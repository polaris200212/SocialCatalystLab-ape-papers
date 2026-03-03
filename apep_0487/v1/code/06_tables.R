################################################################################
# 06_tables.R — All Tables
# Paper: Voting Their Wallet? Medicaid Revenue Dependence and Provider Political Behavior
# APEP-0487
################################################################################

source("00_packages.R")

cat("=== Loading data ===\n")
panel <- read_parquet(file.path(LOCAL_DATA, "analysis_panel.parquet")) |> setDT()
main_models <- readRDS(file.path(LOCAL_DATA, "main_models.rds"))

robust_file <- file.path(LOCAL_DATA, "robustness_results.rds")
if (file.exists(robust_file)) {
  robust <- readRDS(robust_file)
}

linkage_file <- file.path(LOCAL_DATA, "linkage_quality.csv")

# ============================================================================
# Table 1: Summary Statistics
# ============================================================================
cat("Table 1: Summary Statistics\n")

# Panel A: By expansion status
tab1a <- panel[, .(
  `N Providers` = format(uniqueN(npi), big.mark = ","),
  `N Provider-Cycles` = format(.N, big.mark = ","),
  `Mean Medicaid Revenue ($)` = format(round(mean(medicaid_paid)), big.mark = ","),
  `Mean Medicaid Share` = round(mean(medicaid_share, na.rm = TRUE), 3),
  `Donation Rate (%)` = round(mean(any_donation) * 100, 1),
  `Mean Donation ($, donors)` = format(round(mean(total_donations[any_donation == TRUE])), big.mark = ","),
  `Dem Share (%, donors)` = round(mean(dem_share[any_donation == TRUE], na.rm = TRUE) * 100, 1)
), by = .(Group = fifelse(expansion_state, "Late-Expansion States", "Non-Expansion States"))]

# Panel B: By Medicaid dependence quartile
tab1b <- panel[!is.na(medicaid_share_q), .(
  `N Providers` = format(uniqueN(npi), big.mark = ","),
  `Mean Medicaid Share` = round(mean(medicaid_share, na.rm = TRUE), 3),
  `Donation Rate (%)` = round(mean(any_donation) * 100, 1),
  `Mean Donation ($, donors)` = format(round(mean(total_donations[any_donation == TRUE])), big.mark = ","),
  `Dem Share (%, donors)` = round(mean(dem_share[any_donation == TRUE], na.rm = TRUE) * 100, 1)
), by = .(Group = medicaid_share_q)]

# Write LaTeX
sink(file.path(TAB_DIR, "tab1_summary_stats.tex"))
cat("\\begin{table}[htbp]\n\\centering\n")
cat("\\caption{Summary Statistics}\n\\label{tab:summary}\n")
cat("\\begin{adjustbox}{max width=\\textwidth}\n")
cat("\\begin{tabular}{l", rep("c", ncol(tab1a) - 1), "}\n")
cat("\\toprule\n")

# Panel A header
cat("\\multicolumn{", ncol(tab1a), "}{l}{\\textbf{Panel A: By Expansion Status}} \\\\\n")
cat("\\midrule\n")
cat(paste(names(tab1a), collapse = " & "), "\\\\\n")
cat("\\midrule\n")
for (i in seq_len(nrow(tab1a))) {
  cat(paste(tab1a[i], collapse = " & "), "\\\\\n")
}

# Panel B header
cat("\\midrule\n")
cat("\\multicolumn{", ncol(tab1a), "}{l}{\\textbf{Panel B: By Medicaid Dependence Quartile}} \\\\\n")
cat("\\midrule\n")
cat(paste(names(tab1b), collapse = " & "), "\\\\\n")
cat("\\midrule\n")
for (i in seq_len(nrow(tab1b))) {
  cat(paste(tab1b[i], collapse = " & "), "\\\\\n")
}

cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\end{adjustbox}\n")
cat("\\begin{tablenotes}\\small\n")
cat("\\item \\textit{Notes:} Panel A compares providers in late-expansion states (VA, ME, ID, NE, MO, OK, SD) to providers in non-expansion states (TX, FL, GA, WI, WY, MS, AL, SC, TN, KS). Panel B splits all providers by pre-expansion Medicaid revenue share quartile. Donation statistics conditional on making at least one FEC-reported contribution in the election cycle. Medicaid Share = Medicaid Revenue / (Medicaid + Medicare Revenue) measured in 2018.\n")
cat("\\end{tablenotes}\n")
cat("\\end{table}\n")
sink()
cat("  Saved: tab1_summary_stats.tex\n")

