## ============================================================
## 05_figures.R — All figure generation
## RD plots, first stage, placebos
## ============================================================

source("00_packages.R")

data_dir <- "../data"
fig_dir <- "../figures"
dir.create(fig_dir, showWarnings = FALSE)

panel <- fread(file.path(data_dir, "analysis_panel.csv"))

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
    # Left polynomial fit
    geom_smooth(data = binned[x_mean < cutoff], method = "lm",
                formula = y ~ poly(x, 1), se = TRUE,
                color = "#2166AC", fill = "#2166AC", alpha = 0.15) +
    # Right polynomial fit
    geom_smooth(data = binned[x_mean >= cutoff], method = "lm",
                formula = y ~ poly(x, 1), se = TRUE,
                color = "#B2182B", fill = "#B2182B", alpha = 0.15) +
    scale_size_continuous(guide = "none") +
    labs(title = title, x = "Population", y = ylab) +
    theme(plot.title = element_text(size = 11))

  return(p)
}

## ----------------------------------------------------------
## Figure 1: First Stage — Female Councillor Share
## ----------------------------------------------------------

cat("Generating Figure 1: First Stage\n")

muni_5k <- panel[pop > 2000 & pop < 8000 & !is.na(female_share),
  .(female_share = mean(female_share, na.rm = TRUE),
    pop = mean(pop, na.rm = TRUE)),
  by = .(ine_code)
]

muni_3k <- panel[pop > 1000 & pop < 5000 & election_year >= 2011 &
                  !is.na(female_share),
  .(female_share = mean(female_share, na.rm = TRUE),
    pop = mean(pop, na.rm = TRUE)),
  by = .(ine_code)
]

p1a <- rd_binscatter(muni_5k, "female_share", "pop", 5000,
                      title = "A. 5,000 Threshold",
                      ylab = "Female Councillor Share")
p1b <- rd_binscatter(muni_3k, "female_share", "pop", 3000,
                      bandwidth = 2000,
                      title = "B. 3,000 Threshold",
                      ylab = "Female Councillor Share")

if (!is.null(p1a) && !is.null(p1b)) {
  fig1 <- p1a + p1b +
    plot_annotation(title = "First Stage: Gender Quota and Female Council Representation",
                    theme = theme(plot.title = element_text(face = "bold")))
  ggsave(file.path(fig_dir, "fig1_first_stage.pdf"), fig1,
         width = 10, height = 5)
  cat("  Saved fig1_first_stage.pdf\n")
} else {
  cat("  WARNING: Not enough data for first stage figure\n")
}

## ----------------------------------------------------------
## Figure 2: McCrary Density Test
## ----------------------------------------------------------

cat("Generating Figure 2: Density\n")

pdf(file.path(fig_dir, "fig2_density.pdf"), width = 10, height = 5)
par(mfrow = c(1, 2))

# 5,000 cutoff
if (file.exists(file.path(data_dir, "density_5k.rds"))) {
  density_5k <- readRDS(file.path(data_dir, "density_5k.rds"))
  rdplotdensity(density_5k, muni_5k$pop,
                title = "A. 5,000 Threshold",
                xlabel = "Population", ylabel = "Density")
}

# 3,000 cutoff
if (file.exists(file.path(data_dir, "density_3k.rds"))) {
  density_3k <- readRDS(file.path(data_dir, "density_3k.rds"))
  rdplotdensity(density_3k, muni_3k$pop,
                title = "B. 3,000 Threshold",
                xlabel = "Population", ylabel = "Density")
}

dev.off()
cat("  Saved fig2_density.pdf\n")

## ----------------------------------------------------------
## Figure 3: Main Results — Within-Education Shares at 5,000
## ----------------------------------------------------------

cat("Generating Figure 3: Main RD results\n")

muni_outcomes <- panel[pop > 2000 & pop < 8000 & year >= 2010,
  lapply(.SD, function(x) mean(x, na.rm = TRUE)),
  by = .(ine_code),
  .SDcols = c("pop", grep("^share_", names(panel), value = TRUE),
              "edu_share_total", "security_pc")
]

