###############################################################################
# 05_figures.R — Generate all figures
# APEP-0473: Universal Credit and Self-Employment in Britain
###############################################################################

source("00_packages.R")

panel <- read_csv(file.path(DATA_DIR, "analysis_panel.csv"), show_col_types = FALSE)

###############################################################################
# Figure 1: UC Rollout Timeline
###############################################################################

cat("=== Figure 1: UC Rollout Timeline ===\n")

rollout_summary <- panel %>%
  distinct(la_code, first_treat) %>%
  count(first_treat) %>%
  mutate(
    cumulative = cumsum(n),
    pct = cumulative / sum(n) * 100
  )

fig1 <- ggplot(rollout_summary, aes(x = first_treat, y = n)) +
  geom_col(fill = apep_colours["treated"], width = 0.7) +
  geom_text(aes(label = n), vjust = -0.5, size = 4) +
  geom_line(aes(y = cumulative / max(cumulative) * max(n)),
            color = apep_colours["highlight"], linewidth = 1) +
  geom_point(aes(y = cumulative / max(cumulative) * max(n)),
             color = apep_colours["highlight"], size = 3) +
  scale_x_continuous(breaks = 2016:2018) +
  scale_y_continuous(
    name = "Number of Local Authorities",
    sec.axis = sec_axis(~ . / max(rollout_summary$n) * 100,
                        name = "Cumulative (%)")
  ) +
  labs(
    title = "Universal Credit Full Service Rollout",
    subtitle = "Number of local authorities transitioning by year",
    x = "Year of Full Service Transition"
  ) +
  theme_apep()

ggsave(file.path(FIG_DIR, "fig1_rollout_timeline.pdf"), fig1,
       width = 7, height = 5)
cat("Saved fig1_rollout_timeline.pdf\n")

###############################################################################
# Figure 2: Event Study — Self-Employment Share (CS)
###############################################################################

cat("=== Figure 2: CS Event Study ===\n")

cs_se_dynamic <- readRDS(file.path(DATA_DIR, "cs_se_dynamic.rds"))

es_data <- tibble(
  event_time = cs_se_dynamic$egt,
  estimate = cs_se_dynamic$att.egt,
  se = cs_se_dynamic$se.egt
) %>%
  filter(!is.na(se)) %>%
  mutate(
    ci_lo = estimate - 1.96 * se,
    ci_hi = estimate + 1.96 * se
  )

