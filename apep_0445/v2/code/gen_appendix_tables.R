source("00_packages.R")

# Table A1: Donut RDD
donut <- readRDS(file.path(data_dir, "donut_rdd_results.rds"))
if (nrow(donut) > 0) {
  donut_rows <- sapply(1:nrow(donut), function(i) {
    r <- donut[i, ]
    stars <- ifelse(r$pval < 0.01, "***", ifelse(r$pval < 0.05, "**", ifelse(r$pval < 0.10, "*", "")))
    paste0(r$outcome, " & $\\pm$", formatC(r$donut, format="f", digits=1), " & ",
           formatC(r$coef, format="f", digits=3), stars, " & (",
           formatC(r$se, format="f", digits=3), ") & ",
           formatC(r$pval, format="f", digits=3), " & ",
           format(r$N_eff, big.mark=","))
  })
  tex <- paste0(
    "\\begin{table}[htbp]\n\\centering\n",
    "\\caption{Donut RDD Estimates}\n\\label{tab:donut}\n\\small\n",
    "\\begin{tabular}{lccccc}\n\\toprule\n",
    "Outcome & Donut & Estimate & Robust SE & $p$-value & N \\\\\n\\midrule\n",
    paste(donut_rows, collapse=" \\\\\n"), " \\\\\n",
    "\\bottomrule\n\\end{tabular}\n",
    "\\begin{tablenotes}\n\\small\n",
    "\\item \\textit{Notes:} Donut RDD excludes observations within the specified distance of the 20\\% cutoff. * $p<0.10$, ** $p<0.05$, *** $p<0.01$.\n",
    "\\end{tablenotes}\n\\end{table}")
  writeLines(tex, file.path(tab_dir, "tabA1_donut_rdd.tex"))
  cat("Saved tabA1\n")
}

# Table A2: Polynomial sensitivity
poly <- readRDS(file.path(data_dir, "polynomial_sensitivity.rds"))
if (nrow(poly) > 0) {
  poly_rows <- sapply(1:nrow(poly), function(i) {
    r <- poly[i, ]
    stars <- ifelse(r$pval < 0.01, "***", ifelse(r$pval < 0.05, "**", ifelse(r$pval < 0.10, "*", "")))
    paste0(r$outcome, " & ", r$poly_order, " & ",
           formatC(r$coef, format="f", digits=3), stars, " & (",
           formatC(r$se, format="f", digits=3), ") & ",
           formatC(r$pval, format="f", digits=3), " & ",
           format(r$N_eff, big.mark=","))
  })
  tex <- paste0(
    "\\begin{table}[htbp]\n\\centering\n",
    "\\caption{Polynomial Order Sensitivity}\n\\label{tab:polynomial}\n\\small\n",
    "\\begin{tabular}{lccccc}\n\\toprule\n",
    "Outcome & Poly Order & Estimate & Robust SE & $p$-value & N \\\\\n\\midrule\n",
    paste(poly_rows, collapse=" \\\\\n"), " \\\\\n",
    "\\bottomrule\n\\end{tabular}\n",
    "\\begin{tablenotes}\n\\small\n",
    "\\item \\textit{Notes:} RDD estimates with varying polynomial orders. All use MSE-optimal bandwidth with triangular kernel. * $p<0.10$, ** $p<0.05$, *** $p<0.01$.\n",
    "\\end{tablenotes}\n\\end{table}")
  writeLines(tex, file.path(tab_dir, "tabA2_polynomial.tex"))
  cat("Saved tabA2\n")
}

# Table A3: Kernel sensitivity
kern <- readRDS(file.path(data_dir, "kernel_sensitivity.rds"))
if (nrow(kern) > 0) {
  kern_rows <- sapply(1:nrow(kern), function(i) {
    r <- kern[i, ]
    stars <- ifelse(r$pval < 0.01, "***", ifelse(r$pval < 0.05, "**", ifelse(r$pval < 0.10, "*", "")))
    paste0(r$outcome, " & ", r$kernel, " & ",
           formatC(r$coef, format="f", digits=3), stars, " & (",
           formatC(r$se, format="f", digits=3), ") & ",
           formatC(r$pval, format="f", digits=3), " & ",
           format(r$N_eff, big.mark=","))
  })
  tex <- paste0(
    "\\begin{table}[htbp]\n\\centering\n",
    "\\caption{Kernel Function Sensitivity}\n\\label{tab:kernel}\n\\small\n",
    "\\begin{tabular}{lccccc}\n\\toprule\n",
    "Outcome & Kernel & Estimate & Robust SE & $p$-value & N \\\\\n\\midrule\n",
    paste(kern_rows, collapse=" \\\\\n"), " \\\\\n",
    "\\bottomrule\n\\end{tabular}\n",
    "\\begin{tablenotes}\n\\small\n",
    "\\item \\textit{Notes:} RDD estimates with alternative kernel functions. All use MSE-optimal bandwidth and local linear regression. * $p<0.10$, ** $p<0.05$, *** $p<0.01$.\n",
    "\\end{tablenotes}\n\\end{table}")
  writeLines(tex, file.path(tab_dir, "tabA3_kernel.tex"))
  cat("Saved tabA3\n")
}
