#' ---
#' Selective Licensing and Crime Displacement
#' 05_figures.R — Generate all figures
#' ---

source("code/00_packages.R")

# ============================================================================
# JOURNAL-READY THEME
# ============================================================================

theme_journal <- theme_classic(base_size = 12) +
  theme(
    panel.grid.major.y = element_line(colour = "grey92", linewidth = 0.3),
    axis.line = element_line(colour = "grey30", linewidth = 0.4),
    axis.ticks = element_line(colour = "grey30", linewidth = 0.3),
    plot.title = element_text(face = "bold", size = 13, hjust = 0),
    legend.position = "bottom",
    legend.background = element_blank(),
    legend.key = element_blank()
  )

theme_set(theme_journal)

# ============================================================================
# LOAD DATA
# ============================================================================

panel <- fread(file.path(DATA_DIR, "analysis_panel.csv"))
panel[, month := as.Date(month)]
licensing <- fread(file.path(DATA_DIR, "licensing_dates.csv"))
es_coefs <- fread(file.path(DATA_DIR, "event_study_coefs.csv"))
cat_results <- fread(file.path(DATA_DIR, "category_results.csv"))

# ============================================================================
# FIGURE 1: Selective Licensing Adoption Timeline
# ============================================================================

message("Figure 1: Adoption timeline...")

adoption_data <- licensing |>
  mutate(
    adoption_date = as.Date(adoption_date),
    coverage_simple = ifelse(coverage %in% c("borough", "city"),
                             "Borough-wide", "Sub-area")
  ) |>
  filter(adoption_date >= "2013-01-01", adoption_date <= "2025-01-01") |>
  arrange(adoption_date) |>
  mutate(la_name = factor(la_name, levels = la_name))

adoption_fig <- ggplot(adoption_data, aes(x = adoption_date, y = la_name)) +
  geom_point(aes(color = coverage_simple), size = 3) +
  geom_vline(xintercept = as.Date("2024-12-23"), linetype = "dashed",
             color = "grey50", linewidth = 0.5) +
  annotate("text", x = as.Date("2024-12-23"), y = 2,
           label = "SoS approval\nremoved", hjust = -0.1, size = 3.5, color = "grey40") +
  scale_color_manual(
    values = c("Borough-wide" = "#2166AC", "Sub-area" = "#D6604D"),
    name = "Coverage"
  ) +
  labs(
    x = "Adoption Date",
    y = "",
    title = "Selective Licensing Adoption across English Local Authorities"
  ) +
  theme(axis.text.y = element_text(size = 8))

ggsave(file.path(FIG_DIR, "fig1_adoption_timeline.pdf"),
       adoption_fig, width = 8, height = 8)

# ============================================================================
# FIGURE 2: Event Study — Total Crime
# ============================================================================

message("Figure 2: Event study...")

if (nrow(es_coefs) > 0) {
  # Parse relative quarter from coefficient names
  es_plot_data <- es_coefs[grepl("rel_quarter", term)]
  es_plot_data[, rel_q := as.integer(str_extract(term, "-?\\d+"))]

  # Add zero for reference period
  es_plot_data <- rbind(
    es_plot_data,
    data.table(term = "ref", estimate = 0, std.error = 0,
               conf.low = 0, conf.high = 0, rel_q = -1),
    fill = TRUE
  )

  es_fig <- ggplot(es_plot_data, aes(x = rel_q, y = estimate)) +
    geom_hline(yintercept = 0, linewidth = 0.6, colour = "grey40") +
    geom_vline(xintercept = -0.5, linetype = "dotted", color = "firebrick", linewidth = 0.5) +
    geom_ribbon(aes(ymin = conf.low, ymax = conf.high),
                fill = "#2166AC", alpha = 0.15) +
    geom_line(color = "#2166AC", linewidth = 0.8) +
    geom_point(color = "#2166AC", size = 2.5) +
    labs(
      x = "Quarters Relative to Licensing Adoption",
      y = "Effect on Total Crime (LSOA-month)",
      title = "Event Study: Effect of Selective Licensing on Crime"
    ) +
    annotate("text", x = -6, y = max(es_plot_data$conf.high, na.rm = TRUE) * 0.8,
             label = "Pre-treatment", color = "grey40", size = 3.5, fontface = "italic") +
    annotate("text", x = 6, y = max(es_plot_data$conf.high, na.rm = TRUE) * 0.8,
             label = "Post-treatment", color = "grey40", size = 3.5, fontface = "italic")

  ggsave(file.path(FIG_DIR, "fig2_event_study.pdf"), es_fig, width = 8, height = 5)
}

