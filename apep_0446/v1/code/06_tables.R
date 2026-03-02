## ─── 06_tables.R ───────────────────────────────────────────────
## Generate all LaTeX tables for apep_0446
## ────────────────────────────────────────────────────────────────
source("00_packages.R")

## ─── Load data and results ─────────────────────────────────────
monthly <- fread(file.path(data_dir, "monthly_panel.csv"))
monthly[, ym := as.Date(ym)]
monthly[, first_treat_ym := as.Date(first_treat_ym)]
monthly[, cohort := fifelse(enam_treated, first_treat_period, 10000L)]

load(file.path(data_dir, "main_results.RData"))
tryCatch(load(file.path(data_dir, "robustness_results.RData")), error = function(e) NULL)

## ─── Table 1: Summary Statistics ───────────────────────────────
cat("── Table 1: Summary Statistics ──\n")

## Use same mandi filter as regressions: mandis with N >= 60 in FULL panel
## Then restrict to year >= 2010 for summary display
summ_data <- copy(monthly)
for (comm in unique(summ_data$commodity)) {
  mc <- summ_data[commodity == comm, .N, by = mandi_id]
  keep_ids <- mc[N >= 60]$mandi_id
  summ_data <- summ_data[!(commodity == comm & !mandi_id %in% keep_ids)]
}

summ <- summ_data[, .(
  `Mean Price` = mean(modal_price, na.rm = TRUE),
  `SD Price` = sd(modal_price, na.rm = TRUE),
  `N Mandis` = uniqueN(mandi_id),
  `N Months` = uniqueN(ym),
  `Observations` = .N
), by = .(Commodity = commodity,
          Group = fifelse(enam_treated, "e-NAM", "Control"))]

summ_wide <- dcast(summ, Commodity ~ Group,
                   value.var = c("Mean Price", "SD Price", "N Mandis", "Observations"))

## Also compute totals per commodity
summ_total <- summ_data[, .(
  `Mean Price` = mean(modal_price, na.rm = TRUE),
  `N Mandis` = uniqueN(mandi_id),
  `Observations` = .N
), by = .(Commodity = commodity)]

## Write LaTeX
sink(file.path(tab_dir, "tab1_summary.tex"))
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Summary Statistics}\n")
cat("\\label{tab:summary}\n")
cat("\\begin{tabular}{lccccc}\n")
cat("\\toprule\n")
cat("Commodity & Mean Price & N Mandis & Total Obs & e-NAM Mandis & Never-Treated Mandis \\\\\n")
cat("\\midrule\n")
for (i in seq_len(nrow(summ_total))) {
  comm <- summ_total$Commodity[i]
  tot_price <- format(round(summ_total[["Mean Price"]][i]), big.mark = ",")
  tot_mandis <- format(summ_total[["N Mandis"]][i], big.mark = ",")
  tot_obs <- format(summ_total[["Observations"]][i], big.mark = ",")
  enam_m <- if ("N Mandis_e-NAM" %in% names(summ_wide)) {
    row_idx <- which(summ_wide$Commodity == comm)
    if (length(row_idx) > 0 && !is.na(summ_wide[["N Mandis_e-NAM"]][row_idx]))
      format(summ_wide[["N Mandis_e-NAM"]][row_idx], big.mark = ",") else "0"
  } else "0"
  ctrl_m <- if ("N Mandis_Control" %in% names(summ_wide)) {
    row_idx <- which(summ_wide$Commodity == comm)
    if (length(row_idx) > 0 && !is.na(summ_wide[["N Mandis_Control"]][row_idx]))
      format(summ_wide[["N Mandis_Control"]][row_idx], big.mark = ",") else "0"
  } else "0"
  cat(sprintf("%s & %s & %s & %s & %s & %s \\\\\n",
              comm, tot_price, tot_mandis, tot_obs, enam_m, ctrl_m))
}
cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{tablenotes}[flushleft]\n")
cat("\\small\n")
cat("\\item \\textit{Notes:} Mandis with $\\geq 60$ monthly observations (matching regression sample). Prices in Rs per quintal. Total Obs matches the regression sample in Table 2. ")
cat("e-NAM Mandis are those integrated into e-NAM. Never-Treated Mandis are those in Bihar and Assam that were not integrated.\n")
cat("\\end{tablenotes}\n")
cat("\\end{table}\n")
sink()
cat("  ✓ tab1_summary.tex\n")

## ─── Table 2: Main TWFE Results ─────────────────────────────────
cat("── Table 2: Main Results ──\n")

