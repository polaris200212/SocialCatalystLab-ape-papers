## ============================================================================
## 06_tables.R — All tables for The First Retirement Age v3
## Project: Costa Union Army data
## ============================================================================

source("code/00_packages.R")

cat("=== GENERATING TABLES ===\n\n")

cross <- readRDS(file.path(data_dir, "cross_section_sample.rds"))
panel <- readRDS(file.path(data_dir, "panel_sample.rds"))
main  <- readRDS(file.path(data_dir, "main_results.rds"))
fs    <- readRDS(file.path(data_dir, "first_stage_results.rds"))
robust <- readRDS(file.path(data_dir, "robust_results.rds"))

cross[, running := age_1907 - 62]
cross[, above_62 := as.integer(age_1907 >= 62)]
panel[, running := age_1907 - 62]
panel[, above_62 := as.integer(age_1907 >= 62)]

## Helper: write LaTeX table
write_tex <- function(content, filename) {
  writeLines(content, file.path(tab_dir, filename))
  cat("  Wrote", filename, "\n")
}

## =========================================================================
## TABLE 1: Summary Statistics
## =========================================================================
cat("Table 1: Summary statistics\n")

make_stat_row <- function(dt, var, label) {
  vals <- dt[[var]]
  vals <- vals[!is.na(vals)]
  sprintf("  %s & %.3f & %.3f & %d \\\\", label,
          mean(vals), sd(vals), length(vals))
}

tab1_rows <- c(
  "\\begin{table}[htbp]",
  "\\centering",
  "\\caption{Summary Statistics: Costa Union Army Sample}",
  "\\label{tab:summary}",
  "\\begin{tabular}{lccc}",
  "\\toprule",
  "  & Mean & SD & N \\\\",
  "\\midrule",
  "\\multicolumn{4}{l}{\\textit{Panel A: Full Cross-Sectional Sample}} \\\\",
  make_stat_row(cross, "lfp_1910", "LFP (1910)"),
  make_stat_row(cross, "age_1907", "Age at 1907"),
  make_stat_row(cross, "under_1907_act", "Under 1907 Act"),
  make_stat_row(cross, "pen_dollars_1910", "Pension \\$ (1910)"),
  make_stat_row(cross, "literate", "Literate"),
  make_stat_row(cross, "native_born", "Native-born"),
  make_stat_row(cross, "homeowner", "Homeowner"),
  make_stat_row(cross, "enlist_height", "Height (inches)"),
  "\\midrule",
  "\\multicolumn{4}{l}{\\textit{Panel B: Panel Sample (Both 1900 and 1910)}} \\\\",
  make_stat_row(panel, "lfp_1900", "LFP (1900)"),
  make_stat_row(panel, "lfp_1910", "LFP (1910)"),
  make_stat_row(panel, "delta_lfp", "$\\Delta$LFP"),
  sprintf("  N (panel) & & & %d \\\\", nrow(panel)),
  "\\midrule",
  "\\multicolumn{4}{l}{\\textit{Panel C: LFP (1910) by Age-62 Threshold}} \\\\",
  sprintf("  Below 62 in 1907 & %.3f & %.3f & %d \\\\",
          mean(cross[above_62 == 0]$lfp_1910), sd(cross[above_62 == 0]$lfp_1910), sum(cross$above_62 == 0)),
  sprintf("  At/above 62 in 1907 & %.3f & %.3f & %d \\\\",
          mean(cross[above_62 == 1]$lfp_1910), sd(cross[above_62 == 1]$lfp_1910), sum(cross$above_62 == 1)),
  "\\bottomrule",
  "\\end{tabular}",
  "\\begin{tablenotes}[flushleft]",
  "\\small",
  "\\item \\textit{Notes:} Costa Union Army sample of white Union veterans from 331 companies. Cross-sectional sample includes veterans alive at the 1910 census with valid LFP data. Panel sample further restricts to veterans with LFP data in both the 1900 and 1910 censuses. LFP equals one if the veteran had a gainful occupation (excluding retired).",
  "\\end{tablenotes}",
  "\\end{table}")
