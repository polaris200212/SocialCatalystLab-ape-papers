###############################################################################
# 06_tables.R — Generate all tables
# Paper: The Price of Position (apep_0490)
###############################################################################

source("00_packages.R")

cat("=== Loading data ===\n")
df <- fread(file.path(DATA_DIR, "rdd_sample.csv"))
full <- fread(file.path(DATA_DIR, "full_sample.csv"))

# ============================================================================
# Table 1: Summary Statistics
# ============================================================================

cat("=== Table 1: Summary Statistics ===\n")

# Summary for full sample and RDD sample
compute_sumstats <- function(dt, label) {
  stats <- list()
  for (var in c("cited_by_count", "cite_1y", "cite_3y", "cite_5y",
                "n_authors", "n_categories", "abstract_length",
                "position_pctile", "batch_size",
                "n_industry_cites", "n_industry_cites_3y",
                "has_industry_cite", "has_tier1_cite", "n_distinct_companies")) {
    if (var %in% names(dt)) {
      x <- dt[[var]]
      x <- x[!is.na(x)]
      # Skip variables that have no non-NA observations
      if (length(x) == 0) next
      stats[[var]] <- data.table(
        sample = label,
        variable = var,
        n = length(x),
        mean = mean(x),
        sd = sd(x),
        median = median(x),
        p25 = quantile(x, 0.25),
        p75 = quantile(x, 0.75)
      )
    }
  }
  rbindlist(stats)
}

sumstats <- rbind(
  compute_sumstats(full, "Full Sample"),
  compute_sumstats(df, "RDD Sample (±120 min)")
)

fwrite(sumstats, file.path(TAB_DIR, "summary_statistics.csv"))

# LaTeX output
sink(file.path(TAB_DIR, "tab1_summary.tex"))
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Summary Statistics}\n")
cat("\\label{tab:summary}\n")
cat("\\begin{adjustbox}{max width=\\textwidth}\n")
cat("\\begin{tabular}{lcccccc}\n")
cat("\\hline\\hline\n")
cat("& \\multicolumn{3}{c}{Matched Sample} & \\multicolumn{3}{c}{RDD Sample ($\\pm$120 min)} \\\\\n")
cat("\\cmidrule(lr){2-4} \\cmidrule(lr){5-7}\n")
cat("Variable & Mean & SD & Median & Mean & SD & Median \\\\\n")
cat("\\hline\n")

var_labels <- c(
  cited_by_count = "Total citations",
  cite_1y = "1-year citations",
  cite_3y = "3-year citations",
  cite_5y = "5-year citations",
  n_authors = "Number of authors",
  n_categories = "Number of arXiv categories",
  abstract_length = "Abstract length (chars)",
  position_pctile = "Position percentile",
  batch_size = "Announcement batch size",
  n_industry_cites = "Industry citations (total)",
  n_industry_cites_3y = "Industry citations (3-year)",
  has_industry_cite = "Has any industry citation",
  has_tier1_cite = "Has frontier lab citation",
  n_distinct_companies = "Distinct citing companies"
)

for (var in names(var_labels)) {
  s_full <- sumstats[sample == "Full Sample" & variable == var]
  s_rdd <- sumstats[sample == "RDD Sample (±120 min)" & variable == var]
  if (nrow(s_full) > 0 & nrow(s_rdd) > 0) {
    cat(sprintf("%s & %.2f & %.2f & %.2f & %.2f & %.2f & %.2f \\\\\n",
                var_labels[var],
                s_full$mean, s_full$sd, s_full$median,
                s_rdd$mean, s_rdd$sd, s_rdd$median))
  }
}

cat("\\hline\n")
n_full <- sumstats[sample == "Full Sample"]$n[1]
n_rdd <- sumstats[sample == "RDD Sample (±120 min)"]$n[1]
cat(sprintf("Observations & \\multicolumn{3}{c}{%s} & \\multicolumn{3}{c}{%s} \\\\\n",
            formatC(n_full, format = "d", big.mark = ","),
            formatC(n_rdd, format = "d", big.mark = ",")))
