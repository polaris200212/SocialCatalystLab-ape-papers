##############################################################################
# 03_main_analysis.R — Primary RDD estimation
# Paper: Does Place-Based Climate Policy Work? (apep_0418)
##############################################################################

source("code/00_packages.R")

cat("=== STEP 3: Main RDD Analysis ===\n\n")

###############################################################################
# 1. Load analysis sample
###############################################################################
rdd_sample <- readRDS(file.path(DATA_DIR, "rdd_sample.rds"))
cat("RDD sample:", nrow(rdd_sample), "areas\n")
cat("Energy communities:", sum(rdd_sample$energy_community), "\n")
cat("Non-energy communities:", sum(!rdd_sample$energy_community), "\n\n")

###############################################################################
# 2. McCrary density test (manipulation)
###############################################################################
cat("--- McCrary Density Test ---\n")

density_test <- rddensity(
  X = rdd_sample$ff_share,
  c = 0.17
)

cat("  Test statistic:", round(density_test$test$t_jk, 3), "\n")
cat("  P-value:", round(density_test$test$p_jk, 3), "\n")
cat("  Interpretation: ",
    ifelse(density_test$test$p_jk > 0.05,
           "No evidence of manipulation (GOOD)",
           "WARNING: Possible manipulation"), "\n\n")

saveRDS(density_test, file.path(DATA_DIR, "mccrary_test.rds"))

###############################################################################
# 3. Main RDD — Clean energy capacity
###############################################################################
cat("--- Main RDD: Post-IRA clean energy capacity ---\n")

# Outcome: post-IRA clean energy MW per 1000 employees
# Running variable: FF employment share (centered at 0.17%)

# Check if we have sufficient outcome variation
cat("  Outcome (post_ira_mw_per_1000emp) summary:\n")
cat("    Mean:", round(mean(rdd_sample$post_ira_mw_per_1000emp, na.rm = TRUE), 3), "\n")
cat("    SD:", round(sd(rdd_sample$post_ira_mw_per_1000emp, na.rm = TRUE), 3), "\n")
cat("    N non-missing:", sum(!is.na(rdd_sample$post_ira_mw_per_1000emp)), "\n\n")

# Model 1: Sharp RDD, no covariates
rd_main <- rdrobust(
  y = rdd_sample$post_ira_mw_per_1000emp,
  x = rdd_sample$ff_share,
  c = 0.17,
  all = TRUE
)

cat("  Model 1: Sharp RDD (no covariates)\n")
cat("    Conventional estimate:", round(rd_main$coef[1], 3), "\n")
cat("    Robust bias-corrected:", round(rd_main$coef[3], 3), "\n")
cat("    Robust SE:", round(rd_main$se[3], 3), "\n")
cat("    Robust p-value:", round(rd_main$pv[3], 4), "\n")
cat("    Bandwidth (h):", round(rd_main$bws[1, 1], 4), "\n")
cat("    N left:", rd_main$N_h[1], " N right:", rd_main$N_h[2], "\n\n")

saveRDS(rd_main, file.path(DATA_DIR, "rd_main_nocov.rds"))

# Model 2: With covariates
covariates <- rdd_sample %>%
  select(pop, med_income, pct_bachelors, pct_white) %>%
  mutate(across(everything(), ~replace_na(.x, median(.x, na.rm = TRUE)))) %>%
  as.matrix()

rd_cov <- rdrobust(
  y = rdd_sample$post_ira_mw_per_1000emp,
  x = rdd_sample$ff_share,
  c = 0.17,
  covs = covariates,
  all = TRUE
)

cat("  Model 2: Sharp RDD (with covariates)\n")
cat("    Conventional estimate:", round(rd_cov$coef[1], 3), "\n")
cat("    Robust bias-corrected:", round(rd_cov$coef[3], 3), "\n")
cat("    Robust SE:", round(rd_cov$se[3], 3), "\n")
cat("    Robust p-value:", round(rd_cov$pv[3], 4), "\n")
cat("    Bandwidth (h):", round(rd_cov$bws[1, 1], 4), "\n\n")

saveRDS(rd_cov, file.path(DATA_DIR, "rd_main_cov.rds"))

# Model 3: Quadratic polynomial
rd_quad <- rdrobust(
  y = rdd_sample$post_ira_mw_per_1000emp,
  x = rdd_sample$ff_share,
  c = 0.17,
  p = 2,
  all = TRUE
)

cat("  Model 3: Quadratic polynomial\n")
cat("    Conventional estimate:", round(rd_quad$coef[1], 3), "\n")
cat("    Robust p-value:", round(rd_quad$pv[3], 4), "\n\n")

saveRDS(rd_quad, file.path(DATA_DIR, "rd_main_quad.rds"))

###############################################################################
# 4. RDD on total clean energy (not just post-IRA)
###############################################################################
cat("--- RDD: Total clean energy capacity ---\n")

