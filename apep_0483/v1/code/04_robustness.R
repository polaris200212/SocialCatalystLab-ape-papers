###############################################################################
# 04_robustness.R — Robustness and sensitivity analyses
# apep_0483: Teacher Pay Austerity and Student Achievement in England
###############################################################################

source("00_packages.R")

data_dir <- "../data/"
panel <- fread(paste0(data_dir, "analysis_panel.csv"))
la_avg <- fread(paste0(data_dir, "la_analysis_sample.csv"))
aipw_data <- fread(paste0(data_dir, "aipw_sample.csv"))
treat_df <- fread(paste0(data_dir, "treatment_assignment.csv"))

cat("=== ROBUSTNESS CHECKS ===\n\n")

###############################################################################
# 1. Alternative treatment definitions
###############################################################################

cat("--- 1. Alternative treatment definitions ---\n")

# Median split instead of Q25
med_change <- median(treat_df$comp_change, na.rm = TRUE)
treat_df[, treated_median := fifelse(comp_change <= med_change, 1L, 0L)]

la_avg_med <- merge(la_avg[, -"treated", with = FALSE],
                    treat_df[, .(la_code, treated_median)],
                    by = "la_code", all.x = TRUE)

m_med <- feols(att8_mean ~ treated_median + base_pay + urban_proxy,
               data = la_avg_med[!is.na(treated_median)], se = "hetero")

ct_med <- coeftable(m_med)
cat(sprintf("  Median split: coef=%.2f (SE=%.2f, p=%.3f)\n",
            ct_med["treated_median", "Estimate"],
            ct_med["treated_median", "Std. Error"],
            ct_med["treated_median", "Pr(>|t|)"]))

# Top tercile
q33 <- quantile(treat_df$comp_change, 1/3, na.rm = TRUE)
treat_df[, treated_tercile := fifelse(comp_change <= q33, 1L, 0L)]

la_avg_ter <- merge(la_avg[, -"treated", with = FALSE],
                    treat_df[, .(la_code, treated_tercile)],
                    by = "la_code", all.x = TRUE)

m_ter <- feols(att8_mean ~ treated_tercile + base_pay + urban_proxy,
               data = la_avg_ter[!is.na(treated_tercile)], se = "hetero")

ct_ter <- coeftable(m_ter)
cat(sprintf("  Tercile split: coef=%.2f (SE=%.2f, p=%.3f)\n",
            ct_ter["treated_tercile", "Estimate"],
            ct_ter["treated_tercile", "Std. Error"],
            ct_ter["treated_tercile", "Pr(>|t|)"]))

# Extreme comparison: top vs bottom quartile only
q75 <- quantile(treat_df$comp_change, 0.75, na.rm = TRUE)
q25 <- quantile(treat_df$comp_change, 0.25, na.rm = TRUE)

la_avg_extreme <- la_avg[la_code %in% treat_df[comp_change <= q25]$la_code |
                         la_code %in% treat_df[comp_change >= q75]$la_code]
la_avg_extreme[, treated_extreme := fifelse(
  la_code %in% treat_df[comp_change <= q25]$la_code, 1L, 0L)]

m_extreme <- feols(att8_mean ~ treated_extreme + base_pay + urban_proxy,
                   data = la_avg_extreme, se = "hetero")

ct_ext <- coeftable(m_extreme)
cat(sprintf("  Extreme quartiles: coef=%.2f (SE=%.2f, p=%.3f)\n",
            ct_ext["treated_extreme", "Estimate"],
            ct_ext["treated_extreme", "Std. Error"],
            ct_ext["treated_extreme", "Pr(>|t|)"]))

###############################################################################
# 2. Alternative outcome measures
###############################################################################

cat("\n--- 2. Alternative outcome measures ---\n")

