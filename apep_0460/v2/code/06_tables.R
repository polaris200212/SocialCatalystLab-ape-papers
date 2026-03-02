## ============================================================================
## 06_tables.R — All Table Generation
## APEP-0460: Across the Channel
## ============================================================================
source("00_packages.R")

cat("=== Loading results ===\n")
results <- readRDS(file.path(data_dir, "main_results.rds"))
robust <- readRDS(file.path(data_dir, "robustness_results.rds"))
dept_exposure <- readRDS(file.path(data_dir, "dept_exposure.rds"))

## ========================================================================
## TABLE 1: SUMMARY STATISTICS
## ========================================================================
cat("=== Table 1: Summary Statistics ===\n")

# Load analysis data
panel <- as.data.table(readRDS(file.path(data_dir, "analysis_panel.rds")))

# Panel A: Cross-sectional exposure variation
safe_col <- function(dt, col) if (col %in% names(dt)) dt[[col]] else rep(NA, nrow(dt))

exp_vars <- list(
  c("Total SCI to UK", "sci_total_uk"),
  c("Total SCI to Germany", "sci_total_de"),
  c("Total SCI to Switzerland", "sci_total_ch"),
  c("N UK connections", "n_uk_connections"),
  c("SCI Herfindahl (UK)", "sci_hhi")
)

exp_rows <- list()
for (v in exp_vars) {
  vals <- safe_col(dept_exposure, v[2])
  vals <- vals[!is.na(vals)]
  if (length(vals) > 0) {
    # Use more decimals for small values like HHI
    ndec <- if (mean(vals, na.rm = TRUE) < 0.1) 4 else 2
    fmt <- function(x) formatC(round(x, ndec), format = "f", digits = ndec)
    exp_rows <- c(exp_rows, list(data.table(
      Variable = v[1],
      Mean = fmt(mean(vals)),
      SD = fmt(sd(vals)),
      Min = fmt(min(vals)),
      Max = fmt(max(vals))
    )))
  }
}
exp_stats <- rbindlist(exp_rows)

# Panel B: Outcome variables
dvf_panel <- panel[!is.na(log_price_m2)]
if (nrow(dvf_panel) > 0) {
  dvf_stats <- data.table(
    Variable = c("Median price/m\\textsuperscript{2} (\\euro{})",
                 "Log median price/m\\textsuperscript{2}",
                 "N transactions (quarterly)",
                 "Log N transactions"),
    Mean = round(c(mean(dvf_panel$median_price_m2, na.rm = TRUE),
                   mean(dvf_panel$log_price_m2, na.rm = TRUE),
                   mean(dvf_panel$n_transactions, na.rm = TRUE),
                   mean(dvf_panel$log_transactions, na.rm = TRUE)), 2),
    SD = round(c(sd(dvf_panel$median_price_m2, na.rm = TRUE),
                 sd(dvf_panel$log_price_m2, na.rm = TRUE),
                 sd(dvf_panel$n_transactions, na.rm = TRUE),
                 sd(dvf_panel$log_transactions, na.rm = TRUE)), 2),
    Min = round(c(min(dvf_panel$median_price_m2, na.rm = TRUE),
                  min(dvf_panel$log_price_m2, na.rm = TRUE),
                  min(dvf_panel$n_transactions, na.rm = TRUE),
                  min(dvf_panel$log_transactions, na.rm = TRUE)), 2),
    Max = round(c(max(dvf_panel$median_price_m2, na.rm = TRUE),
                  max(dvf_panel$log_price_m2, na.rm = TRUE),
                  max(dvf_panel$n_transactions, na.rm = TRUE),
                  max(dvf_panel$log_transactions, na.rm = TRUE)), 2)
  )
} else {
  dvf_stats <- NULL
}

