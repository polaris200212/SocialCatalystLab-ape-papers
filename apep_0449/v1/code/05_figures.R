## ============================================================================
## 05_figures.R — Publication-Quality Figures for Criminal Politicians RDD
## Generates all main and supplementary figures for apep_0449
## ============================================================================
source("00_packages.R")

cat("\n========================================\n")
cat("FIGURE GENERATION\n")
cat("========================================\n\n")

## ── Custom theme for publication ─────────────────────────────────────────
theme_pub <- theme_minimal(base_size = 11) +
  theme(
    panel.grid.minor  = element_blank(),
    panel.grid.major  = element_line(color = "grey90", linewidth = 0.3),
    strip.text        = element_text(face = "bold", size = 10),
    plot.title        = element_text(face = "bold", size = 12, hjust = 0.5),
    plot.subtitle     = element_text(size = 9, hjust = 0.5, color = "grey40"),
    axis.title        = element_text(size = 10),
    axis.text         = element_text(size = 9),
    legend.position   = "bottom",
    legend.text       = element_text(size = 9),
    plot.margin       = margin(10, 15, 10, 10)
  )

## ── Load data ────────────────────────────────────────────────────────────
rdd_file <- file.path(DATA_DIR, "rdd_analysis.rds")
post08_file <- file.path(DATA_DIR, "rdd_post08_full.rds")
main_res_file <- file.path(DATA_DIR, "main_results.rds")
robust_res_file <- file.path(DATA_DIR, "robustness_results.rds")

stopifnot(file.exists(rdd_file))
rdd <- readRDS(rdd_file)
cat("Loaded RDD dataset:", nrow(rdd), "observations\n")

## Load post-2008 full data (with village directory outcomes) if available
if (file.exists(post08_file)) {
  rdd_post08 <- readRDS(post08_file)
  cat("Loaded post-2008 full dataset:", nrow(rdd_post08), "observations\n")
} else {
  rdd_post08 <- rdd  # fallback
  cat("Post-2008 full data not found; using main RDD dataset\n")
}

## ── Restrict to observations with NL data for main analyses ──────────────
rdd_nl <- rdd[!is.na(nl_growth) & is.finite(nl_growth)]
cat("Observations with valid NL growth:", nrow(rdd_nl), "\n\n")


## ============================================================================
## FIGURE 1: Main RDD Plot — Nightlights Growth (using rdplot for consistency)
## ============================================================================
cat("── Figure 1: RDD plot for nightlights growth ──\n")

## Use rdplot from rdrobust for visual consistency with the estimates
## rdplot uses IMSE-optimal bins and local polynomial fits, matching rdrobust
rdd_clean <- rdd_nl[is.finite(nl_growth) & is.finite(margin)]

## Weighted local linear fits with triangular kernel, matching rdrobust
rd_fit <- rdrobust::rdrobust(y = rdd_clean$nl_growth, x = rdd_clean$margin, all = TRUE)
h <- rd_fit$bws["h", "left"]

## Restrict to within 1.5*h for display
dat_plot <- rdd_clean[abs(margin) <= 1.5 * h]
nbins_side <- 15

## Create bins
left <- dat_plot[margin < 0]
right <- dat_plot[margin >= 0]

make_bins_fig <- function(d, n) {
  if (nrow(d) < n) n <- max(3, nrow(d) %/% 3)
  breaks <- seq(min(d$margin), max(d$margin), length.out = n + 1)
  d[, bin := cut(margin, breaks = breaks, include.lowest = TRUE)]
  d[, .(margin_mid = mean(margin), y_mean = mean(nl_growth), n = .N), by = bin][!is.na(bin)]
}

bins_l <- make_bins_fig(left, nbins_side)
bins_r <- make_bins_fig(right, nbins_side)
bins_all <- rbind(bins_l, bins_r)

