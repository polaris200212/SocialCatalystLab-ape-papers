## =============================================================================
## 05_figures.R — All figures for the paper
## apep_0474: Downtown for Sale? ACV Commercial Displacement
##
## Figures:
##   1. Event study plot (main result)
##   2. Raw trends: ACV vs control
##   3. Callaway-Sant'Anna event study
##   4. Pre-trend balance
##   5. Randomization inference distribution
##   6. Leave-one-out sensitivity
##   7. Period-specific effects
##   8. Size heterogeneity
## =============================================================================

source(file.path(dirname(sys.frame(1)$ofile %||% "code/05_figures.R"), "00_packages.R"))

panel <- fread(file.path(DATA, "panel_commune_quarter.csv"))
results <- readRDS(file.path(DATA, "main_results.rds"))
robust <- readRDS(file.path(DATA, "robustness_results.rds"))

## ---- Figure 1: Raw Trends ----
cat("=== Figure 1: Raw trends ===\n")

trends <- panel[, .(
  mean_creations = mean(n_creations, na.rm = TRUE),
  se_creations = sd(n_creations, na.rm = TRUE) / sqrt(.N)
), by = .(year, quarter, yq = year + (quarter - 1)/4,
          group = fifelse(acv == 1, "ACV Communes", "Control Communes"))]

fig1 <- ggplot(trends, aes(x = yq, y = mean_creations, color = group, fill = group)) +
  geom_ribbon(aes(ymin = mean_creations - 1.96 * se_creations,
                  ymax = mean_creations + 1.96 * se_creations),
              alpha = 0.15, color = NA) +
  geom_line(linewidth = 0.8) +
  geom_vline(xintercept = 2018, linetype = "dashed", color = "grey40") +
  geom_vline(xintercept = 2020.25, linetype = "dotted", color = "grey60",
             linewidth = 0.5) +
  annotate("text", x = 2018.1, y = Inf, label = "ACV\nAnnouncement",
           hjust = 0, vjust = 1.2, size = 3, color = "grey40") +
  annotate("text", x = 2020.35, y = Inf, label = "COVID",
           hjust = 0, vjust = 1.2, size = 3, color = "grey60") +
  scale_color_manual(values = apep_colors[1:2]) +
  scale_fill_manual(values = apep_colors[1:2]) +
  labs(
    x = "Year",
    y = "Mean Quarterly Establishment Creations\n(Downtown-Facing Sectors)",
    color = NULL, fill = NULL,
    title = "Commercial Establishment Creations: ACV vs. Control Communes"
  ) +
  theme_apep() +
  theme(legend.position = c(0.15, 0.85),
        legend.background = element_rect(fill = "white", color = NA))

ggsave(file.path(FIG, "fig1_raw_trends.pdf"), fig1, width = 8, height = 5)
cat("  Saved fig1_raw_trends.pdf\n")

## ---- Figure 2: Event Study (Main Result) ----
cat("=== Figure 2: Event study ===\n")

# Extract event study coefficients from fixest
es_coefs <- as.data.table(coeftable(results$es_level))
es_coefs[, term := rownames(coeftable(results$es_level))]

# Parse event time from coefficient names (format: "event_bin::N:acv")
es_plot_data <- es_coefs[grepl("event_bin", term)]
es_plot_data[, event_time := as.integer(gsub(":acv$", "", gsub("^event_bin::", "", term)))]
es_plot_data <- es_plot_data[!is.na(event_time)]
es_plot_data <- es_plot_data[order(event_time)]

# Add reference period (event_time = -1, coefficient = 0)
ref_row <- data.table(
  Estimate = 0, `Std. Error` = 0, `t value` = 0, `Pr(>|t|)` = 1,
  term = "ref", event_time = -1L
)
setnames(ref_row, old = c("Std. Error", "t value", "Pr(>|t|)"),
         new = c("se", "tval", "pval"))
setnames(es_plot_data, old = c("Std. Error", "t value", "Pr(>|t|)"),
         new = c("se", "tval", "pval"))

es_plot_data <- rbind(es_plot_data, ref_row, fill = TRUE)
es_plot_data <- es_plot_data[order(event_time)]

