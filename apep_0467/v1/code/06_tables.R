## ============================================================================
## 06_tables.R — All tables for the paper
## apep_0467: Priced Out of Care
##
## Tables:
##   1. Summary statistics
##   2. Wage ratio by state
##   3. Main DiD results (multiple outcomes)
##   4. Robustness battery
##   5. Provider type heterogeneity
##   6. Pre-trend balance
## ============================================================================

source("00_packages.R")

panel <- readRDS(file.path(DATA, "panel_analysis.rds"))
wage_ratio <- readRDS(file.path(DATA, "state_wage_ratio.rds"))
results <- readRDS(file.path(DATA, "main_results.rds"))
rob <- readRDS(file.path(DATA, "robustness_results.rds"))


## ============================================================
## Table 1: Summary Statistics
## ============================================================
cat("Table 1: Summary statistics...\n")

# Panel-level summary
sum_stats <- panel[, .(
  # Outcomes
  mean_providers = mean(n_providers),
  sd_providers = sd(n_providers),
  mean_beneficiaries = mean(total_beneficiaries),
  sd_beneficiaries = sd(total_beneficiaries),
  mean_spending = mean(total_paid),
  sd_spending = sd(total_paid),
  # Treatment
  mean_ratio = mean(wage_ratio),
  sd_ratio = sd(wage_ratio),
  mean_pca_wage = mean(pca_wage),
  mean_outside_wage = mean(outside_wage),
  # Sample
  n_states = uniqueN(state),
  n_months = uniqueN(month_date),
  n_obs = .N
)]

# By period
sum_by_period <- panel[, .(
  mean_providers = mean(n_providers),
  sd_providers = sd(n_providers),
  mean_beneficiaries = mean(total_beneficiaries),
  sd_beneficiaries = sd(total_beneficiaries),
  mean_spending_m = mean(total_paid) / 1e6,
  n_obs = .N
), by = .(Period = ifelse(post_covid == 0, "Pre-COVID", "Post-COVID"))]

# By tercile
sum_by_tercile <- panel[!is.na(ratio_tercile), .(
  mean_providers = mean(n_providers),
  sd_providers = sd(n_providers),
  mean_beneficiaries = mean(total_beneficiaries),
  mean_spending_m = mean(total_paid) / 1e6,
  mean_pca_wage = mean(pca_wage),
  mean_outside_wage = mean(outside_wage),
  mean_ratio = mean(wage_ratio),
  n_states = uniqueN(state)
), by = .(Tercile = ratio_tercile)]

# Write LaTeX table
sink(file.path(TABS, "tab1_summary.tex"))
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Summary Statistics}\n")
cat("\\label{tab:summary}\n")
cat("\\begin{tabular}{lcccc}\n")
cat("\\toprule\n")
cat(" & \\multicolumn{1}{c}{Full Sample} & \\multicolumn{3}{c}{By Wage Ratio Tercile} \\\\\n")
cat("\\cmidrule(lr){2-2} \\cmidrule(lr){3-5}\n")
cat(" & & Low & Medium & High \\\\\n")
cat("\\midrule\n")
cat("\\multicolumn{5}{l}{\\textit{Panel A: Treatment Variable}} \\\\\n")
cat(sprintf("Personal care aide wage (\\$/hr) & %.2f & %.2f & %.2f & %.2f \\\\\n",
            mean(wage_ratio$pca_wage),
            sum_by_tercile[Tercile == "Low"]$mean_pca_wage,
            sum_by_tercile[Tercile == "Medium"]$mean_pca_wage,
            sum_by_tercile[Tercile == "High"]$mean_pca_wage))
cat(sprintf("Competing sector wage (\\$/hr) & %.2f & %.2f & %.2f & %.2f \\\\\n",
            mean(wage_ratio$outside_wage),
            sum_by_tercile[Tercile == "Low"]$mean_outside_wage,
            sum_by_tercile[Tercile == "Medium"]$mean_outside_wage,
            sum_by_tercile[Tercile == "High"]$mean_outside_wage))
cat(sprintf("Wage competitiveness ratio & %.3f & %.3f & %.3f & %.3f \\\\\n",
            mean(wage_ratio$wage_ratio),
            sum_by_tercile[Tercile == "Low"]$mean_ratio,
            sum_by_tercile[Tercile == "Medium"]$mean_ratio,
            sum_by_tercile[Tercile == "High"]$mean_ratio))
cat("[4pt]\n")
cat("\\multicolumn{5}{l}{\\textit{Panel B: Outcomes (state-month means)}} \\\\\n")
cat(sprintf("Active HCBS providers & %.0f & %.0f & %.0f & %.0f \\\\\n",
            sum_stats$mean_providers,
            sum_by_tercile[Tercile == "Low"]$mean_providers,
            sum_by_tercile[Tercile == "Medium"]$mean_providers,
            sum_by_tercile[Tercile == "High"]$mean_providers))
cat(sprintf("Beneficiaries served & %s & %s & %s & %s \\\\\n",
            format(round(sum_stats$mean_beneficiaries), big.mark = ","),
            format(round(sum_by_tercile[Tercile == "Low"]$mean_beneficiaries), big.mark = ","),
            format(round(sum_by_tercile[Tercile == "Medium"]$mean_beneficiaries), big.mark = ","),
            format(round(sum_by_tercile[Tercile == "High"]$mean_beneficiaries), big.mark = ",")))
cat(sprintf("Monthly spending (\\$M) & %.1f & %.1f & %.1f & %.1f \\\\\n",
            sum_stats$mean_spending / 1e6,
            sum_by_tercile[Tercile == "Low"]$mean_spending_m,
            sum_by_tercile[Tercile == "Medium"]$mean_spending_m,
            sum_by_tercile[Tercile == "High"]$mean_spending_m))
