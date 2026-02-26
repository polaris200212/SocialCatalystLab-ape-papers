## ============================================================================
## 02_clean_data.R — Construct treatment variable and analysis panel
## apep_0467: Priced Out of Care
##
## Outputs:
##   - state_wage_ratio.rds: 2019 wage competitiveness ratio by state
##   - panel_hcbs.rds: state × month HCBS provider panel
##   - panel_analysis.rds: merged panel with treatment + controls
## ============================================================================

source("00_packages.R")

## ============================================================
## PART A: Construct Treatment Variable — 2019 Wage Ratio
## ============================================================

## ---- A1. Parse BLS QCEW State Wage Data ----
cat("Parsing BLS QCEW state wage data...\n")

qcew <- fread(file.path(DATA, "qcew_state_wages_2019.csv"))
cat(sprintf("QCEW records: %d\n", nrow(qcew)))
cat("Industries:\n")
print(qcew[, .N, by = industry])

## ---- A2. Construct Wage Ratio ----
cat("\nConstructing wage competitiveness ratio...\n")

# Home care wage (NAICS 624120: Services for Elderly/Disabled)
pca_wage <- qcew[industry == "Home_Care", .(state, pca_wage = implied_hourly)]

# Competing sector composite (equal-weighted mean of grocery, fast food, warehouse)
competing_wage <- qcew[industry != "Home_Care",
                        .(outside_wage = mean(implied_hourly, na.rm = TRUE)),
                        by = state]

# Merge and compute ratio
wage_ratio <- merge(pca_wage, competing_wage, by = "state", all = FALSE)
wage_ratio[, wage_ratio := pca_wage / outside_wage]

cat(sprintf("\nWage ratio computed for %d states\n", nrow(wage_ratio)))
cat(sprintf("PCA wage range: $%.2f - $%.2f\n", min(wage_ratio$pca_wage), max(wage_ratio$pca_wage)))
cat(sprintf("Outside wage range: $%.2f - $%.2f\n", min(wage_ratio$outside_wage), max(wage_ratio$outside_wage)))
cat(sprintf("Wage ratio range: %.3f - %.3f\n", min(wage_ratio$wage_ratio), max(wage_ratio$wage_ratio)))
cat(sprintf("Wage ratio mean: %.3f, SD: %.3f\n", mean(wage_ratio$wage_ratio), sd(wage_ratio$wage_ratio)))

# Tercile classification for robustness
wage_ratio[, ratio_tercile := cut(wage_ratio,
                                  breaks = quantile(wage_ratio, c(0, 1/3, 2/3, 1)),
                                  labels = c("Low", "Medium", "High"),
                                  include.lowest = TRUE)]

saveRDS(wage_ratio, file.path(DATA, "state_wage_ratio.rds"))
cat("Saved: state_wage_ratio.rds\n")


## ============================================================
## PART B: Build HCBS Provider Panel from T-MSIS
## ============================================================

cat("\n=== Building HCBS state × month panel ===\n")

## ---- B1. Load NPPES for state mapping ----
nppes_path <- file.path(SHARED_DATA, "nppes_extract.parquet")
nppes <- as.data.table(read_parquet(nppes_path,
                                    col_select = c("npi", "state", "entity_type", "sole_prop")))
nppes[, npi := as.character(npi)]
nppes <- nppes[!is.na(state) & state != "" & nchar(state) == 2]
cat(sprintf("NPPES: %s providers with valid state\n", format(nrow(nppes), big.mark = ",")))

# Deduplicate NPIs (keep first state if multiple)
nppes <- nppes[!duplicated(npi)]

## ---- B2. Aggregate T-MSIS HCBS codes by billing NPI × month ----
cat("Querying T-MSIS for HCBS codes (T + S prefixes)...\n")

tmsis_ds <- open_dataset(file.path(SHARED_DATA, "tmsis.parquet"))

# HCBS = T-codes + S-codes (personal care, attendant care, habilitation, respite)
# Key codes: T1019, T1020, T2016, T2017, T2022, T2025, T2033, S5125, S5150, S5170
hcbs_monthly <- tmsis_ds |>
  filter(substr(HCPCS_CODE, 1, 1) %in% c("T", "S")) |>
  group_by(BILLING_PROVIDER_NPI_NUM, CLAIM_FROM_MONTH) |>
  summarize(
    total_paid = sum(TOTAL_PAID, na.rm = TRUE),
    total_claims = sum(TOTAL_CLAIMS, na.rm = TRUE),
    total_beneficiaries = sum(TOTAL_UNIQUE_BENEFICIARIES, na.rm = TRUE),
    .groups = "drop"
  ) |>
  collect() |>
  as.data.table()

