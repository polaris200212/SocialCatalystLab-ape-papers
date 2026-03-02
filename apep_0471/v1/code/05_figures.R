## 05_figures.R — Generate all figures for apep_0471

source("00_packages.R")

data_dir <- "../data"
fig_dir <- "../figures"
dir.create(fig_dir, showWarnings = FALSE)

panel <- read_parquet(file.path(data_dir, "monthly_panel.parquet"))
annual <- read_parquet(file.path(data_dir, "annual_panel.parquet"))

la_ids <- panel %>% distinct(la_code) %>% mutate(la_id = row_number())
panel <- panel %>% left_join(la_ids, by = "la_code")

# ============================================================
# FIGURE 1: UC Rollout Timeline
# ============================================================
cat("Figure 1: Rollout timeline...\n")

rollout_summary <- panel %>%
  filter(!is.na(first_treat_date)) %>%
  distinct(la_code, first_treat_date) %>%
  count(first_treat_date, name = "n_las") %>%
  arrange(first_treat_date) %>%
  mutate(cumulative = cumsum(n_las))

p1 <- ggplot(rollout_summary, aes(x = first_treat_date)) +
  geom_col(aes(y = n_las), fill = "#2171B5", alpha = 0.7, width = 25) +
  geom_line(aes(y = cumulative / max(cumulative) * max(n_las)),
            color = "#CB181D", linewidth = 1) +
  scale_x_date(date_breaks = "6 months", date_labels = "%b\n%Y") +
  scale_y_continuous(
    name = "Local Authorities transitioning",
    sec.axis = sec_axis(~ . / max(rollout_summary$n_las) * max(rollout_summary$cumulative),
                        name = "Cumulative LAs")
  ) +
  labs(
    title = "Universal Credit Full Service Rollout",
    subtitle = "Staggered adoption across Local Authorities, 2015-2018",
    x = NULL,
    caption = "Source: DWP Transition Rollout Schedule (2018)"
  ) +
  theme_apep() +
  theme(axis.title.y.right = element_text(color = "#CB181D"))

ggsave(file.path(fig_dir, "fig1_rollout_timeline.pdf"), p1,
       width = 8, height = 5)

# ============================================================
# FIGURE 2: Raw Trends — Treated vs Not-Yet-Treated
# ============================================================
cat("Figure 2: Raw trends...\n")

# Group LAs into early (pre-2018) and late (2018) treated
trends <- panel %>%
  mutate(
    group = case_when(
      is.na(first_treat_date) ~ "Never treated",
      first_treat_date < ymd("2017-07-01") ~ "Early adopters (2015-2017H1)",
      first_treat_date < ymd("2018-07-01") ~ "Mid adopters (2017H2-2018H1)",
      TRUE ~ "Late adopters (2018H2)"
    )
  ) %>%
  group_by(group, inc_ym) %>%
  summarise(
    mean_rate = mean(formation_rate, na.rm = TRUE),
    se_rate = sd(formation_rate, na.rm = TRUE) / sqrt(n()),
    .groups = "drop"
  )

p2 <- ggplot(trends, aes(x = inc_ym, y = mean_rate, color = group)) +
  geom_line(linewidth = 0.8) +
  geom_vline(xintercept = ymd("2016-05-01"), linetype = "dashed",
             color = "grey50", alpha = 0.5) +
  annotate("text", x = ymd("2016-05-01"), y = Inf, label = "First full service",
           vjust = -0.5, hjust = -0.05, size = 3, color = "grey50") +
  scale_color_manual(values = c("#2171B5", "#6BAED6", "#BDD7E7", "#969696")) +
  scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
  labs(
    title = "Monthly Firm Formation Rate by Treatment Cohort",
    subtitle = "New company registrations per 1,000 working-age population",
    x = NULL, y = "Formation rate (per 1,000)",
    color = NULL,
    caption = "Source: Companies House, ONS population estimates"
  ) +
  theme_apep()

