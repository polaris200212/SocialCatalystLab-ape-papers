## ============================================================================
## 06_tables.R — Generate LaTeX tables for Criminal Politicians RDD (apep_0449)
## Produces: summary stats, main results, mechanisms, balance, robustness,
##           heterogeneity — all in AER-style booktabs format
## ============================================================================
source("00_packages.R")

cat("\n========================================\n")
cat("TABLE GENERATION — Criminal Politicians RDD\n")
cat("========================================\n\n")

## ── Load data ───────────────────────────────────────────────────────────────
rdd <- readRDS(file.path(DATA_DIR, "rdd_analysis.rds"))
rdd_post08 <- readRDS(file.path(DATA_DIR, "rdd_post08_full.rds"))

## Drop observations with missing outcome for main analyses
rdd_main <- rdd[!is.na(nl_growth)]
cat("Main analysis sample:", nrow(rdd_main), "elections\n")
cat("Post-2008 full sample:", nrow(rdd_post08), "elections\n\n")

## ── Helper: format numbers ──────────────────────────────────────────────────
fmt <- function(x, d = 3) formatC(x, digits = d, format = "f")
fmt2 <- function(x) formatC(x, digits = 2, format = "f")
fmt0 <- function(x) formatC(x, digits = 0, format = "f", big.mark = ",")
stars <- function(p) {
  ifelse(p < 0.01, "$^{***}$",
  ifelse(p < 0.05, "$^{**}$",
  ifelse(p < 0.1,  "$^{*}$", "")))
}

## ============================================================================
## TABLE 1: SUMMARY STATISTICS
## ============================================================================
cat("── Table 1: Summary Statistics ──\n")

## Define variables for summary stats
summ_vars <- c("margin", "nl_growth", "nl_pre", "nl_post",
               "turnout_percentage", "n_cand", "valid_votes")
summ_labels <- c("Vote Margin (\\%)", "NL Growth",
                 "NL Pre-Election", "NL Post-Election",
                 "Turnout (\\%)", "No.\\ Candidates", "Valid Votes")

## Panel A: Full sample
panel_a <- data.frame(
  Variable = summ_labels,
  Mean = NA_real_, SD = NA_real_,
  Min = NA_real_, Max = NA_real_, N = NA_integer_,
  stringsAsFactors = FALSE
)

for (i in seq_along(summ_vars)) {
  v <- summ_vars[i]
  if (v %in% names(rdd_main)) {
    x <- rdd_main[[v]]
    x <- x[!is.na(x)]
    panel_a$Mean[i] <- mean(x)
    panel_a$SD[i]   <- sd(x)
    panel_a$Min[i]  <- min(x)
    panel_a$Max[i]  <- max(x)
    panel_a$N[i]    <- length(x)
  }
}

## Panel B: By treatment
make_panel_b <- function(dt_sub, label) {
  out <- data.frame(
    Variable = summ_labels,
    Mean = NA_real_, SD = NA_real_, N = NA_integer_,
    stringsAsFactors = FALSE
  )
  for (i in seq_along(summ_vars)) {
    v <- summ_vars[i]
    if (v %in% names(dt_sub)) {
      x <- dt_sub[[v]]
      x <- x[!is.na(x)]
      out$Mean[i] <- mean(x)
      out$SD[i]   <- sd(x)
      out$N[i]    <- length(x)
    }
  }
  out
}

panel_b_treat <- make_panel_b(rdd_main[treatment == 1], "Criminal Won")
panel_b_ctrl  <- make_panel_b(rdd_main[treatment == 0], "Criminal Lost")

