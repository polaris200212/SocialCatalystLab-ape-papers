################################################################################
# 05_figures.R — All Figures
# Paper: Voting Their Wallet? Medicaid Revenue Dependence and Provider Political Behavior
# APEP-0487
################################################################################

source("00_packages.R")

cat("=== Loading data ===\n")
panel <- read_parquet(file.path(LOCAL_DATA, "analysis_panel.parquet")) |> setDT()
main_models <- readRDS(file.path(LOCAL_DATA, "main_models.rds"))

robust_file <- file.path(LOCAL_DATA, "robustness_results.rds")
if (file.exists(robust_file)) {
  robust <- readRDS(robust_file)
}

cs_es_file <- file.path(LOCAL_DATA, "cs_event_study.rds")
cs_exists <- file.exists(cs_es_file)

# ============================================================================
# Figure 1: Donation Rates by Medicaid Dependence Quartile and Expansion Status
# ============================================================================
cat("Figure 1: Descriptive — Donation rates by Medicaid dependence\n")

fig1_data <- panel[!is.na(medicaid_share_q), .(
  donation_rate = mean(any_donation, na.rm = TRUE),
  se = sd(any_donation, na.rm = TRUE) / sqrt(.N)
), by = .(medicaid_share_q, expansion_state, cycle)]

fig1 <- ggplot(fig1_data, aes(x = cycle, y = donation_rate * 100,
                                color = medicaid_share_q,
                                linetype = expansion_state)) +
  geom_line(linewidth = 0.8) +
  geom_point(size = 2) +
  facet_wrap(~ifelse(expansion_state, "Late-Expansion States", "Non-Expansion States")) +
  scale_color_brewer(palette = "RdYlBu", direction = -1,
                     name = "Medicaid\nDependence") +
  scale_linetype_manual(values = c("TRUE" = "solid", "FALSE" = "dashed"),
                        guide = "none") +
  labs(
    title = "Political Donation Rates by Medicaid Revenue Dependence",
    subtitle = "Providers grouped by pre-expansion Medicaid revenue share quartile",
    x = "Election Cycle",
    y = "Donation Rate (%)"
  ) +
  theme(legend.position = "right")

ggsave(file.path(FIG_DIR, "fig1_donation_rates_by_medicaid_dependence.pdf"),
       fig1, width = 10, height = 5)
cat("  Saved: fig1_donation_rates_by_medicaid_dependence.pdf\n")

# ============================================================================
# Figure 2: Event Study — DDD Coefficients
# ============================================================================
cat("Figure 2: Event study\n")

# Option A: Callaway-Sant'Anna event study
if (cs_exists) {
  cs_es <- readRDS(cs_es_file)

  es_dt <- data.table(
    event_time = cs_es$egt,
    att = cs_es$att.egt,
    se = cs_es$se.egt
  )
  es_dt[, `:=`(ci_lo = att - 1.96 * se, ci_hi = att + 1.96 * se)]

  fig2 <- ggplot(es_dt, aes(x = event_time, y = att)) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
    geom_vline(xintercept = -0.5, linetype = "dotted", color = "red", alpha = 0.5) +
    geom_ribbon(aes(ymin = ci_lo, ymax = ci_hi), alpha = 0.2, fill = "steelblue") +
    geom_point(size = 2.5, color = "steelblue") +
    geom_line(color = "steelblue", linewidth = 0.8) +
    labs(
      title = "Dynamic Treatment Effects: Medicaid Expansion on Provider Donations",
      subtitle = "Callaway-Sant'Anna group-time ATTs, aggregated to event time",
      x = "Election Cycles Relative to Expansion",
      y = "ATT (Donation Probability)",
      caption = "Notes: Vertical dashed line marks expansion. 95% pointwise CIs shown."
    )

  ggsave(file.path(FIG_DIR, "fig2_event_study.pdf"), fig2, width = 8, height = 5)
  cat("  Saved: fig2_event_study.pdf (CS-DiD)\n")
} else {
  # Option B: TWFE event study from main analysis
  panel[, high_medicaid := medicaid_share > median(medicaid_share, na.rm = TRUE)]
  es_data <- panel[expansion_state == TRUE & !is.na(event_time)]

  if (nrow(es_data) > 100) {
    m_es <- feols(any_donation ~ i(event_time, high_medicaid, ref = -2) |
                    npi + cycle,
                  data = es_data, cluster = ~practice_state)

    es_dt <- data.table(iplot(m_es, only.params = TRUE))

    fig2 <- ggplot(es_dt, aes(x = estimate_names, y = estimate)) +
      geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
      geom_errorbar(aes(ymin = ci_low, ymax = ci_high), width = 0.2, color = "steelblue") +
      geom_point(size = 2.5, color = "steelblue") +
      labs(
        title = "Event Study: Donation Probability by Medicaid Dependence",
        subtitle = "High vs. low Medicaid dependence in expansion states",
        x = "Election Cycles Relative to Expansion",
        y = "Coefficient (Difference in Donation Rate)"
      )

    ggsave(file.path(FIG_DIR, "fig2_event_study.pdf"), fig2, width = 8, height = 5)
    cat("  Saved: fig2_event_study.pdf (TWFE)\n")
  }
}

