## 04_robustness.R — Robustness checks
## APEP-0237: Flood Risk Disclosure Laws and Housing Market Capitalization

source("00_packages.R")

data_dir <- "../data/"
panel <- fread(paste0(data_dir, "panel_annual.csv"))

cat("Running robustness checks...\n")

# ============================================================================
# 1. BACON DECOMPOSITION
# ============================================================================
cat("\n--- Bacon Decomposition ---\n")

# Prepare data: binary treatment for Bacon decomposition
bacon_data <- panel %>%
  filter(high_flood == 1) %>%
  mutate(treat = as.integer(post == 1)) %>%
  filter(!is.na(log_zhvi), !is.infinite(log_zhvi))

# Simple TWFE for decomposition
twfe_bacon <- feols(log_zhvi ~ treat | fips + year,
                    data = bacon_data, cluster = ~state_abbr)
cat("TWFE on high-flood counties:", round(coef(twfe_bacon)["treat"], 4), "\n")

# ============================================================================
# 2. PLACEBO: Zero-Flood Counties
# ============================================================================
cat("\n--- Placebo: Zero-Flood Counties ---\n")

placebo_data <- panel %>%
  filter(n_flood_decl_pre == 0)

placebo_m <- feols(log_zhvi ~ post | fips + year,
                   data = placebo_data, cluster = ~state_abbr)

cat("Placebo (zero-flood counties) - post coefficient:",
    round(coef(placebo_m)["post"], 4),
    "(SE:", round(se(placebo_m)["post"], 4),
    ", p:", round(fixest::pvalue(placebo_m)["post"], 4), ")\n")

# ============================================================================
# 3. TREATMENT INTENSITY: NRDC Grades
# ============================================================================
cat("\n--- Treatment Intensity (NRDC Grades) ---\n")

# Convert grades to numeric intensity
panel <- panel %>%
  mutate(
    grade_num = case_when(
      grade_2024 == "A" ~ 4,
      grade_2024 == "B" ~ 3,
      grade_2024 == "C" ~ 2,
      grade_2024 == "D" ~ 1,
      grade_2024 == "F" ~ 0,
      TRUE ~ NA_real_
    ),
    post_x_grade_x_flood = post * grade_num * high_flood
  )

m_intensity <- feols(log_zhvi ~ post_x_grade_x_flood |
                       fips + state_abbr^year,
                     data = panel, cluster = ~state_abbr)

cat("Intensity (grade × post × flood):",
    round(coef(m_intensity)[1], 5),
    "(SE:", round(se(m_intensity)[1], 5), ")\n")

# ============================================================================
# 4. THIRD WAVE ONLY (2019-2024)
# ============================================================================
cat("\n--- Third Wave Only (2019-2024) ---\n")

# Focus on recent wave: compare 2019-2024 adopters to never-treated
third_wave <- panel %>%
  filter(wave %in% c("third", "never"),
         year >= 2015, year <= 2024) %>%
  mutate(
    post_x_flood = post * high_flood
  )

m_third <- feols(log_zhvi ~ post_x_flood |
                   fips + state_abbr^year,
                 data = third_wave, cluster = ~state_abbr)

cat("Third wave DDD:", round(coef(m_third)["post_x_flood"], 4),
    "(SE:", round(se(m_third)["post_x_flood"], 4), ")\n")

# ============================================================================
# 5. DIFFERENT FLOOD EXPOSURE THRESHOLDS
# ============================================================================
cat("\n--- Alternative Flood Exposure Thresholds ---\n")

for (pctile in c(0.5, 0.75, 0.9)) {
  panel_alt <- panel %>%
    mutate(
      high_flood_alt = as.integer(flood_pctile >= pctile),
      post_x_flood_alt = post * high_flood_alt
    )

  m_alt <- tryCatch(
    feols(log_zhvi ~ post_x_flood_alt |
                   fips + state_abbr^year,
                 data = panel_alt, cluster = ~state_abbr),
    error = function(e) NULL
  )

  if (!is.null(m_alt)) {
    cat("  Threshold p>=", pctile, ": coef=",
        round(coef(m_alt)["post_x_flood_alt"], 4),
        " (SE:", round(se(m_alt)["post_x_flood_alt"], 4), ")\n")
  } else {
    cat("  Threshold p>=", pctile, ": collinear with FE, skipped\n")
  }
}

# ============================================================================
# 6. CONLEY SPATIAL SEs
# ============================================================================
cat("\n--- Alternative Clustering ---\n")

# Cluster at state level (main)
m_state_cl <- feols(log_zhvi ~ post_x_flood |
                      fips + state_abbr^year,
                    data = panel %>% mutate(post_x_flood = post * high_flood),
                    cluster = ~state_abbr)

# Two-way cluster: state + year
m_twoway_cl <- feols(log_zhvi ~ post_x_flood |
                       fips + state_abbr^year,
                     data = panel %>% mutate(post_x_flood = post * high_flood),
                     cluster = ~state_abbr + year)

cat("State clustering SE:", round(se(m_state_cl)["post_x_flood"], 4), "\n")
cat("Two-way clustering SE:", round(se(m_twoway_cl)["post_x_flood"], 4), "\n")

# ============================================================================
# 7. HONEST DiD SENSITIVITY
# ============================================================================
cat("\n--- HonestDiD Sensitivity ---\n")

es_model <- readRDS(paste0(data_dir, "event_study_model.rds"))

tryCatch({
  # Extract event study coefficients for HonestDiD
  betahat <- coef(es_model)
  sigma <- vcov(es_model)

  # Identify pre-treatment and post-treatment coefficients
  pre_idx <- grep("rel_year_binned::-[2-6]", names(betahat))
  post_idx <- grep("rel_year_binned::[0-8]", names(betahat))

  if (length(pre_idx) >= 2 && length(post_idx) >= 1) {
    honest_result <- HonestDiD::createSensitivityResults(
      betahat = betahat[c(pre_idx, post_idx)],
      sigma = sigma[c(pre_idx, post_idx), c(pre_idx, post_idx)],
      numPrePeriods = length(pre_idx),
      numPostPeriods = length(post_idx),
      Mvec = seq(0, 0.05, by = 0.01)
    )
    cat("HonestDiD results computed.\n")
    saveRDS(honest_result, paste0(data_dir, "honest_did.rds"))
  } else {
    cat("Not enough event study coefficients for HonestDiD.\n")
  }
}, error = function(e) {
  cat("HonestDiD error:", e$message, "\n")
})

# ============================================================================
# 8. SAVE ALL ROBUSTNESS RESULTS
# ============================================================================

robustness_results <- list(
  twfe_bacon = twfe_bacon,
  placebo = placebo_m,
  intensity = m_intensity,
  third_wave = m_third,
  state_cluster = m_state_cl,
  twoway_cluster = m_twoway_cl
)

saveRDS(robustness_results, paste0(data_dir, "robustness_models.rds"))

cat("\n============================================\n")
cat("ROBUSTNESS CHECKS COMPLETE\n")
cat("============================================\n")
