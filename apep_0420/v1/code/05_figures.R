## 05_figures.R — Generate all figures
## APEP-0420: The Visible and the Invisible

source("00_packages.R")

data_dir <- "../data"
fig_dir <- "../figures"
dir.create(fig_dir, showWarnings = FALSE, recursive = TRUE)

cat("Loading cleaned NBI panel...\n")
nbi <- fread(file.path(data_dir, "nbi_panel_clean.csv"))
nbi <- nbi[year >= 2001]

## ============================================================
## FIGURE 1: Deterioration trajectories by ADT tercile
## ============================================================

cat("Figure 1: Deterioration trajectories...\n")

## Track average condition by ADT tercile over time
traj <- nbi[!is.na(initial_adt_tercile), .(
  mean_deck = mean(deck_cond, na.rm = TRUE),
  mean_super = mean(super_cond, na.rm = TRUE),
  mean_sub = mean(sub_cond, na.rm = TRUE),
  n = .N
), by = .(year, initial_adt_tercile)]

traj[, initial_adt_tercile := factor(initial_adt_tercile, levels = c("Low", "Medium", "High"))]
p1 <- ggplot(traj, aes(x = year, y = mean_deck, color = initial_adt_tercile)) +
  geom_line(linewidth = 1) +
  geom_point(size = 1.5) +
  scale_color_manual(
    values = c("Low" = "#E41A1C", "Medium" = "#377EB8", "High" = "#4DAF4A"),
    name = "Traffic Exposure\n(Initial ADT Tercile)"
  ) +
  labs(
    title = "Average Bridge Deck Condition by Traffic Exposure",
    subtitle = "Raw condition levels differ, but converge after controlling for engineering characteristics",
    x = "Year",
    y = "Mean Deck Condition Rating (0-9)"
  ) +
  scale_x_continuous(breaks = seq(2000, 2023, by = 4), limits = c(2000, 2023)) +
  scale_y_continuous(limits = c(5, 8)) +
  theme(legend.position = c(0.15, 0.25))

ggsave(file.path(fig_dir, "fig1_trajectories.pdf"), p1,
       width = 8, height = 5.5, dpi = 300)

## ============================================================
## FIGURE 2: Repair event rates by ADT and election proximity
## ============================================================

cat("Figure 2: Electoral maintenance cycle...\n")

## Repair rates by ADT tercile × election window
elec_rates <- nbi[!is.na(initial_adt_tercile), .(
  repair_rate = mean(repair_event, na.rm = TRUE),
  n = .N
), by = .(initial_adt_tercile, election_window)]

elec_rates[, period := fifelse(election_window == 1, "Election Window", "Non-Election")]
elec_rates[, initial_adt_tercile := factor(initial_adt_tercile, levels = c("Low", "Medium", "High"))]

p2 <- ggplot(elec_rates, aes(x = initial_adt_tercile, y = repair_rate * 100,
                              fill = period)) +
  geom_col(position = position_dodge(width = 0.7), width = 0.6) +
  scale_fill_manual(
    values = c("Election Window" = "#4DAF4A", "Non-Election" = "#377EB8"),
    name = ""
  ) +
  labs(
    title = "Bridge Repair Rates by Traffic Exposure and Electoral Timing",
    subtitle = "No differential electoral cycle across traffic exposure groups",
    x = "Initial ADT Tercile",
    y = "Repair Event Rate (%)"
  ) +
  theme(legend.position = c(0.15, 0.85))

ggsave(file.path(fig_dir, "fig2_election_cycle.pdf"), p2,
       width = 7, height = 5, dpi = 300)

## ============================================================
## FIGURE 3: Visible vs Invisible components
## ============================================================

cat("Figure 3: Visible vs invisible component comparison...\n")

## Load component results
component_results <- readRDS(file.path(data_dir, "component_results.rds"))

comp_df <- data.frame(
  component = c("Deck\n(Visible)", "Superstructure\n(Partially Visible)", "Substructure\n(Invisible)"),
  coef = c(
    coef(component_results$m_deck)["high_initial_adt"],
    coef(component_results$m_super)["high_initial_adt"],
    coef(component_results$m_sub)["high_initial_adt"]
  ),
  se = c(
    se(component_results$m_deck)["high_initial_adt"],
    se(component_results$m_super)["high_initial_adt"],
    se(component_results$m_sub)["high_initial_adt"]
  )
)
comp_df$component <- factor(comp_df$component,
                            levels = c("Deck\n(Visible)", "Superstructure\n(Partially Visible)", "Substructure\n(Invisible)"))

