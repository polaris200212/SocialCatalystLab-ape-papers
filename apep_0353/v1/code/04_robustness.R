## ============================================================================
## 04_robustness.R — Robustness checks and sensitivity analysis
## Paper: Tight Labor Markets and the Crisis in Home Care
## ============================================================================

source("00_packages.R")

panel <- readRDS(file.path(DATA, "analysis_panel.rds"))
smpl <- panel[in_sample == TRUE]
results <- readRDS(file.path(DATA, "main_results.rds"))

## ---- 1. Pre-trend test: event study around COVID ----
cat("=== Pre-trend / Event Study ===\n")

# Create period relative to 2020Q1 (COVID onset)
smpl[, rel_time := time_id - 9]  # time_id 9 = 2020Q1

# Bin endpoints
smpl[, rel_time_binned := pmax(pmin(rel_time, 12), -8)]

# Event study: OLS
es_ols <- feols(
  ln_hcbs_providers ~ i(rel_time_binned, emp_pop, ref = -1) |
    county_fips + state_fips^time_id,
  data = smpl,
  cluster = ~state_fips
)

cat("Event study OLS coefficients:\n")
print(coeftable(es_ols)[1:min(20, nrow(coeftable(es_ols))), ])

## ---- 2. Alternative employment measures ----
cat("\n=== Alternative Treatment Measures ===\n")

# Log employment instead of emp/pop ratio
smpl[, ln_emp := log(total_emp + 1)]
alt_lnemp <- feols(
  ln_hcbs_providers ~ 1 | county_fips + state_fips^time_id |
    ln_emp ~ bartik,
  data = smpl,
  cluster = ~state_fips
)

cat(sprintf("  ln(employment) IV: β = %.4f (SE = %.4f)\n",
            coef(alt_lnemp)["fit_ln_emp"], se(alt_lnemp)["fit_ln_emp"]))

## ---- 3. Exclude small counties ----
cat("\n=== Sample Restriction: Exclude Small Counties ===\n")

# Drop counties with fewer than 5 HCBS providers in base period
base_providers <- smpl[year == 2018, .(
  avg_providers = mean(hcbs_providers, na.rm = TRUE)
), by = county_fips]

large_counties <- base_providers[avg_providers >= 5]$county_fips
smpl_large <- smpl[county_fips %in% large_counties]

iv_large <- feols(
  ln_hcbs_providers ~ 1 | county_fips + state_fips^time_id |
    emp_pop ~ bartik,
  data = smpl_large,
  cluster = ~state_fips
)

cat(sprintf("  Large counties (>=5 base providers): β = %.4f (SE = %.4f), N = %d\n",
            coef(iv_large)["fit_emp_pop"], se(iv_large)["fit_emp_pop"],
            nobs(iv_large)))

## ---- 4. Add controls for demand shocks ----
cat("\n=== Controlling for Demand ===\n")

# Control for total Medicaid spending (demand proxy)
smpl[, ln_total_medicaid := log(hcbs_paid + non_hcbs_paid + 1)]

iv_demand_ctrl <- feols(
  ln_hcbs_providers ~ ln_total_medicaid | county_fips + state_fips^time_id |
    emp_pop ~ bartik,
  data = smpl,
  cluster = ~state_fips
)

cat(sprintf("  With demand control: β = %.4f (SE = %.4f)\n",
            coef(iv_demand_ctrl)["fit_emp_pop"],
            se(iv_demand_ctrl)["fit_emp_pop"]))

## ---- 5. Reduced form ----
cat("\n=== Reduced Form (Bartik → HCBS supply directly) ===\n")

rf_providers <- feols(
  ln_hcbs_providers ~ bartik | county_fips + state_fips^time_id,
  data = smpl,
  cluster = ~state_fips
)

rf_claims <- feols(
  ln_hcbs_claims ~ bartik | county_fips + state_fips^time_id,
  data = smpl,
  cluster = ~state_fips
)

cat(sprintf("  RF ln(providers): β = %.4f (SE = %.4f)\n",
            coef(rf_providers)["bartik"], se(rf_providers)["bartik"]))