# Progress 8 (value-added measure)
if ("prog8" %in% names(la_avg)) {
  la_prog8 <- la_avg[!is.na(prog8)]
  if (nrow(la_prog8) > 10) {
    la_prog8_avg <- la_prog8[, .(prog8_mean = mean(prog8, na.rm = TRUE)),
                             by = .(la_code, treated, base_pay, urban_proxy)]
    m_prog8 <- feols(prog8_mean ~ treated + base_pay + urban_proxy,
                     data = la_prog8_avg[!is.na(treated)], se = "hetero")
    ct_p8 <- coeftable(m_prog8)
    cat(sprintf("  Progress 8: coef=%.3f (SE=%.3f, p=%.3f)\n",
                ct_p8["treated", "Estimate"],
                ct_p8["treated", "Std. Error"],
                ct_p8["treated", "Pr(>|t|)"]))
  }
}

# Basics pass rate (English + Maths at 9-4)
la_basics <- la_avg[!is.na(basics_94_mean)]
if (nrow(la_basics) > 10) {
  m_basics <- feols(basics_94_mean ~ treated + base_pay + urban_proxy,
                    data = la_basics[!is.na(treated)], se = "hetero")
  ct_bas <- coeftable(m_basics)
  cat(sprintf("  Basics 9-4: coef=%.2f (SE=%.2f, p=%.3f)\n",
              ct_bas["treated", "Estimate"],
              ct_bas["treated", "Std. Error"],
              ct_bas["treated", "Pr(>|t|)"]))
}

###############################################################################
# 3. Propensity score sensitivity
###############################################################################

cat("\n--- 3. Propensity score specification ---\n")

# Simpler PS: just base_pay
ps_simple <- glm(treated ~ base_pay, data = aipw_data,
                 family = binomial(link = "logit"))
aipw_data[, ps_simple := predict(ps_simple, type = "response")]

# Richer PS: add region dummies
aipw_data[, region := fcase(
  grepl("^E06", la_code), "Unitary",
  grepl("^E07", la_code), "District",
  grepl("^E08", la_code), "Metropolitan",
  grepl("^E09", la_code), "London Borough",
  default = "Other"
)]

ps_rich <- glm(treated ~ base_pay + I(base_pay^2) + urban_proxy +
                 factor(region),
               data = aipw_data, family = binomial(link = "logit"))
aipw_data[, ps_rich := predict(ps_rich, type = "response")]

# Re-estimate AIPW with simple PS
trim_lo <- 0.05; trim_hi <- 0.95

for (ps_name in c("ps_simple", "ps_rich")) {
  ps_vals <- aipw_data[[ps_name]]
  keep <- ps_vals >= trim_lo & ps_vals <= trim_hi
  dt <- aipw_data[keep]

  mu1_mod <- lm(att8_mean ~ base_pay + I(base_pay^2) + urban_proxy,
                data = dt[treated == 1])
  mu0_mod <- lm(att8_mean ~ base_pay + I(base_pay^2) + urban_proxy,
                data = dt[treated == 0])

  mu1_h <- predict(mu1_mod, newdata = dt)
  mu0_h <- predict(mu0_mod, newdata = dt)

  D <- dt$treated
  Y <- dt$att8_mean
  ps <- dt[[ps_name]]

  phi1 <- (D * Y - (D - ps) * mu1_h) / ps
  phi0 <- ((1 - D) * Y + (D - ps) * mu0_h) / (1 - ps)
  phi <- phi1 - phi0

  tau <- mean(phi)
  se <- sd(phi) / sqrt(length(phi))
  p <- 2 * pnorm(-abs(tau / se))

  cat(sprintf("  AIPW (%s): ATE=%.2f (SE=%.2f, p=%.3f)\n",
              ps_name, tau, se, p))
}

###############################################################################
# 4. Leave-one-region-out (jackknife by region)
###############################################################################

cat("\n--- 4. Leave-one-region-out ---\n")

regions <- unique(la_avg$region)
regions <- regions[!is.na(regions)]

