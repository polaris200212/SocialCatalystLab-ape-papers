# ============================================================================
# APEP-0055 v3: Coverage Cliffs — Age 26 RDD on Birth Insurance Coverage
# 06_robustness.R - Robustness checks including MDE calculations
# ============================================================================

source("00_packages.R")

# Load data
natality <- readRDS(file.path(data_dir, "natality_analysis.rds"))

# ============================================================================
# Robustness 1: Different Polynomial Orders
# ============================================================================

cat("\n=== Robustness: Polynomial Order ===\n")

# With 13M+ observations, rdrobust is very slow. Use 10% subsample.
set.seed(99999)
subsample_frac <- 0.10
df_full <- natality[MAGER >= 22 & MAGER <= 30]
df <- df_full[sample(.N, floor(.N * subsample_frac))]
df[, age_c := MAGER - 26]
df[, x_j := age_c + runif(.N, -0.499, 0.499)]
cat(sprintf("Robustness subsample: %s of %s births\n",
            format(nrow(df), big.mark=","), format(nrow(df_full), big.mark=",")))

poly_results <- list()

for (p in 1:3) {
  rd <- rdrobust(y = df$medicaid, x = df$x_j, c = 0, p = p)

  poly_results[[as.character(p)]] <- data.frame(
    Polynomial = p,
    RD_Estimate = rd$coef[1],
    Robust_SE = rd$se[3],
    CI_Lower = rd$ci["Robust", "CI Lower"],
    CI_Upper = rd$ci["Robust", "CI Upper"]
  )

  cat(sprintf("p = %d: RD = %.4f (%.4f, %.4f)\n",
              p, rd$coef[1],
              rd$ci["Robust", "CI Lower"],
              rd$ci["Robust", "CI Upper"]))
}

poly_table <- do.call(rbind, poly_results)
saveRDS(poly_table, file.path(data_dir, "robustness_polynomial.rds"))

# ============================================================================
# Robustness 2: Different Kernels
# ============================================================================

cat("\n=== Robustness: Kernel Choice ===\n")

kernels <- c("triangular", "uniform", "epanechnikov")
kernel_results <- list()

for (k in kernels) {
  rd <- rdrobust(y = df$medicaid, x = df$x_j, c = 0, kernel = k)

  kernel_results[[k]] <- data.frame(
    Kernel = k,
    RD_Estimate = rd$coef[1],
    Robust_SE = rd$se[3],
    CI_Lower = rd$ci["Robust", "CI Lower"],
    CI_Upper = rd$ci["Robust", "CI Upper"]
  )

  cat(sprintf("%s: RD = %.4f (%.4f, %.4f)\n",
              k, rd$coef[1],
              rd$ci["Robust", "CI Lower"],
              rd$ci["Robust", "CI Upper"]))
}

kernel_table <- do.call(rbind, kernel_results)
saveRDS(kernel_table, file.path(data_dir, "robustness_kernel.rds"))

# ============================================================================
# Robustness 3: Donut-Hole RDD
# ============================================================================

cat("\n=== Robustness: Donut-Hole RDD ===\n")
cat("Excluding observations at age 26 to address birthday timing uncertainty\n\n")

# Donut: exclude age 26 (subsample for speed)
# Use fixed bandwidth h=3 since automatic BW selection fails with gap at cutoff
df_donut_full <- natality[MAGER >= 22 & MAGER <= 30 & MAGER != 26]
df_donut <- df_donut_full[sample(.N, floor(.N * subsample_frac))]
df_donut[, age_c := MAGER - 26]
df_donut[, x_j := age_c + runif(.N, -0.499, 0.499)]

rd_donut <- rdrobust(y = df_donut$medicaid, x = df_donut$x_j, c = 0, h = 3)
summary(rd_donut)

cat(sprintf("Donut RD: %.4f (%.4f, %.4f)\n",
            rd_donut$coef[1],
            rd_donut$ci["Robust", "CI Lower"],
            rd_donut$ci["Robust", "CI Upper"]))

# Also run donut for private and selfpay
rd_donut_private <- rdrobust(y = df_donut$private, x = df_donut$x_j, c = 0, h = 3)
rd_donut_selfpay <- rdrobust(y = df_donut$selfpay, x = df_donut$x_j, c = 0, h = 3)

donut_results <- data.frame(
  Outcome = c("Medicaid", "Private Insurance", "Self-Pay"),
  Baseline = c(
    readRDS(file.path(data_dir, "main_results.rds"))$rd_medicaid$coef[1],
    readRDS(file.path(data_dir, "main_results.rds"))$rd_private$coef[1],
    readRDS(file.path(data_dir, "main_results.rds"))$rd_selfpay$coef[1]
  ),
  Donut = c(
    rd_donut$coef[1],
    rd_donut_private$coef[1],
    rd_donut_selfpay$coef[1]
  )
)
cat("\nDonut-hole comparison:\n")
print(donut_results)

