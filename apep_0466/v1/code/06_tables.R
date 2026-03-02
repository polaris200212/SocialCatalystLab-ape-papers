## ============================================================================
## 06_tables.R — All table generation
## APEP-0466: Municipal Population Thresholds and Firm Creation in France
## ============================================================================

source("00_packages.R")

data_dir <- "../data"
tab_dir <- "../tables"
dir.create(tab_dir, showWarnings = FALSE)

panel <- fread(file.path(data_dir, "analysis_panel.csv"))
commune_means <- fread(file.path(data_dir, "commune_means.csv"))
load(file.path(data_dir, "regression_models.RData"))

# ===========================================================================
# TABLE 1: SUMMARY STATISTICS
# ===========================================================================
cat("=== Table 1: Summary statistics ===\n")

# Overall statistics
stats <- commune_means[, .(
  N = .N,
  mean_pop = mean(population),
  sd_pop = sd(population),
  mean_area = mean(superficie_km2, na.rm = TRUE),
  mean_density = mean(densite, na.rm = TRUE),
  mean_creation_rate = mean(mean_creation_rate, na.rm = TRUE),
  sd_creation_rate = sd(mean_creation_rate, na.rm = TRUE),
  mean_council = mean(council_size, na.rm = TRUE),
  mean_salary = mean(mayor_salary, na.rm = TRUE)
)]

# Statistics by threshold proximity
thresh_stats <- list()
for (thresh in c(500, 1000, 1500, 3500, 10000)) {
  bw <- thresh * 0.3
  near <- commune_means[abs(population - thresh) <= bw]
  below <- near[population < thresh]
  above <- near[population >= thresh]

  thresh_stats[[as.character(thresh)]] <- data.table(
    threshold = thresh,
    n_communes = nrow(near),
    n_below = nrow(below),
    n_above = nrow(above),
    mean_pop_below = mean(below$population),
    mean_pop_above = mean(above$population),
    mean_rate_below = mean(below$mean_creation_rate, na.rm = TRUE),
    mean_rate_above = mean(above$mean_creation_rate, na.rm = TRUE),
    diff_rate = mean(above$mean_creation_rate, na.rm = TRUE) -
      mean(below$mean_creation_rate, na.rm = TRUE),
    council_below = mean(below$council_size, na.rm = TRUE),
    council_above = mean(above$council_size, na.rm = TRUE),
    salary_below = mean(below$mayor_salary, na.rm = TRUE),
    salary_above = mean(above$mayor_salary, na.rm = TRUE)
  )
}

tab1 <- rbindlist(thresh_stats)

# LaTeX output
cat("\\begin{table}[t]\n", file = file.path(tab_dir, "tab1_summary.tex"))
cat("\\centering\n", file = file.path(tab_dir, "tab1_summary.tex"), append = TRUE)
cat("\\caption{Summary Statistics by Population Threshold}\n", file = file.path(tab_dir, "tab1_summary.tex"), append = TRUE)
cat("\\label{tab:summary}\n", file = file.path(tab_dir, "tab1_summary.tex"), append = TRUE)
cat("\\begin{tabular}{lccccc}\n", file = file.path(tab_dir, "tab1_summary.tex"), append = TRUE)
cat("\\hline\\hline\n", file = file.path(tab_dir, "tab1_summary.tex"), append = TRUE)
cat(" & \\multicolumn{5}{c}{Population Threshold} \\\\\n", file = file.path(tab_dir, "tab1_summary.tex"), append = TRUE)
cat("\\cmidrule(lr){2-6}\n", file = file.path(tab_dir, "tab1_summary.tex"), append = TRUE)
cat(" & 500 & 1,000 & 1,500 & 3,500 & 10,000 \\\\\n", file = file.path(tab_dir, "tab1_summary.tex"), append = TRUE)
cat("\\hline\n", file = file.path(tab_dir, "tab1_summary.tex"), append = TRUE)

# Write rows
write_row <- function(label, vals, fmt = "%.1f") {
  vals_str <- paste(sprintf(fmt, vals), collapse = " & ")
  sprintf("%s & %s \\\\\n", label, vals_str)
}

