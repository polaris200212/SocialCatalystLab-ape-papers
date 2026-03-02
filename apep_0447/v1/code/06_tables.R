## ============================================================================
## 06_tables.R — LaTeX tables for paper
## ============================================================================

source("00_packages.R")

DATA <- "../data"
TABLES <- "../tables"
dir.create(TABLES, showWarnings = FALSE)

panel <- readRDS(file.path(DATA, "panel_analysis.rds"))
results <- readRDS(file.path(DATA, "main_results.rds"))
robustness <- readRDS(file.path(DATA, "robustness_results.rds"))
state_treatment <- readRDS(file.path(DATA, "state_treatment.rds"))

## ---- Table 1: Summary Statistics ----
cat("Table 1: Summary statistics...\n")

# Panel A: By service type, pre-period
pre <- panel[month_date < as.Date("2020-03-01")]
post <- panel[month_date >= as.Date("2020-04-01")]

make_sumstat_row <- function(dt, varname, label) {
  hcbs <- dt[service_type == "HCBS"]
  bh <- dt[service_type == "BH"]
  sprintf("%s & %.1f & %.1f & %.1f & %.1f & %.1f & %.1f \\\\",
          label,
          mean(hcbs[[varname]], na.rm = TRUE),
          sd(hcbs[[varname]], na.rm = TRUE),
          median(hcbs[[varname]], na.rm = TRUE),
          mean(bh[[varname]], na.rm = TRUE),
          sd(bh[[varname]], na.rm = TRUE),
          median(bh[[varname]], na.rm = TRUE))
}

tab1_lines <- c(
  "\\begin{table}[htbp]",
  "\\centering",
  "\\caption{Summary Statistics: State-Level Monthly Medicaid Billing}",
  "\\label{tab:sumstats}",
  "\\small",
  "\\begin{tabular}{lcccccc}",
  "\\hline\\hline",
  " & \\multicolumn{3}{c}{HCBS (T-codes)} & \\multicolumn{3}{c}{Behavioral Health (H-codes)} \\\\",
  "\\cmidrule(lr){2-4} \\cmidrule(lr){5-7}",
  " & Mean & SD & Median & Mean & SD & Median \\\\",
  "\\hline",
  "\\multicolumn{7}{l}{\\textit{Panel A: Pre-Period (Jan 2018 -- Feb 2020)}} \\\\[3pt]"
)

# Format in millions for paid
tab1_lines <- c(tab1_lines,
  sprintf("Total Paid (\\$M) & %.1f & %.1f & %.1f & %.1f & %.1f & %.1f \\\\",
          mean(pre[service_type == "HCBS"]$total_paid, na.rm = TRUE) / 1e6,
          sd(pre[service_type == "HCBS"]$total_paid, na.rm = TRUE) / 1e6,
          median(pre[service_type == "HCBS"]$total_paid, na.rm = TRUE) / 1e6,
          mean(pre[service_type == "BH"]$total_paid, na.rm = TRUE) / 1e6,
          sd(pre[service_type == "BH"]$total_paid, na.rm = TRUE) / 1e6,
          median(pre[service_type == "BH"]$total_paid, na.rm = TRUE) / 1e6),
  sprintf("Total Claims (000s) & %.1f & %.1f & %.1f & %.1f & %.1f & %.1f \\\\",
          mean(pre[service_type == "HCBS"]$total_claims, na.rm = TRUE) / 1e3,
          sd(pre[service_type == "HCBS"]$total_claims, na.rm = TRUE) / 1e3,
          median(pre[service_type == "HCBS"]$total_claims, na.rm = TRUE) / 1e3,
          mean(pre[service_type == "BH"]$total_claims, na.rm = TRUE) / 1e3,
          sd(pre[service_type == "BH"]$total_claims, na.rm = TRUE) / 1e3,
          median(pre[service_type == "BH"]$total_claims, na.rm = TRUE) / 1e3),
  sprintf("Active Providers & %.0f & %.0f & %.0f & %.0f & %.0f & %.0f \\\\",
          mean(pre[service_type == "HCBS"]$n_providers, na.rm = TRUE),
          sd(pre[service_type == "HCBS"]$n_providers, na.rm = TRUE),
          median(pre[service_type == "HCBS"]$n_providers, na.rm = TRUE),
          mean(pre[service_type == "BH"]$n_providers, na.rm = TRUE),
          sd(pre[service_type == "BH"]$n_providers, na.rm = TRUE),
          median(pre[service_type == "BH"]$n_providers, na.rm = TRUE)),
  sprintf("Beneficiaries (000s) & %.1f & %.1f & %.1f & %.1f & %.1f & %.1f \\\\",
          mean(pre[service_type == "HCBS"]$total_beneficiaries, na.rm = TRUE) / 1e3,
          sd(pre[service_type == "HCBS"]$total_beneficiaries, na.rm = TRUE) / 1e3,
          median(pre[service_type == "HCBS"]$total_beneficiaries, na.rm = TRUE) / 1e3,
          mean(pre[service_type == "BH"]$total_beneficiaries, na.rm = TRUE) / 1e3,
          sd(pre[service_type == "BH"]$total_beneficiaries, na.rm = TRUE) / 1e3,
          median(pre[service_type == "BH"]$total_beneficiaries, na.rm = TRUE) / 1e3)
)

