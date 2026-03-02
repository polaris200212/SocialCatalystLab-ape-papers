## ============================================================
## 04_robustness.R
## Robustness checks: alternative thresholds, placebo tests,
## sensitivity analysis, period splits, leave-one-out
## ============================================================

source("00_packages.R")

data_dir <- "../data/"
panel <- read_csv(paste0(data_dir, "analysis_panel.csv"), show_col_types = FALSE)

## ============================================================
## 1. Alternative Exposure Thresholds (25%, 50%, 75%)
## ============================================================

cat("=== ALTERNATIVE EXPOSURE THRESHOLDS ===\n\n")

threshold_results <- list()

for (thresh in c("high_exposure_25", "high_exposure_50", "high_exposure_75")) {
  cat("Threshold:", thresh, "\n")
  fml <- as.formula(paste0(
    "total_overdose_rate ~ ", thresh, " + own_pdmp + ",
    "has_naloxone + has_good_samaritan + has_medicaid_expansion | state_abbr + year"
  ))
  threshold_results[[thresh]] <- feols(
    fml,
    data = panel %>% filter(year >= 2006, !is.na(total_overdose_rate)),
    cluster = ~state_abbr
  )
  cat("  Coef:", round(coef(threshold_results[[thresh]])[1], 3), "\n")
  cat("  SE:", round(se(threshold_results[[thresh]])[1], 3), "\n\n")
}

## ============================================================
## 2. Pre-Fentanyl vs Fentanyl Era
## ============================================================

cat("=== PERIOD SPLIT: PRE-FENTANYL vs FENTANYL ERA ===\n\n")

# Pre-fentanyl era: 2006-2013 (before synthetic opioid wave)
period_pre <- feols(
  total_overdose_rate ~ high_exposure_50 + own_pdmp +
    has_naloxone + has_good_samaritan |
    state_abbr + year,
  data = panel %>% filter(year >= 2006, year <= 2013, !is.na(total_overdose_rate)),
  cluster = ~state_abbr
)

cat("Pre-fentanyl (2006-2013):\n")
cat("  Coef:", round(coef(period_pre)["high_exposure_50"], 3), "\n")
cat("  SE:", round(se(period_pre)["high_exposure_50"], 3), "\n\n")

# Fentanyl era: 2014-2023
period_post <- feols(
  total_overdose_rate ~ high_exposure_50 + own_pdmp +
    has_naloxone + has_good_samaritan + has_medicaid_expansion |
    state_abbr + year,
  data = panel %>% filter(year >= 2014, !is.na(total_overdose_rate)),
  cluster = ~state_abbr
)

cat("Fentanyl era (2014-2023):\n")
cat("  Coef:", round(coef(period_post)["high_exposure_50"], 3), "\n")
cat("  SE:", round(se(period_post)["high_exposure_50"], 3), "\n\n")

## ============================================================
## 3. Placebo Outcome Test
##    Non-drug causes of death should NOT be affected
## ============================================================

cat("=== PLACEBO OUTCOME TESTS ===\n\n")

# Compute a simple placebo: total overdose rate should respond;
# We test if the treatment "explains" log population or income
# (which it shouldn't, if identification is valid)

placebo_pop <- feols(
  log_pop ~ high_exposure_50 + own_pdmp |
    state_abbr + year,
  data = panel %>% filter(year >= 2006, !is.na(log_pop)),
  cluster = ~state_abbr
)

cat("Placebo: log(population)\n")
cat("  Coef:", round(coef(placebo_pop)["high_exposure_50"], 5), "\n")
cat("  SE:", round(se(placebo_pop)["high_exposure_50"], 5), "\n")
cat("  p-value:", round(fixest::pvalue(placebo_pop)["high_exposure_50"], 3), "\n\n")

placebo_income <- feols(
  log_income ~ high_exposure_50 + own_pdmp |
    state_abbr + year,
  data = panel %>% filter(year >= 2006, !is.na(log_income)),
  cluster = ~state_abbr
)

cat("Placebo: log(median income)\n")
cat("  Coef:", round(coef(placebo_income)["high_exposure_50"], 5), "\n")
cat("  SE:", round(se(placebo_income)["high_exposure_50"], 5), "\n")
cat("  p-value:", round(fixest::pvalue(placebo_income)["high_exposure_50"], 3), "\n\n")

## ============================================================
## 4. Leave-One-Out Sensitivity
## ============================================================

cat("=== LEAVE-ONE-OUT SENSITIVITY ===\n\n")

states <- unique(panel$state_abbr[!panel$state_abbr %in% c("PR", "US", "YC")])
loo_coefs <- tibble(
  excluded_state = character(),
  coef = numeric(),
  se = numeric()
)

