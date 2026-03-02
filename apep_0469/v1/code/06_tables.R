## ============================================================================
## 06_tables.R — All Tables for apep_0469
## Missing Men, Rising Women
## ============================================================================

source("code/00_packages.R")
data_dir <- "data"
tab_dir <- "tables"
dir.create(tab_dir, showWarnings = FALSE)

## Clean variable names for publication tables
setFixest_dict(c(
  mob_std = "Mobilization Rate (std.)",
  female_x_post_x_mob = "Female $\\times$ Post $\\times$ Mob.",
  female_x_post = "Female $\\times$ Post",
  post_x_mob = "Post $\\times$ Mob.",
  female_x_pre_x_mob = "Female $\\times$ Pre $\\times$ Mob.",
  female = "Female",
  post = "Post",
  d_lf_female = "$\\Delta$ Female LFP",
  d_occ_female = "$\\Delta$ Female Occ. Score",
  d_gap_lf = "$\\Delta$ LFP Gender Gap",
  d_lf_male = "$\\Delta$ Male LFP",
  d_head_female = "$\\Delta$ Female HH Head",
  in_lf = "In Labor Force",
  occ_score = "Occ. Score",
  employed = "Employed",
  is_head = "HH Head",
  mob_quintile = "Mob. Quintile"
))

## Load data and models
state_analysis <- readRDS(file.path(data_dir, "state_analysis.rds"))
state_mob <- readRDS(file.path(data_dir, "state_mobilization.rds"))
indiv_panel <- readRDS(file.path(data_dir, "indiv_panel.rds"))
decomp <- readRDS(file.path(data_dir, "decomposition.rds"))
decomp_mob <- readRDS(file.path(data_dir, "decomp_by_mob.rds"))
models <- readRDS(file.path(data_dir, "main_models.rds"))
robustness <- readRDS(file.path(data_dir, "robustness.rds"))
summ_stats <- readRDS(file.path(data_dir, "summary_stats.rds"))


## --------------------------------------------------------------------------
## Table 1: Summary Statistics
## --------------------------------------------------------------------------

cat("=== Table 1: Summary Statistics ===\n")

pa <- summ_stats$panel_a
women <- pa[Gender == "Women"]
men <- pa[Gender == "Men"]

