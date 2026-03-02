## ============================================================
## 05_figures.R — All figures for the paper (v3: expanded)
## New: childcare RDD, facilities summary, pipeline RDD,
## updated 6-family forest plot, restructured per exhibit review
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
    caption = "Source: RNE (2025)."
  ) +
  theme_apep() +
  scale_y_continuous(labels = scales::percent_format())

ggsave(file.path(fig_dir, "fig1_first_stage.pdf"), p1, width = 8, height = 5)

## ===========================================================
## Figure 2: Multi-outcome Forest Plot (6 families — MOVED EARLIER)
## ===========================================================

cat("Creating Figure 2: Multi-outcome forest plot (v3, 6 families)...\n")

all_coefs <- list()

# Helper to add results from a family
add_family <- function(res_list, family_name) {
  for (v in names(res_list)) {
    r <- res_list[[v]]
    all_coefs[[length(all_coefs) + 1]] <<- data.frame(
      outcome = r$name, coef = r$coef_conv, se = r$se_robust,
      ci_lower = r$ci_lower, ci_upper = r$ci_upper,
      family = family_name
    )
  }
}

add_family(results_v2$primary, "Primary: Labor")
if (length(results_v2$pipeline) > 0) add_family(results_v2$pipeline, "Executive Pipeline")
if (length(results_v2$spending) > 0) add_family(results_v2$spending, "Spending Composition")
if (length(results_v2$facilities) > 0) add_family(results_v2$facilities, "Facility Provision")
if (length(results_v2$exploratory) > 0) add_family(results_v2$exploratory, "Exploratory")

coef_data <- bind_rows(all_coefs)

if (nrow(coef_data) > 0) {
  coef_data$outcome <- factor(coef_data$outcome,
                              levels = rev(coef_data$outcome))

  family_colors <- c("Primary: Labor" = apep_colors[1],
                     "Executive Pipeline" = apep_colors[2],
                     "Spending Composition" = apep_colors[3],
                     "Facility Provision" = apep_colors[4],
                     "Exploratory" = apep_colors[6])

  p2 <- ggplot(coef_data, aes(x = coef, y = outcome, color = family)) +
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
    theme(axis.text.y = element_text(size = 8))

  ggsave(file.path(fig_dir, "fig2_multi_outcome_v3.pdf"), p2, width = 9, height = 8)
  # Also save with old name for compatibility
  ggsave(file.path(fig_dir, "fig5_multi_outcome.pdf"), p2, width = 9, height = 8)
}

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
## Figure 4: NEW v3 — Childcare Facilities RDD
## ===========================================================

cat("Creating Figure 4: Childcare Facilities RDD...\n")

if ("bpe_childcare_pc" %in% names(df) && any(!is.na(df$bpe_childcare_pc))) {
  p4 <- make_rdd_plot(df, "bpe_childcare_pc",
                      "Childcare Facilities per 1,000 Pop.",
                      "Childcare Facility Provision at the 1,000-Inhabitant Threshold",
                      "BPE 2023: crèches, haltes-garderies, micro-crèches",
                      bin_width = 30)
  ggsave(file.path(fig_dir, "fig4_childcare_rdd.pdf"), p4, width = 8, height = 5)
} else {
  cat("  BPE childcare data not available, creating placeholder\n")
  p4 <- ggplot() +
    annotate("text", x = 0.5, y = 0.5,
             label = "BPE childcare data not available", size = 5) +
    theme_void()
  ggsave(file.path(fig_dir, "fig4_childcare_rdd.pdf"), p4, width = 8, height = 5)
}

## ===========================================================
## Figure 5: NEW v3 — Facility provision coefficient plot
## ===========================================================

cat("Creating Figure 5: Facilities summary...\n")

if (length(results_v2$facilities) > 0) {
  fac_data <- data.frame()
  for (v in names(results_v2$facilities)) {
    r <- results_v2$facilities[[v]]
    fac_data <- rbind(fac_data, data.frame(
      outcome = r$name, coef = r$coef_conv,
      ci_lower = r$ci_lower, ci_upper = r$ci_upper
    ))
  }

  fac_data$outcome <- factor(fac_data$outcome, levels = rev(fac_data$outcome))

  p5 <- ggplot(fac_data, aes(x = coef, y = outcome)) +
    geom_vline(xintercept = 0, linetype = "dashed", color = "grey40") +
    geom_errorbarh(aes(xmin = ci_lower, xmax = ci_upper),
                   height = 0.2, color = apep_colors[4]) +
    geom_point(size = 3, color = apep_colors[4]) +
    labs(
      title = "Public Facility Provision at the 1,000 Threshold",
      subtitle = "BPE equipment counts per 1,000 inhabitants",
      x = "RDD Estimate (facilities per 1,000 pop.)",
      y = "",
      caption = "Source: INSEE BPE 2023. CER-optimal bandwidths, robust bias-corrected CIs."
    ) +
    theme_apep()

  ggsave(file.path(fig_dir, "fig5_facilities_summary.pdf"), p5, width = 8, height = 5)
} else {
  cat("  No facility results, skipping\n")
}

## ===========================================================
## Figure 6: NEW v3 — Executive Pipeline RDD
## ===========================================================

cat("Creating Figure 6: Executive Pipeline...\n")

if ("female_share_adjoints" %in% names(df) &&
    any(!is.na(df$female_share_adjoints))) {
  p6 <- make_rdd_plot(df, "female_share_adjoints",
                      "Female Share of Adjoints",
                      "Female Representation in Executive Team at the 1,000 Threshold",
                      "Deputy mayors (adjoints) elected by the council",
                      bin_width = 30)
  p6 <- p6 + scale_y_continuous(labels = scales::percent_format())
  ggsave(file.path(fig_dir, "fig6_pipeline_rdd.pdf"), p6, width = 8, height = 5)
} else {
  cat("  Adjoint data not available, skipping\n")
}

