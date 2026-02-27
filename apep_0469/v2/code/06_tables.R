## ============================================================================
## 06_tables.R — All Tables for apep_0469 v2
## Missing Men, Rising Women (Census Linking Project Panel)
## ============================================================================
## Two-panel design: MEN linked individually, WIVES tracked through households.

source("code/00_packages.R")

data_dir <- "data"
tab_dir <- "tables"
dir.create(tab_dir, showWarnings = FALSE)

panel <- readRDS(file.path(data_dir, "linked_panel_40_50.rds"))
couples <- readRDS(file.path(data_dir, "couples_panel_40_50.rds"))
models <- readRDS(file.path(data_dir, "main_models.rds"))
robustness <- readRDS(file.path(data_dir, "robustness.rds"))
decomp <- readRDS(file.path(data_dir, "decomposition.rds"))
sumstats <- readRDS(file.path(data_dir, "summary_stats.rds"))

setFixest_dict(c(
  mob_std = "Mobilization Rate (std.)",
  d_in_lf = "$\\Delta$ Labor Force",
  d_occ_score = "$\\Delta$ Occ. Score",
  d_sei_score = "$\\Delta$ SEI",
  d_employed = "$\\Delta$ Employed",
  wife_d_in_lf = "$\\Delta$ Wife LF",
  wife_d_employed = "$\\Delta$ Wife Employed",
  wife_d_occ_score = "$\\Delta$ Wife Occ. Score",
  sp_in_lf_1950 = "Wife In LF (1950)",
  sp_in_lf_1940 = "Wife In LF (1940)",
  in_lf_1950 = "In LF (1950)",
  in_lf_1940 = "In LF (1940)",
  age_1940 = "Age (1940)",
  sp_age_1940 = "Wife Age (1940)",
  husband_age_1940 = "Husband Age (1940)",
  educ_years_1940 = "Education Years (1940)",
  sp_educ_years_1940 = "Wife Educ. Years (1940)",
  married_1940 = "Married (1940)",
  sp_married_1940 = "Wife Married (1940)",
  is_urban_1940 = "Urban (1940)",
  is_farm_1940 = "Farm (1940)",
  husband_occ_score_1940 = "Husband Occ. Score (1940)",
  husband_in_lf_1940 = "Husband In LF (1940)",
  husband_d_in_lf = "$\\Delta$ Husband LF",
  husband_d_employed = "$\\Delta$ Husband Employed",
  d_lf_female = "$\\Delta$ Female LFP",
  pct_urban = "\\% Urban (1940)",
  pct_farm = "\\% Farm (1940)",
  pct_black = "\\% Black (1940)",
  mean_educ = "Mean Education (1940)",
  pct_married = "\\% Married (1940)"
))


## --------------------------------------------------------------------------
## Table 1: Summary Statistics — Linked Panel + Couples Panel
## --------------------------------------------------------------------------

cat("--- Table 1: Summary Statistics ---\n")

men_stats <- data.table(
  Group = "Linked Men (Individual Panel)",
  N = format(nrow(panel), big.mark = ","),
  `LFP 1940` = sprintf("%.3f", mean(panel$in_lf_1940, na.rm = TRUE)),
  `LFP 1950` = sprintf("%.3f", mean(panel$in_lf_1950, na.rm = TRUE)),
  `DLFP` = sprintf("%.4f", mean(panel$d_in_lf, na.rm = TRUE)),
  `Age 1940` = sprintf("%.1f", mean(panel$age_1940)),
  `Married 1940` = sprintf("%.3f", mean(panel$married_1940, na.rm = TRUE)),
  `Pct Mover` = sprintf("%.1f", 100 * mean(panel$mover))
)

