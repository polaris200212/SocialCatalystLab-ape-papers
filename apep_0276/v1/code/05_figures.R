# =============================================================================
# 05_figures.R - All Figure Generation
# APEP-0265: Felon Voting Rights Restoration and Black Political Participation
# =============================================================================

source("00_packages.R")

data_dir <- "../data"
fig_dir <- "../figures"
dir.create(fig_dir, showWarnings = FALSE, recursive = TRUE)

# Load data
cell_data <- readRDS(file.path(data_dir, "analysis_cells.rds"))
reforms <- readRDS(file.path(data_dir, "reform_timing.rds"))
state_xwalk <- readRDS(file.path(data_dir, "state_crosswalk.rds"))
ddd_data <- readRDS(file.path(data_dir, "ddd_panel.rds"))

reversal_fips <- c(12, 19)

# =============================================================================
# FIGURE 1: TREATMENT ROLLOUT MAP
# =============================================================================

cat("Generating Figure 1: Treatment Rollout Map...\n")

tryCatch({
  states_sf <- states(cb = TRUE, year = 2020) %>%
    filter(!STATEFP %in% c("02", "15", "72", "78", "60", "66", "69")) %>%
    mutate(state_fips = as.integer(STATEFP))

  # Prepare treatment data for map
  map_data <- states_sf %>%
    left_join(
      reforms %>%
        select(state_fips, first_election) %>%
        mutate(
          treatment_status = case_when(
            state_fips %in% reversal_fips ~ "Reversal (FL, IA)",
            first_election <= 2006 ~ "Early Reform (1998-2006)",
            first_election <= 2014 ~ "Middle Reform (2008-2014)",
            first_election <= 2020 ~ "Late Reform (2016-2020)",
            first_election > 2020 ~ "Recent Reform (2022-2024)",
            TRUE ~ NA_character_
          )
        ),
      by = "state_fips"
    ) %>%
    mutate(
      treatment_status = case_when(
        state_fips %in% c(23, 50, 11) ~ "Never Disenfranchises",
        is.na(treatment_status) ~ "No Change (Control)",
        TRUE ~ treatment_status
      ),
      treatment_status = factor(treatment_status, levels = c(
        "Early Reform (1998-2006)", "Middle Reform (2008-2014)",
        "Late Reform (2016-2020)", "Recent Reform (2022-2024)",
        "Reversal (FL, IA)", "Never Disenfranchises", "No Change (Control)"
      ))
    )

  p1 <- ggplot(map_data) +
    geom_sf(aes(fill = treatment_status), color = "white", linewidth = 0.2) +
    scale_fill_manual(
      name = "Treatment Status",
      values = c(
        "Early Reform (1998-2006)" = "#0072B2",
        "Middle Reform (2008-2014)" = "#56B4E9",
        "Late Reform (2016-2020)" = "#D55E00",
        "Recent Reform (2022-2024)" = "#CC79A7",
        "Reversal (FL, IA)" = "#F0E442",
        "Never Disenfranchises" = "#009E73",
        "No Change (Control)" = "grey80"
      ),
      na.value = "grey90"
    ) +
    labs(
      title = "Staggered Adoption of Felon Voting Rights Restoration",
      subtitle = "Continental US, 1996-2024",
      caption = "Sources: NCSL, Brennan Center, Ballotpedia. Reversal states (FL, IA) excluded from main analysis."
    ) +
    theme_void() +
    theme(
      legend.position = "bottom",
      legend.key.size = unit(0.4, "cm"),
      legend.text = element_text(size = 8),
      plot.title = element_text(size = 13, face = "bold", hjust = 0.5),
      plot.subtitle = element_text(size = 10, color = "grey40", hjust = 0.5),
      plot.caption = element_text(size = 7, color = "grey50", hjust = 1)
    ) +
    guides(fill = guide_legend(nrow = 2))

  ggsave(file.path(fig_dir, "fig1_treatment_map.pdf"), p1, width = 10, height = 7)
  cat("  Figure 1 saved.\n")
}, error = function(e) {
  cat(sprintf("  Figure 1 error (map): %s\n", e$message))
})

# =============================================================================
# FIGURE 2: RAW TURNOUT TRENDS BY RACE AND REFORM STATUS
# =============================================================================

