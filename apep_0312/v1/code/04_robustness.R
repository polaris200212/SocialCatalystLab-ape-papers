## 04_robustness.R — Robustness checks and sensitivity analysis
## APEP-0310: Workers' Compensation and Industrial Safety

source("code/00_packages.R")

# Load data
news_clean     <- fread(file.path(DATA_DIR, "newspaper_clean.csv"))
ipums_analysis <- fread(file.path(DATA_DIR, "ipums_analysis.csv"))
state_covs     <- fread(file.path(DATA_DIR, "state_covariates_1910.csv"))

results <- readRDS(file.path(DATA_DIR, "main_results.rds"))

# =============================================================================
# ROBUSTNESS 1: Alternative Search Terms
# =============================================================================

cat("=== Robustness 1: Alternative newspaper search terms ===\n")

# Test with mine-specific and factory-specific accident indices
news_cs <- news_clean[!is.na(statefip)]

news_cs <- merge(news_cs, state_covs[, .(STATEFIP, pct_urban_1910,
                                          pct_manufacturing_1910, pct_mining_1910)],
                 by.x = "statefip", by.y = "STATEFIP", all.x = TRUE)

news_cs[, state_id := as.integer(as.factor(statefip))]
news_cs[, g := fifelse(first_treat == 0 | is.na(first_treat), 0, first_treat)]

# Mine disaster index
news_cs[, mine_index := fifelse(total_pages > 0, (mine_pages / total_pages) * 1000, NA_real_)]

if (sum(!is.na(news_cs$mine_index)) > 100) {
  tryCatch({
    set.seed(202401)  # Reproducible bootstrap for mine index
    cs_mine <- att_gt(
      yname = "mine_index", tname = "year", idname = "state_id",
      gname = "g", data = as.data.frame(news_cs[!is.na(mine_index)]),
      xformla = ~ pct_urban_1910 + pct_manufacturing_1910 + pct_mining_1910,
      est_method = "dr", control_group = "notyettreated",
      bstrap = TRUE, biters = 500
    )
    agg_mine <- aggte(cs_mine, type = "simple")
    cat("Mine disaster index — Overall ATT:", round(agg_mine$overall.att, 4),
        "(SE:", round(agg_mine$overall.se, 4), ")\n")
  }, error = function(e) cat("Mine index C&S failed:", e$message, "\n"))
}

# Factory explosion index
news_cs[, factory_index := fifelse(total_pages > 0, (factory_pages / total_pages) * 1000, NA_real_)]

if (sum(!is.na(news_cs$factory_index)) > 100) {
  tryCatch({
    set.seed(202402)  # Reproducible bootstrap for factory index
    cs_factory <- att_gt(
      yname = "factory_index", tname = "year", idname = "state_id",
      gname = "g", data = as.data.frame(news_cs[!is.na(factory_index)]),
      xformla = ~ pct_urban_1910 + pct_manufacturing_1910,
      est_method = "dr", control_group = "notyettreated",
      bstrap = TRUE, biters = 500
    )
    agg_factory <- aggte(cs_factory, type = "simple")
    cat("Factory explosion index — Overall ATT:", round(agg_factory$overall.att, 4),
        "(SE:", round(agg_factory$overall.se, 4), ")\n")
  }, error = function(e) cat("Factory index C&S failed:", e$message, "\n"))
}

# =============================================================================
# ROBUSTNESS 2: Pre-trend Placebo Test (Newspaper Data)
# =============================================================================

cat("\n=== Robustness 2: Pre-trend placebo test ===\n")

# Use only pre-treatment data (1900-1910) with hypothetical treatment dates
# If treatment had an effect before adoption, something is wrong
news_pre <- news_cs[year <= 1910]

# Assign placebo treatment: states that adopted 1911-1913 get placebo in 1906
news_pre[, placebo_g := fcase(
  g >= 1911 & g <= 1913, 1906L,
  g >= 1914 & g <= 1915, 1908L,
  default = 0L
)]

if (length(unique(news_pre[placebo_g > 0, state_id])) >= 3) {
  tryCatch({
    set.seed(202403)  # Reproducible bootstrap for placebo test
    cs_placebo <- att_gt(
      yname = "accident_index", tname = "year", idname = "state_id",
      gname = "placebo_g", data = as.data.frame(news_pre[!is.na(accident_index)]),
      xformla = ~ pct_urban_1910 + pct_manufacturing_1910,
      est_method = "dr", control_group = "notyettreated",
      bstrap = TRUE, biters = 500
    )
    agg_placebo <- aggte(cs_placebo, type = "simple")
    cat("Placebo ATT:", round(agg_placebo$overall.att, 4),
        "(SE:", round(agg_placebo$overall.se, 4), ")\n")
    cat("Placebo p-value:", ifelse(abs(agg_placebo$overall.att / agg_placebo$overall.se) > 1.96,
                                    "SIGNIFICANT — pre-trends concern!", "Insignificant — good"),
        "\n")
  }, error = function(e) cat("Placebo test failed:", e$message, "\n"))
}

# =============================================================================
# ROBUSTNESS 3: Alternative Treatment Definitions (IPUMS)
# =============================================================================

cat("\n=== Robustness 3: Alternative treatment definitions ===\n")

# Early vs Late adopters (exclude never-treated)
ipums_early_late <- ipums_analysis[adoption_year <= 1920]
ipums_early_late[, early_adopter := fifelse(adoption_year <= 1913, 1L, 0L)]