cat(write_row("Communes in bandwidth", tab1$n_communes, "%.0f"),
    file = file.path(tab_dir, "tab1_summary.tex"), append = TRUE)
cat(write_row("\\quad Below threshold", tab1$n_below, "%.0f"),
    file = file.path(tab_dir, "tab1_summary.tex"), append = TRUE)
cat(write_row("\\quad Above threshold", tab1$n_above, "%.0f"),
    file = file.path(tab_dir, "tab1_summary.tex"), append = TRUE)
cat(write_row("Mean population (below)", tab1$mean_pop_below, "%.0f"),
    file = file.path(tab_dir, "tab1_summary.tex"), append = TRUE)
cat(write_row("Mean population (above)", tab1$mean_pop_above, "%.0f"),
    file = file.path(tab_dir, "tab1_summary.tex"), append = TRUE)
cat("\\hline\n", file = file.path(tab_dir, "tab1_summary.tex"), append = TRUE)
cat(write_row("Firm creation rate (below)", tab1$mean_rate_below),
    file = file.path(tab_dir, "tab1_summary.tex"), append = TRUE)
cat(write_row("Firm creation rate (above)", tab1$mean_rate_above),
    file = file.path(tab_dir, "tab1_summary.tex"), append = TRUE)
cat(write_row("Difference", tab1$diff_rate, "%.2f"),
    file = file.path(tab_dir, "tab1_summary.tex"), append = TRUE)
cat("\\hline\n", file = file.path(tab_dir, "tab1_summary.tex"), append = TRUE)
cat(write_row("Council size (below)", tab1$council_below),
    file = file.path(tab_dir, "tab1_summary.tex"), append = TRUE)
cat(write_row("Council size (above)", tab1$council_above),
    file = file.path(tab_dir, "tab1_summary.tex"), append = TRUE)
cat(write_row("Mayor salary (below)", tab1$salary_below, "%.0f"),
    file = file.path(tab_dir, "tab1_summary.tex"), append = TRUE)
cat(write_row("Mayor salary (above)", tab1$salary_above, "%.0f"),
    file = file.path(tab_dir, "tab1_summary.tex"), append = TRUE)
cat("\\hline\\hline\n", file = file.path(tab_dir, "tab1_summary.tex"), append = TRUE)
cat("\\end{tabular}\n", file = file.path(tab_dir, "tab1_summary.tex"), append = TRUE)
cat("\\begin{tablenotes}\\small\n", file = file.path(tab_dir, "tab1_summary.tex"), append = TRUE)
cat("\\item \\textit{Notes:} Bandwidth is $\\pm$30\\% of each threshold. Firm creation rate is annual new establishments per 1,000 inhabitants (average 2009--2024, excluding election years). Council size from Article L2121-2 CGCT; mayor salary from Article L2123-23 CGCT (2024 monthly maximum in euros). Source: INSEE Sirene, data.gouv.fr.\n",
    file = file.path(tab_dir, "tab1_summary.tex"), append = TRUE)
cat("\\end{tablenotes}\n", file = file.path(tab_dir, "tab1_summary.tex"), append = TRUE)
cat("\\end{table}\n", file = file.path(tab_dir, "tab1_summary.tex"), append = TRUE)

cat("  Table 1 saved\n")

# ===========================================================================
# TABLE 2: MAIN RDD RESULTS
# ===========================================================================
cat("=== Table 2: Main RDD results ===\n")

rdd_results <- tryCatch(fread(file.path(data_dir, "rdd_results.csv")), error = function(e) NULL)

