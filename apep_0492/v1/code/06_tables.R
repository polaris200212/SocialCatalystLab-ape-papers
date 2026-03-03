# ==============================================================================
# 06_tables.R — All Tables
# apep_0492 v1
# ==============================================================================

source("00_packages.R")

# Prevent scientific notation in all output
options(scipen = 999)

data_dir <- "../data"
tab_dir <- "../tables"
dir.create(tab_dir, showWarnings = FALSE)

ppd <- fread(file.path(data_dir, "ppd_analysis.csv"))
results <- readRDS(file.path(data_dir, "main_results.rds"))

england_regions <- c("North East", "North West", "Yorkshire and The Humber",
                     "East Midlands", "West Midlands", "South West",
                     "East of England", "South East", "London")

htb_caps <- data.table(
  region = england_regions,
  cap = c(186100, 224400, 228100, 261900, 255600, 349000, 407400, 437600, 600000)
)

# ==============================================================================
# Table 1: Summary Statistics
# ==============================================================================

tab1 <- ppd[, .(
  N = .N,
  New_Builds = sum(new_build),
  Pct_New_Build = 100 * mean(new_build),
  Mean_Price = as.double(mean(price)),
  Median_Price = as.double(median(price)),
  SD_Price = as.double(sd(price)),
  Pct_Detached = 100 * mean(property_type == "D"),
  Pct_Flat = 100 * mean(property_type == "F"),
  Pct_Freehold = 100 * mean(duration == "F")
), by = region]

tab1 <- merge(tab1, htb_caps, by = "region")
setorder(tab1, cap)

# Format for LaTeX
tab1_tex <- tab1[, .(
  Region = region,
  `Cap (£)` = format(cap, big.mark = ","),
  N = format(N, big.mark = ","),
  `New Builds` = format(New_Builds, big.mark = ","),
  `% New` = sprintf("%.1f", Pct_New_Build),
  `Mean Price` = format(round(Mean_Price), big.mark = ","),
  `Med. Price` = format(round(Median_Price), big.mark = ","),
  `% Detached` = sprintf("%.1f", Pct_Detached),
  `% Flat` = sprintf("%.1f", Pct_Flat)
)]

# Save LaTeX table
sink(file.path(tab_dir, "tab1_summary.tex"))
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Summary Statistics: Land Registry Transactions by Region (2018--2023)}\n")
cat("\\label{tab:summary}\n")
cat("\\begin{adjustbox}{max width=\\textwidth}\n")
cat("\\begin{tabular}{lrrrrrrrr}\n")
cat("\\hline\\hline\n")
cat("Region & Cap (\\pounds) & N & New Builds & \\% New & Mean Price & Med. Price & \\% Detached & \\% Flat \\\\\n")
cat("\\hline\n")
for (i in seq_len(nrow(tab1_tex))) {
  row <- tab1_tex[i]
  cat(sprintf("%s & %s & %s & %s & %s & %s & %s & %s & %s \\\\\n",
              row$Region, row$`Cap (£)`, row$N, row$`New Builds`,
              row$`% New`, row$`Mean Price`, row$`Med. Price`,
              row$`% Detached`, row$`% Flat`))
}
cat("\\hline\\hline\n")
cat("\\end{tabular}\n")
cat("\\end{adjustbox}\n")
cat("\\begin{minipage}{\\textwidth}\n")
cat("\\footnotesize \\textit{Notes:} Standard residential transactions (Category A) in England. ")
cat("Regional price caps took effect April 1, 2021. Source: HM Land Registry Price Paid Data.\n")
cat("\\end{minipage}\n")
cat("\\end{table}\n")
sink()
cat("Table 1 saved.\n")

# ==============================================================================
# Table 2: Main Bunching Results
# ==============================================================================

br_dt <- rbindlist(lapply(results$bunching, as.data.table))

# Add placebo results
if (length(results$placebo_resale) > 0) {
  pl_dt <- rbindlist(lapply(results$placebo_resale, as.data.table))
  br_dt <- merge(br_dt, pl_dt[, .(region, placebo_b = bunching_ratio, placebo_se = se)],
                 by = "region", all.x = TRUE)
}

setorder(br_dt, cap)

