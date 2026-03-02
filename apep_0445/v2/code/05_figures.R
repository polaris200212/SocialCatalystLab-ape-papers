###############################################################################
# 05_figures.R
# Generate all figures for the paper
# APEP-0445 v2
###############################################################################

this_file <- tryCatch(sys.frame(1)$ofile, error = function(e) NULL)
if (is.null(this_file)) this_file <- "."
source(file.path(dirname(this_file), "00_packages.R"))

rdd_sample <- readRDS(file.path(data_dir, "rdd_sample.rds"))
panel_rdd <- readRDS(file.path(data_dir, "panel_rdd.rds"))

cat("Data loaded for figures\n\n")


###############################################################################
# Figure 1: McCrary Density Test
###############################################################################
cat("Figure 1: McCrary Density Test\n")

mccrary <- readRDS(file.path(data_dir, "mccrary_test.rds"))

density_data <- rdd_sample %>%
  filter(poverty_rate >= 5, poverty_rate <= 40) %>%
  mutate(bin = round(poverty_rate * 2) / 2) %>%
  group_by(bin) %>%
  summarize(count = n(), .groups = "drop") %>%
  mutate(density = count / sum(count) / 0.5)

p1 <- ggplot(density_data, aes(x = bin, y = density)) +
  geom_col(aes(fill = bin >= 20), width = 0.45, alpha = 0.8) +
  geom_vline(xintercept = 20, linetype = "dashed", color = "red", linewidth = 0.8) +
  scale_fill_manual(values = c("grey60", "steelblue"),
                    labels = c("Below threshold", "Above threshold"),
                    name = NULL) +
  labs(
    x = "Tract Poverty Rate (%)",
    y = "Density",
    title = "Distribution of Census Tracts Around the 20% Poverty Threshold",
    subtitle = sprintf("McCrary test: t = %.2f, p = %.3f",
                       mccrary$test$t_jk, mccrary$test$p_jk)
  ) +
  annotate("text", x = 20, y = max(density_data$density) * 0.95,
           label = "OZ Eligibility\nThreshold", hjust = -0.1,
           size = 3, color = "red", fontface = "italic")

ggsave(file.path(fig_dir, "fig1_mccrary.pdf"), p1, width = 8, height = 5)
cat("  Saved fig1_mccrary.pdf\n")


###############################################################################
# Figure 2: First Stage -- OZ Designation at Cutoff
###############################################################################
cat("Figure 2: First Stage\n")

binned_fs <- rdd_sample %>%
  filter(poverty_rate >= 5, poverty_rate <= 40) %>%
  mutate(bin = round(poverty_rate)) %>%
  group_by(bin) %>%
  summarize(
    oz_rate = mean(oz_designated, na.rm = TRUE),
    n = n(),
    se = sqrt(oz_rate * (1 - oz_rate) / n),
    .groups = "drop"
  )

p2 <- ggplot(binned_fs, aes(x = bin, y = oz_rate)) +
  geom_point(aes(size = n), alpha = 0.7, color = "steelblue") +
  geom_errorbar(aes(ymin = oz_rate - 1.96 * se, ymax = oz_rate + 1.96 * se),
                width = 0.3, alpha = 0.5) +
  geom_vline(xintercept = 20, linetype = "dashed", color = "red", linewidth = 0.8) +
  geom_smooth(data = filter(binned_fs, bin < 20), method = "lm",
              se = TRUE, color = "grey50", fill = "grey80") +
  geom_smooth(data = filter(binned_fs, bin >= 20), method = "lm",
              se = TRUE, color = "steelblue", fill = "lightblue") +
  scale_y_continuous(labels = percent_format()) +
  scale_size_continuous(range = c(1, 5), guide = "none") +
  labs(
    x = "Tract Poverty Rate (%)",
    y = "Probability of OZ Designation",
    title = "First Stage: OZ Designation Probability at the 20% Poverty Threshold"
  )

ggsave(file.path(fig_dir, "fig2_first_stage.pdf"), p2, width = 8, height = 5)
cat("  Saved fig2_first_stage.pdf\n")