# Write LaTeX table
n_units <- nrow(dept_exposure)
n_periods <- length(unique(panel$yq))
tex_lines <- c(
  "\\begin{table}[htbp]",
  "\\centering",
  "\\caption{Summary Statistics}",
  "\\label{tab:summary}",
  paste0("\\begin{tabular}{l", paste(rep("c", 4), collapse = ""), "}"),
  "\\toprule",
  " & Mean & SD & Min & Max \\\\",
  "\\midrule",
  "\\multicolumn{5}{l}{\\textit{Panel A: Cross-Sectional Exposure Variation}} \\\\[3pt]"
)

for (i in 1:nrow(exp_stats)) {
  tex_lines <- c(tex_lines,
                 paste0(exp_stats$Variable[i], " & ",
                        exp_stats$Mean[i], " & ",
                        exp_stats$SD[i], " & ",
                        exp_stats$Min[i], " & ",
                        exp_stats$Max[i], " \\\\"))
}

if (!is.null(dvf_stats)) {
  tex_lines <- c(tex_lines,
                 "\\midrule",
                 "\\multicolumn{5}{l}{\\textit{Panel B: Outcome Variables (Quarterly)}} \\\\[3pt]")
  for (i in 1:nrow(dvf_stats)) {
    tex_lines <- c(tex_lines,
                   paste0(dvf_stats$Variable[i], " & ",
                          dvf_stats$Mean[i], " & ",
                          dvf_stats$SD[i], " & ",
                          dvf_stats$Min[i], " & ",
                          dvf_stats$Max[i], " \\\\"))
  }
}

tex_lines <- c(tex_lines,
               "\\bottomrule",
               "\\end{tabular}",
               "\\begin{minipage}{0.9\\textwidth}",
               paste0("\\footnotesize \\textit{Notes:} Panel A: SCI exposure computed for ",
                      n_units, " metropolitan French d\\'{e}partements. ",
                      "Panel B: DVF housing outcomes available for 93 d\\'{e}partements ",
                      "(3 Alsace-Moselle d\\'{e}partements lack DVF coverage) over ", n_periods, " quarters. ",
                      "SCI = Facebook Social Connectedness Index. ",
                      "DVF = Demandes de Valeurs Fonci\\`eres (2014--2023)."),
               "\\end{minipage}",
               "\\end{table}")

writeLines(tex_lines, file.path(tab_dir, "tab1_summary.tex"))
cat("  Saved tab1_summary.tex\n")

## ========================================================================
## TABLE 2: MAIN RESULTS
## ========================================================================
cat("=== Table 2: Main Results ===\n")

setFixest_dict(c(
  "log_sci_uk:post_referendum" = "Log SCI(UK) $\\times$ Post-Referendum",
  "log_sci_uk:post_transition" = "Log SCI(UK) $\\times$ Post-Transition",
  "log_sci_de:post_referendum" = "Log SCI(Germany) $\\times$ Post-Referendum",
  "log_prob_uk:post_referendum" = "Log SCI(UK, prob.) $\\times$ Post-Referendum",
  "log_sci_uk:covid_period" = "Log SCI(UK) $\\times$ COVID Period",
  "log_sci_ch:post_chf" = "Log SCI(CH) $\\times$ Post-CHF Shock",
  "log_price_m2" = "Log Price/m$^2$",
  "log_transactions" = "Log Transactions",
  "fr_region" = "D\\'{e}partement",
  "yq" = "Quarter-Year"
))

models_main <- list()
if (!is.null(results$m1)) models_main$`(1)` <- results$m1
if (!is.null(results$m2)) models_main$`(2)` <- results$m2
if (!is.null(results$m4)) models_main$`(3)` <- results$m4
if (!is.null(results$m5)) models_main$`(4)` <- results$m5

