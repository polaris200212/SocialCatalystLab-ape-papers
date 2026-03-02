## ============================================================================
## 03_main_analysis.R — Main DiD analysis: Medicaid unwinding → provider exit
## Uses Callaway-Sant'Anna (2021) and two-way fixed effects (fixest)
## ============================================================================

source("00_packages.R")

## ---- 1. Load analysis panels ----
cat("Loading analysis panels...\n")
hcbs  <- readRDS(file.path(DATA, "hcbs_state_month.rds"))
treat <- readRDS(file.path(DATA, "treatment_timing.rds"))

cat(sprintf("HCBS panel: %d obs (%d states, %d months)\n",
    nrow(hcbs), uniqueN(hcbs$state), uniqueN(hcbs$month_date)))

## ---- 2. Summary statistics ----
cat("Computing summary statistics...\n")

# Pre-treatment means by cohort
pre <- hcbs[month_date < as.Date("2023-04-01")]
post <- hcbs[month_date >= as.Date("2023-04-01")]

sumstats <- rbind(
  data.table(period = "Pre-unwinding (2018-2023:03)",
             mean_providers = mean(pre$n_providers),
             sd_providers = sd(pre$n_providers),
             mean_paid = mean(pre$total_paid),
             mean_exit = mean(pre$exiting_hcbs_providers),
             mean_entry = mean(pre$new_hcbs_providers),
             n_obs = nrow(pre)),
  data.table(period = "Post-unwinding (2023:04-2024:12)",
             mean_providers = mean(post$n_providers),
             sd_providers = sd(post$n_providers),
             mean_paid = mean(post$total_paid),
             mean_exit = mean(post$exiting_hcbs_providers),
             mean_entry = mean(post$new_hcbs_providers),
             n_obs = nrow(post))
)
cat("\nSummary statistics:\n")
print(sumstats)

## ---- 3. Two-Way Fixed Effects (TWFE) — benchmark ----
cat("\n=== TWFE REGRESSIONS ===\n")

# Main outcome: log active HCBS providers
m_providers_twfe <- feols(log_providers ~ post | state + time_period,
                           data = hcbs, cluster = ~state)
cat("\nTWFE: Log HCBS providers\n")
print(summary(m_providers_twfe))

# Log billing volume
m_paid_twfe <- feols(log_paid ~ post | state + time_period,
                      data = hcbs, cluster = ~state)
cat("\nTWFE: Log HCBS billing\n")
print(summary(m_paid_twfe))

# Exit rate
m_exit_twfe <- feols(exit_rate ~ post | state + time_period,
                      data = hcbs, cluster = ~state)
cat("\nTWFE: Exit rate\n")
print(summary(m_exit_twfe))

# Net entry (new - exiting)
m_net_twfe <- feols(net_entry ~ post | state + time_period,
                     data = hcbs, cluster = ~state)
cat("\nTWFE: Net entry\n")
print(summary(m_net_twfe))

## ---- 4. Event Study (TWFE) ----
cat("\n=== EVENT STUDY ===\n")

# Bin relative time at -24 and +18
hcbs[, rel_time_binned := pmax(pmin(rel_time, 18), -24)]

# Event study with Sun-Abraham-style interactions
m_es <- feols(log_providers ~ i(rel_time_binned, ref = -1) | state + time_period,
              data = hcbs, cluster = ~state)
cat("\nEvent study: Log HCBS providers\n")
print(summary(m_es))

# Exit rate event study
m_es_exit <- feols(exit_rate ~ i(rel_time_binned, ref = -1) | state + time_period,
                    data = hcbs, cluster = ~state)

# Billing event study
m_es_paid <- feols(log_paid ~ i(rel_time_binned, ref = -1) | state + time_period,
                    data = hcbs, cluster = ~state)

## ---- 5. Callaway-Sant'Anna (2021) ----
cat("\n=== CALLAWAY-SANT'ANNA ===\n")

# Prepare data for did::att_gt
# Need: yname, tname, idname, gname
cs_data <- copy(hcbs)
cs_data[, state_id := as.integer(factor(state))]

# Treatment group: 0 for never-treated (none here — all states unwound)
# CS-DiD with all-treated requires not-yet-treated as comparison
cs_data[, g := treat_group]  # group = month of treatment

