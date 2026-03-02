##############################################################################
# 03_main_analysis.R — Primary Regressions
# Virtual Snow Days and the Weather-Absence Penalty for Working Parents
##############################################################################

source("code/00_packages.R")

cat("=== STEP 3: MAIN ANALYSIS ===\n\n")

##############################################################################
# Load cleaned data
##############################################################################

winter_panel <- readRDS("data/winter_panel.rds")
policy_data <- readRDS("data/policy_data.rds")

# Ensure first_treat is properly coded (0 = never treated for CS-DiD)
winter_panel <- winter_panel %>%
  mutate(
    first_treat = ifelse(is.na(adopt_year) | adopt_year == 0, 0L,
                         as.integer(adopt_year) + 1L),
    state_id = as.integer(factor(state_fips))
  )

cat(sprintf("Panel: %d obs, %d states, winters %d-%d\n",
            nrow(winter_panel),
            n_distinct(winter_panel$state_fips),
            min(winter_panel$winter_season),
            max(winter_panel$winter_season)))

##############################################################################
# A) Treatment Rollout Diagnostics
##############################################################################

cat("\n--- A. Treatment Rollout ---\n")

# Cohort sizes
cohort_sizes <- winter_panel %>%
  distinct(state_fips, first_treat) %>%
  count(first_treat, name = "n_states") %>%
  arrange(first_treat)

cat("Treatment cohorts:\n")
print(cohort_sizes)

saveRDS(cohort_sizes, "data/cohort_sizes.rds")

##############################################################################
# B) TWFE Baseline (Diagnostic — known to be biased with staggered adoption)
##############################################################################

cat("\n--- B. TWFE Baseline ---\n")

# Model 1: Simple TWFE
m1_twfe <- feols(
  weather_absence_proxy ~ treated | state_fips + winter_season,
  data = winter_panel,
  cluster = ~state_fips
)

cat("TWFE (simple):\n")
summary(m1_twfe)

# Model 2: TWFE with storm interaction
m2_twfe_storm <- feols(
  weather_absence_proxy ~ treated + total_winter_events +
    treated:total_winter_events | state_fips + winter_season,
  data = winter_panel,
  cluster = ~state_fips
)

cat("\nTWFE with storm interaction:\n")
summary(m2_twfe_storm)

# Model 3: TWFE with controls (parent employment + storms)
# Note: mean_winter_temp may be NA if NOAA climate fetch failed
has_temp <- sum(!is.na(winter_panel$mean_winter_temp)) > 50

if (has_temp) {
  m3_twfe_ctrl <- feols(
    weather_absence_proxy ~ treated + total_winter_events +
      treated:total_winter_events + mean_winter_temp |
      state_fips + winter_season,
    data = winter_panel,
    cluster = ~state_fips
  )
} else {
  # Use parent employment rate as additional control instead
  m3_twfe_ctrl <- feols(
    weather_absence_proxy ~ treated + total_winter_events +
      treated:total_winter_events + parent_emp_rate |
      state_fips + winter_season,
    data = winter_panel %>% filter(!is.na(parent_emp_rate)),
    cluster = ~state_fips
  )
}

cat("\nTWFE with controls:\n")
summary(m3_twfe_ctrl)

saveRDS(list(m1 = m1_twfe, m2 = m2_twfe_storm, m3 = m3_twfe_ctrl),
        "data/twfe_results.rds")

##############################################################################
# C) Goodman-Bacon Decomposition
##############################################################################

cat("\n--- C. Bacon Decomposition ---\n")

# Need balanced panel for bacon decomposition
tryCatch({
  # Create balanced panel
  balanced <- winter_panel %>%
    group_by(state_fips) %>%
    filter(n() == max(n_distinct(winter_panel$winter_season))) %>%
    ungroup()

  if (nrow(balanced) > 0) {
    bacon_out <- bacon(
      weather_absence_proxy ~ treated,
      data = as.data.frame(balanced),
      id_var = "state_fips",
      time_var = "winter_season"
    )

    cat("Bacon decomposition:\n")
    print(summary(bacon_out))
    saveRDS(bacon_out, "data/bacon_decomp.rds")
  }
}, error = function(e) {
  cat(sprintf("  Bacon decomposition skipped: %s\n", e$message))
})

##############################################################################
# D) Callaway-Sant'Anna (Primary Specification)
##############################################################################

cat("\n--- D. Callaway-Sant'Anna ---\n")

# CS-DiD with never-treated as control group
tryCatch({
  cs_out <- att_gt(
    yname = "weather_absence_proxy",
    tname = "winter_season",
    idname = "state_fips",
    gname = "first_treat",
    data = winter_panel %>% filter(!is.na(weather_absence_proxy)),
    control_group = "nevertreated",
    anticipation = 0,
    est_method = "dr",
    base_period = "varying"
  )

  cat("CS ATT(g,t) results:\n")
  summary(cs_out)

  # Overall ATT
  cs_overall <- aggte(cs_out, type = "simple")
  cat(sprintf("\nOverall ATT: %.6f (SE: %.6f, p: %.4f)\n",
              cs_overall$overall.att,
              cs_overall$overall.se,
              2 * pnorm(-abs(cs_overall$overall.att / cs_overall$overall.se))))

  # Dynamic (event study) aggregation
  cs_dynamic <- aggte(cs_out, type = "dynamic", min_e = -6, max_e = 8)
  cat("\nDynamic ATT:\n")
  summary(cs_dynamic)

  # Calendar time aggregation
  cs_calendar <- aggte(cs_out, type = "calendar")
  cat("\nCalendar time ATT:\n")
  summary(cs_calendar)

  # Group (cohort) aggregation
  cs_group <- aggte(cs_out, type = "group")
  cat("\nGroup ATT:\n")
  summary(cs_group)

  saveRDS(list(
    att_gt = cs_out,
    overall = cs_overall,
    dynamic = cs_dynamic,
    calendar = cs_calendar,
    group = cs_group
  ), "data/cs_results.rds")

}, error = function(e) {
  cat(sprintf("  CS estimation failed: %s\n", e$message))
  cat("  Falling back to Sun-Abraham via fixest.\n")

  # Sun-Abraham fallback
  sa_out <- feols(
    weather_absence_proxy ~ sunab(first_treat, winter_season) |
      state_fips + winter_season,
    data = winter_panel %>% filter(!is.na(weather_absence_proxy)),
    cluster = ~state_fips
  )
  cat("Sun-Abraham results:\n")
  summary(sa_out)
  saveRDS(sa_out, "data/sa_results.rds")
})

