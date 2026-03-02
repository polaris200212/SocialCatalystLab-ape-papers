## 03_main_analysis.R — Primary DR/AIPW estimation
## APEP-0310: Workers' Compensation and Industrial Safety

source("code/00_packages.R")

# Load cleaned data
news_clean     <- fread(file.path(DATA_DIR, "newspaper_clean.csv"))
ipums_analysis <- fread(file.path(DATA_DIR, "ipums_analysis.csv"))
state_covs     <- fread(file.path(DATA_DIR, "state_covariates_1910.csv"))

# =============================================================================
# ANALYSIS 1: Newspaper Panel — Callaway & Sant'Anna with DR
# =============================================================================

cat("=== Analysis 1: Newspaper Accident Coverage Panel ===\n\n")

# Prepare panel data for C&S
# Need: balanced panel with id, time, group (first treatment period), outcome
news_cs <- news_clean[!is.na(accident_index) & !is.na(statefip)]

# Create numeric state ID
news_cs[, state_id := as.integer(as.factor(statefip))]

# Merge state-level covariates for DR
news_cs <- merge(news_cs, state_covs[, .(STATEFIP, pct_urban_1910, pct_foreign_1910,
                                          pct_manufacturing_1910, pct_mining_1910)],
                 by.x = "statefip", by.y = "STATEFIP", all.x = TRUE)

# first_treat: 0 for never-treated (adoption_year > 1920)
news_cs[, g := fifelse(first_treat == 0 | is.na(first_treat), 0, first_treat)]

# Check data structure
cat("Panel dimensions:\n")
cat("  States:", length(unique(news_cs$state_id)), "\n")
cat("  Years:", length(unique(news_cs$year)), "\n")
cat("  Treatment groups:", paste(sort(unique(news_cs$g)), collapse = ", "), "\n")

# --- C&S with Doubly Robust Estimator ---
# The 'did' package implements AIPW (our DR method) via est_method = "dr"
set.seed(20260216)  # Reproducible bootstrap
cs_result <- att_gt(
  yname = "accident_index",
  tname = "year",
  idname = "state_id",
  gname = "g",
  data = as.data.frame(news_cs),
  xformla = ~ pct_urban_1910 + pct_manufacturing_1910 + pct_mining_1910,
  est_method = "dr",
  control_group = "notyettreated",
  anticipation = 0,
  bstrap = TRUE,
  cband = TRUE,
  biters = 1000
)

cat("\nGroup-Time ATTs (DR estimator):\n")
summary(cs_result)

# Aggregate to event study
es_result <- aggte(cs_result, type = "dynamic", min_e = -8, max_e = 8)
cat("\nEvent Study Aggregation:\n")
summary(es_result)

# Aggregate to overall ATT
overall_att <- aggte(cs_result, type = "simple")
cat("\nOverall ATT:\n")
summary(overall_att)

# Save results
saveRDS(cs_result, file.path(DATA_DIR, "cs_result.rds"))
saveRDS(es_result, file.path(DATA_DIR, "es_result.rds"))
saveRDS(overall_att, file.path(DATA_DIR, "overall_att.rds"))

# =============================================================================
# ANALYSIS 2: IPUMS Cross-Sections — DR for Occupational Sorting
# =============================================================================

cat("\n=== Analysis 2: Occupational Sorting (IPUMS) ===\n\n")

# For the IPUMS data, we use doubly-robust repeated cross-sections
# Comparing 1910 (pre-treatment for most states) to 1920 (post-treatment)

# Restrict to states where adoption occurred between 1910 and 1920
# These are "treated" states — their workers' comp turned on between censuses
# "Control" states: adopted after 1920 (never-treated in our window)
# OR adopted before 1910 (always-treated — but none did, earliest is 1911)

ipums_dr <- ipums_analysis[adoption_cohort > 0 | adoption_year > 1920]
ipums_dr[, treat_group := fifelse(adoption_cohort > 0 & adoption_cohort <= 1920, 1L, 0L)]

cat("IPUMS DR sample:\n")
cat("  Total:", format(nrow(ipums_dr), big.mark = ","), "\n")
cat("  Treated states:", length(unique(ipums_dr[treat_group == 1, STATEFIP])), "\n")
cat("  Control states:", length(unique(ipums_dr[treat_group == 0, STATEFIP])), "\n")

# DR estimation: outcome = dangerous occupation
# Using DRDID package for repeated cross-sections
# This implements Sant'Anna & Zhao (2020) DR estimator

# Prepare data
ipums_drdid <- ipums_dr[, .(
  y = dangerous_occ,
  post = fifelse(YEAR == 1920, 1L, 0L),
  d = treat_group,
  age = AGE,
  age_sq = age_sq,
  white = white,
  foreign_born = foreign_born,
  literate = literate,
  married = married,
  urban = urban,
  occ_income = occ_income,
  statefip = STATEFIP,
  perwt = PERWT
)]

# Remove observations with missing covariates
ipums_drdid <- na.omit(ipums_drdid)

# Add unique row ID for DRDID (required even for repeated cross-sections)
ipums_drdid[, id := .I]

cat("\nDRDID sample (no missing):", format(nrow(ipums_drdid), big.mark = ","), "\n")

