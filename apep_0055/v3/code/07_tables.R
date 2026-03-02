# ============================================================================
# APEP-0055 v3: Coverage Cliffs — Age 26 RDD on Birth Insurance Coverage
# 07_tables.R - Generate all LaTeX tables (written to files via sink())
# ============================================================================
# This is the consolidated table generation script. All tables are written
# to .tex files in the tables/ directory for \input{} in the paper.

source("00_packages.R")

# Create tables directory
dir.create(tables_dir, showWarnings = FALSE)

# ============================================================================
# Table 1: Summary Statistics
# ============================================================================

natality <- readRDS(file.path(data_dir, "natality_analysis.rds"))
n_years <- length(unique(natality$data_year))
year_range <- sprintf("%d--%d", min(natality$data_year), max(natality$data_year))

natality[, above26 := MAGER >= 26]

# Calculate means by group
summary_stats <- natality[, .(
  N = .N,
  Medicaid = mean(medicaid, na.rm = TRUE),
  Private = mean(private, na.rm = TRUE),
  SelfPay = mean(selfpay, na.rm = TRUE),
  Married = mean(married, na.rm = TRUE),
  College = mean(college, na.rm = TRUE),
  USBorn = mean(us_born, na.rm = TRUE),
  EarlyPrenatal = mean(early_prenatal, na.rm = TRUE),
  Preterm = mean(preterm, na.rm = TRUE),
  LowBirthWeight = mean(low_birthweight, na.rm = TRUE)
), by = above26]

# Save Table 1
sink(file.path(tables_dir, "table1_summary.tex"))
cat("\\begin{table}[H]\n")
cat("\\centering\n")
cat("\\caption{Summary Statistics by Age Group}\n")
cat("\\label{tab:summary}\n")
cat("\\begin{tabular}{lcc}\n")
cat("\\toprule\n")
cat(" & Age 22--25 & Age 26--30 \\\\\n")
cat("\\midrule\n")
cat("\\textit{Payment Source} & & \\\\\n")
cat(sprintf("\\quad Medicaid & %.1f\\%% & %.1f\\%% \\\\\n",
            summary_stats[above26 == FALSE, Medicaid * 100],
            summary_stats[above26 == TRUE, Medicaid * 100]))
cat(sprintf("\\quad Private Insurance & %.1f\\%% & %.1f\\%% \\\\\n",
            summary_stats[above26 == FALSE, Private * 100],
            summary_stats[above26 == TRUE, Private * 100]))
cat(sprintf("\\quad Self-Pay & %.1f\\%% & %.1f\\%% \\\\\n",
            summary_stats[above26 == FALSE, SelfPay * 100],
            summary_stats[above26 == TRUE, SelfPay * 100]))
cat("\\midrule\n")
cat("\\textit{Demographics} & & \\\\\n")
cat(sprintf("\\quad Married & %.1f\\%% & %.1f\\%% \\\\\n",
            summary_stats[above26 == FALSE, Married * 100],
            summary_stats[above26 == TRUE, Married * 100]))
cat(sprintf("\\quad College Degree & %.1f\\%% & %.1f\\%% \\\\\n",
            summary_stats[above26 == FALSE, College * 100],
            summary_stats[above26 == TRUE, College * 100]))
cat(sprintf("\\quad US-Born & %.1f\\%% & %.1f\\%% \\\\\n",
            summary_stats[above26 == FALSE, USBorn * 100],
            summary_stats[above26 == TRUE, USBorn * 100]))
cat("\\midrule\n")
cat("\\textit{Health Outcomes} & & \\\\\n")
cat(sprintf("\\quad Early Prenatal Care & %.1f\\%% & %.1f\\%% \\\\\n",
            summary_stats[above26 == FALSE, EarlyPrenatal * 100],
            summary_stats[above26 == TRUE, EarlyPrenatal * 100]))
cat(sprintf("\\quad Preterm Birth & %.1f\\%% & %.1f\\%% \\\\\n",
            summary_stats[above26 == FALSE, Preterm * 100],
            summary_stats[above26 == TRUE, Preterm * 100]))
cat(sprintf("\\quad Low Birth Weight & %.1f\\%% & %.1f\\%% \\\\\n",
            summary_stats[above26 == FALSE, LowBirthWeight * 100],
            summary_stats[above26 == TRUE, LowBirthWeight * 100]))
cat("\\midrule\n")
cat(sprintf("Observations & %s & %s \\\\\n",
            format(summary_stats[above26 == FALSE, N], big.mark = ","),
            format(summary_stats[above26 == TRUE, N], big.mark = ",")))
cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat(sprintf("\\floatfoot{\\textit{Notes:} Sample includes all births to mothers ages 22--30 in %s CDC Natality data (%d years pooled). Percentages are unweighted means.}\n",
            year_range, n_years))
cat("\\end{table}\n")
sink()

cat("Table 1 saved.\n")

# ============================================================================
# Table 2: Main RDD Results
# ============================================================================

results <- readRDS(file.path(data_dir, "rd_results.rds"))

sink(file.path(tables_dir, "table2_main.tex"))
cat("\\begin{table}[H]\n")
cat("\\centering\n")
cat("\\caption{Main RDD Results: Effect of Age 26 Threshold on Payment Source and Health}\n")
cat("\\label{tab:main}\n")
cat("\\begin{tabular}{lccccc}\n")
cat("\\toprule\n")
cat("Outcome & RD Estimate & Robust SE & 95\\% CI & p-value & N \\\\\n")
cat("\\midrule\n")
cat("\\textit{Panel A: Payment Source} & & & & & \\\\\n")

for (i in 1:3) {
  outcome <- results$Outcome[i]
  est <- sprintf("%.3f", results$RD_Estimate[i])
  se <- sprintf("(%.3f)", results$Robust_SE[i])
  ci <- sprintf("[%.3f, %.3f]", results$CI_Lower[i], results$CI_Upper[i])
  pval <- ifelse(results$p_value[i] < 0.001, "$<$0.001", sprintf("%.3f", results$p_value[i]))
  n <- format(results$N_Left[i] + results$N_Right[i], big.mark = ",")
  # Significance stars
  stars <- ifelse(results$p_value[i] < 0.001, "***",
           ifelse(results$p_value[i] < 0.01, "**",
           ifelse(results$p_value[i] < 0.05, "*", "")))

  cat(sprintf("\\quad %s & %s%s & %s & %s & %s & %s \\\\\n",
              outcome, est, stars, se, ci, pval, n))
}

cat("\\midrule\n")
cat("\\textit{Panel B: Health Outcomes} & & & & & \\\\\n")

for (i in 4:6) {
  outcome <- results$Outcome[i]
  est <- sprintf("%.3f", results$RD_Estimate[i])
  se <- sprintf("(%.3f)", results$Robust_SE[i])
  ci <- sprintf("[%.3f, %.3f]", results$CI_Lower[i], results$CI_Upper[i])
  pval <- ifelse(results$p_value[i] < 0.001, "$<$0.001", sprintf("%.3f", results$p_value[i]))
  n <- format(results$N_Left[i] + results$N_Right[i], big.mark = ",")
  stars <- ifelse(results$p_value[i] < 0.001, "***",
           ifelse(results$p_value[i] < 0.01, "**",
           ifelse(results$p_value[i] < 0.05, "*", "")))

  cat(sprintf("\\quad %s & %s%s & %s & %s & %s & %s \\\\\n",
              outcome, est, stars, se, ci, pval, n))
}

cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat(sprintf("\\floatfoot{\\textit{Notes:} Local polynomial RD estimates using \\texttt{rdrobust} with MSE-optimal bandwidth and triangular kernel. Robust bias-corrected standard errors in parentheses. N = observations within optimal bandwidth. Data: CDC Natality %s. *** p$<$0.001, ** p$<$0.01, * p$<$0.05.}\n",
            year_range))
cat("\\end{table}\n")
sink()

cat("Table 2 saved.\n")

# ============================================================================
# Table 3: Balance Tests
# ============================================================================

balance <- readRDS(file.path(data_dir, "balance_results.rds"))

sink(file.path(tables_dir, "table3_balance.tex"))
cat("\\begin{table}[H]\n")
cat("\\centering\n")
cat("\\caption{Covariate Balance Tests at Age 26 Threshold}\n")
cat("\\label{tab:balance}\n")
cat("\\begin{tabular}{lccc}\n")
cat("\\toprule\n")
cat("Covariate & RD Estimate & Robust SE & p-value \\\\\n")
cat("\\midrule\n")

for (i in 1:nrow(balance)) {
  if (is.na(balance$RD_Estimate[i])) {
    cat(sprintf("%s & -- & -- & -- \\\\\n", balance$Covariate[i]))
  } else {
    est <- sprintf("%.4f", balance$RD_Estimate[i])
    se <- sprintf("(%.4f)", balance$Robust_SE[i])
    pval <- ifelse(balance$p_value[i] < 0.001, "$<$0.001", sprintf("%.3f", balance$p_value[i]))
    sig <- balance$Significant[i]
    cat(sprintf("%s & %s%s & %s & %s \\\\\n", balance$Covariate[i], est, sig, se, pval))
  }
}

cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat(sprintf("\\floatfoot{\\textit{Notes:} RD estimates for predetermined covariates using local linear regression with MSE-optimal bandwidth. Robust bias-corrected SEs in parentheses. * indicates p$<$0.05. Data: CDC Natality %s.}\n",
            year_range))
cat("\\end{table}\n")
sink()

cat("Table 3 saved.\n")

# ============================================================================
# Table 4: Placebo Tests (FIXED: no attempt to bold age 26)
# ============================================================================

placebo <- readRDS(file.path(data_dir, "placebo_results.rds"))

sink(file.path(tables_dir, "table4_placebo.tex"))
cat("\\begin{table}[H]\n")
cat("\\centering\n")
cat("\\caption{Placebo Cutoff Tests: Medicaid Payment at Non-Policy Ages}\n")
cat("\\label{tab:placebo}\n")
cat("\\begin{tabular}{lccc}\n")
cat("\\toprule\n")
cat("Cutoff Age & RD Estimate & Robust SE & p-value \\\\\n")
cat("\\midrule\n")

for (i in 1:nrow(placebo)) {
  cutoff <- placebo$Cutoff[i]
  est <- sprintf("%.4f", placebo$RD_Estimate[i])
  se <- sprintf("(%.4f)", placebo$Robust_SE[i])
  pval <- ifelse(placebo$p_value[i] < 0.001, "$<$0.001", sprintf("%.3f", placebo$p_value[i]))

  cat(sprintf("%d & %s & %s & %s \\\\\n", cutoff, est, se, pval))
}

cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat(sprintf("\\floatfoot{\\textit{Notes:} RD estimates for Medicaid outcome at placebo ages (24, 25, 27, 28) where no policy change occurs. Compare to the policy-relevant estimate at age 26 in Table~\\ref{tab:main}. Data: CDC Natality %s.}\n",
            year_range))
cat("\\end{table}\n")
sink()

cat("Table 4 saved.\n")

# ============================================================================
# Table 5: Heterogeneity by Marital Status
# ============================================================================

het <- readRDS(file.path(data_dir, "heterogeneity_marital.rds"))

sink(file.path(tables_dir, "table5_heterogeneity.tex"))
cat("\\begin{table}[H]\n")
cat("\\centering\n")
cat("\\caption{Heterogeneity in RDD Effect by Marital Status}\n")
cat("\\label{tab:heterogeneity}\n")
cat("\\begin{tabular}{lcccc}\n")
cat("\\toprule\n")
cat("Group & N & RD Estimate & Robust SE & 95\\% CI \\\\\n")
cat("\\midrule\n")

for (i in 1:nrow(het)) {
  group <- het$Group[i]
  n <- format(het$N[i], big.mark = ",")
  est <- sprintf("%.3f", het$RD_Estimate[i])
  se <- sprintf("(%.3f)", het$Robust_SE[i])
  ci <- sprintf("[%.3f, %.3f]", het$CI_Lower[i], het$CI_Upper[i])
  stars <- ifelse(het$p_value[i] < 0.001, "***",
           ifelse(het$p_value[i] < 0.01, "**",
           ifelse(het$p_value[i] < 0.05, "*", "")))

  cat(sprintf("%s & %s & %s%s & %s & %s \\\\\n", group, n, est, stars, se, ci))
}

cat("\\midrule\n")
cat(sprintf("Difference & & %.3f & & \\\\\n",
            het$RD_Estimate[het$Group == "Unmarried"] - het$RD_Estimate[het$Group == "Married"]))
cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat(sprintf("\\floatfoot{\\textit{Notes:} RD estimates for Medicaid outcome by marital status using local linear regression with MSE-optimal bandwidth. Robust bias-corrected SEs in parentheses. Data: CDC Natality %s. *** p$<$0.001, ** p$<$0.01, * p$<$0.05.}\n",
            year_range))
cat("\\end{table}\n")
sink()

cat("Table 5 saved.\n")

# ============================================================================
# Table 6: Bandwidth Sensitivity (FIXED: includes Robust SE column)
# ============================================================================

bw_table <- readRDS(file.path(data_dir, "bandwidth_sensitivity.rds"))

