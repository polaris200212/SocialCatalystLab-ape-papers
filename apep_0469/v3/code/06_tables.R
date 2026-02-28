## ============================================================================
## 06_tables.R — All Tables for apep_0469 v3
## Missing Men, Rising Women (MLP Three-Wave Panel)
## ============================================================================
## New tables: Pre-trend results, mobilization validation, selection diagnostics,
## married-women decomposition, state-level controls sensitivity.
## ============================================================================

source("code/00_packages.R")

data_dir <- "data"
tab_dir <- "tables"
dir.create(tab_dir, showWarnings = FALSE)

## --- PHASED LOADING: raw panels first for summary stats, then free ---
## Phase 1: Load raw panels for Table 1 + Table 12 summary statistics
cat("=== Phase 1: Computing summary statistics from raw panels ===\n")

panel <- readRDS(file.path(data_dir, "linked_panel_40_50.rds"))
setDT(panel); alloc.col(panel, ncol(panel) + 20L)
men <- panel[panel$female_1940 == 0, ]
# Pre-compute all needed stats from panel
men_sumstats <- list(
  n = nrow(men),
  lfp_40 = mean(men$in_lf_1940, na.rm = TRUE),
  lfp_50 = mean(men$in_lf_1950, na.rm = TRUE),
  d_lfp = mean(men$d_in_lf, na.rm = TRUE),
  age_40 = mean(men$age_1940),
  married_40 = mean(men$married_1940, na.rm = TRUE),
  pct_mover = 100 * mean(men$mover),
  pct_lf_40 = 100 * mean(men$in_lf_1940, na.rm = TRUE),
  pct_farm_40 = 100 * mean(men$is_farm_1940, na.rm = TRUE),
  linked_mean_age = mean(men$age_1940, na.rm = TRUE),
  linked_pct_married = 100 * mean(men$married_1940, na.rm = TRUE)
)
rm(men, panel); gc()
cat("  Freed individual panel\n")

couples <- readRDS(file.path(data_dir, "couples_panel_40_50.rds"))
setDT(couples); alloc.col(couples, ncol(couples) + 10L)
couples_sumstats <- list(
  n = nrow(couples),
  wife_lfp_40 = mean(couples$sp_in_lf_1940, na.rm = TRUE),
  wife_lfp_50 = mean(couples$sp_in_lf_1950, na.rm = TRUE),
  wife_d_lfp = mean(couples$wife_d_in_lf, na.rm = TRUE),
  wife_age_40 = mean(couples$sp_age_1940, na.rm = TRUE),
  hus_lfp_40 = mean(couples$husband_in_lf_1940, na.rm = TRUE),
  hus_lfp_50 = mean(couples$husband_in_lf_1950, na.rm = TRUE),
  hus_d_lfp = mean(couples$husband_d_in_lf, na.rm = TRUE),
  hus_age_40 = mean(couples$husband_age_1940, na.rm = TRUE)
)
rm(couples); gc()
cat("  Freed couples panel\n")

panel3 <- readRDS(file.path(data_dir, "linked_panel_30_40_50.rds"))
setDT(panel3); alloc.col(panel3, ncol(panel3) + 20L)
men3 <- panel3[panel3$female_1940 == 0, ]
panel3_sumstats <- list(
  n = nrow(men3),
  lfp_40 = mean(men3$in_lf_1940, na.rm = TRUE),
  lfp_50 = mean(men3$in_lf_1950, na.rm = TRUE),
  d_lfp = mean(men3$d_in_lf_40_50, na.rm = TRUE),
  age_40 = mean(men3$age_1940),
  married_40 = mean(men3$married_1940, na.rm = TRUE),
  pct_mover = 100 * mean(men3$mover_40_50, na.rm = TRUE)
)
rm(men3, panel3); gc()
cat("  Freed 3-period panel\n")

