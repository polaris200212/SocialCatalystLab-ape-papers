# =============================================================================
# 01_fetch_data.R — Data acquisition for CTS localisation paper
# apep_0493
# =============================================================================
# Sources:
#   1. NOMIS: Claimant count by LA (monthly, 2008-2023)
#   2. DLUHC: Council Taxbase LCTS data (annual, 2012-2023)
#   3. DLUHC: Council tax collection rates & arrears (annual, 2004-2023)
#   4. DLUHC: Band D council tax levels (annual, 2008-2023)
#   5. ONS: Mid-year population estimates (annual, 2008-2023)
# =============================================================================

source("00_packages.R")

# =============================================================================
# 1. NOMIS Claimant Count (monthly, LA level)
# =============================================================================
cat("=== Fetching NOMIS claimant count data ===\n")

# Build date range: Jan 2008 to Dec 2023
dates <- format(seq(as.Date("2008-01-01"), as.Date("2023-12-01"), by = "month"),
                "%Y-%m")

# Fetch in yearly chunks to respect API limits
fetch_nomis_cc <- function(year) {
  year_dates <- dates[grepl(paste0("^", year), dates)]
  date_str <- paste(year_dates, collapse = ",")

  url <- paste0(
    "https://www.nomisweb.co.uk/api/v01/dataset/NM_162_1.data.csv",
    "?geography=TYPE464",    # Local Authority Districts (pre-2015 boundaries)
    "&date=", date_str,
    "&gender=0",             # Total
    "&age=0",                # All ages
    "&measure=1",            # Level
    "&measures=20100"        # Value
  )

  tryCatch({
    tmp <- tempfile(fileext = ".csv")
    download.file(url, tmp, mode = "wb", quiet = TRUE)
    df <- fread(tmp, showProgress = FALSE)
    unlink(tmp)
    cat("  Year", year, ":", nrow(df), "rows\n")
    return(df)
  }, error = function(e) {
    stop("NOMIS API failed for year ", year, ": ", e$message,
         "\nCannot proceed without claimant count data. Fix the API call.")
  })
}

cc_raw <- rbindlist(lapply(2008:2023, fetch_nomis_cc))

# Also fetch TYPE464 for newer boundary codes (some LAs change codes)
# Try TYPE424 (2021 boundaries) for comparison
fetch_nomis_cc_new <- function(year) {
  year_dates <- dates[grepl(paste0("^", year), dates)]
  date_str <- paste(year_dates, collapse = ",")

  url <- paste0(
    "https://www.nomisweb.co.uk/api/v01/dataset/NM_162_1.data.csv",
    "?geography=TYPE464",
    "&date=", date_str,
    "&gender=0&age=0&measure=1&measures=20100"
  )

  tryCatch({
    tmp <- tempfile(fileext = ".csv")
    download.file(url, tmp, mode = "wb", quiet = TRUE)
    df <- fread(tmp, showProgress = FALSE)
    unlink(tmp)
    return(df)
  }, error = function(e) {
    warning("NOMIS fetch failed for year ", year, ": ", e$message)
    return(NULL)
  })
}

cat("Total claimant count rows:", nrow(cc_raw), "\n")
fwrite(cc_raw, file.path(data_dir, "nomis_claimant_count_raw.csv"))

# =============================================================================
# 2. DLUHC Council Taxbase — LCTS data (treatment variable)
# =============================================================================
cat("\n=== Fetching DLUHC Council Taxbase data ===\n")

# The LCTS-specific file for 2013 (first year of local CTS)
taxbase_urls <- list(
  "2013" = "https://assets.publishing.service.gov.uk/media/5a7bac1ce5274a7202e18ad1/Council_Taxbase_local_authority_level_data_-_LCTS_2013.xls",
  "2013_main" = "https://assets.publishing.service.gov.uk/media/5a7ccb99ed915d63cc65ce40/Council_Taxbase_local_authority_level_data_2013.xlsx",
  "2012" = "https://assets.publishing.service.gov.uk/media/5a7594f2e5274a43682985ff/Revised_2012_Local_Authority_level_data.xls"
)

