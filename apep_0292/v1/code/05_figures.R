## 05_figures.R — All figures for the paper
## APEP-0281: Mandatory Energy Disclosure and Property Values (RDD)

source("00_packages.R")

pluto <- readRDS(file.path(data_dir, "pluto_analysis.rds"))
rdd_narrow <- readRDS(file.path(data_dir, "rdd_narrow.rds"))
rdd_broad <- readRDS(file.path(data_dir, "rdd_broad.rds"))
results <- readRDS(file.path(data_dir, "main_results.rds"))
robustness <- readRDS(file.path(data_dir, "robustness_results.rds"))

# ============================================================
# Figure 1: McCrary Density Test
# ============================================================
cat("Creating Figure 1: Density plot...\n")

density_plot_data <- rdd_broad %>%
  filter(gfa >= 10000, gfa <= 45000) %>%
  mutate(gfa_bin = round(gfa / 500) * 500) %>%
  group_by(gfa_bin) %>%
  summarise(n = n(), .groups = "drop")

fig1 <- ggplot(density_plot_data, aes(x = gfa_bin, y = n)) +
  geom_col(aes(fill = gfa_bin >= 25000), width = 450, alpha = 0.8) +
  geom_vline(xintercept = 25000, linetype = "dashed", color = "red", linewidth = 0.7) +
  scale_fill_manual(values = c(apep_colors[2], apep_colors[1]),
                    labels = c("Below Threshold", "Above Threshold"),
                    name = "") +
  scale_x_continuous(labels = scales::comma, breaks = seq(10000, 45000, 5000)) +
  labs(
    title = "Distribution of Building Floor Area Around LL84 Threshold",
    subtitle = "McCrary density test: no evidence of manipulation at 25,000 sq ft",
    x = "Gross Floor Area (sq ft)",
    y = "Number of Buildings",
    caption = "Source: NYC PLUTO. Bin width = 500 sq ft. Dashed line = 25,000 sq ft LL84 threshold."
  ) +
  theme_apep() +
  theme(legend.position = c(0.85, 0.85))

ggsave(file.path(fig_dir, "fig1_density.pdf"), fig1, width = 8, height = 5)
ggsave(file.path(fig_dir, "fig1_density.png"), fig1, width = 8, height = 5, dpi = 300)

# ============================================================
# Figure 2: RDD Plot — Log Assessed Value
# ============================================================
cat("Creating Figure 2: RDD scatter...\n")

# Create binned scatter data
bin_width <- 1000
rdd_bins <- rdd_narrow %>%
  mutate(gfa_bin = round(gfa / bin_width) * bin_width) %>%
  group_by(gfa_bin) %>%
  summarise(
    mean_log_assess = mean(log_assesstot, na.rm = TRUE),
    se_log_assess = sd(log_assesstot, na.rm = TRUE) / sqrt(n()),
    n = n(),
    .groups = "drop"
  ) %>%
  filter(n >= 5) %>%
  mutate(above = gfa_bin >= 25000)

fig2 <- ggplot(rdd_bins, aes(x = gfa_bin, y = mean_log_assess)) +
  geom_point(aes(color = above, size = n), alpha = 0.7) +
  geom_smooth(data = filter(rdd_bins, !above),
              aes(x = gfa_bin, y = mean_log_assess),
              method = "lm", formula = y ~ poly(x, 2),
              color = apep_colors[2], fill = apep_colors[2],
              alpha = 0.15, linewidth = 1) +
  geom_smooth(data = filter(rdd_bins, above),
              aes(x = gfa_bin, y = mean_log_assess),
              method = "lm", formula = y ~ poly(x, 2),
              color = apep_colors[1], fill = apep_colors[1],
              alpha = 0.15, linewidth = 1) +
  geom_vline(xintercept = 25000, linetype = "dashed", color = "red", linewidth = 0.7) +
  scale_color_manual(values = c(apep_colors[2], apep_colors[1]),
                     labels = c("Below Threshold\n(No Disclosure)", "Above Threshold\n(Mandatory Disclosure)"),
                     name = "") +
  scale_size_continuous(guide = "none", range = c(1, 4)) +
  scale_x_continuous(labels = scales::comma) +
  labs(
    title = "Log Assessed Property Value by Building Floor Area",
    subtitle = "Binned scatter with local polynomial fit",
    x = "Gross Floor Area (sq ft)",
    y = "Log Assessed Total Value ($)",
    caption = "Source: NYC PLUTO. Bins = 1,000 sq ft. Lines = local quadratic fit. Dashed line = 25,000 sq ft threshold."
  ) +
  theme_apep() +
  theme(legend.position = c(0.15, 0.85))

