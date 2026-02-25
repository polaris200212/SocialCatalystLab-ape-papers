## 06_tables.R — All table generation
## apep_0452: Mercury regulation and ASGM in Africa

source("00_packages.R")
load(file.path(data_dir, "clean_panel.RData"))
load(file.path(data_dir, "analysis_results.RData"))
load(file.path(data_dir, "robustness_results.RData"))

# ============================================================
# TABLE 1: Summary Statistics
# ============================================================

cat("--- Table 1: Summary statistics ---\n")

summ_data <- panel %>%
  filter(year >= 2005, year <= 2020)

summ_vars <- summ_data %>%
  summarise(
    `Mercury imports (\\$1000s)` = sprintf("%.1f", mean(hg_import_value / 1000, na.rm = TRUE)),
    `Mercury imports (\\$1000s) SD` = sprintf("%.1f", sd(hg_import_value / 1000, na.rm = TRUE)),
    `Gold exports (\\$1000s)` = sprintf("%.1f", mean(gold_export_value / 1000, na.rm = TRUE)),
    `Gold exports (\\$1000s) SD` = sprintf("%.1f", sd(gold_export_value / 1000, na.rm = TRUE)),
    `GDP per capita` = sprintf("%.0f", mean(gdp_pc, na.rm = TRUE)),
    `GDP per capita SD` = sprintf("%.0f", sd(gdp_pc, na.rm = TRUE)),
    `Population (millions)` = sprintf("%.1f", mean(population / 1e6, na.rm = TRUE)),
    `Population (millions) SD` = sprintf("%.1f", sd(population / 1e6, na.rm = TRUE)),
    `Rule of law` = sprintf("%.2f", mean(rule_of_law, na.rm = TRUE)),
    `Rule of law SD` = sprintf("%.2f", sd(rule_of_law, na.rm = TRUE)),
    `Control of corruption` = sprintf("%.2f", mean(corruption_control, na.rm = TRUE)),
    `Control of corruption SD` = sprintf("%.2f", sd(corruption_control, na.rm = TRUE)),
    `ASGM country (\\%)` = sprintf("%.1f", 100 * mean(is_asgm_country, na.rm = TRUE)),
    `ASGM country (\\%) SD` = sprintf("%.1f", 100 * sd(is_asgm_country, na.rm = TRUE)),
    `Minamata ratifier (\\%)` = sprintf("%.1f", 100 * mean(minamata_ratified, na.rm = TRUE)),
    `Minamata ratifier (\\%) SD` = sprintf("%.1f", 100 * sd(minamata_ratified, na.rm = TRUE)),
    `EU Hg share (pre-ban)` = sprintf("%.3f", mean(eu_share_preban, na.rm = TRUE)),
    `EU Hg share (pre-ban) SD` = sprintf("%.3f", sd(eu_share_preban, na.rm = TRUE))
  )

# Build LaTeX table manually for full control
n_obs <- nrow(summ_data)
n_countries <- n_distinct(summ_data$iso3c)
n_years <- n_distinct(summ_data$year)

