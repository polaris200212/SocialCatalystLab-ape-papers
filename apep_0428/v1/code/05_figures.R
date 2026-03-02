## ============================================================
## 05_figures.R — All figure generation
## PMGSY 250 Threshold RDD — Tribal/Hill Areas
## ============================================================

source(file.path(dirname(sub("--file=", "", grep("--file=", commandArgs(FALSE), value=TRUE))), "00_packages.R"))

out_dir <- file.path(WORK_DIR, "data")
fig_dir <- file.path(WORK_DIR, "figures")

sample_A   <- readRDS(file.path(out_dir, "sample_250_A.rds"))
sample_500 <- readRDS(file.path(out_dir, "sample_500.rds"))
df_full    <- readRDS(file.path(out_dir, "analysis_full.rds"))

# ── Helper: RDD bin scatter ──────────────────────────────────
rdd_binscatter <- function(data, outcome, rv, cutoff = 0, nbins = 40,
                           title = "", ylab = "", xlab = "Population - 250") {
  d <- data[!is.na(data[[outcome]]) & !is.na(data[[rv]]), ]
  d$y <- d[[outcome]]
  d$x <- d[[rv]]

  # Trim extreme outliers for visualization
  q <- quantile(d$y, c(0.01, 0.99), na.rm = TRUE)
  d <- d[d$y >= q[1] & d$y <= q[2], ]

  # Create bins
  breaks_left  <- seq(min(d$x), cutoff, length.out = nbins / 2 + 1)
  breaks_right <- seq(cutoff, max(d$x), length.out = nbins / 2 + 1)
  d$bin <- cut(d$x, breaks = unique(c(breaks_left, breaks_right)),
               include.lowest = TRUE)

  bin_means <- d[, .(mean_y = mean(y, na.rm = TRUE),
                     mean_x = mean(x, na.rm = TRUE),
                     n = .N), by = bin]
  bin_means <- bin_means[!is.na(bin)]
  bin_means[, side := ifelse(mean_x < cutoff, "Below", "Above")]

  ggplot(bin_means, aes(x = mean_x, y = mean_y)) +
    geom_point(aes(color = side), size = 2.5, alpha = 0.8) +
    geom_smooth(data = bin_means[side == "Below"],
                method = "lm", se = TRUE, color = apep_colors[2],
                fill = apep_colors[2], alpha = 0.15, linewidth = 1) +
    geom_smooth(data = bin_means[side == "Above"],
                method = "lm", se = TRUE, color = apep_colors[1],
                fill = apep_colors[1], alpha = 0.15, linewidth = 1) +
    geom_vline(xintercept = cutoff, linetype = "dashed", color = "grey40") +
    scale_color_manual(values = c("Below" = apep_colors[2],
                                  "Above" = apep_colors[1]),
                       guide = "none") +
    labs(title = title, x = xlab, y = ylab) +
    theme_apep()
}

# ============================================================
# Figure 1: McCrary Density Test
# ============================================================

cat("Generating Figure 1: McCrary density...\n")

desig_A <- df_full[designated_A == TRUE & pop_01 >= 50 & pop_01 <= 500]

p_density <- ggplot(desig_A, aes(x = pop_01)) +
  geom_histogram(aes(y = after_stat(density)),
                 binwidth = 10, fill = "grey70", color = "white", linewidth = 0.2) +
  geom_vline(xintercept = 250, linetype = "dashed", color = "red3", linewidth = 0.8) +
  annotate("text", x = 260, y = Inf, label = "PMGSY Threshold\n(250)",
           vjust = 1.5, hjust = 0, size = 3.5, color = "red3") +
  labs(title = "Distribution of Village Population Around 250 Threshold",
       subtitle = "Special Category States (Census 2001)",
       x = "Village Population (Census 2001)",
       y = "Density") +
  theme_apep()

ggsave(file.path(fig_dir, "fig1_mccrary_density.pdf"), p_density,
       width = 8, height = 5)

# ============================================================
# Figure 2: RDD Plots — Main Outcomes
# ============================================================

cat("Generating Figure 2: RDD bin scatters...\n")

p2a <- rdd_binscatter(sample_A, "literacy_11", "rv_250",
                      title = "A. Literacy Rate (2011)", ylab = "Literacy Rate")
p2b <- rdd_binscatter(sample_A, "f_lit_11", "rv_250",
                      title = "B. Female Literacy Rate (2011)", ylab = "Female Literacy Rate")
p2c <- rdd_binscatter(sample_A, "nonag_share_11", "rv_250",
                      title = "C. Non-Agricultural Worker Share (2011)",
                      ylab = "Non-Ag Worker Share")
p2d <- rdd_binscatter(sample_A, "log_nl_post_viirs", "rv_250",
                      title = "D. Log Nightlights (VIIRS 2015-2023)",
                      ylab = "Log Nightlights")

