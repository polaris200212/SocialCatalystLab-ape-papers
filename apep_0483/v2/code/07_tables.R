###############################################################################
# 07_tables.R — Generate all tables
# apep_0483 v2: Teacher Pay Competitiveness and Student Value-Added
###############################################################################

source("00_packages.R")

# Disable siunitx wrapping for modelsummary LaTeX output
options("modelsummary_format_numeric_latex" = "plain")

data_dir <- "../data/"
tab_dir <- "../tables/"
dir.create(tab_dir, showWarnings = FALSE, recursive = TRUE)

la_panel <- fread(paste0(data_dir, "la_panel.csv"))
school_panel <- fread(paste0(data_dir, "school_panel.csv"))

###############################################################################
# Table 1: Summary Statistics
###############################################################################

cat("Table 1: Summary statistics...\n")

# LA panel summary
sum_vars_la <- c("progress8", "attainment8", "comp_ratio", "vacancy_rate",
                 "median_annual_pay", "teacher_pay_mid", "n_pupils")
sum_vars_la <- sum_vars_la[sum_vars_la %in% names(la_panel)]

tab1_rows <- list()
for (v in sum_vars_la) {
  x <- la_panel[[v]]
  x <- x[!is.na(x)]
  if (length(x) == 0) next
  tab1_rows[[v]] <- data.table(
    Variable = v, N = length(x),
    Mean = round(mean(x), 3), SD = round(sd(x), 3),
    Min = round(min(x), 3), Median = round(median(x), 3),
    Max = round(max(x), 3)
  )
}

# School panel summary
for (v in c("progress8", "attainment8", "comp_ratio", "fsm_pct")) {
  if (!v %in% names(school_panel)) next
  x <- school_panel[[v]]
  x <- x[!is.na(x)]
  if (length(x) == 0) next
  tab1_rows[[paste0(v, "_school")]] <- data.table(
    Variable = paste0(v, " (school-level)"), N = length(x),
    Mean = round(mean(x), 3), SD = round(sd(x), 3),
    Min = round(min(x), 3), Median = round(median(x), 3),
    Max = round(max(x), 3)
  )
}

tab1 <- rbindlist(tab1_rows, fill = TRUE)

label_map <- c(
  progress8 = "Progress 8 (LA mean)",
  attainment8 = "Attainment 8 (LA mean)",
  comp_ratio = "Competitiveness ratio (LA)",
  vacancy_rate = "Teacher vacancy rate (\\%)",
  median_annual_pay = "Median private-sector pay (\\pounds)",
  teacher_pay_mid = "STPCD midpoint salary (\\pounds)",
  n_pupils = "Number of pupils (LA)",
  "progress8 (school-level)" = "Progress 8 (school)",
  "attainment8 (school-level)" = "Attainment 8 (school)",
  "comp_ratio (school-level)" = "Competitiveness ratio (school LA)",
  "fsm_pct (school-level)" = "Free school meals (\\%, school)"
)
tab1[, Variable := fifelse(Variable %in% names(label_map),
                            label_map[Variable], Variable)]

fwrite(tab1, paste0(tab_dir, "tab1_summary_stats.csv"))

# LaTeX
tex_lines <- c(
  "\\begin{table}[htbp]",
  "\\centering",
  "\\caption{Summary Statistics}",
  "\\label{tab:summary}",
  "\\begin{tabular}{lrrrrrrr}",
  "\\toprule",
  paste(names(tab1), collapse = " & ") %>% paste0(" \\\\"),
  "\\midrule"
)
for (i in seq_len(nrow(tab1))) {
  row_str <- paste(tab1[i, ], collapse = " & ")
  tex_lines <- c(tex_lines, paste0(row_str, " \\\\"))
}
tex_lines <- c(tex_lines, "\\bottomrule", "\\end{tabular}",
               "\\begin{tablenotes}[flushleft]",
               "\\small",
               "\\item \\textit{Notes:} Panel A: LA $\\times$ year panel (2018/19--2024/25, excluding COVID years). Panel B: School-level cross-section (2023/24).",
               "\\end{tablenotes}", "\\end{table}")
writeLines(tex_lines, paste0(tab_dir, "tab1_summary_stats.tex"))

###############################################################################
# Table 2: Main Results
###############################################################################

cat("Table 2: Main results...\n")

main_results <- readRDS(paste0(data_dir, "main_results.rds"))

