###############################################################################
# 06_tables.R — Generate all LaTeX tables
# Paper: The Geography of Monetary Transmission
###############################################################################

source("00_packages.R")

panel <- readRDS("../data/panel_monthly.rds")
panel_annual <- readRDS("../data/panel_annual.rds")
lp_baseline <- readRDS("../data/lp_baseline.rds")
horse_race <- readRDS("../data/horse_race_results.rds")
alt_htm <- readRDS("../data/alt_htm_results.rds")
subperiod <- readRDS("../data/subperiod_results.rds")
asym <- readRDS("../data/asymmetry_results.rds")
perm <- readRDS("../data/permutation_results.rds")
fiscal <- readRDS("../data/fiscal_results.rds")
tercile_irf <- readRDS("../data/tercile_irf.rds")

htm_xs <- panel %>%
  distinct(state_abbr, htm_poverty_xs, htm_snap_xs, homeown_xs) %>%
  filter(!is.na(htm_poverty_xs))

# ===========================================================================
# Table 1: Summary Statistics
# ===========================================================================
cat("Table 1: Summary statistics...\n")

# Monthly panel stats
monthly_stats <- panel %>%
  filter(!is.na(brw_monthly), date >= "1994-01-01", date <= "2020-12-01") %>%
  summarise(
    `BRW Monetary Shock` = sprintf("%.4f & %.4f & %.4f & %.4f & %s",
      mean(brw_monthly, na.rm=T), sd(brw_monthly, na.rm=T),
      min(brw_monthly, na.rm=T), max(brw_monthly, na.rm=T),
      format(sum(!is.na(brw_monthly)), big.mark=",")),
    `Log Employment` = sprintf("%.2f & %.2f & %.2f & %.2f & %s",
      mean(log_emp, na.rm=T), sd(log_emp, na.rm=T),
      min(log_emp, na.rm=T), max(log_emp, na.rm=T),
      format(sum(!is.na(log_emp)), big.mark=","))
  )

# Cross-sectional stats
xs_stats <- htm_xs %>%
  summarise(
    pov_mean = mean(htm_poverty_xs, na.rm=T),
    pov_sd = sd(htm_poverty_xs, na.rm=T),
    pov_min = min(htm_poverty_xs, na.rm=T),
    pov_max = max(htm_poverty_xs, na.rm=T),
    snap_mean = mean(htm_snap_xs, na.rm=T),
    snap_sd = sd(htm_snap_xs, na.rm=T),
    snap_min = min(htm_snap_xs, na.rm=T),
    snap_max = max(htm_snap_xs, na.rm=T),
    ho_mean = mean(homeown_xs, na.rm=T),
    ho_sd = sd(homeown_xs, na.rm=T),
    ho_min = min(homeown_xs, na.rm=T),
    ho_max = max(homeown_xs, na.rm=T)
  )