# ============================================================================
# Table 2: Linkage Quality
# ============================================================================
cat("Table 2: Linkage Quality\n")

if (file.exists(linkage_file)) {
  linkage <- fread(linkage_file)

  sink(file.path(TAB_DIR, "tab2_linkage_quality.tex"))
  cat("\\begin{table}[htbp]\n\\centering\n")
  cat("\\caption{Record Linkage Quality Statistics}\n\\label{tab:linkage}\n")
  cat("\\begin{tabular}{lc}\n\\toprule\n")
  cat("Metric & Value \\\\\n\\midrule\n")
  for (i in seq_len(nrow(linkage))) {
    cat(linkage$metric[i], " & ", linkage$value[i], " \\\\\n")
  }
  cat("\\bottomrule\n\\end{tabular}\n")
  cat("\\begin{tablenotes}\\small\n")
  cat("\\item \\textit{Notes:} Deterministic matching on (last name, first name, state, ZIP5). Occupation concordance measures the fraction of matched records where the FEC occupation field is consistent with the NPPES provider taxonomy.\n")
  cat("\\end{tablenotes}\n")
  cat("\\end{table}\n")
  sink()
  cat("  Saved: tab2_linkage_quality.tex\n")
}

# ============================================================================
# Table 3: Main DDD Results
# ============================================================================
cat("Table 3: Main DDD Results\n")

# Use fixest's etable to generate LaTeX
etable(main_models$extensive_basic, main_models$extensive_full,
       main_models$extensive_controls,
       main_models$intensive_full, main_models$intensive_controls,
       main_models$direction_full,
       headers = c("Any Donation", "Any Donation", "Any Donation",
                    "Log(Amount)", "Log(Amount)", "Dem Share"),
       se.below = TRUE,
       fitstat = c("n", "r2", "ar2"),
       file = file.path(TAB_DIR, "tab3_main_results.tex"),
       replace = TRUE,
       title = "Medicaid Expansion and Provider Political Donations: DDD Estimates",
       label = "tab:main",
       notes = c("State-clustered standard errors in parentheses.",
                 "Columns 1-3: Any donation (extensive margin). Columns 4-5: Log donation amount (intensive, donors only). Column 6: Democratic share of donations (donors only).",
                 "Medicaid Share measured in 2018 (pre-expansion). * p<0.1, ** p<0.05, *** p<0.01."))

cat("  Saved: tab3_main_results.tex\n")

# ============================================================================
# Table 4: Mechanism Decomposition
# ============================================================================
cat("Table 4: Mechanism Decomposition\n")

# Run mechanism specs
panel[, provider_type := fcase(
  grepl("^(207|208|209)", taxonomy_code), "Physician",
  grepl("^(363|364|367)", taxonomy_code), "Nurse/NP",
  grepl("^(225|229|231)", taxonomy_code), "Therapist",
  grepl("^(171|174|372)", taxonomy_code), "Social/Behavioral",
  default = "Other"
)]

mech_models <- list()
for (ptype in c("Physician", "Nurse/NP", "Therapist", "Social/Behavioral", "Other")) {
  sub <- panel[provider_type == ptype]
  if (nrow(sub) > 100 & sum(sub$any_donation) > 10) {
    mech_models[[ptype]] <- feols(any_donation ~ post_expansion * medicaid_share |
                                     npi + practice_state^cycle,
                                   data = sub, cluster = ~practice_state)
  }
}

if (length(mech_models) > 0) {
  etable(mech_models,
         headers = names(mech_models),
         se.below = TRUE,
         fitstat = c("n", "r2"),
         file = file.path(TAB_DIR, "tab4_mechanism_by_specialty.tex"),
         replace = TRUE,
         title = "DDD Estimates by Provider Specialty",
         label = "tab:mechanism",
         notes = c("State-clustered standard errors in parentheses.",
                   "Each column restricts to providers of the indicated specialty (NUCC taxonomy).",
                   "Medicaid Share measured in 2018 (pre-expansion). * p<0.1, ** p<0.05, *** p<0.01."))
  cat("  Saved: tab4_mechanism_by_specialty.tex\n")
}

# ============================================================================
# Table 5: Robustness
# ============================================================================
cat("Table 5: Robustness\n")

robustness_summary <- data.table(
  Specification = character(),
  Coefficient = numeric(),
  SE = numeric(),
  `p-value` = numeric(),
  N = integer()
)

