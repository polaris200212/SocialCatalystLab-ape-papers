## ============================================================================
## 06_tables.R — All table generation
## apep_0491: Do Red Flag Laws Reduce Violent Crime?
## ============================================================================

source("00_packages.R")
DATA <- "../data"
TABLES <- "../tables"
dir.create(TABLES, showWarnings = FALSE)

panel <- readRDS(file.path(DATA, "analysis_panel_clean.rds"))
results <- readRDS(file.path(DATA, "main_results.rds"))
robustness <- readRDS(file.path(DATA, "robustness_results.rds"))

## ============================================================================
## TABLE 1: Summary Statistics
## ============================================================================

cat("=== Table 1: Summary Statistics ===\n")

summ_vars <- c("murder_rate", "assault_agg_rate", "robbery_rate",
                "violent_rate", "property_rate", "population")

## Pre-treatment means (before any state adopted = pre-1999)
pre_all <- panel[year < 1999 | (treated == FALSE), .(
  variable = summ_vars,
  mean_all = sapply(summ_vars, function(v) mean(panel[[v]], na.rm = TRUE)),
  sd_all   = sapply(summ_vars, function(v) sd(panel[[v]], na.rm = TRUE))
)]

## By treatment group (pre-treatment period: 2000-2015 for most)
pre_panel <- panel[year >= 2000 & year <= 2015]
summ_treated <- pre_panel[treated == TRUE, lapply(.SD, function(x) mean(x, na.rm = TRUE)),
                           .SDcols = summ_vars]
summ_control <- pre_panel[treated == FALSE, lapply(.SD, function(x) mean(x, na.rm = TRUE)),
                           .SDcols = summ_vars]
summ_treated_sd <- pre_panel[treated == TRUE, lapply(.SD, function(x) sd(x, na.rm = TRUE)),
                              .SDcols = summ_vars]
summ_control_sd <- pre_panel[treated == FALSE, lapply(.SD, function(x) sd(x, na.rm = TRUE)),
                              .SDcols = summ_vars]

## Build table
summ_table <- data.table(
  Variable = c("Murder rate", "Aggravated assault rate", "Robbery rate",
                "Total violent crime rate", "Property crime rate", "Population"),
  `ERPO states (mean)` = unlist(summ_treated),
  `ERPO states (SD)` = unlist(summ_treated_sd),
  `Non-ERPO states (mean)` = unlist(summ_control),
  `Non-ERPO states (SD)` = unlist(summ_control_sd)
)

## Write LaTeX
summ_tex <- kbl(summ_table, format = "latex", booktabs = TRUE,
                digits = 2, caption = "Summary Statistics: Pre-Treatment Means (2000--2015)",
                label = "tab:summary") |>
  kable_styling(latex_options = "hold_position") |>
  add_header_above(c(" " = 1, "ERPO States" = 2, "Non-ERPO States" = 2)) |>
  footnote(general = "Crime rates per 100,000 population. ERPO states are those that adopted ERPO laws by 2024 (N=21). Pre-treatment period defined as 2000--2015 (before the 2016--2018 adoption wave). Population in raw numbers.",
           threeparttable = TRUE)

writeLines(summ_tex, file.path(TABLES, "tab1_summary.tex"))
cat("Saved tab1_summary.tex\n")

## ============================================================================
## TABLE 2: Main Results — CS-DiD
## ============================================================================

cat("\n=== Table 2: Main Results ===\n")

main_table <- data.table(
  Outcome = c("Murder rate", "Agg. assault rate", "Robbery rate",
              "Total violent rate", "Property rate (placebo)"),
  ATT = c(results$agg_murder$overall.att,
          results$agg_assault$overall.att,
          results$agg_robbery$overall.att,
          results$agg_violent$overall.att,
          results$agg_property$overall.att),
  SE = c(results$agg_murder$overall.se,
         results$agg_assault$overall.se,
         results$agg_robbery$overall.se,
         results$agg_violent$overall.se,
         results$agg_property$overall.se)
)

