## 05_figures.R — All figure generation
## APEP-0237: Flood Risk Disclosure Laws and Housing Market Capitalization

source("00_packages.R")

data_dir <- "../data/"
fig_dir <- "../figures/"
dir.create(fig_dir, showWarnings = FALSE, recursive = TRUE)

panel <- fread(paste0(data_dir, "panel_annual.csv"))
treatment <- read_csv(paste0(data_dir, "treatment_disclosure_laws.csv"),
                      show_col_types = FALSE)

# ============================================================================
# Figure 1: Map of State Flood Disclosure Law Adoption
# ============================================================================
cat("Creating Figure 1: Treatment map...\n")

# Simplified: show adoption wave by state
treatment_map <- treatment %>%
  mutate(
    wave_label = case_when(
      wave == "first" ~ "First Wave (1992-1999)",
      wave == "second" ~ "Second Wave (2000-2006)",
      wave == "third" ~ "Third Wave (2019-2024)",
      wave == "never" ~ "No Mandatory Disclosure",
      TRUE ~ "Unknown"
    ),
    wave_label = factor(wave_label, levels = c(
      "First Wave (1992-1999)", "Second Wave (2000-2006)",
      "Third Wave (2019-2024)", "No Mandatory Disclosure"
    ))
  )

# Bar chart showing adoption timeline
fig1 <- treatment %>%
  filter(year_adopted > 0) %>%
  count(year_adopted) %>%
  ggplot(aes(x = year_adopted, y = n)) +
  geom_col(fill = "#2166AC", alpha = 0.8) +
  geom_vline(xintercept = c(1999.5, 2018.5), linetype = "dashed",
             color = "gray50") +
  annotate("text", x = 1996, y = 6.5, label = "First Wave",
           size = 3, color = "gray40") +
  annotate("text", x = 2009, y = 6.5, label = "Second Wave",
           size = 3, color = "gray40") +
  annotate("text", x = 2022, y = 6.5, label = "Third Wave",
           size = 3, color = "gray40") +
  labs(
    x = "Year of Adoption",
    y = "Number of States",
    title = "State Adoption of Flood Risk Disclosure Laws",
    subtitle = "Mandatory seller disclosure requirements including flood-related content"
  ) +
  scale_x_continuous(breaks = seq(1992, 2024, 4)) +
  theme(panel.grid.major.x = element_line(color = "gray90"))

ggsave(paste0(fig_dir, "fig1_adoption_timeline.pdf"), fig1,
       width = 8, height = 5)

# ============================================================================
# Figure 2: Event Study — Dynamic Treatment Effects
# ============================================================================
cat("Creating Figure 2: Event study...\n")

es_model <- readRDS(paste0(data_dir, "event_study_model.rds"))

# Extract event study coefficients
es_coefs <- broom::tidy(es_model, conf.int = TRUE) %>%
  filter(str_detect(term, "rel_year_binned")) %>%
  mutate(
    rel_year = as.integer(str_extract(term, "-?\\d+$")),
    # Add the omitted reference period
    estimate = estimate,
    conf.low = conf.low,
    conf.high = conf.high
  )

# Add reference period (0 coefficient at t = -1)
es_coefs <- bind_rows(
  es_coefs,
  tibble(term = "ref", rel_year = -1L, estimate = 0,
         std.error = 0, conf.low = 0, conf.high = 0)
) %>%
  arrange(rel_year)

fig2 <- ggplot(es_coefs, aes(x = rel_year, y = estimate)) +
  geom_hline(yintercept = 0, color = "gray60") +
  geom_vline(xintercept = -0.5, linetype = "dashed", color = "#B2182B",
             alpha = 0.6) +
  geom_ribbon(aes(ymin = conf.low, ymax = conf.high),
              fill = "#2166AC", alpha = 0.15) +
  geom_point(size = 2.5, color = "#2166AC") +
  geom_line(color = "#2166AC", linewidth = 0.5) +
  labs(
    x = "Years Relative to Disclosure Law Adoption",
    y = "Coefficient (log ZHVI)",
    title = "Event Study: Effect of Flood Disclosure on Housing Values",
    subtitle = "Interaction of high-flood-exposure counties with disclosure law adoption"
  ) +
  scale_x_continuous(breaks = seq(-6, 8, 2)) +
  annotate("text", x = -4, y = min(es_coefs$conf.low, na.rm = TRUE) * 0.9,
           label = "Pre-treatment\n(parallel trends test)",
           size = 3, color = "gray50", hjust = 0.5) +
  annotate("text", x = 4, y = min(es_coefs$conf.low, na.rm = TRUE) * 0.9,
           label = "Post-treatment\n(treatment effect)",
           size = 3, color = "gray50", hjust = 0.5)

