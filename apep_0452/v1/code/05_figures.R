## 05_figures.R — All figure generation
## apep_0452: Mercury regulation and ASGM in Africa

source("00_packages.R")
load(file.path(data_dir, "clean_panel.RData"))
load(file.path(data_dir, "analysis_results.RData"))
load(file.path(data_dir, "robustness_results.RData"))

# ============================================================
# FIGURE 1: Mercury imports to Africa over time
# ============================================================

cat("--- Figure 1: Mercury import trends ---\n")

fig1_data <- panel %>%
  filter(year >= 2000, year <= 2023) %>%
  group_by(year) %>%
  summarise(
    total_hg = sum(hg_import_value, na.rm = TRUE) / 1000,
    n_importers = sum(hg_import_value > 0),
    .groups = "drop"
  )

p1 <- ggplot(fig1_data, aes(x = year, y = total_hg)) +
  geom_line(linewidth = 1, color = apep_colors["treated"]) +
  geom_point(size = 2, color = apep_colors["treated"]) +
  geom_vline(xintercept = 2011, linetype = "dashed", color = "grey40") +
  geom_vline(xintercept = 2017, linetype = "dotted", color = apep_colors["neutral"]) +
  annotate("text", x = 2011.3, y = max(fig1_data$total_hg) * 0.95,
           label = "EU Ban", hjust = 0, size = 3, color = "grey40") +
  annotate("text", x = 2017.3, y = max(fig1_data$total_hg) * 0.85,
           label = "Minamata\nin force", hjust = 0, size = 3,
           color = apep_colors["neutral"]) +
  labs(
    x = "Year",
    y = "Total mercury imports ($1,000s)",
    title = "Mercury Imports to Africa, 2000-2023",
    caption = "Source: UN Comtrade (HS 280540). Vertical lines: EU export ban (2011), Minamata entry into force (2017)."
  ) +
  scale_x_continuous(breaks = seq(2000, 2023, 4))

ggsave(file.path(fig_dir, "fig1_mercury_trends.pdf"), p1,
       width = 7, height = 4.5, device = pdf)

# ============================================================
# FIGURE 2: Mercury imports by ASGM intensity
# ============================================================

cat("--- Figure 2: Mercury by ASGM intensity ---\n")

fig2_data <- panel %>%
  filter(year >= 2005, year <= 2020) %>%
  mutate(asgm_group = case_when(
    asgm_level %in% c("very_high", "high") ~ "High ASGM",
    asgm_level %in% c("moderate") ~ "Moderate ASGM",
    TRUE ~ "Low/No ASGM"
  )) %>%
  group_by(year, asgm_group) %>%
  summarise(
    mean_hg = mean(hg_import_value, na.rm = TRUE) / 1000,
    .groups = "drop"
  )

p2 <- ggplot(fig2_data, aes(x = year, y = mean_hg, color = asgm_group)) +
  geom_line(linewidth = 0.8) +
  geom_point(size = 1.5) +
  geom_vline(xintercept = 2011, linetype = "dashed", color = "grey60") +
  labs(
    x = "Year", y = "Mean mercury imports ($1,000s)",
    color = NULL,
    title = "Mercury Imports by ASGM Prevalence",
    caption = "Source: UN Comtrade. Dashed line: EU export ban (March 2011)."
  ) +
  scale_color_manual(values = c("High ASGM" = apep_colors["treated"],
                                 "Moderate ASGM" = apep_colors["highlight"],
                                 "Low/No ASGM" = apep_colors["control"]))

ggsave(file.path(fig_dir, "fig2_mercury_by_asgm.pdf"), p2,
       width = 7, height = 4.5, device = pdf)

# ============================================================
# FIGURE 3: EU ban event study
# ============================================================

cat("--- Figure 3: EU ban event study ---\n")

# Extract event study coefficients
if (!is.null(results$eu_event)) {
  es_coefs <- broom::tidy(results$eu_event, conf.int = TRUE) %>%
    filter(grepl("event_time_fac", term)) %>%
    mutate(
      event_time = as.integer(gsub(".*::|event_time_fac", "", term)),
      # Parse interaction terms
      event_time = suppressWarnings(as.integer(str_extract(term, "-?\\d+")))
    ) %>%
    filter(!is.na(event_time))

  if (nrow(es_coefs) > 0) {
    # Add reference period
    es_coefs <- bind_rows(
      es_coefs,
      tibble(event_time = -1, estimate = 0, conf.low = 0, conf.high = 0)
    ) %>%
      arrange(event_time)

    p3 <- ggplot(es_coefs, aes(x = event_time, y = estimate)) +
      geom_hline(yintercept = 0, color = "grey60") +
      geom_vline(xintercept = -0.5, linetype = "dashed", color = "grey60") +
      geom_ribbon(aes(ymin = conf.low, ymax = conf.high),
                  alpha = 0.2, fill = apep_colors["treated"]) +
      geom_line(color = apep_colors["treated"], linewidth = 0.8) +
      geom_point(color = apep_colors["treated"], size = 2) +
      labs(
        x = "Years relative to EU ban (2011)",
        y = "Coefficient (EU share interaction)",
        title = "Event Study: EU Mercury Export Ban",
        caption = "Coefficients from interaction of EU import share with year dummies. Reference: t = -1."
      ) +
      scale_x_continuous(breaks = seq(-6, 9, 2))

    ggsave(file.path(fig_dir, "fig3_eu_event_study.pdf"), p3,
           width = 7, height = 4.5, device = pdf)
  }
}

# ============================================================
# FIGURE 4: Minamata event study (CS-DiD)
# ============================================================

cat("--- Figure 4: Minamata CS-DiD event study ---\n")

