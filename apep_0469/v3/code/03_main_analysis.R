## ============================================================================
## 03_main_analysis.R — Longitudinal Analysis with MLP Panel Data
## Missing Men, Rising Women v3 (apep_0469)
## ============================================================================
## Three-wave design:
##   1. PRE-TREND TEST (1930-1940): ΔLF(30→40) ~ Mob_s should be ≈ 0
##   2. INDIVIDUAL PANEL (MLP-linked): ΔY_i = α + β·Mob_s + γ·X + δ + ε
##   3. COUPLES PANEL (wives via households): ΔWife_Y ~ Mob_s + controls
##   4. MARRIED-WOMEN DECOMPOSITION: within-couple vs aggregate married women
## ============================================================================

source("code/00_packages.R")

data_dir <- "data"

## --------------------------------------------------------------------------
## 1. Load Data
## --------------------------------------------------------------------------

cat("=== Loading Analysis Datasets ===\n")

panel <- readRDS(file.path(data_dir, "linked_panel_40_50.rds"))
setDT(panel); alloc.col(panel, ncol(panel) + 20L)
couples <- readRDS(file.path(data_dir, "couples_panel_40_50.rds"))
setDT(couples); alloc.col(couples, ncol(couples) + 10L)
panel3 <- readRDS(file.path(data_dir, "linked_panel_30_40_50.rds"))
setDT(panel3); alloc.col(panel3, ncol(panel3) + 20L)
couples3 <- readRDS(file.path(data_dir, "couples_panel_30_40_50.rds"))
setDT(couples3); alloc.col(couples3, ncol(couples3) + 10L)
state_analysis <- readRDS(file.path(data_dir, "state_analysis.rds"))
setDT(state_analysis); alloc.col(state_analysis, ncol(state_analysis) + 10L)
state_controls <- readRDS(file.path(data_dir, "state_controls.rds"))
setDT(state_controls); alloc.col(state_controls, ncol(state_controls) + 10L)
decomp <- readRDS(file.path(data_dir, "decomposition_inputs.rds"))

cat(sprintf("Individual panel: %s\n", format(nrow(panel), big.mark = ",")))
cat(sprintf("Couples panel:    %s couples\n", format(nrow(couples), big.mark = ",")))
cat(sprintf("3-period panel:   %s\n", format(nrow(panel3), big.mark = ",")))
cat(sprintf("3-period couples: %s\n", format(nrow(couples3), big.mark = ",")))
cat(sprintf("States:           %d\n", nrow(state_analysis)))

# Region variable
assign_region <- function(dt, state_col = "statefip_1940") {
  dt[, region := fcase(
    get(state_col) %in% c(9, 23, 25, 33, 34, 36, 42, 44, 50), "Northeast",
    get(state_col) %in% c(17, 18, 19, 20, 26, 27, 29, 31, 38, 39, 46, 55), "Midwest",
    get(state_col) %in% c(1, 5, 10, 11, 12, 13, 21, 22, 24, 28, 37, 40, 45, 47, 48, 51, 54), "South",
    default = "West")]
  invisible(dt)
}

assign_region(panel)
assign_region(couples)
assign_region(panel3)
assign_region(couples3)


## --------------------------------------------------------------------------
## 2. PRE-TREND TEST (1930→1940) — Key New Analysis
## --------------------------------------------------------------------------

cat("\n=== Pre-Trend Test (1930→1940) ===\n")
cat("If identification is valid, ΔLF(1930→1940) should NOT predict mobilization.\n\n")

# Men's pre-trend
men3 <- panel3[female_1940 == 0]
pt_m1 <- feols(d_in_lf_30_40 ~ mob_std, data = men3, cluster = ~statefip_1940)
pt_m2 <- feols(d_in_lf_30_40 ~ mob_std + age_1940 + I(age_1940^2) |
               region, data = men3, cluster = ~statefip_1940)

