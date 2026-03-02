## 04_robustness.R - Robustness checks and sensitivity
## Neighbourhood Planning and House Prices (apep_0228)

source("00_packages.R")

data_dir <- "../data"
panel <- readRDS(file.path(data_dir, "analysis_panel.rds"))
results <- readRDS(file.path(data_dir, "main_results.rds"))

cat("Loaded panel and main results.\n")

## ─────────────────────────────────────────────────────────────
## 1. Alternative outcome: log mean price
## ─────────────────────────────────────────────────────────────

cs_mean <- att_gt(
  yname = "log_mean_price",
  tname = "year",
  idname = "district_id",
  gname = "first_treat",
  data = as.data.frame(panel),
  control_group = "notyettreated",
  anticipation = 0,
  est_method = "dr",
  base_period = "varying"
)
cs_mean_simple <- aggte(cs_mean, type = "simple")
cs_mean_es <- aggte(cs_mean, type = "dynamic", min_e = -5, max_e = 8)

cat("\n=== Robustness: Log Mean Price ===\n")
summary(cs_mean_simple)

## ─────────────────────────────────────────────────────────────
## 2. Alternative outcome: number of transactions (extensive margin)
## ─────────────────────────────────────────────────────────────

panel$log_transactions <- log(panel$n_transactions)

cs_trans <- att_gt(
  yname = "log_transactions",
  tname = "year",
  idname = "district_id",
  gname = "first_treat",
  data = as.data.frame(panel),
  control_group = "notyettreated",
  anticipation = 0,
  est_method = "dr",
  base_period = "varying"
)
cs_trans_simple <- aggte(cs_trans, type = "simple")
cs_trans_es <- aggte(cs_trans, type = "dynamic", min_e = -5, max_e = 8)

cat("\n=== Robustness: Log Transactions ===\n")
summary(cs_trans_simple)

## ─────────────────────────────────────────────────────────────
## 3. Anticipation effects (1-year anticipation)
## ─────────────────────────────────────────────────────────────

cs_antic <- att_gt(
  yname = "log_median_price",
  tname = "year",
  idname = "district_id",
  gname = "first_treat",
  data = as.data.frame(panel),
  control_group = "notyettreated",
  anticipation = 1,
  est_method = "dr",
  base_period = "varying"
)
cs_antic_simple <- aggte(cs_antic, type = "simple")

cat("\n=== Robustness: 1-Year Anticipation ===\n")
summary(cs_antic_simple)

## ─────────────────────────────────────────────────────────────
## 4. Exclude London (outlier housing market)
## ─────────────────────────────────────────────────────────────

london_districts <- c(
  "BARKING AND DAGENHAM", "BARNET", "BEXLEY", "BRENT", "BROMLEY",
  "CAMDEN", "CITY OF LONDON", "CITY OF WESTMINSTER", "CROYDON",
  "EALING", "ENFIELD", "GREENWICH", "HACKNEY", "HAMMERSMITH AND FULHAM",
  "HARINGEY", "HARROW", "HAVERING", "HILLINGDON", "HOUNSLOW",
  "ISLINGTON", "KENSINGTON AND CHELSEA", "KINGSTON UPON THAMES",
  "LAMBETH", "LEWISHAM", "MERTON", "NEWHAM", "REDBRIDGE",
  "RICHMOND UPON THAMES", "SOUTHWARK", "SUTTON", "TOWER HAMLETS",
  "WALTHAM FOREST", "WANDSWORTH"
)

panel_no_london <- panel %>% filter(!(district %in% london_districts))

cs_no_london <- att_gt(
  yname = "log_median_price",
  tname = "year",
  idname = "district_id",
  gname = "first_treat",
  data = as.data.frame(panel_no_london),
  control_group = "notyettreated",
  anticipation = 0,
  est_method = "dr",
  base_period = "varying"
)
cs_no_london_simple <- aggte(cs_no_london, type = "simple")

cat("\n=== Robustness: Excluding London ===\n")
summary(cs_no_london_simple)

## ─────────────────────────────────────────────────────────────
## 5. HonestDiD sensitivity analysis
## ─────────────────────────────────────────────────────────────

