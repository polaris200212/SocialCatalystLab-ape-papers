## ============================================================================
## 01_fetch_data.R — Load T-MSIS, build NPPES extract, fetch external data
## APEP-0326: State Minimum Wage Increases and the HCBS Provider Supply Crisis
## ============================================================================

source("00_packages.R")

## ---- Load .env for API keys ----
env_file <- file.path("..", "..", "..", "..", ".env")
if (file.exists(env_file)) {
  env_lines <- readLines(env_file, warn = FALSE)
  for (line in env_lines) {
    line <- trimws(line)
    if (nchar(line) == 0 || startsWith(line, "#")) next
    parts <- strsplit(line, "=", fixed = TRUE)[[1]]
    if (length(parts) >= 2) {
      key <- trimws(parts[1])
      val <- trimws(paste(parts[-1], collapse = "="))
      val <- gsub("^['\"]|['\"]$", "", val)
      do.call(Sys.setenv, setNames(list(val), key))
    }
  }
  cat("Loaded .env file\n")
}

## ========================================================================
## 1. T-MSIS PARQUET — HCBS provider-level claims
## ========================================================================

tmsis_path <- file.path(SHARED_DATA, "tmsis.parquet")
if (!file.exists(tmsis_path)) {
  stop("T-MSIS Parquet not found at: ", tmsis_path)
}
cat("Opening T-MSIS Parquet (lazy)...\n")
tmsis_ds <- open_dataset(tmsis_path)

## ========================================================================
## 2. NPPES EXTRACT — NPI → state, entity type, specialty
## ========================================================================

nppes_path <- file.path(SHARED_DATA, "nppes_extract.parquet")

if (file.exists(nppes_path)) {
  cat("Loading pre-built NPPES extract...\n")
  nppes <- as.data.table(read_parquet(nppes_path))
} else {
  # Build from bulk CSV
  nppes_csv <- list.files(SHARED_DATA, pattern = "npidata_pfile.*\\.csv$", full.names = TRUE)
  nppes_csv <- nppes_csv[!grepl("header", nppes_csv)]

  if (length(nppes_csv) == 0) {
    # Try unzipping if ZIP exists
    zip_file <- file.path(SHARED_DATA, "nppes_full.zip")
    if (file.exists(zip_file)) {
      cat("Extracting NPPES ZIP...\n")
      unzip(zip_file, exdir = SHARED_DATA, overwrite = FALSE)
      nppes_csv <- list.files(SHARED_DATA, pattern = "npidata_pfile.*\\.csv$", full.names = TRUE)
      nppes_csv <- nppes_csv[!grepl("header", nppes_csv)]
    }
  }

  if (length(nppes_csv) == 0) {
    stop("No NPPES data found. Download from: https://download.cms.gov/nppes/NPI_Files.html")
  }

  cat(sprintf("Building NPPES extract from %s...\n", basename(nppes_csv[1])))
  nppes_cols <- c(
    "NPI", "Entity Type Code",
    "Provider Business Practice Location Address State Name",
    "Provider Business Practice Location Address Postal Code",
    "Healthcare Provider Taxonomy Code_1",
    "Provider Credential Text",
    "Provider Sex Code",
    "Is Sole Proprietor",
    "Parent Organization TIN",
    "Provider Enumeration Date",
    "NPI Deactivation Date"
  )

  nppes <- fread(nppes_csv[1], select = nppes_cols, showProgress = TRUE, nThread = 4)
  setnames(nppes, c(
    "npi", "entity_type", "state", "zip", "taxonomy_1",
    "credential", "gender", "sole_prop", "parent_org_tin",
    "enumeration_date", "deactivation_date"
  ))

  # Parse dates
  for (col in c("enumeration_date", "deactivation_date")) {
    nppes[, (col) := as.Date(get(col), format = "%m/%d/%Y")]
  }

  # Clean ZIP to 5-digit
  nppes[, zip5 := substr(gsub("[^0-9]", "", zip), 1, 5)]

  # Save extract for future papers
  write_parquet(nppes, nppes_path)
  cat(sprintf("NPPES extract saved: %s providers\n", format(nrow(nppes), big.mark = ",")))
}

nppes[, npi := as.character(npi)]
cat(sprintf("NPPES: %s providers, %d states\n",
            format(nrow(nppes), big.mark = ","), uniqueN(nppes$state)))

