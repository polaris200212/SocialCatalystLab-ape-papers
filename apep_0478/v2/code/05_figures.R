# =============================================================================
# 05_figures.R — Going Up Alone v2 (apep_0478)
# All figures: descriptive atlas + individual transitions + SCM (supporting)
# =============================================================================

source("00_packages.R")

cat("\n========================================\n")
cat("GENERATING FIGURES (v2)\n")
cat("========================================\n\n")

# Load data
national    <- fread(file.path(DATA_DIR, "national_clean.csv"))
state_panel <- fread(file.path(DATA_DIR, "scm_panel.csv"))
linked      <- fread(file.path(DATA_DIR, "linked_panel_clean.csv"))
trans_matrix <- fread(file.path(DATA_DIR, "transition_matrix.csv"))
trans_race  <- fread(file.path(DATA_DIR, "transition_by_race.csv"))
trans_city  <- fread(file.path(DATA_DIR, "transition_by_city.csv"))

# New v2 data
trans_dir    <- fread(file.path(DATA_DIR, "transition_direction.csv"))
dest_quality <- fread(file.path(DATA_DIR, "destination_quality.csv"))
nyc_summary  <- fread(file.path(DATA_DIR, "nyc_vs_other_summary.csv"))
ame_df       <- fread(file.path(DATA_DIR, "selection_logit_ame.csv"))
nyc_trans    <- fread(file.path(DATA_DIR, "transition_by_nyc_detail.csv"))

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
# Figure 3: Demographic Composition Evolution (EXPANDED — stacked area)
# ─────────────────────────────────────────────────────────────────────────────

cat("Figure 3: Demographic composition evolution...\n")

# Panel A: Race composition
race_data <- national[, .(year,
                          `White` = 100 - pct_black - pct_other_race,
                          `Black` = pct_black,
                          `Other` = pct_other_race)]
race_long <- melt(race_data, id.vars = "year",
                  variable.name = "race", value.name = "percent")
race_long[, race := factor(race, levels = c("Other", "Black", "White"))]

p3a <- ggplot(race_long, aes(x = year, y = percent, fill = race)) +
  geom_area(alpha = 0.85) +
  scale_fill_manual(values = c("grey70", apep_colors[3], apep_colors[1]),
                    name = "Race") +
  scale_x_continuous(breaks = seq(1900, 1950, 10)) +
  labs(title = "Panel A: Racial Composition",
       x = NULL, y = "Share (%)") +
  theme_apep() +
  theme(legend.position = "right")

# Panel B: Sex and age combined
demo_data <- national[, .(year, `Female (%)` = pct_female,
                          `Mean age` = mean_age_elev)]
p3b <- ggplot() +
  geom_line(data = national, aes(x = year, y = pct_female, color = "Female share (%)"),
            linewidth = 1.1) +
  geom_point(data = national, aes(x = year, y = pct_female, color = "Female share (%)"),
             size = 3) +
  geom_line(data = national, aes(x = year, y = mean_age_elev, color = "Mean age (years)"),
            linewidth = 1.1) +
  geom_point(data = national, aes(x = year, y = mean_age_elev, color = "Mean age (years)"),
             size = 3) +
  scale_color_manual(values = c(apep_colors[2], apep_colors[5]), name = NULL) +
  scale_x_continuous(breaks = seq(1900, 1950, 10)) +
  labs(title = "Panel B: Gender and Age",
       x = NULL, y = "Percent / Years") +
  theme_apep() +
  theme(legend.position = c(0.3, 0.85))

p3 <- p3a / p3b +
  plot_annotation(
    title = "The Changing Face of the Elevator Operator",
    subtitle = "Demographic composition of elevator operators, 1900-1950",
    caption = "Source: IPUMS Full-Count Census, OCC1950 = 761.",
    theme = theme_apep()
  )

ggsave(file.path(FIG_DIR, "fig3_demographics.pdf"), p3,
       width = 8, height = 10)

# ─────────────────────────────────────────────────────────────────────────────
# Figure 4: Age Distribution Over Time (Stacked Area)
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
# Figure 6: Where Did They Go? (Occupational Flow Bar Chart)
# ─────────────────────────────────────────────────────────────────────────────

cat("Figure 6: Occupational flow (transition bar chart)...\n")

trans_matrix[, occ_broad_1950 := factor(occ_broad_1950,
  levels = trans_matrix[order(-N)]$occ_broad_1950)]

p6 <- ggplot(trans_matrix, aes(x = reorder(occ_broad_1950, -pct), y = pct)) +
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

ggsave(file.path(FIG_DIR, "fig6_transition_flow.pdf"), p6,
       width = 9, height = 6)

# ─────────────────────────────────────────────────────────────────────────────
# Figure 7: Transition Direction — Upward, Lateral, Downward
# ─────────────────────────────────────────────────────────────────────────────

cat("Figure 7: Transition direction...\n")

# Order categories
trans_dir[, transition_dir := factor(transition_dir,
  levels = c("Upward", "Lateral", "Stayed", "Left labor force", "Downward"))]

