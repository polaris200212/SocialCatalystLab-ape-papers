## ============================================================================
## 05_figures.R — All figures for the paper
## Paper: Tight Labor Markets and the Crisis in Home Care
## ============================================================================

source("00_packages.R")

panel <- readRDS(file.path(DATA, "analysis_panel.rds"))
smpl <- panel[in_sample == TRUE]
results <- readRDS(file.path(DATA, "main_results.rds"))
robustness <- readRDS(file.path(DATA, "robustness_results.rds"))

## ---- Figure 1: National trends in employment and HCBS supply ----
cat("Figure 1: National trends...\n")

national <- smpl[, .(
  avg_providers = mean(hcbs_providers, na.rm = TRUE),
  avg_emp_pop = mean(emp_pop, na.rm = TRUE),
  total_hcbs_paid = sum(hcbs_paid, na.rm = TRUE) / 1e9,
  n_counties = .N
), by = .(year, quarter)]

national[, date := as.Date(sprintf("%d-%02d-01", year, (quarter - 1) * 3 + 1))]

# Normalize to 2019Q4 = 100
base_vals <- national[year == 2019 & quarter == 4]
national[, providers_idx := 100 * avg_providers / base_vals$avg_providers]
national[, emp_idx := 100 * avg_emp_pop / base_vals$avg_emp_pop]

fig1_data <- melt(national[, .(date, `HCBS Providers` = providers_idx,
                                 `Employment/Population` = emp_idx)],
                  id.vars = "date", variable.name = "series", value.name = "index")

p1 <- ggplot(fig1_data, aes(x = date, y = index, color = series, linetype = series)) +
  geom_line(linewidth = 1.2) +
  geom_vline(xintercept = as.Date("2020-03-01"), linetype = "dashed", color = "grey50") +
  annotate("text", x = as.Date("2020-06-01"), y = 105, label = "COVID-19",
           color = "grey50", size = 3, hjust = 0) +
  geom_hline(yintercept = 100, linetype = "dotted", color = "grey70") +
  scale_color_manual(values = apep_colors[1:2]) +
  scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
  labs(
    title = "Employment Recovery Outpaced HCBS Provider Supply",
    subtitle = "Index: 2019Q4 = 100. County-average across the U.S.",
    x = NULL, y = "Index (2019Q4 = 100)",
    color = NULL, linetype = NULL
  ) +
  theme_apep()

ggsave(file.path(FIGURES, "fig1_national_trends.pdf"), p1, width = 8, height = 5)

## ---- Figure 2: Cross-county variation in labor market tightness ----
cat("Figure 2: Within-state variation...\n")

# Show within-state variation using 2022Q4 snapshot
snap <- smpl[year == 2022 & quarter == 4 & !is.na(emp_pop)]

# Compute state means and deviations
snap[, state_mean_emp := mean(emp_pop, na.rm = TRUE), by = state_fips]
snap[, emp_deviation := emp_pop - state_mean_emp]

p2 <- ggplot(snap, aes(x = emp_deviation)) +
  geom_histogram(bins = 80, fill = apep_colors[1], alpha = 0.8, color = "white") +
  geom_vline(xintercept = 0, linetype = "dashed", color = "grey40") +
  labs(
    title = "Large Within-State Variation in Labor Market Tightness",
    subtitle = "Deviation of county emp/pop ratio from state mean, 2022Q4",
    x = "County Employment/Population Ratio (deviation from state mean)",
    y = "Number of Counties"
  ) +
  theme_apep()

ggsave(file.path(FIGURES, "fig2_within_state_variation.pdf"), p2, width = 8, height = 5)

## ---- Figure 3: Scatter of employment change vs HCBS provider change ----
cat("Figure 3: Change scatter...\n")

pre <- smpl[year == 2019, .(
  pre_providers = mean(hcbs_providers, na.rm = TRUE),
  pre_emp = mean(emp_pop, na.rm = TRUE)
), by = county_fips]

post <- smpl[year == 2023, .(
  post_providers = mean(hcbs_providers, na.rm = TRUE),
  post_emp = mean(emp_pop, na.rm = TRUE)
), by = county_fips]

changes <- merge(pre, post, by = "county_fips")
changes[, d_providers := log(post_providers + 1) - log(pre_providers + 1)]
changes[, d_emp := post_emp - pre_emp]

