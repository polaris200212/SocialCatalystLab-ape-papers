###############################################################################
# 03_main_analysis.R — Primary difference-in-differences estimation
# The Unequal Legacies of the Tennessee Valley Authority
# APEP-0470
###############################################################################

source("code/00_packages.R")

# ── Load data ────────────────────────────────────────────────────────────────
has_individual <- file.exists(paste0(data_dir, "individual_panel_30_40.csv"))
has_county <- file.exists(paste0(data_dir, "county_panel.csv"))

if (has_individual) {
  panel <- fread(paste0(data_dir, "individual_panel_30_40.csv"))
  cat("✓ Individual panel loaded:", format(nrow(panel), big.mark = ","), "obs\n")
} else if (has_county) {
  panel <- fread(paste0(data_dir, "county_panel.csv"))
  cat("✓ County panel loaded:", format(nrow(panel), big.mark = ","), "obs\n")
} else {
  stop("No panel data found. Run 02_clean_data.R first.")
}

results <- list()

# ═══════════════════════════════════════════════════════════════════════════════
# PART A: COUNTY-LEVEL DiD (AGGREGATE ANALYSIS)
# ═══════════════════════════════════════════════════════════════════════════════

if (has_county) {
  cp <- fread(paste0(data_dir, "county_panel.csv"))
  cp[is.na(tva_any), tva_any := FALSE]
  cp[is.na(tva_core), tva_core := FALSE]
  cp[, tva := as.integer(tva_any)]
  cp[, post := as.integer(year == 1940)]

  cat("\n══════════════════════════════════════════════════\n")
  cat("PART A: COUNTY-LEVEL DiD\n")
  cat("══════════════════════════════════════════════════\n")

  # ── A1. Main DiD: TVA effect on manufacturing share ──────────────────────
  # Y_{ct} = α_c + γ_t + β(TVA_c × Post_t) + ε_{ct}
  a1_mfg <- feols(pct_mfg ~ tva_post | county_id + year,
                  data = cp, cluster = ~statefip)

  a1_ag <- feols(pct_ag ~ tva_post | county_id + year,
                 data = cp, cluster = ~statefip)

  a1_sei <- feols(mean_sei ~ tva_post | county_id + year,
                  data = cp, cluster = ~statefip)

  a1_lf <- feols(pct_lf ~ tva_post | county_id + year,
                 data = cp, cluster = ~statefip)

  a1_home <- feols(pct_owns_home ~ tva_post | county_id + year,
                   data = cp, cluster = ~statefip)

  results$a1_main <- list(mfg = a1_mfg, ag = a1_ag, sei = a1_sei,
                           lf = a1_lf, home = a1_home)

  cat("\n── A1: Main DiD Results ──\n")
  cat("Manufacturing share: β =", round(coef(a1_mfg), 4),
      " SE =", round(se(a1_mfg), 4), "\n")
  cat("Agriculture share:   β =", round(coef(a1_ag), 4),
      " SE =", round(se(a1_ag), 4), "\n")
  cat("Mean SEI score:      β =", round(coef(a1_sei), 4),
      " SE =", round(se(a1_sei), 4), "\n")

  # ── A2. Distance gradient ────────────────────────────────────────────────
  # Effect decays with distance to nearest TVA dam
  # Y_{ct} = α_c + γ_t + β₁(Post_t × log_dist_dam_c) + ε_{ct}
  # Restrict to TVA states for within-state comparison

  cp_tva_states <- cp[statefip %in% c(1, 13, 21, 28, 37, 47, 51)]

  a2_gradient_mfg <- feols(pct_mfg ~ post:log_dist_dam | county_id + year,
                           data = cp_tva_states, cluster = ~statefip)

  a2_gradient_sei <- feols(mean_sei ~ post:log_dist_dam | county_id + year,
                           data = cp_tva_states, cluster = ~statefip)

  a2_gradient_ag <- feols(pct_ag ~ post:log_dist_dam | county_id + year,
                          data = cp_tva_states, cluster = ~statefip)

  results$a2_gradient <- list(mfg = a2_gradient_mfg, sei = a2_gradient_sei,
                               ag = a2_gradient_ag)

  cat("\n── A2: Distance Gradient ──\n")
  cat("Mfg × log(dist): β =", round(coef(a2_gradient_mfg), 4),
      " (expect negative: closer to dam = more mfg)\n")

  # ── A3. Border-county subsample ──────────────────────────────────────────
  # Tightest comparison: adjacent counties on either side of TVA boundary
  cp_border <- cp[tva_core == TRUE | border_control == TRUE]

  a3_border_mfg <- feols(pct_mfg ~ tva_post | county_id + year,
                         data = cp_border, cluster = ~statefip)

  a3_border_sei <- feols(mean_sei ~ tva_post | county_id + year,
                         data = cp_border, cluster = ~statefip)

  results$a3_border <- list(mfg = a3_border_mfg, sei = a3_border_sei)

  cat("\n── A3: Border County DiD ──\n")
  cat("Mfg (border): β =", round(coef(a3_border_mfg), 4),
      " SE =", round(se(a3_border_mfg), 4), "\n")

  # ── A4. Race × TVA interaction ───────────────────────────────────────────
  # Triple difference: does TVA differentially affect Black vs White residents?

  # Reshape to race-specific outcomes in long form
  cp_race <- rbind(
    cp[, .(county_id, statefip, year, post, tva, tva_post, log_dist_dam,
           tva_any, border_control,
           race = "White", pct_mfg = pct_mfg_white, sei = sei_white)],
    cp[, .(county_id, statefip, year, post, tva, tva_post, log_dist_dam,
           tva_any, border_control,
           race = "Black", pct_mfg = pct_mfg_black, sei = sei_black)]
  )
  cp_race[, black := as.integer(race == "Black")]
  cp_race[, tva_post_black := tva_post * black]
  cp_race[, county_race := paste0(county_id, "_", race)]

  a4_race_sei <- feols(sei ~ tva_post + tva_post_black | county_race + year,
                       data = cp_race, cluster = ~statefip)

  a4_race_mfg <- feols(pct_mfg ~ tva_post + tva_post_black | county_race + year,
                       data = cp_race, cluster = ~statefip)

  results$a4_race <- list(sei = a4_race_sei, mfg = a4_race_mfg)

  cat("\n── A4: Race × TVA Interaction ──\n")
  cat("SEI (TVA×Post):       β =", round(coef(a4_race_sei)["tva_post"], 4), "\n")
  cat("SEI (TVA×Post×Black): β =", round(coef(a4_race_sei)["tva_post_black"], 4), "\n")

  # ── A5. Gender × TVA interaction ─────────────────────────────────────────
  cp_gender <- rbind(
    cp[, .(county_id, statefip, year, post, tva, tva_post, log_dist_dam,
           tva_any, border_control,
           gender = "Male", pct_lf = pct_lf_male, sei = sei_male)],
    cp[, .(county_id, statefip, year, post, tva, tva_post, log_dist_dam,
           tva_any, border_control,
           gender = "Female", pct_lf = pct_lf_female, sei = sei_female)]
  )
  cp_gender[, female := as.integer(gender == "Female")]
  cp_gender[, tva_post_female := tva_post * female]
  cp_gender[, county_gender := paste0(county_id, "_", gender)]

  a5_gender_lf <- feols(pct_lf ~ tva_post + tva_post_female | county_gender + year,
                        data = cp_gender, cluster = ~statefip)

  a5_gender_sei <- feols(sei ~ tva_post + tva_post_female | county_gender + year,
                         data = cp_gender, cluster = ~statefip)

  results$a5_gender <- list(lf = a5_gender_lf, sei = a5_gender_sei)

  cat("\n── A5: Gender × TVA Interaction ──\n")
  cat("LFP (TVA×Post):         β =", round(coef(a5_gender_lf)["tva_post"], 4), "\n")
  cat("LFP (TVA×Post×Female):  β =", round(coef(a5_gender_lf)["tva_post_female"], 4), "\n")
}