tab1_tex <- sprintf("
\\begin{table}[t]
\\centering
\\caption{Summary Statistics}
\\label{tab:summary}
\\begin{threeparttable}
\\begin{tabular}{@{}lccccc@{}}
\\toprule
& Mean & SD & Min & Max & N \\\\
\\midrule
\\multicolumn{6}{l}{\\textit{Panel A: Monthly State Panel (1994--2020)}} \\\\[3pt]
BRW Monetary Shock & %s \\\\
Log Nonfarm Employment & %s \\\\[6pt]
\\multicolumn{6}{l}{\\textit{Panel B: State-Level HtM Proxies (1995--2005 avg)}} \\\\[3pt]
Poverty Rate & %.3f & %.3f & %.3f & %.3f & %d \\\\
SNAP Recipiency Rate & %.3f & %.3f & %.3f & %.3f & %d \\\\
Homeownership Rate & %.3f & %.3f & %.3f & %.3f & %d \\\\[6pt]
\\multicolumn{6}{l}{\\textit{Panel C: Annual State Panel (2000--2023)}} \\\\[3pt]
\\textrm{\\quad State GDP (\\$ millions)} & %s & %s & %s & %s & %s \\\\
\\textrm{\\quad Transfer/GDP Ratio} & %.3f & %.3f & %.3f & %.3f & %s \\\\
\\bottomrule
\\end{tabular}
\\begin{tablenotes}[flushleft]
\\small
\\item \\textit{Notes:} Panel A reports the monthly state-level panel used for local projection estimation. BRW shock is the Bu-Rogers-Wu (2021) unified monetary policy shock. Panel B reports cross-sectional HtM proxy measures averaged over the pre-sample period (1995--2005). Panel C reports the annual panel used for the fiscal transfer channel analysis. N = state $\\times$ period observations.
\\end{tablenotes}
\\end{threeparttable}
\\end{table}
",
monthly_stats$`BRW Monetary Shock`,
monthly_stats$`Log Employment`,
xs_stats$pov_mean, xs_stats$pov_sd, xs_stats$pov_min, xs_stats$pov_max, nrow(htm_xs),
xs_stats$snap_mean, xs_stats$snap_sd, xs_stats$snap_min, xs_stats$snap_max,
sum(!is.na(htm_xs$htm_snap_xs)),
xs_stats$ho_mean, xs_stats$ho_sd, xs_stats$ho_min, xs_stats$ho_max, nrow(htm_xs),
format(round(mean(panel_annual$gdp_millions, na.rm=T)), big.mark=","),
format(round(sd(panel_annual$gdp_millions, na.rm=T)), big.mark=","),
format(round(min(panel_annual$gdp_millions, na.rm=T)), big.mark=","),
format(round(max(panel_annual$gdp_millions, na.rm=T)), big.mark=","),
format(sum(!is.na(panel_annual$gdp_millions)), big.mark=","),
mean(panel_annual$transfer_gdp_ratio, na.rm=T),
sd(panel_annual$transfer_gdp_ratio, na.rm=T),
min(panel_annual$transfer_gdp_ratio, na.rm=T),
max(panel_annual$transfer_gdp_ratio, na.rm=T),
format(sum(!is.na(panel_annual$transfer_gdp_ratio)), big.mark=",")
)

writeLines(tab1_tex, "../tables/tab1_summary.tex")

# ===========================================================================
# Table 2: Baseline Local Projection Results
# ===========================================================================
cat("Table 2: Baseline LP results...\n")

lp_rows <- lp_baseline %>%
  mutate(
    stars = case_when(
      abs(coef/se) > 2.576 ~ "***",
      abs(coef/se) > 1.960 ~ "**",
      abs(coef/se) > 1.645 ~ "*",
      TRUE ~ ""
    ),
    row = sprintf("%.4f%s & (%.4f) & %s & %.3f",
                  coef, stars, se, format(nobs, big.mark=","), r2)
  )

tab2_tex <- sprintf("
\\begin{table}[t]
\\centering
\\caption{Monetary Policy Transmission and Hand-to-Mouth Households: Baseline Results}
\\label{tab:baseline}
\\begin{threeparttable}
\\begin{tabular}{@{}lcccc@{}}
\\toprule
Horizon (months) & $\\hat{\\gamma}^h$ & (SE) & N & $R^2$ \\\\
\\midrule
%s
\\bottomrule
\\end{tabular}
\\begin{tablenotes}[flushleft]
\\small
\\item \\textit{Notes:} Local projection estimates of the coefficient on MP$_t \\times$ HtM$_s$ (standardized poverty rate). Dependent variable: 100 $\\times$ (log employment$_{s,t+h}$ $-$ log employment$_{s,t-1}$). All specifications include state and year-month fixed effects and three lags of employment growth as controls. Standard errors are Driscoll-Kraay, robust to cross-sectional dependence. *, **, *** denote significance at the 10\\%%, 5\\%%, and 1\\%% levels.
\\end{tablenotes}
\\end{threeparttable}
\\end{table}
",
paste(sprintf("$h = %d$ & %s \\\\", lp_rows$horizon, lp_rows$row), collapse = "\n"))

writeLines(tab2_tex, "../tables/tab2_baseline.tex")

# ===========================================================================
# Table 3: Horse Race (Competing Channels)
# ===========================================================================
cat("Table 3: Horse race...\n")

# Use h=24 horse race
hr <- horse_race$h24

