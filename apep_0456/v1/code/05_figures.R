## ==========================================================================
## 05_figures.R — Publication-ready figures
## APEP-0456: Low Emission Zone Boundaries and Property Values
## ==========================================================================

source("00_packages.R")

# ---- Load data ----
dvf <- fread(file.path(data_dir, "dvf_zfe_analysis.csv"))
dvf[, date_mutation := as.Date(date_mutation)]
results <- readRDS(file.path(data_dir, "rdd_results.rds"))
rob <- readRDS(file.path(data_dir, "robustness_results.rds"))

post <- dvf[strong_enforcement == 1]
pre  <- dvf[enforcement_phase == 0]

# ---- Figure 1: Map of Paris ZFE with transactions ----
cat("Figure 1: Map...\n")

zfe_paris <- st_read(file.path(data_dir, "zfe_boundaries/zfe_paris.geojson"), quiet = TRUE)
zfe_paris <- st_transform(zfe_paris, 4326)

# Sample transactions near boundary for plotting
paris_post <- post[zfe_city == "Paris" & abs(dist_km) <= 3]
paris_sample <- paris_post[sample(.N, min(5000, .N))]

fig1 <- ggplot() +
  geom_sf(data = zfe_paris, fill = apep_colors[1], alpha = 0.15,
          color = apep_colors[1], linewidth = 0.8) +
  geom_point(data = paris_sample,
             aes(x = longitude, y = latitude, color = factor(inside_zfe)),
             size = 0.3, alpha = 0.4) +
  scale_color_manual(
    values = c("0" = apep_colors[2], "1" = apep_colors[1]),
    labels = c("Outside ZFE", "Inside ZFE"),
    name = NULL
  ) +
  labs(
    title = "Property Transactions Near the Paris ZFE Boundary",
    subtitle = "Post-ZFE period, within 3 km of boundary",
    x = "Longitude", y = "Latitude"
  ) +
  theme_apep() +
  theme(legend.position = "bottom")

ggsave(file.path(fig_dir, "fig1_map.pdf"), fig1, width = 8, height = 7)
ggsave(file.path(fig_dir, "fig1_map.png"), fig1, width = 8, height = 7, dpi = 300)

# ---- Figure 2: McCrary Density Test ----
cat("Figure 2: Density test...\n")

# Compute histogram-style density for plotting
bw_dens <- 0.1  # bin width in km
bins_post <- post[abs(dist_km) <= 5, .(count = .N), by = .(bin = round(dist_km / bw_dens) * bw_dens)]

fig2 <- ggplot(bins_post, aes(x = bin, y = count)) +
  geom_bar(stat = "identity", fill = "grey70", color = "grey50", width = bw_dens * 0.9) +
  geom_vline(xintercept = 0, color = apep_colors[2], linewidth = 1, linetype = "dashed") +
  annotate("text", x = 0.3, y = max(bins_post$count) * 0.95,
           label = paste0("McCrary p = ", round(rob$density_post$test$p_jk, 3)),
           hjust = 0, size = 3.5, fontface = "italic") +
  labs(
    title = "Density of Transactions at ZFE Boundary",
    subtitle = "Post-ZFE period. Dashed line = ZFE boundary (cutoff)",
    x = "Distance to ZFE Boundary (km, positive = inside)",
    y = "Number of Transactions"
  ) +
  theme_apep()

ggsave(file.path(fig_dir, "fig2_density.pdf"), fig2, width = 8, height = 5)
ggsave(file.path(fig_dir, "fig2_density.png"), fig2, width = 8, height = 5, dpi = 300)

# ---- Figure 3: Main RDD Plot ----
cat("Figure 3: RDD plot...\n")

# Create binned scatter plot
bin_width <- 0.1  # km
rdd_bins <- post[abs(dist_km) <= 5, .(
  mean_log_price = mean(log_price_sqm),
  se = sd(log_price_sqm) / sqrt(.N),
  n = .N
), by = .(bin = round(dist_km / bin_width) * bin_width)]

# Fit local polynomials for each side (respecting data range)
left_data <- post[dist_km < 0 & dist_km >= -5]
right_data <- post[dist_km >= 0 & dist_km <= 5]

# Use geom_smooth in the plot directly (avoids manual loess issues)

# Add side variable to bins for coloring
rdd_bins[, side := ifelse(bin < 0, "Outside ZFE", "Inside ZFE")]

