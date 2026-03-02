## ============================================================================
## 05_figures.R — All Figures for apep_0469 v2
## Missing Men, Rising Women (Census Linking Project Panel)
## ============================================================================
## Two-panel design: MEN linked individually (14M), WIVES tracked through
## husbands' households (5.6M couples).

source("code/00_packages.R")

data_dir <- "data"
fig_dir <- "figures"
dir.create(fig_dir, showWarnings = FALSE)

panel <- readRDS(file.path(data_dir, "linked_panel_40_50.rds"))
couples <- readRDS(file.path(data_dir, "couples_panel_40_50.rds"))
state_analysis <- readRDS(file.path(data_dir, "state_analysis.rds"))
state_mob <- readRDS(file.path(data_dir, "state_mobilization.rds"))
models <- readRDS(file.path(data_dir, "main_models.rds"))
robustness <- readRDS(file.path(data_dir, "robustness.rds"))
het <- readRDS(file.path(data_dir, "heterogeneity.rds"))

panel[, region := fcase(
  statefip_1940 %in% c(9, 23, 25, 33, 34, 36, 42, 44, 50), "Northeast",
  statefip_1940 %in% c(17, 18, 19, 20, 26, 27, 29, 31, 38, 39, 46, 55), "Midwest",
  statefip_1940 %in% c(1, 5, 10, 11, 12, 13, 21, 22, 24, 28, 37, 40, 45, 47, 48, 51, 54), "South",
  default = "West"
)]

couples[, region := fcase(
  statefip_1940 %in% c(9, 23, 25, 33, 34, 36, 42, 44, 50), "Northeast",
  statefip_1940 %in% c(17, 18, 19, 20, 26, 27, 29, 31, 38, 39, 46, 55), "Midwest",
  statefip_1940 %in% c(1, 5, 10, 11, 12, 13, 21, 22, 24, 28, 37, 40, 45, 47, 48, 51, 54), "South",
  default = "West"
)]

pal_gender <- c("Wives" = "#E63946", "Husbands" = "#457B9D")


## --------------------------------------------------------------------------
## Figure 1: Mobilization Map
## --------------------------------------------------------------------------

cat("--- Figure 1: Mobilization Map ---\n")

shp_file <- file.path(data_dir, "counties_1940.rds")
if (file.exists(shp_file)) {
  counties <- readRDS(shp_file)
  # Dissolve counties to states using sf aggregate
  state_shp <- sf::st_sf(
    STATEFP = sort(unique(counties$STATEFP)),
    geometry = do.call(c, lapply(split(sf::st_geometry(counties), counties$STATEFP), sf::st_union))
  )
  state_shp$statefip <- as.integer(state_shp$STATEFP)

  state_map <- merge(state_shp, state_mob[, .(statefip, mobilization_rate, mob_quintile)],
                     by = "statefip")

  p1 <- ggplot(state_map) +
    geom_sf(aes(fill = mobilization_rate), color = "white", linewidth = 0.2) +
    scale_fill_viridis_c(option = "D", name = "Mobilization\nRate",
                         labels = scales::percent_format(accuracy = 1)) +
    labs(title = "WWII Mobilization Rates by State",
         subtitle = "CenSoc Army Enlistees per 1940 Male Population (18-44)",
         caption = "Source: CenSoc WWII Enlistment Records + IPUMS Full-Count 1940 Census") +
    theme_void() +
    theme(legend.position = "right",
          plot.title = element_text(face = "bold", size = 13),
          plot.subtitle = element_text(size = 10, color = "grey40"),
          plot.caption = element_text(size = 7, color = "grey60"))

  ggsave(file.path(fig_dir, "fig1_mobilization_map.pdf"), p1,
         width = 8, height = 5.5)
  cat("Saved fig1_mobilization_map.pdf\n")
} else {
  cat("WARNING: counties_1940.rds not found, skipping map\n")
}


## --------------------------------------------------------------------------
## Figure 2: Within-Person/Couple Delta-LF by Mobilization Quintile
## --------------------------------------------------------------------------

cat("--- Figure 2: Within-Person Changes by Quintile ---\n")

# Men's changes by quintile
men_q <- panel[, .(
  d_lf = mean(d_in_lf, na.rm = TRUE),
  se_lf = sd(d_in_lf, na.rm = TRUE) / sqrt(.N),
  n = .N
), by = mob_quintile]
men_q[, Gender := "Husbands"]

# Wives' changes by quintile (from couples panel)
wives_q <- couples[, .(
  d_lf = mean(wife_d_in_lf, na.rm = TRUE),
  se_lf = sd(wife_d_in_lf, na.rm = TRUE) / sqrt(.N),
  n = .N
), by = mob_quintile]
wives_q[, Gender := "Wives"]

