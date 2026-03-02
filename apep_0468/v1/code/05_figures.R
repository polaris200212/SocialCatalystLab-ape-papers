# ==============================================================================
# 05_figures.R — All figures
# APEP-0468: Where Does Workfare Work?
# ==============================================================================

source("00_packages.R")

data_dir <- "../data"
fig_dir <- "../figures"
dir.create(fig_dir, showWarnings = FALSE, recursive = TRUE)

panel <- readRDS(file.path(data_dir, "analysis_panel.rds"))

# Theme
theme_apep <- theme_minimal(base_size = 12) +
  theme(
    panel.grid.minor = element_blank(),
    plot.title = element_text(face = "bold", size = 13),
    legend.position = "bottom",
    strip.text = element_text(face = "bold")
  )
theme_set(theme_apep)

# ==============================================================================
# Figure 1: MGNREGA Phase Map (Cohort Paths)
# ==============================================================================
cat("Figure 1: Cohort nightlight paths...\n")

cohort_means <- panel[, .(mean_light = mean(log_light, na.rm = TRUE)),
                       by = .(year, mgnrega_phase)]
cohort_means[, Phase := factor(mgnrega_phase,
                                labels = c("Phase I (2007)",
                                          "Phase II (2008)",
                                          "Phase III (2009)"))]

# Treatment timing lines
treat_years <- data.table(
  Phase = factor(c("Phase I (2007)", "Phase II (2008)", "Phase III (2009)"),
                 levels = c("Phase I (2007)", "Phase II (2008)", "Phase III (2009)")),
  year = c(2007, 2008, 2009)
)

p1 <- ggplot(cohort_means, aes(x = year, y = mean_light, color = Phase)) +
  geom_line(linewidth = 1) +
  geom_point(size = 2) +
  geom_vline(data = treat_years, aes(xintercept = year, color = Phase),
             linetype = "dashed", alpha = 0.5) +
  scale_color_manual(values = c("#E41A1C", "#377EB8", "#4DAF4A")) +
  labs(
    title = "Mean Log Nightlights by MGNREGA Cohort",
    x = "Year", y = "Log(Total Light + 1)",
    color = "Treatment Cohort"
  ) +
  scale_x_continuous(breaks = seq(2000, 2013, 2))

ggsave(file.path(fig_dir, "fig1_cohort_paths.pdf"), p1,
       width = 8, height = 5.5)
cat("  Saved fig1_cohort_paths.pdf\n")

# ==============================================================================
# Figure 2: CS-DiD Event Study
# ==============================================================================
cat("Figure 2: Event study...\n")

cs_agg <- tryCatch(readRDS(file.path(data_dir, "cs_aggregations.rds")),
                    error = function(e) NULL)

if (!is.null(cs_agg)) {
  cs_es <- cs_agg$es

  es_dt <- data.table(
    event_time = cs_es$egt,
    att = cs_es$att.egt,
    se = cs_es$se.egt
  )
  es_dt[, `:=`(ci_lo = att - 1.96 * se, ci_hi = att + 1.96 * se)]

  p2 <- ggplot(es_dt, aes(x = event_time, y = att)) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
    geom_vline(xintercept = -0.5, linetype = "dashed", color = "gray50") +
    geom_ribbon(aes(ymin = ci_lo, ymax = ci_hi), alpha = 0.2, fill = "#377EB8") +
    geom_line(color = "#377EB8", linewidth = 1) +
    geom_point(color = "#377EB8", size = 2.5) +
    labs(
      title = "Dynamic Treatment Effects: Callaway-Sant'Anna (2021)",
      subtitle = "Log nightlights, not-yet-treated control, doubly-robust",
      x = "Event Time (Years Relative to MGNREGA Implementation)",
      y = "Effect on Log Nightlights (ATT)"
    ) +
    scale_x_continuous(breaks = -6:6) +
    theme_minimal(base_size = 11) +
    theme(panel.grid.minor = element_blank()) +
    annotate("text", x = -4, y = max(es_dt$ci_hi, na.rm = TRUE) * 0.9,
             label = "Pre-treatment", hjust = 0.5, fontface = "italic",
             color = "gray40", size = 3.5) +
    annotate("text", x = 3, y = max(es_dt$ci_hi, na.rm = TRUE) * 0.9,
             label = "Post-treatment", hjust = 0.5, fontface = "italic",
             color = "gray40", size = 3.5)

  ggsave(file.path(fig_dir, "fig2_event_study.pdf"), p2,
         width = 8, height = 5.5)
  cat("  Saved fig2_event_study.pdf\n")
} else {
  cat("  CS-DiD results not available, skipping.\n")
}

