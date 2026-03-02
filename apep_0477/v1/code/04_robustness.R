###############################################################################
# 04_robustness.R — Robustness checks for multi-cutoff RDD
# apep_0477: Do Energy Labels Move Markets?
###############################################################################

source("00_packages.R")

DATA_DIR <- "../data"
df <- as.data.table(read_parquet(file.path(DATA_DIR, "analysis_sample.parquet")))

cat(sprintf("Analysis sample: %s observations\n", format(nrow(df), big.mark = ",")))

###############################################################################
# 1. Bandwidth Sensitivity
###############################################################################

cat("\n=== Bandwidth Sensitivity ===\n")

bw_multipliers <- c(0.5, 0.75, 1.0, 1.25, 1.5, 2.0)
bw_results <- list()

for (i in seq_along(EPC_BOUNDARIES)) {
  b <- EPC_BOUNDARIES[i]
  bname <- EPC_BAND_NAMES[i]

  # Get MSE-optimal bandwidth first
  rdd_opt <- rdrobust(
    y = df$log_price,
    x = df$epc_score,
    c = b,
    covs = cbind(df$floor_area, df$is_flat, df$is_new),
    kernel = "triangular",
    bwselect = "mserd"
  )
  h_opt <- rdd_opt$bws[1, 1]

  for (mult in bw_multipliers) {
    h <- h_opt * mult

    tryCatch({
      rdd_bw <- rdrobust(
        y = df$log_price,
        x = df$epc_score,
        c = b,
        h = h,
        covs = cbind(df$floor_area, df$is_flat, df$is_new),
        kernel = "triangular"
      )

      bw_results[[paste(bname, mult)]] <- data.table(
        boundary = bname,
        cutoff = b,
        bw_mult = mult,
        bw = h,
        estimate = rdd_bw$coef[1],
        se_robust = rdd_bw$se[3],
        p_value = rdd_bw$pv[3],
        N_eff = rdd_bw$N_h[1] + rdd_bw$N_h[2]
      )
    }, error = function(e) NULL)
  }

  cat(sprintf("  %s: h_opt=%.1f\n", bname, h_opt))
}

bw_dt <- rbindlist(bw_results, fill = TRUE)
fwrite(bw_dt, file.path(DATA_DIR, "bandwidth_sensitivity.csv"))
cat("Bandwidth sensitivity saved.\n")

###############################################################################
# 2. Polynomial Order Sensitivity
###############################################################################

cat("\n=== Polynomial Sensitivity ===\n")

poly_results <- list()

for (i in seq_along(EPC_BOUNDARIES)) {
  b <- EPC_BOUNDARIES[i]
  bname <- EPC_BAND_NAMES[i]

  for (p in 1:2) {
    tryCatch({
      rdd_poly <- rdrobust(
        y = df$log_price,
        x = df$epc_score,
        c = b,
        p = p,
        covs = cbind(df$floor_area, df$is_flat, df$is_new),
        kernel = "triangular",
        bwselect = "mserd"
      )

      poly_results[[paste(bname, p)]] <- data.table(
        boundary = bname,
        poly_order = p,
        estimate = rdd_poly$coef[1],
        se_robust = rdd_poly$se[3],
        p_value = rdd_poly$pv[3]
      )

      cat(sprintf("  %s p=%d: τ=%.4f (%.4f)\n",
                  bname, p, rdd_poly$coef[1], rdd_poly$se[3]))
    }, error = function(e) NULL)
  }
}

poly_dt <- rbindlist(poly_results)
fwrite(poly_dt, file.path(DATA_DIR, "polynomial_sensitivity.csv"))

###############################################################################
# 3. Donut RDD (exclude ±1 of boundary)
###############################################################################

cat("\n=== Donut RDD ===\n")

donut_results <- list()

for (i in seq_along(EPC_BOUNDARIES)) {
  b <- EPC_BOUNDARIES[i]
  bname <- EPC_BAND_NAMES[i]

  # Exclude observations within ±1 of the boundary
  df_donut <- df[abs(epc_score - b) > 1]

  tryCatch({
    rdd_donut <- rdrobust(
      y = df_donut$log_price,
      x = df_donut$epc_score,
      c = b,
      covs = cbind(df_donut$floor_area, df_donut$is_flat, df_donut$is_new),
      kernel = "triangular",
      bwselect = "mserd"
    )

    donut_results[[bname]] <- data.table(
      boundary = bname,
      type = "donut_1",
      estimate = rdd_donut$coef[1],
      se_robust = rdd_donut$se[3],
      p_value = rdd_donut$pv[3],
      N_eff = rdd_donut$N_h[1] + rdd_donut$N_h[2]
    )

    cat(sprintf("  %s donut(±1): τ=%.4f (%.4f), p=%.4f\n",
                bname, rdd_donut$coef[1], rdd_donut$se[3], rdd_donut$pv[3]))
  }, error = function(e) {
    cat(sprintf("  %s donut: ERROR - %s\n", bname, e$message))
  })
}

