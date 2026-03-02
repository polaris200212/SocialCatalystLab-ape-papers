##############################################################################
# 05_figures.R — All Figure Generation
# Virtual Snow Days and the Weather-Absence Penalty for Working Parents
##############################################################################

source("code/00_packages.R")

cat("=== STEP 5: GENERATE FIGURES ===\n\n")

winter_panel <- readRDS("data/winter_panel.rds")
policy_data <- readRDS("data/policy_data.rds")
all_states <- readRDS("data/all_states.rds")

##############################################################################
# Figure 1: Map of Virtual Snow Day Policy Adoption
##############################################################################

cat("--- Figure 1: Policy Adoption Map ---\n")

tryCatch({
  states_sf <- states(cb = TRUE, year = 2020) %>%
    filter(!STATEFP %in% c("02", "15", "72", "78", "60", "66", "69")) %>%
    mutate(state_fips = as.integer(STATEFP))

  states_policy <- states_sf %>%
    left_join(all_states %>% select(state_fips, adopt_year), by = "state_fips") %>%
    mutate(
      adoption_era = case_when(
        is.na(adopt_year) ~ "Never Adopted",
        adopt_year <= 2019 ~ "Pre-COVID (2011-2019)",
        adopt_year <= 2021 ~ "During COVID (2020-2021)",
        TRUE ~ "Post-COVID (2022+)"
      ),
      adoption_era = factor(adoption_era,
                            levels = c("Pre-COVID (2011-2019)",
                                       "During COVID (2020-2021)",
                                       "Post-COVID (2022+)",
                                       "Never Adopted"))
    )

  p1 <- ggplot(states_policy) +
    geom_sf(aes(fill = adoption_era), color = "white", linewidth = 0.3) +
    scale_fill_manual(
      name = "Virtual Snow Day Authorization",
      values = c(
        "Pre-COVID (2011-2019)" = "#0072B2",
        "During COVID (2020-2021)" = "#56B4E9",
        "Post-COVID (2022+)" = "#D55E00",
        "Never Adopted" = "grey80"
      )
    ) +
    labs(
      title = "Staggered Adoption of Virtual Snow Day Laws",
      subtitle = "State authorization of virtual instruction for weather closures",
      caption = "Sources: EdWeek (2023), state legislation databases."
    ) +
    theme_void() +
    theme(
      legend.position = "bottom",
      legend.key.size = unit(0.5, "cm"),
      plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
      plot.subtitle = element_text(size = 10, color = "grey40", hjust = 0.5),
      plot.caption = element_text(size = 8, color = "grey50", hjust = 1)
    )

  ggsave("figures/fig1_adoption_map.pdf", p1, width = 10, height = 7)
  cat("  Saved figures/fig1_adoption_map.pdf\n")
}, error = function(e) {
  cat(sprintf("  Figure 1 failed: %s\n", e$message))
})

##############################################################################
# Figure 2: Treatment Rollout Timeline
##############################################################################

cat("--- Figure 2: Treatment Rollout ---\n")

rollout_df <- policy_data %>%
  arrange(adopt_year) %>%
  mutate(
    state_label = paste0(state_abbr, " (", adopt_year, ")"),
    era = case_when(
      adopt_year <= 2019 ~ "Pre-COVID",
      adopt_year <= 2021 ~ "COVID-era",
      TRUE ~ "Post-COVID"
    )
  )

p2 <- ggplot(rollout_df, aes(x = adopt_year, y = reorder(state_abbr, -adopt_year),
                              color = era)) +
  geom_point(size = 3) +
  geom_segment(aes(xend = 2024, yend = state_abbr), linewidth = 0.5, alpha = 0.3) +
  scale_color_manual(
    name = "Adoption Era",
    values = c("Pre-COVID" = "#0072B2", "COVID-era" = "#56B4E9",
               "Post-COVID" = "#D55E00")
  ) +
  geom_vline(xintercept = 2020, linetype = "dashed", color = "grey40") +
  annotate("text", x = 2020.2, y = 1, label = "COVID", size = 3, color = "grey40") +
  labs(
    title = "Virtual Snow Day Law Adoption Timeline",
    subtitle = "Year each state authorized virtual instruction for weather closures",
    x = "Year of Adoption",
    y = "",
    caption = "Note: Dashed line marks COVID-19 pandemic onset (2020)."
  ) +
  theme_apep() +
  theme(legend.position = "right")

