## ============================================================================
## 05_figures.R — Generate all figures
## Paper: The Elasticity of Medicaid's Safety Net (apep_0354)
## ============================================================================

source("00_packages.R")

DATA <- "../data"
FIGS <- "../figures"
dir.create(FIGS, showWarnings = FALSE, recursive = TRUE)

## ---- Load ----
rom_panel <- readRDS(file.path(DATA, "rom_panel.rds"))
analysis_excl <- readRDS(file.path(DATA, "analysis_exclusions.rds"))
all_excl <- readRDS(file.path(DATA, "all_matched_exclusions.rds"))
absorption <- readRDS(file.path(DATA, "absorption_rates.rds"))
ri_results <- readRDS(file.path(DATA, "randomization_inference.rds"))
es_models <- readRDS(file.path(DATA, "event_study_models.rds"))

rom_panel[rom_paid < 0, rom_paid := 0]
rom_panel[, ln_rom_paid := log(rom_paid + 1)]

cat("=== Generating Figures ===\n")

## ====================================================================
## Figure 1: Event Study — ROM Spending (state × month FE)
## ====================================================================
cat("Figure 1: Event study\n")

# Use the state × month FE model (paid_sm) — the preferred specification.
# The basic FE model (paid) has near-singular VCOV producing enormous SEs
# due to collinearity between event-time dummies and month FE with few units.
es_mod <- es_models$paid_sm
coef_names <- names(coef(es_mod))
et_idx <- grep("event_time_c", coef_names)

es_dt <- data.table(
  event_time = as.numeric(gsub(".*::", "", coef_names[et_idx])),
  estimate = coef(es_mod)[et_idx],
  se = se(es_mod)[et_idx]
)
es_dt[, ci_low := estimate - 1.96 * se]
es_dt[, ci_high := estimate + 1.96 * se]
es_dt <- es_dt[order(event_time)]

