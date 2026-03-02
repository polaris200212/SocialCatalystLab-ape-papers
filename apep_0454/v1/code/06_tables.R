## ============================================================================
## 06_tables.R — All tables for apep_0454
## ============================================================================

source("00_packages.R")

panel <- readRDS(file.path(DATA_DIR, "panel_clean.rds"))
results <- readRDS(file.path(DATA_DIR, "main_results.rds"))
rob_results <- readRDS(file.path(DATA_DIR, "robustness_results.rds"))
state_exits <- results$state_exits

## ---- Table 1: Summary Statistics ----
cat("Table 1: Summary statistics...\n")

hcbs <- panel[prov_type == "HCBS"]
non_hcbs <- panel[prov_type == "Non-HCBS"]

# Panel A: State-level exit intensity
exit_stats <- state_exits[, .(
  mean_exit = round(mean(exit_rate) * 100, 1),
  sd_exit = round(sd(exit_rate) * 100, 1),
  min_exit = round(min(exit_rate) * 100, 1),
  max_exit = round(max(exit_rate) * 100, 1),
  mean_hcbs_exit = round(mean(hcbs_exit_rate, na.rm = TRUE) * 100, 1),
  sd_hcbs_exit = round(sd(hcbs_exit_rate, na.rm = TRUE) * 100, 1),
  min_hcbs_exit = round(min(hcbs_exit_rate, na.rm = TRUE) * 100, 1),
  max_hcbs_exit = round(max(hcbs_exit_rate, na.rm = TRUE) * 100, 1),
  mean_n_active = round(mean(n_active)),
  sd_n_active = round(sd(n_active)),
  min_n_active = round(min(n_active)),
  max_n_active = round(max(n_active))
)]

# Panel B: Monthly outcomes, by provider type
panel_stats <- panel[, .(
  mean_providers = round(mean(n_providers)),
  sd_providers = round(sd(n_providers)),
  mean_claims = round(mean(total_claims)),
  sd_claims = round(sd(total_claims)),
  mean_bene = round(mean(total_beneficiaries)),
  sd_bene = round(sd(total_beneficiaries)),
  mean_paid = round(mean(total_paid / 1e6), 1),
  sd_paid = round(sd(total_paid / 1e6), 1)
), by = prov_type]

# Write LaTeX
sink(file.path(TAB_DIR, "tab1_summary_stats.tex"))
cat("\\begin{table}[t]\n")
cat("\\centering\n")
cat("\\caption{Summary Statistics}\n")
cat("\\label{tab:summary}\n")
cat("\\begin{tabular}{lcccc}\n")
cat("\\toprule\n")

# Panel A
cat("\\multicolumn{5}{l}{\\textit{Panel A: Pre-COVID Provider Exit Intensity (51 States)}} \\\\\n")
cat("\\midrule\n")
cat(" & Mean & SD & Min & Max \\\\\n")
cat(sprintf("Overall exit rate (\\%%) & %.1f & %.1f & %.1f & %.1f \\\\\n",
            exit_stats$mean_exit, exit_stats$sd_exit, exit_stats$min_exit, exit_stats$max_exit))
cat(sprintf("HCBS exit rate (\\%%) & %.1f & %.1f & %.1f & %.1f \\\\\n",
            exit_stats$mean_hcbs_exit, exit_stats$sd_hcbs_exit, exit_stats$min_hcbs_exit, exit_stats$max_hcbs_exit))
cat(sprintf("Active providers (2018--2019) & %s & %s & %s & %s \\\\\n",
            format(exit_stats$mean_n_active, big.mark = ","),
            format(exit_stats$sd_n_active, big.mark = ","),
            format(exit_stats$min_n_active, big.mark = ","),
            format(exit_stats$max_n_active, big.mark = ",")))

