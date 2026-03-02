## ============================================================
## 04_robustness.R — Robustness checks and sensitivity
## APEP-0479: Durbin Amendment, Bank Restructuring, and Tellers
## ============================================================

source("00_packages.R")

data_dir <- "../data/"
panel <- readRDS(file.path(data_dir, "analysis_panel.rds"))

cat("Panel loaded:", nrow(panel), "obs\n")

## ---- 1. Placebo Sectors ----
## Non-banking employment should NOT respond to Durbin exposure

cat("\n=== PLACEBO SECTORS ===\n")

# Retail
m_placebo_retail <- feols(
  log(retail_emp + 1) ~ durbin_post |
    county_fips + year,
  data = panel %>% filter(!is.na(retail_emp)),
  cluster = ~state_fips
)

# Manufacturing
m_placebo_mfg <- feols(
  log(mfg_emp + 1) ~ durbin_post |
    county_fips + year,
  data = panel %>% filter(!is.na(mfg_emp)),
  cluster = ~state_fips
)

# Healthcare
m_placebo_health <- feols(
  log(health_emp + 1) ~ durbin_post |
    county_fips + year,
  data = panel %>% filter(!is.na(health_emp)),
  cluster = ~state_fips
)

cat("Placebo: Retail\n")
summary(m_placebo_retail)
cat("\nPlacebo: Manufacturing\n")
summary(m_placebo_mfg)
cat("\nPlacebo: Healthcare\n")
summary(m_placebo_health)


## ---- 2. Alternative Exposure Measures ----

cat("\n=== ALTERNATIVE EXPOSURE MEASURES ===\n")

# Binary (above/below median)
m_binary <- feols(
  log_bank_emp ~ exposure_high:post |
    county_fips + year,
  data = panel,
  cluster = ~state_fips
)

# Terciles
panel <- panel %>%
  mutate(exposure_tercile = ntile(durbin_exposure, 3))

m_tercile <- feols(
  log_bank_emp ~ i(exposure_tercile, post, ref = 1) |
    county_fips + year,
  data = panel,
  cluster = ~state_fips
)

cat("Binary exposure:\n")
summary(m_binary)
cat("\nTercile exposure:\n")
summary(m_tercile)


## ---- 3. Bandwidth Sensitivity ----

cat("\n=== BANDWIDTH SENSITIVITY ===\n")

# Narrow: 2008-2014
m_narrow <- feols(
  log_bank_emp ~ durbin_post |
    county_fips + year,
  data = panel %>% filter(year >= 2008, year <= 2014),
  cluster = ~state_fips
)

# Wide: 2005-2019
m_wide <- feols(
  log_bank_emp ~ durbin_post |
    county_fips + year,
  data = panel,
  cluster = ~state_fips
)

# Medium: 2007-2016
m_medium <- feols(
  log_bank_emp ~ durbin_post |
    county_fips + year,
  data = panel %>% filter(year >= 2007, year <= 2016),
  cluster = ~state_fips
)

cat("Narrow (2008-2014):\n")
summary(m_narrow)
cat("\nMedium (2007-2016):\n")
summary(m_medium)
cat("\nWide (2005-2019):\n")
summary(m_wide)


## ---- 4. County-Level Trends ----

cat("\n=== COUNTY TRENDS ===\n")

# Add county-specific linear trends
panel <- panel %>%
  mutate(county_trend = as.numeric(factor(county_fips)) * year)

m_trends <- feols(
  log_bank_emp ~ durbin_post |
    county_fips[year] + year,
  data = panel,
  cluster = ~state_fips
)

cat("With county-specific linear trends:\n")
summary(m_trends)


## ---- 5. Alternative Clustering ----

cat("\n=== CLUSTERING SENSITIVITY ===\n")

# County clustering
m_county_cluster <- feols(
  log_bank_emp ~ durbin_post |
    county_fips + year,
  data = panel,
  cluster = ~county_fips
)

# State clustering (baseline)
m_state_cluster <- feols(
  log_bank_emp ~ durbin_post |
    county_fips + year,
  data = panel,
  cluster = ~state_fips
)

# Two-way clustering (state × year)
m_twoway <- feols(
  log_bank_emp ~ durbin_post |
    county_fips + year,
  data = panel,
  cluster = ~state_fips + year
)

cat("County clustering:\n")
cat(sprintf("  Coef: %.4f, SE: %.4f\n",
            coef(m_county_cluster)["durbin_post"],
            se(m_county_cluster)["durbin_post"]))
cat("State clustering (baseline):\n")
cat(sprintf("  Coef: %.4f, SE: %.4f\n",
            coef(m_state_cluster)["durbin_post"],
            se(m_state_cluster)["durbin_post"]))
cat("Two-way (state × year):\n")
cat(sprintf("  Coef: %.4f, SE: %.4f\n",
            coef(m_twoway)["durbin_post"],
            se(m_twoway)["durbin_post"]))


