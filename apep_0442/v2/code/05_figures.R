## ============================================================================
## 05_figures.R — All figures for the Civil War pension RDD paper (v2)
## Project: The First Retirement Age v2 (revision of apep_0442)
## ============================================================================

source("code/00_packages.R")

union <- readRDS(file.path(data_dir, "union_veterans.rds"))
confed <- readRDS(file.path(data_dir, "confed_veterans.rds"))
robust_results <- readRDS(file.path(data_dir, "robust_results.rds"))

## ---- Figure 1: Main RDD Plot — Labor Force Participation (1.4% Oversampled) ----
cat("Figure 1: RDD plot for LFP (1.4% oversampled)...\n")

bin_means <- union[, .(
  lfp = mean(in_labor_force, na.rm = TRUE),
  n = .N,
  se = sd(in_labor_force, na.rm = TRUE) / sqrt(.N)
), by = AGE]

p1 <- ggplot(bin_means, aes(x = AGE, y = lfp)) +
  geom_vline(xintercept = 62, linetype = "dashed", color = "grey40", linewidth = 0.5) +
  geom_point(aes(size = n), alpha = 0.7, color = apep_blue) +
  geom_errorbar(aes(ymin = lfp - 1.96 * se, ymax = lfp + 1.96 * se),
                width = 0.3, alpha = 0.3, color = apep_blue) +
  geom_smooth(data = bin_means[AGE < 62], method = "loess", span = 0.75,
              se = TRUE, color = apep_dark, fill = apep_grey, linewidth = 1) +
  geom_smooth(data = bin_means[AGE >= 62], method = "loess", span = 0.75,
              se = TRUE, color = apep_dark, fill = apep_grey, linewidth = 1) +
  scale_x_continuous(breaks = seq(45, 90, 5)) +
  scale_y_continuous(labels = percent_format(accuracy = 1)) +
  scale_size_continuous(guide = "none", range = c(1.5, 5)) +
  coord_cartesian(ylim = c(0, 1)) +
  annotate("text", x = 62.5, y = max(bin_means$lfp, na.rm = TRUE) * 0.98,
           label = "Age 62\n(pension eligible)", hjust = 0, size = 3.5, color = "grey30") +
  labs(
    x = "Age at 1910 Census",
    y = "Labor Force Participation Rate",
    title = "Labor Force Participation of Union Veterans by Age",
    subtitle = "IPUMS 1910 Census (1.4% oversampled). Vertical line: age 62 pension eligibility threshold.",
    caption = sprintf("Source: IPUMS 1910 Census (1.4%% oversampled, us1910l). N = %s Union veterans.",
                      format(nrow(union), big.mark = ","))
  )

ggsave(file.path(fig_dir, "fig1_rdd_lfp.pdf"), p1, width = 8, height = 5.5)
ggsave(file.path(fig_dir, "fig1_rdd_lfp.png"), p1, width = 8, height = 5.5, dpi = 300)

## ---- Figure 2: McCrary Density Test ----
cat("Figure 2: Density plot...\n")

age_density <- union[, .N, by = AGE]

# Add McCrary result annotation
dens_test <- rddensity(union$AGE, c = 62)

p2 <- ggplot(age_density, aes(x = AGE, y = N)) +
  geom_vline(xintercept = 62, linetype = "dashed", color = "grey40", linewidth = 0.5) +
  geom_col(fill = apep_blue, alpha = 0.7, width = 0.8) +
  scale_x_continuous(breaks = seq(45, 90, 5)) +
  scale_y_continuous(labels = comma_format()) +
  annotate("text", x = 75, y = max(age_density$N) * 0.9,
           label = sprintf("McCrary test:\nT = %.2f, p = %.3f",
                           dens_test$test$t_jk, dens_test$test$p_jk),
           hjust = 0, size = 3.5, color = "grey30") +
  labs(
    x = "Age at 1910 Census",
    y = "Number of Union Veterans",
    title = "Age Distribution of Union Veterans (1910 Census)",
    subtitle = "Density test at age 62 pension eligibility cutoff",
    caption = "Source: IPUMS 1910 Census (us1910l)."
  )

ggsave(file.path(fig_dir, "fig2_density.pdf"), p2, width = 8, height = 5)
ggsave(file.path(fig_dir, "fig2_density.png"), p2, width = 8, height = 5, dpi = 300)

