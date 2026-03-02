## ============================================================================
## 05_figures.R — All figures for Medicaid unwinding paper
## ============================================================================

source("00_packages.R")
library(dplyr)

## ---- Load data ----
hcbs     <- readRDS(file.path(DATA, "hcbs_state_month.rds"))
nonhcbs  <- readRDS(file.path(DATA, "nonhcbs_state_month.rds"))
treat    <- readRDS(file.path(DATA, "treatment_timing.rds"))
results  <- readRDS(file.path(DATA, "main_results.rds"))
rob      <- readRDS(file.path(DATA, "robustness_results.rds"))
hhi_data <- readRDS(file.path(DATA, "hcbs_hhi.rds"))

# Try to load CS-DiD results
cs_dyn   <- tryCatch(readRDS(file.path(DATA, "cs_dynamic.rds")), error = function(e) NULL)
cs_exit  <- tryCatch(readRDS(file.path(DATA, "cs_exit_dyn.rds")), error = function(e) NULL)

# Colors
col_hcbs <- "#2166AC"
col_nonhcbs <- "#B2182B"
col_treat <- "#D6604D"

## ---- Figure 1: National HCBS provider counts over time ----
cat("Figure 1: National HCBS provider counts...\n")
national <- hcbs[, .(
  n_providers = sum(n_providers),
  total_paid  = sum(total_paid) / 1e9
), by = month_date]

p1 <- ggplot(national, aes(x = month_date, y = n_providers)) +
  geom_line(linewidth = 0.8, color = col_hcbs) +
  geom_vline(xintercept = as.Date("2023-04-01"), linetype = "dashed",
             color = col_treat, linewidth = 0.6) +
  annotate("text", x = as.Date("2023-04-01"), y = max(national$n_providers) * 0.95,
           label = "Unwinding begins\n(April 2023)", hjust = -0.05, size = 3,
           color = col_treat) +
  labs(x = NULL, y = "Active HCBS Providers",
       title = "A. Active HCBS Providers by Month") +
  scale_y_continuous(labels = comma) +
  scale_x_date(date_breaks = "1 year", date_labels = "%Y")
ggsave(file.path(FIG, "fig1_national_providers.pdf"), p1, width = 7, height = 4.5)

## ---- Figure 2: Event study (TWFE) ----
cat("Figure 2: Event study...\n")
es_data <- as.data.table(coeftable(results$es_providers))
# Parse coefficient names to get relative time
es_data[, rel_time := as.integer(gsub(".*::", "", gsub("rel_time_binned::", "", row.names(coeftable(results$es_providers)))))]
setnames(es_data, c("Estimate", "Std. Error", "t value", "Pr(>|t|)"),
         c("estimate", "se", "tval", "pval"))
es_data[, ci_lo := estimate - 1.96 * se]
es_data[, ci_hi := estimate + 1.96 * se]

