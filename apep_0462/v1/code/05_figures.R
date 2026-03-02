## 05_figures.R — Generate all figures
## apep_0462: Speed limit reversal and road safety in France

source(here::here("output", "apep_0462", "v1", "code", "00_packages.R"))

panel <- fread(file.path(DATA_DIR, "panel_quarterly.csv"))
annual <- fread(file.path(DATA_DIR, "panel_annual.csv"))
treat <- fread(file.path(DATA_DIR, "treatment_clean.csv"))
results <- readRDS(file.path(DATA_DIR, "main_results.rds"))
rob <- readRDS(file.path(DATA_DIR, "robustness_results.rds"))

# Recode late adopters
late_deps <- treat[reversal_year >= 2025, dep_code]
panel[dep_code %in% late_deps, treated := FALSE]
annual[dep_code %in% late_deps, treated := FALSE]

# ── Figure 1: Treatment Rollout ──────────────────────────────────────

treat_active <- treat[reversal_year < 2025]
rollout_q <- treat_active[, .(n = .N), by = .(reversal_year, reversal_quarter)]
rollout_q[, yq := reversal_year + (reversal_quarter - 1) / 4]
rollout_q <- rollout_q[order(yq)]
rollout_q[, cum_n := cumsum(n)]

fig1 <- ggplot(rollout_q, aes(x = yq, y = cum_n)) +
  geom_step(color = apep_colors[1], linewidth = 1.2) +
  geom_point(aes(size = n), color = apep_colors[1]) +
  geom_vline(xintercept = 2019 + 11/12, linetype = "dashed", color = "grey50") +
  annotate("text", x = 2019.8, y = 42, label = "LOM\nDec 2019",
           size = 3, color = "grey40", hjust = 1) +
  scale_x_continuous(breaks = 2020:2024) +
  scale_y_continuous(breaks = seq(0, 50, 10)) +
  scale_size_continuous(range = c(2, 6), guide = "none") +
  labs(x = "Year", y = "Cumulative départements (90 km/h restored)",
       title = "Treatment Rollout: Staggered Reversal to 90 km/h") +
  theme_apep()

ggsave(file.path(FIG_DIR, "fig1_rollout.pdf"), fig1, width = 8, height = 5)
cat("Figure 1 saved.\n")

# ── Figure 2: Event Study — CS-DiD Accidents ─────────────────────────

es <- results$es_accidents
es_df <- data.frame(
  time = es$egt,
  att  = es$att.egt,
  se   = es$se.egt
)
es_df <- es_df[!is.na(es_df$se), ]

fig2 <- ggplot(es_df, aes(x = time, y = att)) +
  geom_ribbon(aes(ymin = att - 1.96 * se, ymax = att + 1.96 * se),
              alpha = 0.2, fill = apep_colors[1]) +
  geom_point(color = apep_colors[1], size = 2) +
  geom_line(color = apep_colors[1], linewidth = 0.6) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
  geom_vline(xintercept = -0.5, linetype = "dotted", color = "grey60") +
  scale_x_continuous(breaks = seq(-8, 16, 4)) +
  labs(x = "Quarters Relative to 90 km/h Reversal",
       y = "ATT (Accidents per Quarter)",
       title = "Event Study: Total Corporal Accidents",
       subtitle = "Callaway-Sant'Anna (2021), never-treated control group") +
  theme_apep()

ggsave(file.path(FIG_DIR, "fig2_es_accidents.pdf"), fig2, width = 8, height = 5)
cat("Figure 2 saved.\n")

# ── Figure 3: Event Study — CS-DiD Fatalities ────────────────────────

esk <- results$es_killed
esk_df <- data.frame(
  time = esk$egt,
  att  = esk$att.egt,
  se   = esk$se.egt
)
esk_df <- esk_df[!is.na(esk_df$se), ]

fig3 <- ggplot(esk_df, aes(x = time, y = att)) +
  geom_ribbon(aes(ymin = att - 1.96 * se, ymax = att + 1.96 * se),
              alpha = 0.2, fill = apep_colors[2]) +
  geom_point(color = apep_colors[2], size = 2) +
  geom_line(color = apep_colors[2], linewidth = 0.6) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
  geom_vline(xintercept = -0.5, linetype = "dotted", color = "grey60") +
  scale_x_continuous(breaks = seq(-8, 16, 4)) +
  labs(x = "Quarters Relative to 90 km/h Reversal",
       y = "ATT (Fatalities per Quarter)",
       title = "Event Study: Fatalities",
       subtitle = "Callaway-Sant'Anna (2021), never-treated control group") +
  theme_apep()

