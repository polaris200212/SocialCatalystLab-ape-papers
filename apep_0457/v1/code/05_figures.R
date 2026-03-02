##############################################################################
# 05_figures.R — All figures for the paper
# APEP-0457: The Lex Weber Shock
##############################################################################

source("00_packages.R")
load(file.path(data_dir, "main_results.RData"))
load(file.path(data_dir, "robustness_results.RData"))

# ══════════════════════════════════════════════════════════════════════════════
# Figure 1: Map of Second Home Shares (Treatment Geography)
# ══════════════════════════════════════════════════════════════════════════════
cat("Figure 1: Treatment distribution\n")

zw <- read_csv(file.path(data_dir, "zweitwohnungsanteil_clean.csv"), show_col_types = FALSE)

p1 <- ggplot(zw, aes(x = share_secondhome)) +
  geom_histogram(aes(fill = factor(treated)),
                 binwidth = 2, boundary = 0, color = "white", linewidth = 0.2) +
  geom_vline(xintercept = 20, linetype = "dashed", color = "red", linewidth = 0.8) +
  scale_fill_manual(values = c("0" = apep_colors[1], "1" = apep_colors[2]),
                    labels = c("Control (≤20%)", "Treated (>20%)")) +
  labs(
    x = "Second Home Share (%)",
    y = "Number of Municipalities",
    fill = NULL,
    title = "Distribution of Second Home Shares Across Swiss Municipalities",
    subtitle = "Vertical line at 20% marks the Lex Weber treatment threshold"
  ) +
  theme_apep() +
  theme(legend.position = c(0.75, 0.8))

ggsave(file.path(fig_dir, "fig1_treatment_distribution.pdf"), p1,
       width = 8, height = 5)

# ══════════════════════════════════════════════════════════════════════════════
# Figure 2: Event Study — Total Employment
# ══════════════════════════════════════════════════════════════════════════════
cat("Figure 2: Event study — total employment\n")

es_coef <- broom::tidy(es_models$total, conf.int = TRUE) %>%
  filter(grepl("rel_year", term)) %>%
  mutate(
    rel_year = as.numeric(str_extract(term, "-?\\d+"))
  )

# Add the omitted category
es_coef <- bind_rows(
  es_coef,
  tibble(term = "ref", estimate = 0, std.error = 0,
         conf.low = 0, conf.high = 0, rel_year = -1)
) %>%
  arrange(rel_year)

p2 <- ggplot(es_coef, aes(x = rel_year, y = estimate)) +
  geom_hline(yintercept = 0, color = "grey50", linewidth = 0.3) +
  geom_vline(xintercept = -0.5, linetype = "dashed", color = "red", linewidth = 0.5) +
  geom_ribbon(aes(ymin = conf.low, ymax = conf.high), alpha = 0.2, fill = apep_colors[1]) +
  geom_point(color = apep_colors[1], size = 2.5) +
  geom_line(color = apep_colors[1], linewidth = 0.6) +
  labs(
    x = "Years Relative to Treatment (2016 = 0)",
    y = "Coefficient (Log Employment)",
    title = "Event Study: Effect of Lex Weber on Total Employment",
    subtitle = "Municipality and year fixed effects; 95% CI clustered at municipality level"
  ) +
  theme_apep() +
  annotate("text", x = -0.5, y = max(es_coef$conf.high, na.rm = TRUE) * 0.9,
           label = "Treatment\nonset", hjust = 1.1, size = 3, color = "red")

ggsave(file.path(fig_dir, "fig2_event_study_total.pdf"), p2,
       width = 8, height = 5)

# ══════════════════════════════════════════════════════════════════════════════
# Figure 3: Event Study — By Sector
# ══════════════════════════════════════════════════════════════════════════════
cat("Figure 3: Event study — by sector\n")

es_tertiary <- broom::tidy(es_models$tertiary, conf.int = TRUE) %>%
  filter(grepl("rel_year", term)) %>%
  mutate(rel_year = as.numeric(str_extract(term, "-?\\d+")),
         sector = "Tertiary (Services)")

es_constr <- broom::tidy(es_models$construction, conf.int = TRUE) %>%
  filter(grepl("rel_year", term)) %>%
  mutate(rel_year = as.numeric(str_extract(term, "-?\\d+")),
         sector = "New Dwelling Construction")

