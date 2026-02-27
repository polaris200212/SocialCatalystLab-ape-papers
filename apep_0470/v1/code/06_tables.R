###############################################################################
# 06_tables.R — All tables for the paper
# The Unequal Legacies of the Tennessee Valley Authority
# APEP-0470
###############################################################################

source("code/00_packages.R")

has_individual <- file.exists(paste0(data_dir, "individual_panel_30_40.csv"))
has_county <- file.exists(paste0(data_dir, "county_panel.csv"))
has_results <- file.exists(paste0(data_dir, "main_results.rds"))
has_rob <- file.exists(paste0(data_dir, "robustness_results.rds"))

if (has_results) results <- readRDS(paste0(data_dir, "main_results.rds"))
if (has_rob) rob <- readRDS(paste0(data_dir, "robustness_results.rds"))

# ═══════════════════════════════════════════════════════════════════════════════
# TABLE 1: SUMMARY STATISTICS
# ═══════════════════════════════════════════════════════════════════════════════

if (has_county) {
  cp <- fread(paste0(data_dir, "county_panel.csv"))
  cp[is.na(tva_any), tva_any := FALSE]

  cat("Creating Table 1: Summary Statistics...\n")

  # Panel A: 1930 (pre-treatment) characteristics
  cp_1930 <- cp[year == 1930]

  summ_vars <- c("mean_sei", "pct_mfg", "pct_ag", "pct_farm", "pct_lf",
                  "pct_literate", "pct_owns_home", "pct_black", "pct_female",
                  "mean_age", "n_persons")
  summ_labels <- c("Mean SEI Score", "Manufacturing Share", "Agriculture Share",
                    "Farm Residence Share", "Labor Force Participation",
                    "Literacy Rate", "Home Ownership Rate",
                    "Black Population Share", "Female Share",
                    "Mean Age", "Population (county mean)")

  # Compute means and SDs by TVA status
  summ_tva <- cp_1930[tva_any == TRUE, lapply(.SD, function(x) {
    c(mean = mean(x, na.rm = TRUE), sd = sd(x, na.rm = TRUE))
  }), .SDcols = summ_vars]

  summ_nontva <- cp_1930[tva_any == FALSE, lapply(.SD, function(x) {
    c(mean = mean(x, na.rm = TRUE), sd = sd(x, na.rm = TRUE))
  }), .SDcols = summ_vars]

  # Build LaTeX table
  tab1_lines <- c(
    "\\begin{table}[htbp]",
    "\\centering",
    "\\caption{Summary Statistics: Pre-Treatment County Characteristics, 1930}",
    "\\label{tab:summary}",
    "\\begin{tabular}{lccccc}",
    "\\toprule",
    " & \\multicolumn{2}{c}{TVA Counties} & \\multicolumn{2}{c}{Non-TVA Counties} & Diff. \\\\",
    "\\cmidrule(lr){2-3} \\cmidrule(lr){4-5}",
    " & Mean & SD & Mean & SD & (p-value) \\\\",
    "\\midrule"
  )

  for (i in seq_along(summ_vars)) {
    v <- summ_vars[i]
    tva_m <- cp_1930[tva_any == TRUE, mean(get(v), na.rm = TRUE)]
    tva_sd <- cp_1930[tva_any == TRUE, sd(get(v), na.rm = TRUE)]
    ntva_m <- cp_1930[tva_any == FALSE, mean(get(v), na.rm = TRUE)]
    ntva_sd <- cp_1930[tva_any == FALSE, sd(get(v), na.rm = TRUE)]
    tt <- tryCatch(t.test(cp_1930[tva_any == TRUE, get(v)],
                          cp_1930[tva_any == FALSE, get(v)])$p.value,
                   error = function(e) NA)

    if (v == "n_persons") {
      tab1_lines <- c(tab1_lines, sprintf(
        "%s & %s & %s & %s & %s & %s \\\\",
        summ_labels[i],
        format(round(tva_m), big.mark = ","),
        format(round(tva_sd), big.mark = ","),
        format(round(ntva_m), big.mark = ","),
        format(round(ntva_sd), big.mark = ","),
        ifelse(is.na(tt), "--", sprintf("%.3f", tt))
      ))
    } else {
      tab1_lines <- c(tab1_lines, sprintf(
        "%s & %.3f & %.3f & %.3f & %.3f & %s \\\\",
        summ_labels[i], tva_m, tva_sd, ntva_m, ntva_sd,
        ifelse(is.na(tt), "--", sprintf("%.3f", tt))
      ))
    }
  }

  n_tva <- sum(cp_1930$tva_any)
  n_ntva <- sum(!cp_1930$tva_any)

  tab1_lines <- c(tab1_lines,
    "\\midrule",
    sprintf("Counties & \\multicolumn{2}{c}{%d} & \\multicolumn{2}{c}{%d} & \\\\",
            n_tva, n_ntva),
    "\\bottomrule",
    "\\end{tabular}",
    "\\begin{minipage}{0.95\\textwidth}",
    "\\vspace{0.5em}",
    "\\footnotesize",
    "\\textit{Notes:} Summary statistics for county-level outcomes in 1930, the last pre-treatment census year before TVA creation in 1933. TVA counties are defined as counties in TVA service-area states within 150 km of a TVA dam site. p-values from two-sample t-tests of equal means.",
    "\\end{minipage}",
    "\\end{table}"
  )

  writeLines(tab1_lines, paste0(table_dir, "tab1_summary.tex"))
  cat("✓ Table 1 saved\n")
}

