## 05_figures.R - Generate all figures
## Neighbourhood Planning and House Prices (apep_0228)

source("00_packages.R")

data_dir <- "../data"
fig_dir  <- "../figures"
dir.create(fig_dir, showWarnings = FALSE, recursive = TRUE)

panel     <- readRDS(file.path(data_dir, "analysis_panel.rds"))
results   <- readRDS(file.path(data_dir, "main_results.rds"))
np        <- readRDS(file.path(data_dir, "np_clean.rds"))

tryCatch({
  robustness <- readRDS(file.path(data_dir, "robustness_results.rds"))
}, error = function(e) robustness <<- NULL)

## ─────────────────────────────────────────────────────────────
## Figure 1: Treatment timing histogram
## ─────────────────────────────────────────────────────────────

np_by_year <- np %>%
  filter(!is.na(referendum_year)) %>%
  count(referendum_year, name = "n_plans")

fig1 <- ggplot(np_by_year, aes(x = referendum_year, y = n_plans)) +
  geom_col(fill = "#2c7bb6", alpha = 0.85) +
  geom_text(aes(label = n_plans), vjust = -0.5, size = 3) +
  scale_x_continuous(breaks = 2013:2024) +
  labs(
    title = "Staggered Adoption of Neighbourhood Plans in England",
    subtitle = "Number of plans formally adopted by referendum year, 2013-2024",
    x = "Referendum Year", y = "Number of Plans Made",
    caption = "Source: MHCLG/Locality Neighbourhood Planning Data (March 2024)"
  ) +
  theme_apep()

ggsave(file.path(fig_dir, "fig1_treatment_timing.pdf"), fig1, width = 8, height = 5)
cat("Figure 1 saved.\n")

## ─────────────────────────────────────────────────────────────
## Figure 2: House price trends - treated vs control
## ─────────────────────────────────────────────────────────────

trends <- panel %>%
  mutate(group = ifelse(first_treat > 0, "Treated (Ever NP)", "Never Treated")) %>%
  group_by(group, year) %>%
  summarise(
    median_price = median(median_price, na.rm = TRUE),
    .groups = "drop"
  )

fig2 <- ggplot(trends, aes(x = year, y = median_price / 1000, color = group, linetype = group)) +
  geom_line(linewidth = 1.1) +
  geom_point(size = 2) +
  annotate("rect", xmin = 2013, xmax = 2024, ymin = -Inf, ymax = Inf,
           alpha = 0.08, fill = "grey40") +
  annotate("text", x = 2018.5, y = Inf, label = "Treatment period",
           vjust = 1.5, color = "grey40", size = 3.5) +
  scale_color_manual(values = c("Treated (Ever NP)" = "#d7191c",
                                 "Never Treated" = "#2c7bb6")) +
  scale_y_continuous(labels = scales::comma) +
  labs(
    title = "House Price Trends: Treated vs. Control Districts",
    subtitle = "Median transaction price by treatment status (GBP thousands)",
    x = "Year", y = "Median Price (GBP 000s)",
    color = NULL, linetype = NULL,
    caption = "Source: HM Land Registry Price Paid Data. Treatment = first NP adopted."
  ) +
  theme_apep()

ggsave(file.path(fig_dir, "fig2_price_trends.pdf"), fig2, width = 8, height = 5.5)
cat("Figure 2 saved.\n")

## ─────────────────────────────────────────────────────────────
## Figure 3: CS Event Study (main specification)
## ─────────────────────────────────────────────────────────────

cs_es <- results$cs_es

es_df <- tibble(
  rel_year = cs_es$egt,
  att = cs_es$att.egt,
  se = cs_es$se.egt
) %>%
  mutate(
    ci_lower = att - 1.96 * se,
    ci_upper = att + 1.96 * se
  )