ggsave(file.path(fig_dir, "fig2_raw_trends.pdf"), p2,
       width = 9, height = 5.5)

# ============================================================
# FIGURE 3: Event Study (CS-DiD Dynamic ATT)
# ============================================================
cat("Figure 3: Event study...\n")

agg_dynamic <- readRDS(file.path(data_dir, "cs_att_dynamic.rds"))

es_df <- data.frame(
  e = agg_dynamic$egt,
  att = agg_dynamic$att.egt,
  se = agg_dynamic$se.egt
) %>%
  mutate(
    ci_lo = att - 1.96 * se,
    ci_hi = att + 1.96 * se,
    significant = (ci_lo > 0 | ci_hi < 0)
  )

p3 <- ggplot(es_df, aes(x = e, y = att)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey60") +
  geom_vline(xintercept = -0.5, linetype = "dashed", color = "#CB181D", alpha = 0.5) +
  geom_ribbon(aes(ymin = ci_lo, ymax = ci_hi), fill = "#2171B5", alpha = 0.15) +
  geom_point(aes(color = significant), size = 2) +
  geom_line(color = "#2171B5", linewidth = 0.6) +
  scale_color_manual(values = c("TRUE" = "#2171B5", "FALSE" = "grey50"), guide = "none") +
  scale_x_continuous(breaks = seq(-8, 8, 2)) +
  labs(
    title = "Dynamic Treatment Effects: UC Full Service on Firm Formation",
    subtitle = "Callaway-Sant'Anna group-time ATT, aggregated by event time",
    x = "Quarters relative to UC full service rollout",
    y = "ATT (formation rate per 1,000)",
    caption = "Notes: 95% CI shown. Doubly-robust estimation, not-yet-treated comparison."
  ) +
  theme_apep()

ggsave(file.path(fig_dir, "fig3_event_study.pdf"), p3,
       width = 8, height = 5.5)

# ============================================================
# FIGURE 4: Heterogeneity by Sector
# ============================================================
cat("Figure 4: Sector heterogeneity...\n")

construction <- readRDS(file.path(data_dir, "robustness_construction.rds"))
professional <- readRDS(file.path(data_dir, "robustness_professional.rds"))
placebo <- readRDS(file.path(data_dir, "robustness_placebo_pubadmin.rds"))

# Helper to extract coefficient regardless of name (treated, treatedTRUE, treat_num)
get_coef_se <- function(model) {
  cf <- coef(model)
  vc <- vcov(model)
  coef_name <- intersect(names(cf), c("treated", "treatedTRUE", "treat_num"))[1]
  list(coef = cf[coef_name], se = sqrt(vc[coef_name, coef_name]))
}

# Run baseline model with numeric treatment
panel <- panel %>% mutate(treat_num = as.numeric(treated))
baseline <- feols(formation_rate ~ treat_num | as.factor(la_id) + period,
                  data = panel, cluster = ~la_code)

bl <- get_coef_se(baseline)
cn <- get_coef_se(construction)
pr <- get_coef_se(professional)
pl <- get_coef_se(placebo)

het_df <- tribble(
  ~sector, ~coef, ~se,
  "All sectors", bl$coef, bl$se,
  "Construction (F)", cn$coef, cn$se,
  "Professional (M)", pr$coef, pr$se,
  "Public admin (O)\n[Placebo]", pl$coef, pl$se
) %>%
  mutate(
    ci_lo = coef - 1.96 * se,
    ci_hi = coef + 1.96 * se,
    sector = factor(sector, levels = rev(sector))
  )

p4 <- ggplot(het_df, aes(x = coef, y = sector)) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "grey60") +
  geom_errorbarh(aes(xmin = ci_lo, xmax = ci_hi), height = 0.2, color = "#2171B5") +
  geom_point(size = 3, color = "#2171B5") +
  labs(
    title = "Treatment Effect by SIC Section",
    subtitle = "TWFE estimates, clustered at LA level",
    x = "Effect on formation rate (per 1,000 WA pop)",
    y = NULL,
    caption = "Public admin is a placebo sector (no self-employment channel)."
  ) +
  theme_apep()

