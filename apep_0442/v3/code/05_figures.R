## ============================================================================
## 05_figures.R — All figures for The First Retirement Age v3
## Project: Costa Union Army data, RDD at age 62
## ============================================================================

source("code/00_packages.R")

cat("=== GENERATING FIGURES ===\n\n")

## Load data
cross <- readRDS(file.path(data_dir, "cross_section_sample.rds"))
panel <- readRDS(file.path(data_dir, "panel_sample.rds"))
main  <- readRDS(file.path(data_dir, "main_results.rds"))
fs    <- readRDS(file.path(data_dir, "first_stage_results.rds"))
robust <- readRDS(file.path(data_dir, "robust_results.rds"))

cross[, running := age_1907 - 62]
cross[, above_62 := as.integer(age_1907 >= 62)]
panel[, running := age_1907 - 62]
panel[, above_62 := as.integer(age_1907 >= 62)]

## =========================================================================
## FIGURE 1: Cross-Sectional RDD — LFP(1910) by age at 1907
## =========================================================================

cat("Fig 1: Cross-sectional RDD scatter\n")
cell_cross <- cross[age_1907 >= 55 & age_1907 <= 85,
                     .(lfp = mean(lfp_1910), N = .N),
                     by = .(age = floor(age_1907))]
cell_cross[, running := age - 62]

## Fit lines separately below and above cutoff
dt_below <- cross[running >= -7 & running < 0]
dt_above <- cross[running >= 0 & running <= 15]
fit_below <- lm(lfp_1910 ~ running, data = dt_below)
fit_above <- lm(lfp_1910 ~ running, data = dt_above)
pred_below <- data.table(running = seq(-7, -0.01, 0.1))
pred_below[, lfp := predict(fit_below, pred_below)]
pred_above <- data.table(running = seq(0, 15, 0.1))
pred_above[, lfp := predict(fit_above, pred_above)]

p1 <- ggplot() +
  geom_point(data = cell_cross[age >= 55 & age <= 77],
             aes(x = running, y = lfp, size = N),
             color = apep_blue, alpha = 0.7) +
  geom_line(data = pred_below, aes(x = running, y = lfp),
            color = apep_red, linewidth = 1) +
  geom_line(data = pred_above, aes(x = running, y = lfp),
            color = apep_red, linewidth = 1) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "grey40") +
  scale_size_continuous(range = c(1, 6), guide = "none") +
  labs(x = "Age at 1907 minus 62",
       y = "Labor Force Participation (1910)",
       subtitle = "Costa Union Army sample, bin means and local linear fit") +
  coord_cartesian(xlim = c(-7, 16))

ggsave(file.path(fig_dir, "fig1_rdd_lfp.pdf"), p1, width = 8, height = 5.5)
ggsave(file.path(fig_dir, "fig1_rdd_lfp.png"), p1, width = 8, height = 5.5, dpi = 300)

## =========================================================================
## FIGURE 2: Panel RDD — ΔY by age at 1907
## =========================================================================

cat("Fig 2: Panel RDD\n")
cell_panel <- panel[age_1907 >= 55 & age_1907 <= 85,
                     .(delta = mean(delta_lfp), N = .N),
                     by = .(age = floor(age_1907))]
cell_panel[, running := age - 62]

dt_pb <- panel[running >= -7 & running < 0]
dt_pa <- panel[running >= 0 & running <= 15]
fit_pb <- lm(delta_lfp ~ running, data = dt_pb)
fit_pa <- lm(delta_lfp ~ running, data = dt_pa)
pred_pb <- data.table(running = seq(-7, -0.01, 0.1))
pred_pb[, delta := predict(fit_pb, pred_pb)]
pred_pa <- data.table(running = seq(0, 15, 0.1))
pred_pa[, delta := predict(fit_pa, pred_pa)]