# Panel B: Treatment variation
tab1_lines <- c(tab1_lines,
  "[6pt]",
  "\\multicolumn{7}{l}{\\textit{Panel B: Treatment Variation}} \\\\[3pt]",
  sprintf("\\multicolumn{4}{l}{Peak stringency (April 2020)} & \\multicolumn{3}{l}{Mean = %.1f, SD = %.1f} \\\\",
          mean(state_treatment$peak_stringency, na.rm = TRUE),
          sd(state_treatment$peak_stringency, na.rm = TRUE)),
  sprintf("\\multicolumn{4}{l}{States with stay-at-home orders} & \\multicolumn{3}{l}{%d of 51} \\\\",
          sum(!state_treatment$never_treated)),
  sprintf("\\multicolumn{4}{l}{Observations (state $\\times$ service $\\times$ month)} & \\multicolumn{3}{l}{%s} \\\\",
          format(nrow(panel), big.mark = ",")),
  sprintf("\\multicolumn{4}{l}{States} & \\multicolumn{3}{l}{%d} \\\\",
          uniqueN(panel$state)),
  sprintf("\\multicolumn{4}{l}{Months (excl.~March 2020)} & \\multicolumn{3}{l}{%d} \\\\",
          uniqueN(panel$month_date)),
  "\\hline\\hline",
  "\\end{tabular}",
  "\\begin{minipage}{0.95\\textwidth}",
  "\\vspace{4pt}",
  "\\footnotesize",
  "\\textit{Notes:} HCBS = Home and Community-Based Services (T-codes in HCPCS); BH = Behavioral Health (H-codes). Data from T-MSIS Medicaid Provider Spending, January 2018--September 2024 (October--December 2024 excluded due to reporting lags). State assignment via NPPES practice address. Peak stringency is the April 2020 average of the Oxford COVID-19 Government Response Tracker Stringency Index (0--100 scale).",
  "\\end{minipage}",
  "\\end{table}"
)

writeLines(tab1_lines, file.path(TABLES, "tab1_sumstats.tex"))

## ---- Table 2: Main DDD Results ----
cat("Table 2: Main DDD results...\n")

extract_result <- function(model, model_name) {
  ct <- coeftable(model)
  coef_val <- ct[1, "Estimate"]
  se_val <- ct[1, "Std. Error"]
  pval <- ct[1, "Pr(>|t|)"]
  stars <- ifelse(pval < 0.01, "***", ifelse(pval < 0.05, "**", ifelse(pval < 0.1, "*", "")))
  n_obs <- model$nobs
  list(coef = coef_val, se = se_val, pval = pval, stars = stars, n = n_obs, name = model_name)
}

m1 <- extract_result(results$m1_paid, "Log Paid")
m2 <- extract_result(results$m2_claims, "Log Claims")
m3 <- extract_result(results$m3_providers, "Log Providers")
m4 <- extract_result(results$m4_benef, "Log Beneficiaries")
m5 <- extract_result(results$m5_intensive, "Log Paid/Provider")
m6 <- extract_result(results$m6_benef_prov, "Log Benef./Provider")

