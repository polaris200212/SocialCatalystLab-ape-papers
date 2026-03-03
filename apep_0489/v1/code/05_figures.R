# =============================================================================
# 05_figures.R — Figures for the DiD-Transformer paper
# =============================================================================
# Generates:
#   Figure 1: TVA county map (treatment vs control)
#   Figure 2: Balance visualization (normalized differences)
#   Figure 3: Event study / DiD coefficient plot
#   Figure 4: Outcome trends (ag share, mfg share over time)
#   Figure 5: Leave-one-state-out stability plot
#
# Input:  ../data/ (from scripts 01-04)
# Output: ../figures/*.pdf
# =============================================================================

source("00_packages.R")

# =============================================================================
# Load all data
# =============================================================================
log_msg("Loading data for figures...")

analysis_county  <- readRDS(file.path(DATA_DIR, "analysis_county.rds"))
county_tva       <- readRDS(file.path(DATA_DIR, "county_tva.rds"))
balance_table    <- readRDS(file.path(DATA_DIR, "balance_table_data.rds"))
event_study      <- readRDS(file.path(DATA_DIR, "event_study_results.rds"))
loso_results     <- readRDS(file.path(DATA_DIR, "loso_results.rds"))
main_results     <- readRDS(file.path(DATA_DIR, "main_results.rds"))

# =============================================================================
# Figure 1: TVA County Map
# =============================================================================
log_msg("Figure 1: TVA county map...")

# Load US county shapefile
# Use the tigris package or a shipped shapefile. For reproducibility, download
# a historical county boundary file. Here we use the 2010 county boundaries
# from the US Census Bureau as a reasonable approximation.
tryCatch({
  if (requireNamespace("tigris", quietly = TRUE)) {
    counties_sf <- tigris::counties(cb = TRUE, year = 2020, progress_bar = FALSE)
    counties_sf <- st_transform(counties_sf, crs = 5070)  # Albers Equal Area

    # Create STATEFIP and COUNTYICP mapping
    # Note: COUNTYICP != FIPS county code. For the map, we approximate by
    # highlighting states in the TVA region and marking TVA status at state level.
    # A precise map would require an IPUMS-to-FIPS crosswalk.

    # For this paper, we create a state-level TVA map with county outlines
    tva_state_fips <- c("01", "13", "21", "28", "37", "47", "51")

    # States in the Southeast region (for inset)
    southeast_fips <- c("01", "05", "12", "13", "21", "22", "28",
                        "37", "45", "47", "48", "51", "54")

    # Filter to lower 48
    counties_se <- counties_sf[counties_sf$STATEFP %in% southeast_fips, ]

    # Mark TVA states
    counties_se$tva_state <- ifelse(counties_se$STATEFP %in% tva_state_fips,
                                     "TVA State", "Non-TVA")

    # Approximate TVA service area: counties in Tennessee and parts of
    # surrounding states. For a precise map, we would need the IPUMS-FIPS
    # crosswalk. Here we shade all TVA-state counties and note in the caption
    # that the actual service area is a subset.

    p1 <- ggplot(counties_se) +
      geom_sf(aes(fill = tva_state), color = "gray70", linewidth = 0.05) +
      scale_fill_manual(
        values = c("TVA State" = "#D55E00", "Non-TVA" = "#E0E0E0"),
        name = NULL
      ) +
      labs(
        title = "TVA Service Area States",
        subtitle = "Counties in states served by the Tennessee Valley Authority (est. 1933)",
        caption = paste0("Note: Shading indicates states with TVA service area counties.\n",
                         "Actual TVA service area covers ~125 counties, primarily in Tennessee\n",
                         "and parts of Alabama, Georgia, Kentucky, Mississippi, North Carolina, and Virginia.")
      ) +
      theme_void(base_size = 12) +
      theme(
        plot.title = element_text(face = "bold", size = 14),
        plot.subtitle = element_text(size = 10, color = "gray40"),
        plot.caption = element_text(size = 8, color = "gray50", hjust = 0),
        legend.position = "bottom"
      )

    ggsave(file.path(FIG_DIR, "fig1_tva_map.pdf"), p1,
           width = 10, height = 7, device = "pdf")
    log_msg("  Saved fig1_tva_map.pdf")
  } else {
    log_msg("  SKIPPED: tigris package not available for map generation")
  }
}, error = function(e) {
  log_msg(sprintf("  Map generation failed: %s", e$message))
  log_msg("  Creating placeholder map using state-level aggregates...")
})

