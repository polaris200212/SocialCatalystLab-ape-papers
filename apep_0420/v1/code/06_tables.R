## 06_tables.R — Generate all LaTeX tables
## APEP-0420: The Visible and the Invisible

source("00_packages.R")

data_dir <- "../data"
tables_dir <- "../tables"
dir.create(tables_dir, showWarnings = FALSE, recursive = TRUE)

## Disable siunitx wrapping in modelsummary
options("modelsummary_format_numeric_latex" = "plain")

cat("Loading results...\n")

## ============================================================
## TABLE 1: Summary Statistics
## ============================================================

cat("Table 1: Summary statistics...\n")

nbi <- fread(file.path(data_dir, "nbi_panel_clean.csv"))
nbi <- nbi[year >= 2001]

## Winsorize extreme outliers for display (NBI data errors)
## Max bridge span in the world is ~2000m; cap at 3000m
nbi[max_span_m > 3000, max_span_m := NA]
nbi[total_len_m > 40000, total_len_m := NA]
## Annual condition changes of +/-9 are physically implausible coding errors
nbi[abs(deck_change) > 5, deck_change := NA]

## Overall summary stats
vars_to_summarize <- c("deck_cond", "super_cond", "sub_cond", "adt",
                        "bridge_age", "total_len_m", "n_spans", "max_span_m",
                        "struct_deficient", "repair_event", "deck_change")

var_labels <- c("Deck Condition (0--9)", "Superstructure Condition (0--9)",
                "Substructure Condition (0--9)", "Average Daily Traffic",
                "Bridge Age (years)", "Total Length (meters)", "Number of Spans",
                "Max Span Length (meters)", "Structurally Deficient",
                "Repair Event", "Annual Deck Condition Change")

sumstats <- data.frame(
  Variable = var_labels,
  Mean = sapply(vars_to_summarize, function(v) sprintf("%.2f", mean(nbi[[v]], na.rm = TRUE))),
  SD = sapply(vars_to_summarize, function(v) sprintf("%.2f", sd(nbi[[v]], na.rm = TRUE))),
  Min = sapply(vars_to_summarize, function(v) sprintf("%.1f", min(nbi[[v]], na.rm = TRUE))),
  Max = sapply(vars_to_summarize, function(v) sprintf("%.1f", max(nbi[[v]], na.rm = TRUE))),
  stringsAsFactors = FALSE
)

## Display binary variables as percentages for consistency with Table 2
for (v in c("struct_deficient", "repair_event")) {
  row_idx <- which(vars_to_summarize == v)
  sumstats$Mean[row_idx] <- sprintf("%.1f\\%%", mean(nbi[[v]], na.rm = TRUE) * 100)
  sumstats$SD[row_idx] <- sprintf("%.1f", sd(nbi[[v]], na.rm = TRUE) * 100)
  sumstats$Min[row_idx] <- "0"
  sumstats$Max[row_idx] <- "100"
}

## Format ADT with commas
adt_row <- which(sumstats$Variable == "Average Daily Traffic")
sumstats$Mean[adt_row] <- format(round(mean(nbi$adt, na.rm = TRUE)), big.mark = ",")
sumstats$SD[adt_row] <- format(round(sd(nbi$adt, na.rm = TRUE)), big.mark = ",")
sumstats$Min[adt_row] <- format(round(min(nbi$adt, na.rm = TRUE)), big.mark = ",")
sumstats$Max[adt_row] <- format(round(max(nbi$adt, na.rm = TRUE)), big.mark = ",")

## Write LaTeX
tab1 <- paste0(
  "\\begin{table}[H]\n",
  "\\centering\n",
  "\\caption{Summary Statistics}\n",
  "\\begin{threeparttable}\n",
  "\\begin{tabular}{lrrrr}\n",
  "\\toprule\n",
  "Variable & Mean & Std.\\ Dev. & Min & Max \\\\\n",
  "\\midrule\n",
  paste(apply(sumstats, 1, function(row) {
    paste(row, collapse = " & ")
  }), collapse = " \\\\\n"),
  " \\\\\n",
  "\\bottomrule\n",
  "\\end{tabular}\n",
  "\\begin{tablenotes}[flushleft]\n",
  "\\small\n",
  sprintf("\\item Notes: N = %s bridge-year observations across %s unique bridges in 49 states, 2001--2023. Condition ratings follow the FHWA 0--9 scale (9 = Excellent, 4 = Poor threshold for structural deficiency). Repair Event indicates a condition improvement of 2+ points in any component.\n",
          format(nrow(nbi), big.mark = ","),
          format(uniqueN(nbi$bridge_id), big.mark = ",")),
  "\\end{tablenotes}\n",
  "\\end{threeparttable}\n",
  "\\label{tab:summary}\n",
  "\\end{table}\n"
)