tab2_lines <- c(
  "\\begin{table}[htbp]",
  "\\centering",
  "\\caption{Triple-Difference Estimates: Effect of Lockdown Stringency on HCBS vs Behavioral Health}",
  "\\label{tab:main_ddd}",
  "\\small",
  "\\begin{tabular}{lcccccc}",
  "\\hline\\hline",
  " & (1) & (2) & (3) & (4) & (5) & (6) \\\\",
  " & Log & Log & Log & Log & Log Paid & Log Benef. \\\\",
  " & Paid & Claims & Providers & Benef. & /Provider & /Provider \\\\",
  "\\hline",
  sprintf("Stringency $\\times$ HCBS $\\times$ Post & %.3f%s & %.3f%s & %.3f%s & %.3f%s & %.3f%s & %.3f%s \\\\",
          m1$coef, m1$stars, m2$coef, m2$stars, m3$coef, m3$stars,
          m4$coef, m4$stars, m5$coef, m5$stars, m6$coef, m6$stars),
  sprintf(" & (%.3f) & (%.3f) & (%.3f) & (%.3f) & (%.3f) & (%.3f) \\\\",
          m1$se, m2$se, m3$se, m4$se, m5$se, m6$se),
  sprintf("\\relax[\\textit{p}-value] & [%.3f] & [%.3f] & [%.3f] & [%.3f] & [%.3f] & [%.3f] \\\\",
          m1$pval, m2$pval, m3$pval, m4$pval, m5$pval, m6$pval),
  "[6pt]",
  "\\hline",
  "State $\\times$ Service FE & Yes & Yes & Yes & Yes & Yes & Yes \\\\",
  "Service $\\times$ Month FE & Yes & Yes & Yes & Yes & Yes & Yes \\\\",
  "State $\\times$ Month FE & Yes & Yes & Yes & Yes & Yes & Yes \\\\",
  "Clustering & State & State & State & State & State & State \\\\",
  sprintf("Observations & %s & %s & %s & %s & %s & %s \\\\",
          format(m1$n, big.mark = ","), format(m2$n, big.mark = ","),
          format(m3$n, big.mark = ","), format(m4$n, big.mark = ","),
          format(m5$n, big.mark = ","), format(m6$n, big.mark = ",")),
  sprintf("States & %d & %d & %d & %d & %d & %d \\\\",
          uniqueN(panel$state), uniqueN(panel$state), uniqueN(panel$state),
          uniqueN(panel$state), uniqueN(panel$state), uniqueN(panel$state)),
  "\\hline\\hline",
  "\\end{tabular}",
  "\\begin{minipage}{0.95\\textwidth}",
  "\\vspace{4pt}",
  "\\footnotesize",
  "\\textit{Notes:} Triple-difference estimates. The dependent variable is stated in the column header. The treatment variable is the interaction of state-level peak lockdown stringency (April 2020 Oxford Stringency Index, standardized 0--1), an indicator for HCBS services (T-codes), and a post-lockdown indicator (April 2020+). March 2020 is excluded (partial treatment exposure). All specifications include state $\\times$ service type, service type $\\times$ month, and state $\\times$ month fixed effects. Standard errors clustered at the state level in parentheses. $^{***}$ $p<0.01$, $^{**}$ $p<0.05$, $^{*}$ $p<0.1$.",
  "\\end{minipage}",
  "\\end{table}"
)

writeLines(tab2_lines, file.path(TABLES, "tab2_main_ddd.tex"))

## ---- Table 3: Period-Specific Effects ----
cat("Table 3: Period-specific effects...\n")

m7 <- results$m7_periods
ct7 <- coeftable(m7)

tab3_lines <- c(
  "\\begin{table}[htbp]",
  "\\centering",
  "\\caption{Period-Specific Triple-Difference Effects}",
  "\\label{tab:periods}",
  "\\begin{tabular}{lc}",
  "\\hline\\hline",
  " & Log Total Paid \\\\",
  "\\hline"
)

period_names <- c("Lockdown (Apr--Jun 2020)", "Recovery (Jul--Dec 2020)",
                  "Post-Lockdown (2021)", "Post-Lockdown (2022+)")
for (i in 1:nrow(ct7)) {
  pval <- ct7[i, "Pr(>|t|)"]
  stars <- ifelse(pval < 0.01, "***", ifelse(pval < 0.05, "**", ifelse(pval < 0.1, "*", "")))
  tab3_lines <- c(tab3_lines,
    sprintf("Stringency $\\times$ HCBS $\\times$ %s & %.3f%s \\\\",
            period_names[i], ct7[i, "Estimate"], stars),
    sprintf(" & (%.3f) \\\\[3pt]", ct7[i, "Std. Error"])
  )
}