if (!is.null(rdd_results)) {
  cat("\\begin{table}[t]\n", file = file.path(tab_dir, "tab2_rdd_main.tex"))
  cat("\\centering\n", file = file.path(tab_dir, "tab2_rdd_main.tex"), append = TRUE)
  cat("\\caption{RDD Estimates of Governance Effects on Firm Creation}\n",
      file = file.path(tab_dir, "tab2_rdd_main.tex"), append = TRUE)
  cat("\\label{tab:rdd_main}\n", file = file.path(tab_dir, "tab2_rdd_main.tex"), append = TRUE)

  # Determine number of columns
  n_cols <- nrow(rdd_results)
  col_spec <- paste0("l", paste(rep("c", n_cols), collapse = ""))
  cat(sprintf("\\begin{tabular}{%s}\n", col_spec),
      file = file.path(tab_dir, "tab2_rdd_main.tex"), append = TRUE)
  cat("\\hline\\hline\n", file = file.path(tab_dir, "tab2_rdd_main.tex"), append = TRUE)

  # Header row
  headers <- ifelse(rdd_results$threshold == 0, "Pooled",
                    formatC(rdd_results$threshold, big.mark = ","))
  cat(sprintf(" & %s \\\\\n", paste(headers, collapse = " & ")),
      file = file.path(tab_dir, "tab2_rdd_main.tex"), append = TRUE)
  cat("\\hline\n", file = file.path(tab_dir, "tab2_rdd_main.tex"), append = TRUE)

  # Estimates
  cat(sprintf("RDD estimate & %s \\\\\n",
              paste(sprintf("%.3f", rdd_results$estimate), collapse = " & ")),
      file = file.path(tab_dir, "tab2_rdd_main.tex"), append = TRUE)
  cat(sprintf(" & %s \\\\\n",
              paste(sprintf("(%.3f)", rdd_results$se_conv), collapse = " & ")),
      file = file.path(tab_dir, "tab2_rdd_main.tex"), append = TRUE)

  # P-values with stars
  stars <- ifelse(rdd_results$pvalue < 0.01, "***",
           ifelse(rdd_results$pvalue < 0.05, "**",
           ifelse(rdd_results$pvalue < 0.10, "*", "")))
  cat(sprintf("$p$-value & %s \\\\\n",
              paste(sprintf("[%.3f]%s", rdd_results$pvalue, stars), collapse = " & ")),
      file = file.path(tab_dir, "tab2_rdd_main.tex"), append = TRUE)

  cat("\\hline\n", file = file.path(tab_dir, "tab2_rdd_main.tex"), append = TRUE)
  # Format bandwidth: use integer for individual thresholds, decimal for pooled (normalized)
  bw_formatted <- sapply(seq_len(nrow(rdd_results)), function(i) {
    if (rdd_results$threshold[i] == 0) {
      sprintf("%.3f", rdd_results$bandwidth[i])  # Pooled uses normalized units
    } else {
      sprintf("%.0f", rdd_results$bandwidth[i])   # Individual use population units
    }
  })
  cat(sprintf("Bandwidth & %s \\\\\n",
              paste(bw_formatted, collapse = " & ")),
      file = file.path(tab_dir, "tab2_rdd_main.tex"), append = TRUE)
  cat(sprintf("Eff. $N$ (left) & %s \\\\\n",
              paste(rdd_results$n_left, collapse = " & ")),
      file = file.path(tab_dir, "tab2_rdd_main.tex"), append = TRUE)
  cat(sprintf("Eff. $N$ (right) & %s \\\\\n",
              paste(rdd_results$n_right, collapse = " & ")),
      file = file.path(tab_dir, "tab2_rdd_main.tex"), append = TRUE)

  cat("\\hline\\hline\n", file = file.path(tab_dir, "tab2_rdd_main.tex"), append = TRUE)
  cat("\\end{tabular}\n", file = file.path(tab_dir, "tab2_rdd_main.tex"), append = TRUE)
  cat("\\begin{tablenotes}\\small\n", file = file.path(tab_dir, "tab2_rdd_main.tex"), append = TRUE)
  cat("\\item \\textit{Notes:} Local linear RDD estimates using \\texttt{rdrobust} (Cattaneo, Idrobo, and Titiunik 2020). MSE-optimal bandwidth with triangular kernel. Dependent variable: annual firm creation rate per 1,000 inhabitants. Robust standard errors in parentheses; $p$-values in brackets. For individual thresholds, bandwidth is in population units. For the Pooled specification, the running variable is normalized to $[0, 1]$ across cutoffs following Cattaneo et al.\\ (2016), so the bandwidth is in normalized units. Eff.\\ $N$ reports the number of communes within the selected bandwidth on each side. $^{*}p<0.10$, $^{**}p<0.05$, $^{***}p<0.01$.\n",
      file = file.path(tab_dir, "tab2_rdd_main.tex"), append = TRUE)
  cat("\\end{tablenotes}\n", file = file.path(tab_dir, "tab2_rdd_main.tex"), append = TRUE)
  cat("\\end{table}\n", file = file.path(tab_dir, "tab2_rdd_main.tex"), append = TRUE)

  cat("  Table 2 saved\n")
}

