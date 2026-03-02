# ============================================================================
# 05_figures.R — Publication-ready figures
# APEP-0443: PMGSY Roads and the Gender Gap in Non-Farm Employment
# ============================================================================

source("00_packages.R")

data_dir <- normalizePath(file.path(getwd(), "..", "data"), mustWork = FALSE)
fig_dir  <- normalizePath(file.path(getwd(), "..", "figures"), mustWork = FALSE)

df <- fread(file.path(data_dir, "plains_sample.csv"))

# ── Figure 1: McCrary Density Test ─────────────────────────────────────────
cat("Figure 1: McCrary density test...\n")

mccrary <- readRDS(file.path(data_dir, "mccrary_result.rds"))

pdf(file.path(fig_dir, "fig1_mccrary.pdf"), width = 8, height = 5)
plot_obj <- rdplotdensity(mccrary, df$running_var,
                          plotRange = c(-300, 300),
                          xlabel = "Village Population - 500",
                          ylabel = "Density",
                          title = "")
dev.off()

# ── Figure 2: RDD Plot — Female Non-Ag Share ──────────────────────────────
cat("Figure 2: RDD plot for female non-ag share...\n")

valid <- !is.na(df$nonag_share_f11) & !is.na(df$running_var)
df_valid <- df[valid]

# Use rdplot for binned scatter
rdp <- rdplot(y = df_valid$nonag_share_f11, x = df_valid$running_var, c = 0,
              nbins = c(40, 40),
              x.label = "Village Population - 500",
              y.label = "Female Non-Agricultural Worker Share (2011)",
              title = "",
              hide = TRUE)

# Extract data for custom ggplot
bins_below <- data.frame(x = rdp$vars_bins$rdplot_mean_x[rdp$vars_bins$rdplot_mean_x < 0],
                         y = rdp$vars_bins$rdplot_mean_y[rdp$vars_bins$rdplot_mean_x < 0])
bins_above <- data.frame(x = rdp$vars_bins$rdplot_mean_x[rdp$vars_bins$rdplot_mean_x >= 0],
                         y = rdp$vars_bins$rdplot_mean_y[rdp$vars_bins$rdplot_mean_x >= 0])

poly_below <- data.frame(x = rdp$vars_poly$rdplot_x[rdp$vars_poly$rdplot_x < 0],
                         y = rdp$vars_poly$rdplot_y[rdp$vars_poly$rdplot_x < 0])
poly_above <- data.frame(x = rdp$vars_poly$rdplot_x[rdp$vars_poly$rdplot_x >= 0],
                         y = rdp$vars_poly$rdplot_y[rdp$vars_poly$rdplot_x >= 0])

rd_obj <- readRDS(file.path(data_dir, "rd_objects.rds"))[["nonag_share_f11"]]

p2 <- ggplot() +
  geom_point(data = rbind(bins_below, bins_above),
             aes(x = x, y = y), color = "grey40", size = 2, alpha = 0.7) +
  geom_line(data = poly_below, aes(x = x, y = y),
            color = apep_colors[2], linewidth = 1.2) +
  geom_line(data = poly_above, aes(x = x, y = y),
            color = apep_colors[1], linewidth = 1.2) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "grey30", linewidth = 0.7) +
  labs(x = "Village Population - 500",
       y = "Female Non-Agricultural Worker Share (2011)",
       caption = sprintf("RD estimate: %.4f (SE = %.4f). Optimal bandwidth: %.0f.",
                         rd_obj$coef[2], rd_obj$se[3], rd_obj$bws[1, 1])) +
  theme_apep()

ggsave(file.path(fig_dir, "fig2_rd_female_nonag.pdf"), p2, width = 8, height = 5)

# ── Figure 3: RDD Plot — Male Non-Ag Share (Comparison) ───────────────────
cat("Figure 3: RDD plot for male non-ag share...\n")

valid_m <- !is.na(df$nonag_share_m11) & !is.na(df$running_var)
df_valid_m <- df[valid_m]

rdp_m <- rdplot(y = df_valid_m$nonag_share_m11, x = df_valid_m$running_var, c = 0,
                nbins = c(40, 40), title = "", hide = TRUE)

bins_m <- data.frame(x = rdp_m$vars_bins$rdplot_mean_x,
                     y = rdp_m$vars_bins$rdplot_mean_y)
poly_m_below <- data.frame(x = rdp_m$vars_poly$rdplot_x[rdp_m$vars_poly$rdplot_x < 0],
                           y = rdp_m$vars_poly$rdplot_y[rdp_m$vars_poly$rdplot_x < 0])
poly_m_above <- data.frame(x = rdp_m$vars_poly$rdplot_x[rdp_m$vars_poly$rdplot_x >= 0],
                           y = rdp_m$vars_poly$rdplot_y[rdp_m$vars_poly$rdplot_x >= 0])

rd_obj_m <- readRDS(file.path(data_dir, "rd_objects.rds"))[["nonag_share_m11"]]

p3 <- ggplot() +
  geom_point(data = bins_m, aes(x = x, y = y), color = "grey40", size = 2, alpha = 0.7) +
  geom_line(data = poly_m_below, aes(x = x, y = y),
            color = apep_colors[2], linewidth = 1.2) +
  geom_line(data = poly_m_above, aes(x = x, y = y),
            color = apep_colors[1], linewidth = 1.2) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "grey30", linewidth = 0.7) +
  labs(x = "Village Population - 500",
       y = "Male Non-Agricultural Worker Share (2011)",
       caption = sprintf("RD estimate: %.4f (SE = %.4f). Optimal bandwidth: %.0f.",
                         rd_obj_m$coef[2], rd_obj_m$se[3], rd_obj_m$bws[1, 1])) +
  theme_apep()

