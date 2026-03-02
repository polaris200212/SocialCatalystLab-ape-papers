###############################################################################
# 06_tables.R — Generate all tables for the paper
# Paper: Fear and Punitiveness in America
# APEP Working Paper apep_0313
###############################################################################

source("00_packages.R")

df <- readRDS("../data/gss_analysis.rds")
results_summary <- readRDS("../data/results_summary.rds")
ols_comparison <- readRDS("../data/ols_comparison.rds")

tab_dir <- "../tables"
dir.create(tab_dir, showWarnings = FALSE)

###############################################################################
# Table 1: Summary Statistics
###############################################################################

cat("=== Table 1: Summary Statistics ===\n")

# By treatment group
sum_stats <- df %>%
  group_by(Treatment = factor(afraid, levels = c(0, 1),
                              labels = c("Not Afraid", "Afraid"))) %>%
  summarise(
    N = n(),
    `Age` = mean(age, na.rm = TRUE),
    `Female (%)` = mean(female, na.rm = TRUE) * 100,
    `Black (%)` = mean(black, na.rm = TRUE) * 100,
    `Education (years)` = mean(educ_years, na.rm = TRUE),
    `College+ (%)` = mean(college, na.rm = TRUE) * 100,
    `Married (%)` = mean(married, na.rm = TRUE) * 100,
    `Parent Educ (years)` = mean(parent_educ_avg, na.rm = TRUE),
    `Real Income ($)` = mean(realinc, na.rm = TRUE),
    `Conservative (%)` = mean(conservative, na.rm = TRUE) * 100,
    `Urban (%)` = mean(urban, na.rm = TRUE) * 100,
    `Death Pen. Support (%)` = mean(favor_deathpen, na.rm = TRUE) * 100,
    `Courts Lenient (%)` = mean(courts_too_lenient, na.rm = TRUE) * 100,
    `More Crime Spend (%)` = mean(want_more_crime_spending, na.rm = TRUE) * 100,
    .groups = "drop"
  ) %>%
  mutate(across(where(is.numeric) & !matches("^N$"),
                ~ round(., 1)))

# Also add overall column
overall <- df %>%
  summarise(
    Treatment = "Overall",
    N = n(),
    `Age` = round(mean(age, na.rm = TRUE), 1),
    `Female (%)` = round(mean(female, na.rm = TRUE) * 100, 1),
    `Black (%)` = round(mean(black, na.rm = TRUE) * 100, 1),
    `Education (years)` = round(mean(educ_years, na.rm = TRUE), 1),
    `College+ (%)` = round(mean(college, na.rm = TRUE) * 100, 1),
    `Married (%)` = round(mean(married, na.rm = TRUE) * 100, 1),
    `Parent Educ (years)` = round(mean(parent_educ_avg, na.rm = TRUE), 1),
    `Real Income ($)` = round(mean(realinc, na.rm = TRUE), 1),
    `Conservative (%)` = round(mean(conservative, na.rm = TRUE) * 100, 1),
    `Urban (%)` = round(mean(urban, na.rm = TRUE) * 100, 1),
    `Death Pen. Support (%)` = round(mean(favor_deathpen, na.rm = TRUE) * 100, 1),
    `Courts Lenient (%)` = round(mean(courts_too_lenient, na.rm = TRUE) * 100, 1),
    `More Crime Spend (%)` = round(mean(want_more_crime_spending, na.rm = TRUE) * 100, 1)
  )

sum_stats_all <- bind_rows(sum_stats, overall)

# LaTeX output
sum_long <- sum_stats_all %>%
  pivot_longer(-Treatment, names_to = "Variable", values_to = "Value") %>%
  pivot_wider(names_from = Treatment, values_from = Value)

latex_lines <- c(
  "\\begin{table}[htbp]",
  "\\centering",
  "\\caption{Summary Statistics by Treatment Status}",
  "\\label{tab:summary_stats}",
  "\\begin{tabular}{lccc}",
  "\\hline\\hline",
  "Variable & Not Afraid & Afraid & Overall \\\\",
  "\\hline"
)

for (i in 1:nrow(sum_long)) {
  v <- sum_long$Variable[i]
  na_val <- sum_long$`Not Afraid`[i]
  a_val <- sum_long$Afraid[i]
  o_val <- sum_long$Overall[i]

  if (v == "N") {
    latex_lines <- c(latex_lines,
                     sprintf("$N$ & %s & %s & %s \\\\", format(na_val, big.mark = ","),
                             format(a_val, big.mark = ","), format(o_val, big.mark = ",")))
  } else if (grepl("Income", v)) {
    latex_lines <- c(latex_lines,
                     sprintf("%s & \\$%s & \\$%s & \\$%s \\\\", v,
                             format(round(na_val), big.mark = ","),
                             format(round(a_val), big.mark = ","),
                             format(round(o_val), big.mark = ",")))
  } else {
    latex_lines <- c(latex_lines,
                     sprintf("%s & %.1f & %.1f & %.1f \\\\", v, na_val, a_val, o_val))
  }

  if (v %in% c("Urban (%)", "N")) {
    latex_lines <- c(latex_lines, "\\hline")
  }
}

latex_lines <- c(latex_lines,
                 "\\hline\\hline",
                 "\\end{tabular}",
                 "\\begin{tablenotes}",
                 "\\small",
                 "\\item \\textit{Notes:} Data from the General Social Survey, 1973--2024.",
                 "Treatment is defined as reporting fear of walking alone at night near home.",
                 "Real income in 2024 dollars.",
                 "\\end{tablenotes}",
                 "\\end{table}")

