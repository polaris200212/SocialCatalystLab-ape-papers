## ============================================================================
## 05_figures.R — All figures for the paper
## apep_0467: Priced Out of Care
##
## Figures:
##   1. Wage ratio distribution map
##   2. Main event study (providers)
##   3. Multi-outcome event study panel
##   4. Tercile event study
##   5. Behavioral health placebo comparison
##   6. Randomization inference distribution
##   7. Leave-one-out sensitivity
##   8. Raw trends by tercile (pre/post)
##   9. Scatter: wage ratio vs provider change
## ============================================================================

source("00_packages.R")

panel <- readRDS(file.path(DATA, "panel_analysis.rds"))
wage_ratio <- readRDS(file.path(DATA, "state_wage_ratio.rds"))
results <- readRDS(file.path(DATA, "main_results.rds"))
rob <- readRDS(file.path(DATA, "robustness_results.rds"))
ri <- readRDS(file.path(DATA, "ri_results.rds"))
loo <- readRDS(file.path(DATA, "loo_results.rds"))


## ============================================================
## Figure 1: Wage Ratio Map
## ============================================================
cat("Figure 1: Wage ratio map...\n")

us_states <- tigris::states(cb = TRUE, resolution = "20m", year = 2020) |>
  st_transform(crs = 2163) |>
  filter(!STUSPS %in% c("PR", "VI", "GU", "AS", "MP"))

map_data <- merge(us_states, wage_ratio, by.x = "STUSPS", by.y = "state", all.x = TRUE)

fig1 <- ggplot(map_data) +
  geom_sf(aes(fill = wage_ratio), color = "white", linewidth = 0.2) +
  scale_fill_gradient2(
    low = "#D55E00", mid = "#F0E442", high = "#009E73",
    midpoint = median(wage_ratio$wage_ratio, na.rm = TRUE),
    name = "Wage Ratio\n(PCA / Competing)",
    na.value = "grey80"
  ) +
  theme_apep() +
  theme(
    axis.text = element_blank(),
    axis.ticks = element_blank(),
    axis.title = element_blank(),
    axis.line = element_blank(),
    panel.grid = element_blank()
  ) +
  labs(
    title = "Medicaid HCBS Wage Competitiveness, 2019",
    subtitle = "Ratio of personal care aide wages to competing low-wage occupations",
    caption = "Source: BLS Occupational Employment Statistics, May 2019"
  )

ggsave(file.path(FIGS, "fig1_wage_ratio_map.pdf"), fig1, width = 10, height = 7)
cat("  Saved fig1_wage_ratio_map.pdf\n")


## ============================================================
## Figure 2: Main Event Study (Providers)
## ============================================================
cat("Figure 2: Main event study...\n")

es <- results$es_providers
es_data <- data.table(
  time = as.numeric(names(coef(es))),
  coef = as.numeric(coef(es)),
  se = as.numeric(se(es))
)
# Parse event_time from coefficient names
es_data[, time := as.numeric(gsub(".*::(-?[0-9]+):.*", "\\1", names(coef(es))))]
es_data <- es_data[!is.na(time)]
es_data[, `:=`(ci_lo = coef - 1.96 * se, ci_hi = coef + 1.96 * se)]

# Add reference point
es_data <- rbind(es_data, data.table(time = 0, coef = 0, se = 0, ci_lo = 0, ci_hi = 0))
setorder(es_data, time)

# Trim to reasonable range (-24 to +48)
es_data <- es_data[time >= -24 & time <= 48]

fig2 <- ggplot(es_data, aes(x = time, y = coef)) +
  geom_ribbon(aes(ymin = ci_lo, ymax = ci_hi), alpha = 0.15, fill = apep_colors[1]) +
  geom_line(color = apep_colors[1], linewidth = 0.7) +
  geom_point(color = apep_colors[1], size = 1.5) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
  geom_vline(xintercept = 1.5, linetype = "dotted", color = "red3", linewidth = 0.5) +
  annotate("text", x = 3, y = max(es_data$ci_hi) * 0.9, label = "COVID-19",
           color = "red3", size = 3.5, hjust = 0) +
  scale_x_continuous(breaks = seq(-24, 48, 6)) +
  theme_apep() +
  labs(
    x = "Months Relative to January 2020",
    y = "Coefficient on Wage Ratio × Month",
    title = "Event Study: Wage Competitiveness and HCBS Provider Supply",
    subtitle = "Higher wage ratio (more competitive) associated with better provider retention post-COVID",
    caption = "Notes: 95% CI. State and month FE. Clustered at state level."
  )

