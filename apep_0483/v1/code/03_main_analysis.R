###############################################################################
# 03_main_analysis.R — Primary DR-AIPW estimation
# apep_0483: Teacher Pay Austerity and Student Achievement in England
###############################################################################

source("00_packages.R")

data_dir <- "../data/"
panel <- fread(paste0(data_dir, "analysis_panel.csv"))

###############################################################################
# 1. Analysis sample — post-COVID, post-austerity
###############################################################################

cat("=== MAIN ANALYSIS ===\n")

# Use post-COVID exam years (2021/22 onwards) for outcomes
# Treatment is the 2010-2019 competitiveness change (predetermined)
analysis <- panel[year >= 2021 & !is.na(att8) & !is.na(treated)]

# Collapse to LA-level averages (average across post-austerity years)
la_avg <- analysis[, .(
  att8_mean = mean(att8, na.rm = TRUE),
  att8_sd = sd(att8, na.rm = TRUE),
  fsm_gap_mean = mean(fsm_gap, na.rm = TRUE),
  basics_94_mean = mean(basics_94, na.rm = TRUE),
  n_years = .N,
  mean_comp = mean(comp_ratio, na.rm = TRUE)
), by = .(la_code, la_name, treated, comp_change, comp_pct_change,
          base_pay, base_comp, urban_proxy, region)]

la_avg <- la_avg[!is.na(treated)]

cat(sprintf("Analysis sample: %d LAs (%d treated, %d control)\n",
            nrow(la_avg), sum(la_avg$treated == 1), sum(la_avg$treated == 0)))

###############################################################################
# 2. Balance diagnostics (pre-treatment)
###############################################################################

cat("\n--- Balance diagnostics (baseline 2010 characteristics) ---\n")

# Standardized mean differences
balance_vars <- c("base_pay", "base_comp")
for (v in balance_vars) {
  mu_t <- mean(la_avg[treated == 1][[v]], na.rm = TRUE)
  mu_c <- mean(la_avg[treated == 0][[v]], na.rm = TRUE)
  sd_pool <- sqrt((var(la_avg[treated == 1][[v]], na.rm = TRUE) +
                   var(la_avg[treated == 0][[v]], na.rm = TRUE)) / 2)
  smd <- (mu_t - mu_c) / sd_pool
  cat(sprintf("  %s: Treated=%.0f, Control=%.0f, SMD=%.3f\n",
              v, mu_t, mu_c, smd))
}

# Region distribution
cat("\nRegion distribution:\n")
print(la_avg[, .N, by = .(treated, region)][order(treated, region)])

###############################################################################
# 3. Naive OLS (benchmark)
###############################################################################

cat("\n--- OLS estimates ---\n")

# Model 1: Bivariate
m1_ols <- feols(att8_mean ~ treated, data = la_avg, se = "hetero")

# Model 2: Add baseline covariates
m2_ols <- feols(att8_mean ~ treated + base_pay + urban_proxy,
                data = la_avg, se = "hetero")

# Model 3: Region fixed effects
m3_ols <- feols(att8_mean ~ treated + base_pay | region,
                data = la_avg)

cat("OLS Results:\n")
ct1 <- coeftable(m1_ols)
ct2 <- coeftable(m2_ols)
ct3 <- coeftable(m3_ols)
cat(sprintf("  M1 (bivariate): coef=%.2f, se=%.2f, p=%.3f\n",
            ct1["treated", "Estimate"],
            ct1["treated", "Std. Error"],
            ct1["treated", "Pr(>|t|)"]))
cat(sprintf("  M2 (+covariates): coef=%.2f, se=%.2f, p=%.3f\n",
            ct2["treated", "Estimate"],
            ct2["treated", "Std. Error"],
            ct2["treated", "Pr(>|t|)"]))
cat(sprintf("  M3 (+region FE): coef=%.2f, se=%.2f, p=%.3f\n",
            ct3["treated", "Estimate"],
            ct3["treated", "Std. Error"],
            ct3["treated", "Pr(>|t|)"]))

###############################################################################
# 4. DR-AIPW estimation
###############################################################################

