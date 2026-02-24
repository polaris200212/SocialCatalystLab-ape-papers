##──────────────────────────────────────────────────────────────────────────────
## 04_robustness.R — Pre-trends, placebo, migration, sensitivity
## Paper: apep_0451 — Cocoa Boom and Human Capital in Ghana
##──────────────────────────────────────────────────────────────────────────────

library(data.table)
library(fixest)
library(sensemakr)

DATA_DIR  <- here::here("output", "apep_0451", "v1", "data")
TABLE_DIR <- here::here("output", "apep_0451", "v1", "tables")

dt <- fread(file.path(DATA_DIR, "ghana_census_clean.csv.gz"), nThread = 4)
results <- readRDS(file.path(DATA_DIR, "main_results.rds"))

## ════════════════════════════════════════════════════════════════════════════
## 1. PRE-TREND TESTS: 1984-2000 (no cocoa boom — prices were declining)
## ════════════════════════════════════════════════════════════════════════════
cat("\n===== PRE-TREND TESTS (1984-2000) =====\n")

dt_pre <- dt[census_year %in% c(1984, 2000)]
dt_pre_forest <- dt_pre[forest_belt == TRUE]

## School enrollment pre-trend
pre_enroll <- feols(
  in_school ~ cocoa_share:post2000 + female + I(age) |
    geo1 + census_year,
  data = dt_pre_forest[school_age == 1 & !is.na(in_school)],
  weights = ~pw, cluster = ~geo1
)
cat("Pre-trend: School enrollment\n")
print(summary(pre_enroll))

## Primary completion pre-trend
pre_primary <- feols(
  completed_primary ~ cocoa_share:post2000 + female + I(age) |
    geo1 + census_year,
  data = dt_pre_forest[school_age == 1],
  weights = ~pw, cluster = ~geo1
)
cat("\nPre-trend: Primary completion\n")
print(summary(pre_primary))

## Employment pre-trend
pre_emp <- feols(
  employed ~ cocoa_share:post2000 + female + I(age) |
    geo1 + census_year,
  data = dt_pre_forest[working_age == 1 & !is.na(employed)],
  weights = ~pw, cluster = ~geo1
)
cat("\nPre-trend: Employment\n")
print(summary(pre_emp))

## Agriculture pre-trend
pre_agri <- feols(
  works_agriculture ~ cocoa_share:post2000 + female + I(age) |
    geo1 + census_year,
  data = dt_pre_forest[working_age == 1 & !is.na(works_agriculture)],
  weights = ~pw, cluster = ~geo1
)
cat("\nPre-trend: Agriculture\n")
print(summary(pre_agri))

## ════════════════════════════════════════════════════════════════════════════
## 2. FULL 10-REGION SAMPLE (relaxing forest-belt restriction)
## ════════════════════════════════════════════════════════════════════════════
cat("\n\n===== ROBUSTNESS: FULL 10-REGION SAMPLE =====\n")

dt_main <- dt[census_year %in% c(2000, 2010)]

full_enroll <- feols(
  in_school ~ cocoa_share:post2010 + female + I(age) |
    geo1 + census_year,
  data = dt_main[school_age == 1 & !is.na(in_school)],
  weights = ~pw, cluster = ~geo1
)
cat("Full sample: School enrollment\n")
print(summary(full_enroll))

full_lit <- feols(
  literate ~ cocoa_share:post2010 + female + I(age) |
    geo1 + census_year,
  data = dt_main[school_age == 1 & !is.na(literate)],
  weights = ~pw, cluster = ~geo1
)
cat("\nFull sample: Literacy\n")
print(summary(full_lit))

full_emp <- feols(
  employed ~ cocoa_share:post2010 + female + I(age) |
    geo1 + census_year,
  data = dt_main[working_age == 1 & !is.na(employed)],
  weights = ~pw, cluster = ~geo1
)
cat("\nFull sample: Employment\n")
print(summary(full_emp))

