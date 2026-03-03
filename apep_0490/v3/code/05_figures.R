###############################################################################
# 05_figures.R — Generate all figures
# Paper: Does Visibility Delay Frontier AI? (apep_0490 v3)
###############################################################################

source("00_packages.R")

cat("=== Loading data ===\n")
df <- fread(file.path(DATA_DIR, "rdd_sample.csv"))
full <- fread(file.path(DATA_DIR, "full_sample.csv"))

# Determine available outcomes
ADOPT_PRIMARY <- "frontier_adopted_18m"
if (!(ADOPT_PRIMARY %in% names(df))) ADOPT_PRIMARY <- "has_frontier_cite"
CITE_PRIMARY <- "ln_cite_3y"
if (!(CITE_PRIMARY %in% names(df))) CITE_PRIMARY <- "ln_cited_by_count"

# ============================================================================
# Figure 1: Submission Density Around Cutoff
# ============================================================================

cat("=== Figure 1: Submission Density ===\n")

fig1_data <- df[abs(run_var) <= 90]

p1 <- ggplot(fig1_data, aes(x = run_var)) +
  geom_histogram(binwidth = 2, fill = "steelblue", color = "white", alpha = 0.8) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "red", linewidth = 0.8) +
  annotate("text", x = -40, y = Inf, label = "Before cutoff\n(last in today's batch)",
           vjust = 1.5, hjust = 0.5, size = 3.5, color = "grey40") +
  annotate("text", x = 40, y = Inf, label = "After cutoff\n(first in tomorrow's batch)",
           vjust = 1.5, hjust = 0.5, size = 3.5, color = "grey40") +
  labs(
    x = "Minutes from 14:00 ET cutoff",
    y = "Number of submissions",
    title = "Submission Density Around the arXiv Daily Cutoff",
    subtitle = sprintf("AI/ML papers (%s), %d-%d",
                        paste(AI_CATEGORIES, collapse = ", "), YEAR_START, YEAR_END)
  ) +
  scale_x_continuous(breaks = seq(-90, 90, by = 15)) +
  theme_apep

ggsave(file.path(FIG_DIR, "fig1_density.pdf"), p1, width = 8, height = 5)
cat("Saved fig1_density.pdf\n")

# McCrary density plot
density_est <- rddensity(X = df$run_var, c = 0)
pdf(file.path(FIG_DIR, "fig1b_mccrary.pdf"), width = 8, height = 5)
rdplotdensity(density_est, df$run_var,
              title = "McCrary Density Test at 14:00 ET Cutoff",
              xlabel = "Minutes from cutoff",
              ylabel = "Density")
dev.off()
cat("Saved fig1b_mccrary.pdf\n")

# ============================================================================
# Figure 2: First Stage — Position Discontinuity
# ============================================================================

cat("=== Figure 2: First Stage ===\n")

if ("position_pctile" %in% names(df)) {
  bin_width <- 5
  fig2_data <- df[abs(run_var) <= 90]
  fig2_data[, bin := floor(run_var / bin_width) * bin_width + bin_width / 2]

  fig2_means <- fig2_data[, .(
    mean_position = mean(position_pctile, na.rm = TRUE),
    se_position = sd(position_pctile, na.rm = TRUE) / sqrt(.N),
    n = .N
  ), by = bin]

  p2 <- ggplot(fig2_means, aes(x = bin, y = mean_position)) +
    geom_point(aes(size = n), color = "steelblue", alpha = 0.8) +
    geom_errorbar(aes(ymin = mean_position - 1.96 * se_position,
                      ymax = mean_position + 1.96 * se_position),
                  width = 1, color = "steelblue", alpha = 0.5) +
    geom_vline(xintercept = 0, linetype = "dashed", color = "red", linewidth = 0.8) +
    geom_smooth(data = fig2_data[run_var < 0], aes(x = run_var, y = position_pctile),
                method = "loess", color = "darkblue", fill = "lightblue", alpha = 0.3) +
    geom_smooth(data = fig2_data[run_var > 0], aes(x = run_var, y = position_pctile),
                method = "loess", color = "darkblue", fill = "lightblue", alpha = 0.3) +
    labs(
      x = "Minutes from 14:00 ET cutoff",
      y = "Position percentile within announcement",
      title = "First Stage: Listing Position Jumps at the Cutoff",
      subtitle = "Papers submitted just after the cutoff are listed first in the next announcement"
    ) +
    scale_size_continuous(guide = "none") +
    scale_y_continuous(labels = percent) +
    theme_apep

  ggsave(file.path(FIG_DIR, "fig2_first_stage.pdf"), p2, width = 8, height = 5)
  cat("Saved fig2_first_stage.pdf\n")
}

