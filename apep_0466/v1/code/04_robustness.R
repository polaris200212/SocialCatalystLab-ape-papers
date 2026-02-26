## ============================================================================
## 04_robustness.R — Robustness checks
## APEP-0466: Municipal Population Thresholds and Firm Creation in France
## ============================================================================

source("00_packages.R")

data_dir <- "../data"
panel <- fread(file.path(data_dir, "analysis_panel.csv"))
commune_means <- fread(file.path(data_dir, "commune_means.csv"))
load(file.path(data_dir, "regression_models.RData"))

# ===========================================================================
# 1. McCRARY DENSITY TEST (Manipulation test)
# ===========================================================================
cat("=== McCrary density tests ===\n")

rdd_thresholds <- c(500, 1000, 1500, 3500, 10000)
mccrary_results <- list()

for (thresh in rdd_thresholds) {
  bw <- thresh * 0.5
  df <- commune_means[abs(population - thresh) <= bw]

  density_test <- tryCatch({
    rddensity(X = df$population, c = thresh, p = 2)
  }, error = function(e) {
    cat(sprintf("  Density test failed at %d: %s\n", thresh, e$message))
    NULL
  })

  if (!is.null(density_test)) {
    cat(sprintf("  Threshold %d: T-stat = %.3f, p-value = %.4f\n",
                thresh, density_test$test$t_jk, density_test$test$p_jk))
    mccrary_results[[as.character(thresh)]] <- data.table(
      threshold = thresh,
      t_stat = density_test$test$t_jk,
      p_value = density_test$test$p_jk,
      n_left = density_test$N[1],
      n_right = density_test$N[2]
    )
  }
}

mccrary_table <- rbindlist(mccrary_results)
fwrite(mccrary_table, file.path(data_dir, "mccrary_tests.csv"))

# ===========================================================================
# 2. COVARIATE BALANCE AT THRESHOLDS
# ===========================================================================
cat("\n=== Covariate balance tests ===\n")

covariates <- c("superficie_km2", "densite")
balance_results <- list()

for (thresh in rdd_thresholds) {
  bw <- thresh * 0.5
  df <- commune_means[abs(population - thresh) <= bw]

  for (cov in covariates) {
    if (!cov %in% names(df) || all(is.na(df[[cov]]))) next

    rd_cov <- tryCatch({
      rdrobust(y = df[[cov]], x = df$population, c = thresh, p = 1, bwselect = "mserd", masspoints = "adjust")
    }, error = function(e) NULL)

    if (!is.null(rd_cov)) {
      balance_results[[paste0(thresh, "_", cov)]] <- data.table(
        threshold = thresh,
        covariate = cov,
        estimate = rd_cov$coef[1],
        se = rd_cov$se[1],
        pvalue = rd_cov$pv[1]
      )
    }
  }
}

balance_table <- rbindlist(balance_results)
fwrite(balance_table, file.path(data_dir, "balance_tests.csv"))
cat("Balance tests:\n")
print(balance_table)

# ===========================================================================
# 3. BANDWIDTH SENSITIVITY
# ===========================================================================
cat("\n=== Bandwidth sensitivity (3,500 threshold) ===\n")

thresh <- 3500
bw_multipliers <- c(0.5, 0.75, 1.0, 1.25, 1.5, 2.0)

# Get optimal bandwidth first
# Use ±50% window (same as main analysis in 03_main_analysis.R)
df_3500 <- commune_means[abs(population - thresh) <= thresh * 0.5]
rd_base <- rdrobust(y = df_3500$mean_creation_rate, x = df_3500$population,
                    c = thresh, p = 1, bwselect = "mserd", masspoints = "adjust")
h_opt <- rd_base$bws[1, 1]

