## ============================================================================
## 03_main_analysis.R — Triple-difference estimation
## ============================================================================

source("00_packages.R")

DATA <- "../data"
TABLES <- "../tables"
dir.create(TABLES, showWarnings = FALSE)

panel <- readRDS(file.path(DATA, "panel_analysis.rds"))
state_treatment <- readRDS(file.path(DATA, "state_treatment.rds"))

cat("=== Triple-Difference Analysis ===\n\n")

## ---- 1. Main specification: DDD with continuous stringency ----
# Y_{s,k,t} = β (Stringency_s × HCBS_k × Post_t) + state×service FE + service×month FE + state×month FE + ε
# β captures differential effect of lockdown stringency on HCBS vs BH

# Ensure proper factor coding
panel[, `:=`(
  state_f = factor(state),
  service_f = factor(service_type),
  month_f = factor(month_date)
)]

# Main DDD: log spending
cat("--- Model 1: Log Total Paid ---\n")
m1_paid <- feols(
  log_paid ~ peak_stringency_std:is_hcbs:post |
    state_f^service_f + service_f^month_f + state_f^month_f,
  data = panel,
  cluster = ~state_f
)
cat("DDD coefficient (log paid):\n")
summary(m1_paid)

# Main DDD: log claims
cat("\n--- Model 2: Log Total Claims ---\n")
m2_claims <- feols(
  log_claims ~ peak_stringency_std:is_hcbs:post |
    state_f^service_f + service_f^month_f + state_f^month_f,
  data = panel,
  cluster = ~state_f
)
summary(m2_claims)

# Main DDD: log providers
cat("\n--- Model 3: Log Number of Providers ---\n")
m3_providers <- feols(
  log_providers ~ peak_stringency_std:is_hcbs:post |
    state_f^service_f + service_f^month_f + state_f^month_f,
  data = panel,
  cluster = ~state_f
)
summary(m3_providers)

# Main DDD: log beneficiaries
cat("\n--- Model 4: Log Total Beneficiaries ---\n")
m4_benef <- feols(
  log_beneficiaries ~ peak_stringency_std:is_hcbs:post |
    state_f^service_f + service_f^month_f + state_f^month_f,
  data = panel,
  cluster = ~state_f
)
summary(m4_benef)

## ---- 2. Dynamic DDD: Allow time-varying effects ----
cat("\n=== Dynamic Triple-Difference (Event Study) ===\n")

# Create relative-time indicators (quarters relative to April 2020)
panel[, rel_quarter := floor(as.numeric(difftime(month_date, as.Date("2020-04-01"),
                                                  units = "days")) / 91.25)]
# Cap at extremes
panel[, rel_quarter := pmax(pmin(rel_quarter, 18), -8)]

# Interaction with stringency and HCBS
# Reference period: Q-1 (Jan-Mar 2020, just before lockdown)
panel[, rel_q_f := relevel(factor(rel_quarter), ref = "-1")]

cat("--- Dynamic DDD: Log Paid ---\n")

# Create interaction variable for i()
panel[, str_x_hcbs := peak_stringency_std * is_hcbs]

m_dynamic <- feols(
  log_paid ~ i(rel_quarter, str_x_hcbs, ref = -1) |
    state_f^service_f + service_f^month_f + state_f^month_f,
  data = panel,
  cluster = ~state_f
)
summary(m_dynamic)

## ---- 3. Intensive margin decomposition ----
cat("\n=== Intensive Margin: Per-Provider Outcomes ===\n")

# Create per-provider measures
panel[, `:=`(
  claims_per_provider = total_claims / n_providers,
  paid_per_provider = total_paid / n_providers,
  benef_per_provider = total_beneficiaries / n_providers,
  log_claims_per_prov = log(total_claims / n_providers + 1),
  log_paid_per_prov = log(total_paid / n_providers + 1),
  log_benef_per_prov = log(total_beneficiaries / n_providers + 1)
)]

# DDD on intensive margin
cat("--- Model 5: Log Paid Per Provider ---\n")
m5_intensive <- feols(
  log_paid_per_prov ~ peak_stringency_std:is_hcbs:post |
    state_f^service_f + service_f^month_f + state_f^month_f,
  data = panel,
  cluster = ~state_f
)
summary(m5_intensive)

cat("--- Model 6: Log Beneficiaries Per Provider ---\n")
m6_benef_prov <- feols(
  log_benef_per_prov ~ peak_stringency_std:is_hcbs:post |
    state_f^service_f + service_f^month_f + state_f^month_f,
  data = panel,
  cluster = ~state_f
)
summary(m6_benef_prov)

## ---- 4. Period-specific effects (lockdown, recovery, long-run) ----
cat("\n=== Period-Specific Effects ===\n")

panel[, `:=`(
  lockdown_period = as.integer(month_date >= as.Date("2020-04-01") & month_date < as.Date("2020-07-01")),
  recovery_period = as.integer(month_date >= as.Date("2020-07-01") & month_date < as.Date("2021-01-01")),
  post_lockdown_2021 = as.integer(month_date >= as.Date("2021-01-01") & month_date < as.Date("2022-01-01")),
  post_lockdown_2022plus = as.integer(month_date >= as.Date("2022-01-01"))
)]

m7_periods <- feols(
  log_paid ~ peak_stringency_std:is_hcbs:lockdown_period +
    peak_stringency_std:is_hcbs:recovery_period +
    peak_stringency_std:is_hcbs:post_lockdown_2021 +
    peak_stringency_std:is_hcbs:post_lockdown_2022plus |
    state_f^service_f + service_f^month_f + state_f^month_f,
  data = panel,
  cluster = ~state_f
)
cat("Period-specific DDD effects:\n")
summary(m7_periods)

## ---- 5. Save results ----
results <- list(
  m1_paid = m1_paid,
  m2_claims = m2_claims,
  m3_providers = m3_providers,
  m4_benef = m4_benef,
  m5_intensive = m5_intensive,
  m6_benef_prov = m6_benef_prov,
  m7_periods = m7_periods,
  m_dynamic = m_dynamic
)

saveRDS(results, file.path(DATA, "main_results.rds"))
saveRDS(panel, file.path(DATA, "panel_analysis.rds"))

cat("\n=== Main analysis complete ===\n")
