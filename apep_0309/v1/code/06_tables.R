## ============================================================
## 06_tables.R
## LaTeX tables for PDMP Network Spillovers paper
## ============================================================

source("00_packages.R")

data_dir <- "../data/"
table_dir <- "../tables/"
dir.create(table_dir, showWarnings = FALSE, recursive = TRUE)

panel <- read_csv(paste0(data_dir, "analysis_panel.csv"), show_col_types = FALSE)
results <- readRDS(paste0(data_dir, "main_results.rds"))
rob_results <- readRDS(paste0(data_dir, "robustness_results.rds"))

## ============================================================
## Table 1: Summary Statistics
## ============================================================

cat("Table 1: Summary statistics...\n")

sum_stats <- panel %>%
  filter(year >= 2006, !is.na(total_overdose_rate)) %>%
  summarise(
    across(
      c(total_overdose_rate, share_neighbors_pdmp, own_pdmp,
        pop, median_hh_income, pct_bachelors, pct_white,
        pct_uninsured, unemployment_rate, degree,
        has_naloxone, has_good_samaritan, has_medicaid_expansion),
      list(
        mean = ~mean(.x, na.rm = TRUE),
        sd = ~sd(.x, na.rm = TRUE),
        min = ~min(.x, na.rm = TRUE),
        max = ~max(.x, na.rm = TRUE)
      ),
      .names = "{.col}__{.fn}"
    ),
    N = n(),
    n_states = n_distinct(state_abbr)
  )

# Format LaTeX table
tab1_lines <- c(
  "\\begin{table}[htbp]",
  "\\centering",
  "\\caption{Summary Statistics}",
  "\\label{tab:summary}",
  "\\begin{tabular}{lcccc}",
  "\\toprule",
  " & Mean & SD & Min & Max \\\\",
  "\\midrule",
  "\\multicolumn{5}{l}{\\textit{Panel A: Outcomes (per 100,000)}} \\\\[3pt]"
)

# Helper function
fmt <- function(prefix, digits = 1) {
  paste0(
    round(sum_stats[[paste0(prefix, "__mean")]], digits), " & ",
    round(sum_stats[[paste0(prefix, "__sd")]], digits), " & ",
    round(sum_stats[[paste0(prefix, "__min")]], digits), " & ",
    round(sum_stats[[paste0(prefix, "__max")]], digits)
  )
}

tab1_lines <- c(tab1_lines,
  paste0("Total overdose death rate & ", fmt("total_overdose_rate"), " \\\\"),
  "\\\\",
  "\\multicolumn{5}{l}{\\textit{Panel B: Treatment Variables}} \\\\[3pt]",
  paste0("Share neighbors with PDMP & ", fmt("share_neighbors_pdmp", 3), " \\\\"),
  paste0("Own PDMP mandate & ", fmt("own_pdmp", 3), " \\\\"),
  paste0("Network degree (neighbors) & ", fmt("degree", 1), " \\\\"),
  "\\\\",
  "\\multicolumn{5}{l}{\\textit{Panel C: Covariates}} \\\\[3pt]",
  paste0("Population (thousands) & ",
         round(sum_stats$pop__mean / 1000, 0), " & ",
         round(sum_stats$pop__sd / 1000, 0), " & ",
         round(sum_stats$pop__min / 1000, 0), " & ",
         round(sum_stats$pop__max / 1000, 0), " \\\\"),
  paste0("Median household income (\\$) & ",
         format(round(sum_stats$median_hh_income__mean, 0), big.mark = ","), " & ",
         format(round(sum_stats$median_hh_income__sd, 0), big.mark = ","), " & ",
         format(round(sum_stats$median_hh_income__min, 0), big.mark = ","), " & ",
         format(round(sum_stats$median_hh_income__max, 0), big.mark = ","), " \\\\"),
  paste0("Bachelor's degree (\\%) & ", fmt("pct_bachelors"), " \\\\"),
  paste0("White (\\%) & ", fmt("pct_white"), " \\\\"),
  paste0("Uninsured (\\%) & ", fmt("pct_uninsured"), " \\\\"),
  paste0("Unemployment rate (\\%) & ", fmt("unemployment_rate"), " \\\\"),
  "\\\\",
  "\\multicolumn{5}{l}{\\textit{Panel D: Concurrent Policies}} \\\\[3pt]",
  paste0("Naloxone access law & ", fmt("has_naloxone", 3), " \\\\"),
  paste0("Good Samaritan law & ", fmt("has_good_samaritan", 3), " \\\\"),
  paste0("Medicaid expansion & ", fmt("has_medicaid_expansion", 3), " \\\\"),
  "\\midrule",
  paste0("State-years & \\multicolumn{4}{c}{", sum_stats$N, "} \\\\"),
  paste0("States & \\multicolumn{4}{c}{", sum_stats$n_states, "} \\\\"),
  "\\bottomrule",
  "\\end{tabular}",
  "\\begin{tablenotes}",
  "\\small",
  "\\item \\textit{Notes:} Sample consists of contiguous U.S.\\ states (excluding Alaska and Hawaii), 2011--2023. Overdose death rate is age-adjusted deaths per 100,000 population from CDC VSRR/NCHS. Share neighbors with PDMP is the fraction of contiguous neighboring states with active must-query PDMP mandates. Concurrent policies are binary indicators for active naloxone access, Good Samaritan, and Medicaid expansion laws.",
  "\\end{tablenotes}",
  "\\end{table}"
)