tab1_tex <- paste0(
  "\\begin{table}[htbp]\n",
  "\\centering\n",
  "\\caption{Summary Statistics}\n",
  "\\label{tab:summary}\n",
  "\\begin{tabular}{lcc}\n",
  "\\hline\\hline\n",
  "Variable & Mean & SD \\\\\n",
  "\\hline\n",
  "\\multicolumn{3}{l}{\\textit{Panel A: Trade outcomes}} \\\\\n",
  "Mercury imports (\\$1,000s) & ", summ_vars$`Mercury imports (\\$1000s)`,
  " & ", summ_vars$`Mercury imports (\\$1000s) SD`, " \\\\\n",
  "Gold exports (\\$1,000s) & ", summ_vars$`Gold exports (\\$1000s)`,
  " & ", summ_vars$`Gold exports (\\$1000s) SD`, " \\\\\n",
  "\\hline\n",
  "\\multicolumn{3}{l}{\\textit{Panel B: Country characteristics}} \\\\\n",
  "GDP per capita (\\$) & ", summ_vars$`GDP per capita`,
  " & ", summ_vars$`GDP per capita SD`, " \\\\\n",
  "Population (millions) & ", summ_vars$`Population (millions)`,
  " & ", summ_vars$`Population (millions) SD`, " \\\\\n",
  "Rule of law & ", summ_vars$`Rule of law`,
  " & ", summ_vars$`Rule of law SD`, " \\\\\n",
  "Control of corruption & ", summ_vars$`Control of corruption`,
  " & ", summ_vars$`Control of corruption SD`, " \\\\\n",
  "\\hline\n",
  "\\multicolumn{3}{l}{\\textit{Panel C: Treatment variables}} \\\\\n",
  "ASGM country (\\%) & ", summ_vars$`ASGM country (\\%)`,
  " & ", summ_vars$`ASGM country (\\%) SD`, " \\\\\n",
  "Minamata ratifier (\\%) & ", summ_vars$`Minamata ratifier (\\%)`,
  " & ", summ_vars$`Minamata ratifier (\\%) SD`, " \\\\\n",
  "EU mercury share (pre-ban) & ", summ_vars$`EU Hg share (pre-ban)`,
  " & ", summ_vars$`EU Hg share (pre-ban) SD`, " \\\\\n",
  "\\hline\n",
  "Observations & \\multicolumn{2}{c}{", n_obs, "} \\\\\n",
  "Countries & \\multicolumn{2}{c}{", n_countries, "} \\\\\n",
  "Years & \\multicolumn{2}{c}{", n_years, "} \\\\\n",
  "\\hline\\hline\n",
  "\\end{tabular}\n",
  "\\begin{tablenotes}[flushleft]\\small\n",
  "\\item \\textit{Notes:} Summary statistics computed over the full descriptive sample (54 African countries, 2005--2020, $N=864$). ",
  "Regression samples differ: EU ban analysis uses 2005--2015 excluding 2011 ($N=540$); Minamata analysis uses 2005--2023 ($N=1{,}003$). ",
  "Mercury and gold trade from UN Comtrade (HS 280540 and 7108). ",
  "Governance indicators from World Governance Indicators. ",
  "EU mercury share is the average share of mercury imports sourced from EU member states during 2005--2010.\n",
  "\\end{tablenotes}\n",
  "\\end{table}"
)

writeLines(tab1_tex, file.path(tab_dir, "tab1_summary.tex"))

# ============================================================
# TABLE 2: EU BAN MAIN RESULTS
# ============================================================

cat("--- Table 2: EU ban results ---\n")

models_eu <- list(
  "(1)" = results$eu_ban$m1a,
  "(2)" = results$eu_ban$m1b,
  "(3)" = results$eu_ban$m1c,
  "(4)" = results$eu_ban$m1d,
  "(5)" = results$eu_ban$m1e
)

# Use modelsummary — output directly to file
modelsummary(
  models_eu,
  output = file.path(tab_dir, "tab2_eu_ban.tex"),
  stars = c("*" = 0.1, "**" = 0.05, "***" = 0.01),
  coef_rename = c(
    "eu_ban_treat" = "EU Share $\\times$ Post",
    "log_gdp_pc" = "Log GDP/cap",
    "log_pop" = "Log population",
    "trade_pct_gdp" = "Trade (\\% GDP)"
  ),
  gof_map = c("nobs", "r.squared", "FE: iso3c", "FE: year"),
  title = "Effect of EU Mercury Export Ban on African Mercury Imports",
  notes = list(
    "Clustered standard errors at the country level in parentheses.",
    "EU Share is the pre-ban (2005-2010) average share of mercury imports sourced from EU.",
    "Post = 1 for years $\\geq$ 2012. Year 2011 excluded (transition).",
    "Sample: African countries, 2005-2015."
  ),
  add_rows = tribble(
    ~term, ~`(1)`, ~`(2)`, ~`(3)`, ~`(4)`, ~`(5)`,
    "Outcome", "Log Hg", "IHS Hg", "Log Hg", "Log Gold", "Log Fert",
    "Controls", "No", "No", "Yes", "No", "No"
  ),
  escape = FALSE
)

