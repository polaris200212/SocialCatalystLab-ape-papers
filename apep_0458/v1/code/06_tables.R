## 06_tables.R — All table generation (LaTeX)
## APEP-0458: Second Home Caps and Local Labor Markets

source("code/00_packages.R")

cat("\n=== GENERATING TABLES ===\n")

rdd <- fread("data/rdd_cross_section.csv")
rdd[is.infinite(emp_growth_post), emp_growth_post := NA]
rdd[is.infinite(share_tertiary_post), share_tertiary_post := NA]
rdd <- rdd[!is.na(emp_total_pre) & emp_total_pre > 0]

panel <- fread("data/analysis_panel.csv")
panel[is.infinite(share_tertiary), share_tertiary := NA]
panel <- panel[!is.na(emp_total) & emp_total > 0]

# ---------------------------------------------------------------------------
# Table 1: Summary Statistics
# ---------------------------------------------------------------------------
cat("Table 1: Summary statistics...\n")

pre <- panel[year %in% c(2011, 2012)]
pre_collapsed <- pre[, .(
  emp_total = mean(emp_total, na.rm = TRUE),
  fte_total = mean(fte_total, na.rm = TRUE),
  share_secondary = mean(share_secondary, na.rm = TRUE),
  share_tertiary = mean(share_tertiary, na.rm = TRUE),
  zwa_pct = mean(zwa_pct, na.rm = TRUE)
), by = .(gemeinde_nr, treated)]

sum_stats <- function(dt, varname) {
  x <- dt[[varname]]
  x <- x[!is.na(x) & !is.infinite(x)]
  c(Mean = mean(x), SD = sd(x), Min = min(x), Max = max(x), N = length(x))
}

vars <- c("zwa_pct", "emp_total", "fte_total", "share_secondary", "share_tertiary")
labels <- c("Second-Home Share (\\%)", "Total Employment", "Full-Time Equivalents",
            "Secondary Sector Share", "Tertiary Sector Share")

# Full sample
full <- do.call(rbind, lapply(vars, function(v) sum_stats(pre_collapsed, v)))
rownames(full) <- labels

# By treatment
treated_dt <- pre_collapsed[treated == 1]
control_dt <- pre_collapsed[treated == 0]
treat <- do.call(rbind, lapply(vars, function(v) sum_stats(treated_dt, v)))
ctrl <- do.call(rbind, lapply(vars, function(v) sum_stats(control_dt, v)))

sink("tables/tab1_summary.tex")
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Summary Statistics: Pre-Treatment Municipality Characteristics (2011--2012)}\n")
cat("\\label{tab:summary}\n")
cat("\\small\n")
cat("\\begin{tabular}{lccccccc}\n")
cat("\\toprule\n")
cat(" & \\multicolumn{2}{c}{Full Sample} & \\multicolumn{2}{c}{Above 20\\%} & \\multicolumn{2}{c}{Below 20\\%} & \\\\\n")
cat("\\cmidrule(lr){2-3} \\cmidrule(lr){4-5} \\cmidrule(lr){6-7}\n")
cat("Variable & Mean & SD & Mean & SD & Mean & SD & $N$ \\\\\n")
cat("\\midrule\n")
for (i in seq_along(labels)) {
  cat(sprintf("%s & %.1f & %.1f & %.1f & %.1f & %.1f & %.1f & %d \\\\\n",
              labels[i],
              full[i, "Mean"], full[i, "SD"],
              treat[i, "Mean"], treat[i, "SD"],
              ctrl[i, "Mean"], ctrl[i, "SD"],
              as.integer(full[i, "N"])))
}
cat("\\midrule\n")
cat(sprintf("Municipalities & \\multicolumn{2}{c}{%d} & \\multicolumn{2}{c}{%d} & \\multicolumn{2}{c}{%d} & \\\\\n",
            nrow(pre_collapsed), nrow(treated_dt), nrow(control_dt)))
cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{minipage}{0.95\\textwidth}\n")
cat("\\vspace{0.3em}\n")
cat("\\footnotesize \\textit{Notes:} Statistics computed from the 2011--2012 pre-treatment period.\n")
cat("Second-home share from the Federal Register of Dwellings (GWR). Employment data from STATENT.\n")
cat("``Above 20\\%'' denotes municipalities subject to the Lex Weber construction ban.\n")
cat("$N$ varies across rows because STATENT does not report sector-level employment for all municipalities (26 missing secondary, 13 missing tertiary).\n")
cat("\\end{minipage}\n")
cat("\\end{table}\n")
sink()
cat("  Saved tab1_summary.tex\n")

