###############################################################################
# 05_appendix_tables.R
# Generate LaTeX appendix tables for robustness results
# APEP-0445
###############################################################################

source(file.path(dirname(sys.frame(1)$ofile %||% "."), "00_packages.R"))

# Helper: format coefficient with stars
fmt_coef <- function(coef, pval) {
  stars <- ifelse(pval < 0.01, "^{***}",
           ifelse(pval < 0.05, "^{**}",
           ifelse(pval < 0.10, "^{*}", "")))
  sprintf("%.3f%s", coef, stars)
}

fmt_se <- function(se) sprintf("(%.3f)", se)
fmt_ci <- function(lo, hi) sprintf("[%.1f, %.1f]", lo, hi)
fmt_n <- function(n) formatC(n, format = "d", big.mark = ",")

###############################################################################
# Table A1: Donut RDD
###############################################################################
cat("=== Generating Donut RDD Table ===\n")
donut <- readRDS(file.path(data_dir, "donut_rdd_results.rds"))

# Reshape: rows = outcomes, columns = donut sizes
outcomes <- c("Delta Total Emp", "Delta Info Emp", "Delta Construction Emp")
outcome_labels <- c("$\\Delta$ Total employment",
                     "$\\Delta$ Info sector employment",
                     "$\\Delta$ Construction employment")
donuts <- c(0.5, 1.0, 2.0)

tex_lines <- c(
  "\\begin{table}[htbp]",
  "\\centering",
  "\\caption{Donut RDD Estimates: Excluding Tracts Near the Cutoff}",
  "\\label{tab:donut_rdd}",
  "\\small",
  "\\begin{tabular}{l*{3}{c}}",
  "\\toprule",
  " & \\multicolumn{3}{c}{Donut exclusion zone} \\\\",
  "\\cmidrule(lr){2-4}",
  " & $\\pm 0.5$ pp & $\\pm 1.0$ pp & $\\pm 2.0$ pp \\\\",
  "\\midrule"
)

for (i in seq_along(outcomes)) {
  oc <- outcomes[i]
  coef_row <- outcome_labels[i]
  se_row <- ""
  ci_row <- ""
  n_row <- ""

  for (d in donuts) {
    row <- donut %>% filter(outcome == oc, donut == d)
    if (nrow(row) == 1) {
      coef_row <- paste0(coef_row, " & ", fmt_coef(row$coef, row$pval))
      se_row <- paste0(se_row, " & ", fmt_se(row$se))
      ci_row <- paste0(ci_row, " & ", fmt_ci(row$ci_lower, row$ci_upper))
      n_row <- paste0(n_row, " & ", fmt_n(row$N_eff))
    } else {
      coef_row <- paste0(coef_row, " & ---")
      se_row <- paste0(se_row, " & ---")
      ci_row <- paste0(ci_row, " & ---")
      n_row <- paste0(n_row, " & ---")
    }
  }

  tex_lines <- c(tex_lines,
    paste0(coef_row, " \\\\"),
    paste0(se_row, " \\\\"),
    paste0(ci_row, " \\\\")
  )
  tex_lines <- c(tex_lines, paste0("N", n_row, " \\\\"))
  if (i < length(outcomes)) {
    tex_lines <- c(tex_lines, "\\addlinespace")
  }
}

tex_lines <- c(tex_lines,
  "\\bottomrule",
  "\\end{tabular}",
  "\\begin{tablenotes}",
  "\\small",
  "\\item \\textit{Notes:} Reduced-form RDD estimates excluding tracts within the specified distance of the 20 percent poverty threshold. Estimates from \\texttt{rdrobust} with MSE-optimal bandwidth and triangular kernel. Robust bias-corrected standard errors in parentheses; 95\\% confidence intervals in brackets. N varies across outcomes and donut sizes because \\texttt{rdrobust} selects a separate MSE-optimal bandwidth for each specification; wider optimal bandwidths include more tracts and can yield larger N even with donut exclusions. * $p<0.10$, ** $p<0.05$, *** $p<0.01$.",
  "\\end{tablenotes}",
  "\\end{table}"
)

writeLines(tex_lines, file.path(tab_dir, "tabA1_donut_rdd.tex"))
cat("  Written to", file.path(tab_dir, "tabA1_donut_rdd.tex"), "\n")


###############################################################################
# Table A2: Polynomial Sensitivity
###############################################################################
cat("=== Generating Polynomial Sensitivity Table ===\n")
poly <- readRDS(file.path(data_dir, "polynomial_sensitivity.rds"))

poly_labels <- c("Linear ($p=1$)", "Quadratic ($p=2$)", "Cubic ($p=3$)")
poly_orders <- c(1, 2, 3)

tex_lines <- c(
  "\\begin{table}[htbp]",
  "\\centering",
  "\\caption{Polynomial Sensitivity of RDD Estimates}",
  "\\label{tab:poly_sensitivity}",
  "\\small",
  "\\begin{tabular}{l*{3}{c}}",
  "\\toprule",
  " & \\multicolumn{3}{c}{Polynomial order} \\\\",
  "\\cmidrule(lr){2-4}",
  " & Linear ($p=1$) & Quadratic ($p=2$) & Cubic ($p=3$) \\\\",
  "\\midrule"
)

