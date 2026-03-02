## ============================================================
## 06_tables.R — All table generation
## PMGSY 250 Threshold RDD — Tribal/Hill Areas
## ============================================================

source(file.path(dirname(sub("--file=", "", grep("--file=", commandArgs(FALSE), value=TRUE))), "00_packages.R"))

out_dir <- file.path(WORK_DIR, "data")
tab_dir <- file.path(WORK_DIR, "tables")

sample_A   <- readRDS(file.path(out_dir, "sample_250_A.rds"))
sample_B   <- readRDS(file.path(out_dir, "sample_250_B.rds"))
sample_500 <- readRDS(file.path(out_dir, "sample_500.rds"))
df_full    <- readRDS(file.path(out_dir, "analysis_full.rds"))
results_A  <- readRDS(file.path(out_dir, "results_250_A.rds"))
results_B  <- readRDS(file.path(out_dir, "results_250_B.rds"))
results_500 <- readRDS(file.path(out_dir, "results_500.rds"))

# ============================================================
# Table 1: Summary Statistics
# ============================================================

cat("Generating Table 1: Summary Statistics...\n")

make_sumstats <- function(data, label) {
  vars <- c("pop_01", "literacy_01", "f_lit_01", "st_share_01",
            "sc_share_01", "worker_share_01", "f_worker_share_01",
            "n_hh_01", "log_nl_pre")
  stats <- data.frame(
    Variable = c("Population (2001)", "Literacy Rate", "Female Literacy Rate",
                 "ST Share", "SC Share", "Worker Share", "Female Worker Share",
                 "Households", "Log Nightlights (Pre)"),
    Mean = sapply(vars, function(v) round(mean(data[[v]], na.rm = TRUE), 3)),
    SD   = sapply(vars, function(v) round(sd(data[[v]], na.rm = TRUE), 3)),
    N    = sapply(vars, function(v) sum(!is.na(data[[v]]))),
    stringsAsFactors = FALSE
  )
  stats$Sample <- label
  stats
}

# Full designated area sample (within ±200 of 250)
desig_full <- df_full[designated_A == TRUE & pop_01 >= 50 & pop_01 <= 500]
below_250 <- desig_full[pop_01 < 250]
above_250 <- desig_full[pop_01 >= 250]
nondsg <- df_full[designated_A == FALSE & designated_B == FALSE & pop_01 >= 300 & pop_01 <= 750]

sumstats <- rbind(
  make_sumstats(below_250, "Below 250"),
  make_sumstats(above_250, "Above 250"),
  make_sumstats(nondsg, "Non-Designated (near 500)")
)

# LaTeX table
tex_lines <- c(
  "\\begin{table}[htbp]",
  "\\centering",
  "\\caption{Summary Statistics: Designated vs Non-Designated Areas}",
  "\\label{tab:sumstats}",
  "\\begin{tabular}{lcccccc}",
  "\\toprule",
  " & \\multicolumn{2}{c}{Below 250} & \\multicolumn{2}{c}{Above 250} & \\multicolumn{2}{c}{Non-Designated} \\\\",
  "\\cmidrule(lr){2-3} \\cmidrule(lr){4-5} \\cmidrule(lr){6-7}",
  "Variable & Mean & SD & Mean & SD & Mean & SD \\\\"
)

vars_show <- c("Population (2001)", "Literacy Rate", "Female Literacy Rate",
               "ST Share", "SC Share", "Worker Share", "Female Worker Share",
               "Households", "Log Nightlights (Pre)")

tex_lines <- c(tex_lines, "\\midrule")

for (v in vars_show) {
  b <- sumstats[sumstats$Variable == v & sumstats$Sample == "Below 250", ]
  a <- sumstats[sumstats$Variable == v & sumstats$Sample == "Above 250", ]
  n <- sumstats[sumstats$Variable == v & sumstats$Sample == "Non-Designated (near 500)", ]

  tex_lines <- c(tex_lines, sprintf(
    "%s & %.3f & %.3f & %.3f & %.3f & %.3f & %.3f \\\\",
    v, b$Mean, b$SD, a$Mean, a$SD, n$Mean, n$SD
  ))
}