## ════════════════════════════════════════════════════════════════════════════
## 3. RURAL SUBSAMPLE (where cocoa effects most concentrated)
## ════════════════════════════════════════════════════════════════════════════
cat("\n\n===== ROBUSTNESS: RURAL SUBSAMPLE =====\n")

dt_rural <- dt_main[forest_belt == TRUE & urban == 0]

rural_enroll <- feols(
  in_school ~ cocoa_share:post2010 + female + I(age) |
    geo1 + census_year,
  data = dt_rural[school_age == 1 & !is.na(in_school)],
  weights = ~pw, cluster = ~geo1
)
cat("Rural: Enrollment\n")
print(summary(rural_enroll))

rural_lit <- feols(
  literate ~ cocoa_share:post2010 + female + I(age) |
    geo1 + census_year,
  data = dt_rural[school_age == 1 & !is.na(literate)],
  weights = ~pw, cluster = ~geo1
)
cat("\nRural: Literacy\n")
print(summary(rural_lit))

rural_emp <- feols(
  employed ~ cocoa_share:post2010 + female + I(age) |
    geo1 + census_year,
  data = dt_rural[working_age == 1 & !is.na(employed)],
  weights = ~pw, cluster = ~geo1
)
cat("\nRural: Employment\n")
print(summary(rural_emp))

## ════════════════════════════════════════════════════════════════════════════
## 4. MIGRATION TEST (composition check)
## ════════════════════════════════════════════════════════════════════════════
cat("\n\n===== MIGRATION/COMPOSITION CHECK =====\n")

## Working-age population growth by region
pop_growth <- dt[working_age == 1, .(pop = sum(pw)),
                  by = .(census_year, geo1, cocoa_share, region_name)]
pop_growth <- dcast(pop_growth, geo1 + cocoa_share + region_name ~ census_year,
                     value.var = "pop")
setnames(pop_growth, c("1984", "2000", "2010"),
         c("pop_1984", "pop_2000", "pop_2010"))
pop_growth[, growth_84_00 := (pop_2000 / pop_1984 - 1) * 100]
pop_growth[, growth_00_10 := (pop_2010 / pop_2000 - 1) * 100]
cat("Working-age population growth by region:\n")
print(pop_growth[order(-cocoa_share), .(region_name, cocoa_share,
                                         growth_84_00, growth_00_10)])

## Test: is population growth correlated with cocoa share?
pop_test <- lm(growth_00_10 ~ cocoa_share, data = pop_growth)
cat("\nCorrelation: pop growth (2000-2010) ~ cocoa share:\n")
print(summary(pop_test))

## ════════════════════════════════════════════════════════════════════════════
## 5. SENSITIVITY ANALYSIS (Cinelli & Hazlett 2020)
## ════════════════════════════════════════════════════════════════════════════
cat("\n\n===== SENSITIVITY ANALYSIS =====\n")

## OLS benchmark for sensemakr (without FE, since sensemakr needs lm object)
dt_forest_main <- dt[census_year %in% c(2000, 2010) & forest_belt == TRUE]

ols_lit <- lm(literate ~ cocoa_share:post2010 + factor(geo1) + factor(census_year) +
                female + age,
              data = dt_forest_main[school_age == 1 & !is.na(literate)],
              weights = pw)

sens_lit <- sensemakr(
  model = ols_lit,
  treatment = "cocoa_share:post2010",
  benchmark_covariates = "female",
  kd = 1:3
)
cat("Sensitivity analysis: Literacy\n")
print(summary(sens_lit))

## ════════════════════════════════════════════════════════════════════════════
## 6. THREE-PERIOD EVENT STUDY (Bartik)
## ════════════════════════════════════════════════════════════════════════════
cat("\n\n===== THREE-PERIOD EVENT STUDY =====\n")

## Use all three census years with period interactions
dt_forest_all <- dt[forest_belt == TRUE]

## Primary completion across all 3 periods
event_primary <- feols(
  completed_primary ~ cocoa_share:i(census_year, ref = 2000) + female + I(age) |
    geo1 + census_year,
  data = dt_forest_all[school_age == 1],
  weights = ~pw, cluster = ~geo1
)
cat("Event study: Primary completion\n")
print(summary(event_primary))