p2 <- ggplot() +
  geom_point(data = cell_panel[age >= 55 & age <= 77],
             aes(x = running, y = delta, size = N),
             color = apep_blue, alpha = 0.7) +
  geom_line(data = pred_pb, aes(x = running, y = delta),
            color = apep_red, linewidth = 1) +
  geom_line(data = pred_pa, aes(x = running, y = delta),
            color = apep_red, linewidth = 1) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "grey40") +
  geom_hline(yintercept = 0, linetype = "dotted", color = "grey60") +
  scale_size_continuous(range = c(1, 6), guide = "none") +
  labs(x = "Age at 1907 minus 62",
       y = expression(Delta * "LFP (1910 minus 1900)"),
       subtitle = "Panel sample, same veterans in 1900 and 1910 censuses") +
  coord_cartesian(xlim = c(-7, 16))

ggsave(file.path(fig_dir, "fig2_panel_rdd.pdf"), p2, width = 8, height = 5.5)
ggsave(file.path(fig_dir, "fig2_panel_rdd.png"), p2, width = 8, height = 5.5, dpi = 300)

## =========================================================================
## FIGURE 3: First Stage — Pension take-up at 62
## =========================================================================

cat("Fig 3: First stage pension\n")
fs_age <- copy(fs$fs_by_age)
fs_age[, running := age_1907 - 62]

p3 <- ggplot(fs_age[age_1907 >= 55 & age_1907 <= 80],
             aes(x = running, y = pct_1907act / 100)) +
  geom_point(aes(size = N), color = apep_blue, alpha = 0.7) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "grey40") +
  scale_size_continuous(range = c(1, 5), guide = "none") +
  scale_y_continuous(labels = percent_format()) +
  labs(x = "Age at 1907 minus 62",
       y = "Fraction Under 1907 Act",
       subtitle = "First stage: fraction receiving age-based pension by age at Act passage") +
  coord_cartesian(xlim = c(-7, 18))

ggsave(file.path(fig_dir, "fig3_first_stage.pdf"), p3, width = 8, height = 5.5)
ggsave(file.path(fig_dir, "fig3_first_stage.png"), p3, width = 8, height = 5.5, dpi = 300)

## =========================================================================
## FIGURE 4: First Stage — Pension amount at 62
## =========================================================================

cat("Fig 4: Pension amount\n")
p4 <- ggplot(fs_age[age_1907 >= 55 & age_1907 <= 80],
             aes(x = running, y = mean_pen_amt)) +
  geom_point(aes(size = N), color = apep_orange, alpha = 0.7) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "grey40") +
  scale_size_continuous(range = c(1, 5), guide = "none") +
  labs(x = "Age at 1907 minus 62",
       y = "Mean Monthly Pension ($)",
       subtitle = "Monthly pension dollars at 1910 census") +
  coord_cartesian(xlim = c(-7, 18))

ggsave(file.path(fig_dir, "fig4_pension_amount.pdf"), p4, width = 8, height = 5.5)
ggsave(file.path(fig_dir, "fig4_pension_amount.png"), p4, width = 8, height = 5.5, dpi = 300)

## =========================================================================
## FIGURE 5: Pre-Treatment Falsification — LFP(1900) at 62
## =========================================================================

cat("Fig 5: Pre-treatment falsification\n")
cell_pre <- panel[age_1907 >= 55 & age_1907 <= 85,
                   .(lfp = mean(lfp_1900), N = .N),
                   by = .(age = floor(age_1907))]
cell_pre[, running := age - 62]

p5 <- ggplot(cell_pre[age >= 55 & age <= 77],
             aes(x = running, y = lfp, size = N)) +
  geom_point(color = apep_green, alpha = 0.7) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "grey40") +
  geom_smooth(method = "lm", se = FALSE, color = apep_dark, linewidth = 0.8) +
  scale_size_continuous(range = c(1, 6), guide = "none") +
  labs(x = "Age at 1907 minus 62",
       y = "Labor Force Participation (1900)",
       subtitle = "LFP in 1900 (before 1907 Act) should be smooth at the cutoff") +
  coord_cartesian(xlim = c(-7, 16))

