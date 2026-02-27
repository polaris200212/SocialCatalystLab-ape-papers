## ============================================================================
## 03_main_analysis.R — Core Empirical Analysis
## Missing Men, Rising Women (apep_0469)
## ============================================================================
## Primary design: State-level repeated cross-section DiD
##   Instrument: WWII mobilization rates (CenSoc enlistment / IPUMS male pop)
##   Outcome: Female LFP, occupation, employment in 1940 vs 1950
##   Individual-level triple-diff: female × post × mobilization
## ============================================================================

source("code/00_packages.R")
data_dir <- "data"

## Load
state_analysis <- readRDS(file.path(data_dir, "state_analysis.rds"))
state_mob <- readRDS(file.path(data_dir, "state_mobilization.rds"))
indiv_panel <- readRDS(file.path(data_dir, "indiv_panel.rds"))
baseline <- readRDS(file.path(data_dir, "baseline_1940.rds"))

cat(sprintf("State analysis: %d states\n", nrow(state_analysis)))
cat(sprintf("Individual panel: %s observations\n", format(nrow(indiv_panel), big.mark = ",")))


## --------------------------------------------------------------------------
## 1. DESCRIPTIVE STATISTICS (Table 1)
## --------------------------------------------------------------------------

cat("\n=== Table 1: Summary Statistics ===\n")

# Panel A: 1940 characteristics by gender
summ_1940 <- indiv_panel[year == 1940, .(
  N = format(.N, big.mark = ","),
  Age = round(weighted.mean(age, perwt), 1),
  `In LF` = round(weighted.mean(in_lf, perwt, na.rm = TRUE), 3),
  `Occ Score` = round(weighted.mean(occ_score, perwt, na.rm = TRUE), 1),
  Education = round(weighted.mean(educ_years, perwt, na.rm = TRUE), 1),
  Married = round(weighted.mean(married, perwt, na.rm = TRUE), 3),
  `HH Head` = round(weighted.mean(is_head, perwt, na.rm = TRUE), 3),
  Urban = round(weighted.mean(is_urban, perwt, na.rm = TRUE), 3),
  White = round(weighted.mean(race_cat == "White", perwt), 3),
  Black = round(weighted.mean(race_cat == "Black", perwt), 3)
), by = .(Gender = fifelse(female == 1, "Women", "Men"))]

cat("Panel A: 1940 Baseline\n")
print(summ_1940)

# Panel B: Levels and changes 1940-1950
summ_trend <- rbind(
  indiv_panel[, .(
    LFP = weighted.mean(in_lf, perwt, na.rm = TRUE),
    Employed = weighted.mean(employed, perwt, na.rm = TRUE),
    `Occ Score` = weighted.mean(occ_score, perwt, na.rm = TRUE),
    `HH Head` = weighted.mean(is_head, perwt, na.rm = TRUE)
  ), by = .(Gender = fifelse(female == 1, "Women", "Men"), Year = year)]
)

cat("\nPanel B: Trends\n")
print(dcast(summ_trend, Gender ~ Year, value.var = c("LFP", "Occ Score")))

# Panel C: By mobilization quintile (women, 1940)
summ_mob <- baseline[female == 1, .(
  N = .N,
  LFP = round(weighted.mean(in_lf, perwt, na.rm = TRUE), 3),
  `Occ Score` = round(weighted.mean(occ_score, perwt, na.rm = TRUE), 1),
  Education = round(weighted.mean(educ_years, perwt, na.rm = TRUE), 1),
  Married = round(weighted.mean(married, perwt, na.rm = TRUE), 3),
  Urban = round(weighted.mean(is_urban, perwt, na.rm = TRUE), 3)
), by = mob_quintile]

cat("\nPanel C: Women's 1940 Baseline by Mobilization Quintile\n")
print(summ_mob[order(mob_quintile)])

saveRDS(list(panel_a = summ_1940, panel_b = summ_trend, panel_c = summ_mob),
        file.path(data_dir, "summary_stats.rds"))


## --------------------------------------------------------------------------
## 2. AGGREGATE DECOMPOSITION
## --------------------------------------------------------------------------

cat("\n=== Decomposition: Gender Gap Changes ===\n")

# National-level gender gaps 1940 vs 1950
gap_lf <- indiv_panel[, .(lf = weighted.mean(in_lf, perwt, na.rm = TRUE)),
                      by = .(year, female)]