## Employment across all 3 periods
event_emp <- feols(
  employed ~ cocoa_share:i(census_year, ref = 2000) + female + I(age) |
    geo1 + census_year,
  data = dt_forest_all[working_age == 1 & !is.na(employed)],
  weights = ~pw, cluster = ~geo1
)
cat("\nEvent study: Employment\n")
print(summary(event_emp))

## ════════════════════════════════════════════════════════════════════════════
## 7. NEGATIVE CONTROL: OUTCOMES THAT SHOULDN'T BE AFFECTED
## ════════════════════════════════════════════════════════════════════════════
cat("\n\n===== NEGATIVE CONTROL =====\n")

## Female share among school-age children (shouldn't change with cocoa)
placebo_female <- feols(
  female ~ cocoa_share:post2010 + I(age) |
    geo1 + census_year,
  data = dt_forest_main[school_age == 1],
  weights = ~pw, cluster = ~geo1
)
cat("Placebo: Female share (should be null)\n")
print(summary(placebo_female))

## ════════════════════════════════════════════════════════════════════════════
## 8. RANDOMIZATION INFERENCE (exact permutation test, 6! = 720 permutations)
## ════════════════════════════════════════════════════════════════════════════
cat("\n\n===== RANDOMIZATION INFERENCE =====\n")

## Strategy: permute cocoa_share assignments across 6 forest-belt regions
## Under the sharp null, any assignment of shares to regions is equally likely
## With 6 regions, there are 6! = 720 possible permutations — enumerate all

library(combinat)  # for permn()

forest_regions <- sort(unique(dt_forest_main[forest_belt == TRUE]$geo1))
original_shares <- dt_forest_main[, .(cocoa_share = cocoa_share[1]), by = geo1][order(geo1)]
share_values <- original_shares$cocoa_share

## Generate all 720 permutations of cocoa shares
set.seed(42)
all_perms <- permn(share_values)
cat("Number of permutations:", length(all_perms), "\n")

## Function to run one permuted regression
run_permuted_reg <- function(perm_shares, outcome_var, sample_data, regions) {
  ## Map permuted shares to data
  share_map <- data.table(geo1 = regions, perm_share = perm_shares)
  d <- merge(sample_data, share_map, by = "geo1")

  ## Run regression with permuted treatment
  fml <- as.formula(paste0(outcome_var, " ~ perm_share:post2010 + female + I(age) | geo1 + census_year"))
  m <- tryCatch(
    feols(fml, data = d, weights = ~pw, cluster = ~geo1),
    error = function(e) NULL
  )
  if (is.null(m)) return(NA)
  coef(m)["perm_share:post2010"]
}

## Samples for RI
ri_school <- dt_forest_main[school_age == 1 & !is.na(literate)]
ri_emp <- dt_forest_main[working_age == 1 & !is.na(employed)]

## Observed coefficients
obs_lit <- coef(results$m_lit_fb)["cocoa_share:post2010"]
obs_emp <- coef(results$m_emp_fb)["cocoa_share:post2010"]

cat("Observed literacy coefficient:", obs_lit, "\n")
cat("Observed employment coefficient:", obs_emp, "\n")

## Run all 720 permutations for literacy
cat("Running RI for literacy (720 permutations)...\n")
ri_lit_coefs <- sapply(all_perms, function(p) {
  run_permuted_reg(p, "literate", ri_school, forest_regions)
})
ri_lit_pval <- mean(abs(ri_lit_coefs) >= abs(obs_lit), na.rm = TRUE)
cat("RI p-value (literacy):", ri_lit_pval, "\n")

## Run all 720 permutations for employment
cat("Running RI for employment (720 permutations)...\n")
ri_emp_coefs <- sapply(all_perms, function(p) {
  run_permuted_reg(p, "employed", ri_emp, forest_regions)
})
ri_emp_pval <- mean(abs(ri_emp_coefs) >= abs(obs_emp), na.rm = TRUE)
cat("RI p-value (employment):", ri_emp_pval, "\n")