wife_stats <- data.table(
  Group = "Wives (Couples Panel)",
  N = format(nrow(couples), big.mark = ","),
  `LFP 1940` = sprintf("%.3f", mean(couples$sp_in_lf_1940, na.rm = TRUE)),
  `LFP 1950` = sprintf("%.3f", mean(couples$sp_in_lf_1950, na.rm = TRUE)),
  `DLFP` = sprintf("%.4f", mean(couples$wife_d_in_lf, na.rm = TRUE)),
  `Age 1940` = sprintf("%.1f", mean(couples$sp_age_1940, na.rm = TRUE)),
  `Married 1940` = "1.000",
  `Pct Mover` = "---"
)

husband_stats <- data.table(
  Group = "Husbands (Couples Panel)",
  N = format(nrow(couples), big.mark = ","),
  `LFP 1940` = sprintf("%.3f", mean(couples$husband_in_lf_1940, na.rm = TRUE)),
  `LFP 1950` = sprintf("%.3f", mean(couples$husband_in_lf_1950, na.rm = TRUE)),
  `DLFP` = sprintf("%.4f", mean(couples$husband_d_in_lf, na.rm = TRUE)),
  `Age 1940` = sprintf("%.1f", mean(couples$husband_age_1940, na.rm = TRUE)),
  `Married 1940` = "1.000",
  `Pct Mover` = "---"
)

tab1 <- rbind(men_stats, wife_stats, husband_stats)

write.csv(tab1, file.path(tab_dir, "table1_summary_stats.csv"), row.names = FALSE)

tab1_tex <- kableExtra::kbl(tab1, format = "latex", booktabs = TRUE,
  caption = "Summary Statistics: Census Linking Project Panel (1940-1950)",
  label = "sumstats",
  col.names = c("Sample", "N", "LFP 1940", "LFP 1950", "$\\Delta$LFP",
                "Age 1940", "Married 1940", "\\% Mover"),
  escape = FALSE) %>%
  kableExtra::kable_styling(latex_options = c("scale_down")) %>%
  kableExtra::footnote(general = "Men linked individually via ABE exact conservative algorithm (Abramitzky, Boustan, and Eriksson 2025). Wives tracked through husbands' households. Mover: changed state of residence between 1940 and 1950.",
                       threeparttable = TRUE)
writeLines(tab1_tex, file.path(tab_dir, "table1_summary_stats.tex"))
cat("Saved table1_summary_stats.tex\n")


## --------------------------------------------------------------------------
## Table 2: Main Results — Men's First-Difference
## --------------------------------------------------------------------------

cat("--- Table 2: Men's Results ---\n")

etable(models$m1_lf, models$m2_lf, models$m3_lf, models$m4_lf,
       file = file.path(tab_dir, "table2_main_results.tex"),
       title = "Men's Within-Person Change in Labor Force Participation (1940-1950)",
       label = "tab:men_main",
       extralines = list(
         "Controls" = c("No", "Yes", "Yes", "Yes"),
         "Region FE" = c("No", "No", "Yes", "Yes"),
         "Sample" = c("All", "All", "All", "Non-Movers")
       ),
       keep = "%mob_std",
       se.below = TRUE, depvar = FALSE,
       style.tex = style.tex("aer"),
       fitstat = ~ n + r2)

cat("Saved table2_main_results.tex\n")


## --------------------------------------------------------------------------
## Table 3: Wives' First-Difference (Couples Panel)
## --------------------------------------------------------------------------

cat("--- Table 3: Wives' Results ---\n")

etable(models$w1_lf, models$w2_lf, models$w3_lf, models$w4_lf,
       file = file.path(tab_dir, "table3_wives_results.tex"),
       title = "Wives' Within-Couple Change in Labor Force Participation (1940-1950)",
       label = "tab:wives_main",
       extralines = list(
         "Wife Controls" = c("No", "Yes", "Yes", "Yes"),
         "Region FE" = c("No", "No", "Yes", "Yes"),
         "Husband Controls" = c("No", "No", "Yes", "Yes")
       ),
       keep = "%mob_std",
       se.below = TRUE, depvar = FALSE,
       style.tex = style.tex("aer"),
       fitstat = ~ n + r2)

cat("Saved table3_wives_results.tex\n")