cat("\n--- DR-AIPW estimation ---\n")

# Prepare data for AIPW
aipw_data <- la_avg[complete.cases(la_avg[, .(att8_mean, treated,
                                               base_pay, base_comp)])]

cat(sprintf("  AIPW sample: %d LAs\n", nrow(aipw_data)))

# Propensity score: logistic regression
ps_model <- glm(treated ~ base_pay + I(base_pay^2) + urban_proxy,
                data = aipw_data, family = binomial(link = "logit"))

aipw_data[, ps_hat := predict(ps_model, type = "response")]

cat(sprintf("  Propensity score range: [%.3f, %.3f]\n",
            min(aipw_data$ps_hat), max(aipw_data$ps_hat)))

# Trim extreme propensity scores
trim_lo <- 0.05
trim_hi <- 0.95
aipw_trimmed <- aipw_data[ps_hat >= trim_lo & ps_hat <= trim_hi]
n_trimmed <- nrow(aipw_data) - nrow(aipw_trimmed)
cat(sprintf("  Trimmed: %d LAs (%.1f%%)\n",
            n_trimmed, 100 * n_trimmed / nrow(aipw_data)))

# Outcome models (separate for treated and control)
mu1_model <- lm(att8_mean ~ base_pay + I(base_pay^2) + urban_proxy,
                data = aipw_trimmed[treated == 1])
mu0_model <- lm(att8_mean ~ base_pay + I(base_pay^2) + urban_proxy,
                data = aipw_trimmed[treated == 0])

# Predicted outcomes for all units
aipw_trimmed[, mu1_hat := predict(mu1_model, newdata = aipw_trimmed)]
aipw_trimmed[, mu0_hat := predict(mu0_model, newdata = aipw_trimmed)]

# AIPW estimator (Robins, Rotnitzky, Zhao 1994)
# tau_AIPW = 1/N sum[ (D*Y - (D-ps)*mu1) / ps - ((1-D)*Y + (D-ps)*mu0) / (1-ps) ]

D <- aipw_trimmed$treated
Y <- aipw_trimmed$att8_mean
ps <- aipw_trimmed$ps_hat
mu1 <- aipw_trimmed$mu1_hat
mu0 <- aipw_trimmed$mu0_hat

# Influence function for each observation
phi1 <- (D * Y - (D - ps) * mu1) / ps
phi0 <- ((1 - D) * Y + (D - ps) * mu0) / (1 - ps)
phi <- phi1 - phi0

tau_aipw <- mean(phi)
se_aipw <- sd(phi) / sqrt(length(phi))
ci_lo <- tau_aipw - 1.96 * se_aipw
ci_hi <- tau_aipw + 1.96 * se_aipw
p_aipw <- 2 * pnorm(-abs(tau_aipw / se_aipw))

cat(sprintf("\n  AIPW ATE: %.2f (SE=%.2f, p=%.3f)\n", tau_aipw, se_aipw, p_aipw))
cat(sprintf("  95%% CI: [%.2f, %.2f]\n", ci_lo, ci_hi))

###############################################################################
# 5. AIPW with ML nuisance (Random Forest)
###############################################################################

cat("\n--- DR-AIPW with Random Forest nuisance models ---\n")

# Random forest propensity score
set.seed(42)
rf_ps <- ranger(factor(treated) ~ base_pay + base_comp + urban_proxy,
                data = aipw_data, probability = TRUE, num.trees = 500)
aipw_data[, ps_rf := predict(rf_ps, data = aipw_data)$predictions[, "1"]]

cat(sprintf("  RF propensity score range: [%.3f, %.3f]\n",
            min(aipw_data$ps_rf), max(aipw_data$ps_rf)))

# Random forest outcome models
rf_mu1 <- ranger(att8_mean ~ base_pay + base_comp + urban_proxy,
                 data = aipw_data[treated == 1], num.trees = 500)
rf_mu0 <- ranger(att8_mean ~ base_pay + base_comp + urban_proxy,
                 data = aipw_data[treated == 0], num.trees = 500)

