# =============================================================================
# 05_figures.R — All Figure Generation
# apep_0427: France Apprenticeship Subsidy and Entry-Level Labor Markets
# =============================================================================

source("00_packages.R")

cat("=== Generating figures for apep_0427 ===\n")

# Load data and models
cross_country    <- readRDS("../data/cross_country_panel.rds")
sector_panel     <- readRDS("../data/sector_panel.rds")
models           <- readRDS("../data/main_models.rds")
es_sector        <- readRDS("../data/event_study_sector.rds")
es_cc            <- readRDS("../data/event_study_cross_country.rds")
loso             <- readRDS("../data/loso_results.rds")
ri_results       <- readRDS("../data/permutation_inference.rds")

# Load Indeed data
indeed_fr        <- readRDS("../data/indeed_fr_clean.rds")
indeed_all       <- readRDS("../data/indeed_cross_country.rds")

# =============================================================
# Figure 1: France Apprenticeship Boom Context
# =============================================================
cat("Figure 1: Apprenticeship boom context...\n")

# France vs EU youth employment rates over time
fr_vs_eu <- cross_country %>%
  filter(age_group == "Y15-24") %>%
  mutate(group = ifelse(country == "FR", "France", "EU Comparators")) %>%
  group_by(group, date) %>%
  summarize(emp_rate = mean(emp_rate, na.rm = TRUE), .groups = "drop")

p1 <- ggplot(fr_vs_eu, aes(x = date, y = emp_rate, color = group)) +
  geom_line(linewidth = 1) +
  geom_vline(xintercept = as.Date("2020-07-01"), linetype = "dashed",
             color = "grey50", linewidth = 0.5) +
  geom_vline(xintercept = as.Date("2023-01-01"), linetype = "dashed",
             color = "grey50", linewidth = 0.5) +
  annotate("text", x = as.Date("2020-07-01"), y = max(fr_vs_eu$emp_rate, na.rm = TRUE),
           label = "Subsidy\nIntroduced", hjust = -0.1, size = 3, color = "grey40") +
  annotate("text", x = as.Date("2023-01-01"), y = max(fr_vs_eu$emp_rate, na.rm = TRUE),
           label = "Subsidy\nReduced", hjust = -0.1, size = 3, color = "grey40") +
  scale_color_manual(values = c("France" = apep_colors[1],
                                "EU Comparators" = apep_colors[2])) +
  labs(
    title = "Youth Employment Rates: France vs. EU Comparators",
    subtitle = "Ages 15-24, seasonally adjusted quarterly data",
    x = NULL,
    y = "Employment Rate (%)",
    color = NULL,
    caption = "Source: Eurostat LFS (lfsi_emp_q). EU comparators: BE, NL, ES, IT, PT, DE, AT."
  ) +
  theme_apep()

ggsave("../figures/fig1_youth_emp_trends.pdf", p1, width = 9, height = 5.5)

# =============================================================
# Figure 2: Sector Apprenticeship Exposure Map
# =============================================================
cat("Figure 2: Sector exposure variation...\n")

sector_exp <- sector_panel %>%
  distinct(sector, exposure, sector_name) %>%
  filter(!is.na(sector_name)) %>%
  arrange(desc(exposure))

p2 <- ggplot(sector_exp, aes(x = reorder(sector_name, exposure), y = exposure * 100)) +
  geom_col(fill = apep_colors[1], alpha = 0.8) +
  geom_hline(yintercept = median(sector_exp$exposure * 100),
             linetype = "dashed", color = apep_colors[2]) +
  annotate("text", x = 1, y = median(sector_exp$exposure * 100) + 0.5,
           label = "Median", color = apep_colors[2], size = 3, hjust = 0) +
  coord_flip() +
  labs(
    title = "Pre-Reform Apprenticeship Intensity by Sector (2019)",
    subtitle = "Apprenticeship contracts as share of sector employment",
    x = NULL,
    y = "Apprenticeship Intensity (%)",
    caption = "Source: DARES (2019), Eurostat. Dashed line = median."
  ) +
  theme_apep()

ggsave("../figures/fig2_sector_exposure.pdf", p2, width = 8, height = 6)

# =============================================================
# Figure 3: Event Study — Sector Exposure (PRIMARY RESULT)
# =============================================================
cat("Figure 3: Event study (sector exposure)...\n")

es_coefs <- as.data.frame(coeftable(es_sector)) %>%
  rownames_to_column("term") %>%
  filter(grepl("event_time", term)) %>%
  mutate(
    event_time = as.numeric(gsub(".*::(-?\\d+):.*", "\\1", term)),
    estimate = Estimate,
    se = `Std. Error`
  ) %>%
  # Add reference period
  bind_rows(tibble(event_time = -1, estimate = 0, se = 0))

