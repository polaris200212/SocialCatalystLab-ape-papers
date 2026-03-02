## ============================================================
## 04_robustness.R — Robustness checks for PMGSY RDD
## Breaking Purdah with Pavement (apep_0432)
## ============================================================
source(here::here("output", "apep_0432", "v1", "code", "00_packages.R"))
load(file.path(data_dir, "analysis_panel.RData"))
load(file.path(data_dir, "main_results.RData"))

## ================================================================
## R1: BANDWIDTH SENSITIVITY
## ================================================================

cat("=== R1: Bandwidth Sensitivity ===\n")

## Key outcomes to check
key_outcomes <- c("d_fwpr", "d_f_aglabor", "d_f_nonwork", "d_f_litrate")
key_labels   <- c("Female WPR", "F Ag Labor", "F Non-Worker", "F Literacy")

## Bandwidths: half, main (optimal), 1.5x, double
bw_multipliers <- c(0.5, 0.75, 1, 1.25, 1.5, 2)

bw_results <- list()

for (i in seq_along(key_outcomes)) {
  v <- key_outcomes[i]
  yy <- panel_rdd[[v]]
  ok <- !is.na(yy) & !is.na(panel_rdd$pop01)

  ## Get optimal bandwidth first
  rd_opt <- tryCatch(
    rdrobust(y = yy[ok], x = panel_rdd$pop01[ok], c = 500, kernel = "triangular"),
    error = function(e) NULL
  )
  if (is.null(rd_opt)) next
  h_opt <- rd_opt$bws["h", "left"]

  for (m in bw_multipliers) {
    h_use <- h_opt * m
    rd_bw <- tryCatch(
      rdrobust(y = yy[ok], x = panel_rdd$pop01[ok], c = 500,
               kernel = "triangular", h = h_use),
      error = function(e) NULL
    )
    if (!is.null(rd_bw)) {
      bw_results[[length(bw_results) + 1]] <- data.table(
        Outcome = key_labels[i],
        BW_mult = m,
        BW = h_use,
        Coeff = rd_bw$coef["Conventional", ],
        SE = rd_bw$se["Conventional", ],
        Pval = rd_bw$pv["Conventional", ],
        N_eff = rd_bw$N_h[1] + rd_bw$N_h[2]
      )
    }
  }
}

bw_sensitivity <- rbindlist(bw_results)
cat("\nBandwidth Sensitivity:\n")
print(bw_sensitivity[, .(Outcome, BW_mult, BW = round(BW, 1),
                          Coeff = round(Coeff, 4), Pval = round(Pval, 3))])

## ================================================================
## R2: PLACEBO THRESHOLDS
## ================================================================

cat("\n=== R2: Placebo Thresholds ===\n")

placebo_cutoffs <- c(300, 350, 400, 600, 650, 700)
placebo_results <- list()

for (cc in placebo_cutoffs) {
  for (i in seq_along(key_outcomes)) {
    v <- key_outcomes[i]
    yy <- panel_rdd[[v]]
    ok <- !is.na(yy) & !is.na(panel_rdd$pop01)
    rd_p <- tryCatch(
      rdrobust(y = yy[ok], x = panel_rdd$pop01[ok], c = cc, kernel = "triangular"),
      error = function(e) NULL
    )
    if (!is.null(rd_p)) {
      placebo_results[[length(placebo_results) + 1]] <- data.table(
        Cutoff = cc,
        Outcome = key_labels[i],
        Coeff = rd_p$coef["Conventional", ],
        SE = rd_p$se["Conventional", ],
        Pval = rd_p$pv["Conventional", ]
      )
    }
  }
}

placebo_all <- rbindlist(placebo_results)
cat("\nPlacebo Thresholds:\n")
print(placebo_all[, .(Cutoff, Outcome, Coeff = round(Coeff, 4), Pval = round(Pval, 3))])

## ================================================================
## R3: DONUT HOLE RDD
## ================================================================

