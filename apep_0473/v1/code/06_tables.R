###############################################################################
# 06_tables.R — Generate all LaTeX tables
# APEP-0473: Universal Credit and Self-Employment in Britain
###############################################################################

source("00_packages.R")

panel <- read_csv(file.path(DATA_DIR, "analysis_panel.csv"), show_col_types = FALSE)

###############################################################################
# Table 1: Summary Statistics
###############################################################################

cat("=== Table 1: Summary Statistics ===\n")

# Pre-treatment summary (2010-2015)
pre <- panel %>% filter(year <= 2015)
post <- panel %>% filter(year >= 2016)

sum_stats <- bind_rows(
  pre %>%
    summarise(
      across(c(se_share, emp_rate, econ_active_rate),
             list(mean = ~mean(., na.rm = TRUE),
                  sd = ~sd(., na.rm = TRUE),
                  min = ~min(., na.rm = TRUE),
                  max = ~max(., na.rm = TRUE)),
             .names = "{.col}_{.fn}"),
      N = n(),
      LAs = n_distinct(la_code)
    ) %>%
    mutate(period = "Pre-treatment (2010-2015)"),

  post %>%
    summarise(
      across(c(se_share, emp_rate, econ_active_rate),
             list(mean = ~mean(., na.rm = TRUE),
                  sd = ~sd(., na.rm = TRUE),
                  min = ~min(., na.rm = TRUE),
                  max = ~max(., na.rm = TRUE)),
             .names = "{.col}_{.fn}"),
      N = n(),
      LAs = n_distinct(la_code)
    ) %>%
    mutate(period = "Post-treatment (2016-2019)")
)

# Write LaTeX table
tex_summ <- sprintf("
\\begin{table}[htbp]
\\centering
\\caption{Summary Statistics}
\\label{tab:summary}
\\begin{tabular}{lcccc}
\\toprule
& \\multicolumn{2}{c}{Pre-Treatment (2010--2015)} & \\multicolumn{2}{c}{Post-Treatment (2016--2019)} \\\\
\\cmidrule(lr){2-3} \\cmidrule(lr){4-5}
Variable & Mean & SD & Mean & SD \\\\
\\midrule
Self-employment share (\\%%) & %.1f & %.1f & %.1f & %.1f \\\\
Employment rate (\\%%) & %.1f & %.1f & %.1f & %.1f \\\\
Economic activity rate (\\%%) & %.1f & %.1f & %.1f & %.1f \\\\
\\midrule
Observations & \\multicolumn{2}{c}{%d} & \\multicolumn{2}{c}{%d} \\\\
Local authorities & \\multicolumn{2}{c}{%d} & \\multicolumn{2}{c}{%d} \\\\
\\bottomrule
\\end{tabular}
\\begin{tablenotes}
\\small
\\item \\textit{Notes:} Self-employment share is the percentage of employed persons aged 16+ who are self-employed. Employment and economic activity rates are for the working-age population (16--64). Data from NOMIS Annual Population Survey, April--March rolling annual periods. The panel covers 378 English, Scottish, and Welsh local authorities from 2010 to 2019. Three LAs have missing observations in the post-treatment period due to APS survey suppression, yielding 375 LAs in those years.
\\end{tablenotes}
\\end{table}
",
  sum_stats$se_share_mean[1], sum_stats$se_share_sd[1],
  sum_stats$se_share_mean[2], sum_stats$se_share_sd[2],
  sum_stats$emp_rate_mean[1], sum_stats$emp_rate_sd[1],
  sum_stats$emp_rate_mean[2], sum_stats$emp_rate_sd[2],
  sum_stats$econ_active_rate_mean[1], sum_stats$econ_active_rate_sd[1],
  sum_stats$econ_active_rate_mean[2], sum_stats$econ_active_rate_sd[2],
  sum_stats$N[1], sum_stats$N[2],
  sum_stats$LAs[1], sum_stats$LAs[2]
)

writeLines(tex_summ, file.path(TAB_DIR, "tab1_summary.tex"))
cat("Saved tab1_summary.tex\n")

###############################################################################
# Table 2: Main Results
###############################################################################

cat("=== Table 2: Main Results ===\n")

# Load saved estimates
results <- read_csv(file.path(TAB_DIR, "main_results.csv"), show_col_types = FALSE)

# Set variable dictionary for nice labels
setFixest_dict(c(
  se_share = "Self-Emp. Share",
  emp_rate = "Emp. Rate",
  econ_active_rate = "Econ. Activity Rate",
  treated = "UC Treatment",
  la_code = "Local Authority"
))

