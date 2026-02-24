## ============================================================================
## 03_main_analysis.R — Primary RDD analysis (cross-section + panel)
## Project: The First Retirement Age v3
## Running variable: age_1907 = 1907 - birth_year, cutoff at 62
## Note: age_1907 gives N_left~2,500 vs. N_left~150 with age_1910
## Veterans aged 62+ when the Act passed were immediately eligible
## ============================================================================

source("code/00_packages.R")

cat("=== MAIN RDD ANALYSIS ===\n\n")

## Load data
cross <- readRDS(file.path(data_dir, "cross_section_sample.rds"))
panel <- readRDS(file.path(data_dir, "panel_sample.rds"))

## Primary running variable: age at 1907 (when Act was passed)
cross[, running := age_1907 - 62]
cross[, above_62 := as.integer(age_1907 >= 62)]

panel[, running := age_1907 - 62]
panel[, above_62 := as.integer(age_1907 >= 62)]

## Also keep age_1910 for robustness
cross[, age_1910 := 1910 - birth_year]
panel[, age_1910 := 1910 - birth_year]

cat("Cross-section: N_below_62 =", sum(cross$above_62 == 0),
    ", N_above_62 =", sum(cross$above_62 == 1), "\n")
cat("Panel: N_below_62 =", sum(panel$above_62 == 0),
    ", N_above_62 =", sum(panel$above_62 == 1), "\n\n")

## =========================================================================
## 1. VALIDITY TESTS
## =========================================================================

cat("--- 1. McCRARY DENSITY TEST ---\n")
density_test <- rddensity(cross$running)
cat("T-statistic:", round(density_test$test$t_jk, 3), "\n")
cat("P-value:", round(density_test$test$p_jk, 4), "\n\n")
saveRDS(density_test, file.path(data_dir, "density_test.rds"))

cat("--- 2. COVARIATE BALANCE ---\n")
balance_vars <- c("literate", "native_born", "homeowner", "enlist_height",
                  "has_wound_pre", "severity_pre", "bmi_1900")

balance_results <- list()
for (v in balance_vars) {
  y <- cross[[v]]
  valid <- !is.na(y) & !is.na(cross$running)
  if (sum(valid) > 100) {
    fit <- tryCatch(
      rdrobust(y[valid], cross$running[valid], c = 0),
      error = function(e) NULL
    )
    if (!is.null(fit)) {
      balance_results[[v]] <- data.table(
        variable = v, coef = fit$coef[1], se = fit$se[3], pval = fit$pv[3],
        ci_lo = fit$ci[3, 1], ci_hi = fit$ci[3, 2],
        bw = fit$bws[1, 1], N_left = fit$N_h[1], N_right = fit$N_h[2])
      cat(sprintf("  %s: coef=%.3f, se=%.3f, p=%.3f\n", v,
                  fit$coef[1], fit$se[3], fit$pv[3]))
    }
  }
}
balance_dt <- rbindlist(balance_results)
saveRDS(balance_dt, file.path(data_dir, "balance_results.rds"))

## =========================================================================
## 2. DESIGN A — CROSS-SECTIONAL RDD (LFP at 1910)
## =========================================================================

cat("\n--- 3. CROSS-SECTIONAL RDD (LFP_1910) ---\n")
rdd_cross <- rdrobust(cross$lfp_1910, cross$running, c = 0)
cat("Bandwidth:", round(rdd_cross$bws[1, 1], 2), "\n")
cat("N_left:", rdd_cross$N_h[1], "  N_right:", rdd_cross$N_h[2], "\n")
cat("Coef (conventional):", round(rdd_cross$coef[1], 4), "\n")
cat("Coef (bias-corrected):", round(rdd_cross$coef[2], 4), "\n")
cat("SE (robust):", round(rdd_cross$se[3], 4), "\n")
cat("P-value (robust):", round(rdd_cross$pv[3], 4), "\n")
cat("95% CI (robust): [", round(rdd_cross$ci[3, 1], 4), ",",
    round(rdd_cross$ci[3, 2], 4), "]\n\n")

