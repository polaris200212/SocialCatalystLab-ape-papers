## ============================================================================
## 01_fetch_data.R — Data Acquisition
## APEP-0460: Across the Channel
## ============================================================================
source("00_packages.R")

## ========================================================================
## 1. FACEBOOK SOCIAL CONNECTEDNESS INDEX
## ========================================================================
cat("=== Downloading Facebook SCI (gadm1.zip from HDX) ===\n")

sci_zip <- file.path(data_dir, "gadm1.zip")
sci_tsv <- file.path(data_dir, "gadm1_nuts3_counties.tsv")

if (!file.exists(sci_tsv)) {
  # Download the GADM1/NUTS3/Counties combined file (76.6 MB)
  download.file(
    url = "https://data.humdata.org/dataset/social-connectedness-index/resource/8e1b8b59-c12e-48ea-9af3-41dde75916d5/download/gadm1.zip",
    destfile = sci_zip,
    mode = "wb",
    timeout = 300
  )
  # Extract
  unzip(sci_zip, exdir = data_dir)
  # Find the actual TSV file inside
  tsv_files <- list.files(data_dir, pattern = "\\.tsv$", full.names = TRUE)
  cat("Extracted files:", tsv_files, "\n")
  if (length(tsv_files) == 0) {
    # Try .txt extension
    tsv_files <- list.files(data_dir, pattern = "\\.(tsv|txt|csv)$",
                            full.names = TRUE)
    cat("Alternative files:", tsv_files, "\n")
  }
} else {
  cat("SCI file already exists:", sci_tsv, "\n")
}

# Also try the NUTS 2024 file for France-France connections
nuts_zip <- file.path(data_dir, "nuts_2024.zip")
if (!file.exists(nuts_zip)) {
  cat("=== Downloading NUTS 2024 SCI ===\n")
  download.file(
    url = "https://data.humdata.org/dataset/social-connectedness-index/resource/b691d1d1-b286-456d-9a23-16e2f2d463cc/download/nuts_2024.zip",
    destfile = nuts_zip,
    mode = "wb",
    timeout = 300
  )
  unzip(nuts_zip, exdir = file.path(data_dir, "nuts_2024"))
}

cat("SCI data download complete.\n\n")

## ========================================================================
## 2. DVF — FRENCH PROPERTY TRANSACTIONS
## ========================================================================
cat("=== Downloading DVF property transactions (2014-2023) ===\n")

# DVF is available year by year from data.gouv.fr
# We download the bulk CSV files for each year
dvf_dir <- file.path(data_dir, "dvf")
dir.create(dvf_dir, showWarnings = FALSE)

dvf_years <- 2014:2023

for (yr in dvf_years) {
  dvf_file <- file.path(dvf_dir, paste0("full_", yr, ".csv.gz"))
  if (file.exists(dvf_file) || file.exists(gsub("\\.gz$", "", dvf_file))) {
    cat("DVF", yr, "already exists, skipping.\n")
    next
  }

  # Use the data.gouv.fr open data URL
  # DVF is served from the cadastre API endpoint
  url <- paste0("https://files.data.gouv.fr/geo-dvf/latest/csv/",
                yr, "/full.csv.gz")
  cat("Downloading DVF", yr, "from", url, "\n")

  tryCatch({
    download.file(url, destfile = dvf_file, mode = "wb", timeout = 600)
    cat("  Downloaded:", dvf_file, "\n")
  }, error = function(e) {
    # Try alternative URL format
    url2 <- paste0("https://static.data.gouv.fr/resources/demandes-de-valeurs-foncieres/",
                   yr, "/full.csv.gz")
    cat("  Primary URL failed, trying alternative...\n")
    tryCatch({
      download.file(url2, destfile = dvf_file, mode = "wb", timeout = 600)
    }, error = function(e2) {
      cat("  WARNING: Could not download DVF for", yr, "\n")
    })
  })
}

cat("DVF download complete.\n\n")

## ========================================================================
## 3. INSEE BDM — UNEMPLOYMENT, FIRM CREATION, EMPLOYMENT
## ========================================================================
cat("=== Fetching INSEE BDM data via SDMX API ===\n")

# ---- 3a. Département-level unemployment rates (quarterly) ----
cat("Fetching unemployment rates...\n")

