## ============================================================================
## 05_figures.R — All figures for the Civil War pension RDD paper
## Project: The First Retirement Age (apep_0442)
## ============================================================================

source("code/00_packages.R")

union <- readRDS(file.path(data_dir, "union_veterans.rds"))
confed <- readRDS(file.path(data_dir, "confed_veterans.rds"))
robust_results <- readRDS(file.path(data_dir, "robust_results.rds"))

## ---- Figure 1: RDD Plot — Labor Force Participation ----
cat("Figure 1: RDD plot for LFP...\n")

# Compute bin means
bin_means <- union[, .(
  lfp = mean(in_labor_force, na.rm = TRUE),
  n = .N
), by = AGE]

# Fit local polynomial on each side
below <- union[AGE < 62]
above <- union[AGE >= 62]

p1 <- ggplot(bin_means, aes(x = AGE, y = lfp)) +
  geom_vline(xintercept = 62, linetype = "dashed", color = "grey40", linewidth = 0.5) +
  geom_point(aes(size = n), alpha = 0.7, color = "steelblue") +
  geom_smooth(data = bin_means[AGE < 62], method = "loess", span = 0.75,
              se = TRUE, color = "#2c3e50", fill = "#bdc3c7", linewidth = 1) +
  geom_smooth(data = bin_means[AGE >= 62], method = "loess", span = 0.75,
              se = TRUE, color = "#2c3e50", fill = "#bdc3c7", linewidth = 1) +
  scale_x_continuous(breaks = seq(45, 90, 5)) +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1)) +
  scale_size_continuous(guide = "none", range = c(1, 4)) +
  annotate("text", x = 62.5, y = max(bin_means$lfp, na.rm = TRUE) * 0.98,
           label = "Age 62\n(pension eligible)", hjust = 0, size = 3, color = "grey30") +
  labs(
    x = "Age at 1910 Census",
    y = "Labor Force Participation Rate",
    title = "Labor Force Participation of Union Veterans by Age",
    subtitle = "Vertical line: age 62 pension eligibility threshold (1907 Act)",
    caption = "Source: IPUMS 1910 Census 1% sample. Each point = one year of age."
  )

ggsave(file.path(fig_dir, "fig1_rdd_lfp.pdf"), p1, width = 8, height = 5.5)
ggsave(file.path(fig_dir, "fig1_rdd_lfp.png"), p1, width = 8, height = 5.5, dpi = 300)

## ---- Figure 2: McCrary Density Test ----
cat("Figure 2: Density plot...\n")

age_density <- union[, .N, by = AGE]

p2 <- ggplot(age_density, aes(x = AGE, y = N)) +
  geom_vline(xintercept = 62, linetype = "dashed", color = "grey40", linewidth = 0.5) +
  geom_col(fill = "steelblue", alpha = 0.7, width = 0.8) +
  scale_x_continuous(breaks = seq(45, 90, 5)) +
  annotate("text", x = 62.5, y = max(age_density$N) * 0.95,
           label = "Age 62", hjust = 0, size = 3, color = "grey30") +
  labs(
    x = "Age at 1910 Census",
    y = "Number of Union Veterans",
    title = "Age Distribution of Union Veterans",
    subtitle = "McCrary density test: is there bunching at the age 62 cutoff?",
    caption = "Source: IPUMS 1910 Census 1% sample."
  )

ggsave(file.path(fig_dir, "fig2_density.pdf"), p2, width = 8, height = 5)
ggsave(file.path(fig_dir, "fig2_density.png"), p2, width = 8, height = 5, dpi = 300)

## ---- Figure 3: Covariate Balance ----
cat("Figure 3: Covariate balance...\n")

union[, white := as.integer(RACE == 1)]

cov_names <- c("literate", "native_born", "married", "urban", "white")
cov_labels <- c("Literate", "Native Born", "Married", "Urban", "White")

cov_means <- rbindlist(lapply(seq_along(cov_names), function(i) {
  union[, .(
    value = mean(get(cov_names[i]), na.rm = TRUE),
    covariate = cov_labels[i]
  ), by = AGE]
}))

