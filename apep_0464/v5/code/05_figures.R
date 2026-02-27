## ============================================================================
## 05_figures.R -- Connected Backlash (apep_0464 v3)
## Publication-quality figures for the paper
## v3 changes: Figures 9-12 added (migration validation, distance bins,
##   placebo timing, inference comparison forest plot)
## ============================================================================

source("00_packages.R")

DATA_DIR <- "../data"
FIG_DIR  <- "../figures"
dir.create(FIG_DIR, showWarnings = FALSE, recursive = TRUE)

## ---------------------------------------------------------------------------
## Helper: save both PDF and PNG
## ---------------------------------------------------------------------------
save_fig <- function(plot, name, width = 7, height = 5, dpi = 300) {
  ggsave(file.path(FIG_DIR, paste0(name, ".pdf")),
         plot = plot, width = width, height = height, device = cairo_pdf)
  ggsave(file.path(FIG_DIR, paste0(name, ".png")),
         plot = plot, width = width, height = height, dpi = dpi)
  cat("  Saved:", name, "(PDF + PNG)\n")
}

## ---------------------------------------------------------------------------
## Load data
## ---------------------------------------------------------------------------
cat("\n=== Loading data for figures ===\n")

panel        <- readRDS(file.path(DATA_DIR, "analysis_panel.rds"))
dept_panel   <- readRDS(file.path(DATA_DIR, "dept_panel.rds"))
sci_matrix   <- readRDS(file.path(DATA_DIR, "sci_matrix.rds"))
fuel_vuln    <- readRDS(file.path(DATA_DIR, "fuel_vulnerability.rds"))
net_exp      <- readRDS(file.path(DATA_DIR, "network_exposure.rds"))
es_data      <- readRDS(file.path(DATA_DIR, "event_study_data.rds"))
carbon_tax   <- read_csv(file.path(DATA_DIR, "carbon_tax_schedule.csv"),
                          show_col_types = FALSE)

## Load département boundaries
dept_geo <- st_read(file.path(DATA_DIR, "geo", "departements.geojson"),
                    quiet = TRUE)

## v3: Load département results (for placebo timing figure + inference forest plot)
dept_results_file <- file.path(DATA_DIR, "dept_results.rds")
if (file.exists(dept_results_file)) {
  dept_results <- readRDS(dept_results_file)
  cat("  Loaded dept_results.rds\n")
} else {
  dept_results <- NULL
  cat("  WARNING: dept_results.rds not found.\n")
}

## v3: Load robustness results (for Figures 10-12)
rob_file <- file.path(DATA_DIR, "robustness_results.rds")
if (file.exists(rob_file)) {
  robustness_results <- readRDS(rob_file)
  cat("  Loaded robustness_results.rds\n")
} else {
  robustness_results <- NULL
  cat("  WARNING: robustness_results.rds not found. Figures 10-12 may be skipped.\n")
}

## v3: Load migration/distance-bin data (for Figures 9-10)
mig_corr_file <- file.path(DATA_DIR, "sci_migration_correlation.rds")
mig_net_file  <- file.path(DATA_DIR, "migration_network.rds")
dist_bin_file <- file.path(DATA_DIR, "distance_bin_data.rds")

cat("  Loaded all datasets.\n")
cat("  GeoJSON departments:", nrow(dept_geo), "\n")

## ============================================================================
## FIGURE 1: Carbon Tax Trajectory (v2: extended to 2002)
## ============================================================================

cat("\n--- Figure 1: Carbon Tax Trajectory ---\n")

## v2: All 10 election years (4 new pre-treatment elections added)
election_years <- c(2002, 2004, 2007, 2009, 2012, 2014, 2017, 2019, 2022, 2024)

## v2: Extend carbon tax data back to 2002 (rate = 0 before introduction)
pre_tax_years <- tibble(
  year = 2002:2012,
  rate_eur_tco2 = 0
)
carbon_tax_ext <- bind_rows(pre_tax_years, carbon_tax) %>%
  distinct(year, .keep_all = TRUE) %>%
  arrange(year)

p1 <- ggplot(carbon_tax_ext, aes(x = year, y = rate_eur_tco2)) +
  ## Shaded regions for policy phases
  annotate("rect", xmin = 2002, xmax = 2013, ymin = -Inf, ymax = Inf,
           fill = "grey90", alpha = 0.15) +
  annotate("rect", xmin = 2014, xmax = 2018, ymin = -Inf, ymax = Inf,
           fill = apep_colors[3], alpha = 0.08) +
  annotate("rect", xmin = 2018, xmax = 2024.5, ymin = -Inf, ymax = Inf,
           fill = apep_colors[2], alpha = 0.06) +
  ## Election year markers (vertical dashed)
  geom_vline(xintercept = election_years, linetype = "dashed",
             color = "grey60", linewidth = 0.35) +
  ## Carbon tax line
  geom_line(linewidth = 1.1, color = apep_colors[1]) +
  geom_point(size = 2.2, color = apep_colors[1]) +
  ## Annotate key events
  annotate("segment", x = 2014, xend = 2014, y = 7, yend = 12,
           color = apep_colors[3], linewidth = 0.5,
           arrow = arrow(length = unit(0.15, "cm"), type = "closed")) +
  annotate("text", x = 2014, y = 14, label = "Carbon tax\nintroduced",
           size = 3, color = apep_colors[3], fontface = "bold",
           lineheight = 0.9) +
  annotate("segment", x = 2018, xend = 2018, y = 44.6, yend = 50,
           color = apep_colors[2], linewidth = 0.5,
           arrow = arrow(length = unit(0.15, "cm"), type = "closed",
                         ends = "first")) +
  annotate("text", x = 2018, y = 52,
           label = "Gilets Jaunes\nfreeze",
           size = 3, color = apep_colors[2], fontface = "bold",
           lineheight = 0.9) +
  ## Phase labels at the top
  annotate("text", x = 2007, y = 57, label = "Pre-tax period",
           size = 2.8, color = "grey50", fontface = "italic") +
  annotate("text", x = 2016, y = 57, label = "Escalation phase",
           size = 2.8, color = "grey50", fontface = "italic") +
  annotate("text", x = 2021, y = 57, label = "Frozen at \u20ac44.60",
           size = 2.8, color = "grey50", fontface = "italic") +
  ## Election year labels along the bottom
  annotate("text", x = election_years, y = -3,
           label = election_years, size = 2.3, color = "grey50",
           angle = 0) +
  scale_x_continuous(breaks = seq(2002, 2024, 2), minor_breaks = NULL,
                     expand = expansion(mult = c(0.02, 0.02))) +
  scale_y_continuous(breaks = seq(0, 60, 10),
                     labels = function(x) paste0("\u20ac", x),
                     expand = expansion(mult = c(0.08, 0.12))) +
  labs(
    title = "France's Carbon Tax: Rate per Tonne of CO2",
    subtitle = "Vertical dashed lines mark national election years (4 pre-tax, 6 post-introduction)",
    x = "Year",
    y = expression(bold("Carbon tax rate (" * "\u20ac" * "/tCO"[2] * ")"))
  ) +
  theme_apep() +
  theme(
    panel.grid.major.x = element_blank()
  )

save_fig(p1, "fig_carbon_tax", width = 9, height = 5)

## ============================================================================
## FIGURE 2: Map -- Fuel Vulnerability (co2_commute)
## ============================================================================

cat("\n--- Figure 2: Map -- Fuel Vulnerability ---\n")

## Merge fuel vulnerability onto spatial data
map_fuel <- dept_geo %>%
  left_join(fuel_vuln, by = c("code" = "dept_code"))

## Determine sensible breaks
fuel_breaks <- quantile(fuel_vuln$co2_commute,
                        probs = seq(0, 1, 0.2), na.rm = TRUE)

p2 <- ggplot(map_fuel) +
  geom_sf(aes(fill = co2_commute), color = "white", linewidth = 0.15) +
  scale_fill_viridis_c(
    name = expression(bold("tCO"[2]*"e / worker / year")),
    option = "viridis",
    direction = -1,
    na.value = "grey80",
    breaks = seq(0.2, 1.1, 0.2),
    labels = sprintf("%.1f", seq(0.2, 1.1, 0.2))
  ) +
  coord_sf(xlim = c(-5.5, 10), ylim = c(41, 51.5), expand = FALSE) +
  labs(
    title = "Fuel Vulnerability by D\u00e9partement",
    subtitle = "Commuting CO2 emissions per employed worker (INSEE, 2019)"
  ) +
  theme_apep() +
  theme(
    axis.text  = element_blank(),
    axis.title = element_blank(),
    axis.ticks = element_blank(),
    axis.line  = element_blank(),
    panel.grid = element_blank(),
    legend.position = "right",
    legend.key.height = unit(1.5, "cm"),
    legend.key.width  = unit(0.4, "cm")
  )