cat("Generating Figure 2: Raw Turnout Trends...\n")

trends_data <- cell_data %>%
  filter(!state_fips %in% reversal_fips,
         state_group %in% c("reform", "control")) %>%
  group_by(year, race_cat, state_group) %>%
  summarise(
    turnout = weighted.mean(turnout, n_obs, na.rm = TRUE),
    registered = weighted.mean(registered, n_obs, na.rm = TRUE),
    n = sum(n_obs),
    .groups = "drop"
  ) %>%
  mutate(
    group_label = paste0(
      ifelse(race_cat == "black_nh", "Black", "White"), " - ",
      ifelse(state_group == "reform", "Reform States", "Control States")
    )
  )

p2 <- ggplot(trends_data, aes(x = year, y = turnout, color = group_label,
                                linetype = group_label)) +
  geom_line(linewidth = 0.9) +
  geom_point(size = 2) +
  scale_color_manual(
    name = "",
    values = c(
      "Black - Reform States" = "#0072B2",
      "Black - Control States" = "#56B4E9",
      "White - Reform States" = "#D55E00",
      "White - Control States" = "#F0E442"
    )
  ) +
  scale_linetype_manual(
    name = "",
    values = c(
      "Black - Reform States" = "solid",
      "Black - Control States" = "dashed",
      "White - Reform States" = "solid",
      "White - Control States" = "dashed"
    )
  ) +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1),
                     limits = c(0.3, 0.85)) +
  scale_x_continuous(breaks = seq(1996, 2024, 4)) +
  labs(
    title = "Voter Turnout by Race and Reform Status",
    subtitle = "CPS Voting Supplement, weighted means. Reversal states (FL, IA) excluded.",
    x = "Election Year",
    y = "Voter Turnout Rate",
    caption = "Source: CPS Voting and Registration Supplement, 1996-2024."
  ) +
  theme_apep() +
  theme(legend.position = "bottom",
        legend.key.width = unit(1.5, "cm"))

ggsave(file.path(fig_dir, "fig2_raw_trends.pdf"), p2, width = 9, height = 6)
cat("  Figure 2 saved.\n")

# =============================================================================
# FIGURE 3: BLACK-WHITE TURNOUT GAP TRENDS
# =============================================================================

cat("Generating Figure 3: Black-White Turnout Gap...\n")

gap_trends <- cell_data %>%
  filter(!state_fips %in% reversal_fips,
         state_group %in% c("reform", "control")) %>%
  select(state_fips, year, race_cat, turnout, n_obs, state_group) %>%
  pivot_wider(names_from = race_cat,
              values_from = c(turnout, n_obs),
              names_sep = "_") %>%
  mutate(turnout_gap = turnout_black_nh - turnout_white_nh) %>%
  group_by(year, state_group) %>%
  summarise(
    mean_gap = mean(turnout_gap, na.rm = TRUE),
    se_gap = sd(turnout_gap, na.rm = TRUE) / sqrt(n()),
    n_states = n(),
    .groups = "drop"
  )

p3 <- ggplot(gap_trends, aes(x = year, y = mean_gap, color = state_group,
                               fill = state_group)) +
  geom_ribbon(aes(ymin = mean_gap - 1.96 * se_gap,
                  ymax = mean_gap + 1.96 * se_gap),
              alpha = 0.15, color = NA) +
  geom_line(linewidth = 0.9) +
  geom_point(size = 2.5) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
  scale_color_manual(
    name = "State Group",
    values = c("reform" = apep_colors[1], "control" = apep_colors[2]),
    labels = c("reform" = "Reform States", "control" = "Control States")
  ) +
  scale_fill_manual(
    name = "State Group",
    values = c("reform" = apep_colors[1], "control" = apep_colors[2]),
    labels = c("reform" = "Reform States", "control" = "Control States")
  ) +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1)) +
  scale_x_continuous(breaks = seq(1996, 2024, 4)) +
  labs(
    title = "Black-White Voter Turnout Gap by Reform Status",
    subtitle = "Negative values = Black turnout below White turnout. 95% CI shown.",
    x = "Election Year",
    y = "Black - White Turnout Gap (pp)",
    caption = "Source: CPS Voting and Registration Supplement. State-level gaps averaged across states."
  ) +
  theme_apep()

