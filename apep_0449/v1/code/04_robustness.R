## ============================================================================
## 04_robustness.R — Robustness Checks for RDD Analysis
## Criminal Politicians and Local Development (apep_0449)
## ============================================================================
source("00_packages.R")

cat("\n========================================\n")
cat("ROBUSTNESS CHECKS\n")
cat("========================================\n\n")

## ── Load data ───────────────────────────────────────────────────────────────
rdd <- readRDS(file.path(DATA_DIR, "rdd_analysis.rds"))
rdd <- as.data.table(rdd)
cat("Loaded", nrow(rdd), "observations\n")

## Keep observations with non-missing outcome and running variable
rdd_main <- rdd[!is.na(nl_growth) & !is.na(margin)]
cat("Analysis sample (non-missing nl_growth & margin):", nrow(rdd_main), "\n\n")

## Master list to collect all results
robustness_results <- list()

## ============================================================================
## 1. McCRARY DENSITY TEST
## ============================================================================
cat("── 1. McCrary density test ──\n")

density_test <- tryCatch({
  dt <- rddensity::rddensity(X = rdd_main$margin, c = 0)
  list(
    statistic = dt$test$t_jk,
    p_value   = dt$test$p_jk,
    n_left    = dt$N$eff_left,
    n_right   = dt$N$eff_right,
    passed    = dt$test$p_jk > 0.05
  )
}, error = function(e) {
  cat("  WARNING: McCrary test failed:", conditionMessage(e), "\n")
  list(statistic = NA, p_value = NA, n_left = NA, n_right = NA, passed = NA)
})

cat("  Test statistic:", round(density_test$statistic, 3), "\n")
cat("  P-value:", round(density_test$p_value, 3), "\n")
cat("  Effective N (left/right):", density_test$n_left, "/", density_test$n_right, "\n")
cat("  No manipulation (p > 0.05):",
    ifelse(isTRUE(density_test$passed), "PASS", "FAIL"), "\n\n")

robustness_results$mccrary <- density_test

## Save density plot
tryCatch({
  dt_plot <- rddensity::rddensity(X = rdd_main$margin, c = 0)
  pdf(file.path(FIG_DIR, "mccrary_density.pdf"), width = 7, height = 5)
  plot_obj <- rddensity::rdplotdensity(dt_plot, X = rdd_main$margin,
                                        plotN = 25, plotRange = c(-30, 30),
                                        title = "McCrary Density Test at Margin = 0")
  dev.off()
  cat("  Saved: mccrary_density.pdf\n\n")
}, error = function(e) {
  cat("  Could not save density plot:", conditionMessage(e), "\n\n")
})

## ============================================================================
## 2. COVARIATE BALANCE AT THE THRESHOLD
## ============================================================================
cat("── 2. Covariate balance tests ──\n")

cov_names <- c("lit_rate_01", "sc_share_01", "st_share_01", "log_pop_01",
               "turnout_percentage", "n_cand", "nl_pre")
cov_labels <- c("Literacy rate (2001)", "SC share (2001)", "ST share (2001)",
                "Log population (2001)", "Turnout %", "Number of candidates",
                "Pre-election nightlights")

balance_results <- data.table(
  covariate = character(),
  label     = character(),
  estimate  = numeric(),
  se        = numeric(),
  pvalue    = numeric(),
  ci_lower  = numeric(),
  ci_upper  = numeric(),
  bandwidth = numeric(),
  n_eff     = numeric()
)