cat("--- Men: ΔLF(1930→1940) on Mobilization ---\n")
cat(sprintf("(PT-M1) Unconditional: β = %.4f (SE = %.4f, p = %.3f)\n",
    coef(pt_m1)["mob_std"], sqrt(vcov(pt_m1)["mob_std", "mob_std"]),
    2 * pnorm(-abs(coef(pt_m1)["mob_std"] / sqrt(vcov(pt_m1)["mob_std", "mob_std"])))))
cat(sprintf("(PT-M2) Region FE:     β = %.4f (SE = %.4f, p = %.3f)\n",
    coef(pt_m2)["mob_std"], sqrt(vcov(pt_m2)["mob_std", "mob_std"]),
    2 * pnorm(-abs(coef(pt_m2)["mob_std"] / sqrt(vcov(pt_m2)["mob_std", "mob_std"])))))

# Wives' pre-trend (3-period couples)
pt_w1 <- feols(wife_d_in_lf_30_40 ~ mob_std, data = couples3, cluster = ~statefip_1940)
pt_w2 <- feols(wife_d_in_lf_30_40 ~ mob_std + sp_age_1940 + I(sp_age_1940^2) +
               husband_age_1940 | region, data = couples3, cluster = ~statefip_1940)

cat("\n--- Wives: ΔLF(1930→1940) on Mobilization ---\n")
cat(sprintf("(PT-W1) Unconditional: β = %.4f (SE = %.4f, p = %.3f)\n",
    coef(pt_w1)["mob_std"], sqrt(vcov(pt_w1)["mob_std", "mob_std"]),
    2 * pnorm(-abs(coef(pt_w1)["mob_std"] / sqrt(vcov(pt_w1)["mob_std", "mob_std"])))))
cat(sprintf("(PT-W2) Region FE:     β = %.4f (SE = %.4f, p = %.3f)\n",
    coef(pt_w2)["mob_std"], sqrt(vcov(pt_w2)["mob_std", "mob_std"]),
    2 * pnorm(-abs(coef(pt_w2)["mob_std"] / sqrt(vcov(pt_w2)["mob_std", "mob_std"])))))

# Pre-trend event study: stack both periods, interact Mob × Period
men3_long <- rbind(
  men3[, .(histid_1940, d_lf = d_in_lf_30_40, period = "1930-1940",
           age_1940, mob_std, statefip_1940, region)],
  men3[, .(histid_1940, d_lf = d_in_lf_40_50, period = "1940-1950",
           age_1940, mob_std, statefip_1940, region)]
)
men3_long[, post := as.integer(period == "1940-1950")]

es_men <- feols(d_lf ~ mob_std * post + age_1940 + I(age_1940^2) |
                region, data = men3_long, cluster = ~statefip_1940)

cat("\n--- Event Study (Men): Mob × Period Interaction ---\n")
cat(sprintf("  mob_std (pre):          β = %.4f (SE = %.4f)\n",
    coef(es_men)["mob_std"], sqrt(vcov(es_men)["mob_std", "mob_std"])))
cat(sprintf("  mob_std × post (diff):  β = %.4f (SE = %.4f)\n",
    coef(es_men)["mob_std:post"], sqrt(vcov(es_men)["mob_std:post", "mob_std:post"])))

# Same for wives
couples3_long <- rbind(
  couples3[, .(histid_1940, d_lf = wife_d_in_lf_30_40, period = "1930-1940",
               sp_age_1940, husband_age_1940, mob_std, statefip_1940, region)],
  couples3[, .(histid_1940, d_lf = wife_d_in_lf_40_50, period = "1940-1950",
               sp_age_1940, husband_age_1940, mob_std, statefip_1940, region)]
)
couples3_long[, post := as.integer(period == "1940-1950")]

es_wives <- feols(d_lf ~ mob_std * post + sp_age_1940 + husband_age_1940 |
                  region, data = couples3_long, cluster = ~statefip_1940)