cat(sprintf("  RF ln(claims):    β = %.4f (SE = %.4f)\n",
            coef(rf_claims)["bartik"], se(rf_claims)["bartik"]))

## ---- 6. Exclude COVID quarters (robustness) ----
cat("\n=== Exclude COVID Lockdown (2020Q1-Q2) ===\n")

smpl_no_covid <- smpl[!(year == 2020 & quarter <= 2)]

iv_no_covid <- feols(
  ln_hcbs_providers ~ 1 | county_fips + state_fips^time_id |
    emp_pop ~ bartik,
  data = smpl_no_covid,
  cluster = ~state_fips
)

cat(sprintf("  Excluding 2020Q1-Q2: β = %.4f (SE = %.4f), N = %d\n",
            coef(iv_no_covid)["fit_emp_pop"],
            se(iv_no_covid)["fit_emp_pop"],
            nobs(iv_no_covid)))

## ---- 7. Alternative clustering ----
cat("\n=== Alternative Clustering ===\n")

iv_county_cluster <- feols(
  ln_hcbs_providers ~ 1 | county_fips + state_fips^time_id |
    emp_pop ~ bartik,
  data = smpl,
  cluster = ~county_fips
)

cat(sprintf("  County-clustered SEs: β = %.4f (SE = %.4f)\n",
            coef(iv_county_cluster)["fit_emp_pop"],
            se(iv_county_cluster)["fit_emp_pop"]))

# Two-way clustering (state + quarter)
iv_twoway <- feols(
  ln_hcbs_providers ~ 1 | county_fips + state_fips^time_id |
    emp_pop ~ bartik,
  data = smpl,
  cluster = ~state_fips + time_id
)

cat(sprintf("  Two-way (state+quarter): β = %.4f (SE = %.4f)\n",
            coef(iv_twoway)["fit_emp_pop"], se(iv_twoway)["fit_emp_pop"]))

## ---- 8. Pre-period falsification ----
cat("\n=== Pre-Period Falsification ===\n")

# Regress 2018 HCBS levels on future (2021-2023) labor market changes
pre_levels <- smpl[year == 2018, .(
  avg_providers = mean(hcbs_providers, na.rm = TRUE),
  avg_claims = mean(hcbs_claims, na.rm = TRUE)
), by = county_fips]

post_tightness <- smpl[year >= 2021 & year <= 2023, .(
  avg_emp_pop = mean(emp_pop, na.rm = TRUE),
  delta_emp_pop = mean(emp_pop, na.rm = TRUE)
), by = county_fips]

# Get baseline emp_pop
base_tightness <- smpl[year == 2019, .(
  base_emp_pop = mean(emp_pop, na.rm = TRUE)
), by = county_fips]

post_tightness <- merge(post_tightness, base_tightness, by = "county_fips")
post_tightness[, change_emp_pop := avg_emp_pop - base_emp_pop]

falsif <- merge(pre_levels, post_tightness, by = "county_fips")

falsif_reg <- lm(log(avg_providers + 1) ~ change_emp_pop, data = falsif)
cat(sprintf("  Pre-2018 levels ~ future tightness: β = %.4f (SE = %.4f), p = %.3f\n",
            coef(falsif_reg)[2], sqrt(vcov(falsif_reg)[2, 2]),
            summary(falsif_reg)$coefficients[2, 4]))

## ---- 9. Save robustness results ----
robustness <- list(
  es_ols = es_ols,
  alt_lnemp = alt_lnemp,
  iv_large = iv_large,
  iv_demand_ctrl = iv_demand_ctrl,
  rf_providers = rf_providers,
  rf_claims = rf_claims,
  iv_no_covid = iv_no_covid,
  iv_county_cluster = iv_county_cluster,
  iv_twoway = iv_twoway,
  falsif_reg = falsif_reg
)

saveRDS(robustness, file.path(DATA, "robustness_results.rds"))
cat("\n=== Robustness checks complete ===\n")
