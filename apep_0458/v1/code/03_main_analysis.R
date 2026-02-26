## 03_main_analysis.R — RDD estimation
## APEP-0458: Second Home Caps and Local Labor Markets

source("code/00_packages.R")

cat("\n=== MAIN RDD ANALYSIS ===\n")

# Load data
rdd <- fread("data/rdd_cross_section.csv")
panel <- fread("data/analysis_panel.csv")

# Fix infinite values from division by zero
rdd[is.infinite(share_tertiary_post), share_tertiary_post := NA]
rdd[is.infinite(share_tertiary_pre), share_tertiary_pre := NA]
rdd[is.infinite(share_secondary_pre), share_secondary_pre := NA]
rdd[is.infinite(emp_growth_post), emp_growth_post := NA]

# Remove municipalities with zero pre-treatment employment
rdd <- rdd[!is.na(emp_total_pre) & emp_total_pre > 0]
cat("Analysis sample:", nrow(rdd), "municipalities\n")
cat("  Treated:", sum(rdd$treated == 1), "\n")
cat("  Control:", sum(rdd$treated == 0), "\n")

# ---------------------------------------------------------------------------
# 1. McCrary Density Test
# ---------------------------------------------------------------------------
cat("\n1. McCrary density test at 20% threshold...\n")

density_test <- rddensity(rdd$running, c = 0)
cat("  T-statistic:", round(density_test$test$t_jk, 3), "\n")
cat("  P-value:", round(density_test$test$p_jk, 3), "\n")
if (density_test$test$p_jk > 0.05) {
  cat("  PASS: No evidence of manipulation at 20% threshold\n")
} else {
  cat("  WARNING: Potential bunching at threshold\n")
}

# Save density test results
density_results <- data.table(
  test = "McCrary",
  t_stat = density_test$test$t_jk,
  p_value = density_test$test$p_jk,
  n_left = density_test$N$eff_l,
  n_right = density_test$N$eff_r,
  bw_left = density_test$h$left,
  bw_right = density_test$h$right
)
fwrite(density_results, "data/density_test.csv")

# ---------------------------------------------------------------------------
# 2. Main RDD Estimates — rdrobust
# ---------------------------------------------------------------------------
cat("\n2. Main RDD estimates...\n")

# Outcome variables
outcomes <- c("emp_growth_post", "log_emp_total_post", "share_tertiary_post")
outcome_labels <- c("Employment Growth", "Log Total Employment", "Tertiary Sector Share")

rdd_results <- list()

for (i in seq_along(outcomes)) {
  y <- rdd[[outcomes[i]]]
  x <- rdd$running
  valid <- !is.na(y) & !is.na(x)

  if (sum(valid) < 50) {
    cat("  ", outcomes[i], ": Too few observations (", sum(valid), ")\n")
    next
  }

  cat("  Estimating:", outcomes[i], "(N =", sum(valid), ")...\n")

  # CCT optimal bandwidth with triangular kernel
  rd <- tryCatch({
    rdrobust(y[valid], x[valid], c = 0, kernel = "triangular", all = TRUE)
  }, error = function(e) {
    cat("    Error:", e$message, "\n")
    NULL
  })

  if (!is.null(rd)) {
    cat("    Estimate:", round(rd$coef[1], 4), "\n")
    cat("    SE:", round(rd$se[3], 4), "(robust)\n")
    cat("    P-value:", round(rd$pv[3], 4), "(robust)\n")
    cat("    Bandwidth:", round(rd$bws[1, 1], 2), "\n")
    cat("    N (left/right):", rd$N_h[1], "/", rd$N_h[2], "\n")

    rdd_results[[outcomes[i]]] <- data.table(
      outcome = outcomes[i],
      label = outcome_labels[i],
      estimate = rd$coef[1],
      se_conventional = rd$se[1],
      se_bc = rd$se[2],
      se_robust = rd$se[3],
      pv_conventional = rd$pv[1],
      pv_robust = rd$pv[3],
      ci_lower = rd$ci[3, 1],
      ci_upper = rd$ci[3, 2],
      bw_main = rd$bws[1, 1],
      bw_bias = rd$bws[2, 1],
      n_left = rd$N_h[1],
      n_right = rd$N_h[2],
      n_total = sum(valid)
    )
  }
}

if (length(rdd_results) > 0) {
  results_dt <- rbindlist(rdd_results)
  fwrite(results_dt, "data/rdd_main_results.csv")
  cat("\n  Main results saved to data/rdd_main_results.csv\n")
  print(results_dt[, .(outcome, estimate = round(estimate, 4),
                        se = round(se_robust, 4), pv = round(pv_robust, 4),
                        bw = round(bw_main, 1), n = n_left + n_right)])
}

# ---------------------------------------------------------------------------
# 3. Tourism Outcomes (subset with HESTA data)
# ---------------------------------------------------------------------------
cat("\n3. Tourism RDD (municipalities with HESTA data)...\n")

rdd_tourism <- rdd[!is.na(log_overnights_post)]
cat("  Tourism sample:", nrow(rdd_tourism), "municipalities\n")

