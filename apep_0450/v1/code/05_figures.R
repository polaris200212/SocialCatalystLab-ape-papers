# ============================================================================
# 05_figures.R — Publication-ready figures
# GST and Interstate Price Convergence
# ============================================================================

source("00_packages.R")

cpi <- fread("../data/cpi_panel.csv")
cpi[, date := as.Date(date)]
dispersion <- fread("../data/cpi_dispersion.csv")
dispersion[, date := as.Date(date)]

# ── Figure 1: Cross-State CPI Dispersion Over Time ───────────────────────
cat("Generating Figure 1: Cross-state CPI dispersion...\n")

disp_gen <- dispersion[group == "General"]

fig1 <- ggplot(disp_gen, aes(x = date, y = cv)) +
  geom_vline(xintercept = as.Date("2017-07-01"), linetype = "dashed",
             color = "red", linewidth = 0.6) +
  geom_vline(xintercept = as.Date("2016-11-08"), linetype = "dotted",
             color = "grey50", linewidth = 0.4) +
  geom_line(color = apep_colors[1], linewidth = 0.7) +
  geom_smooth(method = "loess", span = 0.15, se = FALSE,
              color = apep_colors[2], linewidth = 0.5, linetype = "solid") +
  annotate("text", x = as.Date("2017-09-01"), y = max(disp_gen$cv, na.rm = TRUE) * 0.95,
           label = "GST\n(Jul 2017)", color = "red", size = 3, hjust = 0) +
  annotate("text", x = as.Date("2016-07-01"), y = max(disp_gen$cv, na.rm = TRUE) * 0.85,
           label = "Demonetization\n(Nov 2016)", color = "grey40", size = 2.5, hjust = 1) +
  labs(
    title = "Cross-State Consumer Price Dispersion",
    subtitle = "Coefficient of variation of state-level General CPI (Combined)",
    x = NULL, y = "Coefficient of Variation (%)",
    caption = "Source: MoSPI eSankhyiki CPI (base 2012=100). Red dashed = GST implementation."
  ) +
  theme_apep()

ggsave("../figures/fig1_dispersion.pdf", fig1, width = 8, height = 5)

# ── Figure 2: Dispersion by Commodity Group ───────────────────────────────
cat("Generating Figure 2: Dispersion by commodity group...\n")

disp_comm <- dispersion[!group %in% c("General", "Consumer Food Price")]
disp_comm[, group_label := factor(group_short,
  levels = c("Food", "Clothing", "Fuel", "Housing", "Misc", "Tobacco"))]

fig2 <- ggplot(disp_comm[!is.na(group_label)], aes(x = date, y = cv, color = group_label)) +
  geom_vline(xintercept = as.Date("2017-07-01"), linetype = "dashed",
             color = "red", linewidth = 0.4) +
  geom_line(linewidth = 0.5, alpha = 0.7) +
  geom_smooth(method = "loess", span = 0.2, se = FALSE, linewidth = 0.4) +
  scale_color_manual(values = apep_colors, name = "Commodity Group") +
  labs(
    title = "Cross-State Price Dispersion by Commodity Group",
    subtitle = "CV of state-level CPI indices. Red dashed = GST (Jul 2017)",
    x = NULL, y = "Coefficient of Variation (%)"
  ) +
  theme_apep() +
  guides(color = guide_legend(nrow = 1))

ggsave("../figures/fig2_dispersion_bygroup.pdf", fig2, width = 9, height = 5.5)

# ── Figure 3: Event Study Plot ────────────────────────────────────────────
cat("Generating Figure 3: Event study...\n")

es_coef <- fread("../data/event_study_general.csv")

fig3 <- ggplot(es_coef, aes(x = rel_month, y = estimate)) +
  geom_hline(yintercept = 0, color = "grey50", linewidth = 0.3) +
  geom_vline(xintercept = -0.5, linetype = "dashed", color = "red", linewidth = 0.4) +
  geom_ribbon(aes(ymin = ci_lo, ymax = ci_hi), fill = apep_colors[1], alpha = 0.15) +
  geom_line(color = apep_colors[1], linewidth = 0.6) +
  geom_point(color = apep_colors[1], size = 0.8) +
  annotate("text", x = 5, y = max(es_coef$ci_hi, na.rm = TRUE) * 0.9,
           label = "GST", color = "red", size = 3, fontface = "bold") +
  labs(
    title = "Event Study: GST and State-Level CPI",
    subtitle = "Interaction of relative month × tax intensity (ref = month -1)",
    x = "Months Relative to GST (July 2017 = 0)",
    y = TeX("$\\beta_k$ (log CPI × Tax Intensity)")
  ) +
  scale_x_continuous(breaks = seq(-24, 36, 6)) +
  coord_cartesian(xlim = c(-24, 36)) +
  theme_apep()

