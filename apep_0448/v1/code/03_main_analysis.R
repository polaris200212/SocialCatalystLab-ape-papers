## ============================================================================
## 03_main_analysis.R — Primary regressions
## apep_0448: Early UI Termination and Medicaid HCBS Provider Supply
## ============================================================================

source("00_packages.R")

DATA <- "../data"
hcbs <- readRDS(file.path(DATA, "hcbs_analysis.rds"))
bh <- readRDS(file.path(DATA, "bh_analysis.rds"))
month_map <- readRDS(file.path(DATA, "month_to_period.rds"))

cat("HCBS analysis data loaded:", nrow(hcbs), "rows\n")

# Ensure g_period is numeric for did package (it uses Inf internally for never-treated)
hcbs[, g_period := as.numeric(g_period)]
bh[, g_period := as.numeric(g_period)]

## ---- 1. TWFE Baseline (for comparison) ----
cat("\n=== TWFE Baseline Regressions ===\n")

twfe_providers <- feols(ln_providers ~ treated | state + period, data = hcbs, cluster = ~state)
twfe_claims <- feols(ln_claims ~ treated | state + period, data = hcbs, cluster = ~state)
twfe_paid <- feols(ln_paid ~ treated | state + period, data = hcbs, cluster = ~state)
twfe_benes <- feols(ln_benes ~ treated | state + period, data = hcbs, cluster = ~state)

cat("\nTWFE Results (HCBS):\n")
get_pval <- function(fit) coeftable(fit)[, "Pr(>|t|)"]
cat(sprintf("  Providers: β = %.4f (SE = %.4f), p = %.3f\n",
            coef(twfe_providers), se(twfe_providers), get_pval(twfe_providers)))
cat(sprintf("  Claims:    β = %.4f (SE = %.4f), p = %.3f\n",
            coef(twfe_claims), se(twfe_claims), get_pval(twfe_claims)))
cat(sprintf("  Paid:      β = %.4f (SE = %.4f), p = %.3f\n",
            coef(twfe_paid), se(twfe_paid), get_pval(twfe_paid)))
cat(sprintf("  Benes:     β = %.4f (SE = %.4f), p = %.3f\n",
            coef(twfe_benes), se(twfe_benes), get_pval(twfe_benes)))

## ---- 2. Callaway-Sant'Anna (primary specification) ----
cat("\n=== Callaway-Sant'Anna DiD ===\n")

# CS-DiD for log providers
cs_providers <- att_gt(
  yname = "ln_providers",
  tname = "period",
  idname = "state_id",
  gname = "g_period",
  data = as.data.frame(hcbs),
  control_group = "nevertreated",
  est_method = "dr",
  base_period = "universal",
  bstrap = TRUE,
  cband = TRUE,
  biters = 1000
)

cat("\nCS-DiD ATT(g,t) for log providers:\n")
print(summary(cs_providers))

# Aggregate: simple ATT
cs_agg_providers <- aggte(cs_providers, type = "simple")
cat(sprintf("\nCS Simple ATT (providers): %.4f (SE = %.4f)\n",
            cs_agg_providers$overall.att, cs_agg_providers$overall.se))

# CS-DiD for log claims
cs_claims <- att_gt(
  yname = "ln_claims",
  tname = "period",
  idname = "state_id",
  gname = "g_period",
  data = as.data.frame(hcbs),
  control_group = "nevertreated",
  est_method = "dr",
  base_period = "universal",
  bstrap = TRUE,
  cband = TRUE,
  biters = 1000
)
cs_agg_claims <- aggte(cs_claims, type = "simple")

# CS-DiD for log paid
cs_paid <- att_gt(
  yname = "ln_paid",
  tname = "period",
  idname = "state_id",
  gname = "g_period",
  data = as.data.frame(hcbs),
  control_group = "nevertreated",
  est_method = "dr",
  base_period = "universal",
  bstrap = TRUE,
  cband = TRUE,
  biters = 1000
)
cs_agg_paid <- aggte(cs_paid, type = "simple")

# CS-DiD for log beneficiaries
cs_benes <- att_gt(
  yname = "ln_benes",
  tname = "period",
  idname = "state_id",
  gname = "g_period",
  data = as.data.frame(hcbs),
  control_group = "nevertreated",
  est_method = "dr",
  base_period = "universal",
  bstrap = TRUE,
  cband = TRUE,
  biters = 1000
)
cs_agg_benes <- aggte(cs_benes, type = "simple")

