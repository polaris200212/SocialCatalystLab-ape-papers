## ============================================================================
## 05_figures.R -- Connected Backlash (apep_0464 v2)
## Publication-quality figures for the paper
## v2 changes: extended pre-treatment window (2002-2012), 10-election event study
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
## DONE
## ============================================================================

cat("\n", strrep("=", 60), "\n")
cat("ALL FIGURES SAVED TO:", normalizePath(FIG_DIR), "\n")
cat(strrep("=", 60), "\n")

fig_files <- list.files(FIG_DIR, pattern = "\\.(pdf|png)$")
cat("Files produced:", length(fig_files), "\n")
for (f in sort(fig_files)) cat("  ", f, "\n")