# Main estimate
int_nm <- grep("post_expansion.*:.*medicaid_share", names(coef(main_models$extensive_full)), value = TRUE)[1]
main_coef <- coef(main_models$extensive_full)[int_nm]
main_se <- se(main_models$extensive_full)[int_nm]
main_p <- fixest::pvalue(main_models$extensive_full)[int_nm]
main_n <- nobs(main_models$extensive_full)

robustness_summary <- rbind(robustness_summary, data.table(
  Specification = "Main (Provider FE + State×Cycle FE)",
  Coefficient = main_coef, SE = main_se, `p-value` = main_p, N = main_n
))

# WCB
if (exists("robust") && !is.null(robust$wcb)) {
  robustness_summary <- rbind(robustness_summary, data.table(
    Specification = "Wild Cluster Bootstrap",
    Coefficient = robust$wcb$point_estimate, SE = NA_real_,
    `p-value` = robust$wcb$p_val, N = main_n
  ))
}

# RI
if (exists("robust") && !is.null(robust$ri_pvalue)) {
  robustness_summary <- rbind(robustness_summary, data.table(
    Specification = "Randomization Inference (999 perms)",
    Coefficient = main_coef, SE = NA_real_,
    `p-value` = robust$ri_pvalue, N = main_n
  ))
}

# LOO range
if (exists("robust") && !is.null(robust$loo)) {
  loo_range <- range(robust$loo$coef)
  robustness_summary <- rbind(robustness_summary, data.table(
    Specification = paste0("Leave-one-out range [", round(loo_range[1], 4),
                           ", ", round(loo_range[2], 4), "]"),
    Coefficient = mean(robust$loo$coef), SE = NA_real_,
    `p-value` = NA_real_, N = main_n
  ))
}

# Write LaTeX
sink(file.path(TAB_DIR, "tab5_robustness.tex"))
cat("\\begin{table}[htbp]\n\\centering\n")
cat("\\caption{Robustness Checks for Main DDD Estimate}\n\\label{tab:robust}\n")
cat("\\begin{adjustbox}{max width=\\textwidth}\n")
cat("\\begin{tabular}{lcccc}\n\\toprule\n")
cat("Specification & Coefficient & SE & p-value & N \\\\\n\\midrule\n")
for (i in seq_len(nrow(robustness_summary))) {
  r <- robustness_summary[i]
  cat(r$Specification, " & ",
      round(r$Coefficient, 4), " & ",
      ifelse(is.na(r$SE), "---", round(r$SE, 4)), " & ",
      ifelse(is.na(r$`p-value`), "---", round(r$`p-value`, 3)), " & ",
      format(r$N, big.mark = ","), " \\\\\n")
}
cat("\\bottomrule\n\\end{tabular}\n")
cat("\\end{adjustbox}\n")
cat("\\begin{tablenotes}\\small\n")
cat("\\item \\textit{Notes:} All specifications estimate the DDD coefficient (Post Expansion $\\times$ Medicaid Share) on the extensive margin (any FEC donation). Wild cluster bootstrap uses Webb weights. Randomization inference permutes expansion status across 17 states. Leave-one-out drops each expansion state sequentially.\n")
cat("\\end{tablenotes}\n")
cat("\\end{table}\n")
sink()
cat("  Saved: tab5_robustness.tex\n")

# ============================================================================
# Table 6: Placebo Results
# ============================================================================
cat("Table 6: Placebo Results\n")

if (exists("robust")) {
  placebo_models <- list()
  if (!is.null(robust$placebo_low_med)) placebo_models[["Low Medicaid Dep."]] <- robust$placebo_low_med
  if (!is.null(robust$placebo_pre)) placebo_models[["Pre-Period Placebo"]] <- robust$placebo_pre

  if (length(placebo_models) > 0) {
    etable(placebo_models,
           se.below = TRUE,
           fitstat = c("n", "r2"),
           file = file.path(TAB_DIR, "tab6_placebos.tex"),
           replace = TRUE,
           title = "Placebo Tests",
           label = "tab:placebo",
           notes = c("State-clustered standard errors in parentheses.",
                     "Column 1: Restricts to providers in the bottom quartile of Medicaid dependence (should not be affected by expansion).",
                     "Column 2: Pre-treatment period only with fake treatment at 2018 (tests for differential pre-trends).",
                     "* p<0.1, ** p<0.05, *** p<0.01."))
    cat("  Saved: tab6_placebos.tex\n")
  }
}

cat("\n=== All tables generated ===\n")
