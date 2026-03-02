##############################################################################
# 04_robustness.R — Robustness checks and sensitivity analysis
# APEP-0221: Educational Content Restriction Laws and Teacher Labor Markets
##############################################################################

source("00_packages.R")

cat("=== Robustness checks ===\n")

# Load data
edu_panel <- readRDS("../data/edu_panel.rds")
panel <- readRDS("../data/panel.rds")
results <- readRDS("../data/main_results.rds")
treatment_laws <- readRDS("../data/treatment_laws.rds")

cs_data <- edu_panel %>%
  filter(!is.na(Emp), Emp > 0) %>%
  select(state_id, time_int, first_treat_int, log_emp, log_earn, sep_rate, hire_rate,
         TurnOvrS, state_fips, year, quarter, treat, stringency_score, stringency) %>%
  distinct(state_id, time_int, .keep_all = TRUE)

# ============================================================================
# 1) RAMBACHAN-ROTH HONEST DiD SENSITIVITY
# ============================================================================

cat("\n--- Rambachan-Roth Sensitivity Analysis ---\n")

tryCatch({
  # Get the CS event study for employment
  es_emp <- results$es_emp

  # HonestDiD: sensitivity to linear violations of parallel trends
  honest_results <- HonestDiD::createSensitivityResults_relativeMagnitudes(
    betahat = es_emp$att.egt,
    sigma = diag(es_emp$se.egt^2) * diag(length(es_emp$se.egt)),
    numPrePeriods = sum(es_emp$egt < 0),
    numPostPeriods = sum(es_emp$egt >= 0),
    Mbarvec = seq(0.5, 2, by = 0.5)
  )

  cat("Honest DiD results (relative magnitude):\n")
  print(honest_results)

  saveRDS(honest_results, "../data/honest_did_emp.rds")
}, error = function(e) {
  cat("HonestDiD error:", conditionMessage(e), "\n")
  cat("Will report CS results with standard inference.\n")
})

# ============================================================================
# 2) PLACEBO TESTS: NON-EDUCATION SECTORS
# ============================================================================

cat("\n--- Placebo Tests: Non-Education Sectors ---\n")

placebo_results <- list()

for (ind in c("62", "44-45", "31-33")) {
  ind_label <- case_when(
    ind == "62" ~ "Healthcare",
    ind == "44-45" ~ "Retail",
    ind == "31-33" ~ "Manufacturing"
  )
  cat(sprintf("  Placebo: %s (%s)\n", ind_label, ind))

  placebo_data <- panel %>%
    filter(industry == ind, !is.na(Emp), Emp > 0) %>%
    mutate(
      log_emp = log(Emp + 1),
      state_id = as.integer(factor(state_fips))
    ) %>%
    distinct(state_id, time_int, .keep_all = TRUE)

  tryCatch({
    placebo_cs <- att_gt(
      yname = "log_emp",
      tname = "time_int",
      idname = "state_id",
      gname = "first_treat_int",
      data = placebo_data,
      control_group = "nevertreated",
      anticipation = 0,
      base_period = "universal"
    )

    placebo_agg <- aggte(placebo_cs, type = "simple")
    placebo_es <- aggte(placebo_cs, type = "dynamic", min_e = -8, max_e = 12)

    placebo_results[[ind]] <- list(
      industry = ind_label,
      cs = placebo_cs,
      agg = placebo_agg,
      es = placebo_es
    )

    cat(sprintf("  %s ATT: %.4f (SE: %.4f, p: %.4f)\n",
                ind_label, placebo_agg$overall.att,
                placebo_agg$overall.se,
                2 * pnorm(-abs(placebo_agg$overall.att / placebo_agg$overall.se))))
  }, error = function(e) {
    cat(sprintf("  %s error: %s\n", ind_label, conditionMessage(e)))
  })
}

saveRDS(placebo_results, "../data/placebo_results.rds")

# ============================================================================
# 3) HETEROGENEITY BY LAW STRINGENCY
# ============================================================================

cat("\n--- Heterogeneity by Law Stringency ---\n")

# Split into strong vs moderate/weak
strong_states <- treatment_laws %>% filter(stringency == "strong") %>% pull(state_fips)
moderate_weak_states <- treatment_laws %>% filter(stringency != "strong") %>% pull(state_fips)

