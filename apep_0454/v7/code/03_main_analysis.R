## ============================================================================
## 03_main_analysis.R — Primary regressions for apep_0454 v2
##
## Part 1: Pre-COVID exits × pandemic disruption (event study + static DiD)
## Part 1b: Mediation analysis (bad control comparison)
## Part 2: Beneficiary-side outcomes (the "so what")
## Part 3: Vulnerability interaction (exit_rate × COVID severity)
## Part 4: ARPA HCBS recovery (DDD, exploratory)
## Part 5: Deaths of despair (secondary)
## ============================================================================

source("00_packages.R")

panel <- readRDS(file.path(DATA_DIR, "panel_clean.rds"))
state_exits <- readRDS(file.path(DATA_DIR, "state_exits.rds"))

## =========================================================================
## PART 1: Pre-COVID Exits × Pandemic Disruption
## =========================================================================

cat("=== PART 1: Event Study — Pre-COVID Exits × COVID Disruption ===\n\n")

hcbs_panel <- panel[prov_type == "HCBS"]

## ---- 1a. Main event study: Provider counts ----
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

## ---- 1d. Event study: Claims per beneficiary ----
es_claims_per_bene <- feols(
  ln_claims_per_bene ~ i(event_m_covid, exit_rate, ref = -1) |
    state + month_date,
  data = hcbs_panel,
  cluster = ~state
)

cat("\nEvent study — ln(claims/beneficiary) × exit_rate:\n")
summary(es_claims_per_bene)

## ---- 1e. Event study: Spending per beneficiary ----
es_spending_per_bene <- feols(
  ln_spending_per_bene ~ i(event_m_covid, exit_rate, ref = -1) |
    state + month_date,
  data = hcbs_panel,
  cluster = ~state
)

## ---- 1f. Quartile-based event study (for visual) ----
es_quartile <- feols(
  ln_providers ~ i(event_m_covid, exit_quartile, ref = -1) |
    state + month_date,
  data = hcbs_panel[!is.na(exit_quartile)],
  cluster = ~state
)

## ---- 1g. Simple DiD: Before/After COVID (MAIN spec — no COVID controls) ----
hcbs_panel[, post_covid_num := as.integer(post_covid)]

did_covid <- feols(
  ln_providers ~ post_covid_num:exit_rate + unemp_rate |
    state + month_date,
  data = hcbs_panel,
  cluster = ~state
)

cat("\nDiD — ln(HCBS providers), Post-COVID × Exit Rate (MAIN, no COVID controls):\n")
summary(did_covid)

## ---- 1h. IV: Shift-share instrument ----
fs <- lm(exit_rate ~ predicted_exit_rate, data = state_exits)
fs_f <- summary(fs)$fstatistic[1]
cat(sprintf("\nFirst stage F-stat: %.1f\n", fs_f))

hcbs_panel[, post_covid_pred := post_covid_num * predicted_exit_rate]
iv_providers <- feols(
  ln_providers ~ post_covid_num:predicted_exit_rate + unemp_rate |
    state + month_date,
  data = hcbs_panel,
  cluster = ~state
)

cat("\nReduced form — ln(HCBS providers), Post-COVID × Predicted Exit Rate:\n")
summary(iv_providers)

## ---- 1i. Pre-trend joint F-test ----
# Extract pre-period coefficients from event study
es_coefs <- coeftable(es_providers)
pre_coefs <- rownames(es_coefs)[grepl("event_m_covid::-", rownames(es_coefs))]
pre_coefs <- pre_coefs[pre_coefs != "event_m_covid::-1:exit_rate"]  # exclude ref period
if (length(pre_coefs) > 0) {
  pre_test <- wald(es_providers, pre_coefs)
  cat(sprintf("\nPre-trend joint F-test: F=%.2f, p=%.3f\n", pre_test$stat, pre_test$p))
} else {
  pre_test <- list(stat = NA, p = NA)
  cat("\nCould not compute pre-trend F-test.\n")
}


