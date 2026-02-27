## =============================================================================
## 06_tables.R — All tables for the paper
## apep_0474: Downtown for Sale? ACV Commercial Displacement
##
## Tables:
##   1. Summary statistics (ACV vs Control)
##   2. Covariate balance (pre-treatment)
##   3. Main TWFE results
##   4. Event study pre-trend test
##   5. Robustness: alternative specifications
##   6. Heterogeneity by city size
## =============================================================================

source(file.path(dirname(sys.frame(1)$ofile %||% "code/06_tables.R"), "00_packages.R"))

panel <- fread(file.path(DATA, "panel_commune_quarter.csv"))
chars <- fread(file.path(DATA, "commune_characteristics.csv"))
results <- readRDS(file.path(DATA, "main_results.rds"))
robust <- readRDS(file.path(DATA, "robustness_results.rds"))

## ---- Table 1: Summary Statistics ----
cat("=== Table 1: Summary statistics ===\n")

summ <- panel[, .(
  `Quarterly Creations (Downtown)` = mean(n_creations, na.rm = TRUE),
  `SD Creations` = sd(n_creations, na.rm = TRUE),
  `Quarterly Creations (All)` = mean(n_creations_all, na.rm = TRUE),
  `Quarterly Creations (Wholesale)` = mean(n_creations_placebo, na.rm = TRUE),
  `N Commune-Quarters` = .N,
  `N Communes` = uniqueN(code_commune)
), by = .(Group = fifelse(acv == 1, "ACV", "Control"))]

# LaTeX table
tex1 <- "\\begin{table}[ht]\n\\centering\n\\caption{Summary Statistics}\n\\label{tab:summary}\n"
tex1 <- paste0(tex1, "\\begin{tabular}{lcccccc}\n\\toprule\n")
tex1 <- paste0(tex1, " & \\multicolumn{1}{c}{Mean Creations} & \\multicolumn{1}{c}{SD} & ",
               "\\multicolumn{1}{c}{All Sectors} & \\multicolumn{1}{c}{Wholesale} & ",
               "\\multicolumn{1}{c}{Commune-Qtrs} & \\multicolumn{1}{c}{Communes} \\\\\n")
tex1 <- paste0(tex1, " & (Downtown) & & & (Placebo) & & \\\\\n\\midrule\n")

for (i in 1:nrow(summ)) {
  tex1 <- paste0(tex1, sprintf("%s & %.2f & %.2f & %.2f & %.2f & %s & %d \\\\\n",
                               summ$Group[i],
                               summ$`Quarterly Creations (Downtown)`[i],
                               summ$`SD Creations`[i],
                               summ$`Quarterly Creations (All)`[i],
                               summ$`Quarterly Creations (Wholesale)`[i],
                               format(summ$`N Commune-Quarters`[i], big.mark = ","),
                               summ$`N Communes`[i]))
}

tex1 <- paste0(tex1, "\\bottomrule\n\\end{tabular}\n")
tex1 <- paste0(tex1, "\\begin{tablenotes}\\small\n")
tex1 <- paste0(tex1, "\\item \\textit{Notes:} Downtown-facing sectors include retail (NAF 47), ",
               "accommodation (NAF 55), food services (NAF 56), recreation (NAF 93), ",
               "and personal services (NAF 96). Wholesale (NAF 46) serves as placebo. ",
               "Panel covers 2010Q1--2024Q4.\n")
tex1 <- paste0(tex1, "\\end{tablenotes}\n\\end{table}")

writeLines(tex1, file.path(TAB, "tab1_summary.tex"))
cat("  Saved tab1_summary.tex\n")

## ---- Table 2: Covariate Balance ----
cat("=== Table 2: Covariate balance ===\n")

bal <- chars[!is.na(n_active), .(
  `Active Downtown Estab.` = mean(n_active, na.rm = TRUE),
  `Active All Estab.` = mean(n_active_all, na.rm = TRUE),
  `Annual Creations (Pre)` = mean(pre_creations_annual, na.rm = TRUE),
  N = .N
), by = .(Group = fifelse(acv == 1, "ACV", "Control"))]

tex2 <- "\\begin{table}[ht]\n\\centering\n\\caption{Pre-Treatment Covariate Balance}\n\\label{tab:balance}\n"
tex2 <- paste0(tex2, "\\begin{tabular}{lcccc}\n\\toprule\n")
tex2 <- paste0(tex2, " & Active Downtown & Active All & Annual Creations & N \\\\\n")
tex2 <- paste0(tex2, " & Establishments & Establishments & (2012--2017) & Communes \\\\\n\\midrule\n")

for (i in 1:nrow(bal)) {
  tex2 <- paste0(tex2, sprintf("%s & %.1f & %.1f & %.1f & %d \\\\\n",
                               bal$Group[i],
                               bal$`Active Downtown Estab.`[i],
                               bal$`Active All Estab.`[i],
                               bal$`Annual Creations (Pre)`[i],
                               bal$N[i]))
}

