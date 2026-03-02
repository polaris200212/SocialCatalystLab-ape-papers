## ============================================================================
## 01_fetch_data.R -- Data acquisition for apep_0424
## Does Telehealth Payment Parity Expand Medicaid Behavioral Health Access?
## ============================================================================

source("00_packages.R")

SHARED_DATA <- file.path("..", "..", "..", "..", "data", "medicaid_provider_spending")
DATA <- "../data"
dir.create(DATA, showWarnings = FALSE, recursive = TRUE)

## --------------------------------------------------------------------------
## 1. Treatment Variable: State Telehealth Payment Parity Law Adoption
## --------------------------------------------------------------------------
## Sources: CCHPCA State Telehealth Laws Reports (2019-2025), NCSL,
## individual state legislative databases, AMA State Telehealth Policy
## Reports (2023 Year in Review).
##
## We code PERMANENT Medicaid telehealth payment parity laws:
## - "Payment parity" = state law requires Medicaid to reimburse telehealth
##   at the same rate as equivalent in-person services
## - Excludes temporary COVID-19 emergency waivers that expired
## - Excludes coverage-only parity (must include rate parity)
## - For "all payer" laws that include Medicaid, we code as treated

parity_dates <- data.table(
  state = c(
    "GA", "NJ", "WV", "KY", "VA", "HI", "MN", "CO", "NM", "IN",
    "MS", "AR", "ND", "LA", "MO", "CT", "ME", "MT", "OK",
    "NH", "DE", "IL", "SC", "IA", "AZ", "NE"
  ),
  parity_date = as.Date(c(
    "2020-01-01",  # GA: SB 118
    "2021-01-18",  # NJ: A 1467
    "2021-06-10",  # WV: HB 2024
    "2021-06-29",  # KY: HB 140
    "2021-07-01",  # VA: HB 81
    "2021-07-01",  # HI: HB 907
    "2021-07-01",  # MN: SF 3019
    "2021-07-01",  # CO: HB 21-1190
    "2021-07-01",  # NM: HB 245
    "2021-07-01",  # IN: SB 3
    "2021-07-01",  # MS: HB 1531
    "2021-07-28",  # AR: Act 829
    "2021-08-01",  # ND: HB 1247
    "2021-08-01",  # LA: HB 449
    "2021-08-28",  # MO: SB 5
    "2021-10-01",  # CT: PA 21-9
    "2021-10-18",  # ME: LD 1034
    "2021-10-01",  # MT: SB 101
    "2021-11-01",  # OK: SB 674
    "2022-01-01",  # NH: HB 602
    "2022-01-01",  # DE: HB 348
    "2022-01-01",  # IL: SB 2294
    "2022-05-17",  # SC: HB 3726
    "2022-07-01",  # IA: HF 2548
    "2022-09-24",  # AZ: SB 1089
    "2023-01-01"   # NE: LB 400
  ))
)

parity_dates[, parity_year := year(parity_date)]
parity_dates[, parity_quarter := quarter(parity_date)]
# Time index: quarters since Q1 2018
parity_dates[, first_treat_q := (parity_year - 2018) * 4 + parity_quarter]

cat(sprintf("Treatment states: %d\n", nrow(parity_dates)))
cat(sprintf("Treatment cohorts: %d unique quarter-years\n",
            uniqueN(paste(parity_dates$parity_year, parity_dates$parity_quarter))))
cat(sprintf("Earliest treatment: %s (Q%d %d)\n", min(parity_dates$parity_date),
            parity_dates[parity_date == min(parity_date)]$parity_quarter,
            parity_dates[parity_date == min(parity_date)]$parity_year))
cat(sprintf("Latest treatment: %s (Q%d %d)\n", max(parity_dates$parity_date),
            parity_dates[parity_date == max(parity_date)]$parity_quarter,
            parity_dates[parity_date == max(parity_date)]$parity_year))

saveRDS(parity_dates, file.path(DATA, "parity_dates.rds"))

## --------------------------------------------------------------------------
## 2. T-MSIS Behavioral Health and Personal Care Claims
## --------------------------------------------------------------------------

tmsis_path <- file.path(SHARED_DATA, "tmsis.parquet")
stopifnot(file.exists(tmsis_path))

tmsis_ds <- open_dataset(tmsis_path)
cat(sprintf("T-MSIS columns: %s\n", paste(names(tmsis_ds), collapse = ", ")))

# Aggregate by billing NPI, month, and service type (BH vs PC)
bh_monthly <- tmsis_ds |>
  mutate(
    hcpcs_prefix = substr(HCPCS_CODE, 1, 1),
    service_type = case_when(
      hcpcs_prefix == "H" ~ "behavioral_health",
      hcpcs_prefix == "T" ~ "personal_care",
      TRUE ~ "other"
    ),
    year = as.integer(substr(CLAIM_FROM_MONTH, 1, 4)),
    month_num = as.integer(substr(CLAIM_FROM_MONTH, 6, 7))
  ) |>
  filter(service_type %in% c("behavioral_health", "personal_care")) |>
  group_by(BILLING_PROVIDER_NPI_NUM, CLAIM_FROM_MONTH, year, month_num, service_type) |>
  summarize(
    total_paid = sum(TOTAL_PAID, na.rm = TRUE),
    total_claims = sum(TOTAL_CLAIMS, na.rm = TRUE),
    total_beneficiaries = sum(TOTAL_UNIQUE_BENEFICIARIES, na.rm = TRUE),
    .groups = "drop"
  ) |>
  collect() |>
  as.data.table()

