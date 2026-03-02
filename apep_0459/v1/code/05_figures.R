## 05_figures.R — Generate all figures for the paper
## apep_0459: Skills-Based Hiring Laws and Public Sector De-Credentialization

source("00_packages.R")

data_dir <- "../data/"
fig_dir <- "../figures/"
dir.create(fig_dir, recursive = TRUE, showWarnings = FALSE)

analysis <- fread(paste0(data_dir, "analysis_panel.csv"))
load(paste0(data_dir, "main_results.RData"))

## ============================================================================
## FIGURE 1: Policy Adoption Timeline
## ============================================================================

treatment <- fread(paste0(data_dir, "treatment_dates.csv"))
treatment[, adopt_date := as.Date(paste0(adopt_year, "-", adopt_month, "-01"))]

fig1 <- ggplot(treatment, aes(x = adopt_date, y = reorder(state_name, adopt_date))) +
  geom_point(aes(color = policy_type, shape = strength), size = 3) +
  scale_color_manual(values = c("executive" = "#2171B5", "legislative" = "#CB181D"),
                     name = "Policy Type",
                     labels = c("Executive Order", "Legislation")) +
  scale_shape_manual(values = c("strong" = 16, "moderate" = 17),
                     name = "Strength",
                     labels = c("Moderate", "Strong")) +
  scale_x_date(date_breaks = "6 months", date_labels = "%b %Y") +
  labs(x = NULL, y = NULL,
       title = "Staggered Adoption of Skills-Based Hiring Laws",
       subtitle = "22 states removed bachelor's degree requirements for government jobs, 2022-2025") +
  theme(axis.text.y = element_text(size = 8))

ggsave(paste0(fig_dir, "fig1_adoption_timeline.pdf"), fig1, width = 8, height = 7)
cat("Figure 1 saved.\n")

## ============================================================================
## FIGURE 2: Raw Trends — Share Without BA (Treated vs. Control)
## ============================================================================

## Compute weighted means by treatment group
trend_data <- analysis[, .(
  share_no_ba = weighted.mean(share_no_ba, n_state_gov, na.rm = TRUE),
  share_no_ba_se = sd(share_no_ba, na.rm = TRUE) / sqrt(uniqueN(state_fips))
), by = .(year, group = ifelse(first_treat > 0, "Treated (22 states)", "Never-treated (29 states)"))]

fig2 <- ggplot(trend_data, aes(x = year, y = share_no_ba, color = group)) +
  geom_line(linewidth = 1) +
  geom_point(size = 2.5) +
  geom_ribbon(aes(ymin = share_no_ba - 1.96 * share_no_ba_se,
                  ymax = share_no_ba + 1.96 * share_no_ba_se,
                  fill = group), alpha = 0.15, color = NA) +
  geom_vline(xintercept = 2021.5, linetype = "dashed", color = "gray50") +
  annotate("text", x = 2021.5, y = max(trend_data$share_no_ba) + 0.01,
           label = "First adoption\n(Maryland, March 2022)", size = 3,
           hjust = 1.05, color = "gray40") +
  scale_color_manual(values = c("#2171B5", "#CB181D")) +
  scale_fill_manual(values = c("#2171B5", "#CB181D")) +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1)) +
  labs(x = NULL, y = "Share of State Gov. Workers Without BA",
       title = "Educational Composition of State Government Workforce",
       subtitle = "Weighted by state government employment; shaded bands show 95% CI",
       color = NULL, fill = NULL)

ggsave(paste0(fig_dir, "fig2_raw_trends.pdf"), fig2, width = 8, height = 5)
cat("Figure 2 saved.\n")

## ============================================================================
## FIGURE 3: CS Event Study
## ============================================================================

tryCatch({
  es_df <- data.frame(
    e = es_cs$egt,
    att = es_cs$att.egt,
    se = es_cs$se.egt
  )
  es_df$ci_lower <- es_df$att - 1.96 * es_df$se
  es_df$ci_upper <- es_df$att + 1.96 * es_df$se

  fig3 <- ggplot(es_df, aes(x = e, y = att)) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "gray60") +
    geom_vline(xintercept = -0.5, linetype = "dashed", color = "gray60") +
    geom_ribbon(aes(ymin = ci_lower, ymax = ci_upper), alpha = 0.2, fill = "#2171B5") +
    geom_point(size = 2.5, color = "#2171B5") +
    geom_line(color = "#2171B5", linewidth = 0.8) +
    scale_x_continuous(breaks = seq(min(es_df$e), max(es_df$e), 1)) +
    labs(x = "Years Relative to Policy Adoption",
         y = "ATT (Share Without BA)",
         title = "Event Study: Skills-Based Hiring Laws",
         subtitle = "Callaway-Sant'Anna estimator; 95% pointwise CI; never-treated comparison") +
    annotate("text", x = -3, y = max(es_df$ci_upper) * 0.9,
             label = "Pre-treatment\n(should be zero)", size = 3, color = "gray40") +
    annotate("text", x = 1, y = max(es_df$ci_upper) * 0.9,
             label = "Post-treatment\n(policy effect)", size = 3, color = "gray40")

  ggsave(paste0(fig_dir, "fig3_event_study.pdf"), fig3, width = 8, height = 5)
  cat("Figure 3 saved.\n")
}, error = function(e) {
  cat("Figure 3 error:", conditionMessage(e), "\n")
})

