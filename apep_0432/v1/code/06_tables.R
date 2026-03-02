## ============================================================
## 06_tables.R — Publication-quality tables (LaTeX)
## Breaking Purdah with Pavement (apep_0432)
## ============================================================
source(here::here("output", "apep_0432", "v1", "code", "00_packages.R"))
load(file.path(data_dir, "analysis_panel.RData"))
load(file.path(data_dir, "main_results.RData"))
load(file.path(data_dir, "robustness_results.RData"))

caste_cats <- c("General/OBC-dominated", "SC-dominated", "ST-dominated")

## ================================================================
## TABLE 1: Summary Statistics
## ================================================================

cat("=== Table 1: Summary Statistics ===\n")

## Compute summary stats for main bandwidth sample
summ_vars <- c("pop01", "sc_share_01", "st_share_01", "fwpr_01", "fwpr_11",
               "d_fwpr", "mwpr_01", "mwpr_11", "d_mwpr",
               "f_aglabor_share_01", "f_cultiv_share_01", "f_other_share_01",
               "f_litrate_01", "csr_01")
summ_labels <- c("Population (2001)", "SC share (2001)", "ST share (2001)",
                  "Female WPR (2001)", "Female WPR (2011)",
                  "\\(\\Delta\\) Female WPR", "Male WPR (2001)", "Male WPR (2011)",
                  "\\(\\Delta\\) Male WPR",
                  "F Ag Labor Share (2001)", "F Cultivator Share (2001)",
                  "F Other Work Share (2001)", "F Literacy Rate (2001)",
                  "Child Sex Ratio (2001)")

summ_dt <- data.table(Variable = summ_labels)
for (i in seq_along(summ_vars)) {
  x <- panel_bw[[summ_vars[i]]]
  summ_dt[i, `:=`(
    Mean = mean(x, na.rm = TRUE),
    SD = sd(x, na.rm = TRUE),
    N = sum(!is.na(x))
  )]
}

## By caste category
for (cc in c("General/OBC-dominated", "SC-dominated", "ST-dominated")) {
  sub <- panel_bw[caste_dominant == cc]
  suffix <- gsub("[/-]", "", gsub("dominated", "", cc))
  for (i in seq_along(summ_vars)) {
    x <- sub[[summ_vars[i]]]
    set(summ_dt, i, paste0("Mean_", suffix), mean(x, na.rm = TRUE))
    set(summ_dt, i, paste0("N_", suffix), sum(!is.na(x)))
  }
}

## Write LaTeX table
tab1_tex <- c(
  "\\begin{table}[!htbp]",
  "\\centering",
  "\\caption{Summary Statistics: Near-Threshold Villages (Population 300--700)}",
  "\\label{tab:summary}",
  "\\small",
  "\\begin{tabular}{lcccccc}",
  "\\toprule",
  " & \\multicolumn{2}{c}{Full Sample} & \\multicolumn{3}{c}{By Dominant Caste} \\\\",
  "\\cmidrule(lr){2-3} \\cmidrule(lr){4-6}",
  " & Mean & SD & Gen/OBC & SC & ST \\\\",
  "\\midrule"
)

for (i in 1:nrow(summ_dt)) {
  row_str <- sprintf("%s & %.3f & %.3f & %.3f & %.3f & %.3f \\\\",
                     summ_dt$Variable[i],
                     summ_dt$Mean[i], summ_dt$SD[i],
                     summ_dt[["Mean_GeneralOBC"]][i],
                     summ_dt[["Mean_SC"]][i],
                     summ_dt[["Mean_ST"]][i])
  tab1_tex <- c(tab1_tex, row_str)
  ## Add midrule after baseline vars
  if (i == 3) tab1_tex <- c(tab1_tex, "\\midrule")
  if (i == 9) tab1_tex <- c(tab1_tex, "\\midrule")
}

