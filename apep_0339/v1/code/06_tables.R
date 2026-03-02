## ============================================================================
## 06_tables.R — All table generation
## Paper: State Minimum Wage Increases and the Medicaid Home Care Workforce
## ============================================================================

source("00_packages.R")

DATA <- "../data"
TABS <- "../tables"
dir.create(TABS, showWarnings = FALSE)

## ---- Load data ----
panel <- readRDS(file.path(DATA, "panel_hcbs_annual.rds"))
results <- readRDS(file.path(DATA, "main_results.rds"))
robust <- readRDS(file.path(DATA, "robustness_results.rds"))
mw_annual <- readRDS(file.path(DATA, "mw_annual.rds"))

## ---- Table 1: Summary Statistics ----
cat("Table 1: Summary statistics...\n")

# Panel A: HCBS Provider Outcomes
panel_stats <- panel[!is.na(population) & population > 0, .(
  mean_providers = mean(avg_monthly_providers, na.rm = TRUE),
  sd_providers = sd(avg_monthly_providers, na.rm = TRUE),
  mean_providers_pc = mean(providers_per_100k, na.rm = TRUE),
  sd_providers_pc = sd(providers_per_100k, na.rm = TRUE),
  mean_spending = mean(total_paid, na.rm = TRUE),
  sd_spending = sd(total_paid, na.rm = TRUE),
  mean_spending_pc = mean(spending_per_capita, na.rm = TRUE),
  sd_spending_pc = sd(spending_per_capita, na.rm = TRUE),
  mean_claims = mean(total_claims, na.rm = TRUE),
  sd_claims = sd(total_claims, na.rm = TRUE),
  mean_benes = mean(total_beneficiaries, na.rm = TRUE),
  sd_benes = sd(total_beneficiaries, na.rm = TRUE)
)]

# Panel B: By treatment status
treat_stats <- panel[!is.na(population) & population > 0, .(
  n_states = uniqueN(state),
  mean_providers_pc = mean(providers_per_100k, na.rm = TRUE),
  sd_providers_pc = sd(providers_per_100k, na.rm = TRUE),
  mean_spending_pc = mean(spending_per_capita, na.rm = TRUE),
  sd_spending_pc = sd(spending_per_capita, na.rm = TRUE),
  mean_mw = mean(min_wage, na.rm = TRUE),
  sd_mw = sd(min_wage, na.rm = TRUE)
), by = .(treated = first_treat_year > 0)]

# Panel C: Minimum wage variation
mw_stats <- mw_annual[year >= 2018 & year <= 2024 & state_abbr %in% unique(panel$state), .(
  mean_mw = mean(min_wage, na.rm = TRUE),
  sd_mw = sd(min_wage, na.rm = TRUE),
  min_mw = min(min_wage, na.rm = TRUE),
  max_mw = max(min_wage, na.rm = TRUE),
  n_increases = sum(mw_change > 0, na.rm = TRUE)
)]

