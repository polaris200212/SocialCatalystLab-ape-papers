## ============================================================
## 06_tables.R — Publication-ready LaTeX tables
## APEP-0479: Durbin Amendment, Bank Restructuring, and Tellers
## ============================================================

source("00_packages.R")

data_dir <- "../data/"
tab_dir  <- "../tables/"
dir.create(tab_dir, showWarnings = FALSE, recursive = TRUE)

panel      <- readRDS(file.path(data_dir, "analysis_panel.rds"))
results    <- readRDS(file.path(data_dir, "main_results.rds"))
robustness <- readRDS(file.path(data_dir, "robustness_results.rds"))

## ---- Table 1: Summary Statistics ----

cat("Table 1: Summary statistics...\n")

# Pre-period (2005-2010) vs Post-period (2012-2019)
sum_pre <- panel %>%
  filter(year <= 2010) %>%
  summarise(
    across(c(n_branches_total, bank_emp, bank_wage, population,
             durbin_exposure, branches_pc, bank_emp_pc),
           list(mean = ~mean(.x, na.rm = TRUE),
                sd   = ~sd(.x, na.rm = TRUE)),
           .names = "{.col}_{.fn}")
  ) %>%
  mutate(period = "Pre-Durbin (2005-2010)")

sum_post <- panel %>%
  filter(year >= 2012) %>%
  summarise(
    across(c(n_branches_total, bank_emp, bank_wage, population,
             durbin_exposure, branches_pc, bank_emp_pc),
           list(mean = ~mean(.x, na.rm = TRUE),
                sd   = ~sd(.x, na.rm = TRUE)),
           .names = "{.col}_{.fn}")
  ) %>%
  mutate(period = "Post-Durbin (2012-2019)")

# Build summary table
vars <- c("n_branches_total", "bank_emp", "bank_wage", "population",
          "durbin_exposure", "branches_pc", "bank_emp_pc")
var_labels <- c("Bank Branches", "Banking Employment",
                "Average Weekly Wage (\\$)", "Population",
                "Durbin Exposure", "Branches per 100K",
                "Banking Emp. per 100K")

latex_rows <- character()
for (i in seq_along(vars)) {
  v <- vars[i]
  pre_m  <- sum_pre[[paste0(v, "_mean")]]
  pre_s  <- sum_pre[[paste0(v, "_sd")]]
  post_m <- sum_post[[paste0(v, "_mean")]]
  post_s <- sum_post[[paste0(v, "_sd")]]

  latex_rows <- c(latex_rows, sprintf(
    "%s & %.2f & (%.2f) & %.2f & (%.2f) \\\\",
    var_labels[i], pre_m, pre_s, post_m, post_s
  ))
}

n_pre  <- panel %>% filter(year <= 2010) %>% nrow()
n_post <- panel %>% filter(year >= 2012) %>% nrow()
n_counties <- n_distinct(panel$county_fips)

tab1 <- paste0(
  "\\begin{table}[htbp]\n",
  "\\centering\n",
  "\\caption{Summary Statistics}\n",
  "\\label{tab:summary}\n",
  "\\begin{tabular}{lcccc}\n",
  "\\toprule\n",
  " & \\multicolumn{2}{c}{Pre-Durbin} & \\multicolumn{2}{c}{Post-Durbin} \\\\\n",
  " & \\multicolumn{2}{c}{(2005--2010)} & \\multicolumn{2}{c}{(2012--2019)} \\\\\n",
  "\\cmidrule(lr){2-3} \\cmidrule(lr){4-5}\n",
  " & Mean & (SD) & Mean & (SD) \\\\\n",
  "\\midrule\n",
  paste(latex_rows, collapse = "\n"), "\n",
  "\\midrule\n",
  sprintf("County-years & \\multicolumn{2}{c}{%s} & \\multicolumn{2}{c}{%s} \\\\\n",
          format(n_pre, big.mark = ","), format(n_post, big.mark = ",")),
  sprintf("Counties & \\multicolumn{4}{c}{%s} \\\\\n",
          format(n_counties, big.mark = ",")),
  "\\bottomrule\n",
  "\\end{tabular}\n",
  "\\begin{minipage}{0.95\\textwidth}\n",
  "\\vspace{0.5em}\n",
  "\\footnotesize \\textit{Notes:} Banking employment and wages from BLS QCEW (NAICS 522110). ",
  "Branch counts from FDIC Summary of Deposits. ",
  "Durbin Exposure = share of 2010 county deposits in banks with assets $>$ \\$10 billion.\n",
  "\\end{minipage}\n",
  "\\end{table}\n"
)

