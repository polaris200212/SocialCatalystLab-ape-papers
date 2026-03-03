## =============================================================================
## apep_0488: The Welfare Cost of PDMPs — Sufficient Statistics Approach
## 06_tables.R: Generate all tables for the paper
## =============================================================================

source("00_packages.R")

results <- readRDS(file.path(DATA_DIR, "analysis_results.rds"))
panel <- readRDS(file.path(DATA_DIR, "panel_prescribing.rds"))
policy <- readRDS(file.path(DATA_DIR, "policy_dates.rds"))

## ---------------------------------------------------------------------------
## Table 1: Summary statistics
## ---------------------------------------------------------------------------
cat("=== Table 1: Summary statistics ===\n")

summ <- panel %>%
  mutate(treated = ifelse(!is.na(must_access_year), "Treated", "Never Treated")) %>%
  filter(is.na(must_access_year) | year < must_access_year) %>%
  group_by(treated) %>%
  summarise(
    n_states = n_distinct(state),
    n_state_years = n(),
    mean_opioid_rate = mean(opioid_rate, na.rm = TRUE),
    sd_opioid_rate = sd(opioid_rate, na.rm = TRUE),
    mean_opioid_share = mean(opioid_share, na.rm = TRUE),
    sd_opioid_share = sd(opioid_share, na.rm = TRUE),
    mean_la_share = mean(la_share_of_opioid, na.rm = TRUE),
    sd_la_share = sd(la_share_of_opioid, na.rm = TRUE),
    mean_prescribers = mean(n_prescribers, na.rm = TRUE),
    mean_opioid_prescribers = mean(n_opioid_prescribers, na.rm = TRUE),
    mean_prescriber_share = mean(opioid_prescriber_share, na.rm = TRUE),
    .groups = "drop"
  )

print(summ)
write.csv(summ, file.path(TAB_DIR, "tab1_summary_stats.csv"), row.names = FALSE)
cat("  Saved tab1_summary_stats.csv\n")

## ---------------------------------------------------------------------------
## Table 2: Main DiD results
## ---------------------------------------------------------------------------
cat("\n=== Table 2: Main DiD results ===\n")

tab2_data <- tibble(
  Outcome = c("Opioid prescribing rate (%)", "Opioid prescribing rate (%)",
              "Prescriber share", "Prescriber share",
              "Long-acting share", "Long-acting share"),
  Estimator = rep(c("CS-DiD", "TWFE"), 3),
  Coefficient = c(
    results$agg_overall$overall.att,
    coef(results$twfe_rate)["pdmp_active"],
    results$agg_prescriber$overall.att,
    coef(results$twfe_prescriber)["pdmp_active"],
    results$agg_la$overall.att,
    coef(results$twfe_la)["pdmp_active"]
  ),
  SE = c(
    results$agg_overall$overall.se,
    se(results$twfe_rate)["pdmp_active"],
    results$agg_prescriber$overall.se,
    se(results$twfe_prescriber)["pdmp_active"],
    results$agg_la$overall.se,
    se(results$twfe_la)["pdmp_active"]
  )
) %>%
  mutate(
    Stars = case_when(
      abs(Coefficient / SE) > 2.576 ~ "***",
      abs(Coefficient / SE) > 1.96 ~ "**",
      abs(Coefficient / SE) > 1.645 ~ "*",
      TRUE ~ ""
    )
  )

print(tab2_data)
write.csv(tab2_data, file.path(TAB_DIR, "tab2_main_did.csv"), row.names = FALSE)
cat("  Saved tab2_main_did.csv\n")

## ---------------------------------------------------------------------------
## Table 3: Welfare calibration under alternative models
## ---------------------------------------------------------------------------
cat("\n=== Table 3: Welfare calibration ===\n")

wp <- results$welfare_params
e_bar <- 500            # Externality per prevented Rx
lambda_target <- 0.70   # Share of Rx reduction on legitimate pain patients
v_L <- 7500             # Pain cost per legitimate patient denied

# Corrected welfare formula: Net = ē + γ(1-λ) - v_L·λ
gammas <- c(wp$gamma_rational, wp$gamma_moderate, wp$gamma_strong, wp$gamma_cue)
correction <- e_bar + gammas * (1 - lambda_target)
pain_cost <- v_L * lambda_target

tab3 <- tibble(
  Model = c("Rational Addiction (Becker-Murphy 1988)",
            "Moderate Present Bias (Gruber-Koszegi, beta=0.7)",
            "Strong Present Bias (beta=0.5)",
            "Cue-Triggered (Bernheim-Rangel 2004)"),
  Beta = c(1.0, 0.7, 0.5, 0.0),
  Correction = correction,
  Pain_Cost = rep(pain_cost, 4),
  Net_Welfare = correction - pain_cost,
  Sign = ifelse(
    correction - pain_cost > 0,
    "Positive (PDMP improves welfare)",
    "Negative (PDMP reduces welfare)"
  )
)

