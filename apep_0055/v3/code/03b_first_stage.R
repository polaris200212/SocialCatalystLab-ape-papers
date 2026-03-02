# ============================================================================
# APEP-0055 v3: Coverage Cliffs — Age 26 RDD on Birth Insurance Coverage
# 03b_first_stage.R - First-stage evidence of insurance discontinuity at age 26
# ============================================================================
# This script constructs first-stage evidence showing the sharp change in
# insurance coverage at age 26 using the natality data itself. The payment
# source variable (PAY) directly measures insurance status at delivery,
# providing a clean first-stage measure for this population.

source("00_packages.R")

# ============================================================================
# Construct First-Stage from Natality Data
# ============================================================================

cat("=== First-Stage Evidence: Insurance Coverage at Delivery by Age ===\n")

natality <- readRDS(file.path(data_dir, "natality_analysis.rds"))

# Insurance coverage rates by single year of age
first_stage <- natality[, .(
  N = .N,
  private_rate = mean(private, na.rm = TRUE),
  medicaid_rate = mean(medicaid, na.rm = TRUE),
  selfpay_rate = mean(selfpay, na.rm = TRUE),
  any_insurance = mean(1 - selfpay, na.rm = TRUE)
), by = MAGER][order(MAGER)]

first_stage[, source := "Natality"]

cat("\n=== Insurance Coverage by Age at Delivery ===\n")
print(first_stage[, .(MAGER, N,
                       private_pct = round(private_rate * 100, 1),
                       medicaid_pct = round(medicaid_rate * 100, 1),
                       selfpay_pct = round(selfpay_rate * 100, 1))])

saveRDS(first_stage, file.path(data_dir, "first_stage_results.rds"))

# ============================================================================
# First-Stage RD Estimates
# ============================================================================

cat("\n=== First-Stage RD Estimates ===\n")

# Use subsample + jitter for speed
set.seed(55555)
nat_sub <- natality[sample(.N, floor(.N * 0.10))]
nat_sub[, x_j := age_centered + runif(.N, -0.499, 0.499)]

cat("\n--- Private Insurance (First Stage) ---\n")
rd_private_fs <- rdrobust(y = nat_sub$private, x = nat_sub$x_j, c = 0)
summary(rd_private_fs)

cat("\n--- Medicaid (First Stage) ---\n")
rd_medicaid_fs <- rdrobust(y = nat_sub$medicaid, x = nat_sub$x_j, c = 0)
summary(rd_medicaid_fs)

cat("\n--- Self-Pay / Uninsured (First Stage) ---\n")
rd_selfpay_fs <- rdrobust(y = nat_sub$selfpay, x = nat_sub$x_j, c = 0)
summary(rd_selfpay_fs)

fs_rd_results <- list(
  rd_private = rd_private_fs,
  rd_medicaid = rd_medicaid_fs,
  rd_selfpay = rd_selfpay_fs
)
saveRDS(fs_rd_results, file.path(data_dir, "first_stage_rd.rds"))

# Print summary
cat(sprintf("\nPrivate insurance: RD = %.4f (p = %.4f)\n",
            rd_private_fs$coef[1], rd_private_fs$pv[3]))
cat(sprintf("Medicaid:          RD = %.4f (p = %.4f)\n",
            rd_medicaid_fs$coef[1], rd_medicaid_fs$pv[3]))
cat(sprintf("Self-pay:          RD = %.4f (p = %.4f)\n",
            rd_selfpay_fs$coef[1], rd_selfpay_fs$pv[3]))

cat("\nFirst-stage results saved.\n")
cat("\n=== First-Stage Analysis Complete ===\n")
