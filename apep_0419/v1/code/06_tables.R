##############################################################################
# 06_tables.R — All Table Generation
# Virtual Snow Days and the Weather-Absence Penalty for Working Parents
##############################################################################

source("code/00_packages.R")

cat("=== STEP 6: GENERATE TABLES ===\n\n")

winter_panel <- readRDS("data/winter_panel.rds")
policy_data <- readRDS("data/policy_data.rds")
all_states <- readRDS("data/all_states.rds")

##############################################################################
# Table 1: Summary Statistics
##############################################################################

cat("--- Table 1: Summary Statistics ---\n")

sumstats <- winter_panel %>%
  group_by(Group = ifelse(ever_treated, "Treated States", "Never-Treated States")) %>%
  summarize(
    `N (state-winters)` = n(),
    `Mean Storm Events` = mean(total_winter_events, na.rm = TRUE),
    `SD Storm Events` = sd(total_winter_events, na.rm = TRUE),
    `Mean Absence Proxy ($\\times 10^3$)` = mean(weather_absence_proxy, na.rm = TRUE) * 1000,
    `SD Absence Proxy ($\\times 10^3$)` = sd(weather_absence_proxy, na.rm = TRUE) * 1000,
    `Mean Employment (000s)` = mean(mean_employment / 1000, na.rm = TRUE),
    .groups = "drop"
  )

# LaTeX output
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Summary Statistics by Treatment Group}\n")
cat("\\label{tab:sumstats}\n")
cat("\\begin{tabular}{lcc}\n")
cat("\\toprule\n")
cat(" & Treated States & Never-Treated States \\\\\n")
cat("\\midrule\n")

# Ensure correct column order: row with "Never-Treated" -> col 2, "Treated" -> col 1
treated_row <- which(grepl("Treated States", sumstats$Group) & !grepl("Never", sumstats$Group))
never_row <- which(grepl("Never", sumstats$Group))
for (var in names(sumstats)[-1]) {
  vals <- sumstats[[var]]
  cat(sprintf("%s & %.2f & %.2f \\\\\n", var, vals[treated_row], vals[never_row]))
}

cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{tablenotes}[flushleft]\n")
cat("\\small\n")
cat("\\item \\textit{Notes:} Treated states are those that adopted virtual snow day laws through 2023.\n")
cat("Storm events are NOAA-recorded winter weather events (Winter Storm, Heavy Snow, Blizzard,\n")
cat("Ice Storm) per state-winter season (November--March). Winter temperature is the state-level\n")
cat("average from NOAA Climate at a Glance. Employment from BLS LAUS.\n")
cat("\\end{tablenotes}\n")
cat("\\end{table}\n\n")

# Save as LaTeX file
sink("tables/tab1_sumstats.tex")
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Summary Statistics by Treatment Group}\n")
cat("\\label{tab:sumstats}\n")
cat("\\begin{tabular}{lcc}\n")
cat("\\toprule\n")
cat(" & Treated States & Never-Treated States \\\\\n")
cat("\\midrule\n")
treated_row <- which(grepl("Treated States", sumstats$Group) & !grepl("Never", sumstats$Group))
never_row <- which(grepl("Never", sumstats$Group))
for (var in names(sumstats)[-1]) {
  vals <- sumstats[[var]]
  cat(sprintf("%s & %.2f & %.2f \\\\\n", var, vals[treated_row], vals[never_row]))
}
cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{tablenotes}[flushleft]\n")
cat("\\small\n")
cat("\\item \\textit{Notes:} Treated states are those that adopted virtual snow day laws through 2023. Storm events are NOAA-recorded winter weather events per state-winter season (November--March). Absence proxy scaled by $10^3$ for readability. Employment from BLS LAUS.\n")
cat("\\end{tablenotes}\n")
cat("\\end{table}\n")
sink()
cat("  Saved tables/tab1_sumstats.tex\n")

##############################################################################
# Table 2: Policy Adoption Timeline
##############################################################################

cat("--- Table 2: Policy Timeline ---\n")

timeline <- policy_data %>%
  arrange(adopt_year, state_name) %>%
  mutate(
    era = case_when(
      adopt_year <= 2019 ~ "Pre-COVID",
      adopt_year <= 2021 ~ "COVID-era",
      TRUE ~ "Post-COVID"
    ),
    max_days_str = ifelse(is.na(max_days), "Unlimited", as.character(max_days))
  )

sink("tables/tab2_timeline.tex")
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Virtual Snow Day Law Adoption Timeline}\n")
cat("\\label{tab:timeline}\n")
cat("\\begin{tabular}{llccl}\n")
cat("\\toprule\n")
cat("State & Year & Type & Max Days & Era \\\\\n")
cat("\\midrule\n")

for (i in 1:nrow(timeline)) {
  row <- timeline[i, ]
  cat(sprintf("%s & %d & %s & %s & %s \\\\\n",
              row$state_name, row$adopt_year, row$adopt_type,
              row$max_days_str, row$era))
}

cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{tablenotes}[flushleft]\n")
cat("\\small\n")
cat("\\item \\textit{Notes:} ``Packet'' indicates pre-assembled take-home assignments; ``Virtual'' indicates live or asynchronous online instruction. Max Days = maximum virtual weather days per school year allowed by state law. Sources: EdWeek (2023), The 74 Million (2022), state legislation databases.\n")
cat("\\end{tablenotes}\n")
cat("\\end{table}\n")
sink()
cat("  Saved tables/tab2_timeline.tex\n")

##############################################################################
# Table 3: Main Results
##############################################################################

cat("--- Table 3: Main Results ---\n")

twfe_results <- tryCatch(readRDS("data/twfe_results.rds"), error = function(e) NULL)
cs_results <- tryCatch(readRDS("data/cs_results.rds"), error = function(e) NULL)
precovid <- tryCatch(readRDS("data/precovid_results.rds"), error = function(e) NULL)

storm_int <- tryCatch(readRDS("data/storm_interaction_results.rds"), error = function(e) NULL)

if (!is.null(twfe_results)) {
  # Use fixest etable for clean LaTeX
  models <- list(
    "TWFE" = twfe_results$m1,
    "TWFE + Storms" = twfe_results$m2,
    "TWFE + Controls" = twfe_results$m3
  )

  if (!is.null(precovid) && !is.null(precovid$twfe)) {
    models[["Pre-COVID"]] <- precovid$twfe
  }

  # Add storm interaction models (Issue 7: continuous storm interaction)
  if (!is.null(storm_int)) {
    if (!is.null(storm_int$continuous)) {
      models[["Storm Interaction"]] <- storm_int$continuous
    }
  }

  # Remove existing file first since etable appends rather than overwrites
  if (file.exists("tables/tab3_main_results.tex")) file.remove("tables/tab3_main_results.tex")

  etable(
    models,
    tex = TRUE,
    style.tex = style.tex("aer"),
    fitstat = ~ r2 + n,
    title = "Effect of Virtual Snow Day Laws on Weather-Related Work Absences",
    label = "tab:main_results",
    depvar = FALSE,
    dict = c(treatedTRUE = "Virtual Snow Day",
             total_winter_events = "Storm Events",
             "treatedTRUE:total_winter_events" = "Virtual $\\times$ Storms",
             parent_emp_rate = "Working Parent Share",
             storm_deviation = "Storm Deviation",
             "treatedTRUE:storm_deviation" = "Virtual $\\times$ Storm Dev.",
             state_fips = "State",
             winter_season = "Winter Season"),
    file = "tables/tab3_main_results.tex"
  )

  # Post-process: add resizebox and table notes using fixed string replacement
  tab_text <- paste(readLines("tables/tab3_main_results.tex"), collapse = "\n")
  tab_text <- gsub("\\begin{tabular}", "\\resizebox{\\textwidth}{!}{\\begin{tabular}", tab_text, fixed = TRUE)
  tab_text <- gsub("\\end{tabular}", "\\end{tabular}}", tab_text, fixed = TRUE)
  # Insert table notes before \end{table}
  notes <- paste0(
    "\\begin{tablenotes}[flushleft]\n",
    "\\small\n",
    "\\item \\textit{Notes:} Standard errors clustered at the state level in parentheses. ",
    "* $p<0.1$, ** $p<0.05$, *** $p<0.01$. ",
    "Column (1): baseline TWFE. Column (2): adds storm events and treatment interaction. ",
    "Column (3): adds ACS parental employment control (816 obs due to ACS coverage). ",
    "Column (4): pre-COVID subsample (2006--2019), restricted to 8 pre-COVID adopters and 28 never-treated states (504 obs). ",
    "Column (5): continuous storm-deviation specification.\n",
    "\\end{tablenotes}\n"
  )
  tab_text <- gsub("\\end{table}", paste0(notes, "\\end{table}"), tab_text, fixed = TRUE)
  writeLines(tab_text, "tables/tab3_main_results.tex")
  cat("  Saved tables/tab3_main_results.tex\n")
}

##############################################################################
# Table 4: Callaway-Sant'Anna Results
##############################################################################

cat("--- Table 4: CS-DiD Results ---\n")