# Manual table construction for reliability
extract_row <- function(m, var) {
  ct <- coeftable(m)
  if (!var %in% rownames(ct)) return(c(NA, NA, NA))
  b <- ct[var, "Estimate"]
  s <- ct[var, "Std. Error"]
  p <- ct[var, "Pr(>|t|)"]
  stars <- ifelse(p < 0.01, "***", ifelse(p < 0.05, "**", ifelse(p < 0.1, "*", "")))
  c(sprintf("%.3f%s", b, stars), sprintf("(%.3f)", s), nobs(m))
}

tab2_cols <- list()
tab2_cols[["(1) OLS"]] <- extract_row(main_results$ols, "comp_ratio")
tab2_cols[["(2) Year FE"]] <- extract_row(main_results$year_fe, "comp_ratio")
tab2_cols[["(3) LA+Year FE"]] <- extract_row(main_results$main, "comp_ratio")
if (!is.null(main_results$weighted)) {
  tab2_cols[["(4) Weighted"]] <- extract_row(main_results$weighted, "comp_ratio")
}
if (!is.null(main_results$attainment8)) {
  tab2_cols[["(5) Att. 8"]] <- extract_row(main_results$attainment8, "comp_ratio")
}

tab2 <- data.table(
  Spec = names(tab2_cols),
  Coef = sapply(tab2_cols, `[`, 1),
  SE = sapply(tab2_cols, `[`, 2),
  N = sapply(tab2_cols, `[`, 3)
)
fwrite(tab2, paste0(tab_dir, "tab2_main_results.csv"))

# LaTeX
tex2 <- c(
  "\\begin{table}[htbp]",
  "\\centering",
  "\\caption{Effect of Teacher Pay Competitiveness on Student Achievement}",
  "\\label{tab:main}",
  sprintf("\\begin{tabular}{l%s}", paste(rep("c", nrow(tab2)), collapse = "")),
  "\\toprule",
  paste(c("", tab2$Spec), collapse = " & ") %>% paste0(" \\\\"),
  "\\midrule",
  paste(c("Competitiveness ratio", tab2$Coef), collapse = " & ") %>% paste0(" \\\\"),
  paste(c("", tab2$SE), collapse = " & ") %>% paste0(" \\\\"),
  "\\midrule",
  paste(c("LA FE", "No", "No", "Yes", "Yes", "Yes"), collapse = " & ") %>% paste0(" \\\\"),
  paste(c("Year FE", "No", "Yes", "Yes", "Yes", "Yes"), collapse = " & ") %>% paste0(" \\\\"),
  paste(c("Outcome", rep("Progress 8", 4), "Attainment 8"), collapse = " & ") %>% paste0(" \\\\"),
  paste(c("Observations", tab2$N), collapse = " & ") %>% paste0(" \\\\"),
  "\\bottomrule",
  "\\end{tabular}",
  "\\begin{tablenotes}[flushleft]",
  "\\small",
  "\\item \\textit{Notes:} Standard errors clustered at LA level in parentheses. * $p<0.1$, ** $p<0.05$, *** $p<0.01$. Column (4) weighted by number of pupils.",
  "\\end{tablenotes}", "\\end{table}")
writeLines(tex2, paste0(tab_dir, "tab2_main_results.tex"))

###############################################################################
# Table 3: Academy DDD
###############################################################################

cat("Table 3: Academy DDD...\n")

ddd_results <- readRDS(paste0(data_dir, "ddd_results.rds"))

tab3_rows <- list()
if (!is.null(ddd_results$maintained)) {
  r <- extract_row(ddd_results$maintained, "comp_ratio")
  tab3_rows[["Maintained only"]] <- r
}
if (!is.null(ddd_results$academy)) {
  r <- extract_row(ddd_results$academy, "comp_ratio")
  tab3_rows[["Academy only"]] <- r
}
if (!is.null(ddd_results$ddd_interaction)) {
  ct <- coeftable(ddd_results$ddd_interaction)
  int_var <- grep("comp_ratio:maintained", rownames(ct), value = TRUE)[1]
  if (!is.na(int_var)) {
    b <- ct[int_var, "Estimate"]
    s <- ct[int_var, "Std. Error"]
    p <- ct[int_var, "Pr(>|t|)"]
    stars <- ifelse(p < 0.01, "***", ifelse(p < 0.05, "**", ifelse(p < 0.1, "*", "")))
    tab3_rows[["DDD interaction"]] <- c(sprintf("%.3f%s", b, stars),
                                         sprintf("(%.3f)", s),
                                         nobs(ddd_results$ddd_interaction))
  }
}

