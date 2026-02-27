# =============================================================================
# 06_tables.R — All tables for apep_0476
# =============================================================================

source("00_packages.R")

# Load data
panel_summary <- readRDS(file.path(DATA_DIR, "panel_summary.rds"))
census_pop <- readRDS(file.path(DATA_DIR, "census_pop.rds"))
overall_link_rates <- readRDS(file.path(DATA_DIR, "overall_link_rates.rds"))
var_avail <- readRDS(file.path(DATA_DIR, "var_availability.rds"))
balance_df <- readRDS(file.path(DATA_DIR, "balance_tables.rds"))
abe_comparison <- readRDS(file.path(DATA_DIR, "abe_comparison.rds"))
panel_desc <- readRDS(file.path(DATA_DIR, "panel_desc.rds"))
occ_switching <- readRDS(file.path(DATA_DIR, "occ_switching.rds"))
demo_transitions <- readRDS(file.path(DATA_DIR, "demo_transitions.rds"))
migration_named <- readRDS(file.path(DATA_DIR, "migration_named.rds"))
top_corridors <- readRDS(file.path(DATA_DIR, "top_corridors.rds"))
race_patterns <- readRDS(file.path(DATA_DIR, "race_patterns.rds"))
tri_desc <- readRDS(file.path(DATA_DIR, "tri_panel_desc.rds"))
ipw_diag <- readRDS(file.path(DATA_DIR, "ipw_diagnostics.rds"))

# =============================================================================
# Table 1: Panel Summary
# =============================================================================
cat("Table 1: Panel summary\n")

tab1_data <- overall_link_rates %>%
  select(pair_label, n_rows, census_pop_y1, link_rate_pct) %>%
  mutate(
    n_rows = fmt(n_rows),
    census_pop_y1 = fmt(census_pop_y1),
    link_rate_pct = sprintf("%.1f\\%%", link_rate_pct)
  )

# Get 1920 census population for balanced panel link rate
# Must match the pair starting with 1920 (i.e., 1920→1930), not 1910→1920
census_pop_1920 <- overall_link_rates %>%
  filter(grepl("^1920", pair_label)) %>%
  slice(1) %>%
  pull(census_pop_y1)

tri_link_rate <- tri_desc$n / census_pop_1920 * 100

tab1_tex <- sprintf("
\\begin{table}[H]
\\centering
\\caption{MLP Linked Census Panel: Summary Statistics}
\\begin{threeparttable}
\\small
\\begin{tabular}{lccc}
\\toprule
Decade Pair & Linked Individuals & Census Population & Link Rate \\\\
\\midrule
%s
\\midrule
\\multicolumn{4}{l}{\\textit{Balanced Panel}} \\\\
1920$\\rightarrow$1930$\\rightarrow$1940 & %s & %s & %.1f\\%% \\\\
\\bottomrule
\\end{tabular}
\\begin{tablenotes}[flushleft]
\\small
\\item Notes: Census Population is the total count of individuals in the base-year full-count census. Link Rate is the share of the base-year census population that was successfully linked to the subsequent census via the MLP v2.0 crosswalk. For the balanced panel, Census Population is the 1920 base-year population, and Link Rate is the share of that population linked to both 1930 and 1940.
\\end{tablenotes}
\\end{threeparttable}
\\label{tab:panel_summary}
\\end{table}
",
  paste(apply(tab1_data, 1, function(r) {
    sprintf("%s & %s & %s & %s \\\\", r[1], r[2], r[3], r[4])
  }), collapse = "\n"),
  fmt(tri_desc$n),
  fmt(census_pop_1920),
  tri_link_rate
)

writeLines(tab1_tex, file.path(TAB_DIR, "tab1_panel_summary.tex"))

# =============================================================================
# Table 2: Variable Availability Matrix
# =============================================================================
cat("Table 2: Variable availability\n")

# Group variables by category
# Updated for v1 variable list (27 variables, no MOMLOC/POPLOC/SPLOC/LABFORCE/URBAN)
var_avail$category <- c(
  "ID", "Geo", "Geo", "Demo", "Demo", "Demo",  # HISTID, STATEFIP, COUNTYICP, AGE, SEX, RACE
  "Demo", "Demo", "Demo", "HH",                  # BPL, NATIVITY, MARST, RELATE
  "Occ", "Occ", "Occ",                           # OCC1950, IND1950, FARM
  "LF",                                           # CLASSWKR
  "SES", "SES",                                   # OCCSCORE, SEI
  "Edu", "Edu", "Edu",                            # LIT, EDUC, SCHOOL
  "LF", "Econ", "HH", "HH", "HH",               # EMPSTAT, INCWAGE, OWNERSHP, FAMSIZE, NCHILD
  "ID", "ID", "Wt"                                # SERIAL, PERNUM, PERWT
)

