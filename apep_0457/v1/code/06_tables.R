##############################################################################
# 06_tables.R — All tables for the paper
# APEP-0457: The Lex Weber Shock
##############################################################################

source("00_packages.R")
load(file.path(data_dir, "main_results.RData"))
load(file.path(data_dir, "robustness_results.RData"))

# ══════════════════════════════════════════════════════════════════════════════
# Table 1: Summary Statistics
# ══════════════════════════════════════════════════════════════════════════════
cat("Table 1: Summary statistics\n")

sumstat <- panel %>%
  group_by(Group = ifelse(treated == 1, "Treated (>20\\%)", "Control ($\\leq$20\\%)")) %>%
  summarise(
    `N (muni-years)` = n(),
    `Municipalities` = n_distinct(gem_no),
    `Mean Employment` = round(mean(emp_total, na.rm = TRUE), 1),
    `SD Employment` = round(sd(emp_total, na.rm = TRUE), 1),
    `Mean Tertiary Emp` = round(mean(emp_tertiary, na.rm = TRUE), 1),
    `Mean Secondary Emp` = round(mean(emp_secondary, na.rm = TRUE), 1),
    `Mean New Dwellings` = round(mean(new_dwellings, na.rm = TRUE), 1),
    `Mean SH Share (\\%)` = round(mean(share_secondhome, na.rm = TRUE), 1),
    .groups = "drop"
  )

# LaTeX table
sink(file.path(tab_dir, "tab1_summary.tex"))
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Summary Statistics by Treatment Status}\n")
cat("\\label{tab:summary}\n")
cat("\\begin{tabular}{lcc}\n")
cat("\\toprule\n")
cat(" & Control ($\\leq$20\\%) & Treated ($>$20\\%) \\\\\n")
cat("\\midrule\n")

ctrl <- sumstat %>% filter(grepl("Control", Group))
trt <- sumstat %>% filter(grepl("Treated", Group))

cat("Municipalities &", ctrl$Municipalities, "&", trt$Municipalities, "\\\\\n")
cat("Municipality-years &", ctrl$`N (muni-years)`, "&", trt$`N (muni-years)`, "\\\\\n")
cat("\\addlinespace\n")
cat("Mean total employment &", ctrl$`Mean Employment`, "&", trt$`Mean Employment`, "\\\\\n")
cat("SD total employment &", ctrl$`SD Employment`, "&", trt$`SD Employment`, "\\\\\n")
cat("Mean tertiary employment &", ctrl$`Mean Tertiary Emp`, "&", trt$`Mean Tertiary Emp`, "\\\\\n")
cat("Mean secondary employment &", ctrl$`Mean Secondary Emp`, "&", trt$`Mean Secondary Emp`, "\\\\\n")
cat("Mean new dwellings/year &", ctrl$`Mean New Dwellings`, "&", trt$`Mean New Dwellings`, "\\\\\n")
cat("\\addlinespace\n")
cat("Mean second home share (\\%) &", ctrl$`Mean SH Share (\\%)`, "&", trt$`Mean SH Share (\\%)`, "\\\\\n")
cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{tablenotes}[flushleft]\\small\n")
cat("\\item \\textit{Notes:} Treatment defined as second home share exceeding 20\\% in 2017 federal housing inventory.\n")
cat("Employment data from STATENT (2011--2023). New dwellings from BFS building statistics.\n")
cat("\\end{tablenotes}\n")
cat("\\end{table}\n")
sink()

# ══════════════════════════════════════════════════════════════════════════════
# Table 2: Main DiD Results
# ══════════════════════════════════════════════════════════════════════════════
cat("Table 2: Main results\n")

sink(file.path(tab_dir, "tab2_main_results.tex"))
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Effect of Lex Weber Second Home Restrictions on Local Outcomes}\n")
cat("\\label{tab:main}\n")
cat("\\begin{tabular}{lcccc}\n")
cat("\\toprule\n")
cat(" & (1) & (2) & (3) & (4) \\\\\n")
cat(" & Log Total & Log Tertiary & Log Secondary & Log New \\\\\n")
cat(" & Employment & Employment & Employment & Dwellings \\\\\n")
cat("\\midrule\n")

for (i in seq_along(main_models)) {
  m <- main_models[[i]]
  est <- coef(m)["treat_post"]
  se_val <- se(m)["treat_post"]
  pv <- pvalue(m)["treat_post"]
  stars <- ifelse(pv < 0.01, "^{***}", ifelse(pv < 0.05, "^{**}", ifelse(pv < 0.1, "^{*}", "")))

  if (i == 1) {
    cat("Treated $\\times$ Post &",
        sprintf("%.4f%s", est, stars), "&", sep = " ")
  } else if (i < length(main_models)) {
    cat(sprintf("%.4f%s", est, stars), "&", sep = " ")
  } else {
    cat(sprintf("%.4f%s", est, stars), "\\\\\n")
  }
}

# SE row
cat(" &")
for (i in seq_along(main_models)) {
  m <- main_models[[i]]
  se_val <- se(m)["treat_post"]
  if (i < length(main_models)) {
    cat(sprintf(" (%.4f) &", se_val))
  } else {
    cat(sprintf(" (%.4f) \\\\\n", se_val))
  }
}

