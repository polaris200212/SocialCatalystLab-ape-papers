# ============================================================================
# 04_robustness.R — Robustness checks and placebo tests
# GST and Interstate Price Convergence
# ============================================================================

source("00_packages.R")

cpi <- fread("../data/cpi_panel.csv")
cpi[, date := as.Date(date)]
gen <- cpi[group == "General" & !is.na(index)]

cat("=== ROBUSTNESS CHECKS ===\n\n")

# ── R1: Exclude demonetization window (Nov 2016-Jun 2017) ────────────────
cat("--- R1: Exclude demonetization transition ---\n")
gen_no_demo <- gen[!(date >= "2016-11-01" & date <= "2017-06-01")]
r1 <- feols(log_index ~ post_gst:tax_intensity | state_id + time,
            data = gen_no_demo, cluster = ~state_id)
print(summary(r1))

# ── R2: Pre-COVID only (Jul 2017-Feb 2020) ───────────────────────────────
cat("\n--- R2: Pre-COVID window only ---\n")
gen_precovid <- gen[date <= "2020-02-01"]
r2 <- feols(log_index ~ post_gst:tax_intensity | state_id + time,
            data = gen_precovid, cluster = ~state_id)
print(summary(r2))

# ── R3: Fuel & Light placebo (excluded from GST) ─────────────────────────
cat("\n--- R3: Fuel & Light Placebo ---\n")
fuel <- cpi[group == "Fuel and Light" & !is.na(index)]
r3 <- feols(log_index ~ post_gst:tax_intensity | state_id + time,
            data = fuel, cluster = ~state_id)
cat("Fuel & Light (should be NULL — excluded from GST):\n")
print(summary(r3))

# ── R4: Leave-one-out (exclude each state sequentially) ──────────────────
cat("\n--- R4: Leave-one-out ---\n")
states <- unique(gen$state)
loo_results <- list()
for (s in states) {
  sub <- gen[state != s]
  fit <- feols(log_index ~ post_gst:tax_intensity | state_id + time,
               data = sub, cluster = ~state_id)
  loo_results[[s]] <- data.table(
    excluded_state = s,
    estimate = coef(fit)[[1]],
    se = coeftable(fit)[1, 2]
  )
}
loo_dt <- rbindlist(loo_results)
cat("Leave-one-out estimates:\n")
cat("  Range:", round(min(loo_dt$estimate), 5), "to",
    round(max(loo_dt$estimate), 5), "\n")
cat("  Mean:", round(mean(loo_dt$estimate), 5), "\n")
cat("  SD:", round(sd(loo_dt$estimate), 5), "\n")
fwrite(loo_dt, "../data/loo_results.csv")

# ── R5: Randomization inference ──────────────────────────────────────────
cat("\n--- R5: Randomization Inference (500 permutations) ---\n")
set.seed(42)
actual_coef <- coef(feols(log_index ~ post_gst:tax_intensity | state_id + time,
                          data = gen, cluster = ~state_id))[[1]]

n_perm <- 500
perm_coefs <- numeric(n_perm)
state_intensity <- unique(gen[, .(state_id, tax_intensity)])

for (i in seq_len(n_perm)) {
  if (i %% 100 == 0) cat("  Permutation", i, "of", n_perm, "\n")
  shuffled <- copy(state_intensity)
  shuffled[, tax_intensity_perm := sample(tax_intensity)]
  gen_perm <- merge(gen[, !c("tax_intensity"), with = FALSE],
                    shuffled[, .(state_id, tax_intensity = tax_intensity_perm)],
                    by = "state_id")
  fit_perm <- feols(log_index ~ post_gst:tax_intensity | state_id + time,
                    data = gen_perm, cluster = ~state_id)
  perm_coefs[i] <- coef(fit_perm)[[1]]
}

ri_p <- mean(abs(perm_coefs) >= abs(actual_coef))
cat("Actual coefficient:", round(actual_coef, 5), "\n")
cat("RI p-value (two-sided):", round(ri_p, 4), "\n")
cat("RI 95% CI: [", round(quantile(perm_coefs, 0.025), 5), ",",
    round(quantile(perm_coefs, 0.975), 5), "]\n")