# Panel B
cat("\\midrule\n")
cat("\\multicolumn{5}{l}{\\textit{Panel B: Monthly State-Level Outcomes}} \\\\\n")
cat("\\midrule\n")
cat(" & \\multicolumn{2}{c}{HCBS} & \\multicolumn{2}{c}{Non-HCBS} \\\\\n")
cat(" & Mean & SD & Mean & SD \\\\\n")
cat(sprintf("Active providers & %s & %s & %s & %s \\\\\n",
            format(panel_stats[prov_type == "HCBS", mean_providers], big.mark = ","),
            format(panel_stats[prov_type == "HCBS", sd_providers], big.mark = ","),
            format(panel_stats[prov_type == "Non-HCBS", mean_providers], big.mark = ","),
            format(panel_stats[prov_type == "Non-HCBS", sd_providers], big.mark = ",")))
cat(sprintf("Monthly claims & %s & %s & %s & %s \\\\\n",
            format(panel_stats[prov_type == "HCBS", mean_claims], big.mark = ","),
            format(panel_stats[prov_type == "HCBS", sd_claims], big.mark = ","),
            format(panel_stats[prov_type == "Non-HCBS", mean_claims], big.mark = ","),
            format(panel_stats[prov_type == "Non-HCBS", sd_claims], big.mark = ",")))
cat(sprintf("Monthly beneficiaries & %s & %s & %s & %s \\\\\n",
            format(panel_stats[prov_type == "HCBS", mean_bene], big.mark = ","),
            format(panel_stats[prov_type == "HCBS", sd_bene], big.mark = ","),
            format(panel_stats[prov_type == "Non-HCBS", mean_bene], big.mark = ","),
            format(panel_stats[prov_type == "Non-HCBS", sd_bene], big.mark = ",")))
cat(sprintf("Monthly spending (\\$M) & %.1f & %.1f & %.1f & %.1f \\\\\n",
            panel_stats[prov_type == "HCBS", mean_paid],
            panel_stats[prov_type == "HCBS", sd_paid],
            panel_stats[prov_type == "Non-HCBS", mean_paid],
            panel_stats[prov_type == "Non-HCBS", sd_paid]))

cat("\\midrule\n")
cat(sprintf("Observations & \\multicolumn{4}{c}{%s state $\\times$ type $\\times$ months} \\\\\n",
            format(nrow(panel), big.mark = ",")))
cat(sprintf("States & \\multicolumn{4}{c}{%d} \\\\\n", uniqueN(panel$state)))
cat(sprintf("Months & \\multicolumn{4}{c}{%d (%s to %s)} \\\\\n",
            uniqueN(panel$month_date), format(min(panel$month_date), "%b %Y"),
            format(max(panel$month_date), "%b %Y")))
cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{minipage}{0.95\\textwidth}\n")
cat("\\vspace{0.2cm}\n")
cat("\\footnotesize \\textit{Notes:} Panel A shows the distribution of pre-COVID provider exit rates across 51 states (50 + DC). Exit rate = share of providers active in 2018--2019 with no billing after February 2020. Panel B shows mean monthly outcomes by provider type. HCBS = providers billing T, H, or S-prefix HCPCS codes (home/community-based and behavioral health services). Non-HCBS = providers billing CPT and other codes.\n")
cat("\\end{minipage}\n")
cat("\\end{table}\n")
sink()

## ---- Table 2: Main Results — Part 1 (COVID × Exit Rate) ----
cat("Table 2: Main results...\n")

etable(
  results$did_covid,
  results$iv_providers,
  rob_results$rob_no_controls,
  rob_results$rob_full_controls,
  headers = c("OLS", "Reduced Form", "No Controls", "Full Controls"),
  depvar = TRUE,
  se.below = TRUE,
  keep = c("exit_rate", "predicted_exit_rate"),
  fitstat = c("n", "r2", "ar2"),
  file = file.path(TAB_DIR, "tab2_main_results.tex"),
  replace = TRUE,
  title = "Pre-COVID Provider Exits and Pandemic HCBS Disruption",
  label = "tab:main",
  notes = "\\textit{Notes:} Sample: HCBS providers only (N = 4,284 state-months). Dependent variable: ln(active HCBS providers). Exit rate is the share of 2018--2019 active providers absent after Feb 2020. All specifications include state and month fixed effects. Standard errors clustered at the state level in parentheses. Column (2) reports the reduced form of the shift-share IV (national specialty exit rates $\\times$ local specialty composition; first-stage F = 7.5). * p<0.10, ** p<0.05, *** p<0.01.",
  style.tex = style.tex("aer")
)

