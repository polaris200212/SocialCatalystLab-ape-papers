## =============================================================================
## 05_figures.R — Generate all figures
## apep_0497: Who Captures a Tax Cut?
## =============================================================================

source("00_packages.R")

cat("=== GENERATING FIGURES ===\n\n")

panel <- fread(file.path(data_dir, "analysis_panel.csv"))
panel[, code_commune := str_pad(as.character(code_commune), 5, pad = "0")]
panel[, code_dept := substr(code_commune, 1, 2)]

main_results <- readRDS(file.path(data_dir, "main_results.rds"))
rob_results <- readRDS(file.path(data_dir, "robustness_results.rds"))

## TH tercile labels
panel[!is.na(th_dose), th_tercile_lab := cut(th_dose,
  breaks = quantile(th_dose, c(0, 1/3, 2/3, 1), na.rm = TRUE),
  labels = c("Low TH", "Medium TH", "High TH"),
  include.lowest = TRUE)]

## =============================================================================
## Figure 1: Price Trends by TH Tercile
## =============================================================================

cat("--- Figure 1: Price trends by TH tercile ---\n")

trend_data <- panel[!is.na(th_tercile_lab) & !is.na(median_price), .(
  mean_price = mean(median_price, na.rm = TRUE),
  se_price = sd(median_price, na.rm = TRUE) / sqrt(.N),
  n = .N
), by = .(year, th_tercile_lab)]

fig1 <- ggplot(trend_data, aes(x = year, y = mean_price / 1000,
                                color = th_tercile_lab, linetype = th_tercile_lab)) +
  geom_line(linewidth = 0.8) +
  geom_point(size = 2) +
  geom_vline(xintercept = 2017.5, linetype = "dashed", alpha = 0.5) +
  annotate("text", x = 2017.5, y = max(trend_data$mean_price / 1000) * 0.95,
           label = "Reform", hjust = -0.1, size = 3, fontface = "italic") +
  scale_color_manual(values = c("#2166AC", "#B2182B", "#4DAF4A")) +
  labs(
    x = "Year", y = "Mean Median Price (thousands of euros)",
    color = "TH Tercile", linetype = "TH Tercile",
    title = NULL
  ) +
  theme(legend.position = "bottom")

ggsave(file.path(fig_dir, "fig1_price_trends.pdf"), fig1, width = 8, height = 5)
cat("  Saved fig1_price_trends.pdf\n")

## =============================================================================
## Figure 2: Event Study — Dynamic Treatment Effects
## =============================================================================

cat("--- Figure 2: Event study ---\n")

es_model <- main_results$es

es_coefs <- coeftable(es_model)
## Filter to only rel_year coefficients (exclude share_apartments etc.)
es_idx <- grep("^rel_year::", rownames(es_coefs))
es_coefs_sub <- es_coefs[es_idx, , drop = FALSE]
es_dt <- data.table(
  rel_year = as.integer(gsub("rel_year::(-?\\d+):th_dose_std", "\\1", rownames(es_coefs_sub))),
  estimate = es_coefs_sub[, 1],
  se = es_coefs_sub[, 2]
)
es_dt[, ci_lo := estimate - 1.96 * se]
es_dt[, ci_hi := estimate + 1.96 * se]

## Add reference point (rel_year = -1, coef = 0)
es_dt <- rbind(es_dt, data.table(rel_year = -1, estimate = 0, se = 0, ci_lo = 0, ci_hi = 0))
es_dt <- es_dt[order(rel_year)]

fig2 <- ggplot(es_dt, aes(x = rel_year, y = estimate)) +
  geom_hline(yintercept = 0, linetype = "dashed", alpha = 0.5) +
  geom_vline(xintercept = -0.5, linetype = "dashed", color = "red", alpha = 0.5) +
  geom_ribbon(aes(ymin = ci_lo, ymax = ci_hi), alpha = 0.2, fill = "#2166AC") +
  geom_line(color = "#2166AC", linewidth = 0.7) +
  geom_point(color = "#2166AC", size = 2.5) +
  labs(
    x = "Years Relative to Reform (2018)",
    y = expression(beta[t] ~ "(TH Dose" %*% "Year)"),
    title = NULL
  ) +
  scale_x_continuous(breaks = seq(-4, 6, 1))

ggsave(file.path(fig_dir, "fig2_event_study.pdf"), fig2, width = 8, height = 5)
cat("  Saved fig2_event_study.pdf\n")

## =============================================================================
## Figure 2b: Apartment-Specific Event Study
## =============================================================================

cat("--- Figure 2b: Apartment event study ---\n")

