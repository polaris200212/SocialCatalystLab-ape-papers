## 04_robustness.R — Robustness checks, placebo tests, heterogeneity
## APEP-0281: Mandatory Energy Disclosure and Property Values (RDD)

source("00_packages.R")

pluto <- readRDS(file.path(data_dir, "pluto_analysis.rds"))
rdd_narrow <- readRDS(file.path(data_dir, "rdd_narrow.rds"))
rdd_broad <- readRDS(file.path(data_dir, "rdd_broad.rds"))

# ============================================================
# 1. Bandwidth Sensitivity
# ============================================================
cat("=== Bandwidth Sensitivity ===\n")

# Get MSE-optimal bandwidth from main spec
rd_main <- rdrobust(
  y = rdd_narrow$log_assesstot,
  x = rdd_narrow$gfa_centered,
  c = 0, kernel = "triangular", p = 1, bwselect = "mserd"
)
h_opt <- rd_main$bws[1, 1]

# Test at 50%, 75%, 100%, 125%, 150%, 200% of optimal
bw_multipliers <- c(0.5, 0.75, 1.0, 1.25, 1.5, 2.0)
bw_results <- list()

for (mult in bw_multipliers) {
  h <- h_opt * mult
  rd_bw <- tryCatch(
    rdrobust(
      y = rdd_narrow$log_assesstot,
      x = rdd_narrow$gfa_centered,
      c = 0, kernel = "triangular", p = 1, h = h
    ),
    error = function(e) NULL
  )

  if (!is.null(rd_bw)) {
    bw_results[[paste0("bw_", mult)]] <- list(
      multiplier = mult,
      bandwidth = h,
      estimate = rd_bw$coef[1],
      se = rd_bw$se[3],
      pvalue = rd_bw$pv[3],
      ci_lower = rd_bw$ci[3, 1],
      ci_upper = rd_bw$ci[3, 2],
      n_left = rd_bw$N_h[1],
      n_right = rd_bw$N_h[2]
    )
    cat(sprintf("  BW = %.0f (%.0f%%): coef = %.4f, p = %.4f, N = %d\n",
                h, mult * 100, rd_bw$coef[1], rd_bw$pv[3],
                rd_bw$N_h[1] + rd_bw$N_h[2]))
  }
}

# ============================================================
# 2. Polynomial Order Sensitivity
# ============================================================
cat("\n=== Polynomial Order Sensitivity ===\n")

poly_results <- list()
for (p_order in 1:3) {
  rd_poly <- tryCatch(
    rdrobust(
      y = rdd_narrow$log_assesstot,
      x = rdd_narrow$gfa_centered,
      c = 0, kernel = "triangular", p = p_order, bwselect = "mserd"
    ),
    error = function(e) NULL
  )

  if (!is.null(rd_poly)) {
    poly_results[[paste0("p_", p_order)]] <- list(
      order = p_order,
      estimate = rd_poly$coef[1],
      se = rd_poly$se[3],
      pvalue = rd_poly$pv[3],
      bw = rd_poly$bws[1, 1]
    )
    cat(sprintf("  p = %d: coef = %.4f, p = %.4f (bw = %.0f)\n",
                p_order, rd_poly$coef[1], rd_poly$pv[3], rd_poly$bws[1, 1]))
  }
}

# ============================================================
# 3. Kernel Sensitivity
# ============================================================
cat("\n=== Kernel Sensitivity ===\n")

kernel_results <- list()
for (kern in c("triangular", "epanechnikov", "uniform")) {
  rd_kern <- tryCatch(
    rdrobust(
      y = rdd_narrow$log_assesstot,
      x = rdd_narrow$gfa_centered,
      c = 0, kernel = kern, p = 1, bwselect = "mserd"
    ),
    error = function(e) NULL
  )

  if (!is.null(rd_kern)) {
    kernel_results[[kern]] <- list(
      kernel = kern,
      estimate = rd_kern$coef[1],
      se = rd_kern$se[3],
      pvalue = rd_kern$pv[3]
    )
    cat(sprintf("  %s: coef = %.4f, p = %.4f\n",
                kern, rd_kern$coef[1], rd_kern$pv[3]))
  }
}

# ============================================================
# 4. Donut RDD (exclude observations near cutoff)
# ============================================================
cat("\n=== Donut RDD ===\n")

donut_results <- list()
for (donut in c(500, 1000, 2000)) {
  donut_data <- rdd_narrow %>%
    filter(abs(gfa_centered) > donut)

  rd_donut <- tryCatch(
    rdrobust(
      y = donut_data$log_assesstot,
      x = donut_data$gfa_centered,
      c = 0, kernel = "triangular", p = 1, bwselect = "mserd"
    ),
    error = function(e) NULL
  )

  if (!is.null(rd_donut)) {
    donut_results[[paste0("donut_", donut)]] <- list(
      donut_width = donut,
      estimate = rd_donut$coef[1],
      se = rd_donut$se[3],
      pvalue = rd_donut$pv[3],
      n_eff = rd_donut$N_h[1] + rd_donut$N_h[2]
    )
    cat(sprintf("  Donut = %d sq ft: coef = %.4f, p = %.4f, N = %d\n",
                donut, rd_donut$coef[1], rd_donut$pv[3],
                rd_donut$N_h[1] + rd_donut$N_h[2]))
  }
}

# ============================================================
# 5. Placebo Cutoffs
# ============================================================
cat("\n=== Placebo Cutoffs ===\n")