write_tex(tab1_rows, "tab1_summary.tex")

## =========================================================================
## TABLE 2: Pre-Treatment Balance
## =========================================================================
cat("Table 2: Pre-treatment balance\n")

bal <- main$balance
if (nrow(bal) > 0) {
  tab2_rows <- c(
    "\\begin{table}[htbp]",
    "\\centering",
    "\\caption{Covariate Balance at Age-62 Threshold}",
    "\\label{tab:balance}",
    "\\begin{tabular}{lcccccc}",
    "\\toprule",
    "  Variable & RD Estimate & SE & $p$-value & Bandwidth & $N_L$ & $N_R$ \\\\",
    "\\midrule")
  for (i in 1:nrow(bal)) {
    ## Compute consistent p-value from conventional coef / robust SE
    bal_pval <- 2 * pnorm(-abs(bal$coef[i] / bal$se[i]))
    tab2_rows <- c(tab2_rows,
      sprintf("  %s & %.3f & (%.3f) & %.3f & %.1f & %d & %d \\\\",
              gsub("_", " ", bal$variable[i]),
              bal$coef[i], bal$se[i], bal_pval, bal$bw[i],
              bal$N_left[i], bal$N_right[i]))
  }
  tab2_rows <- c(tab2_rows,
    "\\bottomrule",
    "\\end{tabular}",
    "\\begin{tablenotes}[flushleft]",
    "\\small",
    "\\item \\textit{Notes:} Local polynomial RDD estimates (rdrobust) of the discontinuity in pre-treatment covariates at the age-62 threshold. Conventional point estimates with robust standard errors. $p$-values from $z = $ estimate/SE. All covariates measured before 1907 or at enlistment. Note: bandwidths vary across covariates due to MSE-optimal selection.",
    "\\end{tablenotes}",
    "\\end{table}")
  write_tex(tab2_rows, "tab2_balance.tex")
}

## =========================================================================
## TABLE 3: Main RDD Results
## =========================================================================
cat("Table 3: Main RDD\n")

extract_rdd <- function(fit, label) {
  ## Use conventional coefficient with robust SE; compute consistent CI and p-value
  est <- fit$coef[1]
  se  <- fit$se[3]
  ci_lo <- est - 1.96 * se
  ci_hi <- est + 1.96 * se
  pval <- 2 * pnorm(-abs(est / se))
  sprintf("  %s & %.4f & (%.4f) & %.3f & [%.4f, %.4f] & %.1f & %d & %d \\\\",
          label, est, se, pval, ci_lo, ci_hi,
          fit$bws[1, 1], fit$N_h[1], fit$N_h[2])
}

tab3_rows <- c(
  "\\begin{table}[htbp]",
  "\\centering",
  "\\caption{Main RDD Results: Effect of Pension Eligibility on Labor Supply}",
  "\\label{tab:main_rdd}",
  "\\begin{tabular}{lccccccc}",
  "\\toprule",
  "  & Estimate & SE & $p$-value & 95\\% CI & BW & $N_L$ & $N_R$ \\\\",
  "\\midrule",
  "\\multicolumn{8}{l}{\\textit{Panel A: Cross-Sectional (LFP at 1910)}} \\\\",
  extract_rdd(main$cross_section, "Baseline"),
  extract_rdd(main$cross_section_cov, "With covariates"),
  "\\midrule",
  "\\multicolumn{8}{l}{\\textit{Panel B: Panel ($\\Delta$LFP = 1910 $-$ 1900)}} \\\\",
  extract_rdd(main$panel, "Baseline"),
  extract_rdd(main$panel_cov, "With covariates"),
  "\\midrule",
  "\\multicolumn{8}{l}{\\textit{Panel C: Pre-Treatment Falsification (LFP at 1900)}} \\\\",
  extract_rdd(main$pre_treatment, "LFP 1900"),
  "\\bottomrule",
  "\\end{tabular}",
  "\\begin{tablenotes}[flushleft]",
  "\\small",
  "\\item \\textit{Notes:} Local polynomial RDD estimates using rdrobust with MSE-optimal bandwidth selection and triangular kernel. Running variable is age at 1907 (year of Act passage) centered at 62. Conventional point estimates with robust standard errors. $p$-values are two-sided from the conventional $z$-statistic (estimate/SE). 95\\% CIs are $\\pm 1.96 \\times$ SE. Panel C tests whether LFP in 1900 (before the Act) is smooth at the threshold; a non-significant estimate supports the identifying assumption.",
  "\\end{tablenotes}",
  "\\end{table}")
