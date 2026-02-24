##──────────────────────────────────────────────────────────────────────────────
## 03_main_analysis.R — DR DiD and standard DiD analysis
## Paper: apep_0451 — Cocoa Boom and Human Capital in Ghana
##──────────────────────────────────────────────────────────────────────────────

library(data.table)
library(fixest)
library(DRDID)

DATA_DIR  <- here::here("output", "apep_0451", "v1", "data")
TABLE_DIR <- here::here("output", "apep_0451", "v1", "tables")
dir.create(TABLE_DIR, recursive = TRUE, showWarnings = FALSE)

## ── Load data ───────────────────────────────────────────────────────────────
dt <- fread(file.path(DATA_DIR, "ghana_census_clean.csv.gz"), nThread = 4)
cat("Loaded:", format(nrow(dt), big.mark = ","), "observations\n")

## ── Define analysis samples ─────────────────────────────────────────────────
## Main analysis: 2000 vs 2010 (the cocoa boom period)
dt_main <- dt[census_year %in% c(2000, 2010)]

## Forest-belt only (main specification)
dt_forest <- dt_main[forest_belt == TRUE]

## Pre-trend: 1984 vs 2000 (no cocoa boom — prices declining)
dt_pre <- dt[census_year %in% c(1984, 2000)]
dt_pre_forest <- dt_pre[forest_belt == TRUE]

cat("Main sample (2000-2010):", format(nrow(dt_main), big.mark = ","), "\n")
cat("Forest belt (2000-2010):", format(nrow(dt_forest), big.mark = ","), "\n")
cat("Pre-trend (1984-2000):", format(nrow(dt_pre), big.mark = ","), "\n")

## ════════════════════════════════════════════════════════════════════════════
## PANEL A: SCHOOL-AGE CHILDREN (6-17) — Enrollment and Literacy
## ════════════════════════════════════════════════════════════════════════════

cat("\n\n===== PANEL A: School-Age Children (6-17) =====\n\n")

## ── A1. Standard DiD with continuous treatment (Bartik) ─────────────────────
## Y_irt = β(CocoaShare_r × Post_t) + γ_r + δ_t + X_irt'θ + ε_irt

## School enrollment — Forest belt
m_enroll_fb <- feols(
  in_school ~ cocoa_share:post2010 + female + I(age) |
    geo1 + census_year,
  data = dt_forest[school_age == 1 & !is.na(in_school)],
  weights = ~pw,
  cluster = ~geo1
)

## School enrollment — All 10 regions
m_enroll_all <- feols(
  in_school ~ cocoa_share:post2010 + female + I(age) |
    geo1 + census_year,
  data = dt_main[school_age == 1 & !is.na(in_school)],
  weights = ~pw,
  cluster = ~geo1
)

## Literacy — Forest belt (2000-2010 only, LIT unavailable in 1984)
m_lit_fb <- feols(
  literate ~ cocoa_share:post2010 + female + I(age) |
    geo1 + census_year,
  data = dt_forest[school_age == 1 & !is.na(literate)],
  weights = ~pw,
  cluster = ~geo1
)

## Completed primary — Forest belt
m_primary_fb <- feols(
  completed_primary ~ cocoa_share:post2010 + female + I(age) |
    geo1 + census_year,
  data = dt_forest[school_age == 1],
  weights = ~pw,
  cluster = ~geo1
)

cat("── School enrollment (forest belt) ──\n")
print(summary(m_enroll_fb))
cat("\n── Literacy (forest belt) ──\n")
print(summary(m_lit_fb))
cat("\n── Primary completion (forest belt) ──\n")
print(summary(m_primary_fb))

## ── A2. Binary treatment DiD (high-cocoa vs low-cocoa) ──────────────────────
m_enroll_binary <- feols(
  in_school ~ high_cocoa:post2010 + female + I(age) |
    geo1 + census_year,
  data = dt_forest[school_age == 1 & !is.na(in_school)],
  weights = ~pw,
  cluster = ~geo1
)

