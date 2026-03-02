## ============================================================
## 05_figures.R — All figure generation
## Paper: Does Sanitation Drive Development? (apep_0444)
## ============================================================

BASE_DIR <- file.path("output", "apep_0444", "v1")
source(file.path(BASE_DIR, "code", "00_packages.R"))

fig_dir <- file.path(BASE_DIR, "figures")
dir.create(fig_dir, showWarnings = FALSE, recursive = TRUE)

panel <- fread(file.path(BASE_DIR, "data", "district_panel.csv"))
panel[, dist_id := as.factor(dist_id)]

# ══════════════════════════════════════════════════════════════
# FIGURE 1: ODF Rollout Map / Timeline
# ══════════════════════════════════════════════════════════════

cat("Figure 1: ODF rollout timeline...\n")

odf <- fread(file.path(BASE_DIR, "data", "odf_dates.csv"))
state_names <- fread(file.path(BASE_DIR, "data", "state_names.csv"))
odf_named <- merge(odf, state_names, by = "pc11_state_id")

# Timeline bar chart
odf_named[, odf_date_dec := odf_year + (odf_month - 1) / 12]
odf_named <- odf_named[order(odf_date_dec)]
odf_named[, state_name := factor(state_name, levels = rev(state_name))]

p1 <- ggplot(odf_named, aes(x = odf_date_dec, y = state_name)) +
  geom_segment(aes(xend = 2014.75, yend = state_name),
               color = "grey80", linewidth = 0.3) +
  geom_point(aes(color = factor(odf_year)), size = 2.5) +
  geom_vline(xintercept = 2014.75, linetype = "dashed", color = "grey50") +
  scale_color_manual(
    values = c("2016" = "#1b9e77", "2017" = "#d95f02",
               "2018" = "#7570b3", "2019" = "#e7298a"),
    name = "ODF Year"
  ) +
  scale_x_continuous(breaks = 2015:2020, limits = c(2014.5, 2020)) +
  labs(
    x = "Year",
    y = NULL,
    title = "Staggered ODF Declarations Across Indian States",
    subtitle = "Dashed line: SBM-G launch (October 2014)"
  ) +
  theme_pub +
  theme(axis.text.y = element_text(size = 7))

ggsave(file.path(fig_dir, "fig1_odf_timeline.pdf"), p1,
       width = 7, height = 9, device = pdf)

# ══════════════════════════════════════════════════════════════
# FIGURE 2: Raw Nightlights Trends by Treatment Cohort
# ══════════════════════════════════════════════════════════════

cat("Figure 2: Raw nightlights trends by cohort...\n")

cohort_trends <- panel[, .(
  mean_nl = mean(log_nl, na.rm = TRUE),
  se_nl = sd(log_nl, na.rm = TRUE) / sqrt(.N)
), by = .(year, cohort)]

cohort_trends[, cohort_label := paste0("ODF ", cohort)]

p2 <- ggplot(cohort_trends, aes(x = year, y = mean_nl,
                                 color = factor(cohort),
                                 group = factor(cohort))) +
  geom_line(linewidth = 0.8) +
  geom_point(size = 1.5) +
  geom_ribbon(aes(ymin = mean_nl - 1.96 * se_nl,
                  ymax = mean_nl + 1.96 * se_nl,
                  fill = factor(cohort)),
              alpha = 0.15, color = NA) +
  geom_vline(aes(xintercept = cohort, color = factor(cohort)),
             linetype = "dashed", alpha = 0.5,
             data = data.table(cohort = c(2016, 2017, 2018, 2019))) +
  scale_color_manual(
    values = c("2016" = "#1b9e77", "2017" = "#d95f02",
               "2018" = "#7570b3", "2019" = "#e7298a"),
    name = "Treatment Cohort"
  ) +
  scale_fill_manual(
    values = c("2016" = "#1b9e77", "2017" = "#d95f02",
               "2018" = "#7570b3", "2019" = "#e7298a"),
    guide = "none"
  ) +
  scale_x_continuous(breaks = 2012:2023) +
  labs(
    x = "Year",
    y = "Mean Log Nightlights",
    title = "Nighttime Lights by ODF Declaration Cohort",
    subtitle = "Dashed vertical lines mark cohort treatment year"
  ) +
  theme_pub +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

