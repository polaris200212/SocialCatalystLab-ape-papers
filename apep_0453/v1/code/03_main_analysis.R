# ============================================================
# 03_main_analysis.R — Primary regressions
# apep_0453: Demonetization and Banking Infrastructure
# ============================================================

source("00_packages.R")
load("../data/analysis_panel.RData")

cat("=== MAIN ANALYSIS ===\n\n")

# ============================================================
# 1. EVENT STUDY (Main specification)
# ============================================================

# Interaction: bank_per_100k × year dummies (omit 2015 as reference)
# Cluster at state level
cat("--- Event Study: Bank intensity × Year ---\n")
es_fit <- feols(
  log_nl ~ i(year, bank_per_100k, ref = 2015) |
    dist_id + year,
  data = panel,
  cluster = ~state_id
)
summary(es_fit)

# Save event study coefficients
cf <- coef(es_fit)
se_vec <- sqrt(diag(vcov(es_fit)))
# Extract years from coefficient names like "year::2012:bank_per_100k"
yrs <- as.integer(sub("year::(\\d+):bank_per_100k", "\\1", names(cf)))
es_coefs <- data.table(year = yrs, coef = cf, se = se_vec)
es_coefs <- es_coefs[!is.na(year)]
# Add 2015 reference year as zero
es_coefs <- rbind(es_coefs, data.table(year = 2015L, coef = 0, se = 0))
setorder(es_coefs, year)
es_coefs[, `:=`(ci_lo = coef - 1.96 * se, ci_hi = coef + 1.96 * se)]

cat("\nEvent study coefficients:\n")
print(es_coefs)

# ============================================================
# 2. POOLED DiD (Short-run: 2017–2018)
# ============================================================

cat("\n--- Pooled DiD: Short-run (Post = 2017+) ---\n")
did_short <- feols(
  log_nl ~ bank_per_100k:post |
    dist_id + year,
  data = panel,
  cluster = ~state_id
)
summary(did_short)

# ============================================================
# 3. SPLIT PERIOD ANALYSIS (Short / Medium / Long run)
# ============================================================

panel[, `:=`(
  post_short  = as.integer(year %in% 2017:2018),
  post_medium = as.integer(year %in% 2019:2020),
  post_long   = as.integer(year %in% 2021:2023)
)]

cat("\n--- Split-period DiD ---\n")
did_split <- feols(
  log_nl ~ bank_per_100k:post_short +
           bank_per_100k:post_medium +
           bank_per_100k:post_long |
    dist_id + year,
  data = panel,
  cluster = ~state_id
)
summary(did_split)

# ============================================================
# 4. BINARY TREATMENT (Above/Below Median Banking)
# ============================================================

cat("\n--- Binary DiD: High vs Low banking districts ---\n")
did_binary <- feols(
  log_nl ~ i(year, high_bank, ref = 2015) |
    dist_id + year,
  data = panel,
  cluster = ~state_id
)
summary(did_binary)

# ============================================================
# 5. HETEROGENEITY: Agricultural vs Non-Agricultural
# ============================================================

panel[, high_ag := as.integer(ag_share >= median(baseline$ag_share, na.rm = TRUE))]

cat("\n--- Heterogeneity: High agriculture ---\n")
het_ag_high <- feols(
  log_nl ~ bank_per_100k:post |
    dist_id + year,
  data = panel[high_ag == 1],
  cluster = ~state_id
)
summary(het_ag_high)

cat("\n--- Heterogeneity: Low agriculture ---\n")
het_ag_low <- feols(
  log_nl ~ bank_per_100k:post |
    dist_id + year,
  data = panel[high_ag == 0],
  cluster = ~state_id
)
summary(het_ag_low)

# ============================================================
# 6. TRIPLE-DIFFERENCE: Bank × Post × AgShare
# ============================================================

cat("\n--- Triple-diff: Bank × Post × Agricultural share ---\n")
ddd <- feols(
  log_nl ~ bank_per_100k:post +
           bank_per_100k:post:ag_share |
    dist_id + year,
  data = panel,
  cluster = ~state_id
)
summary(ddd)

# ============================================================
# 7. CONTROLS: Baseline × Year trends
# ============================================================

cat("\n--- With baseline × year controls ---\n")
did_controls <- feols(
  log_nl ~ bank_per_100k:post +
           log_pop:factor(year) +
           lit_rate:factor(year) +
           ag_share:factor(year) +
           sc_share:factor(year) |
    dist_id + year,
  data = panel,
  cluster = ~state_id
)
summary(did_controls)

# Event study with controls
cat("\n--- Event study with controls ---\n")
es_controls <- feols(
  log_nl ~ i(year, bank_per_100k, ref = 2015) +
           log_pop:factor(year) +
           lit_rate:factor(year) +
           ag_share:factor(year) +
           sc_share:factor(year) |
    dist_id + year,
  data = panel,
  cluster = ~state_id
)
summary(es_controls)

# Save controlled event study coefficients
idx <- grep("^year::", names(coef(es_controls)))
cf2 <- coef(es_controls)[idx]
se2 <- sqrt(diag(vcov(es_controls))[idx])
yrs2 <- as.integer(sub("year::(\\d+):bank_per_100k", "\\1", names(cf2)))
es_ctrl_coefs <- data.table(year = yrs2, coef = cf2, se = se2)
es_ctrl_coefs <- es_ctrl_coefs[!is.na(year)]
es_ctrl_coefs <- rbind(es_ctrl_coefs, data.table(year = 2015L, coef = 0, se = 0))
setorder(es_ctrl_coefs, year)
es_ctrl_coefs[, `:=`(ci_lo = coef - 1.96 * se, ci_hi = coef + 1.96 * se)]

# ============================================================
# SAVE RESULTS
# ============================================================

save(es_fit, es_coefs, did_short, did_split, did_binary,
     het_ag_high, het_ag_low, ddd, did_controls, es_controls,
     es_ctrl_coefs,
     file = "../data/main_results.RData")

cat("\n=== Main analysis complete. Results saved. ===\n")
