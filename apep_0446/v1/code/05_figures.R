## ─── 05_figures.R ──────────────────────────────────────────────
## Generate all figures for apep_0446
## ────────────────────────────────────────────────────────────────
source("00_packages.R")

## ─── Load data and results ─────────────────────────────────────
monthly <- fread(file.path(data_dir, "monthly_panel.csv"))
monthly[, ym := as.Date(ym)]
monthly[, first_treat_ym := as.Date(first_treat_ym)]

load(file.path(data_dir, "main_results.RData"))
tryCatch(load(file.path(data_dir, "robustness_results.RData")), error = function(e) NULL)

## Color palette
COLORS <- c("e-NAM" = "#2166AC", "Control" = "#B2182B",
            "Pre" = "grey60", "Post" = "#2166AC")

## ─── Figure 1: e-NAM Rollout Timeline ──────────────────────────
cat("── Figure 1: Rollout timeline ──\n")

rollout <- data.table(
  phase = c("Launch\n(Apr 2016)", "Nov 2016", "Mar 2017",
            "Mar 2018"),
  date = as.Date(c("2016-04-14", "2016-11-01", "2017-03-01",
                    "2018-03-01")),
  mandis = c(21, 250, 417, 585),
  states = c(9, 11, 15, 18)
)

p1 <- ggplot(rollout, aes(x = date, y = mandis)) +
  geom_line(linewidth = 1, color = COLORS["e-NAM"]) +
  geom_point(size = 3, color = COLORS["e-NAM"]) +
  geom_text(aes(label = phase), vjust = -1.5, size = 3) +
  geom_text(aes(label = paste0(mandis, " mandis\n", states, " states")),
            vjust = 2.5, size = 2.5, color = "grey40") +
  scale_y_continuous(limits = c(0, 800), labels = comma) +
  labs(x = NULL, y = "Cumulative e-NAM Mandis",
       title = "Staggered Rollout of the e-NAM Platform",
       subtitle = "Number of agricultural mandis integrated into electronic trading") +
  theme_apep()

ggsave(file.path(fig_dir, "fig1_rollout_timeline.pdf"), p1,
       width = 7, height = 4.5)
cat("  ✓ fig1_rollout_timeline.pdf\n")

## ─── Figure 2: Raw price trends (treated vs control cohorts) ───
cat("── Figure 2: Price trends ──\n")

## Average monthly prices by treatment cohort
monthly[, cohort_label := fifelse(
  enam_treated,
  paste0("Phase ", fifelse(!is.na(first_treat_ym),
    fifelse(first_treat_ym <= as.Date("2016-05-01"), "1A (Apr 2016)",
    fifelse(first_treat_ym <= as.Date("2016-12-01"), "1B (Nov 2016)",
    fifelse(first_treat_ym <= as.Date("2017-04-01"), "1C (Mar 2017)",
                                                      "1D (Mar 2018)"))),
    "Unknown")),
  "Never Treated"
)]

for (comm in unique(monthly$commodity)) {
  comm_trends <- monthly[commodity == comm & year >= 2010, .(
    mean_price = mean(modal_price, na.rm = TRUE)
  ), by = .(ym, group = fifelse(enam_treated, "e-NAM States", "Non-e-NAM States"))]

  p <- ggplot(comm_trends, aes(x = ym, y = mean_price, color = group)) +
    geom_line(linewidth = 0.6) +
    geom_vline(xintercept = as.Date("2016-04-14"), linetype = "dashed",
               color = "grey40") +
    annotate("text", x = as.Date("2016-04-14"), y = Inf,
             label = "e-NAM\nLaunch", vjust = 1.5, hjust = -0.1,
             size = 2.5, color = "grey40") +
    scale_color_manual(values = c("e-NAM States" = COLORS["e-NAM"],
                                   "Non-e-NAM States" = COLORS["Control"])) +
    scale_y_continuous(labels = comma) +
    labs(x = NULL, y = "Mean Modal Price (Rs/quintal)",
         title = paste0(comm, ": Mean Mandi Prices by Treatment Status"),
         subtitle = "e-NAM integrated states vs. non-integrated states",
         color = NULL) +
    theme_apep()

  ggsave(file.path(fig_dir, paste0("fig2_trends_", tolower(comm), ".pdf")), p,
         width = 7, height = 4)
}
cat("  ✓ fig2_trends_*.pdf\n")

## ─── Figure 3: Event study plots (CS-DiD) ──────────────────────
cat("── Figure 3: Event study plots ──\n")

