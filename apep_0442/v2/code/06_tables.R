## ============================================================================
## 06_tables.R — All tables for the Civil War pension RDD paper (v2)
## Project: The First Retirement Age v2 (revision of apep_0442)
## AER-style formatting: SEs in parentheses, significance stars, N_left/N_right
## ============================================================================

source("code/00_packages.R")

union <- readRDS(file.path(data_dir, "union_veterans.rds"))
confed <- readRDS(file.path(data_dir, "confed_veterans.rds"))
main_results <- readRDS(file.path(data_dir, "main_results.rds"))
secondary_results <- readRDS(file.path(data_dir, "secondary_results.rds"))
robust_results <- readRDS(file.path(data_dir, "robust_results.rds"))
balance_results <- readRDS(file.path(data_dir, "balance_results.rds"))

stars <- function(p) {
  ifelse(p < 0.01, "^{***}", ifelse(p < 0.05, "^{**}", ifelse(p < 0.10, "^{*}", "")))
}

## ---- Table 1: Summary Statistics ----
cat("Table 1: Summary statistics...\n")

union_below <- union[AGE < 62]
union_above <- union[AGE >= 62]

make_row <- function(var, label, data_all, data_below, data_above, data_confed, is_count = FALSE) {
  if (is_count) {
    sprintf("%s & %s & %s & %s & %s \\\\",
            label,
            format(nrow(data_all), big.mark = ","),
            format(nrow(data_below), big.mark = ","),
            format(nrow(data_above), big.mark = ","),
            format(nrow(data_confed), big.mark = ","))
  } else {
    sprintf("%s & %.3f & %.3f & %.3f & %.3f \\\\",
            label,
            mean(data_all[[var]], na.rm = TRUE),
            mean(data_below[[var]], na.rm = TRUE),
            mean(data_above[[var]], na.rm = TRUE),
            mean(data_confed[[var]], na.rm = TRUE))
  }
}

tab1 <- c(
  "\\begin{table}[htbp]",
  "\\centering",
  "\\caption{Summary Statistics: Civil War Veterans in the 1910 Census (1.4\\% Oversampled)}",
  "\\label{tab:summary}",
  "\\begin{tabular}{lcccc}",
  "\\hline\\hline",
  " & \\multicolumn{3}{c}{Union Veterans} & Confederate \\\\",
  "\\cmidrule(lr){2-4} \\cmidrule(lr){5-5}",
  " & All & Age $<$ 62 & Age $\\geq$ 62 & All \\\\",
  "\\hline",
  make_row(NULL, "N", union, union_below, union_above, confed, is_count = TRUE),
  sprintf("Mean Age & %.1f & %.1f & %.1f & %.1f \\\\",
          mean(union$AGE), mean(union_below$AGE), mean(union_above$AGE), mean(confed$AGE)),
  "\\hline",
  "\\multicolumn{5}{l}{\\textit{Panel A: Outcome Variables}} \\\\",
  make_row("in_labor_force", "Labor Force Participation", union, union_below, union_above, confed),
  make_row("has_occupation", "Has Occupation", union, union_below, union_above, confed),
  make_row("farm_occ", "Farm Occupation", union, union_below, union_above, confed),
  make_row("manual_labor", "Manual Labor", union, union_below, union_above, confed),
  make_row("owns_home", "Owns Home", union, union_below, union_above, confed),
  make_row("is_head", "Household Head", union, union_below, union_above, confed),
  "\\hline",
  "\\multicolumn{5}{l}{\\textit{Panel B: Pre-Determined Covariates}} \\\\",
  make_row("literate", "Literate", union, union_below, union_above, confed),
  make_row("native_born", "Native Born", union, union_below, union_above, confed),
  make_row("married", "Married", union, union_below, union_above, confed),
  make_row("urban", "Urban", union, union_below, union_above, confed),
  make_row("white", "White", union, union_below, union_above, confed),
  "\\hline\\hline",
  "\\multicolumn{5}{p{0.9\\textwidth}}{\\footnotesize \\textit{Notes:}",
  "Summary statistics for Union and Confederate Civil War veterans in the",
  "IPUMS 1910 1.4\\% oversampled census (us1910l). Veterans identified via the VETCIVWR variable.",
  "Panel A reports outcome variables; Panel B reports pre-determined covariates.",
  "LFP = labor force participation rate.} \\\\",
  "\\end{tabular}",
  "\\end{table}"
)
writeLines(tab1, file.path(tab_dir, "tab1_summary.tex"))

