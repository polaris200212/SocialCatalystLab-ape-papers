## 04b_reviewer_checks.R — Additional analyses requested by referees
## apep_0459: Skills-Based Hiring Laws and Public Sector De-Credentialization

source("00_packages.R")

data_dir <- "../data/"
analysis <- fread(paste0(data_dir, "analysis_panel.csv"))
load(paste0(data_dir, "main_results.RData"))
load(paste0(data_dir, "robustness_results.RData"))

cat("=== Referee-Requested Additional Analyses ===\n")

## ============================================================================
## CHECK R1: DDD Event Study / Pre-Trend Test
## (GPT §1.3, Grok §6.1, Gemini §6.1)
## ============================================================================

cat("\n--- DDD Event Study ---\n")

## Build DDD panel: stack state gov and private sector
ddd_panel <- rbind(
  analysis[, .(state_fips, year, first_treat, share_no_ba, n_state_gov,
               is_state_gov = 1L)],
  analysis[, .(state_fips, year, first_treat,
               share_no_ba = share_no_ba_private,
               n_state_gov, is_state_gov = 0L)]
)

## Create event time for treated states
ddd_panel[, event_time := fifelse(first_treat > 0, year - first_treat, NA_integer_)]

## Create interaction: event_time × is_state_gov (the DDD event study)
## Only for treated states
ddd_panel[, treated_state := as.integer(first_treat > 0)]

## DDD event study with fixest sunab-style
tryCatch({
  ddd_es <- feols(share_no_ba ~ sunab(first_treat, year) * is_state_gov |
                    state_fips^is_state_gov + year^is_state_gov,
                  data = ddd_panel[first_treat > 0 | is_state_gov == 1 | TRUE],
                  weights = ~n_state_gov,
                  cluster = ~state_fips)
  cat("DDD event study (sunab × sector):\n")
  print(summary(ddd_es))
}, error = function(e) {
  cat("DDD sunab error:", conditionMessage(e), "\n")
  cat("Falling back to manual event study...\n")
})

## Manual DDD event study
ddd_panel[, rel_year := fifelse(first_treat > 0, year - first_treat, NA_integer_)]

## Create event-time dummies (e = -5 to 1, omit -1)
for (e in c(-5:-2, 0:1)) {
  vname <- paste0("e", ifelse(e < 0, "m", "p"), abs(e))
  ddd_panel[, (vname) := as.integer(!is.na(rel_year) & rel_year == e)]
}

## DDD event study: interact event-time dummies with is_state_gov
ddd_es_manual <- feols(
  share_no_ba ~ (em5 + em4 + em3 + em2 + ep0 + ep1) * is_state_gov |
    state_fips + year + state_fips:is_state_gov + year:is_state_gov,
  data = ddd_panel,
  weights = ~n_state_gov,
  cluster = ~state_fips
)
cat("Manual DDD event study:\n")
print(summary(ddd_es_manual))

## Extract DDD-specific coefficients (the interaction terms)
ddd_coefs <- coef(ddd_es_manual)
ddd_se <- sqrt(diag(vcov(ddd_es_manual)))
ddd_interact <- grep(":is_state_gov$", names(ddd_coefs))
cat("\nDDD interaction coefficients (event-time × state_gov):\n")
for (i in ddd_interact) {
  cat(sprintf("  %s: %.4f (%.4f)\n", names(ddd_coefs)[i], ddd_coefs[i], ddd_se[i]))
}

## Pre-trend joint test on DDD interactions
pre_interact <- grep("^em[0-9]+:is_state_gov$", names(ddd_coefs))
if (length(pre_interact) >= 2) {
  pre_c <- ddd_coefs[pre_interact]
  pre_s <- ddd_se[pre_interact]
  wald <- sum((pre_c / pre_s)^2)
  wald_p <- 1 - pchisq(wald, df = length(pre_c))
  cat(sprintf("\nDDD pre-trend joint test: chi2(%d) = %.2f, p = %.4f\n",
              length(pre_c), wald, wald_p))
}

## Save DDD event study results for figure
ddd_es_results <- data.table(
  event_time = c(-5:-2, 0:1),
  coef_main = ddd_coefs[grep("^e[mp][0-9]+$", names(ddd_coefs))],
  se_main = ddd_se[grep("^e[mp][0-9]+$", names(ddd_coefs))],
  coef_ddd = ddd_coefs[ddd_interact],
  se_ddd = ddd_se[ddd_interact]
)
fwrite(ddd_es_results, paste0(data_dir, "ddd_event_study.csv"))

