# ============================================================================
# 06_tables.R — LaTeX tables for paper
# APEP-0443: PMGSY Roads and the Gender Gap in Non-Farm Employment
# ============================================================================

source("00_packages.R")

data_dir <- normalizePath(file.path(getwd(), "..", "data"), mustWork = FALSE)
tab_dir  <- normalizePath(file.path(getwd(), "..", "tables"), mustWork = FALSE)

df <- fread(file.path(data_dir, "plains_sample.csv"))

# ── Table 1: Summary Statistics ────────────────────────────────────────────
cat("Table 1: Summary statistics...\n")

# Compute for villages near the threshold (within optimal bandwidth)
df_near <- df[abs(running_var) <= 300]

summ_vars <- c("pop01", "sc_share01", "st_share01", "lit_rate_f01", "lit_rate_m01",
               "lfpr_f01", "lfpr_m01", "nonag_share_f01", "nonag_share_m01",
               "nonag_share_f11", "nonag_share_m11", "lfpr_f11", "lfpr_m11",
               "lit_rate_f11", "lit_rate_m11")

labels <- c("Population (2001)", "SC Share (2001)", "ST Share (2001)",
            "Female Literacy Rate (2001)", "Male Literacy Rate (2001)",
            "Female LFPR (2001)", "Male LFPR (2001)",
            "Female Non-Ag Share (2001)", "Male Non-Ag Share (2001)",
            "Female Non-Ag Share (2011)", "Male Non-Ag Share (2011)",
            "Female LFPR (2011)", "Male LFPR (2011)",
            "Female Literacy Rate (2011)", "Male Literacy Rate (2011)")

# Below vs above threshold
summ_table <- data.frame()
for (i in seq_along(summ_vars)) {
  v <- summ_vars[i]
  below <- df_near[eligible == 0][[v]]
  above <- df_near[eligible == 1][[v]]
  summ_table <- rbind(summ_table, data.frame(
    Variable = labels[i],
    Mean_Below = mean(below, na.rm = TRUE),
    SD_Below   = sd(below, na.rm = TRUE),
    Mean_Above = mean(above, na.rm = TRUE),
    SD_Above   = sd(above, na.rm = TRUE),
    Diff       = mean(above, na.rm = TRUE) - mean(below, na.rm = TRUE),
    N_Below    = sum(!is.na(below)),
    N_Above    = sum(!is.na(above))
  ))
}

fwrite(summ_table, file.path(tab_dir, "summary_stats.csv"))

# Generate LaTeX
sink(file.path(tab_dir, "tab1_summary.tex"))
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Summary Statistics: Villages Near the PMGSY Population Threshold}\n")
cat("\\label{tab:summary}\n")
cat("\\small\n")
cat("\\begin{tabular}{l cc cc c}\n")
cat("\\toprule\n")
cat(" & \\multicolumn{2}{c}{Below 500} & \\multicolumn{2}{c}{Above 500} & \\\\\n")
cat("\\cmidrule(lr){2-3} \\cmidrule(lr){4-5}\n")
cat("Variable & Mean & SD & Mean & SD & Diff \\\\\n")
cat("\\midrule\n")
cat("\\multicolumn{6}{l}{\\textit{Panel A: Pre-Treatment Characteristics (Census 2001)}} \\\\\n")
for (i in 1:9) {
  cat(sprintf("%s & %.3f & %.3f & %.3f & %.3f & %.3f \\\\\n",
              summ_table$Variable[i],
              summ_table$Mean_Below[i], summ_table$SD_Below[i],
              summ_table$Mean_Above[i], summ_table$SD_Above[i],
              summ_table$Diff[i]))
}
cat("\\midrule\n")
cat("\\multicolumn{6}{l}{\\textit{Panel B: Outcomes (Census 2011)}} \\\\\n")
for (i in 10:15) {
  cat(sprintf("%s & %.3f & %.3f & %.3f & %.3f & %.3f \\\\\n",
              summ_table$Variable[i],
              summ_table$Mean_Below[i], summ_table$SD_Below[i],
              summ_table$Mean_Above[i], summ_table$SD_Above[i],
              summ_table$Diff[i]))
}
cat("\\midrule\n")
cat(sprintf("Observations & \\multicolumn{2}{c}{%s} & \\multicolumn{2}{c}{%s} & \\\\\n",
            format(summ_table$N_Below[1], big.mark = ","),
            format(summ_table$N_Above[1], big.mark = ",")))
cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{minipage}{0.95\\textwidth}\n")
cat("\\vspace{0.3em}\n")
cat("\\footnotesize\n")
cat("\\textit{Notes:} Sample restricted to plains-area villages within 300 persons of the PMGSY eligibility threshold (population 200--800). ``Non-Ag Share'' is the share of main workers employed in household industry or ``other'' (non-agricultural) activities. ``LFPR'' is the labor force participation rate (total workers / total population). SC = Scheduled Caste; ST = Scheduled Tribe.\n")
cat("\\end{minipage}\n")
cat("\\end{table}\n")
sink()

# ── Table 2: Main RDD Results ─────────────────────────────────────────────
cat("Table 2: Main RDD results...\n")

