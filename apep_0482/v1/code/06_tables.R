## ============================================================
## 06_tables.R — All table generation
## Summary statistics, main results, robustness, heterogeneity
## ============================================================

source("00_packages.R")

data_dir <- "../data"
tab_dir <- "../tables"
dir.create(tab_dir, showWarnings = FALSE)

panel <- fread(file.path(data_dir, "analysis_panel.csv"))

## ----------------------------------------------------------
## Descriptive label map (used throughout)
## ----------------------------------------------------------

# Map internal variable names to descriptive labels
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
  security_pc_placebo = "Security Spending p.c."
)

label_var <- function(v) {
  lbl <- var_label_map[v]
  ifelse(is.na(lbl), v, lbl)
}

## ----------------------------------------------------------
## Table 1: Summary Statistics
## ----------------------------------------------------------

cat("Generating Table 1: Summary Statistics\n")

# Municipalities near the 5,000 cutoff
near_5k <- panel[pop > 2000 & pop < 8000 & year >= 2010]

# Exclude generic share_32 (2-digit aggregate code) — see Data Appendix
share_cols_display <- grep("^share_3[2-9][0-9]", names(near_5k), value = TRUE)

# Compute summary stats
stats_list <- list()
for (var in c("pop", "female_share", "edu_pc", "spending_pc",
              "edu_share_total", "security_pc", "social_pc",
              share_cols_display)) {
  if (var %in% names(near_5k)) {
    x <- near_5k[[var]]
    x <- x[!is.na(x) & !is.nan(x)]
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

  # Pretty variable names
  name_map <- c(
    pop = "Population",
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

  # Export LaTeX
  kbl <- kbl(tab1, format = "latex", booktabs = TRUE,
             caption = "\\label{tab:summary}Summary Statistics: Municipalities Near 5,000 Threshold",
             align = c("l", rep("r", 6))) %>%
    kable_styling(latex_options = c("hold_position"))

  # Add adjustbox wrapper for width
  kbl_text <- as.character(kbl)
  kbl_text <- gsub("(\\\\begin\\{table\\}\\[!h\\])",
                   "\\1\n\\\\centering\n\\\\small", kbl_text)

  writeLines(kbl_text, file.path(tab_dir, "tab1_summary.tex"))
  cat("  Saved tab1_summary.tex\n")
}

## ----------------------------------------------------------
## Table 2: First Stage Results
## ----------------------------------------------------------

cat("Generating Table 2: First Stage\n")

fs_rows <- list()

if (file.exists(file.path(data_dir, "fs_5k.rds"))) {
  fs_5k <- readRDS(file.path(data_dir, "fs_5k.rds"))
  fs_rows[["5,000"]] <- data.table(
    Cutoff = "5,000",
    Estimate = round(fs_5k$coef[1], 4),
    SE = round(fs_5k$se[1], 4),
    `p-value` = round(fs_5k$pv[1], 4),
    Bandwidth = round(fs_5k$bws[1,1]),
    `N (left)` = fs_5k$N_h[1],
    `N (right)` = fs_5k$N_h[2]
  )
}

if (file.exists(file.path(data_dir, "fs_3k.rds"))) {
  fs_3k <- readRDS(file.path(data_dir, "fs_3k.rds"))
  fs_rows[["3,000"]] <- data.table(
    Cutoff = "3,000",
    Estimate = round(fs_3k$coef[1], 4),
    SE = round(fs_3k$se[1], 4),
    `p-value` = round(fs_3k$pv[1], 4),
    Bandwidth = round(fs_3k$bws[1,1]),
    `N (left)` = fs_3k$N_h[1],
    `N (right)` = fs_3k$N_h[2]
  )
}

if (length(fs_rows) > 0) {
  tab2 <- rbindlist(fs_rows)
  kbl2 <- kbl(tab2, format = "latex", booktabs = TRUE,
              caption = "\\label{tab:first_stage}First Stage: Effect of Gender Quota on Female Councillor Share") %>%
    kable_styling(latex_options = c("hold_position"))
  writeLines(kbl2, file.path(tab_dir, "tab2_first_stage.tex"))
  cat("  Saved tab2_first_stage.tex\n")
}

## ----------------------------------------------------------
## Table 3: McCrary Density Tests
## ----------------------------------------------------------

cat("Generating Table 3: Density Tests\n")

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
  tab3 <- rbindlist(density_rows)
  kbl3 <- kbl(tab3, format = "latex", booktabs = TRUE,
              caption = "\\label{tab:density}McCrary Density Tests at Population Thresholds") %>%
    kable_styling(latex_options = c("hold_position"))
  writeLines(kbl3, file.path(tab_dir, "tab3_density.tex"))
  cat("  Saved tab3_density.tex\n")
}

## ----------------------------------------------------------
## Table 4: Main RDD Results — Within-Education Shares
## ----------------------------------------------------------

cat("Generating Table 4: Main Results\n")

main_rows <- list()

if (file.exists(file.path(data_dir, "results_5k.rds"))) {
  results_5k <- readRDS(file.path(data_dir, "results_5k.rds"))

  for (nm in names(results_5k)) {
    # Skip generic share_32 (2-digit aggregate)
    if (nm == "share_32") next
    rd <- results_5k[[nm]]
    if (!is.null(rd)) {
      main_rows[[paste("5k", nm)]] <- data.table(
        Cutoff = "5,000",
        Variable = label_var(nm),
        Estimate = round(rd$coef[1], 4),
        SE = round(rd$se[1], 4),
        `p-value` = round(rd$pv[1], 4),
        Bandwidth = round(rd$bws[1,1]),
        `N (left)` = rd$N_h[1],
        `N (right)` = rd$N_h[2]
      )
    }
  }
}

if (file.exists(file.path(data_dir, "results_3k.rds"))) {
  results_3k <- readRDS(file.path(data_dir, "results_3k.rds"))

  for (nm in names(results_3k)) {
    if (nm == "share_32") next
    rd <- results_3k[[nm]]
    if (!is.null(rd)) {
      main_rows[[paste("3k", nm)]] <- data.table(
        Cutoff = "3,000",
        Variable = label_var(nm),
        Estimate = round(rd$coef[1], 4),
        SE = round(rd$se[1], 4),
        `p-value` = round(rd$pv[1], 4),
        Bandwidth = round(rd$bws[1,1]),
        `N (left)` = rd$N_h[1],
        `N (right)` = rd$N_h[2]
      )
    }
  }
}

if (length(main_rows) > 0) {
  tab4 <- rbindlist(main_rows)

  # Significance stars
  tab4[, Stars := fcase(
    `p-value` < 0.01, "***",
    `p-value` < 0.05, "**",
    `p-value` < 0.10, "*",
    default = ""
  )]

  kbl4 <- kbl(tab4[, .(Cutoff, Variable, Estimate, SE, `p-value`, Stars,
                        Bandwidth, `N (left)`, `N (right)`)],
              format = "latex", booktabs = TRUE,
              caption = "\\label{tab:main_results}Main RDD Results: Within-Education Budget Shares and Aggregate Outcomes") %>%
    kable_styling(latex_options = c("hold_position", "scale_down"))
  writeLines(kbl4, file.path(tab_dir, "tab4_main_results.tex"))
  cat("  Saved tab4_main_results.tex\n")
}

## ----------------------------------------------------------
## Table 5: Robustness — Donut RDD
## ----------------------------------------------------------

cat("Generating Table 5: Donut RDD\n")

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

    # Add N columns if available
    has_n <- "n_left" %in% names(donut_dt)
    if (has_n) {
      kbl5 <- kbl(donut_dt[, .(radius, variable, est, se, pv, Stars, bw, n_left, n_right)],
                  col.names = c("Donut", "Variable", "Estimate", "SE",
                                "p-value", "", "Bandwidth", "N (left)", "N (right)"),
                  format = "latex", booktabs = TRUE,
                  caption = "\\label{tab:donut}Robustness: Donut RDD Estimates") %>%
        kable_styling(latex_options = c("hold_position", "scale_down"))
    } else {
      kbl5 <- kbl(donut_dt[, .(radius, variable, est, se, pv, Stars)],
                  col.names = c("Donut Radius", "Variable", "Estimate", "SE",
                                "p-value", ""),
                  format = "latex", booktabs = TRUE,
                  caption = "\\label{tab:donut}Robustness: Donut RDD Estimates") %>%
        kable_styling(latex_options = c("hold_position"))
    }
    writeLines(kbl5, file.path(tab_dir, "tab5_donut.tex"))
    cat("  Saved tab5_donut.tex\n")
  }
}