cat("\n=== R3: Donut Hole RDD (excluding ±10 around threshold) ===\n")

panel_donut <- panel_rdd[abs(pop01 - 500) > 10]
cat(sprintf("Donut sample: %s villages\n", formatC(nrow(panel_donut), big.mark = ",")))

donut_results <- data.table(
  Outcome = key_labels,
  Coeff = NA_real_, SE = NA_real_, Pval = NA_real_
)

for (i in seq_along(key_outcomes)) {
  v <- key_outcomes[i]
  yy <- panel_donut[[v]]
  ok <- !is.na(yy) & !is.na(panel_donut$pop01)
  rd_d <- tryCatch(
    rdrobust(y = yy[ok], x = panel_donut$pop01[ok], c = 500, kernel = "triangular"),
    error = function(e) NULL
  )
  if (!is.null(rd_d)) {
    donut_results[i, `:=`(
      Coeff = rd_d$coef["Conventional", ],
      SE = rd_d$se["Conventional", ],
      Pval = rd_d$pv["Conventional", ]
    )]
  }
}

cat("\nDonut Hole Results:\n")
print(donut_results)

## ================================================================
## R4: 250 THRESHOLD — HILLS/TRIBAL REPLICATION
## ================================================================

cat("\n=== R4: RDD at 250 Threshold (ST > 25% subsample) ===\n")

panel_st <- panel_rdd[st_share_01 > 0.25]
cat(sprintf("ST > 25%% sample: %s villages\n", formatC(nrow(panel_st), big.mark = ",")))

## All outcomes at 250 threshold
outcomes_all <- c("d_fwpr", "d_mwpr", "d_gender_gap",
                   "d_f_aglabor", "d_f_cultiv", "d_f_other",
                   "d_f_nonwork", "d_f_litrate", "d_csr")
outcome_all_labels <- c("Chg Female WPR", "Chg Male WPR", "Chg Gender Gap",
                         "Chg F Ag Labor", "Chg F Cultivator", "Chg F Other Work",
                         "Chg F Non-Worker", "Chg F Literacy", "Chg Child Sex Ratio")

rdd_250 <- data.table(
  Outcome = outcome_all_labels,
  Coeff = NA_real_, SE = NA_real_, Pval = NA_real_,
  BW = NA_real_, N_eff = NA_integer_
)

for (i in seq_along(outcomes_all)) {
  v <- outcomes_all[i]
  yy <- panel_st[[v]]
  ok <- !is.na(yy) & !is.na(panel_st$pop01)
  if (sum(ok) < 100) next
  rd_fit <- tryCatch(
    rdrobust(y = yy[ok], x = panel_st$pop01[ok], c = 250, kernel = "triangular"),
    error = function(e) NULL
  )
  if (!is.null(rd_fit)) {
    rdd_250[i, `:=`(
      Coeff = rd_fit$coef["Conventional", ],
      SE = rd_fit$se["Conventional", ],
      Pval = rd_fit$pv["Conventional", ],
      BW = rd_fit$bws["h", "left"],
      N_eff = rd_fit$N_h[1] + rd_fit$N_h[2]
    )]
  }
}

cat("\nRDD at 250 (Hills/Tribal):\n")
print(rdd_250)

## ================================================================
## R5: POLYNOMIAL ORDER SENSITIVITY
## ================================================================

cat("\n=== R5: Polynomial Order Sensitivity ===\n")

poly_results <- list()

for (p in 1:3) {
  for (i in seq_along(key_outcomes)) {
    v <- key_outcomes[i]
    yy <- panel_rdd[[v]]
    ok <- !is.na(yy) & !is.na(panel_rdd$pop01)
    rd_p <- tryCatch(
      rdrobust(y = yy[ok], x = panel_rdd$pop01[ok], c = 500,
               kernel = "triangular", p = p),
      error = function(e) NULL
    )
    if (!is.null(rd_p)) {
      poly_results[[length(poly_results) + 1]] <- data.table(
        Outcome = key_labels[i],
        Poly_Order = p,
        Coeff = rd_p$coef["Conventional", ],
        SE = rd_p$se["Conventional", ],
        Pval = rd_p$pv["Conventional", ]
      )
    }
  }
}

