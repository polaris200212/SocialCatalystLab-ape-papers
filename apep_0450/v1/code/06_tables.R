# ============================================================================
# 06_tables.R — Publication-ready tables
# GST and Interstate Price Convergence
# ============================================================================

source("00_packages.R")

load("../data/main_models.RData")
load("../data/robustness_models.RData")
cpi <- fread("../data/cpi_panel.csv")
cpi[, date := as.Date(date)]

# ── Table 1: Summary Statistics ─────────────────────────────────────────────
cat("Generating Table 1: Summary Statistics...\n")

gen <- cpi[group == "General" & !is.na(index)]
pre <- gen[post_gst == 0]
post <- gen[post_gst == 1]

summ <- data.table(
  Variable = c("CPI Index", "Log CPI Index", "Inflation (\\%)",
               "Tax Intensity (raw \\%)", "Tax Intensity (std)"),
  `Full Sample Mean` = c(
    round(mean(gen$index, na.rm = TRUE), 1),
    round(mean(gen$log_index, na.rm = TRUE), 3),
    round(mean(gen$inflation, na.rm = TRUE), 1),
    round(mean(gen$tax_gsdp, na.rm = TRUE), 1),
    round(mean(gen$tax_intensity, na.rm = TRUE), 3)
  ),
  `Full Sample SD` = c(
    round(sd(gen$index, na.rm = TRUE), 1),
    round(sd(gen$log_index, na.rm = TRUE), 3),
    round(sd(gen$inflation, na.rm = TRUE), 1),
    round(sd(gen$tax_gsdp, na.rm = TRUE), 1),
    round(sd(gen$tax_intensity, na.rm = TRUE), 3)
  ),
  `Pre-GST Mean` = c(
    round(mean(pre$index, na.rm = TRUE), 1),
    round(mean(pre$log_index, na.rm = TRUE), 3),
    round(mean(pre$inflation, na.rm = TRUE), 1),
    round(mean(pre$tax_gsdp, na.rm = TRUE), 1),
    round(mean(pre$tax_intensity, na.rm = TRUE), 3)
  ),
  `Pre-GST SD` = c(
    round(sd(pre$index, na.rm = TRUE), 1),
    round(sd(pre$log_index, na.rm = TRUE), 3),
    round(sd(pre$inflation, na.rm = TRUE), 1),
    round(sd(pre$tax_gsdp, na.rm = TRUE), 1),
    round(sd(pre$tax_intensity, na.rm = TRUE), 3)
  ),
  `Post-GST Mean` = c(
    round(mean(post$index, na.rm = TRUE), 1),
    round(mean(post$log_index, na.rm = TRUE), 3),
    round(mean(post$inflation, na.rm = TRUE), 1),
    round(mean(post$tax_gsdp, na.rm = TRUE), 1),
    round(mean(post$tax_intensity, na.rm = TRUE), 3)
  ),
  `Post-GST SD` = c(
    round(sd(post$index, na.rm = TRUE), 1),
    round(sd(post$log_index, na.rm = TRUE), 3),
    round(sd(post$inflation, na.rm = TRUE), 1),
    round(sd(post$tax_gsdp, na.rm = TRUE), 1),
    round(sd(post$tax_intensity, na.rm = TRUE), 3)
  )
)

fwrite(summ, "../tables/tab1_summary.csv")

