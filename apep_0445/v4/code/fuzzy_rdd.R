this_file <- tryCatch(sys.frame(1)$ofile, error = function(e) NULL)
if (is.null(this_file)) this_file <- "."
source(file.path(dirname(this_file), "00_packages.R"))
rdd_sample <- readRDS(file.path(data_dir, "rdd_sample.rds"))

outcomes <- c("delta_total_emp", "delta_info_emp", "delta_construction_emp")
labels <- c("Delta Total employment", "Delta Info sector emp", "Delta Construction emp")
results <- list()

for (i in seq_along(outcomes)) {
  y <- rdd_sample[[outcomes[i]]]
  d <- rdd_sample[["oz_designated"]]
  x <- rdd_sample[["poverty_rate"]]
  ok <- !is.na(y) & !is.na(d) & !is.na(x)
  
  tryCatch({
    fit <- rdrobust(y[ok], x[ok], fuzzy = d[ok], c = 20, kernel = "triangular", p = 1)
    results[[i]] <- data.frame(
      label = labels[i],
      estimate = round(fit$coef[3], 3),
      se = round(fit$se[3], 3),
      pval = round(fit$pv[3], 3),
      ci_lo = round(fit$ci[3, 1], 3),
      ci_hi = round(fit$ci[3, 2], 3),
      n = fit$N_h[1] + fit$N_h[2]
    )
    cat(sprintf("  %s: est=%.3f se=%.3f p=%.3f N=%d\n", labels[i], fit$coef[3], fit$se[3], fit$pv[3], fit$N_h[1]+fit$N_h[2]))
  }, error = function(e) {
    cat(sprintf("  %s: ERROR - %s\n", labels[i], e$message))
  })
}

df <- do.call(rbind, results)

# Write LaTeX table
lines <- character()
lines <- c(lines, "\\begin{table}[htbp]")
lines <- c(lines, "\\centering")
lines <- c(lines, "\\caption{Fuzzy RDD Estimates: Local Average Treatment Effect of OZ Designation}")
lines <- c(lines, "\\label{tab:fuzzy_rdd}")
lines <- c(lines, "\\small")
lines <- c(lines, "\\begin{tabular}{lcccc}")
lines <- c(lines, "\\toprule")
lines <- c(lines, "& Wald Estimate & Robust SE & 95\\% CI & N \\\\")
lines <- c(lines, "\\midrule")

for (i in 1:nrow(df)) {
  line <- sprintf("$\\Delta$ %s & %.1f & (%.1f) & [%.1f, %.1f] & %s \\\\",
    gsub("Delta ", "", df$label[i]),
    df$estimate[i], df$se[i], df$ci_lo[i], df$ci_hi[i],
    format(df$n[i], big.mark=","))
  lines <- c(lines, line)
}

lines <- c(lines, "\\bottomrule")
lines <- c(lines, "\\end{tabular}")
lines <- c(lines, "\\begin{tablenotes}")
lines <- c(lines, "\\small")
lines <- c(lines, "\\item \\textit{Notes:} Fuzzy RDD Wald estimates of OZ designation on employment outcomes, using the 20\\% poverty threshold as the instrument for designation. Estimated via \\texttt{rdrobust} with MSE-optimal bandwidth, triangular kernel, and local linear specification. Robust bias-corrected confidence intervals. * $p<0.10$, ** $p<0.05$, *** $p<0.01$.")
lines <- c(lines, "\\end{tablenotes}")
lines <- c(lines, "\\end{table}")

writeLines(lines, file.path(tab_dir, "tab2b_fuzzy_rdd.tex"))
cat("Saved tables/tab2b_fuzzy_rdd.tex\n")