# ============================================================================
# FIGURE 3: Crime Category Decomposition
# ============================================================================

message("Figure 3: Crime categories...")

if (nrow(cat_results) > 0) {
  cat_results[, sig := p_value < 0.05]
  cat_results[, category_clean := str_replace_all(category, "-", " ") |> str_to_title()]

  cat_fig <- ggplot(cat_results, aes(x = reorder(category_clean, estimate),
                                      y = estimate)) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
    geom_pointrange(aes(ymin = estimate - 1.96 * se,
                        ymax = estimate + 1.96 * se,
                        color = sig)) +
    coord_flip() +
    scale_color_manual(values = c("TRUE" = "#2166AC", "FALSE" = "grey60"),
                       guide = "none") +
    labs(
      x = "",
      y = "Effect of Selective Licensing (crimes per LSOA-month)",
      title = "Effect by Crime Category"
    )

  ggsave(file.path(FIG_DIR, "fig3_category_decomposition.pdf"),
         cat_fig, width = 8, height = 5)
}

# ============================================================================
# FIGURE 4: Treatment vs Control Crime Trends (Raw)
# ============================================================================

message("Figure 4: Raw trends...")

panel[, year_quarter := paste0(year, "Q", quarter)]
trends <- panel[year >= 2011 & year <= 2024, .(
  mean_crime = mean(total_crime, na.rm = TRUE),
  mean_rate = mean(crime_rate, na.rm = TRUE)
), by = .(year_quarter, ever_treated)]

trends[, date := as.Date(paste0(substr(year_quarter, 1, 4), "-",
                                 (as.integer(substr(year_quarter, 6, 6)) - 1) * 3 + 1,
                                 "-01"))]

trends_fig <- ggplot(trends, aes(x = date, y = mean_crime,
                                  color = factor(ever_treated))) +
  geom_line(linewidth = 0.8) +
  geom_point(size = 1.5) +
  scale_color_manual(
    values = c("0" = "#D6604D", "1" = "#2166AC"),
    labels = c("Never Licensed", "Eventually Licensed"),
    name = ""
  ) +
  labs(
    x = "",
    y = "Mean Crime per LSOA-month",
    title = "Crime Trends: Licensed vs Unlicensed Local Authorities"
  )

ggsave(file.path(FIG_DIR, "fig4_raw_trends.pdf"), trends_fig, width = 8, height = 5)

# ============================================================================
# FIGURE 5: CS-DiD Event Study (if available)
# ============================================================================

message("Figure 5: CS-DiD event study...")

cs_es <- tryCatch(readRDS(file.path(DATA_DIR, "cs_did_event_study.rds")), error = function(e) NULL)

if (!is.null(cs_es)) {
  cs_es_data <- data.table(
    rel_period = cs_es$egt,
    att = cs_es$att.egt,
    se = cs_es$se.egt
  )
  cs_es_data[, ci_low := att - 1.96 * se]
  cs_es_data[, ci_high := att + 1.96 * se]

  cs_fig <- ggplot(cs_es_data, aes(x = rel_period, y = att)) +
    geom_hline(yintercept = 0, linewidth = 0.6, colour = "grey40") +
    geom_vline(xintercept = -0.5, linetype = "dotted", color = "firebrick", linewidth = 0.5) +
    geom_ribbon(aes(ymin = ci_low, ymax = ci_high), fill = "#4393C3", alpha = 0.15) +
    geom_line(color = "#4393C3", linewidth = 0.8) +
    geom_point(color = "#4393C3", size = 2.5) +
    labs(
      x = "Periods Relative to Licensing Adoption",
      y = "ATT on Crime per LSOA",
      title = "Callaway \\& Sant'Anna Event Study"
    )

  ggsave(file.path(FIG_DIR, "fig5_cs_did_event_study.pdf"), cs_fig, width = 8, height = 5)
}

# ============================================================================
# FIGURE 6: Map of Licensed vs Unlicensed LAs
# ============================================================================

message("Figure 6: Map (skipping — requires boundary shapefiles)...")
# Note: To create a proper map, download LA boundary shapefiles from
# https://geoportal.statistics.gov.uk/datasets/local-authority-districts-december-2022-boundaries-uk-bgc
# Then use sf::st_read() and ggplot2::geom_sf()
# For now, skip the map and note it in the paper

message("All figures saved to: ", FIG_DIR)
message("Figures complete.")
