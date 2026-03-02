# =============================================================================
# 05_figures.R - Publication-Quality Figures
# v2: Restructured - 5 main text figures, rest in appendix
# =============================================================================

get_this_script_dir <- function() {
  for (i in seq_len(sys.nframe())) {
    if (!is.null(sys.frame(i)$ofile)) return(dirname(sys.frame(i)$ofile))
  }
  return(getwd())
}
script_dir <- get_this_script_dir()
source(file.path(script_dir, "00_packages.R"))

# Load data
voting_data <- readRDS(file.path(data_dir, "voting_data.rds"))
canton_treatment <- readRDS(file.path(data_dir, "canton_treatment.rds"))
analysis_df <- readRDS(file.path(data_dir, "analysis_data.rds"))

has_spatial <- file.exists(file.path(data_dir, "voting_sf.rds"))
if (has_spatial) voting_sf <- readRDS(file.path(data_dir, "voting_sf.rds"))

has_rdd <- file.exists(file.path(data_dir, "rdd_sample.rds"))
if (has_rdd) rdd_sample <- readRDS(file.path(data_dir, "rdd_sample.rds"))

# =============================================================================
# FIGURE 1: Combined Map (treatment + language)
# =============================================================================
message("Creating Figure 1: Map...")

if (has_spatial) {
  map_data <- voting_sf %>%
    filter(!is.na(yes_share)) %>%
    mutate(treated_label = ifelse(treated, "Treated (MuKEn in force)", "Control"))

  # Panel A: Treatment + language overlay
  fig1a <- ggplot(map_data) +
    geom_sf(aes(fill = treated_label), color = "white", linewidth = 0.05) +
    scale_fill_manual(
      values = c("Treated (MuKEn in force)" = "#2166AC", "Control" = "#FCBBA1"),
      name = ""
    ) +
    labs(title = "A. Cantonal Energy Law Status",
         subtitle = "Five treated cantons (GR, BE, AG, BL, BS) - all German-speaking") +
    theme_apep() +
    theme(axis.text = element_blank(), axis.ticks = element_blank(), panel.grid = element_blank())

  ggsave(file.path(fig_dir, "fig1a_treatment_map.pdf"), fig1a, width = 7, height = 5, device = cairo_pdf)

  # Panel B: Language
  fig1c <- ggplot(map_data) +
    geom_sf(aes(fill = lang), color = "white", linewidth = 0.05) +
    scale_fill_manual(
      values = c("German" = "#4DAF4A", "French" = "#984EA3", "Italian" = "#FF7F00"),
      name = "Language Region"
    ) +
    labs(title = "B. Language Regions (Röstigraben)",
         subtitle = "All treated cantons are German-speaking") +
    theme_apep() +
    theme(axis.text = element_blank(), axis.ticks = element_blank(), panel.grid = element_blank())

  ggsave(file.path(fig_dir, "fig1c_language_map.pdf"), fig1c, width = 7, height = 5, device = cairo_pdf)

  # Vote shares
  fig1b <- ggplot(map_data) +
    geom_sf(aes(fill = yes_share), color = "white", linewidth = 0.05) +
    scale_fill_gradient2(low = "#B2182B", mid = "#F7F7F7", high = "#2166AC",
                         midpoint = 58.2, name = "Yes share (%)", limits = c(15, 90)) +
    labs(title = "C. Energy Strategy 2050 Vote Shares",
         subtitle = "May 21, 2017 (national avg: 58.2%)") +
    theme_apep() +
    theme(axis.text = element_blank(), axis.ticks = element_blank(), panel.grid = element_blank())

  ggsave(file.path(fig_dir, "fig1b_voteshare_map.pdf"), fig1b, width = 7, height = 5, device = cairo_pdf)

  # Timing map
  treatment_timing <- map_data %>%
    mutate(
      in_force_year = case_when(
        canton_abbr == "GR" ~ "2011", canton_abbr == "BE" ~ "2012",
        canton_abbr == "AG" ~ "2013", canton_abbr == "BL" ~ "2016",
        canton_abbr == "BS" ~ "2017", TRUE ~ "Control"
      ),
      in_force_year = factor(in_force_year, levels = c("2011", "2012", "2013", "2016", "2017", "Control"))
    )

  fig1d <- ggplot(treatment_timing) +
    geom_sf(aes(fill = in_force_year), color = "white", linewidth = 0.05) +
    scale_fill_manual(
      values = c("2011"="#08519C", "2012"="#3182BD", "2013"="#6BAED6",
                 "2016"="#9ECAE1", "2017"="#BDD7E7", "Control"="#FCBBA1"),
      name = "In-Force Year"
    ) +
    labs(title = "D. Staggered Treatment Timing") +
    theme_apep() +
    theme(axis.text = element_blank(), axis.ticks = element_blank(), panel.grid = element_blank())

  ggsave(file.path(fig_dir, "fig1d_timing_map.pdf"), fig1d, width = 7, height = 5, device = cairo_pdf)

  # Border map
  treated_canton_ids <- c(2, 12, 13, 18, 19)
  canton_borders <- voting_sf %>%
    filter(!is.na(yes_share)) %>%
    group_by(canton_id) %>%
    summarise(.groups = "drop")

  border_line <- tryCatch({
    get_policy_border(canton_borders, treated_canton_ids, canton_id_col = "canton_id")
  }, error = function(e) NULL)

  if (!is.null(border_line)) {
    centroids <- map_data %>% mutate(centroid = st_centroid(st_geometry(.)))
    map_data_b <- centroids %>%
      mutate(
        dist_km = as.numeric(st_distance(centroid, border_line)) / 1000,
        near_border = dist_km <= 5,
        border_label = case_when(
          near_border & treated ~ "Treated (near border)",
          near_border & !treated ~ "Control (near border)",
          !near_border & treated ~ "Treated (interior)",
          TRUE ~ "Control (interior)"
        )
      )

    fig1e <- ggplot(map_data_b) +
      geom_sf(aes(fill = border_label), color = "white", linewidth = 0.05) +
      scale_fill_manual(
        values = c("Treated (near border)"="#08519C", "Control (near border)"="#A50F15",
                   "Treated (interior)"="#9ECAE1", "Control (interior)"="#FCBBA1"),
        name = ""
      ) +
      labs(title = "E. RDD Sample: Border Municipalities",
           subtitle = "Dark colors = within 5km of treated-control border") +
      theme_apep() +
      theme(axis.text = element_blank(), axis.ticks = element_blank(), panel.grid = element_blank())

    ggsave(file.path(fig_dir, "fig1e_border_map.pdf"), fig1e, width = 7, height = 5, device = cairo_pdf)
  }
  message("   Maps saved")
}

