###############################################################################
# 05_figures.R — All figures for the paper
# The Unequal Legacies of the Tennessee Valley Authority
# APEP-0470
###############################################################################

source("code/00_packages.R")

has_individual <- file.exists(paste0(data_dir, "individual_panel_30_40.csv"))
has_county <- file.exists(paste0(data_dir, "county_panel.csv"))
has_results <- file.exists(paste0(data_dir, "main_results.rds"))
has_rob <- file.exists(paste0(data_dir, "robustness_results.rds"))

if (has_results) results <- readRDS(paste0(data_dir, "main_results.rds"))
if (has_rob) rob <- readRDS(paste0(data_dir, "robustness_results.rds"))
if (has_county) cp <- fread(paste0(data_dir, "county_panel.csv"))

counties_sf <- readRDS(paste0(data_dir, "counties_sf.rds"))
county_class <- fread(paste0(data_dir, "county_classification.csv"))
tva_dams <- fread(paste0(data_dir, "tva_dams.csv"))

# ═══════════════════════════════════════════════════════════════════════════════
# FIGURE 1: MAP — TVA Service Area and Dam Locations
# ═══════════════════════════════════════════════════════════════════════════════

cat("Creating Figure 1: TVA Map...\n")

# Merge classification into shapefile (avoid duplicating columns already in counties_sf)
merge_cols <- c("GEOID", "tva_core", "tva_peripheral", "tva_any", "border_control")
# Only add dist_nearest_dam_km if not already present
if (!"dist_nearest_dam_km" %in% names(counties_sf)) {
  merge_cols <- c(merge_cols, "dist_nearest_dam_km")
}
counties_map <- merge(counties_sf,
                       county_class[, ..merge_cols],
                       by = "GEOID", all.x = TRUE)

counties_map$region <- ifelse(counties_map$tva_core, "TVA Core",
                       ifelse(counties_map$tva_peripheral, "TVA Peripheral",
                       ifelse(counties_map$border_control, "Border Control",
                              "Distant Control")))
counties_map$region <- factor(counties_map$region,
                               levels = c("TVA Core", "TVA Peripheral",
                                          "Border Control", "Distant Control"))

# Dam points
dams_sf <- st_as_sf(tva_dams, coords = c("lon", "lat"), crs = 4326) |>
  st_transform(5070)

# Crop to Southeast
bbox <- st_bbox(counties_map[counties_map$STATEFP %in%
  c("01", "13", "21", "28", "37", "47", "51", "45", "54"), ])

fig1 <- ggplot() +
  geom_sf(data = counties_map, aes(fill = region),
          color = "grey70", linewidth = 0.1) +
  geom_sf(data = dams_sf, color = "black", fill = "gold",
          shape = 24, size = 3, stroke = 0.8) +
  scale_fill_manual(
    values = c("TVA Core" = "#1a5276",
               "TVA Peripheral" = "#5dade2",
               "Border Control" = "#f0b27a",
               "Distant Control" = "#f5f5f5"),
    name = "County Classification"
  ) +
  coord_sf(xlim = c(bbox["xmin"] - 50000, bbox["xmax"] + 50000),
           ylim = c(bbox["ymin"] - 50000, bbox["ymax"] + 50000)) +
  labs(title = "The Tennessee Valley Authority Service Area",
       subtitle = "County classification and dam locations, circa 1933-1944",
       caption = "Triangles indicate TVA dam sites. Core TVA = within 150km of a dam in TVA state.") +
  theme_tva +
  theme(axis.text = element_blank(), axis.ticks = element_blank(),
        axis.title = element_blank(), panel.grid = element_blank())

ggsave(paste0(fig_dir, "fig1_tva_map.pdf"), fig1, width = 10, height = 7)
cat("✓ Figure 1 saved\n")

# ═══════════════════════════════════════════════════════════════════════════════
# FIGURE 2: MAP — Distance Gradient (Heat Map)
# ═══════════════════════════════════════════════════════════════════════════════

cat("Creating Figure 2: Distance Gradient Map...\n")

counties_map$dist_dam_capped <- pmin(counties_map$dist_nearest_dam_km, 500)

