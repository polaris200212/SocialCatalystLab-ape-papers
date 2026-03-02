## ============================================================================
## 06_tables.R — All tables for the Civil War pension RDD paper
## Project: The First Retirement Age (apep_0442)
## ============================================================================

source("code/00_packages.R")

union <- readRDS(file.path(data_dir, "union_veterans.rds"))
confed <- readRDS(file.path(data_dir, "confed_veterans.rds"))
main_results <- readRDS(file.path(data_dir, "main_results.rds"))
secondary_results <- readRDS(file.path(data_dir, "secondary_results.rds"))
robust_results <- readRDS(file.path(data_dir, "robust_results.rds"))
balance_results <- readRDS(file.path(data_dir, "balance_results.rds"))

union[, white := as.integer(RACE == 1)]

## ---- Table 1: Summary Statistics ----
cat("Table 1: Summary statistics...\n")

# Panel A: Union Veterans
union_stats <- union[, .(
  N = .N,
  `Mean Age` = round(mean(AGE), 1),
  `LFP Rate` = round(mean(in_labor_force, na.rm = TRUE), 3),
  `Has Occupation` = round(mean(has_occupation, na.rm = TRUE), 3),
  `Owns Home` = round(mean(owns_home, na.rm = TRUE), 3),
  `Household Head` = round(mean(is_head, na.rm = TRUE), 3),
  `Literate` = round(mean(literate, na.rm = TRUE), 3),
  `Married` = round(mean(married, na.rm = TRUE), 3),
  `Native Born` = round(mean(native_born, na.rm = TRUE), 3),
  `White` = round(mean(white, na.rm = TRUE), 3),
  `Urban` = round(mean(urban, na.rm = TRUE), 3)
)]

# Split by above/below 62
union_split <- union[, .(
  N = .N,
  `LFP Rate` = round(mean(in_labor_force, na.rm = TRUE), 3),
  `Has Occupation` = round(mean(has_occupation, na.rm = TRUE), 3),
  `Owns Home` = round(mean(owns_home, na.rm = TRUE), 3),
  `Household Head` = round(mean(is_head, na.rm = TRUE), 3),
  `Literate` = round(mean(literate, na.rm = TRUE), 3),
  `Married` = round(mean(married, na.rm = TRUE), 3)
), by = .(Group = fifelse(AGE < 62, "Below 62", "62 and Above"))]

# Confederate comparison
confed_stats <- confed[, .(
  N = .N,
  `Mean Age` = round(mean(AGE), 1),
  `LFP Rate` = round(mean(in_labor_force, na.rm = TRUE), 3),
  `Has Occupation` = round(mean(has_occupation, na.rm = TRUE), 3),
  `Owns Home` = round(mean(owns_home, na.rm = TRUE), 3),
  `Household Head` = round(mean(is_head, na.rm = TRUE), 3),
  `Literate` = round(mean(literate, na.rm = TRUE), 3),
  `Married` = round(mean(married, na.rm = TRUE), 3)
)]

# Write LaTeX table
tab1_lines <- c(
  "\\begin{table}[htbp]",
  "\\centering",
  "\\caption{Summary Statistics: Civil War Veterans in the 1910 Census}",
  "\\label{tab:summary}",
  "\\begin{tabular}{lcccc}",
  "\\hline\\hline",
  " & \\multicolumn{3}{c}{Union Veterans} & Confederate \\\\",
  "\\cmidrule(lr){2-4} \\cmidrule(lr){5-5}",
  " & All & Age $<$ 62 & Age $\\geq$ 62 & All \\\\",
  "\\hline"
)

# Add rows
vars_to_show <- c("N", "LFP Rate", "Has Occupation", "Owns Home",
                   "Household Head", "Literate", "Married")