## ---- Figure 3: Covariate Balance (5-panel) ----
cat("Figure 3: Covariate balance...\n")

cov_names <- c("literate", "native_born", "married", "urban", "white")
cov_labels <- c("Literate", "Native Born", "Married", "Urban", "White")

cov_means <- rbindlist(lapply(seq_along(cov_names), function(i) {
  union[, .(
    value = mean(get(cov_names[i]), na.rm = TRUE),
    se = sd(get(cov_names[i]), na.rm = TRUE) / sqrt(.N),
    n = .N,
    covariate = cov_labels[i]
  ), by = AGE]
}))

p3 <- ggplot(cov_means, aes(x = AGE, y = value)) +
  geom_vline(xintercept = 62, linetype = "dashed", color = "grey40", linewidth = 0.5) +
  geom_point(alpha = 0.5, size = 1.2, color = apep_blue) +
  geom_smooth(data = cov_means[AGE < 62], method = "loess", span = 0.75,
              se = TRUE, color = apep_dark, fill = apep_grey, linewidth = 0.8) +
  geom_smooth(data = cov_means[AGE >= 62], method = "loess", span = 0.75,
              se = TRUE, color = apep_dark, fill = apep_grey, linewidth = 0.8) +
  facet_wrap(~covariate, scales = "free_y", ncol = 3) +
  scale_x_continuous(breaks = seq(50, 85, 10)) +
  labs(
    x = "Age at 1910 Census",
    y = "Proportion",
    title = "Covariate Balance at the Age 62 Threshold",
    subtitle = "Pre-determined characteristics should be smooth through the cutoff",
    caption = "Source: IPUMS 1910 Census (us1910l)."
  )

ggsave(file.path(fig_dir, "fig3_balance.pdf"), p3, width = 10, height = 6)
ggsave(file.path(fig_dir, "fig3_balance.png"), p3, width = 10, height = 6, dpi = 300)

## ---- Figure 4: Diff-in-Disc Visual (Union vs Confederate) ----
cat("Figure 4: Difference-in-discontinuities...\n")

union_means <- union[AGE >= 50 & AGE <= 80, .(
  lfp = mean(in_labor_force, na.rm = TRUE),
  n = .N,
  group = "Union Veterans (Federal Pension)"
), by = AGE]

confed_means <- confed[AGE >= 50 & AGE <= 80, .(
  lfp = mean(in_labor_force, na.rm = TRUE),
  n = .N,
  group = "Confederate Veterans (No Federal Pension)"
), by = AGE]

both <- rbind(union_means, confed_means)

p4 <- ggplot(both, aes(x = AGE, y = lfp, color = group)) +
  geom_vline(xintercept = 62, linetype = "dashed", color = "grey40", linewidth = 0.5) +
  geom_point(aes(size = n), alpha = 0.5) +
  geom_smooth(data = both[AGE < 62], method = "loess", span = 0.75,
              se = TRUE, linewidth = 0.8, alpha = 0.15) +
  geom_smooth(data = both[AGE >= 62], method = "loess", span = 0.75,
              se = TRUE, linewidth = 0.8, alpha = 0.15) +
  scale_color_manual(values = c(
    "Confederate Veterans (No Federal Pension)" = apep_red,
    "Union Veterans (Federal Pension)" = apep_blue
  )) +
  scale_size_continuous(guide = "none", range = c(1, 5)) +
  scale_x_continuous(breaks = seq(50, 80, 5), limits = c(50, 80)) +
  scale_y_continuous(labels = percent_format(accuracy = 1)) +
  labs(
    x = "Age at 1910 Census",
    y = "Labor Force Participation Rate",
    color = NULL,
    title = "Difference-in-Discontinuities: Union vs. Confederate Veterans",
    subtitle = "Only Union veterans received federal pensions at age 62",
    caption = "Source: IPUMS 1910 Census (us1910l). X-axis restricted to ages 50-80."
  )

ggsave(file.path(fig_dir, "fig4_diff_in_disc.pdf"), p4, width = 9, height = 5.5)
ggsave(file.path(fig_dir, "fig4_diff_in_disc.png"), p4, width = 9, height = 5.5, dpi = 300)