fig2 <- ggplot() +
  geom_sf(data = counties_map, aes(fill = dist_dam_capped),
          color = "grey80", linewidth = 0.05) +
  geom_sf(data = dams_sf, color = "black", fill = "red",
          shape = 24, size = 2.5, stroke = 0.8) +
  scale_fill_viridis_c(
    name = "Distance to\nNearest Dam (km)",
    option = "magma", direction = -1,
    breaks = c(0, 100, 200, 300, 400, 500),
    labels = c("0", "100", "200", "300", "400", "500+")
  ) +
  coord_sf(xlim = c(bbox["xmin"] - 50000, bbox["xmax"] + 50000),
           ylim = c(bbox["ymin"] - 50000, bbox["ymax"] + 50000)) +
  labs(title = "Treatment Intensity: Distance to Nearest TVA Dam",
       subtitle = "Continuous measure of TVA infrastructure exposure",
       caption = "Distance computed from county centroid to nearest TVA dam in Albers Equal Area projection.") +
  theme_tva +
  theme(axis.text = element_blank(), axis.ticks = element_blank(),
        axis.title = element_blank(), panel.grid = element_blank())

ggsave(paste0(fig_dir, "fig2_distance_gradient.pdf"), fig2, width = 10, height = 7)
cat("✓ Figure 2 saved\n")

# ═══════════════════════════════════════════════════════════════════════════════
# FIGURE 3: EVENT STUDY — Pre-Trends and Treatment Effects
# ═══════════════════════════════════════════════════════════════════════════════

if (has_results && !is.null(results$a1_main)) {
  cat("Creating Figure 3: Event Study...\n")

  if (has_rob && !is.null(rob$r1_event)) {
    # Extract event study coefficients
    event_mfg <- rob$r1_event$mfg
    event_sei <- rob$r1_event$sei

    # Build coefficient plot data
    es_data <- data.table(
      year = c(1920, 1930, 1940, 1920, 1930, 1940),
      outcome = rep(c("Manufacturing Share", "Mean SEI Score"), each = 3),
      coef = c(coef(event_mfg)["tva_x_1920"], 0, coef(event_mfg)["tva_x_1940"],
               coef(event_sei)["tva_x_1920"], 0, coef(event_sei)["tva_x_1940"]),
      se = c(se(event_mfg)["tva_x_1920"], 0, se(event_mfg)["tva_x_1940"],
             se(event_sei)["tva_x_1920"], 0, se(event_sei)["tva_x_1940"])
    )
    es_data[, ci_lo := coef - 1.96 * se]
    es_data[, ci_hi := coef + 1.96 * se]

    fig3 <- ggplot(es_data, aes(x = year, y = coef)) +
      geom_hline(yintercept = 0, color = "grey50", linetype = "dashed") +
      geom_vline(xintercept = 1933, color = "#e74c3c", linetype = "dotted",
                 linewidth = 0.7) +
      geom_errorbar(aes(ymin = ci_lo, ymax = ci_hi),
                    width = 1.5, linewidth = 0.6, color = "#1a5276") +
      geom_point(size = 3, color = "#1a5276", fill = "white", shape = 21,
                 stroke = 1.2) +
      facet_wrap(~outcome, scales = "free_y") +
      annotate("text", x = 1933.5, y = Inf, label = "TVA Created →",
               hjust = 0, vjust = 2, size = 3, color = "#e74c3c",
               fontface = "italic") +
      scale_x_continuous(breaks = c(1920, 1930, 1940)) +
      labs(title = "Event Study: TVA Effects on County Outcomes",
           subtitle = "Coefficients relative to 1930 (last pre-treatment census). 95% CIs.",
           x = "Census Year", y = "Coefficient (TVA × Year)") +
      theme_tva

    ggsave(paste0(fig_dir, "fig3_event_study.pdf"), fig3, width = 10, height = 5)
    cat("✓ Figure 3 saved\n")
  }
}

# ═══════════════════════════════════════════════════════════════════════════════
# FIGURE 4: DISTANCE DECAY — Non-Parametric Gradient
# ═══════════════════════════════════════════════════════════════════════════════

