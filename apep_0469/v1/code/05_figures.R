## ============================================================================
## 05_figures.R — All Figures for apep_0469
## Missing Men, Rising Women
## ============================================================================

source("code/00_packages.R")
data_dir <- "data"
fig_dir <- "figures"
dir.create(fig_dir, showWarnings = FALSE)

## Load data
state_mob <- readRDS(file.path(data_dir, "state_mobilization.rds"))
state_analysis <- readRDS(file.path(data_dir, "state_analysis.rds"))
state_gy <- readRDS(file.path(data_dir, "state_gender_year.rds"))
decomp <- readRDS(file.path(data_dir, "decomposition.rds"))
decomp_mob <- readRDS(file.path(data_dir, "decomp_by_mob.rds"))
indiv_panel <- readRDS(file.path(data_dir, "indiv_panel.rds"))
models <- readRDS(file.path(data_dir, "main_models.rds"))
robustness <- readRDS(file.path(data_dir, "robustness.rds"))

# County shapes for maps
shp_file <- file.path(data_dir, "counties_1940.rds")
has_shapes <- file.exists(shp_file)
if (has_shapes) {
  counties_sf <- readRDS(shp_file)
}

state_analysis[, mob_std := as.numeric(scale(mobilization_rate))]
cat("Data loaded. Generating figures...\n")


## --------------------------------------------------------------------------
## Figure 1: Mobilization Map (State-Level)
## --------------------------------------------------------------------------

cat("Figure 1: Mobilization map\n")

if (has_shapes) {
  # Aggregate counties to states for map
  states_sf <- counties_sf %>%
    dplyr::group_by(STATEFP) %>%
    dplyr::summarise(geometry = sf::st_union(geometry)) %>%
    dplyr::ungroup()
  states_sf$statefip <- as.integer(states_sf$STATEFP)

  map_data <- merge(states_sf, state_mob[, .(statefip, mobilization_rate, mob_quintile)],
                    by = "statefip", all.x = TRUE)

  # Exclude AK, HI for cleaner map
  map_data <- map_data[!map_data$statefip %in% c(2, 15), ]

  p1 <- ggplot(map_data) +
    geom_sf(aes(fill = mobilization_rate), color = "white", size = 0.2) +
    scale_fill_viridis_c(option = "D", name = "Mobilization\nRate",
                         na.value = "grey85") +
    labs(title = "WWII Military Mobilization Rate by State",
         subtitle = "Enlistment records per male population aged 18-44 in 1940",
         caption = "Sources: CenSoc WWII Army Enlistment Records; IPUMS USA 1% (1940)") +
    theme_apep() +
    theme(axis.text = element_blank(), axis.ticks = element_blank(),
          panel.grid = element_blank())

  ggsave(file.path(fig_dir, "fig1_mobilization_map.pdf"), p1,
         width = 10, height = 6.5, device = "pdf")
}


## --------------------------------------------------------------------------
## Figure 2: Event Study — LFP by Gender and Mobilization
## --------------------------------------------------------------------------

cat("Figure 2: Event study\n")

# LFP trends by gender × mobilization quintile
trend_data <- indiv_panel[, .(
  lf = weighted.mean(in_lf, perwt, na.rm = TRUE)
), by = .(year, female, mob_quintile)]

trend_data[, Gender := fifelse(female == 1, "Women", "Men")]
trend_data[, Mobilization := mob_quintile]

# Simplify: High (Q4+Q5) vs Low (Q1+Q2) mobilization
trend_hl <- indiv_panel[, .(
  lf = weighted.mean(in_lf, perwt, na.rm = TRUE)
), by = .(year, female,
          mob_group = fifelse(mob_quintile %in% c("Q4", "Q5"), "High Mobilization",
                              fifelse(mob_quintile %in% c("Q1", "Q2"), "Low Mobilization", "Medium")))]
trend_hl[, Gender := fifelse(female == 1, "Women", "Men")]

p2 <- ggplot(trend_hl[mob_group != "Medium"],
             aes(x = factor(year), y = lf, color = Gender, linetype = mob_group, group = interaction(Gender, mob_group))) +
  geom_line(linewidth = 1) +
  geom_point(size = 3) +
  scale_color_manual(values = pal_gender) +
  scale_linetype_manual(values = c("High Mobilization" = "solid", "Low Mobilization" = "dashed")) +
  labs(x = "Census Year", y = "Labor Force Participation Rate",
       title = "Labor Force Participation by Gender and Mobilization Intensity",
       subtitle = "High = top 2 quintiles; Low = bottom 2 quintiles of state mobilization",
       linetype = "") +
  theme_apep() +
  theme(legend.position = "bottom")

