# =============================================================================
# 05_figures.R — Going Up Alone v4 (apep_0478)
# v4: Full arc (1900-1980), state choropleth maps, metro trajectories,
#     borough analysis, newspaper timeline, demographic panels
# All rates as per-10k employed (cleaned denominator)
# =============================================================================

source("00_packages.R")

cat("\n========================================\n")
cat("GENERATING FIGURES (v4)\n")
cat("========================================\n\n")

# Load data
national    <- fread(file.path(DATA_DIR, "national_clean.csv"))
state_panel <- fread(file.path(DATA_DIR, "scm_panel.csv"))
linked      <- fread(file.path(DATA_DIR, "linked_panel_clean.csv"))
trans_matrix <- fread(file.path(DATA_DIR, "transition_matrix.csv"))
trans_race  <- fread(file.path(DATA_DIR, "transition_by_race.csv"))
trans_city  <- fread(file.path(DATA_DIR, "transition_by_city.csv"))
trans_dir    <- fread(file.path(DATA_DIR, "transition_direction.csv"))
dest_quality <- fread(file.path(DATA_DIR, "destination_quality.csv"))
nyc_summary  <- fread(file.path(DATA_DIR, "nyc_vs_other_summary.csv"))
ame_df       <- fread(file.path(DATA_DIR, "selection_logit_ame.csv"))
nyc_trans    <- fread(file.path(DATA_DIR, "transition_by_nyc_detail.csv"))
full_arc     <- fread(file.path(DATA_DIR, "full_arc_1900_1980.csv"))

# Optional data
nyc_borough <- if (file.exists(file.path(DATA_DIR, "nyc_borough_clean.csv")))
                 fread(file.path(DATA_DIR, "nyc_borough_clean.csv")) else NULL
metro_panel <- if (file.exists(file.path(DATA_DIR, "metro_panel.csv")))
                 fread(file.path(DATA_DIR, "metro_panel.csv")) else NULL
county_panel <- if (file.exists(file.path(DATA_DIR, "county_panel.csv")))
                  fread(file.path(DATA_DIR, "county_panel.csv")) else NULL
borough_disp <- if (file.exists(file.path(DATA_DIR, "borough_displacement.csv")))
                  fread(file.path(DATA_DIR, "borough_displacement.csv")) else NULL
entry_origins <- if (file.exists(file.path(DATA_DIR, "entry_origins.csv")))
                   fread(file.path(DATA_DIR, "entry_origins.csv")) else NULL
newspaper_stats <- if (file.exists(file.path(DATA_DIR, "newspaper_year_category.csv")))
                     fread(file.path(DATA_DIR, "newspaper_year_category.csv")) else NULL

# ═══════════════════════════════════════════════════════════════════════════════
# Figure 1: THE FULL ARC — Rise and Extinction (1900-1980)
# ═══════════════════════════════════════════════════════════════════════════════

cat("Figure 1: Full extinction arc (1900-1980)...\n")

# Annotate data window
full_arc[, panel_window := year >= 1940 & year <= 1950]

p1 <- ggplot(full_arc, aes(x = year, y = elev_per_10k_emp)) +
  annotate("rect", xmin = 1940, xmax = 1950, ymin = -Inf, ymax = Inf,
           alpha = 0.08, fill = "#3498DB") +
  annotate("text", x = 1945, y = 1, label = "Linked panel\ndata window",
           color = "#3498DB", size = 2.8, fontface = "italic") +
  geom_line(linewidth = 1.3, color = apep_colors[1]) +
  geom_point(aes(shape = source), size = 3, color = apep_colors[1]) +
  geom_text(aes(label = sprintf("%.1f", elev_per_10k_emp)),
            vjust = -1.2, size = 2.5, fontface = "bold") +
  scale_x_continuous(breaks = seq(1900, 1980, 10)) +
  scale_shape_manual(values = c("full-count" = 16,
                                 "Census published statistics" = 17),
                     guide = "none") +
  labs(
    title = "Rise, Plateau, and Extinction",
    subtitle = "Elevator operators per 10,000 employed workers, 1900-1980",
    x = NULL, y = "Per 10,000 employed",
    caption = "Sources: IPUMS Full-Count Census (1900-1950); Census of Population,\nDetailed Characteristics (1960-1980). Employed denominator excludes OCC1950 special codes."
  ) +
  theme_apep()