fig3 <- ggplot(rdd_bins[n >= 10 & abs(bin) <= 5], aes(x = bin, y = mean_log_price)) +
  geom_point(aes(color = side), size = 1.5, alpha = 0.6) +
  geom_smooth(data = rdd_bins[n >= 10 & bin < 0 & bin >= -5],
              method = "loess", span = 0.5, se = TRUE,
              color = apep_colors[2], fill = apep_colors[2], alpha = 0.2) +
  geom_smooth(data = rdd_bins[n >= 10 & bin > 0 & bin <= 5],
              method = "loess", span = 0.5, se = TRUE,
              color = apep_colors[1], fill = apep_colors[1], alpha = 0.2) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "grey40", linewidth = 0.5) +
  scale_color_manual(values = c("Outside ZFE" = apep_colors[2], "Inside ZFE" = apep_colors[1])) +
  labs(
    title = "Property Prices at the ZFE Boundary",
    subtitle = paste0("RDD estimate: ", round(results$main$tau, 4),
                      " (", round((exp(results$main$tau) - 1) * 100, 1), "%)"),
    x = "Distance to ZFE Boundary (km, positive = inside)",
    y = "Log Price per Square Meter",
    color = NULL
  ) +
  theme_apep()

ggsave(file.path(fig_dir, "fig3_rdd_main.pdf"), fig3, width = 8, height = 5.5)
ggsave(file.path(fig_dir, "fig3_rdd_main.png"), fig3, width = 8, height = 5.5, dpi = 300)

# ---- Figure 4: Pre vs. Post Comparison ----
cat("Figure 4: Pre vs. Post RDD...\n")

# Binned scatter for pre-period
rdd_bins_pre <- pre[abs(dist_km) <= 5, .(
  mean_log_price = mean(log_price_sqm),
  n = .N,
  period = "Pre-ZFE"
), by = .(bin = round(dist_km / bin_width) * bin_width)]

rdd_bins_post <- post[abs(dist_km) <= 5, .(
  mean_log_price = mean(log_price_sqm),
  n = .N,
  period = "Post-ZFE"
), by = .(bin = round(dist_km / bin_width) * bin_width)]

bins_both <- rbind(rdd_bins_pre, rdd_bins_post)

fig4 <- ggplot(bins_both[n >= 10], aes(x = bin, y = mean_log_price, color = period)) +
  geom_point(size = 1.5, alpha = 0.6) +
  geom_smooth(method = "loess", span = 0.3, se = TRUE, alpha = 0.15) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "grey40") +
  scale_color_manual(values = c("Pre-ZFE" = apep_colors[2], "Post-ZFE" = apep_colors[1])) +
  labs(
    title = "Property Prices at ZFE Boundary: Before vs. After",
    subtitle = "Pre-ZFE period serves as placebo (no discontinuity expected)",
    x = "Distance to ZFE Boundary (km, positive = inside)",
    y = "Log Price per Square Meter",
    color = NULL
  ) +
  theme_apep()

ggsave(file.path(fig_dir, "fig4_pre_post.pdf"), fig4, width = 8, height = 5.5)
ggsave(file.path(fig_dir, "fig4_pre_post.png"), fig4, width = 8, height = 5.5, dpi = 300)

# ---- Figure 5: Covariate Balance ----
cat("Figure 5: Covariate balance...\n")

if (nrow(rob$balance) > 0) {
  # Normalize to t-statistics for comparable scale across covariates
  bal_plot <- rob$balance
  bal_plot$t_stat <- bal_plot$tau / bal_plot$se
  bal_plot$sig <- ifelse(bal_plot$pval < 0.05, "Significant", "Not significant")

  fig5 <- ggplot(bal_plot, aes(x = covariate, y = t_stat, color = sig)) +
    geom_point(size = 3) +
    geom_errorbar(aes(ymin = t_stat - 1.96, ymax = t_stat + 1.96),
                  width = 0.2) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
    geom_hline(yintercept = c(-1.96, 1.96), linetype = "dotted", color = "grey60") +
    scale_color_manual(values = c("Significant" = apep_colors[2],
                                   "Not significant" = apep_colors[1]),
                       name = NULL) +
    coord_flip() +
    labs(
      title = "Covariate Balance at ZFE Boundary",
      subtitle = "t-statistics for RDD estimates using covariates as outcomes",
      x = NULL,
      y = "t-statistic (dotted lines = ±1.96)"
    ) +
    theme_apep() +
    theme(legend.position = "bottom")

  ggsave(file.path(fig_dir, "fig5_balance.pdf"), fig5, width = 7, height = 4)
  ggsave(file.path(fig_dir, "fig5_balance.png"), fig5, width = 7, height = 4, dpi = 300)
}

# ---- Figure 6: Bandwidth Sensitivity ----
cat("Figure 6: Bandwidth sensitivity...\n")