ggsave(file.path(fig_dir, "fig3_turnout_gap.pdf"), p3, width = 9, height = 6)
cat("  Figure 3 saved.\n")

# =============================================================================
# FIGURE 4: EVENT STUDY (Callaway-Sant'Anna)
# =============================================================================

cat("Generating Figure 4: Event Study...\n")

tryCatch({
  cs_results <- readRDS(file.path(data_dir, "cs_turnout_results.rds"))

  if ("cs_es" %in% names(cs_results)) {
    es <- cs_results$cs_es

    es_df <- data.frame(
      event_time = es$egt,
      att = es$att.egt,
      se = es$se.egt
    ) %>%
      mutate(
        ci_lo = att - 1.96 * se,
        ci_hi = att + 1.96 * se
      )

    p4 <- ggplot(es_df, aes(x = event_time, y = att)) +
      geom_ribbon(aes(ymin = ci_lo, ymax = ci_hi),
                  alpha = 0.2, fill = apep_colors[1]) +
      geom_line(color = apep_colors[1], linewidth = 0.8) +
      geom_point(color = apep_colors[1], size = 2.5) +
      geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
      geom_vline(xintercept = -0.5, linetype = "dotted", color = "grey60") +
      scale_x_continuous(breaks = seq(-6, 6, 2),
                         labels = function(x) paste0(ifelse(x >= 0, "+", ""), x)) +
      labs(
        title = "Event Study: Effect of Voting Rights Restoration on Black-White Turnout Gap",
        subtitle = "Callaway-Sant'Anna estimator, 95% confidence intervals. Reference: t = -1.",
        x = "Election Cycles Relative to Reform",
        y = "ATT (Change in Black-White Turnout Gap)",
        caption = "Note: Each unit = 2 years (biennial elections). Never-treated states as control."
      ) +
      theme_apep()

    ggsave(file.path(fig_dir, "fig4_event_study.pdf"), p4, width = 9, height = 6)
    cat("  Figure 4 saved.\n")
  } else if ("twfe_es" %in% names(cs_results)) {
    # Fallback: Sun-Abraham event study from fixest
    m_es <- cs_results$twfe_es
    es_df <- data.frame(
      event_time = as.numeric(gsub(".*::", "", names(coef(m_es)))),
      att = as.numeric(coef(m_es)),
      se = as.numeric(se(m_es))
    ) %>%
      mutate(ci_lo = att - 1.96 * se, ci_hi = att + 1.96 * se) %>%
      filter(!is.na(event_time))

    p4 <- ggplot(es_df, aes(x = event_time, y = att)) +
      geom_ribbon(aes(ymin = ci_lo, ymax = ci_hi),
                  alpha = 0.2, fill = apep_colors[1]) +
      geom_line(color = apep_colors[1], linewidth = 0.8) +
      geom_point(color = apep_colors[1], size = 2.5) +
      geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
      geom_vline(xintercept = -0.5, linetype = "dotted", color = "grey60") +
      labs(
        title = "Event Study: Sun-Abraham Estimator",
        subtitle = "Effect of Rights Restoration on Black-White Turnout Gap",
        x = "Election Cycles Relative to Reform",
        y = "Estimated Effect on Turnout Gap"
      ) +
      theme_apep()

    ggsave(file.path(fig_dir, "fig4_event_study.pdf"), p4, width = 9, height = 6)
    cat("  Figure 4 saved (Sun-Abraham fallback).\n")
  }
}, error = function(e) {
  cat(sprintf("  Figure 4 error: %s\n", e$message))
})

# =============================================================================
# FIGURE 5: DDD MECHANISM TEST
# =============================================================================

cat("Generating Figure 5: DDD Mechanism Test...\n")

ddd_trends <- ddd_data %>%
  filter(!state_fips %in% reversal_fips,
         risk_label %in% c("low_risk_black", "low_risk_white",
                           "high_risk_black", "high_risk_white")) %>%
  group_by(year, risk_label) %>%
  summarise(
    turnout = weighted.mean(turnout, n_obs, na.rm = TRUE),
    n = sum(n_obs),
    .groups = "drop"
  ) %>%
  mutate(
    risk_label = factor(risk_label, levels = c(
      "low_risk_black", "high_risk_black",
      "low_risk_white", "high_risk_white"
    ), labels = c(
      "Low-Risk Black", "High-Risk Black",
      "Low-Risk White", "High-Risk White"
    ))
  )

