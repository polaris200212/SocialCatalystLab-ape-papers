## ═══════════════════════════════════════════════════════════════════════════
## 06_tables.R — All tables for the paper
## Paper: Does Piped Water Build Human Capital? Evidence from India's JJM
## ═══════════════════════════════════════════════════════════════════════════

script_dir <- dirname(sys.frame(1)$ofile %||% ".")
if (script_dir == ".") script_dir <- getwd()
source(file.path(script_dir, "00_packages.R"))
load(file.path(data_dir, "analysis_data.RData"))
load(file.path(data_dir, "main_results.RData"))
load(file.path(data_dir, "robustness_results.RData"))

dir.create(tab_dir, recursive = TRUE, showWarnings = FALSE)

# Disable siunitx wrapping to keep LaTeX simple
options("modelsummary_format_numeric_latex" = "plain")

cm <- c("water_gap" = "Water Gap")
gm <- list(
  list("raw" = "nobs", "clean" = "Observations", "fmt" = 0),
  list("raw" = "r.squared", "clean" = "R-squared", "fmt" = 3)
)

# ═══════════════════════════════════════════════════════════════════════════
# TABLE 1: SUMMARY STATISTICS
# ═══════════════════════════════════════════════════════════════════════════

cat("Generating Table 1: Summary Statistics\n")

sum_vars <- c(
  "fem_school_attend_nfhs4", "fem_school_attend_nfhs5", "d_fem_school_attend",
  "women_10yr_school_nfhs4", "women_10yr_school_nfhs5", "d_women_10yr_school",
  "improved_water_nfhs4", "improved_water_nfhs5", "d_improved_water",
  "water_gap",
  "child_diarrhea_nfhs4", "child_diarrhea_nfhs5", "d_child_diarrhea",
  "child_stunted_nfhs4", "child_stunted_nfhs5", "d_child_stunted",
  "literacy_rate", "pop_sc_share", "pop_st_share", "log_pop"
)

sum_labels <- c(
  "Female school attendance (NFHS-4)", "Female school attendance (NFHS-5)",
  "$\\Delta$ Female school attendance",
  "Women 10+ years schooling (NFHS-4)", "Women 10+ years schooling (NFHS-5)",
  "$\\Delta$ Women 10+ years schooling",
  "Improved water source (NFHS-4)", "Improved water source (NFHS-5)",
  "$\\Delta$ Improved water source",
  "Water infrastructure deficit",
  "Child diarrhea (NFHS-4)", "Child diarrhea (NFHS-5)",
  "$\\Delta$ Child diarrhea",
  "Child stunting (NFHS-4)", "Child stunting (NFHS-5)",
  "$\\Delta$ Child stunting",
  "Literacy rate (Census 2011)", "SC population share",
  "ST population share", "Log population"
)

sum_stats <- data.frame(
  Variable = sum_labels,
  Mean = sapply(sum_vars, function(v) sprintf("%.2f", mean(df_analysis[[v]], na.rm = TRUE))),
  SD = sapply(sum_vars, function(v) sprintf("%.2f", sd(df_analysis[[v]], na.rm = TRUE))),
  Min = sapply(sum_vars, function(v) sprintf("%.2f", min(df_analysis[[v]], na.rm = TRUE))),
  Max = sapply(sum_vars, function(v) sprintf("%.2f", max(df_analysis[[v]], na.rm = TRUE))),
  N = sapply(sum_vars, function(v) sum(!is.na(df_analysis[[v]])))
)
row.names(sum_stats) <- NULL