tab3_lines <- c(tab3_lines,
  "\\hline",
  "State $\\times$ Service FE & Yes \\\\",
  "Service $\\times$ Month FE & Yes \\\\",
  "State $\\times$ Month FE & Yes \\\\",
  "Clustering & State \\\\",
  sprintf("Observations & %s \\\\", format(m7$nobs, big.mark = ",")),
  "\\hline\\hline",
  "\\end{tabular}",
  "\\begin{minipage}{0.75\\textwidth}",
  "\\vspace{4pt}",
  "\\footnotesize",
  "\\textit{Notes:} Period-specific triple-difference estimates. Each period interacted with state peak stringency (0--1) and HCBS indicator. All specifications include state $\\times$ service, service $\\times$ month, and state $\\times$ month fixed effects. Standard errors clustered at the state level. $^{***}$ $p<0.01$, $^{**}$ $p<0.05$, $^{*}$ $p<0.1$.",
  "\\end{minipage}",
  "\\end{table}"
)

writeLines(tab3_lines, file.path(TABLES, "tab3_periods.tex"))

## ---- Table 4: Robustness ----
cat("Table 4: Robustness checks...\n")

rob_models <- list(
  list(model = results$m1_paid, label = "Baseline (Peak Stringency)"),
  list(model = robustness$r1_binary, label = "Binary Treatment (Median Split)"),
  list(model = robustness$r2_cumul, label = "Cumulative Stringency (Mar--Jun)"),
  list(model = robustness$r3_no_never, label = "Excl.~Never-Lockdown States"),
  list(model = robustness$r5_cpt, label = "Alt.~Comparison: CPT Professional"),
  list(model = robustness$r7_monthly, label = "Monthly Stringency (Post Only)")
)

tab4_lines <- c(
  "\\begin{table}[htbp]",
  "\\centering",
  "\\caption{Robustness of Triple-Difference Estimates}",
  "\\label{tab:robustness}",
  "\\small",
  "\\begin{tabular}{lccc}",
  "\\hline\\hline",
  "Specification & Coefficient & SE & \\textit{p}-value \\\\",
  "\\hline"
)

for (r in rob_models) {
  ct <- coeftable(r$model)
  pval <- ct[1, "Pr(>|t|)"]
  stars <- ifelse(pval < 0.01, "***", ifelse(pval < 0.05, "**", ifelse(pval < 0.1, "*", "")))
  tab4_lines <- c(tab4_lines,
    sprintf("%s & %.3f%s & (%.3f) & [%.3f] \\\\",
            r$label, ct[1, "Estimate"], stars, ct[1, "Std. Error"], pval)
  )
}

# Add RI result
tab4_lines <- c(tab4_lines,
  sprintf("Randomization Inference (1000 perms) & %.3f & (%.3f) & [%.3f] \\\\",
          robustness$ri_actual_coef, sd(robustness$ri_perm_coefs), robustness$ri_pvalue)
)

# Add placebo
ct_placebo <- coeftable(robustness$r4_placebo)
pval_p <- ct_placebo[1, "Pr(>|t|)"]
stars_p <- ifelse(pval_p < 0.01, "***", ifelse(pval_p < 0.05, "**", ifelse(pval_p < 0.1, "*", "")))
tab4_lines <- c(tab4_lines,
  sprintf("Placebo (March 2019) & %.3f%s & (%.3f) & [%.3f] \\\\",
          ct_placebo[1, "Estimate"], stars_p, ct_placebo[1, "Std. Error"], pval_p)
)

tab4_lines <- c(tab4_lines,
  "\\hline\\hline",
  "\\end{tabular}",
  "\\begin{minipage}{0.85\\textwidth}",
  "\\vspace{4pt}",
  "\\footnotesize",
  "\\textit{Notes:} All specifications use the same three-way fixed effects (state $\\times$ service, service $\\times$ month, state $\\times$ month) and cluster standard errors at the state level. Outcome is log total paid. Baseline uses peak April 2020 stringency (standardized 0--1). Binary treatment splits states at median stringency. ``Monthly Stringency'' uses time-varying OxCGRT stringency (0--100 scale), sample restricted to April 2020--December 2022 (OxCGRT coverage period); note the different treatment scale compared to baseline. For RI, SE column reports the standard deviation of the permutation distribution; the $p$-value is the share of permuted coefficients with absolute value exceeding the actual. Placebo assigns treatment in March 2019 using pre-period data only.",
  "\\end{minipage}",
  "\\end{table}"
)

writeLines(tab4_lines, file.path(TABLES, "tab4_robustness.tex"))

cat("\n=== All tables saved to", TABLES, "===\n")