# ============================================================
# TABLE 3: MINAMATA RESULTS
# ============================================================

cat("--- Table 3: Minamata results ---\n")

models_min <- list(
  "(1)" = results$minamata_twfe,
  "(2)" = results$nap_twfe,
  "(3)" = results$minamata_gold,
  "(4)" = results$minamata_placebo,
  "(5)" = results$combined
)

modelsummary(
  models_min,
  output = file.path(tab_dir, "tab3_minamata.tex"),
  stars = c("*" = 0.1, "**" = 0.05, "***" = 0.01),
  coef_rename = c(
    "minamata_ratified" = "Minamata ratified",
    "nap_submitted" = "NAP submitted",
    "eu_ban_treat" = "EU Share $\\times$ Post"
  ),
  gof_map = c("nobs", "r.squared", "FE: iso3c", "FE: year"),
  title = "Effect of Minamata Convention on Mercury Imports",
  notes = list(
    "Clustered standard errors at the country level in parentheses.",
    "Minamata ratified = 1 from the first full calendar year after ratification.",
    "NAP submitted = 1 from the year of National Action Plan submission.",
    "Column (5) includes both EU ban and Minamata treatments jointly; year 2011 (EU ban transition) is excluded, reducing N from 1,003 to 972."
  ),
  add_rows = tribble(
    ~term, ~`(1)`, ~`(2)`, ~`(3)`, ~`(4)`, ~`(5)`,
    "Outcome", "Log Hg", "Log Hg", "Log Gold", "Log Fert", "Log Hg",
    "Treatment", "Ratification", "NAP", "Ratification", "Ratification", "Both"
  ),
  escape = FALSE
)

# ============================================================
# TABLE 4: ROBUSTNESS
# ============================================================

cat("--- Table 4: Robustness ---\n")

rob_models <- list(
  "(1)" = results$eu_ban$m1a,
  "(2)" = rob$narrow,
  "(3)" = rob$extended,
  "(4)" = rob$ihs_eu,
  "(5)" = rob$no_transit,
  "(6)" = results$eu_balanced
)

modelsummary(
  rob_models,
  output = file.path(tab_dir, "tab4_robustness.tex"),
  stars = c("*" = 0.1, "**" = 0.05, "***" = 0.01),
  coef_rename = c("eu_ban_treat" = "EU Share $\\times$ Post"),
  coef_omit = "log_gdp|log_pop|trade",
  gof_map = c("nobs", "r.squared"),
  title = "Robustness: Alternative Specifications for EU Mercury Export Ban",
  notes = list(
    "All specifications include country and year fixed effects with country-clustered SEs.",
    "(1) Baseline 2005-2015. (2) Narrow 2008-2014. (3) Extended 2005-2020.",
    "(4) IHS transform. (5) Excl. transit hubs (Togo, South Africa). (6) Balanced reporters."
  ),
  add_rows = tribble(
    ~term, ~`(1)`, ~`(2)`, ~`(3)`, ~`(4)`, ~`(5)`, ~`(6)`,
    "Window", "2005-15", "2008-14", "2005-20", "2005-15", "2005-15", "2005-15",
    "Transform", "Log", "Log", "Log", "IHS", "Log", "Log",
    "Sample", "All", "All", "All", "All", "No hubs", "Balanced"
  ),
  escape = FALSE
)

# ============================================================
# TABLE 5: CALLAWAY-SANT'ANNA ATT
# ============================================================

cat("--- Table 5: CS-DiD ATT ---\n")

