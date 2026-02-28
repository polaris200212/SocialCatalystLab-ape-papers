# =============================================================================
# 06_tables.R — Going Up Alone v2 (apep_0478)
# Tables restructured: individual transitions first, SCM supporting
# =============================================================================

source("00_packages.R")

cat("\n========================================\n")
cat("GENERATING TABLES (v2)\n")
cat("========================================\n\n")

# Load data
national    <- fread(file.path(DATA_DIR, "national_clean.csv"))
scm_panel   <- fread(file.path(DATA_DIR, "scm_panel.csv"))
linked      <- fread(file.path(DATA_DIR, "linked_panel_clean.csv"))
trans_matrix <- fread(file.path(DATA_DIR, "transition_matrix.csv"))
trans_race  <- fread(file.path(DATA_DIR, "transition_by_race.csv"))
trans_age   <- fread(file.path(DATA_DIR, "transition_by_age.csv"))

# New v2 data
nyc_summary  <- fread(file.path(DATA_DIR, "nyc_vs_other_summary.csv"))
dest_quality <- fread(file.path(DATA_DIR, "destination_quality.csv"))
ame_df       <- fread(file.path(DATA_DIR, "selection_logit_ame.csv"))
stayer_leav  <- fread(file.path(DATA_DIR, "stayer_leaver_comparison.csv"))
nyc_trans    <- fread(file.path(DATA_DIR, "transition_by_nyc_detail.csv"))

# ─────────────────────────────────────────────────────────────────────────────
# Table 1: National Summary — Elevator Operators by Decade
# ─────────────────────────────────────────────────────────────────────────────

cat("Table 1: National summary...\n")

tab1 <- national[, .(
  Year = year,
  `Total operators` = format(n_elevator_ops, big.mark = ","),
  `Per 10k employed` = sprintf("%.1f", elev_per_10k_emp),
  `Mean age` = sprintf("%.1f", mean_age_elev),
  `Female (%)` = sprintf("%.1f", pct_female),
  `Black (%)` = sprintf("%.1f", pct_black),
  `Under 20 (%)` = sprintf("%.1f", pct_under20),
  `60+ (%)` = sprintf("%.1f", pct_60plus)
)]

tab1_tex <- kable(tab1, format = "latex", booktabs = TRUE,
                  align = c("l", rep("r", 7)),
                  caption = "The Rise and Fall of the Elevator Operator, 1900--1950") %>%
  kable_styling(latex_options = c("hold_position")) %>%
  add_header_above(c(" " = 3, "Demographics" = 5)) %>%
  footnote(general = "Source: IPUMS Full-Count Census, OCC1950 = 761.",
           threeparttable = TRUE)

writeLines(tab1_tex, file.path(TAB_DIR, "tab1_national_summary.tex"))

# ─────────────────────────────────────────────────────────────────────────────
# Table 2: Transition Matrix (full)
# ─────────────────────────────────────────────────────────────────────────────

cat("Table 2: Transition matrix...\n")

setorder(trans_matrix, -N)
tab2 <- trans_matrix[, .(
  `1950 Occupation` = occ_broad_1950,
  N = format(N, big.mark = ","),
  `Share (%)` = sprintf("%.1f", pct)
)]

tab2_tex <- kable(tab2, format = "latex", booktabs = TRUE,
                  caption = "Occupational Transitions: 1940 Elevator Operators in 1950") %>%
  kable_styling(latex_options = c("hold_position")) %>%
  footnote(general = "Source: IPUMS + MLP v2.0 linked panel. Sample: individuals classified as elevator operators (OCC1950=761) in the 1940 census and linked to the 1950 census.",
           threeparttable = TRUE)

writeLines(tab2_tex, file.path(TAB_DIR, "tab2_transition_matrix.tex"))

# ─────────────────────────────────────────────────────────────────────────────
# Table 3: NYC vs Non-NYC Transition Matrix
# ─────────────────────────────────────────────────────────────────────────────

cat("Table 3: NYC vs non-NYC transitions...\n")

# Build wide format: rows = occupation, columns = NYC/Other
nyc_wide <- dcast(nyc_trans, occ_broad_1950 ~ is_nyc_1940,
                  value.var = c("N", "pct"), fill = 0)

# Rename for clarity
if ("pct_0" %in% names(nyc_wide) && "pct_1" %in% names(nyc_wide)) {
  tab3 <- nyc_wide[, .(
    Occupation = occ_broad_1950,
    `NYC (%)` = sprintf("%.1f", pct_1),
    `NYC N` = format(N_1, big.mark = ","),
    `Other (%)` = sprintf("%.1f", pct_0),
    `Other N` = format(N_0, big.mark = ",")
  )]
  setorder(tab3, -`NYC (%)`)

  tab3_tex <- kable(tab3, format = "latex", booktabs = TRUE,
                    caption = "The Paradox of the Epicenter: NYC vs.~Non-NYC Occupational Transitions") %>%
    kable_styling(latex_options = c("hold_position", "scale_down")) %>%
    add_header_above(c(" " = 1, "NYC (Strike Epicenter)" = 2, "Other Cities" = 2)) %>%
    footnote(general = "Source: IPUMS + MLP v2.0 linked panel. NYC = five boroughs (COUNTYICP: Manhattan, Brooklyn, Queens, Bronx, Staten Island).",
             threeparttable = TRUE)

  writeLines(tab3_tex, file.path(TAB_DIR, "tab3_nyc_transition.tex"))
}

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
      "Comparison group: janitors, porters, guards/doorkeepers.",
      "Fixed effects: state, race, sex, age group. SE clustered by state."
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
  SE = sprintf("%.4f", se),
  `p-value` = sprintf("%.3f", p_value)
)]

