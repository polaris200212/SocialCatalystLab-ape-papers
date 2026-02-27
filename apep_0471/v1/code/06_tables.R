## 06_tables.R — Generate all tables for apep_0471

source("00_packages.R")

data_dir <- "../data"
tab_dir <- "../tables"
dir.create(tab_dir, showWarnings = FALSE)

panel <- read_parquet(file.path(data_dir, "monthly_panel.parquet"))
annual <- read_parquet(file.path(data_dir, "annual_panel.parquet"))

la_ids <- panel %>% distinct(la_code) %>% mutate(la_id = row_number())
panel <- panel %>% left_join(la_ids, by = "la_code")

# ============================================================
# TABLE 1: Summary Statistics
# ============================================================
cat("Table 1: Summary statistics...\n")

# Pre-treatment summary by treatment status
pre <- panel %>%
  filter(inc_ym <= ymd("2015-10-01")) %>%  # Before any full service (Oct 2015)
  mutate(ever_treated = !is.na(first_treat_date))

summ_stats <- pre %>%
  group_by(ever_treated) %>%
  summarise(
    `Mean monthly formations` = mean(n_formations, na.rm = TRUE),
    `SD monthly formations` = sd(n_formations, na.rm = TRUE),
    `Formation rate (per 1K)` = mean(formation_rate, na.rm = TRUE),
    `Construction formations` = mean(n_construction, na.rm = TRUE),
    `Professional formations` = mean(n_professional, na.rm = TRUE),
    `Working-age pop (1000s)` = mean(pop_wa / 1000, na.rm = TRUE),
    `N (LA × months)` = n(),
    `N (LAs)` = n_distinct(la_code),
    .groups = "drop"
  ) %>%
  mutate(Group = ifelse(ever_treated, "Treated", "Never treated")) %>%
  select(Group, everything(), -ever_treated)

# Add NOMIS data for annual panel
pre_annual <- annual %>%
  filter(year <= 2015)

nomis_summ <- pre_annual %>%
  mutate(ever_treated = !is.na(first_treat_date)) %>%
  group_by(ever_treated) %>%
  summarise(
    `Self-employment rate (%)` = mean(self_emp_rate, na.rm = TRUE),
    `Employment rate (%)` = mean(emp_rate, na.rm = TRUE),
    `Unemployment rate (%)` = mean(unemp_rate, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(Group = ifelse(ever_treated, "Treated", "Never treated"))

# Save as LaTeX
summ_latex <- summ_stats %>%
  mutate(across(where(is.numeric), ~round(.x, 2)))

write_csv(summ_stats, file.path(tab_dir, "table1_summary.csv"))
write_csv(nomis_summ, file.path(tab_dir, "table1_nomis_summary.csv"))

cat("Summary statistics saved.\n")

# ============================================================
# TABLE 2: Main Results
# ============================================================
cat("Table 2: Main results...\n")

# Reload estimates
cs_overall <- readRDS(file.path(data_dir, "cs_att_overall.rds"))

panel <- panel %>% mutate(treat_num = as.numeric(treated))
twfe_main <- feols(
  formation_rate ~ treat_num | as.factor(la_id) + period,
  data = panel,
  cluster = ~la_code
)

sa_main <- readRDS(file.path(data_dir, "sunab_main.rds"))
mif <- readRDS(file.path(data_dir, "mif_timing.rds"))

# CS-DiD overall ATT
cs_att <- cs_overall$overall.att
cs_se <- cs_overall$overall.se

results_df <- tribble(
  ~Specification, ~Coefficient, ~SE, ~`P-value`, ~N, ~`N LAs`,
  "TWFE", coef(twfe_main)["treat_num"],
  sqrt(vcov(twfe_main)["treat_num", "treat_num"]),
  pnorm(abs(coef(twfe_main)["treat_num"]) / sqrt(vcov(twfe_main)["treat_num", "treat_num"]),
        lower.tail = FALSE) * 2,
  nrow(panel), n_distinct(panel$la_code),

  "CS-DiD (DR)", cs_att, cs_se,
  pnorm(abs(cs_att) / cs_se, lower.tail = FALSE) * 2,
  nrow(panel), n_distinct(panel$la_code),

  "MIF: Start-up (0-12m)", coef(mif)["startup"],
  sqrt(vcov(mif)["startup", "startup"]),
  pnorm(abs(coef(mif)["startup"]) / sqrt(vcov(mif)["startup", "startup"]),
        lower.tail = FALSE) * 2,
  nobs(mif), NA_real_,

  "MIF: Binding (12+m)", coef(mif)["mif"],
  sqrt(vcov(mif)["mif", "mif"]),
  pnorm(abs(coef(mif)["mif"]) / sqrt(vcov(mif)["mif", "mif"]),
        lower.tail = FALSE) * 2,
  nobs(mif), NA_real_
) %>%
  mutate(across(where(is.numeric), ~round(.x, 4)))

write_csv(results_df, file.path(tab_dir, "table2_main_results.csv"))

cat("Main results:\n")
print(results_df)

# ============================================================
# TABLE 3: Robustness Checks
# ============================================================
cat("\nTable 3: Robustness...\n")

placebo <- readRDS(file.path(data_dir, "robustness_placebo_pubadmin.rds"))
highinc <- readRDS(file.path(data_dir, "robustness_placebo_highinc.rds"))
nopilot <- readRDS(file.path(data_dir, "robustness_nopilot.rds"))
construction <- readRDS(file.path(data_dir, "robustness_construction.rds"))
professional <- readRDS(file.path(data_dir, "robustness_professional.rds"))

extract_row <- function(model, label) {
  # Handle both "treated" and "treatedTRUE" coefficient names
  cf <- coef(model)
  vc <- vcov(model)
  coef_name <- intersect(names(cf), c("treated", "treatedTRUE", "treat_num"))[1]
  coef_val <- cf[coef_name]
  se_val <- sqrt(vc[coef_name, coef_name])
  tibble(
    Specification = label,
    Coefficient = coef_val,
    SE = se_val,
    `P-value` = pnorm(abs(coef_val / se_val), lower.tail = FALSE) * 2
  )
}

robust_df <- bind_rows(
  extract_row(twfe_main, "Baseline (all sectors)"),
  extract_row(construction, "Construction (SIC F)"),
  extract_row(professional, "Professional services (SIC M)"),
  extract_row(placebo, "Placebo: Public admin (SIC O)"),
  extract_row(highinc, "Placebo: High-employment LAs"),
  extract_row(nopilot, "Excl. pilot areas (pre-2017)")
) %>%
  mutate(across(where(is.numeric), ~round(.x, 4)))

write_csv(robust_df, file.path(tab_dir, "table3_robustness.csv"))

cat("Robustness results:\n")
print(robust_df)

# ============================================================
# TABLE 4: Pre-trend test
# ============================================================
cat("\nTable 4: Pre-trend test...\n")

pretrend <- readRDS(file.path(data_dir, "pretrend_test.rds"))

pretrend_df <- tibble(
  Test = "Joint pre-trend (chi-squared)",
  Statistic = pretrend$chi2,
  DF = pretrend$df,
  `P-value` = pretrend$p_value
) %>%
  mutate(across(where(is.numeric), ~round(.x, 4)))

write_csv(pretrend_df, file.path(tab_dir, "table4_pretrend.csv"))
cat("Pre-trend test:\n")
print(pretrend_df)

cat("\n=== All tables generated ===\n")
cat("Saved to:", tab_dir, "\n")
