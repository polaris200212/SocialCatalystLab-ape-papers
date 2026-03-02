###############################################################################
# 06_figures.R — Generate all figures
# apep_0483 v2: Teacher Pay Competitiveness and Student Value-Added
###############################################################################

source("00_packages.R")

data_dir <- "../data/"
fig_dir <- "../figures/"
dir.create(fig_dir, showWarnings = FALSE, recursive = TRUE)

panel <- fread(paste0(data_dir, "analysis_panel.csv"))

###############################################################################
# Figure 1: Competitiveness Trends by Region/Band
###############################################################################

cat("Figure 1: Competitiveness trends...\n")

comp <- fread(paste0(data_dir, "competitiveness_by_la.csv"))

fig1_data <- comp[, .(mean_comp = mean(comp_ratio, na.rm = TRUE),
                       median_comp = median(comp_ratio, na.rm = TRUE)),
                  by = .(year, band)]

p1 <- ggplot(fig1_data, aes(x = year, y = mean_comp, color = band)) +
  geom_line(linewidth = 1) +
  geom_point(size = 2) +
  geom_hline(yintercept = 1, linetype = "dashed", color = "grey50") +
  scale_color_brewer(palette = "Set1",
                     labels = c("Fringe", "Inner London", "Outer London",
                                "Rest of England")) +
  labs(
    title = "Teacher Pay Competitiveness by STPCD Band",
    subtitle = "Ratio of STPCD midpoint salary to local median private-sector pay",
    x = "Year",
    y = "Competitiveness Ratio",
    color = "STPCD Band"
  ) +
  annotate("rect", xmin = 2010, xmax = 2019, ymin = -Inf, ymax = Inf,
           alpha = 0.1, fill = "red") +
  annotate("text", x = 2014.5, y = max(fig1_data$mean_comp, na.rm = TRUE) * 0.95,
           label = "Austerity Pay Freeze", size = 3, color = "red")

ggsave(paste0(fig_dir, "fig1_competitiveness_trends.pdf"), p1,
       width = 8, height = 5)

###############################################################################
# Figure 2: Pre-Trends — Progress 8 by Competitiveness Tercile
###############################################################################

cat("Figure 2: Pre-trends...\n")

if ("comp_tercile" %in% names(panel)) {
  fig2_data <- panel[!is.na(comp_tercile) & !is.na(progress8),
                     .(mean_p8 = mean(progress8, na.rm = TRUE),
                       se_p8 = sd(progress8, na.rm = TRUE) / sqrt(.N)),
                     by = .(year, comp_tercile)]

  p2 <- ggplot(fig2_data, aes(x = year, y = mean_p8, color = comp_tercile)) +
    geom_line(linewidth = 0.8) +
    geom_point(size = 2) +
    geom_errorbar(aes(ymin = mean_p8 - 1.96 * se_p8,
                      ymax = mean_p8 + 1.96 * se_p8),
                  width = 0.2) +
    geom_vline(xintercept = 2019.5, linetype = "dashed", color = "grey40") +
    annotate("text", x = 2019.5, y = max(fig2_data$mean_p8, na.rm = TRUE),
             label = "COVID gap", hjust = -0.1, size = 3) +
    scale_color_manual(values = c("Low" = "#e41a1c", "Medium" = "#377eb8",
                                  "High" = "#4daf4a")) +
    labs(
      title = "Progress 8 Trends by Teacher Pay Competitiveness",
      subtitle = "School-level means by LA competitiveness tercile",
      x = "Academic Year (starting)",
      y = "Mean Progress 8 Score",
      color = "Competitiveness\nTercile"
    )

  ggsave(paste0(fig_dir, "fig2_pretrends.pdf"), p2, width = 8, height = 5)
}

###############################################################################
# Figure 3: Event Study Coefficients
###############################################################################

cat("Figure 3: Event study...\n")

event_file <- paste0(data_dir, "event_study_coefs.csv")
if (file.exists(event_file)) {
  event_coefs <- fread(event_file)

  p3 <- ggplot(event_coefs, aes(x = year, y = coef)) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
    geom_vline(xintercept = 2019.5, linetype = "dotted", color = "grey40") +
    geom_ribbon(aes(ymin = ci_lo, ymax = ci_hi), alpha = 0.2, fill = "steelblue") +
    geom_line(color = "steelblue", linewidth = 0.8) +
    geom_point(color = "steelblue", size = 3) +
    labs(
      title = "Event Study: Baseline Competitiveness × Year",
      subtitle = "School FE + Year FE, LA-clustered SEs. Reference: last pre-COVID year.",
      x = "Academic Year",
      y = "Coefficient on Baseline Competitiveness × Year",
      caption = "Shaded area: 95% confidence interval"
    )

  ggsave(paste0(fig_dir, "fig3_event_study.pdf"), p3, width = 8, height = 5)
}

###############################################################################
# Figure 4: Academy DDD Coefficients
###############################################################################

cat("Figure 4: Academy DDD...\n")

ddd_file <- paste0(data_dir, "ddd_results.rds")
if (file.exists(ddd_file)) {
  ddd <- readRDS(ddd_file)

  # Extract maintained vs academy coefficients
  ddd_coefs <- data.table(
    school_type = c("Maintained\n(STPCD-bound)", "Academy\n(Pay freedom)"),
    beta = c(coef(ddd$ddd)["comp_ratio:maintained"],
             coef(ddd$ddd)["comp_ratio:academy"]),
    se = c(se(ddd$ddd)["comp_ratio:maintained"],
           se(ddd$ddd)["comp_ratio:academy"])
  )
  ddd_coefs[, ci_lo := beta - 1.96 * se]
  ddd_coefs[, ci_hi := beta + 1.96 * se]

  p4 <- ggplot(ddd_coefs, aes(x = school_type, y = beta)) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
    geom_point(size = 4, color = "steelblue") +
    geom_errorbar(aes(ymin = ci_lo, ymax = ci_hi), width = 0.15,
                  color = "steelblue", linewidth = 0.8) +
    labs(
      title = "Academy Triple-Difference",
      subtitle = "Effect of competitiveness on Progress 8 by school type",
      x = "",
      y = "Coefficient on Competitiveness Ratio",
      caption = "If STPCD binds: maintained > academy. Bars: 95% CI."
    )

  ggsave(paste0(fig_dir, "fig4_academy_ddd.pdf"), p4, width = 6, height = 5)
}

