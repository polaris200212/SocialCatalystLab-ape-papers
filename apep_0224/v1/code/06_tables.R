## ============================================================================
## 06_tables.R — Generate all LaTeX tables
## APEP Paper: School Suicide Prevention Training Mandates
## ============================================================================

source("00_packages.R")

data_dir   <- "../data"
table_dir  <- "../tables"
dir.create(table_dir, showWarnings = FALSE, recursive = TRUE)

panel <- read_csv(file.path(data_dir, "analysis_panel.csv"), show_col_types = FALSE)

## ============================================================================
## Table 1: Summary Statistics
## ============================================================================

cat("Creating Table 1: Summary statistics...\n")

# Overall and by treatment group
make_summary <- function(df, label) {
  df %>%
    summarise(
      group = label,
      n_states = n_distinct(state),
      n_obs = n(),
      mean_suicide = mean(suicide_aadr, na.rm = TRUE),
      sd_suicide = sd(suicide_aadr, na.rm = TRUE),
      mean_heart = mean(heart_aadr, na.rm = TRUE),
      sd_heart = sd(heart_aadr, na.rm = TRUE),
      mean_cancer = mean(cancer_aadr, na.rm = TRUE),
      sd_cancer = sd(cancer_aadr, na.rm = TRUE)
    )
}

sum_all     <- make_summary(panel, "Full Sample")
sum_treated <- make_summary(filter(panel, first_treat > 0), "Treated States")
sum_control <- make_summary(filter(panel, first_treat == 0), "Control States")

summary_table <- bind_rows(sum_all, sum_treated, sum_control)

# LaTeX output
tex1 <- c(
  "\\begin{table}[htbp]",
  "\\centering",
  "\\caption{Summary Statistics}",
  "\\label{tab:summary}",
  "\\begin{tabular}{lccc}",
  "\\toprule",
  " & Full Sample & Treated & Control \\\\",
  "\\midrule",
  sprintf("States & %d & %d & %d \\\\",
          summary_table$n_states[1], summary_table$n_states[2], summary_table$n_states[3]),
  sprintf("State-Years & %d & %d & %d \\\\",
          summary_table$n_obs[1], summary_table$n_obs[2], summary_table$n_obs[3]),
  "\\addlinespace",
  "\\multicolumn{4}{l}{\\textit{Age-Adjusted Death Rates (per 100,000)}} \\\\",
  sprintf("Suicide Rate & %.1f & %.1f & %.1f \\\\",
          summary_table$mean_suicide[1], summary_table$mean_suicide[2], summary_table$mean_suicide[3]),
  sprintf(" & (%.1f) & (%.1f) & (%.1f) \\\\",
          summary_table$sd_suicide[1], summary_table$sd_suicide[2], summary_table$sd_suicide[3]),
  sprintf("Heart Disease Rate & %.1f & %.1f & %.1f \\\\",
          summary_table$mean_heart[1], summary_table$mean_heart[2], summary_table$mean_heart[3]),
  sprintf(" & (%.1f) & (%.1f) & (%.1f) \\\\",
          summary_table$sd_heart[1], summary_table$sd_heart[2], summary_table$sd_heart[3]),
  sprintf("Cancer Rate & %.1f & %.1f & %.1f \\\\",
          summary_table$mean_cancer[1], summary_table$mean_cancer[2], summary_table$mean_cancer[3]),
  sprintf(" & (%.1f) & (%.1f) & (%.1f) \\\\",
          summary_table$sd_cancer[1], summary_table$sd_cancer[2], summary_table$sd_cancer[3]),
  "\\bottomrule",
  "\\multicolumn{4}{p{0.8\\textwidth}}{\\footnotesize \\textit{Notes:} Standard deviations in parentheses. Treated states are those that adopted mandatory school suicide prevention training before 2017. Age-adjusted death rates are from the CDC NCHS Leading Causes of Death database (1999--2017).} \\\\",
  "\\end{tabular}",
  "\\end{table}"
)

writeLines(tex1, file.path(table_dir, "tab1_summary.tex"))
cat("  Table 1 saved.\n")

