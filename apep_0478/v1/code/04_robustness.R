# =============================================================================
# 04_robustness.R — Going Up Alone (apep_0478)
# Placebo tests, alternative specifications, sensitivity analysis
# =============================================================================

source("00_packages.R")

cat("\n========================================\n")
cat("ROBUSTNESS CHECKS\n")
cat("========================================\n\n")

scm_panel  <- fread(file.path(DATA_DIR, "scm_panel.csv"))
linked     <- fread(file.path(DATA_DIR, "linked_panel_clean.csv"))

nyc_statefip <- 36L
# Comparison states: IL PA MA CA MI OH NJ DC MD
comparison_states <- c(17, 42, 25, 6, 26, 39, 34, 11, 24)

# Pre-compute treatment indicator to avoid collinearity with state FE
scm_panel[, treat_post := as.integer(STATEFIP == nyc_statefip & post == 1)]

# ─────────────────────────────────────────────────────────────────────────────
# R1: Placebo outcome — Janitors (should show NO effect of strike)
# ─────────────────────────────────────────────────────────────────────────────

cat("R1: Placebo outcome — Janitors...\n")

scm_panel[, janitor_per_10k_pop := n_janitors / total_pop * 10000]

did_panel <- scm_panel[STATEFIP %in% c(nyc_statefip, comparison_states)]

reg_janitor <- feols(
  janitor_per_10k_pop ~ treat_post | STATEFIP + year,
  data = did_panel, cluster = ~STATEFIP
)
cat("  Placebo (janitors) DiD:\n")
print(summary(reg_janitor))

# ─────────────────────────────────────────────────────────────────────────────
# R2: Placebo time — pretend strike was in 1925
# ─────────────────────────────────────────────────────────────────────────────

cat("\nR2: Placebo time — fake strike in 1925...\n")

pre_panel <- scm_panel[year <= 1940]
pre_panel[, fake_post := as.integer(year >= 1930)]
pre_panel[, fake_treat_post := as.integer(STATEFIP == nyc_statefip & fake_post == 1)]

did_placebo_time <- feols(
  elev_per_10k_pop ~ fake_treat_post | STATEFIP + year,
  data = pre_panel[STATEFIP %in% c(nyc_statefip, comparison_states)],
  cluster = ~STATEFIP
)
cat("  Placebo time DiD:\n")
print(summary(did_placebo_time))

# ─────────────────────────────────────────────────────────────────────────────
# R3-R4: Alternative outcomes
# ─────────────────────────────────────────────────────────────────────────────

cat("\nR3: Alternative outcome — operators per 10k pop...\n")
did_alt <- feols(
  elev_per_10k_pop ~ treat_post | STATEFIP + year,
  data = did_panel, cluster = ~STATEFIP
)
print(summary(did_alt))

cat("\nR4: Alternative outcome — operators per 10k employed...\n")
did_emp <- feols(
  elev_per_10k_emp ~ treat_post | STATEFIP + year,
  data = did_panel, cluster = ~STATEFIP
)
print(summary(did_emp))

# ─────────────────────────────────────────────────────────────────────────────
# R5: Event study (year × NY interaction)
# ─────────────────────────────────────────────────────────────────────────────

cat("\nR5: Event study...\n")

es_panel <- scm_panel[STATEFIP %in% c(nyc_statefip, comparison_states)]
reg_es <- feols(
  elev_per_10k_pop ~ i(year, is_nyc, ref = 1940) | STATEFIP + year,
  data = es_panel, cluster = ~STATEFIP
)
print(summary(reg_es))

es_coefs <- as.data.frame(coeftable(reg_es))
es_coefs$year <- as.integer(gsub("year::|:is_nyc", "", rownames(es_coefs)))
fwrite(es_coefs, file.path(DATA_DIR, "event_study_coefs.csv"))

# ─────────────────────────────────────────────────────────────────────────────
# R6: Individual-level — age heterogeneity
# ─────────────────────────────────────────────────────────────────────────────

cat("\nR6: Displacement by age group...\n")
reg_age <- feols(
  stayed_same_occ ~ is_elevator_1940 * age_group_1940 |
    statefip_1940 + race_1940 + sex_1940,
  data = linked, cluster = ~statefip_1940
)
print(summary(reg_age))

# ─────────────────────────────────────────────────────────────────────────────
# R7: Triple difference (occupation × state × time)
# ─────────────────────────────────────────────────────────────────────────────

cat("\nR7: Triple difference...\n")

occ_state <- scm_panel[, .(
  STATEFIP, year, is_nyc, post,
  n_elevator = n_elevator_ops, n_janitors
)]

occ_long <- melt(occ_state,
                 id.vars = c("STATEFIP", "year", "is_nyc", "post"),
                 measure.vars = c("n_elevator", "n_janitors"),
                 variable.name = "occupation", value.name = "count")
occ_long[, is_elevator := as.integer(occupation == "n_elevator")]

occ_long[, ddd_treat := as.integer(is_elevator == 1 & STATEFIP == nyc_statefip & post == 1)]
occ_long_sub <- occ_long[STATEFIP %in% c(nyc_statefip, comparison_states)]
reg_ddd <- feols(
  log(count + 1) ~ ddd_treat |
    STATEFIP^occupation + year^occupation + STATEFIP^year,
  data = occ_long_sub, cluster = ~STATEFIP
)
print(summary(reg_ddd))

# Save all robustness
rob <- list(
  janitor_placebo = reg_janitor, time_placebo = did_placebo_time,
  alt_per_pop = did_alt, alt_per_emp = did_emp, event_study = reg_es,
  age_heterogeneity = reg_age, triple_diff = reg_ddd
)
saveRDS(rob, file.path(DATA_DIR, "robustness_results.rds"))

cat("\n========================================\n")
cat("ROBUSTNESS CHECKS COMPLETE\n")
cat("========================================\n")