for (st in states) {
  fit_loo <- feols(
    total_overdose_rate ~ high_exposure_50 + own_pdmp +
      has_naloxone + has_good_samaritan + has_medicaid_expansion |
      state_abbr + year,
    data = panel %>% filter(year >= 2006, state_abbr != st,
                           !is.na(total_overdose_rate)),
    cluster = ~state_abbr
  )
  loo_coefs <- bind_rows(loo_coefs, tibble(
    excluded_state = st,
    coef = coef(fit_loo)["high_exposure_50"],
    se = se(fit_loo)["high_exposure_50"]
  ))
}

cat("Leave-one-out coefficient range:\n")
cat("  Min:", round(min(loo_coefs$coef), 3),
    "(excluding", loo_coefs$excluded_state[which.min(loo_coefs$coef)], ")\n")
cat("  Max:", round(max(loo_coefs$coef), 3),
    "(excluding", loo_coefs$excluded_state[which.max(loo_coefs$coef)], ")\n")
cat("  SD:", round(sd(loo_coefs$coef), 3), "\n\n")

write_csv(loo_coefs, paste0(data_dir, "loo_sensitivity.csv"))

## ============================================================
## 5. Sensitivity to Unmeasured Confounding (sensemakr)
## ============================================================

cat("=== SENSITIVITY ANALYSIS (Cinelli & Hazlett 2020) ===\n\n")

# Run OLS version for sensemakr (requires lm object)
ols_for_sens <- lm(
  total_overdose_rate ~ high_exposure_50 + own_pdmp + log_pop +
    log_income + pct_white + unemployment_rate +
    has_naloxone + has_good_samaritan + has_medicaid_expansion +
    factor(state_abbr) + factor(year),
  data = panel %>% filter(year >= 2006, !is.na(total_overdose_rate),
                          !is.na(log_pop))
)

sens <- tryCatch({
  sensemakr(
    model = ols_for_sens,
    treatment = "high_exposure_50",
    benchmark_covariates = c("own_pdmp", "unemployment_rate"),
    kd = 1:3
  )
}, error = function(e) {
  cat("sensemakr error:", e$message, "\n")
  NULL
})

if (!is.null(sens)) {
  cat("Sensitivity analysis results:\n")
  print(summary(sens))
}

## ============================================================
## 6. Population-Weighted Exposure
## ============================================================

cat("\n=== POPULATION-WEIGHTED EXPOSURE ===\n\n")

twfe_popw <- feols(
  total_overdose_rate ~ high_exposure_50_popw + own_pdmp +
    has_naloxone + has_good_samaritan + has_medicaid_expansion |
    state_abbr + year,
  data = panel %>% filter(year >= 2006, !is.na(total_overdose_rate)),
  cluster = ~state_abbr
)

cat("Pop-weighted binary exposure (50%):\n")
print(summary(twfe_popw))

## ============================================================
## 7. Controlling for Regional Trends
## ============================================================

cat("\n=== REGION-SPECIFIC TRENDS ===\n\n")

# Census regions
panel <- panel %>%
  mutate(
    region = case_when(
      state_abbr %in% c("CT","ME","MA","NH","RI","VT","NJ","NY","PA") ~ "Northeast",
      state_abbr %in% c("IL","IN","MI","OH","WI","IA","KS","MN","MO","NE","ND","SD") ~ "Midwest",
      state_abbr %in% c("DE","DC","FL","GA","MD","NC","SC","VA","WV",
                          "AL","KY","MS","TN","AR","LA","OK","TX") ~ "South",
      state_abbr %in% c("AZ","CO","ID","MT","NV","NM","UT","WY",
                          "CA","OR","WA") ~ "West",
      TRUE ~ NA_character_
    )
  )

twfe_region <- feols(
  total_overdose_rate ~ high_exposure_50 + own_pdmp +
    has_naloxone + has_good_samaritan + has_medicaid_expansion |
    state_abbr + year + region[year],
  data = panel %>% filter(year >= 2006, !is.na(total_overdose_rate), !is.na(region)),
  cluster = ~state_abbr
)

cat("With region × year FE:\n")
print(summary(twfe_region))

## ============================================================
## 8. Save robustness results
## ============================================================

cat("\nSaving robustness results...\n")

rob_results <- list(
  threshold_results = threshold_results,
  period_pre = period_pre,
  period_post = period_post,
  placebo_pop = placebo_pop,
  placebo_income = placebo_income,
  loo_coefs = loo_coefs,
  sens = sens,
  twfe_popw = twfe_popw,
  twfe_region = twfe_region
)

saveRDS(rob_results, paste0(data_dir, "robustness_results.rds"))

cat("\n==============================\n")
cat("Robustness checks complete.\n")
cat("==============================\n")
