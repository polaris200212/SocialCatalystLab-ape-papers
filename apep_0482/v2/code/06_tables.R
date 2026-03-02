## ============================================================
## 06_tables.R — All table generation (v2)
## Summary stats, election-cohort FS, main results with q-values,
## levels + extensive margins, robustness, heterogeneity
## ============================================================

source("00_packages.R")

data_dir <- "../data"
tab_dir <- "../tables"
dir.create(tab_dir, showWarnings = FALSE)

panel <- fread(file.path(data_dir, "analysis_panel.csv"))
eterm <- fread(file.path(data_dir, "election_term_panel.csv"))

## ----------------------------------------------------------
## Descriptive label map
## ----------------------------------------------------------

var_label_map <- c(
  share_320 = "General Administration",
  share_321 = "Primary School Facilities",
  share_322 = "Secondary Education",
  share_323 = "Education Promotion",
  share_324 = "Non-Regulated Education",
  share_325 = "University Education",
  share_326 = "Complementary Services",
  share_327 = "Special Education",
  edu_share_total = "Educ. Share of Total",
  security_pc_placebo = "Security Spending p.c.",
  edu_pc_320 = "General Admin. (EUR p.c.)",
  edu_pc_321 = "Primary School (EUR p.c.)",
  edu_pc_322 = "Secondary (EUR p.c.)",
  edu_pc_323 = "Educ. Promotion (EUR p.c.)",
  edu_pc_324 = "Non-Regulated (EUR p.c.)",
  edu_pc_326 = "Complementary (EUR p.c.)",
  edu_pc_total = "Total Educ. (EUR p.c.)",
  edu_pc_32 = "Total Education (EUR p.c.)",
  edu_pc_325 = "University Educ. (EUR p.c.)",
  edu_pc_327 = "Special Educ. (EUR p.c.)",
  has_320 = "Any General Admin.",
  has_321 = "Any Primary School",
  has_322 = "Any Secondary",
  has_323 = "Any Educ. Promotion",
  has_324 = "Any Non-Regulated",
  has_325 = "Any University Educ.",
  has_326 = "Any Complementary",
  has_327 = "Any Special Educ.",
  has_32 = "Any Education Spending"
)

label_var <- function(v) {
  lbl <- var_label_map[v]
  ifelse(is.na(lbl), v, lbl)
}

## ----------------------------------------------------------
## Table 1: Summary Statistics
## ----------------------------------------------------------

cat("Generating Table 1: Summary Statistics\n")

near_5k <- eterm[pop_elec > 2000 & pop_elec < 8000]
share_cols_display <- grep("^share_3[2-9][0-9]", names(near_5k), value = TRUE)

stats_list <- list()
for (var in c("pop_elec", "female_share", "edu_pc", "spending_pc",
              "edu_share_total", "security_pc", "social_pc",
              share_cols_display)) {
  if (var %in% names(near_5k)) {
    x <- near_5k[[var]]
    x <- x[!is.na(x) & !is.nan(x) & is.finite(x)]
    if (length(x) > 0) {
      stats_list[[var]] <- data.table(
        Variable = var,
        N = length(x),
        Mean = round(mean(x), 3),
        SD = round(sd(x), 3),
        P10 = round(quantile(x, 0.10), 3),
        Median = round(median(x), 3),
        P90 = round(quantile(x, 0.90), 3)
      )
    }
  }
}

if (length(stats_list) > 0) {
  tab1 <- rbindlist(stats_list)

  name_map <- c(
    pop_elec = "Population (Election Year)",
    female_share = "Female Councillor Share",
    edu_pc = "Education Spending p.c. (EUR)",
    spending_pc = "Total Spending p.c. (EUR)",
    edu_share_total = "Education Share of Total",
    security_pc = "Security Spending p.c. (EUR)",
    social_pc = "Social Spending p.c. (EUR)"
  )

  for (sc in share_cols_display) {
    name_map[sc] <- label_var(sc)
  }

  tab1[, Variable := ifelse(Variable %in% names(name_map),
                            name_map[Variable], Variable)]

  kbl <- kbl(tab1, format = "latex", booktabs = TRUE,
             caption = "\\label{tab:summary}Summary Statistics: Municipalities Near 5,000 Threshold (Election-Term Level)",
             align = c("l", rep("r", 6))) %>%
    kable_styling(latex_options = c("hold_position"))

  kbl_text <- as.character(kbl)
  kbl_text <- gsub("(\\\\begin\\{table\\}\\[!h\\])",
                   "\\1\n\\\\centering\n\\\\small", kbl_text)

  writeLines(kbl_text, file.path(tab_dir, "tab1_summary.tex"))
  cat("  Saved tab1_summary.tex\n")
}