# Use the insee R package to query the BDM SDMX endpoint
# TAUX-CHOMAGE-LOCALISE at département level
# We need to find the right series identifiers

# Search for unemployment series at département level
tryCatch({
  # Get the list of available series for localized unemployment
  unemp_search <- search_insee("taux de chômage localisé")
  cat("  Found", nrow(unemp_search), "unemployment series\n")

  # Filter for département-level quarterly data
  unemp_dept <- unemp_search %>%
    filter(grepl("département|departement", tolower(TITLE_FR)) |
             grepl("^[0-9]{2}[A-B]?$", substr(REF_AREA, 1, 3))) %>%
    head(200)

  if (nrow(unemp_dept) > 0) {
    cat("  Found", nrow(unemp_dept), "département-level unemployment series\n")
    # Fetch the actual data
    unemp_ids <- unemp_dept$idbank[1:min(200, nrow(unemp_dept))]
    unemp_data <- get_insee_idbank(unemp_ids)
    cat("  Downloaded", nrow(unemp_data), "observations\n")
    saveRDS(unemp_data, file.path(data_dir, "insee_unemployment_raw.rds"))
  }
}, error = function(e) {
  cat("  Note: Direct idbank approach failed, using alternative method.\n")
  cat("  Error:", conditionMessage(e), "\n")
})

# Alternative: Direct SDMX query for unemployment
tryCatch({
  cat("Trying direct SDMX query for unemployment...\n")
  # The dataflow for localized unemployment rates
  unemp_url <- paste0(
    "https://bdm.insee.fr/series/sdmx/data/TAUX-CHOMAGE-LOCALISE/",
    "T..DEP?startPeriod=2014-Q1&endPeriod=2023-Q4"
  )
  unemp_raw <- fread(unemp_url, header = TRUE)
  cat("  Direct SDMX:", nrow(unemp_raw), "rows\n")
  saveRDS(unemp_raw, file.path(data_dir, "insee_unemployment_sdmx.rds"))
}, error = function(e) {
  cat("  Direct SDMX also failed:", conditionMessage(e), "\n")
  cat("  Will try idbank list method in cleaning script.\n")
})

# ---- 3b. Firm creation counts (département-level, monthly/quarterly) ----
cat("Fetching firm creation counts...\n")

tryCatch({
  firm_search <- search_insee("créations d'entreprises")
  cat("  Found", nrow(firm_search), "firm creation series\n")

  firm_dept <- firm_search %>%
    filter(grepl("département|departement", tolower(TITLE_FR))) %>%
    head(200)

  if (nrow(firm_dept) > 0) {
    cat("  Found", nrow(firm_dept), "département-level firm series\n")
    firm_ids <- firm_dept$idbank[1:min(200, nrow(firm_dept))]
    firm_data <- get_insee_idbank(firm_ids)
    cat("  Downloaded", nrow(firm_data), "observations\n")
    saveRDS(firm_data, file.path(data_dir, "insee_firm_creation_raw.rds"))
  }
}, error = function(e) {
  cat("  Firm creation fetch error:", conditionMessage(e), "\n")
})

# ---- 3c. Salaried employment (ESTEL, département-level, annual) ----
cat("Fetching employment data...\n")

tryCatch({
  emp_search <- search_insee("emploi salarié")
  cat("  Found", nrow(emp_search), "employment series\n")

  emp_dept <- emp_search %>%
    filter(grepl("département|departement", tolower(TITLE_FR))) %>%
    head(200)

  if (nrow(emp_dept) > 0) {
    cat("  Found", nrow(emp_dept), "département-level employment series\n")
    emp_ids <- emp_dept$idbank[1:min(200, nrow(emp_dept))]
    emp_data <- get_insee_idbank(emp_ids)
    cat("  Downloaded", nrow(emp_data), "observations\n")
    saveRDS(emp_data, file.path(data_dir, "insee_employment_raw.rds"))
  }
}, error = function(e) {
  cat("  Employment fetch error:", conditionMessage(e), "\n")
})

cat("INSEE BDM data complete.\n\n")

## ========================================================================
## 4. ONS — UK REGIONAL GVA DATA
## ========================================================================
cat("=== Downloading ONS UK regional GVA data ===\n")

ons_dir <- file.path(data_dir, "ons")
dir.create(ons_dir, showWarnings = FALSE)

