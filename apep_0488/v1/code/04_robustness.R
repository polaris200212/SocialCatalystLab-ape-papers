## =============================================================================
## apep_0488: The Welfare Cost of PDMPs — Sufficient Statistics Approach
## 04_robustness.R: Robustness checks and sensitivity analysis
## =============================================================================

source("00_packages.R")

panel <- readRDS(file.path(DATA_DIR, "panel_prescribing.rds"))
results <- readRDS(file.path(DATA_DIR, "analysis_results.rds"))
policy <- readRDS(file.path(DATA_DIR, "policy_dates.rds"))

# Create numeric state ID
panel <- panel %>% mutate(state_id = as.numeric(factor(state)))

## ---------------------------------------------------------------------------
## 1. All cohorts (including early adopters KY/WV/NM 2012, TN/NY/VT 2013)
## ---------------------------------------------------------------------------
cat("=== Robustness 1: All cohorts ===\n")

panel_all <- panel %>%
  mutate(first_treat_all = ifelse(is.na(must_access_year), 0, must_access_year))

cs_all_cohorts <- att_gt(
  yname = "opioid_rate",
  tname = "year",
  idname = "state_id",
  gname = "first_treat_all",
  data = panel_all,
  control_group = "nevertreated",
  est_method = "dr"
)
agg_all <- aggte(cs_all_cohorts, type = "simple")
cat("All cohorts ATT:", round(agg_all$overall.att, 4),
    " SE:", round(agg_all$overall.se, 4), "\n")

## ---------------------------------------------------------------------------
## 2. Sun-Abraham estimator (alternative aggregation)
## ---------------------------------------------------------------------------
cat("\n=== Robustness 2: Sun-Abraham (fixest sunab) ===\n")

panel_sa <- panel %>%
  filter(is.na(must_access_year) | must_access_year >= 2014) %>%
  mutate(cohort = ifelse(is.na(must_access_year), Inf, must_access_year))

sa_rate <- feols(
  opioid_rate ~ sunab(cohort, year) | state + year,
  data = panel_sa,
  cluster = ~state
)
cat("Sun-Abraham overall:\n")
print(summary(sa_rate, agg = "ATT"))

## ---------------------------------------------------------------------------
## 3. Placebo outcomes: non-opioid prescribing
## ---------------------------------------------------------------------------
cat("\n=== Robustness 3: Placebo — non-opioid prescribing ===\n")

# Total prescribers (should not be affected by PDMP)
twfe_prescribers <- feols(
  log(n_prescribers) ~ pdmp_active | state + year,
  data = panel,
  cluster = ~state
)
cat("Placebo (log total prescribers):\n")
print(summary(twfe_prescribers))

# Total claims (should not change much — PDMPs target opioids not all Rx)
twfe_total_claims <- feols(
  log(total_claims) ~ pdmp_active | state + year,
  data = panel,
  cluster = ~state
)
cat("\nPlacebo (log total claims):\n")
print(summary(twfe_total_claims))

## ---------------------------------------------------------------------------
## 4. Leave-one-out state sensitivity
## ---------------------------------------------------------------------------
cat("\n=== Robustness 4: Leave-one-out states ===\n")

# Largest treated states by opioid claims
large_states <- panel %>%
  filter(pdmp_active == 1) %>%
  group_by(state) %>%
  summarise(total_opioid = sum(opioid_claims, na.rm = TRUE)) %>%
  arrange(desc(total_opioid)) %>%
  head(8) %>%
  pull(state)

loo_results <- map_dfr(large_states, function(drop_st) {
  p <- panel %>%
    filter(state != drop_st, is.na(must_access_year) | must_access_year >= 2014)
  twfe_loo <- feols(
    opioid_rate ~ pdmp_active | state + year,
    data = p,
    cluster = ~state
  )
  tibble(
    dropped_state = drop_st,
    coef = coef(twfe_loo)["pdmp_active"],
    se = se(twfe_loo)["pdmp_active"]
  )
})
cat("Leave-one-out results:\n")
print(loo_results)

## ---------------------------------------------------------------------------
## 5. Co-policy bundling test
## ---------------------------------------------------------------------------
cat("\n=== Robustness 5: Exclude co-policy states ===\n")

