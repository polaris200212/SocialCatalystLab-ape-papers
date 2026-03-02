## ═══════════════════════════════════════════════════════════════════════════
## 03_main_analysis.R — Primary regressions
## Paper: Does Piped Water Build Human Capital? Evidence from India's JJM
## ═══════════════════════════════════════════════════════════════════════════

script_dir <- dirname(sys.frame(1)$ofile %||% ".")
if (script_dir == ".") script_dir <- getwd()
source(file.path(script_dir, "00_packages.R"))
load(file.path(data_dir, "analysis_data.RData"))

cat("\n══════════════════════════════════════════════\n")
cat("MAIN ANALYSIS: Cross-district Bartik exposure design\n")
cat("══════════════════════════════════════════════\n\n")

cat("Analysis sample:", nrow(df_analysis), "districts\n")
cat("States:", length(unique(df_analysis$state_id)), "\n\n")

# ═══════════════════════════════════════════════════════════════════════════
# TABLE 1: FIRST STAGE — Water gap predicts water infrastructure improvement
# ═══════════════════════════════════════════════════════════════════════════

cat("═══ FIRST STAGE: Water gap → Δ Improved water ═══\n\n")

# (1) Bivariate
fs1 <- feols(d_improved_water ~ water_gap, data = df_analysis)

# (2) + State FE
fs2 <- feols(d_improved_water ~ water_gap | state_id, data = df_analysis)

# (3) + Census controls
fs3 <- feols(d_improved_water ~ water_gap + literacy_rate + pop_sc_share +
  pop_st_share + log_pop + child_share + agr_worker_share | state_id,
  data = df_analysis)

# (4) + Baseline sanitation and electricity controls
fs4 <- feols(d_improved_water ~ water_gap + literacy_rate + pop_sc_share +
  pop_st_share + log_pop + child_share + agr_worker_share +
  improved_sanitation_nfhs4 + hh_electricity_nfhs4 | state_id,
  data = df_analysis)

cat("First stage coefficients:\n")
cat("  (1) Bivariate:", round(coef(fs1)["water_gap"], 4), "\n")
cat("  (2) + State FE:", round(coef(fs2)["water_gap"], 4), "\n")
cat("  (3) + Controls:", round(coef(fs3)["water_gap"], 4), "\n")
cat("  (4) + Infrastructure:", round(coef(fs4)["water_gap"], 4), "\n")
cat("  Wald F (bivariate):", round(wald(fs1, "water_gap")$stat, 1), "\n")
cat("  Wald F (full spec):", round(wald(fs4, "water_gap")$stat, 1), "\n\n")

# ═══════════════════════════════════════════════════════════════════════════
# TABLE 2: REDUCED FORM — Water gap → Education outcomes
# ═══════════════════════════════════════════════════════════════════════════

cat("═══ REDUCED FORM: Water gap → Δ Education ═══\n\n")

# Panel A: Female school attendance
rf_school1 <- feols(d_fem_school_attend ~ water_gap, data = df_analysis)
rf_school2 <- feols(d_fem_school_attend ~ water_gap | state_id, data = df_analysis)
rf_school3 <- feols(d_fem_school_attend ~ water_gap + literacy_rate + pop_sc_share +
  pop_st_share + log_pop + child_share + agr_worker_share | state_id,
  data = df_analysis)
rf_school4 <- feols(d_fem_school_attend ~ water_gap + literacy_rate + pop_sc_share +
  pop_st_share + log_pop + child_share + agr_worker_share +
  improved_sanitation_nfhs4 + hh_electricity_nfhs4 | state_id,
  data = df_analysis, cluster = ~state_id)

cat("Female school attendance:\n")
cat("  (1) Bivariate:", round(coef(rf_school1)["water_gap"], 4), "\n")
cat("  (2) + State FE:", round(coef(rf_school2)["water_gap"], 4), "\n")
cat("  (3) + Controls:", round(coef(rf_school3)["water_gap"], 4), "\n")
cat("  (4) + Infra + Cluster:", round(coef(rf_school4)["water_gap"], 4), "\n\n")

# Panel B: Women with 10+ years schooling
rf_10yr1 <- feols(d_women_10yr_school ~ water_gap | state_id, data = df_analysis)
rf_10yr2 <- feols(d_women_10yr_school ~ water_gap + literacy_rate + pop_sc_share +
  pop_st_share + log_pop + child_share + agr_worker_share +
  improved_sanitation_nfhs4 + hh_electricity_nfhs4 | state_id,
  data = df_analysis, cluster = ~state_id)

