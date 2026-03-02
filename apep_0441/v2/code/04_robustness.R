## ============================================================================
## 04_robustness.R — Robustness checks and sensitivity analysis
## Project: apep_0441 — State Bifurcation and Development in India
## ============================================================================

source("00_packages.R")
load("../data/analysis_panel.RData")
load("../data/main_results.RData")
load("../data/cs_results.RData")

## ============================================================================
## 1. Placebo test: fake treatment in 1997
## ============================================================================

cat("=== Placebo Test (Fake Treatment 1997) ===\n")

panel_2000 <- panel_dmsp[state_pair %in% c("UK-UP", "JH-BR", "CG-MP")]

# Use only pre-treatment data (1994-2000) with fake treatment at 1997
panel_placebo <- panel_2000[year <= 2000]
panel_placebo[, fake_post := fifelse(year >= 1997, 1L, 0L)]
panel_placebo[, fake_treat_post := treated * fake_post]

placebo_fit <- feols(log_nl ~ fake_treat_post | did + year,
                      data = panel_placebo, cluster = ~cluster_state)
cat("Placebo (1997):\n")
print(summary(placebo_fit))

## ============================================================================
## 2. Randomization Inference
## ============================================================================

cat("\n=== Randomization Inference ===\n")

# Permute treatment across state pairs
# 2000 cohort: 6 states, choose 3 as "new"
# There are C(6,3) = 20 possible assignments

panel_ri <- panel_2000[, .(dist_id, did, year, log_nl, cluster_state,
                            pc11_state_id, treated, post_2000)]

# Get unique states
states_in_sample <- unique(panel_ri$pc11_state_id)
cat("States in 2000 cohort:", paste(states_in_sample, collapse = ", "), "\n")

# All possible combinations of 3 treated states from 6
combos <- combn(states_in_sample, 3, simplify = FALSE)
cat("Total permutations:", length(combos), "\n")

# Actual treatment assignment
actual_treated_states <- c("05", "20", "22")

# Compute test statistic for each permutation
ri_stats <- numeric(length(combos))
actual_stat <- coef(twfe_basic)["treat_post"]

for (i in seq_along(combos)) {
  fake_treated <- combos[[i]]
  panel_ri[, fake_treat := fifelse(pc11_state_id %in% fake_treated, 1L, 0L)]
  panel_ri[, fake_tp := fake_treat * post_2000]

  fit <- tryCatch({
    feols(log_nl ~ fake_tp | did + year, data = panel_ri, cluster = ~cluster_state)
  }, error = function(e) NULL)

  if (!is.null(fit)) {
    ri_stats[i] <- coef(fit)["fake_tp"]
  } else {
    ri_stats[i] <- NA
  }
}

# RI p-value: fraction of permutations with |stat| >= |actual|
ri_pvalue <- mean(abs(ri_stats) >= abs(actual_stat), na.rm = TRUE)
cat("Actual coefficient:", actual_stat, "\n")
cat("RI p-value (two-sided):", ri_pvalue, "\n")

save(ri_stats, actual_stat, ri_pvalue, file = "../data/ri_results.RData")

## ============================================================================
## 3. HonestDiD sensitivity bounds (Rambachan & Roth 2023)
## ============================================================================

cat("\n=== HonestDiD Sensitivity Analysis (Rambachan-Roth) ===\n")

# Create event_time in panel_2000
panel_2000[, event_time := year - 2001L]

# Use the TWFE event study to construct HonestDiD bounds
es_fit <- feols(log_nl ~ i(event_time, treated, ref = -1) | did + year,
                 data = panel_2000, cluster = ~cluster_state)

