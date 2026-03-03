## =============================================================================
## apep_0488: The Welfare Cost of PDMPs — Sufficient Statistics Approach
## 01_fetch_data.R: Fetch all data sources
## =============================================================================

source("00_packages.R")

## ---------------------------------------------------------------------------
## 1. RAND OPTIC: PDMP policy dates
## ---------------------------------------------------------------------------
cat("=== Fetching RAND OPTIC PDMP policy dates ===\n")

optic_url <- "https://raw.githubusercontent.com/cdigenna/OPTIC-data/main/PDMP/WEB_PDMP.dta"
optic_path <- file.path(DATA_DIR, "optic_pdmp.dta")
if (!file.exists(optic_path)) {
  download.file(optic_url, optic_path, mode = "wb")
}
pdmp_raw <- haven::read_dta(optic_path)
cat("OPTIC PDMP rows:", nrow(pdmp_raw), "cols:", ncol(pdmp_raw), "\n")

# Naloxone access laws
nal_url <- "https://raw.githubusercontent.com/cdigenna/OPTIC-data/main/NAL/WEB_NAL.dta"
nal_path <- file.path(DATA_DIR, "optic_nal.dta")
if (!file.exists(nal_path)) {
  download.file(nal_url, nal_path, mode = "wb")
}
nal_raw <- haven::read_dta(nal_path)

# Good Samaritan laws
gsl_url <- "https://raw.githubusercontent.com/cdigenna/OPTIC-data/main/GSL/WEB_GSL.dta"
gsl_path <- file.path(DATA_DIR, "optic_gsl.dta")
if (!file.exists(gsl_path)) {
  download.file(gsl_url, gsl_path, mode = "wb")
}
gsl_raw <- haven::read_dta(gsl_path)

## ---------------------------------------------------------------------------
## 2. Medicare Part D: Opioid Prescribing Rates by Geography (state-level)
##    CMS data API: dataset UUID 94d00f36-73ce-4520-9b3f-83cd3cded25c
## ---------------------------------------------------------------------------
cat("\n=== Fetching Medicare Part D Opioid Prescribing by Geography ===\n")

geo_opioid_path <- file.path(DATA_DIR, "opioid_rates_geography.rds")
if (!file.exists(geo_opioid_path)) {
  # CMS data API returns JSON; paginate to get all records
  cms_uuid <- "94d00f36-73ce-4520-9b3f-83cd3cded25c"
  page_size <- 5000
  offset <- 0
  all_records <- list()

  cat("  Downloading from CMS data API (JSON, paginated)...\n")
  repeat {
    api_url <- sprintf(
      "https://data.cms.gov/data-api/v1/dataset/%s/data?size=%d&offset=%d",
      cms_uuid, page_size, offset
    )
    tryCatch({
      page <- fromJSON(api_url, flatten = TRUE)
      if (length(page) == 0 || (is.data.frame(page) && nrow(page) == 0)) break
      all_records[[length(all_records) + 1]] <- as_tibble(page)
      cat(sprintf("    Page %d: %d records (offset %d)\n",
                  length(all_records), nrow(page), offset))
      if (nrow(page) < page_size) break
      offset <- offset + page_size
    }, error = function(e) {
      cat("    API error at offset", offset, ":", conditionMessage(e), "\n")
      break
    })
  }

  if (length(all_records) > 0) {
    geo_data <- bind_rows(all_records)
    cat("  Total CMS records:", nrow(geo_data), "\n")
    cat("  Columns:", paste(names(geo_data), collapse = ", "), "\n")
    saveRDS(geo_data, geo_opioid_path)
    cat("  Saved to", geo_opioid_path, "\n")
  } else {
    cat("  ERROR: Could not download CMS opioid prescribing data.\n")
  }
} else {
  cat("  Already have CMS opioid geography data\n")
}

## ---------------------------------------------------------------------------
## 3. CDC Mortality: NCHS + VSRR drug overdose data
## ---------------------------------------------------------------------------
cat("\n=== Fetching CDC mortality data ===\n")

# NCHS Drug Poisoning Mortality by State
nchs_url <- "https://data.cdc.gov/api/views/xbxb-epbu/rows.csv?accessType=DOWNLOAD"
nchs_path <- file.path(DATA_DIR, "nchs_drug_overdose_deaths.csv")
if (!file.exists(nchs_path)) {
  tryCatch({
    download.file(nchs_url, nchs_path, mode = "wb")
    cat("  Downloaded NCHS drug poisoning mortality data\n")
  }, error = function(e) {
    cat("  WARN: Could not download NCHS data:", conditionMessage(e), "\n")
  })
} else {
  cat("  Already have NCHS data\n")
}

