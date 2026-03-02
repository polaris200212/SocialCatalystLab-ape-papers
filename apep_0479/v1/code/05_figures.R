## ============================================================
## 05_figures.R — Publication-ready figures
## APEP-0479: Durbin Amendment, Bank Restructuring, and Tellers
## ============================================================

source("00_packages.R")

data_dir <- "../data/"
fig_dir  <- "../figures/"
dir.create(fig_dir, showWarnings = FALSE, recursive = TRUE)

panel   <- readRDS(file.path(data_dir, "analysis_panel.rds"))
results <- readRDS(file.path(data_dir, "main_results.rds"))


## ---- Figure 1: National Trends in Bank Branches and Tellers ----

cat("Figure 1: National trends...\n")

national_trends <- panel %>%
  group_by(year) %>%
  summarise(
    total_branches = sum(n_branches_total, na.rm = TRUE),
    total_bank_emp = sum(bank_emp, na.rm = TRUE),
    avg_bank_wage  = weighted.mean(bank_wage, bank_emp, na.rm = TRUE),
    n_counties     = n(),
    .groups = "drop"
  ) %>%
  mutate(
    branches_idx = total_branches / total_branches[year == 2010] * 100,
    emp_idx      = total_bank_emp / total_bank_emp[year == 2010] * 100
  )

p1 <- national_trends %>%
  select(year, Branches = branches_idx, `Banking Employment` = emp_idx) %>%
  pivot_longer(-year, names_to = "Series", values_to = "Index") %>%
  ggplot(aes(x = year, y = Index, color = Series, linetype = Series)) +
  geom_line(linewidth = 1) +
  geom_point(size = 2) +
  geom_vline(xintercept = 2011.75, linetype = "dashed", color = "grey40",
             linewidth = 0.5) +
  annotate("text", x = 2012.2, y = 103, label = "Durbin\nAmendment",
           size = 3, hjust = 0, color = "grey40") +
  scale_color_manual(values = apep_colors[1:2]) +
  scale_x_continuous(breaks = seq(2005, 2019, 2)) +
  labs(
    title = "Bank Branches and Banking Employment, 2005\u20132019",
    subtitle = "Index: 2010 = 100. Vertical line marks Durbin Amendment (Oct 2011).",
    x = NULL, y = "Index (2010 = 100)",
    color = NULL, linetype = NULL
  ) +
  theme_apep()

ggsave(file.path(fig_dir, "fig1_national_trends.pdf"), p1,
       width = 8, height = 5)


## ---- Figure 2: Durbin Exposure Distribution ----

cat("Figure 2: Exposure distribution...\n")

exposure <- panel %>%
  filter(year == 2010) %>%
  select(county_fips, durbin_exposure)

p2 <- ggplot(exposure, aes(x = durbin_exposure)) +
  geom_histogram(bins = 50, fill = apep_colors[1], alpha = 0.7,
                 color = "white") +
  geom_vline(xintercept = median(exposure$durbin_exposure),
             linetype = "dashed", color = apep_colors[2], linewidth = 0.7) +
  annotate("text",
           x = median(exposure$durbin_exposure) + 0.02,
           y = Inf, vjust = 2,
           label = sprintf("Median = %.2f", median(exposure$durbin_exposure)),
           color = apep_colors[2], size = 3.5) +
  labs(
    title = "Distribution of County-Level Durbin Exposure",
    subtitle = "Share of 2010 deposits in banks with assets > $10 billion",
    x = "Durbin Exposure (Deposit Share in Treated Banks)",
    y = "Number of Counties"
  ) +
  theme_apep()

ggsave(file.path(fig_dir, "fig2_exposure_distribution.pdf"), p2,
       width = 8, height = 5)


## ---- Figure 3: Event Study — Banking Employment ----

cat("Figure 3: Event study (employment)...\n")

# Extract event study coefficients from fixest model
m_event <- results$m2_event
es_df <- data.frame(
  year = as.numeric(gsub("year::(\\d+):durbin_exposure", "\\1",
                         names(coef(m_event)))),
  coef = coef(m_event),
  se   = se(m_event)
) %>%
  filter(!is.na(year)) %>%
  # Add the reference year
  bind_rows(data.frame(year = 2010, coef = 0, se = 0)) %>%
  arrange(year) %>%
  mutate(
    ci_lo = coef - 1.96 * se,
    ci_hi = coef + 1.96 * se
  )

