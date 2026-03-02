## ============================================================
## 05_figures.R
## Publication-quality figures for PDMP Network Spillovers paper
## ============================================================

source("00_packages.R")

data_dir <- "../data/"
fig_dir <- "../figures/"
dir.create(fig_dir, showWarnings = FALSE, recursive = TRUE)

panel <- read_csv(paste0(data_dir, "analysis_panel.csv"), show_col_types = FALSE)
results <- readRDS(paste0(data_dir, "main_results.rds"))
rob_results <- readRDS(paste0(data_dir, "robustness_results.rds"))

## ============================================================
## Figure 1: Overdose Death Rates by Network Exposure Status
## ============================================================

cat("Figure 1: Trends by exposure status...\n")

fig1_data <- panel %>%
  filter(!is.na(total_overdose_rate)) %>%
  mutate(exposure_group = ifelse(high_exposure_50 == 1, "High Exposure", "Low Exposure")) %>%
  group_by(year, exposure_group) %>%
  summarise(
    mean_rate = mean(total_overdose_rate, na.rm = TRUE),
    se_rate = sd(total_overdose_rate, na.rm = TRUE) / sqrt(n()),
    n_states = n(),
    .groups = "drop"
  ) %>%
  filter(n_states >= 2)  # Drop group-years with <2 states to avoid misleading points

fig1 <- ggplot(fig1_data, aes(x = year, y = mean_rate, color = exposure_group,
                                fill = exposure_group)) +
  geom_ribbon(aes(ymin = mean_rate - 1.96 * se_rate,
                  ymax = mean_rate + 1.96 * se_rate), alpha = 0.15, color = NA) +
  geom_line(linewidth = 1.1) +
  geom_point(size = 2) +
  geom_vline(xintercept = 2012, linetype = "dashed", color = "grey50", linewidth = 0.5) +
  annotate("text", x = 2012.3, y = max(fig1_data$mean_rate) * 0.95,
           label = "First PDMP\nmandates", hjust = 0, size = 3, color = "grey40") +
  scale_color_manual(values = c("High Exposure" = apep_colors[1],
                                 "Low Exposure" = apep_colors[2])) +
  scale_fill_manual(values = c("High Exposure" = apep_colors[1],
                                "Low Exposure" = apep_colors[2])) +
  scale_x_continuous(breaks = seq(2011, 2023, 2)) +
  labs(
    title = "Drug Overdose Death Rates by PDMP Network Exposure",
    subtitle = "High exposure: ≥50% of contiguous neighbors have must-query mandates",
    x = "Year",
    y = "Deaths per 100,000 population",
    color = NULL, fill = NULL
  ) +
  theme_apep()

ggsave(paste0(fig_dir, "fig1_trends_by_exposure.pdf"), fig1, width = 8, height = 5)

## ============================================================
## Figure 2: CS-DiD Event Study Plot
## ============================================================

cat("Figure 2: Event study plot...\n")

if (!is.null(results$cs_es)) {
  es_data <- tibble(
    e = results$cs_es$egt,
    att = results$cs_es$att.egt,
    se = results$cs_es$se.egt
  ) %>%
    mutate(
      ci_lo = att - 1.96 * se,
      ci_hi = att + 1.96 * se
    ) %>%
    filter(e >= -6, e <= 8)

  fig2 <- ggplot(es_data, aes(x = e, y = att)) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
    geom_vline(xintercept = -0.5, linetype = "dashed", color = "grey50", linewidth = 0.5) +
    geom_ribbon(aes(ymin = ci_lo, ymax = ci_hi), alpha = 0.15, fill = apep_colors[1]) +
    geom_line(color = apep_colors[1], linewidth = 0.8) +
    geom_point(color = apep_colors[1], size = 2.5) +
    scale_x_continuous(breaks = seq(-6, 8, 2)) +
    labs(
      title = "Event Study: PDMP Network Exposure Effect on Overdose Deaths",
      subtitle = "Callaway-Sant'Anna DR estimator; 95% pointwise confidence intervals",
      x = "Years relative to high network exposure",
      y = "ATT (deaths per 100,000)",
      caption = "Notes: High exposure defined as ≥50% of contiguous neighbors with must-query PDMP mandates.\nControl group: not-yet-treated states. Standard errors clustered at state level."
    ) +
    theme_apep()

  ggsave(paste0(fig_dir, "fig2_event_study.pdf"), fig2, width = 8, height = 5.5)
} else {
  cat("  Skipping: CS-DiD results not available\n")
}