# TWFE regressions
twfe_se <- feols(se_share ~ treated | la_code + year, data = panel, cluster = ~la_code)
twfe_emp <- feols(emp_rate ~ treated | la_code + year, data = panel, cluster = ~la_code)
twfe_econ_active <- feols(econ_active_rate ~ treated | la_code + year, data = panel, cluster = ~la_code)

# Export TWFE table
etable(twfe_se, twfe_emp, twfe_econ_active,
       tex = TRUE,
       replace = TRUE,
       file = file.path(TAB_DIR, "tab2_twfe.tex"),
       title = "TWFE Estimates: Effect of UC Full Service on Labour Market Outcomes",
       label = "tab:twfe",
       notes = "Standard errors clustered at the local authority level in parentheses. Self-employment share is the percentage of employed persons who are self-employed. All regressions include local authority and year fixed effects. Treatment is defined as a binary indicator equal to one in the year and after a local authority's Jobcentre Plus office transitioned to UC Full Service. The Within R$^2$ measures variation explained by the treatment indicator alone after absorbing fixed effects; a near-zero value is expected given the null treatment effect.",
       fitstat = c("n", "wr2", "ar2"))

cat("Saved tab2_twfe.tex\n")

###############################################################################
# Table 3: Callaway-Sant'Anna Results
###############################################################################

cat("=== Table 3: CS Results ===\n")

# Create manual LaTeX table for CS results
cs_results <- results %>%
  filter(!is.na(cs_att))

# Load saved aggregated CS objects (same bootstrap run as main results)
cs_se_agg <- readRDS(file.path(DATA_DIR, "cs_se_share_agg.rds"))
cs_emp_agg <- readRDS(file.path(DATA_DIR, "cs_emp_rate_agg.rds"))
cs_econ_active_agg <- readRDS(file.path(DATA_DIR, "cs_econ_active_rate_agg.rds"))
cs_se_group <- readRDS(file.path(DATA_DIR, "cs_se_share_group.rds"))
cs_se_obj <- readRDS(file.path(DATA_DIR, "cs_se_share.rds"))

# Extract group-specific ATTs and SEs by cohort
group_df <- tibble(
  group = cs_se_group$egt,
  att = cs_se_group$att.egt,
  se = cs_se_group$se.egt
)

# Get pre-test p-value from the CS object
cs_se_pretest <- tryCatch({
  pre_test <- cs_se_obj$Wpval
  if (is.null(pre_test)) NA_real_ else pre_test
}, error = function(e) NA_real_)

# Format group rows for Panel B
panel_b_lines <- ""
for (i in seq_len(nrow(group_df))) {
  att_str <- ifelse(group_df$att[i] < 0,
                    sprintf("$-$%.3f", abs(group_df$att[i])),
                    sprintf("%.3f", group_df$att[i]))
  panel_b_lines <- paste0(panel_b_lines,
    sprintf("%d cohort & %s & --- & --- \\\\\n& (%.3f) & & \\\\\n",
            group_df$group[i], att_str, group_df$se[i]))
}

# Format pre-test p-value
pretest_str <- ifelse(is.na(cs_se_pretest), "---", sprintf("%.3f", cs_se_pretest))