ggsave(file.path(fig_dir, "fig5_falsification.pdf"), p5, width = 8, height = 5.5)
ggsave(file.path(fig_dir, "fig5_falsification.png"), p5, width = 8, height = 5.5, dpi = 300)

## =========================================================================
## FIGURE 6: Covariate Balance
## =========================================================================

cat("Fig 6: Covariate balance\n")
bal <- main$balance
if (nrow(bal) > 0) {
  bal[, variable := factor(variable, levels = rev(variable))]
  p6 <- ggplot(bal, aes(x = coef, y = variable)) +
    geom_point(size = 3, color = apep_blue) +
    geom_errorbarh(aes(xmin = ci_lo, xmax = ci_hi), height = 0.2, color = apep_blue) +
    geom_vline(xintercept = 0, linetype = "dashed") +
    labs(x = "RD Estimate (robust 95% CI)",
         y = "",
         subtitle = "Pre-treatment characteristics should be continuous at cutoff")
  ggsave(file.path(fig_dir, "fig6_balance.pdf"), p6, width = 7, height = 5)
  ggsave(file.path(fig_dir, "fig6_balance.png"), p6, width = 7, height = 5, dpi = 300)
}

## =========================================================================
## FIGURE 7: Density Test
## =========================================================================

cat("Fig 7: Density\n")
age_counts <- cross[age_1907 >= 55 & age_1907 <= 85,
                     .N, by = .(age = floor(age_1907))]
age_counts[, running := age - 62]

p7 <- ggplot(age_counts, aes(x = running, y = N)) +
  geom_bar(stat = "identity", fill = apep_blue, alpha = 0.7, width = 0.8) +
  geom_vline(xintercept = 0, linetype = "dashed", color = apep_red, linewidth = 1) +
  labs(x = "Age at 1907 minus 62",
       y = "Number of Veterans",
       subtitle = paste0("McCrary test: p = ",
                         round(main$density$test$p_jk, 3))) +
  coord_cartesian(xlim = c(-7, 20))

ggsave(file.path(fig_dir, "fig7_density.pdf"), p7, width = 8, height = 5)
ggsave(file.path(fig_dir, "fig7_density.png"), p7, width = 8, height = 5, dpi = 300)

## =========================================================================
## FIGURE 8: Bandwidth Sensitivity
## =========================================================================

cat("Fig 8: Bandwidth sensitivity\n")
## Use full bandwidth grid (cross-section + panel) from robustness
bw_all <- robust$bandwidth
if (!is.null(bw_all) && nrow(bw_all) > 0) {
  ## Compute CI from conventional coef ± 1.96 * robust SE
  bw_all[, ci_lo_conv := coef - 1.96 * se]
  bw_all[, ci_hi_conv := coef + 1.96 * se]
  p8 <- ggplot(bw_all, aes(x = bandwidth, y = coef, color = design)) +
    geom_point(size = 3, position = position_dodge(width = 0.5)) +
    geom_errorbar(aes(ymin = ci_lo_conv, ymax = ci_hi_conv),
                  width = 0.3, position = position_dodge(width = 0.5)) +
    geom_hline(yintercept = 0, linetype = "dashed") +
    scale_color_manual(values = c("Cross-section" = apep_blue, "Panel" = apep_red)) +
    labs(x = "Bandwidth (years)",
         y = "RD Estimate",
         color = "Design",
         subtitle = "RDD estimates across bandwidths (conventional estimate, robust SE)")
  ggsave(file.path(fig_dir, "fig8_bandwidth.pdf"), p8, width = 8, height = 5)
  ggsave(file.path(fig_dir, "fig8_bandwidth.png"), p8, width = 8, height = 5, dpi = 300)
}

## =========================================================================
## FIGURE 9: Placebo Cutoffs
## =========================================================================