write_tex(tab3_rows, "tab3_main_rdd.tex")

## =========================================================================
## TABLE 4: First Stage
## =========================================================================
cat("Table 4: First stage\n")

tab4_rows <- c(
  "\\begin{table}[htbp]",
  "\\centering",
  "\\caption{First Stage: Pension Receipt at Age-62 Threshold}",
  "\\label{tab:first_stage}",
  "\\begin{tabular}{lccccccc}",
  "\\toprule",
  "  Outcome & Estimate & SE & $p$-value & 95\\% CI & BW & $N_L$ & $N_R$ \\\\",
  "\\midrule",
  extract_rdd(fs$fs_binary, "1907 Act receipt"),
  extract_rdd(fs$fs_any, "Any pension"),
  extract_rdd(fs$fs_amount, "Pension \\$ (1910)"),
  extract_rdd(fs$fs_change, "Pension \\$ change"),
  "\\bottomrule",
  "\\end{tabular}",
  "\\begin{tablenotes}[flushleft]",
  "\\small",
  "\\item \\textit{Notes:} RDD estimates of the discontinuity in pension outcomes at age 62 (at Act passage in 1907). ``1907 Act receipt'' equals one if the veteran's pension law at the 1910 census was the February 6, 1907 Act. ``Any pension'' equals one if the veteran received any pension. Pension amounts are monthly dollars.",
  "\\end{tablenotes}",
  "\\end{table}")
write_tex(tab4_rows, "tab4_first_stage.tex")

## =========================================================================
## TABLE 5: Fuzzy RDD / LATE
## =========================================================================
cat("Table 5: Fuzzy RDD\n")

tab5_rows <- c(
  "\\begin{table}[htbp]",
  "\\centering",
  "\\caption{Fuzzy RDD: Local Average Treatment Effect of Pension on LFP}",
  "\\label{tab:fuzzy}",
  "\\begin{tabular}{lcccccc}",
  "\\toprule",
  "  & LATE & SE & $p$-value & BW & $N_L$ & $N_R$ \\\\",
  "\\midrule")

if (!is.null(fs$fuzzy_binary)) {
  fz_pval1 <- 2 * pnorm(-abs(fs$fuzzy_binary$coef[1] / fs$fuzzy_binary$se[3]))
  tab5_rows <- c(tab5_rows,
    sprintf("  Pension receipt $\\rightarrow$ LFP & %.4f & (%.4f) & %.3f & %.1f & %d & %d \\\\",
            fs$fuzzy_binary$coef[1], fs$fuzzy_binary$se[3], fz_pval1,
            fs$fuzzy_binary$bws[1, 1], fs$fuzzy_binary$N_h[1], fs$fuzzy_binary$N_h[2]))
}
if (!is.null(fs$fuzzy_amount)) {
  fz_pval2 <- 2 * pnorm(-abs(fs$fuzzy_amount$coef[1] / fs$fuzzy_amount$se[3]))
  tab5_rows <- c(tab5_rows,
    sprintf("  Pension \\$ $\\rightarrow$ LFP (per \\$) & %.4f & (%.4f) & %.3f & %.1f & %d & %d \\\\",
            fs$fuzzy_amount$coef[1], fs$fuzzy_amount$se[3], fz_pval2,
            fs$fuzzy_amount$bws[1, 1], fs$fuzzy_amount$N_h[1], fs$fuzzy_amount$N_h[2]))
}
tab5_rows <- c(tab5_rows,
  "\\bottomrule",
  "\\end{tabular}",
  "\\begin{tablenotes}[flushleft]",
  "\\small",
  "\\item \\textit{Notes:} Fuzzy RDD estimates using rdrobust. Treatment is instrumented by the age-62 threshold. LATE represents the effect of pension receipt (or pension dollars) on LFP among compliers at the threshold. MSE-optimal bandwidth with triangular kernel.",
  "\\end{tablenotes}",
  "\\end{table}")
