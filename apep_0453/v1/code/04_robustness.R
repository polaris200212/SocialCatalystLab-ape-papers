# ============================================================
# 04_robustness.R — Robustness checks
# apep_0453: Demonetization and Banking Infrastructure
# ============================================================

source("00_packages.R")
load("../data/analysis_panel.RData")
load("../data/main_results.RData")

cat("=== ROBUSTNESS CHECKS ===\n\n")

# ============================================================
# 1. PLACEBO TEST: Fake demonetization in 2014
# ============================================================

cat("--- Placebo: Fake event in 2014 ---\n")
panel_pre <- panel[year <= 2016]
panel_pre[, post_placebo := as.integer(year >= 2015)]

placebo_2014 <- feols(
  log_nl ~ bank_per_100k:post_placebo |
    dist_id + year,
  data = panel_pre,
  cluster = ~state_id
)
summary(placebo_2014)

# ============================================================
# 2. ALTERNATIVE INTENSITY: Government banks only
# ============================================================

cat("\n--- Alt intensity: Government banks per 100K ---\n")
panel[, bank_gov_per_100k := baseline$bank_gov[match(dist_id,
  paste0(baseline$pc11_state_id, "_", baseline$pc11_district_id))] /
  baseline$pop_total[match(dist_id,
  paste0(baseline$pc11_state_id, "_", baseline$pc11_district_id))] * 100000]
# Impute 0 for 5 districts missing TD data
panel[is.na(bank_gov_per_100k), bank_gov_per_100k := 0]

alt_gov <- feols(
  log_nl ~ bank_gov_per_100k:post |
    dist_id + year,
  data = panel,
  cluster = ~state_id
)
summary(alt_gov)

# ============================================================
# 3. ALTERNATIVE INTENSITY: Log bank branches
# ============================================================

cat("\n--- Alt intensity: Log(bank branches + 1) ---\n")
panel[, log_bank_merged := baseline$log_bank[match(dist_id,
  paste0(baseline$pc11_state_id, "_", baseline$pc11_district_id))]]

alt_log <- feols(
  log_nl ~ log_bank_merged:post |
    dist_id + year,
  data = panel[!is.na(log_bank_merged)],
  cluster = ~state_id
)
summary(alt_log)

# ============================================================
# 4. DROPPING EXTREME DISTRICTS (Top/Bottom 5%)
# ============================================================

cat("\n--- Trim: Drop top/bottom 5% banking ---\n")
q05 <- quantile(baseline$bank_per_100k, 0.05, na.rm = TRUE)
q95 <- quantile(baseline$bank_per_100k, 0.95, na.rm = TRUE)
trim_dists <- baseline[bank_per_100k >= q05 & bank_per_100k <= q95]$pc11_district_id

trim_fit <- feols(
  log_nl ~ bank_per_100k:post |
    dist_id + year,
  data = panel[pc11_district_id %in% trim_dists],
  cluster = ~state_id
)
summary(trim_fit)

# ============================================================
# 5. QUARTILE-BASED EVENT STUDY
# ============================================================

cat("\n--- Quartile event study ---\n")
panel[, bank_q := baseline$bank_quartile[match(dist_id,
  paste0(baseline$pc11_state_id, "_", baseline$pc11_district_id))]]

# Q4 (highest) vs Q1 (lowest) comparison
panel[, top_quartile := as.integer(bank_q == "Q4 (Highest)")]
panel[, bottom_quartile := as.integer(bank_q == "Q1 (Lowest)")]

quartile_es <- feols(
  log_nl ~ i(year, top_quartile, ref = 2015) |
    dist_id + year,
  data = panel[bank_q %in% c("Q1 (Lowest)", "Q4 (Highest)")],
  cluster = ~state_id
)
summary(quartile_es)

# ============================================================
# 6. COVID ROBUSTNESS: Pre-COVID vs Full sample
# ============================================================

cat("\n--- Pre-COVID only (2012-2019) ---\n")
pre_covid <- feols(
  log_nl ~ bank_per_100k:post |
    dist_id + year,
  data = panel[year <= 2019],
  cluster = ~state_id
)
summary(pre_covid)

# ============================================================
# 7. ALTERNATIVE OUTCOME: Nightlights per capita
# ============================================================