if (nrow(rdd_tourism) >= 50) {
  valid_t <- !is.na(rdd_tourism$log_overnights_post) & !is.na(rdd_tourism$running)

  rd_tourism <- tryCatch({
    rdrobust(rdd_tourism$log_overnights_post[valid_t],
             rdd_tourism$running[valid_t], c = 0, kernel = "triangular")
  }, error = function(e) {
    cat("    Error:", e$message, "\n")
    NULL
  })

  if (!is.null(rd_tourism)) {
    cat("  Log overnight stays:\n")
    cat("    Estimate:", round(rd_tourism$coef[1], 4), "\n")
    cat("    SE:", round(rd_tourism$se[3], 4), "(robust)\n")
    cat("    P-value:", round(rd_tourism$pv[3], 4), "\n")
    cat("    Bandwidth:", round(rd_tourism$bws[1, 1], 2), "\n")

    tourism_result <- data.table(
      outcome = "log_overnights_post",
      label = "Log Overnight Stays",
      estimate = rd_tourism$coef[1],
      se_robust = rd_tourism$se[3],
      pv_robust = rd_tourism$pv[3],
      bw_main = rd_tourism$bws[1, 1],
      n_left = rd_tourism$N_h[1],
      n_right = rd_tourism$N_h[2]
    )
    fwrite(tourism_result, "data/rdd_tourism_results.csv")
  }
} else {
  cat("  Insufficient tourism data for RDD\n")
}

# ---------------------------------------------------------------------------
# 4. Covariate Balance Tests
# ---------------------------------------------------------------------------
cat("\n4. Covariate balance at threshold...\n")

# Use log transforms for count variables (avoids scale issues with levels)
rdd[, log_emp_pre := log(emp_total_pre)]
rdd[, log_dwellings := log(total_dwellings + 1)]

covariates <- c("log_emp_pre", "share_tertiary_pre", "share_secondary_pre",
                "log_dwellings")
cov_labels <- c("Log Pre-Treatment Employment", "Pre-Treatment Tertiary Share",
                "Pre-Treatment Secondary Share", "Log Total Housing Units")

# First pass: determine common bandwidth (median of CCT-optimal bandwidths)
bw_candidates <- c()
for (i in seq_along(covariates)) {
  y <- rdd[[covariates[i]]]
  x <- rdd$running
  valid <- !is.na(y) & !is.na(x) & !is.infinite(y)
  if (sum(valid) < 50) next
  rd_bw <- tryCatch(rdrobust(y[valid], x[valid], c = 0, kernel = "triangular"),
                     error = function(e) NULL)
  if (!is.null(rd_bw)) bw_candidates <- c(bw_candidates, rd_bw$bws[1, 1])
}
common_bw <- median(bw_candidates)
cat("  Common bandwidth for balance tests:", round(common_bw, 2), "pp\n")

# Second pass: estimate balance with common bandwidth
balance_results <- list()
for (i in seq_along(covariates)) {
  y <- rdd[[covariates[i]]]
  x <- rdd$running
  valid <- !is.na(y) & !is.na(x) & !is.infinite(y)

  if (sum(valid) < 50) next

  rd_bal <- tryCatch({
    rdrobust(y[valid], x[valid], c = 0, kernel = "triangular", h = common_bw)
  }, error = function(e) NULL)

  if (!is.null(rd_bal)) {
    balance_results[[covariates[i]]] <- data.table(
      covariate = cov_labels[i],
      estimate = rd_bal$coef[1],
      se_robust = rd_bal$se[3],
      pv_robust = rd_bal$pv[3],
      bw = common_bw,
      n_eff = rd_bal$N_h[1] + rd_bal$N_h[2]
    )
    cat("  ", cov_labels[i], ": est =", round(rd_bal$coef[1], 3),
        ", p =", round(rd_bal$pv[3], 3), ", N =", rd_bal$N_h[1] + rd_bal$N_h[2], "\n")
  }
}

if (length(balance_results) > 0) {
  balance_dt <- rbindlist(balance_results)
  fwrite(balance_dt, "data/covariate_balance.csv")
  cat("\n  Balance tests saved\n")
}

# ---------------------------------------------------------------------------
# 5. Event Study RDD (by year)
# ---------------------------------------------------------------------------
cat("\n5. Event-study RDD by year...\n")

# For each post-treatment year, estimate separate RDD
panel[is.infinite(share_tertiary), share_tertiary := NA]
panel <- panel[!is.na(emp_total) & emp_total > 0]

event_results <- list()
for (yr in 2011:2023) {
  yr_data <- panel[year == yr & !is.na(running) & !is.na(emp_total)]

  if (nrow(yr_data) < 100) next

  rd_yr <- tryCatch({
    rdrobust(log(yr_data$emp_total + 1), yr_data$running, c = 0,
             kernel = "triangular")
  }, error = function(e) NULL)

  if (!is.null(rd_yr)) {
    event_results[[as.character(yr)]] <- data.table(
      year = yr,
      estimate = rd_yr$coef[1],
      se_robust = rd_yr$se[3],
      pv_robust = rd_yr$pv[3],
      ci_lower = rd_yr$ci[3, 1],
      ci_upper = rd_yr$ci[3, 2],
      bw = rd_yr$bws[1, 1],
      n = rd_yr$N_h[1] + rd_yr$N_h[2]
    )
    cat("  ", yr, ": est =", round(rd_yr$coef[1], 3),
        ", p =", round(rd_yr$pv[3], 3),
        ", bw =", round(rd_yr$bws[1, 1], 1), "\n")
  }
}

if (length(event_results) > 0) {
  event_dt <- rbindlist(event_results)
  fwrite(event_dt, "data/event_study_rdd.csv")
  cat("\n  Event study saved\n")
}

cat("\n=== MAIN ANALYSIS DONE ===\n")
