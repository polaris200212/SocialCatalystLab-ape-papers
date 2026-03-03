# =============================================================================
# 06_tables.R — LaTeX tables for the DiD-Transformer paper
# =============================================================================
# Generates:
#   Table 1: Balance table (TVA vs Control at 1920 baseline)
#   Table 2: Main DiD results (TWFE)
#   Table 3: Robustness results (alternative controls, placebo, etc.)
#   Table 4: Transition rate results
#
# Input:  ../data/ (from scripts 01-04)
# Output: ../tables/*.tex
# =============================================================================

source("00_packages.R")

# =============================================================================
# Load data
# =============================================================================
log_msg("Loading data for tables...")

balance_table  <- readRDS(file.path(DATA_DIR, "balance_table_data.rds"))
main_results   <- readRDS(file.path(DATA_DIR, "main_results.rds"))
model_objects  <- readRDS(file.path(DATA_DIR, "model_objects.rds"))
rob_models     <- readRDS(file.path(DATA_DIR, "robustness_models.rds"))
rob_results    <- readRDS(file.path(DATA_DIR, "robustness_results.rds"))

# =============================================================================
# Table 1: Balance Table
# =============================================================================
log_msg("Table 1: Balance table...")

bal <- balance_table[variable != "N counties"]

# Format numbers
fmt_bal <- function(x, digits = 3) {
  ifelse(is.na(x), "", formatC(x, digits = digits, format = "f"))
}

bal_tex <- data.table(
  Variable = bal$variable,
  `TVA Mean` = fmt_bal(bal$tva_mean),
  `(SD)` = paste0("(", fmt_bal(bal$tva_sd), ")"),
  `Control Mean` = fmt_bal(bal$ctrl_mean),
  `(SD) ` = paste0("(", fmt_bal(bal$ctrl_sd), ")"),
  Difference = fmt_bal(bal$diff),
  `Norm. Diff.` = fmt_bal(bal$norm_diff, 2)
)

# Get N counties
n_tva  <- balance_table[variable == "N counties"]$tva_mean
n_ctrl <- balance_table[variable == "N counties"]$ctrl_mean

# Build LaTeX table
tbl1 <- kbl(bal_tex,
  format = "latex",
  booktabs = TRUE,
  escape = FALSE,
  align = c("l", rep("c", 6)),
  caption = "Balance at Baseline (1920): TVA vs.\\ Control Counties",
  label = "tab:balance"
) |>
  kable_styling(latex_options = c("hold_position")) |>
  add_header_above(c(" " = 1, "TVA Counties" = 2, "Control Counties" = 2, " " = 2)) |>
  footnote(
    general = sprintf(
      paste0("County-level means and standard deviations at the 1920 census baseline. ",
             "TVA counties (N=%d) are those in the TVA service area. ",
             "Control counties (N=%d) are all non-TVA counties with at least 30 ",
             "linked individuals per census year. ",
             "Normalized difference computed as (mean\\\\textsubscript{TVA} - ",
             "mean\\\\textsubscript{Control}) / ",
             "\\\\sqrt{sd\\\\textsubscript{TVA}\\\\textsuperscript{2} + ",
             "sd\\\\textsubscript{Control}\\\\textsuperscript{2}} ",
             "(Imbens and Rubin 2015)."),
      as.integer(n_tva), as.integer(n_ctrl)
    ),
    general_title = "Notes:",
    escape = FALSE,
    threeparttable = TRUE
  )

writeLines(tbl1, file.path(TABLE_DIR, "tab1_balance.tex"))
log_msg("  Saved tab1_balance.tex")

# =============================================================================
# Table 2: Main DiD Results
# =============================================================================
log_msg("Table 2: Main DiD results...")

