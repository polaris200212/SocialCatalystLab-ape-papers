# =============================================================================
# 06_tables.R - All Table Generation
# APEP-0265: Felon Voting Rights Restoration and Black Political Participation
# =============================================================================

source("00_packages.R")

data_dir <- "../data"
tab_dir <- "../tables"
dir.create(tab_dir, showWarnings = FALSE, recursive = TRUE)

# Load data and results
cell_data <- readRDS(file.path(data_dir, "analysis_cells.rds"))
reforms <- readRDS(file.path(data_dir, "reform_timing.rds"))
state_xwalk <- readRDS(file.path(data_dir, "state_crosswalk.rds"))
dd_results <- readRDS(file.path(data_dir, "dd_results.rds"))
ddd_results <- readRDS(file.path(data_dir, "ddd_results.rds"))

reversal_fips <- c(12, 19)

# =============================================================================
# TABLE 1: SUMMARY STATISTICS
# =============================================================================

cat("Generating Table 1: Summary Statistics...\n")

summ_data <- cell_data %>%
  filter(!state_fips %in% reversal_fips,
         state_group %in% c("reform", "control"))

# Panel A: By race
panel_a <- summ_data %>%
  group_by(race_cat) %>%
  summarise(
    `Mean Turnout` = sprintf("%.3f", mean(turnout, na.rm = TRUE)),
    `SD Turnout` = sprintf("%.3f", sd(turnout, na.rm = TRUE)),
    `Mean Registration` = sprintf("%.3f", mean(registered, na.rm = TRUE)),
    `SD Registration` = sprintf("%.3f", sd(registered, na.rm = TRUE)),
    `Mean Cell Size` = sprintf("%.0f", mean(n_obs, na.rm = TRUE)),
    `State-Year Cells` = as.character(n()),
    .groups = "drop"
  ) %>%
  mutate(race_cat = ifelse(race_cat == "black_nh", "Black Non-Hispanic",
                           "White Non-Hispanic"))

# Panel B: By treatment status
panel_b <- summ_data %>%
  group_by(state_group) %>%
  summarise(
    `Mean Turnout` = sprintf("%.3f", mean(turnout, na.rm = TRUE)),
    `SD Turnout` = sprintf("%.3f", sd(turnout, na.rm = TRUE)),
    `Mean Registration` = sprintf("%.3f", mean(registered, na.rm = TRUE)),
    `SD Registration` = sprintf("%.3f", sd(registered, na.rm = TRUE)),
    `Mean Cell Size` = sprintf("%.0f", mean(n_obs, na.rm = TRUE)),
    `State-Year Cells` = as.character(n()),
    .groups = "drop"
  ) %>%
  mutate(state_group = ifelse(state_group == "reform", "Reform States",
                              "Control States"))

# Write LaTeX table
tex_summ <- c(
  "\\begin{table}[H]",
  "\\centering",
  "\\caption{Summary Statistics}",
  "\\label{tab:summary}",
  "\\begin{threeparttable}",
  "\\begin{tabular}{lcccccc}",
  "\\toprule",
  " & Mean & SD & Mean & SD & Mean Cell & State-Year \\\\",
  " & Turnout & Turnout & Registration & Registration & Size & Cells \\\\",
  "\\midrule",
  "\\multicolumn{7}{l}{\\textit{Panel A: By Race}} \\\\[3pt]"
)

for (i in 1:nrow(panel_a)) {
  tex_summ <- c(tex_summ, sprintf(
    "%s & %s & %s & %s & %s & %s & %s \\\\",
    panel_a$race_cat[i], panel_a$`Mean Turnout`[i], panel_a$`SD Turnout`[i],
    panel_a$`Mean Registration`[i], panel_a$`SD Registration`[i],
    panel_a$`Mean Cell Size`[i], panel_a$`State-Year Cells`[i]
  ))
}

tex_summ <- c(tex_summ,
  "\\\\",
  "\\multicolumn{7}{l}{\\textit{Panel B: By Treatment Status}} \\\\[3pt]"
)

