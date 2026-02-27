## ============================================================================
## 03_main_analysis.R — Longitudinal Analysis with Census Linking Project Data
## Missing Men, Rising Women v2 (apep_0469)
## ============================================================================
## Two-panel design:
##   1. INDIVIDUAL PANEL (14M linked men): ΔY_i = α + β·Mob_s + γ·X_{i,1940} + δ + ε
##   2. COUPLES PANEL (5.6M couples): ΔWife_Y_c = α + β·Mob_s + γ·X_{c,1940} + δ + ε
##
## The ABE crosswalk (Abramitzky et al. 2025) links men individually across
## 1940-1950 censuses. Wives are tracked through their husbands' households.
## ============================================================================

source("code/00_packages.R")

data_dir <- "data"

## --------------------------------------------------------------------------
## 1. Load Data
## --------------------------------------------------------------------------

cat("=== Loading Analysis Datasets ===\n")

panel <- readRDS(file.path(data_dir, "linked_panel_40_50.rds"))
couples <- readRDS(file.path(data_dir, "couples_panel_40_50.rds"))
state_analysis <- readRDS(file.path(data_dir, "state_analysis.rds"))
state_controls <- readRDS(file.path(data_dir, "state_controls.rds"))
decomp <- readRDS(file.path(data_dir, "decomposition_inputs.rds"))

cat(sprintf("Individual panel: %s men\n", format(nrow(panel), big.mark = ",")))
cat(sprintf("Couples panel:    %s couples\n", format(nrow(couples), big.mark = ",")))
cat(sprintf("States:           %d\n", uniqueN(panel$statefip_1940)))

# Region variable for men
panel[, region := fcase(
  statefip_1940 %in% c(9, 23, 25, 33, 34, 36, 42, 44, 50), "Northeast",
  statefip_1940 %in% c(17, 18, 19, 20, 26, 27, 29, 31, 38, 39, 46, 55), "Midwest",
  statefip_1940 %in% c(1, 5, 10, 11, 12, 13, 21, 22, 24, 28, 37, 40, 45, 47, 48, 51, 54), "South",
  default = "West"
)]

# Region variable for couples
couples[, region := fcase(
  statefip_1940 %in% c(9, 23, 25, 33, 34, 36, 42, 44, 50), "Northeast",
  statefip_1940 %in% c(17, 18, 19, 20, 26, 27, 29, 31, 38, 39, 46, 55), "Midwest",
  statefip_1940 %in% c(1, 5, 10, 11, 12, 13, 21, 22, 24, 28, 37, 40, 45, 47, 48, 51, 54), "South",
  default = "West"
)]


## --------------------------------------------------------------------------
## 2. MEN'S INDIVIDUAL FIRST-DIFFERENCE
## --------------------------------------------------------------------------

cat("\n=== Men's Individual First-Difference ===\n")

# (M1) Unconditional: ΔLF = α + β·mob_std + ε
m1_lf <- feols(d_in_lf ~ mob_std, data = panel, cluster = ~statefip_1940)

# (M2) With 1940 controls
m2_lf <- feols(d_in_lf ~ mob_std + age_1940 + I(age_1940^2) +
               educ_years_1940 + married_1940 + is_urban_1940 + is_farm_1940,
               data = panel, cluster = ~statefip_1940)

# (M3) With region FE
m3_lf <- feols(d_in_lf ~ mob_std + age_1940 + I(age_1940^2) +
               educ_years_1940 + married_1940 + is_urban_1940 + is_farm_1940 |
               region, data = panel, cluster = ~statefip_1940)

# (M4) Non-movers only
m4_lf <- feols(d_in_lf ~ mob_std + age_1940 + I(age_1940^2) +
               educ_years_1940 + married_1940 + is_urban_1940 + is_farm_1940 |
               region, data = panel[mover == 0], cluster = ~statefip_1940)

cat("--- Men: ΔLF on Mobilization ---\n")
cat(sprintf("(M1) Unconditional:  β = %.4f (SE = %.4f)\n",
    coef(m1_lf)["mob_std"], sqrt(vcov(m1_lf)["mob_std", "mob_std"])))
cat(sprintf("(M2) With controls:  β = %.4f (SE = %.4f)\n",
    coef(m2_lf)["mob_std"], sqrt(vcov(m2_lf)["mob_std", "mob_std"])))