# ============================================================================
# Figure 3: Mechanism — Donation Direction by Medicaid Dependence
# ============================================================================
cat("Figure 3: Donation direction\n")

fig3_data <- panel[any_donation == TRUE & !is.na(medicaid_share_q), .(
  dem_share = mean(dem_share, na.rm = TRUE),
  se = sd(dem_share, na.rm = TRUE) / sqrt(.N),
  n = .N
), by = .(medicaid_share_q, expansion_state, cycle)]

fig3 <- ggplot(fig3_data[n >= 10], aes(x = cycle, y = dem_share * 100,
                                        color = medicaid_share_q)) +
  geom_line(linewidth = 0.8) +
  geom_point(size = 2) +
  facet_wrap(~ifelse(expansion_state, "Late-Expansion States", "Non-Expansion States")) +
  scale_color_brewer(palette = "RdYlBu", direction = -1,
                     name = "Medicaid\nDependence") +
  geom_hline(yintercept = 50, linetype = "dotted", color = "gray60") +
  labs(
    title = "Democratic Share of Donations by Medicaid Dependence",
    subtitle = "Among healthcare providers who donate, by pre-expansion Medicaid revenue share",
    x = "Election Cycle",
    y = "Democratic Share of Donations (%)"
  ) +
  ylim(0, 100) +
  theme(legend.position = "right")

ggsave(file.path(FIG_DIR, "fig3_donation_direction.pdf"), fig3, width = 10, height = 5)
cat("  Saved: fig3_donation_direction.pdf\n")

# ============================================================================
# Figure 4: Randomization Inference Distribution
# ============================================================================
cat("Figure 4: RI distribution\n")

if (exists("robust") && !is.null(robust$ri_coefs)) {
  ri_dt <- data.table(coef = robust$ri_coefs[!is.na(robust$ri_coefs)])
  actual <- coef(main_models$extensive_full)[grep("post_expansion.*:.*medicaid_share", names(coef(main_models$extensive_full)))[1]]

  fig4 <- ggplot(ri_dt, aes(x = coef)) +
    geom_histogram(bins = 50, fill = "gray70", color = "gray40", alpha = 0.7) +
    geom_vline(xintercept = actual, color = "red", linewidth = 1.2) +
    annotate("text", x = actual, y = Inf, label = paste("Actual =", round(actual, 4)),
             vjust = 2, hjust = -0.1, color = "red", fontface = "bold") +
    labs(
      title = "Randomization Inference: DDD Coefficient Distribution",
      subtitle = paste0(length(robust$ri_coefs[!is.na(robust$ri_coefs)]),
                        " permutations of expansion status across states (RI p = ",
                        round(robust$ri_pvalue, 3), ")"),
      x = "Permuted DDD Coefficient",
      y = "Count"
    )

  ggsave(file.path(FIG_DIR, "fig4_randomization_inference.pdf"), fig4, width = 7, height = 5)
  cat("  Saved: fig4_randomization_inference.pdf\n")
}

# ============================================================================
# Figure 5: Leave-One-Out Sensitivity
# ============================================================================
cat("Figure 5: Leave-one-out\n")