## ---- Figure 5: Pension Schedule ----
cat("Figure 5: Pension schedule...\n")

schedule <- data.table(
  age_min = c(62, 70, 75),
  age_max = c(69, 74, 90),
  pension = c(12, 15, 20)
)

p5 <- ggplot(schedule, aes(xmin = age_min, xmax = age_max + 1, ymin = 0, ymax = pension)) +
  geom_rect(fill = apep_blue, alpha = 0.6, color = "white") +
  geom_text(aes(x = (age_min + age_max) / 2, y = pension / 2,
                label = paste0("$", pension, "/mo")), color = "white", fontface = "bold") +
  scale_x_continuous(breaks = c(62, 70, 75, 90), limits = c(55, 92)) +
  scale_y_continuous(labels = dollar_format()) +
  labs(
    x = "Veteran's Age",
    y = "Monthly Pension",
    title = "Civil War Pension Schedule (Service and Age Pension Act of 1907)",
    subtitle = "Sharp increases at ages 62, 70, and 75"
  )

ggsave(file.path(fig_dir, "fig5_pension_schedule.pdf"), p5, width = 7, height = 4)
ggsave(file.path(fig_dir, "fig5_pension_schedule.png"), p5, width = 7, height = 4, dpi = 300)

## ---- Figure 6: Bandwidth Sensitivity ----
cat("Figure 6: Bandwidth sensitivity...\n")

if (!is.null(robust_results$bandwidth) && nrow(robust_results$bandwidth) > 0) {
  bw_dt <- copy(robust_results$bandwidth)

  p6 <- ggplot(bw_dt, aes(x = bandwidth, y = coef)) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "grey60") +
    geom_point(size = 2.5, color = apep_blue) +
    geom_errorbar(aes(ymin = ci_lower, ymax = ci_upper), width = 0.3, color = apep_blue) +
    labs(
      x = "Bandwidth (Years)",
      y = "RD Estimate (LFP)",
      title = "Bandwidth Sensitivity",
      subtitle = "Point estimates and 95% CIs across bandwidth choices"
    )

  ggsave(file.path(fig_dir, "fig6_bandwidth.pdf"), p6, width = 7, height = 5)
  ggsave(file.path(fig_dir, "fig6_bandwidth.png"), p6, width = 7, height = 5, dpi = 300)
}

## ---- Figure 7: Placebo Cutoffs ----
cat("Figure 7: Placebo cutoffs...\n")

if (!is.null(robust_results$placebo) && nrow(robust_results$placebo) > 0) {
  plac_dt <- copy(robust_results$placebo)

  # Add the true cutoff result
  rd_main <- rdrobust(union$in_labor_force, union$AGE, c = 62,
                       kernel = "triangular", p = 1)
  plac_dt <- rbind(plac_dt, data.table(
    cutoff = 62L,
    coef = rd_main$coef["Conventional", 1],
    se = rd_main$se["Conventional", 1],
    pvalue = rd_main$pv["Conventional", 1],
    n_left = rd_main$N_h[1],
    n_right = rd_main$N_h[2]
  ), fill = TRUE)

  plac_dt[, ci_lower := coef - 1.96 * se]
  plac_dt[, ci_upper := coef + 1.96 * se]
  plac_dt[, is_true := cutoff == 62]

  p7 <- ggplot(plac_dt, aes(x = factor(cutoff), y = coef, color = is_true)) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "grey60") +
    geom_point(size = 3) +
    geom_errorbar(aes(ymin = ci_lower, ymax = ci_upper), width = 0.3) +
    scale_color_manual(values = c("TRUE" = apep_red, "FALSE" = apep_blue),
                       guide = "none") +
    labs(
      x = "Cutoff Age",
      y = "RD Estimate (LFP)",
      title = "Placebo Cutoff Tests",
      subtitle = "Red = true cutoff (62). Blue = placebo cutoffs (no policy change)."
    )

  ggsave(file.path(fig_dir, "fig7_placebo_cutoffs.pdf"), p7, width = 8, height = 5)
  ggsave(file.path(fig_dir, "fig7_placebo_cutoffs.png"), p7, width = 8, height = 5, dpi = 300)
}

## ---- Figure 8: Subgroup Forest Plot ----
cat("Figure 8: Subgroup forest plot...\n")