# Regional GVA by ITL3 — Annual
# ONS publishes this as an Excel file
ons_gva_file <- file.path(ons_dir, "regionalgva_itl.xlsx")

if (!file.exists(ons_gva_file)) {
  # The ONS regional GDP dataset (all NUTS/ITL levels)
  # Try the direct download URL
  tryCatch({
    download.file(
      url = "https://www.ons.gov.uk/file?uri=/economy/grossdomesticproductgdp/datasets/regionalgrossdomesticproductallnutslevelregions/1998to2022/regionalgdpbylocalauthorityitl.xlsx",
      destfile = ons_gva_file,
      mode = "wb",
      timeout = 300
    )
    cat("  Downloaded ONS regional GVA file.\n")
  }, error = function(e) {
    cat("  Primary ONS URL failed, trying alternative...\n")
    # Try alternative URL patterns
    tryCatch({
      download.file(
        url = "https://www.ons.gov.uk/file?uri=/economy/grossvalueaddedgva/datasets/nominalandrealregionalgrossvalueaddedbalancedbyindustry/current/regionalgvabylaindustry.xlsx",
        destfile = ons_gva_file,
        mode = "wb",
        timeout = 300
      )
    }, error = function(e2) {
      cat("  WARNING: Could not download ONS GVA file automatically.\n")
      cat("  Please manually download from:\n")
      cat("  https://www.ons.gov.uk/economy/grossdomesticproductgdp/datasets/regionalgrossdomesticproductallnutslevelregions\n")
    })
  })
} else {
  cat("ONS GVA file already exists.\n")
}

cat("ONS data download complete.\n\n")

## ========================================================================
## 5. EUROSTAT — UK + FRANCE NUTS-3 POPULATION DATA
## ========================================================================
cat("=== Downloading Eurostat population data (for SCI weighting) ===\n")

pop_file <- file.path(data_dir, "eurostat_nuts3_pop.csv")

if (!file.exists(pop_file)) {
  # Eurostat NUTS-3 population: demo_r_pjanaggr3
  tryCatch({
    pop_url <- paste0(
      "https://ec.europa.eu/eurostat/api/dissemination/sdmx/2.1/data/",
      "demo_r_pjanaggr3/A.NR.T.TOTAL.?",
      "startPeriod=2015&endPeriod=2016"
    )
    download.file(pop_url, destfile = pop_file, mode = "wb", timeout = 300)
  }, error = function(e) {
    # Alternative: use TSV bulk download
    cat("  Eurostat API failed, trying bulk download...\n")
    tryCatch({
      pop_url2 <- "https://ec.europa.eu/eurostat/api/dissemination/sdmx/2.1/data/demo_r_pjangrp3?format=TSV&compressed=true"
      download.file(pop_url2,
                    destfile = file.path(data_dir, "eurostat_pop.tsv.gz"),
                    mode = "wb", timeout = 600)
    }, error = function(e2) {
      cat("  WARNING: Eurostat population download failed.\n")
      cat("  Will construct population weights from SCI data or census.\n")
    })
  })
}

## ========================================================================
## 6. FRENCH DÉPARTEMENT SHAPEFILE
## ========================================================================
cat("=== Downloading French département shapefile ===\n")

shp_dir <- file.path(data_dir, "shapefiles")
dir.create(shp_dir, showWarnings = FALSE)

fr_shp_file <- file.path(shp_dir, "departements-20180101.shp")

if (!file.exists(fr_shp_file)) {
  tryCatch({
    # IGN Admin Express or data.gouv.fr départements
    download.file(
      url = "https://www.data.gouv.fr/fr/datasets/r/90b9341a-e1f7-4d75-a73c-bbc010c7feeb",
      destfile = file.path(shp_dir, "departements.zip"),
      mode = "wb",
      timeout = 300
    )
    unzip(file.path(shp_dir, "departements.zip"), exdir = shp_dir)
    cat("  Downloaded French département shapefile.\n")
  }, error = function(e) {
    cat("  WARNING: Shapefile download failed.\n")
    cat("  Will use alternative source or skip mapping.\n")
  })
}

cat("\n=== All data downloads complete ===\n")
cat("Files in data directory:\n")
cat(paste(list.files(data_dir, recursive = TRUE), collapse = "\n"), "\n")