# ============================================================================
# Figure 3: RDD Plot — Frontier Adoption (PRIMARY)
# ============================================================================

cat("=== Figure 3: Frontier Adoption RDD ===\n")

if (ADOPT_PRIMARY %in% names(df)) {
  bin_width <- 5
  fig3_data <- df[abs(run_var) <= 90 & !is.na(get(ADOPT_PRIMARY))]
  fig3_data[, bin := floor(run_var / bin_width) * bin_width + bin_width / 2]

  fig3_means <- fig3_data[, .(
    mean_y = mean(get(ADOPT_PRIMARY), na.rm = TRUE),
    se_y = sd(get(ADOPT_PRIMARY), na.rm = TRUE) / sqrt(.N),
    n = .N
  ), by = bin]

  y_label <- switch(ADOPT_PRIMARY,
    "frontier_adopted_18m" = "Pr(Frontier lab citation within 18 months)",
    "has_frontier_cite" = "Pr(Any frontier lab citation)",
    ADOPT_PRIMARY
  )

  p3 <- ggplot(fig3_means, aes(x = bin, y = mean_y)) +
    geom_point(aes(size = n), color = "darkorange", alpha = 0.8) +
    geom_errorbar(aes(ymin = mean_y - 1.96 * se_y,
                      ymax = mean_y + 1.96 * se_y),
                  width = 1, color = "darkorange", alpha = 0.5) +
    geom_vline(xintercept = 0, linetype = "dashed", color = "red", linewidth = 0.8) +
    geom_smooth(data = fig3_data[run_var < 0], aes(x = run_var, y = get(ADOPT_PRIMARY)),
                method = "loess", color = "darkorange4", fill = "bisque", alpha = 0.3) +
    geom_smooth(data = fig3_data[run_var > 0], aes(x = run_var, y = get(ADOPT_PRIMARY)),
                method = "loess", color = "darkorange4", fill = "bisque", alpha = 0.3) +
    labs(
      x = "Minutes from 14:00 ET cutoff",
      y = y_label,
      title = "Frontier Lab Adoption at the arXiv Cutoff",
      subtitle = "Probability of citation by Google/DeepMind, OpenAI, Meta/FAIR, Anthropic, or xAI"
    ) +
    scale_size_continuous(guide = "none") +
    theme_apep

  ggsave(file.path(FIG_DIR, "fig3_adoption_rdd.pdf"), p3, width = 8, height = 5)
  cat("Saved fig3_adoption_rdd.pdf\n")

  # rdplot version
  y_clean <- df[[ADOPT_PRIMARY]]
  x_clean <- df$run_var
  valid <- !is.na(y_clean) & !is.na(x_clean)

  pdf(file.path(FIG_DIR, "fig3b_rdplot_adoption.pdf"), width = 8, height = 5)
  rdplot(y = y_clean[valid], x = x_clean[valid], c = 0,
         title = "RDD: Frontier Lab Adoption at the arXiv Cutoff",
         x.label = "Minutes from 14:00 ET cutoff",
         y.label = y_label)
  dev.off()
  cat("Saved fig3b_rdplot_adoption.pdf\n")
}

# ============================================================================
# Figure 4: RDD Plot — Citations (SECONDARY)
# ============================================================================

cat("=== Figure 4: Citation RDD Plot ===\n")

