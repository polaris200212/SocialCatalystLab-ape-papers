## ============================================================
## 04_robustness.R — Robustness checks (v2)
## BH-adjusted q-values, MDE, election-year vs averaged comparison,
## donut RDD, bandwidth sensitivity, placebos, LRSAL heterogeneity
## ============================================================

source("00_packages.R")

data_dir <- "../data"
panel <- fread(file.path(data_dir, "analysis_panel.csv"))
eterm <- fread(file.path(data_dir, "election_term_panel.csv"))

cat("Annual panel loaded:", nrow(panel), "rows\n")
cat("Election-term panel loaded:", nrow(eterm), "rows\n")

share_cols <- grep("^share_3[2-9][0-9]", names(eterm), value = TRUE)

## ----------------------------------------------------------
## 1. Donut RDD (Election-Term Level)
## ----------------------------------------------------------

cat("\n=== DONUT RDD ===\n")

et_5k <- eterm[pop_elec > 2000 & pop_elec < 8000 & !is.na(pop_elec)]

donut_results <- list()
for (radius in c(100, 200)) {
  cat("\n-- Donut radius:", radius, "--\n")
  et_donut <- et_5k[abs(pop_elec - 5000) > radius]

  for (sc in share_cols[1:min(4, length(share_cols))]) {
    valid <- !is.na(et_donut[[sc]])
    if (sum(valid) > 50) {
      rd <- tryCatch(
        rdrobust(y = et_donut[[sc]][valid],
                 x = et_donut$pop_elec[valid],
                 c = 5000, kernel = "triangular",
                 p = 1, bwselect = "mserd"),
        error = function(e) NULL
      )
      if (!is.null(rd)) {
        cat("  ", sc, ": est=", round(rd$coef[1], 4),
            " p=", round(rd$pv[1], 3), "\n")
        donut_results[[paste(radius, sc)]] <- list(
          radius = radius, variable = sc,
          est = rd$coef[1], se = rd$se[1], pv = rd$pv[1],
          bw = rd$bws[1,1], n_left = rd$N_h[1], n_right = rd$N_h[2]
        )
      }
    }
  }
}

saveRDS(donut_results, file.path(data_dir, "donut_results.rds"))

## ----------------------------------------------------------
## 2. Bandwidth Sensitivity (Election-Term)
## ----------------------------------------------------------

cat("\n=== BANDWIDTH SENSITIVITY ===\n")

bw_results <- list()

main_sc <- share_cols[1]
valid <- !is.na(et_5k[[main_sc]])
if (sum(valid) > 50) {
  main_rd <- rdrobust(y = et_5k[[main_sc]][valid],
                       x = et_5k$pop_elec[valid],
                       c = 5000, kernel = "triangular",
                       p = 1, bwselect = "mserd")
  opt_bw <- main_rd$bws[1,1]

  for (mult in c(0.5, 0.75, 1.0, 1.25, 1.5, 2.0)) {
    bw <- opt_bw * mult
    rd <- tryCatch(
      rdrobust(y = et_5k[[main_sc]][valid],
               x = et_5k$pop_elec[valid],
               c = 5000, kernel = "triangular",
               p = 1, h = bw),
      error = function(e) NULL
    )
    if (!is.null(rd)) {
      cat("  BW=", round(bw), " (", mult, "x opt): est=",
          round(rd$coef[1], 4), " p=", round(rd$pv[1], 3), "\n")
      bw_results[[as.character(mult)]] <- list(
        multiplier = mult, bw = bw,
        est = rd$coef[1], se = rd$se[1], pv = rd$pv[1]
      )
    }
  }
}

saveRDS(bw_results, file.path(data_dir, "bw_results.rds"))

## ----------------------------------------------------------
## 3. Pre-Treatment Placebo (Election-Term)
## ----------------------------------------------------------

cat("\n=== PRE-TREATMENT PLACEBO ===\n")

