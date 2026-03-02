## 05_figures.R — All figure generation
## APEP-0458: Second Home Caps and Local Labor Markets

source("code/00_packages.R")

cat("\n=== GENERATING FIGURES ===\n")

rdd <- fread("data/rdd_cross_section.csv")
rdd[is.infinite(emp_growth_post), emp_growth_post := NA]
rdd[is.infinite(share_tertiary_post), share_tertiary_post := NA]
rdd <- rdd[!is.na(emp_total_pre) & emp_total_pre > 0]

# ---------------------------------------------------------------------------
# Figure 1: McCrary Density Test
# ---------------------------------------------------------------------------
cat("Figure 1: McCrary density...\n")

density_test <- rddensity(rdd$running, c = 0)

pdf("figures/fig1_mccrary.pdf", width = 7, height = 5)
rdplotdensity(density_test, rdd$running,
              plotN = 25,
              title = "",
              xlabel = "Second-Home Share Minus 20% Threshold",
              ylabel = "Density")
dev.off()
cat("  Saved fig1_mccrary.pdf\n")

# ---------------------------------------------------------------------------
# Figure 2: RDD Plot — Employment Growth
# ---------------------------------------------------------------------------
cat("Figure 2: RDD plot — employment growth...\n")

valid <- !is.na(rdd$emp_growth_post) & !is.na(rdd$running)

pdf("figures/fig2_rdd_emp_growth.pdf", width = 8, height = 6)
rdplot(rdd$emp_growth_post[valid], rdd$running[valid], c = 0,
       nbins = c(20, 20),
       title = "",
       x.label = "Second-Home Share Relative to 20% Threshold (pp)",
       y.label = "Employment Growth (2014-2023 vs. 2011-2012)")
dev.off()
cat("  Saved fig2_rdd_emp_growth.pdf\n")

# ---------------------------------------------------------------------------
# Figure 3: RDD Plot — Log Employment
# ---------------------------------------------------------------------------
cat("Figure 3: RDD plot — log employment...\n")

valid2 <- !is.na(rdd$log_emp_total_post) & !is.na(rdd$running)

pdf("figures/fig3_rdd_log_emp.pdf", width = 8, height = 6)
rdplot(rdd$log_emp_total_post[valid2], rdd$running[valid2], c = 0,
       nbins = c(20, 20),
       title = "",
       x.label = "Second-Home Share Relative to 20% Threshold (pp)",
       y.label = "Log Total Employment (Post-Treatment Average)")
dev.off()
cat("  Saved fig3_rdd_log_emp.pdf\n")

# ---------------------------------------------------------------------------
# Figure 4: Event Study by Year
# ---------------------------------------------------------------------------
cat("Figure 4: Event study...\n")

event <- fread("data/event_study_rdd.csv")

p_event <- ggplot(event, aes(x = year, y = estimate)) +
  geom_ribbon(aes(ymin = ci_lower, ymax = ci_upper),
              alpha = 0.15, fill = apep_colors[1]) +
  geom_point(color = apep_colors[1], size = 2.5) +
  geom_line(color = apep_colors[1], linewidth = 0.6) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
  geom_vline(xintercept = 2012.5, linetype = "dotted", color = "grey60",
             linewidth = 0.8) +
  annotate("text", x = 2012.7, y = max(event$ci_upper, na.rm = TRUE) * 0.8,
           label = "Initiative\n(March 2012)", hjust = 0, size = 3,
           color = "grey40") +
  scale_x_continuous(breaks = 2011:2023) +
  labs(x = "Year",
       y = "RDD Estimate (Log Employment at 20% Threshold)",
       title = "") +
  theme_apep() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

ggsave("figures/fig4_event_study.pdf", p_event, width = 9, height = 5.5)
cat("  Saved fig4_event_study.pdf\n")

# ---------------------------------------------------------------------------
# Figure 5: Bandwidth Sensitivity
# ---------------------------------------------------------------------------
cat("Figure 5: Bandwidth sensitivity...\n")

bw <- fread("data/robustness_bandwidth.csv")