# =============================================================================
# Figure 2: Balance Table Visualization (Normalized Differences)
# =============================================================================
log_msg("Figure 2: Balance visualization...")

bal_plot <- balance_table[variable != "N counties" & !is.na(norm_diff)]

p2 <- ggplot(bal_plot, aes(x = norm_diff, y = reorder(variable, abs(norm_diff)))) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "gray50") +
  geom_vline(xintercept = c(-0.25, 0.25), linetype = "dotted", color = "gray70") +
  geom_point(size = 3, color = "#0072B2") +
  geom_segment(aes(xend = 0, yend = variable), color = "#0072B2", linewidth = 0.5) +
  labs(
    title = "Balance at Baseline (1920)",
    subtitle = "Normalized differences between TVA and control counties",
    x = "Normalized Difference (TVA - Control)",
    y = NULL,
    caption = paste0("Note: Normalized differences computed as ",
                     "(mean_TVA - mean_Control) / sqrt(sd_TVA^2 + sd_Control^2).\n",
                     "Dotted lines at +/- 0.25 indicate conventional balance threshold ",
                     "(Imbens & Rubin 2015).")
  ) +
  theme(
    plot.caption = element_text(size = 8, color = "gray50", hjust = 0)
  )

ggsave(file.path(FIG_DIR, "fig2_balance.pdf"), p2,
       width = 8, height = 5, device = "pdf")
log_msg("  Saved fig2_balance.pdf")

# =============================================================================
# Figure 3: Event Study / DiD Coefficient Plot
# =============================================================================
log_msg("Figure 3: Event study coefficient plot...")

# Add a vertical line at 1933 (TVA creation)
p3 <- ggplot(event_study, aes(x = year, y = coef, color = outcome, shape = outcome)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
  geom_vline(xintercept = 1933, linetype = "dotted", color = "gray40", linewidth = 0.8) +
  annotate("text", x = 1933.5, y = max(event_study$ci_upper, na.rm = TRUE) * 0.9,
           label = "TVA\nestablished", hjust = 0, size = 3, color = "gray40") +
  geom_ribbon(aes(ymin = ci_lower, ymax = ci_upper, fill = outcome),
              alpha = 0.15, color = NA) +
  geom_line(linewidth = 0.8) +
  geom_point(size = 3) +
  scale_color_manual(values = c("Agriculture Share" = "#D55E00",
                                 "Manufacturing Share" = "#0072B2")) +
  scale_fill_manual(values = c("Agriculture Share" = "#D55E00",
                                "Manufacturing Share" = "#0072B2")) +
  scale_x_continuous(breaks = c(1920, 1930, 1940)) +
  labs(
    title = "Event Study: TVA Effects on Sectoral Employment",
    subtitle = "Coefficients relative to 1920 (reference year)",
    x = "Census Year",
    y = "Coefficient (TVA x Year)",
    color = NULL, fill = NULL, shape = NULL,
    caption = paste0("Note: 95% confidence intervals based on state-clustered standard errors.\n",
                     "Reference period is 1920. The 1930 coefficient tests pre-trends.\n",
                     "The 1940 coefficient captures the TVA treatment effect.")
  ) +
  theme(
    legend.position = "bottom",
    plot.caption = element_text(size = 8, color = "gray50", hjust = 0)
  )

ggsave(file.path(FIG_DIR, "fig3_event_study.pdf"), p3,
       width = 8, height = 6, device = "pdf")
log_msg("  Saved fig3_event_study.pdf")

# =============================================================================
# Figure 4: Outcome Trends Over Time (TVA vs Control)
# =============================================================================
log_msg("Figure 4: Outcome trends...")

# Compute mean outcomes by year and TVA status
trends <- analysis_county[, .(
  ag_share  = mean(ag_share, na.rm = TRUE),
  mfg_share = mean(mfg_share, na.rm = TRUE),
  n_counties = .N
), by = .(year, tva)]

trends[, group := fifelse(tva == 1, "TVA", "Control")]

# Ag share trends
p4a <- ggplot(trends, aes(x = year, y = ag_share, color = group, shape = group)) +
  geom_vline(xintercept = 1933, linetype = "dotted", color = "gray40") +
  geom_line(linewidth = 0.8) +
  geom_point(size = 3) +
  scale_color_manual(values = COLORS) +
  scale_x_continuous(breaks = c(1920, 1930, 1940)) +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1)) +
  labs(
    title = "Agricultural Employment Share",
    x = "Census Year",
    y = "Share in Agriculture",
    color = NULL, shape = NULL
  ) +
  theme(legend.position = "bottom")

