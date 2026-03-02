## ============================================================================
## 03_main_analysis.R — Primary specifications
## apep_0467: Priced Out of Care
##
## Specifications:
##   1. Event study (wage ratio × month dummies)
##   2. Pre/post DiD (aggregate treatment effect)
##   3. Heterogeneity by provider type (sole prop vs organization)
##   4. Beneficiary access effects
##   5. Spending and intensity effects
## ============================================================================

source("00_packages.R")

panel <- readRDS(file.path(DATA, "panel_analysis.rds"))
cat(sprintf("Panel loaded: %d rows, %d states\n", nrow(panel), uniqueN(panel$state)))

## ============================================================
## 1. Event Study — Main Specification
## ============================================================
cat("\n=== Specification 1: Event Study ===\n")

# Reference period: January 2020 (event_time = 0)
# Event time: months relative to Jan 2020
# Exclude event_time == 0 as reference

# Main outcome: log active HCBS providers
es_providers <- feols(
  log_providers ~ i(event_time, wage_ratio, ref = 0) | state + month_date,
  data = panel,
  cluster = ~state
)

cat("Event study (providers):\n")
summary(es_providers)

# Beneficiaries
es_beneficiaries <- feols(
  log_beneficiaries ~ i(event_time, wage_ratio, ref = 0) | state + month_date,
  data = panel,
  cluster = ~state
)

# Spending
es_spending <- feols(
  log_spending ~ i(event_time, wage_ratio, ref = 0) | state + month_date,
  data = panel,
  cluster = ~state
)

# Save event study objects
saveRDS(list(
  providers = es_providers,
  beneficiaries = es_beneficiaries,
  spending = es_spending
), file.path(DATA, "es_results.rds"))

cat("Event study results saved.\n")


## ============================================================
## 2. Pre/Post DiD — Aggregate Treatment Effect
## ============================================================
cat("\n=== Specification 2: Pre/Post DiD ===\n")

# Baseline: no controls
did_base <- feols(
  log_providers ~ wage_ratio_x_post | state + month_date,
  data = panel,
  cluster = ~state
)
cat("DiD (baseline):\n")
summary(did_base)

# With COVID controls
did_covid <- feols(
  log_providers ~ wage_ratio_x_post + covid_cases_pc + state_ur | state + month_date,
  data = panel,
  cluster = ~state
)
cat("DiD (with COVID controls):\n")
summary(did_covid)

# Multiple outcomes
did_outcomes <- list()
for (yvar in c("log_providers", "log_beneficiaries", "log_spending", "log_claims")) {
  fml <- as.formula(paste0(yvar, " ~ wage_ratio_x_post + covid_cases_pc + state_ur | state + month_date"))
  did_outcomes[[yvar]] <- feols(fml, data = panel, cluster = ~state)
}

# ARPA interaction (additional post-period)
did_arpa <- feols(
  log_providers ~ wage_ratio_x_post + wage_ratio_x_post_arpa +
    covid_cases_pc + state_ur | state + month_date,
  data = panel,
  cluster = ~state
)
cat("DiD (with ARPA interaction):\n")
summary(did_arpa)


## ============================================================
## 3. Heterogeneity by Provider Type
## ============================================================
cat("\n=== Specification 3: Provider Type Heterogeneity ===\n")

# Sole proprietors (individual workers)
did_sole <- feols(
  log_sole_prop ~ wage_ratio_x_post + covid_cases_pc + state_ur | state + month_date,
  data = panel,
  cluster = ~state
)

# Organizations
did_org <- feols(
  log_org ~ wage_ratio_x_post + covid_cases_pc + state_ur | state + month_date,
  data = panel,
  cluster = ~state
)

cat("Sole proprietors:\n")
summary(did_sole)
cat("Organizations:\n")
summary(did_org)


## ============================================================
## 4. Binned Treatment (Terciles) — Robustness to Functional Form
## ============================================================
cat("\n=== Specification 4: Tercile-Based DiD ===\n")

# Create interaction terms for terciles
panel[, `:=`(
  low_x_post = as.integer(ratio_tercile == "Low") * post_covid,
  med_x_post = as.integer(ratio_tercile == "Medium") * post_covid,
  high_x_post = as.integer(ratio_tercile == "High") * post_covid
)]

# Reference group: High tercile (most competitive)
did_tercile <- feols(
  log_providers ~ low_x_post + med_x_post + covid_cases_pc + state_ur | state + month_date,
  data = panel,
  cluster = ~state
)
cat("Tercile DiD (ref = High):\n")
summary(did_tercile)

# Event study by tercile
es_tercile <- feols(
  log_providers ~ i(event_time, i.ratio_tercile, ref = 0, ref2 = "High") | state + month_date,
  data = panel,
  cluster = ~state
)


## ============================================================
## 5. Per-Capita Outcomes
## ============================================================
cat("\n=== Specification 5: Per-Capita Outcomes ===\n")

did_pc <- feols(
  c(providers_pc, beneficiaries_pc) ~ wage_ratio_x_post +
    covid_cases_pc + state_ur | state + month_date,
  data = panel[!is.na(providers_pc)],
  cluster = ~state
)
summary(did_pc)


## ============================================================
## Save All Results
## ============================================================

results <- list(
  # Event studies
  es_providers = es_providers,
  es_beneficiaries = es_beneficiaries,
  es_spending = es_spending,
  es_tercile = es_tercile,
  # Pre/post DiD
  did_base = did_base,
  did_covid = did_covid,
  did_outcomes = did_outcomes,
  did_arpa = did_arpa,
  # Heterogeneity
  did_sole = did_sole,
  did_org = did_org,
  # Terciles
  did_tercile = did_tercile,
  # Per capita
  did_pc = did_pc
)

saveRDS(results, file.path(DATA, "main_results.rds"))
cat("\n=== All main results saved ===\n")