es_apt_model <- readRDS(file.path(data_dir, "event_study_apt_model.rds"))

es_apt_coefs <- coeftable(es_apt_model)
es_apt_idx <- grep("^rel_year::", rownames(es_apt_coefs))
es_apt_sub <- es_apt_coefs[es_apt_idx, , drop = FALSE]
es_apt_dt <- data.table(
  rel_year = as.integer(gsub("rel_year::(-?\\d+):th_dose_std", "\\1", rownames(es_apt_sub))),
  estimate = es_apt_sub[, 1],
  se = es_apt_sub[, 2]
)
es_apt_dt[, ci_lo := estimate - 1.96 * se]
es_apt_dt[, ci_hi := estimate + 1.96 * se]

## Add reference point
es_apt_dt <- rbind(es_apt_dt, data.table(rel_year = -1, estimate = 0, se = 0, ci_lo = 0, ci_hi = 0))
es_apt_dt <- es_apt_dt[order(rel_year)]

fig2b <- ggplot(es_apt_dt, aes(x = rel_year, y = estimate)) +
  geom_hline(yintercept = 0, linetype = "dashed", alpha = 0.5) +
  geom_vline(xintercept = -0.5, linetype = "dashed", color = "red", alpha = 0.5) +
  geom_ribbon(aes(ymin = ci_lo, ymax = ci_hi), alpha = 0.2, fill = "#2166AC") +
  geom_line(color = "#2166AC", linewidth = 0.7) +
  geom_point(color = "#2166AC", size = 2.5) +
  labs(
    x = "Years Relative to Reform (2018)",
    y = "Effect on Log Apartment Price per m\u00b2",
    title = NULL
  ) +
  scale_x_continuous(breaks = seq(-4, 6, 1))

ggsave(file.path(fig_dir, "fig2b_event_study_apt.pdf"), fig2b, width = 8, height = 5)
cat("  Saved fig2b_event_study_apt.pdf\n")

## =============================================================================
## Figure 3: Leave-One-Out Départements
## =============================================================================

cat("--- Figure 3: Leave-one-out ---\n")

loo_results <- rob_results$loo

## Main coefficient for comparison
main_coef <- coef(main_results$m1)[1]

fig3 <- ggplot(loo_results, aes(x = reorder(dept_dropped, coef), y = coef)) +
  geom_hline(yintercept = main_coef, linetype = "dashed", color = "red", alpha = 0.7) +
  geom_point(size = 1, alpha = 0.7) +
  geom_errorbar(aes(ymin = coef - 1.96 * se, ymax = coef + 1.96 * se),
                width = 0, alpha = 0.3) +
  labs(
    x = "Département Dropped",
    y = "Coefficient (TH Dose x Post)",
    title = NULL
  ) +
  theme(axis.text.x = element_blank(), axis.ticks.x = element_blank())

ggsave(file.path(fig_dir, "fig3_loo.pdf"), fig3, width = 8, height = 4)
cat("  Saved fig3_loo.pdf\n")

## =============================================================================
## Figure 4: TH Rate Distribution
## =============================================================================

cat("--- Figure 4: TH rate distribution ---\n")

th_dist <- panel[year == 2017 & !is.na(th_rate_2017)]
th_dist <- th_dist[!duplicated(code_commune)]

fig4 <- ggplot(th_dist, aes(x = th_rate_2017)) +
  geom_histogram(bins = 60, fill = "#2166AC", alpha = 0.7, color = "white") +
  geom_vline(xintercept = median(th_dist$th_rate_2017, na.rm = TRUE),
             linetype = "dashed", color = "red") +
  annotate("text", x = median(th_dist$th_rate_2017, na.rm = TRUE),
           y = Inf, label = "Median", hjust = -0.2, vjust = 2,
           color = "red", size = 3) +
  labs(
    x = "Communal TH Rate 2017 (%)",
    y = "Number of Communes",
    title = NULL
  )

ggsave(file.path(fig_dir, "fig4_th_distribution.pdf"), fig4, width = 7, height = 4)
cat("  Saved fig4_th_distribution.pdf\n")

## =============================================================================
## Figure 5: Binned Scatter — TH Rate vs Price Change
## =============================================================================

cat("--- Figure 5: Binned scatter ---\n")

## Compute pre-post price change by commune
pre <- panel[year %in% 2015:2017 & !is.na(log_price), .(
  log_price_pre = mean(log_price, na.rm = TRUE)
), by = code_commune]

post_data <- panel[year %in% 2019:2022 & !is.na(log_price), .(
  log_price_post = mean(log_price, na.rm = TRUE)
), by = code_commune]

