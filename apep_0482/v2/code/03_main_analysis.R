## ============================================================
## 03_main_analysis.R — Primary RDD analysis (v2)
## Election-term-level RDD with election-year running variable
## By-election-cohort first stage, levels + extensive margins
## ============================================================

source("00_packages.R")

data_dir <- "../data"
panel <- fread(file.path(data_dir, "analysis_panel.csv"))
eterm <- fread(file.path(data_dir, "election_term_panel.csv"))

cat("Annual panel loaded:", nrow(panel), "rows\n")
cat("Election-term panel loaded:", nrow(eterm), "rows\n")

## ----------------------------------------------------------
## 1. First Stage: Election-Term Level (PRIMARY)
##    Uses election-year population as running variable
## ----------------------------------------------------------

cat("\n=== FIRST STAGE (Election-Term Level) ===\n")

# 5,000 cutoff: pool all election terms
fs_et_5k_data <- eterm[pop_elec > 2000 & pop_elec < 8000 &
                         !is.na(female_share) & !is.na(pop_elec)]

if (nrow(fs_et_5k_data) > 100) {
  cat("\n-- 5,000 cutoff (election-term) --\n")
  fs_et_5k <- rdrobust(y = fs_et_5k_data$female_share,
                        x = fs_et_5k_data$pop_elec,
                        c = 5000,
                        kernel = "triangular",
                        p = 1,
                        bwselect = "mserd")
  cat("  Estimate:", round(fs_et_5k$coef[1], 4), "\n")
  cat("  SE:", round(fs_et_5k$se[1], 4), "\n")
  cat("  p-value:", round(fs_et_5k$pv[1], 4), "\n")
  cat("  Bandwidth:", round(fs_et_5k$bws[1,1]), "\n")
  cat("  N left:", fs_et_5k$N_h[1], " N right:", fs_et_5k$N_h[2], "\n")
  saveRDS(fs_et_5k, file.path(data_dir, "fs_et_5k.rds"))
}

# 3,000 cutoff: post-2011 terms only
fs_et_3k_data <- eterm[pop_elec > 1000 & pop_elec < 5000 &
                         election_year >= 2011 &
                         !is.na(female_share) & !is.na(pop_elec)]

if (nrow(fs_et_3k_data) > 100) {
  cat("\n-- 3,000 cutoff (election-term) --\n")
  fs_et_3k <- rdrobust(y = fs_et_3k_data$female_share,
                        x = fs_et_3k_data$pop_elec,
                        c = 3000,
                        kernel = "triangular",
                        p = 1,
                        bwselect = "mserd")
  cat("  Estimate:", round(fs_et_3k$coef[1], 4), "\n")
  cat("  SE:", round(fs_et_3k$se[1], 4), "\n")
  cat("  p-value:", round(fs_et_3k$pv[1], 4), "\n")
  cat("  Bandwidth:", round(fs_et_3k$bws[1,1]), "\n")
  cat("  N left:", fs_et_3k$N_h[1], " N right:", fs_et_3k$N_h[2], "\n")
  saveRDS(fs_et_3k, file.path(data_dir, "fs_et_3k.rds"))
}

## ----------------------------------------------------------
## 1b. First Stage: By Election Cohort (KEY NEW ANALYSIS)
##     Shows "shelf life" of quota — decay across elections
## ----------------------------------------------------------

cat("\n=== BY-ELECTION FIRST STAGE ===\n")

fs_by_election <- list()
for (ey in c(2007, 2011, 2015, 2019, 2023)) {
  cohort_data <- eterm[election_year == ey & pop_elec > 2000 &
                        pop_elec < 8000 & !is.na(female_share)]

  if (nrow(cohort_data) > 50) {
    cat("\n-- Election", ey, "(N =", nrow(cohort_data), ") --\n")
    rd <- tryCatch({
      rdrobust(y = cohort_data$female_share,
               x = cohort_data$pop_elec,
               c = 5000,
               kernel = "triangular",
               p = 1,
               bwselect = "mserd")
    }, error = function(e) {
      cat("  Error:", e$message, "\n")
      NULL
    })

    if (!is.null(rd)) {
      cat("  Estimate:", round(rd$coef[1], 4),
          " SE:", round(rd$se[1], 4),
          " p:", round(rd$pv[1], 4),
          " BW:", round(rd$bws[1,1]),
          " N:", rd$N_h[1], "+", rd$N_h[2], "\n")

      fs_by_election[[as.character(ey)]] <- list(
        election_year = ey,
        est = rd$coef[1],
        se = rd$se[1],
        pv = rd$pv[1],
        bw = rd$bws[1,1],
        n_left = rd$N_h[1],
        n_right = rd$N_h[2],
        ci_lower = rd$coef[1] - 1.96 * rd$se[1],
        ci_upper = rd$coef[1] + 1.96 * rd$se[1]
      )
    }
  }
}

