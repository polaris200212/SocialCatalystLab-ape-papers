## ==========================================================================
## 04_robustness.R — Validity tests and robustness checks
## APEP-0456: Low Emission Zone Boundaries and Property Values
## ==========================================================================

source("00_packages.R")

# ---- 1. Load data ----
dvf <- fread(file.path(data_dir, "dvf_zfe_analysis.csv"))
dvf[, date_mutation := as.Date(date_mutation)]
results <- readRDS(file.path(data_dir, "rdd_results.rds"))

post <- dvf[strong_enforcement == 1]
pre  <- dvf[enforcement_phase == 0]

cat("Post-ZFE:", nrow(post), "| Pre-ZFE:", nrow(pre), "\n")

# ---- 2. McCrary Density Test ----
cat("\n=== McCrary Density Test (rddensity) ===\n")

# Test for bunching of transactions at ZFE boundary
# If there's bunching, it suggests strategic sorting
density_post <- rddensity(X = post$dist_km, c = 0)
cat("Post-ZFE density test:\n")
cat("  T-statistic:", round(density_post$test$t_jk, 3), "\n")
cat("  p-value:", round(density_post$test$p_jk, 4), "\n")
cat("  Interpretation:", ifelse(density_post$test$p_jk > 0.05,
    "No evidence of manipulation (PASS)", "Potential manipulation (CONCERN)"), "\n")

density_pre <- rddensity(X = pre$dist_km, c = 0)
cat("\nPre-ZFE density test:\n")
cat("  T-statistic:", round(density_pre$test$t_jk, 3), "\n")
cat("  p-value:", round(density_pre$test$p_jk, 4), "\n")

# ---- 3. Covariate Balance Tests ----
cat("\n=== Covariate Balance at Boundary ===\n")

# Test whether pre-determined covariates are smooth at the boundary
covariates <- c("surface_reelle_bati", "nombre_pieces_principales", "nombre_lots")
cov_labels <- c("Surface (sqm)", "Rooms", "Lots")

balance_results <- list()
for (i in seq_along(covariates)) {
  cov_name <- covariates[i]
  cov_data <- post[!is.na(get(cov_name))]

  tryCatch({
    rdd_cov <- rdrobust(
      y = cov_data[[cov_name]],
      x = cov_data$dist_km,
      c = 0, kernel = "triangular", p = 1, bwselect = "mserd"
    )
    balance_results[[cov_name]] <- data.frame(
      covariate = cov_labels[i],
      tau = rdd_cov$coef[1],
      se = rdd_cov$se[3],
      pval = rdd_cov$pv[3],
      bw = rdd_cov$bws[1, 1],
      smooth = ifelse(rdd_cov$pv[3] > 0.05, "PASS", "FAIL")
    )
    cat("  ", cov_labels[i], ": tau =", round(rdd_cov$coef[1], 3),
        "| p =", round(rdd_cov$pv[3], 4),
        "|", ifelse(rdd_cov$pv[3] > 0.05, "PASS", "FAIL"), "\n")
  }, error = function(e) {
    cat("  ", cov_labels[i], ": ERROR -", e$message, "\n")
  })
}

balance_df <- bind_rows(balance_results)

# Also test apartment share (binary covariate)
cov_data <- post[!is.na(type_local)]
cov_data[, is_apt := as.numeric(type_local == "Appartement")]
tryCatch({
  rdd_apt <- rdrobust(
    y = cov_data$is_apt,
    x = cov_data$dist_km,
    c = 0, kernel = "triangular", p = 1, bwselect = "mserd"
  )
  balance_df <- bind_rows(balance_df, data.frame(
    covariate = "Apartment share",
    tau = rdd_apt$coef[1],
    se = rdd_apt$se[3],
    pval = rdd_apt$pv[3],
    bw = rdd_apt$bws[1, 1],
    smooth = ifelse(rdd_apt$pv[3] > 0.05, "PASS", "FAIL")
  ))
  cat("  Apartment share: tau =", round(rdd_apt$coef[1], 3),
      "| p =", round(rdd_apt$pv[3], 4),
      "|", ifelse(rdd_apt$pv[3] > 0.05, "PASS", "FAIL"), "\n")
}, error = function(e) cat("  Apartment share: ERROR -", e$message, "\n"))

# ---- 4. Bandwidth Sensitivity ----
cat("\n=== Bandwidth Sensitivity ===\n")

opt_bw <- results$main$bw
bw_grid <- c(0.25, 0.5, 0.75, 1.0, 1.5, 2.0, 3.0, 5.0)
# Also include half and double optimal
bw_grid <- sort(unique(c(opt_bw * 0.5, opt_bw * 0.75, opt_bw, opt_bw * 1.5, opt_bw * 2, bw_grid)))