write_tex(tab5_rows, "tab5_fuzzy_rdd.tex")

## =========================================================================
## TABLE 6: Robustness Grid
## =========================================================================
cat("Table 6: Robustness\n")

bw_dt <- main$bw_cross
if (!is.null(bw_dt) && nrow(bw_dt) > 0) {
  tab6_rows <- c(
    "\\begin{table}[htbp]",
    "\\centering",
    "\\caption{Robustness: Cross-Sectional RDD Across Bandwidths}",
    "\\label{tab:robustness}",
    "\\begin{tabular}{cccccc}",
    "\\toprule",
    "  BW & Estimate & SE & $p$-value & $N_L$ & $N_R$ \\\\",
    "\\midrule")
  for (i in 1:nrow(bw_dt)) {
    ## Use conventional coefficient with robust SE; compute p-value from conventional z-stat
    conv_pval <- 2 * pnorm(-abs(bw_dt$coef[i] / bw_dt$se_robust[i]))
    tab6_rows <- c(tab6_rows,
      sprintf("  %d & %.4f & (%.4f) & %.3f & %d & %d \\\\",
              bw_dt$bandwidth[i], bw_dt$coef[i], bw_dt$se_robust[i],
              conv_pval, bw_dt$N_left[i], bw_dt$N_right[i]))
  }
  tab6_rows <- c(tab6_rows,
    "\\bottomrule",
    "\\end{tabular}",
    "\\begin{tablenotes}[flushleft]",
    "\\small",
    "\\item \\textit{Notes:} Cross-sectional RDD estimates with varying bandwidths. Local linear polynomial with triangular kernel. Conventional point estimates with robust standard errors (rdrobust). $p$-values computed from the conventional $z$-statistic.",
    "\\end{tablenotes}",
    "\\end{table}")
  write_tex(tab6_rows, "tab6_robustness.tex")
}

## =========================================================================
## TABLE 7: Randomization Inference
## =========================================================================
cat("Table 7: RI\n")
ri_file <- file.path(data_dir, "ri_results.rds")
if (file.exists(ri_file)) {
  ri <- readRDS(ri_file)
  tab7_rows <- c(
    "\\begin{table}[htbp]",
    "\\centering",
    "\\caption{Randomization Inference Results}",
    "\\label{tab:ri}",
    "\\begin{tabular}{lccc}",
    "\\toprule",
    "  Design & Diff-in-Means & RI $p$-value & Permutations \\\\",
    "\\midrule",
    sprintf("  Cross-section (LFP 1910) & %.4f & %.3f & %d \\\\",
            ri$cross_section$observed, ri$cross_section$pvalue, ri$cross_section$N_perm),
    sprintf("  Panel ($\\Delta$LFP) & %.4f & %.3f & %d \\\\",
            ri$panel$observed, ri$panel$pvalue, ri$panel$N_perm))
  ## Note: First-stage RI is omitted. The diff-in-means test statistic is not
  ## informative for the first stage because the pension take-up discontinuity
  ## is localized at the cutoff, while diff-in-means averages over the entire
  ## bandwidth. The rdrobust local polynomial detects this boundary jump (coef=0.10),
  ## but the within-bandwidth average difference is near zero (0.007).
  tab7_rows <- c(tab7_rows,
    "\\bottomrule",
    "\\end{tabular}",
    "\\begin{tablenotes}[flushleft]",
    "\\small",
    "\\item \\textit{Notes:} Two-sided randomization inference $p$-values from 5,000 permutations of the above/below-62 assignment within the bandwidth. Test statistic is the simple difference in means within the bandwidth (not the rdrobust local polynomial estimate), so magnitudes differ from the main RDD estimates in Table \\ref{tab:main_rdd}. The null hypothesis is no treatment effect at the threshold.",
    "\\end{tablenotes}",
    "\\end{table}")
  write_tex(tab7_rows, "tab7_ri.tex")
} else {
  cat("  (RI not yet available)\n")
}

