## ============================================================
## 05_figures.R — Generate all figures
## APEP-0430: Does Workfare Catalyze Long-Run Development?
## ============================================================

source("00_packages.R")

data_dir <- "../data"
tab_dir  <- "../tables"
fig_dir  <- "../figures"
dir.create(fig_dir, showWarnings = FALSE, recursive = TRUE)

panel <- fread(file.path(data_dir, "district_year_panel.csv"))

## ════════════════════════════════════════════════════════════
## Figure 1: Raw Nightlight Trends by Phase
## ════════════════════════════════════════════════════════════

cat("=== Figure 1: Raw trends ===\n")

trends <- panel[, .(
  mean_light = mean(log_light, na.rm = TRUE),
  se_light   = sd(log_light, na.rm = TRUE) / sqrt(.N)
), by = .(year, phase_label = factor(
  ifelse(mgnrega_phase == 1, "Phase I",
    ifelse(mgnrega_phase == 2, "Phase II", "Phase III")),
  levels = c("Phase I", "Phase II", "Phase III")
))]

p1 <- ggplot(trends, aes(x = year, y = mean_light,
                           color = phase_label, fill = phase_label)) +
  geom_ribbon(aes(ymin = mean_light - 1.96 * se_light,
                  ymax = mean_light + 1.96 * se_light),
              alpha = 0.15, color = NA) +
  geom_line(linewidth = 0.8) +
  geom_point(size = 1.5) +
  geom_vline(xintercept = 2006.5, linetype = "dashed", color = "grey40") +
  annotate("text", x = 2006.8, y = max(trends$mean_light) * 0.95,
           label = "Phase I\nstart", hjust = 0, size = 3, color = "grey40") +
  geom_vline(xintercept = 2012.5, linetype = "dotted", color = "grey60") +
  annotate("text", x = 2012.8, y = max(trends$mean_light) * 0.85,
           label = "DMSP→VIIRS", hjust = 0, size = 2.5, color = "grey60") +
  scale_color_manual(values = phase_colors) +
  scale_fill_manual(values = phase_colors) +
  labs(x = "Year", y = "Mean log(nightlights + 1)",
       color = "MGNREGA Phase", fill = "MGNREGA Phase",
       title = "Nighttime Luminosity by MGNREGA Phase, 1994--2023",
       caption = "Note: Shaded bands show 95% confidence intervals. Vertical dashed line marks Phase I start (Feb 2006).\nDMSP data calibrated to VIIRS using 2012--2013 overlap.") +
  scale_x_continuous(breaks = seq(1994, 2023, by = 3))

ggsave(file.path(fig_dir, "fig1_raw_trends.pdf"), p1,
       width = 8, height = 5.5)
cat("Saved: fig1_raw_trends.pdf\n")

## ════════════════════════════════════════════════════════════
## Figure 2: CS Dynamic Event Study
## ════════════════════════════════════════════════════════════

cat("=== Figure 2: CS event study ===\n")

cs_dynamic <- readRDS(file.path(tab_dir, "cs_dynamic.rds"))

## Extract event-time estimates
es_dt <- data.table(
  event_time = cs_dynamic$egt,
  att        = cs_dynamic$att.egt,
  se         = cs_dynamic$se.egt
)
es_dt[, ci_lo := att - 1.96 * se]
es_dt[, ci_hi := att + 1.96 * se]

p2 <- ggplot(es_dt, aes(x = event_time, y = att)) +
  geom_hline(yintercept = 0, linetype = "solid", color = "grey70") +
  geom_vline(xintercept = -0.5, linetype = "dashed", color = "grey50") +
  geom_ribbon(aes(ymin = ci_lo, ymax = ci_hi),
              alpha = 0.15, fill = "#377EB8") +
  geom_line(color = "#377EB8", linewidth = 0.7) +
  geom_point(color = "#377EB8", size = 2) +
  labs(x = "Years Relative to MGNREGA Implementation",
       y = "ATT (log nightlights)",
       title = "Dynamic Treatment Effects of MGNREGA on Nighttime Luminosity",
       subtitle = "Callaway and Sant'Anna (2021) estimator, not-yet-treated comparison",
       caption = "Note: Shaded band shows pointwise 95% confidence intervals. Standard errors clustered at district level.\nPre-treatment coefficients test the parallel trends assumption.") +
  scale_x_continuous(breaks = seq(-12, 16, by = 2))

ggsave(file.path(fig_dir, "fig2_cs_event_study.pdf"), p2,
       width = 8, height = 5.5)
