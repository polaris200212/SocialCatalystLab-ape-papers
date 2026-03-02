## 06_tables.R — All tables for the paper
## APEP-0281: Mandatory Energy Disclosure and Property Values (RDD)

source("00_packages.R")

pluto <- readRDS(file.path(data_dir, "pluto_analysis.rds"))
rdd_narrow <- readRDS(file.path(data_dir, "rdd_narrow.rds"))
results <- readRDS(file.path(data_dir, "main_results.rds"))
robustness <- readRDS(file.path(data_dir, "robustness_results.rds"))

# ============================================================
# Table 1: Summary Statistics
# ============================================================
cat("Creating Table 1: Summary statistics...\n")

# Summary stats for narrow sample, by threshold status
sum_stats <- rdd_narrow %>%
  group_by(above_threshold) %>%
  summarise(
    N = n(),
    `Mean GFA` = mean(gfa, na.rm = TRUE),
    `Mean Assessed Value ($)` = mean(assesstot, na.rm = TRUE),
    `Mean Value per Sq Ft ($)` = mean(assesstot / gfa, na.rm = TRUE),
    `Mean Year Built` = mean(yearbuilt, na.rm = TRUE),
    `Mean Floors` = mean(numfloors, na.rm = TRUE),
    `Pct Residential` = mean(landuse_cat == "Residential", na.rm = TRUE) * 100,
    `Pct Commercial` = mean(landuse_cat == "Commercial", na.rm = TRUE) * 100,
    `Pct LL84 Compliance` = mean(has_ll84, na.rm = TRUE) * 100,
    .groups = "drop"
  ) %>%
  mutate(above_threshold = ifelse(above_threshold, "Above 25K", "Below 25K"))

# LaTeX table
tab1_tex <- "\\begin{table}[htbp]\n\\centering\n\\caption{Summary Statistics by LL84 Threshold Status}\n\\label{tab:summary}\n\\small\n\\begin{tabular}{lrr}\n\\hline\\hline\n"
tab1_tex <- paste0(tab1_tex, " & Below 25K sq ft & Above 25K sq ft \\\\\n\\hline\n")

below <- sum_stats %>% filter(above_threshold == "Below 25K")
above <- sum_stats %>% filter(above_threshold == "Above 25K")

stats_rows <- list(
  c("N (buildings)", format(below$N, big.mark = ","), format(above$N, big.mark = ",")),
  c("Mean GFA (sq ft)", format(round(below$`Mean GFA`), big.mark = ","), format(round(above$`Mean GFA`), big.mark = ",")),
  c("Mean Assessed Value (\\$)", format(round(below$`Mean Assessed Value ($)`), big.mark = ","), format(round(above$`Mean Assessed Value ($)`), big.mark = ",")),
  c("Mean Value per Sq Ft (\\$/sqft)", format(round(below$`Mean Value per Sq Ft ($)`, 1)), format(round(above$`Mean Value per Sq Ft ($)`, 1))),
  c("Mean Year Built", round(below$`Mean Year Built`), round(above$`Mean Year Built`)),
  c("Mean Floors", round(below$`Mean Floors`, 1), round(above$`Mean Floors`, 1)),
  c("Pct Residential (\\%)", round(below$`Pct Residential`, 1), round(above$`Pct Residential`, 1)),
  c("Pct Commercial (\\%)", round(below$`Pct Commercial`, 1), round(above$`Pct Commercial`, 1)),
  c("Pct LL84 Compliance (\\%)", round(below$`Pct LL84 Compliance`, 1), round(above$`Pct LL84 Compliance`, 1))
)

for (r in stats_rows) {
  tab1_tex <- paste0(tab1_tex, r[1], " & ", r[2], " & ", r[3], " \\\\\n")
}

tab1_tex <- paste0(tab1_tex, "\\hline\\hline\n\\end{tabular}\n")
tab1_tex <- paste0(tab1_tex, "\\begin{minipage}{0.9\\textwidth}\n\\vspace{0.3em}\n")
tab1_tex <- paste0(tab1_tex, "\\footnotesize \\textit{Notes:} Sample restricted to buildings with gross floor area between 15,000 and 35,000 sq ft (narrow bandwidth). ``Above 25K'' buildings are subject to NYC Local Law 84 mandatory energy benchmarking disclosure. LL84 compliance is measured as having at least one filing in the NYC benchmarking dataset.\n")
tab1_tex <- paste0(tab1_tex, "\\end{minipage}\n\\end{table}\n")

writeLines(tab1_tex, file.path(tab_dir, "tab1_summary.tex"))

# ============================================================
# Table 2: Main RDD Results
# ============================================================
cat("Creating Table 2: Main RDD results...\n")

# Collect specifications
specs <- list()

