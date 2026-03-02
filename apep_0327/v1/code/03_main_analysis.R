## ============================================================================
## 03_main_analysis.R — Primary DiD estimation
## APEP-0326: State Minimum Wage Increases and the HCBS Provider Supply Crisis
## ============================================================================

source("00_packages.R")

## ---- Load panels ----
annual <- readRDS(file.path(DATA, "panel_annual.rds"))
monthly <- readRDS(file.path(DATA, "panel_monthly.rds"))

cat("=== MAIN ANALYSIS ===\n")
cat(sprintf("Annual panel: %d obs, %d states, %d years\n",
            nrow(annual), uniqueN(annual$state), uniqueN(annual$year)))

## ========================================================================
## 1. SUMMARY STATISTICS
## ========================================================================

cat("\n--- Summary Statistics ---\n")

# Treated vs never-treated comparison
treated_states <- annual[first_treat_year > 0, unique(state)]
control_states <- annual[first_treat_year == 0, unique(state)]
cat(sprintf("Treated states: %d\n", length(treated_states)))
cat(sprintf("Never-treated states: %d\n", length(control_states)))

# Baseline (2018) comparison
baseline <- annual[year == 2018]
cat("\nBaseline (2018) means:\n")
cat(sprintf("  Treated — providers: %.0f, benes: %.0f, MW: $%.2f\n",
            mean(baseline[state %in% treated_states]$n_providers, na.rm = TRUE),
            mean(baseline[state %in% treated_states]$total_benes, na.rm = TRUE),
            mean(baseline[state %in% treated_states]$min_wage, na.rm = TRUE)))
cat(sprintf("  Control — providers: %.0f, benes: %.0f, MW: $%.2f\n",
            mean(baseline[state %in% control_states]$n_providers, na.rm = TRUE),
            mean(baseline[state %in% control_states]$total_benes, na.rm = TRUE),
            mean(baseline[state %in% control_states]$min_wage, na.rm = TRUE)))

## ========================================================================
## 2. TWFE SPECIFICATIONS (fixest)
## ========================================================================

cat("\n--- TWFE Regressions ---\n")

# Specification 1: Binary treatment (above federal)
twfe_1 <- feols(log_providers ~ above_federal | state + year,
                data = annual, cluster = ~state)

# Specification 2: Log minimum wage (continuous)
twfe_2 <- feols(log_providers ~ log_mw | state + year,
                data = annual, cluster = ~state)

# Specification 3: MW premium over federal
twfe_3 <- feols(log_providers ~ mw_premium | state + year,
                data = annual, cluster = ~state)

# Specification 4: With controls (if unemployment data available)
if (any(!is.na(annual$unemp_rate))) {
  twfe_4 <- feols(log_providers ~ log_mw + unemp_rate | state + year,
                  data = annual[!is.na(unemp_rate)], cluster = ~state)
} else {
  # Use population as control instead
  twfe_4 <- feols(log_providers ~ log_mw + log(population) | state + year,
                  data = annual[!is.na(log_providers) & population > 0], cluster = ~state)
}

# Multiple outcomes
twfe_benes <- feols(log_benes ~ log_mw | state + year,
                     data = annual, cluster = ~state)

twfe_entry <- feols(entry_rate ~ log_mw | state + year,
                     data = annual[is.finite(entry_rate)], cluster = ~state)

twfe_exit <- feols(exit_rate ~ log_mw | state + year,
                    data = annual[is.finite(exit_rate)], cluster = ~state)

twfe_individual <- feols(log_individual ~ log_mw | state + year,
                          data = annual[!is.na(log_individual)], cluster = ~state)

twfe_org <- feols(log_org ~ log_mw | state + year,
                   data = annual[!is.na(log_org)], cluster = ~state)

# Print results
cat("\nTWFE Results (clustered at state level):\n")
etable(twfe_1, twfe_2, twfe_3, twfe_4,
       headers = c("Binary", "Log MW", "MW Premium", "+Controls"),
       fitstat = c("n", "r2"),
       se.below = TRUE)

cat("\nMultiple Outcomes (all using log MW):\n")
etable(twfe_2, twfe_benes, twfe_entry, twfe_exit, twfe_individual, twfe_org,
       headers = c("Providers", "Beneficiaries", "Entry Rate", "Exit Rate",
                    "Individual", "Organization"),
       fitstat = c("n", "r2"),
       se.below = TRUE)

## ========================================================================
## 3. CALLAWAY-SANT'ANNA (2021) — Heterogeneity-robust DiD
## ========================================================================

cat("\n--- Callaway-Sant'Anna (2021) Estimation ---\n")

# CS-DiD requires: panel data, numeric ID, time, treatment cohort
# Use annual panel with first_treat_year as cohort

# Primary outcome: log providers
cs_providers <- tryCatch({
  att_gt(
    yname = "log_providers",
    tname = "year",
    idname = "state_id",
    gname = "first_treat_year",
    data = as.data.frame(annual[!is.na(log_providers)]),
    control_group = "nevertreated",
    anticipation = 0,
    base_period = "universal"
  )
}, error = function(e) {
  cat("CS-DiD error:", e$message, "\n")
  NULL
})

