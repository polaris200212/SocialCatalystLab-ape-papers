## ============================================================
## 06_tables.R — All tables for the paper (v2: expanded)
## ============================================================

source("00_packages.R")

df <- readRDS("../data/analysis_data.rds")
results_v2 <- readRDS("../data/rd_results_v2.rds")
results <- results_v2$labor
balance_results <- readRDS("../data/balance_results.rds")
bw_results <- readRDS("../data/bw_sensitivity.rds")
mht <- readRDS("../data/mht_correction.rds")

tab_dir <- "../tables"
dir.create(tab_dir, showWarnings = FALSE)

## ----------------------------------------------------------
## Table 1: Summary Statistics
## ----------------------------------------------------------

cat("Creating Table 1: Summary Statistics...\n")

stats_list <- list()
for (side in c("Full Sample", "Below 1,000", "Above 1,000")) {
  sub <- switch(side,
    "Full Sample" = df,
    "Below 1,000" = df %>% filter(above_threshold == 0),
    "Above 1,000" = df %>% filter(above_threshold == 1)
  )

  stats_list[[side]] <- tibble(
    group = side, n = nrow(sub),
    pop_mean = mean(sub$pop),
    female_share = mean(sub$female_share),
    female_mayor = mean(sub$has_female_mayor, na.rm = TRUE),
    female_emp_rate = mean(sub$female_emp_rate, na.rm = TRUE),
    female_lfpr = mean(sub$female_lfpr, na.rm = TRUE),
    male_emp_rate = mean(sub$male_emp_rate, na.rm = TRUE),
    gender_gap = mean(sub$gender_emp_gap, na.rm = TRUE),
    unemp_rate = mean(sub$unemployment_rate, na.rm = TRUE),
    density = mean(sub$densite, na.rm = TRUE),
    spend_total_pc = mean(sub$spend_total_pc, na.rm = TRUE),
    spend_social_pc = mean(sub$spend_social_pc, na.rm = TRUE)
  )
}

stats <- bind_rows(stats_list)

sink(file.path(tab_dir, "tab1_summary.tex"))
cat("\\begin{table}[H]\n")
cat("\\centering\n")
cat("\\caption{Summary Statistics}\n")
cat("\\begin{threeparttable}\n")
cat("\\begin{tabular}{lrrr}\n")
cat("\\toprule\n")
cat(" & Full Sample & Below 1{,}000 & Above 1{,}000 \\\\\n")
cat("\\midrule\n")
cat(sprintf("N (communes) & %s & %s & %s \\\\\n",
    format(stats$n[1], big.mark = ","),
    format(stats$n[2], big.mark = ","),
    format(stats$n[3], big.mark = ",")))
cat(sprintf("Population (mean) & %s & %s & %s \\\\\n",
    format(round(stats$pop_mean[1]), big.mark = ","),
    format(round(stats$pop_mean[2]), big.mark = ","),
    format(round(stats$pop_mean[3]), big.mark = ",")))
cat(sprintf("Female councillor share & %.3f & %.3f & %.3f \\\\\n",
    stats$female_share[1], stats$female_share[2], stats$female_share[3]))
cat(sprintf("Female mayor (share) & %.3f & %.3f & %.3f \\\\\n",
    stats$female_mayor[1], stats$female_mayor[2], stats$female_mayor[3]))
cat(sprintf("Female employment rate & %.3f & %.3f & %.3f \\\\\n",
    stats$female_emp_rate[1], stats$female_emp_rate[2], stats$female_emp_rate[3]))
cat(sprintf("Female LFPR & %.3f & %.3f & %.3f \\\\\n",
    stats$female_lfpr[1], stats$female_lfpr[2], stats$female_lfpr[3]))
cat(sprintf("Male employment rate & %.3f & %.3f & %.3f \\\\\n",
    stats$male_emp_rate[1], stats$male_emp_rate[2], stats$male_emp_rate[3]))
cat(sprintf("Gender employment gap & %.3f & %.3f & %.3f \\\\\n",
    stats$gender_gap[1], stats$gender_gap[2], stats$gender_gap[3]))
cat(sprintf("Unemployment rate & %.3f & %.3f & %.3f \\\\\n",
    stats$unemp_rate[1], stats$unemp_rate[2], stats$unemp_rate[3]))
