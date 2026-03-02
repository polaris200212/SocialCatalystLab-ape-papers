## ============================================================================
## 06_tables.R — All table generation
## apep_0448: Early UI Termination and Medicaid HCBS Provider Supply
## ============================================================================

source("00_packages.R")

DATA <- "../data"
TABLES <- "../tables"
dir.create(TABLES, showWarnings = FALSE, recursive = TRUE)

hcbs <- readRDS(file.path(DATA, "hcbs_analysis.rds"))
bh <- readRDS(file.path(DATA, "bh_analysis.rds"))
results <- readRDS(file.path(DATA, "main_results.rds"))
robust <- readRDS(file.path(DATA, "robustness_results.rds"))
ui_term <- readRDS(file.path(DATA, "ui_termination.rds"))
chars <- readRDS(file.path(DATA, "state_characteristics.rds"))

## ---- Table 1: State treatment timing ----
cat("Table 1: Treatment timing...\n")

timing_tab <- ui_term[, .(state, termination_date,
                           first_full_month = format(first_full_month, "%B %Y"))]
setorder(timing_tab, termination_date, state)
timing_tab[, termination_date := format(termination_date, "%B %d, %Y")]

timing_latex <- paste0(
  "\\begin{table}[htbp]\n",
  "\\centering\n",
  "\\caption{Early Termination of Federal Pandemic Unemployment Benefits}\n",
  "\\label{tab:treatment_timing}\n",
  "\\begin{tabular}{llc}\n",
  "\\hline\\hline\n",
  "State & Termination Date & First Full Month \\\\\n",
  "\\hline\n"
)

for (i in 1:nrow(timing_tab)) {
  timing_latex <- paste0(timing_latex,
    timing_tab$state[i], " & ", timing_tab$termination_date[i], " & ",
    timing_tab$first_full_month[i], " \\\\\n")
}

timing_latex <- paste0(timing_latex,
  "\\hline\n",
  "\\multicolumn{3}{p{10cm}}{\\footnotesize ",
  "\\textit{Notes:} Twenty-six states voluntarily terminated the \\$300/week Federal Pandemic ",
  "Unemployment Compensation (FPUC) supplement before the federal expiration date of ",
  "September 6, 2021. Source: Ballotpedia.} \\\\\n",
  "\\hline\\hline\n",
  "\\end{tabular}\n",
  "\\end{table}\n"
)

writeLines(timing_latex, file.path(TABLES, "tab1_timing.tex"))

## ---- Table 2: Summary statistics ----
cat("Table 2: Summary statistics...\n")

# Pre-treatment means by group
pre_stats <- hcbs[month_date < as.Date("2021-06-01"), .(
  mean_providers = mean(n_providers),
  sd_providers = sd(n_providers),
  mean_claims = mean(total_claims),
  sd_claims = sd(total_claims),
  mean_paid = mean(total_paid),
  sd_paid = sd(total_paid),
  mean_benes = mean(total_benes),
  sd_benes = sd(total_benes)
), by = early_terminator]

# BH pre-treatment for comparison
bh_pre_stats <- bh[month_date < as.Date("2021-06-01"), .(
  bh_mean_providers = mean(n_providers),
  bh_sd_providers = sd(n_providers)
), by = early_terminator]