# 3,000 cutoff: 2010 data is pre-treatment for the 2011 introduction
pre_3k <- panel[pop > 1000 & pop < 5000 & year == 2010,
  lapply(.SD, function(x) mean(x, na.rm = TRUE)),
  by = .(ine_code),
  .SDcols = c("pop", share_cols, "edu_share_total")
]

placebo_results <- list()
for (sc in share_cols) {
  valid <- !is.na(pre_3k[[sc]])
  if (sum(valid) > 50) {
    rd <- tryCatch(
      rdrobust(y = pre_3k[[sc]][valid],
               x = pre_3k$pop[valid],
               c = 3000, kernel = "triangular",
               p = 1, bwselect = "mserd"),
      error = function(e) NULL
    )
    if (!is.null(rd)) {
      cat("  Pre-treatment (3,000):", sc, ": est=", round(rd$coef[1], 4),
          " p=", round(rd$pv[1], 3), "\n")
      placebo_results[[sc]] <- list(
        variable = sc, est = rd$coef[1],
        se = rd$se[1], pv = rd$pv[1]
      )
    }
  }
}

saveRDS(placebo_results, file.path(data_dir, "placebo_results.rds"))

## ----------------------------------------------------------
## 4. Placebo Cutoffs (4,000 and 6,000)
## ----------------------------------------------------------

cat("\n=== PLACEBO CUTOFFS ===\n")

et_broad <- eterm[pop_elec > 1000 & pop_elec < 9000 & !is.na(pop_elec)]

placebo_cutoff_results <- list()
for (cutoff in c(4000, 6000)) {
  cat("\n-- Placebo cutoff:", cutoff, "--\n")
  for (sc in share_cols[1:min(3, length(share_cols))]) {
    valid <- !is.na(et_broad[[sc]])
    if (sum(valid) > 50) {
      rd <- tryCatch(
        rdrobust(y = et_broad[[sc]][valid],
                 x = et_broad$pop_elec[valid],
                 c = cutoff, kernel = "triangular",
                 p = 1, bwselect = "mserd"),
        error = function(e) NULL
      )
      if (!is.null(rd)) {
        cat("  ", sc, ": est=", round(rd$coef[1], 4),
            " p=", round(rd$pv[1], 3), "\n")
        placebo_cutoff_results[[paste(cutoff, sc)]] <- list(
          cutoff = cutoff, variable = sc,
          est = rd$coef[1], se = rd$se[1], pv = rd$pv[1]
        )
      }
    }
  }
}

saveRDS(placebo_cutoff_results, file.path(data_dir, "placebo_cutoff_results.rds"))

## ----------------------------------------------------------
## 5. Sub-period First Stage (Pre/Post LRSAL)
## ----------------------------------------------------------

cat("\n=== SUB-PERIOD FIRST STAGE ===\n")

fs_subperiod <- list()
for (period in c("pre_lrsal", "post_lrsal")) {
  ey_range <- if (period == "pre_lrsal") c(2007, 2011) else c(2015, 2019, 2023)

  sub_data <- eterm[election_year %in% ey_range &
                     pop_elec > 2000 & pop_elec < 8000 &
                     !is.na(female_share)]

  cat("\n--", period, "(N=", nrow(sub_data), ") --\n")
  if (nrow(sub_data) > 100) {
    rd <- tryCatch(
      rdrobust(y = sub_data$female_share,
               x = sub_data$pop_elec,
               c = 5000, kernel = "triangular",
               p = 1, bwselect = "mserd"),
      error = function(e) NULL
    )
    if (!is.null(rd)) {
      cat("  est=", round(rd$coef[1], 4),
          " se=", round(rd$se[1], 4),
          " p=", round(rd$pv[1], 4),
          " bw=", round(rd$bws[1,1]),
          " N=", rd$N_h[1], "+", rd$N_h[2], "\n")
      fs_subperiod[[period]] <- list(
        period = period,
        est = rd$coef[1], se = rd$se[1], pv = rd$pv[1],
        bw = rd$bws[1,1], n_left = rd$N_h[1], n_right = rd$N_h[2]
      )
    }
  }
}

