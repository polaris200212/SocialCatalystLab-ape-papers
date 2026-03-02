## ============================================================================
## 05_figures.R — Generate all figures (v2: reorganized + new exhibits)
## Project: apep_0441 v2 — State Bifurcation and Development in India
## ============================================================================

source("00_packages.R")
load("../data/analysis_panel.RData")
load("../data/main_results.RData")
load("../data/cs_results.RData")
load("../data/robustness_results.RData")
load("../data/ri_results.RData")
load("../data/es_coefs.RData")
load("../data/border_results.RData")
load("../data/gadm_spatial.RData")

library(rnaturalearth)

fig_dir <- "../figures"
dir.create(fig_dir, showWarnings = FALSE, recursive = TRUE)

panel_2000 <- panel_dmsp[state_pair %in% c("UK-UP", "JH-BR", "CG-MP")]

## ============================================================================
## Figure 1: Map of India with treatment/control regions + border districts
## ============================================================================

cat("=== Figure 1: Map ===\n")

# Get full India outline
india <- ne_states(country = "India", returnclass = "sf")

# Classify states
india$fill_group <- "Other"
new_state_names <- c("Uttarakhand", "Jharkhand", "Chhattisgarh")
parent_state_names <- c("Uttar Pradesh", "Bihar", "Madhya Pradesh")

india$fill_group[india$name %in% new_state_names] <- "New State"
india$fill_group[india$name %in% parent_state_names] <- "Parent State"

# Capital coordinates
capitals_df <- data.frame(
  name = c("Dehradun", "Ranchi", "Raipur"),
  lon = c(78.03, 85.31, 81.63),
  lat = c(30.32, 23.34, 21.25)
)

# Create map
map_colors <- c("New State" = apep_colors[1],
                "Parent State" = apep_colors[2],
                "Other" = "grey90")

fig1 <- ggplot() +
  geom_sf(data = india, aes(fill = fill_group), color = "grey60", linewidth = 0.2) +
  scale_fill_manual(values = map_colors, name = NULL) +
  geom_point(data = capitals_df, aes(x = lon, y = lat),
             shape = 18, size = 3, color = "gold3") +
  geom_text(data = capitals_df, aes(x = lon, y = lat, label = name),
            hjust = -0.1, vjust = -0.5, size = 2.5, fontface = "italic") +
  coord_sf(xlim = c(68, 98), ylim = c(7, 37)) +
  labs(
    title = "India's 2000 State Bifurcations: Treatment and Control Regions",
    subtitle = "Blue = newly created states, Orange = parent states, Diamonds = new capitals"
  ) +
  theme_apep() +
  theme(
    axis.text = element_blank(),
    axis.ticks = element_blank(),
    axis.title = element_blank(),
    axis.line = element_blank(),
    panel.grid = element_blank()
  )

ggsave(file.path(fig_dir, "fig1_map.pdf"), fig1, width = 7, height = 8)
cat("Figure 1 saved: map\n")

## ============================================================================
## Figure 2: Raw nightlight trends by treatment group
## ============================================================================

cat("=== Figure 2: Trends ===\n")

trends <- panel_2000[, .(
  mean_nl = mean(nightlights, na.rm = TRUE),
  mean_log_nl = mean(log_nl, na.rm = TRUE)
), by = .(year, treated)]
trends[, group := fifelse(treated == 1, "New State Districts", "Parent State Districts")]

fig2 <- ggplot(trends, aes(x = year, y = mean_log_nl, color = group, linetype = group)) +
  geom_line(linewidth = 1) +
  geom_point(size = 2) +
  geom_vline(xintercept = 2000.5, linetype = "dashed", color = "grey50") +
  annotate("text", x = 2001, y = max(trends$mean_log_nl) * 0.95,
           label = "State creation\n(Nov 2000)", hjust = 0, size = 3, color = "grey40") +
  scale_color_manual(values = apep_colors[1:2]) +
  scale_linetype_manual(values = c("solid", "dashed")) +
  labs(
    title = "Average Nightlight Intensity: New vs Parent State Districts",
    subtitle = "DMSP calibrated luminosity, district-level means (1994-2013)",
    x = "Year", y = "Log(Nightlights + 1)",
    color = NULL, linetype = NULL
  ) +
  theme_apep()

ggsave(file.path(fig_dir, "fig2_trends.pdf"), fig2, width = 8, height = 5)
cat("Figure 2 saved: trends\n")

## ============================================================================
## Figure 3: Consolidated event study (TWFE + CS-DiD, 2-panel)
## ============================================================================

cat("=== Figure 3: Event Studies ===\n")