## --------------------------------------------------------------------------
## Table 4: Men's Occupation Results
## --------------------------------------------------------------------------

cat("--- Table 4: Occupation ---\n")

occ_models <- list(models$m5_occ)
occ_headers <- c("Men DOcc")
if (!is.null(models$m6_sei)) {
  occ_models[[length(occ_models) + 1]] <- models$m6_sei
  occ_headers <- c(occ_headers, "Men DSEI")
}
if (!is.null(models$w5_occ)) {
  occ_models[[length(occ_models) + 1]] <- models$w5_occ
  occ_headers <- c(occ_headers, "Wives DOcc")
}

etable(occ_models,
       file = file.path(tab_dir, "table4_occupation.tex"),
       title = "Within-Person Change in Occupational Standing (1940-1950)",
       label = "tab:occupation",
       headers = occ_headers,
       notes = "Sample restricted to individuals with valid OCCSCORE in both census years. N varies across columns due to differences in occupation reporting between the men's panel and couples panel.",
       keep = "%mob_std",
       se.below = TRUE, depvar = FALSE,
       style.tex = style.tex("aer"),
       fitstat = ~ n + r2)

cat("Saved table4_occupation.tex\n")


## --------------------------------------------------------------------------
## Table 5: Husband-Wife Dynamics
## --------------------------------------------------------------------------

cat("--- Table 5: Husband-Wife Dynamics ---\n")

hw_models <- list()
hw_headers <- c()
if (!is.null(models$hw_lf)) {
  hw_models[[length(hw_models) + 1]] <- models$hw_lf
  hw_headers <- c(hw_headers, "Wife DLF")
}
if (!is.null(models$hw_occ)) {
  hw_models[[length(hw_models) + 1]] <- models$hw_occ
  hw_headers <- c(hw_headers, "Wife DOcc")
}

if (length(hw_models) > 0) {
  etable(hw_models,
         file = file.path(tab_dir, "table5_hw_dynamics.tex"),
         title = "Husband-Wife Joint Labor Market Dynamics (Couples Panel)",
         label = "tab:hwdynamics",
         headers = hw_headers,
         se.below = TRUE, depvar = FALSE,
         style.tex = style.tex("aer"),
         fitstat = ~ n + r2)
  cat("Saved table5_hw_dynamics.tex\n")
} else {
  cat("No HW dynamics models available\n")
}


## --------------------------------------------------------------------------
## Table 6: Decomposition
## --------------------------------------------------------------------------

cat("--- Table 6: Decomposition ---\n")

decomp_tab <- data.table(
  Component = c("Aggregate Change", "Within-Person/Couple", "Compositional Residual"),
  `Women LFP` = c(
    sprintf("%.4f", decomp$aggregate$d_f_lf),
    sprintf("%.4f (%.0f%%)", decomp$within$wife_d_lf,
            100 * decomp$within$wife_d_lf / decomp$aggregate$d_f_lf),
    sprintf("%.4f (%.0f%%)", decomp$compositional$d_f_lf,
            100 * decomp$compositional$d_f_lf / decomp$aggregate$d_f_lf)
  ),
  `Men LFP` = c(
    sprintf("%.4f", decomp$aggregate$d_m_lf),
    sprintf("%.4f", decomp$within$m_d_lf),
    sprintf("%.4f", decomp$aggregate$d_m_lf - decomp$within$m_d_lf)
  )
)

tab6_tex <- kableExtra::kbl(decomp_tab, format = "latex", booktabs = TRUE,
  caption = "Within-Person vs.\\ Aggregate LFP Changes (1940--1950)",
  label = "decomposition") %>%
  kableExtra::kable_styling() %>%
  kableExtra::footnote(general = "Within-person/couple changes from ABE-linked panel (men) and household-matched couples panel (married wives). Aggregate from full-count cross-sections (all women, all men). The gap reflects both compositional turnover and population differences between the linked panels and the full cross-sections.",
                       threeparttable = TRUE)