for (i in seq_along(cov_names)) {
  cv <- cov_names[i]

  ## Check variable exists and has variation
  if (!(cv %in% names(rdd_main))) {
    cat("  ", cov_labels[i], ": variable not found, skipping\n")
    next
  }

  idx <- !is.na(rdd_main[[cv]]) & !is.na(rdd_main$margin)
  if (sum(idx) < 30) {
    cat("  ", cov_labels[i], ": too few observations (", sum(idx), "), skipping\n")
    next
  }

  bal_fit <- tryCatch({
    rdrobust::rdrobust(y = rdd_main[[cv]][idx],
                       x = rdd_main$margin[idx],
                       c = 0, kernel = "triangular",
                       p = 1, bwselect = "mserd")
  }, error = function(e) NULL)

  if (!is.null(bal_fit)) {
    est <- bal_fit$coef[1]   # Conventional
    se  <- bal_fit$se[3]     # Robust
    pv  <- bal_fit$pv[3]     # Robust p-value
    ci  <- bal_fit$ci[3, ]   # Robust CI

    balance_results <- rbind(balance_results, data.table(
      covariate = cv,
      label     = cov_labels[i],
      estimate  = est,
      se        = se,
      pvalue    = pv,
      ci_lower  = ci[1],
      ci_upper  = ci[2],
      bandwidth = bal_fit$bws[1, 1],
      n_eff     = sum(bal_fit$N_h)
    ))

    sig_flag <- ifelse(pv < 0.05, " ***SIGNIFICANT***", "")
    cat(sprintf("  %-30s: coef = %7.4f  (se = %6.4f)  p = %.3f  bw = %.2f%s\n",
                cov_labels[i], est, se, pv, bal_fit$bws[1, 1], sig_flag))
  } else {
    cat("  ", cov_labels[i], ": rdrobust failed\n")
  }
}

n_sig_balance <- sum(balance_results$pvalue < 0.05, na.rm = TRUE)
cat("\n  Covariates significant at 5%:", n_sig_balance, "of", nrow(balance_results), "\n")
cat("  Balance overall:",
    ifelse(n_sig_balance == 0, "PASS", "CAUTION — some imbalance detected"), "\n\n")

robustness_results$balance <- balance_results

## ============================================================================
## 3. BANDWIDTH SENSITIVITY
## ============================================================================
cat("── 3. Bandwidth sensitivity ──\n")

## Get MSE-optimal bandwidth from the main specification
main_fit <- tryCatch({
  rdrobust::rdrobust(y = rdd_main$nl_growth,
                     x = rdd_main$margin,
                     c = 0, kernel = "triangular",
                     p = 1, bwselect = "mserd")
}, error = function(e) {
  cat("  WARNING: Main specification failed:", conditionMessage(e), "\n")
  NULL
})

if (!is.null(main_fit)) {
  h_star <- main_fit$bws[1, 1]
  cat("  MSE-optimal bandwidth h* =", round(h_star, 2), "\n\n")

  bw_multipliers <- c(0.50, 0.75, 1.00, 1.25, 1.50, 2.00)

  bw_results <- data.table(
    multiplier = numeric(),
    bandwidth  = numeric(),
    estimate   = numeric(),
    se         = numeric(),
    pvalue     = numeric(),
    ci_lower   = numeric(),
    ci_upper   = numeric(),
    n_eff      = numeric()
  )

  for (mult in bw_multipliers) {
    h_test <- h_star * mult

    bw_fit <- tryCatch({
      rdrobust::rdrobust(y = rdd_main$nl_growth,
                         x = rdd_main$margin,
                         c = 0, kernel = "triangular",
                         p = 1, h = h_test)
    }, error = function(e) NULL)

    if (!is.null(bw_fit)) {
      est <- bw_fit$coef[1]
      se  <- bw_fit$se[3]
      pv  <- bw_fit$pv[3]
      ci  <- bw_fit$ci[3, ]

      bw_results <- rbind(bw_results, data.table(
        multiplier = mult,
        bandwidth  = h_test,
        estimate   = est,
        se         = se,
        pvalue     = pv,
        ci_lower   = ci[1],
        ci_upper   = ci[2],
        n_eff      = sum(bw_fit$N_h)
      ))

      sig <- ifelse(pv < 0.05, "*", " ")
      cat(sprintf("  %4.2f x h* = %5.2f : coef = %7.4f  (se = %6.4f)  p = %.3f  N = %d %s\n",
                  mult, h_test, est, se, pv, sum(bw_fit$N_h), sig))
    } else {
      cat(sprintf("  %4.2f x h* = %5.2f : FAILED\n", mult, h_test))
    }
  }

  robustness_results$bandwidth <- bw_results
  cat("\n")
} else {
  cat("  Skipping bandwidth sensitivity (main spec failed)\n\n")
}

