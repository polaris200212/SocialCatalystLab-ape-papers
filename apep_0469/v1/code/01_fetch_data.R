## ============================================================================
## 01_fetch_data.R — Data Acquisition for apep_0469
## Missing Men, Rising Women
## ============================================================================
## REPLICATION NOTE:
## - IPUMS MLP linked extract requires web interface (API does not support MLP):
##   https://usa.ipums.org/usa/mlp/mlp_extracts.shtml
##   Request 1% linked samples for 1930, 1940, 1950 with HISTID and all
##   standard demographic/labor variables. Place .dat.gz and .xml in data/
## - CenSoc Enlistment-Census-1940: Harvard Dataverse (free, direct download)
## - County shapefiles: tigris R package (automatic download)
## - All raw data can be deleted after analysis; rerun this script to re-fetch
## ============================================================================

source("code/00_packages.R")

data_dir <- "data"
dir.create(data_dir, showWarnings = FALSE)

## --------------------------------------------------------------------------
## 1. IPUMS MLP Extract (1930-1940-1950 linked censuses)
## --------------------------------------------------------------------------
## CRITICAL: HISTID (the person linkage key) is ONLY available in full-count
## datasets or in pre-linked MLP extracts from the web interface.
## Regular 1% API extracts do NOT include HISTID.
##
## TWO-TRACK APPROACH:
##   Track A: Submit a regular 1% extract via ipumsr for immediate use
##            (cross-sectional analysis, county-level aggregates)
##   Track B: User manually requests MLP linked extract from web interface
##            (individual panel analysis, decomposition)
##
## The code in 02_clean_data.R handles both cases.
## --------------------------------------------------------------------------

cat("=== IPUMS MLP Data ===\n")

ipums_rds <- file.path(data_dir, "ipums_mlp_clean.rds")

if (!file.exists(ipums_rds)) {

  # Check for manually placed MLP extract files
  ddi_files <- list.files(data_dir, pattern = "usa_.*\\.xml$", full.names = TRUE)
  dat_files <- list.files(data_dir, pattern = "usa_.*\\.(dat\\.gz|csv\\.gz)$", full.names = TRUE)

  if (length(ddi_files) > 0 && length(dat_files) > 0) {
    cat("Found IPUMS extract files. Reading with ipumsr...\n")
    ddi <- read_ipums_ddi(ddi_files[1])
    mlp <- as.data.table(read_ipums_micro(ddi, data_file = dat_files[1]))
    cat(sprintf("IPUMS records: %s\n", format(nrow(mlp), big.mark = ",")))
    cat(sprintf("Memory: %s\n", format(object.size(mlp), units = "GB")))
    saveRDS(mlp, ipums_rds)
    cat("Saved:", ipums_rds, "\n")

  } else {
    # Track A: Submit 1% extract via ipumsr (no HISTID, cross-sectional only)
    cat("No MLP extract files found. Attempting ipumsr API extract...\n")
    cat("NOTE: This 1% extract will NOT have HISTID (linking key).\n")
    cat("For linked panel analysis, request MLP extract from:\n")
    cat("  https://usa.ipums.org/usa/mlp/mlp_extracts.shtml\n\n")

    api_key <- Sys.getenv("IPUMS_API_KEY")
    if (nchar(api_key) > 0) {
      tryCatch({
        set_ipums_api_key(api_key)

        extract_def <- define_extract_micro(
          collection = "usa",
          description = "APEP 0469: 1% samples 1930-1940-1950",
          samples = c("us1930a", "us1940a", "us1950a"),
          variables = c("YEAR", "SERIAL", "PERNUM", "STATEFIP", "COUNTY",
                        "URBAN", "FARM", "SEX", "AGE", "RACE", "BPL",
                        "MARST", "NCHILD", "RELATE", "LABFORCE",
                        "OCC1950", "OCCSCORE", "SEI", "IND1950",
                        "EDUC", "INCWAGE", "VETSTAT", "OWNERSHP", "EMPSTAT")
        )

        cat("Submitting IPUMS extract...\n")
        submitted <- submit_extract(extract_def)
        cat(sprintf("Extract submitted. ID: %s\n", submitted$number))
        cat("Waiting for extract to complete (may take 5-30 minutes)...\n")

        ready <- wait_for_extract(submitted, timeout = 1800)  # 30 min timeout
        cat("Extract ready. Downloading...\n")

        dl_path <- download_extract(ready, download_dir = data_dir)
        cat(sprintf("Downloaded: %s\n", dl_path))

        # Read the extract
        ddi_new <- list.files(data_dir, pattern = "usa_.*\\.xml$", full.names = TRUE)
        if (length(ddi_new) > 0) {
          ddi <- read_ipums_ddi(ddi_new[1])
          dat_new <- list.files(data_dir, pattern = "usa_.*\\.(dat\\.gz|csv\\.gz)$", full.names = TRUE)
          mlp <- as.data.table(read_ipums_micro(ddi, data_file = dat_new[1]))
          cat(sprintf("IPUMS records: %s\n", format(nrow(mlp), big.mark = ",")))
          saveRDS(mlp, ipums_rds)
          cat("Saved:", ipums_rds, "\n")
        }

      }, error = function(e) {
        cat("IPUMS API extract failed:", conditionMessage(e), "\n")
        cat("Please manually request extract from: https://usa.ipums.org/usa/mlp/mlp_extracts.shtml\n")
        cat("Place .dat.gz and .xml files in the data/ directory.\n")
      })
    } else {
      cat("No IPUMS_API_KEY found in environment.\n")
      cat("Please request extract manually from: https://usa.ipums.org/usa/mlp/mlp_extracts.shtml\n")
      cat("Place .dat.gz and .xml files in the data/ directory.\n")
    }
  }
} else {
  cat("IPUMS data already exists:", ipums_rds, "\n")
}