for (name in names(taxbase_urls)) {
  url <- taxbase_urls[[name]]
  ext <- tools::file_ext(url)
  dest <- file.path(data_dir, paste0("taxbase_", name, ".", ext))

  tryCatch({
    download.file(url, dest, mode = "wb", quiet = TRUE)
    cat("  Downloaded:", name, "(", file.size(dest), "bytes)\n")
  }, error = function(e) {
    warning("Failed to download taxbase ", name, ": ", e$message)
  })
}

# Also download later years — these are in the main LA-level data files
# URL pattern varies by year; try common patterns
for (yr in 2014:2023) {
  # Try multiple URL patterns
  urls_to_try <- c(
    paste0("https://assets.publishing.service.gov.uk/media/Council_Taxbase_local_authority_level_data_", yr, ".xlsx"),
    paste0("https://assets.publishing.service.gov.uk/media/Council_Taxbase_local_authority_level_data_", yr, ".ods")
  )

  # Use the GOV.UK statistics page to find the actual URL
  cat("  Searching for taxbase", yr, "...\n")
  page_url <- paste0("https://www.gov.uk/government/statistics/council-taxbase-", yr, "-in-england")

  tryCatch({
    resp <- httr2::request(page_url) |>
      httr2::req_timeout(30) |>
      httr2::req_perform()

    page_html <- httr2::resp_body_string(resp)

    # Find download links containing "local_authority" or "LA_level"
    links <- regmatches(page_html,
                        gregexpr('https://assets\\.publishing\\.service\\.gov\\.uk/[^"]+(?:local.authority|LA.level|la_level)[^"]*\\.(xls|xlsx|ods)', page_html))[[1]]

    if (length(links) > 0) {
      # Download the first matching file
      ext <- tools::file_ext(links[1])
      dest <- file.path(data_dir, paste0("taxbase_", yr, ".", ext))
      download.file(links[1], dest, mode = "wb", quiet = TRUE)
      cat("    Downloaded:", yr, "(", file.size(dest), "bytes)\n")
    } else {
      cat("    No LA-level data link found for", yr, "\n")
    }
  }, error = function(e) {
    cat("    Could not access page for", yr, ":", e$message, "\n")
  })
}

# =============================================================================
# 3. DLUHC Council Tax Collection Rates & Arrears (mechanism data)
# =============================================================================
cat("\n=== Fetching DLUHC collection rates data ===\n")

# Collection rates are published as annual Excel files
# Try to download key years around the reform
for (yr in 2010:2023) {
  yr2 <- yr + 1
  yr_str <- paste0(yr, "-to-", yr2)
  yr_short <- paste0(sprintf("%02d", yr %% 100), sprintf("%02d", yr2 %% 100))

  page_url <- paste0(
    "https://www.gov.uk/government/statistics/collection-rates-for-council-tax-and-non-domestic-rates-in-england-",
    yr, "-to-", yr2
  )

  tryCatch({
    resp <- httr2::request(page_url) |>
      httr2::req_timeout(30) |>
      httr2::req_perform()

    page_html <- httr2::resp_body_string(resp)

    # Find Excel download links
    links <- regmatches(page_html,
                        gregexpr('https://assets\\.publishing\\.service\\.gov\\.uk/[^"]+\\.(xls|xlsx|ods)', page_html))[[1]]

    if (length(links) > 0) {
      # Download main file (usually the first or one containing "table")
      ext <- tools::file_ext(links[1])
      dest <- file.path(data_dir, paste0("collection_", yr, "_", yr2, ".", ext))
      download.file(links[1], dest, mode = "wb", quiet = TRUE)
      cat("  Downloaded collection rates", yr, "-", yr2, "\n")
    } else {
      cat("  No download link found for", yr, "-", yr2, "\n")
    }
  }, error = function(e) {
    cat("  Could not access collection page for", yr, "-", yr2, "\n")
  })
}

# =============================================================================
# 4. DLUHC Band D Council Tax Levels
# =============================================================================
cat("\n=== Fetching Band D council tax levels ===\n")