dir_colors <- c("Upward" = "#2ECC71", "Lateral" = "#F39C12",
                "Stayed" = "#3498DB", "Left labor force" = "#95A5A6",
                "Downward" = "#E74C3C")

p7 <- ggplot(trans_dir, aes(x = transition_dir, y = pct, fill = transition_dir)) +
  geom_col(alpha = 0.85) +
  geom_text(aes(label = sprintf("%.1f%%\n(N=%s)", pct, format(N, big.mark = ","))),
            vjust = -0.2, size = 3) +
  scale_fill_manual(values = dir_colors) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.2))) +
  labs(
    title = "Was Displacement Upward or Downward?",
    subtitle = "Direction of occupational transition for 1940 elevator operators",
    x = NULL, y = "Percent of elevator operators",
    caption = "Upward: OCCSCORE gain > 2 points. Downward: loss > 2 points.\nSource: IPUMS + MLP linked panel."
  ) +
  theme_apep() +
  theme(legend.position = "none")

ggsave(file.path(FIG_DIR, "fig7_transition_direction.pdf"), p7,
       width = 8, height = 6)

# ─────────────────────────────────────────────────────────────────────────────
# Figure 8: NYC vs Non-NYC Transition Comparison
# ─────────────────────────────────────────────────────────────────────────────

cat("Figure 8: NYC vs non-NYC transitions...\n")

top_dest <- trans_matrix[order(-N)]$occ_broad_1950[1:6]
nyc_trans_sub <- nyc_trans[occ_broad_1950 %in% top_dest]
nyc_trans_sub[, city_label := fifelse(is_nyc_1940 == 1, "NYC", "Other cities")]

p8 <- ggplot(nyc_trans_sub,
              aes(x = occ_broad_1950, y = pct, fill = city_label)) +
  geom_col(position = "dodge", alpha = 0.85) +
  scale_fill_manual(values = c(apep_colors[2], apep_colors[4]), name = NULL) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.1))) +
  labs(
    title = "The Paradox of the Epicenter",
    subtitle = "NYC operators were MORE likely to stay — despite the strike",
    x = NULL, y = "Percent of elevator operators",
    caption = "Source: IPUMS + MLP linked panel. NYC = five boroughs."
  ) +
  theme_apep() +
  theme(axis.text.x = element_text(angle = 30, hjust = 1, size = 9),
        legend.position = c(0.85, 0.85))

ggsave(file.path(FIG_DIR, "fig8_nyc_vs_other.pdf"), p8,
       width = 9, height = 6)

# ─────────────────────────────────────────────────────────────────────────────
# Figure 9: Selection into Persistence — Coefficient Plot
# ─────────────────────────────────────────────────────────────────────────────

cat("Figure 9: Selection coefficient plot...\n")

# Remove intercept
ame_plot <- ame_df[variable != "(Intercept)"]
ame_plot[, variable := fcase(
  variable == "age_centered", "Age (centered)",
  variable == "age_centered_sq", "Age squared",
  variable == "is_black", "Black",
  variable == "is_female", "Female",
  variable == "is_native", "Native-born",
  variable == "is_married", "Married",
  variable == "is_nyc_1940", "NYC resident",
  default = variable
)]
ame_plot[, ci_lo := ame - 1.96 * se * abs(ame / coefficient)]
ame_plot[, ci_hi := ame + 1.96 * se * abs(ame / coefficient)]
ame_plot[, sig := fifelse(p_value < 0.05, "p < 0.05", "n.s.")]

