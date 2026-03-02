# =============================================================================
# 03_main_analysis.R — Going Up Alone v2 (apep_0478)
# Restructured: Individual transitions as analytical backbone, SCM as supporting
# =============================================================================

source("00_packages.R")

cat("\n========================================\n")
cat("MAIN ANALYSIS (v2 — Individual-Centered)\n")
cat("========================================\n\n")

# Load clean data
scm_panel   <- fread(file.path(DATA_DIR, "scm_panel.csv"))
linked      <- fread(file.path(DATA_DIR, "linked_panel_clean.csv"))
national    <- fread(file.path(DATA_DIR, "national_clean.csv"))

# ─────────────────────────────────────────────────────────────────────────────
# PART I: INDIVIDUAL TRANSITIONS — THE ANALYTICAL CORE
# ─────────────────────────────────────────────────────────────────────────────

cat("═══════════════════════════════════════════\n")
cat("PART I: Individual-Level Displacement Analysis\n")
cat("═══════════════════════════════════════════\n\n")

elev_1940 <- linked[is_elevator_1940 == 1]
cat(sprintf("  Elevator operators (1940): %s\n", format(nrow(elev_1940), big.mark = ",")))

# ─── 1a: Core Displacement Regressions ───────────────────────────────────────

cat("\n--- 1a: Core displacement regressions ---\n")

# Reg 1: Occupational persistence (elevator vs other bldg service)
cat("  Regression 1: Occupational persistence\n")
reg_stay <- feols(
  stayed_same_occ ~ is_elevator_1940 |
    statefip_1940 + race_1940 + sex_1940 + age_group_1940,
  data = linked, cluster = ~statefip_1940
)
print(summary(reg_stay))

# Reg 2: Interstate mobility
cat("\n  Regression 2: Interstate mobility\n")
reg_move <- feols(
  interstate_mover ~ is_elevator_1940 |
    statefip_1940 + race_1940 + sex_1940 + age_group_1940,
  data = linked, cluster = ~statefip_1940
)
print(summary(reg_move))

# Reg 3: OCCSCORE change (occupational quality)
cat("\n  Regression 3: OCCSCORE change\n")
reg_occ <- feols(
  occscore_change ~ is_elevator_1940 |
    statefip_1940 + race_1940 + sex_1940 + age_group_1940,
  data = linked, cluster = ~statefip_1940
)
print(summary(reg_occ))

# ─── 1b: NYC vs Non-NYC Transition Comparison ────────────────────────────────

cat("\n--- 1b: NYC vs. Non-NYC transitions ---\n")

# Direct test: did operators in the strike's epicenter transition differently?
# This replaces the fragile state-level SCM with individual-level evidence

# Exit rate comparison
cat("  Exit rates:\n")
exit_by_nyc <- elev_1940[, .(
  n = .N,
  n_exited = sum(still_elevator_1950 == 0),
  exit_rate = mean(still_elevator_1950 == 0),
  mean_occscore_1950 = mean(occscore_1950, na.rm = TRUE),
  mean_occscore_change = mean(occscore_change, na.rm = TRUE),
  pct_to_janitor = mean(occ1950_1950 == 770) * 100,
  pct_to_porter = mean(occ1950_1950 == 780) * 100,
  pct_to_nlf = mean(occ1950_1950 == 0 | occ1950_1950 >= 980) * 100,
  pct_upward = mean(occscore_change > 0, na.rm = TRUE) * 100,
  pct_downward = mean(occscore_change < 0, na.rm = TRUE) * 100
), by = is_nyc_1940]
print(exit_by_nyc)
fwrite(exit_by_nyc, file.path(DATA_DIR, "nyc_vs_other_summary.csv"))

# Reg: NYC effect on staying, controlling for demographics
cat("\n  NYC effect on persistence:\n")
reg_nyc_stay <- feols(
  still_elevator_1950 ~ is_nyc_1940 |
    race_1940 + sex_1940 + age_group_1940,
  data = elev_1940, cluster = ~statefip_1940
)
print(summary(reg_nyc_stay))

# Reg: NYC effect on OCCSCORE change
cat("\n  NYC effect on OCCSCORE change:\n")
reg_nyc_occ <- feols(
  occscore_change ~ is_nyc_1940 |
    race_1940 + sex_1940 + age_group_1940,
  data = elev_1940, cluster = ~statefip_1940
)
print(summary(reg_nyc_occ))

# Reg: NYC × race interaction
cat("\n  NYC × race interaction:\n")
reg_nyc_race <- feols(
  still_elevator_1950 ~ is_nyc_1940 * is_black |
    sex_1940 + age_group_1940,
  data = elev_1940, cluster = ~statefip_1940
)
print(summary(reg_nyc_race))