# ═══════════════════════════════════════════════════════════════════════════════
# PART B: INDIVIDUAL-LEVEL DiD (IF MLP LINKED PANEL AVAILABLE)
# ═══════════════════════════════════════════════════════════════════════════════

if (has_individual) {
  ip <- fread(paste0(data_dir, "individual_panel_30_40.csv"))

  cat("\n══════════════════════════════════════════════════\n")
  cat("PART B: INDIVIDUAL-LEVEL DiD\n")
  cat("══════════════════════════════════════════════════\n")

  # ── B1. Main individual-level DiD ──────────────────────────────────────
  # Change in outcomes 1930→1940 as function of TVA exposure
  # ΔY_i = α + β(TVA_c) + X_i'δ + ε_i

  b1_sei <- feols(delta_sei ~ tva_1930 + age_1930 + I(age_1930^2) |
                    statefip_1930,
                  data = ip, cluster = ~statefip_1930)

  b1_mfg <- feols(entered_mfg ~ tva_1930 + age_1930 + I(age_1930^2) |
                    statefip_1930,
                  data = ip, cluster = ~statefip_1930)

  b1_left_ag <- feols(left_ag ~ tva_1930 + age_1930 + I(age_1930^2) |
                       statefip_1930,
                      data = ip[in_ag_1930 == 1], cluster = ~statefip_1930)

  results$b1_main <- list(sei = b1_sei, mfg = b1_mfg, left_ag = b1_left_ag)

  cat("SEI change (TVA): β =", round(coef(b1_sei)["tva_1930"], 4), "\n")
  cat("Entered mfg (TVA): β =", round(coef(b1_mfg)["tva_1930"], 4), "\n")

  # ── B2. Individual distance gradient ─────────────────────────────────────
  ip[, log_dist := log(dist_dam_1930 + 1)]

  b2_sei <- feols(delta_sei ~ log_dist + age_1930 + I(age_1930^2) |
                    statefip_1930,
                  data = ip, cluster = ~statefip_1930)

  b2_mfg <- feols(entered_mfg ~ log_dist + age_1930 + I(age_1930^2) |
                    statefip_1930,
                  data = ip, cluster = ~statefip_1930)

  results$b2_gradient <- list(sei = b2_sei, mfg = b2_mfg)

  # ── B3. Race × TVA at the individual level ───────────────────────────────
  b3_sei <- feols(delta_sei ~ tva_1930 * black + age_1930 + I(age_1930^2) |
                    statefip_1930,
                  data = ip, cluster = ~statefip_1930)

  b3_mfg <- feols(entered_mfg ~ tva_1930 * black + age_1930 + I(age_1930^2) |
                    statefip_1930,
                  data = ip, cluster = ~statefip_1930)

  b3_wage <- feols(log_wage_1940 ~ tva_1930 * black + age_1930 + I(age_1930^2) +
                     sei_1930 | statefip_1930,
                   data = ip[!is.na(log_wage_1940)], cluster = ~statefip_1930)

  results$b3_race <- list(sei = b3_sei, mfg = b3_mfg, wage = b3_wage)

  cat("\n── B3: Race × TVA (Individual) ──\n")
  cat("SEI (TVA):          β =", round(coef(b3_sei)["tva_1930"], 4), "\n")
  cat("SEI (TVA × Black):  β =", round(coef(b3_sei)["tva_1930:black"], 4), "\n")

  # ── B4. Gender × TVA at the individual level ─────────────────────────────
  b4_lf <- feols(in_lf_1940 ~ tva_1930 * female + age_1930 + I(age_1930^2) |
                   statefip_1930,
                 data = ip, cluster = ~statefip_1930)

  b4_sei <- feols(delta_sei ~ tva_1930 * female + age_1930 + I(age_1930^2) |
                    statefip_1930,
                  data = ip, cluster = ~statefip_1930)

  results$b4_gender <- list(lf = b4_lf, sei = b4_sei)

  cat("\n── B4: Gender × TVA (Individual) ──\n")
  cat("LFP (TVA):           β =", round(coef(b4_lf)["tva_1930"], 4), "\n")
  cat("LFP (TVA × Female):  β =", round(coef(b4_lf)["tva_1930:female"], 4), "\n")

  # ── B5. Four-way heterogeneity: Race × Gender × TVA ──────────────────────
  ip[, race_gender := paste0(fifelse(black == 1, "Black", "White"), " ",
                              fifelse(female == 1, "Women", "Men"))]

  b5_sei_wm <- feols(delta_sei ~ tva_1930 + age_1930 | statefip_1930,
                     data = ip[white == 1 & female == 0], cluster = ~statefip_1930)
  b5_sei_wf <- feols(delta_sei ~ tva_1930 + age_1930 | statefip_1930,
                     data = ip[white == 1 & female == 1], cluster = ~statefip_1930)
  b5_sei_bm <- feols(delta_sei ~ tva_1930 + age_1930 | statefip_1930,
                     data = ip[black == 1 & female == 0], cluster = ~statefip_1930)
  b5_sei_bf <- feols(delta_sei ~ tva_1930 + age_1930 | statefip_1930,
                     data = ip[black == 1 & female == 1], cluster = ~statefip_1930)

  results$b5_four_way <- list(
    white_men = b5_sei_wm, white_women = b5_sei_wf,
    black_men = b5_sei_bm, black_women = b5_sei_bf
  )

  cat("\n── B5: Four-Way Heterogeneity (SEI change) ──\n")
  cat("White Men:   β =", round(coef(b5_sei_wm)["tva_1930"], 4), "\n")
  cat("White Women: β =", round(coef(b5_sei_wf)["tva_1930"], 4), "\n")
  cat("Black Men:   β =", round(coef(b5_sei_bm)["tva_1930"], 4), "\n")
  cat("Black Women: β =", round(coef(b5_sei_bf)["tva_1930"], 4), "\n")

  # ── B6. Migration decomposition ──────────────────────────────────────────
  # Stayers in TVA vs stayers in non-TVA
  b6_stayers <- feols(delta_sei ~ tva_1930 + age_1930 | statefip_1930,
                      data = ip[mover == 0], cluster = ~statefip_1930)

  # Did TVA increase out-migration for Black residents?
  b6_outmig <- feols(mover ~ tva_1930 * black + age_1930 | statefip_1930,
                     data = ip, cluster = ~statefip_1930)

  results$b6_migration <- list(stayers = b6_stayers, outmig = b6_outmig)

  cat("\n── B6: Migration ──\n")
  cat("SEI (stayers, TVA): β =", round(coef(b6_stayers)["tva_1930"], 4), "\n")
  cat("Out-migration (TVA × Black): β =",
      round(coef(b6_outmig)["tva_1930:black"], 4), "\n")
}

# ── Save all results ─────────────────────────────────────────────────────────
saveRDS(results, paste0(data_dir, "main_results.rds"))
cat("\n✓ All main analysis results saved to data/main_results.rds\n")