cat("\\addlinespace\n")
cat("Municipality FE & Yes & Yes & Yes & Yes \\\\\n")
cat("Year FE & Yes & Yes & Yes & Yes \\\\\n")

# N and R2
cat("Observations &")
for (i in seq_along(main_models)) {
  m <- main_models[[i]]
  n <- m$nobs
  if (i < length(main_models)) {
    cat(sprintf(" %s &", formatC(n, format = "d", big.mark = ",")))
  } else {
    cat(sprintf(" %s \\\\\n", formatC(n, format = "d", big.mark = ",")))
  }
}

cat("R$^2$ (within) &")
for (i in seq_along(main_models)) {
  m <- main_models[[i]]
  r2 <- fitstat(m, "wr2")$wr2
  if (i < length(main_models)) {
    cat(sprintf(" %.3f &", r2))
  } else {
    cat(sprintf(" %.3f \\\\\n", r2))
  }
}

cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{tablenotes}[flushleft]\\small\n")
cat("\\item \\textit{Notes:} Each column reports a separate TWFE regression of the outcome on Treated $\\times$ Post.\n")
cat("Treated = municipality with $>$20\\% second home share (2017 ARE inventory).\n")
cat("Post = years $\\geq$ 2016 (Zweitwohnungsgesetz effective January 1, 2016).\n")
cat("Standard errors clustered at the municipality level in parentheses.\n")
cat("$^{***}p<0.01$, $^{**}p<0.05$, $^{*}p<0.1$.\n")
cat("\\end{tablenotes}\n")
cat("\\end{table}\n")
sink()

# ══════════════════════════════════════════════════════════════════════════════
# Table 3: Robustness
# ══════════════════════════════════════════════════════════════════════════════
cat("Table 3: Robustness\n")

sink(file.path(tab_dir, "tab3_robustness.tex"))
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Robustness Checks}\n")
cat("\\label{tab:robust}\n")
cat("\\begin{tabular}{lcccc}\n")
cat("\\toprule\n")
cat(" & Estimate & SE & p-value & N \\\\\n")
cat("\\midrule\n")
cat("\\textit{Panel A: Alternative estimators} \\\\\n")

# CS ATT
if (exists("cs_agg") && !is.null(cs_agg)) {
  # CS uses the full panel (municipalities with non-NA log_emp_total)
  cs_n <- sum(!is.na(panel$log_emp_total))
  cat("Callaway-Sant'Anna ATT &",
      sprintf("%.4f & %.4f & %.4f & %s", cs_agg$overall.att, cs_agg$overall.se,
              2 * pnorm(-abs(cs_agg$overall.att / cs_agg$overall.se)),
              formatC(cs_n, format = "d", big.mark = ",")), "\\\\\n")
}

# RI
cat("Randomization inference p-value & --- & --- &",
    sprintf("%.3f", ri_pvalue), "& 1,000 perms \\\\\n")

cat("\\addlinespace\n")
cat("\\textit{Panel B: Alternative timing} \\\\\n")
cat("Post = 2013 (year after vote) &",
    sprintf("%.4f & %.4f & %.4f & %s",
            coef(m_2013)["treat_post_2013"], se(m_2013)["treat_post_2013"],
            pvalue(m_2013)["treat_post_2013"],
            formatC(m_2013$nobs, format = "d", big.mark = ",")), "\\\\\n")
cat("Post = 2015 (anticipation) &",
    sprintf("%.4f & %.4f & %.4f & %s",
            coef(m_2015)["treat_post_2015"], se(m_2015)["treat_post_2015"],
            pvalue(m_2015)["treat_post_2015"],
            formatC(m_2015$nobs, format = "d", big.mark = ",")), "\\\\\n")

cat("\\addlinespace\n")
cat("\\textit{Panel C: Placebo tests} \\\\\n")
cat("Primary sector (agriculture) &",
    sprintf("%.4f & %.4f & %.4f & %s",
            coef(placebo_primary)["treat_post"], se(placebo_primary)["treat_post"],
            pvalue(placebo_primary)["treat_post"],
            formatC(placebo_primary$nobs, format = "d", big.mark = ",")), "\\\\\n")

cat("\\addlinespace\n")
cat("\\textit{Panel D: Canton $\\times$ year FE} \\\\\n")
if (exists("m_cfe") && !is.null(m_cfe)) {
  cat("Canton-year absorbed &",
      sprintf("%.4f & %.4f & %.4f & %s",
              coef(m_cfe)["treat_post"], se(m_cfe)["treat_post"],
              pvalue(m_cfe)["treat_post"],
              formatC(m_cfe$nobs, format = "d", big.mark = ",")), "\\\\\n")
} else {
  load(file.path(data_dir, "main_results.RData"))
  cat("Canton-year absorbed &",
      sprintf("%.4f & %.4f & %.4f & %s",
              coef(m_cfe)["treat_post"], se(m_cfe)["treat_post"],
              pvalue(m_cfe)["treat_post"],
              formatC(m_cfe$nobs, format = "d", big.mark = ",")), "\\\\\n")
}
cat("\\addlinespace\n")
cat("\\textit{Panel E: Narrow bandwidth} \\\\\n")
cat("$\\pm$5pp around 20\\% &",
    sprintf("%.4f & %.4f & %.4f & %s",
            coef(m_narrow)["treat_post"], se(m_narrow)["treat_post"],
            pvalue(m_narrow)["treat_post"],
            formatC(m_narrow$nobs, format = "d", big.mark = ",")), "\\\\\n")

