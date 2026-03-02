## ============================================================
## 05_figures.R — Publication-quality figures
## Breaking Purdah with Pavement (apep_0432)
## ============================================================
source(here::here("output", "apep_0432", "v1", "code", "00_packages.R"))
load(file.path(data_dir, "analysis_panel.RData"))
load(file.path(data_dir, "main_results.RData"))
load(file.path(data_dir, "robustness_results.RData"))

## Color palette for caste categories
caste_colors <- c("General/OBC-dominated" = "#2C3E50",
                   "SC-dominated" = "#E74C3C",
                   "ST-dominated" = "#27AE60")
caste_cats <- c("General/OBC-dominated", "SC-dominated", "ST-dominated")

## ================================================================
## FIGURE 1: McCrary Density Plot
## ================================================================

cat("=== Figure 1: McCrary Density ===\n")

## Manual density plot using histogram bins
bins <- seq(0, 2000, by = 10)
dens_dt <- panel_rdd[, .(count = .N), by = .(bin = findInterval(pop01, bins))]
dens_dt[, midpoint := bins[bin] + 5]
dens_dt <- dens_dt[!is.na(midpoint) & midpoint >= 200 & midpoint <= 800]

fig1 <- ggplot(dens_dt, aes(x = midpoint, y = count)) +
  geom_col(aes(fill = midpoint >= 500), width = 9, alpha = 0.7) +
  geom_vline(xintercept = 500, linetype = "dashed", color = "red", linewidth = 0.8) +
  scale_fill_manual(values = c("TRUE" = "#3498DB", "FALSE" = "#95A5A6"),
                    labels = c("Below threshold", "Above threshold"),
                    name = "PMGSY eligibility") +
  labs(x = "Census 2001 village population",
       y = "Number of villages (per 10-person bin)",
       title = "Distribution of village population at PMGSY threshold",
       subtitle = "McCrary test: T = 0.068, p = 0.945 — no evidence of manipulation") +
  annotate("text", x = 510, y = max(dens_dt$count) * 0.9,
           label = "Threshold = 500", hjust = 0, fontface = "italic", size = 3.5) +
  theme(legend.position = c(0.85, 0.85))

ggsave(file.path(fig_dir, "fig1_mccrary.pdf"), fig1, width = 8, height = 5)
ggsave(file.path(fig_dir, "fig1_mccrary.png"), fig1, width = 8, height = 5, dpi = 300)

## ================================================================
## FIGURE 2: RDD Plot — Female WPR by Caste Category
## ================================================================

cat("=== Figure 2: RDD by Caste ===\n")

## Create binned scatter for RDD visualization
make_rdd_bins <- function(dt, yvar, nbins = 40, xrange = c(200, 800)) {
  dt_sub <- dt[pop01 >= xrange[1] & pop01 <= xrange[2] & !is.na(get(yvar))]
  dt_sub[, bin := cut(pop01, breaks = nbins, labels = FALSE)]
  dt_sub[, .(y_mean = mean(get(yvar), na.rm = TRUE),
             x_mean = mean(pop01, na.rm = TRUE),
             n = .N), by = bin]
}

## Panel A: Pooled
bins_pooled <- make_rdd_bins(panel_rdd, "d_fwpr")

fig2a <- ggplot(bins_pooled, aes(x = x_mean, y = y_mean)) +
  geom_point(alpha = 0.6, size = 2) +
  geom_vline(xintercept = 500, linetype = "dashed", color = "red") +
  geom_smooth(data = bins_pooled[x_mean < 500], method = "lm", se = TRUE,
              color = "#3498DB", fill = "#3498DB", alpha = 0.2) +
  geom_smooth(data = bins_pooled[x_mean >= 500], method = "lm", se = TRUE,
              color = "#3498DB", fill = "#3498DB", alpha = 0.2) +
  labs(x = "Census 2001 population", y = "Change in female WPR (2001-2011)",
       title = "A. Pooled sample") +
  coord_cartesian(ylim = c(-0.08, 0.02))

## By caste category
rdd_caste_figs <- list()
panel_labels <- c("B. General/OBC villages", "C. SC-dominated villages",
                   "D. ST-dominated villages")