# Write LaTeX table
tab1 <- c(
  "\\begin{table}[htbp]",
  "\\centering",
  "\\caption{Summary Statistics}",
  "\\label{tab:summary}",
  "\\begin{tabular}{lcc}",
  "\\toprule",
  " & Mean & SD \\\\",
  "\\midrule",
  "\\multicolumn{3}{l}{\\textit{Panel A: HCBS Provider Outcomes (state-year level)}} \\\\[3pt]",
  sprintf("Active HCBS providers (monthly avg) & %s & %s \\\\",
          format(round(panel_stats$mean_providers), big.mark = ","),
          format(round(panel_stats$sd_providers), big.mark = ",")),
  sprintf("Providers per 100,000 pop & %.1f & %.1f \\\\",
          panel_stats$mean_providers_pc, panel_stats$sd_providers_pc),
  sprintf("Annual HCBS spending (\\$M) & %.1f & %.1f \\\\",
          panel_stats$mean_spending / 1e6, panel_stats$sd_spending / 1e6),
  sprintf("HCBS spending per capita (\\$) & %.0f & %.0f \\\\",
          panel_stats$mean_spending_pc, panel_stats$sd_spending_pc),
  sprintf("Annual claims (thousands) & %s & %s \\\\",
          format(round(panel_stats$mean_claims / 1000), big.mark = ","),
          format(round(panel_stats$sd_claims / 1000), big.mark = ",")),
  sprintf("Annual beneficiaries (thousands) & %s & %s \\\\",
          format(round(panel_stats$mean_benes / 1000), big.mark = ","),
          format(round(panel_stats$sd_benes / 1000), big.mark = ",")),
  "\\\\",
  "\\multicolumn{3}{l}{\\textit{Panel B: Minimum Wage Variation}} \\\\[3pt]",
  sprintf("State minimum wage (\\$/hr) & %.2f & %.2f \\\\",
          mw_stats$mean_mw, mw_stats$sd_mw),
  sprintf("Range & \\multicolumn{2}{c}{[\\$%.2f, \\$%.2f]} \\\\",
          mw_stats$min_mw, mw_stats$max_mw),
  sprintf("Total MW increase events & \\multicolumn{2}{c}{%d} \\\\",
          mw_stats$n_increases),
  "\\\\",
  sprintf("States & \\multicolumn{2}{c}{%d} \\\\", uniqueN(panel$state)),
  sprintf("State-years & \\multicolumn{2}{c}{%s} \\\\",
          format(nrow(panel), big.mark = ",")),
  sprintf("Years & \\multicolumn{2}{c}{%d--%d} \\\\",
          min(panel$year), max(panel$year)),
  "\\bottomrule",
  "\\end{tabular}",
  "\\begin{tablenotes}[flushleft]",
  "\\small",
  "\\item \\textit{Notes:} HCBS providers defined as NPIs billing T, H, or S HCPCS codes.",
  "Provider counts reflect unique billing NPIs active in each state-year.",
  "Spending is total Medicaid payments in nominal dollars.",
  "\\end{tablenotes}",
  "\\end{table}"
)
writeLines(tab1, file.path(TABS, "tab1_summary.tex"))

## ---- Table 2: Balance Table (Treated vs Control) ----
cat("Table 2: Balance table...\n")

balance <- panel[year == 2018 & !is.na(population) & population > 0, .(
  providers_pc = providers_per_100k,
  spending_pc = spending_per_capita,
  log_providers = log_providers,
  log_spending = log_spending,
  min_wage = min_wage,
  population = population / 1e6,
  treated = first_treat_year > 0
)]

balance_means <- balance[, lapply(.SD, function(x) c(mean(x, na.rm = TRUE), sd(x, na.rm = TRUE))),
                          by = treated, .SDcols = c("providers_pc", "spending_pc",
                                                     "min_wage", "population")]

tab2 <- c(
  "\\begin{table}[htbp]",
  "\\centering",
  "\\caption{Baseline Balance: Treated vs.\\ Never-Treated States (2018)}",
  "\\label{tab:balance}",
  "\\begin{tabular}{lccc}",
  "\\toprule",
  " & Treated & Never-Treated & Difference \\\\",
  "\\midrule"
)

vars <- c("providers_pc", "spending_pc", "min_wage", "population")
var_labels <- c("HCBS providers/100k", "Spending per capita (\\$)",
                "Minimum wage (\\$/hr)", "Population (millions)")

for (i in seq_along(vars)) {
  v <- vars[i]
  t_mean <- balance[treated == TRUE, mean(get(v), na.rm = TRUE)]
  c_mean <- balance[treated == FALSE, mean(get(v), na.rm = TRUE)]
  t_sd <- balance[treated == TRUE, sd(get(v), na.rm = TRUE)]
  c_sd <- balance[treated == FALSE, sd(get(v), na.rm = TRUE)]
  diff <- t_mean - c_mean

  tab2 <- c(tab2,
    sprintf("%s & %.2f & %.2f & %.2f \\\\", var_labels[i], t_mean, c_mean, diff),
    sprintf(" & (%.2f) & (%.2f) & \\\\", t_sd, c_sd)
  )
}

