###############################################################################
# 03_main_analysis.R — RDD estimation with adoption as primary outcome
# Paper: Does Visibility Delay Frontier AI? (apep_0490 v3)
#
# Primary outcomes: frontier lab adoption speed & probability
# Secondary outcomes: general citations (consistency with v2)
###############################################################################

source("00_packages.R")

cat("=== Loading analysis data ===\n")
df <- fread(file.path(DATA_DIR, "rdd_sample.csv"))
full <- fread(file.path(DATA_DIR, "full_sample.csv"))
cat(sprintf("RDD sample: %d papers\n", nrow(df)))
cat(sprintf("Full sample: %d papers\n", nrow(full)))

# ============================================================================
# A. McCrary Density Test (Manipulation Test)
# ============================================================================

cat("\n=== A. McCrary Density Test ===\n")

density_test <- rddensity(X = df$run_var, c = 0)
cat(sprintf("McCrary p-value: %.4f\n", density_test$test$p_jk))
cat(sprintf("T-statistic: %.3f\n", density_test$test$t_jk))

for (bw in c(15, 30, 60, 90)) {
  dt <- tryCatch(
    rddensity(X = df$run_var, c = 0, h = c(bw, bw)),
    error = function(e) NULL
  )
  if (!is.null(dt)) {
    cat(sprintf("  Bandwidth ±%d min: p = %.4f\n", bw, dt$test$p_jk))
  }
}

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

balance_vars <- c("n_authors", "n_categories", "abstract_length",
                   "batch_size", "thursday_sub")

# Add category indicators
for (v in c("is_cs_AI", "is_cs_CL", "is_cs_LG", "is_stat_ML", "is_cs_CV")) {
  if (v %in% names(df)) balance_vars <- c(balance_vars, v)
}