## ---- Table 2: Main RDD Results (AER Style) ----
cat("Table 2: Main RDD results (AER style)...\n")

rd <- main_results$lfp
rd_q <- main_results$lfp_quad

tab2 <- c(
  "\\begin{table}[htbp]",
  "\\centering",
  "\\caption{Effect of Pension Eligibility on Labor Force Participation: RDD at Age 62}",
  "\\label{tab:main_rdd}",
  "\\begin{tabular}{lcccc}",
  "\\hline\\hline",
  " & (1) & (2) & (3) & (4) \\\\",
  " & Linear & Quadratic & Bias-Corrected & Robust \\\\",
  "\\hline",
  sprintf("RD Estimate & %.4f%s & %.4f%s & %.4f%s & %.4f%s \\\\",
          rd$coef["Conventional", 1], stars(rd$pv["Conventional", 1]),
          rd_q$coef["Conventional", 1], stars(rd_q$pv["Conventional", 1]),
          rd$coef["Bias-Corrected", 1], stars(rd$pv["Robust", 1]),
          rd$coef["Robust", 1], stars(rd$pv["Robust", 1])),
  sprintf(" & (%.4f) & (%.4f) & (%.4f) & (%.4f) \\\\",
          rd$se["Conventional", 1], rd_q$se["Conventional", 1],
          rd$se["Robust", 1], rd$se["Robust", 1]),
  sprintf("95\\%% CI & [%.3f, %.3f] & [%.3f, %.3f] & [%.3f, %.3f] & [%.3f, %.3f] \\\\",
          rd$coef["Conventional", 1] - 1.96 * rd$se["Conventional", 1],
          rd$coef["Conventional", 1] + 1.96 * rd$se["Conventional", 1],
          rd_q$coef["Conventional", 1] - 1.96 * rd_q$se["Conventional", 1],
          rd_q$coef["Conventional", 1] + 1.96 * rd_q$se["Conventional", 1],
          rd$coef["Bias-Corrected", 1] - 1.96 * rd$se["Robust", 1],
          rd$coef["Bias-Corrected", 1] + 1.96 * rd$se["Robust", 1],
          rd$coef["Robust", 1] - 1.96 * rd$se["Robust", 1],
          rd$coef["Robust", 1] + 1.96 * rd$se["Robust", 1]),
  "\\hline",
  sprintf("Bandwidth (L/R) & %.1f / %.1f & %.1f / %.1f & %.1f / %.1f & %.1f / %.1f \\\\",
          rd$bws["h", "left"], rd$bws["h", "right"],
          rd_q$bws["h", "left"], rd_q$bws["h", "right"],
          rd$bws["h", "left"], rd$bws["h", "right"],
          rd$bws["h", "left"], rd$bws["h", "right"]),
  sprintf("$N_{\\text{left}}$ & %s & %s & %s & %s \\\\",
          format(rd$N_h[1], big.mark = ","), format(rd_q$N_h[1], big.mark = ","),
          format(rd$N_h[1], big.mark = ","), format(rd$N_h[1], big.mark = ",")),
  sprintf("$N_{\\text{right}}$ & %s & %s & %s & %s \\\\",
          format(rd$N_h[2], big.mark = ","), format(rd_q$N_h[2], big.mark = ","),
          format(rd$N_h[2], big.mark = ","), format(rd$N_h[2], big.mark = ",")),
  sprintf("Baseline LFP & \\multicolumn{4}{c}{%.3f} \\\\", main_results$baseline_lfp),
  sprintf("MDE (80\\%% power) & \\multicolumn{4}{c}{%.4f} \\\\", main_results$mde),
  "Kernel & Triangular & Triangular & Triangular & Triangular \\\\",
  "\\hline\\hline",
  "\\multicolumn{5}{p{0.95\\textwidth}}{\\footnotesize \\textit{Notes:}",
  "Sharp RDD estimates of crossing the age 62 pension eligibility threshold on labor",
  "force participation among Union Civil War veterans. Standard errors in parentheses.",
  sprintf("Full sample: $N = %s$ Union veterans. Baseline LFP is computed within the MSE-optimal", format(nrow(union), big.mark = ",")),
  "bandwidth and may differ from the full-sample means in Table \\ref{tab:summary}.",
  "$^{***}p<0.01$, $^{**}p<0.05$, $^{*}p<0.10$.} \\\\",
  "\\end{tabular}",
  "\\end{table}"
)
writeLines(tab2, file.path(tab_dir, "tab2_main_rdd.tex"))

