###############################################################################
# 03_main_analysis.R — RDD estimation
# Paper: The Price of Position (apep_0490)
###############################################################################

source("00_packages.R")

cat("=== Loading analysis data ===\n")
df <- fread(file.path(DATA_DIR, "rdd_sample.csv"))
full <- fread(file.path(DATA_DIR, "full_sample.csv"))
cat(sprintf("RDD sample: %d papers\n", nrow(df)))

# ============================================================================
# A. McCrary Density Test (Manipulation Test)
# ============================================================================

cat("\n=== A. McCrary Density Test ===\n")

density_test <- rddensity(X = df$run_var, c = 0)
cat(sprintf("McCrary p-value: %.4f\n", density_test$test$p_jk))
cat(sprintf("T-statistic: %.3f\n", density_test$test$t_jk))

# Also test with different bandwidths
for (bw in c(15, 30, 60)) {
  dt <- rddensity(X = df$run_var, c = 0, h = c(bw, bw))
  cat(sprintf("  Bandwidth ±%d min: p = %.4f\n", bw, dt$test$p_jk))
}

# Save density test results
density_results <- data.table(
  test = "McCrary",
  t_stat = density_test$test$t_jk,
  p_value = density_test$test$p_jk,
  n_left = density_test$N$eff_l,
  n_right = density_test$N$eff_r,
  h_left = density_test$h$left,
  h_right = density_test$h$right
)
fwrite(density_results, file.path(TAB_DIR, "density_test.csv"))

# ============================================================================
# B. Covariate Balance Tests
# ============================================================================

cat("\n=== B. Covariate Balance Tests ===\n")

balance_vars <- c("n_authors", "n_categories", "abstract_length")

# Add category indicators if they exist
for (v in c("is_cs_AI", "is_cs_CL", "is_cs_LG", "is_stat_ML", "is_cs_CV")) {
  if (v %in% names(df)) balance_vars <- c(balance_vars, v)
}

balance_results <- list()

for (var in balance_vars) {
  if (!(var %in% names(df))) next
  y <- df[[var]]
  if (all(is.na(y))) next

  rdd_bal <- tryCatch(
    rdrobust(y = y, x = df$run_var, c = 0),
    error = function(e) NULL
  )

  if (!is.null(rdd_bal)) {
    balance_results[[var]] <- data.table(
      variable = var,
      coef = rdd_bal$coef["Conventional", ],
      se = rdd_bal$se["Conventional", ],
      p_value = rdd_bal$pv["Conventional", ],
      bw = rdd_bal$bws["h", "left"],
      n_eff = rdd_bal$N_h[1] + rdd_bal$N_h[2]
    )
    cat(sprintf("  %s: coef = %.3f, p = %.3f\n", var,
                rdd_bal$coef["Conventional", ], rdd_bal$pv["Conventional", ]))
  }
}

balance_df <- rbindlist(balance_results, fill = TRUE)
fwrite(balance_df, file.path(TAB_DIR, "balance_tests.csv"))

# ============================================================================
# C. First Stage: Effect on Listing Position
# ============================================================================

cat("\n=== C. First Stage: Position ===\n")

if ("position_pctile" %in% names(df)) {
  rdd_position <- rdrobust(y = df$position_pctile, x = df$run_var, c = 0)
  cat("First stage (position percentile):\n")
  summary(rdd_position)

  first_stage <- data.table(
    outcome = "Position Percentile",
    coef = rdd_position$coef["Conventional", ],
    se = rdd_position$se["Conventional", ],
    ci_lower = rdd_position$ci["Conventional", 1],
    ci_upper = rdd_position$ci["Conventional", 2],
    p_value = rdd_position$pv["Conventional", ],
    bw = rdd_position$bws["h", "left"],
    n_eff_left = rdd_position$N_h[1],
    n_eff_right = rdd_position$N_h[2]
  )
  fwrite(first_stage, file.path(TAB_DIR, "first_stage.csv"))
}

# ============================================================================
# D. Main RDD Results: Citations
# ============================================================================

cat("\n=== D. Main RDD Results ===\n")

citation_outcomes <- c("ln_cited_by_count", "ln_cite_1y", "ln_cite_3y", "ln_cite_5y",
                        "cited_by_count", "cite_1y", "cite_3y", "cite_5y")

# Filter to outcomes that exist in data
citation_outcomes <- citation_outcomes[citation_outcomes %in% names(df)]

main_results <- list()