writeLines(tab1, file.path(tables_dir, "tab1_summary.tex"))

## ============================================================
## TABLE 2: Summary by ADT Tercile
## ============================================================

cat("Table 2: Summary by ADT tercile...\n")

by_tercile <- nbi[!is.na(initial_adt_tercile), .(
  N = format(.N, big.mark = ","),
  Mean_Deck = sprintf("%.2f", mean(deck_cond, na.rm = TRUE)),
  Mean_ADT = format(round(mean(adt, na.rm = TRUE)), big.mark = ","),
  Pct_Deficient = sprintf("%.1f", mean(struct_deficient, na.rm = TRUE) * 100),
  Mean_Age = sprintf("%.1f", mean(bridge_age, na.rm = TRUE)),
  Repair_Rate = sprintf("%.2f", mean(repair_event, na.rm = TRUE) * 100),
  Mean_Change = sprintf("%.3f", mean(deck_change, na.rm = TRUE))
), by = initial_adt_tercile]

## Force correct ordering: Low, Medium, High (alphabetical gives High, Low, Medium)
by_tercile[, initial_adt_tercile := factor(initial_adt_tercile, levels = c("Low", "Medium", "High"))]
setorder(by_tercile, initial_adt_tercile)

tab2 <- paste0(
  "\\begin{table}[H]\n",
  "\\centering\n",
  "\\caption{Bridge Characteristics by Traffic Exposure}\n",
  "\\begin{threeparttable}\n",
  "\\begin{tabular}{lrrr}\n",
  "\\toprule\n",
  " & \\multicolumn{3}{c}{Initial ADT Tercile} \\\\\n",
  "\\cmidrule(lr){2-4}\n",
  " & Low & Medium & High \\\\\n",
  "\\midrule\n",
  sprintf("Observations & %s & %s & %s \\\\\n", by_tercile$N[1], by_tercile$N[2], by_tercile$N[3]),
  sprintf("Mean ADT & %s & %s & %s \\\\\n", by_tercile$Mean_ADT[1], by_tercile$Mean_ADT[2], by_tercile$Mean_ADT[3]),
  sprintf("Mean Deck Condition & %s & %s & %s \\\\\n", by_tercile$Mean_Deck[1], by_tercile$Mean_Deck[2], by_tercile$Mean_Deck[3]),
  sprintf("Pct.\\ Structurally Deficient & %s & %s & %s \\\\\n", by_tercile$Pct_Deficient[1], by_tercile$Pct_Deficient[2], by_tercile$Pct_Deficient[3]),
  sprintf("Mean Age (years) & %s & %s & %s \\\\\n", by_tercile$Mean_Age[1], by_tercile$Mean_Age[2], by_tercile$Mean_Age[3]),
  sprintf("Repair Rate (\\%%) & %s & %s & %s \\\\\n", by_tercile$Repair_Rate[1], by_tercile$Repair_Rate[2], by_tercile$Repair_Rate[3]),
  sprintf("Mean Annual $\\Delta$ Deck & %s & %s & %s \\\\\n", by_tercile$Mean_Change[1], by_tercile$Mean_Change[2], by_tercile$Mean_Change[3]),
  "\\bottomrule\n",
  "\\end{tabular}\n",
  "\\begin{tablenotes}[flushleft]\n",
  "\\small\n",
  "\\item Notes: Terciles computed within state using initial (first-observed) ADT. Repair Rate is the percentage of bridge-year observations with a condition improvement of $\\geq$ 2 points. Annual $\\Delta$ Deck is the year-over-year change in deck condition rating.\n",
  "\\end{tablenotes}\n",
  "\\end{threeparttable}\n",
  "\\label{tab:by_tercile}\n",
  "\\end{table}\n"
)

