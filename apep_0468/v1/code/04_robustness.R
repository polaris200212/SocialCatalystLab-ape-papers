# ==============================================================================
# 04_robustness.R — Robustness checks
# APEP-0468: Where Does Workfare Work?
# ==============================================================================

source("00_packages.R")

data_dir <- "../data"
panel <- readRDS(file.path(data_dir, "analysis_panel.rds"))

cat("=== Robustness Checks ===\n")

# Ensure balanced panel for CS-DiD operations
year_count <- panel[, .N, by = dist_id_11]
n_years <- length(unique(panel$year))
balanced_dists <- year_count[N == n_years]$dist_id_11
cat("Balanced districts:", length(balanced_dists), "of", uniqueN(panel$dist_id_11), "\n")

# ==============================================================================
# 1. Sun-Abraham (2021) Interaction-Weighted Estimator
# ==============================================================================
cat("\n=== Sun-Abraham Estimator ===\n")

# sunab() in fixest implements interaction-weighted estimator
# cohort = first_treat, period = year
sa_es <- feols(log_light ~ sunab(first_treat, year) | dist_id_11 + year,
               data = panel, cluster = ~pc01_state_id)
cat("Sun-Abraham event study:\n")
summary(sa_es)

saveRDS(sa_es, file.path(data_dir, "sa_results.rds"))

# ==============================================================================
# 2. Bacon Decomposition
# ==============================================================================
cat("\n=== Bacon Decomposition ===\n")

# Need balanced panel for bacon decomposition
# Create a simple binary treatment indicator
bacon_data <- copy(panel)
bacon_data[, treat_bin := as.integer(year >= first_treat)]

# Bacon decomposition requires specific format
# Use the formula interface: outcome ~ treatment
tryCatch({
  bd <- bacon(log_light ~ treat_bin,
              data = as.data.frame(bacon_data[, .(log_light, treat_bin,
                                                   dist_id_11, year)]),
              id_var = "dist_id_11",
              time_var = "year")

  cat("Bacon decomposition weights:\n")
  print(bd)

  if (is.data.frame(bd)) {
    bacon_summary <- aggregate(cbind(weight, estimate) ~ type, data = bd, FUN = sum)
    cat("\nWeights by comparison type:\n")
    print(bacon_summary)
  }

  saveRDS(bd, file.path(data_dir, "bacon_decomp.rds"))
}, error = function(e) {
  cat("Bacon decomposition failed:", e$message, "\n")
  cat("Skipping (not critical for paper).\n")
  saveRDS(NULL, file.path(data_dir, "bacon_decomp.rds"))
})

# ==============================================================================
# 3. State × Year Fixed Effects
# ==============================================================================
cat("\n=== State × Year FE ===\n")

# This absorbs all state-level time-varying confounds
# (state agricultural policy, rainfall shocks correlated within state, etc.)
twfe_sxy <- feols(log_light ~ treated | dist_id_11 + state^year,
                  data = panel, cluster = ~pc01_state_id)
cat("TWFE with state × year FE:\n")
summary(twfe_sxy)

# Event study with state × year FE
twfe_sxy_es <- feols(log_light ~ i(event_time, ref = -1) |
                       dist_id_11 + state^year,
                     data = panel[event_time >= -6 & event_time <= 6],
                     cluster = ~pc01_state_id)
cat("\nTWFE Event Study with state × year FE:\n")
summary(twfe_sxy_es)

saveRDS(list(base = twfe_sxy, es = twfe_sxy_es),
        file.path(data_dir, "sxy_results.rds"))

# ==============================================================================
# 4. Alternative Outcomes
# ==============================================================================
cat("\n=== Alternative Outcomes ===\n")

# Mean light (not total)
cs_mean <- tryCatch({
  sub <- copy(panel)
  sub[, id := as.integer(as.factor(dist_id_11))]
  out <- att_gt(
    yname = "log_mean_light", tname = "year", idname = "id",
    gname = "first_treat", data = as.data.frame(sub),
    control_group = "notyettreated", anticipation = 0,
    est_method = "dr", base_period = "universal",
    clustervars = "id", print_details = FALSE
  )
  agg <- aggte(out, type = "simple")
  cat(sprintf("CS-DiD (log mean light): ATT = %.4f (SE = %.4f)\n",
              agg$overall.att, agg$overall.se))
  list(gt = out, agg = agg)
}, error = function(e) {
  cat("CS-DiD mean light failed:", e$message, "\n")
  NULL
})