cat("\n--- Event Study (Wives): Mob × Period Interaction ---\n")
cat(sprintf("  mob_std (pre):          β = %.4f (SE = %.4f)\n",
    coef(es_wives)["mob_std"], sqrt(vcov(es_wives)["mob_std", "mob_std"])))
cat(sprintf("  mob_std × post (diff):  β = %.4f (SE = %.4f)\n",
    coef(es_wives)["mob_std:post"], sqrt(vcov(es_wives)["mob_std:post", "mob_std:post"])))

# Save row counts before freeing 3-period panels (needed for summary stats)
n_panel3_saved <- nrow(panel3)
n_couples3_saved <- nrow(couples3)
rm(men3, men3_long, couples3_long, panel3, couples3); gc()
cat("  (Freed 3-period panels from memory after pre-trend tests)\n")


## --------------------------------------------------------------------------
## 3. MEN'S INDIVIDUAL FIRST-DIFFERENCE (1940→1950)
## --------------------------------------------------------------------------

cat("\n=== Men's Individual First-Difference ===\n")

men <- panel[female_1940 == 0]

m1_lf <- feols(d_in_lf ~ mob_std, data = men, cluster = ~statefip_1940)
m2_lf <- feols(d_in_lf ~ mob_std + age_1940 + I(age_1940^2) +
               educ_years_1940 + married_1940 + is_farm_1940,
               data = men, cluster = ~statefip_1940)
m3_lf <- feols(d_in_lf ~ mob_std + age_1940 + I(age_1940^2) +
               educ_years_1940 + married_1940 + is_farm_1940 |
               region, data = men, cluster = ~statefip_1940)
m4_lf <- feols(d_in_lf ~ mob_std + age_1940 + I(age_1940^2) +
               educ_years_1940 + married_1940 + is_farm_1940 |
               region, data = men[mover == 0], cluster = ~statefip_1940)

# M5: With state-level baseline controls (added variable approach)
m5_lf <- tryCatch({
  sc_cols <- state_analysis[, .(statefip,
    pct_farm_st = pct_farm, pct_black_st = pct_black,
    mean_educ_st = mean_educ, pct_married_st = pct_married)]
  men_sc <- merge(men, sc_cols, by.x = "statefip_1940", by.y = "statefip", all.x = TRUE)
  feols(d_in_lf ~ mob_std + age_1940 + I(age_1940^2) +
        educ_years_1940 + married_1940 + is_farm_1940 +
        pct_farm_st + pct_black_st + mean_educ_st + pct_married_st |
        region, data = men_sc, cluster = ~statefip_1940)
}, error = function(e) { cat(sprintf("  M5 skipped: %s\n", e$message)); NULL })

cat("--- Men: ΔLF on Mobilization ---\n")
for (nm in c("m1_lf", "m2_lf", "m3_lf", "m4_lf")) {
  m <- get(nm)
  cat(sprintf("(%s) β = %.4f (SE = %.4f) [95%% CI: %.4f, %.4f]\n",
      nm, coef(m)["mob_std"], sqrt(vcov(m)["mob_std", "mob_std"]),
      coef(m)["mob_std"] - 1.96 * sqrt(vcov(m)["mob_std", "mob_std"]),
      coef(m)["mob_std"] + 1.96 * sqrt(vcov(m)["mob_std", "mob_std"])))
}

# Occupation
m6_occ <- feols(d_occ_score ~ mob_std + age_1940 + I(age_1940^2) +
                educ_years_1940 + married_1940 + is_farm_1940 |
                region, data = men, cluster = ~statefip_1940)


## --------------------------------------------------------------------------
## 4. WIVES' FIRST-DIFFERENCE (Couples Panel)
## --------------------------------------------------------------------------

cat("\n=== Wives' First-Difference (Couples Panel) ===\n")

