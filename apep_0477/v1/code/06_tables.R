###############################################################################
# 06_tables.R — Publication-quality tables
# apep_0477: Do Energy Labels Move Markets?
###############################################################################

source("00_packages.R")

DATA_DIR <- "../data"
TBL_DIR <- "../tables"
dir.create(TBL_DIR, showWarnings = FALSE, recursive = TRUE)

df <- as.data.table(read_parquet(file.path(DATA_DIR, "analysis_sample.parquet")))
rdd_dt <- fread(file.path(DATA_DIR, "rdd_results.csv"))

###############################################################################
# Table 1: Summary Statistics
###############################################################################

cat("Table 1: Summary statistics...\n")

# By EPC band
summ_band <- df[, .(
  N = .N,
  Mean_Price = mean(price),
  SD_Price = sd(price),
  Median_Price = as.double(median(price)),
  Mean_Score = mean(epc_score),
  Mean_FloorArea = mean(floor_area, na.rm = TRUE),
  Pct_Flat = mean(as.numeric(is_flat)) * 100,
  Pct_NewBuild = mean(as.numeric(is_new)) * 100,
  Pct_Rental = mean(as.numeric(is_rental), na.rm = TRUE) * 100
), by = epc_band][order(epc_band)]

fwrite(summ_band, file.path(TBL_DIR, "table1_summary_by_band.csv"))

# By period
summ_period <- df[, .(
  N = .N,
  Mean_Price = mean(price),
  SD_Price = sd(price),
  Median_Price = as.double(median(price)),
  Mean_Score = mean(epc_score),
  Pct_Rental = mean(as.numeric(is_rental), na.rm = TRUE) * 100
), by = period][order(period)]

fwrite(summ_period, file.path(TBL_DIR, "table1_summary_by_period.csv"))

# Overall
summ_all <- df[, .(
  N = .N,
  Mean_Price = mean(price),
  SD_Price = sd(price),
  Median_Price = median(price),
  Mean_Score = mean(epc_score),
  SD_Score = sd(epc_score),
  Mean_FloorArea = mean(floor_area, na.rm = TRUE),
  Pct_Detached = mean(property_type == "D") * 100,
  Pct_Semi = mean(property_type == "S") * 100,
  Pct_Terraced = mean(property_type == "T") * 100,
  Pct_Flat = mean(property_type == "F") * 100,
  Pct_NewBuild = mean(is_new) * 100,
  Pct_Rental = mean(is_rental, na.rm = TRUE) * 100,
  Pct_Owner = mean(is_owner, na.rm = TRUE) * 100
)]

fwrite(summ_all, file.path(TBL_DIR, "table1_summary_overall.csv"))

# LaTeX table
sink(file.path(TBL_DIR, "table1_summary.tex"))
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Summary Statistics by EPC Band}\n")
cat("\\label{tab:summary}\n")
cat("\\begin{adjustbox}{max width=\\textwidth}\n")
cat("\\begin{tabular}{lccccccc}\n")
cat("\\toprule\n")
cat(" & \\multicolumn{7}{c}{EPC Band} \\\\\n")
cat("\\cmidrule(lr){2-8}\n")
cat(" & G & F & E & D & C & B & A \\\\\n")
cat("\\midrule\n")

for (col_name in c("N", "Mean_Price", "Median_Price", "Mean_Score",
                    "Mean_FloorArea", "Pct_Flat", "Pct_NewBuild", "Pct_Rental")) {
  label <- switch(col_name,
    N = "Observations",
    Mean_Price = "Mean Price (\\pounds)",
    Median_Price = "Median Price (\\pounds)",
    Mean_Score = "Mean EPC Score",
    Mean_FloorArea = "Mean Floor Area (sq m)",
    Pct_Flat = "\\% Flats",
    Pct_NewBuild = "\\% New Build",
    Pct_Rental = "\\% Private Rental"
  )

  vals <- character(7)
  for (j in 1:7) {
    band <- c("G", "F", "E", "D", "C", "B", "A")[j]
    row <- summ_band[epc_band == band]
    if (nrow(row) == 0) {
      vals[j] <- "---"
    } else {
      v <- row[[col_name]]
      if (col_name == "N") {
        vals[j] <- format(v, big.mark = ",")
      } else if (col_name %in% c("Mean_Price", "Median_Price")) {
        vals[j] <- format(round(v), big.mark = ",")
      } else if (grepl("Pct_", col_name)) {
        vals[j] <- sprintf("%.1f", v)
      } else {
        vals[j] <- sprintf("%.1f", v)
      }
    }
  }

  cat(sprintf("%s & %s \\\\\n", label, paste(vals, collapse = " & ")))
}

cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\end{adjustbox}\n")
cat("\\begin{minipage}{\\textwidth}\n")
cat("\\footnotesize\n")
cat("\\textit{Notes:} Summary statistics for the matched EPC--Land Registry analysis sample, 2015--2025.\n")
cat("Transaction prices are in nominal pounds. EPC scores range from 1 (worst) to 100 (best).\n")
cat("Tenure classification from the EPC register's self-reported tenure field.\n")
cat("\\end{minipage}\n")
cat("\\end{table}\n")
sink()

###############################################################################
# Table 2: Main RDD Results (Multi-Cutoff)
###############################################################################

cat("Table 2: Main RDD results...\n")

main_results <- rdd_dt[period == "Overall" & tenure == "All"]
main_results[, boundary := factor(boundary, levels = EPC_BAND_NAMES)]

sink(file.path(TBL_DIR, "table2_main_rdd.tex"))
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{RDD Estimates at EPC Band Boundaries}\n")
cat("\\label{tab:main_rdd}\n")
cat("\\begin{tabular}{lccccc}\n")
cat("\\toprule\n")
cat(" & E/F & D/E & C/D & B/C & A/B \\\\\n")
cat(" & (39) & (55) & (69) & (81) & (92) \\\\\n")
cat("\\midrule\n")

for (b in EPC_BAND_NAMES) {
  row <- main_results[boundary == b]
  if (nrow(row) == 0) next

  # Stars
  stars <- ifelse(row$p_value < 0.01, "^{***}",
           ifelse(row$p_value < 0.05, "^{**}",
           ifelse(row$p_value < 0.1, "^{*}", "")))

  if (b == EPC_BAND_NAMES[1]) {
    cat(sprintf("Discontinuity & %.4f%s", row$estimate, stars))
  } else {
    cat(sprintf(" & %.4f%s", row$estimate, stars))
  }
}
cat(" \\\\\n")

# SEs
for (b in EPC_BAND_NAMES) {
  row <- main_results[boundary == b]
  if (nrow(row) == 0) next

  if (b == EPC_BAND_NAMES[1]) {
    cat(sprintf(" & (%.4f)", row$se_robust))
  } else {
    cat(sprintf(" & (%.4f)", row$se_robust))
  }
}
cat(" \\\\\n")

# Bandwidth
cat("\\midrule\n")
for (b in EPC_BAND_NAMES) {
  row <- main_results[boundary == b]
  if (nrow(row) == 0) next
  if (b == EPC_BAND_NAMES[1]) {
    cat(sprintf("Bandwidth & %.1f", row$bw_left))
  } else {
    cat(sprintf(" & %.1f", row$bw_left))
  }
}
cat(" \\\\\n")

# N effective
for (b in EPC_BAND_NAMES) {
  row <- main_results[boundary == b]
  if (nrow(row) == 0) next
  n_eff <- row$N_eff_left + row$N_eff_right
  if (b == EPC_BAND_NAMES[1]) {
    cat(sprintf("N (effective) & %s", format(n_eff, big.mark = ",")))
  } else {
    cat(sprintf(" & %s", format(n_eff, big.mark = ",")))
  }
}
cat(" \\\\\n")

cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{minipage}{\\textwidth}\n")
cat("\\footnotesize\n")
cat("\\textit{Notes:} Sharp RDD estimates of the log price discontinuity at each EPC band boundary.\n")
cat("Robust bias-corrected standard errors in parentheses (Calonico, Cattaneo \\& Titiunik, 2014).\n")
cat("MSE-optimal bandwidth with triangular kernel. Covariates: floor area, property type, new-build indicator.\n")
cat("$^{***}p<0.01$, $^{**}p<0.05$, $^{*}p<0.1$.\n")
cat("\\end{minipage}\n")
cat("\\end{table}\n")
sink()