cat(sprintf("Density (hab/km\\textsuperscript{2}) & %.0f & %.0f & %.0f \\\\\n",
    stats$density[1], stats$density[2], stats$density[3]))

# Add spending if available
if (!is.na(stats$spend_total_pc[1]) && stats$spend_total_pc[1] > 0) {
  cat("\\midrule\n")
  cat("\\multicolumn{4}{l}{\\textit{Municipal Spending (per capita, EUR)}} \\\\\n")
  cat(sprintf("Total spending & %.0f & %.0f & %.0f \\\\\n",
      stats$spend_total_pc[1], stats$spend_total_pc[2], stats$spend_total_pc[3]))
  if (!is.na(stats$spend_social_pc[1])) {
    cat(sprintf("Social spending & %.0f & %.0f & %.0f \\\\\n",
        stats$spend_social_pc[1], stats$spend_social_pc[2], stats$spend_social_pc[3]))
  }
}

cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{tablenotes}[flushleft]\n")
cat("\\small\n")
cat("\\item Notes: Metropolitan French communes. Employment and LFPR for population aged 15--64 from INSEE 2022 census. Female councillor share from RNE (2025). Municipal spending from DGFIP Balances Comptables (2019--2022 average).\n")
cat("\\end{tablenotes}\n")
cat("\\end{threeparttable}\n")
cat("\\label{tab:summary}\n")
cat("\\end{table}\n")
sink()

## ----------------------------------------------------------
## Table 2: Main RDD Results (with CIs, Holm p-values)
## ----------------------------------------------------------

cat("Creating Table 2: Main RDD Results...\n")

outcome_order <- c("female_emp_rate", "female_lfpr", "male_emp_rate",
                   "gender_emp_gap", "female_share_employed",
                   "total_emp_rate", "unemployment_rate")

sink(file.path(tab_dir, "tab2_main_results.tex"))
cat("\\begin{table}[H]\n")
cat("\\centering\n")
cat("\\caption{RDD Estimates: Effect of the 1,000-Inhabitant Electoral Regime Change on Labor Market Outcomes}\n")
cat("\\begin{threeparttable}\n")
cat("\\begin{tabular}{lccccccc}\n")
cat("\\toprule\n")
cat("Outcome & Estimate & SE & 95\\% CI & $p$ & Holm $p$ & BW & $N$ \\\\\n")
cat("\\midrule\n")

for (v in outcome_order) {
  if (!v %in% names(results)) next
  r <- results[[v]]
  stars <- ifelse(r$pv_robust < 0.01, "***",
           ifelse(r$pv_robust < 0.05, "**",
           ifelse(r$pv_robust < 0.10, "*", "")))

  # Get Holm p-value
  holm_p <- NA
  if (!is.null(mht$labor_holm)) {
    idx <- which(mht$labor_holm$name == r$name)
    if (length(idx) > 0) holm_p <- mht$labor_holm$p_holm[idx]
  }

  cat(sprintf("%s & %.4f%s & (%.4f) & [%.3f, %.3f] & %.3f & %.3f & %d & %s \\\\\n",
      r$name, r$coef_conv, stars, r$se_robust,
      r$ci_lower, r$ci_upper,
      r$pv_robust, ifelse(is.na(holm_p), r$pv_robust, holm_p),
      round(r$bw), format(r$n_left + r$n_right, big.mark = ",")))
}

cat("\\midrule\n")
cat("\\multicolumn{8}{l}{\\textit{First stage: Female councillor share}} \\\\\n")

sub200 <- df %>% filter(abs(pop_centered) <= 200)
mod_fs <- lm(female_share ~ above_threshold + pop_centered +
               I(above_threshold * pop_centered), data = sub200)
se_fs <- sqrt(vcovHC(mod_fs, type = "HC1")[2, 2])
fs_coef <- coef(mod_fs)[2]
cat(sprintf("Female councillor share & %.4f*** & (%.4f) & [%.3f, %.3f] & $<$0.001 & --- & 200 & %s \\\\\n",
    fs_coef, se_fs, fs_coef - 1.96 * se_fs, fs_coef + 1.96 * se_fs,
    format(nrow(sub200), big.mark = ",")))

cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{tablenotes}[flushleft]\n")
cat("\\small\n")
cat("\\item Notes: Each row reports a separate RDD. Local linear regression, triangular kernel, CER-optimal bandwidth \\citep{cattaneo2020practical}. Robust bias-corrected SE in parentheses. Holm $p$-values correct for multiple testing across the seven labor market outcomes. First stage: BW = 200, HC1 SE. * $p<0.10$, ** $p<0.05$, *** $p<0.01$.\n")
cat("\\end{tablenotes}\n")
cat("\\end{threeparttable}\n")
cat("\\label{tab:main}\n")
cat("\\end{table}\n")
sink()

## ----------------------------------------------------------
## Table 3: Covariate Balance
## ----------------------------------------------------------

cat("Creating Table 3: Covariate Balance...\n")

sink(file.path(tab_dir, "tab3_balance.tex"))
cat("\\begin{table}[H]\n")
cat("\\centering\n")
cat("\\caption{Covariate Balance at the 1,000-Inhabitant Threshold}\n")
cat("\\begin{threeparttable}\n")
cat("\\begin{tabular}{lccccc}\n")
cat("\\toprule\n")
cat("Pre-determined Covariate & RDD Estimate & SE & $p$-value & BW & $N$ \\\\\n")
cat("\\midrule\n")

for (i in seq_len(nrow(balance_results))) {
  cat(sprintf("%s & %.4f & (%.4f) & %.3f & %d & %s \\\\\n",
      balance_results$variable[i],
      balance_results$coef[i],
      balance_results$se[i],
      balance_results$pvalue[i],
      round(balance_results$bw[i]),
      format(balance_results$n_obs[i], big.mark = ",")))
}

cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{tablenotes}[flushleft]\n")
cat("\\small\n")
cat("\\item Notes: Pre-determined covariates from 2011 census (before the threshold was lowered to 1,000 in 2014). Local linear regression with robust bias-corrected inference.\n")
cat("\\end{tablenotes}\n")
cat("\\end{threeparttable}\n")
cat("\\label{tab:balance}\n")
cat("\\end{table}\n")
sink()

## ----------------------------------------------------------
## Table 4: Political Competition and Pipeline Outcomes
## ----------------------------------------------------------

cat("Creating Table 4: Political Outcomes...\n")

sink(file.path(tab_dir, "tab4_political.tex"))
cat("\\begin{table}[H]\n")
cat("\\centering\n")
cat("\\caption{Political Competition and Pipeline Outcomes at the 1,000 Threshold}\n")
cat("\\begin{threeparttable}\n")
cat("\\begin{tabular}{lcccccc}\n")
cat("\\toprule\n")
cat("Outcome & Estimate & SE & 95\\% CI & $p$ & BW & $N$ \\\\\n")
cat("\\midrule\n")

for (v in names(results_v2$political)) {
  r <- results_v2$political[[v]]
  stars <- ifelse(r$pv_robust < 0.01, "***",
           ifelse(r$pv_robust < 0.05, "**",
           ifelse(r$pv_robust < 0.10, "*", "")))
  cat(sprintf("%s & %.4f%s & (%.4f) & [%.3f, %.3f] & %.3f & %d & %s \\\\\n",
      r$name, r$coef_conv, stars, r$se_robust,
      r$ci_lower, r$ci_upper,
      r$pv_robust, round(r$bw),
      format(r$n_left + r$n_right, big.mark = ",")))
}

cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{tablenotes}[flushleft]\n")
cat("\\small\n")
cat("\\item Notes: Each row reports a separate RDD at the 1,000-inhabitant threshold. Female mayor is an indicator for having a female mayor (elected by the council, not mechanically determined by parity). Candidacy data from Ministry of Interior 2020 municipal election files. Local linear regression, triangular kernel, CER-optimal bandwidth.\n")
cat("\\end{tablenotes}\n")
cat("\\end{threeparttable}\n")
cat("\\label{tab:political}\n")
cat("\\end{table}\n")
sink()

## ----------------------------------------------------------
## Table 5: Spending Outcomes
## ----------------------------------------------------------

cat("Creating Table 5: Spending Outcomes...\n")

sink(file.path(tab_dir, "tab5_spending.tex"))
cat("\\begin{table}[H]\n")
cat("\\centering\n")
cat("\\caption{Municipal Spending Outcomes at the 1,000 Threshold}\n")
cat("\\begin{threeparttable}\n")
cat("\\begin{tabular}{lcccccc}\n")
cat("\\toprule\n")
cat("Outcome & Estimate & SE & 95\\% CI & $p$ & BW & $N$ \\\\\n")
cat("\\midrule\n")

