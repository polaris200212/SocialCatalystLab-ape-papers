# ==============================================================================
# 04_robustness.R — Robustness Checks
# apep_0492 v1
# ==============================================================================

source("00_packages.R")

data_dir <- "../data"
ppd <- fread(file.path(data_dir, "ppd_analysis.csv"))

england_regions <- c("North East", "North West", "Yorkshire and The Humber",
                     "East Midlands", "West Midlands", "South West",
                     "East of England", "South East", "London")

htb_caps <- data.table(
  region = england_regions,
  cap = c(186100, 224400, 228100, 261900, 255600, 349000, 407400, 437600, 600000)
)

# Load bunching function from main analysis (flag to skip re-running analysis)
.sourced_for_functions <- TRUE
source("03_main_analysis.R")

# ==============================================================================
# 1. ALTERNATIVE BIN WIDTHS
# ==============================================================================

cat("\n=== ROBUSTNESS: ALTERNATIVE BIN WIDTHS ===\n")

bin_widths <- c(500, 1000, 2000)
bin_results <- list()

for (bw in bin_widths) {
  cat(sprintf("\nBin width: £%d\n", bw))
  for (i in seq_len(nrow(htb_caps))) {
    reg <- htb_caps$region[i]
    cap <- htb_caps$cap[i]

    dt_region <- ppd[new_build == TRUE & post_reform == TRUE & region == reg]
    result <- estimate_bunching(dt_region, cap, bin_width = bw)

    if (!is.null(result)) {
      key <- paste(reg, bw, sep = "_")
      bin_results[[key]] <- data.table(
        region = reg, bin_width = bw,
        bunching_ratio = result$bunching_ratio
      )
      cat(sprintf("  %s: b = %.3f\n", reg, result$bunching_ratio))
    }
  }
}

bin_robustness <- rbindlist(bin_results)
cat("\nBunching ratio sensitivity to bin width:\n")
print(dcast(bin_robustness, region ~ bin_width, value.var = "bunching_ratio"))

# ==============================================================================
# 2. ALTERNATIVE POLYNOMIAL ORDERS
# ==============================================================================

cat("\n=== ROBUSTNESS: POLYNOMIAL ORDER ===\n")

poly_orders <- c(5, 7, 9)
poly_results <- list()

for (po in poly_orders) {
  cat(sprintf("\nPolynomial order: %d\n", po))
  for (i in seq_len(nrow(htb_caps))) {
    reg <- htb_caps$region[i]
    cap <- htb_caps$cap[i]

    dt_region <- ppd[new_build == TRUE & post_reform == TRUE & region == reg]
    result <- estimate_bunching(dt_region, cap, poly_order = po)

    if (!is.null(result)) {
      key <- paste(reg, po, sep = "_")
      poly_results[[key]] <- data.table(
        region = reg, poly_order = po,
        bunching_ratio = result$bunching_ratio
      )
    }
  }
}

poly_robustness <- rbindlist(poly_results)
cat("\nBunching ratio sensitivity to polynomial order:\n")
print(dcast(poly_robustness, region ~ poly_order, value.var = "bunching_ratio"))

# ==============================================================================
# 3. ALTERNATIVE BUNCHING WINDOWS
# ==============================================================================

cat("\n=== ROBUSTNESS: BUNCHING WINDOW SIZE ===\n")

windows <- c(15000, 30000, 50000)
window_results <- list()

for (w in windows) {
  for (i in seq_len(nrow(htb_caps))) {
    reg <- htb_caps$region[i]
    cap <- htb_caps$cap[i]

    dt_region <- ppd[new_build == TRUE & post_reform == TRUE & region == reg]
    result <- estimate_bunching(dt_region, cap, window_below = w, window_above = w)

    if (!is.null(result)) {
      key <- paste(reg, w, sep = "_")
      window_results[[key]] <- data.table(
        region = reg, window = w,
        bunching_ratio = result$bunching_ratio
      )
    }
  }
}

window_robustness <- rbindlist(window_results)
cat("\nBunching ratio sensitivity to window size:\n")
print(dcast(window_robustness, region ~ window, value.var = "bunching_ratio"))

# ==============================================================================
# 4. DONUT SPECIFICATION
# ==============================================================================

cat("\n=== ROBUSTNESS: DONUT (EXCLUDE £1K AROUND CAP) ===\n")