## Write LaTeX
sink(file.path(TAB_DIR, "tab_summary_stats.tex"))
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Summary Statistics}\n")
cat("\\label{tab:summary_stats}\n")
cat("\\small\n")
cat("\\begin{tabular}{l ccccc}\n")
cat("\\toprule\n")
cat(" & Mean & SD & Min & Max & $N$ \\\\\n")
cat("\\midrule\n")
cat("\\multicolumn{6}{l}{\\textit{Panel A: Full Sample}} \\\\\n")
cat("\\addlinespace[3pt]\n")
for (i in seq_len(nrow(panel_a))) {
  if (!is.na(panel_a$Mean[i])) {
    cat(sprintf("%-30s & %s & %s & %s & %s & %s \\\\\n",
                panel_a$Variable[i],
                fmt(panel_a$Mean[i]),
                fmt(panel_a$SD[i]),
                fmt2(panel_a$Min[i]),
                fmt2(panel_a$Max[i]),
                fmt0(panel_a$N[i])))
  }
}
cat("\\addlinespace[6pt]\n")
cat("\\multicolumn{6}{l}{\\textit{Panel B: Criminal Candidate Won ($T=1$)}} \\\\\n")
cat("\\addlinespace[3pt]\n")
for (i in seq_len(nrow(panel_b_treat))) {
  if (!is.na(panel_b_treat$Mean[i])) {
    cat(sprintf("%-30s & %s & %s & & & %s \\\\\n",
                panel_b_treat$Variable[i],
                fmt(panel_b_treat$Mean[i]),
                fmt(panel_b_treat$SD[i]),
                fmt0(panel_b_treat$N[i])))
  }
}
cat("\\addlinespace[6pt]\n")
cat("\\multicolumn{6}{l}{\\textit{Panel C: Criminal Candidate Lost ($T=0$)}} \\\\\n")
cat("\\addlinespace[3pt]\n")
for (i in seq_len(nrow(panel_b_ctrl))) {
  if (!is.na(panel_b_ctrl$Mean[i])) {
    cat(sprintf("%-30s & %s & %s & & & %s \\\\\n",
                panel_b_ctrl$Variable[i],
                fmt(panel_b_ctrl$Mean[i]),
                fmt(panel_b_ctrl$SD[i]),
                fmt0(panel_b_ctrl$N[i])))
  }
}
cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{minipage}{0.92\\textwidth}\n")
cat("\\vspace{4pt}\n")
cat("\\footnotesize\n")
cat("\\textit{Notes:} Sample includes elections where the top two candidates differ in criminal\n")
cat("background (one criminal, one non-criminal). NL Growth is $(NL_{post} - NL_{pre})/(NL_{pre}+1)$.\n")
cat("Vote Margin is the criminal candidate's vote share minus the non-criminal candidate's vote share;\n")
cat("positive values indicate the criminal candidate won.\n")
cat("\\end{minipage}\n")
cat("\\end{table}\n")
sink()
cat("  Wrote tab_summary_stats.tex\n")

## ============================================================================
## TABLE 2: MAIN RDD RESULTS
## ============================================================================
cat("\n── Table 2: Main RDD Results ──\n")

## Run rdrobust for three outcome specifications
outcomes <- list(
  list(y = "nl_growth",   label = "NL Growth",    covs = NULL),
  list(y = "nl_change",   label = "NL Change",    covs = NULL),
  list(y = "log_nl_post", label = "Log NL Post",  covs = "log_nl_pre")
)

main_res <- list()
for (spec in outcomes) {
  y_var <- rdd_main[[spec$y]]
  x_var <- rdd_main$margin

  ## Build covariates matrix if specified
  covs_mat <- NULL
  if (!is.null(spec$covs)) {
    covs_mat <- as.matrix(rdd_main[, spec$covs, with = FALSE])
  }

  ## Filter complete cases
  keep <- !is.na(y_var) & !is.na(x_var)
  if (!is.null(covs_mat)) keep <- keep & complete.cases(covs_mat)

  rd <- tryCatch(
    rdrobust(y = y_var[keep], x = x_var[keep], covs = covs_mat[keep, , drop = FALSE],
             kernel = "triangular", p = 1, bwselect = "mserd"),
    error = function(e) {
      cat("  Warning: rdrobust failed for", spec$y, ":", conditionMessage(e), "\n")
      NULL
    }
  )

  if (!is.null(rd)) {
    ## Extract bias-corrected robust estimates
    est   <- rd$coef["Bias-Corrected", ]
    se    <- rd$se["Robust", ]
    pval  <- rd$pv["Robust", ]
    bw    <- rd$bws["h", "left"]
    n_l   <- rd$N[1]
    n_r   <- rd$N[2]
    n_eff <- rd$N_h[1] + rd$N_h[2]

    main_res[[spec$y]] <- list(
      est = est, se = se, pval = pval, bw = bw,
      n_l = n_l, n_r = n_r, n_eff = n_eff,
      kernel = "Triangular", label = spec$label
    )
    cat(sprintf("  %s: est=%.4f, se=%.4f, p=%.4f, bw=%.2f, N_eff=%d\n",
                spec$y, est, se, pval, bw, n_eff))
  }
}

## Write LaTeX
sink(file.path(TAB_DIR, "tab_main_results.tex"))
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Effect of Electing a Criminal Politician on Local Development}\n")
cat("\\label{tab:main_results}\n")
cat("\\begin{tabular}{l ccc}\n")
cat("\\toprule\n")
cat(" & (1) & (2) & (3) \\\\\n")
cat(" & NL Growth & NL Change & Log NL Post \\\\\n")
cat("\\midrule\n")

## Treatment effect
cat("Criminal Elected")
for (spec in outcomes) {
  r <- main_res[[spec$y]]
  if (!is.null(r)) {
    cat(sprintf(" & %s%s", fmt(r$est), stars(r$pval)))
  } else {
    cat(" & ---")
  }
}
cat(" \\\\\n")

