###############################################################################
# 03_main_analysis.R — Main estimation
# apep_0483 v2: Teacher Pay Competitiveness and Student Value-Added
#
# Part A: LA-level panel FE (main specification)
# Part B: Event study (baseline comp × year interactions)
# Part C: Academy DDD (school-level 2023/24)
# Part D: Heterogeneity
###############################################################################

source("00_packages.R")

data_dir <- "../data/"

la_panel <- fread(paste0(data_dir, "la_panel.csv"))
school_panel <- fread(paste0(data_dir, "school_panel.csv"))

cat(sprintf("LA panel: %d obs, %d LAs, years: %s\n",
            nrow(la_panel), uniqueN(la_panel$la_code),
            paste(sort(unique(la_panel$year)), collapse=", ")))
cat(sprintf("School panel: %d schools (2023/24)\n", nrow(school_panel)))

###############################################################################
# Part A: LA-Level Panel FE
###############################################################################

cat("\n=== LA-LEVEL PANEL FE ===\n\n")

est_la <- la_panel[!is.na(progress8) & !is.na(comp_ratio)]
cat(sprintf("Estimation sample: %d LA-years\n", nrow(est_la)))

# Spec 1: Pooled OLS
m1_ols <- feols(progress8 ~ comp_ratio, data = est_la,
                cluster = ~la_code)

# Spec 2: Year FE only
m2_yfe <- feols(progress8 ~ comp_ratio | year, data = est_la,
                cluster = ~la_code)

# Spec 3: LA FE + Year FE (MAIN SPEC)
m3_main <- feols(progress8 ~ comp_ratio | la_id + year, data = est_la,
                 cluster = ~la_code)

# Spec 4: Weighted by number of pupils
if ("n_pupils" %in% names(est_la) && sum(!is.na(est_la$n_pupils)) > 50) {
  m4_weighted <- feols(progress8 ~ comp_ratio | la_id + year, data = est_la,
                       weights = ~n_pupils, cluster = ~la_code)
} else {
  m4_weighted <- NULL
}

# Spec 5: Attainment 8
if (sum(!is.na(est_la$attainment8)) > 50) {
  m5_a8 <- feols(attainment8 ~ comp_ratio | la_id + year, data = est_la,
                 cluster = ~la_code)
} else {
  m5_a8 <- NULL
}

cat("Main results:\n")
# Helper to extract p-value from fixest
get_pval <- function(m, var) {
  ct <- coeftable(m)
  ct[var, "Pr(>|t|)"]
}

cat(sprintf("  OLS:          beta = %.3f (SE = %.3f), p = %.3f, N = %d\n",
            coef(m1_ols)["comp_ratio"], se(m1_ols)["comp_ratio"],
            get_pval(m1_ols, "comp_ratio"), nobs(m1_ols)))
cat(sprintf("  Year FE:      beta = %.3f (SE = %.3f), p = %.3f\n",
            coef(m2_yfe)["comp_ratio"], se(m2_yfe)["comp_ratio"],
            get_pval(m2_yfe, "comp_ratio")))
cat(sprintf("  LA+Year FE:   beta = %.3f (SE = %.3f), p = %.3f\n",
            coef(m3_main)["comp_ratio"], se(m3_main)["comp_ratio"],
            get_pval(m3_main, "comp_ratio")))
if (!is.null(m4_weighted)) {
  cat(sprintf("  Weighted:     beta = %.3f (SE = %.3f), p = %.3f\n",
              coef(m4_weighted)["comp_ratio"], se(m4_weighted)["comp_ratio"],
              get_pval(m4_weighted, "comp_ratio")))
}
if (!is.null(m5_a8)) {
  cat(sprintf("  Attainment 8: beta = %.3f (SE = %.3f), p = %.3f\n",
              coef(m5_a8)["comp_ratio"], se(m5_a8)["comp_ratio"],
              get_pval(m5_a8, "comp_ratio")))
}

main_results <- list(
  ols = m1_ols, year_fe = m2_yfe, main = m3_main,
  weighted = m4_weighted, attainment8 = m5_a8
)
saveRDS(main_results, paste0(data_dir, "main_results.rds"))

###############################################################################
# Part B: Event Study
###############################################################################

cat("\n=== EVENT STUDY ===\n\n")