ggsave(file.path(FIGS, "fig2_event_study_providers.pdf"), fig2, width = 10, height = 6)
cat("  Saved fig2_event_study_providers.pdf\n")


## ============================================================
## Figure 3: Multi-Outcome Event Study Panel
## ============================================================
cat("Figure 3: Multi-outcome panel...\n")

extract_es <- function(model, outcome_name) {
  cf <- coef(model)
  ses <- se(model)
  nms <- names(cf)
  times <- as.numeric(gsub(".*::(-?[0-9]+):.*", "\\1", nms))
  dt <- data.table(time = times, coef = as.numeric(cf), se = as.numeric(ses))
  dt <- dt[!is.na(time)]
  dt[, outcome := outcome_name]
  dt <- rbind(dt, data.table(time = 0, coef = 0, se = 0, outcome = outcome_name))
  dt[, `:=`(ci_lo = coef - 1.96 * se, ci_hi = coef + 1.96 * se)]
  dt[time >= -24 & time <= 48]
}

es_all <- rbindlist(list(
  extract_es(results$es_providers, "Active Providers"),
  extract_es(results$es_beneficiaries, "Beneficiaries Served"),
  extract_es(results$es_spending, "Total Spending")
))

fig3 <- ggplot(es_all, aes(x = time, y = coef)) +
  geom_ribbon(aes(ymin = ci_lo, ymax = ci_hi), alpha = 0.15, fill = apep_colors[1]) +
  geom_line(color = apep_colors[1], linewidth = 0.6) +
  geom_point(color = apep_colors[1], size = 1) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
  geom_vline(xintercept = 1.5, linetype = "dotted", color = "red3", linewidth = 0.5) +
  facet_wrap(~outcome, scales = "free_y", ncol = 1) +
  scale_x_continuous(breaks = seq(-24, 48, 12)) +
  theme_apep() +
  labs(
    x = "Months Relative to January 2020",
    y = "Coefficient on Wage Ratio × Month",
    title = "The Monopsony Stress Test: Multiple Outcomes",
    caption = "Notes: 95% CI. State and month FE. Clustered at state level."
  )

ggsave(file.path(FIGS, "fig3_multi_outcome_es.pdf"), fig3, width = 9, height = 10)
cat("  Saved fig3_multi_outcome_es.pdf\n")


## ============================================================
## Figure 4: Tercile Event Study
## ============================================================
cat("Figure 4: Tercile event study...\n")

es_terc <- results$es_tercile
cf <- coef(es_terc)
ses <- se(es_terc)
nms <- names(cf)

# Parse tercile and time from coefficient names
terc_data <- data.table(
  name = nms,
  coef = as.numeric(cf),
  se = as.numeric(ses)
)
terc_data[, time := as.numeric(gsub(".*::(-?[0-9]+):.*", "\\1", name))]
terc_data[, tercile := ifelse(grepl("Low", name), "Low", "Medium")]
terc_data <- terc_data[!is.na(time) & time >= -24 & time <= 48]
terc_data[, `:=`(ci_lo = coef - 1.96 * se, ci_hi = coef + 1.96 * se)]

# Add reference points
for (tc in c("Low", "Medium")) {
  terc_data <- rbind(terc_data,
    data.table(name = "", coef = 0, se = 0, time = 0, tercile = tc, ci_lo = 0, ci_hi = 0)
  )
}

fig4 <- ggplot(terc_data, aes(x = time, y = coef, color = tercile, fill = tercile)) +
  geom_ribbon(aes(ymin = ci_lo, ymax = ci_hi), alpha = 0.1, color = NA) +
  geom_line(linewidth = 0.7) +
  geom_point(size = 1.5) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
  geom_vline(xintercept = 1.5, linetype = "dotted", color = "red3", linewidth = 0.5) +
  scale_color_manual(values = c("Low" = apep_colors[2], "Medium" = apep_colors[5]),
                     name = "Wage Ratio Tercile\n(ref: High)") +
  scale_fill_manual(values = c("Low" = apep_colors[2], "Medium" = apep_colors[5]),
                    name = "Wage Ratio Tercile\n(ref: High)") +
  scale_x_continuous(breaks = seq(-24, 48, 6)) +
  theme_apep() +
  labs(
    x = "Months Relative to January 2020",
    y = "Coefficient (relative to High tercile)",
    title = "Provider Supply by Wage Competitiveness Tercile",
    subtitle = "Low-competitiveness states show larger post-COVID provider losses",
    caption = "Notes: High tercile (most competitive) is reference group. 95% CI."
  )