main_table[, p_value := 2 * pnorm(-abs(ATT / SE))]
main_table[, stars := fcase(
  p_value < 0.01, "***",
  p_value < 0.05, "**",
  p_value < 0.10, "*",
  default = ""
)]
main_table[, `ATT (SE)` := sprintf("%.3f%s\n(%.3f)", ATT, stars, SE)]
main_table[, `Pre-trend p` := "—"]  # Will be filled from event study

## Baseline means for effect size
baseline_means <- panel[treated == TRUE & year < 2018, .(
  murder_mean  = mean(murder_rate, na.rm = TRUE),
  assault_mean = mean(assault_agg_rate, na.rm = TRUE),
  robbery_mean = mean(robbery_rate, na.rm = TRUE),
  violent_mean = mean(violent_rate, na.rm = TRUE),
  property_mean = mean(property_rate, na.rm = TRUE)
)]

main_table[, `% effect` := sprintf("%.1f%%",
  ATT / c(baseline_means$murder_mean, baseline_means$assault_mean,
          baseline_means$robbery_mean, baseline_means$violent_mean,
          baseline_means$property_mean) * 100)]

## Write LaTeX
main_tex <- kbl(main_table[, .(Outcome, `ATT (SE)`, `% effect`, `Pre-trend p`)],
                format = "latex", booktabs = TRUE,
                caption = "Effect of ERPO Laws on Crime Rates: Callaway \\& Sant'Anna DiD",
                label = "tab:main", escape = FALSE) |>
  kable_styling(latex_options = "hold_position") |>
  pack_rows("Violent crime outcomes", 1, 4) |>
  pack_rows("Placebo outcome", 5, 5) |>
  footnote(general = "ATT = overall average treatment effect on the treated from Callaway \\& Sant'Anna (2021) with doubly-robust estimation and never-treated controls. Standard errors clustered at the state level in parentheses. \\% effect calculated relative to pre-2018 treated-state mean. * p<0.10, ** p<0.05, *** p<0.01.",
           threeparttable = TRUE, escape = FALSE)

writeLines(main_tex, file.path(TABLES, "tab2_main_results.tex"))
cat("Saved tab2_main_results.tex\n")

## ============================================================================
## TABLE 3: TWFE vs CS-DiD Comparison
## ============================================================================

cat("\n=== Table 3: TWFE vs CS-DiD ===\n")

twfe_coefs <- data.table(
  Outcome = c("Murder rate", "Agg. assault rate", "Violent rate", "Property rate"),
  TWFE_coef = c(coef(results$twfe_murder)["postTRUE"],
                coef(results$twfe_assault)["postTRUE"],
                coef(results$twfe_violent)["postTRUE"],
                coef(results$twfe_property)["postTRUE"]),
  TWFE_se = c(summary(results$twfe_murder)$coeftable["postTRUE", "Std. Error"],
              summary(results$twfe_assault)$coeftable["postTRUE", "Std. Error"],
              summary(results$twfe_violent)$coeftable["postTRUE", "Std. Error"],
              summary(results$twfe_property)$coeftable["postTRUE", "Std. Error"]),
  CS_att = c(results$agg_murder$overall.att,
             results$agg_assault$overall.att,
             results$agg_violent$overall.att,
             results$agg_property$overall.att),
  CS_se = c(results$agg_murder$overall.se,
            results$agg_assault$overall.se,
            results$agg_violent$overall.se,
            results$agg_property$overall.se)
)

twfe_coefs[, `TWFE (SE)` := sprintf("%.3f\n(%.3f)", TWFE_coef, TWFE_se)]
twfe_coefs[, `CS-DiD (SE)` := sprintf("%.3f\n(%.3f)", CS_att, CS_se)]

comp_tex <- kbl(twfe_coefs[, .(Outcome, `TWFE (SE)`, `CS-DiD (SE)`)],
                format = "latex", booktabs = TRUE,
                caption = "TWFE vs. Callaway \\& Sant'Anna: Comparison of Estimates",
                label = "tab:twfe_comp", escape = FALSE) |>
  kable_styling(latex_options = "hold_position") |>
  footnote(general = "TWFE = standard two-way fixed effects with state and year FE. CS-DiD = Callaway \\& Sant'Anna (2021) doubly-robust estimator with never-treated controls. TWFE estimates may be biased under treatment effect heterogeneity.",
           threeparttable = TRUE, escape = FALSE)