## --------------------------------------------------------------------------
## 2. CenSoc WWII Army Enlistment Records (linked to 1940 Census)
## --------------------------------------------------------------------------
## Harvard Dataverse: doi:10.7910/DVN/ZFVVNA
## Key dataset: Enlistment-Census-1940 linked file
##   - Links WWII Army enlistees to their 1940 Census records via HISTID
##   - Contains county FIPS codes for constructing mobilization rates
##   - File ID: 10410790 (Enlistment-Census-1940 linked, ~868 MB)
## --------------------------------------------------------------------------

cat("\n=== CenSoc WWII Enlistment Data ===\n")

censoc_rds <- file.path(data_dir, "censoc_enlistment.rds")

if (!file.exists(censoc_rds)) {

  # Direct file IDs from Harvard Dataverse (doi:10.7910/DVN/ZFVVNA)
  # These use the numeric file ID format which is more reliable than persistentId
  urls <- list(
    enlist_census = "https://dataverse.harvard.edu/api/access/datafile/10410790",  # Enlistment-Census-1940 linked
    enlist_raw    = "https://dataverse.harvard.edu/api/access/datafile/10410797"   # Raw enlistment records
  )

  # Try the Enlistment-Census-1940 linked file first (has HISTID + county)
  censoc_file <- file.path(data_dir, "censoc_enlistment_census_1940.csv")

  cat("Downloading CenSoc Enlistment-Census-1940 linked data...\n")
  cat("Source: Harvard Dataverse (doi:10.7910/DVN/ZFVVNA)\n")
  cat("This file links WWII enlistees to their 1940 Census records.\n")

  download_success <- FALSE

  tryCatch({
    download.file(urls$enlist_census, censoc_file, mode = "wb", quiet = FALSE)

    if (file.size(censoc_file) > 1000) {
      censoc <- fread(censoc_file, nThread = getDTthreads())
      cat(sprintf("CenSoc records: %s\n", format(nrow(censoc), big.mark = ",")))
      cat(sprintf("Columns: %s\n", paste(head(names(censoc), 20), collapse = ", ")))
      saveRDS(censoc, censoc_rds)
      cat("Saved:", censoc_rds, "\n")
      download_success <- TRUE
    }
  }, error = function(e) {
    cat("Enlistment-Census linked file download failed:", conditionMessage(e), "\n")
  })

  # Fallback: try raw enlistment records
  if (!download_success) {
    cat("\nTrying raw enlistment records...\n")
    raw_file <- file.path(data_dir, "censoc_enlistment_raw.csv")

    tryCatch({
      download.file(urls$enlist_raw, raw_file, mode = "wb", quiet = FALSE)

      if (file.size(raw_file) > 1000) {
        censoc <- fread(raw_file, nThread = getDTthreads())
        cat(sprintf("CenSoc raw records: %s\n", format(nrow(censoc), big.mark = ",")))
        saveRDS(censoc, censoc_rds)
        cat("Saved:", censoc_rds, "\n")
        download_success <- TRUE
      }
    }, error = function(e) {
      cat("Raw enlistment download failed:", conditionMessage(e), "\n")
    })
  }

  # Fallback 2: CenSoc download portal
  if (!download_success) {
    cat("\nHarvard Dataverse download failed.\n")
    cat("Alternative: Visit https://censoc-download.demog.berkeley.edu/\n")
    cat("  Fill in the form to receive a download link via email.\n")
    cat("  Download the WWII Army Enlistment file and place in data/\n")
    cat("\nProceeding with 1950 veteran status as mobilization proxy.\n")
  }

} else {
  cat("CenSoc data already exists:", censoc_rds, "\n")
}