## Standard errors
cat(" ")
for (spec in outcomes) {
  r <- main_res[[spec$y]]
  if (!is.null(r)) {
    cat(sprintf(" & (%s)", fmt(r$se)))
  } else {
    cat(" & ")
  }
}
cat(" \\\\\n")

## P-value
cat("$p$-value")
for (spec in outcomes) {
  r <- main_res[[spec$y]]
  if (!is.null(r)) {
    cat(sprintf(" & [%s]", fmt(r$pval)))
  } else {
    cat(" & ")
  }
}
cat(" \\\\\n")

cat("\\addlinespace[4pt]\n")

## Bandwidth
cat("Bandwidth")
for (spec in outcomes) {
  r <- main_res[[spec$y]]
  if (!is.null(r)) {
    cat(sprintf(" & %s", fmt2(r$bw)))
  } else {
    cat(" & ")
  }
}
cat(" \\\\\n")

## N left
cat("$N$ (left)")
for (spec in outcomes) {
  r <- main_res[[spec$y]]
  if (!is.null(r)) {
    cat(sprintf(" & %s", fmt0(r$n_l)))
  } else {
    cat(" & ")
  }
}
cat(" \\\\\n")

## N right
cat("$N$ (right)")
for (spec in outcomes) {
  r <- main_res[[spec$y]]
  if (!is.null(r)) {
    cat(sprintf(" & %s", fmt0(r$n_r)))
  } else {
    cat(" & ")
  }
}
cat(" \\\\\n")

## Effective N
cat("Effective $N$")
for (spec in outcomes) {
  r <- main_res[[spec$y]]
  if (!is.null(r)) {
    cat(sprintf(" & %s", fmt0(r$n_eff)))
  } else {
    cat(" & ")
  }
}
cat(" \\\\\n")

## Kernel
cat("Kernel")
for (spec in outcomes) {
  r <- main_res[[spec$y]]
  if (!is.null(r)) {
    cat(" & Triangular")
  } else {
    cat(" & ")
  }
}
cat(" \\\\\n")

## Polynomial
cat("Polynomial order")
for (spec in outcomes) {
  cat(" & 1")
}
cat(" \\\\\n")

## Controls
cat("Controls")
cat(" & No & No & Log NL Pre")
cat(" \\\\\n")

cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{minipage}{0.92\\textwidth}\n")
cat("\\vspace{4pt}\n")
cat("\\footnotesize\n")
cat("\\textit{Notes:} Local linear RDD estimates using \\citet{calonico2014robust} bias-corrected\n")
cat("estimator with robust standard errors in parentheses and $p$-values in brackets.\n")
cat("The running variable is the vote margin of the criminal candidate.\n")
cat("MSE-optimal bandwidth selected via \\texttt{mserd}.\n")
cat("Column (3) controls for log pre-election nightlights.\n")
cat("$^{***}$ $p<0.01$, $^{**}$ $p<0.05$, $^{*}$ $p<0.1$.\n")
cat("\\end{minipage}\n")
cat("\\end{table}\n")
sink()
cat("  Wrote tab_main_results.tex\n")

## ============================================================================
## TABLE 3: MECHANISM — VILLAGE AMENITY DECOMPOSITION
## ============================================================================
cat("\n── Table 3: Mechanism (Village Amenities) ──\n")

## RESTRICT to pre-2011 elections: 2011 Census outcome is post-treatment only
## for elections held before the Census reference date (early 2011)
rdd_vd <- rdd_post08[year <= 2010 & !is.na(margin)]
cat("  Pre-2011 VD sample:", nrow(rdd_vd), "elections (years:",
    paste(sort(unique(rdd_vd$year)), collapse = ", "), ")\n")

## Define VD outcomes: only share-coded variables (0-1 scale)
## Middle school and secondary school are COUNTS, not shares — excluded
vd_specs <- list(
  list(y11 = "pc11_vd_power_all", y01 = "pc01_vd_power_all",
       label = "Electricity", use_change = FALSE),
  list(y11 = "pc11_vd_comm_bank", y01 = "pc01_vd_comm_bank",
       label = "Comm.\\ Bank", use_change = FALSE),
  list(y11 = "pc11_vd_post_off", y01 = "pc01_vd_post_off",
       label = "Post Office", use_change = FALSE)
)