for (v in vars_to_show) {
  all_val <- union_stats[[v]]
  below_val <- union_split[Group == "Below 62"][[v]]
  above_val <- union_split[Group == "62 and Above"][[v]]
  confed_val <- if (v %in% names(confed_stats)) confed_stats[[v]] else "---"

  if (v == "N") {
    tab1_lines <- c(tab1_lines, sprintf(
      "N & %s & %s & %s & %s \\\\",
      format(all_val, big.mark = ","),
      format(below_val, big.mark = ","),
      format(above_val, big.mark = ","),
      format(confed_val, big.mark = ",")))
  } else {
    tab1_lines <- c(tab1_lines, sprintf(
      "%s & %.3f & %.3f & %.3f & %s \\\\",
      v, all_val, below_val, above_val,
      if (is.numeric(confed_val)) sprintf("%.3f", confed_val) else confed_val))
  }
}

tab1_lines <- c(tab1_lines,
  "\\hline\\hline",
  "\\multicolumn{5}{p{0.85\\textwidth}}{\\footnotesize \\textit{Notes:}",
  "Summary statistics for Union and Confederate Civil War veterans in the",
  "1910 IPUMS 1\\% census sample. Veterans identified via the VETCIVWR variable.",
  "LFP = labor force participation rate.} \\\\",
  "\\end{tabular}",
  "\\end{table}"
)

writeLines(tab1_lines, file.path(tab_dir, "tab1_summary.tex"))

## ---- Table 2: Main RDD Results ----
cat("Table 2: Main RDD results...\n")

rd_lfp <- main_results$lfp

tab2_lines <- c(
  "\\begin{table}[htbp]",
  "\\centering",
  "\\caption{Effect of Pension Eligibility on Labor Force Participation: RDD at Age 62}",
  "\\label{tab:main_rdd}",
  "\\begin{tabular}{lcccc}",
  "\\hline\\hline",
  " & (1) & (2) & (3) & (4) \\\\",
  " & Linear & Quadratic & Bias-Corrected & Robust \\\\",
  "\\hline",
  sprintf("RD Estimate & %.3f & & %.3f & %.3f \\\\",
          rd_lfp$coef["Conventional", 1],
          rd_lfp$coef["Bias-Corrected", 1],
          rd_lfp$coef["Robust", 1]),
  sprintf("Std. Error & (%.3f) & & (%.3f) & (%.3f) \\\\",
          rd_lfp$se["Conventional", 1],
          rd_lfp$se["Robust", 1],
          rd_lfp$se["Robust", 1]),
  sprintf("$p$-value & %.3f & & %.3f & %.3f \\\\",
          rd_lfp$pv["Conventional", 1],
          rd_lfp$pv["Robust", 1],
          rd_lfp$pv["Robust", 1]),
  sprintf("95\\%% CI & [%.3f, %.3f] & & [%.3f, %.3f] & [%.3f, %.3f] \\\\",
          rd_lfp$coef["Conventional", 1] - 1.96 * rd_lfp$se["Conventional", 1],
          rd_lfp$coef["Conventional", 1] + 1.96 * rd_lfp$se["Conventional", 1],
          rd_lfp$coef["Bias-Corrected", 1] - 1.96 * rd_lfp$se["Robust", 1],
          rd_lfp$coef["Bias-Corrected", 1] + 1.96 * rd_lfp$se["Robust", 1],
          rd_lfp$coef["Robust", 1] - 1.96 * rd_lfp$se["Robust", 1],
          rd_lfp$coef["Robust", 1] + 1.96 * rd_lfp$se["Robust", 1])
)