## Triangular kernel-weighted local linear fits (within h)
within_bw <- rdd_clean[abs(margin) <= h]
within_bw[, w := (1 - abs(margin) / h)]
fit_l <- lm(nl_growth ~ margin, data = within_bw[margin < 0], weights = w)
fit_r <- lm(nl_growth ~ margin, data = within_bw[margin >= 0], weights = w)

grid_l <- data.table(margin = seq(-h, -0.01, length.out = 200))
grid_r <- data.table(margin = seq(0.01, h, length.out = 200))
grid_l[, yhat := predict(fit_l, newdata = grid_l)]
grid_r[, yhat := predict(fit_r, newdata = grid_r)]

pred_l_se <- predict(fit_l, newdata = grid_l, se.fit = TRUE)
pred_r_se <- predict(fit_r, newdata = grid_r, se.fit = TRUE)
grid_l[, `:=`(ci_lo = yhat - 1.96 * pred_l_se$se.fit,
              ci_hi = yhat + 1.96 * pred_l_se$se.fit)]
grid_r[, `:=`(ci_lo = yhat - 1.96 * pred_r_se$se.fit,
              ci_hi = yhat + 1.96 * pred_r_se$se.fit)]

grid_all <- rbind(grid_l, grid_r)

fig1 <- ggplot() +
  geom_ribbon(data = grid_all, aes(x = margin, ymin = ci_lo, ymax = ci_hi),
              fill = "grey80", alpha = 0.5) +
  geom_line(data = grid_l, aes(x = margin, y = yhat), color = "#2171B5", linewidth = 1) +
  geom_line(data = grid_r, aes(x = margin, y = yhat), color = "#CB181D", linewidth = 1) +
  geom_point(data = bins_all, aes(x = margin_mid, y = y_mean),
             color = "black", size = 2, shape = 21, fill = "white", stroke = 0.8) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "grey30", linewidth = 0.5) +
  annotate("segment", x = -h, xend = -h, y = -Inf, yend = Inf,
           linetype = "dotted", color = "grey60", linewidth = 0.3) +
  annotate("segment", x = h, xend = h, y = -Inf, yend = Inf,
           linetype = "dotted", color = "grey60", linewidth = 0.3) +
  labs(
    x = "Vote Margin (Criminal \u2013 Non-Criminal)",
    y = "Nightlights Growth",
    title = "Effect of Electing a Criminal Politician on Nightlights Growth",
    subtitle = sprintf("Triangular kernel-weighted local linear fit (h* = %.1f pp)", h)
  ) +
  theme_pub

ggsave(file.path(FIG_DIR, "fig_rdd_nl_growth.pdf"), fig1,
       width = 7, height = 5, device = cairo_pdf)
cat("  Saved: fig_rdd_nl_growth.pdf\n")


## ============================================================================
## FIGURE 2: McCrary Density Test
## ============================================================================
cat("\n── Figure 2: McCrary density test ──\n")

## Use rddensity for formal test, then plot
rdd_clean_margin <- rdd_nl[is.finite(margin)]

density_test <- tryCatch(

  rddensity::rddensity(X = rdd_clean_margin$margin, p = 2),
  error = function(e) {
    cat("  rddensity failed:", conditionMessage(e), "\n")
    NULL
  }
)

