## ============================================================================
## 04_robustness.R — Placebo tests, heterogeneity, sensitivity analysis
## Paper: When the Safety Net Frays (apep_0368)
## ============================================================================

source("00_packages.R")
DATA <- "../data"
load(file.path(DATA, "02_analysis_data.RData"))
load(file.path(DATA, "03_results.RData"))

## ---- 1. Placebo: CPT Providers ----
cat("=== Placebo Test: CPT Providers ===\n")

# CPT providers can bill Medicare — should be less affected
# Create combined panel with BH and CPT
panel_bh <- panel[service_cat == "BH",
                   .(state, month, log_paid, log_claims, log_providers,
                     unwind_start, disenroll_rate, year_month, state_id)]
panel_bh[, service_cat := "BH"]

panel_cpt2 <- panel_cpt[, .(state, month, log_paid, log_claims, log_providers,
                             unwind_start, disenroll_rate, year_month, state_id)]
panel_cpt2[, service_cat := "CPT"]

placebo_panel <- rbind(panel_bh, panel_cpt2)
placebo_panel[, `:=`(
  post = as.integer(month >= unwind_start),
  bh = as.integer(service_cat == "BH"),
  post_bh = as.integer(month >= unwind_start) * as.integer(service_cat == "BH")
)]

placebo_ddd <- feols(
  log_paid ~ post_bh |
    state^year_month + service_cat^year_month + state^service_cat,
  data = placebo_panel,
  cluster = ~state
)
cat("Placebo DDD (BH vs CPT):\n")
summary(placebo_ddd)

## ---- 2. Heterogeneity by Provider Type ----
cat("\n=== Heterogeneity: Individual vs Organization ===\n")

# Merge entity type onto panel at provider level, then reaggregate
tmsis_agg_typed <- merge(
  tmsis_agg[service_cat %in% c("BH", "HCBS")],
  nppes[, .(npi, entity_type)],
  by = "npi", all.x = TRUE, allow.cartesian = TRUE
)

# Individual providers (entity_type == "1")
panel_indiv <- tmsis_agg_typed[entity_type == "1",
  .(total_paid = sum(total_paid, na.rm = TRUE),
    n_providers = uniqueN(npi)),
  by = .(state, service_cat, month)]
panel_indiv[, `:=`(log_paid = log(total_paid + 1),
                    log_providers = log(n_providers + 1))]
panel_indiv <- merge(panel_indiv, unwinding, by = "state", all.x = TRUE)
panel_indiv[, `:=`(
  post = as.integer(month >= unwind_start),
  bh = as.integer(service_cat == "BH"),
  post_bh = as.integer(month >= unwind_start) * as.integer(service_cat == "BH"),
  year_month = as.integer(format(month, "%Y")) * 12 +
    as.integer(format(month, "%m")),
  state_id = as.integer(factor(state))
)]

ddd_indiv <- feols(
  log_paid ~ post_bh |
    state^year_month + service_cat^year_month + state^service_cat,
  data = panel_indiv,
  cluster = ~state
)
cat("Individual providers DDD:\n")
summary(ddd_indiv)

# Organization providers (entity_type == "2")
panel_org <- tmsis_agg_typed[entity_type == "2",
  .(total_paid = sum(total_paid, na.rm = TRUE),
    n_providers = uniqueN(npi)),
  by = .(state, service_cat, month)]
panel_org[, `:=`(log_paid = log(total_paid + 1),
                  log_providers = log(n_providers + 1))]
panel_org <- merge(panel_org, unwinding, by = "state", all.x = TRUE)
panel_org[, `:=`(
  post = as.integer(month >= unwind_start),
  bh = as.integer(service_cat == "BH"),
  post_bh = as.integer(month >= unwind_start) * as.integer(service_cat == "BH"),
  year_month = as.integer(format(month, "%Y")) * 12 +
    as.integer(format(month, "%m")),
  state_id = as.integer(factor(state))
)]

ddd_org <- feols(
  log_paid ~ post_bh |
    state^year_month + service_cat^year_month + state^service_cat,
  data = panel_org,
  cluster = ~state
)
cat("Organization providers DDD:\n")
summary(ddd_org)

## ---- 3. Heterogeneity by Procedural Disenrollment Share ----
cat("\n=== Heterogeneity: High vs Low Procedural Share ===\n")

