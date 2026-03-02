## ============================================================
## 01_fetch_data.R — Fetch FDIC SOD and bank financial data
## APEP-0479: Durbin Amendment, Bank Restructuring, and Tellers
## ============================================================

source("00_packages.R")

data_dir <- "../data/"
dir.create(data_dir, showWarnings = FALSE, recursive = TRUE)

## ---- 1. FDIC Summary of Deposits (SOD) ----
## Branch-level data for all FDIC-insured institutions

if (file.exists(file.path(data_dir, "sod_raw.rds"))) {
  cat("SOD data already exists, skipping fetch.\n")
} else {

cat("Fetching FDIC Summary of Deposits...\n")

fetch_sod_year <- function(year) {
  cat(sprintf("  SOD year %d...\n", year))
  base_url <- "https://api.fdic.gov/banks/sod"
  offset <- 0
  limit  <- 10000
  all_data <- list()

  fields <- paste0(
    "CERT,UNINUMBR,STNAME,CNTYNAMB,STCNTYBR,DEPSUMBR,YEAR,",
    "BRSERTYP,NAMEFULL,MSABR,ZIPBR,ADDRESBR,CITYBR"
  )

  repeat {
    url <- sprintf(
      "%s?filters=YEAR%%3A%d&fields=%s&limit=%d&offset=%d&sort_by=CERT&sort_order=ASC",
      base_url, year, fields, limit, offset
    )
    resp <- httr::GET(url, httr::timeout(120))

    if (httr::status_code(resp) != 200) {
      warning(sprintf("HTTP %d for year %d offset %d", httr::status_code(resp), year, offset))
      break
    }

    content <- httr::content(resp, as = "text", encoding = "UTF-8")
    parsed  <- jsonlite::fromJSON(content, flatten = TRUE)

    if (is.null(parsed$data) || length(parsed$data) == 0) break

    # Extract the nested data
    records <- parsed$data
    if ("data" %in% names(records)) {
      # API returns list with nested 'data' element per record
      df <- bind_rows(lapply(records$data, as.data.frame))
    } else {
      df <- as.data.frame(records)
    }

    all_data[[length(all_data) + 1]] <- df

    n_returned <- nrow(df)
    cat(sprintf("    offset %d: %d records\n", offset, n_returned))

    if (n_returned < limit) break
    offset <- offset + limit

    Sys.sleep(0.5)  # Rate limiting
  }

  if (length(all_data) == 0) return(NULL)
  bind_rows(all_data)
}

# Fetch SOD for 2005-2019
sod_years <- 2005:2019
sod_list <- list()

for (yr in sod_years) {
  sod_list[[as.character(yr)]] <- fetch_sod_year(yr)
}

sod_raw <- bind_rows(sod_list)
cat(sprintf("Total SOD records: %s\n", format(nrow(sod_raw), big.mark = ",")))

# Save raw SOD
saveRDS(sod_raw, file.path(data_dir, "sod_raw.rds"))
cat("Saved sod_raw.rds\n")
}  # end SOD skip check


## ---- 2. FDIC Bank Financials ----
## Bank-level asset data to identify Durbin-affected banks (>$10B)