# =============================================================================
# FIGURE 2: Same-Language RDD Plot (PRIMARY identification)
# =============================================================================
message("Creating Figure 2: Same-language RDD plot...")

if (has_rdd) {
  same_lang_rdd <- rdd_sample %>% filter(nearest_same_language == TRUE)

  # Run RDD for annotation
  rd_sl <- tryCatch({
    rdrobust(y = same_lang_rdd$yes_share, x = same_lang_rdd$signed_distance_km, c = 0)
  }, error = function(e) NULL)

  if (!is.null(rd_sl) && nrow(same_lang_rdd) > 50) {
    binned_sl <- same_lang_rdd %>%
      mutate(bin = cut(signed_distance_km, breaks = seq(-20, 20, by = 2))) %>%
      group_by(bin) %>%
      summarise(mean_yes = mean(yes_share, na.rm = TRUE),
                se_yes = sd(yes_share, na.rm = TRUE) / sqrt(n()),
                n = n(), mid = mean(signed_distance_km, na.rm = TRUE),
                treated_side = mean(treated, na.rm = TRUE) > 0.5, .groups = "drop") %>%
      filter(n >= 3)

    fig2 <- ggplot(binned_sl, aes(x = mid, y = mean_yes, color = treated_side)) +
      geom_vline(xintercept = 0, linetype = "dashed", color = "gray30") +
      geom_point(size = 2.5, alpha = 0.8) +
      geom_errorbar(aes(ymin = mean_yes - 1.96*se_yes, ymax = mean_yes + 1.96*se_yes),
                    width = 0.3, alpha = 0.5) +
      geom_smooth(data = same_lang_rdd %>% filter(signed_distance_km < 0),
                  aes(x = signed_distance_km, y = yes_share), method = "loess",
                  se = TRUE, color = "#B2182B", fill = "#B2182B", alpha = 0.2) +
      geom_smooth(data = same_lang_rdd %>% filter(signed_distance_km > 0),
                  aes(x = signed_distance_km, y = yes_share), method = "loess",
                  se = TRUE, color = "#2166AC", fill = "#2166AC", alpha = 0.2) +
      scale_color_manual(values = c("TRUE" = "#2166AC", "FALSE" = "#B2182B"),
                         labels = c("TRUE" = "Treated", "FALSE" = "Control"), name = "") +
      labs(x = "Distance to Nearest Same-Language Border (km)",
           y = "Yes Share (%)",
           title = "Same-Language Border RDD: German-German Canton Borders",
           subtitle = paste0("RD estimate: ", round(rd_sl$coef[1], 2),
                             " pp (SE = ", round(rd_sl$se[1], 2),
                             ", p = ", round(rd_sl$pv[1], 3), ")"),
           caption = "Dots = 2km bin means; lines = local polynomial fits; same-language borders only") +
      theme_apep()

    ggsave(file.path(fig_dir, "fig2_same_lang_rdd.pdf"), fig2, width = 10, height = 6)
    message("   Saved fig2_same_lang_rdd.pdf")
  }

  # Also create pooled RDD plot
  rd_pooled <- tryCatch({
    rdrobust(y = rdd_sample$yes_share, x = rdd_sample$pooled_distance, c = 0)
  }, error = function(e) NULL)

  if (!is.null(rd_pooled)) {
    binned_pooled <- rdd_sample %>%
      filter(abs(pooled_distance) <= 20) %>%
      mutate(bin = cut(pooled_distance, breaks = seq(-20, 20, by = 2))) %>%
      group_by(bin) %>%
      summarise(mean_yes = mean(yes_share, na.rm = TRUE),
                se_yes = sd(yes_share, na.rm = TRUE) / sqrt(n()),
                n = n(), mid = mean(pooled_distance, na.rm = TRUE),
                treated_side = mean(treated, na.rm = TRUE) > 0.5, .groups = "drop") %>%
      filter(n >= 3)

    fig_pooled <- ggplot(binned_pooled, aes(x = mid, y = mean_yes, color = treated_side)) +
      geom_vline(xintercept = 0, linetype = "dashed", color = "gray30") +
      geom_point(size = 2.5, alpha = 0.8) +
      geom_errorbar(aes(ymin = mean_yes - 1.96*se_yes, ymax = mean_yes + 1.96*se_yes),
                    width = 0.3, alpha = 0.5) +
      geom_smooth(data = rdd_sample %>% filter(pooled_distance < 0, abs(pooled_distance) <= 20),
                  aes(x = pooled_distance, y = yes_share), method = "loess",
                  se = TRUE, color = "#B2182B", fill = "#B2182B", alpha = 0.2) +
      geom_smooth(data = rdd_sample %>% filter(pooled_distance > 0, abs(pooled_distance) <= 20),
                  aes(x = pooled_distance, y = yes_share), method = "loess",
                  se = TRUE, color = "#2166AC", fill = "#2166AC", alpha = 0.2) +
      scale_color_manual(values = c("TRUE" = "#2166AC", "FALSE" = "#B2182B"),
                         labels = c("TRUE" = "Treated", "FALSE" = "Control"), name = "") +
      labs(x = "Distance to Canton Border (km)", y = "Yes Share (%)",
           title = "Pooled Spatial RDD: All Canton Borders",
           subtitle = paste0("RD estimate: ", round(rd_pooled$coef[1], 2),
                             " pp (SE = ", round(rd_pooled$se[1], 2), ")")) +
      theme_apep()

    ggsave(file.path(fig_dir, "fig3_spatial_rdd.pdf"), fig_pooled, width = 10, height = 6)
  }
}