w1_lf <- feols(wife_d_in_lf ~ mob_std, data = couples, cluster = ~statefip_1940)
w2_lf <- feols(wife_d_in_lf ~ mob_std + sp_age_1940 + I(sp_age_1940^2) +
               sp_educ_years_1940,
               data = couples, cluster = ~statefip_1940)
w3_lf <- feols(wife_d_in_lf ~ mob_std + sp_age_1940 + I(sp_age_1940^2) +
               sp_educ_years_1940 + husband_age_1940 + husband_occ_score_1940 |
               region, data = couples, cluster = ~statefip_1940)
w4_lf <- feols(wife_d_in_lf ~ mob_std + sp_age_1940 + I(sp_age_1940^2) +
               sp_educ_years_1940 + husband_age_1940 + husband_occ_score_1940 +
               husband_in_lf_1940 |
               region, data = couples, cluster = ~statefip_1940)

# W5: With state-level baseline controls
w5_lf <- tryCatch({
  sc_cols <- state_analysis[, .(statefip,
    pct_farm_st = pct_farm, pct_black_st = pct_black,
    mean_educ_st = mean_educ, pct_married_st = pct_married)]
  couples_sc <- merge(couples, sc_cols, by.x = "statefip_1940", by.y = "statefip", all.x = TRUE)
  feols(wife_d_in_lf ~ mob_std + sp_age_1940 + I(sp_age_1940^2) +
        sp_educ_years_1940 + husband_age_1940 + husband_occ_score_1940 +
        pct_farm_st + pct_black_st + mean_educ_st + pct_married_st |
        region, data = couples_sc, cluster = ~statefip_1940)
}, error = function(e) { cat(sprintf("  W5 skipped: %s\n", e$message)); NULL })

cat("--- Wives: ΔLF on Mobilization ---\n")
for (nm in c("w1_lf", "w2_lf", "w3_lf", "w4_lf")) {
  m <- get(nm)
  cat(sprintf("(%s) β = %.4f (SE = %.4f) [95%% CI: %.4f, %.4f]\n",
      nm, coef(m)["mob_std"], sqrt(vcov(m)["mob_std", "mob_std"]),
      coef(m)["mob_std"] - 1.96 * sqrt(vcov(m)["mob_std", "mob_std"]),
      coef(m)["mob_std"] + 1.96 * sqrt(vcov(m)["mob_std", "mob_std"])))
}

# Wives occupation
w6_occ <- tryCatch(
  feols(wife_d_occ_score ~ mob_std + sp_age_1940 + I(sp_age_1940^2) +
        sp_educ_years_1940 + husband_age_1940 |
        region, data = couples, cluster = ~statefip_1940),
  error = function(e) { cat(sprintf("  W6 skipped: %s\n", e$message)); NULL }
)


## --------------------------------------------------------------------------
## 5. HUSBAND-WIFE DYNAMICS
## --------------------------------------------------------------------------

cat("\n=== Husband-Wife Joint Dynamics ===\n")

hw_lf <- tryCatch(
  feols(wife_d_in_lf ~ husband_d_in_lf + mob_std +
        sp_age_1940 + husband_age_1940 | region,
        data = couples, cluster = ~statefip_1940),
  error = function(e) { cat(sprintf("  HW_LF skipped: %s\n", e$message)); NULL }
)

if (!is.null(hw_lf)) {
  cat(sprintf("Husband ΔLF → Wife ΔLF: β = %.4f (SE = %.4f)\n",
      coef(hw_lf)["husband_d_in_lf"],
      sqrt(vcov(hw_lf)["husband_d_in_lf", "husband_d_in_lf"])))
}


## --------------------------------------------------------------------------
## 6. STATE-LEVEL CROSS-VALIDATION
## --------------------------------------------------------------------------

cat("\n=== State-Level Cross-Validation ===\n")

# Use married-women aggregate (reviewer demand: comparable to within-couple)
s1_lf <- feols(d_mw_lfp ~ mob_std,
               data = state_analysis, weights = ~n_mw_40)