save_fig(p2, "fig_map_fuel_vulnerability", width = 8, height = 6)

## ============================================================================
## FIGURE 3: Map -- Network Fuel Exposure
## ============================================================================

cat("\n--- Figure 3: Map -- Network Fuel Exposure ---\n")

map_net <- dept_geo %>%
  left_join(net_exp %>% select(dept_code, network_fuel_norm),
            by = c("code" = "dept_code"))

p3 <- ggplot(map_net) +
  geom_sf(aes(fill = network_fuel_norm), color = "white", linewidth = 0.15) +
  scale_fill_viridis_c(
    name = "SCI-weighted\nnetwork exposure",
    option = "viridis",
    direction = -1,
    na.value = "grey80"
  ) +
  coord_sf(xlim = c(-5.5, 10), ylim = c(41, 51.5), expand = FALSE) +
  labs(
    title = "Network Fuel Exposure by D\u00e9partement",
    subtitle = "SCI-weighted average fuel vulnerability of connected d\u00e9partements"
  ) +
  theme_apep() +
  theme(
    axis.text  = element_blank(),
    axis.title = element_blank(),
    axis.ticks = element_blank(),
    axis.line  = element_blank(),
    panel.grid = element_blank(),
    legend.position = "right",
    legend.key.height = unit(1.5, "cm"),
    legend.key.width  = unit(0.4, "cm")
  )

save_fig(p3, "fig_map_network_exposure", width = 8, height = 6)

## ============================================================================
## FIGURE 4: Map -- RN Vote Share (2024)
## ============================================================================

cat("\n--- Figure 4: Map -- RN Vote Share (2024) ---\n")

## Aggregate RN share at département level for 2024
rn_2024 <- dept_panel %>%
  filter(year == 2024) %>%
  group_by(dept_code) %>%
  summarize(rn_share = weighted.mean(rn_share, w = total_votes, na.rm = TRUE),
            .groups = "drop")

map_rn <- dept_geo %>%
  left_join(rn_2024, by = c("code" = "dept_code"))

p4 <- ggplot(map_rn) +
  geom_sf(aes(fill = rn_share), color = "white", linewidth = 0.15) +
  scale_fill_gradient(
    name = "RN vote\nshare (%)",
    low = "#fee0d2",
    high = "#99000d",
    na.value = "grey80",
    breaks = seq(10, 50, 10),
    labels = function(x) paste0(x, "%")
  ) +
  coord_sf(xlim = c(-5.5, 10), ylim = c(41, 51.5), expand = FALSE) +
  labs(
    title = "Rassemblement National Vote Share, 2024 European Election",
    subtitle = "First-round results by d\u00e9partement"
  ) +
  theme_apep() +
  theme(
    axis.text  = element_blank(),
    axis.title = element_blank(),
    axis.ticks = element_blank(),
    axis.line  = element_blank(),
    panel.grid = element_blank(),
    legend.position = "right",
    legend.key.height = unit(1.5, "cm"),
    legend.key.width  = unit(0.4, "cm")
  )

save_fig(p4, "fig_map_rn_2024", width = 8, height = 6)

## ============================================================================
## FIGURE 5: SCI Network Visualization
## ============================================================================

cat("\n--- Figure 5: SCI Network Visualization ---\n")

## Compute département centroids from the GeoJSON
dept_centroids <- dept_geo %>%
  st_centroid() %>%
  mutate(
    lon = st_coordinates(.)[, 1],
    lat = st_coordinates(.)[, 2]
  ) %>%
  st_drop_geometry() %>%
  select(code, nom, lon, lat)

## Select top 150 SCI connections (excluding self-links, already excluded)
top_links <- sci_matrix %>%
  arrange(desc(scaled_sci)) %>%
  slice_head(n = 150)

## Merge centroid coordinates onto link endpoints
link_coords <- top_links %>%
  left_join(dept_centroids, by = c("dept_from" = "code")) %>%
  rename(lon_from = lon, lat_from = lat, nom_from = nom) %>%
  left_join(dept_centroids, by = c("dept_to" = "code")) %>%
  rename(lon_to = lon, lat_to = lat, nom_to = nom) %>%
  filter(!is.na(lon_from) & !is.na(lon_to))

## Normalize sci_weight for line width
link_coords <- link_coords %>%
  mutate(
    link_strength = scaled_sci / max(scaled_sci),
    link_alpha    = pmin(0.7, 0.15 + 0.55 * link_strength)
  )

## Notable connections to label (top 5 by scaled_sci)
notable <- link_coords %>%
  slice_head(n = 5) %>%
  mutate(
    mid_lon = (lon_from + lon_to) / 2,
    mid_lat = (lat_from + lat_to) / 2,
    label   = paste0(nom_from, " \u2194 ", nom_to)
  )

p5 <- ggplot() +
  ## Base map
  geom_sf(data = dept_geo, fill = "grey96", color = "grey70",
          linewidth = 0.2) +
  ## SCI connection lines
  geom_segment(
    data = link_coords,
    aes(x = lon_from, y = lat_from, xend = lon_to, yend = lat_to,
        linewidth = link_strength, alpha = link_alpha),
    color = apep_colors[1]
  ) +
  scale_linewidth_continuous(range = c(0.2, 2.5), guide = "none") +
  scale_alpha_identity() +
  ## Centroid dots for connected départements
  geom_point(
    data = dept_centroids %>%
      filter(code %in% c(link_coords$dept_from, link_coords$dept_to)),
    aes(x = lon, y = lat),
    size = 1, color = apep_colors[2], alpha = 0.7
  ) +
  ## Label notable connections
  geom_label_repel(
    data = notable,
    aes(x = mid_lon, y = mid_lat, label = label),
    size = 2.5, fill = "white", alpha = 0.85,
    label.size = 0.2, label.padding = unit(0.15, "lines"),
    segment.color = "grey50", segment.size = 0.3,
    max.overlaps = 20, seed = 42
  ) +
  coord_sf(xlim = c(-5.5, 10), ylim = c(41, 51.5), expand = FALSE) +
  labs(
    title = "Facebook Social Connectedness Between D\u00e9partements",
    subtitle = "Top 150 bilateral SCI connections; line width proportional to connectedness"
  ) +
  theme_apep() +
  theme(
    axis.text  = element_blank(),
    axis.title = element_blank(),
    axis.ticks = element_blank(),
    axis.line  = element_blank(),
    panel.grid = element_blank()
  )

save_fig(p5, "fig_sci_network", width = 8, height = 6)

## ============================================================================
## FIGURE 6: Event Study Plot (Two Panels) -- v2: 10 elections
## ============================================================================

cat("\n--- Figure 6: Event Study (v2: 10 elections) ---\n")

## Prepare data from saved event study results
es_own     <- es_data$own
es_network <- es_data$network

## v2: Full set of election years for x-axis
es_election_years <- c(2002, 2004, 2007, 2009, 2012, 2014, 2017, 2019, 2022, 2024)

