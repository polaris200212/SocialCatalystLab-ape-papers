## ============================================================================
## 03_main_analysis.R — Primary regressions
## Paper: State Minimum Wage Increases and the Medicaid Home Care Workforce
## ============================================================================

source("00_packages.R")

DATA <- "../data"

## ---- 1. Load cleaned data ----
cat("Loading cleaned data...\n")
panel <- readRDS(file.path(DATA, "panel_hcbs_annual.rds"))
panel_nonhcbs <- readRDS(file.path(DATA, "panel_nonhcbs_annual.rds"))

## ---- 2. Diagnostic: Treatment rollout ----
cat("\n=== Treatment Rollout ===\n")
rollout <- panel[year == 2020, .(state, first_treat_year)]
rollout[, status := fifelse(first_treat_year == 0, "Never treated", paste0("Cohort ", first_treat_year))]
cat("Cohort sizes:\n")
print(rollout[, .N, by = status][order(status)])

## ---- 3. Callaway-Sant'Anna: Main specification ----
cat("\n=== Callaway-Sant'Anna DiD ===\n")

# Primary outcome: log(HCBS providers)
cs_providers <- att_gt(
  yname = "log_providers",
  tname = "year",
  idname = "state_id",
  gname = "first_treat_year",
  data = as.data.frame(panel),
  control_group = "nevertreated",
  anticipation = 0,
  base_period = "universal"
)

cat("Group-time ATTs computed.\n")
cat(sprintf("Number of group-time estimates: %d\n", length(cs_providers$att)))

# Aggregate: overall ATT
agg_overall <- aggte(cs_providers, type = "simple")
cat(sprintf("\nOverall ATT (log providers): %.4f (SE: %.4f, p: %.4f)\n",
            agg_overall$overall.att, agg_overall$overall.se,
            2 * pnorm(-abs(agg_overall$overall.att / agg_overall$overall.se))))

# Dynamic/event-study aggregation
es_providers <- aggte(cs_providers, type = "dynamic", min_e = -5, max_e = 5)
cat("\nEvent-study ATTs (log providers):\n")
es_df <- data.table(
  event_time = es_providers$egt,
  att = es_providers$att.egt,
  se = es_providers$se.egt
)
es_df[, ci_low := att - 1.96 * se]
es_df[, ci_high := att + 1.96 * se]
es_df[, sig := fifelse(ci_low > 0 | ci_high < 0, "*", "")]
print(es_df)

# Pre-trend test
pre_atts <- es_df[event_time < 0]
if (nrow(pre_atts) > 0) {
  wald_stat <- sum((pre_atts$att / pre_atts$se)^2)
  wald_pval <- pchisq(wald_stat, df = nrow(pre_atts), lower.tail = FALSE)
  cat(sprintf("\nPre-trend Wald test: chi2(%d) = %.2f, p = %.4f\n",
              nrow(pre_atts), wald_stat, wald_pval))
}

# Save CS results
saveRDS(cs_providers, file.path(DATA, "cs_providers.rds"))
saveRDS(es_providers, file.path(DATA, "es_providers.rds"))

## ---- 4. CS: Log spending ----
cat("\n=== CS DiD: Log Spending ===\n")
cs_spending <- att_gt(
  yname = "log_spending",
  tname = "year",
  idname = "state_id",
  gname = "first_treat_year",
  data = as.data.frame(panel),
  control_group = "nevertreated",
  anticipation = 0,
  base_period = "universal"
)

agg_spending <- aggte(cs_spending, type = "simple")
cat(sprintf("Overall ATT (log spending): %.4f (SE: %.4f, p: %.4f)\n",
            agg_spending$overall.att, agg_spending$overall.se,
            2 * pnorm(-abs(agg_spending$overall.att / agg_spending$overall.se))))

es_spending <- aggte(cs_spending, type = "dynamic", min_e = -5, max_e = 5)
saveRDS(cs_spending, file.path(DATA, "cs_spending.rds"))
saveRDS(es_spending, file.path(DATA, "es_spending.rds"))

## ---- 5. CS: Providers per 100k ----
cat("\n=== CS DiD: Providers per 100k ===\n")
cs_percapita <- att_gt(
  yname = "providers_per_100k",
  tname = "year",
  idname = "state_id",
  gname = "first_treat_year",
  data = as.data.frame(panel),
  control_group = "nevertreated",
  anticipation = 0,
  base_period = "universal"
)