if (exists("robust") && !is.null(robust$loo)) {
  loo <- robust$loo

  fig5 <- ggplot(loo, aes(x = reorder(dropped_state, coef), y = coef)) +
    geom_hline(yintercept = coef(main_models$extensive_full)[grep("post_expansion.*:.*medicaid_share", names(coef(main_models$extensive_full)))[1]],
               color = "red", linetype = "dashed") +
    geom_point(size = 3, color = "steelblue") +
    geom_errorbar(aes(ymin = coef - 1.96 * se, ymax = coef + 1.96 * se),
                  width = 0.2, color = "steelblue") +
    coord_flip() +
    labs(
      title = "Leave-One-State-Out Sensitivity",
      subtitle = "DDD coefficient with each expansion state sequentially dropped",
      x = "Dropped State",
      y = "DDD Coefficient",
      caption = "Red dashed line = full sample estimate"
    )

  ggsave(file.path(FIG_DIR, "fig5_leave_one_out.pdf"), fig5, width = 7, height = 5)
  cat("  Saved: fig5_leave_one_out.pdf\n")
}

# ============================================================================
# Figure 6: Map — Medicaid Provider Donor Density
# ============================================================================
cat("Figure 6: Geographic distribution map\n")

tryCatch({
  # Get state shapefile
  states_sf <- tigris::states(cb = TRUE, year = 2020, class = "sf") |>
    filter(STUSPS %in% c(state.abb, "DC")) |>
    shift_geometry()  # For Alaska/Hawaii

  # Aggregate donation rate by state
  state_donation_rate <- panel[, .(
    donation_rate = mean(any_donation, na.rm = TRUE) * 100,
    n_providers = uniqueN(npi),
    expansion = any(expansion_state)
  ), by = .(state = practice_state)]

  map_data <- merge(states_sf, state_donation_rate, by.x = "STUSPS", by.y = "state", all.x = TRUE)

  fig6 <- ggplot(map_data) +
    geom_sf(aes(fill = donation_rate), color = "white", linewidth = 0.3) +
    geom_sf(data = filter(map_data, expansion == TRUE),
            fill = NA, color = "red", linewidth = 0.6, linetype = "dashed") +
    scale_fill_viridis_c(name = "Donation\nRate (%)", option = "plasma") +
    labs(
      title = "Healthcare Provider Political Donation Rates by State",
      subtitle = "Red border = late Medicaid expansion state (2019-2024)",
      caption = "Source: T-MSIS × NPPES × FEC linked panel"
    ) +
    theme_void() +
    theme(legend.position = "right",
          plot.title = element_text(face = "bold", size = 12))

  ggsave(file.path(FIG_DIR, "fig6_donation_map.pdf"), fig6, width = 10, height = 6)
  cat("  Saved: fig6_donation_map.pdf\n")
}, error = function(e) {
  cat("  Map generation error:", conditionMessage(e), "\n")
  cat("  (May need to install tigris package)\n")
})

# ============================================================================
# Figure A1 (Appendix): Medicaid Dependence Distribution
# ============================================================================
cat("Figure A1: Medicaid dependence distribution\n")

fig_a1 <- ggplot(panel[cycle == 2018 & !is.na(medicaid_share)],
                 aes(x = medicaid_share * 100)) +
  geom_histogram(bins = 50, fill = "steelblue", color = "white", alpha = 0.8) +
  geom_vline(xintercept = median(panel[cycle == 2018, medicaid_share], na.rm = TRUE) * 100,
             color = "red", linetype = "dashed") +
  labs(
    title = "Distribution of Provider Medicaid Revenue Dependence (2018)",
    subtitle = "Percentile rank of log(Medicaid paid + 1), scaled to [0,1]",
    x = "Medicaid Dependence (percentile rank × 100)",
    y = "Count",
    caption = "Red line = median. Measure is approximately uniform by construction."
  )

ggsave(file.path(FIG_DIR, "figA1_medicaid_dependence_dist.pdf"), fig_a1, width = 8, height = 5)
cat("  Saved: figA1_medicaid_dependence_dist.pdf\n")

cat("\n=== All figures generated ===\n")
