###############################################################################
# 06_tables.R — Generate all tables
# Paper: Flood Re and the Capitalization of Climate Risk Insurance
# APEP-0484
###############################################################################

source("00_packages.R")

cat("=== Phase 6: Table Generation ===\n")

# ---- Load data and models ----
ppd <- read_parquet(file.path(data_dir, "analysis_panel.parquet"))
setDT(ppd)
load(file.path(data_dir, "main_models.RData"))

rob_exists <- file.exists(file.path(data_dir, "robustness_models.RData"))
if (rob_exists) load(file.path(data_dir, "robustness_models.RData"))

ppd_main <- ppd[year >= 2009]

# ---- Table 1: Summary Statistics ----
cat("  Table 1: Summary statistics...\n")

# Create summary by group
groups <- list(
  "Full Sample" = ppd_main,
  "Flood Zone, Pre-2009" = ppd_main[in_flood_zone == TRUE & flood_re_eligible == TRUE],
  "Flood Zone, Post-2009" = ppd_main[in_flood_zone == TRUE & flood_re_eligible == FALSE],
  "No Flood Risk, Pre-2009" = ppd_main[in_flood_zone == FALSE & flood_re_eligible == TRUE],
  "No Flood Risk, Post-2009" = ppd_main[in_flood_zone == FALSE & flood_re_eligible == FALSE]
)

sumstats <- rbindlist(lapply(names(groups), function(g) {
  dt <- groups[[g]]
  data.table(
    Group = g,
    N = nrow(dt),
    Mean_Price = round(mean(dt$price)),
    Median_Price = round(median(dt$price)),
    SD_Price = round(sd(dt$price)),
    Pct_Detached = round(100 * mean(dt$property_type == "D"), 1),
    Pct_Semi = round(100 * mean(dt$property_type == "S"), 1),
    Pct_Terraced = round(100 * mean(dt$property_type == "T"), 1),
    Pct_Flat = round(100 * mean(dt$property_type == "F"), 1),
    Pct_Freehold = round(100 * mean(dt$duration == "F"), 1),
    Pct_NewBuild = round(100 * mean(dt$is_new_build), 1)
  )
}))

fwrite(sumstats, file.path(tab_dir, "tab1_summary_stats.csv"))

# LaTeX table
sumstats_tex <- kbl(sumstats, format = "latex", booktabs = TRUE,
                    caption = "Summary Statistics by Flood Risk and Construction Vintage",
                    label = "tab:sumstats",
                    col.names = c("Group", "N", "Mean", "Median", "SD",
                                  "Det.", "Semi", "Terr.", "Flat",
                                  "Freehold", "New Build")) %>%
  kable_styling(latex_options = c("scale_down")) %>%
  add_header_above(c(" " = 2, "Price (GBP)" = 3,
                      "Property Type (%)" = 4, "Tenure (%)" = 1, " " = 1))

writeLines(sumstats_tex, file.path(tab_dir, "tab1_summary_stats.tex"))

# ---- Table 2: Balance Table (pre-2016 means by group) ----
cat("  Table 2: Balance table...\n")

ppd_pre <- ppd_main[post_floodre == FALSE]

balance <- ppd_pre[in_flood_zone == TRUE, .(
  Variable = c("Price", "Log Price", "Pct Detached", "Pct Semi",
               "Pct Terraced", "Pct Flat", "Pct Freehold"),
  Pre2009 = c(
    mean(price[flood_re_eligible == TRUE]),
    mean(log_price[flood_re_eligible == TRUE]),
    100 * mean(property_type[flood_re_eligible == TRUE] == "D"),
    100 * mean(property_type[flood_re_eligible == TRUE] == "S"),
    100 * mean(property_type[flood_re_eligible == TRUE] == "T"),
    100 * mean(property_type[flood_re_eligible == TRUE] == "F"),
    100 * mean(duration[flood_re_eligible == TRUE] == "F")
  ),
  Post2009 = c(
    mean(price[flood_re_eligible == FALSE]),
    mean(log_price[flood_re_eligible == FALSE]),
    100 * mean(property_type[flood_re_eligible == FALSE] == "D"),
    100 * mean(property_type[flood_re_eligible == FALSE] == "S"),
    100 * mean(property_type[flood_re_eligible == FALSE] == "T"),
    100 * mean(property_type[flood_re_eligible == FALSE] == "F"),
    100 * mean(duration[flood_re_eligible == FALSE] == "F")
  )
)]

balance[, Difference := Pre2009 - Post2009]
balance[, Pre2009 := round(Pre2009, 2)]
balance[, Post2009 := round(Post2009, 2)]
balance[, Difference := round(Difference, 2)]

fwrite(balance, file.path(tab_dir, "tab2_balance.csv"))

balance_tex <- kbl(balance, format = "latex", booktabs = TRUE,
                   caption = "Pre-2016 Balance: Pre-2009 vs. Post-2009 Properties in Flood Zones",
                   label = "tab:balance") %>%
  kable_styling(latex_options = c("hold_position"))

writeLines(balance_tex, file.path(tab_dir, "tab2_balance.tex"))