p3 <- ggplot(es_df, aes(x = year, y = coef)) +
  geom_ribbon(aes(ymin = ci_lo, ymax = ci_hi),
              alpha = 0.15, fill = apep_colors[1]) +
  geom_point(color = apep_colors[1], size = 2.5) +
  geom_line(color = apep_colors[1], linewidth = 0.7) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
  geom_vline(xintercept = 2011.5, linetype = "dotted", color = "grey60") +
  annotate("text", x = 2011.8, y = max(es_df$ci_hi, na.rm = TRUE) * 0.9,
           label = "Durbin\nimplementation", size = 3, hjust = 0,
           color = "grey50") +
  scale_x_continuous(breaks = seq(2005, 2019, 2)) +
  labs(
    title = "Event Study: Effect of Durbin Exposure on Banking Employment",
    subtitle = "Coefficient on Durbin Exposure \u00d7 Year indicators; ref. year = 2010",
    x = NULL,
    y = "Coefficient on Durbin Exposure \u00d7 Year",
    caption = "Notes: 95% CIs based on state-clustered SEs. County and year FE included."
  ) +
  theme_apep()

ggsave(file.path(fig_dir, "fig3_event_study_employment.pdf"), p3,
       width = 8, height = 5.5)


## ---- Figure 4: Event Study — Branches ----

cat("Figure 4: Event study (branches)...\n")

m_br_event <- results$m1_event
br_df <- data.frame(
  year = as.numeric(gsub("year::(\\d+):durbin_exposure", "\\1",
                         names(coef(m_br_event)))),
  coef = coef(m_br_event),
  se   = se(m_br_event)
) %>%
  filter(!is.na(year)) %>%
  bind_rows(data.frame(year = 2010, coef = 0, se = 0)) %>%
  arrange(year) %>%
  mutate(ci_lo = coef - 1.96 * se, ci_hi = coef + 1.96 * se)

p4 <- ggplot(br_df, aes(x = year, y = coef)) +
  geom_ribbon(aes(ymin = ci_lo, ymax = ci_hi),
              alpha = 0.15, fill = apep_colors[2]) +
  geom_point(color = apep_colors[2], size = 2.5) +
  geom_line(color = apep_colors[2], linewidth = 0.7) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
  geom_vline(xintercept = 2011.5, linetype = "dotted", color = "grey60") +
  scale_x_continuous(breaks = seq(2005, 2019, 2)) +
  labs(
    title = "Event Study: Effect of Durbin Exposure on Bank Branches",
    subtitle = "Coefficient on Durbin Exposure \u00d7 Year indicators; ref. year = 2010",
    x = NULL,
    y = "Coefficient on Durbin Exposure \u00d7 Year",
    caption = "Notes: 95% CIs based on state-clustered SEs. County and year FE included."
  ) +
  theme_apep()

ggsave(file.path(fig_dir, "fig4_event_study_branches.pdf"), p4,
       width = 8, height = 5.5)


## ---- Figure 5: High vs Low Exposure Counties ----

cat("Figure 5: High vs low exposure...\n")