if (length(models_main) > 0) {
  etable(models_main,
         tex = TRUE,
         style.tex = style.tex("aer"),
         fitstat = ~ wr2 + n,
         title = "Cross-Border Network Spillovers from Brexit to French Housing Markets",
         label = "tab:main_results",
         notes = paste0("All specifications include region and quarter-year fixed effects. ",
                        "Standard errors clustered by region in parentheses. ",
                        "Log SCI(UK) measures the log of total Facebook Social ",
                        "Connectedness Index from each French region to all UK regions. ",
                        "Post-Referendum = 1 from 2016 Q3. Post-Transition = 1 from 2021 Q1. ",
                        "Cols (1)--(3): log price/m$^2$ from DVF. Col (4): log transactions. ",
                        "$^{***}p<0.01$, $^{**}p<0.05$, $^{*}p<0.1$."),
         file = file.path(tab_dir, "tab2_main_results.tex"))
  cat("  Saved tab2_main_results.tex\n")
}

## ========================================================================
## TABLE 3: PLACEBO — MULTIPLE COUNTRIES
## ========================================================================
cat("=== Table 3: Placebo Comparison ===\n")

models_placebo <- list()
if (!is.null(results$m1)) models_placebo$`UK (Treatment)` <- results$m1
if (!is.null(results$m3)) models_placebo$`Germany (Placebo)` <- results$m3
if (!is.null(results$m4)) models_placebo$`Horse Race` <- results$m4
if (!is.null(robust$swiss_placebo)) models_placebo$`Switzerland` <- robust$swiss_placebo

if (length(models_placebo) > 0) {
  etable(models_placebo,
         tex = TRUE,
         style.tex = style.tex("aer"),
         fitstat = ~ wr2 + n,
         title = "Placebo Tests: UK Treatment vs. Germany and Switzerland",
         label = "tab:placebo",
         notes = paste0("All specifications: Log SCI(country) $\\times$ Post with ",
                        "region and quarter-year FE. SE clustered by region. ",
                        "Col 1: UK SCI $\\times$ Post-Referendum. ",
                        "Col 2: Germany SCI $\\times$ Post-Referendum (null expected). ",
                        "Col 3: Both UK and Germany in same regression. ",
                        "Col 4: Switzerland SCI $\\times$ Post-CHF shock (Jan 2015). ",
                        "$^{***}p<0.01$, $^{**}p<0.05$, $^{*}p<0.1$."),
         file = file.path(tab_dir, "tab3_placebo.tex"))
  cat("  Saved tab3_placebo.tex\n")
}

## ========================================================================
## TABLE 4: ROBUSTNESS — CLUSTERING AND WEIGHTING
## ========================================================================
cat("=== Table 4: Robustness ===\n")

models_robust <- list()
if (!is.null(results$m1)) models_robust$`Baseline` <- results$m1
if (!is.null(robust$clustering$twoway)) models_robust$`Two-Way Cluster` <- robust$clustering$twoway
if (!is.null(robust$clustering$hetero)) models_robust$`HC Robust` <- robust$clustering$hetero
if (!is.null(robust$weighting$prob_weighted)) models_robust$`Prob-Weighted` <- robust$weighting$prob_weighted
if (!is.null(robust$covid)) models_robust$`COVID Control` <- robust$covid

if (length(models_robust) > 0) {
  etable(models_robust,
         tex = TRUE,
         style.tex = style.tex("aer"),
         fitstat = ~ wr2 + n,
         title = "Robustness: Alternative Specifications",
         label = "tab:robustness",
         notes = paste0("Col 1: baseline (region-clustered SE). ",
                        "Col 2: two-way clustered (region + quarter). ",
                        "Col 3: heteroskedasticity-robust SE. ",
                        "Col 4: probability-weighted SCI (mean instead of total). ",
                        "Col 5: controls for COVID period interaction. ",
                        "$^{***}p<0.01$, $^{**}p<0.05$, $^{*}p<0.1$."),
         file = file.path(tab_dir, "tab4_robustness.tex"))
  cat("  Saved tab4_robustness.tex\n")
}

## ========================================================================
## TABLE 5: UK COUNTRY DECOMPOSITION
## ========================================================================
cat("=== Table 5: UK Country Decomposition ===\n")