p5 <- ggplot(ddd_trends, aes(x = year, y = turnout, color = risk_label,
                               linetype = risk_label)) +
  geom_line(linewidth = 0.8) +
  geom_point(size = 2) +
  scale_color_manual(
    name = "Subgroup",
    values = c(
      "Low-Risk Black" = apep_colors[1],
      "High-Risk Black" = apep_colors[3],
      "Low-Risk White" = apep_colors[2],
      "High-Risk White" = apep_colors[4]
    )
  ) +
  scale_linetype_manual(
    name = "Subgroup",
    values = c("solid", "dashed", "solid", "dashed")
  ) +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1)) +
  scale_x_continuous(breaks = seq(1996, 2024, 4)) +
  labs(
    title = "Turnout by Race and Felony-Risk Subgroup",
    subtitle = "Low-risk: women 50+ or college-educated. High-risk: men 25-44, no college.",
    x = "Election Year",
    y = "Voter Turnout Rate",
    caption = "Source: CPS Voting Supplement. Reform states only, excl. FL and IA."
  ) +
  theme_apep() +
  theme(legend.position = "bottom",
        legend.key.width = unit(1.5, "cm"))

ggsave(file.path(fig_dir, "fig5_ddd_subgroups.pdf"), p5, width = 9, height = 6)
cat("  Figure 5 saved.\n")

# =============================================================================
# FIGURE 6: TREATMENT ROLLOUT TIMELINE
# =============================================================================

cat("Generating Figure 6: Treatment Rollout Timeline...\n")

rollout <- reforms %>%
  group_by(state_fips) %>%
  slice(1) %>%
  ungroup() %>%
  left_join(state_xwalk %>% select(state_fips, state_name), by = "state_fips") %>%
  mutate(is_reversal = state_fips %in% reversal_fips)

p6 <- ggplot(rollout, aes(x = first_election, y = reorder(state_abbr, first_election),
                            color = reform_type, shape = is_reversal)) +
  geom_point(size = 3) +
  scale_color_manual(
    name = "Reform Type",
    values = c("legislative" = apep_colors[1],
               "executive" = apep_colors[2],
               "ballot" = apep_colors[3])
  ) +
  scale_shape_manual(
    name = "Reversal State",
    values = c("FALSE" = 16, "TRUE" = 4),
    labels = c("FALSE" = "No", "TRUE" = "Yes")
  ) +
  scale_x_continuous(breaks = seq(1998, 2024, 2)) +
  labs(
    title = "Felon Voting Rights Restoration: Treatment Rollout",
    subtitle = "First eligible election year by state and reform type",
    x = "First Eligible Election Year",
    y = "",
    caption = "X marks reversal states (FL, IA). Source: NCSL, Brennan Center."
  ) +
  theme_apep() +
  theme(
    panel.grid.major.y = element_blank(),
    axis.text.y = element_text(size = 8),
    legend.position = "bottom"
  )

ggsave(file.path(fig_dir, "fig6_rollout_timeline.pdf"), p6, width = 8, height = 8)
cat("  Figure 6 saved.\n")

# =============================================================================
# FIGURE 7: ROBUSTNESS COMPARISON
# =============================================================================

cat("Generating Figure 7: Robustness Comparison...\n")

