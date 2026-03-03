# =============================================================================
# 04_robustness.R — Robustness checks and sensitivity analysis
# apep_0493: Council Tax Support Localisation and Low-Income Employment
# =============================================================================

source("00_packages.R")

panel <- fread(file.path(data_dir, "analysis_panel.csv")) |>
  mutate(date = as.Date(date),
         rel_quarter = floor(rel_month / 3),
         rel_quarter_binned = pmax(pmin(rel_quarter, 16), -8))

cat("Panel loaded:", nrow(panel), "rows,", n_distinct(panel$la_code), "LAs\n")

# =============================================================================
# 1. LA-Specific Linear Pre-Trends
# =============================================================================
cat("\n=== Controlling for LA-Specific Linear Trends ===\n")

# The pre-period event study shows significant pre-trends
# Address by including LA-specific linear time trends

# Create time index
panel <- panel |>
  mutate(time_index = as.numeric(date - min(date)) / 30)  # months since start

# TWFE with LA-specific trends
mod_trend <- feols(
  claimant_rate ~ treat_binary:post | la_code[time_index] + date,
  data = panel,
  cluster = ~la_code
)

cat("TWFE with LA-specific linear trends:\n")
summary(mod_trend)

# Event study with LA-specific trends
mod_es_trend <- feols(
  claimant_rate ~ i(rel_quarter_binned, treat_binary, ref = -1) | la_code[time_index] + date,
  data = panel,
  cluster = ~la_code
)

# Save detrended event study coefficients
es_trend <- as.data.frame(coeftable(mod_es_trend)) |>
  tibble::rownames_to_column("term") |>
  filter(str_detect(term, "rel_quarter")) |>
  mutate(
    quarter = as.numeric(str_extract(term, "-?\\d+")),
    estimate = Estimate, se = `Std. Error`,
    ci_lo = estimate - 1.96 * se, ci_hi = estimate + 1.96 * se,
    spec = "Detrended"
  )

fwrite(es_trend, file.path(data_dir, "event_study_detrended.csv"))

cat("\nDetrended event study - pre-period coefficients:\n")
print(es_trend |> filter(quarter < -1) |> select(quarter, estimate, se))

# =============================================================================
# 2. HonestDiD Sensitivity (Rambachan & Roth 2023)
# =============================================================================
cat("\n=== HonestDiD Sensitivity Analysis ===\n")

# Run the basic event study for HonestDiD
mod_es_basic <- feols(
  claimant_rate ~ i(rel_quarter_binned, treat_binary, ref = -1) | la_code + date,
  data = panel,
  cluster = ~la_code
)

# Extract coefficients and variance-covariance matrix
betahat <- coef(mod_es_basic)
sigma <- vcov(mod_es_basic)

# Identify pre and post periods
all_terms <- names(betahat)
es_terms <- all_terms[str_detect(all_terms, "rel_quarter_binned")]

# Parse period numbers
periods <- as.numeric(str_extract(es_terms, "-?\\d+"))
pre_idx <- which(periods < -1)
post_idx <- which(periods >= 0)

if (length(pre_idx) > 0 && length(post_idx) > 0) {
  tryCatch({
    # Use HonestDiD for sensitivity to linear trends
    # M = max allowed change in slope of parallel trends violation
    honest_results <- HonestDiD::createSensitivityResults(
      betahat = betahat[es_terms],
      sigma = sigma[es_terms, es_terms],
      numPrePeriods = length(pre_idx),
      numPostPeriods = length(post_idx),
      Mvec = seq(0, 0.05, by = 0.01)
    )

    cat("HonestDiD results:\n")
    print(honest_results)
    saveRDS(honest_results, file.path(data_dir, "honestdid_results.rds"))
  }, error = function(e) {
    cat("HonestDiD error:", e$message, "\n")
    cat("Proceeding with alternative sensitivity checks\n")
  })
} else {
  cat("Could not identify pre/post periods for HonestDiD\n")
}

# =============================================================================
# 3. Pensioner Placebo Test
# =============================================================================
cat("\n=== Pensioner Placebo Test ===\n")

# Pensioners were PROTECTED from CTS cuts (by statute)
# If our treatment captures policy choices (not confounds),
# the same specification on pensioner outcomes should show NULL

# We don't have pensioner-specific claimant data directly,
# but we can use the working-age CTS share as a placebo check:
# Run on pension-age CTS instead of employment

# Alternative placebo: re-run DiD using periods BEFORE the reform
# Using 2008-2010 as pre and 2010-2012 as post (both under national CTB)
cat("  Falsification test: pre-reform placebo DiD (2008-2010 vs 2010-2012)\n")

