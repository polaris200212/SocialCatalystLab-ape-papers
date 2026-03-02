# ============================================================================
# apep_0277: Indoor Smoking Bans and Social Norms
# 05_figures.R - Generate all figures
# ============================================================================

source(here::here("output", "apep_0277", "v1", "code", "00_packages.R"))

state_year <- readRDS(file.path(data_dir, "state_year_panel.rds"))
results <- readRDS(file.path(data_dir, "main_results.rds"))

if (file.exists(file.path(data_dir, "robustness_results.rds"))) {
  robust <- readRDS(file.path(data_dir, "robustness_results.rds"))
}

cat("=== Generating Figures ===\n")

# ============================================================================
# Figure 1: Smoking Ban Adoption Map / Timeline
# ============================================================================

cat("Figure 1: Treatment timing...\n")

ban_dates <- readRDS(file.path(data_dir, "smoking_ban_dates.rds"))

# Panel A: Timeline of adoption
p1a <- ban_dates %>%
  arrange(ban_year) %>%
  mutate(
    state_label = fct_reorder(state_abbr, ban_year),
    period = case_when(
      ban_year <= 2005 ~ "2002-2005",
      ban_year <= 2008 ~ "2006-2008",
      ban_year <= 2012 ~ "2009-2012",
      TRUE ~ "2013-2016"
    )
  ) %>%
  ggplot(aes(x = ban_year, y = state_label, color = period)) +
  geom_point(size = 2.5) +
  geom_segment(aes(xend = ban_year, y = state_label, yend = state_label),
               x = 1996, linewidth = 0.3, alpha = 0.3) +
  scale_color_manual(values = c("2002-2005" = "#1b9e77", "2006-2008" = "#d95f02",
                                  "2009-2012" = "#7570b3", "2013-2016" = "#e7298a")) +
  scale_x_continuous(breaks = seq(2002, 2016, 2)) +
  labs(x = "Year of Comprehensive Ban Adoption",
       y = NULL,
       color = "Adoption Period",
       title = "Panel A: Staggered Adoption of Indoor Smoking Bans") +
  theme(legend.position = "bottom",
        axis.text.y = element_text(size = 7))

ggsave(file.path(fig_dir, "fig1_adoption_timeline.pdf"), p1a,
       width = 7, height = 8)

# ============================================================================
# Figure 2: Raw Trends in Smoking Rate
# ============================================================================

cat("Figure 2: Raw trends...\n")

trends <- state_year %>%
  mutate(
    treat_group = case_when(
      first_treat == 0 ~ "Never Adopted",
      first_treat <= 2006 ~ "Early Adopters (2002-2006)",
      first_treat <= 2009 ~ "Middle Adopters (2007-2009)",
      TRUE ~ "Late Adopters (2010-2016)"
    )
  ) %>%
  group_by(year, treat_group) %>%
  summarise(
    smoking_rate = weighted.mean(smoking_rate, n_obs, na.rm = TRUE),
    .groups = "drop"
  )

# Insert NA rows for missing years so lines show gaps
missing_years <- c(2005, 2017, 2018, 2019, 2020)
gap_rows <- expand.grid(year = missing_years,
                          treat_group = unique(trends$treat_group),
                          stringsAsFactors = FALSE) %>%
  mutate(smoking_rate = NA_real_)
trends <- bind_rows(trends, gap_rows) %>% arrange(treat_group, year)

p2 <- ggplot(trends, aes(x = year, y = smoking_rate * 100,
                            color = treat_group, linetype = treat_group)) +
  geom_line(linewidth = 0.8) +
  geom_point(size = 1.5) +
  # Annotate missing data periods
  annotate("rect", xmin = 2004.5, xmax = 2005.5, ymin = -Inf, ymax = Inf,
           fill = "grey90", alpha = 0.5) +
  annotate("rect", xmin = 2016.5, xmax = 2020.5, ymin = -Inf, ymax = Inf,
           fill = "grey90", alpha = 0.5) +
  annotate("text", x = 2005, y = Inf, label = "No\ndata", vjust = 1.5,
           size = 2, color = "grey50") +
  annotate("text", x = 2018.5, y = Inf, label = "No data", vjust = 1.5,
           size = 2, color = "grey50") +
  scale_color_manual(values = c("Never Adopted" = "grey50",
                                  "Early Adopters (2002-2006)" = "#1b9e77",
                                  "Middle Adopters (2007-2009)" = "#d95f02",
                                  "Late Adopters (2010-2016)" = "#7570b3")) +
  scale_linetype_manual(values = c("Never Adopted" = "dashed",
                                     "Early Adopters (2002-2006)" = "solid",
                                     "Middle Adopters (2007-2009)" = "solid",
                                     "Late Adopters (2010-2016)" = "solid")) +
  scale_y_continuous(labels = function(x) paste0(x, "%")) +
  labs(x = "Year", y = "Current Smoking Rate (%)",
       color = NULL, linetype = NULL,
       title = "Current Smoking Prevalence by Treatment Cohort") +
  theme(legend.position = "bottom",
        legend.key.width = unit(1.5, "cm"))

