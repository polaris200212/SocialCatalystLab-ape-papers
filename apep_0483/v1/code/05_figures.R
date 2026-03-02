###############################################################################
# 05_figures.R — Generate all figures
# apep_0483: Teacher Pay Austerity and Student Achievement in England
###############################################################################

source("00_packages.R")

data_dir <- "../data/"
fig_dir <- "../figures/"
dir.create(fig_dir, showWarnings = FALSE, recursive = TRUE)

panel <- fread(paste0(data_dir, "analysis_panel.csv"))
la_avg <- fread(paste0(data_dir, "la_analysis_sample.csv"))
aipw_data <- fread(paste0(data_dir, "aipw_sample.csv"))
treat_df <- fread(paste0(data_dir, "treatment_assignment.csv"))
stpcd <- fread(paste0(data_dir, "stpcd_pay_scales.csv"))
robustness <- readRDS(paste0(data_dir, "robustness_results.rds"))
main_results <- readRDS(paste0(data_dir, "main_results.rds"))

# Color palette
col_treated <- "#c0392b"
col_control <- "#2980b9"
col_accent <- "#27ae60"

###############################################################################
# Figure 1: Teacher pay competitiveness over time
###############################################################################

cat("Figure 1: Competitiveness trends...\n")

fig1_data <- panel[!is.na(treated), .(
  mean_comp = mean(comp_ratio, na.rm = TRUE),
  se_comp = sd(comp_ratio, na.rm = TRUE) / sqrt(.N),
  n = .N
), by = .(year, treated)]

fig1_data[, group := fifelse(treated == 1, "High shock (treated)", "Low shock (control)")]

p1 <- ggplot(fig1_data, aes(x = year, y = mean_comp, color = group, fill = group)) +
  geom_ribbon(aes(ymin = mean_comp - 1.96 * se_comp,
                  ymax = mean_comp + 1.96 * se_comp),
              alpha = 0.15, color = NA) +
  geom_line(linewidth = 1) +
  geom_point(size = 2) +
  geom_vline(xintercept = 2010.5, linetype = "dashed", color = "grey40") +
  annotate("text", x = 2010.8, y = max(fig1_data$mean_comp) + 0.01,
           label = "Pay freeze\nbegins (2010)",
           hjust = 0, size = 3, color = "grey40") +
  scale_color_manual(values = c("High shock (treated)" = col_treated,
                                "Low shock (control)" = col_control)) +
  scale_fill_manual(values = c("High shock (treated)" = col_treated,
                               "Low shock (control)" = col_control)) +
  labs(x = "Year", y = "Teacher-to-private pay ratio",
       title = "Teacher Pay Competitiveness by Treatment Group",
       subtitle = "Ratio of STPCD midpoint salary to local median private-sector pay (ASHE)",
       color = NULL, fill = NULL) +
  theme_apep() +
  theme(legend.position = "bottom")

ggsave(paste0(fig_dir, "fig1_competitiveness_trends.pdf"), p1,
       width = 8, height = 5.5)

###############################################################################
# Figure 2: National teacher pay vs private-sector pay
###############################################################################

cat("Figure 2: National pay trends...\n")

national_private <- panel[, .(median_private = mean(median_annual_pay, na.rm = TRUE)),
                          by = year]
pay_trends <- merge(stpcd[, .(year, teacher_pay_mid, m1_rest)],
                    national_private, by = "year")

pay_long <- melt(pay_trends, id.vars = "year",
                 measure.vars = c("teacher_pay_mid", "median_private"),
                 variable.name = "series", value.name = "pay")
pay_long[, series_label := fifelse(series == "teacher_pay_mid",
                                   "Teacher (STPCD midpoint)",
                                   "Private sector (ASHE median)")]

p2 <- ggplot(pay_long, aes(x = year, y = pay / 1000, color = series_label)) +
  geom_line(linewidth = 1) +
  geom_point(size = 2) +
  geom_vline(xintercept = 2010.5, linetype = "dashed", color = "grey40") +
  annotate("rect", xmin = 2010.5, xmax = 2019.5, ymin = -Inf, ymax = Inf,
           fill = "grey80", alpha = 0.2) +
  annotate("text", x = 2015, y = max(pay_long$pay / 1000) * 0.98,
           label = "Austerity period", size = 3.5, color = "grey40") +
  scale_color_manual(values = c("Teacher (STPCD midpoint)" = col_treated,
                                "Private sector (ASHE median)" = col_control)) +
  scale_y_continuous(labels = function(x) paste0("£", x, "k")) +
  labs(x = "Year", y = "Annual pay (£ thousands)",
       title = "Teacher vs. Private-Sector Pay in England",
       subtitle = "STPCD midpoint salary and ASHE median annual gross pay, 2005-2023",
       color = NULL) +
  theme_apep() +
  theme(legend.position = "bottom")

