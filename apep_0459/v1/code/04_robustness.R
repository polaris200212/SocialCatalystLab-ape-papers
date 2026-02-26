## 04_robustness.R — Robustness checks and sensitivity analysis
## apep_0459: Skills-Based Hiring Laws and Public Sector De-Credentialization

source("00_packages.R")

data_dir <- "../data/"
analysis <- fread(paste0(data_dir, "analysis_panel.csv"))
load(paste0(data_dir, "main_results.RData"))

cat("=== Robustness Checks ===\n")

## ============================================================================
## CHECK 1: Bacon Decomposition
## ============================================================================

cat("\n--- Bacon Decomposition ---\n")

## Prepare for bacon decomposition
bacon_data <- as.data.frame(analysis[, .(state_fips, year, treated, share_no_ba, n_state_gov)])

tryCatch({
  bacon_out <- bacon(share_no_ba ~ treated,
                     data = bacon_data,
                     id_var = "state_fips",
                     time_var = "year")
  cat("Bacon decomposition:\n")
  print(summary(bacon_out))

  ## Save for figure
  save(bacon_out, file = paste0(data_dir, "bacon_decomp.RData"))
}, error = function(e) {
  cat("Bacon decomposition error:", conditionMessage(e), "\n")
})

## ============================================================================
## CHECK 2: Placebo — Federal Government Workers
## ============================================================================

cat("\n--- Placebo: Federal Government ---\n")

placebo_fed <- feols(share_no_ba_federal ~ treated | state_fips + year,
                     data = analysis[!is.na(share_no_ba_federal)],
                     weights = ~n_state_gov,
                     cluster = ~state_fips)
cat("Federal government placebo:\n")
print(summary(placebo_fed))

## ============================================================================
## CHECK 3: Placebo — Local Government Workers
## ============================================================================

cat("\n--- Placebo: Local Government ---\n")

placebo_local <- feols(share_no_ba_local ~ treated | state_fips + year,
                       data = analysis[!is.na(share_no_ba_local)],
                       weights = ~n_state_gov,
                       cluster = ~state_fips)
cat("Local government placebo:\n")
print(summary(placebo_local))

## ============================================================================
## CHECK 4: Heterogeneity by Labor Market Tightness
## ============================================================================

cat("\n--- Heterogeneity by Unemployment Rate ---\n")

## Create pre-treatment unemployment quartiles
pre_unemp <- analysis[year == 2021, .(state_fips, unemp_2021 = unemp_rate)]
analysis <- merge(analysis, pre_unemp, by = "state_fips", all.x = TRUE)

analysis[, tight_labor := as.integer(!is.na(unemp_2021) & unemp_2021 <= median(unemp_2021, na.rm = TRUE))]

hetero_labor <- feols(share_no_ba ~ treated * tight_labor | state_fips + year,
                      data = analysis,
                      weights = ~n_state_gov,
                      cluster = ~state_fips)
cat("Heterogeneity by labor market tightness:\n")
print(summary(hetero_labor))

## ============================================================================
## CHECK 5: Demographic Outcomes
## ============================================================================

cat("\n--- Demographic Outcomes ---\n")

## Effect on share Black
demo_black <- feols(pct_black ~ treated | state_fips + year,
                    data = analysis,
                    weights = ~n_state_gov,
                    cluster = ~state_fips)
cat("Effect on share Black workers:\n")
print(summary(demo_black))

## Effect on share female
demo_female <- feols(pct_female ~ treated | state_fips + year,
                     data = analysis,
                     weights = ~n_state_gov,
                     cluster = ~state_fips)
cat("Effect on share female workers:\n")
print(summary(demo_female))

## Effect on share young (25-34)
demo_young <- feols(pct_young ~ treated | state_fips + year,
                    data = analysis,
                    weights = ~n_state_gov,
                    cluster = ~state_fips)
cat("Effect on share young workers:\n")
print(summary(demo_young))

## ============================================================================
## CHECK 6: Wage Effects
## ============================================================================

cat("\n--- Wage Effects ---\n")

## Effect on mean wages (all state gov)
wage_all <- feols(log(mean_wages) ~ treated | state_fips + year,
                  data = analysis[mean_wages > 0],
                  weights = ~n_state_gov,
                  cluster = ~state_fips)
cat("Effect on log mean wages (all):\n")
print(summary(wage_all))

## Effect on wage gap between BA and non-BA
analysis[, wage_gap := mean_wages_ba - mean_wages_no_ba]
analysis[, log_wage_ratio := log(mean_wages_ba / mean_wages_no_ba)]

wage_gap <- feols(log_wage_ratio ~ treated | state_fips + year,
                  data = analysis[is.finite(log_wage_ratio)],
                  weights = ~n_state_gov,
                  cluster = ~state_fips)
cat("Effect on BA/non-BA wage ratio:\n")
print(summary(wage_gap))

## ============================================================================
## CHECK 7: HonestDiD Sensitivity (if CS results are available)
## ============================================================================

cat("\n--- HonestDiD Sensitivity Analysis ---\n")

tryCatch({
  ## Get CS event study results
  es_results <- es_cs

  ## Extract pre-treatment coefficients for sensitivity
  pre_coefs <- es_results$att.egt[es_results$egt < 0]
  pre_se <- es_results$se.egt[es_results$egt < 0]

  if (length(pre_coefs) >= 2) {
    cat("Pre-treatment coefficients for sensitivity:\n")
    for (i in seq_along(pre_coefs)) {
      cat(sprintf("  e=%d: %.4f (%.4f)\n",
                  es_results$egt[es_results$egt < 0][i], pre_coefs[i], pre_se[i]))
    }

    ## Report pre-test: are pre-treatment coefficients jointly zero?
    ## Simple Wald test
    wald_stat <- sum((pre_coefs / pre_se)^2)
    wald_p <- 1 - pchisq(wald_stat, df = length(pre_coefs))
    cat(sprintf("\nJoint pre-trend test: chi2(%d) = %.2f, p = %.4f\n",
                length(pre_coefs), wald_stat, wald_p))
  }
}, error = function(e) {
  cat("HonestDiD error:", conditionMessage(e), "\n")
})

## ============================================================================
## CHECK 8: Legislative vs Executive Order
## ============================================================================

cat("\n--- Legislative vs Executive Order ---\n")

analysis[, legis_treated := as.integer(policy_type == "legislative" & treated == 1)]
analysis[, exec_treated := as.integer(policy_type == "executive" & treated == 1)]

hetero_type <- feols(share_no_ba ~ legis_treated + exec_treated | state_fips + year,
                     data = analysis,
                     weights = ~n_state_gov,
                     cluster = ~state_fips)
cat("Legislative vs Executive Order:\n")
print(summary(hetero_type))

## ============================================================================
## SAVE RESULTS
## ============================================================================

save(placebo_fed, placebo_local, hetero_labor, demo_black, demo_female,
     demo_young, wage_all, wage_gap, hetero_type,
     file = paste0(data_dir, "robustness_results.RData"))

cat("\n=== Robustness checks complete ===\n")
