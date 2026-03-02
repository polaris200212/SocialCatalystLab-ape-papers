## 06_tables.R — Generate all tables
## apep_0461: Oil Dependence and Child Survival

source("00_packages.R")

cat("=== Loading data and results ===\n")
panel <- readRDS("../data/panel_dev.rds")
results <- readRDS("../data/main_results.rds")
robustness <- readRDS("../data/robustness_results.rds")

# ============================================================
# Table 1: Summary statistics
# ============================================================
cat("\n=== Table 1: Summary statistics ===\n")

summary_pre <- panel %>%
  filter(year >= 2005, year <= 2013) %>%
  mutate(group = ifelse(oil_rents_pre > 5, "High Oil (>5\\%)", "Low/No Oil")) %>%
  group_by(group) %>%
  summarise(
    `N (country-years)` = as.character(n()),
    `Countries` = as.character(n_distinct(iso3c)),
    `Under-5 Mortality` = sprintf("%.1f (%.1f)", mean(u5_mortality, na.rm=T), sd(u5_mortality, na.rm=T)),
    `Infant Mortality` = sprintf("%.1f (%.1f)", mean(infant_mortality, na.rm=T), sd(infant_mortality, na.rm=T)),
    `DPT Immunization (\\%)` = sprintf("%.1f (%.1f)", mean(dpt_immunization, na.rm=T), sd(dpt_immunization, na.rm=T)),
    `Health Exp. (\\% GDP)` = sprintf("%.2f (%.2f)", mean(health_exp, na.rm=T), sd(health_exp, na.rm=T)),
    `Military Exp. (\\% GDP)` = sprintf("%.2f (%.2f)", mean(military_exp, na.rm=T), sd(military_exp, na.rm=T)),
    `GDP p.c. (const. 2015 \\$)` = sprintf("%.0f (%.0f)", mean(gdp_pc_constant, na.rm=T), sd(gdp_pc_constant, na.rm=T)),
    `Urban Pop. (\\%)` = sprintf("%.1f (%.1f)", mean(urban_pct, na.rm=T), sd(urban_pct, na.rm=T)),
    `Oil Rents (\\% GDP)` = sprintf("%.1f (%.1f)", mean(oil_rents_pre, na.rm=T), sd(oil_rents_pre, na.rm=T)),
    .groups = "drop"
  ) %>%
  pivot_longer(cols = -group, names_to = "Variable", values_to = "value") %>%
  pivot_wider(names_from = group, values_from = value)

# Write LaTeX
sink("../tables/table1_summary.tex")
cat("\\begin{table}[H]\n\\centering\n\\caption{Summary Statistics: Pre-Period (2005\\textendash{}2013)}\n\\label{tab:summary}\n")
cat("\\begin{threeparttable}\n")
cat("\\begin{tabular}{lcc}\n\\toprule\n")
cat("& High Oil ($>$5\\%) & Low/No Oil \\\\\n\\midrule\n")
for (i in 1:nrow(summary_pre)) {
  cat(sprintf("%s & %s & %s \\\\\n",
              summary_pre$Variable[i],
              summary_pre$`High Oil (>5\\%)`[i],
              summary_pre$`Low/No Oil`[i]))
}
cat("\\bottomrule\n\\end{tabular}\n")
cat("\\begin{tablenotes}\\small\n")
cat("\\item \\textit{Notes:} Mean (standard deviation) for the pre-treatment period. ")
cat("High Oil = countries with average oil rents $>$5\\% of GDP during 2010\\textendash{}2013. ")
cat("Under-5 mortality is per 1,000 live births. Source: World Bank WDI.\n")
cat("\\end{tablenotes}\n\\end{threeparttable}\n\\end{table}\n")
sink()
cat("  Saved: table1_summary.tex\n")

# ============================================================
# Table 2: Main results
# ============================================================
cat("\n=== Table 2: Main results ===\n")

# Extract results from models
extract_row <- function(model, var_name, label) {
  ct <- coeftable(model)
  if (var_name %in% rownames(ct)) {
    row <- ct[var_name,]
    tibble(
      Variable = label,
      estimate = row[1],
      se = row[2],
      p = row[4],
      n = model$nobs,
      n_clusters = model$nparams[["fixef"]]
    )
  } else {
    tibble(Variable = label, estimate = NA, se = NA, p = NA, n = NA, n_clusters = NA)
  }
}

# Write main results table
sink("../tables/table2_main_results.tex")
cat("\\begin{table}[H]\n\\centering\n\\caption{Oil Dependence and Under-5 Mortality: Main Results}\n\\label{tab:main}\n")
cat("\\begin{threeparttable}\n")
cat("\\begin{tabular}{lccc}\n\\toprule\n")
cat("& (1) & (2) & (3) \\\\\n")
cat("& Baseline & + Controls & + Governance \\\\\n\\midrule\n")