sink(file.path(tab_dir, "tab2_bunching.tex"))
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Bunching Estimates at Regional Help to Buy Price Caps}\n")
cat("\\label{tab:bunching}\n")
cat("\\begin{adjustbox}{max width=\\textwidth}\n")
cat("\\begin{tabular}{lrrrrrrr}\n")
cat("\\hline\\hline\n")
cat("Region & Cap (\\pounds) & N & Bunching Ratio & SE & Placebo $b$ & Placebo SE & Excess Mass \\\\\n")
cat("\\hline\n")
cat("\\multicolumn{8}{l}{\\textit{Panel A: New Builds (Post-Reform)}} \\\\\n")
for (i in seq_len(nrow(br_dt))) {
  row <- br_dt[i]
  stars <- ""
  if (!is.na(row$se) && row$se > 0) {
    z <- abs(row$bunching_ratio / row$se)
    if (z > 2.576) stars <- "***"
    else if (z > 1.96) stars <- "**"
    else if (z > 1.645) stars <- "*"
  }
  placebo_str <- ifelse(!is.na(row$placebo_b), sprintf("%.3f", row$placebo_b), "---")
  placebo_se_str <- ifelse(!is.na(row$placebo_se), sprintf("(%.3f)", row$placebo_se), "---")
  cat(sprintf("%s & %s & %s & %.3f%s & (%.3f) & %s & %s & %.0f \\\\\n",
              row$region, format(row$cap, big.mark = ","),
              format(row$n, big.mark = ","),
              row$bunching_ratio, stars, row$se,
              placebo_str, placebo_se_str, row$excess_below))
}
cat("\\hline\\hline\n")
cat("\\end{tabular}\n")
cat("\\end{adjustbox}\n")
cat("\\begin{minipage}{\\textwidth}\n")
cat("\\footnotesize \\textit{Notes:} Bunching ratio $b$ measures excess mass below the price cap relative to ")
cat("the polynomial counterfactual. Bootstrapped standard errors (500 iterations) in parentheses. ")
cat("Placebo $b$ is the bunching ratio for second-hand properties at the same cap (no bunching expected). ")
cat("$^{***}$, $^{**}$, $^{*}$ denote significance at the 1\\%, 5\\%, and 10\\% levels.\n")
cat("\\end{minipage}\n")
cat("\\end{table}\n")
sink()
cat("Table 2 saved.\n")

# ==============================================================================
# Table 3: Spatial RDD Results
# ==============================================================================

if (length(results$rdd) > 0) {
  rdd_dt <- rbindlist(lapply(results$rdd, as.data.table))

  sink(file.path(tab_dir, "tab3_spatial_rdd.tex"))
  cat("\\begin{table}[htbp]\n")
  cat("\\centering\n")
  cat("\\caption{Spatial RDD at Regional Borders: New-Build Prices}\n")
  cat("\\label{tab:rdd}\n")
  cat("\\begin{tabular}{lrrrrr}\n")
  cat("\\hline\\hline\n")
  cat("Border & N & RD Estimate (\\pounds) & SE & $p$-value & Bandwidth (m) \\\\\n")
  cat("\\hline\n")
  for (i in seq_len(nrow(rdd_dt))) {
    row <- rdd_dt[i]
    stars <- ""
    if (row$rd_pvalue < 0.01) stars <- "***"
    else if (row$rd_pvalue < 0.05) stars <- "**"
    else if (row$rd_pvalue < 0.1) stars <- "*"
    cat(sprintf("%s & %s & %s%s & (%s) & %.3f & %s \\\\\n",
                row$border, format(row$n, big.mark = ","),
                format(round(row$rd_estimate), big.mark = ","), stars,
                format(round(row$rd_se), big.mark = ","),
                row$rd_pvalue,
                format(round(row$bandwidth), big.mark = ",")))
  }
  cat("\\hline\n")
  cat("\\multicolumn{6}{l}{\\textit{Density test $p$-values (McCrary):}} \\\\\n")
  for (i in seq_len(nrow(rdd_dt))) {
    row <- rdd_dt[i]
    cat(sprintf("%s: $p$ = %.3f \\\\\n", row$border, row$density_pvalue))
  }
  cat("\\hline\\hline\n")
  cat("\\end{tabular}\n")
  cat("\\begin{minipage}{0.85\\textwidth}\n")
  cat("\\footnotesize \\textit{Notes:} Local polynomial RDD estimates using triangular kernel ")
  cat("and MSE-optimal bandwidth (Calonico, Cattaneo \\& Titiunik, 2014). ")
  cat("Running variable is signed distance to the nearest regional border (meters). ")
  cat("Positive = higher-cap side. Post-reform new builds only.\n")
  cat("\\end{minipage}\n")
  cat("\\end{table}\n")
  sink()
  cat("Table 3 saved.\n")
}

# ==============================================================================
# Table 4: Robustness — Bunching Sensitivity
# ==============================================================================

robustness <- readRDS(file.path(data_dir, "robustness_results.rds"))

