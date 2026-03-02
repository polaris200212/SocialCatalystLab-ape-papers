## ============================================================================
## 03b_diff_in_disc.R — Difference-in-Discontinuities (Union − Confederate)
## Project: The First Retirement Age v2 (revision of apep_0442)
##
## Key idea: Both Union and Confederate veterans share the same aging process,
## cohort composition, and census enumeration. Only Union veterans crossed the
## pension eligibility threshold at age 62. The difference between the two
## discontinuities isolates the pension effect from any age-related confound.
##
## τ_DiD = τ_Union(62) − τ_Confederate(62)
##
## Method: Pooled regression with union × above_62 interaction.
## ============================================================================

source("code/00_packages.R")

## ---- 1. Load data ----
union <- readRDS(file.path(data_dir, "union_veterans.rds"))
confed <- readRDS(file.path(data_dir, "confed_veterans.rds"))

cat("Union veterans:", format(nrow(union), big.mark = ","), "\n")
cat("Confederate veterans:", format(nrow(confed), big.mark = ","), "\n")

## ---- 2. Create pooled dataset ----
union[, is_union := 1L]
confed[, is_union := 0L]

# Ensure both have the same columns
shared_cols <- intersect(names(union), names(confed))
pooled <- rbind(union[, ..shared_cols], confed[, ..shared_cols])
cat("Pooled sample:", format(nrow(pooled), big.mark = ","), "\n")

## ---- 3. Diff-in-disc via pooled rdrobust ----
cat("\n=== Difference-in-Discontinuities ===\n")

did_results <- list()

# Method 1: Separate RDD estimates, then difference
cat("\n--- Method 1: Separate RDD estimates ---\n")

rd_union <- rdrobust(union$in_labor_force, union$AGE, c = 62,
                      kernel = "triangular", p = 1)
rd_confed <- rdrobust(confed$in_labor_force, confed$AGE, c = 62,
                       kernel = "triangular", p = 1)

tau_union <- rd_union$coef["Conventional", 1]
se_union <- rd_union$se["Conventional", 1]
tau_confed <- rd_confed$coef["Conventional", 1]
se_confed <- rd_confed$se["Conventional", 1]

# Difference (assuming independence between Union and Confederate samples)
tau_did <- tau_union - tau_confed
se_did <- sqrt(se_union^2 + se_confed^2)
z_did <- tau_did / se_did
p_did <- 2 * pnorm(-abs(z_did))

cat("  Union RD:", round(tau_union, 4), "(SE:", round(se_union, 4), ")\n")
cat("  Confederate RD:", round(tau_confed, 4), "(SE:", round(se_confed, 4), ")\n")
cat("  Diff-in-disc:", round(tau_did, 4), "(SE:", round(se_did, 4), ")\n")
cat("  P-value:", round(p_did, 4), "\n")
cat("  95% CI: [", round(tau_did - 1.96 * se_did, 4), ",",
    round(tau_did + 1.96 * se_did, 4), "]\n")

did_results$separate <- list(
  tau_union = tau_union, se_union = se_union,
  tau_confed = tau_confed, se_confed = se_confed,
  tau_did = tau_did, se_did = se_did,
  pvalue = p_did,
  n_union_left = rd_union$N_h[1], n_union_right = rd_union$N_h[2],
  n_confed_left = rd_confed$N_h[1], n_confed_right = rd_confed$N_h[2]
)

# Method 2: Pooled parametric regression with interaction
cat("\n--- Method 2: Pooled parametric regression ---\n")

# Use fixed bandwidth from Union RDD
h <- rd_union$bws["h", "left"]
pooled_bw <- pooled[AGE >= (62 - h) & AGE <= (62 + h)]

# Regression: Y = α + β₁·Union + β₂·Above62 + β₃·Union×Above62
#              + f(age) + g(age)·Union + ε
# β₃ is the diff-in-disc estimator
pooled_bw[, age_c := AGE - 62]
pooled_bw[, above := as.integer(AGE >= 62)]

