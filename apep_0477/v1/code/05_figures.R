###############################################################################
# 05_figures.R — Publication-quality figures
# apep_0477: Do Energy Labels Move Markets?
###############################################################################

source("00_packages.R")

DATA_DIR <- "../data"
FIG_DIR <- "../figures"
dir.create(FIG_DIR, showWarnings = FALSE, recursive = TRUE)

df <- as.data.table(read_parquet(file.path(DATA_DIR, "analysis_sample.parquet")))

# Load results
rdd_dt <- fread(file.path(DATA_DIR, "rdd_results.csv"))
bw_dt <- fread(file.path(DATA_DIR, "bandwidth_sensitivity.csv"))
placebo_dt <- fread(file.path(DATA_DIR, "placebo_cutoff_results.csv"))

# Color palette
pal <- c("E/F" = "#E41A1C", "D/E" = "#377EB8", "C/D" = "#4DAF4A",
         "B/C" = "#984EA3", "A/B" = "#FF7F00")

###############################################################################
# Figure 1: EPC Score Distribution with Band Boundaries
###############################################################################

cat("Figure 1: EPC score distribution...\n")

p1 <- ggplot(df, aes(x = epc_score)) +
  geom_histogram(binwidth = 1, fill = "grey60", color = "grey30", linewidth = 0.1) +
  geom_vline(xintercept = EPC_BOUNDARIES, linetype = "dashed",
             color = pal, linewidth = 0.8) +
  annotate("text", x = EPC_BOUNDARIES, y = Inf, label = EPC_BAND_NAMES,
           vjust = 1.5, hjust = 0.5, fontface = "bold", size = 3.5,
           color = pal) +
  annotate("text", x = c(10, 30, 47, 62, 75, 87, 96),
           y = -Inf, vjust = -0.5, size = 3,
           label = c("G", "F", "E", "D", "C", "B", "A"),
           fontface = "bold") +
  labs(
    x = "EPC Energy Efficiency Score (SAP)",
    y = "Number of Transactions",
    title = "Distribution of EPC Scores in Analysis Sample",
    subtitle = "Dashed lines mark band boundaries; vertical axis shows matched transaction count"
  ) +
  scale_x_continuous(breaks = seq(0, 100, 10)) +
  coord_cartesian(xlim = c(1, 100))

ggsave(file.path(FIG_DIR, "fig1_epc_distribution.pdf"), p1,
       width = 8, height = 5)

###############################################################################
# Figure 2: RDD Plots at Each Boundary (Raw Binned Means)
###############################################################################

cat("Figure 2: RDD scatter plots...\n")

rdd_plots <- list()

for (i in seq_along(EPC_BOUNDARIES)) {
  b <- EPC_BOUNDARIES[i]
  bname <- EPC_BAND_NAMES[i]

  # Bin data: 1-point bins within ±15 of cutoff
  sub <- df[abs(epc_score - b) <= 15]
  binned <- sub[, .(mean_log_price = mean(log_price),
                     se_price = sd(log_price) / sqrt(.N),
                     n = .N),
                by = epc_score]

  rdd_plots[[i]] <- ggplot(binned, aes(x = epc_score, y = mean_log_price)) +
    geom_point(aes(size = n), alpha = 0.6, color = "grey40") +
    geom_vline(xintercept = b, linetype = "dashed", color = pal[i],
               linewidth = 0.8) +
    geom_smooth(data = binned[epc_score < b], method = "lm",
                se = TRUE, color = pal[i], fill = pal[i], alpha = 0.15) +
    geom_smooth(data = binned[epc_score >= b], method = "lm",
                se = TRUE, color = pal[i], fill = pal[i], alpha = 0.15) +
    labs(
      title = paste0(bname, " Boundary (score = ", b, ")"),
      x = "EPC Score",
      y = "Mean Log Transaction Price"
    ) +
    scale_size_continuous(guide = "none") +
    coord_cartesian(xlim = c(b - 15, b + 15))
}

