## ============================================================
## 06_tables.R — All tables for the paper
## Paper: Where Medicaid Goes Dark (apep_0417 v2)
## Changes from v1: 6 specialties, add 95% CIs, mean dep var,
## Medicaid-pop denominator column, new appendix tables
## ============================================================

source("00_packages.R")

cat("\n=== Load Data ===\n")
panel <- readRDS(file.path(DATA_DIR, "analysis_panel.rds"))
panel_mdonly <- readRDS(file.path(DATA_DIR, "analysis_panel_mdonly.rds"))
results <- readRDS(file.path(DATA_DIR, "main_results.rds"))
robustness <- readRDS(file.path(DATA_DIR, "robustness_results.rds"))
unwinding <- readRDS(file.path(DATA_DIR, "unwinding_treatment.rds"))

panel <- panel[!is.na(total_pop) & total_pop > 0 &
               state_fips %in% sprintf("%02d", c(1:56))]
panel_mdonly <- panel_mdonly[!is.na(total_pop) & total_pop > 0 &
                             state_fips %in% sprintf("%02d", c(1:56))]

cat("\n=== Table 1: Summary Statistics ===\n")

sumstats_spec <- panel[, .(
  `County-Quarters` = format(.N, big.mark = ","),
  `Counties` = format(uniqueN(county_fips), big.mark = ","),
  `Mean Providers` = sprintf("%.1f", mean(n_providers)),
  `SD` = sprintf("%.1f", sd(n_providers)),
  `\\% Zero` = sprintf("%.1f", 100 * mean(n_providers == 0)),
  `Per 10K Pop` = sprintf("%.2f", mean(providers_per_10k, na.rm = TRUE)),
  `Per 10K Medicaid` = sprintf("%.2f", mean(providers_per_10k_medicaid, na.rm = TRUE)),
  `\\% Desert` = sprintf("%.1f", 100 * mean(is_desert, na.rm = TRUE))
), by = .(Specialty = specialty)]

sumstats_spec <- sumstats_spec[order(-as.numeric(gsub(",", "", `County-Quarters`)))]

tab1_latex <- kbl(sumstats_spec, format = "latex", booktabs = TRUE,
                   escape = FALSE, align = c("l", rep("r", 8)),
                   caption = "Summary Statistics by Specialty",
                   label = "sumstats") |>
  kable_styling(latex_options = c("scale_down")) |>
  footnote(general = "Sample: US county $\\\\times$ specialty $\\\\times$ quarter observations, 2018Q1--2024Q3. All clinicians measure includes NPs/PAs mapped to their clinical specialty. Active providers defined as billing $\\\\geq$4 Medicaid claims per quarter. Desert: $<$1 active clinician per 10,000 county population.",
           escape = FALSE, threeparttable = TRUE)

writeLines(tab1_latex, file.path(TAB_DIR, "tab1_sumstats.tex"))
cat("  Saved tab1_sumstats.tex\n")

cat("\n=== Table 2: Provider Trends by Specialty and Year ===\n")

panel[, qtr_of_year := as.integer(substr(quarter, 6, 6))]

trends <- panel[qtr_of_year <= 3, .(
  providers = round(sum(n_providers) / uniqueN(quarter))
), by = .(specialty, year)]

trends_wide <- dcast(trends, specialty ~ year, value.var = "providers")

year_cols <- setdiff(names(trends_wide), "specialty")
first_year <- year_cols[1]
last_year <- year_cols[length(year_cols)]
trends_wide[, `Change (\\%)` := sprintf("%.1f",
  100 * (get(last_year) / get(first_year) - 1))]

tab2_latex <- kbl(trends_wide, format = "latex", booktabs = TRUE,
                   escape = FALSE, align = c("l", rep("r", ncol(trends_wide) - 1)),
                   caption = "Active Medicaid Clinicians by Specialty and Year (Mean Quarterly Count)",
                   label = "trends",
                   format.args = list(big.mark = ",")) |>
  kable_styling(latex_options = c("scale_down")) |>
  footnote(general = "Mean quarterly count of active clinicians across Q1--Q3 of each year (Q4 excluded for comparability since 2024 data ends at Q3). All clinicians (MD/DO + NP/PA mapped to clinical specialty) with $\\\\geq$4 Medicaid claims per quarter. Counts reflect unique providers per county-quarter summed across counties in each quarter, then averaged across quarters within the year.",
           escape = FALSE, threeparttable = TRUE)

writeLines(tab2_latex, file.path(TAB_DIR, "tab2_trends.tex"))
cat("  Saved tab2_trends.tex\n")

cat("\n=== Table 3: Main DiD Results ===\n")

