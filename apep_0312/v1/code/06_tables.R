## 06_tables.R — All table generation
## APEP-0310: Workers' Compensation and Industrial Safety

source("code/00_packages.R")

ipums_analysis <- fread(file.path(DATA_DIR, "ipums_analysis.csv"))
state_covs     <- fread(file.path(DATA_DIR, "state_covariates_1910.csv"))
wc_dates       <- fread(file.path(DATA_DIR, "workers_comp_dates.csv"))

# Load results
if (file.exists(file.path(DATA_DIR, "main_results.rds"))) {
  results <- readRDS(file.path(DATA_DIR, "main_results.rds"))
} else {
  results <- readRDS(file.path(DATA_DIR, "ipums_results.rds"))
}

# Load robustness results if available
robust <- if (file.exists(file.path(DATA_DIR, "robustness_results.rds"))) {
  readRDS(file.path(DATA_DIR, "robustness_results.rds"))
} else NULL

# =============================================================================
# TABLE 1: Summary Statistics — Newspaper Panel
# =============================================================================

news_clean_file <- file.path(DATA_DIR, "newspaper_clean.csv")
if (file.exists(news_clean_file)) {
  news_clean <- fread(news_clean_file)
  news_summary <- news_clean[, .(
    mean_accident = round(mean(accident_index, na.rm = TRUE), 2),
    sd_accident = round(sd(accident_index, na.rm = TRUE), 2),
    mean_mine = round(mean(mine_pages, na.rm = TRUE), 1),
    mean_factory = round(mean(factory_pages, na.rm = TRUE), 1),
    mean_total = round(mean(total_pages, na.rm = TRUE), 0),
    n_obs = .N
  ), by = .(Period = fifelse(year < 1911, "Pre-1911", "1911-1920"))]

  tab1_lines <- c(
    "\\begin{table}[ht]",
    "\\centering",
    "\\caption{Summary Statistics: Historical Newspaper Coverage of Industrial Accidents}",
    "\\label{tab:newspaper_summary}",
    "\\begin{tabular}{lcccccc}",
    "\\hline\\hline",
    " & \\multicolumn{2}{c}{Accident Index} & Mine & Factory & Total & \\\\",
    "Period & Mean & Std. Dev. & Pages & Pages & Pages & N \\\\",
    "\\hline"
  )

  for (i in 1:nrow(news_summary)) {
    row <- news_summary[i]
    tab1_lines <- c(tab1_lines, sprintf(
      "%s & %.2f & %.2f & %.1f & %.1f & %s & %s \\\\",
      row$Period, row$mean_accident, row$sd_accident,
      row$mean_mine, row$mean_factory,
      format(row$mean_total, big.mark = ","),
      format(row$n_obs, big.mark = ",")
    ))
  }

  tab1_lines <- c(tab1_lines,
    "\\hline\\hline",
    "\\end{tabular}",
    "\\begin{minipage}{0.9\\textwidth}",
    "\\vspace{0.3cm}",
    "\\footnotesize \\textit{Notes:} Data from the Library of Congress Chronicling America digital newspaper archive. The Accident Index measures the number of newspaper pages containing the phrase ``industrial accident'' per 1,000 total newspaper pages in a state-year. Sample restricted to states with adequate newspaper coverage (at least 100 pages in 15 or more years).",
    "\\end{minipage}",
    "\\end{table}"
  )

  writeLines(tab1_lines, file.path(TAB_DIR, "tab1_newspaper_summary.tex"))
  cat("Table 1 saved\n")
} else {
  # Placeholder table
  tab1_lines <- c(
    "\\begin{table}[ht]",
    "\\centering",
    "\\caption{Summary Statistics: Historical Newspaper Coverage of Industrial Accidents}",
    "\\label{tab:newspaper_summary}",
    "\\begin{tabular}{lcccccc}",
    "\\hline\\hline",
    " & \\multicolumn{2}{c}{Accident Index} & Mine & Factory & Total & \\\\",
    "Period & Mean & Std. Dev. & Pages & Pages & Pages & N \\\\",
    "\\hline",
    "\\multicolumn{7}{c}{\\textit{Newspaper data being processed}} \\\\",
    "\\hline\\hline",
    "\\end{tabular}",
    "\\end{table}"
  )
  writeLines(tab1_lines, file.path(TAB_DIR, "tab1_newspaper_summary.tex"))
  cat("Table 1 saved (placeholder)\n")
}