###############################################################################
# Table 3: Period-Specific Estimates (Crisis Amplification)
###############################################################################

cat("Table 3: Period-specific estimates...\n")

period_results <- rdd_dt[tenure == "All" & period != "Overall" &
                           boundary %in% c("E/F", "D/E", "C/D")]

sink(file.path(TBL_DIR, "table3_crisis.tex"))
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{EPC Label Effects by Period: Crisis Amplification}\n")
cat("\\label{tab:crisis}\n")
cat("\\begin{tabular}{lcccc}\n")
cat("\\toprule\n")
cat(" & Pre-MEES & Post-MEES & Crisis & Post-Crisis \\\\\n")
cat(" & (2015--2018Q1) & (2018Q2--2021Q3) & (2021Q4--2023Q2) & (2023Q3--2025) \\\\\n")
cat("\\midrule\n")

for (bname in c("E/F", "D/E", "C/D")) {
  # Collect all periods in one row
  est_vals <- character(4)
  se_vals <- character(4)
  n_vals <- character(4)

  for (j in seq_along(PERIOD_LABELS)) {
    per <- PERIOD_LABELS[j]
    row <- period_results[boundary == bname & period == per]
    if (nrow(row) == 0) {
      est_vals[j] <- "---"
      se_vals[j] <- ""
      n_vals[j] <- "---"
    } else {
      stars <- ifelse(row$p_value < 0.01, "^{***}",
               ifelse(row$p_value < 0.05, "^{**}",
               ifelse(row$p_value < 0.1, "^{*}", "")))
      est_vals[j] <- sprintf("%.4f%s", row$estimate, stars)
      se_vals[j] <- sprintf("(%.4f)", row$se_robust)
      n_vals[j] <- format(row$N_eff_left + row$N_eff_right, big.mark = ",")
    }
  }

  cat(sprintf("\\textit{%s Boundary} & %s \\\\\n", bname, paste(est_vals, collapse = " & ")))
  cat(sprintf(" & %s \\\\\n", paste(se_vals, collapse = " & ")))
  cat(sprintf("\\quad $N$ (effective) & %s \\\\\n", paste(n_vals, collapse = " & ")))

  if (bname != "C/D") cat("\\addlinespace\n")
}

cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{minipage}{\\textwidth}\n")
cat("\\footnotesize\n")
cat("\\textit{Notes:} Separate RDD estimates by time period.\n")
cat("The energy crisis period (Oct 2021--Jun 2023) corresponds to UK wholesale gas prices exceeding \\pounds100/MWh.\n")
cat("See notes to Table \\ref{tab:main_rdd} for specification details.\n")
cat("$^{***}p<0.01$, $^{**}p<0.05$, $^{*}p<0.1$.\n")
cat("\\end{minipage}\n")
cat("\\end{table}\n")
sink()

###############################################################################
# Table 4: MEES Decomposition (Regulatory vs Informational)
###############################################################################

cat("Table 4: MEES decomposition...\n")

