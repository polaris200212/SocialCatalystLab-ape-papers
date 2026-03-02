## ============================================================================
## 02_clean_data.R — Variable construction and panel refinement
## apep_0454: The Depleted Safety Net
## ============================================================================

source("00_packages.R")

panel <- readRDS(file.path(DATA_DIR, "panel.rds"))
state_exits <- readRDS(file.path(DATA_DIR, "state_exits.rds"))

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
# Move here from 03_main_analysis.R so it's available in the HCBS panel
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

## ---- 7. Summary statistics ----
cat("Panel summary:\n")
cat(sprintf("  States: %d\n", uniqueN(panel$state)))
cat(sprintf("  Months: %d (%s to %s)\n",
            uniqueN(panel$month_date),
            min(panel$month_date), max(panel$month_date)))
cat(sprintf("  Provider types: %s\n", paste(unique(panel$prov_type), collapse = ", ")))
cat(sprintf("  Total rows: %s\n", format(nrow(panel), big.mark = ",")))

cat("\nExit intensity by quartile:\n")
print(state_exits[, .(
  n_states = .N,
  mean_exit = round(mean(exit_rate) * 100, 1),
  mean_hcbs_exit = round(mean(hcbs_exit_rate, na.rm = TRUE) * 100, 1)
), by = exit_quartile][order(exit_quartile)])

## ---- Save ----
saveRDS(panel, file.path(DATA_DIR, "panel_clean.rds"))
cat("\n=== Data cleaning complete ===\n")