ggsave(paste0(fig_dir, "fig2_event_study.pdf"), fig2,
       width = 8, height = 5.5)

# ============================================================================
# Figure 3: Housing Value Trends — Treated vs Control
# ============================================================================
cat("Creating Figure 3: Housing value trends...\n")

# Average ZHVI by treatment status and flood exposure
trends <- panel %>%
  mutate(
    group = case_when(
      treated == 1 & high_flood == 1 ~ "Treated, High Flood",
      treated == 1 & high_flood == 0 ~ "Treated, Low Flood",
      treated == 0 & high_flood == 1 ~ "Control, High Flood",
      treated == 0 & high_flood == 0 ~ "Control, Low Flood",
      TRUE ~ NA_character_
    )
  ) %>%
  filter(!is.na(group)) %>%
  group_by(year, group) %>%
  summarize(mean_zhvi = mean(zhvi, na.rm = TRUE) / 1000,
            .groups = "drop")

fig3 <- ggplot(trends, aes(x = year, y = mean_zhvi, color = group,
                           linetype = group)) +
  geom_line(linewidth = 0.8) +
  scale_color_manual(values = c(
    "Treated, High Flood" = "#B2182B",
    "Treated, Low Flood" = "#EF8A62",
    "Control, High Flood" = "#2166AC",
    "Control, Low Flood" = "#67A9CF"
  )) +
  scale_linetype_manual(values = c(
    "Treated, High Flood" = "solid",
    "Treated, Low Flood" = "dashed",
    "Control, High Flood" = "solid",
    "Control, Low Flood" = "dashed"
  )) +
  labs(
    x = "Year",
    y = "Mean ZHVI ($1,000s)",
    color = NULL, linetype = NULL,
    title = "Housing Value Trends by Treatment and Flood Exposure",
    subtitle = "County-level Zillow Home Value Index"
  ) +
  scale_x_continuous(breaks = seq(2000, 2024, 4)) +
  theme(legend.position = "bottom",
        legend.key.width = unit(1.5, "cm"))

ggsave(paste0(fig_dir, "fig3_trends.pdf"), fig3,
       width = 8, height = 5.5)

# ============================================================================
# Figure 4: CS-DiD Dynamic Effects (if available)
# ============================================================================
cat("Creating Figure 4: CS-DiD dynamic effects...\n")

if (file.exists(paste0(data_dir, "cs_dynamic.rds"))) {
  cs_dynamic <- readRDS(paste0(data_dir, "cs_dynamic.rds"))

  cs_df <- data.frame(
    rel_year = cs_dynamic$egt,
    att = cs_dynamic$att.egt,
    se = cs_dynamic$se.egt
  ) %>%
    mutate(
      ci_lo = att - 1.96 * se,
      ci_hi = att + 1.96 * se
    )

  fig4 <- ggplot(cs_df, aes(x = rel_year, y = att)) +
    geom_hline(yintercept = 0, color = "gray60") +
    geom_vline(xintercept = -0.5, linetype = "dashed", color = "#B2182B",
               alpha = 0.6) +
    geom_ribbon(aes(ymin = ci_lo, ymax = ci_hi),
                fill = "#4393C3", alpha = 0.15) +
    geom_point(size = 2.5, color = "#4393C3") +
    geom_line(color = "#4393C3", linewidth = 0.5) +
    labs(
      x = "Event Time (Years Relative to Adoption)",
      y = "ATT (log ZHVI)",
      title = "Callaway-Sant'Anna Dynamic Treatment Effects",
      subtitle = "Heterogeneity-robust estimation, high-flood counties vs. never-treated"
    ) +
    scale_x_continuous(breaks = seq(-5, 8, 1))

  ggsave(paste0(fig_dir, "fig4_cs_dynamic.pdf"), fig4,
         width = 8, height = 5.5)
} else {
  cat("  CS-DiD results not available. Generating placeholder.\n")
  # Create a note figure instead
  fig4 <- ggplot() +
    annotate("text", x = 0.5, y = 0.5,
             label = "CS-DiD dynamic effects\n(See Table 3 for results)",
             size = 5) +
    theme_void()
  ggsave(paste0(fig_dir, "fig4_cs_dynamic.pdf"), fig4,
         width = 8, height = 5.5)
}

