## ============================================================
## 05_figures.R — All figures for the paper (v2: expanded)
## ============================================================

source("00_packages.R")

df <- readRDS("../data/analysis_data.rds")
results_v2 <- readRDS("../data/rd_results_v2.rds")
results <- results_v2$labor
rd_first <- readRDS("../data/rd_first_stage.rds")
density_test <- readRDS("../data/density_test.rds")
bw_results <- readRDS("../data/bw_sensitivity.rds")
placebo_results <- readRDS("../data/placebo_results.rds")
mde_results <- readRDS("../data/mde_results.rds")

fig_dir <- "../figures"
dir.create(fig_dir, showWarnings = FALSE)

bw_plot <- 500

## ----------------------------------------------------------
## Helper: Binned scatter RDD plot
## ----------------------------------------------------------

make_rdd_plot <- function(data, yvar, ylabel, title, subtitle,
                           bin_width = 25, bw = 500, cutoff = 0) {
  plot_data <- data %>%
    filter(abs(pop_centered) <= bw) %>%
    mutate(bin = cut(pop_centered,
                     breaks = seq(-bw, bw, by = bin_width),
                     include.lowest = TRUE)) %>%
    group_by(bin) %>%
    summarise(
      pop_mid = mean(pop_centered),
      y = mean(.data[[yvar]], na.rm = TRUE),
      n = n(),
      .groups = "drop"
    )

  ggplot() +
    geom_point(data = plot_data, aes(x = pop_mid, y = y),
               color = "grey50", size = 2, alpha = 0.7) +
    geom_smooth(data = data %>% filter(pop_centered >= -bw & pop_centered < cutoff),
                aes(x = pop_centered, y = .data[[yvar]]),
                method = "lm", formula = y ~ x,
                color = apep_colors[1], fill = apep_colors[1],
                alpha = 0.2, linewidth = 1) +
    geom_smooth(data = data %>% filter(pop_centered >= cutoff & pop_centered <= bw),
                aes(x = pop_centered, y = .data[[yvar]]),
                method = "lm", formula = y ~ x,
                color = apep_colors[2], fill = apep_colors[2],
                alpha = 0.2, linewidth = 1) +
    geom_vline(xintercept = cutoff, linetype = "dashed", color = "grey30",
               linewidth = 0.7) +
    labs(title = title, subtitle = subtitle,
         x = "Population Relative to Threshold",
         y = ylabel) +
    theme_apep()
}

## ===========================================================
## Figure 1: First Stage — Female Councillor Share
## ===========================================================

cat("Creating Figure 1: First Stage RDD...\n")

plot_data1 <- df %>%
  filter(abs(pop_centered) <= bw_plot) %>%
  mutate(bin = cut(pop_centered,
                   breaks = seq(-bw_plot, bw_plot, by = 20),
                   include.lowest = TRUE)) %>%
  group_by(bin) %>%
  summarise(
    pop_mid = mean(pop_centered),
    female_share = mean(female_share),
    n = n(), .groups = "drop"
  )

p1 <- ggplot() +
  geom_point(data = plot_data1, aes(x = pop_mid, y = female_share),
             color = "grey50", size = 2, alpha = 0.7) +
  geom_smooth(data = df %>% filter(pop_centered >= -bw_plot & pop_centered < 0),
              aes(x = pop_centered, y = female_share),
              method = "lm", formula = y ~ x,
              color = apep_colors[1], fill = apep_colors[1],
              alpha = 0.2, linewidth = 1) +
  geom_smooth(data = df %>% filter(pop_centered >= 0 & pop_centered <= bw_plot),
              aes(x = pop_centered, y = female_share),
              method = "lm", formula = y ~ x,
              color = apep_colors[2], fill = apep_colors[2],
              alpha = 0.2, linewidth = 1) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "grey30",
             linewidth = 0.7) +
  annotate("text", x = 300, y = 0.33,
           label = "Proportional +\nGender Parity",
           size = 3.5, fontface = "italic", color = apep_colors[2]) +
  annotate("text", x = -300, y = 0.33,
           label = "Majority vote\nNo parity",
           size = 3.5, fontface = "italic", color = apep_colors[1]) +
  labs(
    title = "First Stage: Female Councillor Share at the 1,000 Threshold",
    subtitle = "Binned means (bins of 20 inhabitants), linear fit within each side",
    x = "Population Relative to 1,000 Threshold",
    y = "Female Share of Municipal Councillors",
    caption = "Source: Répertoire National des Élus (2025)."
  ) +
  theme_apep() +
  scale_y_continuous(labels = scales::percent_format())

