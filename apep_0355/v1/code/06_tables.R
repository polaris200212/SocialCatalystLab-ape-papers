## ============================================================================
## 06_tables.R — Generate all tables
## Paper: The Elasticity of Medicaid's Safety Net (apep_0354)
## ============================================================================

source("00_packages.R")

DATA <- "../data"
TABLES <- "../tables"
dir.create(TABLES, showWarnings = FALSE, recursive = TRUE)

## ---- Load ----
analysis_excl <- readRDS(file.path(DATA, "analysis_exclusions.rds"))
all_excl <- readRDS(file.path(DATA, "all_matched_exclusions.rds"))
rom_panel <- readRDS(file.path(DATA, "rom_panel.rds"))
static_models <- readRDS(file.path(DATA, "static_did_models.rds"))
het_models <- readRDS(file.path(DATA, "heterogeneity_models.rds"))
absorption <- readRDS(file.path(DATA, "absorption_rates.rds"))
placebo_model <- readRDS(file.path(DATA, "placebo_model.rds"))
ri_results <- readRDS(file.path(DATA, "randomization_inference.rds"))

rom_panel[rom_paid < 0, rom_paid := 0]

options("modelsummary_format_numeric_latex" = "plain")
cat("=== Generating Tables ===\n")

## ====================================================================
## Table 1: Summary Statistics
## ====================================================================
cat("Table 1: Summary statistics\n")

sink(file.path(TABLES, "tab1_summary.tex"))
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Summary Statistics}\n")
cat("\\label{tab:summary}\n")
cat("\\small\n")
cat("\\begin{tabular}{lccccc}\n")
cat("\\toprule\n")
cat("& Mean & SD & Median & Min & Max \\\\\n")
cat("\\midrule\n")
cat("\\multicolumn{6}{l}{\\textit{Panel A: Exclusion Events (N = ",
    nrow(analysis_excl), ")}} \\\\\n", sep = "")
cat(sprintf("Pre-excl.\\ annual billing (\\$) & %s & %s & %s & %s & %s \\\\\n",
            format(round(mean(analysis_excl$pre_paid)), big.mark = ","),
            format(round(sd(analysis_excl$pre_paid)), big.mark = ","),
            format(round(median(analysis_excl$pre_paid)), big.mark = ","),
            format(round(min(analysis_excl$pre_paid)), big.mark = ","),
            format(round(max(analysis_excl$pre_paid)), big.mark = ",")))
cat(sprintf("Service-level market share (\\%%) & %.1f & %.1f & %.1f & %.1f & %.1f \\\\\n",
            100*mean(analysis_excl$market_share), 100*sd(analysis_excl$market_share),
            100*median(analysis_excl$market_share), 100*min(analysis_excl$market_share),
            100*max(analysis_excl$market_share)))
cat(sprintf("Months active pre-exclusion & %.1f & %.1f & %.0f & %d & %d \\\\\n",
            mean(analysis_excl$pre_months), sd(analysis_excl$pre_months),
            median(analysis_excl$pre_months), min(analysis_excl$pre_months),
            max(analysis_excl$pre_months)))
cat(sprintf("HCBS-related specialty & %.0f\\%% & & & & \\\\\n",
            100*mean(analysis_excl$hcbs_related)))

# Panel B: ROM panel
rom_pre <- rom_panel[event_time >= -12 & event_time < 0]
rom_post <- rom_panel[event_time >= 0 & event_time <= 12]

cat("\\midrule\n")
cat("\\multicolumn{6}{l}{\\textit{Panel B: ROM Panel --- Pre-exclusion (N = ",
    nrow(rom_pre), " unit-months)}} \\\\\n", sep = "")
cat(sprintf("Monthly ROM spending (\\$) & %s & %s & %s & & \\\\\n",
            format(round(mean(rom_pre$rom_paid, na.rm=TRUE)), big.mark=","),
            format(round(sd(rom_pre$rom_paid, na.rm=TRUE)), big.mark=","),
            format(round(median(rom_pre$rom_paid, na.rm=TRUE)), big.mark=",")))
cat(sprintf("Active ROM providers & %.1f & %.1f & %.0f & & \\\\\n",
            mean(rom_pre$rom_providers, na.rm=TRUE),
            sd(rom_pre$rom_providers, na.rm=TRUE),
            median(rom_pre$rom_providers, na.rm=TRUE)))

cat("\\multicolumn{6}{l}{\\textit{Panel C: ROM Panel --- Post-exclusion (N = ",
    nrow(rom_post), " unit-months)}} \\\\\n", sep = "")
