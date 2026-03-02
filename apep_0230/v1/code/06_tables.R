## 06_tables.R - Generate all tables
## Neighbourhood Planning and House Prices (apep_0228)

source("00_packages.R")

data_dir   <- "../data"
table_dir  <- "../tables"
dir.create(table_dir, showWarnings = FALSE, recursive = TRUE)

panel    <- readRDS(file.path(data_dir, "analysis_panel.rds"))
results  <- readRDS(file.path(data_dir, "main_results.rds"))
np       <- readRDS(file.path(data_dir, "np_clean.rds"))

tryCatch({
  robustness <- readRDS(file.path(data_dir, "robustness_results.rds"))
}, error = function(e) robustness <<- NULL)

## ─────────────────────────────────────────────────────────────
## Table 1: Summary Statistics
## ─────────────────────────────────────────────────────────────

make_summary_row <- function(x, label) {
  tibble(
    Variable = label,
    Mean = mean(x, na.rm = TRUE),
    SD = sd(x, na.rm = TRUE),
    Min = min(x, na.rm = TRUE),
    Max = max(x, na.rm = TRUE),
    N = sum(!is.na(x))
  )
}

## Overall
sum_overall <- bind_rows(
  make_summary_row(panel$median_price / 1000, "Median price (GBP 000s)"),
  make_summary_row(panel$mean_price / 1000, "Mean price (GBP 000s)"),
  make_summary_row(panel$n_transactions, "Transactions per year"),
  make_summary_row(panel$log_median_price, "Log median price"),
  make_summary_row(panel$treated, "Post-treatment indicator")
)

## By treatment status
sum_treated <- panel %>%
  filter(first_treat > 0) %>%
  summarise(
    across(c(median_price, mean_price, n_transactions, log_median_price),
           list(mean = ~mean(., na.rm = TRUE), sd = ~sd(., na.rm = TRUE)))
  )

sum_control <- panel %>%
  filter(first_treat == 0) %>%
  summarise(
    across(c(median_price, mean_price, n_transactions, log_median_price),
           list(mean = ~mean(., na.rm = TRUE), sd = ~sd(., na.rm = TRUE)))
  )

## Write LaTeX table
sink(file.path(table_dir, "tab1_summary.tex"))
cat("\\begin{table}[H]\n")
cat("\\centering\n")
cat("\\caption{Summary Statistics}\n")
cat("\\begin{threeparttable}\n")
cat("\\begin{tabular}{l S[table-format=6.1] S[table-format=6.1] S[table-format=7.0] S[table-format=7.0] S[table-format=5.0]}\n")
cat("\\toprule\n")
cat("Variable & {Mean} & {Std. Dev.} & {Min} & {Max} & {N} \\\\\n")
cat("\\midrule\n")

for (i in seq_len(nrow(sum_overall))) {
  row <- sum_overall[i, ]
  cat(sprintf("%s & %.1f & %.1f & %.0f & %.0f & %d \\\\\n",
              row$Variable, row$Mean, row$SD, row$Min, row$Max, row$N))
}

cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{tablenotes}[flushleft]\n")
cat("\\small\n")
cat(sprintf("\\item Notes: Panel of %d local authority districts observed annually from %d to %d. Treated districts (N=%d) are those with at least one neighbourhood plan adopted. Never-treated districts (N=%d) had no plan adopted by March 2024. Prices in thousands of GBP.\n",
            n_distinct(panel$district), min(panel$year), max(panel$year),
            n_distinct(panel$district[panel$first_treat > 0]),
            n_distinct(panel$district[panel$first_treat == 0])))
cat("\\end{tablenotes}\n")
cat("\\end{threeparttable}\n")
cat("\\label{tab:summary}\n")
cat("\\end{table}\n")
sink()
cat("Table 1 saved.\n")

## ─────────────────────────────────────────────────────────────
## Table 2: Main Results
## ─────────────────────────────────────────────────────────────

## Extract coefficients
twfe_coef <- coef(results$twfe_baseline)["treated"]
twfe_se <- sqrt(vcov(results$twfe_baseline)["treated", "treated"])
twfe_n <- nobs(results$twfe_baseline)

twfe_ctrl_coef <- coef(results$twfe_controls)["treated"]
twfe_ctrl_se <- sqrt(vcov(results$twfe_controls)["treated", "treated"])