# Convert event time to year-quarter labels
es_plot_data[, year_q := 2018 + event_time / 4]

fig2 <- ggplot(es_plot_data, aes(x = event_time, y = Estimate)) +
  # Confidence intervals
  geom_ribbon(aes(ymin = Estimate - 1.96 * se,
                  ymax = Estimate + 1.96 * se),
              alpha = 0.15, fill = apep_colors[1]) +
  # Point estimates
  geom_point(color = apep_colors[1], size = 2) +
  geom_line(color = apep_colors[1], linewidth = 0.6) +
  # Reference lines
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey40",
             linewidth = 0.4) +
  geom_vline(xintercept = -0.5, linetype = "dotted", color = "grey60") +
  # Labels
  labs(
    x = "Quarters Relative to ACV Announcement (2018Q1 = 0)",
    y = "Effect on Quarterly Establishment Creations\n(Downtown-Facing Sectors)",
    title = "Event Study: Effect of ACV on Commercial Vitality"
  ) +
  scale_x_continuous(breaks = seq(-20, 20, by = 4),
                     labels = function(x) {
                       yr <- 2018 + x / 4
                       paste0(floor(yr), "Q", ((x %% 4) + 4) %% 4 + 1)
                     }) +
  theme_apep() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 8))

ggsave(file.path(FIG, "fig2_event_study.pdf"), fig2, width = 9, height = 5.5)
cat("  Saved fig2_event_study.pdf\n")

## ---- Figure 3: CS-DiD Event Study ----
cat("=== Figure 3: Callaway-Sant'Anna event study ===\n")

if (!is.null(results$cs_out)) {
  cs_es <- aggte(results$cs_out, type = "dynamic")
  cs_df <- data.table(
    event_time = cs_es$egt,
    att = cs_es$att.egt,
    se = cs_es$se.egt
  )

  fig3 <- ggplot(cs_df, aes(x = event_time, y = att)) +
    geom_ribbon(aes(ymin = att - 1.96 * se, ymax = att + 1.96 * se),
                alpha = 0.15, fill = apep_colors[3]) +
    geom_point(color = apep_colors[3], size = 2.5) +
    geom_line(color = apep_colors[3], linewidth = 0.6) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
    geom_vline(xintercept = -0.5, linetype = "dotted", color = "grey60") +
    labs(
      x = "Years Relative to ACV (2018 = 0)",
      y = "ATT on Annual Establishment Creations",
      title = "Callaway-Sant'Anna: Group-Time ATT Aggregated to Event Time"
    ) +
    theme_apep()

  ggsave(file.path(FIG, "fig3_cs_event_study.pdf"), fig3, width = 8, height = 5)
  cat("  Saved fig3_cs_event_study.pdf\n")
} else {
  cat("  CS-DiD not available; skipping.\n")
}

## ---- Figure 4: Randomization Inference ----
cat("=== Figure 4: Randomization inference ===\n")

ri_df <- data.table(coef = robust$ri_coefs[!is.na(robust$ri_coefs)])

fig4 <- ggplot(ri_df, aes(x = coef)) +
  geom_histogram(bins = 50, fill = "grey70", color = "grey50", alpha = 0.7) +
  geom_vline(xintercept = robust$observed_coef, color = apep_colors[1],
             linewidth = 1, linetype = "solid") +
  annotate("text", x = robust$observed_coef, y = Inf,
           label = sprintf("Observed\n%.3f", robust$observed_coef),
           hjust = -0.1, vjust = 1.2, color = apep_colors[1], size = 3.5,
           fontface = "bold") +
  labs(
    x = "Placebo Treatment Effect",
    y = "Frequency",
    title = "Randomization Inference: Distribution Under Sharp Null",
    subtitle = sprintf("1,000 permutations | RI p-value = %.3f", robust$ri_pval)
  ) +
  theme_apep()

ggsave(file.path(FIG, "fig4_randomization_inference.pdf"), fig4, width = 7, height = 5)
cat("  Saved fig4_randomization_inference.pdf\n")

## ---- Figure 5: Leave-one-out Département ----
cat("=== Figure 5: Leave-one-out ===\n")

loo_df <- as.data.table(robust$loo_coefs)
loo_df <- loo_df[order(coef)]
loo_df[, rank := .I]