cat(sprintf("Monthly ROM spending (\\$) & %s & %s & %s & & \\\\\n",
            format(round(mean(rom_post$rom_paid, na.rm=TRUE)), big.mark=","),
            format(round(sd(rom_post$rom_paid, na.rm=TRUE)), big.mark=","),
            format(round(median(rom_post$rom_paid, na.rm=TRUE)), big.mark=",")))
cat(sprintf("Active ROM providers & %.1f & %.1f & %.0f & & \\\\\n",
            mean(rom_post$rom_providers, na.rm=TRUE),
            sd(rom_post$rom_providers, na.rm=TRUE),
            median(rom_post$rom_providers, na.rm=TRUE)))

cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{tablenotes}[flushleft]\\footnotesize\n")
cat("\\item \\textit{Notes:} Panel A describes OIG LEIE exclusion events matched to T-MSIS Medicaid billing with $\\geq$3\\% service-level market share and $\\geq$\\$1,000 annual ZIP-service spending. ROM = rest-of-market (excluding the excluded provider). Service categories are defined by HCPCS code prefix groupings.\n")
cat("\\end{tablenotes}\n")
cat("\\end{table}\n")
sink()

## ====================================================================
## Table 2: Main Results
## ====================================================================
cat("Table 2: Main results\n")

main_list <- list(
  "(1)" = static_models$paid$basic,
  "(2)" = static_models$paid$sm,
  "(3)" = static_models$paid$controls,
  "(4)" = static_models$providers$sm,
  "(5)" = static_models$beneficiaries$sm
)

cm <- c("post" = "Post $\\times$ Treated")

gm <- list(
  list("raw" = "nobs", "clean" = "Observations", "fmt" = function(x) format(x, big.mark = ",")),
  list("raw" = "r.squared", "clean" = "$R^2$", "fmt" = 3)
)

fe_rows <- tribble(
  ~term,           ~`(1)`, ~`(2)`, ~`(3)`, ~`(4)`, ~`(5)`,
  "Unit FE",       "Yes",  "Yes",  "Yes",  "Yes",  "Yes",
  "Month FE",      "Yes",  "---",  "---",  "---",  "---",
  "State$\\times$Month FE", "---",  "Yes",  "Yes",  "Yes",  "Yes",
  "County controls","---",  "---",  "Yes",  "---",  "---",
  "Outcome",       "Spending","Spending","Spending","Providers","Bene."
)
attr(fe_rows, "position") <- c(5, 6, 7, 8, 9)

ms <- modelsummary(
  main_list,
  output = "latex_tabular",
  coef_map = cm,
  gof_map = gm,
  add_rows = fe_rows,
  stars = c("*" = 0.10, "**" = 0.05, "***" = 0.01),
  title = "Effect of Provider Exclusion on Rest-of-Market Outcomes\\label{tab:main}",
  notes = "Standard errors clustered at the ZIP$\\times$service level in parentheses. Dependent variables: (1)--(3) ln(ROM spending), (4) ln(ROM providers), (5) ln(ROM beneficiaries). Unit = ZIP $\\times$ service category $\\times$ month. 22 treated units across 16 ZIPs and 10 states.",
  escape = FALSE
)

# modelsummary may return tinytable object; convert to string
ms_str <- if (is.character(ms)) ms else capture.output(print(ms))
writeLines(ms_str, file.path(TABLES, "tab2_main.tex"))

## ====================================================================
## Table 3: Robustness
## ====================================================================
cat("Table 3: Robustness\n")

sink(file.path(TABLES, "tab3_robustness.tex"))
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Robustness Checks}\n")
cat("\\label{tab:robustness}\n")
cat("\\small\n")
cat("\\begin{tabular}{lcccc}\n")
cat("\\toprule\n")
cat("& Coefficient & SE & $p$-value & N \\\\\n")
cat("\\midrule\n")

# Main specification
mc <- coef(static_models$paid$sm)["post"]
ms_se <- se(static_models$paid$sm)["post"]
cat(sprintf("Baseline (state$\\times$month FE) & %.3f & (%.3f) & %.3f & %d \\\\\n",
            mc, ms_se, 2*pnorm(-abs(mc/ms_se)), nobs(static_models$paid$sm)))

# Placebo
if (!is.null(placebo_model)) {
  pc <- coef(placebo_model)["placebo_post"]
  ps <- se(placebo_model)["placebo_post"]
  cat(sprintf("Placebo: untreated services & %.3f & (%.3f) & %.3f & %d \\\\\n",
              pc, ps, 2*pnorm(-abs(pc/ps)), nobs(placebo_model)))
}

# RI p-value
cat(sprintf("Randomization inference & %.3f & --- & %.3f & --- \\\\\n",
            ri_results$true_coef, ri_results$ri_pvalue))

cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{tablenotes}[flushleft]\\footnotesize\n")
cat("\\item \\textit{Notes:} Baseline uses ZIP$\\times$service FE and state$\\times$month FE with unit-clustered SEs. Placebo assigns treatment timing to non-treated service categories within the same treated ZIPs. Randomization inference permutes treatment timing 500 times.\n")
cat("\\end{tablenotes}\n")
cat("\\end{table}\n")
sink()

## ====================================================================
## Table 4: Absorption Rates
## ====================================================================
cat("Table 4: Absorption rates\n")

abs_clean <- absorption[is.finite(absorb_6m) & is.finite(absorb_12m)]

sink(file.path(TABLES, "tab4_absorption.tex"))
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Rest-of-Market Absorption Rates}\n")
cat("\\label{tab:absorption}\n")
cat("\\small\n")
cat("\\begin{tabular}{lcc}\n")
cat("\\toprule\n")
cat("& 6 Months & 12 Months \\\\\n")
cat("\\midrule\n")
cat(sprintf("Mean absorption & %.0f\\%% & %.0f\\%% \\\\\n",
            100*mean(abs_clean$absorb_6m, na.rm=TRUE),
            100*mean(abs_clean$absorb_12m, na.rm=TRUE)))
cat(sprintf("Median absorption & %.0f\\%% & %.0f\\%% \\\\\n",
            100*median(abs_clean$absorb_6m, na.rm=TRUE),
            100*median(abs_clean$absorb_12m, na.rm=TRUE)))
cat(sprintf("Share $>$ 50\\%% & %.0f\\%% & %.0f\\%% \\\\\n",
            100*mean(abs_clean$absorb_6m > 0.5, na.rm=TRUE),
            100*mean(abs_clean$absorb_12m > 0.5, na.rm=TRUE)))
cat(sprintf("Share $>$ 100\\%% & %.0f\\%% & %.0f\\%% \\\\\n",
            100*mean(abs_clean$absorb_6m > 1, na.rm=TRUE),
            100*mean(abs_clean$absorb_12m > 1, na.rm=TRUE)))
cat("\\midrule\n")
cat(sprintf("N & \\multicolumn{2}{c}{%d} \\\\\n", nrow(abs_clean)))
cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{tablenotes}[flushleft]\\footnotesize\n")
cat("\\item \\textit{Notes:} Absorption = (post ROM spending $-$ pre ROM spending) / excluded provider's monthly baseline. Values $>$100\\% indicate the rest of market more than fully absorbed the displaced volume.\n")
cat("\\end{tablenotes}\n")
cat("\\end{table}\n")
sink()

## ====================================================================
## Table 5: LEIE-to-T-MSIS Match Rates
## ====================================================================
cat("Table 5: Match rates\n")

leie <- readRDS(file.path(DATA, "leie_cleaned.rds"))

sink(file.path(TABLES, "tab5_matching.tex"))
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{LEIE-to-T-MSIS Matching Cascade}\n")
cat("\\label{tab:matching}\n")
cat("\\small\n")
cat("\\begin{tabular}{lcc}\n")
cat("\\toprule\n")
cat("Filter & Count & \\% of Previous \\\\\n")
cat("\\midrule\n")
n_leie <- nrow(leie)
n_npi <- uniqueN(leie$npi)
n_matched <- uniqueN(all_excl$npi)
n_pre3 <- nrow(all_excl)
n_share3 <- nrow(all_excl[market_share >= 0.03 & zip_annual_total >= 1000])
n_final <- nrow(analysis_excl)

cat(sprintf("LEIE records (2018--2024) & %s & --- \\\\\n",
            format(n_leie, big.mark = ",")))
cat(sprintf("With valid NPI & %s & %.0f\\%% \\\\\n",
            format(n_npi, big.mark = ","), 100*n_npi/n_leie))
cat(sprintf("Matched to T-MSIS billing & %d & %.0f\\%% \\\\\n",
            n_matched, 100*n_matched/n_npi))
cat(sprintf("$\\geq$3 months pre-billing (NPI$\\times$svc) & %d & --- \\\\\n", n_pre3))
cat(sprintf("$\\geq$3\\%% svc-level market share & %d & %.0f\\%% \\\\\n",
            n_share3, 100*n_share3/n_pre3))
cat(sprintf("Analysis sample & %d & --- \\\\\n", n_final))
cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{tablenotes}[flushleft]\\footnotesize\n")
cat("\\item \\textit{Notes:} The cascade shows sequential filters applied to OIG LEIE exclusion records. ``Matched to T-MSIS'' means the excluded NPI appears as a servicing provider in the T-MSIS Medicaid billing data. Market share is computed at the ZIP $\\times$ service-category level.\n")
cat("\\end{tablenotes}\n")
cat("\\end{table}\n")
sink()

cat("\n=== All tables generated ===\n")