cat("Women 10+ years schooling:\n")
cat("  + State FE:", round(coef(rf_10yr1)["water_gap"], 4), "\n")
cat("  + Controls + Cluster:", round(coef(rf_10yr2)["water_gap"], 4), "\n\n")

# Panel C: Women literacy
rf_lit1 <- feols(d_women_literate ~ water_gap | state_id, data = df_analysis)
rf_lit2 <- feols(d_women_literate ~ water_gap + literacy_rate + pop_sc_share +
  pop_st_share + log_pop + child_share + agr_worker_share +
  improved_sanitation_nfhs4 + hh_electricity_nfhs4 | state_id,
  data = df_analysis, cluster = ~state_id)

cat("Women literacy:\n")
cat("  + State FE:", round(coef(rf_lit1)["water_gap"], 4), "\n")
cat("  + Controls + Cluster:", round(coef(rf_lit2)["water_gap"], 4), "\n\n")

# ═══════════════════════════════════════════════════════════════════════════
# TABLE 3: IV ESTIMATES — Δ Water → Δ Education (instrumented by water_gap)
# ═══════════════════════════════════════════════════════════════════════════

cat("═══ IV ESTIMATES: Δ Water → Δ Education ═══\n\n")

# Female school attendance
iv_school1 <- feols(d_fem_school_attend ~ 1 | state_id |
  d_improved_water ~ water_gap, data = df_analysis)
iv_school2 <- feols(d_fem_school_attend ~ literacy_rate + pop_sc_share +
  pop_st_share + log_pop + child_share + agr_worker_share | state_id |
  d_improved_water ~ water_gap, data = df_analysis)
iv_school3 <- feols(d_fem_school_attend ~ literacy_rate + pop_sc_share +
  pop_st_share + log_pop + child_share + agr_worker_share +
  improved_sanitation_nfhs4 + hh_electricity_nfhs4 | state_id |
  d_improved_water ~ water_gap, data = df_analysis, cluster = ~state_id)

cat("IV: Δ Water → Δ Female school attendance:\n")
cat("  (1) State FE:", round(coef(iv_school1)["fit_d_improved_water"], 4), "\n")
cat("  (2) + Controls:", round(coef(iv_school2)["fit_d_improved_water"], 4), "\n")
cat("  (3) + Infra + Cluster:", round(coef(iv_school3)["fit_d_improved_water"], 4), "\n")
cat("  First-stage F:", round(fitstat(iv_school3, "ivf")$ivf1$stat, 1), "\n\n")

# Women 10+ years schooling
iv_10yr <- feols(d_women_10yr_school ~ literacy_rate + pop_sc_share +
  pop_st_share + log_pop + child_share + agr_worker_share +
  improved_sanitation_nfhs4 + hh_electricity_nfhs4 | state_id |
  d_improved_water ~ water_gap, data = df_analysis, cluster = ~state_id)

cat("IV: Δ Water → Δ Women 10+ years schooling:", round(coef(iv_10yr)["fit_d_improved_water"], 4), "\n\n")

# ═══════════════════════════════════════════════════════════════════════════
# TABLE 4: HEALTH MECHANISM — Water gap → Child health
# ═══════════════════════════════════════════════════════════════════════════

cat("═══ HEALTH MECHANISM ═══\n\n")

controls_formula <- ~ water_gap + literacy_rate + pop_sc_share +
  pop_st_share + log_pop + child_share + agr_worker_share +
  improved_sanitation_nfhs4 + hh_electricity_nfhs4

# Diarrhea
rf_diarrhea <- feols(d_child_diarrhea ~ water_gap + literacy_rate + pop_sc_share +
  pop_st_share + log_pop + child_share + agr_worker_share +
  improved_sanitation_nfhs4 + hh_electricity_nfhs4 | state_id,
  data = df_analysis, cluster = ~state_id)

# Stunting
rf_stunted <- feols(d_child_stunted ~ water_gap + literacy_rate + pop_sc_share +
  pop_st_share + log_pop + child_share + agr_worker_share +
  improved_sanitation_nfhs4 + hh_electricity_nfhs4 | state_id,
  data = df_analysis, cluster = ~state_id)

# Underweight
rf_underweight <- feols(d_child_underweight ~ water_gap + literacy_rate + pop_sc_share +
  pop_st_share + log_pop + child_share + agr_worker_share +
  improved_sanitation_nfhs4 + hh_electricity_nfhs4 | state_id,
  data = df_analysis, cluster = ~state_id)