ggsave(file.path(FIG_DIR, "fig1_full_arc.pdf"), p1, width = 8, height = 5.5)

# ═══════════════════════════════════════════════════════════════════════════════
# Figure 2: Comparison Occupations (1900-1980)
# ═══════════════════════════════════════════════════════════════════════════════

cat("Figure 2: Comparison occupations...\n")

comp_data <- full_arc[, .(year,
                          `Elevator operators` = elev_per_10k_emp,
                          `Janitors` = janitor_per_10k_emp,
                          `Porters` = porter_per_10k_emp,
                          `Guards` = guard_per_10k_emp)]
comp_long <- melt(comp_data, id.vars = "year",
                  variable.name = "Occupation", value.name = "per_10k")

p2 <- ggplot(comp_long, aes(x = year, y = per_10k, color = Occupation)) +
  geom_line(linewidth = 1) +
  geom_point(size = 2) +
  scale_color_manual(values = apep_colors[1:4]) +
  scale_x_continuous(breaks = seq(1900, 1980, 10)) +
  labs(
    title = "Building Service Occupations, 1900-1980",
    subtitle = "Only elevator operators were eliminated. Janitors grew continuously.",
    x = NULL, y = "Workers per 10,000 employed",
    caption = "Sources: IPUMS Full-Count Census (1900-1950); Census of Population (1960-1980)."
  ) +
  theme_apep() +
  theme(legend.position = c(0.2, 0.85))

ggsave(file.path(FIG_DIR, "fig2_comparison_occupations.pdf"), p2,
       width = 8, height = 5.5)

# ═══════════════════════════════════════════════════════════════════════════════
# Figure 3: Geographic Map — State-Level Elevator Operator Density
# ═══════════════════════════════════════════════════════════════════════════════

cat("Figure 3: State choropleth maps...\n")

# Get US state boundaries from tigris (cached)
tryCatch({
  library(tigris)
  options(tigris_use_cache = TRUE)

  us_states <- states(cb = TRUE, year = 2020, class = "sf") %>%
    filter(!STATEFP %in% c("02", "15", "60", "66", "69", "72", "78")) %>%
    shift_geometry()

  # STATEFIP to FIPS mapping
  us_states$STATEFIP <- as.integer(us_states$STATEFP)

  # Prepare map data for three key years
  map_years <- c(1920, 1940, 1950)
  map_data <- state_panel[year %in% map_years, .(STATEFIP, year, elev_per_10k_emp, state_name)]

  map_sf <- merge(us_states, map_data, by = "STATEFIP", all.x = TRUE, allow.cartesian = TRUE)

  p3 <- ggplot(map_sf) +
    geom_sf(aes(fill = elev_per_10k_emp), color = "white", linewidth = 0.2) +
    facet_wrap(~year, ncol = 3) +
    scale_fill_distiller(palette = "YlOrRd", direction = 1,
                         name = "Per 10,000\nemployed",
                         na.value = "grey90",
                         limits = c(0, max(map_data$elev_per_10k_emp, na.rm = TRUE))) +
    labs(
      title = "The Geography of Elevator Operation",
      subtitle = "Elevator operators per 10,000 employed workers by state",
      caption = "Source: IPUMS Full-Count Census. Excludes Alaska and Hawaii."
    ) +
    theme_apep() +
    theme(
      axis.text = element_blank(),
      axis.ticks = element_blank(),
      panel.grid = element_blank(),
      legend.position = "right"
    )

  ggsave(file.path(FIG_DIR, "fig3_map_states.pdf"), p3,
         width = 12, height = 5)

}, error = function(e) {
  cat(sprintf("  Map generation failed: %s\n", e$message))
  cat("  Falling back to state bar chart...\n")

  # Fallback: horizontal bar chart of top states
  top15 <- state_panel[year == 1940 & !is.na(state_name)]
  setorder(top15, -elev_per_10k_emp)
  top15 <- top15[1:15]

  p3 <- ggplot(top15, aes(x = reorder(state_name, elev_per_10k_emp),
                            y = elev_per_10k_emp)) +
    geom_col(fill = apep_colors[1], alpha = 0.85) +
    coord_flip() +
    labs(title = "Elevator Operator Density by State (1940)",
         x = NULL, y = "Per 10,000 employed") +
    theme_apep()

  ggsave(file.path(FIG_DIR, "fig3_map_states.pdf"), p3, width = 8, height = 6)
})