mech_res <- list()
for (spec in vd_specs) {
  ## Use 2011 levels (not changes — bank/post office differ in scale across rounds)
  if (spec$y11 %in% names(rdd_vd)) {
    y_var <- rdd_vd[[spec$y11]]
    outcome_label <- spec$label
  } else {
    cat("  Skipping", spec$label, "- variable not found\n")
    next
  }

  x_var <- rdd_vd$margin
  keep <- !is.na(y_var) & !is.na(x_var)

  rd <- tryCatch(
    rdrobust(y = y_var[keep], x = x_var[keep],
             kernel = "triangular", p = 1, bwselect = "mserd"),
    error = function(e) {
      cat("  Warning: rdrobust failed for", spec$label, ":", conditionMessage(e), "\n")
      NULL
    }
  )

  if (!is.null(rd)) {
    est   <- rd$coef["Bias-Corrected", ]
    se    <- rd$se["Robust", ]
    pval  <- rd$pv["Robust", ]
    bw    <- rd$bws["h", "left"]
    n_eff <- rd$N_h[1] + rd$N_h[2]

    mech_res[[spec$label]] <- list(
      est = est, se = se, pval = pval, bw = bw, n_eff = n_eff,
      outcome_label = outcome_label
    )
    cat(sprintf("  %s: est=%.4f, p=%.4f, bw=%.2f\n",
                spec$label, est, pval, bw))
  }
}

## Write LaTeX
sink(file.path(TAB_DIR, "tab_mechanism.tex"))
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Mechanism: Effect on Village Amenities}\n")
cat("\\label{tab:mechanism}\n")

ncols <- length(mech_res)
cat(sprintf("\\begin{tabular}{l %s}\n", paste(rep("c", ncols), collapse = "")))
cat("\\toprule\n")

## Header row with column numbers
cat(" ")
for (j in seq_along(mech_res)) {
  cat(sprintf(" & (%d)", j))
}
cat(" \\\\\n")

## Outcome labels
cat(" ")
for (nm in names(mech_res)) {
  cat(sprintf(" & %s", mech_res[[nm]]$outcome_label))
}
cat(" \\\\\n")
cat("\\midrule\n")

## Estimates
cat("Criminal Elected")
for (nm in names(mech_res)) {
  r <- mech_res[[nm]]
  cat(sprintf(" & %s%s", fmt(r$est), stars(r$pval)))
}
cat(" \\\\\n")

## SE
cat(" ")
for (nm in names(mech_res)) {
  r <- mech_res[[nm]]
  cat(sprintf(" & (%s)", fmt(r$se)))
}
cat(" \\\\\n")

## P-value
cat("$p$-value")
for (nm in names(mech_res)) {
  r <- mech_res[[nm]]
  cat(sprintf(" & [%s]", fmt(r$pval)))
}
cat(" \\\\\n")

cat("\\addlinespace[4pt]\n")

## Bandwidth
cat("Bandwidth")
for (nm in names(mech_res)) {
  r <- mech_res[[nm]]
  cat(sprintf(" & %s", fmt2(r$bw)))
}
cat(" \\\\\n")

## Effective N
cat("Effective $N$")
for (nm in names(mech_res)) {
  r <- mech_res[[nm]]
  cat(sprintf(" & %s", fmt0(r$n_eff)))
}
cat(" \\\\\n")

## Kernel
cat("Kernel")
for (nm in names(mech_res)) {
  cat(" & Tri.")
}
cat(" \\\\\n")

cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{minipage}{0.92\\textwidth}\n")
cat("\\vspace{4pt}\n")
cat("\\footnotesize\n")
cat("\\textit{Notes:} RDD estimates for village-level amenity outcomes from the 2011 Census\n")
cat("Village Directory. Outcomes are share-coded (0--1 scale): the fraction of villages\n")
cat("with each amenity. Sample restricted to elections held in 2008--2010 to ensure\n")
cat("the 2011 Census outcome is measured post-treatment. Middle school and secondary\n")
cat("school outcomes are excluded because the Village Directory codes them as counts\n")
cat("rather than shares. Local linear estimation with MSE-optimal bandwidth.\n")
cat("$^{***}$ $p<0.01$, $^{**}$ $p<0.05$, $^{*}$ $p<0.1$.\n")
cat("\\end{minipage}\n")
cat("\\end{table}\n")
sink()
cat("  Wrote tab_mechanism.tex\n")

## ============================================================================
## TABLE 4: COVARIATE BALANCE
## ============================================================================
cat("\n── Table 4: Covariate Balance ──\n")

## Covariates to test
bal_vars <- list(
  list(var = "turnout_percentage", label = "Turnout (\\%)"),
  list(var = "n_cand",             label = "No.\\ Candidates"),
  list(var = "valid_votes",        label = "Valid Votes"),
  list(var = "electors",           label = "Total Electors"),
  list(var = "log_pop_01",         label = "Log Population (2001)"),
  list(var = "lit_rate_01",        label = "Literacy Rate (2001)"),
  list(var = "sc_share_01",        label = "SC Share (2001)"),
  list(var = "st_share_01",        label = "ST Share (2001)"),
  list(var = "nl_pre",             label = "Pre-Election NL")
)