bw_sensitivity <- list()
for (mult in bw_multipliers) {
  h <- h_opt * mult
  rd_bw <- tryCatch({
    rdrobust(y = df_3500$mean_creation_rate, x = df_3500$population,
             c = thresh, p = 1, h = h)
  }, error = function(e) NULL)

  if (!is.null(rd_bw)) {
    bw_sensitivity[[as.character(mult)]] <- data.table(
      multiplier = mult,
      bandwidth = h,
      estimate = rd_bw$coef[1],
      se = rd_bw$se[1],
      pvalue = rd_bw$pv[1],
      ci_lower = rd_bw$ci[1, 1],
      ci_upper = rd_bw$ci[1, 2],
      n_left = rd_bw$N_h[1],
      n_right = rd_bw$N_h[2]
    )
    cat(sprintf("  h = %.0f (%.0f%%): est = %.3f (SE = %.3f, p = %.4f)\n",
                h, mult * 100, rd_bw$coef[1], rd_bw$se[1], rd_bw$pv[1]))
  }
}

bw_table <- rbindlist(bw_sensitivity)
fwrite(bw_table, file.path(data_dir, "bandwidth_sensitivity.csv"))

# ===========================================================================
# 4. POLYNOMIAL ORDER SENSITIVITY
# ===========================================================================
cat("\n=== Polynomial order sensitivity (3,500 threshold) ===\n")

poly_results <- list()
for (p_order in 1:3) {
  rd_poly <- tryCatch({
    rdrobust(y = df_3500$mean_creation_rate, x = df_3500$population,
             c = thresh, p = p_order, bwselect = "mserd", masspoints = "adjust")
  }, error = function(e) NULL)

  if (!is.null(rd_poly)) {
    poly_results[[as.character(p_order)]] <- data.table(
      order = p_order,
      estimate = rd_poly$coef[1],
      se = rd_poly$se[1],
      pvalue = rd_poly$pv[1],
      bandwidth = rd_poly$bws[1, 1]
    )
    cat(sprintf("  Order %d: est = %.3f (SE = %.3f, p = %.4f, h = %.0f)\n",
                p_order, rd_poly$coef[1], rd_poly$se[1], rd_poly$pv[1], rd_poly$bws[1, 1]))
  }
}

poly_table <- rbindlist(poly_results)
fwrite(poly_table, file.path(data_dir, "polynomial_sensitivity.csv"))

# ===========================================================================
# 5. PLACEBO THRESHOLD TESTS
# ===========================================================================
cat("\n=== Placebo threshold tests ===\n")

placebo_thresholds <- c(750, 2000, 2750, 4500, 7500)
placebo_results <- list()

for (pthresh in placebo_thresholds) {
  bw <- pthresh * 0.5
  df_p <- commune_means[abs(population - pthresh) <= bw]

  if (nrow(df_p) < 30) next

  rd_placebo <- tryCatch({
    rdrobust(y = df_p$mean_creation_rate, x = df_p$population,
             c = pthresh, p = 1, bwselect = "mserd", masspoints = "adjust")
  }, error = function(e) NULL)

  if (!is.null(rd_placebo)) {
    placebo_results[[as.character(pthresh)]] <- data.table(
      threshold = pthresh,
      type = "placebo",
      estimate = rd_placebo$coef[1],
      se = rd_placebo$se[1],
      pvalue = rd_placebo$pv[1]
    )
    cat(sprintf("  Placebo %d: est = %.3f (SE = %.3f, p = %.4f)\n",
                pthresh, rd_placebo$coef[1], rd_placebo$se[1], rd_placebo$pv[1]))
  }
}

placebo_table <- rbindlist(placebo_results)
fwrite(placebo_table, file.path(data_dir, "placebo_tests.csv"))

# ===========================================================================
# 6. DONUT-HOLE RDD
# ===========================================================================
cat("\n=== Donut-hole RDD (exclude ±50 of threshold) ===\n")

donut_results <- list()
for (thresh in rdd_thresholds) {
  bw <- thresh * 0.5
  donut <- 50
  df_donut <- commune_means[abs(population - thresh) <= bw & abs(population - thresh) >= donut]

  if (nrow(df_donut) < 30) next

  rd_donut <- tryCatch({
    rdrobust(y = df_donut$mean_creation_rate, x = df_donut$population,
             c = thresh, p = 1, bwselect = "mserd", masspoints = "adjust")
  }, error = function(e) NULL)

  if (!is.null(rd_donut)) {
    donut_results[[as.character(thresh)]] <- data.table(
      threshold = thresh,
      estimate = rd_donut$coef[1],
      se = rd_donut$se[1],
      pvalue = rd_donut$pv[1]
    )
    cat(sprintf("  Donut %d: est = %.3f (SE = %.3f, p = %.4f)\n",
                thresh, rd_donut$coef[1], rd_donut$se[1], rd_donut$pv[1]))
  }
}