## ----------------------------------------------------------
## Table 2: First Stage by Election Cohort (KEY NEW TABLE)
## ----------------------------------------------------------

cat("Generating Table 2: First Stage by Election Cohort\n")

if (file.exists(file.path(data_dir, "fs_by_election.rds"))) {
  fs_by <- readRDS(file.path(data_dir, "fs_by_election.rds"))

  if (length(fs_by) > 0) {
    fs_dt <- rbindlist(fs_by)
    fs_dt[, Stars := fcase(
      pv < 0.01, "***",
      pv < 0.05, "**",
      pv < 0.10, "*",
      default = ""
    )]

    kbl2 <- kbl(fs_dt[, .(election_year, round(est, 4), round(se, 4),
                            round(pv, 4), Stars, round(bw), n_left, n_right)],
                col.names = c("Election", "Estimate", "SE", "p-value", "",
                              "Bandwidth", "N (left)", "N (right)"),
                format = "latex", booktabs = TRUE,
                caption = "\\label{tab:fs_evolution}First Stage by Election Cohort: Effect of Gender Quota on Female Councillor Share at 5,000 Threshold") %>%
      kable_styling(latex_options = c("hold_position"))
    writeLines(kbl2, file.path(tab_dir, "tab2_fs_evolution.tex"))
    cat("  Saved tab2_fs_evolution.tex\n")
  }
}

## ----------------------------------------------------------
## Table 3: Pooled First Stage (Election-Term vs Averaged)
## ----------------------------------------------------------

cat("Generating Table 3: First Stage Comparison\n")

fs_rows <- list()

if (file.exists(file.path(data_dir, "fs_et_5k.rds"))) {
  fs_et <- readRDS(file.path(data_dir, "fs_et_5k.rds"))
  fs_rows[["Election-term (5,000)"]] <- data.table(
    Specification = "Election-year population",
    Cutoff = "5,000",
    Estimate = round(fs_et$coef[1], 4),
    SE = round(fs_et$se[1], 4),
    `p-value` = round(fs_et$pv[1], 4),
    Bandwidth = round(fs_et$bws[1,1]),
    `N (left)` = fs_et$N_h[1],
    `N (right)` = fs_et$N_h[2]
  )
}

if (file.exists(file.path(data_dir, "fs_5k.rds"))) {
  fs_avg <- readRDS(file.path(data_dir, "fs_5k.rds"))
  fs_rows[["Averaged (5,000)"]] <- data.table(
    Specification = "Averaged population",
    Cutoff = "5,000",
    Estimate = round(fs_avg$coef[1], 4),
    SE = round(fs_avg$se[1], 4),
    `p-value` = round(fs_avg$pv[1], 4),
    Bandwidth = round(fs_avg$bws[1,1]),
    `N (left)` = fs_avg$N_h[1],
    `N (right)` = fs_avg$N_h[2]
  )
}

if (file.exists(file.path(data_dir, "fs_et_3k.rds"))) {
  fs_et3 <- readRDS(file.path(data_dir, "fs_et_3k.rds"))
  fs_rows[["Election-term (3,000)"]] <- data.table(
    Specification = "Election-year population",
    Cutoff = "3,000",
    Estimate = round(fs_et3$coef[1], 4),
    SE = round(fs_et3$se[1], 4),
    `p-value` = round(fs_et3$pv[1], 4),
    Bandwidth = round(fs_et3$bws[1,1]),
    `N (left)` = fs_et3$N_h[1],
    `N (right)` = fs_et3$N_h[2]
  )
}

if (file.exists(file.path(data_dir, "fs_3k.rds"))) {
  fs_avg3 <- readRDS(file.path(data_dir, "fs_3k.rds"))
  fs_rows[["Averaged (3,000)"]] <- data.table(
    Specification = "Averaged population",
    Cutoff = "3,000",
    Estimate = round(fs_avg3$coef[1], 4),
    SE = round(fs_avg3$se[1], 4),
    `p-value` = round(fs_avg3$pv[1], 4),
    Bandwidth = round(fs_avg3$bws[1,1]),
    `N (left)` = fs_avg3$N_h[1],
    `N (right)` = fs_avg3$N_h[2]
  )
}

