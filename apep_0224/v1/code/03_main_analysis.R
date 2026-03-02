## ============================================================================
## 03_main_analysis.R — Primary DiD estimation
## APEP Paper: School Suicide Prevention Training Mandates
## ============================================================================

source("00_packages.R")

data_dir <- "../data"
panel <- read_csv(file.path(data_dir, "analysis_panel.csv"), show_col_types = FALSE)

dir.create("../tables", showWarnings = FALSE, recursive = TRUE)

## ============================================================================
## A. Treatment Timing & Design Mapping
## ============================================================================

cat("\n=== A. Treatment Design ===\n")

# Document cohort sizes
cohort_sizes <- panel %>%
  filter(year == max(year)) %>%
  mutate(cohort = if_else(first_treat == 0, "Never Treated", as.character(first_treat))) %>%
  count(cohort, name = "n_states") %>%
  arrange(cohort)

cat("Treatment cohort sizes:\n")
print(cohort_sizes)

# Total treated vs never-treated
n_treated <- sum(panel$first_treat > 0 & panel$year == max(panel$year))
n_never   <- sum(panel$first_treat == 0 & panel$year == max(panel$year))
cat(sprintf("\nTreated: %d states, Never-treated: %d states\n", n_treated, n_never))

## ============================================================================
## B. Callaway-Sant'Anna Estimation (Primary)
## ============================================================================

cat("\n=== B. Callaway-Sant'Anna Estimation ===\n")

# Primary specification: age-adjusted suicide rate
cs_out <- att_gt(
  yname  = "suicide_aadr",
  tname  = "year",
  idname = "state_id",
  gname  = "first_treat",
  data   = panel,
  control_group = "notyettreated",
  anticipation  = 0,
  base_period   = "universal"
)

cat("Group-time ATTs computed.\n")
summary(cs_out)

# Aggregate to overall ATT
cs_agg <- aggte(cs_out, type = "simple")
cat("\n--- Overall ATT ---\n")
summary(cs_agg)

# Save overall ATT
att_overall <- tibble(
  estimator = "CS-ATT",
  outcome = "suicide_aadr",
  att = cs_agg$overall.att,
  se = cs_agg$overall.se,
  ci_lower = cs_agg$overall.att - 1.96 * cs_agg$overall.se,
  ci_upper = cs_agg$overall.att + 1.96 * cs_agg$overall.se,
  pvalue = 2 * pnorm(-abs(cs_agg$overall.att / cs_agg$overall.se)),
  n_groups = length(unique(cs_out$group[cs_out$group > 0])),
  control = "not-yet-treated"
)

# Event study aggregation
cs_es <- aggte(cs_out, type = "dynamic", min_e = -7, max_e = 10)
cat("\n--- Event Study ---\n")
summary(cs_es)

# Save event study results
es_df <- tibble(
  event_time = cs_es$egt,
  att = cs_es$att.egt,
  se = cs_es$se.egt,
  ci_lower = att - 1.96 * se,
  ci_upper = att + 1.96 * se,
  pvalue = 2 * pnorm(-abs(att / se))
)

write_csv(es_df, file.path(data_dir, "event_study_cs.csv"))

## ============================================================================
## C. Alternative specification: log suicide rate
## ============================================================================

cat("\n=== C. Log Specification ===\n")

cs_log <- att_gt(
  yname  = "ln_suicide_aadr",
  tname  = "year",
  idname = "state_id",
  gname  = "first_treat",
  data   = panel,
  control_group = "notyettreated",
  anticipation  = 0,
  base_period   = "universal"
)

cs_log_agg <- aggte(cs_log, type = "simple")
cat("\n--- Overall ATT (log) ---\n")
summary(cs_log_agg)

cs_log_es <- aggte(cs_log, type = "dynamic", min_e = -7, max_e = 10)
write_csv(
  tibble(
    event_time = cs_log_es$egt,
    att = cs_log_es$att.egt,
    se = cs_log_es$se.egt
  ),
  file.path(data_dir, "event_study_cs_log.csv")
)

## ============================================================================
## D. TWFE for comparison (with Bacon decomposition)
## ============================================================================

cat("\n=== D. TWFE Estimation ===\n")