if (has_rob && !is.null(rob$r3_bins)) {
  cat("Creating Figure 4: Distance Decay...\n")

  # Extract bin coefficients
  bins_mfg <- coef(rob$r3_bins$mfg)
  bins_se <- se(rob$r3_bins$mfg)

  bin_data <- data.table(
    dist_bin = c("0-50km", "50-100km", "100-150km", "150-200km",
                 "200-300km", "300-500km"),
    dist_mid = c(25, 75, 125, 175, 250, 400),
    coef = as.numeric(bins_mfg),
    se = as.numeric(bins_se)
  )
  bin_data[, ci_lo := coef - 1.96 * se]
  bin_data[, ci_hi := coef + 1.96 * se]

  fig4 <- ggplot(bin_data, aes(x = dist_mid, y = coef)) +
    geom_hline(yintercept = 0, color = "grey50", linetype = "dashed") +
    geom_ribbon(aes(ymin = ci_lo, ymax = ci_hi),
                fill = "#1a5276", alpha = 0.15) +
    geom_line(color = "#1a5276", linewidth = 0.8) +
    geom_point(size = 3, color = "#1a5276", fill = "white",
               shape = 21, stroke = 1.2) +
    scale_x_continuous(breaks = c(25, 75, 125, 175, 250, 400),
                       labels = bin_data$dist_bin) +
    labs(title = "The Reach of the Valley: TVA Effects by Distance",
         subtitle = "Manufacturing share effect relative to counties 500+ km from nearest TVA dam",
         x = "Distance to Nearest TVA Dam",
         y = "Differential Change in Manufacturing Share (pp)") +
    theme_tva +
    theme(axis.text.x = element_text(angle = 30, hjust = 1))

  ggsave(paste0(fig_dir, "fig4_distance_decay.pdf"), fig4, width = 8, height = 5.5)
  cat("✓ Figure 4 saved\n")
}

# ═══════════════════════════════════════════════════════════════════════════════
# FIGURE 5: HETEROGENEITY — Race × Gender Four-Way Decomposition
# ═══════════════════════════════════════════════════════════════════════════════

if (has_county && has_results) {
  cat("Creating Figure 5: Race/Gender Heterogeneity...\n")

  # County-level race and gender interaction coefficients
  # Run regressions on race- and gender-specific outcomes
  cp_fig <- fread(paste0(data_dir, "county_panel.csv"))
  cp_fig[is.na(tva_any), tva_any := FALSE]
  cp_fig[, tva := as.integer(tva_any)]
  cp_fig[, post := as.integer(year == 1940)]
  cp_fig[, tva_post := tva * post]

  # Four outcome regressions
  r_sei_w <- feols(sei_white ~ tva_post | county_id + year,
                   data = cp_fig, cluster = ~statefip)
  r_sei_b <- feols(sei_black ~ tva_post | county_id + year,
                   data = cp_fig, cluster = ~statefip)
  r_lf_m <- feols(pct_lf_male ~ tva_post | county_id + year,
                  data = cp_fig, cluster = ~statefip)
  r_lf_f <- feols(pct_lf_female ~ tva_post | county_id + year,
                  data = cp_fig, cluster = ~statefip)

  het_data <- data.table(
    group = c("White SEI", "Black SEI",
              "Male LFP", "Female LFP"),
    coef = c(coef(r_sei_w), coef(r_sei_b),
             coef(r_lf_m), coef(r_lf_f)),
    se = c(se(r_sei_w), se(r_sei_b),
           se(r_lf_m), se(r_lf_f))
  )
  het_data[, ci_lo := coef - 1.96 * se]
  het_data[, ci_hi := coef + 1.96 * se]
  het_data[, group := factor(group, levels = rev(c("White SEI", "Black SEI",
                                                     "Male LFP", "Female LFP")))]

  fig5 <- ggplot(het_data, aes(x = coef, y = group)) +
    geom_vline(xintercept = 0, color = "grey50", linetype = "dashed") +
    geom_errorbarh(aes(xmin = ci_lo, xmax = ci_hi),
                   height = 0.2, linewidth = 0.7,
                   color = c("#8e44ad", "#2980b9", "#e74c3c", "#1a5276")) +
    geom_point(size = 4, shape = 21, stroke = 1.2,
               fill = c("#8e44ad", "#2980b9", "#e74c3c", "#1a5276"),
               color = "white") +
    labs(title = "Who Benefited from the TVA?",
         subtitle = "TVA x Post effect on group-specific outcomes (county-level DiD)",
         x = "TVA Effect (coefficient)", y = NULL) +
    theme_tva +
    theme(axis.text.y = element_text(size = 12, face = "bold"))

  ggsave(paste0(fig_dir, "fig5_heterogeneity.pdf"), fig5, width = 8, height = 5)
  cat("✓ Figure 5 saved\n")
}

