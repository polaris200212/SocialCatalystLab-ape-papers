## 06_tables.R — All table generation
## APEP-0237: Flood Risk Disclosure Laws and Housing Market Capitalization

source("00_packages.R")

data_dir <- "../data/"
table_dir <- "../tables/"
dir.create(table_dir, showWarnings = FALSE, recursive = TRUE)

panel <- fread(paste0(data_dir, "panel_annual.csv"))
treatment <- read_csv(paste0(data_dir, "treatment_disclosure_laws.csv"),
                      show_col_types = FALSE)
models <- readRDS(paste0(data_dir, "main_models.rds"))
robustness <- readRDS(paste0(data_dir, "robustness_models.rds"))

# ============================================================================
# Table 1: Summary Statistics
# ============================================================================
cat("Creating Table 1: Summary Statistics...\n")

# Compute summary stats by treatment group and flood exposure
sumstat_groups <- panel %>%
  mutate(
    group = case_when(
      treated == 1 & high_flood == 1 ~ "Treated, High Flood",
      treated == 1 & high_flood == 0 ~ "Treated, Low Flood",
      treated == 0 & high_flood == 1 ~ "Control, High Flood",
      treated == 0 & high_flood == 0 ~ "Control, Low Flood"
    )
  ) %>%
  filter(!is.na(group)) %>%
  group_by(group) %>%
  summarize(
    Counties = n_distinct(fips),
    States = n_distinct(state_abbr),
    `Mean ZHVI` = sprintf("$%s", format(round(mean(zhvi, na.rm = TRUE)), big.mark = ",")),
    `SD ZHVI` = sprintf("$%s", format(round(sd(zhvi, na.rm = TRUE)), big.mark = ",")),
    `Mean Flood Declarations` = round(mean(n_flood_decl_pre, na.rm = TRUE), 1),
    `County-Years` = format(n(), big.mark = ","),
    .groups = "drop"
  )

# Write as LaTeX
sink(paste0(table_dir, "tab1_summary.tex"))
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Summary Statistics by Treatment and Flood Exposure}\n")
cat("\\label{tab:summary}\n")
cat("\\begin{tabular}{lcccccc}\n")
cat("\\hline\\hline\n")
cat("Group & Counties & States & Mean ZHVI & SD ZHVI & Flood Decl. & County-Years \\\\\n")
cat("\\hline\n")
for (i in 1:nrow(sumstat_groups)) {
  row <- sumstat_groups[i, ]
  cat(sprintf("%s & %d & %d & %s & %s & %.1f & %s \\\\\n",
              row$group, row$Counties, row$States,
              row$`Mean ZHVI`, row$`SD ZHVI`,
              row$`Mean Flood Declarations`, row$`County-Years`))
}
cat("\\hline\\hline\n")
cat("\\end{tabular}\n")
cat("\\begin{minipage}{0.95\\textwidth}\n")
cat("\\footnotesize\\textit{Notes:} Summary statistics for the county-year panel, 2000--2024.")
cat(" ``High Flood'' counties have above-median pre-treatment (pre-1992) FEMA flood declarations within their state, conditional on having at least one declaration.")
cat(" ZHVI is the Zillow Home Value Index (typical home value, seasonally adjusted).")
cat(" Flood Declarations is the count of unique FEMA major disaster declarations for flood events in 1953--1991.\n")
cat("\\end{minipage}\n")
cat("\\end{table}\n")
sink()

# ============================================================================
# Table 2: Main DDD Results
# ============================================================================
cat("Creating Table 2: Main DDD results...\n")

sink(paste0(table_dir, "tab2_main_results.tex"))
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Effect of Flood Disclosure Laws on Housing Values}\n")
cat("\\label{tab:main}\n")
cat("\\begin{tabular}{lcccc}\n")
cat("\\hline\\hline\n")
cat(" & (1) & (2) & (3) & (4) \\\\\n")
cat(" & DDD Basic & DDD & Any Flood & Continuous \\\\\n")
cat("\\hline\n")

