## ============================================================================
## 03_main_analysis.R — Primary regressions for apep_0454
##
## Part 1: Pre-COVID exits × pandemic disruption (event study)
## Part 2: ARPA HCBS recovery (DDD)
## Part 3: Deaths of despair (secondary)
## ============================================================================

source("00_packages.R")

panel <- readRDS(file.path(DATA_DIR, "panel_clean.rds"))
state_exits <- readRDS(file.path(DATA_DIR, "state_exits.rds"))

## =========================================================================
## PART 1: Pre-COVID Exits × Pandemic Disruption
## =========================================================================

cat("=== PART 1: Event Study — Pre-COVID Exits × COVID Disruption ===\n\n")

## ---- 1a. Main event study: Provider counts ----
# Continuous treatment: exit_rate × event time
# Uses HCBS providers only for Part 1 (most exposed to HCBS workforce depletion)
hcbs_panel <- panel[prov_type == "HCBS"]

# Event study with continuous treatment intensity
es_providers <- feols(
  ln_providers ~ i(event_m_covid, exit_rate, ref = -1) |
    state + month_date,
  data = hcbs_panel,
  cluster = ~state
)

cat("Event study — ln(HCBS providers) × exit_rate:\n")
summary(es_providers)

## ---- 1b. Event study: Beneficiaries served ----
es_bene <- feols(
  ln_beneficiaries ~ i(event_m_covid, exit_rate, ref = -1) |
    state + month_date,
  data = hcbs_panel,
  cluster = ~state
)

cat("\nEvent study — ln(HCBS beneficiaries) × exit_rate:\n")
summary(es_bene)

## ---- 1c. Event study: Claims volume ----
es_claims <- feols(
  ln_claims ~ i(event_m_covid, exit_rate, ref = -1) |
    state + month_date,
  data = hcbs_panel,
  cluster = ~state
)

## ---- 1d. Quartile-based event study (for visual) ----
es_quartile <- feols(
  ln_providers ~ i(event_m_covid, exit_quartile, ref = -1) |
    state + month_date,
  data = hcbs_panel[!is.na(exit_quartile)],
  cluster = ~state
)

## ---- 1e. Simple DiD: Before/After COVID ----
# Convert post_covid to numeric to avoid factor-level collinearity
hcbs_panel[, post_covid_num := as.integer(post_covid)]

did_covid <- feols(
  ln_providers ~ post_covid_num:exit_rate + unemp_rate |
    state + month_date,
  data = hcbs_panel,
  cluster = ~state
)

cat("\nDiD — ln(HCBS providers), Post-COVID × Exit Rate:\n")
summary(did_covid)

## ---- 1f. IV: Shift-share instrument ----
# First stage (cross-sectional, N=51)
fs <- lm(exit_rate ~ predicted_exit_rate, data = state_exits)
fs_f <- summary(fs)$fstatistic[1]
cat(sprintf("\nFirst stage F-stat: %.1f\n", fs_f))

# Reduced form
hcbs_panel[, post_covid_pred := post_covid_num * predicted_exit_rate]
iv_providers <- feols(
  ln_providers ~ post_covid_num:predicted_exit_rate + unemp_rate |
    state + month_date,
  data = hcbs_panel,
  cluster = ~state
)

cat("\nReduced form — ln(HCBS providers), Post-COVID × Predicted Exit Rate:\n")
summary(iv_providers)

## =========================================================================
## PART 2: ARPA HCBS Recovery (DDD)
## =========================================================================

cat("\n=== PART 2: DDD — ARPA HCBS × Exit Intensity ===\n\n")

## ---- 2a. Main DDD: Provider counts ----
ddd_providers <- feols(
  ln_providers ~ post_arpa_hcbs + post_arpa_high_exit + hcbs_high_exit +
    triple_arpa + unemp_rate |
    state_prov + prov_month,
  data = panel,
  cluster = ~state
)

cat("DDD — ln(providers): Post-ARPA × HCBS × High-Exit:\n")
summary(ddd_providers)