# (1) Local linear, MSE-optimal
rd1 <- results$rd_assess
specs[[1]] <- c(
  round(rd1$coef[1], 4), paste0("(", round(rd1$se[3], 4), ")"),
  round(rd1$pv[3], 3), round(rd1$bws[1, 1]),
  rd1$N_h[1] + rd1$N_h[2], "Linear", "Triangular", "MSE-Optimal"
)

# (2) Local quadratic
rd2 <- results$rd_assess_q
specs[[2]] <- c(
  round(rd2$coef[1], 4), paste0("(", round(rd2$se[3], 4), ")"),
  round(rd2$pv[3], 3), round(rd2$bws[1, 1]),
  rd2$N_h[1] + rd2$N_h[2], "Quadratic", "Triangular", "MSE-Optimal"
)

# (3) Value per sq ft
rd3 <- results$rd_assess_sqft
specs[[3]] <- c(
  round(rd3$coef[1], 4), paste0("(", round(rd3$se[3], 4), ")"),
  round(rd3$pv[3], 3), round(rd3$bws[1, 1]),
  rd3$N_h[1] + rd3$N_h[2], "Linear", "Triangular", "MSE-Optimal"
)

# (4) Parametric linear with borough FE
pl <- results$param_linear
specs[[4]] <- c(
  round(coef(pl)["above_threshold"], 4),
  paste0("(", round(se(pl)["above_threshold"], 4), ")"),
  round(pvalue(pl)["above_threshold"], 3),
  "Full", nobs(pl), "Linear (param.)", "---", "Full Sample"
)

tab2_tex <- "\\begin{table}[htbp]\n\\centering\n\\caption{Main RDD Results: Effect of LL84 Disclosure on Property Values}\n\\label{tab:main_results}\n\\small\n\\begin{tabular}{lcccc}\n\\hline\\hline\n"
tab2_tex <- paste0(tab2_tex, " & (1) & (2) & (3) & (4) \\\\\n")
tab2_tex <- paste0(tab2_tex, " & Log Assessed & Log Assessed & Log Value & Log Assessed \\\\\n")
tab2_tex <- paste0(tab2_tex, " & Value & Value & per Sq Ft & Value \\\\\n\\hline\n")

tab2_tex <- paste0(tab2_tex, "LL84 Disclosure & ", specs[[1]][1], " & ", specs[[2]][1], " & ", specs[[3]][1], " & ", specs[[4]][1], " \\\\\n")
tab2_tex <- paste0(tab2_tex, " & ", specs[[1]][2], " & ", specs[[2]][2], " & ", specs[[3]][2], " & ", specs[[4]][2], " \\\\\n")
tab2_tex <- paste0(tab2_tex, "\\hline\n")
tab2_tex <- paste0(tab2_tex, "Polynomial & ", specs[[1]][6], " & ", specs[[2]][6], " & ", specs[[3]][6], " & ", specs[[4]][6], " \\\\\n")
tab2_tex <- paste0(tab2_tex, "Kernel & ", specs[[1]][7], " & ", specs[[2]][7], " & ", specs[[3]][7], " & ", specs[[4]][7], " \\\\\n")
tab2_tex <- paste0(tab2_tex, "Bandwidth & ", specs[[1]][8], " & ", specs[[2]][8], " & ", specs[[3]][8], " & ", specs[[4]][8], " \\\\\n")
tab2_tex <- paste0(tab2_tex, "Eff. $N$ & ", format(as.numeric(specs[[1]][5]), big.mark = ","), " & ", format(as.numeric(specs[[2]][5]), big.mark = ","), " & ", format(as.numeric(specs[[3]][5]), big.mark = ","), " & ", format(as.numeric(specs[[4]][5]), big.mark = ","), " \\\\\n")
tab2_tex <- paste0(tab2_tex, "$p$-value & ", specs[[1]][3], " & ", specs[[2]][3], " & ", specs[[3]][3], " & ", specs[[4]][3], " \\\\\n")
tab2_tex <- paste0(tab2_tex, "\\hline\\hline\n\\end{tabular}\n")
tab2_tex <- paste0(tab2_tex, "\\begin{minipage}{0.95\\textwidth}\n\\vspace{0.3em}\n")
tab2_tex <- paste0(tab2_tex, "\\footnotesize \\textit{Notes:} Columns (1)--(3) report local polynomial RDD estimates using \\texttt{rdrobust} (Cattaneo, Idrobo, and Titiunik 2020). Standard errors in parentheses are bias-corrected robust. Column (4) reports a parametric OLS estimate with borough fixed effects. The outcome in columns (1), (2), and (4) is log assessed total value; column (3) uses log assessed value per square foot. The running variable is building gross floor area with a cutoff at 25,000 sq ft. MSE-optimal bandwidths are selected using the procedure in Cattaneo and Vazquez-Bare (2020).\n")
tab2_tex <- paste0(tab2_tex, "\\end{minipage}\n\\end{table}\n")

