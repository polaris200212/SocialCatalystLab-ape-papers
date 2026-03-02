## ============================================================
## 04_robustness.R — Robustness Checks
## APEP-0463: Cash Scarcity and Food Prices (Nigeria 2023)
## ============================================================

source("00_packages.R")

data_dir <- "../data"
analysis <- readRDS(file.path(data_dir, "analysis.rds"))
analysis_extended <- readRDS(file.path(data_dir, "analysis_extended.rds"))

## ---------------------------------------------------------
## 1. Placebo Tests: Fake crisis at each quarter 2019-2022
## ---------------------------------------------------------
cat("=== Placebo Tests ===\n")

placebo_dates <- seq(as.Date("2019-07-01"), as.Date("2022-07-01"), by = "quarter")

placebo_results <- data.table()
for (pd in placebo_dates) {
  pd <- as.Date(pd, origin = "1970-01-01")

  ## Create placebo treatment window (5 weeks like real crisis)
  analysis[, placebo_crisis := as.integer(
    week >= pd & week <= (pd + 35)
  )]

  ## Restrict to 1 year before + 6 months after placebo date
  placebo_sample <- analysis[
    week >= (pd - 365) & week <= (pd + 180)
  ]

  if (nrow(placebo_sample) < 100) next

  m_placebo <- tryCatch({
    feols(
      log_food_price_idx ~ cash_scarcity_std:placebo_crisis |
        state + week,
      data = placebo_sample,
      cluster = ~state
    )
  }, error = function(e) NULL)

  if (!is.null(m_placebo)) {
    placebo_results <- rbind(placebo_results, data.table(
      placebo_date = pd,
      coef = coef(m_placebo)["cash_scarcity_std:placebo_crisis"],
      se = se(m_placebo)["cash_scarcity_std:placebo_crisis"],
      pval = fixest::pvalue(m_placebo)["cash_scarcity_std:placebo_crisis"]
    ))
  }
}

## Clean up temp column
analysis[, placebo_crisis := NULL]

cat(sprintf("  Completed %s placebo tests\n", nrow(placebo_results)))
cat("  Significant at 5%%: ",
    sum(placebo_results$pval < 0.05, na.rm = TRUE), "/",
    nrow(placebo_results), "\n")
print(placebo_results)

## ---------------------------------------------------------
## 2. Commodity Heterogeneity
## ---------------------------------------------------------
cat("\n=== Commodity Heterogeneity ===\n")

state_week_prices <- readRDS(file.path(data_dir, "state_week_prices.rds"))
bank_branches <- readRDS(file.path(data_dir, "bank_branches.rds"))

## Merge treatment intensity into commodity-level data
commodity_panel <- merge(
  state_week_prices,
  bank_branches[, .(state, cash_scarcity_std, branches_per_100k)],
  by = "state",
  all.x = TRUE
)
commodity_panel <- commodity_panel[!is.na(cash_scarcity_std)]

## Define treatment period
commodity_panel[, crisis_acute := as.integer(
  week >= as.Date("2023-01-30") & week <= as.Date("2023-03-06")
)]

## Restrict sample
commodity_panel <- commodity_panel[
  week >= as.Date("2019-01-01") & week <= as.Date("2024-06-30")
]

## Classify products
grains <- c("Rice (Milled)", "Rice (5% Broken)", "Maize (White)",
            "Maize (Yellow)", "Millet", "Sorghum (White)", "Sorghum (Red)")
legumes_tubers <- c("Cowpeas (Brown)", "Cowpeas (White)",
                     "Gari (White)", "Gari (Yellow)", "Groundnuts (Shelled)")
processed <- c("Bread")
fuel <- c("Gasoline", "Diesel")

commodity_panel[, product_group := fcase(
  product_clean %in% grains, "Grains",
  product_clean %in% legumes_tubers, "Legumes & Tubers",
  product_clean %in% processed, "Processed",
  product_clean %in% fuel, "Fuel",
  default = "Other"
)]

