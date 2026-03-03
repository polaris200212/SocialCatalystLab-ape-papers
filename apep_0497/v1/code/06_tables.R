## =============================================================================
## 06_tables.R — Generate all LaTeX tables
## apep_0497: Who Captures a Tax Cut?
## =============================================================================

source("00_packages.R")

cat("=== GENERATING TABLES ===\n\n")

panel <- fread(file.path(data_dir, "analysis_panel.csv"))
main_results <- readRDS(file.path(data_dir, "main_results.rds"))
rob_results <- readRDS(file.path(data_dir, "robustness_results.rds"))

## =============================================================================
## Table 1: Summary Statistics
## =============================================================================

cat("--- Table 1: Summary Statistics ---\n")

sum_data <- panel[!is.na(th_rate_2017)]

## Pre/post split for summary stats
pre_data <- sum_data[year < 2018]
post_data <- sum_data[year >= 2018]

vars_full <- data.table(
  Variable = c("Median property price (euros)", "Price per m2, apartments (euros)",
               "Sales per commune-year", "Share apartments",
               "TH rate 2017 (%)"),
  `Pre Mean` = c(mean(pre_data$median_price, na.rm = TRUE),
                 mean(pre_data$price_m2_apt, na.rm = TRUE),
                 mean(pre_data$n_transactions, na.rm = TRUE),
                 mean(pre_data$share_apartments, na.rm = TRUE),
                 mean(pre_data$th_rate_2017, na.rm = TRUE)),
  `Pre SD` = c(sd(pre_data$median_price, na.rm = TRUE),
               sd(pre_data$price_m2_apt, na.rm = TRUE),
               sd(pre_data$n_transactions, na.rm = TRUE),
               sd(pre_data$share_apartments, na.rm = TRUE),
               sd(pre_data$th_rate_2017, na.rm = TRUE)),
  `Post Mean` = c(mean(post_data$median_price, na.rm = TRUE),
                  mean(post_data$price_m2_apt, na.rm = TRUE),
                  mean(post_data$n_transactions, na.rm = TRUE),
                  mean(post_data$share_apartments, na.rm = TRUE),
                  mean(post_data$th_rate_2017, na.rm = TRUE)),
  `Post SD` = c(sd(post_data$median_price, na.rm = TRUE),
                sd(post_data$price_m2_apt, na.rm = TRUE),
                sd(post_data$n_transactions, na.rm = TRUE),
                sd(post_data$share_apartments, na.rm = TRUE),
                sd(post_data$th_rate_2017, na.rm = TRUE))
)

tab1_tex <- kable(vars_full, format = "latex", booktabs = TRUE, digits = 1) |>
  kable_styling(latex_options = "hold_position")
## Strip table wrapper — paper.tex provides its own
tab1_tex <- gsub("\\\\begin\\{table\\}.*?\\\\centering", "", tab1_tex)
tab1_tex <- gsub("\\\\end\\{table\\}", "", tab1_tex)
tab1_tex <- gsub("\\\\caption\\{.*?\\}", "", tab1_tex)

writeLines(tab1_tex, file.path(tab_dir, "tab1_summary.tex"))
cat("  Saved tab1_summary.tex\n")

## =============================================================================
## Table 2: Main Results — Continuous DiD
## =============================================================================

cat("--- Table 2: Main results ---\n")

models_main <- list(
  "(1)" = main_results$m1,
  "(2)" = main_results$m2,
  "(3)" = main_results$m3,
  "(4)" = main_results$m4,
  "(5)" = main_results$vol
)

## Create coefficient map
cm <- c(
  "th_dose_std:post" = "TH Dose x Post",
  "share_apartments" = "Share Apartments"
)

## Generate table
tab2 <- modelsummary(
  models_main,
  coef_map = cm,
  gof_map = c("nobs", "r.squared"),
  stars = c("*" = 0.1, "**" = 0.05, "***" = 0.01),
  output = "latex_tabular",
  title = "Effect of TH Dose on Property Prices"
)

writeLines(as.character(tab2), file.path(tab_dir, "tab2_main_results.tex"))
cat("  Saved tab2_main_results.tex\n")

## =============================================================================
## Table 3: Robustness — Alternative Specifications
## =============================================================================

cat("--- Table 3: Robustness ---\n")

