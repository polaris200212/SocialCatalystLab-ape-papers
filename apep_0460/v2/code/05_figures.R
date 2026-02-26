## ============================================================================
## 05_figures.R — All Figure Generation
## APEP-0460: Across the Channel
## ============================================================================
source("00_packages.R")

cat("=== Loading results ===\n")
results <- readRDS(file.path(data_dir, "main_results.rds"))
robust <- readRDS(file.path(data_dir, "robustness_results.rds"))
dept_exposure <- readRDS(file.path(data_dir, "dept_exposure.rds"))

## ========================================================================
## FIGURE 1: DISTRIBUTION / MAP OF UK SCI CONNECTIVITY
## ========================================================================
cat("=== Figure 1: SCI Distribution ===\n")

# Try to load shapefile for map
shp_dir <- file.path(data_dir, "shapefiles")
shp_files <- list.files(shp_dir, pattern = "\\.geojson$|\\.shp$",
                        full.names = TRUE, recursive = TRUE)

# Also check for raw GeoJSON named as zip
geojson_candidates <- list.files(shp_dir, pattern = "departements",
                                 full.names = TRUE)

map_made <- FALSE
if (length(geojson_candidates) > 0) {
  for (candidate in geojson_candidates) {
    tryCatch({
      fr_shape <- st_read(candidate, quiet = TRUE)
      if (nrow(fr_shape) > 0) {
        cat("  Loaded shapefile:", nrow(fr_shape), "features\n")
        cat("  Shapefile columns:", paste(names(fr_shape), collapse = ", "), "\n")

        # Determine how to join — try different column names
        # dept_exposure has either fr_region (GADM1) or code_departement (GADM2)
        join_col <- NULL
        if ("code_departement" %in% names(dept_exposure)) {
          # Département-level: try joining on code
          for (col in c("code", "code_dept", "CODE_DEPT", "CODE")) {
            if (col %in% names(fr_shape)) {
              join_col <- col
              join_var <- "code_departement"
              break
            }
          }
        }

        if (is.null(join_col)) {
          # Try joining on name or fr_region
          for (col in names(fr_shape)) {
            if (grepl("code|nom|name|dept|region", col, ignore.case = TRUE)) {
              cat("  Available join col:", col, "\n")
            }
          }
        }

        if (!is.null(join_col)) {
          fr_shape_data <- fr_shape %>%
            left_join(dept_exposure %>% as_tibble(),
                      by = setNames(join_var, join_col))

          if (any(!is.na(fr_shape_data$sci_total_uk))) {
            p1 <- ggplot(fr_shape_data) +
              geom_sf(aes(fill = log(sci_total_uk + 1)), color = "white", linewidth = 0.2) +
              scale_fill_viridis_c(
                name = "Log SCI\n(UK connections)",
                option = "plasma",
                na.value = "grey90"
              ) +
              labs(
                title = "Social Connectedness to the United Kingdom",
                subtitle = "Facebook SCI by French region (log scale)",
                caption = "Source: Facebook Social Connectedness Index."
              ) +
              theme_void() +
              theme(
                legend.position = "bottom",
                legend.key.width = unit(2, "cm"),
                plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
                plot.subtitle = element_text(size = 10, hjust = 0.5)
              )

            ggsave(file.path(fig_dir, "fig1_sci_map.pdf"), p1, width = 8, height = 8)
            cat("  Saved fig1_sci_map.pdf\n")
            map_made <- TRUE
          }
        }
        break
      }
    }, error = function(e) {
      cat("  Could not load shapefile:", conditionMessage(e), "\n")
    })
  }
}

if (!map_made) {
  # Fallback: bar chart of SCI exposure by region
  exp_plot_data <- dept_exposure[order(-sci_total_uk)]

  # Use dept_name or region_name depending on what's available
  label_col <- intersect(names(exp_plot_data), c("dept_name", "region_name"))
  if (length(label_col) > 0) {
    exp_plot_data[, label := exp_plot_data[[label_col[1]]]]
  } else {
    exp_plot_data[, label := fr_region]
  }

  p1 <- ggplot(exp_plot_data, aes(x = reorder(label, sci_total_uk), y = sci_total_uk)) +
    geom_col(fill = apep_colors[1], alpha = 0.85) +
    coord_flip() +
    labs(
      title = "Social Connectedness to the United Kingdom",
      subtitle = "Total Facebook SCI by French region",
      x = "",
      y = "Total SCI (Facebook friendship links to UK)",
      caption = "Source: Facebook Social Connectedness Index."
    ) +
    theme_apep() +
    theme(panel.grid.major.y = element_blank())

  ggsave(file.path(fig_dir, "fig1_sci_distribution.pdf"), p1, width = 9, height = 6)
  cat("  Saved fig1_sci_distribution.pdf\n")
}