## Run by product group
hetero_results <- data.table()
for (pg in c("Grains", "Legumes & Tubers", "Processed", "Fuel")) {
  sub <- commodity_panel[product_group == pg]
  if (nrow(sub) < 50) next

  m_het <- tryCatch({
    feols(
      log_price ~ cash_scarcity_std:crisis_acute |
        state + week + product_clean,
      data = sub,
      cluster = ~state
    )
  }, error = function(e) NULL)

  if (!is.null(m_het)) {
    hetero_results <- rbind(hetero_results, data.table(
      product_group = pg,
      coef = coef(m_het)["cash_scarcity_std:crisis_acute"],
      se = se(m_het)["cash_scarcity_std:crisis_acute"],
      pval = fixest::pvalue(m_het)["cash_scarcity_std:crisis_acute"],
      n_obs = nobs(m_het)
    ))
  }
}

cat("Commodity heterogeneity results:\n")
print(hetero_results)

## ---------------------------------------------------------
## 3. Dose-Response: Quintiles of Banking Density
## ---------------------------------------------------------
cat("\n=== Dose-Response (Quintiles) ===\n")

## Create quintile bins of treatment intensity
analysis[, scarcity_quintile := ntile(cash_scarcity_std, 5)]
## Make it a factor with Q1 (lowest scarcity) as reference
analysis[, scarcity_q := factor(scarcity_quintile)]

m_dose <- feols(
  log_food_price_idx ~ i(scarcity_q, crisis_acute, ref = "1") |
    state + week,
  data = analysis,
  cluster = ~state
)
cat("\nDose-response (Q1 = lowest scarcity as reference):\n")
summary(m_dose)

## ---------------------------------------------------------
## 4. Randomization Inference
## ---------------------------------------------------------
cat("\n=== Randomization Inference ===\n")

## Permute treatment intensity across states
set.seed(42)
n_perms <- 999
actual_coef <- coef(feols(
  log_food_price_idx ~ cash_scarcity_std:crisis_acute |
    state + week,
  data = analysis,
  cluster = ~state
))["cash_scarcity_std:crisis_acute"]

perm_coefs <- numeric(n_perms)
states <- unique(analysis$state)

for (p in 1:n_perms) {
  ## Shuffle treatment assignment across states
  perm_map <- data.table(
    state = states,
    perm_scarcity = sample(unique(analysis[, .(state, cash_scarcity_std)])$cash_scarcity_std)
  )

  perm_data <- merge(
    analysis[, -"cash_scarcity_std", with = FALSE],
    perm_map,
    by = "state"
  )

  m_perm <- tryCatch({
    feols(
      log_food_price_idx ~ perm_scarcity:crisis_acute |
        state + week,
      data = perm_data,
      cluster = ~state
    )
  }, error = function(e) NULL)

  if (!is.null(m_perm)) {
    perm_coefs[p] <- coef(m_perm)["perm_scarcity:crisis_acute"]
  }
}

ri_pval <- mean(abs(perm_coefs) >= abs(actual_coef), na.rm = TRUE)
cat(sprintf("  Actual coefficient: %.4f\n", actual_coef))
cat(sprintf("  RI p-value (two-sided): %.4f\n", ri_pval))

## ---------------------------------------------------------
## 5. Alternative Treatment Measures
## ---------------------------------------------------------
cat("\n=== Alternative Treatment Measures ===\n")

## Use raw branches_per_100k instead of standardized
m_raw <- feols(
  log_food_price_idx ~ branches_per_100k:crisis_acute |
    state + week,
  data = analysis,
  cluster = ~state
)
cat("\nAlternative: Raw branches per 100k (negative = more branches reduce crisis effect)\n")
summary(m_raw)

## ---------------------------------------------------------
## 6. Extended Pre-Trends (2010-2024)
## ---------------------------------------------------------
cat("\n=== Extended Pre-Trends ===\n")

## Event study with extended pre-period
analysis_extended[, event_week := as.integer(
  difftime(week, as.Date("2023-01-30"), units = "weeks")
)]
es_ext <- analysis_extended[event_week >= -104 & event_week <= 52]
es_ext[, event_week_f := factor(event_week)]
es_ext[, event_week_f := relevel(event_week_f, ref = "-1")]

## Merge treatment intensity
es_ext <- merge(
  es_ext,
  readRDS(file.path(data_dir, "bank_branches.rds"))[,
    .(state, cash_scarcity_std)],
  by = "state",
  all.x = TRUE
)

