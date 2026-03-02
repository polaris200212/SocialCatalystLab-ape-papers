# ============================================================================
# APEP-0055 v3: Coverage Cliffs — Age 26 RDD on Birth Insurance Coverage
# 08_placebo_figure.R - Placebo cutoff visualization
# ============================================================================

source("00_packages.R")

# Load placebo results (only contains placebo cutoffs: 24, 25, 27, 28)
placebo_table <- readRDS(file.path(data_dir, "placebo_results.rds"))

# Add the real cutoff result from main analysis
main_results <- readRDS(file.path(data_dir, "main_results.rds"))
real_result <- data.frame(
  Cutoff = 26,
  RD_Estimate = main_results$rd_medicaid$coef[1],
  Robust_SE = main_results$rd_medicaid$se[3],
  p_value = main_results$rd_medicaid$pv[3],
  Significant = "***"
)

# Combine placebo and real
all_cutoffs <- rbind(placebo_table, real_result)
all_cutoffs$Cutoff <- as.factor(all_cutoffs$Cutoff)
all_cutoffs$IsReal <- all_cutoffs$Cutoff == "26"

# Create CI columns
all_cutoffs$CI_Lower <- all_cutoffs$RD_Estimate - 1.96 * all_cutoffs$Robust_SE
all_cutoffs$CI_Upper <- all_cutoffs$RD_Estimate + 1.96 * all_cutoffs$Robust_SE

pdf(file.path(fig_dir, "figure7_placebo_cutoffs.pdf"), width = 8, height = 5)

ggplot(all_cutoffs, aes(x = Cutoff, y = RD_Estimate, color = IsReal)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
  geom_point(size = 4) +
  geom_errorbar(aes(ymin = CI_Lower, ymax = CI_Upper), width = 0.2, linewidth = 0.8) +
  scale_color_manual(values = c("FALSE" = apep_colors[1], "TRUE" = apep_colors[2]),
                     labels = c("Placebo Cutoff", "Policy Cutoff (Age 26)"),
                     name = "") +
  labs(
    title = "RDD Estimates at Placebo and Policy Cutoffs",
    subtitle = "Medicaid payment discontinuity",
    x = "Cutoff Age",
    y = "RD Estimate",
    caption = "Note: Points show RD estimates; bars show 95% CI.\nOnly age 26 shows a large positive discontinuity. Data: CDC Natality 2016-2023."
  ) +
  theme_apep() +
  theme(legend.position = "bottom")

dev.off()
cat("Placebo figure saved.\n")