if (length(fs_rows) > 0) {
  tab3 <- rbindlist(fs_rows)
  kbl3 <- kbl(tab3, format = "latex", booktabs = TRUE,
              caption = "\\label{tab:first_stage}First Stage: Election-Year vs.\\ Averaged Population as Running Variable") %>%
    kable_styling(latex_options = c("hold_position", "scale_down"))
  writeLines(kbl3, file.path(tab_dir, "tab3_first_stage.tex"))
  cat("  Saved tab3_first_stage.tex\n")
}

## ----------------------------------------------------------
## Table 4: McCrary Density Tests
## ----------------------------------------------------------

cat("Generating Table 4: Density Tests\n")

density_rows <- list()
if (file.exists(file.path(data_dir, "density_5k.rds"))) {
  d5 <- readRDS(file.path(data_dir, "density_5k.rds"))
  density_rows[["5,000"]] <- data.table(
    Cutoff = "5,000",
    `T-statistic` = round(d5$test$t_jk, 3),
    `p-value` = round(d5$test$p_jk, 4)
  )
}
if (file.exists(file.path(data_dir, "density_3k.rds"))) {
  d3 <- readRDS(file.path(data_dir, "density_3k.rds"))
  density_rows[["3,000"]] <- data.table(
    Cutoff = "3,000",
    `T-statistic` = round(d3$test$t_jk, 3),
    `p-value` = round(d3$test$p_jk, 4)
  )
}
if (length(density_rows) > 0) {
  tab4 <- rbindlist(density_rows)
  kbl4 <- kbl(tab4, format = "latex", booktabs = TRUE,
              caption = "\\label{tab:density}McCrary Density Tests at Population Thresholds (Election-Year)") %>%
    kable_styling(latex_options = c("hold_position"))
  writeLines(kbl4, file.path(tab_dir, "tab4_density.tex"))
  cat("  Saved tab4_density.tex\n")
}

## ----------------------------------------------------------
## Table 5: Main RDD Results — Within-Education Shares
##          With BH-adjusted q-values
## ----------------------------------------------------------

cat("Generating Table 5: Main Results (Election-Term)\n")

main_rows <- list()

# Load BH q-values
bh_5k <- NULL
if (file.exists(file.path(data_dir, "bh_qvalues_5k.rds"))) {
  bh_5k <- readRDS(file.path(data_dir, "bh_qvalues_5k.rds"))
}

if (file.exists(file.path(data_dir, "results_et_5k.rds"))) {
  results_et_5k <- readRDS(file.path(data_dir, "results_et_5k.rds"))

  for (nm in names(results_et_5k)) {
    if (nm == "share_32") next
    if (nm == "security_pc_placebo") next  # Placebo: reported in Table 9
    rd <- results_et_5k[[nm]]
    if (!is.null(rd)) {
      qval <- NA_real_
      if (!is.null(bh_5k) && nm %in% bh_5k$variable) {
        qval <- bh_5k[variable == nm, q_value]
      }
      main_rows[[paste("5k", nm)]] <- data.table(
        Cutoff = "5,000",
        Variable = label_var(nm),
        Estimate = round(rd$coef[1], 4),
        SE = round(rd$se[1], 4),
        `p-value` = round(rd$pv[1], 4),
        `q-value` = round(qval, 4),
        Bandwidth = round(rd$bws[1,1]),
        `N (left)` = rd$N_h[1],
        `N (right)` = rd$N_h[2]
      )
    }
  }
}

if (file.exists(file.path(data_dir, "results_et_3k.rds"))) {
  results_et_3k <- readRDS(file.path(data_dir, "results_et_3k.rds"))

  for (nm in names(results_et_3k)) {
    if (nm == "share_32") next
    rd <- results_et_3k[[nm]]
    if (!is.null(rd)) {
      main_rows[[paste("3k", nm)]] <- data.table(
        Cutoff = "3,000",
        Variable = label_var(nm),
        Estimate = round(rd$coef[1], 4),
        SE = round(rd$se[1], 4),
        `p-value` = round(rd$pv[1], 4),
        `q-value` = NA_real_,
        Bandwidth = round(rd$bws[1,1]),
        `N (left)` = rd$N_h[1],
        `N (right)` = rd$N_h[2]
      )
    }
  }
}