saveRDS(fs_by_election, file.path(data_dir, "fs_by_election.rds"))

## ----------------------------------------------------------
## 2. McCrary Density Test (Election-Term Level)
## ----------------------------------------------------------

cat("\n=== McCrary DENSITY TEST (Election-Term) ===\n")

if (nrow(fs_et_5k_data) > 100) {
  cat("\n-- 5,000 cutoff density test --\n")
  density_5k <- rddensity(X = fs_et_5k_data$pop_elec, c = 5000)
  cat("  T-statistic:", round(density_5k$test$t_jk, 3), "\n")
  cat("  p-value:", round(density_5k$test$p_jk, 4), "\n")
  if (density_5k$test$p_jk > 0.05) {
    cat("  PASS: No evidence of density manipulation\n")
  } else {
    cat("  WARNING: Density manipulation detected!\n")
  }
  saveRDS(density_5k, file.path(data_dir, "density_5k.rds"))
}

if (nrow(fs_et_3k_data) > 100) {
  cat("\n-- 3,000 cutoff density test --\n")
  density_3k <- rddensity(X = fs_et_3k_data$pop_elec, c = 3000)
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
## 3. Covariate Balance at Thresholds (Election-Term)
## ----------------------------------------------------------

cat("\n=== COVARIATE BALANCE ===\n")

# Use first available term (2007/2010) as pre-treatment reference
pre_et <- eterm[election_year == 2007 & pop_elec > 2000 & pop_elec < 8000]

if (nrow(pre_et) > 100) {
  balance_vars <- c("spending_pc", "edu_pc", "security_pc", "social_pc")

  for (var in balance_vars) {
    if (var %in% names(pre_et) && sum(!is.na(pre_et[[var]])) > 50) {
      cat("\nBalance test (5,000):", var, "\n")
      bal <- tryCatch({
        rdrobust(y = pre_et[[var]],
                 x = pre_et$pop_elec,
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
## 4. Main RDD Results: Within-Education Shares (Election-Term)
## ----------------------------------------------------------

cat("\n=== MAIN RESULTS: WITHIN-EDUCATION BUDGET SHARES (Election-Term) ===\n")

share_cols <- grep("^share_", names(eterm), value = TRUE)
# Exclude generic 2-digit aggregate
share_cols <- share_cols[share_cols != "share_32"]
cat("Available education subcategories:", paste(share_cols, collapse = ", "), "\n")

# 5,000 cutoff: pool all terms
et_5k <- eterm[pop_elec > 2000 & pop_elec < 8000 & !is.na(pop_elec)]

results_et_5k <- list()
for (sc in share_cols) {
  y_vals <- et_5k[[sc]]
  valid <- !is.na(y_vals) & !is.nan(y_vals)

  if (sum(valid) > 100) {
    cat("\n--- 5,000 cutoff:", sc, "---\n")
    rd <- tryCatch({
      rdrobust(y = y_vals[valid],
               x = et_5k$pop_elec[valid],
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
      results_et_5k[[sc]] <- rd
    }
  }
}

# Aggregate education share
cat("\n--- 5,000 cutoff: education share of total (aggregate) ---\n")
valid_agg <- !is.na(et_5k$edu_share_total)
if (sum(valid_agg) > 100) {
  rd_agg <- rdrobust(y = et_5k$edu_share_total[valid_agg],
                      x = et_5k$pop_elec[valid_agg],
                      c = 5000,
                      kernel = "triangular",
                      p = 1,
                      bwselect = "mserd")
  cat("  Estimate:", round(rd_agg$coef[1], 4),
      " SE:", round(rd_agg$se[1], 4),
      " p:", round(rd_agg$pv[1], 4), "\n")
  results_et_5k[["edu_share_total"]] <- rd_agg
}

# Placebo: security spending
cat("\n--- 5,000 cutoff: PLACEBO - security per capita ---\n")
valid_sec <- !is.na(et_5k$security_pc) & is.finite(et_5k$security_pc)
if (sum(valid_sec) > 100) {
  rd_sec <- tryCatch({
    rdrobust(y = et_5k$security_pc[valid_sec],
             x = et_5k$pop_elec[valid_sec],
             c = 5000,
             kernel = "triangular",
             p = 1,
             bwselect = "mserd")
  }, error = function(e) {
    cat("  Error:", e$message, "\n")
    NULL
  })
  if (!is.null(rd_sec)) {
    cat("  Estimate:", round(rd_sec$coef[1], 4),
        " SE:", round(rd_sec$se[1], 4),
        " p:", round(rd_sec$pv[1], 4), "\n")
    results_et_5k[["security_pc_placebo"]] <- rd_sec
  }
}

saveRDS(results_et_5k, file.path(data_dir, "results_et_5k.rds"))

## ----------------------------------------------------------
## 5. 3,000 Cutoff Results (Election-Term, post-2011)
## ----------------------------------------------------------

cat("\n=== RESULTS AT 3,000 CUTOFF (Election-Term) ===\n")

et_3k <- eterm[pop_elec > 1000 & pop_elec < 5000 &
                election_year >= 2011 & !is.na(pop_elec)]

results_et_3k <- list()
for (sc in share_cols) {
  y_vals <- et_3k[[sc]]
  valid <- !is.na(y_vals) & !is.nan(y_vals)

  if (sum(valid) > 100) {
    cat("\n--- 3,000 cutoff:", sc, "---\n")
    rd <- tryCatch({
      rdrobust(y = y_vals[valid],
               x = et_3k$pop_elec[valid],
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
      results_et_3k[[sc]] <- rd
    }
  }
}

saveRDS(results_et_3k, file.path(data_dir, "results_et_3k.rds"))

## ----------------------------------------------------------
## 6. Levels: EUR per Capita by Education Subcategory
## ----------------------------------------------------------

cat("\n=== LEVELS: EUR PER CAPITA BY SUBCATEGORY ===\n")

level_cols <- grep("^edu_pc_", names(et_5k), value = TRUE)
cat("Level outcome columns:", paste(level_cols, collapse = ", "), "\n")

results_levels_5k <- list()
for (lc in level_cols) {
  y_vals <- et_5k[[lc]]
  valid <- !is.na(y_vals) & !is.nan(y_vals) & is.finite(y_vals)

  if (sum(valid) > 100) {
    cat("\n--- 5,000 cutoff (levels):", lc, "---\n")
    rd <- tryCatch({
      rdrobust(y = y_vals[valid],
               x = et_5k$pop_elec[valid],
               c = 5000,
               kernel = "triangular",
               p = 1,
               bwselect = "mserd")
    }, error = function(e) {
      cat("  Error:", e$message, "\n")
      return(NULL)
    })

    if (!is.null(rd)) {
      cat("  Estimate:", round(rd$coef[1], 2),
          " SE:", round(rd$se[1], 2),
          " p:", round(rd$pv[1], 4), "\n")
      results_levels_5k[[lc]] <- rd
    }
  }
}

# Total education per capita
cat("\n--- 5,000 cutoff (levels): total edu_pc ---\n")
valid_epc <- !is.na(et_5k$edu_pc) & is.finite(et_5k$edu_pc)
if (sum(valid_epc) > 100) {
  rd_epc <- rdrobust(y = et_5k$edu_pc[valid_epc],
                      x = et_5k$pop_elec[valid_epc],
                      c = 5000,
                      kernel = "triangular",
                      p = 1,
                      bwselect = "mserd")
  cat("  Estimate:", round(rd_epc$coef[1], 2),
      " SE:", round(rd_epc$se[1], 2),
      " p:", round(rd_epc$pv[1], 4), "\n")
  results_levels_5k[["edu_pc_total"]] <- rd_epc
}

saveRDS(results_levels_5k, file.path(data_dir, "results_levels_5k.rds"))

## ----------------------------------------------------------
## 7. Extensive Margin: Any Spending in Subcategory
## ----------------------------------------------------------

cat("\n=== EXTENSIVE MARGIN: POSITIVE SPENDING INDICATOR ===\n")

ext_cols <- grep("^has_", names(et_5k), value = TRUE)
cat("Extensive margin columns:", paste(ext_cols, collapse = ", "), "\n")

results_extensive_5k <- list()
for (ec in ext_cols) {
  y_vals <- et_5k[[ec]]
  valid <- !is.na(y_vals)

  if (sum(valid) > 100) {
    cat("\n--- 5,000 cutoff (extensive):", ec, "---\n")
    rd <- tryCatch({
      rdrobust(y = y_vals[valid],
               x = et_5k$pop_elec[valid],
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
          " p:", round(rd$pv[1], 4), "\n")
      results_extensive_5k[[ec]] <- rd
    }
  }
}

saveRDS(results_extensive_5k, file.path(data_dir, "results_extensive_5k.rds"))

## ----------------------------------------------------------
## 8. Backward Compatibility: Averaged Running Variable
##    (Municipality-level, as in v1)
## ----------------------------------------------------------

cat("\n=== BACKWARD COMPAT: AVERAGED RUNNING VARIABLE ===\n")

muni_5k <- panel[pop > 2000 & pop < 8000 & !is.na(female_share),
  .(female_share = mean(female_share, na.rm = TRUE),
    pop = mean(pop, na.rm = TRUE)),
  by = .(ine_code)
]

if (nrow(muni_5k) > 100) {
  cat("\n-- 5,000 cutoff (averaged pop) --\n")
  fs_5k <- rdrobust(y = muni_5k$female_share,
                     x = muni_5k$pop,
                     c = 5000,
                     kernel = "triangular",
                     p = 1,
                     bwselect = "mserd")
  cat("  Estimate:", round(fs_5k$coef[1], 4), "\n")
  cat("  SE:", round(fs_5k$se[1], 4), "\n")
  cat("  p-value:", round(fs_5k$pv[1], 4), "\n")
  saveRDS(fs_5k, file.path(data_dir, "fs_5k.rds"))
}

muni_3k <- panel[pop > 1000 & pop < 5000 & election_year >= 2011 &
                  !is.na(female_share),
  .(female_share = mean(female_share, na.rm = TRUE),
    pop = mean(pop, na.rm = TRUE)),
  by = .(ine_code)
]

if (nrow(muni_3k) > 100) {
  cat("\n-- 3,000 cutoff (averaged pop) --\n")
  fs_3k <- rdrobust(y = muni_3k$female_share,
                     x = muni_3k$pop,
                     c = 3000,
                     kernel = "triangular",
                     p = 1,
                     bwselect = "mserd")
  cat("  Estimate:", round(fs_3k$coef[1], 4), "\n")
  cat("  SE:", round(fs_3k$se[1], 4), "\n")
  cat("  p-value:", round(fs_3k$pv[1], 4), "\n")
  saveRDS(fs_3k, file.path(data_dir, "fs_3k.rds"))
}

# Main results with averaged running variable (for comparison table)
muni_outcomes_5k <- panel[pop > 2000 & pop < 8000 & year >= 2010,
  lapply(.SD, function(x) mean(x, na.rm = TRUE)),
  by = .(ine_code),
  .SDcols = c("pop", share_cols, "edu_hhi", "edu_pc", "spending_pc",
              "social_pc", "security_pc", "edu_share_total")
]

results_5k <- list()
for (sc in share_cols) {
  y_vals <- muni_outcomes_5k[[sc]]
  valid <- !is.na(y_vals) & !is.nan(y_vals)
  if (sum(valid) > 100) {
    rd <- tryCatch(
      rdrobust(y = y_vals[valid], x = muni_outcomes_5k$pop[valid],
               c = 5000, kernel = "triangular", p = 1, bwselect = "mserd"),
      error = function(e) NULL)
    if (!is.null(rd)) results_5k[[sc]] <- rd
  }
}
# Aggregate
valid_agg2 <- !is.na(muni_outcomes_5k$edu_share_total)
if (sum(valid_agg2) > 100) {
  rd_agg2 <- rdrobust(y = muni_outcomes_5k$edu_share_total[valid_agg2],
                       x = muni_outcomes_5k$pop[valid_agg2],
                       c = 5000, kernel = "triangular", p = 1, bwselect = "mserd")
  results_5k[["edu_share_total"]] <- rd_agg2
}
saveRDS(results_5k, file.path(data_dir, "results_5k.rds"))

# 3k averaged
muni_outcomes_3k <- panel[pop > 1000 & pop < 5000 & year >= 2011,
  lapply(.SD, function(x) mean(x, na.rm = TRUE)),
  by = .(ine_code),
  .SDcols = c("pop", share_cols, "edu_hhi", "edu_pc", "spending_pc",
              "social_pc", "security_pc", "edu_share_total")
]
results_3k <- list()
for (sc in share_cols) {
  y_vals <- muni_outcomes_3k[[sc]]
  valid <- !is.na(y_vals) & !is.nan(y_vals)
  if (sum(valid) > 100) {
    rd <- tryCatch(
      rdrobust(y = y_vals[valid], x = muni_outcomes_3k$pop[valid],
               c = 3000, kernel = "triangular", p = 1, bwselect = "mserd"),
      error = function(e) NULL)
    if (!is.null(rd)) results_3k[[sc]] <- rd
  }
}
saveRDS(results_3k, file.path(data_dir, "results_3k.rds"))

cat("\n=== ANALYSIS COMPLETE ===\n")
