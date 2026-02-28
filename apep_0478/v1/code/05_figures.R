# =============================================================================
# 05_figures.R — Going Up Alone (apep_0478)
# Generate all figures for the paper
# =============================================================================

source("00_packages.R")

cat("\n========================================\n")
cat("GENERATING FIGURES\n")
cat("========================================\n\n")

# Load data
national    <- fread(file.path(DATA_DIR, "national_clean.csv"))
state_panel <- fread(file.path(DATA_DIR, "scm_panel.csv"))
linked      <- fread(file.path(DATA_DIR, "linked_panel_clean.csv"))
trans_matrix <- fread(file.path(DATA_DIR, "transition_matrix.csv"))
trans_race  <- fread(file.path(DATA_DIR, "transition_by_race.csv"))
trans_sex   <- fread(file.path(DATA_DIR, "transition_by_sex.csv"))
trans_age   <- fread(file.path(DATA_DIR, "transition_by_age.csv"))
trans_city  <- fread(file.path(DATA_DIR, "transition_by_city.csv"))

# ─────────────────────────────────────────────────────────────────────────────
# Figure 1: Rise and Fall — National Elevator Operator Count (1900-1950)
# ─────────────────────────────────────────────────────────────────────────────

cat("Figure 1: National time series...\n")

p1 <- ggplot(national, aes(x = year, y = n_elevator_ops / 1000)) +
  geom_line(linewidth = 1.2, color = apep_colors[1]) +
  geom_point(size = 3.5, color = apep_colors[1]) +
  geom_text(aes(label = format(n_elevator_ops, big.mark = ",")),
            vjust = -1.2, size = 3.2, fontface = "bold") +
  annotate("rect", xmin = 1944, xmax = 1946, ymin = -Inf, ymax = Inf,
           alpha = 0.15, fill = "red") +
  annotate("text", x = 1945, y = max(national$n_elevator_ops) / 1000 * 0.3,
           label = "1945 Strike", angle = 90, color = "red", size = 3, fontface = "italic") +
  scale_x_continuous(breaks = seq(1900, 1950, 10)) +
  scale_y_continuous(labels = label_comma()) +
  labs(
    title = "The Rise and Fall of the Elevator Operator",
    subtitle = "Total elevator operators in the United States, 1900-1950",
    x = NULL, y = "Elevator operators (thousands)",
    caption = "Source: IPUMS Full-Count Census, 1900-1950. OCC1950 = 761."
  ) +
  theme_apep()

ggsave(file.path(FIG_DIR, "fig1_national_timeseries.pdf"), p1,
       width = 8, height = 5.5)

# ─────────────────────────────────────────────────────────────────────────────
# Figure 2: Comparison with Other Building Service Occupations
# ─────────────────────────────────────────────────────────────────────────────

cat("Figure 2: Comparison occupations...\n")

comp_data <- national[, .(year,
                          `Elevator operators` = elev_per_10k_emp,
                          `Janitors` = janitor_per_10k_emp,
                          `Porters` = porter_per_10k_emp,
                          `Guards` = guard_per_10k_emp)]
comp_long <- melt(comp_data, id.vars = "year",
                  variable.name = "Occupation", value.name = "per_10k")

p2 <- ggplot(comp_long, aes(x = year, y = per_10k, color = Occupation)) +
  geom_line(linewidth = 1) +
  geom_point(size = 2.5) +
  annotate("rect", xmin = 1944, xmax = 1946, ymin = -Inf, ymax = Inf,
           alpha = 0.1, fill = "red") +
  scale_color_manual(values = apep_colors[1:4]) +
  scale_x_continuous(breaks = seq(1900, 1950, 10)) +
  labs(
    title = "Building Service Occupations, 1900-1950",
    subtitle = "Workers per 10,000 employed. Only elevator operators declined.",
    x = NULL, y = "Workers per 10,000 employed",
    caption = "Source: IPUMS Full-Count Census."
  ) +
  theme_apep() +
  theme(legend.position = c(0.2, 0.85))

ggsave(file.path(FIG_DIR, "fig2_comparison_occupations.pdf"), p2,
       width = 8, height = 5.5)

# ─────────────────────────────────────────────────────────────────────────────
# Figure 3: Demographic Transformation — Sex and Race
# ─────────────────────────────────────────────────────────────────────────────

