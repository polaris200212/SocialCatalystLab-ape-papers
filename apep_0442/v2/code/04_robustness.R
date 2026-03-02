## ============================================================================
## 04_robustness.R — Robustness checks for the age-62 pension RDD
## Project: The First Retirement Age v2 (revision of apep_0442)
## ============================================================================

source("code/00_packages.R")

union <- readRDS(file.path(data_dir, "union_veterans.rds"))
confed <- readRDS(file.path(data_dir, "confed_veterans.rds"))

robust_results <- list()

## ---- 1. Bandwidth Sensitivity ----
cat("=== Bandwidth Sensitivity ===\n")

rd_main <- rdrobust(union$in_labor_force, union$AGE, c = 62,
                     kernel = "triangular", p = 1)
h_opt <- rd_main$bws["h", "left"]

bw_grid <- sort(unique(round(c(h_opt * c(0.5, 0.75, 1, 1.25, 1.5, 2),
                                 3, 5, 7, 10, 12, 15), 1)))

bw_results <- data.table(
  bandwidth = numeric(), coef = numeric(), se = numeric(),
  pvalue = numeric(), n_left = numeric(), n_right = numeric(),
  ci_lower = numeric(), ci_upper = numeric()
)

for (h in bw_grid) {
  tryCatch({
    rd <- rdrobust(union$in_labor_force, union$AGE, c = 62,
                   h = h, kernel = "triangular", p = 1)
    bw_results <- rbind(bw_results, data.table(
      bandwidth = h,
      coef = rd$coef["Conventional", 1],
      se = rd$se["Conventional", 1],
      pvalue = rd$pv["Conventional", 1],
      n_left = rd$N_h[1],
      n_right = rd$N_h[2],
      ci_lower = rd$coef["Conventional", 1] - 1.96 * rd$se["Conventional", 1],
      ci_upper = rd$coef["Conventional", 1] + 1.96 * rd$se["Conventional", 1]
    ))
    cat(sprintf("  h = %5.1f: coef = %7.4f (SE = %6.4f), N = %s + %s\n",
                h, rd$coef["Conventional", 1], rd$se["Conventional", 1],
                format(rd$N_h[1], big.mark = ","), format(rd$N_h[2], big.mark = ",")))
  }, error = function(e) {
    cat(sprintf("  h = %5.1f: ERROR - %s\n", h, e$message))
  })
}

robust_results$bandwidth <- bw_results

## ---- 2. Polynomial Order ----
cat("\n=== Polynomial Order Sensitivity ===\n")

poly_results <- data.table(
  poly_order = integer(), coef = numeric(), se = numeric(),
  pvalue = numeric(), n_left = numeric(), n_right = numeric()
)

for (p in 1:3) {
  tryCatch({
    rd <- rdrobust(union$in_labor_force, union$AGE, c = 62,
                   kernel = "triangular", p = p)
    poly_results <- rbind(poly_results, data.table(
      poly_order = p,
      coef = rd$coef["Conventional", 1],
      se = rd$se["Conventional", 1],
      pvalue = rd$pv["Conventional", 1],
      n_left = rd$N_h[1],
      n_right = rd$N_h[2]
    ))
    cat(sprintf("  p = %d: coef = %7.4f (SE = %6.4f)\n",
                p, rd$coef["Conventional", 1], rd$se["Conventional", 1]))
  }, error = function(e) {
    cat(sprintf("  p = %d: ERROR - %s\n", p, e$message))
  })
}

robust_results$polynomial <- poly_results

## ---- 3. Kernel Choice ----
cat("\n=== Kernel Sensitivity ===\n")

kernel_results <- data.table(
  kernel = character(), coef = numeric(), se = numeric(),
  pvalue = numeric(), n_left = numeric(), n_right = numeric()
)