cat(sprintf("(M3) Region FE:      β = %.4f (SE = %.4f)\n",
    coef(m3_lf)["mob_std"], sqrt(vcov(m3_lf)["mob_std", "mob_std"])))
cat(sprintf("(M4) Non-movers:     β = %.4f (SE = %.4f)\n",
    coef(m4_lf)["mob_std"], sqrt(vcov(m4_lf)["mob_std", "mob_std"])))


## --------------------------------------------------------------------------
## 3. MEN'S OCCUPATION SCORES
## --------------------------------------------------------------------------

cat("\n=== Men's Occupation Score Changes ===\n")

m5_occ <- feols(d_occ_score ~ mob_std + age_1940 + I(age_1940^2) +
                educ_years_1940 + married_1940 + is_urban_1940 + is_farm_1940 |
                region, data = panel, cluster = ~statefip_1940)

m6_sei <- tryCatch(
  feols(d_sei_score ~ mob_std + age_1940 + I(age_1940^2) +
        educ_years_1940 + married_1940 + is_urban_1940 + is_farm_1940 |
        region, data = panel, cluster = ~statefip_1940),
  error = function(e) {
    cat(sprintf("  SEI regression skipped: %s\n", e$message))
    NULL
  }
)

cat(sprintf("(M5) ΔOccScore:  β = %.4f (SE = %.4f)\n",
    coef(m5_occ)["mob_std"], sqrt(vcov(m5_occ)["mob_std", "mob_std"])))
if (!is.null(m6_sei)) {
  cat(sprintf("(M6) ΔSEI:       β = %.4f (SE = %.4f)\n",
      coef(m6_sei)["mob_std"], sqrt(vcov(m6_sei)["mob_std", "mob_std"])))
} else {
  cat("(M6) ΔSEI:       skipped (insufficient variation)\n")
}


## --------------------------------------------------------------------------
## 4. WIVES' FIRST-DIFFERENCE (via Couples Panel)
## --------------------------------------------------------------------------

cat("\n=== Wives' First-Difference (Couples Panel) ===\n")

# (W1) Unconditional: ΔWifeLF = α + β·mob_std + ε
w1_lf <- feols(wife_d_in_lf ~ mob_std, data = couples, cluster = ~statefip_1940)

# (W2) With wife's 1940 controls
w2_lf <- feols(wife_d_in_lf ~ mob_std + sp_age_1940 + I(sp_age_1940^2) +
               sp_educ_years_1940 + sp_married_1940,
               data = couples, cluster = ~statefip_1940)

# (W3) With region FE + husband controls
w3_lf <- feols(wife_d_in_lf ~ mob_std + sp_age_1940 + I(sp_age_1940^2) +
               sp_educ_years_1940 + husband_age_1940 + husband_occ_score_1940 |
               region, data = couples, cluster = ~statefip_1940)

# (W4) With full set of controls
w4_lf <- feols(wife_d_in_lf ~ mob_std + sp_age_1940 + I(sp_age_1940^2) +
               sp_educ_years_1940 + husband_age_1940 + husband_occ_score_1940 +
               husband_in_lf_1940 |
               region, data = couples, cluster = ~statefip_1940)

cat("--- Wives: ΔLF on Mobilization ---\n")
cat(sprintf("(W1) Unconditional:         β = %.4f (SE = %.4f)\n",
    coef(w1_lf)["mob_std"], sqrt(vcov(w1_lf)["mob_std", "mob_std"])))
cat(sprintf("(W2) Wife controls:         β = %.4f (SE = %.4f)\n",
    coef(w2_lf)["mob_std"], sqrt(vcov(w2_lf)["mob_std", "mob_std"])))
cat(sprintf("(W3) Region FE + husband:   β = %.4f (SE = %.4f)\n",
    coef(w3_lf)["mob_std"], sqrt(vcov(w3_lf)["mob_std", "mob_std"])))
cat(sprintf("(W4) Full controls:         β = %.4f (SE = %.4f)\n",
    coef(w4_lf)["mob_std"], sqrt(vcov(w4_lf)["mob_std", "mob_std"])))


## --------------------------------------------------------------------------
## 5. WIVES' OCCUPATION & EMPLOYMENT
## --------------------------------------------------------------------------

cat("\n=== Wives' Occupation & Employment ===\n")