ggsave("figures/fig2_rollout_timeline.pdf", p2, width = 9, height = 7)
cat("  Saved figures/fig2_rollout_timeline.pdf\n")

##############################################################################
# Figure 3: National Weather Absence Trends
##############################################################################

cat("--- Figure 3: National Absence Trends ---\n")

bls_nat <- tryCatch(readRDS("data/bls_national_absences.rds"), error = function(e) NULL)

if (!is.null(bls_nat)) {
  bls_winter <- bls_nat %>%
    filter(month %in% c(11, 12, 1, 2, 3)) %>%
    mutate(
      winter_season = ifelse(month >= 11, year + 1L, year)
    ) %>%
    group_by(winter_season) %>%
    summarize(
      mean_weather_abs = mean(bad_weather_abs, na.rm = TRUE),
      mean_childcare_abs = mean(childcare_abs, na.rm = TRUE),
      mean_total_emp = mean(total_employed, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    mutate(
      weather_rate = mean_weather_abs / mean_total_emp * 1000,
      childcare_rate = mean_childcare_abs / mean_total_emp * 1000
    ) %>%
    filter(winter_season >= 2006, winter_season <= 2024)

  p3 <- ggplot(bls_winter) +
    geom_line(aes(x = winter_season, y = weather_rate, color = "Bad Weather"),
              linewidth = 0.8) +
    geom_point(aes(x = winter_season, y = weather_rate, color = "Bad Weather"),
               size = 2) +
    geom_line(aes(x = winter_season, y = childcare_rate, color = "Childcare Problems"),
              linewidth = 0.8) +
    geom_point(aes(x = winter_season, y = childcare_rate, color = "Childcare Problems"),
               size = 2) +
    scale_color_manual(
      name = "Absence Reason",
      values = c("Bad Weather" = apep_colors[1], "Childcare Problems" = apep_colors[2])
    ) +
    geom_vline(xintercept = 2020, linetype = "dashed", color = "grey40") +
    labs(
      title = "National Work Absences During Winter Months",
      subtitle = "Monthly absences per 1,000 employed, November-March",
      x = "Winter Season",
      y = "Absences per 1,000 Employed",
      caption = "Source: BLS Current Population Survey. Dashed line = COVID onset."
    ) +
    theme_apep()

  ggsave("figures/fig3_national_trends.pdf", p3, width = 9, height = 5.5)
  cat("  Saved figures/fig3_national_trends.pdf\n")
}

##############################################################################
# Figure 4: Parallel Trends by Treatment Cohort
##############################################################################

cat("--- Figure 4: Parallel Trends ---\n")

cohort_trends <- winter_panel %>%
  mutate(
    cohort_group = case_when(
      !ever_treated ~ "Never Treated",
      adopt_year <= 2019 ~ "Pre-COVID Adopters",
      TRUE ~ "Post-COVID Adopters"
    )
  ) %>%
  group_by(cohort_group, winter_season) %>%
  summarize(
    mean_outcome = mean(weather_absence_proxy, na.rm = TRUE),
    se_outcome = sd(weather_absence_proxy, na.rm = TRUE) / sqrt(n()),
    mean_storms = mean(total_winter_events, na.rm = TRUE),
    .groups = "drop"
  )

p4 <- ggplot(cohort_trends,
             aes(x = winter_season, y = mean_outcome, color = cohort_group)) +
  geom_line(linewidth = 0.8) +
  geom_point(size = 2) +
  geom_ribbon(aes(ymin = mean_outcome - 1.96 * se_outcome,
                  ymax = mean_outcome + 1.96 * se_outcome,
                  fill = cohort_group), alpha = 0.15, color = NA) +
  scale_color_manual(
    name = "Group",
    values = c("Never Treated" = apep_colors[2],
               "Pre-COVID Adopters" = apep_colors[1],
               "Post-COVID Adopters" = apep_colors[3])
  ) +
  scale_fill_manual(
    name = "Group",
    values = c("Never Treated" = apep_colors[2],
               "Pre-COVID Adopters" = apep_colors[1],
               "Post-COVID Adopters" = apep_colors[3])
  ) +
  geom_vline(xintercept = 2011, linetype = "dotted", color = apep_colors[1], alpha = 0.5) +
  geom_vline(xintercept = 2020, linetype = "dashed", color = "grey40") +
  labs(
    title = "Weather Absence Proxy by Treatment Cohort",
    subtitle = "Mean outcome trends, 95% CI. Dotted = first adoption (2011), Dashed = COVID (2020)",
    x = "Winter Season",
    y = "Weather Absence Proxy",
    caption = "Note: Shaded areas show 95% confidence intervals."
  ) +
  theme_apep()

ggsave("figures/fig4_parallel_trends.pdf", p4, width = 9, height = 5.5)
cat("  Saved figures/fig4_parallel_trends.pdf\n")

##############################################################################
# Figure 5: Event Study (Callaway-Sant'Anna)
##############################################################################

cat("--- Figure 5: Event Study ---\n")

cs_results <- tryCatch(readRDS("data/cs_results.rds"), error = function(e) NULL)

if (!is.null(cs_results) && !is.null(cs_results$dynamic)) {
  es <- cs_results$dynamic
  es_df <- data.frame(
    event_time = es$egt,
    att = es$att.egt,
    se = es$se.egt
  ) %>%
    filter(event_time >= -6, event_time <= 8)

  p5 <- ggplot(es_df, aes(x = event_time, y = att)) +
    geom_ribbon(aes(ymin = att - 1.96 * se, ymax = att + 1.96 * se),
                alpha = 0.2, fill = apep_colors[1]) +
    geom_point(color = apep_colors[1], size = 2.5) +
    geom_line(color = apep_colors[1], linewidth = 0.7) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
    geom_vline(xintercept = -0.5, linetype = "dotted", color = "grey60") +
    labs(
      title = "Event Study: Effect of Virtual Snow Day Laws",
      subtitle = "Callaway-Sant'Anna ATT, 95% CI. Never-treated as control.",
      x = "Winters Relative to Adoption",
      y = "ATT (Weather Absence Proxy)",
      caption = "Note: Reference period is t = -1. Pre-treatment coefficients test parallel trends."
    ) +
    theme_apep() +
    scale_x_continuous(breaks = seq(-6, 8, 2))

  ggsave("figures/fig5_event_study.pdf", p5, width = 9, height = 5.5)
  cat("  Saved figures/fig5_event_study.pdf\n")
} else {
  cat("  No CS results available for event study plot.\n")
}

##############################################################################
# Figure 6: Storm Intensity Heterogeneity
##############################################################################

cat("--- Figure 6: Storm Heterogeneity ---\n")

storm_het <- winter_panel %>%
  mutate(
    storm_quartile = ntile(total_winter_events, 4),
    storm_label = paste0("Q", storm_quartile)
  ) %>%
  group_by(storm_quartile, storm_label, treated) %>%
  summarize(
    mean_outcome = mean(weather_absence_proxy, na.rm = TRUE),
    se = sd(weather_absence_proxy, na.rm = TRUE) / sqrt(n()),
    .groups = "drop"
  ) %>%
  mutate(treatment_status = ifelse(treated, "Post-Adoption", "Pre-Adoption"))

p6 <- ggplot(storm_het, aes(x = storm_label, y = mean_outcome,
                             fill = treatment_status)) +
  geom_col(position = "dodge", width = 0.7) +
  geom_errorbar(aes(ymin = mean_outcome - 1.96 * se,
                    ymax = mean_outcome + 1.96 * se),
                position = position_dodge(0.7), width = 0.2) +
  scale_fill_manual(
    name = "Treatment Status",
    values = c("Pre-Adoption" = apep_colors[2], "Post-Adoption" = apep_colors[1])
  ) +
  labs(
    title = "Weather Absences by Storm Intensity and Treatment Status",
    subtitle = "Mean outcome by quartile of winter storm events",
    x = "Storm Intensity Quartile",
    y = "Weather Absence Proxy",
    caption = "Note: Q1 = mildest winters, Q4 = most severe. Error bars show 95% CI."
  ) +
  theme_apep()

ggsave("figures/fig6_storm_heterogeneity.pdf", p6, width = 8, height = 5.5)
cat("  Saved figures/fig6_storm_heterogeneity.pdf\n")

##############################################################################
# Figure 7: Leave-One-Out Sensitivity
##############################################################################

cat("--- Figure 7: Leave-One-Out ---\n")

loo_results <- tryCatch(readRDS("data/loo_results.rds"), error = function(e) NULL)

if (!is.null(loo_results)) {
  loo_plot <- loo_results %>%
    left_join(all_states %>% select(state_fips, state_abbr),
              by = c("dropped_state" = "state_fips"))

  # Get baseline estimate
  baseline <- feols(
    weather_absence_proxy ~ treated | state_fips + winter_season,
    data = winter_panel %>% filter(!is.na(weather_absence_proxy)),
    cluster = ~state_fips
  )

  p7 <- ggplot(loo_plot, aes(x = reorder(state_abbr, estimate), y = estimate)) +
    geom_point(size = 2.5, color = apep_colors[1]) +
    geom_errorbar(aes(ymin = estimate - 1.96 * se, ymax = estimate + 1.96 * se),
                  width = 0.3, color = apep_colors[1]) +
    geom_hline(yintercept = coef(baseline)["treated"],
               linetype = "dashed", color = apep_colors[2]) +
    geom_hline(yintercept = 0, linetype = "solid", color = "grey60") +
    coord_flip() +
    labs(
      title = "Leave-One-Out Sensitivity Analysis",
      subtitle = "TWFE estimate dropping each treated state. Dashed = baseline.",
      x = "Dropped State",
      y = "Treatment Effect Estimate",
      caption = "Note: Each point shows the estimate when one treated state is excluded."
    ) +
    theme_apep()

  ggsave("figures/fig7_leave_one_out.pdf", p7, width = 8, height = 7)
  cat("  Saved figures/fig7_leave_one_out.pdf\n")
}

##############################################################################
# Figure 8: Randomization Inference Distribution
##############################################################################

cat("--- Figure 8: Randomization Inference ---\n")

ri_results <- tryCatch(readRDS("data/ri_results.rds"), error = function(e) NULL)

if (!is.null(ri_results)) {
  ri_df <- data.frame(estimate = ri_results$perm_dist)

  p8 <- ggplot(ri_df, aes(x = estimate)) +
    geom_histogram(bins = 50, fill = "grey70", color = "white") +
    geom_vline(xintercept = ri_results$observed, color = apep_colors[1],
               linewidth = 1, linetype = "solid") +
    geom_vline(xintercept = -ri_results$observed, color = apep_colors[1],
               linewidth = 1, linetype = "dashed") +
    annotate("text", x = ri_results$observed, y = Inf,
             label = sprintf("Observed\n(p = %.3f)", ri_results$ri_pvalue),
             vjust = 2, hjust = -0.1, size = 3.5, color = apep_colors[1]) +
    labs(
      title = "Randomization Inference: Permutation Distribution",
      subtitle = sprintf("1,000 random treatment reassignments. RI p-value = %.3f",
                         ri_results$ri_pvalue),
      x = "Permuted Treatment Effect",
      y = "Frequency",
      caption = "Note: Blue line = observed estimate. Distribution under sharp null."
    ) +
    theme_apep()

  ggsave("figures/fig8_randomization_inference.pdf", p8, width = 8, height = 5)
  cat("  Saved figures/fig8_randomization_inference.pdf\n")
}

cat("\n=== FIGURES COMPLETE ===\n")
