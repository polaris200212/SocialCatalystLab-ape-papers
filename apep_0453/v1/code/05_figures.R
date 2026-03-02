# ============================================================
# 05_figures.R — All figure generation
# apep_0453: Demonetization and Banking Infrastructure
# ============================================================

source("00_packages.R")
load("../data/analysis_panel.RData")
load("../data/main_results.RData")
load("../data/robustness_results.RData")

fig_dir <- "../figures"

# ============================================================
# FIGURE 1: Banking Infrastructure Distribution
# ============================================================

cat("Figure 1: Banking density distribution\n")

p1 <- ggplot(baseline[!is.na(bank_per_100k)], aes(x = bank_per_100k)) +
  geom_histogram(bins = 50, fill = apep_colors[1], alpha = 0.7, color = "white") +
  geom_vline(xintercept = median(baseline$bank_per_100k, na.rm = TRUE),
             linetype = "dashed", color = apep_colors[2], linewidth = 0.8) +
  annotate("text", x = median(baseline$bank_per_100k, na.rm = TRUE) + 1,
           y = Inf, vjust = 2, hjust = 0,
           label = paste0("Median = ", round(median(baseline$bank_per_100k, na.rm = TRUE), 1)),
           color = apep_colors[2], size = 3.5) +
  labs(
    title = "Distribution of Banking Infrastructure Across Indian Districts",
    subtitle = "Bank branches per 100,000 population (Census 2011)",
    x = "Bank branches per 100,000 population",
    y = "Number of districts"
  ) +
  theme_apep() +
  coord_cartesian(xlim = c(0, 25))

ggsave(file.path(fig_dir, "fig1_banking_distribution.pdf"),
       p1, width = 8, height = 5)

# ============================================================
# FIGURE 2: Event Study (Main specification)
# ============================================================

cat("Figure 2: Event study\n")

p2 <- ggplot(es_coefs, aes(x = year, y = coef)) +
  geom_ribbon(aes(ymin = ci_lo, ymax = ci_hi),
              alpha = 0.15, fill = apep_colors[1]) +
  geom_point(color = apep_colors[1], size = 2.5) +
  geom_line(color = apep_colors[1], linewidth = 0.7) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
  geom_vline(xintercept = 2015.5, linetype = "dotted", color = "grey60") +
  annotate("text", x = 2015.5, y = Inf, vjust = 2, hjust = 1.1,
           label = "Pre-period", size = 3, color = "grey50") +
  annotate("text", x = 2015.5, y = Inf, vjust = 2, hjust = -0.1,
           label = "Post-demonetization", size = 3, color = "grey50") +
  labs(
    title = "Event Study: Banking Infrastructure and Nightlight Growth",
    subtitle = expression("Coefficients on Bank branches per 100K" %*% "Year dummies (ref: 2015)"),
    x = "Year",
    y = "Coefficient on banking intensity"
  ) +
  scale_x_continuous(breaks = 2012:2023) +
  theme_apep() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

ggsave(file.path(fig_dir, "fig2_event_study.pdf"),
       p2, width = 8, height = 5.5)

# ============================================================
# FIGURE 3: Event Study with Controls
# ============================================================

cat("Figure 3: Event study with controls\n")

p3 <- ggplot(es_ctrl_coefs, aes(x = year, y = coef)) +
  geom_ribbon(aes(ymin = ci_lo, ymax = ci_hi),
              alpha = 0.15, fill = apep_colors[1]) +
  geom_point(color = apep_colors[1], size = 2.5) +
  geom_line(color = apep_colors[1], linewidth = 0.7) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
  geom_vline(xintercept = 2015.5, linetype = "dotted", color = "grey60") +
  labs(
    title = "Event Study with Baseline Controls",
    subtitle = "Controls: log population, literacy, ag share, SC share (all interacted with year)",
    x = "Year",
    y = "Coefficient on banking intensity"
  ) +
  scale_x_continuous(breaks = 2012:2023) +
  theme_apep() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

ggsave(file.path(fig_dir, "fig3_event_study_controls.pdf"),
       p3, width = 8, height = 5.5)

# ============================================================
# FIGURE 4: Nightlight Trends by Banking Quartile
# ============================================================