ggsave(file.path(fig_dir, "fig3_rd_male_nonag.pdf"), p3, width = 8, height = 5)

# ── Figure 4: Bandwidth Sensitivity ───────────────────────────────────────
cat("Figure 4: Bandwidth sensitivity...\n")

bw_results <- fread("../tables/robustness_bandwidth.csv")

p4 <- ggplot(bw_results, aes(x = bandwidth, y = rd_est)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
  geom_ribbon(aes(ymin = rd_est - 1.96 * se, ymax = rd_est + 1.96 * se),
              alpha = 0.2, fill = apep_colors[1]) +
  geom_point(size = 3, color = apep_colors[1]) +
  geom_line(color = apep_colors[1], linewidth = 0.8) +
  geom_vline(xintercept = bw_results$bandwidth[bw_results$multiplier == 1.0],
             linetype = "dotted", color = apep_colors[2]) +
  labs(x = "Bandwidth",
       y = "RD Estimate",
       caption = "Dashed orange line = CCT optimal bandwidth. Shaded region = 95% CI.") +
  theme_apep()

ggsave(file.path(fig_dir, "fig4_bandwidth_sensitivity.pdf"), p4, width = 8, height = 5)

# ── Figure 5: Placebo Cutoffs ─────────────────────────────────────────────
cat("Figure 5: Placebo cutoffs...\n")

placebo <- fread("../tables/robustness_placebo.csv")

p5 <- ggplot(placebo, aes(x = cutoff, y = rd_est)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
  geom_ribbon(aes(ymin = rd_est - 1.96 * se, ymax = rd_est + 1.96 * se),
              alpha = 0.15, fill = "grey50") +
  geom_point(aes(color = cutoff == 500), size = 3) +
  scale_color_manual(values = c("TRUE" = apep_colors[1], "FALSE" = "grey50"),
                     guide = "none") +
  labs(x = "Population Cutoff",
       y = "RD Estimate",
       caption = "Blue point = true PMGSY threshold (500). Grey = placebo cutoffs.") +
  theme_apep()

ggsave(file.path(fig_dir, "fig5_placebo_cutoffs.pdf"), p5, width = 8, height = 5)

# ── Figure 6: Covariate Balance ───────────────────────────────────────────
cat("Figure 6: Covariate balance...\n")

balance <- fread("../tables/balance_test.csv")

# Clean variable names to publication English
label_map <- c(
  "sc_share01" = "SC Population Share",
  "st_share01" = "ST Population Share",
  "lit_rate_f01" = "Female Literacy Rate",
  "lit_rate_m01" = "Male Literacy Rate",
  "lfpr_f01" = "Female LFPR",
  "lfpr_m01" = "Male LFPR",
  "nonag_share_f01" = "Female Non-Ag Share",
  "nonag_share_m01" = "Male Non-Ag Share"
)
balance$variable_label <- ifelse(balance$variable %in% names(label_map),
                                  label_map[balance$variable],
                                  gsub("_", " ", gsub("01$", "", balance$variable)))

p6 <- ggplot(balance, aes(x = reorder(variable_label, rd_est), y = rd_est)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
  geom_pointrange(aes(ymin = rd_est - 1.96 * se, ymax = rd_est + 1.96 * se),
                  color = apep_colors[1], size = 0.5) +
  coord_flip() +
  labs(x = "", y = "RD Estimate (Pre-Treatment Covariates)",
       caption = "95% robust confidence intervals. Covariates measured in Census 2001.") +
  theme_apep()

ggsave(file.path(fig_dir, "fig6_covariate_balance.pdf"), p6, width = 8, height = 5)

# ── Figure 7: Population Histogram ────────────────────────────────────────
cat("Figure 7: Population histogram near cutoff...\n")

df_near <- df[pop01 >= 200 & pop01 <= 800]

p7 <- ggplot(df_near, aes(x = pop01)) +
  geom_histogram(aes(fill = factor(eligible)), binwidth = 10,
                 color = "white", linewidth = 0.2, alpha = 0.8) +
  geom_vline(xintercept = 500, linetype = "dashed", color = "grey20", linewidth = 0.8) +
  scale_fill_manual(values = c("0" = apep_colors[2], "1" = apep_colors[1]),
                    labels = c("Below Threshold", "Above Threshold"),
                    name = "PMGSY Eligibility") +
  labs(x = "Village Population (Census 2001)",
       y = "Number of Villages",
       caption = "Dashed line = PMGSY eligibility threshold (500).") +
  theme_apep()

ggsave(file.path(fig_dir, "fig7_population_histogram.pdf"), p7, width = 8, height = 5)

# ── Figure 8: Donut Hole Sensitivity ──────────────────────────────────────
cat("Figure 8: Donut hole sensitivity...\n")

donut <- fread("../tables/robustness_donut.csv")

p8 <- ggplot(donut, aes(x = donut, y = rd_est)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
  geom_ribbon(aes(ymin = rd_est - 1.96 * se, ymax = rd_est + 1.96 * se),
              alpha = 0.2, fill = apep_colors[1]) +
  geom_point(size = 3, color = apep_colors[1]) +
  geom_line(color = apep_colors[1], linewidth = 0.8) +
  labs(x = "Donut Hole Radius (Population Units Excluded)",
       y = "RD Estimate",
       caption = "Donut = 0 is the baseline specification.") +
  theme_apep()

ggsave(file.path(fig_dir, "fig8_donut_sensitivity.pdf"), p8, width = 8, height = 5)

cat("\nAll figures saved to figures/\n")