panel_by_exposure <- panel %>%
  mutate(exposure_group = ifelse(exposure_high == 1,
                                  "High Exposure", "Low Exposure")) %>%
  group_by(exposure_group, year) %>%
  summarise(
    avg_branches_pc = mean(branches_pc, na.rm = TRUE),
    avg_bank_emp_pc = mean(bank_emp_pc, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(
    branches_idx = ave(avg_branches_pc, exposure_group,
                       FUN = function(x) x / x[1] * 100),
    emp_idx = ave(avg_bank_emp_pc, exposure_group,
                  FUN = function(x) x / x[1] * 100)
  )

p5 <- ggplot(panel_by_exposure,
             aes(x = year, y = emp_idx, color = exposure_group)) +
  geom_line(linewidth = 1) +
  geom_point(size = 2) +
  geom_vline(xintercept = 2011.75, linetype = "dashed", color = "grey40") +
  scale_color_manual(values = apep_colors[1:2]) +
  scale_x_continuous(breaks = seq(2005, 2019, 2)) +
  labs(
    title = "Banking Employment per Capita by Durbin Exposure",
    subtitle = "Index: 2005 = 100. Split at median county-level exposure.",
    x = NULL, y = "Index (2005 = 100)",
    color = NULL
  ) +
  theme_apep()

ggsave(file.path(fig_dir, "fig5_high_low_exposure.pdf"), p5,
       width = 8, height = 5)


## ---- Figure 6: Placebo Tests ----

cat("Figure 6: Placebo tests...\n")

robustness <- readRDS(file.path(data_dir, "robustness_results.rds"))

placebo_df <- data.frame(
  sector = c("Banking\n(Main)", "Retail\n(Placebo)", "Manufacturing\n(Placebo)",
             "Healthcare\n(Placebo)"),
  coef = c(
    coef(results$m2_emp)["durbin_post"],
    coef(robustness$placebo_retail)["durbin_post"],
    coef(robustness$placebo_mfg)["durbin_post"],
    coef(robustness$placebo_health)["durbin_post"]
  ),
  se = c(
    se(results$m2_emp)["durbin_post"],
    se(robustness$placebo_retail)["durbin_post"],
    se(robustness$placebo_mfg)["durbin_post"],
    se(robustness$placebo_health)["durbin_post"]
  ),
  is_main = c(TRUE, FALSE, FALSE, FALSE)
)

placebo_df <- placebo_df %>%
  mutate(
    ci_lo = coef - 1.96 * se,
    ci_hi = coef + 1.96 * se,
    sector = factor(sector, levels = sector)
  )

p6 <- ggplot(placebo_df, aes(x = sector, y = coef, color = is_main)) +
  geom_pointrange(aes(ymin = ci_lo, ymax = ci_hi), size = 0.8,
                  linewidth = 0.6) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
  scale_color_manual(values = c("TRUE" = apep_colors[1],
                                "FALSE" = apep_colors[3]),
                     guide = "none") +
  labs(
    title = "Placebo Tests: Durbin Exposure Effect by Sector",
    subtitle = "Point estimates and 95% CIs. Only banking should respond.",
    x = NULL,
    y = "Coefficient on Durbin Exposure \u00d7 Post",
    caption = "Notes: State-clustered SEs. County and year FE."
  ) +
  theme_apep()

ggsave(file.path(fig_dir, "fig6_placebo_sectors.pdf"), p6,
       width = 7, height = 5)


## ---- Figure 7: Deposit Reallocation ----

cat("Figure 7: Deposit reallocation...\n")

deposit_trends <- panel %>%
  mutate(exposure_group = ifelse(exposure_high == 1,
                                  "High Exposure", "Low Exposure")) %>%
  group_by(exposure_group, year) %>%
  summarise(
    avg_exempt_share = mean(exempt_deposit_share, na.rm = TRUE),
    .groups = "drop"
  )

p7 <- ggplot(deposit_trends,
             aes(x = year, y = avg_exempt_share, color = exposure_group)) +
  geom_line(linewidth = 1) +
  geom_point(size = 2) +
  geom_vline(xintercept = 2011.75, linetype = "dashed", color = "grey40") +
  scale_color_manual(values = apep_colors[1:2]) +
  scale_y_continuous(labels = scales::percent_format()) +
  scale_x_continuous(breaks = seq(2005, 2019, 2)) +
  labs(
    title = "Deposit Share of Durbin-Exempt Banks",
    subtitle = "Average across counties by exposure group",
    x = NULL, y = "Share of Deposits in Exempt Banks",
    color = NULL
  ) +
  theme_apep()

ggsave(file.path(fig_dir, "fig7_deposit_reallocation.pdf"), p7,
       width = 8, height = 5)


## ---- Figure 8: LOSO Sensitivity ----

cat("Figure 8: LOSO...\n")

loso <- readRDS(file.path(data_dir, "loso_coefficients.rds"))
baseline_coef <- coef(results$m2_emp)["durbin_post"]

loso_df <- data.frame(
  state = names(loso),
  coef = as.numeric(loso)
) %>%
  arrange(coef)

p8 <- ggplot(loso_df, aes(x = reorder(state, coef), y = coef)) +
  geom_point(color = apep_colors[1], size = 1.5) +
  geom_hline(yintercept = baseline_coef, linetype = "dashed",
             color = apep_colors[2], linewidth = 0.5) +
  geom_hline(yintercept = 0, linetype = "solid", color = "grey40") +
  labs(
    title = "Leave-One-State-Out Sensitivity",
    subtitle = sprintf("Baseline coefficient = %.4f (dashed line)", baseline_coef),
    x = "State Excluded (FIPS code)",
    y = "Coefficient on Durbin Exposure \u00d7 Post"
  ) +
  theme_apep() +
  theme(axis.text.x = element_text(angle = 90, size = 6, vjust = 0.5))

ggsave(file.path(fig_dir, "fig8_loso_sensitivity.pdf"), p8,
       width = 10, height = 5)


cat("\n=== All figures saved to", fig_dir, "===\n")
list.files(fig_dir)