# Extract coefficients and VCV in the correct order for HonestDiD
honest_result <- tryCatch({
  betahat <- coef(es_fit)
  sigma <- vcov(es_fit)
  coef_names <- names(betahat)

  # Sort by event time to ensure correct ordering
  pre_names <- grep("event_time::-[0-9]", coef_names, value = TRUE)
  post_names <- grep("event_time::[0-9]+:treated", coef_names, value = TRUE)

  # Extract event times for ordering
  get_et <- function(nm) as.integer(gsub("event_time::|:treated", "", nm))
  pre_names <- pre_names[order(sapply(pre_names, get_et))]
  post_names <- post_names[order(sapply(post_names, get_et))]

  all_names <- c(pre_names, post_names)
  betahat_ordered <- betahat[all_names]
  sigma_ordered <- sigma[all_names, all_names]

  numPre <- length(pre_names)
  numPost <- length(post_names)

  cat("  Pre-periods:", numPre, "| Post-periods:", numPost, "\n")
  cat("  Pre-period event times:", sapply(pre_names, get_et), "\n")

  if (numPre >= 2 && numPost >= 1) {
    # Relative magnitudes approach: bound on post-trend violations
    # relative to the largest pre-trend violation
    Mvec <- seq(0, 2, by = 0.25)

    honest_out <- HonestDiD::createSensitivityResults(
      betahat = betahat_ordered,
      sigma = sigma_ordered,
      numPrePeriods = numPre,
      numPostPeriods = numPost,
      Mvec = Mvec,
      method = "C-LF"  # Conditional least-favorable
    )

    cat("HonestDiD sensitivity bounds (Relative Magnitudes):\n")
    print(honest_out)

    # Also compute smoothness-based bounds (Delta^SD)
    honest_sd <- tryCatch({
      HonestDiD::createSensitivityResults_relativeMagnitudes(
        betahat = betahat_ordered,
        sigma = sigma_ordered,
        numPrePeriods = numPre,
        numPostPeriods = numPost,
        Mbarvec = Mvec
      )
    }, error = function(e) {
      cat("  Relative magnitudes variant error:", conditionMessage(e), "\n")
      NULL
    })

    # Find breakdown value: smallest M where CI includes 0
    breakdown_M <- NA_real_
    bounds_df <- as.data.frame(honest_out)
    for (i in 1:nrow(bounds_df)) {
      lb_val <- bounds_df$lb[i]
      ub_val <- bounds_df$ub[i]
      if (!is.na(lb_val) && !is.na(ub_val) && lb_val <= 0 && ub_val >= 0) {
        breakdown_M <- bounds_df$M[i]
        break
      }
    }

    cat("\nBreakdown value (M where CI includes 0):", breakdown_M, "\n")

    list(bounds = honest_out, breakdown_M = breakdown_M,
         betahat = betahat_ordered, sigma = sigma_ordered,
         numPre = numPre, numPost = numPost, Mvec = Mvec,
         smooth_bounds = honest_sd)
  } else {
    cat("Not enough pre/post periods for HonestDiD\n")
    NULL
  }
}, error = function(e) {
  cat("HonestDiD error:", conditionMessage(e), "\n")
  cat("  This may be due to near-singular VCV with few clusters\n")
  NULL
})

## ============================================================================
## 4. Alternative outcome: nightlight levels (not logs)
## ============================================================================

cat("\n=== Alternative Specification: Levels ===\n")

levels_fit <- feols(nightlights ~ treat_post | did + year,
                     data = panel_2000, cluster = ~cluster_state)
cat("Levels specification:\n")
print(summary(levels_fit))

## ============================================================================
## 5. Population-weighted regression
## ============================================================================

cat("\n=== Population-Weighted Regression ===\n")

weighted_fit <- feols(log_nl ~ treat_post | did + year,
                       data = panel_2000, cluster = ~cluster_state,
                       weights = ~pop_2011)
cat("Population-weighted:\n")
print(summary(weighted_fit))

## ============================================================================
## 6. Extended panel (DMSP + VIIRS, 1994-2023)
## ============================================================================

cat("\n=== Extended Panel (1994-2023) ===\n")

panel_ext <- panel_full[state_pair %in% c("UK-UP", "JH-BR", "CG-MP")]
panel_ext[, event_time := year - 2001L]

ext_fit <- feols(log_nl ~ treat_post | did + year,
                  data = panel_ext, cluster = ~cluster_state)
cat("Extended panel (1994-2023):\n")
print(summary(ext_fit))

# Event study on extended panel
es_ext <- feols(log_nl ~ i(event_time, treated, ref = -1) | did + year,
                 data = panel_ext, cluster = ~cluster_state)

## ============================================================================
## 7. Telangana analysis (VIIRS 2012-2023)
## ============================================================================

cat("\n=== Telangana (2014 Cohort) ===\n")