for (j in seq_along(caste_cats)) {
  cc <- caste_cats[j]
  sub <- panel_rdd[caste_dominant == cc]
  bins_cc <- make_rdd_bins(sub, "d_fwpr")

  rdd_caste_figs[[j]] <- ggplot(bins_cc, aes(x = x_mean, y = y_mean)) +
    geom_point(alpha = 0.6, size = 2, color = caste_colors[cc]) +
    geom_vline(xintercept = 500, linetype = "dashed", color = "red") +
    geom_smooth(data = bins_cc[x_mean < 500], method = "lm", se = TRUE,
                color = caste_colors[cc], fill = caste_colors[cc], alpha = 0.2) +
    geom_smooth(data = bins_cc[x_mean >= 500], method = "lm", se = TRUE,
                color = caste_colors[cc], fill = caste_colors[cc], alpha = 0.2) +
    labs(x = "Census 2001 population", y = "Change in female WPR",
         title = panel_labels[j]) +
    coord_cartesian(ylim = c(-0.08, 0.02))
}

library(patchwork)
fig2 <- (fig2a | rdd_caste_figs[[1]]) / (rdd_caste_figs[[2]] | rdd_caste_figs[[3]]) +
  plot_annotation(
    title = "RDD estimates: Effect of PMGSY eligibility on female work participation",
    subtitle = "Binned scatter with local linear fit. Red dashed line = 500-person threshold.",
    theme = theme(plot.title = element_text(face = "bold", size = 13),
                  plot.subtitle = element_text(color = "grey40", size = 10))
  )

ggsave(file.path(fig_dir, "fig2_rdd_caste.pdf"), fig2, width = 10, height = 8)
ggsave(file.path(fig_dir, "fig2_rdd_caste.png"), fig2, width = 10, height = 8, dpi = 300)

## ================================================================
## FIGURE 3: Coefficient Plot — Heterogeneous Effects
## ================================================================

cat("=== Figure 3: Coefficient Plot ===\n")

## Extract key coefficients from hetero_all
coef_dt <- hetero_all[Outcome %in% c("Chg Female WPR", "Chg F Ag Labor",
                                       "Chg F Other Work", "Chg F Non-Worker",
                                       "Chg F Literacy")]
coef_dt <- coef_dt[!is.na(Coeff)]
coef_dt[, CI_lo := Coeff - 1.96 * SE]
coef_dt[, CI_hi := Coeff + 1.96 * SE]
coef_dt[, Outcome := factor(Outcome, levels = rev(c("Chg Female WPR", "Chg F Ag Labor",
                                                      "Chg F Other Work", "Chg F Non-Worker",
                                                      "Chg F Literacy")))]

fig3 <- ggplot(coef_dt, aes(x = Coeff, y = Outcome, color = Caste)) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "grey50") +
  geom_pointrange(aes(xmin = CI_lo, xmax = CI_hi),
                  position = position_dodge(width = 0.6), size = 0.5) +
  scale_color_manual(values = caste_colors) +
  labs(x = "RDD estimate (ITT)", y = "",
       title = "Heterogeneous RDD effects by caste composition",
       subtitle = "Point estimates with 95% confidence intervals") +
  theme(legend.position = "bottom")

ggsave(file.path(fig_dir, "fig3_coef_plot.pdf"), fig3, width = 8, height = 6)
ggsave(file.path(fig_dir, "fig3_coef_plot.png"), fig3, width = 8, height = 6, dpi = 300)

## ================================================================
## FIGURE 4: Bandwidth Sensitivity
## ================================================================

cat("=== Figure 4: Bandwidth Sensitivity ===\n")

bw_fwpr <- bw_sensitivity[Outcome == "Female WPR"]
bw_fwpr[, CI_lo := Coeff - 1.96 * SE]
bw_fwpr[, CI_hi := Coeff + 1.96 * SE]