ggsave(file.path(fig_dir, "fig1_first_stage.pdf"), p1, width = 8, height = 5)

## ===========================================================
## Figure 2: McCrary Density Test
## ===========================================================

cat("Creating Figure 2: Density Test...\n")

hist_data <- df %>%
  filter(abs(pop_centered) <= 500) %>%
  mutate(side = ifelse(pop_centered < 0, "Below", "Above"))

p2 <- ggplot(hist_data, aes(x = pop_centered, fill = side)) +
  geom_histogram(binwidth = 10, color = "white", linewidth = 0.2) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "grey30",
             linewidth = 0.7) +
  scale_fill_manual(values = c("Below" = apep_colors[1],
                                "Above" = apep_colors[2]), name = "") +
  labs(
    title = "Density of Communes Around the 1,000-Inhabitant Threshold",
    subtitle = paste0("McCrary test: T = ", round(density_test$test$t_jk, 2),
                      ", p = ", round(density_test$test$p_jk, 3),
                      " (no evidence of manipulation)"),
    x = "Population Relative to 1,000",
    y = "Number of Communes",
    caption = "Source: INSEE Communes data. Bins of 10 inhabitants."
  ) +
  theme_apep()

ggsave(file.path(fig_dir, "fig2_density.pdf"), p2, width = 8, height = 5)

## ===========================================================
## Figure 3: Two-panel — Female Employment Rate + LFPR
## ===========================================================

cat("Creating Figure 3: Two-panel employment + LFPR...\n")

make_panel_data <- function(yvar, label) {
  df %>%
    filter(abs(pop_centered) <= bw_plot) %>%
    mutate(bin = cut(pop_centered,
                     breaks = seq(-bw_plot, bw_plot, by = 25),
                     include.lowest = TRUE)) %>%
    group_by(bin) %>%
    summarise(
      pop_mid = mean(pop_centered),
      y = mean(.data[[yvar]], na.rm = TRUE),
      .groups = "drop"
    ) %>%
    mutate(panel = label)
}

panel_bins <- bind_rows(
  make_panel_data("female_emp_rate", "Female Employment Rate"),
  make_panel_data("female_lfpr", "Female LFPR")
)

panel_lines <- bind_rows(
  df %>% filter(abs(pop_centered) <= bw_plot) %>%
    mutate(panel = "Female Employment Rate") %>%
    select(pop_centered, female_emp_rate, panel) %>%
    rename(y = female_emp_rate),
  df %>% filter(abs(pop_centered) <= bw_plot) %>%
    mutate(panel = "Female LFPR") %>%
    select(pop_centered, female_lfpr, panel) %>%
    rename(y = female_lfpr)
)

p3 <- ggplot() +
  geom_point(data = panel_bins, aes(x = pop_mid, y = y),
             color = "grey50", size = 1.5, alpha = 0.7) +
  geom_smooth(data = panel_lines %>% filter(pop_centered < 0),
              aes(x = pop_centered, y = y),
              method = "lm", formula = y ~ x,
              color = apep_colors[1], fill = apep_colors[1],
              alpha = 0.2, linewidth = 0.8) +
  geom_smooth(data = panel_lines %>% filter(pop_centered >= 0),
              aes(x = pop_centered, y = y),
              method = "lm", formula = y ~ x,
              color = apep_colors[2], fill = apep_colors[2],
              alpha = 0.2, linewidth = 0.8) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "grey30",
             linewidth = 0.5) +
  facet_wrap(~panel, scales = "free_y") +
  labs(
    title = "Female Economic Outcomes at the 1,000-Inhabitant Threshold",
    subtitle = "No discontinuity in either employment rate or labor force participation",
    x = "Population Relative to 1,000 Threshold",
    y = "Rate (ages 15-64)",
    caption = "Source: INSEE Census 2022. Points are binned means (bins of 25)."
  ) +
  theme_apep() +
  scale_y_continuous(labels = scales::percent_format())