tab1_tex <- c(tab1_tex,
  "\\midrule",
  sprintf("Villages & %s & & %s & %s & %s \\\\",
          formatC(nrow(panel_bw), big.mark = ","),
          formatC(nrow(panel_bw[caste_dominant == "General/OBC-dominated"]), big.mark = ","),
          formatC(nrow(panel_bw[caste_dominant == "SC-dominated"]), big.mark = ","),
          formatC(nrow(panel_bw[caste_dominant == "ST-dominated"]), big.mark = ",")),
  "\\bottomrule",
  "\\end{tabular}",
  "\\begin{tablenotes}",
  "\\small",
  "\\item \\textit{Notes:} Sample restricted to Census 2001 population between 300 and 700",
  "(main bandwidth around the PMGSY 500-person eligibility threshold). SC = Scheduled Caste,",
  "ST = Scheduled Tribe, Gen/OBC = General/Other Backward Classes.",
  "A village is classified as ``X-dominated'' if X-share exceeds 50\\%.",
  "\\(\\Delta\\) denotes the change from 2001 to 2011.",
  "\\end{tablenotes}",
  "\\end{table}"
)

writeLines(tab1_tex, file.path(tab_dir, "tab1_summary.tex"))

## ================================================================
## TABLE 2: Main RDD Results — Pooled
## ================================================================

cat("=== Table 2: Main RDD Results ===\n")

format_stars <- function(pval) {
  if (is.na(pval)) return("")
  if (pval < 0.01) return("$^{***}$")
  if (pval < 0.05) return("$^{**}$")
  if (pval < 0.1) return("$^{*}$")
  return("")
}

tab2_tex <- c(
  "\\begin{table}[!htbp]",
  "\\centering",
  "\\caption{Effect of PMGSY Eligibility on Female Employment Outcomes (Pooled RDD)}",
  "\\label{tab:main_rdd}",
  "\\small",
  "\\begin{tabular}{lccccc}",
  "\\toprule",
  "Outcome & Coeff. & SE & $p$-value & BW & $N_{\\text{eff}}$ \\\\",
  "\\midrule"
)

for (i in 1:nrow(rdd_pooled)) {
  if (is.na(rdd_pooled$Coeff[i])) next
  stars <- format_stars(rdd_pooled$Pval[i])
  row_str <- sprintf("%s & %.4f%s & (%.4f) & %.3f & %.0f & %s \\\\",
                     rdd_pooled$Outcome[i],
                     rdd_pooled$Coeff[i], stars,
                     rdd_pooled$SE[i],
                     rdd_pooled$Pval[i],
                     rdd_pooled$BW[i],
                     formatC(rdd_pooled$N_eff[i], big.mark = ","))
  tab2_tex <- c(tab2_tex, row_str)
}

tab2_tex <- c(tab2_tex,
  "\\bottomrule",
  "\\end{tabular}",
  "\\begin{tablenotes}",
  "\\small",
  "\\item \\textit{Notes:} Local polynomial RDD estimates using \\texttt{rdrobust} with",
  "triangular kernel and MSE-optimal bandwidth. Running variable: Census 2001 population.",
  "Threshold: 500. Sample: villages with population 50--2,000.",
  "$^{***} p<0.01$, $^{**} p<0.05$, $^{*} p<0.1$.",
  "\\end{tablenotes}",
  "\\end{table}"
)

writeLines(tab2_tex, file.path(tab_dir, "tab2_main_rdd.tex"))

## ================================================================
## TABLE 3: Heterogeneous RDD by Caste
## ================================================================

cat("=== Table 3: Heterogeneous RDD ===\n")

## Reshape hetero_all for nice table
key_out <- c("Chg Female WPR", "Chg Male WPR", "Chg Gender Gap",
             "Chg F Ag Labor", "Chg F Other Work", "Chg F Non-Worker",
             "Chg F Literacy", "Chg Child Sex Ratio")