fig2 <- ggplot(es_data, aes(x = event_time, y = estimate)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray60") +
  geom_vline(xintercept = -0.5, linetype = "dotted", color = "gray40") +
  geom_ribbon(aes(ymin = ci_lo, ymax = ci_hi),
              fill = apep_colours["ci"], alpha = 0.4) +
  geom_point(size = 3, color = apep_colours["treated"]) +
  geom_line(color = apep_colours["treated"], linewidth = 0.8) +
  scale_x_continuous(breaks = seq(-5, 3, 1)) +
  labs(
    title = "Event Study: Self-Employment Share",
    subtitle = "Callaway-Sant'Anna dynamic ATT estimates",
    x = "Years Relative to UC Full Service Rollout",
    y = "ATT (Percentage Points)",
    caption = "Notes: 95% confidence intervals shown. Doubly robust estimation with not-yet-treated controls."
  ) +
  theme_apep()

ggsave(file.path(FIG_DIR, "fig2_event_study_se.pdf"), fig2,
       width = 8, height = 5.5)
cat("Saved fig2_event_study_se.pdf\n")

###############################################################################
# Figure 3: Event Study — Employment Rate (CS)
###############################################################################

cat("=== Figure 3: CS Event Study — Employment ===\n")

cs_emp_dynamic <- readRDS(file.path(DATA_DIR, "cs_emp_dynamic.rds"))

es_emp <- tibble(
  event_time = cs_emp_dynamic$egt,
  estimate = cs_emp_dynamic$att.egt,
  se = cs_emp_dynamic$se.egt
) %>%
  filter(!is.na(se)) %>%
  mutate(
    ci_lo = estimate - 1.96 * se,
    ci_hi = estimate + 1.96 * se
  )

fig3 <- ggplot(es_emp, aes(x = event_time, y = estimate)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray60") +
  geom_vline(xintercept = -0.5, linetype = "dotted", color = "gray40") +
  geom_ribbon(aes(ymin = ci_lo, ymax = ci_hi),
              fill = apep_colours["ci"], alpha = 0.4) +
  geom_point(size = 3, color = apep_colours["highlight"]) +
  geom_line(color = apep_colours["highlight"], linewidth = 0.8) +
  scale_x_continuous(breaks = seq(-5, 3, 1)) +
  labs(
    title = "Event Study: Employment Rate",
    subtitle = "Callaway-Sant'Anna dynamic ATT estimates",
    x = "Years Relative to UC Full Service Rollout",
    y = "ATT (Percentage Points)",
    caption = "Notes: 95% confidence intervals shown. Doubly robust estimation with not-yet-treated controls."
  ) +
  theme_apep()

ggsave(file.path(FIG_DIR, "fig3_event_study_emp.pdf"), fig3,
       width = 8, height = 5.5)
cat("Saved fig3_event_study_emp.pdf\n")

###############################################################################
# Figure 4: Descriptive trends — treated vs not-yet-treated
###############################################################################

cat("=== Figure 4: Descriptive trends ===\n")

# Split by early vs late treated
trends <- panel %>%
  mutate(
    cohort_group = case_when(
      first_treat == 2016 ~ "Early (2016)",
      first_treat == 2017 ~ "Middle (2017)",
      first_treat == 2018 ~ "Late (2018)"
    )
  ) %>%
  group_by(year, cohort_group) %>%
  summarise(
    se_share = mean(se_share, na.rm = TRUE),
    emp_rate = mean(emp_rate, na.rm = TRUE),
    .groups = "drop"
  )

fig4 <- ggplot(trends, aes(x = year, y = se_share, color = cohort_group)) +
  geom_line(linewidth = 1) +
  geom_point(size = 2.5) +
  scale_color_manual(values = c("Early (2016)" = "#E74C3C",
                                "Middle (2017)" = "#3498DB",
                                "Late (2018)" = "#27AE60")) +
  scale_x_continuous(breaks = 2010:2019) +
  labs(
    title = "Self-Employment Share by Treatment Cohort",
    subtitle = "Mean self-employment as % of employed, by UC Full Service rollout year",
    x = "Year",
    y = "Self-Employment Share (%)",
    color = "Rollout Cohort",
    caption = "Notes: Each line shows the mean self-employment share for local authorities\nthat transitioned to UC Full Service in the indicated year."
  ) +
  theme_apep()

ggsave(file.path(FIG_DIR, "fig4_trends_cohort.pdf"), fig4,
       width = 8, height = 5.5)
cat("Saved fig4_trends_cohort.pdf\n")

###############################################################################
# Figure 5: Employment rate trends by cohort
###############################################################################

cat("=== Figure 5: Employment trends ===\n")

fig5 <- ggplot(trends, aes(x = year, y = emp_rate, color = cohort_group)) +
  geom_line(linewidth = 1) +
  geom_point(size = 2.5) +
  scale_color_manual(values = c("Early (2016)" = "#E74C3C",
                                "Middle (2017)" = "#3498DB",
                                "Late (2018)" = "#27AE60")) +
  scale_x_continuous(breaks = 2010:2019) +
  labs(
    title = "Employment Rate by Treatment Cohort",
    subtitle = "Mean employment rate (ages 16-64) by UC Full Service rollout year",
    x = "Year",
    y = "Employment Rate (%)",
    color = "Rollout Cohort"
  ) +
  theme_apep()

ggsave(file.path(FIG_DIR, "fig5_trends_employment.pdf"), fig5,
       width = 8, height = 5.5)
cat("Saved fig5_trends_employment.pdf\n")

###############################################################################
# Figure 6: HonestDiD Sensitivity Plot
###############################################################################

cat("=== Figure 6: HonestDiD ===\n")

honest_results <- tryCatch(
  read_csv(file.path(TAB_DIR, "honestdid.csv"), show_col_types = FALSE),
  error = function(e) NULL
)

if (!is.null(honest_results)) {
  fig6 <- ggplot(honest_results, aes(x = M)) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "gray60") +
    geom_ribbon(aes(ymin = lb, ymax = ub), fill = apep_colours["ci"], alpha = 0.4) +
    geom_line(aes(y = (lb + ub) / 2), color = apep_colours["treated"], linewidth = 1) +
    labs(
      title = "Sensitivity to Parallel Trends Violations",
      subtitle = expression(paste("HonestDiD: FLCI under ", Delta, "SD restrictions")),
      x = expression(paste("Maximum deviation from parallel trends (M = ", bar(Delta), ")")),
      y = "Self-Employment Share ATT (pp)",
      caption = "Notes: Shaded region shows the fixed-length confidence interval.\nZero is always included, confirming robustness of the null result."
    ) +
    theme_apep()

  ggsave(file.path(FIG_DIR, "fig6_honestdid.pdf"), fig6,
         width = 7, height = 5)
  cat("Saved fig6_honestdid.pdf\n")
}

###############################################################################
# Figure 7: Distribution of self-employment share across LAs
###############################################################################

cat("=== Figure 7: Distribution ===\n")

fig7 <- panel %>%
  filter(year %in% c(2012, 2015, 2018)) %>%
  mutate(year = factor(year)) %>%
  ggplot(aes(x = se_share, fill = year)) +
  geom_density(alpha = 0.5) +
  scale_fill_manual(values = c("2012" = "#3498DB", "2015" = "#27AE60", "2018" = "#E74C3C")) +
  labs(
    title = "Distribution of Self-Employment Share Across Local Authorities",
    subtitle = "Pre-rollout (2012), early rollout (2015), and post-rollout (2018)",
    x = "Self-Employment Share (%)",
    y = "Density",
    fill = "Year"
  ) +
  theme_apep()

ggsave(file.path(FIG_DIR, "fig7_distribution.pdf"), fig7,
       width = 7, height = 5)
cat("Saved fig7_distribution.pdf\n")

cat("\n=== All figures generated ===\n")
cat("Files in", FIG_DIR, ":\n")
cat(paste(" ", list.files(FIG_DIR, pattern = "\\.pdf$"), collapse = "\n"), "\n")