# ═══════════════════════════════════════════════════════════════════════════════
# Figure 4: Top Metro Area Trajectories
# ═══════════════════════════════════════════════════════════════════════════════

cat("Figure 4: Metro trajectories...\n")

if (!is.null(metro_panel)) {
  # Select top 8 metros by 1940 operator count
  top_metros <- metro_panel[year == 1940]
  setorder(top_metros, -n_elevator_ops)
  top_metro_names <- head(top_metros$metro_name, 8)

  # Exclude individual NYC boroughs from metro comparison; use NYC aggregate
  top_metro_names <- top_metro_names[!top_metro_names %in%
    c("Brooklyn", "Queens", "Bronx", "Staten Island")]

  # Add NYC aggregate
  nyc_agg <- metro_panel[metro_name %in% c("Manhattan", "Brooklyn", "Queens",
                                            "Bronx", "Staten Island"),
                          .(n_elevator_ops = sum(n_elevator_ops),
                            total_employed = sum(total_employed),
                            metro_name = "New York City"), by = year]
  nyc_agg[, elev_per_10k_emp := n_elevator_ops / total_employed * 10000]

  metro_plot <- rbind(
    metro_panel[metro_name %in% top_metro_names,
                .(year, metro_name, elev_per_10k_emp)],
    nyc_agg[, .(year, metro_name, elev_per_10k_emp)]
  )

  p4 <- ggplot(metro_plot, aes(x = year, y = elev_per_10k_emp,
                                color = metro_name)) +
    geom_line(linewidth = 1) +
    geom_point(size = 2) +
    scale_color_manual(values = apep_colors, name = "Metro area") +
    scale_x_continuous(breaks = seq(1900, 1950, 10)) +
    labs(
      title = "Metro Trajectories: NYC Towered Above All",
      subtitle = "Elevator operators per 10,000 employed, top metro areas",
      x = NULL, y = "Per 10,000 employed",
      caption = "Source: IPUMS Full-Count Census. Metro = primary county."
    ) +
    theme_apep() +
    theme(legend.position = "right")

  ggsave(file.path(FIG_DIR, "fig4_metro_trajectories.pdf"), p4,
         width = 9, height = 5.5)
}

# ═══════════════════════════════════════════════════════════════════════════════
# Figure 5: NYC Borough Comparison
# ═══════════════════════════════════════════════════════════════════════════════

cat("Figure 5: NYC boroughs...\n")

if (!is.null(nyc_borough)) {
  p5 <- ggplot(nyc_borough[borough != "Staten Island"],
               aes(x = year, y = elev_per_10k_emp, color = borough)) +
    geom_line(linewidth = 1.1) +
    geom_point(size = 2.5) +
    scale_color_manual(values = apep_colors[1:4], name = "Borough") +
    scale_x_continuous(breaks = seq(1900, 1950, 10)) +
    labs(
      title = "Manhattan's Density, Brooklyn's Workforce",
      subtitle = "Elevator operators per 10,000 employed, NYC boroughs",
      x = NULL, y = "Per 10,000 employed",
      caption = "Source: IPUMS Full-Count Census. COUNTYICP identifies boroughs."
    ) +
    theme_apep() +
    theme(legend.position = c(0.15, 0.85))

  ggsave(file.path(FIG_DIR, "fig5_nyc_boroughs.pdf"), p5,
         width = 8, height = 5.5)
}

# ═══════════════════════════════════════════════════════════════════════════════
# Figure 6: Newspaper Discourse — Thematic Composition + Corpus Normalization
# ═══════════════════════════════════════════════════════════════════════════════

cat("Figure 6: Newspaper themes + normalization...\n")

