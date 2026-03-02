## ============================================================
## 03_main_analysis.R — RDD estimation at PMGSY threshold
## Breaking Purdah with Pavement (apep_0432)
## ============================================================
source(here::here("output", "apep_0432", "v1", "code", "00_packages.R"))
load(file.path(data_dir, "analysis_panel.RData"))

## ================================================================
## PART A: RDD VALIDITY CHECKS
## ================================================================

cat("=== A1: McCrary Density Test ===\n")
## McCrary test at 500 threshold
mc_500 <- rddensity(panel_rdd$pop01, c = 500)
cat(sprintf("McCrary at 500: T-stat = %.3f, p-value = %.4f\n",
            mc_500$test$t_jk, mc_500$test$p_jk))

## McCrary test at 250 threshold (hills/tribal subsample)
panel_st <- panel_rdd[st_share_01 > 0.25]
mc_250 <- rddensity(panel_st$pop01, c = 250)
cat(sprintf("McCrary at 250 (ST>25%%): T-stat = %.3f, p-value = %.4f\n",
            mc_250$test$t_jk, mc_250$test$p_jk))

cat("\n=== A2: Covariate Balance at Threshold ===\n")
## Test balance for pre-treatment covariates at the 500 cutoff
balance_vars <- c("sc_share_01", "st_share_01", "f_litrate_01",
                  "fwpr_01", "mwpr_01", "f_aglabor_share_01",
                  "f_cultiv_share_01", "csr_01")
balance_labels <- c("SC share", "ST share", "Female lit. rate",
                    "Female WPR", "Male WPR", "Female ag labor share",
                    "Female cultivator share", "Child sex ratio (m/total)")

balance_results <- data.table(
  Variable = balance_labels,
  Coeff = NA_real_, SE = NA_real_, Pval = NA_real_,
  BW = NA_real_, N_eff = NA_integer_
)

for (i in seq_along(balance_vars)) {
  v <- balance_vars[i]
  yy <- panel_rdd[[v]]
  ok <- !is.na(yy) & !is.na(panel_rdd$pop01)
  if (sum(ok) < 100) next
  rd_fit <- tryCatch(
    rdrobust(y = yy[ok], x = panel_rdd$pop01[ok], c = 500, kernel = "triangular"),
    error = function(e) NULL
  )
  if (!is.null(rd_fit)) {
    balance_results[i, `:=`(
      Coeff = rd_fit$coef["Conventional", ],
      SE    = rd_fit$se["Conventional", ],
      Pval  = rd_fit$pv["Conventional", ],
      BW    = rd_fit$bws["h", "left"],
      N_eff = rd_fit$N_h[1] + rd_fit$N_h[2]
    )]
  }
}
print(balance_results)
cat("If p-values are generally > 0.05, balance is satisfied.\n")

## ================================================================
## PART B: MAIN RDD ESTIMATES — POOLED
## ================================================================

cat("\n=== B1: Main RDD — Female Work Participation Rate ===\n")

outcomes <- c("d_fwpr", "d_mwpr", "d_gender_gap",
              "d_f_aglabor", "d_f_cultiv", "d_f_other",
              "d_f_nonwork", "d_f_litrate", "d_csr")
outcome_labels <- c("Chg Female WPR", "Chg Male WPR", "Chg Gender Gap",
                     "Chg F Ag Labor", "Chg F Cultivator", "Chg F Other Work",
                     "Chg F Non-Worker", "Chg F Literacy", "Chg Child Sex Ratio")

rdd_pooled <- data.table(
  Outcome = outcome_labels,
  Coeff = NA_real_, SE = NA_real_, Pval = NA_real_,
  BW = NA_real_, N_eff = NA_integer_
)

for (i in seq_along(outcomes)) {
  v <- outcomes[i]
  yy <- panel_rdd[[v]]
  ok <- !is.na(yy) & !is.na(panel_rdd$pop01)
  if (sum(ok) < 100) next
  rd_fit <- tryCatch(
    rdrobust(y = yy[ok], x = panel_rdd$pop01[ok], c = 500, kernel = "triangular"),
    error = function(e) NULL
  )
  if (!is.null(rd_fit)) {
    rdd_pooled[i, `:=`(
      Coeff = rd_fit$coef["Conventional", ],
      SE    = rd_fit$se["Conventional", ],
      Pval  = rd_fit$pv["Conventional", ],
      BW    = rd_fit$bws["h", "left"],
      N_eff = rd_fit$N_h[1] + rd_fit$N_h[2]
    )]
  }
}

