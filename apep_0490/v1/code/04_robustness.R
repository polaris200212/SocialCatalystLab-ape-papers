###############################################################################
# 04_robustness.R — RDD diagnostics and robustness checks
# Paper: The Price of Position (apep_0490)
###############################################################################

source("00_packages.R")

cat("=== Loading analysis data ===\n")
df <- fread(file.path(DATA_DIR, "rdd_sample.csv"))
full <- fread(file.path(DATA_DIR, "full_sample.csv"))

# Primary outcome for robustness
PRIMARY <- "ln_cite_3y"
if (!(PRIMARY %in% names(df))) PRIMARY <- "ln_cited_by_count"
if (!(PRIMARY %in% names(df))) {
  cat("WARNING: No citation outcome found. Using n_categories as placeholder.\n")
  PRIMARY <- "n_categories"
}

cat(sprintf("Primary outcome: %s\n", PRIMARY))

# ============================================================================
# A. Bandwidth Sensitivity
# ============================================================================

cat("\n=== A. Bandwidth Sensitivity ===\n")

# First get the MSE-optimal bandwidth
rdd_base <- rdrobust(y = df[[PRIMARY]], x = df$run_var, c = 0)
h_opt <- rdd_base$bws["h", "left"]
cat(sprintf("MSE-optimal bandwidth: %.1f minutes\n", h_opt))

# Test at different multiples of optimal
bw_multipliers <- c(0.5, 0.75, 1.0, 1.25, 1.5, 2.0)
bw_results <- list()

for (mult in bw_multipliers) {
  h <- h_opt * mult
  rdd_bw <- tryCatch(
    rdrobust(y = df[[PRIMARY]], x = df$run_var, c = 0, h = h),
    error = function(e) NULL
  )

  if (!is.null(rdd_bw)) {
    bw_results[[as.character(mult)]] <- data.table(
      multiplier = mult,
      bandwidth = h,
      coef = rdd_bw$coef["Robust", ],
      se = rdd_bw$se["Robust", ],
      p_value = rdd_bw$pv["Robust", ],
      ci_lower = rdd_bw$ci["Robust", 1],
      ci_upper = rdd_bw$ci["Robust", 2],
      n_eff = rdd_bw$N_h[1] + rdd_bw$N_h[2]
    )
    cat(sprintf("  h = %.1f (%.0f%% opt): coef = %.4f, p = %.4f, N = %d\n",
                h, mult * 100, rdd_bw$coef["Robust", ],
                rdd_bw$pv["Robust", ], rdd_bw$N_h[1] + rdd_bw$N_h[2]))
  }
}

bw_df <- rbindlist(bw_results)
fwrite(bw_df, file.path(TAB_DIR, "bandwidth_sensitivity.csv"))

# ============================================================================
# B. Donut RDD
# ============================================================================

cat("\n=== B. Donut RDD ===\n")

donut_sizes <- c(2, 5)  # minutes excluded around cutoff (larger windows produce too few observations)
donut_results <- list()

for (donut in donut_sizes) {
  df_donut <- df[abs(run_var) > donut]

  rdd_donut <- tryCatch(
    rdrobust(y = df_donut[[PRIMARY]], x = df_donut$run_var, c = 0),
    error = function(e) NULL
  )

  if (!is.null(rdd_donut)) {
    donut_results[[as.character(donut)]] <- data.table(
      donut_minutes = donut,
      coef = rdd_donut$coef["Robust", ],
      se = rdd_donut$se["Robust", ],
      p_value = rdd_donut$pv["Robust", ],
      ci_lower = rdd_donut$ci["Robust", 1],
      ci_upper = rdd_donut$ci["Robust", 2],
      n_eff = rdd_donut$N_h[1] + rdd_donut$N_h[2],
      bw = rdd_donut$bws["h", "left"]
    )
    cat(sprintf("  Donut ±%d min: coef = %.4f, p = %.4f, N = %d\n",
                donut, rdd_donut$coef["Robust", ],
                rdd_donut$pv["Robust", ], rdd_donut$N_h[1] + rdd_donut$N_h[2]))
  }
}

donut_df <- rbindlist(donut_results)
fwrite(donut_df, file.path(TAB_DIR, "donut_rdd.csv"))

# ============================================================================
# C. Placebo Cutoffs
# ============================================================================

cat("\n=== C. Placebo Cutoffs ===\n")

placebo_cutoffs <- c(10*60, 11*60, 12*60, 13*60, 15*60, 16*60, 17*60, 18*60)  # minutes since midnight
placebo_results <- list()