if (!is.null(robustness$bin_width)) {
  bw_wide <- dcast(robustness$bin_width, region ~ bin_width,
                   value.var = "bunching_ratio")

  sink(file.path(tab_dir, "tab4_robustness.tex"))
  cat("\\begin{table}[htbp]\n")
  cat("\\centering\n")
  cat("\\caption{Robustness: Bunching Ratio Sensitivity}\n")
  cat("\\label{tab:robustness}\n")
  cat("\\begin{tabular}{lrrr}\n")
  cat("\\hline\\hline\n")
  cat("Region & \\pounds500 bins & \\pounds1,000 bins & \\pounds2,000 bins \\\\\n")
  cat("\\hline\n")
  for (i in seq_len(nrow(bw_wide))) {
    row <- bw_wide[i]
    cat(sprintf("%s & %.3f & %.3f & %.3f \\\\\n",
                row$region,
                ifelse(is.na(row$`500`), NA, row$`500`),
                ifelse(is.na(row$`1000`), NA, row$`1000`),
                ifelse(is.na(row$`2000`), NA, row$`2000`)))
  }
  cat("\\hline\\hline\n")
  cat("\\end{tabular}\n")
  cat("\\begin{minipage}{0.7\\textwidth}\n")
  cat("\\footnotesize \\textit{Notes:} Bunching ratios for new-build transactions (post-reform) ")
  cat("using alternative bin widths. Baseline specification: \\pounds1,000 bins, ")
  cat("7th-degree polynomial, \\pounds5,000 exclusion window.\n")
  cat("\\end{minipage}\n")
  cat("\\end{table}\n")
  sink()
  cat("Table 4 saved.\n")
}

# ==============================================================================
# Table 5: Difference-in-Bunching at £600K
# ==============================================================================

if (length(results$dib) > 0) {
  dib_dt <- rbindlist(lapply(results$dib, as.data.table))
  dib_dt <- merge(dib_dt, htb_caps, by = "region")
  setorder(dib_dt, cap)

  # Compute triple-difference relative to London
  london_diff <- dib_dt[region == "London", diff]
  london_diff_se <- dib_dt[region == "London", diff_se]
  dib_dt[, triple_diff := diff - london_diff]
  # SE of triple-diff: sqrt(SE_region^2 + SE_London^2) assuming independence
  dib_dt[, triple_se := sqrt(diff_se^2 + london_diff_se^2)]
  dib_dt[region == "London", triple_diff := NA_real_]
  dib_dt[region == "London", triple_se := NA_real_]

  sink(file.path(tab_dir, "tab5_dib.tex"))
  cat("\\begin{table}[htbp]\n")
  cat("\\centering\n")
  cat("\\caption{Difference-in-Bunching at \\pounds600,000}\n")
  cat("\\label{tab:dib}\n")
  cat("\\begin{adjustbox}{max width=\\textwidth}\n")
  cat("\\begin{tabular}{lrrrrrrrrr}\n")
  cat("\\hline\\hline\n")
  cat("Region & Cap (\\pounds) & Pre $b$ & SE & Post $b$ & SE & $\\Delta b$ & SE & Triple-Diff & SE \\\\\n")
  cat("\\hline\n")
  for (i in seq_len(nrow(dib_dt))) {
    row <- dib_dt[i]
    pre_se_str <- sprintf("(%.3f)", row$pre_se)
    post_se_str <- sprintf("(%.3f)", row$post_se)
    diff_se_str <- sprintf("(%.3f)", row$diff_se)
    if (!is.na(row$triple_diff)) {
      triple_str <- sprintf("%.3f", row$triple_diff)
      triple_se_str <- sprintf("(%.3f)", row$triple_se)
    } else {
      triple_str <- "---"
      triple_se_str <- "---"
    }
    cat(sprintf("%s & %s & %.3f & %s & %.3f & %s & %.3f & %s & %s & %s \\\\\n",
                row$region, format(row$cap, big.mark = ","),
                row$pre_bunching, pre_se_str,
                row$post_bunching, post_se_str,
                row$diff, diff_se_str,
                triple_str, triple_se_str))
  }
  cat("\\hline\\hline\n")
  cat("\\end{tabular}\n")
  cat("\\end{adjustbox}\n")
  cat("\\begin{minipage}{0.95\\textwidth}\n")
  cat("\\footnotesize \\textit{Notes:} Bunching ratios at \\pounds600,000 before (January 2018--March 2021, ")
  cat("excluding March--June 2020) and after (April 2021--March 2023) the regional cap reform. ")
  cat("Bootstrapped standard errors (500 iterations) in parentheses. ")
  cat("$\\Delta b$ = Post $-$ Pre. ")
  cat("Triple-Diff = $\\Delta b_{\\text{region}} - \\Delta b_{\\text{London}}$; London serves as control ")
  cat("(cap unchanged at \\pounds600,000). SE for triple-difference computed assuming independence of regional ")
  cat("and London bootstraps.\n")
  cat("\\end{minipage}\n")
  cat("\\end{table}\n")
  sink()
  cat("Table 5 saved.\n")
}

cat("\nAll tables generated.\n")