# Add quadratic
tryCatch({
  rd_quad <- rdrobust(union$in_labor_force, union$AGE, c = 62,
                       kernel = "triangular", p = 2)
  tab2_lines[10] <- sprintf("RD Estimate & %.3f & %.3f & %.3f & %.3f \\\\",
          rd_lfp$coef["Conventional", 1],
          rd_quad$coef["Conventional", 1],
          rd_lfp$coef["Bias-Corrected", 1],
          rd_lfp$coef["Robust", 1])
  tab2_lines[11] <- sprintf("Std. Error & (%.3f) & (%.3f) & (%.3f) & (%.3f) \\\\",
          rd_lfp$se["Conventional", 1],
          rd_quad$se["Conventional", 1],
          rd_lfp$se["Robust", 1],
          rd_lfp$se["Robust", 1])
  tab2_lines[12] <- sprintf("$p$-value & %.3f & %.3f & %.3f & %.3f \\\\",
          rd_lfp$pv["Conventional", 1],
          rd_quad$pv["Conventional", 1],
          rd_lfp$pv["Robust", 1],
          rd_lfp$pv["Robust", 1])
  tab2_lines[13] <- sprintf("95\\%% CI & [%.3f, %.3f] & [%.3f, %.3f] & [%.3f, %.3f] & [%.3f, %.3f] \\\\",
          rd_lfp$coef["Conventional", 1] - 1.96 * rd_lfp$se["Conventional", 1],
          rd_lfp$coef["Conventional", 1] + 1.96 * rd_lfp$se["Conventional", 1],
          rd_quad$coef["Conventional", 1] - 1.96 * rd_quad$se["Conventional", 1],
          rd_quad$coef["Conventional", 1] + 1.96 * rd_quad$se["Conventional", 1],
          rd_lfp$coef["Bias-Corrected", 1] - 1.96 * rd_lfp$se["Robust", 1],
          rd_lfp$coef["Bias-Corrected", 1] + 1.96 * rd_lfp$se["Robust", 1],
          rd_lfp$coef["Robust", 1] - 1.96 * rd_lfp$se["Robust", 1],
          rd_lfp$coef["Robust", 1] + 1.96 * rd_lfp$se["Robust", 1])
}, error = function(e) {})

## Get quadratic bandwidth/N if available
quad_bw_str <- sprintf("%.1f / %.1f", rd_lfp$bws["h", "left"], rd_lfp$bws["h", "right"])
quad_n_str <- sprintf("%d + %d", rd_lfp$N_h[1], rd_lfp$N_h[2])
tryCatch({
  quad_bw_str <- sprintf("%.1f / %.1f", rd_quad$bws["h", "left"], rd_quad$bws["h", "right"])
  quad_n_str <- sprintf("%d + %d", rd_quad$N_h[1], rd_quad$N_h[2])
}, error = function(e) {})

tab2_lines <- c(tab2_lines,
  "\\hline",
  sprintf("Bandwidth (left/right) & %.1f / %.1f & %s & %.1f / %.1f & %.1f / %.1f \\\\",
          rd_lfp$bws["h", "left"], rd_lfp$bws["h", "right"],
          quad_bw_str,
          rd_lfp$bws["h", "left"], rd_lfp$bws["h", "right"],
          rd_lfp$bws["h", "left"], rd_lfp$bws["h", "right"]),
  sprintf("Eff. N (left + right) & %d + %d & %s & %d + %d & %d + %d \\\\",
          rd_lfp$N_h[1], rd_lfp$N_h[2],
          quad_n_str,
          rd_lfp$N_h[1], rd_lfp$N_h[2],
          rd_lfp$N_h[1], rd_lfp$N_h[2]),
  sprintf("Total N & %s & %s & %s & %s \\\\",
          format(sum(rd_lfp$N), big.mark = ","),
          format(sum(rd_lfp$N), big.mark = ","),
          format(sum(rd_lfp$N), big.mark = ","),
          format(sum(rd_lfp$N), big.mark = ",")),
  "Kernel & Triangular & Triangular & Triangular & Triangular \\\\",
  "\\hline\\hline",
  "\\multicolumn{5}{p{0.9\\textwidth}}{\\footnotesize \\textit{Notes:}",
  "Sharp RDD estimates of the effect of crossing the age 62 pension eligibility",
  "threshold on labor force participation among Union Civil War veterans.",
  "Column (1): local linear with MSE-optimal bandwidth.",
  "Column (2): local quadratic.",
  "Column (3): bias-corrected estimate with robust standard errors.",
  "Column (4): robust bias-corrected (same as Column 3; shown for completeness).",
  "Columns (3)--(4) use the same bandwidth as Column (1).",
  "The bias-corrected estimate adjusts the coefficient for estimation bias; robust",
  "standard errors account for additional variability from the bias correction.",
  "Running variable: age. Cutoff: 62.",
  sprintf("Full Union veteran sample: $N = %s$.} \\\\", format(3666, big.mark = ",")),
  "\\end{tabular}",
  "\\end{table}"
)

