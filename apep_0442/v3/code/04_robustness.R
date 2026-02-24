## ============================================================================
## 04_robustness.R — Full robustness battery
## Project: The First Retirement Age v3
## ============================================================================

source("code/00_packages.R")

cat("=== ROBUSTNESS CHECKS ===\n\n")

cross <- readRDS(file.path(data_dir, "cross_section_sample.rds"))
panel <- readRDS(file.path(data_dir, "panel_sample.rds"))

cross[, age_1907 := 1907 - birth_year]
cross[, running := age_1907 - 62]
cross[, above_62 := as.integer(age_1907 >= 62)]

panel[, age_1907 := 1907 - birth_year]
panel[, running := age_1907 - 62]

## =========================================================================
## 1. BANDWIDTH SENSITIVITY
## =========================================================================
cat("--- 1. BANDWIDTH SENSITIVITY ---\n")
bw_grid <- c(2, 3, 4, 5, 6, 7, 8, 10, 12, 15)
bw_results <- list()

for (bw in bw_grid) {
  ## Cross-section
  fit_c <- tryCatch(rdrobust(cross$lfp_1910, cross$running, c = 0, h = bw),
                    error = function(e) NULL)
  ## Panel
  fit_p <- tryCatch(rdrobust(panel$delta_lfp, panel$running, c = 0, h = bw),
                    error = function(e) NULL)

  if (!is.null(fit_c)) {
    bw_results[[paste0("cross_", bw)]] <- data.table(
      design = "Cross-section", bandwidth = bw,
      coef = fit_c$coef[1], se = fit_c$se[3], pval = fit_c$pv[3],
      ci_lo = fit_c$ci[3, 1], ci_hi = fit_c$ci[3, 2],
      N_left = fit_c$N_h[1], N_right = fit_c$N_h[2])
  }
  if (!is.null(fit_p)) {
    bw_results[[paste0("panel_", bw)]] <- data.table(
      design = "Panel", bandwidth = bw,
      coef = fit_p$coef[1], se = fit_p$se[3], pval = fit_p$pv[3],
      ci_lo = fit_p$ci[3, 1], ci_hi = fit_p$ci[3, 2],
      N_left = fit_p$N_h[1], N_right = fit_p$N_h[2])
  }
}
bw_dt <- rbindlist(bw_results)
cat("Bandwidth grid results:\n")
print(bw_dt[, .(design, bandwidth, coef = round(coef, 4),
                se = round(se, 4), pval = round(pval, 3))])

## =========================================================================
## 2. DONUT-HOLE SPECIFICATIONS
## =========================================================================
cat("\n--- 2. DONUT-HOLE ---\n")
donut_results <- list()
for (donut in c(1, 2, 3)) {
  dt_donut <- cross[abs(running) >= donut]
  fit <- tryCatch(rdrobust(dt_donut$lfp_1910, dt_donut$running, c = 0),
                  error = function(e) NULL)
  if (!is.null(fit)) {
    donut_results[[as.character(donut)]] <- data.table(
      donut = donut, coef = fit$coef[1], se = fit$se[3], pval = fit$pv[3],
      N_left = fit$N_h[1], N_right = fit$N_h[2])
    cat(sprintf("  Donut=%d: coef=%.4f, se=%.4f, p=%.3f\n",
                donut, fit$coef[1], fit$se[3], fit$pv[3]))
  }
}

## Also exclude age heaping (ages 60, 65, 70)
dt_no_heap <- cross[!(age_1907 %in% c(60, 62, 65, 70))]
fit_heap <- rdrobust(dt_no_heap$lfp_1910, dt_no_heap$running, c = 0)
cat(sprintf("  No heaping ages: coef=%.4f, se=%.4f, p=%.3f\n",
            fit_heap$coef[1], fit_heap$se[3], fit_heap$pv[3]))

## =========================================================================
## 3. POLYNOMIAL ORDER
## =========================================================================
cat("\n--- 3. POLYNOMIAL ORDER ---\n")
for (p in 1:3) {
  fit <- tryCatch(rdrobust(cross$lfp_1910, cross$running, c = 0, p = p),
                  error = function(e) NULL)
  if (!is.null(fit))
    cat(sprintf("  Order %d: coef=%.4f, se=%.4f, p=%.3f\n",
                p, fit$coef[1], fit$se[3], fit$pv[3]))
}

## =========================================================================
## 4. KERNEL CHOICE
## =========================================================================
cat("\n--- 4. KERNEL ---\n")
for (k in c("triangular", "epanechnikov", "uniform")) {
  fit <- tryCatch(rdrobust(cross$lfp_1910, cross$running, c = 0, kernel = k),
                  error = function(e) NULL)
  if (!is.null(fit))
    cat(sprintf("  %s: coef=%.4f, se=%.4f, p=%.3f\n",
                k, fit$coef[1], fit$se[3], fit$pv[3]))
}