cs_att <- results$cs_simple$overall.att
cs_se <- results$cs_simple$overall.se

cs_never_att <- results$cs_never_simple$overall.att
cs_never_se <- results$cs_never_simple$overall.se

## Stars function
stars <- function(coef, se) {
  pval <- 2 * pnorm(-abs(coef / se))
  if (pval < 0.01) return("***")
  if (pval < 0.05) return("**")
  if (pval < 0.10) return("*")
  return("")
}

sink(file.path(table_dir, "tab2_main_results.tex"))
cat("\\begin{table}[H]\n")
cat("\\centering\n")
cat("\\caption{Main Results: Effect of Neighbourhood Plans on House Prices}\n")
cat("\\begin{threeparttable}\n")
cat("\\begin{tabular}{lcccc}\n")
cat("\\toprule\n")
cat(" & (1) & (2) & (3) & (4) \\\\\n")
cat(" & TWFE & TWFE + Controls & CS (Not-Yet) & CS (Never) \\\\\n")
cat("\\midrule\n")

cat(sprintf("NP Adopted & %.4f%s & %.4f%s & %.4f%s & %.4f%s \\\\\n",
            twfe_coef, stars(twfe_coef, twfe_se),
            twfe_ctrl_coef, stars(twfe_ctrl_coef, twfe_ctrl_se),
            cs_att, stars(cs_att, cs_se),
            cs_never_att, stars(cs_never_att, cs_never_se)))
cat(sprintf(" & (%.4f) & (%.4f) & (%.4f) & (%.4f) \\\\\n",
            twfe_se, twfe_ctrl_se, cs_se, cs_never_se))
cat("\\\\\n")
cat(sprintf("Observations & %s & %s & %s & %s \\\\\n",
            format(twfe_n, big.mark = ","),
            format(nobs(results$twfe_controls), big.mark = ","),
            format(nrow(panel), big.mark = ","),
            format(nrow(panel), big.mark = ",")))
cat("District FE & Yes & Yes & -- & -- \\\\\n")
cat("Year FE & Yes & Yes & -- & -- \\\\\n")
cat("Estimator & TWFE & TWFE & CS (2021) & CS (2021) \\\\\n")
cat("Control group & All untreated & All untreated & Not-yet-treated & Never-treated \\\\\n")
cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{tablenotes}[flushleft]\n")
cat("\\small\n")
cat("\\item Notes: Dependent variable is log median house price at the local authority-year level. Columns (1)-(2) report TWFE estimates with district and year fixed effects, standard errors clustered at the district level. Columns (3)-(4) report Callaway and Sant'Anna (2021) doubly-robust estimates. \\sym{*} \\(p<0.10\\), \\sym{**} \\(p<0.05\\), \\sym{***} \\(p<0.01\\).\n")
cat("\\end{tablenotes}\n")
cat("\\end{threeparttable}\n")
cat("\\label{tab:main}\n")
cat("\\end{table}\n")
sink()
cat("Table 2 saved.\n")

## ─────────────────────────────────────────────────────────────
## Table 3: Robustness checks
## ─────────────────────────────────────────────────────────────