cat("\nPooled RDD Results:\n")
print(rdd_pooled)

## ================================================================
## PART C: HETEROGENEOUS RDD BY CASTE
## ================================================================

cat("\n=== C: RDD by Caste Category ===\n")

## Split sample by dominant caste and estimate RDD separately
caste_cats <- c("General/OBC-dominated", "SC-dominated", "ST-dominated")

## Store results for the key outcome: change in female WPR
hetero_results <- list()

for (cc in caste_cats) {
  sub <- panel_rdd[caste_dominant == cc]
  cat(sprintf("\n--- %s (N = %s) ---\n", cc, formatC(nrow(sub), big.mark = ",")))

  res_cc <- data.table(
    Caste = cc,
    Outcome = outcome_labels,
    Coeff = NA_real_, SE = NA_real_, Pval = NA_real_,
    BW = NA_real_, N_eff = NA_integer_
  )

  for (i in seq_along(outcomes)) {
    v <- outcomes[i]
    yy <- sub[[v]]
    ok <- !is.na(yy) & !is.na(sub$pop01)
    if (sum(ok) < 100) next
    rd_fit <- tryCatch(
      rdrobust(y = yy[ok], x = sub$pop01[ok], c = 500, kernel = "triangular"),
      error = function(e) NULL
    )
    if (!is.null(rd_fit)) {
      res_cc[i, `:=`(
        Coeff = rd_fit$coef["Conventional", ],
        SE    = rd_fit$se["Conventional", ],
        Pval  = rd_fit$pv["Conventional", ],
        BW    = rd_fit$bws["h", "left"],
        N_eff = rd_fit$N_h[1] + rd_fit$N_h[2]
      )]
    }
  }

  print(res_cc[, .(Outcome, Coeff, SE, Pval)])
  hetero_results[[cc]] <- res_cc
}

hetero_all <- rbindlist(hetero_results)

## ================================================================
## PART D: CONTINUOUS INTERACTION SPECIFICATION
## ================================================================

cat("\n=== D: Parametric RDD with Caste Interactions (within BW 300-700) ===\n")

## Using fixest for parametric local linear regressions
## within the main bandwidth

## Main outcomes: d_fwpr, d_mwpr, d_gender_gap, d_f_other, d_f_nonwork
## Treatment: eligible_500
## Running variable: pop01_c500 (centered)
## Interactions: sc_share_01, st_share_01

fit_fwpr <- feols(d_fwpr ~ eligible_500 * sc_share_01 + eligible_500 * st_share_01 +
                    pop01_c500 + I(pop01_c500 * eligible_500) |
                    pc11_state_id,
                  data = panel_bw, cluster = ~pc11_district_id)

fit_mwpr <- feols(d_mwpr ~ eligible_500 * sc_share_01 + eligible_500 * st_share_01 +
                    pop01_c500 + I(pop01_c500 * eligible_500) |
                    pc11_state_id,
                  data = panel_bw, cluster = ~pc11_district_id)

fit_gap <- feols(d_gender_gap ~ eligible_500 * sc_share_01 + eligible_500 * st_share_01 +
                   pop01_c500 + I(pop01_c500 * eligible_500) |
                   pc11_state_id,
                 data = panel_bw, cluster = ~pc11_district_id)

fit_other <- feols(d_f_other ~ eligible_500 * sc_share_01 + eligible_500 * st_share_01 +
                     pop01_c500 + I(pop01_c500 * eligible_500) |
                     pc11_state_id,
                   data = panel_bw, cluster = ~pc11_district_id)

fit_nonwork <- feols(d_f_nonwork ~ eligible_500 * sc_share_01 + eligible_500 * st_share_01 +
                       pop01_c500 + I(pop01_c500 * eligible_500) |
                       pc11_state_id,
                     data = panel_bw, cluster = ~pc11_district_id)

fit_litrate <- feols(d_f_litrate ~ eligible_500 * sc_share_01 + eligible_500 * st_share_01 +
                       pop01_c500 + I(pop01_c500 * eligible_500) |
                       pc11_state_id,
                     data = panel_bw, cluster = ~pc11_district_id)

cat("\n--- Female WPR ---\n")
print(summary(fit_fwpr))
cat("\n--- Male WPR ---\n")
print(summary(fit_mwpr))
cat("\n--- Gender Gap ---\n")
print(summary(fit_gap))
cat("\n--- Female Other Work (Non-farm) ---\n")
print(summary(fit_other))
cat("\n--- Female Non-Worker ---\n")
print(summary(fit_nonwork))
cat("\n--- Female Literacy ---\n")
print(summary(fit_litrate))