setnames(hcbs_monthly, "BILLING_PROVIDER_NPI_NUM", "billing_npi")
setnames(hcbs_monthly, "CLAIM_FROM_MONTH", "month_str")

cat(sprintf("HCBS NPI-month records: %s\n", format(nrow(hcbs_monthly), big.mark = ",")))

## ---- B3. Join state from NPPES ----
hcbs_monthly <- merge(hcbs_monthly, nppes[, .(npi, state, entity_type, sole_prop)],
                      by.x = "billing_npi", by.y = "npi", all.x = TRUE)

# Drop unmatched and non-US states
hcbs_monthly <- hcbs_monthly[!is.na(state) & state %in% c(state.abb, "DC")]
cat(sprintf("After state matching: %s NPI-month records\n",
            format(nrow(hcbs_monthly), big.mark = ",")))

## ---- B4. Collapse to state × month panel ----
hcbs_monthly[, month_date := as.Date(paste0(month_str, "-01"))]

panel_hcbs <- hcbs_monthly[, .(
  n_providers     = uniqueN(billing_npi),
  n_sole_prop     = uniqueN(billing_npi[sole_prop == "Y"]),
  n_org           = uniqueN(billing_npi[entity_type == 2]),
  total_paid      = sum(total_paid),
  total_claims    = sum(total_claims),
  total_beneficiaries = sum(total_beneficiaries)
), by = .(state, month_date)]

setorder(panel_hcbs, state, month_date)

cat(sprintf("Panel: %d state-months, %d states, %d months\n",
            nrow(panel_hcbs), uniqueN(panel_hcbs$state), uniqueN(panel_hcbs$month_date)))

# Log transformations (add 1 to handle zeros)
panel_hcbs[, `:=`(
  log_providers      = log(n_providers + 1),
  log_beneficiaries  = log(total_beneficiaries + 1),
  log_spending       = log(total_paid + 1),
  log_claims         = log(total_claims + 1),
  log_sole_prop      = log(n_sole_prop + 1),
  log_org            = log(n_org + 1)
)]

# Time variables
panel_hcbs[, `:=`(
  year = year(month_date),
  month_num = month(month_date),
  time_index = as.integer(difftime(month_date, as.Date("2020-01-01"), units = "days")) %/% 30,
  post_covid = as.integer(month_date >= as.Date("2020-03-01")),
  post_arpa  = as.integer(month_date >= as.Date("2021-04-01"))
)]

saveRDS(panel_hcbs, file.path(DATA, "panel_hcbs.rds"))
cat("Saved: panel_hcbs.rds\n")


## ============================================================
## PART C: Process Control Variables
## ============================================================

cat("\n=== Processing control variables ===\n")

## ---- C1. COVID cases/deaths ----
covid_path <- file.path(DATA, "covid_states.csv")
if (file.exists(covid_path)) {
  covid <- fread(covid_path)
  covid[, date := as.Date(date)]

  # Aggregate to state × month (new cases/deaths per month)
  covid[, month_date := as.Date(paste0(format(date, "%Y-%m"), "-01"))]

  # Compute monthly new cases (difference from max/min within month)
  covid_monthly <- covid[, .(
    cumulative_cases = max(cases, na.rm = TRUE),
    cumulative_deaths = max(deaths, na.rm = TRUE)
  ), by = .(state, month_date)]

  setorder(covid_monthly, state, month_date)
  covid_monthly[, `:=`(
    new_cases = cumulative_cases - shift(cumulative_cases, 1, fill = 0),
    new_deaths = cumulative_deaths - shift(cumulative_deaths, 1, fill = 0)
  ), by = state]

  # State name → abbreviation
  state_map <- data.table(
    name = c(state.name, "District of Columbia"),
    abbr = c(state.abb, "DC")
  )
  covid_monthly <- merge(covid_monthly, state_map, by.x = "state", by.y = "name", all.x = TRUE)
  covid_monthly[, state := abbr]
  covid_monthly <- covid_monthly[!is.na(state)]

  cat(sprintf("COVID monthly: %d state-months\n", nrow(covid_monthly)))
} else {
  cat("WARNING: COVID data not found. Proceeding without COVID controls.\n")
  covid_monthly <- data.table()
}

## ---- C2. State unemployment rates ----
ur_path <- file.path(DATA, "state_unemployment.csv")
if (file.exists(ur_path)) {
  ur_dt <- fread(ur_path)
  ur_dt[, date := as.Date(date)]
  ur_dt[, month_date := as.Date(paste0(format(date, "%Y-%m"), "-01"))]
  ur_dt[, state_ur := value]
  ur_monthly <- ur_dt[, .(state_ur = mean(state_ur, na.rm = TRUE)),
                      by = .(state, month_date)]
  cat(sprintf("Unemployment: %d state-months\n", nrow(ur_monthly)))
} else {
  cat("WARNING: UR data not found.\n")
  ur_monthly <- data.table()
}