ggsave(file.path(FIG_DIR, "fig3_es_killed.pdf"), fig3, width = 8, height = 5)
cat("Figure 3 saved.\n")

# ── Figure 4: Raw Trends — Treated vs Control ────────────────────────

trends <- annual[, .(
  accidents = mean(accidents),
  killed = mean(killed),
  casualties = mean(total_casualties)
), by = .(year, treated)]
trends[, group := fifelse(treated, "Reversed to 90 km/h", "Maintained 80 km/h")]

fig4a <- ggplot(trends, aes(x = year, y = accidents, color = group)) +
  geom_line(linewidth = 1) +
  geom_point(size = 2.5) +
  geom_vline(xintercept = 2019.5, linetype = "dashed", color = "grey50") +
  annotate("text", x = 2019.3, y = max(trends$accidents) * 0.9,
           label = "First reversals", size = 3, color = "grey40", hjust = 1) +
  scale_color_manual(values = apep_colors[1:2]) +
  labs(x = "Year", y = "Mean Accidents per Département",
       title = "Panel A: Total Corporal Accidents",
       color = "") +
  theme_apep()

fig4b <- ggplot(trends, aes(x = year, y = killed, color = group)) +
  geom_line(linewidth = 1) +
  geom_point(size = 2.5) +
  geom_vline(xintercept = 2019.5, linetype = "dashed", color = "grey50") +
  scale_color_manual(values = apep_colors[1:2]) +
  labs(x = "Year", y = "Mean Fatalities per Département",
       title = "Panel B: Fatalities",
       color = "") +
  theme_apep()

fig4 <- fig4a / fig4b + plot_layout(guides = "collect") &
  theme(legend.position = "bottom")

ggsave(file.path(FIG_DIR, "fig4_raw_trends.pdf"), fig4, width = 8, height = 9)
cat("Figure 4 saved.\n")

# ── Figure 5: Placebo Test — Autoroute vs Départementale ─────────────

# Compare treated-road and autoroute outcomes in treated départements
trends_road <- panel[treated == TRUE, .(
  dept_road = mean(accidents),
  autoroute = mean(accidents_auto)
), by = .(year, quarter)]
trends_road[, yq := year + (quarter - 1) / 4]
trends_road_long <- melt(trends_road, id.vars = c("year", "quarter", "yq"),
                          measure.vars = c("dept_road", "autoroute"),
                          variable.name = "road_type", value.name = "accidents")
trends_road_long[, road_label := fifelse(road_type == "dept_road",
                                          "Routes départementales (treated)",
                                          "Autoroutes (placebo)")]

fig5 <- ggplot(trends_road_long,
               aes(x = yq, y = accidents, color = road_label)) +
  geom_line(linewidth = 0.8) +
  geom_point(size = 1.5) +
  geom_vline(xintercept = 2020, linetype = "dashed", color = "grey50") +
  scale_color_manual(values = apep_colors[c(1, 2)]) +
  labs(x = "Year-Quarter", y = "Mean Accidents per Département",
       title = "Placebo: Treated Roads vs. Autoroutes in Reversal Départements",
       subtitle = "Both decline post-2020, suggesting COVID confounding",
       color = "") +
  theme_apep()

ggsave(file.path(FIG_DIR, "fig5_placebo_roads.pdf"), fig5, width = 8, height = 5)
cat("Figure 5 saved.\n")

# ── Figure 6: Randomization Inference ─────────────────────────────────

ri_df <- data.frame(coef = rob$ri_distribution)

fig6 <- ggplot(ri_df, aes(x = coef)) +
  geom_histogram(bins = 40, fill = "grey80", color = "grey60") +
  geom_vline(xintercept = rob$ri_actual, color = apep_colors[2],
             linewidth = 1.2, linetype = "solid") +
  annotate("text", x = rob$ri_actual, y = Inf, vjust = 2,
           label = sprintf("Actual = %.1f", rob$ri_actual),
           color = apep_colors[2], size = 3.5) +
  labs(x = "Permuted TWFE Coefficient",
       y = "Count",
       title = "Randomization Inference: TWFE Coefficient Distribution",
       subtitle = sprintf("500 permutations, RI p-value = %.4f", rob$ri_pvalue)) +
  theme_apep()