# Strong stringency subset
strong_data <- cs_data %>%
  filter(state_fips %in% c(strong_states, cs_data$state_fips[cs_data$first_treat_int == 0]) ) %>%
  mutate(state_id = as.integer(factor(state_fips)))

tryCatch({
  cs_strong <- att_gt(
    yname = "log_emp",
    tname = "time_int",
    idname = "state_id",
    gname = "first_treat_int",
    data = strong_data,
    control_group = "nevertreated",
    anticipation = 0,
    base_period = "universal"
  )
  agg_strong <- aggte(cs_strong, type = "simple")
  es_strong <- aggte(cs_strong, type = "dynamic", min_e = -8, max_e = 12)
  cat(sprintf("Strong stringency ATT: %.4f (SE: %.4f)\n",
              agg_strong$overall.att, agg_strong$overall.se))
}, error = function(e) {
  cat("Strong stringency error:", conditionMessage(e), "\n")
  agg_strong <- NULL
  es_strong <- NULL
})

# Moderate/weak stringency subset
mw_data <- cs_data %>%
  filter(state_fips %in% c(moderate_weak_states, cs_data$state_fips[cs_data$first_treat_int == 0])) %>%
  mutate(state_id = as.integer(factor(state_fips)))

tryCatch({
  cs_mw <- att_gt(
    yname = "log_emp",
    tname = "time_int",
    idname = "state_id",
    gname = "first_treat_int",
    data = mw_data,
    control_group = "nevertreated",
    anticipation = 0,
    base_period = "universal"
  )
  agg_mw <- aggte(cs_mw, type = "simple")
  es_mw <- aggte(cs_mw, type = "dynamic", min_e = -8, max_e = 12)
  cat(sprintf("Moderate/weak stringency ATT: %.4f (SE: %.4f)\n",
              agg_mw$overall.att, agg_mw$overall.se))
}, error = function(e) {
  cat("Moderate/weak stringency error:", conditionMessage(e), "\n")
  agg_mw <- NULL
  es_mw <- NULL
})

# ============================================================================
# 4) TREATMENT INTENSITY: STRINGENCY SCORE
# ============================================================================

cat("\n--- Treatment Intensity (Stringency Score) ---\n")

cs_data_intensity <- cs_data %>%
  mutate(treat_intensity = ifelse(treat == 1, stringency_score, 0))

twfe_intensity <- feols(log_emp ~ treat_intensity | state_id + time_int,
                        data = cs_data_intensity, cluster = ~state_id)
cat("TWFE with treatment intensity:\n")
summary(twfe_intensity)

# ============================================================================
# 5) RANDOMIZATION INFERENCE (Fisher Permutation Test)
# ============================================================================

cat("\n--- Randomization Inference ---\n")

# Observed TWFE coefficient
obs_coef <- coef(results$twfe_emp)["treat"]

# Permutation: randomly assign treatment status across states
n_perms <- 1000
perm_coefs <- numeric(n_perms)
n_treated <- n_distinct(cs_data$state_fips[cs_data$first_treat_int > 0])
all_states_vec <- unique(cs_data$state_fips)

# Get actual treatment timings from the data
actual_timings <- cs_data %>%
  filter(first_treat_int > 0) %>%
  distinct(state_fips, first_treat_int) %>%
  pull(first_treat_int)

for (i in seq_len(n_perms)) {
  # Randomly select treated states
  fake_treated <- sample(all_states_vec, n_treated)

  # Randomly assign treatment timing from actual timing distribution
  fake_timings <- sample(actual_timings, n_treated, replace = TRUE)

  # Create mapping
  fake_map <- tibble(state_fips = fake_treated, fake_timing = fake_timings)

  perm_data <- cs_data %>%
    left_join(fake_map, by = "state_fips") %>%
    mutate(
      fake_timing = ifelse(is.na(fake_timing), 0, fake_timing),
      fake_treat = as.integer(fake_timing > 0 & time_int >= fake_timing)
    )

  tryCatch({
    perm_fit <- feols(log_emp ~ fake_treat | state_id + time_int,
                      data = perm_data, cluster = ~state_id)
    perm_coefs[i] <- coef(perm_fit)["fake_treat"]
  }, error = function(e) {
    perm_coefs[i] <<- NA
  })
}

