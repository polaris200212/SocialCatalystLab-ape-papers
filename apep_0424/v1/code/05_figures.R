## ============================================================================
## 05_figures.R -- Generate all figures
## ============================================================================

source("00_packages.R")
DATA <- "../data"
FIGS <- "../figures"
dir.create(FIGS, showWarnings = FALSE)

panel_bh <- readRDS(file.path(DATA, "panel_bh.rds"))
parity_dates <- readRDS(file.path(DATA, "parity_dates.rds"))
cs_results <- readRDS(file.path(DATA, "cs_results.rds"))

## --------------------------------------------------------------------------
## Figure 1: Treatment Rollout Timeline
## --------------------------------------------------------------------------

rollout <- parity_dates[order(parity_date)]
rollout[, cumulative := 1:.N]

fig1 <- ggplot(rollout, aes(x = parity_date, y = cumulative)) +
  geom_step(color = apep_colors[1], linewidth = 1) +
  geom_point(color = apep_colors[1], size = 2) +
  geom_vline(xintercept = as.Date("2020-03-13"), linetype = "dashed",
             color = "grey40", linewidth = 0.5) +
  annotate("text", x = as.Date("2020-03-13"), y = 24,
           label = "COVID PHE\nDeclared", hjust = -0.1, size = 3, color = "grey40") +
  labs(title = "Cumulative Adoption of Telehealth Payment Parity Laws",
       subtitle = "Permanent state laws requiring Medicaid payment parity for telehealth",
       x = "", y = "Number of States with Parity Law",
       caption = "Source: CCHPCA, NCSL, state legislative records.") +
  theme_apep() +
  scale_y_continuous(breaks = seq(0, 30, 5)) +
  scale_x_date(date_breaks = "1 year", date_labels = "%Y")

ggsave(file.path(FIGS, "fig1_rollout.pdf"), fig1, width = 8, height = 5)
cat("Figure 1 saved.\n")

## --------------------------------------------------------------------------
## Figure 2: Parallel Trends by Treatment Cohort
## --------------------------------------------------------------------------

panel_bh[, cohort_group := fcase(
  first_treat_q == 0, "Never Treated",
  first_treat_q <= 9, "Early (2020)",
  first_treat_q <= 16, "Main Wave (2021)",
  default = "Late (2022-23)"
)]

trends <- panel_bh[, .(
  mean_lnprov = mean(ln_providers),
  se = sd(ln_providers) / sqrt(.N)
), by = .(cohort_group, year, quarter)]
trends[, date := as.Date(paste0(year, "-", (quarter - 1) * 3 + 1, "-01"))]

fig2 <- ggplot(trends, aes(x = date, y = mean_lnprov,
                             color = cohort_group, group = cohort_group)) +
  geom_line(linewidth = 0.8) +
  geom_point(size = 2) +
  geom_vline(xintercept = as.Date("2021-07-01"), linetype = "dashed",
             color = "grey40", linewidth = 0.5) +
  annotate("text", x = as.Date("2021-07-01"), y = Inf, label = "Main Wave\n(Jul 2021)",
           vjust = 1.5, hjust = 0.5, size = 3, color = "grey40", fontface = "italic") +
  scale_color_manual(values = c("Never Treated" = apep_colors[2],
                                 "Early (2020)" = apep_colors[1],
                                 "Main Wave (2021)" = apep_colors[3],
                                 "Late (2022-23)" = apep_colors[4]), name = "") +
  labs(title = "Behavioral Health Provider Supply by Treatment Cohort",
       subtitle = "Mean ln(unique billing NPIs) per state-quarter",
       x = "", y = "ln(Providers + 1)",
       caption = "Source: T-MSIS 2018--2024, NPPES.") +
  theme_apep() +
  scale_x_date(date_breaks = "1 year", date_labels = "%Y")

ggsave(file.path(FIGS, "fig2_parallel_trends.pdf"), fig2, width = 9, height = 5.5)
cat("Figure 2 saved.\n")

## --------------------------------------------------------------------------
## Figure 3: Event Study -- CS Provider Supply
## --------------------------------------------------------------------------

es <- cs_results$es_prov
es_dt <- data.table(time = es$egt, att = es$att.egt, se = es$se.egt)
es_dt[, `:=`(ci_lo = att - 1.96 * se, ci_hi = att + 1.96 * se)]