##############################################################################
# E) Pre-COVID Subsample (Clean Identification)
##############################################################################

cat("\n--- E. Pre-COVID Subsample (2006-2019) ---\n")

winter_precovid <- winter_panel %>%
  filter(winter_season <= 2019) %>%
  # Only keep pre-COVID adopters and never-treated
  filter(first_treat == 0 | first_treat <= 2020)

cat(sprintf("Pre-COVID panel: %d obs, %d states\n",
            nrow(winter_precovid),
            n_distinct(winter_precovid$state_fips)))

# TWFE on pre-COVID
m_precovid <- feols(
  weather_absence_proxy ~ treated + total_winter_events +
    treated:total_winter_events | state_fips + winter_season,
  data = winter_precovid,
  cluster = ~state_fips
)

cat("Pre-COVID TWFE:\n")
summary(m_precovid)

# CS-DiD on pre-COVID
tryCatch({
  cs_precovid <- att_gt(
    yname = "weather_absence_proxy",
    tname = "winter_season",
    idname = "state_fips",
    gname = "first_treat",
    data = winter_precovid %>% filter(!is.na(weather_absence_proxy)),
    control_group = "nevertreated",
    anticipation = 0,
    est_method = "dr"
  )

  cs_precovid_overall <- aggte(cs_precovid, type = "simple")
  cat(sprintf("\nPre-COVID CS ATT: %.6f (SE: %.6f)\n",
              cs_precovid_overall$overall.att,
              cs_precovid_overall$overall.se))

  saveRDS(list(twfe = m_precovid, cs = cs_precovid,
               cs_overall = cs_precovid_overall),
          "data/precovid_results.rds")

}, error = function(e) {
  cat(sprintf("  Pre-COVID CS failed: %s\n", e$message))
  saveRDS(list(twfe = m_precovid), "data/precovid_results.rds")
})

##############################################################################
# F) Storm Interaction (DDD-style)
##############################################################################

cat("\n--- F. Storm Interaction Analysis ---\n")

# High-storm vs low-storm heterogeneity
winter_panel <- winter_panel %>%
  group_by(state_fips) %>%
  mutate(
    state_mean_storms = mean(total_winter_events, na.rm = TRUE),
    storm_deviation = total_winter_events - state_mean_storms,
    high_storm_winter = total_winter_events > median(total_winter_events, na.rm = TRUE)
  ) %>%
  ungroup()

# Interaction model
m_storm_interact <- feols(
  weather_absence_proxy ~ treated * high_storm_winter |
    state_fips + winter_season,
  data = winter_panel %>% filter(!is.na(weather_absence_proxy)),
  cluster = ~state_fips
)

cat("Storm interaction model:\n")
summary(m_storm_interact)

# Continuous storm intensity
m_storm_continuous <- feols(
  weather_absence_proxy ~ treated * storm_deviation |
    state_fips + winter_season,
  data = winter_panel %>% filter(!is.na(weather_absence_proxy)),
  cluster = ~state_fips
)

cat("\nContinuous storm interaction:\n")
summary(m_storm_continuous)

saveRDS(list(binary = m_storm_interact, continuous = m_storm_continuous),
        "data/storm_interaction_results.rds")

##############################################################################
# G) Summary of Main Results
##############################################################################

cat("\n\n=== MAIN RESULTS SUMMARY ===\n\n")

results_summary <- data.frame(
  Model = c("TWFE (simple)", "TWFE + storms", "TWFE + controls",
            "Pre-COVID TWFE"),
  Estimate = c(coef(m1_twfe)["treatedTRUE"],
               coef(m2_twfe_storm)["treatedTRUE"],
               coef(m3_twfe_ctrl)["treatedTRUE"],
               coef(m_precovid)["treatedTRUE"]),
  SE = c(se(m1_twfe)["treatedTRUE"],
         se(m2_twfe_storm)["treatedTRUE"],
         se(m3_twfe_ctrl)["treatedTRUE"],
         se(m_precovid)["treatedTRUE"])
)
results_summary$p_value <- 2 * pnorm(-abs(results_summary$Estimate / results_summary$SE))
results_summary$sig <- ifelse(results_summary$p_value < 0.01, "***",
                              ifelse(results_summary$p_value < 0.05, "**",
                                     ifelse(results_summary$p_value < 0.1, "*", "")))

cat("Main regression results:\n")
print(results_summary, digits = 6)

saveRDS(results_summary, "data/results_summary.rds")

cat("\n=== MAIN ANALYSIS COMPLETE ===\n")