writeLines(tab2_tex, file.path(tab_dir, "tab2_main_results.tex"))

# ============================================================
# Table 3: Robustness — Bandwidth and Specification
# ============================================================
cat("Creating Table 3: Robustness...\n")

bw_df <- bind_rows(lapply(robustness$bandwidth, as.data.frame))
poly_df <- bind_rows(lapply(robustness$polynomial, as.data.frame))
kern_df <- bind_rows(lapply(robustness$kernel, as.data.frame))
donut_df <- bind_rows(lapply(robustness$donut, as.data.frame))

tab3_tex <- "\\begin{table}[htbp]\n\\centering\n\\caption{Robustness of Main RDD Estimate}\n\\label{tab:robustness}\n\\small\n\\begin{tabular}{llccc}\n\\hline\\hline\n"
tab3_tex <- paste0(tab3_tex, "Specification & Detail & Estimate & Robust SE & $p$-value \\\\\n\\hline\n")

# Panel A: Bandwidth
tab3_tex <- paste0(tab3_tex, "\\multicolumn{5}{l}{\\textit{Panel A: Bandwidth Sensitivity}} \\\\\n")
for (i in seq_len(nrow(bw_df))) {
  tab3_tex <- paste0(tab3_tex, sprintf("  & %d\\%% of optimal (h = %s) & %.4f & %.4f & %.3f \\\\\n",
                                        bw_df$multiplier[i] * 100,
                                        format(round(bw_df$bandwidth[i]), big.mark = ","),
                                        bw_df$estimate[i], bw_df$se[i], bw_df$pvalue[i]))
}

# Panel B: Polynomial
tab3_tex <- paste0(tab3_tex, "\\multicolumn{5}{l}{\\textit{Panel B: Polynomial Order}} \\\\\n")
for (i in seq_len(nrow(poly_df))) {
  tab3_tex <- paste0(tab3_tex, sprintf("  & Order %d & %.4f & %.4f & %.3f \\\\\n",
                                        poly_df$order[i], poly_df$estimate[i],
                                        poly_df$se[i], poly_df$pvalue[i]))
}

# Panel C: Kernel
tab3_tex <- paste0(tab3_tex, "\\multicolumn{5}{l}{\\textit{Panel C: Kernel Function}} \\\\\n")
for (i in seq_len(nrow(kern_df))) {
  tab3_tex <- paste0(tab3_tex, sprintf("  & %s & %.4f & %.4f & %.3f \\\\\n",
                                        tools::toTitleCase(kern_df$kernel[i]),
                                        kern_df$estimate[i], kern_df$se[i], kern_df$pvalue[i]))
}

# Panel D: Donut
tab3_tex <- paste0(tab3_tex, "\\multicolumn{5}{l}{\\textit{Panel D: Donut RDD}} \\\\\n")
for (i in seq_len(nrow(donut_df))) {
  tab3_tex <- paste0(tab3_tex, sprintf("  & Exclude $\\pm$ %s sq ft & %.4f & %.4f & %.3f \\\\\n",
                                        format(donut_df$donut_width[i], big.mark = ","),
                                        donut_df$estimate[i], donut_df$se[i], donut_df$pvalue[i]))
}

tab3_tex <- paste0(tab3_tex, "\\hline\\hline\n\\end{tabular}\n")
tab3_tex <- paste0(tab3_tex, "\\begin{minipage}{0.95\\textwidth}\n\\vspace{0.3em}\n")
tab3_tex <- paste0(tab3_tex, "\\footnotesize \\textit{Notes:} All specifications estimate the discontinuity in log assessed total value at the 25,000 sq ft LL84 threshold using \\texttt{rdrobust}. Panel A varies the bandwidth around the MSE-optimal choice. Panel B varies the polynomial order. Panel C varies the kernel function. Panel D excludes observations within the specified distance of the cutoff. Robust bias-corrected standard errors reported.\n")
tab3_tex <- paste0(tab3_tex, "\\end{minipage}\n\\end{table}\n")

writeLines(tab3_tex, file.path(tab_dir, "tab3_robustness.tex"))

# ============================================================
# Table 4: Placebo Cutoffs
# ============================================================
cat("Creating Table 4: Placebo cutoffs...\n")

placebo_df <- bind_rows(lapply(robustness$placebo, as.data.frame))

# Add real estimate
real <- results$main_assess
placebo_all <- bind_rows(
  placebo_df,
  tibble(cutoff = 25000, estimate = real$estimate, se = real$se_robust,
         pvalue = real$pv_robust)
) %>%
  arrange(cutoff) %>%
  mutate(is_real = cutoff == 25000)

