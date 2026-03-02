## ============================================================
## 03_main_analysis.R — Primary RDD analysis
## First stage, McCrary test, covariate balance, main results
## ============================================================

source("00_packages.R")

data_dir <- "../data"
panel <- fread(file.path(data_dir, "analysis_panel.csv"))

cat("Panel loaded:", nrow(panel), "rows,", uniqueN(panel$ine_code), "municipalities\n")

## ----------------------------------------------------------
## 1. First Stage: Female Councillor Share at Thresholds
## ----------------------------------------------------------

cat("\n=== FIRST STAGE ===\n")

# Collapse to municipality level (average across post-treatment years)
# For 5,000 cutoff: use all post-2007 election data
muni_5k <- panel[pop > 2000 & pop < 8000 & !is.na(female_share),
  .(female_share = mean(female_share, na.rm = TRUE),
    pop = mean(pop, na.rm = TRUE)),
  by = .(ine_code)
]

if (nrow(muni_5k) > 100) {
  cat("\n-- 5,000 cutoff first stage --\n")
  fs_5k <- rdrobust(y = muni_5k$female_share,
                     x = muni_5k$pop,
                     c = 5000,
                     kernel = "triangular",
                     p = 1,
                     bwselect = "mserd")
  cat("  Estimate:", round(fs_5k$coef[1], 4), "\n")
  cat("  SE:", round(fs_5k$se[1], 4), "\n")
  cat("  p-value:", round(fs_5k$pv[1], 4), "\n")
  cat("  Bandwidth:", round(fs_5k$bws[1,1]), "\n")
  cat("  N left:", fs_5k$N_h[1], " N right:", fs_5k$N_h[2], "\n")

  saveRDS(fs_5k, file.path(data_dir, "fs_5k.rds"))
}

# For 3,000 cutoff: use post-2011 election data only
muni_3k <- panel[pop > 1000 & pop < 5000 & election_year >= 2011 &
                  !is.na(female_share),
  .(female_share = mean(female_share, na.rm = TRUE),
    pop = mean(pop, na.rm = TRUE)),
  by = .(ine_code)
]

if (nrow(muni_3k) > 100) {
  cat("\n-- 3,000 cutoff first stage --\n")
  fs_3k <- rdrobust(y = muni_3k$female_share,
                     x = muni_3k$pop,
                     c = 3000,
                     kernel = "triangular",
                     p = 1,
                     bwselect = "mserd")
  cat("  Estimate:", round(fs_3k$coef[1], 4), "\n")
  cat("  SE:", round(fs_3k$se[1], 4), "\n")
  cat("  p-value:", round(fs_3k$pv[1], 4), "\n")
  cat("  Bandwidth:", round(fs_3k$bws[1,1]), "\n")
  cat("  N left:", fs_3k$N_h[1], " N right:", fs_3k$N_h[2], "\n")

  saveRDS(fs_3k, file.path(data_dir, "fs_3k.rds"))
}

## ----------------------------------------------------------
## 2. McCrary Density Test
## ----------------------------------------------------------

cat("\n=== McCrary DENSITY TEST ===\n")

# Test for manipulation of running variable at both cutoffs
if (nrow(muni_5k) > 100) {
  cat("\n-- 5,000 cutoff density test --\n")
  density_5k <- rddensity(X = muni_5k$pop, c = 5000)
  cat("  T-statistic:", round(density_5k$test$t_jk, 3), "\n")
  cat("  p-value:", round(density_5k$test$p_jk, 4), "\n")
  if (density_5k$test$p_jk > 0.05) {
    cat("  PASS: No evidence of density manipulation\n")
  } else {
    cat("  WARNING: Density manipulation detected!\n")
  }
  saveRDS(density_5k, file.path(data_dir, "density_5k.rds"))
}

if (nrow(muni_3k) > 100) {
  cat("\n-- 3,000 cutoff density test --\n")
  density_3k <- rddensity(X = muni_3k$pop, c = 3000)
  cat("  T-statistic:", round(density_3k$test$t_jk, 3), "\n")
  cat("  p-value:", round(density_3k$test$p_jk, 4), "\n")
  if (density_3k$test$p_jk > 0.05) {
    cat("  PASS: No evidence of density manipulation\n")
  } else {
    cat("  WARNING: Density manipulation detected!\n")
  }
  saveRDS(density_3k, file.path(data_dir, "density_3k.rds"))
}

## ----------------------------------------------------------
## 3. Covariate Balance at Thresholds
## ----------------------------------------------------------

cat("\n=== COVARIATE BALANCE ===\n")

# Pre-treatment covariates: total spending per capita, population
# (Test using 2010 data as pre-treatment baseline)
pre_data <- panel[year == 2010 & pop > 2000 & pop < 8000]

if (nrow(pre_data) > 100) {
  balance_vars <- c("spending_pc", "edu_pc", "security_pc", "social_pc")

  for (var in balance_vars) {
    if (var %in% names(pre_data) && sum(!is.na(pre_data[[var]])) > 50) {
      cat("\nBalance test (5,000):", var, "\n")
      bal <- tryCatch({
        rdrobust(y = pre_data[[var]],
                 x = pre_data$pop,
                 c = 5000,
                 kernel = "triangular",
                 p = 1,
                 bwselect = "mserd")
      }, error = function(e) NULL)
      if (!is.null(bal)) {
        cat("  Estimate:", round(bal$coef[1], 2),
            " SE:", round(bal$se[1], 2),
            " p:", round(bal$pv[1], 3), "\n")
      }
    }
  }
}