fig3 <- ggplot(es_dt, aes(x = time, y = att)) +
  geom_ribbon(aes(ymin = ci_lo, ymax = ci_hi), alpha = 0.2, fill = apep_colors[1]) +
  geom_point(color = apep_colors[1], size = 2.5) +
  geom_line(color = apep_colors[1], linewidth = 0.7) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
  geom_vline(xintercept = -0.5, linetype = "dotted", color = "grey60") +
  labs(title = "Effect of Telehealth Parity on Behavioral Health Provider Supply",
       subtitle = "Callaway-Sant'Anna estimator, 95% confidence intervals",
       x = "Quarters Relative to Parity Law Adoption",
       y = "ATT: ln(Providers)",
       caption = "Note: Reference period is t = -1. Never-treated states as comparison group.") +
  theme_apep() +
  scale_x_continuous(breaks = seq(-8, 8, 2))

ggsave(file.path(FIGS, "fig3_event_study_providers.pdf"), fig3, width = 8, height = 5)
cat("Figure 3 saved.\n")

## --------------------------------------------------------------------------
## Figure 4: Event Study -- Beneficiaries
## --------------------------------------------------------------------------

es_b <- cs_results$es_benef
es_b_dt <- data.table(time = es_b$egt, att = es_b$att.egt, se = es_b$se.egt)
es_b_dt[, `:=`(ci_lo = att - 1.96 * se, ci_hi = att + 1.96 * se)]

fig4 <- ggplot(es_b_dt, aes(x = time, y = att)) +
  geom_ribbon(aes(ymin = ci_lo, ymax = ci_hi), alpha = 0.2, fill = apep_colors[3]) +
  geom_point(color = apep_colors[3], size = 2.5) +
  geom_line(color = apep_colors[3], linewidth = 0.7) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
  geom_vline(xintercept = -0.5, linetype = "dotted", color = "grey60") +
  labs(title = "Effect of Telehealth Parity on Behavioral Health Beneficiaries",
       subtitle = "Callaway-Sant'Anna estimator, 95% confidence intervals",
       x = "Quarters Relative to Parity Law Adoption",
       y = "ATT: ln(Beneficiaries)",
       caption = "Note: Reference period is t = -1. Never-treated states as comparison group.") +
  theme_apep() +
  scale_x_continuous(breaks = seq(-8, 8, 2))

ggsave(file.path(FIGS, "fig4_event_study_beneficiaries.pdf"), fig4, width = 8, height = 5)
cat("Figure 4 saved.\n")

## --------------------------------------------------------------------------
## Figure 5: Placebo Comparison -- BH vs Personal Care
## --------------------------------------------------------------------------

if (file.exists(file.path(DATA, "placebo_pc_results.rds"))) {
  pc_res <- readRDS(file.path(DATA, "placebo_pc_results.rds"))
  es_pc <- pc_res$es_pc
  es_pc_dt <- data.table(time = es_pc$egt, att = es_pc$att.egt,
                          se = es_pc$se.egt, service = "Personal Care (Placebo)")
  es_bh_dt <- data.table(time = es$egt, att = es$att.egt,
                           se = es$se.egt, service = "Behavioral Health")

  es_comb <- rbind(es_bh_dt, es_pc_dt)
  es_comb[, `:=`(ci_lo = att - 1.96 * se, ci_hi = att + 1.96 * se)]

  fig5 <- ggplot(es_comb, aes(x = time, y = att, color = service, fill = service)) +
    geom_ribbon(aes(ymin = ci_lo, ymax = ci_hi), alpha = 0.15, color = NA) +
    geom_point(size = 2.5) +
    geom_line(linewidth = 0.7) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
    geom_vline(xintercept = -0.5, linetype = "dotted", color = "grey60") +
    scale_color_manual(values = c("Behavioral Health" = apep_colors[1],
                                   "Personal Care (Placebo)" = apep_colors[2]), name = "") +
    scale_fill_manual(values = c("Behavioral Health" = apep_colors[1],
                                  "Personal Care (Placebo)" = apep_colors[2]), name = "") +
    labs(title = "Treatment vs. Placebo: Provider Supply Event Studies",
         subtitle = "Behavioral health (telehealth-eligible) vs personal care (not telehealth-eligible)",
         x = "Quarters Relative to Parity Law Adoption", y = "ATT: ln(Providers)",
         caption = "Note: Personal care services cannot be delivered via telehealth.") +
    theme_apep() +
    scale_x_continuous(breaks = seq(-8, 8, 2))

  ggsave(file.path(FIGS, "fig5_placebo_comparison.pdf"), fig5, width = 9, height = 5.5)
  cat("Figure 5 saved.\n")
}

## --------------------------------------------------------------------------
## Figure 6: Leave-One-Out
## --------------------------------------------------------------------------