###############################################################################
# Figure 5: Randomization Inference Distribution
###############################################################################

cat("Figure 5: Randomization inference...\n")

ri_file <- paste0(data_dir, "ri_permutations.csv")
ri_res_file <- paste0(data_dir, "ri_results.csv")
if (file.exists(ri_file) && file.exists(ri_res_file)) {
  perm_dist <- fread(ri_file)
  ri_res <- fread(ri_res_file)

  p5 <- ggplot(perm_dist, aes(x = perm_beta)) +
    geom_histogram(bins = 50, fill = "grey70", color = "grey40") +
    geom_vline(xintercept = ri_res$beta_actual, color = "red",
               linewidth = 1, linetype = "solid") +
    labs(
      title = "Randomization Inference",
      subtitle = sprintf("Actual coefficient (red line) vs. %d permutations. RI p = %.3f",
                          ri_res$n_perms, ri_res$ri_pvalue),
      x = "Permuted Coefficient",
      y = "Count"
    )

  ggsave(paste0(fig_dir, "fig5_randomization_inference.pdf"), p5,
         width = 7, height = 5)
}

###############################################################################
# Figure 6: Leave-One-Region-Out
###############################################################################

cat("Figure 6: Leave-one-region-out...\n")

loor_file <- paste0(data_dir, "leave_one_region_out.csv")
if (file.exists(loor_file)) {
  loor <- fread(loor_file)

  # Add the full-sample estimate
  main_res <- readRDS(paste0(data_dir, "main_results.rds"))
  full_est <- data.table(
    excluded_region = "None (full sample)",
    beta = coef(main_res$main)["comp_ratio"],
    se = se(main_res$main)["comp_ratio"]
  )
  loor_plot <- rbind(loor[, .(excluded_region, beta, se)], full_est, fill = TRUE)
  loor_plot[, ci_lo := beta - 1.96 * se]
  loor_plot[, ci_hi := beta + 1.96 * se]

  p6 <- ggplot(loor_plot, aes(x = reorder(excluded_region, beta), y = beta)) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
    geom_point(size = 3, color = "steelblue") +
    geom_errorbar(aes(ymin = ci_lo, ymax = ci_hi), width = 0.2,
                  color = "steelblue") +
    coord_flip() +
    labs(
      title = "Robustness: Leave-One-Region-Out",
      subtitle = "Main coefficient re-estimated excluding each region",
      x = "Excluded Region",
      y = "Coefficient on Competitiveness Ratio"
    )

  ggsave(paste0(fig_dir, "fig6_leave_one_region_out.pdf"), p6,
         width = 7, height = 5)
}

###############################################################################
# Figure 7: Competitiveness Ratio Distribution
###############################################################################

cat("Figure 7: Competitiveness distribution...\n")

if ("comp_ratio" %in% names(panel)) {
  p7 <- ggplot(panel[!is.na(comp_ratio)],
               aes(x = comp_ratio, fill = factor(year))) +
    geom_density(alpha = 0.3) +
    geom_vline(xintercept = 1, linetype = "dashed") +
    scale_fill_viridis_d() +
    labs(
      title = "Distribution of Teacher Pay Competitiveness",
      subtitle = "Across schools, by academic year",
      x = "Competitiveness Ratio (teacher pay / private median)",
      y = "Density",
      fill = "Year"
    )

  ggsave(paste0(fig_dir, "fig7_comp_distribution.pdf"), p7,
         width = 8, height = 5)
}

###############################################################################
# Figure 8: STPCD Pay Scale Components
###############################################################################

cat("Figure 8: STPCD components...\n")

stpcd <- fread(paste0(data_dir, "stpcd_pay_scales.csv"))

stpcd_long <- melt(stpcd, id.vars = c("year", "band"),
                   measure.vars = c("m1", "m6", "teacher_pay_mid"),
                   variable.name = "scale_point", value.name = "salary")

p8 <- ggplot(stpcd_long[scale_point == "teacher_pay_mid"],
             aes(x = year, y = salary / 1000, color = band)) +
  geom_line(linewidth = 0.8) +
  geom_point(size = 1.5) +
  annotate("rect", xmin = 2010, xmax = 2016, ymin = -Inf, ymax = Inf,
           alpha = 0.1, fill = "red") +
  annotate("text", x = 2013, y = 22, label = "Freeze/1% cap",
           size = 2.5, color = "red") +
  scale_color_brewer(palette = "Set1",
                     labels = c("Fringe", "Inner London", "Outer London",
                                "Rest of England")) +
  labs(
    title = "STPCD Teacher Pay by Band",
    subtitle = "Midpoint of main pay scale (M1-M6 average)",
    x = "Year", y = "Salary (£ thousands)",
    color = "Pay Band"
  )

ggsave(paste0(fig_dir, "fig8_stpcd_components.pdf"), p8, width = 8, height = 5)

cat("\n=== ALL FIGURES GENERATED ===\n")
cat(sprintf("Figures saved in: %s\n", fig_dir))
for (f in sort(list.files(fig_dir, pattern = "\\.pdf$"))) {
  cat(sprintf("  %s\n", f))
}
