## ============================================================================
## 05_figures.R — All figures for the paper
## Paper: When the Safety Net Frays (apep_0368)
## ============================================================================

source("00_packages.R")
DATA <- "../data"
FIGS <- "../figures"
dir.create(FIGS, showWarnings = FALSE, recursive = TRUE)

load(file.path(DATA, "02_analysis_data.RData"))
load(file.path(DATA, "03_results.RData"))
load(file.path(DATA, "04_robustness.RData"))

## ---- Figure 1: BH vs HCBS Spending Trends ----
cat("Figure 1: Spending trends...\n")

trends <- panel[, .(
  total_paid = sum(total_paid, na.rm = TRUE) / 1e9
), by = .(service_cat, month)]

p1 <- ggplot(trends, aes(x = month, y = total_paid, color = service_cat)) +
  geom_line(linewidth = 1) +
  geom_vline(xintercept = as.Date("2023-04-01"), linetype = "dashed",
             color = "gray40") +
  annotate("text", x = as.Date("2023-06-01"), y = max(trends$total_paid) * 0.95,
           label = "Unwinding\nbegins", hjust = 0, size = 3, color = "gray40") +
  scale_color_manual(values = apep_colors, name = "Service Category",
                     labels = c("Behavioral Health (H-codes)",
                                "HCBS (T/S-codes)")) +
  scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
  labs(
    title = "Medicaid Behavioral Health vs. HCBS Spending, 2018\u20132024",
    x = NULL, y = "Total Paid ($ Billions)",
    caption = "Source: T-MSIS Medicaid Provider Spending (HHS, 2026)"
  )

ggsave(file.path(FIGS, "fig1_spending_trends.pdf"), p1,
       width = 8, height = 5)

## ---- Figure 2: Event Study (DDD) ----
cat("Figure 2: Event study...\n")

es_coefs <- as.data.table(coeftable(results$es_model))
es_coefs[, event_time := as.numeric(gsub("event_time::", "",
                                          gsub(":bh", "", rownames(coeftable(results$es_model)))))]

# Only keep the BH interaction terms
es_coefs <- es_coefs[!is.na(event_time)]
setnames(es_coefs, c("estimate", "se", "t", "p", "event_time"))

# Add reference period
es_coefs <- rbind(
  es_coefs,
  data.table(estimate = 0, se = 0, t = 0, p = 1, event_time = -1)
)

es_coefs[, `:=`(
  ci_lo = estimate - 1.96 * se,
  ci_hi = estimate + 1.96 * se
)]

p2 <- ggplot(es_coefs, aes(x = event_time, y = estimate)) +
  geom_hline(yintercept = 0, color = "gray60") +
  geom_vline(xintercept = -0.5, linetype = "dashed", color = "gray40") +
  geom_ribbon(aes(ymin = ci_lo, ymax = ci_hi), alpha = 0.2,
              fill = "#E63946") +
  geom_point(color = "#E63946", size = 2) +
  geom_line(color = "#E63946", linewidth = 0.8) +
  labs(
    title = "Event Study: Differential Effect on Behavioral Health vs. HCBS",
    subtitle = "DDD coefficients, relative to t = \u22121",
    x = "Months Relative to Unwinding Start",
    y = "Coefficient (log total paid)",
    caption = "Notes: 95% CIs with state-clustered SEs. Fixed effects: state\u00d7month, category\u00d7month, state\u00d7category."
  ) +
  scale_x_continuous(breaks = seq(-24, 18, by = 6))

ggsave(file.path(FIGS, "fig2_event_study.pdf"), p2,
       width = 8, height = 5.5)

## ---- Figure 3: Provider Counts Over Time ----
cat("Figure 3: Provider counts...\n")

prov_trends <- panel[, .(
  n_providers = sum(n_providers)
), by = .(service_cat, month)]

p3 <- ggplot(prov_trends, aes(x = month, y = n_providers / 1000,
                               color = service_cat)) +
  geom_line(linewidth = 1) +
  geom_vline(xintercept = as.Date("2023-04-01"), linetype = "dashed",
             color = "gray40") +
  scale_color_manual(values = apep_colors, name = "Service Category",
                     labels = c("Behavioral Health", "HCBS")) +
  scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
  labs(
    title = "Active Provider Count by Service Category, 2018\u20132024",
    x = NULL, y = "Active Providers (Thousands)",
    caption = "Source: T-MSIS. Active = at least one claim in month."
  )

ggsave(file.path(FIGS, "fig3_provider_counts.pdf"), p3,
       width = 8, height = 5)

## ---- Figure 4: Exit Rates ----
cat("Figure 4: Exit rates...\n")

exit_trends <- exit_entry[, .(
  exit_rate = mean(exit_rate, na.rm = TRUE)
), by = .(service_cat, month)]

p4 <- ggplot(exit_trends, aes(x = month, y = exit_rate * 100,
                               color = service_cat)) +
  geom_line(linewidth = 0.8) +
  geom_vline(xintercept = as.Date("2023-04-01"), linetype = "dashed",
             color = "gray40") +
  scale_color_manual(values = apep_colors, name = "Service Category",
                     labels = c("Behavioral Health", "HCBS")) +
  scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
  labs(
    title = "Monthly Provider Exit Rate by Service Category",
    x = NULL, y = "Exit Rate (%)",
    caption = "Exit = active provider last month with no billing this month."
  )