if (file.exists(file.path(DATA, "loo_results.rds"))) {
  loo_dt <- readRDS(file.path(DATA, "loo_results.rds"))
  full_coef <- coef(readRDS(file.path(DATA, "twfe_results.rds"))$twfe_prov)["post"]

  fig6 <- ggplot(loo_dt, aes(x = reorder(dropped, coef), y = coef)) +
    geom_point(color = apep_colors[1], size = 2.5) +
    geom_errorbar(aes(ymin = coef - 1.96 * se, ymax = coef + 1.96 * se),
                  width = 0.3, color = apep_colors[1]) +
    geom_hline(yintercept = full_coef, linetype = "dashed", color = apep_colors[2]) +
    geom_hline(yintercept = 0, linetype = "solid", color = "grey60") +
    coord_flip() +
    labs(title = "Leave-One-Out Sensitivity",
         subtitle = "Dashed orange = full-sample TWFE estimate",
         x = "Dropped State", y = "TWFE Coefficient",
         caption = "Error bars: 95% CI. Stability across dropped states validates robustness.") +
    theme_apep()

  ggsave(file.path(FIGS, "fig6_loo.pdf"), fig6, width = 8, height = 7)
  cat("Figure 6 saved.\n")
}

## --------------------------------------------------------------------------
## Figure 7: Bacon Decomposition
## --------------------------------------------------------------------------

if (file.exists(file.path(DATA, "bacon_decomp.rds"))) {
  bacon <- readRDS(file.path(DATA, "bacon_decomp.rds"))

  fig7 <- ggplot(bacon, aes(x = weight, y = estimate, color = type)) +
    geom_point(size = 3, alpha = 0.7) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
    scale_color_manual(values = apep_colors[1:3], name = "Comparison Type") +
    labs(title = "Goodman-Bacon Decomposition of TWFE Estimate",
         subtitle = "Each point is a 2x2 DiD; horizontal position reflects weight",
         x = "Weight", y = "2x2 DiD Estimate",
         caption = "Source: Goodman-Bacon (2021).") +
    theme_apep()

  ggsave(file.path(FIGS, "fig7_bacon.pdf"), fig7, width = 8, height = 5.5)
  cat("Figure 7 saved.\n")
}

## --------------------------------------------------------------------------
## Figure 8: Adoption Map (text-based, no sf)
## --------------------------------------------------------------------------

state_status <- data.table(state = c(state.abb, "DC"))
state_status <- merge(state_status, parity_dates[, .(state, parity_year)],
                      by = "state", all.x = TRUE)
state_status[, status := fcase(
  !is.na(parity_year) & parity_year == 2020, "2020",
  !is.na(parity_year) & parity_year == 2021, "2021",
  !is.na(parity_year) & parity_year == 2022, "2022",
  !is.na(parity_year) & parity_year >= 2023, "2023+",
  default = "No Parity"
)]
state_status[, status := factor(status, levels = c("2020","2021","2022","2023+","No Parity"))]

# Use usmap-style coordinates (approximate state positions)
state_pos <- fread(text = "
state,col,row
AL,7,6
AK,1,7
AZ,2,5
AR,5,5
CA,1,4
CO,3,4
CT,10,3
DE,9,4
DC,9,4
FL,8,7
GA,8,6
HI,1,8
ID,2,2
IL,6,3
IN,6,3
IA,5,3
KS,4,4
KY,7,4
LA,5,6
ME,11,1
MD,9,4
MA,10,2
MI,7,2
MN,5,2
MS,6,6
MO,5,4
MT,3,1
NE,4,3
NV,1,3
NH,10,1
NJ,9,3
NM,3,5
NY,9,2
NC,8,5
ND,4,1
OH,7,3
OK,4,5
OR,1,2
PA,8,3
RI,11,3
SC,8,5
SD,4,2
TN,7,5
TX,4,6
UT,2,4
VT,10,1
VA,8,4
WA,1,1
WV,8,4
WI,6,2
WY,3,3
")

state_map <- merge(state_pos, state_status, by = "state", all.x = TRUE)

fig8 <- ggplot(state_map, aes(x = col, y = -row, fill = status, label = state)) +
  geom_tile(color = "white", linewidth = 0.5) +
  geom_text(size = 2.5, color = "white", fontface = "bold") +
  scale_fill_manual(values = c("2020" = apep_colors[1], "2021" = apep_colors[2],
                                "2022" = apep_colors[3], "2023+" = apep_colors[4],
                                "No Parity" = "grey80"),
                    name = "Adoption Year", na.value = "grey90") +
  labs(title = "State Adoption of Medicaid Telehealth Payment Parity",
       caption = "Source: CCHPCA, NCSL, state legislative records.") +
  theme_void() +
  theme(legend.position = "bottom",
        plot.title = element_text(size = 13, face = "bold", hjust = 0.5))

ggsave(file.path(FIGS, "fig8_adoption_map.pdf"), fig8, width = 9, height = 6)
cat("Figure 8 saved.\n")

cat("\n=== All figures generated ===\n")
