# =============================================================================
# 05_figures.R — All figures for apep_0476
# =============================================================================

source("00_packages.R")

# Load data
overall_link_rates <- readRDS(file.path(DATA_DIR, "overall_link_rates.rds"))
link_by_race <- readRDS(file.path(DATA_DIR, "link_by_race.rds"))
link_by_sex <- readRDS(file.path(DATA_DIR, "link_by_sex.rds"))
link_by_age <- readRDS(file.path(DATA_DIR, "link_by_age.rds"))
panel_desc <- readRDS(file.path(DATA_DIR, "panel_desc.rds"))
occ_matrices <- readRDS(file.path(DATA_DIR, "occ_matrices.rds"))
occ_switching <- readRDS(file.path(DATA_DIR, "occ_switching.rds"))
state_link_rates <- readRDS(file.path(DATA_DIR, "state_link_rates_named.rds"))
migration_named <- readRDS(file.path(DATA_DIR, "migration_named.rds"))
demo_transitions <- readRDS(file.path(DATA_DIR, "demo_transitions.rds"))
sei_distributions <- readRDS(file.path(DATA_DIR, "sei_distributions.rds"))
balance_df <- readRDS(file.path(DATA_DIR, "balance_tables.rds"))
race_patterns <- readRDS(file.path(DATA_DIR, "race_patterns.rds"))
abe_detail <- readRDS(file.path(DATA_DIR, "abe_mlp_comparison.rds"))
tri_desc <- readRDS(file.path(DATA_DIR, "tri_panel_desc.rds"))

# =============================================================================
# Figure 1: Link rates by decade pair (bar chart)
# =============================================================================
cat("Figure 1: Link rates by decade pair\n")

p1 <- ggplot(overall_link_rates, aes(x = pair_label, y = link_rate_pct)) +
  geom_col(fill = apep_colors[1], width = 0.6) +
  geom_text(aes(label = sprintf("%.1f%%", link_rate_pct)),
            vjust = -0.5, size = 3.5, fontface = "bold") +
  geom_text(aes(label = sprintf("N=%s", fmt(n_rows)), y = link_rate_pct / 2),
            size = 2.8, color = "white", fontface = "bold") +
  labs(
    title = "Record Linkage Rates Across Census Decades",
    subtitle = "Share of year-1 census population successfully linked to year-2 census",
    x = "Decade Pair",
    y = "Link Rate (%)"
  ) +
  scale_y_continuous(limits = c(0, max(overall_link_rates$link_rate_pct) * 1.15),
                     labels = function(x) paste0(x, "%")) +
  theme_apep()

ggsave(file.path(FIG_DIR, "fig1_link_rates.pdf"), p1, width = 8, height = 5)

# =============================================================================
# Figure 2: Link rates by race, sex, age (faceted panel)
# =============================================================================
cat("Figure 2: Link rates by demographics\n")

# Panel A: By race
p2a <- link_by_race %>%
  mutate(pair_label = gsub("_", "\u2192", pair)) %>%
  ggplot(aes(x = pair_label, y = link_rate * 100, fill = race_label)) +
  geom_col(position = "dodge", width = 0.6) +
  scale_fill_manual(values = c("White" = apep_colors[1], "Black" = apep_colors[2]),
                    name = "Race") +
  labs(title = "A. By Race", x = NULL, y = "Link Rate (%)") +
  scale_y_continuous(labels = function(x) paste0(x, "%")) +
  theme_apep() +
  theme(axis.text.x = element_text(angle = 30, hjust = 1))

# Panel B: By sex
p2b <- link_by_sex %>%
  mutate(pair_label = gsub("_", "\u2192", pair)) %>%
  ggplot(aes(x = pair_label, y = link_rate * 100, fill = sex_label)) +
  geom_col(position = "dodge", width = 0.6) +
  scale_fill_manual(values = c("Male" = apep_colors[1], "Female" = apep_colors[2]),
                    name = "Sex") +
  labs(title = "B. By Sex", x = NULL, y = "Link Rate (%)") +
  scale_y_continuous(labels = function(x) paste0(x, "%")) +
  theme_apep() +
  theme(axis.text.x = element_text(angle = 30, hjust = 1))

