## ═══════════════════════════════════════════════════════════════════════════
## 04_robustness.R — Robustness checks and placebo tests
## Paper: Does Piped Water Build Human Capital? Evidence from India's JJM
## ═══════════════════════════════════════════════════════════════════════════

script_dir <- dirname(sys.frame(1)$ofile %||% ".")
if (script_dir == ".") script_dir <- getwd()
source(file.path(script_dir, "00_packages.R"))
load(file.path(data_dir, "analysis_data.RData"))

cat("\n══════════════════════════════════════════════\n")
cat("ROBUSTNESS CHECKS\n")
cat("══════════════════════════════════════════════\n\n")

# Standard controls for all robustness specs
base_controls <- "literacy_rate + pop_sc_share + pop_st_share + log_pop +
  child_share + agr_worker_share + improved_sanitation_nfhs4 + hh_electricity_nfhs4"

# ═══════════════════════════════════════════════════════════════════════════
# ROBUSTNESS 1: PLACEBO OUTCOMES
# ═══════════════════════════════════════════════════════════════════════════

cat("═══ PLACEBO TESTS ═══\n\n")

# Male tobacco use (should be unaffected by water infrastructure)
placebo_tobacco <- feols(
  as.formula(paste("d_male_tobacco ~ water_gap +", base_controls, "| state_id")),
  data = df_analysis, cluster = ~state_id)
cat("Male tobacco:", round(coef(placebo_tobacco)["water_gap"], 4),
    "p =", round(fixest::pvalue(placebo_tobacco)["water_gap"], 4), "\n")

# Teen pregnancy (lagged indicator - should not respond to contemporary water)
placebo_teen <- feols(
  as.formula(paste("d_teen_pregnancy ~ water_gap +", base_controls, "| state_id")),
  data = df_analysis, cluster = ~state_id)
cat("Teen pregnancy:", round(coef(placebo_teen)["water_gap"], 4),
    "p =", round(fixest::pvalue(placebo_teen)["water_gap"], 4), "\n")

# Child marriage (structural/cultural - should not respond to water)
placebo_marriage <- feols(
  as.formula(paste("d_child_marriage ~ water_gap +", base_controls, "| state_id")),
  data = df_analysis, cluster = ~state_id)
cat("Child marriage:", round(coef(placebo_marriage)["water_gap"], 4),
    "p =", round(fixest::pvalue(placebo_marriage)["water_gap"], 4), "\n")

# Health insurance (government expansion - should be orthogonal to water)
placebo_insurance <- feols(
  as.formula(paste("d_health_insurance ~ water_gap +", base_controls, "| state_id")),
  data = df_analysis, cluster = ~state_id)
cat("Health insurance:", round(coef(placebo_insurance)["water_gap"], 4),
    "p =", round(fixest::pvalue(placebo_insurance)["water_gap"], 4), "\n\n")

# ═══════════════════════════════════════════════════════════════════════════
# ROBUSTNESS 2: ALTERNATIVE TREATMENT DEFINITIONS
# ═══════════════════════════════════════════════════════════════════════════

cat("═══ ALTERNATIVE TREATMENT DEFINITIONS ═══\n\n")

# Binary treatment: above-median water gap
rob_binary <- feols(
  as.formula(paste("d_fem_school_attend ~ high_water_gap +", base_controls, "| state_id")),
  data = df_analysis, cluster = ~state_id)
cat("Binary (above-median) treatment:", round(coef(rob_binary)["high_water_gap"], 4),
    "SE:", round(se(rob_binary)["high_water_gap"], 4), "\n")

# Quintile treatment
rob_quintile <- feols(
  as.formula(paste("d_fem_school_attend ~ water_gap_q +", base_controls, "| state_id")),
  data = df_analysis[!is.na(water_gap_q)], cluster = ~state_id)
cat("\nQuintile treatment coefficients:\n")
qcoefs <- coef(rob_quintile)[grepl("water_gap_q", names(coef(rob_quintile)))]
for (nm in names(qcoefs)) {
  cat("  ", nm, ":", round(qcoefs[nm], 3), "\n")
}

# Standardized treatment (1 SD increase in water gap)
rob_sd <- feols(
  as.formula(paste("d_fem_school_attend ~ water_gap_sd +", base_controls, "| state_id")),
  data = df_analysis, cluster = ~state_id)