placebo_cutoffs <- c(15000, 20000, 30000, 35000, 40000, 45000)
placebo_results <- list()

for (cutoff in placebo_cutoffs) {
  # Use broad sample to have data on both sides
  placebo_data <- rdd_broad %>%
    mutate(placebo_centered = gfa - cutoff)

  rd_placebo <- tryCatch(
    rdrobust(
      y = placebo_data$log_assesstot,
      x = placebo_data$placebo_centered,
      c = 0, kernel = "triangular", p = 1, bwselect = "mserd"
    ),
    error = function(e) NULL
  )

  if (!is.null(rd_placebo)) {
    placebo_results[[paste0("cutoff_", cutoff)]] <- list(
      cutoff = cutoff,
      estimate = rd_placebo$coef[1],
      se = rd_placebo$se[3],
      pvalue = rd_placebo$pv[3]
    )
    cat(sprintf("  Cutoff = %d: coef = %.4f, p = %.4f\n",
                cutoff, rd_placebo$coef[1], rd_placebo$pv[3]))
  }
}

# ============================================================
# 6. Heterogeneity by Building Type
# ============================================================
cat("\n=== Heterogeneity by Building Type ===\n")

het_type_results <- list()
for (use_type in c("Residential", "Commercial", "Mixed/Institutional")) {
  subset_data <- rdd_narrow %>% filter(landuse_cat == use_type)

  if (nrow(subset_data) < 100) {
    cat(sprintf("  %s: too few observations (%d)\n", use_type, nrow(subset_data)))
    next
  }

  rd_het <- tryCatch(
    rdrobust(
      y = subset_data$log_assesstot,
      x = subset_data$gfa_centered,
      c = 0, kernel = "triangular", p = 1, bwselect = "mserd"
    ),
    error = function(e) NULL
  )

  if (!is.null(rd_het)) {
    het_type_results[[use_type]] <- list(
      type = use_type,
      n = nrow(subset_data),
      estimate = rd_het$coef[1],
      se = rd_het$se[3],
      pvalue = rd_het$pv[3]
    )
    cat(sprintf("  %s (N=%d): coef = %.4f, p = %.4f\n",
                use_type, nrow(subset_data), rd_het$coef[1], rd_het$pv[3]))
  }
}

# ============================================================
# 7. Heterogeneity by Borough
# ============================================================
cat("\n=== Heterogeneity by Borough ===\n")

het_boro_results <- list()
for (boro in c("Manhattan", "Brooklyn", "Queens", "Bronx")) {
  subset_data <- rdd_narrow %>% filter(borough_name == boro)

  if (nrow(subset_data) < 100) {
    cat(sprintf("  %s: too few observations (%d)\n", boro, nrow(subset_data)))
    next
  }

  rd_het <- tryCatch(
    rdrobust(
      y = subset_data$log_assesstot,
      x = subset_data$gfa_centered,
      c = 0, kernel = "triangular", p = 1, bwselect = "mserd"
    ),
    error = function(e) NULL
  )

  if (!is.null(rd_het)) {
    het_boro_results[[boro]] <- list(
      borough = boro,
      n = nrow(subset_data),
      estimate = rd_het$coef[1],
      se = rd_het$se[3],
      pvalue = rd_het$pv[3]
    )
    cat(sprintf("  %s (N=%d): coef = %.4f, p = %.4f\n",
                boro, nrow(subset_data), rd_het$coef[1], rd_het$pv[3]))
  }
}

# ============================================================
# 8. Heterogeneity by Building Age Cohort
# ============================================================
cat("\n=== Heterogeneity by Building Age ===\n")

het_age_results <- list()
age_cuts <- list(
  "Pre-1940" = c(0, 1940),
  "1940-1980" = c(1940, 1980),
  "Post-1980" = c(1980, 2025)
)

for (cohort_name in names(age_cuts)) {
  yrs <- age_cuts[[cohort_name]]
  subset_data <- rdd_narrow %>%
    filter(yearbuilt >= yrs[1], yearbuilt < yrs[2])

  if (nrow(subset_data) < 100) {
    cat(sprintf("  %s: too few observations (%d)\n", cohort_name, nrow(subset_data)))
    next
  }

  rd_het <- tryCatch(
    rdrobust(
      y = subset_data$log_assesstot,
      x = subset_data$gfa_centered,
      c = 0, kernel = "triangular", p = 1, bwselect = "mserd"
    ),
    error = function(e) NULL
  )

  if (!is.null(rd_het)) {
    het_age_results[[cohort_name]] <- list(
      cohort = cohort_name,
      n = nrow(subset_data),
      estimate = rd_het$coef[1],
      se = rd_het$se[3],
      pvalue = rd_het$pv[3]
    )
    cat(sprintf("  %s (N=%d): coef = %.4f, p = %.4f\n",
                cohort_name, nrow(subset_data), rd_het$coef[1], rd_het$pv[3]))
  }
}

# ============================================================
# 9. Save all robustness results
# ============================================================
robustness <- list(
  bandwidth = bw_results,
  polynomial = poly_results,
  kernel = kernel_results,
  donut = donut_results,
  placebo = placebo_results,
  het_type = het_type_results,
  het_borough = het_boro_results,
  het_age = het_age_results
)

saveRDS(robustness, file.path(data_dir, "robustness_results.rds"))

cat("\n=== Robustness Analysis Complete ===\n")
