# ==============================================================================
# 06_tables.R — All tables
# APEP-0468: Where Does Workfare Work?
# ==============================================================================

source("00_packages.R")

data_dir <- "../data"
tab_dir <- "../tables"
dir.create(tab_dir, showWarnings = FALSE, recursive = TRUE)

panel <- readRDS(file.path(data_dir, "analysis_panel.rds"))
census <- readRDS(file.path(data_dir, "census_change.rds"))

# ==============================================================================
# Table 1: Summary Statistics by Phase
# ==============================================================================
cat("Table 1: Summary statistics...\n")

# Baseline (year 2000) summary
baseline <- panel[year == 2000]

summ_by_phase <- baseline[, .(
  Districts = .N,
  `Population (2001)` = sprintf("%.0f", mean(pop_2001, na.rm = TRUE)),
  `Log Nightlights` = sprintf("%.3f", mean(log_light, na.rm = TRUE)),
  `SC/ST Share` = sprintf("%.3f", mean(sc_st_share, na.rm = TRUE)),
  `Literacy Rate` = sprintf("%.3f", mean(lit_rate, na.rm = TRUE)),
  `Ag. Labor Share` = sprintf("%.3f", mean(ag_labor_share, na.rm = TRUE)),
  `Cultivator Share` = sprintf("%.3f", mean(cultivator_share, na.rm = TRUE)),
  `Avg. Rainfall (mm)` = sprintf("%.1f", mean(avg_rainfall, na.rm = TRUE)),
  `Backwardness Index` = sprintf("%.3f", mean(backwardness_index, na.rm = TRUE))
), by = mgnrega_phase]

# Overall
summ_all <- baseline[, .(
  mgnrega_phase = 0L,
  Districts = .N,
  `Population (2001)` = sprintf("%.0f", mean(pop_2001, na.rm = TRUE)),
  `Log Nightlights` = sprintf("%.3f", mean(log_light, na.rm = TRUE)),
  `SC/ST Share` = sprintf("%.3f", mean(sc_st_share, na.rm = TRUE)),
  `Literacy Rate` = sprintf("%.3f", mean(lit_rate, na.rm = TRUE)),
  `Ag. Labor Share` = sprintf("%.3f", mean(ag_labor_share, na.rm = TRUE)),
  `Cultivator Share` = sprintf("%.3f", mean(cultivator_share, na.rm = TRUE)),
  `Avg. Rainfall (mm)` = sprintf("%.1f", mean(avg_rainfall, na.rm = TRUE)),
  `Backwardness Index` = sprintf("%.3f", mean(backwardness_index, na.rm = TRUE))
)]

# Ensure phases are in correct order before combining
setorder(summ_by_phase, mgnrega_phase)
summ_tab <- rbind(summ_by_phase, summ_all)
summ_tab[, Phase := ifelse(mgnrega_phase == 0, "All",
                            paste("Phase", mgnrega_phase))]

# Transpose for LaTeX
summ_mat <- t(as.matrix(summ_tab[, -c("mgnrega_phase")]))
colnames(summ_mat) <- summ_mat["Phase", ]
summ_mat <- summ_mat[rownames(summ_mat) != "Phase", ]

# Verify column order matches header (Phase 1 should have ~200 districts)
stopifnot(colnames(summ_mat)[1] == "Phase 1")
stopifnot(colnames(summ_mat)[4] == "All")

# Write LaTeX table using named columns to prevent ordering bugs
sink(file.path(tab_dir, "tab1_summary_stats.tex"))
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Summary Statistics by MGNREGA Phase}\n")
cat("\\label{tab:summary}\n")
cat("\\begin{tabular}{lcccc}\n")
cat("\\hline\\hline\n")
cat(" & Phase 1 & Phase 2 & Phase 3 & All \\\\\n")
cat("\\hline\n")
for (rn in rownames(summ_mat)) {
  cat(sprintf("%s & %s & %s & %s & %s \\\\\n",
              rn, summ_mat[rn, "Phase 1"], summ_mat[rn, "Phase 2"],
              summ_mat[rn, "Phase 3"], summ_mat[rn, "All"]))
}
cat("\\hline\\hline\n")
cat("\\end{tabular}\n")
cat("\\begin{tablenotes}[flushleft]\\small\n")
cat("\\item \\textit{Notes:} Means of baseline district characteristics by MGNREGA phase assignment. Nightlights measured in year 2000; demographic and economic variables from Census 2001. Phase I (200 most backward districts) began in February 2006; Phase II (next 130) in April 2007; Phase III (remaining 254) in April 2008. Backwardness index is the sum of standardized SC/ST share, agricultural labor share, and inverse literacy rate.\n")
cat("\\end{tablenotes}\n")
cat("\\end{table}\n")
sink()
cat("  Saved tab1_summary_stats.tex\n")

