##############################################################################
# 04_robustness.R — Robustness checks and sensitivity analysis
# apep_0480: FOBT Stake Cut and Local Effects
##############################################################################

source("00_packages.R")

data_dir <- "../data"

panel <- fread(file.path(data_dir, "analysis_panel.csv"))
cat("Panel loaded:", nrow(panel), "rows,", uniqueN(panel$csp_name), "CSPs\n")

results <- readRDS(file.path(data_dir, "main_results.rds"))

# ============================================================================
# 1. ALTERNATIVE TREATMENT DEFINITIONS
# ============================================================================
cat("\n=== Robustness: Alternative Treatment Definitions ===\n")

# Terciles instead of median split
panel[, density_tercile := cut(betting_density,
                               breaks = quantile(betting_density[!duplicated(csp_name)],
                                                 probs = c(0, 1/3, 2/3, 1), na.rm = TRUE),
                               labels = c("Low", "Medium", "High"),
                               include.lowest = TRUE)]

# Top vs bottom tercile only
panel_t13 <- panel[density_tercile %in% c("Low", "High")]
panel_t13[, treat_t13 := as.integer(density_tercile == "High")]

r1 <- feols(total_offences_rate ~ treat_t13:post | csp_id + time_id,
            data = panel_t13, cluster = ~csp_id)
cat("\n--- R1: Top vs Bottom Tercile ---\n")
print(summary(r1))

# Quartile dummies
panel[, density_q4 := cut(betting_density,
                          breaks = quantile(betting_density[!duplicated(csp_name)],
                                            probs = seq(0, 1, 0.25), na.rm = TRUE),
                          labels = 1:4, include.lowest = TRUE)]
panel[, density_q4 := as.integer(density_q4)]

r2 <- feols(total_offences_rate ~ i(density_q4, post, ref = 1) | csp_id + time_id,
            data = panel, cluster = ~csp_id)
cat("\n--- R2: Quartile × Post Interactions ---\n")
print(summary(r2))

# ============================================================================
# 2. CONTROLLING FOR COVID
# ============================================================================
cat("\n=== Robustness: COVID Controls ===\n")

# COVID lockdowns (March 2020 - June 2021) may confound
# Strategy 1: Drop COVID period entirely
panel_no_covid <- panel[!(yq >= 2020.0 & yq <= 2021.5)]
r3 <- feols(total_offences_rate ~ betting_density:post | csp_id + time_id,
            data = panel_no_covid, cluster = ~csp_id)
cat("\n--- R3: Excluding COVID Period (2020Q1-2021Q2) ---\n")
print(summary(r3))

# Strategy 2: Include COVID × density interaction
panel[, covid_period := as.integer(yq >= 2020.0 & yq <= 2021.5)]
r4 <- feols(total_offences_rate ~ betting_density:post + betting_density:covid_period |
              csp_id + time_id, data = panel, cluster = ~csp_id)
cat("\n--- R4: COVID × Density Interaction ---\n")
print(summary(r4))

# ============================================================================
# 3. PLACEBO TESTS
# ============================================================================
cat("\n=== Placebo Tests ===\n")

# Placebo 1: Drug offences (not related to betting shops)
if ("drug_offences_rate" %in% names(panel)) {
  p1 <- feols(drug_offences_rate ~ betting_density:post | csp_id + time_id,
              data = panel, cluster = ~csp_id)
  cat("\n--- Placebo 1: Drug Offences ---\n")
  print(summary(p1))
}

# Placebo 2: Sexual offences (not related to betting shops)
if ("sexual_offences_rate" %in% names(panel)) {
  p2 <- feols(sexual_offences_rate ~ betting_density:post | csp_id + time_id,
              data = panel, cluster = ~csp_id)
  cat("\n--- Placebo 2: Sexual Offences ---\n")
  print(summary(p2))
}

# Placebo 3: Fake treatment date (2017Q2 instead of 2019Q2)
panel[, fake_post := as.integer(yq >= 2017.25)]
# Only use pre-policy data for this test
panel_pre <- panel[yq < 2019.25]
p3 <- feols(total_offences_rate ~ betting_density:fake_post | csp_id + time_id,
            data = panel_pre, cluster = ~csp_id)