tex_lines <- c(tex_lines,
               "\\midrule",
               sprintf("Observations & \\multicolumn{2}{c}{%s} & \\multicolumn{2}{c}{%s} & \\multicolumn{2}{c}{%s} \\\\",
                       format(nrow(below_250), big.mark = ","),
                       format(nrow(above_250), big.mark = ","),
                       format(nrow(nondsg), big.mark = ",")),
               "\\bottomrule",
               "\\end{tabular}",
               "\\begin{minipage}{0.95\\textwidth}",
               "\\vspace{0.5em}",
               "\\footnotesize",
               "\\textit{Notes:} Summary statistics for villages in Special Category States (designated areas) within 50--500 population range, split at the 250 PMGSY eligibility threshold. Non-designated sample includes villages in plains states near the 500 threshold. Data from SHRUG v2.1 Census 2001 PCA and DMSP nightlights.",
               "\\end{minipage}",
               "\\end{table}")

writeLines(tex_lines, file.path(tab_dir, "tab1_sumstats.tex"))

# ============================================================
# Table 2: Main RDD Results
# ============================================================

cat("Generating Table 2: Main RDD Results...\n")

outcomes_labels <- c(
  "literacy_11"       = "Literacy Rate",
  "f_lit_11"          = "Female Literacy",
  "nonag_share_11"    = "Non-Ag Worker Share",
  "f_worker_share_11" = "Female Worker Share",
  "pop_growth"        = "Population Growth",
  "log_nl_post_viirs" = "Log NL (VIIRS)"
)

tex2 <- c(
  "\\begin{table}[htbp]",
  "\\centering",
  "\\caption{RDD Estimates: Effect of PMGSY Eligibility on Development Outcomes}",
  "\\label{tab:main_rdd}",
  "\\small",
  "\\begin{tabular}{lcccccc}",
  "\\toprule",
  paste0(" & ", paste(outcomes_labels, collapse = " & "), " \\\\"),
  paste0(" & ", paste(paste0("(", 1:6, ")"), collapse = " & "), " \\\\"),
  "\\midrule",
  "\\multicolumn{7}{l}{\\textit{Panel A: 250 Threshold (Special Category States)}} \\\\"
)

# Panel A: 250 threshold, Sample A
coef_row <- "RDD Estimate"
se_row <- ""
for (var in names(outcomes_labels)) {
  r <- results_A[[var]]
  coef_val <- ifelse(is.na(r$coef), "", sprintf("%.4f", r$coef))
  se_val <- ifelse(is.na(r$se), "", sprintf("(%.4f)", r$se))
  stars <- ""
  if (!is.na(r$pval)) {
    if (r$pval < 0.01) stars <- "***"
    else if (r$pval < 0.05) stars <- "**"
    else if (r$pval < 0.1) stars <- "*"
  }
  coef_row <- paste0(coef_row, " & ", coef_val, stars)
  se_row <- paste0(se_row, " & ", se_val)
}
tex2 <- c(tex2, paste0(coef_row, " \\\\"), paste0(se_row, " \\\\"))

# Bandwidth and N
bw_row <- "Bandwidth"
n_row <- "Effective N"
for (var in names(outcomes_labels)) {
  r <- results_A[[var]]
  bw_row <- paste0(bw_row, " & ", ifelse(is.na(r$bw), "", sprintf("%.0f", r$bw)))
  n_row <- paste0(n_row, " & ", ifelse(is.na(r$n_eff), "",
                                        format(r$n_eff, big.mark = ",")))
}
tex2 <- c(tex2, paste0(bw_row, " \\\\"), paste0(n_row, " \\\\"))