## ---- Table 3: Difference-in-Discontinuities ----
cat("Table 3: Diff-in-disc...\n")

did_file <- file.path(data_dir, "did_results.rds")
if (file.exists(did_file)) {
  did <- readRDS(did_file)
  d <- did$separate

  tab3 <- c(
    "\\begin{table}[htbp]",
    "\\centering",
    "\\caption{Difference-in-Discontinuities: Union vs.\\ Confederate Veterans at Age 62}",
    "\\label{tab:diff_in_disc}",
    "\\begin{tabular}{lccc}",
    "\\hline\\hline",
    " & Union & Confederate & Difference \\\\",
    "\\hline",
    sprintf("RD Estimate & %.4f%s & %.4f%s & %.4f%s \\\\",
            d$tau_union, stars(2 * pnorm(-abs(d$tau_union / d$se_union))),
            d$tau_confed, stars(2 * pnorm(-abs(d$tau_confed / d$se_confed))),
            d$tau_did, stars(d$pvalue)),
    sprintf(" & (%.4f) & (%.4f) & (%.4f) \\\\",
            d$se_union, d$se_confed, d$se_did),
    sprintf("95\\%% CI & [%.3f, %.3f] & [%.3f, %.3f] & [%.3f, %.3f] \\\\",
            d$tau_union - 1.96 * d$se_union, d$tau_union + 1.96 * d$se_union,
            d$tau_confed - 1.96 * d$se_confed, d$tau_confed + 1.96 * d$se_confed,
            d$tau_did - 1.96 * d$se_did, d$tau_did + 1.96 * d$se_did),
    "\\hline",
    sprintf("$N_{\\text{left}}$ & %s & %s & \\\\",
            format(d$n_union_left, big.mark = ","), format(d$n_confed_left, big.mark = ",")),
    sprintf("$N_{\\text{right}}$ & %s & %s & \\\\",
            format(d$n_union_right, big.mark = ","), format(d$n_confed_right, big.mark = ",")),
    "\\hline\\hline",
    "\\multicolumn{4}{p{0.9\\textwidth}}{\\footnotesize \\textit{Notes:}",
    "Difference-in-discontinuities estimates at the age 62 threshold. The Union RDD estimates",
    "the combined effect of pension eligibility and aging. The Confederate RDD estimates the",
    "pure aging effect (no federal pension). The difference isolates the pension effect.",
    "Standard errors in parentheses; SE for the difference computed assuming independence.",
    "$^{***}p<0.01$, $^{**}p<0.05$, $^{*}p<0.10$.} \\\\",
    "\\end{tabular}",
    "\\end{table}"
  )
  writeLines(tab3, file.path(tab_dir, "tab3_diff_in_disc.tex"))
}

## ---- Table 4: Covariate Balance ----
cat("Table 4: Covariate balance...\n")

cov_labels <- c(literate = "Literate", native_born = "Native Born",
                married = "Married", urban = "Urban", white = "White")

tab4 <- c(
  "\\begin{table}[htbp]",
  "\\centering",
  "\\caption{Covariate Balance at the Age 62 Threshold}",
  "\\label{tab:balance}",
  "\\begin{tabular}{lccccc}",
  "\\hline\\hline",
  "Covariate & RD Est. & SE & $p$-value & Bandwidth & $N_L$ / $N_R$ \\\\",
  "\\hline"
)

for (i in seq_len(nrow(balance_results))) {
  r <- balance_results[i]
  label <- cov_labels[r$covariate]
  tab4 <- c(tab4, sprintf(
    "%s & %.4f%s & (%.4f) & %.3f & %.1f & %s / %s \\\\",
    label,
    r$rd_estimate, stars(r$pvalue),
    r$se, r$pvalue, r$bw_left,
    format(round(r$n_left), big.mark = ","),
    format(round(r$n_right), big.mark = ",")))
}

