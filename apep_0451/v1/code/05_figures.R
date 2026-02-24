##──────────────────────────────────────────────────────────────────────────────
## 05_figures.R — All figures for the paper
## Paper: apep_0451 — Cocoa Boom and Human Capital in Ghana
##──────────────────────────────────────────────────────────────────────────────

library(data.table)
library(ggplot2)
library(patchwork)
library(scales)

DATA_DIR <- here::here("output", "apep_0451", "v1", "data")
FIG_DIR  <- here::here("output", "apep_0451", "v1", "figures")
dir.create(FIG_DIR, recursive = TRUE, showWarnings = FALSE)

## ── APEP theme ──────────────────────────────────────────────────────────────
theme_apep <- function(base_size = 10) {
  theme_minimal(base_size = base_size) +
    theme(
      panel.grid.minor = element_blank(),
      panel.grid.major.x = element_blank(),
      strip.text = element_text(face = "bold", size = base_size),
      plot.title = element_text(face = "bold", size = base_size + 2),
      plot.subtitle = element_text(size = base_size, color = "gray30"),
      legend.position = "bottom",
      axis.title = element_text(size = base_size),
      plot.margin = margin(10, 15, 10, 10)
    )
}

## Load data
dt <- fread(file.path(DATA_DIR, "ghana_census_clean.csv.gz"), nThread = 4)
cocoa_prices <- fread(file.path(DATA_DIR, "cocoa_prices.csv"))
dhs_panel <- fread(file.path(DATA_DIR, "dhs_regional_panel.csv"))

## ════════════════════════════════════════════════════════════════════════════
## FIGURE 1: World Cocoa Prices and Census Years
## ════════════════════════════════════════════════════════════════════════════

fig1 <- ggplot(cocoa_prices[year >= 1980 & year <= 2015],
               aes(x = year, y = price_usd_mt)) +
  geom_line(linewidth = 0.8, color = "chocolate4") +
  geom_point(data = cocoa_prices[year %in% c(1984, 2000, 2010)],
             size = 3, color = "red") +
  geom_vline(xintercept = c(1984, 2000, 2010), linetype = "dashed",
             color = "gray50", linewidth = 0.5) +
  annotate("text", x = 1984, y = max(cocoa_prices[year <= 2015]$price_usd_mt) * 0.95,
           label = "Census\n1984", size = 3, hjust = 0.5) +
  annotate("text", x = 2000, y = max(cocoa_prices[year <= 2015]$price_usd_mt) * 0.95,
           label = "Census\n2000", size = 3, hjust = 0.5) +
  annotate("text", x = 2010, y = max(cocoa_prices[year <= 2015]$price_usd_mt) * 0.95,
           label = "Census\n2010", size = 3, hjust = 0.5) +
  annotate("rect", xmin = 2000, xmax = 2010, ymin = -Inf, ymax = Inf,
           alpha = 0.1, fill = "chocolate4") +
  annotate("text", x = 2005, y = 500, label = "Cocoa Boom\nPeriod",
           size = 3, fontface = "italic", color = "chocolate4") +
  scale_y_continuous(labels = dollar_format(prefix = "$", suffix = ""),
                     breaks = seq(0, 4000, 500)) +
  labs(x = "", y = "World Cocoa Price (USD/metric ton)",
       title = "World Cocoa Prices and Ghana Census Years") +
  theme_apep()

ggsave(file.path(FIG_DIR, "fig1_cocoa_prices.pdf"), fig1,
       width = 6.5, height = 4)
cat("Figure 1 saved.\n")

## ════════════════════════════════════════════════════════════════════════════
## FIGURE 2: Event Study — Three-Period Estimates
## ════════════════════════════════════════════════════════════════════════════

## Compute regional means by year and cocoa intensity
## School outcomes: school-age children (6-17) only
## Employment outcomes: working-age adults (18-64) only
means_school <- dt[forest_belt == TRUE & school_age == 1, .(
  enrollment = weighted.mean(in_school, pw, na.rm = TRUE),
  primary = weighted.mean(completed_primary, pw, na.rm = TRUE)
), by = .(census_year, high_cocoa)]

means_work <- dt[forest_belt == TRUE & working_age == 1, .(
  employed = weighted.mean(employed, pw, na.rm = TRUE),
  agriculture = weighted.mean(works_agriculture, pw, na.rm = TRUE)
), by = .(census_year, high_cocoa)]

means <- merge(means_school, means_work, by = c("census_year", "high_cocoa"))

means_long <- melt(means, id.vars = c("census_year", "high_cocoa"),
                    variable.name = "outcome", value.name = "mean")
means_long[, group := fifelse(high_cocoa == 1, "High Cocoa", "Low Cocoa")]
means_long[, outcome_label := factor(outcome,
  levels = c("enrollment", "primary", "employed", "agriculture"),
  labels = c("School Enrollment (6-17)", "Primary Completion (6-17)",
             "Employment Rate (18-64)", "Agricultural Employment (18-64)"))]

