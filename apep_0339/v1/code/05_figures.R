## ============================================================================
## 05_figures.R — All figure generation
## Paper: State Minimum Wage Increases and the Medicaid Home Care Workforce
## ============================================================================

source("00_packages.R")

DATA <- "../data"
FIGS <- "../figures"
dir.create(FIGS, showWarnings = FALSE)

## ---- Load data ----
panel <- readRDS(file.path(DATA, "panel_hcbs_annual.rds"))
panel_monthly <- readRDS(file.path(DATA, "panel_hcbs_clean.rds"))
results <- readRDS(file.path(DATA, "main_results.rds"))
robust <- readRDS(file.path(DATA, "robustness_results.rds"))
mw_annual <- readRDS(file.path(DATA, "mw_annual.rds"))

## ---- Figure 1: Treatment Rollout Map ----
cat("Figure 1: Treatment rollout map...\n")

states_sf <- states(cb = TRUE, year = 2022)
states_lower48 <- states_sf %>%
  filter(!STATEFP %in% c("02", "15", "72", "78", "60", "66", "69"))

# Get first treatment year per state
first_treat <- panel[, .(first_treat_year = first(first_treat_year)), by = state]
first_treat[, STUSPS := state]

states_map <- states_lower48 %>%
  left_join(as.data.frame(first_treat), by = "STUSPS") %>%
  mutate(
    treatment_label = case_when(
      is.na(first_treat_year) | first_treat_year == 0 ~ "Federal Minimum\n($7.25, no change)",
      first_treat_year == 2018 ~ "2018",
      first_treat_year == 2019 ~ "2019",
      first_treat_year == 2020 ~ "2020",
      first_treat_year == 2021 ~ "2021",
      first_treat_year == 2022 ~ "2022",
      first_treat_year == 2023 ~ "2023",
      first_treat_year == 2024 ~ "2024",
      TRUE ~ as.character(first_treat_year)
    ),
    treatment_label = factor(treatment_label,
                             levels = c("2018","2019","2020","2021","2022","2023","2024",
                                        "Federal Minimum\n($7.25, no change)"))
  )

p1 <- ggplot(states_map) +
  geom_sf(aes(fill = treatment_label), color = "white", linewidth = 0.3) +
  scale_fill_manual(
    name = "First MW Increase",
    values = c("2018" = "#08306B", "2019" = "#2171B5", "2020" = "#4292C6",
               "2021" = "#6BAED6", "2022" = "#9ECAE1", "2023" = "#C6DBEF",
               "2024" = "#DEEBF7",
               "Federal Minimum\n($7.25, no change)" = "#D55E00"),
    na.value = "grey80"
  ) +
  labs(
    caption = "Source: FRED state minimum wage series. Orange states remained at the federal minimum ($7.25) throughout."
  ) +
  theme_void() +
  theme(
    legend.position = "bottom",
    legend.key.width = unit(0.8, "cm"),
    legend.key.height = unit(0.5, "cm"),
    plot.caption = element_text(size = 8, color = "grey50", hjust = 0.5)
  ) +
  guides(fill = guide_legend(nrow = 1))

ggsave(file.path(FIGS, "fig1_treatment_map.pdf"), p1, width = 10, height = 7)

## ---- Figure 2: Parallel Trends (Raw Outcome by Cohort) ----
cat("Figure 2: Parallel trends...\n")

# Group states into: never-treated, early-treated (2018-2020), late-treated (2021-2024)
panel[, treat_group := fcase(
  first_treat_year == 0, "Never Treated (Federal MW)",
  first_treat_year <= 2020, "Early Adopter (2018\u20132020)",
  first_treat_year >= 2021, "Late Adopter (2021\u20132024)"
)]

cohort_means <- panel[, .(
  mean_providers = mean(providers_per_100k, na.rm = TRUE),
  mean_spending = mean(spending_per_capita, na.rm = TRUE),
  n_states = uniqueN(state)
), by = .(year, treat_group)]

p2 <- ggplot(cohort_means, aes(x = year, y = mean_providers, color = treat_group, group = treat_group)) +
  geom_line(linewidth = 0.9) +
  geom_point(size = 2.5) +
  geom_vline(xintercept = 2019.5, linetype = "dotted", color = "grey50") +
  annotate("text", x = 2019.3, y = max(cohort_means$mean_providers, na.rm = TRUE) * 0.95,
           label = "Typical first\ntreatment", size = 3, hjust = 1, color = "grey40") +
  scale_color_manual(values = c("Early Adopter (2018\u20132020)" = apep_colors[1],
                                "Late Adopter (2021\u20132024)" = apep_colors[3],
                                "Never Treated (Federal MW)" = apep_colors[2]),
                     name = "") +
  labs(
    x = "Year",
    y = "HCBS Providers per 100,000",
    caption = "Source: T-MSIS Medicaid Provider Spending (2018\u20132024), NPPES, Census ACS."
  ) +
  theme_apep() +
  theme(legend.position = "bottom")