ggsave(file.path(FIG_DIR, "fig6_ri.pdf"), fig6, width = 8, height = 5)
cat("Figure 6 saved.\n")

# ── Figure 7: Coverage Map (Treatment Intensity) ─────────────────────

# Bar chart of treatment intensity by département
treat_plot <- treat_active[order(-share_pct)]
treat_plot[, dep_label := paste0(dep_name, " (", dep_code, ")")]
treat_plot[, dep_label := factor(dep_label, levels = rev(dep_label))]
treat_plot[, coverage_col := fifelse(coverage == "full", "Full network", "Partial")]

fig7 <- ggplot(treat_plot[1:30], aes(x = share_pct, y = dep_label, fill = coverage_col)) +
  geom_col() +
  scale_fill_manual(values = c("Full network" = apep_colors[1],
                                "Partial" = apep_colors[6])) +
  labs(x = "Share of Départemental Network at 90 km/h (%)",
       y = "",
       title = "Treatment Intensity: Top 30 Départements",
       fill = "") +
  theme_apep() +
  theme(axis.text.y = element_text(size = 7))

ggsave(file.path(FIG_DIR, "fig7_intensity.pdf"), fig7, width = 8, height = 8)
cat("Figure 7 saved.\n")

# ── Figure 8: Event Study — Hospitalized Injuries ────────────────────

esh <- results$es_hosp
esh_df <- data.frame(
  time = esh$egt,
  att  = esh$att.egt,
  se   = esh$se.egt
)
esh_df <- esh_df[!is.na(esh_df$se), ]

fig8 <- ggplot(esh_df, aes(x = time, y = att)) +
  geom_ribbon(aes(ymin = att - 1.96 * se, ymax = att + 1.96 * se),
              alpha = 0.2, fill = apep_colors[3]) +
  geom_point(color = apep_colors[3], size = 2) +
  geom_line(color = apep_colors[3], linewidth = 0.6) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
  geom_vline(xintercept = -0.5, linetype = "dotted", color = "grey60") +
  scale_x_continuous(breaks = seq(-8, 16, 4)) +
  labs(x = "Quarters Relative to 90 km/h Reversal",
       y = "ATT (Hospitalized per Quarter)",
       title = "Event Study: Serious Injuries (Hospitalized)",
       subtitle = "Callaway-Sant'Anna (2021), never-treated control group") +
  theme_apep()

ggsave(file.path(FIG_DIR, "fig8_es_hosp.pdf"), fig8, width = 8, height = 5)
cat("Figure 8 saved.\n")

# ── Figure 9: DDD Event Study ──────────────────────────────────────

ddd_es <- rob$ddd_es
ddd_es_coefs <- coeftable(ddd_es)
# Extract coefficients for the dept_road interaction terms
ddd_rows <- grepl("dept_road", rownames(ddd_es_coefs))
ddd_es_df <- data.frame(
  time = as.integer(gsub(".*rel_bin::(-?\\d+):.*", "\\1", rownames(ddd_es_coefs)[ddd_rows])),
  att  = ddd_es_coefs[ddd_rows, 1],
  se   = ddd_es_coefs[ddd_rows, 2]
)
ddd_es_df <- ddd_es_df[order(ddd_es_df$time), ]

fig9 <- ggplot(ddd_es_df, aes(x = time, y = att)) +
  geom_ribbon(aes(ymin = att - 1.96 * se, ymax = att + 1.96 * se),
              alpha = 0.2, fill = apep_colors[3]) +
  geom_point(color = apep_colors[3], size = 2) +
  geom_line(color = apep_colors[3], linewidth = 0.6) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
  geom_vline(xintercept = -0.5, linetype = "dotted", color = "grey60") +
  scale_x_continuous(breaks = seq(-8, 12, 4)) +
  labs(x = "Quarters Relative to 90 km/h Reversal",
       y = "DDD Coefficient (Accidents)",
       title = "Triple-Difference Event Study: Accidents",
       subtitle = "Dept. road × post relative to autoroute counterfactual within département") +
  theme_apep()

ggsave(file.path(FIG_DIR, "fig9_ddd_es.pdf"), fig9, width = 8, height = 5)
cat("Figure 9 saved.\n")

cat("\nAll figures generated.\n")
