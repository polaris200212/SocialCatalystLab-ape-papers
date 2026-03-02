## 06_tables.R — Generate LaTeX tables for the paper
## apep_0459: Skills-Based Hiring Laws and Public Sector De-Credentialization

source("00_packages.R")

data_dir <- "../data/"
table_dir <- "../tables/"
dir.create(table_dir, recursive = TRUE, showWarnings = FALSE)

analysis <- fread(paste0(data_dir, "analysis_panel.csv"))
load(paste0(data_dir, "main_results.RData"))
load(paste0(data_dir, "robustness_results.RData"))

## ============================================================================
## TABLE 1: Summary Statistics
## ============================================================================

pre <- analysis[year <= 2021]

## Create summary stats table
sumstats <- pre[, .(
  `Share without BA` = c(
    weighted.mean(share_no_ba[first_treat > 0], n_state_gov[first_treat > 0], na.rm = TRUE),
    weighted.mean(share_no_ba[first_treat == 0], n_state_gov[first_treat == 0], na.rm = TRUE)
  ),
  `Mean wages ($)` = c(
    weighted.mean(mean_wages[first_treat > 0], n_state_gov[first_treat > 0], na.rm = TRUE),
    weighted.mean(mean_wages[first_treat == 0], n_state_gov[first_treat == 0], na.rm = TRUE)
  ),
  `Share female` = c(
    weighted.mean(pct_female[first_treat > 0], n_state_gov[first_treat > 0], na.rm = TRUE),
    weighted.mean(pct_female[first_treat == 0], n_state_gov[first_treat == 0], na.rm = TRUE)
  ),
  `Share Black` = c(
    weighted.mean(pct_black[first_treat > 0], n_state_gov[first_treat > 0], na.rm = TRUE),
    weighted.mean(pct_black[first_treat == 0], n_state_gov[first_treat == 0], na.rm = TRUE)
  ),
  `Unemployment rate` = c(
    mean(unemp_rate[first_treat > 0], na.rm = TRUE),
    mean(unemp_rate[first_treat == 0], na.rm = TRUE)
  ),
  `N states` = c(
    uniqueN(state_fips[first_treat > 0]),
    uniqueN(state_fips[first_treat == 0])
  )
)]

## Write LaTeX table
sink(paste0(table_dir, "tab1_summary.tex"))
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Pre-Treatment Summary Statistics: State Government Employees}\n")
cat("\\label{tab:summary}\n")
cat("\\begin{tabular}{lcc}\n")
cat("\\hline\\hline\n")
cat(" & Treated States & Never-Treated States \\\\\n")
cat("\\hline\n")
cat(sprintf("Share without bachelor's degree & %.3f & %.3f \\\\\n",
            sumstats$`Share without BA`[1], sumstats$`Share without BA`[2]))
cat(sprintf("Mean annual wages (\\$) & %s & %s \\\\\n",
            format(round(sumstats$`Mean wages ($)`[1]), big.mark = ","),
            format(round(sumstats$`Mean wages ($)`[2]), big.mark = ",")))
cat(sprintf("Share female & %.3f & %.3f \\\\\n",
            sumstats$`Share female`[1], sumstats$`Share female`[2]))
cat(sprintf("Share Black & %.3f & %.3f \\\\\n",
            sumstats$`Share Black`[1], sumstats$`Share Black`[2]))
cat(sprintf("State unemployment rate (\\%%) & %.1f & %.1f \\\\\n",
            sumstats$`Unemployment rate`[1], sumstats$`Unemployment rate`[2]))
cat(sprintf("Number of states & %d & %d \\\\\n",
            sumstats$`N states`[1], sumstats$`N states`[2]))
cat("\\hline\\hline\n")
cat("\\multicolumn{3}{p{10cm}}{\\footnotesize \\textit{Notes:} Pre-treatment period")
cat(" 2013--2021. Weighted by state government employment. Source: ACS 1-year PUMS")
cat(" (IPUMS/Census Bureau). Workers aged 25--64.}\n")
cat("\\end{tabular}\n")
cat("\\end{table}\n")
sink()
cat("Table 1 saved.\n")

## Helper: significance stars
stars <- function(coef, se) {
  p <- 2 * (1 - pnorm(abs(coef / se)))
  if (p < 0.01) return("***")
  if (p < 0.05) return("**")
  if (p < 0.10) return("*")
  return("")
}

## ============================================================================
## TABLE 2: Main Results
## ============================================================================

sink(paste0(table_dir, "tab2_main_results.tex"))
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Effect of Skills-Based Hiring Laws on State Government Workforce Composition}\n")
cat("\\label{tab:main}\n")
cat("\\begin{tabular}{lcccc}\n")
cat("\\hline\\hline\n")
cat(" & (1) & (2) & (3) & (4) \\\\\n")
cat(" & TWFE & CS-DiD & Sun-Abraham & DDD \\\\\n")
cat("\\hline\n")
cat("\\multicolumn{5}{l}{\\textit{Dep. var.: Share of state gov. workers without BA}} \\\\\n")
cat("[0.5em]\n")