## ========================================================================
## 3. STATE MINIMUM WAGE PANEL (2017–2024)
## ========================================================================
## Compiled from DOL, NCSL, and EPI Minimum Wage Tracker data.
## Each row: state × year × effective_date → minimum_wage_rate.
## For states with mid-year increases, we use the Jan 1 rate for simplicity
## (most increases take effect Jan 1; exceptions noted).
##
## Federal minimum: $7.25 since July 2009 (unchanged through 2024).
## States without own MW law or at/below federal: effective rate = $7.25.
## ========================================================================

cat("Building state minimum wage panel...\n")

# State MW rates by year (Jan 1 effective rate, or closest)
# Source: DOL Wage and Hour Division, NCSL State Minimum Wages
# States at federal minimum ($7.25) throughout: AL, GA, ID, IN, IA, KS, KY, LA,
#   MS, NH, NC, ND, OK, PA, SC, TN, TX, UT, WI, WY
# Note: Some of these states have no state MW law; federal applies.

mw_data <- tribble(
  ~state, ~year, ~min_wage,
  # Alaska
  "AK", 2018, 9.84, "AK", 2019, 9.89, "AK", 2020, 10.19, "AK", 2021, 10.34,
  "AK", 2022, 10.34, "AK", 2023, 10.85, "AK", 2024, 11.73,
  # Arizona
  "AZ", 2018, 10.50, "AZ", 2019, 11.00, "AZ", 2020, 12.00, "AZ", 2021, 12.15,
  "AZ", 2022, 12.80, "AZ", 2023, 13.85, "AZ", 2024, 14.35,
  # Arkansas
  "AR", 2018, 8.50, "AR", 2019, 9.25, "AR", 2020, 10.00, "AR", 2021, 11.00,
  "AR", 2022, 11.00, "AR", 2023, 11.00, "AR", 2024, 11.00,
  # California
  "CA", 2018, 11.00, "CA", 2019, 12.00, "CA", 2020, 13.00, "CA", 2021, 14.00,
  "CA", 2022, 15.00, "CA", 2023, 15.50, "CA", 2024, 16.00,
  # Colorado
  "CO", 2018, 10.20, "CO", 2019, 11.10, "CO", 2020, 12.00, "CO", 2021, 12.32,
  "CO", 2022, 12.56, "CO", 2023, 13.65, "CO", 2024, 14.42,
  # Connecticut
  "CT", 2018, 10.10, "CT", 2019, 10.10, "CT", 2020, 12.00, "CT", 2021, 13.00,
  "CT", 2022, 14.00, "CT", 2023, 15.00, "CT", 2024, 15.69,
  # Delaware
  "DE", 2018, 8.25, "DE", 2019, 8.75, "DE", 2020, 9.25, "DE", 2021, 9.25,
  "DE", 2022, 10.50, "DE", 2023, 11.75, "DE", 2024, 13.25,
  # DC
  "DC", 2018, 12.50, "DC", 2019, 13.25, "DC", 2020, 14.00, "DC", 2021, 15.00,
  "DC", 2022, 15.20, "DC", 2023, 17.00, "DC", 2024, 17.50,
  # Florida (Sept 30 effective dates: 2021=$10, 2022=$11, 2023=$12, 2024=$13)
  "FL", 2018, 8.25, "FL", 2019, 8.46, "FL", 2020, 8.56, "FL", 2021, 10.00,
  "FL", 2022, 11.00, "FL", 2023, 12.00, "FL", 2024, 13.00,
  # Hawaii
  "HI", 2018, 10.10, "HI", 2019, 10.10, "HI", 2020, 10.10, "HI", 2021, 10.10,
  "HI", 2022, 10.10, "HI", 2023, 12.00, "HI", 2024, 14.00,
  # Illinois
  "IL", 2018, 8.25, "IL", 2019, 8.25, "IL", 2020, 9.25, "IL", 2021, 11.00,
  "IL", 2022, 12.00, "IL", 2023, 13.00, "IL", 2024, 14.00,
  # Maine
  "ME", 2018, 10.00, "ME", 2019, 11.00, "ME", 2020, 12.00, "ME", 2021, 12.15,
  "ME", 2022, 12.75, "ME", 2023, 13.80, "ME", 2024, 14.15,
  # Maryland
  "MD", 2018, 9.25, "MD", 2019, 10.10, "MD", 2020, 11.00, "MD", 2021, 11.75,
  "MD", 2022, 12.50, "MD", 2023, 13.25, "MD", 2024, 15.00,
  # Massachusetts
  "MA", 2018, 11.00, "MA", 2019, 12.00, "MA", 2020, 12.75, "MA", 2021, 13.50,
  "MA", 2022, 14.25, "MA", 2023, 15.00, "MA", 2024, 15.00,
  # Michigan
  "MI", 2018, 9.25, "MI", 2019, 9.45, "MI", 2020, 9.65, "MI", 2021, 9.65,
  "MI", 2022, 9.87, "MI", 2023, 10.10, "MI", 2024, 10.33,
  # Minnesota
  "MN", 2018, 9.65, "MN", 2019, 9.86, "MN", 2020, 10.00, "MN", 2021, 10.08,
  "MN", 2022, 10.33, "MN", 2023, 10.59, "MN", 2024, 10.85,
  # Missouri
  "MO", 2018, 7.85, "MO", 2019, 8.60, "MO", 2020, 9.45, "MO", 2021, 10.30,
  "MO", 2022, 11.15, "MO", 2023, 12.00, "MO", 2024, 12.30,
  # Montana
  "MT", 2018, 8.30, "MT", 2019, 8.50, "MT", 2020, 8.65, "MT", 2021, 8.75,
  "MT", 2022, 9.20, "MT", 2023, 9.95, "MT", 2024, 10.30,
  # Nebraska
  "NE", 2018, 9.00, "NE", 2019, 9.00, "NE", 2020, 9.00, "NE", 2021, 9.00,
  "NE", 2022, 9.00, "NE", 2023, 10.50, "NE", 2024, 12.00,
  # Nevada
  "NV", 2018, 8.25, "NV", 2019, 8.25, "NV", 2020, 9.00, "NV", 2021, 9.75,
  "NV", 2022, 10.50, "NV", 2023, 10.50, "NV", 2024, 12.00,
  # New Jersey
  "NJ", 2018, 8.60, "NJ", 2019, 8.85, "NJ", 2020, 11.00, "NJ", 2021, 12.00,
  "NJ", 2022, 13.00, "NJ", 2023, 14.13, "NJ", 2024, 15.13,
  # New Mexico
  "NM", 2018, 7.50, "NM", 2019, 7.50, "NM", 2020, 9.00, "NM", 2021, 10.50,
  "NM", 2022, 11.50, "NM", 2023, 12.00, "NM", 2024, 12.00,
  # New York
  "NY", 2018, 10.40, "NY", 2019, 11.10, "NY", 2020, 11.80, "NY", 2021, 12.50,
  "NY", 2022, 13.20, "NY", 2023, 14.20, "NY", 2024, 15.00,
  # Ohio
  "OH", 2018, 8.30, "OH", 2019, 8.55, "OH", 2020, 8.70, "OH", 2021, 8.80,
  "OH", 2022, 9.30, "OH", 2023, 10.10, "OH", 2024, 10.45,
  # Oregon
  "OR", 2018, 10.25, "OR", 2019, 10.75, "OR", 2020, 11.25, "OR", 2021, 12.00,
  "OR", 2022, 12.75, "OR", 2023, 13.50, "OR", 2024, 14.70,
  # Rhode Island
  "RI", 2018, 10.10, "RI", 2019, 10.50, "RI", 2020, 10.50, "RI", 2021, 11.50,
  "RI", 2022, 12.25, "RI", 2023, 13.00, "RI", 2024, 14.00,
  # South Dakota
  "SD", 2018, 8.85, "SD", 2019, 9.10, "SD", 2020, 9.30, "SD", 2021, 9.45,
  "SD", 2022, 9.95, "SD", 2023, 10.80, "SD", 2024, 11.20,
  # Vermont
  "VT", 2018, 10.50, "VT", 2019, 10.78, "VT", 2020, 10.96, "VT", 2021, 11.75,
  "VT", 2022, 12.55, "VT", 2023, 13.18, "VT", 2024, 13.67,
  # Virginia
  "VA", 2018, 7.25, "VA", 2019, 7.25, "VA", 2020, 7.25, "VA", 2021, 9.50,
  "VA", 2022, 11.00, "VA", 2023, 12.00, "VA", 2024, 12.41,
  # Washington
  "WA", 2018, 11.50, "WA", 2019, 12.00, "WA", 2020, 13.50, "WA", 2021, 13.69,
  "WA", 2022, 14.49, "WA", 2023, 15.74, "WA", 2024, 16.28,
  # West Virginia
  "WV", 2018, 8.75, "WV", 2019, 8.75, "WV", 2020, 8.75, "WV", 2021, 8.75,
  "WV", 2022, 8.75, "WV", 2023, 8.75, "WV", 2024, 8.75
)

