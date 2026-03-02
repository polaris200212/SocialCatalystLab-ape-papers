## ============================================================================
## 05_figures.R — Publication-ready figures
## v2 revision: WS6 improvements — de-clutter, restructure, add workforce fig
## ============================================================================

source("00_packages.R")

DATA <- "../data"
FIGURES <- "../figures"
dir.create(FIGURES, showWarnings = FALSE)

panel <- readRDS(file.path(DATA, "panel_analysis.rds"))
results <- readRDS(file.path(DATA, "main_results.rds"))
robustness <- readRDS(file.path(DATA, "robustness_results.rds"))
state_treatment <- readRDS(file.path(DATA, "state_treatment.rds"))

## ---- Figure 1: Treatment Variation ----
cat("Figure 1: Stringency variation across states...\n")

st <- copy(state_treatment)
st[, state := factor(state, levels = state[order(peak_stringency)])]

fig1 <- ggplot(st, aes(x = state, y = peak_stringency)) +
  geom_col(aes(fill = peak_stringency), width = 0.7) +
  scale_fill_gradient(low = "#56B4E9", high = "#D55E00",
                      name = "Peak Stringency\n(April 2020)") +
  coord_flip() +
  labs(
    title = "COVID-19 Lockdown Stringency by State",
    subtitle = "Oxford Government Response Tracker, April 2020 average",
    x = NULL, y = "Stringency Index (0-100)"
  ) +
  theme_apep() +
  theme(legend.position = "right",
        axis.text.y = element_text(size = 6))

ggsave(file.path(FIGURES, "fig1_stringency_map.pdf"), fig1,
       width = 8, height = 10)

## ---- Figure 2: Raw Trends (IMPROVED — WS6) ----
cat("Figure 2: Raw trends by service type and stringency (improved)...\n")

med_str <- median(state_treatment$peak_stringency, na.rm = TRUE)
panel[, str_group := fifelse(peak_stringency > med_str, "High Stringency", "Low Stringency")]

trends <- panel[, .(
  mean_paid = mean(total_paid) / 1e6,
  mean_providers = mean(n_providers),
  mean_beneficiaries = mean(total_beneficiaries)
), by = .(str_group, service_type, month_date)]

# Panel A: Total paid — thicker lines, on-plot labels, distinct colors (WS6)
fig2a <- ggplot(trends, aes(x = month_date, y = mean_paid,
                            color = interaction(str_group, service_type),
                            linetype = service_type,
                            shape = interaction(str_group, service_type))) +
  geom_line(linewidth = 1.1) +
  geom_point(size = 0.8, alpha = 0.6) +
  geom_vline(xintercept = as.Date("2020-04-01"), linetype = "dashed",
             color = "grey40", linewidth = 0.6) +
  annotate("text", x = as.Date("2020-04-01"), y = max(trends$mean_paid) * 0.98,
           label = "Lockdown onset", hjust = -0.05, size = 3.2, color = "grey30",
           fontface = "italic") +
  scale_color_manual(values = c(
    "High Stringency.HCBS" = "#D55E00",
    "High Stringency.BH" = "#CC79A7",
    "Low Stringency.HCBS" = "#0072B2",
    "Low Stringency.BH" = "#56B4E9"
  ), name = NULL,
  labels = c("High Stringency — HCBS", "High Stringency — BH",
             "Low Stringency — HCBS", "Low Stringency — BH")) +
  scale_linetype_manual(values = c("HCBS" = "solid", "BH" = "dashed"),
                        guide = "none") +
  scale_shape_manual(values = c(
    "High Stringency.HCBS" = 16, "High Stringency.BH" = 17,
    "Low Stringency.HCBS" = 15, "Low Stringency.BH" = 18
  ), guide = "none") +
  labs(
    title = "A. Monthly Medicaid Spending by Service Type and Lockdown Intensity",
    subtitle = "High/Low = above/below median April 2020 OxCGRT stringency",
    x = NULL, y = "Mean State Monthly Spending ($M)"
  ) +
  theme_apep() +
  theme(legend.position = "bottom",
        legend.text = element_text(size = 8))

# Panel B: Providers — thicker lines
fig2b <- ggplot(trends, aes(x = month_date, y = mean_providers,
                            color = interaction(str_group, service_type),
                            linetype = service_type)) +
  geom_line(linewidth = 1.1) +
  geom_vline(xintercept = as.Date("2020-04-01"), linetype = "dashed",
             color = "grey40", linewidth = 0.6) +
  scale_color_manual(values = c(
    "High Stringency.HCBS" = "#D55E00",
    "High Stringency.BH" = "#CC79A7",
    "Low Stringency.HCBS" = "#0072B2",
    "Low Stringency.BH" = "#56B4E9"
  ), name = NULL,
  labels = c("High Stringency — HCBS", "High Stringency — BH",
             "Low Stringency — HCBS", "Low Stringency — BH")) +
  scale_linetype_manual(values = c("HCBS" = "solid", "BH" = "dashed"),
                        guide = "none") +
  labs(
    title = "B. Active Billing Providers by Service Type and Lockdown Intensity",
    x = NULL, y = "Mean State Monthly Provider Count"
  ) +
  theme_apep() +
  theme(legend.position = "bottom",
        legend.text = element_text(size = 8))

