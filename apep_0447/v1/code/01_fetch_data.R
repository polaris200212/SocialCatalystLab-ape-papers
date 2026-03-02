## ============================================================================
## 01_fetch_data.R — Load T-MSIS, NPPES, OxCGRT, and auxiliary data
## Paper: Lockdowns and the Collapse of In-Person Medicaid Care
## ============================================================================

source("00_packages.R")

# Load .env for API keys
env_file <- file.path("..", "..", "..", "..", ".env")
if (file.exists(env_file)) {
  env_lines <- readLines(env_file, warn = FALSE)
  env_lines <- env_lines[!grepl("^#|^$", env_lines)]
  for (line in env_lines) {
    parts <- strsplit(line, "=", fixed = TRUE)[[1]]
    if (length(parts) >= 2) {
      key <- trimws(parts[1])
      val <- trimws(paste(parts[-1], collapse = "="))
      val <- gsub('^["\']|["\']$', '', val)
      do.call(Sys.setenv, setNames(list(val), key))
    }
  }
  cat("Loaded .env file\n")
}

## ---- Paths ----
SHARED_DATA <- file.path("..", "..", "..", "..", "data", "medicaid_provider_spending")
DATA <- "../data"
dir.create(DATA, showWarnings = FALSE, recursive = TRUE)

## ---- 1. Open T-MSIS (lazy via Arrow) ----
tmsis_path <- file.path(SHARED_DATA, "tmsis.parquet")
if (!file.exists(tmsis_path)) {
  stop("T-MSIS Parquet not found at: ", tmsis_path)
}
cat("Opening T-MSIS Parquet (lazy)...\n")
tmsis_ds <- open_dataset(tmsis_path)

## ---- 2. Load NPPES extract ----
nppes_path <- file.path(SHARED_DATA, "nppes_extract.parquet")
if (!file.exists(nppes_path)) {
  stop("NPPES extract not found at: ", nppes_path,
       "\nRun the overview paper's data pipeline first.")
}
cat("Loading NPPES extract...\n")
nppes <- as.data.table(read_parquet(nppes_path))
nppes[, npi := as.character(npi)]
cat(sprintf("NPPES: %s providers\n", format(nrow(nppes), big.mark = ",")))

# NPI -> state mapping (practice state)
npi_state <- nppes[!is.na(state) & state != "" & nchar(state) == 2,
                   .(npi, state)]
# Keep only US states + DC (exclude territories for cleaner analysis)
us_states <- c(state.abb, "DC")
npi_state <- npi_state[state %in% us_states]
cat(sprintf("NPI-state mapping: %s NPIs in %d states\n",
            format(nrow(npi_state), big.mark = ","),
            uniqueN(npi_state$state)))

## ---- 3. Build state × service-type × month panel from T-MSIS ----
cat("Building state × service-type × month panel via Arrow...\n")

# Classify HCPCS codes into service types via Arrow
# T-codes = HCBS (in-person), H-codes = Behavioral Health (telehealth-eligible)
provider_monthly <- tmsis_ds |>
  mutate(
    hcpcs_prefix = substr(HCPCS_CODE, 1, 1),
    service_type = case_when(
      hcpcs_prefix == "T" ~ "HCBS",
      hcpcs_prefix == "H" ~ "BH",
      TRUE ~ NA_character_
    ),
    year = as.integer(substr(CLAIM_FROM_MONTH, 1, 4)),
    month_num = as.integer(substr(CLAIM_FROM_MONTH, 6, 7))
  ) |>
  # Keep only HCBS and BH services

  filter(!is.na(service_type)) |>
  group_by(BILLING_PROVIDER_NPI_NUM, CLAIM_FROM_MONTH, year, month_num, service_type) |>
  summarize(
    total_paid = sum(TOTAL_PAID, na.rm = TRUE),
    total_claims = sum(TOTAL_CLAIMS, na.rm = TRUE),
    total_beneficiaries = sum(TOTAL_UNIQUE_BENEFICIARIES, na.rm = TRUE),
    .groups = "drop"
  ) |>
  collect() |>
  as.data.table()

setnames(provider_monthly, "BILLING_PROVIDER_NPI_NUM", "billing_npi")
cat(sprintf("Provider-monthly panel: %s rows\n",
            format(nrow(provider_monthly), big.mark = ",")))

# Join state from NPPES
provider_monthly <- merge(provider_monthly, npi_state,
                          by.x = "billing_npi", by.y = "npi",
                          all.x = FALSE)  # inner join, drop unmatched

cat(sprintf("After state join: %s rows (%s unique NPIs)\n",
            format(nrow(provider_monthly), big.mark = ","),
            format(uniqueN(provider_monthly$billing_npi), big.mark = ",")))