if (length(main_rows) > 0) {
  tab5 <- rbindlist(main_rows)

  tab5[, Stars := fcase(
    `p-value` < 0.01, "***",
    `p-value` < 0.05, "**",
    `p-value` < 0.10, "*",
    default = ""
  )]

  # Panel A: 5,000 cutoff with q-values
  tab5a <- tab5[Cutoff == "5,000"]
  tab5a[, q_display := fifelse(is.na(`q-value`),
                                formatC(NA_real_, format = "f", digits = 4),
                                formatC(round(`q-value`, 4), format = "f", digits = 4))]

  kbl5a <- kbl(tab5a[, .(Variable, Estimate, SE, `p-value`, q_display,
                          Stars, Bandwidth, `N (left)`, `N (right)`)],
               col.names = c("Variable", "Estimate", "SE",
                             "p-value", "q-value", "", "Bandwidth",
                             "N (left)", "N (right)"),
               format = "latex", booktabs = TRUE,
               caption = "\\label{tab:main_results}Main RDD Results: Within-Education Budget Shares at 5,000 Threshold (Election-Term)") %>%
    kable_styling(latex_options = c("hold_position", "scale_down")) %>%
    footnote(general = "BH q-values computed over the family of within-education share outcomes (programs 320--327) plus education share of total (9 outcomes). Triangular kernel, MSE-optimal bandwidth.",
             general_title = "Notes:", threeparttable = TRUE)
  writeLines(kbl5a, file.path(tab_dir, "tab5_main_results.tex"))
  cat("  Saved tab5_main_results.tex\n")

  # Panel B: 3,000 cutoff without q-values (separate table)
  tab5b <- tab5[Cutoff == "3,000"]
  if (nrow(tab5b) > 0) {
    kbl5b <- kbl(tab5b[, .(Variable, Estimate, SE, `p-value`,
                            Stars, Bandwidth, `N (left)`, `N (right)`)],
                 col.names = c("Variable", "Estimate", "SE",
                               "p-value", "", "Bandwidth",
                               "N (left)", "N (right)"),
                 format = "latex", booktabs = TRUE,
                 caption = "\\label{tab:main_3k}RDD Results: Within-Education Budget Shares at 3,000 Threshold (Post-2011 Elections)") %>%
      kable_styling(latex_options = c("hold_position", "scale_down")) %>%
      footnote(general = "3,000-inhabitant threshold active from 2011 onward. BH correction not applied (separate design with different first stage).",
               general_title = "Notes:", threeparttable = TRUE)
    writeLines(kbl5b, file.path(tab_dir, "tab5b_main_3k.tex"))
    cat("  Saved tab5b_main_3k.tex\n")
  }
}

## ----------------------------------------------------------
## Table 6: Levels + Extensive Margins (Appendix)
## ----------------------------------------------------------

cat("Generating Table 6: Levels and Extensive Margins\n")

appendix_rows <- list()

# Levels
if (file.exists(file.path(data_dir, "results_levels_5k.rds"))) {
  levels <- readRDS(file.path(data_dir, "results_levels_5k.rds"))
  for (nm in names(levels)) {
    rd <- levels[[nm]]
    if (!is.null(rd)) {
      appendix_rows[[paste("level", nm)]] <- data.table(
        Outcome = "Level (EUR p.c.)",
        Variable = label_var(nm),
        Estimate = round(rd$coef[1], 2),
        SE = round(rd$se[1], 2),
        `p-value` = round(rd$pv[1], 4),
        Bandwidth = round(rd$bws[1,1]),
        N = rd$N_h[1] + rd$N_h[2]
      )
    }
  }
}

# Extensive margins
if (file.exists(file.path(data_dir, "results_extensive_5k.rds"))) {
  extensive <- readRDS(file.path(data_dir, "results_extensive_5k.rds"))
  for (nm in names(extensive)) {
    rd <- extensive[[nm]]
    if (!is.null(rd)) {
      appendix_rows[[paste("ext", nm)]] <- data.table(
        Outcome = "Extensive Margin",
        Variable = label_var(nm),
        Estimate = round(rd$coef[1], 4),
        SE = round(rd$se[1], 4),
        `p-value` = round(rd$pv[1], 4),
        Bandwidth = round(rd$bws[1,1]),
        N = rd$N_h[1] + rd$N_h[2]
      )
    }
  }
}