ggsave(file.path(fig_dir, "fig2_event_study.pdf"), p2,
       width = 8, height = 5.5, device = "pdf")


## --------------------------------------------------------------------------
## Figure 3: Decomposition — Gender Gap by Year and Mobilization
## --------------------------------------------------------------------------

cat("Figure 3: Decomposition\n")

decomp_plot <- decomp_mob[, .(year, mob_quintile, lf_gap)]
decomp_plot[, Quintile := mob_quintile]

p3 <- ggplot(decomp_plot, aes(x = factor(year), y = lf_gap, fill = Quintile)) +
  geom_col(position = "dodge", width = 0.7) +
  scale_fill_viridis_d(option = "D") +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
  labs(x = "Census Year", y = "LFP Gender Gap (Female - Male)",
       title = "Gender LFP Gap by Mobilization Quintile",
       subtitle = "Gap narrows more in high-mobilization states") +
  theme_apep()

ggsave(file.path(fig_dir, "fig3_decomposition.pdf"), p3,
       width = 8, height = 5.5, device = "pdf")


## --------------------------------------------------------------------------
## Figure 4: Binned Scatter — Mobilization vs Δ Female LFP
## --------------------------------------------------------------------------

cat("Figure 4: Binned scatter (residualized)\n")

# State-level binscatter — Frisch-Waugh-Lovell residualization
# Residualize both mobilization and LFP change on 1940 controls
sa <- copy(state_analysis)
controls <- c("pct_urban", "pct_black", "pct_farm", "mean_educ", "mean_age", "pct_married")
controls <- controls[controls %in% names(sa)]
if (length(controls) >= 3) {
  fml_y <- as.formula(paste("d_lf_female ~", paste(controls, collapse = " + ")))
  fml_x <- as.formula(paste("mob_std ~", paste(controls, collapse = " + ")))
  res_y <- residuals(lm(fml_y, data = sa, weights = sa$n_female_1940))
  res_x <- residuals(lm(fml_x, data = sa, weights = sa$n_female_1940))
  sa[, resid_y := res_y]
  sa[, resid_x := res_x]
} else {
  sa[, resid_y := d_lf_female]
  sa[, resid_x := mob_std]
}

sa[, mob_bin := cut(resid_x,
                    breaks = quantile(resid_x, probs = seq(0, 1, 0.1), na.rm = TRUE),
                    include.lowest = TRUE)]
binned <- sa[!is.na(mob_bin), .(
  x = mean(resid_x),
  y = mean(resid_y)
), by = mob_bin]

p4a <- ggplot(binned, aes(x = x, y = y)) +
  geom_point(size = 3, color = "#E63946") +
  geom_smooth(method = "lm", se = TRUE, color = "#457B9D", fill = "#457B9D", alpha = 0.2) +
  labs(x = "Mobilization (residualized, std. dev.)",
       y = "Change in Female LFP (residualized)",
       title = "Mobilization and Change in Female LFP, Conditional on 1940 Controls",
       subtitle = "Frisch-Waugh-Lovell: both axes residualized on 1940 state characteristics") +
  theme_apep()

ggsave(file.path(fig_dir, "fig4_binned_scatter.pdf"), p4a,
       width = 7, height = 5.5, device = "pdf")


## --------------------------------------------------------------------------
## Figure 5: Heterogeneity Forest Plot
## --------------------------------------------------------------------------

cat("Figure 5: Heterogeneity\n")

# Extract post:mob_std coefficients from heterogeneity models
extract_coef <- function(model_list, var_pattern = "post.*mob_std|mob_std:post") {
  coefs <- lapply(names(model_list), function(nm) {
    m <- model_list[[nm]]
    if (is.null(m)) return(NULL)
    cf <- coeftable(m)
    idx <- grep(var_pattern, rownames(cf))
    if (length(idx) == 0) return(NULL)
    data.table(group = nm, coef = cf[idx[1], 1], se = cf[idx[1], 2])
  })
  rbindlist(coefs[!sapply(coefs, is.null)])
}

het_results <- rbind(
  cbind(dimension = "Race", extract_coef(models$het_race)),
  cbind(dimension = "Age", extract_coef(models$het_age)),
  cbind(dimension = "Marital", extract_coef(models$het_marst))
)

