##──────────────────────────────────────────────────────────────────────────────
## 06_tables.R — All LaTeX tables for the paper
## Paper: apep_0451 — Cocoa Boom and Human Capital in Ghana
##──────────────────────────────────────────────────────────────────────────────

library(data.table)
library(fixest)
library(modelsummary)

DATA_DIR  <- here::here("output", "apep_0451", "v1", "data")
TABLE_DIR <- here::here("output", "apep_0451", "v1", "tables")
dir.create(TABLE_DIR, recursive = TRUE, showWarnings = FALSE)

dt <- fread(file.path(DATA_DIR, "ghana_census_clean.csv.gz"), nThread = 4)
results <- readRDS(file.path(DATA_DIR, "main_results.rds"))
robustness <- readRDS(file.path(DATA_DIR, "robustness_results.rds"))

## ════════════════════════════════════════════════════════════════════════════
## TABLE 1: Summary Statistics
## ════════════════════════════════════════════════════════════════════════════

dt_forest <- dt[forest_belt == TRUE]

## School-age children (6-17)
sum_school <- dt_forest[school_age == 1, .(
  N = .N,
  enrolled = weighted.mean(in_school, pw, na.rm = TRUE),
  literate = weighted.mean(literate, pw, na.rm = TRUE),
  completed_primary = weighted.mean(completed_primary, pw),
  female = weighted.mean(female, pw),
  mean_age = weighted.mean(age, pw)
), by = .(census_year, high_cocoa)]

## Working-age adults (18-64)
sum_work <- dt_forest[working_age == 1, .(
  N = .N,
  employed = weighted.mean(employed, pw, na.rm = TRUE),
  agriculture = weighted.mean(works_agriculture, pw, na.rm = TRUE),
  completed_secondary = weighted.mean(completed_secondary, pw),
  female = weighted.mean(female, pw),
  mean_age = weighted.mean(age, pw)
), by = .(census_year, high_cocoa)]

## Write summary stats as LaTeX
sink(file.path(TABLE_DIR, "tab1_summary.tex"))
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Summary Statistics by Census Year and Cocoa Intensity}\n")
cat("\\label{tab:summary}\n")
cat("\\begin{tabular}{lcccccc}\n")
cat("\\hline\\hline\n")
cat("& \\multicolumn{2}{c}{1984} & \\multicolumn{2}{c}{2000} & \\multicolumn{2}{c}{2010} \\\\\n")
cat("& Low & High & Low & High & Low & High \\\\\n")
cat("\\hline\n")
cat("\\multicolumn{7}{l}{\\textit{Panel A: School-Age Children (6--17)}} \\\\\n")

for (yr in c(1984, 2000, 2010)) {
  for (hc in c(0, 1)) {
    s <- sum_school[census_year == yr & high_cocoa == hc]
    if (yr == 1984 & hc == 0) {
      cat(sprintf("N & %s", format(s$N, big.mark = ",")))
    } else {
      cat(sprintf(" & %s", format(s$N, big.mark = ",")))
    }
  }
}
cat(" \\\\\n")

write_row <- function(label, var, df) {
  vals <- c()
  for (yr in c(1984, 2000, 2010)) {
    for (hc in c(0, 1)) {
      s <- df[census_year == yr & high_cocoa == hc]
      v <- s[[var]]
      if (length(v) == 0 || is.na(v) || is.nan(v)) {
        vals <- c(vals, "---")
      } else {
        vals <- c(vals, sprintf("%.3f", v))
      }
    }
  }
  cat(sprintf("%s & %s \\\\\n", label, paste(vals, collapse = " & ")))
}

write_row("School enrollment", "enrolled", sum_school)
write_row("Literate", "literate", sum_school)
write_row("Completed primary", "completed_primary", sum_school)
write_row("Female share", "female", sum_school)
write_row("Mean age", "mean_age", sum_school)

cat("\\hline\n")
cat("\\multicolumn{7}{l}{\\textit{Panel B: Working-Age Adults (18--64)}} \\\\\n")

for (yr in c(1984, 2000, 2010)) {
  for (hc in c(0, 1)) {
    s <- sum_work[census_year == yr & high_cocoa == hc]
    if (yr == 1984 & hc == 0) {
      cat(sprintf("N & %s", format(s$N, big.mark = ",")))
    } else {
      cat(sprintf(" & %s", format(s$N, big.mark = ",")))
    }
  }
}
cat(" \\\\\n")