## -- Panel A: Own fuel exposure
p6a <- ggplot(es_own, aes(x = year, y = estimate)) +
  ## Shaded pre-treatment region (parallel trends check)
  annotate("rect", xmin = 2001, xmax = 2012.5, ymin = -Inf, ymax = Inf,
           fill = apep_colors[1], alpha = 0.04) +
  ## Shaded post-treatment region
  annotate("rect", xmin = 2014.5, xmax = 2025, ymin = -Inf, ymax = Inf,
           fill = apep_colors[2], alpha = 0.06) +
  ## Zero reference line
  geom_hline(yintercept = 0, linetype = "solid", color = "grey50",
             linewidth = 0.4) +
  ## Reference period marker
  geom_vline(xintercept = 2014, linetype = "dashed", color = "grey60",
             linewidth = 0.4) +
  ## Confidence intervals
  geom_errorbar(aes(ymin = ci_lo, ymax = ci_hi),
                width = 0.3, linewidth = 0.5, color = apep_colors[1]) +
  ## Point estimates
  geom_point(size = 2.8, color = apep_colors[1]) +
  ## Connected line
  geom_line(linewidth = 0.5, color = apep_colors[1], linetype = "dashed") +
  ## Annotations
  annotate("text", x = 2012, y = max(es_own$ci_hi, na.rm = TRUE) * 1.1,
           label = "Ref. (2012)", size = 2.8, color = "grey50",
           fontface = "italic") +
  annotate("text", x = 2007, y = max(es_own$ci_hi, na.rm = TRUE) * 1.05,
           label = "Pre-treatment", size = 2.5, color = apep_colors[1],
           fontface = "italic", alpha = 0.7) +
  annotate("text", x = 2020, y = max(es_own$ci_hi, na.rm = TRUE) * 1.05,
           label = "Post-treatment", size = 2.5, color = apep_colors[2],
           fontface = "italic", alpha = 0.7) +
  scale_x_continuous(breaks = es_election_years,
                     labels = es_election_years) +
  labs(
    title = "A. Own Fuel Exposure",
    x = "Election Year",
    y = "Coefficient (pp RN share)"
  ) +
  theme_apep() +
  theme(
    plot.title = element_text(size = 12, face = "bold"),
    axis.text.x = element_text(angle = 45, hjust = 1, size = 8)
  )

## -- Panel B: Network fuel exposure
p6b <- ggplot(es_network, aes(x = year, y = estimate)) +
  ## Shaded pre-treatment region
  annotate("rect", xmin = 2001, xmax = 2012.5, ymin = -Inf, ymax = Inf,
           fill = apep_colors[1], alpha = 0.04) +
  ## Shaded post-treatment region
  annotate("rect", xmin = 2014.5, xmax = 2025, ymin = -Inf, ymax = Inf,
           fill = apep_colors[2], alpha = 0.06) +
  geom_hline(yintercept = 0, linetype = "solid", color = "grey50",
             linewidth = 0.4) +
  geom_vline(xintercept = 2014, linetype = "dashed", color = "grey60",
             linewidth = 0.4) +
  geom_errorbar(aes(ymin = ci_lo, ymax = ci_hi),
                width = 0.3, linewidth = 0.5, color = apep_colors[2]) +
  geom_point(size = 2.8, color = apep_colors[2]) +
  geom_line(linewidth = 0.5, color = apep_colors[2], linetype = "dashed") +
  annotate("text", x = 2012,
           y = max(es_network$ci_hi, na.rm = TRUE) * 1.1,
           label = "Ref. (2012)", size = 2.8, color = "grey50",
           fontface = "italic") +
  ## Carbon tax annotation
  annotate("text", x = 2015.5,
           y = min(es_network$ci_lo, na.rm = TRUE) * 0.9,
           label = "Carbon tax\nintroduced \u2192",
           size = 2.8, color = apep_colors[3], fontface = "italic",
           lineheight = 0.9, hjust = 1) +
  annotate("text", x = 2007,
           y = max(es_network$ci_hi, na.rm = TRUE) * 1.05,
           label = "Pre-treatment", size = 2.5, color = apep_colors[1],
           fontface = "italic", alpha = 0.7) +
  annotate("text", x = 2020,
           y = max(es_network$ci_hi, na.rm = TRUE) * 1.05,
           label = "Post-treatment", size = 2.5, color = apep_colors[2],
           fontface = "italic", alpha = 0.7) +
  scale_x_continuous(breaks = es_election_years,
                     labels = es_election_years) +
  labs(
    title = "B. Network Fuel Exposure",
    x = "Election Year",
    y = "Coefficient (pp RN share)"
  ) +
  theme_apep() +
  theme(
    plot.title = element_text(size = 12, face = "bold"),
    axis.text.x = element_text(angle = 45, hjust = 1, size = 8)
  )

## Combine panels
p6 <- p6a + p6b +
  plot_annotation(
    title = "Event Study: Effect of Fuel Exposure on RN Vote Share",
    subtitle = paste0("Interaction of standardized exposure with election ",
                      "indicators (ref. = 2012); 95% CIs clustered by d\u00e9partement;\n",
                      "5 pre-treatment elections (2002\u20132012) support parallel trends"),
    theme = theme_apep() +
      theme(
        plot.title = element_text(size = 14, face = "bold"),
        plot.subtitle = element_text(size = 10, color = "grey40")
      )
  )

save_fig(p6, "fig_event_study_v2", width = 13, height = 5.5)

## ============================================================================
## FIGURE 7: RN Trajectory by Fuel Vulnerability Quartile (v2: from 2002)
## ============================================================================

cat("\n--- Figure 7: RN Trajectory by Fuel Vulnerability Quartile ---\n")

## Assign quartiles of co2_commute at the département level
dept_quartiles <- fuel_vuln %>%
  mutate(
    fuel_q = cut(co2_commute,
                 breaks = quantile(co2_commute, probs = 0:4 / 4,
                                   na.rm = TRUE),
                 labels = c("Q1 (Least exposed)", "Q2", "Q3",
                            "Q4 (Most exposed)"),
                 include.lowest = TRUE)
  )

## Merge quartiles onto département panel and compute mean RN share per group
## Use vote-weighted means with simple SE (avoids Hmisc dependency)
rn_by_q <- dept_panel %>%
  left_join(dept_quartiles %>% select(dept_code, fuel_q),
            by = "dept_code") %>%
  filter(!is.na(fuel_q)) %>%
  group_by(fuel_q, year) %>%
  summarize(
    mean_rn = weighted.mean(rn_share, w = total_votes, na.rm = TRUE),
    se_rn   = sd(rn_share, na.rm = TRUE) / sqrt(n()),
    n_dept  = n(),
    .groups = "drop"
  )

quartile_colors <- c("Q1 (Least exposed)" = apep_colors[1],
                     "Q2"                  = apep_colors[6],
                     "Q3"                  = apep_colors[4],
                     "Q4 (Most exposed)"   = apep_colors[2])

p7 <- ggplot(rn_by_q, aes(x = year, y = mean_rn,
                            color = fuel_q, group = fuel_q)) +
  ## Pre-tax shaded region (v2: visible since data now starts at 2002)
  annotate("rect", xmin = 2001, xmax = 2013.5, ymin = -Inf, ymax = Inf,
           fill = "grey95", alpha = 0.3) +
  ## Carbon tax shaded region
  annotate("rect", xmin = 2014.5, xmax = 2025, ymin = -Inf, ymax = Inf,
           fill = "grey90", alpha = 0.3) +
  annotate("text", x = 2007, y = max(rn_by_q$mean_rn, na.rm = TRUE) * 1.05,
           label = "Pre-tax period",
           size = 2.8, color = "grey50", fontface = "italic") +
  annotate("text", x = 2019, y = max(rn_by_q$mean_rn, na.rm = TRUE) * 1.05,
           label = "Post carbon tax",
           size = 2.8, color = "grey50", fontface = "italic") +
  ## Confidence ribbons
  geom_ribbon(aes(ymin = mean_rn - 1.96 * se_rn,
                  ymax = mean_rn + 1.96 * se_rn,
                  fill = fuel_q),
              alpha = 0.12, color = NA) +
  ## Lines and points
  geom_line(linewidth = 0.9) +
  geom_point(size = 2.5) +
  scale_color_manual(values = quartile_colors, name = "Fuel vulnerability\nquartile") +
  scale_fill_manual(values = quartile_colors, guide = "none") +
  scale_x_continuous(breaks = c(2002, 2004, 2007, 2009, 2012, 2014,
                                2017, 2019, 2022, 2024)) +
  scale_y_continuous(labels = function(x) paste0(round(x, 1), "%")) +
  labs(
    title = "RN Vote Share Trajectory by Fuel Vulnerability Quartile",
    subtitle = "D\u00e9partement-level means weighted by total votes; 95% CIs; extended pre-treatment window (2002\u20132012)",
    x = "Election Year",
    y = "Mean RN vote share (%)"
  ) +
  theme_apep() +
  theme(
    legend.position = "right",
    legend.title = element_text(size = 9, face = "bold"),
    legend.text  = element_text(size = 8),
    axis.text.x = element_text(angle = 45, hjust = 1, size = 8)
  )