tab4 <- c(tab4,
  "\\hline\\hline",
  "\\multicolumn{6}{p{0.95\\textwidth}}{\\footnotesize \\textit{Notes:}",
  "RDD estimates at age 62 for pre-determined covariates using local linear regression.",
  "Each covariate uses its own MSE-optimal bandwidth (reported). Smooth covariates support",
  "RDD validity. Triangular kernel.",
  "$^{***}p<0.01$, $^{**}p<0.05$, $^{*}p<0.10$.} \\\\",
  "\\end{tabular}",
  "\\end{table}"
)
writeLines(tab4, file.path(tab_dir, "tab4_balance.tex"))

## ---- Table 5: Secondary Outcomes ----
cat("Table 5: Secondary outcomes...\n")

tab5 <- c(
  "\\begin{table}[htbp]",
  "\\centering",
  "\\caption{RDD Estimates for Secondary Outcomes at the Age 62 Threshold}",
  "\\label{tab:secondary}",
  "\\begin{tabular}{lccccc}",
  "\\hline\\hline",
  "Outcome & RD Est. & SE & 95\\% CI & Baseline & $N_L$ / $N_R$ \\\\",
  "\\hline"
)

for (i in seq_len(nrow(secondary_results))) {
  r <- secondary_results[i]
  tab5 <- c(tab5, sprintf(
    "%s & %.4f%s & (%.4f) & [%.3f, %.3f] & %.3f & %s / %s \\\\",
    r$outcome, r$coef, stars(r$pvalue),
    r$se, r$ci_lower, r$ci_upper,
    r$baseline_mean,
    format(round(r$n_left), big.mark = ","),
    format(round(r$n_right), big.mark = ",")))
}

tab5 <- c(tab5,
  "\\hline\\hline",
  "\\multicolumn{6}{p{0.95\\textwidth}}{\\footnotesize \\textit{Notes:}",
  "Sharp RDD estimates at the age 62 pension eligibility threshold. Baseline = mean below",
  "cutoff within bandwidth. Local linear, triangular kernel, MSE-optimal bandwidth.",
  "$^{***}p<0.01$, $^{**}p<0.05$, $^{*}p<0.10$.} \\\\",
  "\\end{tabular}",
  "\\end{table}"
)
writeLines(tab5, file.path(tab_dir, "tab5_secondary.tex"))

## ---- Table 6: Robustness ----
cat("Table 6: Robustness...\n")

tab6 <- c(
  "\\begin{table}[htbp]",
  "\\centering",
  "\\caption{Robustness of Main RDD Estimate (Labor Force Participation)}",
  "\\label{tab:robustness}",
  "\\begin{tabular}{lccccc}",
  "\\hline\\hline",
  "Specification & RD Est. & SE & 95\\% CI & Sample \\\\",
  "\\hline",
  "\\multicolumn{5}{l}{\\textit{Panel A: Bandwidth Sensitivity}} \\\\"
)

if (!is.null(robust_results$bandwidth)) {
  for (i in seq_len(nrow(robust_results$bandwidth))) {
    r <- robust_results$bandwidth[i]
    opt_label <- ifelse(abs(r$bandwidth - rd$bws["h", "left"]) < 0.1, " (optimal)", "")
    tab6 <- c(tab6, sprintf(
      "\\quad $h = %.1f$%s & %.4f%s & (%.4f) & [%.3f, %.3f] & %s / %s \\\\",
      r$bandwidth, opt_label,
      r$coef, stars(r$pvalue), r$se, r$ci_lower, r$ci_upper,
      format(round(r$n_left), big.mark = ","),
      format(round(r$n_right), big.mark = ",")))
  }
}

tab6 <- c(tab6,
  "\\hline",
  "\\multicolumn{5}{l}{\\textit{Panel B: Donut-Hole Specifications}} \\\\"
)

if (!is.null(robust_results$donut)) {
  for (i in seq_len(nrow(robust_results$donut))) {
    r <- robust_results$donut[i]
    tab6 <- c(tab6, sprintf(
      "\\quad Excl.\\ %s & %.4f%s & (%.4f) & [%.3f, %.3f] & %s / %s \\\\",
      r$excluded, r$coef, stars(r$pvalue), r$se,
      r$coef - 1.96 * r$se, r$coef + 1.96 * r$se,
      format(round(r$n_left), big.mark = ","),
      format(round(r$n_right), big.mark = ",")))
  }
}