ggsave("../figures/fig3_event_study.pdf", fig3, width = 8, height = 5)

# ── Figure 4: Group-Level Coefficients ────────────────────────────────────
cat("Generating Figure 4: Group-level coefficients...\n")

group_dt <- fread("../data/group_level_results.csv")
group_dt[, group_short := c("Food", "Tobacco", "Clothing", "Housing", "Fuel", "Misc")[
  match(group, c("Food and Beverages", "Pan, Tobacco and Intoxicants",
                  "Clothing and Footwear", "Housing", "Fuel and Light", "Miscellaneous"))]]
group_dt <- group_dt[!is.na(group_short)]
group_dt[, ci_lo := estimate - 1.96 * se]
group_dt[, ci_hi := estimate + 1.96 * se]
group_dt[, sig := ifelse(p_val < 0.05, "Significant", "Not significant")]

fig4 <- ggplot(group_dt, aes(x = reorder(group_short, estimate),
                              y = estimate, color = sig)) +
  geom_hline(yintercept = 0, color = "grey50", linewidth = 0.3) +
  geom_pointrange(aes(ymin = ci_lo, ymax = ci_hi), linewidth = 0.5, size = 0.8) +
  scale_color_manual(values = c("Significant" = apep_colors[1],
                                 "Not significant" = "grey60"), name = NULL) +
  coord_flip() +
  labs(
    title = "GST Price Convergence by Commodity Group",
    subtitle = "Coefficient: Post-GST × Tax Intensity on log CPI",
    x = NULL,
    y = TeX("$\\hat{\\beta}$ (Post-GST $\\times$ Tax Intensity)")
  ) +
  theme_apep() +
  theme(legend.position = c(0.8, 0.2))

ggsave("../figures/fig4_group_coefficients.pdf", fig4, width = 7, height = 5)

# ── Figure 5: High vs Low Tax States CPI Trends ──────────────────────────
cat("Generating Figure 5: High vs low tax state trends...\n")

gen <- cpi[group == "General" & !is.na(index)]
trends <- gen[, .(mean_index = mean(index, na.rm = TRUE)), by = .(date, high_tax)]
trends[, tax_group := ifelse(high_tax == 1, "High Pre-GST Tax", "Low Pre-GST Tax")]

fig5 <- ggplot(trends, aes(x = date, y = mean_index, color = tax_group)) +
  geom_vline(xintercept = as.Date("2017-07-01"), linetype = "dashed",
             color = "red", linewidth = 0.4) +
  geom_line(linewidth = 0.7) +
  scale_color_manual(values = apep_colors[1:2], name = NULL) +
  labs(
    title = "Average CPI: High vs. Low Pre-GST Tax States",
    subtitle = "States split at median pre-GST indirect tax revenue / GSDP",
    x = NULL, y = "CPI Index (2012 = 100)"
  ) +
  theme_apep()

ggsave("../figures/fig5_high_low_trends.pdf", fig5, width = 8, height = 5)

# ── Figure 6: Randomization Inference Distribution ────────────────────────
cat("Generating Figure 6: RI distribution...\n")

ri_data <- fread("../data/ri_results.csv")
actual <- ri_data$actual[1]

fig6 <- ggplot(ri_data, aes(x = perm_coefs)) +
  geom_histogram(bins = 50, fill = "grey80", color = "grey60", linewidth = 0.2) +
  geom_vline(xintercept = actual, color = "red", linewidth = 0.8, linetype = "solid") +
  geom_vline(xintercept = -actual, color = "red", linewidth = 0.5, linetype = "dashed") +
  annotate("text", x = actual, y = Inf, label = paste("Actual =", round(actual, 3)),
           color = "red", hjust = -0.1, vjust = 2, size = 3) +
  labs(
    title = "Randomization Inference: Permutation Distribution",
    subtitle = paste("500 permutations of state tax intensity. RI p-value =",
                     round(ri_data$ri_p[1], 3)),
    x = "Permuted Coefficient",
    y = "Count"
  ) +
  theme_apep()

ggsave("../figures/fig6_ri_distribution.pdf", fig6, width = 7, height = 4.5)

cat("\nAll figures saved to figures/ directory.\n")
