## ============================================================
## 04_robustness.R — Robustness checks, placebo, heterogeneity
## Paper: Does Sanitation Drive Development? (apep_0444)
## ============================================================

BASE_DIR <- file.path("output", "apep_0444", "v1")
source(file.path(BASE_DIR, "code", "00_packages.R"))

panel <- fread(file.path(BASE_DIR, "data", "district_panel.csv"))
panel[, dist_id := as.factor(dist_id)]

# ══════════════════════════════════════════════════════════════
# 1. PLACEBO TESTS
# ══════════════════════════════════════════════════════════════

cat("\n=== Placebo Tests ===\n")

# Placebo 1: Urban-only districts (SBM-G targets rural areas)
# Define urban-dominant districts as those with rural_share < 0.3
urban_panel <- panel[rural_share < 0.3]
cat("Urban-dominant districts:", uniqueN(urban_panel$dist_id), "\n")

if (uniqueN(urban_panel$dist_id) > 10) {
  placebo_urban <- feols(log_nl ~ post_odf | dist_id + year,
                          data = urban_panel, cluster = ~pc11_state_id)
  cat("Placebo (urban districts):\n")
  print(summary(placebo_urban))
} else {
  cat("Too few urban-dominant districts for placebo test.\n")
  placebo_urban <- NULL
}

# Placebo 2: Fake treatment dates (shift ODF dates back 3 years)
placebo_panel <- copy(panel)
placebo_panel[, `:=`(
  fake_odf_year = odf_year - 3L,
  fake_post = as.integer(year >= (odf_year - 3L))
)]
# Only use pre-treatment years (before actual ODF)
placebo_panel <- placebo_panel[year < odf_year]

if (nrow(placebo_panel) > 100) {
  placebo_fake <- feols(log_nl ~ fake_post | dist_id + year,
                         data = placebo_panel, cluster = ~pc11_state_id)
  cat("\nPlacebo (fake dates, pre-period only):\n")
  print(summary(placebo_fake))
} else {
  placebo_fake <- NULL
  cat("Insufficient pre-treatment observations for fake-date placebo.\n")
}

# ══════════════════════════════════════════════════════════════
# 2. HETEROGENEITY ANALYSIS
# ══════════════════════════════════════════════════════════════

cat("\n=== Heterogeneity Analysis ===\n")

# Heterogeneity 1: By baseline rural share
panel[, high_rural := as.integer(rural_share >= median(rural_share, na.rm = TRUE))]

het_rural <- feols(log_nl ~ post_odf * i(high_rural) | dist_id + year,
                    data = panel, cluster = ~pc11_state_id)
cat("Heterogeneity by rural share:\n")
print(summary(het_rural))

# Heterogeneity 2: By baseline literacy
panel[, high_lit := as.integer(lit_rate_2011 >= median(lit_rate_2011, na.rm = TRUE))]

het_lit <- feols(log_nl ~ post_odf * i(high_lit) | dist_id + year,
                  data = panel, cluster = ~pc11_state_id)
cat("\nHeterogeneity by literacy:\n")
print(summary(het_lit))

# Heterogeneity 3: By baseline SC/ST share (proxy for marginalized populations)
panel[, high_scst := as.integer((sc_share_2011 + st_share_2011) >=
                                  median(sc_share_2011 + st_share_2011, na.rm = TRUE))]

het_scst <- feols(log_nl ~ post_odf * i(high_scst) | dist_id + year,
                   data = panel, cluster = ~pc11_state_id)
cat("\nHeterogeneity by SC/ST share:\n")
print(summary(het_scst))

# Heterogeneity 4: By baseline population (district size)
panel[, large_dist := as.integer(pop_2011 >= median(pop_2011, na.rm = TRUE))]

het_size <- feols(log_nl ~ post_odf * i(large_dist) | dist_id + year,
                   data = panel, cluster = ~pc11_state_id)
cat("\nHeterogeneity by district size:\n")
print(summary(het_size))

# ══════════════════════════════════════════════════════════════
# 3. ALTERNATIVE OUTCOME MEASURES
# ══════════════════════════════════════════════════════════════

cat("\n=== Alternative Outcomes ===\n")

# Mean luminosity (instead of total)
panel[, log_nl_mean := log(nl_mean + 0.001)]
alt_mean <- feols(log_nl_mean ~ post_odf | dist_id + year,
                   data = panel, cluster = ~pc11_state_id)
cat("Mean luminosity:\n")
print(summary(alt_mean))

# Lit area (extensive margin — number of lit cells)
panel[, lit_area := nl_cells * (nl_mean > 0)]
alt_lit <- feols(log(lit_area + 1) ~ post_odf | dist_id + year,
                  data = panel, cluster = ~pc11_state_id)
cat("\nLit area:\n")
print(summary(alt_lit))