if (!is.null(cs_providers)) {
  # Overall ATT
  cs_agg <- aggte(cs_providers, type = "simple")
  cat(sprintf("\nCS-DiD Overall ATT (log providers): %.4f (SE: %.4f, p: %.4f)\n",
              cs_agg$overall.att, cs_agg$overall.se,
              2 * pnorm(-abs(cs_agg$overall.att / cs_agg$overall.se))))

  # Dynamic (event study) ATT
  cs_es <- aggte(cs_providers, type = "dynamic", min_e = -5, max_e = 5)
  cat("\nEvent Study Estimates:\n")
  es_df <- data.frame(
    period = cs_es$egt,
    att = cs_es$att.egt,
    se = cs_es$se.egt,
    ci_lower = cs_es$att.egt - 1.96 * cs_es$se.egt,
    ci_upper = cs_es$att.egt + 1.96 * cs_es$se.egt
  )
  print(es_df)

  # Group-level ATT (by cohort)
  cs_group <- aggte(cs_providers, type = "group")
  cat("\nGroup-Level ATT:\n")
  group_df <- data.frame(
    group = cs_group$egt,
    att = cs_group$att.egt,
    se = cs_group$se.egt
  )
  print(group_df)

  saveRDS(cs_providers, file.path(DATA, "cs_providers.rds"))
  saveRDS(cs_es, file.path(DATA, "cs_es_providers.rds"))
}

# Beneficiaries
cs_benes <- tryCatch({
  att_gt(
    yname = "log_benes",
    tname = "year",
    idname = "state_id",
    gname = "first_treat_year",
    data = as.data.frame(annual[!is.na(log_benes)]),
    control_group = "nevertreated",
    anticipation = 0,
    base_period = "universal"
  )
}, error = function(e) {
  cat("CS-DiD (benes) error:", e$message, "\n")
  NULL
})

if (!is.null(cs_benes)) {
  cs_benes_agg <- aggte(cs_benes, type = "simple")
  cat(sprintf("\nCS-DiD Overall ATT (log benes): %.4f (SE: %.4f)\n",
              cs_benes_agg$overall.att, cs_benes_agg$overall.se))

  cs_benes_es <- aggte(cs_benes, type = "dynamic", min_e = -5, max_e = 5)
  saveRDS(cs_benes_es, file.path(DATA, "cs_es_benes.rds"))
}

# Individual providers
cs_indiv <- tryCatch({
  att_gt(
    yname = "log_individual",
    tname = "year",
    idname = "state_id",
    gname = "first_treat_year",
    data = as.data.frame(annual[!is.na(log_individual)]),
    control_group = "nevertreated",
    anticipation = 0,
    base_period = "universal"
  )
}, error = function(e) {
  cat("CS-DiD (individual) error:", e$message, "\n")
  NULL
})

if (!is.null(cs_indiv)) {
  cs_indiv_agg <- aggte(cs_indiv, type = "simple")
  cat(sprintf("\nCS-DiD Overall ATT (log individual): %.4f (SE: %.4f)\n",
              cs_indiv_agg$overall.att, cs_indiv_agg$overall.se))
  cs_indiv_es <- aggte(cs_indiv, type = "dynamic", min_e = -5, max_e = 5)
  saveRDS(cs_indiv_es, file.path(DATA, "cs_es_individual.rds"))
}

## ========================================================================
## 4. SUN-ABRAHAM (2021) VIA FIXEST — Alternative heterogeneity-robust
## ========================================================================

cat("\n--- Sun-Abraham (2021) via fixest ---\n")

# sunab() in fixest handles staggered DiD
# Requires: first_treat_year as treatment cohort, year as time
# Never-treated states have first_treat_year = 0 — need to convert to large value
annual[, treat_cohort := fifelse(first_treat_year == 0, 10000L, first_treat_year)]

sa_providers <- feols(log_providers ~ sunab(treat_cohort, year) | state + year,
                       data = annual[!is.na(log_providers)],
                       cluster = ~state)

cat("Sun-Abraham results:\n")
summary(sa_providers)

sa_benes <- feols(log_benes ~ sunab(treat_cohort, year) | state + year,
                   data = annual[!is.na(log_benes)],
                   cluster = ~state)

## ========================================================================
## 5. SAVE ALL RESULTS
## ========================================================================

results <- list(
  twfe = list(twfe_1, twfe_2, twfe_3, twfe_4),
  twfe_outcomes = list(twfe_2, twfe_benes, twfe_entry, twfe_exit,
                        twfe_individual, twfe_org),
  sa = list(sa_providers, sa_benes),
  summary_stats = list(
    n_treated = length(treated_states),
    n_control = length(control_states),
    treated_states = treated_states,
    control_states = control_states
  )
)

saveRDS(results, file.path(DATA, "main_results.rds"))

cat("\n=== Main analysis complete ===\n")
