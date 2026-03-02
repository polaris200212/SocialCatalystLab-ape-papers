###############################################################################
# 05_figures.R — Generate all figures
# Paper: Flood Re and the Capitalization of Climate Risk Insurance
# APEP-0484
###############################################################################

source("00_packages.R")

cat("=== Phase 5: Figure Generation ===\n")

# ---- Load data and models ----
ppd <- read_parquet(file.path(data_dir, "analysis_panel.parquet"))
setDT(ppd)
load(file.path(data_dir, "main_models.RData"))

rob_exists <- file.exists(file.path(data_dir, "robustness_models.RData"))
if (rob_exists) load(file.path(data_dir, "robustness_models.RData"))

# ---- Figure 1: Raw price trends by flood zone × eligibility ----
cat("  Figure 1: Price trends...\n")

trends <- ppd[year >= 2009, .(
  mean_price = mean(price),
  median_price = median(price),
  log_mean = mean(log_price),
  n = .N
), by = .(year, in_flood_zone, flood_re_eligible)]

trends[, group := paste0(
  ifelse(in_flood_zone, "Flood Zone", "No Flood Risk"), " — ",
  ifelse(flood_re_eligible, "Pre-2009 (Eligible)", "Post-2009 (Ineligible)")
)]

fig1 <- ggplot(trends, aes(x = year, y = log_mean, color = group, linetype = group)) +
  geom_line(linewidth = 0.8) +
  geom_vline(xintercept = 2016, linetype = "dashed", color = "grey50", linewidth = 0.5) +
  annotate("text", x = 2016.3, y = max(trends$log_mean) - 0.05,
           label = "Flood Re\n(April 2016)", size = 3, hjust = 0, color = "grey40") +
  scale_color_manual(values = c(
    "Flood Zone — Pre-2009 (Eligible)" = "#d62728",
    "Flood Zone — Post-2009 (Ineligible)" = "#ff7f0e",
    "No Flood Risk — Pre-2009 (Eligible)" = "#1f77b4",
    "No Flood Risk — Post-2009 (Ineligible)" = "#aec7e8"
  )) +
  scale_linetype_manual(values = c(
    "Flood Zone — Pre-2009 (Eligible)" = "solid",
    "Flood Zone — Post-2009 (Ineligible)" = "dashed",
    "No Flood Risk — Pre-2009 (Eligible)" = "solid",
    "No Flood Risk — Post-2009 (Ineligible)" = "dashed"
  )) +
  labs(
    title = "Mean Log Transaction Price by Flood Risk and Construction Vintage",
    x = "Year", y = "Mean Log Price",
    color = NULL, linetype = NULL
  ) +
  theme(legend.position = "bottom",
        legend.text = element_text(size = 8))

ggsave(file.path(fig_dir, "fig1_price_trends.pdf"), fig1,
       width = 8, height = 5.5)

# ---- Figure 2: Event study (DDD coefficients) ----
cat("  Figure 2: Event study...\n")

es <- fread(file.path(tab_dir, "event_study_coefs.csv"))

fig2 <- ggplot(es, aes(x = year, y = estimate)) +
  geom_hline(yintercept = 0, color = "grey50", linewidth = 0.3) +
  geom_vline(xintercept = 2015.5, linetype = "dashed", color = "grey50", linewidth = 0.5) +
  geom_ribbon(aes(ymin = ci_lo, ymax = ci_hi), fill = "#1f77b4", alpha = 0.2) +
  geom_point(color = "#1f77b4", size = 2) +
  geom_line(color = "#1f77b4", linewidth = 0.6) +
  annotate("text", x = 2015.7, y = max(es$ci_hi, na.rm = TRUE) * 0.9,
           label = "Flood Re\n(April 2016)", size = 3, hjust = 0, color = "grey40") +
  labs(
    title = "Event Study: DDD Coefficients by Year",
    subtitle = "Flood Zone x Pre-2009 Build x Year (ref: 2015)",
    x = "Year", y = "DDD Coefficient (Log Price)"
  )

ggsave(file.path(fig_dir, "fig2_event_study.pdf"), fig2,
       width = 8, height = 5)

# ---- Figure 3: Heterogeneity by property type ----
cat("  Figure 3: Heterogeneity by property type...\n")

het <- fread(file.path(tab_dir, "heterogeneity_property_type.csv"))
het[, property_label := fcase(
  property_type == "D", "Detached",
  property_type == "S", "Semi-detached",
  property_type == "T", "Terraced",
  property_type == "F", "Flat"
)]
het[, ci_lo := estimate - 1.96 * se]
het[, ci_hi := estimate + 1.96 * se]

fig3 <- ggplot(het, aes(x = property_label, y = estimate)) +
  geom_hline(yintercept = 0, color = "grey50", linewidth = 0.3) +
  geom_pointrange(aes(ymin = ci_lo, ymax = ci_hi), color = "#1f77b4", size = 0.6) +
  labs(
    title = "DDD Coefficient by Property Type",
    x = NULL, y = "DDD Coefficient (Log Price)"
  )

ggsave(file.path(fig_dir, "fig3_heterogeneity_type.pdf"), fig3,
       width = 6, height = 4)

# ---- Figure 4: Heterogeneity by price quartile ----
cat("  Figure 4: Heterogeneity by price quartile...\n")