placebo_panel <- panel |>
  filter(date < as.Date("2013-04-01")) |>
  mutate(
    placebo_post = as.integer(date >= as.Date("2010-10-01"))
  )

mod_placebo <- feols(
  claimant_rate ~ treat_binary:placebo_post | la_code + date,
  data = placebo_panel,
  cluster = ~la_code
)

cat("Placebo DiD (pre-reform only):\n")
summary(mod_placebo)

# =============================================================================
# 4. Alternative Treatment Measures
# =============================================================================
cat("\n=== Alternative Treatment Measures ===\n")

treatment <- fread(file.path(data_dir, "treatment.csv"))

# Approach A: Working-age CTS share (higher = more protected)
panel <- panel |>
  left_join(treatment |> select(la_code, wa_cts_share), by = "la_code", suffix = c("", ".dup")) |>
  select(-ends_with(".dup"))

# Standardize
panel$wa_share_std <- scale(panel$wa_cts_share)[, 1]

mod_share <- feols(
  claimant_rate ~ wa_share_std:post | la_code + date,
  data = panel,
  cluster = ~la_code
)

cat("WA CTS share specification:\n")
summary(mod_share)

# Approach B: Tercile groups (dose-response)
panel <- panel |>
  mutate(
    cut_high = as.integer(treat_tercile == 1),  # Bottom tercile = most cut
    cut_mid  = as.integer(treat_tercile == 2)   # Middle tercile
  )

mod_dose <- feols(
  claimant_rate ~ cut_high:post + cut_mid:post | la_code + date,
  data = panel,
  cluster = ~la_code
)

cat("\nDose-response (ref = protected/top tercile):\n")
summary(mod_dose)

# =============================================================================
# 5. Leave-One-Out Region Test
# =============================================================================
cat("\n=== Leave-One-Out Region Test ===\n")

# Get region from LA code prefix (approximate)
# English regions have specific GSS code ranges
# For simplicity, use the first characters of LA name
# Better: extract from NOMIS geography hierarchy

# Get region info from NOMIS data
regions <- panel |>
  distinct(la_code, la_name) |>
  mutate(
    # Approximate region from ONS code patterns
    region = case_when(
      str_starts(la_code, "E0[6-9]00000[0-4]") ~ "North",
      TRUE ~ "Other"
    )
  )

# Since we can't reliably assign regions from codes alone,
# do leave-one-out by LA instead (top 10 largest LAs)
top_10_las <- panel |>
  group_by(la_code) |>
  summarise(mean_pop = mean(working_age_pop, na.rm = TRUE)) |>
  arrange(desc(mean_pop)) |>
  head(10) |>
  pull(la_code)

loo_results <- tibble(
  excluded_la = character(),
  estimate = numeric(),
  se = numeric()
)

for (la in top_10_las) {
  mod_loo <- feols(
    claimant_rate ~ treat_binary:post | la_code + date,
    data = panel |> filter(la_code != la),
    cluster = ~la_code
  )
  ct <- coeftable(mod_loo)
  loo_results <- bind_rows(loo_results, tibble(
    excluded_la = la,
    estimate = ct[1, 1],
    se = ct[1, 2]
  ))
}

cat("Leave-one-out results (excluding largest 10 LAs):\n")
cat("  Range of estimates:", round(range(loo_results$estimate), 4), "\n")
cat("  All significant:", all(abs(loo_results$estimate / loo_results$se) > 1.96), "\n")

fwrite(loo_results, file.path(data_dir, "loo_results.csv"))

# =============================================================================
# 6. Donut Specification (Exclude Transition Period)
# =============================================================================
cat("\n=== Donut Specification ===\n")

mod_donut <- feols(
  claimant_rate ~ treat_binary:post | la_code + date,
  data = panel |> filter(abs(rel_month) > 6),  # Exclude 6 months around reform
  cluster = ~la_code
)

cat("Donut specification (excl. ±6 months):\n")
summary(mod_donut)

# =============================================================================
# 7. Pre-2020 Subsample (Excluding COVID Period)
# =============================================================================
cat("\n=== Pre-2020 Subsample (Excluding COVID) ===\n")

panel_pre2020 <- panel |> filter(date < as.Date("2020-01-01"))
cat("Pre-2020 panel:", nrow(panel_pre2020), "rows,",
    n_distinct(panel_pre2020$la_code), "LAs,",
    n_distinct(panel_pre2020$date), "months\n")

mod_pre2020_naive <- feols(
  claimant_rate ~ treat_binary:post | la_code + date,
  data = panel_pre2020, cluster = ~la_code
)