m_lit_binary <- feols(
  literate ~ high_cocoa:post2010 + female + I(age) |
    geo1 + census_year,
  data = dt_forest[school_age == 1 & !is.na(literate)],
  weights = ~pw,
  cluster = ~geo1
)

## ── A3. DR DiD (Sant'Anna & Zhao 2020) ─────────────────────────────────────
## DRDID requires: outcome, treatment (binary), post indicator, covariates
## Use forest-belt sample, binary treatment

## Prepare data for DRDID
drdid_school <- dt_forest[school_age == 1 & !is.na(in_school) & !is.na(female)]
drdid_school[, post := as.integer(census_year == 2010)]
drdid_school[, id := .I]  # Row ID for repeated cross-section

cat("\nDR DiD sample (school enrollment):", nrow(drdid_school), "\n")
cat("Treatment (high_cocoa): ", table(drdid_school$high_cocoa), "\n")
cat("Post: ", table(drdid_school$post), "\n")

## Run DRDID — improved locally efficient DR DiD for repeated cross-sections
## Use the drdid wrapper which handles data formatting better
## Sample 100K per group to keep computation feasible
set.seed(42)
n_sample <- min(100000, nrow(drdid_school))
set.seed(42)
drdid_sub <- drdid_school[sample(.N, n_sample)]
drdid_sub[, `:=`(female_n = as.numeric(female), age_n = as.numeric(age))]

drdid_enroll <- tryCatch({
  drdid_imp_rc(
    y = drdid_sub$in_school,
    post = drdid_sub$post,
    D = drdid_sub$high_cocoa,
    covariates = as.matrix(drdid_sub[, .(female_n, age_n)])
  )
}, error = function(e) {
  cat("DRDID error:", e$message, "\nFalling back to standard drdid_rc\n")
  drdid_rc(
    y = drdid_sub$in_school,
    post = drdid_sub$post,
    D = drdid_sub$high_cocoa,
    covariates = as.matrix(drdid_sub[, .(female_n, age_n)])
  )
})
cat("\n── DR DiD: School Enrollment (subsample) ──\n")
print(summary(drdid_enroll))

## DR DiD for literacy
drdid_lit_data <- dt_forest[school_age == 1 & !is.na(literate) & !is.na(female) &
                             census_year %in% c(2000, 2010)]
drdid_lit_data[, `:=`(post = as.integer(census_year == 2010),
                       female_n = as.numeric(female), age_n = as.numeric(age))]
n_lit <- min(100000, nrow(drdid_lit_data))
set.seed(123)
drdid_lit_sub <- drdid_lit_data[sample(.N, n_lit)]

drdid_lit <- tryCatch({
  drdid_imp_rc(
    y = drdid_lit_sub$literate,
    post = drdid_lit_sub$post,
    D = drdid_lit_sub$high_cocoa,
    covariates = as.matrix(drdid_lit_sub[, .(female_n, age_n)])
  )
}, error = function(e) {
  cat("DRDID error:", e$message, "\n")
  NULL
})
if (!is.null(drdid_lit)) {
  cat("\n── DR DiD: Literacy ──\n")
  print(summary(drdid_lit))
}

## DR DiD for primary completion
drdid_prim_data <- dt_forest[school_age == 1 & !is.na(female) &
                              census_year %in% c(2000, 2010)]
drdid_prim_data[, `:=`(post = as.integer(census_year == 2010),
                        female_n = as.numeric(female), age_n = as.numeric(age))]
n_prim <- min(100000, nrow(drdid_prim_data))
set.seed(456)
drdid_prim_sub <- drdid_prim_data[sample(.N, n_prim)]