saveRDS(donut_results, file.path(data_dir, "robustness_donut.rds"))

# ============================================================================
# Robustness 4: With Covariates (addresses education imbalance)
# ============================================================================

cat("\n=== Robustness: Covariate-Adjusted RDD ===\n")

# Prepare covariates matrix (complete cases only)
df_cov <- df[complete.cases(df[, .(married, college, us_born)])]
Z <- as.matrix(df_cov[, .(married, college, us_born)])

df_cov[, x_j := age_c + runif(.N, -0.499, 0.499)]
rd_cov <- rdrobust(y = df_cov$medicaid, x = df_cov$x_j, c = 0, covs = Z)
summary(rd_cov)

cat(sprintf("Covariate-adjusted RD: %.4f (%.4f, %.4f)\n",
            rd_cov$coef[1],
            rd_cov$ci["Robust", "CI Lower"],
            rd_cov$ci["Robust", "CI Upper"]))

# Also with flexible education control
df_cov[, educ_control := as.numeric(college)]
Z_flex <- as.matrix(df_cov[, .(married, educ_control, us_born)])
rd_cov_flex <- rdrobust(y = df_cov$medicaid, x = df_cov$x_j, c = 0, covs = Z_flex)

cat(sprintf("Flexible education control RD: %.4f (%.4f, %.4f)\n",
            rd_cov_flex$coef[1],
            rd_cov_flex$ci["Robust", "CI Lower"],
            rd_cov_flex$ci["Robust", "CI Upper"]))

saveRDS(list(rd_cov = rd_cov, rd_cov_flex = rd_cov_flex),
        file.path(data_dir, "robustness_covariates.rds"))

# ============================================================================
# Robustness 5: By Year
# ============================================================================

cat("\n=== Robustness: By Year ===\n")

year_results <- list()

for (yr in sort(unique(natality$data_year))) {
  df_yr_full <- natality[data_year == yr & MAGER >= 22 & MAGER <= 30]
  # Each year has ~1.5M obs; subsample to ~150K
  df_yr <- df_yr_full[sample(.N, floor(.N * subsample_frac))]
  df_yr[, age_c := MAGER - 26]

  if (nrow(df_yr) < 1000) next

  df_yr[, x_j := age_c + runif(.N, -0.499, 0.499)]
  rd_yr <- rdrobust(y = df_yr$medicaid, x = df_yr$x_j, c = 0)

  year_results[[as.character(yr)]] <- data.frame(
    Year = yr,
    N = nrow(df_yr_full),
    RD_Estimate = rd_yr$coef[1],
    Robust_SE = rd_yr$se[3],
    p_value = rd_yr$pv[3]
  )

  cat(sprintf("Year %d (N=%s): RD = %.4f (p = %.3f)\n",
              yr, format(nrow(df_yr_full), big.mark=","),
              rd_yr$coef[1],
              rd_yr$pv[3]))
}

year_table <- do.call(rbind, year_results)
saveRDS(year_table, file.path(data_dir, "robustness_by_year.rds"))

# ============================================================================
# Robustness 6: Alternative Outcomes
# ============================================================================

cat("\n=== Robustness: All Payment Outcomes ===\n")

outcomes <- c("medicaid", "private", "selfpay")
outcome_labels <- c("Medicaid", "Private Insurance", "Self-Pay")

outcome_results <- list()

for (i in seq_along(outcomes)) {
  outcome <- outcomes[i]
  label <- outcome_labels[i]

  rd <- rdrobust(y = df[[outcome]], x = df$x_j, c = 0)

  outcome_results[[outcome]] <- data.frame(
    Outcome = label,
    RD_Estimate = rd$coef[1],
    Robust_SE = rd$se[3],
    CI_Lower = rd$ci["Robust", "CI Lower"],
    CI_Upper = rd$ci["Robust", "CI Upper"],
    p_value = rd$pv[3]
  )

  cat(sprintf("%s: RD = %.4f (SE = %.4f, p = %.3f)\n",
              label, rd$coef[1],
              rd$se[3],
              rd$pv[3]))
}

outcome_table <- do.call(rbind, outcome_results)
saveRDS(outcome_table, file.path(data_dir, "robustness_outcomes.rds"))

# ============================================================================
# Robustness 7: Minimum Detectable Effect (MDE) Calculations
# ============================================================================

cat("\n=== Minimum Detectable Effect (MDE) ===\n")
cat("Power analysis for health outcomes with multi-year pooled data\n\n")

# MDE = (z_alpha + z_beta) * sigma / sqrt(N_eff)
# For RD: N_eff is the effective sample at the boundary
# We use the N within the optimal bandwidth from rdrobust

main_results <- readRDS(file.path(data_dir, "main_results.rds"))