mod_pre2020_trend <- feols(
  claimant_rate ~ treat_binary:post | la_code[time_index] + date,
  data = panel_pre2020, cluster = ~la_code
)

cat("Pre-2020 Naive TWFE:\n")
cat("  Estimate:", round(coef(mod_pre2020_naive)[1], 4),
    "SE:", round(coeftable(mod_pre2020_naive)[1, 2], 4),
    "p:", round(coeftable(mod_pre2020_naive)[1, 4], 4), "\n")
cat("Pre-2020 LA Trends:\n")
cat("  Estimate:", round(coef(mod_pre2020_trend)[1], 4),
    "SE:", round(coeftable(mod_pre2020_trend)[1, 2], 4),
    "p:", round(coeftable(mod_pre2020_trend)[1, 4], 4), "\n")

# =============================================================================
# 8. Quadratic Trends Specification
# =============================================================================
cat("\n=== Quadratic Trends Specification ===\n")

panel <- panel |>
  mutate(time_index_sq = time_index^2)

mod_quad_trend <- feols(
  claimant_rate ~ treat_binary:post + I(time_index * as.numeric(factor(la_code))) +
    I(time_index_sq * as.numeric(factor(la_code))) | la_code + date,
  data = panel, cluster = ~la_code
)

# Alternative: use fixest polynomial syntax
mod_quad_trend2 <- tryCatch({
  feols(
    claimant_rate ~ treat_binary:post | la_code[time_index, time_index_sq] + date,
    data = panel, cluster = ~la_code
  )
}, error = function(e) {
  cat("  Quadratic trend via fixest syntax failed:", e$message, "\n")
  cat("  Using manual polynomial interaction\n")
  # Manual approach: create LA-specific quadratic
  feols(
    claimant_rate ~ treat_binary:post + i(la_code, time_index_sq, drop = TRUE) |
      la_code[time_index] + date,
    data = panel, cluster = ~la_code
  )
})

cat("Quadratic trends:\n")
ct_quad <- coeftable(mod_quad_trend2)
cat("  Estimate:", round(ct_quad["treat_binary:post", "Estimate"], 4),
    "SE:", round(ct_quad["treat_binary:post", "Std. Error"], 4),
    "p:", round(ct_quad["treat_binary:post", "Pr(>|t|)"], 4), "\n")

# =============================================================================
# 9. Dose-Response with LA Trends (investigate non-monotonicity)
# =============================================================================
cat("\n=== Dose-Response with LA Trends ===\n")

mod_dose_trend <- feols(
  claimant_rate ~ cut_high:post + cut_mid:post | la_code[time_index] + date,
  data = panel, cluster = ~la_code
)

cat("Dose-response with LA trends:\n")
summary(mod_dose_trend)

# Check: Are most-cut LAs on steeper pre-trends?
pre_trends_by_tercile <- panel |>
  filter(post == 0) |>
  group_by(treat_tercile) |>
  summarise(
    trend_slope = coef(lm(claimant_rate ~ time_index))[2],
    .groups = "drop"
  )
cat("\nPre-reform trend slopes by tercile:\n")
print(pre_trends_by_tercile)

# =============================================================================
# 10. Summary Table
# =============================================================================
cat("\n=== ROBUSTNESS SUMMARY ===\n")
cat(sprintf("%-40s %10s %10s\n", "Specification", "Estimate", "SE"))
cat(paste(rep("-", 62), collapse = ""), "\n")

robustness_specs <- list(
  list("Main TWFE (binary)", feols(claimant_rate ~ treat_binary:post | la_code + date,
                                    data = panel, cluster = ~la_code)),
  list("With LA-specific trends", mod_trend),
  list("WA CTS share (continuous)", mod_share),
  list("Donut (excl ±6 months)", mod_donut),
  list("Placebo (pre-reform only)", mod_placebo)
)

robustness_table <- tibble(
  Specification = character(), Estimate = numeric(), SE = numeric(), p = numeric()
)

for (s in robustness_specs) {
  ct <- coeftable(s[[2]])
  robustness_table <- bind_rows(robustness_table, tibble(
    Specification = s[[1]], Estimate = ct[1, 1], SE = ct[1, 2], p = ct[1, 4]
  ))
  cat(sprintf("%-40s %10.4f %10.4f\n", s[[1]], ct[1, 1], ct[1, 2]))
}

fwrite(robustness_table, file.path(data_dir, "robustness_table.csv"))

# Save all robustness models
saveRDS(list(
  trend = mod_trend, es_trend = mod_es_trend, placebo = mod_placebo,
  share = mod_share, dose = mod_dose, donut = mod_donut
), file.path(data_dir, "robustness_results.rds"))

cat("\n=== Robustness checks complete ===\n")