ggsave(file.path(fig_dir, "fig2_raw_trends.pdf"), p2,
       width = 8, height = 5, device = pdf)

# ══════════════════════════════════════════════════════════════
# FIGURE 3: TWFE Event Study
# ══════════════════════════════════════════════════════════════

cat("Figure 3: TWFE event study...\n")

es_twfe <- readRDS(file.path(BASE_DIR, "data", "es_twfe.rds"))

# Extract coefficients
es_df <- as.data.table(coeftable(es_twfe))
es_df[, rel_time := as.integer(str_extract(rownames(coeftable(es_twfe)), "-?\\d+"))]
setnames(es_df, c("estimate", "se", "tval", "pval", "rel_time"))

# Add reference period
ref_row <- data.table(estimate = 0, se = 0, tval = 0, pval = 1, rel_time = -1L)
es_df <- rbind(es_df, ref_row)
es_df <- es_df[order(rel_time)]

p3 <- ggplot(es_df, aes(x = rel_time, y = estimate)) +
  geom_hline(yintercept = 0, linetype = "solid", color = "grey60") +
  geom_vline(xintercept = -0.5, linetype = "dashed", color = "red3", alpha = 0.5) +
  geom_ribbon(aes(ymin = estimate - 1.96 * se,
                  ymax = estimate + 1.96 * se),
              fill = "steelblue", alpha = 0.2) +
  geom_point(size = 2.5, color = "steelblue") +
  geom_errorbar(aes(ymin = estimate - 1.96 * se,
                    ymax = estimate + 1.96 * se),
                width = 0.2, color = "steelblue") +
  scale_x_continuous(breaks = -5:5) +
  labs(
    x = "Years Relative to ODF Declaration",
    y = "Estimated Effect on Log Nightlights",
    title = "Event Study: Effect of ODF Declaration on Nighttime Lights",
    subtitle = "TWFE specification with 95% confidence intervals"
  ) +
  theme_pub

ggsave(file.path(fig_dir, "fig3_event_study_twfe.pdf"), p3,
       width = 7, height = 5, device = pdf)

# ══════════════════════════════════════════════════════════════
# FIGURE 4: Callaway-Sant'Anna Event Study
# ══════════════════════════════════════════════════════════════

cat("Figure 4: CS-DiD event study...\n")

cs_es <- readRDS(file.path(BASE_DIR, "data", "cs_es.rds"))

cs_es_df <- data.table(
  rel_time = cs_es$egt,
  estimate = cs_es$att.egt,
  se = cs_es$se.egt
)

p4 <- ggplot(cs_es_df, aes(x = rel_time, y = estimate)) +
  geom_hline(yintercept = 0, linetype = "solid", color = "grey60") +
  geom_vline(xintercept = -0.5, linetype = "dashed", color = "red3", alpha = 0.5) +
  geom_ribbon(aes(ymin = estimate - 1.96 * se,
                  ymax = estimate + 1.96 * se),
              fill = "darkgreen", alpha = 0.2) +
  geom_point(size = 2.5, color = "darkgreen") +
  geom_errorbar(aes(ymin = estimate - 1.96 * se,
                    ymax = estimate + 1.96 * se),
                width = 0.2, color = "darkgreen") +
  scale_x_continuous(breaks = -5:5) +
  labs(
    x = "Years Relative to ODF Declaration",
    y = "ATT on Log Nightlights",
    title = "Callaway-Sant'Anna Event Study",
    subtitle = "Heterogeneity-robust DiD with not-yet-treated comparison"
  ) +
  theme_pub