cat("\n=== CS-DiD Summary (HCBS) ===\n")
cat(sprintf("  Providers: ATT = %.4f (SE = %.4f)\n", cs_agg_providers$overall.att, cs_agg_providers$overall.se))
cat(sprintf("  Claims:    ATT = %.4f (SE = %.4f)\n", cs_agg_claims$overall.att, cs_agg_claims$overall.se))
cat(sprintf("  Paid:      ATT = %.4f (SE = %.4f)\n", cs_agg_paid$overall.att, cs_agg_paid$overall.se))
cat(sprintf("  Benes:     ATT = %.4f (SE = %.4f)\n", cs_agg_benes$overall.att, cs_agg_benes$overall.se))

## ---- 3. Event study aggregation ----
cat("\n=== Event Study (Dynamic ATT) ===\n")

es_providers <- aggte(cs_providers, type = "dynamic", min_e = -24, max_e = 24)
es_claims <- aggte(cs_claims, type = "dynamic", min_e = -24, max_e = 24)
es_paid <- aggte(cs_paid, type = "dynamic", min_e = -24, max_e = 24)
es_benes <- aggte(cs_benes, type = "dynamic", min_e = -24, max_e = 24)

cat("Event study computed (24 pre/post periods)\n")

## ---- 4. Placebo: Behavioral Health ----
cat("\n=== Placebo: Behavioral Health (H-codes) ===\n")

cs_bh_providers <- att_gt(
  yname = "ln_providers",
  tname = "period",
  idname = "state_id",
  gname = "g_period",
  data = as.data.frame(bh),
  control_group = "nevertreated",
  est_method = "dr",
  base_period = "universal",
  bstrap = TRUE,
  cband = TRUE,
  biters = 1000
)
cs_agg_bh <- aggte(cs_bh_providers, type = "simple")
es_bh_providers <- aggte(cs_bh_providers, type = "dynamic", min_e = -24, max_e = 24)

cat(sprintf("BH Placebo ATT (providers): %.4f (SE = %.4f)\n",
            cs_agg_bh$overall.att, cs_agg_bh$overall.se))

## ---- 5. Intensive margin ----
cat("\n=== Intensive Margin (claims per provider) ===\n")

twfe_intensive <- feols(log(claims_per_provider + 1) ~ treated | state + period,
                        data = hcbs, cluster = ~state)
cat(sprintf("TWFE claims/provider: β = %.4f (SE = %.4f)\n",
            coef(twfe_intensive), se(twfe_intensive)))

## ---- 6. TWFE Event Study (Sun & Abraham style) ----
cat("\n=== TWFE Event Study ===\n")

# Create event-time dummies
hcbs[, event_time := period - g_period]
hcbs[g_period == 0, event_time := NA_integer_]

# Bin endpoints
hcbs[, event_time_binned := event_time]
hcbs[event_time < -24, event_time_binned := -24L]
hcbs[event_time > 24, event_time_binned := 24L]

# TWFE event study (exclude t = -1 as reference)
twfe_es <- feols(ln_providers ~ i(event_time_binned, ref = -1) | state + period,
                 data = hcbs[!is.na(event_time_binned)],
                 cluster = ~state)

cat("TWFE event study estimated\n")

## ---- 7. Save all results ----
results <- list(
  twfe = list(
    providers = twfe_providers,
    claims = twfe_claims,
    paid = twfe_paid,
    benes = twfe_benes,
    intensive = twfe_intensive,
    event_study = twfe_es
  ),
  cs = list(
    providers = cs_providers,
    claims = cs_claims,
    paid = cs_paid,
    benes = cs_benes,
    bh_placebo = cs_bh_providers
  ),
  cs_agg = list(
    providers = cs_agg_providers,
    claims = cs_agg_claims,
    paid = cs_agg_paid,
    benes = cs_agg_benes,
    bh_placebo = cs_agg_bh
  ),
  es = list(
    providers = es_providers,
    claims = es_claims,
    paid = es_paid,
    benes = es_benes,
    bh_placebo = es_bh_providers
  )
)

saveRDS(results, file.path(DATA, "main_results.rds"))
cat("\n=== Main analysis complete ===\n")
