# ============================================================================
# APEP-0055 v3: Coverage Cliffs — Age 26 RDD on Birth Insurance Coverage
# 02_clean_data.R - Process natality files and create analysis sample
# ============================================================================

source("00_packages.R")

# ============================================================================
# Read and Process Natality Files (2016-2023, 8 years pooled)
# ============================================================================

# Columns we need (based on NBER codebook)
keep_cols <- c(
  "dob_yy",     # Year of birth
  "dob_mm",     # Month of birth
  "mager",      # Mother's single year of age
  "pay",        # Source of payment (primary)
  "pay_rec",    # Payment recode
  "mrace6",     # Mother's race (6 categories)
  "mracehisp",  # Mother's race/Hispanic origin
  "meduc",      # Mother's education
  "dmar",       # Mother's marital status
  "lbo_rec",    # Live birth order
  "precare5",   # Month prenatal care began
  "dbwt",       # Birth weight (grams)
  "combgest",   # Gestation (weeks)
  "bfacil",     # Birth facility
  "mbstate_rec" # Mother's birthplace (US-born indicator)
)

# Process each year
years <- 2016:2023
all_data <- list()

for (year in years) {
  dta_path <- file.path(data_dir, sprintf("natality%dus.dta", year))

  if (!file.exists(dta_path)) {
    cat(sprintf("Year %d: File not found, skipping.\n", year))
    next
  }

  cat(sprintf("Year %d: Reading...\n", year))

  # Read Stata file with haven
  df <- haven::read_dta(dta_path)

  # Convert to data.table
  dt <- as.data.table(df)
  rm(df); gc()

  # Standardize column names to lowercase
  setnames(dt, tolower(names(dt)))

  # Add year identifier (tracks source file year)
  dt[, data_year := year]

  # Basic cleaning
  # Filter to ages 22-30 (gives us bandwidth flexibility around 26)
  dt <- dt[mager >= 22 & mager <= 30]

  # Recode payment source
  dt[, payment := factor(pay, levels = c(1, 2, 3, 4, 5, 6, 8, 9),
                         labels = c("Medicaid", "Private", "Self-pay",
                                    "IHS", "TRICARE", "Other Gov",
                                    "Other", "Unknown"))]

  # Binary outcomes
  dt[, medicaid := as.integer(pay == 1)]
  dt[, private := as.integer(pay == 2)]
  dt[, selfpay := as.integer(pay == 3)]
  dt[, uninsured := as.integer(pay == 3)]  # Self-pay = uninsured proxy

  # Treatment indicator (age 26 or older)
  dt[, above_26 := as.integer(mager >= 26)]

  # Running variable centered at 26
  dt[, age_centered := mager - 26]

  # Rename MAGER for consistency with analysis code
  setnames(dt, "mager", "MAGER")

  # Clean covariates
  dt[, married := as.integer(dmar == 1)]

  # US-born indicator from MBSTATE_REC:
  # 1 = Born in state of residence, 2 = Born in another state,
  # 3 = Born outside US, 4 = Born in US state unknown
  # US-born = values 1, 2, or 4 (born in US); NOT US-born = 3
  dt[, us_born := as.integer(mbstate_rec %in% c(1, 2, 4))]

  # Education (clean missing)
  dt[meduc %in% c(9, 99), meduc := NA]
  dt[, college := as.integer(meduc >= 6)]  # Bachelor's or higher

  # Birth weight (clean missing)
  dt[dbwt == 9999, dbwt := NA]
  dt[, low_birthweight := as.integer(dbwt < 2500)]
  setnames(dt, "dbwt", "DBWT")

  # Gestation (clean missing)
  dt[combgest == 99, combgest := NA]
  dt[, preterm := as.integer(combgest < 37)]

  # Prenatal care (clean missing)
  dt[precare5 %in% c(6, 9), precare5 := NA]
  dt[, early_prenatal := as.integer(precare5 == 1)]  # First trimester

  # Race/ethnicity
  dt[, race := factor(mrace6, levels = 1:6,
                      labels = c("White", "Black", "AIAN", "Asian", "NHOPI", "Multiple"))]

  # Keep only needed columns
  keep_final <- c("MAGER", "data_year", "payment", "medicaid", "private", "selfpay",
                  "uninsured", "above_26", "age_centered", "married", "us_born",
                  "college", "DBWT", "low_birthweight", "preterm", "early_prenatal", "race")
  dt <- dt[, ..keep_final]

  all_data[[as.character(year)]] <- dt

  cat(sprintf("Year %d: %d births in age range 22-30.\n", year, nrow(dt)))

  # Clean up
  rm(dt); gc()
}

# Combine all years
cat("\nCombining all years...\n")
natality <- rbindlist(all_data)

# ============================================================================
# Year-count assertion: verify multi-year pooling
# ============================================================================
n_years <- length(unique(natality$data_year))
cat(sprintf("Number of unique data years: %d\n", n_years))
stopifnot(n_years >= 2)  # Must have >1 year for multi-year claim

cat(sprintf("Total sample: %s births\n", format(nrow(natality), big.mark = ",")))
cat(sprintf("Years: %d to %d (%d years)\n",
            min(natality$data_year), max(natality$data_year), n_years))

# ============================================================================
# Summary Statistics
# ============================================================================

cat("\n=== Sample by Age ===\n")
print(natality[, .N, by = MAGER][order(MAGER)])

cat("\n=== Payment Source Distribution ===\n")
print(natality[, .(N = .N, pct = round(.N/nrow(natality)*100, 1)), by = payment][order(-N)])

cat("\n=== Payment by Age (around 26) ===\n")
print(natality[MAGER %in% 24:28, .(
  N = .N,
  pct_medicaid = round(mean(medicaid, na.rm=TRUE)*100, 1),
  pct_private = round(mean(private, na.rm=TRUE)*100, 1),
  pct_selfpay = round(mean(selfpay, na.rm=TRUE)*100, 1)
), by = MAGER][order(MAGER)])

cat("\n=== Sample by Year ===\n")
print(natality[, .N, by = data_year][order(data_year)])

# ============================================================================
# Save Analysis File
# ============================================================================

# Save as compressed RDS for faster loading
out_path <- file.path(data_dir, "natality_analysis.rds")
saveRDS(natality, out_path)
cat(sprintf("\nAnalysis file saved to: %s\n", out_path))
cat(sprintf("File size: %.1f MB\n", file.size(out_path) / 1e6))

# Also save a summary dataset at age level for quick plotting
age_summary <- natality[, .(
  N = .N,
  pct_medicaid = mean(medicaid, na.rm=TRUE),
  pct_private = mean(private, na.rm=TRUE),
  pct_selfpay = mean(selfpay, na.rm=TRUE),
  pct_married = mean(married, na.rm=TRUE),
  pct_college = mean(college, na.rm=TRUE),
  pct_us_born = mean(us_born, na.rm=TRUE),
  pct_early_prenatal = mean(early_prenatal, na.rm=TRUE),
  pct_preterm = mean(preterm, na.rm=TRUE),
  pct_low_birthweight = mean(low_birthweight, na.rm=TRUE),
  mean_birthweight = mean(DBWT, na.rm=TRUE)
), by = MAGER][order(MAGER)]

saveRDS(age_summary, file.path(data_dir, "age_summary.rds"))
cat("Age-level summary saved.\n")

print(age_summary)
