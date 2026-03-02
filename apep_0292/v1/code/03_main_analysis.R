## 03_main_analysis.R — RDD estimation with rdrobust
## APEP-0281: Mandatory Energy Disclosure and Property Values (RDD)

source("00_packages.R")

# ============================================================
# Load data
# ============================================================
pluto <- readRDS(file.path(data_dir, "pluto_analysis.rds"))
rdd_narrow <- readRDS(file.path(data_dir, "rdd_narrow.rds"))

cat("Analysis sample loaded:", nrow(rdd_narrow), "buildings (15K-35K sq ft)\n")

# ============================================================
# 1. McCrary Density Test
# ============================================================
cat("\n=== McCrary Density Test ===\n")

# Test for manipulation/bunching at 25K sq ft
density_test <- rddensity(
  X = rdd_narrow$gfa_centered,
  c = 0
)

cat("McCrary test statistic:", density_test$test$t_jk, "\n")
cat("McCrary p-value:", density_test$test$p_jk, "\n")

density_results <- list(
  t_stat = density_test$test$t_jk,
  p_value = density_test$test$p_jk,
  conclusion = ifelse(density_test$test$p_jk > 0.05,
                      "No evidence of manipulation (p > 0.05)",
                      "WARNING: Evidence of bunching at threshold")
)

saveRDS(density_results, file.path(data_dir, "density_test.rds"))

# ============================================================
# 2. Covariate Balance Tests
# ============================================================
cat("\n=== Covariate Balance at Threshold ===\n")

covariates <- c("yearbuilt", "numfloors", "lotarea", "building_age")
cov_labels <- c("Year Built", "Number of Floors", "Lot Area (sq ft)", "Building Age")

cov_results <- list()
for (i in seq_along(covariates)) {
  var <- covariates[i]
  y <- rdd_narrow[[var]]
  x <- rdd_narrow$gfa_centered

  valid <- !is.na(y) & !is.na(x)
  if (sum(valid) < 100) {
    cat("  Skipping", var, "- insufficient observations\n")
    next
  }

  rd_cov <- tryCatch(
    rdrobust(y = y[valid], x = x[valid], c = 0),
    error = function(e) NULL
  )

  if (!is.null(rd_cov)) {
    cov_results[[var]] <- list(
      variable = cov_labels[i],
      estimate = rd_cov$coef[1],
      se = rd_cov$se[3],  # Robust SE
      pvalue = rd_cov$pv[3],  # Robust p-value
      bw = rd_cov$bws[1, 1],
      n_left = rd_cov$N_h[1],
      n_right = rd_cov$N_h[2]
    )
    cat(sprintf("  %s: coef = %.3f, p = %.3f (bw = %.0f)\n",
                cov_labels[i], rd_cov$coef[1], rd_cov$pv[3], rd_cov$bws[1, 1]))
  }
}

saveRDS(cov_results, file.path(data_dir, "cov_balance.rds"))

# ============================================================
# 3. Main RDD Results — Log Assessed Total Value
# ============================================================
cat("\n=== Main RDD: Log Assessed Total Value ===\n")

# MSE-optimal bandwidth (primary specification)
rd_assess <- rdrobust(
  y = rdd_narrow$log_assesstot,
  x = rdd_narrow$gfa_centered,
  c = 0,
  kernel = "triangular",
  p = 1,  # Local linear
  bwselect = "mserd"
)

cat("\n--- Primary Result (Local Linear, MSE-Optimal BW) ---\n")
summary(rd_assess)

main_result <- list(
  outcome = "Log Assessed Total Value",
  estimate = rd_assess$coef[1],
  se_robust = rd_assess$se[3],
  pv_robust = rd_assess$pv[3],
  ci_lower = rd_assess$ci[3, 1],
  ci_upper = rd_assess$ci[3, 2],
  bw = rd_assess$bws[1, 1],
  n_left = rd_assess$N_h[1],
  n_right = rd_assess$N_h[2],
  n_eff = rd_assess$N_h[1] + rd_assess$N_h[2]
)

# Local quadratic
rd_assess_q <- rdrobust(
  y = rdd_narrow$log_assesstot,
  x = rdd_narrow$gfa_centered,
  c = 0,
  kernel = "triangular",
  p = 2,
  bwselect = "mserd"
)

cat("\n--- Quadratic Specification ---\n")
cat("Estimate:", rd_assess_q$coef[1], "  SE:", rd_assess_q$se[3],
    "  p:", rd_assess_q$pv[3], "\n")

# ============================================================
# 4. RDD: Log Assessed Value per Square Foot
# ============================================================
cat("\n=== RDD: Log Assessed Value per Sq Ft ===\n")

rd_assess_sqft <- rdrobust(
  y = rdd_narrow$log_assess_per_sqft,
  x = rdd_narrow$gfa_centered,
  c = 0,
  kernel = "triangular",
  p = 1,
  bwselect = "mserd"
)

cat("Estimate:", rd_assess_sqft$coef[1], "  SE:", rd_assess_sqft$se[3],
    "  p:", rd_assess_sqft$pv[3], "\n")