## ============================================================
## Figure 3: Drug-Type Decomposition
## ============================================================

cat("Figure 3: Drug-type decomposition...\n")

drug_coefs <- tibble(
  drug_type = c("Rx Opioids\n(T40.2)", "Heroin\n(T40.1)",
                "Synthetic\nOpioids (T40.4)", "Cocaine\n(T40.5)",
                "Psycho-\nstimulants (T43.6)"),
  drug_var = c("rx_opioids_rate", "heroin_rate", "synthetic_opioids_rate",
               "cocaine_rate", "psychostimulants_rate"),
  order = 1:5
)

drug_coefs <- drug_coefs %>%
  rowwise() %>%
  mutate(
    coef = if (drug_var %in% names(results$drug_results))
      coef(results$drug_results[[drug_var]])["high_exposure_50"] else NA_real_,
    se = if (drug_var %in% names(results$drug_results))
      se(results$drug_results[[drug_var]])["high_exposure_50"] else NA_real_
  ) %>%
  ungroup() %>%
  filter(!is.na(coef)) %>%
  mutate(
    ci_lo = coef - 1.96 * se,
    ci_hi = coef + 1.96 * se,
    sig = ifelse(ci_lo > 0 | ci_hi < 0, "Significant", "Not significant")
  )

fig3 <- ggplot(drug_coefs, aes(x = reorder(drug_type, order), y = coef, color = sig)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
  geom_errorbar(aes(ymin = ci_lo, ymax = ci_hi), width = 0.2, linewidth = 0.8) +
  geom_point(size = 3) +
  scale_color_manual(values = c("Significant" = apep_colors[1],
                                 "Not significant" = "grey60")) +
  labs(
    title = "Network Exposure Effects by Drug Type",
    subtitle = "TWFE estimates of ≥50% neighbor PDMP exposure; 2015-2023",
    x = NULL,
    y = "Effect on deaths per 100,000",
    color = NULL,
    caption = "Notes: Each coefficient from a separate regression with state and year FE.\nStandard errors clustered at state level. 95% confidence intervals shown."
  ) +
  theme_apep() +
  theme(legend.position = "none")

ggsave(paste0(fig_dir, "fig3_drug_type_decomposition.pdf"), fig3, width = 8, height = 5)

## ============================================================
## Figure 4: Network Exposure Over Time (Map or Heat Panel)
## ============================================================

cat("Figure 4: Network exposure evolution...\n")

exposure_evolution <- panel %>%
  filter(year %in% c(2011, 2015, 2019, 2023), !state_abbr %in% c("PR","US","YC")) %>%
  select(state_abbr, year, share_neighbors_pdmp) %>%
  mutate(year_label = paste0("Year: ", year))

fig4 <- ggplot(exposure_evolution, aes(x = reorder(state_abbr, share_neighbors_pdmp),
                                        y = share_neighbors_pdmp,
                                        fill = share_neighbors_pdmp)) +
  geom_col() +
  scale_fill_gradient2(low = "white", mid = apep_colors[6], high = apep_colors[1],
                       midpoint = 0.5, limits = c(0, 1)) +
  facet_wrap(~year_label, ncol = 2) +
  coord_flip() +
  labs(
    title = "PDMP Network Exposure by State Over Time",
    subtitle = "Share of contiguous neighbors with must-query PDMP mandates",
    x = NULL,
    y = "Share of neighbors with must-query PDMP",
    fill = "Exposure"
  ) +
  theme_apep() +
  theme(axis.text.y = element_text(size = 6),
        legend.position = "right")

ggsave(paste0(fig_dir, "fig4_exposure_evolution.pdf"), fig4, width = 10, height = 12)

## ============================================================
## Figure 5: Leave-One-Out Sensitivity
## ============================================================

cat("Figure 5: Leave-one-out sensitivity...\n")

loo_data <- rob_results$loo_coefs

# Get baseline coefficient
baseline_coef <- coef(results$twfe_total)["high_exposure_50"]

fig5 <- ggplot(loo_data, aes(x = reorder(excluded_state, coef), y = coef)) +
  geom_hline(yintercept = baseline_coef, linetype = "dashed", color = apep_colors[2],
             linewidth = 0.7) +
  geom_hline(yintercept = 0, linetype = "solid", color = "grey80") +
  geom_point(color = apep_colors[1], size = 2) +
  geom_errorbar(aes(ymin = coef - 1.96 * se, ymax = coef + 1.96 * se),
                width = 0.3, color = apep_colors[1], linewidth = 0.4) +
  coord_flip() +
  labs(
    title = "Leave-One-Out Sensitivity Analysis",
    subtitle = "TWFE coefficient on network exposure, excluding each state",
    x = "Excluded State",
    y = "Coefficient on PDMP network exposure",
    caption = "Notes: Dashed line shows baseline estimate with all states.\n95% confidence intervals shown."
  ) +
  theme_apep() +
  theme(axis.text.y = element_text(size = 7))

ggsave(paste0(fig_dir, "fig5_loo_sensitivity.pdf"), fig5, width = 8, height = 10)

## ============================================================
## Figure 6: Propensity Score Overlap
## ============================================================

cat("Figure 6: Propensity score overlap...\n")

# Estimate propensity score for overlap visualization
ps_data <- panel %>%
  filter(year >= 2015, !is.na(total_overdose_rate), !is.na(log_pop),
         !is.na(log_income), !is.na(pre_overdose_rate)) %>%
  mutate(treatment = high_exposure_50)

ps_model <- glm(
  treatment ~ log_pop + log_income + pct_white + unemployment_rate +
    own_pdmp + pre_overdose_rate + degree,
  data = ps_data,
  family = binomial()
)

ps_data$pscore <- predict(ps_model, type = "response")

fig6 <- ggplot(ps_data, aes(x = pscore, fill = factor(treatment))) +
  geom_density(alpha = 0.5) +
  scale_fill_manual(values = c("0" = apep_colors[2], "1" = apep_colors[1]),
                    labels = c("Low exposure", "High exposure")) +
  labs(
    title = "Propensity Score Overlap",
    subtitle = "Distribution of estimated propensity scores by treatment group",
    x = "Estimated propensity score",
    y = "Density",
    fill = NULL,
    caption = "Notes: Propensity score from logistic regression on pre-treatment covariates.\nSubstantial overlap supports the unconfoundedness assumption."
  ) +
  theme_apep()

ggsave(paste0(fig_dir, "fig6_propensity_overlap.pdf"), fig6, width = 8, height = 5)

## ============================================================
## Figure 7: Sensitivity Analysis Contour Plot
## ============================================================

cat("Figure 7: Sensitivity analysis...\n")

if (!is.null(rob_results$sens)) {
  pdf(paste0(fig_dir, "fig7_sensitivity_contour.pdf"), width = 8, height = 6)
  plot(rob_results$sens, sensitivity.of = "estimate")
  title(main = "Sensitivity to Unmeasured Confounding",
        sub = "Cinelli & Hazlett (2020) contour plot")
  dev.off()
}

cat("\n==============================\n")
cat("All figures saved to:", fig_dir, "\n")
cat("==============================\n")