s2_lf <- feols(d_mw_lfp ~ mob_std + pct_farm + pct_black + mean_educ + pct_married,
               data = state_analysis, weights = ~n_mw_40)

# HC2/HC3 for state-level
state_lm <- lm(d_mw_lfp ~ mob_std + pct_farm + pct_black + mean_educ + pct_married,
               data = state_analysis, weights = n_mw_40)
se_hc2 <- sqrt(diag(sandwich::vcovHC(state_lm, type = "HC2")))["mob_std"]
se_hc3 <- sqrt(diag(sandwich::vcovHC(state_lm, type = "HC3")))["mob_std"]

cat(sprintf("State-level Δ(Married Women LFP):\n"))
cat(sprintf("  (S1) Unconditional: β = %.4f (SE = %.4f)\n",
    coef(s1_lf)["mob_std"], sqrt(vcov(s1_lf)["mob_std", "mob_std"])))
cat(sprintf("  (S2) With controls: β = %.4f (SE = %.4f)\n",
    coef(s2_lf)["mob_std"], sqrt(vcov(s2_lf)["mob_std", "mob_std"])))
cat(sprintf("  HC2 SE = %.4f, HC3 SE = %.4f\n", se_hc2, se_hc3))

# Also run on all-women aggregate for comparison
s3_lf <- feols(d_aw_lfp ~ mob_std + pct_farm + pct_black + mean_educ + pct_married,
               data = state_analysis, weights = ~n_aw_40)


## --------------------------------------------------------------------------
## 7. MARRIED-WOMEN DECOMPOSITION
## --------------------------------------------------------------------------

cat("\n=== Married-Women Decomposition ===\n")

cat(sprintf("Married-women aggregate LFP change:  %.4f\n", decomp$agg_d_married_women))
cat(sprintf("All-women aggregate LFP change:      %.4f\n", decomp$agg_d_all_women))
cat(sprintf("Within-couple wife LFP change:       %.4f\n", decomp$within_wife_d_lf))
cat(sprintf("Compositional gap (married women):   %.4f\n",
    decomp$agg_d_married_women - decomp$within_wife_d_lf))
cat(sprintf("Within-person men LFP change:        %.4f\n", decomp$within_m_d_lf))

# By mobilization quintile (men)
decomp_by_mob_men <- panel[female_1940 == 0, .(
  within_d_lf = mean(d_in_lf, na.rm = TRUE),
  within_d_occ = mean(d_occ_score, na.rm = TRUE),
  n = .N
), by = mob_quintile][order(mob_quintile)]

decomp_by_mob_wives <- couples[, .(
  wife_d_lf = mean(wife_d_in_lf, na.rm = TRUE),
  wife_d_occ = mean(wife_d_occ_score, na.rm = TRUE),
  n = .N
), by = mob_quintile][order(mob_quintile)]

cat("\nMen's changes by mobilization quintile:\n")
print(decomp_by_mob_men)
cat("\nWives' changes by mobilization quintile:\n")
print(decomp_by_mob_wives)

# Free individual panel — only couples needed for heterogeneity
n_panel_saved <- nrow(panel)
n_men_saved <- sum(panel$female_1940 == 0)
rm(list = intersect(c("panel", "men", "men_sc"), ls())); gc()
cat("  (Freed individual panel from memory)\n")


## --------------------------------------------------------------------------
## 8. HETEROGENEITY (Wives)
## --------------------------------------------------------------------------

cat("\n=== Heterogeneity Analysis (Wives) ===\n")

het_race <- couples[, {
  if (.N > 100) {
    m <- feols(wife_d_in_lf ~ mob_std + sp_age_1940, data = .SD, cluster = ~statefip_1940)
    list(beta = coef(m)["mob_std"],
         se = sqrt(vcov(m)["mob_std", "mob_std"]),
         n = .N)
  } else {
    list(beta = NA_real_, se = NA_real_, n = .N)
  }
}, by = sp_race_cat_1940]
cat("By wife's race:\n")
print(het_race)