## --------------------------------------------------------------------------
## 3. County denominators (constructed from IPUMS data in 02_clean_data.R)
## --------------------------------------------------------------------------

cat("\n=== County denominators will be constructed from IPUMS data in 02_clean_data.R ===\n")


## --------------------------------------------------------------------------
## 4. County Shapefiles for Maps
## --------------------------------------------------------------------------

cat("\n=== County Shapefiles ===\n")

shp_file <- file.path(data_dir, "counties_1940.rds")

if (!file.exists(shp_file)) {
  cat("Downloading county shapefiles from tigris...\n")

  tryCatch({
    counties <- tigris::counties(year = 2020, cb = TRUE) |>
      sf::st_transform(crs = 5070)  # Albers Equal Area

    counties$fips <- as.integer(paste0(counties$STATEFP, counties$COUNTYFP))

    saveRDS(counties, shp_file)
    cat(sprintf("County shapefiles: %d counties\n", nrow(counties)))
  }, error = function(e) {
    cat("WARNING: Could not download county shapefiles.\n")
    cat("Maps will be skipped. Error:", conditionMessage(e), "\n")
  })
} else {
  cat("County shapefiles already exist:", shp_file, "\n")
}


## --------------------------------------------------------------------------
## 5. War Production Data (Jaworski 2017)
## --------------------------------------------------------------------------

cat("\n=== War Production Data ===\n")
cat("NOTE: Jaworski (2017) data requires OpenICPSR account.\n")
cat("Download from: https://www.openicpsr.org/openicpsr/project/140421\n")
cat("For this analysis, we construct war production proxies from CenSoc\n")
cat("enlistment data (manufacturing share in 1940 by county).\n")


## --------------------------------------------------------------------------
## Summary
## --------------------------------------------------------------------------

cat("\n=== Data Fetch Summary ===\n")
cat(sprintf("  IPUMS MLP:       %s\n", ifelse(file.exists(ipums_rds), "✓", "PENDING")))
cat(sprintf("  CenSoc:          %s\n", ifelse(file.exists(censoc_rds), "✓", "PENDING")))
cat(sprintf("  County shapes:   %s\n", ifelse(file.exists(shp_file), "✓", "PENDING")))
cat("\nData fetch complete. Proceed to 02_clean_data.R\n")