fig4 <- ggplot(bw_fwpr, aes(x = BW, y = Coeff)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
  geom_pointrange(aes(ymin = CI_lo, ymax = CI_hi), size = 0.5, color = "#2C3E50") +
  labs(x = "Bandwidth (population units)", y = "RDD estimate",
       title = "Bandwidth sensitivity: Female WPR",
       subtitle = "Estimates stable across bandwidths. Vertical bars = 95% CI.") +
  theme_apep

ggsave(file.path(fig_dir, "fig4_bw_sensitivity.pdf"), fig4, width = 7, height = 5)
ggsave(file.path(fig_dir, "fig4_bw_sensitivity.png"), fig4, width = 7, height = 5, dpi = 300)

## ================================================================
## FIGURE 5: Placebo Thresholds
## ================================================================

cat("=== Figure 5: Placebo Thresholds ===\n")

## Show coefficients at different cutoffs for FWPR
placebo_fwpr <- placebo_all[Outcome == "Female WPR"]
## Add the real estimate at 500
real_est <- rdd_pooled[Outcome == "Chg Female WPR"]
placebo_fwpr <- rbind(
  placebo_fwpr[, .(Cutoff, Coeff, SE, Pval)],
  data.table(Cutoff = 500, Coeff = real_est$Coeff, SE = real_est$SE, Pval = real_est$Pval)
)
placebo_fwpr[, CI_lo := Coeff - 1.96 * SE]
placebo_fwpr[, CI_hi := Coeff + 1.96 * SE]
placebo_fwpr[, real := Cutoff == 500]

fig5 <- ggplot(placebo_fwpr, aes(x = Cutoff, y = Coeff, color = real)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
  geom_pointrange(aes(ymin = CI_lo, ymax = CI_hi), size = 0.6) +
  scale_color_manual(values = c("TRUE" = "#E74C3C", "FALSE" = "#95A5A6"),
                     guide = "none") +
  labs(x = "Threshold (population cutoff)",
       y = "RDD estimate (Female WPR)",
       title = "Placebo thresholds: No significant effects at non-PMGSY cutoffs",
       subtitle = "Red = actual PMGSY threshold (500). Grey = placebo cutoffs.") +
  theme_apep

ggsave(file.path(fig_dir, "fig5_placebo.pdf"), fig5, width = 7, height = 5)
ggsave(file.path(fig_dir, "fig5_placebo.png"), fig5, width = 7, height = 5, dpi = 300)

## ================================================================
## FIGURE 6: Covariate Balance
## ================================================================

cat("=== Figure 6: Covariate Balance ===\n")

bal <- copy(balance_results)
bal[, CI_lo := Coeff - 1.96 * SE]
bal[, CI_hi := Coeff + 1.96 * SE]
bal[, Variable := factor(Variable, levels = rev(Variable))]
bal <- bal[!is.na(Coeff)]

fig6 <- ggplot(bal, aes(x = Coeff, y = Variable)) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "grey50") +
  geom_pointrange(aes(xmin = CI_lo, xmax = CI_hi), color = "#2C3E50", size = 0.5) +
  labs(x = "RDD estimate at threshold",
       y = "",
       title = "Covariate balance at PMGSY threshold",
       subtitle = "Pre-treatment characteristics show no discontinuity at the 500-person cutoff") +
  theme_apep

ggsave(file.path(fig_dir, "fig6_balance.pdf"), fig6, width = 8, height = 5)
ggsave(file.path(fig_dir, "fig6_balance.png"), fig6, width = 8, height = 5, dpi = 300)

## ================================================================
## FIGURE 7: Descriptive — Female WPR by Caste over Time
## ================================================================

cat("=== Figure 7: Descriptive Trends ===\n")

## Compute means by caste category
desc <- panel_bw[, .(
  FWPR_2001 = mean(fwpr_01, na.rm = TRUE),
  FWPR_2011 = mean(fwpr_11, na.rm = TRUE),
  MWPR_2001 = mean(mwpr_01, na.rm = TRUE),
  MWPR_2011 = mean(mwpr_11, na.rm = TRUE)
), by = caste_dominant]

desc_long <- melt(desc, id.vars = "caste_dominant")
desc_long[, c("Gender", "Year") := tstrsplit(variable, "_")]
desc_long[, Year := as.integer(Year)]
desc_long[, Gender := fifelse(Gender == "FWPR", "Female", "Male")]

fig7 <- ggplot(desc_long, aes(x = Year, y = value, color = caste_dominant,
                                linetype = Gender, group = interaction(caste_dominant, Gender))) +
  geom_line(linewidth = 1.2) +
  geom_point(size = 3) +
  scale_color_manual(values = caste_colors, name = "Caste category") +
  scale_linetype_manual(values = c("Female" = "solid", "Male" = "dashed"), name = "") +
  scale_x_continuous(breaks = c(2001, 2011)) +
  labs(x = "", y = "Work participation rate",
       title = "Work participation rates by caste and gender, 2001-2011",
       subtitle = "Near-threshold villages (pop. 300-700). Female WPR fell everywhere; the gender gap widened.") +
  theme(legend.position = "bottom")

ggsave(file.path(fig_dir, "fig7_descriptive.pdf"), fig7, width = 8, height = 5)
ggsave(file.path(fig_dir, "fig7_descriptive.png"), fig7, width = 8, height = 5, dpi = 300)

cat("\nAll figures saved.\n")
