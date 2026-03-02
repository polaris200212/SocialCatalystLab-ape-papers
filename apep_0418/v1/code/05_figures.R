##############################################################################
# 05_figures.R — Publication-quality figures
# Paper: Does Place-Based Climate Policy Work? (apep_0418)
##############################################################################

source("code/00_packages.R")

cat("=== STEP 5: Generating figures ===\n\n")

rdd_sample <- readRDS(file.path(DATA_DIR, "rdd_sample.rds"))
area_full <- readRDS(file.path(DATA_DIR, "area_data_full.rds"))

###############################################################################
# Figure 1: Map of Energy Community Designation
###############################################################################
cat("--- Figure 1: Energy Community Map ---\n")

states <- tigris::states(cb = TRUE, year = 2021)
counties <- tigris::counties(cb = TRUE, year = 2021)

# Lower 48 only
exclude_states <- c("02", "15", "72", "78", "60", "66", "69")
states_48 <- states %>% filter(!STATEFP %in% exclude_states)
counties_48 <- counties %>%
  filter(!STATEFP %in% exclude_states) %>%
  mutate(fips = paste0(STATEFP, COUNTYFP))

# Merge energy community status
cbp_county <- readRDS(file.path(DATA_DIR, "cbp_county_2021.rds"))
county_ec <- cbp_county %>%
  mutate(
    ff_above = ff_share >= 0.17,
    ec_status = case_when(
      ff_share >= 0.17 ~ "FF Employment >= 0.17%",
      ff_share > 0 & ff_share < 0.17 ~ "FF Employment > 0 but < 0.17%",
      TRUE ~ "No Fossil Fuel Employment"
    )
  )

map_data <- counties_48 %>%
  left_join(county_ec %>% select(fips, ff_share, ec_status, ff_above), by = "fips")

p1 <- ggplot() +
  geom_sf(data = map_data, aes(fill = ec_status), color = NA, linewidth = 0) +
  geom_sf(data = states_48, fill = NA, color = "grey40", linewidth = 0.3) +
  scale_fill_manual(
    name = "Fossil Fuel\nEmployment Status",
    values = c(
      "FF Employment >= 0.17%" = "#D55E00",
      "FF Employment > 0 but < 0.17%" = "#56B4E9",
      "No Fossil Fuel Employment" = "grey90"
    ),
    na.value = "grey95"
  ) +
  labs(
    title = "Counties by Fossil Fuel Employment Relative to IRA Threshold",
    subtitle = "Energy community designation requires FF employment >= 0.17% AND unemployment >= national average",
    caption = "Source: Census County Business Patterns (2021), NAICS 211, 2121, 21311, 486."
  ) +
  theme_void() +
  theme(
    legend.position = "bottom",
    legend.key.size = unit(0.5, "cm"),
    plot.title = element_text(size = 13, face = "bold", hjust = 0.5),
    plot.subtitle = element_text(size = 9, color = "grey40", hjust = 0.5),
    plot.caption = element_text(size = 7, color = "grey50"),
    plot.margin = margin(5, 5, 5, 5)
  )

ggsave(file.path(FIG_DIR, "fig1_energy_community_map.pdf"), p1, width = 10, height = 7)
cat("  Saved fig1_energy_community_map.pdf\n")

###############################################################################
# Figure 2: Distribution of Running Variable with McCrary Test
###############################################################################
cat("--- Figure 2: Running Variable Distribution ---\n")

density_test <- readRDS(file.path(DATA_DIR, "mccrary_test.rds"))

