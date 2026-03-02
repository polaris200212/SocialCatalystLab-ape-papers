## ============================================================================
## 06_tables.R — All tables for the paper
## Paper: Tight Labor Markets and the Crisis in Home Care
## ============================================================================

source("00_packages.R")

panel <- readRDS(file.path(DATA, "analysis_panel.rds"))
smpl <- panel[in_sample == TRUE]
results <- readRDS(file.path(DATA, "main_results.rds"))
robustness <- readRDS(file.path(DATA, "robustness_results.rds"))

## ---- Table 1: Summary Statistics ----
cat("Table 1: Summary statistics...\n")

summ_vars <- smpl[, .(
  `HCBS Providers` = hcbs_providers,
  `HCBS Claims` = hcbs_claims,
  `HCBS Spending ($)` = hcbs_paid,
  `HCBS Beneficiaries` = hcbs_benes,
  `Non-HCBS Providers` = non_hcbs_providers,
  `Employment/Pop Ratio` = emp_pop,
  `Bartik IV` = bartik,
  `Population` = population,
  `Poverty Rate` = poverty_rate,
  `Elderly Share` = elderly_share,
  `Uninsured Rate` = uninsured_rate
)]

tab1_data <- data.table(
  Variable = names(summ_vars),
  Mean = sapply(summ_vars, mean, na.rm = TRUE),
  SD = sapply(summ_vars, sd, na.rm = TRUE),
  P25 = sapply(summ_vars, quantile, 0.25, na.rm = TRUE),
  Median = sapply(summ_vars, median, na.rm = TRUE),
  P75 = sapply(summ_vars, quantile, 0.75, na.rm = TRUE),
  N = sapply(summ_vars, function(x) sum(!is.na(x)))
)

# Format for LaTeX
tab1_tex <- paste0(
  "\\begin{table}[htbp]\n",
  "\\centering\n",
  "\\caption{Summary Statistics}\n",
  "\\label{tab:summary}\n",
  "\\begin{threeparttable}\n",
  "\\begin{tabular}{lrrrrrr}\n",
  "\\toprule\n",
  "Variable & Mean & SD & P25 & Median & P75 & N \\\\\n",
  "\\midrule\n"
)

for (i in 1:nrow(tab1_data)) {
  row <- tab1_data[i]
  tab1_tex <- paste0(tab1_tex, sprintf(
    "%s & %s & %s & %s & %s & %s & %s \\\\\n",
    row$Variable,
    format(round(row$Mean, 2), big.mark = ",", nsmall = 2),
    format(round(row$SD, 2), big.mark = ",", nsmall = 2),
    format(round(row$P25, 2), big.mark = ",", nsmall = 2),
    format(round(row$Median, 2), big.mark = ",", nsmall = 2),
    format(round(row$P75, 2), big.mark = ",", nsmall = 2),
    format(row$N, big.mark = ",")
  ))
}

tab1_tex <- paste0(tab1_tex,
  "\\bottomrule\n",
  "\\end{tabular}\n",
  "\\begin{tablenotes}[flushleft]\n",
  "\\small\n",
  sprintf("\\item \\textit{Notes:} Unit of observation is county $\\times$ quarter. Sample: %s county-quarters from %s counties, 2018Q1--2024Q4. HCBS includes T-codes (personal care, habilitation), H-codes (behavioral health), and S-codes (temporary/state services) from T-MSIS. Employment data from BLS QCEW. Demographics from ACS 5-year estimates.\n",
          format(nrow(smpl), big.mark = ","),
          format(uniqueN(smpl$county_fips), big.mark = ",")),
  "\\end{tablenotes}\n",
  "\\end{threeparttable}\n",
  "\\end{table}\n"
)

writeLines(tab1_tex, file.path(TABLES, "tab1_summary.tex"))

## ---- Table 2: Main Results (OLS and IV) ----
cat("Table 2: Main results...\n")

# Build table manually for precise control
make_coef_row <- function(models, coef_name, label) {
  vals <- sapply(models, function(m) {
    b <- tryCatch(coef(m)[coef_name], error = function(e) NA)
    s <- tryCatch(se(m)[coef_name], error = function(e) NA)
    p <- tryCatch(pvalue(m)[coef_name], error = function(e) NA)
    stars <- ifelse(is.na(p), "",
                    ifelse(p < 0.01, "***",
                           ifelse(p < 0.05, "**",
                                  ifelse(p < 0.1, "*", ""))))
    list(b = b, s = s, stars = stars)
  })
  coef_line <- paste(label, "&",
    paste(sapply(vals, function(v) {
      if (is.na(v$b)) return("")
      sprintf("%.4f%s", v$b, v$stars)
    }), collapse = " & "), "\\\\")
  se_line <- paste(" &",
    paste(sapply(vals, function(v) {
      if (is.na(v$s)) return("")
      sprintf("(%.4f)", v$s)
    }), collapse = " & "), "\\\\")
  paste(coef_line, "\n", se_line)
}