n_treat <- balance[treated == TRUE, .N]
n_control <- balance[treated == FALSE, .N]
tab2 <- c(tab2,
  "\\midrule",
  sprintf("N (states) & %d & %d & \\\\", n_treat, n_control),
  "\\bottomrule",
  "\\end{tabular}",
  "\\begin{tablenotes}[flushleft]",
  "\\small",
  "\\item \\textit{Notes:} Standard deviations in parentheses. Treated states had at least one",
  "minimum wage increase during 2018--2024. Never-treated states remained at the federal minimum (\\$7.25).",
  "\\end{tablenotes}",
  "\\end{table}"
)
writeLines(tab2, file.path(TABS, "tab2_balance.tex"))

## ---- Table 3: Main Results ----
cat("Table 3: Main results...\n")

# Build results table: CS ATTs across outcomes
main_tab <- data.table(
  outcome = c("Log(Providers)", "Log(Spending)", "Providers/100k", "Spending/Capita"),
  att = c(results$att_providers$overall.att,
          results$att_spending$overall.att,
          results$att_percapita$overall.att,
          results$att_spend_pc$overall.att),
  se = c(results$att_providers$overall.se,
         results$att_spending$overall.se,
         results$att_percapita$overall.se,
         results$att_spend_pc$overall.se)
)
main_tab[, pval := 2 * pnorm(-abs(att / se))]
main_tab[, stars := fcase(
  pval < 0.01, "***",
  pval < 0.05, "**",
  pval < 0.1, "*",
  default = ""
)]

tab3 <- c(
  "\\begin{table}[htbp]",
  "\\centering",
  "\\caption{Effect of Minimum Wage Increases on HCBS Provider Supply}",
  "\\label{tab:main_results}",
  "\\begin{tabular}{lcccc}",
  "\\toprule",
  " & (1) & (2) & (3) & (4) \\\\",
  " & Log(Providers) & Log(Spending) & Providers/100k & Spending/Capita \\\\",
  "\\midrule",
  sprintf("ATT & %.4f%s & %.4f%s & %.2f%s & %.2f%s \\\\",
          main_tab$att[1], main_tab$stars[1],
          main_tab$att[2], main_tab$stars[2],
          main_tab$att[3], main_tab$stars[3],
          main_tab$att[4], main_tab$stars[4]),
  sprintf(" & (%.4f) & (%.4f) & (%.2f) & (%.2f) \\\\",
          main_tab$se[1], main_tab$se[2], main_tab$se[3], main_tab$se[4]),
  sprintf("[95\\%% CI] & [%.4f, %.4f] & [%.4f, %.4f] & [%.2f, %.2f] & [%.2f, %.2f] \\\\",
          main_tab$att[1] - 1.96*main_tab$se[1], main_tab$att[1] + 1.96*main_tab$se[1],
          main_tab$att[2] - 1.96*main_tab$se[2], main_tab$att[2] + 1.96*main_tab$se[2],
          main_tab$att[3] - 1.96*main_tab$se[3], main_tab$att[3] + 1.96*main_tab$se[3],
          main_tab$att[4] - 1.96*main_tab$se[4], main_tab$att[4] + 1.96*main_tab$se[4]),
  "\\\\",
  "Estimator & \\multicolumn{4}{c}{Callaway--Sant'Anna (2021)} \\\\",
  "Control group & \\multicolumn{4}{c}{Never-treated states} \\\\",
  sprintf("Treated states & \\multicolumn{4}{c}{%d} \\\\",
          uniqueN(panel[first_treat_year > 0, state])),
  sprintf("N (state-years) & \\multicolumn{4}{c}{%s} \\\\",
          format(nrow(panel), big.mark = ",")),
  "\\bottomrule",
  "\\end{tabular}",
  "\\begin{tablenotes}[flushleft]",
  "\\small",
  "\\item \\textit{Notes:} $^{***}p<0.01$; $^{**}p<0.05$; $^{*}p<0.1$.",
  "Standard errors in parentheses. ATT estimates from Callaway and Sant'Anna (2021)",
  "heterogeneity-robust DiD. Treatment defined as state's first minimum wage increase",
  "during 2018--2024.",
  "\\end{tablenotes}",
  "\\end{table}"
)
writeLines(tab3, file.path(TABS, "tab3_main_results.tex"))