# ===========================================================================
# TABLE 3: PARAMETRIC RDD AND DiDisc
# ===========================================================================
cat("=== Table 3: Parametric RDD and DiDisc ===\n")

etable(param_basic, param_quad, didisc,
       dict = c(above = "Above 3,500",
                dist = "Distance to 3,500",
                dist2 = "Distance$^2$",
                post_reform = "Post-2013",
                "above:post_reform" = "Above $\\times$ Post-2013",
                creation_rate = "Firm Creation Rate"),
       headers = list("Dep. var." = "Firm Creation Rate (per 1,000)"),
       tex = TRUE,
       file = file.path(tab_dir, "tab3_parametric.tex"),
       title = "Parametric RDD and Difference-in-Discontinuities at 3,500",
       label = "tab:parametric",
       notes = "Dependent variable: firm creation rate per 1,000 inhabitants. Columns (1)--(2): parametric RDD with linear and quadratic fits. Column (3): DiDisc interacting above-threshold indicator with post-2013 reform period. All models include d\\'epartement and year fixed effects. Standard errors clustered at d\\'epartement level in parentheses.",
       fitstat = c("n", "r2", "f"),
       style.tex = style.tex("aer"))

cat("  Table 3 saved\n")

# ===========================================================================
# TABLE 4: ROBUSTNESS SUMMARY
# ===========================================================================
cat("=== Table 4: Robustness summary ===\n")

mccrary <- tryCatch(fread(file.path(data_dir, "mccrary_tests.csv")), error = function(e) NULL)
balance <- tryCatch(fread(file.path(data_dir, "balance_tests.csv")), error = function(e) NULL)

if (!is.null(mccrary)) {
  cat("\\begin{table}[t]\n", file = file.path(tab_dir, "tab4_robustness.tex"))
  cat("\\centering\n", file = file.path(tab_dir, "tab4_robustness.tex"), append = TRUE)
  cat("\\caption{Robustness and Validity Checks}\n",
      file = file.path(tab_dir, "tab4_robustness.tex"), append = TRUE)
  cat("\\label{tab:robustness}\n", file = file.path(tab_dir, "tab4_robustness.tex"), append = TRUE)
  cat("\\begin{tabular}{lcccc}\n", file = file.path(tab_dir, "tab4_robustness.tex"), append = TRUE)
  cat("\\hline\\hline\n", file = file.path(tab_dir, "tab4_robustness.tex"), append = TRUE)

  # Panel A: McCrary
  cat("\\multicolumn{5}{l}{\\textit{Panel A: McCrary Density Tests}} \\\\\n",
      file = file.path(tab_dir, "tab4_robustness.tex"), append = TRUE)
  cat("Threshold & $T$-statistic & $p$-value & $N$ (left) & $N$ (right) \\\\\n",
      file = file.path(tab_dir, "tab4_robustness.tex"), append = TRUE)
  cat("\\hline\n", file = file.path(tab_dir, "tab4_robustness.tex"), append = TRUE)
  for (i in 1:nrow(mccrary)) {
    cat(sprintf("%s & %.3f & %.3f & %d & %d \\\\\n",
                formatC(mccrary$threshold[i], big.mark = ","),
                mccrary$t_stat[i], mccrary$p_value[i],
                mccrary$n_left[i], mccrary$n_right[i]),
        file = file.path(tab_dir, "tab4_robustness.tex"), append = TRUE)
  }

  cat("\\hline\\hline\n", file = file.path(tab_dir, "tab4_robustness.tex"), append = TRUE)
  cat("\\end{tabular}\n", file = file.path(tab_dir, "tab4_robustness.tex"), append = TRUE)
  cat("\\begin{tablenotes}\\small\n", file = file.path(tab_dir, "tab4_robustness.tex"), append = TRUE)
  cat("\\item \\textit{Notes:} Panel A: McCrary (2008) manipulation test using \\texttt{rddensity} (Cattaneo, Jansson, and Ma 2020). Null hypothesis: density is continuous at the threshold. Failure to reject supports the validity of the RDD.\n",
      file = file.path(tab_dir, "tab4_robustness.tex"), append = TRUE)
  cat("\\end{tablenotes}\n", file = file.path(tab_dir, "tab4_robustness.tex"), append = TRUE)
  cat("\\end{table}\n", file = file.path(tab_dir, "tab4_robustness.tex"), append = TRUE)

  cat("  Table 4 saved\n")
}