write_row("Employed", "employed", sum_work)
write_row("In agriculture", "agriculture", sum_work)
write_row("Completed secondary", "completed_secondary", sum_work)
write_row("Female share", "female", sum_work)
write_row("Mean age", "mean_age", sum_work)

cat("\\hline\\hline\n")
cat("\\end{tabular}\n")
cat("\\begin{minipage}{0.95\\textwidth}\n")
cat("\\vspace{0.2cm}\n")
cat("\\footnotesize\n")
cat("\\textit{Notes:} Forest belt regions only (Western, Central, Eastern, Ashanti, Brong Ahafo, Volta).")
cat(" High cocoa: regions with $\\geq$8\\% of national cocoa production (Western, Ashanti, Brong Ahafo, Eastern).")
cat(" Low cocoa: Central, Volta. All means are weighted by person weights.")
cat(" Source: IPUMS International, Ghana Population and Housing Census.\n")
cat("\\end{minipage}\n")
cat("\\end{table}\n")
sink()
cat("Table 1 saved.\n")

## ════════════════════════════════════════════════════════════════════════════
## TABLE 2: Main Results — School-Age Children
## ════════════════════════════════════════════════════════════════════════════

models_school <- list(
  "Enrollment" = results$m_enroll_fb,
  "Literacy" = results$m_lit_fb,
  "Primary Compl." = results$m_primary_fb,
  "Enrollment (All)" = results$m_enroll_all
)

cm <- c(
  "cocoa_share:post2010" = "Cocoa Share $\\times$ Post 2010",
  "female" = "Female"
)

modelsummary(
  models_school,
  output = file.path(TABLE_DIR, "tab2_school.tex"),
  coef_map = cm,
  gof_map = c("nobs", "r.squared", "FE: geo1", "FE: census_year"),
  stars = c("*" = 0.10, "**" = 0.05, "***" = 0.01),
  title = "Effect of Cocoa Boom on School-Age Children (6--17)",
  notes = list(
    "Forest belt regions (cols 1--3); all 10 regions (col 4).",
    "Clustered standard errors at the region level in parentheses.",
    "All regressions include region and year fixed effects and control for age."
  ),
  escape = FALSE
)
cat("Table 2 saved.\n")

## ════════════════════════════════════════════════════════════════════════════
## TABLE 3: Main Results — Working-Age Adults
## ════════════════════════════════════════════════════════════════════════════

models_work <- list(
  "Employment" = results$m_emp_fb,
  "Agriculture" = results$m_agri_fb,
  "Self-Empl." = results$m_self_fb,
  "Unpaid Fam." = results$m_unpaid_fb
)

modelsummary(
  models_work,
  output = file.path(TABLE_DIR, "tab3_employment.tex"),
  coef_map = cm,
  gof_map = c("nobs", "r.squared", "FE: geo1", "FE: census_year"),
  stars = c("*" = 0.10, "**" = 0.05, "***" = 0.01),
  title = "Effect of Cocoa Boom on Working-Age Adults (18--64)",
  notes = list(
    "Forest belt regions. Clustered SE at region level.",
    "All regressions include region and year FE and control for age."
  ),
  escape = FALSE
)
cat("Table 3 saved.\n")

## ════════════════════════════════════════════════════════════════════════════
## TABLE 4: Pre-Trend Tests
## ════════════════════════════════════════════════════════════════════════════

models_pre <- list(
  "Enrollment" = robustness$pre_enroll,
  "Primary Compl." = robustness$pre_primary,
  "Employment" = robustness$pre_emp,
  "Agriculture" = robustness$pre_agri
)

cm_pre <- c(
  "cocoa_share:post2000" = "Cocoa Share $\\times$ Post 2000",
  "female" = "Female"
)

modelsummary(
  models_pre,
  output = file.path(TABLE_DIR, "tab4_pretrends.tex"),
  coef_map = cm_pre,
  gof_map = c("nobs", "r.squared", "FE: geo1", "FE: census_year"),
  stars = c("*" = 0.10, "**" = 0.05, "***" = 0.01),
  title = "Pre-Trend Tests: 1984--2000 (No Cocoa Boom)",
  notes = list(
    "Forest belt regions. Period: 1984--2000 (cocoa prices declining).",
    "The treatment interaction should be zero if parallel trends holds."
  ),
  escape = FALSE
)
cat("Table 4 saved.\n")