# Literacy controlled
if (!is.null(robust_results$literacy_controlled)) {
  r <- robust_results$literacy_controlled
  tab6 <- c(tab6, sprintf(
    "\\quad Literacy-controlled & %.4f%s & (%.4f) & [%.3f, %.3f] & %s / %s \\\\",
    r$coef, stars(r$pvalue), r$se,
    r$coef - 1.96 * r$se, r$coef + 1.96 * r$se,
    format(round(r$n_left), big.mark = ","),
    format(round(r$n_right), big.mark = ",")))
}

tab6 <- c(tab6,
  "\\hline",
  "\\multicolumn{5}{l}{\\textit{Panel C: Placebo Populations}} \\\\"
)

# Confederate
if (!is.null(main_results$confed_lfp)) {
  rc <- main_results$confed_lfp
  tab6 <- c(tab6, sprintf(
    "\\quad Confederate veterans & %.4f%s & (%.4f) & [%.3f, %.3f] & %s / %s \\\\",
    rc$coef["Conventional", 1], stars(rc$pv["Conventional", 1]),
    rc$se["Conventional", 1],
    rc$coef["Conventional", 1] - 1.96 * rc$se["Conventional", 1],
    rc$coef["Conventional", 1] + 1.96 * rc$se["Conventional", 1],
    format(rc$N_h[1], big.mark = ","), format(rc$N_h[2], big.mark = ",")))
}

# Non-veteran
if (!is.null(robust_results$nonvet_placebo)) {
  r <- robust_results$nonvet_placebo
  tab6 <- c(tab6, sprintf(
    "\\quad Non-veterans & %.4f%s & (%.4f) & [%.3f, %.3f] & %s / %s \\\\",
    r$coef, stars(r$pvalue), r$se,
    r$coef - 1.96 * r$se, r$coef + 1.96 * r$se,
    format(round(r$n_left), big.mark = ","),
    format(round(r$n_right), big.mark = ",")))
}

tab6 <- c(tab6,
  "\\hline",
  "\\multicolumn{5}{l}{\\textit{Panel D: Multi-Cutoff (Dose-Response)}} \\\\"
)

if (!is.null(robust_results$multi_cutoff)) {
  for (i in seq_len(nrow(robust_results$multi_cutoff))) {
    r <- robust_results$multi_cutoff[i]
    pension_label <- gsub("\\$", "\\\\$", r$pension_change)
    n_total <- r$n_union_left + r$n_union_right + r$n_confed_left + r$n_confed_right
    tab6 <- c(tab6, sprintf(
      "\\quad Age %d (%s) & %.4f%s & (%.4f) & [%.3f, %.3f] & %s \\\\",
      r$cutoff, pension_label,
      r$coef_did, stars(r$pvalue_did), r$se_did,
      r$coef_did - 1.96 * r$se_did, r$coef_did + 1.96 * r$se_did,
      format(round(n_total), big.mark = ",")))
  }
}

tab6 <- c(tab6,
  "\\hline\\hline",
  "\\multicolumn{5}{p{0.95\\textwidth}}{\\footnotesize \\textit{Notes:}",
  "Robustness checks for the main RDD specification. Panel A varies bandwidth.",
  "With integer ages, adjacent bandwidths may yield identical effective $N$ if no observations",
  "fall at the marginal age. Panel B excludes age-heaping ages. Panel C applies the RDD to populations without",
  "pension eligibility. Panel D reports diff-in-disc estimates (Union $-$ Confederate RDD) at additional",
  "pension thresholds; $N$ is the combined Union + Confederate sample within each bandwidth.",
  "$^{***}p<0.01$, $^{**}p<0.05$, $^{*}p<0.10$.} \\\\",
  "\\end{tabular}",
  "\\end{table}"
)
writeLines(tab6, file.path(tab_dir, "tab6_robustness.tex"))

## ---- Table 8: Subgroup Results ----
cat("Table 8: Subgroup results...\n")

