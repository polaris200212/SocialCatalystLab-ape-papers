# =============================================================================
# 03_main_analysis.R - Primary Regressions
# APEP-0265: Felon Voting Rights Restoration and Black Political Participation
# =============================================================================

source("00_packages.R")

data_dir <- "../data"

# Load analysis data
cell_data <- readRDS(file.path(data_dir, "analysis_cells.rds"))
ddd_data <- readRDS(file.path(data_dir, "ddd_panel.rds"))
cps_micro <- readRDS(file.path(data_dir, "cps_clean_micro.rds"))

# =============================================================================
# A. TREATMENT ROLLOUT DIAGNOSTICS
# =============================================================================

cat("\n=== A. Treatment Rollout ===\n")

# Document cohort sizes
reforms <- readRDS(file.path(data_dir, "reform_timing.rds"))
cohort_sizes <- reforms %>%
  count(first_election, name = "n_states") %>%
  arrange(first_election)
cat("Treatment cohort sizes:\n")
print(cohort_sizes)

# Reversal state FIPS (FL=12, IA=19)
reversal_fips <- c(12, 19)

# =============================================================================
# B. PRIMARY DD: BLACK-WHITE TURNOUT GAP
# =============================================================================

cat("\n=== B. Primary DD Specification ===\n")

# Specification:
# Turnout_{rst} = alpha + beta(Black_r x Reform_{st}) + gamma * Black_r
#                 + delta_{st} + epsilon_{rst}
#
# Where delta_{st} = state x year FE
# beta captures change in Black-White turnout gap from rights restoration

# ── B1. Full sample (exclude reversal states) ──────────────────────────────

dd_sample <- cell_data %>%
  filter(!state_fips %in% reversal_fips,
         state_group %in% c("reform", "control"))

cat(sprintf("DD sample: %d cells, %d states, %d years\n",
            nrow(dd_sample), n_distinct(dd_sample$state_fips),
            n_distinct(dd_sample$year)))

# Primary specification with state x year FE
m_dd_turnout <- feols(
  turnout ~ black_reform + black | state_fips^year,
  data = dd_sample,
  weights = ~n_obs,
  cluster = ~state_fips
)

m_dd_reg <- feols(
  registered ~ black_reform + black | state_fips^year,
  data = dd_sample,
  weights = ~n_obs,
  cluster = ~state_fips
)

cat("\n--- DD: Effect on Black-White Turnout Gap ---\n")
summary(m_dd_turnout)

cat("\n--- DD: Effect on Black-White Registration Gap ---\n")
summary(m_dd_reg)

# ── B2. Separate state and year FE (more transparent) ──────────────────────

m_dd_separate <- feols(
  turnout ~ black_reform + black + post_reform | state_fips + year,
  data = dd_sample,
  weights = ~n_obs,
  cluster = ~state_fips
)

cat("\n--- DD: Separate State + Year FE ---\n")
summary(m_dd_separate)

# ── B3. With concurrent voting law controls ────────────────────────────────

dd_controls <- dd_sample %>%
  left_join(
    readRDS(file.path(data_dir, "concurrent_voting_laws.rds")),
    by = c("state_fips", "year")
  ) %>%
  mutate(
    has_strict_voter_id = replace_na(has_strict_voter_id, 0),
    has_same_day_reg = replace_na(has_same_day_reg, 0),
    has_auto_voter_reg = replace_na(has_auto_voter_reg, 0)
  )

m_dd_controls <- feols(
  turnout ~ black_reform + black +
    has_strict_voter_id + has_same_day_reg + has_auto_voter_reg |
    state_fips^year,
  data = dd_controls,
  weights = ~n_obs,
  cluster = ~state_fips
)

cat("\n--- DD: With Concurrent Voting Law Controls ---\n")
summary(m_dd_controls)

# Save DD models
saveRDS(list(
  dd_turnout = m_dd_turnout,
  dd_reg = m_dd_reg,
  dd_separate = m_dd_separate,
  dd_controls = m_dd_controls
), file.path(data_dir, "dd_results.rds"))

# =============================================================================
# C. CALLAWAY-SANT'ANNA STAGGERED DiD
# =============================================================================

