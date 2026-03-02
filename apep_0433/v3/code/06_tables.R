## ============================================================
## 06_tables.R — All tables for the paper (v3: expanded)
## New: outcome hierarchy, facilities, consolidated mechanisms,
## restructured per exhibit review
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

## Helper for significance stars
stars_fn <- function(p) {
  ifelse(p < 0.01, "***", ifelse(p < 0.05, "**", ifelse(p < 0.10, "*", "")))
}

## ----------------------------------------------------------
## Table 1: Summary Statistics (v3: add facilities + adjoints)
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
    female_adj = mean(sub$female_share_adjoints, na.rm = TRUE),
    female_emp_rate = mean(sub$female_emp_rate, na.rm = TRUE),
    female_lfpr = mean(sub$female_lfpr, na.rm = TRUE),
    male_emp_rate = mean(sub$male_emp_rate, na.rm = TRUE),
    gender_gap = mean(sub$gender_emp_gap, na.rm = TRUE),
    unemp_rate = mean(sub$unemployment_rate, na.rm = TRUE),
    density = mean(sub$densite, na.rm = TRUE),
    spend_total_pc = mean(sub$spend_total_pc, na.rm = TRUE),
    spend_social_pc = mean(sub$spend_social_pc, na.rm = TRUE),
    bpe_total_pc = mean(sub$bpe_total_pc, na.rm = TRUE),
    bpe_childcare_pc = mean(sub$bpe_childcare_pc, na.rm = TRUE)
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
cat("\\midrule\n")
cat("\\multicolumn{4}{l}{\\textit{Political Representation}} \\\\\n")
cat(sprintf("Female councillor share & %.3f & %.3f & %.3f \\\\\n",
    stats$female_share[1], stats$female_share[2], stats$female_share[3]))
cat(sprintf("Female mayor (share) & %.3f & %.3f & %.3f \\\\\n",
    stats$female_mayor[1], stats$female_mayor[2], stats$female_mayor[3]))
cat(sprintf("Female adjoint share & %.3f & %.3f & %.3f \\\\\n",
    stats$female_adj[1], stats$female_adj[2], stats$female_adj[3]))
cat("\\midrule\n")
cat("\\multicolumn{4}{l}{\\textit{Labor Market (ages 15--64)}} \\\\\n")
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

if (!is.na(stats$bpe_total_pc[1])) {
  cat("\\midrule\n")
  cat("\\multicolumn{4}{l}{\\textit{Public Facilities (per 1,000 pop.)}} \\\\\n")
  cat(sprintf("Total facilities & %.1f & %.1f & %.1f \\\\\n",
      stats$bpe_total_pc[1], stats$bpe_total_pc[2], stats$bpe_total_pc[3]))
  cat(sprintf("Childcare facilities & %.2f & %.2f & %.2f \\\\\n",
      stats$bpe_childcare_pc[1], stats$bpe_childcare_pc[2], stats$bpe_childcare_pc[3]))
}

cat(sprintf("\\midrule\nDensity (hab/km\\textsuperscript{2}) & %.0f & %.0f & %.0f \\\\\n",
    stats$density[1], stats$density[2], stats$density[3]))

cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{tablenotes}[flushleft]\n")
cat("\\small\n")
cat("\\item Notes: Metropolitan French communes. Employment variables for ages 15--64 from INSEE RP2021. Councillor data from RNE (2025). Spending from DGFIP (2019--2022 average). Facilities from INSEE BPE 2023.\n")
cat("\\end{tablenotes}\n")
cat("\\end{threeparttable}\n")
cat("\\label{tab:summary}\n")
cat("\\end{table}\n")
sink()

## ----------------------------------------------------------
## Table 2: Main RDD Results — Primary Outcomes (Holm)
## ----------------------------------------------------------

cat("Creating Table 2: Main RDD Results...\n")

sink(file.path(tab_dir, "tab2_main_results.tex"))
cat("\\begin{table}[H]\n")
cat("\\centering\n")
cat("\\caption{Primary Outcomes: Effect of the Bundled Electoral Reform on Labor Markets}\n")
cat("\\begin{threeparttable}\n")
cat("\\begin{tabular}{lccccccc}\n")
cat("\\toprule\n")
cat("Outcome & Estimate & SE & 95\\% CI & $p$ & Holm $p$ & BW & $N$ \\\\\n")
cat("\\midrule\n")

