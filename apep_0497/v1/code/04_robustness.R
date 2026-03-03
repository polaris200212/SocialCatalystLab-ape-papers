## =============================================================================
## 04_robustness.R — Robustness checks and mechanism tests
## apep_0497: Who Captures a Tax Cut?
## =============================================================================

source("00_packages.R")

cat("=== ROBUSTNESS CHECKS ===\n\n")

panel <- fread(file.path(data_dir, "analysis_panel.csv"))
panel[, code_commune := str_pad(as.character(code_commune), 5, pad = "0")]
panel[, code_dept := substr(code_commune, 1, 2)]
panel[, rel_year := year - 2018]

## =============================================================================
## 1. Anticipation Test
## =============================================================================

cat("--- Anticipation Test (2017 effect) ---\n")

## Check if prices started rising in 2017 (reform announced Sept 2017)
panel[, announced := as.integer(year >= 2017)]
m_antic <- feols(log_price ~ th_dose_std:announced |
                   code_commune + year,
                 data = panel[!is.na(th_dose_std) & !is.na(log_price) & year <= 2018],
                 cluster = ~code_dept)

cat("Anticipation (2017 announcement effect):\n")
print(coeftable(m_antic))

## =============================================================================
## 2. HonestDiD Sensitivity
## =============================================================================

cat("\n--- HonestDiD Sensitivity ---\n")

es_model <- readRDS(file.path(data_dir, "event_study_model.rds"))

tryCatch({
  ## Extract pre-trend coefficients for HonestDiD
  es_coefs <- coef(es_model)
  es_vcov <- vcov(es_model)

  ## Pre-treatment coefficients (rel_year < 0)
  pre_idx <- grep("rel_year::-[2-9]", names(es_coefs))
  post_idx <- grep("rel_year::[0-9]", names(es_coefs))

  if (length(pre_idx) >= 2 & length(post_idx) >= 1) {
    beta_hat <- es_coefs[c(pre_idx, post_idx)]
    sigma_hat <- es_vcov[c(pre_idx, post_idx), c(pre_idx, post_idx)]

    honest_result <- HonestDiD::createSensitivityResults_relativeMagnitudes(
      betahat = beta_hat,
      sigma = sigma_hat,
      numPrePeriods = length(pre_idx),
      numPostPeriods = length(post_idx),
      Mbarvec = seq(0, 2, by = 0.5)
    )

    cat("HonestDiD relative magnitudes results:\n")
    print(honest_result)

    saveRDS(honest_result, file.path(data_dir, "honest_did_results.rds"))
  } else {
    cat("  Not enough pre/post coefficients for HonestDiD.\n")
  }
}, error = function(e) {
  cat("  HonestDiD failed:", e$message, "\n")
  cat("  Proceeding without sensitivity bounds.\n")
})

## =============================================================================
## 2b. HonestDiD Sensitivity — Apartments
## =============================================================================

cat("\n--- HonestDiD Sensitivity (Apartments) ---\n")

es_apt_model <- readRDS(file.path(data_dir, "event_study_apt_model.rds"))

tryCatch({
  apt_coefs <- coef(es_apt_model)
  apt_vcov <- vcov(es_apt_model)

  apt_pre_idx <- grep("rel_year::-[2-9]", names(apt_coefs))
  apt_post_idx <- grep("rel_year::[0-9]", names(apt_coefs))

  if (length(apt_pre_idx) >= 2 & length(apt_post_idx) >= 1) {
    beta_apt <- apt_coefs[c(apt_pre_idx, apt_post_idx)]
    sigma_apt <- apt_vcov[c(apt_pre_idx, apt_post_idx), c(apt_pre_idx, apt_post_idx)]

    honest_apt <- HonestDiD::createSensitivityResults_relativeMagnitudes(
      betahat = beta_apt,
      sigma = sigma_apt,
      numPrePeriods = length(apt_pre_idx),
      numPostPeriods = length(apt_post_idx),
      Mbarvec = seq(0, 2, by = 0.5)
    )

    cat("HonestDiD apartment relative magnitudes:\n")
    print(honest_apt)

    saveRDS(honest_apt, file.path(data_dir, "honest_did_apt_results.rds"))
  }
}, error = function(e) {
  cat("  HonestDiD (apartments) failed:", e$message, "\n")
})

## =============================================================================
## 2c. CdD Period Only (2014-2020) — Apartment Robustness
## =============================================================================

cat("\n--- CdD Period Only (2014-2020) ---\n")

m_cdd_apt <- feols(log_price_m2 ~ th_dose_std:post |
                     code_commune + year,
                   data = panel[!is.na(th_dose_std) & !is.na(log_price_m2) & year <= 2020],
                   cluster = ~code_dept)

cat("Apartments, CdD period only (2014-2020):\n")
print(coeftable(m_cdd_apt))

## =============================================================================
## 3. Leave-One-Out (Département)
## =============================================================================

cat("\n--- Leave-one-out by département ---\n")

depts <- unique(panel[!is.na(th_dose_std)]$code_dept)
loo_results <- data.table()

