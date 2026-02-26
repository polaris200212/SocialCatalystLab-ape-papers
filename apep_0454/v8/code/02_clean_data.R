## ============================================================================
## 02_clean_data.R — Variable construction and panel refinement
## apep_0454 v8: The Depleted Safety Net (Analytical Revision)
## ============================================================================

source("00_packages.R")

panel <- readRDS(file.path(DATA_DIR, "panel.rds"))
state_exits <- readRDS(file.path(DATA_DIR, "state_exits.rds"))

## ---- 0. Truncation (WS2: reporting lag fix) ----
cat("Saving full panel for sensitivity, truncating primary at June 2024...\n")

# Save full panel before truncation
panel_full <- copy(panel)

# Primary analysis: truncate at June 2024 (late 2024 has reporting lags)
panel <- panel[month_date <= "2024-06-01"]

cat(sprintf("Primary panel: %s rows (through %s)\n",
            format(nrow(panel), big.mark = ","), max(panel$month_date)))
cat(sprintf("Full panel: %s rows (through %s)\n",
            format(nrow(panel_full), big.mark = ","), max(panel_full$month_date)))

## ---- 0b. Handle missing unemployment data ----
# FRED API may fail; fill missing unemp_rate with state mean or 0
if ("unemp_rate" %in% names(panel)) {
  na_pct <- sum(is.na(panel$unemp_rate)) / nrow(panel) * 100
  cat(sprintf("Unemployment data: %.0f%% missing\n", na_pct))
  if (na_pct > 50) {
    cat("WARNING: >50% unemployment data missing (FRED API likely failed). Setting unemp_rate = 0.\n")
    panel[is.na(unemp_rate), unemp_rate := 0]
  } else {
    panel[is.na(unemp_rate), unemp_rate := mean(panel$unemp_rate, na.rm = TRUE)]
  }
} else {
  cat("WARNING: No unemployment data found. Creating unemp_rate = 0.\n")
  panel[, unemp_rate := 0]
}

## ---- 1. Per-beneficiary ratios and log-transform outcomes ----
panel[, `:=`(
  claims_per_bene   = total_claims / pmax(total_beneficiaries, 1),
  spending_per_bene = total_paid / pmax(total_beneficiaries, 1)
)]

panel[, `:=`(
  ln_providers       = log(pmax(n_providers, 1)),
  ln_claims          = log(pmax(total_claims, 1)),
  ln_beneficiaries   = log(pmax(total_beneficiaries, 1)),
  ln_paid            = log(pmax(total_paid, 1)),
  ln_claims_per_bene = log(pmax(claims_per_bene, 1)),
  ln_spending_per_bene = log(pmax(spending_per_bene, 1))
)]

## ---- 1b. COVID deaths per capita (for mediation analysis) ----
if ("covid_deaths" %in% names(panel) & "population" %in% names(panel)) {
  panel[, covid_deaths_pc := covid_deaths / pmax(population / 100000, 1)]
  panel[is.na(covid_deaths_pc) | is.infinite(covid_deaths_pc), covid_deaths_pc := 0]
  cat("COVID deaths per capita constructed.\n")
}

## ---- 2. Normalized outcomes (relative to Jan 2020 baseline) ----
baseline <- panel[month_date == "2020-01-01",
                  .(state, prov_type,
                    base_providers = n_providers,
                    base_claims = total_claims,
                    base_bene = total_beneficiaries,
                    base_paid = total_paid)]

panel <- merge(panel, baseline, by = c("state", "prov_type"), all.x = TRUE)

panel[, `:=`(
  idx_providers = n_providers / pmax(base_providers, 1) * 100,
  idx_claims    = total_claims / pmax(base_claims, 1) * 100,
  idx_bene      = total_beneficiaries / pmax(base_bene, 1) * 100,
  idx_paid      = total_paid / pmax(base_paid, 1) * 100
)]

## ---- 2b. Numeric indicators ----
panel[, post_covid_num := as.integer(post_covid)]
panel[, post_arpa_num := as.integer(post_arpa)]

## ---- 2c. Dense time index and broken-trend interactions (WS3) ----
# Dense-ranked time index (0, 1, 2, ...) for broken-trend model
all_months <- sort(unique(panel$month_date))
month_rank <- data.table(month_date = all_months, time_num = seq_along(all_months) - 1L)
panel <- merge(panel, month_rank, by = "month_date", all.x = TRUE)

# Broken-trend interactions: exit_rate × t, exit_rate × Post, exit_rate × Post × t
panel[, exit_x_trend := exit_rate * time_num]
panel[, exit_x_post := exit_rate * post_covid_num]
panel[, exit_x_post_trend := exit_rate * post_covid_num * time_num]

cat(sprintf("Broken-trend variables: time_num range [%d, %d], %d months\n",
            min(panel$time_num), max(panel$time_num), length(all_months)))

