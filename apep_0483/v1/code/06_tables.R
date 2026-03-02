###############################################################################
# 06_tables.R — Generate all tables
# apep_0483: Teacher Pay Austerity and Student Achievement in England
###############################################################################

source("00_packages.R")

data_dir <- "../data/"
tab_dir <- "../tables/"
dir.create(tab_dir, showWarnings = FALSE, recursive = TRUE)

panel <- fread(paste0(data_dir, "analysis_panel.csv"))
la_avg <- fread(paste0(data_dir, "la_analysis_sample.csv"))
aipw_data <- fread(paste0(data_dir, "aipw_sample.csv"))
treat_df <- fread(paste0(data_dir, "treatment_assignment.csv"))
main_results <- readRDS(paste0(data_dir, "main_results.rds"))
robustness <- readRDS(paste0(data_dir, "robustness_results.rds"))

###############################################################################
# Table 1: Summary statistics
###############################################################################

cat("Table 1: Summary statistics...\n")

sum_vars <- c("att8_mean", "comp_change", "comp_pct_change",
              "mean_comp", "base_pay", "base_comp",
              "fsm_gap_mean", "basics_94_mean")

sum_labels <- c("Attainment 8 score (post-2021 mean)",
                "Competitiveness change (2010-2019)",
                "Competitiveness change (%)",
                "Mean competitiveness ratio (post-2021)",
                "Baseline private-sector pay (2010, £)",
                "Baseline competitiveness ratio (2010)",
                "FSM achievement gap (post-2021)",
                "English+Maths basics 9-4 (%)")

tab1_rows <- list()
for (i in seq_along(sum_vars)) {
  v <- sum_vars[i]
  if (!(v %in% names(la_avg))) next

  all_vals <- la_avg[[v]]
  t_vals <- la_avg[treated == 1][[v]]
  c_vals <- la_avg[treated == 0][[v]]

  tab1_rows[[i]] <- data.table(
    Variable = sum_labels[i],
    `All` = sprintf("%.2f (%.2f)", mean(all_vals, na.rm = TRUE),
                    sd(all_vals, na.rm = TRUE)),
    `Treated` = sprintf("%.2f (%.2f)", mean(t_vals, na.rm = TRUE),
                        sd(t_vals, na.rm = TRUE)),
    `Control` = sprintf("%.2f (%.2f)", mean(c_vals, na.rm = TRUE),
                        sd(c_vals, na.rm = TRUE))
  )
}
tab1 <- rbindlist(tab1_rows)

# Add N row
tab1 <- rbind(tab1, data.table(
  Variable = "N (local authorities)",
  `All` = as.character(nrow(la_avg[!is.na(treated)])),
  `Treated` = as.character(sum(la_avg$treated == 1, na.rm = TRUE)),
  `Control` = as.character(sum(la_avg$treated == 0, na.rm = TRUE))
))

fwrite(tab1, paste0(tab_dir, "tab1_summary_stats.csv"))

# LaTeX version
tab1_tex <- kbl(tab1, format = "latex", booktabs = TRUE,
                caption = "Summary Statistics",
                label = "tab:summary") |>
  kable_styling(latex_options = c("hold_position")) |>
  add_header_above(c(" " = 1, "Sample" = 3))
writeLines(tab1_tex, paste0(tab_dir, "tab1_summary_stats.tex"))

###############################################################################
# Table 2: Balance table
###############################################################################

cat("Table 2: Balance table...\n")

bal_vars <- c("base_pay", "base_comp", "urban_proxy")
bal_labels <- c("Baseline private-sector pay (£)",
                "Baseline competitiveness ratio",
                "Urban proxy (above-median pay)")

bal_rows <- list()
for (i in seq_along(bal_vars)) {
  v <- bal_vars[i]
  if (!(v %in% names(la_avg))) next

  t_vals <- la_avg[treated == 1][[v]]
  c_vals <- la_avg[treated == 0][[v]]

  mu_t <- mean(t_vals, na.rm = TRUE)
  mu_c <- mean(c_vals, na.rm = TRUE)
  sd_pool <- sqrt((var(t_vals, na.rm = TRUE) + var(c_vals, na.rm = TRUE)) / 2)
  smd <- (mu_t - mu_c) / sd_pool

  # T-test
  tt <- t.test(t_vals, c_vals)

  bal_rows[[i]] <- data.table(
    Variable = bal_labels[i],
    `Treated Mean` = sprintf("%.1f", mu_t),
    `Control Mean` = sprintf("%.1f", mu_c),
    Difference = sprintf("%.1f", mu_t - mu_c),
    SMD = sprintf("%.3f", smd),
    `p-value` = sprintf("%.3f", tt$p.value)
  )
}
tab2 <- rbindlist(bal_rows)