## TWFE
twfe_coef <- coef(twfe)["treated"]
twfe_se <- sqrt(vcov(twfe)["treated", "treated"])
cat(sprintf("Treated & %.4f%s & & & \\\\\n", twfe_coef, stars(twfe_coef, twfe_se)))
cat(sprintf(" & (%.4f) & & & \\\\\n", twfe_se))

## CS overall ATT
cs_coef <- att_overall$overall.att
cs_se <- att_overall$overall.se
cat(sprintf("CS ATT & & %.4f%s & & \\\\\n", cs_coef, stars(cs_coef, cs_se)))
cat(sprintf(" & & (%.4f) & & \\\\\n", cs_se))

## Sun-Abraham (overall post-treatment average)
tryCatch({
  sunab_coefs <- coef(sunab_out)
  sunab_se <- sqrt(diag(vcov(sunab_out)))
  ## Post-treatment coefficients have non-negative event times (year::0, year::1, ...)
  post_idx <- grep("^year::[0-9]", names(sunab_coefs))
  if (length(post_idx) > 0) {
    sunab_att <- mean(sunab_coefs[post_idx])
    sunab_att_se <- sqrt(mean(sunab_se[post_idx]^2) / length(post_idx))
    cat(sprintf("SA ATT & & & %.4f%s & \\\\\n", sunab_att, stars(sunab_att, sunab_att_se)))
    cat(sprintf(" & & & (%.4f) & \\\\\n", sunab_att_se))
  } else {
    cat("SA ATT & & & --- & \\\\\n")
  }
}, error = function(e) {
  cat("SA ATT & & & --- & \\\\\n")
})

## DDD
ddd_coef <- coef(ddd_reg)["treated:is_state_gov"]
ddd_se <- sqrt(vcov(ddd_reg)["treated:is_state_gov", "treated:is_state_gov"])
cat(sprintf("Treated $\\times$ State Gov & & & & %.4f%s \\\\\n", ddd_coef, stars(ddd_coef, ddd_se)))
cat(sprintf(" & & & & (%.4f) \\\\\n", ddd_se))

cat("[0.5em]\n")
cat(sprintf("State FE & Yes & --- & Yes & Yes \\\\\n"))
cat(sprintf("Year FE & Yes & --- & Yes & Yes \\\\\n"))
cat(sprintf("Observations & %d & %d & %d & %d \\\\\n",
            nrow(analysis), nrow(analysis), nrow(analysis), nrow(analysis) * 2))
cat("\\hline\\hline\n")
cat("\\multicolumn{5}{p{12cm}}{\\footnotesize \\textit{Notes:} Standard errors")
cat(" clustered at the state level in parentheses. Column 1: TWFE with state and")
cat(" year FE. Column 2: Callaway and Sant'Anna (2021) ATT with never-treated")
cat(" comparison group. Column 3: Sun and Abraham (2021) interaction-weighted")
cat(" estimator. Column 4: Triple-difference comparing state government to")
cat(" private sector workers. Weighted by state government employment. * $p<0.10$,")
cat(" ** $p<0.05$, *** $p<0.01$.}\n")
cat("\\end{tabular}\n")
cat("\\end{table}\n")
sink()
cat("Table 2 saved.\n")

## ============================================================================
## TABLE 3: Robustness and Heterogeneity
## ============================================================================

sink(paste0(table_dir, "tab3_robustness.tex"))
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Robustness Checks and Heterogeneity}\n")
cat("\\label{tab:robust}\n")
cat("\\begin{tabular}{lccc}\n")
cat("\\hline\\hline\n")
cat(" & Coefficient & Std. Error & $p$-value \\\\\n")
cat("\\hline\n")
cat("\\multicolumn{4}{l}{\\textit{Panel A: Placebo Tests}} \\\\\n")
cat("[0.3em]\n")

## Federal placebo
fed_c <- coef(placebo_fed)["treated"]
fed_s <- sqrt(vcov(placebo_fed)["treated", "treated"])
fed_p <- 2 * (1 - pnorm(abs(fed_c / fed_s)))
cat(sprintf("Federal government workers & %.4f & %.4f & %.3f \\\\\n", fed_c, fed_s, fed_p))

## Local placebo
loc_c <- coef(placebo_local)["treated"]
loc_s <- sqrt(vcov(placebo_local)["treated", "treated"])
loc_p <- 2 * (1 - pnorm(abs(loc_c / loc_s)))
cat(sprintf("Local government workers & %.4f & %.4f & %.3f \\\\\n", loc_c, loc_s, loc_p))

cat("[0.5em]\n")
cat("\\multicolumn{4}{l}{\\textit{Panel B: Heterogeneity by Policy Strength}} \\\\\n")
cat("[0.3em]\n")