for (d in depts) {
  m_loo <- feols(log_price ~ th_dose_std:post |
                   code_commune + year,
                 data = panel[!is.na(th_dose_std) & !is.na(log_price) & code_dept != d],
                 cluster = ~code_dept)

  loo_results <- rbind(loo_results, data.table(
    dept_dropped = d,
    coef = coef(m_loo)[1],
    se = se(m_loo)[1]
  ))
}

cat("LOO range: [", round(min(loo_results$coef), 4), ",",
    round(max(loo_results$coef), 4), "]\n")
cat("LOO mean:", round(mean(loo_results$coef), 4), "\n")

saveRDS(loo_results, file.path(data_dir, "loo_results.rds"))

## =============================================================================
## 4. Alternative Dose Measures
## =============================================================================

cat("\n--- Alternative dose measures ---\n")

## Raw TH rate (not standardized)
m_raw <- feols(log_price ~ th_rate_2017:post |
                 code_commune + year,
               data = panel[!is.na(th_rate_2017) & !is.na(log_price)],
               cluster = ~code_dept)

## TH rate tercile indicators
panel[!is.na(th_rate_2017), th_tercile_num := as.integer(cut(th_rate_2017,
  breaks = quantile(th_rate_2017, c(0, 1/3, 2/3, 1), na.rm = TRUE),
  include.lowest = TRUE))]

m_tercile <- feols(log_price ~ i(th_tercile_num, post, ref = 1) |
                     code_commune + year,
                   data = panel[!is.na(th_tercile_num) & !is.na(log_price)],
                   cluster = ~code_dept)

cat("Raw TH rate:\n")
print(coeftable(m_raw))
cat("\nTH tercile:\n")
print(coeftable(m_tercile))

## =============================================================================
## 5. Supply Elasticity Heterogeneity
## =============================================================================

cat("\n--- Supply elasticity heterogeneity ---\n")

## Proxy: transaction counts (denser = less elastic supply)
panel[!is.na(n_transactions) & n_transactions > 0,
      dense := as.integer(n_transactions > median(n_transactions, na.rm = TRUE))]

## Dense (supply-constrained) vs sparse (elastic)
m_dense <- feols(log_price ~ th_dose_std:post |
                   code_commune + year,
                 data = panel[!is.na(th_dose_std) & !is.na(log_price) & dense == 1],
                 cluster = ~code_dept)

m_sparse <- feols(log_price ~ th_dose_std:post |
                    code_commune + year,
                  data = panel[!is.na(th_dose_std) & !is.na(log_price) & dense == 0],
                  cluster = ~code_dept)

cat("Dense communes (supply-constrained):\n")
print(coeftable(m_dense))
cat("\nSparse communes (supply-elastic):\n")
print(coeftable(m_sparse))

## =============================================================================
## 6. Property Type Heterogeneity (Apartments vs Houses)
## =============================================================================

cat("\n--- Property type heterogeneity ---\n")

## Apartment prices (price per m2)
m_apt <- feols(log_price_m2 ~ th_dose_std:post |
                 code_commune + year,
               data = panel[!is.na(th_dose_std) & !is.na(log_price_m2)],
               cluster = ~code_dept)

## House median prices
panel[median_price_house > 0 & !is.na(median_price_house),
      log_price_house := log(median_price_house)]

m_house <- feols(log_price_house ~ th_dose_std:post |
                   code_commune + year,
                 data = panel[!is.na(th_dose_std) & !is.na(log_price_house)],
                 cluster = ~code_dept)

cat("Apartments (price/m²):\n")
print(coeftable(m_apt))
cat("\nHouses (median price):\n")
print(coeftable(m_house))

## =============================================================================
## 7. Donut Specification (Drop 2018 Transition Year)
## =============================================================================

cat("\n--- Donut: Drop 2018 ---\n")

m_donut <- feols(log_price ~ th_dose_std:post |
                   code_commune + year,
                 data = panel[!is.na(th_dose_std) & !is.na(log_price) & year != 2018],
                 cluster = ~code_dept)

cat("Donut (no 2018):\n")
print(coeftable(m_donut))

## =============================================================================
## 8. Trimmed Sample (Drop Extreme TH Rates)
## =============================================================================

cat("\n--- Trimmed sample ---\n")

p5 <- quantile(panel$th_rate_2017, 0.05, na.rm = TRUE)
p95 <- quantile(panel$th_rate_2017, 0.95, na.rm = TRUE)

m_trim <- feols(log_price ~ th_dose_std:post |
                  code_commune + year,
                data = panel[!is.na(th_dose_std) & !is.na(log_price) &
                               th_rate_2017 >= p5 & th_rate_2017 <= p95],
                cluster = ~code_dept)

cat("Trimmed (5th-95th TH rate):\n")
print(coeftable(m_trim))

## =============================================================================
## Save All Robustness Results
## =============================================================================

rob_results <- list(
  antic = m_antic,
  loo = loo_results,
  raw_dose = m_raw,
  tercile = m_tercile,
  dense = m_dense,
  sparse = m_sparse,
  apt = m_apt,
  house = m_house,
  donut = m_donut,
  trim = m_trim,
  cdd_apt = m_cdd_apt
)

saveRDS(rob_results, file.path(data_dir, "robustness_results.rds"))

cat("\n=== ROBUSTNESS COMPLETE ===\n")