saveRDS(fs_subperiod, file.path(data_dir, "fs_subperiod.rds"))

## ----------------------------------------------------------
## 6. LRSAL Heterogeneity (Pre/Post 2013 Austerity)
## ----------------------------------------------------------

cat("\n=== LRSAL HETEROGENEITY ===\n")

lrsal_results <- list()

for (period in c("pre_lrsal", "post_lrsal")) {
  ey_range <- if (period == "pre_lrsal") c(2007, 2011) else c(2015, 2019, 2023)

  period_data <- eterm[election_year %in% ey_range &
                        pop_elec > 2000 & pop_elec < 8000 &
                        !is.na(pop_elec)]

  cat("\n--", period, "(N=", nrow(period_data), ") --\n")
  for (sc in share_cols) {
    valid <- !is.na(period_data[[sc]])
    if (sum(valid) > 50) {
      rd <- tryCatch(
        rdrobust(y = period_data[[sc]][valid],
                 x = period_data$pop_elec[valid],
                 c = 5000, kernel = "triangular",
                 p = 1, bwselect = "mserd"),
        error = function(e) NULL
      )
      if (!is.null(rd)) {
        cat("  ", sc, ": est=", round(rd$coef[1], 4),
            " p=", round(rd$pv[1], 3), "\n")
        lrsal_results[[paste(period, sc)]] <- list(
          period = period, variable = sc,
          est = rd$coef[1], se = rd$se[1], pv = rd$pv[1],
          bw = rd$bws[1,1], n_left = rd$N_h[1], n_right = rd$N_h[2]
        )
      }
    }
  }

  # Aggregate education share
  valid <- !is.na(period_data[["edu_share_total"]])
  if (sum(valid) > 50) {
    rd <- tryCatch(
      rdrobust(y = period_data[["edu_share_total"]][valid],
               x = period_data$pop_elec[valid],
               c = 5000, kernel = "triangular",
               p = 1, bwselect = "mserd"),
      error = function(e) NULL
    )
    if (!is.null(rd)) {
      cat("  edu_share_total: est=", round(rd$coef[1], 4),
          " p=", round(rd$pv[1], 3), "\n")
      lrsal_results[[paste(period, "edu_share_total")]] <- list(
        period = period, variable = "edu_share_total",
        est = rd$coef[1], se = rd$se[1], pv = rd$pv[1],
        bw = rd$bws[1,1], n_left = rd$N_h[1], n_right = rd$N_h[2]
      )
    }
  }
}

saveRDS(lrsal_results, file.path(data_dir, "lrsal_results.rds"))

## ----------------------------------------------------------
## 7. BH-Adjusted q-values for Multiple Testing
## ----------------------------------------------------------

cat("\n=== BENJAMINI-HOCHBERG ADJUSTED Q-VALUES ===\n")

# Collect all main p-values from election-term results
if (file.exists(file.path(data_dir, "results_et_5k.rds"))) {
  res_5k <- readRDS(file.path(data_dir, "results_et_5k.rds"))

  # Extract p-values from share outcomes only (not placebo)
  share_results <- res_5k[grep("^share_|edu_share_total", names(res_5k))]
  if (length(share_results) > 0) {
    pvals <- sapply(share_results, function(rd) rd$pv[1])
    qvals <- p.adjust(pvals, method = "BH")
    cat("\nBH-adjusted q-values (5,000 cutoff, election-term):\n")
    for (i in seq_along(pvals)) {
      cat("  ", names(pvals)[i], ": p=", round(pvals[i], 4),
          " q=", round(qvals[i], 4), "\n")
    }

    bh_results <- data.table(
      variable = names(pvals),
      p_value = pvals,
      q_value = qvals
    )
    saveRDS(bh_results, file.path(data_dir, "bh_qvalues_5k.rds"))
  }
}