# TWFE with fixest
twfe_level <- feols(suicide_aadr ~ treated | state_id + year, data = panel,
                    cluster = ~state_id)
twfe_log   <- feols(ln_suicide_aadr ~ treated | state_id + year, data = panel,
                    cluster = ~state_id)

cat("TWFE (level):\n")
summary(twfe_level)
cat("\nTWFE (log):\n")
summary(twfe_log)

# Bacon decomposition
cat("\n--- Bacon Decomposition ---\n")
bacon <- bacon(suicide_aadr ~ treated, data = panel,
               id_var = "state_id", time_var = "year")
bacon_summary <- bacon %>%
  group_by(type) %>%
  summarise(
    n_comparisons = n(),
    avg_weight = mean(weight),
    total_weight = sum(weight),
    wtd_avg_estimate = weighted.mean(estimate, weight),
    .groups = "drop"
  )
cat("Bacon decomposition:\n")
print(bacon_summary)
write_csv(bacon_summary, file.path(data_dir, "bacon_decomposition.csv"))

## ============================================================================
## E. Sun-Abraham estimation (robustness)
## ============================================================================

cat("\n=== E. Sun-Abraham ===\n")

# Sun-Abraham requires a cohort variable (treatment year)
panel_sa <- panel %>%
  mutate(cohort = if_else(first_treat == 0, 10000L, first_treat))

sa_level <- feols(suicide_aadr ~ sunab(cohort, year) | state_id + year,
                  data = panel_sa, cluster = ~state_id)
cat("Sun-Abraham (level):\n")
summary(sa_level)

sa_log <- feols(ln_suicide_aadr ~ sunab(cohort, year) | state_id + year,
                data = panel_sa, cluster = ~state_id)

## ============================================================================
## F. With controls
## ============================================================================

cat("\n=== F. With Controls ===\n")

# Add Medicaid expansion control
cs_controls <- att_gt(
  yname  = "suicide_aadr",
  tname  = "year",
  idname = "state_id",
  gname  = "first_treat",
  xformla = ~ medicaid_expanded,
  data   = panel,
  control_group = "notyettreated",
  anticipation  = 0,
  base_period   = "universal"
)

cs_controls_agg <- aggte(cs_controls, type = "simple")
cat("\n--- Overall ATT (with Medicaid control) ---\n")
summary(cs_controls_agg)

## ============================================================================
## G. Collect all main results
## ============================================================================

# Add log result
att_log <- tibble(
  estimator = "CS-ATT",
  outcome = "ln_suicide_aadr",
  att = cs_log_agg$overall.att,
  se = cs_log_agg$overall.se,
  ci_lower = att - 1.96 * se,
  ci_upper = att + 1.96 * se,
  pvalue = 2 * pnorm(-abs(att / se)),
  n_groups = length(unique(cs_log$group[cs_log$group > 0])),
  control = "not-yet-treated"
)

# TWFE results
att_twfe <- tibble(
  estimator = "TWFE",
  outcome = "suicide_aadr",
  att = coef(twfe_level)["treated"],
  se = sqrt(vcov(twfe_level)["treated", "treated"]),
  ci_lower = att - 1.96 * se,
  ci_upper = att + 1.96 * se,
  pvalue = 2 * pnorm(-abs(att / se)),
  n_groups = n_treated,
  control = "all untreated"
)

# With controls
att_ctrl <- tibble(
  estimator = "CS-ATT + Controls",
  outcome = "suicide_aadr",
  att = cs_controls_agg$overall.att,
  se = cs_controls_agg$overall.se,
  ci_lower = att - 1.96 * se,
  ci_upper = att + 1.96 * se,
  pvalue = 2 * pnorm(-abs(att / se)),
  n_groups = length(unique(cs_controls$group[cs_controls$group > 0])),
  control = "not-yet-treated"
)

all_results <- bind_rows(att_overall, att_log, att_twfe, att_ctrl)
write_csv(all_results, file.path(data_dir, "main_results.csv"))

cat("\n=== Main Results Summary ===\n")
print(all_results %>% select(estimator, outcome, att, se, pvalue))

cat("\nAll main analysis results saved.\n")
