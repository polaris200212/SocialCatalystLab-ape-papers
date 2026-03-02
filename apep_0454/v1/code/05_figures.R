## ============================================================================
## 05_figures.R — All figures for apep_0454
## ============================================================================

source("00_packages.R")

panel <- readRDS(file.path(DATA_DIR, "panel_clean.rds"))
results <- readRDS(file.path(DATA_DIR, "main_results.rds"))
rob_results <- readRDS(file.path(DATA_DIR, "robustness_results.rds"))

## ---- Figure 1: Pre-COVID exit intensity map / distribution ----
cat("Figure 1: Exit intensity distribution...\n")

state_exits <- results$state_exits

p1 <- ggplot(state_exits, aes(x = reorder(state, exit_rate), y = exit_rate * 100)) +
  geom_col(aes(fill = exit_quartile), width = 0.7) +
  scale_fill_manual(values = c("Q1 (Low)" = "#003049", "Q2" = "#457B9D",
                                "Q3" = "#F77F00", "Q4 (High)" = "#D62828"),
                    name = "Exit Quartile") +
  coord_flip() +
  labs(
    title = "Pre-COVID Medicaid Provider Exit Rates by State",
    subtitle = "Share of 2018\u20132019 active providers absent from billing after February 2020",
    x = NULL, y = "Exit Rate (%)",
    caption = "Source: T-MSIS Medicaid Provider Spending (2018\u20132024), NPPES."
  ) +
  theme(legend.position = "right")

ggsave(file.path(FIG_DIR, "fig1_exit_distribution.pdf"), p1,
       width = 8, height = 10, device = "pdf")

## ---- Figure 2: Event study — Part 1 (Providers × Exit Rate) ----
cat("Figure 2: COVID event study...\n")

es_ct <- coeftable(results$es_providers)
es_names <- rownames(es_ct)
# Keep only event study coefficients (not unemp_rate etc)
es_idx <- grep("event_m_covid::", es_names)
es_df <- as.data.table(es_ct[es_idx, , drop = FALSE])
# Names are like "event_m_covid::-24:exit_rate" — extract the number between :: and :
es_df[, event_time := as.numeric(gsub("^event_m_covid::([-0-9]+):.*$", "\\1", es_names[es_idx]))]

# Add reference period
es_df <- rbind(
  es_df,
  data.table(Estimate = 0, `Std. Error` = 0, `t value` = 0, `Pr(>|t|)` = 1, event_time = -1),
  use.names = FALSE
)
setnames(es_df, c("est", "se", "t", "p", "event_time"))

es_df[, `:=`(ci_lo = est - 1.96 * se, ci_hi = est + 1.96 * se)]

