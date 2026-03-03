# ==============================================================================
# 05_figures.R — All Figures
# apep_0492 v1
# ==============================================================================

source("00_packages.R")

# Prevent scientific notation in all output
options(scipen = 999)

data_dir <- "../data"
fig_dir <- "../figures"
dir.create(fig_dir, showWarnings = FALSE)

ppd <- fread(file.path(data_dir, "ppd_analysis.csv"))
results <- readRDS(file.path(data_dir, "main_results.rds"))

england_regions <- c("North East", "North West", "Yorkshire and The Humber",
                     "East Midlands", "West Midlands", "South West",
                     "East of England", "South East", "London")

htb_caps <- data.table(
  region = england_regions,
  cap = c(186100, 224400, 228100, 261900, 255600, 349000, 407400, 437600, 600000)
)

# Load bunching function (without re-running analysis)
.sourced_for_functions <- TRUE
source("03_main_analysis.R")

# ==============================================================================
# Figure 1: New-Build Price Distributions — 3×3 Panel (Post-Reform)
# ==============================================================================

plots_list <- list()

for (i in seq_along(england_regions)) {
  reg <- england_regions[i]
  cap <- htb_caps[region == reg, cap]

  dt_nb <- ppd[new_build == TRUE & post_reform == TRUE & region == reg]

  # Price range centered on cap
  price_range <- c(max(cap - 100000, 50000), cap + 100000)
  dt_plot <- dt_nb[price >= price_range[1] & price <= price_range[2]]

  p <- ggplot(dt_plot, aes(x = price / 1000)) +
    geom_histogram(binwidth = 2, fill = "steelblue", color = "white",
                   linewidth = 0.1) +
    geom_vline(xintercept = cap / 1000, color = "red", linewidth = 0.8,
               linetype = "dashed") +
    annotate("text", x = cap / 1000, y = Inf, label = sprintf("Cap: £%.0fk", cap / 1000),
             hjust = -0.1, vjust = 2, color = "red", size = 2.5) +
    labs(x = "Price (£000s)", y = "Count",
         title = reg,
         subtitle = sprintf("N = %s", format(nrow(dt_nb), big.mark = ","))) +
    scale_x_continuous(labels = scales::comma_format()) +
    theme(plot.title = element_text(size = 9, face = "bold"),
          plot.subtitle = element_text(size = 7),
          axis.text = element_text(size = 6),
          axis.title = element_text(size = 7))

  plots_list[[i]] <- p
}

fig1 <- wrap_plots(plots_list, ncol = 3) +
  plot_annotation(
    title = "New-Build Price Distributions by Region (Post-Reform, April 2021 — March 2023)",
    subtitle = "Dashed red line indicates regional Help to Buy price cap",
    theme = theme(plot.title = element_text(size = 13, face = "bold"),
                  plot.subtitle = element_text(size = 10, color = "grey40"))
  )

ggsave(file.path(fig_dir, "fig1_price_distributions.pdf"), fig1,
       width = 10, height = 10, dpi = 300)
cat("Figure 1 saved.\n")

# ==============================================================================
# Figure 2: Bunching Estimation — Key Regions
# ==============================================================================

key_regions <- c("North East", "North West", "East of England", "London")

plots_bunch <- list()

for (reg in key_regions) {
  cap <- htb_caps[region == reg, cap]
  dt_nb <- ppd[new_build == TRUE & post_reform == TRUE & region == reg]

  result <- estimate_bunching(dt_nb, cap)
  if (is.null(result)) next

  bc <- result$bin_counts

  p <- ggplot(bc, aes(x = rel_bin / 1000)) +
    geom_col(aes(y = N), fill = "steelblue", width = 0.9) +
    geom_line(aes(y = counterfactual), color = "red", linewidth = 0.8) +
    geom_vline(xintercept = 0, linetype = "dashed", color = "grey40") +
    annotate("text", x = -15, y = max(bc$N) * 0.9,
             label = sprintf("b = %.3f", result$bunching_ratio),
             hjust = 0, size = 3, fontface = "bold") +
    labs(x = "Distance to Cap (£000s)", y = "Count",
         title = reg,
         subtitle = sprintf("Cap = £%s | Excess = %.0f",
                            format(cap, big.mark = ","), result$excess_below)) +
    theme(plot.title = element_text(size = 10, face = "bold"),
          plot.subtitle = element_text(size = 8))

  plots_bunch[[reg]] <- p
}

