###############################################################################
# 03_main_analysis.R
# Main RDD analysis: OZ designation -> employment outcomes
# APEP-0445 v2
###############################################################################

this_file <- tryCatch(sys.frame(1)$ofile, error = function(e) NULL)
if (is.null(this_file)) this_file <- "."
source(file.path(dirname(this_file), "00_packages.R"))

rdd_sample <- readRDS(file.path(data_dir, "rdd_sample.rds"))
cat("RDD sample loaded:", nrow(rdd_sample), "tracts\n\n")

###############################################################################
# 1. McCrary Density Test
###############################################################################
cat("=== McCrary Density Test ===\n")

mccrary <- rddensity(rdd_sample$poverty_rate, c = 20)
cat(sprintf("  Test statistic: %.3f\n", mccrary$test$t_jk))
cat(sprintf("  P-value: %.4f\n", mccrary$test$p_jk))
cat(sprintf("  Result: %s\n",
            ifelse(mccrary$test$p_jk > 0.05, "PASS (no manipulation)", "FAIL")))

saveRDS(mccrary, file.path(data_dir, "mccrary_test.rds"))


###############################################################################
# 2. Covariate Balance Tests
###############################################################################
cat("\n=== Covariate Balance at Cutoff ===\n")

balance_vars <- c("total_pop", "pct_bachelors", "pct_white",
                   "median_home_value", "unemployment_rate",
                   "pre_total_emp", "pre_info_emp")

balance_results <- data.frame(
  variable = character(),
  coef = numeric(),
  se = numeric(),
  pval = numeric(),
  bandwidth = numeric(),
  stringsAsFactors = FALSE
)

for (v in balance_vars) {
  y <- rdd_sample[[v]]
  valid <- !is.na(y) & !is.na(rdd_sample$poverty_rate)

  if (sum(valid) > 100) {
    tryCatch({
      rd <- rdrobust(y[valid], rdd_sample$poverty_rate[valid], c = 20)
      balance_results <- rbind(balance_results, data.frame(
        variable = v,
        coef = rd$coef[1],
        se = rd$se[3],  # Robust SE
        pval = rd$pv[3],
        bandwidth = rd$bws[1, 1]
      ))
      cat(sprintf("  %-25s coef=%.3f  se=%.3f  p=%.3f  %s\n",
                  v, rd$coef[1], rd$se[3], rd$pv[3],
                  ifelse(rd$pv[3] > 0.05, "ok", "!")))
    }, error = function(e) {
      cat(sprintf("  %-25s ERROR: %s\n", v, substr(e$message, 1, 40)))
    })
  }
}

saveRDS(balance_results, file.path(data_dir, "balance_tests.rds"))


###############################################################################
# 3. First Stage: OZ Designation Probability (Nonparametric)
###############################################################################
cat("\n=== First Stage: OZ Designation Discontinuity ===\n")

first_stage <- rdrobust(
  as.numeric(rdd_sample$oz_designated),
  rdd_sample$poverty_rate,
  c = 20
)
cat(sprintf("  Discontinuity in OZ designation: %.3f (SE: %.3f)\n",
            first_stage$coef[1], first_stage$se[3]))
cat(sprintf("  P-value: %.4f\n", first_stage$pv[3]))
cat(sprintf("  Bandwidth: %.2f pp\n", first_stage$bws[1, 1]))
cat(sprintf("  Effective N (left): %d, (right): %d\n",
            first_stage$N_h[1], first_stage$N_h[2]))

saveRDS(first_stage, file.path(data_dir, "first_stage.rds"))


###############################################################################
# 3b. First Stage: Parametric with F-statistic
###############################################################################
cat("\n=== First Stage: Parametric F-statistic ===\n")

# Use optimal bandwidth from nonparametric first stage
fs_bw <- first_stage$bws[1, 1]
fs_sample <- rdd_sample %>%
  filter(abs(pov_centered) <= fs_bw)

# Linear first stage
fs_linear <- feols(oz_designated ~ eligible_poverty * pov_centered,
                   data = fs_sample, vcov = "HC1")

# Extract F-statistic for the treatment indicator
fs_coef <- coef(fs_linear)["eligible_povertyTRUE"]
fs_se <- sqrt(vcov(fs_linear)["eligible_povertyTRUE", "eligible_povertyTRUE"])
fs_f_manual <- (fs_coef / fs_se)^2

cat(sprintf("  Parametric first-stage coefficient: %.4f (SE: %.4f)\n", fs_coef, fs_se))
cat(sprintf("  First-stage F-statistic: %.1f\n", fs_f_manual))
cat(sprintf("  Stock-Yogo 10%% critical value: 16.38\n"))
cat(sprintf("  Instrument %s\n",
            ifelse(fs_f_manual > 16.38, "STRONG", "WEAK")))

# With covariates
fs_covs <- feols(oz_designated ~ eligible_poverty * pov_centered +
                   total_pop + pct_bachelors + pct_white + unemployment_rate,
                 data = fs_sample, vcov = "HC1")