# VSRR provisional overdose data (2015-2025, monthly 12-month-ending)
vsrr_url <- "https://data.cdc.gov/api/views/xkb8-kh2a/rows.csv?accessType=DOWNLOAD"
vsrr_path <- file.path(DATA_DIR, "vsrr_provisional_overdose.csv")
if (!file.exists(vsrr_path)) {
  tryCatch({
    download.file(vsrr_url, vsrr_path, mode = "wb")
    cat("  Downloaded VSRR provisional overdose data\n")
  }, error = function(e) {
    cat("  WARN: Could not download VSRR data:", conditionMessage(e), "\n")
  })
} else {
  cat("  Already have VSRR data\n")
}

## ---------------------------------------------------------------------------
## 4. Census ACS: State-level demographics
## ---------------------------------------------------------------------------
cat("\n=== Fetching Census ACS state demographics ===\n")

census_key <- Sys.getenv("CENSUS_API_KEY")
acs_path <- file.path(DATA_DIR, "acs_state_demographics.rds")
if (nchar(census_key) > 0 && !file.exists(acs_path)) {
  acs_years <- 2013:2022
  acs_all <- map_dfr(acs_years, function(yr) {
    url <- sprintf(
      "https://api.census.gov/data/%d/acs/acs1?get=NAME,B01003_001E,B19013_001E,B17001_002E,B02001_002E,B02001_003E,B03003_003E&for=state:*&key=%s",
      yr, census_key
    )
    tryCatch({
      resp <- fromJSON(url)
      df <- as.data.frame(resp[-1, ], stringsAsFactors = FALSE)
      names(df) <- resp[1, ]
      df$year <- yr
      df
    }, error = function(e) {
      cat("  ACS", yr, "error:", conditionMessage(e), "\n")
      NULL
    })
  })
  if (!is.null(acs_all) && nrow(acs_all) > 0) {
    saveRDS(acs_all, acs_path)
    cat("  Saved ACS data:", nrow(acs_all), "rows\n")
  }
} else if (file.exists(acs_path)) {
  cat("  Already have ACS data\n")
} else {
  cat("  WARN: No CENSUS_API_KEY — skipping ACS download\n")
}

## ---------------------------------------------------------------------------
## 5. FRED: State unemployment rates
## ---------------------------------------------------------------------------
cat("\n=== Fetching FRED state unemployment rates ===\n")

fred_key <- Sys.getenv("FRED_API_KEY")
fred_path <- file.path(DATA_DIR, "fred_state_unemployment.rds")
if (nchar(fred_key) > 0 && !file.exists(fred_path)) {
  state_abbrevs <- c(state.abb, "DC")
  fred_all <- map_dfr(state_abbrevs, function(st) {
    series_id <- paste0(st, "UR")
    url <- sprintf(
      "https://api.stlouisfed.org/fred/series/observations?series_id=%s&api_key=%s&file_type=json&observation_start=2010-01-01&observation_end=2023-12-31&frequency=a",
      series_id, fred_key
    )
    tryCatch({
      resp <- fromJSON(url)
      if (!is.null(resp$observations) && nrow(resp$observations) > 0) {
        resp$observations %>%
          mutate(state = st, date = as.Date(date), value = as.numeric(value)) %>%
          select(state, date, value)
      } else { tibble() }
    }, error = function(e) { tibble() })
  })
  if (nrow(fred_all) > 0) {
    saveRDS(fred_all, fred_path)
    cat("  Saved FRED data:", nrow(fred_all), "rows\n")
  }
} else if (file.exists(fred_path)) {
  cat("  Already have FRED data\n")
} else {
  cat("  WARN: No FRED_API_KEY — skipping FRED download\n")
}

## ---------------------------------------------------------------------------
## Summary
## ---------------------------------------------------------------------------
cat("\n=== Data fetch summary ===\n")
data_files <- list.files(DATA_DIR, full.names = TRUE)
cat("Files in data/:\n")
for (f in data_files) {
  cat(sprintf("  %s (%s)\n", basename(f),
              format(file.size(f), big.mark = ",")))
}