# This has a single file covering all years
band_d_url <- "https://www.gov.uk/government/statistical-data-sets/live-tables-on-council-tax"
tryCatch({
  resp <- httr2::request(band_d_url) |>
    httr2::req_timeout(30) |>
    httr2::req_perform()

  page_html <- httr2::resp_body_string(resp)

  # Look for the Band D levels file
  links <- regmatches(page_html,
                      gregexpr('https://assets\\.publishing\\.service\\.gov\\.uk/[^"]+[Bb]and.?[Dd][^"]*\\.(xls|xlsx|ods)', page_html))[[1]]

  if (length(links) > 0) {
    ext <- tools::file_ext(links[1])
    dest <- file.path(data_dir, paste0("band_d_levels.", ext))
    download.file(links[1], dest, mode = "wb", quiet = TRUE)
    cat("  Downloaded Band D levels (", file.size(dest), "bytes)\n")
  } else {
    cat("  No Band D file found on live tables page\n")
  }
}, error = function(e) {
  cat("  Could not access live tables page:", e$message, "\n")
})

# =============================================================================
# 5. ONS Mid-Year Population Estimates (for denominator)
# =============================================================================
cat("\n=== Fetching ONS population estimates ===\n")

# NOMIS also hosts MYE data — use the population estimates dataset
# NM_2002_1 = Mid-Year Population Estimates
pop_url <- paste0(
  "https://www.nomisweb.co.uk/api/v01/dataset/NM_2002_1.data.csv",
  "?geography=TYPE464",
  "&date=2008-2023",
  "&gender=0",          # Total
  "&c_age=200",         # Working age (16-64)
  "&measures=20100"
)

tryCatch({
  tmp <- tempfile(fileext = ".csv")
  download.file(pop_url, tmp, mode = "wb", quiet = TRUE)
  pop_raw <- fread(tmp, showProgress = FALSE)
  unlink(tmp)
  cat("  Population estimates:", nrow(pop_raw), "rows\n")
  fwrite(pop_raw, file.path(data_dir, "nomis_population_raw.csv"))
}, error = function(e) {
  # Try alternative: annual estimates from ONS API
  cat("  NOMIS population failed, trying year-by-year...\n")

  pop_list <- list()
  for (yr in 2008:2023) {
    url2 <- paste0(
      "https://www.nomisweb.co.uk/api/v01/dataset/NM_2002_1.data.csv",
      "?geography=TYPE464",
      "&date=", yr,
      "&gender=0&c_age=200&measures=20100"
    )
    tryCatch({
      tmp2 <- tempfile(fileext = ".csv")
      download.file(url2, tmp2, mode = "wb", quiet = TRUE)
      pop_list[[as.character(yr)]] <- fread(tmp2, showProgress = FALSE)
      unlink(tmp2)
      cat("    Year", yr, ":", nrow(pop_list[[as.character(yr)]]), "rows\n")
    }, error = function(e2) {
      cat("    Failed for", yr, "\n")
    })
  }

  if (length(pop_list) > 0) {
    pop_raw <- rbindlist(pop_list)
    fwrite(pop_raw, file.path(data_dir, "nomis_population_raw.csv"))
    cat("  Total population rows:", nrow(pop_raw), "\n")
  } else {
    stop("Cannot fetch population data from NOMIS. Cannot proceed.")
  }
})

# =============================================================================
# DATA VALIDATION
# =============================================================================
cat("\n=== Data Validation ===\n")

# Check claimant count
stopifnot("Claimant count data is empty" = nrow(cc_raw) > 0)
n_las <- length(unique(cc_raw$GEOGRAPHY_NAME))
n_dates <- length(unique(cc_raw$DATE_NAME))
cat("Claimant count: ", nrow(cc_raw), " rows, ",
    n_las, " LAs, ", n_dates, " dates\n")
stopifnot("Expected 200+ LAs" = n_las >= 200)
stopifnot("Expected 100+ monthly dates" = n_dates >= 100)

# Check taxbase files exist
taxbase_files <- list.files(data_dir, pattern = "^taxbase_", full.names = TRUE)
cat("Taxbase files downloaded:", length(taxbase_files), "\n")
stopifnot("Need at least 2013 LCTS file" = any(grepl("2013", taxbase_files)))

# Check population data
if (file.exists(file.path(data_dir, "nomis_population_raw.csv"))) {
  pop_check <- fread(file.path(data_dir, "nomis_population_raw.csv"))
  cat("Population data:", nrow(pop_check), "rows\n")
} else {
  warning("Population data not yet downloaded — will construct from alternative source")
}

cat("\n=== Data fetch complete ===\n")
cat("Files in data directory:\n")
cat(paste(" ", list.files(data_dir)), sep = "\n")