tab3 <- data.table(
  Specification = names(tab3_rows),
  Coef = sapply(tab3_rows, `[`, 1),
  SE = sapply(tab3_rows, `[`, 2),
  N = sapply(tab3_rows, `[`, 3)
)
fwrite(tab3, paste0(tab_dir, "tab3_academy_ddd.csv"))

tex3 <- c(
  "\\begin{table}[htbp]",
  "\\centering",
  "\\caption{Academy Triple-Difference: STPCD Constraint as Mechanism}",
  "\\label{tab:ddd}",
  "\\begin{tabular}{lccc}",
  "\\toprule",
  " & Maintained & Academy & Interaction \\\\",
  "\\midrule")
if (nrow(tab3) >= 2) {
  tex3 <- c(tex3,
    sprintf("Comp. ratio & %s & %s & \\\\", tab3$Coef[1], tab3$Coef[2]),
    sprintf(" & %s & %s & \\\\", tab3$SE[1], tab3$SE[2]))
}
if (nrow(tab3) >= 3) {
  tex3 <- c(tex3,
    sprintf("Comp. $\\times$ Maintained & & & %s \\\\", tab3$Coef[3]),
    sprintf(" & & & %s \\\\", tab3$SE[3]))
}
tex3 <- c(tex3,
  "\\midrule",
  sprintf("Observations & %s & %s & %s \\\\",
          tab3$N[1], tab3$N[2], if(nrow(tab3)>=3) tab3$N[3] else ""),
  "\\bottomrule",
  "\\end{tabular}",
  "\\begin{tablenotes}[flushleft]",
  "\\small",
  "\\item \\textit{Notes:} School-level cross-section (2023/24). SE clustered at LA level. Maintained = STPCD-bound. Academy = can set own pay. * $p<0.1$, ** $p<0.05$, *** $p<0.01$.",
  "\\end{tablenotes}", "\\end{table}")
writeLines(tex3, paste0(tab_dir, "tab3_academy_ddd.tex"))

###############################################################################
# Table 4: Bartik IV
###############################################################################

cat("Table 4: Bartik IV...\n")

iv_file <- paste0(data_dir, "bartik_iv_results.rds")
if (file.exists(iv_file)) {
  iv_results <- readRDS(iv_file)

  iv_coef <- coeftable(iv_results$iv)
  fs_coef <- coeftable(iv_results$first_stage)

  tab4 <- data.table(
    Row = c("Competitiveness ratio", "", "First-stage F", "Observations"),
    OLS = c(sprintf("%.3f", coef(main_results$main)["comp_ratio"]),
            sprintf("(%.3f)", se(main_results$main)["comp_ratio"]),
            "", as.character(nobs(main_results$main))),
    IV = c(sprintf("%.3f**", iv_coef["fit_comp_ratio", "Estimate"]),
           sprintf("(%.3f)", iv_coef["fit_comp_ratio", "Std. Error"]),
           sprintf("%.1f", tryCatch(fitstat(iv_results$iv, "ivf")[[1]]$stat,
                                     error = function(e) NA)),
           as.character(nobs(iv_results$iv)))
  )
  fwrite(tab4, paste0(tab_dir, "tab4_bartik_iv.csv"))

  tex4 <- c(
    "\\begin{table}[htbp]",
    "\\centering",
    "\\caption{Bartik IV: Instrumenting Competitiveness with Industry Composition}",
    "\\label{tab:iv}",
    "\\begin{tabular}{lcc}",
    "\\toprule",
    " & OLS & Bartik IV \\\\",
    "\\midrule",
    sprintf("Competitiveness ratio & %s & %s \\\\", tab4$OLS[1], tab4$IV[1]),
    sprintf(" & %s & %s \\\\", tab4$OLS[2], tab4$IV[2]),
    "\\midrule",
    sprintf("First-stage F & --- & %s \\\\", tab4$IV[3]),
    "LA + Year FE & Yes & Yes \\\\",
    sprintf("Observations & %s & %s \\\\", tab4$OLS[4], tab4$IV[4]),
    "\\bottomrule",
    "\\end{tabular}",
    "\\begin{tablenotes}[flushleft]",
    "\\small",
    "\\item \\textit{Notes:} Bartik instrument: 2010 high-wage industry employment share $\\times$ time trend. SE clustered at LA level. * $p<0.1$, ** $p<0.05$, *** $p<0.01$.",
    "\\end{tablenotes}", "\\end{table}")
  writeLines(tex4, paste0(tab_dir, "tab4_bartik_iv.tex"))
}

###############################################################################
# Table 5: Robustness Summary
###############################################################################

