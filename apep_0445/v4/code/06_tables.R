###############################################################################
# 06_tables.R
# Generate all LaTeX tables for the paper
# APEP-0445 v4
###############################################################################

this_file <- tryCatch(sys.frame(1)$ofile, error = function(e) NULL)
if (is.null(this_file)) this_file <- "."
source(file.path(dirname(this_file), "00_packages.R"))

rdd_sample <- readRDS(file.path(data_dir, "rdd_sample.rds"))
cat("Data loaded for tables\n\n")

# Load OZ source metadata
oz_meta_file <- file.path(data_dir, "oz_source_metadata.rds")
oz_source <- "approximation"
if (file.exists(oz_meta_file)) {
  oz_meta <- readRDS(oz_meta_file)
  oz_source <- oz_meta$source
}
cat("OZ data source:", oz_source, "\n\n")


###############################################################################
# Table 1: Summary Statistics
###############################################################################
cat("Table 1: Summary Statistics\n")

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

fmt_n <- function(x) format(x, big.mark = ",")
fmt_1f <- function(x) formatC(x, format = "f", digits = 1)
fmt_0f <- function(x) formatC(x, format = "f", digits = 0)
fmt_2f <- function(x) formatC(x, format = "f", digits = 2)
fmt_money <- function(x) format(round(x), big.mark = ",")

# OZ label depends on data source
oz_label <- ifelse(oz_source == "cdfi_official",
                   "OZ designated (\\%)",
                   "OZ designated (\\%, approx.)")

oz_note <- ifelse(oz_source == "cdfi_official",
  "OZ designation status from official CDFI Fund certified list of 8,764 Qualified Opportunity Zones.",
  "OZ designation is approximated by designating the top 25\\% of poverty-eligible tracts within each state; results should be interpreted with caution."
)

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
  oz_label, " & ", fmt_1f(stats_below$pct_oz), " & ", fmt_1f(stats_above$pct_oz), " & ", fmt_1f(stats_full$pct_oz), " \\\\\n",
  "\\bottomrule\n",
  "\\end{tabular}\n",
  "\\begin{tablenotes}\n",
  "\\small\n",
  "\\item \\textit{Notes:} Sample includes census tracts within the MSE-optimal bandwidth for the change in total employment outcome (", fmt_1f(opt_bw), " percentage points from \\citet{cattaneo2020}). Pre-period is the average of 2015--2017; post-period is the average of 2019--2023. Employment data from Census LEHD/LODES \\citep{lodes_technical}. Poverty rate and demographics from ACS 2011--2015. ", oz_note, "\n",
  "\\end{tablenotes}\n",
  "\\end{table}"
)

writeLines(tex1, file.path(tab_dir, "tab1_summary.tex"))
cat("  Saved tab1_summary.tex\n")


###############################################################################
# Table 1b: First Stage
###############################################################################
cat("Table 1b: First Stage\n")

