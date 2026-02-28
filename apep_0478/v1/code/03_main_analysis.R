# =============================================================================
# 03_main_analysis.R — Going Up Alone (apep_0478)
# Primary SCM analysis + individual displacement regressions
# =============================================================================

source("00_packages.R")

cat("\n========================================\n")
cat("MAIN ANALYSIS\n")
cat("========================================\n\n")

# Load clean data
scm_panel   <- fread(file.path(DATA_DIR, "scm_panel.csv"))
linked      <- fread(file.path(DATA_DIR, "linked_panel_clean.csv"))
national    <- fread(file.path(DATA_DIR, "national_clean.csv"))

# ─────────────────────────────────────────────────────────────────────────────
# PART II: SCM — New York State vs Synthetic New York
# Using states as units. NY state had 34% of all US elevator operators,
# overwhelmingly concentrated in NYC. The 1945 strike was a NYC-specific shock.
# ─────────────────────────────────────────────────────────────────────────────

cat("Part II: Synthetic Control Method\n")
cat("─────────────────────────────────\n\n")

# State IDs for Synth package (needs numeric IDs)
nyc_statefip <- 36L

# Filter donors: states with complete data and some operators
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
  # Add state names
  sl <- as.data.frame(scm_panel[, .(state_name = first(state_name)), by = STATEFIP])
  weights_df <- merge(weights_df, sl, by = "STATEFIP", all.x = TRUE)
  weights_df <- weights_df[order(-weights_df$weight), ]
  print(head(weights_df[weights_df$weight > 0.01, ], 10))

  cat("\n  Predictor Balance:\n")
  print(synth_tables$tab.pred)

  # Extract gap
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

  cat("\n  SCM results saved.\n")

}, error = function(e) {
  cat(sprintf("  SCM ERROR: %s\n", e$message))
  cat("  Falling back to DiD...\n")

  # Comparison states with large elevator operator populations
  comparison_states <- c(17, 42, 25, 6, 26, 39, 34, 11, 24)  # IL PA MA CA MI OH NJ DC MD
  did_panel <- scm_panel[STATEFIP %in% c(nyc_statefip, comparison_states)]

  did_reg <- feols(elev_per_1k_bldg ~ is_nyc:post | STATEFIP + year,
                   data = did_panel, cluster = ~STATEFIP)
  cat("\n  DiD Results (fallback):\n")
  print(summary(did_reg))

  saveRDS(list(did_reg = did_reg, comparison = comparison_states),
          file.path(DATA_DIR, "scm_results.rds"))
})

# ─────────────────────────────────────────────────────────────────────────────
# PART II-b: Permutation inference (placebo-in-space)
# ─────────────────────────────────────────────────────────────────────────────

cat("\nPart II-b: Permutation inference...\n")

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

# ─────────────────────────────────────────────────────────────────────────────
# PART II-c: Augmented SCM
# ─────────────────────────────────────────────────────────────────────────────

cat("\nPart II-c: Augmented SCM...\n")

tryCatch({
  ascm_panel <- scm_panel[STATEFIP %in% c(nyc_statefip, donor_states)]
  ascm_panel[, treated_post := as.integer(is_nyc & year >= 1950)]

  ascm <- augsynth(
    elev_per_1k_bldg ~ treated_post,
    unit = STATEFIP,
    time = year,
    data = as.data.frame(ascm_panel),
    progfunc = "Ridge",
    scm = TRUE
  )

  cat("  Augmented SCM summary:\n")
  print(summary(ascm))
  saveRDS(ascm, file.path(DATA_DIR, "ascm_results.rds"))

}, error = function(e) {
  cat(sprintf("  ASCM ERROR: %s\n", e$message))
})

# ─────────────────────────────────────────────────────────────────────────────
# PART III: Individual displacement analysis
# ─────────────────────────────────────────────────────────────────────────────

cat("\nPart III: Individual displacement regressions\n")
cat("──────────────────────────────────────────────\n\n")

# Reg 1: Occupational persistence
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

# Reg 4: Heterogeneity by race
cat("\n  Regression 4: Heterogeneity by race\n")
reg_race <- feols(
  stayed_same_occ ~ is_elevator_1940 * is_black |
    statefip_1940 + sex_1940 + age_group_1940,
  data = linked, cluster = ~statefip_1940
)
print(summary(reg_race))

# Reg 5: Heterogeneity by sex
cat("\n  Regression 5: Heterogeneity by sex\n")
reg_sex <- feols(
  stayed_same_occ ~ is_elevator_1940 * is_female |
    statefip_1940 + race_1940 + age_group_1940,
  data = linked, cluster = ~statefip_1940
)
print(summary(reg_sex))

# Reg 6: NYC vs other
cat("\n  Regression 6: NYC vs other\n")
reg_nyc <- feols(
  stayed_same_occ ~ is_elevator_1940 * is_nyc_1940 |
    race_1940 + sex_1940 + age_group_1940,
  data = linked, cluster = ~statefip_1940
)
print(summary(reg_nyc))

# Save
regs <- list(stay = reg_stay, move = reg_move, occ = reg_occ,
             race = reg_race, sex = reg_sex, nyc = reg_nyc)
saveRDS(regs, file.path(DATA_DIR, "displacement_regs.rds"))

cat("\n========================================\n")
cat("MAIN ANALYSIS COMPLETE\n")
cat("========================================\n")