ggsave(file.path(FIGS, "fig2_parallel_trends.pdf"), p2, width = 8, height = 5.5)

## ---- Figure 3: Event Study (Main Result) ----
cat("Figure 3: Event study...\n")

es <- results$es_providers
es_df <- data.table(
  event_time = es$egt,
  att = es$att.egt,
  se = es$se.egt
)
es_df[, ci_low := att - 1.96 * se]
es_df[, ci_high := att + 1.96 * se]

p3 <- ggplot(es_df, aes(x = event_time, y = att)) +
  geom_ribbon(aes(ymin = ci_low, ymax = ci_high),
              alpha = 0.2, fill = apep_colors[1]) +
  geom_point(color = apep_colors[1], size = 2.5) +
  geom_line(color = apep_colors[1], linewidth = 0.7) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
  geom_vline(xintercept = -0.5, linetype = "dotted", color = "grey60") +
  labs(
    x = "Years Relative to First Minimum Wage Increase",
    y = "ATT (Log HCBS Providers)",
    caption = "Source: T-MSIS (2018\u20132024). Control group: never-treated states. Reference period: t = \u22121."
  ) +
  theme_apep() +
  scale_x_continuous(breaks = seq(-5, 5, 1))

ggsave(file.path(FIGS, "fig3_event_study_providers.pdf"), p3, width = 8, height = 5)

## ---- Figure 4: Event Study — Spending ----
cat("Figure 4: Event study (spending)...\n")

es_s <- results$es_spending
es_s_df <- data.table(
  event_time = es_s$egt,
  att = es_s$att.egt,
  se = es_s$se.egt
)
es_s_df[, ci_low := att - 1.96 * se]
es_s_df[, ci_high := att + 1.96 * se]

p4 <- ggplot(es_s_df, aes(x = event_time, y = att)) +
  geom_ribbon(aes(ymin = ci_low, ymax = ci_high),
              alpha = 0.2, fill = apep_colors[3]) +
  geom_point(color = apep_colors[3], size = 2.5) +
  geom_line(color = apep_colors[3], linewidth = 0.7) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
  geom_vline(xintercept = -0.5, linetype = "dotted", color = "grey60") +
  labs(
    x = "Years Relative to First Minimum Wage Increase",
    y = "ATT (Log HCBS Spending)",
    caption = "Source: T-MSIS (2018\u20132024). Control group: never-treated states."
  ) +
  theme_apep() +
  scale_x_continuous(breaks = seq(-5, 5, 1))

ggsave(file.path(FIGS, "fig4_event_study_spending.pdf"), p4, width = 8, height = 5)

## ---- Figure 5: Cohort-Specific ATTs ----
cat("Figure 5: Cohort-specific ATTs...\n")

group_agg <- results$group_providers
group_df <- data.table(
  cohort = group_agg$egt,
  att = group_agg$att.egt,
  se = group_agg$se.egt
)
group_df[, ci_low := att - 1.96 * se]
group_df[, ci_high := att + 1.96 * se]

p5 <- ggplot(group_df, aes(x = factor(cohort), y = att)) +
  geom_point(color = apep_colors[1], size = 3) +
  geom_errorbar(aes(ymin = ci_low, ymax = ci_high),
                width = 0.2, color = apep_colors[1], linewidth = 0.6) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
  labs(
    x = "Treatment Cohort (Year of First MW Increase)",
    y = "ATT (Log HCBS Providers)"
  ) +
  theme_apep()

ggsave(file.path(FIGS, "fig5_cohort_atts.pdf"), p5, width = 7, height = 5)

## ---- Figure 6: Falsification (Non-HCBS Event Study) ----
cat("Figure 6: Falsification...\n")

es_nh <- robust$falsification_nonhcbs$es
es_nh_df <- data.table(
  event_time = es_nh$egt,
  att = es_nh$att.egt,
  se = es_nh$se.egt
)
es_nh_df[, ci_low := att - 1.96 * se]
es_nh_df[, ci_high := att + 1.96 * se]

p6 <- ggplot(es_nh_df, aes(x = event_time, y = att)) +
  geom_ribbon(aes(ymin = ci_low, ymax = ci_high),
              alpha = 0.2, fill = apep_colors[2]) +
  geom_point(color = apep_colors[2], size = 2.5) +
  geom_line(color = apep_colors[2], linewidth = 0.7) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
  geom_vline(xintercept = -0.5, linetype = "dotted", color = "grey60") +
  labs(
    x = "Years Relative to MW Increase",
    y = "ATT (Log Non-HCBS Providers)",
    caption = "Source: T-MSIS (2018\u20132024). Non-HCBS = CPT codes (physician services)."
  ) +
  theme_apep() +
  scale_x_continuous(breaks = seq(-5, 5, 1))