# --- Main DR estimate: dangerous occupation ---
dr_dangerous <- drdid(
  yname = "y",
  tname = "post",
  idname = "id",
  dname = "d",
  xformla = ~ age + age_sq + white + foreign_born + literate + married + urban,
  data = as.data.frame(ipums_drdid),
  panel = FALSE,
  estMethod = "imp"  # Improved DR estimator (Sant'Anna & Zhao 2020)
)

cat("\nDR Estimate — Effect on Dangerous Occupation:\n")
cat("  ATT:", round(dr_dangerous$ATT, 4), "\n")
cat("  SE:", round(dr_dangerous$se, 4), "\n")
cat("  t-stat:", round(dr_dangerous$ATT / dr_dangerous$se, 2), "\n")
cat("  95% CI: [", round(dr_dangerous$ATT - 1.96 * dr_dangerous$se, 4), ",",
    round(dr_dangerous$ATT + 1.96 * dr_dangerous$se, 4), "]\n")

# --- DR estimate: occupational income score ---
ipums_drdid_inc <- ipums_dr[, .(
  y = occ_income,
  post = fifelse(YEAR == 1920, 1L, 0L),
  d = treat_group,
  age = AGE,
  age_sq = age_sq,
  white = white,
  foreign_born = foreign_born,
  literate = literate,
  married = married,
  urban = urban,
  statefip = STATEFIP
)]
ipums_drdid_inc <- na.omit(ipums_drdid_inc)
ipums_drdid_inc[, id := .I]

dr_income <- drdid(
  yname = "y",
  tname = "post",
  idname = "id",
  dname = "d",
  xformla = ~ age + age_sq + white + foreign_born + literate + married + urban,
  data = as.data.frame(ipums_drdid_inc),
  panel = FALSE,
  estMethod = "imp"
)

cat("\nDR Estimate — Effect on Occupational Income Score:\n")
cat("  ATT:", round(dr_income$ATT, 4), "\n")
cat("  SE:", round(dr_income$se, 4), "\n")
cat("  t-stat:", round(dr_income$ATT / dr_income$se, 2), "\n")

# --- DR estimate by industry group ---
cat("\n--- Heterogeneity by Pre-Treatment Industry ---\n")

for (ind in c("Mining", "Manufacturing", "Construction/Transportation")) {
  sub <- ipums_dr[industry_group == ind, .(
    y = dangerous_occ,
    post = fifelse(YEAR == 1920, 1L, 0L),
    d = treat_group,
    age = AGE, age_sq = age_sq, white = white,
    foreign_born = foreign_born, literate = literate,
    married = married, urban = urban
  )]
  sub <- na.omit(sub)
  sub[, id := .I]

  if (nrow(sub[d == 0 & post == 0]) < 20 || nrow(sub[d == 1 & post == 0]) < 20) {
    cat(sprintf("  %s: Insufficient observations, skipping\n", ind))
    next
  }

  tryCatch({
    dr_sub <- drdid(
      yname = "y", tname = "post", idname = "id", dname = "d",
      xformla = ~ age + age_sq + white + foreign_born + literate + married + urban,
      data = as.data.frame(sub), panel = FALSE, estMethod = "imp"
    )
    cat(sprintf("  %s: ATT = %.4f (SE = %.4f, t = %.2f)\n",
                ind, dr_sub$ATT, dr_sub$se, dr_sub$ATT / dr_sub$se))
  }, error = function(e) {
    cat(sprintf("  %s: Error — %s\n", ind, e$message))
  })
}

# =============================================================================
# ANALYSIS 3: TWFE Comparison (benchmark against naive estimator)
# =============================================================================

cat("\n=== Analysis 3: TWFE Benchmark ===\n\n")

# State-year level aggregation for TWFE
state_year <- ipums_analysis[, .(
  pct_dangerous = weighted.mean(dangerous_occ, PERWT, na.rm = TRUE) * 100,
  mean_occscore = weighted.mean(occ_income, PERWT, na.rm = TRUE),
  n_workers = .N
), by = .(STATEFIP, YEAR)]

state_year <- merge(state_year,
                    wc_dates[, .(statefip, adoption_year)],
                    by.x = "STATEFIP", by.y = "statefip", all.x = TRUE)
state_year[, treated := fifelse(!is.na(adoption_year) & YEAR >= adoption_year, 1L, 0L)]

# TWFE regression
twfe_dangerous <- feols(
  pct_dangerous ~ treated | STATEFIP + YEAR,
  data = state_year,
  cluster = ~STATEFIP
)

twfe_income <- feols(
  mean_occscore ~ treated | STATEFIP + YEAR,
  data = state_year,
  cluster = ~STATEFIP
)

cat("TWFE — Dangerous occupation share (%):\n")
summary(twfe_dangerous)

cat("\nTWFE — Occupational income score:\n")
summary(twfe_income)

# Save all results
results_list <- list(
  cs_result = cs_result,
  es_result = es_result,
  overall_att = overall_att,
  dr_dangerous = dr_dangerous,
  dr_income = dr_income,
  twfe_dangerous = twfe_dangerous,
  twfe_income = twfe_income
)
saveRDS(results_list, file.path(DATA_DIR, "main_results.rds"))

cat("\n=== Main analysis complete ===\n")