# Winsorize for display
changes[, d_providers_w := pmin(pmax(d_providers, quantile(d_providers, 0.01, na.rm = TRUE)),
                                 quantile(d_providers, 0.99, na.rm = TRUE))]
changes[, d_emp_w := pmin(pmax(d_emp, quantile(d_emp, 0.01, na.rm = TRUE)),
                           quantile(d_emp, 0.99, na.rm = TRUE))]

p3 <- ggplot(changes[!is.na(d_emp_w) & !is.na(d_providers_w)],
             aes(x = d_emp_w, y = d_providers_w)) +
  geom_point(alpha = 0.15, size = 0.8, color = apep_colors[1]) +
  geom_smooth(method = "lm", color = apep_colors[2], linewidth = 1.2, se = TRUE) +
  labs(
    title = "Counties with Tighter Labor Markets Lost HCBS Providers",
    subtitle = "Change from 2019 to 2023, winsorized at 1st/99th percentile",
    x = "Change in Employment/Population Ratio (2019 to 2023)",
    y = "Change in ln(HCBS Providers)"
  ) +
  theme_apep()

ggsave(file.path(FIGURES, "fig3_change_scatter.pdf"), p3, width = 8, height = 6)

## ---- Figure 4: Event study plot ----
cat("Figure 4: Event study...\n")

es <- robustness$es_ols

# Extract coefficients
es_coefs <- as.data.table(coeftable(es))
es_coefs[, term := rownames(coeftable(es))]

# Parse rel_time from coefficient names
es_coefs[, rel_time := as.integer(gsub(".*::(-?[0-9]+):emp_pop", "\\1", term))]
es_coefs <- es_coefs[!is.na(rel_time)]
setnames(es_coefs, c("Estimate", "Std. Error"), c("estimate", "se"))
es_coefs[, ci_lo := estimate - 1.96 * se]
es_coefs[, ci_hi := estimate + 1.96 * se]

# Add reference period (0 at rel_time = -1)
es_coefs <- rbind(es_coefs[, .(rel_time, estimate, se, ci_lo, ci_hi)],
                  data.table(rel_time = -1, estimate = 0, se = 0, ci_lo = 0, ci_hi = 0))
setorder(es_coefs, rel_time)

