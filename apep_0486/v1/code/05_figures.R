## 05_figures.R — Generate all figures
## apep_0486: Progressive Prosecutors, Incarceration, and Public Safety

source("00_packages.R")

panel <- fread(file.path(DATA_DIR, "analysis_panel.csv"))
panel[, fips := str_pad(as.character(fips), width = 5, pad = "0")]

cat("=== FIGURE 1: Event Study — Jail Population Rate ===\n")

es_jail <- tryCatch(fread(file.path(DATA_DIR, "es_jail_rate.csv")), error = function(e) NULL)

if (!is.null(es_jail) && nrow(es_jail) > 0) {
  fig1 <- ggplot(es_jail, aes(x = event_time, y = att)) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
    geom_vline(xintercept = -0.5, linetype = "dotted", color = "gray70") +
    geom_ribbon(aes(ymin = ci_lower, ymax = ci_upper),
                fill = APEP_COLORS["ci"], alpha = 0.4) +
    geom_point(color = APEP_COLORS["treated"], size = 2.5) +
    geom_line(color = APEP_COLORS["treated"], linewidth = 0.8) +
    labs(
      title = "Effect of Progressive DA Election on County Jail Population Rate",
      subtitle = "Callaway-Sant'Anna (2021) event study estimates",
      x = "Years Relative to DA Taking Office",
      y = "ATT (Jail Population per 100,000)"
    ) +
    scale_x_continuous(breaks = seq(-8, 6, 2)) +
    annotate("text", x = -6, y = max(es_jail$ci_upper, na.rm = TRUE) * 0.9,
             label = "Pre-treatment", hjust = 0, color = "gray40", size = 3.5) +
    annotate("text", x = 2, y = max(es_jail$ci_upper, na.rm = TRUE) * 0.9,
             label = "Post-treatment", hjust = 0, color = "gray40", size = 3.5)

  ggsave(file.path(FIGURE_DIR, "fig1_event_study_jail.pdf"),
         fig1, width = 8, height = 5)
  cat("Figure 1 saved\n")
} else {
  cat("No event study data for jail rate — generating from TWFE\n")

  # Fallback: TWFE event study
  panel[, rel_time := fifelse(treatment_year > 0, year - treatment_year, NA_integer_)]
  es_data <- panel[!is.na(jail_rate) & !is.na(rel_time) & abs(rel_time) <= 8]
  es_data[, rel_time_f := factor(pmin(pmax(rel_time, -8L), 6L))]

  es_mod <- feols(
    jail_rate ~ i(rel_time_f, ref = "-1") | fips + year,
    data = es_data,
    cluster = ~state_fips
  )

  es_df <- as.data.frame(coeftable(es_mod))
  es_df$event_time <- as.numeric(gsub("rel_time_f::", "", rownames(es_df)))
  es_df$ci_lower <- es_df$Estimate - 1.96 * es_df$`Std. Error`
  es_df$ci_upper <- es_df$Estimate + 1.96 * es_df$`Std. Error`

  # Add reference period
  ref <- data.frame(event_time = -1, Estimate = 0, ci_lower = 0, ci_upper = 0)
  names(ref) <- names(es_df)[c(ncol(es_df), 1, ncol(es_df)-1, ncol(es_df))]

  fig1 <- ggplot(es_df, aes(x = event_time, y = Estimate)) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
    geom_vline(xintercept = -0.5, linetype = "dotted", color = "gray70") +
    geom_ribbon(aes(ymin = ci_lower, ymax = ci_upper),
                fill = APEP_COLORS["ci"], alpha = 0.4) +
    geom_point(color = APEP_COLORS["treated"], size = 2.5) +
    geom_line(color = APEP_COLORS["treated"], linewidth = 0.8) +
    labs(
      title = "Effect of Progressive DA Election on County Jail Population Rate",
      subtitle = "TWFE event study with county and year fixed effects",
      x = "Years Relative to DA Taking Office",
      y = "Change in Jail Population per 100,000"
    ) +
    scale_x_continuous(breaks = seq(-8, 6, 2))

  ggsave(file.path(FIGURE_DIR, "fig1_event_study_jail.pdf"),
         fig1, width = 8, height = 5)
  cat("Figure 1 (TWFE fallback) saved\n")
}

cat("\n=== FIGURE 2: Event Study — Homicide Rate ===\n")

es_hom <- tryCatch(fread(file.path(DATA_DIR, "es_homicide_rate.csv")), error = function(e) NULL)

