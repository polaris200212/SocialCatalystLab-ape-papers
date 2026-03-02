## ═══════════════════════════════════════════════════════════════════════════
## 05_figures.R — All figures for the paper
## Paper: Does Piped Water Build Human Capital? Evidence from India's JJM
## ═══════════════════════════════════════════════════════════════════════════

script_dir <- dirname(sys.frame(1)$ofile %||% ".")
if (script_dir == ".") script_dir <- getwd()
source(file.path(script_dir, "00_packages.R"))
load(file.path(data_dir, "analysis_data.RData"))
load(file.path(data_dir, "main_results.RData"))
load(file.path(data_dir, "robustness_results.RData"))
if (file.exists(file.path(data_dir, "viirs_panel.RData"))) {
  load(file.path(data_dir, "viirs_panel.RData"))
}

dir.create(fig_dir, recursive = TRUE, showWarnings = FALSE)

# ═══════════════════════════════════════════════════════════════════════════
# FIGURE 1: Distribution of baseline water infrastructure deficit
# ═══════════════════════════════════════════════════════════════════════════

fig1 <- ggplot(df_analysis, aes(x = water_gap)) +
  geom_histogram(binwidth = 5, fill = "#2166AC", color = "white", alpha = 0.8) +
  geom_vline(xintercept = median(df_analysis$water_gap, na.rm = TRUE),
    linetype = "dashed", color = "#B2182B", linewidth = 0.8) +
  annotate("text", x = median(df_analysis$water_gap, na.rm = TRUE) + 3,
    y = Inf, vjust = 2, hjust = 0, label = "Median",
    color = "#B2182B", size = 3.5) +
  labs(
    title = "Distribution of Baseline Water Infrastructure Deficit",
    subtitle = "100 minus NFHS-4 improved drinking water coverage (%)",
    x = "Water Infrastructure Deficit (percentage points)",
    y = "Number of Districts"
  ) +
  scale_x_continuous(breaks = seq(0, 100, 20))

ggsave(file.path(fig_dir, "fig1_water_gap_distribution.pdf"),
  fig1, width = 7, height = 5)
cat("Figure 1 saved\n")

# ═══════════════════════════════════════════════════════════════════════════
# FIGURE 2: Binned scatter — Water gap vs Δ Education
# ═══════════════════════════════════════════════════════════════════════════

# Residualize both variables against state FEs and controls
res_y <- feols(d_fem_school_attend ~ literacy_rate + pop_sc_share +
  pop_st_share + log_pop + child_share + agr_worker_share +
  improved_sanitation_nfhs4 + hh_electricity_nfhs4 | state_id,
  data = df_analysis)
res_x <- feols(water_gap ~ literacy_rate + pop_sc_share +
  pop_st_share + log_pop + child_share + agr_worker_share +
  improved_sanitation_nfhs4 + hh_electricity_nfhs4 | state_id,
  data = df_analysis)

bin_data <- data.table(
  x_resid = residuals(res_x),
  y_resid = residuals(res_y)
)
# Create 20 equal-sized bins
bin_data[, bin := cut(x_resid, breaks = quantile(x_resid, probs = seq(0, 1, 0.05)),
  include.lowest = TRUE)]
bin_means <- bin_data[!is.na(bin), .(
  x_mean = mean(x_resid),
  y_mean = mean(y_resid),
  y_se = sd(y_resid) / sqrt(.N),
  n = .N
), by = bin]

fig2 <- ggplot(bin_means, aes(x = x_mean, y = y_mean)) +
  geom_point(size = 2.5, color = "#2166AC") +
  geom_errorbar(aes(ymin = y_mean - 1.96 * y_se, ymax = y_mean + 1.96 * y_se),
    width = 0.5, color = "#2166AC", alpha = 0.5) +
  geom_smooth(method = "lm", se = FALSE, color = "#B2182B", linewidth = 0.8) +
  labs(
    title = "Water Infrastructure Deficit and Female School Attendance",
    subtitle = "Binned scatter, residualized on state FE and baseline controls",
    x = "Water Deficit (residualized, pp)",
    y = expression(Delta ~ "Female School Attendance (residualized, pp)")
  )

