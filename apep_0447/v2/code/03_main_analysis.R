## ============================================================================
## 03_main_analysis.R — Triple-difference estimation
## v2 revision: Clean HCBS primary + WS2 decomposition (HCBS-only, BH-only DiD)
## ============================================================================

source("00_packages.R")

DATA <- "../data"
TABLES <- "../tables"
dir.create(TABLES, showWarnings = FALSE)

panel <- readRDS(file.path(DATA, "panel_analysis.rds"))  # Clean HCBS
panel_all <- readRDS(file.path(DATA, "panel_all_analysis.rds"))  # All HCBS
state_treatment <- readRDS(file.path(DATA, "state_treatment.rds"))

cat("=== Triple-Difference Analysis (Clean HCBS) ===\n\n")

## ---- 1. Main specification: DDD with continuous stringency ----
panel[, `:=`(
  state_f = factor(state),
  service_f = factor(service_type),
  month_f = factor(month_date)
)]

# Model 1: Log Total Paid
cat("--- Model 1: Log Total Paid ---\n")
m1_paid <- feols(
  log_paid ~ peak_stringency_std:is_hcbs:post |
    state_f^service_f + service_f^month_f + state_f^month_f,
  data = panel,
  cluster = ~state_f
)
summary(m1_paid)

# Model 2: Log Total Claims
cat("\n--- Model 2: Log Total Claims ---\n")
m2_claims <- feols(
  log_claims ~ peak_stringency_std:is_hcbs:post |
    state_f^service_f + service_f^month_f + state_f^month_f,
  data = panel,
  cluster = ~state_f
)
summary(m2_claims)

# Model 3: Log Providers
cat("\n--- Model 3: Log Number of Providers ---\n")
m3_providers <- feols(
  log_providers ~ peak_stringency_std:is_hcbs:post |
    state_f^service_f + service_f^month_f + state_f^month_f,
  data = panel,
  cluster = ~state_f
)
summary(m3_providers)

# Model 4: Log Beneficiaries
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

panel[, rel_quarter := floor(as.numeric(difftime(month_date, as.Date("2020-04-01"),
                                                  units = "days")) / 91.25)]
panel[, rel_quarter := pmax(pmin(rel_quarter, 18), -8)]
panel[, rel_q_f := relevel(factor(rel_quarter), ref = "-1")]

cat("--- Dynamic DDD: Log Paid ---\n")
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

panel[, `:=`(
  claims_per_provider = total_claims / n_providers,
  paid_per_provider = total_paid / n_providers,
  benef_per_provider = total_beneficiaries / n_providers,
  log_claims_per_prov = log(total_claims / n_providers + 1),
  log_paid_per_prov = log(total_paid / n_providers + 1),
  log_benef_per_prov = log(total_beneficiaries / n_providers + 1)
)]

# Model 5: Log Paid Per Provider
cat("--- Model 5: Log Paid Per Provider ---\n")
m5_intensive <- feols(
  log_paid_per_prov ~ peak_stringency_std:is_hcbs:post |
    state_f^service_f + service_f^month_f + state_f^month_f,
  data = panel,
  cluster = ~state_f
)
summary(m5_intensive)

# Model 6: Log Beneficiaries Per Provider
cat("--- Model 6: Log Beneficiaries Per Provider ---\n")
m6_benef_prov <- feols(
  log_benef_per_prov ~ peak_stringency_std:is_hcbs:post |
    state_f^service_f + service_f^month_f + state_f^month_f,
  data = panel,
  cluster = ~state_f
)
summary(m6_benef_prov)

## ---- 4. Period-specific effects ----
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

## ---- 5. WS2: DDD Decomposition — HCBS-only and BH-only DiD ----
cat("\n=== WS2: Decomposition — Separate DiD for HCBS and BH ===\n")

# HCBS-only DiD: log_paid ~ stringency × post | state + month
hcbs_only <- panel[service_type == "HCBS"]
bh_only <- panel[service_type == "BH"]

