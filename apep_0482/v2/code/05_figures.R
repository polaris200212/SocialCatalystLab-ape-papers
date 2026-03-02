## ============================================================
## 05_figures.R — All figure generation (v2)
## First-stage evolution, RD plots, density, placebos, bandwidth
## ============================================================

source("00_packages.R")

data_dir <- "../data"
fig_dir <- "../figures"
dir.create(fig_dir, showWarnings = FALSE)

panel <- fread(file.path(data_dir, "analysis_panel.csv"))
eterm <- fread(file.path(data_dir, "election_term_panel.csv"))

## ----------------------------------------------------------
## Helper: RD binscatter plot
## ----------------------------------------------------------

rd_binscatter <- function(data, y_var, x_var, cutoff, n_bins = 40,
                          title = "", ylab = "", bandwidth = 3000) {
  d <- data[abs(get(x_var) - cutoff) <= bandwidth & !is.na(get(y_var))]
  if (nrow(d) < 50) return(NULL)

  d[, bin := cut(get(x_var), breaks = n_bins)]
  binned <- d[, .(y_mean = mean(get(y_var), na.rm = TRUE),
                   x_mean = mean(get(x_var), na.rm = TRUE),
                   n = .N),
              by = bin][!is.na(y_mean)]

  p <- ggplot(binned, aes(x = x_mean, y = y_mean)) +
    geom_point(aes(size = n), alpha = 0.6, color = "grey30") +
    geom_vline(xintercept = cutoff, linetype = "dashed", color = "red",
               linewidth = 0.8) +
    geom_smooth(data = binned[x_mean < cutoff], method = "lm",
                formula = y ~ poly(x, 1), se = TRUE,
                color = "#2166AC", fill = "#2166AC", alpha = 0.15) +
    geom_smooth(data = binned[x_mean >= cutoff], method = "lm",
                formula = y ~ poly(x, 1), se = TRUE,
                color = "#B2182B", fill = "#B2182B", alpha = 0.15) +
    scale_size_continuous(guide = "none") +
    labs(title = title, x = "Population", y = ylab) +
    theme(plot.title = element_text(size = 11))

  return(p)
}

## ----------------------------------------------------------
## Figure 1: First Stage Evolution by Election Cohort
##           (NEW KEY FIGURE — "shelf life" story)
## ----------------------------------------------------------

cat("Generating Figure 1: First Stage Evolution\n")

if (file.exists(file.path(data_dir, "fs_by_election.rds"))) {
  fs_by_election <- readRDS(file.path(data_dir, "fs_by_election.rds"))

  if (length(fs_by_election) > 0) {
    fs_df <- rbindlist(fs_by_election)

    fig1 <- ggplot(fs_df, aes(x = factor(election_year), y = est)) +
      geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
      geom_errorbar(aes(ymin = ci_lower, ymax = ci_upper),
                    width = 0.2, color = "#2166AC", linewidth = 0.8) +
      geom_point(size = 3, color = "#2166AC") +
      geom_vline(xintercept = 2.5, linetype = "dotted", color = "#D6604D",
                 linewidth = 0.6) +
      annotate("text", x = 2.7, y = max(fs_df$ci_upper) * 0.9,
               label = "LRSAL\n(2013)", color = "#D6604D", size = 3,
               hjust = 0) +
      labs(title = "First-Stage Effect by Election Cohort",
           subtitle = "RDD estimate of gender quota on female councillor share at 5,000 threshold",
           x = "Election Year",
           y = "RD Estimate (Female Share Discontinuity)") +
      theme(axis.text.x = element_text(size = 11))

    ggsave(file.path(fig_dir, "fig1_fs_evolution.pdf"), fig1,
           width = 7, height = 5)
    cat("  Saved fig1_fs_evolution.pdf\n")
  }
}

## ----------------------------------------------------------
## Figure 2: First Stage RD Plots (Election-Term Level)
## ----------------------------------------------------------

cat("Generating Figure 2: First Stage\n")

et_5k <- eterm[pop_elec > 2000 & pop_elec < 8000 &
                !is.na(female_share) & !is.na(pop_elec)]
et_3k <- eterm[pop_elec > 1000 & pop_elec < 5000 &
                election_year >= 2011 &
                !is.na(female_share) & !is.na(pop_elec)]

p2a <- rd_binscatter(et_5k, "female_share", "pop_elec", 5000,
                      title = "A. 5,000 Threshold",
                      ylab = "Female Councillor Share")
p2b <- rd_binscatter(et_3k, "female_share", "pop_elec", 3000,
                      bandwidth = 2000,
                      title = "B. 3,000 Threshold",
                      ylab = "Female Councillor Share")

if (!is.null(p2a) && !is.null(p2b)) {
  fig2 <- p2a + p2b +
    plot_annotation(title = "First Stage: Gender Quota and Female Council Representation",
                    subtitle = "Election-term level with election-year population",
                    theme = theme(plot.title = element_text(face = "bold")))
  ggsave(file.path(fig_dir, "fig2_first_stage.pdf"), fig2,
         width = 10, height = 5)
  cat("  Saved fig2_first_stage.pdf\n")
}

