###############################################################################
# 04_robustness.R
# Robustness checks for RDD estimates
# APEP-0445 v4
###############################################################################

this_file <- tryCatch(sys.frame(1)$ofile, error = function(e) NULL)
if (is.null(this_file)) this_file <- "."
source(file.path(dirname(this_file), "00_packages.R"))

rdd_sample <- readRDS(file.path(data_dir, "rdd_sample.rds"))
panel_rdd <- readRDS(file.path(data_dir, "panel_rdd.rds"))
cat("Data loaded\n\n")


###############################################################################
# 1. Bandwidth Sensitivity
###############################################################################
cat("=== Bandwidth Sensitivity ===\n")

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
    cat(sprintf("  bw=%.1f (%.0f%% opt): b=%.3f (SE=%.3f) p=%.3f N=%d\n",
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

  tryCatch({
    rd <- rdrobust(donut_sample$delta_total_emp,
                   donut_sample$poverty_rate, c = 20)
    cat(sprintf("  Donut +/-%.1fpp: b=%.3f (SE=%.3f) p=%.3f  N=%d\n",
                donut, rd$coef[1], rd$se[3], rd$pv[3],
                rd$N_h[1] + rd$N_h[2]))
    donut_results[[paste0("total_", donut)]] <- data.frame(
      donut = donut, outcome = "Delta Total Emp",
      coef = rd$coef[1], se = rd$se[3], pval = rd$pv[3],
      ci_lower = rd$ci[3, 1], ci_upper = rd$ci[3, 2],
      N_eff = rd$N_h[1] + rd$N_h[2], bw = rd$bws[1, 1]
    )
  }, error = function(e) {
    cat(sprintf("  Donut +/-%.1fpp (total): ERROR\n", donut))
  })

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
  tryCatch({
    rd <- rdrobust(rdd_sample$delta_total_emp, rdd_sample$poverty_rate,
                   c = 20, p = p)
    cat(sprintf("  p=%d: b=%.3f (SE=%.3f) p=%.3f\n",
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
# 4. Systematic Placebo Grid
###############################################################################
cat("\n=== Systematic Placebo Grid ===\n")

# Every 1pp from 5% to 35%, excluding +/-2pp around the true cutoff (18-22%)
placebo_cutoffs <- setdiff(5:35, 18:22)
cat(sprintf("  Testing %d placebo cutoffs\n", length(placebo_cutoffs)))

placebo_results <- list()
for (pc in placebo_cutoffs) {
  tryCatch({
    rd <- rdrobust(rdd_sample$delta_total_emp, rdd_sample$poverty_rate,
                   c = pc)
    placebo_results[[as.character(pc)]] <- data.frame(
      cutoff = pc, coef = rd$coef[1], se = rd$se[3], pval = rd$pv[3],
      t_stat = rd$coef[1] / rd$se[3]
    )
    sig_flag <- ifelse(rd$pv[3] < 0.05, "*** SIGNIFICANT ***", "")
    cat(sprintf("  Cutoff=%d%%: b=%.3f (SE=%.3f) p=%.3f %s\n",
                pc, rd$coef[1], rd$se[3], rd$pv[3], sig_flag))
  }, error = function(e) {
    cat(sprintf("  Cutoff=%d%%: ERROR\n", pc))
  })
}

placebo_df <- bind_rows(placebo_results)
saveRDS(placebo_df, file.path(data_dir, "placebo_cutoffs.rds"))

# Report summary
n_sig <- sum(placebo_df$pval < 0.05, na.rm = TRUE)
cat(sprintf("\n  Placebo summary: %d/%d significant at 5%% (expected ~%.0f by chance)\n",
            n_sig, nrow(placebo_df), nrow(placebo_df) * 0.05))


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
      cat(sprintf("  %-25s b=%.3f (SE=%.3f) p=%.3f %s\n",
                  v, rd$coef[1], rd$se[3], rd$pv[3],
                  ifelse(rd$pv[3] > 0.05, "ok (no pre-trend)", "! pre-trend")))
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
      cat(sprintf("  %d: b=%.3f (SE=%.3f) p=%.3f\n",
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
      cat(sprintf("  %-10s b=%.3f (SE=%.3f) p=%.3f N=%d\n",
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
  tryCatch({
    rd <- rdrobust(rdd_sample$delta_total_emp, rdd_sample$poverty_rate,
                   c = 20, kernel = kern)
    cat(sprintf("  %-15s b=%.3f (SE=%.3f) p=%.3f\n",
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


###############################################################################
# 9. Local Randomization Inference
###############################################################################
cat("\n=== Local Randomization Inference ===\n")

local_rand_results <- list()
windows <- c(0.5, 0.75, 1.0)
set.seed(12345)  # Ensure reproducibility for permutation inference

for (w in windows) {
  # Select tracts in narrow window around cutoff
  narrow <- rdd_sample %>%
    filter(abs(pov_centered) <= w, !is.na(delta_total_emp))

  if (nrow(narrow) > 30) {
    tryCatch({
      ri_total <- rdrandinf(
        Y = narrow$delta_total_emp,
        R = narrow$poverty_rate,
        cutoff = 20,
        wl = 20 - w,
        wr = 20 + w,
        reps = 1000,
        quietly = TRUE
      )

      # Compute difference in means for effect size
      mean_above <- mean(narrow$delta_total_emp[narrow$poverty_rate >= 20], na.rm = TRUE)
      mean_below <- mean(narrow$delta_total_emp[narrow$poverty_rate < 20], na.rm = TRUE)
      diff_means_total <- mean_above - mean_below

      local_rand_results[[paste0("total_", w)]] <- data.frame(
        window = w,
        outcome = "Delta Total Emp",
        obs_stat = ri_total$obs.stat,
        p_value = ri_total$p.value,
        diff_means = diff_means_total,
        n_left = sum(narrow$poverty_rate < 20),
        n_right = sum(narrow$poverty_rate >= 20)
      )
      cat(sprintf("  Window +/-%.2fpp (total): p=%.4f  N=%d\n",
                  w, ri_total$p.value, nrow(narrow)))
    }, error = function(e) {
      cat(sprintf("  Window +/-%.2fpp (total): ERROR - %s\n", w, substr(e$message, 1, 50)))
    })

    # Info employment
    narrow_info <- narrow %>% filter(!is.na(delta_info_emp))
    if (nrow(narrow_info) > 30) {
      tryCatch({
        ri_info <- rdrandinf(
          Y = narrow_info$delta_info_emp,
          R = narrow_info$poverty_rate,
          cutoff = 20,
          wl = 20 - w,
          wr = 20 + w,
          reps = 1000,
          quietly = TRUE
        )

        mean_above_info <- mean(narrow_info$delta_info_emp[narrow_info$poverty_rate >= 20], na.rm = TRUE)
        mean_below_info <- mean(narrow_info$delta_info_emp[narrow_info$poverty_rate < 20], na.rm = TRUE)
        diff_means_info <- mean_above_info - mean_below_info

        local_rand_results[[paste0("info_", w)]] <- data.frame(
          window = w,
          outcome = "Delta Info Emp",
          obs_stat = ri_info$obs.stat,
          p_value = ri_info$p.value,
          diff_means = diff_means_info,
          n_left = sum(narrow_info$poverty_rate < 20),
          n_right = sum(narrow_info$poverty_rate >= 20)
        )
        cat(sprintf("  Window +/-%.2fpp (info):  p=%.4f  N=%d\n",
                    w, ri_info$p.value, nrow(narrow_info)))
      }, error = function(e) {
        cat(sprintf("  Window +/-%.2fpp (info):  ERROR - %s\n", w, substr(e$message, 1, 50)))
      })
    }
  } else {
    cat(sprintf("  Window +/-%.2fpp: Too few observations (%d)\n", w, nrow(narrow)))
  }
}

local_rand_df <- bind_rows(local_rand_results)
saveRDS(local_rand_df, file.path(data_dir, "local_randomization.rds"))


###############################################################################
# 10. Infrastructure Heterogeneity (Broadband)
###############################################################################
cat("\n=== Infrastructure Heterogeneity ===\n")

infra_results <- list()

if ("broadband_quartile" %in% names(rdd_sample)) {
  for (q in 1:4) {
    sub <- rdd_sample %>%
      filter(broadband_quartile == q, !is.na(delta_total_emp))

    if (nrow(sub) > 200) {
      tryCatch({
        rd <- rdrobust(sub$delta_total_emp, sub$poverty_rate, c = 20)
        infra_results[[paste0("total_q", q)]] <- data.frame(
          quartile = q, outcome = "Delta Total Emp",
          coef = rd$coef[1], se = rd$se[3], pval = rd$pv[3],
          ci_lower = rd$ci[3, 1], ci_upper = rd$ci[3, 2],
          N_eff = rd$N_h[1] + rd$N_h[2], bw = rd$bws[1, 1]
        )
        cat(sprintf("  Q%d (total): b=%.3f (SE=%.3f) p=%.3f N=%d\n",
                    q, rd$coef[1], rd$se[3], rd$pv[3], rd$N_h[1] + rd$N_h[2]))
      }, error = function(e) {
        cat(sprintf("  Q%d (total): ERROR\n", q))
      })

      # Info employment
      sub_info <- sub %>% filter(!is.na(delta_info_emp))
      if (nrow(sub_info) > 100) {
        tryCatch({
          rd_info <- rdrobust(sub_info$delta_info_emp, sub_info$poverty_rate, c = 20)
          infra_results[[paste0("info_q", q)]] <- data.frame(
            quartile = q, outcome = "Delta Info Emp",
            coef = rd_info$coef[1], se = rd_info$se[3], pval = rd_info$pv[3],
            ci_lower = rd_info$ci[3, 1], ci_upper = rd_info$ci[3, 2],
            N_eff = rd_info$N_h[1] + rd_info$N_h[2], bw = rd_info$bws[1, 1]
          )
          cat(sprintf("  Q%d (info):  b=%.3f (SE=%.3f) p=%.3f\n",
                      q, rd_info$coef[1], rd_info$se[3], rd_info$pv[3]))
        }, error = function(e) NULL)
      }
    } else {
      cat(sprintf("  Q%d: Too few observations (%d)\n", q, nrow(sub)))
    }
  }
} else {
  cat("  Broadband quartile not available, skipping infrastructure heterogeneity\n")
}

infra_df <- bind_rows(infra_results)
saveRDS(infra_df, file.path(data_dir, "infrastructure_heterogeneity.rds"))

###############################################################################
# 11. DC Outcome Robustness: Bandwidth Sensitivity and Donut (v3 addition)
###############################################################################
cat("\n=== DC Outcome Robustness (v3) ===\n")

dc_rob_results <- list()

if ("dc_any" %in% names(rdd_sample) && sum(rdd_sample$dc_any, na.rm = TRUE) > 0) {
  # Get DC-specific optimal bandwidth
  dc_results <- readRDS(file.path(data_dir, "dc_rdd_results.rds"))
  dc_opt_bw <- if (!is.null(dc_results[["DC Presence"]]$bandwidth)) {
    dc_results[["DC Presence"]]$bandwidth
  } else {
    tryCatch({
      rd_dc_bw <- rdrobust(rdd_sample$dc_any, rdd_sample$poverty_rate, c = 20)
      rd_dc_bw$bws[1, 1]
    }, error = function(e) opt_bw)
  }
  cat(sprintf("  DC-specific optimal bandwidth: %.2f pp\n", dc_opt_bw))

  # Bandwidth sensitivity for DC presence
  for (mult in c(0.5, 0.75, 1.0, 1.5, 2.0)) {
    bw <- dc_opt_bw * mult
    tryCatch({
      rd <- rdrobust(rdd_sample$dc_any, rdd_sample$poverty_rate, c = 20, h = bw)
      dc_rob_results[[paste0("bw_", mult)]] <- data.frame(
        test = "Bandwidth", parameter = mult,
        coef = rd$coef[1], se = rd$se[3], pval = rd$pv[3],
        N_eff = rd$N_h[1] + rd$N_h[2]
      )
      cat(sprintf("  DC bw=%.0f%%: b=%.5f (SE=%.5f) p=%.3f\n",
                  mult * 100, rd$coef[1], rd$se[3], rd$pv[3]))
    }, error = function(e) NULL)
  }

  # Donut for DC presence
  for (donut in c(0.5, 1.0, 2.0)) {
    donut_s <- rdd_sample %>% filter(abs(pov_centered) >= donut)
    tryCatch({
      rd <- rdrobust(donut_s$dc_any, donut_s$poverty_rate, c = 20)
      dc_rob_results[[paste0("donut_", donut)]] <- data.frame(
        test = "Donut", parameter = donut,
        coef = rd$coef[1], se = rd$se[3], pval = rd$pv[3],
        N_eff = rd$N_h[1] + rd$N_h[2]
      )
      cat(sprintf("  DC donut=%.1f: b=%.5f (SE=%.5f) p=%.3f\n",
                  donut, rd$coef[1], rd$se[3], rd$pv[3]))
    }, error = function(e) NULL)
  }
} else {
  cat("  DC data not available for robustness tests\n")
}

dc_rob_df <- bind_rows(dc_rob_results)
saveRDS(dc_rob_df, file.path(data_dir, "dc_robustness.rds"))


###############################################################################
# 11b. DC Vintage Robustness: Bandwidth Sensitivity (v4 addition)
###############################################################################
cat("\n=== DC Vintage Robustness (v4) ===\n")

dc_vintage_rob <- list()

# Helper: try rdrobust, fall back to LPM for sparse outcomes
run_bw_rob <- function(y_var, bw, label) {
  result <- NULL
  tryCatch({
    rd <- rdrobust(rdd_sample[[y_var]], rdd_sample$poverty_rate, c = 20, h = bw)
    result <- data.frame(
      coef = rd$coef[1], se = rd$se[3], pval = rd$pv[3],
      N_eff = rd$N_h[1] + rd$N_h[2], method = "rdrobust"
    )
  }, error = function(e) NULL)

  if (is.null(result)) {
    tryCatch({
      bw_sub <- rdd_sample %>% filter(abs(pov_centered) <= bw)
      lpm <- feols(as.formula(paste0(y_var, " ~ eligible_poverty * pov_centered")),
                   data = bw_sub, vcov = "HC1")
      lpm_c <- coef(lpm)["eligible_povertyTRUE"]
      lpm_s <- sqrt(vcov(lpm)["eligible_povertyTRUE", "eligible_povertyTRUE"])
      lpm_p <- 2 * pnorm(-abs(lpm_c / lpm_s))
      result <- data.frame(
        coef = lpm_c, se = lpm_s, pval = lpm_p,
        N_eff = nrow(bw_sub), method = "LPM"
      )
    }, error = function(e) NULL)
  }
  return(result)
}

for (vin in c("post2018", "pre2018")) {
  y_var <- paste0("dc_any_", vin)
  if (y_var %in% names(rdd_sample) && sum(rdd_sample[[y_var]], na.rm = TRUE) > 0) {
    for (mult in c(0.5, 0.75, 1.0, 1.5, 2.0)) {
      bw <- opt_bw * mult
      res <- run_bw_rob(y_var, bw, paste0(vin, " bw=", mult))
      if (!is.null(res)) {
        dc_vintage_rob[[paste0(vin, "_bw_", mult)]] <- data.frame(
          test = "Bandwidth", parameter = mult,
          vintage = ifelse(vin == "post2018", "Post-2018", "Pre-2018"),
          coef = res$coef, se = res$se, pval = res$pval,
          N_eff = res$N_eff
        )
        cat(sprintf("  %s DC bw=%.0f%%: b=%.6f (SE=%.6f) p=%.3f [%s]\n",
                    ifelse(vin == "post2018", "Post-2018", "Pre-2018"),
                    mult * 100, res$coef, res$se, res$pval, res$method))
      }
    }
  }
}

dc_vintage_rob_df <- bind_rows(dc_vintage_rob)
saveRDS(dc_vintage_rob_df, file.path(data_dir, "dc_vintage_robustness.rds"))


###############################################################################
# 11c. Local Randomization for DC Outcomes (v4 addition, WS2)
###############################################################################
cat("\n=== Local Randomization: DC Outcomes (v4) ===\n")

dc_lr_results <- list()
set.seed(12345)

for (w in windows) {
  narrow <- rdd_sample %>%
    filter(abs(pov_centered) <= w)

  if (nrow(narrow) > 30) {
    # DC presence (any)
    if (sum(narrow$dc_any, na.rm = TRUE) > 0) {
      tryCatch({
        ri_dc <- rdrandinf(
          Y = narrow$dc_any,
          R = narrow$poverty_rate,
          cutoff = 20, wl = 20 - w, wr = 20 + w,
          reps = 1000, quietly = TRUE
        )
        dm_dc <- mean(narrow$dc_any[narrow$poverty_rate >= 20], na.rm=TRUE) -
                 mean(narrow$dc_any[narrow$poverty_rate < 20], na.rm=TRUE)
        dc_lr_results[[paste0("dc_any_", w)]] <- data.frame(
          window = w, outcome = "DC Presence (Any)",
          obs_stat = ri_dc$obs.stat, p_value = ri_dc$p.value,
          diff_means = dm_dc,
          n_left = sum(narrow$poverty_rate < 20),
          n_right = sum(narrow$poverty_rate >= 20)
        )
        cat(sprintf("  Window +/-%.2fpp (DC any):     p=%.4f  N=%d\n",
                    w, ri_dc$p.value, nrow(narrow)))
      }, error = function(e) {
        cat(sprintf("  Window +/-%.2fpp (DC any):     ERROR - %s\n", w, substr(e$message, 1, 50)))
      })
    }

    # DC count
    if (sum(narrow$dc_count, na.rm = TRUE) > 0) {
      tryCatch({
        ri_dc_ct <- rdrandinf(
          Y = narrow$dc_count,
          R = narrow$poverty_rate,
          cutoff = 20, wl = 20 - w, wr = 20 + w,
          reps = 1000, quietly = TRUE
        )
        dm_dc_ct <- mean(narrow$dc_count[narrow$poverty_rate >= 20], na.rm=TRUE) -
                    mean(narrow$dc_count[narrow$poverty_rate < 20], na.rm=TRUE)
        dc_lr_results[[paste0("dc_count_", w)]] <- data.frame(
          window = w, outcome = "DC Count",
          obs_stat = ri_dc_ct$obs.stat, p_value = ri_dc_ct$p.value,
          diff_means = dm_dc_ct,
          n_left = sum(narrow$poverty_rate < 20),
          n_right = sum(narrow$poverty_rate >= 20)
        )
        cat(sprintf("  Window +/-%.2fpp (DC count):   p=%.4f  N=%d\n",
                    w, ri_dc_ct$p.value, nrow(narrow)))
      }, error = function(e) {
        cat(sprintf("  Window +/-%.2fpp (DC count):   ERROR - %s\n", w, substr(e$message, 1, 50)))
      })
    }

    # Construction employment change
    narrow_con <- narrow %>% filter(!is.na(delta_construction_emp))
    if (nrow(narrow_con) > 30) {
      tryCatch({
        ri_con <- rdrandinf(
          Y = narrow_con$delta_construction_emp,
          R = narrow_con$poverty_rate,
          cutoff = 20, wl = 20 - w, wr = 20 + w,
          reps = 1000, quietly = TRUE
        )
        dm_con <- mean(narrow_con$delta_construction_emp[narrow_con$poverty_rate >= 20], na.rm=TRUE) -
                  mean(narrow_con$delta_construction_emp[narrow_con$poverty_rate < 20], na.rm=TRUE)
        dc_lr_results[[paste0("construction_", w)]] <- data.frame(
          window = w, outcome = "Delta Construction Emp",
          obs_stat = ri_con$obs.stat, p_value = ri_con$p.value,
          diff_means = dm_con,
          n_left = sum(narrow_con$poverty_rate < 20),
          n_right = sum(narrow_con$poverty_rate >= 20)
        )
        cat(sprintf("  Window +/-%.2fpp (construction): p=%.4f  N=%d\n",
                    w, ri_con$p.value, nrow(narrow_con)))
      }, error = function(e) {
        cat(sprintf("  Window +/-%.2fpp (construction): ERROR\n", w))
      })
    }
  }
}

dc_lr_df <- bind_rows(dc_lr_results)
saveRDS(dc_lr_df, file.path(data_dir, "dc_local_randomization.rds"))


###############################################################################
# 12. Local Randomization Covariate Balance (v3 addition, WS4)
###############################################################################
cat("\n=== Local Randomization Covariate Balance (v3) ===\n")

lr_balance_results <- list()
w_bal <- 1.0  # Use the 1.0 pp window

narrow_bal <- rdd_sample %>%
  filter(abs(pov_centered) <= w_bal)

if (nrow(narrow_bal) > 50) {
  bal_vars_lr <- c("total_pop", "pct_bachelors", "pct_white",
                    "median_home_value", "unemployment_rate",
                    "pre_total_emp", "pre_info_emp")

  for (v in bal_vars_lr) {
    y_bal <- narrow_bal[[v]]
    valid_bal <- !is.na(y_bal)
    if (sum(valid_bal) > 30) {
      tryCatch({
        ri_bal <- rdrandinf(
          Y = y_bal[valid_bal],
          R = narrow_bal$poverty_rate[valid_bal],
          cutoff = 20,
          wl = 20 - w_bal,
          wr = 20 + w_bal,
          reps = 1000,
          quietly = TRUE
        )
        lr_balance_results[[v]] <- data.frame(
          variable = v,
          obs_stat = ri_bal$obs.stat,
          p_value = ri_bal$p.value,
          n = sum(valid_bal)
        )
        cat(sprintf("  %-25s stat=%.3f  p=%.3f  %s\n",
                    v, ri_bal$obs.stat, ri_bal$p.value,
                    ifelse(ri_bal$p.value > 0.05, "BALANCED", "IMBALANCED")))
      }, error = function(e) {
        cat(sprintf("  %-25s ERROR: %s\n", v, substr(e$message, 1, 40)))
      })
    }
  }
}

lr_balance_df <- bind_rows(lr_balance_results)
saveRDS(lr_balance_df, file.path(data_dir, "lr_covariate_balance.rds"))


cat("\n=== Robustness checks complete ===\n")