cat("\\hline\\hline\n")
cat("\\end{tabular}\n")
cat("\\end{adjustbox}\n")
cat("\\begin{minipage}{0.95\\textwidth}\n")
cat("\\footnotesize\n")
cat("\\textit{Notes:} Sample includes papers in cs.AI, cs.CL, cs.LG, stat.ML, and cs.CV submitted on weekdays between 2012 and 2020, matched to OpenAlex citation records. The RDD sample further restricts to papers submitted within $\\pm$120 minutes of the 14:00 ET daily cutoff. Citations are measured as of early 2025 via OpenAlex.\n")
cat("\\end{minipage}\n")
cat("\\end{table}\n")
sink()
cat("Saved tab1_summary.tex\n")

# ============================================================================
# Table 2: Main RDD Results
# ============================================================================

cat("=== Table 2: Main Results ===\n")

main_file <- file.path(TAB_DIR, "main_results.csv")
if (file.exists(main_file)) {
  main_df <- fread(main_file)

  sink(file.path(TAB_DIR, "tab2_main_results.tex"))
  cat("\\begin{table}[htbp]\n")
  cat("\\centering\n")
  cat("\\caption{The Visibility Premium: RDD Estimates at the arXiv Daily Cutoff}\n")
  cat("\\label{tab:main}\n")
  cat("\\begin{adjustbox}{max width=\\textwidth}\n")

  # Select key outcomes
  outcomes <- c("ln_cite_1y", "ln_cite_3y", "ln_cite_5y", "ln_cited_by_count")
  outcome_labels <- c("Log(1y cites+1)", "Log(3y cites+1)", "Log(5y cites+1)", "Log(total cites+1)")

  n_cols <- length(outcomes[outcomes %in% main_df$outcome])
  cat(sprintf("\\begin{tabular}{l%s}\n", paste(rep("c", n_cols), collapse = "")))
  cat("\\hline\\hline\n")
  cat(paste("&", paste(outcome_labels[outcomes %in% main_df$outcome], collapse = " & "), "\\\\\n"))

  # Column numbers
  col_nums <- paste(sprintf("(%d)", seq_len(n_cols)), collapse = " & ")
  cat(paste("&", col_nums, "\\\\\n"))
  cat("\\hline\n")

  # Coefficients
  coefs <- c()
  ses <- c()
  pvs <- c()
  bws <- c()
  ns <- c()

  for (out in outcomes) {
    row <- main_df[outcome == out]
    if (nrow(row) > 0) {
      coefs <- c(coefs, row$coef_robust)
      ses <- c(ses, row$se_robust)
      pvs <- c(pvs, row$p_robust)
      bws <- c(bws, row$bw_h)
      ns <- c(ns, row$n_eff_total)
    }
  }

  # Stars function
  stars <- function(p) {
    if (is.na(p)) return("")
    if (p < 0.01) return("$^{***}$")
    if (p < 0.05) return("$^{**}$")
    if (p < 0.10) return("$^{*}$")
    return("")
  }

  # Coefficient row
  cat(paste("After cutoff &",
            paste(sprintf("%.4f%s", coefs, sapply(pvs, stars)), collapse = " & "),
            "\\\\\n"))

  # SE row
  cat(paste("&",
            paste(sprintf("(%.4f)", ses), collapse = " & "),
            "\\\\\n"))

  cat("\\hline\n")

  # Bandwidth
  cat(paste("Bandwidth (min) &",
            paste(sprintf("%.1f", bws), collapse = " & "),
            "\\\\\n"))

  # N effective
  cat(paste("Eff. observations &",
            paste(formatC(round(ns), format = "d", big.mark = ","), collapse = " & "),
            "\\\\\n"))

  # Minimum detectable effect (MDE) at 80% power, 5% significance
  # MDE = (z_alpha/2 + z_beta) * sigma / sqrt(N_eff/2) ≈ 2.8 * SE
  # Using robust SEs already computed
  mdes <- 2.8 * ses
  cat(paste("Min. detectable effect &",
            paste(sprintf("%.2f", mdes), collapse = " & "),
            "\\\\\n"))

  cat("\\hline\\hline\n")
  cat("\\end{tabular}\n")
  cat("\\end{adjustbox}\n")
  cat("\\begin{minipage}{0.95\\textwidth}\n")
  cat("\\footnotesize\n")
  cat("\\textit{Notes:} Each column reports a separate local polynomial RDD estimate using \\texttt{rdrobust} with MSE-optimal bandwidth selection, triangular kernel, and robust bias-corrected inference. The running variable is minutes from the 14:00 ET daily cutoff. ``After cutoff'' indicates being submitted after the cutoff, which results in first-listing in the next day's announcement rather than last-listing in today's. Min.\\ detectable effect (MDE) computed at 80\\% power, 5\\% significance, using $\\text{MDE} = 2.8 \\times \\text{SE}$. Standard errors in parentheses. $^{***}p<0.01$, $^{**}p<0.05$, $^{*}p<0.10$.\n")
  cat("\\end{minipage}\n")
  cat("\\end{table}\n")
  sink()
  cat("Saved tab2_main_results.tex\n")
}

