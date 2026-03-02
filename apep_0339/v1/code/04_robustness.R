## ============================================================================
## 04_robustness.R — Robustness checks
## Paper: State Minimum Wage Increases and the Medicaid Home Care Workforce
## ============================================================================

source("00_packages.R")

DATA <- "../data"

## ---- 1. Load data ----
cat("Loading data...\n")
panel <- readRDS(file.path(DATA, "panel_hcbs_annual.rds"))
panel_nonhcbs <- readRDS(file.path(DATA, "panel_nonhcbs_annual.rds"))
cs_providers <- readRDS(file.path(DATA, "cs_providers.rds"))

robustness_results <- list()

## ---- 2. Falsification: Non-HCBS providers ----
cat("\n=== Falsification: Non-HCBS Providers ===\n")

cs_nonhcbs <- att_gt(
  yname = "log_providers",
  tname = "year",
  idname = "state_id",
  gname = "first_treat_year",
  data = as.data.frame(panel_nonhcbs),
  control_group = "nevertreated",
  anticipation = 0,
  base_period = "universal"
)

agg_nonhcbs <- aggte(cs_nonhcbs, type = "simple")
cat(sprintf("Falsification ATT (non-HCBS log providers): %.4f (SE: %.4f, p: %.4f)\n",
            agg_nonhcbs$overall.att, agg_nonhcbs$overall.se,
            2 * pnorm(-abs(agg_nonhcbs$overall.att / agg_nonhcbs$overall.se))))

es_nonhcbs <- aggte(cs_nonhcbs, type = "dynamic", min_e = -5, max_e = 5)
robustness_results$falsification_nonhcbs <- list(
  cs = cs_nonhcbs, agg = agg_nonhcbs, es = es_nonhcbs
)

## ---- 3. Alternative control group: not-yet-treated ----
cat("\n=== Alt Control: Not-yet-treated ===\n")

cs_nyt <- att_gt(
  yname = "log_providers",
  tname = "year",
  idname = "state_id",
  gname = "first_treat_year",
  data = as.data.frame(panel),
  control_group = "notyettreated",
  anticipation = 0,
  base_period = "universal"
)

agg_nyt <- aggte(cs_nyt, type = "simple")
cat(sprintf("Not-yet-treated ATT (log providers): %.4f (SE: %.4f, p: %.4f)\n",
            agg_nyt$overall.att, agg_nyt$overall.se,
            2 * pnorm(-abs(agg_nyt$overall.att / agg_nyt$overall.se))))

es_nyt <- aggte(cs_nyt, type = "dynamic", min_e = -5, max_e = 5)
robustness_results$not_yet_treated <- list(cs = cs_nyt, agg = agg_nyt, es = es_nyt)

## ---- 4. Allow 1 year anticipation ----
cat("\n=== Anticipation = 1 year ===\n")

cs_antic <- att_gt(
  yname = "log_providers",
  tname = "year",
  idname = "state_id",
  gname = "first_treat_year",
  data = as.data.frame(panel),
  control_group = "nevertreated",
  anticipation = 1,
  base_period = "universal"
)

agg_antic <- aggte(cs_antic, type = "simple")
cat(sprintf("Anticipation=1 ATT (log providers): %.4f (SE: %.4f, p: %.4f)\n",
            agg_antic$overall.att, agg_antic$overall.se,
            2 * pnorm(-abs(agg_antic$overall.att / agg_antic$overall.se))))

robustness_results$anticipation <- list(cs = cs_antic, agg = agg_antic)

## ---- 5. Continuous treatment: log(MW) elasticity ----
cat("\n=== Continuous Treatment: MW Elasticity ===\n")

# TWFE with region × year FE
panel[, census_division := fcase(
  state %in% c("CT","ME","MA","NH","RI","VT"), "New England",
  state %in% c("NJ","NY","PA"), "Mid-Atlantic",
  state %in% c("IN","IL","MI","OH","WI"), "E North Central",
  state %in% c("IA","KS","MN","MO","NE","ND","SD"), "W North Central",
  state %in% c("DE","DC","FL","GA","MD","NC","SC","VA","WV"), "South Atlantic",
  state %in% c("AL","KY","MS","TN"), "E South Central",
  state %in% c("AR","LA","OK","TX"), "W South Central",
  state %in% c("AZ","CO","ID","NM","MT","UT","NV","WY"), "Mountain",
  state %in% c("AK","CA","HI","OR","WA"), "Pacific",
  default = "Other"
)]

# Region × year FE
twfe_region <- feols(log_providers ~ log_mw | state_id + census_division^year,
                     data = panel[min_wage > 0], cluster = ~state)
cat("TWFE with region × year FE:\n")
print(summary(twfe_region))
robustness_results$twfe_region <- twfe_region

## ---- 6. Dose-response: magnitude of MW increase ----
cat("\n=== Dose-Response: MW Increase Magnitude ===\n")

# Cumulative MW change since 2017
panel[, cum_mw_change := min_wage - min_wage[year == min(year)], by = state]

twfe_dose <- feols(log_providers ~ cum_mw_change | state_id + year,
                   data = panel, cluster = ~state)
cat("Dose-response (cumulative MW change):\n")
print(summary(twfe_dose))
robustness_results$dose_response <- twfe_dose

## ---- 7. Placebo treatment dates ----
cat("\n=== Placebo: Fake treatment dates ===\n")