ggsave(file.path(FIGS, "fig6_falsification.pdf"), p6, width = 8, height = 5)

## ---- Figure 7: Leave-One-Out Sensitivity ----
cat("Figure 7: Leave-one-out...\n")

if (!is.null(robust$leave_one_out)) {
  loo_dt <- robust$leave_one_out

  # Add full-sample ATT for reference
  full_att <- results$att_providers$overall.att

  p7 <- ggplot(loo_dt, aes(x = reorder(dropped_state, att), y = att)) +
    geom_point(color = apep_colors[1], size = 2) +
    geom_errorbar(aes(ymin = att - 1.96 * se, ymax = att + 1.96 * se),
                  width = 0.3, color = apep_colors[1], linewidth = 0.4) +
    geom_hline(yintercept = full_att, linetype = "dashed", color = apep_colors[2], linewidth = 0.8) +
    geom_hline(yintercept = 0, linetype = "dotted", color = "grey50") +
    coord_flip() +
    labs(
      x = "Dropped State",
      y = "ATT (Log HCBS Providers)"
    ) +
    theme_apep()

  ggsave(file.path(FIGS, "fig7_leave_one_out.pdf"), p7, width = 7, height = 8)
}

## ---- Figure 8: Minimum Wage Levels Over Time ----
cat("Figure 8: MW levels over time...\n")

# Show MW trajectories for selected states
highlight_states <- c("CA", "WA", "NY", "FL", "TX", "OH", "GA")
mw_plot <- mw_annual[state_abbr %in% highlight_states & year >= 2017 & year <= 2024]

p8 <- ggplot(mw_plot, aes(x = year, y = min_wage, color = state_abbr, group = state_abbr)) +
  geom_line(linewidth = 0.9) +
  geom_point(size = 2) +
  geom_hline(yintercept = 7.25, linetype = "dashed", color = "grey60") +
  annotate("text", x = 2017.2, y = 7.5, label = "Federal minimum ($7.25)",
           size = 3, hjust = 0, color = "grey40") +
  scale_color_manual(values = c("CA" = "#0072B2", "WA" = "#009E73",
                                "NY" = "#CC79A7", "FL" = "#E69F00",
                                "TX" = "#D55E00", "OH" = "#56B4E9",
                                "GA" = "#999999"),
                     name = "State") +
  labs(
    x = "Year",
    y = "Minimum Wage ($/hour)",
    caption = "Source: FRED state minimum wage series."
  ) +
  theme_apep()

ggsave(file.path(FIGS, "fig8_mw_trajectories.pdf"), p8, width = 8, height = 5)

## ---- Figure 9: Robustness Summary ----
cat("Figure 9: Robustness summary...\n")

# Compile robustness ATTs
rob_summary <- data.table(
  specification = c("Main (CS, never-treated)",
                    "Not-yet-treated control",
                    "Anticipation = 1 year",
                    "Restricted (>=3 pre-periods)",
                    "Falsification (non-HCBS)"),
  att = c(results$att_providers$overall.att,
          robust$not_yet_treated$agg$overall.att,
          robust$anticipation$agg$overall.att,
          if (!is.null(robust$restricted)) robust$restricted$agg$overall.att else NA_real_,
          robust$falsification_nonhcbs$agg$overall.att),
  se = c(results$att_providers$overall.se,
         robust$not_yet_treated$agg$overall.se,
         robust$anticipation$agg$overall.se,
         if (!is.null(robust$restricted)) robust$restricted$agg$overall.se else NA_real_,
         robust$falsification_nonhcbs$agg$overall.se)
)
rob_summary <- rob_summary[!is.na(att)]
rob_summary[, ci_low := att - 1.96 * se]
rob_summary[, ci_high := att + 1.96 * se]
rob_summary[, spec_label := factor(specification, levels = rev(specification))]

p9 <- ggplot(rob_summary, aes(x = spec_label, y = att)) +
  geom_point(color = apep_colors[1], size = 3) +
  geom_errorbar(aes(ymin = ci_low, ymax = ci_high),
                width = 0.25, color = apep_colors[1], linewidth = 0.6) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
  coord_flip() +
  labs(
    x = "",
    y = "ATT (Log HCBS Providers)"
  ) +
  theme_apep()

ggsave(file.path(FIGS, "fig9_robustness_summary.pdf"), p9, width = 8, height = 5)

cat("\n=== All figures generated ===\n")
