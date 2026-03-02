## ============================================================================
## 06_tables.R — All tables for the paper
## APEP-0326: State Minimum Wage Increases and the HCBS Provider Supply Crisis
## ============================================================================

source("00_packages.R")

## ---- Load data ----
annual <- readRDS(file.path(DATA, "panel_annual.rds"))
results <- readRDS(file.path(DATA, "main_results.rds"))
robustness <- readRDS(file.path(DATA, "robustness_results.rds"))

treated_states <- annual[first_treat_year > 0, unique(state)]
control_states <- annual[first_treat_year == 0, unique(state)]

## ========================================================================
## TABLE 1: SUMMARY STATISTICS
## ========================================================================

cat("Table 1: Summary statistics...\n")

make_stats <- function(dt, label) {
  data.table(
    Group = label,
    `N (state-years)` = nrow(dt),
    `States` = uniqueN(dt$state),
    `Mean MW ($)` = sprintf("%.2f", mean(dt$min_wage, na.rm = TRUE)),
    `Mean Providers` = sprintf("%.0f", mean(dt$n_providers, na.rm = TRUE)),
    `Mean Benes (K)` = sprintf("%.1f", mean(dt$total_benes, na.rm = TRUE) / 1e3),
    `Mean Paid ($M)` = sprintf("%.1f", mean(dt$total_paid, na.rm = TRUE) / 1e6),
    `Mean Entry Rate` = sprintf("%.3f", mean(dt$entry_rate, na.rm = TRUE)),
    `Mean Exit Rate` = sprintf("%.3f", mean(dt$exit_rate, na.rm = TRUE))
  )
}

sumstats <- rbind(
  make_stats(annual, "All States"),
  make_stats(annual[state %in% treated_states], "MW-Increasing"),
  make_stats(annual[state %in% control_states], "Federal Minimum")
)

# LaTeX output
cat("\\begin{table}[ht]\n\\centering\n\\caption{Summary Statistics}\n")
cat("\\label{tab:sumstats}\n")
cat("\\begin{tabular}{lcccccccc}\n\\toprule\n")
cat(paste(names(sumstats), collapse = " & "), "\\\\\n\\midrule\n")
for (i in seq_len(nrow(sumstats))) {
  cat(paste(sumstats[i], collapse = " & "), "\\\\\n")
}
cat("\\bottomrule\n\\end{tabular}\n")
cat("\\begin{tablenotes}\\small\n")
cat("\\item \\textit{Notes:} Sample spans 2018--2024. MW-Increasing states raised their minimum wage above the federal level ($7.25) at some point during the sample. Federal Minimum states remained at $7.25 throughout. Providers are unique billing NPIs filing HCBS claims (T/H/S codes) in T-MSIS.\n")
cat("\\end{tablenotes}\n\\end{table}\n")

# Save as tex file
sink(file.path(TABLES, "tab1_sumstats.tex"))
cat("\\begin{table}[ht]\n\\centering\n\\caption{Summary Statistics}\n")
cat("\\label{tab:sumstats}\n")
cat("\\footnotesize\n")
cat("\\begin{tabular}{lcccccccc}\n\\toprule\n")
cat(" & N & States & Mean MW & Mean & Mean Benes & Mean Paid & Entry & Exit \\\\\n")
cat(" & (st-yrs) & & (\\$) & Providers & (thousands) & (\\$M) & Rate & Rate \\\\\n")
cat("\\midrule\n")
for (i in seq_len(nrow(sumstats))) {
  cat(paste(sumstats[i], collapse = " & "), "\\\\\n")
}
cat("\\bottomrule\n\\end{tabular}\n")
cat("\\begin{tablenotes}\\small\n")
cat("\\item \\textit{Notes:} Sample spans 2018--2024. MW-Increasing states raised their minimum wage above the federal level (\\$7.25) at some point during the sample period. Federal Minimum states remained at \\$7.25 throughout. Providers are unique billing NPIs filing HCBS claims (T/H/S procedure codes) in T-MSIS. Entry rate = new NPIs / total providers. Exit rate = departing NPIs / total providers.\n")
cat("\\end{tablenotes}\n\\end{table}\n")
sink()

## ========================================================================
## TABLE 2: MAIN TWFE RESULTS
## ========================================================================

cat("Table 2: Main TWFE results...\n")

sink(file.path(TABLES, "tab2_main_twfe.tex"))
etable(results$twfe[[1]], results$twfe[[2]], results$twfe[[3]], results$twfe[[4]],
       headers = c("Binary", "Log MW", "MW Premium", "+Controls"),
       fitstat = c("n", "r2"),
       se.below = TRUE,
       tex = TRUE,
       title = "Effect of Minimum Wage on HCBS Provider Supply",
       label = "tab:main_twfe",
       notes = "Dependent variable: log(HCBS providers). All specifications include state and year fixed effects. Standard errors clustered at the state level in parentheses. Binary = indicator for MW above federal minimum. Log MW = log of state minimum wage. MW Premium = state MW minus federal minimum ($7.25). +Controls adds state unemployment rate.")
sink()

