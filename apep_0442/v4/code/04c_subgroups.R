## ============================================================================
## 04c_subgroups.R — Subgroup heterogeneity analysis
## Project: The First Retirement Age v3
## ============================================================================

source("code/00_packages.R")

cat("=== SUBGROUP ANALYSIS ===\n\n")

cross <- readRDS(file.path(data_dir, "cross_section_sample.rds"))
cross[, age_1907 := 1907 - birth_year]
cross[, running := age_1907 - 62]

## Helper: run RDD on subset
run_subgroup_rdd <- function(dt, label) {
  if (nrow(dt) < 100) return(NULL)
  fit <- tryCatch(
    rdrobust(dt$lfp_1910, dt$running, c = 0),
    error = function(e) NULL)
  if (is.null(fit)) return(NULL)
  data.table(subgroup = label, N = nrow(dt),
             coef = fit$coef[1], se = fit$se[3], pval = fit$pv[3],
             ci_lo = fit$ci[3, 1], ci_hi = fit$ci[3, 2],
             N_left = fit$N_h[1], N_right = fit$N_h[2])
}

## ---- Define subgroups ----
results <- list()

## 1. By pre-1907 pension status (KEY heterogeneity)
results[["Full sample"]] <- run_subgroup_rdd(cross, "Full sample")

cross[, had_pension_pre := fifelse(!is.na(pen_amt_1900) & pen_amt_1900 > 0, 1L, 0L)]
results[["Had pension (pre-1907)"]] <- run_subgroup_rdd(
  cross[had_pension_pre == 1], "Had pension (pre-1907)")
results[["No pension (pre-1907)"]] <- run_subgroup_rdd(
  cross[had_pension_pre == 0], "No pension (pre-1907)")

## 2. By pension category
for (grp in unique(cross$pension_group)) {
  if (!is.na(grp)) {
    results[[paste0("Pen: ", grp)]] <- run_subgroup_rdd(
      cross[pension_group == grp], paste0("Pen: ", grp))
  }
}

## 3. By literacy
results[["Literate"]] <- run_subgroup_rdd(cross[literate == 1], "Literate")
results[["Illiterate"]] <- run_subgroup_rdd(cross[literate == 0], "Illiterate")

## 4. By nativity
results[["Native-born"]] <- run_subgroup_rdd(cross[native_born == 1], "Native-born")
results[["Foreign-born"]] <- run_subgroup_rdd(cross[native_born == 0], "Foreign-born")

## 5. By occupation in 1900
for (occ in c("Farmer", "Manual/Operative", "Professional", "None/Retired")) {
  dt_sub <- cross[occ_type_1900 == occ]
  results[[paste0("Occ 1900: ", occ)]] <- run_subgroup_rdd(dt_sub, paste0("Occ 1900: ", occ))
}

## 6. By wound status
results[["Wounded"]] <- run_subgroup_rdd(cross[has_wound_pre == 1], "Wounded")
results[["Not wounded"]] <- run_subgroup_rdd(cross[has_wound_pre == 0], "Not wounded")

## 7. By homeownership
results[["Homeowner"]] <- run_subgroup_rdd(cross[homeowner == 1], "Homeowner")
results[["Not homeowner"]] <- run_subgroup_rdd(cross[homeowner == 0], "Not homeowner")

## Combine
sub_dt <- rbindlist(results[!sapply(results, is.null)])
cat("Subgroup results:\n")
print(sub_dt[, .(subgroup, N, coef = round(coef, 4), se = round(se, 4),
                 pval = round(pval, 3))])

## ---- Save ----
saveRDS(sub_dt, file.path(data_dir, "subgroup_results.rds"))
cat("\n=== SUBGROUP ANALYSIS COMPLETE ===\n")
