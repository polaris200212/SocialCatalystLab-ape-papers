## ─── 03_main_analysis.R ────────────────────────────────────────
## Main DiD estimation: e-NAM effects on mandi prices
## ────────────────────────────────────────────────────────────────
source("00_packages.R")

## ─── Load data ─────────────────────────────────────────────────
monthly <- fread(file.path(data_dir, "monthly_panel.csv"))
dispersion <- fread(file.path(data_dir, "dispersion_panel.csv"))

monthly[, ym := as.Date(ym)]
monthly[, first_treat_ym := as.Date(first_treat_ym)]
if ("enam_first_date" %in% names(dispersion)) {
  dispersion[, enam_first_date := as.Date(enam_first_date)]
}
dispersion[, ym := as.Date(ym)]

cat("Panel loaded:", format(nrow(monthly), big.mark = ","), "obs\n")
cat("Mandis:", uniqueN(monthly$mandi_id), "\n")

## ─── Table 1: Summary Statistics ───────────────────────────────
cat("\n── Table 1: Summary Statistics ──\n")

## Split by treatment status
summ_stats <- monthly[year >= 2010, .(
  `Mean Price (Rs/q)` = mean(modal_price, na.rm = TRUE),
  `SD Price` = sd(modal_price, na.rm = TRUE),
  `Median Price` = median(modal_price, na.rm = TRUE),
  `N Observations` = .N,
  `N Mandis` = uniqueN(mandi_id),
  `N States` = uniqueN(state),
  `Mean Days/Month` = mean(n_days, na.rm = TRUE)
), by = .(Group = fifelse(enam_treated, "e-NAM Mandis", "Non-e-NAM Mandis"))]

cat("\n")
print(summ_stats)

## By commodity
summ_by_comm <- monthly[year >= 2010, .(
  N_mandis = uniqueN(mandi_id),
  Mean_price = round(mean(modal_price, na.rm = TRUE)),
  SD_price = round(sd(modal_price, na.rm = TRUE)),
  N_obs = .N
), by = .(commodity, Group = fifelse(enam_treated, "e-NAM", "Control"))]

cat("\nBy commodity:\n")
print(dcast(summ_by_comm, commodity ~ Group, value.var = c("N_mandis", "Mean_price")))

## ─── Specification 1: TWFE (benchmark) ─────────────────────────
cat("\n── Specification 1: TWFE ──\n")

## Standard TWFE as benchmark (we know this is biased with staggering)
twfe_price <- feols(
  ln_price ~ post_enam | mandi_id + time_period,
  data = monthly,
  cluster = ~mandi_id
)
cat("TWFE (log price):\n")
summary(twfe_price)

## By commodity
twfe_by_comm <- feols(
  ln_price ~ post_enam | mandi_id + time_period,
  data = monthly,
  cluster = ~mandi_id,
  split = ~commodity
)

## ─── Specification 2: Callaway-Sant'Anna ───────────────────────
cat("\n── Specification 2: Callaway-Sant'Anna ──\n")

## Prepare data: Aggregate to quarterly for CS-DiD (smoother panel)
cat("  Preparing quarterly panel for CS-DiD...\n")
monthly[, quarter := paste0(year, "Q", quarter(ym))]
monthly[, qtr_num := (year - 2007) * 4 + quarter(ym)]
monthly[, first_treat_qtr := fifelse(
  enam_treated,
  as.integer((year(first_treat_ym) - 2007) * 4 + quarter(first_treat_ym)),
  0L
)]

quarterly <- monthly[, .(
  ln_price = mean(ln_price, na.rm = TRUE),
  modal_price = mean(modal_price, na.rm = TRUE),
  n_months = .N
), by = .(mandi_id, qtr_num, first_treat_qtr, commodity, state,
          enam_treated, post_enam)]

## Run CS for each commodity separately
cs_results <- list()
cs_sample_info <- list()  ## Track mandi counts from actual CS-DiD sample
commodities <- unique(quarterly$commodity)

for (comm in commodities) {
  cat(sprintf("  CS-DiD: %s\n", comm))
  comm_data <- quarterly[commodity == comm]

  ## Apply same mandi filter as TWFE: keep mandis with >= 60 months in the monthly panel
  monthly_mc <- monthly[commodity == comm, .N, by = mandi_id]
  monthly_keep <- monthly_mc[N >= 60]$mandi_id
  comm_data <- comm_data[mandi_id %in% monthly_keep]

  ## Also require >= 20 quarters for panel balance
  mandi_counts <- comm_data[, .N, by = mandi_id]
  keep_mandis <- mandi_counts[N >= 20]$mandi_id
  comm_data <- comm_data[mandi_id %in% keep_mandis]

  if (nrow(comm_data) < 500 || uniqueN(comm_data[first_treat_qtr > 0]$mandi_id) < 5) {
    cat(sprintf("    Skipping %s: insufficient data (%d obs, %d treated)\n",
                comm, nrow(comm_data),
                uniqueN(comm_data[first_treat_qtr > 0]$mandi_id)))
    next
  }

  n_treat <- uniqueN(comm_data[first_treat_qtr > 0]$mandi_id)
  n_ctrl <- uniqueN(comm_data[first_treat_qtr == 0]$mandi_id)
  n_obs <- nrow(comm_data)

  cat(sprintf("    Panel: %d obs, %d mandis, %d treated, %d control\n",
              n_obs, uniqueN(comm_data$mandi_id), n_treat, n_ctrl))

  ## Save sample info for table
  cs_sample_info[[comm]] <- list(n_treated = n_treat, n_control = n_ctrl, n_obs = n_obs)

  tryCatch({
    cs_out <- att_gt(
      yname = "ln_price",
      tname = "qtr_num",
      idname = "mandi_id",
      gname = "first_treat_qtr",
      data = as.data.frame(comm_data),
      control_group = "notyettreated",
      anticipation = 0,
      base_period = "universal"
    )

    ## Aggregate to overall ATT
    agg_overall <- aggte(cs_out, type = "simple")
    cat(sprintf("    ATT = %.4f (SE = %.4f, p = %.4f)\n",
                agg_overall$overall.att, agg_overall$overall.se,
                2 * pnorm(-abs(agg_overall$overall.att / agg_overall$overall.se))))

    ## Dynamic (event study) aggregation
    agg_dynamic <- aggte(cs_out, type = "dynamic", min_e = -8, max_e = 12)

    cs_results[[comm]] <- list(
      gt = cs_out,
      overall = agg_overall,
      dynamic = agg_dynamic,
      commodity = comm
    )
  }, error = function(e) {
    cat(sprintf("    ERROR in CS-DiD for %s: %s\n", comm, e$message))
  })
}