## ---- 1j. Broken-trend specification (state-specific linear trends) ----
cat("\n=== Broken-trend specification ===\n")

# Add numeric time variable for state trends
hcbs_panel[, time_num := as.numeric(month_date - min(month_date)) / 30]

did_broken_trend <- feols(
  ln_providers ~ post_covid_num:exit_rate + unemp_rate |
    state[time_num] + month_date,
  data = hcbs_panel,
  cluster = ~state
)

cat("Broken-trend — ln(HCBS providers), with state-specific linear trends:\n")
summary(did_broken_trend)

bt_ct <- coeftable(did_broken_trend)
bt_p <- bt_ct["post_covid_num:exit_rate", "Pr(>|t|)"]
cat(sprintf("\nBroken-trend coef: %.4f (SE=%.4f, p=%.4f)\n",
            coef(did_broken_trend)["post_covid_num:exit_rate"],
            se(did_broken_trend)["post_covid_num:exit_rate"],
            bt_p))

## ---- 1k. HCBS-specific exit rate as treatment ----
cat("\n=== HCBS-specific exit rate ===\n")

did_hcbs_specific <- feols(
  ln_providers ~ post_covid_num:hcbs_exit_rate + unemp_rate |
    state + month_date,
  data = hcbs_panel,
  cluster = ~state
)

cat("HCBS-specific exit rate — ln(HCBS providers):\n")
summary(did_hcbs_specific)

# Same for beneficiaries
did_bene_hcbs_specific <- feols(
  ln_beneficiaries ~ post_covid_num:hcbs_exit_rate + unemp_rate |
    state + month_date,
  data = hcbs_panel,
  cluster = ~state
)

cat("\nHCBS-specific exit rate — ln(beneficiaries):\n")
summary(did_bene_hcbs_specific)

# Non-HCBS with HCBS-specific exit rate (falsification)
non_hcbs_panel <- panel[prov_type == "Non-HCBS"]
non_hcbs_panel[, post_covid_num := as.integer(post_covid)]
did_non_hcbs_hcbs_exit <- feols(
  ln_providers ~ post_covid_num:hcbs_exit_rate + unemp_rate |
    state + month_date,
  data = non_hcbs_panel,
  cluster = ~state
)

cat("\nHCBS exit rate on non-HCBS providers (falsification):\n")
summary(did_non_hcbs_hcbs_exit)

## ---- 1l. Formal HCBS vs non-HCBS differential test ----
cat("\n=== Formal HCBS vs non-HCBS differential ===\n")

panel[, post_covid_num := as.integer(post_covid)]
pooled_hcbs_test <- feols(
  ln_providers ~ post_covid_num:hcbs_exit_rate +
    post_covid_num:hcbs_exit_rate:hcbs + unemp_rate |
    state_prov + prov_month,
  data = panel,
  cluster = ~state
)

cat("Pooled: HCBS exit rate × post-COVID, with HCBS differential:\n")
summary(pooled_hcbs_test)


## =========================================================================
## PART 1b: Mediation Analysis — Bad Control Comparison
## =========================================================================

cat("\n=== PART 1b: Mediation Analysis — COVID Deaths as Mediator ===\n\n")

## Spec 1 (MAIN): No COVID controls — total effect of theta_s
## (This is did_covid above — same result, just rename for clarity)
did_no_covid <- did_covid

## Spec 2: + COVID deaths per capita — direct effect conditional on severity
did_with_covid <- feols(
  ln_providers ~ post_covid_num:exit_rate + unemp_rate + covid_deaths_pc |
    state + month_date,
  data = hcbs_panel[!is.na(covid_deaths_pc)],
  cluster = ~state
)

cat("With COVID deaths control:\n")
summary(did_with_covid)