het_prelf <- couples[, {
  m <- feols(wife_d_in_lf ~ mob_std + sp_age_1940, data = .SD, cluster = ~statefip_1940)
  list(beta = coef(m)["mob_std"],
       se = sqrt(vcov(m)["mob_std", "mob_std"]),
       n = .N)
}, by = .(wife_pre_lf = sp_in_lf_1940)]
cat("\nBy wife's 1940 LF status:\n")
print(het_prelf)

couples[, wife_age_bin := fcase(
  sp_age_1940 >= 18 & sp_age_1940 <= 30, "Young (18-30)",
  sp_age_1940 >= 31 & sp_age_1940 <= 45, "Prime (31-45)",
  default = "Older (46+)")]

het_age <- couples[, {
  if (.N > 100) {
    m <- feols(wife_d_in_lf ~ mob_std + sp_age_1940, data = .SD, cluster = ~statefip_1940)
    list(beta = coef(m)["mob_std"],
         se = sqrt(vcov(m)["mob_std", "mob_std"]),
         n = .N)
  } else {
    list(beta = NA_real_, se = NA_real_, n = .N)
  }
}, by = wife_age_bin]
cat("\nBy wife's age group:\n")
print(het_age)


## --------------------------------------------------------------------------
## 9. Save All Models
## --------------------------------------------------------------------------

cat("\n=== Saving Models ===\n")

models <- list(
  # Pre-trend
  pt_m1 = pt_m1, pt_m2 = pt_m2, pt_w1 = pt_w1, pt_w2 = pt_w2,
  es_men = es_men, es_wives = es_wives,
  # Men first-difference
  m1_lf = m1_lf, m2_lf = m2_lf, m3_lf = m3_lf, m4_lf = m4_lf,
  m5_lf = m5_lf, m6_occ = m6_occ,
  # Wives first-difference
  w1_lf = w1_lf, w2_lf = w2_lf, w3_lf = w3_lf, w4_lf = w4_lf,
  w5_lf = w5_lf, w6_occ = w6_occ,
  # Husband-wife dynamics
  hw_lf = hw_lf,
  # State-level
  s1_lf = s1_lf, s2_lf = s2_lf, s3_lf = s3_lf,
  state_lm = state_lm, se_hc2 = se_hc2, se_hc3 = se_hc3
)

saveRDS(models, file.path(data_dir, "main_models.rds"))

decomp_results <- list(
  married_women = list(d_agg = decomp$agg_d_married_women,
                       d_within = decomp$within_wife_d_lf,
                       gap = decomp$agg_d_married_women - decomp$within_wife_d_lf),
  all_women = list(d_agg = decomp$agg_d_all_women,
                   d_within = decomp$within_wife_d_lf,
                   gap = decomp$agg_d_all_women - decomp$within_wife_d_lf),
  men = list(d_within = decomp$within_m_d_lf),
  by_quintile_men = decomp_by_mob_men,
  by_quintile_wives = decomp_by_mob_wives
)
saveRDS(decomp_results, file.path(data_dir, "decomposition.rds"))

sumstats <- list(
  n_panel = n_panel_saved,
  n_men = n_men_saved,
  n_couples = nrow(couples),
  n_panel3 = n_panel3_saved,
  n_couples3 = n_couples3_saved,
  n_states = nrow(state_analysis),
  linking_method = "MLP v2 (Helgertz et al. 2023)"
)
saveRDS(sumstats, file.path(data_dir, "summary_stats.rds"))

het_results <- list(race = het_race, prelf = het_prelf, age = het_age)
saveRDS(het_results, file.path(data_dir, "heterogeneity.rds"))

cat("\nAll models saved. Proceed to 04_robustness.R\n")