## Phase 2: Load model objects for regression tables (much smaller memory footprint)
cat("=== Phase 2: Loading model objects for regression tables ===\n")
models <- readRDS(file.path(data_dir, "main_models.rds"))
robustness <- readRDS(file.path(data_dir, "robustness.rds"))
decomp <- readRDS(file.path(data_dir, "decomposition.rds"))
sumstats <- readRDS(file.path(data_dir, "summary_stats.rds"))
state_analysis <- readRDS(file.path(data_dir, "state_analysis.rds"))
setDT(state_analysis); alloc.col(state_analysis, ncol(state_analysis) + 10L)
state_mob <- readRDS(file.path(data_dir, "state_mobilization.rds"))
setDT(state_mob); alloc.col(state_mob, ncol(state_mob) + 10L)
selection_diag <- readRDS(file.path(data_dir, "selection_diagnostics.rds"))

setFixest_dict(c(
  mob_std = "Mobilization Rate (std.)",
  d_in_lf = "$\\Delta$ Labor Force",
  d_in_lf_30_40 = "$\\Delta$ LF (1930-1940)",
  d_in_lf_40_50 = "$\\Delta$ LF (1940-1950)",
  d_occ_score = "$\\Delta$ Occ. Score",
  d_employed = "$\\Delta$ Employed",
  wife_d_in_lf = "$\\Delta$ Wife LF",
  wife_d_in_lf_30_40 = "$\\Delta$ Wife LF (1930-1940)",
  wife_d_in_lf_40_50 = "$\\Delta$ Wife LF (1940-1950)",
  wife_d_occ_score = "$\\Delta$ Wife Occ. Score",
  sp_in_lf_1950 = "Wife In LF (1950)",
  sp_in_lf_1940 = "Wife In LF (1940)",
  in_lf_1950 = "In LF (1950)",
  in_lf_1940 = "In LF (1940)",
  age_1940 = "Age (1940)",
  sp_age_1940 = "Wife Age (1940)",
  husband_age_1940 = "Husband Age (1940)",
  educ_years_1940 = "Education Years (1940)",
  sp_educ_years_1940 = "Wife Educ. Years (1940)",
  married_1940 = "Married (1940)",
  is_farm_1940 = "Farm (1940)",
  husband_occ_score_1940 = "Husband Occ. Score (1940)",
  husband_in_lf_1940 = "Husband In LF (1940)",
  husband_d_in_lf = "$\\Delta$ Husband LF",
  d_mw_lfp = "$\\Delta$ Married-Women LFP",
  d_aw_lfp = "$\\Delta$ All-Women LFP",
  pct_farm = "\\% Farm (1940)",
  pct_black = "\\% Black (1940)",
  mean_educ = "Mean Education (1940)",
  pct_married = "\\% Married (1940)",
  pct_farm_state = "\\% Farm (state)",
  pct_married_state = "\\% Married (state)",
  mean_educ_state = "Mean Educ. (state)"
))


## --------------------------------------------------------------------------
## Table 1: Summary Statistics — MLP Panel + Couples + 3-Wave
## --------------------------------------------------------------------------

cat("--- Table 1: Summary Statistics ---\n")

# Use pre-computed summary statistics (from Phase 1)
men_stats <- data.table(
  Group = "Linked Men (Individual Panel)",
  N = format(men_sumstats$n, big.mark = ","),
  `LFP 1940` = sprintf("%.3f", men_sumstats$lfp_40),
  `LFP 1950` = sprintf("%.3f", men_sumstats$lfp_50),
  `DLFP` = sprintf("%.4f", men_sumstats$d_lfp),
  `Age 1940` = sprintf("%.1f", men_sumstats$age_40),
  `Married 1940` = sprintf("%.3f", men_sumstats$married_40),
  `Pct Mover` = sprintf("%.1f", men_sumstats$pct_mover)
)

wife_stats <- data.table(
  Group = "Wives (Couples Panel)",
  N = format(couples_sumstats$n, big.mark = ","),
  `LFP 1940` = sprintf("%.3f", couples_sumstats$wife_lfp_40),
  `LFP 1950` = sprintf("%.3f", couples_sumstats$wife_lfp_50),
  `DLFP` = sprintf("%.4f", couples_sumstats$wife_d_lfp),
  `Age 1940` = sprintf("%.1f", couples_sumstats$wife_age_40),
  `Married 1940` = "1.000",
  `Pct Mover` = "---"
)