poly_sensitivity <- rbindlist(poly_results)
cat("\nPolynomial Order Sensitivity:\n")
print(poly_sensitivity[, .(Outcome, Poly_Order, Coeff = round(Coeff, 4), Pval = round(Pval, 3))])

## ================================================================
## R6: ECONOMIC CENSUS OUTCOMES
## ================================================================

cat("\n=== R6: Economic Census (Non-farm Employment) ===\n")

ec_outcomes <- c("d_f_nonfarm")
ec_labels <- c("Chg F Non-farm Share")

## Pooled
for (i in seq_along(ec_outcomes)) {
  v <- ec_outcomes[i]
  yy <- panel_rdd[[v]]
  ok <- !is.na(yy) & !is.na(panel_rdd$pop01)
  if (sum(ok) < 100) {
    cat(sprintf("  %s: Insufficient observations (%d)\n", ec_labels[i], sum(ok)))
    next
  }
  rd_fit <- tryCatch(
    rdrobust(y = yy[ok], x = panel_rdd$pop01[ok], c = 500, kernel = "triangular"),
    error = function(e) NULL
  )
  if (!is.null(rd_fit)) {
    cat(sprintf("  %s: Coeff = %.4f, SE = %.4f, p = %.4f\n",
                ec_labels[i], rd_fit$coef["Conventional", ],
                rd_fit$se["Conventional", ], rd_fit$pv["Conventional", ]))
  }
}

## By caste
caste_cats <- c("General/OBC-dominated", "SC-dominated", "ST-dominated")
for (cc in caste_cats) {
  sub <- panel_rdd[caste_dominant == cc]
  yy <- sub[["d_f_nonfarm"]]
  ok <- !is.na(yy) & !is.na(sub$pop01)
  if (sum(ok) < 100) next
  rd_fit <- tryCatch(
    rdrobust(y = yy[ok], x = sub$pop01[ok], c = 500, kernel = "triangular"),
    error = function(e) NULL
  )
  if (!is.null(rd_fit)) {
    cat(sprintf("  %s — %s: Coeff = %.4f, SE = %.4f, p = %.4f\n",
                "F Non-farm", cc, rd_fit$coef["Conventional", ],
                rd_fit$se["Conventional", ], rd_fit$pv["Conventional", ]))
  }
}

## ================================================================
## R7: SECC-BASED HETEROGENEITY
## ================================================================

cat("\n=== R7: SECC Deprivation Heterogeneity ===\n")

## Split by land ownership
panel_rdd[, high_landless := fifelse(land_own_share < median(land_own_share, na.rm = TRUE),
                                      "High Landless", "Low Landless")]

for (grp in c("High Landless", "Low Landless")) {
  sub <- panel_rdd[high_landless == grp]
  yy <- sub[["d_fwpr"]]
  ok <- !is.na(yy) & !is.na(sub$pop01)
  if (sum(ok) < 100) next
  rd_fit <- tryCatch(
    rdrobust(y = yy[ok], x = sub$pop01[ok], c = 500, kernel = "triangular"),
    error = function(e) NULL
  )
  if (!is.null(rd_fit)) {
    cat(sprintf("  %s — d_fwpr: Coeff = %.4f, SE = %.4f, p = %.4f, N_eff = %d\n",
                grp, rd_fit$coef["Conventional", ], rd_fit$se["Conventional", ],
                rd_fit$pv["Conventional", ], rd_fit$N_h[1] + rd_fit$N_h[2]))
  }
}

## ── Save robustness results ──────────────────────────────────
save(bw_sensitivity, placebo_all, donut_results, rdd_250,
     poly_sensitivity,
     file = file.path(data_dir, "robustness_results.RData"))
cat("\nRobustness results saved.\n")