drdid_prim <- tryCatch({
  drdid_imp_rc(
    y = drdid_prim_sub$completed_primary,
    post = drdid_prim_sub$post,
    D = drdid_prim_sub$high_cocoa,
    covariates = as.matrix(drdid_prim_sub[, .(female_n, age_n)])
  )
}, error = function(e) {
  cat("DRDID error:", e$message, "\n")
  NULL
})
if (!is.null(drdid_prim)) {
  cat("\n── DR DiD: Primary Completion ──\n")
  print(summary(drdid_prim))
}

## ── A4. Age heterogeneity ───────────────────────────────────────────────────
## Primary age (6-11) vs. Secondary age (12-17)
m_enroll_primary_age <- feols(
  in_school ~ cocoa_share:post2010 + female + I(age) |
    geo1 + census_year,
  data = dt_forest[primary_age == 1 & !is.na(in_school)],
  weights = ~pw, cluster = ~geo1
)

m_enroll_secondary_age <- feols(
  in_school ~ cocoa_share:post2010 + female + I(age) |
    geo1 + census_year,
  data = dt_forest[secondary_age == 1 & !is.na(in_school)],
  weights = ~pw, cluster = ~geo1
)

cat("\n── Enrollment: Primary age (6-11) ──\n")
print(summary(m_enroll_primary_age))
cat("\n── Enrollment: Secondary age (12-17) ──\n")
print(summary(m_enroll_secondary_age))

## ── A5. Gender heterogeneity ────────────────────────────────────────────────
m_enroll_male <- feols(
  in_school ~ cocoa_share:post2010 + I(age) |
    geo1 + census_year,
  data = dt_forest[school_age == 1 & female == 0 & !is.na(in_school)],
  weights = ~pw, cluster = ~geo1
)

m_enroll_female <- feols(
  in_school ~ cocoa_share:post2010 + I(age) |
    geo1 + census_year,
  data = dt_forest[school_age == 1 & female == 1 & !is.na(in_school)],
  weights = ~pw, cluster = ~geo1
)

cat("\n── Enrollment: Males ──\n")
print(summary(m_enroll_male))
cat("\n── Enrollment: Females ──\n")
print(summary(m_enroll_female))

## ════════════════════════════════════════════════════════════════════════════
## PANEL B: WORKING-AGE ADULTS (18-64) — Employment and Sector
## ════════════════════════════════════════════════════════════════════════════

cat("\n\n===== PANEL B: Working-Age Adults (18-64) =====\n\n")

## Employment
m_emp_fb <- feols(
  employed ~ cocoa_share:post2010 + female + I(age) |
    geo1 + census_year,
  data = dt_forest[working_age == 1 & !is.na(employed)],
  weights = ~pw, cluster = ~geo1
)

## Agricultural employment
m_agri_fb <- feols(
  works_agriculture ~ cocoa_share:post2010 + female + I(age) |
    geo1 + census_year,
  data = dt_forest[working_age == 1 & !is.na(works_agriculture)],
  weights = ~pw, cluster = ~geo1
)

## Self-employment
m_self_fb <- feols(
  self_employed ~ cocoa_share:post2010 + female + I(age) |
    geo1 + census_year,
  data = dt_forest[working_age == 1 & employed == 1],
  weights = ~pw, cluster = ~geo1
)

## Unpaid family work
m_unpaid_fb <- feols(
  unpaid_family ~ cocoa_share:post2010 + female + I(age) |
    geo1 + census_year,
  data = dt_forest[working_age == 1 & employed == 1],
  weights = ~pw, cluster = ~geo1
)

cat("── Employment (forest belt) ──\n")
print(summary(m_emp_fb))
cat("\n── Agricultural employment ──\n")
print(summary(m_agri_fb))
cat("\n── Self-employment ──\n")
print(summary(m_self_fb))

## DR DiD for employment
drdid_emp_data <- dt_forest[working_age == 1 & !is.na(employed) & !is.na(female)]
drdid_emp_data[, `:=`(post = as.integer(census_year == 2010),
                       female_n = as.numeric(female), age_n = as.numeric(age))]