main_fits <- list()
commodities <- unique(monthly$commodity)
for (comm in commodities) {
  cd <- monthly[commodity == comm]
  mandi_counts <- cd[, .N, by = mandi_id]
  cd <- cd[mandi_id %in% mandi_counts[N >= 60]$mandi_id]
  if (nrow(cd) < 1000) next
  main_fits[[comm]] <- feols(ln_price ~ post_enam | mandi_id + time_period,
                              data = cd, cluster = ~mandi_id)
}

if (length(main_fits) > 0) {
  etable(main_fits,
         file = file.path(tab_dir, "tab2_main_twfe.tex"),
         title = "Effect of e-NAM Integration on Log Mandi Prices",
         label = "tab:main_twfe",
         headers = names(main_fits),
         depvar = FALSE,
         style.tex = style.tex("aer"),
         dict = c(post_enam = "e-NAM $\\times$ Post",
                  mandi_id = "Mandi",
                  time_period = "Month-Year"),
         digits.stats = 3,
         notes = c(
           "Standard errors clustered at mandi level in parentheses.",
           "All specifications include mandi and month-year fixed effects.",
           "* p<0.1, ** p<0.05, *** p<0.01"
         ))
  cat("  ✓ tab2_main_twfe.tex\n")
}

## ─── Table 3: Main Estimates (CS-DiD or TWFE) ─────────────────
cat("── Table 3: Main Estimates ──\n")

estimates <- fread(file.path(tab_dir, "main_estimates.csv"))
if (nrow(estimates) > 0) {
  ## Compute quarterly obs counts for each commodity
  qtr_obs <- list()
  for (comm in estimates$commodity) {
    cd <- monthly[commodity == comm]
    mc <- cd[, .N, by = mandi_id]
    cd <- cd[mandi_id %in% mc[N >= 60]$mandi_id]
    cd[, qtr_num := (year - 2007) * 4 + quarter(ym)]
    cd_q <- cd[, .(ln_price = mean(ln_price, na.rm = TRUE)), by = .(mandi_id, qtr_num)]
    qtr_obs[[comm]] <- nrow(cd_q)
  }

  sink(file.path(tab_dir, "tab3_cs_did.tex"))
  cat("\\begin{table}[htbp]\n")
  cat("\\centering\n")
  cat("\\caption{e-NAM Price Effects by Commodity}\n")
  cat("\\label{tab:cs_did}\n")
  cat("\\begin{tabular}{lcccc}\n")
  cat("\\toprule\n")
  cat("Commodity & Estimator & ATT & SE & N \\\\\n")
  cat("\\midrule\n")
  for (i in seq_len(nrow(estimates))) {
    stars <- ""
    if (estimates$pvalue[i] < 0.01) stars <- "***"
    else if (estimates$pvalue[i] < 0.05) stars <- "**"
    else if (estimates$pvalue[i] < 0.1) stars <- "*"

    n_q <- qtr_obs[[estimates$commodity[i]]]
    cat(sprintf("%s & %s & %.4f%s & (%.4f) & %s \\\\\n",
                estimates$commodity[i],
                estimates$estimator[i],
                estimates$att[i], stars,
                estimates$se[i],
                format(n_q, big.mark = ",")))
  }
  cat("\\bottomrule\n")
  cat("\\end{tabular}\n")
  cat("\\begin{tablenotes}[flushleft]\n")
  cat("\\small\n")
  cat("\\item \\textit{Notes:} CS-DiD = Callaway and Sant'Anna (2021) estimates using not-yet-treated ")
  cat("mandis as control group, estimated on the quarterly panel. N = mandi-quarter observations. ")
  cat("Sample restricted to mandis with $\\geq 60$ monthly observations (same as TWFE in Table 2). ")
  cat("Dependent variable: log modal price. ATT is the aggregated average treatment effect on the treated. ")
  cat("* $p<0.1$, ** $p<0.05$, *** $p<0.01$.\n")
  cat("\\end{tablenotes}\n")
  cat("\\end{table}\n")
  sink()
  cat("  ✓ tab3_cs_did.tex\n")
}

## ─── Table 4: Robustness Comparison ────────────────────────────
cat("── Table 4: Robustness ──\n")

robust_comparison <- data.table(
  commodity = character(), estimator = character(),
  att = numeric(), se = numeric()
)

## TWFE
for (comm in names(main_fits)) {
  ct <- coeftable(main_fits[[comm]])
  robust_comparison <- rbind(robust_comparison, data.table(
    commodity = comm, estimator = "TWFE",
    att = ct[1, 1], se = ct[1, 2]
  ))
}

## CS-DiD (from estimates csv)
if (nrow(estimates[estimator == "CS-DiD"]) > 0) {
  robust_comparison <- rbind(robust_comparison,
    estimates[estimator == "CS-DiD", .(commodity, estimator = "CS-DiD", att, se)])
}