if (!is.null(es_hom) && nrow(es_hom) > 0) {
  fig2 <- ggplot(es_hom, aes(x = event_time, y = att)) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
    geom_vline(xintercept = -0.5, linetype = "dotted", color = "gray70") +
    geom_ribbon(aes(ymin = ci_lower, ymax = ci_upper),
                fill = APEP_COLORS["ci"], alpha = 0.4) +
    geom_point(color = APEP_COLORS["control"], size = 2.5) +
    geom_line(color = APEP_COLORS["control"], linewidth = 0.8) +
    labs(
      title = "Effect of Progressive DA Election on Homicide Mortality Rate",
      subtitle = "Callaway-Sant'Anna (2021) event study estimates",
      x = "Years Relative to DA Taking Office",
      y = "ATT (Homicides per 100,000)"
    ) +
    scale_x_continuous(breaks = seq(-8, 6, 2))

  ggsave(file.path(FIGURE_DIR, "fig2_event_study_homicide.pdf"),
         fig2, width = 8, height = 5)
  cat("Figure 2 saved\n")
}

cat("\n=== FIGURE 3: Mechanism — Pretrial vs Sentenced ===\n")

es_pre <- tryCatch(fread(file.path(DATA_DIR, "es_pretrial_rate.csv")), error = function(e) NULL)

if (!is.null(es_pre) && nrow(es_pre) > 0 && !is.null(es_jail) && nrow(es_jail) > 0) {
  # Combine pretrial and total jail ES for comparison
  es_pre$component <- "Pretrial"
  es_jail_copy <- es_jail
  es_jail_copy$component <- "Total Jail"

  combined <- rbind(
    es_pre[, .(event_time, att, ci_lower, ci_upper, component)],
    es_jail_copy[, .(event_time, att, ci_lower, ci_upper, component)]
  )

  fig3 <- ggplot(combined, aes(x = event_time, y = att, color = component, fill = component)) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
    geom_vline(xintercept = -0.5, linetype = "dotted", color = "gray70") +
    geom_ribbon(aes(ymin = ci_lower, ymax = ci_upper), alpha = 0.15, color = NA) +
    geom_point(size = 2) +
    geom_line(linewidth = 0.7) +
    scale_color_manual(values = c("Pretrial" = APEP_COLORS["pretrial"],
                                   "Total Jail" = APEP_COLORS["treated"])) +
    scale_fill_manual(values = c("Pretrial" = APEP_COLORS["pretrial"],
                                  "Total Jail" = APEP_COLORS["treated"])) +
    labs(
      title = "Mechanism: Pretrial vs. Total Jail Population",
      subtitle = "CS-DiD event study estimates",
      x = "Years Relative to DA Taking Office",
      y = "ATT (per 100,000)"
    ) +
    scale_x_continuous(breaks = seq(-8, 6, 2))

  ggsave(file.path(FIGURE_DIR, "fig3_mechanism_pretrial.pdf"),
         fig3, width = 8, height = 5)
  cat("Figure 3 saved\n")
}

cat("\n=== FIGURE 4: Raw Trends — Treated vs Control ===\n")

# Average jail rate by treatment status over time
trends <- panel[!is.na(jail_rate), .(
  mean_jail = mean(jail_rate, na.rm = TRUE),
  se_jail = sd(jail_rate, na.rm = TRUE) / sqrt(.N),
  n = .N
), by = .(year, ever_treated)]

trends[, group := fifelse(ever_treated == 1, "Progressive DA Counties", "Other Counties")]

fig4 <- ggplot(trends, aes(x = year, y = mean_jail, color = group)) +
  geom_line(linewidth = 1) +
  geom_point(size = 1.5) +
  geom_ribbon(aes(ymin = mean_jail - 1.96 * se_jail,
                  ymax = mean_jail + 1.96 * se_jail,
                  fill = group), alpha = 0.1, color = NA) +
  scale_color_manual(values = c("Progressive DA Counties" = APEP_COLORS["treated"],
                                 "Other Counties" = APEP_COLORS["control"])) +
  scale_fill_manual(values = c("Progressive DA Counties" = APEP_COLORS["treated"],
                                "Other Counties" = APEP_COLORS["control"])) +
  labs(
    title = "Average Jail Population Rate: Progressive DA vs. Other Counties",
    subtitle = "County-level jail population per 100,000 working-age residents",
    x = "Year",
    y = "Mean Jail Population Rate (per 100,000)"
  ) +
  scale_x_continuous(breaks = seq(2005, 2023, 2))

ggsave(file.path(FIGURE_DIR, "fig4_raw_trends.pdf"),
       fig4, width = 8, height = 5)
