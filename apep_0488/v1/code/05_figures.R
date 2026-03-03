## =============================================================================
## apep_0488: The Welfare Cost of PDMPs — Sufficient Statistics Approach
## 05_figures.R: Generate all figures
## =============================================================================

source("00_packages.R")

results <- readRDS(file.path(DATA_DIR, "analysis_results.rds"))
panel <- readRDS(file.path(DATA_DIR, "panel_prescribing.rds"))
policy <- readRDS(file.path(DATA_DIR, "policy_dates.rds"))

## ---------------------------------------------------------------------------
## Figure 1: PDMP adoption timeline
## ---------------------------------------------------------------------------
cat("=== Figure 1: PDMP adoption timeline ===\n")

adoption <- policy %>%
  filter(!is.na(must_access_year)) %>%
  count(must_access_year) %>%
  mutate(cumulative = cumsum(n))

fig1 <- ggplot(adoption, aes(x = must_access_year)) +
  geom_col(aes(y = n), fill = "#2171b5", alpha = 0.7, width = 0.7) +
  geom_line(aes(y = cumulative), colour = "#cb181d", linewidth = 1) +
  geom_point(aes(y = cumulative), colour = "#cb181d", size = 2) +
  scale_x_continuous(breaks = 2012:2020) +
  scale_y_continuous(sec.axis = sec_axis(~ ., name = "Cumulative states")) +
  labs(
    title = "Staggered Adoption of Must-Access PDMP Mandates",
    x = "Year of Adoption",
    y = "Number of States"
  ) +
  annotate("text", x = 2018.8, y = max(adoption$cumulative) - 1,
           label = "Cumulative\n(right axis)", colour = "#cb181d",
           size = 2.8, hjust = 0.5) +
  theme(plot.margin = margin(5.5, 15, 5.5, 5.5))

ggsave(file.path(FIG_DIR, "fig1_adoption_timeline.pdf"),
       fig1, width = 7, height = 4.5)
cat("  Saved fig1_adoption_timeline.pdf\n")

## ---------------------------------------------------------------------------
## Figure 2: Event study — opioid prescribing rate (CS-DiD)
## ---------------------------------------------------------------------------
cat("=== Figure 2: Event study (CS-DiD) ===\n")

es <- results$agg_dynamic
es_df <- tibble(
  e = es$egt,
  att = es$att.egt,
  se = es$se.egt,
  ci_lower = att - 1.96 * se,
  ci_upper = att + 1.96 * se
)

fig2 <- ggplot(es_df, aes(x = e, y = att)) +
  geom_hline(yintercept = 0, linetype = "dashed", colour = "grey50") +
  geom_vline(xintercept = -0.5, linetype = "dotted", colour = "grey70") +
  geom_ribbon(aes(ymin = ci_lower, ymax = ci_upper), alpha = 0.15, fill = "#2171b5") +
  geom_line(colour = "#2171b5", linewidth = 0.8) +
  geom_point(colour = "#2171b5", size = 2) +
  labs(
    title = "Effect of Must-Access PDMP on Opioid Prescribing Rate",
    subtitle = "Callaway-Sant'Anna dynamic ATT estimates",
    x = "Years Relative to Must-Access PDMP Adoption",
    y = "ATT (Opioid Prescribing Rate, pp)"
  ) +
  annotate("text", x = min(es_df$e) + 0.5, y = max(es_df$ci_upper, na.rm = TRUE),
           label = "Pre-treatment", size = 3, colour = "grey40", hjust = 0) +
  annotate("text", x = max(es_df$e) - 0.5, y = min(es_df$ci_lower, na.rm = TRUE),
           label = "Post-treatment", size = 3, colour = "grey40", hjust = 1)

ggsave(file.path(FIG_DIR, "fig2_event_study_opioid_rate.pdf"),
       fig2, width = 7, height = 5)
cat("  Saved fig2_event_study_opioid_rate.pdf\n")

