## 06_tables.R — Generate all tables
## apep_0462: Speed limit reversal and road safety in France

source(here::here("output", "apep_0462", "v1", "code", "00_packages.R"))

panel <- fread(file.path(DATA_DIR, "panel_quarterly.csv"))
annual <- fread(file.path(DATA_DIR, "panel_annual.csv"))
treat <- fread(file.path(DATA_DIR, "treatment_clean.csv"))
results <- readRDS(file.path(DATA_DIR, "main_results.rds"))
rob <- readRDS(file.path(DATA_DIR, "robustness_results.rds"))

# Recode late adopters
late_deps <- treat[reversal_year >= 2025, dep_code]
panel[dep_code %in% late_deps, treated := FALSE]
annual[dep_code %in% late_deps, treated := FALSE]

# ── Table 1: Summary Statistics ──────────────────────────────────────

summ_treated <- panel[treated == TRUE & year <= 2019, .(
  `Mean Accidents` = sprintf("%.2f", mean(accidents)),
  `SD Accidents` = sprintf("%.2f", sd(accidents)),
  `Mean Killed` = sprintf("%.3f", mean(killed)),
  `Mean Hospitalized` = sprintf("%.2f", mean(hospitalized)),
  `Mean Casualties` = sprintf("%.2f", mean(total_casualties)),
  `N Dept-Quarters` = .N,
  `N Départements` = uniqueN(dep_code)
)]

summ_control <- panel[treated == FALSE & year <= 2019, .(
  `Mean Accidents` = sprintf("%.2f", mean(accidents)),
  `SD Accidents` = sprintf("%.2f", sd(accidents)),
  `Mean Killed` = sprintf("%.3f", mean(killed)),
  `Mean Hospitalized` = sprintf("%.2f", mean(hospitalized)),
  `Mean Casualties` = sprintf("%.2f", mean(total_casualties)),
  `N Dept-Quarters` = .N,
  `N Départements` = uniqueN(dep_code)
)]

summ_all <- rbind(
  data.table(Group = "Reversed (treated)", summ_treated),
  data.table(Group = "Maintained 80 km/h (control)", summ_control)
)

# Write LaTeX table
tab1_tex <- kable(t(summ_all[, -1]), format = "latex", booktabs = TRUE,
                  col.names = c("Reversed", "Maintained 80"),
                  caption = "Summary Statistics: Pre-Period (2015--2019), Routes D\\'{e}partementales Outside Agglomeration") |>
  kable_styling(latex_options = c("hold_position"))

writeLines(tab1_tex, file.path(TAB_DIR, "tab1_summary.tex"))
cat("Table 1 saved.\n")

# ── Table 2: Main Results ────────────────────────────────────────────

# Combine CS-DiD and TWFE results
tab2_data <- data.frame(
  Outcome = c("Total Accidents", "Fatalities", "Hospitalized", "Total Casualties"),
  `CS-DiD ATT` = sprintf("%.3f",
    c(results$agg_overall$overall.att, results$agg_killed$overall.att,
      results$agg_hosp$overall.att, results$agg_total$overall.att)),
  `CS-DiD SE` = sprintf("(%.3f)",
    c(results$agg_overall$overall.se, results$agg_killed$overall.se,
      results$agg_hosp$overall.se, results$agg_total$overall.se)),
  `TWFE Est` = sprintf("%.3f",
    c(coef(results$twfe_acc), coef(results$twfe_kill),
      coef(results$twfe_hosp), coef(results$twfe_total))),
  `TWFE SE` = sprintf("(%.3f)",
    c(summary(results$twfe_acc)$coeftable[1,2],
      summary(results$twfe_kill)$coeftable[1,2],
      summary(results$twfe_hosp)$coeftable[1,2],
      summary(results$twfe_total)$coeftable[1,2])),
  check.names = FALSE
)

tab2_tex <- kable(tab2_data, format = "latex", booktabs = TRUE,
                  align = c("l", "r", "r", "r", "r"),
                  caption = "Main Results: Effect of 90 km/h Reversal on Road Safety") |>
  kable_styling(latex_options = c("hold_position")) |>
  add_header_above(c(" " = 1, "Callaway-Sant'Anna" = 2, "TWFE" = 2)) |>
  footnote(general = c(
    "Unit of observation: département-quarter. Sample: 2015Q1-2024Q4.",
    "Département and quarter fixed effects included. Standard errors clustered by département.",
    sprintf("N = %d. Treated départements: %d. Control: %d.",
            nrow(panel), uniqueN(panel[treated==TRUE, dep_code]),
            uniqueN(panel[treated==FALSE, dep_code]))))

