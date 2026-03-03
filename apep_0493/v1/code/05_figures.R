# =============================================================================
# 05_figures.R — All figures
# apep_0493: Council Tax Support Localisation and Low-Income Employment
# =============================================================================

source("00_packages.R")

panel <- fread(file.path(data_dir, "analysis_panel.csv")) |>
  mutate(date = as.Date(date))

# =============================================================================
# Figure 1: Claimant Rate Trends by Treatment Group
# =============================================================================
cat("=== Figure 1: Trend comparison ===\n")

trends <- panel |>
  mutate(group = ifelse(treat_binary == 1, "Cut LAs", "Protected LAs")) |>
  group_by(date, group) |>
  summarise(mean_rate = mean(claimant_rate, na.rm = TRUE),
            se = sd(claimant_rate, na.rm = TRUE) / sqrt(n()),
            .groups = "drop")

fig1 <- ggplot(trends, aes(x = date, y = mean_rate, color = group)) +
  geom_line(linewidth = 0.8) +
  geom_vline(xintercept = as.Date("2013-04-01"), linetype = "dashed", color = "grey40") +
  annotate("text", x = as.Date("2013-06-01"), y = max(trends$mean_rate) * 0.95,
           label = "CTS\nLocalisation", hjust = 0, size = 3, color = "grey40") +
  scale_color_manual(values = c("Cut LAs" = "#d62728", "Protected LAs" = "#1f77b4"),
                     name = NULL) +
  scale_x_date(date_breaks = "2 years", date_labels = "%Y") +
  labs(
    title = "Claimant Rates by Council Tax Support Generosity",
    subtitle = "Monthly claimant count as share of working-age population, 276 English Local Authorities",
    x = NULL, y = "Claimant rate (%)"
  ) +
  theme(legend.position = c(0.8, 0.9))

ggsave(file.path(fig_dir, "fig1_trends.pdf"), fig1, width = 8, height = 5)
ggsave(file.path(fig_dir, "fig1_trends.png"), fig1, width = 8, height = 5, dpi = 300)
cat("  Saved fig1_trends\n")

# =============================================================================
# Figure 2: Event Study (Raw and Detrended)
# =============================================================================
cat("=== Figure 2: Event study ===\n")

es_raw <- fread(file.path(data_dir, "event_study_coefs.csv")) |>
  mutate(spec = "Raw TWFE")

es_detrend <- tryCatch(
  fread(file.path(data_dir, "event_study_detrended.csv")),
  error = function(e) NULL
)

if (!is.null(es_detrend)) {
  es_all <- bind_rows(es_raw, es_detrend)
} else {
  es_all <- es_raw
}

fig2 <- ggplot(es_all, aes(x = quarter, y = estimate, color = spec, fill = spec)) +
  geom_hline(yintercept = 0, color = "grey60") +
  geom_vline(xintercept = -0.5, linetype = "dashed", color = "grey40") +
  geom_ribbon(aes(ymin = ci_lo, ymax = ci_hi), alpha = 0.15, color = NA) +
  geom_point(size = 2) +
  geom_line(linewidth = 0.6) +
  scale_color_manual(values = c("Raw TWFE" = "#d62728", "Detrended" = "#1f77b4"),
                     name = "Specification") +
  scale_fill_manual(values = c("Raw TWFE" = "#d62728", "Detrended" = "#1f77b4"),
                    name = "Specification") +
  scale_x_continuous(breaks = seq(-8, 16, by = 4)) +
  labs(
    title = "Event Study: Effect of CTS Cuts on Claimant Rates",
    subtitle = "Quarterly coefficients relative to quarter before reform (q = -1). 95% CI shown.",
    x = "Quarters relative to CTS localisation (April 2013)",
    y = "Effect on claimant rate (pp)"
  ) +
  theme(legend.position = c(0.2, 0.2))

ggsave(file.path(fig_dir, "fig2_event_study.pdf"), fig2, width = 9, height = 5.5)
ggsave(file.path(fig_dir, "fig2_event_study.png"), fig2, width = 9, height = 5.5, dpi = 300)
cat("  Saved fig2_event_study\n")