donut_results <- list()
for (i in seq_len(nrow(htb_caps))) {
  reg <- htb_caps$region[i]
  cap <- htb_caps$cap[i]

  dt_donut <- ppd[new_build == TRUE & post_reform == TRUE & region == reg &
                    abs(price - cap) > 1000]

  result <- estimate_bunching(dt_donut, cap)
  if (!is.null(result)) {
    donut_results[[reg]] <- result$bunching_ratio
    cat(sprintf("  %s: b = %.3f (donut)\n", reg, result$bunching_ratio))
  }
}

# ==============================================================================
# 5. LEAVE-ONE-REGION-OUT (pooled bunching)
# ==============================================================================

cat("\n=== ROBUSTNESS: LEAVE-ONE-REGION-OUT ===\n")
cat("Pooled bunching estimate excluding each region:\n")

ppd_pool <- ppd[new_build == TRUE & post_reform == TRUE]
# Normalize prices by regional cap
ppd_pool[, norm_price := price / active_cap]

for (exclude_reg in england_regions) {
  dt_ex <- ppd_pool[region != exclude_reg]
  # Use normalized prices with cap at 1.0
  dt_ex_norm <- copy(dt_ex)
  dt_ex_norm[, price := norm_price]

  result <- estimate_bunching(dt_ex_norm, cap_value = 1, bin_width = 0.01,
                               window_below = 0.2, window_above = 0.2,
                               exclude_below = 0.03, exclude_above = 0.03)
  if (!is.null(result)) {
    cat(sprintf("  Excluding %s: b = %.3f\n", exclude_reg, result$bunching_ratio))
  }
}

# ==============================================================================
# 6. SPATIAL RDD — ALTERNATIVE BANDWIDTHS
# ==============================================================================

cat("\n=== ROBUSTNESS: SPATIAL RDD BANDWIDTHS ===\n")

border_labels <- c("NE_YH", "EoE_LON", "SE_LON")

for (bl in border_labels) {
  signed_col <- paste0("signed_dist_", bl)

  if (!signed_col %in% names(ppd)) {
    cat(sprintf("  %s: No distance data available (skipping)\n", bl))
    next
  }

  dt_border <- ppd[new_build == TRUE & post_reform == TRUE &
                     !is.na(get(signed_col))]

  for (h in c(5000, 10000, 20000, 50000)) {
    dt_h <- dt_border[abs(get(signed_col)) <= h]
    if (nrow(dt_h) < 30) next

    tryCatch({
      fit <- rdrobust(y = dt_h$price, x = dt_h[[signed_col]],
                      kernel = "triangular", bwselect = "mserd")
      cat(sprintf("  %s, h=%dkm: RD = £%.0f (p = %.3f, N = %d)\n",
                  bl, h / 1000, fit$coef[1],
                  2 * pnorm(-abs(fit$coef[1] / fit$se[1])),
                  nrow(dt_h)))
    }, error = function(e) NULL)
  }
}

# ==============================================================================
# 7. MONTHLY EVENT STUDY AROUND APRIL 2021
# ==============================================================================

cat("\n=== EVENT STUDY: MONTHLY BUNCHING ===\n")

ppd[, ym := as.Date(paste0(format(date_transfer, "%Y-%m"), "-01"))]

event_months <- seq(as.Date("2020-07-01"), as.Date("2022-12-01"), by = "month")
event_date <- as.Date("2021-04-01")

event_results <- list()

for (reg in c("North East", "North West", "Yorkshire and The Humber")) {
  cap <- htb_caps[region == reg, cap]

  for (m in event_months) {
    dt_m <- ppd[new_build == TRUE & region == reg & ym == m]
    if (nrow(dt_m) < 30) next

    result <- estimate_bunching(dt_m, cap)
    if (!is.null(result)) {
      event_results[[paste(reg, m)]] <- data.table(
        region = reg, month = as.Date(m, origin = "1970-01-01"),
        bunching_ratio = result$bunching_ratio,
        n = nrow(dt_m),
        months_to_reform = as.numeric(difftime(as.Date(m, origin = "1970-01-01"),
                                               event_date, units = "days")) / 30.44
      )
    }
  }
}

if (length(event_results) > 0) {
  event_study <- rbindlist(event_results)
  fwrite(event_study, file.path(data_dir, "event_study.csv"))
  cat("Event study data saved.\n")
}

# ==============================================================================
# 8. SAVE ROBUSTNESS RESULTS
# ==============================================================================

robustness <- list(
  bin_width = bin_robustness,
  poly_order = poly_robustness,
  window = window_robustness,
  donut = donut_results
)

saveRDS(robustness, file.path(data_dir, "robustness_results.rds"))
cat("\nRobustness results saved.\n")