aipw_data[, mu1_rf := predict(rf_mu1, data = aipw_data)$predictions]
aipw_data[, mu0_rf := predict(rf_mu0, data = aipw_data)$predictions]

# Trim
aipw_rf_trim <- aipw_data[ps_rf >= trim_lo & ps_rf <= trim_hi]

D_rf <- aipw_rf_trim$treated
Y_rf <- aipw_rf_trim$att8_mean
ps_rf <- aipw_rf_trim$ps_rf
mu1_rf <- aipw_rf_trim$mu1_rf
mu0_rf <- aipw_rf_trim$mu0_rf

phi1_rf <- (D_rf * Y_rf - (D_rf - ps_rf) * mu1_rf) / ps_rf
phi0_rf <- ((1 - D_rf) * Y_rf + (D_rf - ps_rf) * mu0_rf) / (1 - ps_rf)
phi_rf <- phi1_rf - phi0_rf

tau_rf <- mean(phi_rf)
se_rf <- sd(phi_rf) / sqrt(length(phi_rf))
p_rf <- 2 * pnorm(-abs(tau_rf / se_rf))

cat(sprintf("  RF-AIPW ATE: %.2f (SE=%.2f, p=%.3f)\n", tau_rf, se_rf, p_rf))
cat(sprintf("  95%% CI: [%.2f, %.2f]\n",
            tau_rf - 1.96 * se_rf, tau_rf + 1.96 * se_rf))

###############################################################################
# 5b. Cross-fitted AIPW (DML-style, Chernozhukov et al. 2018)
###############################################################################

cat("\n--- Cross-fitted DR-AIPW (5-fold) ---\n")

set.seed(123)
K <- 5
n <- nrow(aipw_data)
folds <- sample(rep(1:K, length.out = n))

phi_cf <- numeric(n)
for (k in 1:K) {
  train_idx <- which(folds != k)
  test_idx <- which(folds == k)
  train <- aipw_data[train_idx]
  test <- aipw_data[test_idx]

  # Propensity score on training fold
  rf_ps_k <- ranger(factor(treated) ~ base_pay + base_comp + urban_proxy,
                     data = train, probability = TRUE, num.trees = 500)
  ps_k <- predict(rf_ps_k, data = test)$predictions[, "1"]
  ps_k <- pmax(pmin(ps_k, 0.95), 0.05)  # clip

  # Outcome models on training fold
  rf_mu1_k <- ranger(att8_mean ~ base_pay + base_comp + urban_proxy,
                      data = train[treated == 1], num.trees = 500)
  rf_mu0_k <- ranger(att8_mean ~ base_pay + base_comp + urban_proxy,
                      data = train[treated == 0], num.trees = 500)
  mu1_k <- predict(rf_mu1_k, data = test)$predictions
  mu0_k <- predict(rf_mu0_k, data = test)$predictions

  D_k <- test$treated
  Y_k <- test$att8_mean
  phi1_k <- (D_k * Y_k - (D_k - ps_k) * mu1_k) / ps_k
  phi0_k <- ((1 - D_k) * Y_k + (D_k - ps_k) * mu0_k) / (1 - ps_k)
  phi_cf[test_idx] <- phi1_k - phi0_k
}

tau_cf <- mean(phi_cf)
se_cf <- sd(phi_cf) / sqrt(n)
p_cf <- 2 * pnorm(-abs(tau_cf / se_cf))

cat(sprintf("  Cross-fitted AIPW ATE: %.2f (SE=%.2f, p=%.3f)\n", tau_cf, se_cf, p_cf))
cat(sprintf("  95%% CI: [%.2f, %.2f]\n",
            tau_cf - 1.96 * se_cf, tau_cf + 1.96 * se_cf))

###############################################################################
# 6. Continuous treatment (dose-response)
###############################################################################

cat("\n--- Continuous treatment (dose-response OLS) ---\n")

# Competitiveness change as continuous treatment
m_cont <- feols(att8_mean ~ comp_change + base_pay + urban_proxy,
                data = la_avg[!is.na(comp_change)], se = "hetero")