# =============================================================================
# TABLE 2: Summary Statistics — IPUMS Census Analysis Sample
# =============================================================================

ipums_summary <- ipums_analysis[, .(
  N = format(.N, big.mark = ","),
  age_mean = round(weighted.mean(AGE, PERWT), 1),
  pct_white = round(weighted.mean(white, PERWT) * 100, 1),
  pct_foreign = round(weighted.mean(foreign_born, PERWT) * 100, 1),
  pct_literate = round(weighted.mean(literate, PERWT) * 100, 1),
  pct_married = round(weighted.mean(married, PERWT) * 100, 1),
  pct_urban = round(weighted.mean(urban, PERWT) * 100, 1),
  pct_dangerous = round(weighted.mean(dangerous_occ, PERWT) * 100, 1),
  mean_occscore = round(weighted.mean(occ_income, PERWT, na.rm = TRUE), 1)
), by = YEAR]

tab2_lines <- c(
  "\\begin{table}[ht]",
  "\\centering",
  "\\caption{Summary Statistics: IPUMS Census Analysis Sample}",
  "\\label{tab:ipums_summary}",
  "\\begin{tabular}{lcc}",
  "\\hline\\hline",
  " & 1910 & 1920 \\\\",
  "\\hline"
)

vars <- c("N", "age_mean", "pct_white", "pct_foreign", "pct_literate",
          "pct_married", "pct_urban", "pct_dangerous", "mean_occscore")
labels <- c("Observations", "Mean age", "White (\\%)", "Foreign-born (\\%)",
            "Literate (\\%)", "Married (\\%)", "Urban (\\%)",
            "Dangerous occupation (\\%)", "Occ. income score")

for (j in seq_along(vars)) {
  v1 <- ipums_summary[YEAR == 1910, get(vars[j])]
  v2 <- ipums_summary[YEAR == 1920, get(vars[j])]
  tab2_lines <- c(tab2_lines, sprintf("%s & %s & %s \\\\", labels[j], v1, v2))
}

tab2_lines <- c(tab2_lines,
  "\\hline\\hline",
  "\\end{tabular}",
  "\\begin{minipage}{0.85\\textwidth}",
  "\\vspace{0.3cm}",
  "\\footnotesize \\textit{Notes:} Sample restricted to males aged 18--65 in the labor force with non-farm occupations. Data from IPUMS USA 1\\% samples (1910: us1910k; 1920: us1920a). Dangerous occupations include mining, manufacturing operatives, construction, railroad, and lumbering, classified by OCC1950 codes. Occupational income score (OCCSCORE) measures median 1950 income for each occupation category (in hundreds of dollars).",
  "\\end{minipage}",
  "\\end{table}"
)

writeLines(tab2_lines, file.path(TAB_DIR, "tab2_ipums_summary.tex"))
cat("Table 2 saved\n")

# =============================================================================
# TABLE 3: Main Results — DR Estimates
# =============================================================================

dr_d <- results$dr_dangerous
dr_i <- results$dr_income

# Check if newspaper results exist
has_news <- !is.null(results$overall_att)

tab3_lines <- c(
  "\\begin{table}[ht]",
  "\\centering",
  "\\caption{Main Results: Doubly Robust Estimates of Workers' Compensation Effects}",
  "\\label{tab:main_results}",
  "\\begin{tabular}{lccc}",
  "\\hline\\hline",
  " & (1) & (2) & (3) \\\\",
  " & Accident Coverage & Dangerous Occ. & Occ. Income \\\\",
  " & (Newspaper Index) & (IPUMS) & Score (IPUMS) \\\\",
  "\\hline"
)