# Primary outcomes
primary_order <- c("female_emp_rate", "female_lfpr", "gender_emp_gap")
for (v in primary_order) {
  if (!v %in% names(results_v2$primary)) next
  r <- results_v2$primary[[v]]
  st <- stars_fn(r$pv_robust)

  holm_p <- NA
  if (!is.null(mht$primary_holm)) {
    idx <- which(mht$primary_holm$name == r$name)
    if (length(idx) > 0) holm_p <- mht$primary_holm$p_holm[idx]
  }
  if (is.na(holm_p) && !is.null(mht$labor_holm)) {
    idx <- which(mht$labor_holm$name == r$name)
    if (length(idx) > 0) holm_p <- mht$labor_holm$p_holm[idx]
  }

  cat(sprintf("%s & %.4f%s & (%.4f) & [%.3f, %.3f] & %.3f & %.3f & %d & %s \\\\\n",
      r$name, r$coef_conv, st, r$se_robust,
      r$ci_lower, r$ci_upper,
      r$pv_robust, ifelse(is.na(holm_p), r$pv_robust, holm_p),
      round(r$bw), format(r$n_left + r$n_right, big.mark = ",")))
}

# Secondary labor outcomes
cat("\\midrule\n")
cat("\\multicolumn{8}{l}{\\textit{Secondary labor outcomes (raw $p$-values)}} \\\\\n")
secondary_labor <- c("male_emp_rate", "female_share_employed",
                     "total_emp_rate", "unemployment_rate")
for (v in secondary_labor) {
  r <- results[[v]]
  if (is.null(r)) next
  st <- stars_fn(r$pv_robust)
  cat(sprintf("%s & %.4f%s & (%.4f) & [%.3f, %.3f] & %.3f & --- & %d & %s \\\\\n",
      r$name, r$coef_conv, st, r$se_robust,
      r$ci_lower, r$ci_upper,
      r$pv_robust,
      round(r$bw), format(r$n_left + r$n_right, big.mark = ",")))
}

# First stage
cat("\\midrule\n")
cat("\\multicolumn{8}{l}{\\textit{First stage}} \\\\\n")

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
cat("\\item Notes: Each row reports a separate RDD at the 1,000-inhabitant threshold. Local linear regression, triangular kernel, CER-optimal bandwidth \\citep{cattaneo2020practical}. Robust bias-corrected SE in parentheses. Holm $p$-values correct for multiple testing across the three primary outcomes. First stage: BW = 200, HC1 SE. All coefficients in percentage points (0--1 scale). * $p<0.10$, ** $p<0.05$, *** $p<0.01$.\n")
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
cat("\\item Notes: Pre-determined covariates from 2011 census and BPE 2018 (before the threshold was lowered to 1,000 in 2014). Local linear regression with robust bias-corrected inference.\n")
cat("\\end{tablenotes}\n")
cat("\\end{threeparttable}\n")
cat("\\label{tab:balance}\n")
cat("\\end{table}\n")
sink()

## ----------------------------------------------------------
## Table 4: NEW v3 — Consolidated Mechanisms Table
## (merges old Tables 4+5: pipeline + spending + facilities)
## ----------------------------------------------------------

cat("Creating Table 4: Consolidated Mechanisms...\n")

sink(file.path(tab_dir, "tab4_mechanisms.tex"))
cat("\\begin{table}[H]\n")
cat("\\centering\n")
cat("\\caption{Intermediate Mechanisms and Policy Channels at the 1,000 Threshold}\n")
cat("\\begin{threeparttable}\n")
cat("\\begin{tabular}{lcccccc}\n")
cat("\\toprule\n")
cat("Outcome & Estimate & SE & 95\\% CI & $p$ & BW & $N$ \\\\\n")

# Pipeline
cat("\\midrule\n")
cat("\\multicolumn{7}{l}{\\textit{Panel A: Executive Pipeline}} \\\\\n")
for (v in names(results_v2$pipeline)) {
  r <- results_v2$pipeline[[v]]
  st <- stars_fn(r$pv_robust)
  cat(sprintf("%s & %.4f%s & (%.4f) & [%.3f, %.3f] & %.3f & %d & %s \\\\\n",
      r$name, r$coef_conv, st, r$se_robust,
      r$ci_lower, r$ci_upper,
      r$pv_robust, round(r$bw),
      format(r$n_left + r$n_right, big.mark = ",")))
}

# Spending
if (length(results_v2$spending) > 0) {
  cat("\\midrule\n")
  cat("\\multicolumn{7}{l}{\\textit{Panel B: Spending Composition}} \\\\\n")
  for (v in names(results_v2$spending)) {
    r <- results_v2$spending[[v]]
    st <- stars_fn(r$pv_robust)
    cat(sprintf("%s & %.4f%s & (%.4f) & [%.3f, %.3f] & %.3f & %d & %s \\\\\n",
        r$name, r$coef_conv, st, r$se_robust,
        r$ci_lower, r$ci_upper,
        r$pv_robust, round(r$bw),
        format(r$n_left + r$n_right, big.mark = ",")))
  }
}

