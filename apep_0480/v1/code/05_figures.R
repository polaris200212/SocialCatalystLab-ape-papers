##############################################################################
# 05_figures.R — All figures for paper
# apep_0480: FOBT Stake Cut and Local Effects
##############################################################################

source("00_packages.R")

data_dir <- "../data"
fig_dir  <- "../figures"
dir.create(fig_dir, showWarnings = FALSE, recursive = TRUE)

panel <- fread(file.path(data_dir, "analysis_panel.csv"))
results <- readRDS(file.path(data_dir, "main_results.rds"))

# ============================================================================
# FIGURE 1: Betting Shop Density Distribution
# ============================================================================
cat("Creating Figure 1: Betting shop density distribution...\n")

density_data <- panel[!duplicated(csp_name), .(csp_name, betting_density, high_density)]

fig1 <- ggplot(density_data, aes(x = betting_density)) +
  geom_histogram(aes(fill = factor(high_density)),
                 binwidth = 0.5, color = "white", linewidth = 0.2) +
  geom_vline(xintercept = median(density_data$betting_density[density_data$betting_density > 0]),
             linetype = "dashed", color = "red", linewidth = 0.8) +
  scale_fill_manual(values = c("0" = "#2166ac", "1" = "#b2182b"),
                    labels = c("Below Median", "Above Median"),
                    name = "Exposure Group") +
  labs(x = "Betting Shops per 10,000 Population (Pre-Policy)",
       y = "Number of CSPs",
       title = "Distribution of Pre-Policy Betting Shop Density",
       subtitle = "Dashed line = median density among areas with at least one shop") +
  theme(legend.position = c(0.75, 0.85),
        legend.background = element_rect(fill = "white", color = NA))

ggsave(file.path(fig_dir, "fig1_density_distribution.pdf"),
       fig1, width = 7, height = 5)
ggsave(file.path(fig_dir, "fig1_density_distribution.png"),
       fig1, width = 7, height = 5, dpi = 300)

# ============================================================================
# FIGURE 2: Time Series — Crime Trends by Treatment Group
# ============================================================================
cat("Creating Figure 2: Crime trends by treatment group...\n")

trends <- panel[, .(mean_crime = mean(total_offences_rate, na.rm = TRUE),
                    se_crime = sd(total_offences_rate, na.rm = TRUE) / sqrt(.N)),
                by = .(yq, high_density)]
trends[, group := factor(high_density, levels = c(1, 0),
                         labels = c("High Density", "Low Density"))]

fig2 <- ggplot(trends, aes(x = yq, y = mean_crime, color = group)) +
  geom_line(linewidth = 0.8) +
  geom_ribbon(aes(ymin = mean_crime - 1.96 * se_crime,
                  ymax = mean_crime + 1.96 * se_crime,
                  fill = group), alpha = 0.15, color = NA) +
  geom_vline(xintercept = 2019.25, linetype = "dashed", color = "grey40") +
  annotate("text", x = 2019.25, y = max(trends$mean_crime, na.rm = TRUE) * 0.95,
           label = "FOBT Stake Cut\n(April 2019)", hjust = -0.05, size = 3) +
  scale_color_manual(values = c("High Density" = "#b2182b", "Low Density" = "#2166ac")) +
  scale_fill_manual(values = c("High Density" = "#b2182b", "Low Density" = "#2166ac")) +
  labs(x = "Year-Quarter", y = "Total Crime Rate (per 10,000)",
       title = "Crime Trends: High vs. Low Betting Shop Density Areas",
       color = "", fill = "") +
  theme(legend.position = c(0.15, 0.85),
        legend.background = element_rect(fill = "white", color = NA))

ggsave(file.path(fig_dir, "fig2_crime_trends.pdf"), fig2, width = 8, height = 5.5)
ggsave(file.path(fig_dir, "fig2_crime_trends.png"), fig2, width = 8, height = 5.5, dpi = 300)

# ============================================================================
# FIGURE 3: Event Study
# ============================================================================
cat("Creating Figure 3: Event study...\n")