dr_early_late <- ipums_early_late[, .(
  y = dangerous_occ,
  post = fifelse(YEAR == 1920, 1L, 0L),
  d = early_adopter,
  age = AGE, age_sq = age_sq, white = white,
  foreign_born = foreign_born, literate = literate,
  married = married, urban = urban
)]
dr_early_late <- na.omit(dr_early_late)
dr_early_late[, id := .I]

tryCatch({
  dr_el <- drdid(
    yname = "y", tname = "post", idname = "id", dname = "d",
    xformla = ~ age + age_sq + white + foreign_born + literate + married + urban,
    data = as.data.frame(dr_early_late), panel = FALSE, estMethod = "imp"
  )
  cat("Early vs Late adopters — ATT:", round(dr_el$ATT, 4),
      "(SE:", round(dr_el$se, 4), ")\n")
}, error = function(e) cat("Early vs Late DR failed:", e$message, "\n"))

# =============================================================================
# ROBUSTNESS 4: Alternative Outcomes
# =============================================================================

cat("\n=== Robustness 4: Alternative occupational outcomes ===\n")

# Mining occupation specifically
ipums_dr <- ipums_analysis[adoption_cohort > 0 | adoption_year > 1920]
ipums_dr[, treat_group := fifelse(adoption_cohort > 0 & adoption_cohort <= 1920, 1L, 0L)]

# Mining occupation
mining_dr <- ipums_dr[, .(
  y = fifelse(OCC1950 >= 502 & OCC1950 <= 504, 1L, 0L),
  post = fifelse(YEAR == 1920, 1L, 0L),
  d = treat_group,
  age = AGE, age_sq = age_sq, white = white,
  foreign_born = foreign_born, literate = literate,
  married = married, urban = urban
)]
mining_dr <- na.omit(mining_dr)
mining_dr[, id := .I]

tryCatch({
  dr_mining <- drdid(
    yname = "y", tname = "post", idname = "id", dname = "d",
    xformla = ~ age + age_sq + white + foreign_born + literate + married + urban,
    data = as.data.frame(mining_dr), panel = FALSE, estMethod = "imp"
  )
  cat("Mining occupation — ATT:", round(dr_mining$ATT, 4),
      "(SE:", round(dr_mining$se, 4), ")\n")
}, error = function(e) cat("Mining DR failed:", e$message, "\n"))

# Professional/white-collar (negative control — shouldn't be affected)
cat("\n--- Negative Control: White-collar occupation ---\n")
whitecollar_dr <- ipums_dr[, .(
  y = fifelse(OCC1950 >= 0 & OCC1950 <= 99, 1L, 0L),  # Professional/technical
  post = fifelse(YEAR == 1920, 1L, 0L),
  d = treat_group,
  age = AGE, age_sq = age_sq, white = white,
  foreign_born = foreign_born, literate = literate,
  married = married, urban = urban
)]
whitecollar_dr <- na.omit(whitecollar_dr)
whitecollar_dr[, id := .I]

tryCatch({
  dr_wc <- drdid(
    yname = "y", tname = "post", idname = "id", dname = "d",
    xformla = ~ age + age_sq + white + foreign_born + literate + married + urban,
    data = as.data.frame(whitecollar_dr), panel = FALSE, estMethod = "imp"
  )
  cat("White-collar (negative control) — ATT:", round(dr_wc$ATT, 4),
      "(SE:", round(dr_wc$se, 4), ")\n")
  if (abs(dr_wc$ATT / dr_wc$se) > 1.96) {
    cat("  WARNING: Significant effect on negative control → possible confounding\n")
  } else {
    cat("  Insignificant — consistent with no confounding\n")
  }
}, error = function(e) cat("White-collar DR failed:", e$message, "\n"))

# =============================================================================
# ROBUSTNESS 5: Sensitivity Analysis (Cinelli & Hazlett)
# =============================================================================

cat("\n=== Robustness 5: Sensitivity analysis ===\n")

# OLS benchmark for sensemakr
ols_data <- ipums_dr[YEAR == 1920, .(
  dangerous_occ = dangerous_occ,
  treated = treat_group,
  age = AGE, age_sq = age_sq, white = white,
  foreign_born = foreign_born, literate = literate,
  married = married, urban = urban
)]
ols_data <- na.omit(ols_data)

ols_fit <- lm(dangerous_occ ~ treated + age + age_sq + white + foreign_born +
                literate + married + urban, data = ols_data)

# Calibrated sensitivity analysis
sens <- sensemakr(
  model = ols_fit,
  treatment = "treated",
  benchmark_covariates = c("foreign_born", "literate"),
  kd = 1:3
)

cat("OLS coefficient on treated:", round(coef(ols_fit)["treated"], 4), "\n")
cat("\nSensitivity analysis summary:\n")
print(summary(sens))

# Save sensitivity results
saveRDS(sens, file.path(DATA_DIR, "sensitivity_results.rds"))

# =============================================================================
# ROBUSTNESS 6: Covariate Balance Assessment
# =============================================================================

cat("\n=== Robustness 6: Covariate balance ===\n")

# Check balance between treated and control states in 1910 (pre-treatment)
balance_data <- ipums_analysis[YEAR == 1910]
balance_data[, treat_group := fifelse(
  !is.na(adoption_year) & adoption_year <= 1920, 1L, 0L
)]

bal <- bal.tab(
  treat_group ~ AGE + white + foreign_born + literate + married +
    urban + occ_income,
  data = balance_data,
  weights = balance_data$PERWT,
  s.d.denom = "pooled"
)

cat("Pre-treatment covariate balance (1910):\n")
print(bal)

# Save
saveRDS(bal, file.path(DATA_DIR, "balance_results.rds"))

cat("\n=== Robustness checks complete ===\n")