# Panel B: 250 threshold, Sample B
tex2 <- c(tex2, "\\midrule",
          "\\multicolumn{7}{l}{\\textit{Panel B: 250 Threshold (Extended Designated Areas)}} \\\\")

coef_row <- "RDD Estimate"
se_row <- ""
for (var in names(outcomes_labels)) {
  r <- results_B[[var]]
  coef_val <- ifelse(is.na(r$coef), "", sprintf("%.4f", r$coef))
  se_val <- ifelse(is.na(r$se), "", sprintf("(%.4f)", r$se))
  stars <- ""
  if (!is.na(r$pval)) {
    if (r$pval < 0.01) stars <- "***"
    else if (r$pval < 0.05) stars <- "**"
    else if (r$pval < 0.1) stars <- "*"
  }
  coef_row <- paste0(coef_row, " & ", coef_val, stars)
  se_row <- paste0(se_row, " & ", se_val)
}
tex2 <- c(tex2, paste0(coef_row, " \\\\"), paste0(se_row, " \\\\"))

bw_row <- "Bandwidth"
n_row <- "Effective N"
for (var in names(outcomes_labels)) {
  r <- results_B[[var]]
  bw_row <- paste0(bw_row, " & ", ifelse(is.na(r$bw), "", sprintf("%.0f", r$bw)))
  n_row <- paste0(n_row, " & ", ifelse(is.na(r$n_eff), "",
                                        format(r$n_eff, big.mark = ",")))
}
tex2 <- c(tex2, paste0(bw_row, " \\\\"), paste0(n_row, " \\\\"))

# Panel C: 500 threshold comparison
tex2 <- c(tex2, "\\midrule",
          "\\multicolumn{7}{l}{\\textit{Panel C: 500 Threshold (Non-Designated Plains)}} \\\\")

coef_row <- "RDD Estimate"
se_row <- ""
for (var in names(outcomes_labels)) {
  r <- results_500[[var]]
  coef_val <- ifelse(is.na(r$coef), "", sprintf("%.4f", r$coef))
  se_val <- ifelse(is.na(r$se), "", sprintf("(%.4f)", r$se))
  stars <- ""
  if (!is.na(r$pval)) {
    if (r$pval < 0.01) stars <- "***"
    else if (r$pval < 0.05) stars <- "**"
    else if (r$pval < 0.1) stars <- "*"
  }
  coef_row <- paste0(coef_row, " & ", coef_val, stars)
  se_row <- paste0(se_row, " & ", se_val)
}
tex2 <- c(tex2, paste0(coef_row, " \\\\"), paste0(se_row, " \\\\"))

bw_row <- "Bandwidth"
n_row <- "Effective N"
for (var in names(outcomes_labels)) {
  r <- results_500[[var]]
  bw_row <- paste0(bw_row, " & ", ifelse(is.na(r$bw), "", sprintf("%.0f", r$bw)))
  n_row <- paste0(n_row, " & ", ifelse(is.na(r$n_eff), "",
                                        format(r$n_eff, big.mark = ",")))
}
tex2 <- c(tex2, paste0(bw_row, " \\\\"), paste0(n_row, " \\\\"))

tex2 <- c(tex2,
           "\\bottomrule",
           "\\end{tabular}",
           "\\begin{minipage}{0.95\\textwidth}",
           "\\vspace{0.5em}",
           "\\footnotesize",
           "\\textit{Notes:} Each column reports the robust bias-corrected RDD estimate from \\texttt{rdrobust} using a local linear specification with triangular kernel and MSE-optimal bandwidth. Running variable is Census 2001 village population. Panel A uses villages in 11 Special Category/Hill States. Panel B adds villages with $>$50\\% ST population in Schedule V states. Panel C uses non-designated villages at the 500 threshold for comparison. Standard errors in parentheses. * $p<0.10$, ** $p<0.05$, *** $p<0.01$.",
           "\\end{minipage}",
           "\\end{table}")

