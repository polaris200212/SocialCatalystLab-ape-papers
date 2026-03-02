## ============================================================================
## 03_main_analysis.R — Main RDD analysis at age 62 threshold (1.4% oversampled census)
## Project: The First Retirement Age v2 (revision of apep_0442)
## ============================================================================

source("code/00_packages.R")

## ---- 1. Load data ----
union <- readRDS(file.path(data_dir, "union_veterans.rds"))
cat("Union veterans loaded:", format(nrow(union), big.mark = ","), "\n")
cat("Below age 62:", format(sum(union$AGE < 62), big.mark = ","), "\n")
cat("At or above age 62:", format(sum(union$AGE >= 62), big.mark = ","), "\n")

## ---- Initialize results container ----
main_results <- list()
main_results$sample_sizes <- list(
  total = nrow(union),
  below_62 = sum(union$AGE < 62),
  above_62 = sum(union$AGE >= 62)
)

## ---- 2. McCrary density test at age 62 ----
cat("\n=== McCrary Density Test ===\n")
density_test <- rddensity(union$AGE, c = 62)
cat("T-statistic:", round(density_test$test$t_jk, 3), "\n")
cat("P-value:", round(density_test$test$p_jk, 4), "\n")

main_results$density_test <- list(
  t_stat = density_test$test$t_jk,
  p_value = density_test$test$p_jk
)

if (density_test$test$p_jk < 0.05) {
  cat("NOTE: Density discontinuity at threshold.\n")
  cat("Likely reflects age heaping at round numbers, not manipulation.\n")
  cat("Donut-hole and RI will address this.\n")
} else {
  cat("PASS: No evidence of density discontinuity at threshold.\n")
}

## ---- 3. Covariate balance at threshold ----
cat("\n=== Covariate Balance Tests ===\n")
covariates <- c("literate", "native_born", "married", "urban", "white")

balance_results <- data.table(
  covariate = character(),
  rd_estimate = numeric(),
  se = numeric(),
  pvalue = numeric(),
  bw_left = numeric(),
  bw_right = numeric(),
  n_left = numeric(),
  n_right = numeric(),
  mean_below = numeric(),
  mean_above = numeric()
)

for (cov in covariates) {
  y <- union[[cov]]
  if (all(is.na(y))) next

  tryCatch({
    rd <- rdrobust(y, union$AGE, c = 62, kernel = "triangular", p = 1)

    # Use local polynomial fitted values at the cutoff (tau_cl)
    # These are consistent with the RD estimate = tau_cl[2] - tau_cl[1]
    fitted_left <- rd$tau_cl[1]
    fitted_right <- rd$tau_cl[2]

    balance_results <- rbind(balance_results, data.table(
      covariate = cov,
      rd_estimate = rd$coef["Conventional", 1],
      se = rd$se["Conventional", 1],
      pvalue = rd$pv["Conventional", 1],
      bw_left = rd$bws["h", "left"],
      bw_right = rd$bws["h", "right"],
      n_left = rd$N_h[1],
      n_right = rd$N_h[2],
      mean_below = fitted_left,
      mean_above = fitted_right
    ))
    cat(sprintf("  %-15s: coef = %7.4f (SE = %6.4f), p = %.3f, N = %d + %d %s\n",
                cov, rd$coef["Conventional", 1], rd$se["Conventional", 1],
                rd$pv["Conventional", 1], rd$N_h[1], rd$N_h[2],
                ifelse(rd$pv["Conventional", 1] < 0.05, " *", "")))
  }, error = function(e) {
    cat(sprintf("  %-15s: ERROR - %s\n", cov, e$message))
  })
}

saveRDS(balance_results, file.path(data_dir, "balance_results.rds"))

## ---- 4. Main RDD: Labor Force Participation ----
cat("\n=== Main Result: Labor Force Participation ===\n")

# Primary specification: local linear, triangular kernel
rd_lfp <- rdrobust(union$in_labor_force, union$AGE, c = 62,
                    kernel = "triangular", p = 1)
summary(rd_lfp)

main_results$lfp <- rd_lfp

cat("\nKey Statistics:\n")
cat("  RD estimate:", round(rd_lfp$coef["Conventional", 1], 4), "\n")
cat("  SE:", round(rd_lfp$se["Conventional", 1], 4), "\n")
cat("  P-value:", round(rd_lfp$pv["Conventional", 1], 4), "\n")
cat("  Bandwidth (left/right):", round(rd_lfp$bws["h", "left"], 1), "/",
    round(rd_lfp$bws["h", "right"], 1), "\n")
cat("  Effective N (left + right):", rd_lfp$N_h[1], "+", rd_lfp$N_h[2], "\n")
cat("  95% CI: [", round(rd_lfp$coef["Conventional", 1] - 1.96 * rd_lfp$se["Conventional", 1], 4),
    ",", round(rd_lfp$coef["Conventional", 1] + 1.96 * rd_lfp$se["Conventional", 1], 4), "]\n")

# Compute baseline LFP mean (below cutoff, within bandwidth)
bw_main <- rd_lfp$bws["h", "left"]
baseline_lfp <- mean(union$in_labor_force[union$AGE >= (62 - bw_main) & union$AGE < 62], na.rm = TRUE)
cat("  Baseline LFP (below cutoff):", round(baseline_lfp, 3), "\n")
main_results$baseline_lfp <- baseline_lfp