# =============================================================================
# FIGURE 3: Specification Curve (RDD specs)
# =============================================================================
message("Creating Figure 3: Specification curve...")

rdd_results_file <- file.path(tab_dir, "rdd_specifications.csv")
if (file.exists(rdd_results_file)) {
  rdd_specs <- read_csv(rdd_results_file, show_col_types = FALSE) %>%
    filter(!is.na(estimate))

  if (nrow(rdd_specs) > 0) {
    fig3 <- ggplot(rdd_specs, aes(x = estimate, y = fct_rev(specification))) +
      geom_vline(xintercept = 0, linetype = "dashed", color = "gray50") +
      geom_errorbarh(aes(xmin = ci_lower, xmax = ci_upper), height = 0.2, color = "#2166AC") +
      geom_point(size = 3, color = "#2166AC") +
      labs(title = "Spatial RDD Estimates Across Specifications",
           subtitle = "95% robust bias-corrected CI; null effect at dashed line",
           x = "Treatment Effect (pp)", y = "") +
      theme_apep()

    ggsave(file.path(fig_dir, "fig_rdd_specifications.pdf"), fig3, width = 10, height = 6)
    message("   Saved fig_rdd_specifications.pdf")
  }
}

# =============================================================================
# FIGURE 4: Event Study
# =============================================================================
message("Creating Figure 4: Event study...")