cat("\n1 SD water gap increase:", round(coef(rob_sd)["water_gap_sd"], 4),
    "SE:", round(se(rob_sd)["water_gap_sd"], 4), "\n\n")

# ═══════════════════════════════════════════════════════════════════════════
# ROBUSTNESS 3: HETEROGENEITY
# ═══════════════════════════════════════════════════════════════════════════

cat("═══ HETEROGENEITY ═══\n\n")

# By baseline literacy
df_analysis[, low_literacy := as.integer(literacy_rate < median(literacy_rate, na.rm = TRUE))]
het_lit <- feols(
  as.formula(paste("d_fem_school_attend ~ water_gap * low_literacy +", base_controls, "| state_id")),
  data = df_analysis, cluster = ~state_id)
cat("Interaction water_gap × low_literacy:",
    round(coef(het_lit)["water_gap:low_literacy"], 4), "\n")

# By SC/ST share
df_analysis[, high_scst := as.integer((pop_sc_share + pop_st_share) >
  median(pop_sc_share + pop_st_share, na.rm = TRUE))]
het_scst <- feols(
  as.formula(paste("d_fem_school_attend ~ water_gap * high_scst +", base_controls, "| state_id")),
  data = df_analysis, cluster = ~state_id)
cat("Interaction water_gap × high_scst:",
    round(coef(het_scst)["water_gap:high_scst"], 4), "\n")

# By agricultural dependence
df_analysis[, high_agr := as.integer(agr_worker_share > median(agr_worker_share, na.rm = TRUE))]
het_agr <- feols(
  as.formula(paste("d_fem_school_attend ~ water_gap * high_agr +", base_controls, "| state_id")),
  data = df_analysis, cluster = ~state_id)
cat("Interaction water_gap × high_agr:",
    round(coef(het_agr)["water_gap:high_agr"], 4), "\n\n")

# ═══════════════════════════════════════════════════════════════════════════
# ROBUSTNESS 4: SAMPLE RESTRICTIONS
# ═══════════════════════════════════════════════════════════════════════════

cat("═══ SAMPLE RESTRICTIONS ═══\n\n")

# Drop extreme outliers (top/bottom 5% of water gap)
q05 <- quantile(df_analysis$water_gap, 0.05, na.rm = TRUE)
q95 <- quantile(df_analysis$water_gap, 0.95, na.rm = TRUE)
rob_trim <- feols(
  as.formula(paste("d_fem_school_attend ~ water_gap +", base_controls, "| state_id")),
  data = df_analysis[water_gap >= q05 & water_gap <= q95],
  cluster = ~state_id)
cat("Trimmed (5-95%): β =", round(coef(rob_trim)["water_gap"], 4),
    "N =", nobs(rob_trim), "\n")

# Drop NE states (different development trajectory)
ne_states <- c("Arunachal Pradesh", "Assam", "Manipur", "Meghalaya",
               "Mizoram", "Nagaland", "Sikkim", "Tripura")
rob_no_ne <- feols(
  as.formula(paste("d_fem_school_attend ~ water_gap +", base_controls, "| state_id")),
  data = df_analysis[!State %in% ne_states],
  cluster = ~state_id)
cat("Excl NE states: β =", round(coef(rob_no_ne)["water_gap"], 4),
    "N =", nobs(rob_no_ne), "\n")

# Drop districts with near-zero water gap (already saturated)
rob_positive <- feols(
  as.formula(paste("d_fem_school_attend ~ water_gap +", base_controls, "| state_id")),
  data = df_analysis[water_gap > 1],
  cluster = ~state_id)
cat("Water gap > 1%: β =", round(coef(rob_positive)["water_gap"], 4),
    "N =", nobs(rob_positive), "\n\n")

# ═══════════════════════════════════════════════════════════════════════════
# ROBUSTNESS 5: CONLEY SPATIAL SEs
# ═══════════════════════════════════════════════════════════════════════════

cat("═══ ALTERNATIVE STANDARD ERRORS ═══\n\n")

# HC1 robust SEs
rob_hc1 <- feols(
  as.formula(paste("d_fem_school_attend ~ water_gap +", base_controls, "| state_id")),
  data = df_analysis, vcov = "hetero")
cat("HC1 robust: β =", round(coef(rob_hc1)["water_gap"], 4),
    "SE =", round(se(rob_hc1)["water_gap"], 4), "\n")