for (i in 1:nrow(panel_b)) {
  tex_summ <- c(tex_summ, sprintf(
    "%s & %s & %s & %s & %s & %s & %s \\\\",
    panel_b$state_group[i], panel_b$`Mean Turnout`[i], panel_b$`SD Turnout`[i],
    panel_b$`Mean Registration`[i], panel_b$`SD Registration`[i],
    panel_b$`Mean Cell Size`[i], panel_b$`State-Year Cells`[i]
  ))
}

tex_summ <- c(tex_summ,
  "\\bottomrule",
  "\\end{tabular}",
  "\\begin{tablenotes}[flushleft]",
  "\\small",
  sprintf("\\item Notes: Data from CPS Voting and Registration Supplement, %s-%s. Weighted turnout and registration rates computed at the state $\\times$ race $\\times$ year level. Reversal states (FL, IA) excluded. Cell size is the number of individual CPS respondents in each state-race-year cell.",
          min(summ_data$year), max(summ_data$year)),
  "\\end{tablenotes}",
  "\\end{threeparttable}",
  "\\end{table}"
)

writeLines(tex_summ, file.path(tab_dir, "tab1_summary.tex"))
cat("  Table 1 saved.\n")

# =============================================================================
# TABLE 2: REFORM TIMING
# =============================================================================

cat("Generating Table 2: Reform Timing...\n")

reform_table <- reforms %>%
  left_join(state_xwalk, by = "state_fips") %>%
  arrange(first_election) %>%
  mutate(
    reversal = ifelse(state_fips %in% reversal_fips, "Yes", ""),
    type_label = tools::toTitleCase(reform_type)
  ) %>%
  select(state_name, first_election, type_label, notes, reversal)

tex_reform <- c(
  "\\begin{table}[H]",
  "\\centering",
  "\\caption{Felon Voting Rights Restoration: Treatment Timing}",
  "\\label{tab:reform_timing}",
  "\\begin{threeparttable}",
  "\\small",
  "\\begin{tabular}{llclc}",
  "\\toprule",
  "State & First Election & Type & Description & Reversal \\\\",
  "\\midrule"
)

for (i in 1:nrow(reform_table)) {
  # Escape ampersands and special chars in notes
  note_clean <- gsub("&", "\\\\&", reform_table$notes[i])
  note_clean <- gsub("_", "\\\\_", note_clean)
  tex_reform <- c(tex_reform, sprintf(
    "%s & %d & %s & %s & %s \\\\",
    reform_table$state_name[i], reform_table$first_election[i],
    reform_table$type_label[i], note_clean, reform_table$reversal[i]
  ))
}

tex_reform <- c(tex_reform,
  "\\bottomrule",
  "\\end{tabular}",
  "\\begin{tablenotes}[flushleft]",
  "\\small",
  "\\item Notes: Treatment coded as the first November even-year election at which the reform was operative. ``First Election'' is the first CPS Voting Supplement wave at which the state is coded as treated. Reversal states experienced policy rollback and are excluded from the main sample. Sources: NCSL, Brennan Center, Ballotpedia.",
  "\\end{tablenotes}",
  "\\end{threeparttable}",
  "\\end{table}"
)

writeLines(tex_reform, file.path(tab_dir, "tab2_reform_timing.tex"))
cat("  Table 2 saved.\n")

# =============================================================================
# TABLE 3: MAIN DD RESULTS
# =============================================================================

cat("Generating Table 3: Main DD Results...\n")