writeLines(tab2_lines, file.path(tab_dir, "tab2_main_rdd.tex"))

## ---- Table 3: Secondary Outcomes ----
cat("Table 3: Secondary outcomes...\n")

if (nrow(secondary_results) > 0) {
  tab3_lines <- c(
    "\\begin{table}[htbp]",
    "\\centering",
    "\\caption{RDD Estimates for Secondary Outcomes at the Age 62 Threshold}",
    "\\label{tab:secondary}",
    "\\begin{tabular}{lccccc}",
    "\\hline\\hline",
    "Outcome & RD Est. & SE & $p$-value & Bandwidth & Eff. N \\\\",
    "\\hline"
  )

  for (i in seq_len(nrow(secondary_results))) {
    r <- secondary_results[i]
    stars <- ifelse(r$pvalue < 0.01, "***",
                    ifelse(r$pvalue < 0.05, "**",
                           ifelse(r$pvalue < 0.10, "*", "")))
    tab3_lines <- c(tab3_lines, sprintf(
      "%s & %.4f%s & (%.4f) & %.3f & %.1f & %s \\\\",
      r$outcome, r$coef, stars, r$se, r$pvalue,
      r$bw_left, format(round(r$n_eff), big.mark = ",")))
  }

  tab3_lines <- c(tab3_lines,
    "\\hline",
    sprintf("\\multicolumn{6}{l}{Total N = %s} \\\\",
            format(sum(readRDS(file.path(data_dir, "main_results.rds"))$lfp$N), big.mark = ",")),
    "\\hline\\hline",
    "\\multicolumn{6}{p{0.9\\textwidth}}{\\footnotesize \\textit{Notes:}",
    "Sharp RDD estimates at the age 62 pension eligibility threshold for Union",
    "Civil War veterans. Local linear estimation with triangular kernel and",
    "MSE-optimal bandwidth. Total N is the full Union veteran sample; effective",
    "N varies by outcome due to outcome-specific optimal bandwidths.",
    "$^{***}p<0.01$, $^{**}p<0.05$, $^{*}p<0.10$.} \\\\",
    "\\end{tabular}",
    "\\end{table}"
  )

  writeLines(tab3_lines, file.path(tab_dir, "tab3_secondary.tex"))
}

## ---- Table 4: Robustness ----
cat("Table 4: Robustness...\n")

## Use main_results for the optimal bandwidth to ensure Table 2 / Table 4 consistency
rd_lfp_main <- main_results$lfp
opt_bw <- rd_lfp_main$bws["h", "left"]

tab4_lines <- c(
  "\\begin{table}[htbp]",
  "\\centering",
  "\\caption{Robustness of Main RDD Estimate (Labor Force Participation)}",
  "\\label{tab:robustness}",
  "\\begin{tabular}{lcccc}",
  "\\hline\\hline",
  "Specification & RD Estimate & SE & $p$-value & Eff. N \\\\",
  "\\hline",
  "\\multicolumn{5}{l}{\\textit{Panel A: Bandwidth Sensitivity}} \\\\"
)

if (!is.null(robust_results$bandwidth)) {
  for (i in seq_len(nrow(robust_results$bandwidth))) {
    r <- robust_results$bandwidth[i]
    ## For the row closest to the optimal bandwidth, use main_results directly
    if (abs(r$bandwidth - round(opt_bw, 1)) < 0.05) {
      tab4_lines <- c(tab4_lines, sprintf(
        "\\quad $h = %.1f$ (optimal) & %.4f & (%.4f) & %.3f & %s \\\\",
        r$bandwidth,
        rd_lfp_main$coef["Conventional", 1],
        rd_lfp_main$se["Conventional", 1],
        rd_lfp_main$pv["Conventional", 1],
        format(r$n_left + r$n_right, big.mark = ",")))
    } else {
      tab4_lines <- c(tab4_lines, sprintf(
        "\\quad $h = %.1f$ & %.4f & (%.4f) & %.3f & %s \\\\",
        r$bandwidth, r$coef, r$se, r$pvalue,
        format(r$n_left + r$n_right, big.mark = ",")))
    }
  }
}