# ============================================================================
# Figure 5: Robustness — Flood Exposure Thresholds
# ============================================================================
cat("Creating Figure 5: Robustness across thresholds...\n")

threshold_results <- tibble()
for (pctile in seq(0.3, 0.95, by = 0.05)) {
  panel_alt <- panel %>%
    mutate(
      high_alt = as.integer(flood_pctile >= pctile),
      post_x_alt = post * high_alt
    )

  m <- tryCatch(
    feols(log_zhvi ~ post_x_alt | fips + state_abbr^year,
          data = panel_alt, cluster = ~state_abbr),
    error = function(e) NULL
  )

  if (!is.null(m)) {
    threshold_results <- bind_rows(threshold_results, tibble(
      threshold = pctile,
      estimate = coef(m)["post_x_alt"],
      se = se(m)["post_x_alt"]
    ))
  }
}

if (nrow(threshold_results) > 0) {
  threshold_results <- threshold_results %>%
    mutate(ci_lo = estimate - 1.96 * se,
           ci_hi = estimate + 1.96 * se)

  fig5 <- ggplot(threshold_results, aes(x = threshold, y = estimate)) +
    geom_hline(yintercept = 0, color = "gray60") +
    geom_ribbon(aes(ymin = ci_lo, ymax = ci_hi),
                fill = "#2166AC", alpha = 0.15) +
    geom_point(size = 2, color = "#2166AC") +
    geom_line(color = "#2166AC") +
    geom_vline(xintercept = 0.67, linetype = "dashed", color = "#B2182B",
               alpha = 0.6) +
    annotate("text", x = 0.67, y = max(threshold_results$ci_hi, na.rm = TRUE),
             label = "Main spec\n(p67)", size = 3, color = "#B2182B",
             hjust = -0.1) +
    labs(
      x = "Flood Exposure Percentile Threshold",
      y = "DDD Coefficient",
      title = "Robustness: Effect Across Flood Exposure Thresholds",
      subtitle = "Point estimates and 95% CIs for different definitions of 'high flood' counties"
    ) +
    scale_x_continuous(labels = percent_format())

  ggsave(paste0(fig_dir, "fig5_threshold_robustness.pdf"), fig5,
         width = 8, height = 5)
}

# ============================================================================
# Figure 6: Adoption Wave Heterogeneity
# ============================================================================
cat("Creating Figure 6: Wave heterogeneity...\n")

wave_results <- tibble()
for (w in c("first", "second", "third")) {
  wave_data <- panel %>%
    filter(wave %in% c(w, "never")) %>%
    mutate(post_x_flood = post * high_flood)

  m <- tryCatch(
    feols(log_zhvi ~ post_x_flood | fips + state_abbr^year,
          data = wave_data, cluster = ~state_abbr),
    error = function(e) NULL
  )

  if (!is.null(m)) {
    wave_results <- bind_rows(wave_results, tibble(
      wave = w,
      estimate = coef(m)["post_x_flood"],
      se = se(m)["post_x_flood"]
    ))
  }
}

if (nrow(wave_results) > 0) {
  wave_results <- wave_results %>%
    mutate(
      ci_lo = estimate - 1.96 * se,
      ci_hi = estimate + 1.96 * se,
      wave_label = case_when(
        wave == "first" ~ "First Wave\n(1992-1999)",
        wave == "second" ~ "Second Wave\n(2000-2006)",
        wave == "third" ~ "Third Wave\n(2019-2024)"
      ),
      wave_label = factor(wave_label, levels = c(
        "First Wave\n(1992-1999)", "Second Wave\n(2000-2006)",
        "Third Wave\n(2019-2024)"
      ))
    )

  fig6 <- ggplot(wave_results, aes(x = wave_label, y = estimate)) +
    geom_hline(yintercept = 0, color = "gray60") +
    geom_pointrange(aes(ymin = ci_lo, ymax = ci_hi),
                    color = "#2166AC", size = 0.8) +
    labs(
      x = NULL,
      y = "DDD Coefficient",
      title = "Treatment Effect by Adoption Wave",
      subtitle = "Heterogeneity across early vs. late adopters"
    )

  ggsave(paste0(fig_dir, "fig6_wave_heterogeneity.pdf"), fig6,
         width = 6, height = 5)
}

cat("\n============================================\n")
cat("FIGURE GENERATION COMPLETE\n")
cat("============================================\n")
cat("Figures saved in:", fig_dir, "\n")