## ========================================================================
## FIGURE 2: EVENT STUDY — QUARTER-BY-QUARTER EFFECTS
## ========================================================================
cat("=== Figure 2: Event Study ===\n")

if (!is.null(results$event_study)) {
  es <- results$event_study
  event_label <- if (!is.null(results$event_label)) results$event_label else "Brexit"

  es_data <- tryCatch({
    # Use fixest's iplot data extraction
    es_coefs <- coef(es)
    es_ses <- se(es)
    coef_names <- names(es_coefs)

    # Parse period numbers from coefficient names
    # fixest i() naming: ref_period::{value}:log_sci_uk
    periods <- as.numeric(gsub(".*::(-?[0-9]+):.*", "\\1", coef_names))

    data.frame(
      period = periods,
      estimate = as.numeric(es_coefs),
      se = as.numeric(es_ses),
      ci_lo = as.numeric(es_coefs) - 1.96 * as.numeric(es_ses),
      ci_hi = as.numeric(es_coefs) + 1.96 * as.numeric(es_ses)
    ) %>%
      filter(!is.na(period)) %>%
      arrange(period)
  }, error = function(e) {
    cat("  Could not extract event study data:", conditionMessage(e), "\n")
    NULL
  })

  if (!is.null(es_data) && nrow(es_data) > 0) {
    # Add reference period (effect = 0)
    es_data <- rbind(
      es_data,
      data.frame(period = 0, estimate = 0, se = 0, ci_lo = 0, ci_hi = 0)
    ) %>% arrange(period)

    p2 <- ggplot(es_data, aes(x = period, y = estimate)) +
      geom_ribbon(aes(ymin = ci_lo, ymax = ci_hi),
                  alpha = 0.15, fill = apep_colors[1]) +
      geom_point(color = apep_colors[1], size = 2) +
      geom_line(color = apep_colors[1], linewidth = 0.6) +
      geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
      geom_vline(xintercept = 0.5, linetype = "dotted", color = "grey60",
                 linewidth = 0.8) +
      labs(
        title = "Event Study: Housing Prices and UK Social Connectedness",
        subtitle = paste0("Interaction of log SCI(UK) with quarter indicators (95% CI)\nEvent: ",
                          event_label),
        x = "Quarters Relative to Event",
        y = "Coefficient on Log(SCI to UK)",
        caption = "Note: Reference period = 0. Unit and time fixed effects included.\nClustered standard errors by region."
      ) +
      theme_apep() +
      scale_x_continuous(breaks = seq(-20, 30, 4))

    ggsave(file.path(fig_dir, "fig2_event_study.pdf"), p2, width = 9, height = 5.5)
    cat("  Saved fig2_event_study.pdf\n")
  }
}

## ========================================================================
## FIGURE 3: PERMUTATION INFERENCE
## ========================================================================
cat("=== Figure 3: Permutation Inference ===\n")

if (!is.null(robust$permutation)) {
  perm_data <- data.frame(coef = robust$permutation$perm_coefs)
  actual <- robust$permutation$actual

  p3 <- ggplot(perm_data, aes(x = coef)) +
    geom_histogram(bins = 50, fill = "grey70", color = "white", alpha = 0.8) +
    geom_vline(xintercept = actual, color = apep_colors[2], linewidth = 1.2) +
    geom_vline(xintercept = -actual, color = apep_colors[2], linewidth = 0.6,
               linetype = "dashed") +
    annotate("text", x = actual, y = Inf,
             label = paste0("Actual: ", round(actual, 4)),
             vjust = 2, hjust = -0.1, color = apep_colors[2],
             fontface = "bold", size = 3.5) +
    annotate("text", x = max(perm_data$coef) * 0.7, y = Inf,
             label = paste0("p = ", round(robust$permutation$p_value, 3)),
             vjust = 4, hjust = 0, size = 4, fontface = "bold") +
    labs(
      title = "Permutation Inference: Randomized SCI Weights",
      subtitle = paste0(length(robust$permutation$perm_coefs),
                        " permutations of SCI exposure across French regions"),
      x = "Coefficient Estimate",
      y = "Frequency",
      caption = "Note: Solid line = actual estimate. Dashed = mirror image.\nP-value = share of permuted |coefficients| exceeding |actual|."
    ) +
    theme_apep()

  ggsave(file.path(fig_dir, "fig3_permutation.pdf"), p3, width = 8, height = 5)
  cat("  Saved fig3_permutation.pdf\n")
}

## ========================================================================
## FIGURE 4: LEAVE-ONE-UK-REGION-OUT
## ========================================================================
cat("=== Figure 4: Leave-One-Out ===\n")