if (!is.null(density_test)) {
  ## Use rdplotdensity for the formal density plot
  pdf(file.path(FIG_DIR, "fig_density.pdf"), width = 7, height = 5)

  density_plot <- tryCatch(
    rddensity::rdplotdensity(
      rdd = density_test,
      X   = rdd_clean_margin$margin,
      plotRange = c(-30, 30),
      title = "McCrary Density Test at Margin = 0",
      xlabel = "Vote Margin (Criminal \u2013 Non-Criminal)",
      ylabel = "Density"
    ),
    error = function(e) {
      cat("  rdplotdensity failed:", conditionMessage(e), "\n")
      NULL
    }
  )
  dev.off()

  ## If rdplotdensity failed, make manual density plot
  if (is.null(density_plot)) {
    p2 <- ggplot(rdd_clean_margin, aes(x = margin)) +
      geom_histogram(aes(y = after_stat(density)),
                     binwidth = 2, fill = "grey70",
                     color = "white", alpha = 0.7) +
      geom_density(color = "#2171B5", linewidth = 1) +
      geom_vline(xintercept = 0, linetype = "dashed",
                 color = "grey30", linewidth = 0.5) +
      labs(
        x = "Vote Margin (Criminal \u2013 Non-Criminal)",
        y = "Density",
        title = "McCrary Density Test at Margin = 0",
        subtitle = sprintf("rddensity p-value: %.3f",
                           density_test$test$p_jk)
      ) +
      theme_pub

    ggsave(file.path(FIG_DIR, "fig_density.pdf"), p2,
           width = 7, height = 5, device = cairo_pdf)
  }
  cat("  rddensity p-value:", density_test$test$p_jk, "\n")
} else {
  ## Full fallback: manual histogram + kernel density
  p2 <- ggplot(rdd_clean_margin, aes(x = margin)) +
    geom_histogram(aes(y = after_stat(density)),
                   binwidth = 2, fill = "grey70",
                   color = "white", alpha = 0.7) +
    geom_density(color = "#2171B5", linewidth = 1) +
    geom_vline(xintercept = 0, linetype = "dashed",
               color = "grey30", linewidth = 0.5) +
    labs(
      x = "Vote Margin (Criminal \u2013 Non-Criminal)",
      y = "Density",
      title = "McCrary Density Test at Margin = 0"
    ) +
    theme_pub

  ggsave(file.path(FIG_DIR, "fig_density.pdf"), p2,
         width = 7, height = 5, device = cairo_pdf)
}
cat("  Saved: fig_density.pdf\n")


## ============================================================================
## FIGURE 3: Covariate Balance at the Threshold
## ============================================================================
cat("\n── Figure 3: Covariate balance coefficient plot ──\n")

## Covariates to test: pre-treatment Census 2001 characteristics
## Variable names follow the data structure in 02_clean_data.R
covariate_specs <- list(
  list(var = "log_pop_01",     label = "Log Population (2001)"),
  list(var = "lit_rate_01",    label = "Literacy Rate (2001)"),
  list(var = "sc_share_01",    label = "SC Share (2001)"),
  list(var = "st_share_01",    label = "ST Share (2001)"),
  list(var = "turnout_percentage", label = "Voter Turnout (%)"),
  list(var = "n_cand",         label = "Number of Candidates"),
  list(var = "electors",       label = "Electorate Size"),
  list(var = "nl_pre",         label = "Baseline Nightlights")
)

## Run RDD on each covariate
balance_results <- data.table(
  variable = character(),
  label    = character(),
  coef     = numeric(),
  se       = numeric(),
  ci_lo    = numeric(),
  ci_hi    = numeric(),
  pval     = numeric(),
  n_eff    = numeric()
)

for (spec in covariate_specs) {
  vname <- spec$var
  vlabel <- spec$label

  if (!(vname %in% names(rdd_nl))) next

  d_sub <- rdd_nl[is.finite(get(vname)) & is.finite(margin)]
  if (nrow(d_sub) < 50) next

  rd_cov <- tryCatch(
    rdrobust::rdrobust(y = d_sub[[vname]], x = d_sub$margin, all = TRUE),
    error = function(e) NULL
  )

  if (!is.null(rd_cov)) {
    ## Use robust bias-corrected estimates
    coef_est <- rd_cov$coef[3]   # Robust estimate
    se_est   <- rd_cov$se[3]     # Robust SE
    ci_l     <- rd_cov$ci[3, 1]  # Robust CI lower
    ci_u     <- rd_cov$ci[3, 2]  # Robust CI upper
    pv       <- rd_cov$pv[3]     # Robust p-value
    neff     <- sum(rd_cov$N_h)

    ## Standardize: divide by control-side SD for comparability
    ctrl_sd <- sd(d_sub[margin < 0][[vname]], na.rm = TRUE)
    if (!is.na(ctrl_sd) && ctrl_sd > 0) {
      coef_std <- coef_est / ctrl_sd
      se_std   <- se_est / ctrl_sd
      ci_l_std <- ci_l / ctrl_sd
      ci_u_std <- ci_u / ctrl_sd
    } else {
      coef_std <- coef_est
      se_std   <- se_est
      ci_l_std <- ci_l
      ci_u_std <- ci_u
    }

    balance_results <- rbind(balance_results, data.table(
      variable = vname,
      label    = vlabel,
      coef     = coef_std,
      se       = se_std,
      ci_lo    = ci_l_std,
      ci_hi    = ci_u_std,
      pval     = pv,
      n_eff    = neff
    ))
  }
}