event_study_file <- file.path(tab_dir, "event_study_summary.csv")
if (file.exists(event_study_file)) {
  event_study <- read_csv(event_study_file, show_col_types = FALSE)

  fig4 <- ggplot(event_study, aes(x = year, y = mean_yes, color = group, shape = group)) +
    geom_vline(xintercept = 2011, linetype = "dashed", color = "gray50") +
    geom_line(linewidth = 1) +
    geom_point(size = 3) +
    geom_errorbar(aes(ymin = mean_yes - 1.96*se, ymax = mean_yes + 1.96*se), width = 0.3) +
    annotate("text", x = 2011, y = max(event_study$mean_yes) + 2,
             label = "First treatment\n(GR 2011)", hjust = -0.05, size = 3) +
    scale_color_manual(values = c("Treated Cantons" = "#2166AC", "Control Cantons" = "#B2182B")) +
    labs(title = "Event Study: Energy Referendum Support Over Time",
         subtitle = "Canton-level yes-shares across energy referendums (2000-2017)",
         x = "Year", y = "Yes Share (%)", color = "", shape = "") +
    theme_apep()

  ggsave(file.path(fig_dir, "fig_event_study.pdf"), fig4, width = 10, height = 6)
  message("   Saved fig_event_study.pdf")
}

# CS event study
cs_event_file <- file.path(data_dir, "cs_event_data.rds")
if (file.exists(cs_event_file)) {
  cs_event_df <- readRDS(cs_event_file)

  fig_cs <- ggplot(cs_event_df, aes(x = event_time, y = att)) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
    geom_vline(xintercept = -0.5, linetype = "dotted", color = "gray30") +
    geom_ribbon(aes(ymin = ci_lower, ymax = ci_upper), alpha = 0.2, fill = "#2166AC") +
    geom_line(color = "#2166AC", linewidth = 1) +
    geom_point(color = "#2166AC", size = 3) +
    labs(title = "Callaway-Sant'Anna Event Study (Corrected)",
         subtitle = "BS excluded; in-force years used for treatment timing",
         x = "Years Since Treatment", y = "ATT (pp)") +
    theme_apep()

  ggsave(file.path(fig_dir, "fig_cs_event_study.pdf"), fig_cs, width = 10, height = 6)
  message("   Saved fig_cs_event_study.pdf")
}

# =============================================================================
# FIGURE 5: Heterogeneity / Forest Plot
# =============================================================================
message("Creating Figure 5: Forest plot...")

bp_file <- file.path(tab_dir, "border_pair_estimates.csv")
if (file.exists(bp_file)) {
  bp_results <- read_csv(bp_file, show_col_types = FALSE) %>%
    filter(!is.na(estimate))

  if (nrow(bp_results) > 1) {
    bp_results <- bp_results %>%
      mutate(
        color = case_when(
          border_pair == "POOLED (all borders)" ~ "Pooled",
          same_language == TRUE ~ "Same-language",
          TRUE ~ "Cross-language"
        )
      )

    fig5 <- ggplot(bp_results, aes(x = estimate, y = fct_rev(border_pair), color = color)) +
      geom_vline(xintercept = 0, linetype = "dashed", color = "gray50") +
      geom_errorbarh(aes(xmin = ci_lower, xmax = ci_upper), height = 0.2) +
      geom_point(size = 3) +
      scale_color_manual(
        values = c("Pooled" = "#D73027", "Same-language" = "#2166AC", "Cross-language" = "#FD8D3C"),
        name = "Border Type"
      ) +
      labs(title = "Border-Pair Specific RDD Estimates",
           subtitle = "Forest plot by canton border segment",
           x = "Treatment Effect (pp)", y = "") +
      theme_apep()

    ggsave(file.path(fig_dir, "fig_border_pairs_forest.pdf"), fig5, width = 10, height = 7)
    message("   Saved fig_border_pairs_forest.pdf")
  }
}