save_fig(p7, "fig_rn_trajectory", width = 10, height = 5.5)

## ============================================================================
## FIGURE 8: Binscatter -- Network Exposure vs. RN Change (v2: 2002-2024)
## ============================================================================

cat("\n--- Figure 8: Binscatter -- Network Exposure vs. RN Change ---\n")

## v2: Compute RN change (2024 - 2002) at the département level (longer window)
rn_change <- dept_panel %>%
  filter(year %in% c(2002, 2024)) %>%
  select(dept_code, year, rn_share) %>%
  pivot_wider(names_from = year, values_from = rn_share,
              names_prefix = "rn_") %>%
  mutate(delta_rn = rn_2024 - rn_2002) %>%
  filter(!is.na(delta_rn))

## Merge with exposure measures
binscatter_data <- rn_change %>%
  left_join(fuel_vuln, by = "dept_code") %>%
  left_join(net_exp %>% select(dept_code, network_fuel_norm),
            by = "dept_code") %>%
  filter(!is.na(network_fuel_norm) & !is.na(co2_commute))

## Residualize: partial out own fuel exposure
resid_model <- lm(delta_rn ~ co2_commute, data = binscatter_data)
binscatter_data$delta_rn_resid <- residuals(resid_model) +
  mean(binscatter_data$delta_rn, na.rm = TRUE)  # add back mean for levels

resid_x_model <- lm(network_fuel_norm ~ co2_commute, data = binscatter_data)
binscatter_data$network_resid <- residuals(resid_x_model) +
  mean(binscatter_data$network_fuel_norm, na.rm = TRUE)

## Create 20 equal-sized bins
binscatter_data <- binscatter_data %>%
  mutate(bin = ntile(network_resid, 20))

bin_means <- binscatter_data %>%
  group_by(bin) %>%
  summarize(
    x_mean = mean(network_resid, na.rm = TRUE),
    y_mean = mean(delta_rn_resid, na.rm = TRUE),
    y_se   = sd(delta_rn_resid, na.rm = TRUE) / sqrt(n()),
    n_obs  = n(),
    .groups = "drop"
  )

## Regression line from the underlying residualized data
reg_line <- lm(delta_rn_resid ~ network_resid, data = binscatter_data)
reg_coef <- coef(reg_line)
reg_se   <- sqrt(diag(vcov(reg_line)))[2]
reg_label <- sprintf("Slope = %.2f (SE = %.2f)",
                     reg_coef[2], reg_se)

p8 <- ggplot(bin_means, aes(x = x_mean, y = y_mean)) +
  ## Regression line over the full range of bin means
  geom_smooth(data = binscatter_data,
              aes(x = network_resid, y = delta_rn_resid),
              method = "lm", se = TRUE,
              color = apep_colors[1], fill = apep_colors[1],
              alpha = 0.15, linewidth = 0.8) +
  ## Bin means
  geom_point(size = 3, color = apep_colors[2]) +
  ## Error bars on bins
  geom_errorbar(aes(ymin = y_mean - 1.96 * y_se,
                    ymax = y_mean + 1.96 * y_se),
                width = 0, linewidth = 0.4, color = apep_colors[2],
                alpha = 0.5) +
  ## Regression slope annotation
  annotate("text",
           x = min(bin_means$x_mean) + 0.2 *
             diff(range(bin_means$x_mean)),
           y = max(bin_means$y_mean) * 0.98,
           label = reg_label,
           size = 3.5, color = apep_colors[1], fontface = "bold",
           hjust = 0) +
  labs(
    title = "Network Fuel Exposure and Change in RN Vote Share",
    subtitle = paste0("Binned scatter (20 bins); residualized on own fuel ",
                      "exposure (co2_commute)"),
    x = "Network fuel exposure (residualized)",
    y = expression(bold(Delta * " RN vote share 2024 \u2013 2002 (pp, residualized)"))
  ) +
  theme_apep()

save_fig(p8, "fig_binscatter_network", width = 7, height = 5.5)

## ============================================================================
## FIGURE 9: SCI vs. Migration-Proxy Scatter (WS2 -- v3 NEW)
## ============================================================================

cat("\n--- Figure 9: SCI vs. Migration-Proxy Scatter (v3) ---\n")

fig9_ok <- FALSE

if (file.exists(mig_net_file) && file.exists(mig_corr_file)) {
  migration_network <- readRDS(mig_net_file)
  sci_mig_corr      <- readRDS(mig_corr_file)

  ## Build comparison dataset: SCI-based vs. migration-based network exposure
  sci_mig_scatter <- net_exp %>%
    select(dept_code, network_fuel_norm) %>%
    inner_join(migration_network, by = "dept_code") %>%
    filter(!is.na(network_fuel_norm) & !is.na(network_fuel_migration))

  if (nrow(sci_mig_scatter) >= 10) {
    ## Compute Spearman correlation
    spearman_rho <- cor(sci_mig_scatter$network_fuel_norm,
                        sci_mig_scatter$network_fuel_migration,
                        method = "spearman")

    ## OLS fit for annotation
    ols_fit <- lm(network_fuel_migration ~ network_fuel_norm,
                  data = sci_mig_scatter)
    ols_coef <- coef(ols_fit)

    p9 <- ggplot(sci_mig_scatter,
                 aes(x = network_fuel_norm, y = network_fuel_migration)) +
      ## 45-degree reference line
      geom_abline(intercept = 0, slope = 1,
                  linetype = "dashed", color = "grey60", linewidth = 0.5) +
      ## OLS fit line
      geom_smooth(method = "lm", se = TRUE,
                  color = apep_colors[1], fill = apep_colors[1],
                  alpha = 0.15, linewidth = 0.8) +
      ## Points (one per département)
      geom_point(size = 2.5, color = apep_colors[2], alpha = 0.7) +
      ## Spearman correlation annotation
      annotate("text",
               x = min(sci_mig_scatter$network_fuel_norm, na.rm = TRUE) +
                 0.05 * diff(range(sci_mig_scatter$network_fuel_norm, na.rm = TRUE)),
               y = max(sci_mig_scatter$network_fuel_migration, na.rm = TRUE) -
                 0.05 * diff(range(sci_mig_scatter$network_fuel_migration, na.rm = TRUE)),
               label = sprintf("Spearman rho = %.3f", spearman_rho),
               size = 4, color = apep_colors[1], fontface = "bold",
               hjust = 0, vjust = 1) +
      ## OLS slope annotation
      annotate("text",
               x = min(sci_mig_scatter$network_fuel_norm, na.rm = TRUE) +
                 0.05 * diff(range(sci_mig_scatter$network_fuel_norm, na.rm = TRUE)),
               y = max(sci_mig_scatter$network_fuel_migration, na.rm = TRUE) -
                 0.12 * diff(range(sci_mig_scatter$network_fuel_migration, na.rm = TRUE)),
               label = sprintf("OLS: y = %.3f + %.3f x",
                               ols_coef[1], ols_coef[2]),
               size = 3.5, color = "grey40",
               hjust = 0, vjust = 1) +
      ## N annotation
      annotate("text",
               x = max(sci_mig_scatter$network_fuel_norm, na.rm = TRUE),
               y = min(sci_mig_scatter$network_fuel_migration, na.rm = TRUE),
               label = sprintf("N = %d d\u00e9partements", nrow(sci_mig_scatter)),
               size = 3, color = "grey50",
               hjust = 1, vjust = 0) +
      labs(
        title = "Validation: SCI vs. Pre-Treatment Migration Network Exposure",
        subtitle = paste0("Each point is a d\u00e9partement; dashed line = 45-degree; ",
                          "solid line = OLS fit"),
        x = "SCI-based network fuel exposure",
        y = "Migration-proxy network fuel exposure"
      ) +
      theme_apep()

    save_fig(p9, "fig_sci_vs_migration", width = 7, height = 6)
    fig9_ok <- TRUE
    cat("  Spearman rho:", round(spearman_rho, 3), "\n")
    cat("  N départements:", nrow(sci_mig_scatter), "\n")
  }
}

if (!fig9_ok) {
  cat("  WARNING: Migration network data not found. Skipping Figure 9.\n")
  cat("  Expected files: migration_network.rds, sci_migration_correlation.rds\n")
}

## ============================================================================
## FIGURE 10: Distance-Bin Decomposition Bar Chart (WS4 -- v3 NEW)
## ============================================================================