## ============================================================================
## Table 2: Treatment Cohort Details
## ============================================================================

cat("Creating Table 2: Treatment cohorts...\n")

treatment <- read_csv(file.path(data_dir, "treatment_dates.csv"), show_col_types = FALSE)

tex2 <- c(
  "\\begin{table}[htbp]",
  "\\centering",
  "\\caption{State Adoption of Suicide Prevention Training Mandates}",
  "\\label{tab:adoption}",
  "\\begin{tabular}{lcc}",
  "\\toprule",
  "State & Effective Year & Treatment Year \\\\",
  "\\midrule"
)

for (i in seq_len(nrow(treatment))) {
  tex2 <- c(tex2, sprintf("%s & %d & %d \\\\",
                          treatment$state[i], treatment$effective_year[i],
                          treatment$treatment_year[i]))
}

tex2 <- c(tex2,
  "\\bottomrule",
  "\\multicolumn{3}{p{0.7\\textwidth}}{\\footnotesize \\textit{Notes:} Treatment year equals the first full calendar year after the law's effective date. Sources: Lang et al.\\ (2024), Jason Foundation.} \\\\",
  "\\end{tabular}",
  "\\end{table}"
)

writeLines(tex2, file.path(table_dir, "tab2_adoption.tex"))
cat("  Table 2 saved.\n")

## ============================================================================
## Table 3: Main Results
## ============================================================================

cat("Creating Table 3: Main results...\n")

main_results <- read_csv(file.path(data_dir, "main_results.csv"), show_col_types = FALSE)

# Format stars
add_stars <- function(pval) {
  if (is.na(pval)) return("")
  if (pval < 0.01) return("$^{***}$")
  if (pval < 0.05) return("$^{**}$")
  if (pval < 0.10) return("$^{*}$")
  return("")
}

n_obs <- nrow(panel)
n_states <- n_distinct(panel$state)
n_treated_states <- sum(panel$first_treat > 0 & panel$year == max(panel$year))

tex3 <- c(
  "\\begin{table}[htbp]",
  "\\centering",
  "\\caption{Effect of Suicide Prevention Training Mandates on Suicide Rates}",
  "\\label{tab:main_results}",
  "\\begin{tabular}{lcccc}",
  "\\toprule",
  " & (1) & (2) & (3) & (4) \\\\",
  " & CS-ATT & CS-ATT & TWFE & CS + Controls \\\\",
  " & Level & Log & Level & Level \\\\",
  "\\midrule"
)

for (i in seq_len(nrow(main_results))) {
  r <- main_results[i, ]
  stars <- add_stars(r$pvalue)
  tex3 <- c(tex3,
    sprintf("ATT & %.3f%s & %.4f%s & %.3f%s & %.3f%s \\\\",
            r$att, stars, r$att, stars, r$att, stars, r$att, stars))
  tex3 <- c(tex3,
    sprintf(" & (%.3f) & (%.4f) & (%.3f) & (%.3f) \\\\",
            r$se, r$se, r$se, r$se))
  break  # Only need one row per column
}

# Write proper multi-column table
tex3 <- c(
  "\\begin{table}[htbp]",
  "\\centering",
  "\\caption{Effect of Suicide Prevention Training Mandates on Suicide Rates}",
  "\\label{tab:main_results}",
  "\\begin{tabular}{lcccc}",
  "\\toprule",
  " & (1) & (2) & (3) & (4) \\\\",
  " & CS-ATT & CS-ATT & TWFE & CS + Controls \\\\",
  "\\midrule",
  "Outcome & Level & Log & Level & Level \\\\"
)

# Fill in actual values
for (i in seq_len(min(nrow(main_results), 4))) {
  r <- main_results[i, ]
  stars <- add_stars(r$pvalue)
  if (i == 1) {
    tex3 <- c(tex3, sprintf("\\addlinespace"))
    tex3 <- c(tex3, sprintf("ATT"))
  }
}