bal_res <- list()
for (spec in bal_vars) {
  if (!(spec$var %in% names(rdd_main))) {
    cat("  Skipping", spec$var, "- not in data\n")
    next
  }

  y_var <- rdd_main[[spec$var]]
  x_var <- rdd_main$margin
  keep <- !is.na(y_var) & !is.na(x_var)

  rd <- tryCatch(
    rdrobust(y = y_var[keep], x = x_var[keep],
             kernel = "triangular", p = 1, bwselect = "mserd"),
    error = function(e) {
      cat("  Warning: balance test failed for", spec$var, "\n")
      NULL
    }
  )

  if (!is.null(rd)) {
    est  <- rd$coef["Bias-Corrected", ]
    se   <- rd$se["Robust", ]
    pval <- rd$pv["Robust", ]
    bw   <- rd$bws["h", "left"]
    n_eff <- rd$N_h[1] + rd$N_h[2]

    bal_res[[spec$var]] <- list(
      label = spec$label, est = est, se = se, pval = pval,
      bw = bw, n_eff = n_eff
    )
    cat(sprintf("  %s: est=%.4f, p=%.4f\n", spec$var, est, pval))
  }
}

## Write LaTeX
sink(file.path(TAB_DIR, "tab_covariate_balance.tex"))
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Covariate Balance at the Threshold}\n")
cat("\\label{tab:covariate_balance}\n")
cat("\\begin{tabular}{l ccccc}\n")
cat("\\toprule\n")
cat("Covariate & RDD Estimate & Robust SE & $p$-value & Bandwidth & Eff.\\ $N$ \\\\\n")
cat("\\midrule\n")

for (nm in names(bal_res)) {
  r <- bal_res[[nm]]
  cat(sprintf("%-30s & %s%s & %s & %s & %s & %s \\\\\n",
              r$label,
              fmt(r$est), stars(r$pval),
              fmt(r$se),
              fmt(r$pval),
              fmt2(r$bw),
              fmt0(r$n_eff)))
}

cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{minipage}{0.92\\textwidth}\n")
cat("\\vspace{4pt}\n")
cat("\\footnotesize\n")
cat("\\textit{Notes:} Each row reports a separate RDD regression of the covariate on the\n")
cat("criminal-candidate vote margin, using local linear estimation with MSE-optimal bandwidth.\n")
cat("Bias-corrected estimates with robust standard errors.\n")
cat("No significant differences indicate the RDD design is valid.\n")
cat("$^{***}$ $p<0.01$, $^{**}$ $p<0.05$, $^{*}$ $p<0.1$.\n")
cat("\\end{minipage}\n")
cat("\\end{table}\n")
sink()
cat("  Wrote tab_covariate_balance.tex\n")

## ============================================================================
## TABLE 5: ROBUSTNESS CHECKS
## ============================================================================
cat("\n── Table 5: Robustness Checks ──\n")

## Use NL growth as the primary outcome throughout
y_rob <- rdd_main$nl_growth
x_rob <- rdd_main$margin
keep_rob <- !is.na(y_rob) & !is.na(x_rob)
y_rob <- y_rob[keep_rob]
x_rob <- x_rob[keep_rob]

## Get baseline bandwidth for multiplier checks
rd_base <- rdrobust(y = y_rob, x = x_rob,
                    kernel = "triangular", p = 1, bwselect = "mserd")
h_base <- rd_base$bws["h", "left"]

## Panel A: Bandwidth sensitivity
bw_mults <- c(0.50, 0.75, 1.00, 1.25, 1.50, 2.00)
panel_a <- list()
for (mult in bw_mults) {
  h_use <- h_base * mult
  rd <- tryCatch(
    rdrobust(y = y_rob, x = x_rob, h = h_use,
             kernel = "triangular", p = 1),
    error = function(e) NULL
  )
  if (!is.null(rd)) {
    panel_a[[as.character(mult)]] <- list(
      mult = mult,
      est   = rd$coef["Bias-Corrected", ],
      se    = rd$se["Robust", ],
      pval  = rd$pv["Robust", ],
      bw    = h_use,
      n_eff = rd$N_h[1] + rd$N_h[2]
    )
    cat(sprintf("  BW x%.2f: est=%.4f, p=%.4f\n",
                mult, rd$coef["Bias-Corrected", ], rd$pv["Robust", ]))
  }
}