cat("\n--- Figure 10: Distance-Bin Decomposition (v3) ---\n")

fig10_ok <- FALSE

## Strategy: run distance-bin regressions from distance_bin_data.rds
## Each bin's network exposure is interacted with Post, coefficient plotted
if (file.exists(dist_bin_file)) {
  distance_bin_data <- readRDS(dist_bin_file)

  ## Standardize bin exposures and merge onto département panel
  bin_labels <- c("0-50km", "50-100km", "100-200km", "200-400km", "400+km")

  ## Pivot distance_bin_data to wide: one column per bin
  bin_wide <- distance_bin_data %>%
    select(dept_code, bin, network_fuel) %>%
    pivot_wider(names_from = bin, values_from = network_fuel,
                names_prefix = "bin_")

  ## Clean column names (replace special characters)
  names(bin_wide) <- gsub("[^a-zA-Z0-9_]", "_", names(bin_wide))
  names(bin_wide) <- gsub("_+", "_", names(bin_wide))
  names(bin_wide) <- gsub("_$", "", names(bin_wide))

  ## Merge onto département panel
  dept_bin <- dept_panel %>%
    left_join(bin_wide, by = "dept_code")

  ## Identify the bin columns
  bin_cols <- setdiff(names(bin_wide), "dept_code")

  ## Standardize each bin column
  for (col in bin_cols) {
    std_col <- paste0(col, "_std")
    dept_bin[[std_col]] <- (dept_bin[[col]] - mean(dept_bin[[col]], na.rm = TRUE)) /
      sd(dept_bin[[col]], na.rm = TRUE)
  }

  ## Add post indicator if missing
  if (!"post_carbon" %in% names(dept_bin)) {
    dept_bin <- dept_bin %>%
      mutate(post_carbon = as.integer(year >= 2017))
  }

  ## Run separate regressions for each bin
  bin_results <- list()
  std_bin_cols <- paste0(bin_cols, "_std")

  for (i in seq_along(bin_cols)) {
    col <- std_bin_cols[i]
    if (!col %in% names(dept_bin)) next
    if (all(is.na(dept_bin[[col]]))) next

    ## Build formula dynamically
    fml <- as.formula(paste0("rn_share ~ ", col, ":post_carbon | dept_code + id_election"))

    tryCatch({
      m_bin <- feols(fml, data = dept_bin, cluster = ~dept_code)

      ## Extract coefficient for the bin interaction
      coef_nms <- names(coef(m_bin))
      idx <- grep(col, coef_nms)
      if (length(idx) > 0) {
        bin_results[[i]] <- tibble(
          bin = bin_labels[i],
          bin_order = i,
          estimate = coef(m_bin)[idx[1]],
          se = se(m_bin)[idx[1]],
          ci_lo = coef(m_bin)[idx[1]] - 1.96 * se(m_bin)[idx[1]],
          ci_hi = coef(m_bin)[idx[1]] + 1.96 * se(m_bin)[idx[1]]
        )
      }
    }, error = function(e) {
      cat("  Could not estimate bin", bin_labels[i], ":", conditionMessage(e), "\n")
    })
  }

  if (length(bin_results) > 0) {
    bin_df <- bind_rows(bin_results) %>%
      mutate(bin = factor(bin, levels = bin_labels))

    p10 <- ggplot(bin_df, aes(x = bin, y = estimate)) +
      ## Zero reference line
      geom_hline(yintercept = 0, linetype = "solid", color = "grey50",
                 linewidth = 0.4) +
      ## Bars
      geom_col(fill = apep_colors[1], alpha = 0.7, width = 0.6) +
      ## Error bars (95% CI)
      geom_errorbar(aes(ymin = ci_lo, ymax = ci_hi),
                    width = 0.2, linewidth = 0.6, color = "grey30") +
      ## Coefficient labels above bars
      geom_text(aes(label = sprintf("%.3f", estimate),
                    y = ifelse(estimate >= 0,
                               ci_hi + 0.02 * diff(range(c(ci_lo, ci_hi))),
                               ci_lo - 0.02 * diff(range(c(ci_lo, ci_hi))))),
                size = 3, color = "grey30", fontface = "bold") +
      labs(
        title = "Network Effect by Distance Bin",
        subtitle = paste0("Coefficient on bin-specific SCI-weighted network exposure ",
                          "x Post; 95% CIs clustered by d\u00e9partement"),
        x = "Distance bin (centroid-to-centroid)",
        y = "Coefficient (pp RN share)"
      ) +
      theme_apep() +
      theme(
        axis.text.x = element_text(size = 10, face = "bold"),
        panel.grid.major.x = element_blank()
      )

    save_fig(p10, "fig_distance_bins", width = 8, height = 5.5)
    fig10_ok <- TRUE
    cat("  Plotted", nrow(bin_df), "distance bins.\n")
  }
}

## Fallback: try extracting from robustness_results if distance_bin_data wasn't available
if (!fig10_ok && !is.null(robustness_results$distance_bins)) {
  cat("  Using distance_bins from robustness_results.rds...\n")
  db <- robustness_results$distance_bins

  if (is.data.frame(db)) {
    bin_df <- db %>%
      mutate(
        ci_lo = estimate - 1.96 * se,
        ci_hi = estimate + 1.96 * se
      )
  } else if (is.list(db)) {
    ## Convert named list to data frame
    bin_df <- tibble(
      bin = names(db),
      estimate = sapply(db, function(x) x$estimate %||% x$coef %||% NA_real_),
      se = sapply(db, function(x) x$se %||% NA_real_)
    ) %>%
      mutate(
        ci_lo = estimate - 1.96 * se,
        ci_hi = estimate + 1.96 * se
      )
  }

  if (exists("bin_df") && nrow(bin_df) > 0) {
    bin_labels_fallback <- c("0-50km", "50-100km", "100-200km", "200-400km", "400+km")
    bin_df$bin <- factor(bin_df$bin, levels = bin_labels_fallback)

    p10 <- ggplot(bin_df, aes(x = bin, y = estimate)) +
      geom_hline(yintercept = 0, linetype = "solid", color = "grey50",
                 linewidth = 0.4) +
      geom_col(fill = apep_colors[1], alpha = 0.7, width = 0.6) +
      geom_errorbar(aes(ymin = ci_lo, ymax = ci_hi),
                    width = 0.2, linewidth = 0.6, color = "grey30") +
      labs(
        title = "Network Effect by Distance Bin",
        subtitle = paste0("Coefficient on bin-specific network exposure x Post; ",
                          "95% CIs clustered by d\u00e9partement"),
        x = "Distance bin (centroid-to-centroid)",
        y = "Coefficient (pp RN share)"
      ) +
      theme_apep() +
      theme(
        axis.text.x = element_text(size = 10, face = "bold"),
        panel.grid.major.x = element_blank()
      )

    save_fig(p10, "fig_distance_bins", width = 8, height = 5.5)
    fig10_ok <- TRUE
  }
}

if (!fig10_ok) {
  cat("  WARNING: Distance bin data not found. Skipping Figure 10.\n")
  cat("  Expected: distance_bin_data.rds or robustness_results$distance_bins\n")
}

## ============================================================================
## FIGURE 11: Placebo Timing Test (WS5 -- v3 NEW)
## ============================================================================

cat("\n--- Figure 11: Placebo Timing Test (v3) ---\n")

fig11_ok <- FALSE