if (nrow(balance_results) > 0) {
  ## Order by variable name for consistent display
  balance_results[, label := factor(label, levels = rev(balance_results$label))]

  fig3 <- ggplot(balance_results, aes(x = coef, y = label)) +
    geom_vline(xintercept = 0, linetype = "solid",
               color = "grey50", linewidth = 0.4) +
    geom_errorbarh(aes(xmin = ci_lo, xmax = ci_hi),
                   height = 0.2, linewidth = 0.6, color = "#2171B5") +
    geom_point(size = 2.5, color = "#2171B5", fill = "white",
               shape = 21, stroke = 0.8) +
    labs(
      x = "RDD Estimate (Standardized)",
      y = NULL,
      title = "Covariate Balance at the RDD Threshold",
      subtitle = "Point estimates and 95% robust CIs from local polynomial RDD"
    ) +
    theme_pub +
    theme(
      panel.grid.major.y = element_blank(),
      axis.text.y = element_text(size = 9)
    )

  ggsave(file.path(FIG_DIR, "fig_covariate_balance.pdf"), fig3,
         width = 7, height = 5, device = cairo_pdf)
  cat("  Saved: fig_covariate_balance.pdf\n")
} else {
  cat("  WARNING: No covariates available for balance test.\n")
}


## ============================================================================
## FIGURE 4: Bandwidth Sensitivity
## ============================================================================
cat("\n── Figure 4: Bandwidth sensitivity ──\n")

## Get MSE-optimal bandwidth from main specification
main_rd <- tryCatch(
  rdrobust::rdrobust(y = rdd_nl$nl_growth, x = rdd_nl$margin, all = TRUE),
  error = function(e) NULL
)

if (!is.null(main_rd)) {
  h_opt <- main_rd$bws[1, 1]  # MSE-optimal bandwidth
  cat("  MSE-optimal bandwidth:", round(h_opt, 2), "\n")

  ## Sequence of bandwidth multipliers from 0.5 to 2.0
  bw_multipliers <- seq(0.5, 2.0, by = 0.1)
  bw_grid <- h_opt * bw_multipliers

  bw_results <- data.table(
    multiplier = numeric(),
    bandwidth  = numeric(),
    coef       = numeric(),
    se         = numeric(),
    ci_lo      = numeric(),
    ci_hi      = numeric(),
    n_eff      = numeric()
  )

  for (i in seq_along(bw_grid)) {
    h_i <- bw_grid[i]
    rd_i <- tryCatch(
      rdrobust::rdrobust(y = rdd_nl$nl_growth, x = rdd_nl$margin,
                          h = h_i, all = TRUE),
      error = function(e) NULL
    )
    if (!is.null(rd_i)) {
      bw_results <- rbind(bw_results, data.table(
        multiplier = bw_multipliers[i],
        bandwidth  = h_i,
        coef       = rd_i$coef[3],    # Robust
        se         = rd_i$se[3],
        ci_lo      = rd_i$ci[3, 1],
        ci_hi      = rd_i$ci[3, 2],
        n_eff      = sum(rd_i$N_h)
      ))
    }
  }

  if (nrow(bw_results) > 0) {
    fig4 <- ggplot(bw_results, aes(x = multiplier, y = coef)) +
      geom_hline(yintercept = 0, linetype = "solid",
                 color = "grey50", linewidth = 0.4) +
      geom_ribbon(aes(ymin = ci_lo, ymax = ci_hi),
                  fill = "#2171B5", alpha = 0.15) +
      geom_line(color = "#2171B5", linewidth = 0.8) +
      geom_point(color = "#2171B5", size = 1.8) +
      geom_vline(xintercept = 1.0, linetype = "dashed",
                 color = "grey30", linewidth = 0.5) +
      annotate("text", x = 1.02, y = max(bw_results$ci_hi, na.rm = TRUE),
               label = "MSE-optimal", hjust = 0, size = 3, color = "grey30") +
      scale_x_continuous(
        breaks = seq(0.5, 2.0, by = 0.25),
        labels = function(x) paste0(x, "h*")
      ) +
      labs(
        x = "Bandwidth (Multiple of MSE-Optimal)",
        y = "Treatment Effect on Nightlights Growth",
        title = "Bandwidth Sensitivity of Main RDD Estimate",
        subtitle = "Robust bias-corrected estimates with 95% CIs"
      ) +
      theme_pub

    ggsave(file.path(FIG_DIR, "fig_bandwidth_sensitivity.pdf"), fig4,
           width = 7, height = 5, device = cairo_pdf)
    cat("  Saved: fig_bandwidth_sensitivity.pdf\n")
  }
} else {
  cat("  WARNING: Main RDD estimation failed; skipping bandwidth sensitivity.\n")
}