# ============================================================================
# Table 3: Robustness — Bandwidth Sensitivity & Donut
# ============================================================================

cat("=== Table 3: Robustness ===\n")

sink(file.path(TAB_DIR, "tab3_robustness.tex"))
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Robustness: Bandwidth Sensitivity and Donut RDD}\n")
cat("\\label{tab:robustness}\n")
cat("\\begin{adjustbox}{max width=\\textwidth}\n")
cat("\\begin{tabular}{lccccc}\n")
cat("\\hline\\hline\n")
cat("& Estimate & SE & $p$-value & Bandwidth & Eff. $N$ \\\\\n")
cat("\\hline\n")

cat("\\multicolumn{6}{l}{\\textit{Panel A: Bandwidth Sensitivity}} \\\\\n")

bw_file <- file.path(TAB_DIR, "bandwidth_sensitivity.csv")
if (file.exists(bw_file)) {
  bw <- fread(bw_file)
  for (i in seq_len(nrow(bw))) {
    label <- sprintf("%.0f\\%% of optimal", bw$multiplier[i] * 100)
    cat(sprintf("%s & %.4f%s & (%.4f) & %.3f & %.0f & %s \\\\\n",
                label,
                bw$coef[i], stars(bw$p_value[i]),
                bw$se[i], bw$p_value[i], bw$bandwidth[i],
                formatC(bw$n_eff[i], format = "d", big.mark = ",")))
  }
}

cat("\\hline\n")
cat("\\multicolumn{6}{l}{\\textit{Panel B: Donut RDD}} \\\\\n")

donut_file <- file.path(TAB_DIR, "donut_rdd.csv")
if (file.exists(donut_file)) {
  donut <- fread(donut_file)
  for (i in seq_len(nrow(donut))) {
    label <- sprintf("Exclude $\\pm$%d min", donut$donut_minutes[i])
    cat(sprintf("%s & %.4f%s & (%.4f) & %.3f & %.0f & %s \\\\\n",
                label,
                donut$coef[i], stars(donut$p_value[i]),
                donut$se[i], donut$p_value[i], donut$bw[i],
                formatC(donut$n_eff[i], format = "d", big.mark = ",")))
  }
}

cat("\\hline\\hline\n")
cat("\\end{tabular}\n")
cat("\\end{adjustbox}\n")
cat("\\begin{minipage}{0.95\\textwidth}\n")
cat("\\footnotesize\n")
cat("\\textit{Notes:} Panel A varies the bandwidth around the MSE-optimal choice. Panel B implements donut RDD, excluding papers submitted within the specified number of minutes of the 14:00 ET cutoff to address concerns about strategic timing. All specifications use local linear estimation with triangular kernel and robust bias-corrected inference. Dependent variable: log(3-year citations + 1). $^{***}p<0.01$, $^{**}p<0.05$, $^{*}p<0.10$.\n")
cat("\\end{minipage}\n")
cat("\\end{table}\n")
sink()
cat("Saved tab3_robustness.tex\n")

# ============================================================================
# Table 4: Balance Tests
# ============================================================================

cat("=== Table 4: Balance ===\n")