# Fisher p-value
perm_coefs <- perm_coefs[!is.na(perm_coefs)]
fisher_p <- mean(abs(perm_coefs) >= abs(obs_coef))
cat(sprintf("Fisher exact p-value (1000 permutations): %.4f\n", fisher_p))
cat(sprintf("Observed coefficient: %.6f\n", obs_coef))
cat(sprintf("Permutation mean: %.6f, SD: %.6f\n", mean(perm_coefs), sd(perm_coefs)))

# ============================================================================
# 6) ALTERNATIVE CONTROL GROUPS: NOT-YET-TREATED
# ============================================================================

cat("\n--- Alternative control: not-yet-treated ---\n")

tryCatch({
  cs_nyt <- att_gt(
    yname = "log_emp",
    tname = "time_int",
    idname = "state_id",
    gname = "first_treat_int",
    data = cs_data,
    control_group = "notyettreated",
    anticipation = 0,
    base_period = "universal"
  )

  agg_nyt <- aggte(cs_nyt, type = "simple")
  es_nyt <- aggte(cs_nyt, type = "dynamic", min_e = -8, max_e = 12)
  cat(sprintf("Not-yet-treated ATT: %.4f (SE: %.4f)\n",
              agg_nyt$overall.att, agg_nyt$overall.se))
}, error = function(e) {
  cat("Not-yet-treated error:", conditionMessage(e), "\n")
  agg_nyt <- NULL
  es_nyt <- NULL
})

# ============================================================================
# 7) GENDER COMPOSITION ANALYSIS
# ============================================================================

cat("\n--- Gender Composition Analysis ---\n")

if (file.exists("../data/qwi_education_by_sex.rds")) {
  qwi_sex <- readRDS("../data/qwi_education_by_sex.rds")

  # Compute female share by state-quarter
  sex_wide <- qwi_sex %>%
    filter(!is.na(Emp), Emp > 0) %>%
    select(state_fips, year, quarter, sex_label, Emp) %>%
    pivot_wider(names_from = sex_label, values_from = Emp, names_prefix = "emp_") %>%
    filter(!is.na(emp_Female), !is.na(emp_Male)) %>%
    mutate(
      female_share = emp_Female / (emp_Female + emp_Male),
      time_int = (year - 2015) * 4 + quarter
    )

  # Merge treatment info
  treat_info <- treatment_laws %>%
    mutate(first_treat_int_val = (first_full_q_year - 2015) * 4 + first_full_q) %>%
    select(state_fips, treat_yq, first_treat_int_val)

  sex_share <- sex_wide %>%
    left_join(treat_info, by = "state_fips") %>%
    mutate(
      treated_state = !is.na(treat_yq),
      treat = as.integer(treated_state & (year + (quarter - 1)/4) >= treat_yq),
      state_id = as.integer(factor(state_fips))
    )

  tryCatch({
    twfe_female <- feols(female_share ~ treat | state_id + time_int,
                         data = sex_share, cluster = ~state_id)
    cat("TWFE: Female share in education\n")
    summary(twfe_female)
  }, error = function(e) {
    cat("Female share TWFE error:", conditionMessage(e), "\n")
  })
}

# ============================================================================
# SAVE ALL ROBUSTNESS RESULTS
# ============================================================================

robust_results <- list(
  fisher_p = fisher_p,
  obs_coef = obs_coef,
  perm_coefs = perm_coefs,
  placebo_results = placebo_results,
  twfe_intensity = twfe_intensity
)

# Add conditional objects
if (exists("agg_strong")) robust_results$agg_strong <- agg_strong
if (exists("es_strong")) robust_results$es_strong <- es_strong
if (exists("agg_mw")) robust_results$agg_mw <- agg_mw
if (exists("es_mw")) robust_results$es_mw <- es_mw
if (exists("agg_nyt")) robust_results$agg_nyt <- agg_nyt
if (exists("es_nyt")) robust_results$es_nyt <- es_nyt
if (exists("honest_results")) robust_results$honest_did <- honest_results
if (exists("twfe_female")) robust_results$twfe_female <- twfe_female

saveRDS(robust_results, "../data/robust_results.rds")
cat("\n=== Robustness checks complete ===\n")