fs_coef_covs <- coef(fs_covs)["eligible_povertyTRUE"]
fs_se_covs <- sqrt(vcov(fs_covs)["eligible_povertyTRUE", "eligible_povertyTRUE"])
fs_f_covs <- (fs_coef_covs / fs_se_covs)^2
cat(sprintf("  First-stage F (with covariates): %.1f\n", fs_f_covs))

saveRDS(list(
  linear = fs_linear,
  with_covs = fs_covs,
  f_stat = fs_f_manual,
  f_stat_covs = fs_f_covs,
  bandwidth = fs_bw,
  n_obs = nrow(fs_sample)
), file.path(data_dir, "first_stage_parametric.rds"))


###############################################################################
# 4. Reduced-Form RDD: Main Outcomes
###############################################################################
cat("\n=== Reduced-Form RDD Estimates ===\n")

outcomes <- list(
  "Total Employment (Post)" = "post_total_emp",
  "Info Employment (Post)" = "post_info_emp",
  "Construction Emp (Post)" = "post_construction_emp",
  "Log Total Emp (Post)" = "log_post_total_emp",
  "Log Info Emp (Post)" = "log_post_info_emp",
  "Delta Total Emp" = "delta_total_emp",
  "Delta Info Emp" = "delta_info_emp",
  "Delta Construction Emp" = "delta_construction_emp"
)

main_results <- list()
for (name in names(outcomes)) {
  var <- outcomes[[name]]
  y <- rdd_sample[[var]]
  valid <- !is.na(y) & !is.na(rdd_sample$poverty_rate)

  if (sum(valid) > 100) {
    tryCatch({
      rd <- rdrobust(y[valid], rdd_sample$poverty_rate[valid], c = 20)
      main_results[[name]] <- list(
        name = name,
        coef = rd$coef[1],
        se_robust = rd$se[3],
        pval = rd$pv[3],
        ci_lower = rd$ci[3, 1],
        ci_upper = rd$ci[3, 2],
        bandwidth = rd$bws[1, 1],
        N_left = rd$N_h[1],
        N_right = rd$N_h[2]
      )
      cat(sprintf("  %-30s b=%.3f  (SE=%.3f)  p=%.4f  bw=%.1f\n",
                  name, rd$coef[1], rd$se[3], rd$pv[3], rd$bws[1, 1]))
    }, error = function(e) {
      cat(sprintf("  %-30s ERROR: %s\n", name, substr(e$message, 1, 40)))
    })
  }
}

saveRDS(main_results, file.path(data_dir, "main_rdd_results.rds"))


###############################################################################
# 4b. Covariate-Adjusted RDD
###############################################################################
cat("\n=== Covariate-Adjusted RDD ===\n")

cov_vars <- c("total_pop", "pct_bachelors", "pct_white", "unemployment_rate")
cov_adjusted_results <- list()

for (name in c("Delta Total Emp", "Delta Info Emp", "Delta Construction Emp")) {
  var <- outcomes[[name]]
  y <- rdd_sample[[var]]
  x <- rdd_sample$poverty_rate

  # Build covariate matrix
  cov_cols <- rdd_sample[, cov_vars]
  valid <- !is.na(y) & !is.na(x) & complete.cases(cov_cols)

  if (sum(valid) > 100) {
    covs_matrix <- as.matrix(cov_cols[valid, ])

    tryCatch({
      rd_cov <- rdrobust(y[valid], x[valid], c = 20, covs = covs_matrix)
      cov_adjusted_results[[name]] <- list(
        name = name,
        coef = rd_cov$coef[1],
        se_robust = rd_cov$se[3],
        pval = rd_cov$pv[3],
        ci_lower = rd_cov$ci[3, 1],
        ci_upper = rd_cov$ci[3, 2],
        bandwidth = rd_cov$bws[1, 1],
        N_left = rd_cov$N_h[1],
        N_right = rd_cov$N_h[2]
      )
      cat(sprintf("  %-30s b=%.3f  (SE=%.3f)  p=%.4f\n",
                  name, rd_cov$coef[1], rd_cov$se[3], rd_cov$pv[3]))
    }, error = function(e) {
      cat(sprintf("  %-30s ERROR: %s\n", name, substr(e$message, 1, 50)))
    })
  }
}

saveRDS(cov_adjusted_results, file.path(data_dir, "cov_adjusted_rdd_results.rds"))


###############################################################################
# 5. Fuzzy RDD (IV Estimates)
###############################################################################
cat("\n=== Fuzzy RDD (IV) Estimates ===\n")

fuzzy_outcomes <- c("post_total_emp", "post_info_emp", "delta_total_emp", "delta_info_emp")