## ─── Specification 3: Sun-Abraham via fixest ───────────────────
cat("\n── Specification 3: Sun-Abraham ──\n")

## Prepare cohort variable for sunab()
monthly[, cohort := fifelse(enam_treated, first_treat_period, 10000L)]

sa_results <- list()
for (comm in commodities) {
  comm_data <- monthly[commodity == comm]
  mandi_counts <- comm_data[, .N, by = mandi_id]
  keep_mandis <- mandi_counts[N >= 60]$mandi_id
  comm_data <- comm_data[mandi_id %in% keep_mandis]

  if (nrow(comm_data) < 1000) next

  tryCatch({
    sa_fit <- feols(
      ln_price ~ sunab(cohort, time_period) | mandi_id + time_period,
      data = comm_data,
      cluster = ~mandi_id
    )
    sa_results[[comm]] <- sa_fit
    ## Extract aggregated ATT
    agg <- summary(sa_fit, agg = "ATT")
    ct <- coeftable(agg)
    cat(sprintf("  %s: ATT = %.4f (SE = %.4f)\n", comm,
                ct[1, 1], ct[1, 2]))
  }, error = function(e) {
    cat(sprintf("  ERROR for %s: %s\n", comm, e$message))
  })
}

## ─── Specification 4: Price dispersion DiD ─────────────────────
cat("\n── Specification 4: Price Dispersion ──\n")

## State × commodity × month level: CV of prices
if (nrow(dispersion) > 100) {
  disp_did <- feols(
    cv_price ~ post_enam | state + ym,
    data = dispersion[n_mandis >= 3],  # Need 3+ mandis for meaningful CV
    cluster = ~state
  )
  cat("CV dispersion DiD:\n")
  summary(disp_did)
}

## ─── Save results ──────────────────────────────────────────────
cat("\n── Saving results ──\n")

## Save CS results
save(cs_results, sa_results, twfe_price, twfe_by_comm,
     file = file.path(data_dir, "main_results.RData"))

## Export key estimates to CSV for paper
estimates <- data.table(
  commodity = character(),
  estimator = character(),
  att = numeric(),
  se = numeric(),
  pvalue = numeric(),
  n_treated = integer(),
  n_control = integer()
)

for (comm in names(cs_results)) {
  r <- cs_results[[comm]]
  info <- cs_sample_info[[comm]]
  estimates <- rbind(estimates, data.table(
    commodity = comm,
    estimator = "CS-DiD",
    att = r$overall$overall.att,
    se = r$overall$overall.se,
    pvalue = 2 * pnorm(-abs(r$overall$overall.att / r$overall$overall.se)),
    n_treated = info$n_treated,
    n_control = info$n_control
  ))
}

## If CS-DiD produced no results, fall back to TWFE per commodity
if (nrow(estimates) == 0) {
  cat("  CS-DiD produced no results; using TWFE per commodity as main estimates\n")
  for (comm in commodities) {
    cd <- monthly[commodity == comm]
    mandi_counts <- cd[, .N, by = mandi_id]
    cd <- cd[mandi_id %in% mandi_counts[N >= 60]$mandi_id]
    if (nrow(cd) < 500) next
    tryCatch({
      fit <- feols(ln_price ~ post_enam | mandi_id + time_period,
                   data = cd, cluster = ~mandi_id)
      ct <- coeftable(fit)
      estimates <- rbind(estimates, data.table(
        commodity = comm,
        estimator = "TWFE",
        att = ct[1, 1], se = ct[1, 2], pvalue = ct[1, 4],
        n_treated = uniqueN(cd[enam_treated == TRUE]$mandi_id),
        n_control = uniqueN(cd[enam_treated == FALSE]$mandi_id)
      ))
    }, error = function(e) NULL)
  }
}

fwrite(estimates, file.path(tab_dir, "main_estimates.csv"))
cat("✓ Saved main_results.RData and main_estimates.csv\n")

## Print summary table
cat("\n══════════════════════════════════════════════════════\n")
cat("  MAIN RESULTS SUMMARY\n")
cat("══════════════════════════════════════════════════════\n")
if (nrow(estimates) > 0) {
  print(estimates[, .(commodity, estimator,
                      ATT = round(att, 4),
                      SE = round(se, 4),
                      p = round(pvalue, 3),
                      N_treat = n_treated,
                      N_ctrl = n_control)])
}
cat("══════════════════════════════════════════════════════\n")