if (length(appendix_rows) > 0) {
  tab6 <- rbindlist(appendix_rows)
  tab6[, Stars := fcase(
    `p-value` < 0.01, "***",
    `p-value` < 0.05, "**",
    `p-value` < 0.10, "*",
    default = ""
  )]

  # Count rows per panel for pack_rows
  n_levels <- sum(tab6$Outcome == "Level (EUR p.c.)")
  n_ext <- sum(tab6$Outcome == "Extensive Margin")

  kbl6 <- kbl(tab6[, .(Variable, Estimate, SE, `p-value`, Stars, Bandwidth, N)],
              format = "latex", booktabs = TRUE,
              caption = "\\label{tab:levels_extensive}RDD Results: Levels (EUR per Capita) and Extensive Margins at 5,000 Threshold") %>%
    kable_styling(latex_options = c("hold_position", "scale_down")) %>%
    pack_rows("Panel A: Levels (EUR per Capita)", 1, n_levels, bold = TRUE) %>%
    pack_rows("Panel B: Extensive Margin (Any Positive Spending)", n_levels + 1, n_levels + n_ext, bold = TRUE) %>%
    footnote(general = "Panel A estimates the discontinuity in EUR per capita spending. Panel B estimates the discontinuity in the probability of any positive spending in each subcategory.",
             general_title = "Notes:", threeparttable = TRUE)
  writeLines(kbl6, file.path(tab_dir, "tab6_levels_extensive.tex"))
  cat("  Saved tab6_levels_extensive.tex\n")
}

## ----------------------------------------------------------
## Table 7: Robustness — Donut RDD
## ----------------------------------------------------------

cat("Generating Table 7: Donut RDD\n")

if (file.exists(file.path(data_dir, "donut_results.rds"))) {
  donut <- readRDS(file.path(data_dir, "donut_results.rds"))
  if (length(donut) > 0) {
    donut_dt <- rbindlist(donut)
    donut_dt[, Stars := fcase(
      pv < 0.01, "***",
      pv < 0.05, "**",
      pv < 0.10, "*",
      default = ""
    )]
    donut_dt[, est := round(est, 4)]
    donut_dt[, se := round(se, 4)]
    donut_dt[, pv := round(pv, 4)]
    donut_dt[, variable := label_var(variable)]

    kbl7 <- kbl(donut_dt[, .(radius, variable, est, se, pv, Stars,
                              round(bw), n_left, n_right)],
                col.names = c("Donut", "Variable", "Estimate", "SE",
                              "p-value", "", "Bandwidth", "N (left)", "N (right)"),
                format = "latex", booktabs = TRUE,
                caption = "\\label{tab:donut}Robustness: Donut RDD Estimates") %>%
      kable_styling(latex_options = c("hold_position", "scale_down"))
    writeLines(kbl7, file.path(tab_dir, "tab7_donut.tex"))
    cat("  Saved tab7_donut.tex\n")
  }
}

## ----------------------------------------------------------
## Table 8: Robustness — Bandwidth Sensitivity
## ----------------------------------------------------------

cat("Generating Table 8: Bandwidth Sensitivity\n")

if (file.exists(file.path(data_dir, "bw_results.rds"))) {
  bw <- readRDS(file.path(data_dir, "bw_results.rds"))
  if (length(bw) > 0) {
    bw_dt <- rbindlist(bw)
    bw_dt[, est := round(est, 4)]
    bw_dt[, se := round(se, 4)]
    bw_dt[, pv := round(pv, 4)]
    bw_dt[, bw := round(bw)]
    bw_dt[, Stars := fcase(
      pv < 0.01, "***",
      pv < 0.05, "**",
      pv < 0.10, "*",
      default = ""
    )]

    kbl8 <- kbl(bw_dt[, .(multiplier, bw, est, se, pv, Stars)],
                col.names = c("BW Multiplier", "Bandwidth", "Estimate", "SE",
                              "p-value", ""),
                format = "latex", booktabs = TRUE,
                caption = "\\label{tab:bandwidth}Robustness: Bandwidth Sensitivity") %>%
      kable_styling(latex_options = c("hold_position"))
    writeLines(kbl8, file.path(tab_dir, "tab8_bandwidth.tex"))
    cat("  Saved tab8_bandwidth.tex\n")
  }
}

