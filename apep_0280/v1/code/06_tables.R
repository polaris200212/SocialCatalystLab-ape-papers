# ============================================================================
# apep_0277: Indoor Smoking Bans and Social Norms
# 06_tables.R - Generate all tables
# ============================================================================

source(here::here("output", "apep_0277", "v1", "code", "00_packages.R"))

state_year <- readRDS(file.path(data_dir, "state_year_panel.rds"))
results <- readRDS(file.path(data_dir, "main_results.rds"))

cat("=== Generating Tables ===\n")

# ============================================================================
# Table 1: Summary Statistics
# ============================================================================

cat("Table 1: Summary statistics...\n")

# Pre-treatment means by group
pre_treat <- state_year %>%
  filter(year <= 2001 | (first_treat > 0 & year < first_treat) |
           (first_treat == 0)) %>%
  mutate(group = ifelse(first_treat > 0, "Treated (Pre-Ban)", "Never Treated"))

# Compute means
summ_stats <- pre_treat %>%
  group_by(group) %>%
  summarise(
    `Smoking Rate` = sprintf("%.3f", mean(smoking_rate, na.rm = TRUE)),
    `Everyday Smoking` = sprintf("%.3f", mean(everyday_rate, na.rm = TRUE)),
    `Quit Attempt Rate` = sprintf("%.3f", mean(quit_rate, na.rm = TRUE)),
    `Pct Female` = sprintf("%.3f", mean(pct_female, na.rm = TRUE)),
    `Pct College` = sprintf("%.3f", mean(pct_college, na.rm = TRUE)),
    `Pct High Income` = sprintf("%.3f", mean(pct_high_income, na.rm = TRUE)),
    `N (state-years)` = as.character(n()),
    .groups = "drop"
  )

# Compute t-test p-values for difference column
diff_vars <- c("smoking_rate", "everyday_rate", "quit_rate",
               "pct_female", "pct_college", "pct_high_income")
diff_labels <- c("Smoking Rate", "Everyday Smoking", "Quit Attempt Rate",
                 "Pct Female", "Pct College", "Pct High Income")

diff_col <- sapply(diff_vars, function(v) {
  treated <- pre_treat %>% filter(group == "Treated (Pre-Ban)") %>% pull(!!sym(v))
  control <- pre_treat %>% filter(group == "Never Treated") %>% pull(!!sym(v))
  treated <- treated[!is.na(treated)]
  control <- control[!is.na(control)]
  if (length(treated) > 1 && length(control) > 1) {
    tt <- t.test(treated, control)
    diff_val <- mean(treated) - mean(control)
    pval <- tt$p.value
    stars <- if (pval < 0.01) "***" else if (pval < 0.05) "**" else if (pval < 0.10) "*" else ""
    sprintf("%.3f%s", diff_val, stars)
  } else {
    "---"
  }
})
names(diff_col) <- diff_labels

# Write LaTeX table
summ_tex <- c(
  "\\begin{table}[htbp]",
  "\\centering",
  "\\caption{Summary Statistics: Pre-Treatment Means by Treatment Status}",
  "\\label{tab:summ_stats}",
  "\\begin{tabular}{lccc}",
  "\\toprule",
  " & Treated (Pre-Ban) & Never Treated & Difference \\\\",
  "\\midrule"
)

vars <- c("Smoking Rate", "Everyday Smoking", "Quit Attempt Rate",
          "Pct Female", "Pct College", "Pct High Income", "N (state-years)")

for (v in vars) {
  treated_val <- summ_stats %>% filter(group == "Treated (Pre-Ban)") %>% pull(v)
  never_val <- summ_stats %>% filter(group == "Never Treated") %>% pull(v)
  if (v == "N (state-years)") {
    summ_tex <- c(summ_tex, "\\midrule")
    summ_tex <- c(summ_tex, sprintf("%s & %s & %s & \\\\", v, treated_val, never_val))
  } else {
    summ_tex <- c(summ_tex, sprintf("%s & %s & %s & %s \\\\", v, treated_val, never_val, diff_col[v]))
  }
}

summ_tex <- c(summ_tex,
  "\\bottomrule",
  "\\end{tabular}",
  "\\begin{minipage}{0.9\\textwidth}",
  "\\vspace{0.5em}",
  "\\footnotesize",
  "\\textit{Notes:} Pre-treatment means for states that eventually adopted comprehensive indoor smoking bans (``Treated'') and states that never adopted (``Never Treated''). Difference = Treated $-$ Never Treated; significance from two-sample $t$-test. N (state-years) reflects only pre-treatment observations: for treated states, years before ban adoption; for never-treated states, all available years. The full estimation panel contains 1,120 state-year observations (51 jurisdictions $\\times$ 22 survey years, minus 2 state-years with insufficient data). Smoking Rate is the share of adults who currently smoke. Quit Attempt Rate is the share of ever-smokers who attempted to quit in the past 12 months. Pct College is the share with a bachelor's degree or higher. All means are survey-weighted. $^{***}p<0.01$, $^{**}p<0.05$, $^{*}p<0.10$. Source: BRFSS 1996--2004, 2006--2016, 2021--2022.",
  "\\end{minipage}",
  "\\end{table}"
)