donut_dt <- rbindlist(donut_results)
fwrite(donut_dt, file.path(DATA_DIR, "donut_rdd_results.csv"))

###############################################################################
# 4. Placebo Cutoffs
###############################################################################

cat("\n=== Placebo Cutoffs ===\n")

placebo_cutoffs <- c(30, 35, 45, 50, 62, 65, 75, 78, 85, 88)

placebo_results <- list()

for (pc in placebo_cutoffs) {
  tryCatch({
    rdd_placebo <- rdrobust(
      y = df$log_price,
      x = df$epc_score,
      c = pc,
      covs = cbind(df$floor_area, df$is_flat, df$is_new),
      kernel = "triangular",
      bwselect = "mserd"
    )

    placebo_results[[as.character(pc)]] <- data.table(
      cutoff = pc,
      is_real = pc %in% EPC_BOUNDARIES,
      estimate = rdd_placebo$coef[1],
      se_robust = rdd_placebo$se[3],
      p_value = rdd_placebo$pv[3]
    )

    cat(sprintf("  c=%d: τ=%.4f (%.4f), p=%.4f %s\n",
                pc, rdd_placebo$coef[1], rdd_placebo$se[3], rdd_placebo$pv[3],
                ifelse(pc %in% EPC_BOUNDARIES, "[REAL]", "[PLACEBO]")))
  }, error = function(e) NULL)
}

# Also add real cutoff results for comparison
for (b in EPC_BOUNDARIES) {
  tryCatch({
    rdd_real <- rdrobust(
      y = df$log_price,
      x = df$epc_score,
      c = b,
      covs = cbind(df$floor_area, df$is_flat, df$is_new),
      kernel = "triangular",
      bwselect = "mserd"
    )

    placebo_results[[paste0("real_", b)]] <- data.table(
      cutoff = b,
      is_real = TRUE,
      estimate = rdd_real$coef[1],
      se_robust = rdd_real$se[3],
      p_value = rdd_real$pv[3]
    )
  }, error = function(e) NULL)
}

placebo_dt <- rbindlist(placebo_results)
fwrite(placebo_dt, file.path(DATA_DIR, "placebo_cutoff_results.csv"))

###############################################################################
# 5. Owner-Occupied Placebo at E/F (MEES should not affect them)
###############################################################################

cat("\n=== Owner-Occupied Placebo at E/F ===\n")

for (per in c("Post-MEES Pre-Crisis", "Crisis", "Post-Crisis")) {
  sub_owner <- df[is_owner == TRUE & period == per]
  sub_rental <- df[is_rental == TRUE & period == per]

  for (lab in c("Owner", "Rental")) {
    sub <- if (lab == "Owner") sub_owner else sub_rental
    if (nrow(sub) < 100) next

    tryCatch({
      rdd_tenure <- rdrobust(
        y = sub$log_price,
        x = sub$epc_score,
        c = 39,
        covs = cbind(sub$floor_area, sub$is_flat, sub$is_new),
        kernel = "triangular",
        bwselect = "mserd"
      )

      cat(sprintf("  E/F %s (%s): τ=%.4f (%.4f), p=%.4f\n",
                  lab, per, rdd_tenure$coef[1], rdd_tenure$se[3],
                  rdd_tenure$pv[3]))
    }, error = function(e) {
      cat(sprintf("  E/F %s (%s): ERROR\n", lab, per))
    })
  }
}

###############################################################################
# 6. Transaction Volume RDD (Supply Effect)
###############################################################################

cat("\n=== Transaction Volume at E/F ===\n")

# Count transactions by EPC score × period
vol_by_score <- df[abs(epc_score - 39) <= 15,
                    .(n_txns = .N), by = .(epc_score, period)]

# Test for discontinuity in transaction counts at E/F
for (per in levels(df$period)) {
  sub_vol <- vol_by_score[period == per]
  if (nrow(sub_vol) < 10) next

  tryCatch({
    rdd_vol <- rdrobust(
      y = sub_vol$n_txns,
      x = sub_vol$epc_score,
      c = 39
    )

    cat(sprintf("  Volume %s: τ=%.1f (%.1f), p=%.4f\n",
                per, rdd_vol$coef[1], rdd_vol$se[3], rdd_vol$pv[3]))
  }, error = function(e) {
    cat(sprintf("  Volume %s: ERROR\n", per))
  })
}

cat("\nRobustness checks complete.\n")
