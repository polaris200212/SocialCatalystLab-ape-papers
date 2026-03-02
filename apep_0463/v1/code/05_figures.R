## ============================================================
## 05_figures.R — All Figure Generation
## APEP-0463: Cash Scarcity and Food Prices (Nigeria 2023)
## ============================================================

source("00_packages.R")

data_dir <- "../data"
fig_dir <- "../figures"
dir.create(fig_dir, showWarnings = FALSE, recursive = TRUE)

analysis <- readRDS(file.path(data_dir, "analysis.rds"))
results <- readRDS(file.path(data_dir, "main_results.rds"))
robustness <- readRDS(file.path(data_dir, "robustness_results.rds"))
bank_branches <- readRDS(file.path(data_dir, "bank_branches.rds"))

## ---------------------------------------------------------
## Figure 1: Raw food price trends by banking density group
## ---------------------------------------------------------
cat("Generating Figure 1: Price trends by banking density...\n")

## Split states into high/low banking density
median_scarcity <- median(analysis$cash_scarcity_std, na.rm = TRUE)
analysis[, density_group := ifelse(
  cash_scarcity_std > median_scarcity,
  "Low Banking Density\n(High Cash Scarcity)",
  "High Banking Density\n(Low Cash Scarcity)"
)]

## Monthly averages for cleaner plot
monthly_trends <- analysis[, .(
  log_food_price = mean(log_food_price_idx, na.rm = TRUE),
  se = sd(log_food_price_idx, na.rm = TRUE) / sqrt(.N)
), by = .(year_month, density_group)]

p1 <- ggplot(monthly_trends,
             aes(x = year_month, y = log_food_price,
                 color = density_group, fill = density_group)) +
  geom_ribbon(aes(ymin = log_food_price - 1.96 * se,
                  ymax = log_food_price + 1.96 * se),
              alpha = 0.15, color = NA) +
  geom_line(linewidth = 0.8) +
  geom_vline(xintercept = as.Date("2022-10-26"),
             linetype = "dashed", color = "grey40", linewidth = 0.5) +
  geom_vline(xintercept = as.Date("2023-01-31"),
             linetype = "solid", color = apep_colors["treated"], linewidth = 0.7) +
  geom_vline(xintercept = as.Date("2023-03-03"),
             linetype = "dotted", color = apep_colors["neutral"], linewidth = 0.7) +
  annotate("text", x = as.Date("2022-10-26"), y = Inf,
           label = "CBN\nAnnouncement", vjust = 1.5, hjust = 1.1,
           size = 2.8, color = "grey40") +
  annotate("text", x = as.Date("2023-01-31"), y = Inf,
           label = "Deadline", vjust = 1.5, hjust = -0.1,
           size = 2.8, color = apep_colors["treated"]) +
  annotate("text", x = as.Date("2023-03-03"), y = Inf,
           label = "Supreme\nCourt", vjust = 1.5, hjust = -0.1,
           size = 2.8, color = apep_colors["neutral"]) +
  scale_color_manual(values = c(apep_colors["treated"], apep_colors["control"])) +
  scale_fill_manual(values = c(apep_colors["treated"], apep_colors["control"])) +
  labs(
    x = NULL,
    y = "Log Food Price Index",
    color = NULL, fill = NULL
  ) +
  theme(legend.position = "bottom")

ggsave(file.path(fig_dir, "fig1_price_trends.pdf"),
       p1, width = 7, height = 5)

## ---------------------------------------------------------
## Figure 2: Event Study Plot
## ---------------------------------------------------------
cat("Generating Figure 2: Event study...\n")

## Extract event study coefficients
m_es <- results$m_es
es_df <- as.data.table(coeftable(m_es))
es_df[, event_week := as.integer(gsub("event_week::|:cash_scarcity_std", "",
                                       rownames(coeftable(m_es))))]
setnames(es_df, c("Estimate", "Std. Error", "t value", "Pr(>|t|)"),
         c("coef", "se", "t", "pval"))
## Add reference period
es_df <- rbind(es_df, data.table(coef = 0, se = 0, t = 0, pval = 1,
                                  event_week = -1))

## Restrict to ±26 weeks for main figure
es_plot <- es_df[event_week >= -26 & event_week <= 26]

p2 <- ggplot(es_plot, aes(x = event_week, y = coef)) +
  geom_hline(yintercept = 0, color = "grey60", linewidth = 0.3) +
  geom_vline(xintercept = -0.5, linetype = "dashed",
             color = apep_colors["treated"], linewidth = 0.5) +
  geom_ribbon(aes(ymin = coef - 1.96 * se, ymax = coef + 1.96 * se),
              fill = apep_colors["control"], alpha = 0.2) +
  geom_point(size = 1.5, color = apep_colors["control"]) +
  geom_line(color = apep_colors["control"], linewidth = 0.5) +
  annotate("text", x = -0.5, y = Inf, label = "Deadline",
           vjust = 1.5, hjust = 1.1, size = 2.8,
           color = apep_colors["treated"]) +
  labs(
    x = "Weeks Relative to Naira Deadline (Jan 30, 2023)",
    y = expression(hat(beta)[k] ~ "(Cash Scarcity" ~ times ~ "Event Week)")
  )

ggsave(file.path(fig_dir, "fig2_event_study.pdf"),
       p2, width = 7, height = 5)

## ---------------------------------------------------------
## Figure 3: Treatment Intensity Map / Distribution
## ---------------------------------------------------------
cat("Generating Figure 3: Treatment intensity distribution...\n")

## Bar chart of treatment intensity by state (for FEWS NET states)
fewsnet_states <- unique(analysis$state)
treat_data <- bank_branches[state %in% fewsnet_states]
treat_data[, state_label := reorder(state, cash_scarcity_std)]

