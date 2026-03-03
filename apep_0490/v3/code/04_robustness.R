###############################################################################
# 04_robustness.R — RDD diagnostics, robustness checks, randomization inference
# Paper: Does Visibility Delay Frontier AI? (apep_0490 v3)
###############################################################################

source("00_packages.R")

cat("=== Loading analysis data ===\n")
df <- fread(file.path(DATA_DIR, "rdd_sample.csv"))
full <- fread(file.path(DATA_DIR, "full_sample.csv"))

# Primary outcome: frontier adoption (new framing)
PRIMARY <- "frontier_adopted_18m"
if (!(PRIMARY %in% names(df)) || sum(!is.na(df[[PRIMARY]])) < 100) {
  PRIMARY <- "has_frontier_cite"
}
if (!(PRIMARY %in% names(df)) || sum(!is.na(df[[PRIMARY]])) < 100) {
  PRIMARY <- "ln_cite_3y"
}
if (!(PRIMARY %in% names(df)) || sum(!is.na(df[[PRIMARY]])) < 100) {
  PRIMARY <- "ln_cited_by_count"
}

cat(sprintf("Primary outcome for robustness: %s\n", PRIMARY))

# Also run key robustness for citation outcome
CITE_PRIMARY <- "ln_cite_3y"
if (!(CITE_PRIMARY %in% names(df))) CITE_PRIMARY <- "ln_cited_by_count"

# ============================================================================
# A. Bandwidth Sensitivity
# ============================================================================

cat("\n=== A. Bandwidth Sensitivity ===\n")

run_bw_sensitivity <- function(outcome_var, outcome_label) {
  y <- df[[outcome_var]]
  valid <- !is.na(y)
  if (sum(valid) < 100) return(NULL)

  rdd_base <- tryCatch(rdrobust(y = y[valid], x = df$run_var[valid], c = 0), error = function(e) NULL)
  if (is.null(rdd_base)) return(NULL)

  h_opt <- rdd_base$bws["h", "left"]
  cat(sprintf("  %s — MSE-optimal bandwidth: %.1f minutes\n", outcome_label, h_opt))

  bw_results <- list()
  for (mult in c(0.5, 0.75, 1.0, 1.25, 1.5, 2.0)) {
    h <- h_opt * mult
    rdd_bw <- tryCatch(
      rdrobust(y = y[valid], x = df$run_var[valid], c = 0, h = h),
      error = function(e) NULL
    )
    if (!is.null(rdd_bw)) {
      bw_results[[as.character(mult)]] <- data.table(
        outcome = outcome_var,
        multiplier = mult, bandwidth = h,
        coef = rdd_bw$coef["Robust", ], se = rdd_bw$se["Robust", ],
        p_value = rdd_bw$pv["Robust", ],
        ci_lower = rdd_bw$ci["Robust", 1], ci_upper = rdd_bw$ci["Robust", 2],
        n_eff = rdd_bw$N_h[1] + rdd_bw$N_h[2]
      )
      cat(sprintf("    h = %.1f (%.0f%%): coef = %.4f, p = %.4f, N = %d\n",
                  h, mult * 100, rdd_bw$coef["Robust", ],
                  rdd_bw$pv["Robust", ], rdd_bw$N_h[1] + rdd_bw$N_h[2]))
    }
  }
  rbindlist(bw_results)
}

bw_adopt <- run_bw_sensitivity(PRIMARY, "Adoption")
bw_cite <- run_bw_sensitivity(CITE_PRIMARY, "Citations")
bw_all <- rbind(bw_adopt, bw_cite, fill = TRUE)
fwrite(bw_all, file.path(TAB_DIR, "bandwidth_sensitivity.csv"))

# ============================================================================
# B. Donut RDD (±2, ±5, ±10, ±15 minutes)
# ============================================================================

cat("\n=== B. Donut RDD ===\n")