p2_combined <- (p2a + p2b) / (p2c + p2d) +
  plot_annotation(
    title = "RDD Estimates at 250-Population Threshold",
    subtitle = "Special Category States — Bin scatter with local linear fit",
    theme = theme_apep()
  )

ggsave(file.path(fig_dir, "fig2_rdd_main.pdf"), p2_combined,
       width = 12, height = 10)

# ============================================================
# Figure 3: Gender Outcomes
# ============================================================

cat("Generating Figure 3: Gender outcomes...\n")

p3a <- rdd_binscatter(sample_A, "f_worker_share_11", "rv_250",
                      title = "A. Female Worker Share (2011)",
                      ylab = "Female Worker Share")
p3b <- rdd_binscatter(sample_A, "gender_lit_gap_11", "rv_250",
                      title = "B. Gender Literacy Gap (2011)",
                      ylab = "Male - Female Literacy Rate")
p3c <- rdd_binscatter(sample_A, "f_nonag_share_11", "rv_250",
                      title = "C. Female Non-Ag Worker Share (2011)",
                      ylab = "Female Non-Ag Worker Share")
p3d <- rdd_binscatter(sample_A, "log_nl_post_viirs", "rv_250",
                      title = "D. Log Nightlights (VIIRS 2015-2023)",
                      ylab = "Log Nightlights")

p3_combined <- (p3a + p3b) / (p3c + p3d) +
  plot_annotation(
    title = "Gender and Demographic Outcomes at 250 Threshold",
    subtitle = "Special Category States — Bin scatter with local linear fit",
    theme = theme_apep()
  )

ggsave(file.path(fig_dir, "fig3_gender.pdf"), p3_combined,
       width = 12, height = 10)

# ============================================================
# Figure 4: Covariate Balance
# ============================================================

cat("Generating Figure 4: Covariate balance...\n")

balance <- readRDS(file.path(out_dir, "balance_results.rds"))

covariates_labels <- c(
  "literacy_01" = "Literacy (2001)",
  "f_lit_01" = "Female Literacy (2001)",
  "sc_share_01" = "SC Share (2001)",
  "st_share_01" = "ST Share (2001)",
  "worker_share_01" = "Worker Share (2001)",
  "f_worker_share_01" = "Female Worker Share (2001)",
  "main_worker_share_01" = "Main Worker Share (2001)",
  "log_nl_pre" = "Log Nightlights (Pre)"
)

bal_df <- data.frame(
  var = names(balance),
  label = covariates_labels[names(balance)],
  coef = sapply(balance, function(x) ifelse(is.na(x$coef), NA, x$coef)),
  se = sapply(balance, function(x) ifelse(is.na(x$se), NA, x$se)),
  stringsAsFactors = FALSE
)
bal_df <- bal_df[!is.na(bal_df$coef), ]
bal_df$ci_l <- bal_df$coef - 1.96 * bal_df$se
bal_df$ci_u <- bal_df$coef + 1.96 * bal_df$se

p4 <- ggplot(bal_df, aes(x = coef, y = reorder(label, coef))) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "grey40") +
  geom_errorbarh(aes(xmin = ci_l, xmax = ci_u), height = 0.2,
                 color = apep_colors[1], linewidth = 0.7) +
  geom_point(color = apep_colors[1], size = 3) +
  labs(title = "Covariate Balance at 250 Threshold",
       subtitle = "Pre-treatment characteristics should show no discontinuity",
       x = "RDD Coefficient (Robust)", y = "") +
  theme_apep()

ggsave(file.path(fig_dir, "fig4_balance.pdf"), p4,
       width = 8, height = 5)

# ============================================================
# Figure 5: Nightlights Event Study
# ============================================================

cat("Generating Figure 5: Nightlights event study...\n")

nl_event <- readRDS(file.path(out_dir, "nl_event_study.rds"))

# Combine DMSP and VIIRS
event_df <- rbind(
  data.frame(nl_event$dmsp, sensor = "DMSP"),
  data.frame(nl_event$viirs, sensor = "VIIRS")
)
event_df <- event_df[!is.na(event_df$coef), ]
event_df$ci_l <- event_df$coef - 1.96 * event_df$se
event_df$ci_u <- event_df$coef + 1.96 * event_df$se