## ════════════════════════════════════════════════════════════════════════════
## TABLE 5: Robustness — Alternative Samples
## ════════════════════════════════════════════════════════════════════════════

models_robust <- list(
  "Forest Belt" = results$m_lit_fb,
  "All Regions" = robustness$full_lit,
  "Rural Only" = robustness$rural_lit
)

cm_r <- c("cocoa_share:post2010" = "Cocoa Share $\\times$ Post 2010")

modelsummary(
  models_robust,
  output = file.path(TABLE_DIR, "tab5_robustness.tex"),
  coef_map = cm_r,
  gof_map = c("nobs", "r.squared"),
  stars = c("*" = 0.10, "**" = 0.05, "***" = 0.01),
  title = "Robustness: Literacy Effect Across Sample Definitions",
  notes = list(
    "School-age children (6--17). All include region and year FE, age, sex controls.",
    "Col 1: Forest belt only. Col 2: All 10 regions. Col 3: Rural forest belt."
  ),
  escape = FALSE
)
cat("Table 5 saved.\n")

## ════════════════════════════════════════════════════════════════════════════
## TABLE 6: Heterogeneity — Age and Gender
## ════════════════════════════════════════════════════════════════════════════

models_het <- list(
  "Primary (6-11)" = results$m_enroll_primary_age,
  "Secondary (12-17)" = results$m_enroll_secondary_age,
  "Males" = results$m_enroll_male,
  "Females" = results$m_enroll_female
)

modelsummary(
  models_het,
  output = file.path(TABLE_DIR, "tab6_heterogeneity.tex"),
  coef_map = cm,
  gof_map = c("nobs", "r.squared"),
  stars = c("*" = 0.10, "**" = 0.05, "***" = 0.01),
  title = "Heterogeneity in Enrollment Effect by Age and Gender",
  notes = list(
    "Forest belt regions. Dependent variable: school enrollment.",
    "All include region and year FE."
  ),
  escape = FALSE
)
cat("Table 6 saved.\n")

## ════════════════════════════════════════════════════════════════════════════
## TABLE 7: DR DiD Results (Side-by-Side with Bartik)
## ════════════════════════════════════════════════════════════════════════════

## Extract DR DiD results (drdid objects have $ATT, $se, $uci, $lci directly)
extract_drdid <- function(obj, label) {
  if (is.null(obj)) return(NULL)
  data.table(
    Outcome = label,
    ATT = obj$ATT,
    SE = obj$se,
    t = obj$ATT / obj$se,
    p = 2 * pnorm(-abs(obj$ATT / obj$se)),
    CI_lo = obj$lci,
    CI_hi = obj$uci
  )
}

## Build DR DiD results table
drdid_tab <- rbindlist(list(
  extract_drdid(results$drdid_enroll, "Enrollment"),
  extract_drdid(results$drdid_lit, "Literacy"),
  extract_drdid(results$drdid_prim, "Primary Compl."),
  extract_drdid(results$drdid_emp, "Employment"),
  extract_drdid(results$drdid_agri, "Agriculture")
), fill = TRUE)

## Write LaTeX table
sink(file.path(TABLE_DIR, "tab7_drdid.tex"))
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Doubly-Robust Difference-in-Differences Estimates}\n")
cat("\\label{tab:drdid}\n")
cat("\\begin{tabular}{lccccc}\n")
cat("\\hline\\hline\n")
cat("Outcome & ATT & SE & 95\\% CI & $t$ & $p$ \\\\\n")
cat("\\hline\n")
cat("\\multicolumn{6}{l}{\\textit{Panel A: School-Age Children (6--17)}} \\\\\n")