# Load building-elevator classified data (excl GRAIN/OTHER)
news_bldg <- if (file.exists(file.path(DATA_DIR, "newspaper_building_elevator.csv")))
               fread(file.path(DATA_DIR, "newspaper_building_elevator.csv")) else NULL

# Load corpus normalization data
corpus_norm <- if (file.exists(file.path(DATA_DIR, "corpus_normalization.csv")))
                 fread(file.path(DATA_DIR, "corpus_normalization.csv")) else NULL

if (!is.null(news_bldg)) {
  # Panel A: Stacked area of thematic shares
  news_bldg[, total := ACCIDENT + AUTOMATION + CONSTRUCTION + LABOR + STRIKE]
  shares <- news_bldg[, .(year,
    Accident = ACCIDENT / total * 100,
    Automation = AUTOMATION / total * 100,
    Construction = CONSTRUCTION / total * 100,
    Labor = LABOR / total * 100,
    Strike = STRIKE / total * 100
  )]
  shares_long <- melt(shares, id.vars = "year",
                      variable.name = "Category", value.name = "share")
  shares_long[, Category := factor(Category,
    levels = c("Strike", "Labor", "Automation", "Construction", "Accident"))]

  p6a <- ggplot(shares_long, aes(x = year, y = share, fill = Category)) +
    geom_area(alpha = 0.85) +
    geom_vline(xintercept = 1945, linetype = "dashed", color = "grey30", linewidth = 0.5) +
    annotate("text", x = 1946.5, y = 95, label = "1945\nstrike",
             size = 2.5, color = "grey30", hjust = 0, fontface = "italic") +
    scale_fill_manual(values = c(
      "Strike" = "#E74C3C", "Labor" = "#F39C12",
      "Automation" = "#3498DB", "Construction" = "#2ECC71",
      "Accident" = "#9B59B6"
    ), name = NULL) +
    scale_x_continuous(breaks = seq(1900, 1960, 10)) +
    labs(title = "Panel A: Thematic Composition of Elevator Coverage",
         x = NULL, y = "Share of classified articles (%)") +
    theme_apep() +
    theme(legend.position = "right")

  # Panel B: Corpus-normalized rate OR raw counts
  if (!is.null(corpus_norm)) {
    p6b <- ggplot(corpus_norm, aes(x = year, y = rate_per_10k)) +
      geom_line(linewidth = 1.1, color = apep_colors[1]) +
      geom_point(size = 3, color = apep_colors[1]) +
      geom_text(aes(label = sprintf("%.1f", rate_per_10k)),
                vjust = -1.2, size = 2.5) +
      geom_vline(xintercept = 1945, linetype = "dashed", color = "grey30", linewidth = 0.5) +
      scale_x_continuous(breaks = seq(1900, 1960, 10)) +
      labs(title = "Panel B: Elevator Articles per 10,000 Corpus Articles",
           subtitle = "Normalized by total American Stories corpus size per year",
           x = NULL, y = "Rate per 10,000 articles") +
      theme_apep()
  } else {
    # Fallback: raw counts
    news_bldg_counts <- news_bldg[, .(year, total)]
    p6b <- ggplot(news_bldg_counts, aes(x = year, y = total)) +
      geom_col(fill = apep_colors[1], alpha = 0.8) +
      geom_text(aes(label = format(total, big.mark = ",")),
                vjust = -0.3, size = 2.5) +
      scale_x_continuous(breaks = seq(1900, 1960, 10)) +
      labs(title = "Panel B: Building-Elevator Article Volume",
           x = NULL, y = "Number of articles") +
      theme_apep()
  }

  p6 <- p6a / p6b +
    plot_annotation(
      title = "The Newspaper Record: What Americans Said About Elevator Operators",
      subtitle = "Keyword-classified articles from the American Stories corpus, 14 sampled years (1900-1960)",
      caption = "Source: American Stories corpus (Chronicling America). Classification: deterministic keyword matching.\nBuilding-elevator articles only (grain elevator articles excluded). See Appendix B for keyword dictionary.",
      theme = theme_apep()
    )

  ggsave(file.path(FIG_DIR, "fig6_newspaper_themes.pdf"), p6,
         width = 9, height = 10)
}

