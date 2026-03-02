# ============================================================================
# 03_main_analysis.R — RDD estimation
# APEP-0443: PMGSY Roads and the Gender Gap in Non-Farm Employment
# ============================================================================

source("00_packages.R")

data_dir <- normalizePath(file.path(getwd(), "..", "data"), mustWork = FALSE)
df <- fread(file.path(data_dir, "plains_sample.csv"))

cat(sprintf("Plains sample: %d villages\n", nrow(df)))

# ── McCrary Density Test ───────────────────────────────────────────────────
cat("\n=== McCrary Density Test ===\n")
mccrary <- rddensity(df$running_var, c = 0)
cat(sprintf("T-statistic: %.3f, p-value: %.4f\n",
            mccrary$test$t_jk, mccrary$test$p_jk))
cat(sprintf("Interpretation: %s evidence of manipulation\n",
            ifelse(mccrary$test$p_jk < 0.05, "SIGNIFICANT", "No significant")))

# Save McCrary result
sink("../logs/mccrary_test.txt")
summary(mccrary)
sink()

# ── Covariate Balance Tests ────────────────────────────────────────────────
cat("\n=== Covariate Balance at Cutoff ===\n")
balance_vars <- c("sc_share01", "st_share01", "lit_rate01", "lit_rate_f01",
                  "lfpr01", "lfpr_f01", "nonag_share01", "nonag_share_f01")

balance_results <- data.frame(
  variable = character(),
  rd_est = numeric(),
  se = numeric(),
  pval = numeric(),
  bw = numeric(),
  n_eff = numeric(),
  stringsAsFactors = FALSE
)

for (v in balance_vars) {
  y <- df[[v]]
  valid <- !is.na(y)
  if (sum(valid) < 100) next

  rd <- tryCatch(
    rdrobust(y[valid], df$running_var[valid], c = 0, cluster = df$pc11_district_id[valid]),
    error = function(e) NULL
  )

  if (!is.null(rd)) {
    balance_results <- rbind(balance_results, data.frame(
      variable = v,
      rd_est = rd$coef[1],
      se = rd$se[3],       # robust
      pval = rd$pv[3],     # robust
      bw = rd$bws[1, 1],
      n_eff = rd$N_h[1] + rd$N_h[2]
    ))
    cat(sprintf("  %-25s: RD = %7.4f (SE = %.4f, p = %.4f)\n",
                v, rd$coef[1], rd$se[3], rd$pv[3]))
  }
}

fwrite(balance_results, "../tables/balance_test.csv")

# ── Main RDD Estimates ─────────────────────────────────────────────────────
cat("\n=== Main RDD Estimates ===\n")

outcome_vars <- list(
  list(name = "nonag_share_f11", label = "Female Non-Ag Share (2011)"),
  list(name = "nonag_share_m11", label = "Male Non-Ag Share (2011)"),
  list(name = "d_nonag_share_f", label = "Change in Female Non-Ag Share"),
  list(name = "d_nonag_share_m", label = "Change in Male Non-Ag Share"),
  list(name = "lfpr_f11",        label = "Female LFPR (2011)"),
  list(name = "d_lfpr_f",        label = "Change in Female LFPR"),
  list(name = "d_gender_gap_nonag", label = "Change in Gender Gap (Non-Ag)"),
  list(name = "lit_rate_f11",    label = "Female Literacy Rate (2011)"),
  list(name = "d_lit_rate_f",    label = "Change in Female Literacy")
)

main_results <- data.frame(
  outcome = character(),
  rd_conv = numeric(),
  rd_robust = numeric(),
  se_conv = numeric(),
  se_robust = numeric(),
  pval_robust = numeric(),
  bw_main = numeric(),
  bw_bias = numeric(),
  n_left = numeric(),
  n_right = numeric(),
  n_eff_left = numeric(),
  n_eff_right = numeric(),
  stringsAsFactors = FALSE
)

rd_objects <- list()

for (ov in outcome_vars) {
  y <- df[[ov$name]]
  valid <- !is.na(y) & !is.na(df$running_var)

  if (sum(valid) < 200) {
    cat(sprintf("  %-40s: SKIPPED (N=%d too small)\n", ov$label, sum(valid)))
    next
  }

  rd <- tryCatch(
    rdrobust(y[valid], df$running_var[valid], c = 0,
             cluster = df$pc11_district_id[valid]),
    error = function(e) {
      cat(sprintf("  %-40s: ERROR — %s\n", ov$label, e$message))
      NULL
    }
  )

  if (!is.null(rd)) {
    rd_objects[[ov$name]] <- rd

    main_results <- rbind(main_results, data.frame(
      outcome     = ov$label,
      rd_conv     = rd$coef[1],
      rd_robust   = rd$coef[2],
      se_conv     = rd$se[1],
      se_robust   = rd$se[3],
      pval_robust = rd$pv[3],
      bw_main     = rd$bws[1, 1],
      bw_bias     = rd$bws[2, 1],
      n_left      = rd$N[1],
      n_right     = rd$N[2],
      n_eff_left  = rd$N_h[1],
      n_eff_right = rd$N_h[2]
    ))

    stars <- ifelse(rd$pv[3] < 0.01, "***",
             ifelse(rd$pv[3] < 0.05, "**",
             ifelse(rd$pv[3] < 0.10, "*", "")))

    cat(sprintf("  %-40s: RD = %7.4f%s (SE = %.4f, p = %.4f, BW = %.0f, N_eff = %d)\n",
                ov$label, rd$coef[2], stars, rd$se[3], rd$pv[3],
                rd$bws[1, 1], rd$N_h[1] + rd$N_h[2]))
  }
}

fwrite(main_results, "../tables/main_results.csv")

# ── Save RDD objects for figures ───────────────────────────────────────────
saveRDS(rd_objects, "../data/rd_objects.rds")
saveRDS(mccrary, "../data/mccrary_result.rds")

cat("\nMain analysis complete. Results saved to tables/ and data/\n")