tab3_tex <- c(
  "\\begin{table}[!htbp]",
  "\\centering",
  "\\caption{Heterogeneous RDD Effects by Village Caste Composition}",
  "\\label{tab:hetero_rdd}",
  "\\small",
  "\\begin{tabular}{lcccccc}",
  "\\toprule",
  " & \\multicolumn{2}{c}{General/OBC} & \\multicolumn{2}{c}{SC-dominated} & \\multicolumn{2}{c}{ST-dominated} \\\\",
  "\\cmidrule(lr){2-3} \\cmidrule(lr){4-5} \\cmidrule(lr){6-7}",
  "Outcome & Coeff. & SE & Coeff. & SE & Coeff. & SE \\\\",
  "\\midrule"
)

for (out in key_out) {
  parts <- character(0)
  parts <- c(parts, out)
  for (cc in caste_cats) {
    row <- hetero_all[Caste == cc & Outcome == out]
    if (nrow(row) == 1 && !is.na(row$Coeff)) {
      stars <- format_stars(row$Pval)
      parts <- c(parts, sprintf("%.4f%s", row$Coeff, stars))
      parts <- c(parts, sprintf("(%.4f)", row$SE))
    } else {
      parts <- c(parts, "--", "--")
    }
  }
  tab3_tex <- c(tab3_tex, paste(parts, collapse = " & "), "\\\\")
}

## Add sample sizes
n_gen <- hetero_all[Caste == "General/OBC-dominated" & !is.na(N_eff), N_eff[1]]
n_sc <- hetero_all[Caste == "SC-dominated" & !is.na(N_eff), N_eff[1]]
n_st <- hetero_all[Caste == "ST-dominated" & !is.na(N_eff), N_eff[1]]

tab3_tex <- c(tab3_tex,
  "\\midrule",
  sprintf("$N_{\\text{eff}}$ (approx.) & \\multicolumn{2}{c}{%s} & \\multicolumn{2}{c}{%s} & \\multicolumn{2}{c}{%s} \\\\",
          formatC(n_gen, big.mark = ","), formatC(n_sc, big.mark = ","), formatC(n_st, big.mark = ",")),
  "\\bottomrule",
  "\\end{tabular}",
  "\\begin{tablenotes}",
  "\\small",
  "\\item \\textit{Notes:} Split-sample RDD estimates using \\texttt{rdrobust}.",
  "A village is classified as ``X-dominated'' if X-share exceeds 50\\%.",
  "Triangular kernel, MSE-optimal bandwidth.",
  "$^{***} p<0.01$, $^{**} p<0.05$, $^{*} p<0.1$.",
  "\\end{tablenotes}",
  "\\end{table}"
)

writeLines(tab3_tex, file.path(tab_dir, "tab3_hetero_rdd.tex"))

## ================================================================
## TABLE 4: Parametric RDD with Caste Interactions
## ================================================================

cat("=== Table 4: Parametric Interactions ===\n")

## Use modelsummary for a nice multi-column table
models_list <- list(
  "Female WPR" = fit_fwpr,
  "Male WPR"   = fit_mwpr,
  "Gender Gap"  = fit_gap,
  "F Other Work" = fit_other,
  "F Non-Worker" = fit_nonwork,
  "F Literacy" = fit_litrate
)

coef_rename <- c(
  "eligible_500" = "Eligible (pop $\\geq$ 500)",
  "sc_share_01" = "SC share (2001)",
  "st_share_01" = "ST share (2001)",
  "eligible_500:sc_share_01" = "Eligible $\\times$ SC share",
  "eligible_500:st_share_01" = "Eligible $\\times$ ST share",
  "pop01_c500" = "Pop. $-$ 500",
  "I(pop01_c500 * eligible_500)" = "Pop. $-$ 500 $\\times$ Eligible"
)

tab4_file <- file.path(tab_dir, "tab4_parametric.tex")
modelsummary(models_list,
             output = tab4_file,
             coef_rename = coef_rename,
             stars = c('*' = 0.1, '**' = 0.05, '***' = 0.01),
             gof_map = c("nobs", "r.squared", "FE: pc11_state_id"),
             title = "Parametric RDD with Caste Interactions (BW 300--700)",
             notes = list("State fixed effects. Standard errors clustered by district.",
                          "Sample: villages with pop. 300--700."),
             escape = FALSE)