ggsave(file.path(fig_dir, "fig4_event_study_cs.pdf"), p4,
       width = 7, height = 5, device = pdf)

# ══════════════════════════════════════════════════════════════
# FIGURE 5: Heterogeneity by Rural Share
# ══════════════════════════════════════════════════════════════

cat("Figure 5: Heterogeneity...\n")

panel[, high_rural := as.integer(rural_share >= median(rural_share, na.rm = TRUE))]

het_trends <- panel[, .(
  mean_nl = mean(log_nl, na.rm = TRUE)
), by = .(year, high_rural)]

het_trends[, rural_label := fifelse(high_rural == 1, "High Rural Share", "Low Rural Share")]

p5 <- ggplot(het_trends, aes(x = year, y = mean_nl,
                              color = rural_label, group = rural_label)) +
  geom_line(linewidth = 0.8) +
  geom_point(size = 1.5) +
  scale_color_manual(values = c("High Rural Share" = "#d95f02",
                                 "Low Rural Share" = "#1b9e77"),
                      name = NULL) +
  scale_x_continuous(breaks = 2012:2023) +
  labs(
    x = "Year",
    y = "Mean Log Nightlights",
    title = "Nightlights Trends by District Rural Share",
    subtitle = "SBM-Gramin targets rural areas; effects expected in high-rural districts"
  ) +
  theme_pub +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

ggsave(file.path(fig_dir, "fig5_heterogeneity_rural.pdf"), p5,
       width = 7, height = 5, device = pdf)

# ══════════════════════════════════════════════════════════════
# FIGURE 6: Randomization Inference Distribution
# ══════════════════════════════════════════════════════════════

cat("Figure 6: Randomization inference...\n")

rob <- readRDS(file.path(BASE_DIR, "data", "robustness_results.rds"))

ri_df <- data.table(coef = rob$ri_coefs)

p6 <- ggplot(ri_df, aes(x = coef)) +
  geom_histogram(bins = 40, fill = "grey70", color = "grey50") +
  geom_vline(xintercept = rob$actual_coef, color = "red3",
             linewidth = 1.2, linetype = "solid") +
  annotate("text", x = rob$actual_coef, y = Inf,
           label = paste0("Actual = ", round(rob$actual_coef, 4)),
           vjust = 2, hjust = -0.1, color = "red3", size = 3.5) +
  labs(
    x = "Placebo Coefficient",
    y = "Count",
    title = "Randomization Inference: Permuted Treatment Assignments",
    subtitle = paste0("500 permutations. RI p-value = ", round(rob$ri_pvalue, 3))
  ) +
  theme_pub

ggsave(file.path(fig_dir, "fig6_ri_distribution.pdf"), p6,
       width = 7, height = 5, device = pdf)

# ══════════════════════════════════════════════════════════════
# FIGURE A1: Cohort-Specific ATTs (Appendix)
# ══════════════════════════════════════════════════════════════

cat("Figure A1: Cohort ATTs...\n")

cs_cohort <- readRDS(file.path(BASE_DIR, "data", "cs_cohort.rds"))

cohort_df <- data.table(
  cohort = cs_cohort$egt,
  att = cs_cohort$att.egt,
  se = cs_cohort$se.egt
)

p_a1 <- ggplot(cohort_df, aes(x = factor(cohort), y = att)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey60") +
  geom_point(size = 3, color = "steelblue") +
  geom_errorbar(aes(ymin = att - 1.96 * se,
                    ymax = att + 1.96 * se),
                width = 0.2, color = "steelblue") +
  labs(
    x = "Treatment Cohort (ODF Year)",
    y = "Cohort-Specific ATT",
    title = "Treatment Effects by ODF Declaration Cohort"
  ) +
  theme_pub

ggsave(file.path(fig_dir, "figA1_cohort_atts.pdf"), p_a1,
       width = 6, height = 4.5, device = pdf)

cat("\nAll figures saved to:", fig_dir, "\n")