run_donut <- function(outcome_var, outcome_label) {
  donut_results <- list()
  for (donut in c(2, 5, 10, 15)) {
    df_donut <- df[abs(run_var) > donut]
    y <- df_donut[[outcome_var]]
    valid <- !is.na(y)
    if (sum(valid) < 100) next

    rdd_donut <- tryCatch(
      rdrobust(y = y[valid], x = df_donut$run_var[valid], c = 0),
      error = function(e) NULL
    )
    if (!is.null(rdd_donut)) {
      donut_results[[as.character(donut)]] <- data.table(
        outcome = outcome_var,
        donut_minutes = donut,
        coef = rdd_donut$coef["Robust", ], se = rdd_donut$se["Robust", ],
        p_value = rdd_donut$pv["Robust", ],
        ci_lower = rdd_donut$ci["Robust", 1], ci_upper = rdd_donut$ci["Robust", 2],
        n_eff = rdd_donut$N_h[1] + rdd_donut$N_h[2],
        bw = rdd_donut$bws["h", "left"]
      )
      cat(sprintf("  %s donut ±%d min: coef = %.4f, p = %.4f, N = %d\n",
                  outcome_label, donut, rdd_donut$coef["Robust", ],
                  rdd_donut$pv["Robust", ], rdd_donut$N_h[1] + rdd_donut$N_h[2]))
    }
  }
  if (length(donut_results) > 0) rbindlist(donut_results) else NULL
}

donut_adopt <- run_donut(PRIMARY, "Adoption")
donut_cite <- run_donut(CITE_PRIMARY, "Citations")
donut_all <- rbind(donut_adopt, donut_cite, fill = TRUE)
fwrite(donut_all, file.path(TAB_DIR, "donut_rdd.csv"))

# ============================================================================
# C. Placebo Cutoffs
# ============================================================================

cat("\n=== C. Placebo Cutoffs ===\n")

run_placebo_cutoffs <- function(outcome_var, outcome_label) {
  placebo_cutoffs <- c(10*60, 11*60, 12*60, 13*60, 15*60, 16*60, 17*60, 18*60)
  placebo_results <- list()

  for (pc in placebo_cutoffs) {
    full[, placebo_run := minutes_since_midnight - pc]
    df_placebo <- full[abs(placebo_run) <= 120]
    if (nrow(df_placebo) < 100 || !(outcome_var %in% names(df_placebo))) next

    y <- df_placebo[[outcome_var]]
    valid <- !is.na(y)
    if (sum(valid) < 100) next

    rdd_plac <- tryCatch(
      rdrobust(y = y[valid], x = df_placebo$placebo_run[valid], c = 0),
      error = function(e) NULL
    )
    if (!is.null(rdd_plac)) {
      placebo_results[[as.character(pc)]] <- data.table(
        outcome = outcome_var,
        cutoff_hour = pc / 60, is_real = FALSE,
        coef = rdd_plac$coef["Robust", ], se = rdd_plac$se["Robust", ],
        p_value = rdd_plac$pv["Robust", ],
        n_eff = rdd_plac$N_h[1] + rdd_plac$N_h[2]
      )
    }
  }

  # Add the real cutoff
  y_real <- df[[outcome_var]]
  valid_real <- !is.na(y_real)
  if (sum(valid_real) >= 100) {
    rdd_real <- tryCatch(
      rdrobust(y = y_real[valid_real], x = df$run_var[valid_real], c = 0),
      error = function(e) NULL
    )
    if (!is.null(rdd_real)) {
      placebo_results[["real"]] <- data.table(
        outcome = outcome_var,
        cutoff_hour = 14, is_real = TRUE,
        coef = rdd_real$coef["Robust", ], se = rdd_real$se["Robust", ],
        p_value = rdd_real$pv["Robust", ],
        n_eff = rdd_real$N_h[1] + rdd_real$N_h[2]
      )
    }
  }

  if (length(placebo_results) > 0) rbindlist(placebo_results, fill = TRUE) else NULL
}

placebo_adopt <- run_placebo_cutoffs(PRIMARY, "Adoption")
placebo_cite <- run_placebo_cutoffs(CITE_PRIMARY, "Citations")
placebo_all <- rbind(placebo_adopt, placebo_cite, fill = TRUE)
fwrite(placebo_all, file.path(TAB_DIR, "placebo_cutoffs.csv"))

# ============================================================================
# D. Polynomial Order Sensitivity
# ============================================================================

cat("\n=== D. Polynomial Order ===\n")

poly_results <- list()
for (outcome_var in c(PRIMARY, CITE_PRIMARY)) {
  y <- df[[outcome_var]]
  valid <- !is.na(y)
  if (sum(valid) < 100) next

  for (p in 1:3) {
    rdd_poly <- tryCatch(
      rdrobust(y = y[valid], x = df$run_var[valid], c = 0, p = p),
      error = function(e) NULL
    )
    if (!is.null(rdd_poly)) {
      poly_results[[paste(outcome_var, p)]] <- data.table(
        outcome = outcome_var,
        poly_order = p,
        coef = rdd_poly$coef["Robust", ], se = rdd_poly$se["Robust", ],
        p_value = rdd_poly$pv["Robust", ],
        bw = rdd_poly$bws["h", "left"],
        n_eff = rdd_poly$N_h[1] + rdd_poly$N_h[2]
      )
    }
  }
}
poly_df <- rbindlist(poly_results)
fwrite(poly_df, file.path(TAB_DIR, "polynomial_order.csv"))