w5_occ <- tryCatch(
  feols(wife_d_occ_score ~ mob_std + sp_age_1940 + I(sp_age_1940^2) +
        sp_educ_years_1940 + husband_age_1940 |
        region, data = couples, cluster = ~statefip_1940),
  error = function(e) { cat(sprintf("  W5 skipped: %s\n", e$message)); NULL }
)

w6_emp <- tryCatch(
  feols(wife_d_employed ~ mob_std + sp_age_1940 + I(sp_age_1940^2) +
        sp_educ_years_1940 + husband_age_1940 |
        region, data = couples, cluster = ~statefip_1940),
  error = function(e) { cat(sprintf("  W6 skipped: %s\n", e$message)); NULL }
)

if (!is.null(w5_occ)) {
  cat(sprintf("(W5) ΔOccScore:    β = %.4f (SE = %.4f)\n",
      coef(w5_occ)["mob_std"], sqrt(vcov(w5_occ)["mob_std", "mob_std"])))
} else {
  cat("(W5) ΔOccScore:    skipped (insufficient variation)\n")
}
if (!is.null(w6_emp)) {
  cat(sprintf("(W6) ΔEmployed:    β = %.4f (SE = %.4f)\n",
      coef(w6_emp)["mob_std"], sqrt(vcov(w6_emp)["mob_std", "mob_std"])))
} else {
  cat("(W6) ΔEmployed:    skipped (insufficient variation)\n")
}


## --------------------------------------------------------------------------
## 6. HUSBAND-WIFE JOINT DYNAMICS
## --------------------------------------------------------------------------

cat("\n=== Husband-Wife Joint Dynamics ===\n")

# Does husband's LF exit predict wife's LF entry?
hw_lf <- tryCatch(
  feols(wife_d_in_lf ~ husband_d_in_lf + mob_std +
        sp_age_1940 + husband_age_1940 | region,
        data = couples, cluster = ~statefip_1940),
  error = function(e) { cat(sprintf("  HW_LF skipped: %s\n", e$message)); NULL }
)

# Does husband's occupation change affect wife's?
hw_occ <- tryCatch(
  feols(wife_d_occ_score ~ husband_d_employed + mob_std +
        sp_age_1940 + husband_age_1940 | region,
        data = couples, cluster = ~statefip_1940),
  error = function(e) { cat(sprintf("  HW_OCC skipped: %s\n", e$message)); NULL }
)

if (!is.null(hw_lf)) {
  cat(sprintf("Husband ΔLF → Wife ΔLF:    β = %.4f (SE = %.4f)\n",
      coef(hw_lf)["husband_d_in_lf"],
      sqrt(vcov(hw_lf)["husband_d_in_lf", "husband_d_in_lf"])))
} else {
  cat("Husband ΔLF → Wife ΔLF:    skipped\n")
}


## --------------------------------------------------------------------------
## 7. STATE-LEVEL CROSS-VALIDATION
## --------------------------------------------------------------------------

cat("\n=== State-Level Cross-Validation ===\n")

state_analysis <- merge(state_analysis, state_controls, by = "statefip",
                        all.x = TRUE, suffixes = c("", "_dup"))
dup_cols <- grep("_dup$", names(state_analysis), value = TRUE)
if (length(dup_cols) > 0) state_analysis[, (dup_cols) := NULL]

s1_lf <- feols(d_lf_female ~ mob_std,
               data = state_analysis, weights = ~total_pop)

s2_lf <- feols(d_lf_female ~ mob_std + pct_urban + pct_farm + pct_black +
               mean_educ + pct_married,
               data = state_analysis, weights = ~total_pop)

cat(sprintf("State-level ΔLF_female:\n"))
cat(sprintf("  (S1) Unconditional: β = %.4f (SE = %.4f)\n",
    coef(s1_lf)["mob_std"], sqrt(vcov(s1_lf)["mob_std", "mob_std"])))
cat(sprintf("  (S2) With controls: β = %.4f (SE = %.4f)\n",
    coef(s2_lf)["mob_std"], sqrt(vcov(s2_lf)["mob_std", "mob_std"])))


## --------------------------------------------------------------------------
## 8. DECOMPOSITION
## --------------------------------------------------------------------------

cat("\n=== Decomposition ===\n")

agg_d_f <- decomp$agg_f_lf_50 - decomp$agg_f_lf_40
within_wife <- decomp$within_wife_d_lf
comp_f <- agg_d_f - within_wife

