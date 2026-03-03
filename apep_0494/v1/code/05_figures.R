## ===========================================================================
## 05_figures.R — All Figure Generation
## apep_0494: Property Tax Capitalization from France's TH Abolition
## ===========================================================================

source("00_packages.R")

# ============================================================================
# 1. Load Data and Models
# ============================================================================

cat("=== Loading data for figures ===\n")
dvf <- fread(file.path(DAT, "dvf_analysis.csv"))
panel <- fread(file.path(DAT, "panel_commune_year.csv"))
dvf[, code_commune := as.factor(code_commune)]
dvf[, dept := as.factor(dept)]

# Load saved models
es_model <- readRDS(file.path(DAT, "event_study_model.rds"))
es_binned <- readRDS(file.path(DAT, "event_study_binned.rds"))

# Load LOO results if available
loo_file <- file.path(DAT, "loo_results.rds")
loo_results <- if (file.exists(loo_file)) readRDS(loo_file) else NULL

# Try fiscal substitution ES
fs_es_file <- file.path(DAT, "fiscal_substitution_es.rds")
fs_es <- if (file.exists(fs_es_file)) readRDS(fs_es_file) else NULL

dir.create(OUT, showWarnings = FALSE, recursive = TRUE)


# ============================================================================
# Figure 1: Distribution of Pre-Reform TH Rates (2017)
# ============================================================================

cat("\n=== Figure 1: TH Distribution ===\n")

th_baseline <- fread(file.path(DAT, "th_baseline_2017.csv"))

p1 <- ggplot(th_baseline, aes(x = th_rate_2017)) +
  geom_histogram(binwidth = 2, fill = "steelblue", color = "white", alpha = 0.8) +
  geom_vline(xintercept = median(th_baseline$th_rate_2017, na.rm = TRUE),
             linetype = "dashed", color = "red", linewidth = 0.8) +
  annotate("text", x = median(th_baseline$th_rate_2017, na.rm = TRUE) + 5,
           y = Inf, vjust = 2, label = "Median",
           color = "red", fontface = "italic", size = 3.5) +
  labs(x = "Commune TH Rate, 2017 (%)",
       y = "Number of Communes",
       title = "Distribution of Pre-Reform Taxe d'Habitation Rates") +
  scale_x_continuous(breaks = seq(0, 100, 10))

ggsave(file.path(OUT, "fig1_th_distribution.pdf"), p1, width = 7, height = 4.5)
cat("  Saved fig1_th_distribution.pdf\n")


# ============================================================================
# Figure 2: Raw Price Trends by TH Quartile
# ============================================================================

cat("\n=== Figure 2: Price Trends by Quartile ===\n")

# Aggregate mean log price by quartile-year
trend_data <- dvf[!is.na(th_quartile), .(
  mean_log_price = mean(log_price_m2, na.rm = TRUE),
  mean_price_m2 = mean(price_m2, na.rm = TRUE),
  n = .N
), by = .(year, th_quartile)]

p2 <- ggplot(trend_data, aes(x = year, y = mean_price_m2,
                              color = th_quartile, group = th_quartile)) +
  geom_line(linewidth = 1) +
  geom_point(size = 2.5) +
  scale_color_viridis_d(name = "TH Rate\nQuartile",
                        labels = c("Q1 (Low)", "Q2", "Q3", "Q4 (High)")) +
  labs(x = "Year", y = "Mean Price per m\u00B2 (\u20AC)",
       title = "Property Prices by Pre-Reform TH Rate Quartile") +
  scale_y_continuous(labels = comma) +
  scale_x_continuous(breaks = 2020:2025)

ggsave(file.path(OUT, "fig2_price_trends.pdf"), p2, width = 7, height = 4.5)
cat("  Saved fig2_price_trends.pdf\n")


# ============================================================================
# Figure 3: Event Study — Continuous Treatment
# ============================================================================

cat("\n=== Figure 3: Event Study ===\n")

pdf(file.path(OUT, "fig3_event_study.pdf"), width = 7, height = 4.5)
iplot(es_model,
      main = "Event Study: TH Rate \u00D7 Year",
      xlab = "Year Relative to 2020",
      ylab = "Coefficient on TH Rate \u00D7 Year",
      pt.pch = 20, ci.lwd = 1.5)
abline(h = 0, lty = 2, col = "grey50")
dev.off()
cat("  Saved fig3_event_study.pdf\n")


# ============================================================================
# Figure 4: Event Study — Binned (Q4 vs Q1)
# ============================================================================

cat("\n=== Figure 4: Binned Event Study ===\n")

pdf(file.path(OUT, "fig4_event_study_binned.pdf"), width = 7, height = 4.5)
iplot(es_binned,
      main = "Event Study: High TH (Q4) vs Low TH (Q1)",
      xlab = "Year Relative to 2020",
      ylab = "Coefficient on High TH \u00D7 Year",
      pt.pch = 20, ci.lwd = 1.5)
abline(h = 0, lty = 2, col = "grey50")
dev.off()
cat("  Saved fig4_event_study_binned.pdf\n")