## ----------------------------------------------------------
## Table 9: Placebo Tests
## ----------------------------------------------------------

cat("Generating Table 9: Placebo Tests\n")

placebo_rows <- list()

if (file.exists(file.path(data_dir, "placebo_results.rds"))) {
  plac <- readRDS(file.path(data_dir, "placebo_results.rds"))
  for (nm in names(plac)) {
    r <- plac[[nm]]
    if (r$variable == "share_32") next
    placebo_rows[[paste("pre", nm)]] <- data.table(
      Test = "Pre-treatment (2010)",
      Variable = label_var(r$variable),
      Estimate = round(r$est, 4),
      SE = round(r$se, 4),
      `p-value` = round(r$pv, 4)
    )
  }
}

if (file.exists(file.path(data_dir, "placebo_cutoff_results.rds"))) {
  plac_cut <- readRDS(file.path(data_dir, "placebo_cutoff_results.rds"))
  for (nm in names(plac_cut)) {
    r <- plac_cut[[nm]]
    if (r$variable == "share_32") next
    placebo_rows[[paste("cut", nm)]] <- data.table(
      Test = paste0("Placebo cutoff: ", format(r$cutoff, big.mark = ",")),
      Variable = label_var(r$variable),
      Estimate = round(r$est, 4),
      SE = round(r$se, 4),
      `p-value` = round(r$pv, 4)
    )
  }
}

if (length(placebo_rows) > 0) {
  tab9 <- rbindlist(placebo_rows)
  tab9[, Stars := fcase(
    `p-value` < 0.01, "***",
    `p-value` < 0.05, "**",
    `p-value` < 0.10, "*",
    default = ""
  )]

  kbl9 <- kbl(tab9[, .(Test, Variable, Estimate, SE, `p-value`, Stars)],
              format = "latex", booktabs = TRUE,
              caption = "\\label{tab:placebo}Placebo Tests: Pre-Treatment and False Cutoffs") %>%
    kable_styling(latex_options = c("hold_position"))
  writeLines(kbl9, file.path(tab_dir, "tab9_placebo.tex"))
  cat("  Saved tab9_placebo.tex\n")
}

## ----------------------------------------------------------
## Table 10: Covariate Balance
## ----------------------------------------------------------

cat("Generating Table 10: Covariate Balance\n")

pre_et <- eterm[election_year == 2007 & pop_elec > 2000 & pop_elec < 8000]
balance_vars <- c("spending_pc", "edu_pc", "security_pc", "social_pc")

bal_rows <- list()
for (var in balance_vars) {
  if (var %in% names(pre_et)) {
    valid <- !is.na(pre_et[[var]]) & is.finite(pre_et[[var]])
    if (sum(valid) > 50) {
      bal <- tryCatch(
        rdrobust(y = pre_et[[var]][valid],
                 x = pre_et$pop_elec[valid],
                 c = 5000,
                 kernel = "triangular",
                 p = 1,
                 bwselect = "mserd"),
        error = function(e) NULL
      )
      if (!is.null(bal)) {
        bal_rows[[var]] <- data.table(
          Variable = var,
          Estimate = round(bal$coef[1], 2),
          SE = round(bal$se[1], 2),
          `p-value` = round(bal$pv[1], 3),
          Bandwidth = round(bal$bws[1,1]),
          `N (left)` = bal$N_h[1],
          `N (right)` = bal$N_h[2]
        )
      }
    }
  }
}