tryCatch({
  rob_results <- readRDS(file.path(data_dir, "robustness_results.rds"))
  dd_results <- readRDS(file.path(data_dir, "dd_results.rds"))

  # Extract coefficients from each model
  specs <- list(
    "Main (State x Year FE)" = dd_results$dd_turnout,
    "Separate FE" = dd_results$dd_separate,
    "+ Voting Law Controls" = dd_results$dd_controls,
    "Include Reversals" = rob_results$r1_include_reversals,
    "Permanent Reforms Only" = rob_results$r2_permanent_only,
    "Registration Outcome" = rob_results$r4_registration,
    "Unweighted" = rob_results$r5_unweighted,
    "Presidential Years" = rob_results$r6_presidential,
    "Midterm Years" = rob_results$r7_midterm
  )

  rob_df <- map_dfr(names(specs), function(nm) {
    m <- specs[[nm]]
    if (is.null(m)) return(NULL)
    coef_name <- intersect(c("black_reform"), names(coef(m)))
    if (length(coef_name) == 0) return(NULL)
    tibble(
      spec = nm,
      estimate = coef(m)[coef_name],
      se = se(m)[coef_name],
      ci_lo = estimate - 1.96 * se,
      ci_hi = estimate + 1.96 * se
    )
  }) %>%
    mutate(spec = factor(spec, levels = rev(unique(spec))))

  p7 <- ggplot(rob_df, aes(x = estimate, y = spec)) +
    geom_vline(xintercept = 0, linetype = "dashed", color = "grey40") +
    geom_errorbarh(aes(xmin = ci_lo, xmax = ci_hi),
                   height = 0.2, color = apep_colors[1]) +
    geom_point(size = 2.5, color = apep_colors[1]) +
    labs(
      title = "Robustness: Black x Post-Reform Coefficient Across Specifications",
      subtitle = "Point estimates with 95% confidence intervals",
      x = "Estimated Effect on Black-White Turnout/Registration Gap",
      y = ""
    ) +
    theme_apep() +
    theme(panel.grid.major.y = element_blank())

  ggsave(file.path(fig_dir, "fig7_robustness.pdf"), p7, width = 9, height = 6)
  cat("  Figure 7 saved.\n")
}, error = function(e) {
  cat(sprintf("  Figure 7 error: %s\n", e$message))
})

# =============================================================================
# FIGURE 8: PLACEBO TEST (Hispanic-White Gap)
# =============================================================================

cat("Generating Figure 8: Placebo Test...\n")

tryCatch({
  placebo <- readRDS(file.path(data_dir, "placebo_hispanic.rds")) %>%
    filter(!state_fips %in% reversal_fips) %>%
    select(state_fips, year, race_cat, turnout, n_obs) %>%
    pivot_wider(names_from = race_cat,
                values_from = c(turnout, n_obs),
                names_sep = "_") %>%
    mutate(turnout_gap = turnout_hispanic - turnout_white_nh) %>%
    left_join(
      readRDS(file.path(data_dir, "reform_timing.rds")) %>%
        select(state_fips, first_election),
      by = "state_fips"
    ) %>%
    mutate(
      reform_state = !is.na(first_election),
      state_group = ifelse(reform_state, "Reform States", "Control States")
    ) %>%
    group_by(year, state_group) %>%
    summarise(mean_gap = mean(turnout_gap, na.rm = TRUE),
              se_gap = sd(turnout_gap, na.rm = TRUE) / sqrt(n()),
              .groups = "drop")

  p8 <- ggplot(placebo, aes(x = year, y = mean_gap, color = state_group,
                             fill = state_group)) +
    geom_ribbon(aes(ymin = mean_gap - 1.96 * se_gap,
                    ymax = mean_gap + 1.96 * se_gap),
                alpha = 0.15, color = NA) +
    geom_line(linewidth = 0.9) +
    geom_point(size = 2.5) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
    scale_color_manual(name = "", values = c(apep_colors[3], apep_colors[4])) +
    scale_fill_manual(name = "", values = c(apep_colors[3], apep_colors[4])) +
    scale_y_continuous(labels = scales::percent_format(accuracy = 1)) +
    scale_x_continuous(breaks = seq(1996, 2024, 4)) +
    labs(
      title = "Placebo Test: Hispanic-White Voter Turnout Gap",
      subtitle = "No systematic change expected. 95% CI shown.",
      x = "Election Year",
      y = "Hispanic - White Turnout Gap (pp)",
      caption = "Source: CPS Voting Supplement. If reform-driven, effect should be absent here."
    ) +
    theme_apep()

  ggsave(file.path(fig_dir, "fig8_placebo.pdf"), p8, width = 9, height = 6)
  cat("  Figure 8 saved.\n")
}, error = function(e) {
  cat(sprintf("  Figure 8 error: %s\n", e$message))
})

cat("\n=== All Figures Generated ===\n")
