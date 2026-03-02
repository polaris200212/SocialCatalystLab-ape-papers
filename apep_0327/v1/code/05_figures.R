## ============================================================================
## 05_figures.R — All figures for the paper
## APEP-0326: State Minimum Wage Increases and the HCBS Provider Supply Crisis
## ============================================================================

source("00_packages.R")

## ---- Load data ----
annual <- readRDS(file.path(DATA, "panel_annual.rds"))
monthly <- readRDS(file.path(DATA, "panel_monthly.rds"))
mw_data <- readRDS(file.path(DATA, "mw_panel.rds"))

# CS-DiD event study results (if available)
cs_es_providers <- tryCatch(readRDS(file.path(DATA, "cs_es_providers.rds")), error = function(e) NULL)
cs_es_benes <- tryCatch(readRDS(file.path(DATA, "cs_es_benes.rds")), error = function(e) NULL)
cs_es_placebo <- tryCatch(readRDS(file.path(DATA, "cs_es_placebo.rds")), error = function(e) NULL)
cs_es_individual <- tryCatch(readRDS(file.path(DATA, "cs_es_individual.rds")), error = function(e) NULL)
ri_results <- tryCatch(readRDS(file.path(DATA, "ri_results.rds")), error = function(e) NULL)

treated_states <- annual[first_treat_year > 0, unique(state)]
control_states <- annual[first_treat_year == 0, unique(state)]

## ========================================================================
## FIGURE 1: Minimum Wage Variation Across States, 2018–2024
## ========================================================================

cat("Figure 1: MW variation...\n")

# Panel A: MW level time series by treatment group (restrict to analysis period)
mw_group <- mw_data[year <= 2023, .(
  mean_mw = mean(min_wage),
  sd_mw = sd(min_wage)
), by = .(year, treated = first_treat_year > 0)]
mw_group[, group := ifelse(treated, "States with MW increases", "Federal minimum ($7.25)")]

p1a <- ggplot(mw_group, aes(x = year, y = mean_mw, color = group, fill = group)) +
  geom_ribbon(aes(ymin = mean_mw - sd_mw, ymax = mean_mw + sd_mw), alpha = 0.15, color = NA) +
  geom_line(linewidth = 1.2) +
  geom_point(size = 2.5) +
  scale_color_manual(values = apep_colors[1:2]) +
  scale_fill_manual(values = apep_colors[1:2]) +
  labs(x = NULL, y = "Mean State Minimum Wage ($)",
       title = "A. Minimum Wage Levels by Treatment Group",
       color = NULL, fill = NULL) +
  theme_apep() +
  theme(legend.position = c(0.3, 0.85))

# Panel B: Bar chart of MW levels in 2023 (final year of analysis sample)
mw_2023 <- mw_data[year == 2023][order(-min_wage)]
mw_2023[, state := factor(state, levels = state)]
mw_2023[, group := ifelse(first_treat_year > 0, "Above federal", "At federal ($7.25)")]

p1b <- ggplot(mw_2023, aes(x = state, y = min_wage, fill = group)) +
  geom_col(width = 0.7) +
  geom_hline(yintercept = 7.25, linetype = "dashed", color = "grey40") +
  scale_fill_manual(values = apep_colors[1:2]) +
  labs(x = NULL, y = "Minimum Wage ($, 2023)",
       title = "B. State Minimum Wage Rates, 2023",
       fill = NULL) +
  theme_apep() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1, size = 7),
        legend.position = c(0.8, 0.85))

p1 <- cowplot::plot_grid(p1a, p1b, ncol = 1, rel_heights = c(1, 1.2))
ggsave(file.path(FIGURES, "fig1_mw_variation.pdf"), p1, width = 10, height = 10)
ggsave(file.path(FIGURES, "fig1_mw_variation.png"), p1, width = 10, height = 10, dpi = 300)

## ========================================================================
## FIGURE 2: HCBS Provider Trends by Treatment Group
## ========================================================================

cat("Figure 2: HCBS provider trends...\n")

# Aggregate monthly data by treatment group (restrict to analysis period)
monthly[, treated := first_treat_year > 0]
trends <- monthly[month_date <= as.Date("2023-12-31"), .(
  mean_providers = mean(n_providers, na.rm = TRUE),
  mean_benes = mean(total_benes, na.rm = TRUE)
), by = .(month_date, treated)]
trends[, group := ifelse(treated, "MW-increasing states", "Federal minimum states")]

# Normalize to 2018-01 = 100
base_vals <- trends[month_date == as.Date("2018-01-01")]
trends <- merge(trends, base_vals[, .(treated, base_prov = mean_providers, base_benes = mean_benes)],
                by = "treated")
trends[, prov_index := 100 * mean_providers / base_prov]
trends[, benes_index := 100 * mean_benes / base_benes]

