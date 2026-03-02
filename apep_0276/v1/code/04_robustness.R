# =============================================================================
# 04_robustness.R - Robustness Checks
# APEP-0265: Felon Voting Rights Restoration and Black Political Participation
# =============================================================================

source("00_packages.R")

data_dir <- "../data"

cell_data <- readRDS(file.path(data_dir, "analysis_cells.rds"))
gap_panel <- readRDS(file.path(data_dir, "analysis_cells.rds")) %>%
  filter(state_group %in% c("reform", "control")) %>%
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
  mutate(first_treat = replace_na(first_election, 0))

voting_laws <- readRDS(file.path(data_dir, "concurrent_voting_laws.rds"))
reforms <- readRDS(file.path(data_dir, "reform_timing.rds"))

reversal_fips <- c(12, 19)

cat("\n=== Robustness Checks ===\n")

robustness_results <- list()

# =============================================================================
# R1. INCLUDING REVERSAL STATES
# =============================================================================

cat("\n--- R1: Include Reversal States (FL, IA) ---\n")

# Code FL and IA as treated during their final expansion only
r1_data <- cell_data %>%
  filter(state_group %in% c("reform", "control", "reversal"))

m_r1 <- feols(
  turnout ~ black_reform + black | state_fips^year,
  data = r1_data,
  weights = ~n_obs,
  cluster = ~state_fips
)
summary(m_r1)
robustness_results$r1_include_reversals <- m_r1

# =============================================================================
# R2. PERMANENT REFORMS ONLY
# =============================================================================

cat("\n--- R2: Permanent Reforms Only (legislative/ballot, exclude EOs) ---\n")

permanent_fips <- reforms %>%
  filter(reform_type %in% c("legislative", "ballot")) %>%
  pull(state_fips)

r2_data <- cell_data %>%
  filter(state_fips %in% c(permanent_fips, unique(cell_data$state_fips[cell_data$state_group == "control"])),
         !state_fips %in% reversal_fips)

m_r2 <- feols(
  turnout ~ black_reform + black | state_fips^year,
  data = r2_data,
  weights = ~n_obs,
  cluster = ~state_fips
)
summary(m_r2)
robustness_results$r2_permanent_only <- m_r2

# =============================================================================
# R3. PLACEBO: HISPANIC-WHITE GAP
# =============================================================================

cat("\n--- R3: Placebo Test (Hispanic-White Turnout Gap) ---\n")

placebo_data <- readRDS(file.path(data_dir, "placebo_hispanic.rds")) %>%
  filter(!state_fips %in% reversal_fips)

m_r3 <- feols(
  turnout ~ hispanic_reform + hispanic_ind | state_fips^year,
  data = placebo_data,
  weights = ~n_obs,
  cluster = ~state_fips
)
summary(m_r3)
robustness_results$r3_hispanic_placebo <- m_r3

# =============================================================================
# R4. REGISTRATION OUTCOME
# =============================================================================

cat("\n--- R4: Registration as Outcome ---\n")

dd_sample <- cell_data %>%
  filter(!state_fips %in% reversal_fips,
         state_group %in% c("reform", "control"))

m_r4 <- feols(
  registered ~ black_reform + black | state_fips^year,
  data = dd_sample,
  weights = ~n_obs,
  cluster = ~state_fips
)
summary(m_r4)
robustness_results$r4_registration <- m_r4

# =============================================================================
# R5. UNWEIGHTED ESTIMATION
# =============================================================================

cat("\n--- R5: Unweighted Estimation ---\n")

m_r5 <- feols(
  turnout ~ black_reform + black | state_fips^year,
  data = dd_sample,
  cluster = ~state_fips
)
summary(m_r5)
robustness_results$r5_unweighted <- m_r5

# =============================================================================
# R6. PRESIDENTIAL ELECTION YEARS ONLY
# =============================================================================

cat("\n--- R6: Presidential Election Years Only ---\n")

presidential_years <- seq(1996, 2024, by = 4)

m_r6 <- feols(
  turnout ~ black_reform + black | state_fips^year,
  data = dd_sample %>% filter(year %in% presidential_years),
  weights = ~n_obs,
  cluster = ~state_fips
)
summary(m_r6)
robustness_results$r6_presidential <- m_r6

# =============================================================================
# R7. MIDTERM ELECTION YEARS ONLY
# =============================================================================