writeLines(latex_lines, file.path(tab_dir, "tab1_summary_stats.tex"))
cat("Saved: tab1_summary_stats.tex\n")

###############################################################################
# Table 2: Main AIPW Results
###############################################################################

cat("=== Table 2: Main AIPW Results ===\n")

main_res <- results_summary %>% filter(type == "Main")
placebo_res <- results_summary %>% filter(type == "Placebo")

latex_main <- c(
  "\\begin{table}[htbp]",
  "\\centering",
  "\\caption{Effect of Fear of Crime on Punitive Attitudes: AIPW Estimates}",
  "\\label{tab:main_results}",
  "\\begin{tabular}{lccccc}",
  "\\hline\\hline",
  " & ATE & SE & 95\\% CI & $p$-value & $N$ \\\\",
  "\\hline",
  "\\multicolumn{6}{l}{\\textit{Panel A: Crime-Related Attitudes (Main Outcomes)}} \\\\"
)

for (i in 1:nrow(main_res)) {
  r <- main_res[i, ]
  stars <- ifelse(r$p_value < 0.01, "***",
                  ifelse(r$p_value < 0.05, "**",
                         ifelse(r$p_value < 0.1, "*", "")))
  ci_str <- sprintf("[%.3f, %.3f]", r$ci_lo, r$ci_hi)
  latex_main <- c(latex_main,
                  sprintf("%s & %.4f%s & (%.4f) & %s & %.3f & %s \\\\",
                          r$outcome, r$ate, stars, r$se, ci_str, r$p_value,
                          format(r$n, big.mark = ",")))
}

latex_main <- c(latex_main,
                "\\hline",
                "\\multicolumn{6}{l}{\\textit{Panel B: Placebo Outcomes (Should Not Be Affected)}} \\\\")

for (i in 1:nrow(placebo_res)) {
  r <- placebo_res[i, ]
  stars <- ifelse(r$p_value < 0.01, "***",
                  ifelse(r$p_value < 0.05, "**",
                         ifelse(r$p_value < 0.1, "*", "")))
  ci_str <- sprintf("[%.3f, %.3f]", r$ci_lo, r$ci_hi)
  latex_main <- c(latex_main,
                  sprintf("%s & %.4f%s & (%.4f) & %s & %.3f & %s \\\\",
                          r$outcome, r$ate, stars, r$se, ci_str, r$p_value,
                          format(r$n, big.mark = ",")))
}

latex_main <- c(latex_main,
                "\\hline\\hline",
                "\\end{tabular}",
                "\\begin{tablenotes}",
                "\\small",
                "\\item \\textit{Notes:} Augmented Inverse Probability Weighting (AIPW) estimates",
                "using 5-fold cross-fitting with Super Learner (GLM + Random Forest).",
                "Controls include age (quadratic), sex, race, education, parents' education,",
                "marital status, children, real income, political views, urban/rural, region,",
                "year fixed effects, and national violent crime rate.",
                "Standard errors in parentheses.",
                "$^{***}p<0.01$, $^{**}p<0.05$, $^{*}p<0.1$.",
                "\\end{tablenotes}",
                "\\end{table}")

writeLines(latex_main, file.path(tab_dir, "tab2_main_results.tex"))
cat("Saved: tab2_main_results.tex\n")

###############################################################################
# Table 3: AIPW vs OLS Comparison
###############################################################################

cat("=== Table 3: AIPW vs OLS Comparison ===\n")

comparison <- results_summary %>%
  filter(type == "Main") %>%
  select(outcome, aipw_ate = ate, aipw_se = se) %>%
  left_join(
    ols_comparison %>%
      mutate(outcome = c("Death Penalty Support", "Courts Too Lenient",
                         "Want More Crime Spending")) %>%
      select(outcome, ols_ate = estimate, ols_se = se),
    by = "outcome"
  )

latex_comp <- c(
  "\\begin{table}[htbp]",
  "\\centering",
  "\\caption{Comparison of OLS and Doubly Robust Estimates}",
  "\\label{tab:ols_comparison}",
  "\\begin{tabular}{lcccc}",
  "\\hline\\hline",
  " & \\multicolumn{2}{c}{OLS} & \\multicolumn{2}{c}{AIPW} \\\\",
  "\\cmidrule(lr){2-3} \\cmidrule(lr){4-5}",
  "Outcome & Estimate & SE & Estimate & SE \\\\",
  "\\hline"
)

for (i in 1:nrow(comparison)) {
  r <- comparison[i, ]
  if (!is.na(r$ols_ate)) {
    latex_comp <- c(latex_comp,
                    sprintf("%s & %.4f & (%.4f) & %.4f & (%.4f) \\\\",
                            r$outcome, r$ols_ate, r$ols_se, r$aipw_ate, r$aipw_se))
  }
}

latex_comp <- c(latex_comp,
                "\\hline\\hline",
                "\\end{tabular}",
                "\\begin{tablenotes}",
                "\\small",
                "\\item \\textit{Notes:} OLS includes the same covariates as the AIPW propensity score model.",
                "AIPW uses 5-fold cross-fitting with Super Learner ensemble.",
                "\\end{tablenotes}",
                "\\end{table}")

writeLines(latex_comp, file.path(tab_dir, "tab3_ols_vs_aipw.tex"))
cat("Saved: tab3_ols_vs_aipw.tex\n")

cat("\n=== All Tables Generated ===\n")