writeLines(tab6_tex, file.path(tab_dir, "table6_decomposition.tex"))
cat("Saved table6_decomposition.tex\n")


## --------------------------------------------------------------------------
## Table 7: State-Level Cross-Validation
## --------------------------------------------------------------------------

cat("--- Table 7: State-Level ---\n")

etable(models$s1_lf, models$s2_lf,
       file = file.path(tab_dir, "table7_state_level.tex"),
       title = "State-Level Cross-Validation (Full-Count Data)",
       label = "tab:statelevel",
       keep = "%mob_std",
       se.below = TRUE, depvar = FALSE,
       style.tex = style.tex("aer"),
       fitstat = ~ n + r2)

cat("Saved table7_state_level.tex\n")


## --------------------------------------------------------------------------
## Table 8: Robustness Summary
## --------------------------------------------------------------------------

cat("--- Table 8: Robustness Summary ---\n")

rob_rows <- list()
rob_rows[[1]] <- c("Baseline (wives, region FE)",
                    sprintf("%.4f", coef(models$w3_lf)["mob_std"]))

if (!is.null(robustness$oster$delta)) {
  rob_rows[[length(rob_rows) + 1]] <- c("Oster delta (wives)", sprintf("%.2f", robustness$oster$delta))
}

rob_rows[[length(rob_rows) + 1]] <- c(
  sprintf("Randomization Inference (p-value, %d perms)", length(robustness$ri$perm_betas)),
  sprintf("%.4f", robustness$ri$p_value))

rob_rows[[length(rob_rows) + 1]] <- c("HC3 SE (state-level)", sprintf("%.4f", robustness$hc$se_hc3))

rob_rows[[length(rob_rows) + 1]] <- c(
  sprintf("Leave-One-Out Range (%d states)", length(robustness$loo$betas)),
  sprintf("[%.4f, %.4f]", min(robustness$loo$betas), max(robustness$loo$betas)))

if (!is.null(robustness$placebo_older)) {
  rob_rows[[length(rob_rows) + 1]] <- c("Placebo: Older Wives (46+)",
    sprintf("%.4f (SE %.4f)", coef(robustness$placebo_older)["mob_std"],
            sqrt(vcov(robustness$placebo_older)["mob_std", "mob_std"])))
}

if (!is.null(robustness$ancova)) {
  rob_rows[[length(rob_rows) + 1]] <- c("ANCOVA (level with lagged DV)",
    sprintf("%.4f", coef(robustness$ancova)["mob_std"]))
}

if (!is.null(robustness$trimmed)) {
  rob_rows[[length(rob_rows) + 1]] <- c("Trimmed Sample (5-95%)",
    sprintf("%.4f", coef(robustness$trimmed)["mob_std"]))
}

if (!is.null(robustness$wife_verified)) {
  wv <- robustness$wife_verified
  rob_rows[[length(rob_rows) + 1]] <- c(
    sprintf("Wife Age-Verified (%.1f%%)", wv$pct_verified),
    sprintf("%.4f (SE %.4f)", wv$beta, wv$se))
}

if (!is.null(robustness$wild_bootstrap)) {
  rob_rows[[length(rob_rows) + 1]] <- c("Wild Cluster Bootstrap p-value",
    sprintf("%.4f [%.4f, %.4f]", robustness$wild_bootstrap$p_value,
            robustness$wild_bootstrap$ci_lo, robustness$wild_bootstrap$ci_hi))
}

if (!is.null(robustness$nonmover_couples)) {
  rob_rows[[length(rob_rows) + 1]] <- c(
    sprintf("Non-Mover Couples (%.1f%%)", 100 * robustness$nonmover_couples$n / nrow(couples)),
    sprintf("%.4f (SE %.4f)", robustness$nonmover_couples$beta, robustness$nonmover_couples$se))
}

rob_tab <- data.table(
  Check = sapply(rob_rows, `[`, 1),
  Value = sapply(rob_rows, `[`, 2)
)