m_es_ext <- tryCatch({
  feols(
    log_food_price_idx ~ i(event_week, cash_scarcity_std, ref = -1) |
      state + week,
    data = es_ext[!is.na(cash_scarcity_std)],
    cluster = ~state
  )
}, error = function(e) {
  cat("Extended event study error:", e$message, "\n")
  NULL
})

## ---------------------------------------------------------
## 7. State-Specific Linear Trends
## ---------------------------------------------------------
cat("\n=== State-Specific Linear Trends ===\n")

## Create numeric time trend
analysis[, time_trend := as.integer(week - min(week))]

m_trends <- feols(
  log_food_price_idx ~ cash_scarcity_std:crisis_acute |
    state[time_trend] + week,
  data = analysis,
  cluster = ~state
)
cat("With state-specific linear trends:\n")
summary(m_trends)

## ---------------------------------------------------------
## 8. WCB for Fuel Result
## ---------------------------------------------------------
cat("\n=== Wild Cluster Bootstrap for Fuel ===\n")

fuel_panel <- commodity_panel[product_group == "Fuel"]
m_fuel <- feols(
  log_price ~ cash_scarcity_std:crisis_acute |
    state + week + product_clean,
  data = fuel_panel,
  cluster = ~state
)

set.seed(20230201)
B_fuel <- 9999
fuel_clusters <- unique(fuel_panel$state)
G_fuel <- length(fuel_clusters)
actual_t_fuel <- coef(m_fuel)["cash_scarcity_std:crisis_acute"] /
  se(m_fuel)["cash_scarcity_std:crisis_acute"]

boot_t_fuel <- numeric(B_fuel)
for (b in 1:B_fuel) {
  w <- sample(c(-1, 1), G_fuel, replace = TRUE)
  names(w) <- fuel_clusters
  resids <- residuals(m_fuel)
  boot_y <- fitted(m_fuel) + resids * w[fuel_panel$state]
  boot_data <- copy(fuel_panel)
  boot_data[, boot_dep := boot_y]
  m_boot <- tryCatch({
    feols(boot_dep ~ cash_scarcity_std:crisis_acute |
          state + week + product_clean,
          data = boot_data, cluster = ~state)
  }, error = function(e) NULL)
  if (!is.null(m_boot)) {
    boot_t_fuel[b] <- coef(m_boot)["cash_scarcity_std:crisis_acute"] /
      se(m_boot)["cash_scarcity_std:crisis_acute"]
  }
}

wcb_fuel_pval <- mean(abs(boot_t_fuel) >= abs(actual_t_fuel), na.rm = TRUE)
cat(sprintf("  Fuel WCB p-value: %.4f (cluster-robust: %.4f)\n",
            wcb_fuel_pval,
            fixest::pvalue(m_fuel)["cash_scarcity_std:crisis_acute"]))

## ---------------------------------------------------------
## 9. North Dummy Comparison
## ---------------------------------------------------------
cat("\n=== North Dummy Comparison ===\n")

northern_states <- c("Zamfara", "Jigawa", "Kebbi", "Katsina", "Yobe",
                     "Borno", "Gombe", "Adamawa", "Kano", "Kaduna")
analysis[, is_north := as.integer(state %in% northern_states)]

m_north <- feols(
  log_food_price_idx ~ is_north:crisis_acute |
    state + week,
  data = analysis,
  cluster = ~state
)
cat("North dummy specification:\n")
summary(m_north)

## ---------------------------------------------------------
## 10. Save robustness results
## ---------------------------------------------------------
robustness <- list(
  placebo_results = placebo_results,
  hetero_results = hetero_results,
  m_dose = m_dose,
  ri_pval = ri_pval,
  perm_coefs = perm_coefs,
  actual_coef = actual_coef,
  m_raw = m_raw,
  m_es_ext = m_es_ext,
  commodity_panel = commodity_panel,
  m_trends = m_trends,
  wcb_fuel_pval = wcb_fuel_pval,
  m_north = m_north
)
saveRDS(robustness, file.path(data_dir, "robustness_results.rds"))

cat("\nRobustness checks complete.\n")
