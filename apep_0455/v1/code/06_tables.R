## ============================================================
## 06_tables.R — All LaTeX tables for the paper
## Paper: TLV Expansion and Housing Markets (apep_0455)
## ============================================================

source("00_packages.R")

data_dir <- "../data"
tab_dir <- "../tables"
dir.create(tab_dir, showWarnings = FALSE, recursive = TRUE)

cat("=== Loading results ===\n")
main <- readRDS(file.path(data_dir, "main_results.rds"))
sumstats <- readRDS(file.path(data_dir, "summary_statistics.rds"))

robust <- if (file.exists(file.path(data_dir, "robustness_results.rds"))) {
  readRDS(file.path(data_dir, "robustness_results.rds"))
} else NULL

het <- if (file.exists(file.path(data_dir, "heterogeneity_results.rds"))) {
  readRDS(file.path(data_dir, "heterogeneity_results.rds"))
} else NULL

cy <- readRDS(file.path(data_dir, "panel_commune_year.rds"))

## -------------------------------------------------------
## Table 1: Summary Statistics
## -------------------------------------------------------

cat("  Table 1: Summary statistics...\n")

sumstats_formatted <- sumstats %>%
  mutate(Group = ifelse(treated == 1, "Treated", "Control")) %>%
  select(Group, N, Communes, `Mean Price/m²`, `SD Price/m²`,
         `Median Price/m²`, `Mean Surface`, `Share Apartments`) %>%
  mutate(across(c(`Mean Price/m²`, `SD Price/m²`, `Median Price/m²`),
                ~ format(round(., 0), big.mark = ",")),
         across(c(`Mean Surface`), ~ format(round(., 1))),
         `Share Apartments` = sprintf("%.1f%%", `Share Apartments` * 100),
         N = format(N, big.mark = ","),
         Communes = format(Communes, big.mark = ","))

## Write LaTeX table
sink(file.path(tab_dir, "tab1_summary.tex"))
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Summary Statistics: Property Transactions by Treatment Group}\n")
cat("\\label{tab:summary}\n")
cat("\\begin{tabular}{lrrrrrrr}\n")
cat("\\toprule\n")
cat(" & N & Communes & Mean & SD & Median & Mean & Share \\\\\n")
cat(" & & & Price/m² & Price/m² & Price/m² & Surface & Apts \\\\\n")
cat("\\midrule\n")
for (i in 1:nrow(sumstats_formatted)) {
  row <- sumstats_formatted[i, ]
  cat(sprintf("%s & %s & %s & %s & %s & %s & %s & %s \\\\\n",
              row$Group, row$N, row$Communes, row$`Mean Price/m²`,
              row$`SD Price/m²`, row$`Median Price/m²`,
              row$`Mean Surface`, row$`Share Apartments`))
}
cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{tablenotes}[flushleft]\\small\n")
cat("\\item \\textit{Notes:} Treated communes are those entering the TLV regime via the 2023 expansion (D\\'ecret 2023-822). Control communes are those never subject to TLV. Pre-2023 TLV communes are excluded. Sample covers DVF residential sales (houses and apartments) from 2020--2024. Outliers (price/m$^2$ $<$ 100 or $>$ 50,000 EUR) excluded.\n")
cat("\\end{tablenotes}\n")
cat("\\end{table}\n")
sink()

## -------------------------------------------------------
## Table 2: Main DiD Results
## -------------------------------------------------------

cat("  Table 2: Main DiD results...\n")

sink(file.path(tab_dir, "tab2_main_did.tex"))
etable(main$price_cy, main$price_cy_dxy,
       main$volume_cy, main$volume_cy_dxy,
       main$price_tx, main$price_tx_dxy,
       headers = c("(1)", "(2)", "(3)", "(4)", "(5)", "(6)"),
       se.below = TRUE, fitstat = ~ r2 + n,
       style.tex = style.tex("aer"),
       file = file.path(tab_dir, "tab2_main_did.tex"),
       replace = TRUE,
       title = "Effect of TLV Expansion on Housing Prices and Transaction Volume",
       label = "tab:main_did",
       notes = c("Standard errors clustered at the d\\'epartement level in parentheses.",
                  "Columns (1)-(2): Commune-year level, log mean price/m$^2$.",
                  "Columns (3)-(4): Commune-year level, log number of transactions.",
                  "Columns (5)-(6): Transaction level, log price/m$^2$.",
                  "Odd columns: commune + year FE. Even columns: commune + d\\'epartement $\\times$ year FE.",
                  "Treatment: communes entering TLV in 2024. Post: 2024 onward.",
                  "$^{***}p<0.01$; $^{**}p<0.05$; $^{*}p<0.1$."))
sink()

## -------------------------------------------------------
## Table 3: Robustness Checks
## -------------------------------------------------------

if (!is.null(robust)) {
  cat("  Table 3: Robustness...\n")

  rob_models <- list(
    main$price_cy,
    robust$placebo,
    robust$dep_year_fe,
    robust$donut
  )
  rob_models <- rob_models[!sapply(rob_models, is.null)]

  if (!is.null(robust$matched)) {
    rob_models <- c(rob_models, list(robust$matched))
  }

  etable(rob_models,
         headers = c("Baseline", "Placebo (2022)", "Dep×Year FE",
                      "Donut (excl. 2023-H2)",
                      if (!is.null(robust$matched)) "Matched Sample"),
         se.below = TRUE, fitstat = ~ r2 + n,
         style.tex = style.tex("aer"),
         file = file.path(tab_dir, "tab3_robustness.tex"),
         replace = TRUE,
         title = "Robustness Checks",
         label = "tab:robustness",
         notes = c("Standard errors clustered at the d\\'epartement level.",
                    "Dependent variable: log mean price/m$^2$ (commune-year level).",
                    "Column 1: Baseline. Column 2: Placebo test with fake treatment in 2022.",
                    "Column 3: D\\'epartement $\\times$ year FE. Column 4: Exclude Aug-Dec 2023.",
                    "Column 5: Propensity score matched sample (5:1 nearest neighbor)."))
}

## -------------------------------------------------------
## Table 4: Heterogeneity
## -------------------------------------------------------

if (!is.null(het)) {
  cat("  Table 4: Heterogeneity...\n")

  het_models <- list(het$tourism, het$nontourism)
  het_models <- het_models[!sapply(het_models, is.null)]

  if (length(het_models) == 2) {
    etable(het_models,
           headers = c("Tourism Communes", "Non-Tourism"),
           se.below = TRUE, fitstat = ~ r2 + n,
           style.tex = style.tex("aer"),
           file = file.path(tab_dir, "tab4_heterogeneity.tex"),
           replace = TRUE,
           title = "Heterogeneity by Zone Type",
           label = "tab:heterogeneity",
           notes = c("Standard errors clustered at the d\\'epartement level.",
                      "Column 1: Communes designated as ``zone touristique et tendue''.",
                      "Column 2: Communes designated as ``zone tendue'' only.",
                      "Dependent variable: log mean price/m$^2$ (commune-year level)."))
  }
}

cat("\nAll tables saved to ../tables/\n")
cat(sprintf("  Files: %s\n",
            paste(list.files(tab_dir, pattern = "\\.tex$"), collapse = ", ")))