fs_file <- file.path(data_dir, "first_stage_parametric.rds")
if (file.exists(fs_file)) {
  fs <- readRDS(fs_file)

  fs_coef <- coef(fs$linear)["eligible_povertyTRUE"]
  fs_se <- sqrt(vcov(fs$linear)["eligible_povertyTRUE", "eligible_povertyTRUE"])
  fs_pval <- 2 * pnorm(-abs(fs_coef / fs_se))

  fs_coef_c <- coef(fs$with_covs)["eligible_povertyTRUE"]
  fs_se_c <- sqrt(vcov(fs$with_covs)["eligible_povertyTRUE", "eligible_povertyTRUE"])
  fs_pval_c <- 2 * pnorm(-abs(fs_coef_c / fs_se_c))

  add_stars_local <- function(val, pval) {
    stars <- ifelse(pval < 0.01, "***",
             ifelse(pval < 0.05, "**",
             ifelse(pval < 0.10, "*", "")))
    paste0(formatC(val, format = "f", digits = 4), stars)
  }

  tex1b <- paste0(
    "\\begin{table}[htbp]\n",
    "\\centering\n",
    "\\caption{First Stage: Effect of Poverty Threshold on OZ Designation}\n",
    "\\label{tab:first_stage}\n",
    "\\small\n",
    "\\begin{tabular}{lcc}\n",
    "\\toprule\n",
    " & (1) & (2) \\\\\n",
    " & Linear & + Covariates \\\\\n",
    "\\midrule\n",
    "\\textit{Dep. var.: OZ Designated} & & \\\\\n",
    "Above 20\\% threshold & ", add_stars_local(fs_coef, fs_pval), " & ", add_stars_local(fs_coef_c, fs_pval_c), " \\\\\n",
    " & (", formatC(fs_se, format = "f", digits = 4), ") & (", formatC(fs_se_c, format = "f", digits = 4), ") \\\\\n",
    "\\midrule\n",
    "First-stage $F$ & ", formatC(fs$f_stat, format = "f", digits = 1), " & ", formatC(fs$f_stat_covs, format = "f", digits = 1), " \\\\\n",
    "Bandwidth (pp) & ", formatC(fs$bandwidth, format = "f", digits = 1), " & ", formatC(fs$bandwidth, format = "f", digits = 1), " \\\\\n",
    "Observations & ", fmt_n(fs$n_obs), " & ", fmt_n(fs$n_obs), " \\\\\n",
    "Covariates & No & Yes \\\\\n",
    "\\bottomrule\n",
    "\\end{tabular}\n",
    "\\begin{tablenotes}\n",
    "\\small\n",
    "\\item \\textit{Notes:} Parametric first-stage regressions within the MSE-optimal bandwidth. Dependent variable is an indicator for OZ designation. Above threshold is an indicator for poverty rate $\\geq$ 20\\%. HC1 standard errors in parentheses. Covariates: population, education, race, unemployment rate. Stock-Yogo 10\\% critical value for weak instruments: 16.38. * $p<0.10$, ** $p<0.05$, *** $p<0.01$.\n",
    "\\end{tablenotes}\n",
    "\\end{table}"
  )

  writeLines(tex1b, file.path(tab_dir, "tab1b_first_stage.tex"))
  cat("  Saved tab1b_first_stage.tex\n")
} else {
  cat("  First stage parametric file not found\n")
}


###############################################################################
# Table 2: Main RDD Results
###############################################################################
cat("Table 2: Main RDD Results\n")

main_res <- readRDS(file.path(data_dir, "main_rdd_results.rds"))

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
# Table 3: Robustness -- Bandwidth Sensitivity
###############################################################################
cat("Table 3: Bandwidth Sensitivity\n")

bw_sens <- readRDS(file.path(data_dir, "bw_sensitivity.rds"))

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
                "I(pov_centered^2)" = "Poverty Rate (centered)$^2$",
                total_pop = "Population",
                pct_bachelors = "\\% Bachelor's",
                pct_white = "\\% White",
                unemployment_rate = "Unemployment Rate"),
       headers = c("$\\Delta$ Total Emp", "$\\Delta$ Total Emp", "$\\Delta$ Total Emp", "$\\Delta$ Info Emp", "$\\Delta$ Info Emp"),
       notes = "Parametric RDD specifications within optimal bandwidth. Columns (1)--(3): $\\Delta$ Total Employment. Columns (4)--(5): $\\Delta$ Information Sector Employment. Heteroskedasticity-robust standard errors in parentheses.",
       depvar = FALSE,
       style.tex = style.tex("aer"),
       fitstat = ~ r2 + n)

cat("  Saved tab5_parametric.tex\n")

###############################################################################
# Table 6: Data Center Presence RDD (v3 addition)
###############################################################################
cat("Table 6: Data Center Presence RDD\n")

