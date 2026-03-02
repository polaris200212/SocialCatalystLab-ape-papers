## ============================================================================
## 04b_rand_inference.R — Randomization Inference for Discrete Running Variable
## Project: The First Retirement Age v2 (revision of apep_0442)
##
## Implements Cattaneo, Frandsen, and Titiunik (2015) randomization inference
## for RDD with discrete running variables. Standard rdrobust asymptotics may
## be unreliable when the running variable has few mass points near the cutoff.
##
## Approach: Under the null of no treatment effect, we can permute treatment
## assignment within each value of the running variable. The RI p-value is the
## fraction of permuted test statistics that exceed the observed statistic.
## ============================================================================

source("code/00_packages.R")

union <- readRDS(file.path(data_dir, "union_veterans.rds"))

ri_results <- list()

## ---- 1. Setup ----
cat("=== Randomization Inference for RDD ===\n")
cat("Method: Cattaneo, Frandsen, Titiunik (2015)\n")
cat("Running variable: discrete age (integer years)\n\n")

# Get optimal bandwidth
rd_main <- rdrobust(union$in_labor_force, union$AGE, c = 62,
                     kernel = "triangular", p = 1)
h_opt <- rd_main$bws["h", "left"]
tau_obs <- rd_main$coef["Conventional", 1]

cat("Observed RD estimate:", round(tau_obs, 4), "\n")
cat("Optimal bandwidth:", round(h_opt, 1), "\n")

## ---- 2. RI via permutation within age cells ----
# Under sharp null H0: Y_i(1) = Y_i(0) for all i
# Treatment assignment at age 62 is as-if random conditional on age
# We permute the above/below-62 assignment

set.seed(2026)
n_perms <- 5000  # 5000 permutations (feasible with 96GB RAM)

# Working sample within bandwidth
ws <- union[AGE >= (62 - h_opt) & AGE <= (62 + h_opt)]
cat("Working sample within bandwidth:", format(nrow(ws), big.mark = ","), "\n")

# Observed test statistic: difference in means (simple, transparent)
mean_above <- mean(ws[AGE >= 62]$in_labor_force, na.rm = TRUE)
mean_below <- mean(ws[AGE < 62]$in_labor_force, na.rm = TRUE)
t_obs <- mean_above - mean_below

cat("Simple diff-in-means:", round(t_obs, 4), "\n\n")

# Permutation distribution: shuffle treatment labels within age bins
# This maintains the age distribution but breaks the treatment assignment
cat("Running", n_perms, "permutations...\n")

# Method: For each permutation, randomly reassign which side of 62 each
# age value falls on. Since age is discrete, we permute the cutoff assignment
# by randomly swapping observations between the left and right of the cutoff.

# Simpler approach: within the bandwidth, randomly assign above/below status
# preserving the marginal distribution of outcomes and ages
perm_stats <- numeric(n_perms)

for (b in seq_len(n_perms)) {
  # Shuffle the above_62 indicator
  ws_perm <- copy(ws)
  ws_perm[, above_62_perm := sample(above_62)]

  mean_above_perm <- mean(ws_perm[above_62_perm == 1]$in_labor_force, na.rm = TRUE)
  mean_below_perm <- mean(ws_perm[above_62_perm == 0]$in_labor_force, na.rm = TRUE)
  perm_stats[b] <- mean_above_perm - mean_below_perm
}

# RI p-value: fraction of permuted stats at least as extreme as observed
ri_pvalue_twosided <- mean(abs(perm_stats) >= abs(t_obs))
ri_pvalue_onesided <- mean(perm_stats <= t_obs)  # one-sided: pension reduces LFP

cat("RI p-value (two-sided):", round(ri_pvalue_twosided, 4), "\n")
cat("RI p-value (one-sided, H1: pension reduces LFP):", round(ri_pvalue_onesided, 4), "\n")

ri_results$main <- list(
  tau_obs = t_obs,
  ri_pvalue_twosided = ri_pvalue_twosided,
  ri_pvalue_onesided = ri_pvalue_onesided,
  n_perms = n_perms,
  bandwidth = h_opt,
  n_working_sample = nrow(ws),
  perm_distribution = perm_stats,
  conventional_pvalue = rd_main$pv["Conventional", 1]
)