## ---- Table 4: Robustness ----
cat("Table 4: Robustness...\n")

rob_tab <- data.table(
  specification = c(
    "Main: CS, never-treated",
    "Not-yet-treated control",
    "Anticipation = 1 year",
    "TWFE: log(MW) elasticity",
    "TWFE: Region $\\times$ year FE",
    "Restricted: $\\geq$3 pre-periods",
    "Falsification: Non-HCBS providers"
  ),
  att = c(
    results$att_providers$overall.att,
    robust$not_yet_treated$agg$overall.att,
    robust$anticipation$agg$overall.att,
    coef(results$twfe_continuous)["log_mw"],
    coef(robust$twfe_region)["log_mw"],
    if (!is.null(robust$restricted)) robust$restricted$agg$overall.att else NA_real_,
    robust$falsification_nonhcbs$agg$overall.att
  ),
  se = c(
    results$att_providers$overall.se,
    robust$not_yet_treated$agg$overall.se,
    robust$anticipation$agg$overall.se,
    sqrt(vcov(results$twfe_continuous)["log_mw","log_mw"]),
    sqrt(vcov(robust$twfe_region)["log_mw","log_mw"]),
    if (!is.null(robust$restricted)) robust$restricted$agg$overall.se else NA_real_,
    robust$falsification_nonhcbs$agg$overall.se
  )
)
rob_tab <- rob_tab[!is.na(att)]
rob_tab[, pval := 2 * pnorm(-abs(att / se))]
rob_tab[, stars := fcase(
  pval < 0.01, "***",
  pval < 0.05, "**",
  pval < 0.1, "*",
  default = ""
)]

tab4 <- c(
  "\\begin{table}[htbp]",
  "\\centering",
  "\\caption{Robustness of Main Result}",
  "\\label{tab:robustness}",
  "\\begin{tabular}{lcc}",
  "\\toprule",
  "Specification & ATT & SE \\\\",
  "\\midrule"
)

for (i in seq_len(nrow(rob_tab))) {
  tab4 <- c(tab4,
    sprintf("%s & %.4f%s & (%.4f) \\\\",
            rob_tab$specification[i], rob_tab$att[i], rob_tab$stars[i], rob_tab$se[i])
  )
}

tab4 <- c(tab4,
  "\\bottomrule",
  "\\end{tabular}",
  "\\begin{tablenotes}[flushleft]",
  "\\small",
  "\\item \\textit{Notes:} $^{***}p<0.01$; $^{**}p<0.05$; $^{*}p<0.1$.",
  "All specifications use log(HCBS providers) as the outcome.",
  "``Not-yet-treated'' uses states that will be treated later as additional controls.",
  "``Restricted'' drops cohorts with fewer than 3 years of pre-treatment data.",
  "``Falsification'' uses non-HCBS providers (CPT codes) as a placebo outcome.",
  "\\end{tablenotes}",
  "\\end{table}"
)
writeLines(tab4, file.path(TABS, "tab4_robustness.tex"))

## ---- Table 5: Event Study Coefficients ----
cat("Table 5: Event study coefficients...\n")