setnames(bh_monthly, "BILLING_PROVIDER_NPI_NUM", "billing_npi")
setnames(bh_monthly, "CLAIM_FROM_MONTH", "claim_month")

cat(sprintf("Provider x month x service records: %s\n", format(nrow(bh_monthly), big.mark = ",")))
cat(sprintf("  Behavioral health: %s\n",
            format(nrow(bh_monthly[service_type == "behavioral_health"]), big.mark = ",")))
cat(sprintf("  Personal care: %s\n",
            format(nrow(bh_monthly[service_type == "personal_care"]), big.mark = ",")))

saveRDS(bh_monthly, file.path(DATA, "bh_provider_monthly.rds"))

## --------------------------------------------------------------------------
## 3. NPPES Extract -- Provider Geography
## --------------------------------------------------------------------------

nppes_path <- file.path(SHARED_DATA, "nppes_extract.parquet")
if (file.exists(nppes_path)) {
  nppes <- as.data.table(read_parquet(nppes_path))
  cat(sprintf("NPPES extract: %s providers\n", format(nrow(nppes), big.mark = ",")))
} else {
  nppes_csv <- list.files(SHARED_DATA, pattern = "npidata_pfile.*\\.csv$", full.names = TRUE)[1]
  nppes <- fread(nppes_csv, select = c(
    "NPI", "Entity Type Code",
    "Provider Business Practice Location Address State Name",
    "Provider Business Practice Location Address Postal Code",
    "Healthcare Provider Taxonomy Code_1",
    "Provider Enumeration Date", "NPI Deactivation Date"
  ), showProgress = TRUE, nThread = 4)
  setnames(nppes, c("npi", "entity_type", "state", "zip", "taxonomy_1",
                     "enumeration_date", "deactivation_date"))
  nppes[, zip5 := substr(gsub("[^0-9]", "", zip), 1, 5)]
}

# State abbreviation mapping
state_xwalk <- data.table(state_name = c(state.name, "District of Columbia"),
                           state_abb = c(state.abb, "DC"))

npi_state <- nppes[, .(npi = as.character(npi), state, entity_type)]

# Convert state names to abbreviations if needed
if (any(nchar(npi_state$state) > 2, na.rm = TRUE)) {
  npi_state <- merge(npi_state, state_xwalk, by.x = "state", by.y = "state_name", all.x = TRUE)
  npi_state[!is.na(state_abb), state := state_abb]
  npi_state[, state_abb := NULL]
}

npi_state <- npi_state[!is.na(state) & nchar(state) == 2]
saveRDS(npi_state, file.path(DATA, "npi_state.rds"))
cat(sprintf("NPI-state mapping: %s providers\n", format(nrow(npi_state), big.mark = ",")))

## --------------------------------------------------------------------------
## 4. Census ACS -- State Population
## --------------------------------------------------------------------------

census_key <- Sys.getenv("CENSUS_API_KEY")
if (nchar(census_key) > 0) {
  pop_list <- list()
  for (yr in 2018:2023) {
    url <- sprintf(
      "https://api.census.gov/data/%d/acs/acs5?get=B01003_001E,NAME&for=state:*&key=%s",
      yr, census_key
    )
    resp <- tryCatch(fromJSON(url), error = function(e) NULL)
    if (!is.null(resp)) {
      df <- as.data.table(resp[-1, ])
      setnames(df, c("population", "state_name", "state_fips"))
      df[, population := as.numeric(population)]
      df[, year := yr]
      pop_list[[as.character(yr)]] <- df
    }
  }
  state_pop <- rbindlist(pop_list)
  state_pop <- merge(state_pop, state_xwalk, by = "state_name", all.x = TRUE)
  saveRDS(state_pop, file.path(DATA, "state_population.rds"))
  cat(sprintf("Census population: %d state-year records\n", nrow(state_pop)))
} else {
  cat("CENSUS_API_KEY not set. Skipping.\n")
}

## --------------------------------------------------------------------------
## 5. FRED -- State Unemployment
## --------------------------------------------------------------------------

fred_key <- Sys.getenv("FRED_API_KEY")
if (nchar(fred_key) > 0) {
  unemp_list <- list()
  for (st in c(state.abb, "DC")) {
    url <- sprintf(
      "https://api.stlouisfed.org/fred/series/observations?series_id=%sUR&observation_start=2018-01-01&observation_end=2024-12-31&api_key=%s&file_type=json",
      st, fred_key
    )
    resp <- tryCatch(fromJSON(url), error = function(e) NULL)
    if (!is.null(resp) && "observations" %in% names(resp)) {
      obs <- as.data.table(resp$observations)
      obs[, `:=`(state = st, date = as.Date(date), value = as.numeric(value))]
      unemp_list[[st]] <- obs[, .(state, date, unemp_rate = value)]
    }
  }
  state_unemp <- rbindlist(unemp_list)
  state_unemp[, `:=`(year = year(date), month_num = month(date))]
  saveRDS(state_unemp, file.path(DATA, "state_unemployment.rds"))
  cat(sprintf("FRED unemployment: %d state-month records\n", nrow(state_unemp)))
} else {
  cat("FRED_API_KEY not set. Skipping.\n")
}

cat("\n=== Data acquisition complete ===\n")