if (has_news) {
  overall <- results$overall_att
  tab3_lines <- c(tab3_lines,
    sprintf("Workers' comp effect & %.3f & %.4f & %.3f \\\\",
            overall$overall.att, dr_d$ATT, dr_i$ATT),
    sprintf(" & (%.3f) & (%.4f) & (%.3f) \\\\",
            overall$overall.se, dr_d$se, dr_i$se)
  )
} else {
  tab3_lines <- c(tab3_lines,
    sprintf("Workers' comp effect & --- & %.4f & %.4f \\\\",
            dr_d$ATT, dr_i$ATT),
    sprintf(" & --- & (%.4f) & (%.4f) \\\\",
            dr_d$se, dr_i$se)
  )
}

tab3_lines <- c(tab3_lines,
  " & & & \\\\",
  "\\hline",
  sprintf("Estimator & %s & DRDID & DRDID \\\\",
          ifelse(has_news, "CS-AIPW", "---")),
  "Data source & Newspapers & Census & Census \\\\",
  sprintf("Panel structure & %s & Rep. cross-sect. & Rep. cross-sect. \\\\",
          ifelse(has_news, "State-year", "---")),
  "Covariates & State-level & Individual & Individual \\\\",
  sprintf("N & %s & %s & %s \\\\",
          ifelse(has_news, "---", "---"),
          format(nrow(na.omit(ipums_analysis[adoption_cohort > 0 | adoption_year > 1920,
            .(dangerous_occ, AGE, white, foreign_born, literate, married, urban, YEAR,
              treat = fifelse(adoption_cohort > 0 & adoption_cohort <= 1920, 1L, 0L))])),
            big.mark = ","),
          format(nrow(na.omit(ipums_analysis[adoption_cohort > 0 | adoption_year > 1920,
            .(occ_income, AGE, white, foreign_born, literate, married, urban, YEAR,
              treat = fifelse(adoption_cohort > 0 & adoption_cohort <= 1920, 1L, 0L))])),
            big.mark = ",")),
  "\\hline\\hline",
  "\\end{tabular}",
  "\\begin{minipage}{0.9\\textwidth}",
  "\\vspace{0.3cm}",
  "\\footnotesize \\textit{Notes:} Column (1) reports the overall ATT from the Callaway and Sant'Anna (2021) estimator with doubly robust (AIPW) estimation, using ``not-yet-treated'' states as the comparison group. State-level covariates include 1910 urbanization rate, manufacturing share, and mining share. Columns (2) and (3) report the ATT from the Sant'Anna and Zhao (2020) improved doubly robust estimator for repeated cross-sections, comparing 1910 to 1920. Individual covariates include age, age squared, race, nativity, literacy, marital status, and urban residence. Standard errors in parentheses (bootstrapped for column 1; analytical for columns 2--3).",
  "\\end{minipage}",
  "\\end{table}"
)

writeLines(tab3_lines, file.path(TAB_DIR, "tab3_main_results.tex"))
cat("Table 3 saved\n")

# =============================================================================
# TABLE 4: State-Level Covariates by Adoption Cohort
# =============================================================================

state_covs[, cohort := fcase(
  adoption_year <= 1913, "Early (1911-1913)",
  adoption_year <= 1915, "Mid (1914-1915)",
  adoption_year <= 1920, "Late (1917-1920)",
  default = "Never (post-1920)"
)]

cohort_balance <- state_covs[, .(
  n_states = .N,
  mean_pop = round(mean(pop_1910, na.rm = TRUE) / 1000, 0),
  mean_urban = round(mean(pct_urban_1910, na.rm = TRUE), 1),
  mean_foreign = round(mean(pct_foreign_1910, na.rm = TRUE), 1),
  mean_mfg = round(mean(pct_manufacturing_1910, na.rm = TRUE), 1),
  mean_mining = round(mean(pct_mining_1910, na.rm = TRUE), 1)
), by = cohort]

tab4_lines <- c(
  "\\begin{table}[ht]",
  "\\centering",
  "\\caption{Pre-Treatment State Characteristics by Workers' Compensation Adoption Cohort}",
  "\\label{tab:cohort_balance}",
  "\\begin{tabular}{lccccc}",
  "\\hline\\hline",
  "Adoption Cohort & N & Pop. (1000s) & Urban (\\%) & Foreign (\\%) & Mfg. (\\%) \\\\",
  "\\hline"
)