cat("\n--- Placebo 3: Fake Treatment Date (2017Q2) ---\n")
print(summary(p3))

# ============================================================================
# 4. ALTERNATIVE STANDARD ERRORS
# ============================================================================
cat("\n=== Alternative Standard Errors ===\n")

# Conley spatial HAC (if we had coordinates), otherwise use:
# Wild cluster bootstrap (for small number of clusters per group)
r5_hetero <- feols(total_offences_rate ~ betting_density:post | csp_id + time_id,
                   data = panel, vcov = "hetero")
cat("\n--- R5: Heteroskedasticity-robust SE ---\n")
print(summary(r5_hetero))

# Two-way clustering (CSP × time)
r5_twoway <- feols(total_offences_rate ~ betting_density:post | csp_id + time_id,
                   data = panel, cluster = ~csp_id + time_id)
cat("\n--- R5b: Two-way Clustered SE ---\n")
print(summary(r5_twoway))

# ============================================================================
# 5. DOSE-RESPONSE ANALYSIS
# ============================================================================
cat("\n=== Dose-Response ===\n")

# Non-parametric: quintile-specific effects
panel[, density_q5 := cut(betting_density,
                          breaks = quantile(betting_density[!duplicated(csp_name)],
                                            probs = seq(0, 1, 0.2), na.rm = TRUE),
                          labels = 1:5, include.lowest = TRUE)]
panel[, density_q5 := as.integer(density_q5)]

r6 <- feols(total_offences_rate ~ i(density_q5, post, ref = 1) | csp_id + time_id,
            data = panel, cluster = ~csp_id)
cat("\n--- R6: Quintile Dose-Response ---\n")
print(summary(r6))

# ============================================================================
# 6. HONESTDID SENSITIVITY (Rambachan & Roth 2023)
# ============================================================================
cat("\n=== HonestDiD Sensitivity Analysis ===\n")

# Run event study for HonestDiD
panel_es <- panel[event_time >= -16 & event_time <= 20]
es_model <- feols(total_offences_rate ~ i(event_time, betting_density, ref = -1) |
                    csp_id + time_id,
                  data = panel_es, cluster = ~csp_id)

tryCatch({
  # Extract coefficients and variance-covariance matrix
  es_coefs_vec <- coef(es_model)
  es_vcov <- vcov(es_model)

  # Identify pre-treatment and post-treatment coefficient indices
  coef_names <- names(es_coefs_vec)
  pre_idx <- grep("event_time::-", coef_names)
  post_idx <- grep("event_time::[0-9]", coef_names)

  if (length(pre_idx) >= 2 && length(post_idx) >= 1) {
    # HonestDiD: relative magnitudes restriction
    honest_result <- HonestDiD::createSensitivityResults(
      betahat = es_coefs_vec,
      sigma = es_vcov,
      numPrePeriods = length(pre_idx),
      numPostPeriods = length(post_idx),
      Mvec = seq(0, 2, by = 0.5)
    )

    cat("\nHonestDiD Sensitivity (Relative Magnitudes):\n")
    print(honest_result)

    results$honest_did <- honest_result
  } else {
    cat("Insufficient pre/post coefficients for HonestDiD\n")
  }
}, error = function(e) {
  cat("HonestDiD error:", conditionMessage(e), "\n")
})

# ============================================================================
# 7. SAVE ALL ROBUSTNESS RESULTS
# ============================================================================
cat("\n=== Saving Robustness Results ===\n")

rob_results <- list(
  r_tercile = r1,
  r_quartile = r2,
  r_no_covid = r3,
  r_covid_interact = r4,
  r_hetero_se = r5_hetero,
  r_twoway_se = r5_twoway,
  r_dose_response = r6
)
if (exists("p1")) rob_results$placebo_drug <- p1
if (exists("p2")) rob_results$placebo_sexual <- p2
rob_results$placebo_fake_date <- p3

saveRDS(rob_results, file.path(data_dir, "robustness_results.rds"))
cat("Robustness results saved.\n")