writeLines(summ_tex, file.path(table_dir, "tab1_summary_stats.tex"))

# ============================================================================
# Table 2: Main Results
# ============================================================================

cat("Table 2: Main DR-DiD results...\n")

# Extract results
smoking_att <- results$att_smoking
everyday_att <- results$att_everyday
quit_att <- results$att_quit

make_stars <- function(p) {
  if (p < 0.01) return("***")
  if (p < 0.05) return("**")
  if (p < 0.10) return("*")
  return("")
}

format_coef <- function(att_obj) {
  pval <- 2 * pnorm(-abs(att_obj$overall.att / att_obj$overall.se))
  stars <- make_stars(pval)
  coef_str <- sprintf("%.4f%s", att_obj$overall.att, stars)
  se_str <- sprintf("(%.4f)", att_obj$overall.se)
  list(coef = coef_str, se = se_str, pval = pval)
}

r_smoking <- format_coef(smoking_att)
r_everyday <- format_coef(everyday_att)
r_quit <- format_coef(quit_att)

# TWFE comparison
twfe_s <- results$twfe_smoking
twfe_e <- results$twfe_everyday
twfe_q <- results$twfe_quit

twfe_s_pval <- coeftable(twfe_s)[1, 4]
twfe_s_stars <- make_stars(twfe_s_pval)
twfe_e_pval <- coeftable(twfe_e)[1, 4]
twfe_e_stars <- make_stars(twfe_e_pval)
twfe_q_pval <- coeftable(twfe_q)[1, 4]
twfe_q_stars <- make_stars(twfe_q_pval)

# Compute quit-specific stats
quit_panel_stats <- state_year %>% filter(!is.na(quit_rate))
n_quit_years <- n_distinct(quit_panel_stats$year)
n_quit_obs <- nrow(quit_panel_stats)
n_quit_states <- n_distinct(quit_panel_stats$state_fips)

main_tex <- c(
  "\\begin{table}[htbp]",
  "\\centering",
  "\\caption{Effect of Comprehensive Indoor Smoking Bans on Smoking Behavior}",
  "\\label{tab:main_results}",
  "\\begin{tabular}{lccc}",
  "\\toprule",
  " & Current Smoking & Everyday Smoking & Quit Attempts \\\\",
  " & Rate (proportion) & Rate (proportion) & (Ever-Smokers, proportion) \\\\",
  "\\midrule",
  "\\multicolumn{4}{l}{\\textit{Panel A: Callaway-Sant'Anna DiD}} \\\\[0.3em]",
  sprintf("ATT & %s & %s & %s \\\\", r_smoking$coef, r_everyday$coef, r_quit$coef),
  sprintf(" & %s & %s & %s \\\\[0.5em]", r_smoking$se, r_everyday$se, r_quit$se),
  "\\multicolumn{4}{l}{\\textit{Panel B: TWFE (for comparison)}} \\\\[0.3em]",
  sprintf("Treated & %.4f%s & %.4f%s & %.4f%s \\\\",
          coeftable(twfe_s)[1, 1], twfe_s_stars,
          coeftable(twfe_e)[1, 1], twfe_e_stars,
          coeftable(twfe_q)[1, 1], twfe_q_stars),
  sprintf(" & (%.4f) & (%.4f) & (%.4f) \\\\",
          coeftable(twfe_s)[1, 2], coeftable(twfe_e)[1, 2], coeftable(twfe_q)[1, 2]),
  "\\midrule",
  sprintf("States (clusters) & %d & %d & %d \\\\",
          n_distinct(state_year$state_fips),
          n_distinct(state_year$state_fips),
          n_quit_states),
  sprintf("State-year obs ($N$) & %d & %d & %d \\\\",
          nrow(state_year),
          nrow(state_year),
          n_quit_obs),
  sprintf("Survey years & %d & %d & %d \\\\",
          n_distinct(state_year$year),
          n_distinct(state_year$year),
          n_quit_years),
  sprintf("Year coverage & \\multicolumn{2}{c}{1996--2004, 2006--2016, 2021--2022} & %d years \\\\",
          n_quit_years),
  "Estimation & DR-DiD & DR-DiD & Reg-DiD \\\\",
  "Control group & Never-treated & Never-treated & Never-treated \\\\",
  "\\bottomrule",
  "\\end{tabular}",
  "\\begin{minipage}{0.9\\textwidth}",
  "\\vspace{0.5em}",
  "\\footnotesize",
  "\\textit{Notes:} Panel A reports doubly-robust difference-in-differences estimates following \\citet{callaway2021difference}. The ATT is the average treatment effect on the treated, aggregated across all group-time cells. Panel B reports standard two-way fixed effects estimates with state and year fixed effects for comparison. Standard errors clustered at the state level in parentheses. $^{***}p<0.01$, $^{**}p<0.05$, $^{*}p<0.10$. Current smoking rate is the share of adults who currently smoke every day or some days. Quit attempts are measured among ever-smokers (smoked 100+ lifetime cigarettes) as having stopped smoking for one day or longer in the past 12 months because they were trying to quit. Source: BRFSS 1996--2004, 2006--2016, 2021--2022 (22 survey years; approximately 7.5 million individual observations aggregated to state-year means).",
  "\\end{minipage}",
  "\\end{table}"
)