# ===========================================================================
# TABLE 5: DONUT-HOLE RDD ESTIMATES (Appendix)
# ===========================================================================
cat("=== Table 5: Donut-hole RDD ===\n")

donut <- tryCatch(fread(file.path(data_dir, "donut_tests.csv")), error = function(e) NULL)

if (!is.null(donut) && nrow(donut) > 0) {
  cat("\\begin{table}[t]\n", file = file.path(tab_dir, "tab5_donut.tex"))
  cat("\\centering\n", file = file.path(tab_dir, "tab5_donut.tex"), append = TRUE)
  cat("\\caption{Donut-Hole RDD Estimates (Excluding $\\pm$50 Inhabitants of Threshold)}\n",
      file = file.path(tab_dir, "tab5_donut.tex"), append = TRUE)
  cat("\\label{tab:donut}\n", file = file.path(tab_dir, "tab5_donut.tex"), append = TRUE)

  n_cols <- nrow(donut)
  col_spec <- paste0("l", paste(rep("c", n_cols), collapse = ""))
  cat(sprintf("\\begin{tabular}{%s}\n", col_spec),
      file = file.path(tab_dir, "tab5_donut.tex"), append = TRUE)
  cat("\\hline\\hline\n", file = file.path(tab_dir, "tab5_donut.tex"), append = TRUE)

  headers <- formatC(donut$threshold, big.mark = ",")
  cat(sprintf(" & %s \\\\\n", paste(headers, collapse = " & ")),
      file = file.path(tab_dir, "tab5_donut.tex"), append = TRUE)
  cat("\\hline\n", file = file.path(tab_dir, "tab5_donut.tex"), append = TRUE)

  cat(sprintf("Donut-hole estimate & %s \\\\\n",
              paste(sprintf("%.3f", donut$estimate), collapse = " & ")),
      file = file.path(tab_dir, "tab5_donut.tex"), append = TRUE)
  cat(sprintf(" & %s \\\\\n",
              paste(sprintf("(%.3f)", donut$se), collapse = " & ")),
      file = file.path(tab_dir, "tab5_donut.tex"), append = TRUE)

  donut_stars <- ifelse(donut$pvalue < 0.01, "***",
                 ifelse(donut$pvalue < 0.05, "**",
                 ifelse(donut$pvalue < 0.10, "*", "")))
  cat(sprintf("$p$-value & %s \\\\\n",
              paste(sprintf("[%.3f]%s", donut$pvalue, donut_stars), collapse = " & ")),
      file = file.path(tab_dir, "tab5_donut.tex"), append = TRUE)

  cat("\\hline\\hline\n", file = file.path(tab_dir, "tab5_donut.tex"), append = TRUE)
  cat("\\end{tabular}\n", file = file.path(tab_dir, "tab5_donut.tex"), append = TRUE)
  cat("\\begin{tablenotes}\\small\n", file = file.path(tab_dir, "tab5_donut.tex"), append = TRUE)
  cat("\\item \\textit{Notes:} Local linear RDD excluding communes within $\\pm$50 inhabitants of each threshold. MSE-optimal bandwidth with triangular kernel. Robust standard errors in parentheses; $p$-values in brackets. $^{*}p<0.10$, $^{**}p<0.05$, $^{***}p<0.01$.\n",
      file = file.path(tab_dir, "tab5_donut.tex"), append = TRUE)
  cat("\\end{tablenotes}\n", file = file.path(tab_dir, "tab5_donut.tex"), append = TRUE)
  cat("\\end{table}\n", file = file.path(tab_dir, "tab5_donut.tex"), append = TRUE)
  cat("  Table 5 saved\n")
}