writeLines(tex2, file.path(tab_dir, "tab2_main_rdd.tex"))

# ============================================================
# Table 3: Robustness — Balance, Placebo, Donut
# ============================================================

cat("Generating Table 3: Robustness...\n")

balance <- readRDS(file.path(out_dir, "balance_results.rds"))
placebo <- tryCatch(readRDS(file.path(out_dir, "placebo_results.rds")), error = function(e) NULL)
donut <- tryCatch(readRDS(file.path(out_dir, "donut_results.rds")), error = function(e) NULL)

# Balance test table
tex3 <- c(
  "\\begin{table}[htbp]",
  "\\centering",
  "\\caption{RDD Validity: Covariate Balance and Placebo Tests}",
  "\\label{tab:robustness}",
  "\\begin{tabular}{lcc}",
  "\\toprule",
  "\\multicolumn{3}{l}{\\textit{Panel A: Covariate Balance at 250 Threshold}} \\\\",
  "\\midrule",
  "Pre-Treatment Variable & RDD Estimate & Std. Error \\\\"
)

cov_labels <- c(
  "literacy_01" = "Literacy Rate (2001)",
  "f_lit_01" = "Female Literacy (2001)",
  "sc_share_01" = "SC Share (2001)",
  "st_share_01" = "ST Share (2001)",
  "worker_share_01" = "Worker Share (2001)",
  "f_worker_share_01" = "Female Worker Share (2001)",
  "log_nl_pre" = "Log Nightlights (Pre)"
)

tex3 <- c(tex3, "\\midrule")
for (var in names(cov_labels)) {
  r <- balance[[var]]
  if (is.null(r) || is.na(r$coef)) next
  stars <- ""
  if (!is.na(r$pval)) {
    if (r$pval < 0.01) stars <- "***"
    else if (r$pval < 0.05) stars <- "**"
    else if (r$pval < 0.1) stars <- "*"
  }
  tex3 <- c(tex3, sprintf("%s & %.4f%s & (%.4f) \\\\",
                          cov_labels[var], r$coef, stars, r$se))
}

# Panel B: Placebo thresholds
if (!is.null(placebo)) {
  tex3 <- c(tex3, "\\midrule",
            "\\multicolumn{3}{l}{\\textit{Panel B: Placebo Thresholds (Literacy 2011)}} \\\\",
            "\\midrule",
            "Threshold & RDD Estimate & Std. Error \\\\",
            "\\midrule")
  for (i in 1:nrow(placebo)) {
    if (is.na(placebo$coef[i])) next
    stars <- ""
    if (!is.na(placebo$pval[i])) {
      if (placebo$pval[i] < 0.01) stars <- "***"
      else if (placebo$pval[i] < 0.05) stars <- "**"
      else if (placebo$pval[i] < 0.1) stars <- "*"
    }
    tex3 <- c(tex3, sprintf("Population = %d & %.4f%s & (%.4f) \\\\",
                            placebo$threshold[i], placebo$coef[i], stars, placebo$se[i]))
  }
}

tex3 <- c(tex3,
          "\\bottomrule",
          "\\end{tabular}",
          "\\begin{minipage}{0.85\\textwidth}",
          "\\vspace{0.5em}",
          "\\footnotesize",
          "\\textit{Notes:} Panel A tests for discontinuities in pre-treatment (Census 2001) covariates at the 250 threshold. No significant imbalance supports the identifying assumption. Panel B reports RDD estimates for literacy at placebo thresholds where no effect is expected. Robust bias-corrected estimates from \\texttt{rdrobust}. * $p<0.10$, ** $p<0.05$, *** $p<0.01$.",
          "\\end{minipage}",
          "\\end{table}")

writeLines(tex3, file.path(tab_dir, "tab3_robustness.tex"))

cat("\nAll tables generated.\n")