if (!is.null(results$cs_att)) {
  att <- results$cs_att
  cs_raw <- results$cs_did  # Original group-time ATT object
  tab5_tex <- paste0(
    "\\begin{table}[htbp]\n",
    "\\centering\n",
    "\\caption{Callaway-Sant'Anna Doubly Robust DiD: Overall ATT}\n",
    "\\label{tab:cs_att}\n",
    "\\begin{tabular}{lcc}\n",
    "\\hline\\hline\n",
    " & Never-treated & Not-yet-treated \\\\\n",
    "\\hline\n",
    "Overall ATT & ", sprintf("%.4f", att$overall.att),
    " & ", ifelse(!is.null(rob$cs_nyt), sprintf("%.4f", rob$cs_nyt$overall.att), "---"), " \\\\\n",
    " & (", sprintf("%.4f", att$overall.se), ")",
    " & ", ifelse(!is.null(rob$cs_nyt), paste0("(", sprintf("%.4f", rob$cs_nyt$overall.se), ")"), "---"), " \\\\\n",
    "\\hline\n",
    "Estimation method & \\multicolumn{2}{c}{Doubly Robust (DR)} \\\\\n",
    "Covariates & \\multicolumn{2}{c}{Log GDP per capita} \\\\\n",
    "Bootstrap iterations & \\multicolumn{2}{c}{1,000} \\\\\n",
    "Treatment cohorts & \\multicolumn{2}{c}{", length(unique(cs_raw$group[cs_raw$group > 0])), "} \\\\\n",
    "Countries & \\multicolumn{2}{c}{", n_distinct(panel$iso3c[panel$year >= 2005]), "} \\\\\n",
    "\\hline\\hline\n",
    "\\end{tabular}\n",
    "\\begin{tablenotes}[flushleft]\\small\n",
    "\\item \\textit{Notes:} Callaway and Sant'Anna (2021) group-time ATT estimates aggregated to overall ATT. ",
    "Doubly robust estimation combines inverse probability weighting with outcome regression. ",
    "Treatment: first full calendar year after Minamata Convention ratification. ",
    "Standard errors from multiplier bootstrap (1,000 iterations).\n",
    "\\end{tablenotes}\n",
    "\\end{table}"
  )
  writeLines(tab5_tex, file.path(tab_dir, "tab5_cs_att.tex"))
}

# ============================================================
# TABLE A1: MINAMATA RATIFICATION DATES
# ============================================================

cat("--- Table A1: Ratification dates ---\n")

ratif_table <- minamata_ratification %>%
  mutate(country = countrycode(iso3c, "iso3c", "country.name")) %>%
  arrange(ratification_date) %>%
  mutate(
    asgm = ifelse(iso3c %in% asgm_countries$iso3c,
                   asgm_countries$asgm_level[match(iso3c, asgm_countries$iso3c)],
                   "---"),
    nap = ifelse(!is.na(nap_year), as.character(nap_year), "---")
  ) %>%
  select(country, ratification_year, nap, asgm)

# Split into two columns for space
n_half <- ceiling(nrow(ratif_table) / 2)
left  <- ratif_table[1:n_half, ]
right <- ratif_table[(n_half+1):nrow(ratif_table), ]

# Pad right to match length
while (nrow(right) < nrow(left)) {
  right <- bind_rows(right, tibble(country = "", ratification_year = NA,
                                    nap = "", asgm = ""))
}

tabA1_lines <- c(
  "\\begin{table}[htbp]",
  "\\centering",
  "\\caption{Minamata Convention Ratification: African Countries}",
  "\\label{tab:ratification}",
  "\\footnotesize",
  "\\begin{tabular}{lccc|lccc}",
  "\\hline\\hline",
  "Country & Year & NAP & ASGM & Country & Year & NAP & ASGM \\\\",
  "\\hline"
)

for (i in 1:nrow(left)) {
  l <- left[i, ]
  r <- right[i, ]
  line <- paste0(
    l$country, " & ", l$ratification_year, " & ", l$nap, " & ", l$asgm,
    " & ",
    r$country, " & ",
    ifelse(is.na(r$ratification_year), "", r$ratification_year),
    " & ", r$nap, " & ", r$asgm, " \\\\"
  )
  tabA1_lines <- c(tabA1_lines, line)
}

tabA1_lines <- c(tabA1_lines,
  "\\hline\\hline",
  "\\end{tabular}",
  "\\begin{tablenotes}[flushleft]\\small",
  "\\item \\textit{Notes:} Year = ratification year. NAP = National Action Plan submission year. ASGM = artisanal mining prevalence level.",
  "\\end{tablenotes}",
  "\\end{table}"
)

writeLines(tabA1_lines, file.path(tab_dir, "tabA1_ratification.tex"))

cat("All tables saved.\n")