## ============================================================================
## 4. PLACEBO CUTOFFS
## ============================================================================
cat("── 4. Placebo cutoff tests ──\n")

placebo_cuts <- c(-10, -5, -2, 2, 5, 10)

placebo_results <- data.table(
  cutoff   = numeric(),
  estimate = numeric(),
  se       = numeric(),
  pvalue   = numeric(),
  ci_lower = numeric(),
  ci_upper = numeric(),
  n_eff    = numeric()
)

for (cc in placebo_cuts) {
  pl_fit <- tryCatch({
    rdrobust::rdrobust(y = rdd_main$nl_growth,
                       x = rdd_main$margin,
                       c = cc, kernel = "triangular",
                       p = 1, bwselect = "mserd")
  }, error = function(e) NULL)

  if (!is.null(pl_fit)) {
    est <- pl_fit$coef[1]
    se  <- pl_fit$se[3]
    pv  <- pl_fit$pv[3]
    ci  <- pl_fit$ci[3, ]

    placebo_results <- rbind(placebo_results, data.table(
      cutoff   = cc,
      estimate = est,
      se       = se,
      pvalue   = pv,
      ci_lower = ci[1],
      ci_upper = ci[2],
      n_eff    = sum(pl_fit$N_h)
    ))

    sig <- ifelse(pv < 0.05, " *SIG*", "")
    cat(sprintf("  Cutoff = %+3d : coef = %7.4f  (se = %6.4f)  p = %.3f  N = %d%s\n",
                cc, est, se, pv, sum(pl_fit$N_h), sig))
  } else {
    cat(sprintf("  Cutoff = %+3d : FAILED (insufficient observations)\n", cc))
  }
}

n_sig_placebo <- sum(placebo_results$pvalue < 0.05, na.rm = TRUE)
cat("\n  Significant placebos:", n_sig_placebo, "of", nrow(placebo_results), "\n")
cat("  Placebo check:",
    ifelse(n_sig_placebo == 0, "PASS — no spurious effects",
           "CAUTION — some placebo cutoffs significant"), "\n\n")

robustness_results$placebo <- placebo_results

## ============================================================================
## 5. DONUT HOLE REGRESSIONS
## ============================================================================
cat("── 5. Donut hole regressions ──\n")

donut_radii <- c(0.5, 1.0, 1.5, 2.0)

donut_results <- data.table(
  radius   = numeric(),
  n_dropped = integer(),
  n_used   = integer(),
  estimate = numeric(),
  se       = numeric(),
  pvalue   = numeric(),
  ci_lower = numeric(),
  ci_upper = numeric()
)

for (r in donut_radii) {
  donut_data <- rdd_main[abs(margin) >= r]
  n_dropped <- nrow(rdd_main) - nrow(donut_data)

  if (nrow(donut_data) < 30) {
    cat(sprintf("  |margin| >= %.1f : too few obs (%d), skipping\n", r, nrow(donut_data)))
    next
  }

  dn_fit <- tryCatch({
    rdrobust::rdrobust(y = donut_data$nl_growth,
                       x = donut_data$margin,
                       c = 0, kernel = "triangular",
                       p = 1, bwselect = "mserd")
  }, error = function(e) NULL)

  if (!is.null(dn_fit)) {
    est <- dn_fit$coef[1]
    se  <- dn_fit$se[3]
    pv  <- dn_fit$pv[3]
    ci  <- dn_fit$ci[3, ]

    donut_results <- rbind(donut_results, data.table(
      radius    = r,
      n_dropped = as.integer(n_dropped),
      n_used    = nrow(donut_data),
      estimate  = est,
      se        = se,
      pvalue    = pv,
      ci_lower  = ci[1],
      ci_upper  = ci[2]
    ))

    sig <- ifelse(pv < 0.05, "*", " ")
    cat(sprintf("  |margin| >= %.1f : dropped %4d, used %4d | coef = %7.4f  (se = %6.4f)  p = %.3f %s\n",
                r, n_dropped, nrow(donut_data), est, se, pv, sig))
  } else {
    cat(sprintf("  |margin| >= %.1f : rdrobust failed\n", r))
  }
}