## ===========================================================
## Figure 7: McCrary Density Test
## ===========================================================

cat("Creating Figure 7: Density Test...\n")

hist_data <- df %>%
  filter(abs(pop_centered) <= 500) %>%
  mutate(side = ifelse(pop_centered < 0, "Below", "Above"))

p7 <- ggplot(hist_data, aes(x = pop_centered, fill = side)) +
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

ggsave(file.path(fig_dir, "fig2_density.pdf"), p7, width = 8, height = 5)

## ===========================================================
## Appendix Figures
## ===========================================================

cat("Creating appendix figures...\n")

## Bandwidth Sensitivity (moved to appendix)
p_bw <- ggplot(bw_results, aes(x = bandwidth, y = coef)) +
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
    caption = "Shaded region shows 95% confidence interval."
  ) +
  theme_apep()

ggsave(file.path(fig_dir, "fig4_bw_sensitivity.pdf"), p_bw, width = 8, height = 5)

## Placebo Cutoffs (appendix)
p_plac <- ggplot(placebo_results, aes(x = cutoff, y = coef)) +
  geom_errorbar(aes(ymin = coef - 1.96 * se, ymax = coef + 1.96 * se),
                width = 30, color = ifelse(placebo_results$is_real,
                                           apep_colors[2], "grey60")) +
  geom_point(size = 3, color = ifelse(placebo_results$is_real,
                                       apep_colors[2], "grey50")) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
  geom_vline(xintercept = 1000, linetype = "dotted", color = apep_colors[2],
             alpha = 0.5) +
  labs(
    title = "Placebo Cutoff Tests: Female Employment Rate",
    subtitle = "RDD estimated at various population thresholds",
    x = "Population Cutoff",
    y = "RDD Estimate",
    caption = "Orange = actual threshold (1,000). Grey = placebo cutoffs."
  ) +
  theme_apep()

ggsave(file.path(fig_dir, "fig6_placebo.pdf"), p_plac, width = 8, height = 5)

## Female Mayor RDD (appendix)
df$has_female_mayor_num <- as.numeric(df$has_female_mayor)

p_mayor <- make_rdd_plot(df, "has_female_mayor_num",
                    "Probability of Female Mayor",
                    "Female Mayor Probability at the 1,000-Inhabitant Threshold",
                    "Mayor is elected by the council — not mechanically determined by parity",
                    bin_width = 30)
p_mayor <- p_mayor + scale_y_continuous(labels = scales::percent_format())

ggsave(file.path(fig_dir, "fig7_female_mayor.pdf"), p_mayor, width = 8, height = 5)

## Social Spending (appendix)
if (any(!is.na(df$spend_social_pc))) {
  p_spend <- make_rdd_plot(df, "spend_social_pc",
                      "Social Spending per Capita (EUR)",
                      "Social Spending at the 1,000-Inhabitant Threshold",
                      "DGFIP Balances Comptables: accounts 655-657",
                      bin_width = 30)
  ggsave(file.path(fig_dir, "fig8_spending.pdf"), p_spend, width = 8, height = 5)
}

## MDE Analysis
p_mde <- ggplot() +
  geom_col(data = mde_results[1:min(6, nrow(mde_results)), ],
           aes(x = reorder(outcome, -mde), y = mde),
           fill = apep_colors[1], alpha = 0.7, width = 0.6) +
  geom_hline(yintercept = 0.06, linetype = "dashed",
             color = apep_colors[2], linewidth = 0.8) +
  annotate("text", x = min(6, nrow(mde_results)), y = 0.063,
           label = "Beaman et al. (2012)\nIndia: 5-7 pp",
           size = 3, hjust = 1, color = apep_colors[2]) +
  geom_hline(yintercept = 0.005, linetype = "dotted",
             color = apep_colors[3], linewidth = 0.8) +
  annotate("text", x = min(6, nrow(mde_results)), y = 0.008,
           label = "Bertrand et al. (2019)\nNorway: ~0.5 pp",
           size = 3, hjust = 1, color = apep_colors[3]) +
  labs(
    title = "Minimum Detectable Effects vs. Literature Benchmarks",
    subtitle = "80% power, alpha = 0.05",
    x = "",
    y = "Minimum Detectable Effect (pp)",
    caption = "MDE computed from robust standard errors."
  ) +
  theme_apep() +
  theme(axis.text.x = element_text(angle = 20, hjust = 1, size = 8))

ggsave(file.path(fig_dir, "fig9_mde.pdf"), p_mde, width = 8, height = 5)

## 3,500 Threshold Validation (appendix)
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
    labs(
      title = "Validation: Female Councillor Share at the 3,500 Threshold",
      subtitle = "Both sides use PR with parity — no first stage expected",
      x = "Population Relative to 3,500 Threshold",
      y = "Female Share of Municipal Councillors",
      caption = "Communes 2,000-5,000."
    ) +
    theme_apep() +
    scale_y_continuous(labels = scales::percent_format())

  ggsave(file.path(fig_dir, "fig10_validation_3500.pdf"), p10, width = 8, height = 5)
}

## Female LFPR standalone (appendix)
p_lfpr <- make_rdd_plot(df, "female_lfpr",
                     "Female LFPR (ages 15-64)",
                     "Female Labor Force Participation at the 1,000 Threshold",
                     "No economically meaningful discontinuity",
                     bin_width = 25)
p_lfpr <- p_lfpr + scale_y_continuous(labels = scales::percent_format())

ggsave(file.path(fig_dir, "fig7_female_lfpr.pdf"), p_lfpr, width = 8, height = 5)

cat("All figures saved to", fig_dir, "\n")
