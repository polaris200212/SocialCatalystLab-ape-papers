## ============================================================================
## 06_tables.R — All tables for apep_0454 v8
##
## Table 1: Summary statistics
## Table 2: Main results — supply + beneficiary outcomes + mediation
## Table 3: Vulnerability interaction
## Table 4: DDD (ARPA, exploratory)
## Table 5: Robustness (expanded with v8 additions)
## Table 6: Balance
## Table 7: Broken-trend model (v8)
## Table 8: Entity-type heterogeneity (v8)
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

exit_stats <- state_exits[, .(
  mean_exit = round(mean(exit_rate_pre) * 100, 1),
  sd_exit = round(sd(exit_rate_pre) * 100, 1),
  min_exit = round(min(exit_rate_pre) * 100, 1),
  max_exit = round(max(exit_rate_pre) * 100, 1),
  mean_hcbs_exit = round(mean(hcbs_exit_rate_pre, na.rm = TRUE) * 100, 1),
  sd_hcbs_exit = round(sd(hcbs_exit_rate_pre, na.rm = TRUE) * 100, 1),
  min_hcbs_exit = round(min(hcbs_exit_rate_pre, na.rm = TRUE) * 100, 1),
  max_hcbs_exit = round(max(hcbs_exit_rate_pre, na.rm = TRUE) * 100, 1),
  mean_n_active = round(mean(n_active_pre)),
  sd_n_active = round(sd(n_active_pre)),
  min_n_active = round(min(n_active_pre)),
  max_n_active = round(max(n_active_pre))
)]

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

sink(file.path(TAB_DIR, "tab1_summary_stats.tex"))
cat("\\begin{table}[t]\n")
cat("\\centering\n")
cat("\\caption{Summary Statistics}\n")
cat("\\label{tab:summary}\n")
cat("\\begin{tabular}{lcccc}\n")
cat("\\toprule\n")
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
cat("\\footnotesize \\textit{Notes:} Panel A shows the distribution of pre-COVID provider exit rates across 51 states (50 + DC). Exit rate = share of providers active in 2018 with no billing in any month of 2019 (purely pre-treatment measure; no post-COVID information used). Reported in percentage points for readability; regression models use the proportion (0--1 scale). Panel B shows mean monthly outcomes by provider type (analysis truncated at June 2024 to avoid reporting-lag contamination). HCBS = providers billing T, H, or S-prefix HCPCS codes. Non-HCBS = providers billing CPT and other codes.\n")
cat("\\end{minipage}\n")
cat("\\end{table}\n")
sink()


## ---- Table 2: Main Results with Mediation and Beneficiary Outcomes ----
cat("Table 2: Main results (supply + mediation + beneficiary)...\n")

etable(
  results$did_covid,          # Col 1: Providers, no COVID controls (MAIN)
  results$did_with_covid,     # Col 2: Providers, + COVID deaths
  results$did_full_controls,  # Col 3: Providers, + full mediators
  results$did_bene,           # Col 4: Beneficiaries
  results$did_claims_per_bene, # Col 5: Claims/beneficiary
  results$did_spending_per_bene, # Col 6: Spending/beneficiary
  headers = c("Providers", "+ COVID Deaths", "+ Full Controls",
              "Beneficiaries", "Claims/Bene", "Spending/Bene"),
  depvar = FALSE,
  se.below = TRUE,
  keep = c("exit_rate"),
  fitstat = c("n", "r2"),
  file = file.path(TAB_DIR, "tab2_main_results.tex"),
  replace = TRUE,
  title = "Pre-COVID Provider Exits, Pandemic Disruption, and Beneficiary Consequences",
  label = "tab:main",
  notes = paste0(
    "\\", "textit{Notes:} HCBS providers only. Dependent variable in column header. ",
    "All specifications include state and month FE; SEs clustered at state level. ",
    "Column (1) is the main specification, estimating the total effect of pre-COVID exit intensity. ",
    "Columns (2)--(3) add COVID deaths per capita and stringency as controls; these may be ``bad controls'' ",
    "(mediators) if provider depletion worsened pandemic severity. ",
    "Columns (4)--(6) use beneficiary-side outcomes with the main (no mediator) specification. ",
    "* p<0.10, ** p<0.05, *** p<0.01."
  ),
  style.tex = style.tex("aer")
)