summary_latex <- paste0(
  "\\begin{table}[htbp]\n",
  "\\centering\n",
  "\\caption{Summary Statistics: Pre-Treatment Period (January 2018 -- May 2021)}\n",
  "\\label{tab:summary_stats}\n",
  "\\begin{tabular}{lcccc}\n",
  "\\hline\\hline\n",
  " & \\multicolumn{2}{c}{Early Terminators} & \\multicolumn{2}{c}{Maintained Benefits} \\\\\n",
  " & Mean & SD & Mean & SD \\\\\n",
  "\\hline\n",
  "\\multicolumn{5}{l}{\\textit{Panel A: HCBS (T/S-codes)}} \\\\\n",
  sprintf("Active providers & %s & %s & %s & %s \\\\\n",
          format(round(pre_stats[early_terminator == TRUE, mean_providers]), big.mark = ","),
          format(round(pre_stats[early_terminator == TRUE, sd_providers]), big.mark = ","),
          format(round(pre_stats[early_terminator == FALSE, mean_providers]), big.mark = ","),
          format(round(pre_stats[early_terminator == FALSE, sd_providers]), big.mark = ",")),
  sprintf("Total claims & %s & %s & %s & %s \\\\\n",
          format(round(pre_stats[early_terminator == TRUE, mean_claims]), big.mark = ","),
          format(round(pre_stats[early_terminator == TRUE, sd_claims]), big.mark = ","),
          format(round(pre_stats[early_terminator == FALSE, mean_claims]), big.mark = ","),
          format(round(pre_stats[early_terminator == FALSE, sd_claims]), big.mark = ",")),
  sprintf("Total paid (\\$M) & %.1f & %.1f & %.1f & %.1f \\\\\n",
          pre_stats[early_terminator == TRUE, mean_paid] / 1e6,
          pre_stats[early_terminator == TRUE, sd_paid] / 1e6,
          pre_stats[early_terminator == FALSE, mean_paid] / 1e6,
          pre_stats[early_terminator == FALSE, sd_paid] / 1e6),
  sprintf("Unique beneficiaries & %s & %s & %s & %s \\\\\n",
          format(round(pre_stats[early_terminator == TRUE, mean_benes]), big.mark = ","),
          format(round(pre_stats[early_terminator == TRUE, sd_benes]), big.mark = ","),
          format(round(pre_stats[early_terminator == FALSE, mean_benes]), big.mark = ","),
          format(round(pre_stats[early_terminator == FALSE, sd_benes]), big.mark = ",")),
  "\\hline\n",
  "\\multicolumn{5}{l}{\\textit{Panel B: Behavioral Health (H-codes)}} \\\\\n",
  sprintf("Active providers & %s & %s & %s & %s \\\\\n",
          format(round(bh_pre_stats[early_terminator == TRUE, bh_mean_providers]), big.mark = ","),
          format(round(bh_pre_stats[early_terminator == TRUE, bh_sd_providers]), big.mark = ","),
          format(round(bh_pre_stats[early_terminator == FALSE, bh_mean_providers]), big.mark = ","),
          format(round(bh_pre_stats[early_terminator == FALSE, bh_sd_providers]), big.mark = ",")),
  "\\hline\n",
  sprintf("N states & 26 & & 25 & \\\\\n"),
  sprintf("N months & 41 & & 41 & \\\\\n"),
  "\\hline\\hline\n",
  "\\multicolumn{5}{p{12cm}}{\\footnotesize ",
  "\\textit{Notes:} Pre-treatment period is January 2018 through May 2021 (41 months). ",
  "HCBS providers are those billing T-codes (personal care, habilitation, attendant care) ",
  "or S-codes (S5125, S5130, S5150) to Medicaid. Behavioral health providers bill H-codes. ",
  "Data source: T-MSIS Medicaid Provider Spending (HHS).} \\\\\n",
  "\\end{tabular}\n",
  "\\end{table}\n"
)

writeLines(summary_latex, file.path(TABLES, "tab2_summary.tex"))

## ---- Table 3: Main results ----
cat("Table 3: Main results...\n")

cs_agg <- results$cs_agg
twfe <- results$twfe

# Helper: significance stars from z-test on CS-DiD ATT
cs_stars <- function(att, se) {
  p <- 2 * pnorm(-abs(att / se))
  if (p < 0.01) return("***")
  if (p < 0.05) return("**")
  if (p < 0.10) return("*")
  return("")
}

# Helper: format CI from normal approximation
fmt_ci <- function(att, se) {
  lo <- att - 1.96 * se
  hi <- att + 1.96 * se
  # Use $-$ for negative numbers in LaTeX
  fmt_num <- function(x) {
    if (x < 0) sprintf("$-$%.3f", abs(x))
    else sprintf("%.3f", x)
  }
  sprintf("[%s, %s]", fmt_num(lo), fmt_num(hi))
}

