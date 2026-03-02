## ============================================================
## 05_figures.R — All figures for the paper
## Paper: Where Medicaid Goes Dark (apep_0417 v3)
## Changes from v2: Split paired desert maps into individual
## figures (one map per figure) for better readability.
## 14 figures total (was 10).
## ============================================================

source("00_packages.R")

cat("\n=== Load Data ===\n")
panel <- readRDS(file.path(DATA_DIR, "analysis_panel.rds"))
panel_mdonly <- readRDS(file.path(DATA_DIR, "analysis_panel_mdonly.rds"))
results <- readRDS(file.path(DATA_DIR, "main_results.rds"))
robustness <- readRDS(file.path(DATA_DIR, "robustness_results.rds"))
shp <- readRDS(file.path(DATA_DIR, "county_shapes.rds"))
unwinding <- readRDS(file.path(DATA_DIR, "unwinding_treatment.rds"))

panel <- panel[!is.na(total_pop) & total_pop > 0 &
               state_fips %in% sprintf("%02d", c(1:56))]
panel_mdonly <- panel_mdonly[!is.na(total_pop) & total_pop > 0 &
                             state_fips %in% sprintf("%02d", c(1:56))]

cat("  Panel loaded:", nrow(panel), "rows\n")

# State outlines (shared across map figures)
state_shp <- shp |>
  group_by(STATEFP) |>
  summarize(geometry = st_union(geometry))

continental <- shp[!shp$STATEFP %in% c("02", "15", "60", "66", "69", "72", "78"), ]
state_continental <- state_shp[!state_shp$STATEFP %in% c("02", "15", "60", "66", "69", "72", "78"), ]

# Shared color scale for desert maps
desert_colors <- c("Zero" = "#67001f", "<0.5" = "#d6604d",
                    "0.5-1" = "#fddbc7", "1-2" = "#d1e5f0",
                    "2-5" = "#4393c3", ">5" = "#053061")

# Function to create a single desert map (always with legend for standalone use)
make_desert_map <- function(data, spec_name, title_override = NULL) {
  d <- data[data$specialty == spec_name, ]
  map_data <- merge(continental, d, by = "county_fips", all.x = TRUE)
  map_data$desert_cat <- cut(map_data$providers_per_10k,
                              breaks = c(-Inf, 0, 0.5, 1, 2, 5, Inf),
                              labels = c("Zero", "<0.5", "0.5-1", "1-2", "2-5", ">5"))
  map_data$desert_cat[is.na(map_data$desert_cat)] <- "Zero"

  ttl <- if (!is.null(title_override)) title_override else spec_name

  p <- ggplot(map_data) +
    geom_sf(aes(fill = desert_cat), color = NA, linewidth = 0) +
    geom_sf(data = state_continental, fill = NA, color = "gray40", linewidth = 0.2) +
    scale_fill_manual(values = desert_colors,
                      name = "Providers per 10K Pop",
                      drop = FALSE) +
    labs(title = ttl) +
    theme_void() +
    theme(plot.title = element_text(face = "bold", size = 12, hjust = 0.5),
          legend.position = "bottom",
          legend.direction = "horizontal",
          legend.key.size = unit(0.4, "cm"),
          legend.title = element_text(size = 9),
          legend.text = element_text(size = 8)) +
    guides(fill = guide_legend(nrow = 1))

  p
}

# ============================================================
# Figure 1: National Provider Trends (6 specialties)
# ============================================================
cat("\n--- Figure 1: Provider trends ---\n")

trends_total <- panel[, .(
  active_providers = sum(n_providers)
), by = .(specialty, quarter)]

trends_total[, year_qtr := as.Date(paste0(substr(quarter, 1, 4), "-",
  as.integer(substr(quarter, 6, 6)) * 3 - 2, "-01"))]