husband_stats <- data.table(
  Group = "Husbands (Couples Panel)",
  N = format(couples_sumstats$n, big.mark = ","),
  `LFP 1940` = sprintf("%.3f", couples_sumstats$hus_lfp_40),
  `LFP 1950` = sprintf("%.3f", couples_sumstats$hus_lfp_50),
  `DLFP` = sprintf("%.4f", couples_sumstats$hus_d_lfp),
  `Age 1940` = sprintf("%.1f", couples_sumstats$hus_age_40),
  `Married 1940` = "1.000",
  `Pct Mover` = "---"
)

panel3_stats <- data.table(
  Group = "3-Wave Panel Men (1930-1940-1950)",
  N = format(panel3_sumstats$n, big.mark = ","),
  `LFP 1940` = sprintf("%.3f", panel3_sumstats$lfp_40),
  `LFP 1950` = sprintf("%.3f", panel3_sumstats$lfp_50),
  `DLFP` = sprintf("%.4f", panel3_sumstats$d_lfp),
  `Age 1940` = sprintf("%.1f", panel3_sumstats$age_40),
  `Married 1940` = sprintf("%.3f", panel3_sumstats$married_40),
  `Pct Mover` = sprintf("%.1f", panel3_sumstats$pct_mover)
)

tab1 <- rbind(men_stats, wife_stats, husband_stats, panel3_stats)

write.csv(tab1, file.path(tab_dir, "table1_summary_stats.csv"), row.names = FALSE)

tab1_tex <- kableExtra::kbl(tab1, format = "latex", booktabs = TRUE,
  caption = "Summary Statistics: MLP-Linked Panel (1940-1950) and Three-Wave Panel (1930-1940-1950)",
  label = "sumstats",
  col.names = c("Sample", "N", "LFP 1940", "LFP 1950", "$\\Delta$LFP",
                "Age 1940", "Married 1940", "\\% Mover"),
  escape = FALSE) %>%
  kableExtra::kable_styling(latex_options = c("scale_down")) %>%
  kableExtra::footnote(general = "Men linked individually via MLP v2 crosswalk (Helgertz et al.\\ 2023). Wives tracked through husbands' households via SERIAL matching with age verification. Mover: changed state of residence between census years.",
                       threeparttable = TRUE)
writeLines(tab1_tex, file.path(tab_dir, "table1_summary_stats.tex"))
cat("Saved table1_summary_stats.tex\n")


## --------------------------------------------------------------------------
## Table 2: Pre-Trend Results (NEW)
## --------------------------------------------------------------------------

cat("--- Table 2: Pre-Trend Results ---\n")

etable(models$pt_m1, models$pt_m2, models$pt_w1, models$pt_w2,
       file = file.path(tab_dir, "table2_pretrend.tex"),
       title = "Pre-Trend Test: Change in Labor Force Participation (1930-1940) on Mobilization",
       label = "tab:pretrend",
       headers = c("Men (1)", "Men (2)", "Wives (1)", "Wives (2)"),
       extralines = list(
         "Controls" = c("No", "Yes", "No", "Yes"),
         "Region FE" = c("No", "Yes", "No", "Yes")
       ),
       keep = "%mob_std",
       se.below = TRUE, depvar = FALSE,
       style.tex = style.tex("aer"),
       fitstat = ~ n + r2,
       notes = "LFP in 1930 based on gainful employment (CLASSWKR > 0). LFP in 1940 based on EMPSTAT. Samples restricted to individuals appearing in all three census years (1930-1940-1950). State-clustered standard errors in parentheses. * p < 0.10, ** p < 0.05, *** p < 0.01.")

cat("Saved table2_pretrend.tex\n")


