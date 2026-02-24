## ============================================================================
## 01_fetch_data.R — Data acquisition
## apep_0448: Early UI Termination and Medicaid HCBS Provider Supply
## ============================================================================

source("00_packages.R")

## ---- 0. Paths ----
SHARED_DATA <- file.path("..", "..", "..", "..", "data", "medicaid_provider_spending")
DATA <- "../data"
dir.create(DATA, showWarnings = FALSE, recursive = TRUE)

## ---- 1. T-MSIS (local Parquet) ----
tmsis_path <- file.path(SHARED_DATA, "tmsis.parquet")
if (!file.exists(tmsis_path)) {
  stop("T-MSIS Parquet not found at: ", tmsis_path)
}
cat("Opening T-MSIS Parquet (lazy)...\n")
tmsis_ds <- open_dataset(tmsis_path)

## ---- 2. NPPES extract ----
nppes_path <- file.path(SHARED_DATA, "nppes_extract.parquet")
cat("Loading NPPES extract...\n")
nppes <- as.data.table(read_parquet(nppes_path))
nppes[, npi := as.character(npi)]
cat(sprintf("NPPES: %s providers\n", format(nrow(nppes), big.mark = ",")))

npi_state <- nppes[!is.na(state) & state != "", .(npi, state, entity_type)]

## ---- 3. Build HCBS panel (T-codes + attendant care S-codes) ----
hcbs_t_codes <- c("T1019", "T1020", "T2016", "T2020", "T2022",
                   "T2025", "T2026", "T2030", "T2034", "T1015")
hcbs_s_codes <- c("S5125", "S5130", "S5150")
bh_h_codes_prefix <- "H"

cat("Aggregating HCBS (T/S-code) billing by NPI × month...\n")
hcbs_npi_month <- tmsis_ds |>
  filter(
    HCPCS_CODE %in% c(hcbs_t_codes, hcbs_s_codes)
  ) |>
  group_by(BILLING_PROVIDER_NPI_NUM, CLAIM_FROM_MONTH) |>
  summarize(
    paid = sum(TOTAL_PAID, na.rm = TRUE),
    claims = sum(TOTAL_CLAIMS, na.rm = TRUE),
    benes = sum(TOTAL_UNIQUE_BENEFICIARIES, na.rm = TRUE),
    .groups = "drop"
  ) |>
  collect() |>
  as.data.table()

setnames(hcbs_npi_month, "BILLING_PROVIDER_NPI_NUM", "billing_npi")
cat(sprintf("HCBS NPI-months: %s\n", format(nrow(hcbs_npi_month), big.mark = ",")))

# Join state
hcbs_npi_month <- merge(hcbs_npi_month, npi_state,
                         by.x = "billing_npi", by.y = "npi", all.x = TRUE)
cat(sprintf("State match rate: %.1f%%\n", 100 * mean(!is.na(hcbs_npi_month$state))))

# Drop non-state territories, keep 50 states + DC
valid_states <- c(state.abb, "DC")
hcbs_npi_month <- hcbs_npi_month[state %in% valid_states]

# State × month panel
hcbs_panel <- hcbs_npi_month[, .(
  n_providers = uniqueN(billing_npi),
  total_paid = sum(paid),
  total_claims = sum(claims),
  total_benes = sum(benes)
), by = .(state, CLAIM_FROM_MONTH)]

hcbs_panel[, month_date := as.Date(paste0(CLAIM_FROM_MONTH, "-01"))]
hcbs_panel[, service_type := "HCBS"]
setorder(hcbs_panel, state, month_date)

cat(sprintf("HCBS state × month panel: %d rows, %d states, %d months\n",
            nrow(hcbs_panel), uniqueN(hcbs_panel$state), uniqueN(hcbs_panel$month_date)))