cat("Figure 3: Demographics...\n")

demo_data <- national[, .(year, pct_female, pct_black)]
demo_long <- melt(demo_data, id.vars = "year",
                  variable.name = "demographic", value.name = "percent")
demo_long[, demographic := fifelse(demographic == "pct_female",
                                    "Female (%)", "Black (%)")]

p3 <- ggplot(demo_long, aes(x = year, y = percent, color = demographic)) +
  geom_line(linewidth = 1.1) +
  geom_point(size = 3) +
  scale_color_manual(values = c(apep_colors[2], apep_colors[3]),
                     name = NULL) +
  scale_x_continuous(breaks = seq(1900, 1950, 10)) +
  labs(
    title = "The Changing Face of the Elevator Operator",
    subtitle = "Share female and share Black among all elevator operators",
    x = NULL, y = "Percent",
    caption = "Source: IPUMS Full-Count Census, OCC1950 = 761."
  ) +
  theme_apep() +
  theme(legend.position = c(0.2, 0.85))

ggsave(file.path(FIG_DIR, "fig3_demographics.pdf"), p3,
       width = 8, height = 5.5)

# ─────────────────────────────────────────────────────────────────────────────
# Figure 4: Age Distribution Over Time (Aging Workforce)
# ─────────────────────────────────────────────────────────────────────────────

cat("Figure 4: Age distribution...\n")

age_data <- national[, .(year,
                          `Under 20` = pct_under20,
                          `20-29` = pct_20s,
                          `30-39` = pct_30s,
                          `40-49` = pct_40s,
                          `50-59` = pct_50s,
                          `60+` = pct_60plus)]
age_long <- melt(age_data, id.vars = "year",
                 variable.name = "age_group", value.name = "percent")
age_long[, age_group := factor(age_group,
                                levels = c("Under 20", "20-29", "30-39",
                                          "40-49", "50-59", "60+"))]

p4 <- ggplot(age_long, aes(x = year, y = percent, fill = age_group)) +
  geom_area(alpha = 0.85) +
  scale_fill_manual(values = rev(brewer.pal(6, "Blues")), name = "Age group") +
  scale_x_continuous(breaks = seq(1900, 1950, 10)) +
  labs(
    title = "An Aging Occupation",
    subtitle = "Age distribution of elevator operators, 1900-1950",
    x = NULL, y = "Share of all elevator operators (%)",
    caption = "Source: IPUMS Full-Count Census."
  ) +
  theme_apep() +
  theme(legend.position = "right")

ggsave(file.path(FIG_DIR, "fig4_age_distribution.pdf"), p4,
       width = 8, height = 5.5)

# ─────────────────────────────────────────────────────────────────────────────
# Figure 5: Geographic Concentration — Top States
# ─────────────────────────────────────────────────────────────────────────────

cat("Figure 5: Geographic concentration...\n")

# Top 5 states by operator count in 1940
top_states <- state_panel[year == 1940 & !is.na(state_name)]
setorder(top_states, -n_elevator_ops)
top5_names <- head(top_states$state_name, 5)

state_top5 <- state_panel[state_name %in% top5_names]

p5 <- ggplot(state_top5, aes(x = year, y = n_elevator_ops / 1000,
                              color = state_name)) +
  geom_line(linewidth = 1) +
  geom_point(size = 2.5) +
  annotate("rect", xmin = 1944, xmax = 1946, ymin = -Inf, ymax = Inf,
           alpha = 0.1, fill = "red") +
  scale_color_manual(values = apep_colors[1:5], name = "State") +
  scale_x_continuous(breaks = seq(1900, 1950, 10)) +
  labs(
    title = "New York's Outsized Share",
    subtitle = "Elevator operators by state, top 5 states",
    x = NULL, y = "Elevator operators (thousands)",
    caption = "Source: IPUMS Full-Count Census."
  ) +
  theme_apep() +
  theme(legend.position = c(0.15, 0.75))

ggsave(file.path(FIG_DIR, "fig5_geographic.pdf"), p5,
       width = 8, height = 5.5)

# ─────────────────────────────────────────────────────────────────────────────
# Figure 6: SCM — NYC vs Synthetic NYC
# ─────────────────────────────────────────────────────────────────────────────

cat("Figure 6: SCM results...\n")

