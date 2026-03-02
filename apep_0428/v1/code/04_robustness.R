## ============================================================
## 04_robustness.R — Validity tests and robustness checks
## PMGSY 250 Threshold RDD — Tribal/Hill Areas
## ============================================================

source(file.path(dirname(sub("--file=", "", grep("--file=", commandArgs(FALSE), value=TRUE))), "00_packages.R"))

out_dir <- file.path(WORK_DIR, "data")
tab_dir <- file.path(WORK_DIR, "tables")
fig_dir <- file.path(WORK_DIR, "figures")

sample_A <- readRDS(file.path(out_dir, "sample_250_A.rds"))
sample_B <- readRDS(file.path(out_dir, "sample_250_B.rds"))
df_full  <- readRDS(file.path(out_dir, "analysis_full.rds"))

run_rdd <- function(data, outcome, rv = "rv_250", cutoff = 0,
                    kernel = "triangular", p = 1, h = NULL) {
  y <- data[[outcome]]
  x <- data[[rv]]
  valid <- !is.na(y) & !is.na(x)
  if (sum(valid) < 100) return(list(coef = NA, se = NA, pval = NA, bw = NA, n_eff = NA))
  fit <- tryCatch(
    rdrobust(y = y[valid], x = x[valid], c = cutoff, kernel = kernel, p = p, h = h),
    error = function(e) NULL
  )
  if (is.null(fit)) return(list(coef = NA, se = NA, pval = NA, bw = NA, n_eff = NA))
  list(coef = fit$coef["Robust", ], se = fit$se["Robust", ],
       pval = fit$pv["Robust", ], bw = fit$bws[1, 1],
       n_eff = fit$N_h[1] + fit$N_h[2])
}

# ============================================================
# 1. McCrary Density Test
# ============================================================

cat("=== McCrary Density Test at 250 (Sample A) ===\n")
mccrary_A <- rddensity(X = sample_A$rv_250, c = 0)
cat(sprintf("  T-statistic: %.3f, p-value: %.4f\n",
            mccrary_A$test$t_jk, mccrary_A$test$p_jk))
cat(sprintf("  Conclusion: %s\n",
            ifelse(mccrary_A$test$p_jk < 0.05,
                   "MANIPULATION DETECTED (p < 0.05)",
                   "No evidence of manipulation (p >= 0.05)")))

cat("\n=== McCrary Density Test at 250 (Sample B) ===\n")
mccrary_B <- rddensity(X = sample_B$rv_250, c = 0)
cat(sprintf("  T-statistic: %.3f, p-value: %.4f\n",
            mccrary_B$test$t_jk, mccrary_B$test$p_jk))

saveRDS(list(A = mccrary_A, B = mccrary_B),
        file.path(out_dir, "mccrary_results.rds"))

# ============================================================
# 2. Covariate Balance at 250 Threshold
# ============================================================

cat("\n=== Covariate Balance Tests (Sample A) ===\n")

covariates <- c(
  "literacy_01"        = "Literacy Rate (2001)",
  "f_lit_01"           = "Female Literacy (2001)",
  "sc_share_01"        = "SC Share (2001)",
  "st_share_01"        = "ST Share (2001)",
  "worker_share_01"    = "Worker Share (2001)",
  "f_worker_share_01"  = "Female Worker Share (2001)",
  "main_worker_share_01" = "Main Worker Share (2001)",
  "log_nl_pre"         = "Log Nightlights (1994-2000)"
)

balance_results <- list()
for (var in names(covariates)) {
  res <- run_rdd(sample_A, var)
  balance_results[[var]] <- res
  sig <- ifelse(is.na(res$pval), "", ifelse(res$pval < 0.05, " ***", ""))
  cat(sprintf("  %-30s  coef=% .4f  se=%.4f  p=%.3f%s\n",
              covariates[var],
              ifelse(is.na(res$coef), NA, res$coef),
              ifelse(is.na(res$se), NA, res$se),
              ifelse(is.na(res$pval), NA, res$pval), sig))
}