p_bw <- ggplot(bw, aes(x = bandwidth, y = estimate)) +
  geom_ribbon(aes(ymin = ci_lower, ymax = ci_upper),
              alpha = 0.15, fill = apep_colors[1]) +
  geom_point(color = apep_colors[1], size = 3) +
  geom_line(color = apep_colors[1], linewidth = 0.6) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
  labs(x = "Bandwidth (percentage points)",
       y = "RDD Estimate (Employment Growth)") +
  theme_apep()

ggsave("figures/fig5_bandwidth.pdf", p_bw, width = 7, height = 5)
cat("  Saved fig5_bandwidth.pdf\n")

# ---------------------------------------------------------------------------
# Figure 6: Placebo Thresholds
# ---------------------------------------------------------------------------
cat("Figure 6: Placebo thresholds...\n")

placebo <- fread("data/robustness_placebo.csv")
# Add the real threshold result
main_result <- fread("data/rdd_main_results.csv")[outcome == "emp_growth_post"]
placebo_all <- rbind(
  placebo[, .(threshold, estimate, se_robust, pv_robust)],
  data.table(threshold = 20, estimate = main_result$estimate,
             se_robust = main_result$se_robust, pv_robust = main_result$pv_robust)
)
placebo_all[, ci_lower := estimate - 1.96 * se_robust]
placebo_all[, ci_upper := estimate + 1.96 * se_robust]
placebo_all[, is_real := threshold == 20]

p_placebo <- ggplot(placebo_all, aes(x = threshold, y = estimate, color = is_real)) +
  geom_pointrange(aes(ymin = ci_lower, ymax = ci_upper), size = 0.8) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
  scale_color_manual(values = c("FALSE" = "grey50", "TRUE" = apep_colors[1]),
                     labels = c("Placebo", "Actual (20%)"),
                     name = "") +
  labs(x = "Threshold (% Second-Home Share)",
       y = "RDD Estimate (Employment Growth)") +
  theme_apep()

ggsave("figures/fig6_placebo.pdf", p_placebo, width = 7, height = 5)
cat("  Saved fig6_placebo.pdf\n")

# ---------------------------------------------------------------------------
# Figure 7: Distribution of Running Variable
# ---------------------------------------------------------------------------
cat("Figure 7: Histogram of second-home shares...\n")

p_hist <- ggplot(rdd, aes(x = zwa_pct)) +
  geom_histogram(binwidth = 2, fill = "grey70", color = "white") +
  geom_vline(xintercept = 20, color = apep_colors[1], linewidth = 1,
             linetype = "solid") +
  annotate("text", x = 21, y = Inf, vjust = 1.5, hjust = 0,
           label = "20% Threshold", color = apep_colors[1], size = 3.5,
           fontface = "bold") +
  labs(x = "Second-Home Share (%)",
       y = "Number of Municipalities") +
  theme_apep()

ggsave("figures/fig7_histogram.pdf", p_hist, width = 7, height = 5)
cat("  Saved fig7_histogram.pdf\n")

# ---------------------------------------------------------------------------
# Figure 8: Covariate Balance
# ---------------------------------------------------------------------------
cat("Figure 8: Covariate balance...\n")

balance <- fread("data/covariate_balance.csv")
balance[, ci_lower := estimate - 1.96 * se_robust]
balance[, ci_upper := estimate + 1.96 * se_robust]

# Normalize estimates for visual comparison
balance[, est_normalized := estimate / abs(estimate[which.max(abs(estimate))])]

p_balance <- ggplot(balance, aes(x = reorder(covariate, estimate), y = estimate)) +
  geom_pointrange(aes(ymin = ci_lower, ymax = ci_upper),
                  color = apep_colors[1], size = 0.7) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
  coord_flip() +
  labs(x = "", y = "RDD Estimate (Discontinuity at 20%)") +
  theme_apep()

ggsave("figures/fig8_balance.pdf", p_balance, width = 8, height = 4)
cat("  Saved fig8_balance.pdf\n")

cat("\n=== FIGURES DONE ===\n")