## ============================================================================
## CHECK R2: Wild Cluster Bootstrap for Main Estimates
## (GPT §2.1, Grok §2)
## ============================================================================

cat("\n--- Wild Cluster Bootstrap ---\n")

tryCatch({
  library(fwildclusterboot)

  ## TWFE bootstrap
  cat("TWFE wild cluster bootstrap:\n")
  boot_twfe <- boottest(twfe, param = "treated", B = 999,
                        clustid = "state_fips", type = "webb")
  cat(sprintf("  WCB p-value: %.4f\n", pvalue(boot_twfe)))
  cat(sprintf("  WCB 95%% CI: [%.4f, %.4f]\n",
              boot_twfe$conf_int[1], boot_twfe$conf_int[2]))

  ## DDD bootstrap
  cat("DDD wild cluster bootstrap:\n")
  boot_ddd <- boottest(ddd_reg, param = "treated:is_state_gov", B = 999,
                       clustid = "state_fips", type = "webb")
  cat(sprintf("  WCB p-value: %.4f\n", pvalue(boot_ddd)))
  cat(sprintf("  WCB 95%% CI: [%.4f, %.4f]\n",
              boot_ddd$conf_int[1], boot_ddd$conf_int[2]))

  wcb_twfe_p <- pvalue(boot_twfe)
  wcb_ddd_p <- pvalue(boot_ddd)
}, error = function(e) {
  cat("WCB error:", conditionMessage(e), "\n")
  cat("Falling back to standard inference.\n")
  wcb_twfe_p <- NA
  wcb_ddd_p <- NA
})

## ============================================================================
## CHECK R3: TWFE with State-Specific Linear Trends
## (GPT §3.1)
## ============================================================================

cat("\n--- State-Specific Linear Trends ---\n")

analysis[, state_trend := state_fips * year]
twfe_trends <- feols(share_no_ba ~ treated | state_fips + year + state_fips[year],
                     data = analysis,
                     weights = ~n_state_gov,
                     cluster = ~state_fips)
cat("TWFE with state-specific linear trends:\n")
print(summary(twfe_trends))

## ============================================================================
## CHECK R4: Leave-One-Out Analysis
## (Internal review)
## ============================================================================

cat("\n--- Leave-One-Out ---\n")

treated_states <- analysis[first_treat > 0, unique(state_fips)]
loo_results <- data.table(
  dropped_state = integer(),
  coef = numeric(),
  se = numeric()
)

for (st in treated_states) {
  loo_fit <- feols(share_no_ba ~ treated | state_fips + year,
                   data = analysis[state_fips != st],
                   weights = ~n_state_gov,
                   cluster = ~state_fips)
  loo_results <- rbind(loo_results, data.table(
    dropped_state = st,
    coef = coef(loo_fit)["treated"],
    se = sqrt(vcov(loo_fit)["treated", "treated"])
  ))
}

cat(sprintf("Leave-one-out range: [%.4f, %.4f]\n",
            min(loo_results$coef), max(loo_results$coef)))
cat(sprintf("Mean: %.4f, SD: %.4f\n",
            mean(loo_results$coef), sd(loo_results$coef)))
fwrite(loo_results, paste0(data_dir, "loo_results.csv"))

## ============================================================================
## CHECK R5: Cohort-Specific ATTs from CS
## (Gemini §6.1)
## ============================================================================

cat("\n--- Cohort-Specific ATTs ---\n")

tryCatch({
  ## Get group-time ATTs
  gt_results <- att_gt
  groups <- unique(gt_results$group)
  for (g in groups[groups > 0]) {
    g_atts <- gt_results$att[gt_results$group == g & gt_results$t >= g]
    g_ses <- gt_results$se[gt_results$group == g & gt_results$t >= g]
    if (length(g_atts) > 0) {
      avg_att <- mean(g_atts)
      avg_se <- sqrt(mean(g_ses^2) / length(g_ses))
      cat(sprintf("  Cohort %d: ATT = %.4f (SE = %.4f), N post-periods = %d\n",
                  g, avg_att, avg_se, length(g_atts)))
    }
  }
}, error = function(e) {
  cat("Cohort ATT error:", conditionMessage(e), "\n")
})

## ============================================================================
## SAVE ALL REVIEWER-REQUESTED RESULTS
## ============================================================================

save(ddd_es_manual, twfe_trends, loo_results,
     file = paste0(data_dir, "reviewer_results.RData"))

cat("\n=== Referee-requested checks complete ===\n")