## ---- 6. Excluding Crisis Counties ----

cat("\n=== EXCLUDING CRISIS COUNTIES ===\n")

# FDIC bank failures were concentrated in certain states/counties
# Exclude counties in top decile of bank failure rate 2008-2010
# Use the change in number of unique banks as proxy
crisis_counties <- panel %>%
  filter(year %in% c(2007, 2010)) %>%
  select(county_fips, year, n_banks_unique) %>%
  pivot_wider(names_from = year, values_from = n_banks_unique,
              names_prefix = "banks_") %>%
  mutate(bank_loss_rate = (banks_2007 - banks_2010) / banks_2007) %>%
  filter(!is.na(bank_loss_rate)) %>%
  filter(bank_loss_rate > quantile(bank_loss_rate, 0.9, na.rm = TRUE)) %>%
  pull(county_fips)

m_no_crisis <- feols(
  log_bank_emp ~ durbin_post |
    county_fips + year,
  data = panel %>% filter(!county_fips %in% crisis_counties),
  cluster = ~state_fips
)

cat(sprintf("Dropped %d crisis counties\n", length(crisis_counties)))
cat("Without crisis counties:\n")
summary(m_no_crisis)


## ---- 7. Leave-One-State-Out ----

cat("\n=== LEAVE-ONE-STATE-OUT ===\n")

states <- unique(panel$state_fips)
loso_coefs <- numeric(length(states))
names(loso_coefs) <- states

for (i in seq_along(states)) {
  m_loso <- feols(
    log_bank_emp ~ durbin_post |
      county_fips + year,
    data = panel %>% filter(state_fips != states[i]),
    cluster = ~state_fips
  )
  loso_coefs[i] <- coef(m_loso)["durbin_post"]
}

cat(sprintf("LOSO coefficient range: [%.4f, %.4f]\n",
            min(loso_coefs), max(loso_coefs)))
cat(sprintf("LOSO mean: %.4f, SD: %.4f\n",
            mean(loso_coefs), sd(loso_coefs)))

# Save LOSO for figure
saveRDS(loso_coefs, file.path(data_dir, "loso_coefficients.rds"))


## ---- 8. Bunching Test ----
## Do banks manipulate assets to stay below $10B?

cat("\n=== BUNCHING TEST ===\n")

bank_size <- readRDS(file.path(data_dir, "bank_size_panel.rds"))

bunching_data <- bank_size %>%
  filter(year %in% c(2009, 2010, 2011, 2012)) %>%
  filter(asset_billions >= 5, asset_billions <= 20)

cat("Banks near $10B threshold by year:\n")
bunching_data %>%
  mutate(bin = cut(asset_billions,
                   breaks = c(5, 8, 9, 9.5, 10, 10.5, 11, 12, 15, 20))) %>%
  count(year, bin) %>%
  pivot_wider(names_from = year, values_from = n) %>%
  print()


## ---- 9. HonestDiD Sensitivity ----

cat("\n=== HonestDiD SENSITIVITY ===\n")

tryCatch({
  # Run event study for HonestDiD
  m_honest <- feols(
    log_bank_emp ~ i(year, durbin_exposure, ref = 2010) |
      county_fips + year,
    data = panel,
    cluster = ~state_fips
  )

  # Extract coefficients and variance-covariance matrix
  beta_hat <- coef(m_honest)
  sigma_hat <- vcov(m_honest)

  # Identify pre and post periods
  coef_names <- names(beta_hat)
  pre_idx  <- grep("200[5-9]", coef_names)
  post_idx <- grep("201[2-9]", coef_names)

  if (length(pre_idx) > 0 && length(post_idx) > 0) {
    honest_result <- HonestDiD::createSensitivityResults(
      betahat = beta_hat,
      sigma   = sigma_hat,
      numPrePeriods  = length(pre_idx),
      numPostPeriods = length(post_idx),
      Mvec = seq(0, 0.5, by = 0.1)
    )
    cat("HonestDiD sensitivity results:\n")
    print(honest_result)
    saveRDS(honest_result, file.path(data_dir, "honest_did.rds"))
  } else {
    cat("Could not identify pre/post periods for HonestDiD\n")
  }
}, error = function(e) {
  cat(sprintf("HonestDiD error: %s\n", e$message))
})


## ---- 10. Save All Robustness Results ----

robustness <- list(
  placebo_retail = m_placebo_retail,
  placebo_mfg = m_placebo_mfg,
  placebo_health = m_placebo_health,
  binary = m_binary,
  tercile = m_tercile,
  narrow = m_narrow,
  medium = m_medium,
  wide = m_wide,
  trends = m_trends,
  no_crisis = m_no_crisis,
  loso_coefs = loso_coefs
)

saveRDS(robustness, file.path(data_dir, "robustness_results.rds"))
cat("\n=== All robustness results saved ===\n")