for (i in seq_along(outcomes)) {
  oc <- outcomes[i]
  coef_row <- outcome_labels[i]
  se_row <- ""
  ci_row <- ""
  n_row <- ""

  for (p in poly_orders) {
    row <- poly %>% filter(outcome == oc, poly_order == p)
    if (nrow(row) == 1) {
      coef_row <- paste0(coef_row, " & ", fmt_coef(row$coef, row$pval))
      se_row <- paste0(se_row, " & ", fmt_se(row$se))
      ci_row <- paste0(ci_row, " & ", fmt_ci(row$ci_lower, row$ci_upper))
      n_row <- paste0(n_row, " & ", fmt_n(row$N_eff))
    } else {
      coef_row <- paste0(coef_row, " & ---")
      se_row <- paste0(se_row, " & ---")
      ci_row <- paste0(ci_row, " & ---")
      n_row <- paste0(n_row, " & ---")
    }
  }

  tex_lines <- c(tex_lines,
    paste0(coef_row, " \\\\"),
    paste0(se_row, " \\\\"),
    paste0(ci_row, " \\\\")
  )
  tex_lines <- c(tex_lines, paste0("N", n_row, " \\\\"))
  if (i < length(outcomes)) {
    tex_lines <- c(tex_lines, "\\addlinespace")
  }
}

tex_lines <- c(tex_lines,
  "\\bottomrule",
  "\\end{tabular}",
  "\\begin{tablenotes}",
  "\\small",
  "\\item \\textit{Notes:} Reduced-form RDD estimates with varying polynomial order. Estimates from \\texttt{rdrobust} with MSE-optimal bandwidth and triangular kernel. Robust bias-corrected standard errors in parentheses; 95\\% confidence intervals in brackets. N varies across outcomes and polynomial orders because \\texttt{rdrobust} selects a separate MSE-optimal bandwidth for each specification. * $p<0.10$, ** $p<0.05$, *** $p<0.01$.",
  "\\end{tablenotes}",
  "\\end{table}"
)

writeLines(tex_lines, file.path(tab_dir, "tabA2_polynomial.tex"))
cat("  Written to", file.path(tab_dir, "tabA2_polynomial.tex"), "\n")


###############################################################################
# Table A3: Kernel Sensitivity
###############################################################################
cat("=== Generating Kernel Sensitivity Table ===\n")
kern <- readRDS(file.path(data_dir, "kernel_sensitivity.rds"))

kern_names <- c("triangular", "uniform", "epanechnikov")
kern_labels <- c("Triangular", "Uniform", "Epanechnikov")

tex_lines <- c(
  "\\begin{table}[htbp]",
  "\\centering",
  "\\caption{Kernel Sensitivity of RDD Estimates}",
  "\\label{tab:kernel_sensitivity}",
  "\\small",
  "\\begin{tabular}{l*{3}{c}}",
  "\\toprule",
  " & \\multicolumn{3}{c}{Kernel function} \\\\",
  "\\cmidrule(lr){2-4}",
  " & Triangular & Uniform & Epanechnikov \\\\",
  "\\midrule"
)

for (i in seq_along(outcomes)) {
  oc <- outcomes[i]
  coef_row <- outcome_labels[i]
  se_row <- ""
  ci_row <- ""
  n_row <- ""

  for (k in kern_names) {
    row <- kern %>% filter(outcome == oc, kernel == k)
    if (nrow(row) == 1) {
      coef_row <- paste0(coef_row, " & ", fmt_coef(row$coef, row$pval))
      se_row <- paste0(se_row, " & ", fmt_se(row$se))
      ci_row <- paste0(ci_row, " & ", fmt_ci(row$ci_lower, row$ci_upper))
      n_row <- paste0(n_row, " & ", fmt_n(row$N_eff))
    } else {
      coef_row <- paste0(coef_row, " & ---")
      se_row <- paste0(se_row, " & ---")
      ci_row <- paste0(ci_row, " & ---")
      n_row <- paste0(n_row, " & ---")
    }
  }

  tex_lines <- c(tex_lines,
    paste0(coef_row, " \\\\"),
    paste0(se_row, " \\\\"),
    paste0(ci_row, " \\\\")
  )
  tex_lines <- c(tex_lines, paste0("N", n_row, " \\\\"))
  if (i < length(outcomes)) {
    tex_lines <- c(tex_lines, "\\addlinespace")
  }
}

tex_lines <- c(tex_lines,
  "\\bottomrule",
  "\\end{tabular}",
  "\\begin{tablenotes}",
  "\\small",
  "\\item \\textit{Notes:} Reduced-form RDD estimates with varying kernel functions. Estimates from \\texttt{rdrobust} with MSE-optimal bandwidth. Robust bias-corrected standard errors in parentheses; 95\\% confidence intervals in brackets. N varies across outcomes and kernels because \\texttt{rdrobust} selects a separate MSE-optimal bandwidth for each specification. * $p<0.10$, ** $p<0.05$, *** $p<0.01$.",
  "\\end{tablenotes}",
  "\\end{table}"
)

writeLines(tex_lines, file.path(tab_dir, "tabA3_kernel.tex"))
cat("  Written to", file.path(tab_dir, "tabA3_kernel.tex"), "\n")

cat("\n=== All appendix tables generated ===\n")
