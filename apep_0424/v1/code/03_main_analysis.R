## ============================================================================
## 03_main_analysis.R -- Primary DiD estimation
## ============================================================================

source("00_packages.R")
DATA <- "../data"

panel_bh <- readRDS(file.path(DATA, "panel_bh.rds"))
panel_pc <- readRDS(file.path(DATA, "panel_pc.rds"))
panel_full <- readRDS(file.path(DATA, "panel_full.rds"))

## --------------------------------------------------------------------------
## 1. TWFE Baseline
## --------------------------------------------------------------------------

twfe_prov  <- feols(ln_providers ~ post | state_id + time_q, data = panel_bh, cluster = ~state)
twfe_claim <- feols(ln_claims ~ post | state_id + time_q, data = panel_bh, cluster = ~state)
twfe_benef <- feols(ln_beneficiaries ~ post | state_id + time_q, data = panel_bh, cluster = ~state)
twfe_paid  <- feols(ln_paid ~ post | state_id + time_q, data = panel_bh, cluster = ~state)

cat("=== TWFE Results ===\n")
etable(twfe_prov, twfe_claim, twfe_benef, twfe_paid,
       headers = c("ln(Prov)", "ln(Claims)", "ln(Benef)", "ln(Paid)"))

saveRDS(list(twfe_prov = twfe_prov, twfe_claim = twfe_claim,
             twfe_benef = twfe_benef, twfe_paid = twfe_paid),
        file.path(DATA, "twfe_results.rds"))

## --------------------------------------------------------------------------
## 2. Callaway-Sant'Anna Group-Time ATTs
## --------------------------------------------------------------------------

cat("\nRunning CS estimation...\n")

set.seed(2024)

cs_prov <- att_gt(
  yname = "ln_providers", tname = "time_q", idname = "state_id",
  gname = "first_treat_q", data = as.data.frame(panel_bh),
  control_group = "nevertreated", bstrap = TRUE, cband = TRUE, biters = 1000
)
es_prov <- aggte(cs_prov, type = "dynamic", min_e = -8, max_e = 8)
att_prov <- aggte(cs_prov, type = "group")

cat("\n=== CS Event Study: ln(Providers) ===\n")
summary(es_prov)
cat(sprintf("\nOverall ATT: %.4f (SE: %.4f)\n", att_prov$overall.att, att_prov$overall.se))

cs_benef <- att_gt(
  yname = "ln_beneficiaries", tname = "time_q", idname = "state_id",
  gname = "first_treat_q", data = as.data.frame(panel_bh),
  control_group = "nevertreated", bstrap = TRUE, cband = TRUE, biters = 1000
)
es_benef <- aggte(cs_benef, type = "dynamic", min_e = -8, max_e = 8)
att_benef <- aggte(cs_benef, type = "group")

cs_claim <- att_gt(
  yname = "ln_claims", tname = "time_q", idname = "state_id",
  gname = "first_treat_q", data = as.data.frame(panel_bh),
  control_group = "nevertreated", bstrap = TRUE, cband = TRUE, biters = 1000
)
es_claim <- aggte(cs_claim, type = "dynamic", min_e = -8, max_e = 8)
att_claim <- aggte(cs_claim, type = "group")

cs_paid <- att_gt(
  yname = "ln_paid", tname = "time_q", idname = "state_id",
  gname = "first_treat_q", data = as.data.frame(panel_bh),
  control_group = "nevertreated", bstrap = TRUE, cband = TRUE, biters = 1000
)
es_paid <- aggte(cs_paid, type = "dynamic", min_e = -8, max_e = 8)
att_paid <- aggte(cs_paid, type = "group")

saveRDS(list(
  cs_prov = cs_prov, es_prov = es_prov, att_prov = att_prov,
  cs_benef = cs_benef, es_benef = es_benef, att_benef = att_benef,
  cs_claim = cs_claim, es_claim = es_claim, att_claim = att_claim,
  cs_paid = cs_paid, es_paid = es_paid, att_paid = att_paid
), file.path(DATA, "cs_results.rds"))

## --------------------------------------------------------------------------
## 3. Sun-Abraham Interaction-Weighted Estimator
## --------------------------------------------------------------------------

panel_bh[, cohort := fifelse(first_treat_q == 0, 10000L, first_treat_q)]

sa_prov  <- feols(ln_providers ~ sunab(cohort, time_q) | state_id + time_q,
                  data = panel_bh, cluster = ~state)
sa_benef <- feols(ln_beneficiaries ~ sunab(cohort, time_q) | state_id + time_q,
                  data = panel_bh, cluster = ~state)

cat("\n=== Sun-Abraham: ln(Providers) ===\n")
summary(sa_prov)

saveRDS(list(sa_prov = sa_prov, sa_benef = sa_benef),
        file.path(DATA, "sa_results.rds"))

## --------------------------------------------------------------------------
## 4. Triple-Difference: BH vs Personal Care
## --------------------------------------------------------------------------

panel_ddd <- panel_full[service_type %in% c("behavioral_health", "personal_care") &
                          state %in% unique(panel_bh$state)]
panel_ddd[, bh := as.integer(service_type == "behavioral_health")]
panel_ddd[, state_bh := paste0(state, "_", bh)]
panel_ddd[, state_bh_id := as.integer(factor(state_bh))]

ddd_prov  <- feols(ln_providers ~ post:i(bh) | state_bh_id + time_q^bh,
                   data = panel_ddd, cluster = ~state)
ddd_benef <- feols(ln_beneficiaries ~ post:i(bh) | state_bh_id + time_q^bh,
                   data = panel_ddd, cluster = ~state)

cat("\n=== Triple-Diff: ln(Providers) ===\n")
summary(ddd_prov)

saveRDS(list(ddd_prov = ddd_prov, ddd_benef = ddd_benef),
        file.path(DATA, "ddd_results.rds"))

## --------------------------------------------------------------------------
## 5. Results Summary
## --------------------------------------------------------------------------

results <- data.table(
  Outcome = rep(c("ln(Providers)", "ln(Beneficiaries)", "ln(Claims)", "ln(Paid)"), 2),
  Estimator = rep(c("TWFE", "CS ATT"), each = 4),
  Coef = c(coef(twfe_prov)["post"], coef(twfe_benef)["post"],
           coef(twfe_claim)["post"], coef(twfe_paid)["post"],
           att_prov$overall.att, att_benef$overall.att,
           att_claim$overall.att, att_paid$overall.att),
  SE = c(se(twfe_prov)["post"], se(twfe_benef)["post"],
         se(twfe_claim)["post"], se(twfe_paid)["post"],
         att_prov$overall.se, att_benef$overall.se,
         att_claim$overall.se, att_paid$overall.se)
)
results[, pval := 2 * pnorm(-abs(Coef / SE))]
results[, pct := sprintf("%.1f%%", (exp(Coef) - 1) * 100)]

cat("\n=== Results Summary ===\n")
print(results)

saveRDS(results, file.path(DATA, "results_summary.rds"))
cat("\n=== Main analysis complete ===\n")
