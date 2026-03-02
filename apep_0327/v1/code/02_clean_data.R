## ============================================================================
## 02_clean_data.R — Build state × month panel, treatment variables
## APEP-0326: State Minimum Wage Increases and the HCBS Provider Supply Crisis
## ============================================================================

source("00_packages.R")

## ---- Load saved data ----
mw_data <- readRDS(file.path(DATA, "mw_panel.rds"))
pop_data <- readRDS(file.path(DATA, "pop_data.rds"))
qcew_data <- readRDS(file.path(DATA, "qcew_data.rds"))
unemp_data <- readRDS(file.path(DATA, "unemp_data.rds"))

tmsis_path <- file.path(SHARED_DATA, "tmsis.parquet")
tmsis_ds <- open_dataset(tmsis_path)

nppes_path <- file.path(SHARED_DATA, "nppes_extract.parquet")
nppes <- as.data.table(read_parquet(nppes_path))
nppes[, npi := as.character(npi)]

## ========================================================================
## 1. BUILD NPI → STATE MAPPING
## ========================================================================

cat("Building NPI → state mapping...\n")
npi_state <- nppes[!is.na(state) & state != "" & nchar(state) == 2,
                    .(npi, state, entity_type, sole_prop)]
cat(sprintf("NPI-state map: %s NPIs\n", format(nrow(npi_state), big.mark = ",")))

## ========================================================================
## 2. AGGREGATE T-MSIS BY BILLING NPI × MONTH × CODE CATEGORY
## ========================================================================

cat("Aggregating T-MSIS by billing NPI × month × code category (Arrow)...\n")
cat("This may take several minutes...\n")

# Classify HCPCS codes and aggregate
provider_monthly <- tmsis_ds |>
  mutate(
    hcpcs_prefix = substr(HCPCS_CODE, 1, 1),
    is_hcbs = hcpcs_prefix %in% c("T", "H", "S"),
    year = as.integer(substr(CLAIM_FROM_MONTH, 1, 4)),
    month_num = as.integer(substr(CLAIM_FROM_MONTH, 6, 7))
  ) |>
  group_by(BILLING_PROVIDER_NPI_NUM, year, month_num, is_hcbs) |>
  summarize(
    total_paid = sum(TOTAL_PAID, na.rm = TRUE),
    total_claims = sum(TOTAL_CLAIMS, na.rm = TRUE),
    total_benes = sum(TOTAL_UNIQUE_BENEFICIARIES, na.rm = TRUE),
    .groups = "drop"
  ) |>
  collect() |>
  as.data.table()

setnames(provider_monthly, "BILLING_PROVIDER_NPI_NUM", "billing_npi")
cat(sprintf("Provider-monthly: %s rows\n", format(nrow(provider_monthly), big.mark = ",")))

## ---- Join state from NPPES ----
provider_monthly <- merge(provider_monthly, npi_state,
                          by.x = "billing_npi", by.y = "npi",
                          all.x = TRUE)
cat(sprintf("NPPES match rate: %.1f%%\n",
            100 * mean(!is.na(provider_monthly$state))))

# Drop unmatched and territories
provider_monthly <- provider_monthly[!is.na(state) & state %in% state_fips$state_abbr]

## ========================================================================
## 3. BUILD STATE × MONTH PANELS
## ========================================================================

cat("Building state × month panels...\n")

# --- Panel A: HCBS providers (T/H/S codes) ---
hcbs_panel <- provider_monthly[is_hcbs == TRUE, .(
  n_providers = uniqueN(billing_npi),
  total_paid = sum(total_paid),
  total_claims = sum(total_claims),
  total_benes = sum(total_benes),
  n_individual = uniqueN(billing_npi[entity_type == "1"]),
  n_org = uniqueN(billing_npi[entity_type == "2"]),
  n_sole_prop = uniqueN(billing_npi[sole_prop == "Y"])
), by = .(state, year, month_num)]

# --- Panel B: Non-HCBS Medicaid providers (CPT codes — placebo) ---
nonhcbs_panel <- provider_monthly[is_hcbs == FALSE, .(
  n_providers_nonhcbs = uniqueN(billing_npi),
  total_paid_nonhcbs = sum(total_paid),
  total_benes_nonhcbs = sum(total_benes)
), by = .(state, year, month_num)]

# --- Combine panels ---
panel <- merge(hcbs_panel, nonhcbs_panel,
               by = c("state", "year", "month_num"), all = TRUE)