# ==============================================================================
# Table 2: Main Results
# ==============================================================================
cat("Table 2: Main results...\n")

# Helper for significance stars
get_stars <- function(b, s) {
  tstat <- abs(b / s)
  if (tstat > 2.576) return("***")
  if (tstat > 1.96) return("**")
  if (tstat > 1.645) return("*")
  return("")
}

# Load results
twfe_res <- tryCatch(readRDS(file.path(data_dir, "twfe_results.rds")), error = function(e) NULL)
cs_agg <- tryCatch(readRDS(file.path(data_dir, "cs_aggregations.rds")), error = function(e) NULL)
sa_res <- tryCatch(readRDS(file.path(data_dir, "sa_results.rds")), error = function(e) NULL)
sxy_res <- tryCatch(readRDS(file.path(data_dir, "sxy_results.rds")), error = function(e) NULL)

# Extract coefficients
b1 <- coef(twfe_res$base)["treated"]; s1 <- se(twfe_res$base)["treated"]
b2 <- coef(twfe_res$ctrl)["treated"]; s2 <- se(twfe_res$ctrl)["treated"]
b3 <- cs_agg$simple$overall.att; s3 <- cs_agg$simple$overall.se
# Extract Sun-Abraham aggregated ATT (cohort-size-weighted average of post-treatment effects)
# Note: agg = "ATT" is a valid argument for fixest sunab objects
sa_summ <- summary(sa_res, agg = "ATT")
b4 <- sa_summ$coeftable[1, 1]; s4 <- sa_summ$coeftable[1, 2]

sink(file.path(tab_dir, "tab2_main_results.tex"))
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Effect of MGNREGA on District Nightlights}\n")
cat("\\label{tab:main}\n")
cat("\\begin{tabular}{lcccc}\n")
cat("\\hline\\hline\n")
cat(" & (1) & (2) & (3) & (4) \\\\\n")
cat(" & TWFE & TWFE & CS-DiD & Sun-Abraham \\\\\n")
cat("\\hline\n")
cat(sprintf("MGNREGA (Post) & %.4f%s & %.4f%s & %.4f%s & %.4f%s \\\\\n",
            b1, get_stars(b1, s1), b2, get_stars(b2, s2),
            b3, get_stars(b3, s3), b4, get_stars(b4, s4)))
cat(sprintf(" & (%.4f) & (%.4f) & (%.4f) & (%.4f) \\\\\n", s1, s2, s3, s4))
cat("\\hline\n")
cat("District FE & Yes & Yes & Yes & Yes \\\\\n")
cat("Year FE & Yes & Yes & Yes & Yes \\\\\n")
cat("Rainfall controls & No & Yes & No & No \\\\\n")
cat("Estimator & TWFE & TWFE & CS-DiD (DR) & IW \\\\\n")
cat(sprintf("Observations & %s & %s & %s & %s \\\\\n",
            format(nobs(twfe_res$base), big.mark = ","),
            format(nobs(twfe_res$ctrl), big.mark = ","),
            format(nobs(twfe_res$base), big.mark = ","),
            format(nobs(sa_res), big.mark = ",")))
cat("Districts & 584 & 584 & 584 & 584 \\\\\n")
cat("\\hline\\hline\n")
cat("\\end{tabular}\n")
cat("\\begin{tablenotes}[flushleft]\\small\n")
cat("\\item \\textit{Notes:} Dependent variable is log(total nightlights + 1). Column (1): Two-way fixed effects with district and year fixed effects. Column (2): TWFE with rainfall tercile controls. Column (3): Callaway and Sant'Anna (2021) doubly-robust estimator with not-yet-treated control group. Column (4): Sun and Abraham (2021) interaction-weighted estimator. Standard errors clustered at the state level for TWFE (columns 1--2) and at the district level for CS-DiD (column 3) and Sun-Abraham (column 4). *** $p<0.01$, ** $p<0.05$, * $p<0.1$.\n")
cat("\\end{tablenotes}\n")
cat("\\end{table}\n")
sink()
cat("  Saved tab2_main_results.tex\n")

# ==============================================================================
# Table 3: Heterogeneity
# ==============================================================================
cat("Table 3: Heterogeneity...\n")