# State cluster (primary)
rob_cluster <- feols(
  as.formula(paste("d_fem_school_attend ~ water_gap +", base_controls, "| state_id")),
  data = df_analysis, cluster = ~state_id)
cat("State cluster: β =", round(coef(rob_cluster)["water_gap"], 4),
    "SE =", round(se(rob_cluster)["water_gap"], 4), "\n\n")

# ═══════════════════════════════════════════════════════════════════════════
# ROBUSTNESS 6: RANDOMIZATION INFERENCE
# ═══════════════════════════════════════════════════════════════════════════

cat("═══ RANDOMIZATION INFERENCE ═══\n\n")

# Permute water_gap across districts within state, holding controls fixed
set.seed(42)
n_perm <- 1000
actual_beta <- coef(rob_cluster)["water_gap"]

# Only permute within states that have > 1 district
multi_dist_states <- df_analysis[, .N, by = state_id][N > 1, state_id]
df_ri <- df_analysis[state_id %in% multi_dist_states]
cat("RI sample (states with >1 district):", nrow(df_ri), "districts,",
    length(multi_dist_states), "states\n")

perm_betas <- numeric(n_perm)
for (i in 1:n_perm) {
  df_perm <- copy(df_ri)
  df_perm[, water_gap := sample(water_gap), by = state_id]

  perm_fit <- tryCatch({
    feols(
      as.formula(paste("d_fem_school_attend ~ water_gap +", base_controls, "| state_id")),
      data = df_perm)
  }, error = function(e) NULL)

  if (!is.null(perm_fit)) {
    perm_betas[i] <- coef(perm_fit)["water_gap"]
  } else {
    perm_betas[i] <- NA
  }
}

perm_betas <- perm_betas[!is.na(perm_betas)]
ri_pvalue <- mean(abs(perm_betas) >= abs(actual_beta))
cat("Actual β:", round(actual_beta, 4), "\n")
cat("RI p-value (two-sided):", round(ri_pvalue, 4), "\n")
cat("Permutations:", length(perm_betas), "\n\n")

# ═══════════════════════════════════════════════════════════════════════════
# ROBUSTNESS 7: LEAVE-ONE-STATE-OUT
# ═══════════════════════════════════════════════════════════════════════════

cat("═══ LEAVE-ONE-STATE-OUT ═══\n\n")

states <- unique(df_analysis$state_id)
loso_betas <- numeric(length(states))
loso_names <- character(length(states))

for (j in seq_along(states)) {
  s <- states[j]
  loso_fit <- tryCatch({
    feols(
      as.formula(paste("d_fem_school_attend ~ water_gap +", base_controls, "| state_id")),
      data = df_analysis[state_id != s], cluster = ~state_id)
  }, error = function(e) NULL)

  if (!is.null(loso_fit)) {
    loso_betas[j] <- coef(loso_fit)["water_gap"]
  } else {
    loso_betas[j] <- NA
  }
  loso_names[j] <- df_analysis[state_id == s, unique(State)][1]
}

loso_dt <- data.table(state = loso_names, beta = loso_betas)
loso_dt <- loso_dt[!is.na(beta)]
cat("LOSO range: [", round(min(loso_dt$beta), 4), ",",
    round(max(loso_dt$beta), 4), "]\n")
cat("Most influential states:\n")
loso_dt[, deviation := abs(beta - actual_beta)]
print(loso_dt[order(-deviation)][1:5])

# ═══════════════════════════════════════════════════════════════════════════
# SAVE ROBUSTNESS RESULTS
# ═══════════════════════════════════════════════════════════════════════════

robustness <- list(
  placebos = list(tobacco = placebo_tobacco, teen = placebo_teen,
    marriage = placebo_marriage, insurance = placebo_insurance),
  alt_treatment = list(binary = rob_binary, quintile = rob_quintile, sd = rob_sd),
  heterogeneity = list(literacy = het_lit, scst = het_scst, agr = het_agr),
  sample = list(trim = rob_trim, no_ne = rob_no_ne, positive = rob_positive),
  se = list(hc1 = rob_hc1, cluster = rob_cluster),
  ri = list(actual_beta = actual_beta, perm_betas = perm_betas,
    ri_pvalue = ri_pvalue),
  loso = loso_dt
)

save(robustness, file = file.path(data_dir, "robustness_results.RData"))
cat("\n✓ Robustness checks complete. Results saved.\n")
