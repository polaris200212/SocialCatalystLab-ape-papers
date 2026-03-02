## ============================================================================
## 05_figures.R — Generate all figures
## APEP Paper: School Suicide Prevention Training Mandates
## ============================================================================

source("00_packages.R")

data_dir <- "../data"
fig_dir  <- "../figures"
dir.create(fig_dir, showWarnings = FALSE, recursive = TRUE)

panel <- read_csv(file.path(data_dir, "analysis_panel.csv"), show_col_types = FALSE)

## ============================================================================
## Figure 1: Treatment Rollout Map
## ============================================================================

cat("Creating Figure 1: Treatment rollout...\n")

# Treatment status by state
treatment_map <- panel %>%
  filter(year == max(year)) %>%
  select(state, state_abb, state_fips, first_treat) %>%
  mutate(
    treat_label = case_when(
      first_treat == 0 ~ "Never Treated",
      first_treat <= 2009 ~ "Early Adopter (2007-2009)",
      first_treat <= 2013 ~ "Middle Adopter (2010-2013)",
      TRUE ~ "Late Adopter (2014-2017)"
    ),
    treat_label = factor(treat_label, levels = c(
      "Early Adopter (2007-2009)", "Middle Adopter (2010-2013)",
      "Late Adopter (2014-2017)", "Never Treated"
    ))
  )

# Get state boundaries
tryCatch({
  states_sf <- tigris::states(cb = TRUE, year = 2017) %>%
    filter(!STATEFP %in% c("60", "66", "69", "72", "78")) %>%  # Remove territories
    shift_geometry() %>%  # Shift AK/HI
    left_join(treatment_map, by = c("STATEFP" = "state_fips"))

  p1 <- ggplot(states_sf) +
    geom_sf(aes(fill = treat_label), color = "white", linewidth = 0.3) +
    scale_fill_manual(
      values = c(
        "Early Adopter (2007-2009)" = "#D55E00",
        "Middle Adopter (2010-2013)" = "#F0E442",
        "Late Adopter (2014-2017)" = "#56B4E9",
        "Never Treated" = "grey80"
      ),
      name = "Adoption Period",
      na.value = "grey90"
    ) +
    theme_apep() +
    theme(
      axis.text = element_blank(),
      axis.ticks = element_blank(),
      axis.line = element_blank(),
      panel.grid = element_blank()
    ) +
    labs(
      title = "Staggered Adoption of School Suicide Prevention Training Mandates",
      subtitle = "State-level mandatory training laws, 2007-2017"
    )

  ggsave(file.path(fig_dir, "fig1_treatment_rollout.pdf"), p1,
         width = 10, height = 6, device = cairo_pdf)
  cat("  Figure 1 saved.\n")
}, error = function(e) {
  cat(sprintf("  Figure 1 (map) failed: %s\n", e$message))
  # Fallback: tile plot of treatment timing
  p1_alt <- panel %>%
    filter(year == max(year)) %>%
    select(state_abb, first_treat) %>%
    mutate(
      treat_year = if_else(first_treat == 0, NA_integer_, first_treat),
      state_abb = fct_reorder(state_abb, first_treat)
    ) %>%
    ggplot(aes(x = 1, y = state_abb, fill = treat_year)) +
    geom_tile(color = "white") +
    scale_fill_viridis_c(name = "Treatment Year", na.value = "grey80",
                         option = "plasma") +
    theme_apep() +
    labs(x = NULL, y = NULL,
         title = "Adoption of School Suicide Prevention Training Mandates")

  ggsave(file.path(fig_dir, "fig1_treatment_rollout.pdf"), p1_alt,
         width = 6, height = 10, device = cairo_pdf)
  cat("  Figure 1 (fallback tile plot) saved.\n")
})

## ============================================================================
## Figure 2: Raw outcome trends by treatment status
## ============================================================================

cat("Creating Figure 2: Outcome trends...\n")

