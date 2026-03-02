###############################################################################
# 05_figures.R — Generate all figures
# Paper: The Geography of Monetary Transmission
###############################################################################

source("00_packages.R")

lp_baseline <- readRDS("../data/lp_baseline.rds")
tercile_irf <- readRDS("../data/tercile_irf.rds")
panel <- readRDS("../data/panel_monthly.rds")
perm_results <- readRDS("../data/permutation_results.rds")
htm_xs <- panel %>%
  distinct(state_abbr, htm_poverty_xs) %>%
  filter(!is.na(htm_poverty_xs))

# ===========================================================================
# Figure 1: Cross-State Variation in HtM Share
# ===========================================================================
cat("Figure 1: HtM variation across states...\n")

fig1 <- ggplot(htm_xs, aes(x = reorder(state_abbr, htm_poverty_xs), y = htm_poverty_xs * 100)) +
  geom_col(aes(fill = htm_poverty_xs), width = 0.7, show.legend = FALSE) +
  scale_fill_viridis_c(option = "plasma", direction = -1) +
  geom_hline(yintercept = mean(htm_xs$htm_poverty_xs) * 100,
             linetype = "dashed", color = "grey40", linewidth = 0.5) +
  annotate("text", x = 5, y = mean(htm_xs$htm_poverty_xs) * 100 + 0.8,
           label = "National mean", size = 3, color = "grey40") +
  labs(
    title = "Cross-State Variation in Hand-to-Mouth Household Share",
    subtitle = "Average poverty rate, 1995\u20132005 (pre-sample period)",
    x = NULL,
    y = "Poverty Rate (%)"
  ) +
  coord_flip() +
  theme_apep() +
  theme(axis.text.y = element_text(size = 7))

ggsave("../figures/fig1_htm_variation.pdf", fig1, width = 7, height = 9)

# ===========================================================================
# Figure 2: Baseline Local Projection IRF (MP × HtM)
# ===========================================================================
cat("Figure 2: Baseline LP IRF...\n")

fig2 <- ggplot(lp_baseline, aes(x = horizon, y = coef)) +
  geom_ribbon(aes(ymin = ci_lo, ymax = ci_hi), fill = apep_colors[1], alpha = 0.15) +
  geom_ribbon(aes(ymin = ci90_lo, ymax = ci90_hi), fill = apep_colors[1], alpha = 0.25) +
  geom_line(color = apep_colors[1], linewidth = 1) +
  geom_point(color = apep_colors[1], size = 2.5) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
  scale_x_continuous(breaks = c(0, 6, 12, 18, 24, 36, 48)) +
  labs(
    title = "Differential Employment Response to Monetary Policy by HtM Share",
    subtitle = expression(paste("Coefficient on MP"[t], " \u00D7 HtM"[s], " (standardized), Driscoll-Kraay SEs")),
    x = "Horizon (months)",
    y = expression(hat(gamma)^h)
  ) +
  theme_apep()

ggsave("../figures/fig2_lp_baseline.pdf", fig2, width = 8, height = 5)

# ===========================================================================
# Figure 3: Tercile IRFs (High vs Medium vs Low HtM)
# ===========================================================================
cat("Figure 3: Tercile IRFs...\n")

tercile_colors <- c("Low HtM" = apep_colors[1], "Medium HtM" = apep_colors[3],
                     "High HtM" = apep_colors[2])

fig3 <- ggplot(tercile_irf, aes(x = horizon, y = coef, color = tercile, fill = tercile)) +
  geom_ribbon(aes(ymin = ci_lo, ymax = ci_hi), alpha = 0.1, color = NA) +
  geom_line(linewidth = 0.9) +
  geom_point(size = 2) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
  scale_color_manual(values = tercile_colors) +
  scale_fill_manual(values = tercile_colors) +
  scale_x_continuous(breaks = c(0, 6, 12, 18, 24, 36, 48)) +
  labs(
    title = "Monetary Policy Impulse Responses by HtM Tercile",
    subtitle = "100 \u00D7 \u0394log(Employment) response to 1 SD BRW shock",
    x = "Horizon (months)",
    y = "Cumulative Employment Response (%)",
    color = "HtM Group",
    fill = "HtM Group"
  ) +
  theme_apep()

ggsave("../figures/fig3_tercile_irf.pdf", fig3, width = 8, height = 5)

# ===========================================================================
# Figure 4: Permutation Inference
# ===========================================================================
cat("Figure 4: Permutation inference...\n")

perm_df <- tibble(gamma_perm = perm_results$permuted) %>% filter(!is.na(gamma_perm))