sg_file <- file.path(data_dir, "subgroup_results.rds")
if (file.exists(sg_file)) {
  sg <- readRDS(sg_file)

  # Order by category then estimate
  sg[, subgroup := factor(subgroup, levels = rev(sg$subgroup))]

  p8 <- ggplot(sg, aes(x = coef, y = subgroup, color = category)) +
    geom_vline(xintercept = 0, linetype = "dashed", color = "grey60") +
    geom_point(size = 2.5) +
    geom_errorbarh(aes(xmin = ci_lower, xmax = ci_upper), height = 0.3) +
    labs(
      x = "RD Estimate (Labor Force Participation)",
      y = NULL,
      color = "Category",
      title = "Subgroup Heterogeneity: RDD at Age 62",
      subtitle = "Point estimates and 95% CIs by demographic subgroup",
      caption = "Source: IPUMS 1910 Census (us1910l)."
    ) +
    theme(legend.position = "right")

  ggsave(file.path(fig_dir, "fig8_subgroups.pdf"), p8, width = 9, height = 7)
  ggsave(file.path(fig_dir, "fig8_subgroups.png"), p8, width = 9, height = 7, dpi = 300)
}

## ---- Figure 10: Randomization Inference Distribution ----
cat("Figure 10: RI permutation distribution...\n")

ri_file <- file.path(data_dir, "ri_results.rds")
if (file.exists(ri_file)) {
  ri <- readRDS(ri_file)

  if (!is.null(ri$main$perm_distribution)) {
    perm_dt <- data.table(stat = ri$main$perm_distribution)

    p10 <- ggplot(perm_dt, aes(x = stat)) +
      geom_histogram(bins = 50, fill = apep_grey, color = "white", alpha = 0.8) +
      geom_vline(xintercept = ri$main$tau_obs, color = apep_red, linewidth = 1,
                 linetype = "solid") +
      annotate("text", x = ri$main$tau_obs, y = Inf,
               label = sprintf("Observed\n(RI p = %.3f)", ri$main$ri_pvalue_twosided),
               hjust = -0.1, vjust = 1.5, size = 3.5, color = apep_red) +
      labs(
        x = "Permuted Test Statistic (Difference in Means)",
        y = "Count",
        title = "Randomization Inference: Permutation Distribution",
        subtitle = sprintf("Red line = observed statistic. %d permutations.",
                           ri$main$n_perms),
        caption = "Under sharp null of no treatment effect."
      )

    ggsave(file.path(fig_dir, "fig10_ri_distribution.pdf"), p10, width = 7, height = 5)
    ggsave(file.path(fig_dir, "fig10_ri_distribution.png"), p10, width = 7, height = 5, dpi = 300)
  }
}

## ---- Figure 11: Multi-Cutoff Dose-Response ----
cat("Figure 11: Multi-cutoff dose-response...\n")

if (!is.null(robust_results$multi_cutoff) && nrow(robust_results$multi_cutoff) > 0) {
  mc <- robust_results$multi_cutoff

  mc[, ci_lower := coef_did - 1.96 * se_did]
  mc[, ci_upper := coef_did + 1.96 * se_did]
  mc[, pension_increase := c(12, 3, 5)]  # Dollar increase at each cutoff

  p11 <- ggplot(mc, aes(x = pension_increase, y = coef_did)) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "grey60") +
    geom_point(size = 3, color = apep_blue) +
    geom_errorbar(aes(ymin = ci_lower, ymax = ci_upper), width = 0.3, color = apep_blue) +
    geom_text(aes(label = sprintf("Age %d", cutoff)), vjust = -1.5, size = 3) +
    scale_x_continuous(breaks = c(3, 5, 12), labels = dollar_format()) +
    labs(
      x = "Monthly Pension Increase ($)",
      y = "Diff-in-Disc Estimate (LFP)",
      title = "Dose-Response: Pension Income and Labor Supply",
      subtitle = "Larger pension increases at ages 62, 70, and 75"
    )

  ggsave(file.path(fig_dir, "fig11_dose_response.pdf"), p11, width = 7, height = 5)
  ggsave(file.path(fig_dir, "fig11_dose_response.png"), p11, width = 7, height = 5, dpi = 300)
}

cat("\nAll figures saved to", fig_dir, "\n")
