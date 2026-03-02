## ============================================================================
## 04_robustness.R — Robustness checks and sensitivity analysis
## ============================================================================

source("00_packages.R")

DATA <- "../data"
panel <- readRDS(file.path(DATA, "panel_analysis.rds"))
state_treatment <- readRDS(file.path(DATA, "state_treatment.rds"))

cat("=== Robustness Checks ===\n\n")

## ---- 1. Binary treatment (above/below median stringency) ----
cat("--- R1: Binary Treatment (Median Split) ---\n")
med_stringency <- median(state_treatment$peak_stringency, na.rm = TRUE)
panel[, high_stringency := as.integer(peak_stringency > med_stringency)]

r1_binary <- feols(
  log_paid ~ high_stringency:is_hcbs:post |
    state_f^service_f + service_f^month_f + state_f^month_f,
  data = panel,
  cluster = ~state_f
)
summary(r1_binary)

## ---- 2. Cumulative stringency (March-June avg) instead of peak (April) ----
cat("\n--- R2: Cumulative Stringency (Mar-Jun 2020) ---\n")
r2_cumul <- feols(
  log_paid ~ cum_stringency_std:is_hcbs:post |
    state_f^service_f + service_f^month_f + state_f^month_f,
  data = panel,
  cluster = ~state_f
)
summary(r2_cumul)

## ---- 3. Exclude never-lockdown states ----
cat("\n--- R3: Exclude Never-Lockdown States ---\n")
never_lockdown <- state_treatment[never_treated == TRUE]$state
panel_lockdown_only <- panel[!(state %in% never_lockdown)]
cat(sprintf("Excluding %d never-lockdown states: %s\n",
            length(never_lockdown), paste(never_lockdown, collapse = ", ")))

r3_no_never <- feols(
  log_paid ~ peak_stringency_std:is_hcbs:post |
    state_f^service_f + service_f^month_f + state_f^month_f,
  data = panel_lockdown_only,
  cluster = ~state_f
)
summary(r3_no_never)

## ---- 4. Placebo: Pre-period (treat March 2019 as fake lockdown) ----
cat("\n--- R4: Placebo Test (Fake Treatment March 2019) ---\n")
panel_pre <- panel[month_date < as.Date("2020-03-01")]
panel_pre[, placebo_post := as.integer(month_date >= as.Date("2019-04-01"))]

r4_placebo <- feols(
  log_paid ~ peak_stringency_std:is_hcbs:placebo_post |
    state_f^service_f + service_f^month_f + state_f^month_f,
  data = panel_pre,
  cluster = ~state_f
)
cat("Placebo DDD (should be null):\n")
summary(r4_placebo)

## ---- 5. Alternative comparison: CPT professional services instead of BH ----
cat("\n--- R5: Alternative Comparison Group (CPT Professional) ---\n")

# Rebuild panel with CPT instead of BH
tmsis_path <- file.path("..", "..", "..", "..", "data", "medicaid_provider_spending", "tmsis.parquet")
nppes_path <- file.path("..", "..", "..", "..", "data", "medicaid_provider_spending", "nppes_extract.parquet")

tmsis_ds <- open_dataset(tmsis_path)
nppes <- as.data.table(read_parquet(nppes_path))
nppes[, npi := as.character(npi)]
us_states <- c(state.abb, "DC")
npi_state <- nppes[!is.na(state) & state != "" & nchar(state) == 2 & state %in% us_states,
                   .(npi, state)]

cat("Building HCBS vs CPT panel...\n")
alt_monthly <- tmsis_ds |>
  mutate(
    hcpcs_prefix = substr(HCPCS_CODE, 1, 1),
    service_type = case_when(
      hcpcs_prefix == "T" ~ "HCBS",
      hcpcs_prefix %in% c("0","1","2","3","4","5","6","7","8","9") ~ "CPT",
      TRUE ~ NA_character_
    ),
    year = as.integer(substr(CLAIM_FROM_MONTH, 1, 4)),
    month_num = as.integer(substr(CLAIM_FROM_MONTH, 6, 7))
  ) |>
  filter(!is.na(service_type)) |>
  group_by(BILLING_PROVIDER_NPI_NUM, CLAIM_FROM_MONTH, year, month_num, service_type) |>
  summarize(
    total_paid = sum(TOTAL_PAID, na.rm = TRUE),
    total_claims = sum(TOTAL_CLAIMS, na.rm = TRUE),
    total_beneficiaries = sum(TOTAL_UNIQUE_BENEFICIARIES, na.rm = TRUE),
    .groups = "drop"
  ) |>
  collect() |>
  as.data.table()

setnames(alt_monthly, "BILLING_PROVIDER_NPI_NUM", "billing_npi")
alt_monthly <- merge(alt_monthly, npi_state, by.x = "billing_npi", by.y = "npi", all.x = FALSE)