writeLines(comp_tex, file.path(TABLES, "tab3_twfe_comparison.tex"))
cat("Saved tab3_twfe_comparison.tex\n")

## ============================================================================
## TABLE 4: Robustness Summary
## ============================================================================

cat("\n=== Table 4: Robustness ===\n")

rob_table <- data.table(
  Specification = c(
    "Baseline (never-treated)",
    "Not-yet-treated controls",
    "Drop 2021",
    "Pre-COVID (2000--2019)",
    "Drop 2018 cohort",
    "Log murder rate",
    "Family-petition states only",
    "LE-only states only"
  ),
  ATT = c(
    results$agg_murder$overall.att,
    robustness$nyt$overall.att,
    robustness$no2021$overall.att,
    robustness$precovid$overall.att,
    robustness$no2018$overall.att,
    robustness$log_murder$overall.att,
    results$agg_family$overall.att,
    results$agg_le$overall.att
  ),
  SE = c(
    results$agg_murder$overall.se,
    robustness$nyt$overall.se,
    robustness$no2021$overall.se,
    robustness$precovid$overall.se,
    robustness$no2018$overall.se,
    robustness$log_murder$overall.se,
    results$agg_family$overall.se,
    results$agg_le$overall.se
  )
)

rob_table[, p_value := 2 * pnorm(-abs(ATT / SE))]
rob_table[, stars := fcase(
  p_value < 0.01, "***",
  p_value < 0.05, "**",
  p_value < 0.10, "*",
  default = ""
)]
rob_table[, `ATT (SE)` := sprintf("%.3f%s (%.3f)", ATT, stars, SE)]

rob_tex <- kbl(rob_table[, .(Specification, `ATT (SE)`)],
               format = "latex", booktabs = TRUE,
               caption = "Robustness: Murder Rate ATT Across Specifications",
               label = "tab:robustness", escape = FALSE) |>
  kable_styling(latex_options = "hold_position") |>
  footnote(general = "All specifications use Callaway \\& Sant'Anna (2021) doubly-robust estimator unless noted. Standard errors clustered at state level. Log specification reports coefficient (multiply by 100 for approximate percentage). * p<0.10, ** p<0.05, *** p<0.01.",
           threeparttable = TRUE, escape = FALSE)

writeLines(rob_tex, file.path(TABLES, "tab4_robustness.tex"))
cat("Saved tab4_robustness.tex\n")

## ============================================================================
## TABLE 5: Heterogeneity by Petitioner Type
## ============================================================================

cat("\n=== Table 5: Heterogeneity ===\n")

het_table <- data.table(
  `Petitioner type` = c("All ERPO states", "Family + LE petition", "LE only"),
  `N states` = c(21, sum(unique(panel[petitioner_type == "family"])$state_abb %in% unique(panel$state_abb)),
                 sum(unique(panel[petitioner_type == "le"])$state_abb %in% unique(panel$state_abb))),
  ATT = c(results$agg_murder$overall.att,
          results$agg_family$overall.att,
          results$agg_le$overall.att),
  SE = c(results$agg_murder$overall.se,
         results$agg_family$overall.se,
         results$agg_le$overall.se)
)

het_table[, `ATT (SE)` := sprintf("%.3f (%.3f)", ATT, SE)]

het_tex <- kbl(het_table[, .(`Petitioner type`, `N states`, `ATT (SE)`)],
               format = "latex", booktabs = TRUE,
               caption = "Heterogeneity by Petitioner Type: Murder Rate",
               label = "tab:heterogeneity") |>
  kable_styling(latex_options = "hold_position") |>
  footnote(general = "Family + LE = states where both family members and law enforcement can petition for ERPOs. LE only = states where only law enforcement can petition (CT, IN, FL). CS-DiD with doubly-robust estimation and never-treated controls.",
           threeparttable = TRUE)

writeLines(het_tex, file.path(TABLES, "tab5_heterogeneity.tex"))
cat("Saved tab5_heterogeneity.tex\n")

cat("\nAll tables saved.\n")