# Extract and format each model
for (m_name in c("m1", "m2", "m3")) {
  m <- results[[m_name]]
  ct <- coeftable(m)["treatment_continuous",]
  est <- ct[1]
  se <- ct[2]
  p <- ct[4]
  stars <- ifelse(p < 0.01, "***", ifelse(p < 0.05, "**", ifelse(p < 0.1, "*", "")))

  if (m_name == "m1") {
    cat(sprintf("Oil Rents$_{pre}$ $\\times$ Post2014 & %.3f%s", est, stars))
  } else {
    cat(sprintf(" & %.3f%s", est, stars))
  }
}
cat(" \\\\\n")

# Standard errors
for (m_name in c("m1", "m2", "m3")) {
  m <- results[[m_name]]
  se <- coeftable(m)["treatment_continuous", 2]
  if (m_name == "m1") {
    cat(sprintf("& (%.3f)", se))
  } else {
    cat(sprintf(" & (%.3f)", se))
  }
}
cat(" \\\\\n")

# 95% CI
for (m_name in c("m1", "m2", "m3")) {
  m <- results[[m_name]]
  ct <- coeftable(m)["treatment_continuous",]
  ci_l <- ct[1] - 1.96 * ct[2]
  ci_h <- ct[1] + 1.96 * ct[2]
  if (m_name == "m1") {
    cat(sprintf("95\\%% CI & [%.3f, %.3f]", ci_l, ci_h))
  } else {
    cat(sprintf(" & [%.3f, %.3f]", ci_l, ci_h))
  }
}
cat(" \\\\\n\\midrule\n")

# Controls info
cat("Country FE & Yes & Yes & Yes \\\\\n")
cat("Year FE & Yes & Yes & Yes \\\\\n")
cat("Economic controls & No & Yes & Yes \\\\\n")
cat("Governance controls & No & No & Yes \\\\\n")

# N
cat(sprintf("Observations & %s & %s & %s \\\\\n",
            format(results$m1$nobs, big.mark=","),
            format(results$m2$nobs, big.mark=","),
            format(results$m3$nobs, big.mark=",")))

# Countries
n1 <- n_distinct(panel$iso3c[!is.na(panel$u5_mortality)])
cat(sprintf("Countries & %d & %d & %d \\\\\n", n1, n1, n1))

cat("Clustering & Country & Country & Country \\\\\n")
cat("\\bottomrule\n\\end{tabular}\n")
cat("\\begin{tablenotes}\\small\n")
cat("\\item \\textit{Notes:} Dependent variable: under-5 mortality rate (per 1,000 live births). ")
cat("Oil Rents$_{pre}$ is the country's average oil rents as \\% of GDP during 2010\\textendash{}2013. ")
cat("Post2014 indicates years $\\geq$ 2014. Economic controls: log GDP per capita, population growth, urbanization. ")
cat("Governance controls: control of corruption, government effectiveness (WGI). ")
cat("Standard errors clustered at country level in parentheses. ")
cat("$^{*}p<0.10$, $^{**}p<0.05$, $^{***}p<0.01$.\n")
cat("\\end{tablenotes}\n\\end{threeparttable}\n\\end{table}\n")
sink()
cat("  Saved: table2_main_results.tex\n")

# ============================================================
# Table 3: Alternative outcomes
# ============================================================
cat("\n=== Table 3: Alternative outcomes ===\n")

alt <- results$alt_results %>%
  mutate(
    stars = case_when(p_value < 0.01 ~ "***", p_value < 0.05 ~ "**",
                      p_value < 0.1 ~ "*", TRUE ~ ""),
    formatted = ifelse(is.na(estimate), "---",
                       sprintf("%.3f%s\n(%.3f)", estimate, stars, se))
  )

sink("../tables/table3_alt_outcomes.tex")
cat("\\begin{table}[H]\n\\centering\n\\caption{Oil Dependence and Alternative Development Outcomes}\n\\label{tab:alt_outcomes}\n")
cat("\\begin{threeparttable}\n")
cat("\\begin{tabular}{lcccc}\n\\toprule\n")
cat("Outcome & Estimate & Std. Error & $p$-value & $N$ \\\\\n\\midrule\n")
for (i in 1:nrow(alt)) {
  outcome_label <- gsub("_", " ", str_to_title(alt$outcome[i]))
  if (is.na(alt$estimate[i])) {
    cat(sprintf("%s & --- & --- & --- & --- \\\\\n", outcome_label))
  } else {
    cat(sprintf("%s & %.3f%s & (%.3f) & %.3f & %s \\\\\n",
                outcome_label, alt$estimate[i], alt$stars[i], alt$se[i],
                alt$p_value[i], format(alt$n[i], big.mark=",")))
  }
}
cat("\\bottomrule\n\\end{tabular}\n")
cat("\\begin{tablenotes}\\small\n")
cat("\\item \\textit{Notes:} Each row is a separate regression of the listed outcome on ")
cat("Oil Rents$_{pre}$ $\\times$ Post2014 with country and year FE plus economic controls. ")
cat("$^{*}p<0.10$, $^{**}p<0.05$, $^{***}p<0.01$.\n")
cat("\\end{tablenotes}\n\\end{threeparttable}\n\\end{table}\n")
sink()
cat("  Saved: table3_alt_outcomes.tex\n")