p2 <- ggplot(rdd_sample, aes(x = ff_share)) +
  geom_histogram(
    aes(y = after_stat(density)),
    binwidth = 0.02,
    fill = "grey70",
    color = "white",
    alpha = 0.8
  ) +
  geom_vline(xintercept = 0.17, linetype = "dashed", color = "#D55E00", linewidth = 0.8) +
  annotate("text", x = 0.17, y = Inf, label = "Threshold: 0.17%",
           vjust = 2, hjust = -0.1, color = "#D55E00", size = 3.5, fontface = "italic") +
  annotate("text", x = max(rdd_sample$ff_share) * 0.7,
           y = Inf, vjust = 3,
           label = paste0("McCrary test\nt = ",
                         round(density_test$test$t_jk, 2),
                         "\np = ",
                         round(density_test$test$p_jk, 3)),
           size = 3, hjust = 0) +
  labs(
    title = "Distribution of Fossil Fuel Employment Share",
    subtitle = "RDD sample: MSAs/non-MSAs with unemployment >= national average",
    x = "Fossil Fuel Employment (% of Total Employment)",
    y = "Density",
    caption = "Note: Dashed line indicates the statutory 0.17% threshold. McCrary (2008) density test shows no evidence of manipulation."
  ) +
  theme_apep() +
  coord_cartesian(xlim = c(0, quantile(rdd_sample$ff_share, 0.99)))

ggsave(file.path(FIG_DIR, "fig2_running_variable_density.pdf"), p2, width = 8, height = 5)
cat("  Saved fig2_running_variable_density.pdf\n")

###############################################################################
# Figure 3: Main RDD Plot — Visual Discontinuity
###############################################################################
cat("--- Figure 3: Main RDD Plot ---\n")

rd_main <- readRDS(file.path(DATA_DIR, "rd_main_nocov.rds"))

# Create binned scatter using rdplot
rdplot_obj <- rdplot(
  y = rdd_sample$post_ira_mw_per_1000emp,
  x = rdd_sample$ff_share,
  c = 0.17,
  hide = TRUE
)

# Extract binned data
bins_below <- rdplot_obj$vars_bins[rdplot_obj$vars_bins$rdplot_mean_x < 0.17, ]
bins_above <- rdplot_obj$vars_bins[rdplot_obj$vars_bins$rdplot_mean_x >= 0.17, ]

# Manual ggplot for more control
p3 <- ggplot() +
  # Binned means
  geom_point(data = rdplot_obj$vars_bins,
             aes(x = rdplot_mean_x, y = rdplot_mean_y),
             color = "grey40", size = 2.5, alpha = 0.8) +
  # Local polynomial fits from rdplot
  geom_line(data = rdplot_obj$vars_poly[rdplot_obj$vars_poly$rdplot_x < 0.17, ],
            aes(x = rdplot_x, y = rdplot_y),
            color = apep_colors[1], linewidth = 1) +
  geom_line(data = rdplot_obj$vars_poly[rdplot_obj$vars_poly$rdplot_x >= 0.17, ],
            aes(x = rdplot_x, y = rdplot_y),
            color = apep_colors[2], linewidth = 1) +
  # Threshold
  geom_vline(xintercept = 0.17, linetype = "dashed", color = "grey30", linewidth = 0.7) +
  # Estimate annotation
  annotate("text",
           x = max(rdplot_obj$vars_bins$rdplot_mean_x) * 0.75,
           y = max(rdplot_obj$vars_bins$rdplot_mean_y, na.rm = TRUE) * 0.9,
           label = paste0("RD Estimate: ", round(rd_main$coef[3], 2),
                         "\n(SE: ", round(rd_main$se[3], 2), ")",
                         "\np = ", round(rd_main$pv[3], 3)),
           hjust = 0, size = 3.5, fontface = "italic") +
  labs(
    title = "Regression Discontinuity: Energy Community Bonus and Clean Energy Investment",
    subtitle = "Post-IRA clean energy capacity (MW per 1,000 employees) by fossil fuel employment share",
    x = "Fossil Fuel Employment (% of Total Employment)",
    y = "Post-IRA Clean Energy Capacity\n(MW per 1,000 Employees)",
    caption = "Note: Points show binned means. Lines show local polynomial fits. Calonico-Cattaneo-Titiunik optimal bandwidth with robust bias correction."
  ) +
  theme_apep()

