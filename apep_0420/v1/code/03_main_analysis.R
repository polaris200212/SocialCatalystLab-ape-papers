## 03_main_analysis.R — Main regression analysis
## APEP-0420: The Visible and the Invisible

source("00_packages.R")

data_dir <- "../data"
tables_dir <- "../tables"
dir.create(tables_dir, showWarnings = FALSE, recursive = TRUE)

## Load cleaned panel
cat("Loading cleaned NBI panel...\n")
nbi <- fread(file.path(data_dir, "nbi_panel_clean.csv"))

## Restrict to years where we have condition changes (need lag)
nbi <- nbi[year >= 2001]
cat(sprintf("Analysis sample: %s observations\n", format(nrow(nbi), big.mark = ",")))

## ============================================================
## SECTION 1: OLS WITH FIXED EFFECTS (Benchmark)
## ============================================================

cat("\n=== OLS Fixed Effects Regressions ===\n")

## Model 1: Pooled OLS — ADT tercile on deck condition change
m1 <- feols(deck_change ~ high_initial_adt | state_fips + year,
            data = nbi, cluster = ~state_fips)

## Model 2: Add engineering covariates
m2 <- feols(deck_change ~ high_initial_adt + bridge_age + I(bridge_age^2) +
              log_adt + total_len_m + n_spans + max_span_m |
              state_fips + year,
            data = nbi, cluster = ~state_fips)

## Model 3: State × year FE (absorb all state-level time variation)
m3 <- feols(deck_change ~ high_initial_adt + bridge_age + I(bridge_age^2) +
              total_len_m + n_spans + max_span_m |
              state_fips^year,
            data = nbi, cluster = ~state_fips)

## Model 4: Material type FE
m4 <- feols(deck_change ~ high_initial_adt + bridge_age + I(bridge_age^2) +
              total_len_m + n_spans + max_span_m |
              state_fips^year + material,
            data = nbi, cluster = ~state_fips)

## Model 5: Continuous log(ADT) instead of tercile
m5 <- feols(deck_change ~ log(initial_adt) + bridge_age + I(bridge_age^2) +
              total_len_m + n_spans + max_span_m |
              state_fips^year + material,
            data = nbi[initial_adt > 0], cluster = ~state_fips)

cat("Model 1 (basic FE):\n")
print(summary(m1))
cat("\nModel 5 (continuous log ADT):\n")
print(summary(m5))

## Save main results
main_results <- list(m1 = m1, m2 = m2, m3 = m3, m4 = m4, m5 = m5)
saveRDS(main_results, file.path(data_dir, "main_results.rds"))

## ============================================================
## SECTION 2: ELECTORAL MAINTENANCE CYCLE
## ============================================================

cat("\n=== Electoral Maintenance Cycle ===\n")

## Key test: high-ADT bridges get more repairs in election/pre-election years
## This separates "political visibility" from "economic importance"

## Model 6: Interaction ADT × election window
## election_window varies at state-year level; with state×year FE, only the
## interaction (within-state-year variation) is identified
m6 <- feols(repair_event ~ high_initial_adt + high_initial_adt:election_window +
              bridge_age + I(bridge_age^2) + total_len_m |
              state_fips^year + material,
            data = nbi, cluster = ~state_fips)

## Model 7: Interaction with pre-election year specifically
## Use state + year FE (not state×year) because gov_election varies at state×year level
m7 <- feols(repair_event ~ high_initial_adt * pre_election +
              high_initial_adt * gov_election +
              bridge_age + I(bridge_age^2) + total_len_m |
              state_fips + year + material,
            data = nbi, cluster = ~state_fips)

## Model 8: Low-ADT bridges should NOT show election cycle
## election_window absorbed by state×year FE; only interaction identified
m8 <- feols(repair_event ~ low_adt + low_adt:election_window +
              bridge_age + I(bridge_age^2) + total_len_m |
              state_fips^year + material,
            data = nbi, cluster = ~state_fips)

cat("Model 6 (ADT × election window):\n")
print(summary(m6))
cat("\nModel 7 (pre-election vs election year):\n")
print(summary(m7))

election_results <- list(m6 = m6, m7 = m7, m8 = m8)
saveRDS(election_results, file.path(data_dir, "election_results.rds"))

## ============================================================
## SECTION 3: VISIBLE vs INVISIBLE COMPONENTS
## ============================================================

cat("\n=== Visible vs Invisible Components (Placebo) ===\n")

## DECK condition (VISIBLE from the road) — should show visibility premium
m_deck <- feols(deck_change ~ high_initial_adt + bridge_age + I(bridge_age^2) +
                  total_len_m + n_spans |
                  state_fips^year + material,
                data = nbi, cluster = ~state_fips)

## SUPERSTRUCTURE condition (partially visible)
m_super <- feols(super_change ~ high_initial_adt + bridge_age + I(bridge_age^2) +
                   total_len_m + n_spans |
                   state_fips^year + material,
                 data = nbi, cluster = ~state_fips)

## SUBSTRUCTURE condition (INVISIBLE — underwater/underground) — should NOT show premium
m_sub <- feols(sub_change ~ high_initial_adt + bridge_age + I(bridge_age^2) +
                 total_len_m + n_spans |
                 state_fips^year + material,
               data = nbi, cluster = ~state_fips)