cat("\n=== HonestDiD Sensitivity Analysis ===\n")

## Extract event study coefficients from CS
es_result <- results$cs_es

## Get pre-treatment and post-treatment estimates
pre_idx <- which(es_result$egt < 0)
post_idx <- which(es_result$egt >= 0)

if (length(pre_idx) >= 2 && length(post_idx) >= 1) {
  tryCatch({
    ## Construct the objects HonestDiD needs
    betahat <- es_result$att.egt
    sigma <- es_result$V_analytical

    ## Run sensitivity analysis
    honest_result <- HonestDiD::createSensitivityResults(
      betahat = betahat,
      sigma = sigma,
      numPrePeriods = length(pre_idx),
      numPostPeriods = length(post_idx),
      Mvec = seq(0, 0.05, by = 0.01),
      alpha = 0.05
    )

    cat("HonestDiD sensitivity results:\n")
    print(honest_result)

    saveRDS(honest_result, file.path(data_dir, "honest_did_results.rds"))
  }, error = function(e) {
    cat(sprintf("HonestDiD error: %s\n", e$message))
    cat("Proceeding without HonestDiD sensitivity.\n")
  })
} else {
  cat("Insufficient pre/post periods for HonestDiD. Skipping.\n")
}

## ─────────────────────────────────────────────────────────────
## 6. Randomization inference
## ─────────────────────────────────────────────────────────────

cat("\n=== Randomization Inference ===\n")

## Permute treatment assignment 500 times
set.seed(42)
n_perms <- 500
treated_districts <- panel %>%
  filter(first_treat > 0) %>%
  distinct(district_id, first_treat)

twfe_coef <- coef(results$twfe_baseline)["treated"]
perm_coefs <- numeric(n_perms)

for (p in seq_len(n_perms)) {
  if (p %% 100 == 0) cat(sprintf("  Permutation %d/%d\n", p, n_perms))

  ## Randomly reassign treatment timing among all districts
  all_districts <- distinct(panel, district_id)
  n_treated <- nrow(treated_districts)

  perm_districts <- sample(all_districts$district_id, n_treated)
  perm_years <- sample(treated_districts$first_treat, n_treated)

  perm_xwalk <- tibble(
    district_id = perm_districts,
    perm_first_treat = perm_years
  )

  panel_perm <- panel %>%
    select(-first_treat, -treated) %>%
    left_join(perm_xwalk, by = "district_id") %>%
    mutate(
      first_treat = ifelse(is.na(perm_first_treat), 0, perm_first_treat),
      treated = ifelse(first_treat > 0 & year >= first_treat, 1, 0)
    )

  tryCatch({
    perm_fit <- feols(
      log_median_price ~ treated | district + year,
      data = panel_perm,
      cluster = ~district
    )
    perm_coefs[p] <- coef(perm_fit)["treated"]
  }, error = function(e) {
    perm_coefs[p] <- NA
  })
}

perm_coefs <- perm_coefs[!is.na(perm_coefs)]
ri_pvalue <- mean(abs(perm_coefs) >= abs(twfe_coef))

cat(sprintf("\nRandomization inference p-value: %.4f\n", ri_pvalue))
cat(sprintf("  Actual TWFE coefficient: %.6f\n", twfe_coef))
cat(sprintf("  Permutation distribution: mean=%.6f, sd=%.6f\n",
            mean(perm_coefs), sd(perm_coefs)))

## ─────────────────────────────────────────────────────────────
## 7. Save all robustness results
## ─────────────────────────────────────────────────────────────

robustness <- list(
  cs_mean_simple = cs_mean_simple,
  cs_mean_es = cs_mean_es,
  cs_trans_simple = cs_trans_simple,
  cs_trans_es = cs_trans_es,
  cs_antic_simple = cs_antic_simple,
  cs_no_london_simple = cs_no_london_simple,
  ri_pvalue = ri_pvalue,
  ri_distribution = perm_coefs,
  twfe_actual = twfe_coef
)

saveRDS(robustness, file.path(data_dir, "robustness_results.rds"))
cat("\nAll robustness results saved.\n")