ggsave(file.path(fig_dir, "fig3_female_emp.pdf"), p3, width = 10, height = 5)

## ===========================================================
## Figure 4: Bandwidth Sensitivity
## ===========================================================

cat("Creating Figure 4: Bandwidth Sensitivity...\n")

p4 <- ggplot(bw_results, aes(x = bandwidth, y = coef)) +
  geom_ribbon(aes(ymin = coef - 1.96 * se, ymax = coef + 1.96 * se),
              alpha = 0.2, fill = apep_colors[1]) +
  geom_line(color = apep_colors[1], linewidth = 0.8) +
  geom_point(color = apep_colors[1], size = 2) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
  labs(
    title = "Bandwidth Sensitivity: RDD Estimate for Female Employment Rate",
    subtitle = "Local linear regression with HC1 standard errors, 95% CI",
    x = "Bandwidth (inhabitants from threshold)",
    y = "RDD Estimate (pp)",
    caption = "Note: Shaded region shows 95% confidence interval."
  ) +
  theme_apep()

ggsave(file.path(fig_dir, "fig4_bw_sensitivity.pdf"), p4, width = 8, height = 5)

## ===========================================================
## Figure 5: Multi-outcome RDD coefficients (EXPANDED)
## ===========================================================

cat("Creating Figure 5: Multi-outcome coefficients (expanded)...\n")

# Combine all outcome families
all_coefs <- list()

# Labor outcomes
for (v in names(results_v2$labor)) {
  r <- results_v2$labor[[v]]
  all_coefs[[length(all_coefs) + 1]] <- data.frame(
    outcome = r$name, coef = r$coef_conv, se = r$se_robust,
    ci_lower = r$ci_lower, ci_upper = r$ci_upper,
    family = "Labor Market"
  )
}

# Political outcomes
for (v in names(results_v2$political)) {
  r <- results_v2$political[[v]]
  all_coefs[[length(all_coefs) + 1]] <- data.frame(
    outcome = r$name, coef = r$coef_conv, se = r$se_robust,
    ci_lower = r$ci_lower, ci_upper = r$ci_upper,
    family = "Political"
  )
}

# Spending outcomes
for (v in names(results_v2$spending)) {
  r <- results_v2$spending[[v]]
  all_coefs[[length(all_coefs) + 1]] <- data.frame(
    outcome = r$name, coef = r$coef_conv, se = r$se_robust,
    ci_lower = r$ci_lower, ci_upper = r$ci_upper,
    family = "Municipal Spending"
  )
}

# Entrepreneurship
for (v in names(results_v2$entrepreneurship)) {
  r <- results_v2$entrepreneurship[[v]]
  all_coefs[[length(all_coefs) + 1]] <- data.frame(
    outcome = r$name, coef = r$coef_conv, se = r$se_robust,
    ci_lower = r$ci_lower, ci_upper = r$ci_upper,
    family = "Entrepreneurship"
  )
}

coef_data <- bind_rows(all_coefs)

if (nrow(coef_data) > 0) {
  coef_data$outcome <- factor(coef_data$outcome,
                              levels = rev(coef_data$outcome))

  family_colors <- c("Labor Market" = apep_colors[1],
                     "Political" = apep_colors[2],
                     "Municipal Spending" = apep_colors[3],
                     "Entrepreneurship" = apep_colors[4])

  p5 <- ggplot(coef_data, aes(x = coef, y = outcome, color = family)) +
    geom_vline(xintercept = 0, linetype = "dashed", color = "grey40") +
    geom_errorbarh(aes(xmin = ci_lower, xmax = ci_upper),
                   height = 0.2) +
    geom_point(size = 3) +
    scale_color_manual(values = family_colors, name = "Outcome Family") +
    labs(
      title = "RDD Estimates Across All Outcome Families",
      subtitle = "Reduced-form discontinuity at the 1,000-inhabitant threshold",
      x = "RDD Estimate",
      y = "",
      caption = "Horizontal bars: 95% robust bias-corrected CIs. CER-optimal bandwidths."
    ) +
    theme_apep() +
    theme(axis.text.y = element_text(size = 9))

  ggsave(file.path(fig_dir, "fig5_multi_outcome.pdf"), p5, width = 9, height = 7)
}