ggsave(file.path(fig_dir, "fig2_raw_trends.pdf"), p2, width = 8, height = 5.5)

# ============================================================================
# Figure 3: Event Study - Smoking Rate
# ============================================================================

cat("Figure 3: Event study (smoking)...\n")

es_smoking <- results$es_smoking
es_data <- tibble(
  e = es_smoking$egt,
  att = es_smoking$att.egt,
  se = es_smoking$se.egt,
  ci_lo = att - 1.96 * se,
  ci_hi = att + 1.96 * se
)

p3 <- ggplot(es_data, aes(x = e, y = att * 100)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey60") +
  geom_vline(xintercept = -0.5, linetype = "dotted", color = "red", alpha = 0.5) +
  geom_ribbon(aes(ymin = ci_lo * 100, ymax = ci_hi * 100),
              fill = "#1b9e77", alpha = 0.2) +
  geom_line(color = "#1b9e77", linewidth = 0.6) +
  geom_point(color = "#1b9e77", size = 1.8) +
  labs(x = "Years Relative to Ban Adoption",
       y = "ATT on Current Smoking Rate (Percentage Points)",
       title = "Dynamic Treatment Effects: Current Smoking Prevalence") +
  annotate("text", x = -5, y = max(es_data$ci_hi * 100, na.rm = TRUE),
           label = "Pre-treatment", hjust = 0.5, color = "grey40", size = 3) +
  annotate("text", x = 5, y = min(es_data$ci_lo * 100, na.rm = TRUE),
           label = "Post-treatment", hjust = 0.5, color = "grey40", size = 3)

ggsave(file.path(fig_dir, "fig3_event_study_smoking.pdf"), p3, width = 8, height = 5)

# ============================================================================
# Figure 4: Event Study - Quit Attempts
# ============================================================================

cat("Figure 4: Event study (quit attempts)...\n")

es_quit <- results$es_quit
eq_data <- tibble(
  e = es_quit$egt,
  att = es_quit$att.egt,
  se = es_quit$se.egt,
  ci_lo = att - 1.96 * se,
  ci_hi = att + 1.96 * se
)

p4 <- ggplot(eq_data, aes(x = e, y = att * 100)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey60") +
  geom_vline(xintercept = -0.5, linetype = "dotted", color = "red", alpha = 0.5) +
  geom_ribbon(aes(ymin = ci_lo * 100, ymax = ci_hi * 100),
              fill = "#d95f02", alpha = 0.2) +
  geom_line(color = "#d95f02", linewidth = 0.6) +
  geom_point(color = "#d95f02", size = 1.8) +
  labs(x = "Years Relative to Ban Adoption",
       y = "ATT on Quit Attempt Rate (Percentage Points)",
       title = "Dynamic Treatment Effects: Quit Attempts (Among Ever-Smokers)")

ggsave(file.path(fig_dir, "fig4_event_study_quit.pdf"), p4, width = 8, height = 5)

# ============================================================================
# Figure 5: Leave-One-Region-Out
# ============================================================================

cat("Figure 5: Leave-one-region-out...\n")

if (exists("robust") && !is.null(robust$loro_results)) {
  loro_df <- bind_rows(robust$loro_results) %>%
    mutate(
      ci_lo = att - 1.96 * se,
      ci_hi = att + 1.96 * se,
      region_dropped = factor(region_dropped,
                                levels = c("Northeast", "Midwest", "South", "West"))
    )

  main_att <- results$att_smoking$overall.att
  main_se <- results$att_smoking$overall.se

  p5 <- ggplot(loro_df, aes(x = region_dropped, y = att * 100)) +
    geom_hline(yintercept = main_att * 100, linetype = "dashed",
               color = "#1b9e77", linewidth = 0.5) +
    geom_hline(yintercept = 0, linetype = "solid", color = "grey60") +
    geom_pointrange(aes(ymin = ci_lo * 100, ymax = ci_hi * 100),
                    color = "#7570b3", size = 0.5) +
    labs(x = "Census Region Dropped",
         y = "ATT on Current Smoking Rate (Percentage Points)",
         title = "Leave-One-Region-Out Robustness") +
    annotate("text", x = 0.6, y = main_att * 100,
             label = "Main estimate", color = "#1b9e77", hjust = 0, size = 3)

  ggsave(file.path(fig_dir, "fig5_loro.pdf"), p5, width = 7, height = 5)
}

# ============================================================================
# Figure 6: Randomization Inference
# ============================================================================

cat("Figure 6: Randomization inference...\n")

if (exists("robust") && !is.null(robust$perm_atts)) {
  perm_df <- tibble(att = robust$perm_atts) %>% filter(!is.na(att))
  main_att <- results$att_smoking$overall.att

  p6 <- ggplot(perm_df, aes(x = att * 100)) +
    geom_histogram(bins = 50, fill = "grey70", color = "grey50", alpha = 0.8) +
    geom_vline(xintercept = main_att * 100, color = "#e41a1c",
               linewidth = 1, linetype = "solid") +
    labs(x = "Placebo ATT Distribution (Percentage Points)",
         y = "Count",
         title = "Randomization Inference: Permutation Distribution") +
    annotate("text", x = main_att * 100, y = Inf,
             label = sprintf("Actual ATT = %.2f pp\np = %.3f",
                             main_att * 100, robust$ri_pvalue),
             vjust = 2, hjust = -0.1, color = "#e41a1c", size = 3.5)

  ggsave(file.path(fig_dir, "fig6_ri_distribution.pdf"), p6, width = 7, height = 5)
}

# ============================================================================
# Figure 7: Heterogeneity by Education
# ============================================================================

cat("Figure 7: Heterogeneity by education...\n")

# Create education-specific panels
if (file.exists(file.path(data_dir, "brfss_individual.rds"))) {
  df_ind <- readRDS(file.path(data_dir, "brfss_individual.rds"))

  hetero_panels <- list()
  for (edu_val in c(0, 1)) {
    label <- ifelse(edu_val == 1, "College Graduate", "No College Degree")

    panel_edu <- df_ind %>%
      filter(college == edu_val, !is.na(current_smoker)) %>%
      group_by(state_fips, year, first_treat) %>%
      summarise(
        smoking_rate = weighted.mean(current_smoker, wt, na.rm = TRUE),
        n_obs = n(),
        .groups = "drop"
      )

    tryCatch({
      cs_edu <- att_gt(
        yname = "smoking_rate",
        tname = "year",
        idname = "state_fips",
        gname = "first_treat",
        data = panel_edu,
        control_group = "nevertreated",
        est_method = "dr",
        base_period = "universal",
        panel = TRUE,
        allow_unbalanced_panel = TRUE
      )
      es_edu <- aggte(cs_edu, type = "dynamic", min_e = -8, max_e = 12)
      hetero_panels[[label]] <- tibble(
        e = es_edu$egt,
        att = es_edu$att.egt,
        se = es_edu$se.egt,
        group = label
      )
    }, error = function(e) {
      cat(sprintf("  Error for %s: %s\n", label, e$message))
    })
  }

  if (length(hetero_panels) == 2) {
    hetero_df <- bind_rows(hetero_panels) %>%
      mutate(ci_lo = att - 1.96 * se, ci_hi = att + 1.96 * se)

    p7 <- ggplot(hetero_df, aes(x = e, y = att * 100)) +
      geom_hline(yintercept = 0, linetype = "dashed", color = "grey60") +
      geom_vline(xintercept = -0.5, linetype = "dotted", color = "red", alpha = 0.5) +
      geom_ribbon(aes(ymin = ci_lo * 100, ymax = ci_hi * 100),
                  fill = "#1b9e77", alpha = 0.2) +
      geom_line(color = "#1b9e77", linewidth = 0.6) +
      geom_point(color = "#1b9e77", size = 1.5) +
      facet_wrap(~ group, ncol = 1) +
      labs(x = "Years Relative to Ban Adoption",
           y = "ATT on Current Smoking Rate (Percentage Points)",
           title = "Heterogeneous Effects by Education Level") +
      theme(strip.text = element_text(face = "bold", size = 11))

    ggsave(file.path(fig_dir, "fig7_heterogeneity_education.pdf"), p7,
           width = 8, height = 7)
  }
}

cat("\n=== All figures generated ===\n")
cat(sprintf("  Output directory: %s\n", fig_dir))
cat(sprintf("  Files: %s\n", paste(list.files(fig_dir), collapse = ", ")))