cat("\n=== C. Callaway-Sant'Anna Estimator ===\n")

# Need unit-level panel for CS estimator
# Create state-level panel with Black-White turnout GAP as outcome
gap_panel <- cell_data %>%
  filter(!state_fips %in% reversal_fips,
         state_group %in% c("reform", "control")) %>%
  select(state_fips, year, race_cat, turnout, registered, n_obs) %>%
  pivot_wider(
    names_from = race_cat,
    values_from = c(turnout, registered, n_obs),
    names_sep = "_"
  ) %>%
  mutate(
    turnout_gap = turnout_black_nh - turnout_white_nh,
    reg_gap = registered_black_nh - registered_white_nh
  ) %>%
  left_join(
    readRDS(file.path(data_dir, "reform_timing.rds")) %>%
      select(state_fips, first_election),
    by = "state_fips"
  ) %>%
  mutate(
    # CS requires: gname = first treatment period, 0 for never-treated
    first_treat = replace_na(first_election, 0)
  )

cat(sprintf("Gap panel: %d state-year cells\n", nrow(gap_panel)))
cat(sprintf("  Treated states: %d\n", sum(gap_panel$first_treat > 0) / n_distinct(gap_panel$year)))
cat(sprintf("  Never-treated states: %d\n", sum(gap_panel$first_treat == 0) / n_distinct(gap_panel$year)))

# Run CS estimator for turnout gap
tryCatch({
  set.seed(2024)
  cs_turnout <- att_gt(
    yname = "turnout_gap",
    tname = "year",
    idname = "state_fips",
    gname = "first_treat",
    data = gap_panel,
    control_group = "nevertreated",
    est_method = "dr",
    bstrap = TRUE,
    cband = TRUE,
    biters = 1000
  )

  cat("\n--- CS: Group-Time ATTs for Turnout Gap ---\n")
  summary(cs_turnout)

  # Aggregate to event time
  cs_es_turnout <- aggte(cs_turnout, type = "dynamic", min_e = -6, max_e = 6)
  cat("\n--- CS: Event Study (Dynamic) ---\n")
  summary(cs_es_turnout)

  # Overall ATT
  cs_overall_turnout <- aggte(cs_turnout, type = "simple")
  cat("\n--- CS: Overall ATT ---\n")
  summary(cs_overall_turnout)

  # By cohort
  cs_cohort_turnout <- aggte(cs_turnout, type = "group")
  cat("\n--- CS: ATT by Cohort ---\n")
  summary(cs_cohort_turnout)

  # Save CS results
  saveRDS(list(
    cs_gt = cs_turnout,
    cs_es = cs_es_turnout,
    cs_overall = cs_overall_turnout,
    cs_cohort = cs_cohort_turnout
  ), file.path(data_dir, "cs_turnout_results.rds"))

}, error = function(e) {
  cat(sprintf("CS estimator error: %s\n", e$message))
  cat("Falling back to TWFE event study...\n")

  # TWFE event study as fallback
  gap_panel_es <- gap_panel %>%
    filter(first_treat > 0 | first_treat == 0) %>%
    mutate(
      event_time = if_else(first_treat > 0, year - first_treat, NA_real_),
      # Bin event time at -6 and +6
      event_time_binned = case_when(
        is.na(event_time) ~ NA_real_,
        event_time <= -6 ~ -6,
        event_time >= 6 ~ 6,
        TRUE ~ event_time
      )
    )

  # Sun-Abraham via fixest
  m_es <- feols(
    turnout_gap ~ sunab(first_treat, year) | state_fips + year,
    data = gap_panel_es %>% filter(first_treat > 0 | first_treat == 0),
    cluster = ~state_fips
  )

  saveRDS(list(twfe_es = m_es), file.path(data_dir, "cs_turnout_results.rds"))
})