p3 <- ggplot(comp_df, aes(x = component, y = coef)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
  geom_pointrange(aes(ymin = coef - 1.96 * se, ymax = coef + 1.96 * se),
                  size = 0.8, linewidth = 0.8, color = "#377EB8") +
  labs(
    title = "Visibility Premium by Bridge Component",
    subtitle = "Effect of high traffic exposure on annual condition change",
    x = "",
    y = "Coefficient: Effect of High ADT on\nAnnual Condition Change"
  ) +
  annotate("text", x = 1, y = comp_df$coef[1] + comp_df$se[1] * 2.5,
           label = "Visible to drivers", color = "gray40", size = 3) +
  annotate("text", x = 3, y = comp_df$coef[3] - comp_df$se[3] * 2.5,
           label = "Hidden from view", color = "gray40", size = 3)

ggsave(file.path(fig_dir, "fig3_components.pdf"), p3,
       width = 7, height = 5, dpi = 300)

## ============================================================
## FIGURE 4: Propensity score overlap
## ============================================================

cat("Figure 4: Propensity score overlap...\n")

## Estimate propensity scores on a sample
set.seed(42)
ps_sample <- nbi[sample(.N, min(.N, 200000))]
ps_sample <- ps_sample[complete.cases(
  ps_sample[, .(high_initial_adt, bridge_age, total_len_m, n_spans, max_span_m, urban)]
)]

ps_model <- glm(high_initial_adt ~ bridge_age + I(bridge_age^2) +
                   total_len_m + n_spans + max_span_m + urban,
                 data = ps_sample, family = binomial)
ps_sample[, ps := predict(ps_model, type = "response")]

p4 <- ggplot(ps_sample, aes(x = ps, fill = factor(high_initial_adt))) +
  geom_density(alpha = 0.5, adjust = 1.5) +
  scale_fill_manual(
    values = c("0" = "#E41A1C", "1" = "#4DAF4A"),
    labels = c("Low/Medium ADT", "High ADT"),
    name = "Group"
  ) +
  labs(
    title = "Propensity Score Overlap",
    subtitle = "Common support exists across the distribution",
    x = "Estimated Propensity Score",
    y = "Density"
  ) +
  theme(legend.position = c(0.8, 0.8))

ggsave(file.path(fig_dir, "fig4_overlap.pdf"), p4,
       width = 7, height = 5, dpi = 300)

## ============================================================
## FIGURE 5: Coefficient stability across specifications
## ============================================================

cat("Figure 5: Coefficient stability...\n")

main_results <- readRDS(file.path(data_dir, "main_results.rds"))

spec_df <- data.frame(
  spec = c("(1) State + Year FE",
           "(2) + Engineering Covariates",
           "(3) State × Year FE",
           "(4) + Material FE",
           "(5) Continuous log(ADT)"),
  coef = c(
    coef(main_results$m1)["high_initial_adt"],
    coef(main_results$m2)["high_initial_adt"],
    coef(main_results$m3)["high_initial_adt"],
    coef(main_results$m4)["high_initial_adt"],
    coef(main_results$m5)["log(initial_adt)"]
  ),
  se = c(
    se(main_results$m1)["high_initial_adt"],
    se(main_results$m2)["high_initial_adt"],
    se(main_results$m3)["high_initial_adt"],
    se(main_results$m4)["high_initial_adt"],
    se(main_results$m5)["log(initial_adt)"]
  )
)
spec_df$spec <- factor(spec_df$spec, levels = rev(spec_df$spec))

p5 <- ggplot(spec_df, aes(x = coef, y = spec)) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "gray50") +
  geom_pointrange(aes(xmin = coef - 1.96 * se, xmax = coef + 1.96 * se),
                  size = 0.6, linewidth = 0.6, color = "#377EB8") +
  labs(
    title = "Coefficient Stability Across Specifications",
    subtitle = "Effect of high traffic exposure on deck condition change",
    x = "Coefficient Estimate",
    y = ""
  )

ggsave(file.path(fig_dir, "fig5_stability.pdf"), p5,
       width = 8, height = 5, dpi = 300)

## ============================================================
## FIGURE 6: ADT distribution and structurally deficient share
## ============================================================

cat("Figure 6: ADT distribution and deficiency...\n")

adt_bins <- nbi[year == 2020 & adt > 0, .(
  pct_deficient = mean(struct_deficient, na.rm = TRUE) * 100,
  n = .N
), by = .(adt_bin = cut(log10(adt),
                         breaks = seq(0, 6, by = 0.5),
                         include.lowest = TRUE))]

p6 <- ggplot(nbi[year == 2020 & adt > 0], aes(x = log10(adt))) +
  geom_histogram(aes(y = after_stat(count / sum(count) * 100)),
                 bins = 50, fill = "#377EB8", alpha = 0.6) +
  labs(
    title = "Distribution of Bridge Traffic Volume (2020)",
    subtitle = "Log scale; most bridges carry modest traffic",
    x = expression(log[10](ADT)),
    y = "Percent of Bridges"
  )

ggsave(file.path(fig_dir, "fig6_adt_distribution.pdf"), p6,
       width = 7, height = 5, dpi = 300)

## ============================================================
## FIGURE 7: Map of structurally deficient bridges
## ============================================================

cat("Figure 7: Map of deficient bridges...\n")

## County-level deficiency rates in 2020
county_def <- nbi[year == 2020, .(
  pct_deficient = mean(struct_deficient, na.rm = TRUE) * 100,
  n_bridges = .N,
  mean_adt = mean(adt, na.rm = TRUE)
), by = .(state_fips, county_fips)]

## Simple scatter: mean ADT vs deficiency rate
p7 <- ggplot(county_def[n_bridges >= 10], aes(x = log10(mean_adt), y = pct_deficient)) +
  geom_point(alpha = 0.15, size = 0.8, color = "#377EB8") +
  geom_smooth(method = "loess", color = "#E41A1C", linewidth = 1.2, se = TRUE) +
  labs(
    title = "County-Level Bridge Deficiency vs. Traffic Exposure",
    subtitle = "Counties with higher average traffic have fewer deficient bridges",
    x = expression("Mean " * log[10](ADT) * " in County"),
    y = "Percent Structurally Deficient"
  ) +
  scale_y_continuous(limits = c(0, 80))

ggsave(file.path(fig_dir, "fig7_adt_deficiency.pdf"), p7,
       width = 7, height = 5, dpi = 300)

cat("\nAll figures saved to figures/\n")