# Helper: TWFE significance stars
twfe_stars <- function(fit) {
  p <- coeftable(fit)[, "Pr(>|t|)"]
  if (p < 0.01) return("***")
  if (p < 0.05) return("**")
  if (p < 0.10) return("*")
  return("")
}

main_latex <- paste0(
  "\\begin{table}[htbp]\n",
  "\\centering\n",
  "\\caption{Effect of Early UI Termination on HCBS Provider Supply}\n",
  "\\label{tab:main_results}\n",
  "\\begin{tabular}{lcccc}\n",
  "\\hline\\hline\n",
  " & (1) & (2) & (3) & (4) \\\\\n",
  " & Log Providers & Log Claims & Log Paid & Log Beneficiaries \\\\\n",
  "\\hline\n",
  "\\multicolumn{5}{l}{\\textit{Panel A: Callaway-Sant'Anna (2021)}} \\\\\n",
  sprintf("ATT & %.4f%s & %.4f%s & %.4f%s & %.4f%s \\\\\n",
          cs_agg$providers$overall.att, cs_stars(cs_agg$providers$overall.att, cs_agg$providers$overall.se),
          cs_agg$claims$overall.att, cs_stars(cs_agg$claims$overall.att, cs_agg$claims$overall.se),
          cs_agg$paid$overall.att, cs_stars(cs_agg$paid$overall.att, cs_agg$paid$overall.se),
          cs_agg$benes$overall.att, cs_stars(cs_agg$benes$overall.att, cs_agg$benes$overall.se)),
  sprintf(" & (%.4f) & (%.4f) & (%.4f) & (%.4f) \\\\\n",
          cs_agg$providers$overall.se, cs_agg$claims$overall.se,
          cs_agg$paid$overall.se, cs_agg$benes$overall.se),
  sprintf("95\\%% CI & %s & %s & %s & %s \\\\\n",
          fmt_ci(cs_agg$providers$overall.att, cs_agg$providers$overall.se),
          fmt_ci(cs_agg$claims$overall.att, cs_agg$claims$overall.se),
          fmt_ci(cs_agg$paid$overall.att, cs_agg$paid$overall.se),
          fmt_ci(cs_agg$benes$overall.att, cs_agg$benes$overall.se)),
  "[6pt]\n",
  "\\multicolumn{5}{l}{\\textit{Panel B: Two-Way Fixed Effects}} \\\\\n",
  sprintf("Early Term $\\times$ Post & %.4f%s & %.4f%s & %.4f%s & %.4f%s \\\\\n",
          coef(twfe$providers), twfe_stars(twfe$providers),
          coef(twfe$claims), twfe_stars(twfe$claims),
          coef(twfe$paid), twfe_stars(twfe$paid),
          coef(twfe$benes), twfe_stars(twfe$benes)),
  sprintf(" & (%.4f) & (%.4f) & (%.4f) & (%.4f) \\\\\n",
          se(twfe$providers), se(twfe$claims),
          se(twfe$paid), se(twfe$benes)),
  "[6pt]\n",
  "\\multicolumn{5}{l}{\\textit{Panel C: Placebo (Behavioral Health)}} \\\\\n",
  sprintf("ATT (CS) & %.4f%s & --- & --- & --- \\\\\n",
          cs_agg$bh_placebo$overall.att, cs_stars(cs_agg$bh_placebo$overall.att, cs_agg$bh_placebo$overall.se)),
  sprintf(" & (%.4f) & & & \\\\\n", cs_agg$bh_placebo$overall.se),
  "\\hline\n",
  "State FE & Yes & Yes & Yes & Yes \\\\\n",
  "Month FE & Yes & Yes & Yes & Yes \\\\\n",
  sprintf("States & %d & %d & %d & %d \\\\\n",
          uniqueN(hcbs$state), uniqueN(hcbs$state), uniqueN(hcbs$state), uniqueN(hcbs$state)),
  sprintf("Observations & %s & %s & %s & %s \\\\\n",
          format(nrow(hcbs), big.mark = ","), format(nrow(hcbs), big.mark = ","),
          format(nrow(hcbs), big.mark = ","), format(nrow(hcbs), big.mark = ",")),
  "\\hline\\hline\n",
  "\\multicolumn{5}{p{13cm}}{\\footnotesize ",
  "\\textit{Notes:} Panel A reports the Callaway and Sant'Anna (2021) simple aggregated ATT ",
  "using never-treated states as the comparison group with doubly robust estimation. ",
  "95\\% confidence intervals from multiplier bootstrap (1,000 iterations). ",
  "Panel B reports standard TWFE estimates with state-clustered standard errors. ",
  "Panel C shows the placebo test using behavioral health providers (H-codes); only the provider count outcome is estimated for the placebo (--- indicates not estimated). ",
  "* $p<0.10$, ** $p<0.05$, *** $p<0.01$.} \\\\\n",
  "\\end{tabular}\n",
  "\\end{table}\n"
)

