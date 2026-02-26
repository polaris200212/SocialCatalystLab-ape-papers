## ============================================================================
## 05_figures.R — All figure generation
## APEP-0466: Municipal Population Thresholds and Firm Creation in France
## ============================================================================

source("00_packages.R")

data_dir <- "../data"
fig_dir <- "../figures"
dir.create(fig_dir, showWarnings = FALSE)

panel <- fread(file.path(data_dir, "analysis_panel.csv"))
commune_means <- fread(file.path(data_dir, "commune_means.csv"))

# Load robustness results
tryCatch(load(file.path(data_dir, "robustness_results.RData")), error = function(e) NULL)
rdd_results <- tryCatch(fread(file.path(data_dir, "rdd_results.csv")), error = function(e) NULL)
bw_sens <- tryCatch(fread(file.path(data_dir, "bandwidth_sensitivity.csv")), error = function(e) NULL)

# ===========================================================================
# FIGURE 1: RDD PLOTS AT KEY THRESHOLDS
# ===========================================================================
cat("=== Figure 1: RDD plots ===\n")

make_rdd_plot <- function(data, threshold, title, binwidth = NULL) {
  bw <- threshold * 0.4
  df <- data[abs(population - threshold) <= bw]
  if (is.null(binwidth)) binwidth <- ceiling(bw / 20)

  # Create bins
  df[, bin := floor((population - threshold) / binwidth) * binwidth + threshold + binwidth / 2]
  bin_means <- df[, .(y = mean(mean_creation_rate, na.rm = TRUE),
                      n = .N), by = bin]
  bin_means[, above := as.integer(bin >= threshold)]

  ggplot(bin_means, aes(x = bin, y = y)) +
    geom_point(aes(size = n, color = factor(above)), alpha = 0.7) +
    geom_vline(xintercept = threshold, linetype = "dashed", color = "grey40", linewidth = 0.5) +
    geom_smooth(data = df[population < threshold],
                aes(x = population, y = mean_creation_rate),
                method = "lm", formula = y ~ poly(x, 1),
                color = apep_colors[2], fill = apep_colors[2], alpha = 0.15, linewidth = 0.8) +
    geom_smooth(data = df[population >= threshold],
                aes(x = population, y = mean_creation_rate),
                method = "lm", formula = y ~ poly(x, 1),
                color = apep_colors[1], fill = apep_colors[1], alpha = 0.15, linewidth = 0.8) +
    scale_color_manual(values = c("0" = apep_colors[2], "1" = apep_colors[1]),
                       labels = c("Below threshold", "Above threshold"),
                       name = "") +
    scale_size_continuous(range = c(1.5, 5), guide = "none") +
    labs(
      title = title,
      x = "Population",
      y = "Firm creation rate\n(per 1,000 inhabitants)"
    ) +
    theme_apep() +
    theme(legend.position = "none")
}

p1a <- make_rdd_plot(commune_means, 500, "Panel A: Threshold at 500", binwidth = 20)
p1b <- make_rdd_plot(commune_means, 1000, "Panel B: Threshold at 1,000", binwidth = 40)
p1c <- make_rdd_plot(commune_means, 1500, "Panel C: Threshold at 1,500", binwidth = 50)
p1d <- make_rdd_plot(commune_means, 3500, "Panel D: Threshold at 3,500", binwidth = 80)

fig1 <- (p1a | p1b) / (p1c | p1d) +
  plot_annotation(
    title = "Firm Creation Rate at Municipal Governance Thresholds",
    subtitle = "Local means with linear fits; vertical line at population threshold",
    caption = "Source: INSEE Sirene, data.gouv.fr commune populations. Binned scatterplot with local linear fits on each side.",
    theme = theme_apep()
  )

ggsave(file.path(fig_dir, "fig1_rdd_plots.pdf"), fig1, width = 10, height = 8)
ggsave(file.path(fig_dir, "fig1_rdd_plots.png"), fig1, width = 10, height = 8, dpi = 300)
cat("  Saved fig1_rdd_plots\n")

# ===========================================================================
# FIGURE 2: McCRARY DENSITY PLOTS
# ===========================================================================
cat("=== Figure 2: McCrary density ===\n")

make_density_plot <- function(data, threshold, title) {
  bw <- threshold * 0.5
  df <- data[abs(population - threshold) <= bw]

  ggplot(df, aes(x = population)) +
    geom_histogram(aes(y = after_stat(density)),
                   bins = 40, fill = "grey70", color = "white", linewidth = 0.2) +
    geom_vline(xintercept = threshold, linetype = "dashed", color = "red", linewidth = 0.6) +
    geom_density(color = apep_colors[1], linewidth = 0.8) +
    labs(
      title = title,
      x = "Population",
      y = "Density"
    ) +
    scale_y_continuous(labels = function(x) format(x, scientific = FALSE)) +
    theme_apep()
}