# ============================================================================
# Figure 5: Fiscal Substitution — TFB Rate Changes
# ============================================================================

cat("\n=== Figure 5: Fiscal Substitution ===\n")

fiscal_file <- file.path(DAT, "fiscal_change_panel.csv")
if (file.exists(fiscal_file)) {
  fiscal <- fread(fiscal_file)
  fiscal <- fiscal[!is.na(delta_tfb)]

  p5 <- ggplot(fiscal, aes(x = th_rate_2017, y = delta_tfb)) +
    geom_point(alpha = 0.05, size = 0.3, color = "grey40") +
    geom_smooth(method = "lm", color = "red", linewidth = 1, se = TRUE) +
    labs(x = "Baseline TH Rate, 2017 (%)",
         y = "\u0394 TFB Rate, 2017\u20132024 (pp)",
         title = "Fiscal Substitution: TFB Increase vs Pre-Reform TH Rate") +
    geom_hline(yintercept = 0, linetype = "dashed", color = "grey50")

  ggsave(file.path(OUT, "fig5_fiscal_substitution.pdf"), p5, width = 7, height = 4.5)
  cat("  Saved fig5_fiscal_substitution.pdf\n")
}


# ============================================================================
# Figure 6: Leave-One-Out
# ============================================================================

cat("\n=== Figure 6: Leave-One-Out ===\n")

if (!is.null(loo_results) && nrow(loo_results) > 10) {
  loo_results[, lower := coefficient - 1.96 * se]
  loo_results[, upper := coefficient + 1.96 * se]

  # Sort by coefficient
  loo_results <- loo_results[order(coefficient)]
  loo_results[, idx := .I]

  # Main estimate for reference
  main_coef <- mean(loo_results$coefficient)

  p6 <- ggplot(loo_results, aes(x = idx, y = coefficient)) +
    geom_point(size = 1.5, color = "steelblue") +
    geom_errorbar(aes(ymin = lower, ymax = upper),
                  width = 0, alpha = 0.3) +
    geom_hline(yintercept = main_coef, linetype = "dashed", color = "red") +
    geom_hline(yintercept = 0, linetype = "solid", color = "grey50") +
    labs(x = "Département Excluded (ordered by coefficient)",
         y = "Coefficient on TH Rate (2017)",
         title = "Leave-One-Out by D\u00E9partement") +
    theme(axis.text.x = element_blank())

  ggsave(file.path(OUT, "fig6_leave_one_out.pdf"), p6, width = 7, height = 4.5)
  cat("  Saved fig6_leave_one_out.pdf\n")
}


# ============================================================================
# Figure 7: Binscatter — TH Rate vs Price Level
# ============================================================================

cat("\n=== Figure 7: Binscatter ===\n")

# Residualize log price on dept×year FE and property controls
dvf[, resid_price := resid(feols(log_price_m2 ~ is_apartment + log(surface_reelle_bati) |
                                   dept^year, data = dvf))]

bins <- dvf[, .(
  mean_th = mean(th_rate_2017),
  mean_resid = mean(resid_price),
  n = .N
), by = .(th_bin = cut(th_rate_2017, breaks = 50))]

bins <- bins[!is.na(th_bin) & n >= 100]

p7 <- ggplot(bins, aes(x = mean_th, y = mean_resid)) +
  geom_point(size = 2.5, color = "steelblue") +
  geom_smooth(method = "lm", color = "red", linewidth = 1, se = TRUE) +
  labs(x = "Baseline TH Rate, 2017 (%)",
       y = "Residualized Log Price per m\u00B2",
       title = "Cross-Sectional Relationship: TH Rate and Property Prices") +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey50")

ggsave(file.path(OUT, "fig7_binscatter.pdf"), p7, width = 7, height = 4.5)
cat("  Saved fig7_binscatter.pdf\n")


# ============================================================================
# Figure 8: Fiscal Substitution Event Study
# ============================================================================

cat("\n=== Figure 8: Fiscal Substitution ES ===\n")

if (!is.null(fs_es)) {
  pdf(file.path(OUT, "fig8_fiscal_sub_es.pdf"), width = 7, height = 4.5)
  iplot(fs_es,
        main = "TFB Rate Response to Pre-Reform TH Rate",
        xlab = "Year Relative to 2020",
        ylab = "Coefficient on TH Rate (2017) \u00D7 Year",
        pt.pch = 20, ci.lwd = 1.5)
  abline(h = 0, lty = 2, col = "grey50")
  dev.off()
  cat("  Saved fig8_fiscal_sub_es.pdf\n")
} else {
  cat("  No fiscal substitution ES model found, skipping\n")
}


# ============================================================================
# Summary
# ============================================================================

cat("\n=== All figures generated ===\n")
cat(sprintf("  Output directory: %s\n", normalizePath(OUT)))
figs <- list.files(OUT, pattern = "\\.pdf$")
cat(sprintf("  Files: %s\n", paste(figs, collapse = ", ")))