# ═══════════════════════════════════════════════════════════════════════════════
# Figure 6b: Geographic Variation in Newspaper Coverage
# ═══════════════════════════════════════════════════════════════════════════════

cat("Figure 6b: Newspaper geography...\n")

news_geo <- if (file.exists(file.path(DATA_DIR, "newspaper_by_city.csv")))
              fread(file.path(DATA_DIR, "newspaper_by_city.csv")) else NULL

if (!is.null(news_geo)) {
  # Rename city_group to city if needed
  if ("city_group" %in% names(news_geo) && !"city" %in% names(news_geo)) {
    setnames(news_geo, "city_group", "city")
  }
  # Exclude Unknown and Other aggregates
  news_geo <- news_geo[!city %in% c("Unknown", "Other")]

  # Top cities by total article count
  city_totals <- news_geo[, .(total = sum(total, na.rm = TRUE)), by = city]
  setorder(city_totals, -total)
  top_cities <- head(city_totals$city, 6)

  geo_top <- news_geo[city %in% top_cities]
  geo_top[, city := factor(city, levels = top_cities)]

  # Panel: total articles over time by city
  p6b_fig <- ggplot(geo_top, aes(x = year, y = total, color = city)) +
    geom_line(linewidth = 1) +
    geom_point(size = 2) +
    geom_vline(xintercept = 1945, linetype = "dashed", color = "grey30", linewidth = 0.5) +
    scale_color_manual(values = apep_colors[1:6], name = "City") +
    scale_x_continuous(breaks = seq(1900, 1960, 10)) +
    labs(
      title = "Geographic Variation in Elevator Newspaper Coverage",
      subtitle = "Building-elevator articles by city, top 6 cities by volume",
      x = NULL, y = "Number of articles",
      caption = "Source: American Stories corpus. City parsed from newspaper metadata.\nGrain elevator articles excluded."
    ) +
    theme_apep() +
    theme(legend.position = "right")

  ggsave(file.path(FIG_DIR, "fig6b_newspaper_geography.pdf"), p6b_fig,
         width = 9, height = 5.5)
}

# ═══════════════════════════════════════════════════════════════════════════════
# Figure 6c: Category Trend Lines — The Discursive Shift
# ═══════════════════════════════════════════════════════════════════════════════

cat("Figure 6c: Category trends...\n")

if (!is.null(news_bldg)) {
  trend_long <- melt(news_bldg[, .(year, Accident = ACCIDENT, Automation = AUTOMATION,
                                    Labor = LABOR, Strike = STRIKE)],
                     id.vars = "year",
                     variable.name = "Category", value.name = "count")

  p6c <- ggplot(trend_long, aes(x = year, y = count, color = Category)) +
    geom_line(linewidth = 1.1) +
    geom_point(size = 2.5) +
    geom_vline(xintercept = 1945, linetype = "dashed", color = "grey30", linewidth = 0.5) +
    annotate("text", x = 1946.5, y = max(trend_long$count) * 0.9,
             label = "1945\nstrike", size = 2.5, color = "grey30",
             hjust = 0, fontface = "italic") +
    scale_color_manual(values = c(
      "Accident" = "#9B59B6", "Automation" = "#3498DB",
      "Labor" = "#F39C12", "Strike" = "#E74C3C"
    ), name = NULL) +
    scale_x_continuous(breaks = seq(1900, 1960, 10)) +
    labs(
      title = "The Discursive Shift: From Accidents to Automation",
      subtitle = "Thematic category trends in building-elevator newspaper articles",
      x = NULL, y = "Number of articles",
      caption = "Source: American Stories corpus. Keyword classification.\nConstruction category omitted for visual clarity."
    ) +
    theme_apep() +
    theme(legend.position = c(0.85, 0.85))

  ggsave(file.path(FIG_DIR, "fig6c_newspaper_shift.pdf"), p6c,
         width = 9, height = 5.5)
}

# ═══════════════════════════════════════════════════════════════════════════════
# Figure 7: Where Did They Go? (Transition Bar Chart)
# ═══════════════════════════════════════════════════════════════════════════════

cat("Figure 7: Occupational flow...\n")