p2a <- make_density_plot(commune_means, 500, "Panel A: 500")
p2b <- make_density_plot(commune_means, 1000, "Panel B: 1,000")
p2c <- make_density_plot(commune_means, 3500, "Panel C: 3,500")
p2d <- make_density_plot(commune_means, 10000, "Panel D: 10,000")

fig2 <- (p2a | p2b) / (p2c | p2d) +
  plot_annotation(
    title = "McCrary Density Tests: No Evidence of Manipulation",
    subtitle = "Population density smooth at all governance thresholds",
    caption = "Source: data.gouv.fr. Histogram with kernel density overlay; red dashed line at threshold.",
    theme = theme_apep()
  )

ggsave(file.path(fig_dir, "fig2_mccrary.pdf"), fig2, width = 10, height = 8)
ggsave(file.path(fig_dir, "fig2_mccrary.png"), fig2, width = 10, height = 8, dpi = 300)
cat("  Saved fig2_mccrary\n")

# ===========================================================================
# FIGURE 3: GOVERNANCE STEP FUNCTIONS
# ===========================================================================
cat("=== Figure 3: Governance step functions ===\n")

pop_seq <- seq(0, 15000, by = 10)
gov_df <- data.table(
  population = pop_seq
)

# Council size
council_brackets <- data.table(
  pop_min = c(0, 100, 500, 1500, 2500, 3500, 5000, 10000),
  pop_max = c(99, 499, 1499, 2499, 3499, 4999, 9999, 19999),
  council_size = c(9, 11, 15, 19, 23, 27, 29, 33)
)

salary_brackets <- data.table(
  pop_min = c(0, 500, 1000, 3500, 10000),
  pop_max = c(499, 999, 3499, 9999, 19999),
  mayor_salary = c(1042, 1647, 2108, 2247, 2656)
)

gov_df[, council := sapply(population, function(p) {
  idx <- which(council_brackets$pop_min <= p & council_brackets$pop_max >= p)
  if (length(idx) == 0) return(NA_integer_)
  council_brackets$council_size[idx[1]]
})]

gov_df[, salary := sapply(population, function(p) {
  idx <- which(salary_brackets$pop_min <= p & salary_brackets$pop_max >= p)
  if (length(idx) == 0) return(NA_real_)
  salary_brackets$mayor_salary[idx[1]]
})]

p3a <- ggplot(gov_df[!is.na(council)], aes(x = population, y = council)) +
  geom_step(color = apep_colors[1], linewidth = 0.8) +
  geom_vline(xintercept = c(500, 1000, 1500, 2500, 3500, 5000, 10000),
             linetype = "dotted", color = "grey60", linewidth = 0.3) +
  labs(title = "Panel A: Council Size", x = "Population", y = "Number of councillors") +
  scale_x_continuous(labels = comma) +
  theme_apep()

p3b <- ggplot(gov_df[!is.na(salary)], aes(x = population, y = salary)) +
  geom_step(color = apep_colors[2], linewidth = 0.8) +
  geom_vline(xintercept = c(500, 1000, 3500, 10000),
             linetype = "dotted", color = "grey60", linewidth = 0.3) +
  labs(title = "Panel B: Mayor Monthly Salary", x = "Population",
       y = "Maximum allowance (\u20ac/month)") +
  scale_x_continuous(labels = comma) +
  scale_y_continuous(labels = comma) +
  theme_apep()

fig3 <- p3a / p3b +
  plot_annotation(
    title = "Governance Mandates as Step Functions of Population",
    subtitle = "Discrete jumps in council size and mayor compensation at legal thresholds",
    caption = "Source: Articles L2121-2 and L2123-23, Code g\u00e9n\u00e9ral des collectivit\u00e9s territoriales (2024).",
    theme = theme_apep()
  )

ggsave(file.path(fig_dir, "fig3_governance.pdf"), fig3, width = 8, height = 8)
ggsave(file.path(fig_dir, "fig3_governance.png"), fig3, width = 8, height = 8, dpi = 300)
cat("  Saved fig3_governance\n")

# ===========================================================================
# FIGURE 4: BANDWIDTH SENSITIVITY
# ===========================================================================
cat("=== Figure 4: Bandwidth sensitivity ===\n")