for (pc in placebo_cutoffs) {
  full[, placebo_run := minutes_since_midnight - pc]
  df_placebo <- full[abs(placebo_run) <= 120]

  if (nrow(df_placebo) < 100) next

  rdd_plac <- tryCatch(
    rdrobust(y = df_placebo[[PRIMARY]], x = df_placebo$placebo_run, c = 0),
    error = function(e) NULL
  )

  if (!is.null(rdd_plac)) {
    placebo_results[[as.character(pc)]] <- data.table(
      cutoff_hour = pc / 60,
      is_real = (pc == 14 * 60),
      coef = rdd_plac$coef["Robust", ],
      se = rdd_plac$se["Robust", ],
      p_value = rdd_plac$pv["Robust", ],
      n_eff = rdd_plac$N_h[1] + rdd_plac$N_h[2]
    )
    cat(sprintf("  Cutoff at %02d:00: coef = %.4f, p = %.4f\n",
                pc / 60, rdd_plac$coef["Robust", ], rdd_plac$pv["Robust", ]))
  }
}

# Add the real cutoff result
rdd_real <- rdrobust(y = df[[PRIMARY]], x = df$run_var, c = 0)
placebo_results[["real"]] <- data.table(
  cutoff_hour = 14,
  is_real = TRUE,
  coef = rdd_real$coef["Robust", ],
  se = rdd_real$se["Robust", ],
  p_value = rdd_real$pv["Robust", ],
  n_eff = rdd_real$N_h[1] + rdd_real$N_h[2]
)

placebo_df <- rbindlist(placebo_results)
fwrite(placebo_df, file.path(TAB_DIR, "placebo_cutoffs.csv"))

# ============================================================================
# D. Placebo Categories (Math subfields)
# ============================================================================

cat("\n=== D. Placebo Categories ===\n")

# Math papers: less list-order-sensitive (smaller communities, fewer daily submissions)
# This tests whether the effect is specific to high-traffic AI categories
if ("categories" %in% names(full)) {
  # Check if we have math papers in the full sample
  full[, has_math := grepl("math\\.", categories)]
  n_math <- sum(full$has_math)
  cat(sprintf("Math papers in full sample: %d\n", n_math))

  if (n_math > 500) {
    math_df <- full[has_math == TRUE & abs(run_var) <= 120]
    if (nrow(math_df) > 200 & PRIMARY %in% names(math_df)) {
      rdd_math <- tryCatch(
        rdrobust(y = math_df[[PRIMARY]], x = math_df$run_var, c = 0),
        error = function(e) NULL
      )
      if (!is.null(rdd_math)) {
        cat(sprintf("  Math placebo: coef = %.4f, p = %.4f\n",
                    rdd_math$coef["Robust", ], rdd_math$pv["Robust", ]))
      }
    }
  }
}

# ============================================================================
# E. Polynomial Order Sensitivity
# ============================================================================

cat("\n=== E. Polynomial Order ===\n")

poly_results <- list()
for (p in 1:3) {
  rdd_poly <- tryCatch(
    rdrobust(y = df[[PRIMARY]], x = df$run_var, c = 0, p = p),
    error = function(e) NULL
  )

  if (!is.null(rdd_poly)) {
    poly_results[[as.character(p)]] <- data.table(
      poly_order = p,
      coef = rdd_poly$coef["Robust", ],
      se = rdd_poly$se["Robust", ],
      p_value = rdd_poly$pv["Robust", ],
      bw = rdd_poly$bws["h", "left"],
      n_eff = rdd_poly$N_h[1] + rdd_poly$N_h[2]
    )
    cat(sprintf("  p = %d: coef = %.4f, p = %.4f\n",
                p, rdd_poly$coef["Robust", ], rdd_poly$pv["Robust", ]))
  }
}

poly_df <- rbindlist(poly_results)
fwrite(poly_df, file.path(TAB_DIR, "polynomial_order.csv"))

# ============================================================================
# F. Kernel Sensitivity
# ============================================================================

cat("\n=== F. Kernel Sensitivity ===\n")

kernel_results <- list()
for (k in c("triangular", "epanechnikov", "uniform")) {
  rdd_kern <- tryCatch(
    rdrobust(y = df[[PRIMARY]], x = df$run_var, c = 0, kernel = k),
    error = function(e) NULL
  )

  if (!is.null(rdd_kern)) {
    kernel_results[[k]] <- data.table(
      kernel = k,
      coef = rdd_kern$coef["Robust", ],
      se = rdd_kern$se["Robust", ],
      p_value = rdd_kern$pv["Robust", ],
      bw = rdd_kern$bws["h", "left"]
    )
    cat(sprintf("  %s: coef = %.4f, p = %.4f\n",
                k, rdd_kern$coef["Robust", ], rdd_kern$pv["Robust", ]))
  }
}

