###############################################################################
# 05_figures.R — Generate all figures
# Paper: The Price of Position (apep_0490)
###############################################################################

source("00_packages.R")

cat("=== Loading data ===\n")
df <- fread(file.path(DATA_DIR, "rdd_sample.csv"))
full <- fread(file.path(DATA_DIR, "full_sample.csv"))

PRIMARY <- "ln_cite_3y"
if (!(PRIMARY %in% names(df))) PRIMARY <- "ln_cited_by_count"

# ============================================================================
# Figure 1: Submission Density Around Cutoff
# ============================================================================

cat("=== Figure 1: Submission Density ===\n")

# Histogram of submissions by minute relative to cutoff
fig1_data <- df[abs(run_var) <= 90]

p1 <- ggplot(fig1_data, aes(x = run_var)) +
  geom_histogram(binwidth = 2, fill = "steelblue", color = "white", alpha = 0.8) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "red", linewidth = 0.8) +
  annotate("text", x = -40, y = Inf, label = "Before cutoff\n(last in today's batch)",
           vjust = 1.5, hjust = 0.5, size = 3.5, color = "grey40") +
  annotate("text", x = 40, y = Inf, label = "After cutoff\n(first in tomorrow's batch)",
           vjust = 1.5, hjust = 0.5, size = 3.5, color = "grey40") +
  labs(
    x = "Minutes from 14:00 ET cutoff",
    y = "Number of submissions",
    title = "Submission Density Around the arXiv Daily Cutoff",
    subtitle = "AI/ML papers (cs.AI, cs.CL, cs.LG, stat.ML), 2012-2020"
  ) +
  scale_x_continuous(breaks = seq(-90, 90, by = 15)) +
  theme_apep

ggsave(file.path(FIG_DIR, "fig1_density.pdf"), p1, width = 8, height = 5)
cat("Saved fig1_density.pdf\n")

# McCrary density plot
density_est <- rddensity(X = df$run_var, c = 0)
pdf(file.path(FIG_DIR, "fig1b_mccrary.pdf"), width = 8, height = 5)
rdplotdensity(density_est, df$run_var,
              title = "McCrary Density Test at 14:00 ET Cutoff",
              xlabel = "Minutes from cutoff",
              ylabel = "Density")
dev.off()
cat("Saved fig1b_mccrary.pdf\n")

# ============================================================================
# Figure 2: First Stage — Position Discontinuity
# ============================================================================

cat("=== Figure 2: First Stage ===\n")

if ("position_pctile" %in% names(df)) {
  # Binned scatterplot
  bin_width <- 5  # 5-minute bins
  fig2_data <- df[abs(run_var) <= 90]
  fig2_data[, bin := floor(run_var / bin_width) * bin_width + bin_width / 2]

  fig2_means <- fig2_data[, .(
    mean_position = mean(position_pctile, na.rm = TRUE),
    se_position = sd(position_pctile, na.rm = TRUE) / sqrt(.N),
    n = .N
  ), by = bin]

  p2 <- ggplot(fig2_means, aes(x = bin, y = mean_position)) +
    geom_point(aes(size = n), color = "steelblue", alpha = 0.8) +
    geom_errorbar(aes(ymin = mean_position - 1.96 * se_position,
                      ymax = mean_position + 1.96 * se_position),
                  width = 1, color = "steelblue", alpha = 0.5) +
    geom_vline(xintercept = 0, linetype = "dashed", color = "red", linewidth = 0.8) +
    # Add local polynomial fits on each side
    geom_smooth(data = fig2_data[run_var < 0], aes(x = run_var, y = position_pctile),
                method = "loess", color = "darkblue", fill = "lightblue", alpha = 0.3) +
    geom_smooth(data = fig2_data[run_var > 0], aes(x = run_var, y = position_pctile),
                method = "loess", color = "darkblue", fill = "lightblue", alpha = 0.3) +
    labs(
      x = "Minutes from 14:00 ET cutoff",
      y = "Position percentile within announcement",
      title = "First Stage: Listing Position Jumps at the Cutoff",
      subtitle = "Papers submitted just after the cutoff are listed first in the next day's announcement"
    ) +
    scale_size_continuous(guide = "none") +
    scale_y_continuous(labels = percent) +
    theme_apep

  ggsave(file.path(FIG_DIR, "fig2_first_stage.pdf"), p2, width = 8, height = 5)
  cat("Saved fig2_first_stage.pdf\n")
}

# ============================================================================
# Figure 3: Main RDD Plot — Citations
# ============================================================================

cat("=== Figure 3: Main RDD Plot ===\n")

