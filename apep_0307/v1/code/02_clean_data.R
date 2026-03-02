## ============================================================================
## 02_clean_data.R — Build state × month DiD panel from T-MSIS + NPPES
## Focus: HCBS provider outcomes for unwinding analysis
## Uses Arrow lazy evaluation to handle 227M rows
## ============================================================================

source("00_packages.R")
library(dplyr)  # Required for Arrow dplyr interface (collect, mutate, etc.)

## ---- 1. Load NPPES extract (state assignment) ----
cat("Loading NPPES extract...\n")
nppes <- as.data.table(read_parquet(file.path(DATA, "nppes_extract.parquet")))
nppes[, npi := as.character(npi)]

# Keep relevant columns for NPI → state mapping
npi_state <- nppes[!is.na(state) & state != "" & nchar(state) == 2,
                    .(npi, state, entity_type, taxonomy_1, sole_prop,
                      parent_org_tin, enumeration_date, deactivation_date)]
cat(sprintf("  NPI-state mapping: %s NPIs in %d states\n",
    format(nrow(npi_state), big.mark=","), uniqueN(npi_state$state)))

# Restrict to US states + DC (drop territories, military)
us_states <- c(state.abb, "DC")
npi_state <- npi_state[state %in% us_states]
cat(sprintf("  After US state filter: %s NPIs\n",
    format(nrow(npi_state), big.mark=",")))

## ---- 2. Open T-MSIS and build state × service_type × month panel ----
cat("Opening T-MSIS Parquet...\n")
tmsis_ds <- open_dataset(file.path(DATA, "tmsis_full.parquet"))

# Classify HCPCS into service types and compute state-month aggregates
# Strategy: join NPI→state via Arrow, then aggregate
# Arrow supports semi-joins, so we filter to US-state NPIs

cat("Building state × service_type × month panel via Arrow...\n")
cat("  This processes 227M rows — may take a few minutes...\n")

# Step 2a: Provider × month summary (HCBS vs non-HCBS)
# Arrow can't do NPI lookups, so we collect provider-month first, then join
provider_month <- tmsis_ds |>
  mutate(
    hcpcs_prefix = substr(HCPCS_CODE, 1, 1),
    is_hcbs = hcpcs_prefix %in% c("T", "H", "S")
  ) |>
  group_by(BILLING_PROVIDER_NPI_NUM, CLAIM_FROM_MONTH, is_hcbs) |>
  summarize(
    total_paid = sum(TOTAL_PAID, na.rm = TRUE),
    total_claims = sum(TOTAL_CLAIMS, na.rm = TRUE),
    total_beneficiaries = sum(TOTAL_UNIQUE_BENEFICIARIES, na.rm = TRUE),
    .groups = "drop"
  ) |>
  collect() |>
  as.data.table()

setnames(provider_month, "BILLING_PROVIDER_NPI_NUM", "billing_npi")
cat(sprintf("  Provider × month × HCBS panel: %s rows\n",
    format(nrow(provider_month), big.mark=",")))

# Step 2b: Join state from NPPES
provider_month <- merge(provider_month,
                         npi_state[, .(npi, state, entity_type, taxonomy_1,
                                       sole_prop, parent_org_tin)],
                         by.x = "billing_npi", by.y = "npi",
                         all.x = FALSE)  # inner join: only matched NPIs
cat(sprintf("  After NPPES join: %s rows (%d states)\n",
    format(nrow(provider_month), big.mark=","),
    uniqueN(provider_month$state)))

# Date columns
provider_month[, month_date := as.Date(paste0(CLAIM_FROM_MONTH, "-01"))]
provider_month[, year := year(month_date)]
provider_month[, month_num := month(month_date)]

# Provider type classification
provider_month[, provider_type := fifelse(entity_type == 1, "Individual", "Organization")]
provider_month[, service_type := fifelse(is_hcbs, "HCBS", "Non-HCBS")]

## ---- 3. State × service_type × month panel ----
cat("Aggregating to state × service_type × month...\n")