fig1 <- ggplot(es_dt, aes(x = event_time, y = estimate)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
  geom_vline(xintercept = -0.5, linetype = "dotted", color = "grey30") +
  geom_ribbon(aes(ymin = ci_low, ymax = ci_high), alpha = 0.2, fill = "#2166AC") +
  geom_line(color = "#2166AC", linewidth = 0.8) +
  geom_point(color = "#2166AC", size = 2) +
  labs(
    title = "Effect of Provider Exclusion on Rest-of-Market Medicaid Spending",
    subtitle = "Event study coefficients with 95% CIs, state × month FE + unit FE",
    x = "Months relative to exclusion",
    y = "Coefficient (log points)",
    caption = "Notes: Unit of analysis is ZIP×service-category×month. Standard errors clustered at unit level.\n22 treated units across 16 ZIPs and 10 states. Reference period: k = -1."
  ) +
  coord_cartesian(xlim = c(-18, 18)) +
  theme_apep()

ggsave(file.path(FIGS, "fig1_event_study.pdf"), fig1, width = 10, height = 6.5)

## ====================================================================
## Figure 2: Market Share Distribution
## ====================================================================
cat("Figure 2: Market share distribution\n")

fig2 <- ggplot(all_excl, aes(x = market_share * 100)) +
  geom_histogram(bins = 30, fill = "#2166AC", alpha = 0.7, color = "white") +
  geom_vline(xintercept = 3, linetype = "dashed", color = "#B2182B", linewidth = 0.8) +
  geom_vline(xintercept = 5, linetype = "dashed", color = "#D6604D", linewidth = 0.8) +
  annotate("text", x = 4, y = Inf, vjust = 2, label = "3%", color = "#B2182B", size = 3.5) +
  annotate("text", x = 6, y = Inf, vjust = 2, label = "5%", color = "#D6604D", size = 3.5) +
  scale_x_continuous(labels = function(x) paste0(x, "%")) +
  labs(
    title = "Distribution of Excluded Providers' Service-Level Market Shares",
    subtitle = "Pre-exclusion spending share within ZIP × service category",
    x = "Market share (%)",
    y = "Count",
    caption = "Notes: Market share = excluded provider's service spending / total ZIP-service spending in prior year."
  ) +
  theme_apep()

ggsave(file.path(FIGS, "fig2_market_share.pdf"), fig2, width = 9, height = 6)

## ====================================================================
## Figure 3: Spending Trajectory
## ====================================================================
cat("Figure 3: Spending trajectory\n")

traj <- rom_panel[event_time >= -18 & event_time <= 18, .(
  mean_rom = mean(rom_paid, na.rm = TRUE),
  mean_total = mean(total_paid_all, na.rm = TRUE)
), by = event_time]

pre_rom <- traj[event_time >= -12 & event_time < 0, mean(mean_rom)]
pre_total <- traj[event_time >= -12 & event_time < 0, mean(mean_total)]

traj[, rom_idx := mean_rom / pre_rom * 100]
traj[, total_idx := mean_total / pre_total * 100]

traj_long <- melt(traj, id.vars = "event_time",
                  measure.vars = c("rom_idx", "total_idx"),
                  variable.name = "measure", value.name = "index")
traj_long[, measure := fifelse(measure == "rom_idx",
                               "Rest of Market", "Total (incl. excluded)")]

fig3 <- ggplot(traj_long, aes(x = event_time, y = index, color = measure)) +
  geom_hline(yintercept = 100, linetype = "dashed", color = "grey50") +
  geom_vline(xintercept = -0.5, linetype = "dotted", color = "grey30") +
  geom_line(linewidth = 0.9) +
  geom_point(size = 1.8) +
  scale_color_manual(values = c("Rest of Market" = "#2166AC",
                                "Total (incl. excluded)" = "#B2182B")) +
  labs(
    title = "Medicaid Spending Trajectory Around Provider Exclusion",
    subtitle = "Indexed to pre-exclusion mean (= 100)",
    x = "Months relative to exclusion",
    y = "Spending index",
    color = NULL,
    caption = "Notes: Mean across all treated ZIP×service units. Total includes excluded provider."
  ) +
  theme_apep()

ggsave(file.path(FIGS, "fig3_spending_trajectory.pdf"), fig3, width = 10, height = 6)

## ====================================================================
## Figure 4: Randomization Inference
## ====================================================================
cat("Figure 4: Randomization inference\n")

ri_dt <- data.table(coef = ri_results$perm_coefs)
ri_dt <- ri_dt[is.finite(coef)]

fig4 <- ggplot(ri_dt, aes(x = coef)) +
  geom_histogram(bins = 40, fill = "grey70", color = "white") +
  geom_vline(xintercept = ri_results$true_coef, color = "#B2182B", linewidth = 1.2) +
  annotate("text", x = ri_results$true_coef, y = Inf, vjust = 2,
           label = sprintf("True estimate\n(RI p = %.3f)", ri_results$ri_pvalue),
           color = "#B2182B", size = 3.5, hjust = -0.1) +
  labs(
    title = "Randomization Inference: Permutation Distribution",
    subtitle = sprintf("%d permutations of exclusion timing", sum(is.finite(ri_results$perm_coefs))),
    x = "Placebo coefficient",
    y = "Count",
    caption = "Notes: Distribution of coefficients from randomly permuting treatment timing across units."
  ) +
  theme_apep()

ggsave(file.path(FIGS, "fig4_ri.pdf"), fig4, width = 9, height = 6)

## ====================================================================
## Figure 5: Exclusion Events by Year and Category
## ====================================================================
cat("Figure 5: Descriptive — exclusions by year\n")

leie <- readRDS(file.path(DATA, "leie_cleaned.rds"))
npi_geo <- readRDS(file.path(DATA, "npi_geography.rds"))

# All LEIE with valid NPI that matched T-MSIS
matched_npis <- unique(all_excl$npi)

desc_dt <- data.table(
  category = c("LEIE with NPI (2018-2024)",
               "Matched to T-MSIS",
               "≥3 months pre-billing",
               "≥3% market share",
               "Analysis sample"),
  count = c(
    uniqueN(leie$npi),
    length(matched_npis),
    nrow(all_excl),
    nrow(all_excl[market_share >= 0.03]),
    nrow(analysis_excl)
  )
)
desc_dt[, category := factor(category, levels = rev(category))]

fig5 <- ggplot(desc_dt, aes(x = count, y = category)) +
  geom_col(fill = "#2166AC", alpha = 0.8, width = 0.6) +
  geom_text(aes(label = format(count, big.mark = ",")), hjust = -0.1, size = 3.5) +
  scale_x_continuous(expand = expansion(mult = c(0, 0.3))) +
  labs(
    title = "Sample Construction: From LEIE Exclusions to Analysis Sample",
    subtitle = "Sequential filtering of OIG exclusion events",
    x = "Number of excluded providers / provider-service pairs",
    y = NULL,
    caption = "Notes: Each bar shows the count remaining after applying the indicated filter."
  ) +
  theme_apep() +
  theme(panel.grid.major.y = element_blank())

ggsave(file.path(FIGS, "fig5_sample_funnel.pdf"), fig5, width = 10, height = 5.5)

## ====================================================================
## Figure 6: Absorption Rate Distribution
## ====================================================================
cat("Figure 6: Absorption rates\n")

abs_clean <- absorption[is.finite(absorb_12m)]

fig6 <- ggplot(abs_clean, aes(x = absorb_12m * 100)) +
  geom_histogram(bins = 15, fill = "#2166AC", alpha = 0.7, color = "white") +
  geom_vline(xintercept = 0, linetype = "dashed", color = "grey30") +
  geom_vline(xintercept = 100, linetype = "dotted", color = "#B2182B") +
  annotate("text", x = 105, y = Inf, vjust = 2, label = "Full\nabsorption",
           color = "#B2182B", size = 3) +
  scale_x_continuous(labels = function(x) paste0(x, "%")) +
  labs(
    title = "Distribution of 12-Month Absorption Rates",
    subtitle = "Rest-of-market spending change / excluded provider's baseline",
    x = "Absorption rate (%)",
    y = "Count",
    caption = "Notes: Positive values indicate the rest of market expanded to absorb displaced volume.\nValues > 100% indicate more-than-complete absorption."
  ) +
  theme_apep()

ggsave(file.path(FIGS, "fig6_absorption.pdf"), fig6, width = 9, height = 6)

cat("\n=== All figures generated ===\n")
