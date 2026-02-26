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

p1 <- ggplot(state_exits, aes(x = reorder(state, exit_rate_pre), y = exit_rate_pre * 100)) +
  geom_col(aes(fill = exit_quartile), width = 0.7) +
  scale_fill_manual(values = c("Q1 (Low)" = "#003049", "Q2" = "#457B9D",
                                "Q3" = "#F77F00", "Q4 (High)" = "#D62828"),
                    name = "Exit Quartile") +
  coord_flip() +
  labs(
    title = "Pre-COVID Medicaid Provider Exit Rates by State",
    subtitle = "Share of 2018 active providers absent from all 2019 billing (pre-treatment measure)",
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
  scale_x_continuous(limits = c(-25, 52), breaks = seq(-24, 48, by = 12)) +
  labs(
    title = "HCBS Provider Supply and Pre-COVID Exit Exposure",
    subtitle = "Coefficients on Exit Rate \u00d7 Event Time (ref: Feb 2020)",
    x = "Months Relative to March 2020",
    y = "Coefficient on Exit Rate \u00d7 Event Time",
    caption = "Notes: 95% CIs from state-clustered SEs. Unit: state-month. Outcome: ln(active HCBS providers).\nData coverage: Jan 2018 (month -24) through Jun 2024 (month 51). Primary analysis truncated at Jun 2024."
  )

ggsave(file.path(FIG_DIR, "fig2_event_study_covid.pdf"), p2,
       width = 9, height = 6, device = "pdf")

## ---- Figure 2b: Multi-panel event study (providers + beneficiaries) ----
cat("Figure 2b: Multi-panel event study (4 outcomes)...\n")

# Helper to extract event study coefficients
extract_es <- function(model, label) {
  ct <- coeftable(model)
  nms <- rownames(ct)
  idx <- grep("event_m_covid::", nms)
  if (length(idx) == 0) return(NULL)
  df <- as.data.table(ct[idx, , drop = FALSE])
  df[, event_time := as.numeric(gsub("^event_m_covid::([-0-9]+):.*$", "\\1", nms[idx]))]
  df <- rbind(df,
    data.table(Estimate = 0, `Std. Error` = 0, `t value` = 0, `Pr(>|t|)` = 1, event_time = -1),
    use.names = FALSE)
  setnames(df, c("est", "se", "t", "p", "event_time"))
  df[, `:=`(ci_lo = est - 1.96 * se, ci_hi = est + 1.96 * se, outcome = label)]
  df
}

es_all <- rbindlist(list(
  extract_es(results$es_providers, "A: ln(Active Providers)"),
  extract_es(results$es_bene, "B: ln(Beneficiaries Served)"),
  extract_es(results$es_claims_per_bene, "C: ln(Claims per Beneficiary)"),
  extract_es(results$es_spending_per_bene, "D: ln(Spending per Beneficiary)")
))

p2b <- ggplot(es_all, aes(x = event_time, y = est)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
  geom_vline(xintercept = 0, linetype = "dashed", color = apep_colors["post"], alpha = 0.5) +
  geom_ribbon(aes(ymin = ci_lo, ymax = ci_hi), fill = apep_colors["high_exit"], alpha = 0.2) +
  geom_line(color = apep_colors["high_exit"], linewidth = 0.6) +
  geom_point(color = apep_colors["high_exit"], size = 1) +
  facet_wrap(~outcome, scales = "free_y", ncol = 2) +
  labs(
    title = "Pre-COVID Provider Exits and Pandemic Disruption: Supply and Access",
    subtitle = "Coefficients on Exit Rate x Event Time (ref: Feb 2020)",
    x = "Months Relative to March 2020",
    y = "Coefficient",
    caption = "Notes: 95% CIs from state-clustered SEs. Panels A-B measure supply/access;\nPanels C-D measure service intensity conditional on access."
  ) +
  theme(strip.text = element_text(face = "bold", size = 9))

ggsave(file.path(FIG_DIR, "fig2b_multipanel_event_study.pdf"), p2b,
       width = 10, height = 8, device = "pdf")

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
    subtitle = sprintf("2,000 permutations of exit intensity across states"),
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

## ---- Figure 7: HonestDiD Sensitivity Plot ----
cat("Figure 7: HonestDiD sensitivity...\n")

if (!is.null(rob_results$honest_rm_prov)) {
  hrm <- as.data.table(rob_results$honest_rm_prov)
  hrm$outcome <- "A: Providers"

  if (!is.null(rob_results$honest_rm_bene)) {
    hrm_bene <- as.data.table(rob_results$honest_rm_bene)
    hrm_bene$outcome <- "B: Beneficiaries"
    hrm_all <- rbind(hrm, hrm_bene)
  } else {
    hrm_all <- hrm
  }

  p7 <- ggplot(hrm_all, aes(x = Mbar, y = (lb + ub) / 2)) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
    geom_ribbon(aes(ymin = lb, ymax = ub), fill = apep_colors["high_exit"], alpha = 0.25) +
    geom_line(color = apep_colors["high_exit"], linewidth = 0.8) +
    facet_wrap(~outcome, scales = "free_y", ncol = 2) +
    labs(
      title = "Sensitivity to Pre-Trend Violations (Rambachan & Roth 2023)",
      subtitle = "Robust confidence sets under relative magnitudes restrictions",
      x = expression(bar(M) ~ "(allowed violation relative to max pre-trend deviation)"),
      y = "Robust Confidence Set for Treatment Effect",
      caption = "Notes: Shaded region shows 95% robust CI. Horizontal line at zero.\nBreakdown value = largest Mbar where CI excludes zero."
    ) +
    theme(strip.text = element_text(face = "bold"))

  ggsave(file.path(FIG_DIR, "fig7_honestdid_sensitivity.pdf"), p7,
         width = 10, height = 5, device = "pdf")
} else {
  cat("  HonestDiD results not available; skipping figure.\n")
}

## ---- Figure 8: Exit Timing Distribution ----
cat("Figure 8: Exit timing distribution...\n")

if (!is.null(rob_results$exit_timing$monthly)) {
  etm <- as.data.table(rob_results$exit_timing$monthly)
  etm <- etm[!is.na(delta_providers)]

  p8 <- ggplot(etm, aes(x = month_date, y = delta_providers)) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
    geom_vline(xintercept = as.Date("2020-03-01"), linetype = "dashed",
               color = apep_colors["post"], alpha = 0.7) +
    geom_col(aes(fill = ifelse(month_date < "2020-03-01", "Pre-COVID", "Post-COVID")),
             width = 25) +
    scale_fill_manual(values = c("Pre-COVID" = apep_colors["pre"],
                                  "Post-COVID" = apep_colors["post"]),
                      name = NULL) +
    annotate("text", x = as.Date("2020-04-01"),
             y = max(etm$delta_providers, na.rm = TRUE) * 0.8,
             label = "COVID onset", hjust = 0, size = 3.5, color = "grey40") +
    labs(
      title = "Monthly Change in National HCBS Provider Counts",
      subtitle = "No bunching of exits near February 2020 supports gradual attrition",
      x = NULL,
      y = "Month-over-Month Change in Average Providers per State",
      caption = "Notes: Each bar shows the mean change in active HCBS providers across states.\nGradual exits in 2018-2019 contrast with the sharp March 2020 break."
    )

  ggsave(file.path(FIG_DIR, "fig8_exit_timing.pdf"), p8,
         width = 9, height = 5, device = "pdf")
} else {
  cat("  Exit timing data not available; skipping figure.\n")
}

## ---- Figure 9: Conditional RI Distribution ----
cat("Figure 9: Conditional RI distribution...\n")

if (!is.null(rob_results$cond_perm_coefs)) {
  cri_df <- data.table(coef = rob_results$cond_perm_coefs[!is.na(rob_results$cond_perm_coefs)])

  p9 <- ggplot(cri_df, aes(x = coef)) +
    geom_histogram(bins = 60, fill = "grey70", color = "white") +
    geom_vline(xintercept = rob_results$true_coef, color = apep_colors["high_exit"],
               linewidth = 1.2) +
    annotate("text", x = rob_results$true_coef, y = Inf, vjust = -0.5,
             label = sprintf("Actual = %.3f\nCond. RI p = %.3f",
                             rob_results$true_coef, rob_results$cond_ri_pvalue),
             color = apep_colors["high_exit"], size = 3.5, hjust = -0.1) +
    labs(
      title = "Conditional Randomization Inference (Within Census Divisions)",
      subtitle = "5,000 permutations preserving regional structure",
      x = "Permuted Coefficient on Post-COVID x Exit Rate",
      y = "Count",
      caption = "Notes: Red line shows actual estimate. Permutations within 9 Census divisions."
    )

  ggsave(file.path(FIG_DIR, "fig9_conditional_ri.pdf"), p9,
         width = 8, height = 5, device = "pdf")
}

## ---- Figure 10: Broken-Trend Model (v8) ----
cat("Figure 10: Broken-trend model — pre-trend extrapolation vs actual...\n")

# Generate predicted values from broken-trend model
bt_prov <- results$bt_providers
bt_lambda <- coef(bt_prov)["exit_x_trend"]
bt_beta <- coef(bt_prov)["exit_x_post"]
bt_kappa <- coef(bt_prov)["exit_x_post_trend"]

# Create a state-level summary for high vs low exit
hcbs_panel <- panel[prov_type == "HCBS"]
hcbs_panel[, time_num := as.integer(factor(month_date, levels = sort(unique(month_date)))) - 1L]

# Mean exit rate for high/low groups
high_exit_mean <- mean(state_exits$exit_rate_pre[state_exits$high_exit == TRUE])
low_exit_mean <- mean(state_exits$exit_rate_pre[state_exits$high_exit == FALSE])

# Construct predicted differential paths
all_months <- sort(unique(hcbs_panel$month_date))
time_nums <- seq_along(all_months) - 1L
post_indicator <- as.integer(all_months >= "2020-03-01")

bt_predict <- data.table(
  month_date = rep(all_months, 2),
  time_num = rep(time_nums, 2),
  post = rep(post_indicator, 2),
  group = rep(c("High Exit", "Low Exit"), each = length(all_months)),
  exit_rate = rep(c(high_exit_mean, low_exit_mean), each = length(all_months))
)

# Differential = lambda * theta * t + beta * theta * Post + kappa * theta * Post * t
bt_predict[, diff_actual := bt_lambda * exit_rate * time_num +
                             bt_beta * exit_rate * post +
                             bt_kappa * exit_rate * post * time_num]
# Counterfactual: extrapolate pre-trend only
bt_predict[, diff_counterfactual := bt_lambda * exit_rate * time_num]

# Melt for plotting
bt_long <- melt(bt_predict[group == "High Exit"],
                id.vars = c("month_date", "group"),
                measure.vars = c("diff_actual", "diff_counterfactual"),
                variable.name = "trajectory", value.name = "diff")
bt_long[, trajectory := fifelse(trajectory == "diff_actual",
                                 "Actual (with COVID shift)", "Pre-trend extrapolation")]

p10 <- ggplot(bt_long, aes(x = month_date, y = diff, color = trajectory, linetype = trajectory)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
  geom_vline(xintercept = as.Date("2020-03-01"), linetype = "dashed", color = "grey40") +
  geom_line(linewidth = 1) +
  scale_color_manual(values = c("Actual (with COVID shift)" = apep_colors["high_exit"],
                                 "Pre-trend extrapolation" = apep_colors["neutral"]),
                     name = NULL) +
  scale_linetype_manual(values = c("Actual (with COVID shift)" = "solid",
                                    "Pre-trend extrapolation" = "dashed"),
                        name = NULL) +
  annotate("text", x = as.Date("2020-05-01"), y = min(bt_long$diff) * 0.7,
           label = "COVID onset", hjust = 0, size = 3.5, color = "grey40") +
  labs(
    title = "Broken-Trend Model: Pre-Trend Extrapolation vs. Actual Trajectory",
    subtitle = sprintf("High-exit states (mean theta = %.1f%%); lambda = %.4f, kappa = %.4f",
                        high_exit_mean * 100, bt_lambda, bt_kappa),
    x = NULL,
    y = "Differential Effect (exit_rate x time)",
    caption = "Notes: Solid line shows estimated differential trajectory including COVID-onset level shift\nand slope change. Dashed line extrapolates the pre-COVID differential trend."
  )

ggsave(file.path(FIG_DIR, "fig10_broken_trend.pdf"), p10,
       width = 9, height = 6, device = "pdf")

## ---- Figure 11: Collapsed Cross-Sectional Scatter (v8) ----
cat("Figure 11: Collapsed scatter plot...\n")

collapsed <- results$collapsed

p11 <- ggplot(collapsed, aes(x = exit_rate_pre * 100, y = delta_ln_providers)) +
  geom_point(size = 2.5, color = apep_colors["high_exit"], alpha = 0.7) +
  geom_smooth(method = "lm", se = TRUE, color = apep_colors["low_exit"],
              fill = apep_colors["low_exit"], alpha = 0.15, linewidth = 1) +
  labs(
    title = "Pre-COVID Exit Rate and Pandemic Provider Loss",
    subtitle = sprintf("Collapsed regression: N = %d states, R-sq = %.3f",
                        nrow(collapsed),
                        summary(results$collapsed_prov)$r.squared),
    x = "Pre-Period Exit Rate (%)",
    y = expression(Delta ~ "ln(HCBS Providers): Post minus Pre"),
    caption = "Notes: Each point is one state. Exit rate = share of 2018 active providers\nabsent from 2019 billing. HC2 robust standard errors."
  )

ggsave(file.path(FIG_DIR, "fig11_collapsed_scatter.pdf"), p11,
       width = 8, height = 6, device = "pdf")

## ---- Figure 12: RI Comparison Across Stratifications (v8) ----
cat("Figure 12: RI comparison across stratifications...\n")

ri_summary <- data.table(
  stratification = c("Unconditional", "Census Divisions", "Census Regions",
                      "Urbanicity Quartiles", "Governor Party"),
  p_value = c(rob_results$ri_pvalue,
              rob_results$cond_ri_pvalue,
              rob_results$ri_pvalue_region,
              rob_results$ri_pvalue_urban,
              rob_results$ri_pvalue_gov),
  n_strata = c(1, 9, 4, 4, 2)
)
ri_summary[, stratification := factor(stratification, levels = stratification)]

p12 <- ggplot(ri_summary, aes(x = stratification, y = p_value)) +
  geom_col(fill = apep_colors["high_exit"], alpha = 0.7, width = 0.6) +
  geom_hline(yintercept = 0.05, linetype = "dashed", color = "black") +
  geom_hline(yintercept = 0.10, linetype = "dotted", color = "grey50") +
  geom_text(aes(label = sprintf("p = %.3f", p_value)), vjust = -0.3, size = 3.5) +
  annotate("text", x = 5.3, y = 0.05, label = "5%", size = 3, color = "black") +
  annotate("text", x = 5.3, y = 0.10, label = "10%", size = 3, color = "grey50") +
  scale_y_continuous(limits = c(0, max(ri_summary$p_value) * 1.3)) +
  labs(
    title = "Randomization Inference p-Values Across Stratifications",
    subtitle = "Robustness of provider supply result to alternative permutation schemes",
    x = NULL, y = "Two-sided RI p-value",
    caption = "Notes: Bars show p-values from permuting exit rates within strata.\nDashed line: 5% significance. Dotted line: 10% significance."
  ) +
  theme(axis.text.x = element_text(angle = 25, hjust = 1))

ggsave(file.path(FIG_DIR, "fig12_ri_comparison.pdf"), p12,
       width = 8, height = 5, device = "pdf")

## ---- Figure 13: Entity-Type Event Study (v8) ----
cat("Figure 13: Entity-type event studies...\n")

extract_es <- function(model, label) {
  ct <- coeftable(model)
  nms <- rownames(ct)
  idx <- grep("event_m_covid::", nms)
  if (length(idx) == 0) return(NULL)
  df <- as.data.table(ct[idx, , drop = FALSE])
  df[, event_time := as.numeric(gsub("^event_m_covid::([-0-9]+):.*$", "\\1", nms[idx]))]
  df <- rbind(df,
    data.table(Estimate = 0, `Std. Error` = 0, `t value` = 0, `Pr(>|t|)` = 1, event_time = -1),
    use.names = FALSE)
  setnames(df, c("est", "se", "t", "p", "event_time"))
  df[, `:=`(ci_lo = est - 1.96 * se, ci_hi = est + 1.96 * se, outcome = label)]
  df
}

es_ent_all <- rbindlist(list(
  extract_es(rob_results$es_ent1, "A: Individual Providers (Type 1)"),
  extract_es(rob_results$es_ent2, "B: Organization Providers (Type 2)")
))

if (nrow(es_ent_all) > 0) {
  p13 <- ggplot(es_ent_all, aes(x = event_time, y = est)) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
    geom_vline(xintercept = 0, linetype = "dashed", color = apep_colors["post"], alpha = 0.5) +
    geom_ribbon(aes(ymin = ci_lo, ymax = ci_hi), fill = apep_colors["high_exit"], alpha = 0.2) +
    geom_line(color = apep_colors["high_exit"], linewidth = 0.6) +
    geom_point(color = apep_colors["high_exit"], size = 1) +
    facet_wrap(~outcome, scales = "free_y", ncol = 2) +
    labs(
      title = "Entity-Type Heterogeneity: Individual vs. Organization Providers",
      subtitle = "Event study coefficients on exit rate x event time (ref: Feb 2020)",
      x = "Months Relative to March 2020",
      y = "Coefficient on Exit Rate x Event Time",
      caption = "Notes: 95% CIs from state-clustered SEs. HCBS providers only.\nType 1 = individual practitioners. Type 2 = organizational entities."
    ) +
    theme(strip.text = element_text(face = "bold", size = 9))

  ggsave(file.path(FIG_DIR, "fig13_entity_type_es.pdf"), p13,
         width = 10, height = 5, device = "pdf")
}

cat("\n=== All figures generated ===\n")