ggsave(file.path(fig_dir, "fig2_binscatter_education.pdf"),
  fig2, width = 7, height = 5)
cat("Figure 2 saved\n")

# ═══════════════════════════════════════════════════════════════════════════
# FIGURE 3: First stage — Water gap vs Δ Improved water
# ═══════════════════════════════════════════════════════════════════════════

res_yw <- feols(d_improved_water ~ literacy_rate + pop_sc_share +
  pop_st_share + log_pop + child_share + agr_worker_share +
  improved_sanitation_nfhs4 + hh_electricity_nfhs4 | state_id,
  data = df_analysis)

bin_fs <- data.table(
  x_resid = residuals(res_x),
  y_resid = residuals(res_yw)
)
bin_fs[, bin := cut(x_resid, breaks = quantile(x_resid, probs = seq(0, 1, 0.05)),
  include.lowest = TRUE)]
bin_fs_means <- bin_fs[!is.na(bin), .(
  x_mean = mean(x_resid), y_mean = mean(y_resid),
  y_se = sd(y_resid) / sqrt(.N), n = .N
), by = bin]

fig3 <- ggplot(bin_fs_means, aes(x = x_mean, y = y_mean)) +
  geom_point(size = 2.5, color = "#4DAF4A") +
  geom_errorbar(aes(ymin = y_mean - 1.96 * y_se, ymax = y_mean + 1.96 * y_se),
    width = 0.5, color = "#4DAF4A", alpha = 0.5) +
  geom_smooth(method = "lm", se = FALSE, color = "#B2182B", linewidth = 0.8) +
  labs(
    title = "First Stage: Water Deficit Predicts Water Access Improvement",
    subtitle = "Binned scatter, residualized on state FE and baseline controls",
    x = "Baseline Water Deficit (residualized, pp)",
    y = expression(Delta ~ "Improved Water Source (residualized, pp)")
  )

ggsave(file.path(fig_dir, "fig3_first_stage_binscatter.pdf"),
  fig3, width = 7, height = 5)
cat("Figure 3 saved\n")

# ═══════════════════════════════════════════════════════════════════════════
# FIGURE 4: Multi-outcome coefficient plot
# ═══════════════════════════════════════════════════════════════════════════

base_controls <- "literacy_rate + pop_sc_share + pop_st_share + log_pop +
  child_share + agr_worker_share + improved_sanitation_nfhs4 + hh_electricity_nfhs4"

outcomes <- c(
  "d_fem_school_attend", "d_women_10yr_school", "d_women_literate",
  "d_child_diarrhea", "d_child_stunted", "d_child_underweight",
  "d_inst_births", "d_anc_4visits"
)
outcome_labels <- c(
  "Female School\nAttendance", "Women 10+ Yrs\nSchooling", "Women\nLiteracy",
  "Child\nDiarrhea", "Child\nStunting", "Child\nUnderweight",
  "Institutional\nBirths", "ANC 4+\nVisits"
)
outcome_category <- c(
  rep("Education", 3), rep("Health", 3), rep("Maternal Care", 2)
)

coef_data <- data.table(
  outcome = character(), label = character(), category = character(),
  beta = numeric(), se = numeric(), pval = numeric()
)

for (i in seq_along(outcomes)) {
  fit <- tryCatch({
    feols(as.formula(paste(outcomes[i], "~ water_gap +", base_controls, "| state_id")),
      data = df_analysis, cluster = ~state_id)
  }, error = function(e) NULL)
  if (!is.null(fit)) {
    coef_data <- rbind(coef_data, data.table(
      outcome = outcomes[i], label = outcome_labels[i],
      category = outcome_category[i],
      beta = coef(fit)["water_gap"],
      se = se(fit)["water_gap"],
      pval = fixest::pvalue(fit)["water_gap"]
    ))
  }
}

coef_data[, label := factor(label, levels = rev(outcome_labels))]
coef_data[, sig := fifelse(pval < 0.01, "***",
  fifelse(pval < 0.05, "**", fifelse(pval < 0.1, "*", "")))]

