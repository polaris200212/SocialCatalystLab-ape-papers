## ============================================================================
## 05_figures.R — All Figures for apep_0469 v3
## Missing Men, Rising Women (MLP Three-Wave Panel)
## ============================================================================
## New figures: Pre-trend event study, mobilization validation scatter,
## linkage rate scatter, finer age-bin placebo, IPW sensitivity forest.
## All figures regenerated with MLP data + 95% CIs.
## ============================================================================

source("code/00_packages.R")

data_dir <- "data"
fig_dir <- "figures"
dir.create(fig_dir, showWarnings = FALSE)

panel <- readRDS(file.path(data_dir, "linked_panel_40_50.rds"))
setDT(panel); alloc.col(panel, ncol(panel) + 20L)
couples <- readRDS(file.path(data_dir, "couples_panel_40_50.rds"))
setDT(couples); alloc.col(couples, ncol(couples) + 10L)
state_analysis <- readRDS(file.path(data_dir, "state_analysis.rds"))
setDT(state_analysis); alloc.col(state_analysis, ncol(state_analysis) + 10L)
state_mob <- readRDS(file.path(data_dir, "state_mobilization.rds"))
setDT(state_mob); alloc.col(state_mob, ncol(state_mob) + 10L)
models <- readRDS(file.path(data_dir, "main_models.rds"))
robustness <- readRDS(file.path(data_dir, "robustness.rds"))
het <- readRDS(file.path(data_dir, "heterogeneity.rds"))
decomp <- readRDS(file.path(data_dir, "decomposition.rds"))

assign_region <- function(dt, state_col = "statefip_1940") {
  dt[, region := fcase(
    get(state_col) %in% c(9, 23, 25, 33, 34, 36, 42, 44, 50), "Northeast",
    get(state_col) %in% c(17, 18, 19, 20, 26, 27, 29, 31, 38, 39, 46, 55), "Midwest",
    get(state_col) %in% c(1, 5, 10, 11, 12, 13, 21, 22, 24, 28, 37, 40, 45, 47, 48, 51, 54), "South",
    default = "West")]
  invisible(dt)
}
assign_region(panel)
assign_region(couples)

pal_gender <- c("Wives" = "#E63946", "Husbands" = "#457B9D")


## --------------------------------------------------------------------------
## Figure 1: Mobilization Map
## --------------------------------------------------------------------------

cat("--- Figure 1: Mobilization Map ---\n")