dc_file <- file.path(data_dir, "dc_rdd_results.rds")
if (file.exists(dc_file)) {
  dc_res <- readRDS(dc_file)

  if (length(dc_res) > 0 && !is.null(dc_res[["DC Presence (Binary)"]])) {
    dc_bin <- dc_res[["DC Presence (Binary)"]]
    dc_ct <- dc_res[["DC Count"]]
    dc_lpm <- dc_res[["DC LPM"]]
    dc_mde <- dc_res[["MDE"]]

    build_dc_row <- function(res, label, digits = 5) {
      if (is.null(res)) return(paste0(label, " & --- & --- & --- & --- \\\\"))
      stars <- ifelse(res$pval < 0.01, "***",
               ifelse(res$pval < 0.05, "**",
               ifelse(res$pval < 0.10, "*", "")))
      n_total <- if (!is.null(res$N_left)) res$N_left + res$N_right else "---"
      ci_str <- if (!is.null(res$ci_lower)) {
        paste0("[", formatC(res$ci_lower, format = "f", digits = digits), ", ",
               formatC(res$ci_upper, format = "f", digits = digits), "]")
      } else "---"
      paste0(label, " & ",
             formatC(res$coef, format = "f", digits = digits), stars,
             " & (", formatC(res$se_robust, format = "f", digits = digits), ")",
             " & ", ci_str,
             " & ", format(n_total, big.mark = ","),
             " \\\\")
    }

    dc_rows <- c(
      build_dc_row(dc_bin, "DC presence (binary)"),
      build_dc_row(dc_ct, "DC count"),
      build_dc_row(dc_lpm, "DC presence (LPM)")
    )

    mde_note <- ""
    if (!is.null(dc_mde)) {
      mde_note <- sprintf(
        " Base rate of data center presence: %.3f\\%%. MDE at 80\\%% power: %.3f pp (%.0f\\%% of base rate).",
        dc_mde$base_rate * 100, dc_mde$mde_80 * 100, dc_mde$mde_pct_base
      )
    }

    # Count DC events within bandwidth for transparency
    dc_event_note <- ""
    if (!is.null(dc_bin$bandwidth)) {
      bw_idx <- abs(rdd_sample$pov_centered) <= dc_bin$bandwidth
      bw_data <- rdd_sample[bw_idx, ]
      n_dc_below <- sum(bw_data$dc_any[bw_data$poverty_rate < 20], na.rm = TRUE)
      n_dc_above <- sum(bw_data$dc_any[bw_data$poverty_rate >= 20], na.rm = TRUE)
      dc_event_note <- sprintf(
        " Within the MSE-optimal bandwidth (%.1f pp), %d tract(s) below and %d tract(s) above the cutoff contain a data center facility.",
        dc_bin$bandwidth, n_dc_below, n_dc_above
      )
    }

    tex6 <- paste0(
      "\\begin{table}[htbp]\n",
      "\\centering\n",
      "\\caption{RDD Estimates: Effect of OZ Eligibility on Data Center Presence}\n",
      "\\label{tab:dc_rdd}\n",
      "\\small\n",
      "\\begin{tabular}{lcccc}\n",
      "\\toprule\n",
      "& Estimate & Robust SE & 95\\% CI & N \\\\\n",
      "\\midrule\n",
      paste(dc_rows, collapse = "\n"), "\n",
      "\\bottomrule\n",
      "\\end{tabular}\n",
      "\\begin{tablenotes}\n",
      "\\small\n",
      "\\item \\textit{Notes:} Rows 1--2: nonparametric RDD using \\texttt{rdrobust} with MSE-optimal bandwidth and triangular kernel. Row 3: linear probability model within optimal bandwidth with HC1 standard errors. Data center locations from EIA Form 860 and EPA GHGRP, geocoded to census tracts.", mde_note, dc_event_note, " * $p<0.10$, ** $p<0.05$, *** $p<0.01$.\n",
      "\\end{tablenotes}\n",
      "\\end{table}"
    )

    writeLines(tex6, file.path(tab_dir, "tab6_dc_rdd.tex"))
    cat("  Saved tab6_dc_rdd.tex\n")
  } else {
    cat("  No DC RDD results available for table\n")
  }
} else {
  cat("  DC RDD results file not found\n")
}


###############################################################################
# Table 7: DC Vintage RDD (v4 addition)
###############################################################################
cat("Table 7: DC Vintage RDD\n")