# =============================================================================
# APPENDIX FIGURES
# =============================================================================
message("\nCreating appendix figures...")

# Bandwidth sensitivity
bw_file <- file.path(tab_dir, "bandwidth_sensitivity.csv")
if (file.exists(bw_file)) {
  bw_data <- read_csv(bw_file, show_col_types = FALSE)
  p_bw <- ggplot(bw_data, aes(x = bandwidth, y = estimate)) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
    geom_ribbon(aes(ymin = ci_lower, ymax = ci_upper), alpha = 0.2, fill = "#2166AC") +
    geom_line(color = "#2166AC", linewidth = 1) +
    labs(title = "Bandwidth Sensitivity Analysis", x = "Bandwidth (km)", y = "Treatment Effect (pp)") +
    theme_apep()
  ggsave(file.path(fig_dir, "fig4_bandwidth_sensitivity.pdf"), p_bw, width = 10, height = 6)
}

# Donut RDD
donut_file <- file.path(tab_dir, "donut_rdd.csv")
if (file.exists(donut_file)) {
  donut_data <- read_csv(donut_file, show_col_types = FALSE)
  p_donut <- ggplot(donut_data, aes(x = donut_km, y = estimate)) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
    geom_ribbon(aes(ymin = ci_lower, ymax = ci_upper), alpha = 0.2, fill = "#2166AC") +
    geom_line(color = "#2166AC", linewidth = 1) +
    geom_point(color = "#2166AC", size = 3) +
    labs(title = "Donut RDD Specifications", x = "Donut Radius (km excluded)", y = "Treatment Effect (pp)") +
    theme_apep()
  ggsave(file.path(fig_dir, "fig_donut_rdd.pdf"), p_donut, width = 8, height = 5)
}

# McCrary density test
if (has_rdd) {
  density_test <- tryCatch({
    rddensity(rdd_sample$pooled_distance, c = 0)
  }, error = function(e) NULL)
  if (!is.null(density_test)) {
    p_density <- tryCatch({
      rdplotdensity(density_test, rdd_sample$pooled_distance)$Estplot +
        labs(title = "McCrary Density Test", x = "Distance to Border (km)", y = "Density") +
        theme_apep()
    }, error = function(e) NULL)
    if (!is.null(p_density)) {
      ggsave(file.path(fig_dir, "fig_density_test.pdf"), p_density, width = 8, height = 5)
    }
  }
}

# Randomization inference
ri_file <- file.path(data_dir, "ri_distributions.rds")
if (file.exists(ri_file)) {
  ri_data <- readRDS(ri_file)

  p_ri_strat <- ggplot(tibble(estimate = ri_data$stratified), aes(x = estimate)) +
    geom_histogram(bins = 50, fill = "gray70", color = "white") +
    geom_vline(xintercept = ri_data$original, color = "#D73027", linewidth = 1.5) +
    geom_vline(xintercept = -ri_data$original, color = "#D73027", linewidth = 1.5, linetype = "dashed") +
    annotate("text", x = ri_data$original + 0.5, y = Inf,
             label = paste("Observed =", round(ri_data$original, 2)),
             vjust = 2, hjust = 0, color = "#D73027", fontface = "bold") +
    labs(title = "Stratified Randomization Inference (German cantons only)",
         subtitle = paste0("p = ", round(mean(abs(ri_data$stratified) >= abs(ri_data$original)), 3)),
         x = "Permuted Treatment Effect (pp)", y = "Count") +
    theme_apep()

  ggsave(file.path(fig_dir, "fig_randomization_inference.pdf"), p_ri_strat, width = 10, height = 6)
}