ggsave(file.path(fig_dir, "fig2_rdd_scatter.pdf"), fig2, width = 8, height = 5.5)
ggsave(file.path(fig_dir, "fig2_rdd_scatter.png"), fig2, width = 8, height = 5.5, dpi = 300)

# ============================================================
# Figure 3: RDD Plot — Log Assessed Value per Sq Ft
# ============================================================
cat("Creating Figure 3: RDD per sq ft...\n")

rdd_bins_sqft <- rdd_narrow %>%
  mutate(gfa_bin = round(gfa / bin_width) * bin_width) %>%
  group_by(gfa_bin) %>%
  summarise(
    mean_log_assess_sqft = mean(log_assess_per_sqft, na.rm = TRUE),
    n = n(),
    .groups = "drop"
  ) %>%
  filter(n >= 5) %>%
  mutate(above = gfa_bin >= 25000)

fig3 <- ggplot(rdd_bins_sqft, aes(x = gfa_bin, y = mean_log_assess_sqft)) +
  geom_point(aes(color = above, size = n), alpha = 0.7) +
  geom_smooth(data = filter(rdd_bins_sqft, !above),
              method = "lm", formula = y ~ poly(x, 2),
              color = apep_colors[2], fill = apep_colors[2],
              alpha = 0.15, linewidth = 1) +
  geom_smooth(data = filter(rdd_bins_sqft, above),
              method = "lm", formula = y ~ poly(x, 2),
              color = apep_colors[1], fill = apep_colors[1],
              alpha = 0.15, linewidth = 1) +
  geom_vline(xintercept = 25000, linetype = "dashed", color = "red", linewidth = 0.7) +
  scale_color_manual(values = c(apep_colors[2], apep_colors[1]),
                     labels = c("No Disclosure", "Mandatory Disclosure"),
                     name = "") +
  scale_size_continuous(guide = "none", range = c(1, 4)) +
  scale_x_continuous(labels = scales::comma) +
  labs(
    title = "Log Assessed Value per Square Foot",
    subtitle = "Tests whether disclosure premium is driven by size vs. unit-value",
    x = "Gross Floor Area (sq ft)",
    y = "Log Assessed Value per Sq Ft ($)",
    caption = "Source: NYC PLUTO. Dashed line = 25,000 sq ft threshold."
  ) +
  theme_apep()

ggsave(file.path(fig_dir, "fig3_rdd_per_sqft.pdf"), fig3, width = 8, height = 5.5)
ggsave(file.path(fig_dir, "fig3_rdd_per_sqft.png"), fig3, width = 8, height = 5.5, dpi = 300)

# ============================================================
# Figure 4: Covariate Balance
# ============================================================
cat("Creating Figure 4: Covariate balance...\n")

cov_results <- results$covariate_balance
if (length(cov_results) > 0) {
  cov_df <- bind_rows(lapply(cov_results, as.data.frame)) %>%
    mutate(
      significant = pvalue < 0.05,
      variable = factor(variable, levels = rev(variable))
    )

  fig4 <- ggplot(cov_df, aes(x = estimate, y = variable)) +
    geom_vline(xintercept = 0, linetype = "solid", color = "grey50") +
    geom_errorbarh(aes(xmin = estimate - 1.96 * se, xmax = estimate + 1.96 * se),
                   height = 0.2, color = "grey40") +
    geom_point(aes(color = significant), size = 3) +
    scale_color_manual(values = c("FALSE" = apep_colors[1], "TRUE" = apep_colors[2]),
                       labels = c("Not Significant", "Significant at 5%"),
                       name = "") +
    labs(
      title = "Covariate Balance at the 25,000 Sq Ft Threshold",
      subtitle = "RDD estimates with robust 95% confidence intervals",
      x = "RDD Estimate (Discontinuity in Covariate)",
      y = "",
      caption = "Each row shows the rdrobust estimate of the discontinuity in a pre-determined covariate."
    ) +
    theme_apep() +
    theme(legend.position = c(0.8, 0.2))

  ggsave(file.path(fig_dir, "fig4_covariate_balance.pdf"), fig4, width = 7, height = 4.5)
  ggsave(file.path(fig_dir, "fig4_covariate_balance.png"), fig4, width = 7, height = 4.5, dpi = 300)
}