p2 <- ggplot(es_data, aes(x = rel_time, y = estimate)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
  geom_vline(xintercept = -0.5, linetype = "dashed", color = col_treat) +
  geom_ribbon(aes(ymin = ci_lo, ymax = ci_hi), alpha = 0.2, fill = col_hcbs) +
  geom_point(size = 1.5, color = col_hcbs) +
  geom_line(color = col_hcbs, linewidth = 0.5) +
  labs(x = "Months Relative to Unwinding Start",
       y = "Effect on Log(HCBS Providers)",
       title = "B. Event Study: HCBS Provider Count") +
  scale_x_continuous(breaks = seq(-24, 18, 6))
ggsave(file.path(FIG, "fig2_event_study.pdf"), p2, width = 7, height = 4.5)

## ---- Figure 3: Callaway-Sant'Anna dynamic effects ----
cat("Figure 3: CS-DiD dynamic effects...\n")
if (!is.null(cs_dyn)) {
  p3 <- ggdid(cs_dyn, title = "C. Callaway-Sant'Anna: Dynamic ATT (Log HCBS Providers)") +
    theme_minimal(base_size = 11) +
    theme(plot.title = element_text(face = "bold"))
  ggsave(file.path(FIG, "fig3_cs_dynamic.pdf"), p3, width = 7, height = 4.5)
} else {
  cat("  CS-DiD results not available, skipping.\n")
}

## ---- Figure 4: Placebo — HCBS vs Non-HCBS comparison ----
cat("Figure 4: HCBS vs Non-HCBS placebo...\n")

# Normalize to 100 at 2023-03 (last pre-treatment month)
hcbs_nat <- hcbs[, .(n_providers = sum(n_providers)), by = month_date]
nonhcbs_nat <- nonhcbs[, .(n_providers = sum(n_providers)), by = month_date]

base_hcbs <- hcbs_nat[month_date == as.Date("2023-03-01")]$n_providers
base_non  <- nonhcbs_nat[month_date == as.Date("2023-03-01")]$n_providers

comparison <- rbind(
  hcbs_nat[, .(month_date, index = n_providers / base_hcbs * 100, type = "HCBS (100% Medicaid)")],
  nonhcbs_nat[, .(month_date, index = n_providers / base_non * 100, type = "Non-HCBS (Medicare alternative)")]
)

p4 <- ggplot(comparison, aes(x = month_date, y = index, color = type)) +
  geom_line(linewidth = 0.8) +
  geom_vline(xintercept = as.Date("2023-04-01"), linetype = "dashed",
             color = "gray40") +
  geom_hline(yintercept = 100, linetype = "dotted", color = "gray60") +
  scale_color_manual(values = c(col_hcbs, col_nonhcbs)) +
  labs(x = NULL, y = "Provider Count (Index: March 2023 = 100)",
       title = "D. Placebo: HCBS vs Non-HCBS Providers",
       color = NULL) +
  scale_x_date(date_breaks = "1 year", date_labels = "%Y")
ggsave(file.path(FIG, "fig4_placebo.pdf"), p4, width = 7, height = 4.5)

## ---- Figure 5: Treatment intensity scatter ----
cat("Figure 5: Treatment intensity...\n")

# Change in log providers by state
pre_mean <- hcbs[month_date < as.Date("2023-04-01"),
                  .(pre_log_prov = mean(log_providers)), by = state]
post_mean <- hcbs[month_date >= as.Date("2023-04-01"),
                   .(post_log_prov = mean(log_providers)), by = state]
state_change <- merge(pre_mean, post_mean, by = "state")
state_change[, delta := post_log_prov - pre_log_prov]
state_change <- merge(state_change, treat, by = "state")

p5 <- ggplot(state_change, aes(x = disenroll_rate * 100, y = delta)) +
  geom_point(size = 2, alpha = 0.7, color = col_hcbs) +
  geom_smooth(method = "lm", se = TRUE, color = col_treat, fill = col_treat,
              alpha = 0.2) +
  geom_text(aes(label = state), size = 2, vjust = -0.5, alpha = 0.6) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
  labs(x = "Medicaid Disenrollment Rate (%)",
       y = "Change in Log(HCBS Providers)",
       title = "E. Treatment Intensity: Disenrollment Rate vs Provider Decline")
ggsave(file.path(FIG, "fig5_intensity.pdf"), p5, width = 7, height = 5)

## ---- Figure 6: Heterogeneity — Individual vs Organization ----
cat("Figure 6: Heterogeneity...\n")

het_data <- hcbs[, .(
  individual = sum(n_individual),
  organization = sum(n_org)
), by = month_date]

base_ind <- het_data[month_date == as.Date("2023-03-01")]$individual
base_org <- het_data[month_date == as.Date("2023-03-01")]$organization

het_long <- rbind(
  het_data[, .(month_date, index = individual / base_ind * 100, type = "Individual Providers")],
  het_data[, .(month_date, index = organization / base_org * 100, type = "Organizations")]
)

p6 <- ggplot(het_long, aes(x = month_date, y = index, color = type)) +
  geom_line(linewidth = 0.8) +
  geom_vline(xintercept = as.Date("2023-04-01"), linetype = "dashed",
             color = "gray40") +
  geom_hline(yintercept = 100, linetype = "dotted", color = "gray60") +
  scale_color_manual(values = c(col_hcbs, "#4393C3")) +
  labs(x = NULL, y = "Provider Count (Index: March 2023 = 100)",
       title = "F. Heterogeneity: Individual vs Organizational HCBS Providers",
       color = NULL) +
  scale_x_date(date_breaks = "1 year", date_labels = "%Y")
ggsave(file.path(FIG, "fig6_heterogeneity.pdf"), p6, width = 7, height = 4.5)

## ---- Figure 7: Market concentration (HHI) over time ----
cat("Figure 7: Market concentration...\n")

hhi_nat <- hhi_data[, .(
  mean_hhi = mean(hhi, na.rm = TRUE),
  median_hhi = median(hhi, na.rm = TRUE),
  p75_hhi = quantile(hhi, 0.75, na.rm = TRUE)
), by = .(year, quarter)]
hhi_nat[, date := as.Date(paste0(year, "-", sprintf("%02d", (quarter - 1) * 3 + 1), "-01"))]

p7 <- ggplot(hhi_nat, aes(x = date)) +
  geom_line(aes(y = mean_hhi), linewidth = 0.8, color = col_hcbs) +
  geom_ribbon(aes(ymin = median_hhi, ymax = p75_hhi), alpha = 0.15, fill = col_hcbs) +
  geom_vline(xintercept = as.Date("2023-04-01"), linetype = "dashed",
             color = col_treat) +
  labs(x = NULL, y = "HHI (10,000 = monopoly)",
       title = "G. HCBS Market Concentration Over Time") +
  scale_x_date(date_breaks = "1 year", date_labels = "%Y")
ggsave(file.path(FIG, "fig7_hhi.pdf"), p7, width = 7, height = 4.5)

## ---- Figure 8: Permutation inference distribution ----
cat("Figure 8: Permutation inference...\n")

perm_dt <- data.table(coef = rob$perm_coefs)
actual <- coef(results$twfe_providers)["post"]

p8 <- ggplot(perm_dt, aes(x = coef)) +
  geom_histogram(bins = 50, fill = "gray70", color = "white") +
  geom_vline(xintercept = actual, color = col_treat, linewidth = 1) +
  annotate("text", x = actual, y = Inf, label = sprintf("Actual = %.4f\np = %.3f",
           actual, rob$perm_p), vjust = 2, hjust = -0.1, size = 3, color = col_treat) +
  labs(x = "Coefficient under Random Treatment Assignment",
       y = "Count",
       title = "H. Permutation Inference: 1,000 Random Reassignments")
ggsave(file.path(FIG, "fig8_permutation.pdf"), p8, width = 7, height = 4.5)

## ---- Figure 9: Leave-one-out stability ----
cat("Figure 9: Leave-one-out...\n")

loo <- rob$loo
setorder(loo, coef)
loo[, rank := .I]

p9 <- ggplot(loo, aes(x = rank, y = coef)) +
  geom_point(size = 1.5, color = col_hcbs) +
  geom_hline(yintercept = actual, linetype = "dashed", color = col_treat) +
  geom_hline(yintercept = 0, linetype = "dotted", color = "gray50") +
  labs(x = "State Excluded (ranked by coefficient)",
       y = "TWFE Coefficient (log providers)",
       title = "I. Leave-One-Out: Excluding Each State")
ggsave(file.path(FIG, "fig9_loo.pdf"), p9, width = 7, height = 4.5)

## ---- Figure 10: Treatment timing map ----
cat("Figure 10: Treatment timing map...\n")

shapes <- tryCatch(readRDS(file.path(DATA, "state_shapes.rds")), error = function(e) NULL)
if (!is.null(shapes)) {
  map_data <- merge(shapes, treat[, .(state, unwinding_month, disenroll_rate)],
                    by.x = "STUSPS", by.y = "state", all.x = TRUE)

  p10 <- ggplot(map_data) +
    geom_sf(aes(fill = unwinding_month), color = "white", linewidth = 0.2) +
    scale_fill_brewer(palette = "RdYlBu", direction = -1, na.value = "gray90",
                      name = "Unwinding Start") +
    labs(title = "J. Medicaid Unwinding Start Date by State") +
    theme_void(base_size = 11) +
    theme(plot.title = element_text(face = "bold"),
          legend.position = "bottom")
  ggsave(file.path(FIG, "fig10_timing_map.pdf"), p10, width = 8, height = 5)
} else {
  cat("  State shapes not available, skipping map.\n")
}

cat("\n=== All figures saved ===\n")
