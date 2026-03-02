## 04_robustness.R — Robustness checks
## APEP-0458: Second Home Caps and Local Labor Markets

source("code/00_packages.R")

cat("\n=== ROBUSTNESS CHECKS ===\n")

rdd <- fread("data/rdd_cross_section.csv")
rdd[is.infinite(emp_growth_post), emp_growth_post := NA]
rdd <- rdd[!is.na(emp_total_pre) & emp_total_pre > 0]

# Primary outcome for robustness: emp_growth_post
y <- rdd$emp_growth_post
x <- rdd$running
valid <- !is.na(y) & !is.na(x)

# ---------------------------------------------------------------------------
# 1. Bandwidth Sensitivity
# ---------------------------------------------------------------------------
cat("1. Bandwidth sensitivity...\n")

# Get CCT optimal bandwidth first
rd_main <- rdrobust(y[valid], x[valid], c = 0, kernel = "triangular")
bw_opt <- rd_main$bws[1, 1]
cat("  Optimal bandwidth:", round(bw_opt, 2), "\n")

bw_fractions <- c(0.5, 0.75, 1.0, 1.25, 1.5, 2.0)
bw_results <- list()

for (frac in bw_fractions) {
  bw <- bw_opt * frac

  if (frac == 1.0) {
    # Use exact main results (avoids SE discrepancy from manual h specification)
    bw_results[["1"]] <- data.table(
      fraction = 1.0,
      bandwidth = bw_opt,
      estimate = rd_main$coef[1],
      se_robust = rd_main$se[3],
      pv_robust = rd_main$pv[3],
      ci_lower = rd_main$ci[3, 1],
      ci_upper = rd_main$ci[3, 2],
      n = rd_main$N_h[1] + rd_main$N_h[2]
    )
    cat("  bw =", round(bw_opt, 1), "( 1 x): est =", round(rd_main$coef[1], 3),
        ", p =", round(rd_main$pv[3], 3), ", n =", rd_main$N_h[1] + rd_main$N_h[2], "\n")
    next
  }

  rd_bw <- tryCatch({
    rdrobust(y[valid], x[valid], c = 0, h = bw, kernel = "triangular")
  }, error = function(e) NULL)

  if (!is.null(rd_bw)) {
    bw_results[[as.character(frac)]] <- data.table(
      fraction = frac,
      bandwidth = bw,
      estimate = rd_bw$coef[1],
      se_robust = rd_bw$se[3],
      pv_robust = rd_bw$pv[3],
      ci_lower = rd_bw$ci[3, 1],
      ci_upper = rd_bw$ci[3, 2],
      n = rd_bw$N_h[1] + rd_bw$N_h[2]
    )
    cat("  bw =", round(bw, 1), "(", frac, "x): est =", round(rd_bw$coef[1], 3),
        ", p =", round(rd_bw$pv[3], 3), ", n =", rd_bw$N_h[1] + rd_bw$N_h[2], "\n")
  }
}

bw_dt <- rbindlist(bw_results)
fwrite(bw_dt, "data/robustness_bandwidth.csv")

# ---------------------------------------------------------------------------
# 2. Polynomial Order Sensitivity
# ---------------------------------------------------------------------------
cat("\n2. Polynomial order sensitivity...\n")

poly_results <- list()
for (p in 1:3) {
  rd_p <- tryCatch({
    rdrobust(y[valid], x[valid], c = 0, p = p, kernel = "triangular")
  }, error = function(e) NULL)

  if (!is.null(rd_p)) {
    poly_results[[as.character(p)]] <- data.table(
      poly_order = p,
      estimate = rd_p$coef[1],
      se_robust = rd_p$se[3],
      pv_robust = rd_p$pv[3],
      bw = rd_p$bws[1, 1],
      n = rd_p$N_h[1] + rd_p$N_h[2]
    )
    cat("  p =", p, ": est =", round(rd_p$coef[1], 3),
        ", p =", round(rd_p$pv[3], 3), "\n")
  }
}

poly_dt <- rbindlist(poly_results)
fwrite(poly_dt, "data/robustness_polynomial.csv")

# ---------------------------------------------------------------------------
# 3. Kernel Sensitivity
# ---------------------------------------------------------------------------
cat("\n3. Kernel sensitivity...\n")

kernels <- c("triangular", "uniform", "epanechnikov")
kernel_results <- list()

for (k in kernels) {
  rd_k <- tryCatch({
    rdrobust(y[valid], x[valid], c = 0, kernel = k)
  }, error = function(e) NULL)

  if (!is.null(rd_k)) {
    kernel_results[[k]] <- data.table(
      kernel = k,
      estimate = rd_k$coef[1],
      se_robust = rd_k$se[3],
      pv_robust = rd_k$pv[3],
      bw = rd_k$bws[1, 1],
      n = rd_k$N_h[1] + rd_k$N_h[2]
    )
    cat("  ", k, ": est =", round(rd_k$coef[1], 3),
        ", p =", round(rd_k$pv[3], 3), "\n")
  }
}

kernel_dt <- rbindlist(kernel_results)
fwrite(kernel_dt, "data/robustness_kernel.csv")

# ---------------------------------------------------------------------------
# 4. Placebo Thresholds
# ---------------------------------------------------------------------------
cat("\n4. Placebo threshold tests...\n")