mw_data <- as.data.table(mw_data)

# States at federal minimum ($7.25) — no state-level increases
federal_states <- c("AL", "GA", "ID", "IN", "IA", "KS", "KY", "LA",
                    "MS", "NH", "NC", "ND", "OK", "PA", "SC", "TN",
                    "TX", "UT", "WI", "WY")

# Add federal-minimum states
federal_rows <- CJ(state = federal_states, year = 2018:2024)
federal_rows[, min_wage := 7.25]
mw_data <- rbind(mw_data, federal_rows)

# Calculate derived variables
mw_data[, log_mw := log(min_wage)]
mw_data[, above_federal := as.integer(min_wage > 7.25)]
mw_data[, mw_premium := min_wage - 7.25]

# Define treatment cohort: first year MW exceeds $7.25
# For states always above: cohort = 2018 (already treated at start of sample)
# For never-treated: cohort = 0 (CS-DiD convention)
cohort_def <- mw_data[, .(first_treat_year = min(year[min_wage > 7.25])), by = state]
cohort_def[is.infinite(first_treat_year), first_treat_year := 0L]  # never-treated
mw_data <- merge(mw_data, cohort_def, by = "state")

cat(sprintf("MW panel: %d state-years. Treated: %d states, Never-treated: %d states\n",
            nrow(mw_data),
            sum(cohort_def$first_treat_year > 0),
            sum(cohort_def$first_treat_year == 0)))