## ---------------------------------------------------------------------------
## Figure 3: Event study — prescriber share (extensive margin)
## ---------------------------------------------------------------------------
cat("=== Figure 3: Event study (prescriber share) ===\n")

es_presc <- results$agg_prescriber_dynamic
es_presc_df <- tibble(
  e = es_presc$egt,
  att = es_presc$att.egt,
  se = es_presc$se.egt,
  ci_lower = att - 1.96 * se,
  ci_upper = att + 1.96 * se
)

fig3 <- ggplot(es_presc_df, aes(x = e, y = att)) +
  geom_hline(yintercept = 0, linetype = "dashed", colour = "grey50") +
  geom_vline(xintercept = -0.5, linetype = "dotted", colour = "grey70") +
  geom_ribbon(aes(ymin = ci_lower, ymax = ci_upper), alpha = 0.15, fill = "#238b45") +
  geom_line(colour = "#238b45", linewidth = 0.8) +
  geom_point(colour = "#238b45", size = 2) +
  labs(
    title = "Effect of Must-Access PDMP on Opioid Prescriber Share",
    subtitle = "Callaway-Sant'Anna dynamic ATT (extensive margin)",
    x = "Years Relative to Must-Access PDMP Adoption",
    y = "ATT (Share of Prescribers with Any Opioid)"
  )

ggsave(file.path(FIG_DIR, "fig3_event_study_prescriber.pdf"),
       fig3, width = 7, height = 5)
cat("  Saved fig3_event_study_prescriber.pdf\n")

## ---------------------------------------------------------------------------
## Figure 4: Welfare bounds under alternative behavioral models
## ---------------------------------------------------------------------------
cat("=== Figure 4: Welfare bounds ===\n")

wp <- results$welfare_params

# Corrected welfare formula: Net = ē + γ(1-λ) - v_L·λ
# where γ = (1-β)·δK is the internality, λ = targeting parameter
lambda_target <- 0.70   # Share of Rx reduction on legitimate pain patients
v_L <- 7500             # Pain cost per legitimate patient denied
e_bar <- 500            # Externality per prevented Rx

betas <- seq(0, 1, by = 0.01)
welfare_df <- tibble(
  beta = betas,
  gamma = (1 - betas) * wp$PV_addiction_cost,
  welfare_per_rx = e_bar + gamma * (1 - lambda_target) - v_L * lambda_target
) %>%
  mutate(
    model = case_when(
      beta == 1 ~ "Rational Addiction\n(Becker-Murphy)",
      beta == 0.7 ~ "Moderate Present Bias\n(Gruber-Koszegi)",
      beta == 0.5 ~ "Strong Present Bias",
      beta == 0 ~ "Cue-Triggered\n(Bernheim-Rangel)",
      TRUE ~ NA_character_
    )
  )

benchmarks <- welfare_df %>% filter(!is.na(model))

fig4 <- ggplot(welfare_df, aes(x = beta, y = welfare_per_rx / 1000)) +
  geom_hline(yintercept = 0, linetype = "dashed", colour = "grey50", linewidth = 0.5) +
  geom_line(colour = "#756bb1", linewidth = 1.2) +
  geom_point(data = benchmarks, colour = "#756bb1", size = 3) +
  geom_label(data = benchmarks, aes(label = model),
             size = 2.3, nudge_y = -1.5, fill = "white", alpha = 0.8,
             label.padding = unit(0.15, "lines")) +
  labs(
    title = "Welfare Effect of PDMP per Prescription Reduced",
    subtitle = "Under alternative behavioral models of addiction",
    x = expression(paste("Present bias parameter (", beta, "): 0 = full bias, 1 = rational")),
    y = "Net Welfare per Rx Reduced ($1,000s)"
  ) +
  annotate("rect", xmin = 0.5, xmax = 0.8, ymin = -Inf, ymax = Inf,
           fill = "#238b45", alpha = 0.05) +
  annotate("text", x = 0.65, y = max(welfare_df$welfare_per_rx / 1000) * 0.9,
           label = "Literature\nconsensus\nrange", colour = "#238b45",
           size = 3, fontface = "italic")