## --------------------------------------------------------------------------
## Table 3: Men's First-Difference (M1-M5)
## --------------------------------------------------------------------------

cat("--- Table 3: Men's Results ---\n")

men_models <- list(models$m1_lf, models$m2_lf, models$m3_lf, models$m4_lf)
men_headers <- c("(1)", "(2)", "(3)", "(4)")
men_extras <- list(
  "Controls" = c("No", "Yes", "Yes", "Yes"),
  "Region FE" = c("No", "No", "Yes", "Yes"),
  "Sample" = c("All", "All", "All", "Non-Movers"),
  "State Controls" = c("No", "No", "No", "No")
)

if (!is.null(models$m5_lf)) {
  men_models[[5]] <- models$m5_lf
  men_headers <- c(men_headers, "(5)")
  men_extras[["Controls"]] <- c(men_extras[["Controls"]], "Yes")
  men_extras[["Region FE"]] <- c(men_extras[["Region FE"]], "Yes")
  men_extras[["Sample"]] <- c(men_extras[["Sample"]], "All")
  men_extras[["State Controls"]] <- c(men_extras[["State Controls"]], "Yes")
}

etable(men_models,
       file = file.path(tab_dir, "table3_men_results.tex"),
       title = "Men's Within-Person Change in Labor Force Participation (1940-1950)",
       label = "tab:men_main",
       headers = men_headers,
       extralines = men_extras,
       keep = "%mob_std",
       se.below = TRUE, depvar = FALSE,
       style.tex = style.tex("aer"),
       fitstat = ~ n + r2)

cat("Saved table3_men_results.tex\n")


## --------------------------------------------------------------------------
## Table 4: Wives' First-Difference (W1-W5)
## --------------------------------------------------------------------------

cat("--- Table 4: Wives' Results ---\n")

wife_models <- list(models$w1_lf, models$w2_lf, models$w3_lf, models$w4_lf)
wife_headers <- c("(1)", "(2)", "(3)", "(4)")
wife_extras <- list(
  "Wife Controls" = c("No", "Yes", "Yes", "Yes"),
  "Region FE" = c("No", "No", "Yes", "Yes"),
  "Husband Controls" = c("No", "No", "Yes", "Yes"),
  "State Controls" = c("No", "No", "No", "No")
)

if (!is.null(models$w5_lf)) {
  wife_models[[5]] <- models$w5_lf
  wife_headers <- c(wife_headers, "(5)")
  wife_extras[["Wife Controls"]] <- c(wife_extras[["Wife Controls"]], "Yes")
  wife_extras[["Region FE"]] <- c(wife_extras[["Region FE"]], "Yes")
  wife_extras[["Husband Controls"]] <- c(wife_extras[["Husband Controls"]], "Yes")
  wife_extras[["State Controls"]] <- c(wife_extras[["State Controls"]], "Yes")
}

etable(wife_models,
       file = file.path(tab_dir, "table4_wives_results.tex"),
       title = "Wives' Within-Couple Change in Labor Force Participation (1940-1950)",
       label = "tab:wives_main",
       headers = wife_headers,
       extralines = wife_extras,
       keep = "%mob_std",
       se.below = TRUE, depvar = FALSE,
       style.tex = style.tex("aer"),
       fitstat = ~ n + r2)

cat("Saved table4_wives_results.tex\n")


## --------------------------------------------------------------------------
## Table 5: Occupation Results
## --------------------------------------------------------------------------

cat("--- Table 5: Occupation ---\n")

occ_models <- list(models$m6_occ)
occ_headers <- c("Men $\\Delta$Occ")
if (!is.null(models$w6_occ)) {
  occ_models[[length(occ_models) + 1]] <- models$w6_occ
  occ_headers <- c(occ_headers, "Wives $\\Delta$Occ")
}

etable(occ_models,
       file = file.path(tab_dir, "table5_occupation.tex"),
       title = "Within-Person Change in Occupational Standing (1940-1950)",
       label = "tab:occupation",
       headers = occ_headers,
       keep = "%mob_std",
       se.below = TRUE, depvar = FALSE,
       style.tex = style.tex("aer"),
       fitstat = ~ n + r2)