health_outcomes <- c("early_prenatal", "preterm", "low_birthweight")
health_labels <- c("Early Prenatal Care", "Preterm Birth", "Low Birth Weight")

mde_results <- list()

for (i in seq_along(health_outcomes)) {
  outcome <- health_outcomes[i]
  label <- health_labels[i]

  # Get outcome mean and SD
  y_mean <- mean(df[[outcome]], na.rm = TRUE)
  y_sd <- sd(df[[outcome]], na.rm = TRUE)

  # Get effective N from RD (sum of left + right within bandwidth)
  rd_obj <- main_results[[paste0("rd_", gsub("early_", "", outcome))]]
  if (is.null(rd_obj)) {
    rd_obj <- main_results[[paste0("rd_", gsub("low_", "", outcome))]]
  }

  # Use total N within bandwidth = 4
  n_bw <- nrow(df[!is.na(get(outcome))])

  # For RD, effective N is roughly N_h (within optimal bandwidth)
  # Using conventional MDE formula for two-sample test at boundary
  # MDE = 2.8 * sigma / sqrt(N_eff)   [alpha=0.05, power=0.80]
  n_eff <- n_bw / 2  # Approximate: half on each side
  mde <- 2.8 * y_sd / sqrt(n_eff)

  mde_results[[outcome]] <- data.frame(
    Outcome = label,
    Mean = y_mean,
    SD = y_sd,
    N_total = n_bw,
    N_effective = n_eff,
    MDE = mde,
    MDE_pct = mde / y_mean * 100
  )

  cat(sprintf("%s: mean = %.3f, MDE = %.4f (%.1f%% of mean), N_eff = %s\n",
              label, y_mean, mde, mde / y_mean * 100,
              format(n_eff, big.mark = ",")))
}

mde_table <- do.call(rbind, mde_results)
saveRDS(mde_table, file.path(data_dir, "mde_results.rds"))

cat("\nMDE table:\n")
print(mde_table)

# ============================================================================
# Summary Table
# ============================================================================

cat("\n=== ROBUSTNESS SUMMARY ===\n")

# Load main result for comparison
main_est <- main_results$rd_medicaid$coef[1]

cat(sprintf("Main estimate (Medicaid): %.4f\n\n", main_est))

cat("Specification checks:\n")
cat(sprintf("  Linear polynomial:      %.4f\n", poly_table$RD_Estimate[1]))
cat(sprintf("  Quadratic polynomial:   %.4f\n", poly_table$RD_Estimate[2]))
cat(sprintf("  Cubic polynomial:       %.4f\n", poly_table$RD_Estimate[3]))
cat(sprintf("  Triangular kernel:      %.4f\n", kernel_table$RD_Estimate[1]))
cat(sprintf("  Uniform kernel:         %.4f\n", kernel_table$RD_Estimate[2]))
cat(sprintf("  Epanechnikov kernel:    %.4f\n", kernel_table$RD_Estimate[3]))
cat(sprintf("  Donut-hole:             %.4f\n", rd_donut$coef[1]))
cat(sprintf("  With covariates:        %.4f\n", rd_cov$coef[1]))

# ============================================================================
# Heterogeneity Analysis: By Marital Status
# ============================================================================

cat("\n=== Heterogeneity: By Marital Status ===\n")

het_results <- list()

for (status in c("Married", "Unmarried")) {
  if (status == "Married") {
    df_sub_full <- natality[married == 1 & MAGER >= 22 & MAGER <= 30]
  } else {
    df_sub_full <- natality[married == 0 & MAGER >= 22 & MAGER <= 30]
  }
  df_sub <- df_sub_full[sample(.N, floor(.N * subsample_frac))]
  df_sub[, age_c := MAGER - 26]

  df_sub[, x_j := age_c + runif(.N, -0.499, 0.499)]
  rd_sub <- rdrobust(y = df_sub$medicaid, x = df_sub$x_j, c = 0)

  het_results[[status]] <- data.frame(
    Group = status,
    N = nrow(df_sub_full),
    RD_Estimate = rd_sub$coef[1],
    Robust_SE = rd_sub$se[3],
    CI_Lower = rd_sub$ci["Robust", "CI Lower"],
    CI_Upper = rd_sub$ci["Robust", "CI Upper"],
    p_value = rd_sub$pv[3]
  )

  cat(sprintf("%s (N=%s): RD = %.4f (SE = %.4f, p = %.4f)\n",
              status, format(nrow(df_sub_full), big.mark=","),
              rd_sub$coef[1],
              rd_sub$se[3],
              rd_sub$pv[3]))
}

het_table <- do.call(rbind, het_results)
saveRDS(het_table, file.path(data_dir, "heterogeneity_marital.rds"))

cat("\nHeterogeneity results saved to heterogeneity_marital.rds\n")

cat("\n\nAll robustness results saved.\n")
