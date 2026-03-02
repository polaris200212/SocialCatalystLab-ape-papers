## 04_robustness.R — Robustness checks
## APEP-0420: The Visible and the Invisible

source("00_packages.R")

data_dir <- "../data"
tables_dir <- "../tables"
dir.create(tables_dir, showWarnings = FALSE, recursive = TRUE)

cat("Loading cleaned NBI panel...\n")
nbi <- fread(file.path(data_dir, "nbi_panel_clean.csv"))
nbi <- nbi[year >= 2001]

## ============================================================
## ROBUSTNESS 1: Alternative ADT cutoffs
## ============================================================

cat("\n=== Alternative ADT Cutoffs ===\n")

## Median split
nbi[, high_adt_median := as.integer(initial_adt > median(initial_adt, na.rm = TRUE)),
    by = state_fips]

## Quartile splits (use ntile to handle ties)
nbi[, adt_quartile_n := ntile(initial_adt, 4), by = state_fips]
nbi[, high_adt_q4 := as.integer(adt_quartile_n == 4)]

r1_median <- feols(deck_change ~ high_adt_median + bridge_age + I(bridge_age^2) +
                     total_len_m + n_spans |
                     state_fips^year + material,
                   data = nbi, cluster = ~state_fips)

r1_q4 <- feols(deck_change ~ high_adt_q4 + bridge_age + I(bridge_age^2) +
                 total_len_m + n_spans |
                 state_fips^year + material,
               data = nbi, cluster = ~state_fips)

cat("Median split:\n")
cat(sprintf("  β = %.4f (SE = %.4f)\n", coef(r1_median)["high_adt_median"],
            se(r1_median)["high_adt_median"]))
cat("Top quartile:\n")
cat(sprintf("  β = %.4f (SE = %.4f)\n", coef(r1_q4)["high_adt_q4"],
            se(r1_q4)["high_adt_q4"]))

## ============================================================
## ROBUSTNESS 2: Exclude recently built bridges (< 5 years old)
## ============================================================

cat("\n=== Exclude New Bridges (Placebo) ===\n")

r2_old <- feols(deck_change ~ high_initial_adt + bridge_age + I(bridge_age^2) +
                  total_len_m + n_spans |
                  state_fips^year + material,
                data = nbi[bridge_age >= 10], cluster = ~state_fips)

r2_new <- feols(deck_change ~ high_initial_adt + bridge_age + I(bridge_age^2) +
                  total_len_m + n_spans |
                  state_fips^year + material,
                data = nbi[bridge_age < 10], cluster = ~state_fips)

cat("Older bridges (age >= 10):\n")
cat(sprintf("  β = %.4f (SE = %.4f)\n", coef(r2_old)["high_initial_adt"],
            se(r2_old)["high_initial_adt"]))
cat("New bridges (age < 10):\n")
cat(sprintf("  β = %.4f (SE = %.4f)\n", coef(r2_new)["high_initial_adt"],
            se(r2_new)["high_initial_adt"]))

## ============================================================
## ROBUSTNESS 3: Exclude bridges with major reconstruction
## ============================================================

cat("\n=== Exclude Major Reconstruction Events ===\n")

## Major reconstruction = condition jump of 4+ points
nbi[, major_recon := as.integer(
  deck_change >= 4 | super_change >= 4 | sub_change >= 4
)]
nbi[is.na(major_recon), major_recon := 0L]

## Flag bridges that EVER had major reconstruction
recon_bridges <- nbi[major_recon == 1, unique(bridge_id)]

r3 <- feols(deck_change ~ high_initial_adt + bridge_age + I(bridge_age^2) +
              total_len_m + n_spans |
              state_fips^year + material,
            data = nbi[!bridge_id %in% recon_bridges], cluster = ~state_fips)

cat(sprintf("Excluding %s bridges with major reconstruction:\n",
            format(length(recon_bridges), big.mark = ",")))
cat(sprintf("  β = %.4f (SE = %.4f)\n", coef(r3)["high_initial_adt"],
            se(r3)["high_initial_adt"]))

## ============================================================
## ROBUSTNESS 4: Bridge fixed effects (within-bridge variation)
## ============================================================

cat("\n=== Bridge Fixed Effects ===\n")

## With bridge FE, we identify from within-bridge ADT changes over time
## (e.g., traffic growth or reclassification)
r4 <- feols(deck_cond ~ log(adt) + bridge_age + I(bridge_age^2) |
              bridge_id + year,
            data = nbi, cluster = ~state_fips)

cat("Bridge FE (log ADT on level of deck condition):\n")
print(summary(r4))

## ============================================================
## ROBUSTNESS 5: Alternative clustering
## ============================================================

cat("\n=== Alternative Clustering ===\n")

r5_state <- feols(deck_change ~ high_initial_adt + bridge_age + I(bridge_age^2) +
                    total_len_m + n_spans |
                    state_fips^year + material,
                  data = nbi, cluster = ~state_fips)

r5_county <- feols(deck_change ~ high_initial_adt + bridge_age + I(bridge_age^2) +
                     total_len_m + n_spans |
                     state_fips^year + material,
                   data = nbi[, county_id := state_fips * 1000 + county_fips],
                   cluster = ~county_id)

r5_twoway <- feols(deck_change ~ high_initial_adt + bridge_age + I(bridge_age^2) +
                     total_len_m + n_spans |
                     state_fips^year + material,
                   data = nbi[, county_id := state_fips * 1000 + county_fips],
                   cluster = ~state_fips + county_id)

cat("State clustering:\n")
cat(sprintf("  SE = %.4f\n", se(r5_state)["high_initial_adt"]))
cat("County clustering:\n")
cat(sprintf("  SE = %.4f\n", se(r5_county)["high_initial_adt"]))
cat("Two-way clustering:\n")
cat(sprintf("  SE = %.4f\n", se(r5_twoway)["high_initial_adt"]))

## ============================================================
## ROBUSTNESS 6: Covariate balance (propensity score diagnostics)
## ============================================================

cat("\n=== Covariate Balance ===\n")

## Check balance between high-ADT and low-ADT bridges
bal_sample <- nbi[initial_adt_tercile %in% c("Low", "High") & year == 2010]
bal_sample <- bal_sample[complete.cases(
  bal_sample[, .(high_initial_adt, bridge_age, total_len_m, n_spans, max_span_m, urban)]
)]

tryCatch({
  bal <- bal.tab(high_initial_adt ~ bridge_age + total_len_m + n_spans +
                   max_span_m + urban,
                 data = bal_sample, binary = "std")
  cat("Covariate balance (unweighted):\n")
  print(bal)

  saveRDS(bal, file.path(data_dir, "balance_results.rds"))
}, error = function(e) {
  cat(sprintf("Balance check error: %s\n", e$message))
})

## Save all robustness results
robustness_results <- list(
  r1_median = r1_median, r1_q4 = r1_q4,
  r2_old = r2_old, r2_new = r2_new,
  r3 = r3, r4 = r4,
  r5_state = r5_state, r5_county = r5_county, r5_twoway = r5_twoway
)
saveRDS(robustness_results, file.path(data_dir, "robustness_results.rds"))

cat("\n=== Robustness Checks Complete ===\n")