for (r in regions) {
  dt_loo <- la_avg[region != r & !is.na(treated)]
  if (sum(dt_loo$treated == 1) < 5) next

  m_loo <- feols(att8_mean ~ treated + base_pay + urban_proxy,
                 data = dt_loo, se = "hetero")
  ct_loo <- coeftable(m_loo)
  cat(sprintf("  Excl. %s: coef=%.2f (SE=%.2f, p=%.3f, N=%d)\n",
              r, ct_loo["treated", "Estimate"],
              ct_loo["treated", "Std. Error"],
              ct_loo["treated", "Pr(>|t|)"],
              nrow(dt_loo)))
}

###############################################################################
# 5. Placebo treatment: 2005-2010 competitiveness change
###############################################################################

cat("\n--- 5. Placebo: 2005-2010 competitiveness change ---\n")

comp_2005 <- panel[year == 2005, .(la_code, comp_2005 = comp_ratio)]
comp_2010 <- panel[year == 2010, .(la_code, comp_2010 = comp_ratio)]
placebo_df <- merge(comp_2005, comp_2010, by = "la_code")
placebo_df[, placebo_change := comp_2010 - comp_2005]

# Use same quantile approach
q25_placebo <- quantile(placebo_df$placebo_change, 0.25, na.rm = TRUE)
placebo_df[, placebo_treated := fifelse(placebo_change <= q25_placebo, 1L, 0L)]

la_avg_placebo <- merge(la_avg[, .(la_code, att8_mean, base_pay, urban_proxy)],
                        placebo_df[, .(la_code, placebo_treated)],
                        by = "la_code", all.x = TRUE)

m_placebo <- feols(att8_mean ~ placebo_treated + base_pay + urban_proxy,
                   data = la_avg_placebo[!is.na(placebo_treated)], se = "hetero")

ct_plac <- coeftable(m_placebo)
cat(sprintf("  Placebo (2005-2010 change): coef=%.2f (SE=%.2f, p=%.3f)\n",
            ct_plac["placebo_treated", "Estimate"],
            ct_plac["placebo_treated", "Std. Error"],
            ct_plac["placebo_treated", "Pr(>|t|)"]))

###############################################################################
# 6. Oster (2019) delta — coefficient stability
###############################################################################

cat("\n--- 6. Oster (2019) coefficient stability ---\n")

# Estimate with sensemakr for omitted variable bias diagnostics
# Using continuous treatment (comp_change) for sensemakr
sens_data <- la_avg[!is.na(comp_change) & !is.na(att8_mean) &
                    !is.na(base_pay) & !is.na(urban_proxy)]

m_sens <- lm(att8_mean ~ comp_change + base_pay + urban_proxy,
             data = sens_data)

sens_result <- sensemakr(model = m_sens, treatment = "comp_change",
                         benchmark_covariates = "base_pay",
                         kd = 1:3)

cat("  Sensemakr results for comp_change:\n")
cat(sprintf("    RV_q=1 (alpha=0.05): %.3f\n", sens_result$sensitivity_stats$rv_q))
cat(sprintf("    RV_qa=0.05 (alpha=0.05): %.3f\n", sens_result$sensitivity_stats$rv_qa))

# Oster delta (manual approximation)
# R^2 from restricted vs unrestricted
m_short <- lm(att8_mean ~ comp_change, data = sens_data)
m_full <- lm(att8_mean ~ comp_change + base_pay + urban_proxy, data = sens_data)

r2_short <- summary(m_short)$r.squared
r2_full <- summary(m_full)$r.squared
beta_short <- coef(m_short)["comp_change"]
beta_full <- coef(m_full)["comp_change"]

# Oster delta with R_max = 1
r2_max <- min(2.2 * r2_full, 1)  # Oster's rule of thumb: R_max = 2.2 * R_tilde
delta_oster <- (beta_full * (r2_max - r2_full)) /
               ((beta_short - beta_full) * (r2_full - r2_short))

cat(sprintf("    Oster delta (R_max=%.3f): %.3f\n", r2_max, delta_oster))
cat("    (|delta| > 1 suggests result robust to omitted variable bias)\n")

###############################################################################
# 7. E-value (VanderWeele & Ding 2017)
###############################################################################

cat("\n--- 7. E-value ---\n")