gap_occ <- indiv_panel[, .(occ = weighted.mean(occ_score, perwt, na.rm = TRUE)),
                       by = .(year, female)]

decomp <- data.table(
  outcome = c("Labor Force Part.", "Occupation Score"),
  female_1940 = c(gap_lf[year == 1940 & female == 1]$lf,
                  gap_occ[year == 1940 & female == 1]$occ),
  male_1940 = c(gap_lf[year == 1940 & female == 0]$lf,
                gap_occ[year == 1940 & female == 0]$occ),
  female_1950 = c(gap_lf[year == 1950 & female == 1]$lf,
                  gap_occ[year == 1950 & female == 1]$occ),
  male_1950 = c(gap_lf[year == 1950 & female == 0]$lf,
                gap_occ[year == 1950 & female == 0]$occ)
)
decomp[, `:=`(
  gap_1940 = female_1940 - male_1940,
  gap_1950 = female_1950 - male_1950,
  d_female = female_1950 - female_1940,
  d_male = male_1950 - male_1940
)]
decomp[, gap_change := gap_1950 - gap_1940]

cat("National decomposition:\n")
print(decomp[, .(outcome, gap_1940 = round(gap_1940, 3), gap_1950 = round(gap_1950, 3),
                 gap_change = round(gap_change, 3),
                 d_female = round(d_female, 3), d_male = round(d_male, 3))])

# By mobilization quintile
decomp_by_mob <- indiv_panel[, .(
  lf_female = weighted.mean(in_lf[female == 1], perwt[female == 1], na.rm = TRUE),
  lf_male = weighted.mean(in_lf[female == 0], perwt[female == 0], na.rm = TRUE)
), by = .(year, mob_quintile)]
decomp_by_mob[, lf_gap := lf_female - lf_male]

cat("\nLFP Gender Gap by Mobilization × Year:\n")
print(dcast(decomp_by_mob, mob_quintile ~ year, value.var = "lf_gap"))

saveRDS(decomp, file.path(data_dir, "decomposition.rds"))
saveRDS(decomp_by_mob, file.path(data_dir, "decomp_by_mob.rds"))


## --------------------------------------------------------------------------
## 3. STATE-LEVEL FIRST-DIFFERENCE REGRESSIONS
## --------------------------------------------------------------------------

cat("\n=== State-Level DiD Regressions ===\n")

# Δ female LFP
s1_lf <- feols(d_lf_female ~ mob_std, data = state_analysis,
               weights = ~n_female_1940)
s2_lf <- feols(d_lf_female ~ mob_std + pct_urban + pct_black + pct_farm +
               mean_educ + mean_age + pct_married,
               data = state_analysis, weights = ~n_female_1940)

# Δ female occupation score
s1_occ <- feols(d_occ_female ~ mob_std, data = state_analysis,
                weights = ~n_female_1940)
s2_occ <- feols(d_occ_female ~ mob_std + pct_urban + pct_black + pct_farm +
                mean_educ + mean_age, data = state_analysis,
                weights = ~n_female_1940)

# Δ LFP gender gap
s1_gap <- feols(d_lf_gap ~ mob_std, data = state_analysis,
                weights = ~n_female_1940)
s2_gap <- feols(d_lf_gap ~ mob_std + pct_urban + pct_black + pct_farm +
                mean_educ + mean_age + pct_married,
                data = state_analysis, weights = ~n_female_1940)

# Δ male LFP (should be small or negative — men leaving LF due to injury/death)
s2_male <- feols(d_lf_male ~ mob_std + pct_urban + pct_black + pct_farm +
                 mean_educ + mean_age, data = state_analysis,
                 weights = ~n_male_1940)

cat("--- Δ Female LFP ---\n")
etable(s1_lf, s2_lf, headers = c("No controls", "Controls"), keep = "mob_std")

cat("\n--- Δ Female Occ Score ---\n")
etable(s1_occ, s2_occ, headers = c("No controls", "Controls"), keep = "mob_std")

cat("\n--- Δ LFP Gender Gap ---\n")
etable(s1_gap, s2_gap, headers = c("No controls", "Controls"), keep = "mob_std")

cat("\n--- Δ Male LFP ---\n")
etable(s2_male, keep = "mob_std")