sg_file <- file.path(data_dir, "subgroup_results.rds")
if (file.exists(sg_file)) {
  sg <- readRDS(sg_file)

  tab8 <- c(
    "\\begin{table}[htbp]",
    "\\centering",
    "\\caption{Subgroup Heterogeneity: RDD at Age 62 by Demographic Group}",
    "\\label{tab:subgroups}",
    "\\begin{tabular}{llccccc}",
    "\\hline\\hline",
    "Category & Subgroup & RD Est. & SE & $N$ & $N_L$ / $N_R$ & Baseline \\\\",
    "\\hline"
  )

  prev_cat <- ""
  for (i in seq_len(nrow(sg))) {
    r <- sg[i]
    cat_label <- if (r$category != prev_cat) r$category else ""
    prev_cat <- r$category

    tab8 <- c(tab8, sprintf(
      "%s & %s & %.4f%s & (%.4f) & %s & %s / %s & %.3f \\\\",
      cat_label, r$subgroup,
      r$coef, stars(r$pvalue), r$se,
      format(r$n_total, big.mark = ","),
      format(round(r$n_eff_left), big.mark = ","),
      format(round(r$n_eff_right), big.mark = ","),
      r$baseline_lfp))
  }

  tab8 <- c(tab8,
    "\\hline\\hline",
    "\\multicolumn{7}{p{0.95\\textwidth}}{\\footnotesize \\textit{Notes:}",
    "RDD estimates at age 62 by demographic subgroup. Each row is a separate",
    "rdrobust estimation. Baseline = mean LFP below cutoff within bandwidth.",
    "$^{***}p<0.01$, $^{**}p<0.05$, $^{*}p<0.10$.} \\\\",
    "\\end{tabular}",
    "\\end{table}"
  )
  writeLines(tab8, file.path(tab_dir, "tab8_subgroups.tex"))
}

## ---- Table 9: Randomization Inference ----
cat("Table 9: Randomization inference...\n")

ri_file <- file.path(data_dir, "ri_results.rds")
if (file.exists(ri_file)) {
  ri <- readRDS(ri_file)

  tab9 <- c(
    "\\begin{table}[htbp]",
    "\\centering",
    "\\caption{Randomization Inference: Finite-Sample P-Values}",
    "\\label{tab:ri}",
    "\\begin{tabular}{lccc}",
    "\\hline\\hline",
    "Outcome & Observed Statistic & RI $p$-value & Conventional $p$-value \\\\",
    "\\hline",
    sprintf("LFP (diff-in-means) & %.4f & %.3f & %.3f \\\\",
            ri$main$tau_obs, ri$main$ri_pvalue_twosided, ri$main$conventional_pvalue)
  )

  if (!is.null(ri$robust)) {
    # Use conventional p-value from main rdrobust estimation
    conv_p <- main_results$lfp$pv["Conventional", 1]
    tab9 <- c(tab9, sprintf(
      "LFP (rdrobust T-stat) & %.3f & %.3f & %.3f \\\\",
      ri$robust$t_obs, ri$robust$ri_pvalue, conv_p))
  }

  # Secondary outcome RI omitted: diff-in-means test statistic confounds age
  # trends with treatment, producing p-values inconsistent with rdrobust estimates.

  tab9 <- c(tab9,
    "\\hline\\hline",
    sprintf("\\multicolumn{4}{p{0.85\\textwidth}}{\\footnotesize \\textit{Notes:}"),
    sprintf("Randomization inference following Cattaneo, Frandsen, and Titiunik (2015)."),
    sprintf("Diff-in-means: %s permutations; rdrobust $t$-statistic: 1,000 permutations. Two-sided tests.", format(ri$main$n_perms, big.mark = ",")),
    "Provides finite-sample valid inference for discrete running variables.} \\\\",
    "\\end{tabular}",
    "\\end{table}"
  )
  writeLines(tab9, file.path(tab_dir, "tab9_ri.tex"))
}


## ---- Table 10: Border State Results ----
cat("Table 10: Border state results...\n")