# Collapse to state × service_type × month
panel <- provider_monthly[, .(
  total_paid = sum(total_paid),
  total_claims = sum(total_claims),
  total_beneficiaries = sum(total_beneficiaries),
  n_providers = uniqueN(billing_npi)
), by = .(state, service_type, year, month_num, CLAIM_FROM_MONTH)]

panel[, month_date := as.Date(paste0(CLAIM_FROM_MONTH, "-01"))]
setorder(panel, state, service_type, month_date)

cat(sprintf("State × service × month panel: %d rows (%d states, %d service types, %d months)\n",
            nrow(panel),
            uniqueN(panel$state),
            uniqueN(panel$service_type),
            uniqueN(panel$month_date)))

# Clean up
rm(provider_monthly)
gc()

## ---- 4. Download Oxford COVID-19 Government Response Tracker (state-level) ----
cat("\nDownloading OxCGRT US state-level data...\n")
oxcgrt_url <- "https://raw.githubusercontent.com/OxCGRT/USA-covid-policy/master/data/OxCGRT_US_latest.csv"

oxcgrt_file <- file.path(DATA, "oxcgrt_us.csv")
if (!file.exists(oxcgrt_file)) {
  download.file(oxcgrt_url, oxcgrt_file, quiet = TRUE)
}

# Read and filter to state-level
oxcgrt_raw <- fread(oxcgrt_file, showProgress = FALSE)
oxcgrt <- oxcgrt_raw[Jurisdiction == "STATE_WIDE"]

# Parse date and extract state abbreviation
oxcgrt[, date := as.Date(as.character(Date), format = "%Y%m%d")]
oxcgrt[, state_abbr := gsub("US_", "", RegionCode)]

# Keep stringency index and key indicators
oxcgrt_clean <- oxcgrt[, .(
  state = state_abbr,
  date,
  stringency = as.numeric(StringencyIndex),
  c6_stay_home = as.numeric(`C6_Stay at home requirements`),
  c2_workplace = as.numeric(`C2_Workplace closing`)
)]

# Remove rows with missing stringency
oxcgrt_clean <- oxcgrt_clean[!is.na(stringency)]

cat(sprintf("OxCGRT: %s state-day observations, %d states, %s to %s\n",
            format(nrow(oxcgrt_clean), big.mark = ","),
            uniqueN(oxcgrt_clean$state),
            min(oxcgrt_clean$date),
            max(oxcgrt_clean$date)))

# Create monthly state-level stringency measures
oxcgrt_clean[, `:=`(
  year = year(date),
  month_num = month(date)
)]

# Monthly average stringency
stringency_monthly <- oxcgrt_clean[, .(
  stringency_avg = mean(stringency, na.rm = TRUE),
  stringency_max = max(stringency, na.rm = TRUE),
  c6_stay_home_avg = mean(c6_stay_home, na.rm = TRUE),
  c2_workplace_avg = mean(c2_workplace, na.rm = TRUE)
), by = .(state, year, month_num)]

# Peak stringency (April 2020) for cross-state treatment intensity
peak_stringency <- oxcgrt_clean[year == 2020 & month_num == 4,
                                .(peak_stringency = mean(stringency, na.rm = TRUE)),
                                by = state]

# Cumulative stringency (March-June 2020)
cum_stringency <- oxcgrt_clean[year == 2020 & month_num %in% 3:6,
                               .(cum_stringency = sum(stringency, na.rm = TRUE) / .N),
                               by = state]

# Merge peak and cumulative
state_treatment <- merge(peak_stringency, cum_stringency, by = "state", all = TRUE)

cat(sprintf("State treatment measures: %d states\n", nrow(state_treatment)))
cat(sprintf("Peak stringency range: %.1f to %.1f (mean: %.1f)\n",
            min(state_treatment$peak_stringency, na.rm = TRUE),
            max(state_treatment$peak_stringency, na.rm = TRUE),
            mean(state_treatment$peak_stringency, na.rm = TRUE)))

## ---- 5. Stay-at-Home classification from OxCGRT C6 ----
cat("\nClassifying stay-at-home orders from OxCGRT C6 indicator...\n")

# C6_Stay at home requirements: 0=no measures, 1=recommend, 2=require (exceptions), 3=require (minimal exceptions)
# Identify first month where C6 >= 2 (required) for each state
sah_from_oxcgrt <- oxcgrt_clean[c6_stay_home >= 2, .(first_sah_date = min(date)), by = state]

cat(sprintf("States with mandatory stay-at-home (C6 >= 2): %d\n", nrow(sah_from_oxcgrt)))

# Merge into treatment data
state_treatment <- merge(state_treatment, sah_from_oxcgrt, by = "state", all.x = TRUE)
state_treatment[is.na(first_sah_date), never_treated := TRUE]
state_treatment[is.na(never_treated), never_treated := FALSE]

