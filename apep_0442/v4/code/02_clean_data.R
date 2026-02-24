## ============================================================================
## 02_clean_data.R — Census panel construction from Costa UA data
## Project: The First Retirement Age v3
## Key identifier: recidnum (links veteran across all datasets)
## ============================================================================

source("code/00_packages.R")

base <- file.path(data_dir, "costa_ua_raw")

cat("=== CONSTRUCTING ANALYSIS SAMPLE ===\n\n")

## ---- Load raw data ----
basics  <- as.data.table(read_dta(file.path(base, "Data101_The_Basics_All/The_Basics_unionarmy.dta")))
pension <- as.data.table(read_dta(file.path(base, "Data101_Pension_All/Pension_unionarmy.dta")))
socio   <- as.data.table(read_dta(file.path(base, "Data101_Socioeconomic_All/Socioeconomic_unionarmy_2017-06-29.dta")))

## ---- Merge all records ----
dt <- merge(basics, socio, by = "recidnum", all = TRUE)
dt <- merge(dt, pension, by = "recidnum", all = TRUE, suffixes = c("", ".pen"))
cat("Total veterans after merge:", nrow(dt), "\n")

## ---- Running variable: age at 1907 ----
dt[, birth_year := gen_bestbirthyear]
dt[, age_1907 := 1907 - birth_year]
dt[, above_62 := as.integer(age_1907 >= 62)]
dt[, running := age_1907 - 62]  # centered running variable

## ---- Mortality ----
dt[, death_yr := as.numeric(substr(rd_date, 1, 4))]
dt[, alive_1900 := is.na(death_yr) | death_yr >= 1900]
dt[, alive_1907 := is.na(death_yr) | death_yr >= 1907]
dt[, alive_1910 := is.na(death_yr) | death_yr >= 1910]

## ---- LFP from occupation codes ----
## gen_recocn_0 = 1950 occupation code at 1900 census
## gen_recocn_1 = 1950 occupation code at 1910 census
## 995 = "Other non-occupation" (not working / not found)
## 984 = "Retired"
## NA = not matched to census record

## Found in census (has any occupation code, including 995)
dt[, found_1900 := !is.na(gen_recocn_0)]
dt[, found_1910 := !is.na(gen_recocn_1)]

## LFP = 1 if has gainful occupation (not 995, not 984=retired)
## LFP = 0 if found in census but no gainful occupation or retired
## LFP = NA if not found in census or dead
dt[, lfp_1900 := NA_integer_]
dt[found_1900 == TRUE & alive_1900 == TRUE,
   lfp_1900 := fifelse(gen_recocn_0 != 995 & gen_recocn_0 != 984, 1L, 0L)]

dt[, lfp_1910 := NA_integer_]
dt[found_1910 == TRUE & alive_1910 == TRUE,
   lfp_1910 := fifelse(gen_recocn_1 != 995 & gen_recocn_1 != 984, 1L, 0L)]

## Panel change
dt[, delta_lfp := lfp_1910 - lfp_1900]

## ---- Occupation categories ----
## Using 1950 census occupation codes (gen_recocn_X)
## Farm: 100 (Farmers), 123 (Farm laborers)
## Manual: codes > 300 and various craftsmen/operatives
## Professional: codes < 100

code_to_occ_type <- function(code) {
  fifelse(is.na(code) | code == 995 | code == 984, "None/Retired",
  fifelse(code == 100, "Farmer",
  fifelse(code %in% c(123, 810, 820, 830), "Farm laborer",
  fifelse(code < 100, "Professional",
  fifelse(code < 400, "Clerical/Sales/Manager",
         "Manual/Operative")))))
}

dt[, occ_type_1900 := code_to_occ_type(gen_recocn_0)]
dt[, occ_type_1910 := code_to_occ_type(gen_recocn_1)]

## ---- Covariates ----
## Literacy (from socioeconomic)
dt[, literate := fifelse(gen_reads == 1 | gen_writes == 1, 1L,
                 fifelse(gen_reads == 0 & gen_writes == 0, 0L, NA_integer_))]

## Homeownership
dt[, homeowner := fifelse(gen_homeowner == 1, 1L,
                  fifelse(gen_homeowner == 0, 0L, NA_integer_))]

