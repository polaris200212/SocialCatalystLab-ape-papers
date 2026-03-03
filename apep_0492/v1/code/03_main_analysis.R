# ==============================================================================
# 03_main_analysis.R — Multi-Cutoff Bunching + Spatial RDD
# apep_0492 v1
# ==============================================================================

source("00_packages.R")

# Prevent scientific notation
options(scipen = 999)

data_dir <- "../data"
ppd <- fread(file.path(data_dir, "ppd_analysis.csv"))

# ==============================================================================
# 1. BUNCHING ANALYSIS — Multi-Cutoff Estimation
# ==============================================================================

# Following Kleven (2016) and Best & Kleven (2018):
# 1. Bin new-build transactions by price
# 2. Fit polynomial to counterfactual distribution excluding bunching region
# 3. Estimate excess mass below cap and missing mass above

england_regions <- c("North East", "North West", "Yorkshire and The Humber",
                     "East Midlands", "West Midlands", "South West",
                     "East of England", "South East", "London")

htb_caps <- data.table(
  region = england_regions,
  cap = c(186100, 224400, 228100, 261900, 255600, 349000, 407400, 437600, 600000)
)

# Bunching estimation function
estimate_bunching <- function(dt, cap_value, bin_width = 1000,
                              window_below = 30000, window_above = 30000,
                              poly_order = 7, exclude_below = 5000,
                              exclude_above = 5000) {
  min_price <- cap_value - window_below * 2
  max_price <- cap_value + window_above * 2
  dt_sub <- dt[price >= min_price & price <= max_price]

  if (nrow(dt_sub) < 100) return(NULL)

  # Bin relative to cap to ensure cap aligns with bin boundary
  dt_sub[, rel_price := price - cap_value]
  dt_sub[, rel_bin := floor(rel_price / bin_width) * bin_width]
  bin_counts <- dt_sub[, .N, by = rel_bin][order(rel_bin)]

  # Exclude bunching region from polynomial fit
  # rel_bin < 0 means prices BELOW cap; rel_bin >= 0 means prices AT or ABOVE cap
  bunching_region <- bin_counts[rel_bin >= -exclude_below & rel_bin <= exclude_above]
  fit_region <- bin_counts[rel_bin < -exclude_below | rel_bin > exclude_above]

  if (nrow(fit_region) < poly_order + 1) return(NULL)

  fit <- lm(N ~ poly(rel_bin, poly_order), data = fit_region)
  bin_counts[, counterfactual := predict(fit, newdata = .SD)]

  # Excess mass: bins just below cap (negative rel_bin, within exclude window)
  excess_below <- bin_counts[rel_bin >= -exclude_below & rel_bin < 0,
                             sum(N - counterfactual)]
  missing_above <- bin_counts[rel_bin >= 0 & rel_bin <= exclude_above,
                              sum(counterfactual - N)]
  avg_cf <- bin_counts[rel_bin >= -exclude_below & rel_bin < 0,
                       mean(counterfactual)]
  bunching_ratio <- excess_below / max(avg_cf, 1)

  list(
    bin_counts = bin_counts,
    excess_below = excess_below,
    missing_above = missing_above,
    bunching_ratio = bunching_ratio,
    avg_counterfactual = avg_cf,
    n_transactions = nrow(dt_sub),
    cap = cap_value
  )
}

# Bootstrap inference for bunching estimates
bootstrap_bunching <- function(dt, cap_value, n_boot = 500, seed = 42, ...) {
  set.seed(seed)
  n <- nrow(dt)
  boot_results <- numeric(n_boot)

  for (b in seq_len(n_boot)) {
    boot_idx <- sample(n, replace = TRUE)
    boot_dt <- dt[boot_idx]
    result <- estimate_bunching(boot_dt, cap_value, ...)
    boot_results[b] <- if (!is.null(result)) result$bunching_ratio else NA_real_
  }

  boot_results <- boot_results[!is.na(boot_results)]

  if (length(boot_results) < 3) {
    return(list(se = NA_real_, ci_lower = NA_real_, ci_upper = NA_real_,
                n_valid = length(boot_results)))
  }

  list(
    se = sd(boot_results),
    ci_lower = quantile(boot_results, 0.025),
    ci_upper = quantile(boot_results, 0.975),
    n_valid = length(boot_results)
  )
}