## ---- Table 3: DDD Results — Part 2 (ARPA × HCBS × Exit) ----
cat("Table 3: DDD results...\n")

etable(
  results$ddd_providers,
  results$ddd_bene,
  results$ddd_continuous,
  headers = c("Providers", "Beneficiaries", "Continuous"),
  depvar = TRUE,
  se.below = TRUE,
  keep = c("triple_arpa", "exit_rate_x_post_arpa_hcbs"),
  fitstat = c("n", "r2"),
  file = file.path(TAB_DIR, "tab3_ddd_results.tex"),
  replace = TRUE,
  title = "ARPA HCBS Investment and Provider Supply Recovery",
  label = "tab:ddd",
  notes = paste0("\\", "textit{Notes:} Triple-difference: Post-ARPA $\\", "times$ HCBS $\\", "times$ High-Exit. Columns (1)--(2) use binary high-exit (above-median). Column (3) uses continuous exit rate. All specifications include state $\\", "times$ provider-type (102 groups) and provider-type $\\", "times$ month (168 groups) fixed effects, which absorb the bulk of the variance and account for the high $R^2$ values. Standard errors clustered at the state level. * p<0.10, ** p<0.05, *** p<0.01."),
  style.tex = style.tex("aer")
)

## ---- Table 4: Robustness Summary ----
cat("Table 4: Robustness...\n")

sink(file.path(TAB_DIR, "tab4_robustness.tex"))
cat("\\begin{table}[t]\n")
cat("\\centering\n")
cat("\\caption{Robustness Checks: Pre-COVID Exits and HCBS Provider Supply}\n")
cat("\\label{tab:robustness}\n")
cat("\\begin{tabular}{lcc}\n")
cat("\\toprule\n")
cat("Specification & Coefficient & SE \\\\\n")
cat("\\midrule\n")

# Main result (continuous exit rate interaction)
main_coef <- coef(results$did_covid)["post_covid_num:exit_rate"]
main_se <- sqrt(vcov(results$did_covid)["post_covid_num:exit_rate", "post_covid_num:exit_rate"])
cat(sprintf("Main specification (continuous) & %.4f & (%.4f) \\\\\n", main_coef, main_se))

# No controls
nc_coef <- coef(rob_results$rob_no_controls)["post_covid_num:exit_rate"]
nc_se <- sqrt(vcov(rob_results$rob_no_controls)["post_covid_num:exit_rate", "post_covid_num:exit_rate"])
cat(sprintf("No controls (continuous) & %.4f & (%.4f) \\\\\n", nc_coef, nc_se))

# Full controls
fc_coef <- coef(rob_results$rob_full_controls)["post_covid_num:exit_rate"]
fc_se <- sqrt(vcov(rob_results$rob_full_controls)["post_covid_num:exit_rate", "post_covid_num:exit_rate"])
cat(sprintf("Full controls (continuous) & %.4f & (%.4f) \\\\\n", fc_coef, fc_se))

cat("\\midrule\n")
cat(sprintf("Randomization inference $p$-value & \\multicolumn{2}{c}{%.3f} \\\\\n",
            rob_results$ri_pvalue))
cat(sprintf("Leave-one-out range & \\multicolumn{2}{c}{[%.4f, %.4f]} \\\\\n",
            min(rob_results$loo_coefs, na.rm = TRUE),
            max(rob_results$loo_coefs, na.rm = TRUE)))