## Panel B: Polynomial order
poly_orders <- c(1, 2)
panel_b <- list()
for (p_ord in poly_orders) {
  rd <- tryCatch(
    rdrobust(y = y_rob, x = x_rob,
             kernel = "triangular", p = p_ord, bwselect = "mserd"),
    error = function(e) NULL
  )
  if (!is.null(rd)) {
    panel_b[[as.character(p_ord)]] <- list(
      p_ord = p_ord,
      est   = rd$coef["Bias-Corrected", ],
      se    = rd$se["Robust", ],
      pval  = rd$pv["Robust", ],
      bw    = rd$bws["h", "left"],
      n_eff = rd$N_h[1] + rd$N_h[2]
    )
    cat(sprintf("  p=%d: est=%.4f, p=%.4f\n",
                p_ord, rd$coef["Bias-Corrected", ], rd$pv["Robust", ]))
  }
}

## Panel C: Kernel
kernels <- c("triangular", "uniform", "epanechnikov")
panel_c <- list()
for (k in kernels) {
  rd <- tryCatch(
    rdrobust(y = y_rob, x = x_rob,
             kernel = k, p = 1, bwselect = "mserd"),
    error = function(e) NULL
  )
  if (!is.null(rd)) {
    ## Capitalize kernel name for display
    k_disp <- paste0(toupper(substr(k, 1, 1)), substr(k, 2, nchar(k)))
    panel_c[[k]] <- list(
      kernel = k_disp,
      est    = rd$coef["Bias-Corrected", ],
      se     = rd$se["Robust", ],
      pval   = rd$pv["Robust", ],
      bw     = rd$bws["h", "left"],
      n_eff  = rd$N_h[1] + rd$N_h[2]
    )
    cat(sprintf("  Kernel %s: est=%.4f, p=%.4f\n",
                k, rd$coef["Bias-Corrected", ], rd$pv["Robust", ]))
  }
}

## Panel D: Donut hole
donut_cuts <- c(0.5, 1.0, 1.5, 2.0)
panel_d <- list()
for (dc in donut_cuts) {
  keep_donut <- abs(x_rob) >= dc
  if (sum(keep_donut) < 50) {
    cat(sprintf("  Donut %.1f: too few obs (%d), skipping\n", dc, sum(keep_donut)))
    next
  }
  rd <- tryCatch(
    rdrobust(y = y_rob[keep_donut], x = x_rob[keep_donut],
             kernel = "triangular", p = 1, bwselect = "mserd"),
    error = function(e) NULL
  )
  if (!is.null(rd)) {
    panel_d[[as.character(dc)]] <- list(
      donut = dc,
      est   = rd$coef["Bias-Corrected", ],
      se    = rd$se["Robust", ],
      pval  = rd$pv["Robust", ],
      bw    = rd$bws["h", "left"],
      n_eff = rd$N_h[1] + rd$N_h[2]
    )
    cat(sprintf("  Donut |m|>=%.1f: est=%.4f, p=%.4f\n",
                dc, rd$coef["Bias-Corrected", ], rd$pv["Robust", ]))
  }
}

## Write LaTeX
sink(file.path(TAB_DIR, "tab_robustness.tex"))
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Robustness Checks: Effect on Nightlight Growth}\n")
cat("\\label{tab:robustness}\n")
cat("\\small\n")
cat("\\begin{tabular}{l cccccc}\n")
cat("\\toprule\n")
cat("Specification & Estimate & Robust SE & $p$-value & Bandwidth & Eff.\\ $N$ \\\\\n")
cat("\\midrule\n")

## Panel A
cat("\\multicolumn{6}{l}{\\textit{Panel A: Bandwidth Sensitivity}} \\\\\n")
cat("\\addlinespace[3pt]\n")
for (nm in names(panel_a)) {
  r <- panel_a[[nm]]
  cat(sprintf("$h = %.2f \\times h^{*}$ ($h=%.1f$) & %s%s & %s & %s & %s & %s \\\\\n",
              r$mult, r$bw,
              fmt(r$est), stars(r$pval),
              fmt(r$se), fmt(r$pval),
              fmt2(r$bw), fmt0(r$n_eff)))
}

## Panel B
cat("\\addlinespace[6pt]\n")
cat("\\multicolumn{6}{l}{\\textit{Panel B: Polynomial Order}} \\\\\n")
cat("\\addlinespace[3pt]\n")
for (nm in names(panel_b)) {
  r <- panel_b[[nm]]
  cat(sprintf("$p = %d$ & %s%s & %s & %s & %s & %s \\\\\n",
              r$p_ord,
              fmt(r$est), stars(r$pval),
              fmt(r$se), fmt(r$pval),
              fmt2(r$bw), fmt0(r$n_eff)))
}

