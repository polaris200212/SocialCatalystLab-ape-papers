##############################################################################
# 06_tables.R — LaTeX tables for paper
# Paper: Does Place-Based Climate Policy Work? (apep_0418)
##############################################################################

source("code/00_packages.R")

cat("=== STEP 6: Generating LaTeX tables ===\n\n")

rdd_sample <- readRDS(file.path(DATA_DIR, "rdd_sample.rds"))

###############################################################################
# Table 1: Summary Statistics
###############################################################################
cat("--- Table 1: Summary Statistics ---\n")

# Split by treatment status
treated <- rdd_sample %>% filter(energy_community)
control <- rdd_sample %>% filter(!energy_community)

sum_vars <- c("ff_share", "total_emp", "total_estab", "unemp_rate",
              "pop", "med_income", "pct_bachelors", "pct_white",
              "post_ira_mw_per_1000emp", "clean_mw_per_1000emp")

var_labels <- c(
  "Fossil Fuel Employment (\\%)",
  "Total Employment",
  "N Establishments",
  "Unemployment Rate (\\%)",
  "Population",
  "Median Household Income (\\$)",
  "Bachelor's Degree (\\%)",
  "White Population (\\%)",
  "Post-IRA Clean Energy (MW/1000 emp.)",
  "Total Clean Energy (MW/1000 emp.)"
)

make_stats <- function(df, vars) {
  sapply(vars, function(v) {
    x <- df[[v]]
    if (is.null(x) || all(is.na(x))) return(c(NA, NA, NA))
    c(mean = mean(x, na.rm = TRUE),
      sd = sd(x, na.rm = TRUE),
      n = sum(!is.na(x)))
  })
}

stats_treated <- make_stats(treated, sum_vars)
stats_control <- make_stats(control, sum_vars)
stats_full <- make_stats(rdd_sample, sum_vars)

# Build LaTeX table
tex_lines <- c(
  "\\begin{table}[htbp]",
  "\\centering",
  "\\caption{Summary Statistics: Energy Community vs.\\ Non-Energy Community Areas}",
  "\\label{tab:summary_stats}",
  "\\small",
  "\\begin{tabular}{lcccccc}",
  "\\toprule",
  " & \\multicolumn{2}{c}{Energy Community} & \\multicolumn{2}{c}{Non-EC} & \\multicolumn{2}{c}{Full Sample} \\\\",
  "\\cmidrule(lr){2-3} \\cmidrule(lr){4-5} \\cmidrule(lr){6-7}",
  " & Mean & SD & Mean & SD & Mean & SD \\\\"
)

tex_lines <- c(tex_lines, "\\midrule",
  "\\multicolumn{7}{l}{\\textit{Running Variable}} \\\\")

for (i in seq_along(sum_vars)) {
  # Add section headers
  if (i == 2) tex_lines <- c(tex_lines, "\\addlinespace", "\\multicolumn{7}{l}{\\textit{Area Characteristics}} \\\\")
  if (i == 9) tex_lines <- c(tex_lines, "\\addlinespace", "\\multicolumn{7}{l}{\\textit{Outcome Variables}} \\\\")
  v <- sum_vars[i]
  lab <- var_labels[i]
  t_mean <- ifelse(is.na(stats_treated["mean", v]), "--",
                   formatC(stats_treated["mean", v], format = "f", digits = 2, big.mark = ","))
  t_sd <- ifelse(is.na(stats_treated["sd", v]), "--",
                 paste0("(", formatC(stats_treated["sd", v], format = "f", digits = 2, big.mark = ","), ")"))
  c_mean <- ifelse(is.na(stats_control["mean", v]), "--",
                   formatC(stats_control["mean", v], format = "f", digits = 2, big.mark = ","))
  c_sd <- ifelse(is.na(stats_control["sd", v]), "--",
                 paste0("(", formatC(stats_control["sd", v], format = "f", digits = 2, big.mark = ","), ")"))
  f_mean <- ifelse(is.na(stats_full["mean", v]), "--",
                   formatC(stats_full["mean", v], format = "f", digits = 2, big.mark = ","))
  f_sd <- ifelse(is.na(stats_full["sd", v]), "--",
                 paste0("(", formatC(stats_full["sd", v], format = "f", digits = 2, big.mark = ","), ")"))
  tex_lines <- c(tex_lines, paste0(lab, " & ", t_mean, " & ", t_sd, " & ",
                                    c_mean, " & ", c_sd, " & ",
                                    f_mean, " & ", f_sd, " \\\\"))
}