## ===========================================================
## Figure 6: Placebo Cutoffs
## ===========================================================

cat("Creating Figure 6: Placebo Cutoffs...\n")

p6 <- ggplot(placebo_results, aes(x = cutoff, y = coef)) +
  geom_errorbar(aes(ymin = coef - 1.96 * se, ymax = coef + 1.96 * se),
                width = 30, color = ifelse(placebo_results$is_real,
                                           apep_colors[2], "grey60")) +
  geom_point(size = 3, color = ifelse(placebo_results$is_real,
                                       apep_colors[2], "grey50")) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
  geom_vline(xintercept = 1000, linetype = "dotted", color = apep_colors[2],
             alpha = 0.5) +
  annotate("text", x = 1000,
           y = max(placebo_results$coef + 1.96 * placebo_results$se),
           label = "Actual\nthreshold", size = 3, color = apep_colors[2],
           vjust = -0.5) +
  labs(
    title = "Placebo Cutoff Tests: Female Employment Rate",
    subtitle = "RDD estimated at various population thresholds",
    x = "Population Cutoff",
    y = "RDD Estimate",
    caption = "Orange = actual threshold (1,000). Grey = placebo cutoffs."
  ) +
  theme_apep()

ggsave(file.path(fig_dir, "fig6_placebo.pdf"), p6, width = 8, height = 5)

## ===========================================================
## Figure 7: Female Mayor RDD
## ===========================================================

cat("Creating Figure 7: Female Mayor RDD...\n")

df$has_female_mayor_num <- as.numeric(df$has_female_mayor)

p7 <- make_rdd_plot(df, "has_female_mayor_num",
                    "Probability of Female Mayor",
                    "Female Mayor Probability at the 1,000-Inhabitant Threshold",
                    "Mayor is elected by the council — not mechanically determined by parity",
                    bin_width = 30)
p7 <- p7 + scale_y_continuous(labels = scales::percent_format())

ggsave(file.path(fig_dir, "fig7_female_mayor.pdf"), p7, width = 8, height = 5)

## ===========================================================
## Figure 8: Spending Outcomes RDD (if data available)
## ===========================================================

cat("Creating Figure 8: Spending Outcomes...\n")

if (any(!is.na(df$spend_social_pc))) {
  p8 <- make_rdd_plot(df, "spend_social_pc",
                      "Social Spending per Capita (EUR)",
                      "Social Spending at the 1,000-Inhabitant Threshold",
                      "DGFIP Balances Comptables: Function 5 (action sociale) + Function 6 (famille)",
                      bin_width = 30)
  ggsave(file.path(fig_dir, "fig8_spending.pdf"), p8, width = 8, height = 5)
} else {
  cat("  Spending data not available, skipping Figure 8\n")
  # Create a placeholder plot
  p8 <- ggplot() +
    annotate("text", x = 0.5, y = 0.5,
             label = "Spending data not available\n(DGFIP download may have failed)",
             size = 5) +
    theme_void()
  ggsave(file.path(fig_dir, "fig8_spending.pdf"), p8, width = 8, height = 5)
}

## ===========================================================
## Figure 9: MDE vs Literature Benchmarks
## ===========================================================

cat("Creating Figure 9: MDE Analysis...\n")

# Literature benchmarks
benchmarks <- data.frame(
  study = c("Chattopadhyay & Duflo (2004)\n[India: public goods]",
            "Beaman et al. (2012)\n[India: aspirations]",
            "Bertrand et al. (2019)\n[Norway: broad labor]",
            "Bagues & Campa (2021)\n[Spain: candidacy]"),
  effect = c(0.50, 0.06, 0.005, 0.005),
  type = "Literature"
)

mde_plot <- mde_results %>%
  mutate(study = outcome, effect = mde, type = "MDE (this paper)")

plot_df <- bind_rows(
  benchmarks,
  mde_plot %>% select(study, effect, type)
)

# Only plot relevant MDEs
mde_subset <- mde_results[1:4, ]  # First 4 outcomes