# Extract coefficients for each model
cat("Coefficient")
for (mname in c("m1", "m2", "m3", "m4")) {
  m <- models[[mname]]
  coefs <- coef(m)
  ses <- se(m)
  pvs <- fixest::pvalue(m)

  # Find the interaction term
  int_name <- names(coefs)[grep("post_x", names(coefs))][1]
  if (!is.na(int_name)) {
    stars <- ifelse(pvs[int_name] < 0.01, "***",
             ifelse(pvs[int_name] < 0.05, "**",
             ifelse(pvs[int_name] < 0.1, "*", "")))
    cat(sprintf(" & %.4f%s", coefs[int_name], stars))
  }
}
cat(" \\\\\n")

# Standard errors
for (mname in c("m1", "m2", "m3", "m4")) {
  m <- models[[mname]]
  ses <- se(m)
  int_name <- names(ses)[grep("post_x", names(ses))][1]
  if (!is.na(int_name)) {
    cat(sprintf(" & (%.4f)", ses[int_name]))
  }
}
cat(" \\\\\n")

# Row labels
cat("\\hline\n")
cat("Post $\\times$ High Flood & \\checkmark & \\checkmark & & \\\\\n")
cat("Post $\\times$ Any Flood & & & \\checkmark & \\\\\n")
cat("Post $\\times$ Flood Count & & & & \\checkmark \\\\\n")
cat("\\hline\n")
cat("County FE & \\checkmark & \\checkmark & \\checkmark & \\checkmark \\\\\n")
cat("State $\\times$ Year FE & \\checkmark & \\checkmark & \\checkmark & \\checkmark \\\\\n")

# N and R-squared
cat("Observations")
for (mname in c("m1", "m2", "m3", "m4")) {
  m <- models[[mname]]
  cat(sprintf(" & %s", format(m$nobs, big.mark = ",")))
}
cat(" \\\\\n")

cat("$R^2$ (within)")
for (mname in c("m1", "m2", "m3", "m4")) {
  m <- models[[mname]]
  r2 <- fitstat(m, "r2")$r2
  cat(sprintf(" & %.3f", r2))
}
cat(" \\\\\n")

cat("\\hline\\hline\n")
cat("\\end{tabular}\n")
cat("\\begin{minipage}{0.95\\textwidth}\n")
cat("\\footnotesize\\textit{Notes:} All specifications include county and state-by-year fixed effects.")
cat(" Standard errors clustered at the state level in parentheses.")
cat(" The dependent variable is log Zillow Home Value Index (ZHVI).")
cat(" ``Post'' indicates the state has adopted a flood disclosure law.")
cat(" ``High Flood'' is an indicator for counties in the above-median of pre-1992 FEMA flood declarations within their state.")
cat(" ``Any Flood'' indicates counties with at least one pre-1992 flood declaration.")
cat(" ``Flood Count'' is the number of pre-1992 flood declarations (continuous).")
cat(" $^{***}p<0.01$, $^{**}p<0.05$, $^{*}p<0.1$.\n")
cat("\\end{minipage}\n")
cat("\\end{table}\n")
sink()

# ============================================================================
# Table 3: Robustness Results
# ============================================================================
cat("Creating Table 3: Robustness...\n")

sink(paste0(table_dir, "tab3_robustness.tex"))
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Robustness Checks}\n")
cat("\\label{tab:robustness}\n")
cat("\\begin{tabular}{lccccc}\n")
cat("\\hline\\hline\n")
cat(" & (1) & (2) & (3) & (4) & (5) \\\\\n")
cat(" & Main & Placebo & Intensity & Third Wave & Two-Way CL \\\\\n")
cat("\\hline\n")

# Extract results from each robustness model
rob_names <- c("state_cluster", "placebo", "intensity", "third_wave", "twoway_cluster")
for (rname in rob_names) {
  m <- robustness[[rname]]
  if (is.null(m)) next
  coefs <- coef(m)
  ses <- se(m)
  pvs <- fixest::pvalue(m)
  int_name <- names(coefs)[1]
  stars <- ifelse(pvs[int_name] < 0.01, "***",
           ifelse(pvs[int_name] < 0.05, "**",
           ifelse(pvs[int_name] < 0.1, "*", "")))

  if (rname == rob_names[1]) cat("Coefficient")
  cat(sprintf(" & %.4f%s", coefs[int_name], stars))
}
cat(" \\\\\n")