if (file.exists(file.path(DATA_DIR, "scm_results.rds"))) {
  scm_res <- readRDS(file.path(DATA_DIR, "scm_results.rds"))

  if ("gap" %in% names(scm_res)) {
    gap_df <- as.data.table(scm_res$gap)

    # Panel A: NYC vs Synthetic NYC
    gap_long <- melt(gap_df[, .(year, `NYC (actual)` = nyc_actual,
                                 `Synthetic NYC` = nyc_synthetic)],
                     id.vars = "year",
                     variable.name = "series", value.name = "value")

    p6a <- ggplot(gap_long, aes(x = year, y = value, color = series,
                                 linetype = series)) +
      geom_line(linewidth = 1.1) +
      geom_point(size = 3) +
      geom_vline(xintercept = 1945, linetype = "dashed", color = "grey50") +
      annotate("text", x = 1945, y = max(gap_long$value) * 0.9,
               label = "1945 Strike", hjust = -0.1, color = "grey40",
               size = 3, fontface = "italic") +
      scale_color_manual(values = c(apep_colors[1], apep_colors[2]),
                         name = NULL) +
      scale_linetype_manual(values = c("solid", "dashed"), name = NULL) +
      scale_x_continuous(breaks = seq(1900, 1950, 10)) +
      labs(
        title = "NYC vs. Synthetic NYC",
        subtitle = "Elevator operators per 1,000 building service workers",
        x = NULL, y = "Operators per 1,000 bldg. service workers"
      ) +
      theme_apep() +
      theme(legend.position = c(0.2, 0.85))

    # Panel B: Gap (treatment effect)
    p6b <- ggplot(gap_df, aes(x = year, y = gap)) +
      geom_line(linewidth = 1, color = apep_colors[1]) +
      geom_point(size = 3, color = apep_colors[1]) +
      geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
      geom_vline(xintercept = 1945, linetype = "dashed", color = "grey50") +
      scale_x_continuous(breaks = seq(1900, 1950, 10)) +
      labs(
        title = "Treatment Effect (Gap)",
        subtitle = "NYC actual minus synthetic NYC",
        x = NULL, y = "Gap"
      ) +
      theme_apep()

    p6 <- p6a / p6b +
      plot_annotation(
        title = "Breaking the Equilibrium: The 1945 Strike and Elevator Automation",
        caption = "Source: IPUMS Full-Count Census. SCM with permutation inference.",
        theme = theme_apep()
      )

    ggsave(file.path(FIG_DIR, "fig6_scm_results.pdf"), p6,
           width = 8, height = 10)
  }
}

# ─────────────────────────────────────────────────────────────────────────────
# Figure 7: Placebo Tests (Spaghetti Plot)
# ─────────────────────────────────────────────────────────────────────────────

cat("Figure 7: Placebo tests...\n")

if (file.exists(file.path(DATA_DIR, "placebo_gaps.csv")) &&
    file.exists(file.path(DATA_DIR, "scm_results.rds"))) {
  placebo_df <- fread(file.path(DATA_DIR, "placebo_gaps.csv"))
  scm_res <- readRDS(file.path(DATA_DIR, "scm_results.rds"))

  if ("gap" %in% names(scm_res)) {
    nyc_gap <- as.data.table(scm_res$gap)
    nyc_gap[, city_id := "NYC"]

    p7 <- ggplot() +
      geom_line(data = placebo_df,
                aes(x = year, y = gap, group = STATEFIP),
                color = "grey70", alpha = 0.5, linewidth = 0.4) +
      geom_line(data = nyc_gap,
                aes(x = year, y = gap),
                color = apep_colors[2], linewidth = 1.3) +
      geom_point(data = nyc_gap,
                 aes(x = year, y = gap),
                 color = apep_colors[2], size = 3) +
      geom_vline(xintercept = 1945, linetype = "dashed", color = "grey50") +
      geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
      scale_x_continuous(breaks = seq(1900, 1950, 10)) +
      labs(
        title = "Placebo Tests: New York is the Outlier",
        subtitle = "SCM gap for NY (red) vs. placebo gaps for donor states (grey)",
        x = NULL, y = "Gap (actual - synthetic)",
        caption = sprintf("NY p-value: %.3f (%d placebos)",
                          scm_res$p_value, scm_res$n_placebos)
      ) +
      theme_apep()

    ggsave(file.path(FIG_DIR, "fig7_placebo_spaghetti.pdf"), p7,
           width = 8, height = 6)
  }
}