fmt_b <- function(fit, var) {
  b <- coef(fit)[var]
  s <- sqrt(diag(vcov(fit)))[var]
  if (is.na(b)) return("")
  stars <- ifelse(abs(b/s) > 2.576, "***",
           ifelse(abs(b/s) > 1.960, "**",
           ifelse(abs(b/s) > 1.645, "*", "")))
  sprintf("%.4f%s", b, stars)
}
fmt_se <- function(fit, var) {
  b <- coef(fit)[var]
  s <- sqrt(diag(vcov(fit)))[var]
  if (is.na(b)) return("")
  sprintf("(%.4f)", s)
}

tab3_tex <- sprintf("
\\begin{table}[t]
\\centering
\\caption{Horse Race: HtM Channel vs. Alternative Transmission Mechanisms ($h = 24$)}
\\label{tab:horserace}
\\begin{threeparttable}
\\begin{tabular}{@{}lcccc@{}}
\\toprule
& (1) & (2) & (3) & (4) \\\\
& HtM Only & Homeown. Only & Both & SNAP \\\\
\\midrule
MP $\\times$ HtM (poverty) & %s & & %s & \\\\
& %s & & %s & \\\\[6pt]
MP $\\times$ Homeownership & & %s & %s & \\\\
& & %s & %s & \\\\[6pt]
MP $\\times$ HtM (SNAP) & & & & %s \\\\
& & & & %s \\\\
\\midrule
State FE & Yes & Yes & Yes & Yes \\\\
Year-Month FE & Yes & Yes & Yes & Yes \\\\
Lagged controls & Yes & Yes & Yes & Yes \\\\
N & %s & %s & %s & %s \\\\
\\bottomrule
\\end{tabular}
\\begin{tablenotes}[flushleft]
\\small
\\item \\textit{Notes:} All regressions use the $h = 24$ month local projection specification. Columns (1)--(3) use the poverty rate as the HtM proxy; column (4) uses SNAP recipiency. The ``homeownership'' interaction captures the housing wealth channel of monetary transmission. Driscoll-Kraay standard errors in parentheses. *, **, *** denote significance at 10\\%%, 5\\%%, 1\\%%.
\\end{tablenotes}
\\end{threeparttable}
\\end{table}
",
fmt_b(hr$htm_only, "mp_htm"), fmt_b(hr$both, "mp_htm"),
fmt_se(hr$htm_only, "mp_htm"), fmt_se(hr$both, "mp_htm"),
fmt_b(hr$homeown_only, "mp_homeown"), fmt_b(hr$both, "mp_homeown"),
fmt_se(hr$homeown_only, "mp_homeown"), fmt_se(hr$both, "mp_homeown"),
fmt_b(hr$snap, "mp_snap"),
fmt_se(hr$snap, "mp_snap"),
format(hr$htm_only$nobs, big.mark=","),
format(hr$homeown_only$nobs, big.mark=","),
format(hr$both$nobs, big.mark=","),
format(hr$snap$nobs, big.mark=",")
)

writeLines(tab3_tex, "../tables/tab3_horserace.tex")

# ===========================================================================
# Table 4: Robustness — Alternative HtM, Sub-periods, Permutation
# ===========================================================================
cat("Table 4: Robustness...\n")

# Collect robustness results at h=24
rob_rows <- list()

# Alt HtM measures
rob_rows[["Poverty rate (baseline)"]] <- alt_htm$h24$poverty
rob_rows[["SNAP recipiency"]] <- alt_htm$h24$snap
rob_rows[["Homeownership (inverse)"]] <- alt_htm$h24$homeown

# Sub-periods
rob_rows[["Pre-GFC (1994--2007)"]] <- subperiod$h24$pre_gfc
rob_rows[["Post-GFC (2010--2020)"]] <- subperiod$h24$post_gfc

make_rob_row <- function(label, fit, varname) {
  b <- coef(fit)[varname]
  s <- sqrt(diag(vcov(fit)))[varname]
  stars <- ifelse(abs(b/s) > 2.576, "***",
           ifelse(abs(b/s) > 1.960, "**",
           ifelse(abs(b/s) > 1.645, "*", "")))
  sprintf("%s & %.4f%s & (%.4f) & %s \\\\",
          label, b, stars, s, format(fit$nobs, big.mark=","))
}