## ============================================================================
## FIGURE 5: Mechanism Decomposition — Village Amenity Effects
## ============================================================================
cat("\n── Figure 5: Mechanism decomposition (village amenities) ──\n")

## Village directory outcome variables (from 02_clean_data.R)
## Use 2011 Census Village Directory outcomes
amenity_specs <- list(
  list(var = "pc11_vd_power_all",   label = "Electricity"),
  list(var = "pc11_vd_m_sch_gov",   label = "Middle Schools (Gov)"),
  list(var = "pc11_vd_s_sch_gov",   label = "Secondary Schools (Gov)"),
  list(var = "pc11_vd_comm_bank",   label = "Commercial Banks"),
  list(var = "pc11_vd_post_off",    label = "Post Offices"),
  list(var = "pc11_vd_tar_road",    label = "Paved Roads"),
  list(var = "pc11_vd_tap",         label = "Tap Water"),
  list(var = "pc11_vd_phc",         label = "Primary Health Centers"),
  list(var = "pc11_vd_prim_sch_gov", label = "Primary Schools (Gov)"),
  list(var = "pc11_vd_bus",         label = "Bus Service")
)

mech_results <- data.table(
  variable = character(),
  label    = character(),
  coef     = numeric(),
  se       = numeric(),
  ci_lo    = numeric(),
  ci_hi    = numeric(),
  pval     = numeric(),
  n_eff    = numeric()
)

for (spec in amenity_specs) {
  vname  <- spec$var
  vlabel <- spec$label

  if (!(vname %in% names(rdd_post08))) next

  d_sub <- rdd_post08[is.finite(get(vname)) & is.finite(margin)]
  if (nrow(d_sub) < 50) next

  rd_am <- tryCatch(
    rdrobust::rdrobust(y = d_sub[[vname]], x = d_sub$margin, all = TRUE),
    error = function(e) NULL
  )

  if (!is.null(rd_am)) {
    ## Standardize by control-side mean for interpretability
    ctrl_mean <- mean(d_sub[margin < 0][[vname]], na.rm = TRUE)
    denom <- ifelse(!is.na(ctrl_mean) && ctrl_mean > 0, ctrl_mean, 1)

    mech_results <- rbind(mech_results, data.table(
      variable = vname,
      label    = vlabel,
      coef     = rd_am$coef[3] / denom,
      se       = rd_am$se[3] / denom,
      ci_lo    = rd_am$ci[3, 1] / denom,
      ci_hi    = rd_am$ci[3, 2] / denom,
      pval     = rd_am$pv[3],
      n_eff    = sum(rd_am$N_h)
    ))
  }
}