robustness_results$donut <- donut_results
cat("\n")

## ============================================================================
## 6. POLYNOMIAL ORDER SENSITIVITY
## ============================================================================
cat("── 6. Polynomial order sensitivity ──\n")

poly_results <- data.table(
  poly_order = integer(),
  estimate   = numeric(),
  se         = numeric(),
  pvalue     = numeric(),
  ci_lower   = numeric(),
  ci_upper   = numeric(),
  bandwidth  = numeric(),
  n_eff      = numeric()
)

for (pp in c(1L, 2L)) {
  poly_fit <- tryCatch({
    rdrobust::rdrobust(y = rdd_main$nl_growth,
                       x = rdd_main$margin,
                       c = 0, kernel = "triangular",
                       p = pp, bwselect = "mserd")
  }, error = function(e) NULL)

  if (!is.null(poly_fit)) {
    est <- poly_fit$coef[1]
    se  <- poly_fit$se[3]
    pv  <- poly_fit$pv[3]
    ci  <- poly_fit$ci[3, ]

    poly_results <- rbind(poly_results, data.table(
      poly_order = pp,
      estimate   = est,
      se         = se,
      pvalue     = pv,
      ci_lower   = ci[1],
      ci_upper   = ci[2],
      bandwidth  = poly_fit$bws[1, 1],
      n_eff      = sum(poly_fit$N_h)
    ))

    label <- ifelse(pp == 1, "Local linear  (p=1)", "Local quadratic (p=2)")
    sig <- ifelse(pv < 0.05, "*", " ")
    cat(sprintf("  %s : coef = %7.4f  (se = %6.4f)  p = %.3f  bw = %.2f  N = %d %s\n",
                label, est, se, pv, poly_fit$bws[1, 1], sum(poly_fit$N_h), sig))
  }
}

robustness_results$polynomial <- poly_results
cat("\n")

## ============================================================================
## 7. KERNEL SENSITIVITY
## ============================================================================
cat("── 7. Kernel sensitivity ──\n")

kernels <- c("triangular", "uniform", "epanechnikov")

kernel_results <- data.table(
  kernel    = character(),
  estimate  = numeric(),
  se        = numeric(),
  pvalue    = numeric(),
  ci_lower  = numeric(),
  ci_upper  = numeric(),
  bandwidth = numeric(),
  n_eff     = numeric()
)

for (kern in kernels) {
  kern_fit <- tryCatch({
    rdrobust::rdrobust(y = rdd_main$nl_growth,
                       x = rdd_main$margin,
                       c = 0, kernel = kern,
                       p = 1, bwselect = "mserd")
  }, error = function(e) NULL)

  if (!is.null(kern_fit)) {
    est <- kern_fit$coef[1]
    se  <- kern_fit$se[3]
    pv  <- kern_fit$pv[3]
    ci  <- kern_fit$ci[3, ]

    kernel_results <- rbind(kernel_results, data.table(
      kernel    = kern,
      estimate  = est,
      se        = se,
      pvalue    = pv,
      ci_lower  = ci[1],
      ci_upper  = ci[2],
      bandwidth = kern_fit$bws[1, 1],
      n_eff     = sum(kern_fit$N_h)
    ))

    sig <- ifelse(pv < 0.05, "*", " ")
    cat(sprintf("  %-15s : coef = %7.4f  (se = %6.4f)  p = %.3f  bw = %.2f  N = %d %s\n",
                kern, est, se, pv, kern_fit$bws[1, 1], sum(kern_fit$N_h), sig))
  }
}

robustness_results$kernel <- kernel_results
cat("\n")

## ============================================================================
## 8. HETEROGENEITY ANALYSIS
## ============================================================================
cat("── 8. Heterogeneity analysis ──\n")

heterogeneity_results <- list()
min_het_n <- 50  # Minimum observations for subgroup analysis