# Panel A: TWFE event study
es_plot_data <- rbind(
  es_coefs[, .(event_time, estimate, se)],
  data.table(event_time = -1L, estimate = 0, se = 0)
)
es_plot_data[, ci_lo := estimate - 1.96 * se]
es_plot_data[, ci_hi := estimate + 1.96 * se]
es_plot_data <- es_plot_data[order(event_time)]

fig3a <- ggplot(es_plot_data, aes(x = event_time, y = estimate)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey60") +
  geom_vline(xintercept = -0.5, linetype = "dashed", color = "grey50") +
  geom_ribbon(aes(ymin = ci_lo, ymax = ci_hi), alpha = 0.15, fill = apep_colors[1]) +
  geom_line(color = apep_colors[1], linewidth = 0.8) +
  geom_point(color = apep_colors[1], size = 2) +
  labs(
    title = "A. TWFE Event Study",
    subtitle = "95% CI, clustered at state level",
    x = "Years Relative to State Creation", y = "Coefficient"
  ) +
  theme_apep()

# Panel B: CS-DiD event study
fig3b_data <- tryCatch({
  data.table(
    event_time = cs_es$egt,
    estimate = cs_es$att.egt,
    se = cs_es$se.egt
  )
}, error = function(e) NULL)

if (!is.null(fig3b_data)) {
  fig3b_data[, ci_lo := estimate - 1.96 * se]
  fig3b_data[, ci_hi := estimate + 1.96 * se]

  fig3b <- ggplot(fig3b_data, aes(x = event_time, y = estimate)) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "grey60") +
    geom_vline(xintercept = -0.5, linetype = "dashed", color = "grey50") +
    geom_ribbon(aes(ymin = ci_lo, ymax = ci_hi), alpha = 0.15, fill = apep_colors[3]) +
    geom_line(color = apep_colors[3], linewidth = 0.8) +
    geom_point(color = apep_colors[3], size = 2) +
    labs(
      title = "B. Callaway-Sant'Anna Event Study",
      subtitle = "Heterogeneity-robust ATTs",
      x = "Years Relative to State Creation", y = "ATT"
    ) +
    theme_apep()

  fig3 <- fig3a + fig3b + plot_layout(ncol = 2)
} else {
  fig3 <- fig3a
}

ggsave(file.path(fig_dir, "fig3_event_studies.pdf"), fig3, width = 12, height = 5)
cat("Figure 3 saved: event studies (2-panel)\n")

## ============================================================================
## Figure 4: Heterogeneity by state pair
## ============================================================================

cat("=== Figure 4: Pair Trends ===\n")

pair_trends <- panel_2000[, .(
  mean_log_nl = mean(log_nl, na.rm = TRUE)
), by = .(year, state_pair, treated)]
pair_trends[, group := fifelse(treated == 1, "New State", "Parent State")]

pair_labels <- c("UK-UP" = "Uttarakhand vs UP",
                 "JH-BR" = "Jharkhand vs Bihar",
                 "CG-MP" = "Chhattisgarh vs MP")

fig4 <- ggplot(pair_trends, aes(x = year, y = mean_log_nl, color = group)) +
  geom_line(linewidth = 0.8) +
  geom_point(size = 1.5) +
  geom_vline(xintercept = 2000.5, linetype = "dashed", color = "grey50") +
  facet_wrap(~state_pair, labeller = labeller(state_pair = pair_labels),
             scales = "free_y") +
  scale_color_manual(values = apep_colors[1:2]) +
  labs(
    title = "Nightlight Trends by State Pair",
    subtitle = "Heterogeneous trajectories across the three bifurcations",
    x = "Year", y = "Log(Nightlights + 1)",
    color = NULL
  ) +
  theme_apep() +
  theme(strip.text = element_text(face = "bold", size = 10))

ggsave(file.path(fig_dir, "fig4_pair_trends.pdf"), fig4, width = 10, height = 4)
cat("Figure 4 saved: pair trends\n")

## ============================================================================
## Figure 5: Placebo permutation distribution (reframed from RI)
## ============================================================================

cat("=== Figure 5: Placebo Permutation ===\n")

ri_df <- data.table(stat = ri_stats[!is.na(ri_stats)])

fig5 <- ggplot(ri_df, aes(x = stat)) +
  geom_histogram(bins = 15, fill = "grey70", color = "grey50", alpha = 0.7) +
  geom_vline(xintercept = actual_stat, color = apep_colors[1], linewidth = 1.2) +
  annotate("text", x = actual_stat, y = Inf, vjust = 2,
           label = paste0("Actual = ", round(actual_stat, 3)),
           color = apep_colors[1], fontface = "bold", size = 3.5) +
  labs(
    title = "Placebo Permutation: Estimates Under Random Assignment",
    subtitle = paste0("All C(6,3) = 20 permutations of treatment across states. p-value = ",
                      round(ri_pvalue, 3)),
    x = "Placebo Treatment Effect (log nightlights)",
    y = "Count"
  ) +
  theme_apep()