# Additional outcomes
s_head <- feols(d_head_female ~ mob_std + pct_urban + pct_black + pct_farm +
                mean_educ + mean_age, data = state_analysis,
                weights = ~n_female_1940)
s_married <- feols(d_married_female ~ mob_std + pct_urban + pct_black + pct_farm +
                   mean_educ + mean_age, data = state_analysis,
                   weights = ~n_female_1940)
s_employed <- feols(d_employed_female ~ mob_std + pct_urban + pct_black + pct_farm +
                    mean_educ + mean_age, data = state_analysis,
                    weights = ~n_female_1940)

cat("\n--- Additional Outcomes ---\n")
etable(s_head, s_married, s_employed,
       headers = c("Δ Female Head", "Δ Female Married", "Δ Female Employed"),
       keep = "mob_std")


## --------------------------------------------------------------------------
## 4. INDIVIDUAL-LEVEL TRIPLE-DIFFERENCE
## --------------------------------------------------------------------------

cat("\n=== Individual-Level Triple-Difference ===\n")

# Y_ict = β₁(female × post × mob) + β₂(female × post) + β₃(post × mob)
#         + controls + state FE + year FE + ε

# Model 1: Baseline
t1_lf <- feols(in_lf ~ female_x_post_x_mob + female_x_post + post_x_mob + female_x_mob +
               age + I(age^2) | statefip + year,
               data = indiv_panel, cluster = ~statefip,
               weights = ~perwt)

# Note: is_urban = 100% NA in 1950, educ_years = 75% NA in 1950
# Use only controls available in both census years: age, race, married, is_farm

# Model 2: Full controls (available in both years)
t2_lf <- feols(in_lf ~ female_x_post_x_mob + female_x_post + post_x_mob + female_x_mob +
               age + I(age^2) + i(race_cat) + married + is_farm |
               statefip + year,
               data = indiv_panel, cluster = ~statefip,
               weights = ~perwt)

# Other outcomes
t2_occ <- feols(occ_score ~ female_x_post_x_mob + female_x_post + post_x_mob + female_x_mob +
                age + I(age^2) + i(race_cat) + married + is_farm |
                statefip + year,
                data = indiv_panel[!is.na(occ_score)], cluster = ~statefip,
                weights = ~perwt)

t2_emp <- feols(employed ~ female_x_post_x_mob + female_x_post + post_x_mob + female_x_mob +
                age + I(age^2) + i(race_cat) + married + is_farm |
                statefip + year,
                data = indiv_panel, cluster = ~statefip,
                weights = ~perwt)

t2_head <- feols(is_head ~ female_x_post_x_mob + female_x_post + post_x_mob + female_x_mob +
                 age + I(age^2) + i(race_cat) + married + is_farm |
                 statefip + year,
                 data = indiv_panel, cluster = ~statefip,
                 weights = ~perwt)

cat("--- Triple-Diff: LFP ---\n")
etable(t1_lf, t2_lf,
       headers = c("Baseline", "Full controls"),
       keep = c("female_x_post_x_mob", "female_x_post", "post_x_mob"))

cat("\n--- Triple-Diff: Multiple Outcomes ---\n")
etable(t2_lf, t2_occ, t2_emp, t2_head,
       headers = c("LFP", "Occ Score", "Employed", "HH Head"),
       drop = c("age", "I\\(", "race", "married", "is_farm"))


## --------------------------------------------------------------------------
## 5. WOMEN ONLY: Post × Mobilization Interaction
## --------------------------------------------------------------------------

cat("\n=== Women Only: Post × Mobilization ===\n")

women <- indiv_panel[female == 1]

w1_lf <- feols(in_lf ~ post * mob_std + age + I(age^2) | statefip,
               data = women, cluster = ~statefip, weights = ~perwt)

w2_lf <- feols(in_lf ~ post * mob_std + age + I(age^2) + i(race_cat) +
               married + is_farm | statefip,
               data = women, cluster = ~statefip, weights = ~perwt)

w2_occ <- feols(occ_score ~ post * mob_std + age + I(age^2) + i(race_cat) +
                married + is_farm | statefip,
                data = women[!is.na(occ_score)], cluster = ~statefip,
                weights = ~perwt)