fig2 <- ggplot(means_long, aes(x = census_year, y = mean,
                                color = group, shape = group)) +
  geom_line(linewidth = 0.8) +
  geom_point(size = 2.5) +
  facet_wrap(~outcome_label, scales = "free_y", ncol = 2) +
  scale_color_manual(values = c("High Cocoa" = "chocolate4",
                                 "Low Cocoa" = "steelblue")) +
  scale_x_continuous(breaks = c(1984, 2000, 2010)) +
  scale_y_continuous(labels = percent_format(accuracy = 1)) +
  labs(x = "", y = "", color = "", shape = "",
       title = "Outcomes by Cocoa Intensity (Forest Belt Regions)") +
  theme_apep() +
  theme(legend.position = "bottom")

ggsave(file.path(FIG_DIR, "fig2_event_study.pdf"), fig2,
       width = 6.5, height = 5)
cat("Figure 2 saved.\n")

## ════════════════════════════════════════════════════════════════════════════
## FIGURE 3: Event Study Coefficients (β from 3-period model)
## ════════════════════════════════════════════════════════════════════════════

library(fixest)

dt_forest_all <- dt[forest_belt == TRUE]

## Primary completion event study
event_primary <- feols(
  completed_primary ~ cocoa_share:i(census_year, ref = 2000) + female + I(age) |
    geo1 + census_year,
  data = dt_forest_all[school_age == 1],
  weights = ~pw, cluster = ~geo1
)

## Employment event study
event_emp <- feols(
  employed ~ cocoa_share:i(census_year, ref = 2000) + female + I(age) |
    geo1 + census_year,
  data = dt_forest_all[working_age == 1 & !is.na(employed)],
  weights = ~pw, cluster = ~geo1
)

## Extract coefficients
extract_event <- function(model, outcome_name) {
  cf <- coeftable(model)
  rows <- grep("cocoa_share:census_year", rownames(cf))
  years <- as.integer(gsub(".*::", "", rownames(cf)[rows]))
  data.table(
    year = c(years[1], 2000, years[2]),
    coef = c(cf[rows[1], 1], 0, cf[rows[2], 1]),
    se = c(cf[rows[1], 2], 0, cf[rows[2], 2]),
    outcome = outcome_name
  )
}

event_dt <- rbind(
  extract_event(event_primary, "Primary Completion"),
  extract_event(event_emp, "Employment Rate")
)
event_dt[, ci_lo := coef - 1.96 * se]
event_dt[, ci_hi := coef + 1.96 * se]