rd_total <- rdrobust(
  y = rdd_sample$clean_mw_per_1000emp,
  x = rdd_sample$ff_share,
  c = 0.17,
  all = TRUE
)

cat("  Total clean energy RD:\n")
cat("    Estimate:", round(rd_total$coef[3], 3), "\n")
cat("    p-value:", round(rd_total$pv[3], 4), "\n\n")

saveRDS(rd_total, file.path(DATA_DIR, "rd_total_clean.rds"))

###############################################################################
# 5. Covariate balance tests
###############################################################################
cat("--- Covariate Balance at Threshold ---\n")

# Use log transforms for count variables to avoid implausibly large coefficients
rdd_sample$log_pop <- log(rdd_sample$pop + 1)
rdd_sample$log_total_emp <- log(rdd_sample$total_emp + 1)
rdd_sample$log_total_estab <- log(rdd_sample$total_estab + 1)
rdd_sample$log_med_income <- log(rdd_sample$med_income + 1)

cov_names <- c("log_pop", "log_med_income", "pct_bachelors", "pct_white",
               "log_total_emp", "log_total_estab", "unemp_rate")

balance_results <- list()
for (cov in cov_names) {
  if (cov %in% names(rdd_sample) && sum(!is.na(rdd_sample[[cov]])) > 20) {
    rd_bal <- tryCatch({
      rdrobust(
        y = rdd_sample[[cov]],
        x = rdd_sample$ff_share,
        c = 0.17,
        all = TRUE
      )
    }, error = function(e) NULL)

    if (!is.null(rd_bal)) {
      balance_results[[cov]] <- data.frame(
        covariate = cov,
        estimate = rd_bal$coef[3],
        se = rd_bal$se[3],
        p_value = rd_bal$pv[3],
        n_left = rd_bal$N_h[1],
        n_right = rd_bal$N_h[2]
      )
      cat("  ", cov, ": est =", round(rd_bal$coef[3], 3),
          " p =", round(rd_bal$pv[3], 3), "\n")
    }
  }
}

balance_df <- bind_rows(balance_results)
saveRDS(balance_df, file.path(DATA_DIR, "covariate_balance.rds"))

cat("\n  Balance check:", sum(balance_df$p_value < 0.05), "of",
    nrow(balance_df), "covariates significant at 5%\n\n")

###############################################################################
# 6. Parametric RDD (OLS for comparison)
###############################################################################
cat("--- Parametric RDD (OLS) ---\n")

# Linear specification within bandwidth
bw <- rd_main$bws[1, 1]  # Use main RDD optimal bandwidth
rdd_bw <- rdd_sample %>%
  filter(abs(ff_share - 0.17) <= bw)

ols_linear <- feols(
  post_ira_mw_per_1000emp ~ above_ff_threshold * running_var,
  data = rdd_bw,
  vcov = "hetero"
)

cat("  OLS Linear (within optimal bandwidth):\n")
cat("    Treatment effect:", round(coef(ols_linear)["above_ff_thresholdTRUE"], 3), "\n")
cat("    SE:", round(sqrt(vcov(ols_linear)["above_ff_thresholdTRUE", "above_ff_thresholdTRUE"]), 3), "\n")
cat("    N:", nobs(ols_linear), "\n\n")

saveRDS(ols_linear, file.path(DATA_DIR, "ols_rd_linear.rds"))

# With covariates
ols_cov <- feols(
  post_ira_mw_per_1000emp ~ above_ff_threshold * running_var +
    log(pop + 1) + med_income + pct_bachelors,
  data = rdd_bw,
  vcov = "hetero"
)

saveRDS(ols_cov, file.path(DATA_DIR, "ols_rd_cov.rds"))

###############################################################################
# 7. Summary of main results
###############################################################################
cat("====================================\n")
cat("MAIN RESULTS SUMMARY\n")
cat("====================================\n\n")

results_summary <- data.frame(
  model = c("Sharp RDD (no cov)", "Sharp RDD (with cov)", "Quadratic", "OLS (bw)"),
  estimate = c(rd_main$coef[3], rd_cov$coef[3], rd_quad$coef[3],
               coef(ols_linear)["above_ff_thresholdTRUE"]),
  se = c(rd_main$se[3], rd_cov$se[3], rd_quad$se[3],
         sqrt(vcov(ols_linear)["above_ff_thresholdTRUE", "above_ff_thresholdTRUE"])),
  p_value = c(rd_main$pv[3], rd_cov$pv[3], rd_quad$pv[3], NA)
)

results_summary$ci_lower <- results_summary$estimate - 1.96 * results_summary$se
results_summary$ci_upper <- results_summary$estimate + 1.96 * results_summary$se

print(results_summary)
saveRDS(results_summary, file.path(DATA_DIR, "main_results_summary.rds"))

cat("\n=== Main analysis complete ===\n")