cat("Figure 4: NL trends by banking quartile\n")

panel[, bank_q := baseline$bank_quartile[match(dist_id,
  paste0(baseline$pc11_state_id, "_", baseline$pc11_district_id))]]

trends <- panel[!is.na(bank_q), .(
  mean_nl = mean(log_nl, na.rm = TRUE),
  se_nl   = sd(log_nl, na.rm = TRUE) / sqrt(.N)
), by = .(year, bank_q)]

p4 <- ggplot(trends, aes(x = year, y = mean_nl, color = bank_q, group = bank_q)) +
  geom_line(linewidth = 0.8) +
  geom_point(size = 2) +
  geom_vline(xintercept = 2016, linetype = "dashed", color = "grey50") +
  annotate("text", x = 2016, y = Inf, vjust = 2, hjust = 1.1,
           label = "Demonetization\n(Nov 2016)", size = 3, color = "grey50") +
  scale_color_manual(values = apep_colors[1:4]) +
  labs(
    title = "Average Log Nightlights by Banking Infrastructure Quartile",
    subtitle = "District-level annual VIIRS nightlights (2012\u20132023)",
    x = "Year",
    y = "Mean log(nightlights + 0.01)",
    color = "Banking quartile"
  ) +
  scale_x_continuous(breaks = 2012:2023) +
  theme_apep() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

ggsave(file.path(fig_dir, "fig4_nl_trends_quartile.pdf"),
       p4, width = 9, height = 5.5)

# ============================================================
# FIGURE 5: Randomization Inference
# ============================================================

cat("Figure 5: Randomization inference\n")

ri_df <- data.frame(coef = ri_coefs)

p5 <- ggplot(ri_df, aes(x = coef)) +
  geom_histogram(bins = 30, fill = "grey70", color = "white", alpha = 0.8) +
  geom_vline(xintercept = actual_coef, color = apep_colors[2],
             linewidth = 1, linetype = "solid") +
  annotate("text", x = actual_coef, y = Inf, vjust = 2,
           hjust = ifelse(actual_coef > 0, -0.2, 1.2),
           label = paste0("Actual = ", round(actual_coef, 5),
                          "\np = ", round(ri_pvalue, 3)),
           color = apep_colors[2], size = 3.5, fontface = "bold") +
  labs(
    title = "Randomization Inference: Distribution of Placebo Coefficients",
    subtitle = "100 permutations of banking intensity across districts",
    x = "Coefficient on Bank per 100K \u00d7 Post",
    y = "Count"
  ) +
  theme_apep()

ggsave(file.path(fig_dir, "fig5_randomization_inference.pdf"),
       p5, width = 8, height = 5)

# ============================================================
# FIGURE 6: Heterogeneity by Agricultural Share
# ============================================================

cat("Figure 6: Heterogeneity by ag share\n")

panel[, high_ag := as.integer(ag_share >= median(baseline$ag_share, na.rm = TRUE))]

het_trends <- panel[!is.na(high_ag), .(
  mean_nl = mean(log_nl, na.rm = TRUE)
), by = .(year, high_ag, high_bank = as.integer(bank_per_100k >= median(baseline$bank_per_100k, na.rm = TRUE)))]

het_trends[, group := paste0(
  ifelse(high_ag == 1, "High Ag", "Low Ag"), " / ",
  ifelse(high_bank == 1, "High Bank", "Low Bank")
)]

p6 <- ggplot(het_trends, aes(x = year, y = mean_nl, color = group, group = group)) +
  geom_line(linewidth = 0.8) +
  geom_point(size = 2) +
  geom_vline(xintercept = 2016, linetype = "dashed", color = "grey50") +
  scale_color_manual(values = apep_colors[1:4]) +
  labs(
    title = "Nightlight Trends by Agriculture and Banking Status",
    subtitle = "District-level VIIRS nightlights (2012\u20132023)",
    x = "Year",
    y = "Mean log(nightlights + 0.01)",
    color = "District type"
  ) +
  scale_x_continuous(breaks = 2012:2023) +
  theme_apep() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

ggsave(file.path(fig_dir, "fig6_het_ag_bank.pdf"),
       p6, width = 9, height = 5.5)

cat("\n=== All figures saved to", fig_dir, "===\n")