border_file <- file.path(data_dir, "border_results.rds")
if (file.exists(border_file)) {
  border <- readRDS(border_file)
  
  brd <- border$union_rdd
  cfe <- border$county_fe
  
  tab10 <- c(
    "\\begin{table}[htbp]",
    "\\centering",
    "\\caption{Border State Analysis: KY, MO, MD, WV, DE}",
    "\\label{tab:border}",
    "\\begin{tabular}{lcc}",
    "\\hline\\hline",
    " & (1) & (2) \\\\",
    " & Union-Only RDD & Diff-in-Disc (County FE) \\\\",
    "\\hline",
    sprintf("Estimate & %.4f%s & %.4f%s \\\\",
            brd$coef["Conventional", 1], stars(brd$pv["Conventional", 1]),
            cfe$coeftable["union_veteran:above", "Estimate"],
            stars(cfe$coeftable["union_veteran:above", "Pr(>|t|)"])),
    sprintf(" & (%.4f) & (%.4f) \\\\",
            brd$se["Conventional", 1],
            cfe$coeftable["union_veteran:above", "Std. Error"]),
    sprintf("95\\%% CI & [%.3f, %.3f] & [%.3f, %.3f] \\\\",
            brd$coef["Conventional", 1] - 1.96 * brd$se["Conventional", 1],
            brd$coef["Conventional", 1] + 1.96 * brd$se["Conventional", 1],
            cfe$coeftable["union_veteran:above", "Estimate"] - 1.96 * cfe$coeftable["union_veteran:above", "Std. Error"],
            cfe$coeftable["union_veteran:above", "Estimate"] + 1.96 * cfe$coeftable["union_veteran:above", "Std. Error"]),
    "\\hline",
    sprintf("$N_{\\text{left}}$ / $N_{\\text{right}}$ & %s / %s & \\multicolumn{1}{c}{%s} \\\\",
            format(brd$N_h[1], big.mark = ","), format(brd$N_h[2], big.mark = ","),
            format(nobs(cfe), big.mark = ",")),
    "County FE & No & Yes \\\\",
    "\\hline\\hline",
    "\\multicolumn{3}{p{0.85\\textwidth}}{\\footnotesize \\textit{Notes:}",
    "Border states: KY, MO, MD, WV, DE. Column 1: rdrobust RDD for Union veterans only.",
    "Column 2: pooled OLS of Union and Confederate veterans with county fixed effects;",
    "the reported coefficient is the Union $\\times$ Above-62 interaction (diff-in-disc).",
    "Wide confidence intervals reflect the small border-state sample and high-dimensional FE.",
    "$^{***}p<0.01$, $^{**}p<0.05$, $^{*}p<0.10$.} \\\\",
    "\\end{tabular}",
    "\\end{table}"
  )
  writeLines(tab10, file.path(tab_dir, "tab10_border.tex"))
}

## ---- Table 11: Household Spillover Results ----
cat("Table 11: Household spillover results...\n")

spill_file <- file.path(data_dir, "spillover_results.rds")
if (file.exists(spill_file)) {
  spill <- readRDS(spill_file)
  
  spill_outcomes <- list(
    list(key = "wife_lfp", label = "Wife LFP"),
    list(key = "wife_occ", label = "Wife has occupation"),
    list(key = "child_lfp", label = "Adult child LFP"),
    list(key = "hh_n_earners", label = "HH earners"),
    list(key = "hh_hh_size", label = "HH size"),
    list(key = "hh_any_female_work", label = "Any female employment")
  )
  
  tab11 <- c(
    "\\begin{table}[htbp]",
    "\\centering",
    "\\caption{Household Spillover Effects: RDD at Veteran's Age 62 Threshold}",
    "\\label{tab:spillovers}",
    "\\begin{tabular}{lccccc}",
    "\\hline\\hline",
    "Outcome & RD Est. & SE & 95\\% CI & $N_L$ / $N_R$ \\\\",
    "\\hline",
    "\\multicolumn{5}{l}{\\textit{Panel A: Individual Household Members}} \\\\"
  )
  
  for (i in 1:3) {
    s <- spill_outcomes[[i]]
    rd <- spill[[s$key]]
    tab11 <- c(tab11, sprintf(
      "\\quad %s & %.4f%s & (%.4f) & [%.3f, %.3f] & %s / %s \\\\",
      s$label,
      rd$coef["Conventional", 1], stars(rd$pv["Conventional", 1]),
      rd$se["Conventional", 1],
      rd$coef["Conventional", 1] - 1.96 * rd$se["Conventional", 1],
      rd$coef["Conventional", 1] + 1.96 * rd$se["Conventional", 1],
      format(rd$N_h[1], big.mark = ","), format(rd$N_h[2], big.mark = ",")))
  }
  
  tab11 <- c(tab11,
    "\\hline",
    "\\multicolumn{5}{l}{\\textit{Panel B: Household-Level Outcomes}} \\\\"
  )
  
  for (i in 4:6) {
    s <- spill_outcomes[[i]]
    rd <- spill[[s$key]]
    tab11 <- c(tab11, sprintf(
      "\\quad %s & %.4f%s & (%.4f) & [%.3f, %.3f] & %s / %s \\\\",
      s$label,
      rd$coef["Conventional", 1], stars(rd$pv["Conventional", 1]),
      rd$se["Conventional", 1],
      rd$coef["Conventional", 1] - 1.96 * rd$se["Conventional", 1],
      rd$coef["Conventional", 1] + 1.96 * rd$se["Conventional", 1],
      format(rd$N_h[1], big.mark = ","), format(rd$N_h[2], big.mark = ",")))
  }
  
  tab11 <- c(tab11,
    "\\hline\\hline",
    "\\multicolumn{5}{p{0.95\\textwidth}}{\\footnotesize \\textit{Notes:}",
    "RDD estimates at the veteran's age-62 threshold for household members' outcomes.",
    "Panel A: outcomes for co-resident spouses and adult children (ages 18--50).",
    "Panel B: household-level aggregates. Running variable is the veteran's age.",
    "$^{***}p<0.01$, $^{**}p<0.05$, $^{*}p<0.10$.} \\\\",
    "\\end{tabular}",
    "\\end{table}"
  )
  writeLines(tab11, file.path(tab_dir, "tab11_spillovers.tex"))
}