alt_panel <- alt_monthly[, .(
  total_paid = sum(total_paid),
  total_claims = sum(total_claims),
  total_beneficiaries = sum(total_beneficiaries),
  n_providers = uniqueN(billing_npi)
), by = .(state, service_type, year, month_num, CLAIM_FROM_MONTH)]

alt_panel[, month_date := as.Date(paste0(CLAIM_FROM_MONTH, "-01"))]

# Drop March 2020
alt_panel <- alt_panel[month_date != as.Date("2020-03-01")]

# Merge treatment
alt_panel <- merge(alt_panel, state_treatment[, .(state, peak_stringency)], by = "state", all.x = TRUE)
alt_panel[, `:=`(
  post = as.integer(month_date >= as.Date("2020-04-01")),
  is_hcbs = as.integer(service_type == "HCBS"),
  log_paid = log(total_paid + 1),
  peak_stringency_std = peak_stringency / 100,
  state_f = factor(state),
  service_f = factor(service_type),
  month_f = factor(month_date)
)]

r5_cpt <- feols(
  log_paid ~ peak_stringency_std:is_hcbs:post |
    state_f^service_f + service_f^month_f + state_f^month_f,
  data = alt_panel,
  cluster = ~state_f
)
cat("DDD with CPT as comparison (instead of BH):\n")
summary(r5_cpt)

rm(alt_monthly, alt_panel)
gc()

## ---- 6. Wild cluster bootstrap (50 clusters — borderline) ----
cat("\n--- R6: Wild Cluster Bootstrap P-values ---\n")
# fixest doesn't have built-in WCB, but we can do randomization inference

# Randomization inference: permute stringency across states
set.seed(42)
n_perms <- 1000
perm_coefs <- numeric(n_perms)

# Get the actual coefficient
actual_coef <- coef(feols(
  log_paid ~ peak_stringency_std:is_hcbs:post |
    state_f^service_f + service_f^month_f + state_f^month_f,
  data = panel,
  cluster = ~state_f
))

# State-level permutation
states_in_data <- unique(panel$state)
cat(sprintf("Running %d permutations of stringency across %d states...\n",
            n_perms, length(states_in_data)))

for (i in 1:n_perms) {
  if (i %% 100 == 0) cat(sprintf("  Permutation %d/%d\n", i, n_perms))

  # Permute peak_stringency across states
  perm_map <- data.table(
    state = states_in_data,
    perm_stringency = sample(panel[!duplicated(state), peak_stringency_std])
  )

  panel_perm <- merge(panel, perm_map, by = "state")

  tryCatch({
    m_perm <- feols(
      log_paid ~ perm_stringency:is_hcbs:post |
        state_f^service_f + service_f^month_f + state_f^month_f,
      data = panel_perm,
      cluster = ~state_f
    )
    perm_coefs[i] <- coef(m_perm)
  }, error = function(e) {
    perm_coefs[i] <<- NA
  })
}

perm_coefs <- perm_coefs[!is.na(perm_coefs)]
ri_p <- mean(abs(perm_coefs) >= abs(actual_coef))
cat(sprintf("\nRandomization Inference p-value: %.4f (based on %d valid permutations)\n",
            ri_p, length(perm_coefs)))
cat(sprintf("Actual coefficient: %.4f\n", actual_coef))
cat(sprintf("Permutation distribution: mean=%.4f, sd=%.4f\n",
            mean(perm_coefs), sd(perm_coefs)))

## ---- 7. Time-varying stringency (monthly) instead of peak ----
cat("\n--- R7: Time-Varying Monthly Stringency (Apr 2020 - Dec 2022) ---\n")
# Restrict to OxCGRT coverage period (stringency is zero after Dec 2022)
panel_oxcgrt <- panel[post == 1 & month_date <= as.Date("2022-12-01")]
cat(sprintf("Sample restricted to OxCGRT coverage: %d obs (Apr 2020 - Dec 2022)\n", nrow(panel_oxcgrt)))

r7_monthly <- feols(
  log_paid ~ stringency_avg:is_hcbs |
    state_f^service_f + service_f^month_f + state_f^month_f,
  data = panel_oxcgrt,
  cluster = ~state_f
)
cat("Monthly stringency × HCBS (OxCGRT coverage period only):\n")
summary(r7_monthly)

## ---- 8. Save all robustness results ----
robustness <- list(
  r1_binary = r1_binary,
  r2_cumul = r2_cumul,
  r3_no_never = r3_no_never,
  r4_placebo = r4_placebo,
  r5_cpt = r5_cpt,
  r7_monthly = r7_monthly,
  ri_pvalue = ri_p,
  ri_actual_coef = actual_coef,
  ri_perm_coefs = perm_coefs,
  n_perms = length(perm_coefs)
)

saveRDS(robustness, file.path(DATA, "robustness_results.rds"))

cat("\n=== Robustness checks complete ===\n")
