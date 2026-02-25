# ============================================================================
# 03_main_analysis.R — Primary DiD regressions
# GST and Interstate Price Convergence
# ============================================================================

source("00_packages.R")

cpi <- fread("../data/cpi_panel.csv")
cpi[, date := as.Date(date)]

# ── 1. BASELINE DiD: General CPI ─────────────────────────────────────────
cat("=== Model 1: Baseline Continuous-Intensity DiD (General CPI) ===\n\n")

gen <- cpi[group == "General" & !is.na(index)]

# Primary specification: state + time FE
m1 <- feols(log_index ~ post_gst:tax_intensity | state_id + time,
            data = gen, cluster = ~state_id)
cat("Model 1: Post-GST × Tax Intensity\n")
print(summary(m1))

# ── 2. EVENT STUDY: Monthly leads and lags ────────────────────────────────
cat("\n=== Model 2: Event Study (General CPI) ===\n\n")

# Bin endpoints: group months beyond -24 and +36 for cleaner display
gen[, rel_month_binned := pmax(-24, pmin(36, rel_month))]

m2 <- feols(log_index ~ i(rel_month_binned, tax_intensity, ref = -1) |
              state_id + time,
            data = gen, cluster = ~state_id)
cat("Event study estimated with", length(coef(m2)), "coefficients\n")

# Save event study coefficients for plotting
es_coef <- as.data.table(coeftable(m2), keep.rownames = TRUE)
setnames(es_coef, c("term", "estimate", "se", "t", "p"))
es_coef[, rel_month := as.integer(gsub("rel_month_binned::", "", gsub(":tax_intensity", "", term)))]
es_coef <- es_coef[!is.na(rel_month)]
es_coef[, ci_lo := estimate - 1.96 * se]
es_coef[, ci_hi := estimate + 1.96 * se]
fwrite(es_coef, "../data/event_study_general.csv")

# ── 3. COMMODITY-GROUP DiD ────────────────────────────────────────────────
cat("\n=== Model 3: Commodity-Group Heterogeneity ===\n\n")

# Exclude "General" and "Consumer Food Price" (aggregates of sub-groups)
comm <- cpi[!group %in% c("General", "Consumer Food Price") & !is.na(index)]

# State × group FE + group × time FE
m3 <- feols(log_index ~ post_gst:tax_intensity:delta_tax |
              state_id^group_id + group_id^time,
            data = comm, cluster = ~state_id)
cat("Model 3: Post-GST × Tax Intensity × Commodity ΔTax\n")
print(summary(m3))

# ── 4. TRIPLE-DIFF with full FE structure ────────────────────────────────
cat("\n=== Model 4: Triple-Diff (State × Commodity × Time) ===\n\n")

m4 <- feols(log_index ~ post_gst:tax_intensity:abs_delta_tax |
              state_id^group_id + group_id^time + state_id^time,
            data = comm, cluster = ~state_id)
cat("Model 4: Triple-Diff with State×Time FE\n")
print(summary(m4))

# ── 5. BY COMMODITY GROUP ─────────────────────────────────────────────────
cat("\n=== Model 5: Separate regressions by commodity group ===\n\n")

groups <- unique(cpi[!group %in% c("General", "Consumer Food Price"), group])
group_results <- list()

for (g in groups) {
  sub <- cpi[group == g & !is.na(index)]
  if (nrow(sub) < 100) next
  fit <- tryCatch(
    feols(log_index ~ post_gst:tax_intensity | state_id + time,
          data = sub, cluster = ~state_id),
    error = function(e) {
      cat(sprintf("  %-30s  SKIPPED (collinearity): %s\n", g, e$message))
      NULL
    }
  )
  if (is.null(fit)) next
  coefs <- coeftable(fit)
  group_results[[g]] <- data.table(
    group = g,
    estimate = coefs[1, 1],
    se = coefs[1, 2],
    t_stat = coefs[1, 3],
    p_val = coefs[1, 4]
  )
  cat(sprintf("  %-30s  β = %7.4f (SE = %.4f, p = %.3f)\n",
              g, coefs[1, 1], coefs[1, 2], coefs[1, 4]))
}

group_dt <- rbindlist(group_results)
fwrite(group_dt, "../data/group_level_results.csv")

# ── 6. PRE-TREND F-TEST ──────────────────────────────────────────────────
cat("\n=== Model 6: Pre-trend test (pre-GST only) ===\n\n")

gen_pre <- gen[post_gst == 0]
m6 <- feols(log_index ~ i(year, tax_intensity, ref = 2013) | state_id + time,
            data = gen_pre, cluster = ~state_id)
cat("Pre-trend test: interaction of year × intensity (ref = 2013):\n")
print(summary(m6))

# Joint F-test for pre-trend coefficients
pre_test <- wald(m6, "tax_intensity")
cat("\nJoint F-test for pre-trends: F =", round(pre_test$stat, 2),
    ", p =", round(pre_test$p, 4), "\n")

# ── 7. BINARY TREATMENT (above/below median) ─────────────────────────────
cat("\n=== Model 7: Binary High vs Low Tax States ===\n\n")

m7 <- feols(log_index ~ post_gst:high_tax | state_id + time,
            data = gen, cluster = ~state_id)
cat("Model 7: Post-GST × High Tax State (binary)\n")
print(summary(m7))

# ── 8. ALTERNATIVE INTENSITY (pre-GST price dispersion) ──────────────────
cat("\n=== Model 8: Alternative Intensity (Price Dispersion) ===\n\n")

m8 <- feols(log_index ~ post_gst:disp_intensity | state_id + time,
            data = gen, cluster = ~state_id)
cat("Model 8: Post-GST × Pre-GST Price Dispersion Intensity\n")
print(summary(m8))

# ── Save all models for table generation ──────────────────────────────────
save(m1, m2, m3, m4, m6, m7, m8, file = "../data/main_models.RData")

cat("\n=== ALL MAIN ANALYSES COMPLETE ===\n")
