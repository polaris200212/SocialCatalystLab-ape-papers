################################################################################
# 01_fetch_data.R — Data Acquisition
# Paper: Digital Exodus or Digital Magnet?
#
# Data Sources:
#   1. BLS QCEW — Quarterly employment by state × NAICS industry
#   2. Census BFS — Monthly business applications by state
#   3. BEA — State quarterly GDP
#   4. Treatment coding — State privacy law effective dates
################################################################################

tryCatch({
  script_dir <- dirname(sys.frame(1)$ofile)
}, error = function(e) {
  # Rscript: use commandArgs to find script location
  args <- commandArgs(trailingOnly = FALSE)
  file_arg <- grep("^--file=", args, value = TRUE)
  if (length(file_arg) > 0) {
    script_dir <<- dirname(sub("^--file=", "", file_arg))
  } else {
    script_dir <<- "."
  }
})
source(file.path(script_dir, "00_packages.R"))

###############################################################################
# 1. TREATMENT CODING: State comprehensive data privacy laws
###############################################################################

cat("=== Coding treatment dates ===\n")

# Comprehensive state data privacy law effective dates
# Source: NCSL, IAPP, Sidley Austin tracker
privacy_laws <- tribble(
  ~state, ~state_abbr, ~enacted_date,    ~effective_date,
  "California",   "CA", "2018-06-28", "2020-01-01",
  "Virginia",     "VA", "2021-03-02", "2023-01-01",
  "Colorado",     "CO", "2021-07-07", "2023-07-01",
  "Connecticut",  "CT", "2022-05-10", "2023-07-01",
  "Utah",         "UT", "2022-03-24", "2023-12-31",
  "Iowa",         "IA", "2023-03-28", "2025-01-01",
  "Indiana",      "IN", "2023-05-01", "2026-01-01",
  "Tennessee",    "TN", "2023-05-11", "2025-07-01",
  "Montana",      "MT", "2023-05-19", "2024-10-01",
  "Oregon",       "OR", "2023-07-18", "2024-07-01",
  "Texas",        "TX", "2023-06-18", "2024-07-01",
  "Delaware",     "DE", "2023-09-11", "2025-01-01",
  "New Hampshire","NH", "2024-03-06", "2025-01-01",
  "New Jersey",   "NJ", "2024-01-16", "2025-01-15",
  "Kentucky",     "KY", "2024-04-04", "2026-01-01",
  "Nebraska",     "NE", "2024-04-17", "2025-01-01",
  "Maryland",     "MD", "2024-05-19", "2025-10-01",
  "Minnesota",    "MN", "2024-05-24", "2025-07-31",
  "Rhode Island", "RI", "2024-06-25", "2026-01-01"
) %>%
  mutate(
    enacted_date = ymd(enacted_date),
    effective_date = ymd(effective_date),
    # For QCEW quarterly: treatment year-quarter as numeric (e.g., 2023.25 = 2023Q1)
    treat_year = year(effective_date),
    treat_qtr = quarter(effective_date),
    # First full quarter after effective date
    treat_yearqtr = treat_year + (treat_qtr - 1) / 4,
    # If effective in mid-quarter, treatment starts next quarter
    treat_yearqtr = ifelse(
      day(effective_date) > 1,
      treat_year + treat_qtr / 4,  # next quarter
      treat_yearqtr
    ),
    # For BFS monthly: treatment month is month of effective date
    treat_year_month = floor_date(effective_date, "month")
  )

# Montana reclassification: effective Oct 1, 2024 = 2024Q4.
# With data ending 2024Q4, Montana has at most 1 quarter of post-treatment
# data and firms had zero compliance lead time before Q4 outcomes were
# measured. Reclassify as not-yet-treated to avoid contaminating estimates.
privacy_laws <- privacy_laws %>%
  mutate(
    treat_yearqtr = ifelse(state_abbr == "MT", NA_real_, treat_yearqtr),
    treat_year_month = if_else(state_abbr == "MT", as.Date(NA), treat_year_month)
  )
cat("Montana reclassified as not-yet-treated (effective Oct 2024, insufficient post-treatment data)\n")
cat("Effectively treated states:", sum(!is.na(privacy_laws$treat_yearqtr)), "\n")