if (length(bal_rows) > 0) {
  tab10 <- rbindlist(bal_rows)

  name_map_bal <- c(
    spending_pc = "Total Spending p.c. (EUR)",
    edu_pc = "Education Spending p.c. (EUR)",
    security_pc = "Security Spending p.c. (EUR)",
    social_pc = "Social Spending p.c. (EUR)"
  )
  tab10[, Variable := name_map_bal[Variable]]

  kbl10 <- kbl(tab10, format = "latex", booktabs = TRUE,
              caption = "\\label{tab:balance}Continuity of Spending at 5,000 Threshold (Earliest Available Data, 2010)") %>%
    kable_styling(latex_options = c("hold_position", "scale_down")) %>%
    footnote(general = "RDD estimates of spending discontinuities at the 5,000 threshold using the earliest available fiscal year (2010). These test for pre-existing spending differences rather than covariate balance, since 2010 data are contemporaneous with the first observed quota-eligible council (2007 election term).",
             general_title = "Notes:", threeparttable = TRUE)
  writeLines(kbl10, file.path(tab_dir, "tab10_balance.tex"))
  cat("  Saved tab10_balance.tex\n")
}

## ----------------------------------------------------------
## Table 11: LRSAL Heterogeneity (Pre/Post 2013)
##           With BH-adjusted q-values for pre-period
## ----------------------------------------------------------

cat("Generating Table 11: Pre/Post-LRSAL Heterogeneity\n")

if (file.exists(file.path(data_dir, "lrsal_results.rds"))) {
  lrsal <- readRDS(file.path(data_dir, "lrsal_results.rds"))

  # Load pre- and post-LRSAL q-values
  bh_pre <- NULL
  bh_post <- NULL
  if (file.exists(file.path(data_dir, "bh_qvalues_pre_lrsal.rds"))) {
    bh_pre <- readRDS(file.path(data_dir, "bh_qvalues_pre_lrsal.rds"))
  }
  if (file.exists(file.path(data_dir, "bh_qvalues_post_lrsal.rds"))) {
    bh_post <- readRDS(file.path(data_dir, "bh_qvalues_post_lrsal.rds"))
  }

  if (length(lrsal) > 0) {
    lrsal_dt <- rbindlist(lrsal)
    lrsal_dt[, Stars := fcase(
      pv < 0.01, "***",
      pv < 0.05, "**",
      pv < 0.10, "*",
      default = ""
    )]
    lrsal_dt[, est := round(est, 4)]
    lrsal_dt[, se := round(se, 4)]
    lrsal_dt[, pv := round(pv, 4)]
    lrsal_dt[, bw := round(bw)]

    # Add q-values for pre- and post-LRSAL
    lrsal_dt[, qval := NA_real_]
    if (!is.null(bh_pre)) {
      for (i in seq_len(nrow(lrsal_dt))) {
        if (lrsal_dt$period[i] == "pre_lrsal" &&
            lrsal_dt$variable[i] %in% bh_pre$variable) {
          lrsal_dt[i, qval := bh_pre[variable == lrsal_dt$variable[i], q_value]]
        }
      }
    }
    if (!is.null(bh_post)) {
      for (i in seq_len(nrow(lrsal_dt))) {
        if (lrsal_dt$period[i] == "post_lrsal" &&
            lrsal_dt$variable[i] %in% bh_post$variable) {
          lrsal_dt[i, qval := bh_post[variable == lrsal_dt$variable[i], q_value]]
        }
      }
    }

    lrsal_dt[, variable := label_var(variable)]
    lrsal_dt[, Period := fifelse(period == "pre_lrsal",
                                  "Pre-LRSAL (2007--2011)",
                                  "Post-LRSAL (2015--2023)")]

    # Format q-values for display
    lrsal_dt[, q_display := fifelse(is.na(qval), "---",
                                     formatC(round(qval, 4), format = "f", digits = 4))]

    # Count rows per period for pack_rows
    n_pre <- sum(lrsal_dt$Period == "Pre-LRSAL (2007--2011)")
    n_post <- sum(lrsal_dt$Period == "Post-LRSAL (2015--2023)")

    kbl11 <- kbl(lrsal_dt[, .(variable, est, se, pv, q_display,
                               Stars, bw, n_left, n_right)],
                col.names = c("Variable", "Estimate", "SE",
                              "p-value", "q-value", "", "Bandwidth",
                              "N (left)", "N (right)"),
                format = "latex", booktabs = TRUE,
                caption = "\\label{tab:lrsal}Temporal Heterogeneity: Pre- and Post-LRSAL RDD Results at 5,000 Threshold") %>%
      kable_styling(latex_options = c("hold_position", "scale_down")) %>%
      pack_rows("Panel A: Pre-LRSAL (2007--2011 Election Terms)", 1, n_pre, bold = TRUE) %>%
      pack_rows("Panel B: Post-LRSAL (2015--2023 Election Terms)", n_pre + 1, n_pre + n_post, bold = TRUE) %>%
      footnote(general = "BH q-values computed separately for pre- and post-LRSAL families. Each family includes the outcomes reported in that panel.",
               general_title = "Notes:", threeparttable = TRUE)
    writeLines(kbl11, file.path(tab_dir, "tab11_lrsal.tex"))
    cat("  Saved tab11_lrsal.tex\n")
  }
}