if (nrow(mech_results) > 0) {
  ## Order by effect size
  mech_results <- mech_results[order(coef)]
  mech_results[, label := factor(label, levels = label)]

  ## Color by significance
  mech_results[, sig := fifelse(pval < 0.05, "p < 0.05",
                         fifelse(pval < 0.10, "p < 0.10", "n.s."))]

  fig5 <- ggplot(mech_results, aes(x = coef, y = label, color = sig)) +
    geom_vline(xintercept = 0, linetype = "solid",
               color = "grey50", linewidth = 0.4) +
    geom_errorbarh(aes(xmin = ci_lo, xmax = ci_hi),
                   height = 0.2, linewidth = 0.6) +
    geom_point(size = 2.8, shape = 16) +
    scale_color_manual(
      values = c("p < 0.05" = "#CB181D", "p < 0.10" = "#FB6A4A",
                 "n.s." = "#6BAED6"),
      name = "Significance"
    ) +
    labs(
      x = "RDD Estimate (Proportion of Control Mean)",
      y = NULL,
      title = "Effect of Criminal Politicians on Village Amenities",
      subtitle = "Post-2008 elections; robust bias-corrected estimates with 95% CIs"
    ) +
    theme_pub +
    theme(
      panel.grid.major.y = element_blank(),
      axis.text.y = element_text(size = 9)
    )

  ggsave(file.path(FIG_DIR, "fig_mechanism_decomposition.pdf"), fig5,
         width = 7, height = 5.5, device = cairo_pdf)
  cat("  Saved: fig_mechanism_decomposition.pdf\n")
} else {
  cat("  WARNING: No village amenity variables found in post-2008 data.\n")
}


## ============================================================================
## FIGURE 6: Placebo Cutoff Tests
## ============================================================================
cat("\n── Figure 6: Placebo cutoff tests ──\n")

## Test at false thresholds matching Table 6: -15, -10, -5, 0, +5, +10, +15
placebo_cutoffs <- c(-15, -10, -5, 0, 5, 10, 15)

placebo_results <- data.table(
  cutoff = numeric(),
  coef   = numeric(),
  se     = numeric(),
  ci_lo  = numeric(),
  ci_hi  = numeric(),
  pval   = numeric(),
  n_eff  = numeric()
)

for (c0 in placebo_cutoffs) {
  ## Shift the running variable so the "threshold" is at c0
  rd_plac <- tryCatch(
    rdrobust::rdrobust(y = rdd_nl$nl_growth, x = rdd_nl$margin,
                        c = c0, all = TRUE),
    error = function(e) NULL
  )

  if (!is.null(rd_plac)) {
    placebo_results <- rbind(placebo_results, data.table(
      cutoff = c0,
      coef   = rd_plac$coef[3],
      se     = rd_plac$se[3],
      ci_lo  = rd_plac$ci[3, 1],
      ci_hi  = rd_plac$ci[3, 2],
      pval   = rd_plac$pv[3],
      n_eff  = sum(rd_plac$N_h)
    ))
  }
}

if (nrow(placebo_results) > 0) {
  ## Highlight the true cutoff
  placebo_results[, is_true := cutoff == 0]

  fig6 <- ggplot(placebo_results, aes(x = cutoff, y = coef)) +
    geom_hline(yintercept = 0, linetype = "solid",
               color = "grey50", linewidth = 0.4) +
    geom_ribbon(aes(ymin = ci_lo, ymax = ci_hi), fill = "grey80",
                alpha = 0.4) +
    geom_line(color = "grey50", linewidth = 0.5, linetype = "dotted") +
    geom_point(aes(color = is_true, size = is_true), shape = 16) +
    scale_color_manual(values = c("FALSE" = "#6BAED6", "TRUE" = "#CB181D"),
                       guide = "none") +
    scale_size_manual(values = c("FALSE" = 2.2, "TRUE" = 3.5),
                      guide = "none") +
    scale_x_continuous(breaks = placebo_cutoffs) +
    labs(
      x = "Cutoff Location (Vote Margin)",
      y = "RDD Estimate (Nightlights Growth)",
      title = "Placebo Cutoff Tests",
      subtitle = "True cutoff at 0 (red); placebo cutoffs should yield null effects"
    ) +
    theme_pub

  ggsave(file.path(FIG_DIR, "fig_placebo.pdf"), fig6,
         width = 7, height = 5, device = cairo_pdf)
  cat("  Saved: fig_placebo.pdf\n")
} else {
  cat("  WARNING: Placebo tests failed; insufficient data.\n")
}