vintage_file <- file.path(data_dir, "dc_vintage_results.rds")
if (file.exists(vintage_file)) {
  vintage_res <- readRDS(vintage_file)

  if (length(vintage_res) > 0) {
    build_vintage_row <- function(res, label, digits = 5) {
      if (is.null(res)) return(paste0(label, " & --- & --- & --- & --- \\\\"))
      stars <- ifelse(res$pval < 0.01, "***",
               ifelse(res$pval < 0.05, "**",
               ifelse(res$pval < 0.10, "*", "")))
      n_total <- if (!is.null(res$N_left)) res$N_left + res$N_right else "---"
      ci_str <- if (!is.null(res$ci_lower)) {
        paste0("[", formatC(res$ci_lower, format = "f", digits = digits), ", ",
               formatC(res$ci_upper, format = "f", digits = digits), "]")
      } else "---"
      paste0(label, " & ",
             formatC(res$coef, format = "f", digits = digits), stars,
             " & (", formatC(res$se_robust, format = "f", digits = digits), ")",
             " & ", ci_str,
             " & ", format(n_total, big.mark = ","),
             " \\\\")
    }

    vintage_rows <- c(
      "\\textit{Panel A: Post-2018 (Treatment-Relevant)} & & & & \\\\",
      build_vintage_row(vintage_res[["DC Post-2018 (Binary)"]], "Post-2018 DC presence"),
      "\\midrule",
      "\\textit{Panel B: Pre-2018 (Placebo)} & & & & \\\\",
      build_vintage_row(vintage_res[["DC Pre-2018 (Binary)"]], "Pre-2018 DC presence")
    )

    mde_note_v <- ""
    if (!is.null(vintage_res[["MDE_post2018"]])) {
      mde_v <- vintage_res[["MDE_post2018"]]
      mde_note_v <- sprintf(
        " Post-2018 base rate: %.3f\\%%. MDE at 80\\%% power: %.3f pp.",
        mde_v$base_rate * 100, mde_v$mde_80 * 100
      )
    }

    tex7 <- paste0(
      "\\begin{table}[htbp]\n",
      "\\centering\n",
      "\\caption{RDD Estimates: Data Center Presence by Vintage}\n",
      "\\label{tab:dc_vintage}\n",
      "\\small\n",
      "\\begin{tabular}{lcccc}\n",
      "\\toprule\n",
      "& Estimate & Robust SE & 95\\% CI & N \\\\\n",
      "\\midrule\n",
      paste(vintage_rows, collapse = "\n"), "\n",
      "\\bottomrule\n",
      "\\end{tabular}\n",
      "\\begin{tablenotes}\n",
      "\\small\n",
      "\\item \\textit{Notes:} Parametric linear probability model within a $\\pm 15$ percentage-point bandwidth with HC1 standard errors. Nonparametric \\texttt{rdrobust} is infeasible for these outcomes due to extreme sparsity (fewer than 5 treated tracts with vintage DCs in the RDD sample). Panel A reports estimates for data centers with initial commercial operation in 2018 or later (treatment-relevant flow). Panel B reports estimates for pre-2018 facilities (placebo: should show no discontinuity since these predate OZ designation). Operating year from EIA Form 860 generator-level data. Because all post-2018 and pre-2018 tracts have exactly one facility, the binary and count outcomes are mechanically identical.", mde_note_v, " * $p<0.10$, ** $p<0.05$, *** $p<0.01$.\n",
      "\\end{tablenotes}\n",
      "\\end{table}"
    )

    writeLines(tex7, file.path(tab_dir, "tab7_dc_vintage.tex"))
    cat("  Saved tab7_dc_vintage.tex\n")
  } else {
    cat("  No DC vintage results available\n")
  }
} else {
  cat("  DC vintage results file not found\n")
}


###############################################################################
# Table 8: Main-Text Local Randomization (v4: elevated from appendix)
###############################################################################
cat("Table 8: Main-Text Local Randomization\n")

lr_file <- file.path(data_dir, "local_randomization.rds")
dc_lr_file <- file.path(data_dir, "dc_local_randomization.rds")

lr_all <- data.frame()
if (file.exists(lr_file)) {
  lr_emp <- readRDS(lr_file)
  if (nrow(lr_emp) > 0) lr_all <- bind_rows(lr_all, lr_emp)
}
if (file.exists(dc_lr_file)) {
  lr_dc <- readRDS(dc_lr_file)
  if (nrow(lr_dc) > 0) lr_all <- bind_rows(lr_all, lr_dc)
}