bw_results <- list()
for (bw in bw_grid) {
  sub <- post[abs(dist_km) <= bw]
  if (nrow(sub) < 100) next

  tryCatch({
    rdd_bw <- rdrobust(
      y = sub$log_price_sqm,
      x = sub$dist_km,
      c = 0, kernel = "triangular", p = 1, h = bw
    )
    bw_results[[as.character(bw)]] <- data.frame(
      bandwidth_km = bw,
      tau = rdd_bw$coef[1],
      se_robust = rdd_bw$se[3],
      pval = rdd_bw$pv[3],
      n = rdd_bw$N[1] + rdd_bw$N[2]
    )
    cat("  bw =", sprintf("%.2f", bw), "km | tau =", round(rdd_bw$coef[1], 4),
        "| se =", round(rdd_bw$se[3], 4), "| N =", rdd_bw$N[1] + rdd_bw$N[2], "\n")
  }, error = function(e) {
    cat("  bw =", sprintf("%.2f", bw), "km | ERROR:", e$message, "\n")
  })
}

bw_df <- bind_rows(bw_results)

# ---- 5. Polynomial Order Sensitivity ----
cat("\n=== Polynomial Order ===\n")

poly_results <- list()
for (p_order in 1:3) {
  tryCatch({
    rdd_p <- rdrobust(
      y = post$log_price_sqm,
      x = post$dist_km,
      c = 0, kernel = "triangular", p = p_order, bwselect = "mserd"
    )
    poly_results[[p_order]] <- data.frame(
      order = p_order,
      tau = rdd_p$coef[1],
      se = rdd_p$se[3],
      pval = rdd_p$pv[3],
      bw = rdd_p$bws[1, 1]
    )
    cat("  p =", p_order, "| tau =", round(rdd_p$coef[1], 4),
        "| se =", round(rdd_p$se[3], 4), "\n")
  }, error = function(e) {
    cat("  p =", p_order, "| ERROR:", e$message, "\n")
  })
}
poly_df <- bind_rows(poly_results)

# ---- 6. Donut Hole RDD ----
cat("\n=== Donut Hole RDD ===\n")

donut_sizes <- c(0.1, 0.2, 0.3, 0.5)  # km (dropped 50m — too close)
donut_results <- list()

for (hole in donut_sizes) {
  sub <- post[abs(dist_km) > hole]
  if (nrow(sub) < 100) next

  tryCatch({
    rdd_donut <- rdrobust(
      y = sub$log_price_sqm,
      x = sub$dist_km,
      c = 0, kernel = "triangular", p = 1, bwselect = "mserd"
    )
    donut_results[[as.character(hole)]] <- data.frame(
      donut_km = hole,
      tau = rdd_donut$coef[1],
      se = rdd_donut$se[3],
      pval = rdd_donut$pv[3],
      n = rdd_donut$N[1] + rdd_donut$N[2]
    )
    cat("  donut =", hole, "km | tau =", round(rdd_donut$coef[1], 4),
        "| se =", round(rdd_donut$se[3], 4), "\n")
  }, error = function(e) {
    cat("  donut =", hole, "km | ERROR:", e$message, "\n")
  })
}
donut_df <- bind_rows(donut_results)

# ---- 7. Placebo Cutoffs ----
cat("\n=== Placebo Cutoffs ===\n")

placebo_cutoffs <- c(-3, -2, -1, -0.5, 0.5, 1, 2, 3)  # km from real boundary
placebo_results <- list()

for (pc in placebo_cutoffs) {
  tryCatch({
    rdd_pc <- rdrobust(
      y = post$log_price_sqm,
      x = post$dist_km,
      c = pc,
      kernel = "triangular", p = 1, bwselect = "mserd"
    )
    placebo_results[[as.character(pc)]] <- data.frame(
      cutoff = pc,
      tau = rdd_pc$coef[1],
      se = rdd_pc$se[3],
      pval = rdd_pc$pv[3]
    )
    cat("  cutoff =", sprintf("%+.1f", pc), "km | tau =", round(rdd_pc$coef[1], 4),
        "| p =", round(rdd_pc$pv[3], 4), "\n")
  }, error = function(e) {
    cat("  cutoff =", sprintf("%+.1f", pc), "km | ERROR:", e$message, "\n")
  })
}
placebo_df <- bind_rows(placebo_results)

# ---- 8. Alternative kernel ----
cat("\n=== Alternative Kernels ===\n")

for (kern in c("triangular", "epanechnikov", "uniform")) {
  tryCatch({
    rdd_k <- rdrobust(
      y = post$log_price_sqm,
      x = post$dist_km,
      c = 0, kernel = kern, p = 1, bwselect = "mserd"
    )
    cat("  ", kern, "| tau =", round(rdd_k$coef[1], 4),
        "| se =", round(rdd_k$se[3], 4), "\n")
  }, error = function(e) {
    cat("  ", kern, "| ERROR:", e$message, "\n")
  })
}

# ---- 9. Save robustness results ----
cat("\nSaving robustness results...\n")

rob_results <- list(
  density_post = density_post,
  density_pre = density_pre,
  balance = balance_df,
  bandwidth_sensitivity = bw_df,
  polynomial_sensitivity = poly_df,
  donut = donut_df,
  placebo_cutoffs = placebo_df
)

saveRDS(rob_results, file.path(data_dir, "robustness_results.rds"))
cat("Robustness results saved.\n")