es_model <- results$es_model
es_coefs <- as.data.table(coeftable(es_model), keep.rownames = TRUE)
setnames(es_coefs, c("term", "estimate", "se", "tstat", "pvalue"))

# Parse event time from coefficient names
es_coefs[, event_time := as.integer(gsub(".*::(-?\\d+):.*", "\\1", term))]
es_coefs <- es_coefs[!is.na(event_time)]

# Add the reference period (event_time = -1, coefficient = 0)
ref_row <- data.table(term = "ref", estimate = 0, se = 0, tstat = 0,
                      pvalue = 1, event_time = -1)
es_coefs <- rbind(es_coefs, ref_row)
es_coefs <- es_coefs[order(event_time)]

# Confidence intervals
es_coefs[, ci_lo := estimate - 1.96 * se]
es_coefs[, ci_hi := estimate + 1.96 * se]

fig3 <- ggplot(es_coefs, aes(x = event_time, y = estimate)) +
  geom_hline(yintercept = 0, linetype = "solid", color = "grey60") +
  geom_vline(xintercept = -0.5, linetype = "dashed", color = "grey40") +
  geom_ribbon(aes(ymin = ci_lo, ymax = ci_hi), fill = "#2166ac", alpha = 0.2) +
  geom_point(size = 1.5, color = "#2166ac") +
  geom_line(color = "#2166ac", linewidth = 0.5) +
  annotate("text", x = -0.5, y = max(es_coefs$ci_hi, na.rm = TRUE) * 0.9,
           label = "Policy\nImplementation", hjust = 1.1, size = 3, color = "grey30") +
  labs(x = "Quarters Relative to FOBT Stake Cut (April 2019)",
       y = "Coefficient: Betting Density × Period",
       title = "Event Study: Effect of Betting Shop Density on Crime Rate") +
  scale_x_continuous(breaks = seq(-16, 20, by = 4))

ggsave(file.path(fig_dir, "fig3_event_study.pdf"), fig3, width = 8, height = 5.5)
ggsave(file.path(fig_dir, "fig3_event_study.png"), fig3, width = 8, height = 5.5, dpi = 300)

# ============================================================================
# FIGURE 4: Crime Decomposition by Type
# ============================================================================
cat("Creating Figure 4: Crime decomposition...\n")

# Crime type trends by treatment group
crime_types <- c("violence_against_the_person_rate", "theft_offences_rate",
                 "criminal_damage_and_arson_rate", "robbery_rate",
                 "drug_offences_rate", "public_order_offences_rate")

# Filter to columns that exist
crime_types <- crime_types[crime_types %in% names(panel)]

if (length(crime_types) > 0) {
  type_trends <- panel[, lapply(.SD, mean, na.rm = TRUE),
                       .SDcols = crime_types,
                       by = .(yq, high_density)]

  type_long <- melt(type_trends, id.vars = c("yq", "high_density"),
                    variable.name = "crime_type", value.name = "rate")
  type_long[, group := factor(high_density, levels = c(1, 0),
                              labels = c("High Density", "Low Density"))]
  type_long[, crime_label := gsub("_rate$", "", crime_type)]
  type_long[, crime_label := gsub("_", " ", crime_label)]
  type_long[, crime_label := tools::toTitleCase(crime_label)]

  fig4 <- ggplot(type_long, aes(x = yq, y = rate, color = group)) +
    geom_line(linewidth = 0.6) +
    geom_vline(xintercept = 2019.25, linetype = "dashed", color = "grey40", linewidth = 0.3) +
    facet_wrap(~ crime_label, scales = "free_y", ncol = 2) +
    scale_color_manual(values = c("High Density" = "#b2182b", "Low Density" = "#2166ac")) +
    labs(x = "Year-Quarter", y = "Crime Rate (per 10,000)",
         title = "Crime Trends by Type: High vs. Low Betting Density Areas",
         color = "") +
    theme(legend.position = "bottom",
          strip.text = element_text(face = "bold", size = 9))

  ggsave(file.path(fig_dir, "fig4_crime_decomposition.pdf"),
         fig4, width = 9, height = 8)
  ggsave(file.path(fig_dir, "fig4_crime_decomposition.png"),
         fig4, width = 9, height = 8, dpi = 300)
}