## Panel C
cat("\\addlinespace[6pt]\n")
cat("\\multicolumn{6}{l}{\\textit{Panel C: Kernel Function}} \\\\\n")
cat("\\addlinespace[3pt]\n")
for (nm in names(panel_c)) {
  r <- panel_c[[nm]]
  cat(sprintf("%s & %s%s & %s & %s & %s & %s \\\\\n",
              r$kernel,
              fmt(r$est), stars(r$pval),
              fmt(r$se), fmt(r$pval),
              fmt2(r$bw), fmt0(r$n_eff)))
}

## Panel D
cat("\\addlinespace[6pt]\n")
cat("\\multicolumn{6}{l}{\\textit{Panel D: Donut Hole (Excluding $|\\text{margin}| < c$)}} \\\\\n")
cat("\\addlinespace[3pt]\n")
for (nm in names(panel_d)) {
  r <- panel_d[[nm]]
  cat(sprintf("$c = %.1f$ & %s%s & %s & %s & %s & %s \\\\\n",
              r$donut,
              fmt(r$est), stars(r$pval),
              fmt(r$se), fmt(r$pval),
              fmt2(r$bw), fmt0(r$n_eff)))
}

cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{minipage}{0.92\\textwidth}\n")
cat("\\vspace{4pt}\n")
cat("\\footnotesize\n")
cat("\\textit{Notes:} All specifications report bias-corrected RDD estimates with robust\n")
cat("standard errors for the effect of electing a criminal politician on nightlight growth.\n")
cat("Panel A varies the bandwidth around the MSE-optimal $h^{*}$.\n")
cat("Panel B compares local linear ($p=1$) and local quadratic ($p=2$) polynomial fits.\n")
cat("Panel C varies the kernel weighting function.\n")
cat("Panel D implements donut-hole RDD by excluding observations within $c$ percentage\n")
cat("points of the threshold.\n")
cat("$^{***}$ $p<0.01$, $^{**}$ $p<0.05$, $^{*}$ $p<0.1$.\n")
cat("\\end{minipage}\n")
cat("\\end{table}\n")
sink()
cat("  Wrote tab_robustness.tex\n")

## ============================================================================
## TABLE 6: HETEROGENEITY
## ============================================================================
cat("\n── Table 6: Heterogeneity ──\n")

## Prepare subgroup indicators
## A. Crime type: major vs minor
## In case1, the criminal is the winner; treatment=1 means criminal won
## w_major indicates whether the winning criminal has major charges
## For treatment=0, the criminal is the runner-up: use r_major
rdd_main[, crim_major := fifelse(treatment == 1, w_major, r_major)]

## B. BIMARU states
bimaru_states <- c("bihar", "madhya pradesh", "rajasthan", "uttar pradesh",
                   "chhattisgarh", "jharkhand", "uttarakhand")
rdd_main[, bimaru := fifelse(tolower(eci_state_name) %in% bimaru_states, 1L, 0L)]

## C. Reservation: GEN vs SC/ST
rdd_main[, reserved := fifelse(constituency_type %in% c("SC", "ST"), 1L, 0L)]

## Define heterogeneity specifications
het_specs <- list(
  ## Crime type
  list(label = "Major Crimes", subset_expr = quote(crim_major == 1)),
  list(label = "Minor Crimes Only", subset_expr = quote(crim_major == 0)),
  ## State development
  list(label = "BIMARU States", subset_expr = quote(bimaru == 1)),
  list(label = "Non-BIMARU States", subset_expr = quote(bimaru == 0)),
  ## Reservation
  list(label = "General Seats", subset_expr = quote(reserved == 0)),
  list(label = "Reserved Seats (SC/ST)", subset_expr = quote(reserved == 1))
)

het_res <- list()
panel_labels <- list(
  "A" = "Crime Severity",
  "B" = "State Development",
  "C" = "Seat Reservation"
)
panel_assign <- c("A", "A", "B", "B", "C", "C")

