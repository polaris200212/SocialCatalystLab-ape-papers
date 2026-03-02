###############################################################################
# 04_robustness.R
# Robustness checks for RDD estimates
# APEP-0445
###############################################################################

source(file.path(dirname(sys.frame(1)$ofile %||% "."), "00_packages.R"))

rdd_sample <- readRDS(file.path(data_dir, "rdd_sample.rds"))
panel_rdd <- readRDS(file.path(data_dir, "panel_rdd.rds"))
cat("Data loaded\n\n")


###############################################################################
# 1. Bandwidth Sensitivity
###############################################################################
cat("=== Bandwidth Sensitivity ===\n")

# Get optimal bandwidth from main results
main_results <- readRDS(file.path(data_dir, "main_rdd_results.rds"))
opt_bw <- main_results[["Delta Total Emp"]]$bandwidth
if (is.null(opt_bw)) opt_bw <- 10

bw_multipliers <- c(0.5, 0.75, 1.0, 1.25, 1.5, 2.0)
bw_results <- list()

for (mult in bw_multipliers) {
  bw <- opt_bw * mult
  tryCatch({
    rd <- rdrobust(rdd_sample$delta_total_emp, rdd_sample$poverty_rate,
                   c = 20, h = bw)
    bw_results[[as.character(mult)]] <- data.frame(
      multiplier = mult,
      bandwidth = bw,
      coef = rd$coef[1],
      se = rd$se[3],
      pval = rd$pv[3],
      ci_lower = rd$ci[3, 1],
      ci_upper = rd$ci[3, 2],
      N_eff = rd$N_h[1] + rd$N_h[2]
    )
    cat(sprintf("  bw=%.1f (%.0f%% opt): β=%.3f (SE=%.3f) p=%.3f N=%d\n",
                bw, mult * 100, rd$coef[1], rd$se[3], rd$pv[3],
                rd$N_h[1] + rd$N_h[2]))
  }, error = function(e) {
    cat(sprintf("  bw=%.1f: ERROR\n", bw))
  })
}

bw_sensitivity <- bind_rows(bw_results)
saveRDS(bw_sensitivity, file.path(data_dir, "bw_sensitivity.rds"))

# Repeat for info employment
bw_info_results <- list()
for (mult in bw_multipliers) {
  bw <- opt_bw * mult
  tryCatch({
    rd <- rdrobust(rdd_sample$delta_info_emp, rdd_sample$poverty_rate,
                   c = 20, h = bw)
    bw_info_results[[as.character(mult)]] <- data.frame(
      multiplier = mult, bandwidth = bw,
      coef = rd$coef[1], se = rd$se[3], pval = rd$pv[3]
    )
  }, error = function(e) NULL)
}
bw_info_sensitivity <- bind_rows(bw_info_results)
saveRDS(bw_info_sensitivity, file.path(data_dir, "bw_info_sensitivity.rds"))


###############################################################################
# 2. Donut RDD (Exclude Near-Cutoff Observations)
###############################################################################
cat("\n=== Donut RDD ===\n")

donut_results <- list()
for (donut in c(0.5, 1.0, 2.0)) {
  donut_sample <- rdd_sample %>%
    filter(abs(pov_centered) >= donut)

  # Total employment
  tryCatch({
    rd <- rdrobust(donut_sample$delta_total_emp,
                   donut_sample$poverty_rate, c = 20)
    cat(sprintf("  Donut ±%.1fpp: β=%.3f (SE=%.3f) p=%.3f  N=%d\n",
                donut, rd$coef[1], rd$se[3], rd$pv[3],
                rd$N_h[1] + rd$N_h[2]))
    donut_results[[paste0("total_", donut)]] <- data.frame(
      donut = donut, outcome = "Delta Total Emp",
      coef = rd$coef[1], se = rd$se[3], pval = rd$pv[3],
      ci_lower = rd$ci[3, 1], ci_upper = rd$ci[3, 2],
      N_eff = rd$N_h[1] + rd$N_h[2], bw = rd$bws[1, 1]
    )
  }, error = function(e) {
    cat(sprintf("  Donut ±%.1fpp (total): ERROR\n", donut))
  })

  # Info employment
  tryCatch({
    rd_info <- rdrobust(donut_sample$delta_info_emp,
                        donut_sample$poverty_rate, c = 20)
    donut_results[[paste0("info_", donut)]] <- data.frame(
      donut = donut, outcome = "Delta Info Emp",
      coef = rd_info$coef[1], se = rd_info$se[3], pval = rd_info$pv[3],
      ci_lower = rd_info$ci[3, 1], ci_upper = rd_info$ci[3, 2],
      N_eff = rd_info$N_h[1] + rd_info$N_h[2], bw = rd_info$bws[1, 1]
    )
  }, error = function(e) NULL)

  # Construction employment
  tryCatch({
    rd_con <- rdrobust(donut_sample$delta_construction_emp,
                       donut_sample$poverty_rate, c = 20)
    donut_results[[paste0("construction_", donut)]] <- data.frame(
      donut = donut, outcome = "Delta Construction Emp",
      coef = rd_con$coef[1], se = rd_con$se[3], pval = rd_con$pv[3],
      ci_lower = rd_con$ci[3, 1], ci_upper = rd_con$ci[3, 2],
      N_eff = rd_con$N_h[1] + rd_con$N_h[2], bw = rd_con$bws[1, 1]
    )
  }, error = function(e) NULL)
}