## ================================================================
## TABLE 5: Covariate Balance
## ================================================================

cat("=== Table 5: Covariate Balance ===\n")

tab5_tex <- c(
  "\\begin{table}[!htbp]",
  "\\centering",
  "\\caption{Covariate Balance at the PMGSY Threshold}",
  "\\label{tab:balance}",
  "\\small",
  "\\begin{tabular}{lccccc}",
  "\\toprule",
  "Pre-treatment variable & Coeff. & SE & $p$-value & BW & $N_{\\text{eff}}$ \\\\",
  "\\midrule"
)

for (i in 1:nrow(balance_results)) {
  if (is.na(balance_results$Coeff[i])) next
  stars <- format_stars(balance_results$Pval[i])
  row_str <- sprintf("%s & %.4f%s & (%.4f) & %.3f & %.0f & %s \\\\",
                     balance_results$Variable[i],
                     balance_results$Coeff[i], stars,
                     balance_results$SE[i],
                     balance_results$Pval[i],
                     balance_results$BW[i],
                     formatC(balance_results$N_eff[i], big.mark = ","))
  tab5_tex <- c(tab5_tex, row_str)
}

tab5_tex <- c(tab5_tex,
  "\\bottomrule",
  "\\end{tabular}",
  "\\begin{tablenotes}",
  "\\small",
  "\\item \\textit{Notes:} Each row is a separate RDD estimate using \\texttt{rdrobust}.",
  "All variables are pre-treatment (Census 2001). None is significant at the 5\\% level.",
  "$^{***} p<0.01$, $^{**} p<0.05$, $^{*} p<0.1$.",
  "\\end{tablenotes}",
  "\\end{table}"
)

writeLines(tab5_tex, file.path(tab_dir, "tab5_balance.tex"))

## ================================================================
## TABLE 6: Robustness — 250 Threshold
## ================================================================

cat("=== Table 6: 250 Threshold ===\n")

tab6_tex <- c(
  "\\begin{table}[!htbp]",
  "\\centering",
  "\\caption{RDD at 250-Person Threshold (Hills/Tribal Subsample, ST Share $>$ 25\\%)}",
  "\\label{tab:rdd250}",
  "\\small",
  "\\begin{tabular}{lccccc}",
  "\\toprule",
  "Outcome & Coeff. & SE & $p$-value & BW & $N_{\\text{eff}}$ \\\\",
  "\\midrule"
)

for (i in 1:nrow(rdd_250)) {
  if (is.na(rdd_250$Coeff[i])) next
  stars <- format_stars(rdd_250$Pval[i])
  row_str <- sprintf("%s & %.4f%s & (%.4f) & %.3f & %.0f & %s \\\\",
                     rdd_250$Outcome[i],
                     rdd_250$Coeff[i], stars,
                     rdd_250$SE[i],
                     rdd_250$Pval[i],
                     rdd_250$BW[i],
                     formatC(rdd_250$N_eff[i], big.mark = ","))
  tab6_tex <- c(tab6_tex, row_str)
}

tab6_tex <- c(tab6_tex,
  "\\bottomrule",
  "\\end{tabular}",
  "\\begin{tablenotes}",
  "\\small",
  "\\item \\textit{Notes:} Sample restricted to villages with ST share $>$ 25\\% (Census 2001).",
  "PMGSY mandates a 250-person threshold in hills, tribal, and desert areas.",
  "This provides an independent replication of the threshold design.",
  "$^{***} p<0.01$, $^{**} p<0.05$, $^{*} p<0.1$.",
  "\\end{tablenotes}",
  "\\end{table}"
)

writeLines(tab6_tex, file.path(tab_dir, "tab6_rdd250.tex"))

cat("\nAll tables saved.\n")