## =========================================================================
## 5. PLACEBO CUTOFFS
## =========================================================================
cat("\n--- 5. PLACEBO CUTOFFS ---\n")
placebo_results <- list()
for (age_cut in c(55, 58, 60, 64, 66, 68, 70)) {
  cross_tmp <- copy(cross)
  cross_tmp[, running_tmp := age_1907 - age_cut]
  fit <- tryCatch(rdrobust(cross_tmp$lfp_1910, cross_tmp$running_tmp, c = 0),
                  error = function(e) NULL)
  if (!is.null(fit)) {
    placebo_results[[as.character(age_cut)]] <- data.table(
      cutoff = age_cut, coef = fit$coef[1], se = fit$se[3], pval = fit$pv[3])
    cat(sprintf("  Age %d: coef=%.4f, se=%.4f, p=%.3f\n",
                age_cut, fit$coef[1], fit$se[3], fit$pv[3]))
  }
}
placebo_dt <- rbindlist(placebo_results)

## =========================================================================
## 6. AGE-CELL AGGREGATION (Lee & Card 2008)
## =========================================================================
cat("\n--- 6. AGE-CELL AGGREGATION ---\n")
cell <- cross[, .(lfp_mean = mean(lfp_1910), N = .N),
              by = .(age_1907)]
cell[, running := age_1907 - 62]
fit_cell <- tryCatch(
  rdrobust(cell$lfp_mean, cell$running, c = 0, weights = cell$N),
  error = function(e) {
    cat("Cell-level RDD failed:", e$message, "\n")
    ## Fallback: unweighted
    rdrobust(cell$lfp_mean, cell$running, c = 0)
  }
)
cat(sprintf("  Cell-level: coef=%.4f, se=%.4f, p=%.3f\n",
            fit_cell$coef[1], fit_cell$se[3], fit_cell$pv[3]))

## =========================================================================
## 7. HEALTH-CONTROLLED
## =========================================================================
cat("\n--- 7. HEALTH-CONTROLLED ---\n")
health_covs <- as.matrix(cross[, .(severity_pre, has_wound_pre, enlist_height)])
health_covs[is.na(health_covs)] <- 0
fit_health <- tryCatch(
  rdrobust(cross$lfp_1910, cross$running, c = 0, covs = health_covs),
  error = function(e) NULL)
if (!is.null(fit_health))
  cat(sprintf("  With health controls: coef=%.4f, se=%.4f, p=%.3f\n",
              fit_health$coef[1], fit_health$se[3], fit_health$pv[3]))

## =========================================================================
## 8. SELECTION INTO PANEL
## =========================================================================
cat("\n--- 8. PANEL SELECTION TEST ---\n")
## Test whether probability of being in panel sample is smooth at cutoff
dt_full <- readRDS(file.path(data_dir, "full_merged.rds"))
dt_full[, age_1907 := 1907 - birth_year]
dt_full[, running := age_1907 - 62]
dt_full[, in_panel := as.integer(recidnum %in% panel$recidnum)]

alive_full <- dt_full[alive_1910 == TRUE & !is.na(running)]
fit_sel <- tryCatch(
  rdrobust(alive_full$in_panel, alive_full$running, c = 0),
  error = function(e) NULL)
if (!is.null(fit_sel))
  cat(sprintf("  Panel selection: coef=%.4f, se=%.4f, p=%.3f\n",
              fit_sel$coef[1], fit_sel$se[3], fit_sel$pv[3]))

## =========================================================================
## 9. FALSIFICATION BANDWIDTH SENSITIVITY (Pre-treatment LFP in 1900)
## =========================================================================
cat("\n--- 9. FALSIFICATION BANDWIDTH SENSITIVITY ---\n")
falsif_bw_grid <- c(2, 3, 4, 5, 6, 7, 8, 10, 12, 15)
falsif_bw_results <- list()

for (bw in falsif_bw_grid) {
  fit_f <- tryCatch(rdrobust(panel$lfp_1900, panel$running, c = 0, h = bw),
                    error = function(e) NULL)
  if (!is.null(fit_f)) {
    falsif_p <- 2 * pnorm(-abs(fit_f$coef[1] / fit_f$se[3]))
    falsif_bw_results[[as.character(bw)]] <- data.table(
      bandwidth = bw,
      coef = fit_f$coef[1],
      se_robust = fit_f$se[3],
      pval = falsif_p,
      N_left = fit_f$N_h[1],
      N_right = fit_f$N_h[2])
    cat(sprintf("  BW=%2d: coef=%.4f, se=%.4f, p=%.3f (N_l=%d, N_r=%d)\n",
                bw, fit_f$coef[1], fit_f$se[3], falsif_p,
                fit_f$N_h[1], fit_f$N_h[2]))
  }
}
falsif_bw_dt <- rbindlist(falsif_bw_results)
cat("Falsification bandwidth sensitivity results:\n")
print(falsif_bw_dt[, .(bandwidth, coef = round(coef, 4),
                        se_robust = round(se_robust, 4), pval = round(pval, 3))])

## =========================================================================
## SAVE ALL
## =========================================================================
robust_results <- list(
  bandwidth = bw_dt,
  donut = rbindlist(donut_results),
  placebo = placebo_dt,
  cell_level = fit_cell,
  health_controlled = fit_health,
  panel_selection = fit_sel,
  falsif_bw = falsif_bw_dt
)
saveRDS(robust_results, file.path(data_dir, "robust_results.rds"))
cat("\n=== ROBUSTNESS COMPLETE ===\n")