# Panel C: By age group (filter to key working-age bands)
age_keep <- c(0, 10, 20, 30, 40, 50, 60)
p2c <- link_by_age %>%
  filter(age_group %in% age_keep) %>%
  mutate(
    pair_label = gsub("_", "\u2192", pair),
    age_label = factor(paste0(age_group, "-", age_group + 9),
                       levels = paste0(age_keep, "-", age_keep + 9))
  ) %>%
  ggplot(aes(x = pair_label, y = link_rate * 100, fill = age_label)) +
  geom_col(position = "dodge", width = 0.7) +
  scale_fill_brewer(palette = "Set2", name = "Age Group") +
  labs(title = "C. By Age Group", x = "Decade Pair", y = "Link Rate (%)") +
  scale_y_continuous(labels = function(x) paste0(x, "%")) +
  theme_apep() +
  theme(axis.text.x = element_text(angle = 30, hjust = 1))

p2 <- p2a / p2b / p2c +
  plot_annotation(
    title = "Linkage Rates by Demographic Group",
    subtitle = "Share of base-year population linked to subsequent census"
  )

ggsave(file.path(FIG_DIR, "fig2_link_rates_demographics.pdf"), p2, width = 8, height = 12)

# =============================================================================
# Figure 3: Balance — linked vs unlinked (coefficient plot)
# =============================================================================
cat("Figure 3: Selection into linkage\n")

# Reshape balance tables for coefficient plot
balance_long <- balance_df %>%
  select(pair, starts_with("mean_age"), starts_with("pct_male"),
         starts_with("pct_white"), starts_with("pct_native"),
         starts_with("pct_farm")) %>%
  pivot_longer(-pair, names_to = "var_status", values_to = "value") %>%
  mutate(
    linked = ifelse(grepl("_linked$", var_status), "Linked", "Unlinked"),
    variable = gsub("_(linked|unlinked)$", "", var_status),
    variable = gsub("^(mean_|pct_)", "", variable)
  ) %>%
  pivot_wider(names_from = linked, values_from = value) %>%
  mutate(
    diff = Linked - Unlinked,
    variable = recode(variable,
      "age" = "Age",
      "male" = "Male (%)",
      "white" = "White (%)",
      "native" = "Native-born (%)",
      "farm" = "Farm (%)"
    )
  )

p3 <- ggplot(balance_long, aes(x = diff, y = variable, color = pair)) +
  geom_point(size = 3, position = position_dodge(0.4)) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "grey50") +
  scale_color_manual(values = apep_colors[1:5], name = "Decade Pair") +
  labs(
    title = "Selection into Linkage: Linked vs Unlinked Populations",
    subtitle = "Difference in means (linked minus unlinked). Zero = no selection.",
    x = "Difference (Linked - Unlinked)",
    y = NULL
  ) +
  theme_apep() +
  theme(legend.position = "right")

ggsave(file.path(FIG_DIR, "fig3_selection_balance.pdf"), p3, width = 9, height = 5)

# =============================================================================
# Figure 4: SEI distribution changes (density plots)
# =============================================================================
cat("Figure 4: SEI mobility\n")

p4 <- sei_distributions %>%
  ggplot(aes(x = delta_sei, fill = pair)) +
  geom_density(alpha = 0.4) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "grey40") +
  scale_fill_manual(values = apep_colors[1:4], name = "Decade Pair") +
  labs(
    title = "Within-Person Change in Socioeconomic Index (SEI)",
    subtitle = "Density of individual-level SEI changes across census decades",
    x = expression(Delta * " SEI (year 2 - year 1)"),
    y = "Density"
  ) +
  coord_cartesian(xlim = c(-40, 40)) +
  theme_apep()