set.seed(789)
drdid_emp_sub <- drdid_emp_data[sample(.N, min(100000, .N))]

drdid_emp <- tryCatch({
  drdid_imp_rc(
    y = drdid_emp_sub$employed,
    post = drdid_emp_sub$post,
    D = drdid_emp_sub$high_cocoa,
    covariates = as.matrix(drdid_emp_sub[, .(female_n, age_n)])
  )
}, error = function(e) { cat("DRDID error:", e$message, "\n"); NULL })
if (!is.null(drdid_emp)) {
  cat("\n── DR DiD: Employment ──\n")
  print(summary(drdid_emp))
}

## DR DiD for agriculture
drdid_agri_data <- dt_forest[working_age == 1 & !is.na(works_agriculture) & !is.na(female)]
drdid_agri_data[, `:=`(post = as.integer(census_year == 2010),
                        female_n = as.numeric(female), age_n = as.numeric(age))]
set.seed(101)
drdid_agri_sub <- drdid_agri_data[sample(.N, min(100000, .N))]

drdid_agri <- tryCatch({
  drdid_imp_rc(
    y = drdid_agri_sub$works_agriculture,
    post = drdid_agri_sub$post,
    D = drdid_agri_sub$high_cocoa,
    covariates = as.matrix(drdid_agri_sub[, .(female_n, age_n)])
  )
}, error = function(e) { cat("DRDID error:", e$message, "\n"); NULL })
if (!is.null(drdid_agri)) {
  cat("\n── DR DiD: Agriculture ──\n")
  print(summary(drdid_agri))
}

## ════════════════════════════════════════════════════════════════════════════
## PANEL C: YOUNG ADULTS (18-30) — Educational Attainment
## ════════════════════════════════════════════════════════════════════════════

cat("\n\n===== PANEL C: Young Adults (18-30) — Attainment =====\n\n")

m_secondary_ya <- feols(
  completed_secondary ~ cocoa_share:post2010 + female + I(age) |
    geo1 + census_year,
  data = dt_forest[young_adult == 1],
  weights = ~pw, cluster = ~geo1
)

m_university_ya <- feols(
  completed_university ~ cocoa_share:post2010 + female + I(age) |
    geo1 + census_year,
  data = dt_forest[young_adult == 1],
  weights = ~pw, cluster = ~geo1
)

cat("── Secondary completion (18-30) ──\n")
print(summary(m_secondary_ya))
cat("\n── University completion (18-30) ──\n")
print(summary(m_university_ya))

## ════════════════════════════════════════════════════════════════════════════
## SAVE MODEL OBJECTS
## ════════════════════════════════════════════════════════════════════════════

results <- list(
  ## School-age enrollment/literacy
  m_enroll_fb = m_enroll_fb,
  m_enroll_all = m_enroll_all,
  m_lit_fb = m_lit_fb,
  m_primary_fb = m_primary_fb,
  m_enroll_binary = m_enroll_binary,
  m_lit_binary = m_lit_binary,
  ## Age/gender heterogeneity
  m_enroll_primary_age = m_enroll_primary_age,
  m_enroll_secondary_age = m_enroll_secondary_age,
  m_enroll_male = m_enroll_male,
  m_enroll_female = m_enroll_female,
  ## Employment/sector
  m_emp_fb = m_emp_fb,
  m_agri_fb = m_agri_fb,
  m_self_fb = m_self_fb,
  m_unpaid_fb = m_unpaid_fb,
  ## Young adult attainment
  m_secondary_ya = m_secondary_ya,
  m_university_ya = m_university_ya,
  ## DR DiD
  drdid_enroll = drdid_enroll,
  drdid_lit = drdid_lit,
  drdid_prim = drdid_prim,
  drdid_emp = drdid_emp,
  drdid_agri = drdid_agri
)

saveRDS(results, file.path(DATA_DIR, "main_results.rds"))
cat("\n\nAll results saved to main_results.rds\n")