p2a <- ggplot(trends, aes(x = month_date, y = prov_index, color = group)) +
  geom_line(linewidth = 0.9) +
  geom_vline(xintercept = as.Date("2020-03-01"), linetype = "dotted", color = "grey50") +
  annotate("text", x = as.Date("2020-03-01"), y = max(trends$prov_index, na.rm = TRUE),
           label = "COVID-19", hjust = -0.1, size = 3, color = "grey50") +
  scale_color_manual(values = apep_colors[1:2]) +
  labs(x = NULL, y = "HCBS Providers (Index: Jan 2018 = 100)",
       title = "A. HCBS Provider Counts",
       color = NULL) +
  theme_apep()

p2b <- ggplot(trends, aes(x = month_date, y = benes_index, color = group)) +
  geom_line(linewidth = 0.9) +
  geom_vline(xintercept = as.Date("2020-03-01"), linetype = "dotted", color = "grey50") +
  scale_color_manual(values = apep_colors[1:2]) +
  labs(x = NULL, y = "Beneficiaries Served (Index: Jan 2018 = 100)",
       title = "B. Beneficiaries Served",
       color = NULL) +
  theme_apep()

p2 <- cowplot::plot_grid(p2a, p2b, ncol = 1)
ggsave(file.path(FIGURES, "fig2_provider_trends.pdf"), p2, width = 10, height = 10)
ggsave(file.path(FIGURES, "fig2_provider_trends.png"), p2, width = 10, height = 10, dpi = 300)

## ========================================================================
## FIGURE 3: CS-DiD Event Study — HCBS Providers
## ========================================================================

cat("Figure 3: Event study...\n")

if (!is.null(cs_es_providers)) {
  es_df <- data.frame(
    period = cs_es_providers$egt,
    att = cs_es_providers$att.egt,
    se = cs_es_providers$se.egt
  )
  es_df$ci_lower <- es_df$att - 1.96 * es_df$se
  es_df$ci_upper <- es_df$att + 1.96 * es_df$se

  p3 <- ggplot(es_df, aes(x = period, y = att)) +
    geom_ribbon(aes(ymin = ci_lower, ymax = ci_upper),
                alpha = 0.2, fill = apep_colors[1]) +
    geom_point(color = apep_colors[1], size = 3) +
    geom_line(color = apep_colors[1], linewidth = 0.8) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
    geom_vline(xintercept = -0.5, linetype = "dotted", color = "grey60") +
    labs(x = "Years Relative to Minimum Wage Increase",
         y = "ATT (Log HCBS Providers)",
         title = "Callaway-Sant'Anna Event Study: Effect of MW on HCBS Provider Supply") +
    theme_apep()

  ggsave(file.path(FIGURES, "fig3_event_study.pdf"), p3, width = 10, height = 6)
  ggsave(file.path(FIGURES, "fig3_event_study.png"), p3, width = 10, height = 6, dpi = 300)
}

## ========================================================================
## FIGURE 4: CS-DiD Event Study — Multiple Outcomes
## ========================================================================

cat("Figure 4: Multi-outcome event study...\n")

make_es_df <- function(cs_es, label) {
  if (is.null(cs_es)) return(NULL)
  data.frame(
    period = cs_es$egt,
    att = cs_es$att.egt,
    se = cs_es$se.egt,
    ci_lower = cs_es$att.egt - 1.96 * cs_es$se.egt,
    ci_upper = cs_es$att.egt + 1.96 * cs_es$se.egt,
    outcome = label
  )
}

multi_es <- rbind(
  make_es_df(cs_es_providers, "HCBS Providers"),
  make_es_df(cs_es_benes, "Beneficiaries"),
  make_es_df(cs_es_individual, "Individual Providers")
)

if (!is.null(multi_es) && nrow(multi_es) > 0) {
  p4 <- ggplot(multi_es, aes(x = period, y = att, color = outcome, fill = outcome)) +
    geom_ribbon(aes(ymin = ci_lower, ymax = ci_upper), alpha = 0.1, color = NA) +
    geom_point(size = 2.5, position = position_dodge(0.3)) +
    geom_line(linewidth = 0.7) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
    geom_vline(xintercept = -0.5, linetype = "dotted", color = "grey60") +
    scale_color_manual(values = apep_colors[1:3]) +
    scale_fill_manual(values = apep_colors[1:3]) +
    labs(x = "Years Relative to MW Increase",
         y = "ATT (Log Outcome)",
         title = "Effect of Minimum Wage on HCBS Outcomes",
         color = NULL, fill = NULL) +
    theme_apep()

  ggsave(file.path(FIGURES, "fig4_multi_outcome_es.pdf"), p4, width = 10, height = 6)
  ggsave(file.path(FIGURES, "fig4_multi_outcome_es.png"), p4, width = 10, height = 6, dpi = 300)
}