# Day-of-week indicators for balance
for (v in c("dow_mon", "dow_tue", "dow_wed", "dow_thu", "dow_fri")) {
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
# D. PRIMARY OUTCOME: Frontier Lab Adoption
# ============================================================================

cat("\n=== D. Primary: Frontier Lab Adoption ===\n")

# D.1 Binary: adopted by frontier lab (ever)
adoption_outcomes <- c(
  "has_frontier_cite",
  "frontier_adopted_12m",
  "frontier_adopted_18m",
  "has_industry_cite",
  "adopted_12m",
  "adopted_18m",
  "n_frontier_cites",
  "ln_frontier_cites",
  "n_frontier_labs_18m",
  "frontier_cite_share",
  "n_industry_cites",
  "ln_industry_cites",
  "industry_cite_share",
  "n_distinct_companies",
  "has_bigtech_cite"
)

adoption_outcomes <- adoption_outcomes[adoption_outcomes %in% names(df)]

adoption_results <- list()

for (outcome in adoption_outcomes) {
  y <- df[[outcome]]
  if (all(is.na(y)) || sum(!is.na(y)) < 100) {
    cat(sprintf("  %s: skipped (too few obs)\n", outcome))
    next
  }

  rdd_out <- tryCatch(
    rdrobust(y = y, x = df$run_var, c = 0),
    error = function(e) {
      cat(sprintf("  %s: error — %s\n", outcome, conditionMessage(e)))
      NULL
    }
  )

  if (!is.null(rdd_out)) {
    adoption_results[[outcome]] <- data.table(
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
      n_eff_total = rdd_out$N_h[1] + rdd_out$N_h[2],
      mean_y = mean(y, na.rm = TRUE),
      sd_y = sd(y, na.rm = TRUE)
    )
    cat(sprintf("  %s: coef = %.4f (se = %.4f), p = %.4f, bw = %.1f, N = %d, mean = %.3f\n",
                outcome,
                rdd_out$coef["Robust", ], rdd_out$se["Robust", ],
                rdd_out$pv["Robust", ], rdd_out$bws["h", "left"],
                rdd_out$N_h[1] + rdd_out$N_h[2],
                mean(y, na.rm = TRUE)))
  }
}

if (length(adoption_results) > 0) {
  adoption_df <- rbindlist(adoption_results, fill = TRUE)
  fwrite(adoption_df, file.path(TAB_DIR, "adoption_results.csv"))
  cat(sprintf("\nSaved %d adoption outcome estimates\n", nrow(adoption_df)))
}

# ============================================================================
# D.2 Adoption Speed: Cox Proportional Hazard with RDD structure
# ============================================================================

cat("\n=== D.2 Adoption Speed (Cox PH) ===\n")

if ("adoption_lag_days" %in% names(df) && "frontier_lag_days" %in% names(df)) {

  # Restrict to papers within optimal bandwidth
  if (exists("rdd_position")) {
    h_opt <- rdd_position$bws["h", "left"]
  } else {
    h_opt <- 30  # default
  }

  df_cox <- df[abs(run_var) <= h_opt]

  # Industry adoption survival
  if (sum(!is.na(df_cox$adoption_lag_days) | df_cox$has_industry_cite == 0) > 50) {
    # Construct survival variables
    df_cox[, surv_time_ind := fifelse(
      has_industry_cite == 1 & !is.na(adoption_lag_days) & adoption_lag_days > 0,
      adoption_lag_days,
      365 * 3  # Right-censor at 3 years for non-adopted
    )]
    df_cox[, surv_event_ind := as.integer(has_industry_cite == 1 & !is.na(adoption_lag_days) & adoption_lag_days > 0)]

    cox_ind <- tryCatch({
      coxph(Surv(surv_time_ind, surv_event_ind) ~ after_cutoff + run_var + I(run_var * after_cutoff),
            data = df_cox)
    }, error = function(e) {
      cat(sprintf("  Cox (industry): error — %s\n", conditionMessage(e)))
      NULL
    })

    if (!is.null(cox_ind)) {
      cat("  Cox PH — Industry adoption:\n")
      print(summary(cox_ind))

      cox_results <- data.table(
        model = "Cox PH — Industry",
        hr_after_cutoff = exp(coef(cox_ind)["after_cutoff"]),
        coef = coef(cox_ind)["after_cutoff"],
        se = sqrt(vcov(cox_ind)["after_cutoff", "after_cutoff"]),
        p_value = summary(cox_ind)$coefficients["after_cutoff", "Pr(>|z|)"],
        n = cox_ind$n,
        n_events = cox_ind$nevent,
        concordance = summary(cox_ind)$concordance[1]
      )
      fwrite(cox_results, file.path(TAB_DIR, "cox_industry.csv"))
    }
  }

  # Frontier lab adoption survival
  if (sum(!is.na(df_cox$frontier_lag_days) | df_cox$has_frontier_cite == 0) > 50) {
    df_cox[, surv_time_fr := fifelse(
      has_frontier_cite == 1 & !is.na(frontier_lag_days) & frontier_lag_days > 0,
      frontier_lag_days,
      365 * 3
    )]
    df_cox[, surv_event_fr := as.integer(has_frontier_cite == 1 & !is.na(frontier_lag_days) & frontier_lag_days > 0)]

    cox_fr <- tryCatch({
      coxph(Surv(surv_time_fr, surv_event_fr) ~ after_cutoff + run_var + I(run_var * after_cutoff),
            data = df_cox)
    }, error = function(e) {
      cat(sprintf("  Cox (frontier): error — %s\n", conditionMessage(e)))
      NULL
    })

    if (!is.null(cox_fr)) {
      cat("  Cox PH — Frontier adoption:\n")
      print(summary(cox_fr))

      cox_fr_results <- data.table(
        model = "Cox PH — Frontier",
        hr_after_cutoff = exp(coef(cox_fr)["after_cutoff"]),
        coef = coef(cox_fr)["after_cutoff"],
        se = sqrt(vcov(cox_fr)["after_cutoff", "after_cutoff"]),
        p_value = summary(cox_fr)$coefficients["after_cutoff", "Pr(>|z|)"],
        n = cox_fr$n,
        n_events = cox_fr$nevent,
        concordance = summary(cox_fr)$concordance[1]
      )
      fwrite(cox_fr_results, file.path(TAB_DIR, "cox_frontier.csv"))
    }
  }
}

# ============================================================================
# E. SECONDARY OUTCOME: General Citations
# ============================================================================

cat("\n=== E. Secondary: General Citations ===\n")

citation_outcomes <- c("ln_cited_by_count", "ln_cite_1y", "ln_cite_3y", "ln_cite_5y",
                        "cited_by_count", "cite_1y", "cite_3y", "cite_5y",
                        "highly_cited", "top_venue")
citation_outcomes <- citation_outcomes[citation_outcomes %in% names(df)]

citation_results <- list()

for (outcome in citation_outcomes) {
  y <- df[[outcome]]
  if (all(is.na(y)) || sum(!is.na(y)) < 100) next

  rdd_out <- tryCatch(
    rdrobust(y = y, x = df$run_var, c = 0),
    error = function(e) NULL
  )

  if (!is.null(rdd_out)) {
    citation_results[[outcome]] <- data.table(
      outcome = outcome,
      coef_conv = rdd_out$coef["Conventional", ],
      se_conv = rdd_out$se["Conventional", ],
      p_conv = rdd_out$pv["Conventional", ],
      coef_robust = rdd_out$coef["Robust", ],
      se_robust = rdd_out$se["Robust", ],
      p_robust = rdd_out$pv["Robust", ],
      ci_robust_lower = rdd_out$ci["Robust", 1],
      ci_robust_upper = rdd_out$ci["Robust", 2],
      bw_h = rdd_out$bws["h", "left"],
      n_eff_left = rdd_out$N_h[1],
      n_eff_right = rdd_out$N_h[2],
      n_eff_total = rdd_out$N_h[1] + rdd_out$N_h[2],
      mean_y = mean(y, na.rm = TRUE)
    )
    cat(sprintf("  %s: coef = %.4f, p = %.4f, N = %d\n",
                outcome,
                rdd_out$coef["Robust", ], rdd_out$pv["Robust", ],
                rdd_out$N_h[1] + rdd_out$N_h[2]))
  }
}

citation_df <- rbindlist(citation_results, fill = TRUE)
fwrite(citation_df, file.path(TAB_DIR, "citation_results.csv"))

# ============================================================================
# F. Heterogeneity: Day-of-Week
# ============================================================================

cat("\n=== F. Day-of-Week Heterogeneity ===\n")

# Primary adoption outcome for heterogeneity
ADOPT_PRIMARY <- "frontier_adopted_18m"
if (!(ADOPT_PRIMARY %in% names(df))) ADOPT_PRIMARY <- "has_frontier_cite"
if (!(ADOPT_PRIMARY %in% names(df))) ADOPT_PRIMARY <- "ln_cite_3y"

# Mon-Wed vs Thu-Fri
if ("early_week" %in% names(df)) {
  df_early <- df[early_week == 1]
  df_late <- df[early_week == 0]

  if (nrow(df_early) > 200 & nrow(df_late) > 200) {
    rdd_early <- tryCatch(
      rdrobust(y = df_early[[ADOPT_PRIMARY]], x = df_early$run_var, c = 0),
      error = function(e) NULL
    )
    rdd_late <- tryCatch(
      rdrobust(y = df_late[[ADOPT_PRIMARY]], x = df_late$run_var, c = 0),
      error = function(e) NULL
    )

    if (!is.null(rdd_early) & !is.null(rdd_late)) {
      cat(sprintf("  Mon-Wed: coef = %.4f (p = %.4f), N = %d\n",
                  rdd_early$coef["Robust", ], rdd_early$pv["Robust", ],
                  rdd_early$N_h[1] + rdd_early$N_h[2]))
      cat(sprintf("  Thu-Fri: coef = %.4f (p = %.4f), N = %d\n",
                  rdd_late$coef["Robust", ], rdd_late$pv["Robust", ],
                  rdd_late$N_h[1] + rdd_late$N_h[2]))

      dow_het <- data.table(
        subgroup = c("Mon-Wed", "Thu-Fri"),
        coef = c(rdd_early$coef["Robust", ], rdd_late$coef["Robust", ]),
        se = c(rdd_early$se["Robust", ], rdd_late$se["Robust", ]),
        p_value = c(rdd_early$pv["Robust", ], rdd_late$pv["Robust", ]),
        n_eff = c(rdd_early$N_h[1] + rdd_early$N_h[2],
                  rdd_late$N_h[1] + rdd_late$N_h[2])
      )
      fwrite(dow_het, file.path(TAB_DIR, "dow_heterogeneity.csv"))
    }
  }
}

# ============================================================================
# G. Heterogeneity: Category
# ============================================================================

cat("\n=== G. Category Heterogeneity ===\n")

cat_results <- list()
for (ai_cat in c("cs.AI", "cs.CL", "cs.LG", "stat.ML", "cs.CV")) {
  df_cat <- df[grepl(ai_cat, categories)]
  if (nrow(df_cat) < 200 || !(ADOPT_PRIMARY %in% names(df_cat))) next

  rdd_cat <- tryCatch(
    rdrobust(y = df_cat[[ADOPT_PRIMARY]], x = df_cat$run_var, c = 0),
    error = function(e) NULL
  )

  if (!is.null(rdd_cat)) {
    cat_results[[ai_cat]] <- data.table(
      category = ai_cat,
      outcome = ADOPT_PRIMARY,
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

if (length(cat_results) > 0) {
  cat_df <- rbindlist(cat_results)
  fwrite(cat_df, file.path(TAB_DIR, "category_heterogeneity.csv"))
}

# ============================================================================
# H. Year-by-Year Estimates
# ============================================================================

cat("\n=== H. Year-by-Year Estimates ===\n")

year_results <- list()
for (yr in sort(unique(df$v1_year))) {
  df_yr <- df[v1_year == yr]
  if (nrow(df_yr) < 200 || !(ADOPT_PRIMARY %in% names(df_yr))) next

  rdd_yr <- tryCatch(
    rdrobust(y = df_yr[[ADOPT_PRIMARY]], x = df_yr$run_var, c = 0),
    error = function(e) NULL
  )

  if (!is.null(rdd_yr)) {
    year_results[[as.character(yr)]] <- data.table(
      year = yr,
      outcome = ADOPT_PRIMARY,
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

if (length(year_results) > 0) {
  year_df <- rbindlist(year_results)
  fwrite(year_df, file.path(TAB_DIR, "year_by_year.csv"))
}

cat("\n=== Main analysis complete ===\n")