ggsave(file.path(FIG_DIR, "fig4_sei_mobility.pdf"), p4, width = 8, height = 5)

# =============================================================================
# Figure 5: Occupation transition heatmap (1920-1930)
# =============================================================================
cat("Figure 5: Occupation transitions\n")

occ_categories <- c("Professional", "Manager", "Clerical", "Sales",
                     "Craftsman", "Operative", "Service",
                     "Farmer", "Farm laborer", "Laborer")

# Use 1920-1930 pair for the main text heatmap
occ_1920_30 <- occ_matrices %>%
  filter(pair == "1920-1930") %>%
  filter(occ_y1 %in% occ_categories & occ_y2 %in% occ_categories) %>%
  group_by(occ_y1) %>%
  mutate(row_pct = n / sum(n) * 100) %>%
  ungroup() %>%
  mutate(
    occ_y1 = factor(occ_y1, levels = rev(occ_categories)),
    occ_y2 = factor(occ_y2, levels = occ_categories)
  )

p5 <- ggplot(occ_1920_30, aes(x = occ_y2, y = occ_y1, fill = row_pct)) +
  geom_tile(color = "white", linewidth = 0.5) +
  geom_text(aes(label = sprintf("%.0f", row_pct)),
            size = 2.5, color = ifelse(occ_1920_30$row_pct > 40, "white", "black")) +
  scale_fill_gradient(low = "white", high = apep_colors[1],
                      name = "Row %", limits = c(0, 100)) +
  labs(
    title = "Occupation Transition Matrix, 1920\u21921930",
    subtitle = "Row percentages: share of 1920 occupation group in each 1930 category",
    x = "1930 Occupation",
    y = "1920 Occupation"
  ) +
  theme_apep() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1, size = 8),
    axis.text.y = element_text(size = 8),
    panel.grid = element_blank()
  )

ggsave(file.path(FIG_DIR, "fig5_occ_transitions.pdf"), p5, width = 9, height = 7)

# =============================================================================
# Figure 6: Interstate migration rates over time
# =============================================================================
cat("Figure 6: Migration rates\n")

mig_rates <- demo_transitions %>%
  mutate(pair_label = sprintf("%d\u2192%d", y1, y2))

p6 <- ggplot(mig_rates, aes(x = pair_label, y = mover_rate * 100, group = 1)) +
  geom_line(color = apep_colors[1], linewidth = 1) +
  geom_point(color = apep_colors[1], size = 3) +
  geom_text(aes(label = sprintf("%.1f%%", mover_rate * 100)),
            vjust = -1, size = 3.5) +
  labs(
    title = "Interstate Migration Rates Across Census Decades",
    subtitle = "Share of linked individuals who changed state of residence",
    x = "Decade Pair",
    y = "Interstate Migration Rate (%)"
  ) +
  scale_y_continuous(labels = function(x) paste0(x, "%")) +
  theme_apep()

ggsave(file.path(FIG_DIR, "fig6_migration_rates.pdf"), p6, width = 8, height = 5)

# =============================================================================
# Figure 7: Farm-to-nonfarm transitions by race
# =============================================================================
cat("Figure 7: Farm exit by race\n")

farm_by_race <- race_patterns %>%
  filter(!is.na(pct_farm_y1) & !is.na(pct_farm_y2)) %>%
  mutate(
    farm_decline = pct_farm_y1 - pct_farm_y2,
    pair_label = gsub("-", "\u2192", pair)
  )

p7 <- ggplot(farm_by_race, aes(x = pair_label, y = farm_decline * 100,
                                 fill = race_label)) +
  geom_col(position = "dodge", width = 0.6) +
  scale_fill_manual(values = c("White" = apep_colors[1], "Black" = apep_colors[2]),
                    name = "Race") +
  labs(
    title = "Farm-to-Nonfarm Transitions by Race",
    subtitle = "Percentage point decline in farm residence within linked individuals",
    x = "Decade Pair",
    y = "Net Change in Farm Residence (pp)"
  ) +
  theme_apep() +
  theme(axis.text.x = element_text(angle = 30, hjust = 1))