## ================================================================
## PART E: FIRST STAGE — Nightlights
## ================================================================

cat("\n=== E: First Stage via Nightlights ===\n")

## Load nightlights from raw data (not in analysis_panel)
load(file.path(data_dir, "raw_shrug.RData"))

## Merge nightlights (get pre and post averages)
## DMSP nightlights are in long format: shrid2 + year columns
## Let's compute pre (2000-2004) and post (2008-2011) averages
nl_cols <- names(nl)
nl_year_cols <- grep("^total_light", nl_cols, value = TRUE)

## The DMSP file has columns: shrid2, num_cells, dmsp_total_light_cal, max_light
## BUT it's a PANEL with one row per village-year
## Actually let me check the structure
cat(sprintf("NL columns: %s\n", paste(names(nl)[1:5], collapse = ", ")))
cat(sprintf("NL rows: %s\n", formatC(nrow(nl), big.mark = ",")))

## DMSP nightlights in SHRUG are in WIDE format with year-specific columns
## Check actual column names
dmsp_cols <- grep("total_light|num_cells", names(nl), value = TRUE)
cat(sprintf("DMSP columns: %s\n", paste(head(dmsp_cols, 10), collapse = ", ")))

## Construct pre/post nightlight averages
## Nightlight columns are typically: dmsp_total_light_cal2000, dmsp_total_light_cal2001, etc.
## or just: dmsp_total_light_cal with year in separate column

## Check if this is long or wide format
if ("year" %in% names(nl)) {
  cat("Nightlights in LONG format\n")
  nl_pre <- nl[year >= 2000 & year <= 2004, .(nl_pre = mean(dmsp_total_light_cal, na.rm = TRUE)), by = shrid2]
  nl_post <- nl[year >= 2008 & year <= 2011, .(nl_post = mean(dmsp_total_light_cal, na.rm = TRUE)), by = shrid2]
} else {
  cat("Nightlights in WIDE format — checking columns...\n")
  ## Check for year-specific columns
  yr_cols <- grep("200[0-9]|201[0-3]", names(nl), value = TRUE)
  cat(sprintf("Year columns found: %s\n", paste(head(yr_cols, 10), collapse = ", ")))

  if (length(yr_cols) > 0) {
    pre_cols <- grep("200[0-4]", yr_cols, value = TRUE)
    post_cols <- grep("200[89]|201[01]", yr_cols, value = TRUE)
    if (length(pre_cols) > 0 & length(post_cols) > 0) {
      nl[, nl_pre := rowMeans(.SD, na.rm = TRUE), .SDcols = pre_cols]
      nl[, nl_post := rowMeans(.SD, na.rm = TRUE), .SDcols = post_cols]
      nl_avg <- nl[, .(shrid2, nl_pre, nl_post)]
    }
  } else {
    ## Try dmsp_total_light_cal directly (single cross-section?)
    cat("Attempting single column approach...\n")
    nl_avg <- nl[, .(shrid2, nl_pre = dmsp_total_light_cal)]
  }
}

if (exists("nl_pre") && exists("nl_post")) {
  nl_avg <- merge(nl_pre, nl_post, by = "shrid2")
}

if (exists("nl_avg")) {
  nl_avg[, d_nl := nl_post - nl_pre]
  panel_bw <- merge(panel_bw, nl_avg, by = "shrid2", all.x = TRUE)

  ## RDD for nightlight growth as first stage
  ok_nl <- !is.na(panel_bw$d_nl) & !is.na(panel_bw$pop01)
  if (sum(ok_nl) > 100) {
    rd_nl <- tryCatch(
      rdrobust(y = panel_bw$d_nl[ok_nl], x = panel_bw$pop01[ok_nl],
               c = 500, kernel = "triangular"),
      error = function(e) NULL
    )
    if (!is.null(rd_nl)) {
      cat(sprintf("NL First Stage: Coeff = %.4f, SE = %.4f, p = %.4f\n",
                  rd_nl$coef["Conventional", ],
                  rd_nl$se["Conventional", ],
                  rd_nl$pv["Conventional", ]))
    }
  }
}

## ── Save all results ──────────────────────────────────────
save(mc_500, mc_250, balance_results, rdd_pooled, hetero_all,
     fit_fwpr, fit_mwpr, fit_gap, fit_other, fit_nonwork, fit_litrate,
     file = file.path(data_dir, "main_results.RData"))
cat("\nAll results saved.\n")
