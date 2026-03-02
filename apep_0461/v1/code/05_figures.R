## 05_figures.R — Generate all figures
## apep_0461: Oil Dependence and Child Survival

source("00_packages.R")

cat("=== Loading data and results ===\n")
panel <- readRDS("../data/panel_dev.rds")
oil <- readRDS("../data/oil_prices.rds")
es_coefs <- readRDS("../data/event_study_coefs.rds")
results <- readRDS("../data/main_results.rds")
robustness <- readRDS("../data/robustness_results.rds")

# ============================================================
# Figure 1: Oil price and the 2014 crash
# ============================================================
cat("\n=== Figure 1: Oil price timeline ===\n")

fig1 <- ggplot(oil, aes(x = year, y = oil_price_brent)) +
  geom_line(color = apep_colors[1], linewidth = 1) +
  geom_ribbon(aes(ymin = oil_price_brent - oil_price_sd,
                  ymax = oil_price_brent + oil_price_sd),
              alpha = 0.15, fill = apep_colors[1]) +
  geom_vline(xintercept = 2014, linetype = "dashed", color = "grey40") +
  annotate("text", x = 2014.3, y = max(oil$oil_price_brent, na.rm = TRUE) * 0.95,
           label = "Oil price\ncrash begins", hjust = 0, size = 3.5, color = "grey40") +
  scale_x_continuous(breaks = seq(2000, 2024, 2)) +
  scale_y_continuous(labels = scales::dollar_format()) +
  labs(
    x = "Year",
    y = "Brent Crude Price (USD/barrel)",
    title = "Global Oil Price, 2000\u20132024",
    subtitle = "Annual average with monthly standard deviation band",
    caption = "Source: FRED (DCOILBRENTEU)"
  ) +
  theme_apep()

ggsave("../figures/fig1_oil_price.pdf", fig1, width = 8, height = 5, device = pdf)
cat("  Saved: fig1_oil_price.pdf\n")

# ============================================================
# Figure 2: Under-5 mortality trends by oil dependence
# ============================================================
cat("\n=== Figure 2: Mortality trends by treatment group ===\n")

trends <- panel %>%
  mutate(group = case_when(
    oil_rents_pre > 10 ~ "High oil (>10% GDP)",
    oil_rents_pre > 2 ~ "Moderate oil (2\u201310%)",
    TRUE ~ "Low/No oil (<2%)"
  )) %>%
  group_by(group, year) %>%
  summarise(
    mean_u5 = mean(u5_mortality, na.rm = TRUE),
    se_u5 = sd(u5_mortality, na.rm = TRUE) / sqrt(n()),
    n = n(),
    .groups = "drop"
  ) %>%
  mutate(group = factor(group, levels = c("High oil (>10% GDP)", "Moderate oil (2\u201310%)", "Low/No oil (<2%)")))

fig2 <- ggplot(trends, aes(x = year, y = mean_u5, color = group, fill = group)) +
  geom_ribbon(aes(ymin = mean_u5 - 1.96 * se_u5, ymax = mean_u5 + 1.96 * se_u5),
              alpha = 0.1, color = NA) +
  geom_line(linewidth = 0.8) +
  geom_point(size = 1.5) +
  geom_vline(xintercept = 2014, linetype = "dashed", color = "grey40") +
  scale_color_manual(values = apep_colors[1:3]) +
  scale_fill_manual(values = apep_colors[1:3]) +
  scale_x_continuous(breaks = seq(2005, 2023, 2)) +
  labs(
    x = "Year",
    y = "Under-5 Mortality Rate\n(per 1,000 live births)",
    title = "Under-5 Mortality by Pre-2014 Oil Dependence",
    subtitle = "Country-group means with 95% confidence intervals",
    color = "Oil Dependence\n(2010\u20132013 avg)",
    fill = "Oil Dependence\n(2010\u20132013 avg)",
    caption = "Source: World Bank WDI"
  ) +
  theme_apep()

ggsave("../figures/fig2_mortality_trends.pdf", fig2, width = 9, height = 6, device = pdf)
cat("  Saved: fig2_mortality_trends.pdf\n")

# ============================================================
# Figure 3: Event study
# ============================================================
cat("\n=== Figure 3: Event study ===\n")

fig3 <- ggplot(es_coefs, aes(x = event_time, y = estimate)) +
  geom_hline(yintercept = 0, color = "grey60", linewidth = 0.3) +
  geom_vline(xintercept = -0.5, linetype = "dashed", color = "grey40") +
  geom_ribbon(aes(ymin = ci_low, ymax = ci_high), alpha = 0.15, fill = apep_colors[1]) +
  geom_point(color = apep_colors[1], size = 2.5) +
  geom_line(color = apep_colors[1], linewidth = 0.6) +
  scale_x_continuous(breaks = seq(-9, 9, 1)) +
  labs(
    x = "Years Relative to 2014 Oil Price Crash",
    y = "Coefficient on Oil Rents\u00d7Post",
    title = "Event Study: Oil Dependence and Under-5 Mortality",
    subtitle = "Interaction of pre-crash oil rents (% GDP) with year dummies; 2013 = reference",
    caption = "Notes: 95% CIs based on country-clustered SEs. Country and year FE included."
  ) +
  theme_apep()

ggsave("../figures/fig3_event_study.pdf", fig3, width = 9, height = 6, device = pdf)
cat("  Saved: fig3_event_study.pdf\n")

# ============================================================
# Figure 4: Treatment intensity (map-like scatter)
# ============================================================
cat("\n=== Figure 4: Treatment intensity ===\n")

treatment_map <- panel %>%
  filter(year == 2013) %>%
  select(iso3c, country, oil_rents_pre, u5_mortality, region) %>%
  filter(!is.na(oil_rents_pre))