tex_lines <- c(tex_lines,
  "\\midrule",
  paste0("N (areas) & \\multicolumn{2}{c}{", nrow(treated), "} & \\multicolumn{2}{c}{",
         nrow(control), "} & \\multicolumn{2}{c}{", nrow(rdd_sample), "} \\\\"),
  "\\bottomrule",
  "\\end{tabular}",
  "\\begin{minipage}{0.95\\textwidth}",
  "\\vspace{0.3em}",
  "\\footnotesize",
  "\\textit{Notes:} Sample restricted to MSAs/non-MSAs with unemployment rate $\\geq$ national average (2022). Energy community status determined by fossil fuel employment $\\geq$ 0.17\\% of total employment (IRA statutory threshold). Standard deviations in parentheses. Employment and establishment data from Census County Business Patterns (2021). Demographics from ACS 5-Year (2021). Clean energy capacity from EIA Form 860.",
  "\\end{minipage}",
  "\\end{table}"
)

writeLines(tex_lines, file.path(TAB_DIR, "tab1_summary_stats.tex"))
cat("  Saved tab1_summary_stats.tex\n")

###############################################################################
# Table 2: Main RDD Results
###############################################################################
cat("--- Table 2: Main RDD Results ---\n")

results_summary <- readRDS(file.path(DATA_DIR, "main_results_summary.rds"))
rd_main <- readRDS(file.path(DATA_DIR, "rd_main_nocov.rds"))
rd_cov <- readRDS(file.path(DATA_DIR, "rd_main_cov.rds"))
rd_quad <- readRDS(file.path(DATA_DIR, "rd_main_quad.rds"))

tex2 <- c(
  "\\begin{table}[htbp]",
  "\\centering",
  "\\caption{Main Results: Effect of Energy Community Designation on Clean Energy Investment}",
  "\\label{tab:main_results}",
  "\\small",
  "\\begin{tabular}{lcccc}",
  "\\toprule",
  " & (1) & (2) & (3) & (4) \\\\",
  " & Sharp RDD & + Covariates & Quadratic & OLS (BW) \\\\",
  "\\midrule",
  paste0("Energy Community & ",
         round(rd_main$coef[3], 3), " & ",
         round(rd_cov$coef[3], 3), " & ",
         round(rd_quad$coef[3], 3), " & ",
         round(results_summary$estimate[4], 3), " \\\\"),
  paste0(" & (",
         round(rd_main$se[3], 3), ") & (",
         round(rd_cov$se[3], 3), ") & (",
         round(rd_quad$se[3], 3), ") & (",
         round(results_summary$se[4], 3), ") \\\\"),
  paste0(" & [",
         round(rd_main$pv[3], 3), "] & [",
         round(rd_cov$pv[3], 3), "] & [",
         round(rd_quad$pv[3], 3), "] & \\\\"),
  paste0("95\\% CI & [",
         round(rd_main$ci[3,1], 2), ", ", round(rd_main$ci[3,2], 2), "] & [",
         round(rd_cov$ci[3,1], 2), ", ", round(rd_cov$ci[3,2], 2), "] & [",
         round(rd_quad$ci[3,1], 2), ", ", round(rd_quad$ci[3,2], 2), "] & [",
         round(results_summary$ci_lower[4], 2), ", ", round(results_summary$ci_upper[4], 2), "] \\\\"),
  "\\midrule",
  paste0("Polynomial & Linear & Linear & Quadratic & Linear \\\\"),
  paste0("Covariates & No & Yes & No & Yes \\\\"),
  paste0("Bandwidth & ", round(rd_main$bws[1,1], 3), " & ",
         round(rd_cov$bws[1,1], 3), " & ",
         round(rd_quad$bws[1,1], 3), " & ",
         round(rd_main$bws[1,1], 3), " \\\\"),
  paste0("N (left) & ", rd_main$N_h[1], " & ", rd_cov$N_h[1], " & ",
         rd_quad$N_h[1], " & ", rd_main$N_h[1], " \\\\"),
  paste0("N (right) & ", rd_main$N_h[2], " & ", rd_cov$N_h[2], " & ",
         rd_quad$N_h[2], " & ", rd_main$N_h[2], " \\\\"),
  "\\bottomrule",
  "\\end{tabular}",
  "\\begin{minipage}{0.95\\textwidth}",
  "\\vspace{0.3em}",
  "\\footnotesize",
  "\\textit{Notes:} Dependent variable is post-IRA (2023+) clean energy generating capacity in megawatts per 1,000 employees. Columns (1)--(3) report robust bias-corrected estimates from \\texttt{rdrobust} with Calonico-Cattaneo-Titiunik optimal bandwidth selection. Column (4) reports OLS within the optimal bandwidth. Standard errors in parentheses; $p$-values in brackets. Covariates include log population, median household income, percent with bachelor's degree, and percent white. Running variable: fossil fuel employment as percent of total employment (2021 CBP). Threshold: 0.17\\% (IRA statutory cutoff). Sample: MSAs/non-MSAs with unemployment $\\geq$ national average.",
  "\\end{minipage}",
  "\\end{table}"
)