if (nrow(het_results) > 0) {
  het_results[, `:=`(
    ci_lo = coef - 1.96 * se,
    ci_hi = coef + 1.96 * se
  )]

  p5 <- ggplot(het_results, aes(x = coef, y = reorder(group, coef),
                                 xmin = ci_lo, xmax = ci_hi)) +
    geom_vline(xintercept = 0, linetype = "dashed", color = "grey50") +
    geom_errorbarh(height = 0.2, color = "#457B9D") +
    geom_point(size = 3, color = "#E63946") +
    facet_grid(dimension ~ ., scales = "free_y", space = "free_y") +
    labs(x = "Post × Mobilization Coefficient", y = "",
         title = "Heterogeneous Effects of Mobilization on Women's LFP",
         subtitle = "Individual-level regressions, state-clustered SEs") +
    theme_apep()

  ggsave(file.path(fig_dir, "fig5_heterogeneity.pdf"), p5,
         width = 7, height = 5.5, device = "pdf")
}


## --------------------------------------------------------------------------
## Figure 6: Occupational Transitions
## --------------------------------------------------------------------------

cat("Figure 6: Occupational transitions\n")

# Cross-sectional occupation distribution by gender and year
occ_dist <- indiv_panel[!is.na(occ_score), .(
  mean_occ = weighted.mean(occ_score, perwt, na.rm = TRUE),
  p25 = quantile(occ_score, 0.25),
  p75 = quantile(occ_score, 0.75),
  n = .N
), by = .(year, female)]
occ_dist[, Gender := fifelse(female == 1, "Women", "Men")]

p6 <- ggplot(indiv_panel[!is.na(occ_score) & occ_score > 0],
             aes(x = occ_score, fill = fifelse(female == 1, "Women", "Men"))) +
  geom_density(alpha = 0.5) +
  scale_fill_manual(values = pal_gender, name = "") +
  facet_wrap(~ year) +
  labs(x = "Occupation Score (Duncan SEI)", y = "Density",
       title = "Distribution of Occupation Scores by Gender",
       subtitle = "Conditional on labor force participation") +
  theme_apep()

ggsave(file.path(fig_dir, "fig6_transitions.pdf"), p6,
       width = 9, height = 5, device = "pdf")


## --------------------------------------------------------------------------
## Figure 7: Female LFP Map (State-Level Change)
## --------------------------------------------------------------------------

cat("Figure 7: Female LFP map\n")

if (has_shapes) {
  lf_map <- merge(states_sf, state_analysis[, .(statefip, d_lf_female)],
                  by = "statefip", all.x = TRUE)
  lf_map <- lf_map[!lf_map$statefip %in% c(2, 15), ]

  p7 <- ggplot(lf_map) +
    geom_sf(aes(fill = d_lf_female), color = "white", size = 0.2) +
    scale_fill_gradient2(low = "#457B9D", mid = "white", high = "#E63946",
                         midpoint = 0, name = "Change in\nFemale LFP") +
    labs(title = "Change in Female Labor Force Participation, 1940-1950",
         subtitle = "Red = increase, Blue = decrease",
         caption = "Source: IPUMS USA 1% samples") +
    theme_apep() +
    theme(axis.text = element_blank(), axis.ticks = element_blank(),
          panel.grid = element_blank())

  ggsave(file.path(fig_dir, "fig7_female_lf_map.pdf"), p7,
         width = 10, height = 6.5, device = "pdf")
}


## --------------------------------------------------------------------------
## Figure 8: Gender Gap Trends by Mobilization
## --------------------------------------------------------------------------

cat("Figure 8: Gender gap trends\n")

gap_trends <- state_gy[, .(
  lf_female = weighted.mean(mean_lf[female == 1], n[female == 1], na.rm = TRUE),
  lf_male = weighted.mean(mean_lf[female == 0], n[female == 0], na.rm = TRUE)
), by = year]
gap_trends[, lf_gap := lf_female - lf_male]

# Also by mobilization
gap_by_mob <- merge(state_gy, state_mob[, .(statefip, mob_quintile)], by = "statefip")
gap_mob_year <- gap_by_mob[, .(
  lf_female = weighted.mean(mean_lf[female == 1], n[female == 1], na.rm = TRUE),
  lf_male = weighted.mean(mean_lf[female == 0], n[female == 0], na.rm = TRUE)
), by = .(year, mob_quintile)]
gap_mob_year[, lf_gap := lf_female - lf_male]

p8 <- ggplot(gap_mob_year, aes(x = factor(year), y = lf_gap, group = mob_quintile, color = mob_quintile)) +
  geom_line(linewidth = 1) +
  geom_point(size = 3) +
  scale_color_viridis_d(option = "D", name = "Mobilization\nQuintile") +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey70") +
  labs(x = "Census Year", y = "LFP Gender Gap (Female - Male)",
       title = "Gender LFP Gap Over Time by Mobilization Quintile",
       subtitle = "Parallel trends in 1930-1940; convergence in 1940-1950") +
  theme_apep()

