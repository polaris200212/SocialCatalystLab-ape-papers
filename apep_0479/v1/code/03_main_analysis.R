## ============================================================
## 03_main_analysis.R — Main DiD and DDD specifications
## APEP-0479: Durbin Amendment, Bank Restructuring, and Tellers
## ============================================================

source("00_packages.R")

data_dir <- "../data/"
panel <- readRDS(file.path(data_dir, "analysis_panel.rds"))

cat("Panel loaded:", nrow(panel), "obs,", n_distinct(panel$county_fips), "counties\n")

## ---- 1. First Stage: Durbin Exposure → Branch Closures ----
## Does higher exposure to Durbin-affected banks predict branch closures?

cat("\n=== FIRST STAGE: Branches ===\n")

# 1a. Simple DiD: branches per capita
m1_branches <- feols(
  log_branches_pc ~ durbin_post |
    county_fips + year,
  data = panel,
  cluster = ~state_fips
)

# 1b. Event study: year-by-year effects
panel$year_factor <- relevel(factor(panel$year), ref = "2010")

m1_event <- feols(
  log_branches_pc ~ i(year, durbin_exposure, ref = 2010) |
    county_fips + year,
  data = panel,
  cluster = ~state_fips
)

cat("First-stage (log branches per capita):\n")
summary(m1_branches)
cat("\nEvent study coefficients:\n")
summary(m1_event)

# Save event study coefficients
es_branches <- as.data.frame(coeftable(m1_event))
es_branches$term <- rownames(es_branches)
saveRDS(es_branches, file.path(data_dir, "es_branches.rds"))


## ---- 2. Main Result: Durbin Exposure → Banking Employment ----

cat("\n=== MAIN RESULT: Banking Employment ===\n")

# 2a. Simple DiD
m2_emp <- feols(
  log_bank_emp ~ durbin_post |
    county_fips + year,
  data = panel,
  cluster = ~state_fips
)

# 2b. Event study
m2_event <- feols(
  log_bank_emp ~ i(year, durbin_exposure, ref = 2010) |
    county_fips + year,
  data = panel,
  cluster = ~state_fips
)

# 2c. Per capita
m2_emp_pc <- feols(
  log_bank_emp_pc ~ durbin_post |
    county_fips + year,
  data = panel,
  cluster = ~state_fips
)

cat("Main result (log banking employment):\n")
summary(m2_emp)
cat("\nPer capita:\n")
summary(m2_emp_pc)

# Save event study coefficients
es_emp <- as.data.frame(coeftable(m2_event))
es_emp$term <- rownames(es_emp)
saveRDS(es_emp, file.path(data_dir, "es_employment.rds"))


## ---- 3. Banking Wages ----

cat("\n=== WAGES ===\n")

m3_wage <- feols(
  log_bank_wage ~ durbin_post |
    county_fips + year,
  data = panel,
  cluster = ~state_fips
)

m3_wage_event <- feols(
  log_bank_wage ~ i(year, durbin_exposure, ref = 2010) |
    county_fips + year,
  data = panel,
  cluster = ~state_fips
)

cat("Banking wages:\n")
summary(m3_wage)


## ---- 4. Triple-Difference (DDD) ----
## Banking vs. non-banking employment in same counties
## Absorbs county-specific macro shocks

cat("\n=== TRIPLE-DIFFERENCE ===\n")

# Construct DDD panel: stack banking + retail + manufacturing
ddd_banking <- panel %>%
  transmute(
    county_fips, state_fips, year, durbin_exposure, post,
    sector = "banking",
    is_banking = 1,
    employment = bank_emp,
    log_emp = log(bank_emp + 1)
  )

ddd_retail <- panel %>%
  filter(!is.na(retail_emp)) %>%
  transmute(
    county_fips, state_fips, year, durbin_exposure, post,
    sector = "retail",
    is_banking = 0,
    employment = retail_emp,
    log_emp = log(retail_emp + 1)
  )

ddd_mfg <- panel %>%
  filter(!is.na(mfg_emp)) %>%
  transmute(
    county_fips, state_fips, year, durbin_exposure, post,
    sector = "manufacturing",
    is_banking = 0,
    employment = mfg_emp,
    log_emp = log(mfg_emp + 1)
  )

ddd_panel <- bind_rows(ddd_banking, ddd_retail, ddd_mfg)

# DDD specification
m4_ddd <- feols(
  log_emp ~ durbin_exposure:post:is_banking +
    durbin_exposure:post + post:is_banking + durbin_exposure:is_banking |
    county_fips^sector + year^sector + county_fips^year,
  data = ddd_panel,
  cluster = ~state_fips
)

cat("Triple-difference (banking vs retail+manufacturing):\n")
summary(m4_ddd)


## ---- 5. Deposit Reallocation ----
## Do deposits shift from Durbin-affected banks to exempt banks?

cat("\n=== DEPOSIT REALLOCATION ===\n")

# Durbin bank deposits (should decline in high-exposure counties)
m5_dep_durbin <- feols(
  log_deposits_durbin ~ durbin_post |
    county_fips + year,
  data = panel,
  cluster = ~state_fips
)

# Exempt bank deposits (should increase — reallocation)
m5_dep_exempt <- feols(
  log_deposits_exempt ~ durbin_post |
    county_fips + year,
  data = panel,
  cluster = ~state_fips
)

# Exempt share
m5_exempt_share <- feols(
  exempt_deposit_share ~ durbin_post |
    county_fips + year,
  data = panel,
  cluster = ~state_fips
)

cat("Durbin bank deposits:\n")
summary(m5_dep_durbin)
cat("\nExempt bank deposits:\n")
summary(m5_dep_exempt)
cat("\nExempt deposit share:\n")
summary(m5_exempt_share)


## ---- 6. Heterogeneity ----

cat("\n=== HETEROGENEITY ===\n")

# By exposure quartile
m6_hetero <- feols(
  log_bank_emp ~ i(exposure_q, post, ref = 1) |
    county_fips + year,
  data = panel,
  cluster = ~state_fips
)

cat("Heterogeneity by exposure quartile:\n")
summary(m6_hetero)


## ---- 7. Pre-trend Tests ----

cat("\n=== PRE-TREND TESTS ===\n")

# Joint F-test of pre-treatment coefficients
pre_coefs <- grep("^year::", names(coef(m2_event)), value = TRUE)
pre_coefs <- pre_coefs[grep("200[5-9]|2010", pre_coefs)]

if (length(pre_coefs) > 0) {
  pre_test <- wald(m2_event, pre_coefs)
  cat("Joint F-test of pre-treatment event study coefficients:\n")
  print(pre_test)
}


## ---- 8. Save all models ----

results <- list(
  m1_branches = m1_branches,
  m1_event = m1_event,
  m2_emp = m2_emp,
  m2_event = m2_event,
  m2_emp_pc = m2_emp_pc,
  m3_wage = m3_wage,
  m3_wage_event = m3_wage_event,
  m4_ddd = m4_ddd,
  m5_dep_durbin = m5_dep_durbin,
  m5_dep_exempt = m5_dep_exempt,
  m5_exempt_share = m5_exempt_share,
  m6_hetero = m6_hetero
)

saveRDS(results, file.path(data_dir, "main_results.rds"))
cat("\n=== All main results saved ===\n")