fig1 <- ggplot(trends_total, aes(x = year_qtr, y = active_providers,
                                  color = specialty)) +
  geom_line(linewidth = 0.8) +
  geom_vline(xintercept = as.Date("2023-04-01"), linetype = "dashed",
             color = "red", alpha = 0.7) +
  annotate("text", x = as.Date("2023-04-01"), y = Inf,
           label = "Unwinding\nbegins", vjust = 1.5, hjust = -0.1,
           size = 3, color = "red") +
  scale_x_date(date_labels = "%Y", date_breaks = "1 year") +
  scale_color_brewer(palette = "Set2") +
  labs(
    title = "Active Medicaid Clinicians by Specialty, 2018-2024",
    subtitle = "All clinicians (MD/DO + NP/PA) billing \u22654 Medicaid claims per quarter",
    x = NULL, y = "Active Clinicians (county-quarter sum)",
    color = "Specialty"
  ) +
  theme(legend.position = "right")

ggsave(file.path(FIG_DIR, "fig1_provider_trends.pdf"), fig1,
       width = 8, height = 5)
cat("  Saved fig1_provider_trends.pdf\n")

# ============================================================
# Figure 2: Indexed Provider Trends (2018Q1 = 100)
# ============================================================
cat("\n--- Figure 2: Indexed trends ---\n")

base <- trends_total[quarter == "2018Q1", .(specialty, base = active_providers)]
trends_idx <- merge(trends_total, base, by = "specialty")
trends_idx[, index := 100 * active_providers / base]

fig2 <- ggplot(trends_idx, aes(x = year_qtr, y = index, color = specialty)) +
  geom_line(linewidth = 0.9) +
  geom_hline(yintercept = 100, linetype = "dotted", alpha = 0.5) +
  geom_vline(xintercept = as.Date("2023-04-01"), linetype = "dashed",
             color = "red", alpha = 0.7) +
  scale_x_date(date_labels = "%Y", date_breaks = "1 year") +
  scale_color_brewer(palette = "Set2") +
  labs(
    title = "Medicaid Clinician Supply by Specialty, Indexed to 2018Q1",
    subtitle = "Index = 100 in 2018Q1. Red line = unwinding start.",
    x = NULL, y = "Index (2018Q1 = 100)",
    color = "Specialty"
  ) +
  theme(legend.position = "right")

ggsave(file.path(FIG_DIR, "fig2_indexed_trends.pdf"), fig2,
       width = 8, height = 5)
cat("  Saved fig2_indexed_trends.pdf\n")

# ============================================================
# Figure 3: Unwinding Intensity Map
# ============================================================
cat("\n--- Figure 3: Unwinding intensity map ---\n")

state_disenroll <- merge(state_continental,
  unwinding[, .(STATEFP = state_fips, net_disenroll_pct)],
  by = "STATEFP", all.x = TRUE)

fig3 <- ggplot(state_disenroll) +
  geom_sf(aes(fill = net_disenroll_pct), color = "white", linewidth = 0.3) +
  scale_fill_viridis_c(option = "magma", direction = -1,
                        name = "Net\nDisenrollment\n(%)",
                        limits = c(0, 35)) +
  labs(
    title = "Medicaid Unwinding Intensity by State",
    subtitle = "Net enrollment decline (%) from peak to completion"
  ) +
  theme_void() +
  theme(legend.position = "right")

ggsave(file.path(FIG_DIR, "fig3_unwinding_map.pdf"), fig3,
       width = 8, height = 5)
cat("  Saved fig3_unwinding_map.pdf\n")

# ============================================================
# Desert Maps: Prepare data (shared)
# ============================================================
cat("\n--- Preparing desert map data ---\n")

desert_2023 <- panel[quarter == "2023Q1" & !is.na(providers_per_10k),
  .(providers_per_10k = mean(providers_per_10k, na.rm = TRUE),
    n_providers = sum(n_providers),
    is_desert = all(is_desert)),
  by = .(county_fips, specialty)]

# ============================================================
# Figure 4: Primary Care Deserts
# ============================================================
cat("\n--- Figure 4: Primary Care deserts ---\n")
fig4 <- make_desert_map(desert_2023, "Primary Care")
ggsave(file.path(FIG_DIR, "fig4_desert_primary_care.pdf"), fig4,
       width = 8, height = 4.5)
cat("  Saved fig4_desert_primary_care.pdf\n")

