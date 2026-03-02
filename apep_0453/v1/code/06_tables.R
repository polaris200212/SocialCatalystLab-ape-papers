# ============================================================
# 06_tables.R — All table generation
# apep_0453: Demonetization and Banking Infrastructure
# ============================================================

source("00_packages.R")
load("../data/analysis_panel.RData")
load("../data/main_results.RData")
load("../data/robustness_results.RData")

tab_dir <- "../tables"

# Professional variable name dictionary for etable
setFixest_dict(c(
  bank_per_100k = "Bank Branches/100k",
  bank_gov_per_100k = "Govt Bank Branches/100k",
  post = "Post",
  post_placebo = "Post (Placebo 2014)",
  urban_proxy2 = "Non-Ag Worker Share",
  log_nl = "Log Nightlights",
  ag_share = "Ag Worker Share",
  dist_id = "District",
  year = "Year",
  state_id = "State"
))

# ============================================================
# TABLE 1: Summary Statistics
# ============================================================

cat("Table 1: Summary statistics\n")

# Panel A: District characteristics (cross-section, N=640)
# Fill bank_total NA with 0 for 5 districts missing TD data (consistent with bank_per_100k=0)
baseline[is.na(bank_total), bank_total := 0]
base_vars <- baseline[, .(
  pop_total, bank_per_100k, bank_total, lit_rate, ag_share,
  sc_share, st_share, work_rate
)]

sum_stats <- data.frame(
  Variable = c("Population (Census 2011)",
               "Bank branches per 100K pop",
               "Total bank branches",
               "Literacy rate",
               "Agricultural worker share",
               "SC population share",
               "ST population share",
               "Worker participation rate"),
  N = sapply(base_vars, function(x) sum(!is.na(x))),
  Mean = sapply(base_vars, mean, na.rm = TRUE),
  SD = sapply(base_vars, sd, na.rm = TRUE),
  Min = sapply(base_vars, min, na.rm = TRUE),
  P25 = sapply(base_vars, quantile, probs = 0.25, na.rm = TRUE),
  Median = sapply(base_vars, median, na.rm = TRUE),
  P75 = sapply(base_vars, quantile, probs = 0.75, na.rm = TRUE),
  Max = sapply(base_vars, max, na.rm = TRUE)
)

# Panel B: Nightlight outcomes (panel, N~7600)
nl_vars <- panel[, .(log_nl, nl_sum)]
nl_stats <- data.frame(
  Variable = c("Log nightlights", "Nightlight sum (VIIRS)"),
  N = sapply(nl_vars, function(x) sum(!is.na(x))),
  Mean = sapply(nl_vars, mean, na.rm = TRUE),
  SD = sapply(nl_vars, sd, na.rm = TRUE),
  Min = sapply(nl_vars, min, na.rm = TRUE),
  P25 = sapply(nl_vars, quantile, probs = 0.25, na.rm = TRUE),
  Median = sapply(nl_vars, median, na.rm = TRUE),
  P75 = sapply(nl_vars, quantile, probs = 0.75, na.rm = TRUE),
  Max = sapply(nl_vars, max, na.rm = TRUE)
)

all_stats <- rbind(sum_stats, nl_stats)