cat("\n--- Alt outcome: NL per capita ---\n")
panel[, nl_per_cap := nl_sum / pop_total]
panel[, log_nl_pc := log(nl_per_cap + 0.01)]

nl_pc_fit <- feols(
  log_nl_pc ~ bank_per_100k:post |
    dist_id + year,
  data = panel[!is.na(log_nl_pc)],
  cluster = ~state_id
)
summary(nl_pc_fit)

# ============================================================
# 8. URBANIZATION CONTROL
# ============================================================

cat("\n--- Urban share interaction ---\n")
# Urban share from worker composition (non-ag as proxy)
panel[, urban_proxy := nonag_share]

urban_control <- feols(
  log_nl ~ bank_per_100k:post +
           urban_proxy:post |
    dist_id + year,
  data = panel[!is.na(urban_proxy)],
  cluster = ~state_id
)
summary(urban_control)

# ============================================================
# 9. RANDOMIZATION INFERENCE (100 permutations)
# ============================================================

cat("\n--- Randomization Inference (500 permutations) ---\n")
set.seed(42)
actual_coef <- coef(did_short)["bank_per_100k:post"]

n_perm <- 500
ri_coefs <- numeric(n_perm)

# Get unique district IDs for permutation
unique_dists <- unique(panel$dist_id)

for (i in 1:n_perm) {
  # Shuffle banking intensity across districts
  perm_map <- data.table(
    dist_id = unique_dists,
    bank_perm = sample(baseline$bank_per_100k[match(unique_dists,
      paste0(baseline$pc11_state_id, "_", baseline$pc11_district_id))])
  )
  panel_perm <- merge(panel, perm_map, by = "dist_id")

  fit_perm <- tryCatch(
    feols(
      log_nl ~ bank_perm:post | dist_id + year,
      data = panel_perm,
      cluster = ~state_id
    ),
    error = function(e) NULL
  )

  if (!is.null(fit_perm)) {
    ri_coefs[i] <- coef(fit_perm)["bank_perm:post"]
  }

  if (i %% 25 == 0) cat("  Permutation", i, "/", n_perm, "\n")
}

# Use (r+1)/(B+1) convention for exact permutation p-value
ri_count <- sum(abs(ri_coefs) >= abs(actual_coef), na.rm = TRUE)
ri_pvalue <- (ri_count + 1) / (n_perm + 1)
cat("  Actual coefficient:", round(actual_coef, 6), "\n")
cat("  RI p-value:", round(ri_pvalue, 3), "\n")

# ============================================================
# 10. HETEROGENEITY: ST/SC share
# ============================================================

cat("\n--- Heterogeneity: High SC/ST districts ---\n")
panel[, high_scst := as.integer((sc_share + st_share) >= median(baseline$sc_share + baseline$st_share, na.rm = TRUE))]

het_scst <- feols(
  log_nl ~ bank_per_100k:post:factor(high_scst) |
    dist_id + year,
  data = panel,
  cluster = ~state_id
)
summary(het_scst)

# ============================================================
# 11. ROBUSTNESS: Drop 5 districts with missing bank data
# ============================================================

cat("\n--- Drop 5 districts missing TD data ---\n")
# Identify districts where bank_total was NA (imputed to 0)
missing_td_dists <- baseline[bank_total == 0 & is.na(bank_gov)]$pc11_district_id
if (length(missing_td_dists) == 0) {
  # Alternative: find districts where original bank data was missing
  missing_td_dists <- baseline[bank_per_100k == 0]$pc11_district_id
}
cat("  Districts dropped:", length(missing_td_dists), "\n")

drop_missing <- feols(
  log_nl ~ bank_per_100k:post | dist_id + year,
  data = panel[!pc11_district_id %in% missing_td_dists],
  cluster = ~state_id
)
summary(drop_missing)

# ============================================================
# SAVE ALL ROBUSTNESS RESULTS
# ============================================================

save(placebo_2014, alt_gov, alt_log, trim_fit,
     quartile_es, pre_covid, nl_pc_fit, urban_control,
     ri_coefs, ri_pvalue, actual_coef, het_scst, drop_missing,
     file = "../data/robustness_results.RData")

cat("\n=== Robustness checks complete. Results saved. ===\n")
