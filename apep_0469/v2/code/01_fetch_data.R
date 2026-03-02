## ============================================================================
## 01_fetch_data.R — Data Acquisition for apep_0469 v2
## FULL-COUNT IPUMS (100%) with HISTID for longitudinal panel
## ============================================================================
## REPLICATION NOTE:
## - This script downloads IPUMS full-count (100%) census data for 1930, 1940,
##   and 1950. These are ~123M, ~132M, and ~151M records respectively.
## - HISTID (the person linkage key) is ONLY available in full-count databases.
##   It is NOT available in 1% samples.
## - Requires IPUMS_API_KEY in .env
## - CenSoc WWII Enlistment-Census-1940: Harvard Dataverse (free download)
## - Expect download to take 1-3 hours for the full extract.
## ============================================================================

source("code/00_packages.R")

data_dir <- "data"
dir.create(data_dir, showWarnings = FALSE)

## --------------------------------------------------------------------------
## 1. IPUMS Full-Count Extract with HISTID
## --------------------------------------------------------------------------

cat("=== IPUMS Full-Count Data with HISTID ===\n")

ipums_rds <- file.path(data_dir, "ipums_fullcount.rds")

if (!file.exists(ipums_rds)) {

  # Check for manually placed extract files first
  ddi_files <- list.files(data_dir, pattern = "usa_.*\\.xml$", full.names = TRUE)
  dat_files <- list.files(data_dir, pattern = "usa_.*\\.(dat\\.gz|csv\\.gz)$", full.names = TRUE)

  if (length(ddi_files) > 0 && length(dat_files) > 0) {
    cat("Found IPUMS extract files. Reading in chunks with ipumsr...\n")
    cat("NOTE: ipumsr's read_ipums_micro hits SET_STRING_ELT overflow with\n")
    cat("  283M+ rows (HISTID UUID strings). Using chunked reader instead.\n")
    cat("  Writing each chunk to disk immediately (no in-memory accumulation).\n")
    ddi <- read_ipums_ddi(ddi_files[1])

    # Disk-based chunked reading: write each chunk to a temp RDS file.
    # In-memory accumulation via closures causes GC thrashing at 250M+ rows.
    tmp_dir <- file.path(data_dir, "tmp_chunks")
    dir.create(tmp_dir, showWarnings = FALSE)
    chunk_num <- 0L
    total_rows <- 0L

    cat("Starting chunked read (10M rows per chunk)...\n")
    t0 <- Sys.time()
    read_ipums_micro_chunked(
      ddi,
      data_file = dat_files[1],
      callback = IpumsListCallback$new(function(x, pos) {
        chunk_num <<- chunk_num + 1L
        dt <- as.data.table(x)
        total_rows <<- total_rows + nrow(dt)
        yrs <- unique(dt$YEAR)

        # Write each year's subset as a separate temp file
        for (yr in yrs) {
          sub <- dt[YEAR == yr]
          f <- file.path(tmp_dir, sprintf("chunk_%03d_year_%d.rds", chunk_num, yr))
          saveRDS(sub, f)
        }
        rm(dt); gc(verbose = FALSE)

        elapsed <- as.numeric(difftime(Sys.time(), t0, units = "mins"))
        cat(sprintf("  Chunk %d: %s rows (years: %s) [%.1f min, %s total]\n",
            chunk_num, format(nrow(x), big.mark = ","),
            paste(yrs, collapse = ","), elapsed,
            format(total_rows, big.mark = ",")))
        NULL
      }),
      chunk_size = 10000000L
    )

    cat(sprintf("\nFinished reading. Total: %s rows in %.1f minutes\n",
        format(total_rows, big.mark = ","),
        as.numeric(difftime(Sys.time(), t0, units = "mins"))))

    # Combine temp chunk files into year-specific RDS files
    for (yr in c(1930, 1940, 1950)) {
      chunk_files <- sort(list.files(tmp_dir, pattern = sprintf("year_%d\\.rds$", yr),
                                      full.names = TRUE))
      if (length(chunk_files) == 0) next
      cat(sprintf("Combining %d chunk files for %d...\n", length(chunk_files), yr))
      yr_dt <- rbindlist(lapply(chunk_files, readRDS))
      yr_file <- file.path(data_dir, sprintf("ipums_year_%d.rds", yr))
      cat(sprintf("  %s: %s rows (%s)\n", yr,
          format(nrow(yr_dt), big.mark = ","),
          format(object.size(yr_dt), units = "GB")))
      cat(sprintf("  Has HISTID: %s\n", "HISTID" %in% names(yr_dt)))
      saveRDS(yr_dt, yr_file)
      rm(yr_dt); gc()
    }

    # Cleanup temp files
    unlink(tmp_dir, recursive = TRUE)

    # Write marker file so 02_clean_data.R knows data is ready
    writeLines("year_split", ipums_rds)
    cat("Year-specific RDS files saved.\n")

  } else {
    # Submit and download via API
    api_key <- Sys.getenv("IPUMS_API_KEY")
    if (nchar(api_key) == 0) stop("IPUMS_API_KEY not found in environment.")
    set_ipums_api_key(api_key)

    # Check if extract already submitted
    extract_num_file <- file.path(data_dir, "extract_number.txt")
    if (file.exists(extract_num_file)) {
      extract_num <- as.integer(readLines(extract_num_file))
      cat(sprintf("Found existing extract number: %d\n", extract_num))
    } else {
      cat("Submitting new full-count extract...\n")
      ext <- define_extract_micro(
        collection = "usa",
        description = "APEP 0469 v2: Full-count 1930-1940-1950 with HISTID",
        samples = c("us1930d", "us1940b", "us1950b"),
        variables = c("HISTID", "YEAR", "STATEFIP", "SEX", "AGE", "RACE",
                       "BPL", "MARST", "LABFORCE", "EMPSTAT", "OCC1950",
                       "OCCSCORE", "SEI", "EDUC", "RELATE", "URBAN",
                       "FARM", "PERWT")
      )
      sub <- submit_extract(ext)
      extract_num <- sub$number
      writeLines(as.character(extract_num), extract_num_file)
      cat(sprintf("Submitted extract #%d\n", extract_num))
    }

    # Check status and wait
    cat(sprintf("Checking status of extract #%d...\n", extract_num))
    info <- get_extract_info(sprintf("usa:%d", extract_num))
    cat(sprintf("Status: %s\n", info$status))

    if (info$status != "completed") {
      cat("Waiting for extract to complete (full-count takes 1-6 hours)...\n")
      cat("Polling every 5 minutes...\n")
      ready <- wait_for_extract(sprintf("usa:%d", extract_num), timeout = 36000)
      cat("Extract ready!\n")
    }

    # Download
    cat("Downloading full-count extract...\n")
    dl_path <- download_extract(sprintf("usa:%d", extract_num), download_dir = data_dir)
    cat(sprintf("Downloaded: %s\n", dl_path))

    # Read
    ddi_new <- list.files(data_dir, pattern = "usa_.*\\.xml$", full.names = TRUE)
    dat_new <- list.files(data_dir, pattern = "usa_.*\\.(dat\\.gz|csv\\.gz)$", full.names = TRUE)
    if (length(ddi_new) > 0 && length(dat_new) > 0) {
      cat("Reading full-count data into memory...\n")
      gc()
      ddi <- read_ipums_ddi(ddi_new[1])
      mlp <- as.data.table(read_ipums_micro(ddi, data_file = dat_new[1]))
      cat(sprintf("IPUMS records: %s\n", format(nrow(mlp), big.mark = ",")))
      cat(sprintf("Memory: %s\n", format(object.size(mlp), units = "GB")))
      cat(sprintf("Has HISTID: %s\n", "HISTID" %in% names(mlp)))
      saveRDS(mlp, ipums_rds)
      cat("Saved:", ipums_rds, "\n")
    } else {
      stop("Downloaded files not found after download.")
    }
  }
} else {
  cat("IPUMS full-count data already exists:", ipums_rds, "\n")
}