p3 <- ggplot(cov_means, aes(x = AGE, y = value)) +
  geom_vline(xintercept = 62, linetype = "dashed", color = "grey40", linewidth = 0.5) +
  geom_point(alpha = 0.5, size = 1, color = "steelblue") +
  geom_smooth(data = cov_means[AGE < 62], method = "loess", span = 0.75,
              se = TRUE, color = "#2c3e50", fill = "#bdc3c7", linewidth = 0.8) +
  geom_smooth(data = cov_means[AGE >= 62], method = "loess", span = 0.75,
              se = TRUE, color = "#2c3e50", fill = "#bdc3c7", linewidth = 0.8) +
  facet_wrap(~covariate, scales = "free_y", ncol = 3) +
  scale_x_continuous(breaks = seq(50, 85, 10)) +
  labs(
    x = "Age at 1910 Census",
    y = "Proportion",
    title = "Covariate Balance at the Age 62 Threshold",
    subtitle = "Pre-determined characteristics should be smooth through the cutoff",
    caption = "Source: IPUMS 1910 Census 1% sample."
  )

ggsave(file.path(fig_dir, "fig3_balance.pdf"), p3, width = 10, height = 6)
ggsave(file.path(fig_dir, "fig3_balance.png"), p3, width = 10, height = 6, dpi = 300)

## ---- Figure 4: Confederate Placebo ----
cat("Figure 4: Confederate placebo...\n")

if (nrow(confed) >= 20) {
  confed_means <- confed[, .(
    lfp = mean(in_labor_force, na.rm = TRUE),
    n = .N
  ), by = AGE]

  union_means <- union[, .(
    lfp = mean(in_labor_force, na.rm = TRUE),
    n = .N,
    group = "Union Veterans (Federal Pension)"
  ), by = AGE]

  confed_means[, group := "Confederate Veterans (No Federal Pension)"]
  confed_means[, n := n]

  both <- rbind(union_means, confed_means, fill = TRUE)

  p4 <- ggplot(both, aes(x = AGE, y = lfp, color = group)) +
    geom_vline(xintercept = 62, linetype = "dashed", color = "grey40", linewidth = 0.5) +
    geom_point(aes(size = n), alpha = 0.5) +
    geom_smooth(data = both[AGE < 62], method = "loess", span = 0.75,
                se = TRUE, linewidth = 0.8, alpha = 0.15) +
    geom_smooth(data = both[AGE >= 62], method = "loess", span = 0.75,
                se = TRUE, linewidth = 0.8, alpha = 0.15) +
    scale_color_manual(values = c("Confederate Veterans (No Federal Pension)" = "#c0392b",
                                   "Union Veterans (Federal Pension)" = "#2980b9")) +
    scale_size_continuous(guide = "none", range = c(1, 4)) +
    scale_x_continuous(breaks = seq(45, 90, 5)) +
    scale_y_continuous(labels = scales::percent_format(accuracy = 1)) +
    annotate("text", x = 62.5, y = 0.9, label = "Age 62\npension\nthreshold",
             hjust = 0, size = 2.5, color = "grey40") +
    labs(
      x = "Age at 1910 Census",
      y = "Labor Force Participation Rate",
      color = NULL,
      title = "Union vs. Confederate Veterans: Placebo Test",
      subtitle = "Confederate veterans did not receive federal pensions — no discontinuity expected at 62",
      caption = "Source: IPUMS 1910 Census 1% sample."
    )

  ggsave(file.path(fig_dir, "fig4_placebo_confed.pdf"), p4, width = 9, height = 5.5)
  ggsave(file.path(fig_dir, "fig4_placebo_confed.png"), p4, width = 9, height = 5.5, dpi = 300)
} else {
  cat("  Too few Confederate veterans for placebo figure.\n")
}

## ---- Figure 5: Multi-Cutoff RDD ----
cat("Figure 5: Multi-cutoff pension schedule...\n")

# Pension schedule
schedule <- data.table(
  age_min = c(62, 70, 75),
  age_max = c(69, 74, 90),
  pension = c(12, 15, 20)
)

p5a <- ggplot(schedule, aes(xmin = age_min, xmax = age_max + 1, ymin = 0, ymax = pension)) +
  geom_rect(fill = "steelblue", alpha = 0.6, color = "white") +
  geom_text(aes(x = (age_min + age_max) / 2, y = pension / 2,
                label = paste0("$", pension, "/mo")), color = "white", fontface = "bold") +
  scale_x_continuous(breaks = c(62, 70, 75, 90), limits = c(55, 92)) +
  scale_y_continuous(labels = scales::dollar_format()) +
  labs(
    x = "Veteran's Age",
    y = "Monthly Pension",
    title = "Civil War Pension Schedule (1907 Act)",
    subtitle = "Sharp increases at ages 62, 70, and 75"
  )