# Create date variable
panel[, month_date := as.Date(sprintf("%d-%02d-01", year, month_num))]
panel[, time_period := year * 12 + month_num]  # numeric time for DiD

## ========================================================================
## 4. PROVIDER ENTRY/EXIT
## ========================================================================

cat("Computing provider entry and exit rates...\n")

# For each state × month: identify new NPIs (entry) and disappeared NPIs (exit)
hcbs_providers <- provider_monthly[is_hcbs == TRUE,
                                    .(state, billing_npi, year, month_num)]
hcbs_providers[, time_period := year * 12 + month_num]
setorder(hcbs_providers, state, billing_npi, time_period)

# First and last appearance of each NPI in each state
npi_tenure <- hcbs_providers[, .(
  first_period = min(time_period),
  last_period = max(time_period)
), by = .(state, billing_npi)]

# Entry: NPI's first appearance in a state-month
entries <- npi_tenure[, .(
  n_entries = .N
), by = .(state, first_period)]
setnames(entries, "first_period", "time_period")

# Exit: NPI's last appearance (only if last_period < max observed period)
max_period <- max(hcbs_providers$time_period)
exits <- npi_tenure[last_period < max_period, .(
  n_exits = .N
), by = .(state, last_period)]
setnames(exits, "last_period", "time_period")

# Merge entry/exit into panel
panel <- merge(panel, entries,
               by.x = c("state", "time_period"), by.y = c("state", "time_period"),
               all.x = TRUE)
panel <- merge(panel, exits,
               by.x = c("state", "time_period"), by.y = c("state", "time_period"),
               all.x = TRUE)
panel[is.na(n_entries), n_entries := 0]
panel[is.na(n_exits), n_exits := 0]

# Compute rates
panel[, entry_rate := n_entries / n_providers]
panel[, exit_rate := n_exits / n_providers]
panel[, net_entry_rate := (n_entries - n_exits) / n_providers]

## ========================================================================
## 5. MERGE TREATMENT AND CONTROLS
## ========================================================================

cat("Merging treatment and control variables...\n")

# Minimum wage (annual — assign to all months in that year)
panel <- merge(panel, mw_data[, .(state, year, min_wage, log_mw, above_federal,
                                   mw_premium, first_treat_year)],
               by = c("state", "year"), all.x = TRUE)

# Population
panel <- merge(panel, pop_data[, .(state_abbr, year, population)],
               by.x = c("state", "year"), by.y = c("state_abbr", "year"),
               all.x = TRUE)

# Unemployment
panel <- merge(panel, unemp_data,
               by.x = c("state", "year"), by.y = c("state", "year"),
               all.x = TRUE)

# QCEW healthcare employment
if (nrow(qcew_data) > 0) {
  panel <- merge(panel, qcew_data[, .(state_abbr, year, hc_employment, hc_avg_wage)],
                 by.x = c("state", "year"), by.y = c("state_abbr", "year"),
                 all.x = TRUE)
}

## ========================================================================
## 6. CONSTRUCT ANALYSIS VARIABLES
## ========================================================================

cat("Constructing analysis variables...\n")

# Log outcomes
panel[n_providers > 0, log_providers := log(n_providers)]
panel[total_benes > 0, log_benes := log(total_benes)]
panel[n_individual > 0, log_individual := log(n_individual)]
panel[n_org > 0, log_org := log(n_org)]

# Per-capita measures
panel[population > 0, providers_per_100k := n_providers / population * 100000]
panel[population > 0, benes_per_100k := total_benes / population * 100000]

# Spending per beneficiary
panel[total_benes > 0, paid_per_bene := total_paid / total_benes]

# Restrict to 2018-2023 analysis period: T-MSIS reporting lags make 2024 unreliable
panel <- panel[year <= 2023]

# For the primary analysis, use ANNUAL data (CS-DiD works better with annual)
# Exclude 2024 entirely — even Jan-Oct 2024 is partial year and contaminated
annual_panel <- panel[year <= 2023, .(
  n_providers = mean(n_providers, na.rm = TRUE),
  total_benes = sum(total_benes, na.rm = TRUE),
  total_paid = sum(total_paid, na.rm = TRUE),
  n_individual = mean(n_individual, na.rm = TRUE),
  n_org = mean(n_org, na.rm = TRUE),
  n_entries = sum(n_entries, na.rm = TRUE),
  n_exits = sum(n_exits, na.rm = TRUE),
  n_providers_nonhcbs = mean(n_providers_nonhcbs, na.rm = TRUE)
), by = .(state, year, min_wage, log_mw, above_federal, mw_premium,
          first_treat_year, population, unemp_rate)]

