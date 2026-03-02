## ============================================================================
## 04_robustness.R — Robustness checks for the age-62 pension RDD
## Project: The First Retirement Age (apep_0442)
## ============================================================================

source("code/00_packages.R")

union <- readRDS(file.path(data_dir, "union_veterans.rds"))
confed <- readRDS(file.path(data_dir, "confed_veterans.rds"))

robust_results <- list()

## ---- 1. Bandwidth Sensitivity ----
cat("=== Bandwidth Sensitivity ===\n")

# Get optimal bandwidth from main specification
rd_main <- rdrobust(union$in_labor_force, union$AGE, c = 62,
                     kernel = "triangular", p = 1)
h_opt <- rd_main$bws["h", "left"]

bw_grid <- c(h_opt * 0.5, h_opt * 0.75, h_opt, h_opt * 1.25, h_opt * 1.5, h_opt * 2)
bw_grid <- sort(unique(round(bw_grid, 1)))

bw_results <- data.table(
  bandwidth = numeric(),
  coef = numeric(),
  se = numeric(),
  pvalue = numeric(),
  n_left = numeric(),
  n_right = numeric()
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
      n_right = rd$N_h[2]
    ))
    cat(sprintf("  h = %5.1f: coef = %7.4f (SE = %6.4f), N = %d + %d\n",
                h, rd$coef["Conventional", 1], rd$se["Conventional", 1],
                rd$N_h[1], rd$N_h[2]))
  }, error = function(e) {
    cat(sprintf("  h = %5.1f: ERROR - %s\n", h, e$message))
  })
}

robust_results$bandwidth <- bw_results

## ---- 2. Polynomial Order ----
cat("\n=== Polynomial Order Sensitivity ===\n")

poly_results <- data.table(
  poly_order = integer(),
  coef = numeric(),
  se = numeric(),
  pvalue = numeric()
)

for (p in 1:2) {
  tryCatch({
    rd <- rdrobust(union$in_labor_force, union$AGE, c = 62,
                   kernel = "triangular", p = p)
    poly_results <- rbind(poly_results, data.table(
      poly_order = p,
      coef = rd$coef["Conventional", 1],
      se = rd$se["Conventional", 1],
      pvalue = rd$pv["Conventional", 1]
    ))
    cat(sprintf("  p = %d: coef = %7.4f (SE = %6.4f), p-val = %.3f\n",
                p, rd$coef["Conventional", 1], rd$se["Conventional", 1],
                rd$pv["Conventional", 1]))
  }, error = function(e) {
    cat(sprintf("  p = %d: ERROR - %s\n", p, e$message))
  })
}

robust_results$polynomial <- poly_results

## ---- 3. Kernel Choice ----
cat("\n=== Kernel Sensitivity ===\n")

kernel_results <- data.table(
  kernel = character(),
  coef = numeric(),
  se = numeric(),
  pvalue = numeric()
)