trans_matrix[, occ_broad_1950 := factor(occ_broad_1950,
  levels = trans_matrix[order(-N)]$occ_broad_1950)]

p7 <- ggplot(trans_matrix, aes(x = reorder(occ_broad_1950, -pct), y = pct)) +
  geom_col(fill = apep_colors[1], alpha = 0.85) +
  geom_text(aes(label = sprintf("%.1f%%", pct)),
            vjust = -0.3, size = 3) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.15))) +
  labs(
    title = "Where Were the Displaced Operators by 1950?",
    subtitle = "1950 occupation of individuals who were elevator operators in 1940",
    x = NULL, y = "Percent of 1940 elevator operators",
    caption = "Source: IPUMS Full-Count Census + MLP v2.0 linked panel."
  ) +
  theme_apep() +
  theme(axis.text.x = element_text(angle = 35, hjust = 1, size = 9))

ggsave(file.path(FIG_DIR, "fig7_transition_flow.pdf"), p7,
       width = 9, height = 6)

# ═══════════════════════════════════════════════════════════════════════════════
# Figure 8: Transition by Race (Black vs Non-Black)
# ═══════════════════════════════════════════════════════════════════════════════

cat("Figure 8: Transition by race...\n")

top_dest <- trans_matrix[order(-N)]$occ_broad_1950[1:6]
trans_race_sub <- trans_race[occ_broad_1950 %in% top_dest]
trans_race_sub[, race_label := fifelse(is_black == 1, "Black", "Non-Black")]

p8 <- ggplot(trans_race_sub,
             aes(x = occ_broad_1950, y = pct, fill = race_label)) +
  geom_col(position = "dodge", alpha = 0.85) +
  scale_fill_manual(values = c(apep_colors[3], apep_colors[1]), name = NULL) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.1))) +
  labs(
    title = "The Unequal Burden of Displacement",
    subtitle = "1950 destination of 1940 elevator operators, by race",
    x = NULL, y = "Percent",
    caption = "Source: IPUMS + MLP linked panel."
  ) +
  theme_apep() +
  theme(axis.text.x = element_text(angle = 30, hjust = 1, size = 9),
        legend.position = c(0.85, 0.85))

ggsave(file.path(FIG_DIR, "fig8_transition_race.pdf"), p8,
       width = 9, height = 6)

# ═══════════════════════════════════════════════════════════════════════════════
# Figure 9: NYC vs Non-NYC Transitions
# ═══════════════════════════════════════════════════════════════════════════════

cat("Figure 9: NYC vs non-NYC...\n")

nyc_trans_sub <- nyc_trans[occ_broad_1950 %in% top_dest]
nyc_trans_sub[, city_label := fifelse(is_nyc_1940 == 1, "NYC", "Other cities")]

p9 <- ggplot(nyc_trans_sub,
             aes(x = occ_broad_1950, y = pct, fill = city_label)) +
  geom_col(position = "dodge", alpha = 0.85) +
  scale_fill_manual(values = c(apep_colors[2], apep_colors[4]), name = NULL) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.1))) +
  labs(
    title = "Institutional Thickness: NYC Retained Operators Longer",
    subtitle = "NYC operators were MORE likely to stay in the occupation",
    x = NULL, y = "Percent of elevator operators",
    caption = "Source: IPUMS + MLP linked panel. NYC = five boroughs."
  ) +
  theme_apep() +
  theme(axis.text.x = element_text(angle = 30, hjust = 1, size = 9),
        legend.position = c(0.85, 0.85))

ggsave(file.path(FIG_DIR, "fig9_nyc_vs_other.pdf"), p9,
       width = 9, height = 6)

# ═══════════════════════════════════════════════════════════════════════════════
# Figure 10: Demographic Composition Evolution
# ═══════════════════════════════════════════════════════════════════════════════

cat("Figure 10: Demographics...\n")

race_data <- national[, .(year,
                          `White` = 100 - pct_black - pct_other_race,
                          `Black` = pct_black,
                          `Other` = pct_other_race)]
race_long <- melt(race_data, id.vars = "year",
                  variable.name = "race", value.name = "percent")
race_long[, race := factor(race, levels = c("Other", "Black", "White"))]