# ============================================================================
# FIGURE 5: Dose-Response
# ============================================================================
cat("Creating Figure 5: Dose-response...\n")

rob_results <- tryCatch(readRDS(file.path(data_dir, "robustness_results.rds")),
                        error = function(e) NULL)

if (!is.null(rob_results) && !is.null(rob_results$r_dose_response)) {
  dr_coefs <- as.data.table(coeftable(rob_results$r_dose_response), keep.rownames = TRUE)
  setnames(dr_coefs, c("term", "estimate", "se", "tstat", "pvalue"))
  dr_coefs[, quintile := as.integer(gsub(".*::(\\d+):.*", "\\1", term))]
  dr_coefs <- dr_coefs[!is.na(quintile)]

  # Add reference quintile
  ref <- data.table(term = "ref", estimate = 0, se = 0, tstat = 0,
                    pvalue = 1, quintile = 1)
  dr_coefs <- rbind(ref, dr_coefs)

  dr_coefs[, ci_lo := estimate - 1.96 * se]
  dr_coefs[, ci_hi := estimate + 1.96 * se]

  fig5 <- ggplot(dr_coefs, aes(x = factor(quintile), y = estimate)) +
    geom_hline(yintercept = 0, linetype = "solid", color = "grey60") +
    geom_errorbar(aes(ymin = ci_lo, ymax = ci_hi), width = 0.2, color = "#2166ac") +
    geom_point(size = 3, color = "#2166ac") +
    labs(x = "Quintile of Pre-Policy Betting Density\n(1 = Lowest, 5 = Highest)",
         y = "Effect on Total Crime Rate (per 10,000)",
         title = "Dose-Response: Crime Effects by Betting Density Quintile",
         subtitle = "Quintile 1 (lowest density) is the reference group") +
    theme(panel.grid.major.x = element_blank())

  ggsave(file.path(fig_dir, "fig5_dose_response.pdf"), fig5, width = 7, height = 5)
  ggsave(file.path(fig_dir, "fig5_dose_response.png"), fig5, width = 7, height = 5, dpi = 300)
}

# ============================================================================
# FIGURE 6: Property Price Trends (if available)
# ============================================================================
cat("Creating Figure 6: Property price trends...\n")

if ("log_mean_price" %in% names(panel)) {
  # Use annual data (not quarterly duplicates of annual values)
  price_annual <- panel[!is.na(log_mean_price),
                        .(mean_log_price = mean(log_mean_price, na.rm = TRUE)),
                        by = .(merge_year, high_density)]
  price_annual[, group := factor(high_density, levels = c(1, 0),
                                 labels = c("High Density", "Low Density"))]

  if (nrow(price_annual) > 5) {
    fig6 <- ggplot(price_annual, aes(x = merge_year, y = mean_log_price, color = group)) +
      geom_line(linewidth = 0.8) +
      geom_point(size = 2) +
      geom_vline(xintercept = 2019, linetype = "dashed", color = "grey40") +
      scale_color_manual(values = c("High Density" = "#b2182b", "Low Density" = "#2166ac")) +
      labs(x = "Year", y = "Log Mean Property Price",
           title = "Property Price Trends: High vs. Low Betting Density Areas",
           color = "") +
      theme(legend.position = c(0.15, 0.85),
            legend.background = element_rect(fill = "white", color = NA))

    ggsave(file.path(fig_dir, "fig6_property_prices.pdf"), fig6, width = 8, height = 5.5)
    ggsave(file.path(fig_dir, "fig6_property_prices.png"), fig6, width = 8, height = 5.5, dpi = 300)
  }
}

# ============================================================================
# FIGURE 7: Map of Betting Density (Placeholder — text-based summary)
# ============================================================================
cat("Figure 7: Map would require spatial data (shapefile). Skipping.\n")

cat("\n=== All figures saved to", fig_dir, "===\n")
cat("Files created:\n")
for (f in list.files(fig_dir)) {
  cat("  ", f, "\n")
}