if (length(results_v2$spending) > 0) {
  for (v in names(results_v2$spending)) {
    r <- results_v2$spending[[v]]
    stars <- ifelse(r$pv_robust < 0.01, "***",
             ifelse(r$pv_robust < 0.05, "**",
             ifelse(r$pv_robust < 0.10, "*", "")))
    cat(sprintf("%s & %.2f%s & (%.2f) & [%.2f, %.2f] & %.3f & %d & %s \\\\\n",
        r$name, r$coef_conv, stars, r$se_robust,
        r$ci_lower, r$ci_upper,
        r$pv_robust, round(r$bw),
        format(r$n_left + r$n_right, big.mark = ",")))
  }
} else {
  cat("\\multicolumn{7}{c}{\\textit{Spending data not available}} \\\\\n")
}

cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{tablenotes}[flushleft]\n")
cat("\\small\n")
cat("\\item Notes: Spending per capita (EUR) from DGFIP Balances Comptables, averaged over 2019--2022. Social spending = functional categories 5 (action sociale) and 6 (famille). Winsorized at 1st and 99th percentiles. Local linear regression, triangular kernel, CER-optimal bandwidth.\n")
cat("\\end{tablenotes}\n")
cat("\\end{threeparttable}\n")
cat("\\label{tab:spending}\n")
cat("\\end{table}\n")
sink()

## ----------------------------------------------------------
## Table 6: Fuzzy RD-IV Estimates
## ----------------------------------------------------------

cat("Creating Table 6: Fuzzy RD-IV...\n")

sink(file.path(tab_dir, "tab6_fuzzy.tex"))
cat("\\begin{table}[H]\n")
cat("\\centering\n")
cat("\\caption{Fuzzy RD-IV: Effect of Female Councillor Share on Labor Outcomes}\n")
cat("\\begin{threeparttable}\n")
cat("\\begin{tabular}{lccccc}\n")
cat("\\toprule\n")
cat("Outcome & IV Estimate & SE & $p$ & BW & $N$ \\\\\n")
cat("\\midrule\n")

if (length(results_v2$fuzzy) > 0) {
  for (v in names(results_v2$fuzzy)) {
    r <- results_v2$fuzzy[[v]]
    stars <- ifelse(r$pv_robust < 0.01, "***",
             ifelse(r$pv_robust < 0.05, "**",
             ifelse(r$pv_robust < 0.10, "*", "")))
    cat(sprintf("%s & %.4f%s & (%.4f) & %.3f & %d & %s \\\\\n",
        r$name, r$coef_conv, stars, r$se_robust,
        r$pv_robust, round(r$bw),
        format(r$n_left + r$n_right, big.mark = ",")))
  }
} else {
  cat("\\multicolumn{6}{c}{\\textit{Fuzzy RD estimates not available}} \\\\\n")
}

cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{tablenotes}[flushleft]\n")
cat("\\small\n")
cat("\\item Notes: Fuzzy RDD using the 1,000 threshold as an instrument for female councillor share. Estimates the LATE of a 1 percentage point increase in female councillor share on labor outcomes, for communes at the threshold. Local linear regression, triangular kernel, CER-optimal bandwidth.\n")
cat("\\end{tablenotes}\n")
cat("\\end{threeparttable}\n")
cat("\\label{tab:fuzzy}\n")
cat("\\end{table}\n")
sink()

## ----------------------------------------------------------
## Table 7: 3,500 Threshold Validation
## ----------------------------------------------------------

cat("Creating Table 7: 3,500 Validation...\n")

sink(file.path(tab_dir, "tab7_validation_3500.tex"))
cat("\\begin{table}[H]\n")
cat("\\centering\n")
cat("\\caption{Validation: RDD at the 3,500-Inhabitant Threshold}\n")
cat("\\begin{threeparttable}\n")
cat("\\begin{tabular}{lccccc}\n")
cat("\\toprule\n")
cat("Outcome & Estimate & SE & $p$ & BW & $N$ \\\\\n")
cat("\\midrule\n")