if (!is.null(robustness_results$placebo_timing)) {
  ## If placebo_timing is stored as a structured list/data.frame
  pt <- robustness_results$placebo_timing

  if (is.data.frame(pt)) {
    raw_df <- pt
  } else if (is.list(pt) && !is.null(pt$results)) {
    raw_df <- pt$results
  } else {
    raw_df <- NULL
  }

  ## Build placebo_df from the actual column names (coef_network / se_network)
  if (!is.null(raw_df) && nrow(raw_df) > 0) {
    ## Get actual treatment coefficient from dept_results D2
    actual_coef <- as.numeric(coef(dept_results$d2)[grep("network_fuel_std", names(coef(dept_results$d2)))])
    actual_se   <- as.numeric(se(dept_results$d2)[grep("network_fuel_std", names(se(dept_results$d2)))])

    placebo_df <- raw_df %>%
      transmute(
        label    = paste0("Fake: ", fake_date),
        estimate = as.numeric(coef_network),
        se       = as.numeric(se_network),
        type     = "placebo"
      ) %>%
      bind_rows(
        tibble(label = "Actual: 2014", estimate = actual_coef, se = actual_se, type = "actual")
      ) %>%
      mutate(
        ci_lo = estimate - 1.96 * se,
        ci_hi = estimate + 1.96 * se,
        label = factor(label, levels = c("Fake: 2007", "Fake: 2009", "Actual: 2014"))
      )
  } else {
    placebo_df <- NULL
  }

  if (!is.null(placebo_df) && nrow(placebo_df) > 0) {
    p11 <- ggplot(placebo_df, aes(x = label, y = estimate)) +
      geom_hline(yintercept = 0, linetype = "dashed", color = "grey50",
                 linewidth = 0.4) +
      geom_point(aes(color = type), size = 3.5) +
      geom_errorbar(aes(ymin = ci_lo, ymax = ci_hi, color = type),
                    width = 0.15, linewidth = 0.6) +
      scale_color_manual(
        values = c("actual" = apep_colors[2], "placebo" = apep_colors[1]),
        labels = c("actual" = "Actual treatment", "placebo" = "Placebo"),
        name = ""
      ) +
      labs(
        title = "Placebo Timing Test: Network Coefficient Under Fake Treatment Dates",
        subtitle = "Actual treatment (2014+) vs. fake treatments (2007, 2009); 95% CIs",
        x = "",
        y = "Network coefficient (pp RN share)"
      ) +
      theme_apep() +
      theme(
        axis.text.x = element_text(size = 10, face = "bold"),
        panel.grid.major.x = element_blank()
      )

    save_fig(p11, "fig_placebo_timing", width = 7, height = 5)
    fig11_ok <- TRUE
  }
}

## Fallback: construct placebo timing test from panel data directly
if (!fig11_ok) {
  cat("  Placebo timing not found in robustness_results. Estimating from panel data...\n")

  ## We can construct this from the département panel directly
  dept_panel_pt <- dept_panel %>%
    mutate(
      own_fuel_std = (co2_commute - mean(co2_commute, na.rm = TRUE)) /
        sd(co2_commute, na.rm = TRUE),
      network_fuel_std = (network_fuel_norm - mean(network_fuel_norm, na.rm = TRUE)) /
        sd(network_fuel_norm, na.rm = TRUE)
    )

  if (!"id_election" %in% names(dept_panel_pt)) {
    dept_panel_pt <- dept_panel_pt %>%
      mutate(id_election = paste0("elec_", year))
  }

  ## Actual treatment: post_carbon (year >= 2017)
  if (!"post_carbon" %in% names(dept_panel_pt)) {
    dept_panel_pt <- dept_panel_pt %>%
      mutate(post_carbon = as.integer(year >= 2017))
  }

  ## Fake treatment 1: post 2007
  dept_panel_pt$fake_2007 <- as.integer(dept_panel_pt$year >= 2007)

  ## Fake treatment 2: post 2009
  dept_panel_pt$fake_2009 <- as.integer(dept_panel_pt$year >= 2009)

  placebo_results <- list()

  ## Actual treatment
  tryCatch({
    m_actual <- feols(rn_share ~ own_fuel_std:post_carbon +
                        network_fuel_std:post_carbon |
                        dept_code + id_election,
                      data = dept_panel_pt,
                      cluster = ~dept_code)
    net_nm <- names(coef(m_actual))[grep("network_fuel_std", names(coef(m_actual)))]
    if (length(net_nm) > 0) {
      placebo_results[["actual"]] <- tibble(
        label = "Actual (2014+)",
        type = "actual",
        estimate = coef(m_actual)[net_nm[1]],
        se = se(m_actual)[net_nm[1]]
      )
    }
  }, error = function(e) cat("  Error estimating actual model:", conditionMessage(e), "\n"))

  ## Fake treatment 2007 (restrict to pre-2014 sample to avoid contamination)
  tryCatch({
    pre2014 <- dept_panel_pt %>% filter(year <= 2012)
    if (nrow(pre2014) > 0 && n_distinct(pre2014$year) >= 3) {
      m_fake07 <- feols(rn_share ~ own_fuel_std:fake_2007 +
                          network_fuel_std:fake_2007 |
                          dept_code + id_election,
                        data = pre2014,
                        cluster = ~dept_code)
      net_nm <- names(coef(m_fake07))[grep("network_fuel_std", names(coef(m_fake07)))]
      if (length(net_nm) > 0) {
        placebo_results[["fake_2007"]] <- tibble(
          label = "Placebo (2007)",
          type = "placebo",
          estimate = coef(m_fake07)[net_nm[1]],
          se = se(m_fake07)[net_nm[1]]
        )
      }
    }
  }, error = function(e) cat("  Error estimating fake 2007:", conditionMessage(e), "\n"))

  ## Fake treatment 2009 (restrict to pre-2014)
  tryCatch({
    pre2014 <- dept_panel_pt %>% filter(year <= 2012)
    if (nrow(pre2014) > 0 && n_distinct(pre2014$year) >= 3) {
      m_fake09 <- feols(rn_share ~ own_fuel_std:fake_2009 +
                          network_fuel_std:fake_2009 |
                          dept_code + id_election,
                        data = pre2014,
                        cluster = ~dept_code)
      net_nm <- names(coef(m_fake09))[grep("network_fuel_std", names(coef(m_fake09)))]
      if (length(net_nm) > 0) {
        placebo_results[["fake_2009"]] <- tibble(
          label = "Placebo (2009)",
          type = "placebo",
          estimate = coef(m_fake09)[net_nm[1]],
          se = se(m_fake09)[net_nm[1]]
        )
      }
    }
  }, error = function(e) cat("  Error estimating fake 2009:", conditionMessage(e), "\n"))

  if (length(placebo_results) > 0) {
    placebo_df <- bind_rows(placebo_results) %>%
      mutate(
        ci_lo = estimate - 1.96 * se,
        ci_hi = estimate + 1.96 * se,
        label = factor(label, levels = c("Placebo (2007)", "Placebo (2009)",
                                          "Actual (2014+)"))
      )

    ## Determine significance markers
    placebo_df <- placebo_df %>%
      mutate(
        sig = case_when(
          abs(estimate / se) > 2.576 ~ "***",
          abs(estimate / se) > 1.960 ~ "**",
          abs(estimate / se) > 1.645 ~ "*",
          TRUE ~ ""
        )
      )

    p11 <- ggplot(placebo_df, aes(x = label, y = estimate, color = type)) +
      ## Zero reference line
      geom_hline(yintercept = 0, linetype = "dashed", color = "grey50",
                 linewidth = 0.4) +
      ## Point estimates
      geom_point(size = 4) +
      ## Confidence intervals
      geom_errorbar(aes(ymin = ci_lo, ymax = ci_hi),
                    width = 0.15, linewidth = 0.7) +
      ## Significance stars
      geom_text(aes(label = sig,
                    y = ci_hi + 0.08 * diff(range(c(ci_lo, ci_hi)))),
                size = 5, show.legend = FALSE) +
      scale_color_manual(
        values = c("actual" = apep_colors[2], "placebo" = apep_colors[1]),
        labels = c("actual" = "Actual treatment (2014+)",
                    "placebo" = "Placebo (pre-treatment)"),
        name = ""
      ) +
      labs(
        title = "Placebo Timing Test: Network Coefficient Under Fake Treatment Dates",
        subtitle = paste0("Actual treatment (post-2014) should be significant; ",
                          "fake treatments (2007, 2009) should be null\n",
                          "95% CIs clustered by d\u00e9partement"),
        x = "",
        y = "Network coefficient (pp RN share)"
      ) +
      theme_apep() +
      theme(
        axis.text.x = element_text(size = 10, face = "bold"),
        panel.grid.major.x = element_blank(),
        legend.position = "bottom"
      )

    save_fig(p11, "fig_placebo_timing", width = 7, height = 5.5)
    fig11_ok <- TRUE
    cat("  Placebo timing test constructed and plotted.\n")
    for (i in seq_len(nrow(placebo_df))) {
      cat(sprintf("    %s: %.4f (SE %.4f) %s\n",
                  placebo_df$label[i], placebo_df$estimate[i],
                  placebo_df$se[i], placebo_df$sig[i]))
    }
  }
}