annual_panel[n_providers > 0, log_providers := log(n_providers)]
annual_panel[total_benes > 0, log_benes := log(total_benes)]
annual_panel[n_individual > 0, log_individual := log(n_individual)]
annual_panel[n_org > 0, log_org := log(n_org)]
annual_panel[n_providers_nonhcbs > 0, log_providers_nonhcbs := log(n_providers_nonhcbs)]
annual_panel[population > 0, providers_per_100k := n_providers / population * 100000]
annual_panel[n_providers > 0, entry_rate := n_entries / (n_providers * 12)]
annual_panel[n_providers > 0, exit_rate := n_exits / (n_providers * 12)]

# State numeric ID for CS-DiD
annual_panel[, state_id := as.integer(factor(state))]

## ========================================================================
## 7. DDD PANEL — Stack HCBS and non-HCBS
## ========================================================================

# CS-DiD cohort variable — REVISED DEFINITION
# Since most states were already above $7.25 in 2018,
# binary above/below federal is not useful for staggered DiD.
# Instead, define treatment as: first year of a substantial MW increase
# (≥$0.50 over prior year) during the sample period.
mw_increases <- mw_data[order(state, year)]
mw_increases[, mw_change := min_wage - shift(min_wage, 1), by = state]
mw_increases[year == 2018, mw_change := 0]

# First year with ≥$0.50 increase
cohort_new <- mw_increases[mw_change >= 0.50,
                            .(first_treat_year_new = min(year)), by = state]
all_states_mw <- unique(mw_data$state)
no_increase_states <- setdiff(all_states_mw, cohort_new$state)
cohort_no <- data.table(state = no_increase_states, first_treat_year_new = 0L)
cohort_combined <- rbind(cohort_new, cohort_no)

# Update annual panel with revised cohort
annual_panel <- merge(annual_panel, cohort_combined, by = "state", all.x = TRUE)
annual_panel[!is.na(first_treat_year_new), first_treat_year := first_treat_year_new]
annual_panel[, first_treat_year_new := NULL]

cat("Revised treatment cohorts (first year of ≥$0.50 MW increase):\n")
print(annual_panel[, .N, by = first_treat_year][order(first_treat_year)])

# Reassign state_id
annual_panel[, state_id := as.integer(factor(state))]

cat("Building DDD (triple-diff) panel...\n")

# HCBS providers
ddd_hcbs <- annual_panel[, .(state, year, state_id, first_treat_year, min_wage, log_mw,
                              n_prov = n_providers, log_prov = log_providers)]
ddd_hcbs[, hcbs := 1L]

# Non-HCBS providers
ddd_nonhcbs <- annual_panel[, .(state, year, state_id, first_treat_year, min_wage, log_mw,
                                 n_prov = n_providers_nonhcbs, log_prov = log_providers_nonhcbs)]
ddd_nonhcbs[, hcbs := 0L]

ddd_panel <- rbind(ddd_hcbs, ddd_nonhcbs)
ddd_panel[, unit_id := paste0(state, "_", hcbs)]
ddd_panel[, unit_num := as.integer(factor(unit_id))]

## ========================================================================
## 8. SAVE ANALYSIS PANELS
## ========================================================================

saveRDS(panel, file.path(DATA, "panel_monthly.rds"))
saveRDS(annual_panel, file.path(DATA, "panel_annual.rds"))
saveRDS(ddd_panel, file.path(DATA, "panel_ddd.rds"))

cat("\n=== Panel construction complete ===\n")
cat(sprintf("Monthly panel: %d state-months (%d states × %d months)\n",
            nrow(panel), uniqueN(panel$state), uniqueN(panel$month_date)))
cat(sprintf("Annual panel: %d state-years (%d states × %d years)\n",
            nrow(annual_panel), uniqueN(annual_panel$state), uniqueN(annual_panel$year)))
cat(sprintf("DDD panel: %d unit-years\n", nrow(ddd_panel)))
cat(sprintf("Treatment cohorts:\n"))
print(annual_panel[, .N, by = first_treat_year][order(first_treat_year)])