# Difference and t-test
if (nrow(bal) == 2) {
  # Simple t-tests on key variables
  acv_chars <- chars[acv == 1 & !is.na(n_active)]
  ctrl_chars <- chars[acv == 0 & !is.na(n_active)]

  t1 <- t.test(acv_chars$n_active, ctrl_chars$n_active)
  t2 <- t.test(acv_chars$n_active_all, ctrl_chars$n_active_all)
  t3 <- t.test(acv_chars$pre_creations_annual, ctrl_chars$pre_creations_annual)

  tex2 <- paste0(tex2, "\\midrule\n")
  tex2 <- paste0(tex2, sprintf("Difference & %.1f & %.1f & %.1f & \\\\\n",
                               t1$estimate[1] - t1$estimate[2],
                               t2$estimate[1] - t2$estimate[2],
                               t3$estimate[1] - t3$estimate[2]))
  tex2 <- paste0(tex2, sprintf("p-value & %.3f & %.3f & %.3f & \\\\\n",
                               t1$p.value, t2$p.value, t3$p.value))
}

tex2 <- paste0(tex2, "\\bottomrule\n\\end{tabular}\n")
tex2 <- paste0(tex2, "\\begin{tablenotes}\\small\n")
tex2 <- paste0(tex2, "\\item \\textit{Notes:} Pre-treatment characteristics computed from Sirene data (2012--2017). ",
               "p-values from two-sample t-tests.\n")
tex2 <- paste0(tex2, "\\end{tablenotes}\n\\end{table}")

writeLines(tex2, file.path(TAB, "tab2_balance.tex"))
cat("  Saved tab2_balance.tex\n")

## ---- Table 3: Main TWFE Results ----
cat("=== Table 3: Main results ===\n")

etable(
  results$twfe_level,
  results$twfe_log,
  results$twfe_deptyr,
  results$twfe_all,
  results$twfe_placebo,
  headers = c("Downtown", "Downtown (log)", "Dept×Year FE", "All Sectors", "Wholesale"),
  depvar = TRUE,
  se.below = TRUE,
  fitstat = c("n", "r2", "ar2"),
  dict = c(treat_post = "ACV × Post"),
  file = file.path(TAB, "tab3_main_results.tex"),
  replace = TRUE,
  style.tex = style.tex("aer"),
  title = "Effect of ACV on Establishment Creations",
  label = "tab:main",
  notes = c(
    "Standard errors clustered at commune level in parentheses.",
    "Downtown sectors: retail (47), accommodation (55), food services (56), recreation (93), personal services (96).",
    "Wholesale (46) is a placebo sector. Panel: 2010Q1--2024Q4."
  )
)
cat("  Saved tab3_main_results.tex\n")

## ---- Table 4: Period-Specific Effects ----
cat("=== Table 4: Period effects ===\n")

etable(
  results$twfe_periods,
  results$twfe_level,
  headers = c("Period-Specific", "Pooled"),
  depvar = TRUE,
  se.below = TRUE,
  fitstat = c("n", "r2"),
  dict = c(
    `acv:post_precovid` = "ACV × 2018--2019",
    `acv:post_covid` = "ACV × 2020--2021",
    `acv:post_recovery` = "ACV × 2022--2024",
    treat_post = "ACV × Post"
  ),
  file = file.path(TAB, "tab4_period_effects.tex"),
  replace = TRUE,
  style.tex = style.tex("aer"),
  title = "ACV Effect by Period: Pre-COVID, COVID, and Recovery",
  label = "tab:periods",
  notes = c(
    "Standard errors clustered at commune level in parentheses.",
    "Column 1 allows the ACV effect to vary across three post-treatment sub-periods.",
    "Column 2 pools all post-treatment quarters."
  )
)
cat("  Saved tab4_period_effects.tex\n")

## ---- Table 5: Robustness ----
cat("=== Table 5: Robustness specifications ===\n")

# Build model list — include PPML if available
rob_models <- list(results$twfe_level, robust$twfe_donut, robust$twfe_precovid)
rob_headers <- c("Baseline", "Donut", "Pre-COVID")

if (!is.null(robust$twfe_ppml)) {
  rob_models <- c(rob_models, list(robust$twfe_ppml))
  rob_headers <- c(rob_headers, "Poisson (PPML)")
}

etable(
  .list = rob_models,
  headers = rob_headers,
  depvar = TRUE,
  se.below = TRUE,
  fitstat = c("n", "r2"),
  dict = c(treat_post = "ACV × Post"),
  file = file.path(TAB, "tab5_robustness.tex"),
  replace = TRUE,
  style.tex = style.tex("aer"),
  title = "Robustness: Alternative Specifications",
  label = "tab:robust",
  notes = c(
    "Standard errors clustered at commune level in parentheses.",
    "Col. 2 drops 2018 (transition year). Col. 3 restricts to 2010--2019 (pre-COVID).",
    "Col. 4 estimates Poisson PPML with commune and quarter fixed effects.",
    sprintf("CR2 small-sample p-value for baseline: %.3f.",
            ifelse(!is.null(robust$boot_result), robust$boot_result$p_val, NA)),
    sprintf("Randomization inference p-value: %.3f (1,000 permutations).",
            robust$ri_pval)
  )
)
cat("  Saved tab5_robustness.tex\n")

cat("\nAll tables complete.\n")