# ---- Table 3: Main DDD Results ----
cat("  Table 3: Main results...\n")

main_res <- fread(file.path(tab_dir, "main_results.csv"))

# Create star indicators
main_res[, t_stat := ddd_coef / ddd_se]
main_res[, stars := ifelse(abs(t_stat) > 2.576, "***",
                     ifelse(abs(t_stat) > 1.960, "**",
                     ifelse(abs(t_stat) > 1.645, "*", "")))]

# Build LaTeX table manually
main_tex_lines <- c(
  "\\begin{table}[htbp]",
  "\\centering",
  "\\caption{Effect of Flood Re on Property Prices: Triple-Difference Estimates}",
  "\\label{tab:main_results}",
  "\\begin{tabular}{lcccc}",
  "\\toprule",
  " & (1) & (2) & (3) & (4) \\\\",
  "\\midrule",
  sprintf("Flood Zone $\\times$ Post-2016 $\\times$ Pre-2009 & %s%s & %s%s & %s%s & %s%s \\\\",
          format(round(main_res$ddd_coef[1], 4), nsmall = 4), main_res$stars[1],
          format(round(main_res$ddd_coef[2], 4), nsmall = 4), main_res$stars[2],
          format(round(main_res$ddd_coef[3], 4), nsmall = 4), main_res$stars[3],
          format(round(main_res$ddd_coef[4], 4), nsmall = 4), main_res$stars[4]),
  sprintf(" & (%s) & (%s) & (%s) & (%s) \\\\",
          format(round(main_res$ddd_se[1], 4), nsmall = 4),
          format(round(main_res$ddd_se[2], 4), nsmall = 4),
          format(round(main_res$ddd_se[3], 4), nsmall = 4),
          format(round(main_res$ddd_se[4], 4), nsmall = 4)),
  "\\midrule",
  "Two-way interactions & Yes & Yes & Absorbed & Absorbed \\\\",
  "Property controls & No & Yes & Yes & Yes \\\\",
  "District FE & Yes & Yes & Yes & No \\\\",
  "Postcode FE & No & No & No & Yes \\\\",
  "Year-Quarter FE & Yes & Yes & No & Yes \\\\",
  "District $\\times$ Year-Quarter FE & No & No & Yes & No \\\\",
  sprintf("Observations & %s & %s & %s & %s \\\\",
          format(main_res$n_obs[1], big.mark = ","),
          format(main_res$n_obs[2], big.mark = ","),
          format(main_res$n_obs[3], big.mark = ","),
          format(main_res$n_obs[4], big.mark = ",")),
  "\\bottomrule",
  "\\end{tabular}",
  "\\begin{tablenotes}[flushleft]",
  "\\small",
  "\\item \\textit{Notes:} Standard errors clustered by postcode district and year-quarter in parentheses.",
  "* $p<0.10$, ** $p<0.05$, *** $p<0.01$.",
  "Dependent variable is log transaction price.",
  "\\end{tablenotes}",
  "\\end{table}"
)

writeLines(main_tex_lines, file.path(tab_dir, "tab3_main_results.tex"))
fwrite(main_res, file.path(tab_dir, "tab3_main_results.csv"))

# ---- Table 4: Robustness summary ----
cat("  Table 4: Robustness summary...\n")

if (rob_exists && exists("rob_summary")) {
  rob_tex <- kbl(rob_summary[, .(Test, Coefficient = round(Coefficient, 4),
                                  SE = round(SE, 4), Stars)],
                 format = "latex", booktabs = TRUE,
                 caption = "Robustness Checks",
                 label = "tab:robustness") %>%
    kable_styling(latex_options = c("hold_position"))

  writeLines(rob_tex, file.path(tab_dir, "tab4_robustness.tex"))
  fwrite(rob_summary, file.path(tab_dir, "tab4_robustness.csv"))
}

# ---- Table 5: Heterogeneity ----
cat("  Table 5: Heterogeneity...\n")

het_combined <- rbind(
  fread(file.path(tab_dir, "heterogeneity_property_type.csv"))[, .(
    Dimension = "Property Type",
    Category = property_type,
    Estimate = round(estimate, 4),
    SE = round(se, 4),
    N = n
  )],
  fread(file.path(tab_dir, "heterogeneity_price_quartile.csv"))[, .(
    Dimension = "Price Quartile",
    Category = quartile,
    Estimate = round(estimate, 4),
    SE = round(se, 4),
    N = n
  )]
)

fwrite(het_combined, file.path(tab_dir, "tab5_heterogeneity.csv"))

het_tex <- kbl(het_combined, format = "latex", booktabs = TRUE,
               caption = "Heterogeneous Effects by Property Type and Price Quartile",
               label = "tab:heterogeneity") %>%
  kable_styling(latex_options = c("hold_position")) %>%
  pack_rows("Property Type", 1, 4) %>%
  pack_rows("Price Quartile", 5, 8)

writeLines(het_tex, file.path(tab_dir, "tab5_heterogeneity.tex"))

cat("\nAll tables generated.\n")