for (k in c("triangular", "epanechnikov", "uniform")) {
  tryCatch({
    rd <- rdrobust(union$in_labor_force, union$AGE, c = 62, kernel = k, p = 1)
    kernel_results <- rbind(kernel_results, data.table(
      kernel = k,
      coef = rd$coef["Conventional", 1],
      se = rd$se["Conventional", 1],
      pvalue = rd$pv["Conventional", 1],
      n_left = rd$N_h[1],
      n_right = rd$N_h[2]
    ))
    cat(sprintf("  %-15s: coef = %7.4f (SE = %6.4f)\n",
                k, rd$coef["Conventional", 1], rd$se["Conventional", 1]))
  }, error = function(e) {
    cat(sprintf("  %-15s: ERROR - %s\n", k, e$message))
  })
}

robust_results$kernel <- kernel_results

## ---- 4. Donut-Hole RDD ----
cat("\n=== Donut-Hole RDD ===\n")

donut_specs <- list(
  list(excl = 62, label = "Age 62"),
  list(excl = c(60, 65), label = "Ages 60, 65"),
  list(excl = c(60, 65, 70), label = "Ages 60, 65, 70"),
  list(excl = c(60, 62, 65, 70), label = "Ages 60, 62, 65, 70"),
  list(excl = c(61, 62, 63), label = "Ages 61-63 (narrow donut)")
)

donut_results <- data.table(
  excluded = character(), coef = numeric(), se = numeric(),
  pvalue = numeric(), n_left = numeric(), n_right = numeric()
)

for (spec in donut_specs) {
  donut_data <- union[!AGE %in% spec$excl]
  tryCatch({
    rd <- rdrobust(donut_data$in_labor_force, donut_data$AGE, c = 62,
                   kernel = "triangular", p = 1)
    donut_results <- rbind(donut_results, data.table(
      excluded = spec$label,
      coef = rd$coef["Conventional", 1],
      se = rd$se["Conventional", 1],
      pvalue = rd$pv["Conventional", 1],
      n_left = rd$N_h[1],
      n_right = rd$N_h[2]
    ))
    cat(sprintf("  Excl %-25s: coef = %7.4f (SE = %6.4f)\n",
                spec$label, rd$coef["Conventional", 1], rd$se["Conventional", 1]))
  }, error = function(e) {
    cat(sprintf("  Excl %-25s: ERROR\n", spec$label))
  })
}

robust_results$donut <- donut_results

## ---- 5. Literacy-Controlled RDD ----
cat("\n=== Literacy-Controlled RDD ===\n")

resid_model <- lm(in_labor_force ~ literate, data = union)
union[, lfp_resid := resid(resid_model)]

tryCatch({
  rd_ctrl <- rdrobust(union$lfp_resid, union$AGE, c = 62,
                      kernel = "triangular", p = 1)
  robust_results$literacy_controlled <- data.table(
    coef = rd_ctrl$coef["Conventional", 1],
    se = rd_ctrl$se["Conventional", 1],
    pvalue = rd_ctrl$pv["Conventional", 1],
    n_left = rd_ctrl$N_h[1],
    n_right = rd_ctrl$N_h[2]
  )
  cat("  Controlled estimate:", round(rd_ctrl$coef["Conventional", 1], 4),
      "(SE:", round(rd_ctrl$se["Conventional", 1], 4), ")\n")
}, error = function(e) {
  cat("  Literacy-controlled RDD: ERROR -", e$message, "\n")
})

## ---- 6. Placebo Cutoffs ----
cat("\n=== Placebo Cutoffs ===\n")

placebo_ages <- c(50, 52, 55, 57, 59, 64, 66, 68, 72)
placebo_results <- data.table(
  cutoff = integer(), coef = numeric(), se = numeric(),
  pvalue = numeric(), n_left = numeric(), n_right = numeric()
)