writeLines(tab1, file.path(tab_dir, "tab1_summary.tex"))


## ---- Table 2: Main Results ----

cat("Table 2: Main results...\n")

etable(
  results$m1_branches,
  results$m2_emp,
  results$m2_emp_pc,
  results$m3_wage,
  headers = c("Log Branches/cap", "Log Bank Emp", "Log Bank Emp/cap", "Log Bank Wage"),
  se.below = TRUE,
  fitstat = c("n", "r2", "ar2"),
  dict = c(
    durbin_post = "Durbin Exposure $\\times$ Post",
    county_fips = "County FE",
    year = "Year FE"
  ),
  style.tex = style.tex("aer"),
  file = file.path(tab_dir, "tab2_main_results.tex"),
  replace = TRUE,
  title = "Effect of Durbin Exposure on Banking Outcomes",
  label = "tab:main",
  notes = paste(
    "State-clustered standard errors in parentheses.",
    "Durbin Exposure = county share of 2010 deposits in banks with assets $>$ \\$10B.",
    "Post = 1 for years $\\geq$ 2012.",
    "All specifications include county and year fixed effects.",
    "* p$<$0.10, ** p$<$0.05, *** p$<$0.01."
  )
)


## ---- Table 3: Triple-Difference ----

cat("Table 3: DDD...\n")

etable(
  results$m4_ddd,
  headers = "Log Employment",
  se.below = TRUE,
  fitstat = c("n", "r2"),
  style.tex = style.tex("aer"),
  file = file.path(tab_dir, "tab3_ddd.tex"),
  replace = TRUE,
  title = "Triple-Difference: Banking vs.\\ Non-Banking Employment",
  label = "tab:ddd",
  notes = paste(
    "State-clustered standard errors in parentheses.",
    "Stacked panel with banking, retail, and manufacturing sectors.",
    "County$\\times$sector, year$\\times$sector, and county$\\times$year FE included.",
    "* p$<$0.10, ** p$<$0.05, *** p$<$0.01."
  )
)


## ---- Table 4: Deposit Reallocation ----

cat("Table 4: Deposit reallocation...\n")

etable(
  results$m5_dep_durbin,
  results$m5_dep_exempt,
  results$m5_exempt_share,
  headers = c("Log Durbin Dep.", "Log Exempt Dep.", "Exempt Share"),
  se.below = TRUE,
  fitstat = c("n", "r2"),
  style.tex = style.tex("aer"),
  file = file.path(tab_dir, "tab4_deposits.tex"),
  replace = TRUE,
  title = "Deposit Reallocation Following Durbin Amendment",
  label = "tab:deposits",
  notes = paste(
    "State-clustered standard errors in parentheses.",
    "Columns show deposits at Durbin-affected banks ($>$\\$10B), exempt banks ($<$\\$10B),",
    "and the share of county deposits in exempt banks.",
    "* p$<$0.10, ** p$<$0.05, *** p$<$0.01."
  )
)


## ---- Table 5: Robustness ----

cat("Table 5: Robustness...\n")