if (file.exists(file.path(TAB_DIR, "balance_tests.csv"))) {
  bal <- fread(file.path(TAB_DIR, "balance_tests.csv"))

  sink(file.path(TAB_DIR, "tab4_balance.tex"))
  cat("\\begin{table}[htbp]\n")
  cat("\\centering\n")
  cat("\\caption{Covariate Balance at the Cutoff}\n")
  cat("\\label{tab:balance}\n")
  cat("\\begin{tabular}{lccccr}\n")
  cat("\\hline\\hline\n")
  cat("Covariate & RDD Estimate & SE & $p$-value & Bandwidth & Eff. $N$ \\\\\n")
  cat("\\hline\n")

  for (i in seq_len(nrow(bal))) {
    vname <- gsub("_", " ", bal$variable[i])
    vname <- gsub("is ", "", vname)
    cat(sprintf("%s & %.4f & (%.4f) & %.3f & %.0f & %s \\\\\n",
                tools::toTitleCase(vname),
                bal$coef[i], bal$se[i], bal$p_value[i],
                bal$bw[i], formatC(bal$n_eff[i], format = "d", big.mark = ",")))
  }

  cat("\\hline\\hline\n")
  cat("\\end{tabular}\n")
  cat("\\begin{minipage}{0.95\\textwidth}\n")
  cat("\\footnotesize\n")
  cat("\\textit{Notes:} Each row reports a separate RDD estimate of the discontinuity in the covariate at the 14:00 ET cutoff, using \\texttt{rdrobust} with MSE-optimal bandwidth selection. Bandwidth and effective sample size (Eff. $N$) vary across covariates because each uses its own MSE-optimal bandwidth. Insignificant estimates indicate that pre-determined paper characteristics are smooth through the cutoff, supporting the local randomization assumption.\n")
  cat("\\end{minipage}\n")
  cat("\\end{table}\n")
  sink()
  cat("Saved tab4_balance.tex\n")
}

# ============================================================================
# Table 5: Heterogeneity by Category and Day
# ============================================================================

cat("=== Table 5: Heterogeneity ===\n")

cat_file <- file.path(TAB_DIR, "category_heterogeneity.csv")
if (file.exists(cat_file)) {
  cat_df <- fread(cat_file)

  # Exclude categories with fewer than 15 effective observations (unreliable estimates)
  cat_df <- cat_df[cat_df$n_eff >= 15, ]

  sink(file.path(TAB_DIR, "tab5_heterogeneity.tex"))
  cat("\\begin{table}[htbp]\n")
  cat("\\centering\n")
  cat("\\caption{Heterogeneity by arXiv Category}\n")
  cat("\\label{tab:heterogeneity}\n")
  cat("\\begin{tabular}{lccccc}\n")
  cat("\\hline\\hline\n")
  cat("Category & Estimate & SE & $p$-value & Eff. $N$ \\\\\n")
  cat("\\hline\n")

  for (i in seq_len(nrow(cat_df))) {
    cat(sprintf("%s & %.4f%s & (%.4f) & %.3f & %s \\\\\n",
                cat_df$category[i],
                cat_df$coef[i], stars(cat_df$p_value[i]),
                cat_df$se[i], cat_df$p_value[i],
                formatC(cat_df$n_eff[i], format = "d", big.mark = ",")))
  }

  cat("\\hline\\hline\n")
  cat("\\end{tabular}\n")
  cat("\\begin{minipage}{0.95\\textwidth}\n")
  cat("\\footnotesize\n")
  cat("\\textit{Notes:} Each row estimates the RDD separately for papers whose primary listing includes the specified category. Categories with fewer than 15 effective observations (cs.CL, cs.LG) are excluded due to unreliable estimates. Dependent variable: log(3-year citations + 1). $^{***}p<0.01$, $^{**}p<0.05$, $^{*}p<0.10$.\n")
  cat("\\end{minipage}\n")
  cat("\\end{table}\n")
  sink()
  cat("Saved tab5_heterogeneity.tex\n")
}

# ============================================================================
# Table 6: Industry Adoption — Full RDD Panel
# ============================================================================

cat("=== Table 6: Industry Adoption ===\n")