###############################################################################
# Figure 3: Reduced-Form RDD -- Total Employment Change
###############################################################################
cat("Figure 3: Reduced-Form RDD -- Total Employment\n")

binned_emp <- rdd_sample %>%
  filter(poverty_rate >= 5, poverty_rate <= 40, !is.na(delta_total_emp)) %>%
  mutate(bin = round(poverty_rate)) %>%
  group_by(bin) %>%
  summarize(
    mean_delta = mean(delta_total_emp, na.rm = TRUE),
    se = sd(delta_total_emp, na.rm = TRUE) / sqrt(n()),
    n = n(),
    .groups = "drop"
  )

p3 <- ggplot(binned_emp, aes(x = bin, y = mean_delta)) +
  geom_point(aes(size = n), alpha = 0.7, color = "steelblue") +
  geom_errorbar(aes(ymin = mean_delta - 1.96 * se, ymax = mean_delta + 1.96 * se),
                width = 0.3, alpha = 0.4) +
  geom_vline(xintercept = 20, linetype = "dashed", color = "red", linewidth = 0.8) +
  geom_smooth(data = filter(binned_emp, bin < 20), method = "lm",
              se = TRUE, color = "grey50", fill = "grey80") +
  geom_smooth(data = filter(binned_emp, bin >= 20), method = "lm",
              se = TRUE, color = "steelblue", fill = "lightblue") +
  geom_hline(yintercept = 0, linetype = "dotted", color = "grey60") +
  labs(
    x = "Tract Poverty Rate (%)",
    y = "Change in Total Employment (2019--2023 vs. 2015--2017)",
    title = "Reduced-Form RDD: Employment Change at the OZ Eligibility Threshold"
  )

ggsave(file.path(fig_dir, "fig3_rdd_total_emp.pdf"), p3, width = 8, height = 5)
cat("  Saved fig3_rdd_total_emp.pdf\n")


###############################################################################
# Figure 4: Reduced-Form RDD -- Information Sector Employment
###############################################################################
cat("Figure 4: Info Sector Employment RDD\n")

binned_info <- rdd_sample %>%
  filter(poverty_rate >= 5, poverty_rate <= 40, !is.na(delta_info_emp)) %>%
  mutate(bin = round(poverty_rate)) %>%
  group_by(bin) %>%
  summarize(
    mean_delta = mean(delta_info_emp, na.rm = TRUE),
    se = sd(delta_info_emp, na.rm = TRUE) / sqrt(n()),
    n = n(),
    .groups = "drop"
  )

p4 <- ggplot(binned_info, aes(x = bin, y = mean_delta)) +
  geom_point(aes(size = n), alpha = 0.7, color = "darkgreen") +
  geom_errorbar(aes(ymin = mean_delta - 1.96 * se, ymax = mean_delta + 1.96 * se),
                width = 0.3, alpha = 0.4) +
  geom_vline(xintercept = 20, linetype = "dashed", color = "red", linewidth = 0.8) +
  geom_smooth(data = filter(binned_info, bin < 20), method = "lm",
              se = TRUE, color = "grey50", fill = "grey80") +
  geom_smooth(data = filter(binned_info, bin >= 20), method = "lm",
              se = TRUE, color = "darkgreen", fill = "lightgreen") +
  geom_hline(yintercept = 0, linetype = "dotted", color = "grey60") +
  labs(
    x = "Tract Poverty Rate (%)",
    y = "Change in Information Sector Employment",
    title = "Reduced-Form RDD: Information Sector (NAICS 51) Employment Change"
  )

ggsave(file.path(fig_dir, "fig4_rdd_info_emp.pdf"), p4, width = 8, height = 5)
cat("  Saved fig4_rdd_info_emp.pdf\n")


###############################################################################
# Figure 5: Dynamic RDD -- Event Study at the Cutoff
###############################################################################
cat("Figure 5: Dynamic RDD Event Study\n")

dynamic <- readRDS(file.path(data_dir, "dynamic_rdd.rds"))