change <- merge(pre, post_data, by = "code_commune")
change[, delta_log_price := log_price_post - log_price_pre]

## Merge TH rate
th_rates <- unique(panel[!is.na(th_rate_2017), .(code_commune, th_rate_2017)])
change <- merge(change, th_rates, by = "code_commune")

## Create bins
change[, th_bin := cut(th_rate_2017,
  breaks = quantile(th_rate_2017, seq(0, 1, 0.05), na.rm = TRUE),
  include.lowest = TRUE)]

bin_means <- change[!is.na(th_bin), .(
  mean_th = mean(th_rate_2017),
  mean_delta = mean(delta_log_price),
  se_delta = sd(delta_log_price) / sqrt(.N),
  n = .N
), by = th_bin]

fig5 <- ggplot(bin_means, aes(x = mean_th, y = mean_delta)) +
  geom_point(aes(size = n), alpha = 0.7, color = "#2166AC") +
  geom_smooth(method = "lm", se = TRUE, color = "#B2182B",
              fill = "#B2182B", alpha = 0.15, linewidth = 0.7) +
  scale_size_continuous(range = c(1, 4), guide = "none") +
  labs(
    x = "Communal TH Rate 2017 (%)",
    y = expression(Delta * " Log Price (2019-22 vs 2015-17)"),
    title = NULL
  )

ggsave(file.path(fig_dir, "fig5_binscatter.pdf"), fig5, width = 7, height = 5)
cat("  Saved fig5_binscatter.pdf\n")

## =============================================================================
## Figure 6: Supply Elasticity Heterogeneity
## =============================================================================

cat("--- Figure 6: Supply elasticity heterogeneity ---\n")

## Get coefficients from dense vs sparse models
dense_coef <- coef(rob_results$dense)[1]
dense_se <- se(rob_results$dense)[1]
sparse_coef <- coef(rob_results$sparse)[1]
sparse_se <- se(rob_results$sparse)[1]

het_dt <- data.table(
  group = c("Dense\n(Supply-constrained)", "Sparse\n(Supply-elastic)"),
  coef = c(dense_coef, sparse_coef),
  se = c(dense_se, sparse_se)
)
het_dt[, ci_lo := coef - 1.96 * se]
het_dt[, ci_hi := coef + 1.96 * se]

fig6 <- ggplot(het_dt, aes(x = group, y = coef)) +
  geom_hline(yintercept = 0, linetype = "dashed", alpha = 0.5) +
  geom_point(size = 3, color = "#2166AC") +
  geom_errorbar(aes(ymin = ci_lo, ymax = ci_hi), width = 0.2, color = "#2166AC") +
  labs(
    x = NULL,
    y = "Coefficient (TH Dose x Post)",
    title = NULL
  )

ggsave(file.path(fig_dir, "fig6_supply_elasticity.pdf"), fig6, width = 5, height = 4)
cat("  Saved fig6_supply_elasticity.pdf\n")

## =============================================================================
## Figure 7: Normalized Price Trends (Pre-reform = 100)
## =============================================================================

cat("--- Figure 7: Normalized price trends ---\n")

## Normalize to 2017 = 100
base_prices <- panel[year == 2017 & !is.na(th_tercile_lab) & !is.na(median_price), .(
  base_price = mean(median_price, na.rm = TRUE)
), by = th_tercile_lab]

norm_trend <- merge(trend_data, base_prices, by = "th_tercile_lab")
norm_trend[, index := mean_price / base_price * 100]

fig7 <- ggplot(norm_trend, aes(x = year, y = index,
                                color = th_tercile_lab, linetype = th_tercile_lab)) +
  geom_line(linewidth = 0.8) +
  geom_point(size = 2) +
  geom_vline(xintercept = 2017.5, linetype = "dashed", alpha = 0.5) +
  geom_hline(yintercept = 100, linetype = "dotted", alpha = 0.3) +
  scale_color_manual(values = c("#2166AC", "#B2182B", "#4DAF4A")) +
  labs(
    x = "Year", y = "Price Index (2017 = 100)",
    color = "TH Tercile", linetype = "TH Tercile",
    title = NULL
  ) +
  theme(legend.position = "bottom")

ggsave(file.path(fig_dir, "fig7_normalized_trends.pdf"), fig7, width = 8, height = 5)
cat("  Saved fig7_normalized_trends.pdf\n")

cat("\n=== ALL FIGURES GENERATED ===\n")
cat("Files in", fig_dir, ":\n")
print(list.files(fig_dir))