# ============================================================
# Figure 5: Dental Deserts
# ============================================================
cat("\n--- Figure 5: Dental deserts ---\n")
fig5 <- make_desert_map(desert_2023, "Dental")
ggsave(file.path(FIG_DIR, "fig5_desert_dental.pdf"), fig5,
       width = 8, height = 4.5)
cat("  Saved fig5_desert_dental.pdf\n")

# ============================================================
# Figure 6: Psychiatry Deserts
# ============================================================
cat("\n--- Figure 6: Psychiatry deserts ---\n")
fig6 <- make_desert_map(desert_2023, "Psychiatry")
ggsave(file.path(FIG_DIR, "fig6_desert_psychiatry.pdf"), fig6,
       width = 8, height = 4.5)
cat("  Saved fig6_desert_psychiatry.pdf\n")

# ============================================================
# Figure 7: Behavioral Health Deserts
# ============================================================
cat("\n--- Figure 7: Behavioral Health deserts ---\n")
fig7 <- make_desert_map(desert_2023, "Behavioral Health")
ggsave(file.path(FIG_DIR, "fig7_desert_bh.pdf"), fig7,
       width = 8, height = 4.5)
cat("  Saved fig7_desert_bh.pdf\n")

# ============================================================
# Figure 8: OB-GYN Deserts
# ============================================================
cat("\n--- Figure 8: OB-GYN deserts ---\n")
fig8 <- make_desert_map(desert_2023, "OB-GYN")
ggsave(file.path(FIG_DIR, "fig8_desert_obgyn.pdf"), fig8,
       width = 8, height = 4.5)
cat("  Saved fig8_desert_obgyn.pdf\n")

# ============================================================
# Figure 9: Surgery Deserts
# ============================================================
cat("\n--- Figure 9: Surgery deserts ---\n")
fig9_map <- make_desert_map(desert_2023, "Surgery")
ggsave(file.path(FIG_DIR, "fig9_desert_surgery.pdf"), fig9_map,
       width = 8, height = 4.5)
cat("  Saved fig9_desert_surgery.pdf\n")

# ============================================================
# Figure 10: No-NP/PA Primary Care (comparison)
# ============================================================
cat("\n--- Figure 10: No-NP/PA Primary Care ---\n")

desert_2023_mdonly <- panel_mdonly[quarter == "2023Q1" & !is.na(providers_per_10k),
  .(providers_per_10k = mean(providers_per_10k, na.rm = TRUE),
    n_providers = sum(n_providers),
    is_desert = all(is_desert)),
  by = .(county_fips, specialty)]

fig10 <- make_desert_map(desert_2023_mdonly, "Primary Care",
                          title_override = "Primary Care: No NP/PA")
ggsave(file.path(FIG_DIR, "fig10_desert_pc_no_nppa.pdf"), fig10,
       width = 8, height = 4.5)
cat("  Saved fig10_desert_pc_no_nppa.pdf\n")

# ============================================================
# Figure 11: All Clinicians Primary Care (comparison)
# ============================================================
cat("\n--- Figure 11: All Clinicians Primary Care ---\n")
fig11 <- make_desert_map(desert_2023, "Primary Care",
                          title_override = "Primary Care: All Clinicians (incl. NPs)")
ggsave(file.path(FIG_DIR, "fig11_desert_pc_all.pdf"), fig11,
       width = 8, height = 4.5)
cat("  Saved fig11_desert_pc_all.pdf\n")

# ============================================================
# Figure 12: Urban vs Rural Desert Share Over Time
# ============================================================
cat("\n--- Figure 12: Urban vs rural deserts ---\n")

desert_trend <- panel[!is.na(urban) & !is.na(is_desert), .(
  pct_desert = 100 * mean(is_desert)
), by = .(urban, specialty, quarter)]

desert_trend[, year_qtr := as.Date(paste0(substr(quarter, 1, 4), "-",
  as.integer(substr(quarter, 6, 6)) * 3 - 2, "-01"))]
desert_trend[, area := ifelse(urban, "Urban (Metro)", "Rural (Non-Metro)")]