## ---- Table 3: Vulnerability Interaction ----
cat("Table 3: Vulnerability interaction...\n")

etable(
  results$vulnerability_providers,
  results$vulnerability_bene,
  results$vulnerability_claims_per_bene,
  headers = c("Providers", "Beneficiaries", "Claims/Bene"),
  depvar = TRUE,
  se.below = TRUE,
  keep = c("%exit_rate", "%covid_deaths_pc", "%I\\(exit_rate"),
  dict = c(
    "post_covid_num:exit_rate" = "Post-COVID $\\times$ Exit Rate",
    "post_covid_num:covid_deaths_pc" = "Post-COVID $\\times$ COVID Deaths/100k",
    "post_covid_num:I(exit_rate * covid_deaths_pc)" = "Post-COVID $\\times$ Exit Rate $\\times$ COVID Deaths/100k"
  ),
  fitstat = c("n", "r2"),
  file = file.path(TAB_DIR, "tab3_vulnerability.tex"),
  replace = TRUE,
  title = "Safety Net Vulnerability: Exit Rate $\\times$ COVID Severity",
  label = "tab:vulnerability",
  notes = paste0(
    "\\", "textit{Notes:} HCBS providers only. All specifications include state and month FE; ",
    "SEs clustered at state level. The interaction tests whether pre-COVID provider depletion ",
    "amplified the damage from pandemic severity. A negative interaction coefficient means ",
    "depleted states experienced disproportionately larger losses when hit by more severe COVID. ",
    "* p<0.10, ** p<0.05, *** p<0.01."
  ),
  style.tex = style.tex("aer")
)


## ---- Table 4: DDD Results (ARPA, Exploratory) ----
cat("Table 4: DDD results...\n")

etable(
  results$ddd_providers,
  results$ddd_bene,
  results$ddd_continuous,
  headers = c("Providers", "Beneficiaries", "Continuous"),
  depvar = FALSE,
  se.below = TRUE,
  keep = c("%triple_arpa", "%exit_rate_x_post_arpa_hcbs"),
  dict = c(
    "triple_arpa" = "Post-ARPA $\\times$ HCBS $\\times$ High-Exit",
    "exit_rate_x_post_arpa_hcbs" = "Post-ARPA $\\times$ HCBS $\\times$ Exit Rate"
  ),
  fitstat = c("n", "r2"),
  file = file.path(TAB_DIR, "tab4_ddd_results.tex"),
  replace = TRUE,
  title = "Exploratory: ARPA HCBS Investment and Supply Recovery",
  label = "tab:ddd",
  notes = paste0(
    "\\", "textit{Notes:} Triple-difference: Post-ARPA $\\", "times$ HCBS $\\", "times$ High-Exit. ",
    "Columns (1)--(2) use binary high-exit (above-median). Column (3) uses continuous exit rate. ",
    "All specifications include state $\\", "times$ provider-type and provider-type $\\", "times$ month FE. ",
    "Pre-trend joint F-test: F=", sprintf("%.2f", results$ddd_pre_test$stat),
    ", p=", sprintf("%.3f", results$ddd_pre_test$p), ". ",
    "SEs clustered at state level. * p<0.10, ** p<0.05, *** p<0.01."
  ),
  style.tex = style.tex("aer")
)


## ---- Table 5: Robustness Summary (v8 expanded) ----
cat("Table 5: Robustness...\n")

sink(file.path(TAB_DIR, "tab5_robustness.tex"))
cat("\\begin{table}[t]\n")
cat("\\centering\n")
cat("\\caption{Robustness Checks}\n")
cat("\\label{tab:robustness}\n")
cat("\\small\n")
cat("\\begin{tabular}{lccc}\n")
cat("\\toprule\n")
cat(" & Providers & Beneficiaries & Claims/Bene \\\\\n")
cat("\\midrule\n")