ggsave(file.path(FIG_DIR, "fig7_farm_exit_race.pdf"), p7, width = 8, height = 5)

# =============================================================================
# Figure 8: ABE vs MLP comparison
# =============================================================================
cat("Figure 8: ABE vs MLP\n")

if (nrow(abe_detail) > 0) {
  abe_overall <- abe_detail %>%
    group_by(pair, source) %>%
    summarize(
      link_rate = sum(n_linked) / sum(n_total) * 100,
      .groups = "drop"
    ) %>%
    mutate(pair_label = gsub("-", "\u2192", pair))

  p8 <- ggplot(abe_overall, aes(x = pair_label, y = link_rate, fill = source)) +
    geom_col(position = "dodge", width = 0.6) +
    scale_fill_manual(values = c("ABE" = apep_colors[2], "MLP" = apep_colors[1]),
                      name = "Crosswalk") +
    labs(
      title = "Linkage Rate Comparison: MLP v2.0 vs ABE Crosswalks",
      subtitle = "Overall population link rates for overlapping decade pairs",
      x = "Decade Pair",
      y = "Link Rate (%)"
    ) +
    scale_y_continuous(labels = function(x) paste0(x, "%")) +
    theme_apep()

  ggsave(file.path(FIG_DIR, "fig8_abe_comparison.pdf"), p8, width = 8, height = 5)
}

# =============================================================================
# Figure 9: Occupation switching rates over time
# =============================================================================
cat("Figure 9: Occupation switching\n")

occ_switch_plot <- occ_switching %>%
  mutate(pair_label = gsub("-", "\u2192", pair))

p9 <- ggplot(occ_switch_plot, aes(x = pair_label, y = switch_rate * 100, group = 1)) +
  geom_line(color = apep_colors[3], linewidth = 1) +
  geom_point(color = apep_colors[3], size = 3) +
  geom_text(aes(label = sprintf("%.1f%%", switch_rate * 100)),
            vjust = -1, size = 3.5) +
  labs(
    title = "Occupation Switching Rates Across Decades",
    subtitle = "Share of linked individuals changing major occupation group",
    x = "Decade Pair",
    y = "Switching Rate (%)"
  ) +
  scale_y_continuous(labels = function(x) paste0(x, "%")) +
  theme_apep()

ggsave(file.path(FIG_DIR, "fig9_occ_switching.pdf"), p9, width = 8, height = 5)

# =============================================================================
# Figure 10: Demographic transitions summary
# =============================================================================
cat("Figure 10: Demographic transitions\n")

demo_long <- demo_transitions %>%
  mutate(pair_label = sprintf("%d\u2192%d", y1, y2)) %>%
  select(pair_label, mover_rate, urbanization_rate, marriage_entry) %>%
  pivot_longer(-pair_label, names_to = "transition", values_to = "rate") %>%
  mutate(
    transition = recode(transition,
      "mover_rate" = "Interstate Migration",
      "urbanization_rate" = "Farm Exit (net)",
      "marriage_entry" = "Marriage Entry (net)"
    )
  )

p10 <- ggplot(demo_long, aes(x = pair_label, y = rate * 100, color = transition, group = transition)) +
  geom_line(linewidth = 0.8) +
  geom_point(size = 2.5) +
  scale_color_manual(values = apep_colors[1:3], name = "Transition") +
  labs(
    title = "Demographic Transitions Across Census Decades",
    subtitle = "Individual-level rates of interstate migration, farm exit, and marriage",
    x = "Decade Pair",
    y = "Rate (%)"
  ) +
  scale_y_continuous(labels = function(x) paste0(x, "%")) +
  theme_apep() +
  theme(legend.position = "right")

ggsave(file.path(FIG_DIR, "fig10_demo_transitions.pdf"), p10, width = 9, height = 5)

cat("\nAll figures saved to", FIG_DIR, "\n")
