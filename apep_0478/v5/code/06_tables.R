# =============================================================================
# 06_tables.R — Going Up Alone v4 (apep_0478)
# v4: Full arc table, metro comparison, OCC1950 sensitivity, updated rates
# =============================================================================

source("00_packages.R")

cat("\n========================================\n")
cat("GENERATING TABLES (v4)\n")
cat("========================================\n\n")

# Load data
national    <- fread(file.path(DATA_DIR, "national_clean.csv"))
full_arc    <- fread(file.path(DATA_DIR, "full_arc_1900_1980.csv"))
linked      <- fread(file.path(DATA_DIR, "linked_panel_clean.csv"))
trans_matrix <- fread(file.path(DATA_DIR, "transition_matrix.csv"))
trans_race  <- fread(file.path(DATA_DIR, "transition_by_race.csv"))
trans_age   <- fread(file.path(DATA_DIR, "transition_by_age.csv"))
nyc_summary  <- fread(file.path(DATA_DIR, "nyc_vs_other_summary.csv"))
ame_df       <- fread(file.path(DATA_DIR, "selection_logit_ame.csv"))
nyc_trans    <- fread(file.path(DATA_DIR, "transition_by_nyc_detail.csv"))

# Optional
metro_panel <- if (file.exists(file.path(DATA_DIR, "metro_panel.csv")))
                 fread(file.path(DATA_DIR, "metro_panel.csv")) else NULL

# ─────────────────────────────────────────────────────────────────────────────
# Table 1: The Full Arc — National Summary (1900-1980)
# ─────────────────────────────────────────────────────────────────────────────

cat("Table 1: Full arc national summary...\n")

tab1 <- full_arc[, .(
  Year = year,
  `Total operators` = format(n_elevator_ops, big.mark = ","),
  `Per 10k employed` = sprintf("%.1f", elev_per_10k_emp),
  Source = fifelse(source == "full-count", "Full-count", "Published")
)]

tab1_tex <- kable(tab1, format = "latex", booktabs = TRUE,
                  align = c("l", "r", "r", "l"),
                  caption = "Rise, Plateau, and Extinction: Elevator Operators in the United States, 1900--1980") %>%
  kable_styling(latex_options = c("hold_position")) %>%
  footnote(general = "Sources: IPUMS Full-Count Census (1900--1950); Census of Population, Detailed Characteristics (1960--1980). Employed denominator excludes OCC1950 special codes (0, 979--999).",
           threeparttable = TRUE)

writeLines(tab1_tex, file.path(TAB_DIR, "tab1_full_arc.tex"))

# ─────────────────────────────────────────────────────────────────────────────
# Table 2: Metro Comparison (Top 15, 1940→1950)
# ─────────────────────────────────────────────────────────────────────────────

cat("Table 2: Metro comparison...\n")

if (!is.null(metro_panel)) {
  # Aggregate NYC boroughs
  nyc_agg <- metro_panel[metro_name %in% c("Manhattan", "Brooklyn", "Queens",
                                            "Bronx", "Staten Island"),
                          .(n_elevator_ops = sum(n_elevator_ops),
                            total_employed = sum(total_employed),
                            metro_name = "New York City"), by = year]
  nyc_agg[, elev_per_10k_emp := n_elevator_ops / total_employed * 10000]

  other_metros <- metro_panel[!metro_name %in% c("Manhattan", "Brooklyn", "Queens",
                                                   "Bronx", "Staten Island")]

  metro_all <- rbind(
    nyc_agg[, .(year, metro_name, n_elevator_ops, total_employed, elev_per_10k_emp)],
    other_metros[, .(year, metro_name, n_elevator_ops, total_employed, elev_per_10k_emp)]
  )

  metro_wide <- dcast(metro_all[year %in% c(1940, 1950)],
                      metro_name ~ year,
                      value.var = c("n_elevator_ops", "elev_per_10k_emp"))

  # Only keep metros with data in both years
  metro_wide <- metro_wide[!is.na(n_elevator_ops_1940) & !is.na(n_elevator_ops_1950)]
  metro_wide[, change_pct := (elev_per_10k_emp_1950 - elev_per_10k_emp_1940) /
                              elev_per_10k_emp_1940 * 100]
  setorder(metro_wide, -n_elevator_ops_1940)

  tab2 <- metro_wide[1:min(15, nrow(metro_wide)), .(
    Metro = metro_name,
    `1940 (N)` = format(n_elevator_ops_1940, big.mark = ","),
    `1940 (per 10k)` = sprintf("%.1f", elev_per_10k_emp_1940),
    `1950 (N)` = format(n_elevator_ops_1950, big.mark = ","),
    `1950 (per 10k)` = sprintf("%.1f", elev_per_10k_emp_1950),
    `Change (%)` = sprintf("%+.1f", change_pct)
  )]

  tab2_tex <- kable(tab2, format = "latex", booktabs = TRUE,
                    align = c("l", rep("r", 5)),
                    caption = "Elevator Operators in Major Metropolitan Areas, 1940 vs.~1950") %>%
    kable_styling(latex_options = c("hold_position", "scale_down")) %>%
    add_header_above(c(" " = 1, "1940" = 2, "1950" = 2, " " = 1)) %>%
    footnote(general = "Source: IPUMS Full-Count Census. Metro identified by primary county COUNTYICP. Per 10k = per 10,000 employed.",
             threeparttable = TRUE)

  writeLines(tab2_tex, file.path(TAB_DIR, "tab2_metro_comparison.tex"))
}