# ---------------------------------------------------------------------------
# Table 2: Main RDD Results
# ---------------------------------------------------------------------------
cat("Table 2: Main RDD results...\n")

results <- fread("data/rdd_main_results.csv")

# Tourism results moved to appendix due to N_right = 3 (insufficient for valid RDD inference)

sink("tables/tab2_main_results.tex")
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Main RDD Estimates: Effect of Second-Home Construction Ban on Local Employment}\n")
cat("\\label{tab:main}\n")
cat("\\begin{tabular}{lcccccc}\n")
cat("\\toprule\n")
cat("Outcome & Estimate & SE & $p$-value & Bandwidth & $N_{\\text{left}}$ & $N_{\\text{right}}$ \\\\\n")
cat("\\midrule\n")
for (i in seq_len(nrow(results))) {
  r <- results[i]
  stars <- ifelse(r$pv_robust < 0.01, "***",
           ifelse(r$pv_robust < 0.05, "**",
           ifelse(r$pv_robust < 0.10, "*", "")))
  cat(sprintf("%s & %.3f%s & (%.3f) & %.3f & %.1f & %d & %d \\\\\n",
              r$label,
              r$estimate, stars, r$se_robust, r$pv_robust,
              r$bw_main, r$n_left, r$n_right))
}
cat("\\midrule\n")
cat("Kernel & \\multicolumn{6}{c}{Triangular} \\\\\n")
cat("Polynomial order & \\multicolumn{6}{c}{1 (local linear)} \\\\\n")
cat("Bandwidth selection & \\multicolumn{6}{c}{CCT optimal} \\\\\n")
cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{minipage}{0.95\\textwidth}\n")
cat("\\vspace{0.3em}\n")
cat("\\footnotesize \\textit{Notes:} Local linear RDD estimates using the \\citet{calonico2014} robust bias-corrected procedure.\n")
cat("Bandwidth selected via CCT optimal method. Robust bias-corrected standard errors in parentheses.\n")
cat("$p$-values are from the robust bias-corrected test and may not correspond to simple $t$-ratios of estimate/SE.\n")
cat("$^{***}p<0.01$; $^{**}p<0.05$; $^{*}p<0.10$.\n")
cat("\\end{minipage}\n")
cat("\\end{table}\n")
sink()
cat("  Saved tab2_main_results.tex\n")

# ---------------------------------------------------------------------------
# Table 3: Bandwidth Sensitivity
# ---------------------------------------------------------------------------
cat("Table 3: Bandwidth sensitivity...\n")

bw <- fread("data/robustness_bandwidth.csv")

sink("tables/tab3_bandwidth.tex")
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Bandwidth Sensitivity: Employment Growth}\n")
cat("\\label{tab:bandwidth}\n")
cat("\\begin{tabular}{lcccc}\n")
cat("\\toprule\n")
cat("Bandwidth (pp) & Fraction of Optimal & Estimate & SE & $N$ \\\\\n")
cat("\\midrule\n")
for (i in seq_len(nrow(bw))) {
  r <- bw[i]
  stars <- ifelse(r$pv_robust < 0.01, "***",
           ifelse(r$pv_robust < 0.05, "**",
           ifelse(r$pv_robust < 0.10, "*", "")))
  cat(sprintf("%.1f & %.2f$\\times$ & %.3f%s & (%.3f) & %d \\\\\n",
              r$bandwidth, r$fraction, r$estimate, stars, r$se_robust, r$n))
}
cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{minipage}{0.85\\textwidth}\n")
cat("\\vspace{0.3em}\n")
cat("\\footnotesize \\textit{Notes:} RDD estimates for employment growth at varying multiples of the CCT optimal bandwidth.\n")
cat("Robust standard errors in parentheses. $^{***}p<0.01$; $^{**}p<0.05$; $^{*}p<0.10$.\n")
cat("\\end{minipage}\n")
cat("\\end{table}\n")
sink()
cat("  Saved tab3_bandwidth.tex\n")