ggsave(file.path(FIG_DIR, "fig4_welfare_bounds.pdf"),
       fig4, width = 7, height = 5.5)
cat("  Saved fig4_welfare_bounds.pdf\n")

## ---------------------------------------------------------------------------
## Figure 5: Raw trends — treated vs. control states
## ---------------------------------------------------------------------------
cat("=== Figure 5: Raw trends ===\n")

panel_trends <- panel %>%
  mutate(
    group = case_when(
      is.na(must_access_year) ~ "Never treated",
      must_access_year <= 2016 ~ "Early adopters (2012-2016)",
      TRUE ~ "Late adopters (2017-2019)"
    )
  )

trends <- panel_trends %>%
  group_by(group, year) %>%
  summarise(
    mean_opioid_rate = mean(opioid_rate, na.rm = TRUE),
    se = sd(opioid_rate, na.rm = TRUE) / sqrt(n()),
    .groups = "drop"
  )

fig5 <- ggplot(trends, aes(x = year, y = mean_opioid_rate, colour = group, fill = group)) +
  geom_ribbon(aes(ymin = mean_opioid_rate - 1.96 * se,
                  ymax = mean_opioid_rate + 1.96 * se),
              alpha = 0.1, colour = NA) +
  geom_line(linewidth = 0.8) +
  geom_point(size = 1.5) +
  scale_colour_manual(values = c(
    "Never treated" = "grey50",
    "Early adopters (2012-2016)" = "#cb181d",
    "Late adopters (2017-2019)" = "#2171b5"
  )) +
  scale_fill_manual(values = c(
    "Never treated" = "grey50",
    "Early adopters (2012-2016)" = "#cb181d",
    "Late adopters (2017-2019)" = "#2171b5"
  )) +
  labs(
    title = "Opioid Prescribing Rate by PDMP Adoption Status",
    x = "Year",
    y = "Opioid Prescribing Rate (%)",
    colour = NULL, fill = NULL
  )

ggsave(file.path(FIG_DIR, "fig5_raw_trends.pdf"),
       fig5, width = 7, height = 5)
cat("  Saved fig5_raw_trends.pdf\n")

## ---------------------------------------------------------------------------
## Figure 6: Leave-one-out sensitivity
## ---------------------------------------------------------------------------
cat("=== Figure 6: Leave-one-out ===\n")

if (file.exists(file.path(DATA_DIR, "robustness_results.rds"))) {
  rob <- readRDS(file.path(DATA_DIR, "robustness_results.rds"))

  loo <- rob$loo_results
  main_coef <- coef(results$twfe_rate)["pdmp_active"]

  fig6 <- ggplot(loo, aes(x = reorder(dropped_state, coef), y = coef)) +
    geom_hline(yintercept = main_coef, linetype = "dashed", colour = "#cb181d") +
    geom_hline(yintercept = 0, linetype = "solid", colour = "grey70") +
    geom_pointrange(aes(ymin = coef - 1.96 * se, ymax = coef + 1.96 * se),
                    size = 0.5, colour = "#2171b5") +
    coord_flip() +
    labs(
      title = "Leave-One-Out Sensitivity",
      subtitle = "Effect on opioid prescribing rate when each large state is dropped",
      x = "Dropped State",
      y = "PDMP Coefficient (pp)"
    ) +
    annotate("text", x = 0.5, y = main_coef, label = "Main estimate",
             colour = "#cb181d", size = 3, hjust = -0.1, vjust = -0.5)

  ggsave(file.path(FIG_DIR, "fig6_leave_one_out.pdf"),
         fig6, width = 6, height = 4)
  cat("  Saved fig6_leave_one_out.pdf\n")
}

cat("\n=== All figures generated ===\n")
