## ============================================================
## 06_tables.R — Generate all LaTeX tables
## APEP-0430: Does Workfare Catalyze Long-Run Development?
## ============================================================

source("00_packages.R")

data_dir <- "../data"
tab_dir  <- "../tables"

panel    <- fread(file.path(data_dir, "district_year_panel.csv"))
phase_dt <- fread(file.path(data_dir, "district_phase_assignment.csv"))

## ════════════════════════════════════════════════════════════
## Table 1: Summary Statistics
## ════════════════════════════════════════════════════════════

cat("=== Table 1: Summary statistics ===\n")

## Panel A: District-level baseline characteristics (Census 2001)
summ_phase <- phase_dt[, .(
  N              = .N,
  pop_mean       = mean(pop, na.rm = TRUE),
  pop_sd         = sd(pop, na.rm = TRUE),
  sc_st_mean     = mean(sc_st_share, na.rm = TRUE),
  sc_st_sd       = sd(sc_st_share, na.rm = TRUE),
  ag_labor_mean  = mean(ag_labor_share, na.rm = TRUE),
  ag_labor_sd    = sd(ag_labor_share, na.rm = TRUE),
  illit_mean     = mean(illiteracy_rate, na.rm = TRUE),
  illit_sd       = sd(illiteracy_rate, na.rm = TRUE),
  backward_mean  = mean(backwardness_idx, na.rm = TRUE),
  backward_sd    = sd(backwardness_idx, na.rm = TRUE)
), by = mgnrega_phase]

## Panel B: Nightlights by period
pre_light <- panel[year < 2007, .(
  pre_light_mean = mean(log_light, na.rm = TRUE),
  pre_light_sd   = sd(log_light, na.rm = TRUE)
), by = mgnrega_phase]

post_light <- panel[year >= 2007, .(
  post_light_mean = mean(log_light, na.rm = TRUE),
  post_light_sd   = sd(log_light, na.rm = TRUE)
), by = mgnrega_phase]

summ <- merge(summ_phase, pre_light, by = "mgnrega_phase")
summ <- merge(summ, post_light, by = "mgnrega_phase")

## Write LaTeX table
sink(file.path(tab_dir, "tab1_summary.tex"))
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Summary Statistics by MGNREGA Phase}\n")
cat("\\label{tab:summary}\n")
cat("\\small\n")
cat("\\begin{tabular}{lccc}\n")
cat("\\toprule\n")
cat(" & Phase I & Phase II & Phase III \\\\\n")
cat("\\midrule\n")
cat("\\multicolumn{4}{l}{\\textit{Panel A: Baseline Characteristics (Census 2001)}} \\\\\n")
cat(sprintf("Districts & %d & %d & %d \\\\\n",
            summ[1, N], summ[2, N], summ[3, N]))
cat(sprintf("Population (thousands) & %.0f & %.0f & %.0f \\\\\n",
            summ[1, pop_mean]/1000, summ[2, pop_mean]/1000,
            summ[3, pop_mean]/1000))
cat(sprintf(" & (%.0f) & (%.0f) & (%.0f) \\\\\n",
            summ[1, pop_sd]/1000, summ[2, pop_sd]/1000,
            summ[3, pop_sd]/1000))
cat(sprintf("SC/ST share & %.3f & %.3f & %.3f \\\\\n",
            summ[1, sc_st_mean], summ[2, sc_st_mean], summ[3, sc_st_mean]))
cat(sprintf(" & (%.3f) & (%.3f) & (%.3f) \\\\\n",
            summ[1, sc_st_sd], summ[2, sc_st_sd], summ[3, sc_st_sd]))
cat(sprintf("Agricultural labor share & %.3f & %.3f & %.3f \\\\\n",
            summ[1, ag_labor_mean], summ[2, ag_labor_mean],
            summ[3, ag_labor_mean]))
cat(sprintf(" & (%.3f) & (%.3f) & (%.3f) \\\\\n",
            summ[1, ag_labor_sd], summ[2, ag_labor_sd],
            summ[3, ag_labor_sd]))
cat(sprintf("Illiteracy rate & %.3f & %.3f & %.3f \\\\\n",
            summ[1, illit_mean], summ[2, illit_mean], summ[3, illit_mean]))
cat(sprintf(" & (%.3f) & (%.3f) & (%.3f) \\\\\n",
            summ[1, illit_sd], summ[2, illit_sd], summ[3, illit_sd]))
cat(sprintf("Backwardness index & %.3f & %.3f & %.3f \\\\\n",
            summ[1, backward_mean], summ[2, backward_mean],
            summ[3, backward_mean]))
cat("\\midrule\n")
cat("\\multicolumn{4}{l}{\\textit{Panel B: Nighttime Luminosity (log(light + 1))}} \\\\\n")
cat(sprintf("Pre-treatment (1994--2006) & %.3f & %.3f & %.3f \\\\\n",
            summ[1, pre_light_mean], summ[2, pre_light_mean],
            summ[3, pre_light_mean]))
cat(sprintf(" & (%.3f) & (%.3f) & (%.3f) \\\\\n",
            summ[1, pre_light_sd], summ[2, pre_light_sd],
            summ[3, pre_light_sd]))
cat(sprintf("Post-treatment (2007--2023) & %.3f & %.3f & %.3f \\\\\n",
            summ[1, post_light_mean], summ[2, post_light_mean],
            summ[3, post_light_mean]))
cat(sprintf(" & (%.3f) & (%.3f) & (%.3f) \\\\\n",
            summ[1, post_light_sd], summ[2, post_light_sd],
            summ[3, post_light_sd]))
cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{minipage}{0.95\\textwidth}\n")
cat("\\vspace{0.3em}\n")
cat("\\footnotesize \\textit{Notes:} Standard deviations in parentheses. Phase I districts (200) were assigned in February 2006, Phase II (+130) in April 2007, and Phase III (remaining) in April 2008. Assignment based on Planning Commission backwardness index (SC/ST share, agricultural labor share, illiteracy rate). Pre-treatment nightlights use DMSP data calibrated to VIIRS; post-treatment uses VIIRS from 2012 onward.\n")
cat("\\end{minipage}\n")
cat("\\end{table}\n")
sink()
cat("Saved: tab1_summary.tex\n")

## ════════════════════════════════════════════════════════════
## Table 2: Main Results
## ════════════════════════════════════════════════════════════

cat("=== Table 2: Main results ===\n")

twfe1         <- readRDS(file.path(tab_dir, "twfe_binary.rds"))
twfe_trends   <- readRDS(file.path(tab_dir, "twfe_dist_trends.rds"))
twfe_state_yr <- readRDS(file.path(tab_dir, "twfe_state_year.rds"))
twfe_weighted <- readRDS(file.path(tab_dir, "twfe_pop_weighted.rds"))
cs_simple     <- readRDS(file.path(tab_dir, "cs_simple.rds"))

## Use etable for clean output
etable(twfe1, twfe_trends, twfe_state_yr, twfe_weighted,
       file = file.path(tab_dir, "tab2_main_results.tex"),
       title = "Effect of MGNREGA on Nighttime Luminosity",
       label = "tab:main",
       headers = c("TWFE", "Dist. Trends", "State$\\times$Year FE",
                    "Pop. Weighted"),
       depvar = FALSE,
       fixef.group = list("District FE" = "dist_id",
                           "Year FE" = "^year$",
                           "District Trends" = "dist_id\\[year\\]",
                           "State $\\times$ Year FE" = "state_year"),
       se.below = TRUE,
       digits = 4,
       style.tex = style.tex("aer"),
       notes = paste0("Notes: Dependent variable is log(nightlights + 1). ",
                       "Standard errors clustered at the district level in parentheses. ",
                       "Column (4) weights by Census 2001 population. ",
                       "MGNREGA Phase I began February 2006 (200 districts), ",
                       "Phase II April 2007 (+130), Phase III April 2008 (all remaining). ",
                       "Callaway-Sant'Anna overall ATT = ",
                       sprintf("%.4f", cs_simple$overall.att),
                       " (SE = ", sprintf("%.4f", cs_simple$overall.se), ")."),
       replace = TRUE)
cat("Saved: tab2_main_results.tex\n")

## ════════════════════════════════════════════════════════════
## Table 3: Robustness Across Specifications
## ════════════════════════════════════════════════════════════

cat("=== Table 3: Robustness ===\n")

twfe_dmsp    <- readRDS(file.path(tab_dir, "twfe_dmsp_only.rds"))
twfe_viirs   <- readRDS(file.path(tab_dir, "twfe_viirs_only.rds"))
twfe_placebo <- readRDS(file.path(tab_dir, "twfe_placebo.rds"))
twfe_p1p3    <- readRDS(file.path(tab_dir, "twfe_phase1_vs3.rds"))

etable(twfe_dmsp, twfe_viirs, twfe_placebo, twfe_p1p3,
       file = file.path(tab_dir, "tab3_robustness.tex"),
       title = "Robustness Checks",
       label = "tab:robust",
       headers = c("DMSP Only", "VIIRS Only",
                    "Placebo", "Phase I vs III"),
       depvar = FALSE,
       se.below = TRUE,
       digits = 4,
       style.tex = style.tex("aer"),
       notes = paste0("Notes: Column (1) uses DMSP nightlights only (1994--2013). ",
                       "Column (2) uses VIIRS only (2012--2023). ",
                       "Column (3) tests a placebo treatment shifted 5 years earlier, ",
                       "estimated on pre-MGNREGA data only. ",
                       "Column (4) restricts to Phase I vs Phase III districts."),
       replace = TRUE)
cat("Saved: tab3_robustness.tex\n")

## ════════════════════════════════════════════════════════════
## Table 4: Heterogeneous Effects
## ════════════════════════════════════════════════════════════

cat("=== Table 4: Heterogeneity ===\n")

het_scst <- readRDS(file.path(tab_dir, "het_scst.rds"))
het_ag   <- readRDS(file.path(tab_dir, "het_ag.rds"))
het_lit  <- readRDS(file.path(tab_dir, "het_lit.rds"))

## Create etable with all quartile regressions
all_het <- c(het_scst, het_ag, het_lit)
het_names <- c(paste("SC/ST", names(het_scst)),
               paste("Ag Labor", names(het_ag)),
               paste("Literacy", names(het_lit)))

if (length(all_het) > 0) {
  etable(all_het,
         file = file.path(tab_dir, "tab4_heterogeneity.tex"),
         title = "Heterogeneous Treatment Effects by Baseline Characteristics",
         label = "tab:het",
         headers = het_names,
         depvar = FALSE,
         se.below = TRUE,
         digits = 4,
         style.tex = style.tex("aer"),
         notes = paste0("Notes: Each column estimates TWFE on a subsample defined ",
                         "by quartiles of the baseline (Census 2001) characteristic. ",
                         "Q1 = lowest quartile, Q4 = highest."),
         replace = TRUE)
  cat("Saved: tab4_heterogeneity.tex\n")
}

cat("\n=== All tables generated ===\n")