# Main result
main_coef <- coef(results$did_covid)["post_covid_num:exit_rate"]
main_se <- se(results$did_covid)["post_covid_num:exit_rate"]
bene_coef <- coef(results$did_bene)["post_covid_num:exit_rate"]
bene_se <- se(results$did_bene)["post_covid_num:exit_rate"]
cpb_coef <- coef(results$did_claims_per_bene)["post_covid_num:exit_rate"]
cpb_se <- se(results$did_claims_per_bene)["post_covid_num:exit_rate"]

cat(sprintf("Main specification & %.4f & %.4f & %.4f \\\\\n", main_coef, bene_coef, cpb_coef))
cat(sprintf(" & (%.4f) & (%.4f) & (%.4f) \\\\\n", main_se, bene_se, cpb_se))

# Non-HCBS falsification
if (!is.null(rob_results$rob_non_hcbs)) {
  nh_coef <- coef(rob_results$rob_non_hcbs)["post_covid_num:exit_rate"]
  nh_se <- se(rob_results$rob_non_hcbs)["post_covid_num:exit_rate"]
  cat(sprintf("Non-HCBS falsification & %.4f & --- & --- \\\\\n", nh_coef))
  cat(sprintf(" & (%.4f) & & \\\\\n", nh_se))
}

# Pandemic exit rate (legacy comparison)
if (!is.null(rob_results$did_pandemic_exit)) {
  pe_coef <- coef(rob_results$did_pandemic_exit)["post_covid_num:exit_rate_old"]
  pe_se <- se(rob_results$did_pandemic_exit)["post_covid_num:exit_rate_old"]
  cat(sprintf("Pandemic exit rate (legacy) & %.4f & --- & --- \\\\\n", pe_coef))
  cat(sprintf(" & (%.4f) & & \\\\\n", pe_se))
}

# Full sample (untruncated)
if (!is.null(rob_results$rob_full_sample)) {
  fs_coef <- coef(rob_results$rob_full_sample)["post_covid_num:exit_rate"]
  fs_se <- se(rob_results$rob_full_sample)["post_covid_num:exit_rate"]
  cat(sprintf("Full sample (untruncated) & %.4f & --- & --- \\\\\n", fs_coef))
  cat(sprintf(" & (%.4f) & & \\\\\n", fs_se))
}

# Collapsed regression
if (!is.null(results$collapsed_prov_hc2)) {
  coll_coef <- results$collapsed_prov_hc2["exit_rate_pre", "Estimate"]
  coll_se <- results$collapsed_prov_hc2["exit_rate_pre", "Std. Error"]
  cat(sprintf("Collapsed (N=51, HC2) & %.4f & --- & --- \\\\\n", coll_coef))
  cat(sprintf(" & (%.4f) & & \\\\\n", coll_se))
}

cat("\\midrule\n")
cat("\\multicolumn{4}{l}{\\textit{Inference}} \\\\\n")

cat(sprintf("RI $p$-value (unconditional) & %.3f & %.3f & %.3f \\\\\n",
            rob_results$ri_pvalue, rob_results$ri_pvalue_bene, rob_results$ri_pvalue_cpb))

if (!is.null(rob_results$cond_ri_pvalue)) {
  cat(sprintf("RI $p$-value (Census divisions) & %.3f & %.3f & --- \\\\\n",
              rob_results$cond_ri_pvalue, rob_results$cond_ri_pvalue_bene))
}

# v8 stratified RI
if (!is.null(rob_results$ri_pvalue_region)) {
  cat(sprintf("RI $p$-value (Census regions) & %.3f & --- & --- \\\\\n",
              rob_results$ri_pvalue_region))
}
if (!is.null(rob_results$ri_pvalue_urban)) {
  cat(sprintf("RI $p$-value (urbanicity quartiles) & %.3f & --- & --- \\\\\n",
              rob_results$ri_pvalue_urban))
}
if (!is.null(rob_results$ri_pvalue_gov)) {
  cat(sprintf("RI $p$-value (governor party) & %.3f & --- & --- \\\\\n",
              rob_results$ri_pvalue_gov))
}