# Use fixest etable for clean regression output
tbl2 <- etable(
  model_objects$ag_twfe,
  model_objects$ag_weighted,
  model_objects$ag_controls,
  model_objects$mfg_twfe,
  model_objects$mfg_weighted,
  model_objects$mfg_controls,
  headers = list(
    ":_:" = list("Agriculture Share" = 3, "Manufacturing Share" = 3)
  ),
  dict = c(
    tva_post = "TVA $\\times$ Post",
    base_ag_x_year = "Baseline Ag $\\times$ Year",
    base_white_x_year = "Baseline White $\\times$ Year",
    base_urban_x_year = "Baseline Urban $\\times$ Year"
  ),
  se.below = TRUE,
  keep = "tva_post",
  fixef.group = list(
    "County FE" = "county_id",
    "Year FE" = "year"
  ),
  fitstat = ~ n + r2.within,
  tex = TRUE,
  file = file.path(TABLE_DIR, "tab2_main_results.tex"),
  title = "Traditional DiD: TVA Effects on Sectoral Employment",
  label = "tab:main",
  notes = paste0(
    "County-level TWFE regressions. Treatment: residence in TVA service area county (1920). ",
    "Post: year $\\geq$ 1940 (first post-TVA census). ",
    "Columns (1)--(3): agricultural employment share; Columns (4)--(6): manufacturing share. ",
    "Weighted regressions use county population (linked individuals) as weights. ",
    "Baseline controls: 1920 agriculture share, white share, and urban share interacted with year. ",
    "Standard errors clustered at the state level in parentheses. ",
    "* $p<0.10$, ** $p<0.05$, *** $p<0.01$."
  ),
  replace = TRUE
)

log_msg("  Saved tab2_main_results.tex")

# =============================================================================
# Table 3: Robustness Results
# =============================================================================
log_msg("Table 3: Robustness results...")

tbl3 <- etable(
  rob_models$ag_border,
  rob_models$ag_same,
  rob_models$ag_nonsouth,
  rob_models$ag_placebo,
  rob_models$mfg_border,
  rob_models$mfg_same,
  rob_models$mfg_nonsouth,
  rob_models$mfg_placebo,
  headers = list(
    ":_:" = list("Agriculture Share" = 4, "Manufacturing Share" = 4)
  ),
  dict = c(
    tva_post = "TVA $\\times$ Post",
    tva_placebo = "TVA $\\times$ Placebo Post"
  ),
  se.below = TRUE,
  keep = "tva_post|tva_placebo",
  fixef.group = list(
    "County FE" = "county_id",
    "Year FE" = "year"
  ),
  fitstat = ~ n + r2.within,
  extralines = list(
    "Control group" = c("Bordering", "Same-state", "Non-South", "All (placebo)",
                        "Bordering", "Same-state", "Non-South", "All (placebo)")
  ),
  tex = TRUE,
  file = file.path(TABLE_DIR, "tab3_robustness.tex"),
  title = "Robustness: Alternative Control Groups and Placebo Test",
  label = "tab:robustness",
  notes = paste0(
    "Robustness checks for the TVA DiD estimates. ",
    "Columns (1) and (5): control group restricted to bordering counties (same-state + adjacent-state non-TVA). ",
    "Columns (2) and (6): same-state non-TVA controls only. ",
    "Columns (3) and (7): non-South controls only (all non-Southern states). ",
    "Columns (4) and (8): placebo test using 1920--1930 as the pre/post period ",
    "(TVA not yet established). ",
    "Standard errors clustered at the state level. ",
    "* $p<0.10$, ** $p<0.05$, *** $p<0.01$."
  ),
  replace = TRUE
)

log_msg("  Saved tab3_robustness.tex")

# =============================================================================
# Table 4: Transition Rate Results
# =============================================================================
log_msg("Table 4: Transition rate results...")