# Average suicide rate by treatment group
trend_data <- panel %>%
  mutate(group = if_else(first_treat == 0, "Never Treated", "Eventually Treated")) %>%
  group_by(year, group) %>%
  summarise(
    mean_rate = mean(suicide_aadr, na.rm = TRUE),
    se_rate = sd(suicide_aadr, na.rm = TRUE) / sqrt(n()),
    .groups = "drop"
  )

p2 <- ggplot(trend_data, aes(x = year, y = mean_rate, color = group, linetype = group)) +
  geom_line(linewidth = 1) +
  geom_ribbon(aes(ymin = mean_rate - 1.96 * se_rate,
                  ymax = mean_rate + 1.96 * se_rate, fill = group),
              alpha = 0.15, linetype = 0) +
  scale_color_manual(values = c("Eventually Treated" = apep_colors[1],
                                "Never Treated" = apep_colors[2]),
                     name = NULL) +
  scale_fill_manual(values = c("Eventually Treated" = apep_colors[1],
                               "Never Treated" = apep_colors[2]),
                    name = NULL) +
  scale_linetype_manual(values = c("Eventually Treated" = "solid",
                                   "Never Treated" = "dashed"),
                        name = NULL) +
  theme_apep() +
  labs(
    x = "Year",
    y = "Age-Adjusted Suicide Rate (per 100,000)",
    title = "Suicide Rate Trends: Treated vs. Never-Treated States",
    subtitle = "Mean age-adjusted death rate with 95% CI"
  )

ggsave(file.path(fig_dir, "fig2_trends.pdf"), p2,
       width = 8, height = 5, device = cairo_pdf)
cat("  Figure 2 saved.\n")

## ============================================================================
## Figure 3: Callaway-Sant'Anna Event Study
## ============================================================================

cat("Creating Figure 3: CS event study...\n")

es_df <- read_csv(file.path(data_dir, "event_study_cs.csv"), show_col_types = FALSE)