panel[, treat_intensity := post_unwind * net_disenroll_pct / 100]

m1 <- results$m1
m3 <- results$m3
m2 <- results$m2

# Mean dependent variable by specialty
mean_depvar <- panel[, .(mean_y = round(mean(ln_providers), 3)), by = specialty]

spec_rows <- lapply(names(m2), function(nm) {
  spec_clean <- gsub("sample\\.var: specialty; sample: ", "", nm)
  mdv <- mean_depvar[specialty == spec_clean, mean_y]
  coef_val <- coef(m2[[nm]])["treat_intensity"]
  se_val <- se(m2[[nm]])["treat_intensity"]
  data.table(
    Specialty = spec_clean,
    Estimate = sprintf("%.4f", coef_val),
    SE = sprintf("(%.4f)", se_val),
    `95\\% CI` = sprintf("[%.3f, %.3f]", coef_val - 1.96 * se_val, coef_val + 1.96 * se_val),
    Stars = ifelse(fixest::pvalue(m2[[nm]])["treat_intensity"] < 0.01, "***",
            ifelse(fixest::pvalue(m2[[nm]])["treat_intensity"] < 0.05, "**",
            ifelse(fixest::pvalue(m2[[nm]])["treat_intensity"] < 0.10, "*", ""))),
    `Mean $\\bar{Y}$` = sprintf("%.3f", mdv),
    N = format(nobs(m2[[nm]]), big.mark = ",")
  )
})

pooled_mdv <- panel[, round(mean(ln_providers), 3)]
pooled_coef <- coef(m1)["treat_intensity"]
pooled_se <- se(m1)["treat_intensity"]
pooled_row <- data.table(
  Specialty = "\\textit{Pooled (all specialties)}",
  Estimate = sprintf("%.4f", pooled_coef),
  SE = sprintf("(%.4f)", pooled_se),
  `95\\% CI` = sprintf("[%.3f, %.3f]", pooled_coef - 1.96 * pooled_se, pooled_coef + 1.96 * pooled_se),
  Stars = ifelse(fixest::pvalue(m1)["treat_intensity"] < 0.01, "***",
          ifelse(fixest::pvalue(m1)["treat_intensity"] < 0.05, "**",
          ifelse(fixest::pvalue(m1)["treat_intensity"] < 0.10, "*", ""))),
  `Mean $\\bar{Y}$` = sprintf("%.3f", pooled_mdv),
  N = format(nobs(m1), big.mark = ",")
)
spec_table <- rbind(pooled_row, rbindlist(spec_rows))

tab3_latex <- kbl(spec_table, format = "latex", booktabs = TRUE,
                   escape = FALSE, align = c("l", "r", "r", "c", "c", "r", "r"),
                   caption = "Effect of Medicaid Unwinding on Provider Supply by Specialty",
                   label = "main_by_spec") |>
  kable_styling(latex_options = c("scale_down")) |>
  footnote(general = "Dependent variable: $\\\\log$(active clinicians + 1). Treatment: post-unwinding $\\\\times$ net disenrollment rate. All clinicians includes NPs/PAs mapped to their clinical specialty. All models include county$\\\\times$specialty and quarter fixed effects. Standard errors clustered at the state level (51 clusters). * p$<$0.10, ** p$<$0.05, *** p$<$0.01.",
           escape = FALSE, threeparttable = TRUE)

writeLines(tab3_latex, file.path(TAB_DIR, "tab3_main_by_specialty.tex"))
cat("  Saved tab3_main_by_specialty.tex\n")

cat("\n=== Table 4: Robustness Checks ===\n")

# Use pre-computed Sun-Abraham ATT values (saved as scalars in 03_main_analysis.R)
sa_coef <- results$sa_att_coef
sa_se <- results$sa_att_se
sa_n <- results$sa_att_n

