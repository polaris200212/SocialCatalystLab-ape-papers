## ============================================================================
## 03_main_analysis.R — Main regressions: TWFE + Bartik IV
## Paper: Tight Labor Markets and the Crisis in Home Care
## ============================================================================

source("00_packages.R")

panel <- readRDS(file.path(DATA, "analysis_panel.rds"))
smpl <- panel[in_sample == TRUE]

cat(sprintf("Analysis sample: %d county-quarters, %d counties\n",
            nrow(smpl), uniqueN(smpl$county_fips)))

## ---- 1. OLS: TWFE with state × quarter FE ----
cat("\n=== OLS Results (TWFE) ===\n")

# Main outcome: ln(HCBS providers)
ols_providers <- feols(
  ln_hcbs_providers ~ emp_pop | county_fips + state_fips^time_id,
  data = smpl,
  cluster = ~state_fips
)

# Outcome: ln(HCBS claims)
ols_claims <- feols(
  ln_hcbs_claims ~ emp_pop | county_fips + state_fips^time_id,
  data = smpl,
  cluster = ~state_fips
)

# Outcome: ln(HCBS spending)
ols_paid <- feols(
  ln_hcbs_paid ~ emp_pop | county_fips + state_fips^time_id,
  data = smpl,
  cluster = ~state_fips
)

# Outcome: ln(HCBS beneficiaries)
ols_benes <- feols(
  ln_hcbs_benes ~ emp_pop | county_fips + state_fips^time_id,
  data = smpl,
  cluster = ~state_fips
)

cat("OLS (county + state×quarter FE, clustered at state):\n")
cat(sprintf("  ln(providers):    β = %.4f (SE = %.4f)\n",
            coef(ols_providers)["emp_pop"], se(ols_providers)["emp_pop"]))
cat(sprintf("  ln(claims):       β = %.4f (SE = %.4f)\n",
            coef(ols_claims)["emp_pop"], se(ols_claims)["emp_pop"]))
cat(sprintf("  ln(paid):         β = %.4f (SE = %.4f)\n",
            coef(ols_paid)["emp_pop"], se(ols_paid)["emp_pop"]))
cat(sprintf("  ln(benes):        β = %.4f (SE = %.4f)\n",
            coef(ols_benes)["emp_pop"], se(ols_benes)["emp_pop"]))

## ---- 2. IV: Bartik instrument ----
cat("\n=== IV Results (Bartik Shift-Share) ===\n")

# 2SLS: emp_pop instrumented by bartik
iv_providers <- feols(
  ln_hcbs_providers ~ 1 | county_fips + state_fips^time_id |
    emp_pop ~ bartik,
  data = smpl,
  cluster = ~state_fips
)

iv_claims <- feols(
  ln_hcbs_claims ~ 1 | county_fips + state_fips^time_id |
    emp_pop ~ bartik,
  data = smpl,
  cluster = ~state_fips
)

iv_paid <- feols(
  ln_hcbs_paid ~ 1 | county_fips + state_fips^time_id |
    emp_pop ~ bartik,
  data = smpl,
  cluster = ~state_fips
)

iv_benes <- feols(
  ln_hcbs_benes ~ 1 | county_fips + state_fips^time_id |
    emp_pop ~ bartik,
  data = smpl,
  cluster = ~state_fips
)

cat("IV (Bartik, county + state×quarter FE, clustered at state):\n")
cat(sprintf("  ln(providers):    β = %.4f (SE = %.4f)\n",
            coef(iv_providers)["fit_emp_pop"], se(iv_providers)["fit_emp_pop"]))
cat(sprintf("  ln(claims):       β = %.4f (SE = %.4f)\n",
            coef(iv_claims)["fit_emp_pop"], se(iv_claims)["fit_emp_pop"]))
cat(sprintf("  ln(paid):         β = %.4f (SE = %.4f)\n",
            coef(iv_paid)["fit_emp_pop"], se(iv_paid)["fit_emp_pop"]))
cat(sprintf("  ln(benes):        β = %.4f (SE = %.4f)\n",
            coef(iv_benes)["fit_emp_pop"], se(iv_benes)["fit_emp_pop"]))

# First stage
first_stage <- feols(
  emp_pop ~ bartik | county_fips + state_fips^time_id,
  data = smpl,
  cluster = ~state_fips
)
cat(sprintf("\nFirst stage: bartik coef = %.4f (SE = %.4f), F = %.1f\n",
            coef(first_stage)["bartik"], se(first_stage)["bartik"],
            fitstat(iv_providers, "ivf")$ivf1$stat))