writeLines(tex2, file.path(TAB_DIR, "tab2_main_results.tex"))
cat("  Saved tab2_main_results.tex\n")

###############################################################################
# Table 3: Covariate Balance
###############################################################################
cat("--- Table 3: Covariate Balance ---\n")

balance_df <- readRDS(file.path(DATA_DIR, "covariate_balance.rds"))

tex3 <- c(
  "\\begin{table}[htbp]",
  "\\centering",
  "\\caption{Covariate Balance at the 0.17\\% Threshold}",
  "\\label{tab:covariate_balance}",
  "\\small",
  "\\begin{tabular}{lccc}",
  "\\toprule",
  "Covariate & RD Estimate & Robust SE & $p$-value \\\\",
  "\\midrule"
)

cov_labels <- c(
  log_pop = "Log Population",
  log_med_income = "Log Median Household Income",
  pct_bachelors = "\\% Bachelor's Degree",
  pct_white = "\\% White",
  log_total_emp = "Log Total Employment",
  log_total_estab = "Log N Establishments",
  unemp_rate = "Unemployment Rate"
)

for (i in 1:nrow(balance_df)) {
  row <- balance_df[i, ]
  lab <- ifelse(row$covariate %in% names(cov_labels),
                cov_labels[row$covariate], row$covariate)
  tex3 <- c(tex3, paste0(lab, " & ",
                          round(row$estimate, 3), " & ",
                          round(row$se, 3), " & ",
                          round(row$p_value, 3), " \\\\"))
}

tex3 <- c(tex3,
  "\\bottomrule",
  "\\end{tabular}",
  "\\begin{minipage}{0.85\\textwidth}",
  "\\vspace{0.3em}",
  "\\footnotesize",
  "\\textit{Notes:} Each row reports a separate RDD estimation using the indicated covariate as the dependent variable. Robust bias-corrected estimates from \\texttt{rdrobust}. No covariate should show a significant discontinuity at the threshold for the RDD to be valid.",
  "\\end{minipage}",
  "\\end{table}"
)

writeLines(tex3, file.path(TAB_DIR, "tab3_covariate_balance.tex"))
cat("  Saved tab3_covariate_balance.tex\n")

###############################################################################
# Table 4: Robustness — Bandwidth Sensitivity
###############################################################################
cat("--- Table 4: Bandwidth Sensitivity ---\n")

bw_df <- readRDS(file.path(DATA_DIR, "bandwidth_sensitivity.rds"))

tex4 <- c(
  "\\begin{table}[htbp]",
  "\\centering",
  "\\caption{Robustness: Bandwidth Sensitivity}",
  "\\label{tab:bandwidth_sensitivity}",
  "\\small",
  "\\begin{tabular}{cccccc}",
  "\\toprule",
  "BW Multiplier & Bandwidth & RD Estimate & Robust SE & $p$-value & N \\\\",
  "\\midrule"
)