# ═══════════════════════════════════════════════════════════════════════════════
# FIGURE 6: MAP — Heterogeneous Effects by County
# ═══════════════════════════════════════════════════════════════════════════════

if (has_county) {
  cat("Creating Figure 6: Outcome Maps...\n")

  # Manufacturing share change by county
  cp_wide <- dcast(cp, county_id + statefip + countyfip_approx + tva_any +
                     dist_nearest_dam_km ~ year,
                   value.var = c("pct_mfg", "pct_ag", "mean_sei"))

  if ("pct_mfg_1930" %in% names(cp_wide) && "pct_mfg_1940" %in% names(cp_wide)) {
    cp_wide[, delta_mfg := pct_mfg_1940 - pct_mfg_1930]
    cp_wide[, delta_sei := mean_sei_1940 - mean_sei_1930]
    cp_wide[, GEOID := sprintf("%02d%03d", statefip, countyfip_approx)]

    # Merge back to shapefile
    map_change <- merge(counties_sf, cp_wide, by = "GEOID", all.x = FALSE)

    fig6a <- ggplot() +
      geom_sf(data = map_change, aes(fill = delta_mfg),
              color = "grey80", linewidth = 0.05) +
      geom_sf(data = dams_sf, color = "black", fill = "gold",
              shape = 24, size = 2, stroke = 0.6) +
      scale_fill_gradient2(
        low = "#b03a2e", mid = "white", high = "#1a5276",
        midpoint = 0, name = "Δ Manufacturing\nShare (pp)",
        limits = c(-0.15, 0.15), oob = scales::squish
      ) +
      coord_sf(xlim = c(bbox["xmin"] - 50000, bbox["xmax"] + 50000),
               ylim = c(bbox["ymin"] - 50000, bbox["ymax"] + 50000)) +
      labs(title = "Change in Manufacturing Share, 1930-1940",
           subtitle = "Blue = increasing manufacturing; Red = declining") +
      theme_tva +
      theme(axis.text = element_blank(), axis.ticks = element_blank(),
            axis.title = element_blank(), panel.grid = element_blank())

    ggsave(paste0(fig_dir, "fig6_delta_mfg_map.pdf"), fig6a, width = 10, height = 7)
    cat("✓ Figure 6 saved\n")
  }
}

# ═══════════════════════════════════════════════════════════════════════════════
# FIGURE 7: OCCUPATIONAL TRANSITIONS — Sankey-style
# ═══════════════════════════════════════════════════════════════════════════════

if (has_county) {
  cat("Creating Figure 7: Sectoral Composition Shift...\n")

  cp_fig7 <- fread(paste0(data_dir, "county_panel.csv"))
  cp_fig7[is.na(tva_any), tva_any := FALSE]

  # Agricultural and manufacturing shares over time, by TVA status
  sector_means <- cp_fig7[, .(
    mfg = mean(pct_mfg, na.rm = TRUE),
    ag = mean(pct_ag, na.rm = TRUE)
  ), by = .(year, tva_any)]

  sector_long <- melt(sector_means, id.vars = c("year", "tva_any"),
                       variable.name = "sector", value.name = "share")
  sector_long[, group := paste0(
    fifelse(tva_any, "TVA", "Non-TVA"), " - ",
    fifelse(sector == "mfg", "Manufacturing", "Agriculture")
  )]

  fig7 <- ggplot(sector_long, aes(x = year, y = share, color = group,
                                    linetype = group)) +
    geom_line(linewidth = 1.1) +
    geom_point(size = 3, shape = 21, fill = "white", stroke = 1.2) +
    geom_vline(xintercept = 1933, color = "#e74c3c", linetype = "dotted",
               linewidth = 0.7) +
    scale_color_manual(values = c(
      "TVA - Manufacturing" = "#1a5276",
      "TVA - Agriculture" = "#5dade2",
      "Non-TVA - Manufacturing" = "#b03a2e",
      "Non-TVA - Agriculture" = "#f0b27a"
    )) +
    scale_linetype_manual(values = c(
      "TVA - Manufacturing" = "solid",
      "TVA - Agriculture" = "solid",
      "Non-TVA - Manufacturing" = "dashed",
      "Non-TVA - Agriculture" = "dashed"
    )) +
    scale_y_continuous(labels = percent_format()) +
    scale_x_continuous(breaks = c(1920, 1930, 1940)) +
    labs(title = "From Field to Factory: Sectoral Transformation in TVA Counties",
         subtitle = "Mean county-level employment shares, TVA vs. non-TVA counties",
         x = "Census Year", y = "Employment Share",
         color = NULL, linetype = NULL) +
    theme_tva +
    theme(legend.position = "bottom", legend.key.width = unit(2, "cm"))

  ggsave(paste0(fig_dir, "fig7_occ_transitions.pdf"), fig7, width = 9, height = 6)
  cat("✓ Figure 7 saved\n")
}