p5 <- ggplot(event_df, aes(x = year, y = coef, color = sensor, fill = sensor)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
  geom_vline(xintercept = 2001, linetype = "dotted", color = "grey60",
             linewidth = 0.5) +
  annotate("text", x = 2001.5, y = max(event_df$ci_u, na.rm = TRUE),
           label = "PMGSY\nlaunched", size = 3, hjust = 0, color = "grey40") +
  geom_ribbon(aes(ymin = ci_l, ymax = ci_u), alpha = 0.15, color = NA) +
  geom_line(linewidth = 0.8) +
  geom_point(size = 2) +
  scale_color_manual(values = c("DMSP" = apep_colors[1],
                                "VIIRS" = apep_colors[3]),
                     name = "Sensor") +
  scale_fill_manual(values = c("DMSP" = apep_colors[1],
                               "VIIRS" = apep_colors[3]),
                    name = "Sensor") +
  labs(title = "Dynamic Effects of PMGSY Eligibility on Nightlights",
       subtitle = "Year-by-year RDD estimates at 250 threshold (Special Category States)",
       x = "Year", y = "RDD Coefficient (Log Nightlights)") +
  theme_apep()

ggsave(file.path(fig_dir, "fig5_nl_event.pdf"), p5,
       width = 10, height = 6)

# ============================================================
# Figure 6: Bandwidth Sensitivity
# ============================================================

cat("Generating Figure 6: Bandwidth sensitivity...\n")

bw_sens <- tryCatch(readRDS(file.path(out_dir, "bw_sensitivity.rds")),
                    error = function(e) NULL)

if (!is.null(bw_sens)) {
  bw_sens$ci_l <- bw_sens$coef - 1.96 * bw_sens$se
  bw_sens$ci_u <- bw_sens$coef + 1.96 * bw_sens$se

  p6 <- ggplot(bw_sens, aes(x = bandwidth, y = coef)) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
    geom_ribbon(aes(ymin = ci_l, ymax = ci_u), alpha = 0.2,
                fill = apep_colors[1]) +
    geom_line(color = apep_colors[1], linewidth = 0.8) +
    geom_point(color = apep_colors[1], size = 3) +
    geom_point(data = bw_sens[bw_sens$multiplier == 1, ],
               color = "red3", size = 4, shape = 18) +
    labs(title = "Bandwidth Sensitivity (Literacy Rate 2011)",
         subtitle = "Diamond = MSE-optimal bandwidth",
         x = "Bandwidth (Population Units)", y = "RDD Coefficient") +
    theme_apep()

  ggsave(file.path(fig_dir, "fig6_bw_sensitivity.pdf"), p6,
         width = 8, height = 5)
}

# ============================================================
# Figure 7: Comparison — 250 vs 500 Threshold
# ============================================================

cat("Generating Figure 7: 250 vs 500 comparison...\n")

results_A <- readRDS(file.path(out_dir, "results_250_A.rds"))
results_500 <- readRDS(file.path(out_dir, "results_500.rds"))

compare_vars <- c("literacy_11", "f_lit_11", "nonag_share_11",
                   "f_worker_share_11", "log_nl_post_viirs")
compare_labels <- c("Literacy", "Female Literacy", "Non-Ag Workers",
                     "Female Workers", "Nightlights")

comp_df <- rbind(
  data.frame(
    var = compare_labels,
    threshold = "250 (Tribal/Hill)",
    coef = sapply(compare_vars, function(v)
      ifelse(is.na(results_A[[v]]$coef), NA, results_A[[v]]$coef)),
    se = sapply(compare_vars, function(v)
      ifelse(is.na(results_A[[v]]$se), NA, results_A[[v]]$se)),
    stringsAsFactors = FALSE
  ),
  data.frame(
    var = compare_labels,
    threshold = "500 (Plains)",
    coef = sapply(compare_vars, function(v)
      ifelse(is.na(results_500[[v]]$coef), NA, results_500[[v]]$coef)),
    se = sapply(compare_vars, function(v)
      ifelse(is.na(results_500[[v]]$se), NA, results_500[[v]]$se)),
    stringsAsFactors = FALSE
  )
)
comp_df$ci_l <- comp_df$coef - 1.96 * comp_df$se
comp_df$ci_u <- comp_df$coef + 1.96 * comp_df$se

p7 <- ggplot(comp_df[!is.na(comp_df$coef), ],
             aes(x = coef, y = var, color = threshold)) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "grey40") +
  geom_errorbarh(aes(xmin = ci_l, xmax = ci_u), height = 0.2,
                 linewidth = 0.7,
                 position = position_dodge(width = 0.4)) +
  geom_point(size = 3, position = position_dodge(width = 0.4)) +
  scale_color_manual(values = c("250 (Tribal/Hill)" = apep_colors[1],
                                "500 (Plains)" = apep_colors[2]),
                     name = "Threshold") +
  labs(title = "Comparing Road Eligibility Effects: Tribal vs Plains Areas",
       subtitle = "RDD estimates at 250 (designated) and 500 (non-designated) thresholds",
       x = "RDD Coefficient (Robust)", y = "") +
  theme_apep()

ggsave(file.path(fig_dir, "fig7_comparison.pdf"), p7,
       width = 10, height = 6)

cat("\nAll figures generated.\n")