# CS for registration gap
tryCatch({
  set.seed(2025)
  cs_reg <- att_gt(
    yname = "reg_gap",
    tname = "year",
    idname = "state_fips",
    gname = "first_treat",
    data = gap_panel,
    control_group = "nevertreated",
    est_method = "dr",
    bstrap = TRUE,
    cband = TRUE,
    biters = 1000
  )

  cs_es_reg <- aggte(cs_reg, type = "dynamic", min_e = -6, max_e = 6)
  cs_overall_reg <- aggte(cs_reg, type = "simple")

  saveRDS(list(
    cs_gt = cs_reg,
    cs_es = cs_es_reg,
    cs_overall = cs_overall_reg
  ), file.path(data_dir, "cs_reg_results.rds"))

  cat("\n--- CS: Registration Gap Overall ATT ---\n")
  summary(cs_overall_reg)

}, error = function(e) {
  cat(sprintf("CS registration error: %s\n", e$message))
})

# =============================================================================
# D. DDD MECHANISM TEST
# =============================================================================

cat("\n=== D. Triple-Difference Mechanism Test ===\n")

# DDD: (Low-risk Black vs Low-risk White) x (Reform vs Control) x (Before vs After)
# If low-risk Black citizens' turnout increases after restoration (relative to
# equivalent Whites), this cannot be explained by direct restoration effects
# and must reflect community-level spillovers.

ddd_sample <- ddd_data %>%
  filter(!state_fips %in% reversal_fips)

cat(sprintf("DDD sample: %d cells\n", nrow(ddd_sample)))

# Full DDD specification
m_ddd_turnout <- feols(
  turnout ~ triple + black_reform + low_risk_reform + black_low_risk +
    black + low_risk + post_reform | state_fips + year,
  data = ddd_sample,
  weights = ~n_obs,
  cluster = ~state_fips
)

cat("\n--- DDD: Turnout (triple = spillover effect) ---\n")
summary(m_ddd_turnout)

# Low-risk only DD (strongest spillover test)
low_risk_sample <- ddd_sample %>%
  filter(low_risk == 1)

m_lowrisk_dd <- feols(
  turnout ~ black_reform + black | state_fips + year,
  data = low_risk_sample,
  weights = ~n_obs,
  cluster = ~state_fips
)

cat("\n--- Low-Risk Only DD (Pure Spillover) ---\n")
summary(m_lowrisk_dd)

# High-risk DD (direct + spillover)
high_risk_sample <- ddd_sample %>%
  filter(low_risk == 0)

m_highrisk_dd <- feols(
  turnout ~ black_reform + black | state_fips + year,
  data = high_risk_sample,
  weights = ~n_obs,
  cluster = ~state_fips
)

cat("\n--- High-Risk DD (Direct + Spillover) ---\n")
summary(m_highrisk_dd)

# Save DDD results
saveRDS(list(
  ddd_full = m_ddd_turnout,
  low_risk_dd = m_lowrisk_dd,
  high_risk_dd = m_highrisk_dd
), file.path(data_dir, "ddd_results.rds"))

# =============================================================================
# E. SUMMARY OF MAIN RESULTS
# =============================================================================

cat("\n\n")
cat("=================================================================\n")
cat("SUMMARY OF MAIN RESULTS\n")
cat("=================================================================\n\n")

cat("DD: Black x Post-Reform on Turnout Gap:\n")
cat(sprintf("  Coefficient: %.4f (SE: %.4f)\n",
            coef(m_dd_turnout)["black_reform"],
            se(m_dd_turnout)["black_reform"]))
cat(sprintf("  p-value: %.4f\n",
            pvalue(m_dd_turnout)["black_reform"]))

cat("\nDD: Black x Post-Reform on Registration Gap:\n")
cat(sprintf("  Coefficient: %.4f (SE: %.4f)\n",
            coef(m_dd_reg)["black_reform"],
            se(m_dd_reg)["black_reform"]))

cat("\nDDD: Triple interaction (spillover on low-risk Black citizens):\n")
cat(sprintf("  Coefficient: %.4f (SE: %.4f)\n",
            coef(m_ddd_turnout)["triple"],
            se(m_ddd_turnout)["triple"]))

cat("\nLow-Risk Only DD (pure spillover test):\n")
cat(sprintf("  Coefficient: %.4f (SE: %.4f)\n",
            coef(m_lowrisk_dd)["black_reform"],
            se(m_lowrisk_dd)["black_reform"]))

cat("\n=================================================================\n")