for (c_age in placebo_ages) {
  tryCatch({
    rd <- rdrobust(union$in_labor_force, union$AGE, c = c_age,
                   kernel = "triangular", p = 1)
    placebo_results <- rbind(placebo_results, data.table(
      cutoff = c_age,
      coef = rd$coef["Conventional", 1],
      se = rd$se["Conventional", 1],
      pvalue = rd$pv["Conventional", 1],
      n_left = rd$N_h[1],
      n_right = rd$N_h[2]
    ))
    cat(sprintf("  Age %d: coef = %7.4f (SE = %6.4f), p = %.3f %s\n",
                c_age, rd$coef["Conventional", 1], rd$se["Conventional", 1],
                rd$pv["Conventional", 1],
                ifelse(rd$pv["Conventional", 1] < 0.05, " *", "")))
  }, error = function(e) {
    cat(sprintf("  Age %d: ERROR\n", c_age))
  })
}

robust_results$placebo <- placebo_results

## ---- 7. Multi-Cutoff: Age 70 and 75 (Dose-Response) ----
cat("\n=== Multi-Cutoff RDD (Pension Increases at 70 and 75) ===\n")

multi_results <- data.table(
  cutoff = integer(), pension_change = character(),
  coef_union = numeric(), se_union = numeric(), pvalue_union = numeric(),
  coef_confed = numeric(), se_confed = numeric(), pvalue_confed = numeric(),
  coef_did = numeric(), se_did = numeric(), pvalue_did = numeric(),
  n_union_left = numeric(), n_union_right = numeric(),
  n_confed_left = numeric(), n_confed_right = numeric()
)

cutoff_specs <- list(
  list(age = 62, label = "$0 to $12"),
  list(age = 70, label = "$12 to $15"),
  list(age = 75, label = "$15 to $20")
)

for (spec in cutoff_specs) {
  tryCatch({
    rd_u <- rdrobust(union$in_labor_force, union$AGE, c = spec$age,
                      kernel = "triangular", p = 1)
    rd_c <- rdrobust(confed$in_labor_force, confed$AGE, c = spec$age,
                      kernel = "triangular", p = 1)

    tau_d <- rd_u$coef["Conventional", 1] - rd_c$coef["Conventional", 1]
    se_d <- sqrt(rd_u$se["Conventional", 1]^2 + rd_c$se["Conventional", 1]^2)
    p_d <- 2 * pnorm(-abs(tau_d / se_d))

    multi_results <- rbind(multi_results, data.table(
      cutoff = spec$age, pension_change = spec$label,
      coef_union = rd_u$coef["Conventional", 1],
      se_union = rd_u$se["Conventional", 1],
      pvalue_union = rd_u$pv["Conventional", 1],
      coef_confed = rd_c$coef["Conventional", 1],
      se_confed = rd_c$se["Conventional", 1],
      pvalue_confed = rd_c$pv["Conventional", 1],
      coef_did = tau_d, se_did = se_d, pvalue_did = p_d,
      n_union_left = rd_u$N_h[1], n_union_right = rd_u$N_h[2],
      n_confed_left = rd_c$N_h[1], n_confed_right = rd_c$N_h[2]
    ))
    cat(sprintf("  Age %d (%s): Union = %7.4f, Confed = %7.4f, DiD = %7.4f (SE = %6.4f)\n",
                spec$age, spec$label,
                rd_u$coef["Conventional", 1], rd_c$coef["Conventional", 1],
                tau_d, se_d))
  }, error = function(e) {
    cat(sprintf("  Age %d: ERROR\n", spec$age))
  })
}

robust_results$multi_cutoff <- multi_results

## ---- 8. Non-Veteran Placebo ----
cat("\n=== Non-Veteran Placebo ===\n")

all_data <- readRDS(file.path(data_dir, "census_1910_veterans.rds"))
nonvets <- all_data[any_veteran == 0]
cat("Non-veterans:", format(nrow(nonvets), big.mark = ","), "\n")