if (nrow(rob$bandwidth_sensitivity) > 0) {
  bw_data <- rob$bandwidth_sensitivity
  opt_bw_val <- results$main$bw

  fig6 <- ggplot(bw_data, aes(x = bandwidth_km, y = tau)) +
    geom_ribbon(aes(ymin = tau - 1.96 * se_robust, ymax = tau + 1.96 * se_robust),
                fill = apep_colors[1], alpha = 0.2) +
    geom_point(size = 2.5, color = apep_colors[1]) +
    geom_line(color = apep_colors[1], linewidth = 0.5) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
    geom_vline(xintercept = opt_bw_val, linetype = "dotted", color = apep_colors[2]) +
    annotate("text", x = opt_bw_val + 0.1, y = max(bw_data$tau + 1.96 * bw_data$se_robust),
             label = "Optimal BW", hjust = 0, size = 3, color = apep_colors[2]) +
    labs(
      title = "Bandwidth Sensitivity",
      subtitle = "RDD estimate across different bandwidth choices",
      x = "Bandwidth (km)",
      y = "Treatment Effect (log points)"
    ) +
    theme_apep()

  ggsave(file.path(fig_dir, "fig6_bw_sensitivity.pdf"), fig6, width = 8, height = 5)
  ggsave(file.path(fig_dir, "fig6_bw_sensitivity.png"), fig6, width = 8, height = 5, dpi = 300)
}

# ---- Figure 7: Placebo Cutoffs ----
cat("Figure 7: Placebo cutoffs...\n")

if (nrow(rob$placebo_cutoffs) > 0) {
  pc_data <- rob$placebo_cutoffs
  # Add the real cutoff
  real_point <- data.frame(cutoff = 0, tau = results$main$tau,
                           se = results$main$se, pval = 0, real = TRUE)
  pc_data$real <- FALSE
  pc_plot <- bind_rows(pc_data, real_point)

  fig7 <- ggplot(pc_plot, aes(x = cutoff, y = tau)) +
    geom_ribbon(aes(ymin = tau - 1.96 * se, ymax = tau + 1.96 * se),
                fill = "grey80", alpha = 0.5) +
    geom_point(aes(color = real, size = real)) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
    geom_vline(xintercept = 0, linetype = "dotted", color = apep_colors[2]) +
    scale_color_manual(values = c("FALSE" = "grey50", "TRUE" = apep_colors[1]),
                       guide = "none") +
    scale_size_manual(values = c("FALSE" = 2, "TRUE" = 4), guide = "none") +
    labs(
      title = "Placebo Cutoff Tests",
      subtitle = "Real cutoff at 0 (blue). Placebos should show no effect.",
      x = "Cutoff Location (km from real boundary)",
      y = "RDD Estimate (log points)"
    ) +
    theme_apep()

  ggsave(file.path(fig_dir, "fig7_placebo_cutoffs.pdf"), fig7, width = 8, height = 5)
  ggsave(file.path(fig_dir, "fig7_placebo_cutoffs.png"), fig7, width = 8, height = 5, dpi = 300)
}

# ---- Figure 8: City-by-city estimates ----
cat("Figure 8: City estimates...\n")

if (nrow(results$city) > 0) {
  fig8 <- ggplot(results$city, aes(x = reorder(city, tau), y = tau)) +
    geom_point(size = 3, color = apep_colors[1]) +
    geom_errorbar(aes(ymin = tau - 1.96 * se_robust, ymax = tau + 1.96 * se_robust),
                  width = 0.2, color = apep_colors[1]) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
    coord_flip() +
    labs(
      title = "ZFE Price Effect by City",
      subtitle = "Separate RDD estimates for each city with 95% CI",
      x = NULL,
      y = "Treatment Effect (log points)"
    ) +
    theme_apep()

  ggsave(file.path(fig_dir, "fig8_by_city.pdf"), fig8, width = 7, height = 4)
  ggsave(file.path(fig_dir, "fig8_by_city.png"), fig8, width = 7, height = 4, dpi = 300)
}

# ---- Figure 9: Temporal dynamics ----
cat("Figure 9: Temporal dynamics...\n")

het_df <- results$heterogeneity
year_rows <- het_df[grepl("^Year", het_df$group), ]
if (nrow(year_rows) > 0) {
  year_rows$yr <- as.numeric(gsub("Year ", "", year_rows$group))

  fig9 <- ggplot(year_rows, aes(x = yr, y = tau)) +
    geom_ribbon(aes(ymin = tau - 1.96 * se_robust, ymax = tau + 1.96 * se_robust),
                fill = apep_colors[1], alpha = 0.2) +
    geom_point(size = 2.5, color = apep_colors[1]) +
    geom_line(color = apep_colors[1], linewidth = 0.5) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
    labs(
      title = "ZFE Boundary Effect Over Time",
      subtitle = "Year-by-year RDD estimates with 95% CI",
      x = "Year",
      y = "Treatment Effect (log points)"
    ) +
    scale_x_continuous(breaks = year_rows$yr) +
    theme_apep()

  ggsave(file.path(fig_dir, "fig9_temporal.pdf"), fig9, width = 8, height = 5)
  ggsave(file.path(fig_dir, "fig9_temporal.png"), fig9, width = 8, height = 5, dpi = 300)
}

cat("\nAll figures saved to:", fig_dir, "\n")
cat("Files:", paste(list.files(fig_dir), collapse = ", "), "\n")