# Same for LRSAL pre-period
if (length(lrsal_results) > 0) {
  pre_results <- lrsal_results[grep("^pre_lrsal", names(lrsal_results))]
  if (length(pre_results) > 0) {
    pvals_pre <- sapply(pre_results, function(r) r$pv)
    qvals_pre <- p.adjust(pvals_pre, method = "BH")
    cat("\nBH-adjusted q-values (pre-LRSAL):\n")
    for (i in seq_along(pvals_pre)) {
      cat("  ", names(pvals_pre)[i], ": p=", round(pvals_pre[i], 4),
          " q=", round(qvals_pre[i], 4), "\n")
    }

    bh_pre <- data.table(
      variable = sapply(pre_results, function(r) r$variable),
      p_value = pvals_pre,
      q_value = qvals_pre
    )
    saveRDS(bh_pre, file.path(data_dir, "bh_qvalues_pre_lrsal.rds"))
  }

  # Post-LRSAL q-values
  post_results <- lrsal_results[grep("^post_lrsal", names(lrsal_results))]
  if (length(post_results) > 0) {
    pvals_post <- sapply(post_results, function(r) r$pv)
    qvals_post <- p.adjust(pvals_post, method = "BH")
    cat("\nBH-adjusted q-values (post-LRSAL):\n")
    for (i in seq_along(pvals_post)) {
      cat("  ", names(pvals_post)[i], ": p=", round(pvals_post[i], 4),
          " q=", round(qvals_post[i], 4), "\n")
    }

    bh_post <- data.table(
      variable = sapply(post_results, function(r) r$variable),
      p_value = pvals_post,
      q_value = qvals_post
    )
    saveRDS(bh_post, file.path(data_dir, "bh_qvalues_post_lrsal.rds"))
  }
}

## ----------------------------------------------------------
## 8. MDE (Minimum Detectable Effect) Calculation
## ----------------------------------------------------------

cat("\n=== MINIMUM DETECTABLE EFFECTS ===\n")

# MDE = (z_alpha + z_beta) * SE, with alpha=0.05, power=0.80
z_alpha <- qnorm(0.975)  # two-sided 5%
z_beta  <- qnorm(0.80)   # 80% power

if (file.exists(file.path(data_dir, "results_et_5k.rds"))) {
  res_5k <- readRDS(file.path(data_dir, "results_et_5k.rds"))

  mde_list <- list()
  for (nm in names(res_5k)) {
    rd <- res_5k[[nm]]
    if (!is.null(rd)) {
      se <- rd$se[1]
      mde <- (z_alpha + z_beta) * se
      # Express as % of mean outcome
      cat("  ", nm, ": SE=", round(se, 4),
          " MDE=", round(mde, 4), "\n")
      mde_list[[nm]] <- list(
        variable = nm, se = se, mde = mde
      )
    }
  }

  saveRDS(mde_list, file.path(data_dir, "mde_results.rds"))
}

## ----------------------------------------------------------
## 9. Election-Year vs Averaged Running Variable Comparison
## ----------------------------------------------------------

cat("\n=== ELECTION-YEAR VS AVERAGED RUNNING VARIABLE ===\n")

# Compare first-stage estimates
if (file.exists(file.path(data_dir, "fs_et_5k.rds")) &&
    file.exists(file.path(data_dir, "fs_5k.rds"))) {

  fs_et <- readRDS(file.path(data_dir, "fs_et_5k.rds"))
  fs_avg <- readRDS(file.path(data_dir, "fs_5k.rds"))

  comparison <- data.table(
    Specification = c("Election-year population", "Averaged population"),
    FS_Estimate = c(round(fs_et$coef[1], 4), round(fs_avg$coef[1], 4)),
    FS_SE = c(round(fs_et$se[1], 4), round(fs_avg$se[1], 4)),
    FS_pvalue = c(round(fs_et$pv[1], 4), round(fs_avg$pv[1], 4)),
    Bandwidth = c(round(fs_et$bws[1,1]), round(fs_avg$bws[1,1])),
    N_eff = c(fs_et$N_h[1] + fs_et$N_h[2], fs_avg$N_h[1] + fs_avg$N_h[2])
  )
  cat("\nFirst-stage comparison:\n")
  print(comparison)

  saveRDS(comparison, file.path(data_dir, "rv_comparison.rds"))
}