# Baseline competitiveness (first year) × year interactions
# Reference: 2018 (last pre-COVID year: academic 2018/19)
est_la[, year_f := factor(year)]
ref_year <- 2018

if (as.character(ref_year) %in% levels(est_la$year_f)) {
  est_la[, year_f := relevel(year_f, ref = as.character(ref_year))]
}

m_event <- tryCatch(
  feols(progress8 ~ i(year, baseline_comp, ref = ref_year) | la_id + year,
        data = est_la, cluster = ~la_code),
  error = function(e) {
    cat(sprintf("Event study failed: %s\n", e$message))
    NULL
  }
)

if (!is.null(m_event)) {
  cat("Event study coefficients:\n")
  print(coeftable(m_event))

  # Extract for plotting
  coef_names <- names(coef(m_event))
  event_years <- as.integer(gsub(".*year::(\\d+).*", "\\1", coef_names))

  event_coefs <- data.table(
    year = event_years,
    coef = coef(m_event),
    se = se(m_event)
  )
  event_coefs[, ci_lo := coef - 1.96 * se]
  event_coefs[, ci_hi := coef + 1.96 * se]

  # Add reference year
  event_coefs <- rbind(
    event_coefs,
    data.table(year = ref_year, coef = 0, se = 0, ci_lo = 0, ci_hi = 0)
  )
  event_coefs <- event_coefs[order(year)]

  fwrite(event_coefs, paste0(data_dir, "event_study_coefs.csv"))
  saveRDS(m_event, paste0(data_dir, "event_study_model.rds"))

  # Pre-trends: are pre-COVID coefficients jointly zero?
  pre_coefs <- coef_names[event_years < ref_year]
  if (length(pre_coefs) > 0) {
    pre_test <- tryCatch(wald(m_event, pre_coefs), error = function(e) NULL)
    if (!is.null(pre_test)) {
      cat(sprintf("\nPre-trends joint test: F = %.2f, p = %.3f\n",
                  pre_test$stat, pre_test$p))
    }
  }

  # Post-treatment: are post-COVID coefficients jointly significant?
  post_coefs <- coef_names[event_years > 2019]
  if (length(post_coefs) > 0) {
    post_test <- tryCatch(wald(m_event, post_coefs), error = function(e) NULL)
    if (!is.null(post_test)) {
      cat(sprintf("Post-treatment joint test: F = %.2f, p = %.3f\n",
                  post_test$stat, post_test$p))
    }
  }
}

###############################################################################
# Part C: Academy Triple-Difference (School-Level)
###############################################################################

cat("\n=== ACADEMY TRIPLE-DIFFERENCE ===\n\n")

est_school <- school_panel[!is.na(progress8) & !is.na(comp_ratio) &
                             !is.na(academy)]
cat(sprintf("School estimation sample: %d\n", nrow(est_school)))
cat(sprintf("  Academies: %d, Maintained: %d\n",
            sum(est_school$academy), sum(est_school$maintained)))

# DDD: separate slopes for maintained vs academy
m_ddd <- tryCatch(
  feols(progress8 ~ comp_ratio:maintained + comp_ratio:academy,
        data = est_school, cluster = ~la_code),
  error = function(e) {
    cat(sprintf("DDD failed: %s\n", e$message))
    NULL
  }
)

if (!is.null(m_ddd)) {
  cat("DDD results (separate slopes):\n")
  print(coeftable(m_ddd))

  beta_m <- coef(m_ddd)["comp_ratio:maintained"]
  beta_a <- coef(m_ddd)["comp_ratio:academy"]
  cat(sprintf("\n  Maintained: beta = %.3f (SE = %.3f)\n",
              beta_m, se(m_ddd)["comp_ratio:maintained"]))
  cat(sprintf("  Academy:    beta = %.3f (SE = %.3f)\n",
              beta_a, se(m_ddd)["comp_ratio:academy"]))
  cat(sprintf("  Difference: %.3f\n", beta_m - beta_a))
}

# Interaction form
m_ddd_int <- tryCatch(
  feols(progress8 ~ comp_ratio * maintained, data = est_school,
        cluster = ~la_code),
  error = function(e) NULL
)

if (!is.null(m_ddd_int)) {
  cat("\nDDD (interaction form):\n")
  print(coeftable(m_ddd_int))
}