cat(sprintf("LOO range & [%.4f, %.4f] & --- & --- \\\\\n",
            min(rob_results$loo_coefs, na.rm = TRUE),
            max(rob_results$loo_coefs, na.rm = TRUE)))

if (!is.null(results$pre_test) && !is.na(results$pre_test$stat)) {
  cat(sprintf("Pre-trend joint F (p) & %.2f (%.3f) & --- & --- \\\\\n",
              results$pre_test$stat, results$pre_test$p))
}

if (!is.null(rob_results$wcb_providers)) {
  cat(sprintf("WCR bootstrap $p$-value & %.3f & %.3f & --- \\\\\n",
              rob_results$wcb_providers$p_value,
              rob_results$wcb_bene$p_value))
}

cat("\\midrule\n")
cat("\\multicolumn{4}{l}{\\textit{Sensitivity analysis}} \\\\\n")

# State-specific linear trends
if (!is.null(results$did_broken_trend)) {
  bt_coef <- coef(results$did_broken_trend)["post_covid_num:exit_rate"]
  bt_se <- se(results$did_broken_trend)["post_covid_num:exit_rate"]
  cat(sprintf("State-specific linear trends & %.4f & --- & --- \\\\\n", bt_coef))
  cat(sprintf(" & (%.4f) & & \\\\\n", bt_se))
}

# HCBS-specific exit rate
if (!is.null(results$did_hcbs_specific)) {
  hs_coef <- coef(results$did_hcbs_specific)["post_covid_num:hcbs_exit_rate"]
  hs_se <- se(results$did_hcbs_specific)["post_covid_num:hcbs_exit_rate"]
  cat(sprintf("HCBS-specific exit rate & %.4f & --- & --- \\\\\n", hs_coef))
  cat(sprintf(" & (%.4f) & & \\\\\n", hs_se))
}

# HonestDiD breakdown
if (!is.null(rob_results$rm_breakdown_prov)) {
  cat(sprintf("HonestDiD breakdown $\\bar{M}$ & %s & %s & --- \\\\\n",
              ifelse(is.na(rob_results$rm_breakdown_prov), "0.00",
                     sprintf("%.2f", rob_results$rm_breakdown_prov)),
              ifelse(is.na(rob_results$rm_breakdown_bene), "0.00",
                     sprintf("%.2f", rob_results$rm_breakdown_bene))))
}

# augsynth ATT
if (!is.null(rob_results$asyn_att) && !is.na(rob_results$asyn_att)) {
  asyn_pval <- tryCatch({
    s <- summary(rob_results$asyn_result)
    pv <- s$average_att[["p Value"]]
    if (length(pv) == 0 || is.null(pv)) NA_real_ else pv
  }, error = function(e) NA_real_)
  cat(sprintf("augsynth ATT (binarized) & %.4f & --- & --- \\\\\n", rob_results$asyn_att))
  if (!is.na(asyn_pval) && length(asyn_pval) == 1) {
    cat(sprintf(" & [$p$ = %.2f] & & \\\\\n", asyn_pval))
  } else {
    cat(" & [$p$ = n/a] & & \\\\\n")
  }
}

# Anderson-Rubin CI
if (!is.null(rob_results$ar_ci_lo) && !is.na(rob_results$ar_ci_lo)) {
  if (rob_results$ar_bounded) {
    cat(sprintf("Anderson-Rubin 95\\%% CI & [%.2f, %.2f] & --- & --- \\\\\n",
                rob_results$ar_ci_lo, rob_results$ar_ci_hi))
  } else {
    cat("Anderson-Rubin 95\\% CI & unbounded & --- & --- \\\\\n")
  }
}

cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{minipage}{0.9\\textwidth}\n")
cat("\\vspace{0.2cm}\n")
cat("\\footnotesize \\textit{Notes:} All specifications use state and month FE with state-clustered SEs unless noted. Primary analysis truncated at June 2024. Exit rate uses pre-period definition (2018 active, absent in 2019). ``Pandemic exit rate'' uses the legacy definition (2018--2019 active, absent after Feb 2020). Collapsed regression uses pre/post state means with HC2 standard errors (N=51). RI permutes exit rates across states; conditional RI permutes within strata. WCR bootstrap: Wild Cluster Restricted bootstrap (999 replications, Rademacher weights). HonestDiD breakdown $\\bar{M}$: largest violation of parallel trends under which the 95\\% robust CI still excludes zero \\citep{rambachan2023}. augsynth: augmented synthetic control with binarized treatment \\citep{benmichael2021}.\n")
cat("\\end{minipage}\n")
cat("\\end{table}\n")
sink()