fig2 <- fig2a / fig2b + plot_layout(guides = "collect") &
  theme(legend.position = "bottom")

ggsave(file.path(FIGURES, "fig2_raw_trends.pdf"), fig2,
       width = 10, height = 10)

## ---- Figure 3: HCBS/BH Ratio ----
cat("Figure 3: HCBS/BH spending ratio...\n")

ratio_data <- panel[, .(total_paid = sum(total_paid)),
                    by = .(str_group, service_type, month_date)]
ratio_wide <- dcast(ratio_data, str_group + month_date ~ service_type,
                    value.var = "total_paid")
ratio_wide[, hcbs_bh_ratio := HCBS / BH]

pre_mean <- ratio_wide[month_date < as.Date("2020-03-01"),
                       .(pre_ratio = mean(hcbs_bh_ratio)), by = str_group]
ratio_wide <- merge(ratio_wide, pre_mean, by = "str_group")
ratio_wide[, ratio_normalized := hcbs_bh_ratio / pre_ratio]

fig3 <- ggplot(ratio_wide, aes(x = month_date, y = ratio_normalized,
                               color = str_group)) +
  geom_line(linewidth = 1.0) +
  geom_hline(yintercept = 1, linetype = "dashed", color = "grey60") +
  geom_vline(xintercept = as.Date("2020-04-01"), linetype = "dashed", color = "grey40") +
  annotate("rect", xmin = as.Date("2020-04-01"), xmax = as.Date("2020-07-01"),
           ymin = -Inf, ymax = Inf, alpha = 0.1, fill = "red") +
  scale_color_manual(values = c("High Stringency" = "#D55E00",
                                "Low Stringency" = "#0072B2"),
                     name = NULL) +
  labs(
    title = "HCBS-to-Behavioral Health Spending Ratio (Normalized to Pre-Period)",
    subtitle = "Ratio < 1 indicates HCBS fell more than BH; shaded = lockdown period",
    x = NULL, y = "Normalized HCBS/BH Ratio"
  ) +
  theme_apep()

ggsave(file.path(FIGURES, "fig3_ratio_trends.pdf"), fig3,
       width = 10, height = 6)

## ---- Figure 4: Dynamic DDD Event Study (IMPROVED — WS6) ----
cat("Figure 4: Event study coefficients (improved)...\n")

m_dynamic <- results$m_dynamic
ct <- as.data.table(coeftable(m_dynamic), keep.rownames = TRUE)
setnames(ct, c("rn", "estimate", "se", "tval", "pval"))

ct[, quarter := as.numeric(gsub("rel_quarter::", "", gsub(":str_x_hcbs", "", rn)))]
ct <- ct[!is.na(quarter)]

# Add reference period
ct <- rbind(ct, data.table(rn = "ref", estimate = 0, se = 0, tval = 0, pval = 1, quarter = -1))
setorder(ct, quarter)

fig4 <- ggplot(ct, aes(x = quarter, y = estimate)) +
  geom_ribbon(aes(ymin = estimate - 1.96 * se, ymax = estimate + 1.96 * se),
              alpha = 0.15, fill = apep_colors[1]) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey40", linewidth = 0.5) +
  geom_vline(xintercept = -0.5, linetype = "dashed", color = "grey50", linewidth = 0.6) +
  geom_point(color = apep_colors[1], size = 2.8) +
  geom_line(color = apep_colors[1], linewidth = 0.8) +
  annotate("text", x = -0.5, y = max(ct$estimate + 1.96 * ct$se, na.rm = TRUE) * 0.95,
           label = "Lockdown onset", hjust = -0.05, size = 3.2, color = "grey30",
           fontface = "italic") +
  scale_x_continuous(breaks = seq(-8, 18, 2)) +
  labs(
    title = "Dynamic Triple-Difference: Effect of Lockdown Stringency on HCBS vs BH",
    subtitle = "Coefficient on Stringency x HCBS x Quarter relative to Q-1 (Jan-Mar 2020)",
    x = "Quarters Relative to April 2020", y = "Triple-Difference Coefficient (log spending)"
  ) +
  theme_apep() +
  theme(axis.title = element_text(size = 12),
        axis.text = element_text(size = 10),
        plot.title = element_text(size = 13),
        plot.subtitle = element_text(size = 10))

ggsave(file.path(FIGURES, "fig4_event_study.pdf"), fig4,
       width = 10, height = 6)

## ---- Figure 5: Period-Specific Effects (promoted from Fig 6) ----
cat("Figure 5: Period-specific effects...\n")