var_map <- c(
  "Poverty rate (baseline)" = "mp_htm",
  "SNAP recipiency" = "mp_snap",
  "Homeownership (inverse)" = "mp_homeown",
  "Pre-GFC (1994--2007)" = "mp_htm",
  "Post-GFC (2010--2020)" = "mp_htm"
)

rob_lines <- sapply(names(rob_rows), function(n) {
  make_rob_row(n, rob_rows[[n]], var_map[n])
})

tab4_tex <- sprintf("
\\begin{table}[t]
\\centering
\\caption{Robustness: Alternative HtM Measures, Sub-Periods, and Permutation Test ($h = 24$)}
\\label{tab:robustness}
\\begin{threeparttable}
\\begin{tabular}{@{}lccc@{}}
\\toprule
Specification & $\\hat{\\gamma}^{24}$ & (SE) & N \\\\
\\midrule
\\multicolumn{4}{l}{\\textit{Panel A: Alternative HtM Measures}} \\\\[3pt]
%s
%s
%s
\\\\[3pt]
\\multicolumn{4}{l}{\\textit{Panel B: Sub-Period Stability}} \\\\[3pt]
%s
%s
\\\\[3pt]
\\multicolumn{4}{l}{\\textit{Panel C: Permutation Inference}} \\\\[3pt]
Actual $\\hat{\\gamma}^{24}$ & \\multicolumn{3}{c}{%.4f} \\\\
Permutation $p$-value & \\multicolumn{3}{c}{%.3f (500 permutations)} \\\\
\\bottomrule
\\end{tabular}
\\begin{tablenotes}[flushleft]
\\small
\\item \\textit{Notes:} All specifications use the $h = 24$ month local projection with state and year-month fixed effects. Panel A varies the HtM proxy measure. Panel B splits the sample at the Great Financial Crisis. Panel C randomly reassigns HtM rankings across states 500 times and reports the fraction of permuted $|\\hat{\\gamma}|$ exceeding the actual. Driscoll-Kraay SEs. *, **, *** denote significance at 10\\%%, 5\\%%, 1\\%%.
\\end{tablenotes}
\\end{threeparttable}
\\end{table}
",
rob_lines[1], rob_lines[2], rob_lines[3],
rob_lines[4], rob_lines[5],
perm$actual, perm$pvalue
)

writeLines(tab4_tex, "../tables/tab4_robustness.tex")

# ===========================================================================
# Table 5: Asymmetry (Tightening vs Easing)
# ===========================================================================
cat("Table 5: Asymmetry...\n")

asym_rows <- lapply(names(asym), function(n) {
  fit <- asym[[n]]
  h <- as.integer(gsub("h", "", n))
  bt <- coef(fit)["mp_htm_tight"]
  st <- sqrt(diag(vcov(fit)))["mp_htm_tight"]
  be <- coef(fit)["mp_htm_ease"]
  se_ <- sqrt(diag(vcov(fit)))["mp_htm_ease"]
  stars_t <- ifelse(abs(bt/st) > 2.576, "***", ifelse(abs(bt/st) > 1.960, "**", ifelse(abs(bt/st) > 1.645, "*", "")))
  stars_e <- ifelse(abs(be/se_) > 2.576, "***", ifelse(abs(be/se_) > 1.960, "**", ifelse(abs(be/se_) > 1.645, "*", "")))
  sprintf("$h = %d$ & %.4f%s & (%.4f) & %.4f%s & (%.4f) & %s \\\\",
          h, bt, stars_t, st, be, stars_e, se_, format(fit$nobs, big.mark=","))
})