# MDE calculation (80% power, 5% significance)
mde <- 2.8 * rd_lfp$se["Conventional", 1]
cat("  Minimum detectable effect (80% power):", round(mde, 4), "\n")
main_results$mde <- mde

## ---- 5. Bias-corrected and robust estimates ----
cat("\n--- Bias-Corrected and Robust Estimates ---\n")
cat("  Bias-corrected:", round(rd_lfp$coef["Bias-Corrected", 1], 4),
    "(SE:", round(rd_lfp$se["Robust", 1], 4), ")\n")
cat("  Robust:", round(rd_lfp$coef["Robust", 1], 4),
    "(SE:", round(rd_lfp$se["Robust", 1], 4), ")\n")

# Quadratic specification
rd_lfp_quad <- rdrobust(union$in_labor_force, union$AGE, c = 62,
                         kernel = "triangular", p = 2)
main_results$lfp_quad <- rd_lfp_quad
cat("  Quadratic:", round(rd_lfp_quad$coef["Conventional", 1], 4),
    "(SE:", round(rd_lfp_quad$se["Conventional", 1], 4), ")\n")

## ---- 6. Secondary Outcomes ----
cat("\n=== Secondary Outcomes ===\n")

outcomes <- list(
  "Has Occupation" = "has_occupation",
  "Professional" = "professional",
  "Farm Occupation" = "farm_occ",
  "Manual Labor" = "manual_labor",
  "Owns Home" = "owns_home",
  "Household Head" = "is_head"
)

secondary_results <- data.table(
  outcome = character(),
  coef = numeric(),
  se = numeric(),
  pvalue = numeric(),
  bw_left = numeric(),
  bw_right = numeric(),
  n_left = numeric(),
  n_right = numeric(),
  baseline_mean = numeric(),
  ci_lower = numeric(),
  ci_upper = numeric()
)

for (nm in names(outcomes)) {
  var <- outcomes[[nm]]
  y <- union[[var]]

  tryCatch({
    rd <- rdrobust(y, union$AGE, c = 62, kernel = "triangular", p = 1)
    main_results[[var]] <- rd

    bw <- rd$bws["h", "left"]
    baseline <- mean(y[union$AGE >= (62 - bw) & union$AGE < 62], na.rm = TRUE)

    secondary_results <- rbind(secondary_results, data.table(
      outcome = nm,
      coef = rd$coef["Conventional", 1],
      se = rd$se["Conventional", 1],
      pvalue = rd$pv["Conventional", 1],
      bw_left = rd$bws["h", "left"],
      bw_right = rd$bws["h", "right"],
      n_left = rd$N_h[1],
      n_right = rd$N_h[2],
      baseline_mean = baseline,
      ci_lower = rd$coef["Conventional", 1] - 1.96 * rd$se["Conventional", 1],
      ci_upper = rd$coef["Conventional", 1] + 1.96 * rd$se["Conventional", 1]
    ))

    cat(sprintf("  %-20s: coef = %7.4f (SE = %6.4f), p = %.3f, N = %d + %d\n",
                nm, rd$coef["Conventional", 1], rd$se["Conventional", 1],
                rd$pv["Conventional", 1], rd$N_h[1], rd$N_h[2]))
  }, error = function(e) {
    cat(sprintf("  %-20s: ERROR - %s\n", nm, e$message))
  })
}

## ---- 7. Confederate Veterans Placebo ----
cat("\n=== Confederate Veterans Placebo Test ===\n")
confed <- readRDS(file.path(data_dir, "confed_veterans.rds"))
cat("Confederate veterans:", format(nrow(confed), big.mark = ","), "\n")
cat("Below age 62:", format(sum(confed$AGE < 62), big.mark = ","), "\n")

tryCatch({
  rd_confed <- rdrobust(confed$in_labor_force, confed$AGE, c = 62,
                        kernel = "triangular", p = 1)
  main_results$confed_lfp <- rd_confed

  cat("  LFP discontinuity at 62:", round(rd_confed$coef["Conventional", 1], 4), "\n")
  cat("  SE:", round(rd_confed$se["Conventional", 1], 4), "\n")
  cat("  P-value:", round(rd_confed$pv["Conventional", 1], 4), "\n")
  cat("  N (left + right):", rd_confed$N_h[1], "+", rd_confed$N_h[2], "\n")

  if (rd_confed$pv["Conventional", 1] > 0.10) {
    cat("  PASS: No significant discontinuity for Confederate veterans.\n")
  } else {
    cat("  NOTE: Significant discontinuity for Confederates.\n")
    cat("  Diff-in-disc (03b) will difference this out.\n")
  }
}, error = function(e) {
  cat("  Confederate placebo could not be estimated:", e$message, "\n")
})

## ---- 8. Save all results ----
saveRDS(main_results, file.path(data_dir, "main_results.rds"))
saveRDS(secondary_results, file.path(data_dir, "secondary_results.rds"))

cat("\n=== Analysis Summary ===\n")
cat("Primary outcome (LFP):\n")
cat("  RD estimate:", round(rd_lfp$coef["Conventional", 1], 4), "\n")
cat("  SE:", round(rd_lfp$se["Conventional", 1], 4), "\n")
cat("  P-value:", round(rd_lfp$pv["Conventional", 1], 4), "\n")
cat("  MDE (80% power):", round(mde, 4), "\n")
cat("  Effective N:", rd_lfp$N_h[1], "+", rd_lfp$N_h[2], "\n")

cat("\nMain analysis complete.\n")