fig12 <- ggplot(desert_trend[specialty %in% c("Primary Care", "Psychiatry",
                                              "Behavioral Health", "OB-GYN")],
               aes(x = year_qtr, y = pct_desert, color = area)) +
  geom_line(linewidth = 0.7) +
  geom_vline(xintercept = as.Date("2023-04-01"), linetype = "dashed",
             color = "red", alpha = 0.5) +
  facet_wrap(~specialty) +
  scale_y_continuous(limits = c(0, 100), breaks = seq(0, 100, 20)) +
  scale_color_manual(values = c("Urban (Metro)" = "#2166ac",
                                 "Rural (Non-Metro)" = "#b2182b")) +
  scale_x_date(date_labels = "%Y", date_breaks = "2 years") +
  labs(
    title = "Medicaid Desert Counties by Specialty: Urban vs. Rural",
    subtitle = "% of county-quarters with <1 active clinician per 10,000 population",
    x = NULL, y = "% Counties in Desert Status",
    color = NULL
  )

ggsave(file.path(FIG_DIR, "fig12_urban_rural_deserts.pdf"), fig12,
       width = 9, height = 6)
cat("  Saved fig12_urban_rural_deserts.pdf\n")

# ============================================================
# Figure 13: Event Study — Pooled
# ============================================================
cat("\n--- Figure 13: Event study ---\n")

m_es <- results$m_es
es_coefs <- as.data.table(coeftable(m_es))
es_coefs[, rel_q := as.integer(str_extract(rownames(coeftable(m_es)), "-?\\d+"))]
es_coefs <- es_coefs[!is.na(rel_q)]
names(es_coefs)[1:4] <- c("estimate", "se", "t", "p")

es_coefs <- rbind(es_coefs,
  data.table(estimate = 0, se = 0, t = 0, p = 1, rel_q = -1),
  fill = TRUE)
es_coefs <- es_coefs[order(rel_q)]
es_coefs[, ci_lo := estimate - 1.96 * se]
es_coefs[, ci_hi := estimate + 1.96 * se]

fig13 <- ggplot(es_coefs, aes(x = rel_q, y = estimate)) +
  geom_hline(yintercept = 0, linetype = "dashed", alpha = 0.5) +
  geom_vline(xintercept = -0.5, linetype = "dashed", color = "red", alpha = 0.5) +
  geom_ribbon(aes(ymin = ci_lo, ymax = ci_hi), fill = "steelblue", alpha = 0.2) +
  geom_point(size = 2, color = "steelblue") +
  geom_line(color = "steelblue", linewidth = 0.6) +
  scale_x_continuous(breaks = seq(-8, 5, 1)) +
  labs(
    title = "Event Study: Medicaid Unwinding and Provider Supply",
    subtitle = "Interaction of relative quarter \u00d7 state disenrollment intensity",
    x = "Quarters Relative to Unwinding Start",
    y = "Coefficient (log providers)"
  )

ggsave(file.path(FIG_DIR, "fig13_event_study.pdf"), fig13,
       width = 8, height = 5)
cat("  Saved fig13_event_study.pdf\n")

# ============================================================
# Figure 14: Permutation Inference Distribution
# ============================================================
cat("\n--- Figure 14: RI distribution ---\n")

ri_dist <- data.table(coef = robustness$ri_distribution)

fig14 <- ggplot(ri_dist, aes(x = coef)) +
  geom_histogram(bins = 40, fill = "gray70", color = "gray50", alpha = 0.8) +
  geom_vline(xintercept = robustness$ri_observed, color = "red",
             linewidth = 1, linetype = "solid") +
  annotate("text", x = robustness$ri_observed, y = Inf,
           label = sprintf("Observed\n(p = %.3f)", robustness$ri_pvalue),
           vjust = 1.5, hjust = -0.1, color = "red", size = 3.5) +
  labs(
    title = "Permutation Inference: Distribution of Placebo Coefficients",
    subtitle = "500 permutations of state treatment timing",
    x = "Coefficient (log providers)", y = "Count"
  )

ggsave(file.path(FIG_DIR, "fig14_ri_distribution.pdf"), fig14,
       width = 7, height = 4.5)
cat("  Saved fig14_ri_distribution.pdf\n")

cat("\nAll figures saved to:", FIG_DIR, "\n")