fig2 <- wrap_plots(plots_bunch, ncol = 2) +
  plot_annotation(
    title = "Bunching Below Help to Buy Price Caps: New Builds (Post-Reform)",
    subtitle = "Blue bars = observed distribution; Red line = polynomial counterfactual",
    theme = theme(plot.title = element_text(size = 13, face = "bold"),
                  plot.subtitle = element_text(size = 10, color = "grey40"))
  )

ggsave(file.path(fig_dir, "fig2_bunching_estimation.pdf"), fig2,
       width = 10, height = 8, dpi = 300)
cat("Figure 2 saved.\n")

# ==============================================================================
# Figure 3: Placebo — Second-Hand Properties at Same Caps
# ==============================================================================

plots_placebo <- list()

for (reg in key_regions) {
  cap <- htb_caps[region == reg, cap]
  dt_sh <- ppd[new_build == FALSE & post_reform == TRUE & region == reg]

  result <- estimate_bunching(dt_sh, cap)
  if (is.null(result)) next

  bc <- result$bin_counts

  p <- ggplot(bc, aes(x = rel_bin / 1000)) +
    geom_col(aes(y = N), fill = "grey60", width = 0.9) +
    geom_line(aes(y = counterfactual), color = "red", linewidth = 0.8) +
    geom_vline(xintercept = 0, linetype = "dashed", color = "grey40") +
    annotate("text", x = -15, y = max(bc$N) * 0.9,
             label = sprintf("b = %.3f", result$bunching_ratio),
             hjust = 0, size = 3, fontface = "bold") +
    labs(x = "Distance to Cap (£000s)", y = "Count",
         title = paste(reg, "(Second-Hand)"),
         subtitle = "No bunching expected at HTB caps") +
    theme(plot.title = element_text(size = 10, face = "bold"),
          plot.subtitle = element_text(size = 8))

  plots_placebo[[reg]] <- p
}

fig3 <- wrap_plots(plots_placebo, ncol = 2) +
  plot_annotation(
    title = "Placebo: Second-Hand Property Distributions at Help to Buy Caps",
    subtitle = "No bunching expected — HTB does not apply to existing properties",
    theme = theme(plot.title = element_text(size = 13, face = "bold"),
                  plot.subtitle = element_text(size = 10, color = "grey40"))
  )

ggsave(file.path(fig_dir, "fig3_placebo_secondhand.pdf"), fig3,
       width = 10, height = 8, dpi = 300)
cat("Figure 3 saved.\n")

# ==============================================================================
# Figure 4: Bunching Ratios Across Regions (Forest Plot)
# ==============================================================================

br_dt <- rbindlist(lapply(results$bunching, as.data.table))

fig4 <- ggplot(br_dt, aes(x = reorder(region, cap), y = bunching_ratio)) +
  geom_point(size = 3, color = "steelblue") +
  geom_errorbar(aes(ymin = ci_lower, ymax = ci_upper), width = 0.2,
                color = "steelblue") +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
  coord_flip() +
  labs(x = "", y = "Bunching Ratio (b)",
       title = "Bunching Ratios by Region",
       subtitle = "95% CI from bootstrap (500 iterations). Regions ordered by cap level.") +
  theme(plot.title = element_text(size = 13, face = "bold"))

ggsave(file.path(fig_dir, "fig4_bunching_forest.pdf"), fig4,
       width = 8, height = 6, dpi = 300)
cat("Figure 4 saved.\n")

# ==============================================================================
# Figure 5: Property Type Composition Shift
# ==============================================================================