writeLines(tab1_lines, paste0(table_dir, "tab1_summary.tex"))

## ============================================================
## Table 2: Main Results — TWFE and CS-DiD
## ============================================================

cat("Table 2: Main results...\n")

# Use fixest etable for clean output
etable(
  results$twfe_total,
  results$twfe_cont,
  results$twfe_popw,
  title = "PDMP Network Exposure and Total Overdose Death Rate",
  headers = c("Binary (50\\%)", "Continuous", "Pop-Weighted"),
  depvar = FALSE,
  style.tex = style.tex("aer"),
  dict = c(
    high_exposure_50 = "High network exposure ($\\geq$50\\%)",
    share_neighbors_pdmp = "Network exposure (continuous)",
    share_neighbors_pdmp_popw = "Network exposure (pop-weighted)",
    own_pdmp = "Own PDMP mandate",
    has_naloxone = "Naloxone access law",
    has_good_samaritan = "Good Samaritan law",
    has_medicaid_expansion = "Medicaid expansion"
  ),
  notes = c(
    "Standard errors clustered at the state level in parentheses.",
    "All specifications include state and year fixed effects.",
    "$^{***}p<0.01$, $^{**}p<0.05$, $^{*}p<0.1$"
  ),
  label = "tab:main",
  file = paste0(table_dir, "tab2_main_results.tex"),
  replace = TRUE
)

## ============================================================
## Table 3: Drug-Type Decomposition
## ============================================================

cat("Table 3: Drug-type decomposition...\n")

drug_names <- names(results$drug_results)

if (length(drug_names) >= 3) {
  etable(
    results$drug_results[drug_names],
    title = "Network Exposure Effects by Drug Type (2015--2023)",
    headers = gsub("_rate", "", drug_names),
    depvar = FALSE,
    keep = "%high_exposure_50",
    style.tex = style.tex("aer"),
    dict = c(
      high_exposure_50 = "High network exposure ($\\geq$50\\%)"
    ),
    notes = c(
      "Each column reports a separate TWFE regression for the specified drug type.",
      "Standard errors clustered at the state level in parentheses.",
      "All specifications include state and year FE and concurrent policy controls.",
      "$^{***}p<0.01$, $^{**}p<0.05$, $^{*}p<0.1$"
    ),
    label = "tab:drugs",
    file = paste0(table_dir, "tab3_drug_decomposition.tex"),
    replace = TRUE
  )
}

## ============================================================
## Table 4: Robustness — Alternative Thresholds
## ============================================================

cat("Table 4: Robustness thresholds...\n")

etable(
  rob_results$threshold_results[["high_exposure_25"]],
  rob_results$threshold_results[["high_exposure_50"]],
  rob_results$threshold_results[["high_exposure_75"]],
  title = "Robustness: Alternative Network Exposure Thresholds",
  headers = c("$\\geq$25\\%", "$\\geq$50\\%", "$\\geq$75\\%"),
  depvar = FALSE,
  keep = "%high_exposure",
  style.tex = style.tex("aer"),
  dict = c(
    high_exposure_25 = "Network exposure ($\\geq$25\\%)",
    high_exposure_50 = "Network exposure ($\\geq$50\\%)",
    high_exposure_75 = "Network exposure ($\\geq$75\\%)"
  ),
  notes = c(
    "Each column uses a different threshold for the binary network exposure indicator.",
    "Standard errors clustered at the state level in parentheses.",
    "$^{***}p<0.01$, $^{**}p<0.05$, $^{*}p<0.1$"
  ),
  label = "tab:thresholds",
  file = paste0(table_dir, "tab4_thresholds.tex"),
  replace = TRUE
)