panel_tg <- panel_full[state_pair == "TG-AP" & year >= 2012]
panel_tg[, event_time := year - 2015L]
panel_tg[, tg_treat_post := new_state_2014 * fifelse(year >= 2015, 1L, 0L)]

tg_fit <- feols(log_nl ~ tg_treat_post | did + year,
                 data = panel_tg, cluster = ~cluster_state)
cat("Telangana DiD:\n")
print(summary(tg_fit))

# Telangana event study
tg_es <- feols(log_nl ~ i(event_time, new_state_2014, ref = -1) | did + year,
                data = panel_tg, cluster = ~cluster_state)

## ============================================================================
## 8. Dropping one state pair at a time (leave-one-out)
## ============================================================================

cat("\n=== Leave-One-Pair-Out ===\n")

loo_results <- list()
for (drop_pair in c("UK-UP", "JH-BR", "CG-MP")) {
  sub <- panel_2000[state_pair != drop_pair]
  fit <- feols(log_nl ~ treat_post | did + year, data = sub, cluster = ~cluster_state)
  loo_results[[paste0("drop_", drop_pair)]] <- fit
  cat("Dropping", drop_pair, ": coef =", round(coef(fit)["treat_post"], 4),
      ", se =", round(se(fit)["treat_post"], 4), "\n")
}

## ============================================================================
## 9. Pre-trend test: joint F-test on pre-period coefficients
## ============================================================================

cat("\n=== Pre-Trend Joint F-Test ===\n")

# Test that all pre-period coefficients are jointly zero
pre_coefs <- grep("event_time::-", names(coef(es_fit)), value = TRUE)
if (length(pre_coefs) > 0) {
  wald_test <- tryCatch({
    wald(es_fit, pre_coefs)
  }, error = function(e) {
    cat("Wald test error:", conditionMessage(e), "\n")
    NULL
  })
  if (!is.null(wald_test)) {
    cat("Joint F-test on pre-period coefficients:\n")
    print(wald_test)
  }
}

## ============================================================================
## 10. Trend-Adjusted Estimates
## ============================================================================

cat("\n=== Trend-Adjusted Estimates ===\n")

# Compute linear pre-trend, extrapolate forward, subtract from post-treatment coefficients
# This gives a lower bound on the treatment effect net of pre-existing convergence

load("../data/es_coefs.RData")

pre_coefs_dt <- es_coefs[event_time < -1]
if (nrow(pre_coefs_dt) >= 2) {
  # Fit linear trend to pre-period coefficients
  pre_trend_fit <- lm(estimate ~ event_time, data = pre_coefs_dt)
  pre_slope <- coef(pre_trend_fit)["event_time"]
  pre_intercept <- coef(pre_trend_fit)["(Intercept)"]

  cat("Pre-trend slope:", round(pre_slope, 4), "\n")
  cat("Pre-trend intercept:", round(pre_intercept, 4), "\n")

  # Extrapolate: what would event study look like if pre-trend continued?
  post_coefs_dt <- es_coefs[event_time >= 0]
  post_coefs_dt[, predicted_trend := pre_intercept + pre_slope * event_time]
  post_coefs_dt[, trend_adjusted := estimate - predicted_trend]

  cat("\nTrend-adjusted post-treatment coefficients:\n")
  print(post_coefs_dt[, .(event_time, raw = round(estimate, 4),
                           extrapolated = round(predicted_trend, 4),
                           adjusted = round(trend_adjusted, 4))])

  # Average trend-adjusted treatment effect
  avg_adjusted <- mean(post_coefs_dt$trend_adjusted, na.rm = TRUE)
  cat("\nAverage trend-adjusted effect:", round(avg_adjusted, 4), "\n")

  trend_adjusted_results <- list(
    slope = pre_slope, intercept = pre_intercept,
    adjusted_coefs = post_coefs_dt, avg_adjusted = avg_adjusted
  )
} else {
  cat("Not enough pre-period coefficients for trend adjustment\n")
  trend_adjusted_results <- NULL
}

## ============================================================================
## 11. Save all robustness results
## ============================================================================

save(placebo_fit, ri_stats, actual_stat, ri_pvalue,
     honest_result, levels_fit, weighted_fit,
     ext_fit, es_ext, tg_fit, tg_es,
     loo_results, trend_adjusted_results,
     file = "../data/robustness_results.RData")

cat("\n=== Robustness checks complete ===\n")