ggsave(file.path(fig_dir, "fig4_sector_heterogeneity.pdf"), p4,
       width = 7, height = 4.5)

# ============================================================
# FIGURE 5: MIF Timing Effect
# ============================================================
cat("Figure 5: MIF timing...\n")

mif <- readRDS(file.path(data_dir, "mif_timing.rds"))

mif_df <- tribble(
  ~phase, ~coef, ~se,
  "Start-up period\n(0-12 months)", coef(mif)["startup"],
  sqrt(vcov(mif)["startup", "startup"]),
  "MIF binding\n(12+ months)", coef(mif)["mif"],
  sqrt(vcov(mif)["mif", "mif"])
) %>%
  mutate(
    ci_lo = coef - 1.96 * se,
    ci_hi = coef + 1.96 * se,
    phase = factor(phase, levels = phase)
  )

p5 <- ggplot(mif_df, aes(x = phase, y = coef)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey60") +
  geom_errorbar(aes(ymin = ci_lo, ymax = ci_hi), width = 0.15, color = "#2171B5") +
  geom_point(size = 4, color = "#2171B5") +
  labs(
    title = "Minimum Income Floor Timing Test",
    subtitle = "Effect on firm formation before and after MIF becomes binding",
    x = NULL,
    y = "Effect on formation rate (per 1,000)",
    caption = "MIF assumes self-employed earn at least NMW after 12-month start-up period."
  ) +
  theme_apep()

ggsave(file.path(fig_dir, "fig5_mif_timing.pdf"), p5,
       width = 6, height = 5)

# ============================================================
# FIGURE 6: Self-Employment Rate Event Study (Annual)
# ============================================================
cat("Figure 6: Self-employment event study...\n")

if (!file.exists(file.path(data_dir, "sunab_selfempl.rds"))) {
  cat("SKIPPING Figure 6: Self-employment model not available (insufficient NOMIS data).\n")
} else {

sa_se <- readRDS(file.path(data_dir, "sunab_selfempl.rds"))

# Extract Sun-Abraham coefficients
sa_coefs <- as.data.frame(coef(sa_se))
sa_vcov <- vcov(sa_se)

if (nrow(sa_coefs) > 0) {
  se_es_df <- data.frame(
    term = rownames(sa_coefs),
    coef = sa_coefs[, 1]
  ) %>%
    mutate(
      e = as.numeric(str_extract(term, "-?\\d+")),
      se = sqrt(diag(sa_vcov)[match(term, names(diag(sa_vcov)))]),
      ci_lo = coef - 1.96 * se,
      ci_hi = coef + 1.96 * se
    ) %>%
    filter(!is.na(e))

  p6 <- ggplot(se_es_df, aes(x = e, y = coef)) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "grey60") +
    geom_vline(xintercept = -0.5, linetype = "dashed", color = "#CB181D", alpha = 0.5) +
    geom_ribbon(aes(ymin = ci_lo, ymax = ci_hi), fill = "#2171B5", alpha = 0.15) +
    geom_point(size = 2, color = "#2171B5") +
    geom_line(color = "#2171B5", linewidth = 0.6) +
    labs(
      title = "UC Full Service and Self-Employment Rate",
      subtitle = "Sun-Abraham event study, NOMIS Annual Population Survey",
      x = "Years relative to UC full service rollout",
      y = "Effect on self-employment rate (pp)",
      caption = "Clustered at LA level. Not-yet-treated as comparison."
    ) +
    theme_apep()

  ggsave(file.path(fig_dir, "fig6_selfempl_event_study.pdf"), p6,
         width = 8, height = 5.5)
}
} # end if file.exists

cat("\n=== All figures generated ===\n")
cat("Saved to:", fig_dir, "\n")