if (nrow(dynamic) > 0) {
  dynamic <- dynamic %>%
    mutate(post = year >= 2018)

  p5 <- ggplot(dynamic, aes(x = year, y = coef)) +
    geom_point(aes(color = post), size = 3) +
    geom_errorbar(aes(ymin = ci_lower, ymax = ci_upper, color = post),
                  width = 0.3) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
    geom_vline(xintercept = 2017.5, linetype = "dotted", color = "red",
               linewidth = 0.8) +
    scale_color_manual(values = c("grey50", "steelblue"),
                       labels = c("Pre-OZ", "Post-OZ"),
                       name = NULL) +
    scale_x_continuous(breaks = sort(unique(dynamic$year)),
                       labels = sort(unique(dynamic$year))) +
    labs(
      x = "Year",
      y = "RDD Estimate (Total Employment)",
      title = "Dynamic RDD: Year-by-Year Estimates at the 20% Poverty Threshold",
      subtitle = "Pre-period estimates should be near zero if design is valid"
    ) +
    annotate("text", x = 2017.5, y = max(dynamic$ci_upper, na.rm = TRUE),
             label = "OZ\nDesignated", hjust = 1.1, size = 3, color = "red")

  ggsave(file.path(fig_dir, "fig5_dynamic_rdd.pdf"), p5, width = 8, height = 5)
  cat("  Saved fig5_dynamic_rdd.pdf\n")
} else {
  cat("  WARNING: No dynamic RDD results to plot\n")
}


###############################################################################
# Figure 6: Bandwidth Sensitivity
###############################################################################
cat("Figure 6: Bandwidth Sensitivity\n")

bw_sens <- readRDS(file.path(data_dir, "bw_sensitivity.rds"))

if (nrow(bw_sens) > 0) {
  p6 <- ggplot(bw_sens, aes(x = bandwidth, y = coef)) +
    geom_point(size = 3, color = "steelblue") +
    geom_errorbar(aes(ymin = ci_lower, ymax = ci_upper),
                  width = 0.3, color = "steelblue") +
    geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
    labs(
      x = "Bandwidth (percentage points)",
      y = "RDD Estimate (Change in Total Employment)",
      title = "Bandwidth Sensitivity of the Main RDD Estimate"
    )

  ggsave(file.path(fig_dir, "fig6_bw_sensitivity.pdf"), p6, width = 7, height = 5)
  cat("  Saved fig6_bw_sensitivity.pdf\n")
}


###############################################################################
# Figure 7: Covariate Balance
###############################################################################
cat("Figure 7: Covariate Balance\n")

balance <- readRDS(file.path(data_dir, "balance_tests.rds"))

if (nrow(balance) > 0) {
  balance <- balance %>%
    mutate(
      std_coef = coef / se,
      variable = case_when(
        variable == "total_pop" ~ "Population",
        variable == "pct_bachelors" ~ "% Bachelor's",
        variable == "pct_white" ~ "% White",
        variable == "median_home_value" ~ "Median Home Value",
        variable == "unemployment_rate" ~ "Unemployment Rate",
        variable == "pre_total_emp" ~ "Pre-Period Total Emp",
        variable == "pre_info_emp" ~ "Pre-Period Info Emp",
        TRUE ~ variable
      )
    )

  p7 <- ggplot(balance, aes(x = reorder(variable, abs(std_coef)), y = std_coef)) +
    geom_point(size = 3, color = "steelblue") +
    geom_errorbar(aes(ymin = std_coef - 1.96, ymax = std_coef + 1.96),
                  width = 0.2, color = "grey60") +
    geom_hline(yintercept = 0, linetype = "dashed") +
    geom_hline(yintercept = c(-1.96, 1.96), linetype = "dotted", color = "red") +
    coord_flip() +
    labs(
      x = NULL,
      y = "Standardized RDD Coefficient (t-statistic)",
      title = "Covariate Balance at the 20% Poverty Threshold"
    )

  ggsave(file.path(fig_dir, "fig7_balance.pdf"), p7, width = 7, height = 5)
  cat("  Saved fig7_balance.pdf\n")
}


###############################################################################
# Figure 8: Placebo Cutoffs
###############################################################################
cat("Figure 8: Placebo Cutoffs\n")

placebo <- readRDS(file.path(data_dir, "placebo_cutoffs.rds"))