# Approximate E-value for the DR-AIPW estimate
# Load main results
main_results <- readRDS(paste0(data_dir, "main_results.rds"))
tau <- main_results$aipw_ate
se <- main_results$aipw_se

# Standardized effect (using outcome SD)
sd_y <- sd(la_avg$att8_mean, na.rm = TRUE)
d <- abs(tau) / sd_y  # Cohen's d equivalent

# E-value for point estimate
RR <- exp(0.91 * d)  # approximate RR from d (VanderWeele 2017)
e_value <- RR + sqrt(RR * (RR - 1))
e_value_ci <- max(1, exp(0.91 * (abs(tau) - 1.96 * se) / sd_y) +
                  sqrt(max(0, exp(0.91 * (abs(tau) - 1.96 * se) / sd_y) *
                       (exp(0.91 * (abs(tau) - 1.96 * se) / sd_y) - 1))))

cat(sprintf("  Point estimate E-value: %.2f\n", e_value))
cat(sprintf("  CI bound E-value: %.2f\n", e_value_ci))
cat("  (An unmeasured confounder would need to be associated with both\n")
cat("   treatment and outcome by a factor of E to explain the result)\n")

###############################################################################
# 8. Permutation inference (Fisher exact test)
###############################################################################

cat("\n--- 8. Permutation inference ---\n")

set.seed(42)
n_perms <- 1000

# Observed test statistic (OLS coefficient)
obs_coef <- coeftable(feols(att8_mean ~ treated + base_pay + urban_proxy,
                            data = la_avg[!is.na(treated)],
                            se = "hetero"))["treated", "Estimate"]

perm_coefs <- numeric(n_perms)
for (i in 1:n_perms) {
  la_avg_perm <- copy(la_avg[!is.na(treated)])
  la_avg_perm[, treated := sample(treated)]
  m_perm <- feols(att8_mean ~ treated + base_pay + urban_proxy,
                  data = la_avg_perm, se = "hetero")
  perm_coefs[i] <- coef(m_perm)["treated"]
}

p_ri <- mean(abs(perm_coefs) >= abs(obs_coef))
cat(sprintf("  Observed coefficient: %.2f\n", obs_coef))
cat(sprintf("  RI p-value (two-sided, %d perms): %.3f\n", n_perms, p_ri))

###############################################################################
# 9. Year-by-year estimates
###############################################################################

cat("\n--- 9. Year-by-year cross-sectional estimates ---\n")

year_results <- list()
for (yr in c(2018, 2021, 2022, 2023)) {
  dt_yr <- panel[year == yr & !is.na(att8) & !is.na(treated)]
  if (nrow(dt_yr) < 20) next

  m_yr <- feols(att8 ~ treated + base_pay + urban_proxy,
                data = dt_yr, se = "hetero")
  ct_yr <- coeftable(m_yr)
  cat(sprintf("  Year %d: coef=%.2f (SE=%.2f, p=%.3f, N=%d)\n",
              yr, ct_yr["treated", "Estimate"],
              ct_yr["treated", "Std. Error"],
              ct_yr["treated", "Pr(>|t|)"],
              nrow(dt_yr)))

  year_results[[as.character(yr)]] <- data.table(
    year = yr,
    coef = ct_yr["treated", "Estimate"],
    se = ct_yr["treated", "Std. Error"],
    p = ct_yr["treated", "Pr(>|t|)"],
    n = nrow(dt_yr)
  )
}
year_results_dt <- rbindlist(year_results)

###############################################################################
# 10. Save robustness results
###############################################################################

robustness <- list(
  median_split = m_med,
  tercile_split = m_ter,
  extreme_quartiles = m_extreme,
  placebo = m_placebo,
  sensemakr = sens_result,
  oster_delta = delta_oster,
  e_value = e_value,
  e_value_ci = e_value_ci,
  ri_pvalue = p_ri,
  perm_coefs = perm_coefs,
  year_results = year_results_dt,
  obs_coef = obs_coef
)

saveRDS(robustness, paste0(data_dir, "robustness_results.rds"))

cat("\n=== ROBUSTNESS COMPLETE ===\n")