ri_data <- data.table(
  actual = actual_coef,
  perm_coefs = perm_coefs,
  ri_p = ri_p
)
fwrite(ri_data, "../data/ri_results.csv")

# ── R6: Placebo in time (fake GST date = July 2015) ─────────────────────
cat("\n--- R6: Placebo in time (fake GST = July 2015) ---\n")
gen[, post_placebo := as.integer(date >= as.Date("2015-07-01"))]
gen_pre_real <- gen[date < "2017-07-01"]  # Only pre-GST data
r6 <- feols(log_index ~ post_placebo:tax_intensity | state_id + time,
            data = gen_pre_real, cluster = ~state_id)
cat("Placebo (should be NULL):\n")
print(summary(r6))

# ── R7: Rural vs Urban heterogeneity ─────────────────────────────────────
cat("\n--- R7: Rural vs Urban (fetch from separate files) ---\n")
cpi_r <- fread("../data/cpi_rural_raw.csv")
cpi_u <- fread("../data/cpi_urban_raw.csv")

# Quick clean for rural
month_map <- c("January"=1,"February"=2,"March"=3,"April"=4,"May"=5,"June"=6,
               "July"=7,"August"=8,"September"=9,"October"=10,"November"=11,"December"=12)

for (dt in list(cpi_r, cpi_u)) {
  dt[, month_num := month_map[month]]
  dt[, date := as.Date(paste(year, month_num, "01", sep = "-"))]
  dt[, index := as.numeric(index)]
  dt[, log_index := log(index)]
  dt[, post_gst := as.integer(date >= as.Date("2017-07-01"))]
  dt[, time := (year - 2013) * 12 + month_num]
}

# Merge intensity
state_tax <- fread("../data/state_tax_intensity.csv")
state_ids <- unique(cpi[, .(state, state_id, tax_intensity)])
for (dt in list(cpi_r, cpi_u)) {
  dt <- merge(dt, state_ids, by = "state", all.x = TRUE)
}

cpi_r <- merge(cpi_r, state_ids, by = "state", all.x = TRUE)
cpi_u <- merge(cpi_u, state_ids, by = "state", all.x = TRUE)

gen_r <- cpi_r[subgroup == "General-Overall" & !is.na(index) & !is.na(tax_intensity)]
gen_u <- cpi_u[subgroup == "General-Overall" & !is.na(index) & !is.na(tax_intensity)]

if (nrow(gen_r) > 100) {
  r7_rural <- feols(log_index ~ post_gst:tax_intensity | state_id + time,
                    data = gen_r, cluster = ~state_id)
  cat("Rural:\n")
  print(summary(r7_rural))
}

if (nrow(gen_u) > 100) {
  r7_urban <- feols(log_index ~ post_gst:tax_intensity | state_id + time,
                    data = gen_u, cluster = ~state_id)
  cat("Urban:\n")
  print(summary(r7_urban))
}

# ── R8: Dispersion-based outcome |log CPI - national mean| ───────────────
cat("\n--- R8: Dispersion outcome (absolute deviation from national mean) ---\n")

# Compute national mean log CPI per month
gen[, national_mean_log := mean(log_index, na.rm = TRUE), by = time]
gen[, abs_dev := abs(log_index - national_mean_log)]

r8 <- feols(abs_dev ~ post_gst:tax_intensity | state_id + time,
            data = gen, cluster = ~state_id)
cat("Dispersion outcome (|log CPI - national mean|):\n")
print(summary(r8))

# ── R9: State-specific linear trends ────────────────────────────────────
cat("\n--- R9: State-specific linear trends ---\n")

# Create numeric time trend (months since start)
gen[, trend := as.numeric(date - min(date)) / 30.44]  # roughly months

r9 <- feols(log_index ~ post_gst:tax_intensity | state_id[trend] + time,
            data = gen, cluster = ~state_id)
cat("State-specific linear trends:\n")
print(summary(r9))

# ── Save robustness models ───────────────────────────────────────────────
save(r1, r2, r3, r6, r8, r9, loo_dt, ri_data, file = "../data/robustness_models.RData")

cat("\n=== ALL ROBUSTNESS CHECKS COMPLETE ===\n")
