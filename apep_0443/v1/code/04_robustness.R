# ============================================================================
# 04_robustness.R — Robustness checks for RDD
# APEP-0443: PMGSY Roads and the Gender Gap in Non-Farm Employment
# ============================================================================

source("00_packages.R")

data_dir <- normalizePath(file.path(getwd(), "..", "data"), mustWork = FALSE)
df <- fread(file.path(data_dir, "plains_sample.csv"))
df_hills <- fread(file.path(data_dir, "hills_sample.csv"))

# Primary outcome for robustness: female non-ag share (2011)
y_main <- df$nonag_share_f11
x_main <- df$running_var
cl_main <- df$pc11_district_id

# ── 1. Bandwidth Sensitivity ──────────────────────────────────────────────
cat("\n=== Bandwidth Sensitivity ===\n")

# Get optimal bandwidth from main spec
rd_opt <- rdrobust(y_main, x_main, c = 0, cluster = cl_main)
h_opt <- rd_opt$bws[1, 1]

bw_multipliers <- c(0.5, 0.75, 1.0, 1.25, 1.5, 2.0)
bw_results <- data.frame()

for (mult in bw_multipliers) {
  h <- h_opt * mult
  rd <- tryCatch(
    rdrobust(y_main, x_main, c = 0, h = h, cluster = cl_main),
    error = function(e) NULL
  )
  if (!is.null(rd)) {
    bw_results <- rbind(bw_results, data.frame(
      multiplier = mult,
      bandwidth = h,
      rd_est = rd$coef[2],
      se = rd$se[3],
      pval = rd$pv[3],
      n_eff = rd$N_h[1] + rd$N_h[2]
    ))
    cat(sprintf("  BW = %.0f (%.0f%% of optimal): RD = %.4f (SE = %.4f, p = %.4f)\n",
                h, mult * 100, rd$coef[2], rd$se[3], rd$pv[3]))
  }
}

fwrite(bw_results, "../tables/robustness_bandwidth.csv")

# ── 2. Placebo Cutoffs ────────────────────────────────────────────────────
cat("\n=== Placebo Cutoffs ===\n")

placebo_cutoffs <- c(-100, -50, 50, 100)  # Relative to true cutoff of 500
placebo_results <- data.frame()

for (pc in placebo_cutoffs) {
  x_placebo <- df$pop01 - (500 + pc)
  rd <- tryCatch(
    rdrobust(y_main, x_placebo, c = 0, cluster = cl_main),
    error = function(e) NULL
  )
  if (!is.null(rd)) {
    placebo_results <- rbind(placebo_results, data.frame(
      cutoff = 500 + pc,
      rd_est = rd$coef[2],
      se = rd$se[3],
      pval = rd$pv[3],
      n_eff = rd$N_h[1] + rd$N_h[2]
    ))
    cat(sprintf("  Cutoff = %d: RD = %.4f (SE = %.4f, p = %.4f)\n",
                500 + pc, rd$coef[2], rd$se[3], rd$pv[3]))
  }
}

# Add true cutoff
placebo_results <- rbind(
  data.frame(cutoff = 500, rd_est = rd_opt$coef[2], se = rd_opt$se[3],
             pval = rd_opt$pv[3], n_eff = rd_opt$N_h[1] + rd_opt$N_h[2]),
  placebo_results
)

fwrite(placebo_results, "../tables/robustness_placebo.csv")

# ── 3. Polynomial Order ───────────────────────────────────────────────────
cat("\n=== Polynomial Order Sensitivity ===\n")

poly_results <- data.frame()
for (p in 1:3) {
  rd <- tryCatch(
    rdrobust(y_main, x_main, c = 0, p = p, cluster = cl_main),
    error = function(e) NULL
  )
  if (!is.null(rd)) {
    poly_results <- rbind(poly_results, data.frame(
      poly_order = p,
      rd_est = rd$coef[2],
      se = rd$se[3],
      pval = rd$pv[3],
      bw = rd$bws[1, 1]
    ))
    cat(sprintf("  p = %d: RD = %.4f (SE = %.4f, p = %.4f, BW = %.0f)\n",
                p, rd$coef[2], rd$se[3], rd$pv[3], rd$bws[1, 1]))
  }
}

fwrite(poly_results, "../tables/robustness_polynomial.csv")