donut_df <- bind_rows(donut_results)
saveRDS(donut_df, file.path(data_dir, "donut_rdd_results.rds"))


###############################################################################
# 3. Polynomial Order Sensitivity
###############################################################################
cat("\n=== Polynomial Order Sensitivity ===\n")

poly_results <- list()
for (p in c(1, 2, 3)) {
  # Total employment
  tryCatch({
    rd <- rdrobust(rdd_sample$delta_total_emp, rdd_sample$poverty_rate,
                   c = 20, p = p)
    cat(sprintf("  p=%d: β=%.3f (SE=%.3f) p=%.3f\n",
                p, rd$coef[1], rd$se[3], rd$pv[3]))
    poly_results[[paste0("total_", p)]] <- data.frame(
      poly_order = p, outcome = "Delta Total Emp",
      coef = rd$coef[1], se = rd$se[3], pval = rd$pv[3],
      ci_lower = rd$ci[3, 1], ci_upper = rd$ci[3, 2],
      N_eff = rd$N_h[1] + rd$N_h[2], bw = rd$bws[1, 1]
    )
  }, error = function(e) {
    cat(sprintf("  p=%d (total): ERROR\n", p))
  })

  # Info employment
  tryCatch({
    rd_info <- rdrobust(rdd_sample$delta_info_emp, rdd_sample$poverty_rate,
                        c = 20, p = p)
    poly_results[[paste0("info_", p)]] <- data.frame(
      poly_order = p, outcome = "Delta Info Emp",
      coef = rd_info$coef[1], se = rd_info$se[3], pval = rd_info$pv[3],
      ci_lower = rd_info$ci[3, 1], ci_upper = rd_info$ci[3, 2],
      N_eff = rd_info$N_h[1] + rd_info$N_h[2], bw = rd_info$bws[1, 1]
    )
  }, error = function(e) NULL)

  # Construction employment
  tryCatch({
    rd_con <- rdrobust(rdd_sample$delta_construction_emp, rdd_sample$poverty_rate,
                       c = 20, p = p)
    poly_results[[paste0("construction_", p)]] <- data.frame(
      poly_order = p, outcome = "Delta Construction Emp",
      coef = rd_con$coef[1], se = rd_con$se[3], pval = rd_con$pv[3],
      ci_lower = rd_con$ci[3, 1], ci_upper = rd_con$ci[3, 2],
      N_eff = rd_con$N_h[1] + rd_con$N_h[2], bw = rd_con$bws[1, 1]
    )
  }, error = function(e) NULL)
}

poly_df <- bind_rows(poly_results)
saveRDS(poly_df, file.path(data_dir, "polynomial_sensitivity.rds"))


###############################################################################
# 4. Placebo Cutoffs
###############################################################################
cat("\n=== Placebo Cutoffs ===\n")

placebo_cutoffs <- c(10, 12, 15, 25, 30, 35)
placebo_results <- list()

for (pc in placebo_cutoffs) {
  tryCatch({
    rd <- rdrobust(rdd_sample$delta_total_emp, rdd_sample$poverty_rate,
                   c = pc)
    placebo_results[[as.character(pc)]] <- data.frame(
      cutoff = pc, coef = rd$coef[1], se = rd$se[3], pval = rd$pv[3]
    )
    cat(sprintf("  Cutoff=%d%%: β=%.3f (SE=%.3f) p=%.3f %s\n",
                pc, rd$coef[1], rd$se[3], rd$pv[3],
                ifelse(rd$pv[3] < 0.05, "*** SIGNIFICANT ***", "")))
  }, error = function(e) {
    cat(sprintf("  Cutoff=%d%%: ERROR\n", pc))
  })
}

placebo_df <- bind_rows(placebo_results)
saveRDS(placebo_df, file.path(data_dir, "placebo_cutoffs.rds"))


###############################################################################
# 5. Pre-Treatment Outcome Test (Should Be Zero)
###############################################################################
cat("\n=== Pre-Treatment Outcome Test (Should Be Zero) ===\n")

pre_outcomes <- c("pre_total_emp", "pre_info_emp", "pre_construction_emp")
for (v in pre_outcomes) {
  y <- rdd_sample[[v]]
  valid <- !is.na(y)
  if (sum(valid) > 100) {
    tryCatch({
      rd <- rdrobust(y[valid], rdd_sample$poverty_rate[valid], c = 20)
      cat(sprintf("  %-25s β=%.3f (SE=%.3f) p=%.3f %s\n",
                  v, rd$coef[1], rd$se[3], rd$pv[3],
                  ifelse(rd$pv[3] > 0.05, "✓ (no pre-trend)", "⚠ pre-trend")))
    }, error = function(e) {
      cat(sprintf("  %-25s ERROR\n", v))
    })
  }
}