tab4_lines <- c(tab4_lines,
  "\\hline",
  "\\multicolumn{5}{l}{\\textit{Panel B: Donut-Hole Specifications}} \\\\"
)

if (!is.null(robust_results$donut)) {
  for (i in seq_len(nrow(robust_results$donut))) {
    r <- robust_results$donut[i]
    n_eff <- if ("n_eff" %in% names(r)) format(r$n_eff, big.mark = ",") else "---"
    tab4_lines <- c(tab4_lines, sprintf(
      "\\quad Exclude %s & %.4f & (%.4f) & %.3f & %s \\\\",
      r$excluded, r$coef, r$se, r$pvalue, n_eff))
  }
}

# Literacy-controlled RDD
if (!is.null(robust_results$literacy_controlled)) {
  r <- robust_results$literacy_controlled
  lc_n_eff <- if ("n_eff" %in% names(r)) format(round(r$n_eff), big.mark = ",") else "---"
  tab4_lines <- c(tab4_lines, sprintf(
    "\\quad Literacy-controlled & %.4f & (%.4f) & %.3f & %s \\\\",
    r$coef, r$se, r$pvalue, lc_n_eff))
}

tab4_lines <- c(tab4_lines,
  "\\hline",
  "\\multicolumn{5}{l}{\\textit{Panel C: Placebo Populations}} \\\\"
)

# Confederate placebo
if (!is.null(main_results$confed_lfp)) {
  r <- main_results$confed_lfp
  confed_n_eff <- format(sum(r$N_h), big.mark = ",")
  tab4_lines <- c(tab4_lines, sprintf(
    "\\quad Confederate veterans & %.4f & (%.4f) & %.3f & %s \\\\",
    r$coef["Conventional", 1], r$se["Conventional", 1], r$pv["Conventional", 1],
    confed_n_eff))
}

# Non-veteran placebo
if (!is.null(robust_results$nonvet_placebo)) {
  r <- robust_results$nonvet_placebo
  nv_n_eff <- if ("n_eff" %in% names(r)) format(round(r$n_eff), big.mark = ",") else "---"
  tab4_lines <- c(tab4_lines, sprintf(
    "\\quad Non-veterans & %.4f & (%.4f) & %.3f & %s \\\\",
    r$coef, r$se, r$pvalue, nv_n_eff))
}

tab4_lines <- c(tab4_lines,
  "\\hline",
  "\\multicolumn{5}{l}{\\textit{Panel D: Multi-Cutoff}} \\\\"
)

if (!is.null(robust_results$multi_cutoff)) {
  for (i in seq_len(nrow(robust_results$multi_cutoff))) {
    r <- robust_results$multi_cutoff[i]
    mc_n_eff <- if ("n_eff" %in% names(r)) format(round(r$n_eff), big.mark = ",") else "---"
    ## Escape $ signs in pension_amount for LaTeX
    pension_label <- gsub("\\$", "\\\\$", r$pension_amount)
    tab4_lines <- c(tab4_lines, sprintf(
      "\\quad Age %d (%s/mo) & %.4f & (%.4f) & %.3f & %s \\\\",
      r$cutoff, pension_label, r$coef, r$se, r$pvalue, mc_n_eff))
  }
}

## Panel E: Alternative Kernels
tab4_lines <- c(tab4_lines,
  "\\hline",
  "\\multicolumn{5}{l}{\\textit{Panel E: Alternative Kernels}} \\\\"
)

if (!is.null(robust_results$kernel)) {
  ## Compute Eff. N for each kernel by re-running rdrobust
  for (i in seq_len(nrow(robust_results$kernel))) {
    r <- robust_results$kernel[i]
    if (r$kernel == "triangular") next  # already shown in main table
    kern_label <- tools::toTitleCase(r$kernel)
    kern_n_eff <- "---"
    tryCatch({
      rd_kern <- rdrobust(union$in_labor_force, union$AGE, c = 62,
                           kernel = r$kernel, p = 1)
      kern_n_eff <- format(sum(rd_kern$N_h), big.mark = ",")
    }, error = function(e) {})
    tab4_lines <- c(tab4_lines, sprintf(
      "\\quad %s & %.4f & (%.4f) & %.3f & %s \\\\",
      kern_label, r$coef, r$se, r$pvalue, kern_n_eff))
  }
}

