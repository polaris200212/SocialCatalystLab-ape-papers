## ============================================================================
## 05_figures.R — All figure generation
## apep_0448: Early UI Termination and Medicaid HCBS Provider Supply
## ============================================================================

source("00_packages.R")

DATA <- "../data"
FIGS <- "../figures"
dir.create(FIGS, showWarnings = FALSE, recursive = TRUE)

hcbs <- readRDS(file.path(DATA, "hcbs_analysis.rds"))
bh <- readRDS(file.path(DATA, "bh_analysis.rds"))
results <- readRDS(file.path(DATA, "main_results.rds"))
robust <- readRDS(file.path(DATA, "robustness_results.rds"))
panel <- readRDS(file.path(DATA, "panel.rds"))
ui_term <- readRDS(file.path(DATA, "ui_termination.rds"))

## ---- Figure 1: Raw trends in HCBS providers ----
cat("Figure 1: Raw trends...\n")

trend_data <- hcbs[, .(
  mean_providers = mean(n_providers)
), by = .(month_date, early_terminator)]
trend_data[, group := fifelse(early_terminator, "Early Terminators (26 states)",
                               "Maintained Benefits (25 jurisdictions)")]

p1 <- ggplot(trend_data[month_date <= as.Date("2024-11-30")],
             aes(x = month_date, y = mean_providers, color = group)) +
  geom_line(linewidth = 0.8) +
  geom_vline(xintercept = as.Date("2021-07-01"), linetype = "dashed", color = "gray40") +
  annotate("text", x = as.Date("2021-07-01"), y = max(trend_data$mean_providers) * 1.02,
           label = "Early UI\nTermination", size = 3, hjust = 0.5, color = "gray40") +
  scale_color_manual(values = c("Early Terminators (26 states)" = "#E63946",
                                 "Maintained Benefits (25 jurisdictions)" = "#457B9D")) +
  scale_x_date(date_breaks = "1 year", date_labels = "%Y",
               limits = c(as.Date("2018-01-01"), as.Date("2024-11-30"))) +
  labs(
    x = NULL, y = "Mean Active HCBS Providers per State",
    color = NULL
  ) +
  theme(legend.position = "bottom")

ggsave(file.path(FIGS, "fig1_raw_trends.pdf"), p1, width = 8, height = 5)

## ---- Figure 2: Normalized trends ----
cat("Figure 2: Normalized trends...\n")

norm_data <- hcbs[, .(
  mean_norm = mean(norm_providers, na.rm = TRUE)
), by = .(month_date, early_terminator)]
norm_data[, group := fifelse(early_terminator, "Early Terminators",
                              "Maintained Benefits")]

p2 <- ggplot(norm_data[month_date <= as.Date("2024-11-30")],
             aes(x = month_date, y = mean_norm, color = group)) +
  geom_line(linewidth = 0.8) +
  geom_hline(yintercept = 1, linetype = "dotted", color = "gray60") +
  geom_vline(xintercept = as.Date("2021-07-01"), linetype = "dashed", color = "gray40") +
  scale_color_manual(values = c("Early Terminators" = "#E63946",
                                 "Maintained Benefits" = "#457B9D")) +
  scale_x_date(date_breaks = "1 year", date_labels = "%Y",
               limits = c(as.Date("2018-01-01"), as.Date("2024-11-30"))) +
  scale_y_continuous(labels = percent_format(accuracy = 1)) +
  labs(
    x = NULL,
    y = "Provider Count (Relative to Pre-Treatment Mean)",
    color = NULL
  ) +
  theme(legend.position = "bottom")

ggsave(file.path(FIGS, "fig2_normalized_trends.pdf"), p2, width = 8, height = 5)

## ---- Figure 3: CS-DiD Event Study (providers) ----
cat("Figure 3: CS event study (providers)...\n")

es_prov <- results$es$providers
es_dt <- data.table(
  rel_time = es_prov$egt,
  att = es_prov$att.egt,
  se = es_prov$se.egt
)
es_dt[, ci_lo := att - 1.96 * se]
es_dt[, ci_hi := att + 1.96 * se]