fig4 <- ggplot(coef_data, aes(x = beta, y = label, color = category)) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "grey50") +
  geom_point(size = 3) +
  geom_errorbarh(aes(xmin = beta - 1.96 * se, xmax = beta + 1.96 * se),
    height = 0.2, linewidth = 0.7) +
  geom_text(aes(label = sig), vjust = -0.8, size = 4, show.legend = FALSE) +
  scale_color_manual(values = c(
    "Education" = "#2166AC", "Health" = "#B2182B", "Maternal Care" = "#4DAF4A")) +
  labs(
    title = "Effect of Water Infrastructure Deficit on Human Capital",
    subtitle = "Reduced-form coefficient on baseline water gap, state FE + controls, clustered by state",
    x = expression("Coefficient on Water Gap (" * beta * ")"),
    y = "",
    color = "Domain"
  ) +
  theme(legend.position = "bottom")

ggsave(file.path(fig_dir, "fig4_coefficient_plot.pdf"),
  fig4, width = 8, height = 6)
cat("Figure 4 saved\n")

# ═══════════════════════════════════════════════════════════════════════════
# FIGURE 5: Placebo coefficient plot
# ═══════════════════════════════════════════════════════════════════════════

placebo_outcomes <- c("d_male_tobacco", "d_teen_pregnancy",
  "d_child_marriage", "d_health_insurance")
placebo_labels <- c("Male Tobacco\nUse", "Teen\nPregnancy",
  "Child\nMarriage", "Health\nInsurance")

placebo_data <- data.table(
  outcome = character(), label = character(),
  beta = numeric(), se = numeric(), pval = numeric()
)

for (i in seq_along(placebo_outcomes)) {
  fit <- tryCatch({
    feols(as.formula(paste(placebo_outcomes[i], "~ water_gap +", base_controls, "| state_id")),
      data = df_analysis, cluster = ~state_id)
  }, error = function(e) NULL)
  if (!is.null(fit)) {
    placebo_data <- rbind(placebo_data, data.table(
      outcome = placebo_outcomes[i], label = placebo_labels[i],
      beta = coef(fit)["water_gap"],
      se = se(fit)["water_gap"],
      pval = fixest::pvalue(fit)["water_gap"]
    ))
  }
}

placebo_data[, label := factor(label, levels = rev(placebo_labels))]

fig5 <- ggplot(placebo_data, aes(x = beta, y = label)) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "grey50") +
  geom_point(size = 3, color = "#762A83") +
  geom_errorbarh(aes(xmin = beta - 1.96 * se, xmax = beta + 1.96 * se),
    height = 0.2, linewidth = 0.7, color = "#762A83") +
  labs(
    title = "Placebo Tests: Water Gap Should Not Predict These Outcomes",
    subtitle = "Coefficient on baseline water gap, state FE + controls, clustered by state",
    x = expression("Coefficient on Water Gap (" * beta * ")"),
    y = ""
  )

ggsave(file.path(fig_dir, "fig5_placebo_tests.pdf"),
  fig5, width = 7, height = 4)
cat("Figure 5 saved\n")

# ═══════════════════════════════════════════════════════════════════════════
# FIGURE 6: Randomization inference distribution
# ═══════════════════════════════════════════════════════════════════════════

ri_data <- data.table(beta = robustness$ri$perm_betas)
actual <- robustness$ri$actual_beta

fig6 <- ggplot(ri_data, aes(x = beta)) +
  geom_histogram(bins = 50, fill = "grey70", color = "white") +
  geom_vline(xintercept = actual, color = "#B2182B", linewidth = 1) +
  annotate("text", x = actual, y = Inf, vjust = 2, hjust = -0.1,
    label = paste0("Actual β = ", round(actual, 4),
      "\nRI p = ", round(robustness$ri$ri_pvalue, 3)),
    color = "#B2182B", size = 3.5) +
  labs(
    title = "Randomization Inference: Permutation Distribution",
    subtitle = paste0(length(robustness$ri$perm_betas),
      " within-state permutations of water gap"),
    x = expression("Permuted " * beta),
    y = "Count"
  )