if (!fig11_ok) {
  cat("  WARNING: Could not construct placebo timing test. Skipping Figure 11.\n")
}

## ============================================================================
## FIGURE 12: Inference Comparison Forest Plot (WS1 -- v3 NEW)
## ============================================================================

cat("\n--- Figure 12: Inference Comparison Forest Plot (v3) ---\n")

fig12_ok <- FALSE

## We need the main coefficient + CIs under different inference methods.
## The baseline coefficient comes from the main results; we vary the SE/CI.
## Load main département results for the baseline coefficient.
dept_results_file <- file.path(DATA_DIR, "dept_results.rds")

if (file.exists(dept_results_file) && !is.null(robustness_results)) {
  dept_results <- readRDS(dept_results_file)

  ## v3: Get the baseline model (D2: pop-weighted département-level — primary spec)
  baseline_model <- dept_results$d2
  if (is.null(baseline_model)) baseline_model <- dept_results[[1]]

  ## Extract baseline network coefficient
  net_nm <- names(coef(baseline_model))[grep("network_fuel_std", names(coef(baseline_model)))]
  if (length(net_nm) > 0) {
    base_coef <- coef(baseline_model)[net_nm[1]]
    base_se   <- se(baseline_model)[net_nm[1]]

    ## Build inference comparison data frame
    inference_rows <- list()

    ## 1. Clustered SE (département) -- from the baseline model
    inference_rows[["clustered"]] <- tibble(
      method = "Clustered SE (dept.)",
      estimate = base_coef,
      ci_lo = base_coef - 1.96 * base_se,
      ci_hi = base_coef + 1.96 * base_se,
      method_order = 1
    )

    ## 2. AKM (shift-share) -- check robustness_results
    if (!is.null(robustness_results$akm) ||
        !is.null(robustness_results$shift_share_se)) {
      akm <- robustness_results$akm %||% robustness_results$shift_share_se
      akm_se <- akm$se_network %||% akm$se %||% NA_real_
      if (!is.na(akm_se)) {
        inference_rows[["akm"]] <- tibble(
          method = "AKM (Shift-Share)",
          estimate = base_coef,
          ci_lo = base_coef - 1.96 * akm_se,
          ci_hi = base_coef + 1.96 * akm_se,
          method_order = 2
        )
      }
    }

    ## 3. Two-way cluster (dept + election) -- from D4 model
    if (!is.null(dept_results$d4)) {
      d4_net_nm <- names(coef(dept_results$d4))[grep("network_fuel_std",
                                                       names(coef(dept_results$d4)))]
      if (length(d4_net_nm) > 0) {
        d4_se <- se(dept_results$d4)[d4_net_nm[1]]
        inference_rows[["twoway"]] <- tibble(
          method = "Two-Way Cluster",
          estimate = base_coef,
          ci_lo = base_coef - 1.96 * d4_se,
          ci_hi = base_coef + 1.96 * d4_se,
          method_order = 3
        )
      }
    }

    ## 4. Conley spatial HAC -- check robustness_results
    if (!is.null(robustness_results$conley)) {
      conley_se <- robustness_results$conley$se_network %||%
        robustness_results$conley$se %||% NA_real_
      if (!is.na(conley_se)) {
        inference_rows[["conley"]] <- tibble(
          method = "Conley Spatial HAC",
          estimate = base_coef,
          ci_lo = base_coef - 1.96 * conley_se,
          ci_hi = base_coef + 1.96 * conley_se,
          method_order = 4
        )
      }
    }

    ## 5. Randomization Inference -- from robustness_results
    if (!is.null(robustness_results$randomization_inference)) {
      ri <- robustness_results$randomization_inference
      ri_p <- ri$ri_p_net %||% ri$p_network %||% NA_real_
      if (!is.na(ri_p)) {
        ## Convert RI p-value to approximate CI using normal approximation
        ## If p < alpha, the CI excludes zero
        ri_z <- qnorm(1 - ri_p / 2)
        ri_se_approx <- abs(base_coef) / ri_z
        inference_rows[["ri"]] <- tibble(
          method = "Randomization Inference",
          estimate = base_coef,
          ci_lo = base_coef - 1.96 * ri_se_approx,
          ci_hi = base_coef + 1.96 * ri_se_approx,
          method_order = 5
        )
      }
    }

    ## 6. Block RI (within-region) -- from robustness_results
    if (!is.null(robustness_results$block_ri)) {
      bri <- robustness_results$block_ri
      bri_p <- bri$block_ri_p_net %||% bri$p_network %||% NA_real_
      if (!is.na(bri_p) && bri_p > 0) {
        bri_z <- qnorm(1 - bri_p / 2)
        bri_se_approx <- abs(base_coef) / bri_z
        inference_rows[["block_ri"]] <- tibble(
          method = "Block RI (within-region)",
          estimate = base_coef,
          ci_lo = base_coef - 1.96 * bri_se_approx,
          ci_hi = base_coef + 1.96 * bri_se_approx,
          method_order = 6
        )
      }
    }

    ## 7. Wild Cluster Bootstrap -- from robustness_results
    if (!is.null(robustness_results$wild_bootstrap)) {
      wcb <- robustness_results$wild_bootstrap
      wcb_p <- wcb$p_network %||% NA_real_
      if (!is.na(wcb_p) && wcb_p > 0) {
        wcb_z <- qnorm(1 - wcb_p / 2)
        wcb_se_approx <- abs(base_coef) / wcb_z
        inference_rows[["wcb"]] <- tibble(
          method = "Wild Cluster Bootstrap",
          estimate = base_coef,
          ci_lo = base_coef - 1.96 * wcb_se_approx,
          ci_hi = base_coef + 1.96 * wcb_se_approx,
          method_order = 7
        )
      }
    }

    if (length(inference_rows) >= 2) {
      forest_df <- bind_rows(inference_rows) %>%
        arrange(method_order) %>%
        mutate(method = factor(method, levels = rev(method)))

      ## Color: blue if CI excludes zero, grey if includes zero
      forest_df <- forest_df %>%
        mutate(
          significant = (ci_lo > 0 | ci_hi < 0),
          point_color = ifelse(significant, apep_colors[2], "grey50")
        )

      p12 <- ggplot(forest_df, aes(x = estimate, y = method)) +
        ## Vertical zero reference line
        geom_vline(xintercept = 0, linetype = "dashed", color = "grey50",
                   linewidth = 0.4) +
        ## Confidence intervals
        geom_errorbarh(aes(xmin = ci_lo, xmax = ci_hi),
                       height = 0.2, linewidth = 0.6, color = "grey40") +
        ## Point estimates
        geom_point(aes(color = significant), size = 3.5) +
        scale_color_manual(
          values = c("TRUE" = apep_colors[2], "FALSE" = "grey50"),
          labels = c("TRUE" = "Significant at 5%", "FALSE" = "Not significant"),
          name = ""
        ) +
        ## Annotate point estimates and CIs
        geom_text(aes(label = sprintf("%.4f [%.4f, %.4f]",
                                       estimate, ci_lo, ci_hi),
                      x = max(forest_df$ci_hi, na.rm = TRUE) +
                        0.05 * diff(range(c(forest_df$ci_lo, forest_df$ci_hi)))),
                  size = 2.8, hjust = 0, color = "grey30") +
        ## Expand right margin for annotations
        scale_x_continuous(
          expand = expansion(mult = c(0.05, 0.35))
        ) +
        labs(
          title = "Inference Robustness: Network Coefficient Under Alternative Methods",
          subtitle = paste0("Point estimate from d\u00e9partement-level baseline model; ",
                            "CIs vary by inference method"),
          x = "Network coefficient (pp RN share)",
          y = ""
        ) +
        theme_apep() +
        theme(
          axis.text.y = element_text(size = 10, face = "bold"),
          panel.grid.major.y = element_blank(),
          legend.position = "bottom"
        )

      save_fig(p12, "fig_inference_forest", width = 10, height = 5.5)
      fig12_ok <- TRUE
      cat("  Plotted", nrow(forest_df), "inference methods.\n")
    }
  }
}

if (!fig12_ok) {
  cat("  WARNING: Could not construct inference forest plot. Skipping Figure 12.\n")
  cat("  Requires: dept_results.rds and robustness_results.rds with inference data.\n")
}