# ─────────────────────────────────────────────────────────────────────────────
# Figure 8: Event Study
# ─────────────────────────────────────────────────────────────────────────────

cat("Figure 8: Event study...\n")

if (file.exists(file.path(DATA_DIR, "event_study_coefs.csv"))) {
  es_coefs <- fread(file.path(DATA_DIR, "event_study_coefs.csv"))

  # Add reference year (1940)
  ref_row <- data.table(Estimate = 0, `Std. Error` = 0,
                         `t value` = 0, `Pr(>|t|)` = 1, year = 1940)
  setnames(ref_row, names(es_coefs))
  es_coefs <- rbind(es_coefs, ref_row)

  # Confidence intervals
  es_coefs[, ci_lo := Estimate - 1.96 * `Std. Error`]
  es_coefs[, ci_hi := Estimate + 1.96 * `Std. Error`]

  p8 <- ggplot(es_coefs, aes(x = year, y = Estimate)) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
    geom_vline(xintercept = 1945, linetype = "dashed", color = "red",
               alpha = 0.5) +
    geom_ribbon(aes(ymin = ci_lo, ymax = ci_hi), alpha = 0.2,
                fill = apep_colors[3]) +
    geom_line(linewidth = 1, color = apep_colors[1]) +
    geom_point(size = 3, color = apep_colors[1]) +
    annotate("text", x = 1945, y = min(es_coefs$ci_lo) * 0.8,
             label = "1945 Strike", hjust = -0.1, color = "red",
             size = 3, fontface = "italic") +
    scale_x_continuous(breaks = seq(1900, 1950, 10)) +
    labs(
      title = "Event Study: NYC Elevator Operators Relative to Comparison Cities",
      subtitle = "Coefficients from year × NYC interaction. Reference year: 1940.",
      x = NULL, y = "Operators per 10,000 pop.\n(relative to 1940)",
      caption = "95% CI shown. Source: IPUMS Full-Count Census."
    ) +
    theme_apep()

  ggsave(file.path(FIG_DIR, "fig8_event_study.pdf"), p8,
         width = 8, height = 5.5)
}

# ─────────────────────────────────────────────────────────────────────────────
# Figure 9: Transition Matrix — Where Did They Go?
# ─────────────────────────────────────────────────────────────────────────────

cat("Figure 9: Transition matrix...\n")

# Keep top categories
trans_matrix[, occ_broad_1950 := factor(occ_broad_1950,
  levels = trans_matrix[order(-N)]$occ_broad_1950)]

p9 <- ggplot(trans_matrix, aes(x = reorder(occ_broad_1950, -pct), y = pct)) +
  geom_col(fill = apep_colors[1], alpha = 0.85) +
  geom_text(aes(label = sprintf("%.1f%%", pct)),
            vjust = -0.3, size = 3) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.15))) +
  labs(
    title = "Where Did the Elevator Operators Go?",
    subtitle = "1950 occupation of individuals who were elevator operators in 1940",
    x = NULL, y = "Percent of 1940 elevator operators",
    caption = "Source: IPUMS Full-Count Census + MLP v2.0 linked panel."
  ) +
  theme_apep() +
  theme(axis.text.x = element_text(angle = 35, hjust = 1, size = 9))

ggsave(file.path(FIG_DIR, "fig9_transition_matrix.pdf"), p9,
       width = 9, height = 6)

# ─────────────────────────────────────────────────────────────────────────────
# Figure 10: Transition by Race (Black vs White)
# ─────────────────────────────────────────────────────────────────────────────

cat("Figure 10: Transition by race...\n")

# Top 6 destination occupations
top_dest <- trans_matrix[order(-N)]$occ_broad_1950[1:6]
trans_race_sub <- trans_race[occ_broad_1950 %in% top_dest]
trans_race_sub[, race_label := fifelse(is_black == 1, "Black", "Non-Black")]