tab5_tex <- kable(tab5, format = "latex", booktabs = TRUE, escape = FALSE,
                  caption = "Selection into Persistence: Who Remains an Elevator Operator?") %>%
  kable_styling(latex_options = c("hold_position")) %>%
  footnote(general = "Logit model: P(still elevator operator in 1950 | elevator operator in 1940). AME = average marginal effect. Source: IPUMS + MLP v2.0 linked panel.",
           threeparttable = TRUE, escape = FALSE)

writeLines(tab5_tex, file.path(TAB_DIR, "tab5_selection_logit.tex"))

# ─────────────────────────────────────────────────────────────────────────────
# Table 6: Heterogeneity Regressions (Race × Sex × NYC)
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
      "Dependent variable: stayed in same occupation (1940 to 1950).",
      "Source: IPUMS + MLP v2.0 linked panel. SE clustered by state."
    )
  )
}

# ─────────────────────────────────────────────────────────────────────────────
# Table 7: NYC Regressions (Persistence, OCCSCORE, Race interaction)
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
    title = "The Paradox of the Epicenter: NYC vs.~Non-NYC Elevator Operators",
    notes = list(
      "Sample: 1940 elevator operators linked to 1950 census.",
      "Source: IPUMS + MLP v2.0 linked panel. SE clustered by state."
    )
  )
}

# ─────────────────────────────────────────────────────────────────────────────
# Table 8: IPW Comparison (Unweighted vs Weighted)
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
      "IPW weights estimated via logit: P(linked | age, race, sex, nativity, marital, NYC).",
      "Weights trimmed at 99th percentile. Source: IPUMS + MLP v2.0."
    )
  )
}

# ─────────────────────────────────────────────────────────────────────────────
# Table A1 (Appendix): SCM Gap
# ─────────────────────────────────────────────────────────────────────────────

cat("Table A1: SCM gap...\n")

if (file.exists(file.path(DATA_DIR, "scm_results.rds"))) {
  scm_res <- readRDS(file.path(DATA_DIR, "scm_results.rds"))

  if ("gap" %in% names(scm_res)) {
    gap <- scm_res$gap
    gap$Period <- ifelse(gap$year <= 1940, "Pre-treatment", "Post-treatment")

    tab_a1 <- gap[, c("year", "nyc_actual", "nyc_synthetic", "gap", "Period")]
    tab_a1$nyc_actual <- sprintf("%.1f", tab_a1$nyc_actual)
    tab_a1$nyc_synthetic <- sprintf("%.1f", tab_a1$nyc_synthetic)
    tab_a1$gap <- sprintf("%.1f", as.numeric(tab_a1$gap))

    tab_a1_tex <- kable(tab_a1, format = "latex", booktabs = TRUE,
                        col.names = c("Year", "NYC", "Synthetic NYC", "Gap", "Period"),
                        caption = "NYC vs.~Synthetic NYC: Elevator Operators per 1,000 Building Service Workers") %>%
      kable_styling(latex_options = c("hold_position")) %>%
      footnote(general = sprintf("Permutation p-value: %.3f (%d placebos).",
                                  scm_res$p_value, scm_res$n_placebos),
               threeparttable = TRUE)

    writeLines(tab_a1_tex, file.path(TAB_DIR, "tab_a1_scm_gap.tex"))
  }
}

# ─────────────────────────────────────────────────────────────────────────────
# Table A2 (Appendix): Transition by Age Group
# ─────────────────────────────────────────────────────────────────────────────

cat("Table A2: Transition by age...\n")

top_dest <- trans_matrix[order(-N)]$occ_broad_1950[1:6]
trans_age_sub <- trans_age[occ_broad_1950 %in% top_dest]
trans_age_wide <- dcast(trans_age_sub,
                        occ_broad_1950 ~ age_group_1940,
                        value.var = "pct", fill = 0)

for (col in names(trans_age_wide)[-1]) {
  set(trans_age_wide, j = col,
      value = sprintf("%.1f", trans_age_wide[[col]]))
}

tab_a2_tex <- kable(trans_age_wide, format = "latex", booktabs = TRUE,
                    col.names = c("1950 Occupation", names(trans_age_wide)[-1]),
                    caption = "Occupational Transitions by Age Group (1940 Age)") %>%
  kable_styling(latex_options = c("hold_position", "scale_down")) %>%
  footnote(general = "Row percentages within each age group. Source: IPUMS + MLP v2.0.",
           threeparttable = TRUE)

writeLines(tab_a2_tex, file.path(TAB_DIR, "tab_a2_transition_age.tex"))

# ─────────────────────────────────────────────────────────────────────────────
# Table A3 (Appendix): SCM Robustness (Triple-diff, Event study)
# ─────────────────────────────────────────────────────────────────────────────

cat("Table A3: SCM robustness...\n")

if (file.exists(file.path(DATA_DIR, "robustness_results.rds"))) {
  rob <- readRDS(file.path(DATA_DIR, "robustness_results.rds"))

  rob_list <- list(
    "Event Study" = rob$event_study,
    "Triple Diff" = rob$triple_diff,
    "Excl. Janitors" = rob$no_janitor
  )

  modelsummary(rob_list,
    output = file.path(TAB_DIR, "tab_a3_robustness.tex"),
    stars = c('*' = 0.1, '**' = 0.05, '***' = 0.01),
    gof_map = c("nobs", "r.squared"),
    title = "Robustness Checks",
    notes = list(
      "Source: IPUMS Full-Count Census, 1900--1950.",
      "Triple diff: elevator vs janitor x NYC x post-1945."
    )
  )
}

cat("\n========================================\n")
cat("TABLES COMPLETE\n")
cat(sprintf("Saved %d tables to %s\n", length(list.files(TAB_DIR, "*.tex")), TAB_DIR))
cat("========================================\n")