es_sectors <- bind_rows(es_tertiary, es_constr) %>%
  bind_rows(
    tibble(term = "ref", estimate = 0, std.error = 0,
           conf.low = 0, conf.high = 0, rel_year = -1,
           sector = c("Tertiary (Services)", "New Dwelling Construction"))
  ) %>%
  arrange(sector, rel_year)

p3 <- ggplot(es_sectors, aes(x = rel_year, y = estimate)) +
  geom_hline(yintercept = 0, color = "grey50", linewidth = 0.3) +
  geom_vline(xintercept = -0.5, linetype = "dashed", color = "red", linewidth = 0.5) +
  geom_ribbon(aes(ymin = conf.low, ymax = conf.high), alpha = 0.2, fill = apep_colors[1]) +
  geom_point(color = apep_colors[1], size = 2) +
  geom_line(color = apep_colors[1], linewidth = 0.6) +
  facet_wrap(~sector, ncol = 2, scales = "free_y") +
  labs(
    x = "Years Relative to Treatment (2016 = 0)",
    y = "Coefficient (Log Outcome)",
    title = "Event Study: Sectoral Effects of the Lex Weber Restriction",
    subtitle = "Municipality and year FE; 95% CI clustered at municipality level"
  ) +
  theme_apep()

ggsave(file.path(fig_dir, "fig3_event_study_sectors.pdf"), p3,
       width = 10, height = 5)

# ══════════════════════════════════════════════════════════════════════════════
# Figure 4: RDD Plot
# ══════════════════════════════════════════════════════════════════════════════
cat("Figure 4: RDD\n")

if (!is.null(rdd1)) {
  p4 <- ggplot(post_data, aes(x = running, y = mean_log_emp)) +
    geom_point(aes(color = factor(treated)), alpha = 0.3, size = 1.5) +
    geom_smooth(data = post_data %>% filter(running < 0),
                method = "loess", span = 0.8, se = TRUE,
                color = apep_colors[1], fill = apep_colors[1], alpha = 0.2) +
    geom_smooth(data = post_data %>% filter(running >= 0),
                method = "loess", span = 0.8, se = TRUE,
                color = apep_colors[2], fill = apep_colors[2], alpha = 0.2) +
    geom_vline(xintercept = 0, linetype = "dashed", color = "red", linewidth = 0.7) +
    scale_color_manual(values = c("0" = apep_colors[1], "1" = apep_colors[2]),
                       labels = c("Control (≤20%)", "Treated (>20%)")) +
    labs(
      x = "Second Home Share Relative to 20% Cutoff (pp)",
      y = "Mean Log Employment (Post-Treatment)",
      color = NULL,
      title = "Regression Discontinuity at the 20% Second Home Threshold",
      subtitle = "Local polynomial fit with 95% CI"
    ) +
    theme_apep() +
    coord_cartesian(xlim = c(-20, 40))

  ggsave(file.path(fig_dir, "fig4_rdd.pdf"), p4, width = 8, height = 5.5)
}

# ══════════════════════════════════════════════════════════════════════════════
# Figure 5: Randomization Inference Distribution
# ══════════════════════════════════════════════════════════════════════════════
cat("Figure 5: RI distribution\n")

ri_df <- tibble(estimate = perm_effects[!is.na(perm_effects)])

p5 <- ggplot(ri_df, aes(x = estimate)) +
  geom_histogram(bins = 50, fill = "grey70", color = "white") +
  geom_vline(xintercept = obs_effect, color = "red", linewidth = 1) +
  labs(
    x = "Placebo Treatment Effect",
    y = "Frequency",
    title = "Randomization Inference: Distribution of Placebo Effects",
    subtitle = paste0("Red line = observed effect. RI p-value = ", round(ri_pvalue, 3))
  ) +
  theme_apep()

ggsave(file.path(fig_dir, "fig5_ri_distribution.pdf"), p5,
       width = 7, height = 4.5)

# ══════════════════════════════════════════════════════════════════════════════
# Figure 6: Parallel Trends (Raw Means)
# ══════════════════════════════════════════════════════════════════════════════
cat("Figure 6: Parallel trends\n")