copolicy_states <- policy %>%
  filter(!is.na(must_access_year)) %>%
  mutate(
    nal_close = !is.na(naloxone_year) & abs(naloxone_year - must_access_year) <= 1,
    gsl_close = !is.na(gsl_year) & abs(gsl_year - must_access_year) <= 1,
    any_copolicy = nal_close | gsl_close
  ) %>%
  filter(any_copolicy) %>%
  pull(state)

cat("States with co-policies within +/- 1 year:", length(copolicy_states), "\n")

panel_no_copolicy <- panel %>%
  filter(!(state %in% copolicy_states))

twfe_no_copolicy <- feols(
  opioid_rate ~ pdmp_active | state + year,
  data = panel_no_copolicy,
  cluster = ~state
)
cat("Without co-policy states:\n")
print(summary(twfe_no_copolicy))

## ---------------------------------------------------------------------------
## 6. Wild cluster bootstrap (graceful fallback)
## ---------------------------------------------------------------------------
cat("\n=== Robustness 6: Wild cluster bootstrap ===\n")

tryCatch({
  set.seed(20260303)
  boot_rate <- boottest(
    results$twfe_rate,
    param = "pdmp_active",
    clustid = "state",
    B = 999,
    type = "rademacher"
  )
  cat("Wild bootstrap p-value:", boot_rate$p_val, "\n")
  cat("Wild bootstrap CI:", boot_rate$conf_int, "\n")
}, error = function(e) {
  cat("Bootstrap error:", conditionMessage(e), "\n")
  cat("  Using analytical cluster-robust SEs (standard approach with 51 clusters)\n")
})

## ---------------------------------------------------------------------------
## 7. Welfare sensitivity to internality calibration
## ---------------------------------------------------------------------------
cat("\n=== Robustness 7: Welfare sensitivity grid ===\n")

wp <- results$welfare_params
betas <- seq(0, 1, by = 0.1)
welfare_grid <- tibble(
  beta = betas,
  gamma = (1 - betas) * wp$PV_addiction_cost,
  label = case_when(
    beta == 1 ~ "Rational (BM)",
    beta == 0.7 ~ "Moderate (GK)",
    beta == 0.5 ~ "Strong bias",
    beta == 0 ~ "Cue-triggered (BR)",
    TRUE ~ ""
  )
)
cat("Welfare sensitivity grid:\n")
print(welfare_grid)

saveRDS(welfare_grid, file.path(DATA_DIR, "welfare_sensitivity.rds"))

## ---------------------------------------------------------------------------
## 8. Pre-trends test (joint significance of pre-treatment coefficients)
## ---------------------------------------------------------------------------
cat("\n=== Robustness 8: Pre-trends test ===\n")

es <- results$agg_dynamic
pre_periods <- which(es$egt < 0)
if (length(pre_periods) >= 2) {
  pre_atts <- es$att.egt[pre_periods]
  pre_ses <- es$se.egt[pre_periods]
  cat("Pre-treatment ATTs:\n")
  for (i in seq_along(pre_periods)) {
    cat(sprintf("  e = %d: ATT = %.4f, SE = %.4f, t = %.2f\n",
                es$egt[pre_periods[i]], pre_atts[i], pre_ses[i],
                pre_atts[i] / pre_ses[i]))
  }
  # Wald-type joint test (approximate)
  chi2 <- sum((pre_atts / pre_ses)^2)
  p_val <- 1 - pchisq(chi2, df = length(pre_periods))
  cat(sprintf("\nJoint pre-trends test: chi2(%d) = %.2f, p = %.4f\n",
              length(pre_periods), chi2, p_val))
} else {
  cat("  Not enough pre-treatment periods for joint test\n")
}

## ---------------------------------------------------------------------------
## Save robustness results
## ---------------------------------------------------------------------------
rob_results <- list(
  cs_all_cohorts = cs_all_cohorts,
  agg_all = agg_all,
  sa_rate = sa_rate,
  twfe_prescribers = twfe_prescribers,
  twfe_total_claims = twfe_total_claims,
  loo_results = loo_results,
  twfe_no_copolicy = twfe_no_copolicy,
  welfare_grid = welfare_grid
)
saveRDS(rob_results, file.path(DATA_DIR, "robustness_results.rds"))

cat("\n=== Robustness checks complete ===\n")