if (!is.null(robust$looro) && nrow(robust$looro) > 0) {
  looro <- robust$looro

  # Determine label column
  label_col <- intersect(names(looro), c("uk_label", "uk_region"))
  if (length(label_col) > 0) {
    looro$label <- looro[[label_col[1]]]
  } else {
    looro$label <- paste("Region", 1:nrow(looro))
  }

  p4 <- ggplot(looro, aes(x = reorder(label, coefficient), y = coefficient)) +
    geom_point(color = apep_colors[1], size = 3) +
    geom_errorbar(aes(ymin = coefficient - 1.96 * se,
                      ymax = coefficient + 1.96 * se),
                  width = 0.15, color = apep_colors[1]) +
    geom_hline(yintercept = coef(results$m1)[1], color = apep_colors[2],
               linewidth = 0.8, linetype = "dashed") +
    annotate("text", x = 0.5, y = coef(results$m1)[1],
             label = paste0("Baseline: ", round(coef(results$m1)[1], 4)),
             vjust = -1, hjust = 0, color = apep_colors[2], size = 3.5) +
    coord_flip() +
    labs(
      title = "Leave-One-UK-Region-Out Sensitivity",
      subtitle = "Each bar excludes one UK country from SCI exposure",
      x = "UK Country Excluded",
      y = "Coefficient Estimate (95% CI)",
      caption = "Note: Dashed line shows baseline estimate using all UK regions."
    ) +
    theme_apep()

  ggsave(file.path(fig_dir, "fig4_leave_one_out.pdf"), p4, width = 8, height = 5)
  cat("  Saved fig4_leave_one_out.pdf\n")
}

## ========================================================================
## FIGURE 5: UK COUNTRY DECOMPOSITION / DISTANCE BANDS
## ========================================================================
cat("=== Figure 5: Distance Bands ===\n")

if (!is.null(robust$distance) && nrow(robust$distance) > 0) {
  dist_df <- robust$distance %>%
    mutate(
      ci_lo = coef - 1.96 * se,
      ci_hi = coef + 1.96 * se,
      band = factor(band, levels = band)
    )

  p5 <- ggplot(dist_df, aes(x = band, y = coef)) +
    geom_point(size = 3, color = apep_colors[1]) +
    geom_errorbar(aes(ymin = ci_lo, ymax = ci_hi),
                  width = 0.2, color = apep_colors[1], linewidth = 0.6) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
    labs(
      title = "SCI Exposure by UK Country Composition",
      subtitle = "Progressively restricting which UK countries enter the exposure measure",
      x = "",
      y = "Coefficient on SCI Exposure",
      caption = "Note: Error bars show 95% CI. Numbers show UK regions included."
    ) +
    theme_apep() +
    theme(axis.text.x = element_text(angle = 20, hjust = 1))

  ggsave(file.path(fig_dir, "fig5_distance_bands.pdf"), p5, width = 8, height = 5)
  cat("  Saved fig5_distance_bands.pdf\n")
}

## ========================================================================
## FIGURE 6: POPULATION VS PROBABILITY WEIGHTING
## ========================================================================
cat("=== Figure 6: Weighting Comparison ===\n")

if (!is.null(robust$weighting)) {
  pop <- robust$weighting$pop_weighted
  prob <- robust$weighting$prob_weighted

  weight_df <- data.frame(
    measure = c("Population-Weighted\n(Total SCI)", "Probability-Weighted\n(Mean SCI)"),
    coef = c(coef(pop)[1], coef(prob)[1]),
    se = c(se(pop)[1], se(prob)[1])
  ) %>%
    mutate(ci_lo = coef - 1.96 * se,
           ci_hi = coef + 1.96 * se)

  p6 <- ggplot(weight_df, aes(x = measure, y = coef)) +
    geom_point(size = 4, color = apep_colors[1]) +
    geom_errorbar(aes(ymin = ci_lo, ymax = ci_hi),
                  width = 0.15, color = apep_colors[1], linewidth = 0.8) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
    labs(
      title = "Population-Weighted vs. Probability-Weighted SCI",
      subtitle = "Following Bailey et al. (2018) methodology",
      x = "",
      y = "Coefficient on SCI Exposure \u00d7 Post",
      caption = "Note: Population-weighted = total SCI (absolute connections).\nProbability-weighted = mean SCI (connection share)."
    ) +
    theme_apep()

  ggsave(file.path(fig_dir, "fig6_weighting.pdf"), p6, width = 7, height = 5)
  cat("  Saved fig6_weighting.pdf\n")
}