quintile_data <- rbind(men_q, wives_q)
quintile_data[, mob_quintile := factor(mob_quintile, levels = paste0("Q", 1:5))]

p2 <- ggplot(quintile_data, aes(x = mob_quintile, y = d_lf, fill = Gender)) +
  geom_col(position = position_dodge(0.7), width = 0.6) +
  geom_errorbar(aes(ymin = d_lf - 1.96 * se_lf, ymax = d_lf + 1.96 * se_lf),
                position = position_dodge(0.7), width = 0.15) +
  scale_fill_manual(values = pal_gender) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
  labs(title = "Within-Person Change in Labor Force Participation (1940-1950)",
       subtitle = "By WWII mobilization intensity quintile",
       x = "Mobilization Quintile (Q1 = Lowest)", y = "Mean Change in LFP",
       caption = "Husbands: ABE-linked individual panel (14M). Wives: household-matched couples panel (5.6M).") +
  theme(legend.position = "bottom",
        plot.caption = element_text(size = 7, color = "grey60"))

ggsave(file.path(fig_dir, "fig2_within_person_by_quintile.pdf"), p2,
       width = 7, height = 5)
cat("Saved fig2_within_person_by_quintile.pdf\n")


## --------------------------------------------------------------------------
## Figure 3: Decomposition — Aggregate vs Within-Person vs Composition
## --------------------------------------------------------------------------

cat("--- Figure 3: Decomposition ---\n")

decomp <- readRDS(file.path(data_dir, "decomposition.rds"))

decomp_df <- data.table(
  Component = c("Aggregate\nChange", "Within-Person/\nCouple Change", "Compositional\nResidual"),
  Wives = c(decomp$aggregate$d_f_lf,
            decomp$within$wife_d_lf,
            decomp$compositional$d_f_lf),
  Husbands = c(decomp$aggregate$d_m_lf,
               decomp$within$m_d_lf,
               decomp$aggregate$d_m_lf - decomp$within$m_d_lf)
)

decomp_long <- melt(decomp_df, id.vars = "Component",
                     variable.name = "Gender", value.name = "Change")
decomp_long[, Component := factor(Component,
  levels = c("Aggregate\nChange", "Within-Person/\nCouple Change", "Compositional\nResidual"))]

p3 <- ggplot(decomp_long, aes(x = Component, y = Change, fill = Gender)) +
  geom_col(position = position_dodge(0.7), width = 0.6) +
  geom_text(aes(label = sprintf("%+.3f", Change),
                vjust = ifelse(Change >= 0, -0.5, 1.5)),
            position = position_dodge(0.7), size = 2.8) +
  scale_fill_manual(values = pal_gender) +
  geom_hline(yintercept = 0, linetype = "dashed") +
  labs(title = "Decomposition of LFP Changes (1940-1950)",
       subtitle = "Aggregate = Within-Person/Couple + Compositional (Entry/Exit/Mortality)",
       y = "Change in Labor Force Participation Rate",
       caption = "Within-person from ABE-linked panel; Aggregate from full-count cross-sections") +
  theme(axis.title.x = element_blank(),
        plot.caption = element_text(size = 7, color = "grey60"))

ggsave(file.path(fig_dir, "fig3_decomposition.pdf"), p3, width = 7, height = 5)
cat("Saved fig3_decomposition.pdf\n")


## --------------------------------------------------------------------------
## Figure 4: Binned Scatter — Wife ΔLF on Mobilization (FWL)
## --------------------------------------------------------------------------

cat("--- Figure 4: Binned Scatter (Wives) ---\n")

fwl_y <- feols(wife_d_in_lf ~ sp_age_1940 + I(sp_age_1940^2) +
               sp_educ_years_1940 + husband_age_1940 | region,
               data = couples)
fwl_x <- feols(mob_std ~ sp_age_1940 + I(sp_age_1940^2) +
               sp_educ_years_1940 + husband_age_1940 | region,
               data = couples)

scatter_dt <- data.table(
  resid_y = residuals(fwl_y),
  resid_x = residuals(fwl_x)
)

scatter_dt[, bin := cut(resid_x, breaks = 20, labels = FALSE)]
binned <- scatter_dt[, .(mean_y = mean(resid_y), mean_x = mean(resid_x),
                          se_y = sd(resid_y) / sqrt(.N)), by = bin]