## --------------------------------------------------------------------------
## 2. CenSoc WWII Army Enlistment Records
## --------------------------------------------------------------------------

cat("\n=== CenSoc WWII Enlistment Data ===\n")

censoc_rds <- file.path(data_dir, "censoc_enlistment.rds")

if (!file.exists(censoc_rds)) {
  urls <- list(
    enlist_census = "https://dataverse.harvard.edu/api/access/datafile/10410790",
    enlist_raw    = "https://dataverse.harvard.edu/api/access/datafile/10410797"
  )
  censoc_file <- file.path(data_dir, "censoc_enlistment_census_1940.csv")
  cat("Downloading CenSoc Enlistment-Census-1940...\n")
  download_success <- FALSE
  tryCatch({
    download.file(urls$enlist_census, censoc_file, mode = "wb", quiet = FALSE)
    if (file.size(censoc_file) > 1000) {
      censoc <- fread(censoc_file, nThread = getDTthreads())
      cat(sprintf("CenSoc records: %s\n", format(nrow(censoc), big.mark = ",")))
      saveRDS(censoc, censoc_rds)
      download_success <- TRUE
    }
  }, error = function(e) cat("Download failed:", conditionMessage(e), "\n"))
  if (!download_success) {
    tryCatch({
      raw_file <- file.path(data_dir, "censoc_enlistment_raw.csv")
      download.file(urls$enlist_raw, raw_file, mode = "wb", quiet = FALSE)
      if (file.size(raw_file) > 1000) {
        censoc <- fread(raw_file, nThread = getDTthreads())
        saveRDS(censoc, censoc_rds)
      }
    }, error = function(e) cat("Fallback failed:", conditionMessage(e), "\n"))
  }
} else {
  cat("CenSoc data already exists:", censoc_rds, "\n")
}


## --------------------------------------------------------------------------
## 3. County Shapefiles
## --------------------------------------------------------------------------

cat("\n=== County Shapefiles ===\n")

shp_file <- file.path(data_dir, "counties_1940.rds")
if (!file.exists(shp_file)) {
  tryCatch({
    counties <- tigris::counties(year = 2020, cb = TRUE) |>
      sf::st_transform(crs = 5070)
    counties$fips <- as.integer(paste0(counties$STATEFP, counties$COUNTYFP))
    saveRDS(counties, shp_file)
    cat(sprintf("County shapefiles: %d counties\n", nrow(counties)))
  }, error = function(e) cat("WARNING: Could not download county shapefiles.\n"))
} else {
  cat("County shapefiles already exist:", shp_file, "\n")
}


## --------------------------------------------------------------------------
## Summary
## --------------------------------------------------------------------------

cat("\n=== Data Fetch Summary ===\n")
cat(sprintf("  IPUMS Full-Count: %s\n", ifelse(file.exists(ipums_rds), "READY", "PENDING")))
cat(sprintf("  CenSoc:          %s\n", ifelse(file.exists(censoc_rds), "READY", "PENDING")))
cat(sprintf("  County shapes:   %s\n", ifelse(file.exists(shp_file), "READY", "PENDING")))
cat("\nProceed to 02_clean_data.R\n")
