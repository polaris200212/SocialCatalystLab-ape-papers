## =============================================================================
## apep_0488: The Welfare Cost of PDMPs — Sufficient Statistics Approach
## 03_main_analysis.R: Primary CS-DiD estimation + welfare calibration
## =============================================================================

source("00_packages.R")

## ---------------------------------------------------------------------------
## 1. Load analysis panels
## ---------------------------------------------------------------------------
panel <- readRDS(file.path(DATA_DIR, "panel_prescribing.rds"))
policy <- readRDS(file.path(DATA_DIR, "policy_dates.rds"))

cat("=== Panel summary ===\n")
cat("States:", n_distinct(panel$state), "\n")
cat("Years:", paste(range(panel$year), collapse = "-"), "\n")
cat("Must-access PDMP states:", sum(!is.na(policy$must_access_year)), "\n")
cat("Never-treated states:", sum(is.na(policy$must_access_year)), "\n\n")

# Create numeric state ID for CS-DiD
panel <- panel %>%
  mutate(state_id = as.numeric(factor(state)))

## ---------------------------------------------------------------------------
## 2. Main sample: 2014+ adopters + truly never-treated
##    Drop early adopters (2012-2013) who are already treated at start of panel
## ---------------------------------------------------------------------------
panel_main <- panel %>%
  filter(is.na(must_access_year) | must_access_year >= 2014) %>%
  mutate(
    first_treat_cs = ifelse(is.na(must_access_year), 0L, must_access_year)
  )

cat("=== Main sample ===\n")
cat("State-years:", nrow(panel_main), "\n")
cat("Treated states (2014+):", n_distinct(panel_main$state[panel_main$first_treat_cs > 0]), "\n")
cat("Never-treated states:", n_distinct(panel_main$state[panel_main$first_treat_cs == 0]), "\n")
cat("Cohort distribution:\n")
print(table(panel_main$first_treat_cs[panel_main$first_treat_cs > 0]))

## ---------------------------------------------------------------------------
## 3. Callaway-Sant'Anna: Effect of must-access PDMP on opioid prescribing
## ---------------------------------------------------------------------------
cat("\n=== CS-DiD: Opioid prescribing rate ===\n")

# Outcome 1: Opioid prescribing rate (% of claims that are opioids)
cs_opioid_rate <- att_gt(
  yname = "opioid_rate",
  tname = "year",
  idname = "state_id",
  gname = "first_treat_cs",
  data = panel_main,
  control_group = "nevertreated",
  est_method = "dr"
)

agg_overall <- aggte(cs_opioid_rate, type = "simple")
cat("Overall ATT (opioid rate %):", round(agg_overall$overall.att, 4),
    " SE:", round(agg_overall$overall.se, 4), "\n")

agg_dynamic <- aggte(cs_opioid_rate, type = "dynamic")
cat("Dynamic ATT computed (", length(agg_dynamic$egt), "periods)\n")

# Outcome 2: Opioid prescriber share (extensive margin)
cs_prescriber <- att_gt(
  yname = "opioid_prescriber_share",
  tname = "year",
  idname = "state_id",
  gname = "first_treat_cs",
  data = panel_main,
  control_group = "nevertreated",
  est_method = "dr"
)

agg_prescriber <- aggte(cs_prescriber, type = "simple")
cat("Overall ATT (prescriber share):", round(agg_prescriber$overall.att, 4),
    " SE:", round(agg_prescriber$overall.se, 4), "\n")

agg_prescriber_dynamic <- aggte(cs_prescriber, type = "dynamic")

# Outcome 3: Long-acting opioid share
cs_la_share <- att_gt(
  yname = "la_share_of_opioid",
  tname = "year",
  idname = "state_id",
  gname = "first_treat_cs",
  data = panel_main,
  control_group = "nevertreated",
  est_method = "dr"
)

agg_la <- aggte(cs_la_share, type = "simple")
cat("Overall ATT (LA share of opioid):", round(agg_la$overall.att, 4),
    " SE:", round(agg_la$overall.se, 4), "\n")

## ---------------------------------------------------------------------------
## 4. TWFE (fixest) for comparison
## ---------------------------------------------------------------------------
cat("\n=== TWFE specifications ===\n")

# Use full panel (all 51 states × 11 years) for TWFE
twfe_rate <- feols(
  opioid_rate ~ pdmp_active + naloxone_active + gsl_active |
    state + year,
  data = panel,
  cluster = ~state
)
cat("TWFE opioid_rate:\n")
print(summary(twfe_rate))

twfe_prescriber <- feols(
  opioid_prescriber_share ~ pdmp_active + naloxone_active + gsl_active |
    state + year,
  data = panel,
  cluster = ~state
)
cat("\nTWFE prescriber_share:\n")
print(summary(twfe_prescriber))

twfe_la <- feols(
  la_share_of_opioid ~ pdmp_active + naloxone_active + gsl_active |
    state + year,
  data = panel,
  cluster = ~state
)
cat("\nTWFE la_share_of_opioid:\n")
print(summary(twfe_la))

# Opioid share (fraction form) for robustness
twfe_share <- feols(
  opioid_share ~ pdmp_active + naloxone_active + gsl_active |
    state + year,
  data = panel,
  cluster = ~state
)

## ---------------------------------------------------------------------------
## 5. Event study (fixest sunab for robustness)
## ---------------------------------------------------------------------------
cat("\n=== Sun-Abraham event study ===\n")

panel_sa <- panel_main %>%
  mutate(cohort = ifelse(first_treat_cs == 0, Inf, first_treat_cs))