writeLines(tab2, file.path(tables_dir, "tab2_by_tercile.tex"))

## ============================================================
## TABLE 3: Main Results
## ============================================================

cat("Table 3: Main regression results...\n")

main_results <- readRDS(file.path(data_dir, "main_results.rds"))

## Use modelsummary for clean LaTeX output
tab3_models <- list(
  "(1)" = main_results$m1,
  "(2)" = main_results$m2,
  "(3)" = main_results$m3,
  "(4)" = main_results$m4,
  "(5)" = main_results$m5
)

tab3_file <- file.path(tables_dir, "tab3_main_results.tex")
modelsummary(
  tab3_models,
  output = tab3_file,
  fmt = 3,
  stars = c("*" = 0.10, "**" = 0.05, "***" = 0.01),
  coef_map = c(
    "high_initial_adt" = "High Initial ADT",
    "log(initial_adt)" = "Log(Initial ADT)",
    "bridge_age" = "Bridge Age",
    "I(bridge_age^2)" = "Bridge Age Squared",
    "total_len_m" = "Total Length (m)",
    "n_spans" = "Number of Spans",
    "max_span_m" = "Max Span Length"
  ),
  gof_map = c("nobs", "r.squared", "FE: state_fips", "FE: year",
              "FE: state_fips^year", "FE: material"),
  title = "Effect of Traffic Exposure on Bridge Deck Condition Change",
  notes = c(
    "Standard errors clustered at the state level in parentheses.",
    "Outcome: annual change in deck condition rating (0--9 scale).",
    "High Initial ADT = top tercile of initial Average Daily Traffic within state.",
    "Column (1) has more observations because it excludes engineering covariates; Columns (2)--(5) drop observations with missing covariates.",
    "Coefficients on Bridge Age Squared and engineering covariates are small (order of 1e-05); 0.000 indicates abs(coeff) < 0.001.",
    "* p < 0.10, ** p < 0.05, *** p < 0.01."
  )
)

## ============================================================
## TABLE 4: Electoral Maintenance Cycle
## ============================================================

cat("Table 4: Electoral maintenance cycle...\n")

election_results <- readRDS(file.path(data_dir, "election_results.rds"))

tab4_models <- list(
  "(1)" = election_results$m6,
  "(2)" = election_results$m7,
  "(3)" = election_results$m8
)

tab4_file <- file.path(tables_dir, "tab4_election_cycle.tex")
modelsummary(
  tab4_models,
  output = tab4_file,
  stars = c("*" = 0.10, "**" = 0.05, "***" = 0.01),
  coef_map = c(
    "high_initial_adt" = "High Initial ADT",
    "high_initial_adt:election_window" = "High ADT x Election Window",
    "pre_election" = "Pre-Election Year",
    "gov_election" = "Governor Election Year",
    "high_initial_adt:pre_election" = "High ADT x Pre-Election",
    "high_initial_adt:gov_election" = "High ADT x Election Year",
    "low_adt" = "Low ADT",
    "low_adt:election_window" = "Low ADT x Election Window"
  ),
  gof_map = c("nobs", "r.squared", "r.squared.within", "rmse",
              "FE: material", "FE: state_fips^year", "FE: year", "FE: state_fips"),
  title = "The Electoral Maintenance Cycle: Repair Events by Traffic Exposure and Election Proximity",
  notes = c(
    "Standard errors clustered at the state level in parentheses.",
    "Outcome: indicator for repair event (condition improvement of 2+ points).",
    "Election Window = gubernatorial election year or year preceding.",
    "Columns (1) and (3) include state x year and material FE (election window main effect absorbed). Column (2) uses state + year + material FE.",
    "* p < 0.10, ** p < 0.05, *** p < 0.01."
  )
)

## ============================================================
## TABLE 5: Visible vs Invisible Components
## ============================================================

cat("Table 5: Component comparison...\n")

component_results <- readRDS(file.path(data_dir, "component_results.rds"))

