# =============================================================================
# 06_tables.R — All tables for the paper
# apep_0493: Council Tax Support Localisation and Low-Income Employment
# =============================================================================

source("00_packages.R")

panel <- fread(file.path(data_dir, "analysis_panel.csv")) |>
  mutate(date = as.Date(date),
         time_index = as.numeric(date - min(date)) / 30)

treatment <- fread(file.path(data_dir, "treatment.csv"))

# =============================================================================
# Table 1: Summary Statistics
# =============================================================================
cat("=== Table 1: Summary Statistics ===\n")

sum_stats <- panel |>
  mutate(Group = ifelse(treat_binary == 1, "Cut LAs", "Protected LAs")) |>
  group_by(Group) |>
  summarise(
    `N (LAs)` = n_distinct(la_code),
    `Mean claimant rate (%)` = mean(claimant_rate, na.rm = TRUE),
    `SD claimant rate (%)` = sd(claimant_rate, na.rm = TRUE),
    `Mean working-age pop` = mean(working_age_pop, na.rm = TRUE),
    `Mean CTS/capita (£)` = mean(cts_working_pc, na.rm = TRUE),
    `Pre-reform claimant rate (%)` = mean(claimant_rate[post == 0], na.rm = TRUE),
    `Post-reform claimant rate (%)` = mean(claimant_rate[post == 1], na.rm = TRUE),
    .groups = "drop"
  ) |>
  mutate(across(where(is.numeric), ~round(., 2)))

# Save as LaTeX
tab1_latex <- kable(sum_stats, format = "latex", booktabs = TRUE,
                    caption = "Summary Statistics by Treatment Group",
                    label = "tab:sumstats") |>
  kable_styling(latex_options = "hold_position")

writeLines(tab1_latex, file.path(tab_dir, "tab1_summary.tex"))
cat("  Saved tab1_summary.tex\n")

# =============================================================================
# Table 2: Main Results
# =============================================================================
cat("=== Table 2: Main Results ===\n")

# Re-estimate all main specifications
mod1 <- feols(claimant_rate ~ treat_binary:post | la_code + date,
              data = panel, cluster = ~la_code)

mod2 <- feols(claimant_rate ~ treat_continuous:post | la_code + date,
              data = panel, cluster = ~la_code)

mod3 <- feols(claimant_rate ~ treat_binary:post | la_code[time_index] + date,
              data = panel, cluster = ~la_code)

mod4 <- feols(log(claimant_rate + 0.01) ~ treat_binary:post | la_code + date,
              data = panel, cluster = ~la_code)

mod5 <- feols(log(claimant_rate + 0.01) ~ treat_binary:post | la_code[time_index] + date,
              data = panel, cluster = ~la_code)

# Create modelsummary table
tab2 <- modelsummary(
  list("(1)" = mod1, "(2)" = mod2, "(3)" = mod3, "(4)" = mod4, "(5)" = mod5),
  stars = c("*" = 0.1, "**" = 0.05, "***" = 0.01),
  gof_map = c("nobs", "r.squared", "adj.r.squared", "within.r.squared"),
  coef_rename = c(
    "treat_binary:post" = "Cut $\\times$ Post",
    "treat_continuous:post" = "CTS Intensity $\\times$ Post"
  ),
  output = file.path(tab_dir, "tab2_main_results.tex"),
  title = "Effect of Council Tax Support Cuts on Claimant Rates",
  notes = list(
    "Standard errors clustered at the Local Authority level in parentheses.",
    "Columns (3) and (5) include LA-specific linear time trends.",
    "Columns (4) and (5) use log(claimant rate) as the dependent variable."
  )
)

cat("  Saved tab2_main_results.tex\n")

# =============================================================================
# Table 3: Dose-Response Results
# =============================================================================
cat("=== Table 3: Dose-Response ===\n")

panel <- panel |>
  mutate(
    cut_high = as.integer(treat_tercile == 1),
    cut_mid  = as.integer(treat_tercile == 2)
  )

mod_dose1 <- feols(claimant_rate ~ cut_high:post + cut_mid:post | la_code + date,
                   data = panel, cluster = ~la_code)

mod_dose2 <- feols(claimant_rate ~ cut_high:post + cut_mid:post | la_code[time_index] + date,
                   data = panel, cluster = ~la_code)

tab3 <- modelsummary(
  list("Raw TWFE" = mod_dose1, "With LA Trends" = mod_dose2),
  stars = c("*" = 0.1, "**" = 0.05, "***" = 0.01),
  gof_map = c("nobs", "within.r.squared"),
  coef_rename = c(
    "cut_high:post" = "Most Cut $\\times$ Post",
    "post:cut_mid" = "Moderate Cut $\\times$ Post",
    "cut_mid:post" = "Moderate Cut $\\times$ Post"
  ),
  output = file.path(tab_dir, "tab3_dose_response.tex"),
  title = "Dose-Response: Effect by Tercile of CTS Cut Intensity",
  notes = "Reference group: Most protected LAs (top tercile of CTS generosity)."
)

cat("  Saved tab3_dose_response.tex\n")

# =============================================================================
# Table 4: Robustness
# =============================================================================
cat("=== Table 4: Robustness ===\n")

# Donut specification
mod_donut <- feols(claimant_rate ~ treat_binary:post | la_code + date,
                   data = panel |> filter(abs(as.numeric(date - as.Date("2013-04-01"))) > 180),
                   cluster = ~la_code)

# Placebo
mod_placebo <- feols(
  claimant_rate ~ treat_binary:I(date >= as.Date("2010-10-01")) | la_code + date,
  data = panel |> filter(date < as.Date("2013-04-01")),
  cluster = ~la_code
)

tab4 <- modelsummary(
  list("Main" = mod1, "LA Trends" = mod3, "Donut" = mod_donut, "Placebo" = mod_placebo),
  stars = c("*" = 0.1, "**" = 0.05, "***" = 0.01),
  gof_map = c("nobs", "within.r.squared"),
  output = file.path(tab_dir, "tab4_robustness.tex"),
  title = "Robustness Checks",
  notes = list(
    "Column (1): Main specification. Column (2): LA-specific linear trends.",
    "Column (3): Excludes 6 months around reform. Column (4): Placebo using pre-reform period only."
  )
)

cat("  Saved tab4_robustness.tex\n")

# =============================================================================
# Table 5: Pre-trends F-test
# =============================================================================
cat("=== Table 5: Pre-trends ===\n")

es_data <- fread(file.path(data_dir, "event_study_coefs.csv"))
pre_coefs <- es_data |> filter(quarter < -1)

pre_table <- pre_coefs |>
  select(Quarter = quarter, Estimate = estimate, `Std. Error` = se) |>
  mutate(across(where(is.numeric), ~round(., 4)))

tab5_latex <- kable(pre_table, format = "latex", booktabs = TRUE,
                    caption = "Pre-Reform Event Study Coefficients",
                    label = "tab:pretrends") |>
  kable_styling(latex_options = "hold_position")

writeLines(tab5_latex, file.path(tab_dir, "tab5_pretrends.tex"))
cat("  Saved tab5_pretrends.tex\n")

cat("\n=== All tables generated ===\n")
cat("Files:", paste(list.files(tab_dir), collapse = ", "), "\n")