## Bandwidth sensitivity
cat("Bandwidth sensitivity (cross-section):\n")
bw_grid <- c(2, 3, 4, 5, 6, 7, 8, 10, 12, 15)
cross_bw_results <- list()
for (bw in bw_grid) {
  fit <- tryCatch(
    rdrobust(cross$lfp_1910, cross$running, c = 0, h = bw),
    error = function(e) NULL)
  if (!is.null(fit)) {
    cross_bw_results[[as.character(bw)]] <- data.table(
      bandwidth = bw, coef = fit$coef[1], coef_bc = fit$coef[2],
      se_robust = fit$se[3], pval = fit$pv[3],
      ci_lo = fit$ci[3, 1], ci_hi = fit$ci[3, 2],
      N_left = fit$N_h[1], N_right = fit$N_h[2])
    cat(sprintf("  bw=%2d: coef=%.4f, se=%.4f, p=%.3f, N=%d+%d\n",
                bw, fit$coef[1], fit$se[3], fit$pv[3], fit$N_h[1], fit$N_h[2]))
  }
}

## With covariates
covars <- as.matrix(cross[, .(literate, native_born, homeowner)])
covars[is.na(covars)] <- 0
rdd_cross_cov <- rdrobust(cross$lfp_1910, cross$running, c = 0, covs = covars)
cat("\nWith covariates: coef=", round(rdd_cross_cov$coef[1], 4),
    "se=", round(rdd_cross_cov$se[3], 4),
    "p=", round(rdd_cross_cov$pv[3], 4), "\n")

## =========================================================================
## 3. DESIGN B — PANEL RDD (HEADLINE)
## =========================================================================

cat("\n--- 4. PANEL RDD (ΔY = LFP_1910 - LFP_1900) ---\n")
rdd_panel <- rdrobust(panel$delta_lfp, panel$running, c = 0)
cat("Bandwidth:", round(rdd_panel$bws[1, 1], 2), "\n")
cat("N_left:", rdd_panel$N_h[1], "  N_right:", rdd_panel$N_h[2], "\n")
cat("Coef (conventional):", round(rdd_panel$coef[1], 4), "\n")
cat("Coef (bias-corrected):", round(rdd_panel$coef[2], 4), "\n")
cat("SE (robust):", round(rdd_panel$se[3], 4), "\n")
cat("P-value (robust):", round(rdd_panel$pv[3], 4), "\n")
cat("95% CI (robust): [", round(rdd_panel$ci[3, 1], 4), ",",
    round(rdd_panel$ci[3, 2], 4), "]\n\n")

## Panel with covariates
covars_p <- as.matrix(panel[, .(literate, native_born, homeowner)])
covars_p[is.na(covars_p)] <- 0
rdd_panel_cov <- rdrobust(panel$delta_lfp, panel$running, c = 0, covs = covars_p)
cat("Panel with covariates: coef=", round(rdd_panel_cov$coef[1], 4),
    "se=", round(rdd_panel_cov$se[3], 4),
    "p=", round(rdd_panel_cov$pv[3], 4), "\n")

## Panel bandwidth sensitivity
cat("\nPanel bandwidth sensitivity:\n")
panel_bw_results <- list()
for (bw in bw_grid) {
  fit <- tryCatch(
    rdrobust(panel$delta_lfp, panel$running, c = 0, h = bw),
    error = function(e) NULL)
  if (!is.null(fit)) {
    panel_bw_results[[as.character(bw)]] <- data.table(
      bandwidth = bw, coef = fit$coef[1], se = fit$se[3], pval = fit$pv[3],
      N_left = fit$N_h[1], N_right = fit$N_h[2])
    cat(sprintf("  bw=%2d: coef=%.4f, se=%.4f, p=%.3f, N=%d+%d\n",
                bw, fit$coef[1], fit$se[3], fit$pv[3], fit$N_h[1], fit$N_h[2]))
  }
}

## =========================================================================
## 4. DESIGN C — PRE-TREATMENT FALSIFICATION
## =========================================================================