# NYC transition matrix (for detailed table)
trans_by_nyc <- elev_1940[, .N, by = .(is_nyc_1940, occ_broad_1950)]
trans_by_nyc[, pct := N / sum(N) * 100, by = is_nyc_1940]
fwrite(trans_by_nyc, file.path(DATA_DIR, "transition_by_nyc_detail.csv"))

cat("\n  NYC vs Other transition matrix:\n")
trans_wide <- dcast(trans_by_nyc, occ_broad_1950 ~ is_nyc_1940,
                    value.var = "pct", fill = 0)
setnames(trans_wide, c("Occupation_1950", "Other", "NYC"))
setorder(trans_wide, -NYC)
print(trans_wide)

# ─── 1c: Occupational Ladder / Destination Quality ───────────────────────────

cat("\n--- 1c: Occupational destination quality ---\n")

# OCCSCORE distribution for exiting operators
exiters <- elev_1940[still_elevator_1950 == 0 & occ1950_1950 > 0 & occ1950_1950 < 980]
cat(sprintf("  Exiters with valid 1950 occupation: %s\n",
    format(nrow(exiters), big.mark = ",")))

# Classify transitions as upward/lateral/downward
elev_1940[, transition_dir := fcase(
  still_elevator_1950 == 1, "Stayed",
  occ1950_1950 == 0 | occ1950_1950 >= 980, "Left labor force",
  occscore_change > 2, "Upward",
  occscore_change < -2, "Downward",
  default = "Lateral"
)]

transition_summary <- elev_1940[, .N, by = transition_dir]
transition_summary[, pct := N / sum(N) * 100]
setorder(transition_summary, -N)
cat("  Transition direction summary:\n")
print(transition_summary)
fwrite(transition_summary, file.path(DATA_DIR, "transition_direction.csv"))

# Mean OCCSCORE by destination occupation
dest_quality <- exiters[, .(
  n = .N,
  mean_occscore_1940 = mean(occscore_1940),
  mean_occscore_1950 = mean(occscore_1950),
  mean_change = mean(occscore_change),
  pct_upward = mean(occscore_change > 0) * 100
), by = occ_broad_1950]
setorder(dest_quality, -n)
cat("\n  Destination quality by occupation:\n")
print(dest_quality)
fwrite(dest_quality, file.path(DATA_DIR, "destination_quality.csv"))

# ─── 1d: Selection into Persistence ──────────────────────────────────────────

cat("\n--- 1d: Selection into persistence (who stays?) ---\n")

# Logit: P(still elevator in 1950) ~ demographics
# Center age for interpretability
elev_1940[, age_centered := age_1940 - median(age_1940)]
elev_1940[, age_centered_sq := age_centered^2]
elev_1940[, is_married := as.integer(marst_1940 %in% c(1, 2))]

# Logit model
logit_persist <- glm(
  still_elevator_1950 ~ age_centered + age_centered_sq +
    is_black + is_female + is_native + is_married + is_nyc_1940,
  data = elev_1940, family = binomial(link = "logit")
)
cat("\n  Logit: Selection into persistence\n")
print(summary(logit_persist))

# Average marginal effects
beta <- coef(logit_persist)
p_hat <- predict(logit_persist, type = "response")

# Compute AME for each variable
X <- model.matrix(logit_persist)
ame_vals <- numeric(ncol(X))
names(ame_vals) <- colnames(X)
for (j in seq_len(ncol(X))) {
  ame_vals[j] <- mean(p_hat * (1 - p_hat) * beta[j])
}

ame_df <- data.frame(
  variable = names(beta),
  coefficient = beta,
  ame = ame_vals,
  se = summary(logit_persist)$coefficients[, "Std. Error"],
  p_value = summary(logit_persist)$coefficients[, "Pr(>|z|)"]
)
rownames(ame_df) <- NULL
cat("\n  Average Marginal Effects:\n")
print(ame_df)
fwrite(ame_df, file.path(DATA_DIR, "selection_logit_ame.csv"))

# What happens to stayers vs leavers in terms of occupational quality?
stayer_leaver <- elev_1940[, .(
  n = .N,
  mean_occscore_1940 = mean(occscore_1940),
  mean_occscore_1950 = mean(occscore_1950),
  mean_change = mean(occscore_change),
  mean_age_1940 = mean(age_1940),
  pct_black = mean(is_black) * 100,
  pct_female = mean(is_female) * 100,
  pct_nyc = mean(is_nyc_1940) * 100
), by = .(stayed = still_elevator_1950)]
cat("\n  Stayers vs. Leavers:\n")
print(stayer_leaver)
fwrite(stayer_leaver, file.path(DATA_DIR, "stayer_leaver_comparison.csv"))

# ─── 1e: Heterogeneity Regressions ───────────────────────────────────────────

cat("\n--- 1e: Heterogeneity regressions ---\n")