p2 <- ggplot(es_df, aes(x = event_time, y = est)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
  geom_vline(xintercept = 0, linetype = "dashed", color = apep_colors["post"], alpha = 0.5) +
  geom_vline(xintercept = 13, linetype = "dotted", color = apep_colors["arpa"], alpha = 0.5) +
  geom_ribbon(aes(ymin = ci_lo, ymax = ci_hi), fill = apep_colors["high_exit"], alpha = 0.2) +
  geom_line(color = apep_colors["high_exit"], linewidth = 0.8) +
  geom_point(color = apep_colors["high_exit"], size = 1.5) +
  annotate("text", x = 1, y = max(es_df$ci_hi, na.rm = TRUE) * 0.9,
           label = "COVID onset\n(Mar 2020)", hjust = 0, size = 3, color = "grey40") +
  annotate("text", x = 14, y = max(es_df$ci_hi, na.rm = TRUE) * 0.9,
           label = "ARPA\n(Apr 2021)", hjust = 0, size = 3, color = apep_colors["arpa"]) +
  scale_x_continuous(limits = c(-25, 58), breaks = seq(-24, 57, by = 12)) +
  labs(
    title = "HCBS Provider Supply and Pre-COVID Exit Exposure",
    subtitle = "Coefficients on Exit Rate \u00d7 Event Time (ref: Feb 2020)",
    x = "Months Relative to March 2020",
    y = "Coefficient on Exit Rate \u00d7 Event Time",
    caption = "Notes: 95% CIs from state-clustered SEs. Unit: state-month. Outcome: ln(active HCBS providers).\nData coverage: Jan 2018 (month -24) through Dec 2024 (month 57)."
  )

ggsave(file.path(FIG_DIR, "fig2_event_study_covid.pdf"), p2,
       width = 9, height = 6, device = "pdf")

## ---- Figure 3: Quartile event study (raw trends) ----
cat("Figure 3: Provider trends by exit quartile...\n")

trends <- panel[prov_type == "HCBS" & !is.na(exit_quartile),
                .(mean_idx = mean(idx_providers, na.rm = TRUE)),
                by = .(exit_quartile, month_date)]

p3 <- ggplot(trends, aes(x = month_date, y = mean_idx, color = exit_quartile)) +
  geom_vline(xintercept = as.Date("2020-03-01"), linetype = "dashed", color = "grey50") +
  geom_vline(xintercept = as.Date("2021-04-01"), linetype = "dotted", color = apep_colors["arpa"]) +
  geom_line(linewidth = 0.8) +
  scale_color_manual(values = c("Q1 (Low)" = "#003049", "Q2" = "#457B9D",
                                 "Q3" = "#F77F00", "Q4 (High)" = "#D62828"),
                     name = "Pre-COVID\nExit Quartile") +
  labs(
    title = "HCBS Provider Supply Trends by Pre-COVID Exit Intensity",
    subtitle = "Index: January 2020 = 100",
    x = NULL, y = "Provider Count Index (Jan 2020 = 100)",
    caption = "Source: T-MSIS. Dashed line: COVID onset (Mar 2020). Dotted: ARPA (Apr 2021)."
  )

ggsave(file.path(FIG_DIR, "fig3_quartile_trends.pdf"), p3,
       width = 9, height = 6, device = "pdf")

## ---- Figure 4: DDD — ARPA event study ----
cat("Figure 4: ARPA DDD event study...\n")

# Extract only the arpa_quarter interaction coefficients (filter out unemp_rate etc)
arpa_ct <- coeftable(results$es_arpa_ddd)
arpa_names <- rownames(arpa_ct)
# Keep only rows with "arpa_quarter::" in the name
arpa_idx <- grep("arpa_quarter::", arpa_names)
arpa_df <- as.data.table(arpa_ct[arpa_idx, , drop = FALSE])
# Names are like "arpa_quarter::-12:hcbs_high_exit" — extract the number between :: and :
arpa_df[, quarter := as.numeric(gsub("^arpa_quarter::([-0-9]+):.*$", "\\1", arpa_names[arpa_idx]))]

# Add reference period
arpa_df <- rbind(
  arpa_df,
  data.table(Estimate = 0, `Std. Error` = 0, `t value` = 0, `Pr(>|t|)` = 1, quarter = -1),
  use.names = FALSE
)
setnames(arpa_df, c("est", "se", "t", "p", "quarter"))
arpa_df <- arpa_df[!is.na(quarter)]
arpa_df[, `:=`(ci_lo = est - 1.96 * se, ci_hi = est + 1.96 * se)]
setorder(arpa_df, quarter)

cat(sprintf("  DDD event study: %d quarterly coefficients (range: Q%d to Q%d)\n",
            nrow(arpa_df), min(arpa_df$quarter), max(arpa_df$quarter)))

p4 <- ggplot(arpa_df, aes(x = quarter * 3, y = est)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
  geom_vline(xintercept = 0, linetype = "dashed", color = apep_colors["arpa"]) +
  geom_ribbon(aes(ymin = ci_lo, ymax = ci_hi), fill = apep_colors["arpa"], alpha = 0.2) +
  geom_line(color = apep_colors["arpa"], linewidth = 0.8) +
  geom_point(color = apep_colors["arpa"], size = 2) +
  labs(
    title = "ARPA HCBS Investment: Differential Recovery in Depleted Markets",
    subtitle = "DDD coefficients: HCBS \u00d7 High-Exit States (ref: Q-1 before ARPA)",
    x = "Months Relative to ARPA (April 2021)",
    y = "DDD Coefficient",
    caption = "Notes: 95% CIs from state-clustered SEs. Quarterly bins."
  )

ggsave(file.path(FIG_DIR, "fig4_arpa_event_study.pdf"), p4,
       width = 9, height = 6, device = "pdf")

## ---- Figure 5: Randomization inference ----
cat("Figure 5: Randomization inference...\n")

ri_df <- data.table(coef = rob_results$ri_coefs[!is.na(rob_results$ri_coefs)])

p5 <- ggplot(ri_df, aes(x = coef)) +
  geom_histogram(bins = 50, fill = "grey70", color = "white") +
  geom_vline(xintercept = rob_results$true_coef, color = apep_colors["high_exit"],
             linewidth = 1.2, linetype = "solid") +
  annotate("text", x = rob_results$true_coef, y = Inf, vjust = -0.5,
           label = sprintf("Actual = %.3f\nRI p = %.3f",
                           rob_results$true_coef, rob_results$ri_pvalue),
           color = apep_colors["high_exit"], size = 3.5, hjust = -0.1) +
  labs(
    title = "Randomization Inference: Permutation Distribution",
    subtitle = sprintf("500 permutations of exit intensity across states"),
    x = "Permuted Coefficient on Post-COVID \u00d7 Exit Rate",
    y = "Count",
    caption = "Notes: Red line shows actual estimate. RI p-value: two-sided."
  )

ggsave(file.path(FIG_DIR, "fig5_randomization_inference.pdf"), p5,
       width = 8, height = 5, device = "pdf")

## ---- Figure 6: HCBS vs Non-HCBS trends (DDD visual) ----
cat("Figure 6: HCBS vs Non-HCBS trends...\n")

ddd_trends <- panel[!is.na(high_exit), .(
  mean_idx = mean(idx_providers, na.rm = TRUE)
), by = .(prov_type, high_exit, month_date)]

ddd_trends[, group := paste0(prov_type, ifelse(high_exit, " (High Exit)", " (Low Exit)"))]

p6 <- ggplot(ddd_trends, aes(x = month_date, y = mean_idx,
                               color = group, linetype = group)) +
  geom_vline(xintercept = as.Date("2020-03-01"), linetype = "dashed", color = "grey50") +
  geom_vline(xintercept = as.Date("2021-04-01"), linetype = "dotted", color = "grey50") +
  geom_line(linewidth = 0.7) +
  scale_color_manual(values = c(
    "HCBS (High Exit)" = "#D62828", "HCBS (Low Exit)" = "#F77F00",
    "Non-HCBS (High Exit)" = "#003049", "Non-HCBS (Low Exit)" = "#457B9D"
  ), name = NULL) +
  scale_linetype_manual(values = c(
    "HCBS (High Exit)" = "solid", "HCBS (Low Exit)" = "dashed",
    "Non-HCBS (High Exit)" = "solid", "Non-HCBS (Low Exit)" = "dashed"
  ), name = NULL) +
  labs(
    title = "Provider Supply by Type and Pre-COVID Exit Intensity",
    subtitle = "Index: January 2020 = 100",
    x = NULL, y = "Provider Count Index (Jan 2020 = 100)",
    caption = "Dashed vertical: COVID (Mar 2020). Dotted: ARPA (Apr 2021)."
  )

ggsave(file.path(FIG_DIR, "fig6_ddd_trends.pdf"), p6,
       width = 9, height = 6, device = "pdf")

cat("\n=== All figures generated ===\n")