# Exclude generic share_32 (2-digit aggregate)
share_cols <- grep("^share_3[2-9][0-9]", names(muni_outcomes), value = TRUE)

# Label map
fig_label_map <- c(
  share_320 = "General Administration",
  share_321 = "Primary School Facilities",
  share_322 = "Secondary Education",
  share_323 = "Education Promotion",
  share_324 = "Non-Regulated Education",
  share_326 = "Complementary Services"
)

# Create a panel of RD plots for key education subcategories
rd_plots <- list()
for (sc in share_cols[1:min(4, length(share_cols))]) {
  label <- ifelse(sc %in% names(fig_label_map), fig_label_map[sc],
                  gsub("share_", "Program ", sc))
  p <- rd_binscatter(muni_outcomes, sc, "pop", 5000,
                      title = label,
                      ylab = "Share of Education Spending")
  if (!is.null(p)) rd_plots[[sc]] <- p
}

if (length(rd_plots) >= 2) {
  fig3 <- wrap_plots(rd_plots, ncol = 2) +
    plot_annotation(
      title = "Within-Education Budget Shares at 5,000 Population Threshold",
      theme = theme(plot.title = element_text(face = "bold"))
    )
  ggsave(file.path(fig_dir, "fig3_main_rd.pdf"), fig3,
         width = 10, height = 8)
  cat("  Saved fig3_main_rd.pdf\n")
}

## ----------------------------------------------------------
## Figure 4: Aggregate Null Replication
## ----------------------------------------------------------

cat("Generating Figure 4: Aggregate null\n")

p4 <- rd_binscatter(muni_outcomes, "edu_share_total", "pop", 5000,
                     title = "Education Share of Total Spending",
                     ylab = "Education / Total Spending")

if (!is.null(p4)) {
  ggsave(file.path(fig_dir, "fig4_aggregate_null.pdf"), p4,
         width = 6, height = 5)
  cat("  Saved fig4_aggregate_null.pdf\n")
}

## ----------------------------------------------------------
## Figure 5: Placebo — Security Spending
## ----------------------------------------------------------

cat("Generating Figure 5: Placebo\n")

p5 <- rd_binscatter(muni_outcomes, "security_pc", "pop", 5000,
                     title = "Placebo: Security Spending per Capita",
                     ylab = "EUR per Capita")

if (!is.null(p5)) {
  ggsave(file.path(fig_dir, "fig5_placebo_security.pdf"), p5,
         width = 6, height = 5)
  cat("  Saved fig5_placebo_security.pdf\n")
}

## ----------------------------------------------------------
## Figure 6: Bandwidth Sensitivity
## ----------------------------------------------------------

cat("Generating Figure 6: Bandwidth sensitivity\n")

if (file.exists(file.path(data_dir, "bw_results.rds"))) {
  bw_results <- readRDS(file.path(data_dir, "bw_results.rds"))
  bw_df <- rbindlist(bw_results)

  if (nrow(bw_df) > 0) {
    fig6 <- ggplot(bw_df, aes(x = multiplier, y = est)) +
      geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
      geom_ribbon(aes(ymin = est - 1.96 * se, ymax = est + 1.96 * se),
                  fill = "#2166AC", alpha = 0.2) +
      geom_line(color = "#2166AC", linewidth = 1) +
      geom_point(color = "#2166AC", size = 2) +
      labs(title = "Bandwidth Sensitivity",
           x = "Bandwidth Multiplier (× MSE-optimal)",
           y = "RD Estimate") +
      scale_x_continuous(breaks = c(0.5, 0.75, 1.0, 1.25, 1.5, 2.0))

    ggsave(file.path(fig_dir, "fig6_bandwidth.pdf"), fig6,
           width = 6, height = 5)
    cat("  Saved fig6_bandwidth.pdf\n")
  }
}

cat("\n=== FIGURES COMPLETE ===\n")