ggsave(paste0(fig_dir, "fig2_pay_trends.pdf"), p2,
       width = 8, height = 5.5)

###############################################################################
# Figure 3: Propensity score distribution (overlap)
###############################################################################

cat("Figure 3: Propensity score overlap...\n")

ps_plot_data <- aipw_data[, .(ps_hat, treated)]
ps_plot_data[, group := fifelse(treated == 1, "Treated", "Control")]

p3 <- ggplot(ps_plot_data, aes(x = ps_hat, fill = group)) +
  geom_histogram(aes(y = after_stat(density)), bins = 25,
                 alpha = 0.6, position = "identity") +
  geom_vline(xintercept = c(0.05, 0.95), linetype = "dashed",
             color = "grey50") +
  annotate("text", x = 0.07, y = Inf, label = "Trim", vjust = 1.5,
           size = 3, color = "grey50") +
  scale_fill_manual(values = c("Treated" = col_treated,
                               "Control" = col_control)) +
  labs(x = "Propensity score (logistic)", y = "Density",
       title = "Propensity Score Overlap",
       subtitle = "Distribution of estimated treatment probability by group",
       fill = NULL) +
  theme_apep() +
  theme(legend.position = "bottom")

ggsave(paste0(fig_dir, "fig3_ps_overlap.pdf"), p3,
       width = 7, height = 5)

###############################################################################
# Figure 4: Treatment assignment — competitiveness change distribution
###############################################################################

cat("Figure 4: Treatment assignment...\n")

q25 <- quantile(treat_df$comp_change, 0.25, na.rm = TRUE)

p4 <- ggplot(treat_df, aes(x = comp_change, fill = factor(treated))) +
  geom_histogram(bins = 30, alpha = 0.7, color = "white") +
  geom_vline(xintercept = q25, linetype = "dashed", linewidth = 0.8) +
  annotate("text", x = q25 - 0.005, y = Inf,
           label = paste0("Q25 = ", round(q25, 4)),
           vjust = 1.5, hjust = 1, size = 3.5) +
  scale_fill_manual(values = c("0" = col_control, "1" = col_treated),
                    labels = c("0" = "Control (small decline)",
                               "1" = "Treated (large decline)")) +
  labs(x = "Change in competitiveness ratio (2010-2019)",
       y = "Number of LAs",
       title = "Distribution of Teacher Pay Competitiveness Change",
       subtitle = "Treatment defined as bottom quartile of competitiveness decline",
       fill = NULL) +
  theme_apep() +
  theme(legend.position = "bottom")

ggsave(paste0(fig_dir, "fig4_treatment_assignment.pdf"), p4,
       width = 7, height = 5)

###############################################################################
# Figure 5: Dose-response scatter
###############################################################################

cat("Figure 5: Dose-response...\n")

p5 <- ggplot(la_avg[!is.na(comp_change) & !is.na(att8_mean)],
             aes(x = comp_change, y = att8_mean)) +
  geom_point(aes(color = factor(treated)), alpha = 0.6, size = 2.5) +
  geom_smooth(method = "lm", se = TRUE, color = "grey30",
              linetype = "dashed", linewidth = 0.8) +
  scale_color_manual(values = c("0" = col_control, "1" = col_treated),
                     labels = c("0" = "Control", "1" = "Treated")) +
  labs(x = "Competitiveness change (2010-2019)",
       y = "Mean Attainment 8 score (post-2021)",
       title = "Teacher Pay Competitiveness and Student Achievement",
       subtitle = "Each point is a local authority; line is OLS fit",
       color = NULL) +
  theme_apep() +
  theme(legend.position = "bottom")

ggsave(paste0(fig_dir, "fig5_dose_response.pdf"), p5,
       width = 7, height = 5.5)

###############################################################################
# Figure 6: Year-by-year treatment effects
###############################################################################

cat("Figure 6: Year-by-year effects...\n")

yr_res <- robustness$year_results