tryCatch({
  etable(
    dd_results$dd_turnout,
    dd_results$dd_reg,
    dd_results$dd_separate,
    dd_results$dd_controls,
    tex = TRUE,
    style.tex = style.tex("aer"),
    fitstat = ~ r2 + n,
    headers = c("Turnout", "Registration", "Turnout", "Turnout"),
    extralines = list(
      "_State $\\times$ Year FE" = c("Yes", "Yes", "No", "Yes"),
      "_Separate State + Year FE" = c("No", "No", "Yes", "No"),
      "_Voting Law Controls" = c("No", "No", "No", "Yes")
    ),
    title = "Effect of Felon Voting Rights Restoration on the Black-White Participation Gap",
    label = "tab:main_dd",
    notes = c(
      "Standard errors clustered at the state level in parentheses.",
      "* p$<$0.10, ** p$<$0.05, *** p$<$0.01.",
      "Outcome is the weighted mean turnout/registration rate at the state-race-year level.",
      "Black $\\times$ Post-Reform captures the change in the Black-White gap after reform.",
      "Reversal states (FL, IA) excluded."
    ),
    file = file.path(tab_dir, "tab3_main_dd.tex")
  )
  cat("  Table 3 saved.\n")
}, error = function(e) {
  cat(sprintf("  Table 3 error: %s\nFalling back to manual table.\n", e$message))

  # Manual LaTeX table fallback
  m1 <- dd_results$dd_turnout
  m2 <- dd_results$dd_reg

  tex_dd <- c(
    "\\begin{table}[H]",
    "\\centering",
    "\\caption{Effect of Felon Voting Rights Restoration on the Black-White Participation Gap}",
    "\\label{tab:main_dd}",
    "\\begin{threeparttable}",
    "\\begin{tabular}{lcc}",
    "\\toprule",
    " & (1) Turnout & (2) Registration \\\\",
    "\\midrule",
    sprintf("Black $\\times$ Post-Reform & %.4f & %.4f \\\\",
            coef(m1)["black_reform"], coef(m2)["black_reform"]),
    sprintf(" & (%.4f) & (%.4f) \\\\",
            se(m1)["black_reform"], se(m2)["black_reform"]),
    "\\\\",
    sprintf("State $\\times$ Year FE & Yes & Yes \\\\"),
    sprintf("N & %d & %d \\\\", nobs(m1), nobs(m2)),
    "\\bottomrule",
    "\\end{tabular}",
    "\\begin{tablenotes}[flushleft]",
    "\\small",
    "\\item Notes: Standard errors clustered at the state level in parentheses. * p$<$0.10, ** p$<$0.05, *** p$<$0.01. Weighted by cell size. Reversal states (FL, IA) excluded.",
    "\\end{tablenotes}",
    "\\end{threeparttable}",
    "\\end{table}"
  )
  writeLines(tex_dd, file.path(tab_dir, "tab3_main_dd.tex"))
  cat("  Table 3 saved (manual fallback).\n")
})

# =============================================================================
# TABLE 4: DDD RESULTS
# =============================================================================

cat("Generating Table 4: DDD Results...\n")