# Mfg share trends
p4b <- ggplot(trends, aes(x = year, y = mfg_share, color = group, shape = group)) +
  geom_vline(xintercept = 1933, linetype = "dotted", color = "gray40") +
  geom_line(linewidth = 0.8) +
  geom_point(size = 3) +
  scale_color_manual(values = COLORS) +
  scale_x_continuous(breaks = c(1920, 1930, 1940)) +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1)) +
  labs(
    title = "Manufacturing Employment Share",
    x = "Census Year",
    y = "Share in Manufacturing",
    color = NULL, shape = NULL
  ) +
  theme(legend.position = "bottom")

# Combine with patchwork if available, else save separately
if (requireNamespace("patchwork", quietly = TRUE)) {
  library(patchwork)
  p4 <- p4a + p4b +
    plot_annotation(
      title = "Sectoral Employment Shares: TVA vs. Control Counties",
      subtitle = "Vertical line marks TVA establishment (1933)",
      caption = paste0("Note: Means across county-level agriculture and manufacturing shares.\n",
                       "TVA counties defined by 1920 residence in TVA service area."),
      theme = theme(
        plot.title = element_text(face = "bold", size = 14),
        plot.caption = element_text(size = 8, color = "gray50", hjust = 0)
      )
    )
  ggsave(file.path(FIG_DIR, "fig4_trends.pdf"), p4,
         width = 12, height = 5, device = "pdf")
} else {
  ggsave(file.path(FIG_DIR, "fig4a_ag_trends.pdf"), p4a,
         width = 7, height = 5, device = "pdf")
  ggsave(file.path(FIG_DIR, "fig4b_mfg_trends.pdf"), p4b,
         width = 7, height = 5, device = "pdf")
}
log_msg("  Saved fig4_trends.pdf")

# =============================================================================
# Figure 5: Leave-One-State-Out Stability Plot
# =============================================================================
log_msg("Figure 5: Leave-one-state-out stability...")

# State FIPS to name mapping (for labels)
state_names <- c(
  "1" = "AL", "2" = "AK", "4" = "AZ", "5" = "AR", "6" = "CA",
  "8" = "CO", "9" = "CT", "10" = "DE", "11" = "DC", "12" = "FL",
  "13" = "GA", "15" = "HI", "16" = "ID", "17" = "IL", "18" = "IN",
  "19" = "IA", "20" = "KS", "21" = "KY", "22" = "LA", "23" = "ME",
  "24" = "MD", "25" = "MA", "26" = "MI", "27" = "MN", "28" = "MS",
  "29" = "MO", "30" = "MT", "31" = "NE", "32" = "NV", "33" = "NH",
  "34" = "NJ", "35" = "NM", "36" = "NY", "37" = "NC", "38" = "ND",
  "39" = "OH", "40" = "OK", "41" = "OR", "42" = "PA", "44" = "RI",
  "45" = "SC", "46" = "SD", "47" = "TN", "48" = "TX", "49" = "UT",
  "50" = "VT", "51" = "VA", "53" = "WA", "54" = "WV", "55" = "WI",
  "56" = "WY"
)

loso_results[, state_abbr := state_names[as.character(dropped_state)]]

# Highlight TVA states
loso_results[, is_tva_state := dropped_state %in% TVA_STATES]