if (PRIMARY %in% names(df)) {
  bin_width <- 5
  fig3_data <- df[abs(run_var) <= 90 & !is.na(get(PRIMARY))]
  fig3_data[, bin := floor(run_var / bin_width) * bin_width + bin_width / 2]

  fig3_means <- fig3_data[, .(
    mean_y = mean(get(PRIMARY), na.rm = TRUE),
    se_y = sd(get(PRIMARY), na.rm = TRUE) / sqrt(.N),
    n = .N
  ), by = bin]

  y_label <- switch(PRIMARY,
    "ln_cite_3y" = "Log(3-year citations + 1)",
    "ln_cited_by_count" = "Log(total citations + 1)",
    "ln_cite_1y" = "Log(1-year citations + 1)",
    PRIMARY
  )

  p3 <- ggplot(fig3_means, aes(x = bin, y = mean_y)) +
    geom_point(aes(size = n), color = "steelblue", alpha = 0.8) +
    geom_errorbar(aes(ymin = mean_y - 1.96 * se_y,
                      ymax = mean_y + 1.96 * se_y),
                  width = 1, color = "steelblue", alpha = 0.5) +
    geom_vline(xintercept = 0, linetype = "dashed", color = "red", linewidth = 0.8) +
    geom_smooth(data = fig3_data[run_var < 0], aes(x = run_var, y = get(PRIMARY)),
                method = "loess", color = "darkblue", fill = "lightblue", alpha = 0.3) +
    geom_smooth(data = fig3_data[run_var > 0], aes(x = run_var, y = get(PRIMARY)),
                method = "loess", color = "darkblue", fill = "lightblue", alpha = 0.3) +
    labs(
      x = "Minutes from 14:00 ET cutoff",
      y = y_label,
      title = "The Visibility Premium: Citations Jump at the Cutoff",
      subtitle = "Papers listed first in the next announcement receive more citations"
    ) +
    scale_size_continuous(guide = "none") +
    theme_apep

  ggsave(file.path(FIG_DIR, "fig3_rdd_citations.pdf"), p3, width = 8, height = 5)
  cat("Saved fig3_rdd_citations.pdf\n")
}

# ============================================================================
# Figure 4: rdplot — Formal RDD Visualization
# ============================================================================

cat("=== Figure 4: rdplot ===\n")

if (PRIMARY %in% names(df)) {
  y_clean <- df[[PRIMARY]]
  x_clean <- df$run_var
  valid <- !is.na(y_clean) & !is.na(x_clean)

  pdf(file.path(FIG_DIR, "fig4_rdplot.pdf"), width = 8, height = 5)
  rdplot(y = y_clean[valid], x = x_clean[valid], c = 0,
         title = "RDD: Citations at the arXiv Daily Cutoff",
         x.label = "Minutes from 14:00 ET cutoff",
         y.label = y_label)
  dev.off()
  cat("Saved fig4_rdplot.pdf\n")
}

# ============================================================================
# Figure 5: Bandwidth Sensitivity
# ============================================================================

cat("=== Figure 5: Bandwidth Sensitivity ===\n")

bw_file <- file.path(TAB_DIR, "bandwidth_sensitivity.csv")
if (file.exists(bw_file)) {
  bw_df <- fread(bw_file)

  p5 <- ggplot(bw_df, aes(x = bandwidth, y = coef)) +
    geom_point(size = 3, color = "steelblue") +
    geom_errorbar(aes(ymin = ci_lower, ymax = ci_upper), width = 2, color = "steelblue") +
    geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
    labs(
      x = "Bandwidth (minutes)",
      y = "RDD estimate (robust)",
      title = "Bandwidth Sensitivity",
      subtitle = "Effect stable across bandwidth choices"
    ) +
    theme_apep

  ggsave(file.path(FIG_DIR, "fig5_bandwidth.pdf"), p5, width = 7, height = 5)
  cat("Saved fig5_bandwidth.pdf\n")
}

# ============================================================================
# Figure 6: Donut RDD Results
# ============================================================================

cat("=== Figure 6: Donut RDD ===\n")