cat(sprintf("Never-treated states (no mandatory SAH): %d\n",
            sum(state_treatment$never_treated)))
cat(sprintf("Never-treated: %s\n",
            paste(state_treatment[never_treated == TRUE]$state, collapse = ", ")))

## ---- 6. Census ACS population denominators ----
cat("\nFetching Census ACS state population data...\n")
census_key <- Sys.getenv("CENSUS_API_KEY")

if (nchar(census_key) > 0) {
  # Get state population for 2019 (pre-COVID baseline)
  acs_url <- sprintf(
    "https://api.census.gov/data/2019/acs/acs5?get=B01003_001E,B27007_004E,B27007_007E,B27007_010E,NAME&for=state:*&key=%s",
    census_key
  )
  acs_resp <- GET(acs_url)
  if (status_code(acs_resp) == 200) {
    acs_raw <- fromJSON(content(acs_resp, as = "text", encoding = "UTF-8"))
    acs_dt <- as.data.table(acs_raw[-1, ])  # Remove header row
    setnames(acs_dt, c("pop_total", "medicaid_19_25", "medicaid_26_34",
                       "medicaid_35_44", "state_name", "state_fips"))
    acs_dt[, pop_total := as.numeric(pop_total)]
    acs_dt[, medicaid_est := as.numeric(medicaid_19_25) +
             as.numeric(medicaid_26_34) + as.numeric(medicaid_35_44)]

    # Map FIPS to abbreviation
    fips_map <- data.table(
      state_fips = sprintf("%02d", c(1,2,4,5,6,8,9,10,11,12,13,15,16,17,18,19,
                                     20,21,22,23,24,25,26,27,28,29,30,31,32,33,
                                     34,35,36,37,38,39,40,41,42,44,45,46,47,48,
                                     49,50,51,53,54,55,56)),
      state = c("AL","AK","AZ","AR","CA","CO","CT","DE","DC","FL","GA","HI",
                "ID","IL","IN","IA","KS","KY","LA","ME","MD","MA","MI","MN",
                "MS","MO","MT","NE","NV","NH","NJ","NM","NY","NC","ND","OH",
                "OK","OR","PA","RI","SC","SD","TN","TX","UT","VT","VA","WA",
                "WV","WI","WY")
    )
    acs_dt <- merge(acs_dt, fips_map, by = "state_fips", all.x = TRUE)
    state_pop <- acs_dt[!is.na(state), .(state, pop_total, state_name)]
    cat(sprintf("Census ACS: %d states with population data\n", nrow(state_pop)))
  } else {
    cat("WARNING: Census API returned non-200 status\n")
    state_pop <- NULL
  }
} else {
  cat("WARNING: No CENSUS_API_KEY found.\n")
  state_pop <- NULL
}

## ---- 7. FRED state unemployment ----
cat("\nFetching FRED state unemployment data...\n")
fred_key <- Sys.getenv("FRED_API_KEY")

if (nchar(fred_key) > 0) {
  # Fetch monthly unemployment for all states (2018-2024)
  fred_series <- paste0(c("AL","AK","AZ","AR","CA","CO","CT","DE","DC","FL",
                           "GA","HI","ID","IL","IN","IA","KS","KY","LA","ME",
                           "MD","MA","MI","MN","MS","MO","MT","NE","NV","NH",
                           "NJ","NM","NY","NC","ND","OH","OK","OR","PA","RI",
                           "SC","SD","TN","TX","UT","VT","VA","WA","WV","WI","WY"), "UR")

  unemp_list <- list()
  for (ser in fred_series) {
    url <- sprintf(
      "https://api.stlouisfed.org/fred/series/observations?series_id=%s&observation_start=2018-01-01&observation_end=2024-12-31&api_key=%s&file_type=json",
      ser, fred_key
    )
    resp <- GET(url)
    if (status_code(resp) == 200) {
      obs <- fromJSON(content(resp, as = "text", encoding = "UTF-8"))$observations
      if (!is.null(obs) && nrow(obs) > 0) {
        unemp_list[[ser]] <- data.table(
          state = gsub("UR$", "", ser),
          date = as.Date(obs$date),
          unemp_rate = as.numeric(obs$value)
        )
      }
    }
    Sys.sleep(0.1)  # Rate limit
  }
  unemp_dt <- rbindlist(unemp_list)
  unemp_dt[, `:=`(year = year(date), month_num = month(date))]
  cat(sprintf("FRED unemployment: %s observations, %d states\n",
              format(nrow(unemp_dt), big.mark = ","),
              uniqueN(unemp_dt$state)))
} else {
  cat("WARNING: No FRED_API_KEY found.\n")
  unemp_dt <- NULL
}

## ---- 8. Merge all data into analysis panel ----
cat("\nMerging all data sources...\n")