if (!is.null(cs_results)) {
  sink("tables/tab4_cs_results.tex")
  cat("\\begin{table}[htbp]\n")
  cat("\\centering\n")
  cat("\\caption{Callaway-Sant'Anna Difference-in-Differences Results}\n")
  cat("\\label{tab:cs_results}\n")
  cat("\\begin{tabular}{lccc}\n")
  cat("\\toprule\n")
  cat("Aggregation & ATT & SE & 95\\% CI \\\\\n")
  cat("\\midrule\n")

  # Overall
  ov <- cs_results$overall
  cat(sprintf("Overall & %.6f & (%.6f) & [%.6f, %.6f] \\\\\n",
              ov$overall.att, ov$overall.se,
              ov$overall.att - 1.96 * ov$overall.se,
              ov$overall.att + 1.96 * ov$overall.se))

  # Group averages
  if (!is.null(cs_results$group)) {
    grp <- cs_results$group
    for (j in seq_along(grp$egt)) {
      cat(sprintf("Adoption %d & %.6f & (%.6f) & [%.6f, %.6f] \\\\\n",
                  grp$egt[j] - 1L, grp$att.egt[j], grp$se.egt[j],
                  grp$att.egt[j] - 1.96 * grp$se.egt[j],
                  grp$att.egt[j] + 1.96 * grp$se.egt[j]))
    }
  }

  cat("\\midrule\n")
  cat("Estimator & \\multicolumn{3}{c}{Callaway-Sant'Anna (2021)} \\\\\n")
  cat("Control Group & \\multicolumn{3}{c}{Never-treated} \\\\\n")
  cat("\\# Treated States & \\multicolumn{3}{c}{",
      sum(all_states$ever_treated), "} \\\\\n")
  cat("\\# Never-Treated & \\multicolumn{3}{c}{",
      sum(!all_states$ever_treated), "} \\\\\n")
  cat("Clustering & \\multicolumn{3}{c}{State} \\\\\n")
  cat("\\bottomrule\n")
  cat("\\end{tabular}\n")
  cat("\\begin{tablenotes}[flushleft]\n")
  cat("\\small\n")
  cat("\\item \\textit{Notes:} ATT estimated using the Callaway and Sant'Anna (2021) doubly-robust estimator with never-treated states as the comparison group. Standard errors clustered at the state level. The overall ATT is a simple weighted average across all group-time ATTs. Cohorts labeled by adoption year; first treatment begins in the following winter season (e.g., adoption 2011 $\\rightarrow$ first treated winter 2012).\n")
  cat("\\end{tablenotes}\n")
  cat("\\end{table}\n")
  sink()
  cat("  Saved tables/tab4_cs_results.tex\n")
}

##############################################################################
# Table 5: Robustness Checks
##############################################################################

cat("--- Table 5: Robustness ---\n")

rob_summary <- tryCatch(readRDS("data/robustness_summary.rds"), error = function(e) NULL)
boot_result <- tryCatch(readRDS("data/wild_bootstrap.rds"), error = function(e) NULL)
ri_results <- tryCatch(readRDS("data/ri_results.rds"), error = function(e) NULL)

sink("tables/tab5_robustness.tex")
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Robustness Checks}\n")
cat("\\label{tab:robustness}\n")
cat("\\begin{tabular}{lccc}\n")
cat("\\toprule\n")
cat("Specification & Estimate & SE/p-value & Notes \\\\\n")
cat("\\midrule\n")

# Baseline
if (!is.null(twfe_results)) {
  base <- twfe_results$m1
  # Coefficient name is "treatedTRUE" from fixest logical variable
  treat_name <- grep("treated", names(coef(base)), value = TRUE)[1]
  cat(sprintf("Baseline TWFE & %.6f & (%.6f) & Full sample \\\\\n",
              coef(base)[treat_name], se(base)[treat_name]))
}

# Placebo
if (!is.null(rob_summary) && !is.null(rob_summary$placebo_summer)) {
  plac <- rob_summary$placebo_summer
  treat_name_p <- grep("treated", names(coef(plac)), value = TRUE)[1]
  cat(sprintf("Summer Placebo & %.6f & (%.6f) & Should be zero \\\\\n",
              coef(plac)[treat_name_p], se(plac)[treat_name_p]))
}

# Wild bootstrap
if (!is.null(boot_result)) {
  boot_est <- if (!is.null(boot_result$point_est)) boot_result$point_est else coef(twfe_results$m1)[grep("treated", names(coef(twfe_results$m1)))[1]]
  cat(sprintf("Wild Cluster Bootstrap & %.6f & p = %.4f & Rademacher weights \\\\\n",
              boot_est, boot_result$p_val))
}

# RI
if (!is.null(ri_results)) {
  ri_est <- if (!is.null(ri_results$observed)) ri_results$observed else coef(twfe_results$m1)[grep("treated", names(coef(twfe_results$m1)))[1]]
  cat(sprintf("Randomization Inference & %.6f & p = %.4f & 1,000 permutations \\\\\n",
              ri_est, ri_results$ri_pvalue))
}

cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{tablenotes}[flushleft]\n")
cat("\\small\n")
cat("\\item \\textit{Notes:} Baseline is TWFE with state and winter-season fixed effects, clustered at the state level. Summer placebo uses June--August (school not in session). Wild cluster bootstrap uses Rademacher weights with 999 replications. Randomization inference permutes treatment assignment across states 1,000 times.\n")
cat("\\end{tablenotes}\n")
cat("\\end{table}\n")
sink()
cat("  Saved tables/tab5_robustness.tex\n")

cat("\n=== TABLES COMPLETE ===\n")