if (file.exists(file.path(DATA_DIR, "decomposition_results.csv"))) {
  decomp <- fread(file.path(DATA_DIR, "decomposition_results.csv"))

  sink(file.path(TBL_DIR, "table4_decomposition.tex"))
  cat("\\begin{table}[htbp]\n")
  cat("\\centering\n")
  cat("\\caption{Decomposition: Information vs Regulatory Effects at E/F Boundary}\n")
  cat("\\label{tab:decomposition}\n")
  cat("\\begin{tabular}{lcccc}\n")
  cat("\\toprule\n")
  cat(" & Pre-MEES & Post-MEES & Crisis & Post-Crisis \\\\\n")
  cat("\\midrule\n")

  cat("\\textit{Panel A: Components} & & & & \\\\\n")

  # E/F total effect - single row with all periods
  ef_vals <- character(4)
  ef_se_vals <- character(4)
  info_vals <- character(4)
  info_se_vals <- character(4)

  for (j in seq_along(PERIOD_LABELS)) {
    per <- PERIOD_LABELS[j]
    row <- decomp[period == per]
    if (nrow(row) == 0) {
      ef_vals[j] <- "---"
      ef_se_vals[j] <- ""
      info_vals[j] <- "---"
      info_se_vals[j] <- ""
    } else {
      ef_vals[j] <- sprintf("%.4f", row$ef_effect)
      ef_se_vals[j] <- sprintf("(%.4f)", row$ef_se)
      info_vals[j] <- sprintf("%.4f", row$info_effect)
      info_se_vals[j] <- sprintf("(%.4f)", row$info_se)
    }
  }

  cat(sprintf("\\quad E/F total effect & %s \\\\\n", paste(ef_vals, collapse = " & ")))
  cat(sprintf(" & %s \\\\\n", paste(ef_se_vals, collapse = " & ")))
  cat("\\addlinespace\n")
  cat(sprintf("\\quad Information effect & %s \\\\\n", paste(info_vals, collapse = " & ")))
  cat(sprintf(" & %s \\\\\n", paste(info_se_vals, collapse = " & ")))

  cat("\\addlinespace\n")
  cat("\\textit{Panel B: Regulatory effect} & & & & \\\\\n")

  # Regulatory effect - single row with all periods
  reg_vals <- character(4)
  reg_se_vals <- character(4)

  for (j in seq_along(PERIOD_LABELS)) {
    per <- PERIOD_LABELS[j]
    row <- decomp[period == per]
    if (nrow(row) == 0) {
      reg_vals[j] <- "---"
      reg_se_vals[j] <- ""
    } else {
      stars <- ifelse(row$reg_pval < 0.01, "^{***}",
               ifelse(row$reg_pval < 0.05, "^{**}",
               ifelse(row$reg_pval < 0.1, "^{*}", "")))
      reg_vals[j] <- sprintf("%.4f%s", row$reg_effect, stars)
      reg_se_vals[j] <- sprintf("(%.4f)", row$reg_se)
    }
  }

  cat(sprintf("\\quad E/F $-$ information & %s \\\\\n", paste(reg_vals, collapse = " & ")))
  cat(sprintf(" & %s \\\\\n", paste(reg_se_vals, collapse = " & ")))

  cat("\\bottomrule\n")
  cat("\\end{tabular}\n")
  cat("\\begin{minipage}{\\textwidth}\n")
  cat("\\footnotesize\n")
  cat("\\textit{Notes:} Panel A reports the total E/F discontinuity and the average information effect\n")
  cat("(mean of D/E and C/D discontinuities). Panel B reports the regulatory component:\n")
  cat("the E/F effect minus the average informational effect. Standard errors computed via\n")
  cat("propagation assuming independence across boundaries.\n")
  cat("$^{***}p<0.01$, $^{**}p<0.05$, $^{*}p<0.1$.\n")
  cat("\\end{minipage}\n")
  cat("\\end{table}\n")
  sink()
}

###############################################################################
# Table 5: McCrary Density Tests
###############################################################################

cat("Table 5: McCrary results...\n")

mccrary_dt <- fread(file.path(DATA_DIR, "mccrary_results.csv"))

sink(file.path(TBL_DIR, "table5_mccrary.tex"))
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{McCrary Density Tests at EPC Band Boundaries}\n")
cat("\\label{tab:mccrary}\n")
cat("\\begin{tabular}{lccccc}\n")
cat("\\toprule\n")
cat("Boundary & Cutoff & Test Statistic & $p$-value & $N_{\\text{left}}$ & $N_{\\text{right}}$ \\\\\n")
cat("\\midrule\n")

for (j in seq_len(nrow(mccrary_dt))) {
  row <- mccrary_dt[j]
  cat(sprintf("%s & %d & %.3f & %.4f & %s & %s \\\\\n",
              row$boundary, row$cutoff, row$test_stat, row$p_value,
              format(row$N_left, big.mark = ","),
              format(row$N_right, big.mark = ",")))
}

cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{minipage}{\\textwidth}\n")
cat("\\footnotesize\n")
cat("\\textit{Notes:} Density continuity tests from Cattaneo, Jansson \\& Ma (2020).\n")
cat("A significant $p$-value indicates potential manipulation/bunching at the threshold.\n")
cat("\\end{minipage}\n")
cat("\\end{table}\n")
sink()

cat("\nAll tables generated.\n")