main <- fread(file.path(tab_dir, "main_results.csv"))

sink(file.path(tab_dir, "tab2_main_results.tex"))
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{PMGSY Road Eligibility and Employment Outcomes: RDD Estimates}\n")
cat("\\label{tab:main}\n")
cat("\\small\n")
cat("\\begin{tabular}{l ccc cc}\n")
cat("\\toprule\n")
cat(" & RD & Robust SE & $p$-value & Bandwidth & $N_{\\text{eff}}$ \\\\\n")
cat("\\midrule\n")

for (i in 1:nrow(main)) {
  stars <- ifelse(main$pval_robust[i] < 0.01, "$^{***}$",
           ifelse(main$pval_robust[i] < 0.05, "$^{**}$",
           ifelse(main$pval_robust[i] < 0.10, "$^{*}$", "")))
  cat(sprintf("%s & %.4f%s & %.4f & %.3f & %.0f & %s \\\\\n",
              main$outcome[i],
              main$rd_robust[i], stars,
              main$se_robust[i],
              main$pval_robust[i],
              main$bw_main[i],
              format(main$n_eff_left[i] + main$n_eff_right[i], big.mark = ",")))
}

cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{minipage}{0.95\\textwidth}\n")
cat("\\vspace{0.3em}\n")
cat("\\footnotesize\n")
cat("\\textit{Notes:} Local polynomial RDD estimates using \\texttt{rdrobust} with triangular kernel and CCT optimal bandwidth selection. Standard errors clustered at the district level. Running variable is Census 2001 village population centered at 500 (PMGSY eligibility threshold for plains areas). Sample restricted to plains-area villages with population 1--5,000. $^{*}p<0.10$; $^{**}p<0.05$; $^{***}p<0.01$.\n")
cat("\\end{minipage}\n")
cat("\\end{table}\n")
sink()

# ── Table 3: Robustness — Bandwidth Sensitivity ───────────────────────────
cat("Table 3: Bandwidth robustness...\n")

bw <- fread(file.path(tab_dir, "robustness_bandwidth.csv"))

sink(file.path(tab_dir, "tab3_robustness.tex"))
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Robustness: Bandwidth Sensitivity for Female Non-Agricultural Worker Share}\n")
cat("\\label{tab:robustness_bw}\n")
cat("\\begin{tabular}{l cccc}\n")
cat("\\toprule\n")
cat("Bandwidth (\\% of Optimal) & RD Estimate & Robust SE & $p$-value & $N_{\\text{eff}}$ \\\\\n")
cat("\\midrule\n")
for (i in 1:nrow(bw)) {
  stars <- ifelse(bw$pval[i] < 0.01, "$^{***}$",
           ifelse(bw$pval[i] < 0.05, "$^{**}$",
           ifelse(bw$pval[i] < 0.10, "$^{*}$", "")))
  cat(sprintf("%.0f\\%% (h = %.0f) & %.4f%s & %.4f & %.3f & %s \\\\\n",
              bw$multiplier[i] * 100, bw$bandwidth[i],
              bw$rd_est[i], stars, bw$se[i], bw$pval[i],
              format(bw$n_eff[i], big.mark = ",")))
}
cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{minipage}{0.85\\textwidth}\n")
cat("\\vspace{0.3em}\n")
cat("\\footnotesize\n")
cat("\\textit{Notes:} Each row re-estimates the main RDD specification with a different bandwidth. Optimal bandwidth selected by CCT procedure.\n")
cat("\\end{minipage}\n")
cat("\\end{table}\n")
sink()

# ── Table 4: Covariate Balance ────────────────────────────────────────────
cat("Table 4: Covariate balance...\n")

balance <- fread(file.path(tab_dir, "balance_test.csv"))
balance$variable <- gsub("01$", "", balance$variable)

sink(file.path(tab_dir, "tab4_balance.tex"))
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Covariate Balance at the PMGSY Eligibility Threshold}\n")
cat("\\label{tab:balance}\n")
cat("\\begin{tabular}{l cccc}\n")
cat("\\toprule\n")
cat("Covariate (2001) & RD Estimate & Robust SE & $p$-value & Bandwidth \\\\\n")
cat("\\midrule\n")
for (i in 1:nrow(balance)) {
  stars <- ifelse(balance$pval[i] < 0.01, "$^{***}$",
           ifelse(balance$pval[i] < 0.05, "$^{**}$",
           ifelse(balance$pval[i] < 0.10, "$^{*}$", "")))
  vname <- gsub("_", " ", balance$variable[i])
  cat(sprintf("%s & %.4f%s & %.4f & %.3f & %.0f \\\\\n",
              vname, balance$rd_est[i], stars, balance$se[i],
              balance$pval[i], balance$bw[i]))
}
cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{minipage}{0.85\\textwidth}\n")
cat("\\vspace{0.3em}\n")
cat("\\footnotesize\n")
cat("\\textit{Notes:} Each row reports a separate RDD estimate using a Census 2001 pre-treatment covariate as the outcome. None should show a significant discontinuity if the RDD is valid.\n")
cat("\\end{minipage}\n")
cat("\\end{table}\n")
sink()

cat("\nAll tables saved to tables/\n")