cat("Saved table5_occupation.tex\n")


## --------------------------------------------------------------------------
## Table 6: Husband-Wife Dynamics
## --------------------------------------------------------------------------

cat("--- Table 6: Husband-Wife Dynamics ---\n")

if (!is.null(models$hw_lf)) {
  etable(models$hw_lf,
         file = file.path(tab_dir, "table6_hw_dynamics.tex"),
         title = "Husband-Wife Joint Labor Market Dynamics (Couples Panel)",
         label = "tab:hwdynamics",
         se.below = TRUE, depvar = FALSE,
         style.tex = style.tex("aer"),
         fitstat = ~ n + r2)
  cat("Saved table6_hw_dynamics.tex\n")
} else {
  cat("No HW dynamics models available\n")
}


## --------------------------------------------------------------------------
## Table 7: State-Level Cross-Validation (Married-Women Aggregate)
## --------------------------------------------------------------------------

cat("--- Table 7: State-Level ---\n")

state_models <- list(models$s1_lf, models$s2_lf)
state_headers <- c("(1) Unconditional", "(2) With Controls")
state_extras <- list("State Controls" = c("No", "Yes"))

if (!is.null(models$s3_lf)) {
  state_models[[3]] <- models$s3_lf
  state_headers <- c(state_headers, "(3) All Women")
  state_extras[["State Controls"]] <- c(state_extras[["State Controls"]], "Yes")
}

etable(state_models,
       file = file.path(tab_dir, "table7_state_level.tex"),
       title = "State-Level Cross-Validation: Mobilization and Female LFP (Full-Count Data)",
       label = "tab:statelevel",
       headers = state_headers,
       extralines = state_extras,
       keep = "%mob_std",
       se.below = TRUE, depvar = FALSE,
       style.tex = style.tex("aer"),
       fitstat = ~ n + r2,
       notes = sprintf("Cols 1-2: Married women aged 18-55 (MARST = 1,2). Col 3: All women aged 18-55. Population-weighted. HC2 SE = %.4f, HC3 SE = %.4f for Col 2.",
                        models$se_hc2, models$se_hc3))

cat("Saved table7_state_level.tex\n")


## --------------------------------------------------------------------------
## Table 8: Married-Women Decomposition (NEW)
## --------------------------------------------------------------------------

cat("--- Table 8: Married-Women Decomposition ---\n")

# Build decomposition table with married-women focus
dw_ratio <- ifelse(abs(decomp$married_women$d_agg) > 1e-10,
  100 * decomp$married_women$d_within / decomp$married_women$d_agg, NA)
comp_ratio <- ifelse(abs(decomp$married_women$d_agg) > 1e-10,
  100 * decomp$married_women$gap / decomp$married_women$d_agg, NA)

decomp_tab <- data.table(
  Component = c("Aggregate Change", "Within-Couple Change", "Compositional Residual"),
  `Married Women` = c(
    sprintf("%.4f", decomp$married_women$d_agg),
    sprintf("%.4f (%.0f%%)", decomp$married_women$d_within,
            ifelse(is.na(dw_ratio), 0, dw_ratio)),
    sprintf("%.4f (%.0f%%)", decomp$married_women$gap,
            ifelse(is.na(comp_ratio), 0, comp_ratio))
  ),
  `All Women` = c(
    sprintf("%.4f", decomp$all_women$d_agg),
    sprintf("%.4f", decomp$all_women$d_within),
    sprintf("%.4f", decomp$all_women$gap)
  ),
  `Men` = c(
    "---",
    sprintf("%.4f", decomp$men$d_within),
    "---"
  )
)