check_mark <- function(x) ifelse(x, "\\checkmark", "---")

tab2_rows <- var_avail %>%
  mutate(across(starts_with("y"), check_mark)) %>%
  mutate(row = sprintf("\\texttt{%s} & %s & %s & %s & %s & %s & %s \\\\",
                        variable, y1900, y1910, y1920, y1930, y1940, y1950)) %>%
  pull(row)

tab2_tex <- sprintf("
\\begin{table}[H]
\\centering
\\caption{Variable Availability by Census Year}
\\begin{threeparttable}
\\begin{adjustbox}{max width=\\textwidth}
\\begin{tabular}{lcccccc}
\\toprule
Variable & 1900 & 1910 & 1920 & 1930 & 1940 & 1950 \\\\
\\midrule
%s
\\bottomrule
\\end{tabular}
\\end{adjustbox}
\\begin{tablenotes}[flushleft]
\\small
\\item Notes: \\checkmark\\ indicates variable is available in the IPUMS full-count extract for that year; --- indicates the variable is unavailable in that year's extract. Each linked panel includes only variables available in both the base and target census years. HISTID is the unique person identifier used for crosswalk linkage.
\\end{tablenotes}
\\end{threeparttable}
\\label{tab:var_availability}
\\end{table}
", paste(tab2_rows, collapse = "\n"))

writeLines(tab2_tex, file.path(TAB_DIR, "tab2_var_availability.tex"))

# =============================================================================
# Table 3: Balance Table (Linked vs Unlinked)
# =============================================================================
cat("Table 3: Balance table\n")

balance_rows <- c()
for (i in seq_len(nrow(balance_df))) {
  row <- balance_df[i, ]
  pair <- row$pair

  balance_rows <- c(balance_rows, sprintf(
    "\\multicolumn{3}{l}{\\textbf{%s}} \\\\", gsub("-", "$\\\\rightarrow$", pair)
  ))
  balance_rows <- c(balance_rows, sprintf(
    "\\quad Age & %.1f & %.1f \\\\", row$mean_age_linked, row$mean_age_unlinked
  ))
  balance_rows <- c(balance_rows, sprintf(
    "\\quad Male (\\%%) & %.1f & %.1f \\\\", row$pct_male_linked * 100, row$pct_male_unlinked * 100
  ))
  balance_rows <- c(balance_rows, sprintf(
    "\\quad White (\\%%) & %.1f & %.1f \\\\", row$pct_white_linked * 100, row$pct_white_unlinked * 100
  ))
  balance_rows <- c(balance_rows, sprintf(
    "\\quad Native-born (\\%%) & %.1f & %.1f \\\\", row$pct_native_linked * 100, row$pct_native_unlinked * 100
  ))
  balance_rows <- c(balance_rows, sprintf(
    "\\quad Farm (\\%%) & %.1f & %.1f \\\\", row$pct_farm_linked * 100, row$pct_farm_unlinked * 100
  ))
  balance_rows <- c(balance_rows, sprintf(
    "\\quad N & %s & %s \\\\", fmt(row$n_linked), fmt(row$n_unlinked)
  ))
  if (i < nrow(balance_df)) balance_rows <- c(balance_rows, "\\addlinespace")
}

tab3_tex <- sprintf("
\\begin{table}[H]
\\centering
\\caption{Selection into Linkage: Linked vs.\\ Unlinked Populations}
\\begin{threeparttable}
\\small
\\begin{tabular}{lcc}
\\toprule
& Linked & Unlinked \\\\
\\midrule
%s
\\bottomrule
\\end{tabular}
\\begin{tablenotes}[flushleft]
\\small
\\item Notes: Means of base-year characteristics for individuals who were successfully linked to the subsequent census (Linked) versus those who were not (Unlinked). Differences reflect selection into linkage: linked samples systematically overrepresent native-born, White, male individuals.
\\end{tablenotes}
\\end{threeparttable}
\\label{tab:balance}
\\end{table}
", paste(balance_rows, collapse = "\n"))

writeLines(tab3_tex, file.path(TAB_DIR, "tab3_balance.tex"))

# =============================================================================
# Table 4: ABE vs MLP Comparison
# =============================================================================
cat("Table 4: ABE comparison\n")

if (nrow(abe_comparison) > 0) {
  tab4_rows <- abe_comparison %>%
    mutate(
      pair_label = gsub("-", "$\\\\rightarrow$", pair),
      mlp_str = fmt(mlp_n),
      abe_str = fmt(abe_n),
      ratio = sprintf("%.2f", mlp_n / abe_n)
    )

  tab4_tex <- sprintf("
\\begin{table}[H]
\\centering
\\caption{Linkage Rate Comparison: MLP v2.0 vs.\\ ABE Crosswalks}
\\begin{threeparttable}
\\begin{tabular}{lccc}
\\toprule
Decade Pair & MLP Links & ABE Links & MLP/ABE Ratio \\\\
\\midrule
%s
\\bottomrule
\\end{tabular}
\\begin{tablenotes}[flushleft]
\\small
\\item Notes: MLP = IPUMS Multigenerational Longitudinal Panel v2.0 crosswalk (machine learning-based linking). ABE = Abramitzky, Boustan, and Eriksson Census Linking Project crosswalk (algorithmic linking). Both counts reflect unique 1:1 links after deduplication.
\\end{tablenotes}
\\end{threeparttable}
\\label{tab:abe_comparison}
\\end{table}
",
    paste(apply(tab4_rows, 1, function(r) {
      sprintf("%s & %s & %s & %s \\\\", r["pair_label"], r["mlp_str"], r["abe_str"], r["ratio"])
    }), collapse = "\n")
  )

  writeLines(tab4_tex, file.path(TAB_DIR, "tab4_abe_comparison.tex"))
}

# =============================================================================
# Table 5: Descriptive Patterns — Occupational and Demographic Transitions
# =============================================================================
cat("Table 5: Descriptive transitions\n")

trans_data <- demo_transitions %>%
  left_join(occ_switching, by = "pair") %>%
  left_join(
    panel_desc %>% select(pair, starts_with("mean_sei"), starts_with("mean_delta")),
    by = "pair"
  ) %>%
  mutate(pair_label = gsub("-", "$\\\\rightarrow$", pair))

tab5_rows <- trans_data %>%
  mutate(row = sprintf(
    "%s & %s & %.1f & %.1f & %.1f & %.1f & %.1f \\\\",
    pair_label,
    fmt(n),
    mover_rate * 100,
    switch_rate * 100,
    pct_farm_y1 * 100,
    pct_farm_y2 * 100,
    pct_married_y2 * 100
  )) %>%
  pull(row)

tab5_tex <- sprintf("
\\begin{table}[H]
\\centering
\\caption{Individual-Level Transitions Across Census Decades}
\\begin{threeparttable}
\\small
\\begin{tabular}{lrrrrrr}
\\toprule
Pair & N & Migration & Occ. Switch & Farm (Y1) & Farm (Y2) & Married (Y2) \\\\
& & (\\%%) & (\\%%) & (\\%%) & (\\%%) & (\\%%) \\\\
\\midrule
%s
\\bottomrule
\\end{tabular}
\\begin{tablenotes}[flushleft]
\\small
\\item Notes: N = total linked individuals in each decade pair. Migration = share changing state of residence. Occ.\\ Switch = share changing major occupation group (10-category classification based on OCC1950), computed among individuals with non-missing occupation in both years. Farm = share residing on a farm. Married = share currently married (MARST $\\leq$ 2).
\\end{tablenotes}
\\end{threeparttable}
\\label{tab:transitions}
\\end{table}
", paste(tab5_rows, collapse = "\n"))

writeLines(tab5_tex, file.path(TAB_DIR, "tab5_transitions.tex"))

# =============================================================================
# Table 6: Top Migration Corridors
# =============================================================================
cat("Table 6: Migration corridors\n")

tab6_rows <- top_corridors %>%
  head(15) %>%
  mutate(row = sprintf("%s $\\rightarrow$ %s & %s \\\\",
                        origin_name, dest_name, fmt(total_movers))) %>%
  pull(row)

tab6_tex <- sprintf("
\\begin{table}[H]
\\centering
\\caption{Top Interstate Migration Corridors, 1900--1950}
\\begin{threeparttable}
\\begin{tabular}{lr}
\\toprule
Origin $\\rightarrow$ Destination & Total Movers \\\\
\\midrule
%s
\\bottomrule
\\end{tabular}
\\begin{tablenotes}[flushleft]
\\small
\\item Notes: Cumulative count of linked individuals who moved between the origin and destination states across all five decade pairs (1900$\\rightarrow$1910 through 1940$\\rightarrow$1950). Each individual is counted once per decade pair in which they moved.
\\end{tablenotes}
\\end{threeparttable}
\\label{tab:migration_corridors}
\\end{table}
", paste(tab6_rows, collapse = "\n"))

writeLines(tab6_tex, file.path(TAB_DIR, "tab6_migration_corridors.tex"))

# =============================================================================
# Table 7: Race-Specific Patterns
# =============================================================================
cat("Table 7: Race-specific patterns\n")

race_tab <- race_patterns %>%
  select(pair, race_label, n, mover_rate, pct_farm_y1, pct_farm_y2) %>%
  mutate(
    pair_label = gsub("-", "$\\\\rightarrow$", pair),
    farm_decline = pct_farm_y1 - pct_farm_y2
  )

race_rows <- c()
for (p in unique(race_tab$pair)) {
  w <- race_tab %>% filter(pair == p, race_label == "White")
  b <- race_tab %>% filter(pair == p, race_label == "Black")
  if (nrow(w) == 0 || nrow(b) == 0) next

  race_rows <- c(race_rows, sprintf(
    "\\multicolumn{6}{l}{\\textbf{%s}} \\\\", w$pair_label[1]
  ))
  race_rows <- c(race_rows, sprintf(
    "\\quad White & %s & %.1f & %.1f & %.1f & %.1f \\\\",
    fmt(w$n), w$mover_rate * 100, w$pct_farm_y1 * 100, w$pct_farm_y2 * 100, w$farm_decline * 100
  ))
  race_rows <- c(race_rows, sprintf(
    "\\quad Black & %s & %.1f & %.1f & %.1f & %.1f \\\\",
    fmt(b$n), b$mover_rate * 100, b$pct_farm_y1 * 100, b$pct_farm_y2 * 100, b$farm_decline * 100
  ))
  race_rows <- c(race_rows, "\\addlinespace")
}

tab7_tex <- sprintf("
\\begin{table}[H]
\\centering
\\caption{Mobility Patterns by Race}
\\begin{threeparttable}
\\begin{tabular}{lrrrrr}
\\toprule
& N & Migration & Farm (Y1) & Farm (Y2) & Farm Exit \\\\
& & (\\%%) & (\\%%) & (\\%%) & (pp) \\\\
\\midrule
%s
\\bottomrule
\\end{tabular}
\\begin{tablenotes}[flushleft]
\\small
\\item Notes: Migration = share changing state of residence between census years. Farm Exit = percentage point decline in farm residence (Y1 minus Y2). All rates computed within the linked panel for White and Black individuals separately. N covers White and Black individuals only; individuals of other races (approximately 0.03\\%% of the linked sample) are excluded.
\\end{tablenotes}
\\end{threeparttable}
\\label{tab:race_patterns}
\\end{table}
", paste(race_rows, collapse = "\n"))

writeLines(tab7_tex, file.path(TAB_DIR, "tab7_race_patterns.tex"))

# =============================================================================
# Table A1: IPW Weight Diagnostics (Appendix)
# =============================================================================
cat("Table A1: IPW diagnostics\n")

if (!is.null(ipw_diag)) {
  tab_a1_rows <- ipw_diag %>%
    mutate(
      pair_label = gsub("_", "$\\\\rightarrow$", pair),
      row = sprintf("%s & %s & %.2f & %.2f & %.2f & %.2f & %.2f & %.2f \\\\",
                    pair_label, fmt(n), mean_ipw, p1, p25, p50, p75, p99)
    ) %>%
    pull(row)

  tab_a1_tex <- sprintf("
\\begin{table}[H]
\\centering
\\caption{IPW Weight Distributions}
\\begin{threeparttable}
\\begin{adjustbox}{max width=\\textwidth}
\\begin{tabular}{lrrrrrrr}
\\toprule
Pair & N & Mean & P1 & P25 & P50 & P75 & P99 \\\\
\\midrule
%s
\\bottomrule
\\end{tabular}
\\end{adjustbox}
\\begin{tablenotes}[flushleft]
\\small
\\item Notes: Inverse probability weights constructed from cell-based propensity scores (cells: state $\\times$ race $\\times$ sex $\\times$ age group $\\times$ nativity $\\times$ farm status). Weights are winsorized at the 1st and 99th percentiles.
\\end{tablenotes}
\\end{threeparttable}
\\label{tab:ipw_diagnostics}
\\end{table}
", paste(tab_a1_rows, collapse = "\n"))

  writeLines(tab_a1_tex, file.path(TAB_DIR, "tab_a1_ipw.tex"))
}

cat("\nAll tables saved to", TAB_DIR, "\n")