tab1_tex <- paste0(
"\\begin{table}[htbp]
\\centering
\\caption{Summary Statistics: 1940 Baseline Characteristics}
\\label{tab:summary}
\\small
\\begin{tabular}{lcc}
\\hline\\hline
 & Women & Men \\\\
\\hline
N & ", women$N, " & ", men$N, " \\\\[3pt]
Age & ", women$Age, " & ", men$Age, " \\\\
In Labor Force & ", women$`In LF`, " & ", men$`In LF`, " \\\\
Occupation Score & ", women$`Occ Score`, " & ", men$`Occ Score`, " \\\\
Married & ", women$Married, " & ", men$Married, " \\\\
Household Head & ", women$`HH Head`, " & ", men$`HH Head`, " \\\\
White & ", women$White, " & ", men$White, " \\\\
Black & ", women$Black, " & ", men$Black, " \\\\[3pt]
States & \\multicolumn{2}{c}{", nrow(state_analysis), "} \\\\
\\hline\\hline
\\end{tabular}
\\begin{tablenotes}
\\small
\\item \\textit{Notes:} IPUMS USA 1\\% samples, individuals aged 18--55. Statistics are weighted by person sampling weights (\\texttt{PERWT}). Labor force participation defined as \\texttt{LABFORCE} $= 2$. Occupation score is the IPUMS \\texttt{OCCSCORE} variable (Duncan socioeconomic index).
\\end{tablenotes}
\\end{table}")

writeLines(tab1_tex, file.path(tab_dir, "tab1_summary.tex"))
cat("  Saved: tab1_summary.tex\n")


## --------------------------------------------------------------------------
## Table 2: State-Level Main Results
## --------------------------------------------------------------------------

cat("=== Table 2: State-Level Results ===\n")

etable(models$s1_lf, models$s2_lf, models$s2_occ, models$s2_gap,
       models$s2_male, models$s_head,
       headers = c("(1)", "(2)", "(3)", "(4)", "(5)", "(6)"),
       keep = "%mob_std",
       tex = TRUE,
       file = file.path(tab_dir, "tab2_main_results.tex"),
       title = "State-Level First-Difference Regressions: Mobilization and Labor Market Outcomes",
       label = "tab:main_state",
       notes = paste("Dependent variables are 1940--1950 changes. Column (1): bivariate regression of change in female LFP on standardized mobilization rate.",
                     "Column (2): adds controls for 1940 state characteristics (percent urban, Black, farm, mean education, mean age, percent married).",
                     "Column (3): change in female occupation score. Column (4): change in LFP gender gap (female minus male).",
                     "Column (5): change in male LFP. Column (6): change in female household headship rate.",
                     "All regressions weighted by 1940 female population (male population for Column 5).",
                     "N = 48 states plus DC (excluding Alaska and Hawaii)."))

cat("  Saved: tab2_main_results.tex\n")


## --------------------------------------------------------------------------
## Table 3: Decomposition
## --------------------------------------------------------------------------

cat("=== Table 3: Decomposition ===\n")

tab3_tex <- sprintf(
"\\begin{table}[htbp]
\\centering
\\caption{National Gender Gap Changes, 1940--1950}
\\label{tab:decomp}
\\small
\\begin{tabular}{lcc}
\\hline\\hline
 & Labor Force Participation & Occupation Score \\\\
\\hline
\\textit{Panel A: Levels} \\\\[3pt]
Female, 1940 & %.3f & %.1f \\\\
Male, 1940 & %.3f & %.1f \\\\
Female, 1950 & %.3f & %.1f \\\\
Male, 1950 & %.3f & %.1f \\\\[3pt]
\\textit{Panel B: Changes} \\\\[3pt]
$\\Delta$ Female & %.3f & %.1f \\\\
$\\Delta$ Male & %.3f & %.1f \\\\
Gender gap, 1940 & %.3f & %.1f \\\\
Gender gap, 1950 & %.3f & %.1f \\\\
Gap change & %.3f & %.1f \\\\
\\hline\\hline
\\end{tabular}
\\begin{tablenotes}
\\small
\\item \\textit{Notes:} IPUMS USA 1\\%% samples, individuals aged 18--55, weighted by person sampling weights. Gender gap defined as female minus male. LFP is the share in the labor force. Occupation score is the IPUMS \\texttt{OCCSCORE} variable (Duncan socioeconomic index).
\\end{tablenotes}
\\end{table}",
  decomp$female_1940[1], decomp$female_1940[2],
  decomp$male_1940[1], decomp$male_1940[2],
  decomp$female_1950[1], decomp$female_1950[2],
  decomp$male_1950[1], decomp$male_1950[2],
  decomp$d_female[1], decomp$d_female[2],
  decomp$d_male[1], decomp$d_male[2],
  decomp$gap_1940[1], decomp$gap_1940[2],
  decomp$gap_1950[1], decomp$gap_1950[2],
  decomp$gap_change[1], decomp$gap_change[2]
)

writeLines(tab3_tex, file.path(tab_dir, "tab3_decomposition.tex"))
cat("  Saved: tab3_decomposition.tex\n")


## --------------------------------------------------------------------------
## Table 4: Individual Triple-Difference
## --------------------------------------------------------------------------

cat("=== Table 4: Triple-Difference ===\n")

etable(models$t1_lf, models$t2_lf, models$t2_occ, models$t2_emp, models$t2_head,
       headers = c("(1)", "(2)", "(3)", "(4)", "(5)"),
       drop = c("%age", "%I\\(", "%race", "%married", "%is_farm"),
       tex = TRUE,
       file = file.path(tab_dir, "tab4_triple_diff.tex"),
       title = "Individual-Level Triple-Difference: Female $\\times$ Post $\\times$ Mobilization",
       label = "tab:triple",
       notes = paste("All specifications include state and year fixed effects.",
                     "Column (1): baseline with age controls only.",
                     "Column (2): adds race, marital status, and farm indicators.",
                     "Columns (3)--(5): full controls with alternative outcomes.",
                     "Column (3) has fewer observations ($N = 1{,}027{,}280$) because IPUMS \\texttt{OCCSCORE} is only available for individuals reporting an occupation; non-labor-force participants are excluded.",
                     "Standard errors clustered at state level in parentheses.",
                     "Sample: individuals aged 18--55 in IPUMS USA 1\\% samples (1940 and 1950 pooled)."))

cat("  Saved: tab4_triple_diff.tex\n")


## --------------------------------------------------------------------------
## Table 5: Robustness Battery (State-Level)
## --------------------------------------------------------------------------

cat("=== Table 5: State-Level Robustness ===\n")

etable(models$s2_lf, robustness$unweighted, robustness$nonsouth,
       robustness$trimmed,
       headers = c("Baseline", "Unweighted", "Non-South", "Trimmed"),
       keep = "%mob_std",
       tex = TRUE,
       file = file.path(tab_dir, "tab5_robustness.tex"),
       title = "Robustness: State-Level Mobilization Effect on Female LFP Change",
       label = "tab:robust_state",
       notes = paste("Dependent variable: change in female LFP 1940--1950.",
                     "Column (1): baseline with 1940 controls, population-weighted.",
                     "Column (2): unweighted. Column (3): excludes 16 former Confederate states plus border states.",
                     "Column (4): trims top and bottom 10\\% of mobilization distribution.",
                     "All specifications include 1940 controls (percent urban, Black, farm, mean education, mean age)."))

cat("  Saved: tab5_robustness.tex\n")


## --------------------------------------------------------------------------
## Table 5b: Quintile Effects
## --------------------------------------------------------------------------

cat("=== Table 5b: Quintile Effects ===\n")

etable(robustness$quintile_lf, robustness$quintile_gap,
       headers = c("Female LFP Change", "LFP Gap Change"),
       keep = "%mob_quintile",
       tex = TRUE,
       file = file.path(tab_dir, "tab5b_quintile.tex"),
       title = "Non-Parametric Quintile Effects of Mobilization",
       label = "tab:quintile",
       notes = paste("Dependent variables: 1940--1950 change in female LFP (Column 1) and LFP gender gap (Column 2).",
                     "Mobilization quintile dummies with Q1 (lowest) as the omitted category.",
                     "Controls: 1940 state characteristics (percent urban, Black, farm, mean education, mean age).",
                     "Population-weighted. N = 48 states plus DC."))

cat("  Saved: tab5b_quintile.tex\n")


## --------------------------------------------------------------------------
## Table 6: Pre-Trends and Placebo
## --------------------------------------------------------------------------

cat("=== Table 6: Pre-Trends ===\n")

pre_models <- list()
if (!is.null(models$pre_lf)) pre_models[["Pre: Female LFP"]] <- models$pre_lf
if (!is.null(models$pre_gap)) pre_models[["Pre: LFP Gap"]] <- models$pre_gap
if (!is.null(models$pre_indiv)) pre_models[["Pre: Triple-Diff"]] <- models$pre_indiv
if (!is.null(models$plac_lf)) pre_models[["Placebo: 50+"]] <- models$plac_lf
pre_models[["Main: Female LFP"]] <- models$s2_lf

if (length(pre_models) > 1) {
  etable(pre_models,
         keep = c("%mob_std", "%post.*mob", "%female_x_pre_x_mob"),
         tex = TRUE,
         file = file.path(tab_dir, "tab6_pretrends.tex"),
         title = "Pre-Trend Validation and Placebo Tests",
         label = "tab:pretrends",
         notes = paste("Columns 1--2: state-level pre-trend tests using 1930--1940 changes.",
                       "Null results indicate parallel pre-trends.",
                       "Column 3: individual-level triple-difference pre-trend (female $\\times$ pre $\\times$ mobilization) using 1930--1940 data; a significant coefficient raises concerns about pre-existing compositional differences.",
                       "Column 4: placebo test on women aged 50+ (unlikely to enter labor force due to mobilization).",
                       "Last column: main result for comparison. Standard errors in parentheses."))
  cat("  Saved: tab6_pretrends.tex\n")
} else {
  cat("  Skipped: insufficient pre-trend models\n")
}


## --------------------------------------------------------------------------
## Table 7: Heterogeneity
## --------------------------------------------------------------------------

cat("=== Table 7: Heterogeneity ===\n")

het_models <- list()
if (!is.null(models$het_race$White)) het_models[["White Women"]] <- models$het_race$White
if (!is.null(models$het_race$Black)) het_models[["Black Women"]] <- models$het_race$Black
if (!is.null(models$het_marst$Unmarried)) het_models[["Unmarried"]] <- models$het_marst$Unmarried
if (!is.null(models$het_marst$Married)) het_models[["Married"]] <- models$het_marst$Married

if (length(het_models) >= 2) {
  etable(het_models,
         keep = c("%post.*mob"),
         tex = TRUE,
         file = file.path(tab_dir, "tab7_heterogeneity.tex"),
         title = "Heterogeneous Effects of Mobilization on Female LFP",
         label = "tab:het",
         notes = paste("Each column reports a separate regression of LFP on post $\\times$ mobilization for the indicated subsample.",
                       "All specifications include age, age$^2$, and state fixed effects.",
                       "Standard errors clustered at state level in parentheses.",
                       "Sample: women aged 18--55 in IPUMS USA 1\\% samples (1940 and 1950 pooled)."))
  cat("  Saved: tab7_heterogeneity.tex\n")
}


## --------------------------------------------------------------------------
## Table 8: Covariate Balance
## --------------------------------------------------------------------------

cat("=== Table 8: Balance ===\n")

bal <- robustness$balance
if (!is.null(bal) && nrow(bal) > 0) {
  bal_tex <- "\\begin{table}[htbp]\n\\centering\n"
  bal_tex <- paste0(bal_tex, "\\caption{Covariate Balance: 1940 State Characteristics on Mobilization}\n")
  bal_tex <- paste0(bal_tex, "\\label{tab:balance}\n")
  bal_tex <- paste0(bal_tex, "\\small\n")
  bal_tex <- paste0(bal_tex, "\\begin{tabular}{lccc}\n\\hline\\hline\n")
  bal_tex <- paste0(bal_tex, "1940 Covariate & Coefficient & Std. Error & $p$-value \\\\\n\\hline\n")

  for (i in seq_len(nrow(bal))) {
    sig <- ifelse(bal$pval[i] < 0.01, "***",
           ifelse(bal$pval[i] < 0.05, "**",
           ifelse(bal$pval[i] < 0.10, "*", "")))
    bal_tex <- paste0(bal_tex, sprintf("%s & %.4f%s & (%.4f) & %.3f \\\\\n",
      gsub("_", " ", tools::toTitleCase(bal$variable[i])),
      bal$coef[i], sig, bal$se[i], bal$pval[i]))
  }

  f_stat <- robustness$balance_f
  bal_tex <- paste0(bal_tex, "\\hline\n")
  bal_tex <- paste0(bal_tex, sprintf("Joint $F$-test & \\multicolumn{2}{c}{$F = %.2f$} & %.3f \\\\\n",
    f_stat$f$stat, f_stat$f$p))
  bal_tex <- paste0(bal_tex, "\\hline\\hline\n\\end{tabular}\n")
  bal_tex <- paste0(bal_tex, "\\begin{tablenotes}\n\\small\n")
  bal_tex <- paste0(bal_tex, "\\item \\textit{Notes:} Each row reports the coefficient from a bivariate regression of the 1940 state characteristic on standardized mobilization rate, weighted by 1940 female population. The joint $F$-test regresses mobilization on all covariates simultaneously. Significant coefficients indicate mobilization is not conditionally random, motivating the inclusion of controls in main specifications.\n")
  bal_tex <- paste0(bal_tex, "\\end{tablenotes}\n\\end{table}")

  writeLines(bal_tex, file.path(tab_dir, "tab8_balance.tex"))
  cat("  Saved: tab8_balance.tex\n")
}


## --------------------------------------------------------------------------
## Table 9: Oster (2019) Coefficient Stability
## --------------------------------------------------------------------------

cat("=== Table 9: Oster ===\n")

oster <- robustness$oster
tab9_tex <- sprintf(
"\\begin{table}[htbp]
\\centering
\\caption{Coefficient Stability: Oster (2019) Bounds}
\\label{tab:oster}
\\small
\\begin{tabular}{lc}
\\hline\\hline
 & Female LFP Change \\\\
\\hline
$\\hat{\\beta}$ (short regression) & %.4f \\\\
$\\hat{\\beta}$ (long regression) & %.4f \\\\
$R^2$ (short) & %.4f \\\\
$R^2$ (long) & %.4f \\\\
$R^2_{\\max}$ ($= 1.3 \\times R^2_{\\text{long}}$) & %.4f \\\\[3pt]
$\\delta$ (Oster) & %.2f \\\\
\\hline
$|\\delta| > 1$? & %s \\\\
\\hline\\hline
\\end{tabular}
\\begin{tablenotes}
\\small
\\item \\textit{Notes:} Following \\citet{oster2019unobservable}, $\\delta$ measures how much selection on unobservables relative to observables would be needed to drive the coefficient to zero. $|\\delta| > 1$ indicates robustness. Short regression: mobilization on female LFP change, no controls. Long regression: adds 1940 state characteristics. Both regressions population-weighted.
\\end{tablenotes}
\\end{table}",
  oster$beta_s, oster$beta_l,
  oster$r2_s, oster$r2_l, oster$r2_max,
  oster$delta,
  ifelse(abs(oster$delta) > 1, "Yes (robust)", "No")
)

writeLines(tab9_tex, file.path(tab_dir, "tab9_oster.tex"))
cat("  Saved: tab9_oster.tex\n")


## --------------------------------------------------------------------------
## Summary
## --------------------------------------------------------------------------

tabs_created <- list.files(tab_dir, pattern = "\\.tex$")
cat(sprintf("\n=== %d tables created in %s/ ===\n", length(tabs_created), tab_dir))
for (f in sort(tabs_created)) cat(sprintf("  %s\n", f))