p9 <- ggplot() +
  # MDE bars
  geom_col(data = mde_subset,
           aes(x = reorder(outcome, -mde), y = mde),
           fill = apep_colors[1], alpha = 0.7, width = 0.6) +
  # Literature benchmarks as horizontal lines
  geom_hline(yintercept = 0.06, linetype = "dashed",
             color = apep_colors[2], linewidth = 0.8) +
  annotate("text", x = nrow(mde_subset) + 0.3, y = 0.063,
           label = "Beaman et al. (2012)\nIndia: 5-7 pp",
           size = 3, hjust = 1, color = apep_colors[2]) +
  geom_hline(yintercept = 0.005, linetype = "dotted",
             color = apep_colors[3], linewidth = 0.8) +
  annotate("text", x = nrow(mde_subset) + 0.3, y = 0.008,
           label = "Bertrand et al. (2019)\nNorway: ~0.5 pp",
           size = 3, hjust = 1, color = apep_colors[3]) +
  labs(
    title = "Minimum Detectable Effects vs. Literature Benchmarks",
    subtitle = "80% power, alpha = 0.05. This design can detect effects above the bars.",
    x = "",
    y = "Minimum Detectable Effect (pp)",
    caption = "MDE computed from robust standard errors of baseline RDD specifications."
  ) +
  theme_apep() +
  theme(axis.text.x = element_text(angle = 20, hjust = 1, size = 9))

ggsave(file.path(fig_dir, "fig9_mde.pdf"), p9, width = 8, height = 5)

## ===========================================================
## Figure 10: 3,500 Threshold Validation
## ===========================================================

cat("Creating Figure 10: 3,500 Threshold...\n")

df_3500 <- df %>% filter(pop >= 2000 & pop <= 5000)

if (nrow(df_3500) > 200) {
  plot_data_3500 <- df_3500 %>%
    mutate(bin = cut(pop_centered_3500,
                     breaks = seq(-1500, 1500, by = 50),
                     include.lowest = TRUE)) %>%
    group_by(bin) %>%
    summarise(
      pop_mid = mean(pop_centered_3500),
      female_share = mean(female_share),
      .groups = "drop"
    )

  p10 <- ggplot() +
    geom_point(data = plot_data_3500, aes(x = pop_mid, y = female_share),
               color = "grey50", size = 2, alpha = 0.7) +
    geom_smooth(data = df_3500 %>% filter(pop_centered_3500 < 0),
                aes(x = pop_centered_3500, y = female_share),
                method = "lm", formula = y ~ x,
                color = apep_colors[1], fill = apep_colors[1],
                alpha = 0.2, linewidth = 1) +
    geom_smooth(data = df_3500 %>% filter(pop_centered_3500 >= 0),
                aes(x = pop_centered_3500, y = female_share),
                method = "lm", formula = y ~ x,
                color = apep_colors[2], fill = apep_colors[2],
                alpha = 0.2, linewidth = 1) +
    geom_vline(xintercept = 0, linetype = "dashed", color = "grey30",
               linewidth = 0.7) +
    annotate("text", x = -800, y = max(plot_data_3500$female_share, na.rm = TRUE),
             label = "Both sides: PR\n(parity since 2000)",
             size = 3.5, fontface = "italic", color = "grey40") +
    labs(
      title = "Validation: Female Councillor Share at the 3,500-Inhabitant Threshold",
      subtitle = "Both sides use PR with parity — no first stage expected",
      x = "Population Relative to 3,500 Threshold",
      y = "Female Share of Municipal Councillors",
      caption = "Communes 2,000-5,000. Both sides had PR with parity since 2000 law."
    ) +
    theme_apep() +
    scale_y_continuous(labels = scales::percent_format())

  ggsave(file.path(fig_dir, "fig10_validation_3500.pdf"), p10, width = 8, height = 5)
} else {
  cat("  Too few communes for 3,500 validation plot\n")
}

## ===========================================================
## Figure 11: Female LFPR RDD (standalone, for appendix)
## ===========================================================

cat("Creating Figure 11: Female LFPR (appendix)...\n")

p11 <- make_rdd_plot(df, "female_lfpr",
                     "Female LFPR (ages 15-64)",
                     "Female Labor Force Participation at the 1,000 Threshold",
                     "No economically meaningful discontinuity",
                     bin_width = 25)
p11 <- p11 + scale_y_continuous(labels = scales::percent_format())

ggsave(file.path(fig_dir, "fig7_female_lfpr.pdf"), p11, width = 8, height = 5)

cat("All figures saved to", fig_dir, "\n")