tab2_tex <- paste0(
  "\\begin{table}[htbp]\n",
  "\\centering\n",
  "\\caption{Effect of Labor Market Tightness on HCBS Provider Supply}\n",
  "\\label{tab:main}\n",
  "\\begin{threeparttable}\n",
  "\\footnotesize\n",
  "\\begin{tabular}{lcccccccc}\n",
  "\\toprule\n",
  " & \\multicolumn{4}{c}{OLS} & \\multicolumn{4}{c}{IV (Bartik)} \\\\\n",
  "\\cmidrule(lr){2-5} \\cmidrule(lr){6-9}\n",
  " & ln(Prov) & ln(Claims) & ln(Paid) & ln(Benes) & ln(Prov) & ln(Claims) & ln(Paid) & ln(Benes) \\\\\n",
  " & (1) & (2) & (3) & (4) & (5) & (6) & (7) & (8) \\\\\n",
  "\\midrule\n"
)

# OLS coefficients
ols_models <- list(results$ols_providers, results$ols_claims,
                   results$ols_paid, results$ols_benes)
iv_models <- list(results$iv_providers, results$iv_claims,
                  results$iv_paid, results$iv_benes)

# Emp/Pop row
for (m_list in list(ols_models, iv_models)) {
  for (m in m_list) {
    cn <- if ("emp_pop" %in% names(coef(m))) "emp_pop" else "fit_emp_pop"
  }
}

# Build rows
ols_b <- sapply(ols_models, function(m) coef(m)["emp_pop"])
ols_se <- sapply(ols_models, function(m) se(m)["emp_pop"])
iv_b <- sapply(iv_models, function(m) coef(m)["fit_emp_pop"])
iv_se <- sapply(iv_models, function(m) se(m)["fit_emp_pop"])

get_pval <- function(m, coef_name) {
  ct <- coeftable(m)
  idx <- which(rownames(ct) == coef_name)
  if (length(idx) == 0) return(NA)
  ct[idx, "Pr(>|t|)"]
}

stars <- function(p) ifelse(is.na(p), "", ifelse(p < 0.01, "***", ifelse(p < 0.05, "**", ifelse(p < 0.1, "*", ""))))

ols_p <- sapply(ols_models, function(m) get_pval(m, "emp_pop"))
iv_p <- sapply(iv_models, function(m) get_pval(m, "fit_emp_pop"))

b_row <- paste0("Employment/Pop & ",
  paste(sprintf("%.3f%s", ols_b, stars(ols_p)), collapse = " & "), " & ",
  paste(sprintf("%.3f%s", iv_b, stars(iv_p)), collapse = " & "), " \\\\")
se_row <- paste0(" & ",
  paste(sprintf("(%.3f)", ols_se), collapse = " & "), " & ",
  paste(sprintf("(%.3f)", iv_se), collapse = " & "), " \\\\")

# N and statistics
n_obs <- sapply(c(ols_models, iv_models), nobs)
n_counties <- sapply(c(ols_models, iv_models), function(m) {
  tryCatch(length(unique(m$fixef_id$county_fips)), error = function(e) NA)
})

# First stage F
fs_f <- tryCatch(fitstat(results$iv_providers, "ivf")$ivf1$stat, error = function(e) NA)

tab2_tex <- paste0(tab2_tex,
  b_row, "\n", se_row, "\n",
  "[0.5em]\n",
  "\\midrule\n",
  sprintf("First-stage F & & & & & %.1f & %.1f & %.1f & %.1f \\\\\n", fs_f, fs_f, fs_f, fs_f),
  paste0("Observations & ", paste(format(n_obs, big.mark = ","), collapse = " & "), " \\\\\n"),
  "County FE & Yes & Yes & Yes & Yes & Yes & Yes & Yes & Yes \\\\\n",
  "State $\\times$ Quarter FE & Yes & Yes & Yes & Yes & Yes & Yes & Yes & Yes \\\\\n",
  "Clustering & State & State & State & State & State & State & State & State \\\\\n",
  "\\bottomrule\n",
  "\\end{tabular}\n",
  "\\begin{tablenotes}[flushleft]\n",
  "\\small\n",
  "\\item \\textit{Notes:} Each column reports a separate regression. The dependent variable is indicated in the column header. Employment/Population is the county-quarter ratio of total private employment (BLS QCEW) to population (ACS). Columns 5--8 instrument employment/population with a Bartik shift-share instrument using 2018 county industry shares and national industry employment growth, excluding healthcare (NAICS 62). Standard errors clustered at the state level in parentheses. *** p$<$0.01, ** p$<$0.05, * p$<$0.1.\n",
  "\\end{tablenotes}\n",
  "\\end{threeparttable}\n",
  "\\end{table}\n"
)