writeLines(main_tex, file.path(table_dir, "tab2_main_results.tex"))

# ============================================================================
# Table 3: Robustness Checks
# ============================================================================

cat("Table 3: Robustness...\n")

if (file.exists(file.path(data_dir, "robustness_results.rds"))) {
  robust <- readRDS(file.path(data_dir, "robustness_results.rds"))

  robust_tex <- c(
    "\\begin{table}[htbp]",
    "\\centering",
    "\\caption{Robustness Checks: Effect on Current Smoking Rate}",
    "\\label{tab:robustness}",
    "\\begin{tabular}{lcc}",
    "\\toprule",
    "Specification & ATT & SE \\\\",
    "\\midrule",
    sprintf("Main estimate (DR-DiD) & %.4f & (%.4f) \\\\",
            results$att_smoking$overall.att, results$att_smoking$overall.se)
  )

  # LORO results
  if (!is.null(robust$loro_results)) {
    for (nm in names(robust$loro_results)) {
      r <- robust$loro_results[[nm]]
      robust_tex <- c(robust_tex,
        sprintf("Drop %s & %.4f & (%.4f) \\\\", nm, r$att, r$se))
    }
  }

  # Full-year exposure
  if (!is.null(robust$cs_full_year)) {
    att_full <- aggte(robust$cs_full_year, type = "simple")
    robust_tex <- c(robust_tex,
      sprintf("Full-year exposure only & %.4f & (%.4f) \\\\",
              att_full$overall.att, att_full$overall.se))
  }

  # Not-yet-treated
  if (!is.null(robust$cs_nyt)) {
    att_nyt <- aggte(robust$cs_nyt, type = "simple")
    robust_tex <- c(robust_tex,
      sprintf("Not-yet-treated controls & %.4f & (%.4f) \\\\",
              att_nyt$overall.att, att_nyt$overall.se))
  }

  # Drop 2016 cohort (California)
  if (!is.null(robust$att_no2016)) {
    robust_tex <- c(robust_tex,
      sprintf("Drop 2016 cohort (California) & %.4f & (%.4f) \\\\",
              robust$att_no2016$overall.att, robust$att_no2016$overall.se))
  }

  # Some-days decomposition
  if (!is.null(robust$somedays_att)) {
    sd_att <- robust$somedays_att
    sd_pval <- 2 * pnorm(-abs(sd_att$overall.att / sd_att$overall.se))
    sd_stars <- make_stars(sd_pval)
    robust_tex <- c(robust_tex,
      "\\midrule",
      "\\multicolumn{3}{l}{\\textit{Compositional decomposition}} \\\\",
      sprintf("Some-days smoking rate & %.4f%s & (%.4f) \\\\",
              sd_att$overall.att, sd_stars, sd_att$overall.se))
  }

  # RI p-value
  robust_tex <- c(robust_tex,
    "\\midrule",
    sprintf("Randomization inference $p$-value & \\multicolumn{2}{c}{%.3f} \\\\",
            robust$ri_pvalue),
    "\\bottomrule",
    "\\end{tabular}",
    "\\begin{minipage}{0.85\\textwidth}",
    "\\vspace{0.5em}",
    "\\footnotesize",
    "\\textit{Notes:} All specifications use the Callaway-Sant'Anna doubly-robust estimator with never-treated states as the control group, except where noted. ``Drop [Region]'' excludes all states in the specified Census region. ``Full-year exposure'' redefines treatment onset as the first full calendar year after ban adoption. ``Not-yet-treated controls'' uses states that have not yet adopted as the comparison group instead of never-treated states. ``Drop 2016 cohort (California)'' excludes California, whose first post-treatment observation is 2021 due to missing 2017--2020 data (see \\Cref{sec:data_gaps}). ``Some-days smoking rate'' decomposes current smoking into everyday and some-days components; a negative effect on some-days smoking supports the compositional reclassification hypothesis for the everyday smoking result. Randomization inference $p$-value based on 1{,}000 permutations of treatment assignment. $^{***}p<0.01$, $^{**}p<0.05$, $^{*}p<0.10$.",
    "\\end{minipage}",
    "\\end{table}"
  )

  writeLines(robust_tex, file.path(table_dir, "tab3_robustness.tex"))
}

cat("\n=== All tables generated ===\n")
cat(sprintf("  Output directory: %s\n", table_dir))
cat(sprintf("  Files: %s\n", paste(list.files(table_dir), collapse = ", ")))