if (CITE_PRIMARY %in% names(df)) {
  bin_width <- 5
  fig4_data <- df[abs(run_var) <= 90 & !is.na(get(CITE_PRIMARY))]
  fig4_data[, bin := floor(run_var / bin_width) * bin_width + bin_width / 2]

  fig4_means <- fig4_data[, .(
    mean_y = mean(get(CITE_PRIMARY), na.rm = TRUE),
    se_y = sd(get(CITE_PRIMARY), na.rm = TRUE) / sqrt(.N),
    n = .N
  ), by = bin]

  y_label_cite <- switch(CITE_PRIMARY,
    "ln_cite_3y" = "Log(3-year citations + 1)",
    "ln_cited_by_count" = "Log(total citations + 1)",
    CITE_PRIMARY
  )

  p4 <- ggplot(fig4_means, aes(x = bin, y = mean_y)) +
    geom_point(aes(size = n), color = "steelblue", alpha = 0.8) +
    geom_errorbar(aes(ymin = mean_y - 1.96 * se_y,
                      ymax = mean_y + 1.96 * se_y),
                  width = 1, color = "steelblue", alpha = 0.5) +
    geom_vline(xintercept = 0, linetype = "dashed", color = "red", linewidth = 0.8) +
    geom_smooth(data = fig4_data[run_var < 0], aes(x = run_var, y = get(CITE_PRIMARY)),
                method = "loess", color = "darkblue", fill = "lightblue", alpha = 0.3) +
    geom_smooth(data = fig4_data[run_var > 0], aes(x = run_var, y = get(CITE_PRIMARY)),
                method = "loess", color = "darkblue", fill = "lightblue", alpha = 0.3) +
    labs(
      x = "Minutes from 14:00 ET cutoff",
      y = y_label_cite,
      title = "Citations at the arXiv Daily Cutoff",
      subtitle = "General citation impact of listing position"
    ) +
    scale_size_continuous(guide = "none") +
    theme_apep

  ggsave(file.path(FIG_DIR, "fig4_rdd_citations.pdf"), p4, width = 8, height = 5)
  cat("Saved fig4_rdd_citations.pdf\n")

  pdf(file.path(FIG_DIR, "fig4b_rdplot_citations.pdf"), width = 8, height = 5)
  y_c <- df[[CITE_PRIMARY]]
  x_c <- df$run_var
  v <- !is.na(y_c) & !is.na(x_c)
  rdplot(y = y_c[v], x = x_c[v], c = 0,
         title = "RDD: Citations at the arXiv Daily Cutoff",
         x.label = "Minutes from 14:00 ET cutoff",
         y.label = y_label_cite)
  dev.off()
  cat("Saved fig4b_rdplot_citations.pdf\n")
}

# ============================================================================
# Figure 5: Survival Curves — Adoption by Side of Cutoff
# ============================================================================

cat("=== Figure 5: Survival Curves ===\n")