# ═══════════════════════════════════════════════════════════════════════════════
# FIGURE 8: RANDOMIZATION INFERENCE DISTRIBUTION
# ═══════════════════════════════════════════════════════════════════════════════

if (has_rob && !is.null(rob$r5_ri)) {
  cat("Creating Figure 8: Randomization Inference...\n")

  ri_df <- data.table(coef = rob$r5_ri$ri_coefs)
  obs <- rob$r5_ri$obs_coef

  fig8 <- ggplot(ri_df, aes(x = coef)) +
    geom_histogram(bins = 50, fill = "grey70", color = "white", linewidth = 0.3) +
    geom_vline(xintercept = obs, color = "#e74c3c", linewidth = 1.2,
               linetype = "solid") +
    annotate("text", x = obs, y = Inf, label = paste0("Observed\n(p = ",
             round(rob$r5_ri$ri_p, 3), ")"),
             hjust = -0.1, vjust = 2, color = "#e74c3c", fontface = "bold",
             size = 4) +
    labs(title = "Randomization Inference: Is the TVA Effect Real?",
         subtitle = paste0("Distribution of placebo coefficients from ",
                           length(rob$r5_ri$ri_coefs), " random permutations"),
         x = "Placebo TVA Effect on Manufacturing Share",
         y = "Count") +
    theme_tva

  ggsave(paste0(fig_dir, "fig8_randomization_inference.pdf"), fig8, width = 8, height = 5)
  cat("✓ Figure 8 saved\n")
}

# ═══════════════════════════════════════════════════════════════════════════════
# FIGURE 9: MAP — Racial Composition and TVA
# ═══════════════════════════════════════════════════════════════════════════════

if (has_county) {
  cat("Creating Figure 9: Racial Composition Map...\n")

  cp_1930 <- cp[year == 1930]
  cp_1930[, GEOID := sprintf("%02d%03d", statefip, countyfip_approx)]

  map_race <- merge(counties_sf, cp_1930[, .(GEOID, pct_black)],
                    by = "GEOID", all.x = FALSE)

  fig9 <- ggplot() +
    geom_sf(data = map_race, aes(fill = pct_black),
            color = "grey80", linewidth = 0.05) +
    geom_sf(data = dams_sf, color = "white", fill = "gold",
            shape = 24, size = 2, stroke = 0.6) +
    scale_fill_viridis_c(
      name = "Black Population\nShare (1930)",
      option = "inferno", direction = -1,
      labels = percent_format()
    ) +
    coord_sf(xlim = c(bbox["xmin"] - 50000, bbox["xmax"] + 50000),
             ylim = c(bbox["ymin"] - 50000, bbox["ymax"] + 50000)) +
    labs(title = "The Color Line: Black Population Share in the TVA Region, 1930",
         subtitle = "TVA dam locations overlaid on county-level racial composition") +
    theme_tva +
    theme(axis.text = element_blank(), axis.ticks = element_blank(),
          axis.title = element_blank(), panel.grid = element_blank())

  ggsave(paste0(fig_dir, "fig9_race_map.pdf"), fig9, width = 10, height = 7)
  cat("✓ Figure 9 saved\n")
}

cat("\n✓ All figures generated.\n")
cat("  Files in figures/:\n")
for (f in list.files(fig_dir, pattern = "\\.pdf$")) cat("    -", f, "\n")