p2 <- wrap_plots(rdd_plots, ncol = 2) +
  plot_annotation(
    title = "RDD Plots: Mean Log Price at EPC Band Boundaries",
    subtitle = "Each point is a 1-score bin; fitted lines are local linear"
  )

ggsave(file.path(FIG_DIR, "fig2_rdd_plots.pdf"), p2, width = 10, height = 12)

###############################################################################
# Figure 3: Multi-Cutoff RDD Estimates (Coefficient Plot)
###############################################################################

cat("Figure 3: Multi-cutoff coefficient plot...\n")

main_est <- rdd_dt[tenure == "All" & period == "Overall"]
main_est[, boundary := factor(boundary, levels = rev(EPC_BAND_NAMES))]

p3 <- ggplot(main_est, aes(x = estimate, y = boundary, color = boundary)) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "grey50") +
  geom_errorbarh(aes(xmin = ci_lower, xmax = ci_upper),
                 height = 0.2, linewidth = 0.8) +
  geom_point(size = 3) +
  scale_color_manual(values = pal, guide = "none") +
  labs(
    x = "RDD Estimate (Log Price Discontinuity)",
    y = "EPC Band Boundary",
    title = "Price Discontinuities at EPC Band Boundaries",
    subtitle = "Robust bias-corrected estimates; 95% CI"
  )

ggsave(file.path(FIG_DIR, "fig3_multicutoff_coefs.pdf"), p3, width = 7, height = 5)

###############################################################################
# Figure 4: Time-Varying Effects (Crisis Amplification)
###############################################################################

cat("Figure 4: Crisis amplification...\n")

period_est <- rdd_dt[tenure == "All" & period != "Overall" &
                       boundary %in% c("E/F", "D/E", "C/D")]
period_est[, period := factor(period, levels = PERIOD_LABELS)]
period_est[, boundary := factor(boundary, levels = EPC_BAND_NAMES)]