p6 <- ggplot(yr_res, aes(x = year, y = coef)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey60") +
  geom_errorbar(aes(ymin = coef - 1.96 * se, ymax = coef + 1.96 * se),
                width = 0.2, color = col_treated, linewidth = 0.8) +
  geom_point(size = 3, color = col_treated) +
  annotate("rect", xmin = 2020.5, xmax = 2024.5, ymin = -Inf, ymax = Inf,
           fill = "grey90", alpha = 0.3) +
  annotate("text", x = 2022.5, y = max(yr_res$coef + 1.96 * yr_res$se) + 0.3,
           label = "Post-austerity outcomes", size = 3, color = "grey40") +
  labs(x = "Year", y = "Treatment effect on Attainment 8",
       title = "Treatment Effect by Year",
       subtitle = "OLS coefficient on treated indicator with 95% CIs") +
  theme_apep()

ggsave(paste0(fig_dir, "fig6_yearly_effects.pdf"), p6,
       width = 7, height = 5)

###############################################################################
# Figure 7: Permutation inference
###############################################################################

cat("Figure 7: Permutation inference...\n")

perm_df <- data.table(coef = robustness$perm_coefs)

p7 <- ggplot(perm_df, aes(x = coef)) +
  geom_histogram(bins = 40, fill = "grey70", color = "white", alpha = 0.8) +
  geom_vline(xintercept = robustness$obs_coef, color = col_treated,
             linewidth = 1, linetype = "solid") +
  geom_vline(xintercept = -robustness$obs_coef, color = col_treated,
             linewidth = 1, linetype = "dashed") +
  annotate("text", x = robustness$obs_coef, y = Inf,
           label = paste0("Observed = ", round(robustness$obs_coef, 2)),
           vjust = 1.5, hjust = -0.1, size = 3.5, color = col_treated) +
  labs(x = "Permuted treatment coefficients",
       y = "Count",
       title = "Randomization Inference",
       subtitle = paste0("Distribution of 1,000 permuted coefficients; ",
                         "RI p-value = ", round(robustness$ri_pvalue, 3))) +
  theme_apep()

ggsave(paste0(fig_dir, "fig7_permutation_inference.pdf"), p7,
       width = 7, height = 5)

###############################################################################
# Figure 8: Sensemakr contour plot
###############################################################################

cat("Figure 8: Sensitivity analysis...\n")

pdf(paste0(fig_dir, "fig8_sensitivity_contour.pdf"), width = 7, height = 5.5)
plot(robustness$sensemakr, sensitivity.of = "estimate",
     main = "Sensitivity of Competitiveness Effect to Unobserved Confounders")
dev.off()

###############################################################################
# Figure 9: Competitiveness trends — STPCD components
###############################################################################

cat("Figure 9: STPCD components...\n")

stpcd_long <- melt(stpcd, id.vars = "year",
                   measure.vars = c("m1_rest", "m6_rest", "teacher_pay_mid"),
                   variable.name = "scale", value.name = "pay")
stpcd_long[, scale_label := fcase(
  scale == "m1_rest", "M1 (starting salary)",
  scale == "m6_rest", "M6 (top of main scale)",
  scale == "teacher_pay_mid", "Midpoint (used in analysis)"
)]

p9 <- ggplot(stpcd_long, aes(x = year, y = pay / 1000, color = scale_label)) +
  geom_line(linewidth = 1) +
  geom_point(size = 1.5) +
  geom_vline(xintercept = 2010.5, linetype = "dashed", color = "grey40") +
  annotate("rect", xmin = 2010.5, xmax = 2019.5, ymin = -Inf, ymax = Inf,
           fill = "grey80", alpha = 0.15) +
  scale_y_continuous(labels = function(x) paste0("£", x, "k")) +
  scale_color_manual(values = c("M1 (starting salary)" = col_accent,
                                "M6 (top of main scale)" = col_control,
                                "Midpoint (used in analysis)" = col_treated)) +
  labs(x = "Year", y = "Annual salary (£ thousands)",
       title = "Teacher Pay Scales (STPCD), Rest of England",
       subtitle = "Main pay range points, 2005-2023",
       color = NULL) +
  theme_apep() +
  theme(legend.position = "bottom")

ggsave(paste0(fig_dir, "fig9_stpcd_components.pdf"), p9,
       width = 8, height = 5.5)

cat("\n=== ALL FIGURES SAVED ===\n")
cat(paste0("Output: ", normalizePath(fig_dir), "\n"))
list.files(fig_dir, pattern = "\\.pdf$")