## Individual event study plots (for appendix)
for (comm in names(cs_results)) {
  dyn <- cs_results[[comm]]$dynamic
  if (is.null(dyn)) next

  es_data <- data.table(
    event_time = dyn$egt,
    att = dyn$att.egt,
    se = dyn$se.egt
  )
  es_data[, ci_lo := att - 1.96 * se]
  es_data[, ci_hi := att + 1.96 * se]

  ## Trim to reasonable window
  es_data <- es_data[event_time >= -8 & event_time <= 12]

  p <- ggplot(es_data, aes(x = event_time, y = att)) +
    geom_hline(yintercept = 0, color = "grey60", linetype = "dashed") +
    geom_vline(xintercept = -0.5, color = "grey40", linetype = "dashed") +
    geom_ribbon(aes(ymin = ci_lo, ymax = ci_hi), alpha = 0.15,
                fill = COLORS["e-NAM"]) +
    geom_line(color = COLORS["e-NAM"], linewidth = 0.7) +
    geom_point(color = COLORS["e-NAM"], size = 1.5) +
    annotate("text", x = -4, y = max(es_data$ci_hi, na.rm = TRUE) * 0.9,
             label = "Pre-treatment", size = 3, color = "grey50") +
    annotate("text", x = 6, y = max(es_data$ci_hi, na.rm = TRUE) * 0.9,
             label = "Post-treatment", size = 3, color = "grey50") +
    labs(x = "Quarters Relative to e-NAM Integration",
         y = "ATT (Log Price)",
         title = paste0(comm, ": Dynamic Treatment Effects"),
         subtitle = "Callaway-Sant'Anna event study (95% CI)") +
    theme_apep()

  ggsave(file.path(fig_dir, paste0("fig3_eventstudy_", tolower(comm), ".pdf")), p,
         width = 7, height = 4.5)
}
cat("  ✓ fig3_eventstudy_*.pdf\n")

## Combined two-panel event study (for main text)
cat("── Figure 3b: Combined event study (panels) ──\n")
es_combined <- rbindlist(lapply(c("Wheat", "Soyabean"), function(comm) {
  dyn <- cs_results[[comm]]$dynamic
  if (is.null(dyn)) return(NULL)
  dt <- data.table(
    event_time = dyn$egt,
    att = dyn$att.egt,
    se = dyn$se.egt,
    commodity = fifelse(comm == "Soyabean", "Panel B: Soybean", "Panel A: Wheat")
  )
  dt[, ci_lo := att - 1.96 * se]
  dt[, ci_hi := att + 1.96 * se]
  dt[event_time >= -8 & event_time <= 12]
}))

if (nrow(es_combined) > 0) {
  p_combined <- ggplot(es_combined, aes(x = event_time, y = att)) +
    geom_hline(yintercept = 0, color = "grey60", linetype = "dashed") +
    geom_vline(xintercept = -0.5, color = "grey40", linetype = "dashed") +
    geom_ribbon(aes(ymin = ci_lo, ymax = ci_hi), alpha = 0.15,
                fill = COLORS["e-NAM"]) +
    geom_line(color = COLORS["e-NAM"], linewidth = 0.7) +
    geom_point(color = COLORS["e-NAM"], size = 1.5) +
    facet_wrap(~commodity, scales = "free_y") +
    labs(x = "Quarters Relative to e-NAM Integration",
         y = "ATT (Log Price)",
         title = "Dynamic Treatment Effects: Storable Commodities",
         subtitle = "Callaway-Sant'Anna event study estimates with 95% confidence intervals") +
    theme_apep()

  ggsave(file.path(fig_dir, "fig3_eventstudy_combined.pdf"), p_combined,
         width = 10, height = 4.5)
  cat("  ✓ fig3_eventstudy_combined.pdf\n")
}

## ─── Figure 4: TWFE by commodity (coefficient plot) ─────────────
cat("── Figure 4: Commodity comparison ──\n")

estimates <- fread(file.path(tab_dir, "main_estimates.csv"))
if (nrow(estimates) > 0) {
  estimates[, ci_lo := att - 1.96 * se]
  estimates[, ci_hi := att + 1.96 * se]
  estimates[, sig := fifelse(pvalue < 0.05, "p < 0.05", "n.s.")]

  p4 <- ggplot(estimates, aes(x = reorder(commodity, att), y = att)) +
    geom_hline(yintercept = 0, color = "grey60", linetype = "dashed") +
    geom_pointrange(aes(ymin = ci_lo, ymax = ci_hi, color = sig),
                    size = 0.6) +
    scale_color_manual(values = c("p < 0.05" = COLORS["e-NAM"],
                                   "n.s." = "grey50")) +
    coord_flip() +
    labs(x = NULL, y = "ATT on Log Price",
         title = "e-NAM Price Effects by Commodity",
         subtitle = "Estimates with 95% confidence intervals",
         color = NULL) +
    theme_apep()

  ggsave(file.path(fig_dir, "fig4_commodity_comparison.pdf"), p4,
         width = 7, height = 4)
  cat("  ✓ fig4_commodity_comparison.pdf\n")
}