donut_file <- file.path(TAB_DIR, "donut_rdd.csv")
if (file.exists(donut_file)) {
  donut_df <- fread(donut_file)

  # Add the baseline (no donut)
  rdd_base <- rdrobust(y = df[[PRIMARY]][!is.na(df[[PRIMARY]])],
                        x = df$run_var[!is.na(df[[PRIMARY]])], c = 0)
  donut_df <- rbind(
    data.table(donut_minutes = 0, coef = rdd_base$coef["Robust", ],
               se = rdd_base$se["Robust", ],
               ci_lower = rdd_base$ci["Robust", 1],
               ci_upper = rdd_base$ci["Robust", 2],
               p_value = rdd_base$pv["Robust", ],
               n_eff = rdd_base$N_h[1] + rdd_base$N_h[2],
               bw = rdd_base$bws["h", "left"]),
    donut_df, fill = TRUE
  )

  p6 <- ggplot(donut_df, aes(x = donut_minutes, y = coef)) +
    geom_point(size = 3, color = "steelblue") +
    geom_errorbar(aes(ymin = ci_lower, ymax = ci_upper), width = 0.5, color = "steelblue") +
    geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
    labs(
      x = "Donut hole (minutes excluded around cutoff)",
      y = "RDD estimate (robust)",
      title = "Donut RDD: Excluding Papers Near the Cutoff",
      subtitle = "Effect persists after removing potentially strategic submissions"
    ) +
    scale_x_continuous(breaks = c(0, 2, 5, 10, 15)) +
    theme_apep

  ggsave(file.path(FIG_DIR, "fig6_donut.pdf"), p6, width = 7, height = 5)
  cat("Saved fig6_donut.pdf\n")
}

# ============================================================================
# Figure 7: Placebo Cutoffs
# ============================================================================

cat("=== Figure 7: Placebo Cutoffs ===\n")

placebo_file <- file.path(TAB_DIR, "placebo_cutoffs.csv")
if (file.exists(placebo_file)) {
  placebo_df <- fread(placebo_file)

  p7 <- ggplot(placebo_df, aes(x = cutoff_hour, y = coef,
                                 color = is_real, shape = is_real)) +
    geom_point(size = 3) +
    geom_errorbar(aes(ymin = coef - 1.96 * se, ymax = coef + 1.96 * se),
                  width = 0.3) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
    scale_color_manual(values = c("TRUE" = "red", "FALSE" = "steelblue"),
                        labels = c("Placebo", "Real (14:00)"),
                        guide = "none") +
    scale_shape_manual(values = c("TRUE" = 17, "FALSE" = 16),
                        guide = "none") +
    labs(
      x = "Cutoff hour (ET)",
      y = "RDD estimate",
      title = "Placebo Cutoffs: Only the Real 14:00 ET Cutoff Matters",
      subtitle = "Red triangle = real cutoff; blue circles = placebo cutoffs"
    ) +
    scale_x_continuous(breaks = seq(10, 18, by = 1)) +
    theme_apep

  ggsave(file.path(FIG_DIR, "fig7_placebo.pdf"), p7, width = 7, height = 5)
  cat("Saved fig7_placebo.pdf\n")
}

# ============================================================================
# Figure 8: Year-by-Year Estimates
# ============================================================================

cat("=== Figure 8: Year-by-Year ===\n")

year_file <- file.path(TAB_DIR, "year_by_year.csv")
if (file.exists(year_file)) {
  year_df <- fread(year_file)

  p8 <- ggplot(year_df, aes(x = year, y = coef)) +
    geom_point(size = 3, color = "steelblue") +
    geom_errorbar(aes(ymin = ci_lower, ymax = ci_upper), width = 0.3, color = "steelblue") +
    geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
    labs(
      x = "Submission year",
      y = "RDD estimate (robust)",
      title = "Year-by-Year RDD Estimates",
      subtitle = "The visibility premium persists across years"
    ) +
    scale_x_continuous(breaks = 2012:2020) +
    theme_apep

  ggsave(file.path(FIG_DIR, "fig8_yearly.pdf"), p8, width = 7, height = 5)
  cat("Saved fig8_yearly.pdf\n")
}

# ============================================================================
# Figure 9: Covariate Balance
# ============================================================================

cat("=== Figure 9: Balance ===\n")

balance_file <- file.path(TAB_DIR, "balance_tests.csv")
if (file.exists(balance_file)) {
  bal_df <- fread(balance_file)
  bal_df[, variable := factor(variable, levels = rev(variable))]

  p9 <- ggplot(bal_df, aes(x = coef, y = variable)) +
    geom_point(size = 3, color = "steelblue") +
    geom_errorbarh(aes(xmin = coef - 1.96 * se, xmax = coef + 1.96 * se),
                    height = 0.2, color = "steelblue") +
    geom_vline(xintercept = 0, linetype = "dashed", color = "red") +
    labs(
      x = "RDD estimate at cutoff",
      y = "",
      title = "Covariate Balance at the Cutoff",
      subtitle = "Pre-determined characteristics are smooth through the cutoff"
    ) +
    theme_apep

  ggsave(file.path(FIG_DIR, "fig9_balance.pdf"), p9, width = 7, height = 5)
  cat("Saved fig9_balance.pdf\n")
}

cat("\n=== All figures generated ===\n")