if (nrow(placebo) > 0) {
  main_res <- readRDS(file.path(data_dir, "main_rdd_results.rds"))
  real_est <- main_res[["Delta Total Emp"]]

  if (!is.null(real_est)) {
    placebo_plot <- bind_rows(
      placebo,
      data.frame(cutoff = 20, coef = real_est$coef, se = real_est$se_robust,
                 pval = real_est$pval, t_stat = real_est$coef / real_est$se_robust)
    ) %>%
      mutate(is_real = cutoff == 20)

    p8 <- ggplot(placebo_plot, aes(x = cutoff, y = coef)) +
      geom_point(aes(color = is_real, size = is_real)) +
      geom_errorbar(aes(ymin = coef - 1.96 * se, ymax = coef + 1.96 * se,
                        color = is_real), width = 0.5) +
      geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
      scale_color_manual(values = c("grey50", "red"), guide = "none") +
      scale_size_manual(values = c(2, 4), guide = "none") +
      labs(
        x = "Poverty Rate Cutoff (%)",
        y = "RDD Estimate",
        title = "Systematic Placebo Cutoff Test",
        subtitle = "Red = true cutoff (20%); grey = placebo cutoffs (every 1pp, 5-35%)"
      )

    ggsave(file.path(fig_dir, "fig8_placebo.pdf"), p8, width = 8, height = 5)
    cat("  Saved fig8_placebo.pdf\n")
  }
}


###############################################################################
# Figure 8b: Placebo t-statistic Histogram
###############################################################################
cat("Figure 8b: Placebo t-statistic Histogram\n")

if (nrow(placebo) > 0 && "t_stat" %in% names(placebo)) {
  real_t <- ifelse(!is.null(real_est), real_est$coef / real_est$se_robust, NA)

  p8b <- ggplot(placebo, aes(x = t_stat)) +
    geom_histogram(bins = 15, fill = "grey70", color = "white", alpha = 0.8) +
    geom_vline(xintercept = real_t, color = "red", linewidth = 1, linetype = "dashed") +
    geom_vline(xintercept = c(-1.96, 1.96), color = "grey40",
               linewidth = 0.5, linetype = "dotted") +
    labs(
      x = "t-statistic",
      y = "Count",
      title = "Distribution of Placebo t-statistics",
      subtitle = "Red dashed = true cutoff (20%); grey dotted = +/-1.96 critical values"
    ) +
    annotate("text", x = real_t, y = Inf, label = "True\ncutoff",
             vjust = 1.5, hjust = -0.1, color = "red", size = 3)

  ggsave(file.path(fig_dir, "fig8b_placebo_histogram.pdf"), p8b, width = 7, height = 5)
  cat("  Saved fig8b_placebo_histogram.pdf\n")
}


###############################################################################
# Figure 9: Infrastructure Heterogeneity
###############################################################################
cat("Figure 9: Infrastructure Heterogeneity\n")

infra_file <- file.path(data_dir, "infrastructure_heterogeneity.rds")
if (file.exists(infra_file)) {
  infra <- readRDS(infra_file)
  infra_total <- infra %>% filter(outcome == "Delta Total Emp")

  if (nrow(infra_total) > 0) {
    infra_total <- infra_total %>%
      mutate(quartile_label = paste0("Q", quartile))

    p9 <- ggplot(infra_total, aes(x = factor(quartile), y = coef)) +
      geom_point(size = 3, color = "steelblue") +
      geom_errorbar(aes(ymin = ci_lower, ymax = ci_upper),
                    width = 0.2, color = "steelblue") +
      geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
      labs(
        x = "Broadband Access Quartile (1 = lowest, 4 = highest)",
        y = "RDD Estimate (Change in Total Employment)",
        title = "Infrastructure Heterogeneity: RDD Estimates by Broadband Access",
        subtitle = "Null persists even in infrastructure-ready tracts"
      )

    ggsave(file.path(fig_dir, "fig9_infrastructure.pdf"), p9, width = 7, height = 5)
    cat("  Saved fig9_infrastructure.pdf\n")
  } else {
    cat("  No infrastructure results to plot\n")
  }
} else {
  cat("  Infrastructure data not available\n")
}


cat("\n=== All figures generated ===\n")
