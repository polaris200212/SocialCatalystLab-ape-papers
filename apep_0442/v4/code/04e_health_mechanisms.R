## ============================================================================
## 04e_health_mechanisms.R — Health analysis from surgeons' certificates
## Project: The First Retirement Age v3
## ============================================================================

source("code/00_packages.R")

cat("=== HEALTH MECHANISMS ===\n\n")

cross <- readRDS(file.path(data_dir, "cross_section_sample.rds"))
cross[, age_1907 := 1907 - birth_year]
cross[, running := age_1907 - 62]

## =========================================================================
## 1. PRE-TREATMENT HEALTH BALANCE
## =========================================================================
cat("--- 1. PRE-TREATMENT HEALTH BALANCE AT CUTOFF ---\n")
health_vars <- c("severity_pre", "n_diagnoses_pre", "has_wound_pre",
                 "cardiac_pre", "wound_rating_pre", "enlist_height")

health_balance <- list()
for (v in health_vars) {
  y <- cross[[v]]
  valid <- !is.na(y)
  if (sum(valid) > 200) {
    fit <- tryCatch(rdrobust(y[valid], cross$running[valid], c = 0),
                    error = function(e) NULL)
    if (!is.null(fit)) {
      hb_p <- 2 * pnorm(-abs(fit$coef[1] / fit$se[3]))
      health_balance[[v]] <- data.table(
        variable = v, coef = fit$coef[1], se = fit$se[3], pval = hb_p,
        bw = fit$bws[1, 1], N_left = fit$N_h[1], N_right = fit$N_h[2])
      cat(sprintf("  %s: coef=%.3f, se=%.3f, p=%.3f\n",
                  v, fit$coef[1], fit$se[3], fit$pv[3]))
    }
  }
}
health_bal_dt <- rbindlist(health_balance)

## =========================================================================
## 2. POST-1907 HEALTH OUTCOMES
## =========================================================================
cat("\n--- 2. POST-1907 HEALTH OUTCOMES ---\n")

## Did pension eligibility change health trajectories?
post_vars <- c("severity_post", "n_diagnoses_post", "cardiac_post")

health_post_results <- list()
for (v in post_vars) {
  y <- cross[[v]]
  valid <- !is.na(y)
  if (sum(valid) > 100) {
    fit <- tryCatch(rdrobust(y[valid], cross$running[valid], c = 0),
                    error = function(e) NULL)
    if (!is.null(fit)) {
      health_post_results[[v]] <- data.table(
        variable = v, coef = fit$coef[1], se = fit$se[3], pval = fit$pv[3])
      cat(sprintf("  %s: coef=%.3f, se=%.3f, p=%.3f\n",
                  v, fit$coef[1], fit$se[3], fit$pv[3]))
    }
  }
}

## =========================================================================
## 3. HEALTH CHANGES (among those with both pre and post exams)
## =========================================================================
cat("\n--- 3. HEALTH CHANGES ---\n")
change_vars <- c("severity_change", "n_diagnoses_change", "cardiac_change")

health_change_results <- list()
for (v in change_vars) {
  y <- cross[[v]]
  valid <- !is.na(y)
  if (sum(valid) > 100) {
    fit <- tryCatch(rdrobust(y[valid], cross$running[valid], c = 0),
                    error = function(e) NULL)
    if (!is.null(fit)) {
      hc_p <- 2 * pnorm(-abs(fit$coef[1] / fit$se[3]))
      health_change_results[[v]] <- data.table(
        variable = v, coef = fit$coef[1], se = fit$se[3], pval = hc_p,
        bw = fit$bws[1, 1], N_left = fit$N_h[1], N_right = fit$N_h[2])
      cat(sprintf("  %s: coef=%.3f, se=%.3f, p=%.3f\n",
                  v, fit$coef[1], fit$se[3], fit$pv[3]))
    }
  }
}

## =========================================================================
## 4. BMI AS OUTCOME
## =========================================================================
cat("\n--- 4. BMI AT 1910 ---\n")
valid_bmi <- !is.na(cross$bmi_1910)
if (sum(valid_bmi) > 100) {
  fit_bmi <- tryCatch(
    rdrobust(cross$bmi_1910[valid_bmi], cross$running[valid_bmi], c = 0),
    error = function(e) NULL)
  if (!is.null(fit_bmi))
    cat(sprintf("  BMI 1910: coef=%.3f, se=%.3f, p=%.3f\n",
                fit_bmi$coef[1], fit_bmi$se[3], fit_bmi$pv[3]))
}

## =========================================================================
## 5. MORTALITY ANALYSIS
## =========================================================================
cat("\n--- 5. MORTALITY ---\n")
## Does pension eligibility affect mortality?
dt_full <- readRDS(file.path(data_dir, "full_merged.rds"))
dt_full[, age_1907 := 1907 - birth_year]
dt_full[, running := age_1907 - 62]

## Restrict to those alive in 1907 (could be affected by pension)
alive07 <- dt_full[alive_1907 == TRUE & !is.na(running)]

## Survived to 1910 (alive_1910)
alive07[, survived_1910 := as.integer(alive_1910)]
fit_mort <- tryCatch(
  rdrobust(alive07$survived_1910, alive07$running, c = 0),
  error = function(e) NULL)
if (!is.null(fit_mort))
  cat(sprintf("  Survival to 1910: coef=%.4f, se=%.4f, p=%.3f\n",
              fit_mort$coef[1], fit_mort$se[3], fit_mort$pv[3]))

## Survived to 1915
alive07[, survived_1915 := as.integer(is.na(death_yr) | death_yr >= 1915)]
fit_mort15 <- tryCatch(
  rdrobust(alive07$survived_1915, alive07$running, c = 0),
  error = function(e) NULL)
if (!is.null(fit_mort15))
  cat(sprintf("  Survival to 1915: coef=%.4f, se=%.4f, p=%.3f\n",
              fit_mort15$coef[1], fit_mort15$se[3], fit_mort15$pv[3]))

## =========================================================================
## SAVE
## =========================================================================
health_results <- list(
  balance = health_bal_dt,
  post_outcomes = rbindlist(health_post_results),
  changes = rbindlist(health_change_results),
  mortality = list(fit_mort, fit_mort15)
)
saveRDS(health_results, file.path(data_dir, "health_results.rds"))
cat("\n=== HEALTH MECHANISMS COMPLETE ===\n")