fig4 <- ggplot(treatment_map, aes(x = oil_rents_pre, y = u5_mortality)) +
  geom_point(aes(color = region), alpha = 0.7, size = 2.5) +
  geom_text(data = filter(treatment_map, oil_rents_pre > 15 | u5_mortality > 120),
            aes(label = iso3c), hjust = -0.2, size = 2.5, color = "grey40") +
  geom_smooth(method = "lm", se = TRUE, color = "grey30", linewidth = 0.5, linetype = "dashed") +
  scale_x_continuous(labels = function(x) paste0(x, "%")) +
  labs(
    x = "Pre-2014 Oil Rents (% of GDP)",
    y = "Under-5 Mortality (2013)",
    title = "Oil Dependence and Child Mortality, Pre-Crash (2013)",
    subtitle = "Each point is a developing country",
    color = "Region",
    caption = "Source: World Bank WDI. Oil rents = 2010\u20132013 average."
  ) +
  theme_apep() +
  theme(legend.position = "right")

ggsave("../figures/fig4_treatment_scatter.pdf", fig4, width = 9, height = 6, device = pdf)
cat("  Saved: fig4_treatment_scatter.pdf\n")

# ============================================================
# Figure 5: Mechanism — Health expenditure trends
# ============================================================
cat("\n=== Figure 5: Health expenditure mechanism ===\n")

health_trends <- panel %>%
  mutate(group = ifelse(oil_rents_pre > 5, "High Oil", "Low/No Oil")) %>%
  group_by(group, year) %>%
  summarise(
    mean_health = mean(health_exp, na.rm = TRUE),
    mean_military = mean(military_exp, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  pivot_longer(cols = c(mean_health, mean_military),
               names_to = "spending_type",
               values_to = "pct_gdp") %>%
  mutate(spending_type = ifelse(spending_type == "mean_health", "Health", "Military"))

fig5 <- ggplot(health_trends, aes(x = year, y = pct_gdp, color = group, linetype = spending_type)) +
  geom_line(linewidth = 0.8) +
  geom_point(size = 1.5) +
  geom_vline(xintercept = 2014, linetype = "dashed", color = "grey40") +
  scale_color_manual(values = apep_colors[1:2]) +
  scale_linetype_manual(values = c("Health" = "solid", "Military" = "dotted")) +
  scale_x_continuous(breaks = seq(2005, 2023, 2)) +
  labs(
    x = "Year",
    y = "Expenditure (% of GDP)",
    title = "Health vs. Military Expenditure by Oil Dependence",
    subtitle = "Oil-dependent countries maintained health spending after the 2014 crash",
    color = "Oil Dependence",
    linetype = "Spending Type",
    caption = "Source: World Bank WDI"
  ) +
  theme_apep()

ggsave("../figures/fig5_mechanism_spending.pdf", fig5, width = 9, height = 6, device = pdf)
cat("  Saved: fig5_mechanism_spending.pdf\n")

# ============================================================
# Figure 6: Nigeria spotlight
# ============================================================
cat("\n=== Figure 6: Nigeria spotlight ===\n")

nigeria <- panel %>%
  filter(iso3c == "NGA") %>%
  select(year, u5_mortality, health_exp, military_exp, gdp_pc_constant) %>%
  pivot_longer(cols = -year, names_to = "indicator", values_to = "value") %>%
  mutate(indicator = case_when(
    indicator == "u5_mortality" ~ "Under-5 Mortality\n(per 1,000)",
    indicator == "health_exp" ~ "Health Exp.\n(% GDP)",
    indicator == "military_exp" ~ "Military Exp.\n(% GDP)",
    indicator == "gdp_pc_constant" ~ "GDP per capita\n(constant 2015 $)"
  ))

fig6 <- ggplot(nigeria, aes(x = year, y = value)) +
  geom_line(color = apep_colors[1], linewidth = 0.8) +
  geom_point(color = apep_colors[1], size = 1.5) +
  geom_vline(xintercept = 2014, linetype = "dashed", color = "grey40") +
  facet_wrap(~indicator, scales = "free_y", ncol = 2) +
  scale_x_continuous(breaks = seq(2005, 2023, 3)) +
  labs(
    x = "Year",
    y = "",
    title = "Nigeria: Key Indicators Around the 2014 Oil Price Crash",
    caption = "Source: World Bank WDI"
  ) +
  theme_apep()

ggsave("../figures/fig6_nigeria_spotlight.pdf", fig6, width = 9, height = 7, device = pdf)
cat("  Saved: fig6_nigeria_spotlight.pdf\n")

# ============================================================
# Figure 7: Robustness — Time window sensitivity
# ============================================================
cat("\n=== Figure 7: Robustness - time windows ===\n")

window_df <- robustness$window_results %>%
  mutate(
    ci_low = estimate - 1.96 * se,
    ci_high = estimate + 1.96 * se,
    sig = ifelse(p_value < 0.05, "p < 0.05", "p >= 0.05")
  )

fig7 <- ggplot(window_df, aes(x = window, y = estimate, color = sig)) +
  geom_hline(yintercept = 0, color = "grey60") +
  geom_pointrange(aes(ymin = ci_low, ymax = ci_high), size = 0.8) +
  scale_color_manual(values = c("p < 0.05" = apep_colors[1], "p >= 0.05" = "grey50")) +
  labs(
    x = "Time Window",
    y = "Coefficient on Oil Rents \u00d7 Post-2014",
    title = "Robustness: Sensitivity to Time Window",
    color = "Significance"
  ) +
  theme_apep() +
  coord_flip()

ggsave("../figures/fig7_robustness_windows.pdf", fig7, width = 8, height = 5, device = pdf)
cat("  Saved: fig7_robustness_windows.pdf\n")

cat("\n=== All figures generated ===\n")