tex_lines <- c(
  "\\begin{table}[H]",
  "\\centering",
  "\\caption{Summary Statistics}",
  "\\label{tab:summary}",
  "\\begin{threeparttable}",
  "\\begin{tabular}{lrrrrr}",
  "\\toprule",
  "Variable & Mean & SD & Min & Max & N \\\\",
  "\\midrule",
  "\\multicolumn{6}{l}{\\textit{Panel A: Education Outcomes}} \\\\",
  paste0(apply(sum_stats[1:6,], 1, function(r) paste(r, collapse = " & ")), " \\\\"),
  "\\midrule",
  "\\multicolumn{6}{l}{\\textit{Panel B: Water Infrastructure}} \\\\",
  paste0(apply(sum_stats[7:10,], 1, function(r) paste(r, collapse = " & ")), " \\\\"),
  "\\midrule",
  "\\multicolumn{6}{l}{\\textit{Panel C: Health Outcomes}} \\\\",
  paste0(apply(sum_stats[11:16,], 1, function(r) paste(r, collapse = " & ")), " \\\\"),
  "\\midrule",
  "\\multicolumn{6}{l}{\\textit{Panel D: Controls}} \\\\",
  paste0(apply(sum_stats[17:20,], 1, function(r) paste(r, collapse = " & ")), " \\\\"),
  "\\bottomrule",
  "\\end{tabular}",
  "\\begin{tablenotes}[flushleft]",
  "\\small",
  paste0("\\item Notes: N = ", nrow(df_analysis), " districts. All NFHS variables in percentage points. Water infrastructure deficit = 100 minus NFHS-4 improved drinking water coverage."),
  "\\end{tablenotes}",
  "\\end{threeparttable}",
  "\\end{table}"
)
writeLines(tex_lines, file.path(tab_dir, "tab1_summary.tex"))
cat("Table 1 saved\n")

# ═══════════════════════════════════════════════════════════════════════════
# TABLE 3: FIRST STAGE
# ═══════════════════════════════════════════════════════════════════════════

cat("Generating Table 3: First Stage\n")

modelsummary(
  list("(1)" = results$fs$fs1, "(2)" = results$fs$fs2,
       "(3)" = results$fs$fs3, "(4)" = results$fs$fs4),
  output = file.path(tab_dir, "tab3_first_stage.tex"),
  coef_map = cm, gof_map = gm,
  title = "First Stage: Baseline Water Deficit Predicts Water Access Improvement",
  notes = list("Dependent variable: Change in improved drinking water source (NFHS-5 minus NFHS-4).",
    "Standard errors in parentheses. Columns (2)-(4) include state fixed effects.",
    "Column (3) adds Census 2011 controls. Column (4) adds baseline infrastructure."),
  stars = c("*" = 0.1, "**" = 0.05, "***" = 0.01))
cat("Table 3 saved\n")

# ═══════════════════════════════════════════════════════════════════════════
# TABLE 4: REDUCED FORM — Education outcomes
# ═══════════════════════════════════════════════════════════════════════════

cat("Generating Table 4: Reduced Form Education\n")

modelsummary(
  list("(1)" = results$rf_school$rf_school1, "(2)" = results$rf_school$rf_school2,
       "(3)" = results$rf_school$rf_school3, "(4)" = results$rf_school$rf_school4,
       "(5)" = results$rf_10yr$rf_10yr2, "(6)" = results$rf_lit$rf_lit2),
  output = file.path(tab_dir, "tab4_reduced_form.tex"),
  coef_map = cm, gof_map = gm,
  title = "Reduced Form: Baseline Water Deficit and Education Improvements",
  notes = list("Dependent variables: (1)-(4) change in female school attendance;",
    "(5) change in women with 10+ years schooling; (6) change in women's literacy.",
    "State FEs in (2)-(6). Controls in (3)-(6). Clustered SEs in (4)-(6)."),
  stars = c("*" = 0.1, "**" = 0.05, "***" = 0.01))
cat("Table 4 saved\n")

# ═══════════════════════════════════════════════════════════════════════════
# TABLE 5: IV ESTIMATES
# ═══════════════════════════════════════════════════════════════════════════

cat("Generating Table 5: IV Estimates\n")

cm_iv <- c("fit_d_improved_water" = "Change in Improved Water (instrumented)")

modelsummary(
  list("(1)" = results$iv$iv_school1, "(2)" = results$iv$iv_school2,
       "(3)" = results$iv$iv_school3, "(4)" = results$iv$iv_10yr),
  output = file.path(tab_dir, "tab5_iv.tex"),
  coef_map = cm_iv, gof_map = gm,
  title = "IV Estimates: Effect of Water Access Improvement on Education",
  notes = list("Dependent variables: (1)-(3) change in female school attendance;",
    "(4) change in women with 10+ years schooling.",
    "Instrument: baseline water deficit. State FEs in all columns.",
    "Controls in (2)-(4). Clustered SEs at state level in (3)-(4)."),
  stars = c("*" = 0.1, "**" = 0.05, "***" = 0.01))
cat("Table 5 saved\n")