# ---------------------------------------------------------------------------
# Table 4: Robustness — Polynomial and Kernel
# ---------------------------------------------------------------------------
cat("Table 4: Polynomial and kernel sensitivity...\n")

poly <- fread("data/robustness_polynomial.csv")
kernel <- fread("data/robustness_kernel.csv")

sink("tables/tab4_robustness.tex")
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Robustness: Polynomial Order and Kernel Sensitivity}\n")
cat("\\label{tab:robustness}\n")
cat("\\begin{tabular}{llcccc}\n")
cat("\\toprule\n")
cat("Specification & Detail & Estimate & SE & $p$-value & $N$ \\\\\n")
cat("\\midrule\n")
cat("\\multicolumn{6}{l}{\\textit{Panel A: Polynomial Order}} \\\\\n")
for (i in seq_len(nrow(poly))) {
  r <- poly[i]
  cat(sprintf("  & Order %d & %.3f & (%.3f) & %.3f & %d \\\\\n",
              r$poly_order, r$estimate, r$se_robust, r$pv_robust, r$n))
}
cat("\\midrule\n")
cat("\\multicolumn{6}{l}{\\textit{Panel B: Kernel Function}} \\\\\n")
for (i in seq_len(nrow(kernel))) {
  r <- kernel[i]
  kname <- tools::toTitleCase(r$kernel)
  cat(sprintf("  & %s & %.3f & (%.3f) & %.3f & %d \\\\\n",
              kname, r$estimate, r$se_robust, r$pv_robust, r$n))
}
cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{minipage}{0.85\\textwidth}\n")
cat("\\vspace{0.3em}\n")
cat("\\footnotesize \\textit{Notes:} Outcome is employment growth (post vs.\\ pre-treatment).\n")
cat("Panel A varies the polynomial order with a triangular kernel.\n")
cat("Panel B varies the kernel function with a local linear specification.\n")
cat("All bandwidths CCT-optimal. Robust standard errors in parentheses.\n")
cat("\\end{minipage}\n")
cat("\\end{table}\n")
sink()
cat("  Saved tab4_robustness.tex\n")

# ---------------------------------------------------------------------------
# Table 5: Placebo Thresholds
# ---------------------------------------------------------------------------
cat("Table 5: Placebo thresholds...\n")

placebo <- fread("data/robustness_placebo.csv")

sink("tables/tab5_placebo.tex")
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Placebo Threshold Tests}\n")
cat("\\label{tab:placebo}\n")
cat("\\begin{tabular}{lcccc}\n")
cat("\\toprule\n")
cat("Threshold (\\%) & Estimate & SE & $p$-value & $N$ \\\\\n")
cat("\\midrule\n")
for (i in seq_len(nrow(placebo))) {
  r <- placebo[i]
  stars <- ifelse(r$pv_robust < 0.01, "***",
           ifelse(r$pv_robust < 0.05, "**",
           ifelse(r$pv_robust < 0.10, "*", "")))
  cat(sprintf("%d & %.3f%s & (%.3f) & %.3f & %d \\\\\n",
              r$threshold, r$estimate, stars, r$se_robust, r$pv_robust, r$n))
}
cat("\\midrule\n")
cat("Actual (20\\%) & \\multicolumn{4}{c}{See Table \\ref{tab:main}} \\\\\n")
cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{minipage}{0.85\\textwidth}\n")
cat("\\vspace{0.3em}\n")
cat("\\footnotesize \\textit{Notes:} RDD estimates at placebo thresholds where no policy discontinuity exists.\n")
cat("Outcome: employment growth. A well-identified RDD should show no effects at placebo cutoffs.\n")
cat("\\end{minipage}\n")
cat("\\end{table}\n")
sink()
cat("  Saved tab5_placebo.tex\n")

# ---------------------------------------------------------------------------
# Table 6: Covariate Balance
# ---------------------------------------------------------------------------
cat("Table 6: Covariate balance...\n")

balance <- fread("data/covariate_balance.csv")