state_month <- provider_month[, .(
  n_providers   = uniqueN(billing_npi),
  total_paid    = sum(total_paid),
  total_claims  = sum(total_claims),
  total_benef   = sum(total_beneficiaries),
  n_individual  = uniqueN(billing_npi[provider_type == "Individual"]),
  n_org         = uniqueN(billing_npi[provider_type == "Organization"]),
  n_sole_prop   = uniqueN(billing_npi[sole_prop == "Y"])
), by = .(state, CLAIM_FROM_MONTH, month_date, service_type)]

setorder(state_month, state, service_type, month_date)
cat(sprintf("  State × service_type × month panel: %s rows\n",
    format(nrow(state_month), big.mark=",")))

## ---- 4. Provider-level entry/exit tracking (HCBS only) ----
cat("Computing HCBS provider entry/exit by state...\n")

hcbs_provider <- provider_month[is_hcbs == TRUE, .(
  first_month = min(CLAIM_FROM_MONTH),
  last_month  = max(CLAIM_FROM_MONTH),
  active_months = uniqueN(CLAIM_FROM_MONTH),
  total_paid  = sum(total_paid),
  total_claims = sum(total_claims)
), by = .(billing_npi, state, entity_type, provider_type, sole_prop, parent_org_tin)]

hcbs_provider[, first_date := as.Date(paste0(first_month, "-01"))]
hcbs_provider[, last_date := as.Date(paste0(last_month, "-01"))]

cat(sprintf("  HCBS providers: %s unique NPIs\n",
    format(nrow(hcbs_provider), big.mark=",")))

# Entry by state × month
hcbs_entry <- hcbs_provider[, .N, by = .(state, first_month)]
setnames(hcbs_entry, c("state", "month", "new_hcbs_providers"))
hcbs_entry[, month_date := as.Date(paste0(month, "-01"))]

# Exit by state × month (provider whose last billing was this month)
# Exclude Dec 2024 (right-censored)
max_month_str <- max(hcbs_provider$last_month)
hcbs_exit <- hcbs_provider[last_month < max_month_str, .N, by = .(state, last_month)]
setnames(hcbs_exit, c("state", "month", "exiting_hcbs_providers"))
hcbs_exit[, month_date := as.Date(paste0(month, "-01"))]

## ---- 5. Market concentration (HHI by state × quarter) ----
cat("Computing HCBS market concentration (HHI)...\n")

# HHI based on parent_org_tin (firm-level)
# Providers without parent_org_tin are treated as individual firms
hcbs_firm_qtr <- provider_month[is_hcbs == TRUE, .(
  firm_paid = sum(total_paid)
), by = .(state, year, quarter = ceiling(month_num / 3),
          firm_id = fifelse(is.na(parent_org_tin) | parent_org_tin == "",
                            billing_npi, parent_org_tin))]

# Compute HHI per state-quarter
hcbs_hhi <- hcbs_firm_qtr[, {
  total <- sum(firm_paid)
  shares <- firm_paid / total
  .(hhi = sum(shares^2) * 10000,
    n_firms = .N,
    top_firm_share = max(shares))
}, by = .(state, year, quarter)]

hcbs_hhi[, month_date := as.Date(paste0(year, "-", sprintf("%02d", (quarter - 1) * 3 + 2), "-01"))]

cat(sprintf("  HHI computed: %s state-quarters\n",
    format(nrow(hcbs_hhi), big.mark=",")))

## ---- 6. Merge treatment timing ----
cat("Merging treatment timing...\n")
treatment <- readRDS(file.path(DATA, "treatment_timing.rds"))

# HCBS-only state-month panel for DiD
hcbs_state_month <- state_month[service_type == "HCBS"]

# Merge treatment timing
hcbs_state_month <- merge(hcbs_state_month, treatment,
                           by = "state", all.x = TRUE)

# Time variable (months since Jan 2018)
hcbs_state_month[, time_period := as.integer(difftime(month_date,
                                                       as.Date("2018-01-01"),
                                                       units = "days")) %/% 30 + 1]

# Post-treatment indicator
hcbs_state_month[, post := as.integer(month_date >= unwinding_date)]

# Relative time to treatment
hcbs_state_month[, rel_time := as.integer(difftime(month_date, unwinding_date,
                                                    units = "days")) %/% 30]