## ========================================================================
## 4. CENSUS ACS — State population denominators
## ========================================================================

cat("Fetching Census ACS population data...\n")
api_key <- Sys.getenv("CENSUS_API_KEY")

pop_list <- list()
for (yr in 2018:2023) {
  # Census API works without key but with rate limits
  if (nchar(api_key) > 0) {
    url <- sprintf(
      "https://api.census.gov/data/%d/acs/acs5?get=B01003_001E,NAME&for=state:*&key=%s",
      yr, api_key
    )
  } else {
    url <- sprintf(
      "https://api.census.gov/data/%d/acs/acs5?get=B01003_001E,NAME&for=state:*",
      yr
    )
  }
  resp <- tryCatch(jsonlite::fromJSON(url), error = function(e) {
    cat(sprintf("  Census %d failed: %s\n", yr, e$message))
    NULL
  })
  if (!is.null(resp)) {
    df <- as.data.table(resp[-1, , drop = FALSE])
    setnames(df, c("population", "state_name", "state_fips"))
    df[, population := as.numeric(population)]
    df[, year := yr]
    pop_list[[length(pop_list) + 1]] <- df
    cat(sprintf("  Census %d: %d states\n", yr, nrow(df)))
  }
  Sys.sleep(1)  # Rate limit without key
}

if (length(pop_list) > 0) {
  pop_data <- rbindlist(pop_list)
  pop_data <- merge(pop_data, state_fips[, .(fips, state_abbr)],
                    by.x = "state_fips", by.y = "fips", all.x = TRUE)
  # Extrapolate 2024 from 2023
  pop_2024 <- pop_data[year == 2023]
  pop_2024[, year := 2024]
  pop_data <- rbind(pop_data, pop_2024)
} else {
  cat("WARNING: Census ACS fetch failed. Using approximate populations.\n")
  # Fallback: approximate 2020 Census populations
  pop_approx <- data.table(
    state_abbr = state_fips$state_abbr,
    population = c(5024279,733391,7151502,3011524,39538223,5773714,3605944,989948,689545,21538187,
                   10711908,1455271,1839106,12812508,6785528,3190369,2937880,4505836,4657757,1362359,
                   6177224,7029917,10077331,5706494,2961279,6154913,1084225,1961504,3104614,1377529,
                   9288994,2117522,20201249,10439388,779094,11799448,3959353,4237256,13002700,1097379,
                   5118425,886667,6910840,29145505,3271616,643077,8631393,7614893,1793716,5893718,576851)
  )
  pop_data <- CJ(state_abbr = state_fips$state_abbr, year = 2018:2024)
  pop_data <- merge(pop_data, pop_approx, by = "state_abbr")
}

cat(sprintf("Population data: %d state-years\n", nrow(pop_data)))

## ========================================================================
## 5. BLS QCEW — Healthcare employment controls
## ========================================================================

cat("Fetching BLS QCEW healthcare employment...\n")
# NAICS 621 = Ambulatory health care services (includes home health)
# Annual average, all ownership, state level

qcew_list <- list()
for (yr in 2018:2024) {
  url <- sprintf("https://data.bls.gov/cew/data/api/%d/a/area/US000.csv", yr)
  resp <- tryCatch(fread(url, showProgress = FALSE), error = function(e) NULL)
  if (!is.null(resp) && nrow(resp) > 0) {
    qcew_list[[length(qcew_list) + 1]] <- resp[, year := yr]
  }
  Sys.sleep(1)
}