type_shares <- ppd[new_build == TRUE,
                   .(detached = mean(property_type == "D"),
                     semi = mean(property_type == "S"),
                     terraced = mean(property_type == "T"),
                     flat = mean(property_type == "F")),
                   by = .(region, post_reform)]

type_long <- melt(type_shares, id.vars = c("region", "post_reform"),
                  variable.name = "type", value.name = "share")
type_long[, period := fifelse(post_reform, "Post-Reform\n(2021-2023)",
                              "Pre-Reform\n(2018-2021)")]

fig5 <- ggplot(type_long[region %in% c("North East", "North West",
                                         "East of England", "London")],
               aes(x = type, y = share, fill = period)) +
  geom_col(position = "dodge", width = 0.6) +
  facet_wrap(~region, scales = "free_y") +
  scale_y_continuous(labels = scales::percent_format()) +
  scale_fill_manual(values = c("steelblue", "coral")) +
  labs(x = "Property Type", y = "Share of New Builds", fill = "",
       title = "New-Build Property Type Composition: Pre vs Post Reform",
       subtitle = "D = Detached, S = Semi-Detached, T = Terraced, F = Flat") +
  theme(legend.position = "bottom",
        plot.title = element_text(size = 13, face = "bold"))

ggsave(file.path(fig_dir, "fig5_property_types.pdf"), fig5,
       width = 10, height = 8, dpi = 300)
cat("Figure 5 saved.\n")

# ==============================================================================
# Figure 6: Event Study — Monthly Bunching Around April 2021
# ==============================================================================

if (file.exists(file.path(data_dir, "event_study.csv"))) {
  event_study <- fread(file.path(data_dir, "event_study.csv"))

  fig6 <- ggplot(event_study, aes(x = months_to_reform, y = bunching_ratio,
                                    color = region)) +
    geom_point(size = 1.5) +
    geom_smooth(method = "loess", se = FALSE, linewidth = 0.8, span = 0.5) +
    geom_vline(xintercept = 0, linetype = "dashed", color = "grey40") +
    annotate("text", x = 0.5, y = Inf, label = "Reform\n(Apr 2021)",
             hjust = 0, vjust = 2, size = 3, color = "grey40") +
    labs(x = "Months Relative to April 2021", y = "Bunching Ratio",
         color = "",
         title = "Monthly Bunching at Regional Caps Around Reform Date",
         subtitle = "Bunching should appear only after April 2021 at regional cap values") +
    theme(legend.position = "bottom",
          plot.title = element_text(size = 13, face = "bold"))

  ggsave(file.path(fig_dir, "fig6_event_study.pdf"), fig6,
         width = 9, height = 6, dpi = 300)
  cat("Figure 6 saved.\n")
}

# ==============================================================================
# Figure 7: Difference-in-Bunching at £600K
# ==============================================================================

if (length(results$dib) > 0) {
  dib_dt <- rbindlist(lapply(results$dib, as.data.table))

  dib_long <- melt(dib_dt[, .(region, pre_bunching, post_bunching)],
                   id.vars = "region",
                   variable.name = "period", value.name = "bunching")

  fig7 <- ggplot(dib_long, aes(x = reorder(region, -bunching),
                                 y = bunching, fill = period)) +
    geom_col(position = "dodge", width = 0.6) +
    scale_fill_manual(values = c("steelblue", "coral"),
                      labels = c("Pre-Reform (at £600K)", "Post-Reform (at £600K)")) +
    coord_flip() +
    labs(x = "", y = "Bunching Ratio at £600K", fill = "",
         title = "Difference-in-Bunching: Disappearance of £600K Bunching Post-Reform",
         subtitle = "Non-London regions: cap dropped below £600K → bunching should disappear at £600K") +
    theme(legend.position = "bottom",
          plot.title = element_text(size = 12, face = "bold"))

  ggsave(file.path(fig_dir, "fig7_dib_600k.pdf"), fig7,
         width = 9, height = 6, dpi = 300)
  cat("Figure 7 saved.\n")
}

cat("\nAll figures generated.\n")
