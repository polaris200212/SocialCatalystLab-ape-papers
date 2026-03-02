# =============================================================================
# 06_tables.R — Going Up Alone (apep_0478)
# Generate all tables for the paper
# =============================================================================

source("00_packages.R")

cat("\n========================================\n")
cat("GENERATING TABLES\n")
cat("========================================\n\n")

# Load data
national    <- fread(file.path(DATA_DIR, "national_clean.csv"))
scm_panel   <- fread(file.path(DATA_DIR, "scm_panel.csv"))
linked      <- fread(file.path(DATA_DIR, "linked_panel_clean.csv"))
trans_matrix <- fread(file.path(DATA_DIR, "transition_matrix.csv"))
trans_race  <- fread(file.path(DATA_DIR, "transition_by_race.csv"))
trans_age   <- fread(file.path(DATA_DIR, "transition_by_age.csv"))

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

# LaTeX output
tab1_tex <- kable(tab1, format = "latex", booktabs = TRUE,
                  align = c("l", rep("r", 7)),
                  caption = "The Rise and Fall of the Elevator Operator, 1900--1950") %>%
  kable_styling(latex_options = c("hold_position")) %>%
  add_header_above(c(" " = 3, "Demographics" = 5)) %>%
  footnote(general = "Source: IPUMS Full-Count Census, OCC1950 = 761.",
           threeparttable = TRUE)

writeLines(tab1_tex, file.path(TAB_DIR, "tab1_national_summary.tex"))

# ─────────────────────────────────────────────────────────────────────────────
# Table 2: SCM Predictor Balance
# ─────────────────────────────────────────────────────────────────────────────

cat("Table 2: SCM balance...\n")

if (file.exists(file.path(DATA_DIR, "scm_results.rds"))) {
  scm_res <- readRDS(file.path(DATA_DIR, "scm_results.rds"))

  if ("tables" %in% names(scm_res)) {
    pred_balance <- scm_res$tables$tab.pred
    # Clean row names
    var_names <- rownames(pred_balance)
    var_names <- gsub("special\\.", "", var_names)
    var_names <- gsub("\\.", " ", var_names)

    tab2 <- data.table(
      Variable = var_names,
      NYC = sprintf("%.2f", pred_balance[, 1]),
      Synthetic = sprintf("%.2f", pred_balance[, 2]),
      DonorMean = sprintf("%.2f", pred_balance[, 3])
    )

    tab2_tex <- kable(tab2, format = "latex", booktabs = TRUE,
                      col.names = c("Variable", "NYC", "Synthetic NYC", "Donor Mean"),
                      caption = "SCM Predictor Balance: NYC vs.~Synthetic NYC") %>%
      kable_styling(latex_options = c("hold_position")) %>%
      footnote(general = "Pre-treatment means (1900--1940).",
               threeparttable = TRUE)

    writeLines(tab2_tex, file.path(TAB_DIR, "tab2_scm_balance.tex"))
  }

  # SCM Weights table
  if ("weights" %in% names(scm_res)) {
    w <- scm_res$weights[scm_res$weights$weight > 0.01, c("state_name", "weight")]
    w$weight <- sprintf("%.3f", w$weight)

    tab2b_tex <- kable(w, format = "latex", booktabs = TRUE, row.names = FALSE,
                       col.names = c("State", "Weight"),
                       caption = "SCM Donor Weights (weights $> 0.01$)") %>%
      kable_styling(latex_options = c("hold_position")) %>%
      footnote(general = "Weights selected to minimize pre-treatment MSPE.",
               threeparttable = TRUE)

    writeLines(tab2b_tex, file.path(TAB_DIR, "tab2b_scm_weights.tex"))
  }
}

# ─────────────────────────────────────────────────────────────────────────────
# Table 3: SCM Results — Gap
# ─────────────────────────────────────────────────────────────────────────────

cat("Table 3: SCM gap...\n")

if (file.exists(file.path(DATA_DIR, "scm_results.rds"))) {
  scm_res <- readRDS(file.path(DATA_DIR, "scm_results.rds"))

  if ("gap" %in% names(scm_res)) {
    gap <- scm_res$gap
    gap$Period <- ifelse(gap$year <= 1940, "Pre-treatment", "Post-treatment")

    tab3 <- gap[, c("year", "nyc_actual", "nyc_synthetic", "gap", "Period")]
    tab3$nyc_actual <- sprintf("%.1f", tab3$nyc_actual)
    tab3$nyc_synthetic <- sprintf("%.1f", tab3$nyc_synthetic)
    tab3$gap <- sprintf("%.1f", as.numeric(tab3$gap))

    tab3_tex <- kable(tab3, format = "latex", booktabs = TRUE,
                      col.names = c("Year", "NYC", "Synthetic NYC", "Gap", "Period"),
                      caption = "NYC vs.~Synthetic NYC: Elevator Operators per 1,000 Building Service Workers") %>%
      kable_styling(latex_options = c("hold_position")) %>%
      footnote(general = sprintf("Permutation p-value: %.3f (%d placebos).",
                                  scm_res$p_value, scm_res$n_placebos),
               threeparttable = TRUE)

    writeLines(tab3_tex, file.path(TAB_DIR, "tab3_scm_gap.tex"))
  }
}