ggsave(file.path(fig_dir, "fig5_pension_schedule.pdf"), p5a, width = 7, height = 4)
ggsave(file.path(fig_dir, "fig5_pension_schedule.png"), p5a, width = 7, height = 4, dpi = 300)

## ---- Figure 6: Bandwidth Sensitivity Plot ----
cat("Figure 6: Bandwidth sensitivity...\n")

if (!is.null(robust_results$bandwidth) && nrow(robust_results$bandwidth) > 0) {
  bw_dt <- robust_results$bandwidth
  bw_dt[, ci_lo := coef - 1.96 * se]
  bw_dt[, ci_hi := coef + 1.96 * se]

  p6 <- ggplot(bw_dt, aes(x = bandwidth, y = coef)) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "grey60") +
    geom_point(size = 2.5, color = "steelblue") +
    geom_errorbar(aes(ymin = ci_lo, ymax = ci_hi), width = 0.3, color = "steelblue") +
    labs(
      x = "Bandwidth (Years)",
      y = "RD Estimate (LFP)",
      title = "Bandwidth Sensitivity",
      subtitle = "Point estimates and 95% CIs across bandwidth choices"
    )

  ggsave(file.path(fig_dir, "fig6_bandwidth.pdf"), p6, width = 7, height = 5)
  ggsave(file.path(fig_dir, "fig6_bandwidth.png"), p6, width = 7, height = 5, dpi = 300)
}

## ---- Figure 7: Placebo Cutoff Plot ----
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
    pvalue = rd_main$pv["Conventional", 1]
  ))
  plac_dt[, ci_lo := coef - 1.96 * se]
  plac_dt[, ci_hi := coef + 1.96 * se]
  plac_dt[, is_true := cutoff == 62]

  p7 <- ggplot(plac_dt, aes(x = factor(cutoff), y = coef, color = is_true)) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "grey60") +
    geom_point(size = 3) +
    geom_errorbar(aes(ymin = ci_lo, ymax = ci_hi), width = 0.3) +
    scale_color_manual(values = c("TRUE" = "#e74c3c", "FALSE" = "steelblue"),
                       guide = "none") +
    labs(
      x = "Cutoff Age",
      y = "RD Estimate (LFP)",
      title = "Placebo Cutoff Tests",
      subtitle = "Red = true cutoff (62). Blue = placebo cutoffs (no policy change)."
    )

  ggsave(file.path(fig_dir, "fig7_placebo_cutoffs.pdf"), p7, width = 7, height = 5)
  ggsave(file.path(fig_dir, "fig7_placebo_cutoffs.png"), p7, width = 7, height = 5, dpi = 300)
}

## ---- Figure 8: Secondary Outcomes RDD Plots ----
cat("Figure 8: Secondary outcomes...\n")

sec_outcomes <- list(
  "Owns Home" = "owns_home",
  "Household Head" = "is_head",
  "Has Occupation" = "has_occupation"
)

sec_plots <- list()

for (nm in names(sec_outcomes)) {
  var <- sec_outcomes[[nm]]
  y_means <- union[, .(value = mean(get(var), na.rm = TRUE)), by = AGE]

  sec_plots[[nm]] <- ggplot(y_means, aes(x = AGE, y = value)) +
    geom_vline(xintercept = 62, linetype = "dashed", color = "grey40") +
    geom_point(alpha = 0.6, color = "steelblue", size = 1.5) +
    geom_smooth(data = y_means[AGE < 62], method = "loess", span = 0.75,
                se = TRUE, color = "#2c3e50", fill = "#bdc3c7", linewidth = 0.8) +
    geom_smooth(data = y_means[AGE >= 62], method = "loess", span = 0.75,
                se = TRUE, color = "#2c3e50", fill = "#bdc3c7", linewidth = 0.8) +
    scale_x_continuous(breaks = seq(50, 85, 10)) +
    labs(x = "Age", y = nm, title = nm)
}

if (length(sec_plots) > 0) {
  library(patchwork)
  p8 <- wrap_plots(sec_plots, ncol = 3) +
    plot_annotation(
      title = "Secondary Outcomes at the Age 62 Threshold",
      subtitle = "Vertical line: pension eligibility cutoff",
      caption = "Source: IPUMS 1910 Census 1% sample."
    )
  ggsave(file.path(fig_dir, "fig8_secondary.pdf"), p8, width = 12, height = 4.5)
  ggsave(file.path(fig_dir, "fig8_secondary.png"), p8, width = 12, height = 4.5, dpi = 300)
}

cat("\nAll figures saved to", fig_dir, "\n")
