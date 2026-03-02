## ============================================================================
## 06_tables.R — All tables for the paper
## Paper: When the Safety Net Frays (apep_0368)
## ============================================================================

source("00_packages.R")
DATA <- "../data"
TABS <- "../tables"
dir.create(TABS, showWarnings = FALSE, recursive = TRUE)

load(file.path(DATA, "02_analysis_data.RData"))
load(file.path(DATA, "03_results.RData"))
load(file.path(DATA, "04_robustness.RData"))

## ---- Table 1: Summary Statistics ----
cat("Table 1: Summary statistics...\n")

pre_stats <- panel[post == 0, .(
  `Mean Monthly Paid ($M)` = mean(total_paid) / 1e6,
  `SD Monthly Paid ($M)` = sd(total_paid) / 1e6,
  `Mean Monthly Claims (K)` = mean(total_claims) / 1e3,
  `Mean Active Providers` = mean(n_providers),
  `N State-Months` = .N
), by = .(Category = fifelse(service_cat == "BH",
                             "Behavioral Health", "HCBS"))]

post_stats <- panel[post == 1, .(
  `Mean Monthly Paid ($M)` = mean(total_paid) / 1e6,
  `SD Monthly Paid ($M)` = sd(total_paid) / 1e6,
  `Mean Monthly Claims (K)` = mean(total_claims) / 1e3,
  `Mean Active Providers` = mean(n_providers),
  `N State-Months` = .N
), by = .(Category = fifelse(service_cat == "BH",
                             "Behavioral Health", "HCBS"))]

tab1_pre <- kable(pre_stats, format = "latex", booktabs = TRUE, digits = 1,
                   caption = "Summary Statistics: Pre-Unwinding Period (Jan 2018 -- Mar 2023)",
                   label = "tab:summary_pre") %>%
  kable_styling(latex_options = "hold_position")

tab1_post <- kable(post_stats, format = "latex", booktabs = TRUE, digits = 1,
                    caption = "Summary Statistics: Post-Unwinding Period (Apr 2023 -- Dec 2024)",
                    label = "tab:summary_post") %>%
  kable_styling(latex_options = "hold_position")

writeLines(tab1_pre, file.path(TABS, "tab1_summary_pre.tex"))
writeLines(tab1_post, file.path(TABS, "tab1_summary_post.tex"))

## ---- Table 2: Main DDD Results ----
cat("Table 2: Main DDD results...\n")

models <- list(
  "Log Paid" = results$ddd_paid,
  "Log Claims" = results$ddd_claims,
  "Log Providers" = results$ddd_providers,
  "Exit Rate" = results$ddd_exit,
  "Net Entry" = results$ddd_entry,
  "Log HHI" = results$ddd_hhi
)

# Create coefficient map
cm <- c("post_bh" = "Post × Behavioral Health")

tab2 <- modelsummary(
  models,
  coef_map = cm,
  stars = c("*" = 0.1, "**" = 0.05, "***" = 0.01),
  gof_map = c("nobs", "r.squared"),
  output = "latex",
  title = "Triple-Difference Estimates: Behavioral Health vs. HCBS",
  notes = list(
    "State-clustered standard errors in parentheses.",
    "All specifications include state$\\times$month, category$\\times$month, and state$\\times$category fixed effects.",
    "$^{*}p<0.1$; $^{**}p<0.05$; $^{***}p<0.01$"
  )
)

writeLines(tab2, file.path(TABS, "tab2_main_ddd.tex"))

## ---- Table 3: Intensity DDD ----
cat("Table 3: Intensity DDD...\n")

models_int <- list(
  "Baseline DDD" = results$ddd_paid,
  "Intensity DDD" = results$ddd_intensity,
  "BH Only (Intensity)" = results$did_bh_intensity
)

cm_int <- c(
  "post_bh" = "Post × BH",
  "post_bh_intensity" = "Post × BH × Disenroll Rate",
  "post:disenroll_rate" = "Post × Disenroll Rate"
)

tab3 <- modelsummary(
  models_int,
  coef_map = cm_int,
  stars = c("*" = 0.1, "**" = 0.05, "***" = 0.01),
  gof_map = c("nobs", "r.squared"),
  output = "latex",
  title = "Dose-Response: Unwinding Intensity and Behavioral Health Spending"
)

writeLines(tab3, file.path(TABS, "tab3_intensity.tex"))

## ---- Table 4: Robustness ----
cat("Table 4: Robustness...\n")

models_rob <- list(
  "BH vs CPT (Placebo)" = rob_results$placebo_ddd,
  "Individual Providers" = rob_results$ddd_indiv,
  "Organizations" = rob_results$ddd_org,
  "High Procedural" = rob_results$ddd_high_proc,
  "Low Procedural" = rob_results$ddd_low_proc,
  "Pre-trend (2021)" = rob_results$ddd_pretrend
)

cm_rob <- c(
  "post_bh" = "Post × BH",
  "fake_post_bh" = "Fake Post × BH"
)

tab4 <- modelsummary(
  models_rob,
  coef_map = cm_rob,
  stars = c("*" = 0.1, "**" = 0.05, "***" = 0.01),
  gof_map = c("nobs", "r.squared"),
  output = "latex",
  title = "Robustness Checks and Heterogeneity Analysis"
)

writeLines(tab4, file.path(TABS, "tab4_robustness.tex"))

## ---- Table 5: Unwinding Variation ----
cat("Table 5: Unwinding variation...\n")

cohort_summary <- unwinding[, .(
  `N States` = .N,
  `Mean Disenroll Rate` = mean(disenroll_rate, na.rm = TRUE),
  `Mean Procedural Share` = mean(procedural_share, na.rm = TRUE)
), by = .(Cohort = format(unwind_start, "%B %Y"))]

tab5 <- kable(cohort_summary, format = "latex", booktabs = TRUE, digits = 2,
               caption = "Medicaid Unwinding Cohorts: Timing and Intensity",
               label = "tab:unwinding") %>%
  kable_styling(latex_options = "hold_position")

writeLines(tab5, file.path(TABS, "tab5_unwinding.tex"))

cat("\n=== All tables saved to", TABS, "===\n")
