###############################################################################
# 05_figures.R — Generate all figures for the paper
# Paper: Fear and Punitiveness in America
# APEP Working Paper apep_0313
###############################################################################

source("00_packages.R")

df <- readRDS("../data/gss_analysis.rds")
crime <- readRDS("../data/crime_rates.rds")
results_summary <- readRDS("../data/results_summary.rds")

fig_dir <- "../figures"
dir.create(fig_dir, showWarnings = FALSE)

###############################################################################
# Figure 1: The Paradox — Crime Falls, Fear Persists
###############################################################################

cat("=== Figure 1: Crime and Fear Trends ===\n")

# Aggregate fear by year
fear_trend <- df %>%
  group_by(year) %>%
  summarise(
    pct_afraid = mean(afraid, na.rm = TRUE) * 100,
    n = n(),
    se = sqrt(pct_afraid / 100 * (1 - pct_afraid / 100) / n) * 100,
    .groups = "drop"
  )

# Normalize crime rate to percentage scale for dual axis
crime_norm <- crime %>%
  filter(year >= 1973 & year <= 2024) %>%
  mutate(
    violent_norm = violent_rate / max(violent_rate, na.rm = TRUE) * 100
  )

fig1 <- ggplot() +
  geom_ribbon(data = fear_trend,
              aes(x = year, ymin = pct_afraid - 1.96 * se, ymax = pct_afraid + 1.96 * se),
              fill = apep_colors[1], alpha = 0.2) +
  geom_line(data = fear_trend,
            aes(x = year, y = pct_afraid, color = "Fear of crime\n(% afraid)"),
            linewidth = 1.2) +
  geom_point(data = fear_trend,
             aes(x = year, y = pct_afraid),
             color = apep_colors[1], size = 1.5) +
  geom_line(data = crime_norm,
            aes(x = year, y = violent_norm, color = "Violent crime rate\n(normalized to 100)"),
            linewidth = 1.2, linetype = "dashed") +
  scale_color_manual(values = c("Fear of crime\n(% afraid)" = apep_colors[1],
                                "Violent crime rate\n(normalized to 100)" = apep_colors[2]),
                     name = "") +
  scale_x_continuous(breaks = seq(1975, 2025, 5)) +
  scale_y_continuous(limits = c(0, 100),
                     labels = function(x) paste0(x, "%")) +
  labs(x = "Year", y = "Percent / Normalized Rate",
       title = "Crime Falls, but Fear Persists",
       subtitle = "GSS fear of walking alone at night vs. FBI violent crime rate, 1973-2024",
       caption = "Source: GSS cumulative file; FBI UCR. Shaded area = 95% CI.") +
  theme_apep() +
  theme(legend.position = c(0.75, 0.85),
        legend.background = element_rect(fill = "white", color = "grey80"))

ggsave(file.path(fig_dir, "fig1_fear_crime_trends.pdf"), fig1,
       width = 8, height = 5, device = cairo_pdf)
cat("Saved: fig1_fear_crime_trends.pdf\n")

###############################################################################
# Figure 2: Punitive Attitudes Over Time
###############################################################################

cat("=== Figure 2: Punitive Attitude Trends ===\n")

punitive_trends <- df %>%
  group_by(year) %>%
  summarise(
    `Death Penalty\nSupport` = mean(favor_deathpen, na.rm = TRUE) * 100,
    `Courts Too\nLenient` = mean(courts_too_lenient, na.rm = TRUE) * 100,
    `Want More\nCrime Spending` = mean(want_more_crime_spending, na.rm = TRUE) * 100,
    .groups = "drop"
  ) %>%
  pivot_longer(-year, names_to = "attitude", values_to = "pct")

fig2 <- ggplot(punitive_trends, aes(x = year, y = pct, color = attitude)) +
  geom_line(linewidth = 1) +
  geom_point(size = 1.2) +
  scale_color_manual(values = apep_colors[1:3], name = "") +
  scale_x_continuous(breaks = seq(1975, 2025, 5)) +
  scale_y_continuous(labels = function(x) paste0(x, "%")) +
  labs(x = "Year", y = "Percent Supporting",
       title = "Punitive Attitudes in America, 1973-2024",
       subtitle = "GSS respondents supporting punitive criminal justice policies",
       caption = "Source: GSS cumulative file.") +
  theme_apep() +
  theme(legend.position = "bottom")

ggsave(file.path(fig_dir, "fig2_punitive_trends.pdf"), fig2,
       width = 8, height = 5, device = cairo_pdf)
cat("Saved: fig2_punitive_trends.pdf\n")

###############################################################################
# Figure 3: Propensity Score Distribution
###############################################################################

cat("=== Figure 3: Propensity Score Overlap ===\n")

ps_data <- readRDS("../data/ps_diagnostics.rds")

fig3 <- ggplot(ps_data, aes(x = ps, fill = factor(afraid,
                                                    labels = c("Not Afraid", "Afraid")))) +
  geom_density(alpha = 0.5, color = "grey30", linewidth = 0.3) +
  geom_vline(xintercept = c(0.05, 0.95), linetype = "dashed", color = "grey50") +
  scale_fill_manual(values = apep_colors[c(2, 1)], name = "Treatment Status") +
  labs(x = "Estimated Propensity Score",
       y = "Density",
       title = "Propensity Score Overlap",
       subtitle = "Distribution of P(Afraid | X) by treatment status",
       caption = "Dashed lines = trimming boundaries [0.05, 0.95].") +
  theme_apep()

ggsave(file.path(fig_dir, "fig3_ps_overlap.pdf"), fig3,
       width = 8, height = 5, device = cairo_pdf)
cat("Saved: fig3_ps_overlap.pdf\n")