# Race heterogeneity
cat("  Heterogeneity by race:\n")
reg_race <- feols(
  stayed_same_occ ~ is_elevator_1940 * is_black |
    statefip_1940 + sex_1940 + age_group_1940,
  data = linked, cluster = ~statefip_1940
)
print(summary(reg_race))

# Sex heterogeneity
cat("\n  Heterogeneity by sex:\n")
reg_sex <- feols(
  stayed_same_occ ~ is_elevator_1940 * is_female |
    statefip_1940 + race_1940 + age_group_1940,
  data = linked, cluster = ~statefip_1940
)
print(summary(reg_sex))

# NYC heterogeneity (elevator × NYC)
cat("\n  Heterogeneity by NYC:\n")
reg_nyc <- feols(
  stayed_same_occ ~ is_elevator_1940 * is_nyc_1940 |
    race_1940 + sex_1940 + age_group_1940,
  data = linked, cluster = ~statefip_1940
)
print(summary(reg_nyc))

# ─── 1f: Demographic Composition Shift (Cross-Sectional) ─────────────────────

cat("\n--- 1f: Demographic composition shift ---\n")

demo_shift <- national[, .(
  year,
  n_operators = n_elevator_ops,
  pct_female,
  pct_black,
  pct_other_race,
  pct_under20,
  pct_20s,
  pct_30s,
  pct_40s,
  pct_50s,
  pct_60plus,
  mean_age = mean_age_elev
)]
cat("  Demographic composition over time:\n")
print(demo_shift)
fwrite(demo_shift, file.path(DATA_DIR, "demographic_composition_shift.csv"))

# ─────────────────────────────────────────────────────────────────────────────
# PART II: SCM — Supporting Evidence (Compressed)
# The paradox: NYC (strike epicenter) RETAINED operators longer
# ─────────────────────────────────────────────────────────────────────────────

cat("\n═══════════════════════════════════════════\n")
cat("PART II: Synthetic Control (Supporting Evidence)\n")
cat("═══════════════════════════════════════════\n\n")

nyc_statefip <- 36L

# Filter donors
donor_states <- scm_panel[STATEFIP != nyc_statefip &
                           !is.na(elev_per_1k_bldg),
                          .(n_yr = uniqueN(year)), by = STATEFIP]
donor_states <- donor_states[n_yr == 6]$STATEFIP

cat(sprintf("  Treatment: New York State (STATEFIP = %d)\n", nyc_statefip))
cat(sprintf("  Donor pool: %d states\n", length(donor_states)))

scm_df <- as.data.frame(scm_panel[STATEFIP %in% c(nyc_statefip, donor_states)])

tryCatch({
  dp <- dataprep(
    foo = scm_df,
    predictors = c("log_pop", "mfg_share", "foreign_share"),
    predictors.op = "mean",
    time.predictors.prior = c(1900, 1910, 1920, 1930, 1940),
    special.predictors = list(
      list("elev_per_1k_bldg", 1900, "mean"),
      list("elev_per_1k_bldg", 1910, "mean"),
      list("elev_per_1k_bldg", 1920, "mean"),
      list("elev_per_1k_bldg", 1930, "mean"),
      list("elev_per_1k_bldg", 1940, "mean")
    ),
    dependent = "elev_per_1k_bldg",
    unit.variable = "STATEFIP",
    time.variable = "year",
    treatment.identifier = nyc_statefip,
    controls.identifier = donor_states,
    time.optimize.ssr = c(1900, 1910, 1920, 1930, 1940),
    time.plot = c(1900, 1910, 1920, 1930, 1940, 1950)
  )

  synth_out <- synth(dp, optimxmethod = "Nelder-Mead")
  synth_tables <- synth.tab(synth_out, dp)

  cat("\n  SCM Weights (top donors):\n")
  weights_df <- data.frame(
    STATEFIP = as.integer(rownames(synth_tables$tab.w)),
    weight = round(synth_tables$tab.w[, 1], 4)
  )
  sl <- as.data.frame(scm_panel[, .(state_name = first(state_name)), by = STATEFIP])
  weights_df <- merge(weights_df, sl, by = "STATEFIP", all.x = TRUE)
  weights_df <- weights_df[order(-weights_df$weight), ]
  print(head(weights_df[weights_df$weight > 0.01, ], 10))

  gap <- dp$Y1plot - (dp$Y0plot %*% synth_out$solution.w)
  gap_df <- data.frame(
    year = c(1900, 1910, 1920, 1930, 1940, 1950),
    nyc_actual = as.numeric(dp$Y1plot),
    nyc_synthetic = as.numeric(dp$Y0plot %*% synth_out$solution.w),
    gap = as.numeric(gap)
  )
  cat("\n  NY vs Synthetic NY (elev per 1k bldg service):\n")
  print(gap_df)

  saveRDS(list(
    synth_out = synth_out, dataprep = dp, tables = synth_tables,
    gap = gap_df, weights = weights_df
  ), file.path(DATA_DIR, "scm_results.rds"))

}, error = function(e) {
  cat(sprintf("  SCM ERROR: %s\n", e$message))
  comparison_states <- c(17, 42, 25, 6, 26, 39, 34, 11, 24)
  did_panel <- scm_panel[STATEFIP %in% c(nyc_statefip, comparison_states)]
  did_reg <- feols(elev_per_1k_bldg ~ is_nyc:post | STATEFIP + year,
                   data = did_panel, cluster = ~STATEFIP)
  print(summary(did_reg))
  saveRDS(list(did_reg = did_reg, comparison = comparison_states),
          file.path(DATA_DIR, "scm_results.rds"))
})