# Covariate balance
cov_file <- file.path(tab_dir, "covariate_balance.csv")
if (file.exists(cov_file)) {
  cov_data <- read_csv(cov_file, show_col_types = FALSE)
  p_balance <- ggplot(cov_data, aes(x = estimate, y = covariate)) +
    geom_vline(xintercept = 0, linetype = "dashed") +
    geom_errorbarh(aes(xmin = estimate - 1.96*se, xmax = estimate + 1.96*se), height = 0.2) +
    geom_point(size = 3, color = "#2166AC") +
    labs(title = "Covariate Balance at the Border", x = "Discontinuity Estimate", y = "") +
    theme_apep()
  ggsave(file.path(fig_dir, "fig_covariate_balance.pdf"), p_balance, width = 8, height = 5)
}

# OLS coefficient plot
ols_file <- file.path(tab_dir, "table_ols_results.csv")
if (file.exists(ols_file)) {
  ols_data <- read_csv(ols_file, show_col_types = FALSE)
  p_ols <- ggplot(ols_data, aes(x = estimate, y = fct_rev(specification))) +
    geom_vline(xintercept = 0, linetype = "dashed", color = "gray50") +
    geom_errorbarh(aes(xmin = ci_lower, xmax = ci_upper), height = 0.2, color = "#2166AC") +
    geom_point(size = 3, color = "#2166AC") +
    labs(title = "OLS Estimates Across Specifications", x = "Treatment Effect (pp)", y = "") +
    theme_apep()
  ggsave(file.path(fig_dir, "fig_ols_coefficients.pdf"), p_ols, width = 10, height = 5)
}

# Distribution figures
gemeinde_data <- voting_data %>%
  rename(canton = canton_abbr, language = lang, voters = eligible_voters) %>%
  mutate(treated = as.numeric(treated))

p_dist <- ggplot(gemeinde_data, aes(x = yes_share, fill = factor(treated))) +
  geom_histogram(alpha = 0.6, position = "identity", bins = 40, color = "white") +
  geom_vline(xintercept = 58.2, linetype = "dashed", color = "gray30") +
  scale_fill_manual(values = c("1" = "#2166AC", "0" = "#B2182B"),
                    labels = c("1" = "Treated", "0" = "Control"), name = "") +
  labs(x = "Yes Share (%)", y = "Number of Gemeinden",
       title = "Distribution of Vote Shares by Treatment Status") +
  theme_apep()
ggsave(file.path(fig_dir, "fig_distribution_treatment.pdf"), p_dist, width = 8, height = 5)

p_lang <- ggplot(gemeinde_data, aes(x = yes_share, fill = language)) +
  geom_histogram(alpha = 0.6, position = "identity", bins = 40, color = "white") +
  geom_vline(xintercept = 58.2, linetype = "dashed", color = "gray30") +
  scale_fill_manual(values = c("German"="#E6AB02", "French"="#7570B3", "Italian"="#1B9E77"), name = "Language") +
  labs(x = "Yes Share (%)", y = "Number of Gemeinden",
       title = "Distribution of Vote Shares by Language Region") +
  theme_apep()
ggsave(file.path(fig_dir, "fig_distribution_language.pdf"), p_lang, width = 8, height = 5)

# Language comparison bar chart
lang_summary <- gemeinde_data %>%
  group_by(language, treated) %>%
  summarize(mean_yes = mean(yes_share, na.rm = TRUE),
            se_yes = sd(yes_share, na.rm = TRUE) / sqrt(n()), n = n(), .groups = "drop") %>%
  mutate(treated_label = ifelse(treated == 1, "Treated", "Control"))

p_lang_bar <- ggplot(lang_summary, aes(x = language, y = mean_yes, fill = treated_label)) +
  geom_bar(stat = "identity", position = position_dodge(0.8), width = 0.7) +
  geom_errorbar(aes(ymin = mean_yes - 1.96*se_yes, ymax = mean_yes + 1.96*se_yes),
                position = position_dodge(0.8), width = 0.2) +
  geom_hline(yintercept = 58.2, linetype = "dashed", color = "gray30") +
  scale_fill_manual(values = c("Treated" = "#2166AC", "Control" = "#B2182B"), name = "") +
  labs(x = "Language Region", y = "Mean Yes Share (%)",
       title = "Vote Shares by Language Region and Treatment Status") +
  theme_apep()
ggsave(file.path(fig_dir, "fig_language_comparison.pdf"), p_lang_bar, width = 8, height = 5)

message("\n=== FIGURES COMPLETE ===")