kernel_df <- rbindlist(kernel_results)
fwrite(kernel_df, file.path(TAB_DIR, "kernel_sensitivity.csv"))

# ============================================================================
# G. Conference Deadline Exclusion
# ============================================================================

cat("\n=== G. Conference Deadline Exclusion ===\n")

# Major ML conference deadlines (approximate weeks to exclude)
# These are periods where strategic timing is most likely
# NeurIPS: late May, ICML: late January, ICLR: late September
# We exclude ±2 weeks around major deadlines

# Define approximate deadline months (varies by year)
deadline_months <- c(1, 5, 9)  # Jan (ICML), May (NeurIPS), Sep (ICLR)

if ("submission_date" %in% names(df)) {
  df[, sub_month := month(as.Date(submission_date))]
  df_no_deadline <- df[!(sub_month %in% deadline_months)]

  if (nrow(df_no_deadline) > 500) {
    rdd_nodeadline <- tryCatch(
      rdrobust(y = df_no_deadline[[PRIMARY]], x = df_no_deadline$run_var, c = 0),
      error = function(e) NULL
    )

    if (!is.null(rdd_nodeadline)) {
      cat(sprintf("  Excl. conference months: coef = %.4f, p = %.4f, N = %d\n",
                  rdd_nodeadline$coef["Robust", ], rdd_nodeadline$pv["Robust", ],
                  rdd_nodeadline$N_h[1] + rdd_nodeadline$N_h[2]))
    }
  }
}

# ============================================================================
# H. Year-by-Year Estimates
# ============================================================================

cat("\n=== H. Year-by-Year Estimates ===\n")

year_results <- list()
for (yr in sort(unique(df$v1_year))) {
  df_yr <- df[v1_year == yr]
  if (nrow(df_yr) < 200) next

  rdd_yr <- tryCatch(
    rdrobust(y = df_yr[[PRIMARY]], x = df_yr$run_var, c = 0),
    error = function(e) NULL
  )

  if (!is.null(rdd_yr)) {
    year_results[[as.character(yr)]] <- data.table(
      year = yr,
      coef = rdd_yr$coef["Robust", ],
      se = rdd_yr$se["Robust", ],
      p_value = rdd_yr$pv["Robust", ],
      ci_lower = rdd_yr$ci["Robust", 1],
      ci_upper = rdd_yr$ci["Robust", 2],
      n_eff = rdd_yr$N_h[1] + rdd_yr$N_h[2]
    )
    cat(sprintf("  %d: coef = %.4f, p = %.4f, N = %d\n",
                yr, rdd_yr$coef["Robust", ], rdd_yr$pv["Robust", ],
                rdd_yr$N_h[1] + rdd_yr$N_h[2]))
  }
}

year_df <- rbindlist(year_results)
fwrite(year_df, file.path(TAB_DIR, "year_by_year.csv"))

# ============================================================================
# I. Category Heterogeneity
# ============================================================================

cat("\n=== I. Category Heterogeneity ===\n")

cat_results <- list()
for (ai_cat in c("cs.AI", "cs.CL", "cs.LG", "stat.ML", "cs.CV")) {
  df_cat <- df[grepl(ai_cat, categories)]
  if (nrow(df_cat) < 200) next

  rdd_cat <- tryCatch(
    rdrobust(y = df_cat[[PRIMARY]], x = df_cat$run_var, c = 0),
    error = function(e) NULL
  )

  if (!is.null(rdd_cat)) {
    cat_results[[ai_cat]] <- data.table(
      category = ai_cat,
      coef = rdd_cat$coef["Robust", ],
      se = rdd_cat$se["Robust", ],
      p_value = rdd_cat$pv["Robust", ],
      n_eff = rdd_cat$N_h[1] + rdd_cat$N_h[2]
    )
    cat(sprintf("  %s: coef = %.4f, p = %.4f, N = %d\n",
                ai_cat, rdd_cat$coef["Robust", ], rdd_cat$pv["Robust", ],
                rdd_cat$N_h[1] + rdd_cat$N_h[2]))
  }
}

cat_df <- rbindlist(cat_results)
fwrite(cat_df, file.path(TAB_DIR, "category_heterogeneity.csv"))

cat("\n=== Robustness analysis complete ===\n")