# Region distribution
region_tab <- la_avg[!is.na(treated), .N, by = .(treated, region)]
region_wide <- dcast(region_tab, region ~ treated, value.var = "N", fill = 0)
setnames(region_wide, c("Region", "Control", "Treated"))

fwrite(tab2, paste0(tab_dir, "tab2_balance.csv"))
fwrite(region_wide, paste0(tab_dir, "tab2b_region_balance.csv"))

tab2_tex <- kbl(tab2, format = "latex", booktabs = TRUE,
                caption = "Baseline Balance (2010 Characteristics)",
                label = "tab:balance") |>
  kable_styling(latex_options = c("hold_position"))
writeLines(tab2_tex, paste0(tab_dir, "tab2_balance.tex"))

###############################################################################
# Table 3: Main results
###############################################################################

cat("Table 3: Main results...\n")

# Create comparison table
main_tab <- data.table(
  Specification = c(
    "OLS (bivariate)",
    "OLS (+ covariates)",
    "OLS (+ region FE)",
    "DR-AIPW (logistic PS)",
    "DR-AIPW (Random Forest)",
    "Continuous (comp\\_change)",
    "Continuous (pct change)"
  ),
  Estimate = c(
    sprintf("%.2f", coef(main_results$ols_bivariate)["treated"]),
    sprintf("%.2f", coef(main_results$ols_covariates)["treated"]),
    sprintf("%.2f", coef(main_results$ols_region_fe)["treated"]),
    sprintf("%.2f", main_results$aipw_ate),
    sprintf("%.2f", main_results$aipw_rf_ate),
    sprintf("%.2f", coef(main_results$continuous)["comp_change"]),
    sprintf("%.3f", coef(main_results$continuous)["comp_change"] / 100)
  ),
  SE = c(
    sprintf("(%.2f)", coeftable(main_results$ols_bivariate)["treated", "Std. Error"]),
    sprintf("(%.2f)", coeftable(main_results$ols_covariates)["treated", "Std. Error"]),
    sprintf("(%.2f)", coeftable(main_results$ols_region_fe)["treated", "Std. Error"]),
    sprintf("(%.2f)", main_results$aipw_se),
    sprintf("(%.2f)", main_results$aipw_rf_se),
    sprintf("(%.2f)", coeftable(main_results$continuous)["comp_change", "Std. Error"]),
    sprintf("(%.3f)", coeftable(main_results$continuous)["comp_change", "Std. Error"] / 100)
  ),
  `p-value` = c(
    sprintf("%.3f", coeftable(main_results$ols_bivariate)["treated", "Pr(>|t|)"]),
    sprintf("%.3f", coeftable(main_results$ols_covariates)["treated", "Pr(>|t|)"]),
    sprintf("%.3f", coeftable(main_results$ols_region_fe)["treated", "Pr(>|t|)"]),
    sprintf("%.3f", main_results$aipw_p),
    sprintf("%.3f", main_results$aipw_rf_p),
    sprintf("%.3f", coeftable(main_results$continuous)["comp_change", "Pr(>|t|)"]),
    sprintf("%.3f", coeftable(main_results$continuous)["comp_change", "Pr(>|t|)"])
  ),
  N = c(
    as.character(nobs(main_results$ols_bivariate)),
    as.character(nobs(main_results$ols_covariates)),
    as.character(nobs(main_results$ols_region_fe)),
    as.character(nrow(aipw_data)),
    as.character(nrow(aipw_data)),
    as.character(nobs(main_results$continuous)),
    as.character(nobs(main_results$continuous))
  )
)

fwrite(main_tab, paste0(tab_dir, "tab3_main_results.csv"))

tab3_tex <- kbl(main_tab, format = "latex", booktabs = TRUE,
                escape = FALSE,
                caption = "Main Results: Effect of Teacher Pay Competitiveness on Student Achievement",
                label = "tab:main") |>
  kable_styling(latex_options = c("hold_position", "scale_down")) |>
  pack_rows("Binary treatment (Q1 vs Q2-Q4)", 1, 5) |>
  pack_rows("Continuous treatment", 6, 7)
writeLines(tab3_tex, paste0(tab_dir, "tab3_main_results.tex"))

###############################################################################
# Table 4: Robustness — alternative treatment definitions
###############################################################################

cat("Table 4: Robustness...\n")

ct_main <- coeftable(main_results$ols_covariates)
ct_med <- coeftable(robustness$median_split)
ct_ter <- coeftable(robustness$tercile_split)
ct_ext <- coeftable(robustness$extreme_quartiles)