cat("[4pt]\n")
cat("\\multicolumn{5}{l}{\\textit{Panel C: Sample}} \\\\\n")
cat(sprintf("States & %d & %d & %d & %d \\\\\n",
            sum_stats$n_states,
            sum_by_tercile[Tercile == "Low"]$n_states,
            sum_by_tercile[Tercile == "Medium"]$n_states,
            sum_by_tercile[Tercile == "High"]$n_states))
cat(sprintf("Months & %d & & & \\\\\n", sum_stats$n_months))
cat(sprintf("State-month observations & %s & & & \\\\\n",
            format(sum_stats$n_obs, big.mark = ",")))
cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{tablenotes}[flushleft]\\small\n")
cat("\\item \\textit{Notes:} Wage competitiveness ratio = BLS QCEW average hourly wage in NAICS 624120 (Services for the Elderly and Persons with Disabilities) divided by simple average of hourly wages in three competing industries (grocery stores, limited-service restaurants, general warehousing). All wages are 2019 annual averages, private sector. Tercile cutoffs based on 2019 ratio distribution. HCBS providers defined as billing NPIs with T-code or S-code activity in T-MSIS.\n")
cat("\\end{tablenotes}\n")
cat("\\end{table}\n")
sink()
cat("  Saved tab1_summary.tex\n")


## ============================================================
## Table 2: Main DiD Results
## ============================================================
cat("Table 2: Main results...\n")

etable(
  results$did_base,
  results$did_covid,
  results$did_outcomes$log_beneficiaries,
  results$did_outcomes$log_spending,
  results$did_outcomes$log_claims,
  headers = c("Providers", "Providers", "Beneficiaries", "Spending", "Claims"),
  se.below = TRUE,
  depvar = FALSE,
  fixef.group = list("State FE" = "state", "Month FE" = "month_date"),
  notes = "Clustered standard errors at state level in parentheses. Significance: $^{*}$ $p<0.10$, $^{**}$ $p<0.05$, $^{***}$ $p<0.01$.",
  title = "Wage Competitiveness and HCBS Outcomes: Main Results",
  label = "tab:main",
  file = file.path(TABS, "tab2_main_results.tex"),
  style.tex = style.tex("aer"),
  replace = TRUE
)
cat("  Saved tab2_main_results.tex\n")


## ============================================================
## Table 3: Robustness Battery
## ============================================================
cat("Table 3: Robustness...\n")

etable(
  results$did_covid,
  rob$region_month,
  rob$no_lockdown,
  results$did_tercile,
  rob$wage_level,
  headers = c("Baseline", "Reg.×Month", "No Lockdown", "Terciles", "Wage Lvl."),
  se.below = TRUE,
  depvar = FALSE,
  drop.section = "fixef",
  extralines = list(
    "_State FE" = c("$\\checkmark$","$\\checkmark$","$\\checkmark$","$\\checkmark$","$\\checkmark$"),
    "_Month FE" = c("$\\checkmark$","","$\\checkmark$","$\\checkmark$","$\\checkmark$"),
    "_Region×Month FE" = c("","$\\checkmark$","","","")
  ),
  notes = "All specifications include state FE and clustered SEs at state level.",
  title = "Robustness Checks",
  label = "tab:robustness",
  file = file.path(TABS, "tab3_robustness.tex"),
  style.tex = style.tex("aer"),
  replace = TRUE
)
cat("  Saved tab3_robustness.tex\n")


## ============================================================
## Table 4: Provider Type Heterogeneity
## ============================================================
cat("Table 4: Heterogeneity...\n")

etable(
  results$did_covid,
  results$did_sole,
  results$did_org,
  headers = c("All Providers", "Sole Proprietors", "Organizations"),
  se.below = TRUE,
  depvar = FALSE,
  fixef.group = list("State FE" = "state", "Month FE" = "month_date"),
  notes = "Clustered standard errors at state level.",
  title = "Heterogeneity by Provider Type",
  label = "tab:heterogeneity",
  file = file.path(TABS, "tab4_heterogeneity.tex"),
  style.tex = style.tex("aer"),
  replace = TRUE
)
cat("  Saved tab4_heterogeneity.tex\n")


## ============================================================
## Table 5: Placebo Tests
## ============================================================
cat("Table 5: Placebo tests...\n")

etable(
  results$did_covid,
  rob$placebo_bh,
  rob$pretrend,
  headers = c("HCBS (Main)", "BH Placebo", "Pre-Trend Test"),
  se.below = TRUE,
  depvar = FALSE,
  fixef.group = list("State FE" = "state", "Month FE" = "month_date"),
  notes = "Column 1: main specification. Column 2: behavioral health providers as placebo. Column 3: pre-trend test on pre-COVID data only.",
  title = "Falsification and Placebo Tests",
  label = "tab:placebo",
  file = file.path(TABS, "tab5_placebo.tex"),
  style.tex = style.tex("aer"),
  replace = TRUE
)
cat("  Saved tab5_placebo.tex\n")


## ============================================================
## Table 6: ARPA Recovery
## ============================================================
cat("Table 6: ARPA recovery...\n")

etable(
  results$did_covid,
  results$did_arpa,
  headers = c("Post-COVID Only", "Post-COVID + ARPA"),
  se.below = TRUE,
  depvar = FALSE,
  fixef.group = list("State FE" = "state", "Month FE" = "month_date"),
  notes = "Clustered standard errors at state level. ARPA period begins April 2021.",
  title = "ARPA HCBS Spending and Workforce Recovery",
  label = "tab:arpa",
  file = file.path(TABS, "tab6_arpa.tex"),
  style.tex = style.tex("aer"),
  replace = TRUE
)
cat("  Saved tab6_arpa.tex\n")


cat("\n=== All tables saved ===\n")
