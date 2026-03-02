## =============================================================================
## 03_main_analysis.R — Primary regressions
## apep_0474: Downtown for Sale? ACV Commercial Displacement
##
## Specifications:
##   1. TWFE DiD (baseline)
##   2. Event study (quarter-by-quarter coefficients)
##   3. Callaway-Sant'Anna estimator
##   4. Displacement test (spillover to neighboring communes)
## =============================================================================

source(file.path(dirname(sys.frame(1)$ofile %||% "code/03_main_analysis.R"), "00_packages.R"))

panel <- fread(file.path(DATA, "panel_commune_quarter.csv"))
cat(sprintf("Panel loaded: %s obs, %d communes\n",
            format(nrow(panel), big.mark = ","),
            length(unique(panel$code_commune))))

## ---- 1. TWFE DiD (Baseline) ----
cat("\n=== TWFE Difference-in-Differences ===\n")

# Main outcome: downtown-facing establishment creations
# Specification: Y_it = α_i + γ_t + β(ACV_i × Post_t) + ε_it

# 1a. Level specification
twfe_level <- feols(
  n_creations ~ treat_post | commune_id + time_id,
  data = panel,
  cluster = ~commune_id
)
cat("TWFE (levels):\n")
print(summary(twfe_level))

# 1b. Log specification
twfe_log <- feols(
  log_creations ~ treat_post | commune_id + time_id,
  data = panel,
  cluster = ~commune_id
)
cat("\nTWFE (log):\n")
print(summary(twfe_log))

# 1c. With département × year FE (absorb regional trends)
panel[, dept_year := paste0(dept, "_", year)]
twfe_deptyr <- feols(
  n_creations ~ treat_post | commune_id + time_id + dept_year,
  data = panel,
  cluster = ~commune_id
)
cat("\nTWFE (dept × year FE):\n")
print(summary(twfe_deptyr))

# 1d. All-sector specification
twfe_all <- feols(
  n_creations_all ~ treat_post | commune_id + time_id,
  data = panel,
  cluster = ~commune_id
)
cat("\nTWFE (all sectors):\n")
print(summary(twfe_all))

## ---- 2. Event Study ----
cat("\n=== Event Study ===\n")

# Bin endpoints: combine all pre ≤ -20 and post ≥ 20
panel[, event_bin := fcase(
  event_time <= -20, -20L,
  event_time >= 20, 20L,
  default = as.integer(event_time)
)]

# Event study with fixest i() syntax
# Reference period: event_time = -1 (2017Q4)
es_level <- feols(
  n_creations ~ i(event_bin, acv, ref = -1) | commune_id + time_id,
  data = panel,
  cluster = ~commune_id
)
cat("Event study (levels):\n")
print(summary(es_level))

# Event study with log
es_log <- feols(
  log_creations ~ i(event_bin, acv, ref = -1) | commune_id + time_id,
  data = panel,
  cluster = ~commune_id
)

# Event study with département × year FE
es_deptyr <- feols(
  n_creations ~ i(event_bin, acv, ref = -1) | commune_id + time_id + dept_year,
  data = panel,
  cluster = ~commune_id
)

# Pre-trend test: joint F-test on pre-treatment coefficients
pre_coefs <- grep("event_bin::-", names(coef(es_level)), value = TRUE)
if (length(pre_coefs) > 1) {
  pre_test <- wald(es_level, pre_coefs)
  cat(sprintf("\nPre-trend F-test: F = %.3f, p = %.4f\n",
              pre_test$stat, pre_test$p))
}

## ---- 3. Callaway-Sant'Anna ----
cat("\n=== Callaway-Sant'Anna Estimator ===\n")

# CS-DiD requires: group (first treatment period), time, id, outcome
# All ACV communes treated simultaneously → single group
# first_treat = 33 (= 2018Q1 in our time_id coding: (2018-2010)*4 + 1 = 33)
panel[, first_treat := fifelse(acv == 1, 33L, 0L)]

# Annual aggregation for CS (quarterly may be too granular)
annual <- panel[, .(
  n_creations = sum(n_creations),
  n_creations_all = sum(n_creations_all),
  n_creations_placebo = sum(n_creations_placebo)
), by = .(code_commune, commune_id, year, acv, dept)]

annual[, first_treat_yr := fifelse(acv == 1, 2018L, 0L)]

cs_out <- tryCatch({
  att_gt(
    yname = "n_creations",
    tname = "year",
    idname = "commune_id",
    gname = "first_treat_yr",
    data = as.data.frame(annual),
    control_group = "nevertreated",
    anticipation = 0,
    base_period = "universal"
  )
}, error = function(e) {
  cat(sprintf("  CS-DiD error: %s\n", e$message))
  NULL
})

if (!is.null(cs_out)) {
  cat("\nCallaway-Sant'Anna group-time ATTs:\n")
  print(summary(cs_out))

  # Aggregate to event time
  cs_es <- aggte(cs_out, type = "dynamic")
  cat("\nCS Event Study:\n")
  print(summary(cs_es))

  # Overall ATT
  cs_overall <- aggte(cs_out, type = "simple")
  cat(sprintf("\nCS Overall ATT: %.3f (SE: %.3f)\n",
              cs_overall$overall.att, cs_overall$overall.se))
}

## ---- 4. Period-specific effects ----
cat("\n=== Period-specific effects ===\n")

# Pre-COVID (2018-2019), COVID (2020-2021), Post-COVID (2022-2024)
panel[, period := fcase(
  year < 2018, "Pre-treatment",
  year %in% 2018:2019, "Post: Pre-COVID",
  year %in% 2020:2021, "Post: COVID",
  year >= 2022, "Post: Recovery"
)]

panel[, post_precovid := fifelse(year %in% 2018:2019, 1L, 0L)]
panel[, post_covid := fifelse(year %in% 2020:2021, 1L, 0L)]
panel[, post_recovery := fifelse(year >= 2022, 1L, 0L)]

twfe_periods <- feols(
  n_creations ~ acv:post_precovid + acv:post_covid + acv:post_recovery |
    commune_id + time_id,
  data = panel,
  cluster = ~commune_id
)
cat("Period-specific TWFE:\n")
print(summary(twfe_periods))

## ---- 5. Placebo test: non-downtown sectors ----
cat("\n=== Placebo test: wholesale sector ===\n")

twfe_placebo <- feols(
  n_creations_placebo ~ treat_post | commune_id + time_id,
  data = panel,
  cluster = ~commune_id
)
cat("Placebo (wholesale):\n")
print(summary(twfe_placebo))

## ---- 6. Save results ----
cat("\n=== Saving results ===\n")

results <- list(
  twfe_level = twfe_level,
  twfe_log = twfe_log,
  twfe_deptyr = twfe_deptyr,
  twfe_all = twfe_all,
  es_level = es_level,
  es_log = es_log,
  es_deptyr = es_deptyr,
  twfe_periods = twfe_periods,
  twfe_placebo = twfe_placebo,
  cs_out = cs_out
)

saveRDS(results, file.path(DATA, "main_results.rds"))
cat("Results saved to main_results.rds\n")

cat("\nMain analysis complete.\n")