ct_cont <- coeftable(m_cont)
cat(sprintf("  Continuous: coef=%.2f per unit comp_change (SE=%.2f, p=%.3f)\n",
            ct_cont["comp_change", "Estimate"],
            ct_cont["comp_change", "Std. Error"],
            ct_cont["comp_change", "Pr(>|t|)"]))

# Percent change version
m_pct <- feols(att8_mean ~ comp_pct_change + base_pay + urban_proxy,
               data = la_avg[!is.na(comp_pct_change)], se = "hetero")

ct_pct <- coeftable(m_pct)
cat(sprintf("  Pct change: coef=%.3f per 1pp comp decline (SE=%.3f, p=%.3f)\n",
            ct_pct["comp_pct_change", "Estimate"],
            ct_pct["comp_pct_change", "Std. Error"],
            ct_pct["comp_pct_change", "Pr(>|t|)"]))

###############################################################################
# 7. Panel regression (LA × year)
###############################################################################

cat("\n--- Panel regression (LA × year, post-COVID sample) ---\n")

panel_post <- panel[year >= 2021 & !is.na(att8) & !is.na(treated)]

# TWFE
m_twfe <- feols(att8 ~ comp_ratio | la_id + year,
                data = panel_post, cluster = ~la_code)

ct_twfe <- coeftable(m_twfe)
cat(sprintf("  TWFE (comp_ratio): coef=%.2f (SE=%.2f, p=%.3f)\n",
            ct_twfe["comp_ratio", "Estimate"],
            ct_twfe["comp_ratio", "Std. Error"],
            ct_twfe["comp_ratio", "Pr(>|t|)"]))

# TWFE with treatment × post interaction
m_twfe2 <- feols(att8 ~ treated:factor(year) | la_id + year,
                 data = panel_post, cluster = ~la_code)

cat("\n  Treatment × year coefficients:\n")
print(summary(m_twfe2)$coeftable)

###############################################################################
# 8. FSM gap (equity) analysis
###############################################################################

cat("\n--- FSM achievement gap analysis ---\n")

la_gap <- analysis[!is.na(fsm_gap), .(
  fsm_gap_mean = mean(fsm_gap, na.rm = TRUE)
), by = .(la_code, treated, base_pay, urban_proxy)]

la_gap <- la_gap[!is.na(treated)]

m_gap <- feols(fsm_gap_mean ~ treated + base_pay + urban_proxy,
               data = la_gap, se = "hetero")

ct_gap <- coeftable(m_gap)
cat(sprintf("  FSM gap effect: coef=%.2f (SE=%.2f, p=%.3f)\n",
            ct_gap["treated", "Estimate"],
            ct_gap["treated", "Std. Error"],
            ct_gap["treated", "Pr(>|t|)"]))
cat("  (Positive = wider gap in treated LAs)\n")

###############################################################################
# 9. Save results
###############################################################################

results <- list(
  ols_bivariate = m1_ols,
  ols_covariates = m2_ols,
  ols_region_fe = m3_ols,
  aipw_ate = tau_aipw,
  aipw_se = se_aipw,
  aipw_p = p_aipw,
  aipw_rf_ate = tau_rf,
  aipw_rf_se = se_rf,
  aipw_rf_p = p_rf,
  aipw_cf_ate = tau_cf,
  aipw_cf_se = se_cf,
  aipw_cf_p = p_cf,
  continuous = m_cont,
  panel_twfe = m_twfe,
  fsm_gap = m_gap
)

saveRDS(results, paste0(data_dir, "main_results.rds"))
fwrite(la_avg, paste0(data_dir, "la_analysis_sample.csv"))
fwrite(aipw_data, paste0(data_dir, "aipw_sample.csv"))

cat("\n=== MAIN ANALYSIS COMPLETE ===\n")
cat(sprintf("Key result — AIPW ATE: %.2f Attainment 8 points (p=%.3f)\n",
            tau_aipw, p_aipw))
cat(sprintf("Key result — RF-AIPW ATE: %.2f Attainment 8 points (p=%.3f)\n",
            tau_rf, p_rf))