cat("\n--- 5. PRE-TREATMENT FALSIFICATION (LFP_1900) ---\n")
rdd_pre <- rdrobust(panel$lfp_1900, panel$running, c = 0)
cat("Bandwidth:", round(rdd_pre$bws[1, 1], 2), "\n")
cat("Coef:", round(rdd_pre$coef[1], 4), "\n")
cat("SE:", round(rdd_pre$se[3], 4), "\n")
cat("P-value:", round(rdd_pre$pv[3], 4), "\n")
cat("95% CI: [", round(rdd_pre$ci[3, 1], 4), ",",
    round(rdd_pre$ci[3, 2], 4), "]\n")

## =========================================================================
## 5. PARAMETRIC SPECIFICATIONS
## =========================================================================

cat("\n--- 6. PARAMETRIC SPECIFICATIONS (bw=8) ---\n")
for (deg in 1:3) {
  dt_bw <- cross[abs(running) <= 8]
  if (deg == 1) {
    fit <- lm(lfp_1910 ~ above_62 * running, data = dt_bw)
  } else if (deg == 2) {
    fit <- lm(lfp_1910 ~ above_62 * poly(running, 2, raw = TRUE), data = dt_bw)
  } else {
    fit <- lm(lfp_1910 ~ above_62 * poly(running, 3, raw = TRUE), data = dt_bw)
  }
  coef_val <- coef(fit)["above_62"]
  se_val <- sqrt(vcovHC(fit, type = "HC1")["above_62", "above_62"])
  cat(sprintf("  Poly %d: coef=%.4f, se=%.4f, t=%.2f\n",
              deg, coef_val, se_val, coef_val / se_val))
}

## =========================================================================
## 6. ROBUSTNESS: AGE AT 1910 (secondary running variable)
## =========================================================================

cat("\n--- 7. ROBUSTNESS: AGE AT 1910 CENSUS (secondary RV) ---\n")
cross[, running_1910 := age_1910 - 62]
rdd_1910 <- rdrobust(cross$lfp_1910, cross$running_1910, c = 0)
cat("Age-at-1910 RDD:\n")
cat("  BW:", round(rdd_1910$bws[1, 1], 2),
    "N_left:", rdd_1910$N_h[1], "N_right:", rdd_1910$N_h[2], "\n")
cat("  Coef:", round(rdd_1910$coef[1], 4),
    "SE:", round(rdd_1910$se[3], 4),
    "P:", round(rdd_1910$pv[3], 4), "\n")

## =========================================================================
## 7. POWER CALCULATION
## =========================================================================

cat("\n--- 8. POWER ---\n")
## Within optimal bandwidth
bw_opt <- rdd_cross$bws[1, 1]
dt_opt <- cross[abs(running) <= bw_opt]
n_l <- sum(dt_opt$running < 0)
n_r <- sum(dt_opt$running >= 0)
sd_y <- sd(dt_opt$lfp_1910)
mde <- 2.8 * sd_y * sqrt(1/n_l + 1/n_r)
cat("Optimal BW:", round(bw_opt, 2), "\n")
cat("N_left:", n_l, " N_right:", n_r, "\n")
cat("MDE (80% power):", round(mde, 4), "\n")

## With bw=5
dt5 <- cross[abs(running) <= 5]
mde5 <- 2.8 * sd(dt5$lfp_1910) * sqrt(1/sum(dt5$running < 0) + 1/sum(dt5$running >= 0))
cat("MDE (bw=5):", round(mde5, 4), "\n")

## =========================================================================
## SAVE ALL
## =========================================================================

main_results <- list(
  cross_section = rdd_cross,
  cross_section_cov = rdd_cross_cov,
  panel = rdd_panel,
  panel_cov = rdd_panel_cov,
  pre_treatment = rdd_pre,
  density = density_test,
  balance = balance_dt,
  bw_cross = rbindlist(cross_bw_results),
  bw_panel = rbindlist(panel_bw_results),
  rdd_1910 = rdd_1910
)
saveRDS(main_results, file.path(data_dir, "main_results.rds"))
cat("\nAll results saved to main_results.rds\n")
cat("=== MAIN ANALYSIS COMPLETE ===\n")