tab8_tex <- kableExtra::kbl(rob_tab, format = "latex", booktabs = TRUE,
  caption = "Robustness Checks Summary",
  label = "robustness") %>%
  kableExtra::kable_styling()
writeLines(tab8_tex, file.path(tab_dir, "table8_robustness.tex"))
cat("Saved table8_robustness.tex\n")


## --------------------------------------------------------------------------
## Table 9: Linkage Selection Balance (Men 18-55 Only)
## --------------------------------------------------------------------------

cat("--- Table 9: Linkage Balance ---\n")

## Linked panel stats (from panel, 14M men)
n_linked <- nrow(panel)
linked_pct_white <- 100 * mean(panel$race_cat == "White", na.rm = TRUE)
linked_pct_urban <- 100 * mean(panel$is_urban_1940, na.rm = TRUE)
linked_mean_age  <- mean(panel$age_1940, na.rm = TRUE)
linked_pct_lf    <- 100 * mean(panel$in_lf_1940, na.rm = TRUE)
linked_pct_married <- 100 * mean(panel$married_1940, na.rm = TRUE)
linked_mean_educ <- mean(panel$educ_years_1940, na.rm = TRUE)

## Full 1940 male population (18-55) from state_gender_year
sgy <- readRDS(file.path(data_dir, "state_gender_year.rds"))
males_1940 <- sgy[sgy$female == 0 & sgy$year == 1940, ]
n_full_males <- sum(males_1940$n)
full_pct_lf <- 100 * weighted.mean(males_1940$mean_lf, males_1940$n)

## State-level characteristics for full male pop from state_analysis
sa <- readRDS(file.path(data_dir, "state_analysis.rds"))
full_mean_age <- weighted.mean(sa$mean_age, sa$total_pop)
full_pct_urban <- 100 * weighted.mean(sa$pct_urban, sa$total_pop)
full_pct_married <- 100 * weighted.mean(sa$pct_married, sa$total_pop)
full_mean_educ <- weighted.mean(sa$mean_educ, sa$total_pop)

tab9_data <- data.table(
  Group = c("Full 1940 Male Pop. (18--55)", "Linked Panel (Men)"),
  N = c(format(n_full_males, big.mark = ","), format(n_linked, big.mark = ",")),
  `\\% Urban` = c(sprintf("%.1f", full_pct_urban), sprintf("%.1f", linked_pct_urban)),
  `Mean Age` = c(sprintf("%.1f", full_mean_age), sprintf("%.1f", linked_mean_age)),
  `\\% in LF` = c(sprintf("%.1f", full_pct_lf), sprintf("%.1f", linked_pct_lf)),
  `\\% Married` = c(sprintf("%.1f", full_pct_married), sprintf("%.1f", linked_pct_married)),
  `Mean Educ.` = c(sprintf("%.1f", full_mean_educ), sprintf("%.1f", linked_mean_educ))
)

tab9_tex <- kableExtra::kbl(tab9_data,
  format = "latex", booktabs = TRUE,
  caption = "Linkage Selection: Linked Panel vs.\\ Full 1940 Male Population (Ages 18--55)",
  label = "linkage",
  col.names = c("Sample", "N", "\\% Urban", "Mean Age", "\\% in LF",
                "\\% Married", "Mean Educ."),
  escape = FALSE) %>%
  kableExtra::kable_styling() %>%
  kableExtra::footnote(
    general = "Linked panel: men matched via ABE exact conservative algorithm across 1940--1950 full-count censuses (Abramitzky, Boustan, and Eriksson 2025). Full male population from IPUMS 1940 full count, restricted to men aged 18--55. State-level characteristics are population-weighted means from the full 1940 cross-section. Linkage rate: 38.4\\%.",
    threeparttable = TRUE, escape = FALSE)
writeLines(tab9_tex, file.path(tab_dir, "table9_linkage_balance.tex"))
cat("Saved table9_linkage_balance.tex\n")


cat("\n=== All tables saved to tables/ ===\n")