# Write LaTeX table
sink(file.path(tab_dir, "tab1_summary_stats.tex"))
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Summary Statistics}\n")
cat("\\label{tab:summary}\n")
cat("\\small\n")
cat("\\begin{tabular}{lrrrrrr}\n")
cat("\\hline\\hline\n")
cat(" & N & Mean & SD & P25 & Median & P75 \\\\\n")
cat("\\hline\n")
cat("\\multicolumn{7}{l}{\\textit{Panel A: District Characteristics (Census 2011)}} \\\\\n")
for (i in 1:nrow(sum_stats)) {
  cat(sprintf("%-35s & %d & %.3f & %.3f & %.3f & %.3f & %.3f \\\\\n",
    sum_stats$Variable[i], sum_stats$N[i],
    sum_stats$Mean[i], sum_stats$SD[i],
    sum_stats$P25[i], sum_stats$Median[i], sum_stats$P75[i]))
}
cat("\\hline\n")
cat("\\multicolumn{7}{l}{\\textit{Panel B: Nightlight Outcomes (2012--2023 panel)}} \\\\\n")
for (i in 1:nrow(nl_stats)) {
  cat(sprintf("%-35s & %d & %.3f & %.3f & %.3f & %.3f & %.3f \\\\\n",
    nl_stats$Variable[i], nl_stats$N[i],
    nl_stats$Mean[i], nl_stats$SD[i],
    nl_stats$P25[i], nl_stats$Median[i], nl_stats$P75[i]))
}
cat("\\hline\\hline\n")
cat("\\end{tabular}\n")
cat("\\begin{minipage}{0.95\\textwidth}\n")
cat("\\footnotesize\n")
cat("\\textit{Notes:} Panel A shows cross-sectional characteristics of 640 Indian districts from Census 2011.\n")
cat("Banking data from the Census 2011 Town Directory. Panel B shows district-year observations\n")
cat("from VIIRS annual nightlights (2012--2023). All data from SHRUG v2.1.\n")
cat("\\end{minipage}\n")
cat("\\end{table}\n")
sink()

# ============================================================
# TABLE 2: Main Results
# ============================================================

cat("Table 2: Main regression results\n")

# Use etable from fixest
etable(did_short, did_controls, did_split,
       vcov = ~state_id,
       title = "Main Results: Banking Infrastructure and Post-Demonetization Nightlights",
       headers = c("Baseline DiD", "With Controls", "Split Period"),
       drop = "factor|log_pop|lit_rate|ag_share|sc_share",
       notes = "All regressions include district and year fixed effects. Standard errors clustered at state level (35 clusters). Banking intensity measured as bank branches per 100,000 population from Census 2011. Column 2 includes log population, literacy rate, agricultural share, and SC share, each interacted with year indicators (44 coefficients suppressed).",
       label = "tab:main",
       file = file.path(tab_dir, "tab2_main_results.tex"),
       replace = TRUE)

# ============================================================
# TABLE 3: Heterogeneity
# ============================================================

cat("Table 3: Heterogeneity results\n")

# Re-estimate heterogeneity models so fixest can access the data
panel[, high_ag := as.integer(ag_share >= median(baseline$ag_share, na.rm = TRUE))]

het_ag_high_r <- feols(
  log_nl ~ bank_per_100k:post | dist_id + year,
  data = panel[high_ag == 1], cluster = ~state_id
)
het_ag_low_r <- feols(
  log_nl ~ bank_per_100k:post | dist_id + year,
  data = panel[high_ag == 0], cluster = ~state_id
)
ddd_r <- feols(
  log_nl ~ bank_per_100k:post + bank_per_100k:post:ag_share |
    dist_id + year,
  data = panel, cluster = ~state_id
)

etable(het_ag_high_r, het_ag_low_r, ddd_r,
       vcov = ~state_id,
       title = "Heterogeneity by Agricultural Structure",
       headers = c("High Ag Districts", "Low Ag Districts", "Triple-Diff"),
       notes = "High (Low) agriculture = above (below) median agricultural worker share. Standard errors clustered at state level (35 clusters).",
       label = "tab:heterogeneity",
       file = file.path(tab_dir, "tab3_heterogeneity.tex"),
       replace = TRUE)

# ============================================================
# TABLE 4: Robustness
# ============================================================

cat("Table 4: Robustness checks\n")

# Re-estimate robustness models in current environment
panel_pre <- panel[year <= 2016]
panel_pre[, post_placebo := as.integer(year >= 2015)]

rob_baseline <- feols(
  log_nl ~ bank_per_100k:post | dist_id + year,
  data = panel, cluster = ~state_id
)
rob_placebo <- feols(
  log_nl ~ bank_per_100k:post_placebo | dist_id + year,
  data = panel_pre, cluster = ~state_id
)

panel[, bank_gov_per_100k := baseline$bank_gov[match(dist_id,
  paste0(baseline$pc11_state_id, "_", baseline$pc11_district_id))] /
  baseline$pop_total[match(dist_id,
  paste0(baseline$pc11_state_id, "_", baseline$pc11_district_id))] * 100000]