## ---- 3. Interaction terms for DDD ----
panel[, `:=`(
  hcbs = as.integer(prov_type == "HCBS"),
  post_covid_hcbs = as.integer(post_covid & prov_type == "HCBS"),
  post_arpa_hcbs = as.integer(post_arpa & prov_type == "HCBS"),
  post_covid_high_exit = as.integer(post_covid & high_exit),
  post_arpa_high_exit = as.integer(post_arpa & high_exit),
  hcbs_high_exit = as.integer(prov_type == "HCBS" & high_exit),
  triple_covid = as.integer(post_covid & prov_type == "HCBS" & high_exit),
  triple_arpa = as.integer(post_arpa & prov_type == "HCBS" & high_exit)
)]

# Continuous interactions
panel[, `:=`(
  exit_rate_x_post_covid = exit_rate * post_covid,
  exit_rate_x_post_arpa  = exit_rate * post_arpa,
  exit_rate_x_hcbs       = exit_rate * hcbs,
  exit_rate_x_post_covid_hcbs = exit_rate * post_covid * hcbs,
  exit_rate_x_post_arpa_hcbs  = exit_rate * post_arpa * hcbs
)]

## ---- 4. State-provider type fixed effects ----
panel[, state_prov := paste0(state, "_", prov_type)]
panel[, state_month := paste0(state, "_", month_date)]
panel[, prov_month := paste0(prov_type, "_", month_date)]

## ---- 5. Event study dummies for Part 1 (COVID onset, monthly) ----
# Bin event time: keep -24 to +57, bin endpoints
panel[, event_m_covid := pmax(-24, pmin(57, event_month_covid))]
# Reference period: month -1 (Feb 2020)
panel[, event_m_covid_fac := factor(event_m_covid)]
panel[, event_m_covid_fac := relevel(event_m_covid_fac, ref = "-1")]

## ---- 6. Event study dummies for Part 2 (ARPA onset, monthly) ----
panel[, event_m_arpa := pmax(-38, pmin(45, event_month_arpa))]
panel[, event_m_arpa_fac := factor(event_m_arpa)]
panel[, event_m_arpa_fac := relevel(event_m_arpa_fac, ref = "-1")]

## ---- 7. Clean entity-type panel (WS6) ----
cat("Cleaning entity-type panel...\n")
entity_panel <- readRDS(file.path(DATA_DIR, "entity_panel.rds"))

# Merge exit intensity
entity_panel <- merge(entity_panel,
  state_exits[, .(state, exit_rate_pre, hcbs_exit_rate_pre,
                   exit_rate_pandemic, exit_quartile, high_exit,
                   predicted_exit_rate,
                   exit_rate_indiv_pre, exit_rate_org_pre)],
  by = "state", all.x = TRUE)

# Primary exit rate
entity_panel[, exit_rate := exit_rate_pre]

# Time variables
entity_panel[, `:=`(
  post_covid = month_date >= "2020-03-01",
  post_arpa  = month_date >= "2021-04-01"
)]
entity_panel[, post_covid_num := as.integer(post_covid)]

# Log outcomes
entity_panel[, `:=`(
  ln_providers     = log(pmax(n_providers, 1)),
  ln_claims        = log(pmax(total_claims, 1)),
  ln_beneficiaries = log(pmax(total_beneficiaries, 1))
)]

# Truncate at June 2024
entity_panel <- entity_panel[month_date <= "2024-06-01"]

# Merge unemployment
unemp_data <- unique(panel[, .(state, month_date, unemp_rate)])
entity_panel <- merge(entity_panel, unemp_data, by = c("state", "month_date"), all.x = TRUE)

# Event time
entity_panel[, event_month_covid := round(as.numeric(difftime(month_date, as.Date("2020-03-01"), units = "days")) / 30.44)]
entity_panel[, event_m_covid := pmax(-24, pmin(57, event_month_covid))]

cat(sprintf("Entity panel: %d rows (%d states × %d types × %d months)\n",
            nrow(entity_panel), uniqueN(entity_panel$state),
            uniqueN(entity_panel$entity_type), uniqueN(entity_panel$month_date)))

## ---- 8. Summary statistics ----
cat("Panel summary:\n")
cat(sprintf("  States: %d\n", uniqueN(panel$state)))
cat(sprintf("  Months: %d (%s to %s)\n",
            uniqueN(panel$month_date),
            min(panel$month_date), max(panel$month_date)))
cat(sprintf("  Provider types: %s\n", paste(unique(panel$prov_type), collapse = ", ")))
cat(sprintf("  Total rows: %s\n", format(nrow(panel), big.mark = ",")))

cat("\nExit intensity by quartile (pre-period definition):\n")
print(state_exits[, .(
  n_states = .N,
  mean_exit_pre = round(mean(exit_rate_pre) * 100, 1),
  mean_hcbs_exit_pre = round(mean(hcbs_exit_rate_pre, na.rm = TRUE) * 100, 1),
  mean_exit_pandemic = round(mean(exit_rate_pandemic) * 100, 1)
), by = exit_quartile][order(exit_quartile)])

## ---- Save ----
saveRDS(panel, file.path(DATA_DIR, "panel_clean.rds"))
saveRDS(panel_full, file.path(DATA_DIR, "panel_full.rds"))
saveRDS(entity_panel, file.path(DATA_DIR, "entity_panel_clean.rds"))
cat("\n=== Data cleaning complete ===\n")
