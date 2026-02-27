###############################################################################
# 03_main_analysis.R — Multi-cutoff RDD at EPC band boundaries
# apep_0477: Do Energy Labels Move Markets?
###############################################################################

source("00_packages.R")

DATA_DIR <- "../data"
df <- as.data.table(read_parquet(file.path(DATA_DIR, "analysis_sample.parquet")))

cat(sprintf("Analysis sample: %s observations\n", format(nrow(df), big.mark = ",")))

###############################################################################
# 1. McCrary Density Tests at All Boundaries
###############################################################################

cat("\n=== McCrary Density Tests ===\n")

mccrary_results <- list()

for (i in seq_along(EPC_BOUNDARIES)) {
  b <- EPC_BOUNDARIES[i]
  bname <- EPC_BAND_NAMES[i]

  # Overall
  dens <- rddensity(df$epc_score, c = b)
  mccrary_results[[bname]] <- list(
    boundary = bname,
    cutoff = b,
    test_stat = dens$test$t_jk,
    p_value = dens$test$p_jk,
    N_left = dens$N$eff_left,
    N_right = dens$N$eff_right
  )

  cat(sprintf("  %s (c=%d): T=%.3f, p=%.4f [%s]\n",
              bname, b, dens$test$t_jk, dens$test$p_jk,
              ifelse(dens$test$p_jk < 0.05, "BUNCHING DETECTED", "OK")))

  # By MEES period (E/F only)
  if (b == 39) {
    for (per in c("Pre-MEES", "Post-MEES Pre-Crisis", "Crisis", "Post-Crisis")) {
      sub <- df[period == per]
      if (nrow(sub) > 100) {
        dens_p <- rddensity(sub$epc_score, c = b)
        cat(sprintf("    %s: T=%.3f, p=%.4f [%s]\n",
                    per, dens_p$test$t_jk, dens_p$test$p_jk,
                    ifelse(dens_p$test$p_jk < 0.05, "BUNCHING", "OK")))
      }
    }
  }
}

mccrary_dt <- rbindlist(lapply(mccrary_results, as.data.table))
fwrite(mccrary_dt, file.path(DATA_DIR, "mccrary_results.csv"))
cat("McCrary results saved.\n")

###############################################################################
# 2. Covariate Balance at Boundaries
###############################################################################

cat("\n=== Covariate Balance Tests ===\n")

covariates <- c("floor_area", "is_flat", "is_new")

balance_results <- list()

for (i in seq_along(EPC_BOUNDARIES)) {
  b <- EPC_BOUNDARIES[i]
  bname <- EPC_BAND_NAMES[i]

  for (cov in covariates) {
    if (all(is.na(df[[cov]]))) next

    tryCatch({
      rdd_cov <- rdrobust(
        y = df[[cov]],
        x = df$epc_score,
        c = b,
        kernel = "triangular",
        bwselect = "mserd"
      )

      balance_results[[paste(bname, cov)]] <- data.table(
        boundary = bname,
        covariate = cov,
        estimate = rdd_cov$coef[1],
        se = rdd_cov$se[3],  # Robust SE
        p_value = rdd_cov$pv[3],
        bw = rdd_cov$bws[1, 1],
        N_eff = rdd_cov$N_h[1] + rdd_cov$N_h[2]
      )

      cat(sprintf("  %s × %s: coef=%.4f, p=%.4f\n",
                  bname, cov, rdd_cov$coef[1], rdd_cov$pv[3]))
    }, error = function(e) {
      cat(sprintf("  %s × %s: ERROR - %s\n", bname, cov, e$message))
    })
  }
}

if (length(balance_results) > 0) {
  balance_dt <- rbindlist(balance_results)
  fwrite(balance_dt, file.path(DATA_DIR, "balance_results.csv"))
  cat("Balance results saved.\n")
}

###############################################################################
# 3. Main RDD Estimates at Each Boundary
###############################################################################

cat("\n=== Main RDD Estimates ===\n")

rdd_results <- list()