ggsave(file.path(fig_dir, "fig5_placebo_permutation.pdf"), fig5, width = 7, height = 5)
cat("Figure 5 saved: placebo permutation\n")

## ============================================================================
## Figure 6: Capital vs non-capital districts
## ============================================================================

cat("=== Figure 6: Capital Effect ===\n")

capital_trends <- panel_2000[, .(
  mean_log_nl = mean(log_nl, na.rm = TRUE)
), by = .(year, is_capital, treated)]

capital_trends[, group := fifelse(
  is_capital == 1, "New State Capital",
  fifelse(treated == 1, "New State (Non-Capital)", "Parent State")
)]

fig6 <- ggplot(capital_trends, aes(x = year, y = mean_log_nl, color = group)) +
  geom_line(linewidth = 0.8) +
  geom_point(size = 2) +
  geom_vline(xintercept = 2000.5, linetype = "dashed", color = "grey50") +
  scale_color_manual(values = apep_colors[c(3, 1, 2)]) +
  labs(
    title = "Capital City Effect: New State Capitals vs Other Districts",
    subtitle = "Dehradun, Ranchi, Raipur vs non-capital treated vs parent districts",
    x = "Year", y = "Log(Nightlights + 1)",
    color = NULL
  ) +
  theme_apep()

ggsave(file.path(fig_dir, "fig6_capital_effect.pdf"), fig6, width = 8, height = 5)
cat("Figure 6 saved: capital effect\n")

## ============================================================================
## Figure 7: Border DiD Event Study
## ============================================================================

cat("=== Figure 7: Border DiD Event Study ===\n")

border_es_plot <- rbind(
  border_es_coefs[, .(event_time, estimate, se)],
  data.table(event_time = -1L, estimate = 0, se = 0)
)
border_es_plot[, ci_lo := estimate - 1.96 * se]
border_es_plot[, ci_hi := estimate + 1.96 * se]
border_es_plot <- border_es_plot[order(event_time)]