writeLines(main_latex, file.path(TABLES, "tab3_main_results.tex"))

## ---- Table 4: Robustness ----
cat("Table 4: Robustness...\n")

robust_latex <- paste0(
  "\\begin{table}[htbp]\n",
  "\\centering\n",
  "\\caption{Robustness Checks: Effect on Log Active HCBS Providers}\n",
  "\\label{tab:robustness}\n",
  "\\begin{tabular}{lcccc}\n",
  "\\hline\\hline\n",
  " & Estimate & SE & States & Notes \\\\\n",
  "\\hline\n",
  sprintf("Baseline TWFE & %.4f & %.4f & 51 & \\\\\n",
          coef(twfe$providers), se(twfe$providers)),
  sprintf("CS-DiD ATT & %.4f & %.4f & 51 & Never-treated comparison \\\\\n",
          cs_agg$providers$overall.att, cs_agg$providers$overall.se),
  sprintf("South only & %.4f & %.4f & %d & Within-region \\\\\n",
          coef(robust$south_only), se(robust$south_only),
          uniqueN(hcbs[state %in% c("AL","AR","DE","DC","FL","GA","KY","LA","MD","MS","NC","OK","SC","TN","TX","VA","WV"), state])),
  sprintf("Midwest only & %.4f & %.4f & %d & Within-region \\\\\n",
          coef(robust$midwest_only), se(robust$midwest_only),
          uniqueN(hcbs[state %in% c("IA","IL","IN","KS","MI","MN","MO","ND","NE","OH","SD","WI"), state])),
  sprintf("Excl. NY, CA & %.4f & %.4f & 49 & Drop large states \\\\\n",
          coef(robust$no_outliers), se(robust$no_outliers)),
  sprintf("Placebo (2019) & %.4f & %.4f & 51 & Pre-COVID only \\\\\n",
          coef(robust$placebo_2019), se(robust$placebo_2019)),
  sprintf("RI (CS-DiD) & \\multicolumn{2}{c}{$p = %.3f$} & 51 & %d permutations \\\\\n",
          robust$ri_pvalue_cs, length(robust$ri_distribution_cs)),
  sprintf("RI (TWFE) & \\multicolumn{2}{c}{$p = %.3f$} & 51 & %d permutations \\\\\n",
          robust$ri_pvalue, length(robust$ri_distribution)),
  "\\hline\n",
  "\\multicolumn{5}{l}{\\textit{Intensive margin}} \\\\\n",
  sprintf("Claims/provider & %.4f & %.4f & 51 & TWFE \\\\\n",
          coef(twfe$intensive), se(twfe$intensive)),
  sprintf("Benes/provider & %.4f & %.4f & 51 & TWFE \\\\\n",
          coef(robust$intensive_benes), se(robust$intensive_benes)),
  "\\hline\\hline\n",
  "\\multicolumn{5}{p{13cm}}{\\footnotesize ",
  "\\textit{Notes:} All specifications include state and month fixed effects with ",
  "state-clustered standard errors. ``South'' includes AL, AR, DE, DC, FL, GA, KY, LA, ",
  "MD, MS, NC, OK, SC, TN, TX, VA, WV. ``Midwest'' includes IA, IL, IN, KS, MI, MN, ",
  "MO, ND, NE, OH, SD, WI. Placebo shifts treatment timing two years earlier and restricts ",
  "to the pre-COVID period (through February 2020). ",
  "Randomization inference permutes treatment assignment across states. ",
  "CS-DiD RI re-estimates the Callaway-Sant'Anna ATT under each permutation.} \\\\\n",
  "\\end{tabular}\n",
  "\\end{table}\n"
)