p9 <- ggplot(ame_plot, aes(x = reorder(variable, ame), y = ame, color = sig)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
  geom_pointrange(aes(ymin = ci_lo, ymax = ci_hi), size = 0.8) +
  scale_color_manual(values = c("p < 0.05" = apep_colors[1],
                                "n.s." = "grey60"), name = NULL) +
  coord_flip() +
  labs(
    title = "Who Stayed? Selection into Occupational Persistence",
    subtitle = "Average marginal effects from logit: P(still elevator operator in 1950)",
    x = NULL, y = "Average marginal effect on P(staying)",
    caption = "Source: IPUMS + MLP linked panel. N = linked elevator operators."
  ) +
  theme_apep() +
  theme(legend.position = c(0.85, 0.15))

ggsave(file.path(FIG_DIR, "fig9_selection_coefficients.pdf"), p9,
       width = 8, height = 5.5)

# ─────────────────────────────────────────────────────────────────────────────
# Figure 10: Transition by Race (Black vs White)
# ─────────────────────────────────────────────────────────────────────────────

cat("Figure 10: Transition by race...\n")

trans_race_sub <- trans_race[occ_broad_1950 %in% top_dest]
trans_race_sub[, race_label := fifelse(is_black == 1, "Black", "Non-Black")]

p10 <- ggplot(trans_race_sub,
              aes(x = occ_broad_1950, y = pct, fill = race_label)) +
  geom_col(position = "dodge", alpha = 0.85) +
  scale_fill_manual(values = c(apep_colors[3], apep_colors[1]), name = NULL) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.1))) +
  labs(
    title = "The Unequal Burden of Displacement",
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
# Figure 11: SCM — NYC vs Synthetic NYC (compressed, single panel)
# ─────────────────────────────────────────────────────────────────────────────

cat("Figure 11: SCM results (compressed)...\n")

if (file.exists(file.path(DATA_DIR, "scm_results.rds"))) {
  scm_res <- readRDS(file.path(DATA_DIR, "scm_results.rds"))

  if ("gap" %in% names(scm_res)) {
    gap_df <- as.data.table(scm_res$gap)
    gap_long <- melt(gap_df[, .(year, `NYC (actual)` = nyc_actual,
                                 `Synthetic NYC` = nyc_synthetic)],
                     id.vars = "year",
                     variable.name = "series", value.name = "value")

    p11 <- ggplot(gap_long, aes(x = year, y = value, color = series,
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
        title = "The Paradox: NYC Retained Operators After the Strike",
        subtitle = "Synthetic control: NYC vs. weighted comparison states",
        x = NULL, y = "Operators per 1,000 bldg. service workers",
        caption = sprintf("Permutation p-value: %.3f (%d placebos). Source: IPUMS.",
                          scm_res$p_value, scm_res$n_placebos)
      ) +
      theme_apep() +
      theme(legend.position = c(0.2, 0.85))

    ggsave(file.path(FIG_DIR, "fig11_scm_results.pdf"), p11,
           width = 8, height = 5.5)
  }
}

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
# Figure A1 (Appendix): Placebo Spaghetti Plot
# ─────────────────────────────────────────────────────────────────────────────

cat("Figure A1: Placebo spaghetti...\n")

if (file.exists(file.path(DATA_DIR, "placebo_gaps.csv")) &&
    file.exists(file.path(DATA_DIR, "scm_results.rds"))) {
  placebo_df <- fread(file.path(DATA_DIR, "placebo_gaps.csv"))
  scm_res <- readRDS(file.path(DATA_DIR, "scm_results.rds"))

  if ("gap" %in% names(scm_res)) {
    nyc_gap <- as.data.table(scm_res$gap)

    p_a1 <- ggplot() +
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
        caption = sprintf("NY p-value: %.3f (%d placebos). Source: IPUMS.",
                          scm_res$p_value, scm_res$n_placebos)
      ) +
      theme_apep()

    ggsave(file.path(FIG_DIR, "fig_a1_placebo_spaghetti.pdf"), p_a1,
           width = 8, height = 6)
  }
}

# ─────────────────────────────────────────────────────────────────────────────
# Figure A2 (Appendix): Event Study
# ─────────────────────────────────────────────────────────────────────────────

cat("Figure A2: Event study...\n")

if (file.exists(file.path(DATA_DIR, "event_study_coefs.csv"))) {
  es_coefs <- fread(file.path(DATA_DIR, "event_study_coefs.csv"))
  ref_row <- data.table(Estimate = 0, `Std. Error` = 0,
                         `t value` = 0, `Pr(>|t|)` = 1, year = 1940)
  setnames(ref_row, names(es_coefs))
  es_coefs <- rbind(es_coefs, ref_row)
  es_coefs[, ci_lo := Estimate - 1.96 * `Std. Error`]
  es_coefs[, ci_hi := Estimate + 1.96 * `Std. Error`]

  p_a2 <- ggplot(es_coefs, aes(x = year, y = Estimate)) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
    geom_vline(xintercept = 1945, linetype = "dashed", color = "red", alpha = 0.5) +
    geom_ribbon(aes(ymin = ci_lo, ymax = ci_hi), alpha = 0.2, fill = apep_colors[3]) +
    geom_line(linewidth = 1, color = apep_colors[1]) +
    geom_point(size = 3, color = apep_colors[1]) +
    scale_x_continuous(breaks = seq(1900, 1950, 10)) +
    labs(
      title = "Event Study: NYC Relative to Comparison States",
      subtitle = "Coefficients from year x NYC interaction. Reference: 1940.",
      x = NULL, y = "Operators per 10,000 pop.\n(relative to 1940)",
      caption = "95% CI shown. Source: IPUMS Full-Count Census."
    ) +
    theme_apep()

  ggsave(file.path(FIG_DIR, "fig_a2_event_study.pdf"), p_a2,
         width = 8, height = 5.5)
}

# ─────────────────────────────────────────────────────────────────────────────
# Figure A3 (Appendix): State-level detail — top 5 states
# ─────────────────────────────────────────────────────────────────────────────

cat("Figure A3: State detail...\n")

state_panel_sub <- state_panel[!is.na(state_name) & state_name %in% top5_names]

p_a3 <- ggplot(state_panel_sub,
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

ggsave(file.path(FIG_DIR, "fig_a3_state_detail.pdf"), p_a3,
       width = 10, height = 7)

cat("\n========================================\n")
cat("FIGURES COMPLETE\n")
cat(sprintf("Saved %d figures to %s\n", length(list.files(FIG_DIR, "*.pdf")), FIG_DIR))
cat("========================================\n")