cat("Deck (VISIBLE) — high ADT coefficient:\n")
cat(sprintf("  β = %.4f (SE = %.4f)\n", coef(m_deck)["high_initial_adt"],
            se(m_deck)["high_initial_adt"]))

cat("Superstructure (partial) — high ADT coefficient:\n")
cat(sprintf("  β = %.4f (SE = %.4f)\n", coef(m_super)["high_initial_adt"],
            se(m_super)["high_initial_adt"]))

cat("Substructure (INVISIBLE) — high ADT coefficient:\n")
cat(sprintf("  β = %.4f (SE = %.4f)\n", coef(m_sub)["high_initial_adt"],
            se(m_sub)["high_initial_adt"]))

component_results <- list(m_deck = m_deck, m_super = m_super, m_sub = m_sub)
saveRDS(component_results, file.path(data_dir, "component_results.rds"))

## ============================================================
## SECTION 4: URBAN/RURAL HETEROGENEITY
## ============================================================

cat("\n=== Urban/Rural Heterogeneity ===\n")

## Urban bridges: high ADT = more political visibility (more voters)
## Rural bridges: high ADT = mainly economic (truck routes), less political
m_urban <- feols(deck_change ~ high_initial_adt * urban +
                   bridge_age + I(bridge_age^2) + total_len_m |
                   state_fips^year + material,
                 data = nbi, cluster = ~state_fips)

cat("Urban × High ADT interaction:\n")
print(summary(m_urban))

## ============================================================
## SECTION 5: DOUBLY ROBUST ESTIMATION
## ============================================================

cat("\n=== Doubly Robust (AIPW) Estimation ===\n")

## For DR, we need a manageable sample — use a smaller random sample for speed
set.seed(42)
dr_sample <- nbi[sample(.N, min(.N, 50000))]
dr_sample <- dr_sample[complete.cases(
  dr_sample[, .(deck_change, high_initial_adt, bridge_age, total_len_m,
                n_spans, max_span_m, urban)]
)]

cat(sprintf("DR sample size: %s\n", format(nrow(dr_sample), big.mark = ",")))

## Covariates for DR
covariates <- c("bridge_age", "total_len_m", "n_spans", "max_span_m", "urban")

## Check that we have variation
cat(sprintf("Treatment rate (high initial ADT): %.1f%%\n",
            100 * mean(dr_sample$high_initial_adt)))

## Fit AIPW with SuperLearner
tryCatch({
  ## Define SL library (simpler for speed)
  sl_lib <- c("SL.glm", "SL.ranger")

  aipw_obj <- AIPW$new(
    Y = dr_sample$deck_change,
    A = dr_sample$high_initial_adt,
    W = as.data.frame(dr_sample[, ..covariates]),
    Q.SL.library = sl_lib,
    g.SL.library = sl_lib,
    k_split = 5,
    verbose = FALSE
  )

  aipw_obj$fit()
  aipw_result <- aipw_obj$summary()

  cat("\nAIPW Results:\n")
  print(aipw_result)

  ## Save
  saveRDS(list(aipw_obj = aipw_obj, aipw_result = aipw_result),
          file.path(data_dir, "dr_results.rds"))

}, error = function(e) {
  cat(sprintf("AIPW estimation error: %s\n", e$message))
  cat("Falling back to IPW estimation...\n")

  ## Fallback: manual IPW
  ps_model <- glm(high_initial_adt ~ bridge_age + I(bridge_age^2) +
                     total_len_m + n_spans + max_span_m + urban,
                   data = dr_sample, family = binomial)
  dr_sample[, ps := predict(ps_model, type = "response")]

  ## IPW estimate
  dr_sample[, ipw := fifelse(high_initial_adt == 1, 1/ps, 1/(1-ps))]
  ## Trim extreme weights
  dr_sample[ipw > quantile(ipw, 0.99), ipw := quantile(ipw, 0.99)]

  ipw_est <- dr_sample[high_initial_adt == 1, weighted.mean(deck_change, ipw, na.rm = TRUE)] -
    dr_sample[high_initial_adt == 0, weighted.mean(deck_change, ipw, na.rm = TRUE)]

  cat(sprintf("IPW estimate (ATE): %.4f\n", ipw_est))

  saveRDS(list(ps_model = ps_model, ipw_est = ipw_est),
          file.path(data_dir, "dr_results.rds"))
})

## ============================================================
## SECTION 6: SENSITIVITY ANALYSIS
## ============================================================

cat("\n=== Sensitivity Analysis (Cinelli & Hazlett) ===\n")

## Use OLS benchmark for sensitivity analysis (no state FE for lm speed)
set.seed(123)
sens_sample <- dr_sample[sample(.N, min(.N, 20000))]
ols_bench <- lm(deck_change ~ high_initial_adt + bridge_age + I(bridge_age^2) +
                  total_len_m + n_spans + max_span_m + urban,
                data = sens_sample)

tryCatch({
  sens <- sensemakr(
    model = ols_bench,
    treatment = "high_initial_adt",
    benchmark_covariates = c("bridge_age", "total_len_m"),
    kd = 1:3
  )

  cat("\nSensitivity Analysis Results:\n")
  print(summary(sens))

  saveRDS(sens, file.path(data_dir, "sensitivity_results.rds"))
}, error = function(e) {
  cat(sprintf("Sensitivity analysis error: %s\n", e$message))
})

cat("\n=== Main Analysis Complete ===\n")