if (!is.null(robust$distance) && nrow(robust$distance) > 0) {
  dist <- robust$distance

  tex_dist <- c(
    "\\begin{table}[htbp]",
    "\\centering",
    "\\caption{UK Country Composition: Progressively Restricting Exposure}",
    "\\label{tab:distance}",
    "\\begin{tabular}{lccc}",
    "\\toprule",
    "UK Composition & Coefficient & SE & N UK Regions (GADM2) \\\\",
    "\\midrule"
  )

  for (i in 1:nrow(dist)) {
    sig <- ifelse(abs(dist$coef[i]) > 2.58 * dist$se[i], "***",
                  ifelse(abs(dist$coef[i]) > 1.96 * dist$se[i], "**",
                         ifelse(abs(dist$coef[i]) > 1.64 * dist$se[i], "*", "")))
    tex_dist <- c(tex_dist,
                  paste0(dist$band[i], " & ",
                         sprintf("%.4f%s", dist$coef[i], sig), " & (",
                         sprintf("%.4f", dist$se[i]), ") & ",
                         dist$n_uk_regions[i], " \\\\"))
  }

  tex_dist <- c(tex_dist,
                "\\bottomrule",
                "\\end{tabular}",
                "\\begin{minipage}{0.9\\textwidth}",
                paste0("\\footnotesize \\textit{Notes:} Each row restricts the set of UK ",
                       "GADM2 regions used to construct the SCI exposure measure. ",
                       "England's 118 regions dominate UK SCI due to population size. ",
                       "If effects are driven only by England-specific confounders, ",
                       "restricting to non-England regions should attenuate coefficients. ",
                       "$^{***}p<0.01$, $^{**}p<0.05$, $^{*}p<0.1$."),
                "\\end{minipage}",
                "\\end{table}")

  writeLines(tex_dist, file.path(tab_dir, "tab5_distance.tex"))
  cat("  Saved tab5_distance.tex\n")
}

## ========================================================================
## TABLE 6: PERMUTATION INFERENCE
## ========================================================================
cat("=== Table 6: Permutation Summary ===\n")

if (!is.null(robust$permutation)) {
  perm <- robust$permutation

  tex_perm <- c(
    "\\begin{table}[htbp]",
    "\\centering",
    "\\caption{Permutation Inference: Randomization of SCI Exposure}",
    "\\label{tab:permutation}",
    "\\begin{tabular}{lc}",
    "\\toprule",
    "Statistic & Value \\\\",
    "\\midrule",
    paste0("Actual coefficient & ", sprintf("%.4f", perm$actual), " \\\\"),
    paste0("Number of permutations & ", length(perm$perm_coefs), " \\\\"),
    paste0("Mean permuted coefficient & ",
           sprintf("%.4f", mean(perm$perm_coefs)), " \\\\"),
    paste0("SD permuted coefficient & ",
           sprintf("%.4f", sd(perm$perm_coefs)), " \\\\"),
    paste0("Permutation p-value (two-sided) & ",
           format(round(perm$p_value, 3), nsmall = 3), " \\\\"),
    paste0("Actual / SD(permuted) & ",
           sprintf("%.2f", perm$actual / sd(perm$perm_coefs)), " \\\\"),
    "\\bottomrule",
    "\\end{tabular}",
    "\\begin{minipage}{0.9\\textwidth}",
    paste0("\\footnotesize \\textit{Notes:} SCI exposure is randomly reassigned ",
           "across French regions in each permutation, holding the panel structure ",
           "and time fixed effects fixed. The p-value is the share of permutations ",
           "where $|\\hat{\\beta}_{\\text{perm}}| \\geq |\\hat{\\beta}_{\\text{actual}}|$. ",
           "Under the null of no network effect, exposure should not predict outcomes."),
    "\\end{minipage}",
    "\\end{table}")

  writeLines(tex_perm, file.path(tab_dir, "tab6_permutation.tex"))
  cat("  Saved tab6_permutation.tex\n")
}

cat("\n=== All tables generated ===\n")
cat("Files in tables directory:\n")
cat(paste(list.files(tab_dir), collapse = "\n"), "\n")
