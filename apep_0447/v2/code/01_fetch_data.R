## ============================================================================
## 01_fetch_data.R — Load T-MSIS, NPPES, OxCGRT, and auxiliary data
## Paper: Lockdowns and the Collapse of In-Person Medicaid Care (v2 revision)
## REVISION CHANGE: Add clean HCBS classification (WS1)
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
## REVISION: Now also track individual HCPCS codes for clean HCBS classification
cat("Building state × service-type × month panel via Arrow...\n")

# Step 3a: Extract at HCPCS code level for later clean classification
provider_monthly_hcpcs <- tmsis_ds |>
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
  filter(!is.na(service_type)) |>
  group_by(BILLING_PROVIDER_NPI_NUM, CLAIM_FROM_MONTH, year, month_num, service_type, HCPCS_CODE) |>
  summarize(
    total_paid = sum(TOTAL_PAID, na.rm = TRUE),
    total_claims = sum(TOTAL_CLAIMS, na.rm = TRUE),
    total_beneficiaries = sum(TOTAL_UNIQUE_BENEFICIARIES, na.rm = TRUE),
    .groups = "drop"
  ) |>
  collect() |>
  as.data.table()

setnames(provider_monthly_hcpcs, "BILLING_PROVIDER_NPI_NUM", "billing_npi")
cat(sprintf("Provider-monthly-HCPCS panel: %s rows\n",
            format(nrow(provider_monthly_hcpcs), big.mark = ",")))

# Join state from NPPES
provider_monthly_hcpcs <- merge(provider_monthly_hcpcs, npi_state,
                                by.x = "billing_npi", by.y = "npi",
                                all.x = FALSE)

cat(sprintf("After state join: %s rows (%s unique NPIs)\n",
            format(nrow(provider_monthly_hcpcs), big.mark = ","),
            format(uniqueN(provider_monthly_hcpcs$billing_npi), big.mark = ",")))

## ---- 3b. HCPCS code classification for HCBS (WS1: Clean HCBS) ----
# Define clean HCBS: genuinely in-person home care codes
clean_hcbs_codes <- c(
  "T1019",  # Personal care services, per 15 min
  "T1020",  # Personal care services, per diem (agency-directed)
  "T2016",  # Habilitation, residential, waiver, per diem
  "T2017",  # Habilitation, residential, waiver, 15 min
  "T2022",  # Case management, per month (community-based waiver)
  "T2025",  # Waiver services NOS (not otherwise specified)
  "T2028",  # Specialized supply (for home-based care)
  "T2033",  # Supported employment, waiver
  "T2034",  # Crisis intervention, waiver, per diem
  "T2036",  # Therapeutic camping, waiver
  "T1005"   # Respite care, per 15 min (in-home)
)

# Non-home-based T-codes to exclude from clean subset
excluded_t_codes <- c(
  "T1015",  # FQHC visit (clinic-based, not home care)
  "T1023",  # Screening (can be clinic-based)
  "T1024",  # Evaluation and assessment (can be clinic-based)
  "T2003",  # Non-emergency transportation (not home care)
  "T2005",  # Non-emergency transportation, stretcher van
  "T2007"   # Transportation, ambulance
)

# Classify HCPCS codes
provider_monthly_hcpcs[, hcbs_clean := FALSE]
provider_monthly_hcpcs[service_type == "HCBS" & HCPCS_CODE %in% clean_hcbs_codes,
                       hcbs_clean := TRUE]

# Log HCPCS code distribution
cat("\n=== HCPCS Code Distribution for T-codes (HCBS) ===\n")
hcpcs_dist <- provider_monthly_hcpcs[service_type == "HCBS",
                                      .(total_paid_sum = sum(total_paid),
                                        total_claims_sum = sum(total_claims)),
                                      by = .(HCPCS_CODE, hcbs_clean)]
setorder(hcpcs_dist, -total_paid_sum)
cat("Top 20 T-codes by total spending:\n")
print(head(hcpcs_dist, 20))

# Save HCPCS distribution for appendix table
saveRDS(hcpcs_dist, file.path(DATA, "hcpcs_distribution.rds"))

## ---- 3c. Collapse to state × service_type × month (all HCBS) ----
panel_all <- provider_monthly_hcpcs[, .(
  total_paid = sum(total_paid),
  total_claims = sum(total_claims),
  total_beneficiaries = sum(total_beneficiaries),
  n_providers = uniqueN(billing_npi)
), by = .(state, service_type, year, month_num, CLAIM_FROM_MONTH)]