###############################################################################
# Figure 4: Main Results — AIPW Estimates
###############################################################################

cat("=== Figure 4: Main AIPW Results ===\n")

main_res <- results_summary %>%
  filter(type == "Main") %>%
  mutate(outcome = c("Death Penalty\nSupport", "Courts Too\nLenient",
                      "More Crime\nSpending", "Favor Gun\nPermits"))

fig4 <- ggplot(main_res, aes(x = reorder(outcome, ate), y = ate)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
  geom_pointrange(aes(ymin = ci_lo, ymax = ci_hi),
                  color = apep_colors[1], size = 0.8, linewidth = 0.8) +
  coord_flip() +
  labs(x = "", y = "AIPW Estimate (ATE)",
       title = "Effect of Fear of Crime on Punitive Attitudes",
       subtitle = "Doubly robust estimates with 95% confidence intervals",
       caption = "Source: GSS 1973-2024. AIPW with SuperLearner cross-fitting.") +
  theme_apep()

ggsave(file.path(fig_dir, "fig4_main_results.pdf"), fig4,
       width = 8, height = 5, device = cairo_pdf)
cat("Saved: fig4_main_results.pdf\n")

###############################################################################
# Figure 5: Main vs. Placebo Comparison
###############################################################################

cat("=== Figure 5: Main vs Placebo ===\n")

all_res <- results_summary %>%
  mutate(
    outcome_label = c("Death Penalty", "Courts Lenient",
                      "Crime Spending", "Gun Permits",
                      "Space Spending", "Science Spending",
                      "Environment Spending"),
    outcome_label = factor(outcome_label,
                           levels = rev(c("Death Penalty", "Courts Lenient",
                                          "Crime Spending", "Gun Permits",
                                          "Space Spending", "Science Spending",
                                          "Environment Spending")))
  )

fig5 <- ggplot(all_res, aes(x = outcome_label, y = ate, color = type)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
  geom_pointrange(aes(ymin = ci_lo, ymax = ci_hi),
                  size = 0.8, linewidth = 0.8) +
  coord_flip() +
  scale_color_manual(values = c("Main" = apep_colors[1], "Placebo" = apep_colors[2]),
                     name = "Test Type") +
  labs(x = "", y = "AIPW Estimate (ATE)",
       title = "Main Effects vs. Placebo Tests",
       subtitle = "Fear of crime should affect crime-related attitudes, not science/space spending",
       caption = "Source: GSS 1973-2024. AIPW with SuperLearner cross-fitting.") +
  theme_apep()

ggsave(file.path(fig_dir, "fig5_main_vs_placebo.pdf"), fig5,
       width = 8, height = 6, device = cairo_pdf)
cat("Saved: fig5_main_vs_placebo.pdf\n")

###############################################################################
# Figure 6: Fear by Demographics
###############################################################################

cat("=== Figure 6: Fear Demographics ===\n")

demo_fear <- df %>%
  mutate(
    group = case_when(
      female == 1 & black == 1 ~ "Black Women",
      female == 1 & black == 0 & other_race == 0 ~ "White Women",
      female == 0 & black == 1 ~ "Black Men",
      female == 0 & black == 0 & other_race == 0 ~ "White Men",
      TRUE ~ "Other"
    )
  ) %>%
  filter(group != "Other") %>%
  group_by(year, group) %>%
  summarise(pct_afraid = mean(afraid, na.rm = TRUE) * 100,
            n = n(), .groups = "drop") %>%
  filter(n >= 20)

fig6 <- ggplot(demo_fear, aes(x = year, y = pct_afraid, color = group)) +
  geom_line(linewidth = 0.8) +
  geom_point(size = 0.8) +
  scale_color_manual(values = apep_colors[1:4], name = "") +
  scale_x_continuous(breaks = seq(1975, 2025, 10)) +
  scale_y_continuous(labels = function(x) paste0(x, "%")) +
  labs(x = "Year", y = "Percent Afraid",
       title = "Fear of Crime by Race and Gender, 1973-2024",
       subtitle = "GSS: 'Is there any area near here where you would be afraid to walk alone at night?'",
       caption = "Source: GSS cumulative file.") +
  theme_apep() +
  theme(legend.position = "bottom")

ggsave(file.path(fig_dir, "fig6_fear_demographics.pdf"), fig6,
       width = 8, height = 5, device = cairo_pdf)
cat("Saved: fig6_fear_demographics.pdf\n")

###############################################################################
# Figure 7: Heterogeneity by Period
###############################################################################

cat("=== Figure 7: Heterogeneity by Period ===\n")

het_data <- readRDS("../data/heterogeneity_results.rds")

# Period heterogeneity
period_het <- het_data %>%
  filter(grepl("^Period", label)) %>%
  mutate(period = str_extract(label, "\\d{4}-\\d{4}"))

if (nrow(period_het) > 0) {
  fig7 <- ggplot(period_het, aes(x = period, y = ate)) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
    geom_pointrange(aes(ymin = ci_lo, ymax = ci_hi),
                    color = apep_colors[1], size = 0.8, linewidth = 0.8) +
    labs(x = "Time Period", y = "IPW Estimate (ATE)",
         title = "Effect of Fear on Death Penalty Support Over Time",
         subtitle = "Has the fear-punitiveness link strengthened or weakened?",
         caption = "Source: GSS. IPW estimates by period with bootstrap SEs.") +
    theme_apep()

  ggsave(file.path(fig_dir, "fig7_period_heterogeneity.pdf"), fig7,
         width = 7, height = 5, device = cairo_pdf)
  cat("Saved: fig7_period_heterogeneity.pdf\n")
} else {
  cat("Not enough period heterogeneity data for Figure 7.\n")
}

cat("\n=== All Figures Generated ===\n")