if ("adoption_lag_days" %in% names(df)) {
  # Get optimal bandwidth
  rdd_tmp <- tryCatch(
    rdrobust(y = df[[ADOPT_PRIMARY]][!is.na(df[[ADOPT_PRIMARY]])],
             x = df$run_var[!is.na(df[[ADOPT_PRIMARY]])], c = 0),
    error = function(e) NULL
  )
  h_opt <- if (!is.null(rdd_tmp)) rdd_tmp$bws["h", "left"] else 30

  df_surv <- df[abs(run_var) <= h_opt]

  # Construct survival data: time to first industry citation
  df_surv[, surv_time := fifelse(
    has_industry_cite == 1 & !is.na(adoption_lag_days) & adoption_lag_days > 0,
    pmin(adoption_lag_days, 365 * 3),
    365 * 3
  )]
  df_surv[, surv_event := as.integer(has_industry_cite == 1 & !is.na(adoption_lag_days) & adoption_lag_days > 0)]
  df_surv[, side := fifelse(after_cutoff == 1, "After cutoff (first listed)", "Before cutoff (last listed)")]

  surv_fit <- survfit(Surv(surv_time, surv_event) ~ side, data = df_surv)

  # Extract survival data for ggplot
  surv_data <- data.table(
    time = surv_fit$time,
    surv = surv_fit$surv,
    group = rep(names(surv_fit$strata), surv_fit$strata)
  )
  surv_data[, group := gsub("side=", "", group)]

  # Convert survival to cumulative adoption (1 - S(t))
  surv_data[, adoption := 1 - surv]

  p5 <- ggplot(surv_data, aes(x = time / 30.44, y = adoption, color = group)) +
    geom_step(linewidth = 1) +
    geom_vline(xintercept = 12, linetype = "dotted", color = "grey60") +
    geom_vline(xintercept = 18, linetype = "dotted", color = "grey60") +
    annotate("text", x = 12, y = 0, label = "12m", vjust = -0.5, hjust = -0.2, size = 3, color = "grey40") +
    annotate("text", x = 18, y = 0, label = "18m", vjust = -0.5, hjust = -0.2, size = 3, color = "grey40") +
    scale_color_manual(values = c("After cutoff (first listed)" = "darkorange",
                                   "Before cutoff (last listed)" = "steelblue")) +
    labs(
      x = "Months since publication",
      y = "Cumulative probability of industry adoption",
      title = "Industry Adoption Speed by Listing Position",
      subtitle = sprintf("Papers within ±%.0f minutes of the 14:00 ET cutoff", h_opt),
      color = ""
    ) +
    coord_cartesian(xlim = c(0, 36)) +
    theme_apep +
    theme(legend.position = "bottom")

  ggsave(file.path(FIG_DIR, "fig5_survival.pdf"), p5, width = 8, height = 5.5)
  cat("Saved fig5_survival.pdf\n")
}

# ============================================================================
# Figure 6: Multi-Outcome Coefficient Plot
# ============================================================================

cat("=== Figure 6: Multi-Outcome Coefficient Plot ===\n")

adopt_file <- file.path(TAB_DIR, "adoption_results.csv")
cite_file <- file.path(TAB_DIR, "citation_results.csv")

if (file.exists(adopt_file) || file.exists(cite_file)) {
  all_results <- list()

  if (file.exists(adopt_file)) {
    adopt_res <- fread(adopt_file)
    all_results <- c(all_results, list(adopt_res))
  }
  if (file.exists(cite_file)) {
    cite_res <- fread(cite_file)
    all_results <- c(all_results, list(cite_res))
  }

  combined <- rbindlist(all_results, fill = TRUE)

  # Select key outcomes
  key_outcomes <- c("frontier_adopted_18m", "has_frontier_cite", "frontier_cite_share",
                     "has_industry_cite", "adopted_18m",
                     "ln_cite_3y", "ln_cited_by_count")
  selected <- combined[outcome %in% key_outcomes]

  if (nrow(selected) > 0) {
    outcome_labels <- c(
      "frontier_adopted_18m" = "Frontier adoption (18m)",
      "has_frontier_cite" = "Any frontier citation",
      "frontier_cite_share" = "Frontier cite share",
      "has_industry_cite" = "Any industry citation",
      "adopted_18m" = "Industry adoption (18m)",
      "ln_cite_3y" = "Log(3y citations)",
      "ln_cited_by_count" = "Log(total citations)"
    )

    selected[, label := outcome_labels[outcome]]
    selected[, label := factor(label, levels = rev(outcome_labels[names(outcome_labels) %in% outcome]))]
    selected[, type := fifelse(outcome %in% c("ln_cite_3y", "ln_cited_by_count"), "Citation", "Adoption")]

    p6 <- ggplot(selected, aes(x = coef_robust, y = label, color = type)) +
      geom_point(size = 3) +
      geom_errorbarh(aes(xmin = ci_robust_lower, xmax = ci_robust_upper), height = 0.2) +
      geom_vline(xintercept = 0, linetype = "dashed", color = "grey50") +
      scale_color_manual(values = c("Adoption" = "darkorange", "Citation" = "steelblue")) +
      labs(
        x = "RDD estimate (robust, with 95% CI)",
        y = "",
        title = "Multi-Outcome RDD Estimates at the arXiv Cutoff",
        subtitle = "Adoption outcomes (orange) vs. citation outcomes (blue)",
        color = ""
      ) +
      theme_apep +
      theme(legend.position = "bottom")

    ggsave(file.path(FIG_DIR, "fig6_multi_outcome.pdf"), p6, width = 8, height = 5.5)
    cat("Saved fig6_multi_outcome.pdf\n")
  }
}