median_proc <- median(unwinding$procedural_share, na.rm = TRUE)
panel[, high_procedural := as.integer(procedural_share > median_proc)]

ddd_high_proc <- feols(
  log_paid ~ post_bh |
    state^year_month + service_cat^year_month + state^service_cat,
  data = panel[high_procedural == 1],
  cluster = ~state
)
cat("High procedural share states:\n")
summary(ddd_high_proc)

ddd_low_proc <- feols(
  log_paid ~ post_bh |
    state^year_month + service_cat^year_month + state^service_cat,
  data = panel[high_procedural == 0],
  cluster = ~state
)
cat("Low procedural share states:\n")
summary(ddd_low_proc)

## ---- 4. Pre-trend Falsification ----
cat("\n=== Pre-trend Falsification: Fake Unwinding at 2021-04 ===\n")

panel_pre <- panel[month < as.Date("2023-04-01")]
panel_pre[, `:=`(
  fake_post = as.integer(month >= as.Date("2021-04-01")),
  fake_post_bh = as.integer(month >= as.Date("2021-04-01")) * bh
)]

ddd_pretrend <- feols(
  log_paid ~ fake_post_bh |
    state^year_month + service_cat^year_month + state^service_cat,
  data = panel_pre,
  cluster = ~state
)
cat("Fake unwinding (Apr 2021) DDD:\n")
summary(ddd_pretrend)

## ---- 5. Bacon Decomposition ----
cat("\n=== Bacon Decomposition (BH only) ===\n")

bh_state_year <- panel[service_cat == "BH",
  .(log_paid = mean(log_paid)),
  by = .(state, year_month, post)]

# Bacon needs binary treatment
tryCatch({
  library(bacondecomp)
  bacon_out <- bacon(
    log_paid ~ post,
    data = as.data.frame(bh_state_year),
    id_var = "state",
    time_var = "year_month"
  )
  cat("Bacon decomposition:\n")
  print(summary(bacon_out))
}, error = function(e) {
  cat("Bacon decomposition failed:", e$message, "\n")
})

## ---- 6. Randomization Inference ----
cat("\n=== Randomization Inference ===\n")

# Permute state assignment to unwinding cohorts
set.seed(42)
n_perms <- 500

obs_coef <- coef(results$ddd_paid)["post_bh"]

perm_coefs <- numeric(n_perms)
states <- unique(panel$state)

for (i in 1:n_perms) {
  # Randomly reassign unwinding dates
  shuffled_dates <- unwinding[sample(.N)]
  perm_map <- data.table(
    state = states,
    fake_start = shuffled_dates$unwind_start[1:length(states)]
  )

  panel_perm <- merge(panel, perm_map, by = "state")
  panel_perm[, `:=`(
    fake_post = as.integer(month >= fake_start),
    fake_post_bh = as.integer(month >= fake_start) * bh
  )]

  perm_mod <- tryCatch(
    feols(log_paid ~ fake_post_bh |
            state^year_month + service_cat^year_month + state^service_cat,
          data = panel_perm, cluster = ~state),
    error = function(e) NULL
  )

  if (!is.null(perm_mod)) {
    perm_coefs[i] <- coef(perm_mod)["fake_post_bh"]
  } else {
    perm_coefs[i] <- NA
  }
}

ri_pvalue <- mean(abs(perm_coefs) >= abs(obs_coef), na.rm = TRUE)
cat(sprintf("Observed coefficient: %.4f\n", obs_coef))
cat(sprintf("RI p-value (two-sided, %d permutations): %.4f\n",
            n_perms, ri_pvalue))

## ---- 7. Save robustness results ----
rob_results <- list(
  placebo_ddd = placebo_ddd,
  ddd_indiv = ddd_indiv,
  ddd_org = ddd_org,
  ddd_high_proc = ddd_high_proc,
  ddd_low_proc = ddd_low_proc,
  ddd_pretrend = ddd_pretrend,
  ri_pvalue = ri_pvalue,
  ri_coefs = perm_coefs,
  obs_coef = obs_coef
)

save(rob_results, file = file.path(DATA, "04_robustness.RData"))
cat("\nSaved: 04_robustness.RData\n")