## ---- C3. Population ----
pop_path <- file.path(DATA, "state_population.csv")
if (file.exists(pop_path)) {
  pop_dt <- fread(pop_path)
  # Map FIPS to state abbreviation
  fips_map <- data.table(
    fips = sprintf("%02d", c(1:2, 4:6, 8:13, 15:42, 44:51, 53:56)),
    abbr = c(state.abb[1:2], state.abb[3:5], state.abb[6:8], "DC",
             state.abb[9:10], state.abb[11:50])
  )
  # Simpler: use state name
  state_name_map <- data.table(
    name = c(state.name, "District of Columbia"),
    abbr = c(state.abb, "DC")
  )
  pop_dt <- merge(pop_dt, state_name_map, by.x = "state_name", by.y = "name", all.x = TRUE)
  pop_dt[, state := abbr]
  pop_dt <- pop_dt[!is.na(state), .(state, year, population)]
  cat(sprintf("Population: %d state-years\n", nrow(pop_dt)))
} else {
  cat("WARNING: Population data not found.\n")
  pop_dt <- data.table()
}


## ============================================================
## PART D: Merge Everything into Analysis Panel
## ============================================================

cat("\n=== Merging analysis panel ===\n")

panel <- copy(panel_hcbs)

# Merge wage ratio (time-invariant treatment)
panel <- merge(panel, wage_ratio[, .(state, pca_wage, outside_wage, wage_ratio, ratio_tercile)],
               by = "state", all.x = TRUE)

# Merge COVID (by state abbreviation × month)
if (nrow(covid_monthly) > 0) {
  panel <- merge(panel, covid_monthly[, .(state, month_date, new_cases, new_deaths)],
                 by = c("state", "month_date"), all.x = TRUE)
  panel[is.na(new_cases), new_cases := 0]
  panel[is.na(new_deaths), new_deaths := 0]
}

# Merge unemployment
if (nrow(ur_monthly) > 0) {
  panel <- merge(panel, ur_monthly[, .(state, month_date, state_ur)],
                 by = c("state", "month_date"), all.x = TRUE)
}

# Merge population (by year)
if (nrow(pop_dt) > 0) {
  panel <- merge(panel, pop_dt, by = c("state", "year"), all.x = TRUE)
  # Per capita measures
  panel[population > 0, `:=`(
    covid_cases_pc = new_cases / population * 100000,
    covid_deaths_pc = new_deaths / population * 100000,
    providers_pc = n_providers / population * 100000,
    beneficiaries_pc = total_beneficiaries / population * 100000
  )]
}

# Create interaction terms for main specification
panel[, `:=`(
  wage_ratio_x_post = wage_ratio * post_covid,
  wage_ratio_x_post_arpa = wage_ratio * post_arpa
)]

# Event time relative to COVID (months since Jan 2020)
panel[, event_time := as.integer(round(difftime(month_date, as.Date("2020-01-01"), units = "days") / 30.44))]

# Numeric state for FE
panel[, state_id := as.integer(factor(state))]
panel[, month_id := as.integer(factor(month_date))]

# Year-quarter for some aggregations
panel[, yq := paste0(year, "Q", ceiling(month_num / 3))]

setorder(panel, state, month_date)

# Drop states without wage ratio
n_before <- nrow(panel)
panel <- panel[!is.na(wage_ratio)]
cat(sprintf("Dropped %d state-months without wage ratio\n", n_before - nrow(panel)))

cat(sprintf("\n=== Final analysis panel ===\n"))
cat(sprintf("Rows: %d\n", nrow(panel)))
cat(sprintf("States: %d\n", uniqueN(panel$state)))
cat(sprintf("Months: %d (%s to %s)\n",
            uniqueN(panel$month_date),
            min(panel$month_date),
            max(panel$month_date)))
cat(sprintf("Pre-COVID months: %d\n", sum(panel$post_covid == 0) / uniqueN(panel$state)))
cat(sprintf("Post-COVID months: %d\n", sum(panel$post_covid == 1) / uniqueN(panel$state)))

saveRDS(panel, file.path(DATA, "panel_analysis.rds"))
cat("Saved: panel_analysis.rds\n")

# Clean up large objects
rm(hcbs_monthly)
gc()

cat("\n=== Data cleaning complete ===\n")