# State FIPS codes (proper hard-coded mapping)
state_fips <- tibble(
  state_abbr = c("AL","AK","AZ","AR","CA","CO","CT","DE","FL","GA",
                  "HI","ID","IL","IN","IA","KS","KY","LA","ME","MD",
                  "MA","MI","MN","MS","MO","MT","NE","NV","NH","NJ",
                  "NM","NY","NC","ND","OH","OK","OR","PA","RI","SC",
                  "SD","TN","TX","UT","VT","VA","WA","WV","WI","WY","DC"),
  state_name = c("Alabama","Alaska","Arizona","Arkansas","California","Colorado",
                  "Connecticut","Delaware","Florida","Georgia","Hawaii","Idaho",
                  "Illinois","Indiana","Iowa","Kansas","Kentucky","Louisiana",
                  "Maine","Maryland","Massachusetts","Michigan","Minnesota",
                  "Mississippi","Missouri","Montana","Nebraska","Nevada",
                  "New Hampshire","New Jersey","New Mexico","New York",
                  "North Carolina","North Dakota","Ohio","Oklahoma","Oregon",
                  "Pennsylvania","Rhode Island","South Carolina","South Dakota",
                  "Tennessee","Texas","Utah","Vermont","Virginia","Washington",
                  "West Virginia","Wisconsin","Wyoming","District of Columbia"),
  fips = c("01","02","04","05","06","08","09","10","12","13",
           "15","16","17","18","19","20","21","22","23","24",
           "25","26","27","28","29","30","31","32","33","34",
           "35","36","37","38","39","40","41","42","44","45",
           "46","47","48","49","50","51","53","54","55","56","11")
)

write_csv(privacy_laws, file.path(DATA_DIR, "privacy_law_dates.csv"))
write_csv(state_fips, file.path(DATA_DIR, "state_fips.csv"))
cat("Treatment coding saved:", nrow(privacy_laws), "treated states\n")

###############################################################################
# 2. BLS QCEW — Quarterly Census of Employment and Wages
###############################################################################

cat("\n=== Fetching BLS QCEW data ===\n")

# Strategy: Read from pre-downloaded cache (01a_fetch_qcew_fast.sh)
# or fetch via API if cache doesn't exist
if (file.exists(file.path(DATA_DIR, "qcew_raw.csv"))) {
  cat("QCEW raw data already exists, skipping fetch.\n")
  qcew_raw <- read_csv(file.path(DATA_DIR, "qcew_raw.csv"), show_col_types = FALSE)
  cat("QCEW data loaded:", nrow(qcew_raw), "rows\n")
} else {

industries <- c("10", "51", "5112", "5415", "52", "23", "44-45")
industry_names <- c("Total", "Information", "Software Publishers",
                     "Computer Systems Design", "Finance & Insurance",
                     "Construction", "Retail Trade")
naics_to_label <- setNames(industry_names, industries)
years <- 2015:2024
qcew_results <- list()

# Check for cached CSVs from parallel download
cache_dir <- file.path(DATA_DIR, "qcew_cache")
if (dir.exists(cache_dir) && length(list.files(cache_dir, pattern = "\\.csv$")) > 0) {
  cat("  Reading from cached CSVs...\n")
  csv_files <- list.files(cache_dir, pattern = "\\.csv$", full.names = TRUE)
  for (f in csv_files) {
    tryCatch({
      # Parse year, quarter, industry from filename: qcew_YYYY_qQ_NAICS.csv
      parts <- str_match(basename(f), "qcew_(\\d{4})_q(\\d)_(.*)\\.csv")
      yr <- as.integer(parts[2])
      qtr <- as.integer(parts[3])
      ind <- parts[4]
      ind_name <- naics_to_label[ind]
      if (is.na(ind_name)) next

      df <- read_csv(f, show_col_types = FALSE)
      if (nrow(df) == 0) next

      df_filtered <- df %>%
        filter(own_code == 5,
               agglvl_code %in% c(50, 51, 54, 55, 56, 57, 58, 74),
               grepl("^\\d{2}000$", area_fips)) %>%
        mutate(year = yr, quarter = qtr, industry = ind_name, naics = ind)

      if (nrow(df_filtered) > 0) {
        qcew_results[[length(qcew_results) + 1]] <- df_filtered
      }
    }, error = function(e) NULL)
  }
} else {
  # Fallback: fetch via API (slow, ~30 min)
  cat("  No cache found. Fetching via BLS QCEW API (this will take ~30 minutes)...\n")
  for (yr in years) {
    for (qtr in 1:4) {
      for (i in seq_along(industries)) {
        ind <- industries[i]
        ind_name <- industry_names[i]

        url <- sprintf("https://data.bls.gov/cew/data/api/%d/%d/industry/%s.csv",
                       yr, qtr, ind)

        tryCatch({
          resp <- GET(url, timeout(60))
          if (status_code(resp) == 200) {
            txt <- content(resp, as = "text", encoding = "UTF-8")
            if (nchar(txt) > 50) {
              df <- read_csv(txt, show_col_types = FALSE) %>%
                filter(own_code == 5,
                       agglvl_code %in% c(50, 51, 54, 55, 56, 57, 58, 74),
                       grepl("^\\d{2}000$", area_fips)) %>%
                mutate(year = yr, quarter = qtr, industry = ind_name, naics = ind)
              qcew_results[[length(qcew_results) + 1]] <- df
              if (qtr == 1 && i == 1) {
                cat("  QCEW", yr, "Q", qtr, ":", nrow(df), "rows\n")
              }
            }
          }
        }, error = function(e) NULL)

        Sys.sleep(0.15)
      }
    }
  }
}

if (length(qcew_results) > 0) {
  qcew_raw <- bind_rows(qcew_results)
  write_csv(qcew_raw, file.path(DATA_DIR, "qcew_raw.csv"))
  cat("QCEW data saved:", nrow(qcew_raw), "rows across",
      n_distinct(paste(qcew_raw$year, qcew_raw$quarter)), "year-quarters\n")
} else {
  stop("QCEW API returned no data. Check BLS API status.")
}
} # end QCEW fetch