cat("Figure 4 saved\n")

cat("\n=== FIGURE 5: Black-White Jail Rate Gap ===\n")

bw_trends <- panel[!is.na(black_jail_rate) & !is.na(white_jail_rate), .(
  mean_black = mean(black_jail_rate, na.rm = TRUE),
  mean_white = mean(white_jail_rate, na.rm = TRUE),
  mean_ratio = mean(black_jail_rate / white_jail_rate, na.rm = TRUE)
), by = .(year, ever_treated)]

bw_trends[, group := fifelse(ever_treated == 1, "Progressive DA Counties", "Other Counties")]

# Reshape for plotting
bw_long <- melt(bw_trends, id.vars = c("year", "group", "ever_treated"),
                measure.vars = c("mean_black", "mean_white"),
                variable.name = "race", value.name = "jail_rate")
bw_long[, race := fifelse(race == "mean_black", "Black", "White")]

fig5 <- ggplot(bw_long, aes(x = year, y = jail_rate, color = race, linetype = group)) +
  geom_line(linewidth = 0.9) +
  geom_point(size = 1.5) +
  scale_color_manual(values = c("Black" = APEP_COLORS["black"],
                                 "White" = APEP_COLORS["white"])) +
  labs(
    title = "Black and White Jail Population Rates by DA Type",
    subtitle = "County-level rates per 100,000 working-age population",
    x = "Year",
    y = "Mean Jail Population Rate (per 100,000)",
    color = "Race",
    linetype = "County Type"
  ) +
  scale_x_continuous(breaks = seq(2005, 2023, 2))

ggsave(file.path(FIGURE_DIR, "fig5_bw_jail_rates.pdf"),
       fig5, width = 9, height = 5.5)
cat("Figure 5 saved\n")

cat("\n=== FIGURE 6: Leave-One-Out Influence ===\n")

loo <- tryCatch(fread(file.path(DATA_DIR, "loo_results.csv")), error = function(e) NULL)
if (!is.null(loo) && nrow(loo) > 0) {
  # Add the full-sample estimate
  results <- readRDS(file.path(DATA_DIR, "main_results.rds"))
  full_coef <- coef(results$twfe_jail)["treated"]
  full_se <- se(results$twfe_jail)["treated"]

  loo$dropped <- factor(loo$dropped, levels = rev(loo$dropped))

  fig6 <- ggplot(loo, aes(x = coef, y = dropped)) +
    geom_vline(xintercept = full_coef, linetype = "dashed", color = APEP_COLORS["treated"]) +
    geom_vline(xintercept = 0, linetype = "solid", color = "gray70") +
    geom_errorbarh(aes(xmin = coef - 1.96 * se, xmax = coef + 1.96 * se),
                   height = 0.2, color = APEP_COLORS["control"]) +
    geom_point(size = 3, color = APEP_COLORS["control"]) +
    labs(
      title = "Leave-One-Out Influence Analysis",
      subtitle = paste0("Full sample estimate: ", round(full_coef, 1),
                        ". Dashed line = full sample."),
      x = "TWFE Coefficient (Jail Rate per 100,000)",
      y = "Dropped County"
    )

  ggsave(file.path(FIGURE_DIR, "fig6_loo_influence.pdf"),
         fig6, width = 7, height = 4)
  cat("Figure 6 saved\n")
}

cat("\n=== FIGURE 7: Treatment Timing Map ===\n")

treatment <- fread(file.path(DATA_DIR, "progressive_da_treatment.csv"))
treatment[, fips := str_pad(as.character(fips), width = 5, pad = "0")]

fig7 <- ggplot(treatment, aes(x = treatment_year, y = reorder(county_name, -treatment_year))) +
  geom_point(size = 3, color = APEP_COLORS["treated"]) +
  geom_segment(aes(xend = 2024, yend = county_name),
               color = APEP_COLORS["treated"], alpha = 0.3) +
  labs(
    title = "Progressive DA Election Timeline",
    subtitle = "Treatment onset year for each county",
    x = "Year DA Took Office",
    y = NULL
  ) +
  scale_x_continuous(breaks = seq(2015, 2023, 1)) +
  theme(axis.text.y = element_text(size = 8))

ggsave(file.path(FIGURE_DIR, "fig7_treatment_timing.pdf"),
       fig7, width = 7, height = 7)
cat("Figure 7 saved\n")

cat("\n=== FIGURES COMPLETE ===\n")
cat("Files in figures directory:\n")
cat(paste(list.files(FIGURE_DIR), collapse = "\n"), "\n")