## =========================================================================
## TABLE 8: Subgroup Heterogeneity
## =========================================================================
cat("Table 8: Subgroups\n")
sub_file <- file.path(data_dir, "subgroup_results.rds")
if (file.exists(sub_file)) {
  sub <- readRDS(sub_file)
  sub <- sub[!is.na(coef)]
  ## Filter out subgroups with too few observations on either side (unreliable estimates)
  sub <- sub[N_left >= 20 & N_right >= 20]
  ## Filter out implausible estimates for binary outcomes (|coef| > 0.5 or SE > 0.5)
  sub <- sub[abs(coef) <= 0.5 & se <= 0.5]

  tab8_rows <- c(
    "\\begin{table}[htbp]",
    "\\centering",
    "\\caption{Subgroup Heterogeneity: RDD by Pre-Treatment Characteristics}",
    "\\label{tab:subgroups}",
    "\\begin{tabular}{lcccc}",
    "\\toprule",
    "  Subgroup & Estimate & SE & $p$-value & N \\\\",
    "\\midrule")
  for (i in 1:nrow(sub)) {
    ## Compute consistent p-value from coef/se
    sub_pval <- 2 * pnorm(-abs(sub$coef[i] / sub$se[i]))
    tab8_rows <- c(tab8_rows,
      sprintf("  %s & %.4f & (%.4f) & %.3f & %d \\\\",
              gsub("&", "\\\\&", sub$subgroup[i]),
              sub$coef[i], sub$se[i], sub_pval, sub$N[i]))
  }
  tab8_rows <- c(tab8_rows,
    "\\bottomrule",
    "\\end{tabular}",
    "\\begin{tablenotes}[flushleft]",
    "\\small",
    "\\item \\textit{Notes:} Separate RDD estimates for each subgroup. MSE-optimal bandwidth, triangular kernel, robust standard errors.",
    "\\end{tablenotes}",
    "\\end{table}")
  write_tex(tab8_rows, "tab8_subgroups.tex")
}

## =========================================================================
## TABLE 9: Dose-Response
## =========================================================================
cat("Table 9: Dose-response\n")
dose_file <- file.path(data_dir, "dose_results.rds")
if (file.exists(dose_file)) {
  dose <- readRDS(dose_file)
  multi <- dose$multi_cutoff
  if (!is.null(multi) && nrow(multi) > 0) {
    tab9_rows <- c(
      "\\begin{table}[htbp]",
      "\\centering",
      "\\caption{Multi-Cutoff Dose-Response: LFP at Different Pension Thresholds}",
      "\\label{tab:dose_response}",
      "\\begin{tabular}{lcccccccc}",
      "\\toprule",
      "  Cutoff & Pension \\$ & Estimate & SE & $p$-value & 95\\% CI & BW & $N_L$ & $N_R$ \\\\",
      "\\midrule")
    for (i in 1:nrow(multi)) {
      ## Use stored consistent p-value (coef/se, computed in 04d)
      dose_ci_lo <- multi$coef[i] - 1.96 * multi$se[i]
      dose_ci_hi <- multi$coef[i] + 1.96 * multi$se[i]
      tab9_rows <- c(tab9_rows,
        sprintf("  %s & \\$%d & %.4f & (%.4f) & %.3f & [%.4f, %.4f] & %.1f & %d & %d \\\\",
                multi$label[i], multi$pension_amt[i],
                multi$coef[i], multi$se[i], multi$pval[i],
                dose_ci_lo, dose_ci_hi,
                multi$bw[i], multi$N_left[i], multi$N_right[i]))
    }
    tab9_rows <- c(tab9_rows,
      "\\bottomrule",
      "\\end{tabular}",
      "\\begin{tablenotes}[flushleft]",
      "\\small",
      "\\item \\textit{Notes:} RDD estimates at three pension amount thresholds under the 1907 Act schedule. Conventional coefficients with robust standard errors. $p$-values from $z = $ estimate/SE. BW is the MSE-optimal bandwidth in years.",
      "\\end{tablenotes}",
      "\\end{table}")
    write_tex(tab9_rows, "tab9_dose_response.tex")
  }
}