tbl4 <- etable(
  model_objects$trans_twfe,
  model_objects$trans_cond_twfe,
  model_objects$occ_twfe,
  model_objects$farm_twfe,
  headers = list(
    ":_:" = list(
      "Ag$\\rightarrow$Mfg\n(Uncond.)" = 1,
      "Ag$\\rightarrow$Mfg\n(Cond.)" = 1,
      "Occ. Change\nRate" = 1,
      "Farm Exit\nRate" = 1
    )
  ),
  dict = c(
    tva_post_trans = "TVA $\\times$ Post"
  ),
  se.below = TRUE,
  keep = "tva_post_trans",
  fixef.group = list(
    "County FE" = "county_id",
    "Year FE" = "year"
  ),
  fitstat = ~ n + r2.within,
  tex = TRUE,
  file = file.path(TABLE_DIR, "tab4_transitions.tex"),
  title = "TVA Effects on Career Transitions",
  label = "tab:transitions",
  notes = paste0(
    "County-level TWFE regressions of career transition rates on TVA treatment. ",
    "Column (1): unconditional agriculture-to-manufacturing transition rate (share of all workers). ",
    "Column (2): conditional transition rate (share of prior-year agricultural workers who moved to manufacturing). ",
    "Column (3): overall occupation change rate (any broad occupation change between census waves). ",
    "Column (4): farm exit rate (share of prior-year farm residents who left farming). ",
    "Transition rates use two periods: 1920$\\rightarrow$1930 (pre-TVA) and 1930$\\rightarrow$1940 (post-TVA). ",
    "Standard errors clustered at the state level. ",
    "* $p<0.10$, ** $p<0.05$, *** $p<0.01$."
  ),
  replace = TRUE
)

log_msg("  Saved tab4_transitions.tex")

# =============================================================================
# Table 5: Event Study Coefficients
# =============================================================================
log_msg("Table 5: Event study table...")

tbl5 <- etable(
  model_objects$ag_es,
  model_objects$mfg_es,
  headers = list(
    ":_:" = list("Ag Share" = 1, "Mfg Share" = 1)
  ),
  dict = c(
    tva_1930 = "TVA $\\times$ 1930",
    tva_1940 = "TVA $\\times$ 1940"
  ),
  se.below = TRUE,
  keep = "tva_",
  fixef.group = list(
    "County FE" = "county_id",
    "Year FE" = "year"
  ),
  fitstat = ~ n + r2.within,
  tex = TRUE,
  file = file.path(TABLE_DIR, "tab5_event_study.tex"),
  title = "Event Study: TVA Effects by Census Year",
  label = "tab:eventstudy",
  notes = paste0(
    "Event study regressions with 1920 as the reference year. ",
    "The TVA $\\times$ 1930 coefficient tests for pre-trends (TVA established in 1933). ",
    "The TVA $\\times$ 1940 coefficient captures the treatment effect. ",
    "Standard errors clustered at the state level. ",
    "* $p<0.10$, ** $p<0.05$, *** $p<0.01$."
  ),
  replace = TRUE
)

log_msg("  Saved tab5_event_study.tex")

# =============================================================================
# Summary statistics table (for appendix)
# =============================================================================
log_msg("Summary statistics table (appendix)...")

analysis_county <- readRDS(file.path(DATA_DIR, "analysis_county.rds"))

# Overall summary statistics
summ_vars <- c("ag_share", "mfg_share", "mean_age", "pct_white",
               "pct_married", "pct_urban", "pct_farm", "n_individuals")
summ_labels <- c("Agriculture share", "Manufacturing share", "Mean age",
                 "Share white", "Share married", "Share urban",
                 "Share on farm", "N individuals")

summ_list <- lapply(seq_along(summ_vars), function(i) {
  v <- analysis_county[[summ_vars[i]]]
  v <- v[!is.na(v)]
  data.table(
    Variable = summ_labels[i],
    Mean = round(mean(v), 3),
    SD = round(sd(v), 3),
    Min = round(min(v), 3),
    Median = round(median(v), 3),
    Max = round(max(v), 3),
    N = length(v)
  )
})

summ_dt <- rbindlist(summ_list)

tbl_summ <- kbl(summ_dt,
  format = "latex",
  booktabs = TRUE,
  caption = "Summary Statistics: County-Year Panel",
  label = "tab:summary",
  align = c("l", rep("c", 6))
) |>
  kable_styling(latex_options = c("hold_position")) |>
  footnote(
    general = paste0(
      "County-year panel with three census waves (1920, 1930, 1940). ",
      "Sample restricted to counties with at least 30 linked male individuals ",
      "(aged 18--65 in 1920) per census year."
    ),
    general_title = "Notes:",
    escape = FALSE,
    threeparttable = TRUE
  )

writeLines(tbl_summ, file.path(TABLE_DIR, "tab_summary.tex"))
log_msg("  Saved tab_summary.tex")

log_msg("\nAll tables complete.")