ggsave(file.path(FIGS, "fig4_tercile_es.pdf"), fig4, width = 10, height = 6)
cat("  Saved fig4_tercile_es.pdf\n")


## ============================================================
## Figure 5: Behavioral Health Placebo
## ============================================================
cat("Figure 5: BH placebo...\n")

panel_bh <- readRDS(file.path(DATA, "panel_bh.rds"))
panel_bh[, event_time := as.integer(round(difftime(month_date, as.Date("2020-01-01"), units = "days") / 30.44))]

es_bh <- feols(
  log_bh_providers ~ i(event_time, wage_ratio, ref = 0) | state + month_date,
  data = panel_bh[!is.na(wage_ratio)],
  cluster = ~state
)

es_bh_data <- extract_es(es_bh, "Behavioral Health (Placebo)")
es_hcbs_data <- extract_es(results$es_providers, "HCBS (Treatment)")
placebo_compare <- rbindlist(list(es_hcbs_data, es_bh_data))

fig5 <- ggplot(placebo_compare, aes(x = time, y = coef, color = outcome, fill = outcome)) +
  geom_ribbon(aes(ymin = ci_lo, ymax = ci_hi), alpha = 0.1, color = NA) +
  geom_line(linewidth = 0.7) +
  geom_point(size = 1.5) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
  geom_vline(xintercept = 1.5, linetype = "dotted", color = "red3", linewidth = 0.5) +
  scale_color_manual(values = c("HCBS (Treatment)" = apep_colors[1],
                                "Behavioral Health (Placebo)" = apep_colors[3]),
                     name = "") +
  scale_fill_manual(values = c("HCBS (Treatment)" = apep_colors[1],
                               "Behavioral Health (Placebo)" = apep_colors[3]),
                    name = "") +
  scale_x_continuous(breaks = seq(-24, 48, 12)) +
  theme_apep() +
  labs(
    x = "Months Relative to January 2020",
    y = "Coefficient on Wage Ratio × Month",
    title = "Falsification: HCBS vs. Behavioral Health Providers",
    subtitle = "Wage ratio predicts HCBS disruption but not behavioral health (telehealth-eligible)",
    caption = "Notes: 95% CI. State and month FE. Clustered at state level."
  )

ggsave(file.path(FIGS, "fig5_placebo_bh.pdf"), fig5, width = 10, height = 6)
cat("  Saved fig5_placebo_bh.pdf\n")


## ============================================================
## Figure 6: Randomization Inference
## ============================================================
cat("Figure 6: RI distribution...\n")

ri_data <- data.table(coef = ri$perm_coefs[!is.na(ri$perm_coefs)])

fig6 <- ggplot(ri_data, aes(x = coef)) +
  geom_histogram(bins = 50, fill = "grey70", color = "white") +
  geom_vline(xintercept = ri$main_coef, color = apep_colors[1], linewidth = 1.2) +
  annotate("text", x = ri$main_coef, y = Inf, vjust = 2,
           label = sprintf("Observed: %.4f\nRI p = %.3f", ri$main_coef, ri$ri_pvalue),
           color = apep_colors[1], size = 3.5, fontface = "bold") +
  theme_apep() +
  labs(
    x = "Permuted Coefficients",
    y = "Count",
    title = "Randomization Inference: Permutation Distribution",
    subtitle = sprintf("500 permutations of wage ratio across states (p = %.3f)", ri$ri_pvalue),
    caption = "Notes: Vertical line shows observed coefficient."
  )

ggsave(file.path(FIGS, "fig6_ri_distribution.pdf"), fig6, width = 8, height = 5)
cat("  Saved fig6_ri_distribution.pdf\n")


## ============================================================
## Figure 7: Leave-One-Out
## ============================================================
cat("Figure 7: Leave-one-out...\n")

loo_data <- data.table(state = names(loo), coef = as.numeric(loo))
loo_data[, deviation := coef - ri$main_coef]
setorder(loo_data, coef)
loo_data[, rank := seq_len(.N)]