# ══════════════════════════════════════════════════════════════
# 4. SENSITIVITY TO TREATMENT DATE UNCERTAINTY
# ══════════════════════════════════════════════════════════════

cat("\n=== Treatment Date Sensitivity ===\n")

# Tier 1 states only (highest confidence dates)
odf <- fread(file.path(BASE_DIR, "data", "odf_dates.csv"))
tier1_states <- odf[confidence_tier == 1, pc11_state_id]
tier1_panel <- panel[pc11_state_id %in% tier1_states]

if (uniqueN(tier1_panel$pc11_state_id) >= 5) {
  sens_tier1 <- feols(log_nl ~ post_odf | dist_id + year,
                       data = tier1_panel, cluster = ~pc11_state_id)
  cat("Tier 1 states only:\n")
  print(summary(sens_tier1))
} else {
  sens_tier1 <- NULL
  cat("Too few Tier 1 states for separate analysis.\n")
}

# Exclude earliest and latest cohorts (most uncertain timing)
mid_panel <- panel[cohort %in% c(2017, 2018)]
if (uniqueN(mid_panel$pc11_state_id) >= 10) {
  sens_mid <- feols(log_nl ~ post_odf | dist_id + year,
                     data = mid_panel, cluster = ~pc11_state_id)
  cat("\nMid-cohort states only (2017-2018):\n")
  print(summary(sens_mid))
} else {
  sens_mid <- NULL
}

# ══════════════════════════════════════════════════════════════
# 5. EXTENDED PRE-TREATMENT WITH DMSP (2008-2013)
# ══════════════════════════════════════════════════════════════

cat("\n=== DMSP Extended Pre-Trends ===\n")

dmsp_panel <- fread(file.path(BASE_DIR, "data", "district_dmsp_panel.csv"))
dmsp_panel[, dist_id := as.factor(paste0(pc11_state_id, "_", pc11_district_id))]

# All DMSP years are pre-treatment (2008-2013, ODF starts 2016)
# Run event study relative to ODF year using DMSP
dmsp_panel[, rel_time_binned := pmin(pmax(rel_time, -10L), -3L)]

es_dmsp <- feols(log_dmsp ~ i(rel_time_binned, ref = -3) | dist_id + year,
                  data = dmsp_panel, cluster = ~pc11_state_id)
cat("DMSP pre-trend event study (should show flat pre-trends):\n")
print(summary(es_dmsp))

# ══════════════════════════════════════════════════════════════
# 6. RANDOMIZATION INFERENCE
# ══════════════════════════════════════════════════════════════

cat("\n=== Randomization Inference ===\n")

# Permute treatment across states 500 times
set.seed(42)
n_perm <- 500
actual_coef <- coef(feols(log_nl ~ post_odf | dist_id + year,
                           data = panel))["post_odf"]

ri_coefs <- numeric(n_perm)
state_ids <- unique(panel$pc11_state_id)
odf_years <- unique(panel[, .(pc11_state_id, odf_year)])

for (i in seq_len(n_perm)) {
  # Shuffle ODF years across states
  shuffled <- copy(odf_years)
  shuffled[, odf_year := sample(odf_year)]

  ri_panel <- copy(panel)
  ri_panel[, odf_year := NULL]
  ri_panel <- merge(ri_panel, shuffled, by = "pc11_state_id")
  ri_panel[, post_odf := as.integer(year >= odf_year)]

  ri_fit <- feols(log_nl ~ post_odf | dist_id + year, data = ri_panel)
  ri_coefs[i] <- coef(ri_fit)["post_odf"]

  if (i %% 100 == 0) cat("  RI iteration", i, "/", n_perm, "\n")
}

ri_pvalue <- mean(abs(ri_coefs) >= abs(actual_coef))
cat("\nRandomization Inference p-value:", round(ri_pvalue, 4), "\n")
cat("Actual coefficient:", round(actual_coef, 4), "\n")
cat("RI distribution: mean =", round(mean(ri_coefs), 4),
    ", sd =", round(sd(ri_coefs), 4), "\n")

# ── Save all robustness results ───────────────────────────────
robustness_results <- list(
  placebo_urban = placebo_urban,
  placebo_fake = placebo_fake,
  het_rural = het_rural,
  het_lit = het_lit,
  het_scst = het_scst,
  het_size = het_size,
  alt_mean = alt_mean,
  alt_lit = alt_lit,
  sens_tier1 = sens_tier1,
  sens_mid = sens_mid,
  es_dmsp = es_dmsp,
  ri_pvalue = ri_pvalue,
  ri_coefs = ri_coefs,
  actual_coef = actual_coef
)
saveRDS(robustness_results, file.path(BASE_DIR, "data", "robustness_results.rds"))
cat("\nRobustness results saved.\n")