# ============================================================
# Figure 5: Bandwidth Sensitivity
# ============================================================
cat("Creating Figure 5: Bandwidth sensitivity...\n")

bw_df <- bind_rows(lapply(robustness$bandwidth, as.data.frame))

fig5 <- ggplot(bw_df, aes(x = bandwidth, y = estimate)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
  geom_ribbon(aes(ymin = ci_lower, ymax = ci_upper), alpha = 0.2, fill = apep_colors[1]) +
  geom_line(color = apep_colors[1], linewidth = 1) +
  geom_point(color = apep_colors[1], size = 3) +
  geom_text(aes(label = paste0(round(multiplier * 100), "%")),
            vjust = -1.2, size = 3, color = "grey40") +
  labs(
    title = "Bandwidth Sensitivity of Main RDD Estimate",
    subtitle = "Labels show percentage of MSE-optimal bandwidth",
    x = "Bandwidth (sq ft)",
    y = "RDD Estimate (Log Assessed Value)",
    caption = "Shaded area = robust 95% CI. Dashed line = zero."
  ) +
  theme_apep()

ggsave(file.path(fig_dir, "fig5_bw_sensitivity.pdf"), fig5, width = 7, height = 5)
ggsave(file.path(fig_dir, "fig5_bw_sensitivity.png"), fig5, width = 7, height = 5, dpi = 300)

# ============================================================
# Figure 6: Placebo Cutoffs
# ============================================================
cat("Creating Figure 6: Placebo cutoffs...\n")

placebo_df <- bind_rows(lapply(robustness$placebo, as.data.frame)) %>%
  mutate(
    is_real = cutoff == 25000,
    cutoff_label = paste0(scales::comma(cutoff), " sq ft")
  )

# Add the real estimate
real_est <- results$main_assess
placebo_df <- bind_rows(
  placebo_df,
  tibble(cutoff = 25000, estimate = real_est$estimate, se = real_est$se_robust,
         pvalue = real_est$pv_robust, is_real = TRUE,
         cutoff_label = "25,000 sq ft\n(True Threshold)")
)

fig6 <- ggplot(placebo_df, aes(x = cutoff, y = estimate)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
  geom_errorbar(aes(ymin = estimate - 1.96 * se, ymax = estimate + 1.96 * se,
                    color = is_real), width = 800) +
  geom_point(aes(color = is_real, shape = is_real), size = 3) +
  scale_color_manual(values = c("FALSE" = "grey50", "TRUE" = apep_colors[2]),
                     guide = "none") +
  scale_shape_manual(values = c("FALSE" = 16, "TRUE" = 17), guide = "none") +
  scale_x_continuous(labels = scales::comma, breaks = seq(15000, 45000, 5000)) +
  labs(
    title = "Placebo Cutoff Tests",
    subtitle = "RDD estimates at false thresholds (grey) vs. true 25,000 sq ft threshold (orange)",
    x = "Cutoff (sq ft)",
    y = "RDD Estimate (Log Assessed Value)",
    caption = "Error bars = robust 95% CI. Only the true threshold should show a significant effect."
  ) +
  theme_apep()

ggsave(file.path(fig_dir, "fig6_placebo_cutoffs.pdf"), fig6, width = 8, height = 5)
ggsave(file.path(fig_dir, "fig6_placebo_cutoffs.png"), fig6, width = 8, height = 5, dpi = 300)

# ============================================================
# Figure 7: Heterogeneity by Building Type
# ============================================================
cat("Creating Figure 7: Heterogeneity...\n")

het_dfs <- list()

if (length(robustness$het_type) > 0) {
  het_dfs[["Building Type"]] <- bind_rows(lapply(robustness$het_type, as.data.frame)) %>%
    mutate(category = "Building Type", subgroup = type)
}
if (length(robustness$het_borough) > 0) {
  het_dfs[["Borough"]] <- bind_rows(lapply(robustness$het_borough, as.data.frame)) %>%
    mutate(category = "Borough", subgroup = borough)
}
if (length(robustness$het_age) > 0) {
  het_dfs[["Construction Era"]] <- bind_rows(lapply(robustness$het_age, as.data.frame)) %>%
    mutate(category = "Construction Era", subgroup = cohort)
}

if (length(het_dfs) > 0) {
  het_all <- bind_rows(het_dfs)

  fig7 <- ggplot(het_all, aes(x = estimate, y = subgroup)) +
    geom_vline(xintercept = 0, linetype = "dashed", color = "grey50") +
    geom_errorbarh(aes(xmin = estimate - 1.96 * se, xmax = estimate + 1.96 * se),
                   height = 0.25, color = "grey40") +
    geom_point(aes(color = pvalue < 0.05), size = 3) +
    scale_color_manual(values = c("FALSE" = apep_colors[1], "TRUE" = apep_colors[2]),
                       labels = c("p > 0.05", "p < 0.05"), name = "") +
    facet_wrap(~category, scales = "free_y", ncol = 1) +
    labs(
      title = "Heterogeneous Treatment Effects",
      subtitle = "RDD estimates by building type, borough, and construction era",
      x = "RDD Estimate (Log Assessed Value)",
      y = "",
      caption = "Error bars = robust 95% CI. Each panel shows a different dimension of heterogeneity."
    ) +
    theme_apep() +
    theme(strip.text = element_text(face = "bold", size = 11))

  ggsave(file.path(fig_dir, "fig7_heterogeneity.pdf"), fig7, width = 7, height = 8)
  ggsave(file.path(fig_dir, "fig7_heterogeneity.png"), fig7, width = 7, height = 8, dpi = 300)
}

# ============================================================
# Figure 8: LL84 Compliance First Stage
# ============================================================
cat("Creating Figure 8: First stage...\n")

first_stage_bins <- rdd_narrow %>%
  mutate(gfa_bin = round(gfa / bin_width) * bin_width) %>%
  group_by(gfa_bin) %>%
  summarise(
    pct_ll84 = mean(has_ll84, na.rm = TRUE),
    n = n(),
    .groups = "drop"
  ) %>%
  filter(n >= 5) %>%
  mutate(above = gfa_bin >= 25000)

fig8 <- ggplot(first_stage_bins, aes(x = gfa_bin, y = pct_ll84)) +
  geom_point(aes(color = above, size = n), alpha = 0.7) +
  geom_smooth(data = filter(first_stage_bins, !above),
              method = "lm", color = apep_colors[2], fill = apep_colors[2],
              alpha = 0.15, linewidth = 1) +
  geom_smooth(data = filter(first_stage_bins, above),
              method = "lm", color = apep_colors[1], fill = apep_colors[1],
              alpha = 0.15, linewidth = 1) +
  geom_vline(xintercept = 25000, linetype = "dashed", color = "red", linewidth = 0.7) +
  scale_color_manual(values = c(apep_colors[2], apep_colors[1]),
                     labels = c("Below Threshold", "Above Threshold"),
                     name = "") +
  scale_size_continuous(guide = "none", range = c(1, 4)) +
  scale_x_continuous(labels = scales::comma) +
  scale_y_continuous(labels = scales::percent) +
  labs(
    title = "First Stage: LL84 Compliance Rate by Building Size",
    subtitle = "Sharp jump in energy disclosure compliance at 25,000 sq ft",
    x = "Gross Floor Area (sq ft)",
    y = "Share of Buildings with LL84 Filing (%)",
    caption = "Source: NYC PLUTO merged with LL84 data. Dashed line = 25,000 sq ft threshold."
  ) +
  theme_apep()

ggsave(file.path(fig_dir, "fig8_first_stage.pdf"), fig8, width = 8, height = 5.5)
ggsave(file.path(fig_dir, "fig8_first_stage.png"), fig8, width = 8, height = 5.5, dpi = 300)

cat("\nAll figures saved to:", fig_dir, "\n")
cat("Figures: fig1-fig8 (.pdf and .png)\n")