tab8_tex <- kableExtra::kbl(decomp_tab, format = "latex", booktabs = TRUE,
  caption = "Within-Couple vs.\\ Aggregate LFP Changes (1940--1950): Married Women",
  label = "decomposition",
  escape = FALSE) %>%
  kableExtra::kable_styling() %>%
  kableExtra::footnote(general = "Within-couple changes from MLP-linked couples panel. Aggregate changes from full-count cross-sections (married women: MARST $\\in \\{1,2\\}$, ages 18--55; all women: ages 18--55). Compositional residual = Aggregate $-$ Within-couple. The gap captures marriage transitions, mortality, migration, and differential Census enumeration.",
                       threeparttable = TRUE, escape = FALSE)
writeLines(tab8_tex, file.path(tab_dir, "table8_decomposition.tex"))
cat("Saved table8_decomposition.tex\n")


## --------------------------------------------------------------------------
## Table 9: Mobilization Validation (NEW)
## --------------------------------------------------------------------------

cat("--- Table 9: Mobilization Validation ---\n")

tryCatch({
  mob_val <- robustness$mob_validation
  r15 <- mob_val$model
  r15_sum <- summary(r15)

  val_tab <- data.table(
    Check = c(
      "CenSoc mob vs mover rate (β)",
      "CenSoc mob vs mover rate (SE)",
      "CenSoc mob vs mover rate (R²)",
      "N states"
    ),
    Value = c(
      sprintf("%.4f", coef(r15)["mob_std"]),
      sprintf("%.4f", sqrt(diag(vcov(r15)))["mob_std"]),
      sprintf("%.3f", r15_sum$r.squared),
      as.character(nrow(mob_val$data))
    )
  )

  tab9_tex <- kableExtra::kbl(val_tab, format = "latex", booktabs = TRUE,
    caption = "Mobilization Measure Validation",
    label = "mobvalidation") %>%
    kableExtra::kable_styling() %>%
    kableExtra::footnote(general = "CenSoc mobilization rate: WWII Army enlistees per 1940 male population (ages 18--44). Mover rate: fraction of MLP-linked men who changed state between 1940 and 1950.",
                         threeparttable = TRUE)
  writeLines(tab9_tex, file.path(tab_dir, "table9_mob_validation.tex"))
  cat("Saved table9_mob_validation.tex\n")
}, error = function(e) cat(sprintf("  Skipped: %s\n", e$message)))


## --------------------------------------------------------------------------
## Table 10: Selection Diagnostics (NEW — Linkage Balance)
## --------------------------------------------------------------------------

cat("--- Table 10: Selection Diagnostics ---\n")

tryCatch({
  # Linkage rate vs mobilization
  lr_mob <- robustness$linkage_vs_mob
  r16 <- lr_mob$model
  r16_p <- summary(r16)$coefficients["mob_std", 4]

  sel_tab <- data.table(
    Check = c(
      "Link rate ~ mob (β)", "Link rate ~ mob (p-value)",
      sprintf("N states (link rate test)")
    ),
    Value = c(
      sprintf("%.6f", coef(r16)["mob_std"]),
      sprintf("%.3f", r16_p),
      as.character(nrow(lr_mob$data))
    )
  )

  tab10_tex <- kableExtra::kbl(sel_tab, format = "latex", booktabs = TRUE,
    caption = "Selection Tests: MLP Linkage Rate and Mobilization",
    label = "selection") %>%
    kableExtra::kable_styling() %>%
    kableExtra::footnote(general = "If linkage rate correlates with mobilization, the linked panel may be unrepresentative along the dimension of interest. Null result supports validity of the linked-panel design. IPW weights further address any residual selection (see Table~\\ref{tab:robustness}).",
                         threeparttable = TRUE, escape = FALSE)
  writeLines(tab10_tex, file.path(tab_dir, "table10_selection.tex"))
  cat("Saved table10_selection.tex\n")
}, error = function(e) cat(sprintf("  Skipped: %s\n", e$message)))


## --------------------------------------------------------------------------
## Table 11: Robustness Summary (updated with IPW + new checks)
## --------------------------------------------------------------------------

cat("--- Table 11: Robustness Summary ---\n")

rob_rows <- list()

