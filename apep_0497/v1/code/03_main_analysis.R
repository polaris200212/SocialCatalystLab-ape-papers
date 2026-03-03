## =============================================================================
## 03_main_analysis.R — Primary regressions
## apep_0497: Who Captures a Tax Cut?
## =============================================================================

source("00_packages.R")

cat("=== MAIN ANALYSIS ===\n\n")

panel <- fread(file.path(data_dir, "analysis_panel.csv"))
panel[, code_commune := str_pad(as.character(code_commune), 5, pad = "0")]
panel[, code_dept := substr(code_commune, 1, 2)]

## =============================================================================
## Table 1: Summary Statistics
## =============================================================================

cat("--- Summary Statistics ---\n")

## Pre vs post comparison
sum_stats <- panel[!is.na(th_dose), .(
  `Median price (€)` = mean(median_price, na.rm = TRUE),
  `Price/m² apt (€)` = mean(price_m2_apt, na.rm = TRUE),
  `Transactions/commune` = mean(n_transactions, na.rm = TRUE),
  `Mean TH rate (%)` = mean(th_rate_2017, na.rm = TRUE),
  `Share apartments` = mean(share_apartments, na.rm = TRUE),
  `N commune-years` = .N,
  `N communes` = uniqueN(code_commune)
), by = .(Period = fifelse(year < 2018, "Pre-reform (2014-2017)", "Post-reform (2018-2024)"))]

print(sum_stats)

## Summary stats by TH dose tercile
panel[!is.na(th_dose), th_tercile_lab := cut(th_dose,
  breaks = quantile(th_dose, c(0, 1/3, 2/3, 1), na.rm = TRUE),
  labels = c("Low TH", "Medium TH", "High TH"),
  include.lowest = TRUE)]

sum_by_tercile <- panel[!is.na(th_tercile_lab) & year == 2017, .(
  `Mean TH rate (%)` = mean(th_rate_2017, na.rm = TRUE),
  `Median price (€)` = mean(median_price, na.rm = TRUE),
  `Transactions` = mean(n_transactions, na.rm = TRUE),
  `N communes` = uniqueN(code_commune)
), by = .(th_tercile_lab)]

print(sum_by_tercile)

## Save summary stats
saveRDS(list(overall = sum_stats, by_tercile = sum_by_tercile),
        file.path(data_dir, "summary_stats.rds"))

## =============================================================================
## Main Specification: Continuous DiD
## =============================================================================

cat("\n--- Main Specification: Continuous DiD ---\n")

## Primary outcome: log median price
## Model 1: Basic continuous DiD
## log(price) = β × TH_dose_std × Post + commune FE + year FE
m1 <- feols(log_price ~ th_dose_std:post |
              code_commune + year,
            data = panel[!is.na(th_dose_std) & !is.na(log_price)],
            cluster = ~code_dept)

cat("Model 1 (basic):\n")
print(summary(m1))

## Model 2: With composition controls
m2 <- feols(log_price ~ th_dose_std:post + share_apartments |
              code_commune + year,
            data = panel[!is.na(th_dose_std) & !is.na(log_price)],
            cluster = ~code_dept)

cat("\nModel 2 (controls):\n")
print(summary(m2))

## Model 3: With département × year FE (absorb regional trends)
m3 <- feols(log_price ~ th_dose_std:post + share_apartments |
              code_commune + code_dept^year,
            data = panel[!is.na(th_dose_std) & !is.na(log_price)],
            cluster = ~code_dept)

cat("\nModel 3 (dept×year FE):\n")
print(summary(m3))

## Model 4: Apartment price per m2 (intensive margin)
m4 <- feols(log_price_m2 ~ th_dose_std:post |
              code_commune + year,
            data = panel[!is.na(th_dose_std) & !is.na(log_price_m2)],
            cluster = ~code_dept)

cat("\nModel 4 (price/m² apartments):\n")
print(summary(m4))

## Model 5: Apartment price per m2 with département × year FE
m5 <- feols(log_price_m2 ~ th_dose_std:post |
              code_commune + code_dept^year,
            data = panel[!is.na(th_dose_std) & !is.na(log_price_m2)],
            cluster = ~code_dept)

cat("\nModel 5 (apartments, dept×year FE):\n")
print(summary(m5))

## =============================================================================
## Event Study: Dynamic Treatment Effects
## =============================================================================

cat("\n--- Event Study ---\n")

## Create relative time to reform (base: 2017)
panel[, rel_year := year - 2018]