fig7 <- ggplot(border_es_plot, aes(x = event_time, y = estimate)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey60") +
  geom_vline(xintercept = -0.5, linetype = "dashed", color = "grey50") +
  geom_ribbon(aes(ymin = ci_lo, ymax = ci_hi), alpha = 0.15, fill = apep_colors[4]) +
  geom_line(color = apep_colors[4], linewidth = 0.8) +
  geom_point(color = apep_colors[4], size = 2.5) +
  labs(
    title = paste0("Border DiD Event Study (Districts Within ", preferred_bw, "km of Boundary)"),
    subtitle = "Pre-trends should flatten if border sample improves identification",
    x = "Years Relative to State Creation",
    y = "Coefficient (log nightlights)"
  ) +
  theme_apep()

ggsave(file.path(fig_dir, "fig7_border_event_study.pdf"), fig7, width = 8, height = 5)
cat("Figure 7 saved: border event study\n")

## ============================================================================
## Figure 8: Spatial RDD Plot
## ============================================================================

cat("=== Figure 8: Spatial RDD ===\n")

if (!is.null(rdd_out)) {
  rdd_plot_data <- copy(rdd_data)
  rdd_plot_data[, side := fifelse(dist_to_border_km >= 0, "New State", "Parent State")]

  fig8 <- ggplot(rdd_plot_data, aes(x = dist_to_border_km, y = nl_growth)) +
    geom_point(aes(color = side), alpha = 0.6, size = 2.5) +
    geom_vline(xintercept = 0, linetype = "solid", color = "grey30", linewidth = 0.5) +
    geom_smooth(data = rdd_plot_data[dist_to_border_km < 0],
                method = "loess", se = TRUE, color = apep_colors[2], fill = apep_colors[2],
                alpha = 0.1, linewidth = 0.8) +
    geom_smooth(data = rdd_plot_data[dist_to_border_km >= 0],
                method = "loess", se = TRUE, color = apep_colors[1], fill = apep_colors[1],
                alpha = 0.1, linewidth = 0.8) +
    scale_color_manual(values = c("New State" = apep_colors[1],
                                   "Parent State" = apep_colors[2])) +
    annotate("text", x = 0, y = max(rdd_plot_data$nl_growth, na.rm = TRUE) * 0.95,
             label = "State\nBoundary", hjust = 0.5, size = 3, color = "grey40") +
    labs(
      title = "Spatial RDD: Nightlight Growth vs Distance to New State Boundary",
      subtitle = paste0("rdrobust estimate: ", round(rdd_out$coef[1], 3),
                        " (SE = ", round(rdd_out$se[1], 3),
                        "), optimal BW = ", round(rdd_out$bws[1,1], 0), "km"),
      x = "Signed Distance to Boundary (km, + = new state side)",
      y = "Nightlight Growth (post - pre, log)",
      color = NULL
    ) +
    theme_apep()

  ggsave(file.path(fig_dir, "fig8_spatial_rdd.pdf"), fig8, width = 8, height = 5.5)
  cat("Figure 8 saved: spatial RDD\n")
} else {
  cat("  RDD result NULL, skipping figure 8\n")
}

## ============================================================================
## Figure 9: HonestDiD Sensitivity Plot
## ============================================================================

cat("=== Figure 9: HonestDiD Sensitivity ===\n")

if (!is.null(honest_result) && !is.null(honest_result$bounds)) {
  honest_df <- as.data.table(honest_result$bounds)

  # The bounds dataframe should have M/Mbar, lb, ub columns
  # Detect column names
  possible_m <- intersect(names(honest_df), c("M", "Mbar"))
  if (length(possible_m) > 0) {
    m_col <- possible_m[1]
    if (m_col != "M") setnames(honest_df, m_col, "M")

    fig9 <- ggplot(honest_df, aes(x = M)) +
      geom_hline(yintercept = 0, linetype = "dashed", color = "grey60") +
      geom_ribbon(aes(ymin = lb, ymax = ub), alpha = 0.2, fill = apep_colors[3]) +
      geom_line(aes(y = lb), color = apep_colors[3], linewidth = 0.6, linetype = "dashed") +
      geom_line(aes(y = ub), color = apep_colors[3], linewidth = 0.6, linetype = "dashed") +
      labs(
        title = "Rambachan-Roth Sensitivity: Robust Confidence Intervals",
        subtitle = paste0("Breakdown value: M = ",
                          ifelse(!is.na(honest_result$breakdown_M),
                                 honest_result$breakdown_M, "N/A"),
                          " (CI includes zero when post-trend violation exceeds M times max pre-trend)"),
        x = expression(bar(M) ~ "(Maximum Relative Magnitude of Post-Treatment Violation)"),
        y = "Treatment Effect (log nightlights)"
      ) +
      theme_apep()

    ggsave(file.path(fig_dir, "fig9_honestdid.pdf"), fig9, width = 8, height = 5)
    cat("Figure 9 saved: HonestDiD sensitivity\n")
  } else {
    cat("  HonestDiD bounds format unexpected, columns:", paste(names(honest_df), collapse = ", "), "\n")
  }
} else {
  cat("  HonestDiD result NULL, generating placeholder\n")
  fig9 <- ggplot() +
    annotate("text", x = 0.5, y = 0.5,
             label = "HonestDiD sensitivity bounds could not be computed\n(near-singular VCV with 6 clusters)",
             size = 4, color = "grey50") +
    theme_void() +
    labs(title = "Rambachan-Roth Sensitivity Analysis")
  ggsave(file.path(fig_dir, "fig9_honestdid.pdf"), fig9, width = 8, height = 5)
}

## ============================================================================
## Appendix Figure A1: Extended panel (1994-2023, DMSP + VIIRS)
## ============================================================================

cat("=== Appendix Figure A1: Extended Panel ===\n")

panel_ext <- panel_full[state_pair %in% c("UK-UP", "JH-BR", "CG-MP")]
ext_trends <- panel_ext[, .(
  mean_log_nl = mean(log_nl, na.rm = TRUE)
), by = .(year, treated)]
ext_trends[, group := fifelse(treated == 1, "New State Districts", "Parent State Districts")]
ext_trends[, sensor := fifelse(year <= 2013, "DMSP", "VIIRS")]

figA1 <- ggplot(ext_trends, aes(x = year, y = mean_log_nl, color = group)) +
  geom_line(linewidth = 0.8) +
  geom_point(aes(shape = sensor), size = 2) +
  geom_vline(xintercept = 2000.5, linetype = "dashed", color = "grey50") +
  geom_vline(xintercept = 2013.5, linetype = "dotted", color = "grey70") +
  annotate("text", x = 2013.5, y = min(ext_trends$mean_log_nl) * 1.05,
           label = "DMSP->VIIRS", size = 2.5, color = "grey50", hjust = 1.1) +
  scale_color_manual(values = apep_colors[1:2]) +
  labs(
    title = "Long-Run Trajectories: Two Decades After State Creation",
    subtitle = "Calibrated DMSP (1994-2013) + VIIRS (2014-2023)",
    x = "Year", y = "Log(Nightlights + 1)",
    color = NULL, shape = "Sensor"
  ) +
  theme_apep()

ggsave(file.path(fig_dir, "figA1_extended_panel.pdf"), figA1, width = 9, height = 5)
cat("Appendix Figure A1 saved: extended panel\n")

cat("\n=== All figures generated ===\n")