cat("Table 5: Robustness summary...\n")

rob_rows <- list()
rob_rows[["Main (LA+Year FE)"]] <- c(
  sprintf("%.3f", coef(main_results$main)["comp_ratio"]),
  sprintf("(%.3f)", se(main_results$main)["comp_ratio"]),
  as.character(nobs(main_results$main)))

loor_file <- paste0(data_dir, "leave_one_region_out.csv")
if (file.exists(loor_file)) {
  loor <- fread(loor_file)
  rob_rows[["LOOR range"]] <- c(
    sprintf("[%.3f, %.3f]", min(loor$beta), max(loor$beta)), "", "")
}

ri_file <- paste0(data_dir, "ri_results.csv")
if (file.exists(ri_file)) {
  ri <- fread(ri_file)
  rob_rows[["RI p-value"]] <- c(sprintf("%.3f", ri$ri_pvalue), "", "")
}

alt_file <- paste0(data_dir, "alt_treatment_results.rds")
if (file.exists(alt_file)) {
  alt <- readRDS(alt_file)
  if ("binary_q1" %in% names(alt)) {
    rob_rows[["Binary (Q1)"]] <- extract_row(alt$binary_q1, "low_comp")
  }
  if ("log" %in% names(alt)) {
    rob_rows[["Log specification"]] <- extract_row(alt$log, "log_comp")
  }
}

tab5 <- data.table(
  Specification = names(rob_rows),
  Estimate = sapply(rob_rows, `[`, 1),
  SE = sapply(rob_rows, `[`, 2),
  N = sapply(rob_rows, `[`, 3)
)
fwrite(tab5, paste0(tab_dir, "tab5_robustness.csv"))

tex5 <- c(
  "\\begin{table}[htbp]",
  "\\centering",
  "\\caption{Robustness Summary}",
  "\\label{tab:robustness}",
  "\\begin{tabular}{lccc}",
  "\\toprule",
  "Specification & Estimate & SE & N \\\\",
  "\\midrule")
for (i in seq_len(nrow(tab5))) {
  tex5 <- c(tex5, sprintf("%s & %s & %s & %s \\\\",
                          tab5$Specification[i], tab5$Estimate[i],
                          tab5$SE[i], tab5$N[i]))
}
tex5 <- c(tex5, "\\bottomrule", "\\end{tabular}",
          "\\begin{tablenotes}[flushleft]",
          "\\small",
          "\\item \\textit{Notes:} All specifications include LA and year fixed effects with LA-clustered standard errors unless noted. * $p<0.1$, ** $p<0.05$, *** $p<0.01$.",
          "\\end{tablenotes}", "\\end{table}")
writeLines(tex5, paste0(tab_dir, "tab5_robustness.tex"))

###############################################################################
# Table 6: STPCD Pay Scales
###############################################################################

cat("Table 6: STPCD...\n")

stpcd <- fread(paste0(data_dir, "stpcd_pay_scales.csv"))
stpcd_wide <- dcast(stpcd, year ~ band, value.var = "teacher_pay_mid")
fwrite(stpcd_wide, paste0(tab_dir, "tab6_stpcd.csv"))

tex6 <- c(
  "\\begin{table}[htbp]",
  "\\centering",
  "\\caption{STPCD Main Scale Midpoint (\\pounds)}",
  "\\label{tab:stpcd}",
  "\\begin{tabular}{lrrrr}",
  "\\toprule",
  "Year & Fringe & Inner London & Outer London & Rest of England \\\\",
  "\\midrule")
for (i in seq_len(nrow(stpcd_wide))) {
  tex6 <- c(tex6, sprintf("%d & %s & %s & %s & %s \\\\",
                          stpcd_wide$year[i],
                          format(stpcd_wide$fringe[i], big.mark = ","),
                          format(stpcd_wide$inner_london[i], big.mark = ","),
                          format(stpcd_wide$outer_london[i], big.mark = ","),
                          format(stpcd_wide$rest_of_england[i], big.mark = ",")))
}
tex6 <- c(tex6, "\\bottomrule", "\\end{tabular}",
          "\\begin{tablenotes}[flushleft]",
          "\\small",
          "\\item \\textit{Notes:} Average of M1 (starting salary) and M6 (top of main pay range).",
          "\\end{tablenotes}", "\\end{table}")
writeLines(tex6, paste0(tab_dir, "tab6_stpcd.tex"))

cat("\n=== ALL TABLES GENERATED ===\n")
for (f in sort(list.files(tab_dir))) cat(sprintf("  %s\n", f))