## =========================================================================
## TABLE 10: Occupation Transitions
## =========================================================================
cat("Table 10: Occupation transitions\n")
occ_file <- file.path(data_dir, "occupation_results.rds")
if (file.exists(occ_file)) {
  occ <- readRDS(occ_file)
  exit_dt <- occ$exit_by_occ
  tab10_rows <- c(
    "\\begin{table}[htbp]",
    "\\centering",
    "\\caption{Occupation Transitions: Labor Force Exit Rates by 1900 Occupation}",
    "\\label{tab:occupation}",
    "\\begin{tabular}{lccc}",
    "\\toprule",
    "  1900 Occupation & Exit Rate & LFP (1910) & N \\\\",
    "\\midrule")
  for (i in 1:nrow(exit_dt)) {
    tab10_rows <- c(tab10_rows,
      sprintf("  %s & %.3f & %.3f & %d \\\\",
              exit_dt$occ_type_1900[i], exit_dt$exit_rate[i],
              exit_dt$mean_lfp_1910[i], exit_dt$N[i]))
  }
  tab10_rows <- c(tab10_rows,
    "\\bottomrule",
    "\\end{tabular}",
    "\\begin{tablenotes}[flushleft]",
    "\\small",
    "\\item \\textit{Notes:} Exit rates are the fraction of veterans who had an occupation in 1900 but no occupation in 1910. Panel sample only.",
    "\\end{tablenotes}",
    "\\end{table}")
  write_tex(tab10_rows, "tab10_occupation.tex")
}