fig4 <- ggplot(perm_df, aes(x = gamma_perm)) +
  geom_histogram(bins = 40, fill = "grey70", color = "white", linewidth = 0.3) +
  geom_vline(xintercept = perm_results$actual, color = apep_colors[2],
             linewidth = 1.2, linetype = "solid") +
  annotate("text",
           x = perm_results$actual, y = Inf,
           label = sprintf("Actual \u03B3 = %.4f\np = %.3f",
                           perm_results$actual, perm_results$pvalue),
           hjust = -0.1, vjust = 2, size = 3.5, color = apep_colors[2]) +
  labs(
    title = "Permutation Inference: Randomization of HtM Rankings",
    subtitle = sprintf("%d permutations, h = 24 months", nrow(perm_df)),
    x = expression(hat(gamma)^{perm}),
    y = "Count"
  ) +
  theme_apep()

ggsave("../figures/fig4_permutation.pdf", fig4, width = 7, height = 5)

# ===========================================================================
# Figure 5: BRW Monetary Shock Time Series
# ===========================================================================
cat("Figure 5: BRW shock time series...\n")

brw <- readRDS("../data/brw_shocks.rds")

fig5 <- ggplot(brw, aes(x = date, y = brw_monthly)) +
  geom_col(aes(fill = brw_monthly > 0), width = 25, show.legend = FALSE) +
  scale_fill_manual(values = c("TRUE" = apep_colors[2], "FALSE" = apep_colors[1])) +
  geom_hline(yintercept = 0, linewidth = 0.3) +
  # Shade recessions
  annotate("rect", xmin = as.Date("2001-03-01"), xmax = as.Date("2001-11-01"),
           ymin = -Inf, ymax = Inf, fill = "grey80", alpha = 0.3) +
  annotate("rect", xmin = as.Date("2007-12-01"), xmax = as.Date("2009-06-01"),
           ymin = -Inf, ymax = Inf, fill = "grey80", alpha = 0.3) +
  annotate("rect", xmin = as.Date("2020-02-01"), xmax = as.Date("2020-04-01"),
           ymin = -Inf, ymax = Inf, fill = "grey80", alpha = 0.3) +
  labs(
    title = "Bu-Rogers-Wu Monetary Policy Shocks",
    subtitle = "Monthly, 1994\u20132020. Blue = easing, orange = tightening. Grey = NBER recessions.",
    x = NULL,
    y = "BRW Shock (pp)"
  ) +
  theme_apep()

ggsave("../figures/fig5_brw_shocks.pdf", fig5, width = 9, height = 4)

# ===========================================================================
# Figure 6: Scatter — HtM Share vs Employment Sensitivity
# ===========================================================================
cat("Figure 6: HtM vs sensitivity scatter...\n")

# For each state, estimate sensitivity to monetary shocks
state_sensitivity <- panel %>%
  filter(!is.na(brw_monthly), !is.na(log_emp)) %>%
  group_by(state_abbr) %>%
  arrange(date) %>%
  mutate(d_emp_12 = 100 * (lead(log_emp, 12) - lag(log_emp, 1))) %>%
  ungroup() %>%
  filter(!is.na(d_emp_12)) %>%
  group_by(state_abbr) %>%
  summarise(
    beta = tryCatch(
      coef(lm(d_emp_12 ~ brw_monthly))["brw_monthly"],
      error = function(e) NA_real_
    ),
    .groups = "drop"
  ) %>%
  left_join(htm_xs, by = "state_abbr") %>%
  filter(!is.na(beta), !is.na(htm_poverty_xs))

fig6 <- ggplot(state_sensitivity, aes(x = htm_poverty_xs * 100, y = beta)) +
  geom_point(size = 2.5, color = apep_colors[1], alpha = 0.7) +
  geom_smooth(method = "lm", color = apep_colors[2], fill = apep_colors[2],
              alpha = 0.15, linewidth = 1) +
  geom_text(aes(label = state_abbr), size = 2, nudge_y = 0.1, color = "grey40") +
  labs(
    title = "Monetary Policy Sensitivity vs. Hand-to-Mouth Share",
    subtitle = "State-level employment response to BRW shock (h = 12 months)",
    x = "Poverty Rate (%, 1995\u20132005 avg)",
    y = expression(hat(beta)[s] ~ "(Employment sensitivity to MP)")
  ) +
  theme_apep()

ggsave("../figures/fig6_htm_sensitivity_scatter.pdf", fig6, width = 7, height = 6)

cat("\n=== ALL FIGURES GENERATED ===\n")
cat(sprintf("Saved to: %s\n", normalizePath("../figures")))