## ----------------------------------------------------------
## Table 6: Robustness — Bandwidth Sensitivity
## ----------------------------------------------------------

cat("Generating Table 6: Bandwidth Sensitivity\n")

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

    kbl6 <- kbl(bw_dt[, .(multiplier, bw, est, se, pv, Stars)],
                col.names = c("BW Multiplier", "Bandwidth", "Estimate", "SE",
                              "p-value", ""),
                format = "latex", booktabs = TRUE,
                caption = "\\label{tab:bandwidth}Robustness: Bandwidth Sensitivity") %>%
      kable_styling(latex_options = c("hold_position"))
    writeLines(kbl6, file.path(tab_dir, "tab6_bandwidth.tex"))
    cat("  Saved tab6_bandwidth.tex\n")
  }
}

## ----------------------------------------------------------
## Table 7: Placebo Tests
## ----------------------------------------------------------

cat("Generating Table 7: Placebo Tests\n")

placebo_rows <- list()

# Pre-treatment placebos
if (file.exists(file.path(data_dir, "placebo_results.rds"))) {
  plac <- readRDS(file.path(data_dir, "placebo_results.rds"))
  for (nm in names(plac)) {
    r <- plac[[nm]]
    # Skip generic share_32
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

# Placebo cutoffs
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
  tab7 <- rbindlist(placebo_rows)
  tab7[, Stars := fcase(
    `p-value` < 0.01, "***",
    `p-value` < 0.05, "**",
    `p-value` < 0.10, "*",
    default = ""
  )]

  kbl7 <- kbl(tab7[, .(Test, Variable, Estimate, SE, `p-value`, Stars)],
              format = "latex", booktabs = TRUE,
              caption = "\\label{tab:placebo}Placebo Tests: Pre-Treatment and False Cutoffs") %>%
    kable_styling(latex_options = c("hold_position"))
  writeLines(kbl7, file.path(tab_dir, "tab7_placebo.tex"))
  cat("  Saved tab7_placebo.tex\n")
}

## ----------------------------------------------------------
## Table 8: Covariate Balance
## ----------------------------------------------------------

cat("Generating Table 8: Covariate Balance\n")

pre_data <- panel[year == 2010 & pop > 2000 & pop < 8000]
balance_vars <- c("spending_pc", "edu_pc", "security_pc", "social_pc")

bal_rows <- list()
for (var in balance_vars) {
  if (var %in% names(pre_data) && sum(!is.na(pre_data[[var]])) > 50) {
    bal <- tryCatch(
      rdrobust(y = pre_data[[var]],
               x = pre_data$pop,
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

if (length(bal_rows) > 0) {
  tab8 <- rbindlist(bal_rows)

  name_map_bal <- c(
    spending_pc = "Total Spending p.c. (EUR)",
    edu_pc = "Education Spending p.c. (EUR)",
    security_pc = "Security Spending p.c. (EUR)",
    social_pc = "Social Spending p.c. (EUR)"
  )
  tab8[, Variable := name_map_bal[Variable]]

  kbl8 <- kbl(tab8, format = "latex", booktabs = TRUE,
              caption = "\\label{tab:balance}Covariate Balance at 5,000 Population Threshold (2010 Pre-Treatment)") %>%
    kable_styling(latex_options = c("hold_position"))
  writeLines(kbl8, file.path(tab_dir, "tab8_balance.tex"))
  cat("  Saved tab8_balance.tex\n")
}

## ----------------------------------------------------------
## Table 9: LRSAL Heterogeneity (Pre/Post 2013)
## ----------------------------------------------------------

cat("Generating Table 9: Pre/Post-LRSAL Heterogeneity\n")

if (file.exists(file.path(data_dir, "lrsal_results.rds"))) {
  lrsal <- readRDS(file.path(data_dir, "lrsal_results.rds"))

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
    lrsal_dt[, variable := label_var(variable)]
    lrsal_dt[, Period := fifelse(period == "pre_lrsal",
                                  "Pre-LRSAL (2010--2013)",
                                  "Post-LRSAL (2014--2023)")]

    kbl9 <- kbl(lrsal_dt[, .(Period, variable, est, se, pv, Stars, bw, n_left, n_right)],
                col.names = c("Period", "Variable", "Estimate", "SE",
                              "p-value", "", "Bandwidth", "N (left)", "N (right)"),
                format = "latex", booktabs = TRUE,
                caption = "\\label{tab:lrsal}Temporal Heterogeneity: Pre- and Post-LRSAL RDD Results at 5,000 Threshold") %>%
      kable_styling(latex_options = c("hold_position", "scale_down"))
    writeLines(kbl9, file.path(tab_dir, "tab9_lrsal.tex"))
    cat("  Saved tab9_lrsal.tex\n")
  }
} else {
  cat("  WARNING: lrsal_results.rds not found. Run 04_robustness.R first.\n")
}

cat("\n=== TABLES COMPLETE ===\n")