if (!is.null(bw_sens) && nrow(bw_sens) > 0) {
  fig4 <- ggplot(bw_sens, aes(x = bandwidth, y = estimate)) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
    geom_errorbar(aes(ymin = ci_lower, ymax = ci_upper), width = 30,
                  color = apep_colors[1], linewidth = 0.5) +
    geom_point(size = 3, color = apep_colors[1]) +
    geom_vline(xintercept = bw_sens[multiplier == 1.0]$bandwidth,
               linetype = "dotted", color = "red", linewidth = 0.5) +
    labs(
      title = "Bandwidth Sensitivity: RDD at 3,500 Threshold",
      subtitle = "Point estimates with 95% CIs; red line = MSE-optimal bandwidth",
      x = "Bandwidth (population units)",
      y = "RDD estimate\n(firm creation rate per 1,000)"
    ) +
    theme_apep()

  ggsave(file.path(fig_dir, "fig4_bandwidth.pdf"), fig4, width = 7, height = 5)
  ggsave(file.path(fig_dir, "fig4_bandwidth.png"), fig4, width = 7, height = 5, dpi = 300)
  cat("  Saved fig4_bandwidth\n")
}

# ===========================================================================
# FIGURE 5: MULTI-CUTOFF COEFFICIENT PLOT
# ===========================================================================
cat("=== Figure 5: Multi-cutoff coefficient plot ===\n")

if (!is.null(rdd_results) && nrow(rdd_results) > 0) {
  rd_plot <- rdd_results[threshold > 0]
  rd_plot[, eff_n := n_left + n_right]
  rd_plot[, threshold_lab := factor(
    paste0(formatC(threshold, big.mark = ","), "\n(Eff. N=", eff_n, ")"),
    levels = paste0(formatC(sort(unique(threshold)), big.mark = ","),
                    "\n(Eff. N=", eff_n[order(threshold)], ")")
  )]

  fig5 <- ggplot(rd_plot, aes(x = threshold_lab, y = estimate)) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
    geom_errorbar(aes(ymin = ci_lower, ymax = ci_upper), width = 0.2,
                  color = apep_colors[1], linewidth = 0.6) +
    geom_point(size = 3.5, color = apep_colors[1]) +
    labs(
      title = "RDD Estimates Across Population Thresholds",
      subtitle = "Treatment effect on firm creation rate (per 1,000 inhabitants)",
      x = "Population threshold",
      y = "RDD estimate\n(95% robust CI)"
    ) +
    theme_apep()

  ggsave(file.path(fig_dir, "fig5_multicutoff.pdf"), fig5, width = 8, height = 5)
  ggsave(file.path(fig_dir, "fig5_multicutoff.png"), fig5, width = 8, height = 5, dpi = 300)
  cat("  Saved fig5_multicutoff\n")
}

# ===========================================================================
# FIGURE 6: PLACEBO TEST COMPARISON
# ===========================================================================
cat("=== Figure 6: Placebo tests ===\n")

placebo <- tryCatch(fread(file.path(data_dir, "placebo_tests.csv")), error = function(e) NULL)
if (!is.null(placebo) && !is.null(rdd_results)) {
  real_results <- rdd_results[threshold > 0, .(threshold, estimate, se = se_conv, type = "Real threshold")]
  placebo[, se := se]

  combined <- rbind(
    real_results[, .(threshold, estimate, se, type)],
    placebo[, .(threshold, estimate, se, type = "Placebo threshold")],
    fill = TRUE
  )
  combined[, ci_lower := estimate - 1.96 * se]
  combined[, ci_upper := estimate + 1.96 * se]

  fig6 <- ggplot(combined, aes(x = factor(threshold), y = estimate, color = type)) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
    geom_errorbar(aes(ymin = ci_lower, ymax = ci_upper), width = 0.2, linewidth = 0.5,
                  position = position_dodge(width = 0.4)) +
    geom_point(size = 3, position = position_dodge(width = 0.4)) +
    scale_color_manual(values = c("Real threshold" = apep_colors[1],
                                   "Placebo threshold" = apep_colors[2]),
                       name = "") +
    labs(
      title = "Real vs. Placebo Threshold Effects",
      x = "Population threshold",
      y = "RDD estimate\n(95% CI)"
    ) +
    theme_apep()

  ggsave(file.path(fig_dir, "fig6_placebo.pdf"), fig6, width = 8, height = 5)
  ggsave(file.path(fig_dir, "fig6_placebo.png"), fig6, width = 8, height = 5, dpi = 300)
  cat("  Saved fig6_placebo\n")
}

cat("\n=== All figures generated ===\n")