## ----------------------------------------------------------
## 4. Main RDD Results: Within-Education Shares
## ----------------------------------------------------------

cat("\n=== MAIN RESULTS: WITHIN-EDUCATION BUDGET SHARES ===\n")

# Average across post-treatment years for each municipality
# For 5,000 cutoff
muni_outcomes_5k <- panel[pop > 2000 & pop < 8000 & year >= 2010,
  lapply(.SD, function(x) mean(x, na.rm = TRUE)),
  by = .(ine_code),
  .SDcols = c("pop", grep("^share_", names(panel), value = TRUE),
              "edu_hhi", "edu_pc", "spending_pc", "social_pc",
              "security_pc", "edu_share_total")
]

# Identify available share columns
share_cols <- grep("^share_", names(muni_outcomes_5k), value = TRUE)
cat("Available education subcategories:", paste(share_cols, collapse = ", "), "\n")

# Run RD on each within-education share
results_5k <- list()
for (sc in share_cols) {
  y_vals <- muni_outcomes_5k[[sc]]
  valid <- !is.na(y_vals) & !is.nan(y_vals)

  if (sum(valid) > 100) {
    cat("\n--- 5,000 cutoff:", sc, "---\n")
    rd <- tryCatch({
      rdrobust(y = y_vals[valid],
               x = muni_outcomes_5k$pop[valid],
               c = 5000,
               kernel = "triangular",
               p = 1,
               bwselect = "mserd")
    }, error = function(e) {
      cat("  Error:", e$message, "\n")
      return(NULL)
    })

    if (!is.null(rd)) {
      cat("  Estimate:", round(rd$coef[1], 4),
          " SE:", round(rd$se[1], 4),
          " p:", round(rd$pv[1], 4),
          " BW:", round(rd$bws[1,1]),
          " N:", rd$N_h[1], "+", rd$N_h[2], "\n")
      results_5k[[sc]] <- rd
    }
  }
}

# Also run on aggregate education share (replication of Bagues & Campa null)
cat("\n--- 5,000 cutoff: education share of total spending (aggregate) ---\n")
valid_agg <- !is.na(muni_outcomes_5k$edu_share_total)
if (sum(valid_agg) > 100) {
  rd_agg <- rdrobust(y = muni_outcomes_5k$edu_share_total[valid_agg],
                      x = muni_outcomes_5k$pop[valid_agg],
                      c = 5000,
                      kernel = "triangular",
                      p = 1,
                      bwselect = "mserd")
  cat("  Estimate:", round(rd_agg$coef[1], 4),
      " SE:", round(rd_agg$se[1], 4),
      " p:", round(rd_agg$pv[1], 4), "\n")
  results_5k[["edu_share_total"]] <- rd_agg
}

# Placebo: security spending share
cat("\n--- 5,000 cutoff: PLACEBO - security per capita ---\n")
valid_sec <- !is.na(muni_outcomes_5k$security_pc)
if (sum(valid_sec) > 100) {
  rd_sec <- rdrobust(y = muni_outcomes_5k$security_pc[valid_sec],
                      x = muni_outcomes_5k$pop[valid_sec],
                      c = 5000,
                      kernel = "triangular",
                      p = 1,
                      bwselect = "mserd")
  cat("  Estimate:", round(rd_sec$coef[1], 4),
      " SE:", round(rd_sec$se[1], 4),
      " p:", round(rd_sec$pv[1], 4), "\n")
  results_5k[["security_pc_placebo"]] <- rd_sec
}

# Save results
saveRDS(results_5k, file.path(data_dir, "results_5k.rds"))

## ----------------------------------------------------------
## 5. Repeat for 3,000 cutoff (post-2011 only)
## ----------------------------------------------------------

cat("\n=== RESULTS AT 3,000 CUTOFF ===\n")

muni_outcomes_3k <- panel[pop > 1000 & pop < 5000 & year >= 2011,
  lapply(.SD, function(x) mean(x, na.rm = TRUE)),
  by = .(ine_code),
  .SDcols = c("pop", grep("^share_", names(panel), value = TRUE),
              "edu_hhi", "edu_pc", "spending_pc", "social_pc",
              "security_pc", "edu_share_total")
]

results_3k <- list()
for (sc in share_cols) {
  y_vals <- muni_outcomes_3k[[sc]]
  valid <- !is.na(y_vals) & !is.nan(y_vals)

  if (sum(valid) > 100) {
    cat("\n--- 3,000 cutoff:", sc, "---\n")
    rd <- tryCatch({
      rdrobust(y = y_vals[valid],
               x = muni_outcomes_3k$pop[valid],
               c = 3000,
               kernel = "triangular",
               p = 1,
               bwselect = "mserd")
    }, error = function(e) {
      cat("  Error:", e$message, "\n")
      return(NULL)
    })

    if (!is.null(rd)) {
      cat("  Estimate:", round(rd$coef[1], 4),
          " SE:", round(rd$se[1], 4),
          " p:", round(rd$pv[1], 4),
          " BW:", round(rd$bws[1,1]),
          " N:", rd$N_h[1], "+", rd$N_h[2], "\n")
      results_3k[[sc]] <- rd
    }
  }
}

saveRDS(results_3k, file.path(data_dir, "results_3k.rds"))

cat("\n=== ANALYSIS COMPLETE ===\n")
cat("Results saved to: results_5k.rds, results_3k.rds\n")