p10 <- ggplot(trans_race_sub,
              aes(x = occ_broad_1950, y = pct, fill = race_label)) +
  geom_col(position = "dodge", alpha = 0.85) +
  scale_fill_manual(values = c(apep_colors[3], apep_colors[1]), name = NULL) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.1))) +
  labs(
    title = "Racial Disparities in Occupational Transitions",
    subtitle = "1950 destination of 1940 elevator operators, by race",
    x = NULL, y = "Percent",
    caption = "Source: IPUMS + MLP linked panel."
  ) +
  theme_apep() +
  theme(axis.text.x = element_text(angle = 30, hjust = 1, size = 9),
        legend.position = c(0.85, 0.85))

ggsave(file.path(FIG_DIR, "fig10_transition_race.pdf"), p10,
       width = 9, height = 6)

# ─────────────────────────────────────────────────────────────────────────────
# Figure 11: Transition by NYC vs. Other Cities
# ─────────────────────────────────────────────────────────────────────────────

cat("Figure 11: Transition by city...\n")

trans_city_sub <- trans_city[occ_broad_1950 %in% top_dest]
trans_city_sub[, city_label := fifelse(is_nyc_1940 == 1, "NYC", "Other cities")]

p11 <- ggplot(trans_city_sub,
              aes(x = occ_broad_1950, y = pct, fill = city_label)) +
  geom_col(position = "dodge", alpha = 0.85) +
  scale_fill_manual(values = c(apep_colors[2], apep_colors[4]), name = NULL) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.1))) +
  labs(
    title = "NYC vs. Other Cities: Different Transition Patterns",
    subtitle = "1950 destination of 1940 elevator operators",
    x = NULL, y = "Percent",
    caption = "Source: IPUMS + MLP linked panel."
  ) +
  theme_apep() +
  theme(axis.text.x = element_text(angle = 30, hjust = 1, size = 9),
        legend.position = c(0.85, 0.85))

ggsave(file.path(FIG_DIR, "fig11_transition_city.pdf"), p11,
       width = 9, height = 6)

# ─────────────────────────────────────────────────────────────────────────────
# Figure 12: Mean Age of Elevator Operators Over Time
# ─────────────────────────────────────────────────────────────────────────────

cat("Figure 12: Mean age trend...\n")

p12 <- ggplot(national, aes(x = year, y = mean_age_elev)) +
  geom_line(linewidth = 1.1, color = apep_colors[1]) +
  geom_point(size = 3.5, color = apep_colors[1]) +
  geom_text(aes(label = sprintf("%.1f", mean_age_elev)),
            vjust = -1.2, size = 3.2) +
  scale_x_continuous(breaks = seq(1900, 1950, 10)) +
  labs(
    title = "A Dying Occupation: The Aging of the Elevator Operator",
    subtitle = "Mean age of elevator operators, 1900-1950",
    x = NULL, y = "Mean age (years)",
    caption = "Source: IPUMS Full-Count Census."
  ) +
  theme_apep()

ggsave(file.path(FIG_DIR, "fig12_mean_age.pdf"), p12,
       width = 8, height = 5.5)

# ─────────────────────────────────────────────────────────────────────────────
# Figure A1 (Appendix): State-level heat map — operator share by decade
# ─────────────────────────────────────────────────────────────────────────────

cat("Figure A1: State heat map...\n")

# All states with operators
state_wide <- dcast(state_panel[!is.na(state_name)],
                    state_name ~ year,
                    value.var = "elev_per_10k_pop")

# For simplicity, use a faceted bar chart instead of map
state_panel_sub <- state_panel[!is.na(state_name) &
                                 state_name %in% top5_names]

p_a1 <- ggplot(state_panel_sub,
               aes(x = year, y = elev_per_10k_pop, fill = state_name)) +
  geom_col(alpha = 0.85) +
  facet_wrap(~state_name, scales = "free_y") +
  scale_fill_manual(values = apep_colors[1:5]) +
  scale_x_continuous(breaks = seq(1900, 1950, 10)) +
  labs(
    title = "Elevator Operators per 10,000 Population by State",
    x = NULL, y = "Operators per 10,000 pop."
  ) +
  theme_apep() +
  theme(legend.position = "none",
        axis.text.x = element_text(angle = 45, hjust = 1))

ggsave(file.path(FIG_DIR, "fig_a1_state_detail.pdf"), p_a1,
       width = 10, height = 7)

cat("\n========================================\n")
cat("FIGURES COMPLETE\n")
cat(sprintf("Saved %d figures to %s\n", length(list.files(FIG_DIR, "*.pdf")), FIG_DIR))
cat("========================================\n")