## ============================================================================
## FIGURE 4: DDD — State Gov vs. Private Sector Trends
## ============================================================================

ddd_trends <- analysis[, .(
  state_gov = weighted.mean(share_no_ba, n_state_gov, na.rm = TRUE),
  private = weighted.mean(share_no_ba_private, n_state_gov, na.rm = TRUE)
), by = .(year, group = ifelse(first_treat > 0, "Treated", "Never-treated"))]

ddd_long <- melt(ddd_trends, id.vars = c("year", "group"),
                 variable.name = "sector", value.name = "share")
ddd_long[, sector := ifelse(sector == "state_gov", "State Government", "Private Sector")]

fig4 <- ggplot(ddd_long, aes(x = year, y = share, color = sector, linetype = group)) +
  geom_line(linewidth = 0.8) +
  geom_point(size = 2) +
  geom_vline(xintercept = 2021.5, linetype = "dashed", color = "gray50") +
  scale_color_manual(values = c("#2171B5", "#CB181D")) +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1)) +
  facet_wrap(~group) +
  labs(x = NULL, y = "Share Without BA",
       title = "Triple-Difference Design: State Government vs. Private Sector",
       subtitle = "If policy drives the effect, divergence should appear only in treated states' state gov sector",
       color = "Sector", linetype = "Treatment Group")

ggsave(paste0(fig_dir, "fig4_ddd_trends.pdf"), fig4, width = 10, height = 5)
cat("Figure 4 saved.\n")

## ============================================================================
## FIGURE 5: Heterogeneity by Policy Strength
## ============================================================================

hetero_data <- analysis[first_treat > 0, .(
  share_no_ba = weighted.mean(share_no_ba, n_state_gov, na.rm = TRUE)
), by = .(year, strength)]

fig5 <- ggplot(hetero_data, aes(x = year, y = share_no_ba, color = strength)) +
  geom_line(linewidth = 1) +
  geom_point(size = 2.5) +
  geom_vline(xintercept = 2021.5, linetype = "dashed", color = "gray50") +
  scale_color_manual(values = c("moderate" = "#FDAE6B", "strong" = "#D94801"),
                     labels = c("Moderate (review/consider)", "Strong (mandate/legislation)")) +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1)) +
  labs(x = NULL, y = "Share Without BA",
       title = "Policy Strength Heterogeneity",
       subtitle = "Strong policies (legislative mandates, 90%+ positions) vs. moderate (executive review orders)",
       color = "Policy Strength")

ggsave(paste0(fig_dir, "fig5_heterogeneity_strength.pdf"), fig5, width = 8, height = 5)
cat("Figure 5 saved.\n")

## ============================================================================
## FIGURE 6: Demographic Effects — Share Black Workers
## ============================================================================

demo_trends <- analysis[, .(
  pct_black = weighted.mean(pct_black, n_state_gov, na.rm = TRUE)
), by = .(year, group = ifelse(first_treat > 0, "Treated", "Never-treated"))]

fig6 <- ggplot(demo_trends, aes(x = year, y = pct_black, color = group)) +
  geom_line(linewidth = 1) +
  geom_point(size = 2.5) +
  geom_vline(xintercept = 2021.5, linetype = "dashed", color = "gray50") +
  scale_color_manual(values = c("#2171B5", "#CB181D")) +
  scale_y_continuous(labels = scales::percent_format(accuracy = 0.1)) +
  labs(x = NULL, y = "Share Black Workers (State Gov.)",
       title = "Demographic Composition: Did Skills-Based Hiring Diversify Government?",
       color = NULL)

ggsave(paste0(fig_dir, "fig6_demographics.pdf"), fig6, width = 8, height = 5)
cat("Figure 6 saved.\n")

cat("\n=== All figures generated ===\n")