rob_rows <- data.table(
  Specification = c(
    "Main (all clinicians, $\\geq$4 claims/qtr)",
    "Sun-Abraham ATT (interaction-weighted)",
    "Full-time threshold ($\\geq$36 claims/qtr)",
    "Binary treatment (early vs.\\ late)",
    "With Medicaid share $\\times$ time",
    "Medicaid pop denominator (desert)",
    "Region $\\times$ quarter FE",
    "Total claims (log) as outcome",
    "No NP/PA (excl.\\ nurse practitioners/PAs)",
    "Placebo (fake 2021Q2 treatment)"
  ),
  Estimate = c(
    sprintf("%.4f", coef(results$m1)["treat_intensity"]),
    sprintf("%.4f", sa_coef),
    sprintf("%.4f", coef(robustness$rob1_ft)["treat_intensity"]),
    sprintf("%.4f", coef(robustness$rob3_binary)["treat_binary"]),
    sprintf("%.4f", coef(robustness$rob4_controls)["treat_intensity"]),
    sprintf("%.4f", coef(robustness$rob5_medicaid_denom)["treat_intensity"]),
    sprintf("%.4f", coef(robustness$rob6_region_qtr)["treat_intensity"]),
    sprintf("%.4f", coef(robustness$rob7_claims)["treat_intensity"]),
    sprintf("%.4f", coef(robustness$rob8_mdonly)["treat_intensity"]),
    sprintf("%.4f", coef(robustness$placebo)["fake_treat"])
  ),
  SE = c(
    sprintf("(%.4f)", se(results$m1)["treat_intensity"]),
    sprintf("(%.4f)", sa_se),
    sprintf("(%.4f)", se(robustness$rob1_ft)["treat_intensity"]),
    sprintf("(%.4f)", se(robustness$rob3_binary)["treat_binary"]),
    sprintf("(%.4f)", se(robustness$rob4_controls)["treat_intensity"]),
    sprintf("(%.4f)", se(robustness$rob5_medicaid_denom)["treat_intensity"]),
    sprintf("(%.4f)", se(robustness$rob6_region_qtr)["treat_intensity"]),
    sprintf("(%.4f)", se(robustness$rob7_claims)["treat_intensity"]),
    sprintf("(%.4f)", se(robustness$rob8_mdonly)["treat_intensity"]),
    sprintf("(%.4f)", se(robustness$placebo)["fake_treat"])
  ),
  N = c(
    format(nobs(results$m1), big.mark = ","),
    format(sa_n, big.mark = ","),
    format(nobs(robustness$rob1_ft), big.mark = ","),
    format(nobs(robustness$rob3_binary), big.mark = ","),
    format(nobs(robustness$rob4_controls), big.mark = ","),
    format(nobs(robustness$rob5_medicaid_denom), big.mark = ","),
    format(nobs(robustness$rob6_region_qtr), big.mark = ","),
    format(nobs(robustness$rob7_claims), big.mark = ","),
    format(nobs(robustness$rob8_mdonly), big.mark = ","),
    format(nobs(robustness$placebo), big.mark = ",")
  )
)

ri_note <- sprintf("Randomization inference (500 permutations of treatment timing across states) yields p = %.3f for the main specification.",
                   robustness$ri_pvalue)

tab4_latex <- kbl(rob_rows, format = "latex", booktabs = TRUE,
                   escape = FALSE,
                   caption = "Robustness Checks",
                   label = "robustness") |>
  kable_styling(latex_options = c("scale_down")) |>
  footnote(general = paste0("All models include county$\\\\times$specialty and quarter fixed effects with state-clustered standard errors (51 clusters) unless noted. Placebo test uses only pre-unwinding observations; N varies because states have different unwinding start dates. ", ri_note),
           escape = FALSE, threeparttable = TRUE)

writeLines(tab4_latex, file.path(TAB_DIR, "tab4_robustness.tex"))
cat("  Saved tab4_robustness.tex\n")

cat("\n=== Table 5: Desert County Counts by Specialty ===\n")

desert_counts <- panel[, .(
  pct_desert = 100 * mean(is_desert, na.rm = TRUE),
  n_desert = sum(is_desert, na.rm = TRUE),
  n_total = sum(!is.na(is_desert))
), by = .(specialty, period = ifelse(quarter < "2023Q2", "Pre-Unwinding (2018Q1-2023Q1)",
                                      "Post-Unwinding (2023Q2-2024Q3)"))]

desert_overall <- panel[, .(
  pct_desert = 100 * mean(is_desert, na.rm = TRUE)
), by = .(specialty)]

desert_wide <- dcast(desert_counts, specialty ~ period, value.var = "pct_desert")
desert_wide <- merge(desert_wide, desert_overall, by = "specialty")
setnames(desert_wide, "pct_desert", "Overall")

setcolorder(desert_wide, c("specialty", "Pre-Unwinding (2018Q1-2023Q1)",
                            "Post-Unwinding (2023Q2-2024Q3)", "Overall"))

tab5_latex <- kbl(desert_wide, format = "latex", booktabs = TRUE,
                   digits = 1,
                   caption = "Percentage of County-Quarters in Desert Status, Pre vs.\\ Post Unwinding",
                   label = "desert_counts") |>
  kable_styling() |>
  footnote(general = "Desert: county-specialty-quarter with $<$1 active Medicaid clinician per 10,000 population. All clinicians measure includes NPs/PAs mapped to clinical specialty. Overall column is the unweighted mean across all quarters.",
           escape = FALSE, threeparttable = TRUE)