# ═══════════════════════════════════════════════════════════════════════════════
# TABLE 2: MAIN DiD RESULTS
# ═══════════════════════════════════════════════════════════════════════════════

if (has_results && !is.null(results$a1_main)) {
  cat("Creating Table 2: Main DiD Results...\n")

  etable(results$a1_main$mfg, results$a1_main$ag, results$a1_main$sei,
         results$a1_main$lf, results$a1_main$home,
         headers = c("Mfg Share", "Ag Share", "Mean SEI", "LFP", "Home Own"),
         tex = TRUE,
         file = paste0(table_dir, "tab2_main_did.tex"),
         title = "The TVA Effect: County-Level Difference-in-Differences",
         label = "tab:main_did",
         notes = "All regressions include county and year fixed effects. Standard errors clustered at the state level in parentheses. TVA $\\times$ Post is an indicator for TVA counties in the 1940 census. The sample includes counties in TVA service-area states and buffer states. * p < 0.10, ** p < 0.05, *** p < 0.01.",
         style.tex = style.tex("aer"))

  cat("✓ Table 2 saved\n")
}

# ═══════════════════════════════════════════════════════════════════════════════
# TABLE 3: RACE × TVA INTERACTION
# ═══════════════════════════════════════════════════════════════════════════════

if (has_results && !is.null(results$a4_race)) {
  cat("Creating Table 3: Race × TVA Interaction...\n")

  etable(results$a4_race$sei, results$a4_race$mfg,
         headers = c("SEI Score", "Mfg Share"),
         tex = TRUE,
         file = paste0(table_dir, "tab3_race_interaction.tex"),
         title = "Unequal Benefits: TVA Effects by Race",
         label = "tab:race",
         notes = "Triple-difference specification: TVA $\\times$ Post captures the average TVA effect; TVA $\\times$ Post $\\times$ Black captures the differential effect for Black residents. County$\\times$race and year fixed effects included. Standard errors clustered at the state level. * p < 0.10, ** p < 0.05, *** p < 0.01.",
         style.tex = style.tex("aer"))

  cat("✓ Table 3 saved\n")
}

# ═══════════════════════════════════════════════════════════════════════════════
# TABLE 4: GENDER × TVA INTERACTION
# ═══════════════════════════════════════════════════════════════════════════════

if (has_results && !is.null(results$a5_gender)) {
  cat("Creating Table 4: Gender × TVA Interaction...\n")

  etable(results$a5_gender$lf, results$a5_gender$sei,
         headers = c("LFP Rate", "SEI Score"),
         tex = TRUE,
         file = paste0(table_dir, "tab4_gender_interaction.tex"),
         title = "TVA and Women's Economic Lives",
         label = "tab:gender",
         notes = "Triple-difference specification: TVA $\\times$ Post $\\times$ Female captures the differential effect for women. County$\\times$gender and year fixed effects included. Standard errors clustered at the state level. * p < 0.10, ** p < 0.05, *** p < 0.01.",
         style.tex = style.tex("aer"))

  cat("✓ Table 4 saved\n")
}

# ═══════════════════════════════════════════════════════════════════════════════
# TABLE 5: DISTANCE GRADIENT
# ═══════════════════════════════════════════════════════════════════════════════

if (has_results && !is.null(results$a2_gradient)) {
  cat("Creating Table 5: Distance Gradient...\n")

  etable(results$a2_gradient$mfg, results$a2_gradient$sei, results$a2_gradient$ag,
         headers = c("Mfg Share", "Mean SEI", "Ag Share"),
         tex = TRUE,
         file = paste0(table_dir, "tab5_gradient.tex"),
         title = "How Far Does the Valley Reach? Distance Gradient Estimates",
         label = "tab:gradient",
         notes = "Sample restricted to TVA service-area states. Post $\\times$ log(Distance to Dam) captures how effects decay with distance from TVA infrastructure. County and year fixed effects included. Standard errors clustered at the state level. * p < 0.10, ** p < 0.05, *** p < 0.01.",
         style.tex = style.tex("aer"))

  cat("✓ Table 5 saved\n")
}

# ═══════════════════════════════════════════════════════════════════════════════
# TABLE 6: ROBUSTNESS SUMMARY
# ═══════════════════════════════════════════════════════════════════════════════