# With controls (FSM%)
m_ddd_ctrl <- tryCatch(
  feols(progress8 ~ comp_ratio:maintained + comp_ratio:academy + fsm_pct,
        data = est_school[!is.na(fsm_pct)], cluster = ~la_code),
  error = function(e) NULL
)

if (!is.null(m_ddd_ctrl)) {
  cat("\nDDD with FSM control:\n")
  cat(sprintf("  Maintained: %.3f, Academy: %.3f\n",
              coef(m_ddd_ctrl)["comp_ratio:maintained"],
              coef(m_ddd_ctrl)["comp_ratio:academy"]))
}

# Separate regressions by school type
m_maintained <- tryCatch(
  feols(progress8 ~ comp_ratio, data = est_school[maintained == 1],
        cluster = ~la_code),
  error = function(e) NULL
)

m_academy <- tryCatch(
  feols(progress8 ~ comp_ratio, data = est_school[academy == 1],
        cluster = ~la_code),
  error = function(e) NULL
)

if (!is.null(m_maintained) && !is.null(m_academy)) {
  cat(sprintf("\nSeparate regressions:\n"))
  cat(sprintf("  Maintained: beta = %.3f (SE = %.3f), p = %.3f, N = %d\n",
              coef(m_maintained)["comp_ratio"], se(m_maintained)["comp_ratio"],
              coeftable(m_maintained)["comp_ratio", "Pr(>|t|)"], nobs(m_maintained)))
  cat(sprintf("  Academy:    beta = %.3f (SE = %.3f), p = %.3f, N = %d\n",
              coef(m_academy)["comp_ratio"], se(m_academy)["comp_ratio"],
              coeftable(m_academy)["comp_ratio", "Pr(>|t|)"], nobs(m_academy)))
}

ddd_results <- list(
  ddd = m_ddd, ddd_interaction = m_ddd_int, ddd_controls = m_ddd_ctrl,
  maintained = m_maintained, academy = m_academy
)
saveRDS(ddd_results, paste0(data_dir, "ddd_results.rds"))

###############################################################################
# Part D: Heterogeneity
###############################################################################

cat("\n=== HETEROGENEITY ===\n\n")

het_results <- list()

# By STPCD band (LA panel)
for (b in unique(est_la$band[!is.na(est_la$band)])) {
  m_b <- tryCatch(
    feols(progress8 ~ comp_ratio | la_id + year,
          data = est_la[band == b], cluster = ~la_code),
    error = function(e) NULL
  )
  if (!is.null(m_b) && !is.na(coef(m_b)["comp_ratio"])) {
    het_results[[paste0("band_", b)]] <- m_b
    cat(sprintf("  Band %s: beta = %.3f (SE = %.3f), N = %d\n",
                b, coef(m_b)["comp_ratio"], se(m_b)["comp_ratio"], nobs(m_b)))
  }
}

# By FSM quartile (school panel)
if ("fsm_pct" %in% names(est_school) && sum(!is.na(est_school$fsm_pct)) > 100) {
  est_school[, fsm_quartile := cut(fsm_pct,
                                    breaks = quantile(fsm_pct, c(0, 0.25, 0.5, 0.75, 1),
                                                      na.rm = TRUE),
                                    labels = c("Q1", "Q2", "Q3", "Q4"),
                                    include.lowest = TRUE)]

  for (q in levels(est_school$fsm_quartile)) {
    m_q <- tryCatch(
      feols(progress8 ~ comp_ratio,
            data = est_school[fsm_quartile == q], cluster = ~la_code),
      error = function(e) NULL
    )
    if (!is.null(m_q)) {
      het_results[[paste0("fsm_", q)]] <- m_q
      cat(sprintf("  FSM %s: beta = %.3f (SE = %.3f), N = %d\n",
                  q, coef(m_q)["comp_ratio"], se(m_q)["comp_ratio"], nobs(m_q)))
    }
  }
}

saveRDS(het_results, paste0(data_dir, "heterogeneity_results.rds"))

# Save academy placebo for backward compatibility
saveRDS(list(maintained = m_maintained, academy = m_academy),
        paste0(data_dir, "academy_placebo.rds"))

cat("\n=== MAIN ANALYSIS COMPLETE ===\n")