fig3 <- ggplot(event_dt, aes(x = year, y = coef)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
  geom_errorbar(aes(ymin = ci_lo, ymax = ci_hi), width = 1, linewidth = 0.6) +
  geom_point(size = 2.5, color = "chocolate4") +
  facet_wrap(~outcome, scales = "free_y") +
  scale_x_continuous(breaks = c(1984, 2000, 2010)) +
  labs(x = "", y = expression(hat(beta) ~ "(Cocoa Share" %*% "Year)"),
       title = "Event Study: Effect of Cocoa Exposure",
       subtitle = "Reference year: 2000. Forest belt regions. 95% CIs.") +
  theme_apep()

ggsave(file.path(FIG_DIR, "fig3_event_coefficients.pdf"), fig3,
       width = 6.5, height = 3.5)
cat("Figure 3 saved.\n")

## ════════════════════════════════════════════════════════════════════════════
## FIGURE 4: Regional Cocoa Production Shares (Map-like bar chart)
## ════════════════════════════════════════════════════════════════════════════

cocoa_shares <- fread(file.path(DATA_DIR, "cocoa_regional_shares.csv"))
cocoa_shares_plot <- data.table(
  region = c("Western", "Ashanti", "Brong Ahafo", "Eastern",
             "Central", "Volta", "Greater Accra", "Northern",
             "Upper East", "Upper West"),
  share = c(0.55, 0.20, 0.12, 0.08, 0.03, 0.01, 0.00, 0.00, 0.00, 0.00),
  belt = c("Forest", "Forest", "Forest", "Forest",
           "Forest", "Forest", "Urban", "Savanna", "Savanna", "Savanna")
)
cocoa_shares_plot[, region := factor(region, levels = region[order(share)])]

fig4 <- ggplot(cocoa_shares_plot, aes(x = region, y = share, fill = belt)) +
  geom_col(width = 0.7) +
  coord_flip() +
  scale_fill_manual(values = c("Forest" = "darkgreen", "Savanna" = "goldenrod",
                                "Urban" = "gray50")) +
  scale_y_continuous(labels = percent_format(accuracy = 1),
                     expand = expansion(mult = c(0, 0.05))) +
  labs(x = "", y = "Share of National Cocoa Production",
       fill = "Ecological Zone",
       title = "Cocoa Production Intensity by Region") +
  theme_apep() +
  theme(legend.position = c(0.8, 0.3))

ggsave(file.path(FIG_DIR, "fig4_cocoa_shares.pdf"), fig4,
       width = 6.5, height = 4)
cat("Figure 4 saved.\n")

## ════════════════════════════════════════════════════════════════════════════
## FIGURE 5: DHS Pre-Trends (Extended Health Indicators)
## ════════════════════════════════════════════════════════════════════════════

## Map DHS regions to cocoa intensity
## DHS regions for Ghana: match to our classification
dhs_cocoa <- data.table(
  dhs_region = c("Western", "Ashanti", "Brong Ahafo", "Eastern",
                 "Central", "Volta", "Greater Accra", "Northern",
                 "Upper East", "Upper West"),
  high_cocoa = c(1L, 1L, 1L, 1L, 0L, 0L, 0L, 0L, 0L, 0L)
)

dhs_matched <- merge(dhs_panel, dhs_cocoa, by.x = "region", by.y = "dhs_region")
dhs_means <- dhs_matched[!is.na(value), .(
  mean_value = mean(value)
), by = .(survey_year, high_cocoa, indicator)]

dhs_means[, group := fifelse(high_cocoa == 1, "High Cocoa", "Low Cocoa")]
dhs_means[, indicator_label := factor(indicator,
  levels = c("FE_FRTR_W_TFR", "CM_ECMR_C_IMR", "RH_DELP_C_DHF", "RH_ANCN_W_N4P"),
  labels = c("Total Fertility Rate", "Infant Mortality Rate",
             "Facility Delivery (%)", "4+ ANC Visits (%)"))]

fig5 <- ggplot(dhs_means[!is.na(indicator_label)],
               aes(x = survey_year, y = mean_value, color = group)) +
  geom_line(linewidth = 0.7) +
  geom_point(size = 2) +
  geom_vline(xintercept = 2003, linetype = "dashed", color = "gray50", linewidth = 0.4) +
  facet_wrap(~indicator_label, scales = "free_y", ncol = 2) +
  scale_color_manual(values = c("High Cocoa" = "chocolate4",
                                 "Low Cocoa" = "steelblue")) +
  labs(x = "", y = "", color = "",
       title = "Extended Health Trends by Cocoa Intensity (DHS Data)",
       subtitle = "Dashed line = NHIS launch (2003)") +
  theme_apep()

ggsave(file.path(FIG_DIR, "fig5_dhs_trends.pdf"), fig5,
       width = 6.5, height = 5)
cat("Figure 5 saved.\n")

## ════════════════════════════════════════════════════════════════════════════
## FIGURE 6: Age Heterogeneity in Enrollment Effect
## ════════════════════════════════════════════════════════════════════════════

## Estimate age-specific effects
dt_forest_main <- dt[census_year %in% c(2000, 2010) & forest_belt == TRUE]
age_effects <- list()
for (a in 6:17) {
  m <- feols(
    in_school ~ cocoa_share:post2010 + female |
      geo1 + census_year,
    data = dt_forest_main[age == a & !is.na(in_school)],
    weights = ~pw, cluster = ~geo1
  )
  cf <- coeftable(m)
  row <- grep("cocoa_share", rownames(cf))
  age_effects[[as.character(a)]] <- data.table(
    age = a, coef = cf[row, 1], se = cf[row, 2]
  )
}
age_dt <- rbindlist(age_effects)
age_dt[, ci_lo := coef - 1.96 * se]
age_dt[, ci_hi := coef + 1.96 * se]

fig6 <- ggplot(age_dt, aes(x = age, y = coef)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
  geom_ribbon(aes(ymin = ci_lo, ymax = ci_hi), alpha = 0.2, fill = "chocolate4") +
  geom_line(color = "chocolate4", linewidth = 0.8) +
  geom_point(color = "chocolate4", size = 2) +
  annotate("rect", xmin = 5.5, xmax = 11.5, ymin = -Inf, ymax = Inf,
           alpha = 0.05, fill = "blue") +
  annotate("rect", xmin = 11.5, xmax = 17.5, ymin = -Inf, ymax = Inf,
           alpha = 0.05, fill = "red") +
  annotate("text", x = 8.5, y = max(age_dt$ci_hi) * 0.9,
           label = "Primary\nAge", size = 3, color = "blue4") +
  annotate("text", x = 14.5, y = max(age_dt$ci_hi) * 0.9,
           label = "Secondary\nAge", size = 3, color = "red4") +
  scale_x_continuous(breaks = 6:17) +
  labs(x = "Age", y = expression(hat(beta) ~ "(Enrollment Effect)"),
       title = "Age-Specific Effect of Cocoa Exposure on School Enrollment",
       subtitle = "Forest belt regions, 2000-2010. 95% CIs.") +
  theme_apep()

ggsave(file.path(FIG_DIR, "fig6_age_heterogeneity.pdf"), fig6,
       width = 6.5, height = 4)
cat("Figure 6 saved.\n")

cat("\nAll figures saved to:", FIG_DIR, "\n")
list.files(FIG_DIR)