w2_emp <- feols(employed ~ post * mob_std + age + I(age^2) + i(race_cat) +
                married + is_farm | statefip,
                data = women, cluster = ~statefip, weights = ~perwt)

cat("--- Women: Post × Mobilization ---\n")
etable(w1_lf, w2_lf, w2_occ, w2_emp,
       headers = c("LFP (base)", "LFP", "Occ Score", "Employed"),
       keep = c("post.*mob", "mob_std"))


## --------------------------------------------------------------------------
## 6. PRE-TREND VALIDATION (1930-1940)
## --------------------------------------------------------------------------

cat("\n=== Pre-Trend Tests ===\n")

# State-level
if (file.exists(file.path(data_dir, "state_pretrends.rds"))) {
  state_pre <- readRDS(file.path(data_dir, "state_pretrends.rds"))

  pre_lf <- feols(d_lf_female_pre ~ mob_std + pct_urban + pct_black + pct_farm +
                  mean_educ + mean_age, data = state_pre)
  pre_gap <- feols(d_lf_gap_pre ~ mob_std + pct_urban + pct_black + pct_farm +
                   mean_educ + mean_age, data = state_pre)

  cat("State-level pre-trends (1930→1940): Should be ~zero\n")
  etable(pre_lf, pre_gap,
         headers = c("Δ Female LFP (pre)", "Δ LFP Gap (pre)"),
         keep = "mob_std")
}

# Individual-level pre-trend
indiv_pre <- indiv_panel  # Reuse the panel construction approach
indiv_1930_40 <- mlp_wa <- NULL  # Will need separate loading
# Load 1930-1940 stacked panel
tryCatch({
  source("code/00_packages.R")
  mlp <- readRDS(file.path(data_dir, "ipums_mlp_clean.rds"))
  setnames(mlp, tolower(names(mlp)))
  for (col in names(mlp)) {
    if (inherits(mlp[[col]], "haven_labelled")) {
      mlp[, (col) := as.numeric(get(col))]
    }
  }

  mlp[, female := as.integer(sex == 2)]
  mlp[, in_lf := as.integer(labforce == 2)]
  mlp[, married := as.integer(marst %in% c(1, 2))]
  mlp[, is_farm := as.integer(farm == 2)]
  mlp[, is_urban := as.integer(urban == 2)]
  mlp[, race_cat := fcase(race == 1, "White", race == 2, "Black", default = "Other")]

  state_mob_data <- readRDS(file.path(data_dir, "state_mobilization.rds"))
  mlp <- merge(mlp, state_mob_data[, .(statefip, mob_std)],
               by = "statefip", all.x = TRUE)

  pre_panel <- mlp[year %in% c(1930, 1940) & age >= 18 & age <= 55 & !is.na(mob_std)]
  pre_panel[, pre_post := as.integer(year == 1940)]
  pre_panel[, female_x_pre_x_mob := female * pre_post * mob_std]
  pre_panel[, female_x_pre := female * pre_post]
  pre_panel[, pre_x_mob := pre_post * mob_std]
  pre_panel[, female_x_mob := female * mob_std]

  pre_indiv <- feols(in_lf ~ female_x_pre_x_mob + female_x_pre + pre_x_mob +
                     female_x_mob + age + I(age^2) | statefip + year,
                     data = pre_panel, cluster = ~statefip,
                     weights = ~perwt)

  cat("\nIndividual-level pre-trend (1930→1940 triple-diff):\n")
  etable(pre_indiv, keep = c("female_x_pre_x_mob", "female_x_pre", "pre_x_mob"))
}, error = function(e) {
  cat("Individual pre-trend failed:", conditionMessage(e), "\n")
})


## --------------------------------------------------------------------------
## 7. PLACEBO: Women 50+ (Unaffected by Mobilization)
## --------------------------------------------------------------------------

cat("\n=== Placebo: Older Women ===\n")

older <- indiv_panel[female == 1 & age >= 50]
if (nrow(older) > 500) {
  plac_lf <- feols(in_lf ~ post * mob_std + age + I(age^2) + i(race_cat) |
                   statefip,
                   data = older, cluster = ~statefip, weights = ~perwt)
  cat("Women 50+: post × mobilization should be ~zero\n")
  etable(plac_lf, keep = c("post.*mob"))
}


## --------------------------------------------------------------------------
## 8. HETEROGENEITY
## --------------------------------------------------------------------------