# ── 4. Kernel Sensitivity ─────────────────────────────────────────────────
cat("\n=== Kernel Sensitivity ===\n")

kernel_results <- data.frame()
for (kern in c("triangular", "uniform", "epanechnikov")) {
  rd <- tryCatch(
    rdrobust(y_main, x_main, c = 0, kernel = kern, cluster = cl_main),
    error = function(e) NULL
  )
  if (!is.null(rd)) {
    kernel_results <- rbind(kernel_results, data.frame(
      kernel = kern,
      rd_est = rd$coef[2],
      se = rd$se[3],
      pval = rd$pv[3]
    ))
    cat(sprintf("  %s: RD = %.4f (SE = %.4f, p = %.4f)\n",
                kern, rd$coef[2], rd$se[3], rd$pv[3]))
  }
}

fwrite(kernel_results, "../tables/robustness_kernel.csv")

# ── 5. Donut Hole ─────────────────────────────────────────────────────────
cat("\n=== Donut Hole Sensitivity ===\n")

donut_results <- data.frame()
for (d in c(0, 5, 10, 25, 50)) {
  mask <- abs(x_main) >= d & !is.na(y_main)
  if (sum(mask) < 200) next

  rd <- tryCatch(
    rdrobust(y_main[mask], x_main[mask], c = 0, cluster = cl_main[mask]),
    error = function(e) NULL
  )
  if (!is.null(rd)) {
    donut_results <- rbind(donut_results, data.frame(
      donut = d,
      rd_est = rd$coef[2],
      se = rd$se[3],
      pval = rd$pv[3],
      n_eff = rd$N_h[1] + rd$N_h[2]
    ))
    cat(sprintf("  Donut = %d: RD = %.4f (SE = %.4f, p = %.4f)\n",
                d, rd$coef[2], rd$se[3], rd$pv[3]))
  }
}

fwrite(donut_results, "../tables/robustness_donut.csv")

# ── 6. Hill/Tribal States (250 threshold) ─────────────────────────────────
cat("\n=== Hill/Tribal States (250 threshold) ===\n")

y_hill <- df_hills$nonag_share_f11
x_hill <- df_hills$running_var
cl_hill <- df_hills$pc11_district_id
valid_hill <- !is.na(y_hill) & !is.na(x_hill)

if (sum(valid_hill) > 200) {
  rd_hill <- tryCatch(
    rdrobust(y_hill[valid_hill], x_hill[valid_hill], c = 0,
             cluster = cl_hill[valid_hill]),
    error = function(e) {
      cat(sprintf("  Hill RDD error: %s\n", e$message))
      NULL
    }
  )
  if (!is.null(rd_hill)) {
    cat(sprintf("  Hill (250 threshold): RD = %.4f (SE = %.4f, p = %.4f, N_eff = %d)\n",
                rd_hill$coef[2], rd_hill$se[3], rd_hill$pv[3],
                rd_hill$N_h[1] + rd_hill$N_h[2]))
    saveRDS(rd_hill, "../data/rd_hill.rds")
  }
}

# ── 7. Male outcomes as comparison ────────────────────────────────────────
cat("\n=== Male Outcomes (Comparison) ===\n")

male_outcomes <- list(
  list(name = "nonag_share_m11", label = "Male Non-Ag Share (2011)"),
  list(name = "d_nonag_share_m", label = "Change in Male Non-Ag Share"),
  list(name = "lfpr_m11",        label = "Male LFPR (2011)"),
  list(name = "d_lfpr_m",        label = "Change in Male LFPR")
)

male_results <- data.frame()
for (ov in male_outcomes) {
  y <- df[[ov$name]]
  valid <- !is.na(y) & !is.na(x_main)
  rd <- tryCatch(
    rdrobust(y[valid], x_main[valid], c = 0, cluster = cl_main[valid]),
    error = function(e) NULL
  )
  if (!is.null(rd)) {
    male_results <- rbind(male_results, data.frame(
      outcome = ov$label,
      rd_est = rd$coef[2],
      se = rd$se[3],
      pval = rd$pv[3]
    ))
    cat(sprintf("  %-40s: RD = %.4f (SE = %.4f, p = %.4f)\n",
                ov$label, rd$coef[2], rd$se[3], rd$pv[3]))
  }
}

fwrite(male_results, "../tables/robustness_male.csv")

cat("\nRobustness checks complete.\n")
