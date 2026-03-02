## ============================================================
## 05_figures.R — All figures for the paper
## Paper: TLV Expansion and Housing Markets (apep_0455)
## ============================================================

source("00_packages.R")

data_dir <- "../data"
fig_dir <- "../figures"
dir.create(fig_dir, showWarnings = FALSE, recursive = TRUE)

cat("=== Loading results ===\n")
cy <- readRDS(file.path(data_dir, "panel_commune_year.rds"))
panel <- readRDS(file.path(data_dir, "panel_transactions.rds"))
es_results <- readRDS(file.path(data_dir, "event_study_results.rds"))

if (file.exists(file.path(data_dir, "ri_results.rds"))) {
  ri <- readRDS(file.path(data_dir, "ri_results.rds"))
} else {
  ri <- NULL
}

## -------------------------------------------------------
## Figure 1: Parallel Trends (Raw Means)
## -------------------------------------------------------

cat("  Figure 1: Parallel trends...\n")

trends <- cy %>%
  group_by(year, treated) %>%
  summarise(
    mean_price = mean(mean_price_sqm, na.rm = TRUE),
    se_price = sd(mean_price_sqm, na.rm = TRUE) / sqrt(n()),
    mean_volume = mean(n_transactions, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(group = ifelse(treated == 1, "TLV Expansion (Treated)",
                         "Never Treated (Control)"))

p1 <- ggplot(trends, aes(x = year, y = mean_price, color = group,
                            shape = group)) +
  geom_point(size = 3) +
  geom_line(linewidth = 0.8) +
  geom_ribbon(aes(ymin = mean_price - 1.96 * se_price,
                   ymax = mean_price + 1.96 * se_price, fill = group),
              alpha = 0.15, color = NA) +
  geom_vline(xintercept = 2023.5, linetype = "dashed", color = "grey40") +
  annotate("text", x = 2023.7, y = max(trends$mean_price) * 0.95,
           label = "TLV\nExpansion", hjust = 0, size = 3, color = "grey40") +
  scale_color_manual(values = apep_colors[1:2]) +
  scale_fill_manual(values = apep_colors[1:2]) +
  scale_x_continuous(breaks = sort(unique(trends$year))) +
  labs(x = "Year", y = "Mean Price per m² (EUR)",
       title = "Housing Prices: Treated vs. Control Communes",
       subtitle = "Communes entering TLV in 2024 vs. never-designated communes",
       color = NULL, shape = NULL, fill = NULL) +
  theme_apep()

ggsave(file.path(fig_dir, "fig1_parallel_trends.pdf"),
       p1, width = 8, height = 5)

## -------------------------------------------------------
## Figure 2: Event Study Plot
## -------------------------------------------------------

cat("  Figure 2: Event study...\n")

## Extract coefficients from fixest event study
es_coefs <- as.data.frame(coeftable(es_results$price_cy))
es_coefs$year <- as.integer(gsub("year::(\\d+):treated", "\\1",
                                   rownames(es_coefs)))
es_coefs <- es_coefs %>%
  rename(estimate = Estimate, se = `Std. Error`) %>%
  mutate(
    ci_lower = estimate - 1.96 * se,
    ci_upper = estimate + 1.96 * se,
    rel_year = year - 2024
  )

## Add reference year
ref_row <- data.frame(
  estimate = 0, se = 0, ci_lower = 0, ci_upper = 0,
  year = 2022, rel_year = -2
)
es_coefs <- bind_rows(es_coefs, ref_row) %>% arrange(year)

p2 <- ggplot(es_coefs, aes(x = year, y = estimate)) +
  geom_hline(yintercept = 0, color = "grey50", linetype = "solid") +
  geom_vline(xintercept = 2023.5, linetype = "dashed", color = "grey40") +
  geom_ribbon(aes(ymin = ci_lower, ymax = ci_upper),
              fill = apep_colors[1], alpha = 0.2) +
  geom_point(color = apep_colors[1], size = 3) +
  geom_line(color = apep_colors[1], linewidth = 0.8) +
  annotate("text", x = 2023.7, y = max(es_coefs$ci_upper, na.rm = TRUE) * 0.9,
           label = "TLV\nExpansion", hjust = 0, size = 3, color = "grey40") +
  scale_x_continuous(breaks = sort(unique(es_coefs$year))) +
  labs(x = "Year", y = "Coefficient (log price/m²)",
       title = "Event Study: Effect of TLV Expansion on Housing Prices",
       subtitle = "Reference year: 2022. Commune and year fixed effects. SEs clustered by département.") +
  theme_apep()

ggsave(file.path(fig_dir, "fig2_event_study.pdf"),
       p2, width = 8, height = 5)

## -------------------------------------------------------
## Figure 3: Transaction Volume Event Study
## -------------------------------------------------------

cat("  Figure 3: Volume event study...\n")

vol_coefs <- as.data.frame(coeftable(es_results$volume_cy))
vol_coefs$year <- as.integer(gsub("year::(\\d+):treated", "\\1",
                                    rownames(vol_coefs)))
vol_coefs <- vol_coefs %>%
  rename(estimate = Estimate, se = `Std. Error`) %>%
  mutate(
    ci_lower = estimate - 1.96 * se,
    ci_upper = estimate + 1.96 * se
  )

vol_ref <- data.frame(estimate = 0, se = 0, ci_lower = 0, ci_upper = 0,
                        year = 2022)
vol_coefs <- bind_rows(vol_coefs, vol_ref) %>% arrange(year)

p3 <- ggplot(vol_coefs, aes(x = year, y = estimate)) +
  geom_hline(yintercept = 0, color = "grey50") +
  geom_vline(xintercept = 2023.5, linetype = "dashed", color = "grey40") +
  geom_ribbon(aes(ymin = ci_lower, ymax = ci_upper),
              fill = apep_colors[3], alpha = 0.2) +
  geom_point(color = apep_colors[3], size = 3) +
  geom_line(color = apep_colors[3], linewidth = 0.8) +
  scale_x_continuous(breaks = sort(unique(vol_coefs$year))) +
  labs(x = "Year", y = "Coefficient (log transactions)",
       title = "Event Study: Effect of TLV Expansion on Transaction Volume",
       subtitle = "Reference year: 2022") +
  theme_apep()

ggsave(file.path(fig_dir, "fig3_volume_event_study.pdf"),
       p3, width = 8, height = 5)

## -------------------------------------------------------
## Figure 4: Randomization Inference Distribution
## -------------------------------------------------------

if (!is.null(ri)) {
  cat("  Figure 4: RI distribution...\n")

  ri_df <- data.frame(coef = ri$permuted)

  p4 <- ggplot(ri_df, aes(x = coef)) +
    geom_histogram(bins = 50, fill = "grey80", color = "grey50") +
    geom_vline(xintercept = ri$observed, color = apep_colors[2],
               linewidth = 1, linetype = "solid") +
    annotate("text",
             x = ri$observed, y = Inf, vjust = 2,
             label = sprintf("Observed = %.4f\nRI p = %.3f",
                              ri$observed, ri$p_value),
             color = apep_colors[2], hjust = -0.1, size = 3.5) +
    labs(x = "Placebo Coefficient", y = "Frequency",
         title = "Randomization Inference: Distribution of Placebo Coefficients",
         subtitle = "500 random permutations of treatment assignment") +
    theme_apep()

  ggsave(file.path(fig_dir, "fig4_randomization_inference.pdf"),
         p4, width = 8, height = 5)
}

## -------------------------------------------------------
## Figure 5: Treatment Map (if sf available)
## -------------------------------------------------------

cat("  Figure 5: Treatment map...\n")

## Try to create a simple départment-level treatment intensity map
treat_dep <- cy %>%
  filter(year == 2024) %>%
  group_by(dep) %>%
  summarise(
    n_treated = sum(treated == 1),
    n_control = sum(treated == 0),
    share_treated = n_treated / (n_treated + n_control),
    .groups = "drop"
  )

## Simple bar chart of treatment intensity by département (top 20)
top_deps <- treat_dep %>%
  arrange(desc(n_treated)) %>%
  head(20)

if (nrow(top_deps) > 0) {
  p5 <- ggplot(top_deps, aes(x = reorder(dep, n_treated), y = n_treated)) +
    geom_col(fill = apep_colors[1], alpha = 0.8) +
    coord_flip() +
    labs(x = "Département", y = "Number of Treated Communes",
         title = "TLV Expansion: Geographic Distribution of Treated Communes",
         subtitle = "Top 20 départements by number of newly designated communes") +
    theme_apep()

  ggsave(file.path(fig_dir, "fig5_treatment_geography.pdf"),
         p5, width = 8, height = 6)
}

## -------------------------------------------------------
## Figure 6: Heterogeneity by Zone Type
## -------------------------------------------------------

cat("  Figure 6: Heterogeneity...\n")

het_data <- cy %>%
  filter(treated == 1) %>%
  group_by(year, zone_2023) %>%
  summarise(
    mean_price = mean(mean_price_sqm, na.rm = TRUE),
    se = sd(mean_price_sqm, na.rm = TRUE) / sqrt(n()),
    .groups = "drop"
  ) %>%
  mutate(zone_label = ifelse(zone_2023 == "touristique_tendue",
                              "Tourism + Tendue", "Tendue Only"))

if (nrow(het_data) > 0) {
  p6 <- ggplot(het_data, aes(x = year, y = mean_price,
                               color = zone_label, shape = zone_label)) +
    geom_point(size = 3) +
    geom_line(linewidth = 0.8) +
    geom_vline(xintercept = 2023.5, linetype = "dashed", color = "grey40") +
    scale_color_manual(values = apep_colors[c(1, 4)]) +
    scale_x_continuous(breaks = sort(unique(het_data$year))) +
    labs(x = "Year", y = "Mean Price per m² (EUR)",
         title = "Price Trends by Zone Type: Tourism vs. Non-Tourism Expansion",
         color = NULL, shape = NULL) +
    theme_apep()

  ggsave(file.path(fig_dir, "fig6_heterogeneity_zone.pdf"),
         p6, width = 8, height = 5)
}

cat("\nAll figures saved to ../figures/\n")
cat(sprintf("  Files: %s\n",
            paste(list.files(fig_dir, pattern = "\\.pdf$"), collapse = ", ")))