## ---- Table 12: Pooled Diff-in-Disc Regression ----
cat("Table 12: Pooled diff-in-disc regression...\n")

if (file.exists(did_file)) {
  did <- readRDS(did_file)
  
  if (!is.null(did$pooled_reg)) {
    pr <- did$pooled_reg
    ct <- pr$coeftable
    
    tab12 <- c(
      "\\begin{table}[htbp]",
      "\\centering",
      "\\caption{Pooled Parametric Difference-in-Discontinuities Regression}",
      "\\label{tab:pooled_did}",
      "\\begin{tabular}{lcc}",
      "\\hline\\hline",
      " & Coefficient & SE \\\\",
      "\\hline",
      sprintf("Union ($\\beta_1$) & %.4f%s & (%.4f) \\\\",
              ct["is_union", "Estimate"], stars(ct["is_union", "Pr(>|t|)"]),
              ct["is_union", "Std. Error"]),
      sprintf("Above 62 ($\\beta_2$) & %.4f%s & (%.4f) \\\\",
              ct["above", "Estimate"], stars(ct["above", "Pr(>|t|)"]),
              ct["above", "Std. Error"]),
      sprintf("Union $\\times$ Above 62 ($\\beta_3$) & %.4f%s & (%.4f) \\\\",
              ct["is_union:above", "Estimate"], stars(ct["is_union:above", "Pr(>|t|)"]),
              ct["is_union:above", "Std. Error"]),
      sprintf("Age $-$ 62 & %.4f%s & (%.4f) \\\\",
              ct["age_c", "Estimate"], stars(ct["age_c", "Pr(>|t|)"]),
              ct["age_c", "Std. Error"]),
      "\\hline",
      sprintf("$N$ & \\multicolumn{2}{c}{%s} \\\\", format(nobs(pr), big.mark = ",")),
      sprintf("$R^2$ & \\multicolumn{2}{c}{%.3f} \\\\", pr$sq.cor),
      "\\hline\\hline",
      "\\multicolumn{3}{p{0.85\\textwidth}}{\\footnotesize \\textit{Notes:}",
      "OLS regression of LFP on Union status, above-62 indicator, their interaction,",
      "and centered age (common slope). The coefficient $\\beta_3$ on Union $\\times$ Above 62",
      "is the parametric diff-in-disc estimator. Sample restricted to the Union MSE-optimal",
      "bandwidth applied to both groups; $N$ may differ from the sum of the separate RDD samples",
      "in Table \\ref{tab:diff_in_disc}, which use group-specific optimal bandwidths.",
      "$^{***}p<0.01$, $^{**}p<0.05$, $^{*}p<0.10$.} \\\\",
      "\\end{tabular}",
      "\\end{table}"
    )
    writeLines(tab12, file.path(tab_dir, "tab12_pooled_did.tex"))
  }
}

cat("\nAll tables saved to", tab_dir, "\n")