writeLines(tab5_latex, file.path(TAB_DIR, "tab5_desert_counts.tex"))
cat("  Saved tab5_desert_counts.tex\n")

cat("\n=== Appendix Table A1: MD/DO-Only DiD Results ===\n")

m1_mdonly <- results$m1_mdonly
m2_mdonly <- results$m2_mdonly

panel_mdonly[, treat_intensity := post_unwind * net_disenroll_pct / 100]
mean_depvar_mdonly <- panel_mdonly[, .(mean_y = round(mean(ln_providers), 3)), by = specialty]

mdonly_rows <- lapply(names(m2_mdonly), function(nm) {
  spec_clean <- gsub("sample\\.var: specialty; sample: ", "", nm)
  mdv <- mean_depvar_mdonly[specialty == spec_clean, mean_y]
  coef_val <- coef(m2_mdonly[[nm]])["treat_intensity"]
  se_val <- se(m2_mdonly[[nm]])["treat_intensity"]
  data.table(
    Specialty = spec_clean,
    Estimate = sprintf("%.4f", coef_val),
    SE = sprintf("(%.4f)", se_val),
    `Mean $\\bar{Y}$` = sprintf("%.3f", mdv),
    N = format(nobs(m2_mdonly[[nm]]), big.mark = ",")
  )
})

pooled_mdv_mdonly <- panel_mdonly[, round(mean(ln_providers), 3)]
pooled_row_mdonly <- data.table(
  Specialty = "\\textit{Pooled}",
  Estimate = sprintf("%.4f", coef(m1_mdonly)["treat_intensity"]),
  SE = sprintf("(%.4f)", se(m1_mdonly)["treat_intensity"]),
  `Mean $\\bar{Y}$` = sprintf("%.3f", pooled_mdv_mdonly),
  N = format(nobs(m1_mdonly), big.mark = ",")
)
mdonly_table <- rbind(pooled_row_mdonly, rbindlist(mdonly_rows))

tabA1_latex <- kbl(mdonly_table, format = "latex", booktabs = TRUE,
                    escape = FALSE, align = c("l", "r", "r", "r", "r"),
                    caption = "Effect of Medicaid Unwinding on Provider Supply: No-NP/PA Panel",
                    label = "mdonly_results") |>
  kable_styling() |>
  footnote(general = "Dependent variable: $\\\\log$(active clinicians + 1). No-NP/PA classification excludes nurse practitioners and physician assistants but retains credential-based specialties (Behavioral Health and Dental) that have no NP/PA taxonomy mappings. Standard errors clustered at the state level. BH and Dental estimates are identical to the all-clinicians panel by construction. Both panels use the same balanced county $\\\\times$ specialty $\\\\times$ quarter structure (zero-filled), so N is identical; only provider counts differ.",
           escape = FALSE, threeparttable = TRUE)

writeLines(tabA1_latex, file.path(TAB_DIR, "tabA1_mdonly_results.tex"))
cat("  Saved tabA1_mdonly_results.tex\n")

cat("\n=== Appendix Table A2: Desert Rate Comparison (All Clinicians vs MD/DO) ===\n")

desert_all <- panel[, .(
  pct_desert_all = round(100 * mean(is_desert, na.rm = TRUE), 1)
), by = specialty]

desert_md <- panel_mdonly[, .(
  pct_desert_md = round(100 * mean(is_desert, na.rm = TRUE), 1)
), by = specialty]

desert_compare <- merge(desert_all, desert_md, by = "specialty")
desert_compare[, Difference := round(pct_desert_md - pct_desert_all, 1)]
setnames(desert_compare, c("Specialty", "All Clinicians (\\%)",
                             "No NP/PA (\\%)", "Difference (pp)"))

tabA2_latex <- kbl(desert_compare, format = "latex", booktabs = TRUE,
                    escape = FALSE, align = c("l", "r", "r", "r"),
                    caption = "Desert Rates: All Clinicians vs.\\ No-NP/PA Panel",
                    label = "desert_comparison") |>
  kable_styling() |>
  footnote(general = "Desert: county-specialty-quarter with $<$1 active provider per 10,000 population. Difference = MD/DO rate minus all-clinicians rate (positive = including NPs reduces desert rate).",
           escape = FALSE, threeparttable = TRUE)

writeLines(tabA2_latex, file.path(TAB_DIR, "tabA2_desert_comparison.tex"))
cat("  Saved tabA2_desert_comparison.tex\n")

cat("\nAll tables saved to:", TAB_DIR, "\n")