writeLines(tab2_tex, file.path(TABLES, "tab2_main.tex"))

## ---- Table 3: Robustness ----
cat("Table 3: Robustness...\n")

# Collect all robustness specifications for ln(providers)
rob_specs <- list(
  list(name = "Baseline IV", model = results$iv_providers, coef = "fit_emp_pop"),
  list(name = "Excl. NAICS 62", model = results$iv_providers_no62, coef = "fit_emp_pop"),
  list(name = "Excl. 2020Q1--Q2", model = robustness$iv_no_covid, coef = "fit_emp_pop"),
  list(name = "$\\geq$5 base providers", model = robustness$iv_large, coef = "fit_emp_pop"),
  list(name = "With demand control", model = robustness$iv_demand_ctrl, coef = "fit_emp_pop"),
  list(name = "County-clustered SE", model = robustness$iv_county_cluster, coef = "fit_emp_pop"),
  list(name = "Two-way clustered", model = robustness$iv_twoway, coef = "fit_emp_pop")
)

tab3_tex <- paste0(
  "\\begin{table}[htbp]\n",
  "\\centering\n",
  "\\caption{Robustness Checks: IV Estimates of Labor Market Tightness on HCBS Supply}\n",
  "\\label{tab:robustness}\n",
  "\\begin{threeparttable}\n",
  "\\begin{tabular}{lcccl}\n",
  "\\toprule\n",
  "Specification & Coefficient & SE & N & Notes \\\\\n",
  "\\midrule\n"
)

for (spec in rob_specs) {
  b <- coef(spec$model)[spec$coef]
  s <- se(spec$model)[spec$coef]
  p <- get_pval(spec$model, spec$coef)
  n <- nobs(spec$model)
  st <- stars(p)
  tab3_tex <- paste0(tab3_tex,
    sprintf("%s & %.4f%s & (%.4f) & %s & \\\\\n",
            spec$name, b, st, s, format(n, big.mark = ",")))
}

tab3_tex <- paste0(tab3_tex,
  "\\bottomrule\n",
  "\\end{tabular}\n",
  "\\begin{tablenotes}[flushleft]\n",
  "\\small\n",
  "\\item \\textit{Notes:} All specifications include county and state $\\times$ quarter fixed effects. The dependent variable is ln(HCBS providers). Employment/population is instrumented with the Bartik shift-share. Baseline uses all industries; ``Excl.\\ NAICS 62'' removes healthcare from the Bartik instrument. *** p$<$0.01, ** p$<$0.05, * p$<$0.1.\n",
  "\\end{tablenotes}\n",
  "\\end{threeparttable}\n",
  "\\end{table}\n"
)

writeLines(tab3_tex, file.path(TABLES, "tab3_robustness.tex"))

## ---- Table 4: Heterogeneity ----
cat("Table 4: Heterogeneity...\n")

het_specs <- list(
  list(name = "Full sample", model = results$iv_providers),
  list(name = "Urban counties", model = results$iv_urban),
  list(name = "Rural counties", model = results$iv_rural),
  list(name = "Individual providers", model = results$iv_indiv),
  list(name = "Organizational providers", model = results$iv_org)
)

tab4_tex <- paste0(
  "\\begin{table}[htbp]\n",
  "\\centering\n",
  "\\caption{Heterogeneous Effects by Area and Provider Type}\n",
  "\\label{tab:heterogeneity}\n",
  "\\begin{threeparttable}\n",
  "\\begin{tabular}{lccc}\n",
  "\\toprule\n",
  "Sample / Outcome & Coefficient & SE & N \\\\\n",
  "\\midrule\n"
)

for (spec in het_specs) {
  b <- coef(spec$model)["fit_emp_pop"]
  s <- se(spec$model)["fit_emp_pop"]
  p <- get_pval(spec$model, "fit_emp_pop")
  n <- nobs(spec$model)
  st <- stars(p)
  tab4_tex <- paste0(tab4_tex,
    sprintf("%s & %.4f%s & (%.4f) & %s \\\\\n",
            spec$name, b, st, s, format(n, big.mark = ",")))
}

tab4_tex <- paste0(tab4_tex,
  "\\bottomrule\n",
  "\\end{tabular}\n",
  "\\begin{tablenotes}[flushleft]\n",
  "\\small\n",
  "\\item \\textit{Notes:} IV (Bartik) estimates. All specifications include county and state $\\times$ quarter fixed effects. Standard errors clustered at the state level. Urban counties have population $\\geq$ 50,000. *** p$<$0.01, ** p$<$0.05, * p$<$0.1.\n",
  "\\end{tablenotes}\n",
  "\\end{threeparttable}\n",
  "\\end{table}\n"
)