###############################################################################
# 3. CENSUS BFS — Business Formation Statistics
###############################################################################

cat("\n=== Fetching Census BFS data ===\n")

if (file.exists(file.path(DATA_DIR, "bfs_monthly.csv"))) {
  cat("BFS data already exists, skipping fetch.\n")
  bfs_raw <- read_csv(file.path(DATA_DIR, "bfs_monthly.csv"), show_col_types = FALSE)
} else {

# BFS data tables: Business applications by state, monthly
# Available at: https://www.census.gov/data/tables/time-series/econ/bfs/business-formation-statistics.html

bfs_url <- "https://www2.census.gov/econ/bfs/data/bfs_monthly_state.csv"

tryCatch({
  bfs_raw <- read_csv(bfs_url, show_col_types = FALSE)
  write_csv(bfs_raw, file.path(DATA_DIR, "bfs_monthly.csv"))
  cat("BFS data saved:", nrow(bfs_raw), "rows,", ncol(bfs_raw), "columns\n")
  cat("  Columns:", paste(head(names(bfs_raw), 10), collapse = ", "), "...\n")
  cat("  Date range:", range(bfs_raw[[1]]), "\n")
}, error = function(e) {
  cat("BFS download failed:", e$message, "\n")
  cat("Trying alternative URL...\n")

  # Alternative: direct table download
  alt_url <- "https://www.census.gov/econ/bfs/csv/bfs_monthly.csv"
  tryCatch({
    bfs_raw <- read_csv(alt_url, show_col_types = FALSE)
    write_csv(bfs_raw, file.path(DATA_DIR, "bfs_monthly.csv"))
    cat("BFS data (alt) saved:", nrow(bfs_raw), "rows\n")
  }, error = function(e2) {
    cat("BFS alternative also failed:", e2$message, "\n")
  })
})
} # end BFS fetch else block

###############################################################################
# 4. BEA — State Quarterly GDP
###############################################################################

cat("\n=== Fetching BEA state GDP data ===\n")

