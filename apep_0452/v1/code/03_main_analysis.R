## 03_main_analysis.R — Primary regressions
## apep_0452: Mercury regulation and ASGM in Africa

source("00_packages.R")
load(file.path(data_dir, "clean_panel.RData"))

results <- list()

# ============================================================
# A. DESIGN 1: EU MERCURY EXPORT BAN (2011)
# ============================================================

cat("=== DESIGN 1: EU Mercury Export Ban ===\n\n")

# A1. Main specification: EU share × Post interaction
# Window: 2005-2015 (drop 2011 as transition)
eu_panel <- panel %>%
  filter(year >= 2005, year <= 2015, year != 2011)

cat("--- A1: TWFE with continuous treatment intensity ---\n")

# (a) Log mercury imports ~ EU share × Post
m1a <- feols(log_hg_import ~ eu_ban_treat |
               iso3c + year,
             data = eu_panel, cluster = ~iso3c)

# (b) IHS mercury imports ~ EU share × Post
m1b <- feols(ihs_hg_import ~ eu_ban_treat |
               iso3c + year,
             data = eu_panel, cluster = ~iso3c)

# (c) With time-varying controls
m1c <- feols(log_hg_import ~ eu_ban_treat + log_gdp_pc + log_pop +
               trade_pct_gdp |
               iso3c + year,
             data = eu_panel, cluster = ~iso3c)

# (d) Gold exports as secondary outcome
m1d <- feols(log_gold_export ~ eu_ban_treat |
               iso3c + year,
             data = eu_panel, cluster = ~iso3c)

# (e) Placebo: fertilizer imports
m1e <- feols(log_fert_import ~ eu_ban_treat |
               iso3c + year,
             data = eu_panel, cluster = ~iso3c)

results$eu_ban <- list(m1a = m1a, m1b = m1b, m1c = m1c, m1d = m1d, m1e = m1e)

cat("  m1a (log Hg): coef =", round(coef(m1a)["eu_ban_treat"], 4),
    " se =", round(sqrt(vcov(m1a)["eu_ban_treat","eu_ban_treat"]), 4), "\n")
cat("  m1e (placebo fert): coef =", round(coef(m1e)["eu_ban_treat"], 4), "\n")

# A2. Event study for EU ban
cat("\n--- A2: Event study around EU ban (2011) ---\n")

eu_event <- panel %>%
  filter(year >= 2005, year <= 2020) %>%
  mutate(
    event_time = year - 2011,
    event_time_fac = factor(event_time),
    # Rebase: 2010 (event_time = -1) is reference
    event_time_fac = relevel(event_time_fac, ref = "-1")
  )

m2_event <- feols(log_hg_import ~ i(event_time_fac) * eu_share_preban |
                    iso3c + year,
                  data = eu_event %>% filter(eu_share_preban > 0),
                  cluster = ~iso3c)

results$eu_event <- m2_event

# A3. Subgroup: ASGM countries only
cat("\n--- A3: ASGM countries only ---\n")

m3_asgm <- feols(log_hg_import ~ eu_ban_treat |
                   iso3c + year,
                 data = eu_panel %>% filter(is_asgm_country),
                 cluster = ~iso3c)

results$eu_asgm <- m3_asgm
cat("  ASGM-only coef:", round(coef(m3_asgm)["eu_ban_treat"], 4), "\n")

# A4. Balanced reporters only
cat("\n--- A4: Balanced reporters only ---\n")

m4_balanced <- feols(log_hg_import ~ eu_ban_treat |
                      iso3c + year,
                    data = eu_panel %>% filter(balanced_reporter),
                    cluster = ~iso3c)

results$eu_balanced <- m4_balanced
cat("  Balanced coef:", round(coef(m4_balanced)["eu_ban_treat"], 4), "\n")

# ============================================================
# B. DESIGN 2: MINAMATA CONVENTION (Staggered DR-DiD)
# ============================================================

cat("\n=== DESIGN 2: Minamata Convention ===\n\n")

# B1. Callaway-Sant'Anna with DR
cat("--- B1: Callaway-Sant'Anna DR-DiD ---\n")

cs_panel <- panel %>%
  filter(year >= 2005, year <= 2023) %>%
  # Need non-missing outcome and covariates
  filter(!is.na(log_hg_import), !is.na(log_gdp_pc)) %>%
  # Recode late ratifiers (treatment_year > 2023) as never-treated
  # since we have no post-treatment data for them
  mutate(first_treat_minamata = ifelse(
    first_treat_minamata > 2023 | first_treat_minamata == 0, 0L,
    first_treat_minamata
  ))

# Check we have enough variation
cat("  Treated countries:", sum(cs_panel$first_treat_minamata > 0) /
    n_distinct(cs_panel$year), "\n")
cat("  Never-treated:", sum(cs_panel$first_treat_minamata == 0) /
    n_distinct(cs_panel$year), "\n")

# Run CS-DiD with doubly robust estimation
set.seed(20250225)
cs_out <- tryCatch({
  att_gt(
    yname       = "log_hg_import",
    tname       = "year",
    idname      = "country_id",
    gname       = "first_treat_minamata",
    data        = as.data.frame(cs_panel),
    xformla     = ~ log_gdp_pc,
    est_method  = "dr",
    control_group = "nevertreated",
    base_period = "universal",
    bstrap      = TRUE,
    cband       = TRUE,
    biters      = 1000
  )
}, error = function(e) {
  cat("  CS-DiD error:", conditionMessage(e), "\n")
  cat("  Falling back to simple DiD...\n")
  NULL
})