p10a <- ggplot(race_long, aes(x = year, y = percent, fill = race)) +
  geom_area(alpha = 0.85) +
  scale_fill_manual(values = c("grey70", apep_colors[3], apep_colors[1]),
                    name = "Race") +
  scale_x_continuous(breaks = seq(1900, 1950, 10)) +
  labs(title = "Panel A: Racial Composition",
       x = NULL, y = "Share (%)") +
  theme_apep() +
  theme(legend.position = "right")

age_data <- national[, .(year,
                          `Under 20` = pct_under20,
                          `20-29` = pct_20s,
                          `30-39` = pct_30s,
                          `40-49` = pct_40s,
                          `50-59` = pct_50s,
                          `60+` = pct_60plus)]
age_long <- melt(age_data, id.vars = "year",
                 variable.name = "age_group", value.name = "percent")
age_long[, age_group := factor(age_group,
                                levels = c("Under 20", "20-29", "30-39",
                                          "40-49", "50-59", "60+"))]

p10b <- ggplot(age_long, aes(x = year, y = percent, fill = age_group)) +
  geom_area(alpha = 0.85) +
  scale_fill_manual(values = rev(brewer.pal(6, "Blues")), name = "Age group") +
  scale_x_continuous(breaks = seq(1900, 1950, 10)) +
  labs(title = "Panel B: Age Distribution",
       x = NULL, y = "Share (%)") +
  theme_apep() +
  theme(legend.position = "right")

p10 <- p10a / p10b +
  plot_annotation(
    title = "The Changing Face of the Elevator Operator",
    subtitle = "Demographic composition, 1900-1950",
    caption = "Source: IPUMS Full-Count Census, OCC1950 = 761.",
    theme = theme_apep()
  )

ggsave(file.path(FIG_DIR, "fig10_demographics.pdf"), p10,
       width = 8, height = 10)

# ═══════════════════════════════════════════════════════════════════════════════
# Figure 11: Selection Coefficient Plot
# ═══════════════════════════════════════════════════════════════════════════════

cat("Figure 11: Selection coefficients...\n")

ame_plot <- ame_df[variable != "(Intercept)"]
ame_plot[, variable := fcase(
  variable == "age_centered", "Age (centered)",
  variable == "age_centered_sq", "Age squared",
  variable == "is_black", "Black",
  variable == "is_female", "Female",
  variable == "is_native", "Native-born",
  variable == "is_married", "Married",
  variable == "is_nyc_1940", "NYC resident",
  default = variable
)]
ame_plot[, ci_lo := ame - 1.96 * se * abs(ame / coefficient)]
ame_plot[, ci_hi := ame + 1.96 * se * abs(ame / coefficient)]
ame_plot[, sig := fifelse(p_value < 0.05, "p < 0.05", "n.s.")]