ggsave(file.path(fig_dir, "fig6_randomization_inference.pdf"),
  fig6, width = 7, height = 5)
cat("Figure 6 saved\n")

# ═══════════════════════════════════════════════════════════════════════════
# FIGURE 7: Leave-one-state-out stability
# ═══════════════════════════════════════════════════════════════════════════

loso_dt <- robustness$loso
loso_dt[, state := factor(state, levels = state[order(beta)])]

fig7 <- ggplot(loso_dt, aes(x = state, y = beta)) +
  geom_point(size = 2, color = "#2166AC") +
  geom_hline(yintercept = actual, linetype = "dashed", color = "#B2182B") +
  annotate("text", x = 1, y = actual, vjust = -0.5,
    label = "Full sample", color = "#B2182B", size = 3) +
  labs(
    title = "Leave-One-State-Out: Coefficient Stability",
    subtitle = "Each point drops one state from the estimation",
    x = "", y = expression(beta ~ "(water gap)")
  ) +
  theme(axis.text.x = element_text(angle = 90, hjust = 1, size = 6))

ggsave(file.path(fig_dir, "fig7_loso.pdf"),
  fig7, width = 10, height = 5)
cat("Figure 7 saved\n")

# ═══════════════════════════════════════════════════════════════════════════
# FIGURE 8: VIIRS nightlights event study (if available)
# ═══════════════════════════════════════════════════════════════════════════

if (exists("viirs_long")) {
  # Merge water_gap into VIIRS panel
  viirs_panel <- merge(viirs_long, df_analysis[, .(dist_id, water_gap, state_id,
    literacy_rate, pop_sc_share, pop_st_share, log_pop)],
    by = "dist_id", all.x = FALSE)

  # Create interaction terms: water_gap × year dummies
  viirs_panel[, year_f := factor(year)]
  viirs_panel[, post_jjm := as.integer(year >= 2019)]

  # Event study: water_gap × year interactions
  es_model <- feols(nightlights ~ i(year, water_gap, ref = 2018) +
    literacy_rate + pop_sc_share + pop_st_share + log_pop |
    dist_id + year, data = viirs_panel, cluster = ~state_id)

  # Extract coefficients for plot
  es_coefs <- as.data.table(coeftable(es_model))
  es_coefs[, year := as.integer(gsub("year::(\\d+):water_gap", "\\1",
    rownames(coeftable(es_model))))]
  es_coefs <- es_coefs[!is.na(year)]
  setnames(es_coefs, c("Estimate", "Std. Error"), c("beta", "se"))

  # Add reference year
  es_coefs <- rbind(es_coefs, data.table(
    beta = 0, se = 0, year = 2018,
    `t value` = 0, `Pr(>|t|)` = 1),
    fill = TRUE)

  fig8 <- ggplot(es_coefs, aes(x = year, y = beta)) +
    geom_vline(xintercept = 2018.5, linetype = "dashed", color = "grey50") +
    geom_hline(yintercept = 0, color = "grey80") +
    geom_ribbon(aes(ymin = beta - 1.96 * se, ymax = beta + 1.96 * se),
      fill = "#2166AC", alpha = 0.2) +
    geom_line(color = "#2166AC", linewidth = 0.8) +
    geom_point(size = 2, color = "#2166AC") +
    annotate("text", x = 2018.5, y = Inf, vjust = 2, hjust = -0.1,
      label = "JJM\nlaunched", size = 3, color = "grey40") +
    labs(
      title = "Nighttime Lights Event Study: Water Gap × Year",
      subtitle = "Districts with larger baseline water deficits, normalized to 2018",
      x = "Year",
      y = expression(beta[t] ~ "(water gap × year)")
    ) +
    scale_x_continuous(breaks = 2012:2023)

  ggsave(file.path(fig_dir, "fig8_viirs_event_study.pdf"),
    fig8, width = 8, height = 5)
  cat("Figure 8 saved\n")
}

cat("\n✓ All figures complete\n")
