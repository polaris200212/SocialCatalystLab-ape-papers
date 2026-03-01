# =============================================================================
# 03_main_analysis.R — Going Up Alone v4 (apep_0478)
# v4: Individual transitions as backbone, entry analysis, borough-level,
#     county-level exit rates. SCM demoted to appendix.
# =============================================================================

source("00_packages.R")

cat("\n========================================\n")
cat("MAIN ANALYSIS (v4)\n")
cat("========================================\n\n")

# Load clean data
scm_panel   <- fread(file.path(DATA_DIR, "scm_panel.csv"))
linked      <- fread(file.path(DATA_DIR, "linked_panel_clean.csv"))
national    <- fread(file.path(DATA_DIR, "national_clean.csv"))

# ═══════════════════════════════════════════════════════════════════════════════
# PART I: INDIVIDUAL-LEVEL DISPLACEMENT ANALYSIS (CORE)
# ═══════════════════════════════════════════════════════════════════════════════

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

# NYC persistence regression
cat("\n  NYC effect on persistence:\n")
reg_nyc_stay <- feols(
  still_elevator_1950 ~ is_nyc_1940 |
    race_1940 + sex_1940 + age_group_1940,
  data = elev_1940, cluster = ~statefip_1940
)
print(summary(reg_nyc_stay))

# NYC OCCSCORE regression
cat("\n  NYC effect on OCCSCORE change:\n")
reg_nyc_occ <- feols(
  occscore_change ~ is_nyc_1940 |
    race_1940 + sex_1940 + age_group_1940,
  data = elev_1940, cluster = ~statefip_1940
)
print(summary(reg_nyc_occ))

# NYC × race interaction
cat("\n  NYC × race interaction:\n")
reg_nyc_race <- feols(
  still_elevator_1950 ~ is_nyc_1940 * is_black |
    sex_1940 + age_group_1940,
  data = elev_1940, cluster = ~statefip_1940
)
print(summary(reg_nyc_race))

# NYC transition matrix
trans_by_nyc <- elev_1940[, .N, by = .(is_nyc_1940, occ_broad_1950)]
trans_by_nyc[, pct := N / sum(N) * 100, by = is_nyc_1940]
fwrite(trans_by_nyc, file.path(DATA_DIR, "transition_by_nyc_detail.csv"))

# ─── 1c: Borough-level analysis (v4 new) ─────────────────────────────────────

cat("\n--- 1c: Borough-level analysis ---\n")

if ("borough_1940" %in% names(elev_1940)) {
  borough_summary <- elev_1940[!is.na(borough_1940), .(
    n = .N,
    exit_rate = mean(still_elevator_1950 == 0),
    mean_occscore_change = mean(occscore_change, na.rm = TRUE),
    pct_black = mean(is_black) * 100,
    pct_female = mean(is_female) * 100,
    mean_age = mean(age_1940),
    pct_upward = mean(occscore_change > 0, na.rm = TRUE) * 100
  ), by = borough_1940]
  setorder(borough_summary, exit_rate)
  cat("  Borough-level displacement:\n")
  print(borough_summary)
  fwrite(borough_summary, file.path(DATA_DIR, "borough_displacement.csv"))
}

# ─── 1d: Occupational Ladder / Destination Quality ───────────────────────────

cat("\n--- 1d: Occupational destination quality ---\n")

exiters <- elev_1940[still_elevator_1950 == 0 & occ1950_1950 > 0 & occ1950_1950 < 980]
cat(sprintf("  Exiters with valid 1950 occupation: %s\n",
    format(nrow(exiters), big.mark = ",")))

# Classify transitions
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

dest_quality <- exiters[, .(
  n = .N,
  mean_occscore_1940 = mean(occscore_1940),
  mean_occscore_1950 = mean(occscore_1950),
  mean_change = mean(occscore_change),
  pct_upward = mean(occscore_change > 0) * 100
), by = occ_broad_1950]
setorder(dest_quality, -n)
fwrite(dest_quality, file.path(DATA_DIR, "destination_quality.csv"))

# ─── 1e: Selection into Persistence ──────────────────────────────────────────

cat("\n--- 1e: Selection into persistence (who stays?) ---\n")

elev_1940[, age_centered := age_1940 - median(age_1940)]
elev_1940[, age_centered_sq := age_centered^2]
elev_1940[, is_married := as.integer(marst_1940 %in% c(1, 2))]