## --- 8a. By major crime (among criminal-adjacent elections) ---
cat("\n  8a. By severity of criminal charges\n")

if ("w_major" %in% names(rdd_main)) {
  for (major_val in c(0L, 1L)) {
    sub_label <- ifelse(major_val == 1, "Major crime", "Minor crime only")
    sub_data <- rdd_main[w_major == major_val]

    if (nrow(sub_data) >= min_het_n) {
      het_fit <- tryCatch({
        rdrobust::rdrobust(y = sub_data$nl_growth,
                           x = sub_data$margin,
                           c = 0, kernel = "triangular",
                           p = 1, bwselect = "mserd")
      }, error = function(e) NULL)

      if (!is.null(het_fit)) {
        est <- het_fit$coef[1]
        se  <- het_fit$se[3]
        pv  <- het_fit$pv[3]
        ci  <- het_fit$ci[3, ]

        heterogeneity_results[[paste0("crime_major_", major_val)]] <- data.table(
          subgroup  = sub_label,
          dimension = "crime_severity",
          estimate  = est,
          se        = se,
          pvalue    = pv,
          ci_lower  = ci[1],
          ci_upper  = ci[2],
          bandwidth = het_fit$bws[1, 1],
          n_eff     = sum(het_fit$N_h),
          n_total   = nrow(sub_data)
        )

        sig <- ifelse(pv < 0.05, "*", " ")
        cat(sprintf("      %-20s (N=%4d): coef = %7.4f  (se = %6.4f)  p = %.3f %s\n",
                    sub_label, nrow(sub_data), est, se, pv, sig))
      } else {
        cat(sprintf("      %-20s (N=%4d): rdrobust failed\n",
                    sub_label, nrow(sub_data)))
      }
    } else {
      cat(sprintf("      %-20s (N=%4d): too few observations\n",
                  sub_label, nrow(sub_data)))
    }
  }
} else {
  cat("      w_major not available, skipping\n")
}

## --- 8b. By state development: BIMARU vs non-BIMARU ---
cat("\n  8b. By state development (BIMARU vs others)\n")

if ("eci_state_name" %in% names(rdd_main)) {
  ## BIMARU states: Bihar, Madhya Pradesh, Rajasthan, Uttar Pradesh
  ## (including Jharkhand, Chhattisgarh, Uttarakhand as carved-out successors)
  bimaru_states <- c("Bihar", "Jharkhand",
                     "Madhya Pradesh", "Chhattisgarh", "Chattisgarh",
                     "Rajasthan",
                     "Uttar Pradesh", "Uttarakhand", "Uttaranchal")

  ## Normalize state names for matching (title case, trimmed)
  rdd_main[, state_clean := trimws(eci_state_name)]

  ## Case-insensitive match
  rdd_main[, is_bimaru := as.integer(tolower(state_clean) %in% tolower(bimaru_states))]

  for (bimaru_val in c(1L, 0L)) {
    sub_label <- ifelse(bimaru_val == 1, "BIMARU states", "Non-BIMARU states")
    sub_data <- rdd_main[is_bimaru == bimaru_val]

    if (nrow(sub_data) >= min_het_n) {
      het_fit <- tryCatch({
        rdrobust::rdrobust(y = sub_data$nl_growth,
                           x = sub_data$margin,
                           c = 0, kernel = "triangular",
                           p = 1, bwselect = "mserd")
      }, error = function(e) NULL)

      if (!is.null(het_fit)) {
        est <- het_fit$coef[1]
        se  <- het_fit$se[3]
        pv  <- het_fit$pv[3]
        ci  <- het_fit$ci[3, ]

        heterogeneity_results[[paste0("bimaru_", bimaru_val)]] <- data.table(
          subgroup  = sub_label,
          dimension = "state_development",
          estimate  = est,
          se        = se,
          pvalue    = pv,
          ci_lower  = ci[1],
          ci_upper  = ci[2],
          bandwidth = het_fit$bws[1, 1],
          n_eff     = sum(het_fit$N_h),
          n_total   = nrow(sub_data)
        )

        sig <- ifelse(pv < 0.05, "*", " ")
        cat(sprintf("      %-20s (N=%4d): coef = %7.4f  (se = %6.4f)  p = %.3f %s\n",
                    sub_label, nrow(sub_data), est, se, pv, sig))
      } else {
        cat(sprintf("      %-20s (N=%4d): rdrobust failed\n",
                    sub_label, nrow(sub_data)))
      }
    } else {
      cat(sprintf("      %-20s (N=%4d): too few observations\n",
                  sub_label, nrow(sub_data)))
    }
  }

  ## Clean up temporary columns
  rdd_main[, c("state_clean", "is_bimaru") := NULL]
} else {
  cat("      eci_state_name not available, skipping\n")
}