p3 <- ggplot(es_dt, aes(x = rel_time, y = att)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray60") +
  geom_vline(xintercept = -0.5, linetype = "dashed", color = "gray40") +
  geom_ribbon(aes(ymin = ci_lo, ymax = ci_hi), alpha = 0.2, fill = "#E63946") +
  geom_line(color = "#E63946", linewidth = 0.8) +
  geom_point(color = "#E63946", size = 1.5) +
  labs(
    x = "Months Relative to UI Termination",
    y = "ATT (Log Active HCBS Providers)"
  ) +
  scale_x_continuous(breaks = seq(-24, 24, 6))

ggsave(file.path(FIGS, "fig3_event_study_providers.pdf"), p3, width = 8, height = 5)

## ---- Figure 4: CS-DiD Event Study (claims) ----
cat("Figure 4: CS event study (claims)...\n")

es_cl <- results$es$claims
es_cl_dt <- data.table(
  rel_time = es_cl$egt,
  att = es_cl$att.egt,
  se = es_cl$se.egt
)
es_cl_dt[, ci_lo := att - 1.96 * se]
es_cl_dt[, ci_hi := att + 1.96 * se]

p4 <- ggplot(es_cl_dt, aes(x = rel_time, y = att)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray60") +
  geom_vline(xintercept = -0.5, linetype = "dashed", color = "gray40") +
  geom_ribbon(aes(ymin = ci_lo, ymax = ci_hi), alpha = 0.2, fill = "#2A9D8F") +
  geom_line(color = "#2A9D8F", linewidth = 0.8) +
  geom_point(color = "#2A9D8F", size = 1.5) +
  labs(
    x = "Months Relative to UI Termination",
    y = "ATT (Log Total HCBS Claims)"
  ) +
  scale_x_continuous(breaks = seq(-24, 24, 6))

ggsave(file.path(FIGS, "fig4_event_study_claims.pdf"), p4, width = 8, height = 5)

## ---- Figure 5: Placebo — BH event study ----
cat("Figure 5: BH placebo event study...\n")

es_bh <- results$es$bh_placebo
es_bh_dt <- data.table(
  rel_time = es_bh$egt,
  att = es_bh$att.egt,
  se = es_bh$se.egt
)
es_bh_dt[, ci_lo := att - 1.96 * se]
es_bh_dt[, ci_hi := att + 1.96 * se]

p5 <- ggplot(es_bh_dt, aes(x = rel_time, y = att)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray60") +
  geom_vline(xintercept = -0.5, linetype = "dashed", color = "gray40") +
  geom_ribbon(aes(ymin = ci_lo, ymax = ci_hi), alpha = 0.2, fill = "#A8DADC") +
  geom_line(color = "#457B9D", linewidth = 0.8) +
  geom_point(color = "#457B9D", size = 1.5) +
  labs(
    x = "Months Relative to UI Termination",
    y = "ATT (Log Active BH Providers)",
    subtitle = "Placebo: Behavioral Health Providers (Higher Wages)"
  ) +
  scale_x_continuous(breaks = seq(-24, 24, 6))

ggsave(file.path(FIGS, "fig5_placebo_bh.pdf"), p5, width = 8, height = 5)

## ---- Figure 6: HCBS vs BH comparison ----
cat("Figure 6: HCBS vs BH comparison...\n")

# Combine event study data
es_combined <- rbind(
  es_dt[, .(rel_time, att, ci_lo, ci_hi, service = "HCBS (T-codes)")],
  es_bh_dt[, .(rel_time, att, ci_lo, ci_hi, service = "Behavioral Health (H-codes)")]
)

p6 <- ggplot(es_combined, aes(x = rel_time, y = att, color = service, fill = service)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray60") +
  geom_vline(xintercept = -0.5, linetype = "dashed", color = "gray40") +
  geom_ribbon(aes(ymin = ci_lo, ymax = ci_hi), alpha = 0.15, color = NA) +
  geom_line(linewidth = 0.8) +
  geom_point(size = 1.5) +
  scale_color_manual(values = c("HCBS (T-codes)" = "#E63946",
                                 "Behavioral Health (H-codes)" = "#457B9D")) +
  scale_fill_manual(values = c("HCBS (T-codes)" = "#E63946",
                                "Behavioral Health (H-codes)" = "#457B9D")) +
  labs(
    x = "Months Relative to UI Termination",
    y = "ATT (Log Active Providers)",
    color = NULL, fill = NULL
  ) +
  scale_x_continuous(breaks = seq(-24, 24, 6)) +
  theme(legend.position = "bottom")

ggsave(file.path(FIGS, "fig6_hcbs_vs_bh.pdf"), p6, width = 8, height = 5)

## ---- Figure 7: Randomization Inference ----
cat("Figure 7: RI distribution (CS-DiD + TWFE)...\n")

# CS-DiD RI panel
ri_cs_dist <- data.table(coef = robust$ri_distribution_cs, estimator = "CS-DiD")
p7a <- ggplot(ri_cs_dist, aes(x = coef)) +
  geom_histogram(bins = 40, fill = "#457B9D", color = "white", alpha = 0.8) +
  geom_vline(xintercept = robust$ri_actual_cs, color = "#E63946",
             linewidth = 1, linetype = "dashed") +
  annotate("text", x = robust$ri_actual_cs, y = Inf,
           label = sprintf("Actual ATT: %.4f\nRI p = %.3f", robust$ri_actual_cs, robust$ri_pvalue_cs),
           hjust = -0.1, vjust = 1.5, size = 3.5, color = "#E63946") +
  labs(
    title = "A. CS-DiD (Primary)",
    x = "Permuted ATT (Log Providers)",
    y = "Count"
  )

# TWFE RI panel
ri_twfe_dist <- data.table(coef = robust$ri_distribution, estimator = "TWFE")
p7b <- ggplot(ri_twfe_dist, aes(x = coef)) +
  geom_histogram(bins = 50, fill = "gray70", color = "white") +
  geom_vline(xintercept = robust$ri_actual, color = "#E63946",
             linewidth = 1, linetype = "dashed") +
  annotate("text", x = robust$ri_actual, y = Inf,
           label = sprintf("Actual: %.4f\nRI p = %.3f", robust$ri_actual, robust$ri_pvalue),
           hjust = -0.1, vjust = 1.5, size = 3.5, color = "#E63946") +
  labs(
    title = "B. TWFE (Comparison)",
    x = "Permuted Treatment Effect (Log Providers)",
    y = "Count"
  )

library(patchwork)
p7 <- p7a + p7b + plot_layout(ncol = 2)
ggsave(file.path(FIGS, "fig7_randomization_inference.pdf"), p7, width = 12, height = 4.5)

## ---- Figure 8: Treatment timing map ----
cat("Figure 8: Treatment map...\n")

# Create state-level data for map
state_map_data <- unique(hcbs[, .(state, early_terminator)])
state_map_data <- merge(state_map_data,
                         ui_term[, .(state, termination_date)],
                         by = "state", all.x = TRUE)
state_map_data[, timing_group := fifelse(
  is.na(termination_date), "Maintained through Sept 6",
  fifelse(termination_date <= as.Date("2021-06-15"), "June 12",
  fifelse(termination_date <= as.Date("2021-06-22"), "June 19",
  fifelse(termination_date <= as.Date("2021-06-30"), "June 26-30",
  "July+"))))]

# Use maps package for simple state map
if (requireNamespace("maps", quietly = TRUE)) {
  library(maps)
  states_map <- map_data("state")

  # State name to abbreviation
  state_names <- data.table(
    region = tolower(state.name),
    state = state.abb
  )
  state_names <- rbind(state_names, data.table(region = "district of columbia", state = "DC"))

  states_map <- merge(as.data.table(states_map), state_names, by = "region", all.x = TRUE)
  states_map <- merge(states_map, state_map_data, by = "state", all.x = TRUE)
  setorder(states_map, group, order)

  p8 <- ggplot(states_map, aes(x = long, y = lat, group = group, fill = timing_group)) +
    geom_polygon(color = "white", linewidth = 0.2) +
    scale_fill_manual(
      values = c("June 12" = "#800000", "June 19" = "#E63946",
                 "June 26-30" = "#F4845F", "July+" = "#F4A261",
                 "Maintained through Sept 6" = "#457B9D"),
      na.value = "gray90"
    ) +
    coord_map("albers", lat0 = 39, lat1 = 45) +
    labs(fill = "UI Termination Timing") +
    theme_void() +
    theme(legend.position = "bottom")

  ggsave(file.path(FIGS, "fig8_treatment_map.pdf"), p8, width = 9, height = 5.5)
} else {
  cat("  maps package not available — skipping Figure 8\n")
}

## ---- Figure 9: Event study for paid and beneficiaries ----
cat("Figure 9: Multi-outcome event study...\n")

es_paid <- results$es$paid
es_benes <- results$es$benes

es_multi <- rbind(
  es_dt[, .(rel_time, att, ci_lo, ci_hi, outcome = "Providers")],
  es_cl_dt[, .(rel_time, att, ci_lo, ci_hi, outcome = "Claims")],
  data.table(rel_time = es_paid$egt, att = es_paid$att.egt,
             ci_lo = es_paid$att.egt - 1.96 * es_paid$se.egt,
             ci_hi = es_paid$att.egt + 1.96 * es_paid$se.egt,
             outcome = "Payments"),
  data.table(rel_time = es_benes$egt, att = es_benes$att.egt,
             ci_lo = es_benes$att.egt - 1.96 * es_benes$se.egt,
             ci_hi = es_benes$att.egt + 1.96 * es_benes$se.egt,
             outcome = "Beneficiaries")
)

p9 <- ggplot(es_multi, aes(x = rel_time, y = att)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray60") +
  geom_vline(xintercept = -0.5, linetype = "dashed", color = "gray40") +
  geom_ribbon(aes(ymin = ci_lo, ymax = ci_hi), alpha = 0.2, fill = "#E63946") +
  geom_line(color = "#E63946", linewidth = 0.6) +
  geom_point(color = "#E63946", size = 1) +
  facet_wrap(~outcome, scales = "free_y", ncol = 2) +
  labs(
    x = "Months Relative to UI Termination",
    y = "ATT (Log Outcome)"
  ) +
  scale_x_continuous(breaks = seq(-24, 24, 12))

ggsave(file.path(FIGS, "fig9_multi_outcome_es.pdf"), p9, width = 9, height = 6)

## ---- Figure 10: Entity Type Event Studies ----
cat("Figure 10: Entity type event studies...\n")

ent_results <- readRDS(file.path(DATA, "entity_type_results.rds"))

# Type 1 (Individual) event study
es_t1 <- ent_results$cs_type1_es
es_t2 <- ent_results$cs_type2_es

if (!is.null(es_t1) && !is.null(es_t2)) {
  es_entity <- rbind(
    data.table(rel_time = es_t1$egt, att = es_t1$att.egt,
               ci_lo = es_t1$att.egt - 1.96 * es_t1$se.egt,
               ci_hi = es_t1$att.egt + 1.96 * es_t1$se.egt,
               type = "Individual (Type 1)"),
    data.table(rel_time = es_t2$egt, att = es_t2$att.egt,
               ci_lo = es_t2$att.egt - 1.96 * es_t2$se.egt,
               ci_hi = es_t2$att.egt + 1.96 * es_t2$se.egt,
               type = "Organization (Type 2)")
  )

  p10a <- ggplot(es_entity[type == "Individual (Type 1)"],
                 aes(x = rel_time, y = att)) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "gray60") +
    geom_vline(xintercept = -0.5, linetype = "dashed", color = "gray40") +
    geom_ribbon(aes(ymin = ci_lo, ymax = ci_hi), alpha = 0.2, fill = "#264653") +
    geom_line(color = "#264653", linewidth = 0.8) +
    geom_point(color = "#264653", size = 1.5) +
    labs(title = "A. Individual NPIs (Type 1)",
         x = "Months Relative to UI Termination",
         y = "ATT (Log Providers)") +
    scale_x_continuous(breaks = seq(-24, 24, 6))

  p10b <- ggplot(es_entity[type == "Organization (Type 2)"],
                 aes(x = rel_time, y = att)) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "gray60") +
    geom_vline(xintercept = -0.5, linetype = "dashed", color = "gray40") +
    geom_ribbon(aes(ymin = ci_lo, ymax = ci_hi), alpha = 0.2, fill = "#E76F51") +
    geom_line(color = "#E76F51", linewidth = 0.8) +
    geom_point(color = "#E76F51", size = 1.5) +
    labs(title = "B. Organizational NPIs (Type 2)",
         x = "Months Relative to UI Termination",
         y = "ATT (Log Providers)") +
    scale_x_continuous(breaks = seq(-24, 24, 6))

  p10 <- p10a + p10b + plot_layout(ncol = 2)
  ggsave(file.path(FIGS, "fig10_entity_type_es.pdf"), p10, width = 12, height = 4.5)
} else {
  cat("  Entity type event studies unavailable — skipping Figure 10\n")
}

cat("\n=== All figures generated ===\n")