## ============================================================
## Table 5: Period Split and Heterogeneity
## ============================================================

cat("Table 5: Period splits and heterogeneity...\n")

etable(
  rob_results$period_pre,
  rob_results$period_post,
  results$het_degree,
  title = "Heterogeneity: Period Splits and Network Position",
  headers = c("Pre-Fentanyl\\\\(2011--2013)", "Fentanyl Era\\\\(2014--2023)", "Degree\\\\Interaction"),
  depvar = FALSE,
  keep = c("%high_exposure_50", "%high_degree", "%high_exposure_50:high_degree"),
  style.tex = style.tex("aer"),
  dict = c(
    high_exposure_50 = "High network exposure",
    high_degree = "High degree centrality",
    "high_exposure_50:high_degree" = "Exposure $\\times$ high degree"
  ),
  notes = c(
    "Pre-fentanyl: 2011--2013; fentanyl era: 2014--2023.",
    "High degree centrality: above-median number of contiguous neighbors.",
    "Standard errors clustered at the state level in parentheses.",
    "$^{***}p<0.01$, $^{**}p<0.05$, $^{*}p<0.1$"
  ),
  label = "tab:heterogeneity",
  file = paste0(table_dir, "tab5_heterogeneity.tex"),
  replace = TRUE
)

## ============================================================
## Table A1: PDMP Must-Query Mandate Adoption Dates
## ============================================================

cat("Table A1: PDMP adoption dates...\n")

pdmp <- read_csv(paste0(data_dir, "pdmp_must_query_dates.csv"), show_col_types = FALSE)

pdmp_sorted <- pdmp %>% arrange(must_query_year, state_name)

tab_a1 <- c(
  "\\begin{table}[htbp]",
  "\\centering",
  "\\caption{PDMP Must-Query Mandate Adoption Dates}",
  "\\label{tab:pdmp_dates}",
  "\\begin{tabular}{llc}",
  "\\toprule",
  "State & Abbreviation & Must-Query Year \\\\",
  "\\midrule"
)

for (i in 1:nrow(pdmp_sorted)) {
  tab_a1 <- c(tab_a1, paste0(
    pdmp_sorted$state_name[i], " & ",
    pdmp_sorted$state[i], " & ",
    pdmp_sorted$must_query_year[i], " \\\\"
  ))
}

tab_a1 <- c(tab_a1,
  "\\midrule",
  "\\multicolumn{3}{l}{\\textit{States without must-query mandate (as of 2023):}} \\\\",
  "\\multicolumn{3}{l}{Alaska, Kansas, Missouri, Montana, Nebraska, Oregon} \\\\",
  "\\bottomrule",
  "\\end{tabular}",
  "\\begin{tablenotes}",
  "\\small",
  "\\item \\textit{Sources:} PDAPS (pdaps.org), Buchmueller \\& Carey (2018),",
  "Wen et al.\\ (2019), PDMP TTAC (pdmpassist.org).",
  "\\end{tablenotes}",
  "\\end{table}"
)

writeLines(tab_a1, paste0(table_dir, "tab_a1_pdmp_dates.tex"))

## ============================================================
## Table A2: Placebo Tests
## ============================================================

cat("Table A2: Placebo tests...\n")

etable(
  rob_results$placebo_pop,
  rob_results$placebo_income,
  title = "Placebo Tests: Non-Drug Outcomes",
  headers = c("log(Population)", "log(Median Income)"),
  depvar = FALSE,
  keep = "%high_exposure_50",
  style.tex = style.tex("aer"),
  dict = c(high_exposure_50 = "High network exposure ($\\geq$50\\%)"),
  notes = c(
    "PDMP network exposure should not predict population or income changes.",
    "Non-zero coefficients would suggest confounding.",
    "Standard errors clustered at the state level in parentheses.",
    "$^{***}p<0.01$, $^{**}p<0.05$, $^{*}p<0.1$"
  ),
  label = "tab:placebo",
  file = paste0(table_dir, "tab_a2_placebo.tex"),
  replace = TRUE
)

cat("\n==============================\n")
cat("All tables saved to:", table_dir, "\n")
cat("==============================\n")