cat("--- HCBS-only DiD: Log Paid ---\n")
m_hcbs_did <- feols(
  log_paid ~ peak_stringency_std:post | state_f + month_f,
  data = hcbs_only,
  cluster = ~state_f
)
summary(m_hcbs_did)

cat("\n--- HCBS-only DiD: Log Claims ---\n")
m_hcbs_did_claims <- feols(
  log_claims ~ peak_stringency_std:post | state_f + month_f,
  data = hcbs_only,
  cluster = ~state_f
)
summary(m_hcbs_did_claims)

cat("\n--- BH-only DiD: Log Paid ---\n")
m_bh_did <- feols(
  log_paid ~ peak_stringency_std:post | state_f + month_f,
  data = bh_only,
  cluster = ~state_f
)
summary(m_bh_did)

cat("\n--- BH-only DiD: Log Claims ---\n")
m_bh_did_claims <- feols(
  log_claims ~ peak_stringency_std:post | state_f + month_f,
  data = bh_only,
  cluster = ~state_f
)
summary(m_bh_did_claims)

cat("\n--- HCBS-only DiD: Log Providers ---\n")
m_hcbs_did_prov <- feols(
  log_providers ~ peak_stringency_std:post | state_f + month_f,
  data = hcbs_only,
  cluster = ~state_f
)
summary(m_hcbs_did_prov)

cat("\n--- BH-only DiD: Log Providers ---\n")
m_bh_did_prov <- feols(
  log_providers ~ peak_stringency_std:post | state_f + month_f,
  data = bh_only,
  cluster = ~state_f
)
summary(m_bh_did_prov)

## ---- 6. All-HCBS robustness (original T-code classification) ----
cat("\n=== All-HCBS Robustness (Original Classification) ===\n")

panel_all[, `:=`(
  state_f = factor(state),
  service_f = factor(service_type),
  month_f = factor(month_date)
)]

m_all_paid <- feols(
  log_paid ~ peak_stringency_std:is_hcbs:post |
    state_f^service_f + service_f^month_f + state_f^month_f,
  data = panel_all,
  cluster = ~state_f
)
cat("All T-codes DDD (log paid) — for robustness:\n")
summary(m_all_paid)

m_all_claims <- feols(
  log_claims ~ peak_stringency_std:is_hcbs:post |
    state_f^service_f + service_f^month_f + state_f^month_f,
  data = panel_all,
  cluster = ~state_f
)
cat("All T-codes DDD (log claims) — for robustness:\n")
summary(m_all_claims)

## ---- 7. T1019-only specification (single-code robustness) ----
cat("\n=== T1019-Only Specification ===\n")
# T1019 is the dominant personal care code
# Need to rebuild from HCPCS-level data if available, or use the all panel
# For now, save a flag — this will be done in robustness if HCPCS-level data is saved

## ---- 8. Save results ----
results <- list(
  m1_paid = m1_paid,
  m2_claims = m2_claims,
  m3_providers = m3_providers,
  m4_benef = m4_benef,
  m5_intensive = m5_intensive,
  m6_benef_prov = m6_benef_prov,
  m7_periods = m7_periods,
  m_dynamic = m_dynamic,
  # WS2: Decomposition
  m_hcbs_did = m_hcbs_did,
  m_hcbs_did_claims = m_hcbs_did_claims,
  m_bh_did = m_bh_did,
  m_bh_did_claims = m_bh_did_claims,
  m_hcbs_did_prov = m_hcbs_did_prov,
  m_bh_did_prov = m_bh_did_prov,
  # All-HCBS robustness
  m_all_paid = m_all_paid,
  m_all_claims = m_all_claims
)

saveRDS(results, file.path(DATA, "main_results.rds"))
saveRDS(panel, file.path(DATA, "panel_analysis.rds"))
saveRDS(panel_all, file.path(DATA, "panel_all_analysis.rds"))

cat("\n=== Main analysis complete ===\n")