p3 <- ggplot(es_coefs, aes(x = event_time, y = estimate)) +
  geom_ribbon(aes(ymin = estimate - 1.96 * se, ymax = estimate + 1.96 * se),
              alpha = 0.2, fill = apep_colors[1]) +
  geom_point(color = apep_colors[1], size = 2.5) +
  geom_line(color = apep_colors[1], linewidth = 0.7) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
  geom_vline(xintercept = -0.5, linetype = "dotted", color = "grey60") +
  annotate("text", x = -10, y = max(es_coefs$estimate + 1.96 * es_coefs$se, na.rm = TRUE) * 0.9,
           label = "Pre-treatment", hjust = 0, size = 3, color = "grey50") +
  annotate("text", x = 2, y = max(es_coefs$estimate + 1.96 * es_coefs$se, na.rm = TRUE) * 0.9,
           label = "Post-reduction", hjust = 0, size = 3, color = "grey50") +
  scale_x_continuous(breaks = seq(-20, 10, 4)) +
  labs(
    title = "Event Study: Effect of Subsidy Reduction on Youth Employment Share",
    subtitle = "Bartik exposure x event-time interaction, reference period = Q4 2022",
    x = "Quarters Relative to January 2023 Reduction",
    y = "Effect on Youth Employment Share (pp)",
    caption = "Note: Shaded region = 95% CI. Clustered SEs at sector level."
  ) +
  theme_apep()

ggsave("../figures/fig3_event_study_sector.pdf", p3, width = 9, height = 5.5)

# =============================================================
# Figure 4: Cross-Country Event Study (Robustness)
# =============================================================
cat("Figure 4: Cross-country event study...\n")

es_cc_coefs <- as.data.frame(coeftable(es_cc)) %>%
  rownames_to_column("term") %>%
  filter(grepl("event_time", term)) %>%
  mutate(
    event_time = as.numeric(gsub(".*::(-?\\d+):.*", "\\1", term)),
    estimate = Estimate,
    se = `Std. Error`
  ) %>%
  bind_rows(tibble(event_time = -1, estimate = 0, se = 0))

p4 <- ggplot(es_cc_coefs, aes(x = event_time, y = estimate)) +
  geom_ribbon(aes(ymin = estimate - 1.96 * se, ymax = estimate + 1.96 * se),
              alpha = 0.2, fill = apep_colors[2]) +
  geom_point(color = apep_colors[2], size = 2.5) +
  geom_line(color = apep_colors[2], linewidth = 0.7) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
  geom_vline(xintercept = -0.5, linetype = "dotted", color = "grey60") +
  scale_x_continuous(breaks = seq(-20, 10, 4)) +
  labs(
    title = "Cross-Country Event Study: France vs. EU Comparators",
    subtitle = "Youth (15-24) employment rate, France indicator x event time",
    x = "Quarters Relative to January 2023 Reduction",
    y = "Differential Youth Employment Rate (pp)",
    caption = "Note: Controls: BE, NL, ES, IT, PT, DE, AT. Clustered SEs at country level."
  ) +
  theme_apep()

ggsave("../figures/fig4_event_study_cross_country.pdf", p4, width = 9, height = 5.5)

# =============================================================
# Figure 5: Indeed Job Postings Around January 2023
# =============================================================
cat("Figure 5: Indeed job postings event study...\n")

# Focus on 2022-2024 window
indeed_window <- indeed_all %>%
  filter(date >= as.Date("2022-01-01") & date <= as.Date("2024-06-30")) %>%
  mutate(
    is_france = ifelse(country == "FR", "France", "Other EU"),
    week = floor_date(date, "week")
  )

# Check if postings_index column exists
if ("postings_index" %in% names(indeed_window)) {
  indeed_weekly <- indeed_window %>%
    group_by(is_france, week) %>%
    summarize(postings = mean(postings_index, na.rm = TRUE), .groups = "drop")

  p5 <- ggplot(indeed_weekly, aes(x = week, y = postings, color = is_france)) +
    geom_line(linewidth = 0.6, alpha = 0.8) +
    geom_vline(xintercept = as.Date("2023-01-01"), linetype = "dashed",
               color = "grey40") +
    annotate("text", x = as.Date("2023-01-15"), y = max(indeed_weekly$postings, na.rm = TRUE),
             label = "Subsidy Reduced\n(Jan 2023)", hjust = 0, size = 3, color = "grey40") +
    scale_color_manual(values = c("France" = apep_colors[1], "Other EU" = apep_colors[2])) +
    labs(
      title = "Indeed Job Postings: France vs. EU Countries",
      subtitle = "Weekly average, seasonally adjusted (Feb 2020 = 100)",
      x = NULL,
      y = "Job Postings Index",
      color = NULL,
      caption = "Source: Indeed Hiring Lab. Other EU = DE, ES, IT, NL, GB."
    ) +
    theme_apep()
} else {
  # Fallback: use whatever numeric column exists
  num_cols <- names(indeed_window)[sapply(indeed_window, is.numeric)]
  indeed_window$postings <- indeed_window[[num_cols[1]]]

  indeed_weekly <- indeed_window %>%
    group_by(is_france, week = floor_date(date, "week")) %>%
    summarize(postings = mean(postings, na.rm = TRUE), .groups = "drop")

  p5 <- ggplot(indeed_weekly, aes(x = week, y = postings, color = is_france)) +
    geom_line(linewidth = 0.6, alpha = 0.8) +
    geom_vline(xintercept = as.Date("2023-01-01"), linetype = "dashed", color = "grey40") +
    scale_color_manual(values = c("France" = apep_colors[1], "Other EU" = apep_colors[2])) +
    labs(title = "Indeed Job Postings: France vs. EU Countries",
         x = NULL, y = "Job Postings Index", color = NULL) +
    theme_apep()
}

