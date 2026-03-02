###############################################################################
# 06_tables.R
# Generate all LaTeX tables for the paper
# APEP-0445
###############################################################################

source(file.path(dirname(sys.frame(1)$ofile %||% "."), "00_packages.R"))

rdd_sample <- readRDS(file.path(data_dir, "rdd_sample.rds"))
cat("Data loaded for tables\n\n")


###############################################################################
# Table 1: Summary Statistics
###############################################################################
cat("Table 1: Summary Statistics\n")

# Within optimal bandwidth
main_results <- readRDS(file.path(data_dir, "main_rdd_results.rds"))
opt_bw <- ifelse(!is.null(main_results[["Delta Total Emp"]]),
                 main_results[["Delta Total Emp"]]$bandwidth, 10)

within_bw <- rdd_sample %>%
  filter(abs(pov_centered) <= opt_bw)

below <- within_bw %>% filter(!eligible_poverty)
above <- within_bw %>% filter(eligible_poverty)

make_stats <- function(df, label) {
  data.frame(
    group = label,
    n_tracts = nrow(df),
    mean_poverty = mean(df$poverty_rate, na.rm = TRUE),
    mean_pop = mean(df$total_pop, na.rm = TRUE),
    mean_pre_emp = mean(df$pre_total_emp, na.rm = TRUE),
    mean_pre_info = mean(df$pre_info_emp, na.rm = TRUE),
    mean_post_emp = mean(df$post_total_emp, na.rm = TRUE),
    mean_post_info = mean(df$post_info_emp, na.rm = TRUE),
    mean_delta_emp = mean(df$delta_total_emp, na.rm = TRUE),
    mean_delta_info = mean(df$delta_info_emp, na.rm = TRUE),
    pct_oz = mean(df$oz_designated, na.rm = TRUE) * 100,
    mean_bachelors = mean(df$pct_bachelors, na.rm = TRUE),
    mean_white = mean(df$pct_white, na.rm = TRUE),
    mean_home_val = mean(df$median_home_value, na.rm = TRUE),
    mean_unemp = mean(df$unemployment_rate, na.rm = TRUE)
  )
}

stats_below <- make_stats(below, "Below 20\\%")
stats_above <- make_stats(above, "Above 20\\%")
stats_full <- make_stats(within_bw, "Full Sample")

# Build table using paste0 to avoid sprintf % conflicts
fmt_n <- function(x) format(x, big.mark = ",")
fmt_1f <- function(x) formatC(x, format = "f", digits = 1)
fmt_0f <- function(x) formatC(x, format = "f", digits = 0)
fmt_2f <- function(x) formatC(x, format = "f", digits = 2)
fmt_money <- function(x) format(round(x), big.mark = ",")