## ---- 3. IV excluding healthcare (NAICS 62) ----
cat("\n=== IV Robustness: Bartik excluding NAICS 62 ===\n")

iv_providers_no62 <- feols(
  ln_hcbs_providers ~ 1 | county_fips + state_fips^time_id |
    emp_pop ~ bartik_no62,
  data = smpl,
  cluster = ~state_fips
)

cat(sprintf("  ln(providers), excl. NAICS 62: β = %.4f (SE = %.4f)\n",
            coef(iv_providers_no62)["fit_emp_pop"],
            se(iv_providers_no62)["fit_emp_pop"]))

## ---- 4. Placebo: non-HCBS providers ----
cat("\n=== Placebo: Non-HCBS Medicaid providers ===\n")

placebo_ols <- feols(
  ln_non_hcbs_providers ~ emp_pop | county_fips + state_fips^time_id,
  data = smpl,
  cluster = ~state_fips
)

placebo_iv <- feols(
  ln_non_hcbs_providers ~ 1 | county_fips + state_fips^time_id |
    emp_pop ~ bartik,
  data = smpl,
  cluster = ~state_fips
)

cat(sprintf("  OLS:  β = %.4f (SE = %.4f)\n",
            coef(placebo_ols)["emp_pop"], se(placebo_ols)["emp_pop"]))
cat(sprintf("  IV:   β = %.4f (SE = %.4f)\n",
            coef(placebo_iv)["fit_emp_pop"], se(placebo_iv)["fit_emp_pop"]))

## ---- 5. Individual vs organizational providers ----
cat("\n=== Heterogeneity: Individual vs Organizational Providers ===\n")

smpl[, ln_indiv_prov := log(hcbs_indiv_providers + 1)]
smpl[, ln_org_prov := log(hcbs_org_providers + 1)]

iv_indiv <- feols(
  ln_indiv_prov ~ 1 | county_fips + state_fips^time_id |
    emp_pop ~ bartik,
  data = smpl,
  cluster = ~state_fips
)

iv_org <- feols(
  ln_org_prov ~ 1 | county_fips + state_fips^time_id |
    emp_pop ~ bartik,
  data = smpl,
  cluster = ~state_fips
)

cat(sprintf("  Individual providers: β = %.4f (SE = %.4f)\n",
            coef(iv_indiv)["fit_emp_pop"], se(iv_indiv)["fit_emp_pop"]))
cat(sprintf("  Org providers:        β = %.4f (SE = %.4f)\n",
            coef(iv_org)["fit_emp_pop"], se(iv_org)["fit_emp_pop"]))

## ---- 6. Urban vs Rural heterogeneity ----
cat("\n=== Heterogeneity: Urban vs Rural ===\n")

iv_urban <- feols(
  ln_hcbs_providers ~ 1 | county_fips + state_fips^time_id |
    emp_pop ~ bartik,
  data = smpl[urban == 1],
  cluster = ~state_fips
)

iv_rural <- feols(
  ln_hcbs_providers ~ 1 | county_fips + state_fips^time_id |
    emp_pop ~ bartik,
  data = smpl[urban == 0],
  cluster = ~state_fips
)

cat(sprintf("  Urban: β = %.4f (SE = %.4f), N = %d\n",
            coef(iv_urban)["fit_emp_pop"], se(iv_urban)["fit_emp_pop"],
            nobs(iv_urban)))
cat(sprintf("  Rural: β = %.4f (SE = %.4f), N = %d\n",
            coef(iv_rural)["fit_emp_pop"], se(iv_rural)["fit_emp_pop"],
            nobs(iv_rural)))

## ---- 7. Save results ----
results <- list(
  ols_providers = ols_providers,
  ols_claims = ols_claims,
  ols_paid = ols_paid,
  ols_benes = ols_benes,
  iv_providers = iv_providers,
  iv_claims = iv_claims,
  iv_paid = iv_paid,
  iv_benes = iv_benes,
  iv_providers_no62 = iv_providers_no62,
  first_stage = first_stage,
  placebo_ols = placebo_ols,
  placebo_iv = placebo_iv,
  iv_indiv = iv_indiv,
  iv_org = iv_org,
  iv_urban = iv_urban,
  iv_rural = iv_rural
)

saveRDS(results, file.path(DATA, "main_results.rds"))
cat("\n=== Main analysis complete ===\n")