# LaTeX version
sink("../tables/tab1_summary.tex")
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Summary Statistics: State-Level Consumer Price Index (General)}\n")
cat("\\label{tab:summary}\n")
cat("\\begin{tabular}{lcccccc}\n")
cat("\\toprule\n")
cat("& \\multicolumn{2}{c}{Full Sample} & \\multicolumn{2}{c}{Pre-GST} & \\multicolumn{2}{c}{Post-GST} \\\\\n")
cat("\\cmidrule(lr){2-3} \\cmidrule(lr){4-5} \\cmidrule(lr){6-7}\n")
cat("Variable & Mean & SD & Mean & SD & Mean & SD \\\\\n")
cat("\\midrule\n")
for (i in 1:nrow(summ)) {
  cat(sprintf("%s & %s & %s & %s & %s & %s & %s \\\\\n",
              summ$Variable[i], summ$`Full Sample Mean`[i],
              summ$`Full Sample SD`[i], summ$`Pre-GST Mean`[i],
              summ$`Pre-GST SD`[i], summ$`Post-GST Mean`[i],
              summ$`Post-GST SD`[i]))
}
cat("\\midrule\n")
cat(sprintf("\\multicolumn{7}{l}{States: %d \\quad Months: %d (54 pre-GST, 100 post-GST) \\quad Observations: %s} \\\\\n",
            uniqueN(gen$state), uniqueN(gen$date), format(nrow(gen), big.mark = ",")))
cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{tablenotes}[flushleft]\\small\n")
cat("\\item \\textit{Notes:} CPI base year 2012=100 (Combined sector). ")
cat("Tax intensity is pre-GST state indirect tax revenue as \\% of GSDP (RBI State Finances 2016-17). ")
cat("Standardized intensity has mean 0 and SD 1. ")
cat("Pre-GST: January 2013--June 2017 (54 months). Post-GST: July 2017--December 2025 (100 months, excluding April--May 2020). ")
cat("Two months missing due to COVID-19 lockdown suspension of CPI collection.\n")
cat("\\end{tablenotes}\n")
cat("\\end{table}\n")
sink()

# ── Table 2: Main Regression Results ────────────────────────────────────────
cat("Generating Table 2: Main results...\n")

models_main <- list(
  "Baseline DiD" = m1,
  "Binary Treatment" = m7,
  "Alt. Intensity" = m8
)

# Custom gof_map with cluster count
gm_main <- list(
  list("raw" = "nobs", "clean" = "Observations", "fmt" = function(x) format(round(x), big.mark = ",")),
  list("raw" = "r.squared", "clean" = "$R^2$", "fmt" = 3),
  list("raw" = "adj.r.squared", "clean" = "Adj. $R^2$", "fmt" = 3),
  list("raw" = "FE: state_id", "clean" = "State FE", "fmt" = 0),
  list("raw" = "FE: time", "clean" = "Time FE", "fmt" = 0)
)

msummary(models_main,
         output = "../tables/tab2_main_results.tex",
         stars = c("*" = 0.1, "**" = 0.05, "***" = 0.01),
         statistic = c("({std.error})", "[{conf.low}, {conf.high}]"),
         conf_level = 0.95,
         coef_rename = c(
           "post_gst:tax_intensity" = "Post-GST $\\times$ Tax Intensity",
           "post_gst:high_tax" = "Post-GST $\\times$ High Tax State",
           "post_gst:disp_intensity" = "Post-GST $\\times$ Price Dispersion"
         ),
         gof_map = gm_main,
         add_rows = data.frame(
           V1 = "Clusters (states)",
           V2 = "35", V3 = "35", V4 = "35"
         ),
         title = "GST and State-Level CPI: Main Results",
         notes = c("Standard errors clustered at the state level in parentheses.",
                    "95\\% confidence intervals in brackets.",
                    "All specifications include state and time fixed effects.",
                    "Dependent variable: log(CPI index)."),
         escape = FALSE)

# ── Table 3: Commodity Group Heterogeneity ──────────────────────────────────
cat("Generating Table 3: Commodity group results...\n")

group_dt <- fread("../data/group_level_results.csv")
group_dt[, stars := ifelse(p_val < 0.01, "***",
                   ifelse(p_val < 0.05, "**",
                   ifelse(p_val < 0.1, "*", "")))]

# Get N per commodity group from data
comm <- cpi[!group %in% c("General", "Consumer Food Price") & !is.na(index)]
group_n <- comm[, .(N = .N), by = group]
group_dt <- merge(group_dt, group_n, by = "group", all.x = TRUE)