## ════════════════════════════════════════════════════════════════════════════
## 9. LEAVE-ONE-REGION-OUT (jackknife influence diagnostics)
## ════════════════════════════════════════════════════════════════════════════
cat("\n\n===== LEAVE-ONE-REGION-OUT =====\n")

region_names <- dt_forest_main[, .(region_name = region_name[1]), by = geo1][order(geo1)]

loo_results <- data.table(
  geo1 = integer(),
  region_name = character(),
  lit_coef = numeric(),
  lit_se = numeric(),
  emp_coef = numeric(),
  emp_se = numeric()
)

for (i in seq_along(forest_regions)) {
  r <- forest_regions[i]
  rname <- region_names[geo1 == r]$region_name

  ## Literacy without region r
  d_school <- dt_forest_main[school_age == 1 & !is.na(literate) & geo1 != r]
  m_lit <- tryCatch(
    feols(literate ~ cocoa_share:post2010 + female + I(age) | geo1 + census_year,
          data = d_school, weights = ~pw, cluster = ~geo1),
    error = function(e) NULL
  )

  ## Employment without region r
  d_emp <- dt_forest_main[working_age == 1 & !is.na(employed) & geo1 != r]
  m_emp <- tryCatch(
    feols(employed ~ cocoa_share:post2010 + female + I(age) | geo1 + census_year,
          data = d_emp, weights = ~pw, cluster = ~geo1),
    error = function(e) NULL
  )

  loo_results <- rbind(loo_results, data.table(
    geo1 = r,
    region_name = rname,
    lit_coef = if (!is.null(m_lit)) coef(m_lit)["cocoa_share:post2010"] else NA,
    lit_se = if (!is.null(m_lit)) se(m_lit)["cocoa_share:post2010"] else NA,
    emp_coef = if (!is.null(m_emp)) coef(m_emp)["cocoa_share:post2010"] else NA,
    emp_se = if (!is.null(m_emp)) se(m_emp)["cocoa_share:post2010"] else NA
  ))

  cat(sprintf("  Dropped %-12s: lit = %7.4f, emp = %7.4f\n",
              rname,
              if (!is.null(m_lit)) coef(m_lit)["cocoa_share:post2010"] else NA,
              if (!is.null(m_emp)) coef(m_emp)["cocoa_share:post2010"] else NA))
}

cat("\nFull sample: lit =", round(obs_lit, 4), ", emp =", round(obs_emp, 4), "\n")
cat("LOO range (lit):", round(range(loo_results$lit_coef, na.rm = TRUE), 4), "\n")
cat("LOO range (emp):", round(range(loo_results$emp_coef, na.rm = TRUE), 4), "\n")

## ════════════════════════════════════════════════════════════════════════════
## SAVE ALL ROBUSTNESS RESULTS
## ════════════════════════════════════════════════════════════════════════════

robustness <- list(
  pre_enroll = pre_enroll,
  pre_primary = pre_primary,
  pre_emp = pre_emp,
  pre_agri = pre_agri,
  full_enroll = full_enroll,
  full_lit = full_lit,
  full_emp = full_emp,
  rural_enroll = rural_enroll,
  rural_lit = rural_lit,
  rural_emp = rural_emp,
  pop_growth = pop_growth,
  sens_lit = sens_lit,
  event_primary = event_primary,
  event_emp = event_emp,
  placebo_female = placebo_female,
  ## New: Randomization inference
  ri_lit_coefs = ri_lit_coefs,
  ri_lit_pval = ri_lit_pval,
  ri_emp_coefs = ri_emp_coefs,
  ri_emp_pval = ri_emp_pval,
  ## New: Leave-one-region-out
  loo_results = loo_results
)
saveRDS(robustness, file.path(DATA_DIR, "robustness_results.rds"))
cat("\nAll robustness results saved.\n")