# ============================================================================
# Figure 7: Bandwidth Sensitivity
# ============================================================================

cat("=== Figure 7: Bandwidth Sensitivity ===\n")

bw_file <- file.path(TAB_DIR, "bandwidth_sensitivity.csv")
if (file.exists(bw_file)) {
  bw_df <- fread(bw_file)

  for (out_var in unique(bw_df$outcome)) {
    bw_sub <- bw_df[outcome == out_var]
    suffix <- gsub("[^a-z0-9]", "_", tolower(out_var))

    p7 <- ggplot(bw_sub, aes(x = bandwidth, y = coef)) +
      geom_point(size = 3, color = "steelblue") +
      geom_errorbar(aes(ymin = ci_lower, ymax = ci_upper), width = 2, color = "steelblue") +
      geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
      labs(
        x = "Bandwidth (minutes)",
        y = "RDD estimate (robust)",
        title = sprintf("Bandwidth Sensitivity: %s", out_var)
      ) +
      theme_apep

    ggsave(file.path(FIG_DIR, sprintf("fig7_bw_%s.pdf", suffix)), p7, width = 7, height = 5)
  }
  cat("Saved fig7_bw_*.pdf\n")
}

# ============================================================================
# Figure 8: Placebo Cutoffs
# ============================================================================

cat("=== Figure 8: Placebo Cutoffs ===\n")

placebo_file <- file.path(TAB_DIR, "placebo_cutoffs.csv")
if (file.exists(placebo_file)) {
  placebo_df <- fread(placebo_file)

  for (out_var in unique(placebo_df$outcome)) {
    pl_sub <- placebo_df[outcome == out_var]
    suffix <- gsub("[^a-z0-9]", "_", tolower(out_var))

    p8 <- ggplot(pl_sub, aes(x = cutoff_hour, y = coef, color = is_real, shape = is_real)) +
      geom_point(size = 3) +
      geom_errorbar(aes(ymin = coef - 1.96 * se, ymax = coef + 1.96 * se), width = 0.3) +
      geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
      scale_color_manual(values = c("TRUE" = "red", "FALSE" = "steelblue"), guide = "none") +
      scale_shape_manual(values = c("TRUE" = 17, "FALSE" = 16), guide = "none") +
      labs(
        x = "Cutoff hour (ET)",
        y = "RDD estimate",
        title = sprintf("Placebo Cutoffs: %s", out_var),
        subtitle = "Red triangle = real cutoff (14:00); blue = placebo"
      ) +
      scale_x_continuous(breaks = seq(10, 18, by = 1)) +
      theme_apep

    ggsave(file.path(FIG_DIR, sprintf("fig8_placebo_%s.pdf", suffix)), p8, width = 7, height = 5)
  }
  cat("Saved fig8_placebo_*.pdf\n")
}

# ============================================================================
# Figure 9: Year-by-Year Estimates
# ============================================================================

cat("=== Figure 9: Year-by-Year ===\n")