het_list <- list()
for (var in c("rain_tercile", "ag_labor_tercile", "scst_tercile", "light_tercile")) {
  for (lev in levels(panel[[var]])) {
    sub <- panel[get(var) == lev]
    if (nrow(sub) > 100) {
      m <- feols(log_light ~ treated | dist_id_11 + year,
                 data = sub, cluster = ~pc01_state_id)
      het_list[[paste(var, lev)]] <- data.table(
        dimension = var, level = lev,
        att = coef(m)["treated"], se = se(m)["treated"],
        n_dist = uniqueN(sub$dist_id_11), n_obs = nrow(sub)
      )
    }
  }
}
het_tab <- rbindlist(het_list)

sink(file.path(tab_dir, "tab3_heterogeneity.tex"))
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Heterogeneous Effects by Baseline District Characteristics}\n")
cat("\\label{tab:heterogeneity}\n")
cat("\\begin{tabular}{llccc}\n")
cat("\\hline\\hline\n")
cat("Dimension & Tercile & ATT & SE & Districts \\\\\n")
cat("\\hline\n")

dim_labels <- c(
  rain_tercile = "Rainfall",
  ag_labor_tercile = "Ag. Labor Share",
  scst_tercile = "SC/ST Share",
  light_tercile = "Baseline Luminosity"
)

for (d in unique(het_tab$dimension)) {
  sub <- het_tab[dimension == d]
  for (i in 1:nrow(sub)) {
    label <- if (i == 1) dim_labels[d] else ""
    stars <- get_stars(sub$att[i], sub$se[i])
    cat(sprintf("%s & %s & %.4f%s & (%.4f) & %d \\\\\n",
                label, sub$level[i], sub$att[i], stars, sub$se[i], sub$n_dist[i]))
  }
  if (d != tail(unique(het_tab$dimension), 1)) cat("\\addlinespace\n")
}

cat("\\addlinespace\n")
cat(sprintf("Observations & \\multicolumn{4}{c}{%s total; per tercile $\\approx$ %s} \\\\\n",
            format(nrow(panel), big.mark = ","),
            format(round(nrow(panel) / 3), big.mark = ",")))
cat(sprintf("Districts & \\multicolumn{4}{c}{%d total; per tercile $\\approx$ %d} \\\\\n",
            uniqueN(panel$dist_id_11),
            round(uniqueN(panel$dist_id_11) / 3)))

cat("\\hline\\hline\n")
cat("\\end{tabular}\n")
cat("\\begin{tablenotes}[flushleft]\\small\n")
cat("\\item \\textit{Notes:} Each cell reports the TWFE estimate of MGNREGA's effect on log nightlights for the indicated subgroup. All specifications include district and year fixed effects. Standard errors clustered at the state level. Terciles defined by baseline (year 2000) district characteristics. *** $p<0.01$, ** $p<0.05$, * $p<0.1$.\n")
cat("\\end{tablenotes}\n")
cat("\\end{table}\n")
sink()
cat("  Saved tab3_heterogeneity.tex\n")

# ==============================================================================
# Table 4: Census Mechanism
# ==============================================================================
cat("Table 4: Census mechanism...\n")

mech_res <- tryCatch(readRDS(file.path(data_dir, "mechanism_results.rds")),
                      error = function(e) NULL)

if (!is.null(mech_res)) {
  sink(file.path(tab_dir, "tab4_mechanism.tex"))
  cat("\\begin{table}[htbp]\n")
  cat("\\centering\n")
  cat("\\caption{MGNREGA and Structural Transformation (Census 2001-2011)}\n")
  cat("\\label{tab:mechanism}\n")
  cat("\\begin{tabular}{lccc}\n")
  cat("\\hline\\hline\n")
  cat(" & (1) & (2) & (3) \\\\\n")
  cat(" & $\\Delta$ Ag. Labor & Pop. Growth & Female LFPR \\\\\n")
  cat("\\hline\n")

  for (phase in c(1, 2)) {
    pname <- paste0("mgnrega_phase::", phase)
    for (i in 1:3) {
      m <- mech_res[[i]]
      ct <- coeftable(m)
      if (pname %in% rownames(ct)) {
        b <- ct[pname, 1]
        s <- ct[pname, 2]
        stars <- get_stars(b, s)
        if (i == 1) cat(sprintf("Phase %d & %.4f%s & ", phase, b, stars))
        else if (i == 2) cat(sprintf("%.4f%s & ", b, stars))
        else cat(sprintf("%.4f%s \\\\\n", b, stars))
      }
    }
    # SEs
    for (i in 1:3) {
      m <- mech_res[[i]]
      ct <- coeftable(m)
      if (pname %in% rownames(ct)) {
        s <- ct[pname, 2]
        if (i == 1) cat(sprintf(" & (%.4f) & ", s))
        else if (i == 2) cat(sprintf("(%.4f) & ", s))
        else cat(sprintf("(%.4f) \\\\\n", s))
      }
    }
  }

  cat("\\hline\n")
  cat("Controls & Backward. & Backward. & Backward.+Lit+SC/ST \\\\\n")
  cat(sprintf("Observations & %d & %d & %d \\\\\n",
              nobs(mech_res$mech1), nobs(mech_res$mech2), nobs(mech_res$mech3)))
  cat("\\hline\\hline\n")
  cat("\\end{tabular}\n")
  cat("\\begin{tablenotes}[flushleft]\\small\n")
  cat("\\item \\textit{Notes:} Cross-sectional regressions comparing Census 2001-2011 changes across MGNREGA phases. Phase III is the omitted category. Column (1): Change in agricultural labor share of workers. Column (2): Population growth rate. Column (3): Female labor force participation rate in 2011. Standard errors clustered at the state level. *** $p<0.01$, ** $p<0.05$, * $p<0.1$.\n")
  cat("\\end{tablenotes}\n")
  cat("\\end{table}\n")
  sink()
  cat("  Saved tab4_mechanism.tex\n")
}