if (!is.null(cs_out)) {
  results$cs_did <- cs_out

  # Aggregate to event study
  cs_es <- aggte(cs_out, type = "dynamic")
  results$cs_event_study <- cs_es

  # Overall ATT
  cs_att <- aggte(cs_out, type = "simple")
  results$cs_att <- cs_att

  cat("  CS-DiD overall ATT:", round(cs_att$overall.att, 4),
      " se:", round(cs_att$overall.se, 4), "\n")
}

# B2. TWFE specification (for comparison, knowing its limitations)
cat("\n--- B2: TWFE specification ---\n")

m5_twfe <- feols(log_hg_import ~ minamata_ratified |
                   iso3c + year,
                 data = cs_panel, cluster = ~iso3c)

results$minamata_twfe <- m5_twfe
cat("  TWFE coef:", round(coef(m5_twfe)["minamata_ratified"], 4), "\n")

# B3. NAP submission as treatment margin
cat("\n--- B3: NAP submission ---\n")

m6_nap <- feols(log_hg_import ~ nap_submitted |
                  iso3c + year,
                data = cs_panel, cluster = ~iso3c)

results$nap_twfe <- m6_nap
cat("  NAP TWFE coef:", round(coef(m6_nap)["nap_submitted"], 4), "\n")

# B4. Minamata effect on gold exports
cat("\n--- B4: Minamata → gold exports ---\n")

m7_gold <- feols(log_gold_export ~ minamata_ratified |
                   iso3c + year,
                 data = cs_panel, cluster = ~iso3c)

results$minamata_gold <- m7_gold
cat("  Gold exports coef:", round(coef(m7_gold)["minamata_ratified"], 4), "\n")

# B5. Placebo: fertilizer imports
cat("\n--- B5: Placebo (fertilizer) ---\n")

m8_placebo <- feols(log_fert_import ~ minamata_ratified |
                      iso3c + year,
                    data = cs_panel, cluster = ~iso3c)

results$minamata_placebo <- m8_placebo
cat("  Placebo coef:", round(coef(m8_placebo)["minamata_ratified"], 4), "\n")

# ============================================================
# C. DESIGN 3: COMBINED MODEL
# ============================================================

cat("\n=== DESIGN 3: Combined EU Ban + Minamata ===\n\n")

combined_panel <- panel %>%
  filter(year >= 2005, year <= 2023, year != 2011)

m9_combined <- feols(log_hg_import ~ eu_ban_treat + minamata_ratified |
                       iso3c + year,
                     data = combined_panel, cluster = ~iso3c)

results$combined <- m9_combined
cat("  EU ban coef:", round(coef(m9_combined)["eu_ban_treat"], 4), "\n")
cat("  Minamata coef:", round(coef(m9_combined)["minamata_ratified"], 4), "\n")

# C2. Triple interaction: EU ban × Minamata × ASGM
m10_triple <- feols(log_hg_import ~ eu_ban_treat * minamata_ratified +
                      eu_ban_treat * i(is_asgm_country) |
                      iso3c + year,
                    data = combined_panel, cluster = ~iso3c)

results$triple <- m10_triple

# ============================================================
# D. TRADE PARTNER REALLOCATION
# ============================================================

cat("\n=== Trade Partner Reallocation Analysis ===\n\n")

if (nrow(mercury_bilat) > 0) {
  # Compute partner region shares by year
  partner_shares <- mercury_bilat %>%
    group_by(reporter_iso3, year) %>%
    mutate(total_value = sum(value, na.rm = TRUE)) %>%
    ungroup() %>%
    group_by(reporter_iso3, year, partner_region) %>%
    summarise(
      region_value = sum(value, na.rm = TRUE),
      share = region_value / first(total_value),
      .groups = "drop"
    )

  # Average across all African importers
  avg_shares <- partner_shares %>%
    group_by(year, partner_region) %>%
    summarise(
      mean_share = mean(share, na.rm = TRUE),
      total_value = sum(region_value, na.rm = TRUE),
      .groups = "drop"
    )

  results$partner_shares <- avg_shares

  # Formal test: EU share pre vs post
  eu_share_test <- partner_shares %>%
    filter(partner_region == "EU") %>%
    mutate(post_ban = year >= 2012) %>%
    group_by(reporter_iso3) %>%
    filter(n() >= 4) %>%
    ungroup()

  if (nrow(eu_share_test) > 0) {
    eu_share_reg <- feols(share ~ post_ban | reporter_iso3,
                          data = eu_share_test, cluster = ~reporter_iso3)
    results$eu_share_decline <- eu_share_reg
    cat("  EU share decline after ban:", round(coef(eu_share_reg)["post_banTRUE"], 4), "\n")
  }
}

# ============================================================
# E. MIRROR TRADE ANALYSIS
# ============================================================

cat("\n=== Mirror Trade Analysis ===\n")

# Compare importer-reported vs exporter-reported mercury flows
# This requires fetching exporter-reported data for the same flows
# For now, compute within-sample discrepancy indicators
if (nrow(mercury_bilat) > 0) {
  mirror_summary <- mercury_bilat %>%
    group_by(year) %>%
    summarise(
      total_hg_imports = sum(value, na.rm = TRUE),
      n_flows = n(),
      n_countries = n_distinct(reporter_iso3),
      .groups = "drop"
    )

  results$mirror_summary <- mirror_summary
  cat("  Mercury trade summary computed.\n")
}

# ============================================================
# SAVE RESULTS
# ============================================================

save(results, file = file.path(data_dir, "analysis_results.RData"))
cat("\nAll results saved.\n")
cat("Main analysis complete.\n")
