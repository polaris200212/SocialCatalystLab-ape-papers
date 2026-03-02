## 05_figures.R — All figure generation
## APEP-0310: Workers' Compensation and Industrial Safety

source("code/00_packages.R")

ipums_analysis <- fread(file.path(DATA_DIR, "ipums_analysis.csv"))
state_covs     <- fread(file.path(DATA_DIR, "state_covariates_1910.csv"))
wc_dates       <- fread(file.path(DATA_DIR, "workers_comp_dates.csv"))

# Load results (newspaper or IPUMS-only)
if (file.exists(file.path(DATA_DIR, "main_results.rds"))) {
  results <- readRDS(file.path(DATA_DIR, "main_results.rds"))
} else {
  results <- readRDS(file.path(DATA_DIR, "ipums_results.rds"))
}

# =============================================================================
# FIGURE 1: Workers' Compensation Adoption Timeline
# =============================================================================

adoption_by_year <- wc_dates[adoption_year <= 1925, .(n = .N), by = adoption_year]
adoption_by_year[, cumulative := cumsum(n)]

fig1 <- ggplot(adoption_by_year, aes(x = adoption_year)) +
  geom_col(aes(y = n), fill = "#2C5F8A", alpha = 0.7, width = 0.7) +
  geom_line(aes(y = cumulative / 2), color = "#C44E52", linewidth = 1) +
  geom_point(aes(y = cumulative / 2), color = "#C44E52", size = 2) +
  scale_y_continuous(
    "Number of States Adopting",
    sec.axis = sec_axis(~ . * 2, name = "Cumulative States")
  ) +
  scale_x_continuous(breaks = 1911:1925) +
  labs(
    title = "Staggered Adoption of Workers' Compensation Laws",
    subtitle = "States adopting by year (bars) and cumulative total (line)",
    x = "Year"
  ) +
  annotate("text", x = 1911.5, y = 9, label = "9 states\n(incl. WI, CA, IL)",
           size = 3, hjust = 0, color = "gray30") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

ggsave(file.path(FIG_DIR, "fig1_adoption_timeline.pdf"),
       fig1, width = 8, height = 5)
cat("Figure 1 saved\n")

# =============================================================================
# FIGURE 2: Newspaper Accident Coverage Over Time (by Adoption Cohort)
# =============================================================================

news_clean_file <- file.path(DATA_DIR, "newspaper_clean.csv")
if (file.exists(news_clean_file)) {
  news_clean <- fread(news_clean_file)

  cohort_trends <- news_clean[!is.na(cohort) & !is.na(accident_index), .(
    mean_index = mean(accident_index, na.rm = TRUE),
    se_index = sd(accident_index, na.rm = TRUE) / sqrt(.N)
  ), by = .(year, cohort)]

  fig2 <- ggplot(cohort_trends, aes(x = year, y = mean_index, color = cohort)) +
    geom_line(linewidth = 0.8) +
    geom_point(size = 1.5) +
    geom_ribbon(aes(ymin = mean_index - 1.96 * se_index,
                    ymax = mean_index + 1.96 * se_index, fill = cohort),
                alpha = 0.15, color = NA) +
    geom_vline(xintercept = c(1911, 1915), linetype = "dashed", alpha = 0.5) +
    annotate("text", x = 1911, y = max(cohort_trends$mean_index, na.rm = TRUE) * 0.95,
             label = "First adoptions\n(1911)", size = 3, hjust = -0.1) +
    scale_color_manual(values = c("#2C5F8A", "#55A868", "#C44E52", "#8172B3")) +
    scale_fill_manual(values = c("#2C5F8A", "#55A868", "#C44E52", "#8172B3")) +
    labs(
      title = "Newspaper Coverage of Industrial Accidents by Adoption Cohort",
      subtitle = "Accident-related pages per 1,000 total newspaper pages",
      x = "Year", y = "Accident Coverage Index",
      color = "Adoption Cohort", fill = "Adoption Cohort"
    )

  ggsave(file.path(FIG_DIR, "fig2_accident_trends.pdf"),
         fig2, width = 9, height = 6)
  cat("Figure 2 saved\n")
} else {
  cat("Skipping Figure 2 (newspaper data not yet available)\n")
}

# =============================================================================
# FIGURE 3: Event Study — Newspaper Accident Coverage (DR Estimates)
# =============================================================================

if (!is.null(results$es_result)) {
  es_result <- results$es_result

  es_data <- data.table(
    rel_time = es_result$egt,
    att = es_result$att.egt,
    se = es_result$se.egt
  )
  es_data[, `:=`(
    ci_lower = att - 1.96 * se,
    ci_upper = att + 1.96 * se
  )]

  fig3 <- ggplot(es_data, aes(x = rel_time, y = att)) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
    geom_vline(xintercept = -0.5, linetype = "dashed", color = "gray70") +
    geom_ribbon(aes(ymin = ci_lower, ymax = ci_upper), alpha = 0.2, fill = "#2C5F8A") +
    geom_line(color = "#2C5F8A", linewidth = 0.8) +
    geom_point(color = "#2C5F8A", size = 2.5) +
    labs(
      title = "Event Study: Workers' Compensation and Newspaper Accident Coverage",
      subtitle = "DR/AIPW estimates from Callaway & Sant'Anna (2021)",
      x = "Years Relative to Workers' Comp Adoption",
      y = "ATT (Accident Coverage Index)"
    ) +
    annotate("text", x = -4, y = max(es_data$ci_upper, na.rm = TRUE) * 0.9,
             label = "Pre-treatment", size = 3.5, color = "gray40") +
    annotate("text", x = 4, y = max(es_data$ci_upper, na.rm = TRUE) * 0.9,
             label = "Post-treatment", size = 3.5, color = "gray40")

  ggsave(file.path(FIG_DIR, "fig3_event_study.pdf"),
         fig3, width = 8, height = 5.5)
  cat("Figure 3 saved\n")
} else {
  cat("Skipping Figure 3 (event study not yet available)\n")
}