tryCatch({
  etable(
    ddd_results$ddd_full,
    ddd_results$low_risk_dd,
    ddd_results$high_risk_dd,
    tex = TRUE,
    style.tex = style.tex("aer"),
    fitstat = ~ r2 + n,
    headers = c("Full DDD", "Low-Risk DD", "High-Risk DD"),
    extralines = list(
      "_Sample" = c("All Subgroups", "Low-Risk Only", "High-Risk Only"),
      "_State + Year FE" = c("Yes", "Yes", "Yes")
    ),
    title = "Triple-Difference Mechanism Test: Community Spillovers vs. Direct Effects",
    label = "tab:ddd",
    notes = c(
      "Standard errors clustered at the state level in parentheses.",
      "Low-risk: Black women 50+ or college-educated. High-risk: Black men 25-44, no college.",
      "Column 1: Full DDD. Column 2: DD among low-risk only (pure spillover test).",
      "Column 3: DD among high-risk only (direct + spillover)."
    ),
    file = file.path(tab_dir, "tab4_ddd.tex")
  )
  cat("  Table 4 saved.\n")
}, error = function(e) {
  cat(sprintf("  Table 4 error: %s\nFalling back to manual table.\n", e$message))

  m_ddd <- ddd_results$ddd_full
  m_low <- ddd_results$low_risk_dd
  m_high <- ddd_results$high_risk_dd

  tex_ddd <- c(
    "\\begin{table}[H]",
    "\\centering",
    "\\caption{Triple-Difference Mechanism Test: Community Spillovers vs. Direct Effects}",
    "\\label{tab:ddd}",
    "\\begin{threeparttable}",
    "\\begin{tabular}{lccc}",
    "\\toprule",
    " & (1) Full DDD & (2) Low-Risk DD & (3) High-Risk DD \\\\",
    "\\midrule"
  )

  if ("triple" %in% names(coef(m_ddd))) {
    tex_ddd <- c(tex_ddd,
      sprintf("Black $\\times$ Low-Risk $\\times$ Post & %.4f & & \\\\",
              coef(m_ddd)["triple"]),
      sprintf(" & (%.4f) & & \\\\", se(m_ddd)["triple"])
    )
  }

  tex_ddd <- c(tex_ddd,
    sprintf("Black $\\times$ Post-Reform & %.4f & %.4f & %.4f \\\\",
            ifelse("black_reform" %in% names(coef(m_ddd)), coef(m_ddd)["black_reform"], NA),
            coef(m_low)["black_reform"],
            coef(m_high)["black_reform"]),
    sprintf(" & (%.4f) & (%.4f) & (%.4f) \\\\",
            ifelse("black_reform" %in% names(se(m_ddd)), se(m_ddd)["black_reform"], NA),
            se(m_low)["black_reform"],
            se(m_high)["black_reform"]),
    "\\\\",
    sprintf("Sample & All & Low-Risk & High-Risk \\\\"),
    sprintf("N & %d & %d & %d \\\\", nobs(m_ddd), nobs(m_low), nobs(m_high)),
    "\\bottomrule",
    "\\end{tabular}",
    "\\begin{tablenotes}[flushleft]",
    "\\small",
    "\\item Notes: Standard errors clustered at the state level. Low-risk: women 50+ or college-educated. High-risk: men 25-44, no college. Column (2) isolates community spillovers: any effect among low-risk Black citizens cannot be driven by direct voting rights restoration.",
    "\\end{tablenotes}",
    "\\end{threeparttable}",
    "\\end{table}"
  )
  writeLines(tex_ddd, file.path(tab_dir, "tab4_ddd.tex"))
  cat("  Table 4 saved (manual fallback).\n")
})

# =============================================================================
# TABLE 5: ROBUSTNESS
# =============================================================================

cat("Generating Table 5: Robustness...\n")