# Only run analysis if this is the main script (not sourced)
if (sys.nframe() == 0L || !exists(".sourced_for_functions")) {

# ==============================================================================
# 2. MAIN BUNCHING RESULTS — Post-Reform Period
# ==============================================================================

cat("\n=== BUNCHING ANALYSIS: POST-REFORM NEW BUILDS ===\n\n")

bunching_results <- list()

for (i in seq_len(nrow(htb_caps))) {
  reg <- htb_caps$region[i]
  cap <- htb_caps$cap[i]

  dt_region <- ppd[new_build == TRUE & post_reform == TRUE & region == reg]

  cat(sprintf("Region: %s (cap = £%s, N = %s)\n",
              reg, format(cap, big.mark = ","),
              format(nrow(dt_region), big.mark = ",")))

  result <- estimate_bunching(dt_region, cap)

  if (!is.null(result)) {
    boot <- bootstrap_bunching(dt_region, cap, n_boot = 200)

    bunching_results[[reg]] <- list(
      region = reg,
      cap = cap,
      n = nrow(dt_region),
      excess_below = result$excess_below,
      missing_above = result$missing_above,
      bunching_ratio = result$bunching_ratio,
      se = boot$se,
      ci_lower = boot$ci_lower,
      ci_upper = boot$ci_upper
    )

    cat(sprintf("  Bunching ratio: %.3f (SE: %.3f, 95%% CI: [%.3f, %.3f])\n",
                result$bunching_ratio, boot$se, boot$ci_lower, boot$ci_upper))
    cat(sprintf("  Excess below cap: %.0f transactions\n", result$excess_below))
    cat(sprintf("  Missing above cap: %.0f transactions\n\n", result$missing_above))
  }
}

# ==============================================================================
# 3. PLACEBO: SECOND-HAND PROPERTIES (no bunching expected)
# ==============================================================================

cat("\n=== PLACEBO: SECOND-HAND PROPERTIES ===\n\n")

placebo_results <- list()

for (i in seq_len(nrow(htb_caps))) {
  reg <- htb_caps$region[i]
  cap <- htb_caps$cap[i]

  dt_resale <- ppd[new_build == FALSE & post_reform == TRUE & region == reg]
  result <- estimate_bunching(dt_resale, cap)

  if (!is.null(result)) {
    boot <- bootstrap_bunching(dt_resale, cap, n_boot = 200)

    placebo_results[[reg]] <- list(
      region = reg,
      cap = cap,
      bunching_ratio = result$bunching_ratio,
      se = boot$se
    )

    cat(sprintf("  %s: Bunching ratio = %.3f (SE: %.3f) [expect ~0]\n",
                reg, result$bunching_ratio, boot$se))
  }
}

# ==============================================================================
# 4. PLACEBO: PRE-REFORM PERIOD AT FUTURE REGIONAL CAPS
# ==============================================================================

cat("\n=== PLACEBO: PRE-REFORM AT FUTURE REGIONAL CAPS ===\n\n")

pre_reform_results <- list()

for (i in seq_len(nrow(htb_caps))) {
  reg <- htb_caps$region[i]
  cap <- htb_caps$cap[i]

  if (cap == 600000) next

  dt_pre <- ppd[new_build == TRUE & post_reform == FALSE & region == reg &
                  period %in% c("pre_covid", "pre_reform")]
  result <- estimate_bunching(dt_pre, cap)

  if (!is.null(result)) {
    pre_reform_results[[reg]] <- list(
      region = reg,
      cap = cap,
      bunching_ratio = result$bunching_ratio,
      n = nrow(dt_pre)
    )

    cat(sprintf("  %s (future cap £%s): Bunching ratio = %.3f [expect ~0]\n",
                reg, format(cap, big.mark = ","), result$bunching_ratio))
  }
}

# ==============================================================================
# 5. DIFFERENCE-IN-BUNCHING: Pre vs Post Reform
# ==============================================================================

cat("\n=== DIFFERENCE-IN-BUNCHING ===\n")
cat("At £600K threshold (which was the UNIFORM cap pre-reform):\n\n")

dib_results <- list()

for (i in seq_len(nrow(htb_caps))) {
  reg <- htb_caps$region[i]

  dt_pre <- ppd[new_build == TRUE & post_reform == FALSE & region == reg &
                  period %in% c("pre_covid", "pre_reform")]
  pre_result <- estimate_bunching(dt_pre, 600000)

  dt_post <- ppd[new_build == TRUE & post_reform == TRUE & region == reg]
  post_result <- estimate_bunching(dt_post, 600000)

  if (!is.null(pre_result) & !is.null(post_result)) {
    diff <- post_result$bunching_ratio - pre_result$bunching_ratio

    # Bootstrap SEs for pre, post, and difference
    pre_boot <- bootstrap_bunching(dt_pre, 600000, n_boot = 500, seed = 42)
    post_boot <- bootstrap_bunching(dt_post, 600000, n_boot = 500, seed = 42)

    # Bootstrap the difference directly
    set.seed(42)
    n_boot <- 500
    diff_boots <- numeric(n_boot)
    for (b in seq_len(n_boot)) {
      pre_b <- dt_pre[sample(.N, replace = TRUE)]
      post_b <- dt_post[sample(.N, replace = TRUE)]
      pre_r <- estimate_bunching(pre_b, 600000)
      post_r <- estimate_bunching(post_b, 600000)
      if (!is.null(pre_r) & !is.null(post_r)) {
        diff_boots[b] <- post_r$bunching_ratio - pre_r$bunching_ratio
      } else {
        diff_boots[b] <- NA_real_
      }
    }
    diff_se <- sd(diff_boots, na.rm = TRUE)

    dib_results[[reg]] <- list(
      region = reg,
      pre_bunching = pre_result$bunching_ratio,
      post_bunching = post_result$bunching_ratio,
      diff = diff,
      pre_se = pre_boot$se,
      post_se = post_boot$se,
      diff_se = diff_se
    )

    cat(sprintf("  %s: Pre = %.3f (%.3f), Post = %.3f (%.3f), Diff = %.3f (%.3f)\n",
                reg, pre_result$bunching_ratio, pre_boot$se,
                post_result$bunching_ratio, post_boot$se,
                diff, diff_se))
  }
}

# ==============================================================================
# 6. SPATIAL RDD AT KEY BORDERS
# ==============================================================================

cat("\n=== SPATIAL RDD AT REGIONAL BORDERS ===\n\n")

border_labels <- c("NE_YH", "EoE_LON", "SE_LON")
rdd_results <- list()

for (bl in border_labels) {
  signed_col <- paste0("signed_dist_", bl)
  zone_col <- paste0("border_zone_", bl)

  if (!signed_col %in% names(ppd)) {
    cat(sprintf("  %s: No distance data available (skipping)\n", bl))
    next
  }

  dt_border <- ppd[new_build == TRUE & post_reform == TRUE &
                     !is.na(get(signed_col)) & abs(get(signed_col)) <= 30000]

  if (nrow(dt_border) < 50) {
    cat(sprintf("  %s: Insufficient observations (%d)\n", bl, nrow(dt_border)))
    next
  }

  cat(sprintf("  %s border: %d new builds in border zone\n", bl, nrow(dt_border)))

  tryCatch({
    rdd_fit <- rdrobust(y = dt_border$price,
                        x = dt_border[[signed_col]],
                        kernel = "triangular",
                        bwselect = "mserd")

    cat(sprintf("    RD estimate: £%.0f (SE: £%.0f, p = %.3f)\n",
                rdd_fit$coef[1], rdd_fit$se[1],
                2 * pnorm(-abs(rdd_fit$coef[1] / rdd_fit$se[1]))))
    cat(sprintf("    Bandwidth: %.0f meters\n", rdd_fit$bws[1, 1]))

    dens_test <- rddensity(dt_border[[signed_col]])
    cat(sprintf("    McCrary density test p-value: %.3f\n\n", dens_test$test$p_jk))

    rdd_results[[bl]] <- list(
      border = bl,
      n = nrow(dt_border),
      rd_estimate = rdd_fit$coef[1],
      rd_se = rdd_fit$se[1],
      rd_pvalue = 2 * pnorm(-abs(rdd_fit$coef[1] / rdd_fit$se[1])),
      bandwidth = rdd_fit$bws[1, 1],
      density_pvalue = dens_test$test$p_jk
    )
  }, error = function(e) {
    cat(sprintf("    RDD failed: %s\n\n", e$message))
  })
}

# ==============================================================================
# 7. PROPERTY TYPE COMPOSITION ANALYSIS
# ==============================================================================

cat("\n=== PROPERTY TYPE COMPOSITION ===\n")

type_shares <- ppd[new_build == TRUE,
                   .(detached = mean(property_type == "D"),
                     semi = mean(property_type == "S"),
                     terraced = mean(property_type == "T"),
                     flat = mean(property_type == "F"),
                     n = .N),
                   by = .(region, post_reform)]

type_diff <- dcast(type_shares, region ~ post_reform,
                   value.var = c("detached", "semi", "terraced", "flat", "n"))

if ("detached_TRUE" %in% names(type_diff) & "detached_FALSE" %in% names(type_diff)) {
  type_diff[, detached_change := detached_TRUE - detached_FALSE]
  cat("Change in detached house share (post - pre reform):\n")
  print(type_diff[, .(region, detached_FALSE, detached_TRUE, detached_change)][order(detached_change)])
}

# ==============================================================================
# 8. SAVE ALL RESULTS
# ==============================================================================

results_list <- list(
  bunching = bunching_results,
  placebo_resale = placebo_results,
  placebo_pre = pre_reform_results,
  dib = dib_results,
  rdd = rdd_results
)

saveRDS(results_list, file.path(data_dir, "main_results.rds"))
cat("\nAll results saved to main_results.rds\n")

}  # end of main script guard
