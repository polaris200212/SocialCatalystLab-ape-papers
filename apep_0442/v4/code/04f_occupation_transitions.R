## ============================================================================
## 04f_occupation_transitions.R — Occupation flows 1900 → 1910
## Project: The First Retirement Age v3
## ============================================================================

source("code/00_packages.R")

cat("=== OCCUPATION TRANSITIONS ===\n\n")

panel <- readRDS(file.path(data_dir, "panel_sample.rds"))
panel[, age_1907 := 1907 - birth_year]
panel[, running := age_1907 - 62]
panel[, above_62 := as.integer(age_1907 >= 62)]

## =========================================================================
## 1. TRANSITION MATRIX
## =========================================================================
cat("--- 1. OCCUPATION TRANSITION MATRIX ---\n")
trans_mat <- panel[, .N, by = .(occ_type_1900, occ_type_1910)]
trans_mat <- dcast(trans_mat, occ_type_1900 ~ occ_type_1910, value.var = "N", fill = 0)
print(trans_mat)

## By pension eligibility
cat("\nBelow 62 in 1910:\n")
trans_below <- panel[above_62 == 0, .N, by = .(occ_type_1900, occ_type_1910)]
trans_below <- dcast(trans_below, occ_type_1900 ~ occ_type_1910, value.var = "N", fill = 0)
print(trans_below)

cat("\nAbove 62 in 1910:\n")
trans_above <- panel[above_62 == 1, .N, by = .(occ_type_1900, occ_type_1910)]
trans_above <- dcast(trans_above, occ_type_1900 ~ occ_type_1910, value.var = "N", fill = 0)
print(trans_above)

## =========================================================================
## 2. OCCUPATIONAL DOWNGRADING
## =========================================================================
cat("\n--- 2. OCCUPATIONAL DOWNGRADING ---\n")

## Define downgrading: moving from skilled to less skilled work
occ_rank <- c("Professional" = 4, "Clerical/Sales/Manager" = 3,
              "Farmer" = 2, "Manual/Operative" = 2, "Farm laborer" = 1,
              "None/Retired" = 0)

panel[, occ_rank_1900 := occ_rank[occ_type_1900]]
panel[, occ_rank_1910 := occ_rank[occ_type_1910]]
panel[, downgraded := as.integer(occ_rank_1910 < occ_rank_1900)]
panel[, full_exit := as.integer(occ_rank_1900 > 0 & occ_rank_1910 == 0)]

cat("Full exit rate (had occ 1900, none 1910):", round(mean(panel$full_exit, na.rm=TRUE), 3), "\n")
cat("Downgrading rate:", round(mean(panel$downgraded, na.rm=TRUE), 3), "\n")

## RDD on full exit
rdd_exit <- tryCatch(rdrobust(panel$full_exit, panel$running, c = 0),
                     error = function(e) NULL)
if (!is.null(rdd_exit))
  cat(sprintf("Full exit RDD: coef=%.4f, se=%.4f, p=%.3f\n",
              rdd_exit$coef[1], rdd_exit$se[3], rdd_exit$pv[3]))

## RDD on downgrading
rdd_down <- tryCatch(rdrobust(panel$downgraded, panel$running, c = 0),
                     error = function(e) NULL)
if (!is.null(rdd_down))
  cat(sprintf("Downgrading RDD: coef=%.4f, se=%.4f, p=%.3f\n",
              rdd_down$coef[1], rdd_down$se[3], rdd_down$pv[3]))

## =========================================================================
## 3. SPECIFIC OCCUPATION EXIT RATES
## =========================================================================
cat("\n--- 3. EXIT RATES BY 1900 OCCUPATION ---\n")
exit_by_occ <- panel[occ_type_1900 != "None/Retired",
                     .(exit_rate = mean(full_exit, na.rm = TRUE),
                       mean_lfp_1910 = mean(lfp_1910, na.rm = TRUE),
                       N = .N),
                     by = occ_type_1900][order(-N)]
print(exit_by_occ)

## RDD by 1900 occupation
cat("\nRDD by 1900 occupation:\n")
occ_rdd_results <- list()
for (occ in c("Farmer", "Manual/Operative", "Professional")) {
  dt_sub <- panel[occ_type_1900 == occ]
  if (nrow(dt_sub) >= 100) {
    fit <- tryCatch(rdrobust(dt_sub$lfp_1910, dt_sub$running, c = 0),
                    error = function(e) NULL)
    if (!is.null(fit)) {
      occ_rdd_results[[occ]] <- data.table(
        occupation = occ, coef = fit$coef[1], se = fit$se[3], pval = fit$pv[3],
        N_left = fit$N_h[1], N_right = fit$N_h[2])
      cat(sprintf("  %s: coef=%.4f, se=%.4f, p=%.3f\n",
                  occ, fit$coef[1], fit$se[3], fit$pv[3]))
    }
  }
}

## =========================================================================
## SAVE
## =========================================================================
occ_results <- list(
  transition_all = trans_mat,
  transition_below = trans_below,
  transition_above = trans_above,
  exit_by_occ = exit_by_occ,
  rdd_exit = rdd_exit,
  rdd_downgrading = rdd_down,
  rdd_by_occ = rbindlist(occ_rdd_results)
)
saveRDS(occ_results, file.path(data_dir, "occupation_results.rds"))
cat("\n=== OCCUPATION TRANSITIONS COMPLETE ===\n")