cat("Fig 9: Placebo cutoffs\n")
plac <- robust$placebo
if (!is.null(plac) && nrow(plac) > 0) {
  ## Add true cutoff
  true_est <- data.table(cutoff = 62, coef = main$cross_section$coef[1],
                         se = main$cross_section$se[3], pval = main$cross_section$pv[3])
  plac_all <- rbind(plac, true_est, fill = TRUE)
  plac_all[, is_true := cutoff == 62]
  plac_all[, ci_lo := coef - 1.96 * se]
  plac_all[, ci_hi := coef + 1.96 * se]

  p9 <- ggplot(plac_all, aes(x = cutoff, y = coef, color = is_true)) +
    geom_point(size = 3) +
    geom_errorbar(aes(ymin = ci_lo, ymax = ci_hi), width = 0.5) +
    geom_hline(yintercept = 0, linetype = "dashed") +
    scale_color_manual(values = c("TRUE" = apep_red, "FALSE" = apep_blue), guide = "none") +
    labs(x = "Placebo Cutoff Age",
         y = "RD Estimate",
         subtitle = "Red = true cutoff (62), blue = placebos")
  ggsave(file.path(fig_dir, "fig9_placebo.pdf"), p9, width = 7, height = 5)
  ggsave(file.path(fig_dir, "fig9_placebo.png"), p9, width = 7, height = 5, dpi = 300)
}

## =========================================================================
## FIGURE 10: RI Distribution (if available)
## =========================================================================

cat("Fig 10: RI distribution\n")
ri_file <- file.path(data_dir, "ri_results.rds")
if (file.exists(ri_file)) {
  ri <- readRDS(ri_file)
  ri_df <- data.table(perm = ri$cross_section$permutations)
  p10 <- ggplot(ri_df[!is.na(perm)], aes(x = perm)) +
    geom_histogram(bins = 50, fill = apep_blue, alpha = 0.7) +
    geom_vline(xintercept = ri$cross_section$observed,
               color = apep_red, linewidth = 1.2) +
    labs(x = "Permutation RD Estimates",
         y = "Count",
         subtitle = paste0("Observed (red line) vs. null distribution. RI p = ",
                           round(ri$cross_section$pvalue, 3)))
  ggsave(file.path(fig_dir, "fig10_ri.pdf"), p10, width = 7, height = 5)
  ggsave(file.path(fig_dir, "fig10_ri.png"), p10, width = 7, height = 5, dpi = 300)
} else {
  cat("  (RI results not yet available — will generate later)\n")
}

## =========================================================================
## FIGURE 11: Subgroup Forest Plot
## =========================================================================

cat("Fig 11: Subgroup forest plot\n")
sub_file <- file.path(data_dir, "subgroup_results.rds")
if (file.exists(sub_file)) {
  sub <- readRDS(sub_file)
  sub <- sub[!is.na(coef)]
  sub[, ci_lo := coef - 1.96 * se]
  sub[, ci_hi := coef + 1.96 * se]
  sub[, subgroup := factor(subgroup, levels = rev(subgroup))]

  p11 <- ggplot(sub[1:min(15, nrow(sub))],
                aes(x = coef, y = subgroup)) +
    geom_point(size = 2.5, color = apep_blue) +
    geom_errorbarh(aes(xmin = ci_lo, xmax = ci_hi), height = 0.2, color = apep_blue) +
    geom_vline(xintercept = 0, linetype = "dashed") +
    labs(x = "RD Estimate (95% CI)",
         y = "",
         subtitle = "Cross-sectional RDD by pre-treatment characteristics")
  ggsave(file.path(fig_dir, "fig11_subgroups.pdf"), p11, width = 8, height = 7)
  ggsave(file.path(fig_dir, "fig11_subgroups.png"), p11, width = 8, height = 7, dpi = 300)
}

## =========================================================================
## FIGURE 12: Dose-Response
## =========================================================================