reg_did <- feols(in_labor_force ~ is_union * above + age_c, data = pooled_bw)
cat("  Pooled regression (interaction term):\n")
cat("  Union × Above62:", round(coef(reg_did)["is_union:above"], 4),
    "(SE:", round(se(reg_did)["is_union:above"], 4), ")\n")

did_results$pooled_reg <- reg_did

# Method 3: Varying bandwidths for robustness
cat("\n--- Method 3: Bandwidth sensitivity ---\n")

bw_grid <- c(3, 4, 5, 6, 7, 8, 10, 12, 15)
did_bw <- data.table(
  bandwidth = numeric(),
  tau_union = numeric(), se_union = numeric(),
  tau_confed = numeric(), se_confed = numeric(),
  tau_did = numeric(), se_did = numeric(),
  pvalue = numeric()
)

for (bw in bw_grid) {
  tryCatch({
    rd_u <- rdrobust(union$in_labor_force, union$AGE, c = 62, h = bw,
                      kernel = "triangular", p = 1)
    rd_c <- rdrobust(confed$in_labor_force, confed$AGE, c = 62, h = bw,
                      kernel = "triangular", p = 1)

    t_u <- rd_u$coef["Conventional", 1]
    s_u <- rd_u$se["Conventional", 1]
    t_c <- rd_c$coef["Conventional", 1]
    s_c <- rd_c$se["Conventional", 1]
    t_d <- t_u - t_c
    s_d <- sqrt(s_u^2 + s_c^2)
    p_d <- 2 * pnorm(-abs(t_d / s_d))

    did_bw <- rbind(did_bw, data.table(
      bandwidth = bw,
      tau_union = t_u, se_union = s_u,
      tau_confed = t_c, se_confed = s_c,
      tau_did = t_d, se_did = s_d, pvalue = p_d
    ))
    cat(sprintf("  h = %2d: DiD = %7.4f (SE = %6.4f), p = %.3f\n",
                bw, t_d, s_d, p_d))
  }, error = function(e) {
    cat(sprintf("  h = %2d: ERROR\n", bw))
  })
}

did_results$bandwidth_sensitivity <- did_bw

## ---- 4. Diff-in-disc for secondary outcomes ----
cat("\n=== Diff-in-Disc: Secondary Outcomes ===\n")

sec_outcomes <- c("has_occupation", "owns_home", "is_head", "farm_occ", "manual_labor")
did_secondary <- data.table(
  outcome = character(),
  tau_union = numeric(), se_union = numeric(),
  tau_confed = numeric(), se_confed = numeric(),
  tau_did = numeric(), se_did = numeric(),
  pvalue = numeric()
)

for (var in sec_outcomes) {
  tryCatch({
    rd_u <- rdrobust(union[[var]], union$AGE, c = 62, kernel = "triangular", p = 1)
    rd_c <- rdrobust(confed[[var]], confed$AGE, c = 62, kernel = "triangular", p = 1)

    t_u <- rd_u$coef["Conventional", 1]
    s_u <- rd_u$se["Conventional", 1]
    t_c <- rd_c$coef["Conventional", 1]
    s_c <- rd_c$se["Conventional", 1]
    t_d <- t_u - t_c
    s_d <- sqrt(s_u^2 + s_c^2)
    p_d <- 2 * pnorm(-abs(t_d / s_d))

    did_secondary <- rbind(did_secondary, data.table(
      outcome = var,
      tau_union = t_u, se_union = s_u,
      tau_confed = t_c, se_confed = s_c,
      tau_did = t_d, se_did = s_d, pvalue = p_d
    ))
    cat(sprintf("  %-20s: DiD = %7.4f (SE = %6.4f), p = %.3f\n", var, t_d, s_d, p_d))
  }, error = function(e) {
    cat(sprintf("  %-20s: ERROR\n", var))
  })
}

did_results$secondary <- did_secondary

## ---- 5. Save results ----
saveRDS(did_results, file.path(data_dir, "did_results.rds"))

cat("\nDifference-in-discontinuities analysis complete.\n")