## Spec 3: + COVID deaths + stringency — full mediation controls
if ("stringency" %in% names(hcbs_panel)) {
  did_full_controls <- feols(
    ln_providers ~ post_covid_num:exit_rate + unemp_rate +
      covid_deaths_pc + stringency |
      state + month_date,
    data = hcbs_panel[!is.na(covid_deaths_pc) & !is.na(stringency)],
    cluster = ~state
  )
  cat("\nWith COVID deaths + stringency controls:\n")
  summary(did_full_controls)
} else {
  did_full_controls <- NULL
  cat("Stringency variable not available; skipping Spec 3.\n")
}

# Compare coefficients
cat("\n--- MEDIATION COMPARISON ---\n")
cat(sprintf("Spec 1 (no COVID controls): %.4f (SE=%.4f)\n",
            coef(did_no_covid)["post_covid_num:exit_rate"],
            se(did_no_covid)["post_covid_num:exit_rate"]))
cat(sprintf("Spec 2 (+ COVID deaths):    %.4f (SE=%.4f)\n",
            coef(did_with_covid)["post_covid_num:exit_rate"],
            se(did_with_covid)["post_covid_num:exit_rate"]))
if (!is.null(did_full_controls)) {
  cat(sprintf("Spec 3 (+ deaths + string): %.4f (SE=%.4f)\n",
              coef(did_full_controls)["post_covid_num:exit_rate"],
              se(did_full_controls)["post_covid_num:exit_rate"]))
}


## =========================================================================
## PART 2: Beneficiary-Side Outcomes (the "so what")
## =========================================================================

cat("\n=== PART 2: Beneficiary-Side Outcomes ===\n\n")

## ---- 2a. Static DiD: Beneficiaries ----
did_bene <- feols(
  ln_beneficiaries ~ post_covid_num:exit_rate + unemp_rate |
    state + month_date,
  data = hcbs_panel,
  cluster = ~state
)

cat("DiD — ln(beneficiaries), Post-COVID × Exit Rate:\n")
summary(did_bene)

## ---- 2b. Static DiD: Claims per beneficiary ----
did_claims_per_bene <- feols(
  ln_claims_per_bene ~ post_covid_num:exit_rate + unemp_rate |
    state + month_date,
  data = hcbs_panel,
  cluster = ~state
)

cat("\nDiD — ln(claims/beneficiary), Post-COVID × Exit Rate:\n")
summary(did_claims_per_bene)

## ---- 2c. Static DiD: Spending per beneficiary ----
did_spending_per_bene <- feols(
  ln_spending_per_bene ~ post_covid_num:exit_rate + unemp_rate |
    state + month_date,
  data = hcbs_panel,
  cluster = ~state
)

cat("\nDiD — ln(spending/beneficiary), Post-COVID × Exit Rate:\n")
summary(did_spending_per_bene)

## ---- 2d. Static DiD: Total claims ----
did_claims <- feols(
  ln_claims ~ post_covid_num:exit_rate + unemp_rate |
    state + month_date,
  data = hcbs_panel,
  cluster = ~state
)


## =========================================================================
## PART 3: Vulnerability Interaction (exit_rate × COVID severity)
## =========================================================================

cat("\n=== PART 3: Vulnerability Interaction ===\n\n")

# Does pre-COVID depletion amplify the damage from pandemic severity?
# Negative coef on interaction = depleted states more vulnerable to COVID

vulnerability_providers <- feols(
  ln_providers ~ post_covid_num:exit_rate +
    post_covid_num:covid_deaths_pc +
    post_covid_num:I(exit_rate * covid_deaths_pc) + unemp_rate |
    state + month_date,
  data = hcbs_panel[!is.na(covid_deaths_pc)],
  cluster = ~state
)

cat("Vulnerability — ln(providers) × exit_rate × COVID deaths/capita:\n")
summary(vulnerability_providers)