es <- results$es_providers
es_df <- data.table(
  event_time = es$egt,
  att = es$att.egt,
  se = es$se.egt
)
es_df[, pval := 2 * pnorm(-abs(att / se))]
es_df[, stars := fcase(
  pval < 0.01, "***",
  pval < 0.05, "**",
  pval < 0.1, "*",
  default = ""
)]

tab5 <- c(
  "\\begin{table}[htbp]",
  "\\centering",
  "\\caption{Event Study Coefficients: Log(HCBS Providers)}",
  "\\label{tab:event_study}",
  "\\begin{tabular}{lcc}",
  "\\toprule",
  "Event Time & ATT & SE \\\\",
  "\\midrule"
)

for (i in seq_len(nrow(es_df))) {
  label <- ifelse(es_df$event_time[i] < 0,
                  sprintf("$t%d$", es_df$event_time[i]),
                  sprintf("$t+%d$", es_df$event_time[i]))
  if (es_df$event_time[i] == -1) {
    tab5 <- c(tab5, sprintf("%s & \\multicolumn{2}{c}{[Reference]} \\\\", label))
  } else {
    tab5 <- c(tab5,
      sprintf("%s & %.4f%s & (%.4f) \\\\",
              label, es_df$att[i], es_df$stars[i], es_df$se[i])
    )
  }
}

# Compute Wald test on pre-treatment coefficients (excluding reference)
pre_idx <- es_df$event_time < -1
pre_z <- es_df$att[pre_idx] / es_df$se[pre_idx]
wald_stat <- sum(pre_z^2)
wald_pval <- pchisq(wald_stat, df = sum(pre_idx), lower.tail = FALSE)

tab5 <- c(tab5,
  "\\midrule",
  sprintf("Pre-trend Wald $p$-value & \\multicolumn{2}{c}{%.3f} \\\\", wald_pval),
  "\\bottomrule",
  "\\end{tabular}",
  "\\par\\vspace{3pt}\\noindent",
  "\\small",
  "\\textit{Notes:} Callaway--Sant'Anna dynamic aggregation.",
  "Reference period: $t=-1$.",
  "",
  "\\end{table}"
)
writeLines(tab5, file.path(TABS, "tab5_event_study.tex"))

## ---- Table 6: Treatment Cohort Detail ----
cat("Table 6: Treatment cohorts...\n")

cohort_detail <- panel[, .(
  n_states = uniqueN(state),
  avg_mw = mean(min_wage, na.rm = TRUE),
  avg_providers_pc = mean(providers_per_100k, na.rm = TRUE)
), by = .(cohort = fifelse(first_treat_year == 0, "Never treated", as.character(first_treat_year)))]
setorder(cohort_detail, cohort)

tab6 <- c(
  "\\begin{table}[htbp]",
  "\\centering",
  "\\caption{Treatment Cohort Characteristics}",
  "\\label{tab:cohorts}",
  "\\begin{tabular}{lccc}",
  "\\toprule",
  "Cohort & States & Avg MW (\\$) & Avg Providers/100k \\\\",
  "\\midrule"
)

for (i in seq_len(nrow(cohort_detail))) {
  tab6 <- c(tab6,
    sprintf("%s & %d & %.2f & %.1f \\\\",
            cohort_detail$cohort[i], cohort_detail$n_states[i],
            cohort_detail$avg_mw[i], cohort_detail$avg_providers_pc[i])
  )
}

tab6 <- c(tab6,
  "\\bottomrule",
  "\\end{tabular}",
  "\\begin{tablenotes}[flushleft]",
  "\\small",
  "\\item \\textit{Notes:} Averages computed across all years in panel.",
  "Cohort = year of state's first minimum wage increase during 2018--2024.",
  "\\end{tablenotes}",
  "\\end{table}"
)
writeLines(tab6, file.path(TABS, "tab6_cohorts.tex"))

cat("\n=== All tables generated ===\n")