## ----------------------------------------------------------
## Figure 3: McCrary Density Test
## ----------------------------------------------------------

cat("Generating Figure 3: Density\n")

pdf(file.path(fig_dir, "fig3_density.pdf"), width = 10, height = 5)
par(mfrow = c(1, 2))

if (file.exists(file.path(data_dir, "density_5k.rds"))) {
  density_5k <- readRDS(file.path(data_dir, "density_5k.rds"))
  rdplotdensity(density_5k, et_5k$pop_elec,
                title = "A. 5,000 Threshold",
                xlabel = "Population (Election Year)", ylabel = "Density")
}

if (file.exists(file.path(data_dir, "density_3k.rds"))) {
  density_3k <- readRDS(file.path(data_dir, "density_3k.rds"))
  rdplotdensity(density_3k, et_3k$pop_elec,
                title = "B. 3,000 Threshold",
                xlabel = "Population (Election Year)", ylabel = "Density")
}

dev.off()
cat("  Saved fig3_density.pdf\n")

## ----------------------------------------------------------
## Figure 4: Main Results — Within-Education Shares at 5,000
## ----------------------------------------------------------

cat("Generating Figure 4: Main RD results\n")

et_outcomes <- eterm[pop_elec > 2000 & pop_elec < 8000 & !is.na(pop_elec)]

share_cols <- grep("^share_3[2-9][0-9]", names(et_outcomes), value = TRUE)

fig_label_map <- c(
  share_320 = "General Administration",
  share_321 = "Primary School Facilities",
  share_322 = "Secondary Education",
  share_323 = "Education Promotion",
  share_324 = "Non-Regulated Education",
  share_326 = "Complementary Services"
)

rd_plots <- list()
for (sc in share_cols[1:min(4, length(share_cols))]) {
  label <- ifelse(sc %in% names(fig_label_map), fig_label_map[sc],
                  gsub("share_", "Program ", sc))
  p <- rd_binscatter(et_outcomes, sc, "pop_elec", 5000,
                      title = label,
                      ylab = "Share of Education Spending")
  if (!is.null(p)) rd_plots[[sc]] <- p
}

if (length(rd_plots) >= 2) {
  fig4 <- wrap_plots(rd_plots, ncol = 2) +
    plot_annotation(
      title = "Within-Education Budget Shares at 5,000 Population Threshold",
      subtitle = "Election-term level specification",
      theme = theme(plot.title = element_text(face = "bold"))
    )
  ggsave(file.path(fig_dir, "fig4_main_rd.pdf"), fig4,
         width = 10, height = 8)
  cat("  Saved fig4_main_rd.pdf\n")
}

## ----------------------------------------------------------
## Figure 5: Aggregate Null Replication
## ----------------------------------------------------------

cat("Generating Figure 5: Aggregate null\n")

p5 <- rd_binscatter(et_outcomes, "edu_share_total", "pop_elec", 5000,
                     title = "Education Share of Total Spending",
                     ylab = "Education / Total Spending")

if (!is.null(p5)) {
  ggsave(file.path(fig_dir, "fig5_aggregate_null.pdf"), p5,
         width = 6, height = 5)
  cat("  Saved fig5_aggregate_null.pdf\n")
}

## ----------------------------------------------------------
## Figure 6: Placebo — Security Spending
## ----------------------------------------------------------

cat("Generating Figure 6: Placebo\n")

p6 <- rd_binscatter(et_outcomes, "security_pc", "pop_elec", 5000,
                     title = "Placebo: Security Spending per Capita",
                     ylab = "EUR per Capita")

if (!is.null(p6)) {
  ggsave(file.path(fig_dir, "fig6_placebo_security.pdf"), p6,
         width = 6, height = 5)
  cat("  Saved fig6_placebo_security.pdf\n")
}

## ----------------------------------------------------------
## Figure 7: Bandwidth Sensitivity
## ----------------------------------------------------------

cat("Generating Figure 7: Bandwidth sensitivity\n")

if (file.exists(file.path(data_dir, "bw_results.rds"))) {
  bw_results <- readRDS(file.path(data_dir, "bw_results.rds"))
  bw_df <- rbindlist(bw_results)

  if (nrow(bw_df) > 0) {
    fig7 <- ggplot(bw_df, aes(x = multiplier, y = est)) +
      geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
      geom_ribbon(aes(ymin = est - 1.96 * se, ymax = est + 1.96 * se),
                  fill = "#2166AC", alpha = 0.2) +
      geom_line(color = "#2166AC", linewidth = 1) +
      geom_point(color = "#2166AC", size = 2) +
      labs(title = "Bandwidth Sensitivity",
           subtitle = "Election-term specification at 5,000 threshold",
           x = "Bandwidth Multiplier (\u00d7 MSE-optimal)",
           y = "RD Estimate") +
      scale_x_continuous(breaks = c(0.5, 0.75, 1.0, 1.25, 1.5, 2.0))

    ggsave(file.path(fig_dir, "fig7_bandwidth.pdf"), fig7,
           width = 6, height = 5)
    cat("  Saved fig7_bandwidth.pdf\n")
  }
}

cat("\n=== FIGURES COMPLETE ===\n")
