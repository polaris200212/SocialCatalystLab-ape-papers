## ============================================================================
## 03_main_analysis.R — Callaway & Sant'Anna DiD estimation
## apep_0491: Do Red Flag Laws Reduce Violent Crime?
## ============================================================================

source("00_packages.R")
DATA <- "../data"
panel <- readRDS(file.path(DATA, "analysis_panel_clean.rds"))

## ============================================================================
## 1. CALLAWAY & SANT'ANNA: MURDER RATE
## ============================================================================

cat("=== CS-DiD: Murder Rate ===\n")

## Main specification: never-treated as control
cs_murder <- att_gt(
  yname  = "murder_rate",
  tname  = "year",
  idname = "state_id",
  gname  = "g",
  data   = as.data.frame(panel),
  control_group = "nevertreated",
  anticipation  = 0,
  base_period   = "universal",
  est_method    = "dr",  # doubly-robust
  bstrap        = TRUE,
  cband         = TRUE,
  biters        = 1000,
  clustervars   = "state_id"
)

## Aggregate to overall ATT
agg_murder <- aggte(cs_murder, type = "simple")
cat(sprintf("Overall ATT (murder rate): %.3f (SE: %.3f, p: %.4f)\n",
            agg_murder$overall.att, agg_murder$overall.se,
            2 * pnorm(-abs(agg_murder$overall.att / agg_murder$overall.se))))

## Dynamic event study
es_murder <- aggte(cs_murder, type = "dynamic",
                   min_e = -10, max_e = 8)

## Group-specific ATTs
group_murder <- aggte(cs_murder, type = "group")

## ============================================================================
## 2. CS-DiD: AGGRAVATED ASSAULT RATE
## ============================================================================

cat("\n=== CS-DiD: Aggravated Assault Rate ===\n")

cs_assault <- att_gt(
  yname  = "assault_agg_rate",
  tname  = "year",
  idname = "state_id",
  gname  = "g",
  data   = as.data.frame(panel),
  control_group = "nevertreated",
  anticipation  = 0,
  base_period   = "universal",
  est_method    = "dr",
  bstrap        = TRUE,
  cband         = TRUE,
  biters        = 1000,
  clustervars   = "state_id"
)

agg_assault <- aggte(cs_assault, type = "simple")
cat(sprintf("Overall ATT (assault rate): %.3f (SE: %.3f, p: %.4f)\n",
            agg_assault$overall.att, agg_assault$overall.se,
            2 * pnorm(-abs(agg_assault$overall.att / agg_assault$overall.se))))

es_assault <- aggte(cs_assault, type = "dynamic",
                    min_e = -10, max_e = 8)

## ============================================================================
## 3. CS-DiD: ROBBERY RATE
## ============================================================================

cat("\n=== CS-DiD: Robbery Rate ===\n")

cs_robbery <- att_gt(
  yname  = "robbery_rate",
  tname  = "year",
  idname = "state_id",
  gname  = "g",
  data   = as.data.frame(panel),
  control_group = "nevertreated",
  anticipation  = 0,
  base_period   = "universal",
  est_method    = "dr",
  bstrap        = TRUE,
  cband         = TRUE,
  biters        = 1000,
  clustervars   = "state_id"
)

agg_robbery <- aggte(cs_robbery, type = "simple")
cat(sprintf("Overall ATT (robbery rate): %.3f (SE: %.3f, p: %.4f)\n",
            agg_robbery$overall.att, agg_robbery$overall.se,
            2 * pnorm(-abs(agg_robbery$overall.att / agg_robbery$overall.se))))

es_robbery <- aggte(cs_robbery, type = "dynamic",
                    min_e = -10, max_e = 8)

## ============================================================================
## 4. CS-DiD: TOTAL VIOLENT CRIME RATE
## ============================================================================

cat("\n=== CS-DiD: Total Violent Crime Rate ===\n")

cs_violent <- att_gt(
  yname  = "violent_rate",
  tname  = "year",
  idname = "state_id",
  gname  = "g",
  data   = as.data.frame(panel),
  control_group = "nevertreated",
  anticipation  = 0,
  base_period   = "universal",
  est_method    = "dr",
  bstrap        = TRUE,
  cband         = TRUE,
  biters        = 1000,
  clustervars   = "state_id"
)

agg_violent <- aggte(cs_violent, type = "simple")
cat(sprintf("Overall ATT (violent rate): %.3f (SE: %.3f, p: %.4f)\n",
            agg_violent$overall.att, agg_violent$overall.se,
            2 * pnorm(-abs(agg_violent$overall.att / agg_violent$overall.se))))

es_violent <- aggte(cs_violent, type = "dynamic",
                    min_e = -10, max_e = 8)

## ============================================================================
## 5. PLACEBO: PROPERTY CRIME RATE
## ============================================================================