if (file.exists(file.path(data_dir, "financials_raw.rds"))) {
  cat("Financials data already exists, skipping fetch.\n")
} else {

cat("\nFetching FDIC bank financials...\n")

fetch_financials <- function(date_str) {
  cat(sprintf("  Financials %s...\n", date_str))
  base_url <- "https://api.fdic.gov/banks/financials"
  offset <- 0
  limit  <- 10000
  all_data <- list()

  fields <- "CERT,REPNM,ASSET,REPDTE,STNAME"

  repeat {
    url <- sprintf(
      "%s?filters=REPDTE%%3A%s&fields=%s&limit=%d&offset=%d&sort_by=CERT&sort_order=ASC",
      base_url, date_str, fields, limit, offset
    )
    resp <- httr::GET(url, httr::timeout(120))

    if (httr::status_code(resp) != 200) {
      warning(sprintf("HTTP %d for %s offset %d", httr::status_code(resp), date_str, offset))
      break
    }

    content <- httr::content(resp, as = "text", encoding = "UTF-8")
    parsed  <- jsonlite::fromJSON(content, flatten = TRUE)

    if (is.null(parsed$data) || length(parsed$data) == 0) break

    records <- parsed$data
    if ("data" %in% names(records)) {
      df <- bind_rows(lapply(records$data, as.data.frame))
    } else {
      df <- as.data.frame(records)
    }

    all_data[[length(all_data) + 1]] <- df

    n_returned <- nrow(df)
    cat(sprintf("    offset %d: %d records\n", offset, n_returned))

    if (n_returned < limit) break
    offset <- offset + limit

    Sys.sleep(0.5)
  }

  if (length(all_data) == 0) return(NULL)
  bind_rows(all_data)
}

# Fetch financials for key dates
# Pre-Durbin: June 2010 (to define treatment)
# Also: June 2005-2019 for panel
fin_dates <- paste0(2005:2019, "0630")
fin_list <- list()

for (d in fin_dates) {
  fin_list[[d]] <- fetch_financials(d)
}

fin_raw <- bind_rows(fin_list)
cat(sprintf("Total financials records: %s\n", format(nrow(fin_raw), big.mark = ",")))

saveRDS(fin_raw, file.path(data_dir, "financials_raw.rds"))
cat("Saved financials_raw.rds\n")
}  # end financials skip check


## ---- 3. BLS QCEW Data ----
## County-level employment by industry
## Singlefile downloads for all years (API doesn't support sector codes at
## county level). Column name varies: annual_avg_estabs vs annual_avg_estabs_count.

if (file.exists(file.path(data_dir, "qcew_raw.rds")) &&
    file.size(file.path(data_dir, "qcew_raw.rds")) > 10000) {
  cat("QCEW data already exists, skipping fetch.\n")
} else {

cat("\nFetching BLS QCEW data...\n")

industries <- c("522110", "44-45", "31-33", "62")

fetch_qcew_singlefile <- function(year) {
  url <- sprintf(
    "https://data.bls.gov/cew/data/files/%d/csv/%d_annual_singlefile.zip",
    year, year
  )
  temp_zip <- tempfile(fileext = ".zip")
  temp_dir <- tempdir()

  tryCatch({
    exit_code <- system2("curl", args = c(
      "-sL", "-o", temp_zip,
      "--max-time", "600",
      "--retry", "3",
      "--retry-delay", "5",
      url
    ), stdout = FALSE, stderr = FALSE)

    if (exit_code != 0 || !file.exists(temp_zip) || file.size(temp_zip) < 1000) {
      cat(sprintf("    ERROR: download failed for %d\n", year))
      unlink(temp_zip)
      return(NULL)
    }

    cat(sprintf("    Downloaded %.1f MB\n", file.size(temp_zip) / 1e6))
    csv_files <- unzip(temp_zip, exdir = temp_dir)
    csv_file  <- csv_files[grepl("\\.csv$", csv_files)][1]

    # Read only the columns we need (handle varying column names)
    dt <- fread(csv_file, select = c(
      "area_fips", "own_code", "industry_code", "agglvl_code",
      "year", "annual_avg_emplvl", "annual_avg_wkly_wage",
      "total_annual_wages"
    ))

    # Ensure consistent types
    dt[, industry_code := as.character(industry_code)]

    # agglvl_code 73 = County, Supersector (44-45 Retail, 31-33 Manufacturing)
    # agglvl_code 74 = County, NAICS Sector (62 Health Care)
    # agglvl_code 78 = County, NAICS 6-digit (522110 Commercial Banking)
    dt <- dt[own_code == 5 & industry_code %in% industries &
               agglvl_code %in% c(73, 74, 78)]

    unlink(temp_zip)
    unlink(csv_files)

    cat(sprintf("    %d records after filtering\n", nrow(dt)))
    as_tibble(dt)
  }, error = function(e) {
    cat(sprintf("    ERROR: %s\n", e$message))
    NULL
  })
}

qcew_list <- list()

for (yr in 2005:2019) {
  cat(sprintf("  QCEW year %d...\n", yr))
  qcew_list[[as.character(yr)]] <- fetch_qcew_singlefile(yr)
  Sys.sleep(1)
}

qcew_raw <- bind_rows(qcew_list)
cat(sprintf("Total QCEW records: %s\n", format(nrow(qcew_raw), big.mark = ",")))

saveRDS(qcew_raw, file.path(data_dir, "qcew_raw.rds"))
cat("Saved qcew_raw.rds\n")
}  # end QCEW skip check