for (i in seq_along(EPC_BOUNDARIES)) {
  b <- EPC_BOUNDARIES[i]
  bname <- EPC_BAND_NAMES[i]

  # Overall estimate
  tryCatch({
    rdd_main <- rdrobust(
      y = df$log_price,
      x = df$epc_score,
      c = b,
      covs = cbind(df$floor_area, df$is_flat, df$is_new),
      kernel = "triangular",
      bwselect = "mserd"
    )

    rdd_results[[paste(bname, "Overall")]] <- data.table(
      boundary = bname,
      cutoff = b,
      period = "Overall",
      tenure = "All",
      estimate = rdd_main$coef[1],
      se_robust = rdd_main$se[3],
      ci_lower = rdd_main$ci[3, 1],
      ci_upper = rdd_main$ci[3, 2],
      p_value = rdd_main$pv[3],
      bw_left = rdd_main$bws[1, 1],
      bw_right = rdd_main$bws[1, 2],
      N_eff_left = rdd_main$N_h[1],
      N_eff_right = rdd_main$N_h[2]
    )

    cat(sprintf("\n  %s Overall: τ=%.4f (%.4f), p=%.4f, bw=%.1f, N_eff=%d+%d\n",
                bname, rdd_main$coef[1], rdd_main$se[3], rdd_main$pv[3],
                rdd_main$bws[1, 1], rdd_main$N_h[1], rdd_main$N_h[2]))
  }, error = function(e) {
    cat(sprintf("  %s Overall: ERROR - %s\n", bname, e$message))
  })

  # By period
  for (per in levels(df$period)) {
    sub <- df[period == per]
    if (nrow(sub) < 200) next

    tryCatch({
      rdd_per <- rdrobust(
        y = sub$log_price,
        x = sub$epc_score,
        c = b,
        covs = cbind(sub$floor_area, sub$is_flat, sub$is_new),
        kernel = "triangular",
        bwselect = "mserd"
      )

      rdd_results[[paste(bname, per)]] <- data.table(
        boundary = bname,
        cutoff = b,
        period = per,
        tenure = "All",
        estimate = rdd_per$coef[1],
        se_robust = rdd_per$se[3],
        ci_lower = rdd_per$ci[3, 1],
        ci_upper = rdd_per$ci[3, 2],
        p_value = rdd_per$pv[3],
        bw_left = rdd_per$bws[1, 1],
        bw_right = rdd_per$bws[1, 2],
        N_eff_left = rdd_per$N_h[1],
        N_eff_right = rdd_per$N_h[2]
      )

      cat(sprintf("    %s: τ=%.4f (%.4f), p=%.4f\n",
                  per, rdd_per$coef[1], rdd_per$se[3], rdd_per$pv[3]))
    }, error = function(e) {
      cat(sprintf("    %s: ERROR - %s\n", per, e$message))
    })
  }

  # E/F boundary: by tenure (MEES regulatory decomposition)
  if (b == 39) {
    for (ten in c("rental", "owner")) {
      sub <- if (ten == "rental") df[is_rental == TRUE] else df[is_owner == TRUE]
      if (nrow(sub) < 200) next

      for (per in c("Pre-MEES", "Post-MEES Pre-Crisis", "Crisis", "Post-Crisis")) {
        sub_per <- sub[period == per]
        if (nrow(sub_per) < 100) next

        tryCatch({
          rdd_ten <- rdrobust(
            y = sub_per$log_price,
            x = sub_per$epc_score,
            c = b,
            covs = cbind(sub_per$floor_area, sub_per$is_flat, sub_per$is_new),
            kernel = "triangular",
            bwselect = "mserd"
          )

          rdd_results[[paste(bname, per, ten)]] <- data.table(
            boundary = bname,
            cutoff = b,
            period = per,
            tenure = ten,
            estimate = rdd_ten$coef[1],
            se_robust = rdd_ten$se[3],
            ci_lower = rdd_ten$ci[3, 1],
            ci_upper = rdd_ten$ci[3, 2],
            p_value = rdd_ten$pv[3],
            bw_left = rdd_ten$bws[1, 1],
            bw_right = rdd_ten$bws[1, 2],
            N_eff_left = rdd_ten$N_h[1],
            N_eff_right = rdd_ten$N_h[2]
          )

          cat(sprintf("    %s (%s): τ=%.4f (%.4f), p=%.4f\n",
                      per, ten, rdd_ten$coef[1], rdd_ten$se[3], rdd_ten$pv[3]))
        }, error = function(e) {
          cat(sprintf("    %s (%s): ERROR - %s\n", per, ten, e$message))
        })
      }
    }
  }
}

rdd_dt <- rbindlist(rdd_results, fill = TRUE)
fwrite(rdd_dt, file.path(DATA_DIR, "rdd_results.csv"))
cat("\nAll RDD results saved.\n")

###############################################################################
# 4. Decomposition: Information vs Regulation vs Crisis
###############################################################################

cat("\n=== Effect Decomposition ===\n")

# Average information effect at non-regulatory boundaries (D/E and C/D)
info_boundaries <- rdd_dt[boundary %in% c("D/E", "C/D") & tenure == "All"]
info_by_period <- info_boundaries[, .(
  info_effect = mean(estimate),
  info_se = sqrt(mean(se_robust^2))  # Conservative pooled SE
), by = period]

cat("Information effect (average of D/E and C/D):\n")
print(info_by_period)

# MEES regulatory effect: E/F effect minus average information effect
ef_results <- rdd_dt[boundary == "E/F" & tenure == "All"]
if (nrow(ef_results) > 0 && nrow(info_by_period) > 0) {
  decomp <- merge(ef_results[, .(period, ef_effect = estimate, ef_se = se_robust)],
                  info_by_period, by = "period", all.x = TRUE)

  decomp[, reg_effect := ef_effect - info_effect]
  decomp[, reg_se := sqrt(ef_se^2 + info_se^2)]
  decomp[, reg_pval := 2 * pnorm(-abs(reg_effect / reg_se))]

  cat("\nRegulatory effect (E/F minus information baseline):\n")
  print(decomp[, .(period, ef_effect, info_effect, reg_effect, reg_se, reg_pval)])

  fwrite(decomp, file.path(DATA_DIR, "decomposition_results.csv"))
}

###############################################################################
# 5. Crisis Amplification Test
###############################################################################

cat("\n=== Crisis Amplification ===\n")

# For each boundary: compare crisis vs pre-crisis effect
for (bname in EPC_BAND_NAMES[1:3]) {  # E/F, D/E, C/D (enough observations)
  pre <- rdd_dt[boundary == bname & period == "Post-MEES Pre-Crisis" & tenure == "All"]
  crisis <- rdd_dt[boundary == bname & period == "Crisis" & tenure == "All"]

  if (nrow(pre) == 1 && nrow(crisis) == 1) {
    diff <- crisis$estimate - pre$estimate
    diff_se <- sqrt(crisis$se_robust^2 + pre$se_robust^2)
    diff_pval <- 2 * pnorm(-abs(diff / diff_se))
    cat(sprintf("  %s: Crisis - Pre = %.4f (%.4f), p=%.4f\n",
                bname, diff, diff_se, diff_pval))
  }
}

cat("\nMain analysis complete.\n")