print(tab3)
write.csv(tab3, file.path(TAB_DIR, "tab3_welfare_calibration.csv"), row.names = FALSE)
cat("  Saved tab3_welfare_calibration.csv\n")

## ---------------------------------------------------------------------------
## Table 4: PDMP adoption dates
## ---------------------------------------------------------------------------
cat("\n=== Table 4: PDMP adoption dates ===\n")

tab4 <- policy %>%
  filter(!is.na(must_access_year)) %>%
  arrange(must_access_year, state) %>%
  select(State = state,
         `Must-Access Year` = must_access_year,
         `Naloxone Law` = naloxone_year,
         `Good Samaritan` = gsl_year)

write.csv(tab4, file.path(TAB_DIR, "tab4_pdmp_adoption.csv"), row.names = FALSE)
cat("  Saved tab4_pdmp_adoption.csv\n")

## ---------------------------------------------------------------------------
## Table 5: Robustness summary
## ---------------------------------------------------------------------------
cat("\n=== Table 5: Robustness summary ===\n")

if (file.exists(file.path(DATA_DIR, "robustness_results.rds"))) {
  rob <- readRDS(file.path(DATA_DIR, "robustness_results.rds"))

  tab5 <- tibble(
    Specification = c(
      "Main (CS-DiD, 2014+ cohorts)",
      "All cohorts (including 2012-2013)",
      "Sun-Abraham estimator",
      "TWFE (no CS correction)",
      "Excluding co-policy states",
      "Placebo: log(total prescribers)",
      "Placebo: log(total claims)"
    ),
    Coefficient = c(
      results$agg_overall$overall.att,
      rob$agg_all$overall.att,
      {sa_c <- coef(rob$sa_rate); mean(sa_c[grep("^year::[0-9]", names(sa_c))])},
      coef(results$twfe_rate)["pdmp_active"],
      coef(rob$twfe_no_copolicy)["pdmp_active"],
      coef(rob$twfe_prescribers)["pdmp_active"],
      coef(rob$twfe_total_claims)["pdmp_active"]
    ),
    SE = c(
      results$agg_overall$overall.se,
      rob$agg_all$overall.se,
      {sa_s <- se(rob$sa_rate); mean(sa_s[grep("^year::[0-9]", names(sa_s))])},
      se(results$twfe_rate)["pdmp_active"],
      se(rob$twfe_no_copolicy)["pdmp_active"],
      se(rob$twfe_prescribers)["pdmp_active"],
      se(rob$twfe_total_claims)["pdmp_active"]
    )
  )

  print(tab5)
  write.csv(tab5, file.path(TAB_DIR, "tab5_robustness.csv"), row.names = FALSE)
  cat("  Saved tab5_robustness.csv\n")
}

## ---------------------------------------------------------------------------
## Generate LaTeX table files
## ---------------------------------------------------------------------------
cat("\n=== Generating LaTeX tables ===\n")

if (exists("tab2_data")) {
  tex_lines <- c(
    "\\begin{table}[htbp]",
    "\\centering",
    "\\caption{Effect of Must-Access PDMP Mandates on Opioid Prescribing}",
    "\\label{tab:main_did}",
    "\\begin{adjustbox}{max width=\\textwidth}",
    "\\begin{tabular}{lcccc}",
    "\\toprule",
    "Outcome & Estimator & Coefficient & SE & Sig. \\\\",
    "\\midrule"
  )
  for (i in seq_len(nrow(tab2_data))) {
    tex_lines <- c(tex_lines, sprintf(
      "%s & %s & %.4f & (%.4f) & %s \\\\",
      tab2_data$Outcome[i], tab2_data$Estimator[i],
      tab2_data$Coefficient[i], tab2_data$SE[i], tab2_data$Stars[i]
    ))
  }
  tex_lines <- c(tex_lines,
    "\\bottomrule",
    "\\end{tabular}",
    "\\end{adjustbox}",
    "\\begin{minipage}{0.9\\textwidth}",
    "\\footnotesize\\textit{Notes:} CS-DiD = Callaway and Sant'Anna (2021) doubly robust estimator. TWFE = two-way fixed effects with state and year FE. Standard errors clustered at the state level. Main sample: states adopting must-access PDMPs 2014 or later, plus never-treated states. *** $p<0.01$, ** $p<0.05$, * $p<0.1$.",
    "\\end{minipage}",
    "\\end{table}"
  )
  writeLines(tex_lines, file.path(TAB_DIR, "tab2_main_did.tex"))
  cat("  Saved tab2_main_did.tex\n")
}

cat("\n=== All tables generated ===\n")