for (outcome in citation_outcomes) {
  y <- df[[outcome]]
  if (all(is.na(y))) next

  rdd_out <- tryCatch(
    rdrobust(y = y, x = df$run_var, c = 0),
    error = function(e) {
      cat(sprintf("  Error for %s: %s\n", outcome, conditionMessage(e)))
      NULL
    }
  )

  if (!is.null(rdd_out)) {
    main_results[[outcome]] <- data.table(
      outcome = outcome,
      coef_conv = rdd_out$coef["Conventional", ],
      se_conv = rdd_out$se["Conventional", ],
      p_conv = rdd_out$pv["Conventional", ],
      coef_bc = rdd_out$coef["Bias-Corrected", ],
      se_bc = rdd_out$se["Bias-Corrected", ],
      p_bc = rdd_out$pv["Bias-Corrected", ],
      coef_robust = rdd_out$coef["Robust", ],
      se_robust = rdd_out$se["Robust", ],
      p_robust = rdd_out$pv["Robust", ],
      ci_robust_lower = rdd_out$ci["Robust", 1],
      ci_robust_upper = rdd_out$ci["Robust", 2],
      bw_h = rdd_out$bws["h", "left"],
      bw_b = rdd_out$bws["b", "left"],
      n_eff_left = rdd_out$N_h[1],
      n_eff_right = rdd_out$N_h[2],
      n_eff_total = rdd_out$N_h[1] + rdd_out$N_h[2]
    )
    cat(sprintf("  %s: coef = %.4f (se = %.4f), p = %.4f, bw = %.1f min, N_eff = %d\n",
                outcome,
                rdd_out$coef["Robust", ], rdd_out$se["Robust", ],
                rdd_out$pv["Robust", ], rdd_out$bws["h", "left"],
                rdd_out$N_h[1] + rdd_out$N_h[2]))
  }
}

main_df <- rbindlist(main_results, fill = TRUE)
fwrite(main_df, file.path(TAB_DIR, "main_results.csv"))

# ============================================================================
# E. Industry Adoption
# ============================================================================

cat("\n=== E. Industry Adoption ===\n")

if ("has_industry_affil" %in% names(df)) {
  rdd_industry <- tryCatch(
    rdrobust(y = df$has_industry_affil, x = df$run_var, c = 0),
    error = function(e) {
      cat("Industry affiliation RDD failed:", conditionMessage(e), "\n")
      NULL
    }
  )

  if (!is.null(rdd_industry)) {
    cat("Industry citation (from citing papers at industry labs):\n")
    summary(rdd_industry)

    industry_result <- data.table(
      outcome = "Industry Affiliation",
      coef = rdd_industry$coef["Robust", ],
      se = rdd_industry$se["Robust", ],
      p_value = rdd_industry$pv["Robust", ],
      bw = rdd_industry$bws["h", "left"]
    )
    fwrite(industry_result, file.path(TAB_DIR, "industry_adoption.csv"))
  }
}

# ============================================================================
# F. Top Venue Publication
# ============================================================================

cat("\n=== F. Top Venue Publication ===\n")

if ("top_venue" %in% names(df)) {
  rdd_venue <- tryCatch(
    rdrobust(y = df$top_venue, x = df$run_var, c = 0),
    error = function(e) {
      cat("Top venue RDD failed:", conditionMessage(e), "\n")
      NULL
    }
  )

  if (!is.null(rdd_venue)) {
    cat("Top venue publication:\n")
    summary(rdd_venue)

    venue_result <- data.table(
      outcome = "Top Venue",
      coef = rdd_venue$coef["Robust", ],
      se = rdd_venue$se["Robust", ],
      p_value = rdd_venue$pv["Robust", ],
      bw = rdd_venue$bws["h", "left"]
    )
    fwrite(venue_result, file.path(TAB_DIR, "top_venue.csv"))
  }
}

# ============================================================================
# G. Highly Cited (Top 10%)
# ============================================================================

cat("\n=== G. Highly Cited ===\n")

if ("highly_cited" %in% names(df)) {
  rdd_hc <- tryCatch(
    rdrobust(y = df$highly_cited, x = df$run_var, c = 0),
    error = function(e) NULL
  )

  if (!is.null(rdd_hc)) {
    cat("Highly cited (top 10%):\n")
    summary(rdd_hc)
  }
}

# ============================================================================
# H. Heterogeneity: Day of Week
# ============================================================================

cat("\n=== H. Day-of-Week Heterogeneity ===\n")

if ("thursday_sub" %in% names(df) && "ln_cite_3y" %in% names(df)) {
  # Thursday submissions (3-day front page)
  df_thu <- df[thursday_sub == 1]
  df_nonthu <- df[thursday_sub == 0]

  if (nrow(df_thu) > 100 & nrow(df_nonthu) > 100) {
    rdd_thu <- tryCatch(
      rdrobust(y = df_thu$ln_cite_3y, x = df_thu$run_var, c = 0),
      error = function(e) NULL
    )
    rdd_nonthu <- tryCatch(
      rdrobust(y = df_nonthu$ln_cite_3y, x = df_nonthu$run_var, c = 0),
      error = function(e) NULL
    )

    if (!is.null(rdd_thu) & !is.null(rdd_nonthu)) {
      cat(sprintf("Thursday (3-day front page): coef = %.4f (p = %.4f)\n",
                  rdd_thu$coef["Robust", ], rdd_thu$pv["Robust", ]))
      cat(sprintf("Non-Thursday: coef = %.4f (p = %.4f)\n",
                  rdd_nonthu$coef["Robust", ], rdd_nonthu$pv["Robust", ]))
    }
  }
}

cat("\n=== Main analysis complete ===\n")