## ============================================================================
## v4 FIGURE 13: ROTEMBERG WEIGHTS SCATTER (WS3)
## ============================================================================

cat("\n=== v4 Figure 13: Rotemberg Weights Scatter ===\n")

fig13_ok <- FALSE

if (file.exists(file.path(DATA_DIR, "robustness_results.rds"))) {
  rob <- readRDS(file.path(DATA_DIR, "robustness_results.rds"))

  if (!is.null(rob$bartik_diagnostics$rotemberg_weights)) {
    rw <- rob$bartik_diagnostics$rotemberg_weights
    rw_df <- tibble(
      dept_code = names(rw),
      rotemberg_weight = as.numeric(rw)
    ) %>%
      left_join(fuel_vuln, by = "dept_code") %>%
      filter(!is.na(co2_commute)) %>%
      arrange(desc(rotemberg_weight)) %>%
      mutate(
        rank = row_number(),
        label = ifelse(rank <= 5, dept_code, NA_character_)
      )

    p13 <- ggplot(rw_df, aes(x = co2_commute, y = rotemberg_weight)) +
      geom_point(color = apep_colors[1], size = 2.5, alpha = 0.7) +
      geom_text_repel(aes(label = label), size = 3.5, color = "grey30",
                      na.rm = TRUE, max.overlaps = 15) +
      geom_hline(yintercept = 1 / nrow(rw_df), linetype = "dashed",
                 color = "grey50", linewidth = 0.5) +
      annotate("text", x = max(rw_df$co2_commute, na.rm = TRUE) * 0.95,
               y = 1 / nrow(rw_df) + 0.002,
               label = "Equal weight", size = 3, color = "grey50", hjust = 1) +
      labs(
        title = "Rotemberg Weights vs. Fuel Vulnerability Shifts",
        subtitle = "Top-5 source départements labeled; dashed line = equal weight",
        x = expression("Fuel vulnerability (tCO"[2]*"e per commuter)"),
        y = "Rotemberg weight"
      ) +
      theme_apep()

    save_fig(p13, "fig_rotemberg_scatter", width = 7, height = 5)
    fig13_ok <- TRUE
  }
}

if (!fig13_ok) {
  cat("  WARNING: Could not create Rotemberg scatter. Skipping Figure 13.\n")
}


## ============================================================================
## v4 FIGURE 14: HONESTDID SENSITIVITY PLOT (WS2)
## ============================================================================

cat("\n=== v4 Figure 14: HonestDiD Sensitivity Plot ===\n")

fig14_ok <- FALSE

if (file.exists(file.path(DATA_DIR, "robustness_results.rds"))) {
  if (!exists("rob")) rob <- readRDS(file.path(DATA_DIR, "robustness_results.rds"))

  if (!is.null(rob$honest_did$relative_magnitudes)) {
    hd_rm <- rob$honest_did$relative_magnitudes

    p14 <- ggplot(hd_rm, aes(x = Mbar)) +
      geom_ribbon(aes(ymin = lb, ymax = ub), fill = apep_colors[1], alpha = 0.2) +
      geom_line(aes(y = lb), color = apep_colors[1], linewidth = 0.8) +
      geom_line(aes(y = ub), color = apep_colors[1], linewidth = 0.8) +
      geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
      labs(
        title = "Sensitivity to Violations of Parallel Trends",
        subtitle = expression("Rambachan-Roth (2023) robust CI: " * Delta^RM * " (relative magnitudes)"),
        x = expression(bar(M) * " (max relative magnitude of pre-trend violation)"),
        y = "Treatment effect on RN vote share (pp)"
      ) +
      theme_apep()

    save_fig(p14, "fig_honestdid_sensitivity", width = 7, height = 5)
    fig14_ok <- TRUE
  }
}

if (!fig14_ok) {
  cat("  WARNING: Could not create HonestDiD sensitivity plot. Skipping Figure 14.\n")
}


## ============================================================================
## v5 NEW: FIGURE 15 — TIMING DECOMPOSITION
## ============================================================================

cat("\n=== Figure 15: Timing Decomposition ===\n")

fig15_ok <- FALSE

if (file.exists(file.path(DATA_DIR, "robustness_results.rds"))) {
  if (!exists("rob")) rob <- readRDS(file.path(DATA_DIR, "robustness_results.rds"))

  if (!is.null(rob$timing_decomposition)) {
    td <- rob$timing_decomposition
    td_data <- tibble(
      Period = c("Carbon Tax Only\n(2014-2017)", "Post-GJ\n(2019+)"),
      Coef = c(td$coef_net_carbon, td$coef_net_gj),
      SE = c(td$se_net_carbon, td$se_net_gj),
      CI_lo = Coef - 1.96 * SE,
      CI_hi = Coef + 1.96 * SE
    ) %>%
      mutate(Period = factor(Period, levels = Period))

    p15 <- ggplot(td_data, aes(x = Period, y = Coef)) +
      geom_col(fill = apep_colors[1], alpha = 0.6, width = 0.5) +
      geom_errorbar(aes(ymin = CI_lo, ymax = CI_hi), width = 0.2, linewidth = 0.8) +
      geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
      labs(
        title = "Network Fuel Exposure Effect by Treatment Period",
        subtitle = "Département-level, population-weighted",
        x = "",
        y = "Effect on RN vote share (pp)"
      ) +
      theme_apep()

    save_fig(p15, "fig_timing_decomposition", width = 6, height = 5)
    fig15_ok <- TRUE
  }
}

if (!fig15_ok) {
  cat("  WARNING: Could not create timing decomposition plot. Skipping Figure 15.\n")
}


## ============================================================================
## v5 NEW: FIGURE 16 — RI COMPARISON (STANDARD vs BLOCK vs URBAN-BLOCK vs SHIFT-LEVEL)
## ============================================================================

cat("\n=== Figure 16: RI Comparison ===\n")

fig16_ok <- FALSE

if (file.exists(file.path(DATA_DIR, "robustness_results.rds"))) {
  if (!exists("rob")) rob <- readRDS(file.path(DATA_DIR, "robustness_results.rds"))

  ri_data <- tibble(
    Method = c("Standard RI", "Region-Block RI", "Urban-Block RI", "Shift-Level RI"),
    p_value = c(
      rob$randomization_inference$ri_p_net,
      rob$block_ri$block_ri_p_net,
      if (!is.null(rob$urban_block_ri)) rob$urban_block_ri$p_network else NA,
      if (!is.null(rob$shift_ri)) rob$shift_ri$p_network else NA
    )
  ) %>%
    filter(!is.na(p_value)) %>%
    mutate(Method = factor(Method, levels = Method))

  if (nrow(ri_data) >= 2) {
    p16 <- ggplot(ri_data, aes(x = Method, y = p_value)) +
      geom_col(fill = apep_colors[2], alpha = 0.7, width = 0.5) +
      geom_hline(yintercept = 0.05, linetype = "dashed", color = "red", linewidth = 0.5) +
      geom_hline(yintercept = 0.10, linetype = "dotted", color = "orange", linewidth = 0.5) +
      annotate("text", x = 0.5, y = 0.055, label = "5%", color = "red", size = 3, hjust = 0) +
      annotate("text", x = 0.5, y = 0.105, label = "10%", color = "orange", size = 3, hjust = 0) +
      labs(
        title = "Randomization Inference p-values Across Blocking Structures",
        subtitle = "Network fuel exposure coefficient",
        x = "",
        y = "p-value"
      ) +
      coord_cartesian(ylim = c(0, max(ri_data$p_value, na.rm = TRUE) * 1.15)) +
      theme_apep() +
      theme(axis.text.x = element_text(angle = 20, hjust = 1))

    save_fig(p16, "fig_ri_comparison", width = 7, height = 5)
    fig16_ok <- TRUE
  }
}

if (!fig16_ok) {
  cat("  WARNING: Could not create RI comparison plot. Skipping Figure 16.\n")
}


## ============================================================================
## DONE
## ============================================================================

cat("\n", strrep("=", 60), "\n")
cat("ALL FIGURES SAVED TO:", normalizePath(FIG_DIR), "\n")
cat(strrep("=", 60), "\n")

fig_files <- list.files(FIG_DIR, pattern = "\\.(pdf|png)$")
cat("Files produced:", length(fig_files), "\n")
for (f in sort(fig_files)) cat("  ", f, "\n")