## Strong vs moderate
str_c <- coef(hetero_strength)["strong_policy"]
str_s <- sqrt(vcov(hetero_strength)["strong_policy", "strong_policy"])
str_p <- 2 * (1 - pnorm(abs(str_c / str_s)))
cat(sprintf("Strong policy & %.4f & %.4f & %.3f \\\\\n", str_c, str_s, str_p))

mod_c <- coef(hetero_strength)["moderate_policy"]
mod_s <- sqrt(vcov(hetero_strength)["moderate_policy", "moderate_policy"])
mod_p <- 2 * (1 - pnorm(abs(mod_c / mod_s)))
cat(sprintf("Moderate policy & %.4f & %.4f & %.3f \\\\\n", mod_c, mod_s, mod_p))

cat("[0.5em]\n")
cat("\\multicolumn{4}{l}{\\textit{Panel C: Demographic Outcomes}} \\\\\n")
cat("[0.3em]\n")

## Demographics
blk_c <- coef(demo_black)["treated"]
blk_s <- sqrt(vcov(demo_black)["treated", "treated"])
blk_p <- 2 * (1 - pnorm(abs(blk_c / blk_s)))
cat(sprintf("Share Black workers & %.4f & %.4f & %.3f \\\\\n", blk_c, blk_s, blk_p))

fem_c <- coef(demo_female)["treated"]
fem_s <- sqrt(vcov(demo_female)["treated", "treated"])
fem_p <- 2 * (1 - pnorm(abs(fem_c / fem_s)))
cat(sprintf("Share female workers & %.4f & %.4f & %.3f \\\\\n", fem_c, fem_s, fem_p))

yng_c <- coef(demo_young)["treated"]
yng_s <- sqrt(vcov(demo_young)["treated", "treated"])
yng_p <- 2 * (1 - pnorm(abs(yng_c / yng_s)))
cat(sprintf("Share young workers (25--34) & %.4f & %.4f & %.3f \\\\\n", yng_c, yng_s, yng_p))

cat("[0.5em]\n")
cat(sprintf("Observations & \\multicolumn{3}{c}{%d (all panels)} \\\\\n", nrow(analysis)))
cat("\\hline\\hline\n")
cat("\\multicolumn{4}{p{10cm}}{\\footnotesize \\textit{Notes:} All specifications")
cat(" include state and year fixed effects, weighted by state government employment,")
cat(" with standard errors clustered at the state level. $N = 510$ state-year observations")
cat(" (51 units $\\times$ 10 years). Placebo tests use the same")
cat(" treatment timing applied to workers in other sectors.}\n")
cat("\\end{tabular}\n")
cat("\\end{table}\n")
sink()
cat("Table 3 saved.\n")

## ============================================================================
## TABLE 4: Policy Adoption Dates
## ============================================================================

treatment <- fread(paste0(data_dir, "treatment_dates.csv"))

sink(paste0(table_dir, "tab4_adoption.tex"))
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Skills-Based Hiring Policy Adoption Dates}\n")
cat("\\label{tab:adoption}\n")
cat("\\small\n")
cat("\\begin{tabular}{lllll}\n")
cat("\\hline\\hline\n")
cat("State & Date & Type & Strength & First Treat \\\\\n")
cat("\\hline\n")

for (i in 1:nrow(treatment)) {
  row <- treatment[i]
  date_str <- paste0(month.abb[row$adopt_month], " ", row$adopt_year)
  type_str <- ifelse(row$policy_type == "executive", "Executive", "Legislative")
  str_str <- tools::toTitleCase(row$strength)
  post_marker <- ifelse(row$first_treat <= 2023, paste0(row$first_treat, "$^\\dagger$"), row$first_treat)
  cat(sprintf("%s & %s & %s & %s & %s \\\\\n", row$state_name, date_str, type_str, str_str, post_marker))
}

cat("\\hline\\hline\n")
cat("\\multicolumn{5}{p{12cm}}{\\footnotesize \\textit{Notes:} Adoption dates from")
cat(" executive orders, legislation, and administrative actions documented by NCSL,")
cat(" NGA, Brookings Institution, and state government websites. ``Strong'' policies")
cat(" affect 90\\%+ of positions or are codified in legislation. ``Moderate'' policies")
cat(" direct review or consideration of alternatives to degree requirements.")
cat(" First Treat = effective first treatment year used in analysis (adoption month $\\leq$ 6")
cat(" $\\Rightarrow$ same year; month $>$ 6 $\\Rightarrow$ next year). $\\dagger$ = has $\\geq 1$")
cat(" post-treatment year in ACS data (through 2023).}\n")
cat("\\end{tabular}\n")
cat("\\end{table}\n")
sink()
cat("Table 4 saved.\n")

cat("\n=== All tables generated ===\n")