cat("Saved: fig2_cs_event_study.pdf\n")

## ════════════════════════════════════════════════════════════
## Figure 3: Sun-Abraham Event Study (TWFE)
## ════════════════════════════════════════════════════════════

cat("=== Figure 3: Sun-Abraham event study ===\n")

twfe_es <- readRDS(file.path(tab_dir, "twfe_event_study.rds"))

p3 <- iplot(twfe_es, main = "", xlab = "Years Relative to Treatment",
            ylab = "Coefficient (log nightlights)")
## Save via ggsave workaround
pdf(file.path(fig_dir, "fig3_sunab_event_study.pdf"), width = 8, height = 5.5)
iplot(twfe_es,
      main = "Sun-Abraham Event Study: MGNREGA and Nighttime Luminosity",
      xlab = "Years Relative to Treatment",
      ylab = "Coefficient (log nightlights)")
dev.off()
cat("Saved: fig3_sunab_event_study.pdf\n")

## ════════════════════════════════════════════════════════════
## Figure 4: Cohort-Specific ATTs
## ════════════════════════════════════════════════════════════

cat("=== Figure 4: Cohort-specific ATTs ===\n")

cs_group <- readRDS(file.path(tab_dir, "cs_group.rds"))

group_dt <- data.table(
  cohort = cs_group$egt,
  att    = cs_group$att.egt,
  se     = cs_group$se.egt
)
group_dt[, ci_lo := att - 1.96 * se]
group_dt[, ci_hi := att + 1.96 * se]
group_dt[, phase := factor(
  ifelse(cohort == 2007, "Phase I",
    ifelse(cohort == 2008, "Phase II", "Phase III")),
  levels = c("Phase I", "Phase II", "Phase III")
)]

p4 <- ggplot(group_dt, aes(x = phase, y = att, color = phase)) +
  geom_hline(yintercept = 0, linetype = "solid", color = "grey70") +
  geom_pointrange(aes(ymin = ci_lo, ymax = ci_hi), size = 1) +
  scale_color_manual(values = phase_colors) +
  labs(x = "MGNREGA Cohort", y = "ATT (log nightlights)",
       title = "Cohort-Specific Average Treatment Effects",
       subtitle = "Callaway-Sant'Anna estimates aggregated by treatment cohort",
       caption = "Note: Error bars show 95% confidence intervals.\nPhase I treated 2007, Phase II 2008, Phase III 2009.") +
  theme(legend.position = "none")

ggsave(file.path(fig_dir, "fig4_cohort_atts.pdf"), p4,
       width = 6, height = 5)
cat("Saved: fig4_cohort_atts.pdf\n")

## ════════════════════════════════════════════════════════════
## Figure 5: Randomization Inference Distribution
## ════════════════════════════════════════════════════════════

cat("=== Figure 5: RI distribution ===\n")

ri <- readRDS(file.path(tab_dir, "ri_results.rds"))

p5 <- ggplot(data.frame(coef = ri$permuted), aes(x = coef)) +
  geom_histogram(bins = 50, fill = "grey70", color = "white") +
  geom_vline(xintercept = ri$actual, color = "#E41A1C",
             linewidth = 1, linetype = "solid") +
  annotate("text", x = ri$actual, y = Inf, vjust = -0.5,
           label = sprintf("Actual = %.4f\nRI p = %.3f",
                           ri$actual, ri$pvalue),
           color = "#E41A1C", hjust = -0.1, size = 3.5) +
  labs(x = "Permuted Treatment Coefficient",
       y = "Count",
       title = "Randomization Inference: MGNREGA Treatment Effect",
       subtitle = paste0(length(ri$permuted),
                         " permutations of district-phase assignment"),
       caption = "Note: Red line shows actual estimated coefficient. Grey histogram shows distribution under random assignment.")

ggsave(file.path(fig_dir, "fig5_ri_distribution.pdf"), p5,
       width = 7, height = 5)
cat("Saved: fig5_ri_distribution.pdf\n")

## ════════════════════════════════════════════════════════════
## Figure 6: Heterogeneity by SC/ST Share
## ════════════════════════════════════════════════════════════

cat("=== Figure 6: Heterogeneity ===\n")

het_scst <- readRDS(file.path(tab_dir, "het_scst.rds"))
het_ag   <- readRDS(file.path(tab_dir, "het_ag.rds"))