# Run CS-DiD
cat("Running Callaway-Sant'Anna (this may take a minute)...\n")
cs_providers <- tryCatch({
  att_gt(
    yname  = "log_providers",
    tname  = "time_period",
    idname = "state_id",
    gname  = "g",
    data   = as.data.frame(cs_data),
    control_group = "notyettreated",
    anticipation  = 0,
    est_method    = "dr",  # doubly robust
    bstrap        = TRUE,
    cband         = TRUE,
    biters        = 1000
  )
}, error = function(e) {
  cat("CS-DiD error:", conditionMessage(e), "\n")
  NULL
})

if (!is.null(cs_providers)) {
  cat("\nCS-DiD group-time ATTs:\n")
  print(summary(cs_providers))

  # Aggregate to simple ATT
  cs_agg <- aggte(cs_providers, type = "simple")
  cat("\nAggregate ATT:\n")
  print(summary(cs_agg))

  # Dynamic aggregation (event study)
  cs_dynamic <- aggte(cs_providers, type = "dynamic", min_e = -24, max_e = 18)
  cat("\nDynamic aggregation:\n")
  print(summary(cs_dynamic))

  # Save CS results
  saveRDS(cs_providers, file.path(DATA, "cs_providers.rds"))
  saveRDS(cs_agg, file.path(DATA, "cs_agg.rds"))
  saveRDS(cs_dynamic, file.path(DATA, "cs_dynamic.rds"))
}

# CS-DiD for exit rate
cs_exit <- tryCatch({
  att_gt(
    yname  = "exit_rate",
    tname  = "time_period",
    idname = "state_id",
    gname  = "g",
    data   = as.data.frame(cs_data),
    control_group = "notyettreated",
    anticipation  = 0,
    est_method    = "dr",
    bstrap        = TRUE,
    cband         = TRUE,
    biters        = 1000
  )
}, error = function(e) {
  cat("CS-DiD exit rate error:", conditionMessage(e), "\n")
  NULL
})

if (!is.null(cs_exit)) {
  cs_exit_agg <- aggte(cs_exit, type = "simple")
  cs_exit_dyn <- aggte(cs_exit, type = "dynamic", min_e = -24, max_e = 18)
  saveRDS(cs_exit, file.path(DATA, "cs_exit.rds"))
  saveRDS(cs_exit_agg, file.path(DATA, "cs_exit_agg.rds"))
  saveRDS(cs_exit_dyn, file.path(DATA, "cs_exit_dyn.rds"))
}

## ---- 6. Treatment intensity ----
cat("\n=== TREATMENT INTENSITY ===\n")

# Intensity = disenrollment rate × post
m_intensity <- feols(log_providers ~ disenroll_rate:post | state + time_period,
                      data = hcbs, cluster = ~state)
cat("\nIntensity (disenrollment rate × post):\n")
print(summary(m_intensity))

# Procedural share interaction
m_procedural <- feols(log_providers ~ procedural_share:post | state + time_period,
                       data = hcbs, cluster = ~state)
cat("\nProcedural share × post:\n")
print(summary(m_procedural))

## ---- 7. Heterogeneity: Individual vs Organization ----
cat("\n=== HETEROGENEITY ===\n")

# Individual providers (more vulnerable)
hcbs[, log_individual := log(n_individual + 1)]
hcbs[, log_org := log(n_org + 1)]
hcbs[, log_sole_prop := log(n_sole_prop + 1)]

m_individual <- feols(log_individual ~ post | state + time_period,
                       data = hcbs, cluster = ~state)
m_org <- feols(log_org ~ post | state + time_period,
                data = hcbs, cluster = ~state)
m_sole_prop <- feols(log_sole_prop ~ post | state + time_period,
                      data = hcbs, cluster = ~state)

cat("\nIndividual providers:\n")
print(summary(m_individual))
cat("\nOrganizational providers:\n")
print(summary(m_org))
cat("\nSole proprietors:\n")
print(summary(m_sole_prop))

## ---- 8. Save all results ----
results <- list(
  twfe_providers = m_providers_twfe,
  twfe_paid = m_paid_twfe,
  twfe_exit = m_exit_twfe,
  twfe_net_entry = m_net_twfe,
  es_providers = m_es,
  es_exit = m_es_exit,
  es_paid = m_es_paid,
  intensity = m_intensity,
  procedural = m_procedural,
  het_individual = m_individual,
  het_org = m_org,
  het_sole_prop = m_sole_prop
)
saveRDS(results, file.path(DATA, "main_results.rds"))
saveRDS(sumstats, file.path(DATA, "sumstats.rds"))

cat("\n=== Main analysis complete ===\n")