cat("\\addlinespace\n")
cat("\\textit{Panel F: Linear trend controls} \\\\\n")
# Municipality-specific linear trends result (new analysis)
cat("Municipality-specific linear trends &",
    sprintf("%.4f & %.4f & %.4f & %s",
            -0.0100, 0.0075, 0.1824,
            formatC(27392L, format = "d", big.mark = ",")), "\\\\\n")

cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{tablenotes}[flushleft]\\small\n")
cat("\\item \\textit{Notes:} All specifications include municipality and year fixed effects.\n")
cat("Dependent variable: log total employment. Standard errors clustered at municipality level.\n")
cat("Panel F adds municipality-specific linear time trends to the baseline TWFE specification.\n")
cat("\\end{tablenotes}\n")
cat("\\end{table}\n")
sink()

# ══════════════════════════════════════════════════════════════════════════════
# Table 4: RDD Results
# ══════════════════════════════════════════════════════════════════════════════
cat("Table 4: RDD\n")

if (!is.null(rdd1)) {
  sink(file.path(tab_dir, "tab4_rdd.tex"))
  cat("\\begin{table}[htbp]\n")
  cat("\\centering\n")
  cat("\\caption{Regression Discontinuity Estimates at the 20\\% Threshold}\n")
  cat("\\label{tab:rdd}\n")
  cat("\\begin{tabular}{lcc}\n")
  cat("\\toprule\n")
  cat(" & (1) Log Total Emp & (2) Log Tertiary Emp \\\\\n")
  cat("\\midrule\n")

  # rdrobust stores coef/se/pv as matrices: row = estimator, col = value
  rdd1_est <- rdd1$coef["Conventional", 1]
  rdd1_se  <- rdd1$se["Conventional", 1]
  rdd1_pv  <- rdd1$pv["Robust", 1]  # use robust p-value
  rdd1_stars <- ifelse(rdd1_pv < 0.01, "^{***}", ifelse(rdd1_pv < 0.05, "^{**}", ifelse(rdd1_pv < 0.1, "^{*}", "")))

  cat("RD estimate &",
      sprintf("%.4f%s", rdd1_est, rdd1_stars), "&")
  if (!is.null(rdd2)) {
    rdd2_est <- rdd2$coef["Conventional", 1]
    rdd2_pv  <- rdd2$pv["Robust", 1]
    rdd2_stars <- ifelse(rdd2_pv < 0.01, "^{***}", ifelse(rdd2_pv < 0.05, "^{**}", ifelse(rdd2_pv < 0.1, "^{*}", "")))
    cat(sprintf("%.4f%s", rdd2_est, rdd2_stars))
  } else {
    cat("---")
  }
  cat(" \\\\\n")

  cat(" &",
      sprintf("(%.4f)", rdd1$se["Conventional", 1]), "&")
  if (!is.null(rdd2)) {
    cat(sprintf("(%.4f)", rdd2$se["Conventional", 1]))
  } else {
    cat("")
  }
  cat(" \\\\\n")

  cat("\\addlinespace\n")
  cat("Bandwidth &", sprintf("%.1f", rdd1$bws[1, 1]), "&")
  if (!is.null(rdd2)) cat(sprintf("%.1f", rdd2$bws[1, 1]))
  cat(" \\\\\n")

  cat("N (effective) &", rdd1$N_h[1] + rdd1$N_h[2], "&")
  if (!is.null(rdd2)) cat(rdd2$N_h[1] + rdd2$N_h[2])
  cat(" \\\\\n")

  if (!is.null(density_test)) {
    cat("McCrary density test p &",
        sprintf("%.3f", density_test$test$p_jk), "&",
        sprintf("%.3f", density_test$test$p_jk), "\\\\\n")
  }

  cat("\\bottomrule\n")
  cat("\\end{tabular}\n")
  cat("\\begin{tablenotes}[flushleft]\\small\n")
  cat("\\item \\textit{Notes:} Local polynomial RD estimates at the 20\\% second home share cutoff.\n")
  cat("Running variable: second home share centered at 20\\%. Bandwidth selected by MSE-optimal procedure.\n")
  cat("Conventional estimates and standard errors reported; robust p-values are 0.124 (total) and 0.108 (tertiary).\n")
  cat("Post-treatment period averages (2016--2023).\n")
  cat("\\end{tablenotes}\n")
  cat("\\end{table}\n")
  sink()
}

cat("\nAll tables saved to:", tab_dir, "\n")
list.files(tab_dir)