bea_key <- Sys.getenv("BEA_API_KEY")
if (nchar(bea_key) > 0) {
  # BEA API for state GDP
  bea_url <- sprintf(
    "https://apps.bea.gov/api/data/?UserID=%s&method=GetData&datasetname=Regional&TableName=SQGDP2&LineCode=1&GeoFips=STATE&Year=ALL&ResultFormat=JSON",
    bea_key
  )

  tryCatch({
    resp <- GET(bea_url, timeout(60))
    bea_json <- content(resp, as = "parsed")

    if (!is.null(bea_json$BEAAPI$Results$Data)) {
      bea_data <- bea_json$BEAAPI$Results$Data %>%
        map_dfr(~tibble(
          geo_fips = .x$GeoFips,
          geo_name = .x$GeoName,
          time_period = .x$TimePeriod,
          data_value = as.numeric(.x$DataValue)
        ))
      write_csv(bea_data, file.path(DATA_DIR, "bea_state_gdp.csv"))
      cat("BEA GDP data saved:", nrow(bea_data), "rows\n")
    } else {
      cat("BEA API returned no data\n")
    }
  }, error = function(e) {
    cat("BEA fetch failed:", e$message, "\n")
  })
} else {
  cat("BEA_API_KEY not set. Fetching FRED state GDP instead...\n")

  # Alternative: Use FRED for state GDP (limited but accessible)
  fred_key <- Sys.getenv("FRED_API_KEY")
  if (nchar(fred_key) > 0) {
    # Fetch national GDP as control
    fred_url <- sprintf(
      "https://api.stlouisfed.org/fred/series/observations?series_id=GDP&api_key=%s&file_type=json&observation_start=2015-01-01",
      fred_key
    )
    tryCatch({
      resp <- GET(fred_url, timeout(30))
      fred_json <- content(resp, as = "parsed")
      if (!is.null(fred_json$observations)) {
        gdp_data <- fred_json$observations %>%
          map_dfr(~tibble(
            date = .x$date,
            value = as.numeric(.x$value)
          ))
        write_csv(gdp_data, file.path(DATA_DIR, "fred_national_gdp.csv"))
        cat("FRED national GDP saved:", nrow(gdp_data), "rows\n")
      }
    }, error = function(e) {
      cat("FRED GDP fetch failed:", e$message, "\n")
    })
  }
}

###############################################################################
# 5. IRS SOI — Interstate Migration Data
###############################################################################

cat("\n=== Fetching IRS SOI migration data ===\n")

# IRS SOI migration data: state-to-state flows by AGI bracket
# Available at: https://www.irs.gov/statistics/soi-tax-stats-migration-data
# We want state inflows/outflows for 2015-2022

# The IRS provides CSV files by year
irs_years <- 2015:2021  # Latest available

for (yr in irs_years) {
  # State inflow data
  yr_short <- yr %% 100
  yr_next <- (yr + 1) %% 100

  # Format: stateinflow[YRYY].csv  e.g., stateinflow1516.csv
  inflow_url <- sprintf(
    "https://www.irs.gov/pub/irs-soi/stateinflow%02d%02d.csv",
    yr_short, yr_next
  )

  outflow_url <- sprintf(
    "https://www.irs.gov/pub/irs-soi/stateoutflow%02d%02d.csv",
    yr_short, yr_next
  )

  inflow_path <- file.path(DATA_DIR, sprintf("irs_inflow_%d_%d.csv", yr, yr + 1))
  outflow_path <- file.path(DATA_DIR, sprintf("irs_outflow_%d_%d.csv", yr, yr + 1))

  if (!file.exists(inflow_path)) {
    tryCatch({
      download.file(inflow_url, inflow_path, mode = "wb", quiet = TRUE)
      cat("  IRS inflow", yr, "downloaded\n")
    }, error = function(e) {
      cat("  IRS inflow", yr, "failed:", e$message, "\n")
    })
  }

  if (!file.exists(outflow_path)) {
    tryCatch({
      download.file(outflow_url, outflow_path, mode = "wb", quiet = TRUE)
      cat("  IRS outflow", yr, "downloaded\n")
    }, error = function(e) {
      cat("  IRS outflow", yr, "failed:", e$message, "\n")
    })
  }

  Sys.sleep(0.5)
}

cat("\n=== Data acquisition complete ===\n")
cat("Files in data directory:\n")
cat(paste(" ", list.files(DATA_DIR), collapse = "\n"), "\n")