if (has_rob && has_results) {
  cat("Creating Table 6: Robustness Summary...\n")

  # Collect results across specifications
  rob_rows <- list()

  # Main estimate
  if (!is.null(results$a1_main$mfg)) {
    rob_rows[[1]] <- data.table(
      spec = "Main DiD (all counties)",
      coef = round(coef(results$a1_main$mfg), 4),
      se = round(se(results$a1_main$mfg), 4),
      n = nobs(results$a1_main$mfg)
    )
  }

  # Border counties
  if (!is.null(results$a3_border$mfg)) {
    rob_rows[[2]] <- data.table(
      spec = "Border counties only",
      coef = round(coef(results$a3_border$mfg), 4),
      se = round(se(results$a3_border$mfg), 4),
      n = nobs(results$a3_border$mfg)
    )
  }

  # Donut
  if (!is.null(rob$r2_donut$mfg)) {
    rob_rows[[3]] <- data.table(
      spec = "Donut (exclude 100-200km)",
      coef = round(coef(rob$r2_donut$mfg), 4),
      se = round(se(rob$r2_donut$mfg), 4),
      n = nobs(rob$r2_donut$mfg)
    )
  }

  # Pre-trend (placebo)
  if (!is.null(rob$r1_pretrend$mfg)) {
    rob_rows[[4]] <- data.table(
      spec = "Pre-trend placebo (1920-1930)",
      coef = round(coef(rob$r1_pretrend$mfg), 4),
      se = round(se(rob$r1_pretrend$mfg), 4),
      n = nobs(rob$r1_pretrend$mfg)
    )
  }

  rob_tab <- rbindlist(rob_rows, fill = TRUE)

  # Write LaTeX
  tab6_lines <- c(
    "\\begin{table}[htbp]",
    "\\centering",
    "\\caption{Robustness of Main TVA Effect on Manufacturing Share}",
    "\\label{tab:robustness}",
    "\\begin{tabular}{lccc}",
    "\\toprule",
    "Specification & Coefficient & SE & N \\\\",
    "\\midrule"
  )

  for (i in seq_len(nrow(rob_tab))) {
    tab6_lines <- c(tab6_lines, sprintf(
      "%s & %.4f & (%.4f) & %s \\\\",
      rob_tab$spec[i], rob_tab$coef[i], rob_tab$se[i],
      format(rob_tab$n[i], big.mark = ",")
    ))
  }

  # Add RI and bootstrap p-values
  if (!is.null(rob$r5_ri)) {
    tab6_lines <- c(tab6_lines, "\\midrule",
      sprintf("Randomization inference p-value & \\multicolumn{3}{c}{%.3f} \\\\",
              rob$r5_ri$ri_p))
  }
  if (!is.null(rob$r4_bootstrap)) {
    tab6_lines <- c(tab6_lines,
      sprintf("Wild cluster bootstrap p-value & \\multicolumn{3}{c}{%.3f} \\\\",
              rob$r4_bootstrap$boot_p))
  }

  tab6_lines <- c(tab6_lines,
    "\\bottomrule",
    "\\end{tabular}",
    "\\begin{minipage}{0.95\\textwidth}",
    "\\vspace{0.5em}",
    "\\footnotesize",
    "\\textit{Notes:} All specifications include county and year fixed effects with state-clustered standard errors. The dependent variable is manufacturing employment share. Row 1 is the baseline from Table \\ref{tab:main_did}. Border counties restricts to TVA core and adjacent non-TVA counties. The donut excludes counties in the 100--200 km ambiguous zone. The pre-trend placebo uses only 1920 and 1930 (both pre-TVA). Randomization inference permutes TVA assignment across counties (500 permutations). Wild cluster bootstrap uses Rademacher weights at the state level (999 replications).",
    "\\end{minipage}",
    "\\end{table}"
  )

  writeLines(tab6_lines, paste0(table_dir, "tab6_robustness.tex"))
  cat("✓ Table 6 saved\n")
}

# ═══════════════════════════════════════════════════════════════════════════════
# TABLE 7: INDIVIDUAL-LEVEL RESULTS (if MLP available)
# ═══════════════════════════════════════════════════════════════════════════════

if (has_results && !is.null(results$b1_main)) {
  cat("Creating Table 7: Individual-Level Results...\n")

  etable(results$b1_main$sei, results$b1_main$mfg, results$b1_main$left_ag,
         headers = c("ΔSEI", "Entered Mfg", "Left Ag"),
         tex = TRUE,
         file = paste0(table_dir, "tab7_individual.tex"),
         title = "Individual-Level TVA Effects: Linked Census Panel, 1930--1940",
         label = "tab:individual",
         notes = "Individual change regressions: $\\Delta Y_i = \\alpha + \\beta \\text{TVA}_c + X_i'\\delta + \\epsilon_i$. The sample consists of individuals linked across the 1930 and 1940 censuses via the IPUMS Multigenerational Longitudinal Panel (MLP v2.0). TVA is an indicator for residing in a TVA service-area county in 1930. Controls include age, age squared, and state fixed effects. Standard errors clustered at the 1930 state of residence. * p < 0.10, ** p < 0.05, *** p < 0.01.",
         style.tex = style.tex("aer"))

  cat("✓ Table 7 saved\n")
}

cat("\n✓ All tables generated.\n")
cat("  Files in tables/:\n")
for (f in list.files(table_dir, pattern = "\\.tex$")) cat("    -", f, "\n")