tab5_models <- list(
  "Deck (Visible)" = component_results$m_deck,
  "Superstructure" = component_results$m_super,
  "Substructure (Invisible)" = component_results$m_sub
)

tab5_file <- file.path(tables_dir, "tab5_components.tex")
modelsummary(
  tab5_models,
  output = tab5_file,
  stars = c("*" = 0.10, "**" = 0.05, "***" = 0.01),
  coef_map = c(
    "high_initial_adt" = "High Initial ADT"
  ),
  gof_map = c("nobs", "r.squared"),
  title = "The Visibility Premium: Effect of Traffic Exposure on Condition Change by Component",
  notes = c(
    "Standard errors clustered at the state level in parentheses.",
    "Each column uses a different dependent variable: annual change in that component's condition rating.",
    "Deck condition is directly visible to drivers; substructure condition is not.",
    "All models include engineering covariates, state x year FE, and material FE.",
    "Sample size differs slightly from the main results table due to component-specific missing values.",
    "* p < 0.10, ** p < 0.05, *** p < 0.01."
  )
)

## ============================================================
## TABLE 6: Robustness Results
## ============================================================

cat("Table 6: Robustness...\n")

robustness_results <- readRDS(file.path(data_dir, "robustness_results.rds"))

tab6_models <- list(
  "Median Split" = robustness_results$r1_median,
  "Top Quartile" = robustness_results$r1_q4,
  "Age 10+" = robustness_results$r2_old,
  "No Reconstruction" = robustness_results$r3,
  "County Cluster" = robustness_results$r5_county
)

tab6_file <- file.path(tables_dir, "tab6_robustness.tex")
modelsummary(
  tab6_models,
  output = tab6_file,
  stars = c("*" = 0.10, "**" = 0.05, "***" = 0.01),
  coef_map = c(
    "high_initial_adt" = "High Initial ADT",
    "high_adt_median" = "Above Median ADT",
    "high_adt_q4" = "Top Quartile ADT"
  ),
  gof_map = c("nobs", "r.squared"),
  title = "Robustness of the Visibility Premium",
  notes = c(
    "Standard errors clustered as indicated in parentheses.",
    "Outcome: annual change in deck condition rating.",
    "All models include state x year FE, material FE, and engineering covariates.",
    "Column (3) restricts to bridges aged 10+ years.",
    "Column (4) excludes bridges with any reconstruction event.",
    "* p < 0.10, ** p < 0.05, *** p < 0.01."
  )
)

## Replace blank coefficient cells with em-dash
fill_blanks <- function(file) {
  txt <- readLines(file)
  ## Replace empty cells (only whitespace between & separators or & and \\)
  ## Pattern: & followed by only spaces then & or \\
  txt <- gsub("& (\\s*)&", "& --- &", txt)
  txt <- gsub("& (\\s*)&", "& --- &", txt)  # second pass for consecutive blanks
  txt <- gsub("&(\\s*)\\\\\\\\", "& --- \\\\\\\\", txt)
  writeLines(txt, file)
}

fill_blanks(file.path(tables_dir, "tab3_main_results.tex"))
fill_blanks(file.path(tables_dir, "tab4_election_cycle.tex"))
fill_blanks(file.path(tables_dir, "tab5_components.tex"))
fill_blanks(file.path(tables_dir, "tab6_robustness.tex"))

## Add \label tags to modelsummary tables (they don't include them by default)
add_label <- function(file, label) {
  txt <- readLines(file)
  ## Insert \label before \end{table}
  idx <- grep("\\\\end\\{table\\}", txt)
  if (length(idx) > 0) {
    txt <- c(txt[1:(idx[1]-1)], paste0("\\label{", label, "}"), txt[idx[1]:length(txt)])
    writeLines(txt, file)
  }
}

add_label(file.path(tables_dir, "tab3_main_results.tex"), "tab:main")
add_label(file.path(tables_dir, "tab4_election_cycle.tex"), "tab:election")
add_label(file.path(tables_dir, "tab5_components.tex"), "tab:components")
add_label(file.path(tables_dir, "tab6_robustness.tex"), "tab:robustness")

cat("\nAll tables saved to tables/\n")