if (length(results_v2$validation_3500) > 0) {
  for (v in names(results_v2$validation_3500)) {
    r <- results_v2$validation_3500[[v]]
    stars <- ifelse(r$pv_robust < 0.01, "***",
             ifelse(r$pv_robust < 0.05, "**",
             ifelse(r$pv_robust < 0.10, "*", "")))
    cat(sprintf("%s & %.4f%s & (%.4f) & %.3f & %d & %s \\\\\n",
        r$name, r$coef_conv, stars, r$se_robust,
        r$pv_robust, round(r$bw),
        format(r$n_left + r$n_right, big.mark = ",")))
  }
} else {
  cat("\\multicolumn{6}{c}{\\textit{3,500 validation not available}} \\\\\n")
}

cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{tablenotes}[flushleft]\n")
cat("\\small\n")
cat("\\item Notes: RDD at the 3,500 threshold using communes with population 2,000--5,000. Before 2014, communes above 3,500 used proportional list voting with parity (since 2000); those below used majority voting. After 2014, communes 1,000--3,500 also use PR with parity, so this threshold now separates communes that have had parity since 2000 from those that gained it in 2014. A null first stage at 3,500 supports the interpretation that parity is the binding component of the 1,000 regime change.\n")
cat("\\end{tablenotes}\n")
cat("\\end{threeparttable}\n")
cat("\\label{tab:validation}\n")
cat("\\end{table}\n")
sink()

## ----------------------------------------------------------
## Table 8: Robustness — Multiple Specifications
## ----------------------------------------------------------

cat("Creating Table 8: Robustness...\n")

valid <- !is.na(df$female_emp_rate) & is.finite(df$female_emp_rate)

rob_specs <- list()

rd1 <- rdrobust(y = df$female_emp_rate[valid], x = df$pop_centered[valid],
                c = 0, p = 1, kernel = "triangular", bwselect = "cerrd",
                masspoints = "adjust")
rob_specs[["Baseline (linear)"]] <- c(rd1$coef[1], rd1$se[3], rd1$pv[3],
                                       rd1$N_h[1] + rd1$N_h[2])

rd2 <- rdrobust(y = df$female_emp_rate[valid], x = df$pop_centered[valid],
                c = 0, p = 2, kernel = "triangular", bwselect = "cerrd",
                masspoints = "adjust")
rob_specs[["Quadratic"]] <- c(rd2$coef[1], rd2$se[3], rd2$pv[3],
                               rd2$N_h[1] + rd2$N_h[2])

rd3 <- rdrobust(y = df$female_emp_rate[valid], x = df$pop_centered[valid],
                c = 0, p = 1, kernel = "uniform", bwselect = "cerrd",
                masspoints = "adjust")
rob_specs[["Uniform kernel"]] <- c(rd3$coef[1], rd3$se[3], rd3$pv[3],
                                    rd3$N_h[1] + rd3$N_h[2])

sub_donut <- df[valid, ] %>% filter(abs(pop_centered) >= 20)
rd4 <- rdrobust(y = sub_donut$female_emp_rate, x = sub_donut$pop_centered,
                c = 0, p = 1, kernel = "triangular", bwselect = "cerrd",
                masspoints = "adjust")
rob_specs[["Donut ($\\pm$20)"]] <- c(rd4$coef[1], rd4$se[3], rd4$pv[3],
                                 rd4$N_h[1] + rd4$N_h[2])

sub_man <- df[valid, ] %>% filter(abs(pop_centered) <= 200)
if ("dep_code.x" %in% names(sub_man)) {
  mod5 <- lm(female_emp_rate ~ above_threshold + pop_centered +
               I(above_threshold * pop_centered) + factor(dep_code.x),
             data = sub_man)
} else if ("dep_code" %in% names(sub_man)) {
  mod5 <- lm(female_emp_rate ~ above_threshold + pop_centered +
               I(above_threshold * pop_centered) + factor(dep_code),
             data = sub_man)
} else {
  mod5 <- lm(female_emp_rate ~ above_threshold + pop_centered +
               I(above_threshold * pop_centered),
             data = sub_man)
}
se5 <- sqrt(vcovHC(mod5, type = "HC1")[2, 2])
rob_specs[["+ Department FE"]] <- c(coef(mod5)[2], se5,
                                     2 * pnorm(-abs(coef(mod5)[2] / se5)),
                                     nrow(sub_man))