fig3 <- ggplot(es_df, aes(x = rel_year, y = att)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
  geom_vline(xintercept = -0.5, linetype = "dotted", color = "grey40") +
  geom_ribbon(aes(ymin = ci_lower, ymax = ci_upper), alpha = 0.2, fill = "#2c7bb6") +
  geom_point(size = 2.5, color = "#2c7bb6") +
  geom_line(color = "#2c7bb6", linewidth = 0.7) +
  labs(
    title = "Event Study: Effect of Neighbourhood Plans on House Prices",
    subtitle = "Callaway-Sant'Anna (2021) estimates with 95% CI, not-yet-treated controls",
    x = "Years Relative to First NP Adoption", y = "ATT (Log Median Price)",
    caption = "Source: Authors' calculations. Doubly-robust estimation."
  ) +
  theme_apep()

ggsave(file.path(fig_dir, "fig3_event_study_cs.pdf"), fig3, width = 8, height = 5.5)
cat("Figure 3 saved.\n")

## ─────────────────────────────────────────────────────────────
## Figure 4: CS Event Study with never-treated controls
## ─────────────────────────────────────────────────────────────

cs_never_es <- results$cs_never_es

es_never_df <- tibble(
  rel_year = cs_never_es$egt,
  att = cs_never_es$att.egt,
  se = cs_never_es$se.egt
) %>%
  mutate(
    ci_lower = att - 1.96 * se,
    ci_upper = att + 1.96 * se
  )

fig4 <- ggplot(es_never_df, aes(x = rel_year, y = att)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
  geom_vline(xintercept = -0.5, linetype = "dotted", color = "grey40") +
  geom_ribbon(aes(ymin = ci_lower, ymax = ci_upper), alpha = 0.2, fill = "#d7191c") +
  geom_point(size = 2.5, color = "#d7191c") +
  geom_line(color = "#d7191c", linewidth = 0.7) +
  labs(
    title = "Event Study: Never-Treated Controls",
    subtitle = "Callaway-Sant'Anna (2021) estimates with 95% CI",
    x = "Years Relative to First NP Adoption", y = "ATT (Log Median Price)",
    caption = "Source: Authors' calculations. Control group = never-treated LAs only."
  ) +
  theme_apep()

ggsave(file.path(fig_dir, "fig4_event_study_never_treated.pdf"), fig4, width = 8, height = 5.5)
cat("Figure 4 saved.\n")

## ─────────────────────────────────────────────────────────────
## Figure 5: Group-level ATTs (cohort heterogeneity)
## ─────────────────────────────────────────────────────────────

cs_group <- results$cs_group

group_df <- tibble(
  cohort = cs_group$egt,
  att = cs_group$att.egt,
  se = cs_group$se.egt
) %>%
  mutate(
    ci_lower = att - 1.96 * se,
    ci_upper = att + 1.96 * se
  )

fig5 <- ggplot(group_df, aes(x = factor(cohort), y = att)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
  geom_pointrange(aes(ymin = ci_lower, ymax = ci_upper),
                  color = "#2c7bb6", size = 0.6) +
  labs(
    title = "Treatment Effects by Adoption Cohort",
    subtitle = "Cohort-specific ATTs with 95% CI",
    x = "First NP Adoption Year (Cohort)", y = "ATT (Log Median Price)",
    caption = "Source: Authors' calculations."
  ) +
  theme_apep() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

ggsave(file.path(fig_dir, "fig5_cohort_effects.pdf"), fig5, width = 8, height = 5.5)
cat("Figure 5 saved.\n")

## ─────────────────────────────────────────────────────────────
## Figure 6: Randomization inference
## ─────────────────────────────────────────────────────────────

if (!is.null(robustness) && !is.null(robustness$ri_distribution)) {
  ri_df <- tibble(coef = robustness$ri_distribution)
  actual_coef <- robustness$twfe_actual

  fig6 <- ggplot(ri_df, aes(x = coef)) +
    geom_histogram(bins = 50, fill = "grey70", color = "white") +
    geom_vline(xintercept = actual_coef, color = "#d7191c", linewidth = 1.2, linetype = "solid") +
    geom_vline(xintercept = -actual_coef, color = "#d7191c", linewidth = 0.8, linetype = "dashed") +
    annotate("text", x = actual_coef, y = Inf, label = "Actual estimate",
             color = "#d7191c", vjust = 1.5, hjust = -0.1, size = 3.5) +
    labs(
      title = "Randomization Inference: Permutation Distribution",
      subtitle = sprintf("500 permutations of treatment timing (RI p-value = %.3f)",
                         robustness$ri_pvalue),
      x = "TWFE Coefficient (Permuted)", y = "Frequency",
      caption = "Red line = actual estimate. Distribution = random assignment of treatment timing."
    ) +
    theme_apep()

  ggsave(file.path(fig_dir, "fig6_randomization_inference.pdf"), fig6, width = 8, height = 5)
  cat("Figure 6 saved.\n")
} else {
  cat("Skipping Figure 6 (no RI results).\n")
}

## ─────────────────────────────────────────────────────────────
## Figure 7: Referendum characteristics
## ─────────────────────────────────────────────────────────────

np_ref <- np %>%
  filter(!is.na(yes_pct), !is.na(turnout_pct))

fig7 <- ggplot(np_ref, aes(x = turnout_pct, y = yes_pct)) +
  geom_point(alpha = 0.3, size = 1.5, color = "#2c7bb6") +
  geom_smooth(method = "loess", se = TRUE, color = "#d7191c", fill = "#d7191c", alpha = 0.15) +
  geom_hline(yintercept = 50, linetype = "dashed", color = "grey50") +
  labs(
    title = "Neighbourhood Plan Referendum Characteristics",
    subtitle = "Each point = one referendum. Red line = LOESS fit.",
    x = "Turnout (%)", y = "Yes Vote (%)",
    caption = "Source: MHCLG/Locality. Horizontal line = 50% threshold."
  ) +
  theme_apep()

ggsave(file.path(fig_dir, "fig7_referendum_scatter.pdf"), fig7, width = 7, height = 5)
cat("Figure 7 saved.\n")

cat("\nAll figures generated.\n")