tab4_lines <- c(tab4_lines,
  "\\hline\\hline",
  "\\multicolumn{5}{p{0.95\\textwidth}}{\\footnotesize \\textit{Notes:}",
  "Panel A varies the bandwidth around the MSE-optimal choice. Panel B excludes",
  "ages near the cutoff to address age heaping. Panel C applies the same RDD at",
  "age 62 to populations that should show no discontinuity (Confederate veterans",
  "had no federal pension; non-veterans had no pension at all). Panel D estimates",
  "the RDD at additional pension thresholds where monthly amounts increased.",
  "Panel E shows results with alternative kernel functions.",
  sprintf("Eff. N = effective number of observations within the bandwidth. Full Union veteran sample: $N = %s$.} \\\\",
          format(sum(main_results$lfp$N), big.mark = ",")),
  "\\end{tabular}",
  "\\end{table}"
)

writeLines(tab4_lines, file.path(tab_dir, "tab4_robustness.tex"))

## ---- Table 5: Covariate Balance ----
cat("Table 5: Covariate balance...\n")

if (nrow(balance_results) > 0) {
  ## Covariate display name mapping (fixes "Nativeborn" typo)
  cov_labels <- c(
    literate    = "Literate",
    native_born = "Native Born",
    married     = "Married",
    urban       = "Urban",
    white       = "White"
  )

  ## Re-run rdrobust per covariate to extract bandwidth and effective N
  bal_bw   <- numeric(nrow(balance_results))
  bal_neff <- integer(nrow(balance_results))
  for (i in seq_len(nrow(balance_results))) {
    cov_name <- balance_results[i]$covariate
    tryCatch({
      rd_bal <- rdrobust(union[[cov_name]], union$AGE, c = 62,
                         kernel = "triangular", p = 1)
      bal_bw[i]   <- rd_bal$bws["h", "left"]
      bal_neff[i] <- sum(rd_bal$N_h)
    }, error = function(e) {
      bal_bw[i]   <<- NA
      bal_neff[i] <<- NA
    })
  }

  tab5_lines <- c(
    "\\begin{table}[htbp]",
    "\\centering",
    "\\caption{Covariate Balance at the Age 62 Threshold}",
    "\\label{tab:balance}",
    "\\begin{tabular}{lcccc}",
    "\\hline\\hline",
    "Covariate & RD Estimate & SE & $p$-value & Bandwidth / Eff. N \\\\",
    "\\hline"
  )

  for (i in seq_len(nrow(balance_results))) {
    r <- balance_results[i]
    label <- if (r$covariate %in% names(cov_labels)) cov_labels[r$covariate] else tools::toTitleCase(r$covariate)
    bw_str <- if (!is.na(bal_bw[i])) sprintf("%.1f / %s", bal_bw[i], format(bal_neff[i], big.mark = ",")) else "---"
    tab5_lines <- c(tab5_lines, sprintf(
      "%s & %.4f & (%.4f) & %.3f & %s \\\\",
      label, r$rd_estimate, r$se, r$pvalue, bw_str))
  }

  tab5_lines <- c(tab5_lines,
    "\\hline\\hline",
    "\\multicolumn{5}{p{0.9\\textwidth}}{\\footnotesize \\textit{Notes:}",
    "RDD estimates at the age 62 threshold for pre-determined covariates.",
    "None should show a discontinuity if the RDD is valid. Local linear",
    "estimation with triangular kernel and MSE-optimal bandwidth.",
    "Bandwidth / Eff. N reports the MSE-optimal bandwidth and effective",
    "number of observations within the bandwidth for each covariate.} \\\\",
    "\\end{tabular}",
    "\\end{table}"
  )

  writeLines(tab5_lines, file.path(tab_dir, "tab5_balance.tex"))
}

cat("\nAll tables saved to", tab_dir, "\n")
