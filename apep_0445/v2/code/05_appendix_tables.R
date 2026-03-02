###############################################################################
# 05_appendix_tables.R
# Generate appendix tables for inference robustness and local randomization
# APEP-0445 v2
###############################################################################

this_file <- tryCatch(sys.frame(1)$ofile, error = function(e) NULL)
if (is.null(this_file)) this_file <- "."
source(file.path(dirname(this_file), "00_packages.R"))

rdd_sample <- readRDS(file.path(data_dir, "rdd_sample.rds"))
cat("Data loaded for appendix tables\n\n")

fmt_3f <- function(x) formatC(x, format = "f", digits = 3)
fmt_1f <- function(x) formatC(x, format = "f", digits = 1)
fmt_n <- function(x) format(x, big.mark = ",")

add_stars <- function(coef_str, pval) {
  stars <- ifelse(pval < 0.01, "***",
           ifelse(pval < 0.05, "**",
           ifelse(pval < 0.10, "*", "")))
  paste0(coef_str, stars)
}


###############################################################################
# Table A4: Inference Robustness
###############################################################################
cat("Table A4: Inference Robustness\n")

main_results <- readRDS(file.path(data_dir, "main_rdd_results.rds"))
cov_file <- file.path(data_dir, "cov_adjusted_rdd_results.rds")
cluster_file <- file.path(data_dir, "cluster_models.rds")
param_file <- file.path(data_dir, "parametric_models.rds")

# Column 1: Baseline rdrobust
# Column 2: rdrobust + covariates
# Column 3: Parametric HC1
# Column 4: Parametric county-clustered

rows <- list()
for (outcome in c("Delta Total Emp", "Delta Info Emp", "Delta Construction Emp")) {
  # Col 1: Baseline rdrobust
  base <- main_results[[outcome]]
  col1_coef <- if (!is.null(base)) add_stars(fmt_3f(base$coef), base$pval) else "---"
  col1_se <- if (!is.null(base)) paste0("(", fmt_3f(base$se_robust), ")") else ""

  # Col 2: Covariate-adjusted rdrobust
  if (file.exists(cov_file)) {
    cov_res <- readRDS(cov_file)
    cov <- cov_res[[outcome]]
    col2_coef <- if (!is.null(cov)) add_stars(fmt_3f(cov$coef), cov$pval) else "---"
    col2_se <- if (!is.null(cov)) paste0("(", fmt_3f(cov$se_robust), ")") else ""
  } else {
    col2_coef <- "---"
    col2_se <- ""
  }

  # Col 3 & 4: Parametric (HC1 and county-clustered)
  if (outcome == "Delta Total Emp") {
    param_key_hc1 <- "m1"
    clust_key <- "total_linear"
  } else if (outcome == "Delta Info Emp") {
    param_key_hc1 <- "m4"
    clust_key <- "info_linear"
  } else {
    param_key_hc1 <- NULL
    clust_key <- NULL
  }

  if (!is.null(param_key_hc1) && file.exists(param_file)) {
    param_models <- readRDS(param_file)
    m <- param_models[[param_key_hc1]]
    if (!is.null(m)) {
      hc1_coef_val <- coef(m)["eligible_povertyTRUE"]
      hc1_se_val <- sqrt(vcov(m)["eligible_povertyTRUE", "eligible_povertyTRUE"])
      hc1_pval <- 2 * pnorm(-abs(hc1_coef_val / hc1_se_val))
      col3_coef <- add_stars(fmt_3f(hc1_coef_val), hc1_pval)
      col3_se <- paste0("(", fmt_3f(hc1_se_val), ")")
    } else {
      col3_coef <- "---"
      col3_se <- ""
    }
  } else {
    col3_coef <- "---"
    col3_se <- ""
  }

  if (!is.null(clust_key) && file.exists(cluster_file)) {
    cluster_models <- readRDS(cluster_file)
    mc <- cluster_models[[clust_key]]
    if (!is.null(mc)) {
      cl_coef_val <- coef(mc)["eligible_povertyTRUE"]
      cl_se_val <- sqrt(vcov(mc)["eligible_povertyTRUE", "eligible_povertyTRUE"])
      cl_pval <- 2 * pnorm(-abs(cl_coef_val / cl_se_val))
      col4_coef <- add_stars(fmt_3f(cl_coef_val), cl_pval)
      col4_se <- paste0("(", fmt_3f(cl_se_val), ")")
    } else {
      col4_coef <- "---"
      col4_se <- ""
    }
  } else {
    col4_coef <- "---"
    col4_se <- ""
  }

  label <- gsub("Delta ", "$\\\\Delta$ ", outcome)
  rows[[outcome]] <- paste0(
    label, " & ", col1_coef, " & ", col2_coef, " & ", col3_coef, " & ", col4_coef, " \\\\\n",
    " & ", col1_se, " & ", col2_se, " & ", col3_se, " & ", col4_se, " \\\\"
  )
}