agg_percapita <- aggte(cs_percapita, type = "simple")
cat(sprintf("Overall ATT (providers/100k): %.2f (SE: %.2f, p: %.4f)\n",
            agg_percapita$overall.att, agg_percapita$overall.se,
            2 * pnorm(-abs(agg_percapita$overall.att / agg_percapita$overall.se))))

es_percapita <- aggte(cs_percapita, type = "dynamic", min_e = -5, max_e = 5)
saveRDS(cs_percapita, file.path(DATA, "cs_percapita.rds"))
saveRDS(es_percapita, file.path(DATA, "es_percapita.rds"))

## ---- 6. CS: Spending per capita ----
cat("\n=== CS DiD: Spending per Capita ===\n")
cs_spend_pc <- att_gt(
  yname = "spending_per_capita",
  tname = "year",
  idname = "state_id",
  gname = "first_treat_year",
  data = as.data.frame(panel),
  control_group = "nevertreated",
  anticipation = 0,
  base_period = "universal"
)

agg_spend_pc <- aggte(cs_spend_pc, type = "simple")
cat(sprintf("Overall ATT (spending/capita): %.2f (SE: %.2f, p: %.4f)\n",
            agg_spend_pc$overall.att, agg_spend_pc$overall.se,
            2 * pnorm(-abs(agg_spend_pc$overall.att / agg_spend_pc$overall.se))))

es_spend_pc <- aggte(cs_spend_pc, type = "dynamic", min_e = -5, max_e = 5)
saveRDS(cs_spend_pc, file.path(DATA, "cs_spend_pc.rds"))
saveRDS(es_spend_pc, file.path(DATA, "es_spend_pc.rds"))

## ---- 7. TWFE comparison (for Bacon decomposition) ----
cat("\n=== TWFE Baseline (for comparison) ===\n")

# Construct post indicator for annual panel
panel[, post := as.integer(first_treat_year > 0 & year >= first_treat_year)]

# Standard TWFE (known to be biased with staggered treatment)
twfe_providers <- feols(log_providers ~ post | state_id + year,
                        data = panel, cluster = ~state)
cat("TWFE (log providers):\n")
print(summary(twfe_providers))

twfe_spending <- feols(log_spending ~ post | state_id + year,
                       data = panel, cluster = ~state)

# Continuous treatment: log(MW)
twfe_continuous <- feols(log_providers ~ log_mw | state_id + year,
                         data = panel[min_wage > 0], cluster = ~state)
cat("\nTWFE continuous (log providers ~ log MW):\n")
print(summary(twfe_continuous))

saveRDS(twfe_providers, file.path(DATA, "twfe_providers.rds"))
saveRDS(twfe_spending, file.path(DATA, "twfe_spending.rds"))
saveRDS(twfe_continuous, file.path(DATA, "twfe_continuous.rds"))

## ---- 8. Group-specific ATTs ----
cat("\n=== Group-specific ATTs ===\n")
agg_group <- aggte(cs_providers, type = "group")
cat("ATT by treatment cohort:\n")
group_df <- data.table(
  cohort = agg_group$egt,
  att = agg_group$att.egt,
  se = agg_group$se.egt
)
group_df[, ci_low := att - 1.96 * se]
group_df[, ci_high := att + 1.96 * se]
print(group_df)

saveRDS(agg_group, file.path(DATA, "agg_group_providers.rds"))

## ---- 9. Save all key results ----
results <- list(
  # Overall ATTs
  att_providers = agg_overall,
  att_spending = agg_spending,
  att_percapita = agg_percapita,
  att_spend_pc = agg_spend_pc,
  # Event studies
  es_providers = es_providers,
  es_spending = es_spending,
  es_percapita = es_percapita,
  es_spend_pc = es_spend_pc,
  # TWFE
  twfe_providers = twfe_providers,
  twfe_spending = twfe_spending,
  twfe_continuous = twfe_continuous,
  # Group ATTs
  group_providers = agg_group
)

saveRDS(results, file.path(DATA, "main_results.rds"))

cat("\n=== Main analysis complete ===\n")