placebo_thresholds <- c(10, 12, 15, 25, 30, 35)
placebo_results <- list()

for (thr in placebo_thresholds) {
  x_placebo <- rdd$zwa_pct - thr
  valid_p <- !is.na(y) & !is.na(x_placebo)

  rd_pl <- tryCatch({
    rdrobust(y[valid_p], x_placebo[valid_p], c = 0, kernel = "triangular")
  }, error = function(e) NULL)

  if (!is.null(rd_pl)) {
    placebo_results[[as.character(thr)]] <- data.table(
      threshold = thr,
      estimate = rd_pl$coef[1],
      se_robust = rd_pl$se[3],
      pv_robust = rd_pl$pv[3],
      bw = rd_pl$bws[1, 1],
      n = rd_pl$N_h[1] + rd_pl$N_h[2]
    )
    cat("  threshold =", thr, "%: est =", round(rd_pl$coef[1], 3),
        ", p =", round(rd_pl$pv[3], 3), "\n")
  }
}

placebo_dt <- rbindlist(placebo_results)
fwrite(placebo_dt, "data/robustness_placebo.csv")

# ---------------------------------------------------------------------------
# 5. Donut-Hole RDD
# ---------------------------------------------------------------------------
cat("\n5. Donut-hole RDD (exclude ±1 pp from threshold)...\n")

donut_sizes <- c(0.5, 1, 2)
donut_results <- list()

for (d in donut_sizes) {
  donut_idx <- valid & (abs(x) > d)

  if (sum(donut_idx) < 50) {
    cat("  donut =", d, ": too few obs\n")
    next
  }

  rd_donut <- tryCatch({
    rdrobust(y[donut_idx], x[donut_idx], c = 0, kernel = "triangular")
  }, error = function(e) NULL)

  if (!is.null(rd_donut)) {
    donut_results[[as.character(d)]] <- data.table(
      donut_size = d,
      estimate = rd_donut$coef[1],
      se_robust = rd_donut$se[3],
      pv_robust = rd_donut$pv[3],
      bw = rd_donut$bws[1, 1],
      n = rd_donut$N_h[1] + rd_donut$N_h[2]
    )
    cat("  donut =", d, "pp: est =", round(rd_donut$coef[1], 3),
        ", p =", round(rd_donut$pv[3], 3), "\n")
  }
}

if (length(donut_results) > 0) {
  donut_dt <- rbindlist(donut_results)
  fwrite(donut_dt, "data/robustness_donut.csv")
}

# ---------------------------------------------------------------------------
# 6. Pre-treatment placebo (2011 outcomes at 20% threshold)
# ---------------------------------------------------------------------------
cat("\n6. Pre-treatment outcome balance (2011)...\n")

panel <- fread("data/analysis_panel.csv")
panel[is.infinite(share_tertiary), share_tertiary := NA]
panel <- panel[!is.na(emp_total) & emp_total > 0]

pre_2011 <- panel[year == 2011]
pre_y <- log(pre_2011$emp_total + 1)
pre_x <- pre_2011$running
pre_valid <- !is.na(pre_y) & !is.na(pre_x)

rd_pre <- tryCatch({
  rdrobust(pre_y[pre_valid], pre_x[pre_valid], c = 0, kernel = "triangular")
}, error = function(e) NULL)

if (!is.null(rd_pre)) {
  cat("  2011 log employment at threshold: est =", round(rd_pre$coef[1], 3),
      ", p =", round(rd_pre$pv[3], 3), "\n")
}

# ---------------------------------------------------------------------------
# 7. Leave-One-Out Jackknife (within optimal bandwidth)
# ---------------------------------------------------------------------------
cat("\n7. Leave-one-out jackknife (employment growth)...\n")

bw_main <- rd_main$bws[1, 1]
in_bw <- valid & abs(x) <= bw_main
idx_bw <- which(in_bw)

jackknife_estimates <- numeric(length(idx_bw))
for (j in seq_along(idx_bw)) {
  drop_idx <- idx_bw[j]
  jk_valid <- in_bw
  jk_valid[drop_idx] <- FALSE
  # Re-estimate with same bandwidth on leave-one-out sample
  rd_jk <- tryCatch({
    rdrobust(y[jk_valid], x[jk_valid], c = 0, h = bw_main, kernel = "triangular")
  }, error = function(e) NULL)
  if (!is.null(rd_jk)) {
    jackknife_estimates[j] <- rd_jk$coef[1]
  } else {
    jackknife_estimates[j] <- NA
  }
}

jk_valid_est <- jackknife_estimates[!is.na(jackknife_estimates)]
cat("  Full-sample estimate:", round(rd_main$coef[1], 4), "\n")
cat("  Jackknife range: [", round(min(jk_valid_est), 4), ",",
    round(max(jk_valid_est), 4), "]\n")
cat("  Jackknife mean:", round(mean(jk_valid_est), 4), "\n")
cat("  Jackknife SD:", round(sd(jk_valid_est), 4), "\n")
cat("  Max influence (|est - mean|):", round(max(abs(jk_valid_est - mean(jk_valid_est))), 4), "\n")

jk_dt <- data.table(
  obs_dropped = seq_along(jackknife_estimates),
  estimate = jackknife_estimates
)
fwrite(jk_dt, "data/robustness_jackknife.csv")

cat("\n=== ROBUSTNESS CHECKS DONE ===\n")