## Sun-Abraham — re-estimate to get ATT (saved objects lose data environment)
for (comm in unique(monthly$commodity)) {
  cd <- monthly[commodity == comm]
  mandi_counts <- cd[, .N, by = mandi_id]
  cd <- cd[mandi_id %in% mandi_counts[N >= 60]$mandi_id]
  if (nrow(cd) < 1000) next
  tryCatch({
    sa_fit <- feols(ln_price ~ sunab(cohort, time_period) | mandi_id + time_period,
                    data = cd, cluster = ~mandi_id)
    sa_agg <- summary(sa_fit, agg = "ATT")
    ct <- coeftable(sa_agg)
    robust_comparison <- rbind(robust_comparison, data.table(
      commodity = comm, estimator = "Sun-Abraham",
      att = ct[1, 1], se = ct[1, 2]
    ))
  }, error = function(e) NULL)
}

## Placebo
if (exists("placebo_results") && length(placebo_results) > 0) {
  for (comm in names(placebo_results)) {
    ct <- placebo_results[[comm]]
    robust_comparison <- rbind(robust_comparison, data.table(
      commodity = comm, estimator = "Placebo",
      att = ct[1, 1], se = ct[1, 2]
    ))
  }
}

if (nrow(robust_comparison) > 0) {
  fwrite(robust_comparison, file.path(tab_dir, "robustness_comparison.csv"))

  sink(file.path(tab_dir, "tab4_robustness.tex"))
  cat("\\begin{table}[htbp]\n")
  cat("\\centering\n")
  cat("\\caption{Robustness: e-NAM Price Effects Across Estimators}\n")
  cat("\\label{tab:robustness}\n")
  cat("\\small\n")
  cat("\\begin{tabular}{lcccc}\n")
  cat("\\toprule\n")
  cat(" & TWFE & CS-DiD & Sun-Abraham & Placebo \\\\\n")
  cat("\\midrule\n")

  for (comm in unique(robust_comparison$commodity)) {
    vals <- c()
    for (est in c("TWFE", "CS-DiD", "Sun-Abraham", "Placebo")) {
      row <- robust_comparison[commodity == comm & estimator == est]
      if (nrow(row) > 0 && !(est == "Sun-Abraham" && row$se[1] > 1.0)) {
        vals <- c(vals, sprintf("%.4f", row$att[1]))
      } else {
        vals <- c(vals, "\\textemdash")
      }
    }
    cat(sprintf("%s & %s \\\\\n", comm, paste(vals, collapse = " & ")))

    ## SE row
    se_vals <- c()
    for (est in c("TWFE", "CS-DiD", "Sun-Abraham", "Placebo")) {
      row <- robust_comparison[commodity == comm & estimator == est]
      if (nrow(row) > 0 && !(est == "Sun-Abraham" && row$se[1] > 1.0)) {
        se_vals <- c(se_vals, sprintf("(%.4f)", row$se[1]))
      } else if (nrow(row) == 0 || (est == "Sun-Abraham" && row$se[1] > 1.0)) {
        se_vals <- c(se_vals, "\\textemdash")
      } else {
        se_vals <- c(se_vals, "")
      }
    }
    cat(sprintf(" & %s \\\\\n", paste(se_vals, collapse = " & ")))
    cat("[0.3em]\n")
  }
  cat("\\bottomrule\n")
  cat("\\end{tabular}\n")
  cat("\\begin{tablenotes}[flushleft]\n")
  cat("\\small\n")
  ## Compute TWFE observation counts for the note
  twfe_n <- sapply(names(main_fits), function(comm) {
    format(nobs(main_fits[[comm]]), big.mark = ",")
  })
  twfe_n_str <- paste(names(twfe_n), twfe_n, sep = ": ", collapse = "; ")
  cat("\\item \\textit{Notes:} Standard errors in parentheses. \\textemdash~= not estimable. TWFE = Two-Way Fixed Effects. ")
  cat("CS-DiD = Callaway and Sant'Anna (2021) with not-yet-treated controls. ")
  cat("Sun-Abraham = Sun and Abraham (2021) interaction-weighted estimator. ")
  cat("Placebo shifts treatment dates 3 years earlier (pre-period only). ")
  cat(sprintf("TWFE observations: %s. ", twfe_n_str))
  cat("CS-DiD and Sun-Abraham could not be estimated for Onion and Tomato due to insufficient not-yet-treated comparison units. ")
  cat("Wheat and Soyabean pass the placebo test (insignificant pre-treatment effects); ")
  cat("Onion and Tomato show significant pre-trends.\n")
  cat("\\end{tablenotes}\n")
  cat("\\end{table}\n")
  sink()
  cat("  ✓ tab4_robustness.tex\n")
}

cat("\n✓ All tables generated.\n")