ggsave(file.path(FIGS, "fig4_exit_rates.pdf"), p4,
       width = 8, height = 5)

## ---- Figure 5: Disenrollment Rate Map ----
cat("Figure 5: Disenrollment map...\n")

tryCatch({
  library(sf)
  library(tigris)
  options(tigris_use_cache = TRUE)

  states_sf <- states(cb = TRUE, resolution = "20m", year = 2022)
  states_sf <- states_sf[states_sf$STUSPS %in% c(state.abb, "DC"), ]
  states_sf <- shift_geometry(states_sf)

  map_data <- merge(states_sf, unwinding,
                     by.x = "STUSPS", by.y = "state", all.x = TRUE)

  p5 <- ggplot(map_data) +
    geom_sf(aes(fill = disenroll_rate * 100), color = "white", size = 0.2) +
    scale_fill_viridis_c(
      name = "Disenrollment\nRate (%)",
      option = "inferno",
      direction = -1
    ) +
    labs(
      title = "Medicaid Unwinding: Cumulative Disenrollment Rate by State",
      caption = "Source: KFF Medicaid Enrollment and Unwinding Tracker"
    ) +
    theme_void() +
    theme(
      plot.title = element_text(face = "bold", size = 13),
      legend.position = "right"
    )

  ggsave(file.path(FIGS, "fig5_disenrollment_map.pdf"), p5,
         width = 9, height = 6)
}, error = function(e) {
  cat("Map generation failed:", e$message, "\n")
  cat("Skipping Figure 5 (map).\n")
})

## ---- Figure 6: Dose-Response ----
cat("Figure 6: Dose-response...\n")

# State-level change in BH vs HCBS spending, pre vs post
change_data <- panel[, .(
  mean_paid = mean(total_paid, na.rm = TRUE)
), by = .(state, service_cat, post)]

change_wide <- dcast(change_data, state + service_cat ~ post,
                      value.var = "mean_paid")
setnames(change_wide, c("0", "1"), c("pre_paid", "post_paid"))
change_wide[, pct_change := (post_paid - pre_paid) / pre_paid * 100]
change_wide <- merge(change_wide, unwinding[, .(state, disenroll_rate)],
                      by = "state")

p6 <- ggplot(change_wide, aes(x = disenroll_rate * 100, y = pct_change,
                               color = service_cat)) +
  geom_point(alpha = 0.7, size = 2) +
  geom_smooth(method = "lm", se = TRUE, alpha = 0.15) +
  scale_color_manual(values = apep_colors, name = "",
                     labels = c("Behavioral Health", "HCBS")) +
  labs(
    title = "Dose-Response: Spending Change vs. Disenrollment Intensity",
    x = "State Disenrollment Rate (%)",
    y = "Spending Change, Pre to Post (%)",
    caption = "Each point is a state. Lines show OLS fit with 95% CI."
  )

ggsave(file.path(FIGS, "fig6_dose_response.pdf"), p6,
       width = 8, height = 5.5)

## ---- Figure 7: Randomization Inference ----
cat("Figure 7: RI distribution...\n")

ri_df <- data.frame(coef = rob_results$ri_coefs[!is.na(rob_results$ri_coefs)])

p7 <- ggplot(ri_df, aes(x = coef)) +
  geom_histogram(bins = 40, fill = "gray70", color = "white") +
  geom_vline(xintercept = rob_results$obs_coef, color = "#E63946",
             linewidth = 1.2, linetype = "solid") +
  annotate("text", x = rob_results$obs_coef,
           y = Inf, vjust = 2, hjust = -0.1,
           label = sprintf("Observed = %.4f\nRI p = %.3f",
                           rob_results$obs_coef, rob_results$ri_pvalue),
           color = "#E63946", size = 3.5, fontface = "bold") +
  labs(
    title = "Randomization Inference: Distribution of Placebo Coefficients",
    x = "DDD Coefficient (log paid)", y = "Count",
    caption = sprintf("%d permutations of state unwinding assignments.",
                      length(rob_results$ri_coefs))
  )

ggsave(file.path(FIGS, "fig7_ri_distribution.pdf"), p7,
       width = 7, height = 5)

## ---- Figure 8: HHI Trends ----
cat("Figure 8: HHI trends...\n")

hhi_trends <- hhi_state[, .(
  mean_hhi = mean(hhi, na.rm = TRUE)
), by = .(service_cat, month)]

p8 <- ggplot(hhi_trends, aes(x = month, y = mean_hhi * 10000,
                               color = service_cat)) +
  geom_line(linewidth = 0.8) +
  geom_vline(xintercept = as.Date("2023-04-01"), linetype = "dashed",
             color = "gray40") +
  scale_color_manual(values = apep_colors, name = "",
                     labels = c("Behavioral Health", "HCBS")) +
  scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
  labs(
    title = "Market Concentration (HHI) by Service Category",
    x = NULL, y = "HHI (0\u201310,000 scale)",
    caption = "HHI computed at state\u00d7category\u00d7month level."
  )

ggsave(file.path(FIGS, "fig8_hhi_trends.pdf"), p8,
       width = 8, height = 5)

cat("\n=== All figures saved to", FIGS, "===\n")