# Same for beneficiaries
vulnerability_bene <- feols(
  ln_beneficiaries ~ post_covid_num:exit_rate +
    post_covid_num:covid_deaths_pc +
    post_covid_num:I(exit_rate * covid_deaths_pc) + unemp_rate |
    state + month_date,
  data = hcbs_panel[!is.na(covid_deaths_pc)],
  cluster = ~state
)

cat("\nVulnerability — ln(beneficiaries) × exit_rate × COVID deaths/capita:\n")
summary(vulnerability_bene)

# Same for claims per beneficiary
vulnerability_claims_per_bene <- feols(
  ln_claims_per_bene ~ post_covid_num:exit_rate +
    post_covid_num:covid_deaths_pc +
    post_covid_num:I(exit_rate * covid_deaths_pc) + unemp_rate |
    state + month_date,
  data = hcbs_panel[!is.na(covid_deaths_pc)],
  cluster = ~state
)

cat("\nVulnerability — ln(claims/bene) × exit_rate × COVID deaths/capita:\n")
summary(vulnerability_claims_per_bene)


## =========================================================================
## PART 4: ARPA HCBS Recovery (DDD, Exploratory)
## =========================================================================

cat("\n=== PART 4: DDD — ARPA HCBS × Exit Intensity (Exploratory) ===\n\n")

## ---- 4a. Main DDD: Provider counts ----
ddd_providers <- feols(
  ln_providers ~ post_arpa_hcbs + post_arpa_high_exit + hcbs_high_exit +
    triple_arpa + unemp_rate |
    state_prov + prov_month,
  data = panel,
  cluster = ~state
)

cat("DDD — ln(providers): Post-ARPA × HCBS × High-Exit:\n")
summary(ddd_providers)

## ---- 4b. Main DDD: Beneficiaries ----
ddd_bene <- feols(
  ln_beneficiaries ~ post_arpa_hcbs + post_arpa_high_exit + hcbs_high_exit +
    triple_arpa + unemp_rate |
    state_prov + prov_month,
  data = panel,
  cluster = ~state
)

cat("\nDDD — ln(beneficiaries): Post-ARPA × HCBS × High-Exit:\n")
summary(ddd_bene)

## ---- 4c. Continuous DDD ----
ddd_continuous <- feols(
  ln_providers ~ exit_rate_x_post_arpa_hcbs +
    exit_rate_x_post_arpa + exit_rate_x_hcbs +
    post_arpa_hcbs + unemp_rate |
    state_prov + prov_month,
  data = panel,
  cluster = ~state
)

## ---- 4d. ARPA event study (DDD with event time) ----
panel[, arpa_quarter := floor(event_m_arpa / 3)]
panel[, arpa_quarter := pmax(-12, pmin(15, arpa_quarter))]

es_arpa_ddd <- feols(
  ln_providers ~ i(arpa_quarter, hcbs_high_exit, ref = -1) + unemp_rate |
    state_prov + prov_month,
  data = panel[!is.na(arpa_quarter)],
  cluster = ~state
)

## ---- 4e. DDD pre-trend F-test ----
ddd_coefs <- coeftable(es_arpa_ddd)
ddd_pre_coefs <- rownames(ddd_coefs)[grepl("arpa_quarter::-", rownames(ddd_coefs))]
ddd_pre_coefs <- ddd_pre_coefs[ddd_pre_coefs != "arpa_quarter::-1:hcbs_high_exit"]
if (length(ddd_pre_coefs) > 0) {
  ddd_pre_test <- wald(es_arpa_ddd, ddd_pre_coefs)
  cat(sprintf("\nDDD Pre-trend joint F-test: F=%.2f, p=%.3f\n",
              ddd_pre_test$stat, ddd_pre_test$p))
} else {
  ddd_pre_test <- list(stat = NA, p = NA)
}


## =========================================================================
## PART 5: Deaths of Despair (Secondary, moved to appendix)
## =========================================================================