p4 <- ggplot(es_coefs, aes(x = rel_time, y = estimate)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
  geom_vline(xintercept = -0.5, linetype = "dotted", color = "grey50") +
  geom_ribbon(aes(ymin = ci_lo, ymax = ci_hi), fill = apep_colors[1], alpha = 0.2) +
  geom_point(color = apep_colors[1], size = 2) +
  geom_line(color = apep_colors[1], linewidth = 0.8) +
  annotate("text", x = -4, y = max(es_coefs$ci_hi) * 0.9, label = "Pre-period",
           color = "grey40", size = 3) +
  annotate("text", x = 6, y = max(es_coefs$ci_hi) * 0.9, label = "Post-period",
           color = "grey40", size = 3) +
  scale_x_continuous(breaks = seq(-8, 12, 2)) +
  labs(
    title = "Event Study: Effect of Labor Market Tightness on HCBS Supply",
    subtitle = "Quarters relative to COVID onset (2020Q1). County + state x quarter FE.",
    x = "Quarters Relative to 2020Q1",
    y = "Coefficient on Employment/Population"
  ) +
  theme_apep()

ggsave(file.path(FIGURES, "fig4_event_study.pdf"), p4, width = 8, height = 5.5)

## ---- Figure 5: Bartik first stage ----
cat("Figure 5: First stage...\n")

fs_data <- smpl[, .(bartik = mean(bartik, na.rm = TRUE),
                      emp_pop = mean(emp_pop, na.rm = TRUE)),
                 by = .(year, quarter)]
fs_data[, date := as.Date(sprintf("%d-%02d-01", year, (quarter - 1) * 3 + 1))]

# Residualize (remove county and state×quarter FE visually)
# Show binscatter of bartik vs emp_pop (county-demeaned)
smpl[, bartik_dm := bartik - mean(bartik, na.rm = TRUE), by = county_fips]
smpl[, emp_pop_dm := emp_pop - mean(emp_pop, na.rm = TRUE), by = county_fips]

# Create 20 equal-sized bins
smpl_fs <- smpl[!is.na(bartik_dm) & !is.na(emp_pop_dm)]
smpl_fs[, bartik_bin := cut(bartik_dm, breaks = 20, labels = FALSE)]
bins_fs <- smpl_fs[, .(
  bartik_mean = mean(bartik_dm, na.rm = TRUE),
  emp_mean = mean(emp_pop_dm, na.rm = TRUE)
), by = bartik_bin]

p5 <- ggplot(bins_fs, aes(x = bartik_mean, y = emp_mean)) +
  geom_point(size = 3, color = apep_colors[1]) +
  geom_smooth(method = "lm", color = apep_colors[2], linewidth = 1.2, se = FALSE) +
  labs(
    title = "First Stage: Bartik Instrument Predicts Employment",
    subtitle = "Binned scatter (20 bins). County-demeaned values.",
    x = "Bartik Predicted Employment Growth (demeaned)",
    y = "Actual Employment/Population (demeaned)"
  ) +
  theme_apep()

ggsave(file.path(FIGURES, "fig5_first_stage.pdf"), p5, width = 7, height = 5.5)

## ---- Figure 6: Heterogeneity — Urban vs Rural ----
cat("Figure 6: Urban vs Rural...\n")

het_data <- data.table(
  group = c("Urban", "Rural", "Individual\nProviders", "Organizational\nProviders"),
  estimate = c(
    coef(results$iv_urban)["fit_emp_pop"],
    coef(results$iv_rural)["fit_emp_pop"],
    coef(results$iv_indiv)["fit_emp_pop"],
    coef(results$iv_org)["fit_emp_pop"]
  ),
  se = c(
    se(results$iv_urban)["fit_emp_pop"],
    se(results$iv_rural)["fit_emp_pop"],
    se(results$iv_indiv)["fit_emp_pop"],
    se(results$iv_org)["fit_emp_pop"]
  )
)
het_data[, ci_lo := estimate - 1.96 * se]
het_data[, ci_hi := estimate + 1.96 * se]
het_data[, group := factor(group, levels = group)]

p6 <- ggplot(het_data, aes(x = group, y = estimate)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
  geom_pointrange(aes(ymin = ci_lo, ymax = ci_hi), color = apep_colors[1], size = 0.8) +
  labs(
    title = "Heterogeneous Effects by Provider and Area Type",
    subtitle = "IV estimates with 95% CIs. Dependent variable: ln(HCBS providers).",
    x = NULL, y = "IV Coefficient (Bartik)"
  ) +
  theme_apep() +
  theme(axis.text.x = element_text(size = 10))

ggsave(file.path(FIGURES, "fig6_heterogeneity.pdf"), p6, width = 7, height = 5)

## ---- Figure 7: Map of HCBS provider change ----
cat("Figure 7: Map...\n")

# Get county shapefiles
counties_sf <- tryCatch({
  tigris::counties(cb = TRUE, year = 2020, progress_bar = FALSE)
}, error = function(e) {
  cat("WARNING: Could not download county shapefiles. Skipping map.\n")
  NULL
})

if (!is.null(counties_sf)) {
  changes[, GEOID := county_fips]

  map_data <- merge(counties_sf, changes[, .(GEOID, d_providers)],
                    by = "GEOID", all.x = TRUE)

  # Filter to continental US
  map_data <- map_data[!map_data$STATEFP %in% c("02", "15", "60", "66", "69", "72", "78"), ]

  p7 <- ggplot(map_data) +
    geom_sf(aes(fill = d_providers), color = NA, size = 0) +
    scale_fill_gradient2(
      low = apep_colors[2], mid = "white", high = apep_colors[3],
      midpoint = 0, na.value = "grey90",
      limits = c(-1, 1),
      oob = scales::squish,
      name = "Change in\nln(Providers)"
    ) +
    labs(
      title = "Change in HCBS Provider Supply, 2019 to 2023",
      subtitle = "Log change in active HCBS billing providers per county"
    ) +
    theme_void() +
    theme(
      plot.title = element_text(size = 13, face = "bold"),
      plot.subtitle = element_text(size = 10, color = "grey40"),
      legend.position = "right"
    )

  ggsave(file.path(FIGURES, "fig7_map_provider_change.pdf"), p7, width = 10, height = 6)
}

cat("\n=== All figures saved ===\n")