het_pq <- fread(file.path(tab_dir, "heterogeneity_price_quartile.csv"))
het_pq[, ci_lo := estimate - 1.96 * se]
het_pq[, ci_hi := estimate + 1.96 * se]

fig4 <- ggplot(het_pq, aes(x = quartile, y = estimate)) +
  geom_hline(yintercept = 0, color = "grey50", linewidth = 0.3) +
  geom_pointrange(aes(ymin = ci_lo, ymax = ci_hi), color = "#d62728", size = 0.6) +
  labs(
    title = "DDD Coefficient by Property Price Quartile",
    subtitle = "Higher quartiles = higher-value properties (proxy for Council Tax band)",
    x = "Price Quartile", y = "DDD Coefficient (Log Price)"
  )

ggsave(file.path(fig_dir, "fig4_heterogeneity_price.pdf"), fig4,
       width = 6, height = 4)

# ---- Figure 5: Moral hazard — new construction in flood zones ----
cat("  Figure 5: Moral hazard (new builds)...\n")

mh <- fread(file.path(tab_dir, "moral_hazard_newbuild.csv"))
mh[, group := ifelse(in_flood_zone, "Flood Zone (High/Medium)", "Non-Flood Zone")]

fig5 <- ggplot(mh[year >= 2005], aes(x = year, y = share_new_build * 100, color = group)) +
  geom_line(linewidth = 0.8) +
  geom_vline(xintercept = 2016, linetype = "dashed", color = "grey50") +
  scale_color_manual(values = c("Flood Zone (High/Medium)" = "#d62728",
                                "Non-Flood Zone" = "#1f77b4")) +
  labs(
    title = "Share of Transactions That Are New Builds",
    subtitle = "Flood Zone vs. Non-Flood Zone",
    x = "Year", y = "New Build Share (%)",
    color = NULL
  ) +
  theme(legend.position = "bottom")

ggsave(file.path(fig_dir, "fig5_moral_hazard.pdf"), fig5,
       width = 7, height = 4.5)

# ---- Figure 6: Leave-one-out stability ----
cat("  Figure 6: Leave-one-out...\n")

if (rob_exists && exists("loo_dt")) {
  loo_dt[, ci_lo := ddd_coef - 1.96 * ddd_se]
  loo_dt[, ci_hi := ddd_coef + 1.96 * ddd_se]

  # Get main estimate for reference line
  main_coef <- main_coefs$m2$coef

  fig6 <- ggplot(loo_dt, aes(x = reorder(excluded_area, ddd_coef), y = ddd_coef)) +
    geom_hline(yintercept = main_coef, color = "#d62728", linetype = "dashed") +
    geom_hline(yintercept = 0, color = "grey50", linewidth = 0.3) +
    geom_pointrange(aes(ymin = ci_lo, ymax = ci_hi), color = "#1f77b4", size = 0.4) +
    coord_flip() +
    labs(
      title = "Leave-One-Out Stability: DDD Coefficient",
      subtitle = "Red dashed line = full sample estimate",
      x = "Excluded Postcode Area", y = "DDD Coefficient"
    )

  ggsave(file.path(fig_dir, "fig6_loo.pdf"), fig6,
         width = 6, height = 5)
}

# ---- Figure 7: Robustness summary (coefficient comparison) ----
cat("  Figure 7: Robustness summary...\n")

if (rob_exists && exists("rob_summary")) {
  rob_summary[, ci_lo := Coefficient - 1.96 * SE]
  rob_summary[, ci_hi := Coefficient + 1.96 * SE]

  fig7 <- ggplot(rob_summary, aes(x = reorder(Test, Coefficient), y = Coefficient)) +
    geom_hline(yintercept = 0, color = "grey50", linewidth = 0.3) +
    geom_pointrange(aes(ymin = ci_lo, ymax = ci_hi), color = "#1f77b4", size = 0.5) +
    coord_flip() +
    labs(
      title = "Robustness: DDD Coefficient Across Specifications",
      x = NULL, y = "DDD Coefficient (Log Price)"
    )

  ggsave(file.path(fig_dir, "fig7_robustness.pdf"), fig7,
         width = 7, height = 5)
}

# ---- Figure 8: Transaction volume trends ----
cat("  Figure 8: Transaction volumes...\n")

vol_trends <- ppd[year >= 2005, .N, by = .(year, quarter, in_flood_zone)]
vol_trends[, yearq := year + (quarter - 1) / 4]
vol_trends[, group := ifelse(in_flood_zone, "Flood Zone", "Non-Flood Zone")]

fig8 <- ggplot(vol_trends, aes(x = yearq, y = N / 1000, color = group)) +
  geom_line(linewidth = 0.6) +
  geom_vline(xintercept = 2016.25, linetype = "dashed", color = "grey50") +
  scale_color_manual(values = c("Flood Zone" = "#d62728", "Non-Flood Zone" = "#1f77b4")) +
  labs(
    title = "Quarterly Transaction Volume",
    x = "Year-Quarter", y = "Transactions (thousands)",
    color = NULL
  ) +
  theme(legend.position = "bottom")

ggsave(file.path(fig_dir, "fig8_volume_trends.pdf"), fig8,
       width = 7, height = 4.5)

cat("\nAll figures generated.\n")