shp_file <- file.path(data_dir, "counties_1940.rds")
if (file.exists(shp_file)) {
  counties <- readRDS(shp_file)
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
## Figure 2: Pre-Trend Event Study (NEW — most important figure)
## --------------------------------------------------------------------------

cat("--- Figure 2: Pre-Trend Event Study ---\n")

# Extract coefficients from event study models
es_data <- data.table(
  Gender = rep(c("Husbands", "Wives"), each = 2),
  Period = rep(c("1930-1940\n(Pre-Trend)", "1940-1950\n(Post-WWII)"), 2),
  beta = c(
    coef(models$es_men)["mob_std"],
    coef(models$es_men)["mob_std"] + coef(models$es_men)["mob_std:post"],
    coef(models$es_wives)["mob_std"],
    coef(models$es_wives)["mob_std"] + coef(models$es_wives)["mob_std:post"]
  ),
  se = c(
    sqrt(vcov(models$es_men)["mob_std", "mob_std"]),
    # SE for sum of coefficients
    sqrt(vcov(models$es_men)["mob_std", "mob_std"] +
         vcov(models$es_men)["mob_std:post", "mob_std:post"] +
         2 * vcov(models$es_men)["mob_std", "mob_std:post"]),
    sqrt(vcov(models$es_wives)["mob_std", "mob_std"]),
    sqrt(vcov(models$es_wives)["mob_std", "mob_std"] +
         vcov(models$es_wives)["mob_std:post", "mob_std:post"] +
         2 * vcov(models$es_wives)["mob_std", "mob_std:post"])
  )
)
es_data[, `:=`(lo = beta - 1.96 * se, hi = beta + 1.96 * se)]
es_data[, Period := factor(Period, levels = c("1930-1940\n(Pre-Trend)", "1940-1950\n(Post-WWII)"))]

p2 <- ggplot(es_data, aes(x = Period, y = beta, color = Gender, shape = Gender)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
  geom_point(size = 4, position = position_dodge(0.3)) +
  geom_errorbar(aes(ymin = lo, ymax = hi), width = 0.12,
                position = position_dodge(0.3), linewidth = 0.8) +
  scale_color_manual(values = pal_gender) +
  labs(title = "Effect of Mobilization on LFP Change: Pre-Trend vs Post-WWII",
       subtitle = "3-wave MLP panel (1930-1940-1950), 95% CIs, state-clustered SEs",
       x = NULL, y = "Coefficient on Mobilization Rate (std.)",
       caption = "Pre-trend: ΔLF(1930→1940); Post-WWII: ΔLF(1940→1950). Controls + region FE.") +
  theme(legend.position = "bottom",
        plot.caption = element_text(size = 7, color = "grey60"))

ggsave(file.path(fig_dir, "fig2_event_study.pdf"), p2, width = 6, height = 5)
cat("Saved fig2_event_study.pdf\n")


## --------------------------------------------------------------------------
## Figure 3: Within-Person/Couple ΔLF by Mobilization Quintile
## --------------------------------------------------------------------------

cat("--- Figure 3: Within-Person Changes by Quintile ---\n")

men_q <- panel[female_1940 == 0, .(
  d_lf = mean(d_in_lf, na.rm = TRUE),
  se_lf = sd(d_in_lf, na.rm = TRUE) / sqrt(.N),
  n = .N
), by = mob_quintile]
men_q[, Gender := "Husbands"]

wives_q <- couples[, .(
  d_lf = mean(wife_d_in_lf, na.rm = TRUE),
  se_lf = sd(wife_d_in_lf, na.rm = TRUE) / sqrt(.N),
  n = .N
), by = mob_quintile]
wives_q[, Gender := "Wives"]

quintile_data <- rbind(men_q, wives_q)
quintile_data[, mob_quintile := factor(mob_quintile, levels = paste0("Q", 1:5))]

p3 <- ggplot(quintile_data, aes(x = mob_quintile, y = d_lf, fill = Gender)) +
  geom_col(position = position_dodge(0.7), width = 0.6) +
  geom_errorbar(aes(ymin = d_lf - 1.96 * se_lf, ymax = d_lf + 1.96 * se_lf),
                position = position_dodge(0.7), width = 0.15) +
  scale_fill_manual(values = pal_gender) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
  labs(title = "Within-Person Change in Labor Force Participation (1940-1950)",
       subtitle = "By WWII mobilization intensity quintile",
       x = "Mobilization Quintile (Q1 = Lowest)", y = "Mean Change in LFP",
       caption = "MLP-linked individual panel (men) and household-matched couples panel (wives).") +
  theme(legend.position = "bottom",
        plot.caption = element_text(size = 7, color = "grey60"))

ggsave(file.path(fig_dir, "fig3_within_person_by_quintile.pdf"), p3,
       width = 7, height = 5)
cat("Saved fig3_within_person_by_quintile.pdf\n")


## --------------------------------------------------------------------------
## Figure 4: Married-Women Decomposition (NEW — replaces all-women version)
## --------------------------------------------------------------------------

cat("--- Figure 4: Married-Women Decomposition ---\n")

decomp_df <- data.table(
  Component = c("Aggregate\nMarried Women", "Within-Couple\nChange", "Compositional\nResidual"),
  Wives = c(decomp$married_women$d_agg,
            decomp$married_women$d_within,
            decomp$married_women$gap),
  `All Women\n(comparison)` = c(decomp$all_women$d_agg,
                                 decomp$all_women$d_within,
                                 decomp$all_women$gap)
)

decomp_long <- melt(decomp_df, id.vars = "Component",
                     variable.name = "Population", value.name = "Change")
decomp_long[, Component := factor(Component,
  levels = c("Aggregate\nMarried Women", "Within-Couple\nChange", "Compositional\nResidual"))]

p4 <- ggplot(decomp_long, aes(x = Component, y = Change, fill = Population)) +
  geom_col(position = position_dodge(0.7), width = 0.6) +
  geom_text(aes(label = sprintf("%+.4f", Change),
                vjust = ifelse(Change >= 0, -0.5, 1.5)),
            position = position_dodge(0.7), size = 2.8) +
  scale_fill_manual(values = c("Wives" = "#E63946", "All Women\n(comparison)" = "#A8DADC")) +
  geom_hline(yintercept = 0, linetype = "dashed") +
  labs(title = "Decomposition: Married Women vs All Women (1940-1950)",
       subtitle = "Aggregate = Within-Couple + Compositional (entry/exit/mortality/marriage transitions)",
       y = "Change in Labor Force Participation Rate",
       caption = "Within-couple from MLP-linked panel; Aggregate from full-count cross-sections") +
  theme(axis.title.x = element_blank(),
        plot.caption = element_text(size = 7, color = "grey60"))

ggsave(file.path(fig_dir, "fig4_decomposition.pdf"), p4, width = 7, height = 5)
cat("Saved fig4_decomposition.pdf\n")


## --------------------------------------------------------------------------
## Figure 5: Binned Scatter — Wife ΔLF on Mobilization (FWL)
## --------------------------------------------------------------------------

cat("--- Figure 5: Binned Scatter (Wives) ---\n")

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

p5 <- ggplot(binned, aes(x = mean_x, y = mean_y)) +
  geom_point(size = 3, color = "#E63946") +
  geom_errorbar(aes(ymin = mean_y - 1.96 * se_y, ymax = mean_y + 1.96 * se_y),
                width = 0, color = "#E63946", alpha = 0.5) +
  geom_smooth(method = "lm", se = TRUE, color = "grey30", linewidth = 0.8) +
  labs(title = "Wives' Within-Couple LFP Change and Mobilization",
       subtitle = sprintf("Binned scatter, FWL residuals (%s couples)",
                           format(nrow(couples), big.mark = ",")),
       x = "Mobilization Rate (residualized)", y = "Wife's ΔLFP 1940-1950 (residualized)",
       caption = "Controls: wife age, wife age², wife education, husband age, region FE") +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey60") +
  theme(plot.caption = element_text(size = 7, color = "grey60"))

ggsave(file.path(fig_dir, "fig5_binned_scatter.pdf"), p5, width = 6, height = 5)
cat("Saved fig5_binned_scatter.pdf\n")


## --------------------------------------------------------------------------
## Figure 6: Mobilization Validation Scatter (NEW)
## --------------------------------------------------------------------------

cat("--- Figure 6: Mobilization Validation ---\n")

tryCatch({
  mob_valid <- robustness$mob_validation$data
  r15 <- robustness$mob_validation$model
  r2_val <- summary(r15)$r.squared

  p6 <- ggplot(mob_valid, aes(x = mob_std, y = mover_rate)) +
    geom_point(aes(size = n), color = "#457B9D", alpha = 0.7) +
    geom_smooth(method = "lm", se = TRUE, color = "#E63946", linewidth = 0.8) +
    ggrepel::geom_text_repel(
      data = mob_valid[order(-abs(mob_std))][1:5],
      aes(label = statefip), size = 2.5, color = "grey40", max.overlaps = 10) +
    scale_size_continuous(name = "N (men)", labels = scales::comma) +
    labs(title = "Mobilization Validation: CenSoc Enlistment vs Mover Rate",
         subtitle = sprintf("State-level, R² = %.3f", r2_val),
         x = "Mobilization Rate (CenSoc, standardized)",
         y = "Interstate Mover Rate (MLP panel, 1940-1950)") +
    theme(legend.position = "bottom",
          plot.caption = element_text(size = 7))

  ggsave(file.path(fig_dir, "fig6_mob_validation.pdf"), p6, width = 6, height = 5)
  cat("Saved fig6_mob_validation.pdf\n")
}, error = function(e) cat(sprintf("  Skipped: %s\n", e$message)))


## --------------------------------------------------------------------------
## Figure 7: Linkage Rate vs Mobilization (NEW — should be null)
## --------------------------------------------------------------------------

cat("--- Figure 7: Linkage Rate vs Mobilization ---\n")

tryCatch({
  lr_data <- robustness$linkage_vs_mob$data
  r16 <- robustness$linkage_vs_mob$model
  p_val <- summary(r16)$coefficients["mob_std", 4]

  p7 <- ggplot(lr_data, aes(x = mob_std, y = link_rate_men)) +
    geom_point(size = 3, color = "#457B9D") +
    geom_smooth(method = "lm", se = TRUE, color = "#E63946", linewidth = 0.8) +
    labs(title = "Linkage Rate vs Mobilization (Selection Test)",
         subtitle = sprintf("State-level, p = %.3f (should be insignificant)", p_val),
         x = "Mobilization Rate (standardized)",
         y = "MLP Linkage Rate (men, 1940-1950)") +
    theme(plot.caption = element_text(size = 7))

  ggsave(file.path(fig_dir, "fig7_linkage_vs_mob.pdf"), p7, width = 6, height = 5)
  cat("Saved fig7_linkage_vs_mob.pdf\n")
}, error = function(e) cat(sprintf("  Skipped: %s\n", e$message)))


## --------------------------------------------------------------------------
## Figure 8: Randomization Inference Distribution
## --------------------------------------------------------------------------

cat("--- Figure 8: RI Distribution ---\n")

ri_dt <- data.table(beta = robustness$ri$perm_betas)
obs_beta <- robustness$ri$observed

p8 <- ggplot(ri_dt, aes(x = beta)) +
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

ggsave(file.path(fig_dir, "fig8_ri_distribution.pdf"), p8, width = 6, height = 4.5)
cat("Saved fig8_ri_distribution.pdf\n")


## --------------------------------------------------------------------------
## Figure 9: Heterogeneity + IPW Forest Plot (Wives)
## --------------------------------------------------------------------------

cat("--- Figure 9: Heterogeneity + IPW Forest ---\n")

forest_pieces <- list()

# Overall baseline
if (!is.null(models$w3_lf)) {
  forest_pieces[["overall"]] <- data.table(
    Group = "Baseline", Subgroup = "All Wives (w3)",
    beta = coef(models$w3_lf)["mob_std"],
    se = sqrt(vcov(models$w3_lf)["mob_std", "mob_std"]))
}

# IPW-weighted (NEW)
if (!is.null(robustness$ipw_weighted$wives)) {
  ipw_w <- robustness$ipw_weighted$wives
  forest_pieces[["ipw"]] <- data.table(
    Group = "IPW", Subgroup = "IPW-Weighted Wives",
    beta = coef(ipw_w)["mob_std"],
    se = sqrt(vcov(ipw_w)["mob_std", "mob_std"]))
}

# State controls (NEW)
if (!is.null(models$w5_lf)) {
  forest_pieces[["state_ctrl"]] <- data.table(
    Group = "Controls", Subgroup = "State Baseline Controls (w5)",
    beta = coef(models$w5_lf)["mob_std"],
    se = sqrt(vcov(models$w5_lf)["mob_std", "mob_std"]))
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

p9 <- ggplot(forest_dt, aes(x = beta, y = Subgroup)) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "grey50") +
  geom_point(size = 2.5, color = "#E63946") +
  geom_errorbarh(aes(xmin = lo, xmax = hi), height = 0.15, color = "#E63946") +
  labs(title = "Effect of Mobilization on Wives' LFP Change",
       subtitle = "Heterogeneity + specification sensitivity, 95% CI",
       x = "Coefficient on Mobilization Rate (std.)", y = NULL) +
  theme(axis.text.y = element_text(size = 9))

ggsave(file.path(fig_dir, "fig9_heterogeneity_forest.pdf"), p9,
       width = 7, height = 5.5)
cat("Saved fig9_heterogeneity_forest.pdf\n")


## --------------------------------------------------------------------------
## Figure 10: Finer Age-Bin Placebo (NEW)
## --------------------------------------------------------------------------

cat("--- Figure 10: Age-Bin Placebo ---\n")

tryCatch({
  abp <- robustness$age_bin_placebo
  abp <- abp[!is.na(beta)]
  abp[, `:=`(lo = beta - 1.96 * se, hi = beta + 1.96 * se)]
  abp[, wife_age_fine := factor(wife_age_fine,
    levels = c("18-30", "31-45", "46-50", "51-55", "56+"))]

  # Color: treatment-age bins blue, placebo bins red
  abp[, bin_type := ifelse(wife_age_fine %in% c("18-30", "31-45"), "Treatment Age", "Placebo Age")]

  p10 <- ggplot(abp, aes(x = wife_age_fine, y = beta, color = bin_type)) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
    geom_point(size = 3) +
    geom_errorbar(aes(ymin = lo, ymax = hi), width = 0.15, linewidth = 0.8) +
    scale_color_manual(values = c("Treatment Age" = "#E63946", "Placebo Age" = "#457B9D"),
                       name = NULL) +
    labs(title = "Mobilization Effect by Wife's Age Group (Placebo Test)",
         subtitle = "Wives 46+ in 1940 should show near-zero effect",
         x = "Wife's Age in 1940", y = "Coefficient on Mobilization Rate (std.)") +
    theme(legend.position = "bottom")

  ggsave(file.path(fig_dir, "fig10_age_bin_placebo.pdf"), p10, width = 6, height = 5)
  cat("Saved fig10_age_bin_placebo.pdf\n")
}, error = function(e) cat(sprintf("  Skipped: %s\n", e$message)))


## --------------------------------------------------------------------------
## Figure 11: Leave-One-Out Influence (State-Level)
## --------------------------------------------------------------------------

cat("--- Figure 11: LOO Influence ---\n")

loo_dt <- data.table(
  state_idx = seq_along(robustness$loo$betas),
  beta = robustness$loo$betas
)

p11 <- ggplot(loo_dt, aes(x = state_idx, y = beta)) +
  geom_point(size = 1.5, color = "#457B9D") +
  geom_hline(yintercept = 0, linetype = "dashed", color = "red") +
  geom_hline(yintercept = mean(loo_dt$beta), color = "#457B9D", linewidth = 0.8) +
  labs(title = "Leave-One-Out Sensitivity (State-Level)",
       subtitle = sprintf("All %d coefficients %s",
                           nrow(loo_dt),
                           ifelse(robustness$loo$all_same_sign, "same sign", "mixed sign")),
       x = "State Dropped", y = "Coefficient on Mobilization Rate")

ggsave(file.path(fig_dir, "fig11_loo_influence.pdf"), p11, width = 6, height = 4)
cat("Saved fig11_loo_influence.pdf\n")


## --------------------------------------------------------------------------
## Figure 12: LF Transition Matrix — Wives (Couples Panel)
## --------------------------------------------------------------------------

cat("--- Figure 12: LF Transition Matrix (Wives) ---\n")

transition <- couples[, .(n = .N),
  by = .(LF_1940 = ifelse(sp_in_lf_1940 == 1, "In LF", "Out of LF"),
         LF_1950 = ifelse(sp_in_lf_1950 == 1, "In LF", "Out of LF"),
         Mobilization = ifelse(mob_std > 0, "High Mob.", "Low Mob."))]
transition[, pct := n / sum(n), by = .(LF_1940, Mobilization)]

p12 <- ggplot(transition, aes(x = LF_1940, y = LF_1950, fill = pct)) +
  geom_tile() +
  geom_text(aes(label = sprintf("%.1f%%", 100 * pct)), size = 4) +
  scale_fill_gradient(low = "white", high = "#E63946", name = "Share") +
  facet_wrap(~Mobilization) +
  labs(title = "Labor Force Transitions (Wives, 1940-1950)",
       subtitle = "Wives tracked through husbands' MLP-linked households",
       x = "Wife's LF Status in 1940", y = "Wife's LF Status in 1950") +
  theme(panel.grid = element_blank(),
        plot.subtitle = element_text(size = 10, color = "grey40"))

ggsave(file.path(fig_dir, "fig12_lf_transitions.pdf"), p12, width = 8, height = 4.5)
cat("Saved fig12_lf_transitions.pdf\n")


## --------------------------------------------------------------------------
## Figure 13: Husband-Wife LF Change by Quintile
## --------------------------------------------------------------------------

cat("--- Figure 13: Husband-Wife Dynamics ---\n")

hw_dynamics <- couples[, .(
  husband_exit_rate = mean(husband_d_in_lf == -1, na.rm = TRUE),
  wife_entry_rate = mean(wife_d_in_lf == 1, na.rm = TRUE),
  n = .N
), by = mob_quintile]
hw_dynamics[, mob_quintile := factor(mob_quintile, levels = paste0("Q", 1:5))]

hw_long <- melt(hw_dynamics[, .(mob_quintile, `Husband Exits LF` = husband_exit_rate,
                                 `Wife Enters LF` = wife_entry_rate)],
                id.vars = "mob_quintile", variable.name = "Transition", value.name = "Rate")

p13 <- ggplot(hw_long, aes(x = mob_quintile, y = Rate, fill = Transition)) +
  geom_col(position = position_dodge(0.7), width = 0.6) +
  scale_fill_manual(values = c("Husband Exits LF" = "#457B9D", "Wife Enters LF" = "#E63946")) +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1)) +
  labs(title = "Husband-Wife Labor Force Transitions by Mobilization",
       subtitle = "Share of couples where husband exits or wife enters labor force (1940-1950)",
       x = "Mobilization Quintile", y = "Share of Couples") +
  theme(legend.position = "bottom")

ggsave(file.path(fig_dir, "fig13_hw_dynamics.pdf"), p13, width = 7, height = 5)
cat("Saved fig13_hw_dynamics.pdf\n")


cat("\n=== All figures saved to figures/ ===\n")