# ============================================================================
# E. Kernel Sensitivity
# ============================================================================

cat("\n=== E. Kernel Sensitivity ===\n")

kernel_results <- list()
for (outcome_var in c(PRIMARY, CITE_PRIMARY)) {
  y <- df[[outcome_var]]
  valid <- !is.na(y)
  if (sum(valid) < 100) next

  for (k in c("triangular", "epanechnikov", "uniform")) {
    rdd_kern <- tryCatch(
      rdrobust(y = y[valid], x = df$run_var[valid], c = 0, kernel = k),
      error = function(e) NULL
    )
    if (!is.null(rdd_kern)) {
      kernel_results[[paste(outcome_var, k)]] <- data.table(
        outcome = outcome_var, kernel = k,
        coef = rdd_kern$coef["Robust", ], se = rdd_kern$se["Robust", ],
        p_value = rdd_kern$pv["Robust", ],
        bw = rdd_kern$bws["h", "left"]
      )
    }
  }
}
kernel_df <- rbindlist(kernel_results)
fwrite(kernel_df, file.path(TAB_DIR, "kernel_sensitivity.csv"))

# ============================================================================
# F. Randomization Inference
# ============================================================================

cat("\n=== F. Randomization Inference ===\n")

run_ri <- function(outcome_var, n_perms = 1000, seed = 20240301) {
  set.seed(seed)  # Reproducibility for permutation inference
  y <- df[[outcome_var]]
  x <- df$run_var
  valid <- !is.na(y)
  if (sum(valid) < 100) return(NULL)

  y_v <- y[valid]
  x_v <- x[valid]

  # Get actual estimate
  rdd_actual <- tryCatch(
    rdrobust(y = y_v, x = x_v, c = 0),
    error = function(e) NULL
  )
  if (is.null(rdd_actual)) return(NULL)

  actual_coef <- rdd_actual$coef["Conventional", ]
  h <- rdd_actual$bws["h", "left"]

  # Permutation distribution
  cat(sprintf("  Running %d permutations for %s...\n", n_perms, outcome_var))
  perm_coefs <- numeric(n_perms)

  for (j in 1:n_perms) {
    y_perm <- sample(y_v)
    rdd_perm <- tryCatch(
      rdrobust(y = y_perm, x = x_v, c = 0, h = h),
      error = function(e) NULL
    )
    if (!is.null(rdd_perm)) {
      perm_coefs[j] <- rdd_perm$coef["Conventional", ]
    } else {
      perm_coefs[j] <- NA
    }

    if (j %% 200 == 0) cat(sprintf("    %d/%d done\n", j, n_perms))
  }

  perm_coefs <- perm_coefs[!is.na(perm_coefs)]

  # Two-sided p-value
  ri_p <- mean(abs(perm_coefs) >= abs(actual_coef))

  cat(sprintf("  %s — RI p-value: %.4f (actual coef: %.4f)\n",
              outcome_var, ri_p, actual_coef))

  data.table(
    outcome = outcome_var,
    actual_coef = actual_coef,
    ri_p_value = ri_p,
    n_permutations = length(perm_coefs),
    perm_mean = mean(perm_coefs),
    perm_sd = sd(perm_coefs)
  )
}

# Run RI for primary adoption and citation outcomes
ri_results <- list()
for (out in c(PRIMARY, CITE_PRIMARY)) {
  ri_out <- run_ri(out, n_perms = 500)  # 500 for speed; increase to 1000 for publication
  if (!is.null(ri_out)) ri_results[[out]] <- ri_out
}

if (length(ri_results) > 0) {
  ri_df <- rbindlist(ri_results)
  fwrite(ri_df, file.path(TAB_DIR, "randomization_inference.csv"))
}

# ============================================================================
# G. Day-of-Week Balance Test
# ============================================================================

cat("\n=== G. Day-of-Week Balance Test ===\n")

# Test whether day-of-week distribution is smooth at cutoff
for (dow in c("dow_mon", "dow_tue", "dow_wed", "dow_thu", "dow_fri")) {
  if (!(dow %in% names(df))) next
  rdd_dow <- tryCatch(
    rdrobust(y = df[[dow]], x = df$run_var, c = 0),
    error = function(e) NULL
  )
  if (!is.null(rdd_dow)) {
    cat(sprintf("  %s: coef = %.4f, p = %.4f\n",
                dow, rdd_dow$coef["Robust", ], rdd_dow$pv["Robust", ]))
  }
}