tab5_tex <- sprintf("
\\begin{table}[t]
\\centering
\\caption{Asymmetric Monetary Transmission: Tightening vs. Easing}
\\label{tab:asymmetry}
\\begin{threeparttable}
\\begin{tabular}{@{}lccccl@{}}
\\toprule
& \\multicolumn{2}{c}{Tightening} & \\multicolumn{2}{c}{Easing} & \\\\
Horizon & $\\hat{\\gamma}_{tight}^h$ & (SE) & $\\hat{\\gamma}_{ease}^h$ & (SE) & N \\\\
\\midrule
%s
\\bottomrule
\\end{tabular}
\\begin{tablenotes}[flushleft]
\\small
\\item \\textit{Notes:} Tightening shocks are BRW $> 0$; easing shocks are BRW $< 0$. Each is interacted separately with the standardized HtM share. HANK predicts that tightening effects are larger in absolute value for high-HtM states (asymmetric amplification). State and year-month FE; Driscoll-Kraay SEs. *, **, *** denote significance at 10\\%%, 5\\%%, 1\\%%.
\\end{tablenotes}
\\end{threeparttable}
\\end{table}
",
paste(asym_rows, collapse = "\n"))

writeLines(tab5_tex, "../tables/tab5_asymmetry.tex")

# ===========================================================================
# Table 6: Fiscal Transfer Channel
# ===========================================================================
cat("Table 6: Fiscal transfer channel...\n")

format_coef <- function(fit, varname) {
  b <- coef(fit)[varname]
  s <- sqrt(diag(vcov(fit)))[varname]
  if (is.na(b)) return(list(coef = "---", se = ""))
  stars <- ifelse(abs(b/s) > 2.576, "***", ifelse(abs(b/s) > 1.960, "**", ifelse(abs(b/s) > 1.645, "*", "")))
  list(coef = sprintf("%.4f%s", b, stars), se = sprintf("(%.4f)", s))
}

# OLS results
ols_main <- format_coef(fiscal$ols, "d_transfer_ratio")
ols_int <- format_coef(fiscal$ols, "I(d_transfer_ratio * htm_std_annual)")
ols_n <- format(fiscal$ols$nobs, big.mark = ",")

# IV results (with NULL guard)
if (!is.null(fiscal$iv)) {
  iv_nms <- names(coef(fiscal$iv))
  iv_main <- format_coef(fiscal$iv, iv_nms[1])
  iv_int <- if (length(iv_nms) >= 2) format_coef(fiscal$iv, iv_nms[2]) else list(coef = "---", se = "")
  iv_n <- format(fiscal$iv$nobs, big.mark = ",")
} else {
  iv_main <- list(coef = "---", se = "")
  iv_int <- list(coef = "---", se = "")
  iv_n <- "---"
}

tab6_tex <- sprintf("
\\begin{table}[t]
\\centering
\\caption{Fiscal Transfer Channel: OLS and IV Estimates}
\\label{tab:fiscal}
\\begin{threeparttable}
\\begin{tabular}{@{}lcc@{}}
\\toprule
& (1) OLS & (2) IV \\\\
\\midrule
$\\Delta$Transfer/GDP & %s & %s \\\\
& %s & %s \\\\[6pt]
$\\Delta$Transfer/GDP $\\times$ HtM & %s & %s \\\\
& %s & %s \\\\
\\midrule
State FE & Yes & Yes \\\\
Year FE & Yes & Yes \\\\
Instrument & --- & Bartik \\\\
N & %s & %s \\\\
\\bottomrule
\\end{tabular}
\\begin{tablenotes}[flushleft]
\\small
\\item \\textit{Notes:} Dependent variable: $\\Delta \\log$(State GDP). Annual state panel, 2000--2023. The Bartik instrument uses pre-determined state shares of each federal transfer category (excluding UI) interacted with national changes. HtM is the standardized poverty rate. Driscoll-Kraay SEs in parentheses. *, **, *** denote significance at 10\\%%, 5\\%%, 1\\%%.
\\end{tablenotes}
\\end{threeparttable}
\\end{table}
",
ols_main$coef, iv_main$coef,
ols_main$se, iv_main$se,
ols_int$coef, iv_int$coef,
ols_int$se, iv_int$se,
ols_n, iv_n
)

writeLines(tab6_tex, "../tables/tab6_fiscal.tex")

cat("\n=== ALL TABLES GENERATED ===\n")
cat(sprintf("Saved to: %s\n", normalizePath("../tables")))