## Build heterogeneity data for plotting
build_het_dt <- function(het_list, var_name) {
  dt <- rbindlist(lapply(names(het_list), function(q) {
    mod <- het_list[[q]]
    data.table(
      quartile = q,
      variable = var_name,
      coef     = coef(mod)["treated"],
      se       = se(mod)["treated"]
    )
  }))
  dt[, ci_lo := coef - 1.96 * se]
  dt[, ci_hi := coef + 1.96 * se]
  return(dt)
}

het_dt <- rbindlist(list(
  build_het_dt(het_scst, "SC/ST Population Share"),
  build_het_dt(het_ag, "Agricultural Labor Share")
))

p6 <- ggplot(het_dt, aes(x = quartile, y = coef, color = variable)) +
  geom_hline(yintercept = 0, color = "grey70") +
  geom_pointrange(aes(ymin = ci_lo, ymax = ci_hi),
                  position = position_dodge(width = 0.3), size = 0.7) +
  facet_wrap(~variable, scales = "free_x") +
  scale_color_manual(values = c("#E41A1C", "#377EB8")) +
  labs(x = "Baseline Quartile (Q1 = Lowest, Q4 = Highest)",
       y = "TWFE Coefficient (log nightlights)",
       title = "Heterogeneous Effects by Baseline District Characteristics",
       caption = "Note: Error bars show 95% CIs. Coefficients from TWFE with district and year FE.\nQuartiles defined by Census 2001 baseline characteristics.") +
  theme(legend.position = "none")

ggsave(file.path(fig_dir, "fig6_heterogeneity.pdf"), p6,
       width = 9, height = 5)
cat("Saved: fig6_heterogeneity.pdf\n")

## ════════════════════════════════════════════════════════════
## Figure 7: Bacon Decomposition (if available)
## ════════════════════════════════════════════════════════════

cat("=== Figure 7: Bacon decomposition ===\n")

bacon_file <- file.path(tab_dir, "bacon_decomp.rds")
if (file.exists(bacon_file)) {
  bacon_out <- readRDS(bacon_file)

  p7 <- ggplot(bacon_out, aes(x = weight, y = estimate, color = type)) +
    geom_hline(yintercept = 0, color = "grey70") +
    geom_point(size = 2, alpha = 0.7) +
    scale_color_brewer(palette = "Set1") +
    labs(x = "Weight in TWFE Estimate", y = "2×2 DiD Estimate",
         color = "Comparison Type",
         title = "Goodman-Bacon Decomposition of TWFE Estimate",
         caption = "Note: Each point is a 2×2 DiD comparison. Size reflects weight in overall TWFE.") +
    theme(legend.position = "bottom")

  ggsave(file.path(fig_dir, "fig7_bacon_decomp.pdf"), p7,
         width = 8, height = 5.5)
  cat("Saved: fig7_bacon_decomp.pdf\n")
} else {
  cat("Bacon decomposition not available, skipping.\n")
}

## ════════════════════════════════════════════════════════════
## Figure 8: DMSP-Only vs VIIRS-Only Comparison
## ════════════════════════════════════════════════════════════

cat("=== Figure 8: Sensor comparison ===\n")

## Mean nightlights by phase in overlap period (2012-2013)
overlap_trends <- panel[year %in% 2008:2016, .(
  mean_light = mean(log_light, na.rm = TRUE)
), by = .(year, source, phase_label = factor(
  ifelse(mgnrega_phase == 1, "Phase I",
    ifelse(mgnrega_phase == 2, "Phase II", "Phase III")),
  levels = c("Phase I", "Phase II", "Phase III")
))]

p8 <- ggplot(overlap_trends, aes(x = year, y = mean_light,
                                   color = phase_label,
                                   linetype = source)) +
  geom_line(linewidth = 0.7) +
  geom_point(size = 1.5) +
  scale_color_manual(values = phase_colors) +
  labs(x = "Year", y = "Mean log(nightlights + 1)",
       color = "MGNREGA Phase", linetype = "Sensor",
       title = "Nightlight Sensor Comparison in Overlap Period",
       caption = "Note: DMSP (calibrated) and VIIRS overlap in 2012--2013.\nSolid lines show the sensor used in the main analysis.") +
  scale_x_continuous(breaks = 2008:2016)

ggsave(file.path(fig_dir, "fig8_sensor_comparison.pdf"), p8,
       width = 8, height = 5.5)
cat("Saved: fig8_sensor_comparison.pdf\n")

cat("\n=== All figures generated ===\n")