fig7 <- ggplot(loo_data, aes(x = rank, y = coef)) +
  geom_point(color = apep_colors[1], size = 2) +
  geom_hline(yintercept = ri$main_coef, linetype = "dashed", color = "red3") +
  geom_hline(yintercept = 0, linetype = "solid", color = "grey40") +
  geom_text(data = loo_data[rank %in% c(1, 2, .N - 1, .N)],
            aes(label = state), hjust = -0.3, size = 3) +
  theme_apep() +
  labs(
    x = "State Rank",
    y = "Coefficient (dropping one state)",
    title = "Leave-One-Out Sensitivity",
    subtitle = "No single state drives the main result",
    caption = "Notes: Dashed line shows full-sample estimate."
  )

ggsave(file.path(FIGS, "fig7_loo.pdf"), fig7, width = 9, height = 5)
cat("  Saved fig7_loo.pdf\n")


## ============================================================
## Figure 8: Raw Trends by Tercile
## ============================================================
cat("Figure 8: Raw trends...\n")

tercile_trends <- panel[!is.na(ratio_tercile), .(
  avg_providers = mean(n_providers),
  avg_beneficiaries = mean(total_beneficiaries)
), by = .(ratio_tercile, month_date)]

# Normalize to January 2020 = 100
baseline <- tercile_trends[month_date == as.Date("2020-01-01"),
                           .(ratio_tercile, base_prov = avg_providers, base_ben = avg_beneficiaries)]
tercile_trends <- merge(tercile_trends, baseline, by = "ratio_tercile")
tercile_trends[, `:=`(
  idx_providers = avg_providers / base_prov * 100,
  idx_beneficiaries = avg_beneficiaries / base_ben * 100
)]

fig8 <- ggplot(tercile_trends, aes(x = month_date, y = idx_providers,
                                    color = ratio_tercile)) +
  geom_line(linewidth = 0.8) +
  geom_vline(xintercept = as.Date("2020-03-01"), linetype = "dotted",
             color = "red3", linewidth = 0.5) +
  geom_hline(yintercept = 100, linetype = "dashed", color = "grey40") +
  scale_color_manual(values = c("Low" = apep_colors[2], "Medium" = apep_colors[5],
                                "High" = apep_colors[3]),
                     name = "Wage Ratio Tercile") +
  theme_apep() +
  labs(
    x = "",
    y = "Index (Jan 2020 = 100)",
    title = "HCBS Provider Counts by Wage Competitiveness Tercile",
    subtitle = "Raw trends normalized to January 2020",
    caption = "Source: T-MSIS Provider Spending × BLS OES wage data"
  )

ggsave(file.path(FIGS, "fig8_raw_trends.pdf"), fig8, width = 10, height = 6)
cat("  Saved fig8_raw_trends.pdf\n")


## ============================================================
## Figure 9: Cross-Sectional Scatter
## ============================================================
cat("Figure 9: Scatter plot...\n")

# Compute provider change: post-COVID average vs pre-COVID average
change_data <- panel[, .(
  pre_providers = mean(n_providers[post_covid == 0]),
  post_providers = mean(n_providers[post_covid == 1])
), by = .(state, wage_ratio)]
change_data[, pct_change := (post_providers - pre_providers) / pre_providers * 100]

fig9 <- ggplot(change_data, aes(x = wage_ratio, y = pct_change)) +
  geom_point(size = 3, color = apep_colors[1], alpha = 0.7) +
  geom_smooth(method = "lm", se = TRUE, color = apep_colors[2], fill = apep_colors[2],
              alpha = 0.15) +
  geom_text(aes(label = state), hjust = -0.2, vjust = -0.2, size = 2.5, color = "grey40") +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
  theme_apep() +
  labs(
    x = "Wage Competitiveness Ratio (2019)",
    y = "% Change in HCBS Providers (Pre vs Post-COVID)",
    title = "Wage Competitiveness Predicts Provider Resilience",
    subtitle = "States with higher wage ratios retained more providers through the pandemic",
    caption = "Source: T-MSIS Provider Spending × BLS OES wage data"
  )

ggsave(file.path(FIGS, "fig9_scatter.pdf"), fig9, width = 9, height = 7)
cat("  Saved fig9_scatter.pdf\n")


cat("\n=== All figures saved ===\n")