# Placebo
placebo_coefs <- coef(rob_results$es_placebo)
placebo_post <- placebo_coefs[grep("::[1-9]", names(placebo_coefs))]
if (length(placebo_post) > 0) {
  mean_placebo <- mean(placebo_post)
  cat(sprintf("Placebo (Mar 2019) mean post-coef & \\multicolumn{2}{c}{%.3f} \\\\\n", mean_placebo))
}

cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{minipage}{0.9\\textwidth}\n")
cat("\\vspace{0.2cm}\n")
cat("\\footnotesize \\textit{Notes:} Sample: HCBS providers only (N = 4,284 state-months). All specifications use ln(active HCBS providers) as the dependent variable with state and month fixed effects and state-clustered standard errors. The main specification interacts post-COVID (indicator) with the continuous state-level exit rate (share of 2018--2019 providers absent after Feb 2020). Randomization inference permutes exit rates across states (500 iterations). Leave-one-out drops each state and re-estimates.\n")
cat("\\end{minipage}\n")
cat("\\end{table}\n")
sink()

## ---- Table 5: Balance Table ----
cat("Table 5: Balance...\n")

balance <- merge(
  state_exits[, .(state, exit_quartile, high_exit)],
  panel[prov_type == "HCBS" & month_date == "2019-12-01",
        .(state, n_providers, total_claims, total_paid, total_beneficiaries)],
  by = "state", all.x = TRUE
)

bal_dt <- merge(balance,
  panel[prov_type == "HCBS" & month_date == "2019-12-01",
        .(state, population, median_income, poverty_rate, pct_black, median_age, unemp_rate)],
  by = "state", all.x = TRUE
) |> unique(by = "state")

bal_summary <- bal_dt[, .(
  pop = mean(population, na.rm = TRUE),
  income = mean(median_income, na.rm = TRUE),
  poverty = mean(poverty_rate, na.rm = TRUE) * 100,
  pct_black = mean(pct_black, na.rm = TRUE) * 100,
  age = mean(median_age, na.rm = TRUE),
  providers = mean(n_providers, na.rm = TRUE),
  unemp = mean(unemp_rate, na.rm = TRUE)
), by = high_exit]

sink(file.path(TAB_DIR, "tab5_balance.tex"))
cat("\\begin{table}[t]\n")
cat("\\centering\n")
cat("\\caption{Balance: High vs.\\ Low Pre-COVID Exit States (Dec 2019)}\n")
cat("\\label{tab:balance}\n")
cat("\\begin{tabular}{lccc}\n")
cat("\\toprule\n")
cat(" & Low Exit & High Exit & Diff. \\\\\n")
cat("\\midrule\n")

vars <- c("pop", "income", "poverty", "pct_black", "age", "providers", "unemp")
labels <- c("Population", "Median Income (\\$)", "Poverty Rate (\\%)",
            "Black (\\%)", "Median Age", "HCBS Providers", "Unemployment (\\%)")

for (i in seq_along(vars)) {
  lo <- bal_summary[high_exit == FALSE, get(vars[i])]
  hi <- bal_summary[high_exit == TRUE, get(vars[i])]
  if (vars[i] %in% c("pop", "income", "providers")) {
    cat(sprintf("%s & %s & %s & %s \\\\\n",
                labels[i],
                format(round(lo), big.mark = ","),
                format(round(hi), big.mark = ","),
                format(round(hi - lo), big.mark = ",")))
  } else {
    cat(sprintf("%s & %.1f & %.1f & %.1f \\\\\n", labels[i], lo, hi, hi - lo))
  }
}

cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{minipage}{0.85\\textwidth}\n")
cat("\\vspace{0.2cm}\n")
cat("\\footnotesize \\textit{Notes:} Means of pre-COVID state characteristics by above/below-median exit rate. Population and income from 2019 ACS 5-Year. Providers from T-MSIS December 2019 billing.\n")
cat("\\end{minipage}\n")
cat("\\end{table}\n")
sink()

cat("\n=== All tables generated ===\n")