tab4_tex <- "\\begin{table}[htbp]\n\\centering\n\\caption{Placebo Cutoff Tests}\n\\label{tab:placebo}\n\\small\n\\begin{tabular}{lccc}\n\\hline\\hline\n"
tab4_tex <- paste0(tab4_tex, "Cutoff (sq ft) & Estimate & Robust SE & $p$-value \\\\\n\\hline\n")

for (i in seq_len(nrow(placebo_all))) {
  prefix <- if (placebo_all$is_real[i]) "\\textbf{" else ""
  suffix <- if (placebo_all$is_real[i]) "}" else ""
  note <- if (placebo_all$is_real[i]) " (True)" else ""
  tab4_tex <- paste0(tab4_tex, sprintf("%s%s%s%s & %s%.4f%s & %s%.4f%s & %s%.3f%s \\\\\n",
                                        prefix, format(placebo_all$cutoff[i], big.mark = ","),
                                        note, suffix,
                                        prefix, placebo_all$estimate[i], suffix,
                                        prefix, placebo_all$se[i], suffix,
                                        prefix, placebo_all$pvalue[i], suffix))
}

tab4_tex <- paste0(tab4_tex, "\\hline\\hline\n\\end{tabular}\n")
tab4_tex <- paste0(tab4_tex, "\\begin{minipage}{0.8\\textwidth}\n\\vspace{0.3em}\n")
tab4_tex <- paste0(tab4_tex, "\\footnotesize \\textit{Notes:} Each row reports the RDD estimate at an alternative cutoff. Bold row is the true LL84 threshold at 25,000 sq ft. Only the true threshold should show a significant discontinuity.\n")
tab4_tex <- paste0(tab4_tex, "\\end{minipage}\n\\end{table}\n")

writeLines(tab4_tex, file.path(tab_dir, "tab4_placebo.tex"))

# ============================================================
# Table 5: Heterogeneity
# ============================================================
cat("Creating Table 5: Heterogeneity...\n")

het_dfs <- list()
if (length(robustness$het_type) > 0)
  het_dfs[["type"]] <- bind_rows(lapply(robustness$het_type, as.data.frame)) %>%
    mutate(category = "Building Type", subgroup = type)
if (length(robustness$het_borough) > 0)
  het_dfs[["boro"]] <- bind_rows(lapply(robustness$het_borough, as.data.frame)) %>%
    mutate(category = "Borough", subgroup = borough)
if (length(robustness$het_age) > 0)
  het_dfs[["age"]] <- bind_rows(lapply(robustness$het_age, as.data.frame)) %>%
    mutate(category = "Construction Era", subgroup = cohort)

if (length(het_dfs) > 0) {
  het_all <- bind_rows(het_dfs)

  tab5_tex <- "\\begin{table}[htbp]\n\\centering\n\\caption{Heterogeneous Treatment Effects}\n\\label{tab:heterogeneity}\n\\small\n\\begin{tabular}{llcccc}\n\\hline\\hline\n"
  tab5_tex <- paste0(tab5_tex, "Category & Subgroup & $N$ & Estimate & Robust SE & $p$-value \\\\\n\\hline\n")

  for (cat in unique(het_all$category)) {
    tab5_tex <- paste0(tab5_tex, "\\multicolumn{6}{l}{\\textit{", cat, "}} \\\\\n")
    sub <- het_all %>% filter(category == cat)
    for (j in seq_len(nrow(sub))) {
      tab5_tex <- paste0(tab5_tex, sprintf("  & %s & %s & %.4f & %.4f & %.3f \\\\\n",
                                            sub$subgroup[j],
                                            format(sub$n[j], big.mark = ","),
                                            sub$estimate[j], sub$se[j], sub$pvalue[j]))
    }
  }

  tab5_tex <- paste0(tab5_tex, "\\hline\\hline\n\\end{tabular}\n")
  tab5_tex <- paste0(tab5_tex, "\\begin{minipage}{0.9\\textwidth}\n\\vspace{0.3em}\n")
  tab5_tex <- paste0(tab5_tex, "\\footnotesize \\textit{Notes:} Each row estimates the LL84 disclosure RDD separately for the indicated subgroup. Estimates use \\texttt{rdrobust} with MSE-optimal bandwidth and triangular kernel. Robust bias-corrected standard errors.\n")
  tab5_tex <- paste0(tab5_tex, "\\end{minipage}\n\\end{table}\n")

  writeLines(tab5_tex, file.path(tab_dir, "tab5_heterogeneity.tex"))
}

cat("\nAll tables saved to:", tab_dir, "\n")