## ========================================================================
## FIGURE 7: PLACEBO — UK VS GERMANY VS SWITZERLAND
## ========================================================================
cat("=== Figure 7: Placebo Comparison ===\n")

placebo_df <- data.frame(
  country = c("UK\n(Treatment)", "Germany\n(Placebo)"),
  coef = c(coef(results$m1)[1], coef(results$m3)[1]),
  se = c(se(results$m1)[1], se(results$m3)[1])
)

if (!is.null(robust$swiss_placebo)) {
  placebo_df <- rbind(placebo_df, data.frame(
    country = "Switzerland\n(Positive Placebo)",
    coef = coef(robust$swiss_placebo)[1],
    se = se(robust$swiss_placebo)[1]
  ))
}

placebo_df <- placebo_df %>%
  mutate(
    ci_lo = coef - 1.96 * se,
    ci_hi = coef + 1.96 * se,
    country = factor(country, levels = country)
  )

p7 <- ggplot(placebo_df, aes(x = country, y = coef)) +
  geom_point(aes(color = country), size = 4, show.legend = FALSE) +
  geom_errorbar(aes(ymin = ci_lo, ymax = ci_hi, color = country),
                width = 0.15, linewidth = 0.8, show.legend = FALSE) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
  scale_color_manual(values = apep_colors[1:nrow(placebo_df)]) +
  labs(
    title = "Cross-Border Spillovers: Treatment vs. Placebo Countries",
    subtitle = "SCI-weighted exposure \u00d7 Post for each country",
    x = "",
    y = "Coefficient on SCI Exposure \u00d7 Post",
    caption = "Note: UK = Brexit shock (treatment). Germany = no comparable shock (null expected).\nSwitzerland = CHF shock Jan 2015. 95% CI shown."
  ) +
  theme_apep()

ggsave(file.path(fig_dir, "fig7_placebo.pdf"), p7, width = 8, height = 5)
cat("  Saved fig7_placebo.pdf\n")

## ========================================================================
## FIGURE 8: SCATTER — SCI TO UK VS HOUSING PRICE CHANGE
## ========================================================================
cat("=== Figure 8: Binscatter ===\n")

panel <- as.data.table(readRDS(file.path(data_dir, "analysis_panel.rds")))

# Compute pre-post price change
pre_prices <- panel[!is.na(log_price_m2) & (year < 2016 | (year == 2016 & quarter <= 2)),
                    .(pre_price = mean(log_price_m2, na.rm = TRUE)),
                    by = fr_region]

post_prices <- panel[!is.na(log_price_m2) & year >= 2017,
                     .(post_price = mean(log_price_m2, na.rm = TRUE)),
                     by = fr_region]

price_change <- merge(pre_prices, post_prices, by = "fr_region")
price_change[, delta_price := post_price - pre_price]

# Merge with exposure (dept_exposure uses code_departement, panel uses fr_region)
if ("code_departement" %in% names(dept_exposure) && !"fr_region" %in% names(dept_exposure)) {
  dept_exposure[, fr_region := code_departement]
}
scatter_data <- merge(dept_exposure, price_change, by = "fr_region", all.x = TRUE)
scatter_data <- scatter_data[!is.na(delta_price)]

if (nrow(scatter_data) > 5) {
  # Determine label column
  label_col <- intersect(names(scatter_data), c("dept_name", "region_name"))
  if (length(label_col) > 0) {
    scatter_data[, label := scatter_data[[label_col[1]]]]
  } else {
    scatter_data[, label := fr_region]
  }

  p8 <- ggplot(scatter_data, aes(x = log(sci_total_uk + 1), y = delta_price)) +
    geom_point(color = apep_colors[1], size = 3, alpha = 0.7) +
    geom_smooth(method = "lm", color = apep_colors[2], se = TRUE,
                alpha = 0.2, linewidth = 1) +
    geom_text(aes(label = label), size = 2.5, vjust = -0.8, alpha = 0.7) +
    labs(
      title = "UK Social Connectedness and Housing Price Changes",
      subtitle = "Pre-Brexit (2014\u20132016Q2) to Post-Brexit (2017\u20132023)",
      x = "Log(Total SCI to UK)",
      y = "\u0394 Log(Price per m\u00b2)",
      caption = "Note: Each point is a French region. Line shows OLS fit with 95% CI."
    ) +
    theme_apep()

  ggsave(file.path(fig_dir, "fig8_binscatter.pdf"), p8, width = 8, height = 6)
  cat("  Saved fig8_binscatter.pdf\n")
} else {
  cat("  Not enough data for binscatter (need pre-2016 DVF data).\n")
}

cat("\n=== All figures generated ===\n")
cat("Files in figures directory:\n")
cat(paste(list.files(fig_dir), collapse = "\n"), "\n")