for (k in c("triangular", "epanechnikov", "uniform")) {
  tryCatch({
    rd <- rdrobust(union$in_labor_force, union$AGE, c = 62,
                   kernel = k, p = 1)
    kernel_results <- rbind(kernel_results, data.table(
      kernel = k,
      coef = rd$coef["Conventional", 1],
      se = rd$se["Conventional", 1],
      pvalue = rd$pv["Conventional", 1]
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

donut_results <- data.table(
  excluded = character(),
  coef = numeric(),
  se = numeric(),
  pvalue = numeric(),
  n_eff = integer()
)

# Donut 1: Exclude exact age 62
donut1 <- union[AGE != 62]
tryCatch({
  rd <- rdrobust(donut1$in_labor_force, donut1$AGE, c = 62,
                 kernel = "triangular", p = 1)
  donut_results <- rbind(donut_results, data.table(
    excluded = "Age 62",
    coef = rd$coef["Conventional", 1],
    se = rd$se["Conventional", 1],
    pvalue = rd$pv["Conventional", 1],
    n_eff = sum(rd$N_h)
  ))
  cat("  Excl age 62:", round(rd$coef["Conventional", 1], 4), "\n")
}, error = function(e) cat("  Excl age 62: ERROR\n"))

# Donut 2: Exclude ages 60 and 65 (heaping ages)
donut2 <- union[!AGE %in% c(60, 65)]
tryCatch({
  rd <- rdrobust(donut2$in_labor_force, donut2$AGE, c = 62,
                 kernel = "triangular", p = 1)
  donut_results <- rbind(donut_results, data.table(
    excluded = "Ages 60, 65",
    coef = rd$coef["Conventional", 1],
    se = rd$se["Conventional", 1],
    pvalue = rd$pv["Conventional", 1],
    n_eff = sum(rd$N_h)
  ))
  cat("  Excl 60,65:", round(rd$coef["Conventional", 1], 4), "\n")
}, error = function(e) cat("  Excl 60,65: ERROR\n"))

# Donut 3: Exclude all round ages (60, 65, 70)
donut3 <- union[!AGE %in% c(60, 65, 70)]
tryCatch({
  rd <- rdrobust(donut3$in_labor_force, donut3$AGE, c = 62,
                 kernel = "triangular", p = 1)
  donut_results <- rbind(donut_results, data.table(
    excluded = "Ages 60, 65, 70",
    coef = rd$coef["Conventional", 1],
    se = rd$se["Conventional", 1],
    pvalue = rd$pv["Conventional", 1],
    n_eff = sum(rd$N_h)
  ))
  cat("  Excl 60,65,70:", round(rd$coef["Conventional", 1], 4), "\n")
}, error = function(e) cat("  Excl 60,65,70: ERROR\n"))

robust_results$donut <- donut_results

## ---- 4b. Literacy-Controlled RDD ----
cat("\n=== Literacy-Controlled RDD ===\n")
# Residualize LFP on literacy to address concern that literacy imbalance drives results
resid_model <- lm(in_labor_force ~ literate, data = union)
union[, lfp_resid := resid(resid_model)]

tryCatch({
  rd_ctrl <- rdrobust(union$lfp_resid, union$AGE, c = 62,
                      kernel = "triangular", p = 1)
  robust_results$literacy_controlled <- data.table(
    coef = rd_ctrl$coef["Conventional", 1],
    se = rd_ctrl$se["Conventional", 1],
    pvalue = rd_ctrl$pv["Conventional", 1],
    n_eff = sum(rd_ctrl$N_h),
    bw_left = rd_ctrl$bws["h", "left"],
    bw_right = rd_ctrl$bws["h", "right"]
  )
  cat("  Controlled RDD estimate:", round(rd_ctrl$coef["Conventional", 1], 4), "\n")
  cat("  SE:", round(rd_ctrl$se["Conventional", 1], 4), "\n")
  cat("  P-value:", round(rd_ctrl$pv["Conventional", 1], 4), "\n")
}, error = function(e) {
  cat("  Literacy-controlled RDD: ERROR -", e$message, "\n")
})

## ---- 5. Placebo Cutoffs ----
cat("\n=== Placebo Cutoffs ===\n")

placebo_ages <- c(55, 57, 59, 64, 66, 68)
placebo_results <- data.table(
  cutoff = integer(),
  coef = numeric(),
  se = numeric(),
  pvalue = numeric()
)

for (c_age in placebo_ages) {
  tryCatch({
    rd <- rdrobust(union$in_labor_force, union$AGE, c = c_age,
                   kernel = "triangular", p = 1)
    placebo_results <- rbind(placebo_results, data.table(
      cutoff = c_age,
      coef = rd$coef["Conventional", 1],
      se = rd$se["Conventional", 1],
      pvalue = rd$pv["Conventional", 1]
    ))
    cat(sprintf("  Age %d: coef = %7.4f (SE = %6.4f), p = %.3f %s\n",
                c_age, rd$coef["Conventional", 1], rd$se["Conventional", 1],
                rd$pv["Conventional", 1],
                ifelse(rd$pv["Conventional", 1] < 0.05, " *** SIGNIFICANT", "")))
  }, error = function(e) {
    cat(sprintf("  Age %d: ERROR - %s\n", c_age, e$message))
  })
}

robust_results$placebo <- placebo_results

## ---- 6. Multi-Cutoff: Age 70 and 75 ----
cat("\n=== Multi-Cutoff RDD (Pension Increases at 70 and 75) ===\n")

multi_results <- data.table(
  cutoff = integer(),
  pension_amount = character(),
  coef = numeric(),
  se = numeric(),
  pvalue = numeric(),
  n_eff = numeric()
)

# Age 70: pension increases from $12 to $15/month
tryCatch({
  rd70 <- rdrobust(union$in_labor_force, union$AGE, c = 70,
                    kernel = "triangular", p = 1)
  multi_results <- rbind(multi_results, data.table(
    cutoff = 70L, pension_amount = "$12 to $15",
    coef = rd70$coef["Conventional", 1],
    se = rd70$se["Conventional", 1],
    pvalue = rd70$pv["Conventional", 1],
    n_eff = sum(rd70$N_h)
  ))
  cat("  Age 70 ($12→$15):", round(rd70$coef["Conventional", 1], 4), "\n")
}, error = function(e) cat("  Age 70: ERROR\n"))

# Age 75: pension increases from $15 to $20/month
tryCatch({
  rd75 <- rdrobust(union$in_labor_force, union$AGE, c = 75,
                    kernel = "triangular", p = 1)
  multi_results <- rbind(multi_results, data.table(
    cutoff = 75L, pension_amount = "$15 to $20",
    coef = rd75$coef["Conventional", 1],
    se = rd75$se["Conventional", 1],
    pvalue = rd75$pv["Conventional", 1],
    n_eff = sum(rd75$N_h)
  ))
  cat("  Age 75 ($15→$20):", round(rd75$coef["Conventional", 1], 4), "\n")
}, error = function(e) cat("  Age 75: ERROR\n"))

robust_results$multi_cutoff <- multi_results

## ---- 7. Non-Veteran Placebo ----
cat("\n=== Non-Veteran Placebo (age 62 for non-veterans) ===\n")

all_data <- readRDS(file.path(data_dir, "census_1910_veterans.rds"))
nonvets <- all_data[any_veteran == 0]

if (nrow(nonvets) > 1000) {
  # Sample if too large (non-veterans are the vast majority)
  if (nrow(nonvets) > 100000) {
    set.seed(42)
    nonvets <- nonvets[sample(.N, 100000)]
  }

  tryCatch({
    rd_nonvet <- rdrobust(nonvets$in_labor_force, nonvets$AGE, c = 62,
                          kernel = "triangular", p = 1)
    cat("  Non-vet LFP at 62:", round(rd_nonvet$coef["Conventional", 1], 4), "\n")
    cat("  SE:", round(rd_nonvet$se["Conventional", 1], 4), "\n")
    cat("  P-value:", round(rd_nonvet$pv["Conventional", 1], 4), "\n")

    robust_results$nonvet_placebo <- data.table(
      coef = rd_nonvet$coef["Conventional", 1],
      se = rd_nonvet$se["Conventional", 1],
      pvalue = rd_nonvet$pv["Conventional", 1],
      n_eff = sum(rd_nonvet$N_h)
    )
  }, error = function(e) cat("  Non-vet placebo: ERROR\n"))
}

rm(all_data, nonvets)
gc()

## ---- 8. Subgroup Analysis ----
cat("\n=== Subgroup Analysis ===\n")

union[, white := as.integer(RACE == 1)]

subgroups <- list(
  "White veterans" = union[white == 1],
  "Non-white veterans" = union[white == 0],
  "Urban" = union[urban == 1],
  "Rural" = union[urban == 0],
  "Literate" = union[literate == 1],
  "Illiterate" = union[literate == 0]
)

subgroup_results <- data.table(
  subgroup = character(),
  n = integer(),
  coef = numeric(),
  se = numeric(),
  pvalue = numeric()
)

for (sg_name in names(subgroups)) {
  sg <- subgroups[[sg_name]]
  if (nrow(sg) < 50) {
    cat(sprintf("  %-25s: Too few observations (%d)\n", sg_name, nrow(sg)))
    next
  }

  tryCatch({
    rd <- rdrobust(sg$in_labor_force, sg$AGE, c = 62,
                   kernel = "triangular", p = 1)
    subgroup_results <- rbind(subgroup_results, data.table(
      subgroup = sg_name,
      n = nrow(sg),
      coef = rd$coef["Conventional", 1],
      se = rd$se["Conventional", 1],
      pvalue = rd$pv["Conventional", 1]
    ))
    cat(sprintf("  %-25s (N=%s): coef = %7.4f (SE = %6.4f)\n",
                sg_name, format(nrow(sg), big.mark = ","),
                rd$coef["Conventional", 1], rd$se["Conventional", 1]))
  }, error = function(e) {
    cat(sprintf("  %-25s: ERROR - %s\n", sg_name, e$message))
  })
}

robust_results$subgroups <- subgroup_results

## ---- Save all robustness results ----
saveRDS(robust_results, file.path(data_dir, "robust_results.rds"))
cat("\nRobustness checks complete. Results saved.\n")