etable(
  results$m2_emp,
  robustness$narrow,
  robustness$medium,
  robustness$trends,
  robustness$no_crisis,
  headers = c("Baseline", "2008--2014", "2007--2016",
              "County Trends", "No Crisis"),
  se.below = TRUE,
  fitstat = c("n", "r2"),
  style.tex = style.tex("aer"),
  file = file.path(tab_dir, "tab5_robustness.tex"),
  replace = TRUE,
  title = "Robustness: Alternative Specifications",
  label = "tab:robustness",
  notes = paste(
    "Dependent variable: Log banking employment.",
    "State-clustered standard errors in parentheses.",
    "(1) Baseline (2005--2019). (2) Narrow bandwidth. (3) Medium bandwidth.",
    "(4) County-specific linear trends. (5) Excluding top-decile crisis counties.",
    "* p$<$0.10, ** p$<$0.05, *** p$<$0.01."
  )
)


## ---- Table A1 (Appendix): Placebo Tests ----

cat("Table A1: Placebo tests...\n")

etable(
  results$m2_emp,
  robustness$placebo_retail,
  robustness$placebo_mfg,
  robustness$placebo_health,
  headers = c("Banking", "Retail", "Manufacturing", "Healthcare"),
  se.below = TRUE,
  fitstat = c("n", "r2"),
  style.tex = style.tex("aer"),
  file = file.path(tab_dir, "tab_a1_placebo.tex"),
  replace = TRUE,
  title = "Placebo Tests: Non-Banking Sectors",
  label = "tab:placebo",
  notes = paste(
    "State-clustered standard errors in parentheses.",
    "Column (1) shows the main banking result. Columns (2)--(4) show placebo sectors",
    "that should not respond to the Durbin Amendment.",
    "* p$<$0.10, ** p$<$0.05, *** p$<$0.01."
  )
)


## ---- Table A2 (Appendix): Clustering Sensitivity ----

cat("Table A2: Clustering...\n")

cluster_tab <- data.frame(
  Clustering = c("State (baseline)", "County", "State $\\times$ Year"),
  Coefficient = sprintf("%.4f", c(
    coef(results$m2_emp)["durbin_post"],
    coef(results$m2_emp)["durbin_post"],
    coef(results$m2_emp)["durbin_post"]
  )),
  SE = sprintf("(%.4f)", c(
    se(results$m2_emp)["durbin_post"],
    # Re-estimate for these
    NA, NA
  ))
)

# Actually re-run with different clustering for correct SEs
m_county_cl <- feols(log_bank_emp ~ durbin_post | county_fips + year,
                     data = panel, cluster = ~county_fips)
m_twoway_cl <- feols(log_bank_emp ~ durbin_post | county_fips + year,
                     data = panel, cluster = ~state_fips + year)

tab_a2 <- paste0(
  "\\begin{table}[htbp]\n",
  "\\centering\n",
  "\\caption{Clustering Sensitivity}\n",
  "\\label{tab:clustering}\n",
  "\\begin{tabular}{lccc}\n",
  "\\toprule\n",
  " & State & County & State $\\times$ Year \\\\\n",
  "\\midrule\n",
  sprintf("Durbin Exposure $\\times$ Post & %.4f & %.4f & %.4f \\\\\n",
          coef(results$m2_emp)["durbin_post"],
          coef(m_county_cl)["durbin_post"],
          coef(m_twoway_cl)["durbin_post"]),
  sprintf(" & (%.4f) & (%.4f) & (%.4f) \\\\\n",
          se(results$m2_emp)["durbin_post"],
          se(m_county_cl)["durbin_post"],
          se(m_twoway_cl)["durbin_post"]),
  sprintf("N & %s & %s & %s \\\\\n",
          format(nobs(results$m2_emp), big.mark = ","),
          format(nobs(m_county_cl), big.mark = ","),
          format(nobs(m_twoway_cl), big.mark = ",")),
  "\\bottomrule\n",
  "\\end{tabular}\n",
  "\\begin{minipage}{0.9\\textwidth}\n",
  "\\vspace{0.5em}\n",
  "\\footnotesize \\textit{Notes:} Dependent variable: Log banking employment. ",
  "All specifications include county and year FE. Standard errors in parentheses.\n",
  "\\end{minipage}\n",
  "\\end{table}\n"
)

writeLines(tab_a2, file.path(tab_dir, "tab_a2_clustering.tex"))

cat("\n=== All tables saved to", tab_dir, "===\n")
list.files(tab_dir)