ggsave(file.path(FIG_DIR, "fig3_main_rd_plot.pdf"), p3, width = 8, height = 5.5)
cat("  Saved fig3_main_rd_plot.pdf\n")

###############################################################################
# Figure 4: Covariate Balance
###############################################################################
cat("--- Figure 4: Covariate Balance ---\n")

balance_df <- readRDS(file.path(DATA_DIR, "covariate_balance.rds"))

balance_df <- balance_df %>%
  mutate(
    covariate = recode(covariate,
      "pop" = "Population",
      "med_income" = "Median Income",
      "pct_bachelors" = "% Bachelor's Degree",
      "pct_white" = "% White",
      "total_emp" = "Total Employment",
      "total_estab" = "N Establishments",
      "unemp_rate" = "Unemployment Rate"
    ),
    significant = p_value < 0.05,
    ci_lower = estimate - 1.96 * se,
    ci_upper = estimate + 1.96 * se,
    # Standardize estimates for comparison
    std_estimate = estimate / se
  )

p4 <- ggplot(balance_df, aes(x = reorder(covariate, std_estimate), y = std_estimate)) +
  geom_point(aes(color = significant), size = 3) +
  geom_errorbar(aes(ymin = std_estimate - 1.96, ymax = std_estimate + 1.96,
                     color = significant),
                width = 0.2) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
  scale_color_manual(values = c("FALSE" = apep_colors[1], "TRUE" = "#D55E00"),
                     labels = c("Not significant", "p < 0.05"),
                     name = "") +
  coord_flip() +
  labs(
    title = "Covariate Balance at the 0.17% Threshold",
    subtitle = "RD estimates for pre-determined covariates (standardized)",
    x = "",
    y = "Standardized RD Estimate (estimate / SE)",
    caption = "Note: Points show RD estimates divided by SE. Error bars show 95% CI. Covariates should be balanced (centered at zero) for valid RDD."
  ) +
  theme_apep() +
  theme(legend.position = "bottom")

ggsave(file.path(FIG_DIR, "fig4_covariate_balance.pdf"), p4, width = 8, height = 5)
cat("  Saved fig4_covariate_balance.pdf\n")

###############################################################################
# Figure 5: Bandwidth Sensitivity
###############################################################################
cat("--- Figure 5: Bandwidth Sensitivity ---\n")

bw_df <- readRDS(file.path(DATA_DIR, "bandwidth_sensitivity.rds"))

bw_df <- bw_df %>%
  mutate(
    ci_lower = estimate - 1.96 * se,
    ci_upper = estimate + 1.96 * se,
    is_optimal = multiplier == 1.0
  )

p5 <- ggplot(bw_df, aes(x = bandwidth, y = estimate)) +
  geom_ribbon(aes(ymin = ci_lower, ymax = ci_upper),
              fill = apep_colors[1], alpha = 0.2) +
  geom_line(color = apep_colors[1], linewidth = 0.8) +
  geom_point(aes(shape = is_optimal, size = is_optimal),
             color = apep_colors[1]) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
  scale_shape_manual(values = c("FALSE" = 16, "TRUE" = 18), guide = "none") +
  scale_size_manual(values = c("FALSE" = 2, "TRUE" = 4), guide = "none") +
  labs(
    title = "Bandwidth Sensitivity of RD Estimate",
    subtitle = "Diamond indicates CCT optimal bandwidth",
    x = "Bandwidth (Fossil Fuel Employment %)",
    y = "RD Estimate\n(Post-IRA Clean Energy MW per 1,000 Emp.)",
    caption = "Note: Shaded region shows 95% CI. Robust bias-corrected estimates from rdrobust."
  ) +
  theme_apep()