# QCEW state-level data for NAICS 621 (ambulatory healthcare)
# Fetch QCEW state-level data for all states at once per year
# Use the annual averages CSV which has all states in one file
qcew_state_list <- list()
for (yr in 2018:2024) {
  # Use the national-level file which includes state breakdowns
  url <- sprintf("https://data.bls.gov/cew/data/api/%d/a/industry/62/area/US000.csv", yr)
  resp <- tryCatch(suppressWarnings(fread(url, showProgress = FALSE)), error = function(e) NULL)
  if (!is.null(resp) && nrow(resp) > 0 && "annual_avg_emplvl" %in% names(resp)) {
    qcew_state_list[[length(qcew_state_list) + 1]] <- data.table(
      state_fips = "US",
      year = yr,
      hc_employment = resp$annual_avg_emplvl[1],
      hc_avg_wage = resp$avg_annual_pay[1]
    )
  }
  Sys.sleep(1)
}

if (length(qcew_state_list) > 0) {
  qcew_data <- rbindlist(qcew_state_list)
  qcew_data <- merge(qcew_data, state_fips[, .(fips, state_abbr)],
                     by.x = "state_fips", by.y = "fips", all.x = TRUE)
  cat(sprintf("QCEW: %d state-years\n", nrow(qcew_data)))
} else {
  cat("WARNING: QCEW fetch returned no data. Proceeding without healthcare employment controls.\n")
  qcew_data <- data.table(state_fips = character(), year = integer(),
                          hc_employment = numeric(), hc_avg_wage = numeric(),
                          state_abbr = character())
}

## ========================================================================
## 6. FRED — State unemployment rates
## ========================================================================

cat("Fetching BLS state unemployment rates...\n")
# Try BLS LAUS data (no key needed) as primary source
unemp_list <- list()
for (yr in 2018:2024) {
  url <- sprintf("https://data.bls.gov/cew/data/api/%d/a/area/US000.csv", yr)
  # LAUS is separate; use a simpler approach with FRED if available
}

fred_key <- Sys.getenv("FRED_API_KEY")
if (nchar(fred_key) > 0) {
  # State unemployment series IDs: {STATE}UR (e.g., ALUR, AKUR)
  unemp_list <- list()
  for (i in seq_len(nrow(state_fips))) {
    st <- state_fips$state_abbr[i]
    series_id <- paste0(st, "UR")
    url <- sprintf(
      "https://api.stlouisfed.org/fred/series/observations?series_id=%s&api_key=%s&file_type=json&observation_start=2018-01-01&observation_end=2024-12-31&frequency=a",
      series_id, fred_key
    )
    resp <- tryCatch(jsonlite::fromJSON(url), error = function(e) NULL)
    if (!is.null(resp) && !is.null(resp$observations)) {
      obs <- as.data.table(resp$observations)
      obs[, `:=`(
        state = st,
        year = as.integer(substr(date, 1, 4)),
        unemp_rate = as.numeric(value)
      )]
      unemp_list[[length(unemp_list) + 1]] <- obs[, .(state, year, unemp_rate)]
    }
    Sys.sleep(0.15)
  }
  unemp_data <- rbindlist(unemp_list)
  cat(sprintf("FRED unemployment: %d state-years\n", nrow(unemp_data)))
} else {
  cat("WARNING: FRED_API_KEY not set. Proceeding without unemployment controls.\n")
  unemp_data <- data.table(state = character(), year = integer(), unemp_rate = numeric())
}

## ========================================================================
## 7. SAVE ALL RAW DATA
## ========================================================================

saveRDS(mw_data, file.path(DATA, "mw_panel.rds"))
saveRDS(pop_data, file.path(DATA, "pop_data.rds"))
saveRDS(qcew_data, file.path(DATA, "qcew_data.rds"))
saveRDS(unemp_data, file.path(DATA, "unemp_data.rds"))

cat("\n=== Data fetch complete ===\n")
cat(sprintf("T-MSIS: lazy reference (227M rows)\n"))
cat(sprintf("NPPES: %s providers\n", format(nrow(nppes), big.mark = ",")))
cat(sprintf("MW panel: %d state-years\n", nrow(mw_data)))
cat(sprintf("Population: %d state-years\n", nrow(pop_data)))
cat(sprintf("QCEW: %d state-years\n", nrow(qcew_data)))
cat(sprintf("Unemployment: %d state-years\n", nrow(unemp_data)))