## ---- 4. County Population Data (Census ACS 5-Year) ----
## For per-capita normalizations
## ACS 5-year available 2009-2019; for 2005-2008 use 2009 values (population
## changes slowly at county level)

cat("\nFetching county population from ACS 5-year...\n")

fetch_acs_pop <- function(year) {
  cat(sprintf("  ACS population %d...\n", year))
  # B01003_001E = Total Population
  url <- sprintf(
    "https://api.census.gov/data/%d/acs/acs5?get=B01003_001E,NAME&for=county:*&in=state:*",
    year
  )

  tryCatch({
    resp <- httr::GET(url, httr::timeout(120))
    if (httr::status_code(resp) != 200) {
      cat(sprintf("    HTTP %d\n", httr::status_code(resp)))
      return(NULL)
    }
    content <- httr::content(resp, as = "text", encoding = "UTF-8")
    parsed  <- jsonlite::fromJSON(content)
    df <- as.data.frame(parsed[-1, ], stringsAsFactors = FALSE)
    names(df) <- parsed[1, ]
    df$year <- year
    df$POP  <- as.numeric(df$B01003_001E)
    df$fips <- paste0(df$state, df$county)
    cat(sprintf("    %d counties\n", nrow(df)))
    df %>% select(fips, NAME, POP, year)
  }, error = function(e) {
    cat(sprintf("    ERROR: %s\n", e$message))
    NULL
  })
}

# ACS 5-year available from 2009 to 2019
pop_list <- list()
for (yr in 2009:2019) {
  pop_list[[as.character(yr)]] <- fetch_acs_pop(yr)
  Sys.sleep(0.5)
}

pop_raw <- bind_rows(pop_list)

# For 2005-2008, replicate 2009 values (slow-changing)
pop_2009 <- pop_raw %>% filter(year == 2009)
for (yr in 2005:2008) {
  fill <- pop_2009 %>% mutate(year = yr)
  pop_raw <- bind_rows(pop_raw, fill)
}

cat(sprintf("Total population records: %s\n", format(nrow(pop_raw), big.mark = ",")))

saveRDS(pop_raw, file.path(data_dir, "population_raw.rds"))
cat("Saved population_raw.rds\n")


## ---- 5. FRED National Banking Aggregates ----
## For context/figures

cat("\nFetching FRED banking aggregates...\n")

fred_key <- Sys.getenv("FRED_API_KEY")

fetch_fred <- function(series_id) {
  url <- sprintf(
    "https://api.stlouisfed.org/fred/series/observations?series_id=%s&api_key=%s&file_type=json&observation_start=2000-01-01",
    series_id, fred_key
  )
  resp <- httr::GET(url, httr::timeout(30))
  if (httr::status_code(resp) != 200) return(NULL)
  content <- httr::content(resp, as = "text", encoding = "UTF-8")
  parsed  <- jsonlite::fromJSON(content)
  parsed$observations %>%
    select(date, value) %>%
    mutate(
      date  = as.Date(date),
      value = as.numeric(value),
      series = series_id
    )
}

fred_series <- c(
  "USNUM"     # Number of commercial banks
)

fred_data <- bind_rows(lapply(fred_series, fetch_fred))
saveRDS(fred_data, file.path(data_dir, "fred_banking.rds"))
cat("Saved fred_banking.rds\n")


cat("\n=== Data fetch complete ===\n")
cat("Files saved to:", data_dir, "\n")
list.files(data_dir, pattern = "\\.rds$")