writeLines(tab2_tex, file.path(TAB_DIR, "tab2_main.tex"))
cat("Table 2 saved.\n")

# ── Table 3: Robustness Checks ──────────────────────────────────────

get_coef_se <- function(mod) {
  ct <- summary(mod)$coeftable
  c(est = ct[1,1], se = ct[1,2], p = ct[1,4])
}

rob_specs <- list(
  `Baseline TWFE` = get_coef_se(results$twfe_acc),
  `Excl. COVID (Q1-Q3 2020)` = get_coef_se(rob$twfe_nocovid),
  `Late adopters (2022+)` = get_coef_se(rob$twfe_late),
  `High coverage (>50%)` = get_coef_se(rob$twfe_high),
  `Log(accidents + 1)` = get_coef_se(rob$twfe_log),
  `Intensity (share)` = get_coef_se(results$twfe_intensity),
  `Placebo: autoroute` = get_coef_se(rob$twfe_placebo_auto),
  `Placebo: urban dept rd` = get_coef_se(rob$twfe_placebo_urban),
  `Severity ratio` = get_coef_se(rob$twfe_severity)
)

# Add DDD
ct_ddd <- summary(rob$twfe_ddd)$coeftable
ddd_row <- grep("dept_road", rownames(ct_ddd))
rob_specs[["DDD (dept rd × treated)"]] <- c(
  est = ct_ddd[ddd_row, 1], se = ct_ddd[ddd_row, 2], p = ct_ddd[ddd_row, 4])

tab3_df <- do.call(rbind, lapply(names(rob_specs), function(nm) {
  r <- rob_specs[[nm]]
  stars <- ifelse(r["p"] < 0.01, "***",
           ifelse(r["p"] < 0.05, "**",
           ifelse(r["p"] < 0.10, "*", "")))
  data.frame(
    Specification = nm,
    Estimate = sprintf("%.3f%s", r["est"], stars),
    SE = sprintf("(%.3f)", r["se"]),
    stringsAsFactors = FALSE
  )
}))

tab3_tex <- kable(tab3_df, format = "latex", booktabs = TRUE, row.names = FALSE,
                  caption = "Robustness Checks: Total Accidents") |>
  kable_styling(latex_options = c("hold_position")) |>
  pack_rows("Main Specification", 1, 1) |>
  pack_rows("COVID Robustness", 2, 4) |>
  pack_rows("Alternative Outcomes", 5, 6) |>
  pack_rows("Placebo Tests", 7, 8) |>
  pack_rows("Triple-Difference", 9, 10) |>
  footnote(general = c(
    "* p < 0.10, ** p < 0.05, *** p < 0.01.",
    "All specifications include département and quarter FE with département-clustered SEs.",
    sprintf("RI p-value (500 permutations): %.4f.", rob$ri_pvalue)))

writeLines(tab3_tex, file.path(TAB_DIR, "tab3_robustness.tex"))
cat("Table 3 saved.\n")

# ── Table 4: Treatment Rollout ───────────────────────────────────────

treat_active <- treat[reversal_year < 2025]
rollout <- treat_active[, .(
  N = .N,
  `Full Coverage` = sum(coverage == "full"),
  `Mean Share (%)` = sprintf("%.1f", mean(share_pct)),
  `Median Share (%)` = sprintf("%.1f", median(share_pct))
), by = reversal_year]
rollout <- rollout[order(reversal_year)]
setnames(rollout, "reversal_year", "Year")

tab4_tex <- kable(rollout, format = "latex", booktabs = TRUE,
                  caption = "Treatment Rollout: 90 km/h Reversal by Year") |>
  kable_styling(latex_options = c("hold_position"))

writeLines(tab4_tex, file.path(TAB_DIR, "tab4_rollout.tex"))
cat("Table 4 saved.\n")

# ── Table 5: Event Study Coefficients ────────────────────────────────

es <- results$es_accidents
es_df <- data.frame(
  `Event Time` = es$egt,
  ATT = sprintf("%.3f", es$att.egt),
  SE = sprintf("(%.3f)", es$se.egt),
  check.names = FALSE
)
es_df <- es_df[!is.na(es$se.egt), ]

tab5_tex <- kable(es_df, format = "latex", booktabs = TRUE, row.names = FALSE,
                  caption = "Event Study Coefficients: Total Accidents (CS-DiD)") |>
  kable_styling(latex_options = c("hold_position"))

writeLines(tab5_tex, file.path(TAB_DIR, "tab5_event_study.tex"))
cat("Table 5 saved.\n")

cat("\nAll tables generated.\n")