# ─────────────────────────────────────────────────────────────────────────────
# Table 3: Transition Matrix
# ─────────────────────────────────────────────────────────────────────────────

cat("Table 3: Transition matrix...\n")

setorder(trans_matrix, -N)
tab3 <- trans_matrix[, .(
  `1950 Occupation` = occ_broad_1950,
  N = format(N, big.mark = ","),
  `Share (%)` = sprintf("%.1f", pct)
)]

tab3_tex <- kable(tab3, format = "latex", booktabs = TRUE,
                  caption = "Occupational Transitions: 1940 Elevator Operators in 1950") %>%
  kable_styling(latex_options = c("hold_position")) %>%
  footnote(general = "Source: IPUMS + MLP v2.0 linked panel. N = 38,562 elevator operators in 1940 linked to 1950 census.",
           threeparttable = TRUE)

writeLines(tab3_tex, file.path(TAB_DIR, "tab3_transition_matrix.tex"))

# ─────────────────────────────────────────────────────────────────────────────
# Table 4: Core Displacement Regressions
# ─────────────────────────────────────────────────────────────────────────────

cat("Table 4: Displacement regressions...\n")

if (file.exists(file.path(DATA_DIR, "displacement_regs.rds"))) {
  regs <- readRDS(file.path(DATA_DIR, "displacement_regs.rds"))

  reg_list <- list(
    "Same Occ." = regs$stay,
    "Interstate Move" = regs$move,
    "OCCSCORE Change" = regs$occ
  )

  options("modelsummary_format_numeric_latex" = "plain")
  modelsummary(reg_list,
    output = file.path(TAB_DIR, "tab4_displacement_regs.tex"),
    stars = c('*' = 0.1, '**' = 0.05, '***' = 0.01),
    gof_map = c("nobs", "r.squared", "adj.r.squared"),
    title = "Individual Displacement: Elevator Operators vs.~Other Building Service Workers",
    notes = list(
      "Source: IPUMS + MLP v2.0 linked panel, 1940--1950.",
      "Comparison: janitors, porters, guards, charwomen/cleaners, housekeepers.",
      "FE: state, race, sex, age group. SE clustered by state."
    )
  )
}

# ─────────────────────────────────────────────────────────────────────────────
# Table 5: Selection into Persistence (Logit)
# ─────────────────────────────────────────────────────────────────────────────

cat("Table 5: Selection logit...\n")

ame_clean <- ame_df[variable != "(Intercept)"]
ame_clean[, variable := fcase(
  variable == "age_centered", "Age (centered)",
  variable == "age_centered_sq", "Age$^2$",
  variable == "is_black", "Black",
  variable == "is_female", "Female",
  variable == "is_native", "Native-born",
  variable == "is_married", "Married",
  variable == "is_nyc_1940", "NYC resident",
  default = variable
)]

tab5 <- ame_clean[, .(
  Variable = variable,
  Coefficient = sprintf("%.4f", coefficient),
  AME = sprintf("%.4f", ame),
  `Coef. SE` = sprintf("%.4f", se),
  `p-value` = sprintf("%.3f", p_value)
)]