cat("\n=== PART 5: Deaths of Despair (Secondary/Appendix) ===\n\n")

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

state_month[, covid_deaths_pc := covid_deaths / (population / 100000)]

if ("overdose_deaths" %in% names(state_month)) {
  state_month[, od_deaths_pc := overdose_deaths / (population / 100000)]
  es_overdose <- feols(
    od_deaths_pc ~ i(event_m_covid, exit_rate, ref = -1) |
      state + month_date,
    data = state_month[!is.na(od_deaths_pc) & !is.infinite(od_deaths_pc)],
    cluster = ~state
  )
  cat("Event study — overdose deaths per 100k × exit rate:\n")
  summary(es_overdose)
} else {
  cat("Overdose data not available. Skipping.\n")
  es_overdose <- NULL
}

es_covid_deaths <- feols(
  covid_deaths_pc ~ i(event_m_covid, exit_rate, ref = -1) |
    state + month_date,
  data = state_month[!is.na(covid_deaths_pc) & !is.infinite(covid_deaths_pc) &
                       month_date >= "2020-01-01"],
  cluster = ~state
)


## =========================================================================
## PART 6: Pooled HCBS/Non-HCBS Differential Test
## =========================================================================

cat("\n=== PART 6: Pooled HCBS vs Non-HCBS Test ===\n\n")

panel[, post_covid_num := as.integer(post_covid)]

pooled_test <- feols(
  ln_providers ~ post_covid_num:exit_rate +
    post_covid_num:exit_rate:hcbs + unemp_rate |
    state_prov + prov_month,
  data = panel,
  cluster = ~state
)

cat("Pooled test — is HCBS differentially affected?\n")
cat("  Base (non-HCBS): post_covid_num:exit_rate\n")
cat("  HCBS differential: post_covid_num:exit_rate:hcbs\n")
summary(pooled_test)


## ---- Save results ----
results <- list(
  # Part 1: Provider supply
  es_providers = es_providers,
  es_bene = es_bene,
  es_claims = es_claims,
  es_claims_per_bene = es_claims_per_bene,
  es_spending_per_bene = es_spending_per_bene,
  es_quartile = es_quartile,
  did_covid = did_covid,
  iv_providers = iv_providers,
  pre_test = pre_test,
  # Part 1b: Mediation
  did_no_covid = did_no_covid,
  did_with_covid = did_with_covid,
  did_full_controls = did_full_controls,
  # Part 2: Beneficiary outcomes
  did_bene = did_bene,
  did_claims = did_claims,
  did_claims_per_bene = did_claims_per_bene,
  did_spending_per_bene = did_spending_per_bene,
  # Part 3: Vulnerability
  vulnerability_providers = vulnerability_providers,
  vulnerability_bene = vulnerability_bene,
  vulnerability_claims_per_bene = vulnerability_claims_per_bene,
  # Part 4: ARPA DDD
  ddd_providers = ddd_providers,
  ddd_bene = ddd_bene,
  ddd_continuous = ddd_continuous,
  es_arpa_ddd = es_arpa_ddd,
  ddd_pre_test = ddd_pre_test,
  # Part 5: Deaths of despair
  es_overdose = es_overdose,
  es_covid_deaths = es_covid_deaths,
  # Part 1j-1l: Reviewer-requested specs
  did_broken_trend = did_broken_trend,
  did_hcbs_specific = did_hcbs_specific,
  did_bene_hcbs_specific = did_bene_hcbs_specific,
  did_non_hcbs_hcbs_exit = did_non_hcbs_hcbs_exit,
  pooled_hcbs_test = pooled_hcbs_test,
  # Part 6: Pooled test
  pooled_test = pooled_test,
  # Data
  state_exits = state_exits,
  first_stage = fs
)

saveRDS(results, file.path(DATA_DIR, "main_results.rds"))

cat("\n=== Main analysis complete ===\n")