saveRDS(balance_results, file.path(out_dir, "balance_results.rds"))

# ============================================================
# 3. Bandwidth Sensitivity
# ============================================================

cat("\n=== Bandwidth Sensitivity (Literacy 2011, Sample A) ===\n")

# Get optimal bandwidth first
base_fit <- tryCatch(
  rdrobust(y = sample_A$literacy_11[!is.na(sample_A$literacy_11)],
           x = sample_A$rv_250[!is.na(sample_A$literacy_11)], c = 0),
  error = function(e) NULL
)

if (!is.null(base_fit)) {
  h_opt <- base_fit$bws[1, 1]
  bw_mults <- c(0.5, 0.75, 1.0, 1.25, 1.5, 2.0)

  bw_results <- data.frame(
    multiplier = bw_mults,
    bandwidth = h_opt * bw_mults,
    coef = NA_real_, se = NA_real_, pval = NA_real_, n_eff = NA_integer_
  )

  for (i in seq_along(bw_mults)) {
    h <- h_opt * bw_mults[i]
    res <- run_rdd(sample_A, "literacy_11", h = h)
    bw_results$coef[i]  <- res$coef
    bw_results$se[i]    <- res$se
    bw_results$pval[i]  <- res$pval
    bw_results$n_eff[i] <- res$n_eff
  }

  cat(sprintf("  Optimal bandwidth: %.0f\n", h_opt))
  print(bw_results)
  saveRDS(bw_results, file.path(out_dir, "bw_sensitivity.rds"))
}

# ============================================================
# 4. Placebo Thresholds
# ============================================================

cat("\n=== Placebo Thresholds (Literacy 2011, designated_A areas) ===\n")

placebo_thresholds <- c(150, 200, 300, 350, 400)
placebo_data <- df_full[designated_A == TRUE & pop_01 >= 50 & pop_01 <= 550]

placebo_results <- data.frame(
  threshold = placebo_thresholds,
  coef = NA_real_, se = NA_real_, pval = NA_real_
)

for (i in seq_along(placebo_thresholds)) {
  thr <- placebo_thresholds[i]
  rv <- placebo_data$pop_01 - thr
  y <- placebo_data$literacy_11
  valid <- !is.na(y) & !is.na(rv)

  fit <- tryCatch(
    rdrobust(y = y[valid], x = rv[valid], c = 0),
    error = function(e) NULL
  )

  if (!is.null(fit)) {
    placebo_results$coef[i] <- fit$coef["Robust", ]
    placebo_results$se[i]   <- fit$se["Robust", ]
    placebo_results$pval[i] <- fit$pv["Robust", ]
  }
}

cat("  True threshold (250) should show effect; placebos should not:\n")
print(placebo_results)
saveRDS(placebo_results, file.path(out_dir, "placebo_results.rds"))

# ============================================================
# 5. Polynomial Order Sensitivity
# ============================================================

cat("\n=== Polynomial Order Sensitivity (Sample A) ===\n")

key_outcomes <- c("literacy_11", "f_lit_11", "nonag_share_11", "log_nl_post_viirs")
poly_results <- list()

for (var in key_outcomes) {
  for (p_order in 1:2) {
    res <- run_rdd(sample_A, var, p = p_order)
    poly_results[[paste0(var, "_p", p_order)]] <- res
    cat(sprintf("  %-30s  p=%d  coef=% .4f  se=%.4f  p=%.3f\n",
                var, p_order,
                ifelse(is.na(res$coef), NA, res$coef),
                ifelse(is.na(res$se), NA, res$se),
                ifelse(is.na(res$pval), NA, res$pval)))
  }
}

saveRDS(poly_results, file.path(out_dir, "poly_sensitivity.rds"))

# ============================================================
# 6. Donut-Hole RDD
# ============================================================

cat("\n=== Donut-Hole RDD (excluding pop 245-255, Sample A) ===\n")