## ========================================================================
## TABLE 3: MULTIPLE OUTCOMES
## ========================================================================

cat("Table 3: Multiple outcomes...\n")

sink(file.path(TABLES, "tab3_outcomes.tex"))
etable(results$twfe_outcomes[[1]], results$twfe_outcomes[[2]],
       results$twfe_outcomes[[3]], results$twfe_outcomes[[4]],
       results$twfe_outcomes[[5]], results$twfe_outcomes[[6]],
       headers = c("Providers", "Benes", "Entry", "Exit", "Individual", "Org"),
       fitstat = c("n", "r2"),
       se.below = TRUE,
       tex = TRUE,
       title = "Minimum Wage Effects Across HCBS Outcomes",
       label = "tab:outcomes",
       notes = "All specifications use log(MW) as the treatment variable with state and year fixed effects. Standard errors clustered at the state level. Columns 1--2: log outcomes. Columns 3--4: entry and exit rates. Columns 5--6: log providers by entity type (individual vs. organizational).")
sink()

## ========================================================================
## TABLE 4: ROBUSTNESS — DDD, PLACEBO, ALTERNATIVE SPECS
## ========================================================================

cat("Table 4: Robustness...\n")

sink(file.path(TABLES, "tab4_robustness.tex"))
etable(results$twfe[[2]], robustness$ddd, robustness$placebo,
       robustness$het_individual, robustness$het_org,
       robustness$excl_arpa,
       headers = c("Main", "DDD", "Placebo", "Individual", "Org", "Excl ARPA"),
       fitstat = c("n", "r2"),
       se.below = TRUE,
       tex = TRUE,
       title = "Robustness Checks",
       label = "tab:robustness",
       notes = "Column 1: baseline TWFE (log MW on log HCBS providers). Column 2: triple-difference (HCBS vs. non-HCBS × MW). Column 3: placebo test on non-HCBS Medicaid providers. Columns 4--5: by provider entity type. Column 6: excludes states with documented ARPA HCBS rate increases (NC, CO, VA, NM, NY, CA). State and year FE throughout. Standard errors clustered at state level.")
sink()

## ========================================================================
## TABLE 5: CS-DiD AGGREGATE RESULTS
## ========================================================================

cat("Table 5: CS-DiD results...\n")

cs_results <- tryCatch({
  cs_prov <- readRDS(file.path(DATA, "cs_providers.rds"))
  cs_benes_full <- tryCatch({
    att_gt(
      yname = "log_benes",
      tname = "year",
      idname = "state_id",
      gname = "first_treat_year",
      data = as.data.frame(annual[!is.na(log_benes)]),
      control_group = "nevertreated",
      anticipation = 0,
      base_period = "universal"
    )
  }, error = function(e) NULL)

  agg_prov <- aggte(cs_prov, type = "simple")
  agg_benes <- if (!is.null(cs_benes_full)) aggte(cs_benes_full, type = "simple") else NULL

  sink(file.path(TABLES, "tab5_csdd.tex"))
  cat("\\begin{table}[ht]\n\\centering\n")
  cat("\\caption{Callaway-Sant'Anna (2021) Aggregate ATT Estimates}\n")
  cat("\\label{tab:csdd}\n")
  cat("\\begin{tabular}{lcc}\n\\toprule\n")
  cat(" & Log Providers & Log Beneficiaries \\\\\n")
  cat("\\midrule\n")
  cat(sprintf("ATT & %.4f & %.4f \\\\\n", agg_prov$overall.att,
              ifelse(!is.null(agg_benes), agg_benes$overall.att, NA)))
  cat(sprintf(" & (%.4f) & (%.4f) \\\\\n", agg_prov$overall.se,
              ifelse(!is.null(agg_benes), agg_benes$overall.se, NA)))
  p_prov <- 2 * pnorm(-abs(agg_prov$overall.att / agg_prov$overall.se))
  p_benes <- if (!is.null(agg_benes)) 2 * pnorm(-abs(agg_benes$overall.att / agg_benes$overall.se)) else NA
  cat(sprintf("$p$-value & %.4f & %.4f \\\\\n", p_prov, p_benes))
  cat("\\midrule\n")
  cat("Control group & Never-treated & Never-treated \\\\\n")
  cat(sprintf("Treated cohorts & %d & %d \\\\\n",
              length(unique(cs_prov$group)), length(unique(cs_prov$group))))
  cat("\\bottomrule\n\\end{tabular}\n")
  cat("\\begin{tablenotes}\\small\n")
  cat("\\item \\textit{Notes:} Callaway and Sant'Anna (2021) heterogeneity-robust DiD estimator. Treatment cohort defined as the first year a state raised its minimum wage above \\$7.25. Never-treated states (those remaining at \\$7.25 throughout 2018--2024) serve as the comparison group. Standard errors in parentheses.\n")
  cat("\\end{tablenotes}\n\\end{table}\n")
  sink()
  cat("CS-DiD table saved.\n")
}, error = function(e) {
  cat("CS-DiD table skipped:", e$message, "\n")
})

cat("\n=== Tables complete ===\n")
cat("All tables saved to:", TABLES, "\n")