tab5_tex <- kable(tab5, format = "latex", booktabs = TRUE, escape = FALSE,
                  caption = "Selection into Persistence: Who Remains an Elevator Operator?") %>%
  kable_styling(latex_options = c("hold_position")) %>%
  footnote(general = "Logit model: P(still elevator operator in 1950 $|$ elevator operator in 1940). AME = average marginal effect. SE and p-value refer to the logit coefficient, not the AME. $N = 38{,}562$ elevator operators.",
           threeparttable = TRUE, escape = FALSE)

writeLines(tab5_tex, file.path(TAB_DIR, "tab5_selection_logit.tex"))

# ─────────────────────────────────────────────────────────────────────────────
# Table 6: Heterogeneity Regressions
# ─────────────────────────────────────────────────────────────────────────────

cat("Table 6: Heterogeneity regressions...\n")

if (file.exists(file.path(DATA_DIR, "displacement_regs.rds"))) {
  regs <- readRDS(file.path(DATA_DIR, "displacement_regs.rds"))

  het_list <- list(
    "Race" = regs$race,
    "Sex" = regs$sex,
    "NYC" = regs$nyc
  )

  modelsummary(het_list,
    output = file.path(TAB_DIR, "tab6_heterogeneity.tex"),
    stars = c('*' = 0.1, '**' = 0.05, '***' = 0.01),
    gof_map = c("nobs", "r.squared"),
    title = "Heterogeneous Displacement: By Race, Sex, and City",
    notes = list(
      "DV: stayed in same occupation (1940 to 1950).",
      "SE clustered by state."
    )
  )
}

# ─────────────────────────────────────────────────────────────────────────────
# Table 7: NYC Regressions
# ─────────────────────────────────────────────────────────────────────────────

cat("Table 7: NYC regressions...\n")

if (file.exists(file.path(DATA_DIR, "displacement_regs.rds"))) {
  regs <- readRDS(file.path(DATA_DIR, "displacement_regs.rds"))

  nyc_list <- list(
    "Still Elevator" = regs$nyc_stay,
    "OCCSCORE Change" = regs$nyc_occ,
    "Persist x Race" = regs$nyc_race
  )

  modelsummary(nyc_list,
    output = file.path(TAB_DIR, "tab7_nyc_regressions.tex"),
    stars = c('*' = 0.1, '**' = 0.05, '***' = 0.01),
    gof_map = c("nobs", "r.squared"),
    title = "NYC vs.~Non-NYC: Institutional Thickness and Displacement",
    notes = list(
      "Sample: 1940 elevator operators linked to 1950 census.",
      "SE clustered by state."
    )
  )
}

# ─────────────────────────────────────────────────────────────────────────────
# Table 8: IPW Comparison
# ─────────────────────────────────────────────────────────────────────────────

cat("Table 8: IPW comparison...\n")

if (file.exists(file.path(DATA_DIR, "displacement_regs.rds")) &&
    file.exists(file.path(DATA_DIR, "robustness_results.rds"))) {
  regs <- readRDS(file.path(DATA_DIR, "displacement_regs.rds"))
  rob <- readRDS(file.path(DATA_DIR, "robustness_results.rds"))

  ipw_list <- list(
    "Same Occ. (Unwtd)" = regs$stay,
    "Same Occ. (IPW)" = rob$stay_ipw,
    "OCCSCORE (Unwtd)" = regs$occ,
    "OCCSCORE (IPW)" = rob$occ_ipw
  )

  modelsummary(ipw_list,
    output = file.path(TAB_DIR, "tab8_ipw_comparison.tex"),
    stars = c('*' = 0.1, '**' = 0.05, '***' = 0.01),
    gof_map = c("nobs", "r.squared"),
    title = "Inverse Probability Weighting: Addressing Linkage Selection Bias",
    notes = list(
      "IPW weights from logit: P(linked $|$ age, race, sex, nativity, marital, NYC).",
      "Weights trimmed at 99th percentile."
    )
  )
}

cat("\n========================================\n")
cat("TABLES COMPLETE\n")
cat(sprintf("Saved %d tables to %s\n", length(list.files(TAB_DIR, "*.tex")), TAB_DIR))
cat("========================================\n")