sample_donut <- sample_A[pop_01 < 245 | pop_01 > 255]
cat(sprintf("  Donut sample: %s villages (dropped %d at exact threshold)\n",
            format(nrow(sample_donut), big.mark = ","),
            nrow(sample_A) - nrow(sample_donut)))

donut_results <- list()
for (var in key_outcomes) {
  res <- run_rdd(sample_donut, var)
  donut_results[[var]] <- res
  cat(sprintf("  %-30s  coef=% .4f  se=%.4f  p=%.3f\n",
              var,
              ifelse(is.na(res$coef), NA, res$coef),
              ifelse(is.na(res$se), NA, res$se),
              ifelse(is.na(res$pval), NA, res$pval)))
}

saveRDS(donut_results, file.path(out_dir, "donut_results.rds"))

# ============================================================
# 7. Nightlights Event Study (Year-by-Year RDD)
# ============================================================

cat("\n=== Nightlights Event Study (DMSP year-by-year RDD) ===\n")

dmsp <- readRDS(file.path(out_dir, "dmsp.rds"))

# Merge designated area flag
desig <- df_full[, .(shrid2, designated_A, pop_01, rv_250)]

dmsp_desig <- merge(dmsp, desig, by = "shrid2")
dmsp_desig <- dmsp_desig[designated_A == TRUE & pop_01 >= 50 & pop_01 <= 500]
dmsp_desig[, log_nl := log(dmsp_total_light_cal + 0.01)]

years_dmsp <- sort(unique(dmsp_desig$year))
nl_event <- data.frame(year = years_dmsp, coef = NA, se = NA, pval = NA, n = NA)

for (i in seq_along(years_dmsp)) {
  yr <- years_dmsp[i]
  sub <- dmsp_desig[year == yr]
  y <- sub$log_nl
  x <- sub$rv_250
  valid <- !is.na(y) & !is.na(x)

  if (sum(valid) < 200) next

  fit <- tryCatch(rdrobust(y = y[valid], x = x[valid], c = 0), error = function(e) NULL)
  if (!is.null(fit)) {
    nl_event$coef[i] <- fit$coef["Robust", ]
    nl_event$se[i]   <- fit$se["Robust", ]
    nl_event$pval[i] <- fit$pv["Robust", ]
    nl_event$n[i]    <- fit$N_h[1] + fit$N_h[2]
  }
}

cat(nl_event %>% mutate(across(c(coef, se, pval), ~round(., 4))) %>%
      capture.output() %>% paste(collapse = "\n"))

# VIIRS event study
viirs <- readRDS(file.path(out_dir, "viirs.rds"))
viirs_desig <- merge(viirs, desig, by = "shrid2")
viirs_desig <- viirs_desig[designated_A == TRUE & pop_01 >= 50 & pop_01 <= 500]
viirs_desig[, log_nl := log(viirs_annual_sum + 0.01)]

years_viirs <- sort(unique(viirs_desig$year))
nl_event_viirs <- data.frame(year = years_viirs, coef = NA, se = NA, pval = NA, n = NA)

for (i in seq_along(years_viirs)) {
  yr <- years_viirs[i]
  sub <- viirs_desig[year == yr]
  y <- sub$log_nl
  x <- sub$rv_250
  valid <- !is.na(y) & !is.na(x)

  if (sum(valid) < 200) next

  fit <- tryCatch(rdrobust(y = y[valid], x = x[valid], c = 0), error = function(e) NULL)
  if (!is.null(fit)) {
    nl_event_viirs$coef[i] <- fit$coef["Robust", ]
    nl_event_viirs$se[i]   <- fit$se["Robust", ]
    nl_event_viirs$pval[i] <- fit$pv["Robust", ]
    nl_event_viirs$n[i]    <- fit$N_h[1] + fit$N_h[2]
  }
}

saveRDS(list(dmsp = nl_event, viirs = nl_event_viirs),
        file.path(out_dir, "nl_event_study.rds"))

cat("\nRobustness checks complete.\n")