## --- 8c. By reservation status ---
cat("\n  8c. By reservation status (GEN / SC / ST)\n")

if ("constituency_type" %in% names(rdd_main)) {
  ## Normalize labels
  rdd_main[, const_type := toupper(trimws(constituency_type))]

  for (ctype in c("GEN", "SC", "ST")) {
    sub_data <- rdd_main[const_type == ctype]
    sub_label <- paste0("Reservation: ", ctype)

    if (nrow(sub_data) >= min_het_n) {
      het_fit <- tryCatch({
        rdrobust::rdrobust(y = sub_data$nl_growth,
                           x = sub_data$margin,
                           c = 0, kernel = "triangular",
                           p = 1, bwselect = "mserd")
      }, error = function(e) NULL)

      if (!is.null(het_fit)) {
        est <- het_fit$coef[1]
        se  <- het_fit$se[3]
        pv  <- het_fit$pv[3]
        ci  <- het_fit$ci[3, ]

        heterogeneity_results[[paste0("reservation_", ctype)]] <- data.table(
          subgroup  = sub_label,
          dimension = "reservation",
          estimate  = est,
          se        = se,
          pvalue    = pv,
          ci_lower  = ci[1],
          ci_upper  = ci[2],
          bandwidth = het_fit$bws[1, 1],
          n_eff     = sum(het_fit$N_h),
          n_total   = nrow(sub_data)
        )

        sig <- ifelse(pv < 0.05, "*", " ")
        cat(sprintf("      %-20s (N=%4d): coef = %7.4f  (se = %6.4f)  p = %.3f %s\n",
                    sub_label, nrow(sub_data), est, se, pv, sig))
      } else {
        cat(sprintf("      %-20s (N=%4d): rdrobust failed\n",
                    sub_label, nrow(sub_data)))
      }
    } else {
      cat(sprintf("      %-20s (N=%4d): too few observations\n",
                  sub_label, nrow(sub_data)))
    }
  }

  rdd_main[, const_type := NULL]
} else {
  cat("      constituency_type not available, skipping\n")
}

## Combine heterogeneity results
if (length(heterogeneity_results) > 0) {
  robustness_results$heterogeneity <- rbindlist(heterogeneity_results)
  cat("\n  Heterogeneity subgroups estimated:", length(heterogeneity_results), "\n")
} else {
  cat("\n  No heterogeneity subgroups had sufficient sample size\n")
}

cat("\n")

## ============================================================================
## SUMMARY TABLE
## ============================================================================
cat("── ROBUSTNESS SUMMARY ──\n\n")

cat("  McCrary density test ............ ",
    ifelse(isTRUE(density_test$passed), "PASS", "FAIL/NA"),
    " (p =", round(density_test$p_value, 3), ")\n")

cat("  Covariate balance ............... ",
    ifelse(n_sig_balance == 0, "PASS", paste0("CAUTION (", n_sig_balance, " sig.)")),
    "\n")

if (exists("bw_results") && nrow(bw_results) > 0) {
  n_sig_bw <- sum(bw_results$pvalue < 0.05, na.rm = TRUE)
  cat("  Bandwidth sensitivity ........... ",
      n_sig_bw, "of", nrow(bw_results), "specifications significant\n")
}

if (nrow(placebo_results) > 0) {
  cat("  Placebo cutoffs ................. ",
      ifelse(n_sig_placebo == 0, "PASS", paste0(n_sig_placebo, " of ",
             nrow(placebo_results), " sig.")), "\n")
}