# ==============================================================================
# Table 5: Robustness
# ==============================================================================
cat("Table 5: Robustness...\n")

rob_misc <- tryCatch(readRDS(file.path(data_dir, "robustness_misc.rds")), error = function(e) NULL)
dose_res <- tryCatch(readRDS(file.path(data_dir, "dose_response.rds")), error = function(e) NULL)

if (!is.null(rob_misc) && !is.null(sxy_res)) {
  sink(file.path(tab_dir, "tab5_robustness.tex"))
  cat("\\begin{table}[htbp]\n")
  cat("\\centering\n")
  cat("\\caption{Robustness Checks}\n")
  cat("\\label{tab:robustness}\n")
  cat("\\begin{tabular}{lccc}\n")
  cat("\\hline\\hline\n")
  cat(" & (1) & (2) & (3) \\\\\n")
  cat(" & State$\\times$Year FE & District Cluster & Placebo (2003) \\\\\n")
  cat("\\hline\n")

  # Col 1: State × Year FE
  if (!is.null(sxy_res)) {
    b1 <- coef(sxy_res$base)["treated"]
    s1 <- se(sxy_res$base)["treated"]
    stars1 <- get_stars(b1, s1)
  }
  # Col 2: District clustering
  b2 <- coef(rob_misc$dist_cluster)["treated"]
  s2 <- se(rob_misc$dist_cluster)["treated"]
  stars2 <- get_stars(b2, s2)
  # Col 3: Placebo
  b3 <- coef(rob_misc$placebo)["fake_treat"]
  s3 <- se(rob_misc$placebo)["fake_treat"]
  stars3 <- get_stars(b3, s3)

  cat(sprintf("MGNREGA (Post) & %.4f%s & %.4f%s & %.4f%s \\\\\n",
              b1, stars1, b2, stars2, b3, stars3))
  cat(sprintf(" & (%.4f) & (%.4f) & (%.4f) \\\\\n", s1, s2, s3))

  cat("\\hline\n")
  cat("District FE & Yes & Yes & Yes \\\\\n")
  cat("Year FE & Absorbed & Yes & Yes \\\\\n")
  cat("State$\\times$Year FE & Yes & No & No \\\\\n")
  cat("Clustering & State & District & State \\\\\n")
  cat("Sample & Full & Full & Pre-2006 \\\\\n")
  cat(sprintf("Observations & %s & %s & %s \\\\\n",
              format(nobs(sxy_res$base), big.mark = ","),
              format(nobs(rob_misc$dist_cluster), big.mark = ","),
              format(nobs(rob_misc$placebo), big.mark = ",")))
  cat(sprintf("Districts & %d & %d & %d \\\\\n",
              uniqueN(panel$dist_id_11),
              uniqueN(panel$dist_id_11),
              uniqueN(panel[year <= 2005]$dist_id_11)))
  cat("\\hline\\hline\n")
  cat("\\end{tabular}\n")
  cat("\\begin{tablenotes}[flushleft]\\small\n")
  cat("\\item \\textit{Notes:} Robustness checks for the baseline TWFE specification. Column (1) replaces year FE with state$\\times$year FE. Column (2) clusters at the district level (584 clusters). Column (3) uses a placebo treatment date of 2003 on only pre-MGNREGA data (2000-2005). *** $p<0.01$, ** $p<0.05$, * $p<0.1$.\n")
  cat("\\end{tablenotes}\n")
  cat("\\end{table}\n")
  sink()
  cat("  Saved tab5_robustness.tex\n")
}

cat("\n=== All Tables Complete ===\n")