## ─── Figure 5: Price dispersion over time ──────────────────────
cat("── Figure 5: Price dispersion ──\n")

dispersion <- fread(file.path(data_dir, "dispersion_panel.csv"))
dispersion[, ym := as.Date(ym)]

## Average CV over time by treatment status
## Filter out extreme CV outliers (>1.0 indicates data quality issues)
disp_trends <- dispersion[n_mandis >= 3 & cv_price < 1.0, .(
  mean_cv = mean(cv_price, na.rm = TRUE),
  median_cv = median(cv_price, na.rm = TRUE)
), by = .(ym, group = fifelse(post_enam == 1, "Post-e-NAM States", "Pre/Control States"))]

if (nrow(disp_trends) > 20) {
  p5 <- ggplot(disp_trends, aes(x = ym, y = mean_cv, color = group)) +
    geom_line(linewidth = 0.6, alpha = 0.7) +
    geom_smooth(method = "loess", span = 0.3, se = FALSE, linewidth = 0.8) +
    geom_vline(xintercept = as.Date("2016-04-14"), linetype = "dashed",
               color = "grey40") +
    scale_color_manual(values = c("Post-e-NAM States" = COLORS["e-NAM"],
                                   "Pre/Control States" = COLORS["Control"])) +
    labs(x = NULL, y = "Coefficient of Variation",
         title = "Price Dispersion Across Mandis Over Time",
         subtitle = "Within-state CV of modal prices, all commodities",
         color = NULL) +
    theme_apep()

  ggsave(file.path(fig_dir, "fig5_price_dispersion.pdf"), p5,
         width = 7, height = 4.5)
  cat("  ✓ fig5_price_dispersion.pdf\n")
}

## ─── Figure 6: Placebo test results ────────────────────────────
cat("── Figure 6: Placebo tests ──\n")

if (exists("placebo_results") && length(placebo_results) > 0) {
  placebo_dt <- rbindlist(lapply(names(placebo_results), function(comm) {
    ct <- placebo_results[[comm]]
    data.table(commodity = comm, att = ct[1, 1], se = ct[1, 2], pvalue = ct[1, 4])
  }))
  placebo_dt[, ci_lo := att - 1.96 * se]
  placebo_dt[, ci_hi := att + 1.96 * se]
  placebo_dt[, sig := fifelse(pvalue < 0.05, "Significant (Pre-trend)", "Not Significant")]

  p6 <- ggplot(placebo_dt, aes(x = reorder(commodity, att), y = att)) +
    geom_hline(yintercept = 0, color = "grey60", linetype = "dashed") +
    geom_pointrange(aes(ymin = ci_lo, ymax = ci_hi, color = sig), size = 0.6) +
    scale_color_manual(values = c("Significant (Pre-trend)" = "#D6604D",
                                   "Not Significant" = "#4393C3")) +
    coord_flip() +
    labs(x = NULL, y = "Placebo ATT (Fictional Treatment 3 Years Early)",
         title = "Placebo Test: Pre-Trend Falsification",
         subtitle = "Non-significant = parallel trends supported",
         color = NULL) +
    theme_apep()

  ggsave(file.path(fig_dir, "fig6_placebo_test.pdf"), p6,
         width = 7, height = 4)
  cat("  ✓ fig6_placebo_test.pdf\n")
}

## ─── Figure 7: Treatment window sensitivity ───────────────────
cat("── Figure 7: Treatment window sensitivity ──\n")

if (exists("window_dt") && nrow(window_dt) > 0) {
  window_dt[, ci_lo := att - 1.96 * se]
  window_dt[, ci_hi := att + 1.96 * se]

  p7 <- ggplot(window_dt, aes(x = shift_months, y = att, color = commodity)) +
    geom_hline(yintercept = 0, color = "grey60", linetype = "dashed") +
    geom_vline(xintercept = 0, color = "grey40", linetype = "dotted") +
    geom_pointrange(aes(ymin = ci_lo, ymax = ci_hi),
                    position = position_dodge(width = 0.5), size = 0.3) +
    labs(x = "Treatment Date Shift (Months)",
         y = "ATT on Log Price",
         title = "Sensitivity to Treatment Date Assignment",
         subtitle = "TWFE estimates with treatment date shifted +/- 3 months",
         color = "Commodity") +
    theme_apep()

  ggsave(file.path(fig_dir, "fig7_window_sensitivity.pdf"), p7,
         width = 7, height = 4.5)
  cat("  ✓ fig7_window_sensitivity.pdf\n")
}

cat("\n✓ All figures generated.\n")