panel_all[, month_date := as.Date(paste0(CLAIM_FROM_MONTH, "-01"))]
setorder(panel_all, state, service_type, month_date)

## ---- 3d. Collapse to state × service_type × month (clean HCBS) ----
# For clean HCBS: use only clean_hcbs_codes for HCBS, keep all BH
provider_clean <- provider_monthly_hcpcs[service_type == "BH" | hcbs_clean == TRUE]

panel_clean <- provider_clean[, .(
  total_paid = sum(total_paid),
  total_claims = sum(total_claims),
  total_beneficiaries = sum(total_beneficiaries),
  n_providers = uniqueN(billing_npi)
), by = .(state, service_type, year, month_num, CLAIM_FROM_MONTH)]

panel_clean[, month_date := as.Date(paste0(CLAIM_FROM_MONTH, "-01"))]
setorder(panel_clean, state, service_type, month_date)

cat(sprintf("\nAll-HCBS panel: %d rows (%d states)\n",
            nrow(panel_all), uniqueN(panel_all$state)))
cat(sprintf("Clean-HCBS panel: %d rows (%d states)\n",
            nrow(panel_clean), uniqueN(panel_clean$state)))

# Compare spending levels
cat(sprintf("\nAll T-code HCBS spending (total): $%.1fB\n",
            sum(panel_all[service_type == "HCBS"]$total_paid) / 1e9))
cat(sprintf("Clean HCBS spending (total): $%.1fB\n",
            sum(panel_clean[service_type == "HCBS"]$total_paid) / 1e9))
cat(sprintf("Clean share of all HCBS: %.1f%%\n",
            100 * sum(panel_clean[service_type == "HCBS"]$total_paid) /
              sum(panel_all[service_type == "HCBS"]$total_paid)))

# Clean up HCPCS-level data
rm(provider_monthly_hcpcs, provider_clean)
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

sah_from_oxcgrt <- oxcgrt_clean[c6_stay_home >= 2, .(first_sah_date = min(date)), by = state]