tex1 <- paste0(
  "\\begin{table}[htbp]\n",
  "\\centering\n",
  "\\caption{Summary Statistics: Census Tracts Near the 20\\% Poverty Threshold}\n",
  "\\label{tab:summary}\n",
  "\\small\n",
  "\\begin{tabular}{lrrr}\n",
  "\\toprule\n",
  "& Below 20\\% & Above 20\\% & Full Sample \\\\\n",
  "\\midrule\n",
  "\\textit{Panel A: Demographics} & & & \\\\\n",
  "Number of tracts & ", fmt_n(stats_below$n_tracts), " & ", fmt_n(stats_above$n_tracts), " & ", fmt_n(stats_full$n_tracts), " \\\\\n",
  "Poverty rate (\\%) & ", fmt_1f(stats_below$mean_poverty), " & ", fmt_1f(stats_above$mean_poverty), " & ", fmt_1f(stats_full$mean_poverty), " \\\\\n",
  "Total population & ", fmt_0f(stats_below$mean_pop), " & ", fmt_0f(stats_above$mean_pop), " & ", fmt_0f(stats_full$mean_pop), " \\\\\n",
  "\\% Bachelor's degree & ", fmt_1f(stats_below$mean_bachelors), " & ", fmt_1f(stats_above$mean_bachelors), " & ", fmt_1f(stats_full$mean_bachelors), " \\\\\n",
  "\\% White & ", fmt_1f(stats_below$mean_white), " & ", fmt_1f(stats_above$mean_white), " & ", fmt_1f(stats_full$mean_white), " \\\\\n",
  "Median home value (\\$) & ", fmt_money(stats_below$mean_home_val), " & ", fmt_money(stats_above$mean_home_val), " & ", fmt_money(stats_full$mean_home_val), " \\\\\n",
  "Unemployment rate (\\%) & ", fmt_1f(stats_below$mean_unemp), " & ", fmt_1f(stats_above$mean_unemp), " & ", fmt_1f(stats_full$mean_unemp), " \\\\\n",
  "\\midrule\n",
  "\\textit{Panel B: Employment} & & & \\\\\n",
  "Pre-period total employment & ", fmt_1f(stats_below$mean_pre_emp), " & ", fmt_1f(stats_above$mean_pre_emp), " & ", fmt_1f(stats_full$mean_pre_emp), " \\\\\n",
  "Pre-period info employment & ", fmt_2f(stats_below$mean_pre_info), " & ", fmt_2f(stats_above$mean_pre_info), " & ", fmt_2f(stats_full$mean_pre_info), " \\\\\n",
  "Post-period total employment & ", fmt_1f(stats_below$mean_post_emp), " & ", fmt_1f(stats_above$mean_post_emp), " & ", fmt_1f(stats_full$mean_post_emp), " \\\\\n",
  "Post-period info employment & ", fmt_2f(stats_below$mean_post_info), " & ", fmt_2f(stats_above$mean_post_info), " & ", fmt_2f(stats_full$mean_post_info), " \\\\\n",
  "$\\Delta$ Total employment & ", fmt_1f(stats_below$mean_delta_emp), " & ", fmt_1f(stats_above$mean_delta_emp), " & ", fmt_1f(stats_full$mean_delta_emp), " \\\\\n",
  "$\\Delta$ Info employment & ", fmt_2f(stats_below$mean_delta_info), " & ", fmt_2f(stats_above$mean_delta_info), " & ", fmt_2f(stats_full$mean_delta_info), " \\\\\n",
  "\\midrule\n",
  "\\textit{Panel C: OZ Status} & & & \\\\\n",
  "OZ designated (\\%, approx.) & ", fmt_1f(stats_below$pct_oz), " & ", fmt_1f(stats_above$pct_oz), " & ", fmt_1f(stats_full$pct_oz), " \\\\\n",
  "\\bottomrule\n",
  "\\end{tabular}\n",
  "\\begin{tablenotes}\n",
  "\\small\n",
  "\\item \\textit{Notes:} Sample includes census tracts within the MSE-optimal bandwidth for the change in total employment outcome (", fmt_1f(opt_bw), " percentage points from \\citet{cattaneo2020}). Bandwidths vary by outcome in the main RDD estimates. Pre-period is the average of 2015--2017; post-period is the average of 2019--2023. Employment data from Census LEHD/LODES. Poverty rate and demographics from ACS 2011--2015. OZ designation is approximated by designating the top 25\\% of poverty-eligible tracts within each state (see Appendix~\\ref{app:data}); by construction, the approximated designation rate is zero for tracts below the 20\\% poverty threshold.\n",
  "\\end{tablenotes}\n",
  "\\end{table}"
)

writeLines(tex1, file.path(tab_dir, "tab1_summary.tex"))
cat("  Saved tab1_summary.tex\n")


###############################################################################
# Table 2: Main RDD Results
###############################################################################
cat("Table 2: Main RDD Results\n")

main_res <- readRDS(file.path(data_dir, "main_rdd_results.rds"))

# Build table rows
build_row <- function(res, label) {
  if (is.null(res)) return(paste0(label, " & --- & --- & --- & --- \\\\"))
  stars <- ifelse(res$pval < 0.01, "***",
           ifelse(res$pval < 0.05, "**",
           ifelse(res$pval < 0.10, "*", "")))
  paste0(label, " & ",
         formatC(res$coef, format = "f", digits = 3), stars,
         " & (", formatC(res$se_robust, format = "f", digits = 3), ")",
         " & [", formatC(res$ci_lower, format = "f", digits = 3), ", ",
         formatC(res$ci_upper, format = "f", digits = 3), "]",
         " & ", format(res$N_left + res$N_right, big.mark = ","),
         " \\\\")
}

rows <- c(
  build_row(main_res[["Delta Total Emp"]], "$\\Delta$ Total employment"),
  build_row(main_res[["Delta Info Emp"]], "$\\Delta$ Info sector emp"),
  build_row(main_res[["Delta Construction Emp"]], "$\\Delta$ Construction emp")
)