p4 <- ggplot(period_est, aes(x = period, y = estimate, color = boundary,
                              group = boundary)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
  geom_line(linewidth = 0.8) +
  geom_pointrange(aes(ymin = ci_lower, ymax = ci_upper), size = 0.5) +
  scale_color_manual(values = pal, name = "Boundary") +
  labs(
    x = "",
    y = "RDD Estimate",
    title = "EPC Label Effects Over Time: Crisis Amplification",
    subtitle = "Separate RDD estimates by period; vertical bars are 95% CI"
  ) +
  theme(axis.text.x = element_text(angle = 15, hjust = 1))

ggsave(file.path(FIG_DIR, "fig4_crisis_amplification.pdf"), p4,
       width = 8, height = 5)

###############################################################################
# Figure 5: MEES Decomposition (Rental vs Owner at E/F)
###############################################################################

cat("Figure 5: MEES tenure decomposition...\n")

ef_tenure <- rdd_dt[boundary == "E/F" & period != "Overall" &
                      tenure %in% c("rental", "owner")]
ef_tenure[, period := factor(period, levels = PERIOD_LABELS)]

p5 <- ggplot(ef_tenure, aes(x = period, y = estimate, color = tenure,
                              group = tenure)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
  geom_line(linewidth = 0.8) +
  geom_pointrange(aes(ymin = ci_lower, ymax = ci_upper), size = 0.5) +
  scale_color_manual(values = c("rental" = "#E41A1C", "owner" = "#377EB8"),
                     name = "Tenure",
                     labels = c("rental" = "Rental (Private)",
                                "owner" = "Owner-Occupied")) +
  labs(
    x = "",
    y = "RDD Estimate at E/F Boundary",
    title = "MEES Regulatory Effect: Rental vs Owner-Occupied",
    subtitle = "Owner-occupied serves as placebo (MEES applies only to rentals)"
  ) +
  theme(axis.text.x = element_text(angle = 15, hjust = 1))

ggsave(file.path(FIG_DIR, "fig5_mees_tenure.pdf"), p5, width = 8, height = 5)

###############################################################################
# Figure 6: Bandwidth Sensitivity
###############################################################################

cat("Figure 6: Bandwidth sensitivity...\n")

bw_dt[, boundary := factor(boundary, levels = EPC_BAND_NAMES)]

p6 <- ggplot(bw_dt, aes(x = bw_mult, y = estimate, color = boundary)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
  geom_ribbon(aes(ymin = estimate - 1.96 * se_robust,
                  ymax = estimate + 1.96 * se_robust,
                  fill = boundary), alpha = 0.1, color = NA) +
  geom_line(linewidth = 0.8) +
  geom_point(size = 2) +
  geom_vline(xintercept = 1, linetype = "dotted", color = "grey40") +
  facet_wrap(~boundary, scales = "free_y", ncol = 3) +
  scale_color_manual(values = pal, guide = "none") +
  scale_fill_manual(values = pal, guide = "none") +
  labs(
    x = "Bandwidth Multiplier (1 = MSE-optimal)",
    y = "RDD Estimate",
    title = "Bandwidth Sensitivity of RDD Estimates",
    subtitle = "Shaded area: 95% CI; dotted line marks MSE-optimal bandwidth"
  )

ggsave(file.path(FIG_DIR, "fig6_bandwidth_sensitivity.pdf"), p6,
       width = 10, height = 6)

###############################################################################
# Figure 7: Placebo Cutoffs
###############################################################################

cat("Figure 7: Placebo cutoffs...\n")

placebo_dt[, is_real := factor(is_real, labels = c("Placebo", "Real"))]

p7 <- ggplot(placebo_dt, aes(x = cutoff, y = estimate, color = is_real)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
  geom_pointrange(aes(ymin = estimate - 1.96 * se_robust,
                      ymax = estimate + 1.96 * se_robust),
                  size = 0.5) +
  scale_color_manual(values = c("Placebo" = "grey50", "Real" = "#E41A1C"),
                     name = "") +
  labs(
    x = "EPC Score Cutoff",
    y = "RDD Estimate",
    title = "Real vs Placebo Cutoffs",
    subtitle = "Real boundaries should show larger discontinuities than placebo cutoffs"
  ) +
  scale_x_continuous(breaks = seq(20, 100, 5))

ggsave(file.path(FIG_DIR, "fig7_placebo_cutoffs.pdf"), p7, width = 8, height = 5)

###############################################################################
# Figure 8: McCrary Density Plots
###############################################################################

cat("Figure 8: McCrary density plots...\n")

# Load saved McCrary results for consistent p-values
mccrary_saved <- fread(file.path(DATA_DIR, "mccrary_results.csv"))

density_plots <- list()

for (i in 1:3) {  # E/F, D/E, C/D (main boundaries)
  b <- EPC_BOUNDARIES[i]
  bname <- EPC_BAND_NAMES[i]

  sub <- df[abs(epc_score - b) <= 20]

  # Use saved p-value for consistency with Table 5
  saved_p <- mccrary_saved[boundary == bname, p_value]

  # Manual density plot
  binned_dens <- sub[, .N, by = epc_score]

  density_plots[[i]] <- ggplot(binned_dens, aes(x = epc_score, y = N)) +
    geom_col(fill = "grey70", width = 0.8) +
    geom_vline(xintercept = b, linetype = "dashed", color = pal[i],
               linewidth = 0.8) +
    labs(
      title = sprintf("%s (p = %.3f)", bname, saved_p),
      x = "EPC Score",
      y = "Count"
    ) +
    coord_cartesian(xlim = c(b - 20, b + 20))
}

p8 <- wrap_plots(density_plots, ncol = 3) +
  plot_annotation(
    title = "McCrary Density Tests at EPC Band Boundaries",
    subtitle = "p-values from Cattaneo, Jansson & Ma (2020) density test"
  )

ggsave(file.path(FIG_DIR, "fig8_mccrary_density.pdf"), p8,
       width = 12, height = 4)

cat("\nAll figures generated.\n")