if (!is.null(results$cs_event_study)) {
  es_cs <- results$cs_event_study

  es_df <- tibble(
    event_time = es_cs$egt,
    att = es_cs$att.egt,
    se = es_cs$se.egt,
    ci_lower = att - 1.96 * se,
    ci_upper = att + 1.96 * se
  ) %>%
    filter(event_time >= -8, event_time <= 8)

  p4 <- ggplot(es_df, aes(x = event_time, y = att)) +
    geom_hline(yintercept = 0, color = "grey60") +
    geom_vline(xintercept = -0.5, linetype = "dashed", color = "grey60") +
    geom_ribbon(aes(ymin = ci_lower, ymax = ci_upper),
                alpha = 0.2, fill = apep_colors["neutral"]) +
    geom_line(color = apep_colors["neutral"], linewidth = 0.8) +
    geom_point(color = apep_colors["neutral"], size = 2) +
    labs(
      x = "Years relative to Minamata ratification",
      y = "ATT (log mercury imports)",
      title = "Event Study: Minamata Convention Ratification",
      caption = "Callaway-Sant'Anna DR-DiD. 95% pointwise confidence intervals. Never-treated control group."
    ) +
    scale_x_continuous(breaks = seq(-8, 8, 2))

  ggsave(file.path(fig_dir, "fig4_minamata_event_study.pdf"), p4,
         width = 7, height = 4.5, device = pdf)
}

# ============================================================
# FIGURE 5: Trade partner reallocation
# ============================================================

cat("--- Figure 5: Trade partner reallocation ---\n")

if (!is.null(results$partner_shares) && nrow(results$partner_shares) > 0) {
  shares_plot <- results$partner_shares %>%
    filter(partner_region %in% c("EU", "Turkey", "UAE", "India", "China/HK",
                                  "Africa (intra)", "Other")) %>%
    mutate(partner_region = factor(partner_region,
                                   levels = c("EU", "China/HK", "Turkey", "UAE",
                                              "India", "Africa (intra)", "Other")))

  p5 <- ggplot(shares_plot, aes(x = year, y = total_value / 1000,
                                 fill = partner_region)) +
    geom_area(position = "stack", alpha = 0.8) +
    geom_vline(xintercept = 2011, linetype = "dashed", color = "white") +
    labs(
      x = "Year",
      y = "Mercury imports ($1,000s)",
      fill = "Source region",
      title = "Mercury Import Sources for Africa",
      caption = "Source: UN Comtrade bilateral trade data. Dashed line: EU export ban (2011)."
    ) +
    scale_fill_manual(values = c(
      "EU" = "#264653", "China/HK" = "#E76F51",
      "Turkey" = "#F4A261", "UAE" = "#E9C46A",
      "India" = "#2A9D8F", "Africa (intra)" = "#606C38",
      "Other" = "#CCD5AE"
    ))

  ggsave(file.path(fig_dir, "fig5_trade_reallocation.pdf"), p5,
         width = 7, height = 4.5, device = pdf)
}

# ============================================================
# FIGURE 6: Leave-one-out robustness
# ============================================================

cat("--- Figure 6: Leave-one-out ---\n")

if (!is.null(rob$loo) && nrow(rob$loo) > 0) {
  base_coef <- coef(results$eu_ban$m1a)["eu_ban_treat"]

  p6 <- ggplot(rob$loo, aes(x = reorder(excluded, coef), y = coef)) +
    geom_hline(yintercept = base_coef, color = apep_colors["treated"],
               linetype = "dashed") +
    geom_hline(yintercept = 0, color = "grey60") +
    geom_point(color = apep_colors["control"], size = 2) +
    geom_errorbar(aes(ymin = coef - 1.96 * se, ymax = coef + 1.96 * se),
                  width = 0, color = apep_colors["control"], alpha = 0.5) +
    coord_flip() +
    labs(
      x = "Excluded country",
      y = "EU ban coefficient",
      title = "Leave-One-Out Sensitivity",
      caption = "Each point excludes one country. Dashed line: baseline estimate."
    )

  ggsave(file.path(fig_dir, "fig6_leave_one_out.pdf"), p6,
         width = 7, height = 6, device = pdf)
}

# ============================================================
# FIGURE 7: Minamata ratification map (timeline)
# ============================================================

cat("--- Figure 7: Ratification timeline ---\n")

ratif_timeline <- minamata_ratification %>%
  count(ratification_year, name = "n_ratifiers") %>%
  mutate(cumulative = cumsum(n_ratifiers))

p7 <- ggplot(ratif_timeline, aes(x = ratification_year)) +
  geom_col(aes(y = n_ratifiers), fill = apep_colors["neutral"], alpha = 0.5) +
  geom_line(aes(y = cumulative), color = apep_colors["treated"],
            linewidth = 1) +
  geom_point(aes(y = cumulative), color = apep_colors["treated"], size = 2) +
  geom_vline(xintercept = 2017, linetype = "dotted", color = "grey50") +
  annotate("text", x = 2017.2, y = max(ratif_timeline$cumulative) * 0.5,
           label = "Entry into force", hjust = 0, size = 3) +
  labs(
    x = "Year",
    y = "Number of African countries",
    title = "Minamata Convention Ratification in Africa",
    caption = "Bars: new ratifiers per year. Line: cumulative total."
  ) +
  scale_x_continuous(breaks = 2014:2024) +
  scale_y_continuous(sec.axis = sec_axis(~., name = "Cumulative ratifiers"))

ggsave(file.path(fig_dir, "fig7_ratification_timeline.pdf"), p7,
       width = 7, height = 4.5, device = pdf)

cat("All figures saved.\n")