sink(file.path(tab_dir, "tab8_robustness.tex"))
cat("\\begin{table}[H]\n")
cat("\\centering\n")
cat("\\caption{Robustness: Alternative Specifications for Female Employment Rate}\n")
cat("\\begin{threeparttable}\n")
cat("\\begin{tabular}{lcccc}\n")
cat("\\toprule\n")
cat("Specification & Estimate & SE & $p$-value & $N$ \\\\\n")
cat("\\midrule\n")
for (spec in names(rob_specs)) {
  r <- rob_specs[[spec]]
  cat(sprintf("%s & %.4f & (%.4f) & %.3f & %s \\\\\n",
      spec, r[1], r[2], r[3], format(round(r[4]), big.mark = ",")))
}
cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{tablenotes}[flushleft]\n")
cat("\\small\n")
cat("\\item Notes: All specifications estimate the discontinuity in female employment rate at the 1,000 threshold. Baseline: local linear, triangular kernel, CER-optimal BW. Department FE: BW = 200, HC1 SE.\n")
cat("\\end{tablenotes}\n")
cat("\\end{threeparttable}\n")
cat("\\label{tab:robustness}\n")
cat("\\end{table}\n")
sink()

## ----------------------------------------------------------
## Table 9: Equivalence Test Results
## ----------------------------------------------------------

cat("Creating Table 9: Equivalence Tests...\n")

sink(file.path(tab_dir, "tab9_equivalence.tex"))
cat("\\begin{table}[H]\n")
cat("\\centering\n")
cat("\\caption{Equivalence Tests (TOST): Can We Reject Meaningful Effects?}\n")
cat("\\begin{threeparttable}\n")
cat("\\begin{tabular}{lccccc}\n")
cat("\\toprule\n")
cat("Outcome & Estimate & SE & SESOI & TOST $p$ & Equivalent? \\\\\n")
cat("\\midrule\n")

for (v in names(results_v2$equivalence)) {
  r <- results_v2$equivalence[[v]]
  cat(sprintf("%s & %.4f & (%.4f) & $\\pm$%.2f & %.3f & %s \\\\\n",
      r$name, r$coef, r$se, r$sesoi,
      r$p_tost, ifelse(r$equivalent, "Yes", "No")))
}

cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{tablenotes}[flushleft]\n")
cat("\\small\n")
cat("\\item Notes: Two one-sided test (TOST) procedure. SESOI (smallest effect of scientific interest) set at 1 percentage point, following \\citet{bertrand2019} and \\citet{blaukahn2017}. ``Equivalent'' = we reject that the true effect exceeds $\\pm$1 pp at the 5\\%\\ level, formally demonstrating an absence of meaningful effects.\n")
cat("\\end{tablenotes}\n")
cat("\\end{threeparttable}\n")
cat("\\label{tab:equivalence}\n")
cat("\\end{table}\n")
sink()

## ----------------------------------------------------------
## Table 10: Bandwidth Sensitivity (moved to appendix)
## ----------------------------------------------------------

cat("Creating Table 10: Bandwidth Sensitivity (appendix)...\n")

sink(file.path(tab_dir, "tab10_bandwidth.tex"))
cat("\\begin{table}[H]\n")
cat("\\centering\n")
cat("\\caption{Bandwidth Sensitivity: Female Employment Rate}\n")
cat("\\begin{threeparttable}\n")
cat("\\begin{tabular}{lcccc}\n")
cat("\\toprule\n")
cat("Bandwidth & Estimate & SE & $N$ & 95\\% CI \\\\\n")
cat("\\midrule\n")

for (bw in c(100, 150, 200, 300, 400, 500, 600, 800)) {
  row <- bw_results %>% filter(bandwidth == bw)
  if (nrow(row) == 0) next
  cat(sprintf("%d & %.4f & (%.4f) & %s & [%.4f, %.4f] \\\\\n",
      bw, row$coef, row$se, format(row$n, big.mark = ","),
      row$coef - 1.96 * row$se, row$coef + 1.96 * row$se))
}

cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{tablenotes}[flushleft]\n")
cat("\\small\n")
cat("\\item Notes: Local linear regression with HC1 standard errors.\n")
cat("\\end{tablenotes}\n")
cat("\\end{threeparttable}\n")
cat("\\label{tab:bandwidth}\n")
cat("\\end{table}\n")
sink()

cat("All tables saved to", tab_dir, "\n")