# Baseline
rob_rows[[length(rob_rows) + 1]] <- c("Baseline (wives, region FE)",
  sprintf("%.4f (SE %.4f)",
    coef(models$w3_lf)["mob_std"], sqrt(vcov(models$w3_lf)["mob_std", "mob_std"])))

# Pre-trend
rob_rows[[length(rob_rows) + 1]] <- c("Pre-trend: Wives ΔLF(1930-1940)",
  sprintf("%.4f (SE %.4f)",
    coef(models$pt_w2)["mob_std"], sqrt(vcov(models$pt_w2)["mob_std", "mob_std"])))

# IPW wives
if (!is.null(robustness$ipw_weighted$wives)) {
  ipw_w <- robustness$ipw_weighted$wives
  rob_rows[[length(rob_rows) + 1]] <- c("IPW-Weighted (wives)",
    sprintf("%.4f (SE %.4f)", coef(ipw_w)["mob_std"],
            sqrt(vcov(ipw_w)["mob_std", "mob_std"])))
}

# State controls
if (!is.null(models$w5_lf)) {
  rob_rows[[length(rob_rows) + 1]] <- c("State Baseline Controls (w5)",
    sprintf("%.4f (SE %.4f)", coef(models$w5_lf)["mob_std"],
            sqrt(vcov(models$w5_lf)["mob_std", "mob_std"])))
}

# Oster
if (!is.null(robustness$oster$delta) && is.finite(robustness$oster$delta)) {
  rob_rows[[length(rob_rows) + 1]] <- c("Oster δ (wives)",
    sprintf("%.2f", robustness$oster$delta))
}

# RI
rob_rows[[length(rob_rows) + 1]] <- c(
  sprintf("Randomization Inference (%d perms)", length(robustness$ri$perm_betas)),
  sprintf("p = %.4f", robustness$ri$p_value))

# HC3
rob_rows[[length(rob_rows) + 1]] <- c("HC3 SE (state-level)",
  sprintf("%.4f", robustness$hc$se_hc3))

# LOO
rob_rows[[length(rob_rows) + 1]] <- c(
  sprintf("Leave-One-Out Range (%d states)", length(robustness$loo$betas)),
  sprintf("[%.4f, %.4f]", min(robustness$loo$betas), max(robustness$loo$betas)))

# Placebo older
if (!is.null(robustness$placebo_older)) {
  rob_rows[[length(rob_rows) + 1]] <- c("Placebo: Older Wives (46+)",
    sprintf("%.4f (SE %.4f)", coef(robustness$placebo_older)["mob_std"],
            sqrt(vcov(robustness$placebo_older)["mob_std", "mob_std"])))
}

# ANCOVA
if (!is.null(robustness$ancova)) {
  rob_rows[[length(rob_rows) + 1]] <- c("ANCOVA (level with lagged DV)",
    sprintf("%.4f", coef(robustness$ancova)["mob_std"]))
}

# Trimmed
if (!is.null(robustness$trimmed)) {
  rob_rows[[length(rob_rows) + 1]] <- c("Trimmed Sample (5-95%)",
    sprintf("%.4f (SE %.4f)", coef(robustness$trimmed)["mob_std"],
            sqrt(vcov(robustness$trimmed)["mob_std", "mob_std"])))
}

# Wife verified
if (!is.null(robustness$wife_verified)) {
  wv <- robustness$wife_verified
  rob_rows[[length(rob_rows) + 1]] <- c(
    sprintf("Wife Age-Verified (%.1f%%)", wv$pct_verified),
    sprintf("%.4f (SE %.4f)", wv$beta, wv$se))
}

# Wild bootstrap
if (!is.null(robustness$wild_bootstrap)) {
  rob_rows[[length(rob_rows) + 1]] <- c("Wild Cluster Bootstrap",
    sprintf("p = %.4f, CI [%.4f, %.4f]", robustness$wild_bootstrap$p_value,
            robustness$wild_bootstrap$ci_lo, robustness$wild_bootstrap$ci_hi))
}