p4 <- ggplot(binned, aes(x = mean_x, y = mean_y)) +
  geom_point(size = 3, color = "#E63946") +
  geom_errorbar(aes(ymin = mean_y - 1.96 * se_y, ymax = mean_y + 1.96 * se_y),
                width = 0, color = "#E63946", alpha = 0.5) +
  geom_smooth(method = "lm", se = TRUE, color = "grey30", linewidth = 0.8) +
  labs(title = "Wives' Within-Couple LFP Change and Mobilization",
       subtitle = "Binned scatter, Frisch-Waugh-Lovell residuals (5.6M couples)",
       x = "Mobilization Rate (residualized)", y = "Wife's DLFP 1940-1950 (residualized)",
       caption = "Controls: wife age, wife age-sq, wife education, husband age, region FE") +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey60") +
  theme(plot.caption = element_text(size = 7, color = "grey60"))

ggsave(file.path(fig_dir, "fig4_binned_scatter.pdf"), p4, width = 6, height = 5)
cat("Saved fig4_binned_scatter.pdf\n")


## --------------------------------------------------------------------------
## Figure 5: Randomization Inference Distribution
## --------------------------------------------------------------------------

cat("--- Figure 5: RI Distribution ---\n")

ri_dt <- data.table(beta = robustness$ri$perm_betas)
obs_beta <- robustness$ri$observed

p5 <- ggplot(ri_dt, aes(x = beta)) +
  geom_histogram(bins = 50, fill = "grey70", color = "white") +
  geom_vline(xintercept = obs_beta, color = "#E63946", linewidth = 1.2) +
  annotate("text", x = obs_beta, y = Inf, vjust = -0.5,
           label = sprintf("Observed = %.4f\np < %.3f", obs_beta, robustness$ri$p_value),
           color = "#E63946", size = 3.5, fontface = "bold") +
  labs(title = "Randomization Inference: Permutation Distribution",
       subtitle = sprintf("Wives' LFP change, %d permutations of state mobilization",
                           length(robustness$ri$perm_betas)),
       x = "Permuted Coefficient (mob_std)", y = "Count") +
  theme(plot.subtitle = element_text(size = 10))

ggsave(file.path(fig_dir, "fig5_ri_distribution.pdf"), p5, width = 6, height = 4.5)
cat("Saved fig5_ri_distribution.pdf\n")


## --------------------------------------------------------------------------
## Figure 6: Heterogeneity Forest Plot (Wives)
## --------------------------------------------------------------------------

cat("--- Figure 6: Heterogeneity Forest ---\n")

# Build forest from heterogeneity results
forest_pieces <- list()

# Overall
if (!is.null(models$w3_lf)) {
  forest_pieces[["overall"]] <- data.table(
    Group = "Overall", Subgroup = "All Wives",
    beta = coef(models$w3_lf)["mob_std"],
    se = sqrt(vcov(models$w3_lf)["mob_std", "mob_std"]))
}

# By race
if (!is.null(het$race) && nrow(het$race[!is.na(beta)]) > 0) {
  race_dt <- het$race[!is.na(beta)]
  setnames(race_dt, "sp_race_cat_1940", "Subgroup", skip_absent = TRUE)
  if (!"Subgroup" %in% names(race_dt)) {
    race_dt[, Subgroup := as.character(get(names(race_dt)[1]))]
  }
  race_dt[, Group := "Race"]
  forest_pieces[["race"]] <- race_dt[, .(Group, Subgroup, beta, se)]
}

# By pre-war LF
if (!is.null(het$prelf)) {
  prelf_dt <- copy(het$prelf)
  prelf_dt[, Subgroup := ifelse(wife_pre_lf == 1, "In LF (1940)", "Out of LF (1940)")]
  prelf_dt[, Group := "Pre-War Status"]
  forest_pieces[["prelf"]] <- prelf_dt[!is.na(beta), .(Group, Subgroup, beta, se)]
}

# By age
if (!is.null(het$age) && nrow(het$age[!is.na(beta)]) > 0) {
  age_dt <- het$age[!is.na(beta)]
  setnames(age_dt, "wife_age_bin", "Subgroup", skip_absent = TRUE)
  age_dt[, Group := "Age Group"]
  forest_pieces[["age"]] <- age_dt[, .(Group, Subgroup, beta, se)]
}

forest_dt <- rbindlist(forest_pieces, fill = TRUE)
forest_dt[, `:=`(lo = beta - 1.96 * se, hi = beta + 1.96 * se)]
forest_dt[, Subgroup := factor(Subgroup, levels = rev(Subgroup))]

p6 <- ggplot(forest_dt, aes(x = beta, y = Subgroup)) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "grey50") +
  geom_point(size = 2.5, color = "#E63946") +
  geom_errorbarh(aes(xmin = lo, xmax = hi), height = 0.15, color = "#E63946") +
  labs(title = "Effect of Mobilization on Wives' LFP Change",
       subtitle = "Heterogeneity by subgroup, 95% CI (couples panel)",
       x = "Coefficient on Mobilization Rate (std.)", y = NULL) +
  theme(axis.text.y = element_text(size = 10))