# Assign random treatment years to never-treated states
never_treated <- panel[first_treat_year == 0, unique(state)]
if (length(never_treated) >= 5) {
  panel_placebo <- copy(panel[state %in% never_treated])
  set.seed(42)
  placebo_years <- sample(2019:2022, length(never_treated), replace = TRUE)
  placebo_assign <- data.table(state = never_treated, placebo_treat = placebo_years)
  panel_placebo <- merge(panel_placebo, placebo_assign, by = "state")
  panel_placebo[, first_treat_year := placebo_treat]
  panel_placebo[, post := as.integer(year >= first_treat_year)]

  # Need at least some variation for CS
  # Use half as "treated" and half as "never treated"
  n_half <- length(never_treated) %/% 2
  placebo_treated <- never_treated[1:n_half]
  placebo_control <- never_treated[(n_half + 1):length(never_treated)]
  panel_placebo[state %in% placebo_control, first_treat_year := 0]

  cs_placebo <- tryCatch({
    att_gt(
      yname = "log_providers",
      tname = "year",
      idname = "state_id",
      gname = "first_treat_year",
      data = as.data.frame(panel_placebo),
      control_group = "nevertreated",
      anticipation = 0,
      base_period = "universal"
    )
  }, error = function(e) {
    cat(sprintf("  Placebo CS failed: %s\n", e$message))
    NULL
  })

  if (!is.null(cs_placebo)) {
    agg_placebo <- aggte(cs_placebo, type = "simple")
    cat(sprintf("Placebo ATT (should be ~0): %.4f (SE: %.4f, p: %.4f)\n",
                agg_placebo$overall.att, agg_placebo$overall.se,
                2 * pnorm(-abs(agg_placebo$overall.att / agg_placebo$overall.se))))
    robustness_results$placebo <- list(cs = cs_placebo, agg = agg_placebo)
  }
} else {
  cat("  Not enough never-treated states for placebo test.\n")
}

## ---- 8. Leave-one-out: Drop each treated state ----
cat("\n=== Leave-One-Out Sensitivity ===\n")

treated_states <- panel[first_treat_year > 0, unique(state)]
loo_results <- list()

for (st in treated_states) {
  panel_loo <- panel[state != st]
  cs_loo <- tryCatch({
    att_gt(
      yname = "log_providers",
      tname = "year",
      idname = "state_id",
      gname = "first_treat_year",
      data = as.data.frame(panel_loo),
      control_group = "nevertreated",
      anticipation = 0,
      base_period = "universal"
    )
  }, error = function(e) NULL)

  if (!is.null(cs_loo)) {
    agg_loo <- aggte(cs_loo, type = "simple")
    loo_results[[st]] <- data.table(
      dropped_state = st,
      att = agg_loo$overall.att,
      se = agg_loo$overall.se
    )
  }
}

if (length(loo_results) > 0) {
  loo_dt <- rbindlist(loo_results)
  cat("Leave-one-out ATTs:\n")
  cat(sprintf("  Range: [%.4f, %.4f]\n", min(loo_dt$att), max(loo_dt$att)))
  cat(sprintf("  Mean: %.4f\n", mean(loo_dt$att)))
  robustness_results$leave_one_out <- loo_dt
}

## ---- 9. Restrict to cohorts with ≥3 pre-periods ----
cat("\n=== Restrict: ≥3 pre-periods ===\n")

# Drop states treated in 2018-2019 (limited pre-data)
panel_restricted <- panel[first_treat_year == 0 | first_treat_year >= 2021]

cs_restricted <- tryCatch({
  att_gt(
    yname = "log_providers",
    tname = "year",
    idname = "state_id",
    gname = "first_treat_year",
    data = as.data.frame(panel_restricted),
    control_group = "nevertreated",
    anticipation = 0,
    base_period = "universal"
  )
}, error = function(e) {
  cat(sprintf("  Restricted CS failed: %s\n", e$message))
  NULL
})

if (!is.null(cs_restricted)) {
  agg_restricted <- aggte(cs_restricted, type = "simple")
  cat(sprintf("Restricted ATT (≥3 pre): %.4f (SE: %.4f, p: %.4f)\n",
              agg_restricted$overall.att, agg_restricted$overall.se,
              2 * pnorm(-abs(agg_restricted$overall.att / agg_restricted$overall.se))))
  es_restricted <- aggte(cs_restricted, type = "dynamic", min_e = -5, max_e = 5)
  robustness_results$restricted <- list(cs = cs_restricted, agg = agg_restricted, es = es_restricted)
}

## ---- 10. Sun-Abraham event study (via fixest) ----
cat("\n=== Sun-Abraham Event Study ===\n")

panel_sa <- copy(panel)
# sunab() needs treatment year as numeric (0 for never-treated → Inf)
panel_sa[, treat_year_sa := fifelse(first_treat_year == 0, 10000, first_treat_year)]

sa_fit <- feols(log_providers ~ sunab(treat_year_sa, year) | state_id + year,
                data = panel_sa, cluster = ~state)
cat("Sun-Abraham event study:\n")
print(summary(sa_fit))
robustness_results$sun_abraham <- sa_fit

## ---- 11. Save all robustness results ----
saveRDS(robustness_results, file.path(DATA, "robustness_results.rds"))

cat("\n=== Robustness checks complete ===\n")