trends <- panel %>%
  group_by(year, treated) %>%
  summarise(
    mean_emp = mean(emp_total, na.rm = TRUE),
    se_emp = sd(emp_total, na.rm = TRUE) / sqrt(n()),
    mean_emp_tert = mean(emp_tertiary, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(group = ifelse(treated == 1, "Treated (>20%)", "Control (≤20%)"))

p6 <- ggplot(trends, aes(x = year, y = mean_emp, color = group)) +
  geom_vline(xintercept = 2015.5, linetype = "dashed", color = "grey50") +
  geom_line(linewidth = 0.8) +
  geom_point(size = 2) +
  scale_color_manual(values = c(apep_colors[1], apep_colors[2])) +
  labs(
    x = "Year",
    y = "Mean Total Employment",
    color = NULL,
    title = "Average Employment Trends by Treatment Status",
    subtitle = "Dashed line marks 2016 treatment onset"
  ) +
  theme_apep()

ggsave(file.path(fig_dir, "fig6_parallel_trends.pdf"), p6,
       width = 8, height = 5)

# ══════════════════════════════════════════════════════════════════════════════
# Figure 7: CS Event Study
# ══════════════════════════════════════════════════════════════════════════════
cat("Figure 7: CS event study\n")

if (exists("cs_es") && !is.null(cs_es)) {
  cs_es_df <- data.frame(
    rel_year = cs_es$egt,
    estimate = cs_es$att.egt,
    se = cs_es$se.egt
  ) %>%
    mutate(
      conf.low = estimate - 1.96 * se,
      conf.high = estimate + 1.96 * se
    )

  p7 <- ggplot(cs_es_df, aes(x = rel_year, y = estimate)) +
    geom_hline(yintercept = 0, color = "grey50", linewidth = 0.3) +
    geom_vline(xintercept = -0.5, linetype = "dashed", color = "red", linewidth = 0.5) +
    geom_ribbon(aes(ymin = conf.low, ymax = conf.high), alpha = 0.2, fill = apep_colors[3]) +
    geom_point(color = apep_colors[3], size = 2.5) +
    geom_line(color = apep_colors[3], linewidth = 0.6) +
    labs(
      x = "Years Relative to Treatment",
      y = "ATT (Log Total Employment)",
      title = "Callaway-Sant'Anna Event Study Estimates",
      subtitle = "Doubly robust estimator; 95% pointwise CI"
    ) +
    theme_apep()

  ggsave(file.path(fig_dir, "fig7_cs_event_study.pdf"), p7,
         width = 8, height = 5)
}

# ══════════════════════════════════════════════════════════════════════════════
# Figure 8: Dose-Response
# ══════════════════════════════════════════════════════════════════════════════
cat("Figure 8: Dose-response\n")

# Bin treated municipalities by second home share
dose_bins <- panel %>%
  filter(treated == 1) %>%
  mutate(sh_bin = cut(share_secondhome, breaks = c(20, 25, 30, 40, 50, 100),
                      labels = c("20-25%", "25-30%", "30-40%", "40-50%", ">50%"),
                      include.lowest = TRUE)) %>%
  filter(!is.na(sh_bin))

# Run separate DiD for each bin
dose_results <- list()
for (b in levels(dose_bins$sh_bin)) {
  bin_data <- panel %>%
    filter(treated == 0 | (treated == 1 & gem_no %in%
             (dose_bins %>% filter(sh_bin == b) %>% pull(gem_no) %>% unique())))
  m <- tryCatch(
    feols(log_emp_total ~ treat_post | gem_no + year, data = bin_data,
          cluster = ~gem_no),
    error = function(e) NULL
  )
  if (!is.null(m)) {
    dose_results[[b]] <- tibble(
      bin = b,
      estimate = coef(m)["treat_post"],
      se = se(m)["treat_post"],
      conf.low = estimate - 1.96 * se,
      conf.high = estimate + 1.96 * se,
      n_treated = n_distinct(filter(bin_data, treated == 1)$gem_no)
    )
  }
}

if (length(dose_results) > 0) {
  dose_df <- bind_rows(dose_results)

  p8 <- ggplot(dose_df, aes(x = bin, y = estimate)) +
    geom_hline(yintercept = 0, color = "grey50", linewidth = 0.3) +
    geom_pointrange(aes(ymin = conf.low, ymax = conf.high),
                    color = apep_colors[1], size = 0.8) +
    geom_text(aes(label = paste0("n=", n_treated)), vjust = -1.5, size = 3) +
    labs(
      x = "Second Home Share Category",
      y = "DiD Estimate (Log Total Employment)",
      title = "Dose-Response: Treatment Effect by Second Home Share Intensity",
      subtitle = "Each bin compared to full control group; 95% CI"
    ) +
    theme_apep()

  ggsave(file.path(fig_dir, "fig8_dose_response.pdf"), p8,
         width = 8, height = 5)
}

cat("\nAll figures saved to:", fig_dir, "\n")
list.files(fig_dir)