p3 <- ggplot(es_df, aes(x = event_time, y = att)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
  geom_vline(xintercept = -0.5, linetype = "dotted", color = "grey70") +
  geom_ribbon(aes(ymin = ci_lower, ymax = ci_upper), fill = apep_colors[1], alpha = 0.2) +
  geom_line(color = apep_colors[1], linewidth = 0.8) +
  geom_point(color = apep_colors[1], size = 2.5) +
  theme_apep() +
  labs(
    x = "Years Relative to Treatment",
    y = "ATT: Change in Suicide Rate (per 100,000)",
    title = "Event Study: Effect of Suicide Prevention Training Mandates",
    subtitle = "Callaway-Sant'Anna estimator, not-yet-treated as controls"
  ) +
  annotate("text", x = -4, y = max(es_df$ci_upper, na.rm = TRUE) * 0.9,
           label = "Pre-treatment", hjust = 0, size = 3.5, color = "grey40") +
  annotate("text", x = 2, y = max(es_df$ci_upper, na.rm = TRUE) * 0.9,
           label = "Post-treatment", hjust = 0, size = 3.5, color = "grey40")

ggsave(file.path(fig_dir, "fig3_event_study.pdf"), p3,
       width = 8, height = 5, device = cairo_pdf)
cat("  Figure 3 saved.\n")

## ============================================================================
## Figure 4: Placebo event studies
## ============================================================================

cat("Creating Figure 4: Placebo event studies...\n")

placebo_heart  <- read_csv(file.path(data_dir, "event_study_placebo_heart.csv"),
                           show_col_types = FALSE)
placebo_cancer <- read_csv(file.path(data_dir, "event_study_placebo_cancer.csv"),
                           show_col_types = FALSE)

placebo_all <- bind_rows(placebo_heart, placebo_cancer) %>%
  mutate(ci_lower = att - 1.96 * se, ci_upper = att + 1.96 * se)

p4 <- ggplot(placebo_all, aes(x = event_time, y = att, color = outcome, fill = outcome)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
  geom_vline(xintercept = -0.5, linetype = "dotted", color = "grey70") +
  geom_ribbon(aes(ymin = ci_lower, ymax = ci_upper), alpha = 0.15, linetype = 0) +
  geom_line(linewidth = 0.7) +
  geom_point(size = 2) +
  scale_color_manual(values = c("Heart Disease" = apep_colors[2],
                                "Cancer" = apep_colors[3]),
                     name = "Placebo Outcome") +
  scale_fill_manual(values = c("Heart Disease" = apep_colors[2],
                               "Cancer" = apep_colors[3]),
                    name = "Placebo Outcome") +
  theme_apep() +
  labs(
    x = "Years Relative to Treatment",
    y = "ATT: Change in Death Rate (per 100,000)",
    title = "Placebo Test: Training Mandates and Non-Suicide Mortality",
    subtitle = "No effect expected; validates identification"
  )

ggsave(file.path(fig_dir, "fig4_placebo.pdf"), p4,
       width = 8, height = 5, device = cairo_pdf)
cat("  Figure 4 saved.\n")

## ============================================================================
## Figure 5: Bacon Decomposition
## ============================================================================

cat("Creating Figure 5: Bacon decomposition...\n")

bacon_file <- file.path(data_dir, "bacon_decomposition.csv")
if (file.exists(bacon_file)) {
  bacon_summary <- read_csv(bacon_file, show_col_types = FALSE)

  p5 <- ggplot(bacon_summary, aes(x = fct_reorder(type, total_weight),
                                   y = wtd_avg_estimate, size = total_weight)) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
    geom_point(color = apep_colors[1]) +
    scale_size_continuous(name = "Weight", range = c(3, 10)) +
    coord_flip() +
    theme_apep() +
    labs(
      x = NULL,
      y = "Weighted Average Estimate",
      title = "Goodman-Bacon Decomposition of TWFE Estimate",
      subtitle = "Contribution of each comparison type to the overall TWFE coefficient"
    )

  ggsave(file.path(fig_dir, "fig5_bacon.pdf"), p5,
         width = 8, height = 5, device = cairo_pdf)
  cat("  Figure 5 saved.\n")
}

## ============================================================================
## Figure 6: Leave-one-cohort-out
## ============================================================================

cat("Creating Figure 6: Leave-one-cohort-out...\n")

loco_file <- file.path(data_dir, "leave_one_cohort_out.csv")
if (file.exists(loco_file)) {
  loco <- read_csv(loco_file, show_col_types = FALSE) %>%
    mutate(ci_lower = att - 1.96 * se, ci_upper = att + 1.96 * se)

  # Get the full-sample estimate for reference
  main_results <- read_csv(file.path(data_dir, "main_results.csv"), show_col_types = FALSE)
  full_att <- main_results$att[main_results$estimator == "CS-ATT" &
                                main_results$outcome == "suicide_aadr"]

  p6 <- ggplot(loco, aes(x = factor(dropped_cohort), y = att)) +
    geom_hline(yintercept = full_att, linetype = "dashed", color = apep_colors[1],
               linewidth = 0.5) +
    geom_hline(yintercept = 0, linetype = "solid", color = "grey70") +
    geom_pointrange(aes(ymin = ci_lower, ymax = ci_upper),
                    color = apep_colors[1], size = 0.5) +
    theme_apep() +
    labs(
      x = "Dropped Treatment Cohort",
      y = "ATT (per 100,000)",
      title = "Leave-One-Cohort-Out Sensitivity",
      subtitle = "Dashed line = full sample estimate"
    )

  ggsave(file.path(fig_dir, "fig6_leave_one_out.pdf"), p6,
         width = 8, height = 5, device = cairo_pdf)
  cat("  Figure 6 saved.\n")
}

cat("\nAll figures generated.\n")