# Merge entry/exit
hcbs_state_month <- merge(hcbs_state_month,
                           hcbs_entry[, .(state, month_date, new_hcbs_providers)],
                           by = c("state", "month_date"), all.x = TRUE)
hcbs_state_month <- merge(hcbs_state_month,
                           hcbs_exit[, .(state, month_date, exiting_hcbs_providers)],
                           by = c("state", "month_date"), all.x = TRUE)

# Fill NA entry/exit with 0
hcbs_state_month[is.na(new_hcbs_providers), new_hcbs_providers := 0]
hcbs_state_month[is.na(exiting_hcbs_providers), exiting_hcbs_providers := 0]

# Per-capita outcomes (merge ACS pop)
acs_pop <- fread(file.path(DATA, "acs_state_pop.csv"))
if ("state_abbr" %in% names(acs_pop)) {
  setnames(acs_pop, "state_abbr", "state_acs")
} else if ("state" %in% names(acs_pop)) {
  setnames(acs_pop, "state", "state_acs")
}
# Check what columns we have
cat("ACS columns:", paste(names(acs_pop), collapse=", "), "\n")

# Log outcomes
hcbs_state_month[, log_providers := log(n_providers + 1)]
hcbs_state_month[, log_paid := log(total_paid + 1)]
hcbs_state_month[, log_claims := log(total_claims + 1)]
hcbs_state_month[, exit_rate := exiting_hcbs_providers / (n_providers + 1)]
hcbs_state_month[, entry_rate := new_hcbs_providers / (n_providers + 1)]
hcbs_state_month[, net_entry := new_hcbs_providers - exiting_hcbs_providers]

setorder(hcbs_state_month, state, month_date)

# Also build non-HCBS panel for placebo test
nonhcbs_state_month <- state_month[service_type == "Non-HCBS"]
nonhcbs_state_month <- merge(nonhcbs_state_month, treatment,
                              by = "state", all.x = TRUE)
nonhcbs_state_month[, time_period := as.integer(difftime(month_date,
                                                          as.Date("2018-01-01"),
                                                          units = "days")) %/% 30 + 1]
nonhcbs_state_month[, post := as.integer(month_date >= unwinding_date)]
nonhcbs_state_month[, rel_time := as.integer(difftime(month_date, unwinding_date,
                                                       units = "days")) %/% 30]
nonhcbs_state_month[, log_providers := log(n_providers + 1)]
nonhcbs_state_month[, log_paid := log(total_paid + 1)]

## ---- 7. Save analysis panels ----
cat("Saving analysis panels...\n")
saveRDS(hcbs_state_month, file.path(DATA, "hcbs_state_month.rds"))
saveRDS(nonhcbs_state_month, file.path(DATA, "nonhcbs_state_month.rds"))
saveRDS(hcbs_provider, file.path(DATA, "hcbs_provider.rds"))
saveRDS(hcbs_hhi, file.path(DATA, "hcbs_hhi.rds"))
saveRDS(hcbs_entry, file.path(DATA, "hcbs_entry.rds"))
saveRDS(hcbs_exit, file.path(DATA, "hcbs_exit.rds"))
saveRDS(provider_month, file.path(DATA, "provider_month.rds"))

cat("\n=== PANEL SUMMARY ===\n")
cat(sprintf("HCBS state-month panel: %d obs (%d states × %d months)\n",
    nrow(hcbs_state_month), uniqueN(hcbs_state_month$state),
    uniqueN(hcbs_state_month$month_date)))
cat(sprintf("Non-HCBS state-month panel: %d obs (placebo)\n",
    nrow(nonhcbs_state_month)))
cat(sprintf("HCBS providers: %s\n", format(nrow(hcbs_provider), big.mark=",")))
cat(sprintf("HHI state-quarters: %d\n", nrow(hcbs_hhi)))
cat(sprintf("Treatment cohorts: %s\n",
    paste(treatment[, .N, by=unwinding_month][order(unwinding_month),
          paste0(unwinding_month, " (n=", N, ")")], collapse=", ")))

cat("\n=== Clean complete ===\n")