for (i in seq_along(het_specs)) {
  spec <- het_specs[[i]]
  dt_sub <- rdd_main[eval(spec$subset_expr)]
  dt_sub <- dt_sub[!is.na(nl_growth) & !is.na(margin)]

  if (nrow(dt_sub) < 30) {
    cat(sprintf("  %s: only %d obs, skipping\n", spec$label, nrow(dt_sub)))
    het_res[[spec$label]] <- list(
      label = spec$label, est = NA, se = NA, pval = NA,
      bw = NA, n_eff = NA, n_tot = nrow(dt_sub),
      panel = panel_assign[i]
    )
    next
  }

  rd <- tryCatch(
    rdrobust(y = dt_sub$nl_growth, x = dt_sub$margin,
             kernel = "triangular", p = 1, bwselect = "mserd"),
    error = function(e) {
      cat(sprintf("  %s: rdrobust failed: %s\n", spec$label, conditionMessage(e)))
      NULL
    }
  )

  if (!is.null(rd)) {
    het_res[[spec$label]] <- list(
      label  = spec$label,
      est    = rd$coef["Bias-Corrected", ],
      se     = rd$se["Robust", ],
      pval   = rd$pv["Robust", ],
      bw     = rd$bws["h", "left"],
      n_eff  = rd$N_h[1] + rd$N_h[2],
      n_tot  = nrow(dt_sub),
      panel  = panel_assign[i]
    )
    cat(sprintf("  %s: est=%.4f, p=%.4f, N=%d\n",
                spec$label, rd$coef["Bias-Corrected", ],
                rd$pv["Robust", ], nrow(dt_sub)))
  } else {
    het_res[[spec$label]] <- list(
      label = spec$label, est = NA, se = NA, pval = NA,
      bw = NA, n_eff = NA, n_tot = nrow(dt_sub),
      panel = panel_assign[i]
    )
  }
}

## Write LaTeX
sink(file.path(TAB_DIR, "tab_heterogeneity.tex"))
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Heterogeneous Effects on Nightlight Growth}\n")
cat("\\label{tab:heterogeneity}\n")
cat("\\begin{tabular}{l ccccc}\n")
cat("\\toprule\n")
cat("Subgroup & Estimate & Robust SE & $p$-value & Bandwidth & Eff.\\ $N$ \\\\\n")
cat("\\midrule\n")

current_panel <- ""
for (nm in names(het_res)) {
  r <- het_res[[nm]]
  ## Insert panel header
  if (r$panel != current_panel) {
    if (current_panel != "") cat("\\addlinespace[6pt]\n")
    cat(sprintf("\\multicolumn{6}{l}{\\textit{Panel %s: %s}} \\\\\n",
                r$panel, panel_labels[[r$panel]]))
    cat("\\addlinespace[3pt]\n")
    current_panel <- r$panel
  }
  if (!is.na(r$est)) {
    cat(sprintf("%-30s & %s%s & %s & %s & %s & %s \\\\\n",
                r$label,
                fmt(r$est), stars(r$pval),
                fmt(r$se), fmt(r$pval),
                fmt2(r$bw), fmt0(r$n_eff)))
  } else {
    cat(sprintf("%-30s & --- & --- & --- & --- & %s \\\\\n",
                r$label, fmt0(r$n_tot)))
  }
}

cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{minipage}{0.92\\textwidth}\n")
cat("\\vspace{4pt}\n")
cat("\\footnotesize\n")
cat("\\textit{Notes:} Each row reports a separate RDD regression of nightlight growth on the\n")
cat("criminal-candidate vote margin for the indicated subgroup.\n")
cat("Panel A splits by crime severity (major crimes include murder, kidnapping,\n")
cat("extortion per ADR classification).\n")
cat("Panel B compares BIMARU states (Bihar, MP, Rajasthan, UP, and successor states)\n")
cat("with non-BIMARU states.\n")
cat("Panel C compares General category seats with those reserved for SC/ST.\n")
cat("All specifications use local linear estimation with MSE-optimal bandwidth.\n")
cat("$^{***}$ $p<0.01$, $^{**}$ $p<0.05$, $^{*}$ $p<0.1$.\n")
cat("\\end{minipage}\n")
cat("\\end{table}\n")
sink()
cat("  Wrote tab_heterogeneity.tex\n")

## ============================================================================
## SAVE RESULTS FOR DOWNSTREAM USE
## ============================================================================
cat("\n── Saving computed results ──\n")

all_results <- list(
  main      = main_res,
  mechanism = mech_res,
  balance   = bal_res,
  robustness = list(
    bandwidth  = panel_a,
    polynomial = panel_b,
    kernel     = panel_c,
    donut      = panel_d
  ),
  heterogeneity = het_res,
  baseline_bw   = h_base
)

saveRDS(all_results, file.path(DATA_DIR, "main_results.rds"))

## Also save robustness separately
saveRDS(all_results$robustness, file.path(DATA_DIR, "robustness_results.rds"))

cat("  Saved main_results.rds and robustness_results.rds\n")

## ── Summary ─────────────────────────────────────────────────────────────────
cat("\n========================================\n")
cat("TABLE GENERATION COMPLETE\n")
cat("========================================\n")
cat("Tables written to:", TAB_DIR, "\n")
cat("  1. tab_summary_stats.tex\n")
cat("  2. tab_main_results.tex\n")
cat("  3. tab_mechanism.tex\n")
cat("  4. tab_covariate_balance.tex\n")
cat("  5. tab_robustness.tex\n")
cat("  6. tab_heterogeneity.tex\n")