# Impute 0 for 5 districts missing TD data (consistent with bank_per_100k treatment)
panel[is.na(bank_gov_per_100k), bank_gov_per_100k := 0]

rob_gov <- feols(
  log_nl ~ bank_gov_per_100k:post | dist_id + year,
  data = panel, cluster = ~state_id
)

q05 <- quantile(baseline$bank_per_100k, 0.05, na.rm = TRUE)
q95 <- quantile(baseline$bank_per_100k, 0.95, na.rm = TRUE)
trim_dists <- baseline[bank_per_100k >= q05 & bank_per_100k <= q95]$pc11_district_id
rob_trim <- feols(
  log_nl ~ bank_per_100k:post | dist_id + year,
  data = panel[pc11_district_id %in% trim_dists], cluster = ~state_id
)

rob_precovid <- feols(
  log_nl ~ bank_per_100k:post | dist_id + year,
  data = panel[year <= 2019], cluster = ~state_id
)

panel[, urban_proxy2 := nonag_share]
rob_urban <- feols(
  log_nl ~ bank_per_100k:post + urban_proxy2:post | dist_id + year,
  data = panel[!is.na(urban_proxy2)], cluster = ~state_id
)

etable(rob_baseline, rob_placebo, rob_gov, rob_trim, rob_precovid, rob_urban,
       vcov = ~state_id,
       title = "Robustness Checks",
       headers = c("Baseline", "Placebo 2014", "Govt Banks", "Trimmed", "Pre-COVID", "Urban Ctrl"),
       notes = paste0("All regressions include district and year fixed effects. Standard errors clustered at state level (35 clusters). ",
                      "Randomization inference p-value $< 0.01$ (500 permutations, exact: ", round(ri_pvalue, 4), ")."),
       label = "tab:robustness",
       file = file.path(tab_dir, "tab4_robustness.tex"),
       replace = TRUE)

# ============================================================
# TABLE 5: Balance Table (Pre-2016 characteristics by banking quartile)
# ============================================================

cat("Table 5: Balance table\n")

baseline[, bank_q := bank_quartile]
bal <- baseline[!is.na(bank_q), .(
  `Mean Pop (millions)` = mean(pop_total / 1e6, na.rm = TRUE),
  `Literacy Rate` = mean(lit_rate, na.rm = TRUE),
  `Ag Worker Share` = mean(ag_share, na.rm = TRUE),
  `SC Share` = mean(sc_share, na.rm = TRUE),
  `ST Share` = mean(st_share, na.rm = TRUE),
  `Work Rate` = mean(work_rate, na.rm = TRUE),
  N = .N
), by = bank_q]

sink(file.path(tab_dir, "tab5_balance.tex"))
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{District Characteristics by Banking Infrastructure Quartile}\n")
cat("\\label{tab:balance}\n")
cat("\\small\n")
cat("\\begin{tabular}{lcccc}\n")
cat("\\hline\\hline\n")
cat(" & Q1 (Lowest) & Q2 & Q3 & Q4 (Highest) \\\\\n")
cat("\\hline\n")
for (v in c("Mean Pop (millions)", "Literacy Rate", "Ag Worker Share",
            "SC Share", "ST Share", "Work Rate", "N")) {
  vals <- bal[[v]]
  if (v == "N") {
    cat(sprintf("%-25s & %d & %d & %d & %d \\\\\n", v, vals[1], vals[2], vals[3], vals[4]))
  } else {
    cat(sprintf("%-25s & %.3f & %.3f & %.3f & %.3f \\\\\n", v, vals[1], vals[2], vals[3], vals[4]))
  }
}
cat("\\hline\\hline\n")
cat("\\end{tabular}\n")
cat("\\begin{minipage}{0.85\\textwidth}\n")
cat("\\footnotesize\n")
cat("\\textit{Notes:} Districts grouped by quartiles of bank branches per 100,000 population (Census 2011).\n")
cat("All variables from Census 2011 Primary Census Abstract and Town Directory via SHRUG.\n")
cat("\\end{minipage}\n")
cat("\\end{table}\n")
sink()

cat("\n=== All tables saved to", tab_dir, "===\n")