donut_table <- rbindlist(donut_results)
fwrite(donut_table, file.path(data_dir, "donut_tests.csv"))

# ===========================================================================
# 7. THRESHOLD SWITCHERS ANALYSIS
# ===========================================================================
cat("\n=== Threshold switching analysis (2022-2025) ===\n")

pop_panel <- tryCatch(fread(file.path(data_dir, "commune_population_panel.csv")), error = function(e) NULL)
if (!is.null(pop_panel) && "data_year" %in% names(pop_panel)) {
  switchers_results <- list()
  for (thresh in rdd_thresholds) {
    bw <- thresh * 0.3  # ±30% bandwidth (same as Table 1)
    # Use 2025 population to identify communes near threshold
    pop_2025 <- pop_panel[data_year == max(data_year)]
    near_codes <- pop_2025[abs(population - thresh) <= bw, code_insee]

    # Look at all years for these communes
    near_all <- pop_panel[code_insee %in% near_codes]

    # For each commune, check if it crosses the threshold across years
    commune_status <- near_all[, .(
      ever_above = any(population >= thresh),
      ever_below = any(population < thresh),
      n_years = .N,
      min_pop = min(population),
      max_pop = max(population)
    ), by = code_insee]

    n_communes <- nrow(commune_status[n_years > 1])
    n_switchers <- nrow(commune_status[ever_above == TRUE & ever_below == TRUE & n_years > 1])
    pct_switch <- ifelse(n_communes > 0, 100 * n_switchers / n_communes, 0)

    switchers_results[[as.character(thresh)]] <- data.table(
      threshold = thresh,
      n_communes = n_communes,
      n_switchers = n_switchers,
      pct_switchers = pct_switch
    )
    cat(sprintf("  Threshold %s: %d/%d communes (%.1f%%) cross threshold 2022-2025\n",
                formatC(thresh, big.mark = ","), n_switchers, n_communes, pct_switch))
  }

  switchers_table <- rbindlist(switchers_results)
  fwrite(switchers_table, file.path(data_dir, "switchers_analysis.csv"))
} else {
  cat("  Population panel not found, skipping switchers analysis\n")
}

# ===========================================================================
# 9. POST-2020 SUBSAMPLE RDD
# ===========================================================================
cat("\n=== Post-2020 subsample RDD ===\n")

# Compute commune means for post-2020 period only
panel_post2020 <- panel[year >= 2021 & election_year == FALSE]
cm_post2020 <- panel_post2020[, .(
  mean_creation_rate = mean(creation_rate, na.rm = TRUE),
  n_years = .N
), by = .(code_insee, population)]

post2020_results <- list()
for (thresh in rdd_thresholds) {
  bw_max <- thresh * 0.5
  df <- cm_post2020[abs(population - thresh) <= bw_max]
  if (nrow(df) < 50) next

  rd_post <- tryCatch({
    rdrobust(y = df$mean_creation_rate, x = df$population,
             c = thresh, p = 1, bwselect = "mserd", masspoints = "adjust")
  }, error = function(e) NULL)

  if (!is.null(rd_post)) {
    post2020_results[[as.character(thresh)]] <- data.table(
      threshold = thresh,
      estimate = rd_post$coef[1],
      se = rd_post$se[1],
      pvalue = rd_post$pv[1]
    )
    cat(sprintf("  Threshold %s (post-2020): est = %.3f (SE = %.3f, p = %.4f)\n",
                formatC(thresh, big.mark = ","), rd_post$coef[1], rd_post$se[1], rd_post$pv[1]))
  }
}

post2020_table <- rbindlist(post2020_results)
fwrite(post2020_table, file.path(data_dir, "post2020_rdd.csv"))

# ===========================================================================
# 10. SAVE ALL ROBUSTNESS RESULTS (Updated)
# ===========================================================================

save(mccrary_table, balance_table, bw_table, poly_table,
     placebo_table, donut_table,
     file = file.path(data_dir, "robustness_results.RData"))

cat("\n=== Robustness checks complete ===\n")