tex_a4 <- paste0(
  "\\begin{table}[htbp]\n",
  "\\centering\n",
  "\\caption{Inference Robustness}\n",
  "\\label{tab:inference_robustness}\n",
  "\\small\n",
  "\\begin{tabular}{lcccc}\n",
  "\\toprule\n",
  " & (1) & (2) & (3) & (4) \\\\\n",
  " & Baseline & + Covariates & Parametric & County \\\\\n",
  " & rdrobust & rdrobust & HC1 & Clustered \\\\\n",
  "\\midrule\n",
  paste(unlist(rows), collapse = "\n"), "\n",
  "\\bottomrule\n",
  "\\end{tabular}\n",
  "\\begin{tablenotes}\n",
  "\\small\n",
  "\\item \\textit{Notes:} Column (1): baseline \\texttt{rdrobust} with MSE-optimal bandwidth and triangular kernel. Column (2): \\texttt{rdrobust} with demographic covariates (population, education, race, unemployment). Column (3): parametric linear RDD within optimal bandwidth with HC1 standard errors. Column (4): parametric linear RDD with county-clustered standard errors. * $p<0.10$, ** $p<0.05$, *** $p<0.01$.\n",
  "\\end{tablenotes}\n",
  "\\end{table}"
)

writeLines(tex_a4, file.path(tab_dir, "tabA4_inference_robustness.tex"))
cat("  Saved tabA4_inference_robustness.tex\n")


###############################################################################
# Table A5: Local Randomization Inference
###############################################################################
cat("Table A5: Local Randomization Inference\n")

lr_file <- file.path(data_dir, "local_randomization.rds")
if (file.exists(lr_file)) {
  lr <- readRDS(lr_file)

  if (nrow(lr) > 0) {
    lr_rows <- sapply(1:nrow(lr), function(i) {
      r <- lr[i, ]
      label <- gsub("Delta ", "$\\\\Delta$ ", r$outcome)
      paste0(
        label, " & $\\pm$", fmt_1f(r$window), " & ",
        fmt_3f(r$obs_stat), " & ",
        fmt_3f(r$p_value), " & ",
        r$n_left, " & ", r$n_right
      )
    })

    tex_a5 <- paste0(
      "\\begin{table}[htbp]\n",
      "\\centering\n",
      "\\caption{Local Randomization Inference}\n",
      "\\label{tab:local_randomization}\n",
      "\\small\n",
      "\\begin{tabular}{lccccc}\n",
      "\\toprule\n",
      "Outcome & Window (pp) & Test Stat & Fisher $p$ & $N_{left}$ & $N_{right}$ \\\\\n",
      "\\midrule\n",
      paste(lr_rows, collapse = " \\\\\n"), " \\\\\n",
      "\\bottomrule\n",
      "\\end{tabular}\n",
      "\\begin{tablenotes}\n",
      "\\small\n",
      "\\item \\textit{Notes:} Randomization inference using \\texttt{rdrandinf} \\citep{cattaneo2015} with 1,000 permutations. Windows are symmetric around the 20\\% poverty cutoff. Fisher $p$-values test the sharp null of no treatment effect for any unit within the window.\n",
      "\\end{tablenotes}\n",
      "\\end{table}"
    )

    writeLines(tex_a5, file.path(tab_dir, "tabA5_local_randomization.tex"))
    cat("  Saved tabA5_local_randomization.tex\n")
  } else {
    cat("  No local randomization results available\n")
  }
} else {
  cat("  Local randomization file not found\n")
}

cat("\n=== Appendix tables complete ===\n")