if (nrow(donut_results) > 0) {
  n_sig_donut <- sum(donut_results$pvalue < 0.05, na.rm = TRUE)
  cat("  Donut hole ...................... ",
      n_sig_donut, "of", nrow(donut_results), "specifications significant\n")
}

if (nrow(poly_results) > 0) {
  cat("  Polynomial order ................ ",
      paste(sprintf("p=%d: p-val=%.3f", poly_results$poly_order, poly_results$pvalue),
            collapse = "; "), "\n")
}

if (nrow(kernel_results) > 0) {
  cat("  Kernel sensitivity .............. ",
      paste(sprintf("%s: p-val=%.3f", kernel_results$kernel, kernel_results$pvalue),
            collapse = "; "), "\n")
}

if (!is.null(robustness_results$heterogeneity) && nrow(robustness_results$heterogeneity) > 0) {
  het <- robustness_results$heterogeneity
  cat("  Heterogeneity ................... ",
      nrow(het), "subgroups tested;",
      sum(het$pvalue < 0.05, na.rm = TRUE), "significant\n")
}

## ============================================================================
## SAVE ALL RESULTS
## ============================================================================
cat("\n── Saving results ──\n")

saveRDS(robustness_results, file.path(DATA_DIR, "robustness_results.rds"))
cat("  Saved:", file.path(DATA_DIR, "robustness_results.rds"), "\n")

## Also save a flat summary table for easy LaTeX export
flat_summary <- data.table(
  check    = character(),
  spec     = character(),
  estimate = numeric(),
  se       = numeric(),
  pvalue   = numeric(),
  n_eff    = numeric()
)

## Add bandwidth rows
if (exists("bw_results") && nrow(bw_results) > 0) {
  flat_summary <- rbind(flat_summary, data.table(
    check    = "Bandwidth",
    spec     = sprintf("%.2f x h*", bw_results$multiplier),
    estimate = bw_results$estimate,
    se       = bw_results$se,
    pvalue   = bw_results$pvalue,
    n_eff    = bw_results$n_eff
  ))
}

## Add placebo rows
if (nrow(placebo_results) > 0) {
  flat_summary <- rbind(flat_summary, data.table(
    check    = "Placebo cutoff",
    spec     = sprintf("c = %+d", as.integer(placebo_results$cutoff)),
    estimate = placebo_results$estimate,
    se       = placebo_results$se,
    pvalue   = placebo_results$pvalue,
    n_eff    = placebo_results$n_eff
  ))
}

## Add donut rows
if (nrow(donut_results) > 0) {
  flat_summary <- rbind(flat_summary, data.table(
    check    = "Donut hole",
    spec     = sprintf("|m| >= %.1f", donut_results$radius),
    estimate = donut_results$estimate,
    se       = donut_results$se,
    pvalue   = donut_results$pvalue,
    n_eff    = as.numeric(donut_results$n_used)
  ))
}

## Add polynomial rows
if (nrow(poly_results) > 0) {
  flat_summary <- rbind(flat_summary, data.table(
    check    = "Polynomial",
    spec     = sprintf("p = %d", poly_results$poly_order),
    estimate = poly_results$estimate,
    se       = poly_results$se,
    pvalue   = poly_results$pvalue,
    n_eff    = poly_results$n_eff
  ))
}

## Add kernel rows
if (nrow(kernel_results) > 0) {
  flat_summary <- rbind(flat_summary, data.table(
    check    = "Kernel",
    spec     = kernel_results$kernel,
    estimate = kernel_results$estimate,
    se       = kernel_results$se,
    pvalue   = kernel_results$pvalue,
    n_eff    = kernel_results$n_eff
  ))
}

saveRDS(flat_summary, file.path(DATA_DIR, "robustness_flat_summary.rds"))
cat("  Saved:", file.path(DATA_DIR, "robustness_flat_summary.rds"), "\n")

cat("\n========================================\n")
cat("ROBUSTNESS CHECKS COMPLETE\n")
cat("========================================\n")