## ========================================================================
## FIGURE 5: Placebo Event Study — Non-HCBS Providers
## ========================================================================

cat("Figure 5: Placebo event study...\n")

if (!is.null(cs_es_placebo)) {
  placebo_df <- data.frame(
    period = cs_es_placebo$egt,
    att = cs_es_placebo$att.egt,
    se = cs_es_placebo$se.egt,
    ci_lower = cs_es_placebo$att.egt - 1.96 * cs_es_placebo$se.egt,
    ci_upper = cs_es_placebo$att.egt + 1.96 * cs_es_placebo$se.egt
  )

  p5 <- ggplot(placebo_df, aes(x = period, y = att)) +
    geom_ribbon(aes(ymin = ci_lower, ymax = ci_upper),
                alpha = 0.2, fill = apep_colors[2]) +
    geom_point(color = apep_colors[2], size = 3) +
    geom_line(color = apep_colors[2], linewidth = 0.8) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
    geom_vline(xintercept = -0.5, linetype = "dotted", color = "grey60") +
    labs(x = "Years Relative to MW Increase",
         y = "ATT (Log Non-HCBS Providers)",
         title = "Placebo: Non-HCBS Medicaid Providers (Physician/Specialist)",
         subtitle = "These providers earn far above minimum wage — expect null effect") +
    theme_apep()

  ggsave(file.path(FIGURES, "fig5_placebo_es.pdf"), p5, width = 10, height = 6)
  ggsave(file.path(FIGURES, "fig5_placebo_es.png"), p5, width = 10, height = 6, dpi = 300)
}

## ========================================================================
## FIGURE 6: Randomization Inference Distribution
## ========================================================================

cat("Figure 6: Randomization inference...\n")

if (!is.null(ri_results)) {
  ri_df <- data.frame(coef = ri_results$perms)

  p6 <- ggplot(ri_df, aes(x = coef)) +
    geom_histogram(bins = 50, fill = "grey70", color = "grey50") +
    geom_vline(xintercept = ri_results$actual, color = apep_colors[1],
               linewidth = 1.2, linetype = "solid") +
    geom_vline(xintercept = -ri_results$actual, color = apep_colors[1],
               linewidth = 1.2, linetype = "dashed") +
    annotate("text", x = ri_results$actual, y = Inf,
             label = sprintf("Actual = %.4f\nRI p = %.3f", ri_results$actual, ri_results$pvalue),
             hjust = -0.1, vjust = 2, size = 4, color = apep_colors[1]) +
    labs(x = "Permuted Coefficient (log MW → log HCBS Providers)",
         y = "Frequency",
         title = "Randomization Inference: Fisher Permutation Test (500 permutations)") +
    theme_apep()

  ggsave(file.path(FIGURES, "fig6_ri_distribution.pdf"), p6, width = 10, height = 6)
  ggsave(file.path(FIGURES, "fig6_ri_distribution.png"), p6, width = 10, height = 6, dpi = 300)
}

## ========================================================================
## FIGURE 7: Provider Entry and Exit Rates
## ========================================================================

cat("Figure 7: Entry/exit rates...\n")

# Drop 2018: first year of panel inflates entry rate mechanically (all NPIs are "new")
entry_exit <- annual[year >= 2019, .(
  mean_entry = mean(entry_rate, na.rm = TRUE),
  mean_exit = mean(exit_rate, na.rm = TRUE)
), by = .(year, treated = first_treat_year > 0)]
entry_exit[, group := ifelse(treated, "MW-increasing", "Federal minimum")]

# Reshape to long
ee_long <- melt(entry_exit, id.vars = c("year", "treated", "group"),
                measure.vars = c("mean_entry", "mean_exit"),
                variable.name = "rate_type", value.name = "rate")
ee_long[, rate_type := ifelse(rate_type == "mean_entry", "Entry Rate", "Exit Rate")]

p7 <- ggplot(ee_long, aes(x = year, y = rate, color = group, linetype = rate_type)) +
  geom_line(linewidth = 0.9) +
  geom_point(size = 2) +
  scale_color_manual(values = apep_colors[1:2]) +
  labs(x = NULL, y = "Annual Rate (fraction of providers)",
       title = "HCBS Provider Entry and Exit Rates",
       color = NULL, linetype = NULL) +
  theme_apep()

ggsave(file.path(FIGURES, "fig7_entry_exit.pdf"), p7, width = 10, height = 6)
ggsave(file.path(FIGURES, "fig7_entry_exit.png"), p7, width = 10, height = 6, dpi = 300)

cat("\n=== Figures complete ===\n")
cat("All figures saved to:", FIGURES, "\n")