## ---- 4. Build behavioral health panel (H-codes) — placebo ----
cat("Aggregating BH (H-code) billing by NPI × month...\n")
bh_npi_month <- tmsis_ds |>
  filter(substr(HCPCS_CODE, 1, 1) == "H") |>
  group_by(BILLING_PROVIDER_NPI_NUM, CLAIM_FROM_MONTH) |>
  summarize(
    paid = sum(TOTAL_PAID, na.rm = TRUE),
    claims = sum(TOTAL_CLAIMS, na.rm = TRUE),
    benes = sum(TOTAL_UNIQUE_BENEFICIARIES, na.rm = TRUE),
    .groups = "drop"
  ) |>
  collect() |>
  as.data.table()

setnames(bh_npi_month, "BILLING_PROVIDER_NPI_NUM", "billing_npi")
bh_npi_month <- merge(bh_npi_month, npi_state,
                       by.x = "billing_npi", by.y = "npi", all.x = TRUE)
bh_npi_month <- bh_npi_month[state %in% valid_states]

bh_panel <- bh_npi_month[, .(
  n_providers = uniqueN(billing_npi),
  total_paid = sum(paid),
  total_claims = sum(claims),
  total_benes = sum(benes)
), by = .(state, CLAIM_FROM_MONTH)]

bh_panel[, month_date := as.Date(paste0(CLAIM_FROM_MONTH, "-01"))]
bh_panel[, service_type := "BH"]
setorder(bh_panel, state, month_date)

cat(sprintf("BH state × month panel: %d rows\n", nrow(bh_panel)))

## ---- 5. Combine panels ----
panel <- rbind(hcbs_panel, bh_panel)

## ---- 6. Early UI termination treatment data ----
ui_termination <- data.table(
  state = c("AK", "IA", "MS", "MO",
            "AL", "ID", "IN", "NE", "NH", "ND", "WV", "WY",
            "AR", "FL", "GA", "OH", "OK", "SD", "TX", "UT",
            "MT", "SC", "MD", "TN", "AZ", "LA"),
  termination_date = as.Date(c(
    rep("2021-06-12", 4),
    rep("2021-06-19", 8),
    rep("2021-06-26", 8),
    "2021-06-27",
    "2021-06-30",
    rep("2021-07-03", 2),
    "2021-07-10",
    "2021-07-31"
  ))
)

# First full month of exposure
ui_termination[, first_full_month := fifelse(
  day(termination_date) <= 1,
  floor_date(termination_date, "month"),
  floor_date(termination_date, "month") + months(1)
)]

# Cohort assignment for CS-DiD
ui_termination[, cohort := format(first_full_month, "%Y-%m")]

cat("UI termination cohorts:\n")
print(ui_termination[, .N, by = .(cohort, first_full_month)])

## ---- 7. Merge treatment into panel ----
panel <- merge(panel, ui_termination[, .(state, termination_date, first_full_month, cohort)],
               by = "state", all.x = TRUE)

# Treatment indicator
panel[, early_terminator := !is.na(termination_date)]
panel[, treated := early_terminator & month_date >= first_full_month]

# Numeric cohort for CS-DiD (0 = never treated)
panel[, cohort_num := fifelse(is.na(first_full_month), 0L,
                               as.integer(format(first_full_month, "%Y%m")))]

# Time period as integer (months since 2018-01)
panel[, time_period := as.integer(difftime(month_date, as.Date("2018-01-01"), units = "days")) %/% 30 + 1]

# Log outcomes (add 1 to handle zeros)
panel[, ln_providers := log(n_providers + 1)]
panel[, ln_claims := log(total_claims + 1)]
panel[, ln_paid := log(total_paid + 1)]
panel[, ln_benes := log(total_benes + 1)]

# Claims per provider
panel[, claims_per_provider := total_claims / pmax(n_providers, 1)]
panel[, benes_per_provider := total_benes / pmax(n_providers, 1)]

cat(sprintf("\nFull panel: %d rows (%d states × %d months × %d service types)\n",
            nrow(panel), uniqueN(panel$state), uniqueN(panel$month_date),
            uniqueN(panel$service_type)))