## ============================================================================
## FIGURE 7: Heterogeneity by Subgroup
## ============================================================================
cat("\n── Figure 7: Heterogeneity analysis ──\n")

## Define subgroups
## BIMARU states: Bihar, Madhya Pradesh, Rajasthan, Uttar Pradesh
## (also sometimes: Odisha, Jharkhand, Chhattisgarh, Uttarakhand)
bimaru_states <- c("bihar", "madhya pradesh", "rajasthan", "uttar pradesh",
                   "jharkhand", "chhattisgarh", "uttarakhand", "odisha")

rdd_nl[, state_lower := tolower(trimws(eci_state_name))]
rdd_nl[, is_bimaru := state_lower %in% bimaru_states]

## Crime type subgroups
## w_major = 1 if winner had major/serious criminal cases
## w_major is defined in 02_clean_data.R from ADR affidavit data
has_major <- "w_major" %in% names(rdd_nl)

het_specs <- list()

## 1. Major crime vs minor crime (among criminal winners)
if (has_major) {
  ## Subset: criminal won AND had major crime
  d_major <- rdd_nl[treatment == 1 | (treatment == 0 & TRUE)]
  ## Create indicator for major crime contests
  if ("w_major" %in% names(rdd_nl) && "r_major" %in% names(rdd_nl)) {
    rdd_nl[, major_contest := fifelse(
      (treatment == 1 & w_major == 1) | (treatment == 0 & r_major == 1),
      1L, 0L)]
    rdd_nl[, minor_contest := fifelse(
      (treatment == 1 & w_major == 0) | (treatment == 0 & r_major == 0),
      1L, 0L)]
  } else if ("w_major" %in% names(rdd_nl)) {
    rdd_nl[, major_contest := w_major]
    rdd_nl[, minor_contest := 1L - w_major]
  }

  het_specs[["Major Crime"]] <- rdd_nl[major_contest == 1 &
                                         is.finite(nl_growth)]
  het_specs[["Minor Crime"]] <- rdd_nl[minor_contest == 1 &
                                         is.finite(nl_growth)]
}

## 2. BIMARU vs non-BIMARU
het_specs[["BIMARU States"]]     <- rdd_nl[is_bimaru == TRUE &
                                             is.finite(nl_growth)]
het_specs[["Non-BIMARU States"]] <- rdd_nl[is_bimaru == FALSE &
                                             is.finite(nl_growth)]

## 3. Full sample (for reference)
het_specs[["Full Sample"]] <- rdd_nl[is.finite(nl_growth)]

## Run RDD for each subgroup
het_results <- data.table(
  subgroup = character(),
  coef     = numeric(),
  se       = numeric(),
  ci_lo    = numeric(),
  ci_hi    = numeric(),
  pval     = numeric(),
  n_eff    = numeric()
)