###############################################################################
# 6. Event Study at the Cutoff (Dynamic RDD)
###############################################################################
cat("\n=== Dynamic RDD (Year-by-Year at Cutoff) ===\n")

years <- sort(unique(panel_rdd$year))
dynamic_results <- list()

for (yr in years) {
  yr_data <- panel_rdd %>% filter(year == yr)

  if (nrow(yr_data) > 200) {
    tryCatch({
      rd <- rdrobust(yr_data$total_emp, yr_data$poverty_rate, c = 20)
      dynamic_results[[as.character(yr)]] <- data.frame(
        year = yr,
        coef = rd$coef[1],
        se = rd$se[3],
        pval = rd$pv[3],
        ci_lower = rd$ci[3, 1],
        ci_upper = rd$ci[3, 2]
      )
      cat(sprintf("  %d: β=%.3f (SE=%.3f) p=%.3f\n",
                  yr, rd$coef[1], rd$se[3], rd$pv[3]))
    }, error = function(e) {
      cat(sprintf("  %d: ERROR\n", yr))
    })
  }
}

dynamic_df <- bind_rows(dynamic_results)
saveRDS(dynamic_df, file.path(data_dir, "dynamic_rdd.rds"))


###############################################################################
# 7. Heterogeneity by Urbanicity
###############################################################################
cat("\n=== Heterogeneity: Urban vs Rural ===\n")

for (u in c(TRUE, FALSE)) {
  sub <- rdd_sample %>% filter(urban == u)
  label <- ifelse(u, "Urban", "Rural")

  if (nrow(sub) > 200) {
    tryCatch({
      rd <- rdrobust(sub$delta_total_emp, sub$poverty_rate, c = 20)
      cat(sprintf("  %-10s β=%.3f (SE=%.3f) p=%.3f N=%d\n",
                  label, rd$coef[1], rd$se[3], rd$pv[3],
                  rd$N_h[1] + rd$N_h[2]))
    }, error = function(e) {
      cat(sprintf("  %-10s ERROR\n", label))
    })
  }
}


###############################################################################
# 8. Alternative Kernel
###############################################################################
cat("\n=== Alternative Kernel (Uniform vs Triangular) ===\n")

kernel_results <- list()
for (kern in c("triangular", "uniform", "epanechnikov")) {
  # Total employment
  tryCatch({
    rd <- rdrobust(rdd_sample$delta_total_emp, rdd_sample$poverty_rate,
                   c = 20, kernel = kern)
    cat(sprintf("  %-15s β=%.3f (SE=%.3f) p=%.3f\n",
                kern, rd$coef[1], rd$se[3], rd$pv[3]))
    kernel_results[[paste0("total_", kern)]] <- data.frame(
      kernel = kern, outcome = "Delta Total Emp",
      coef = rd$coef[1], se = rd$se[3], pval = rd$pv[3],
      ci_lower = rd$ci[3, 1], ci_upper = rd$ci[3, 2],
      N_eff = rd$N_h[1] + rd$N_h[2], bw = rd$bws[1, 1]
    )
  }, error = function(e) {
    cat(sprintf("  %-15s (total) ERROR\n", kern))
  })

  # Info employment
  tryCatch({
    rd_info <- rdrobust(rdd_sample$delta_info_emp, rdd_sample$poverty_rate,
                        c = 20, kernel = kern)
    kernel_results[[paste0("info_", kern)]] <- data.frame(
      kernel = kern, outcome = "Delta Info Emp",
      coef = rd_info$coef[1], se = rd_info$se[3], pval = rd_info$pv[3],
      ci_lower = rd_info$ci[3, 1], ci_upper = rd_info$ci[3, 2],
      N_eff = rd_info$N_h[1] + rd_info$N_h[2], bw = rd_info$bws[1, 1]
    )
  }, error = function(e) NULL)

  # Construction employment
  tryCatch({
    rd_con <- rdrobust(rdd_sample$delta_construction_emp, rdd_sample$poverty_rate,
                       c = 20, kernel = kern)
    kernel_results[[paste0("construction_", kern)]] <- data.frame(
      kernel = kern, outcome = "Delta Construction Emp",
      coef = rd_con$coef[1], se = rd_con$se[3], pval = rd_con$pv[3],
      ci_lower = rd_con$ci[3, 1], ci_upper = rd_con$ci[3, 2],
      N_eff = rd_con$N_h[1] + rd_con$N_h[2], bw = rd_con$bws[1, 1]
    )
  }, error = function(e) NULL)
}

kernel_df <- bind_rows(kernel_results)
saveRDS(kernel_df, file.path(data_dir, "kernel_sensitivity.rds"))

cat("\n=== Robustness checks complete ===\n")