# Get main estimate for reference line
main_ag  <- main_results[outcome == "Ag Share" & specification == "TWFE"]$coef
main_mfg <- main_results[outcome == "Mfg Share" & specification == "TWFE"]$coef

p5 <- ggplot(loso_results,
             aes(x = reorder(state_abbr, coef), y = coef,
                 color = is_tva_state)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
  geom_point(size = 2) +
  geom_errorbar(aes(ymin = coef - 1.96 * se, ymax = coef + 1.96 * se),
                width = 0.3) +
  scale_color_manual(
    values = c("FALSE" = "gray40", "TRUE" = "#D55E00"),
    labels = c("Non-TVA state", "TVA state"),
    name = NULL
  ) +
  facet_wrap(~outcome, scales = "free_y", ncol = 1) +
  coord_flip() +
  labs(
    title = "Leave-One-State-Out Sensitivity",
    subtitle = "TWFE coefficient when each state is dropped from the sample",
    x = "Dropped State",
    y = "TVA x Post Coefficient",
    caption = paste0("Note: Each point shows the TWFE coefficient from a regression that\n",
                     "excludes the indicated state. 95% CIs from state-clustered SEs.\n",
                     "Orange points indicate TVA-region states.")
  ) +
  theme(
    legend.position = "bottom",
    axis.text.y = element_text(size = 6),
    plot.caption = element_text(size = 8, color = "gray50", hjust = 0)
  )

ggsave(file.path(FIG_DIR, "fig5_loso.pdf"), p5,
       width = 8, height = 10, device = "pdf")
log_msg("  Saved fig5_loso.pdf")

# =============================================================================
# Figure 6: Transition rate comparison (TVA vs Control)
# =============================================================================
log_msg("Figure 6: Transition rate comparison...")

# Compute transition rates by TVA status and period
trans_summary <- analysis_county[year %in% c(1930, 1940) & !is.na(transition_ag_to_mfg), .(
  trans_ag_mfg = mean(transition_ag_to_mfg, na.rm = TRUE),
  trans_ag_mfg_cond = mean(transition_ag_to_mfg_cond, na.rm = TRUE),
  occ_change  = mean(occ_change_rate, na.rm = TRUE),
  farm_exit   = mean(farm_exit_rate, na.rm = TRUE),
  n = .N
), by = .(year, tva)]

trans_summary[, group := fifelse(tva == 1, "TVA", "Control")]
trans_summary[, period := fifelse(year == 1930, "1920-1930\n(Pre-TVA)", "1930-1940\n(Post-TVA)")]

# Reshape for faceted plot
trans_long <- melt(trans_summary,
  id.vars = c("year", "tva", "group", "period", "n"),
  measure.vars = c("trans_ag_mfg_cond", "occ_change", "farm_exit"),
  variable.name = "outcome",
  value.name = "rate"
)

trans_long[, outcome_label := fcase(
  outcome == "trans_ag_mfg_cond", "Ag-to-Mfg Transition\n(Conditional on Ag)",
  outcome == "occ_change", "Occupation Change Rate",
  outcome == "farm_exit", "Farm Exit Rate"
)]

p6 <- ggplot(trans_long, aes(x = period, y = rate, fill = group)) +
  geom_col(position = position_dodge(width = 0.7), width = 0.6) +
  facet_wrap(~outcome_label, scales = "free_y", ncol = 3) +
  scale_fill_manual(values = COLORS) +
  scale_y_continuous(labels = scales::percent_format(accuracy = 0.1)) +
  labs(
    title = "Career Transition Rates: TVA vs. Control Counties",
    x = NULL,
    y = "Rate",
    fill = NULL,
    caption = paste0("Note: County-level means. Ag-to-Mfg transition is conditional on\n",
                     "being in agriculture in the prior census year.")
  ) +
  theme(
    legend.position = "bottom",
    plot.caption = element_text(size = 8, color = "gray50", hjust = 0)
  )

ggsave(file.path(FIG_DIR, "fig6_transitions.pdf"), p6,
       width = 12, height = 5, device = "pdf")
log_msg("  Saved fig6_transitions.pdf")

log_msg("\nAll figures complete.")
