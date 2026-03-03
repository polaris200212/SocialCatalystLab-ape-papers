## ============================================================================
## 05_figures.R — All figure generation
## apep_0491: Do Red Flag Laws Reduce Violent Crime?
## ============================================================================

source("00_packages.R")
DATA <- "../data"
FIGS <- "../figures"
dir.create(FIGS, showWarnings = FALSE)

panel <- readRDS(file.path(DATA, "analysis_panel_clean.rds"))
results <- readRDS(file.path(DATA, "main_results.rds"))
robustness <- readRDS(file.path(DATA, "robustness_results.rds"))

## ============================================================================
## FIGURE 1: ERPO Adoption Timeline
## ============================================================================

erpo_timeline <- unique(panel[treated == TRUE, .(state_abb, erpo_year, petitioner_type)])
setorder(erpo_timeline, erpo_year, state_abb)
erpo_timeline[, state_label := factor(state_abb, levels = rev(erpo_timeline$state_abb))]

fig1 <- ggplot(erpo_timeline, aes(x = erpo_year, y = state_label,
                                    color = petitioner_type)) +
  geom_point(size = 3) +
  scale_color_manual(values = c("family" = "#2166AC", "le" = "#B2182B"),
                     labels = c("Family + LE", "LE only"),
                     name = "Petitioner type") +
  labs(title = "Staggered Adoption of ERPO Laws",
       x = "Year enacted", y = NULL) +
  theme(axis.text.y = element_text(size = 8))

ggsave(file.path(FIGS, "fig1_erpo_timeline.pdf"), fig1,
       width = 7, height = 6)
cat("Saved fig1_erpo_timeline.pdf\n")

## ============================================================================
## FIGURE 2: Crime Trends by Treatment Status
## ============================================================================

trends <- panel[, .(
  murder_rate  = weighted.mean(murder_rate, population, na.rm = TRUE),
  violent_rate = weighted.mean(violent_rate, population, na.rm = TRUE),
  property_rate = weighted.mean(property_rate, population, na.rm = TRUE)
), by = .(year, treated)]

trends_long <- melt(trends, id.vars = c("year", "treated"),
                    variable.name = "crime_type", value.name = "rate")
trends_long[, group := fifelse(treated, "ERPO states", "Non-ERPO states")]
trends_long[, crime_label := fcase(
  crime_type == "murder_rate", "Murder",
  crime_type == "violent_rate", "Violent crime",
  crime_type == "property_rate", "Property crime"
)]

fig2 <- ggplot(trends_long, aes(x = year, y = rate, color = group, linetype = group)) +
  geom_line(linewidth = 0.8) +
  facet_wrap(~crime_label, scales = "free_y", ncol = 1) +
  scale_color_manual(values = c("ERPO states" = "#2166AC", "Non-ERPO states" = "#B2182B")) +
  scale_linetype_manual(values = c("ERPO states" = "solid", "Non-ERPO states" = "dashed")) +
  geom_vline(xintercept = 2018, linetype = "dotted", color = "grey50", alpha = 0.7) +
  annotate("text", x = 2018.5, y = Inf, label = "2018 wave", vjust = 1.5,
           size = 3, color = "grey50") +
  labs(title = "Crime Rate Trends: ERPO vs. Non-ERPO States",
       x = "Year", y = "Rate per 100,000", color = NULL, linetype = NULL)

ggsave(file.path(FIGS, "fig2_crime_trends.pdf"), fig2,
       width = 8, height = 10)
cat("Saved fig2_crime_trends.pdf\n")

## ============================================================================
## FIGURE 3: Event Study — Murder Rate (Main Result)
## ============================================================================

es_murder <- results$es_murder
es_dt <- data.table(
  event_time = es_murder$egt,
  att        = es_murder$att.egt,
  se         = es_murder$se.egt
)
es_dt[, ci_lo := att - 1.96 * se]
es_dt[, ci_hi := att + 1.96 * se]