p3 <- ggplot(treat_data,
             aes(x = state_label, y = branches_per_100k)) +
  geom_col(aes(fill = cash_scarcity_std), width = 0.7) +
  scale_fill_gradient(low = apep_colors["treated"],
                      high = apep_colors["control"],
                      name = "Cash Scarcity\n(Standardized)") +
  coord_flip() +
  labs(
    x = NULL,
    y = "Bank Branches per 100,000 Population"
  ) +
  theme(legend.position = "right")

ggsave(file.path(fig_dir, "fig3_treatment_intensity.pdf"),
       p3, width = 7, height = 5)

## ---------------------------------------------------------
## Figure 4: Placebo Test Distribution
## ---------------------------------------------------------
cat("Generating Figure 4: Placebo test distribution...\n")

placebo <- robustness$placebo_results
## Add the actual result
actual <- data.table(
  placebo_date = as.Date("2023-01-30"),
  coef = robustness$actual_coef,
  se = NA_real_,
  pval = NA_real_
)

if (nrow(placebo) > 0) {
  p4 <- ggplot(placebo, aes(x = placebo_date, y = coef)) +
    geom_hline(yintercept = 0, color = "grey60", linewidth = 0.3) +
    geom_pointrange(aes(ymin = coef - 1.96 * se, ymax = coef + 1.96 * se),
                    color = apep_colors["grey"], size = 0.3) +
    geom_pointrange(data = actual,
                    aes(ymin = coef, ymax = coef),
                    color = apep_colors["treated"], size = 0.8) +
    annotate("text", x = as.Date("2023-01-30"), y = actual$coef,
             label = "Actual\nCrisis", hjust = -0.2, vjust = 0.5,
             size = 2.8, color = apep_colors["treated"]) +
    labs(
      x = "Placebo Crisis Date",
      y = "Estimated Coefficient"
    )

  ggsave(file.path(fig_dir, "fig4_placebo_tests.pdf"),
         p4, width = 7, height = 4.5)
}

## ---------------------------------------------------------
## Figure 5: Commodity Heterogeneity
## ---------------------------------------------------------
cat("Generating Figure 5: Commodity heterogeneity...\n")

hetero <- robustness$hetero_results
if (nrow(hetero) > 0) {
  hetero[, product_group := reorder(product_group, coef)]

  p5 <- ggplot(hetero, aes(x = product_group, y = coef)) +
    geom_hline(yintercept = 0, color = "grey60", linewidth = 0.3) +
    geom_pointrange(aes(ymin = coef - 1.96 * se, ymax = coef + 1.96 * se),
                    color = apep_colors["control"], size = 0.8) +
    coord_flip() +
    labs(
      x = NULL,
      y = expression("Estimated " ~ hat(beta) ~ " (Cash Scarcity" ~ times ~ "Crisis)")
    )

  ggsave(file.path(fig_dir, "fig5_commodity_hetero.pdf"),
         p5, width = 7, height = 4)
}

## ---------------------------------------------------------
## Figure 6: Randomization Inference Distribution
## ---------------------------------------------------------
cat("Generating Figure 6: Randomization inference...\n")

perm_df <- data.table(coef = robustness$perm_coefs)
perm_df <- perm_df[!is.na(coef)]

p6 <- ggplot(perm_df, aes(x = coef)) +
  geom_histogram(bins = 50, fill = "grey70", color = "white") +
  geom_vline(xintercept = robustness$actual_coef,
             color = apep_colors["treated"], linewidth = 1) +
  geom_vline(xintercept = -robustness$actual_coef,
             color = apep_colors["treated"], linewidth = 1, linetype = "dashed") +
  annotate("text", x = robustness$actual_coef, y = Inf,
           label = paste0("Actual\np(RI) = ",
                          sprintf("%.3f", robustness$ri_pval)),
           vjust = 1.5, hjust = -0.1,
           size = 3, color = apep_colors["treated"]) +
  labs(
    x = "Permuted Coefficient",
    y = "Count"
  )

ggsave(file.path(fig_dir, "fig6_ri_distribution.pdf"),
       p6, width = 6, height = 4)

## ---------------------------------------------------------
## Figure 7: Dose-Response
## ---------------------------------------------------------
cat("Generating Figure 7: Dose-response...\n")

m_dose <- robustness$m_dose
dose_df <- as.data.table(coeftable(m_dose))
dose_df[, quintile := as.integer(gsub("scarcity_q::|:crisis_acute", "",
                                       rownames(coeftable(m_dose))))]
setnames(dose_df, c("Estimate", "Std. Error", "t value", "Pr(>|t|)"),
         c("coef", "se", "t", "pval"))
dose_df <- rbind(dose_df, data.table(coef = 0, se = 0, t = 0, pval = 1,
                                      quintile = 1L))

p7 <- ggplot(dose_df, aes(x = quintile, y = coef)) +
  geom_hline(yintercept = 0, color = "grey60", linewidth = 0.3) +
  geom_pointrange(aes(ymin = coef - 1.96 * se, ymax = coef + 1.96 * se),
                  color = apep_colors["control"], size = 0.8) +
  scale_x_continuous(breaks = 1:5,
                     labels = paste0("Q", 1:5, "\n(",
                                     c("Most", "", "", "", "Least"),
                                     " Banking)")) +
  labs(
    x = "Cash Scarcity Quintile",
    y = expression("Estimated " ~ hat(beta) ~ " (Crisis Effect)")
  )

ggsave(file.path(fig_dir, "fig7_dose_response.pdf"),
       p7, width = 6, height = 4.5)

cat("\nAll figures generated in:", fig_dir, "\n")
cat("Files:", paste(list.files(fig_dir), collapse = ", "), "\n")