fuzzy_results <- list()
for (var in fuzzy_outcomes) {
  y <- rdd_sample[[var]]
  d <- as.numeric(rdd_sample$oz_designated)
  x <- rdd_sample$poverty_rate
  valid <- !is.na(y) & !is.na(d) & !is.na(x)

  if (sum(valid) > 100) {
    tryCatch({
      rd_fuzzy <- rdrobust(y[valid], x[valid], c = 20, fuzzy = d[valid])
      fuzzy_results[[var]] <- list(
        outcome = var,
        coef = rd_fuzzy$coef[1],
        se_robust = rd_fuzzy$se[3],
        pval = rd_fuzzy$pv[3],
        ci_lower = rd_fuzzy$ci[3, 1],
        ci_upper = rd_fuzzy$ci[3, 2],
        bandwidth = rd_fuzzy$bws[1, 1]
      )
      cat(sprintf("  %-25s b_IV=%.3f  (SE=%.3f)  p=%.4f\n",
                  var, rd_fuzzy$coef[1], rd_fuzzy$se[3], rd_fuzzy$pv[3]))
    }, error = function(e) {
      cat(sprintf("  %-25s ERROR: %s\n", var, substr(e$message, 1, 50)))
    })
  }
}

saveRDS(fuzzy_results, file.path(data_dir, "fuzzy_rdd_results.rds"))


###############################################################################
# 6. Parametric Specifications (for comparison)
###############################################################################
cat("\n=== Parametric RDD Specifications ===\n")

opt_bw <- ifelse(length(main_results) > 0,
                 main_results[[1]]$bandwidth, 10)

rdd_bw <- rdd_sample %>%
  filter(abs(pov_centered) <= opt_bw)

cat(sprintf("  Optimal bandwidth: %.1f pp\n", opt_bw))
cat(sprintf("  Observations in bandwidth: %d\n", nrow(rdd_bw)))

# Linear, no covariates
m1 <- feols(delta_total_emp ~ eligible_poverty * pov_centered,
            data = rdd_bw, vcov = "HC1")

# Linear, with covariates
m2 <- feols(delta_total_emp ~ eligible_poverty * pov_centered +
              total_pop + pct_bachelors + pct_white + unemployment_rate,
            data = rdd_bw, vcov = "HC1")

# Quadratic
m3 <- feols(delta_total_emp ~ eligible_poverty * (pov_centered + I(pov_centered^2)),
            data = rdd_bw, vcov = "HC1")

# Info employment
m4 <- feols(delta_info_emp ~ eligible_poverty * pov_centered,
            data = rdd_bw, vcov = "HC1")

m5 <- feols(delta_info_emp ~ eligible_poverty * pov_centered +
              total_pop + pct_bachelors + pct_white + unemployment_rate,
            data = rdd_bw, vcov = "HC1")

parametric_models <- list(m1 = m1, m2 = m2, m3 = m3, m4 = m4, m5 = m5)
saveRDS(parametric_models, file.path(data_dir, "parametric_models.rds"))

cat("\n  Parametric estimates (delta total emp):\n")
cat(sprintf("    Linear:            %.3f (%.3f)\n", coef(m1)["eligible_povertyTRUE"],
            sqrt(vcov(m1)["eligible_povertyTRUE", "eligible_povertyTRUE"])))
cat(sprintf("    Linear + covs:     %.3f (%.3f)\n", coef(m2)["eligible_povertyTRUE"],
            sqrt(vcov(m2)["eligible_povertyTRUE", "eligible_povertyTRUE"])))
cat(sprintf("    Quadratic:         %.3f (%.3f)\n", coef(m3)["eligible_povertyTRUE"],
            sqrt(vcov(m3)["eligible_povertyTRUE", "eligible_povertyTRUE"])))


###############################################################################
# 7. County-Clustered Parametric Specifications
###############################################################################
cat("\n=== County-Clustered Parametric Specifications ===\n")

if ("county_fips" %in% names(rdd_bw)) {
  # Linear, county-clustered
  m_clust1 <- feols(delta_total_emp ~ eligible_poverty * pov_centered,
                    data = rdd_bw, cluster = ~county_fips)

  m_clust2 <- feols(delta_total_emp ~ eligible_poverty * pov_centered +
                      total_pop + pct_bachelors + pct_white + unemployment_rate,
                    data = rdd_bw, cluster = ~county_fips)

  m_clust3 <- feols(delta_info_emp ~ eligible_poverty * pov_centered,
                    data = rdd_bw, cluster = ~county_fips)

  m_clust4 <- feols(delta_info_emp ~ eligible_poverty * pov_centered +
                      total_pop + pct_bachelors + pct_white + unemployment_rate,
                    data = rdd_bw, cluster = ~county_fips)

  cluster_models <- list(
    total_linear = m_clust1, total_covs = m_clust2,
    info_linear = m_clust3, info_covs = m_clust4
  )
  saveRDS(cluster_models, file.path(data_dir, "cluster_models.rds"))

  cat(sprintf("  County-clustered (total): %.3f (SE=%.3f)\n",
              coef(m_clust1)["eligible_povertyTRUE"],
              sqrt(vcov(m_clust1)["eligible_povertyTRUE", "eligible_povertyTRUE"])))
  cat(sprintf("  County-clustered (info):  %.3f (SE=%.3f)\n",
              coef(m_clust3)["eligible_povertyTRUE"],
              sqrt(vcov(m_clust3)["eligible_povertyTRUE", "eligible_povertyTRUE"])))
  cat(sprintf("  Number of clusters: %d\n", length(unique(rdd_bw$county_fips))))
} else {
  cat("  WARNING: county_fips not available, skipping clustered SEs\n")
}


cat("\n=== Main analysis complete ===\n")