# Permutation inference
cat("\nPermutation inference...\n")
scm_df_all <- as.data.frame(scm_panel[STATEFIP %in% c(nyc_statefip, donor_states)])
placebo_gaps <- list()
n_placebos <- min(20, length(donor_states))
placebo_states <- head(donor_states, n_placebos)

for (i in seq_along(placebo_states)) {
  p_state <- placebo_states[i]
  p_donors <- setdiff(donor_states, p_state)
  tryCatch({
    dp_p <- dataprep(
      foo = scm_df_all[scm_df_all$STATEFIP %in% c(p_state, p_donors), ],
      predictors = c("log_pop", "mfg_share", "foreign_share"),
      predictors.op = "mean",
      time.predictors.prior = c(1900, 1910, 1920, 1930, 1940),
      special.predictors = list(
        list("elev_per_1k_bldg", 1900, "mean"),
        list("elev_per_1k_bldg", 1920, "mean"),
        list("elev_per_1k_bldg", 1940, "mean")
      ),
      dependent = "elev_per_1k_bldg",
      unit.variable = "STATEFIP",
      time.variable = "year",
      treatment.identifier = p_state,
      controls.identifier = p_donors,
      time.optimize.ssr = c(1900, 1910, 1920, 1930, 1940),
      time.plot = c(1900, 1910, 1920, 1930, 1940, 1950)
    )
    synth_p <- synth(dp_p, optimxmethod = "Nelder-Mead")
    gap_p <- dp_p$Y1plot - (dp_p$Y0plot %*% synth_p$solution.w)
    state_nm <- scm_panel[STATEFIP == p_state, first(state_name)]
    placebo_gaps[[as.character(p_state)]] <- data.frame(
      STATEFIP = p_state, state_name = state_nm,
      year = c(1900, 1910, 1920, 1930, 1940, 1950),
      gap = as.numeric(gap_p)
    )
    cat(sprintf("  Placebo %d/%d (%s): gap_1950 = %.2f\n",
        i, n_placebos, state_nm, gap_p[length(gap_p)]))
  }, error = function(e) {
    cat(sprintf("  Placebo %d/%d FAILED: %s\n", i, n_placebos, e$message))
  })
}

if (length(placebo_gaps) > 0) {
  placebo_df <- rbindlist(placebo_gaps)
  fwrite(placebo_df, file.path(DATA_DIR, "placebo_gaps.csv"))
  if (file.exists(file.path(DATA_DIR, "scm_results.rds"))) {
    scm_res <- readRDS(file.path(DATA_DIR, "scm_results.rds"))
    if ("gap" %in% names(scm_res)) {
      nyc_gap_1950 <- scm_res$gap$gap[scm_res$gap$year == 1950]
      placebo_1950 <- placebo_df[year == 1950]$gap
      p_value <- mean(abs(placebo_1950) >= abs(nyc_gap_1950))
      cat(sprintf("\n  NY gap (1950): %.2f\n", nyc_gap_1950))
      cat(sprintf("  Placebo p-value: %.3f (%d placebos)\n", p_value, length(placebo_1950)))
      scm_res$p_value <- p_value
      scm_res$n_placebos <- length(placebo_1950)
      saveRDS(scm_res, file.path(DATA_DIR, "scm_results.rds"))
    }
  }
}

# Save all regressions
regs <- list(
  stay = reg_stay, move = reg_move, occ = reg_occ,
  race = reg_race, sex = reg_sex, nyc = reg_nyc,
  nyc_stay = reg_nyc_stay, nyc_occ = reg_nyc_occ,
  nyc_race = reg_nyc_race
)
saveRDS(regs, file.path(DATA_DIR, "displacement_regs.rds"))

# Save logit separately
saveRDS(logit_persist, file.path(DATA_DIR, "selection_logit.rds"))

cat("\n========================================\n")
cat("MAIN ANALYSIS COMPLETE\n")
cat("========================================\n")