for (i in 1:nrow(bw_df)) {
  row <- bw_df[i, ]
  opt_marker <- ifelse(row$multiplier == 1.0, "$^{\\dagger}$", "")
  tex4 <- c(tex4, paste0(
    row$multiplier, opt_marker, " & ",
    round(row$bandwidth, 4), " & ",
    round(row$estimate, 3), " & ",
    round(row$se, 3), " & ",
    round(row$p_value, 3), " & ",
    row$n_left + row$n_right, " \\\\"
  ))
}

tex4 <- c(tex4,
  "\\bottomrule",
  "\\end{tabular}",
  "\\begin{minipage}{0.85\\textwidth}",
  "\\vspace{0.3em}",
  "\\footnotesize",
  "\\textit{Notes:} $^{\\dagger}$ indicates CCT optimal bandwidth. All estimates use robust bias-corrected inference from \\texttt{rdrobust}.",
  "\\end{minipage}",
  "\\end{table}"
)

writeLines(tex4, file.path(TAB_DIR, "tab4_bandwidth_sensitivity.tex"))
cat("  Saved tab4_bandwidth_sensitivity.tex\n")

###############################################################################
# Table A1: Alternative Outcomes and Heterogeneity
###############################################################################
cat("--- Table A1: Alternative Outcomes and Heterogeneity ---\n")

alt_outcomes <- if (file.exists(file.path(DATA_DIR, "alternative_outcomes.rds")))
  readRDS(file.path(DATA_DIR, "alternative_outcomes.rds")) else list()
rd_total <- if (file.exists(file.path(DATA_DIR, "rd_total_clean.rds")))
  readRDS(file.path(DATA_DIR, "rd_total_clean.rds")) else NULL
rd_pre_ira <- if (file.exists(file.path(DATA_DIR, "rd_pre_ira_placebo.rds")))
  readRDS(file.path(DATA_DIR, "rd_pre_ira_placebo.rds")) else NULL
bivar <- if (file.exists(file.path(DATA_DIR, "bivariate_rd.rds")))
  readRDS(file.path(DATA_DIR, "bivariate_rd.rds")) else NULL
unemp_rd <- if (file.exists(file.path(DATA_DIR, "rd_unemployment_margin.rds")))
  readRDS(file.path(DATA_DIR, "rd_unemployment_margin.rds")) else NULL
hetero <- if (file.exists(file.path(DATA_DIR, "heterogeneity_msa.rds")))
  readRDS(file.path(DATA_DIR, "heterogeneity_msa.rds")) else list()

# Build appendix table
texa1 <- c(
  "\\begin{table}[htbp]",
  "\\centering",
  "\\caption{Alternative Outcomes, Heterogeneity, and Additional RDD Specifications}",
  "\\label{tab:alt_outcomes}",
  "\\small",
  "\\begin{tabular}{lccccc}",
  "\\toprule",
  " & Estimate & Robust SE & $p$-value & N(left) & N(right) \\\\",
  "\\midrule",
  "\\multicolumn{6}{l}{\\textit{Panel A: Alternative Outcomes}} \\\\"
)

# Total clean energy
if (!is.null(rd_total)) {
  texa1 <- c(texa1, paste0(
    "Total Clean Energy (all years) & ",
    round(rd_total$coef[3], 3), " & ",
    round(rd_total$se[3], 3), " & ",
    round(rd_total$pv[3], 3), " & ",
    rd_total$N_h[1], " & ", rd_total$N_h[2], " \\\\"
  ))
}

# Pre-IRA placebo (clean energy before 2023)
if (!is.null(rd_pre_ira)) {
  texa1 <- c(texa1, paste0(
    "Pre-IRA Clean Energy (placebo) & ",
    round(rd_pre_ira$coef[3], 3), " & ",
    round(rd_pre_ira$se[3], 3), " & ",
    round(rd_pre_ira$pv[3], 3), " & ",
    rd_pre_ira$N_h[1], " & ", rd_pre_ira$N_h[2], " \\\\"
  ))
}