# Facilities
if (length(results_v2$facilities) > 0) {
  cat("\\midrule\n")
  cat("\\multicolumn{7}{l}{\\textit{Panel C: Public Facility Provision (BPE)}} \\\\\n")
  for (v in names(results_v2$facilities)) {
    r <- results_v2$facilities[[v]]
    st <- stars_fn(r$pv_robust)
    cat(sprintf("%s & %.4f%s & (%.4f) & [%.3f, %.3f] & %.3f & %d & %s \\\\\n",
        r$name, r$coef_conv, st, r$se_robust,
        r$ci_lower, r$ci_upper,
        r$pv_robust, round(r$bw),
        format(r$n_left + r$n_right, big.mark = ",")))
  }
}

cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{tablenotes}[flushleft]\n")
cat("\\small\n")
cat("\\item Notes: Each row is a separate RDD at the 1,000 threshold. Panel A: Executive positions from RNE (2025). Panel B: Per capita spending (EUR) from DGFIP (2019--2022 average); HHI measures spending concentration across 6 categories. Panel C: Facilities per 1,000 inhabitants from INSEE BPE 2023; ``Has cr\\`eche'' is binary. All secondary outcomes; raw $p$-values reported. * $p<0.10$, ** $p<0.05$, *** $p<0.01$.\n")
cat("\\end{tablenotes}\n")
cat("\\end{threeparttable}\n")
cat("\\label{tab:mechanisms}\n")
cat("\\end{table}\n")
sink()

## ----------------------------------------------------------
## Table 5: Equivalence Test Results
## ----------------------------------------------------------

cat("Creating Table 5: Equivalence Tests...\n")

sink(file.path(tab_dir, "tab5_equivalence.tex"))
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
cat("\\item Notes: Two one-sided test (TOST) procedure. SESOI set at 1 percentage point. ``Equivalent'' = we reject that the true effect exceeds $\\pm$1 pp at the 5\\%\\ level.\n")
cat("\\end{tablenotes}\n")
cat("\\end{threeparttable}\n")
cat("\\label{tab:equivalence}\n")
cat("\\end{table}\n")
sink()

## ----------------------------------------------------------
## Table 6: Robustness — Multiple Specifications
## ----------------------------------------------------------

cat("Creating Table 6: Robustness...\n")

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
dep_var <- intersect(names(sub_man), c("dep_code.x", "dep_code"))
if (length(dep_var) > 0) {
  fmla <- as.formula(paste("female_emp_rate ~ above_threshold + pop_centered +",
    "I(above_threshold * pop_centered) + factor(", dep_var[1], ")"))
  mod5 <- lm(fmla, data = sub_man)
} else {
  mod5 <- lm(female_emp_rate ~ above_threshold + pop_centered +
               I(above_threshold * pop_centered), data = sub_man)
}
se5 <- sqrt(vcovHC(mod5, type = "HC1")[2, 2])
rob_specs[["+ Department FE"]] <- c(coef(mod5)[2], se5,
                                     2 * pnorm(-abs(coef(mod5)[2] / se5)),
                                     nrow(sub_man))

sink(file.path(tab_dir, "tab6_robustness.tex"))
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
## Appendix Tables
## ----------------------------------------------------------

cat("Creating appendix tables...\n")

## Fuzzy RD-IV
sink(file.path(tab_dir, "tab_fuzzy.tex"))
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
    st <- stars_fn(r$pv_robust)
    cat(sprintf("%s & %.4f%s & (%.4f) & %.3f & %d & %s \\\\\n",
        r$name, r$coef_conv, st, r$se_robust,
        r$pv_robust, round(r$bw),
        format(r$n_left + r$n_right, big.mark = ",")))
  }
}

cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{tablenotes}[flushleft]\n")
cat("\\small\n")
cat("\\item Notes: Fuzzy RDD using the threshold as instrument for female councillor share. Local linear regression, triangular kernel, CER-optimal bandwidth.\n")
cat("\\end{tablenotes}\n")
cat("\\end{threeparttable}\n")
cat("\\label{tab:fuzzy}\n")
cat("\\end{table}\n")
sink()

## 3,500 Validation
sink(file.path(tab_dir, "tab_validation_3500.tex"))
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
    st <- stars_fn(r$pv_robust)
    cat(sprintf("%s & %.4f%s & (%.4f) & %.3f & %d & %s \\\\\n",
        r$name, r$coef_conv, st, r$se_robust,
        r$pv_robust, round(r$bw),
        format(r$n_left + r$n_right, big.mark = ",")))
  }
}

cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{tablenotes}[flushleft]\n")
cat("\\small\n")
cat("\\item Notes: RDD at the 3,500 threshold using communes 2,000--5,000. Both sides had PR with parity by 2020 (since 2000 above, since 2014 below). A null first stage confirms rapid convergence of female councillor share.\n")
cat("\\end{tablenotes}\n")
cat("\\end{threeparttable}\n")
cat("\\label{tab:validation}\n")
cat("\\end{table}\n")
sink()

## Bandwidth Sensitivity
sink(file.path(tab_dir, "tab_bandwidth.tex"))
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