# ═══════════════════════════════════════════════════════════════════════════
# TABLE 6: HEALTH MECHANISM
# ═══════════════════════════════════════════════════════════════════════════

cat("Generating Table 6: Health Outcomes\n")

modelsummary(
  list("Diarrhea" = results$health$rf_diarrhea,
       "Stunting" = results$health$rf_stunted,
       "Underweight" = results$health$rf_underweight,
       "Inst. Births" = results$health$rf_instbirth,
       "ANC 4+" = results$health$rf_anc),
  output = file.path(tab_dir, "tab6_health.tex"),
  coef_map = cm, gof_map = gm,
  title = "Health Mechanism: Baseline Water Deficit and Child/Maternal Health",
  notes = list("All columns include state FEs, Census 2011 controls, and baseline infrastructure.",
    "Standard errors clustered at state level."),
  stars = c("*" = 0.1, "**" = 0.05, "***" = 0.01))
cat("Table 6 saved\n")

# ═══════════════════════════════════════════════════════════════════════════
# TABLE 7: PLACEBO TESTS
# ═══════════════════════════════════════════════════════════════════════════

cat("Generating Table 7: Placebo Tests\n")

modelsummary(
  list("Tobacco" = robustness$placebos$tobacco,
       "Teen Preg." = robustness$placebos$teen,
       "Child Marriage" = robustness$placebos$marriage,
       "Insurance" = robustness$placebos$insurance),
  output = file.path(tab_dir, "tab7_placebos.tex"),
  coef_map = cm, gof_map = gm,
  title = "Placebo Tests: Outcomes That Should Not Respond to Water Infrastructure",
  notes = list("All columns include state FEs, Census 2011 controls, and baseline infrastructure.",
    "Standard errors clustered at state level.",
    "None of these outcomes should respond to water infrastructure alone."),
  stars = c("*" = 0.1, "**" = 0.05, "***" = 0.01))
cat("Table 7 saved\n")

# ═══════════════════════════════════════════════════════════════════════════
# TABLE 8: ROBUSTNESS
# ═══════════════════════════════════════════════════════════════════════════

cat("Generating Table 8: Robustness\n")

cm_rob <- c("water_gap" = "Water Gap (continuous)",
  "high_water_gap" = "High Water Gap (binary)",
  "water_gap_sd" = "Water Gap (1 SD)")

modelsummary(
  list("Binary" = robustness$alt_treatment$binary,
       "1 SD" = robustness$alt_treatment$sd,
       "Trimmed" = robustness$sample$trim,
       "Excl. NE" = robustness$sample$no_ne,
       "Gap > 1pct" = robustness$sample$positive),
  output = file.path(tab_dir, "tab8_robustness.tex"),
  coef_map = cm_rob, gof_map = gm,
  title = "Robustness: Alternative Specifications and Sample Restrictions",
  notes = list("Dependent variable: change in female school attendance.",
    "All columns include state FEs and controls. Clustered SEs at state level."),
  stars = c("*" = 0.1, "**" = 0.05, "***" = 0.01))
cat("Table 8 saved\n")

# ═══════════════════════════════════════════════════════════════════════════
# TABLE 9: HETEROGENEITY
# ═══════════════════════════════════════════════════════════════════════════

cat("Generating Table 9: Heterogeneity\n")

cm_het <- c("water_gap" = "Water Gap",
  "water_gap:low_literacy" = "Water Gap x Low Literacy",
  "water_gap:high_scst" = "Water Gap x High SC/ST",
  "water_gap:high_agr" = "Water Gap x High Agriculture",
  "low_literacy" = "Low Literacy",
  "high_scst" = "High SC/ST",
  "high_agr" = "High Agriculture")

modelsummary(
  list("Literacy" = robustness$heterogeneity$literacy,
       "SC/ST" = robustness$heterogeneity$scst,
       "Agriculture" = robustness$heterogeneity$agr),
  output = file.path(tab_dir, "tab9_heterogeneity.tex"),
  coef_map = cm_het, gof_map = gm,
  title = "Heterogeneity: Who Benefits Most from Water Infrastructure?",
  notes = list("Dependent variable: change in female school attendance.",
    "All columns include state FEs and controls. Clustered SEs at state level."),
  stars = c("*" = 0.1, "**" = 0.05, "***" = 0.01))
cat("Table 9 saved\n")

cat("\n✓ All tables complete\n")