if (nrow(lr_all) > 0) {
  has_diff <- "diff_means" %in% names(lr_all)

  lr_rows <- sapply(1:nrow(lr_all), function(i) {
    r <- lr_all[i, ]
    label <- gsub("Delta ", "$\\\\Delta$ ", r$outcome)
    dm_str <- if (has_diff && !is.na(r$diff_means)) {
      formatC(r$diff_means, format = "f", digits = 2)
    } else { "---" }
    paste0(
      label, " & $\\pm$", formatC(r$window, format = "f", digits = 2), " & ",
      dm_str, " & ",
      formatC(r$obs_stat, format = "f", digits = 3), " & ",
      formatC(r$p_value, format = "f", digits = 3), " & ",
      r$n_left, " & ", r$n_right
    )
  })

  tex8 <- paste0(
    "\\begin{table}[htbp]\n",
    "\\centering\n",
    "\\caption{Design-Based Results: Local Randomization Inference}\n",
    "\\label{tab:local_rand_main}\n",
    "\\small\n",
    "\\begin{tabular}{lcccccc}\n",
    "\\toprule\n",
    "Outcome & Window (pp) & $\\hat{\\tau}$ & Test Stat & Fisher $p$ & $N_{left}$ & $N_{right}$ \\\\\n",
    "\\midrule\n",
    paste(lr_rows, collapse = " \\\\\n"), " \\\\\n",
    "\\bottomrule\n",
    "\\end{tabular}\n",
    "\\begin{tablenotes}\n",
    "\\small\n",
    "\\item \\textit{Notes:} Fisher randomization inference using \\texttt{rdrandinf} \\citep{cattaneo2015} with 1,000 permutations within symmetric windows around the 20\\% poverty cutoff. $\\hat{\\tau}$ is the difference in means (above minus below cutoff). This approach does not require density continuity and is valid with discrete running variables \\citep{frandsen2017, kolesar2018}. Fisher $p$-values test the sharp null of no treatment effect for any unit within the window. * $p<0.10$, ** $p<0.05$, *** $p<0.01$.\n",
    "\\end{tablenotes}\n",
    "\\end{table}"
  )

  writeLines(tex8, file.path(tab_dir, "tab8_local_randomization.tex"))
  cat("  Saved tab8_local_randomization.tex\n")
} else {
  cat("  No local randomization results available for main table\n")
}


###############################################################################
# Table A6: Local Randomization Covariate Balance (v3 addition)
###############################################################################
cat("Table A6: Local Randomization Covariate Balance\n")

lr_bal_file <- file.path(data_dir, "lr_covariate_balance.rds")
if (file.exists(lr_bal_file)) {
  lr_bal <- readRDS(lr_bal_file)

  if (nrow(lr_bal) > 0) {
    lr_bal <- lr_bal %>%
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

    lr_rows <- sapply(1:nrow(lr_bal), function(i) {
      r <- lr_bal[i, ]
      paste0(r$variable, " & ",
             formatC(r$obs_stat, format = "f", digits = 3), " & ",
             formatC(r$p_value, format = "f", digits = 3), " & ",
             r$n)
    })

    tex_a6 <- paste0(
      "\\begin{table}[htbp]\n",
      "\\centering\n",
      "\\caption{Local Randomization Covariate Balance}\n",
      "\\label{tab:lr_balance}\n",
      "\\small\n",
      "\\begin{tabular}{lccc}\n",
      "\\toprule\n",
      "Covariate & Test Statistic & Fisher $p$ & $N$ \\\\\n",
      "\\midrule\n",
      paste(lr_rows, collapse = " \\\\\n"), " \\\\\n",
      "\\bottomrule\n",
      "\\end{tabular}\n",
      "\\begin{tablenotes}\n",
      "\\small\n",
      "\\item \\textit{Notes:} Fisher randomization inference for covariate balance within $\\pm 1.0$ percentage-point window of the 20\\% poverty cutoff, using \\texttt{rdrandinf} \\citep{cattaneo2015} with 1,000 permutations.\n",
      "\\end{tablenotes}\n",
      "\\end{table}"
    )

    writeLines(tex_a6, file.path(tab_dir, "tabA6_lr_balance.tex"))
    cat("  Saved tabA6_lr_balance.tex\n")
  }
}


###############################################################################
# Table A5: Appendix Local Randomization (regenerated from data)
###############################################################################
cat("Table A5: Appendix Local Randomization\n")

