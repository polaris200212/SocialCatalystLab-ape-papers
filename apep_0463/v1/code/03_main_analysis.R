## ============================================================
## 03_main_analysis.R — Primary Regressions
## APEP-0463: Cash Scarcity and Food Prices (Nigeria 2023)
## ============================================================

source("00_packages.R")

data_dir <- "../data"
analysis <- readRDS(file.path(data_dir, "analysis.rds"))

cat("Analysis sample: ", nrow(analysis), " observations\n")
cat("States: ", length(unique(analysis$state)), "\n")
cat("Treatment variable range: ",
    range(analysis$cash_scarcity_std, na.rm = TRUE), "\n")

## ---------------------------------------------------------
## 1. Summary Statistics
## ---------------------------------------------------------
cat("\n=== Summary Statistics ===\n")

summ_stats <- analysis[, .(
  mean_log_price = mean(log_food_price_idx, na.rm = TRUE),
  sd_log_price = sd(log_food_price_idx, na.rm = TRUE),
  mean_price_level = mean(mean_price, na.rm = TRUE),
  mean_cash_scarcity = mean(cash_scarcity_std, na.rm = TRUE),
  mean_branches_100k = mean(branches_per_100k, na.rm = TRUE),
  n_obs = .N,
  n_weeks = uniqueN(week)
), by = state]

print(summ_stats[order(-mean_cash_scarcity)])

## Overall summary
cat("\nOverall:\n")
cat(sprintf("  N observations: %s\n", nrow(analysis)))
cat(sprintf("  N states: %s\n", length(unique(analysis$state))))
cat(sprintf("  N weeks: %s\n", length(unique(analysis$week))))
cat(sprintf("  Mean log food price: %.3f (SD: %.3f)\n",
            mean(analysis$log_food_price_idx, na.rm = TRUE),
            sd(analysis$log_food_price_idx, na.rm = TRUE)))

## Save summary stats for tables
saveRDS(summ_stats, file.path(data_dir, "summ_stats.rds"))

## ---------------------------------------------------------
## 2. Primary Specification: Continuous DiD
## ---------------------------------------------------------
## log(FoodPrice_it) = α_i + γ_t + β(CashScarcity_i × Post_t) + ε_it
##
## CashScarcity_i = standardized inverse banking density (0-1)
## Post_t = indicator for crisis period (Feb-Mar 2023)

cat("\n=== Primary Specification: Continuous DiD ===\n")

## Model 1: Basic continuous DiD with state + week FE
m1 <- feols(
  log_food_price_idx ~ cash_scarcity_std:crisis_acute |
    state + week,
  data = analysis,
  cluster = ~state
)
cat("\nModel 1: Basic continuous DiD (acute crisis)\n")
summary(m1)

## Model 2: Broader crisis window
m2 <- feols(
  log_food_price_idx ~ cash_scarcity_std:post_deadline |
    state + week,
  data = analysis,
  cluster = ~state
)
cat("\nModel 2: Post-deadline window\n")
summary(m2)

## Model 3: With conflict control
m3 <- feols(
  log_food_price_idx ~ cash_scarcity_std:crisis_acute +
    log1p(n_conflict_events) |
    state + week,
  data = analysis,
  cluster = ~state
)
cat("\nModel 3: With conflict control\n")
summary(m3)

## Model 4: Triple interaction with post-announcement
m4 <- feols(
  log_food_price_idx ~ cash_scarcity_std:post_announce +
    cash_scarcity_std:crisis_acute |
    state + week,
  data = analysis,
  cluster = ~state
)
cat("\nModel 4: Announcement + Acute crisis\n")
summary(m4)

## ---------------------------------------------------------
## 3. Event Study
## ---------------------------------------------------------
cat("\n=== Event Study ===\n")

## Restrict to ±52 weeks around deadline
es_data <- analysis[event_week >= -52 & event_week <= 52]
es_data[, event_week_f := factor(event_week)]
## Reference period: -1 (week before deadline)
es_data[, event_week_f := relevel(event_week_f, ref = "-1")]

## Event study specification
m_es <- feols(
  log_food_price_idx ~ i(event_week, cash_scarcity_std, ref = -1) |
    state + week,
  data = es_data,
  cluster = ~state
)
cat("\nEvent study coefficients (selected):\n")
## Show a few key periods
es_coefs <- coef(m_es)
es_se <- se(m_es)
es_names <- names(es_coefs)
for (k in c(-26, -13, -4, -1, 0, 1, 2, 3, 4, 8, 13, 26, 52)) {
  nm <- paste0("event_week::", k, ":cash_scarcity_std")
  if (nm %in% es_names) {
    idx <- which(es_names == nm)
    cat(sprintf("  k=%3d: β=%.4f (SE=%.4f)\n", k, es_coefs[idx], es_se[idx]))
  }
}

## ---------------------------------------------------------
## 4. Wild Cluster Bootstrap (few-clusters inference)
## ---------------------------------------------------------
cat("\n=== Wild Cluster Bootstrap (manual implementation) ===\n")

## Manual wild cluster bootstrap with Rademacher weights
set.seed(20230130)
B <- 9999
clusters <- unique(analysis$state)
G <- length(clusters)

## Get actual t-statistic
actual_t <- coef(m1)["cash_scarcity_std:crisis_acute"] /
  se(m1)["cash_scarcity_std:crisis_acute"]

boot_t <- numeric(B)
boot_coef <- numeric(B)
for (b in 1:B) {
  ## Rademacher weights: +1 or -1 for each cluster
  w <- sample(c(-1, 1), G, replace = TRUE)
  names(w) <- clusters

  ## Create wild bootstrap residuals
  resids <- residuals(m1)
  boot_y <- fitted(m1) + resids * w[analysis$state]

  ## Re-estimate
  boot_data <- copy(analysis)
  boot_data[, boot_dep := boot_y]

  m_boot <- tryCatch({
    feols(boot_dep ~ cash_scarcity_std:crisis_acute | state + week,
          data = boot_data, cluster = ~state)
  }, error = function(e) NULL)

  if (!is.null(m_boot)) {
    boot_t[b] <- coef(m_boot)["cash_scarcity_std:crisis_acute"] /
      se(m_boot)["cash_scarcity_std:crisis_acute"]
    boot_coef[b] <- coef(m_boot)["cash_scarcity_std:crisis_acute"]
  }
}

## Compute bootstrap p-value (two-sided)
boot_pval <- mean(abs(boot_t) >= abs(actual_t), na.rm = TRUE)
cat(sprintf("  Actual t-stat: %.3f\n", actual_t))
cat(sprintf("  WCB p-value (Rademacher, %d reps): %.4f\n", B, boot_pval))

## Bootstrap percentile CI from coefficient distribution
boot_ci <- quantile(boot_coef[boot_coef != 0], c(0.025, 0.975), na.rm = TRUE)

## Store results
boot_m1 <- list(
  p_val = boot_pval,
  actual_t = actual_t,
  boot_t = boot_t,
  boot_coef = boot_coef,
  conf_int = boot_ci
)
cat(sprintf("  95%% CI: [%.4f, %.4f]\n", boot_m1$conf_int[1], boot_m1$conf_int[2]))

## ---------------------------------------------------------
## 5. Save results
## ---------------------------------------------------------
results <- list(
  m1 = m1,
  m2 = m2,
  m3 = m3,
  m4 = m4,
  m_es = m_es,
  boot_m1 = boot_m1
)
saveRDS(results, file.path(data_dir, "main_results.rds"))

cat("\nMain analysis complete.\n")
