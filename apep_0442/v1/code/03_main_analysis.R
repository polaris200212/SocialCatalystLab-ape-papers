## ============================================================================
## 03_main_analysis.R — Main RDD analysis at age 62 threshold
## Project: The First Retirement Age (apep_0442)
## ============================================================================

source("code/00_packages.R")

## ---- 1. Load data ----
union <- readRDS(file.path(data_dir, "union_veterans.rds"))
cat("Union veterans loaded:", format(nrow(union), big.mark = ","), "\n")

## ---- Initialize results container ----
main_results <- list()

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
  cat("WARNING: Evidence of manipulation at threshold (p < 0.05)\n")
  cat("This may reflect age heaping. Will check with donut-hole.\n")
} else {
  cat("PASS: No evidence of manipulation at threshold.\n")
}

## ---- 3. Covariate balance at threshold ----
cat("\n=== Covariate Balance Tests ===\n")
covariates <- c("literate", "native_born", "married", "urban", "white")

# Create white indicator
union[, white := as.integer(RACE == 1)]

balance_results <- data.table(
  covariate = character(),
  rd_estimate = numeric(),
  se = numeric(),
  pvalue = numeric()
)

for (cov in covariates) {
  y <- union[[cov]]
  if (all(is.na(y))) next

  tryCatch({
    rd <- rdrobust(y, union$AGE, c = 62, kernel = "triangular", p = 1)
    balance_results <- rbind(balance_results, data.table(
      covariate = cov,
      rd_estimate = rd$coef["Conventional", 1],
      se = rd$se["Conventional", 1],
      pvalue = rd$pv["Conventional", 1]
    ))
    cat(sprintf("  %-15s: coef = %7.4f (SE = %6.4f), p = %.3f %s\n",
                cov, rd$coef["Conventional", 1], rd$se["Conventional", 1],
                rd$pv["Conventional", 1],
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

# Store results
main_results$lfp <- rd_lfp

cat("\nInterpretation: Crossing age 62 threshold",
    ifelse(rd_lfp$coef["Conventional", 1] < 0, "reduces", "increases"),
    "labor force participation by",
    round(abs(rd_lfp$coef["Conventional", 1]) * 100, 1),
    "percentage points.\n")

## ---- 5. Secondary Outcomes ----
cat("\n=== Secondary Outcomes ===\n")

outcomes <- list(
  "Has Occupation" = "has_occupation",
  "Professional" = "professional",
  "Farm Occupation" = "farm_occ",
  "Manual Labor" = "manual_labor",
  "Owns Home" = "owns_home",
  "Household Head" = "is_head",
  "Independent Living" = "independent"
)

secondary_results <- data.table(
  outcome = character(),
  coef = numeric(),
  se = numeric(),
  pvalue = numeric(),
  bw_left = numeric(),
  bw_right = numeric(),
  n_eff = numeric(),
  baseline_mean = numeric()
)

for (nm in names(outcomes)) {
  var <- outcomes[[nm]]
  y <- union[[var]]

  tryCatch({
    rd <- rdrobust(y, union$AGE, c = 62, kernel = "triangular", p = 1)
    main_results[[var]] <- rd

    # Baseline mean (below cutoff, within bandwidth)
    bw <- rd$bws["h", "left"]
    baseline <- mean(y[union$AGE >= (62 - bw) & union$AGE < 62], na.rm = TRUE)

    secondary_results <- rbind(secondary_results, data.table(
      outcome = nm,
      coef = rd$coef["Conventional", 1],
      se = rd$se["Conventional", 1],
      pvalue = rd$pv["Conventional", 1],
      bw_left = rd$bws["h", "left"],
      bw_right = rd$bws["h", "right"],
      n_eff = rd$N_h[1] + rd$N_h[2],
      baseline_mean = baseline
    ))

    cat(sprintf("  %-20s: coef = %7.4f (SE = %6.4f), p = %.3f, bw = [%.1f, %.1f]\n",
                nm, rd$coef["Conventional", 1], rd$se["Conventional", 1],
                rd$pv["Conventional", 1], rd$bws["h", "left"], rd$bws["h", "right"]))
  }, error = function(e) {
    cat(sprintf("  %-20s: ERROR - %s\n", nm, e$message))
  })
}

## ---- 6. Confederate Veterans Placebo ----
cat("\n=== Confederate Veterans Placebo Test ===\n")
confed <- readRDS(file.path(data_dir, "confed_veterans.rds"))
cat("Confederate veterans:", format(nrow(confed), big.mark = ","), "\n")

if (nrow(confed) >= 50) {
  tryCatch({
    rd_confed <- rdrobust(confed$in_labor_force, confed$AGE, c = 62,
                          kernel = "triangular", p = 1)
    main_results$confed_lfp <- rd_confed

    cat("  LFP discontinuity at 62:", round(rd_confed$coef["Conventional", 1], 4), "\n")
    cat("  SE:", round(rd_confed$se["Conventional", 1], 4), "\n")
    cat("  P-value:", round(rd_confed$pv["Conventional", 1], 4), "\n")

    if (rd_confed$pv["Conventional", 1] > 0.10) {
      cat("  PASS: No significant discontinuity for Confederate veterans.\n")
      cat("  This supports the pension interpretation.\n")
    } else {
      cat("  WARNING: Significant discontinuity for Confederates.\n")
      cat("  May indicate aging effect rather than pension effect.\n")
    }
  }, error = function(e) {
    cat("  Confederate placebo could not be estimated:", e$message, "\n")
  })
} else {
  cat("  Too few Confederate veterans for placebo test.\n")
}

## ---- 7. Save all results ----
saveRDS(main_results, file.path(data_dir, "main_results.rds"))
saveRDS(secondary_results, file.path(data_dir, "secondary_results.rds"))

cat("\n=== Analysis Summary ===\n")
cat("Primary outcome (LFP):\n")
cat("  RD estimate:", round(rd_lfp$coef["Conventional", 1], 4), "\n")
cat("  SE:", round(rd_lfp$se["Conventional", 1], 4), "\n")
cat("  P-value:", round(rd_lfp$pv["Conventional", 1], 4), "\n")
cat("  Optimal bandwidth:", round(rd_lfp$bws["h", "left"], 1), "/",
    round(rd_lfp$bws["h", "right"], 1), "\n")
cat("  Effective N:", rd_lfp$N_h[1], "+", rd_lfp$N_h[2], "\n")

cat("\nMain analysis complete.\n")