## ---- 2b. Main DDD: Beneficiaries ----
ddd_bene <- feols(
  ln_beneficiaries ~ post_arpa_hcbs + post_arpa_high_exit + hcbs_high_exit +
    triple_arpa + unemp_rate |
    state_prov + prov_month,
  data = panel,
  cluster = ~state
)

cat("\nDDD — ln(beneficiaries): Post-ARPA × HCBS × High-Exit:\n")
summary(ddd_bene)

## ---- 2c. Continuous DDD ----
ddd_continuous <- feols(
  ln_providers ~ exit_rate_x_post_arpa_hcbs +
    exit_rate_x_post_arpa + exit_rate_x_hcbs +
    post_arpa_hcbs + unemp_rate |
    state_prov + prov_month,
  data = panel,
  cluster = ~state
)

cat("\nContinuous DDD — ln(providers): ExitRate × Post-ARPA × HCBS:\n")
summary(ddd_continuous)

## ---- 2d. ARPA event study (DDD with event time) ----
# Quarterly bins for ARPA (too many monthly dummies)
panel[, arpa_quarter := floor(event_m_arpa / 3)]
panel[, arpa_quarter := pmax(-12, pmin(15, arpa_quarter))]

es_arpa_ddd <- feols(
  ln_providers ~ i(arpa_quarter, hcbs_high_exit, ref = -1) + unemp_rate |
    state_prov + prov_month,
  data = panel[!is.na(arpa_quarter)],
  cluster = ~state
)

## =========================================================================
## PART 3: Deaths of Despair (Secondary)
## =========================================================================

cat("\n=== PART 3: Deaths of Despair (Secondary) ===\n\n")

# Collapse to state × month (not by provider type)
state_month <- panel[prov_type == "HCBS", .(
  state, month_date, exit_rate, high_exit, post_covid,
  covid_deaths, unemp_rate, population, median_income,
  poverty_rate, pct_black, predicted_exit_rate,
  event_m_covid = event_month_covid
)] |> unique(by = c("state", "month_date"))

if ("overdose_deaths" %in% names(panel)) {
  od_merge <- panel[prov_type == "HCBS", .(state, month_date, overdose_deaths)] |>
    unique(by = c("state", "month_date"))
  state_month <- merge(state_month, od_merge, by = c("state", "month_date"), all.x = TRUE)
}

# COVID deaths per capita
state_month[, covid_deaths_pc := covid_deaths / (population / 100000)]

# Overdose deaths per capita (if available)
if ("overdose_deaths" %in% names(state_month)) {
  state_month[, od_deaths_pc := overdose_deaths / (population / 100000)]

  # Event study: overdose deaths × exit rate
  es_overdose <- feols(
    od_deaths_pc ~ i(event_m_covid, exit_rate, ref = -1) |
      state + month_date,
    data = state_month[!is.na(od_deaths_pc) & !is.infinite(od_deaths_pc)],
    cluster = ~state
  )
  cat("Event study — overdose deaths per 100k × exit rate:\n")
  summary(es_overdose)
} else {
  cat("Overdose data not available. Skipping Part 3 overdose analysis.\n")
  es_overdose <- NULL
}

# COVID deaths × exit rate (descriptive, not causal)
es_covid_deaths <- feols(
  covid_deaths_pc ~ i(event_m_covid, exit_rate, ref = -1) |
    state + month_date,
  data = state_month[!is.na(covid_deaths_pc) & !is.infinite(covid_deaths_pc) &
                       month_date >= "2020-01-01"],
  cluster = ~state
)

## ---- Save results ----
results <- list(
  # Part 1
  es_providers = es_providers,
  es_bene = es_bene,
  es_claims = es_claims,
  es_quartile = es_quartile,
  did_covid = did_covid,
  iv_providers = iv_providers,
  # Part 2
  ddd_providers = ddd_providers,
  ddd_bene = ddd_bene,
  ddd_continuous = ddd_continuous,
  es_arpa_ddd = es_arpa_ddd,
  # Part 3
  es_overdose = es_overdose,
  es_covid_deaths = es_covid_deaths,
  # Data
  state_exits = state_exits,
  first_stage = fs
)

saveRDS(results, file.path(DATA_DIR, "main_results.rds"))

cat("\n=== Main analysis complete ===\n")
