## ============================================================================
## 03b_first_stage.R — Observed first stage and fuzzy RDD
## Project: The First Retirement Age v3
## ============================================================================

source("code/00_packages.R")

cat("=== FIRST STAGE & FUZZY RDD ===\n\n")

## Load data
cross <- readRDS(file.path(data_dir, "cross_section_sample.rds"))

## Running variable: age at 1907 (when Act passed)
cross[, running := age_1907 - 62]
cross[, above_62 := as.integer(age_1907 >= 62)]

## =========================================================================
## 1. FIRST STAGE: Pension take-up at age 62
## =========================================================================

cat("--- 1. PENSION TAKE-UP (1907 Act) AT AGE 62 ---\n")

## Binary: under 1907 Act
rdd_fs_binary <- rdrobust(cross$under_1907_act, cross$running, c = 0)
cat("1907 Act receipt:\n")
cat("  Coef:", round(rdd_fs_binary$coef[1], 4), "\n")
cat("  SE:", round(rdd_fs_binary$se[3], 4), "\n")
cat("  P-value:", round(rdd_fs_binary$pv[3], 4), "\n")
cat("  BW:", round(rdd_fs_binary$bws[1, 1], 2), "\n")
cat("  N_left:", rdd_fs_binary$N_h[1], "  N_right:", rdd_fs_binary$N_h[2], "\n\n")

## Any pension at 1910
rdd_fs_any <- rdrobust(cross$has_pension_1910, cross$running, c = 0)
cat("Any pension receipt:\n")
cat("  Coef:", round(rdd_fs_any$coef[1], 4), "\n")
cat("  SE:", round(rdd_fs_any$se[3], 4), "\n")
cat("  P-value:", round(rdd_fs_any$pv[3], 4), "\n\n")

## =========================================================================
## 2. FIRST STAGE: Pension amount at age 62
## =========================================================================

cat("--- 2. PENSION AMOUNT AT AGE 62 ---\n")

rdd_fs_amt <- rdrobust(cross$pen_dollars_1910, cross$running, c = 0)
cat("Pension $ at 1910:\n")
cat("  Coef:", round(rdd_fs_amt$coef[1], 4), "\n")
cat("  SE:", round(rdd_fs_amt$se[3], 4), "\n")
cat("  P-value:", round(rdd_fs_amt$pv[3], 4), "\n\n")

## Dollar increase
rdd_fs_change <- rdrobust(cross$pen_change, cross$running, c = 0)
cat("Pension $ change (1910 vs 1900):\n")
cat("  Coef:", round(rdd_fs_change$coef[1], 4), "\n")
cat("  SE:", round(rdd_fs_change$se[3], 4), "\n")
cat("  P-value:", round(rdd_fs_change$pv[3], 4), "\n\n")

## =========================================================================
## 3. FIRST STAGE BY AGE (raw tabulation)
## =========================================================================

cat("--- 3. FIRST STAGE BY AGE ---\n")
fs_by_age <- cross[age_1907 >= 55 & age_1907 <= 80,
                    .(pct_1907act = mean(under_1907_act, na.rm = TRUE),
                      pct_any_pension = mean(has_pension_1910, na.rm = TRUE),
                      mean_pen_amt = mean(pen_dollars_1910, na.rm = TRUE),
                      mean_lfp = mean(lfp_1910, na.rm = TRUE),
                      N = .N),
                    by = age_1907][order(age_1907)]
print(fs_by_age)

## =========================================================================
## 4. FUZZY RDD / 2SLS LATE
## =========================================================================

cat("\n--- 4. FUZZY RDD (LATE) ---\n")
cat("Instrumenting pension receipt with age >= 62\n\n")

## Fuzzy RDD using rdrobust
rdd_fuzzy <- tryCatch(
  rdrobust(cross$lfp_1910, cross$running, c = 0,
           fuzzy = cross$under_1907_act),
  error = function(e) {
    cat("rdrobust fuzzy failed:", e$message, "\n")
    NULL
  }
)

if (!is.null(rdd_fuzzy)) {
  cat("Fuzzy RDD (1907 Act → LFP):\n")
  cat("  LATE:", round(rdd_fuzzy$coef[1], 4), "\n")
  cat("  SE:", round(rdd_fuzzy$se[3], 4), "\n")
  cat("  P-value:", round(rdd_fuzzy$pv[3], 4), "\n")
  cat("  95% CI: [", round(rdd_fuzzy$ci[3, 1], 4), ",",
      round(rdd_fuzzy$ci[3, 2], 4), "]\n\n")
}

## Manual 2SLS within bandwidth (for comparison)
cat("Manual 2SLS (within optimal bandwidth):\n")
bw <- rdd_fs_binary$bws[1, 1]
dt_bw <- cross[abs(running) <= bw]

if (nrow(dt_bw) > 50) {
  ## First stage
  fs <- lm(under_1907_act ~ above_62 + running + above_62:running,
           data = dt_bw)
  cat("  First stage F-stat:", round(summary(fs)$fstatistic[1], 2), "\n")
  cat("  First stage coef:", round(coef(fs)["above_62"], 4), "\n")

  ## 2SLS
  iv <- tryCatch(
    ivreg(lfp_1910 ~ under_1907_act + running |
            above_62 + running + above_62:running,
          data = dt_bw),
    error = function(e) NULL
  )
  if (!is.null(iv)) {
    iv_sum <- summary(iv, diagnostics = TRUE)
    cat("  2SLS LATE:", round(coef(iv)["under_1907_act"], 4), "\n")
    cat("  SE:", round(sqrt(vcovHC(iv, type = "HC1")["under_1907_act", "under_1907_act"]), 4), "\n")
  }
}

## Fuzzy RDD with pension amount as treatment
rdd_fuzzy_amt <- tryCatch(
  rdrobust(cross$lfp_1910, cross$running, c = 0,
           fuzzy = cross$pen_dollars_1910),
  error = function(e) {
    cat("Fuzzy RDD (amount) failed:", e$message, "\n")
    NULL
  }
)

if (!is.null(rdd_fuzzy_amt)) {
  cat("\nFuzzy RDD (pension $ → LFP):\n")
  cat("  LATE per $:", round(rdd_fuzzy_amt$coef[1], 4), "\n")
  cat("  SE:", round(rdd_fuzzy_amt$se[3], 4), "\n")
  cat("  P-value:", round(rdd_fuzzy_amt$pv[3], 4), "\n")
}

## =========================================================================
## SAVE
## =========================================================================

first_stage_results <- list(
  fs_binary = rdd_fs_binary,
  fs_any = rdd_fs_any,
  fs_amount = rdd_fs_amt,
  fs_change = rdd_fs_change,
  fuzzy_binary = rdd_fuzzy,
  fuzzy_amount = rdd_fuzzy_amt,
  fs_by_age = fs_by_age
)

saveRDS(first_stage_results, file.path(data_dir, "first_stage_results.rds"))
cat("\nAll first stage results saved.\n")
cat("=== FIRST STAGE COMPLETE ===\n")
