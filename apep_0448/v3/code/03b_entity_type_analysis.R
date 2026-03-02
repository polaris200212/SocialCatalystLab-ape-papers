## ============================================================================
## 03b_entity_type_analysis.R — CS-DiD by entity type
## apep_0448: Early UI Termination and Medicaid HCBS Provider Supply
## ============================================================================

source("00_packages.R")
library(did)

DATA <- "../data"

type1 <- readRDS(file.path(DATA, "hcbs_type1.rds"))
type2 <- readRDS(file.path(DATA, "hcbs_type2.rds"))

cat("=== Entity Type Analysis ===\n")

## ---- 1. CS-DiD for Type 1 (Individual NPIs) ----
cat("\n--- Type 1 (Individual) CS-DiD ---\n")

# Ensure g_period is numeric (did package requirement)
type1[, g_period := as.numeric(g_period)]
type2[, g_period := as.numeric(g_period)]

cs_type1 <- tryCatch({
  att_gt(
    yname = "ln_providers",
    tname = "period",
    idname = "state_id",
    gname = "g_period",
    data = as.data.frame(type1),
    control_group = "nevertreated",
    est_method = "dr",
    base_period = "universal",
    bstrap = TRUE,
    biters = 1000,
    cband = TRUE
  )
}, error = function(e) {
  cat("  CS-DiD Type 1 failed:", conditionMessage(e), "\n")
  NULL
})

cs_type1_agg <- NULL
cs_type1_es <- NULL
if (!is.null(cs_type1)) {
  cs_type1_agg <- aggte(cs_type1, type = "simple")
  cs_type1_es <- aggte(cs_type1, type = "dynamic")
  cat(sprintf("  Type 1 ATT: %.4f (SE: %.4f, p: %.4f)\n",
              cs_type1_agg$overall.att, cs_type1_agg$overall.se,
              2 * pnorm(-abs(cs_type1_agg$overall.att / cs_type1_agg$overall.se))))
}

## ---- 2. CS-DiD for Type 2 (Organization NPIs) ----
cat("\n--- Type 2 (Organization) CS-DiD ---\n")

cs_type2 <- tryCatch({
  att_gt(
    yname = "ln_providers",
    tname = "period",
    idname = "state_id",
    gname = "g_period",
    data = as.data.frame(type2),
    control_group = "nevertreated",
    est_method = "dr",
    base_period = "universal",
    bstrap = TRUE,
    biters = 1000,
    cband = TRUE
  )
}, error = function(e) {
  cat("  CS-DiD Type 2 failed:", conditionMessage(e), "\n")
  NULL
})

cs_type2_agg <- NULL
cs_type2_es <- NULL
if (!is.null(cs_type2)) {
  cs_type2_agg <- aggte(cs_type2, type = "simple")
  cs_type2_es <- aggte(cs_type2, type = "dynamic")
  cat(sprintf("  Type 2 ATT: %.4f (SE: %.4f, p: %.4f)\n",
              cs_type2_agg$overall.att, cs_type2_agg$overall.se,
              2 * pnorm(-abs(cs_type2_agg$overall.att / cs_type2_agg$overall.se))))
}

## ---- 3. TWFE comparison for both types ----
cat("\n--- TWFE by Entity Type ---\n")

twfe_type1 <- fixest::feols(ln_providers ~ treated | state_id + period,
                             data = type1, cluster = ~state_id)
twfe_type2 <- fixest::feols(ln_providers ~ treated | state_id + period,
                             data = type2, cluster = ~state_id)

cat(sprintf("  TWFE Type 1: %.4f (SE: %.4f)\n",
            coef(twfe_type1), fixest::se(twfe_type1)))
cat(sprintf("  TWFE Type 2: %.4f (SE: %.4f)\n",
            coef(twfe_type2), fixest::se(twfe_type2)))

## ---- 4. Summary comparison ----
cat("\n=== Entity Type Decomposition Summary ===\n")
if (!is.null(cs_type1_agg) && !is.null(cs_type2_agg)) {
  cat(sprintf("  Type 1 (Individual):   ATT = %.4f (SE = %.4f)\n",
              cs_type1_agg$overall.att, cs_type1_agg$overall.se))
  cat(sprintf("  Type 2 (Organization): ATT = %.4f (SE = %.4f)\n",
              cs_type2_agg$overall.att, cs_type2_agg$overall.se))

  # Pre-treatment provider counts for context
  pre_t1 <- type1[month_date < as.Date("2021-06-01"), .(mean_prov = mean(n_providers)), by = early_terminator]
  pre_t2 <- type2[month_date < as.Date("2021-06-01"), .(mean_prov = mean(n_providers)), by = early_terminator]
  cat(sprintf("\n  Pre-treatment mean providers (treated states):\n"))
  cat(sprintf("    Type 1: %.0f per state-month\n", pre_t1[early_terminator == TRUE, mean_prov]))
  cat(sprintf("    Type 2: %.0f per state-month\n", pre_t2[early_terminator == TRUE, mean_prov]))
}

## ---- 5. Save results ----
entity_results <- list(
  cs_type1 = cs_type1,
  cs_type1_agg = cs_type1_agg,
  cs_type1_es = cs_type1_es,
  cs_type2 = cs_type2,
  cs_type2_agg = cs_type2_agg,
  cs_type2_es = cs_type2_es,
  twfe_type1 = twfe_type1,
  twfe_type2 = twfe_type2
)

saveRDS(entity_results, file.path(DATA, "entity_type_results.rds"))
cat("\n=== Entity type analysis complete ===\n")
