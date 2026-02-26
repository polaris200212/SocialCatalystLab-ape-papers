## ============================================================================
## 03_main_analysis.R — Primary RDD regressions
## APEP-0466: Municipal Population Thresholds and Firm Creation in France
## ============================================================================

source("00_packages.R")

data_dir <- "../data"
panel <- fread(file.path(data_dir, "analysis_panel.csv"))
commune_means <- fread(file.path(data_dir, "commune_means.csv"))

results_list <- list()

# ===========================================================================
# 1. SINGLE-CUTOFF RDD AT EACH THRESHOLD
# ===========================================================================
cat("=== Single-cutoff RDD at each threshold ===\n")

rdd_thresholds <- c(500, 1000, 1500, 3500, 10000)
threshold_labels <- c("500", "1,000", "1,500", "3,500", "10,000")

for (k in seq_along(rdd_thresholds)) {
  thresh <- rdd_thresholds[k]
  bw_max <- thresh * 0.5

  # Use commune-level means (cross-sectional)
  df <- commune_means[abs(population - thresh) <= bw_max]
  if (nrow(df) < 50) {
    cat(sprintf("  Threshold %d: insufficient observations (%d)\n", thresh, nrow(df)))
    next
  }

  cat(sprintf("\n--- Threshold %s (N = %d communes) ---\n", threshold_labels[k], nrow(df)))

  # rdrobust estimation (masspoints="adjust" handles discrete running variable)
  rd_out <- tryCatch({
    rdrobust(
      y = df$mean_creation_rate,
      x = df$population,
      c = thresh,
      kernel = "triangular",
      p = 1,
      bwselect = "mserd",
      masspoints = "adjust"
    )
  }, error = function(e) {
    cat(sprintf("  rdrobust failed: %s\n", e$message))
    NULL
  })

  if (!is.null(rd_out)) {
    cat(sprintf("  Estimate: %.3f (SE: %.3f, p: %.4f)\n",
                rd_out$coef[1], rd_out$se[1], rd_out$pv[1]))
    cat(sprintf("  Bandwidth: %.0f (eff N: %d left, %d right)\n",
                rd_out$bws[1, 1], rd_out$N_h[1], rd_out$N_h[2]))
    cat(sprintf("  95%% CI: [%.3f, %.3f]\n",
                rd_out$ci[1, 1], rd_out$ci[1, 2]))

    results_list[[threshold_labels[k]]] <- data.table(
      threshold = thresh,
      estimate = rd_out$coef[1],
      se_robust = rd_out$se[3],
      se_conv = rd_out$se[1],
      pvalue = rd_out$pv[1],
      ci_lower = rd_out$ci[1, 1],
      ci_upper = rd_out$ci[1, 2],
      bandwidth = rd_out$bws[1, 1],
      n_left = rd_out$N_h[1],
      n_right = rd_out$N_h[2],
      n_total = nrow(df)
    )
  }
}

# ===========================================================================
# 2. POOLED MULTI-CUTOFF RDD
# ===========================================================================
cat("\n\n=== Pooled multi-cutoff RDD (Cattaneo et al. 2016) ===\n")

# Normalize running variable: distance to nearest threshold / threshold
# Pool across all cutoffs
pooled_df <- data.table()
for (thresh in rdd_thresholds) {
  bw_max <- thresh * 0.5
  tmp <- commune_means[abs(population - thresh) <= bw_max]
  if (nrow(tmp) == 0) next

  # Nearest threshold must be this one
  tmp <- tmp[sapply(population, function(p) {
    rdd_thresholds[which.min(abs(p - rdd_thresholds))] == thresh
  })]

  tmp[, `:=`(
    normalized_x = (population - thresh) / thresh,
    above = as.integer(population >= thresh),
    cutoff = thresh
  )]
  pooled_df <- rbind(pooled_df, tmp, fill = TRUE)
}

cat(sprintf("Pooled sample: %d communes across %d cutoffs\n",
            nrow(pooled_df), length(unique(pooled_df$cutoff))))

# Pooled RDD with normalized running variable
pooled_rd <- tryCatch({
  rdrobust(
    y = pooled_df$mean_creation_rate,
    x = pooled_df$normalized_x,
    c = 0,
    kernel = "triangular",
    p = 1,
    bwselect = "mserd",
    masspoints = "adjust"
  )
}, error = function(e) {
  cat(sprintf("  Pooled rdrobust failed: %s\n", e$message))
  NULL
})

if (!is.null(pooled_rd)) {
  cat(sprintf("  Pooled estimate: %.3f (SE: %.3f, p: %.4f)\n",
              pooled_rd$coef[1], pooled_rd$se[1], pooled_rd$pv[1]))
  cat(sprintf("  Bandwidth: %.3f (normalized)\n", pooled_rd$bws[1, 1]))

  results_list[["Pooled"]] <- data.table(
    threshold = 0,
    estimate = pooled_rd$coef[1],
    se_robust = pooled_rd$se[3],
    se_conv = pooled_rd$se[1],
    pvalue = pooled_rd$pv[1],
    ci_lower = pooled_rd$ci[1, 1],
    ci_upper = pooled_rd$ci[1, 2],
    bandwidth = pooled_rd$bws[1, 1],
    n_left = pooled_rd$N_h[1],
    n_right = pooled_rd$N_h[2],
    n_total = nrow(pooled_df)
  )
}

# ===========================================================================
# 3. PARAMETRIC RDD (for comparison)
# ===========================================================================
cat("\n\n=== Parametric RDD (fixest) at 3,500 threshold ===\n")

# Panel-level analysis at 3,500 threshold
thresh <- 3500
bw <- 1000
panel_3500 <- panel[abs(population - thresh) <= bw & !election_year]
panel_3500[, above := as.integer(population >= thresh)]
panel_3500[, dist := population - thresh]

# Basic parametric RDD (commune-clustered SEs)
param_basic <- feols(
  creation_rate ~ above + dist + above:dist | dep_code + year,
  data = panel_3500,
  cluster = ~code_insee
)
cat("Parametric RDD (linear, dept+year FE):\n")
print(summary(param_basic))

# Quadratic
panel_3500[, dist2 := dist^2]
param_quad <- feols(
  creation_rate ~ above + dist + dist2 + above:dist + above:dist2 | dep_code + year,
  data = panel_3500,
  cluster = ~code_insee
)
cat("\nParametric RDD (quadratic):\n")
print(summary(param_quad))

# ===========================================================================
# 4. DiDisc AT 3,500 (PRE/POST 2013 ELECTORAL REFORM)
# ===========================================================================
cat("\n\n=== Difference-in-Discontinuities at 3,500 ===\n")

panel_3500[, post_reform := as.integer(year >= 2014)]

# DiDisc: interact above threshold with post-reform
# Cluster at commune level (commune is the unit of treatment variation)
didisc <- feols(
  creation_rate ~ above * post_reform + dist + above:dist +
    post_reform:dist + above:post_reform:dist | dep_code + year,
  data = panel_3500,
  cluster = ~code_insee
)
cat("DiDisc (above x post-2013 reform, commune-clustered):\n")
print(summary(didisc))

# ===========================================================================
# 5. SAVE RESULTS
# ===========================================================================

results_table <- rbindlist(results_list, fill = TRUE)
fwrite(results_table, file.path(data_dir, "rdd_results.csv"))

# Save parametric models for table generation
save(param_basic, param_quad, didisc, pooled_rd,
     file = file.path(data_dir, "regression_models.RData"))

cat("\n=== Main analysis complete ===\n")
cat(sprintf("Results saved: %d specifications\n", nrow(results_table)))