tex2 <- paste0(
  "\\begin{table}[htbp]\n",
  "\\centering\n",
  "\\caption{Main RDD Estimates: Effect of OZ Eligibility on Employment}\n",
  "\\label{tab:main_rdd}\n",
  "\\small\n",
  "\\begin{tabular}{lcccc}\n",
  "\\toprule\n",
  "& Estimate & Robust SE & 95\\% CI & N \\\\\n",
  "\\midrule\n",
  "\\textit{Changes (Post minus Pre)} & & & & \\\\\n",
  rows[1], "\n",
  rows[2], "\n",
  rows[3], "\n",
  "\\bottomrule\n",
  "\\end{tabular}\n",
  "\\begin{tablenotes}\n",
  "\\small\n",
  "\\item \\textit{Notes:} Estimates from local polynomial RDD using \\texttt{rdrobust} \\citep{cattaneo2020} with MSE-optimal bandwidth and triangular kernel. Each row reports the reduced-form (ITT) estimate of crossing the 20\\% poverty threshold on the change in employment (post-period 2019--2023 average minus pre-period 2015--2017 average). Robust bias-corrected confidence intervals. MSE-optimal bandwidths (pp): ",
  ifelse(!is.null(main_res[["Delta Total Emp"]]),
         paste0("$\\Delta$ Total emp = ", formatC(main_res[["Delta Total Emp"]]$bandwidth, format = "f", digits = 1)), ""),
  ifelse(!is.null(main_res[["Delta Info Emp"]]),
         paste0("; $\\Delta$ Info emp = ", formatC(main_res[["Delta Info Emp"]]$bandwidth, format = "f", digits = 1)), ""),
  ifelse(!is.null(main_res[["Delta Construction Emp"]]),
         paste0("; $\\Delta$ Construction emp = ", formatC(main_res[["Delta Construction Emp"]]$bandwidth, format = "f", digits = 1)), ""),
  ". * $p<0.10$, ** $p<0.05$, *** $p<0.01$.\n",
  "\\end{tablenotes}\n",
  "\\end{table}"
)

writeLines(tex2, file.path(tab_dir, "tab2_main_rdd.tex"))
cat("  Saved tab2_main_rdd.tex\n")


###############################################################################
# Table 3: Robustness — Bandwidth Sensitivity
###############################################################################
cat("Table 3: Bandwidth Sensitivity\n")

bw_sens <- readRDS(file.path(data_dir, "bw_sensitivity.rds"))

# Override 100% row with main results to ensure consistency across tables
main_delta <- main_res[["Delta Total Emp"]]
if (!is.null(main_delta)) {
  idx_100 <- which(abs(bw_sens$multiplier - 1.0) < 0.01)
  if (length(idx_100) == 1) {
    bw_sens$coef[idx_100] <- main_delta$coef
    bw_sens$se[idx_100] <- main_delta$se_robust
    bw_sens$pval[idx_100] <- main_delta$pval
    bw_sens$N_eff[idx_100] <- main_delta$N_left + main_delta$N_right
  }
}

if (nrow(bw_sens) > 0) {
  bw_rows <- sapply(1:nrow(bw_sens), function(i) {
    r <- bw_sens[i, ]
    stars <- ifelse(r$pval < 0.01, "***",
             ifelse(r$pval < 0.05, "**",
             ifelse(r$pval < 0.10, "*", "")))
    paste0(fmt_0f(r$multiplier * 100), "\\% & ",
           fmt_1f(r$bandwidth), " & ",
           formatC(r$coef, format = "f", digits = 3), stars, " & (",
           formatC(r$se, format = "f", digits = 3), ") & ",
           formatC(r$pval, format = "f", digits = 3), " & ",
           fmt_n(r$N_eff))
  })

  tex3 <- paste0(
    "\\begin{table}[htbp]\n",
    "\\centering\n",
    "\\caption{Bandwidth Sensitivity: $\\Delta$ Total Employment}\n",
    "\\label{tab:bw_sensitivity}\n",
    "\\small\n",
    "\\begin{tabular}{lccccc}\n",
    "\\toprule\n",
    "Bandwidth & Size (pp) & Estimate & Robust SE & $p$-value & N \\\\\n",
    "\\midrule\n",
    paste(bw_rows, collapse = " \\\\\n"), " \\\\\n",
    "\\bottomrule\n",
    "\\end{tabular}\n",
    "\\begin{tablenotes}\n",
    "\\small\n",
    "\\item \\textit{Notes:} Each row reports the RDD estimate at a different bandwidth, expressed as a percentage of the MSE-optimal bandwidth. All specifications use local linear regression with triangular kernel and robust bias-corrected inference. * $p<0.10$, ** $p<0.05$, *** $p<0.01$.\n",
    "\\end{tablenotes}\n",
    "\\end{table}"
  )

  writeLines(tex3, file.path(tab_dir, "tab3_bw_sensitivity.tex"))
  cat("  Saved tab3_bw_sensitivity.tex\n")
}