cat(sprintf("States with mandatory stay-at-home (C6 >= 2): %d\n", nrow(sah_from_oxcgrt)))

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
  acs_url <- sprintf(
    "https://api.census.gov/data/2019/acs/acs5?get=B01003_001E,B27007_004E,B27007_007E,B27007_010E,NAME&for=state:*&key=%s",
    census_key
  )
  acs_resp <- GET(acs_url)
  if (status_code(acs_resp) == 200) {
    acs_raw <- fromJSON(content(acs_resp, as = "text", encoding = "UTF-8"))
    acs_dt <- as.data.table(acs_raw[-1, ])
    setnames(acs_dt, c("pop_total", "medicaid_19_25", "medicaid_26_34",
                       "medicaid_35_44", "state_name", "state_fips"))
    acs_dt[, pop_total := as.numeric(pop_total)]
    acs_dt[, medicaid_est := as.numeric(medicaid_19_25) +
             as.numeric(medicaid_26_34) + as.numeric(medicaid_35_44)]

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
    Sys.sleep(0.1)
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

## ---- 8. Helper function to prepare analysis panel ----
prepare_panel <- function(panel_raw, state_treatment, stringency_monthly,
                          state_pop, unemp_dt) {
  # Merge treatment intensity
  panel_raw <- merge(panel_raw, state_treatment, by = "state", all.x = TRUE)

  # Merge monthly stringency
  panel_raw <- merge(panel_raw, stringency_monthly,
                     by = c("state", "year", "month_num"), all.x = TRUE)
  panel_raw[is.na(stringency_avg), stringency_avg := 0]
  panel_raw[is.na(stringency_max), stringency_max := 0]

  # Merge population
  if (!is.null(state_pop)) {
    panel_raw <- merge(panel_raw, state_pop[, .(state, pop_total)], by = "state", all.x = TRUE)
  }

  # Merge unemployment
  if (!is.null(unemp_dt)) {
    panel_raw <- merge(panel_raw, unemp_dt[, .(state, year, month_num, unemp_rate)],
                       by = c("state", "year", "month_num"), all.x = TRUE)
  }

  # Create key variables
  panel_raw[, `:=`(
    post = as.integer(month_date >= as.Date("2020-04-01")),
    is_hcbs = as.integer(service_type == "HCBS"),
    log_paid = log(total_paid + 1),
    log_claims = log(total_claims + 1),
    log_providers = log(n_providers + 1),
    log_beneficiaries = log(total_beneficiaries + 1),
    month_id = as.integer(factor(month_date)),
    peak_stringency_std = peak_stringency / 100,
    cum_stringency_std = cum_stringency / 100,
    stringency_q = cut(peak_stringency,
                       breaks = quantile(peak_stringency, probs = c(0, 0.25, 0.5, 0.75, 1), na.rm = TRUE),
                       include.lowest = TRUE, labels = c("Q1 (Low)", "Q2", "Q3", "Q4 (High)"))
  )]

  # Per-capita
  if ("pop_total" %in% names(panel_raw)) {
    panel_raw[, paid_pc := fifelse(!is.na(pop_total) & pop_total > 0,
                                   total_paid / pop_total * 100000, NA_real_)]
  }

  # State-service FE
  panel_raw[, state_service := paste(state, service_type, sep = "_")]

  # Period indicators
  panel_raw[, period := fcase(
    month_date < as.Date("2020-03-01"), "Pre-COVID",
    month_date >= as.Date("2020-03-01") & month_date < as.Date("2020-04-01"), "March 2020 (partial)",
    month_date >= as.Date("2020-04-01") & month_date < as.Date("2020-07-01"), "Lockdown (Apr-Jun 2020)",
    month_date >= as.Date("2020-07-01") & month_date < as.Date("2021-01-01"), "Recovery (Jul-Dec 2020)",
    month_date >= as.Date("2021-01-01") & month_date < as.Date("2022-01-01"), "Post-Lockdown (2021)",
    month_date >= as.Date("2022-01-01") & month_date < as.Date("2023-01-01"), "Post-Lockdown (2022)",
    month_date >= as.Date("2023-01-01"), "Post-Lockdown (2023-24)"
  )]

  # Drop March 2020
  panel_raw <- panel_raw[month_date != as.Date("2020-03-01")]

  # Drop Oct-Dec 2024 (T-MSIS reporting lags)
  panel_raw <- panel_raw[month_date < as.Date("2024-10-01")]

  return(panel_raw)
}

## ---- 9. Prepare both panels ----
cat("\nPreparing ALL-HCBS panel...\n")
panel_all_analysis <- prepare_panel(panel_all, state_treatment, stringency_monthly,
                                     state_pop, unemp_dt)

cat(sprintf("\n=== ALL-HCBS analysis panel ===\n"))
cat(sprintf("Total rows: %s\n", format(nrow(panel_all_analysis), big.mark = ",")))
cat(sprintf("States: %d, Service types: %s, Date range: %s to %s\n",
            uniqueN(panel_all_analysis$state),
            paste(unique(panel_all_analysis$service_type), collapse = ", "),
            min(panel_all_analysis$month_date), max(panel_all_analysis$month_date)))

cat("\nPreparing CLEAN-HCBS panel...\n")
panel_clean_analysis <- prepare_panel(panel_clean, state_treatment, stringency_monthly,
                                       state_pop, unemp_dt)

cat(sprintf("\n=== CLEAN-HCBS analysis panel ===\n"))
cat(sprintf("Total rows: %s\n", format(nrow(panel_clean_analysis), big.mark = ",")))
cat(sprintf("States: %d, Service types: %s, Date range: %s to %s\n",
            uniqueN(panel_clean_analysis$state),
            paste(unique(panel_clean_analysis$service_type), collapse = ", "),
            min(panel_clean_analysis$month_date), max(panel_clean_analysis$month_date)))

## ---- 10. Save ----
saveRDS(panel_all_analysis, file.path(DATA, "panel_all_analysis.rds"))
saveRDS(panel_clean_analysis, file.path(DATA, "panel_analysis.rds"))  # Clean is primary
saveRDS(state_treatment, file.path(DATA, "state_treatment.rds"))
saveRDS(stringency_monthly, file.path(DATA, "stringency_monthly.rds"))
if (!is.null(state_pop)) saveRDS(state_pop, file.path(DATA, "state_pop.rds"))
if (!is.null(unemp_dt)) saveRDS(unemp_dt, file.path(DATA, "unemp_dt.rds"))

cat("\n=== Data preparation complete ===\n")