# Desired display order
display_order <- c("Food and Beverages", "Pan, Tobacco and Intoxicants",
                   "Clothing and Footwear", "Fuel and Light", "Miscellaneous")
group_dt <- group_dt[match(display_order, group)]

sink("../tables/tab3_commodity_groups.tex")
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{GST Price Effects by Commodity Group}\n")
cat("\\label{tab:commodity}\n")
cat("\\begin{tabular}{lccccc}\n")
cat("\\toprule\n")
cat("Commodity Group & $\\hat{\\beta}$ & SE & $t$-stat & $p$-value & $N$ \\\\\n")
cat("\\midrule\n")
for (i in 1:nrow(group_dt)) {
  cat(sprintf("%s & %.4f%s & (%.4f) & %.2f & %.3f & %s \\\\\n",
              group_dt$group[i], group_dt$estimate[i], group_dt$stars[i],
              group_dt$se[i], group_dt$t_stat[i], group_dt$p_val[i],
              format(group_dt$N[i], big.mark = ",")))
}
cat("Housing & \\multicolumn{5}{c}{(dropped: collinearity with fixed effects)} \\\\\n")
cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{tablenotes}[flushleft]\\small\n")
cat("\\item \\textit{Notes:} Each row reports the coefficient from a separate regression of ")
cat("log(CPI) on Post-GST $\\times$ Tax Intensity with state and time fixed effects. ")
cat("Standard errors clustered at the state level (35 clusters). ")
cat("$^{***}p<0.01$, $^{**}p<0.05$, $^{*}p<0.1$.\n")
cat("\\end{tablenotes}\n")
cat("\\end{table}\n")
sink()

# ── Table 4: Robustness Checks ─────────────────────────────────────────────
cat("Generating Table 4: Robustness...\n")

models_robust <- list(
  "Baseline" = m1,
  "Excl. Demo." = r1,
  "Pre-COVID" = r2,
  "Fuel Placebo" = r3,
  "Time Placebo" = r6
)

# Add the new robustness specs
models_robust_ext <- list(
  "Baseline" = m1,
  "Excl. Demo." = r1,
  "Pre-COVID" = r2,
  "Fuel Placebo" = r3,
  "Time Placebo" = r6,
  "Dispersion DV" = r8,
  "State Trends" = r9
)

gm_rob <- list(
  list("raw" = "nobs", "clean" = "Observations", "fmt" = function(x) format(round(x), big.mark = ",")),
  list("raw" = "r.squared", "clean" = "$R^2$", "fmt" = 3),
  list("raw" = "adj.r.squared", "clean" = "Adj. $R^2$", "fmt" = 3)
)

msummary(models_robust_ext,
         output = "../tables/tab4_robustness.tex",
         stars = c("*" = 0.1, "**" = 0.05, "***" = 0.01),
         statistic = c("({std.error})", "[{conf.low}, {conf.high}]"),
         conf_level = 0.95,
         coef_rename = c(
           "post_gst:tax_intensity" = "Post $\\times$ Intensity",
           "post_placebo:tax_intensity" = "Placebo $\\times$ Intensity"
         ),
         gof_map = gm_rob,
         add_rows = data.frame(
           V1 = "Clusters (states)",
           V2 = "35", V3 = "35", V4 = "35", V5 = "35", V6 = "35",
           V7 = "35", V8 = "35"
         ),
         title = "Robustness Checks: Alternative Samples, Outcomes, and Placebo Tests",
         notes = c("Standard errors clustered at the state level in parentheses.",
                    "95\\% confidence intervals in brackets.",
                    "Columns 1--5: DV is log(CPI). Column 6: DV is $|\\log CPI_{st} - \\overline{\\log CPI}_t|$.",
                    "Column 7: baseline with state-specific linear trends.",
                    "Column 2: excludes Nov 2016--Jun 2017. Column 3: truncated at Feb 2020.",
                    "Column 4: Fuel \\& Light (outside GST). Column 5: placebo July 2015 on pre-GST data."),
         escape = FALSE)