fig5 <- ggplot(loo_df, aes(x = rank, y = coef)) +
  geom_point(color = "grey50", size = 1.5) +
  geom_errorbar(aes(ymin = coef - 1.96 * se, ymax = coef + 1.96 * se),
                width = 0, color = "grey70", alpha = 0.5) +
  geom_hline(yintercept = robust$observed_coef, color = apep_colors[1],
             linewidth = 0.8) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
  labs(
    x = "Département Dropped (sorted by estimate)",
    y = "TWFE Coefficient (treat_post)",
    title = "Leave-One-Out Sensitivity: Dropping Each Département"
  ) +
  theme_apep() +
  theme(axis.text.x = element_blank(), axis.ticks.x = element_blank())

ggsave(file.path(FIG, "fig5_leave_one_out.pdf"), fig5, width = 8, height = 4.5)
cat("  Saved fig5_leave_one_out.pdf\n")

## ---- Figure 6: Period-Specific Effects ----
cat("=== Figure 6: Period-specific effects ===\n")

period_coefs <- coeftable(results$twfe_periods)
period_df <- data.table(
  period = c("2018--2019\n(Pre-COVID)", "2020--2021\n(COVID)", "2022--2024\n(Recovery)"),
  estimate = period_coefs[, "Estimate"],
  se = period_coefs[, "Std. Error"]
)
period_df[, period := factor(period, levels = period)]

fig6 <- ggplot(period_df, aes(x = period, y = estimate)) +
  geom_point(color = apep_colors[1], size = 3) +
  geom_errorbar(aes(ymin = estimate - 1.96 * se, ymax = estimate + 1.96 * se),
                width = 0.15, color = apep_colors[1], linewidth = 0.8) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
  labs(
    x = "Post-Treatment Period",
    y = "Effect on Quarterly Establishment Creations",
    title = "ACV Effect by Period: Pre-COVID, COVID, and Recovery"
  ) +
  theme_apep()

ggsave(file.path(FIG, "fig6_period_effects.pdf"), fig6, width = 6, height = 5)
cat("  Saved fig6_period_effects.pdf\n")

## ---- Figure 7: Placebo Sector Event Study ----
cat("=== Figure 7: Placebo sector ===\n")

es_placebo <- feols(
  n_creations_placebo ~ i(event_bin, acv, ref = -1) | commune_id + time_id,
  data = panel,
  cluster = ~commune_id
)

es_p_coefs <- as.data.table(coeftable(es_placebo))
es_p_coefs[, term := rownames(coeftable(es_placebo))]
es_p_coefs <- es_p_coefs[grepl("event_bin", term)]
es_p_coefs[, event_time := as.integer(gsub(":acv$", "", gsub("^event_bin::", "", term)))]
es_p_coefs <- es_p_coefs[!is.na(event_time)]
setnames(es_p_coefs, "Std. Error", "se")

# Add reference
ref_p <- data.table(Estimate = 0, se = 0, event_time = -1L)
es_p_coefs <- rbind(es_p_coefs[, .(Estimate, se, event_time)],
                     ref_p, fill = TRUE)
es_p_coefs <- es_p_coefs[order(event_time)]

fig7 <- ggplot(es_p_coefs, aes(x = event_time, y = Estimate)) +
  geom_ribbon(aes(ymin = Estimate - 1.96 * se, ymax = Estimate + 1.96 * se),
              alpha = 0.15, fill = apep_colors[2]) +
  geom_point(color = apep_colors[2], size = 2) +
  geom_line(color = apep_colors[2], linewidth = 0.6) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
  geom_vline(xintercept = -0.5, linetype = "dotted", color = "grey60") +
  labs(
    x = "Quarters Relative to ACV (2018Q1 = 0)",
    y = "Effect on Wholesale Establishment Creations",
    title = "Placebo Test: Wholesale Sector (Non-Downtown-Facing)"
  ) +
  theme_apep()

ggsave(file.path(FIG, "fig7_placebo_sector.pdf"), fig7, width = 8, height = 5)
cat("  Saved fig7_placebo_sector.pdf\n")

cat("\nAll figures complete.\n")