year_file <- file.path(TAB_DIR, "year_by_year.csv")
if (file.exists(year_file) && file.info(year_file)$size > 10) {
  year_df <- fread(year_file)
  if (nrow(year_df) > 0) {
    p9 <- ggplot(year_df, aes(x = year, y = coef)) +
      geom_point(size = 3, color = "darkorange") +
      geom_errorbar(aes(ymin = ci_lower, ymax = ci_upper), width = 0.3, color = "darkorange") +
      geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
      labs(
        x = "Submission year",
        y = "RDD estimate (robust)",
        title = sprintf("Year-by-Year RDD Estimates: %s", unique(year_df$outcome)[1]),
        subtitle = "The adoption premium across the sample window"
      ) +
      scale_x_continuous(breaks = seq(YEAR_START, YEAR_END, by = 1)) +
      theme_apep +
      theme(axis.text.x = element_text(angle = 45, hjust = 1))

    ggsave(file.path(FIG_DIR, "fig9_yearly.pdf"), p9, width = 8, height = 5)
    cat("Saved fig9_yearly.pdf\n")
  }
}

# ============================================================================
# Figure 10: Covariate Balance
# ============================================================================

cat("=== Figure 10: Balance ===\n")

balance_file <- file.path(TAB_DIR, "balance_tests.csv")
if (file.exists(balance_file)) {
  bal_df <- fread(balance_file)
  # Exclude DoW indicators for cleaner plot
  bal_df <- bal_df[!grepl("^dow_", variable)]
  bal_df[, variable := factor(variable, levels = rev(variable))]

  p10 <- ggplot(bal_df, aes(x = coef, y = variable)) +
    geom_point(size = 3, color = "steelblue") +
    geom_errorbarh(aes(xmin = coef - 1.96 * se, xmax = coef + 1.96 * se),
                    height = 0.2, color = "steelblue") +
    geom_vline(xintercept = 0, linetype = "dashed", color = "red") +
    labs(
      x = "RDD estimate at cutoff",
      y = "",
      title = "Covariate Balance at the Cutoff",
      subtitle = "Pre-determined characteristics are smooth through the cutoff"
    ) +
    theme_apep

  ggsave(file.path(FIG_DIR, "fig10_balance.pdf"), p10, width = 7, height = 5)
  cat("Saved fig10_balance.pdf\n")
}

# ============================================================================
# Figure 11: Donut RDD
# ============================================================================

cat("=== Figure 11: Donut RDD ===\n")

donut_file <- file.path(TAB_DIR, "donut_rdd.csv")
if (file.exists(donut_file)) {
  donut_df <- fread(donut_file)

  for (out_var in unique(donut_df$outcome)) {
    d_sub <- donut_df[outcome == out_var]

    # Add baseline (no donut)
    y <- df[[out_var]]
    valid <- !is.na(y)
    if (sum(valid) >= 100) {
      rdd_base <- tryCatch(
        rdrobust(y = y[valid], x = df$run_var[valid], c = 0),
        error = function(e) NULL
      )
      if (!is.null(rdd_base)) {
        d_sub <- rbind(
          data.table(outcome = out_var, donut_minutes = 0,
                     coef = rdd_base$coef["Robust", ], se = rdd_base$se["Robust", ],
                     ci_lower = rdd_base$ci["Robust", 1], ci_upper = rdd_base$ci["Robust", 2],
                     p_value = rdd_base$pv["Robust", ],
                     n_eff = rdd_base$N_h[1] + rdd_base$N_h[2],
                     bw = rdd_base$bws["h", "left"]),
          d_sub, fill = TRUE
        )
      }
    }

    suffix <- gsub("[^a-z0-9]", "_", tolower(out_var))
    p11 <- ggplot(d_sub, aes(x = donut_minutes, y = coef)) +
      geom_point(size = 3, color = "steelblue") +
      geom_errorbar(aes(ymin = ci_lower, ymax = ci_upper), width = 0.5, color = "steelblue") +
      geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
      labs(
        x = "Donut hole (minutes excluded around cutoff)",
        y = "RDD estimate (robust)",
        title = sprintf("Donut RDD: %s", out_var)
      ) +
      scale_x_continuous(breaks = c(0, 2, 5, 10, 15)) +
      theme_apep

    ggsave(file.path(FIG_DIR, sprintf("fig11_donut_%s.pdf", suffix)), p11, width = 7, height = 5)
  }
  cat("Saved fig11_donut_*.pdf\n")
}

cat("\n=== All figures generated ===\n")