cat("Fig 12: Dose-response\n")
dose_file <- file.path(data_dir, "dose_results.rds")
if (file.exists(dose_file)) {
  dose <- readRDS(dose_file)
  multi <- dose$multi_cutoff
  if (!is.null(multi) && nrow(multi) > 0) {
    multi[, ci_lo := coef - 1.96 * se]
    multi[, ci_hi := coef + 1.96 * se]
    p12 <- ggplot(multi, aes(x = pension_amt, y = coef)) +
      geom_point(size = 4, color = apep_blue) +
      geom_errorbar(aes(ymin = ci_lo, ymax = ci_hi), width = 0.5) +
      geom_hline(yintercept = 0, linetype = "dashed") +
      labs(x = "Monthly Pension Amount ($)",
           y = "RD Estimate on LFP",
           subtitle = "RDD estimates at ages 62 ($12), 70 ($15), 75 ($20)")
    ggsave(file.path(fig_dir, "fig12_dose_response.pdf"), p12, width = 7, height = 5)
    ggsave(file.path(fig_dir, "fig12_dose_response.png"), p12, width = 7, height = 5, dpi = 300)
  }
}

## =========================================================================
## FIGURE 13: Occupation Transitions
## =========================================================================

cat("Fig 13: Occupation transitions\n")
occ_file <- file.path(data_dir, "occupation_results.rds")
if (file.exists(occ_file)) {
  occ <- readRDS(occ_file)
  exit_dt <- occ$exit_by_occ
  exit_dt[, occ_type_1900 := factor(occ_type_1900, levels = occ_type_1900[order(exit_rate)])]

  p13 <- ggplot(exit_dt, aes(x = occ_type_1900, y = exit_rate)) +
    geom_bar(stat = "identity", fill = apep_blue, alpha = 0.8) +
    coord_flip() +
    scale_y_continuous(labels = percent_format()) +
    labs(x = "", y = "Labor Force Exit Rate (1900 to 1910)",
         subtitle = "Fraction leaving labor force by 1900 occupation type")
  ggsave(file.path(fig_dir, "fig13_occ_exit.pdf"), p13, width = 7, height = 4.5)
  ggsave(file.path(fig_dir, "fig13_occ_exit.png"), p13, width = 7, height = 4.5, dpi = 300)
}

## =========================================================================
## FIGURE 14: Pension Schedule
## =========================================================================

cat("Fig 14: Pension schedule\n")
sched <- data.table(
  age_range = c("Under 62", "62-69", "70-74", "75+"),
  amount = c(0, 12, 15, 20),
  x_pos = c(58, 62, 70, 75)
)
p14 <- ggplot(sched, aes(x = x_pos, y = amount)) +
  geom_step(direction = "hv", color = apep_dark, linewidth = 1.2) +
  geom_point(size = 3, color = apep_red) +
  annotate("text", x = 66, y = 13, label = "$12/mo", vjust = -0.5) +
  annotate("text", x = 72.5, y = 16, label = "$15/mo", vjust = -0.5) +
  annotate("text", x = 77.5, y = 21, label = "$20/mo", vjust = -0.5) +
  labs(x = "Veteran Age",
       y = "Monthly Pension ($)",
       subtitle = "Pension amounts by age bracket under the 1907 Act") +
  scale_x_continuous(breaks = c(55, 60, 62, 65, 70, 75, 80)) +
  coord_cartesian(ylim = c(0, 25))

ggsave(file.path(fig_dir, "fig14_pension_schedule.pdf"), p14, width = 7, height = 4.5)
ggsave(file.path(fig_dir, "fig14_pension_schedule.png"), p14, width = 7, height = 4.5, dpi = 300)

## ---- Check all figures ----
figs <- list.files(fig_dir, pattern = "\\.pdf$")
cat("\n=== FIGURES GENERATED:", length(figs), "===\n")
for (f in sort(figs)) cat("  ", f, "\n")