ggsave(file.path(fig_dir, "fig6_heterogeneity_forest.pdf"), p6,
       width = 6.5, height = 4.5)
cat("Saved fig6_heterogeneity_forest.pdf\n")


## --------------------------------------------------------------------------
## Figure 7: Leave-One-Out Influence (State-Level)
## --------------------------------------------------------------------------

cat("--- Figure 7: LOO Influence ---\n")

loo_dt <- data.table(
  state_idx = seq_along(robustness$loo$betas),
  beta = robustness$loo$betas
)

p7 <- ggplot(loo_dt, aes(x = state_idx, y = beta)) +
  geom_point(size = 1.5, color = "#457B9D") +
  geom_hline(yintercept = 0, linetype = "dashed", color = "red") +
  geom_hline(yintercept = mean(loo_dt$beta), color = "#457B9D", linewidth = 0.8) +
  labs(title = "Leave-One-Out Sensitivity (State-Level)",
       subtitle = sprintf("All %d coefficients %s",
                           nrow(loo_dt),
                           ifelse(robustness$loo$all_same_sign, "same sign", "mixed sign")),
       x = "State Dropped", y = "Coefficient on Mobilization Rate")

ggsave(file.path(fig_dir, "fig7_loo_influence.pdf"), p7, width = 6, height = 4)
cat("Saved fig7_loo_influence.pdf\n")


## --------------------------------------------------------------------------
## Figure 8: Transition Matrix — Wife LF Status Changes (Couples Panel)
## --------------------------------------------------------------------------

cat("--- Figure 8: LF Transition Matrix (Wives) ---\n")

transition <- couples[, .(n = .N),
  by = .(LF_1940 = ifelse(sp_in_lf_1940 == 1, "In LF", "Out of LF"),
         LF_1950 = ifelse(sp_in_lf_1950 == 1, "In LF", "Out of LF"),
         Mobilization = ifelse(mob_std > 0, "High Mob.", "Low Mob."))]

transition[, pct := n / sum(n), by = .(LF_1940, Mobilization)]

p8 <- ggplot(transition, aes(x = LF_1940, y = LF_1950, fill = pct)) +
  geom_tile() +
  geom_text(aes(label = sprintf("%.1f%%", 100 * pct)), size = 4) +
  scale_fill_gradient(low = "white", high = "#E63946", name = "Share") +
  facet_wrap(~Mobilization) +
  labs(title = "Labor Force Transitions (Wives, 1940-1950)",
       subtitle = "Wives tracked through husbands' Census Linking Project linkages",
       x = "Wife's LF Status in 1940", y = "Wife's LF Status in 1950") +
  theme(panel.grid = element_blank(),
        plot.subtitle = element_text(size = 10, color = "grey40"))

ggsave(file.path(fig_dir, "fig8_lf_transitions.pdf"), p8, width = 8, height = 4.5)
cat("Saved fig8_lf_transitions.pdf\n")


## --------------------------------------------------------------------------
## Figure 9: Husband-Wife LF Change Correlation
## --------------------------------------------------------------------------

cat("--- Figure 9: Husband-Wife Dynamics ---\n")

# Aggregate: share of couples where husband exits LF vs wife enters LF
hw_dynamics <- couples[, .(
  husband_exit_rate = mean(husband_d_in_lf == -1, na.rm = TRUE),
  wife_entry_rate = mean(wife_d_in_lf == 1, na.rm = TRUE),
  n = .N
), by = mob_quintile]
hw_dynamics[, mob_quintile := factor(mob_quintile, levels = paste0("Q", 1:5))]

hw_long <- melt(hw_dynamics[, .(mob_quintile, `Husband Exits LF` = husband_exit_rate,
                                 `Wife Enters LF` = wife_entry_rate)],
                id.vars = "mob_quintile", variable.name = "Transition", value.name = "Rate")

p9 <- ggplot(hw_long, aes(x = mob_quintile, y = Rate, fill = Transition)) +
  geom_col(position = position_dodge(0.7), width = 0.6) +
  scale_fill_manual(values = c("Husband Exits LF" = "#457B9D", "Wife Enters LF" = "#E63946")) +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1)) +
  labs(title = "Husband-Wife Labor Force Transitions by Mobilization",
       subtitle = "Share of couples where husband exits or wife enters labor force (1940-1950)",
       x = "Mobilization Quintile", y = "Share of Couples") +
  theme(legend.position = "bottom")

ggsave(file.path(fig_dir, "fig9_hw_dynamics.pdf"), p9, width = 7, height = 5)
cat("Saved fig9_hw_dynamics.pdf\n")


cat("\n=== All figures saved to figures/ ===\n")