cat(sprintf("Female LFP:\n"))
cat(sprintf("  Aggregate change (1940-1950):    %.4f\n", agg_d_f))
cat(sprintf("  Within-couple wife change:       %.4f\n", within_wife))
cat(sprintf("  Compositional residual:          %.4f\n", comp_f))

agg_d_m <- decomp$agg_m_lf_50 - decomp$agg_m_lf_40
within_m <- decomp$within_m_d_lf

cat(sprintf("\nMale LFP:\n"))
cat(sprintf("  Aggregate change (1940-1950):    %.4f\n", agg_d_m))
cat(sprintf("  Within-person change:            %.4f\n", within_m))

# By mobilization quintile (men)
decomp_by_mob_men <- panel[, .(
  within_d_lf = mean(d_in_lf, na.rm = TRUE),
  within_d_occ = mean(d_occ_score, na.rm = TRUE),
  n = .N
), by = mob_quintile][order(mob_quintile)]

cat("\nMen's changes by mobilization quintile:\n")
print(decomp_by_mob_men)

# By mobilization quintile (wives)
decomp_by_mob_wives <- couples[, .(
  wife_d_lf = mean(wife_d_in_lf, na.rm = TRUE),
  wife_d_occ = mean(wife_d_occ_score, na.rm = TRUE),
  n = .N
), by = mob_quintile][order(mob_quintile)]

cat("\nWives' changes by mobilization quintile:\n")
print(decomp_by_mob_wives)


## --------------------------------------------------------------------------
## 9. HETEROGENEITY (Wives)
## --------------------------------------------------------------------------

cat("\n=== Heterogeneity Analysis (Wives) ===\n")

# By wife's race
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

# By wife's pre-war LF status
het_prelf <- couples[, {
  m <- feols(wife_d_in_lf ~ mob_std + sp_age_1940, data = .SD, cluster = ~statefip_1940)
  list(beta = coef(m)["mob_std"],
       se = sqrt(vcov(m)["mob_std", "mob_std"]),
       n = .N)
}, by = .(wife_pre_lf = sp_in_lf_1940)]
cat("\nBy wife's 1940 LF status:\n")
print(het_prelf)

# By wife's age group
couples[, wife_age_bin := fcase(
  sp_age_1940 >= 18 & sp_age_1940 <= 30, "Young (18-30)",
  sp_age_1940 >= 31 & sp_age_1940 <= 45, "Prime (31-45)",
  default = "Older (46+)"
)]

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
## 10. Save All Models
## --------------------------------------------------------------------------

cat("\n=== Saving Models ===\n")

models <- list(
  # Men first-difference
  m1_lf = m1_lf, m2_lf = m2_lf, m3_lf = m3_lf, m4_lf = m4_lf,
  m5_occ = m5_occ, m6_sei = m6_sei,
  # Wives first-difference
  w1_lf = w1_lf, w2_lf = w2_lf, w3_lf = w3_lf, w4_lf = w4_lf,
  w5_occ = w5_occ, w6_emp = w6_emp,
  # Husband-wife dynamics
  hw_lf = hw_lf, hw_occ = hw_occ,
  # State-level
  s1_lf = s1_lf, s2_lf = s2_lf
)

saveRDS(models, file.path(data_dir, "main_models.rds"))

# Decomposition results
decomp_results <- list(
  aggregate = list(d_f_lf = agg_d_f, d_m_lf = agg_d_m),
  within = list(wife_d_lf = within_wife, m_d_lf = within_m),
  compositional = list(d_f_lf = comp_f),
  by_quintile_men = decomp_by_mob_men,
  by_quintile_wives = decomp_by_mob_wives
)
saveRDS(decomp_results, file.path(data_dir, "decomposition.rds"))

# Summary statistics
sumstats <- list(
  n_men = nrow(panel),
  n_couples = nrow(couples),
  n_states = uniqueN(panel$statefip_1940),
  pct_movers = mean(panel$mover),
  mean_d_lf_men = mean(panel$d_in_lf, na.rm = TRUE),
  mean_d_lf_wives = mean(couples$wife_d_in_lf, na.rm = TRUE),
  linking_method = "ABE exact conservative"
)
saveRDS(sumstats, file.path(data_dir, "summary_stats.rds"))

# Heterogeneity
het_results <- list(race = het_race, prelf = het_prelf, age = het_age)
saveRDS(het_results, file.path(data_dir, "heterogeneity.rds"))

cat("\nAll models saved. Proceed to 04_robustness.R\n")