# ===========================================================================
# TABLE 6: POLYNOMIAL ORDER SENSITIVITY (Appendix)
# ===========================================================================
cat("=== Table 6: Polynomial sensitivity ===\n")

poly <- tryCatch(fread(file.path(data_dir, "polynomial_sensitivity.csv")), error = function(e) NULL)

if (!is.null(poly) && nrow(poly) > 0) {
  cat("\\begin{table}[t]\n", file = file.path(tab_dir, "tab6_polynomial.tex"))
  cat("\\centering\n", file = file.path(tab_dir, "tab6_polynomial.tex"), append = TRUE)
  cat("\\caption{Polynomial Order Sensitivity at 3,500 Threshold}\n",
      file = file.path(tab_dir, "tab6_polynomial.tex"), append = TRUE)
  cat("\\label{tab:polynomial}\n", file = file.path(tab_dir, "tab6_polynomial.tex"), append = TRUE)
  cat("\\begin{tabular}{lccc}\n", file = file.path(tab_dir, "tab6_polynomial.tex"), append = TRUE)
  cat("\\hline\\hline\n", file = file.path(tab_dir, "tab6_polynomial.tex"), append = TRUE)
  cat(" & Linear ($p=1$) & Quadratic ($p=2$) & Cubic ($p=3$) \\\\\n",
      file = file.path(tab_dir, "tab6_polynomial.tex"), append = TRUE)
  cat("\\hline\n", file = file.path(tab_dir, "tab6_polynomial.tex"), append = TRUE)

  cat(sprintf("RDD estimate & %s \\\\\n",
              paste(sprintf("%.3f", poly$estimate), collapse = " & ")),
      file = file.path(tab_dir, "tab6_polynomial.tex"), append = TRUE)
  cat(sprintf(" & %s \\\\\n",
              paste(sprintf("(%.3f)", poly$se), collapse = " & ")),
      file = file.path(tab_dir, "tab6_polynomial.tex"), append = TRUE)

  poly_stars <- ifelse(poly$pvalue < 0.01, "***",
                ifelse(poly$pvalue < 0.05, "**",
                ifelse(poly$pvalue < 0.10, "*", "")))
  cat(sprintf("$p$-value & %s \\\\\n",
              paste(sprintf("[%.3f]%s", poly$pvalue, poly_stars), collapse = " & ")),
      file = file.path(tab_dir, "tab6_polynomial.tex"), append = TRUE)

  cat("\\hline\n", file = file.path(tab_dir, "tab6_polynomial.tex"), append = TRUE)
  cat(sprintf("Bandwidth & %s \\\\\n",
              paste(sprintf("%.0f", poly$bandwidth), collapse = " & ")),
      file = file.path(tab_dir, "tab6_polynomial.tex"), append = TRUE)

  cat("\\hline\\hline\n", file = file.path(tab_dir, "tab6_polynomial.tex"), append = TRUE)
  cat("\\end{tabular}\n", file = file.path(tab_dir, "tab6_polynomial.tex"), append = TRUE)
  cat("\\begin{tablenotes}\\small\n", file = file.path(tab_dir, "tab6_polynomial.tex"), append = TRUE)
  cat("\\item \\textit{Notes:} RDD estimates at the 3,500 threshold with varying polynomial orders. MSE-optimal bandwidth with triangular kernel (bandwidth varies with polynomial order). Robust standard errors in parentheses; $p$-values in brackets. $^{*}p<0.10$, $^{**}p<0.05$, $^{***}p<0.01$.\n",
      file = file.path(tab_dir, "tab6_polynomial.tex"), append = TRUE)
  cat("\\end{tablenotes}\n", file = file.path(tab_dir, "tab6_polynomial.tex"), append = TRUE)
  cat("\\end{table}\n", file = file.path(tab_dir, "tab6_polynomial.tex"), append = TRUE)
  cat("  Table 6 saved\n")
}

cat("\n=== All tables generated ===\n")
