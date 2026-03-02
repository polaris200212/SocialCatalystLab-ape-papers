## 06_tables.R — Generate all tables for the paper
## apep_0486: Progressive Prosecutors, Incarceration, and Public Safety

source("00_packages.R")

panel <- fread(file.path(DATA_DIR, "analysis_panel.csv"))
panel[, fips := str_pad(as.character(fips), width = 5, pad = "0")]
panel[, state_fips := str_pad(as.character(state_fips), width = 2, pad = "0")]

results <- readRDS(file.path(DATA_DIR, "main_results.rds"))
rob_results <- readRDS(file.path(DATA_DIR, "robustness_results.rds"))

cat("=== TABLE 1: Summary Statistics ===\n")

# Summary stats by treatment status
summ_vars <- c("jail_rate", "total_jail_pop", "total_jail_pretrial",
               "homicide_rate", "total_pop", "black_share",
               "poverty_rate", "unemp_rate", "median_hh_income")

make_summ <- function(dt, label) {
  data.frame(
    Group = label,
    `Jail Rate (per 100K)` = sprintf("%.1f (%.1f)", mean(dt$jail_rate, na.rm=T), sd(dt$jail_rate, na.rm=T)),
    `Jail Population` = sprintf("%.0f (%.0f)", mean(dt$total_jail_pop, na.rm=T), sd(dt$total_jail_pop, na.rm=T)),
    `Pretrial Share` = sprintf("%.2f (%.2f)",
      mean(dt$total_jail_pretrial/dt$total_jail_pop, na.rm=T),
      sd(dt$total_jail_pretrial/dt$total_jail_pop, na.rm=T)),
    `Homicide Rate` = sprintf("%.1f (%.1f)", mean(dt$homicide_rate, na.rm=T), sd(dt$homicide_rate, na.rm=T)),
    `Population` = sprintf("%.0f (%.0f)", mean(dt$total_pop, na.rm=T)/1000, sd(dt$total_pop, na.rm=T)/1000),
    `Black Share (pct)` = sprintf("%.1f (%.1f)", mean(dt$black_share, na.rm=T), sd(dt$black_share, na.rm=T)),
    `Poverty Rate (pct)` = sprintf("%.1f (%.1f)", mean(dt$poverty_rate, na.rm=T), sd(dt$poverty_rate, na.rm=T)),
    `Unemp. Rate (pct)` = sprintf("%.1f (%.1f)", mean(dt$unemp_rate, na.rm=T), sd(dt$unemp_rate, na.rm=T)),
    `N county-years` = nrow(dt),
    check.names = FALSE
  )
}

pre_treat <- panel[year >= 2010 & year <= 2014]
summ_treated <- make_summ(pre_treat[ever_treated == 1], "Progressive DA Counties")
summ_control <- make_summ(pre_treat[ever_treated == 0], "Other Counties")

table1 <- rbind(summ_treated, summ_control)
table1_t <- t(table1[, -1])
colnames(table1_t) <- table1$Group

cat("Table 1 (Summary Statistics):\n")
print(table1_t)

# Export LaTeX
tex_table1 <- xtable(table1_t,
  caption = "Summary Statistics: Pre-Treatment Means (2010--2014)",
  label = "tab:summary",
  align = c("l", "c", "c"))
print(tex_table1,
  file = file.path(TABLE_DIR, "table1_summary.tex"),
  floating = TRUE,
  sanitize.text.function = identity,
  include.rownames = TRUE,
  booktabs = TRUE)
cat("Table 1 saved\n")

cat("\n=== TABLE 2: Main Results — First Stage ===\n")

# Collect main models
tab2_models <- list(
  "(1)" = results$twfe_jail,
  "(2)" = results$twfe_jail_ctrl,
  "(3)" = results$twfe_jail_sxyr,
  "(4)" = results$twfe_pretrial,
  "(5)" = results$twfe_sentenced
)

# Create table with modelsummary
tab2_names <- c(
  "treated" = "Progressive DA",
  "poverty_rate" = "Poverty Rate",
  "unemp_rate" = "Unemployment Rate",
  "log_pop" = "Log Population"
)

# LaTeX output
modelsummary(
  tab2_models,
  coef_map = tab2_names,
  stars = c("*" = 0.1, "**" = 0.05, "***" = 0.01),
  gof_omit = "AIC|BIC|Log|Adj|Within",
  title = "Effect of Progressive DA Election on County Jail Population",
  notes = c("Clustered standard errors at state level in parentheses.",
            "All specifications include county and year fixed effects.",
            "Columns (3) includes state × year fixed effects."),
  output = file.path(TABLE_DIR, "table2_first_stage.tex")
)
cat("Table 2 saved\n")