###############################################################################
# Table 4: Covariate Balance
###############################################################################
cat("Table 4: Covariate Balance\n")

balance <- readRDS(file.path(data_dir, "balance_tests.rds"))

if (nrow(balance) > 0) {
  # Compute N for each covariate using its bandwidth
  balance$N_eff <- sapply(1:nrow(balance), function(i) {
    bw <- balance$bandwidth[i]
    sum(abs(rdd_sample$poverty_rate - 20) <= bw, na.rm = TRUE)
  })

  balance <- balance %>%
    mutate(variable = case_when(
      variable == "total_pop" ~ "Population",
      variable == "pct_bachelors" ~ "\\% Bachelor's degree",
      variable == "pct_white" ~ "\\% White",
      variable == "median_home_value" ~ "Median home value",
      variable == "unemployment_rate" ~ "Unemployment rate",
      variable == "pre_total_emp" ~ "Pre-period total employment",
      variable == "pre_info_emp" ~ "Pre-period info employment",
      TRUE ~ variable
    ))

  bal_rows <- sapply(1:nrow(balance), function(i) {
    r <- balance[i, ]
    paste0(r$variable, " & ",
           formatC(r$coef, format = "f", digits = 3), " & (",
           formatC(r$se, format = "f", digits = 3), ") & ",
           formatC(r$pval, format = "f", digits = 3), " & ",
           fmt_n(r$N_eff))
  })

  tex4 <- paste0(
    "\\begin{table}[htbp]\n",
    "\\centering\n",
    "\\caption{Covariate Balance at the 20\\% Poverty Threshold}\n",
    "\\label{tab:balance}\n",
    "\\small\n",
    "\\begin{tabular}{lcccc}\n",
    "\\toprule\n",
    "Covariate & RDD Estimate & Robust SE & $p$-value & N \\\\\n",
    "\\midrule\n",
    paste(bal_rows, collapse = " \\\\\n"), " \\\\\n",
    "\\bottomrule\n",
    "\\end{tabular}\n",
    "\\begin{tablenotes}\n",
    "\\small\n",
    "\\item \\textit{Notes:} Each row reports the RDD estimate for a pre-determined covariate at the 20\\% poverty threshold, using \\texttt{rdrobust} with MSE-optimal bandwidth and triangular kernel. $p$-values are from robust bias-corrected inference. N is the number of tracts within each covariate's MSE-optimal bandwidth. All covariates are measured from ACS 2011--2015 (pre-treatment).\n",
    "\\end{tablenotes}\n",
    "\\end{table}"
  )

  writeLines(tex4, file.path(tab_dir, "tab4_balance.tex"))
  cat("  Saved tab4_balance.tex\n")
}


###############################################################################
# Table 5: Parametric Specifications
###############################################################################
cat("Table 5: Parametric Specifications\n")

models <- readRDS(file.path(data_dir, "parametric_models.rds"))

etable(models$m1, models$m2, models$m3, models$m4, models$m5,
       tex = TRUE,
       file = file.path(tab_dir, "tab5_parametric.tex"),
       replace = TRUE,
       title = "Parametric RDD Specifications",
       label = "tab:parametric",
       dict = c(eligible_povertyTRUE = "Above Threshold",
                pov_centered = "Poverty Rate (centered)",
                total_pop = "Population",
                pct_bachelors = "\\% Bachelor's",
                pct_white = "\\% White",
                unemployment_rate = "Unemployment Rate"),
       notes = "Parametric RDD specifications within optimal bandwidth. Columns (1)--(3): $\\Delta$ Total Employment. Columns (4)--(5): $\\Delta$ Information Sector Employment. Heteroskedasticity-robust standard errors in parentheses.",
       depvar = FALSE,
       style.tex = style.tex("aer"))

cat("  Saved tab5_parametric.tex\n")

cat("\n=== All tables generated ===\n")