rob_tab <- data.table(
  Specification = c(
    "Main (Q1 cutoff)",
    "Median split",
    "Tercile split",
    "Extreme quartiles (Q1 vs Q4)"
  ),
  Estimate = c(
    sprintf("%.2f", ct_main["treated", "Estimate"]),
    sprintf("%.2f", ct_med["treated_median", "Estimate"]),
    sprintf("%.2f", ct_ter["treated_tercile", "Estimate"]),
    sprintf("%.2f", ct_ext["treated_extreme", "Estimate"])
  ),
  SE = c(
    sprintf("(%.2f)", ct_main["treated", "Std. Error"]),
    sprintf("(%.2f)", ct_med["treated_median", "Std. Error"]),
    sprintf("(%.2f)", ct_ter["treated_tercile", "Std. Error"]),
    sprintf("(%.2f)", ct_ext["treated_extreme", "Std. Error"])
  ),
  `p-value` = c(
    sprintf("%.3f", ct_main["treated", "Pr(>|t|)"]),
    sprintf("%.3f", ct_med["treated_median", "Pr(>|t|)"]),
    sprintf("%.3f", ct_ter["treated_tercile", "Pr(>|t|)"]),
    sprintf("%.3f", ct_ext["treated_extreme", "Pr(>|t|)"])
  )
)

fwrite(rob_tab, paste0(tab_dir, "tab4_robustness.csv"))

tab4_tex <- kbl(rob_tab, format = "latex", booktabs = TRUE,
                caption = "Robustness: Alternative Treatment Definitions",
                label = "tab:robust") |>
  kable_styling(latex_options = c("hold_position"))
writeLines(tab4_tex, paste0(tab_dir, "tab4_robustness.tex"))

###############################################################################
# Table 5: Sensitivity analysis summary
###############################################################################

cat("Table 5: Sensitivity summary...\n")

ct_plac <- coeftable(robustness$placebo)

sens_tab <- data.table(
  Test = c(
    "Placebo (2005-2010 competitiveness change)",
    "Randomization inference p-value",
    "Oster (2019) delta",
    "E-value (point estimate)",
    "E-value (CI bound)",
    "Sensemakr RV\\_q",
    "Sensemakr RV\\_qa"
  ),
  Value = c(
    sprintf("%.2f (p=%.3f)", ct_plac["placebo_treated", "Estimate"],
            ct_plac["placebo_treated", "Pr(>|t|)"]),
    sprintf("%.3f", robustness$ri_pvalue),
    sprintf("%.2f", robustness$oster_delta),
    sprintf("%.2f", robustness$e_value),
    sprintf("%.2f", robustness$e_value_ci),
    sprintf("%.3f", robustness$sensemakr$sensitivity_stats$rv_q),
    sprintf("%.3f", robustness$sensemakr$sensitivity_stats$rv_qa)
  ),
  Interpretation = c(
    "Null placebo supports causal interpretation",
    "Exact p-value from 1,000 treatment permutations",
    "|delta|>1 suggests robust to proportional selection",
    "Required confounder strength to explain away point est.",
    "Required confounder strength to move CI to include 0",
    "Robustness value: % of variance to nullify",
    "Robustness value: % of variance to nullify at 5%"
  )
)

fwrite(sens_tab, paste0(tab_dir, "tab5_sensitivity.csv"))

tab5_tex <- kbl(sens_tab, format = "latex", booktabs = TRUE,
                escape = FALSE,
                caption = "Sensitivity Analysis Summary",
                label = "tab:sensitivity") |>
  kable_styling(latex_options = c("hold_position", "scale_down"))
writeLines(tab5_tex, paste0(tab_dir, "tab5_sensitivity.tex"))

###############################################################################
# Table 6: STPCD pay scales
###############################################################################

cat("Table 6: Teacher pay scales...\n")

stpcd <- fread(paste0(data_dir, "stpcd_pay_scales.csv"))

stpcd_display <- stpcd[, .(
  Year = year,
  `M1 (Starting, £)` = format(m1_rest, big.mark = ","),
  `M6 (Top main, £)` = format(m6_rest, big.mark = ","),
  `Midpoint (£)` = format(teacher_pay_mid, big.mark = ","),
  `Nominal growth (%)` = c(NA, round(diff(teacher_pay_mid) / head(teacher_pay_mid, -1) * 100, 1))
)]

fwrite(stpcd_display, paste0(tab_dir, "tab6_stpcd.csv"))

tab6_tex <- kbl(stpcd_display, format = "latex", booktabs = TRUE,
                caption = "Teacher Pay Scales (STPCD), Rest of England",
                label = "tab:stpcd") |>
  kable_styling(latex_options = c("hold_position"))
writeLines(tab6_tex, paste0(tab_dir, "tab6_stpcd.tex"))

cat("\n=== ALL TABLES SAVED ===\n")
cat(paste0("Output: ", normalizePath(tab_dir), "\n"))
list.files(tab_dir)