writeLines(robust_latex, file.path(TABLES, "tab4_robustness.tex"))

## ---- Table 5: Triple-Diff ----
cat("Table 5: Triple-diff...\n")

ddd <- robust$triple_diff

ddd_latex <- paste0(
  "\\begin{table}[htbp]\n",
  "\\centering\n",
  "\\caption{Triple-Difference: HCBS vs.\\ Behavioral Health}\n",
  "\\label{tab:triple_diff}\n",
  "\\begin{tabular}{lc}\n",
  "\\hline\\hline\n",
  " & Log Active Providers \\\\\n",
  "\\hline\n"
)

coef_names <- names(coef(ddd))
for (i in seq_along(coef_names)) {
  clean_name <- gsub(":", " $\\\\times$ ", coef_names[i])
  clean_name <- gsub("early_terminatorTRUE", "EarlyTerm", clean_name)
  clean_name <- gsub("is_hcbs", "HCBS", clean_name)
  clean_name <- gsub("post", "Post", clean_name)
  stars <- ""
  p <- coeftable(ddd)[, "Pr(>|t|)"][i]
  if (!is.na(p)) {
    if (p < 0.01) stars <- "***"
    else if (p < 0.05) stars <- "**"
    else if (p < 0.10) stars <- "*"
  }
  ddd_latex <- paste0(ddd_latex,
    sprintf("%s & %.4f%s \\\\\n", clean_name, coef(ddd)[i], stars),
    sprintf(" & (%.4f) \\\\\n", se(ddd)[i]))
}

ddd_latex <- paste0(ddd_latex,
  "\\hline\n",
  "State $\\times$ Service FE & Yes \\\\\n",
  "Service $\\times$ Month FE & Yes \\\\\n",
  "State $\\times$ Month FE & Yes \\\\\n",
  sprintf("Observations & %s \\\\\n", format(nobs(ddd), big.mark = ",")),
  "\\hline\\hline\n",
  "\\multicolumn{2}{p{10cm}}{\\footnotesize ",
  "\\textit{Notes:} Triple-difference specification comparing HCBS (T/S-codes) to ",
  "behavioral health (H-codes), before vs.\\ after July 2021, in early-terminating vs.\\ ",
  "non-terminating states. The triple interaction (EarlyTerm $\\times$ HCBS $\\times$ Post) ",
  "captures the differential effect of UI termination on low-wage HCBS providers relative ",
  "to higher-wage behavioral health providers. State-clustered standard errors in parentheses. ",
  "* $p<0.10$, ** $p<0.05$, *** $p<0.01$.} \\\\\n",
  "\\end{tabular}\n",
  "\\end{table}\n"
)

writeLines(ddd_latex, file.path(TABLES, "tab5_triple_diff.tex"))

## ---- Table 6: Entity Type Decomposition ----
cat("Table 6: Entity type decomposition...\n")

ent <- readRDS(file.path(DATA, "entity_type_results.rds"))