fig3 <- ggplot(es_dt, aes(x = event_time, y = att)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey60") +
  geom_vline(xintercept = -0.5, linetype = "dotted", color = "grey40") +
  geom_ribbon(aes(ymin = ci_lo, ymax = ci_hi), alpha = 0.15, fill = "#2166AC") +
  geom_line(color = "#2166AC", linewidth = 0.8) +
  geom_point(color = "#2166AC", size = 2) +
  labs(title = "Event Study: Effect of ERPO Laws on Murder Rate",
       subtitle = "Callaway & Sant'Anna (2021), doubly-robust, never-treated controls",
       x = "Years relative to ERPO adoption",
       y = "ATT (murders per 100,000)") +
  scale_x_continuous(breaks = seq(-10, 8, 2))

ggsave(file.path(FIGS, "fig3_event_study_murder.pdf"), fig3,
       width = 8, height = 5)
cat("Saved fig3_event_study_murder.pdf\n")

## ============================================================================
## FIGURE 4: Event Study — Multiple Outcomes
## ============================================================================

make_es_dt <- function(es_obj, label) {
  data.table(
    event_time = es_obj$egt,
    att = es_obj$att.egt,
    se  = es_obj$se.egt,
    outcome = label
  )
}

es_all <- rbind(
  make_es_dt(results$es_murder, "Murder"),
  make_es_dt(results$es_assault, "Aggravated assault"),
  make_es_dt(results$es_robbery, "Robbery"),
  make_es_dt(results$es_property, "Property crime (placebo)")
)
es_all[, ci_lo := att - 1.96 * se]
es_all[, ci_hi := att + 1.96 * se]

fig4 <- ggplot(es_all, aes(x = event_time, y = att)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey60") +
  geom_vline(xintercept = -0.5, linetype = "dotted", color = "grey40") +
  geom_ribbon(aes(ymin = ci_lo, ymax = ci_hi), alpha = 0.15, fill = "#2166AC") +
  geom_line(color = "#2166AC", linewidth = 0.6) +
  geom_point(color = "#2166AC", size = 1.5) +
  facet_wrap(~outcome, scales = "free_y", ncol = 2) +
  labs(title = "Event Study: ERPO Laws and Crime",
       subtitle = "CS-DiD, doubly-robust, never-treated controls",
       x = "Years relative to ERPO adoption",
       y = "ATT (per 100,000)") +
  scale_x_continuous(breaks = seq(-10, 8, 2))

ggsave(file.path(FIGS, "fig4_event_study_all.pdf"), fig4,
       width = 10, height = 7)
cat("Saved fig4_event_study_all.pdf\n")

## ============================================================================
## FIGURE 5: Group-Specific ATTs
## ============================================================================

group_obj <- results$group_murder
group_dt <- data.table(
  cohort = group_obj$egt,
  att    = group_obj$att.egt,
  se     = group_obj$se.egt
)
group_dt[, ci_lo := att - 1.96 * se]
group_dt[, ci_hi := att + 1.96 * se]
group_dt[, cohort_f := factor(cohort)]

fig5 <- ggplot(group_dt, aes(x = cohort_f, y = att)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey60") +
  geom_pointrange(aes(ymin = ci_lo, ymax = ci_hi),
                  color = "#2166AC", size = 0.6) +
  labs(title = "Cohort-Specific ATTs: Murder Rate",
       subtitle = "Each point = ATT for states adopting in that year",
       x = "ERPO adoption cohort", y = "ATT (murders per 100,000)")

ggsave(file.path(FIGS, "fig5_group_att.pdf"), fig5,
       width = 8, height = 5)
cat("Saved fig5_group_att.pdf\n")

## ============================================================================
## FIGURE 6: Leave-One-Out Sensitivity
## ============================================================================

if (!is.null(robustness$loo) && nrow(robustness$loo) > 0) {
  loo <- robustness$loo
  loo[, state_f := factor(dropped_state, levels = loo[order(att)]$dropped_state)]

  main_att <- results$agg_murder$overall.att

  fig6 <- ggplot(loo, aes(x = state_f, y = att)) +
    geom_hline(yintercept = main_att, color = "#B2182B", linetype = "dashed") +
    geom_hline(yintercept = 0, color = "grey60", linetype = "dotted") +
    geom_pointrange(aes(ymin = att - 1.96 * se, ymax = att + 1.96 * se),
                    color = "#2166AC", size = 0.4) +
    coord_flip() +
    labs(title = "Leave-One-State-Out Sensitivity",
         subtitle = "Red dashed line = main ATT estimate",
         x = "Dropped state", y = "ATT (murders per 100,000)")

  ggsave(file.path(FIGS, "fig6_loo.pdf"), fig6,
         width = 7, height = 8)
  cat("Saved fig6_loo.pdf\n")
}

## ============================================================================
## FIGURE 7: Randomization Inference Distribution
## ============================================================================

if (!is.null(robustness$ri_dist) && length(robustness$ri_dist) > 10) {
  ri_dt <- data.table(perm_att = robustness$ri_dist)
  true_att <- results$agg_murder$overall.att

  fig7 <- ggplot(ri_dt, aes(x = perm_att)) +
    geom_histogram(bins = 50, fill = "grey70", color = "white") +
    geom_vline(xintercept = true_att, color = "#B2182B", linewidth = 1) +
    geom_vline(xintercept = -true_att, color = "#B2182B",
               linewidth = 1, linetype = "dashed") +
    labs(title = "Randomization Inference: Murder Rate ATT",
         subtitle = sprintf("Observed ATT = %.3f, RI p = %.3f",
                            true_att, robustness$ri_pvalue),
         x = "Permuted ATTs", y = "Count")

  ggsave(file.path(FIGS, "fig7_ri_distribution.pdf"), fig7,
         width = 7, height = 5)
  cat("Saved fig7_ri_distribution.pdf\n")
}

cat("\nAll figures saved.\n")