for (sg_name in names(het_specs)) {
  sg_data <- het_specs[[sg_name]]
  if (nrow(sg_data) < 40) {
    cat("  Skipping", sg_name, "- too few observations (", nrow(sg_data), ")\n")
    next
  }

  rd_het <- tryCatch(
    rdrobust::rdrobust(y = sg_data$nl_growth, x = sg_data$margin, all = TRUE),
    error = function(e) NULL
  )

  if (!is.null(rd_het)) {
    het_results <- rbind(het_results, data.table(
      subgroup = sg_name,
      coef     = rd_het$coef[3],
      se       = rd_het$se[3],
      ci_lo    = rd_het$ci[3, 1],
      ci_hi    = rd_het$ci[3, 2],
      pval     = rd_het$pv[3],
      n_eff    = sum(rd_het$N_h)
    ))
    cat("  ", sg_name, ": coef =", round(rd_het$coef[3], 3),
        ", p =", round(rd_het$pv[3], 3),
        ", N_eff =", sum(rd_het$N_h), "\n")
  }
}

if (nrow(het_results) > 0) {
  ## Order: Full sample first, then subgroups
  level_order <- c("Full Sample", "Major Crime", "Minor Crime",
                   "BIMARU States", "Non-BIMARU States")
  level_order <- intersect(level_order, het_results$subgroup)
  het_results[, subgroup := factor(subgroup, levels = rev(level_order))]

  ## Color by category
  het_results[, category := fcase(
    subgroup %in% c("Major Crime", "Minor Crime"), "Crime Type",
    subgroup %in% c("BIMARU States", "Non-BIMARU States"), "State Type",
    default = "Overall"
  )]

  fig7 <- ggplot(het_results, aes(x = coef, y = subgroup, color = category)) +
    geom_vline(xintercept = 0, linetype = "solid",
               color = "grey50", linewidth = 0.4) +
    geom_errorbarh(aes(xmin = ci_lo, xmax = ci_hi),
                   height = 0.25, linewidth = 0.6) +
    geom_point(size = 3, shape = 16) +
    scale_color_manual(
      values = c("Overall" = "black",
                 "Crime Type" = "#E6550D",
                 "State Type" = "#3182BD"),
      name = "Subgroup"
    ) +
    ## Add N labels to the right
    geom_text(aes(label = paste0("Eff.N=", n_eff)),
              x = max(het_results$ci_hi, na.rm = TRUE) * 1.05,
              hjust = 0, size = 3, color = "grey40", show.legend = FALSE) +
    labs(
      x = "Treatment Effect on Nightlights Growth",
      y = NULL,
      title = "Heterogeneity in the Effect of Criminal Politicians",
      subtitle = "Robust bias-corrected RDD estimates with 95% CIs"
    ) +
    theme_pub +
    theme(
      panel.grid.major.y = element_blank(),
      axis.text.y = element_text(size = 10)
    ) +
    ## Expand right margin for N labels
    coord_cartesian(clip = "off") +
    theme(plot.margin = margin(10, 50, 10, 10))

  ggsave(file.path(FIG_DIR, "fig_heterogeneity.pdf"), fig7,
         width = 7.5, height = 5, device = cairo_pdf)
  cat("  Saved: fig_heterogeneity.pdf\n")
} else {
  cat("  WARNING: No heterogeneity estimates could be computed.\n")
}


## ============================================================================
## SAVE COMPUTED RESULTS FOR REPRODUCIBILITY
## ============================================================================
cat("\n── Saving computed figure data ──\n")

figure_data <- list(
  balance     = if (exists("balance_results")) balance_results else NULL,
  bandwidth   = if (exists("bw_results")) bw_results else NULL,
  mechanisms  = if (exists("mech_results")) mech_results else NULL,
  placebos    = if (exists("placebo_results")) placebo_results else NULL,
  heterogeneity = if (exists("het_results")) het_results else NULL,
  density_pval  = if (!is.null(density_test)) density_test$test$p_jk else NA
)
saveRDS(figure_data, file.path(DATA_DIR, "figure_data.rds"))
cat("  Saved: figure_data.rds\n")

## ── Summary ──────────────────────────────────────────────────────────────
cat("\n========================================\n")
cat("FIGURE GENERATION COMPLETE\n")
cat("========================================\n")
cat("Figures saved to:", FIG_DIR, "\n")
cat("Files:\n")
for (f in list.files(FIG_DIR, pattern = "\\.pdf$")) {
  cat("  ", f, "\n")
}