ggsave("../figures/fig5_indeed_postings.pdf", p5, width = 9, height = 5.5)

# =============================================================
# Figure 6: Leave-One-Sector-Out Sensitivity
# =============================================================
cat("Figure 6: Leave-one-sector-out...\n")

if (nrow(loso) > 0) {
  # Get the main estimate for reference
  main_coef <- coef(models$bartik_youth_share)["bartik_reduction"]

  p6 <- ggplot(loso, aes(x = reorder(excluded_sector, coef), y = coef)) +
    geom_point(size = 3, color = apep_colors[1]) +
    geom_errorbar(aes(ymin = coef - 1.96 * se, ymax = coef + 1.96 * se),
                  width = 0.2, color = apep_colors[1]) +
    geom_hline(yintercept = main_coef, linetype = "dashed", color = apep_colors[2]) +
    geom_hline(yintercept = 0, linetype = "solid", color = "grey70") +
    coord_flip() +
    labs(
      title = "Leave-One-Sector-Out: Bartik DiD Sensitivity",
      subtitle = "Each point excludes one NACE sector; dashed line = full-sample estimate",
      x = "Excluded Sector",
      y = "Bartik DiD Coefficient",
      caption = "Note: 95% CIs shown. Clustering at sector level."
    ) +
    theme_apep()

  ggsave("../figures/fig6_loso.pdf", p6, width = 8, height = 6)
}

# =============================================================
# Figure 7: Permutation Inference Distribution
# =============================================================
cat("Figure 7: Permutation inference...\n")

perm_df <- tibble(stat = ri_results$perms)

p7 <- ggplot(perm_df, aes(x = stat)) +
  geom_histogram(bins = 50, fill = "grey70", color = "white") +
  geom_vline(xintercept = ri_results$obs, color = apep_colors[1],
             linewidth = 1, linetype = "dashed") +
  geom_vline(xintercept = -ri_results$obs, color = apep_colors[1],
             linewidth = 1, linetype = "dashed") +
  annotate("text", x = ri_results$obs, y = Inf,
           label = sprintf("Observed\n(p = %.3f)", ri_results$p),
           hjust = -0.1, vjust = 1.5, size = 3.5, color = apep_colors[1]) +
  labs(
    title = "Randomization Inference: Permuted Sector Exposure",
    subtitle = sprintf("Distribution of %d permuted test statistics", length(ri_results$perms)),
    x = "Bartik DiD Coefficient",
    y = "Frequency",
    caption = "Note: Dashed lines show observed test statistic. Two-sided p-value."
  ) +
  theme_apep()

ggsave("../figures/fig7_permutation.pdf", p7, width = 8, height = 5)

# =============================================================
# Figure 8: Dose-Response (Exposure Quintiles)
# =============================================================
cat("Figure 8: Dose-response...\n")

dose_model <- readRDS("../data/dose_response.rds")

dose_coefs <- as.data.frame(coeftable(dose_model)) %>%
  rownames_to_column("term") %>%
  filter(grepl("exposure_quintile", term)) %>%
  mutate(
    quintile = as.numeric(gsub(".*::(\\d).*", "\\1", term)),
    estimate = Estimate,
    se = `Std. Error`
  ) %>%
  bind_rows(tibble(quintile = 1, estimate = 0, se = 0))

p8 <- ggplot(dose_coefs, aes(x = quintile, y = estimate)) +
  geom_point(size = 3, color = apep_colors[1]) +
  geom_errorbar(aes(ymin = estimate - 1.96 * se, ymax = estimate + 1.96 * se),
                width = 0.15, color = apep_colors[1]) +
  geom_line(color = apep_colors[1], linewidth = 0.6, linetype = "dotted") +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
  scale_x_continuous(breaks = 1:5, labels = paste0("Q", 1:5)) +
  labs(
    title = "Dose-Response: Effect by Apprenticeship Exposure Quintile",
    subtitle = "Reference: Q1 (lowest exposure). Post-reduction interaction.",
    x = "Apprenticeship Exposure Quintile",
    y = "Effect on Youth Employment Share (pp)",
    caption = "Note: Q1 = lowest exposure, Q5 = highest. 95% CIs shown."
  ) +
  theme_apep()

ggsave("../figures/fig8_dose_response.pdf", p8, width = 8, height = 5)

cat("\n=== All figures generated ===\n")
cat("Figures saved to ../figures/\n")