logit_persist <- glm(
  still_elevator_1950 ~ age_centered + age_centered_sq +
    is_black + is_female + is_native + is_married + is_nyc_1940,
  data = elev_1940, family = binomial(link = "logit")
)
cat("\n  Logit: Selection into persistence\n")
print(summary(logit_persist))

beta <- coef(logit_persist)
p_hat <- predict(logit_persist, type = "response")
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
fwrite(ame_df, file.path(DATA_DIR, "selection_logit_ame.csv"))

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
fwrite(stayer_leaver, file.path(DATA_DIR, "stayer_leaver_comparison.csv"))

# ─── 1f: Heterogeneity Regressions ───────────────────────────────────────────

cat("\n--- 1f: Heterogeneity regressions ---\n")

reg_race <- feols(
  stayed_same_occ ~ is_elevator_1940 * is_black |
    statefip_1940 + sex_1940 + age_group_1940,
  data = linked, cluster = ~statefip_1940
)

reg_sex <- feols(
  stayed_same_occ ~ is_elevator_1940 * is_female |
    statefip_1940 + race_1940 + age_group_1940,
  data = linked, cluster = ~statefip_1940
)

reg_nyc <- feols(
  stayed_same_occ ~ is_elevator_1940 * is_nyc_1940 |
    race_1940 + sex_1940 + age_group_1940,
  data = linked, cluster = ~statefip_1940
)

# ─── 1g: Entry Analysis (v4 new) ─────────────────────────────────────────────

cat("\n--- 1g: Entry analysis ---\n")

entrants_file <- file.path(DATA_DIR, "entrants_1940_1950.csv")
if (file.exists(entrants_file)) {
  entrants <- fread(entrants_file)
  cat(sprintf("  Entrants (1940→1950): %s\n", format(nrow(entrants), big.mark = ",")))

  entrants[, `:=`(
    is_female = as.integer(sex_1940 == 2),
    is_black = as.integer(race_1940 == 2),
    is_nyc = as.integer(statefip_1940 == 36 & countyicp_1940 %in% NYC_COUNTYICP)
  )]

  # Compare entry vs exit: is the occupation becoming a "last resort"?
  entry_vs_exit <- data.table(
    group = c("Exiters (1940 elev → other)", "Entrants (other → 1950 elev)"),
    n = c(nrow(elev_1940[still_elevator_1950 == 0]),
          nrow(entrants)),
    pct_black = c(mean(elev_1940[still_elevator_1950 == 0]$is_black) * 100,
                  mean(entrants$is_black) * 100),
    pct_female = c(mean(elev_1940[still_elevator_1950 == 0]$is_female) * 100,
                   mean(entrants$is_female) * 100),
    mean_age = c(mean(elev_1940[still_elevator_1950 == 0]$age_1940),
                 mean(entrants$age_1940))
  )
  cat("  Entry vs Exit demographics:\n")
  print(entry_vs_exit)
  fwrite(entry_vs_exit, file.path(DATA_DIR, "entry_vs_exit.csv"))
}

# ─── 1h: Demographic Composition Shift (Cross-Sectional) ─────────────────────

cat("\n--- 1h: Demographic composition shift ---\n")

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
fwrite(demo_shift, file.path(DATA_DIR, "demographic_composition_shift.csv"))

# ═══════════════════════════════════════════════════════════════════════════════
# PART II: SCM — Appendix Evidence
# ═══════════════════════════════════════════════════════════════════════════════

cat("\n═══════════════════════════════════════════\n")
cat("PART II: Synthetic Control (Appendix)\n")
cat("═══════════════════════════════════════════\n\n")

# Load Synth library only for this section
library(Synth)

nyc_statefip <- 36L

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

  weights_df <- data.frame(
    STATEFIP = as.integer(rownames(synth_tables$tab.w)),
    weight = round(synth_tables$tab.w[, 1], 4)
  )

  gap <- dp$Y1plot - (dp$Y0plot %*% synth_out$solution.w)
  gap_df <- data.frame(
    year = c(1900, 1910, 1920, 1930, 1940, 1950),
    nyc_actual = as.numeric(dp$Y1plot),
    nyc_synthetic = as.numeric(dp$Y0plot %*% synth_out$solution.w),
    gap = as.numeric(gap)
  )

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
saveRDS(logit_persist, file.path(DATA_DIR, "selection_logit.rds"))

cat("\n========================================\n")
cat("MAIN ANALYSIS COMPLETE\n")
cat("========================================\n")