cat("\n=== Heterogeneity Analysis ===\n")

women <- indiv_panel[female == 1]

# By race
het_race <- list()
for (r in c("White", "Black")) {
  sub <- women[race_cat == r]
  if (nrow(sub) > 1000) {
    het_race[[r]] <- feols(in_lf ~ post * mob_std + age + I(age^2) +
                           married + is_farm | statefip,
                           data = sub, cluster = ~statefip, weights = ~perwt)
  }
}
if (length(het_race) >= 2) {
  cat("--- By Race ---\n")
  etable(het_race$White, het_race$Black,
         headers = c("White", "Black"), keep = c("post.*mob"))
}

# By urban/rural (only 1940 cross-section, since is_urban unavailable in 1950)
# Note: mob_std is state-level, absorbed by state FE in cross-section
# Use OLS without state FE to show urban/rural differential
women_1940 <- indiv_panel[female == 1 & year == 1940]
het_urban <- list()
for (u in c(0, 1)) {
  lab <- ifelse(u == 1, "Urban", "Rural")
  sub <- women_1940[is_urban == u & !is.na(is_urban)]
  if (nrow(sub) > 500) {
    het_urban[[lab]] <- feols(in_lf ~ mob_std + age + I(age^2) +
                              i(race_cat) + married,
                              data = sub, cluster = ~statefip, weights = ~perwt)
  }
}
if (length(het_urban) >= 2) {
  cat("\n--- By Urban/Rural (1940 Cross-Section, no state FE) ---\n")
  etable(het_urban$Rural, het_urban$Urban,
         headers = c("Rural", "Urban"),
         drop = c("age", "I\\(", "race", "married", "Constant"))
}

# By age group
het_age <- list()
for (ag in c("18-25", "26-35", "36-45", "46-55")) {
  sub <- women[age_group == ag]
  if (nrow(sub) > 1000) {
    het_age[[ag]] <- feols(in_lf ~ post * mob_std + I(age^2) +
                           i(race_cat) + married + is_farm | statefip,
                           data = sub, cluster = ~statefip, weights = ~perwt)
  }
}
if (length(het_age) >= 2) {
  cat("\n--- By Age Group ---\n")
  etable(het_age, headers = names(het_age), keep = c("post.*mob"))
}

# By marital status
het_marst <- list()
for (ms in c(0, 1)) {
  lab <- ifelse(ms == 1, "Married", "Unmarried")
  sub <- women[married == ms]
  if (nrow(sub) > 1000) {
    het_marst[[lab]] <- feols(in_lf ~ post * mob_std + age + I(age^2) +
                              i(race_cat) + is_farm | statefip,
                              data = sub, cluster = ~statefip, weights = ~perwt)
  }
}
if (length(het_marst) >= 2) {
  cat("\n--- By Marital Status ---\n")
  etable(het_marst$Unmarried, het_marst$Married,
         headers = c("Unmarried", "Married"), keep = c("post.*mob"))
}


## --------------------------------------------------------------------------
## 9. Save All Results
## --------------------------------------------------------------------------

cat("\n=== Saving ===\n")

models <- list(
  # State-level
  s1_lf = s1_lf, s2_lf = s2_lf, s1_occ = s1_occ, s2_occ = s2_occ,
  s1_gap = s1_gap, s2_gap = s2_gap, s2_male = s2_male,
  s_head = s_head, s_married = s_married, s_employed = s_employed,
  # Triple-diff
  t1_lf = t1_lf, t2_lf = t2_lf, t2_occ = t2_occ, t2_emp = t2_emp, t2_head = t2_head,
  # Women only
  w1_lf = w1_lf, w2_lf = w2_lf, w2_occ = w2_occ, w2_emp = w2_emp,
  # Heterogeneity
  het_race = het_race, het_urban = het_urban, het_age = het_age, het_marst = het_marst
)

if (exists("pre_lf")) models$pre_lf <- pre_lf
if (exists("pre_gap")) models$pre_gap <- pre_gap
if (exists("pre_indiv")) models$pre_indiv <- pre_indiv
if (exists("plac_lf")) models$plac_lf <- plac_lf

saveRDS(models, file.path(data_dir, "main_models.rds"))

cat("\n✓ Main analysis complete. Proceed to 04_robustness.R\n")