# Non-mover couples
if (!is.null(robustness$nonmover_couples)) {
  rob_rows[[length(rob_rows) + 1]] <- c(
    "Non-Mover Couples",
    sprintf("%.4f (SE %.4f)", robustness$nonmover_couples$beta,
            robustness$nonmover_couples$se))
}

# IPW men
if (!is.null(robustness$ipw_weighted$men)) {
  ipw_m <- robustness$ipw_weighted$men
  rob_rows[[length(rob_rows) + 1]] <- c("IPW-Weighted (men)",
    sprintf("%.4f (SE %.4f)", coef(ipw_m)["mob_std"],
            sqrt(vcov(ipw_m)["mob_std", "mob_std"])))
}

rob_tab <- data.table(
  Check = sapply(rob_rows, `[`, 1),
  Value = sapply(rob_rows, `[`, 2)
)

tab11_tex <- kableExtra::kbl(rob_tab, format = "latex", booktabs = TRUE,
  caption = "Robustness Checks Summary",
  label = "robustness") %>%
  kableExtra::kable_styling(latex_options = c("scale_down")) %>%
  kableExtra::footnote(general = "All specifications use state-clustered standard errors except state-level regressions (HC2/HC3). IPW weights rebalance the linked sample to match the full-count census cross-section. Pre-trend test uses 3-wave MLP panel (1930-1940-1950).",
                       threeparttable = TRUE)
writeLines(tab11_tex, file.path(tab_dir, "table11_robustness.tex"))
cat("Saved table11_robustness.tex\n")


## --------------------------------------------------------------------------
## Table 12: Linkage Balance (Selection)
## --------------------------------------------------------------------------

cat("--- Table 12: Linkage Balance ---\n")

tryCatch({
  linked_mean_age <- men_sumstats$linked_mean_age
  linked_pct_lf <- men_sumstats$pct_lf_40
  linked_pct_married <- men_sumstats$linked_pct_married
  linked_pct_farm <- men_sumstats$pct_farm_40

  full_mean_age <- weighted.mean(state_analysis$mean_age, state_analysis$total_pop, na.rm = TRUE)
  full_pct_married <- 100 * weighted.mean(state_analysis$pct_married, state_analysis$total_pop, na.rm = TRUE)
  full_pct_farm <- 100 * weighted.mean(state_analysis$pct_farm, state_analysis$total_pop, na.rm = TRUE)

  tab12_data <- data.table(
    Group = c("Full 1940 Male Pop. (18--55)", "MLP-Linked Panel (Men)"),
    `Mean Age` = c(sprintf("%.1f", full_mean_age), sprintf("%.1f", linked_mean_age)),
    `\\% in LF` = c("---", sprintf("%.1f", linked_pct_lf)),
    `\\% Married` = c(sprintf("%.1f", full_pct_married), sprintf("%.1f", linked_pct_married)),
    `\\% Farm` = c(sprintf("%.1f", full_pct_farm), sprintf("%.1f", linked_pct_farm))
  )

  tab12_tex <- kableExtra::kbl(tab12_data,
    format = "latex", booktabs = TRUE,
    caption = "Linkage Balance: MLP Panel vs.\\ Full 1940 Male Population (Ages 18--55)",
    label = "linkage",
    col.names = c("Sample", "Mean Age", "\\% in LF", "\\% Married", "\\% Farm"),
    escape = FALSE) %>%
    kableExtra::kable_styling() %>%
    kableExtra::footnote(
      general = "Linked panel: men matched via MLP v2 crosswalk (Helgertz et al.\\ 2023) across full-count censuses. Full-count aggregates are population-weighted means from the state-level analysis dataset.",
      threeparttable = TRUE, escape = FALSE)
  writeLines(tab12_tex, file.path(tab_dir, "table12_linkage_balance.tex"))
  cat("Saved table12_linkage_balance.tex\n")
}, error = function(e) cat(sprintf("  Skipped: %s\n", e$message)))


cat("\n=== All tables saved to tables/ ===\n")