# ============================================================
# Table 4: Mechanism (fiscal channel)
# ============================================================
cat("\n=== Table 4: Mechanism ===\n")

sink("../tables/table4_mechanism.tex")
cat("\\begin{table}[H]\n\\centering\n\\caption{Fiscal Mechanism: Oil Dependence and Government Spending}\n\\label{tab:mechanism}\n")
cat("\\begin{threeparttable}\n")
cat("\\begin{tabular}{lccc}\n\\toprule\n")
cat("& (1) & (2) & (3) \\\\\n")
cat("& Health Exp. & Gov. Health Exp. & Military Exp. \\\\\n")
cat("& (\\% GDP) & (\\% GDP) & (\\% GDP) \\\\\n\\midrule\n")

for (m_name in c("m_health", "m_gov_health", "m_military")) {
  m <- results[[m_name]]
  ct <- coeftable(m)["treatment_continuous",]
  stars <- ifelse(ct[4] < 0.01, "***", ifelse(ct[4] < 0.05, "**", ifelse(ct[4] < 0.1, "*", "")))
  if (m_name == "m_health") {
    cat(sprintf("Oil Rents$_{pre}$ $\\times$ Post2014 & %.4f%s", ct[1], stars))
  } else {
    cat(sprintf(" & %.4f%s", ct[1], stars))
  }
}
cat(" \\\\\n")

for (m_name in c("m_health", "m_gov_health", "m_military")) {
  m <- results[[m_name]]
  se <- coeftable(m)["treatment_continuous", 2]
  if (m_name == "m_health") {
    cat(sprintf("& (%.4f)", se))
  } else {
    cat(sprintf(" & (%.4f)", se))
  }
}
cat(" \\\\\n\\midrule\n")

cat("Country \\& Year FE & Yes & Yes & Yes \\\\\n")
cat("Economic controls & Yes & Yes & Yes \\\\\n")
cat(sprintf("Observations & %s & %s & %s \\\\\n",
            format(results$m_health$nobs, big.mark=","),
            format(results$m_gov_health$nobs, big.mark=","),
            format(results$m_military$nobs, big.mark=",")))
cat("\\bottomrule\n\\end{tabular}\n")
cat("\\begin{tablenotes}\\small\n")
cat("\\item \\textit{Notes:} Dependent variables are government spending categories as \\% of GDP. ")
cat("A negative coefficient for health and positive for military would indicate the ``guns over vaccines'' fiscal substitution. ")
cat("$^{*}p<0.10$, $^{**}p<0.05$, $^{***}p<0.01$.\n")
cat("\\end{tablenotes}\n\\end{threeparttable}\n\\end{table}\n")
sink()
cat("  Saved: table4_mechanism.tex\n")

# ============================================================
# Table 5: Robustness checks summary
# ============================================================
cat("\n=== Table 5: Robustness summary ===\n")

rob_summary <- tibble(
  Specification = c(
    "Baseline (preferred)",
    "Including OECD countries",
    "Dropping top 5 oil exporters",
    "Total resource rents (not just oil)",
    "Placebo: 2010 as fake treatment date",
    "Placebo outcome: Urbanization"
  ),
  Model = c("m2", "r1_oecd", "r2_notop5", "r3_total_rents", "r4_placebo_time", "r5_placebo_outcome")
)

sink("../tables/table5_robustness.tex")
cat("\\begin{table}[H]\n\\centering\n\\caption{Robustness Checks}\n\\label{tab:robustness}\n")
cat("\\begin{threeparttable}\n")
cat("\\begin{tabular}{lccc}\n\\toprule\n")
cat("Specification & Estimate & Std. Error & $N$ \\\\\n\\midrule\n")

for (i in 1:nrow(rob_summary)) {
  m_name <- rob_summary$Model[i]
  if (m_name == "m2") {
    m <- results$m2
    var_name <- "treatment_continuous"
  } else {
    m <- robustness[[m_name]]
    if (m_name == "r3_total_rents") var_name <- "treatment_total_rents"
    else if (m_name == "r4_placebo_time") var_name <- "treatment_placebo"
    else var_name <- "treatment_continuous"
  }
  ct <- coeftable(m)[var_name,]
  stars <- ifelse(ct[4] < 0.01, "***", ifelse(ct[4] < 0.05, "**", ifelse(ct[4] < 0.1, "*", "")))
  cat(sprintf("%s & %.3f%s & (%.3f) & %s \\\\\n",
              rob_summary$Specification[i], ct[1], stars, ct[2],
              format(m$nobs, big.mark=",")))
}

cat("\\bottomrule\n\\end{tabular}\n")
cat("\\begin{tablenotes}\\small\n")
cat("\\item \\textit{Notes:} All specifications include country and year FE with economic controls. ")
cat("The placebo checks should show null effects. ")
cat("$^{*}p<0.10$, $^{**}p<0.05$, $^{***}p<0.01$.\n")
cat("\\end{tablenotes}\n\\end{threeparttable}\n\\end{table}\n")
sink()
cat("  Saved: table5_robustness.tex\n")

cat("\n=== All tables generated ===\n")