cat("\n=== Placebo: Property Crime Rate ===\n")

cs_property <- att_gt(
  yname  = "property_rate",
  tname  = "year",
  idname = "state_id",
  gname  = "g",
  data   = as.data.frame(panel),
  control_group = "nevertreated",
  anticipation  = 0,
  base_period   = "universal",
  est_method    = "dr",
  bstrap        = TRUE,
  cband         = TRUE,
  biters        = 1000,
  clustervars   = "state_id"
)

agg_property <- aggte(cs_property, type = "simple")
cat(sprintf("Placebo ATT (property rate): %.3f (SE: %.3f, p: %.4f)\n",
            agg_property$overall.att, agg_property$overall.se,
            2 * pnorm(-abs(agg_property$overall.att / agg_property$overall.se))))

es_property <- aggte(cs_property, type = "dynamic",
                     min_e = -10, max_e = 8)

## ============================================================================
## 6. TWFE (for comparison with existing literature)
## ============================================================================

cat("\n=== TWFE Comparison (biased under heterogeneity) ===\n")

twfe_murder <- feols(murder_rate ~ post | state_id + year,
                     data = panel, cluster = ~state_id)
twfe_assault <- feols(assault_agg_rate ~ post | state_id + year,
                      data = panel, cluster = ~state_id)
twfe_violent <- feols(violent_rate ~ post | state_id + year,
                      data = panel, cluster = ~state_id)
twfe_property <- feols(property_rate ~ post | state_id + year,
                       data = panel, cluster = ~state_id)

cat("TWFE Murder:   "); print(summary(twfe_murder)$coeftable)
cat("TWFE Assault:  "); print(summary(twfe_assault)$coeftable)
cat("TWFE Violent:  "); print(summary(twfe_violent)$coeftable)
cat("TWFE Property: "); print(summary(twfe_property)$coeftable)

## ============================================================================
## 7. HETEROGENEITY BY PETITIONER TYPE
## ============================================================================

cat("\n=== Heterogeneity: Family petitioner vs LE-only ===\n")

## Family petitioner states
family_states <- panel[petitioner_type == "family" | treated == FALSE]
family_states[, g_family := fifelse(petitioner_type == "family" & !is.na(petitioner_type),
                                     erpo_year, 0L)]

cs_murder_family <- att_gt(
  yname  = "murder_rate",
  tname  = "year",
  idname = "state_id",
  gname  = "g_family",
  data   = as.data.frame(family_states),
  control_group = "nevertreated",
  anticipation  = 0,
  base_period   = "universal",
  est_method    = "dr",
  bstrap        = TRUE,
  biters        = 1000,
  clustervars   = "state_id"
)

agg_family <- aggte(cs_murder_family, type = "simple")
cat(sprintf("Family-petition ATT (murder): %.3f (SE: %.3f)\n",
            agg_family$overall.att, agg_family$overall.se))

## LE-only states (CT, IN, FL)
le_states <- panel[petitioner_type == "le" | treated == FALSE]
le_states[, g_le := fifelse(petitioner_type == "le" & !is.na(petitioner_type),
                             erpo_year, 0L)]

cs_murder_le <- att_gt(
  yname  = "murder_rate",
  tname  = "year",
  idname = "state_id",
  gname  = "g_le",
  data   = as.data.frame(le_states),
  control_group = "nevertreated",
  anticipation  = 0,
  base_period   = "universal",
  est_method    = "dr",
  bstrap        = TRUE,
  biters        = 1000,
  clustervars   = "state_id"
)

agg_le <- aggte(cs_murder_le, type = "simple")
cat(sprintf("LE-only ATT (murder): %.3f (SE: %.3f)\n",
            agg_le$overall.att, agg_le$overall.se))

## ============================================================================
## 8. SAVE ALL RESULTS
## ============================================================================

results <- list(
  cs_murder   = cs_murder,
  cs_assault  = cs_assault,
  cs_robbery  = cs_robbery,
  cs_violent  = cs_violent,
  cs_property = cs_property,
  agg_murder  = agg_murder,
  agg_assault = agg_assault,
  agg_robbery = agg_robbery,
  agg_violent = agg_violent,
  agg_property = agg_property,
  es_murder   = es_murder,
  es_assault  = es_assault,
  es_robbery  = es_robbery,
  es_violent  = es_violent,
  es_property = es_property,
  group_murder = group_murder,
  twfe_murder  = twfe_murder,
  twfe_assault = twfe_assault,
  twfe_violent = twfe_violent,
  twfe_property = twfe_property,
  agg_family   = agg_family,
  agg_le       = agg_le,
  cs_murder_family = cs_murder_family,
  cs_murder_le     = cs_murder_le
)

saveRDS(results, file.path(DATA, "main_results.rds"))
cat("\nAll main results saved.\n")