for (i in 1:nrow(cohort_balance)) {
  row <- cohort_balance[i]
  tab4_lines <- c(tab4_lines, sprintf(
    "%s & %d & %s & %.1f & %.1f & %.1f \\\\",
    row$cohort, row$n_states,
    format(row$mean_pop, big.mark = ","),
    row$mean_urban, row$mean_foreign, row$mean_mfg
  ))
}

tab4_lines <- c(tab4_lines,
  "\\hline\\hline",
  "\\end{tabular}",
  "\\begin{minipage}{0.9\\textwidth}",
  "\\vspace{0.3cm}",
  "\\footnotesize \\textit{Notes:} State characteristics computed from IPUMS 1910 census 1\\% sample. Population in thousands. Urban, foreign-born, and manufacturing shares are population-weighted percentages. ``Never'' includes states that adopted workers' compensation after 1920 (NC, FL, SC, AR, MS). The pattern confirms selection into early adoption: early-adopting states are more urbanized, have larger foreign-born populations, and higher manufacturing employment shares.",
  "\\end{minipage}",
  "\\end{table}"
)

writeLines(tab4_lines, file.path(TAB_DIR, "tab4_cohort_balance.tex"))
cat("Table 4 saved\n")

# =============================================================================
# TABLE 5: Robustness — Alternative Specifications
# =============================================================================

tab5_lines <- c(
  "\\begin{table}[ht]",
  "\\centering",
  "\\caption{Robustness: Alternative Specifications and Samples}",
  "\\label{tab:robustness}",
  "\\begin{tabular}{lcccc}",
  "\\hline\\hline",
  " & (1) & (2) & (3) & (4) \\\\",
  " & Baseline & Early vs. & Mining & Negative \\\\",
  " & & Late & Occupation & Control \\\\",
  "\\hline"
)

if (!is.null(robust)) {
  tab5_lines <- c(tab5_lines,
    sprintf("ATT & %.4f & %.4f & %.4f & %.4f \\\\",
            dr_d$ATT,
            ifelse(!is.null(robust$dr_el), robust$dr_el$ATT, NA),
            ifelse(!is.null(robust$dr_mining), robust$dr_mining$ATT, NA),
            ifelse(!is.null(robust$dr_wc), robust$dr_wc$ATT, NA)),
    sprintf(" & (%.4f) & (%.4f) & (%.4f) & (%.4f) \\\\",
            dr_d$se,
            ifelse(!is.null(robust$dr_el), robust$dr_el$se, NA),
            ifelse(!is.null(robust$dr_mining), robust$dr_mining$se, NA),
            ifelse(!is.null(robust$dr_wc), robust$dr_wc$se, NA))
  )
} else {
  tab5_lines <- c(tab5_lines,
    sprintf("ATT & %.4f & --- & --- & --- \\\\", dr_d$ATT),
    sprintf(" & (%.4f) & --- & --- & --- \\\\", dr_d$se)
  )
}

tab5_lines <- c(tab5_lines,
  "\\hline",
  "Estimator & DRDID & DRDID & DRDID & DRDID \\\\",
  "Outcome & Dangerous occ. & Dangerous occ. & Mining occ. & White-collar \\\\",
  "\\hline\\hline",
  "\\end{tabular}",
  "\\begin{minipage}{0.9\\textwidth}",
  "\\vspace{0.3cm}",
  "\\footnotesize \\textit{Notes:} All columns use the improved doubly robust estimator of Sant'Anna and Zhao (2020) for repeated cross-sections. Column (1) reproduces the baseline estimate from Table \\ref{tab:main_results}. Column (2) compares early adopters (1911--1913) to late adopters (1914+), excluding never-treated states. Column (3) estimates the effect on mining occupation specifically. Column (4) tests the effect on white-collar occupations as a negative control (no effect expected).",
  "\\end{minipage}",
  "\\end{table}"
)

writeLines(tab5_lines, file.path(TAB_DIR, "tab5_robustness.tex"))
cat("Table 5 saved\n")

cat("\n=== All tables generated ===\n")
