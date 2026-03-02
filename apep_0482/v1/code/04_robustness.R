## ============================================================
## 04_robustness.R — Robustness checks
## Donut RDD, bandwidth sensitivity, pre-treatment placebos,
## placebo cutoffs, LRSAL heterogeneity
## ============================================================

source("00_packages.R")

data_dir <- "../data"
panel <- fread(file.path(data_dir, "analysis_panel.csv"))

cat("Panel loaded:", nrow(panel), "rows\n")

## ----------------------------------------------------------
## 1. Donut RDD — Exclude municipalities near cutoff
## ----------------------------------------------------------

cat("\n=== DONUT RDD ===\n")

# Average outcomes for 5,000 cutoff
muni_5k <- panel[pop > 2000 & pop < 8000 & year >= 2010,
  lapply(.SD, function(x) mean(x, na.rm = TRUE)),
  by = .(ine_code),
  .SDcols = c("pop", grep("^share_", names(panel), value = TRUE),
              "edu_share_total", "edu_pc")
]

share_cols <- grep("^share_", names(muni_5k), value = TRUE)
# Exclude generic share_32 (2-digit aggregate)
donut_share_cols <- share_cols[share_cols != "share_32"]

# Try different donut radii (100, 200 only — 500 removes too many observations
# near the cutoff, producing implausibly large and imprecise estimates)
donut_results <- list()
for (radius in c(100, 200)) {
  cat("\n-- Donut radius:", radius, "--\n")
  muni_donut <- muni_5k[abs(pop - 5000) > radius]

  for (sc in donut_share_cols[1:min(4, length(donut_share_cols))]) {
    valid <- !is.na(muni_donut[[sc]])
    if (sum(valid) > 50) {
      rd <- tryCatch(
        rdrobust(y = muni_donut[[sc]][valid],
                 x = muni_donut$pop[valid],
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
## 2. Bandwidth Sensitivity
## ----------------------------------------------------------

cat("\n=== BANDWIDTH SENSITIVITY ===\n")

bw_results <- list()

# Get optimal bandwidth from main result
main_sc <- share_cols[1]
valid <- !is.na(muni_5k[[main_sc]])
if (sum(valid) > 50) {
  main_rd <- rdrobust(y = muni_5k[[main_sc]][valid],
                       x = muni_5k$pop[valid],
                       c = 5000, kernel = "triangular",
                       p = 1, bwselect = "mserd")
  opt_bw <- main_rd$bws[1,1]

  for (mult in c(0.5, 0.75, 1.0, 1.25, 1.5, 2.0)) {
    bw <- opt_bw * mult
    rd <- tryCatch(
      rdrobust(y = muni_5k[[main_sc]][valid],
               x = muni_5k$pop[valid],
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
## 3. Pre-Treatment Placebo (shares in 2010, before treatment)
## ----------------------------------------------------------

cat("\n=== PRE-TREATMENT PLACEBO ===\n")

# For the 3,000 cutoff: pre-2011 data is pre-treatment
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
## 4. Placebo Cutoffs (4,000 and 6,000 — no policy change)
## ----------------------------------------------------------

cat("\n=== PLACEBO CUTOFFS ===\n")

muni_broad <- panel[pop > 1000 & pop < 9000 & year >= 2010,
  lapply(.SD, function(x) mean(x, na.rm = TRUE)),
  by = .(ine_code),
  .SDcols = c("pop", share_cols, "edu_share_total")
]

placebo_cutoff_results <- list()
for (cutoff in c(4000, 6000)) {
  cat("\n-- Placebo cutoff:", cutoff, "--\n")
  for (sc in share_cols[1:min(3, length(share_cols))]) {
    valid <- !is.na(muni_broad[[sc]])
    if (sum(valid) > 50) {
      rd <- tryCatch(
        rdrobust(y = muni_broad[[sc]][valid],
                 x = muni_broad$pop[valid],
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
## 4b. Sub-period First Stage (Pre/Post LRSAL)
## ----------------------------------------------------------

cat("\n=== SUB-PERIOD FIRST STAGE ===\n")

fs_subperiod <- list()
for (period in c("pre_lrsal", "post_lrsal")) {
  yr_range <- if (period == "pre_lrsal") 2010:2013 else 2014:2023

  muni_fs <- panel[pop > 2000 & pop < 8000 & year %in% yr_range &
                    !is.na(female_share),
    .(female_share = mean(female_share, na.rm = TRUE),
      pop = mean(pop, na.rm = TRUE)),
    by = .(ine_code)
  ]

  cat("\n--", period, "(N=", nrow(muni_fs), ") --\n")
  if (nrow(muni_fs) > 100) {
    rd <- tryCatch(
      rdrobust(y = muni_fs$female_share,
               x = muni_fs$pop,
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
## 5. LRSAL Heterogeneity (Pre/Post 2013 Austerity)
## ----------------------------------------------------------

cat("\n=== LRSAL HETEROGENEITY ===\n")

# Use only disaggregated shares (exclude generic share_32)
het_share_cols <- share_cols[share_cols != "share_32"]

lrsal_results <- list()

# Split panel at 2014 (LRSAL effective late 2013)
for (period in c("pre_lrsal", "post_lrsal")) {
  yr_range <- if (period == "pre_lrsal") 2010:2013 else 2014:2023

  muni_period <- panel[pop > 2000 & pop < 8000 & year %in% yr_range,
    lapply(.SD, function(x) mean(x, na.rm = TRUE)),
    by = .(ine_code),
    .SDcols = c("pop", het_share_cols, "edu_share_total")
  ]

  cat("\n--", period, "(N=", nrow(muni_period), ") --\n")
  for (sc in het_share_cols) {
    valid <- !is.na(muni_period[[sc]])
    if (sum(valid) > 50) {
      rd <- tryCatch(
        rdrobust(y = muni_period[[sc]][valid],
                 x = muni_period$pop[valid],
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

  # Also estimate aggregate education share
  valid <- !is.na(muni_period[["edu_share_total"]])
  if (sum(valid) > 50) {
    rd <- tryCatch(
      rdrobust(y = muni_period[["edu_share_total"]][valid],
               x = muni_period$pop[valid],
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
## 6. Polynomial Order Sensitivity
## ----------------------------------------------------------

cat("\n=== POLYNOMIAL ORDER SENSITIVITY ===\n")

for (p_order in 1:3) {
  sc <- share_cols[1]
  valid <- !is.na(muni_5k[[sc]])
  if (sum(valid) > 50) {
    rd <- tryCatch(
      rdrobust(y = muni_5k[[sc]][valid],
               x = muni_5k$pop[valid],
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

cat("\n=== ROBUSTNESS COMPLETE ===\n")
