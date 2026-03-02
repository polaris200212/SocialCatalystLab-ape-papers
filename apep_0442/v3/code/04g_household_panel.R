## ============================================================================
## 04g_household_panel.R — Household effects and geographic mobility
## Project: The First Retirement Age v3
## Note: Costa UA Data 101 does not include household members directly.
## We use homeownership and property as proxy household outcomes.
## ============================================================================

source("code/00_packages.R")

cat("=== HOUSEHOLD EFFECTS ===\n\n")

cross <- readRDS(file.path(data_dir, "cross_section_sample.rds"))
cross[, age_1907 := 1907 - birth_year]
cross[, running := age_1907 - 62]

## =========================================================================
## 1. HOMEOWNERSHIP
## =========================================================================
cat("--- 1. HOMEOWNERSHIP ---\n")
valid <- !is.na(cross$homeowner)
if (sum(valid) > 200) {
  fit_home <- rdrobust(cross$homeowner[valid], cross$running[valid], c = 0)
  cat(sprintf("  Homeownership RDD: coef=%.4f, se=%.4f, p=%.3f\n",
              fit_home$coef[1], fit_home$se[3], fit_home$pv[3]))
}

## =========================================================================
## 2. PROPERTY VALUE (from socioeconomic data)
## =========================================================================
cat("\n--- 2. PROPERTY/ASSETS ---\n")
## Check property variables
socio <- readRDS(file.path(data_dir, "full_merged.rds"))
prop_vars <- grep("^recprp_|^str_recprp_", names(socio), value = TRUE)
cat("Property variables available:", paste(prop_vars, collapse = ", "), "\n")

## =========================================================================
## 3. DEATH-PLACE vs BIRTH-PLACE (geographic mobility proxy)
## =========================================================================
cat("\n--- 3. GEOGRAPHIC MOBILITY ---\n")
## gen_birthplace_icpsr vs gen_deathplace_icpsr
full <- readRDS(file.path(data_dir, "full_merged.rds"))
full[, age_1907 := 1907 - birth_year]
full[, running := age_1907 - 62]
full[, moved := as.integer(!is.na(gen_birthplace_icpsr1) & !is.na(gen_deathplace_icpsr) &
                           gen_birthplace_icpsr1 != gen_deathplace_icpsr)]

alive <- full[alive_1910 == TRUE & !is.na(running)]
valid_move <- !is.na(alive$moved) & alive$moved >= 0
if (sum(valid_move) > 200) {
  fit_move <- tryCatch(
    rdrobust(alive$moved[valid_move], alive$running[valid_move], c = 0),
    error = function(e) NULL)
  if (!is.null(fit_move))
    cat(sprintf("  Geographic mobility RDD: coef=%.4f, se=%.4f, p=%.3f\n",
                fit_move$coef[1], fit_move$se[3], fit_move$pv[3]))
}

## =========================================================================
## SAVE
## =========================================================================
hh_results <- list(
  homeownership = if(exists("fit_home")) fit_home else NULL,
  mobility = if(exists("fit_move")) fit_move else NULL
)
saveRDS(hh_results, file.path(data_dir, "household_results.rds"))
cat("\n=== HOUSEHOLD EFFECTS COMPLETE ===\n")