ind_file <- file.path(TAB_DIR, "industry_adoption_full.csv")
if (file.exists(ind_file)) {
  ind_df <- fread(ind_file)

  sink(file.path(TAB_DIR, "tab6_industry.tex"))
  cat("\\begin{table}[htbp]\n")
  cat("\\centering\n")
  cat("\\caption{Industry Adoption: RDD Estimates at the arXiv Daily Cutoff}\n")
  cat("\\label{tab:industry}\n")
  cat("\\begin{adjustbox}{max width=\\textwidth}\n")

  # Select key industry outcomes
  ind_outcomes <- c("has_industry_cite", "ln_industry_cites", "industry_cite_share",
                     "has_tier1_cite", "has_tier2_cite",
                     "ln_industry_cites_3y", "n_distinct_companies")
  ind_labels <- c("Any Industry\\\\Citation", "Log(Industry\\\\Cites+1)", "Industry\\\\Cite Share",
                   "Frontier Lab\\\\Citation", "Big Tech\\\\Citation",
                   "Log(3y Industry\\\\Cites+1)", "Distinct\\\\Companies")

  # Filter to available outcomes
  avail <- ind_outcomes %in% ind_df$outcome
  ind_outcomes <- ind_outcomes[avail]
  ind_labels <- ind_labels[avail]

  n_cols <- length(ind_outcomes)
  cat(sprintf("\\begin{tabular}{l%s}\n", paste(rep("c", n_cols), collapse = "")))
  cat("\\hline\\hline\n")
  cat(paste("&", paste(ind_labels, collapse = " & "), "\\\\\n"))

  col_nums <- paste(sprintf("(%d)", seq_len(n_cols)), collapse = " & ")
  cat(paste("&", col_nums, "\\\\\n"))
  cat("\\hline\n")

  # Extract values
  coefs <- c(); ses <- c(); pvs <- c(); bws <- c(); ns <- c(); means <- c()
  for (out in ind_outcomes) {
    row <- ind_df[outcome == out]
    if (nrow(row) > 0) {
      coefs <- c(coefs, row$coef_robust)
      ses <- c(ses, row$se_robust)
      pvs <- c(pvs, row$p_robust)
      bws <- c(bws, row$bw_h)
      ns <- c(ns, row$n_eff_total)
      means <- c(means, row$mean_y)
    } else {
      coefs <- c(coefs, NA); ses <- c(ses, NA); pvs <- c(pvs, NA)
      bws <- c(bws, NA); ns <- c(ns, NA); means <- c(means, NA)
    }
  }

  # Coefficient row
  cat(paste("After cutoff &",
            paste(ifelse(is.na(coefs), "---",
                         sprintf("%.4f%s", coefs, sapply(pvs, stars))), collapse = " & "),
            "\\\\\n"))

  # SE row
  cat(paste("&",
            paste(ifelse(is.na(ses), "", sprintf("(%.4f)", ses)), collapse = " & "),
            "\\\\\n"))

  cat("\\hline\n")

  # Control mean
  cat(paste("Control mean &",
            paste(ifelse(is.na(means), "---", sprintf("%.3f", means)), collapse = " & "),
            "\\\\\n"))

  # Bandwidth
  cat(paste("Bandwidth (min) &",
            paste(ifelse(is.na(bws), "---", sprintf("%.1f", bws)), collapse = " & "),
            "\\\\\n"))

  # N effective
  cat(paste("Eff.\\ observations &",
            paste(ifelse(is.na(ns), "---",
                         formatC(round(ns), format = "d", big.mark = ",")), collapse = " & "),
            "\\\\\n"))

  # MDE
  mdes <- 2.8 * ses
  cat(paste("MDE (80\\% power) &",
            paste(ifelse(is.na(mdes), "---", sprintf("%.3f", mdes)), collapse = " & "),
            "\\\\\n"))

  cat("\\hline\\hline\n")
  cat("\\end{tabular}\n")
  cat("\\end{adjustbox}\n")
  cat("\\begin{minipage}{0.95\\textwidth}\n")
  cat("\\footnotesize\n")
  cat("\\textit{Notes:} Each column reports a separate local polynomial RDD estimate. Industry citations are defined as citations from papers with at least one author affiliated with a major AI/tech company. ``Frontier Lab'' includes Google/DeepMind, OpenAI, Meta/FAIR, Anthropic, and xAI. ``Big Tech'' includes Microsoft, Amazon, Apple, and NVIDIA. Industry citation share is the fraction of total citations originating from industry. MDE computed at 80\\% power, 5\\% significance. $^{***}p<0.01$, $^{**}p<0.05$, $^{*}p<0.10$.\n")
  cat("\\end{minipage}\n")
  cat("\\end{table}\n")
  sink()
  cat("Saved tab6_industry.tex\n")
}

cat("\n=== All tables generated ===\n")