writeLines(tab4_tex, file.path(TABLES, "tab4_heterogeneity.tex"))

## ---- Table 5: Placebo ----
cat("Table 5: Placebo...\n")

tab5_tex <- paste0(
  "\\begin{table}[htbp]\n",
  "\\centering\n",
  "\\caption{Placebo Test: Non-HCBS Medicaid Provider Supply}\n",
  "\\label{tab:placebo}\n",
  "\\begin{threeparttable}\n",
  "\\begin{tabular}{lcc}\n",
  "\\toprule\n",
  " & OLS & IV (Bartik) \\\\\n",
  " & (1) & (2) \\\\\n",
  "\\midrule\n"
)

placebo_ols_b <- coef(results$placebo_ols)["emp_pop"]
placebo_ols_se <- se(results$placebo_ols)["emp_pop"]
placebo_ols_p <- get_pval(results$placebo_ols, "emp_pop")
placebo_iv_b <- coef(results$placebo_iv)["fit_emp_pop"]
placebo_iv_se <- se(results$placebo_iv)["fit_emp_pop"]
placebo_iv_p <- get_pval(results$placebo_iv, "fit_emp_pop")

tab5_tex <- paste0(tab5_tex,
  sprintf("Employment/Pop & %.4f%s & %.4f%s \\\\\n",
          placebo_ols_b, stars(placebo_ols_p),
          placebo_iv_b, stars(placebo_iv_p)),
  sprintf(" & (%.4f) & (%.4f) \\\\\n", placebo_ols_se, placebo_iv_se),
  "[0.5em]\n",
  "\\midrule\n",
  sprintf("Observations & %s & %s \\\\\n",
          format(nobs(results$placebo_ols), big.mark = ","),
          format(nobs(results$placebo_iv), big.mark = ",")),
  "Dep. var. & \\multicolumn{2}{c}{ln(Non-HCBS Providers)} \\\\\n",
  "\\bottomrule\n",
  "\\end{tabular}\n",
  "\\begin{tablenotes}[flushleft]\n",
  "\\small\n",
  "\\item \\textit{Notes:} Placebo test using non-HCBS Medicaid providers (CPT professional codes, drug codes, DME) as the dependent variable. If labor market tightness specifically affects low-wage HCBS workers, the effect on non-HCBS providers (physicians, pharmacies) should be smaller or zero. All specifications include county and state $\\times$ quarter FE. *** p$<$0.01, ** p$<$0.05, * p$<$0.1.\n",
  "\\end{tablenotes}\n",
  "\\end{threeparttable}\n",
  "\\end{table}\n"
)

writeLines(tab5_tex, file.path(TABLES, "tab5_placebo.tex"))

## ---- Table 6: First Stage ----
cat("Table 6: First stage...\n")

fs <- results$first_stage
fs_b <- coef(fs)["bartik"]
fs_se <- se(fs)["bartik"]
fs_p <- get_pval(fs, "bartik")
fs_f <- tryCatch(fitstat(results$iv_providers, "ivf")$ivf1$stat, error = function(e) NA)

tab6_tex <- paste0(
  "\\begin{table}[htbp]\n",
  "\\centering\n",
  "\\caption{First Stage: Bartik Instrument Predicting Employment/Population}\n",
  "\\label{tab:first_stage}\n",
  "\\begin{threeparttable}\n",
  "\\begin{tabular}{lc}\n",
  "\\toprule\n",
  " & Employment/Pop \\\\\n",
  "\\midrule\n",
  sprintf("Bartik IV & %.4f%s \\\\\n", fs_b, stars(fs_p)),
  sprintf(" & (%.4f) \\\\\n", fs_se),
  "[0.5em]\n",
  "\\midrule\n",
  sprintf("F-statistic & %.1f \\\\\n", fs_f),
  sprintf("Observations & %s \\\\\n", format(nobs(fs), big.mark = ",")),
  "County FE & Yes \\\\\n",
  "State $\\times$ Quarter FE & Yes \\\\\n",
  "\\bottomrule\n",
  "\\end{tabular}\n",
  "\\begin{tablenotes}[flushleft]\n",
  "\\small\n",
  "\\item \\textit{Notes:} First stage of the 2SLS regression. The Bartik instrument is constructed from 2018 county industry employment shares interacted with national industry employment growth rates, excluding healthcare (NAICS 62). Standard errors clustered at the state level.\n",
  "\\end{tablenotes}\n",
  "\\end{threeparttable}\n",
  "\\end{table}\n"
)

writeLines(tab6_tex, file.path(TABLES, "tab6_first_stage.tex"))

cat("\n=== All tables saved ===\n")
