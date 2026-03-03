###############################################################################
# 06_tables.R — Generate all tables
# Paper: Does Visibility Delay Frontier AI? (apep_0490 v3)
###############################################################################

source("00_packages.R")

cat("=== Loading data ===\n")
df <- fread(file.path(DATA_DIR, "rdd_sample.csv"))
full <- fread(file.path(DATA_DIR, "full_sample.csv"))

stars <- function(p) {
  if (is.na(p)) return("")
  if (p < 0.01) return("$^{***}$")
  if (p < 0.05) return("$^{**}$")
  if (p < 0.10) return("$^{*}$")
  return("")
}

# ============================================================================
# Table 1: Summary Statistics
# ============================================================================

cat("=== Table 1: Summary Statistics ===\n")

compute_sumstats <- function(dt, label) {
  stats <- list()
  vars_to_check <- c("cited_by_count", "cite_1y", "cite_3y", "cite_5y",
                      "n_authors", "n_categories", "abstract_length",
                      "position_pctile", "batch_size",
                      "n_industry_cites", "n_frontier_cites",
                      "has_industry_cite", "has_frontier_cite",
                      "adopted_12m", "adopted_18m",
                      "frontier_adopted_12m", "frontier_adopted_18m",
                      "n_frontier_labs_18m", "n_distinct_companies",
                      "adoption_lag_days", "frontier_lag_days")
  for (var in vars_to_check) {
    if (var %in% names(dt)) {
      x <- dt[[var]]
      x <- x[!is.na(x)]
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
  compute_sumstats(df, "RDD Sample")
)
fwrite(sumstats, file.path(TAB_DIR, "summary_statistics.csv"))

# LaTeX table
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
cat("\\multicolumn{7}{l}{\\textit{Panel A: Paper Characteristics}} \\\\\n")

var_labels_a <- c(
  n_authors = "Number of authors",
  n_categories = "arXiv categories",
  abstract_length = "Abstract length (chars)",
  position_pctile = "Position percentile",
  batch_size = "Batch size"
)

for (var in names(var_labels_a)) {
  s_full <- sumstats[sample == "Full Sample" & variable == var]
  s_rdd <- sumstats[sample == "RDD Sample" & variable == var]
  if (nrow(s_full) > 0 & nrow(s_rdd) > 0) {
    cat(sprintf("%s & %.2f & %.2f & %.2f & %.2f & %.2f & %.2f \\\\\n",
                var_labels_a[var],
                s_full$mean, s_full$sd, s_full$median,
                s_rdd$mean, s_rdd$sd, s_rdd$median))
  }
}

cat("\\hline\n")
cat("\\multicolumn{7}{l}{\\textit{Panel B: Citation Outcomes}} \\\\\n")

var_labels_b <- c(
  cited_by_count = "Total citations",
  cite_1y = "1-year citations",
  cite_3y = "3-year citations",
  cite_5y = "5-year citations"
)

for (var in names(var_labels_b)) {
  s_full <- sumstats[sample == "Full Sample" & variable == var]
  s_rdd <- sumstats[sample == "RDD Sample" & variable == var]
  if (nrow(s_full) > 0 & nrow(s_rdd) > 0) {
    cat(sprintf("%s & %.2f & %.2f & %.2f & %.2f & %.2f & %.2f \\\\\n",
                var_labels_b[var],
                s_full$mean, s_full$sd, s_full$median,
                s_rdd$mean, s_rdd$sd, s_rdd$median))
  }
}

cat("\\hline\n")
cat("\\multicolumn{7}{l}{\\textit{Panel C: Frontier Lab Adoption}} \\\\\n")

var_labels_c <- c(
  has_frontier_cite = "Any frontier lab citation",
  frontier_adopted_12m = "Adopted by frontier (12m)",
  frontier_adopted_18m = "Adopted by frontier (18m)",
  n_frontier_cites = "Frontier citations (total)",
  n_frontier_labs_18m = "Distinct frontier labs (18m)",
  has_industry_cite = "Any industry citation",
  adopted_18m = "Adopted by industry (18m)",
  n_industry_cites = "Industry citations (total)",
  n_distinct_companies = "Distinct citing companies"
)

for (var in names(var_labels_c)) {
  s_full <- sumstats[sample == "Full Sample" & variable == var]
  s_rdd <- sumstats[sample == "RDD Sample" & variable == var]
  if (nrow(s_full) > 0 & nrow(s_rdd) > 0) {
    cat(sprintf("%s & %.3f & %.3f & %.3f & %.3f & %.3f & %.3f \\\\\n",
                var_labels_c[var],
                s_full$mean, s_full$sd, s_full$median,
                s_rdd$mean, s_rdd$sd, s_rdd$median))
  }
}

cat("\\hline\n")
n_full <- sumstats[sample == "Full Sample"]$n[1]
n_rdd <- sumstats[sample == "RDD Sample"]$n[1]
cat(sprintf("Observations & \\multicolumn{3}{c}{%s} & \\multicolumn{3}{c}{%s} \\\\\n",
            formatC(n_full, format = "d", big.mark = ","),
            formatC(n_rdd, format = "d", big.mark = ",")))
cat("\\hline\\hline\n")
cat("\\end{tabular}\n")
cat("\\end{adjustbox}\n")
cat("\\begin{minipage}{0.95\\textwidth}\n")
cat("\\footnotesize\n")
cat(sprintf("\\textit{Notes:} Sample includes AI/ML papers (%s) submitted on weekdays between %d and %d, matched to Semantic Scholar and OpenAlex citation records. The RDD sample restricts to papers submitted within $\\pm$120 minutes of the 14:00 ET daily cutoff. ``Frontier lab'' includes Google/DeepMind, OpenAI, Meta/FAIR, Anthropic, and xAI. Adoption within $N$ months means at least one citation from a frontier (or industry) lab within that horizon. Citations measured as of early 2026.\n",
            paste(AI_CATEGORIES, collapse = ", "), YEAR_START, YEAR_END))
cat("\\end{minipage}\n")
cat("\\end{table}\n")
sink()
cat("Saved tab1_summary.tex\n")

# ============================================================================
# Table 2: Main Results — Adoption Outcomes (PRIMARY)
# ============================================================================

cat("=== Table 2: Adoption Results ===\n")

adopt_file <- file.path(TAB_DIR, "adoption_results.csv")
if (file.exists(adopt_file)) {
  adopt_df <- fread(adopt_file)

  sink(file.path(TAB_DIR, "tab2_adoption.tex"))
  cat("\\begin{table}[htbp]\n")
  cat("\\centering\n")
  cat("\\caption{Does Visibility Accelerate Frontier Lab Adoption? RDD Estimates}\n")
  cat("\\label{tab:adoption}\n")
  cat("\\begin{adjustbox}{max width=\\textwidth}\n")

  outcomes <- c("frontier_adopted_18m", "has_frontier_cite", "n_frontier_labs_18m",
                "frontier_cite_share", "adopted_18m", "has_industry_cite")
  outcome_labels <- c("Frontier\\\\Adopt (18m)", "Any Frontier\\\\Citation",
                       "\\# Frontier\\\\Labs (18m)", "Frontier\\\\Cite Share",
                       "Industry\\\\Adopt (18m)", "Any Industry\\\\Citation")

  avail <- outcomes %in% adopt_df$outcome
  outcomes <- outcomes[avail]
  outcome_labels <- outcome_labels[avail]

  n_cols <- length(outcomes)
  cat(sprintf("\\begin{tabular}{l%s}\n", paste(rep("c", n_cols), collapse = "")))
  cat("\\hline\\hline\n")
  cat(paste("&", paste(outcome_labels, collapse = " & "), "\\\\\n"))
  col_nums <- paste(sprintf("(%d)", seq_len(n_cols)), collapse = " & ")
  cat(paste("&", col_nums, "\\\\\n"))
  cat("\\hline\n")

  coefs <- ses <- pvs <- bws <- ns <- means <- c()
  for (out in outcomes) {
    row <- adopt_df[outcome == out]
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

  cat(paste("After cutoff &",
            paste(ifelse(is.na(coefs), "---",
                         sprintf("%.4f%s", coefs, sapply(pvs, stars))), collapse = " & "),
            "\\\\\n"))
  cat(paste("&",
            paste(ifelse(is.na(ses), "", sprintf("(%.4f)", ses)), collapse = " & "),
            "\\\\\n"))

  cat("\\hline\n")

  cat(paste("Control mean &",
            paste(ifelse(is.na(means), "---", sprintf("%.3f", means)), collapse = " & "),
            "\\\\\n"))
  cat(paste("Bandwidth (min) &",
            paste(ifelse(is.na(bws), "---", sprintf("%.1f", bws)), collapse = " & "),
            "\\\\\n"))
  cat(paste("Eff.\\ observations &",
            paste(ifelse(is.na(ns), "---",
                         formatC(round(ns), format = "d", big.mark = ",")), collapse = " & "),
            "\\\\\n"))
  mdes <- 2.8 * ses
  cat(paste("MDE (80\\% power) &",
            paste(ifelse(is.na(mdes), "---", sprintf("%.4f", mdes)), collapse = " & "),
            "\\\\\n"))

  cat("\\hline\\hline\n")
  cat("\\end{tabular}\n")
  cat("\\end{adjustbox}\n")
  cat("\\begin{minipage}{0.95\\textwidth}\n")
  cat("\\footnotesize\n")
  cat("\\textit{Notes:} Each column reports a separate local polynomial RDD estimate using \\texttt{rdrobust} with MSE-optimal bandwidth selection, triangular kernel, and robust bias-corrected inference. The running variable is minutes from the 14:00~ET daily cutoff. ``After cutoff'' indicates submission after the cutoff, resulting in first-listing in the next announcement. ``Frontier'' labs: Google/DeepMind, OpenAI, Meta/FAIR, Anthropic, xAI. MDE at 80\\% power, 5\\% significance. $^{***}p<0.01$, $^{**}p<0.05$, $^{*}p<0.10$.\n")
  cat("\\end{minipage}\n")
  cat("\\end{table}\n")
  sink()
  cat("Saved tab2_adoption.tex\n")
}

# ============================================================================
# Table 3: Citation Results (SECONDARY)
# ============================================================================

cat("=== Table 3: Citation Results ===\n")

cite_file <- file.path(TAB_DIR, "citation_results.csv")
if (file.exists(cite_file)) {
  cite_df <- fread(cite_file)

  sink(file.path(TAB_DIR, "tab3_citations.tex"))
  cat("\\begin{table}[htbp]\n")
  cat("\\centering\n")
  cat("\\caption{General Citations: RDD Estimates at the arXiv Daily Cutoff}\n")
  cat("\\label{tab:citations}\n")
  cat("\\begin{adjustbox}{max width=\\textwidth}\n")

  outcomes <- c("ln_cite_1y", "ln_cite_3y", "ln_cite_5y", "ln_cited_by_count")
  outcome_labels <- c("Log(1y+1)", "Log(3y+1)", "Log(5y+1)", "Log(total+1)")

  avail <- outcomes %in% cite_df$outcome
  outcomes <- outcomes[avail]
  outcome_labels <- outcome_labels[avail]
  n_cols <- length(outcomes)

  cat(sprintf("\\begin{tabular}{l%s}\n", paste(rep("c", n_cols), collapse = "")))
  cat("\\hline\\hline\n")
  cat(paste("&", paste(outcome_labels, collapse = " & "), "\\\\\n"))
  col_nums <- paste(sprintf("(%d)", seq_len(n_cols)), collapse = " & ")
  cat(paste("&", col_nums, "\\\\\n"))
  cat("\\hline\n")

  coefs <- ses <- pvs <- bws <- ns <- c()
  for (out in outcomes) {
    row <- cite_df[outcome == out]
    if (nrow(row) > 0) {
      coefs <- c(coefs, row$coef_robust)
      ses <- c(ses, row$se_robust)
      pvs <- c(pvs, row$p_robust)
      bws <- c(bws, row$bw_h)
      ns <- c(ns, row$n_eff_total)
    }
  }

  cat(paste("After cutoff &",
            paste(sprintf("%.4f%s", coefs, sapply(pvs, stars)), collapse = " & "),
            "\\\\\n"))
  cat(paste("&",
            paste(sprintf("(%.4f)", ses), collapse = " & "),
            "\\\\\n"))
  cat("\\hline\n")
  cat(paste("Bandwidth (min) &",
            paste(sprintf("%.1f", bws), collapse = " & "),
            "\\\\\n"))
  cat(paste("Eff.\\ observations &",
            paste(formatC(round(ns), format = "d", big.mark = ","), collapse = " & "),
            "\\\\\n"))
  mdes <- 2.8 * ses
  cat(paste("MDE (80\\% power) &",
            paste(sprintf("%.2f", mdes), collapse = " & "),
            "\\\\\n"))

  cat("\\hline\\hline\n")
  cat("\\end{tabular}\n")
  cat("\\end{adjustbox}\n")
  cat("\\begin{minipage}{0.95\\textwidth}\n")
  cat("\\footnotesize\n")
  cat("\\textit{Notes:} Each column reports a separate local polynomial RDD estimate. Dependent variable is log(citations$+$1) measured over the specified horizon. All specifications use MSE-optimal bandwidth, triangular kernel, and robust bias-corrected inference. $^{***}p<0.01$, $^{**}p<0.05$, $^{*}p<0.10$.\n")
  cat("\\end{minipage}\n")
  cat("\\end{table}\n")
  sink()
  cat("Saved tab3_citations.tex\n")
}

# ============================================================================
# Table 4: Balance Tests
# ============================================================================

cat("=== Table 4: Balance ===\n")

if (file.exists(file.path(TAB_DIR, "balance_tests.csv"))) {
  bal <- fread(file.path(TAB_DIR, "balance_tests.csv"))
  bal <- bal[!grepl("^dow_", variable)]  # Exclude DoW for main table

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
  cat("\\textit{Notes:} Each row reports a separate RDD estimate of the discontinuity in the covariate at the 14:00~ET cutoff, using \\texttt{rdrobust} with MSE-optimal bandwidth selection. Insignificant estimates indicate that pre-determined characteristics are smooth through the cutoff, supporting the local randomization assumption.\n")
  cat("\\end{minipage}\n")
  cat("\\end{table}\n")
  sink()
  cat("Saved tab4_balance.tex\n")
}

# ============================================================================
# Table 5: Robustness — Bandwidth & Donut
# ============================================================================

cat("=== Table 5: Robustness ===\n")

sink(file.path(TAB_DIR, "tab5_robustness.tex"))
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Robustness: Bandwidth Sensitivity and Donut RDD}\n")
cat("\\label{tab:robustness}\n")
cat("\\begin{adjustbox}{max width=\\textwidth}\n")
cat("\\begin{tabular}{lccccc}\n")
cat("\\hline\\hline\n")
cat("& Estimate & SE & $p$-value & Bandwidth & Eff. $N$ \\\\\n")
cat("\\hline\n")

# Use adoption primary for robustness table
ADOPT_PRIMARY <- "frontier_adopted_18m"

cat("\\multicolumn{6}{l}{\\textit{Panel A: Bandwidth Sensitivity}} \\\\\n")
bw_file <- file.path(TAB_DIR, "bandwidth_sensitivity.csv")
if (file.exists(bw_file)) {
  bw <- fread(bw_file)
  bw_sub <- bw[outcome == ADOPT_PRIMARY]
  if (nrow(bw_sub) == 0) bw_sub <- bw[1:min(6, nrow(bw))]

  for (i in seq_len(nrow(bw_sub))) {
    label <- sprintf("%.0f\\%% of optimal", bw_sub$multiplier[i] * 100)
    cat(sprintf("%s & %.4f%s & (%.4f) & %.3f & %.0f & %s \\\\\n",
                label,
                bw_sub$coef[i], stars(bw_sub$p_value[i]),
                bw_sub$se[i], bw_sub$p_value[i], bw_sub$bandwidth[i],
                formatC(bw_sub$n_eff[i], format = "d", big.mark = ",")))
  }
}

cat("\\hline\n")
cat("\\multicolumn{6}{l}{\\textit{Panel B: Donut RDD}} \\\\\n")
donut_file <- file.path(TAB_DIR, "donut_rdd.csv")
if (file.exists(donut_file)) {
  donut <- fread(donut_file)
  d_sub <- donut[outcome == ADOPT_PRIMARY]
  if (nrow(d_sub) == 0) d_sub <- donut[1:min(4, nrow(donut))]

  for (i in seq_len(nrow(d_sub))) {
    label <- sprintf("Exclude $\\pm$%d min", d_sub$donut_minutes[i])
    cat(sprintf("%s & %.4f%s & (%.4f) & %.3f & %.0f & %s \\\\\n",
                label,
                d_sub$coef[i], stars(d_sub$p_value[i]),
                d_sub$se[i], d_sub$p_value[i], d_sub$bw[i],
                formatC(d_sub$n_eff[i], format = "d", big.mark = ",")))
  }
}

cat("\\hline\n")
cat("\\multicolumn{6}{l}{\\textit{Panel C: Randomization Inference}} \\\\\n")
ri_file <- file.path(TAB_DIR, "randomization_inference.csv")
if (file.exists(ri_file)) {
  ri <- fread(ri_file)
  for (i in seq_len(nrow(ri))) {
    cat(sprintf("%s & %.4f & --- & %.3f & --- & %d perms \\\\\n",
                ri$outcome[i], ri$actual_coef[i], ri$ri_p_value[i],
                ri$n_permutations[i]))
  }
}

cat("\\hline\\hline\n")
cat("\\end{tabular}\n")
cat("\\end{adjustbox}\n")
cat("\\begin{minipage}{0.95\\textwidth}\n")
cat("\\footnotesize\n")
cat("\\textit{Notes:} Panel A varies the bandwidth around the MSE-optimal choice. Panel B implements donut RDD, excluding papers submitted within the specified number of minutes of the cutoff. Panel C reports randomization inference $p$-values from permuting the outcome within the bandwidth. All specifications use local linear estimation with triangular kernel. $^{***}p<0.01$, $^{**}p<0.05$, $^{*}p<0.10$.\n")
cat("\\end{minipage}\n")
cat("\\end{table}\n")
sink()
cat("Saved tab5_robustness.tex\n")

# ============================================================================
# Table 6: Cox Proportional Hazard Results
# ============================================================================

cat("=== Table 6: Cox PH ===\n")

cox_ind_file <- file.path(TAB_DIR, "cox_industry.csv")
cox_fr_file <- file.path(TAB_DIR, "cox_frontier.csv")

if (file.exists(cox_ind_file) || file.exists(cox_fr_file)) {
  sink(file.path(TAB_DIR, "tab6_cox.tex"))
  cat("\\begin{table}[htbp]\n")
  cat("\\centering\n")
  cat("\\caption{Adoption Speed: Cox Proportional Hazard Estimates}\n")
  cat("\\label{tab:cox}\n")
  cat("\\begin{tabular}{lcc}\n")
  cat("\\hline\\hline\n")
  cat("& Industry Adoption & Frontier Adoption \\\\\n")
  cat("\\hline\n")

  if (file.exists(cox_ind_file)) {
    cox_ind <- fread(cox_ind_file)
    cat(sprintf("After cutoff (HR) & %.3f%s & ",
                cox_ind$hr_after_cutoff, stars(cox_ind$p_value)))
  } else {
    cat("After cutoff (HR) & --- & ")
  }

  if (file.exists(cox_fr_file)) {
    cox_fr <- fread(cox_fr_file)
    cat(sprintf("%.3f%s \\\\\n", cox_fr$hr_after_cutoff, stars(cox_fr$p_value)))
    cat(sprintf("& (%.3f) & (%.3f) \\\\\n",
                if (file.exists(cox_ind_file)) cox_ind$se else NA,
                cox_fr$se))
  } else {
    cat("--- \\\\\n")
  }

  cat("\\hline\n")

  if (file.exists(cox_ind_file)) {
    cat(sprintf("$N$ & %s & ", formatC(cox_ind$n, format = "d", big.mark = ",")))
  } else {
    cat("$N$ & --- & ")
  }
  if (file.exists(cox_fr_file)) {
    cat(sprintf("%s \\\\\n", formatC(cox_fr$n, format = "d", big.mark = ",")))
    cat(sprintf("Events & %s & %s \\\\\n",
                if (file.exists(cox_ind_file)) formatC(cox_ind$n_events, format = "d", big.mark = ",") else "---",
                formatC(cox_fr$n_events, format = "d", big.mark = ",")))
  } else {
    cat("--- \\\\\n")
  }

  cat("\\hline\\hline\n")
  cat("\\end{tabular}\n")
  cat("\\begin{minipage}{0.95\\textwidth}\n")
  cat("\\footnotesize\n")
  cat("\\textit{Notes:} Cox proportional hazard model estimated within the MSE-optimal RDD bandwidth. The dependent variable is time-to-first-citation by an industry (or frontier) lab, right-censored at 3 years. HR $>$ 1 indicates faster adoption for papers submitted after the cutoff (i.e., listed first). The model includes the running variable and its interaction with the treatment indicator. Standard errors from the Cox partial likelihood in parentheses. $^{***}p<0.01$, $^{**}p<0.05$, $^{*}p<0.10$.\n")
  cat("\\end{minipage}\n")
  cat("\\end{table}\n")
  sink()
  cat("Saved tab6_cox.tex\n")
}

# ============================================================================
# Table 7: Heterogeneity by Category
# ============================================================================

cat("=== Table 7: Heterogeneity ===\n")

cat_file <- file.path(TAB_DIR, "category_heterogeneity.csv")
if (file.exists(cat_file)) {
  cat_df <- fread(cat_file)

  sink(file.path(TAB_DIR, "tab7_heterogeneity.tex"))
  cat("\\begin{table}[htbp]\n")
  cat("\\centering\n")
  cat("\\caption{Heterogeneity by arXiv Category}\n")
  cat("\\label{tab:heterogeneity}\n")
  cat("\\begin{tabular}{lcccc}\n")
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
  cat(sprintf("\\textit{Notes:} Each row estimates the RDD separately for papers whose listing includes the specified category. Dependent variable: %s. $^{***}p<0.01$, $^{**}p<0.05$, $^{*}p<0.10$.\n", unique(cat_df$outcome)[1]))
  cat("\\end{minipage}\n")
  cat("\\end{table}\n")
  sink()
  cat("Saved tab7_heterogeneity.tex\n")
}

cat("\n=== All tables generated ===\n")