# ── Table 5: Leave-One-Out Summary ─────────────────────────────────────────
cat("Generating Table 5: Leave-one-out...\n")

loo_dt <- fread("../data/loo_results.csv")

sink("../tables/tab5_loo_summary.tex")
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Leave-One-Out Sensitivity: Excluding Each State}\n")
cat("\\label{tab:loo}\n")
cat("\\begin{tabular}{lc}\n")
cat("\\toprule\n")
cat("Statistic & Value \\\\\n")
cat("\\midrule\n")
cat(sprintf("Baseline estimate & %.5f \\\\\n", coef(m1)[[1]]))
cat(sprintf("LOO minimum & %.5f \\\\\n", min(loo_dt$estimate)))
cat(sprintf("LOO maximum & %.5f \\\\\n", max(loo_dt$estimate)))
cat(sprintf("LOO mean & %.5f \\\\\n", mean(loo_dt$estimate)))
cat(sprintf("LOO std. dev. & %.5f \\\\\n", sd(loo_dt$estimate)))
cat(sprintf("N states excluded & %d \\\\\n", nrow(loo_dt)))
cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{tablenotes}[flushleft]\\small\n")
cat("\\item \\textit{Notes:} Each row of the underlying analysis excludes one state ")
cat("and re-estimates the baseline specification. The table reports the distribution ")
cat("of the resulting coefficients on Post-GST $\\times$ Tax Intensity.\n")
cat("\\end{tablenotes}\n")
cat("\\end{table}\n")
sink()

# ── Table 6: Triple-Difference Results ──────────────────────────────────────
cat("Generating Table 6: Triple-diff...\n")

models_triple <- list(
  "State × Commodity DiD" = m3,
  "Triple-Diff (Full FE)" = m4
)

gm_triple <- list(
  list("raw" = "nobs", "clean" = "Observations", "fmt" = function(x) format(round(x), big.mark = ",")),
  list("raw" = "r.squared", "clean" = "$R^2$", "fmt" = 3),
  list("raw" = "adj.r.squared", "clean" = "Adj. $R^2$", "fmt" = 3),
  list("raw" = "FE: state_id^group_id", "clean" = "State $\\times$ Group FE", "fmt" = 0),
  list("raw" = "FE: group_id^time", "clean" = "Group $\\times$ Time FE", "fmt" = 0),
  list("raw" = "FE: state_id^time", "clean" = "State $\\times$ Time FE", "fmt" = 0)
)

msummary(models_triple,
         output = "../tables/tab6_triple_diff.tex",
         stars = c("*" = 0.1, "**" = 0.05, "***" = 0.01),
         statistic = c("({std.error})", "[{conf.low}, {conf.high}]"),
         conf_level = 0.95,
         coef_rename = c(
           "post_gst:tax_intensity:delta_tax" = "Post $\\times$ State Intensity $\\times$ $\\Delta$Tax",
           "post_gst:tax_intensity:abs_delta_tax" = "Post $\\times$ State Intensity $\\times$ $|\\Delta$Tax$|$"
         ),
         gof_map = gm_triple,
         add_rows = data.frame(
           V1 = "Clusters (states)",
           V2 = "35", V3 = "35"
         ),
         title = "Triple-Difference: State Tax Intensity $\\times$ Commodity Tax Change",
         notes = c("Standard errors clustered at the state level in parentheses.",
                    "95\\% confidence intervals in brackets.",
                    "Column 1: state$\\times$group and group$\\times$time FE.",
                    "Column 2: adds state$\\times$time FE (full triple-diff)."),
         escape = FALSE)

cat("\nAll tables saved to tables/ directory.\n")