p11 <- ggplot(ame_plot, aes(x = reorder(variable, ame), y = ame, color = sig)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
  geom_pointrange(aes(ymin = ci_lo, ymax = ci_hi), size = 0.8) +
  scale_color_manual(values = c("p < 0.05" = apep_colors[1],
                                "n.s." = "grey60"), name = NULL) +
  coord_flip() +
  labs(
    title = "Who Stayed? Selection into Occupational Persistence",
    subtitle = "Average marginal effects: P(still elevator operator in 1950)",
    x = NULL, y = "Average marginal effect on P(staying)",
    caption = "Source: IPUMS + MLP linked panel."
  ) +
  theme_apep() +
  theme(legend.position = c(0.85, 0.15))

ggsave(file.path(FIG_DIR, "fig11_selection_coefficients.pdf"), p11,
       width = 8, height = 5.5)

# ═══════════════════════════════════════════════════════════════════════════════
# Figure 12: Entry Analysis (v4 new)
# ═══════════════════════════════════════════════════════════════════════════════

cat("Figure 12: Entry analysis...\n")

if (!is.null(entry_origins)) {
  entry_origins[, occ_broad_1940 := factor(occ_broad_1940,
    levels = entry_origins[order(-N)]$occ_broad_1940)]

  p12 <- ggplot(entry_origins, aes(x = reorder(occ_broad_1940, -pct), y = pct)) +
    geom_col(fill = apep_colors[5], alpha = 0.85) +
    geom_text(aes(label = sprintf("%.1f%%", pct)),
              vjust = -0.3, size = 3) +
    scale_y_continuous(expand = expansion(mult = c(0, 0.15))) +
    labs(
      title = "Where Did New Operators Come From?",
      subtitle = "1940 occupation of workers who became elevator operators by 1950",
      x = NULL, y = "Percent of 1950 entrants",
      caption = "Source: IPUMS + MLP linked panel. N = 36,700 entrants."
    ) +
    theme_apep() +
    theme(axis.text.x = element_text(angle = 35, hjust = 1, size = 9))

  ggsave(file.path(FIG_DIR, "fig12_entry_origins.pdf"), p12,
         width = 9, height = 6)
}

# ═══════════════════════════════════════════════════════════════════════════════
# Appendix figures
# ═══════════════════════════════════════════════════════════════════════════════

cat("Appendix figures...\n")

# A1: Placebo spaghetti
if (file.exists(file.path(DATA_DIR, "placebo_gaps.csv")) &&
    file.exists(file.path(DATA_DIR, "scm_results.rds"))) {
  placebo_df <- fread(file.path(DATA_DIR, "placebo_gaps.csv"))
  scm_res <- readRDS(file.path(DATA_DIR, "scm_results.rds"))

  if ("gap" %in% names(scm_res)) {
    nyc_gap <- as.data.table(scm_res$gap)

    p_a1 <- ggplot() +
      geom_line(data = placebo_df,
                aes(x = year, y = gap, group = STATEFIP),
                color = "grey70", alpha = 0.5, linewidth = 0.4) +
      geom_line(data = nyc_gap,
                aes(x = year, y = gap),
                color = apep_colors[2], linewidth = 1.3) +
      geom_point(data = nyc_gap,
                 aes(x = year, y = gap),
                 color = apep_colors[2], size = 3) +
      geom_vline(xintercept = 1940, linetype = "dashed", color = "grey50") +
      geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
      scale_x_continuous(breaks = seq(1900, 1950, 10)) +
      labs(
        title = "Placebo Tests: New York is the Outlier",
        x = NULL, y = "Gap (actual - synthetic)"
      ) +
      theme_apep()

    ggsave(file.path(FIG_DIR, "fig_a1_placebo_spaghetti.pdf"), p_a1,
           width = 8, height = 6)
  }
}

# A2: SCM results
if (file.exists(file.path(DATA_DIR, "scm_results.rds"))) {
  scm_res <- readRDS(file.path(DATA_DIR, "scm_results.rds"))

  if ("gap" %in% names(scm_res)) {
    gap_df <- as.data.table(scm_res$gap)
    gap_long <- melt(gap_df[, .(year, `NYC (actual)` = nyc_actual,
                                 `Synthetic NYC` = nyc_synthetic)],
                     id.vars = "year",
                     variable.name = "series", value.name = "value")

    p_a2 <- ggplot(gap_long, aes(x = year, y = value, color = series,
                                   linetype = series)) +
      geom_line(linewidth = 1.1) +
      geom_point(size = 3) +
      geom_vline(xintercept = 1940, linetype = "dashed", color = "grey50") +
      scale_color_manual(values = c(apep_colors[1], apep_colors[2]), name = NULL) +
      scale_linetype_manual(values = c("solid", "dashed"), name = NULL) +
      scale_x_continuous(breaks = seq(1900, 1950, 10)) +
      labs(
        title = "Synthetic Control: NYC vs. Weighted Comparison States",
        x = NULL, y = "Operators per 10,000 population"
      ) +
      theme_apep() +
      theme(legend.position = c(0.2, 0.85))

    ggsave(file.path(FIG_DIR, "fig_a2_scm_results.pdf"), p_a2,
           width = 8, height = 5.5)
  }
}

cat("\n========================================\n")
cat("FIGURES COMPLETE\n")
cat(sprintf("Saved %d figures to %s\n", length(list.files(FIG_DIR, "*.pdf")), FIG_DIR))
cat("========================================\n")