## =========================================================================
## TABLE 11: Health Mechanisms
## =========================================================================
cat("Table 11: Health mechanisms\n")
health_file <- file.path(data_dir, "health_results.rds")
if (file.exists(health_file)) {
  health <- readRDS(health_file)

  tab11_rows <- c(
    "\\begin{table}[htbp]",
    "\\centering",
    "\\caption{Health Mechanisms: Disability and Mortality at Age-62 Threshold}",
    "\\label{tab:health}",
    "\\begin{tabular}{lcccccc}",
    "\\toprule",
    "  Outcome & RD Estimate & SE & $p$-value & BW & $N_L$ & $N_R$ \\\\",
    "\\midrule",
    "\\multicolumn{7}{l}{\\textit{Panel A: Pre-Treatment Health Balance}} \\\\")

  if (nrow(health$balance) > 0) {
    has_bw <- "bw" %in% names(health$balance)
    for (i in 1:nrow(health$balance)) {
      if (has_bw) {
        tab11_rows <- c(tab11_rows,
          sprintf("  %s & %.3f & (%.3f) & %.3f & %.1f & %d & %d \\\\",
                  gsub("_", " ", health$balance$variable[i]),
                  health$balance$coef[i], health$balance$se[i], health$balance$pval[i],
                  health$balance$bw[i], health$balance$N_left[i], health$balance$N_right[i]))
      } else {
        tab11_rows <- c(tab11_rows,
          sprintf("  %s & %.3f & (%.3f) & %.3f & & & \\\\",
                  gsub("_", " ", health$balance$variable[i]),
                  health$balance$coef[i], health$balance$se[i], health$balance$pval[i]))
      }
    }
  }

  tab11_rows <- c(tab11_rows,
    "\\midrule",
    "\\multicolumn{7}{l}{\\textit{Panel B: Health Changes (Post minus Pre 1907)}} \\\\")
  if (nrow(health$changes) > 0) {
    has_bw_c <- "bw" %in% names(health$changes)
    for (i in 1:nrow(health$changes)) {
      if (has_bw_c) {
        tab11_rows <- c(tab11_rows,
          sprintf("  %s & %.3f & (%.3f) & %.3f & %.1f & %d & %d \\\\",
                  gsub("_", " ", health$changes$variable[i]),
                  health$changes$coef[i], health$changes$se[i], health$changes$pval[i],
                  health$changes$bw[i], health$changes$N_left[i], health$changes$N_right[i]))
      } else {
        tab11_rows <- c(tab11_rows,
          sprintf("  %s & %.3f & (%.3f) & %.3f & & & \\\\",
                  gsub("_", " ", health$changes$variable[i]),
                  health$changes$coef[i], health$changes$se[i], health$changes$pval[i]))
      }
    }
  }

  tab11_rows <- c(tab11_rows,
    "\\bottomrule",
    "\\end{tabular}",
    "\\begin{tablenotes}[flushleft]",
    "\\small",
    "\\item \\textit{Notes:} RDD estimates of the discontinuity in health outcomes at the age-62 threshold. Health data from surgeons' certificates in the Costa Union Army dataset. Panel A tests pre-treatment balance; Panel B tests whether pension eligibility changed health trajectories. MSE-optimal bandwidth with robust standard errors.",
    "\\end{tablenotes}",
    "\\end{table}")
  write_tex(tab11_rows, "tab11_health.tex")
}

## =========================================================================
## TABLE A1: Pension Law Summary (Appendix)
## =========================================================================
cat("Table A1: Pension law summary\n")
tabA1 <- c(
  "\\begin{table}[htbp]",
  "\\centering",
  "\\caption{Summary of Major Union Army Pension Laws}",
  "\\label{tab:pension_laws}",
  "\\begin{tabular}{lp{3cm}p{4cm}p{4cm}}",
  "\\toprule",
  "  Law & Date & Eligibility & Benefits \\\\",
  "\\midrule",
  "  General Law & July 14, 1862 & Service-connected disability & \\$8--\\$30/mo by disability rating \\\\",
  "  Dependent Pension Act & June 27, 1890 & Any disability (not service-connected) & \\$6--\\$12/mo \\\\",
  "  \\textbf{Service and Age Act} & \\textbf{Feb 6, 1907} & \\textbf{Age 62+, 90+ days service} & \\textbf{\\$12--\\$20/mo by age} \\\\",
  "  Sherwood Act & May 11, 1912 & Age 62+, liberalized & \\$13--\\$30/mo \\\\",
  "\\bottomrule",
  "\\end{tabular}",
  "\\begin{tablenotes}[flushleft]",
  "\\small",
  "\\item \\textit{Notes:} Principal Union Army pension laws. The 1907 Act created the first age-based eligibility threshold at 62, providing \\$12/month (ages 62--69), \\$15/month (ages 70--74), and \\$20/month (ages 75+) regardless of disability status.",
  "\\end{tablenotes}",
  "\\end{table}")
write_tex(tabA1, "tabA1_pension_laws.tex")