for (rname in rob_names) {
  m <- robustness[[rname]]
  if (is.null(m)) next
  ses <- se(m)
  int_name <- names(ses)[1]
  if (rname == rob_names[1]) cat(" ")
  cat(sprintf(" & (%.4f)", ses[int_name]))
}
cat(" \\\\\n")

cat("\\hline\n")
cat("County FE & \\checkmark & \\checkmark & \\checkmark & \\checkmark & \\checkmark \\\\\n")
cat("State $\\times$ Year FE & \\checkmark & \\checkmark & \\checkmark & \\checkmark & \\checkmark \\\\\n")

cat("Observations")
for (rname in rob_names) {
  m <- robustness[[rname]]
  if (is.null(m)) next
  cat(sprintf(" & %s", format(m$nobs, big.mark = ",")))
}
cat(" \\\\\n")

cat("\\hline\\hline\n")
cat("\\end{tabular}\n")
cat("\\begin{minipage}{0.95\\textwidth}\n")
cat("\\footnotesize\\textit{Notes:} Column (1) replicates the main DDD specification.")
cat(" Column (2) is a placebo test using only counties with zero pre-1992 flood declarations.")
cat(" Column (3) uses NRDC disclosure grade intensity (0--4 scale) interacted with post and high-flood.")
cat(" Column (4) restricts to the third wave of adopters (2019--2024) vs.~never-treated states.")
cat(" Column (5) uses two-way clustering by state and year.")
cat(" $^{***}p<0.01$, $^{**}p<0.05$, $^{*}p<0.1$.\n")
cat("\\end{minipage}\n")
cat("\\end{table}\n")
sink()

# ============================================================================
# Table 4: Treatment Variable — State Adoption Dates
# ============================================================================
cat("Creating Table 4: Treatment variable...\n")

sink(paste0(table_dir, "tab4_treatment_states.tex"))
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{State Flood Disclosure Law Adoption Dates}\n")
cat("\\label{tab:treatment}\n")
cat("\\begin{tabular}{llcc}\n")
cat("\\hline\\hline\n")
cat("State & Year & Wave & NRDC Grade \\\\\n")
cat("\\hline\n")

treated_sorted <- treatment %>%
  filter(year_adopted > 0) %>%
  arrange(year_adopted, state_name)

for (i in 1:nrow(treated_sorted)) {
  row <- treated_sorted[i, ]
  wave_label <- switch(row$wave,
    "first" = "First (1992--1999)",
    "second" = "Second (2000--2006)",
    "third" = "Third (2019--2024)")
  cat(sprintf("%s & %d & %s & %s \\\\\n",
              row$state_name, row$year_adopted, wave_label, row$grade_2024))
}

cat("\\hline\n")
cat("\\multicolumn{4}{l}{\\textit{Never-Treated States (no mandatory disclosure):}} \\\\\n")
cat("\\multicolumn{4}{l}{AL, AR, AZ, CO, GA, ID, KS, MA, MD, MN, MO, MT, NM, RI, UT, VA, WI, WV, WY} \\\\\n")
cat("\\hline\\hline\n")
cat("\\end{tabular}\n")
cat("\\begin{minipage}{0.95\\textwidth}\n")
cat("\\footnotesize\\textit{Notes:} Adoption dates reflect when states first required sellers to disclose")
cat(" flood-related information (flood zone status, flooding history, flood damage, or flood insurance)")
cat(" as part of mandatory property condition disclosure.")
cat(" NRDC grades from the Natural Resources Defense Council 2024 State Flood Disclosure Scorecard.")
cat(" States with grade F have no mandatory flood disclosure requirement.\n")
cat("\\end{minipage}\n")
cat("\\end{table}\n")
sink()

cat("\n============================================\n")
cat("TABLE GENERATION COMPLETE\n")
cat("============================================\n")