# ============================================================
# 5. RDD: LL84 Compliance (First Stage)
# ============================================================
cat("\n=== First Stage: LL84 Compliance ===\n")

rd_compliance <- rdrobust(
  y = rdd_narrow$has_ll84,
  x = rdd_narrow$gfa_centered,
  c = 0,
  kernel = "triangular",
  p = 1,
  bwselect = "mserd"
)

cat("First stage jump:", rd_compliance$coef[1], "  SE:", rd_compliance$se[3],
    "  p:", rd_compliance$pv[3], "\n")

# ============================================================
# 6. RDD: Building Permits (Investment Response)
# ============================================================
if ("n_permits_post" %in% names(rdd_narrow)) {
  cat("\n=== RDD: Post-Policy Building Permits ===\n")

  rd_permits <- rdrobust(
    y = rdd_narrow$has_permit_post,
    x = rdd_narrow$gfa_centered,
    c = 0,
    kernel = "triangular",
    p = 1,
    bwselect = "mserd"
  )

  cat("Estimate:", rd_permits$coef[1], "  SE:", rd_permits$se[3],
      "  p:", rd_permits$pv[3], "\n")
}

# ============================================================
# 6b. Fuzzy RDD — LATE (Wald) estimate
# ============================================================
cat("\n=== Fuzzy RDD: LATE Estimate ===\n")

rd_fuzzy <- rdrobust(
  y = rdd_narrow$log_assesstot,
  x = rdd_narrow$gfa_centered,
  c = 0,
  fuzzy = rdd_narrow$has_ll84,
  kernel = "triangular",
  p = 1,
  bwselect = "mserd"
)

cat("Fuzzy RDD (LATE) estimate:", rd_fuzzy$coef[1], "\n")
cat("  Robust SE:", rd_fuzzy$se[3], "\n")
cat("  Robust p-value:", rd_fuzzy$pv[3], "\n")
cat("  95% CI: [", rd_fuzzy$ci[3, 1], ",", rd_fuzzy$ci[3, 2], "]\n")
cat("  Bandwidth:", rd_fuzzy$bws[1, 1], "\n")
cat("  Effective N:", rd_fuzzy$N_h[1] + rd_fuzzy$N_h[2], "\n")

# First-stage F-stat (from linear model within optimal bandwidth)
bw_opt <- rd_compliance$bws[1, 1]
rdd_bw <- rdd_narrow %>%
  filter(abs(gfa_centered) <= bw_opt)

fs_model <- lm(has_ll84 ~ above_threshold * gfa_centered, data = rdd_bw)
fs_fstat <- summary(fs_model)$fstatistic
cat("\nFirst-stage F-statistic:", fs_fstat[1], "\n")
cat("  (df1 =", fs_fstat[2], ", df2 =", fs_fstat[3], ")\n")

fuzzy_result <- list(
  late = rd_fuzzy$coef[1],
  se_robust = rd_fuzzy$se[3],
  pv_robust = rd_fuzzy$pv[3],
  ci_lower = rd_fuzzy$ci[3, 1],
  ci_upper = rd_fuzzy$ci[3, 2],
  bw = rd_fuzzy$bws[1, 1],
  n_eff = rd_fuzzy$N_h[1] + rd_fuzzy$N_h[2],
  fs_fstat = fs_fstat[1]
)

saveRDS(fuzzy_result, file.path(data_dir, "fuzzy_rdd.rds"))

# ============================================================
# 7. Parametric RDD (for comparison)
# ============================================================
cat("\n=== Parametric RDD (OLS) ===\n")

# Linear in GFA, different slopes
param_linear <- feols(
  log_assesstot ~ above_threshold * gfa_centered | borough_name,
  data = rdd_narrow
)

# Quadratic
param_quad <- feols(
  log_assesstot ~ above_threshold * (gfa_centered + I(gfa_centered^2)) | borough_name,
  data = rdd_narrow
)

cat("Parametric linear: coef =", coef(param_linear)["above_threshold"],
    "  SE =", se(param_linear)["above_threshold"], "\n")
cat("Parametric quad:   coef =", coef(param_quad)["above_threshold"],
    "  SE =", se(param_quad)["above_threshold"], "\n")

# ============================================================
# 8. Save all results
# ============================================================
results <- list(
  density_test = density_results,
  covariate_balance = cov_results,
  main_assess = main_result,
  rd_assess = rd_assess,
  rd_assess_q = rd_assess_q,
  rd_assess_sqft = rd_assess_sqft,
  rd_compliance = rd_compliance,
  param_linear = param_linear,
  param_quad = param_quad,
  fuzzy = fuzzy_result
)

if (exists("rd_permits")) results$rd_permits <- rd_permits

saveRDS(results, file.path(data_dir, "main_results.rds"))

cat("\n=== Main Analysis Complete ===\n")
cat("Key result: Disclosure effect on log assessed value =",
    round(main_result$estimate, 4),
    " (p =", round(main_result$pv_robust, 4), ")\n")
cat("Bandwidth:", round(main_result$bw), "sq ft\n")
cat("Effective N:", main_result$n_eff, "\n")