## Event study with year-by-year TH dose interaction
## Omit 2017 (rel_year = -1) as reference
es_model <- feols(log_price ~ i(rel_year, th_dose_std, ref = -1) +
                    share_apartments |
                    code_commune + year,
                  data = panel[!is.na(th_dose_std) & !is.na(log_price)],
                  cluster = ~code_dept)

cat("Event study coefficients:\n")
print(coeftable(es_model))

saveRDS(es_model, file.path(data_dir, "event_study_model.rds"))

## Apartment-specific event study
es_apt <- feols(log_price_m2 ~ i(rel_year, th_dose_std, ref = -1) |
                  code_commune + year,
                data = panel[!is.na(th_dose_std) & !is.na(log_price_m2)],
                cluster = ~code_dept)

cat("Apartment event study coefficients:\n")
print(coeftable(es_apt))

## Joint pre-trend test for apartment event study
apt_pre_coefs <- grep("rel_year::-[2-4]", names(coef(es_apt)), value = TRUE)
if (length(apt_pre_coefs) >= 2) {
  apt_pre_test <- wald(es_apt, keep = apt_pre_coefs)
  cat("\nApartment pre-trends joint F-test p-value:", apt_pre_test$p, "\n")
}

saveRDS(es_apt, file.path(data_dir, "event_study_apt_model.rds"))

## =============================================================================
## Two-Group DiD: High-Dose vs Low-Dose Communes
## =============================================================================

cat("\n--- Two-Group DiD: High-Dose vs Low-Dose ---\n")

## Construct binary treatment groups from pre-reform TH rate
## High-dose = above-median TH communes; Low-dose = bottom-quartile TH communes
panel[!is.na(th_rate_2017), high_th := as.integer(
  th_rate_2017 > median(th_rate_2017, na.rm = TRUE))]

## High-dose = above-median TH rate (2018); Low-dose comparison = bottom quartile (coded 0)
## Note: both groups are treated; we estimate RELATIVE effects of higher dose
q25_th <- quantile(panel$th_rate_2017, 0.25, na.rm = TRUE)
panel[, cs_group := fifelse(th_rate_2017 > median(th_rate_2017, na.rm = TRUE), 2018L,
                             fifelse(th_rate_2017 <= q25_th, 0L, NA_integer_))]

cs_data <- panel[!is.na(cs_group) & !is.na(log_price)]
cs_data[, id := as.integer(factor(code_commune))]

## Standard two-group event study (high-dose vs low-dose)
## This uses a simple HighDose_c × Year_t interaction design
## NOT the Callaway-Sant'Anna framework (which requires untreated units)
twogroup_data <- panel[!is.na(cs_group) & cs_group %in% c(0L, 2018L) & !is.na(log_price)]
twogroup_data[, high_dose := as.integer(cs_group == 2018L)]

m_twogroup <- feols(log_price ~ i(year, high_dose, ref = 2017) |
                      code_commune + year,
                    data = twogroup_data,
                    cluster = ~code_dept)

cat("Two-group event study (high-dose vs low-dose):\n")
print(coeftable(m_twogroup))

## Overall post-reform average
twogroup_data[, post := as.integer(year >= 2018)]
m_twogroup_avg <- feols(log_price ~ high_dose:post |
                          code_commune + year,
                        data = twogroup_data,
                        cluster = ~code_dept)

cat("\nTwo-group average post effect:\n")
print(coeftable(m_twogroup_avg))

## Pre-trends test (joint F-test of pre-reform coefficients)
pre_coefs <- grep("2014|2015|2016", names(coef(m_twogroup)), value = TRUE)
if (length(pre_coefs) >= 2) {
  pre_test <- wald(m_twogroup, keep = pre_coefs)
  cat("\nPre-trends joint F-test p-value:", pre_test$p, "\n")
}

saveRDS(list(es = m_twogroup, avg = m_twogroup_avg),
        file.path(data_dir, "twogroup_did_results.rds"))

## =============================================================================
## Transaction Volume Effects
## =============================================================================

cat("\n--- Transaction Volume Effects ---\n")

m_vol <- feols(log_transactions ~ th_dose_std:post |
                 code_commune + year,
               data = panel[!is.na(th_dose_std) & !is.na(log_transactions)],
               cluster = ~code_dept)

cat("Volume effect:\n")
print(summary(m_vol))

## =============================================================================
## Save All Main Results
## =============================================================================

results <- list(
  m1 = m1, m2 = m2, m3 = m3, m4 = m4, m5 = m5,
  es = es_model,
  es_apt = es_apt,
  vol = m_vol
)

saveRDS(results, file.path(data_dir, "main_results.rds"))

cat("\n=== MAIN ANALYSIS COMPLETE ===\n")
cat("Results saved to data/main_results.rds\n")