# Light per capita
cs_pc <- tryCatch({
  sub <- copy(panel)
  sub[, id := as.integer(as.factor(dist_id_11))]
  out <- att_gt(
    yname = "light_pc", tname = "year", idname = "id",
    gname = "first_treat", data = as.data.frame(sub),
    control_group = "notyettreated", anticipation = 0,
    est_method = "dr", base_period = "universal",
    clustervars = "id", print_details = FALSE
  )
  agg <- aggte(out, type = "simple")
  cat(sprintf("CS-DiD (light per capita): ATT = %.4f (SE = %.4f)\n",
              agg$overall.att, agg$overall.se))
  list(gt = out, agg = agg)
}, error = function(e) {
  cat("CS-DiD light/capita failed:", e$message, "\n")
  NULL
})

saveRDS(list(mean = cs_mean, pc = cs_pc),
        file.path(data_dir, "alt_outcome_results.rds"))

# ==============================================================================
# 5. HonestDiD Sensitivity (Rambachan-Roth 2023)
# ==============================================================================
cat("\n=== HonestDiD Sensitivity ===\n")

# Use TWFE event study for HonestDiD (requires fixest object)
twfe_es <- readRDS(file.path(data_dir, "twfe_results.rds"))$es

tryCatch({
  # Extract beta and variance-covariance
  betahat <- coef(twfe_es)
  sigma <- vcov(twfe_es)

  # Identify pre and post coefficients
  # fixest i() names: event_time::-6, event_time::-5, ..., event_time::0, ..., event_time::6
  coef_names <- names(betahat)
  pre_idx <- grep("event_time::-[0-9]", coef_names)
  post_idx <- grep("event_time::[0-9]", coef_names)

  if (length(pre_idx) > 0 && length(post_idx) > 0) {
    # Number of pre-treatment periods
    l_vec <- seq(0, max(abs(as.numeric(gsub(".*::(-?[0-9]+)", "\\1",
                                             coef_names[pre_idx])))), by = 0.5)

    # Relative magnitudes approach
    honest_rm <- HonestDiD::createSensitivityResults_relativeMagnitudes(
      betahat = betahat,
      sigma = sigma,
      numPrePeriods = length(pre_idx),
      numPostPeriods = length(post_idx),
      Mbarvec = seq(0, 2, by = 0.5)
    )

    cat("HonestDiD Relative Magnitudes sensitivity:\n")
    print(honest_rm)

    saveRDS(honest_rm, file.path(data_dir, "honestdid_results.rds"))
  } else {
    cat("Could not identify pre/post coefficients for HonestDiD\n")
  }
}, error = function(e) {
  cat("HonestDiD failed:", e$message, "\n")
})

# ==============================================================================
# 6. District-level clustering (more conservative)
# ==============================================================================
cat("\n=== Alternative Clustering ===\n")

twfe_dist_cluster <- feols(log_light ~ treated | dist_id_11 + year,
                           data = panel, cluster = ~dist_id_11)
cat("TWFE (district-clustered):\n")
summary(twfe_dist_cluster)

# ==============================================================================
# 7. Placebo: pre-treatment outcome trends
# ==============================================================================
cat("\n=== Placebo Tests ===\n")

# Restrict to pre-treatment period only (2000-2005)
# Placebo: assign fake staggered treatment mimicking MGNREGA timing but 3 years earlier
# Phase I fake treat: 2004, Phase II: 2005, Phase III: never (comparison)
pre_panel <- panel[year <= 2005]
pre_panel[, fake_treat := fifelse(mgnrega_phase == 1, as.integer(year >= 2004),
                            fifelse(mgnrega_phase == 2, as.integer(year >= 2005), 0L))]

placebo_twfe <- feols(log_light ~ fake_treat | dist_id_11 + year,
                      data = pre_panel, cluster = ~pc01_state_id)
cat("Placebo TWFE (fake staggered treatment, pre-period only):\n")
summary(placebo_twfe)

# Phase-specific placebo
pre_panel[, fake_treated_p1 := as.integer(year >= 2004 & mgnrega_phase == 1)]
pre_panel[, fake_treated_p2 := as.integer(year >= 2005 & mgnrega_phase == 2)]
placebo_phase <- feols(log_light ~ fake_treated_p1 + fake_treated_p2 |
                         dist_id_11 + year,
                       data = pre_panel, cluster = ~pc01_state_id)
cat("\nPlacebo by phase:\n")
summary(placebo_phase)

saveRDS(list(placebo = placebo_twfe, placebo_phase = placebo_phase,
             dist_cluster = twfe_dist_cluster),
        file.path(data_dir, "robustness_misc.rds"))

# ==============================================================================
# 8. Dose-response: years of exposure
# ==============================================================================
cat("\n=== Dose-Response ===\n")