# ─────────────────────────────────────────────────────────────────────────────
# Table 4: Displacement Regressions
# ─────────────────────────────────────────────────────────────────────────────

cat("Table 4: Displacement regressions...\n")

if (file.exists(file.path(DATA_DIR, "displacement_regs.rds"))) {
  regs <- readRDS(file.path(DATA_DIR, "displacement_regs.rds"))

  # modelsummary table
  reg_list <- list(
    "Same Occupation" = regs$stay,
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
      "Fixed effects: state, race, sex, age group."
    )
  )
}

# ─────────────────────────────────────────────────────────────────────────────
# Table 5: Transition Matrix (full)
# ─────────────────────────────────────────────────────────────────────────────

cat("Table 5: Transition matrix...\n")

setorder(trans_matrix, -N)
tab5 <- trans_matrix[, .(
  `1950 Occupation` = occ_broad_1950,
  N = format(N, big.mark = ","),
  `Share (%)` = sprintf("%.1f", pct)
)]

tab5_tex <- kable(tab5, format = "latex", booktabs = TRUE,
                  caption = "Occupational Transitions: 1940 Elevator Operators in 1950") %>%
  kable_styling(latex_options = c("hold_position")) %>%
  footnote(general = "Source: IPUMS + MLP v2.0 linked panel. Sample: individuals who were elevator operators (OCC1950=761) in the 1940 census and linked to the 1950 census.",
           threeparttable = TRUE)

writeLines(tab5_tex, file.path(TAB_DIR, "tab5_transition_matrix.tex"))

# ─────────────────────────────────────────────────────────────────────────────
# Table 6: Heterogeneity Regressions (Race × Sex)
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
      "Source: IPUMS + MLP v2.0 linked panel."
    )
  )
}

# ─────────────────────────────────────────────────────────────────────────────
# Table 7: Robustness Summary
# ─────────────────────────────────────────────────────────────────────────────

cat("Table 7: Robustness summary...\n")

if (file.exists(file.path(DATA_DIR, "robustness_results.rds"))) {
  rob <- readRDS(file.path(DATA_DIR, "robustness_results.rds"))

  rob_list <- list(
    "Janitor Placebo" = rob$janitor_placebo,
    "Time Placebo" = rob$time_placebo,
    "Per Population" = rob$alt_per_pop,
    "Per Employed" = rob$alt_per_emp,
    "Triple Diff" = rob$triple_diff
  )

  modelsummary(rob_list,
    output = file.path(TAB_DIR, "tab7_robustness.tex"),
    stars = c('*' = 0.1, '**' = 0.05, '***' = 0.01),
    gof_map = c("nobs", "r.squared"),
    title = "Robustness Checks: Alternative Specifications and Placebo Tests",
    notes = list(
      "Source: IPUMS Full-Count Census, 1900--1950.",
      "Janitor placebo uses janitors per 10k pop as outcome.",
      "Time placebo uses fake treatment date (1925-30) with pre-1940 data only."
    )
  )
}

# ─────────────────────────────────────────────────────────────────────────────
# Table A1 (Appendix): Transition by Age Group
# ─────────────────────────────────────────────────────────────────────────────

cat("Table A1: Transition by age...\n")

# Top destinations
top_dest <- trans_matrix[order(-N)]$occ_broad_1950[1:6]
trans_age_sub <- trans_age[occ_broad_1950 %in% top_dest]
trans_age_wide <- dcast(trans_age_sub,
                        occ_broad_1950 ~ age_group_1940,
                        value.var = "pct", fill = 0)

for (col in names(trans_age_wide)[-1]) {
  set(trans_age_wide, j = col,
      value = sprintf("%.1f", trans_age_wide[[col]]))
}

tab_a1_tex <- kable(trans_age_wide, format = "latex", booktabs = TRUE,
                    col.names = c("1950 Occupation", names(trans_age_wide)[-1]),
                    caption = "Occupational Transitions by Age Group (1940 Age)") %>%
  kable_styling(latex_options = c("hold_position", "scale_down")) %>%
  footnote(general = "Row percentages within each age group.",
           threeparttable = TRUE)

writeLines(tab_a1_tex, file.path(TAB_DIR, "tab_a1_transition_age.tex"))

cat("\n========================================\n")
cat("TABLES COMPLETE\n")
cat(sprintf("Saved %d tables to %s\n", length(list.files(TAB_DIR, "*.tex")), TAB_DIR))
cat("========================================\n")