cat("\n=== TABLE 3: Public Safety — Homicide Results ===\n")

tab3_models <- list(
  "(1)" = results$twfe_homicide,
  "(2)" = results$twfe_hom_sxyr
)

modelsummary(
  tab3_models,
  coef_map = c("treated" = "Progressive DA"),
  stars = c("*" = 0.1, "**" = 0.05, "***" = 0.01),
  gof_omit = "AIC|BIC|Log|Adj|Within",
  title = "Effect of Progressive DA Election on Homicide Mortality Rate",
  notes = c("Clustered standard errors at state level in parentheses.",
            "Column (1): county + year FE. Column (2): county + state × year FE."),
  output = file.path(TABLE_DIR, "table3_homicide.tex")
)
cat("Table 3 saved\n")

cat("\n=== TABLE 4: DDD — Racial Decomposition ===\n")

tab4_models <- list(
  "(1)" = results$ddd_jail,
  "(2)" = results$twfe_bw_ratio
)

tab4_names <- c(
  "is_black:treated" = "Black × Progressive DA",
  "treated" = "Progressive DA"
)

modelsummary(
  tab4_models,
  coef_map = tab4_names,
  stars = c("*" = 0.1, "**" = 0.05, "***" = 0.01),
  gof_omit = "AIC|BIC|Log|Adj|Within",
  title = "Racial Decomposition: Black vs. White Jail Population Effects",
  notes = c("Column (1): DDD with race × county, race × year, county × year FE.",
            "Column (2): Black/White ratio as dependent variable.",
            "Clustered standard errors at state level."),
  output = file.path(TABLE_DIR, "table4_racial_ddd.tex")
)
cat("Table 4 saved\n")

cat("\n=== TABLE 5: Robustness Checks ===\n")

tab5_models <- list(
  "(1) Full Sample" = results$twfe_jail,
  "(2) Pre-COVID" = rob_results$precovid,
  "(3) Pre-2020 Cohorts" = rob_results$precohort,
  "(4) Excl. 2020" = rob_results$no2020,
  "(5) Pop-Weighted" = rob_results$weighted,
  "(6) AAPI Placebo" = rob_results$aapi_placebo
)

modelsummary(
  tab5_models,
  coef_map = c("treated" = "Progressive DA"),
  stars = c("*" = 0.1, "**" = 0.05, "***" = 0.01),
  gof_omit = "AIC|BIC|Log|Adj|Within",
  title = "Robustness: Effect on Jail Population Rate Across Specifications",
  notes = c("All specifications include county and year FE, state-clustered SEs.",
            "Column (6) uses AAPI jail rate as placebo outcome."),
  output = file.path(TABLE_DIR, "table5_robustness.tex")
)
cat("Table 5 saved\n")

cat("\n=== TABLE 6: Treatment County Details ===\n")

treatment <- fread(file.path(DATA_DIR, "progressive_da_treatment.csv"))
treatment[, fips := str_pad(as.character(fips), width = 5, pad = "0")]

# Merge with pre-treatment characteristics
pre_chars <- panel[year == 2014, .(
  fips, total_pop, jail_rate, black_share, homicide_rate
)]
treatment_detail <- merge(treatment, pre_chars, by = "fips", all.x = TRUE)
treatment_detail <- treatment_detail[order(treatment_year)]

tex_treat <- xtable(
  treatment_detail[, .(county_name, state, da_name, treatment_year,
                       total_pop = round(total_pop/1000),
                       jail_rate = round(jail_rate, 1),
                       black_share = round(black_share, 1))],
  caption = "Progressive District Attorney Counties: Treatment Details",
  label = "tab:treatment",
  align = c("l", "l", "c", "l", "c", "r", "r", "r")
)
names(treatment_detail)[names(treatment_detail) == "total_pop"] <- "Pop (1000s)"

print(tex_treat,
  file = file.path(TABLE_DIR, "table6_treatment_details.tex"),
  floating = TRUE,
  include.rownames = FALSE,
  booktabs = TRUE,
  sanitize.text.function = identity)
cat("Table 6 saved\n")

cat("\n=== TABLES COMPLETE ===\n")
cat("Files in tables directory:\n")
cat(paste(list.files(TABLE_DIR), collapse = "\n"), "\n")