if (!is.null(robustness)) {
  sink(file.path(table_dir, "tab3_robustness.tex"))
  cat("\\begin{table}[H]\n")
  cat("\\centering\n")
  cat("\\caption{Robustness Checks}\n")
  cat("\\begin{threeparttable}\n")
  cat("\\begin{tabular}{lccc}\n")
  cat("\\toprule\n")
  cat("Specification & ATT & SE & Description \\\\\n")
  cat("\\midrule\n")

  specs <- list(
    list("Baseline (not-yet-treated)", results$cs_simple$overall.att, results$cs_simple$overall.se, "Main specification"),
    list("Never-treated controls", results$cs_never_simple$overall.att, results$cs_never_simple$overall.se, "Only never-treated as controls"),
    list("Log mean price", robustness$cs_mean_simple$overall.att, robustness$cs_mean_simple$overall.se, "Alternative outcome"),
    list("Log transactions", robustness$cs_trans_simple$overall.att, robustness$cs_trans_simple$overall.se, "Extensive margin"),
    list("1-year anticipation", robustness$cs_antic_simple$overall.att, robustness$cs_antic_simple$overall.se, "Allow 1-year anticipation"),
    list("Exclude London", robustness$cs_no_london_simple$overall.att, robustness$cs_no_london_simple$overall.se, "Drop London boroughs")
  )

  for (spec in specs) {
    cat(sprintf("%s & %.4f%s & (%.4f) & %s \\\\\n",
                spec[[1]], spec[[2]], stars(spec[[2]], spec[[3]]),
                spec[[3]], spec[[4]]))
  }

  cat("\\midrule\n")
  cat(sprintf("Randomization inference & \\multicolumn{2}{c}{$p = %.3f$} & 500 permutations \\\\\n",
              robustness$ri_pvalue))

  cat("\\bottomrule\n")
  cat("\\end{tabular}\n")
  cat("\\begin{tablenotes}[flushleft]\n")
  cat("\\small\n")
  cat("\\item Notes: All specifications use Callaway and Sant'Anna (2021) doubly-robust estimator unless noted. Dependent variable is log median house price at the local authority-year level. Randomization inference permutes treatment timing across districts. \\sym{*} \\(p<0.10\\), \\sym{**} \\(p<0.05\\), \\sym{***} \\(p<0.01\\).\n")
  cat("\\end{tablenotes}\n")
  cat("\\end{threeparttable}\n")
  cat("\\label{tab:robustness}\n")
  cat("\\end{table}\n")
  sink()
  cat("Table 3 saved.\n")
}

## ─────────────────────────────────────────────────────────────
## Table 4: Pre-treatment balance
## ─────────────────────────────────────────────────────────────

pre_panel <- panel %>%
  filter(year < 2013) %>%
  mutate(group = ifelse(first_treat > 0, "Treated", "Control"))

balance <- pre_panel %>%
  group_by(group) %>%
  summarise(
    `Median price (GBP 000s)` = mean(median_price / 1000, na.rm = TRUE),
    `Mean price (GBP 000s)` = mean(mean_price / 1000, na.rm = TRUE),
    `Transactions/year` = mean(n_transactions, na.rm = TRUE),
    `Log median price` = mean(log_median_price, na.rm = TRUE),
    N = n_distinct(district),
    .groups = "drop"
  )

sink(file.path(table_dir, "tab4_balance.tex"))
cat("\\begin{table}[H]\n")
cat("\\centering\n")
cat("\\caption{Pre-Treatment Balance (2008--2012)}\n")
cat("\\begin{threeparttable}\n")
cat("\\begin{tabular}{lcccc}\n")
cat("\\toprule\n")
cat(" & Treated & Control & Difference & $p$-value \\\\\n")
cat("\\midrule\n")

## Divide prices by 1000 for display consistency with Table 1
pre_panel <- pre_panel %>%
  mutate(median_price_k = median_price / 1000,
         mean_price_k = mean_price / 1000)

vars_to_test <- c("median_price_k", "mean_price_k", "n_transactions", "log_median_price")
var_labels <- c("Median price (GBP 000s)", "Mean price (GBP 000s)", "Transactions/year", "Log median price")

for (v in seq_along(vars_to_test)) {
  treated_vals <- pre_panel %>% filter(group == "Treated") %>% pull(!!sym(vars_to_test[v]))
  control_vals <- pre_panel %>% filter(group == "Control") %>% pull(!!sym(vars_to_test[v]))
  tt <- t.test(treated_vals, control_vals)

  ## Use more decimal places for log prices
  if (grepl("log", vars_to_test[v], ignore.case = TRUE)) {
    fmt <- "%s & %.3f & %.3f & %.3f & %.3f \\\\\n"
  } else {
    fmt <- "%s & %.0f & %.0f & %.0f & %.3f \\\\\n"
  }
  cat(sprintf(fmt,
              var_labels[v],
              mean(treated_vals, na.rm = TRUE),
              mean(control_vals, na.rm = TRUE),
              tt$estimate[1] - tt$estimate[2],
              tt$p.value))
}

cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{tablenotes}[flushleft]\n")
cat("\\small\n")
cat("\\item Notes: Pre-treatment means for 2008-2012. Treated = districts with at least one NP adopted by 2024. $p$-values from two-sample $t$-tests.\n")
cat("\\end{tablenotes}\n")
cat("\\end{threeparttable}\n")
cat("\\label{tab:balance}\n")
cat("\\end{table}\n")
sink()
cat("Table 4 saved.\n")

cat("\nAll tables generated.\n")