cat("\n--- R7: Midterm Election Years Only ---\n")

midterm_years <- seq(1998, 2022, by = 4)

m_r7 <- feols(
  turnout ~ black_reform + black | state_fips^year,
  data = dd_sample %>% filter(year %in% midterm_years),
  weights = ~n_obs,
  cluster = ~state_fips
)
summary(m_r7)
robustness_results$r7_midterm <- m_r7

# =============================================================================
# R8. CONCURRENT VOTING LAW CONTROLS
# =============================================================================

cat("\n--- R8: With Concurrent Voting Law Controls ---\n")

dd_controls <- dd_sample %>%
  left_join(voting_laws, by = c("state_fips", "year")) %>%
  mutate(across(starts_with("has_"), ~replace_na(., 0)))

m_r8 <- feols(
  turnout ~ black_reform + black +
    has_strict_voter_id + has_same_day_reg + has_auto_voter_reg |
    state_fips^year,
  data = dd_controls,
  weights = ~n_obs,
  cluster = ~state_fips
)
summary(m_r8)
robustness_results$r8_voting_controls <- m_r8

# =============================================================================
# R9. SUN-ABRAHAM ESTIMATOR (via fixest sunab)
# =============================================================================

cat("\n--- R9: Sun-Abraham Estimator ---\n")

gap_panel_main <- gap_panel %>%
  filter(!state_fips %in% reversal_fips)

tryCatch({
  m_r9 <- feols(
    turnout_gap ~ sunab(first_treat, year) | state_fips + year,
    data = gap_panel_main %>% filter(first_treat > 0 | first_treat == 0),
    cluster = ~state_fips
  )
  summary(m_r9)
  robustness_results$r9_sun_abraham <- m_r9
}, error = function(e) {
  cat(sprintf("Sun-Abraham error: %s\n", e$message))
})

# =============================================================================
# R10. HONESTDID SENSITIVITY ANALYSIS
# =============================================================================

cat("\n--- R10: HonestDiD Sensitivity ---\n")

tryCatch({
  library(HonestDiD)

  # Load CS results
  cs_results <- readRDS(file.path(data_dir, "cs_turnout_results.rds"))

  if ("cs_es" %in% names(cs_results)) {
    es <- cs_results$cs_es

    # Extract pre-treatment and post-treatment coefficients
    pre_idx <- which(es$egt < 0)
    post_idx <- which(es$egt >= 0)

    if (length(pre_idx) >= 2 && length(post_idx) >= 1) {
      # Construct objects for HonestDiD
      betahat <- es$att.egt
      sigma <- diag(es$se.egt^2)  # Approximate variance matrix

      # Relative magnitudes approach
      honest_rm <- tryCatch({
        createSensitivityResults_relativeMagnitudes(
          betahat = betahat,
          sigma = sigma,
          numPrePeriods = length(pre_idx),
          numPostPeriods = length(post_idx),
          Mbarvec = seq(0, 2, by = 0.5)
        )
      }, error = function(e) {
        cat(sprintf("HonestDiD RM error: %s\n", e$message))
        NULL
      })

      if (!is.null(honest_rm)) {
        saveRDS(honest_rm, file.path(data_dir, "honestdid_results.rds"))
        cat("HonestDiD results saved.\n")
      }
    }
  }
}, error = function(e) {
  cat(sprintf("HonestDiD error: %s\n", e$message))
})

# =============================================================================
# SAVE ALL ROBUSTNESS RESULTS
# =============================================================================

saveRDS(robustness_results, file.path(data_dir, "robustness_results.rds"))

cat("\n=== Robustness Summary ===\n")
cat("Model                    | Coef (Black x Reform) | SE      | p-value\n")
cat("-------------------------|----------------------|---------|--------\n")

for (nm in names(robustness_results)) {
  m <- robustness_results[[nm]]
  # Find the interaction coefficient
  coef_name <- intersect(c("black_reform", "hispanic_reform"), names(coef(m)))
  if (length(coef_name) > 0) {
    b <- coef(m)[coef_name[1]]
    s <- se(m)[coef_name[1]]
    p <- pvalue(m)[coef_name[1]]
    cat(sprintf("%-25s| %20.4f | %7.4f | %7.4f\n", nm, b, s, p))
  }
}

cat("\n=== Robustness Checks Complete ===\n")