## ----------------------------------------------------------
## 10. Polynomial Order Sensitivity
## ----------------------------------------------------------

cat("\n=== POLYNOMIAL ORDER SENSITIVITY ===\n")

for (p_order in 1:3) {
  sc <- share_cols[1]
  valid <- !is.na(et_5k[[sc]])
  if (sum(valid) > 50) {
    rd <- tryCatch(
      rdrobust(y = et_5k[[sc]][valid],
               x = et_5k$pop_elec[valid],
               c = 5000, kernel = "triangular",
               p = p_order, bwselect = "mserd"),
      error = function(e) NULL
    )
    if (!is.null(rd)) {
      cat("  p=", p_order, ": est=", round(rd$coef[1], 4),
          " se=", round(rd$se[1], 4),
          " p=", round(rd$pv[1], 3), "\n")
    }
  }
}

## ----------------------------------------------------------
## 11. 2011-Only Pre-LRSAL Analysis
##     Addresses referee concern: pre-LRSAL result driven by 2011
##     cohort. Show result without 2007 (clean assignment).
## ----------------------------------------------------------

cat("\n=== 2011-ONLY PRE-LRSAL ANALYSIS ===\n")

cohort_2011 <- eterm[election_year == 2011 &
                      pop_elec > 2000 & pop_elec < 8000 &
                      !is.na(pop_elec)]

cat("2011 cohort N:", nrow(cohort_2011), "\n")

share_cols_2011 <- grep("^share_3[2-9][0-9]", names(cohort_2011), value = TRUE)
# Also include edu_share_total
outcomes_2011 <- c(share_cols_2011, "edu_share_total")

results_2011_only <- list()
for (sc in outcomes_2011) {
  if (sc %in% names(cohort_2011)) {
    valid <- !is.na(cohort_2011[[sc]])
    if (sum(valid) > 50) {
      rd <- tryCatch(
        rdrobust(y = cohort_2011[[sc]][valid],
                 x = cohort_2011$pop_elec[valid],
                 c = 5000, kernel = "triangular",
                 p = 1, bwselect = "mserd"),
        error = function(e) NULL
      )
      if (!is.null(rd)) {
        cat("  ", sc, ": est=", round(rd$coef[1], 4),
            " p=", round(rd$pv[1], 3), "\n")
        results_2011_only[[sc]] <- list(
          variable = sc,
          est = rd$coef[1], se = rd$se[1], pv = rd$pv[1],
          bw = rd$bws[1,1], n_left = rd$N_h[1], n_right = rd$N_h[2]
        )
      }
    }
  }
}

saveRDS(results_2011_only, file.path(data_dir, "results_2011_only.rds"))

# BH q-values for 2011-only
if (length(results_2011_only) > 0) {
  pvals_2011 <- sapply(results_2011_only, function(r) r$pv)
  qvals_2011 <- p.adjust(pvals_2011, method = "BH")
  cat("\nBH-adjusted q-values (2011-only):\n")
  for (i in seq_along(pvals_2011)) {
    cat("  ", names(pvals_2011)[i], ": p=", round(pvals_2011[i], 4),
        " q=", round(qvals_2011[i], 4), "\n")
  }
  bh_2011 <- data.table(
    variable = sapply(results_2011_only, function(r) r$variable),
    p_value = pvals_2011,
    q_value = qvals_2011
  )
  saveRDS(bh_2011, file.path(data_dir, "bh_qvalues_2011_only.rds"))
}

cat("\n=== ROBUSTNESS COMPLETE ===\n")