## ----------------------------------------------------------
## Table 12: MDE (Minimum Detectable Effects)
## ----------------------------------------------------------

cat("Generating Table 12: Minimum Detectable Effects\n")

if (file.exists(file.path(data_dir, "mde_results.rds"))) {
  mde <- readRDS(file.path(data_dir, "mde_results.rds"))

  if (length(mde) > 0) {
    mde_dt <- rbindlist(mde)
    mde_dt[, variable := label_var(variable)]
    mde_dt[, se := round(se, 4)]
    mde_dt[, mde := round(mde, 4)]

    kbl12 <- kbl(mde_dt[, .(variable, se, mde)],
                col.names = c("Variable", "SE", "MDE (80% power)"),
                format = "latex", booktabs = TRUE,
                caption = "\\label{tab:mde}Minimum Detectable Effects at 5,000 Threshold (Election-Term)") %>%
      kable_styling(latex_options = c("hold_position"))
    writeLines(kbl12, file.path(tab_dir, "tab12_mde.tex"))
    cat("  Saved tab12_mde.tex\n")
  }
}

## ----------------------------------------------------------
## Table 13: 2011-Only Pre-LRSAL Results (Appendix)
## ----------------------------------------------------------

cat("Generating Table 13: 2011-Only Pre-LRSAL Results\n")

if (file.exists(file.path(data_dir, "results_2011_only.rds"))) {
  res_2011 <- readRDS(file.path(data_dir, "results_2011_only.rds"))

  # Load BH q-values for 2011
  bh_2011 <- NULL
  if (file.exists(file.path(data_dir, "bh_qvalues_2011_only.rds"))) {
    bh_2011 <- readRDS(file.path(data_dir, "bh_qvalues_2011_only.rds"))
  }

  if (length(res_2011) > 0) {
    rows_2011 <- list()
    for (nm in names(res_2011)) {
      r <- res_2011[[nm]]
      qval <- NA_real_
      if (!is.null(bh_2011) && nm %in% bh_2011$variable) {
        qval <- bh_2011[variable == nm, q_value]
      }
      rows_2011[[nm]] <- data.table(
        Variable = label_var(nm),
        Estimate = round(r$est, 4),
        SE = round(r$se, 4),
        `p-value` = round(r$pv, 4),
        `q-value` = round(qval, 4),
        Bandwidth = round(r$bw),
        `N (left)` = r$n_left,
        `N (right)` = r$n_right
      )
    }
    tab13 <- rbindlist(rows_2011)
    tab13[, Stars := fcase(
      `p-value` < 0.01, "***",
      `p-value` < 0.05, "**",
      `p-value` < 0.10, "*",
      default = ""
    )]

    kbl13 <- kbl(tab13[, .(Variable, Estimate, SE, `p-value`, `q-value`,
                             Stars, Bandwidth, `N (left)`, `N (right)`)],
                  col.names = c("Variable", "Estimate", "SE",
                                "p-value", "q-value", "", "Bandwidth",
                                "N (left)", "N (right)"),
                  format = "latex", booktabs = TRUE,
                  caption = "\\label{tab:results_2011}Pre-LRSAL Results: 2011 Election Cohort Only (5,000 Threshold)") %>%
      kable_styling(latex_options = c("hold_position", "scale_down")) %>%
      footnote(general = "Restricted to the 2011 election cohort (budget years 2011--2014), where the running variable (2011 Padr\\'{o}n) exactly matches the assignment rule. Each municipality contributes one observation. BH q-values computed over reported outcomes.",
               general_title = "Notes:", threeparttable = TRUE, escape = FALSE)
    writeLines(kbl13, file.path(tab_dir, "tab13_2011_only.tex"))
    cat("  Saved tab13_2011_only.tex\n")
  }
}

cat("\n=== TABLES COMPLETE ===\n")