m7 <- results$m7_periods
ct7 <- as.data.table(coeftable(m7), keep.rownames = TRUE)
setnames(ct7, c("rn", "estimate", "se", "tval", "pval"))

ct7[, period := c("Lockdown\n(Apr-Jun 2020)", "Recovery\n(Jul-Dec 2020)",
                  "Post-Lockdown\n(2021)", "Post-Lockdown\n(2022+)")]
ct7[, period := factor(period, levels = period)]

fig5 <- ggplot(ct7, aes(x = period, y = estimate)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
  geom_pointrange(aes(ymin = estimate - 1.96 * se, ymax = estimate + 1.96 * se),
                  color = apep_colors[1], size = 0.8, linewidth = 0.8) +
  labs(
    title = "Triple-Difference Effect by Period",
    subtitle = "Effect of lockdown stringency on HCBS vs BH spending",
    x = NULL, y = "DDD Coefficient (log spending)"
  ) +
  theme_apep()

ggsave(file.path(FIGURES, "fig5_period_effects.pdf"), fig5,
       width = 8, height = 5)

## ---- Figure 6: Workforce Evidence (NEW — WS3) ----
cat("Figure 6: Workforce evidence...\n")

if (file.exists(file.path(DATA, "workforce_results.rds"))) {
  wf <- readRDS(file.path(DATA, "workforce_results.rds"))

  if (nrow(wf$workforce_trends) > 0 && "mean_emp_index" %in% names(wf$workforce_trends)) {
    fig6 <- ggplot(wf$workforce_trends[!is.na(mean_emp_index)],
                   aes(x = year, y = mean_emp_index, color = str_group)) +
      geom_line(linewidth = 1.1) +
      geom_point(size = 2.5) +
      geom_hline(yintercept = 100, linetype = "dashed", color = "grey60") +
      geom_vline(xintercept = 2020, linetype = "dashed", color = "grey40") +
      scale_color_manual(values = c("High Stringency" = "#D55E00",
                                    "Low Stringency" = "#0072B2"),
                         name = NULL) +
      labs(
        title = "Home Health Aide Employment by Lockdown Stringency",
        subtitle = "BLS OEWS SOC 31-1120, indexed to 2019 = 100",
        x = "Year", y = "Employment Index (2019 = 100)"
      ) +
      theme_apep()

    ggsave(file.path(FIGURES, "fig6_workforce.pdf"), fig6,
           width = 8, height = 5)
    cat("Workforce figure saved.\n")
  } else {
    cat("Workforce data insufficient for figure — skipping.\n")
  }
} else {
  cat("No workforce results file found.\n")
}

## ---- Figure A1: RI Distribution (moved to appendix — WS6) ----
cat("Figure A1: Randomization inference (appendix)...\n")

# RI for log_claims (the significant outcome)
ri_data_claims <- data.table(coef = robustness$ri_perm_coefs_claims)

figA1a <- ggplot(ri_data_claims, aes(x = coef)) +
  geom_histogram(bins = 60, fill = "grey70", color = "white") +
  geom_vline(xintercept = robustness$ri_actual_coef_claims,
             color = "#D55E00", linewidth = 1.2) +
  annotate("text", x = robustness$ri_actual_coef_claims,
           y = Inf, vjust = 2,
           label = sprintf("Actual = %.3f\nRI p = %.3f",
                          robustness$ri_actual_coef_claims,
                          robustness$ri_pvalue_claims),
           color = "#D55E00", size = 3.5, hjust = -0.1) +
  labs(
    title = "A. Randomization Inference: Log Claims",
    subtitle = sprintf("%d permutations of state stringency assignments",
                      length(robustness$ri_perm_coefs_claims)),
    x = "Permuted DDD Coefficient", y = "Count"
  ) +
  theme_apep()

# RI for log_paid
ri_data_paid <- data.table(coef = robustness$ri_perm_coefs_paid)

figA1b <- ggplot(ri_data_paid, aes(x = coef)) +
  geom_histogram(bins = 60, fill = "grey70", color = "white") +
  geom_vline(xintercept = robustness$ri_actual_coef_paid,
             color = "#D55E00", linewidth = 1.2) +
  annotate("text", x = robustness$ri_actual_coef_paid,
           y = Inf, vjust = 2,
           label = sprintf("Actual = %.3f\nRI p = %.3f",
                          robustness$ri_actual_coef_paid,
                          robustness$ri_pvalue_paid),
           color = "#D55E00", size = 3.5, hjust = -0.1) +
  labs(
    title = "B. Randomization Inference: Log Total Paid",
    subtitle = sprintf("%d permutations of state stringency assignments",
                      length(robustness$ri_perm_coefs_paid)),
    x = "Permuted DDD Coefficient", y = "Count"
  ) +
  theme_apep()

figA1 <- figA1a / figA1b

ggsave(file.path(FIGURES, "figA1_ri_distribution.pdf"), figA1,
       width = 9, height = 9)

cat("\n=== All figures saved to", FIGURES, "===\n")