## Nativity: from birthplace ICPSR codes
## gen_birthplace_icpsr1 encodes state/country
dt[, native_born := fifelse(!is.na(gen_birthplace_icpsr1) & gen_birthplace_icpsr1 < 100, 1L,
                    fifelse(!is.na(gen_birthplace_icpsr1) & gen_birthplace_icpsr1 >= 100, 0L, NA_integer_))]

## State of enlistment
dt[, enlist_state := gen_rb_statbest]

## Height (early adult)
dt[, height := gen_hgt_early]

## BMI
dt[, bmi_1900 := gen_bmi_1900]
dt[, bmi_1910 := gen_bmi_1910]

## ---- Pension variables ----
## First pension
dt[, first_pension_date := gen_pendatefirst]
dt[, first_pension_law  := gen_penlaw_first]
dt[, first_pension_amt  := gen_penamt_first]

## Pension at 1900
dt[, pen_law_1900 := gen_penlaw_1900]
dt[, pen_amt_1900 := gen_penamt_1900]
dt[, had_pension_1900 := !is.na(gen_penamt_1900)]

## Pension at 1910
dt[, pen_law_1910 := gen_penlaw_1910]
dt[, pen_amt_1910 := gen_penamt_1910]
dt[, had_pension_1910 := !is.na(gen_penamt_1910)]

## Under 1907 Act (pension law date starts with "190702")
dt[, pension_1907act := as.integer(grepl("^190702", gen_penlaw_1910))]

## Old-age pension status
dt[, oldage_pension := fifelse(gen_penstatusoldage == 1, 1L,
                       fifelse(gen_penstatusoldage == 0, 0L, NA_integer_))]

## Pension increase
dt[, pen_increase := fifelse(!is.na(pen_amt_1910) & !is.na(pen_amt_1900),
                             pen_amt_1910 - pen_amt_1900,
                    fifelse(!is.na(pen_amt_1910) & is.na(pen_amt_1900),
                             pen_amt_1910, NA_real_))]

## Pre-1907 pension categories
dt[, pension_category := fifelse(!had_pension_1900 & pension_1907act == 1, "New (1907 Act)",
                         fifelse(had_pension_1900 & pen_amt_1900 < 12 & pension_1907act == 1, "Topped up to $12",
                         fifelse(had_pension_1900 & pen_amt_1900 >= 12, "Already >= $12",
                         fifelse(had_pension_1900 & pen_amt_1900 < 12 & pension_1907act == 0, "Had disability < $12",
                                "No pension"))))]

## ---- Sample restrictions ----
## Cross-sectional sample: alive at 1910, with LFP data, valid age
cross <- dt[alive_1910 == TRUE & !is.na(lfp_1910) & !is.na(age_1907) &
            age_1907 >= 52 & age_1907 <= 90]
cat("Cross-sectional sample (alive 1910, valid LFP & age):", nrow(cross), "\n")

## Panel sample: both LFP years available
panel <- dt[!is.na(lfp_1900) & !is.na(lfp_1910) & !is.na(age_1907) &
            age_1907 >= 52 & age_1907 <= 90]
cat("Panel sample (both LFP years, valid age):", nrow(panel), "\n")

## ---- Summary statistics ----
cat("\n--- SAMPLE SUMMARY ---\n")
cat("Cross-section:\n")
cat("  N:", nrow(cross), "\n")
cat("  Mean age at 1907:", round(mean(cross$age_1907), 1), "\n")
cat("  LFP 1910:", round(mean(cross$lfp_1910), 3), "\n")
cat("  Below 62:", sum(cross$above_62 == 0), "\n")
cat("  At/above 62:", sum(cross$above_62 == 1), "\n")
cat("  Pension (1907 Act):", round(mean(cross$pension_1907act), 3), "\n")

cat("\nPanel:\n")
cat("  N:", nrow(panel), "\n")
cat("  LFP 1900:", round(mean(panel$lfp_1900), 3), "\n")
cat("  LFP 1910:", round(mean(panel$lfp_1910), 3), "\n")
cat("  Delta LFP:", round(mean(panel$delta_lfp), 3), "\n")

## ---- Save ----
saveRDS(cross, file.path(data_dir, "cross_section_sample.rds"))
saveRDS(panel, file.path(data_dir, "panel_sample.rds"))
saveRDS(dt, file.path(data_dir, "full_merged.rds"))

cat("\nData saved to:\n")
cat("  cross_section_sample.rds\n")
cat("  panel_sample.rds\n")
cat("  full_merged.rds\n")
cat("\n=== SAMPLE CONSTRUCTION COMPLETE ===\n")