sink(file.path(tables_dir, "table6_bandwidth.tex"))
cat("\\begin{table}[H]\n")
cat("\\centering\n")
cat("\\caption{Bandwidth Sensitivity: Medicaid RD Estimates}\n")
cat("\\label{tab:bandwidth}\n")
cat("\\begin{tabular}{lcccc}\n")
cat("\\toprule\n")
cat("Bandwidth & N & RD Estimate & Robust SE & 95\\% CI \\\\\n")
cat("\\midrule\n")

for (i in 1:nrow(bw_table)) {
  cat(sprintf("%d years & %s & %.4f & (%.4f) & [%.4f, %.4f] \\\\\n",
              bw_table$Bandwidth[i],
              format(bw_table$N[i], big.mark=","),
              bw_table$RD_Estimate[i],
              bw_table$Robust_SE[i],
              bw_table$CI_Lower[i],
              bw_table$CI_Upper[i]))
}

cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat(sprintf("\\floatfoot{\\textit{Notes:} RD estimates for Medicaid payment at varying bandwidths around age 26. All specifications use local linear regression with triangular kernel and robust bias-corrected SEs. Data: CDC Natality %s.}\n",
            year_range))
cat("\\end{table}\n")
sink()

cat("Table 6 saved.\n")

# ============================================================================
# Table 7: Robustness Summary
# ============================================================================

poly_table <- readRDS(file.path(data_dir, "robustness_polynomial.rds"))
kernel_table <- readRDS(file.path(data_dir, "robustness_kernel.rds"))
donut_results <- readRDS(file.path(data_dir, "robustness_donut.rds"))
cov_results <- readRDS(file.path(data_dir, "robustness_covariates.rds"))

sink(file.path(tables_dir, "table7_robustness.tex"))
cat("\\begin{table}[H]\n")
cat("\\centering\n")
cat("\\caption{Robustness Checks: Medicaid RD Estimates}\n")
cat("\\label{tab:robustness}\n")
cat("\\begin{tabular}{lcc}\n")
cat("\\toprule\n")
cat("Specification & RD Estimate & 95\\% CI \\\\\n")
cat("\\midrule\n")
cat("\\textit{Polynomial Order} & & \\\\\n")
for (i in 1:nrow(poly_table)) {
  cat(sprintf("\\quad Order %d & %.4f & [%.4f, %.4f] \\\\\n",
              poly_table$Polynomial[i], poly_table$RD_Estimate[i],
              poly_table$CI_Lower[i], poly_table$CI_Upper[i]))
}
cat("\\midrule\n")
cat("\\textit{Kernel} & & \\\\\n")
for (i in 1:nrow(kernel_table)) {
  cat(sprintf("\\quad %s & %.4f & [%.4f, %.4f] \\\\\n",
              tools::toTitleCase(kernel_table$Kernel[i]),
              kernel_table$RD_Estimate[i],
              kernel_table$CI_Lower[i], kernel_table$CI_Upper[i]))
}
cat("\\midrule\n")
cat(sprintf("Donut-hole (excl.\\ age 26) & %.4f & \\\\\n",
            donut_results$Donut[1]))
cat(sprintf("With covariates & %.4f & [%.4f, %.4f] \\\\\n",
            cov_results$rd_cov$coef[1],
            cov_results$rd_cov$ci["Robust", "CI Lower"],
            cov_results$rd_cov$ci["Robust", "CI Upper"]))
cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat(sprintf("\\floatfoot{\\textit{Notes:} All specifications estimate the Medicaid payment discontinuity at age 26. Baseline uses local linear regression with triangular kernel and MSE-optimal bandwidth. Covariates include marital status, college degree, and US-born indicator. Data: CDC Natality %s.}\n",
            year_range))
cat("\\end{table}\n")
sink()

cat("Table 7 saved.\n")

# ============================================================================
# Table 8: Subgroup Heterogeneity (Education × Marital Status)
# ============================================================================

expansion_het <- readRDS(file.path(data_dir, "expansion_heterogeneity.rds"))

sink(file.path(tables_dir, "table8_subgroups.tex"))
cat("\\begin{table}[H]\n")
cat("\\centering\n")
cat("\\caption{Heterogeneity by Education and Marital Status}\n")
cat("\\label{tab:subgroups}\n")
cat("\\begin{tabular}{lccccc}\n")
cat("\\toprule\n")
cat("Subgroup & N & RD Estimate & Robust SE & 95\\% CI & p-value \\\\\n")
cat("\\midrule\n")