# Merge treatment intensity into main panel
panel <- merge(panel, state_treatment, by = "state", all.x = TRUE)

# Merge monthly stringency
panel <- merge(panel, stringency_monthly,
               by = c("state", "year", "month_num"), all.x = TRUE)
# Pre-COVID months have no stringency — set to 0
panel[is.na(stringency_avg), stringency_avg := 0]
panel[is.na(stringency_max), stringency_max := 0]

# Merge population (for per-capita outcomes)
if (!is.null(state_pop)) {
  panel <- merge(panel, state_pop[, .(state, pop_total)], by = "state", all.x = TRUE)
}

# Merge unemployment
if (!is.null(unemp_dt)) {
  panel <- merge(panel, unemp_dt[, .(state, year, month_num, unemp_rate)],
                 by = c("state", "year", "month_num"), all.x = TRUE)
}

# Create key variables
panel[, `:=`(
  # Time indicators
  post = as.integer(month_date >= as.Date("2020-04-01")),
  is_hcbs = as.integer(service_type == "HCBS"),

  # Log outcomes (adding 1 for zeros)
  log_paid = log(total_paid + 1),
  log_claims = log(total_claims + 1),
  log_providers = log(n_providers + 1),
  log_beneficiaries = log(total_beneficiaries + 1),


  # Month counter (for trends)
  month_id = as.integer(factor(month_date)),

  # Standardize stringency (0-1)
  peak_stringency_std = peak_stringency / 100,
  cum_stringency_std = cum_stringency / 100,

  # Stringency quartile
  stringency_q = cut(peak_stringency,
                     breaks = quantile(peak_stringency, probs = c(0, 0.25, 0.5, 0.75, 1), na.rm = TRUE),
                     include.lowest = TRUE, labels = c("Q1 (Low)", "Q2", "Q3", "Q4 (High)"))
)]

# Per-capita outcomes (only if pop_total was merged)
if ("pop_total" %in% names(panel)) {
  panel[, paid_pc := fifelse(!is.na(pop_total) & pop_total > 0,
                             total_paid / pop_total * 100000, NA_real_)]
}

# Create state-service fixed effects
panel[, state_service := paste(state, service_type, sep = "_")]

# Create time period indicators for event study
panel[, `:=`(
  period = fcase(
    month_date < as.Date("2020-03-01"), "Pre-COVID",
    month_date >= as.Date("2020-03-01") & month_date < as.Date("2020-04-01"), "March 2020 (partial)",
    month_date >= as.Date("2020-04-01") & month_date < as.Date("2020-07-01"), "Lockdown (Apr-Jun 2020)",
    month_date >= as.Date("2020-07-01") & month_date < as.Date("2021-01-01"), "Recovery (Jul-Dec 2020)",
    month_date >= as.Date("2021-01-01") & month_date < as.Date("2022-01-01"), "Post-Lockdown (2021)",
    month_date >= as.Date("2022-01-01") & month_date < as.Date("2023-01-01"), "Post-Lockdown (2022)",
    month_date >= as.Date("2023-01-01"), "Post-Lockdown (2023-24)"
  )
)]

# Drop March 2020 (partial exposure)
panel_analysis <- panel[month_date != as.Date("2020-03-01")]

# Drop Oct-Dec 2024 (T-MSIS reporting lags — claims not yet fully adjudicated)
panel_analysis <- panel_analysis[month_date < as.Date("2024-10-01")]
cat(sprintf("Dropped Oct-Dec 2024 due to T-MSIS reporting lags\n"))

cat(sprintf("\n=== Final analysis panel ===\n"))
cat(sprintf("Total rows: %s\n", format(nrow(panel_analysis), big.mark = ",")))
cat(sprintf("States: %d\n", uniqueN(panel_analysis$state)))
cat(sprintf("Service types: %s\n", paste(unique(panel_analysis$service_type), collapse = ", ")))
cat(sprintf("Date range: %s to %s\n", min(panel_analysis$month_date), max(panel_analysis$month_date)))
cat(sprintf("Pre-period months: %d\n", uniqueN(panel_analysis[post == 0]$month_date)))
cat(sprintf("Post-period months: %d\n", uniqueN(panel_analysis[post == 1]$month_date)))

## ---- 9. Save ----
saveRDS(panel, file.path(DATA, "panel_full.rds"))
saveRDS(panel_analysis, file.path(DATA, "panel_analysis.rds"))
saveRDS(state_treatment, file.path(DATA, "state_treatment.rds"))
saveRDS(stringency_monthly, file.path(DATA, "stringency_monthly.rds"))
if (!is.null(state_pop)) saveRDS(state_pop, file.path(DATA, "state_pop.rds"))
if (!is.null(unemp_dt)) saveRDS(unemp_dt, file.path(DATA, "unemp_dt.rds"))

cat("\n=== Data preparation complete ===\n")