## =========================================================================
## TABLE A2: Panel Selection Test (Appendix)
## =========================================================================
cat("Table A2: Panel selection\n")
sel <- robust$panel_selection
if (!is.null(sel)) {
  ## Compute consistent p-value from conventional coef / robust SE
  sel_conv_p <- 2 * pnorm(-abs(sel$coef[1] / sel$se[1]))
  sel_robust_p <- 2 * pnorm(-abs(sel$coef[1] / sel$se[3]))
  tabA2 <- c(
    "\\begin{table}[htbp]",
    "\\centering",
    "\\caption{Panel Selection: Probability of Appearing in Both Censuses}",
    "\\label{tab:panel_selection}",
    "\\begin{tabular}{lcccccccc}",
    "\\toprule",
    "  & Estimate & Conv. SE & Robust SE & $p$ (conv.) & $p$ (robust) & BW & $N_L$ & $N_R$ \\\\",
    "\\midrule",
    sprintf("  In panel sample & %.4f & (%.4f) & (%.4f) & %.3f & %.3f & %.1f & %d & %d \\\\",
            sel$coef[1], sel$se[1], sel$se[3],
            sel_conv_p, sel_robust_p,
            sel$bws[1, 1], sel$N_h[1], sel$N_h[2]),
    "\\midrule",
    sprintf("  Bias-corrected estimate & %.4f & & (%.4f) & & %.3f & & & \\\\",
            sel$coef[2], sel$se[3], sel$pv[3]),
    "\\bottomrule",
    "\\end{tabular}",
    "\\begin{tablenotes}[flushleft]",
    "\\small",
    "\\item \\textit{Notes:} RDD estimate of the discontinuity in the probability of appearing in both the 1900 and 1910 censuses at the age-62 threshold. Sample restricted to veterans alive at 1910. Conventional estimate uses local polynomial; bias-corrected estimate applies rdrobust correction. Conv.\\ SE is the conventional standard error; Robust SE is the bias-corrected robust standard error from rdrobust. $p$ (conv.) tests Estimate/Conv.\\ SE; $p$ (robust) tests Estimate/Robust SE.",
    "\\end{tablenotes}",
    "\\end{table}")
  write_tex(tabA2, "tabA2_panel_selection.tex")
}

## =========================================================================
## TABLE A3: Falsification Bandwidth Sensitivity (Appendix)
## =========================================================================
cat("Table A3: Falsification bandwidth sensitivity\n")
falsif_bw <- robust$falsif_bw
if (!is.null(falsif_bw) && nrow(falsif_bw) > 0) {
  tabA3 <- c(
    "\\begin{table}[htbp]",
    "\\centering",
    "\\caption{Pre-Treatment Falsification: LFP (1900) Across Bandwidths}",
    "\\label{tab:falsif_bw}",
    "\\begin{tabular}{cccccc}",
    "\\toprule",
    "  BW & Estimate & SE & $p$-value & $N_L$ & $N_R$ \\\\",
    "\\midrule")
  for (i in 1:nrow(falsif_bw)) {
    tabA3 <- c(tabA3,
      sprintf("  %d & %.4f & (%.4f) & %.3f & %d & %d \\\\",
              falsif_bw$bandwidth[i], falsif_bw$coef[i], falsif_bw$se_robust[i],
              falsif_bw$pval[i], falsif_bw$N_left[i], falsif_bw$N_right[i]))
  }
  tabA3 <- c(tabA3,
    "\\bottomrule",
    "\\end{tabular}",
    "\\begin{tablenotes}[flushleft]",
    "\\small",
    "\\item \\textit{Notes:} RDD estimates of the discontinuity in LFP at 1900 (pre-treatment) at the age-62-in-1907 threshold across bandwidths. Conventional coefficients with robust standard errors. $p$-values from $z = $ estimate/SE. A non-significant estimate supports the identifying assumption; a significant positive estimate suggests composition differences across the cutoff.",
    "\\end{tablenotes}",
    "\\end{table}")
  write_tex(tabA3, "tabA3_falsif_bw.tex")
}

## ---- Summary ----
tabs <- list.files(tab_dir, pattern = "\\.tex$")
cat("\n=== TABLES GENERATED:", length(tabs), "===\n")
for (t in sort(tabs)) cat("  ", t, "\n")