for (i in 1:nrow(expansion_het)) {
  g <- expansion_het$Group[i]
  n <- format(expansion_het$N[i], big.mark = ",")
  est <- sprintf("%.3f", expansion_het$RD_Estimate[i])
  se <- sprintf("(%.3f)", expansion_het$Robust_SE[i])
  ci <- sprintf("[%.3f, %.3f]", expansion_het$CI_Lower[i], expansion_het$CI_Upper[i])
  pval <- ifelse(expansion_het$p_value[i] < 0.001, "$<$0.001",
                 sprintf("%.3f", expansion_het$p_value[i]))
  stars <- ifelse(expansion_het$p_value[i] < 0.001, "***",
           ifelse(expansion_het$p_value[i] < 0.01, "**",
           ifelse(expansion_het$p_value[i] < 0.05, "*", "")))

  cat(sprintf("%s & %s & %s%s & %s & %s & %s \\\\\n",
              g, n, est, stars, se, ci, pval))
}

cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat(sprintf("\\floatfoot{\\textit{Notes:} RD estimates for Medicaid payment by education--marital status subgroup. All specifications use local linear regression with MSE-optimal bandwidth and robust bias-corrected SEs. Data: CDC Natality %s. *** p$<$0.001, ** p$<$0.01, * p$<$0.05.}\n",
            year_range))
cat("\\end{table}\n")
sink()

cat("Table 8 saved.\n")

# ============================================================================
# Table 9: MDE / Power Calculations
# ============================================================================

mde <- readRDS(file.path(data_dir, "mde_results.rds"))

sink(file.path(tables_dir, "table9_mde.tex"))
cat("\\begin{table}[H]\n")
cat("\\centering\n")
cat("\\caption{Minimum Detectable Effects for Health Outcomes}\n")
cat("\\label{tab:mde}\n")
cat("\\begin{tabular}{lcccc}\n")
cat("\\toprule\n")
cat("Outcome & Baseline Mean & N (effective) & MDE & MDE (\\% of mean) \\\\\n")
cat("\\midrule\n")

for (i in 1:nrow(mde)) {
  cat(sprintf("%s & %.3f & %s & %.4f & %.1f\\%% \\\\\n",
              mde$Outcome[i],
              mde$Mean[i],
              format(round(mde$N_effective[i]), big.mark = ","),
              mde$MDE[i],
              mde$MDE_pct[i]))
}

cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\floatfoot{\\textit{Notes:} Minimum detectable effect at 80\\% power and 5\\% significance level. MDE = $2.8 \\times \\sigma / \\sqrt{N_{\\text{eff}}}$, where $N_{\\text{eff}}$ is half the analysis sample within bandwidth 4.}\n")
cat("\\end{table}\n")
sink()

cat("Table 9 saved.\n")

# ============================================================================
# Table 10: Local Randomization Results
# ============================================================================

locrand <- readRDS(file.path(data_dir, "locrand_results.rds"))

sink(file.path(tables_dir, "table10_locrand.tex"))
cat("\\begin{table}[H]\n")
cat("\\centering\n")
cat("\\caption{Permutation Inference: OLS-Detrended Treatment Effect}\n")
cat("\\label{tab:locrand}\n")
cat("\\begin{tabular}{lccc}\n")
cat("\\toprule\n")
cat("Outcome & OLS Coefficient & Permutation p-value & N \\\\\n")
cat("\\midrule\n")

for (nm in names(locrand)) {
  lr <- locrand[[nm]]
  est <- sprintf("%.4f", lr$obs_stat[1])
  pval <- sprintf("%.4f", lr$p_value[1])
  n_total <- format(lr$n_left + lr$n_right, big.mark = ",")
  stars <- ifelse(lr$p_value[1] < 0.001, "***",
           ifelse(lr$p_value[1] < 0.01, "**",
           ifelse(lr$p_value[1] < 0.05, "*", "")))

  cat(sprintf("%s & %s%s & %s & %s \\\\\n",
              lr$outcome, est, stars, pval, n_total))
}

cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat(sprintf("\\floatfoot{\\textit{Notes:} OLS coefficient on treatment indicator from $Y_i = \\alpha + \\beta \\cdot \\text{age}_i + \\gamma \\cdot \\mathbf{1}[\\text{age} \\geq 26] + \\varepsilon_i$ on ages 22--30. Permutation p-values from 2,000 random reassignments of the treatment indicator. Data: CDC Natality %s. *** p$<$0.001, ** p$<$0.01, * p$<$0.05.}\n",
            year_range))
cat("\\end{table}\n")
sink()

cat("Table 10 saved.\n")

cat("\nAll tables saved to:", tables_dir, "\n")
print(list.files(tables_dir, pattern = "\\.tex$"))