# =============================================================================
# FIGURE 4: Occupational Distribution (1910 vs 1920, Treated vs Control)
# =============================================================================

occ_dist <- ipums_analysis[, .(
  pct = weighted.mean(dangerous_occ, PERWT, na.rm = TRUE) * 100
), by = .(YEAR, treat_status = fifelse(
  !is.na(adoption_year) & adoption_year <= 1920, "Treated States", "Control States"
))]

fig4 <- ggplot(occ_dist, aes(x = factor(YEAR), y = pct, fill = treat_status)) +
  geom_col(position = position_dodge(width = 0.7), width = 0.6) +
  scale_fill_manual(values = c("Control States" = "#8172B3", "Treated States" = "#2C5F8A")) +
  labs(
    title = "Share of Workers in Dangerous Occupations",
    subtitle = "Treated states (adopted workers' comp by 1920) vs. control states",
    x = "Census Year", y = "Percentage in Dangerous Occupations",
    fill = ""
  ) +
  scale_y_continuous(labels = function(x) paste0(x, "%"))

ggsave(file.path(FIG_DIR, "fig4_occupation_shares.pdf"),
       fig4, width = 7, height = 5)
cat("Figure 4 saved\n")

# =============================================================================
# FIGURE 5: Propensity Score Overlap (DR Diagnostic)
# =============================================================================

ps_data <- state_covs[!is.na(adoption_year)]
ps_data[, treated := fifelse(adoption_year <= 1915, 1L, 0L)]
ps_data[, log_pop := log(pop_1910)]

ps_model <- glm(treated ~ pct_urban_1910 + pct_manufacturing_1910 +
                   pct_mining_1910 + pct_foreign_1910 + log_pop,
                 data = ps_data, family = binomial)
ps_data[, pscore := predict(ps_model, type = "response")]

fig5 <- ggplot(ps_data, aes(x = pscore, fill = factor(treated))) +
  geom_density(alpha = 0.5) +
  scale_fill_manual(
    values = c("0" = "#C44E52", "1" = "#2C5F8A"),
    labels = c("Late Adopters (1916+)", "Early Adopters (\u22641915)")
  ) +
  labs(
    title = "Propensity Score Overlap: Early vs. Late Workers' Comp Adoption",
    subtitle = "Covariates: urbanization, manufacturing, mining, foreign-born share, population",
    x = "Estimated Propensity Score",
    y = "Density",
    fill = ""
  )

ggsave(file.path(FIG_DIR, "fig5_pscore_overlap.pdf"),
       fig5, width = 7, height = 5)
cat("Figure 5 saved\n")

# =============================================================================
# FIGURE 6: Sensitivity Analysis Contour Plot
# =============================================================================

if (file.exists(file.path(DATA_DIR, "sensitivity_results.rds"))) {
  sens <- readRDS(file.path(DATA_DIR, "sensitivity_results.rds"))

  pdf(file.path(FIG_DIR, "fig6_sensitivity.pdf"), width = 7, height = 6)
  plot(sens,
       main = "Sensitivity to Unobserved Confounders",
       sub = "Contour plot: partial R-squared of confounder with treatment and outcome")
  dev.off()
  cat("Figure 6 saved\n")
}

# =============================================================================
# FIGURE 7: Map of Workers' Comp Adoption Year
# =============================================================================

tryCatch({
  library(maps)
  us_states <- map_data("state")

  wc_map <- wc_dates[, .(state_name_lower = tolower(state_name), adoption_year)]

  map_data_merged <- merge(us_states, wc_map,
                           by.x = "region", by.y = "state_name_lower", all.x = TRUE)

  fig7 <- ggplot(map_data_merged, aes(x = long, y = lat, group = group,
                                       fill = adoption_year)) +
    geom_polygon(color = "white", linewidth = 0.2) +
    scale_fill_viridis_c(
      option = "D", direction = -1,
      breaks = c(1911, 1915, 1920, 1930, 1940),
      labels = c("1911", "1915", "1920", "1930", "1940+"),
      na.value = "gray80"
    ) +
    coord_map("polyconic") +
    labs(
      title = "Workers' Compensation Law Adoption by State",
      fill = "Year\nAdopted"
    ) +
    theme_void() +
    theme(
      plot.title = element_text(face = "bold", size = 14, hjust = 0.5),
      legend.position = "right"
    )

  ggsave(file.path(FIG_DIR, "fig7_adoption_map.pdf"),
         fig7, width = 9, height = 6)
  cat("Figure 7 saved\n")
}, error = function(e) cat("Map figure failed:", e$message, "\n"))

cat("\n=== All figures generated ===\n")