# Sample for computational efficiency (non-veteran sample may be large)
if (nrow(nonvets) > 500000) {
  set.seed(42)
  nonvets <- nonvets[sample(.N, 500000)]
  cat("Sampled 500,000 for computational efficiency\n")
}

tryCatch({
  rd_nonvet <- rdrobust(nonvets$in_labor_force, nonvets$AGE, c = 62,
                        kernel = "triangular", p = 1)
  robust_results$nonvet_placebo <- data.table(
    coef = rd_nonvet$coef["Conventional", 1],
    se = rd_nonvet$se["Conventional", 1],
    pvalue = rd_nonvet$pv["Conventional", 1],
    n_left = rd_nonvet$N_h[1],
    n_right = rd_nonvet$N_h[2]
  )
  cat("  Non-vet LFP at 62:", round(rd_nonvet$coef["Conventional", 1], 4),
      "(SE:", round(rd_nonvet$se["Conventional", 1], 4), ")\n")
}, error = function(e) cat("  Non-vet placebo: ERROR\n"))

rm(all_data, nonvets)
gc()

## ---- 9. Lee Bounds for Literacy Imbalance ----
cat("\n=== Lee Bounds (Addressing Literacy Imbalance) ===\n")

# Lee (2009) bounds: Trim the group with "excess" observations to bound
# the treatment effect under worst-case selection.
# If literacy is imbalanced at cutoff, we trim accordingly.

# Simple implementation: stratify by literacy, estimate within each stratum
tryCatch({
  rd_lit <- rdrobust(union[literate == 1]$in_labor_force,
                      union[literate == 1]$AGE, c = 62,
                      kernel = "triangular", p = 1)
  rd_illit <- rdrobust(union[literate == 0]$in_labor_force,
                        union[literate == 0]$AGE, c = 62,
                        kernel = "triangular", p = 1)

  n_lit <- sum(union$literate == 1 & union$AGE >= (62 - h_opt) & union$AGE <= (62 + h_opt))
  n_illit <- sum(union$literate == 0 & union$AGE >= (62 - h_opt) & union$AGE <= (62 + h_opt))
  w_lit <- n_lit / (n_lit + n_illit)
  w_illit <- n_illit / (n_lit + n_illit)

  tau_pooled <- w_lit * rd_lit$coef["Conventional", 1] +
                w_illit * rd_illit$coef["Conventional", 1]

  # Bounds: worst case = assign all marginal literate to highest/lowest LFP
  lee_upper <- max(rd_lit$coef["Conventional", 1], rd_illit$coef["Conventional", 1])
  lee_lower <- min(rd_lit$coef["Conventional", 1], rd_illit$coef["Conventional", 1])

  robust_results$lee_bounds <- data.table(
    tau_literate = rd_lit$coef["Conventional", 1],
    se_literate = rd_lit$se["Conventional", 1],
    tau_illiterate = rd_illit$coef["Conventional", 1],
    se_illiterate = rd_illit$se["Conventional", 1],
    tau_reweighted = tau_pooled,
    lee_lower = lee_lower,
    lee_upper = lee_upper,
    n_literate = n_lit,
    n_illiterate = n_illit
  )

  cat("  Literate stratum:", round(rd_lit$coef["Conventional", 1], 4),
      "(SE:", round(rd_lit$se["Conventional", 1], 4), ")\n")
  cat("  Illiterate stratum:", round(rd_illit$coef["Conventional", 1], 4),
      "(SE:", round(rd_illit$se["Conventional", 1], 4), ")\n")
  cat("  Lee bounds: [", round(lee_lower, 4), ",", round(lee_upper, 4), "]\n")
  cat("  Reweighted:", round(tau_pooled, 4), "\n")
}, error = function(e) {
  cat("  Lee bounds: ERROR -", e$message, "\n")
})

## ---- Save all robustness results ----
saveRDS(robust_results, file.path(data_dir, "robust_results.rds"))
cat("\nRobustness checks complete. Results saved.\n")