for (i in seq_len(nrow(drdid_tab))) {
  row <- drdid_tab[i]
  stars <- ""
  if (!is.na(row$p)) {
    if (row$p < 0.01) stars <- "***"
    else if (row$p < 0.05) stars <- "**"
    else if (row$p < 0.10) stars <- "*"
  }

  if (i == 4) {
    cat("\\hline\n")
    cat("\\multicolumn{6}{l}{\\textit{Panel B: Working-Age Adults (18--64)}} \\\\\n")
  }

  cat(sprintf("%s & %.3f%s & (%.3f) & [%.3f, %.3f] & %.2f & %.3f \\\\\n",
    row$Outcome, row$ATT, stars, row$SE,
    row$CI_lo, row$CI_hi, row$t, row$p
  ))
}

cat("\\hline\\hline\n")
cat("\\end{tabular}\n")
cat("\\begin{minipage}{0.95\\textwidth}\n")
cat("\\vspace{0.2cm}\n")
cat("\\footnotesize\n")
cat("\\textit{Notes:} Improved locally efficient doubly-robust DiD estimator \\citep{santanna2020}.\n")
cat("Binary treatment: high cocoa ($\\geq$8\\% national share) vs.\\ low cocoa.\n")
cat("Forest belt regions, 2000 vs.\\ 2010. Covariates: age and gender.\n")
cat("Standard errors from the influence function. $^{***}p<0.01$, $^{**}p<0.05$, $^{*}p<0.10$.\n")
cat("\\end{minipage}\n")
cat("\\end{table}\n")
sink()
cat("Table 7 (DR DiD) saved.\n")

## ════════════════════════════════════════════════════════════════════════════
## TABLE 8: Randomization Inference and Leave-One-Out Summary
## ════════════════════════════════════════════════════════════════════════════

rob <- readRDS(file.path(DATA_DIR, "robustness_results.rds"))

sink(file.path(TABLE_DIR, "tab8_ri_loo.tex"))
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Inference Robustness: Randomization Inference and Leave-One-Region-Out}\n")
cat("\\label{tab:ri_loo}\n")
cat("\\begin{tabular}{lcc}\n")
cat("\\hline\\hline\n")
cat("& Literacy & Employment \\\\\n")
cat("\\hline\n")
cat("\\multicolumn{3}{l}{\\textit{Panel A: Randomization Inference (720 permutations)}} \\\\\n")

## Format RI results
obs_lit <- coef(results$m_lit_fb)["cocoa_share:post2010"]
obs_emp <- coef(results$m_emp_fb)["cocoa_share:post2010"]

cat(sprintf("Observed coefficient & %.3f & %.3f \\\\\n", obs_lit, obs_emp))
cat(sprintf("RI $p$-value (two-sided) & %.3f & %.3f \\\\\n",
            rob$ri_lit_pval, rob$ri_emp_pval))
cat("\\hline\n")
cat("\\multicolumn{3}{l}{\\textit{Panel B: Leave-One-Region-Out}} \\\\\n")
cat(sprintf("Full sample & %.3f & %.3f \\\\\n", obs_lit, obs_emp))

for (j in seq_len(nrow(rob$loo_results))) {
  r <- rob$loo_results[j]
  cat(sprintf("Drop %-12s & %.3f & %.3f \\\\\n",
              r$region_name, r$lit_coef, r$emp_coef))
}
cat(sprintf("Range & [%.3f, %.3f] & [%.3f, %.3f] \\\\\n",
            min(rob$loo_results$lit_coef, na.rm = TRUE),
            max(rob$loo_results$lit_coef, na.rm = TRUE),
            min(rob$loo_results$emp_coef, na.rm = TRUE),
            max(rob$loo_results$emp_coef, na.rm = TRUE)))

cat("\\hline\\hline\n")
cat("\\end{tabular}\n")
cat("\\begin{minipage}{0.95\\textwidth}\n")
cat("\\vspace{0.2cm}\n")
cat("\\footnotesize\n")
cat("\\textit{Notes:} Panel A: Exact randomization inference. All 6! = 720 permutations of cocoa shares across\n")
cat("forest-belt regions enumerated. Two-sided $p$-value = fraction of permuted coefficients with absolute\n")
cat("value $\\geq$ observed.\n")
cat("Panel B: Each row drops one forest-belt region and re-estimates the main specification.\n")
cat("\\end{minipage}\n")
cat("\\end{table}\n")
sink()
cat("Table 8 (RI + LOO) saved.\n")

cat("\nAll tables saved to:", TABLE_DIR, "\n")
list.files(TABLE_DIR)
