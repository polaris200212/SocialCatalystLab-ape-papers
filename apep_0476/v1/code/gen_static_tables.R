# Generate tables that don't require Azure data
source("00_packages.R")

# =============================================================================
# Variable availability table
# =============================================================================
var_avail <- tibble(
  variable = c("HISTID", "STATEFIP", "COUNTYICP", "AGE", "SEX", "RACE",
               "BPL", "NATIVITY", "MARST", "RELATE",
               "OCC1950", "IND1950", "FARM",
               "CLASSWKR",
               "OCCSCORE", "SEI",
               "LIT", "EDUC", "SCHOOL",
               "EMPSTAT", "INCWAGE", "OWNERSHP", "FAMSIZE", "NCHILD",
               "SERIAL", "PERNUM", "PERWT"),
  y1900 = c(T,T,T,T,T,T,T,T,T,T,T,T,T,F,T,F,T,F,T,F,F,T,T,T,T,T,T),
  y1910 = c(T,T,T,T,T,T,T,T,T,T,T,T,T,T,T,F,T,F,T,F,F,T,T,T,T,T,T),
  y1920 = c(T,T,T,T,T,T,T,T,T,T,T,T,T,T,T,T,T,F,T,F,F,T,T,T,T,T,T),
  y1930 = c(T,T,T,T,T,T,T,T,T,T,T,T,T,T,T,T,T,F,T,F,F,T,T,T,T,T,T),
  y1940 = c(T,T,T,T,T,T,T,T,T,T,T,T,T,T,T,T,F,T,T,T,T,T,T,T,T,T,T),
  y1950 = c(T,T,T,T,T,T,T,T,T,T,T,T,T,T,T,F,F,T,T,T,T,F,F,T,T,T,T)
)

check <- function(x) ifelse(x, "\\checkmark", "---")

rows <- var_avail %>%
  mutate(across(starts_with("y"), check)) %>%
  mutate(row = sprintf("\\texttt{%s} & %s & %s & %s & %s & %s & %s \\\\",
                        variable, y1900, y1910, y1920, y1930, y1940, y1950)) %>%
  pull(row)

tex <- paste0(
"\\begin{table}[H]
\\centering
\\caption{Variable Availability by Census Year}
\\begin{threeparttable}
\\begin{adjustbox}{max width=\\textwidth}
\\begin{tabular}{lcccccc}
\\toprule
Variable & 1900 & 1910 & 1920 & 1930 & 1940 & 1950 \\\\
\\midrule
", paste(rows, collapse = "\n"), "
\\bottomrule
\\end{tabular}
\\end{adjustbox}
\\begin{tablenotes}[flushleft]
\\small
\\item Notes: \\checkmark\\ indicates variable is available in the IPUMS full-count extract for that year. Each linked panel includes only variables available in both the base and target census years. HISTID is the unique person identifier used for crosswalk linkage.
\\end{tablenotes}
\\end{threeparttable}
\\label{tab:var_availability}
\\end{table}
")

writeLines(tex, file.path(TAB_DIR, "tab2_var_availability.tex"))
cat("Generated tab2_var_availability.tex\n")

# =============================================================================
# Create placeholder files for tables that need Azure data
# =============================================================================
placeholders <- c(
  "tab1_panel_summary.tex",
  "tab3_balance.tex",
  "tab4_abe_comparison.tex",
  "tab5_transitions.tex",
  "tab6_migration_corridors.tex",
  "tab7_race_patterns.tex"
)

for (f in placeholders) {
  path <- file.path(TAB_DIR, f)
  if (!file.exists(path)) {
    writeLines(sprintf(
      "\\begin{table}[H]\n\\centering\n\\caption{[To be generated from Azure data]}\n\\label{tab:%s}\n\\end{table}",
      gsub("\\.tex$", "", f)
    ), path)
    cat("  Created placeholder:", f, "\n")
  }
}

# Create placeholder figure PDFs
for (f in paste0("fig", 1:10, c("_link_rates", "_link_rates_demographics",
                                  "_selection_balance", "_sei_mobility",
                                  "_occ_transitions", "_migration_rates",
                                  "_farm_exit_race", "_abe_comparison",
                                  "_occ_switching", "_demo_transitions"), ".pdf")) {
  path <- file.path(FIG_DIR, f)
  if (!file.exists(path)) {
    # Create a minimal valid PDF
    pdf(path, width = 8, height = 5)
    plot.new()
    text(0.5, 0.5, paste("Placeholder:", f), cex = 1.5)
    dev.off()
    cat("  Created placeholder figure:", f, "\n")
  }
}

cat("\nStatic tables and placeholders generated.\n")