sink("tables/tab6_balance.tex")
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Covariate Balance at the 20\\% Threshold}\n")
cat("\\label{tab:balance}\n")
cat("\\begin{tabular}{lcccc}\n")
cat("\\toprule\n")
cat("Covariate & RDD Estimate & SE & $p$-value & $N$ \\\\\n")
cat("\\midrule\n")
for (i in seq_len(nrow(balance))) {
  r <- balance[i]
  cat(sprintf("%s & %.3f & (%.3f) & %.3f & %d \\\\\n",
              r$covariate, r$estimate, r$se_robust, r$pv_robust,
              as.integer(r$n_eff)))
}
cat("\\midrule\n")
cat(sprintf("Common bandwidth & \\multicolumn{4}{c}{%.1f pp} \\\\\n", balance$bw[1]))
cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{minipage}{0.90\\textwidth}\n")
cat("\\vspace{0.3em}\n")
cat("\\footnotesize \\textit{Notes:} Each row reports an RDD estimate of the discontinuity in a pre-treatment covariate at the 20\\% threshold.\n")
cat("All covariates tested at a common bandwidth (median of individual CCT-optimal bandwidths) to ensure comparable sample sizes.\n")
cat("Employment is measured in logs; sector shares as fractions. Insignificant estimates indicate smooth covariate transitions.\n")
cat("\\end{minipage}\n")
cat("\\end{table}\n")
sink()
cat("  Saved tab6_balance.tex\n")

# ---------------------------------------------------------------------------
# Table 7: Donut-Hole RDD
# ---------------------------------------------------------------------------
cat("Table 7: Donut-hole RDD...\n")

if (file.exists("data/robustness_donut.csv")) {
  donut <- fread("data/robustness_donut.csv")

  sink("tables/tab7_donut.tex")
  cat("\\begin{table}[htbp]\n")
  cat("\\centering\n")
  cat("\\caption{Donut-Hole RDD Estimates}\n")
  cat("\\label{tab:donut}\n")
  cat("\\begin{tabular}{lcccc}\n")
  cat("\\toprule\n")
  cat("Donut Radius (pp) & Estimate & SE & $p$-value & $N$ \\\\\n")
  cat("\\midrule\n")
  for (i in seq_len(nrow(donut))) {
    r <- donut[i]
    cat(sprintf("$\\pm$ %.1f & %.3f & (%.3f) & %.3f & %d \\\\\n",
                r$donut_size, r$estimate, r$se_robust, r$pv_robust, r$n))
  }
  cat("\\bottomrule\n")
  cat("\\end{tabular}\n")
  cat("\\begin{minipage}{0.85\\textwidth}\n")
  cat("\\vspace{0.3em}\n")
  cat("\\footnotesize \\textit{Notes:} RDD estimates excluding municipalities within the stated radius of the 20\\% threshold.\n")
  cat("Outcome: employment growth. Donut-hole designs guard against threshold manipulation.\n")
  cat("\\end{minipage}\n")
  cat("\\end{table}\n")
  sink()
  cat("  Saved tab7_donut.tex\n")
}

# ---------------------------------------------------------------------------
# Table 8: McCrary Density Test
# ---------------------------------------------------------------------------
cat("Table 8: McCrary density test...\n")

density <- fread("data/density_test.csv")

sink("tables/tab8_density.tex")
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{McCrary Density Test at the 20\\% Threshold}\n")
cat("\\label{tab:density}\n")
cat("\\begin{tabular}{lc}\n")
cat("\\toprule\n")
cat("Statistic & Value \\\\\n")
cat("\\midrule\n")
cat(sprintf("$t$-statistic & %.3f \\\\\n", density$t_stat))
cat(sprintf("$p$-value & %.3f \\\\\n", density$p_value))
cat(sprintf("Effective $N$ (left) & %d \\\\\n", density$n_left))
cat(sprintf("Effective $N$ (right) & %d \\\\\n", density$n_right))
cat(sprintf("Bandwidth (left) & %.2f \\\\\n", density$bw_left))
cat(sprintf("Bandwidth (right) & %.2f \\\\\n", density$bw_right))
cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{minipage}{0.75\\textwidth}\n")
cat("\\vspace{0.3em}\n")
cat("\\footnotesize \\textit{Notes:} \\citet{cattaneo2020} manipulation test for the density of the running variable.\n")
cat("A non-significant $p$-value indicates no evidence of sorting around the threshold.\n")
cat("\\end{minipage}\n")
cat("\\end{table}\n")
sink()
cat("  Saved tab8_density.tex\n")

cat("\n=== TABLES DONE ===\n")