lr_a5_file <- file.path(data_dir, "local_randomization.rds")
if (file.exists(lr_a5_file)) {
  lr_a5 <- readRDS(lr_a5_file)

  if (nrow(lr_a5) > 0) {
    lr_a5_rows <- sapply(1:nrow(lr_a5), function(i) {
      r <- lr_a5[i, ]
      label <- gsub("Delta ", "$\\\\Delta$ ", r$outcome)
      paste0(
        label, " & $\\pm$", formatC(r$window, format = "f", digits = 2), " & ",
        formatC(r$obs_stat, format = "f", digits = 3), " & ",
        formatC(r$p_value, format = "f", digits = 3), " & ",
        r$n_left, " & ", r$n_right
      )
    })

    tex_a5 <- paste0(
      "\\begin{table}[htbp]\n",
      "\\centering\n",
      "\\caption{Local Randomization Inference}\n",
      "\\label{tab:local_randomization}\n",
      "\\small\n",
      "\\begin{tabular}{lccccc}\n",
      "\\toprule\n",
      "Outcome & Window (pp) & Test Stat & Fisher $p$ & $N_{left}$ & $N_{right}$ \\\\\n",
      "\\midrule\n",
      paste(lr_a5_rows, collapse = " \\\\\n"), " \\\\\n",
      "\\bottomrule\n",
      "\\end{tabular}\n",
      "\\begin{tablenotes}\n",
      "\\small\n",
      "\\item \\textit{Notes:} Randomization inference using \\texttt{rdrandinf} \\citep{cattaneo2015} with 1,000 permutations. Windows are symmetric around the 20\\% poverty cutoff. Fisher $p$-values test the sharp null of no treatment effect for any unit within the window.\n",
      "\\end{tablenotes}\n",
      "\\end{table}"
    )

    writeLines(tex_a5, file.path(tab_dir, "tabA5_local_randomization.tex"))
    cat("  Saved tabA5_local_randomization.tex\n")
  }
}


###############################################################################
# Table A7: DC Robustness (bandwidth + donut)
###############################################################################
cat("Table A7: DC Robustness\n")

dc_rob_file <- file.path(data_dir, "dc_robustness.rds")
if (file.exists(dc_rob_file)) {
  dc_rob <- readRDS(dc_rob_file)
  # Filter out rows with NaN p-values (too-narrow bandwidths with no variation)
  dc_rob <- dc_rob %>% filter(!is.nan(pval))

  if (nrow(dc_rob) > 0) {
    dc_rob_rows <- sapply(1:nrow(dc_rob), function(i) {
      r <- dc_rob[i, ]
      param_label <- if (r$test == "Bandwidth") {
        paste0(formatC(r$parameter, format = "f", digits = 2), "$\\times$ optimal")
      } else {
        paste0("$\\pm$", formatC(r$parameter, format = "f", digits = 1), " pp")
      }
      stars <- ifelse(r$pval < 0.01, "$^{***}$", ifelse(r$pval < 0.05, "$^{**}$", ifelse(r$pval < 0.10, "$^{*}$", "")))
      paste0(
        r$test, " & ", param_label, " & ",
        formatC(r$coef, format = "f", digits = 5), stars, " & (",
        formatC(r$se, format = "f", digits = 5), ") & ",
        formatC(r$pval, format = "f", digits = 3), " & ",
        format(r$N_eff, big.mark = ",")
      )
    })

    tex_a7 <- paste0(
      "\\begin{table}[htbp]\n",
      "\\centering\n",
      "\\caption{Data Center Presence: Bandwidth and Donut Robustness}\n",
      "\\label{tab:dc_robustness}\n",
      "\\small\n",
      "\\begin{tabular}{llcccc}\n",
      "\\toprule\n",
      "Test & Specification & Estimate & Robust SE & $p$-value & $N$ \\\\\n",
      "\\midrule\n",
      paste(dc_rob_rows, collapse = " \\\\\n"), " \\\\\n",
      "\\bottomrule\n",
      "\\end{tabular}\n",
      "\\begin{tablenotes}\n",
      "\\small\n",
      "\\item \\textit{Notes:} Nonparametric RDD estimates for binary data center presence using \\texttt{rdrobust} with triangular kernel. Bandwidth rows vary the bandwidth as a fraction of the MSE-optimal bandwidth. Donut rows exclude tracts within the specified distance of the 20\\% poverty cutoff. Robust bias-corrected inference throughout. * $p<0.10$, ** $p<0.05$, *** $p<0.01$.\n",
      "\\end{tablenotes}\n",
      "\\end{table}"
    )

    writeLines(tex_a7, file.path(tab_dir, "tabA7_dc_robustness.tex"))
    cat("  Saved tabA7_dc_robustness.tex\n")
  }
}


cat("\n=== All tables generated ===\n")