# Institutional births
rf_instbirth <- feols(d_inst_births ~ water_gap + literacy_rate + pop_sc_share +
  pop_st_share + log_pop + child_share + agr_worker_share +
  improved_sanitation_nfhs4 + hh_electricity_nfhs4 | state_id,
  data = df_analysis, cluster = ~state_id)

# ANC 4+ visits
rf_anc <- feols(d_anc_4visits ~ water_gap + literacy_rate + pop_sc_share +
  pop_st_share + log_pop + child_share + agr_worker_share +
  improved_sanitation_nfhs4 + hh_electricity_nfhs4 | state_id,
  data = df_analysis, cluster = ~state_id)

cat("Health outcomes (β on water_gap):\n")
cat("  Δ Diarrhea:", round(coef(rf_diarrhea)["water_gap"], 4),
    "p =", round(fixest::pvalue(rf_diarrhea)["water_gap"], 4), "\n")
cat("  Δ Stunting:", round(coef(rf_stunted)["water_gap"], 4),
    "p =", round(fixest::pvalue(rf_stunted)["water_gap"], 4), "\n")
cat("  Δ Underweight:", round(coef(rf_underweight)["water_gap"], 4),
    "p =", round(fixest::pvalue(rf_underweight)["water_gap"], 4), "\n")
cat("  Δ Institutional births:", round(coef(rf_instbirth)["water_gap"], 4),
    "p =", round(fixest::pvalue(rf_instbirth)["water_gap"], 4), "\n")
cat("  Δ ANC 4+ visits:", round(coef(rf_anc)["water_gap"], 4),
    "p =", round(fixest::pvalue(rf_anc)["water_gap"], 4), "\n\n")

# ═══════════════════════════════════════════════════════════════════════════
# TABLE 5: NIGHTLIGHTS — Economic development
# ═══════════════════════════════════════════════════════════════════════════

cat("═══ NIGHTLIGHTS OUTCOME ═══\n\n")

nl_sub <- df_analysis[!is.na(d_nightlights)]
cat("Districts with nightlights:", nrow(nl_sub), "\n")

rf_nl1 <- feols(d_nightlights ~ water_gap | state_id, data = nl_sub)
rf_nl2 <- feols(d_nightlights ~ water_gap + literacy_rate + pop_sc_share +
  pop_st_share + log_pop + child_share + agr_worker_share | state_id,
  data = nl_sub, cluster = ~state_id)
rf_nl_pct <- feols(d_nightlights_pct ~ water_gap + literacy_rate + pop_sc_share +
  pop_st_share + log_pop + child_share + agr_worker_share | state_id,
  data = nl_sub, cluster = ~state_id)

cat("Nightlights:\n")
cat("  Δ NL (level):", round(coef(rf_nl2)["water_gap"], 4),
    "p =", round(fixest::pvalue(rf_nl2)["water_gap"], 4), "\n")
cat("  Δ NL (% change):", round(coef(rf_nl_pct)["water_gap"], 4),
    "p =", round(fixest::pvalue(rf_nl_pct)["water_gap"], 4), "\n\n")

# ═══════════════════════════════════════════════════════════════════════════
# SAVE ALL RESULTS
# ═══════════════════════════════════════════════════════════════════════════

# Save model objects for tables/figures
results <- list(
  # First stage
  fs = list(fs1 = fs1, fs2 = fs2, fs3 = fs3, fs4 = fs4),
  # Reduced form education
  rf_school = list(rf_school1 = rf_school1, rf_school2 = rf_school2,
    rf_school3 = rf_school3, rf_school4 = rf_school4),
  rf_10yr = list(rf_10yr1 = rf_10yr1, rf_10yr2 = rf_10yr2),
  rf_lit = list(rf_lit1 = rf_lit1, rf_lit2 = rf_lit2),
  # IV
  iv = list(iv_school1 = iv_school1, iv_school2 = iv_school2,
    iv_school3 = iv_school3, iv_10yr = iv_10yr),
  # Health
  health = list(rf_diarrhea = rf_diarrhea, rf_stunted = rf_stunted,
    rf_underweight = rf_underweight, rf_instbirth = rf_instbirth,
    rf_anc = rf_anc),
  # Nightlights
  nl = list(rf_nl1 = rf_nl1, rf_nl2 = rf_nl2, rf_nl_pct = rf_nl_pct)
)

save(results, file = file.path(data_dir, "main_results.RData"))
cat("✓ Main analysis complete. Results saved.\n")