# =============================================================================
# Figure 3: Dose-Response (Tercile Means Over Time)
# =============================================================================
cat("=== Figure 3: Dose-response ===\n")

dose_trends <- panel |>
  mutate(group = case_when(
    treat_tercile == 1 ~ "Most Cut (T1)",
    treat_tercile == 2 ~ "Moderate Cut (T2)",
    treat_tercile == 3 ~ "Most Protected (T3)"
  )) |>
  group_by(date, group) |>
  summarise(mean_rate = mean(claimant_rate, na.rm = TRUE), .groups = "drop")

fig3 <- ggplot(dose_trends, aes(x = date, y = mean_rate, color = group)) +
  geom_line(linewidth = 0.7) +
  geom_vline(xintercept = as.Date("2013-04-01"), linetype = "dashed", color = "grey40") +
  scale_color_manual(
    values = c("Most Cut (T1)" = "#d62728", "Moderate Cut (T2)" = "#ff7f0e",
               "Most Protected (T3)" = "#1f77b4"),
    name = "CTS Generosity Tercile"
  ) +
  scale_x_date(date_breaks = "2 years", date_labels = "%Y") +
  labs(
    title = "Claimant Rate Trends by CTS Cut Intensity",
    subtitle = "Local Authorities grouped by tercile of council tax support generosity",
    x = NULL, y = "Claimant rate (%)"
  ) +
  theme(legend.position = c(0.75, 0.85))

ggsave(file.path(fig_dir, "fig3_dose_response.pdf"), fig3, width = 8, height = 5)
ggsave(file.path(fig_dir, "fig3_dose_response.png"), fig3, width = 8, height = 5, dpi = 300)
cat("  Saved fig3_dose_response\n")

# =============================================================================
# Figure 4: Treatment Distribution
# =============================================================================
cat("=== Figure 4: Treatment distribution ===\n")

treatment <- fread(file.path(data_dir, "treatment.csv"))

fig4 <- ggplot(treatment, aes(x = cts_working_pc)) +
  geom_histogram(bins = 40, fill = "#4a90d9", color = "white", alpha = 0.8) +
  geom_vline(xintercept = median(treatment$cts_working_pc, na.rm = TRUE),
             linetype = "dashed", color = "#d62728") +
  annotate("text", x = median(treatment$cts_working_pc, na.rm = TRUE) + 2,
           y = Inf, vjust = 2, label = "Median", color = "#d62728", size = 3.5) +
  labs(
    title = "Distribution of Working-Age CTS Per Capita Across Local Authorities",
    subtitle = "Council tax support foregone per working-age resident, 2013-14 (£)",
    x = "CTS per working-age person (£)", y = "Number of Local Authorities"
  )

ggsave(file.path(fig_dir, "fig4_treatment_dist.pdf"), fig4, width = 7, height = 4.5)
ggsave(file.path(fig_dir, "fig4_treatment_dist.png"), fig4, width = 7, height = 4.5, dpi = 300)
cat("  Saved fig4_treatment_dist\n")

# =============================================================================
# Figure 5: Robustness Coefficient Plot
# =============================================================================
cat("=== Figure 5: Robustness comparison ===\n")

rob_table <- fread(file.path(data_dir, "robustness_table.csv"))

fig5 <- ggplot(rob_table, aes(x = Estimate, y = reorder(Specification, Estimate))) +
  geom_vline(xintercept = 0, color = "grey60") +
  geom_errorbarh(aes(xmin = Estimate - 1.96 * SE, xmax = Estimate + 1.96 * SE),
                 height = 0.2, color = "#4a90d9") +
  geom_point(size = 3, color = "#d62728") +
  labs(
    title = "Robustness of Main Estimate Across Specifications",
    subtitle = "Point estimates with 95% confidence intervals",
    x = "Effect on claimant rate (pp)", y = NULL
  )

ggsave(file.path(fig_dir, "fig5_robustness.pdf"), fig5, width = 8, height = 4)
ggsave(file.path(fig_dir, "fig5_robustness.png"), fig5, width = 8, height = 4, dpi = 300)
cat("  Saved fig5_robustness\n")

cat("\n=== All figures generated ===\n")
cat("Files:", paste(list.files(fig_dir), collapse = ", "), "\n")