## ---- 8. State-level covariates ----
# Census ACS: state population
census_key <- Sys.getenv("CENSUS_API_KEY")
if (nchar(census_key) > 0) {
  cat("Fetching state population from Census ACS...\n")
  pop_list <- list()
  for (yr in 2018:2023) {
    url <- sprintf(
      "https://api.census.gov/data/%d/acs/acs5?get=B01003_001E,NAME&for=state:*&key=%s",
      yr, census_key
    )
    resp <- tryCatch(GET(url, timeout(30)), error = function(e) NULL)
    if (!is.null(resp) && status_code(resp) == 200) {
      raw <- content(resp, "text", encoding = "UTF-8")
      df <- as.data.table(fromJSON(raw))
      names(df) <- df[1, ]
      df <- df[-1, ]
      pop_list[[as.character(yr)]] <- data.table(
        state_fips = df$state,
        state_name = df$NAME,
        population = as.numeric(df$B01003_001E),
        year = yr
      )
    }
  }
  state_pop <- rbindlist(pop_list)

  # FIPS to state abbreviation mapping
  fips_map <- data.table(
    state_fips = sprintf("%02d", c(1,2,4,5,6,8,9,10,11,12,13,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,44,45,46,47,48,49,50,51,53,54,55,56)),
    state = c("AL","AK","AZ","AR","CA","CO","CT","DE","DC","FL","GA","HI","ID","IL","IN","IA","KS","KY","LA","ME","MD","MA","MI","MN","MS","MO","MT","NE","NV","NH","NJ","NM","NY","NC","ND","OH","OK","OR","PA","RI","SC","SD","TN","TX","UT","VT","VA","WA","WV","WI","WY")
  )

  state_pop <- merge(state_pop, fips_map, by = "state_fips", all.x = TRUE)
  state_pop <- state_pop[!is.na(state)]
  saveRDS(state_pop, file.path(DATA, "state_pop.rds"))
  cat(sprintf("State population: %d rows\n", nrow(state_pop)))
} else {
  cat("CENSUS_API_KEY not set — skipping population fetch\n")
}

## ---- 9. COVID severity data ----
# Use CDC COVID-19 case surveillance (state-level weekly)
cat("Fetching COVID death data from CDC...\n")
covid_url <- "https://data.cdc.gov/resource/9mfq-cb36.json?$limit=50000&$select=state,submission_date,new_death&$where=submission_date>='2020-01-01'"
covid_resp <- tryCatch(GET(covid_url, timeout(60)), error = function(e) NULL)

if (!is.null(covid_resp) && status_code(covid_resp) == 200) {
  covid_raw <- content(covid_resp, "text", encoding = "UTF-8")
  covid_dt <- as.data.table(fromJSON(covid_raw))
  covid_dt[, submission_date := as.Date(submission_date)]
  covid_dt[, new_death := as.numeric(new_death)]
  covid_dt[, month_date := floor_date(submission_date, "month")]

  # Aggregate to state × month
  covid_monthly <- covid_dt[, .(
    monthly_deaths = sum(new_death, na.rm = TRUE)
  ), by = .(state, month_date)]

  saveRDS(covid_monthly, file.path(DATA, "covid_monthly.rds"))
  cat(sprintf("COVID monthly deaths: %d rows\n", nrow(covid_monthly)))
} else {
  cat("Warning: COVID data fetch failed — will proceed without COVID controls\n")
}

## ---- 10. Save main panel ----
saveRDS(panel, file.path(DATA, "panel.rds"))
saveRDS(ui_termination, file.path(DATA, "ui_termination.rds"))
saveRDS(hcbs_npi_month, file.path(DATA, "hcbs_npi_month.rds"))

cat("\n=== Data preparation complete ===\n")
cat(sprintf("HCBS panel: %d state-months\n", nrow(panel[service_type == "HCBS"])))
cat(sprintf("BH panel: %d state-months\n", nrow(panel[service_type == "BH"])))
cat(sprintf("Early terminators: %d states\n", uniqueN(ui_termination$state)))