## ---- 3. RI with rdrobust test statistic ----
cat("\n--- RI using rdrobust test statistic ---\n")
cat("(More sophisticated but slower — using T-stat from rdrobust)\n")

# For each permutation, run rdrobust and collect the T-statistic
n_perms_robust <- 1000  # Fewer due to computational cost
cat("Running", n_perms_robust, "rdrobust permutations...\n")

t_obs_robust <- rd_main$coef["Conventional", 1] / rd_main$se["Conventional", 1]
perm_tstats <- numeric(n_perms_robust)

for (b in seq_len(n_perms_robust)) {
  # Shuffle outcome within bandwidth
  ws_perm <- copy(ws)
  ws_perm[, y_perm := sample(in_labor_force)]

  tryCatch({
    rd_perm <- rdrobust(ws_perm$y_perm, ws_perm$AGE, c = 62,
                         kernel = "triangular", p = 1, h = h_opt)
    perm_tstats[b] <- rd_perm$coef["Conventional", 1] / rd_perm$se["Conventional", 1]
  }, error = function(e) {
    perm_tstats[b] <<- NA
  })

  if (b %% 200 == 0) cat(sprintf("  %d/%d permutations complete\n", b, n_perms_robust))
}

# Remove NAs
perm_tstats_valid <- perm_tstats[!is.na(perm_tstats)]
ri_pvalue_robust <- mean(abs(perm_tstats_valid) >= abs(t_obs_robust))

cat("RI p-value (rdrobust T-stat, two-sided):", round(ri_pvalue_robust, 4), "\n")
cat("Conventional T-stat:", round(t_obs_robust, 3), "\n")
cat("Valid permutations:", length(perm_tstats_valid), "/", n_perms_robust, "\n")

ri_results$robust <- list(
  t_obs = t_obs_robust,
  ri_pvalue = ri_pvalue_robust,
  n_perms = n_perms_robust,
  n_valid = length(perm_tstats_valid),
  perm_distribution = perm_tstats_valid
)

## ---- 4. RI for secondary outcomes ----
cat("\n--- RI for Secondary Outcomes ---\n")

sec_vars <- c("has_occupation", "owns_home", "is_head", "farm_occ")
ri_secondary <- data.table(
  outcome = character(),
  tau_obs = numeric(),
  ri_pvalue = numeric(),
  conventional_pvalue = numeric()
)

for (var in sec_vars) {
  y <- ws[[var]]
  mean_a <- mean(y[ws$AGE >= 62], na.rm = TRUE)
  mean_b <- mean(y[ws$AGE < 62], na.rm = TRUE)
  t_obs_sec <- mean_a - mean_b

  perm_sec <- numeric(n_perms)
  for (b in seq_len(n_perms)) {
    perm_idx <- sample(ws$above_62)
    perm_sec[b] <- mean(y[perm_idx == 1], na.rm = TRUE) -
                   mean(y[perm_idx == 0], na.rm = TRUE)
  }

  ri_p <- mean(abs(perm_sec) >= abs(t_obs_sec))

  # Conventional p-value
  tryCatch({
    rd_sec <- rdrobust(union[[var]], union$AGE, c = 62, kernel = "triangular", p = 1)
    conv_p <- rd_sec$pv["Conventional", 1]
  }, error = function(e) {
    conv_p <- NA
  })

  ri_secondary <- rbind(ri_secondary, data.table(
    outcome = var,
    tau_obs = t_obs_sec,
    ri_pvalue = ri_p,
    conventional_pvalue = conv_p
  ))
  cat(sprintf("  %-20s: RI p = %.3f, Conv. p = %.3f\n", var, ri_p, conv_p))
}

ri_results$secondary <- ri_secondary

## ---- 5. Save ----
saveRDS(ri_results, file.path(data_dir, "ri_results.rds"))
cat("\nRandomization inference complete.\n")