tryCatch({
  rob <- readRDS(file.path(data_dir, "robustness_results.rds"))

  spec_names <- c(
    "r1_include_reversals" = "Include Reversal States",
    "r2_permanent_only" = "Permanent Reforms Only",
    "r3_hispanic_placebo" = "Placebo: Hispanic-White Gap",
    "r4_registration" = "Registration Outcome",
    "r5_unweighted" = "Unweighted",
    "r6_presidential" = "Presidential Years Only",
    "r7_midterm" = "Midterm Years Only",
    "r8_voting_controls" = "Concurrent Voting Law Controls"
  )

  rob_rows <- map_dfr(names(spec_names), function(nm) {
    m <- rob[[nm]]
    if (is.null(m)) return(NULL)
    coef_name <- intersect(c("black_reform", "hispanic_reform"), names(coef(m)))
    if (length(coef_name) == 0) return(NULL)
    b <- coef(m)[coef_name[1]]
    s <- se(m)[coef_name[1]]
    p <- pvalue(m)[coef_name[1]]
    tibble(
      Specification = spec_names[nm],
      Estimate = sprintf("%.4f", b),
      SE = sprintf("(%.4f)", s),
      N = as.character(nobs(m)),
      Stars = case_when(p < 0.01 ~ "***", p < 0.05 ~ "**", p < 0.10 ~ "*", TRUE ~ "")
    )
  })

  tex_rob <- c(
    "\\begin{table}[H]",
    "\\centering",
    "\\caption{Robustness Checks}",
    "\\label{tab:robustness}",
    "\\begin{threeparttable}",
    "\\begin{tabular}{lccc}",
    "\\toprule",
    "Specification & Estimate & SE & N \\\\",
    "\\midrule"
  )

  for (i in 1:nrow(rob_rows)) {
    tex_rob <- c(tex_rob, sprintf(
      "%s & %s%s & %s & %s \\\\",
      rob_rows$Specification[i], rob_rows$Estimate[i], rob_rows$Stars[i],
      rob_rows$SE[i], rob_rows$N[i]
    ))
  }

  tex_rob <- c(tex_rob,
    "\\bottomrule",
    "\\end{tabular}",
    "\\begin{tablenotes}[flushleft]",
    "\\small",
    "\\item Notes: Each row reports the coefficient on Black $\\times$ Post-Reform (or Hispanic $\\times$ Post-Reform for the placebo test) from a separate regression. Standard errors clustered at the state level. * p$<$0.10, ** p$<$0.05, *** p$<$0.01. All specifications include state $\\times$ year fixed effects unless noted.",
    "\\end{tablenotes}",
    "\\end{threeparttable}",
    "\\end{table}"
  )

  writeLines(tex_rob, file.path(tab_dir, "tab5_robustness.tex"))
  cat("  Table 5 saved.\n")
}, error = function(e) {
  cat(sprintf("  Table 5 error: %s\n", e$message))
})

# =============================================================================
# TABLE 6: EVENT STUDY COEFFICIENTS
# =============================================================================

cat("Generating Table 6: Event Study Coefficients...\n")

tryCatch({
  cs_results <- readRDS(file.path(data_dir, "cs_turnout_results.rds"))

  if ("cs_es" %in% names(cs_results)) {
    es <- cs_results$cs_es

    es_table <- tibble(
      `Event Time` = es$egt,
      ATT = sprintf("%.4f", es$att.egt),
      SE = sprintf("(%.4f)", es$se.egt),
      `95\\% CI` = sprintf("[%.4f, %.4f]",
                           es$att.egt - 1.96 * es$se.egt,
                           es$att.egt + 1.96 * es$se.egt)
    )

    tex_es <- c(
      "\\begin{table}[H]",
      "\\centering",
      "\\caption{Event Study Coefficients: Callaway-Sant'Anna Estimator}",
      "\\label{tab:event_study}",
      "\\begin{threeparttable}",
      "\\begin{tabular}{cccc}",
      "\\toprule",
      "Event Time & ATT & SE & 95\\% CI \\\\",
      "\\midrule"
    )

    for (i in 1:nrow(es_table)) {
      tex_es <- c(tex_es, sprintf(
        "%d & %s & %s & %s \\\\",
        es_table$`Event Time`[i], es_table$ATT[i],
        es_table$SE[i], es_table$`95\\% CI`[i]
      ))
    }

    tex_es <- c(tex_es,
      "\\\\",
      sprintf("Overall ATT & \\multicolumn{3}{c}{%.4f (%.4f)} \\\\",
              cs_results$cs_overall$overall.att,
              cs_results$cs_overall$overall.se),
      "\\bottomrule",
      "\\end{tabular}",
      "\\begin{tablenotes}[flushleft]",
      "\\small",
      "\\item Notes: Callaway-Sant'Anna (2021) group-time ATTs aggregated to event time. Each unit of event time = one biennial election cycle (2 years). Bootstrap standard errors with 1,000 iterations. Control group: never-treated states.",
      "\\end{tablenotes}",
      "\\end{threeparttable}",
      "\\end{table}"
    )

    writeLines(tex_es, file.path(tab_dir, "tab6_event_study.tex"))
    cat("  Table 6 saved.\n")
  }
}, error = function(e) {
  cat(sprintf("  Table 6 error: %s\n", e$message))
})

cat("\n=== All Tables Generated ===\n")