es_rate <- feols(
  opioid_rate ~ sunab(cohort, year) + naloxone_active + gsl_active |
    state + year,
  data = panel_sa,
  cluster = ~state
)
cat("Sun-Abraham event study:\n")
print(summary(es_rate, agg = "ATT"))

## ---------------------------------------------------------------------------
## 6. Mortality analysis (VSRR data merged in panel)
## ---------------------------------------------------------------------------
cat("\n=== Mortality analysis ===\n")

if ("overdose_deaths" %in% names(panel) && sum(!is.na(panel$overdose_deaths)) > 50) {
  mort_panel <- panel %>% filter(!is.na(overdose_deaths), overdose_deaths > 0)
  cat("Mortality panel:", nrow(mort_panel), "state-years\n")

  twfe_mort <- feols(
    log(overdose_deaths) ~ pdmp_active + naloxone_active + gsl_active |
      state + year,
    data = mort_panel,
    cluster = ~state
  )
  cat("Mortality TWFE:\n")
  print(summary(twfe_mort))

  # Mortality rate per 100K if population available
  if ("overdose_rate" %in% names(panel)) {
    mort_rate_panel <- panel %>% filter(!is.na(overdose_rate), overdose_rate > 0)
    twfe_mort_rate <- feols(
      log(overdose_rate) ~ pdmp_active + naloxone_active + gsl_active |
        state + year,
      data = mort_rate_panel,
      cluster = ~state
    )
    cat("\nMortality rate TWFE:\n")
    print(summary(twfe_mort_rate))
  }
} else {
  cat("  Insufficient mortality data for analysis\n")
  twfe_mort <- NULL
}

## ---------------------------------------------------------------------------
## 7. Welfare calibration
## ---------------------------------------------------------------------------
cat("\n=== Welfare calibration ===\n")

# Key inputs from DiD estimates
# dQ/dτ: Prescribing reduction from must-access PDMP
dQ_tau <- agg_overall$overall.att  # Opioid rate change (percentage points)

# Baseline prescribing (pre-treatment mean among treated states)
baseline_opioid_rate <- panel_main %>%
  filter(first_treat_cs > 0, pdmp_active == 0) %>%
  summarise(mean_rate = mean(opioid_rate, na.rm = TRUE)) %>%
  pull(mean_rate)

pct_reduction <- dQ_tau / baseline_opioid_rate * 100
cat("Baseline opioid prescribing rate:", round(baseline_opioid_rate, 2), "%\n")
cat("PDMP effect (pp):", round(dQ_tau, 4), "\n")
cat("Percentage reduction:", round(pct_reduction, 1), "%\n")

# Externality calibration
# VSL = $10.9M (EPA 2024, 2020 dollars)
VSL <- 10.9e6

# Welfare bounds under alternative behavioral models
# γ̄ = average internality per prescription
# Annual expected addiction cost per new prescription
# OUD probability: ~5% of new Rx opioid starts (Volkow & McLellan 2016)
# Annual OUD cost: ~$25,000 (healthcare + productivity + QALYs; Florence et al. 2016)
addiction_cost_annual <- 25000
new_addiction_probability <- 0.05
expected_addiction_cost <- addiction_cost_annual * new_addiction_probability
PV_addiction_cost <- expected_addiction_cost / 0.05  # r = 5% discount rate

cat("\nWelfare bounds:\n")
cat("PV expected addiction cost per prescription:", format(PV_addiction_cost, big.mark = ","), "\n")

# Scenario 1: Rational addiction (Becker-Murphy 1988) — γ = 0
gamma_rational <- 0
cat("\nScenario 1 (Rational): gamma =", gamma_rational, "\n")

# Scenario 2: Moderate present bias (Gruber-Koszegi 2001, beta = 0.7)
gamma_moderate <- (1 - 0.7) * PV_addiction_cost
cat("Scenario 2 (Moderate bias, beta=0.7): gamma =", format(gamma_moderate, big.mark = ","), "\n")

# Scenario 3: Strong present bias (beta = 0.5)
gamma_strong <- (1 - 0.5) * PV_addiction_cost
cat("Scenario 3 (Strong bias, beta=0.5): gamma =", format(gamma_strong, big.mark = ","), "\n")

# Scenario 4: Cue-triggered (Bernheim-Rangel 2004) — γ = full addiction cost
gamma_cue <- PV_addiction_cost
cat("Scenario 4 (Cue-triggered): gamma =", format(gamma_cue, big.mark = ","), "\n")

## ---------------------------------------------------------------------------
## 8. Save all results
## ---------------------------------------------------------------------------
results <- list(
  cs_opioid_rate = cs_opioid_rate,
  cs_prescriber = cs_prescriber,
  cs_la_share = cs_la_share,
  agg_overall = agg_overall,
  agg_prescriber = agg_prescriber,
  agg_la = agg_la,
  agg_dynamic = agg_dynamic,
  agg_prescriber_dynamic = agg_prescriber_dynamic,
  twfe_rate = twfe_rate,
  twfe_prescriber = twfe_prescriber,
  twfe_la = twfe_la,
  twfe_share = twfe_share,
  twfe_mort = twfe_mort,
  es_rate = es_rate,
  welfare_params = list(
    VSL = VSL,
    dQ_tau = dQ_tau,
    baseline_opioid_rate = baseline_opioid_rate,
    pct_reduction = pct_reduction,
    gamma_rational = gamma_rational,
    gamma_moderate = gamma_moderate,
    gamma_strong = gamma_strong,
    gamma_cue = gamma_cue,
    PV_addiction_cost = PV_addiction_cost
  )
)

saveRDS(results, file.path(DATA_DIR, "analysis_results.rds"))
cat("\n=== Analysis complete. Results saved. ===\n")