models_rob <- list()
if (!is.null(rob_results$donut))
  models_rob[["Donut\n(no 2018)"]] <- rob_results$donut
if (!is.null(rob_results$trim))
  models_rob[["Trimmed\n(5-95%)"]] <- rob_results$trim
if (!is.null(rob_results$antic))
  models_rob[["Anticipation\n(pre-2018)"]] <- rob_results$antic

if (length(models_rob) > 0) {
  tab3 <- modelsummary(
    models_rob,
    coef_map = c("th_dose_std:post" = "TH Dose x Post",
                 "th_dose_std:announced" = "TH Dose x Announced"),
    gof_map = c("nobs", "r.squared"),
    stars = c("*" = 0.1, "**" = 0.05, "***" = 0.01),
    output = "latex_tabular"
  )

  writeLines(as.character(tab3), file.path(tab_dir, "tab3_robustness.tex"))
  cat("  Saved tab3_robustness.tex\n")
}

## =============================================================================
## Table 4: Heterogeneity — Supply Elasticity and Property Type
## =============================================================================

cat("--- Table 4: Heterogeneity ---\n")

models_het <- list()
if (!is.null(rob_results$dense))
  models_het[["Dense\n(constrained)"]] <- rob_results$dense
if (!is.null(rob_results$sparse))
  models_het[["Sparse\n(elastic)"]] <- rob_results$sparse
if (!is.null(rob_results$apt))
  models_het[["Apartments\n(price/m2)"]] <- rob_results$apt
if (!is.null(rob_results$house))
  models_het[["Houses\n(median)"]] <- rob_results$house

if (length(models_het) > 0) {
  tab4 <- modelsummary(
    models_het,
    coef_map = c("th_dose_std:post" = "TH Dose x Post"),
    gof_map = c("nobs", "r.squared"),
    stars = c("*" = 0.1, "**" = 0.05, "***" = 0.01),
    output = "latex_tabular"
  )

  writeLines(as.character(tab4), file.path(tab_dir, "tab4_heterogeneity.tex"))
  cat("  Saved tab4_heterogeneity.tex\n")
}

## =============================================================================
## Table 5: Welfare Decomposition
## =============================================================================

cat("--- Table 5: Welfare decomposition ---\n")

## Get the APARTMENT coefficient (m4 = apartment price/m2, the headline result)
apt_coef <- coef(main_results$m4)[grep("th_dose_std:post", names(coef(main_results$m4)))]
if (length(apt_coef) > 0) {
  mean_th_rate <- mean(panel$th_rate_2017, na.rm = TRUE)
  sd_th_rate <- sd(panel$th_rate_2017, na.rm = TRUE)

  ## A 1-SD increase in TH dose → apt_coef × 100% price change
  pct_price_change <- apt_coef * 100
  mean_apt_price_m2 <- mean(panel$price_m2_apt, na.rm = TRUE)

  welfare <- data.table(
    Metric = c(
      "Apartment coefficient (TH dose x Post)",
      "Price effect per SD of TH dose (%)",
      "Mean TH rate 2017 (%)",
      "SD of TH rate 2017 (%)",
      "Total annual TH revenue abolished (billion euros)",
      "Mean apartment price per m2 (euros)",
      "Implied price increase per SD TH dose (%)"
    ),
    Value = c(
      round(apt_coef, 4),
      round(pct_price_change, 2),
      round(mean_th_rate, 2),
      round(sd_th_rate, 2),
      23.4,
      round(mean_apt_price_m2, 0),
      round(pct_price_change, 2)
    )
  )

  tab5_tex <- kable(welfare, format = "latex", booktabs = TRUE) |>
    kable_styling(latex_options = "hold_position")
  ## Strip table wrapper — paper.tex provides its own
  tab5_tex <- gsub("\\\\begin\\{table\\}.*?\\\\centering", "", tab5_tex)
  tab5_tex <- gsub("\\\\end\\{table\\}", "", tab5_tex)
  tab5_tex <- gsub("\\\\caption\\{.*?\\}", "", tab5_tex)

  writeLines(tab5_tex, file.path(tab_dir, "tab5_welfare.tex"))
  cat("  Saved tab5_welfare.tex\n")
}

cat("\n=== ALL TABLES GENERATED ===\n")
cat("Files in", tab_dir, ":\n")
print(list.files(tab_dir))