# Simpler approach: one row per specification
att_vals <- sapply(seq_len(min(nrow(main_results), 4)), function(i) {
  sprintf("%.3f%s", main_results$att[i], add_stars(main_results$pvalue[i]))
})
se_vals <- sapply(seq_len(min(nrow(main_results), 4)), function(i) {
  sprintf("(%.3f)", main_results$se[i])
})
ci_vals <- sapply(seq_len(min(nrow(main_results), 4)), function(i) {
  sprintf("[%.3f, %.3f]", main_results$ci_lower[i], main_results$ci_upper[i])
})

tex3 <- c(
  "\\begin{table}[htbp]",
  "\\centering",
  "\\caption{Effect of Suicide Prevention Training Mandates on Suicide Rates}",
  "\\label{tab:main_results}",
  "\\begin{tabular}{lcccc}",
  "\\toprule",
  " & (1) & (2) & (3) & (4) \\\\",
  " & CS-ATT & CS-ATT (Log) & TWFE & CS + Controls \\\\",
  "\\midrule",
  paste0("Treatment Effect & ", paste(att_vals, collapse = " & "), " \\\\"),
  paste0(" & ", paste(se_vals, collapse = " & "), " \\\\"),
  paste0("95\\% CI & ", paste(ci_vals, collapse = " & "), " \\\\"),
  "\\addlinespace",
  sprintf("Observations & %d & %d & %d & %d \\\\", n_obs, n_obs, n_obs, n_obs),
  sprintf("States & %d & %d & %d & %d \\\\", n_states, n_states, n_states, n_states),
  sprintf("Treated States & %d & %d & %d & %d \\\\",
          n_treated_states, n_treated_states, n_treated_states, n_treated_states),
  "Control Group & NYT & NYT & All & NYT \\\\",
  "Estimator & CS & CS & TWFE & CS \\\\",
  "Controls & No & No & No & Medicaid \\\\",
  "\\bottomrule",
  "\\multicolumn{5}{p{0.9\\textwidth}}{\\footnotesize \\textit{Notes:} $^{***}$p$<$0.01, $^{**}$p$<$0.05, $^{*}$p$<$0.10. CS-ATT = Callaway \\& Sant'Anna (2021) group-time average treatment effect on the treated, aggregated to an overall ATT. NYT = not-yet-treated control group. Column (2) uses the log of the age-adjusted suicide rate. Column (3) uses standard two-way fixed effects for comparison. Column (4) adds a Medicaid expansion indicator as a control. Standard errors clustered at the state level in parentheses.} \\\\",
  "\\end{tabular}",
  "\\end{table}"
)

writeLines(tex3, file.path(table_dir, "tab3_main_results.tex"))
cat("  Table 3 saved.\n")

## ============================================================================
## Table 4: Robustness checks
## ============================================================================

cat("Creating Table 4: Robustness...\n")

robust_file <- file.path(data_dir, "robustness_summary.csv")
if (file.exists(robust_file)) {
  robust <- read_csv(robust_file, show_col_types = FALSE)

  tex4 <- c(
    "\\begin{table}[htbp]",
    "\\centering",
    "\\caption{Robustness Checks}",
    "\\label{tab:robustness}",
    "\\begin{tabular}{lccc}",
    "\\toprule",
    "Specification & ATT & SE & $p$-value \\\\",
    "\\midrule"
  )

  for (i in seq_len(nrow(robust))) {
    r <- robust[i, ]
    tex4 <- c(tex4, sprintf("%s & %.3f & (%.3f) & %.3f \\\\",
                            r$check, r$att, r$se, r$pvalue))
  }

  tex4 <- c(tex4,
    "\\bottomrule",
    "\\multicolumn{4}{p{0.8\\textwidth}}{\\footnotesize \\textit{Notes:} All specifications use the Callaway \\& Sant'Anna (2021) estimator with not-yet-treated controls unless otherwise noted. Placebo outcomes (heart disease, cancer) should show null effects. Alternative timing codes treatment at the effective year rather than the first full post-effective year.} \\\\",
    "\\end{tabular}",
    "\\end{table}"
  )

  writeLines(tex4, file.path(table_dir, "tab4_robustness.tex"))
  cat("  Table 4 saved.\n")
}

cat("\nAll tables generated.\n")