ggsave(file.path(FIG_DIR, "fig5_bandwidth_sensitivity.pdf"), p5, width = 8, height = 5)
cat("  Saved fig5_bandwidth_sensitivity.pdf\n")

###############################################################################
# Figure 6: Placebo Cutoffs
###############################################################################
cat("--- Figure 6: Placebo Cutoffs ---\n")

placebo_df <- readRDS(file.path(DATA_DIR, "placebo_cutoffs.rds"))

placebo_df <- placebo_df %>%
  mutate(
    ci_lower = estimate - 1.96 * se,
    ci_upper = estimate + 1.96 * se
  )

p6 <- ggplot(placebo_df, aes(x = cutoff, y = estimate)) +
  geom_ribbon(aes(ymin = ci_lower, ymax = ci_upper),
              fill = "grey80", alpha = 0.5) +
  geom_point(aes(color = is_true, size = is_true)) +
  geom_line(color = "grey50", linewidth = 0.5) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
  geom_vline(xintercept = 0.17, linetype = "dotted", color = "#D55E00", alpha = 0.5) +
  scale_color_manual(values = c("FALSE" = "grey50", "TRUE" = "#D55E00"),
                     labels = c("Placebo", "True (0.17%)"),
                     name = "") +
  scale_size_manual(values = c("FALSE" = 2, "TRUE" = 4), guide = "none") +
  labs(
    title = "Placebo Cutoff Tests",
    subtitle = "RD estimates at false thresholds should be zero",
    x = "Cutoff Value (Fossil Fuel Employment %)",
    y = "RD Estimate",
    caption = "Note: Orange point indicates the true statutory threshold (0.17%). Grey points show placebo estimates at false cutoffs."
  ) +
  theme_apep() +
  theme(legend.position = "bottom")

ggsave(file.path(FIG_DIR, "fig6_placebo_cutoffs.pdf"), p6, width = 8, height = 5)
cat("  Saved fig6_placebo_cutoffs.pdf\n")

###############################################################################
# Figure 7: Donut RDD Sensitivity
###############################################################################
cat("--- Figure 7: Donut RDD ---\n")

donut_df <- readRDS(file.path(DATA_DIR, "donut_rdd.rds"))

donut_df <- donut_df %>%
  mutate(
    ci_lower = estimate - 1.96 * se,
    ci_upper = estimate + 1.96 * se
  )

# Add the baseline (no donut) result
rd_main <- readRDS(file.path(DATA_DIR, "rd_main_nocov.rds"))
donut_plot <- bind_rows(
  data.frame(donut_width = 0, estimate = rd_main$coef[3],
             se = rd_main$se[3], p_value = rd_main$pv[3],
             n_obs = rd_main$N_h[1] + rd_main$N_h[2]),
  donut_df
) %>%
  mutate(
    ci_lower = estimate - 1.96 * se,
    ci_upper = estimate + 1.96 * se
  )

p7 <- ggplot(donut_plot, aes(x = donut_width, y = estimate)) +
  geom_ribbon(aes(ymin = ci_lower, ymax = ci_upper),
              fill = apep_colors[3], alpha = 0.2) +
  geom_point(color = apep_colors[3], size = 3) +
  geom_line(color = apep_colors[3], linewidth = 0.8) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
  labs(
    title = "Donut RDD: Excluding Observations Near Threshold",
    subtitle = "Estimates remain stable as observations closest to cutoff are removed",
    x = "Donut Width (Observations Excluded Within +/- X% of Threshold)",
    y = "RD Estimate",
    caption = "Note: Point at 0 shows the baseline estimate. Robust bias-corrected inference."
  ) +
  theme_apep()

ggsave(file.path(FIG_DIR, "fig7_donut_rdd.pdf"), p7, width = 8, height = 5)
cat("  Saved fig7_donut_rdd.pdf\n")

cat("\n=== All figures generated ===\n")
cat("Figures saved to:", FIG_DIR, "\n")