# N proposed generators
if (!is.null(alt_outcomes$n_generators)) {
  texa1 <- c(texa1, paste0(
    "N Proposed Generators & ",
    round(alt_outcomes$n_generators$coef[3], 3), " & ",
    round(alt_outcomes$n_generators$se[3], 3), " & ",
    round(alt_outcomes$n_generators$pv[3], 3), " & ",
    alt_outcomes$n_generators$N_h[1], " & ", alt_outcomes$n_generators$N_h[2], " \\\\"
  ))
}

texa1 <- c(texa1,
  "\\midrule",
  "\\multicolumn{6}{l}{\\textit{Panel B: Heterogeneity by Area Type}} \\\\"
)

# Heterogeneity
if ("MSA" %in% names(hetero)) {
  texa1 <- c(texa1, paste0(
    "MSA Areas & ",
    round(hetero$MSA$coef[3], 3), " & ",
    round(hetero$MSA$se[3], 3), " & ",
    round(hetero$MSA$pv[3], 3), " & ",
    hetero$MSA$N_h[1], " & ", hetero$MSA$N_h[2], " \\\\"
  ))
}
if ("non-MSA" %in% names(hetero)) {
  texa1 <- c(texa1, paste0(
    "Non-MSA Areas & ",
    round(hetero[["non-MSA"]]$coef[3], 3), " & ",
    round(hetero[["non-MSA"]]$se[3], 3), " & ",
    round(hetero[["non-MSA"]]$pv[3], 3), " & ",
    hetero[["non-MSA"]]$N_h[1], " & ", hetero[["non-MSA"]]$N_h[2], " \\\\"
  ))
}

texa1 <- c(texa1,
  "\\midrule",
  "\\multicolumn{6}{l}{\\textit{Panel C: Additional Specifications}} \\\\"
)

# Bivariate RDD
if (!is.null(bivar)) {
  bivar_coef_name <- "energy_communityTRUE"
  texa1 <- c(texa1, paste0(
    "Bivariate RDD (OLS) & ",
    round(coef(bivar)[bivar_coef_name], 3), " & ",
    round(sqrt(vcov(bivar)[bivar_coef_name, bivar_coef_name]), 3), " & ",
    round(summary(bivar)$coeftable[bivar_coef_name, "Pr(>|t|)"], 3), " & ",
    "\\multicolumn{2}{c}{N = ", nobs(bivar), "} \\\\"
  ))
}

# Unemployment margin RDD
if (!is.null(unemp_rd)) {
  texa1 <- c(texa1, paste0(
    "Unemployment Margin RDD & ",
    round(unemp_rd$coef[3], 3), " & ",
    round(unemp_rd$se[3], 3), " & ",
    round(unemp_rd$pv[3], 3), " & ",
    unemp_rd$N_h[1], " & ", unemp_rd$N_h[2], " \\\\"
  ))
}

texa1 <- c(texa1,
  "\\bottomrule",
  "\\end{tabular}",
  "\\begin{minipage}{0.95\\textwidth}",
  "\\vspace{0.3em}",
  "\\footnotesize",
  "\\textit{Notes:} Panel A reports RDD estimates for alternative outcome variables. Total clean energy includes all operational generators (not just post-IRA). Pre-IRA clean energy is a placebo test using generators with operating years before 2023 (prior to IRA implementation). N proposed generators counts EIA Form 860 proposed projects. Panel B splits the sample by metropolitan (MSA) vs.\\ non-metropolitan (non-MSA) areas. Panel C reports the bivariate RDD (OLS, both FF employment and unemployment thresholds, full sample) and the unemployment margin RDD (among areas with FF employment $\\geq 0.17\\%$). All estimates except the bivariate RDD use robust bias-corrected inference from \\texttt{rdrobust}.",
  "\\end{minipage}",
  "\\end{table}"
)

writeLines(texa1, file.path(TAB_DIR, "tabA1_alt_outcomes.tex"))
cat("  Saved tabA1_alt_outcomes.tex\n")

cat("\n=== All tables generated ===\n")