if (!is.null(ent$cs_type1_agg) && !is.null(ent$cs_type2_agg)) {
  # Pre-treatment provider counts for context
  type1 <- readRDS(file.path(DATA, "hcbs_type1.rds"))
  type2 <- readRDS(file.path(DATA, "hcbs_type2.rds"))
  pre_t1_treated <- type1[early_terminator == TRUE & month_date < as.Date("2021-06-01"),
                           .(mean_prov = mean(n_providers))]$mean_prov
  pre_t2_treated <- type2[early_terminator == TRUE & month_date < as.Date("2021-06-01"),
                           .(mean_prov = mean(n_providers))]$mean_prov

  entity_latex <- paste0(
    "\\begin{table}[htbp]\n",
    "\\centering\n",
    "\\caption{Entity Type Decomposition: Individual vs.\\ Organizational NPIs}\n",
    "\\label{tab:entity_type}\n",
    "\\begin{tabular}{lccc}\n",
    "\\hline\\hline\n",
    " & (1) All & (2) Individual & (3) Organization \\\\\n",
    " & NPIs & (Type 1) & (Type 2) \\\\\n",
    "\\hline\n",
    "\\multicolumn{4}{l}{\\textit{Panel A: CS-DiD ATT (Log Providers)}} \\\\\n",
    sprintf("ATT & %.4f%s & %.4f%s & %.4f%s \\\\\n",
            cs_agg$providers$overall.att,
            cs_stars(cs_agg$providers$overall.att, cs_agg$providers$overall.se),
            ent$cs_type1_agg$overall.att,
            cs_stars(ent$cs_type1_agg$overall.att, ent$cs_type1_agg$overall.se),
            ent$cs_type2_agg$overall.att,
            cs_stars(ent$cs_type2_agg$overall.att, ent$cs_type2_agg$overall.se)),
    sprintf(" & (%.4f) & (%.4f) & (%.4f) \\\\\n",
            cs_agg$providers$overall.se,
            ent$cs_type1_agg$overall.se,
            ent$cs_type2_agg$overall.se),
    sprintf("95\\%% CI & %s & %s & %s \\\\\n",
            fmt_ci(cs_agg$providers$overall.att, cs_agg$providers$overall.se),
            fmt_ci(ent$cs_type1_agg$overall.att, ent$cs_type1_agg$overall.se),
            fmt_ci(ent$cs_type2_agg$overall.att, ent$cs_type2_agg$overall.se)),
    "[6pt]\n",
    "\\multicolumn{4}{l}{\\textit{Panel B: TWFE (Log Providers)}} \\\\\n",
    sprintf("Early Term $\\times$ Post & %.4f%s & %.4f%s & %.4f%s \\\\\n",
            coef(twfe$providers), twfe_stars(twfe$providers),
            coef(ent$twfe_type1), twfe_stars(ent$twfe_type1),
            coef(ent$twfe_type2), twfe_stars(ent$twfe_type2)),
    sprintf(" & (%.4f) & (%.4f) & (%.4f) \\\\\n",
            se(twfe$providers), se(ent$twfe_type1), se(ent$twfe_type2)),
    "\\hline\n",
    sprintf("Pre-treatment mean & %.0f & %.0f & %.0f \\\\\n",
            hcbs[early_terminator == TRUE & month_date < as.Date("2021-06-01"),
                 mean(n_providers)],
            pre_t1_treated, pre_t2_treated),
    sprintf("States & %d & %d & %d \\\\\n",
            uniqueN(hcbs$state), uniqueN(type1$state), uniqueN(type2$state)),
    sprintf("Observations & %s & %s & %s \\\\\n",
            format(nrow(hcbs), big.mark = ","),
            format(nrow(type1), big.mark = ","),
            format(nrow(type2), big.mark = ",")),
    "\\hline\\hline\n",
    "\\multicolumn{4}{p{13cm}}{\\footnotesize ",
    "\\textit{Notes:} Column 1 reproduces the baseline result from Table \\ref{tab:main_results}. ",
    "Columns 2--3 decompose by NPPES entity type: Type 1 (individual practitioners) and ",
    "Type 2 (organizational entities such as home health agencies and personal care organizations). ",
    "Panel A: Callaway-Sant'Anna ATT with never-treated comparison; bootstrap SEs (1,000 iterations). ",
    "Panel B: TWFE with state-clustered SEs. ",
    "* $p<0.10$, ** $p<0.05$, *** $p<0.01$.} \\\\\n",
    "\\end{tabular}\n",
    "\\end{table}\n"
  )

  writeLines(entity_latex, file.path(TABLES, "tab6_entity_type.tex"))
} else {
  cat("  Entity type results unavailable — skipping Table 6\n")
}

cat("\n=== All tables generated ===\n")