ggsave(file.path(fig_dir, "fig8_gender_gap_trends.pdf"), p8,
       width = 8, height = 5.5, device = "pdf")


## --------------------------------------------------------------------------
## Figure 9: Lee Bounds
## --------------------------------------------------------------------------

cat("Figure 9: Lee bounds\n")

lee_bounds <- robustness$lee_bounds
lb_valid <- lee_bounds[!is.na(coef) | !is.na(lower) | !is.na(upper)]
if (nrow(lb_valid) > 0) {
  # Melt with actual column names
  avail_cols <- intersect(c("coef", "lower", "upper"), names(lee_bounds))
  lb_plot <- melt(lee_bounds, id.vars = "trim",
                  measure.vars = avail_cols,
                  variable.name = "bound", value.name = "estimate")
  lb_plot <- lb_plot[!is.na(estimate)]
  lb_plot[, bound := fcase(bound == "coef", "Point Estimate",
                           bound == "lower", "Lower Bound",
                           bound == "upper", "Upper Bound")]

  p9 <- ggplot(lb_plot, aes(x = trim, y = estimate, color = bound)) +
    geom_line(linewidth = 1) +
    geom_point(size = 3) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
    scale_color_manual(values = c("Point Estimate" = "#E63946",
                                  "Lower Bound" = "#457B9D",
                                  "Upper Bound" = "#2A9D8F")) +
    labs(x = "Trimming Proportion", y = "Coefficient on Mobilization",
         title = "Lee (2009) Bounds for Selective Attrition",
         subtitle = "Bounds on mobilization effect under different trimming assumptions",
         color = "") +
    theme_apep()

  ggsave(file.path(fig_dir, "fig9_lee_bounds.pdf"), p9,
         width = 7, height = 5, device = "pdf")
} else {
  cat("  Lee bounds all NA (collinear with state FE) -- skipping figure\n")
  # Create placeholder
  p9 <- ggplot() + annotate("text", x = 0.5, y = 0.5, label = "Lee bounds not estimable\n(state-level variable absorbed by state FE)") + theme_void()
  ggsave(file.path(fig_dir, "fig9_lee_bounds.pdf"), p9, width = 7, height = 5, device = "pdf")
}


## --------------------------------------------------------------------------
## Figure 10: Robustness Summary
## --------------------------------------------------------------------------

cat("Figure 10: Robustness\n")

# Collect robustness coefficients
rob_coefs <- data.table(
  spec = c("Baseline (state)", "Pop-weighted", "Unweighted",
           "Non-South", "Trimmed (10-90%)", "Indiv age 25-45", "Indiv age 18-35"),
  coef = c(coef(models$s2_lf)["mob_std"],
           coef(robustness$weighted)["mob_std"],
           coef(robustness$unweighted)["mob_std"],
           coef(robustness$nonsouth)["mob_std"],
           coef(robustness$trimmed)["mob_std"],
           NA_real_, NA_real_),
  se = c(se(models$s2_lf)["mob_std"],
         se(robustness$weighted)["mob_std"],
         se(robustness$unweighted)["mob_std"],
         se(robustness$nonsouth)["mob_std"],
         se(robustness$trimmed)["mob_std"],
         NA_real_, NA_real_)
)

# Try to add individual-level robustness
tryCatch({
  rob_coefs[spec == "Indiv age 25-45", `:=`(
    coef = coef(robustness$indiv_25_45)["post:mob_std"],
    se = se(robustness$indiv_25_45)["post:mob_std"]
  )]
  rob_coefs[spec == "Indiv age 18-35", `:=`(
    coef = coef(robustness$indiv_18_35)["post:mob_std"],
    se = se(robustness$indiv_18_35)["post:mob_std"]
  )]
}, error = function(e) cat("Some individual robustness coefs unavailable\n"))

rob_coefs <- rob_coefs[!is.na(coef)]
rob_coefs[, `:=`(ci_lo = coef - 1.96 * se, ci_hi = coef + 1.96 * se)]

p10 <- ggplot(rob_coefs, aes(x = coef, y = reorder(spec, coef),
                              xmin = ci_lo, xmax = ci_hi)) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "grey50") +
  geom_errorbarh(height = 0.2, color = "#457B9D") +
  geom_point(size = 3, color = "#E63946") +
  labs(x = "Effect of Mobilization on Change in Female LFP", y = "",
       title = "Robustness: Mobilization Effect Across Specifications",
       subtitle = "Point estimates with 95% confidence intervals") +
  theme_apep()

ggsave(file.path(fig_dir, "fig10_robustness.pdf"), p10,
       width = 7, height = 5, device = "pdf")


cat("\n✓ All figures saved to", fig_dir, "\n")