# ============================================================================
# H. Conference Deadline Exclusion
# ============================================================================

cat("\n=== H. Conference Deadline Exclusion ===\n")

deadline_months <- c(1, 5, 9)

if ("submission_date" %in% names(df)) {
  df[, sub_month := month(as.Date(submission_date))]
  df_no_deadline <- df[!(sub_month %in% deadline_months)]

  for (outcome_var in c(PRIMARY, CITE_PRIMARY)) {
    if (nrow(df_no_deadline) < 500 || !(outcome_var %in% names(df_no_deadline))) next
    y <- df_no_deadline[[outcome_var]]
    valid <- !is.na(y)
    if (sum(valid) < 100) next

    rdd_nodeadline <- tryCatch(
      rdrobust(y = y[valid], x = df_no_deadline$run_var[valid], c = 0),
      error = function(e) NULL
    )
    if (!is.null(rdd_nodeadline)) {
      cat(sprintf("  %s excl. conf months: coef = %.4f, p = %.4f, N = %d\n",
                  outcome_var, rdd_nodeadline$coef["Robust", ],
                  rdd_nodeadline$pv["Robust", ],
                  rdd_nodeadline$N_h[1] + rdd_nodeadline$N_h[2]))
    }
  }
}

# ============================================================================
# I. Mon-Wed vs Thu-Fri Split Estimates
# ============================================================================

cat("\n=== I. Mon-Wed vs Thu-Fri Split ===\n")

if ("early_week" %in% names(df)) {
  split_results <- list()

  for (outcome_var in c(PRIMARY, CITE_PRIMARY)) {
    y <- df[[outcome_var]]
    if (all(is.na(y))) next

    for (split_val in c(1, 0)) {
      label <- if (split_val == 1) "Mon-Wed" else "Thu-Fri"
      df_sub <- df[early_week == split_val]
      y_sub <- df_sub[[outcome_var]]
      valid <- !is.na(y_sub)
      if (sum(valid) < 100) next

      rdd_split <- tryCatch(
        rdrobust(y = y_sub[valid], x = df_sub$run_var[valid], c = 0),
        error = function(e) NULL
      )
      if (!is.null(rdd_split)) {
        split_results[[paste(outcome_var, label)]] <- data.table(
          outcome = outcome_var, subgroup = label,
          coef = rdd_split$coef["Robust", ], se = rdd_split$se["Robust", ],
          p_value = rdd_split$pv["Robust", ],
          ci_lower = rdd_split$ci["Robust", 1], ci_upper = rdd_split$ci["Robust", 2],
          n_eff = rdd_split$N_h[1] + rdd_split$N_h[2]
        )
        cat(sprintf("  %s %s: coef = %.4f, p = %.4f, N = %d\n",
                    outcome_var, label, rdd_split$coef["Robust", ],
                    rdd_split$pv["Robust", ], rdd_split$N_h[1] + rdd_split$N_h[2]))
      }
    }
  }

  if (length(split_results) > 0) {
    fwrite(rbindlist(split_results), file.path(TAB_DIR, "dow_split.csv"))
  }
}

# ============================================================================
# J. Placebo Categories (Math subfields)
# ============================================================================

cat("\n=== J. Placebo Categories ===\n")

if ("categories" %in% names(full)) {
  full[, has_math := grepl("math\\.", categories)]
  n_math <- sum(full$has_math)
  cat(sprintf("Math papers in full sample: %d\n", n_math))

  if (n_math > 500) {
    math_df <- full[has_math == TRUE & abs(run_var) <= 120]
    # Use citation outcome for math placebo (math papers rarely have industry citations)
    if (nrow(math_df) > 200 & CITE_PRIMARY %in% names(math_df)) {
      y <- math_df[[CITE_PRIMARY]]
      valid <- !is.na(y)
      if (sum(valid) > 100) {
        rdd_math <- tryCatch(
          rdrobust(y = y[valid], x = math_df$run_var[valid], c = 0),
          error = function(e) NULL
        )
        if (!is.null(rdd_math)) {
          cat(sprintf("  Math placebo: coef = %.4f, p = %.4f, N = %d\n",
                      rdd_math$coef["Robust", ], rdd_math$pv["Robust", ],
                      rdd_math$N_h[1] + rdd_math$N_h[2]))
        }
      }
    }
  }
}

cat("\n=== Robustness analysis complete ===\n")
