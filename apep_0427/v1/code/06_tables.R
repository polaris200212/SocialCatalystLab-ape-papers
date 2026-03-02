# =============================================================================
# 06_tables.R — All Table Generation
# apep_0427: France Apprenticeship Subsidy and Entry-Level Labor Markets
# =============================================================================

source("00_packages.R")

cat("=== Generating tables for apep_0427 ===\n")

# Load data and models
cross_country  <- readRDS("../data/cross_country_panel.rds")
sector_panel   <- readRDS("../data/sector_panel.rds")
models         <- readRDS("../data/main_models.rds")

# =============================================================
# Table 1: Summary Statistics
# =============================================================
cat("Table 1: Summary statistics...\n")

# Cross-country youth employment — use same sample as regressions (2015+)
cc_youth <- cross_country %>%
  filter(age_group == "Y15-24")

cc_fr <- cc_youth %>% filter(country == "FR")
cc_ctrl <- cc_youth %>% filter(country != "FR")

summ_stats <- tribble(
  ~Variable, ~Mean_FR, ~SD_FR, ~Mean_Ctrl, ~SD_Ctrl,
  "Youth employment rate (\\%)", mean(cc_fr$emp_rate, na.rm = T), sd(cc_fr$emp_rate, na.rm = T),
    mean(cc_ctrl$emp_rate, na.rm = T), sd(cc_ctrl$emp_rate, na.rm = T)
)

# Add sector-level stats
sp <- sector_panel %>% filter(!is.na(youth_share))
summ_sector <- tribble(
  ~Variable, ~Mean, ~SD, ~Min, ~Max, ~N,
  "Youth employment share (\\%)", mean(sp$youth_share, na.rm = T),
    sd(sp$youth_share, na.rm = T), min(sp$youth_share, na.rm = T),
    max(sp$youth_share, na.rm = T), sum(!is.na(sp$youth_share)),
  "Apprenticeship exposure", mean(sp$exposure, na.rm = T),
    sd(sp$exposure, na.rm = T), min(sp$exposure, na.rm = T),
    max(sp$exposure, na.rm = T), sum(!is.na(sp$exposure)),
  "Youth employment (thousands)", mean(sp$emp_youth, na.rm = T),
    sd(sp$emp_youth, na.rm = T), min(sp$emp_youth, na.rm = T),
    max(sp$emp_youth, na.rm = T), sum(!is.na(sp$emp_youth)),
  "Total employment (thousands)", mean(sp$emp_total, na.rm = T),
    sd(sp$emp_total, na.rm = T), min(sp$emp_total, na.rm = T),
    max(sp$emp_total, na.rm = T), sum(!is.na(sp$emp_total))
)

# Write LaTeX
sink("../tables/tab1_summary.tex")
cat("\\begin{table}[H]\n")
cat("\\centering\n")
cat("\\caption{Summary Statistics}\n")
cat("\\begin{threeparttable}\n")
cat("\\begin{tabular}{l S[table-format=4.1] S[table-format=4.1] S[table-format=4.1] S[table-format=4.1] S[table-format=5.0]}\n")
cat("\\toprule\n")
cat("Variable & {Mean} & {Std. Dev.} & {Min} & {Max} & {N} \\\\\n")
cat("\\midrule\n")
n_sectors <- length(unique(sp$sector))
cat(sprintf("\\multicolumn{6}{l}{\\textit{Panel A: France Sector-Quarter Panel (2015Q1--2025Q3, %d sectors)}} \\\\\n", n_sectors))
# Use more precision for exposure row to show meaningful variation
for (i in 1:nrow(summ_sector)) {
  if (grepl("exposure", summ_sector$Variable[i], ignore.case = TRUE)) {
    # Exposure is already in percentage points (1-18) after rescaling in 02_clean_data.R
    cat(sprintf("Apprenticeship exposure (\\%%) & %.1f & %.1f & %.1f & %.1f & %d \\\\\n",
                summ_sector$Mean[i], summ_sector$SD[i],
                summ_sector$Min[i], summ_sector$Max[i], summ_sector$N[i]))
  } else {
    cat(sprintf("%s & %.1f & %.1f & %.1f & %.1f & %d \\\\\n",
                summ_sector$Variable[i], summ_sector$Mean[i], summ_sector$SD[i],
                summ_sector$Min[i], summ_sector$Max[i], summ_sector$N[i]))
  }
}
cat("\\midrule\n")
cat("\\multicolumn{6}{l}{\\textit{Panel B: Cross-Country Quarterly Panel (2015Q1--2025Q3)}} \\\\\n")
cat(sprintf("Youth employment rate, France (\\%%) & %.1f & %.1f & %.1f & %.1f & %d \\\\\n",
            summ_stats$Mean_FR, summ_stats$SD_FR,
            min(cc_fr$emp_rate, na.rm = T), max(cc_fr$emp_rate, na.rm = T), nrow(cc_fr)))
cat(sprintf("Youth employment rate, Controls (\\%%) & %.1f & %.1f & %.1f & %.1f & %d \\\\\n",
            summ_stats$Mean_Ctrl, summ_stats$SD_Ctrl,
            min(cc_ctrl$emp_rate, na.rm = T), max(cc_ctrl$emp_rate, na.rm = T), nrow(cc_ctrl)))
cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{tablenotes}[flushleft]\n")
cat("\\small\n")
cat("\\item Notes: Panel A reports statistics for the France sector-quarter panel used in the Bartik DiD analysis. Apprenticeship exposure measures the 2019 share of apprenticeship contracts in sector employment (DARES/CEDEFOP), in percentage points. Regression coefficients are per percentage point of exposure. Panel B reports youth (15--24) employment rates from Eurostat LFS. Controls: Belgium, Netherlands, Spain, Italy, Portugal, Germany, Austria.\n")
cat("\\end{tablenotes}\n")
cat("\\end{threeparttable}\n")
cat("\\label{tab:summary}\n")
cat("\\end{table}\n")
sink()

# =============================================================
# Table 2: Main Results — Bartik DiD
# =============================================================
cat("Table 2: Main Bartik DiD results...\n")

setFixest_dict(c(
  bartik_reduction = "Exposure $\\times$ Post-Reduction",
  `high_exposure:post_reduction` = "High Exposure $\\times$ Post-Reduction",
  bartik_subsidy = "Exposure $\\times$ Post-Introduction",
  youth_share = "Youth Share (\\%)",
  emp_youth = "Youth Emp. (000s)",
  emp_total = "Total Emp. (000s)",
  prime_share = "Prime-Age Share (\\%)",
  sector = "Sector",
  yq = "Year-Quarter"
))

# Load prime-age placebo
m_placebo_prime <- readRDS("../data/placebo_prime_age.rds")

# Delete existing file to prevent append
unlink("../tables/tab2_main_bartik.tex")
etable(
  models$bartik_youth_share,
  models$bartik_youth_level,
  models$binary_exposure,
  models$bartik_total_placebo,
  m_placebo_prime,
  tex = TRUE,
  style.tex = style.tex("aer"),
  fitstat = ~ r2 + n,
  headers = c("Youth Share", "Youth Level", "Binary Exp.", "Total Emp.", "Prime-Age Share"),
  title = "Effect of Apprenticeship Subsidy Reduction on Employment",
  label = "tab:main_bartik",
  notes = c("Standard errors clustered at sector level in parentheses.",
            "* p$<$0.10, ** p$<$0.05, *** p$<$0.01.",
            "All specifications include sector and year-quarter fixed effects.",
            "Exposure measures 2019 sector apprenticeship intensity (DARES), in percentage points.",
            "Post-Reduction = 1 after January 2023 subsidy cut.",
            "Col 5: Prime-age (25+) employment share as placebo outcome."),
  file = "../tables/tab2_main_bartik.tex"
)

# =============================================================
# Table 3: Cross-Country DiD and Triple-Diff
# =============================================================
cat("Table 3: Cross-country results...\n")

setFixest_dict(c(
  `france:post_reduction` = "France $\\times$ Post-Reduction",
  fr_youth_reduction = "France $\\times$ Youth $\\times$ Post-Reduction",
  `france:post_subsidy` = "France $\\times$ Post-Introduction",
  emp_rate = "Emp. Rate (\\%)",
  neet_rate = "NEET Rate (\\%)",
  temp_share = "Temp. Share (\\%)",
  country = "Country",
  yq = "Year-Quarter",
  age_group = "Age Group"
))

unlink("../tables/tab3_cross_country.tex")
etable(
  models$did_youth,
  models$did_intro,
  models$ddd,
  models$neet,
  models$temp_emp,
  tex = TRUE,
  style.tex = style.tex("aer"),
  fitstat = ~ r2 + n,
  headers = c("Youth Emp (Redn)", "Youth Emp (Intro)", "DDD", "NEET", "Temp Emp"),
  title = "Cross-Country Difference-in-Differences: Subsidy Effects on Youth Outcomes",
  label = "tab:cross_country",
  notes = c("Standard errors clustered at country level in parentheses.",
            "* p$<$0.10, ** p$<$0.05, *** p$<$0.01.",
            "Controls: Belgium, Netherlands, Spain, Italy, Portugal, Germany, Austria.",
            "Col 1--2: Youth (15--24) employment rate.",
            "Col 3: Triple-diff (France $\\times$ Youth $\\times$ Post).",
            "Col 4: NEET rate (15--24). Col 5: Temporary employment share."),
  file = "../tables/tab3_cross_country.tex"
)

# =============================================================
# Table 4: Alternative Control Groups
# =============================================================
cat("Table 4: Alternative control groups...\n")

rob_cc <- readRDS("../data/robustness_control_groups.rds")

unlink("../tables/tab4_alt_controls.tex")
etable(
  models$did_youth,
  rob_cc$no_germany,
  rob_cc$southern_only,
  rob_cc$neighbors_only,
  tex = TRUE,
  style.tex = style.tex("aer"),
  fitstat = ~ r2 + n,
  headers = c("Baseline", "Excl. Germany", "Southern EU", "Neighbors"),
  title = "Robustness: Alternative Control Groups",
  label = "tab:alt_controls",
  notes = c("Standard errors clustered at country level in parentheses.",
            "* p$<$0.10, ** p$<$0.05, *** p$<$0.01.",
            "Baseline: BE, NL, ES, IT, PT, DE, AT.",
            "Southern EU: ES, IT, PT. Neighbors: BE, DE, NL."),
  file = "../tables/tab4_alt_controls.tex"
)

cat("\n=== All tables generated ===\n")
cat("Tables saved to ../tables/\n")