# Years since treatment (continuous intensity)
panel[, years_exposed := pmax(0, year - first_treat + 1)]

dose_resp <- feols(log_light ~ years_exposed | dist_id_11 + year,
                   data = panel, cluster = ~pc01_state_id)
cat("Dose-response (years of exposure):\n")
summary(dose_resp)

# Quadratic
dose_resp2 <- feols(log_light ~ years_exposed + I(years_exposed^2) |
                      dist_id_11 + year,
                    data = panel, cluster = ~pc01_state_id)
cat("\nDose-response (quadratic):\n")
summary(dose_resp2)

saveRDS(list(linear = dose_resp, quad = dose_resp2),
        file.path(data_dir, "dose_response.rds"))

# ==============================================================================
# 9. Within-Tercile Pre-Trend Diagnostics (Event Studies)
# ==============================================================================
cat("\n=== Within-Tercile Event Studies ===\n")

tercile_es_results <- list()
for (dim_var in c("rain_tercile", "ag_labor_tercile")) {
  for (lev in levels(panel[[dim_var]])) {
    sub <- panel[get(dim_var) == lev & event_time >= -6 & event_time <= 6]
    if (nrow(sub) > 200) {
      es <- tryCatch(
        feols(log_light ~ i(event_time, ref = -1) | dist_id_11 + year,
              data = sub, cluster = ~dist_id_11),
        error = function(e) NULL
      )
      if (!is.null(es)) {
        coefs <- coef(es)
        ses <- se(es)
        pre_names <- grep("event_time::-[2-6]", names(coefs), value = TRUE)
        pre_coefs <- coefs[pre_names]
        pre_ses <- ses[pre_names]
        # Joint pre-trend F-test
        pre_f_p <- tryCatch({
          wt <- wald(es, pre_names)
          if (is.list(wt) && !is.null(wt$p)) wt$p else
          if (is.data.frame(wt)) wt$p[1] else NA
        }, error = function(e) NA_real_)
        tercile_es_results[[paste0(dim_var, "_", lev)]] <- list(
          dimension = dim_var, level = lev,
          pre_coefs = pre_coefs, pre_ses = pre_ses,
          pre_f_p = pre_f_p
        )
        cat(sprintf("  %s=%s: max|pre-coef|=%.4f, pre-trend p=%s\n",
                    dim_var, lev,
                    max(abs(pre_coefs), na.rm = TRUE),
                    if (!is.na(pre_f_p)) sprintf("%.4f", pre_f_p) else "NA"))
      }
    }
  }
}

saveRDS(tercile_es_results, file.path(data_dir, "tercile_event_studies.rds"))

# ==============================================================================
# 10. Joint Heterogeneity Test (Interaction Model)
# ==============================================================================
cat("\n=== Joint Heterogeneity Test ===\n")

# Interaction of treated × ag_labor_tercile
het_joint <- feols(log_light ~ treated * ag_labor_tercile | dist_id_11 + year,
                   data = panel, cluster = ~dist_id_11)
cat("Joint het test (ag labor interaction):\n")
summary(het_joint)

# F-test for interaction terms
het_f_p <- tryCatch({
  int_names <- grep("treated:ag_labor_tercile", names(coef(het_joint)), value = TRUE)
  wt <- wald(het_joint, int_names)
  if (is.list(wt) && !is.null(wt$p)) wt$p else
  if (is.data.frame(wt)) wt$p[1] else NA
}, error = function(e) NA_real_)
cat(sprintf("F-test for het: p=%s\n",
            if (!is.na(het_f_p)) sprintf("%.4f", het_f_p) else "NA"))

saveRDS(list(model = het_joint, f_test_p = het_f_p),
        file.path(data_dir, "het_joint_test.rds"))

# ==============================================================================
# 11. Uniform District Clustering for TWFE
# ==============================================================================
cat("\n=== Uniform Clustering (District) ===\n")

twfe_base <- readRDS(file.path(data_dir, "twfe_results.rds"))

# Re-cluster TWFE at district level
twfe_dist <- feols(log_light ~ treated | dist_id_11 + year,
                   data = panel, cluster = ~dist_id_11)
twfe_rain_dist <- feols(log_light ~ treated + avg_rainfall | dist_id_11 + year,
                        data = panel, cluster = ~dist_id_11)
cat("TWFE (district-clustered): coef=", round(coef(twfe_dist)["treated"], 4),
    " SE=", round(se(twfe_dist)["treated"], 4), "\n")

saveRDS(list(base_dist = twfe_dist, rain_dist = twfe_rain_dist),
        file.path(data_dir, "twfe_district_cluster.rds"))

cat("\n=== All Robustness Checks Complete ===\n")