tex_cs <- sprintf("
\\begin{table}[htbp]
\\centering
\\caption{Callaway-Sant'Anna Estimates: Effect of UC Full Service on Labour Market Outcomes}
\\label{tab:cs}
\\begin{tabular}{lccc}
\\toprule
& Self-Emp. Share & Emp. Rate & Econ. Activity Rate \\\\
\\midrule
\\textbf{Panel A: Overall ATT} & & & \\\\
ATT & %.3f & %.3f & %.3f \\\\
& (%.3f) & (%.3f) & (%.3f) \\\\
\\midrule
\\textbf{Panel B: Group-specific ATT} & & & \\\\
%s\\midrule
Observations & %d & %d & %d \\\\
Local authorities & %d & %d & %d \\\\
Pre-test $p$-value & %s & --- & --- \\\\
\\bottomrule
\\end{tabular}
\\begin{tablenotes}
\\small
\\item \\textit{Notes:} Doubly robust Callaway-Sant'Anna (2021) estimates with not-yet-treated local authorities as the control group. Standard errors in parentheses are computed via multiplier bootstrap (999 iterations). The pre-test $p$-value is from a joint test that all pre-treatment group-time ATTs equal zero. Universal base period is used. Panel B omits the 2018 cohort because, as the last-treated group, no not-yet-treated controls exist in post-treatment years for this cohort. The overall ATT in Panel A aggregates only over identifiable group-time ATTs.
\\end{tablenotes}
\\end{table}
",
  cs_se_agg$overall.att, cs_emp_agg$overall.att, cs_econ_active_agg$overall.att,
  cs_se_agg$overall.se, cs_emp_agg$overall.se, cs_econ_active_agg$overall.se,
  panel_b_lines,
  nrow(panel), nrow(panel), nrow(panel),
  n_distinct(panel$la_code), n_distinct(panel$la_code), n_distinct(panel$la_code),
  pretest_str
)

writeLines(tex_cs, file.path(TAB_DIR, "tab3_cs.tex"))
cat("Saved tab3_cs.tex\n")

###############################################################################
# Table 4: Robustness
###############################################################################

cat("=== Table 4: Robustness ===\n")

rob <- read_csv(file.path(TAB_DIR, "robustness_summary.csv"), show_col_types = FALSE)

tex_rob <- "
\\begin{table}[htbp]
\\centering
\\caption{Robustness Checks: Self-Employment Share}
\\label{tab:robustness}
\\begin{tabular}{lcc}
\\toprule
Specification & Estimate & Std. Error \\\\
\\midrule
"

for (i in 1:nrow(rob)) {
  tex_rob <- paste0(tex_rob, sprintf("%s & %.3f & (%.3f) \\\\\n",
                                     rob$specification[i], rob$estimate[i], rob$se[i]))
}

tex_rob <- paste0(tex_rob, "
\\bottomrule
\\end{tabular}
\\begin{tablenotes}
\\small
\\item \\textit{Notes:} All specifications estimate the effect of UC Full Service rollout on the self-employment share. Row 1 is the main Callaway-Sant'Anna estimate. Row 2 adds region-by-year fixed effects to TWFE. Row 3 excludes London boroughs. Row 4 restricts to English local authorities. Row 5 excludes LAs with fuzzy-matched or reassigned treatment timing. Row 6 is a placebo test assigning a fake treatment date of 2014 using only pre-treatment data (2010--2015).
\\end{tablenotes}
\\end{table}
")

writeLines(tex_rob, file.path(TAB_DIR, "tab4_robustness.tex"))
cat("Saved tab4_robustness.tex\n")

###############################################################################
# Table 5: Treatment cohort characteristics
###############################################################################

cat("=== Table 5: Cohort characteristics ===\n")

# Use full pre-treatment period means and true cohort counts
# Get true cohort counts from full panel
cohort_counts <- panel %>%
  filter(!is.na(first_treat)) %>%
  distinct(la_code, first_treat) %>%
  count(first_treat, name = "n_la")

# Get pre-treatment means (all years before treatment) by cohort
cohort_chars <- panel %>%
  filter(!is.na(first_treat), treated == 0) %>%
  mutate(cohort = factor(first_treat)) %>%
  group_by(cohort) %>%
  summarise(
    se_share = mean(se_share, na.rm = TRUE),
    emp_rate = mean(emp_rate, na.rm = TRUE),
    econ_active_rate = mean(econ_active_rate, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  left_join(cohort_counts %>% mutate(first_treat = factor(first_treat)), by = c("cohort" = "first_treat"))

tex_cohort <- sprintf("
\\begin{table}[htbp]
\\centering
\\caption{Pre-Treatment Characteristics by Treatment Cohort}
\\label{tab:cohort}
\\begin{tabular}{lccc}
\\toprule
& 2016 Cohort & 2017 Cohort & 2018 Cohort \\\\
\\midrule
Number of LAs & %d & %d & %d \\\\
Self-employment share (\\%%) & %.1f & %.1f & %.1f \\\\
Employment rate (\\%%) & %.1f & %.1f & %.1f \\\\
Economic activity rate (\\%%) & %.1f & %.1f & %.1f \\\\
\\bottomrule
\\end{tabular}
\\begin{tablenotes}
\\small
\\item \\textit{Notes:} Pre-treatment means computed across all pre-treatment years for each cohort. Number of LAs reflects the full sample. Cohort defined by the year of UC Full Service transition.
\\end{tablenotes}
\\end{table}
",
  cohort_chars$n_la[1], cohort_chars$n_la[2], cohort_chars$n_la[3],
  cohort_chars$se_share[1], cohort_chars$se_share[2], cohort_chars$se_share[3],
  cohort_chars$emp_rate[1], cohort_chars$emp_rate[2], cohort_chars$emp_rate[3],
  cohort_chars$econ_active_rate[1], cohort_chars$econ_active_rate[2], cohort_chars$econ_active_rate[3]
)

writeLines(tex_cohort, file.path(TAB_DIR, "tab5_cohort.tex"))
cat("Saved tab5_cohort.tex\n")

cat("\n=== All tables generated ===\n")
cat("Files in", TAB_DIR, ":\n")
cat(paste(" ", list.files(TAB_DIR), collapse = "\n"), "\n")