## ---- Table 6: Balance Table ----
cat("Table 6: Balance...\n")

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

sink(file.path(TAB_DIR, "tab6_balance.tex"))
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

## ---- Table 7: Broken-Trend Model (v8) ----
cat("Table 7: Broken-trend model...\n")

etable(
  results$bt_providers,
  results$bt_bene,
  results$bt_claims_per_bene,
  results$bt_spending_per_bene,
  headers = c("Providers", "Beneficiaries", "Claims/Bene", "Spending/Bene"),
  depvar = FALSE,
  se.below = TRUE,
  keep = c("%exit_x_trend", "%exit_x_post", "%exit_x_post_trend"),
  dict = c(
    "exit_x_trend" = "$\\lambda$: Exit Rate $\\times$ Trend",
    "exit_x_post" = "$\\beta$: Exit Rate $\\times$ Post",
    "exit_x_post_trend" = "$\\kappa$: Exit Rate $\\times$ Post $\\times$ Trend"
  ),
  fitstat = c("n", "r2"),
  file = file.path(TAB_DIR, "tab7_broken_trend.tex"),
  replace = TRUE,
  title = "Broken-Trend Model: Pre-Trend, Level Shift, and Slope Change",
  label = "tab:broken_trend",
  notes = paste0(
    "\\", "textit{Notes:} HCBS providers only. ",
    "Specification: $Y_{st} = \\", "alpha_s + \\", "delta_t + \\", "lambda(\\", "theta_s \\", "times t) + ",
    "\\", "beta(\\", "theta_s \\", "times \\", "text{Post}_t) + ",
    "\\", "kappa(\\", "theta_s \\", "times \\", "text{Post}_t \\", "times t) + \\", "gamma X_{st} + \\", "varepsilon_{st}$. ",
    "$\\", "lambda$ captures the ongoing differential trend identified from the pre-period. ",
    "$\\", "beta$ captures the level shift at COVID onset. ",
    "$\\", "kappa$ (the key parameter) captures whether the post-COVID trajectory accelerates ",
    "relative to the pre-existing differential trend. ",
    "Month FE absorb the common time path; state FE absorb time-invariant state characteristics. ",
    "State-clustered SEs. * p<0.10, ** p<0.05, *** p<0.01."
  ),
  style.tex = style.tex("aer")
)

## ---- Table 8: Entity-Type Heterogeneity (v8) ----
cat("Table 8: Entity-type heterogeneity...\n")

etable(
  rob_results$did_ent1,
  rob_results$did_ent1_bene,
  rob_results$did_ent2,
  rob_results$did_ent2_bene,
  headers = c("Type 1: Providers", "Type 1: Bene",
              "Type 2: Providers", "Type 2: Bene"),
  depvar = FALSE,
  se.below = TRUE,
  keep = c("exit_rate"),
  fitstat = c("n", "r2"),
  file = file.path(TAB_DIR, "tab8_entity_type.tex"),
  replace = TRUE,
  title = "Entity-Type Heterogeneity: Individual vs.\\ Organization Providers",
  label = "tab:entity_type",
  notes = paste0(
    "\\", "textit{Notes:} HCBS providers only. ",
    "Entity Type 1 = individual practitioners. Entity Type 2 = organizational entities. ",
    "Organization exits may represent dozens of individual workers. ",
    "All specifications include state and month FE with state-clustered SEs. ",
    "Exit rate uses pre-period definition (2018 active, absent in 2019). ",
    "* p<0.10, ** p<0.05, *** p<0.01."
  ),
  style.tex = style.tex("aer")
)

cat("\n=== All tables generated ===\n")