# ==============================================================================
# Figure 3: Heterogeneity by Baseline Characteristics
# ==============================================================================
cat("Figure 3: Heterogeneity...\n")

# TWFE heterogeneity estimates
het_results <- list()

for (var in c("rain_tercile", "ag_labor_tercile", "scst_tercile", "light_tercile")) {
  for (lev in levels(panel[[var]])) {
    sub <- panel[get(var) == lev]
    if (nrow(sub) > 100) {
      m <- feols(log_light ~ treated | dist_id_11 + year,
                 data = sub, cluster = ~pc01_state_id)
      het_results[[length(het_results) + 1]] <- data.table(
        dimension = var,
        level = lev,
        att = coef(m)["treated"],
        se = se(m)["treated"]
      )
    }
  }
}

het_dt <- rbindlist(het_results)
het_dt[, `:=`(ci_lo = att - 1.96 * se, ci_hi = att + 1.96 * se)]

# Clean labels
het_dt[, Dimension := fcase(
  dimension == "rain_tercile", "Rainfall",
  dimension == "ag_labor_tercile", "Ag. Labor Share",
  dimension == "scst_tercile", "SC/ST Share",
  dimension == "light_tercile", "Baseline Luminosity"
)]

p3 <- ggplot(het_dt, aes(x = level, y = att, ymin = ci_lo, ymax = ci_hi)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
  geom_pointrange(color = "#377EB8", size = 0.6) +
  facet_wrap(~Dimension, scales = "free_x", nrow = 1) +
  labs(
    title = "Heterogeneous Effects of MGNREGA on Nightlights",
    subtitle = "TWFE estimates by baseline district characteristics",
    x = "", y = "ATT (Log Nightlights)"
  ) +
  theme_minimal(base_size = 11) +
  theme(
    axis.text.x = element_text(size = 9),
    panel.grid.major.x = element_blank(),
    panel.grid.minor = element_blank(),
    strip.text = element_text(face = "bold")
  )

ggsave(file.path(fig_dir, "fig3_heterogeneity.pdf"), p3,
       width = 10, height = 5)
cat("  Saved fig3_heterogeneity.pdf\n")

# ==============================================================================
# Figure 4: Bacon Decomposition
# ==============================================================================
cat("Figure 4: Bacon decomposition...\n")

bd <- tryCatch(readRDS(file.path(data_dir, "bacon_decomp.rds")),
                error = function(e) NULL)

if (!is.null(bd) && is.data.frame(bd)) {
  p4 <- ggplot(bd, aes(x = weight, y = estimate, color = type, shape = type)) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
    geom_point(size = 3, alpha = 0.8) +
    scale_color_brewer(palette = "Set1") +
    labs(
      title = "Bacon Decomposition of TWFE Estimate",
      x = "Weight", y = "2x2 DiD Estimate",
      color = "Comparison Type", shape = "Comparison Type"
    )

  ggsave(file.path(fig_dir, "fig4_bacon_decomp.pdf"), p4,
         width = 8, height = 5.5)
  cat("  Saved fig4_bacon_decomp.pdf\n")
} else {
  cat("  Bacon decomposition not available, skipping.\n")
}

# ==============================================================================
# Figure 5: Sun-Abraham Event Study
# ==============================================================================
cat("Figure 5: Sun-Abraham event study...\n")

sa <- tryCatch(readRDS(file.path(data_dir, "sa_results.rds")),
                error = function(e) NULL)

if (!is.null(sa)) {
  sa_coefs <- as.data.table(coef(sa), keep.rownames = TRUE)
  setnames(sa_coefs, c("term", "estimate"))
  sa_se <- as.data.table(se(sa), keep.rownames = TRUE)
  setnames(sa_se, c("term", "se"))
  sa_dt <- merge(sa_coefs, sa_se, by = "term")

  # Parse event time from fixest sunab coefficient names
  sa_dt[, event_time := as.numeric(gsub(".*::(-?[0-9]+).*", "\\1", term))]
  sa_dt <- sa_dt[!is.na(event_time)]
  sa_dt[, `:=`(ci_lo = estimate - 1.96 * se, ci_hi = estimate + 1.96 * se)]

  p5 <- ggplot(sa_dt, aes(x = event_time, y = estimate)) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
    geom_vline(xintercept = -0.5, linetype = "dashed", color = "gray50") +
    geom_ribbon(aes(ymin = ci_lo, ymax = ci_hi), alpha = 0.2, fill = "#E41A1C") +
    geom_line(color = "#E41A1C", linewidth = 1) +
    geom_point(color = "#E41A1C", size = 2.5) +
    labs(
      title = "Sun-Abraham (2021) Interaction-Weighted Event Study",
      x = "Event Time (Years Relative to MGNREGA Implementation)",
      y = "ATT (Log Nightlights)"
    ) +
    scale_x_continuous(breaks = -6:6)

  ggsave(file.path(fig_dir, "fig5_sun_abraham.pdf"), p5,
         width = 8, height = 5.5)
  cat("  Saved fig5_sun_abraham.pdf\n")
} else {
  cat("  Sun-Abraham results not available, skipping.\n")
}

# ==============================================================================
# Figure 6: TWFE vs CS-DiD comparison
# ==============================================================================
cat("Figure 6: Estimator comparison...\n")

twfe_res <- tryCatch(readRDS(file.path(data_dir, "twfe_results.rds")),
                      error = function(e) NULL)

if (!is.null(cs_agg) && !is.null(twfe_res)) {
  # CS-DiD event study
  cs_dt <- data.table(
    event_time = cs_agg$es$egt,
    att = cs_agg$es$att.egt,
    se = cs_agg$es$se.egt,
    estimator = "Callaway-Sant'Anna"
  )

  # TWFE event study
  twfe_coefs <- as.data.table(coef(twfe_res$es), keep.rownames = TRUE)
  setnames(twfe_coefs, c("term", "estimate"))
  twfe_ses <- as.data.table(se(twfe_res$es), keep.rownames = TRUE)
  setnames(twfe_ses, c("term", "se"))
  twfe_dt <- merge(twfe_coefs, twfe_ses, by = "term")
  twfe_dt[, event_time := as.numeric(gsub(".*::(-?[0-9]+).*", "\\1", term))]
  twfe_dt <- twfe_dt[!is.na(event_time)]
  twfe_dt[, estimator := "TWFE"]
  twfe_dt[, att := estimate]

  combined <- rbind(
    cs_dt[, .(event_time, att, se, estimator)],
    twfe_dt[, .(event_time, att, se, estimator)]
  )
  combined[, `:=`(ci_lo = att - 1.96 * se, ci_hi = att + 1.96 * se)]

  p6 <- ggplot(combined, aes(x = event_time, y = att, color = estimator,
                               fill = estimator)) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
    geom_vline(xintercept = -0.5, linetype = "dashed", color = "gray50") +
    geom_ribbon(aes(ymin = ci_lo, ymax = ci_hi), alpha = 0.15) +
    geom_line(linewidth = 0.8) +
    geom_point(size = 2) +
    scale_color_manual(values = c("Callaway-Sant'Anna" = "#377EB8",
                                   "TWFE" = "#E41A1C")) +
    scale_fill_manual(values = c("Callaway-Sant'Anna" = "#377EB8",
                                  "TWFE" = "#E41A1C")) +
    labs(
      title = "Comparison: TWFE vs. Callaway-Sant'Anna Event Study",
      x = "Event Time", y = "ATT (Log Nightlights)",
      color = "Estimator", fill = "Estimator"
    ) +
    scale_x_continuous(breaks = -6:6)

  ggsave(file.path(fig_dir, "fig6_estimator_comparison.pdf"), p6,
         width = 8, height = 5.5)
  cat("  Saved fig6_estimator_comparison.pdf\n")
}

# ==============================================================================
# Figure 7: Census Mechanism — Structural Transformation
# ==============================================================================
cat("Figure 7: Census mechanism...\n")

census <- readRDS(file.path(data_dir, "census_change.rds"))

# Ag labor share change by phase
mech_summary <- census[, .(
  d_ag_labor = mean(d_ag_labor_share, na.rm = TRUE),
  d_ag_labor_se = sd(d_ag_labor_share, na.rm = TRUE) / sqrt(.N),
  d_cult = mean(d_cult_share, na.rm = TRUE),
  d_cult_se = sd(d_cult_share, na.rm = TRUE) / sqrt(.N),
  pop_growth = mean(pop_growth, na.rm = TRUE),
  pop_growth_se = sd(pop_growth, na.rm = TRUE) / sqrt(.N),
  N = .N
), by = mgnrega_phase]

mech_long <- melt(mech_summary,
                   id.vars = c("mgnrega_phase", "N"),
                   measure.vars = patterns("^d_ag|^d_cult|^pop"),
                   variable.name = "measure")
# Manually create long format
mech_plot <- rbind(
  mech_summary[, .(Phase = factor(mgnrega_phase), measure = "Ag. Labor Share Change",
                    value = d_ag_labor, se = d_ag_labor_se)],
  mech_summary[, .(Phase = factor(mgnrega_phase), measure = "Cultivator Share Change",
                    value = d_cult, se = d_cult_se)],
  mech_summary[, .(Phase = factor(mgnrega_phase), measure = "Population Growth",
                    value = pop_growth, se = pop_growth_se)]
)

p7 <- ggplot(mech_plot, aes(x = Phase, y = value, fill = Phase)) +
  geom_col(alpha = 0.8) +
  geom_errorbar(aes(ymin = value - 1.96 * se, ymax = value + 1.96 * se),
                width = 0.2) +
  facet_wrap(~measure, scales = "free_y") +
  scale_fill_manual(values = c("1" = "#E41A1C", "2" = "#377EB8", "3" = "#4DAF4A")) +
  labs(
    title = "Structural Transformation by MGNREGA Phase (Census 2001-2011)",
    x = "MGNREGA Phase", y = "Change (2001-2011)",
    fill = "Phase"
  ) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray50")

ggsave(file.path(fig_dir, "fig7_mechanism_census.pdf"), p7,
       width = 10, height = 5)
cat("  Saved fig7_mechanism_census.pdf\n")

# ==============================================================================
# Figure 8: Baseline Balance
# ==============================================================================
cat("Figure 8: Baseline balance...\n")

bal_data <- panel[year == 2000, .(
  dist_id_11, mgnrega_phase, log_light, sc_st_share, lit_rate,
  ag_labor_share, avg_rainfall, pop_2001
)]

bal_long <- melt(bal_data, id.vars = c("dist_id_11", "mgnrega_phase"),
                  variable.name = "characteristic")
bal_long[, Phase := factor(mgnrega_phase,
                           labels = c("Phase I", "Phase II", "Phase III"))]

# Standardize within each characteristic for comparison
bal_long[, value_std := scale(value)[,1], by = characteristic]

p8 <- ggplot(bal_long[characteristic %in% c("log_light", "sc_st_share",
                                              "lit_rate", "ag_labor_share")],
              aes(x = Phase, y = value_std, fill = Phase)) +
  geom_boxplot(alpha = 0.7, outlier.size = 0.5) +
  facet_wrap(~characteristic, scales = "free_y",
             labeller = labeller(characteristic = c(
               log_light = "Log Nightlights",
               sc_st_share = "SC/ST Share",
               lit_rate = "Literacy Rate",
               ag_labor_share = "Ag. Labor Share"
             ))) +
  scale_fill_manual(values = c("#E41A1C", "#377EB8", "#4DAF4A")) +
  labs(
    title = "Baseline District Characteristics by MGNREGA Phase (Year 2000)",
    x = "", y = "Standardized Value"
  ) +
  theme(legend.position = "none")

ggsave(file.path(fig_dir, "fig8_baseline_balance.pdf"), p8,
       width = 10, height = 6)
cat("  Saved fig8_baseline_balance.pdf\n")

cat("\n=== All Figures Complete ===\n")
