## ============================================================================
## 01b_explore_data.R — Data exploration and quality checks
## Project: The First Retirement Age v3
## Purpose: Understand Costa UA data structure before building analysis sample
## ============================================================================

source("code/00_packages.R")

base <- file.path(data_dir, "costa_ua_raw")

## Load all Data 101 datasets
basics  <- as.data.table(read_dta(file.path(base, "Data101_The_Basics_All/The_Basics_unionarmy.dta")))
pension <- as.data.table(read_dta(file.path(base, "Data101_Pension_All/Pension_unionarmy.dta")))
socio   <- as.data.table(read_dta(file.path(base, "Data101_Socioeconomic_All/Socioeconomic_unionarmy_2017-06-29.dta")))
disease <- as.data.table(read_dta(file.path(base, "Data101_Disease_All/Disease_unionarmy.dta")))

cat("=== DATA EXPLORATION: Costa Union Army Dataset ===\n\n")

## ---- 1. Universe and Linkage ----
cat("--- 1. UNIVERSE ---\n")
cat("Total veterans (Basics):", nrow(basics), "\n")
cat("Total veterans (Pension):", nrow(pension), "\n")
cat("Total veterans (Socioeconomic):", nrow(socio), "\n")
cat("Unique veterans in Disease:", uniqueN(disease$recidnum), "\n")

## Merge basics + socio + pension
dt <- merge(basics, socio, by = "recidnum", all = TRUE)
dt <- merge(dt, pension, by = "recidnum", all = TRUE, suffixes = c("", ".pen"))
cat("Merged dataset rows:", nrow(dt), "\n\n")

## ---- 2. Birth year and age distribution ----
cat("--- 2. BIRTH YEAR & AGE ---\n")
dt[, age_1907 := 1907 - gen_bestbirthyear]
cat("Birth year — mean:", round(mean(dt$gen_bestbirthyear, na.rm=TRUE), 1), "\n")
cat("Birth year — median:", median(dt$gen_bestbirthyear, na.rm=TRUE), "\n")
cat("Age at 1907 — mean:", round(mean(dt$age_1907, na.rm=TRUE), 1), "\n")
cat("Age at 1907 — range:", range(dt$age_1907, na.rm=TRUE), "\n\n")

## ---- 3. Mortality ----
cat("--- 3. MORTALITY ---\n")
dt[, death_yr := as.numeric(substr(rd_date, 1, 4))]
dt[, alive_1900 := is.na(death_yr) | death_yr >= 1900]
dt[, alive_1910 := is.na(death_yr) | death_yr >= 1910]
dt[, alive_1907 := is.na(death_yr) | death_yr >= 1907]
cat("Alive in 1900:", sum(dt$alive_1900), "\n")
cat("Alive in 1907:", sum(dt$alive_1907), "\n")
cat("Alive in 1910:", sum(dt$alive_1910), "\n\n")

## ---- 4. Census linkage (occupation availability) ----
cat("--- 4. CENSUS LINKAGE ---\n")
# gen_recocn_0 = 1950 occ code at 1900 census, 995 = non-occupation
# gen_recocn_1 = 1950 occ code at 1910 census, 995 = non-occupation
# recocc_0 = raw text at 1900, recocc_1 = raw text at 1910

dt[, has_occ_1900 := !is.na(gen_recocn_0) & gen_recocn_0 != 995]
dt[, has_occ_1910 := !is.na(gen_recocn_1) & gen_recocn_1 != 995]
dt[, found_1900 := !is.na(gen_recocn_0)]  # Found in 1900 census (even if no occ)
dt[, found_1910 := !is.na(gen_recocn_1)]  # Found in 1910 census

cat("Found in 1900 census (non-NA occ code):", sum(dt$found_1900), "\n")
cat("  With gainful occupation:", sum(dt$has_occ_1900), "\n")
cat("  Without occupation (code 995):", sum(dt$found_1900 & !dt$has_occ_1900), "\n")
cat("Found in 1910 census (non-NA occ code):", sum(dt$found_1910), "\n")
cat("  With gainful occupation:", sum(dt$has_occ_1910), "\n")
cat("  Without occupation (code 995):", sum(dt$found_1910 & !dt$has_occ_1910), "\n")
cat("Found in both 1900 and 1910:", sum(dt$found_1900 & dt$found_1910), "\n")
cat("  Both with occupation:", sum(dt$has_occ_1900 & dt$has_occ_1910), "\n\n")

## ---- 5. Census-found vs. alive cross-tab ----
cat("--- 5. CENSUS FOUND vs. ALIVE ---\n")
cat("Among alive in 1900:\n")
cat("  Found in 1900 census:", sum(dt$alive_1900 & dt$found_1900), "/", sum(dt$alive_1900), "\n")
cat("Among alive in 1910:\n")
cat("  Found in 1910 census:", sum(dt$alive_1910 & dt$found_1910), "/", sum(dt$alive_1910), "\n")

## Key: Among those NOT found (995), how many were alive?
cat("Among those with 995 in 1900:\n")
cat("  Alive:", sum(!dt$has_occ_1900 & dt$found_1900 & dt$alive_1900), "\n")
cat("  Dead:", sum(!dt$has_occ_1900 & dt$found_1900 & !dt$alive_1900), "\n")
cat("Among those with 995 in 1910:\n")
cat("  Alive:", sum(!dt$has_occ_1910 & dt$found_1910 & dt$alive_1910), "\n")
cat("  Dead:", sum(!dt$has_occ_1910 & dt$found_1910 & !dt$alive_1910), "\n\n")

## ---- 6. LFP construction ----
cat("--- 6. LFP CONSTRUCTION ---\n")
# LFP = 1 if has any gainful occupation (not 995, not retired 984)
# LFP = 0 if 995 (no occupation) AND alive
# Retired (984) is ambiguous — could be LFP=0

# Check retired
cat("Retired code (984) at 1900:", sum(dt$gen_recocn_0 == 984, na.rm=TRUE), "\n")
cat("Retired code (984) at 1910:", sum(dt$gen_recocn_1 == 984, na.rm=TRUE), "\n")

# For analysis: focus on those found in census (alive, with occ code)
# Define lfp_1900 and lfp_1910
dt[found_1900 == TRUE & alive_1900 == TRUE,
   lfp_1900 := fifelse(has_occ_1900 & gen_recocn_0 != 984, 1L, 0L)]
dt[found_1910 == TRUE & alive_1910 == TRUE,
   lfp_1910 := fifelse(has_occ_1910 & gen_recocn_1 != 984, 1L, 0L)]

cat("LFP 1900 (among alive & found): mean =",
    round(mean(dt$lfp_1900, na.rm=TRUE), 3), ", N =", sum(!is.na(dt$lfp_1900)), "\n")
cat("LFP 1910 (among alive & found): mean =",
    round(mean(dt$lfp_1910, na.rm=TRUE), 3), ", N =", sum(!is.na(dt$lfp_1910)), "\n\n")

## ---- 7. Panel sample (both census years) ----
cat("--- 7. PANEL SAMPLE ---\n")
panel <- dt[!is.na(lfp_1900) & !is.na(lfp_1910)]
panel[, delta_lfp := lfp_1910 - lfp_1900]
cat("Panel N (both lfp_1900 and lfp_1910):", nrow(panel), "\n")
cat("Panel LFP 1900:", round(mean(panel$lfp_1900), 3), "\n")
cat("Panel LFP 1910:", round(mean(panel$lfp_1910), 3), "\n")
cat("Panel ΔY (mean):", round(mean(panel$delta_lfp), 3), "\n")
cat("Panel age at 1907 — range:", range(panel$age_1907, na.rm=TRUE), "\n")

# Within RDD bandwidth (±5 years of 62)
panel_bw <- panel[age_1907 >= 57 & age_1907 <= 67]
cat("Panel within ±5yr of 62:", nrow(panel_bw), "\n")
cat("  Below 62:", sum(panel_bw$age_1907 < 62), "\n")
cat("  At/above 62:", sum(panel_bw$age_1907 >= 62), "\n\n")

## ---- 8. Pension structure at 1907 ----
cat("--- 8. PENSION STRUCTURE ---\n")
# penlaw at 1910 contains the 1907 Act code (19070206)
dt[, pension_1907act := grepl("^190702", gen_penlaw_1910)]
cat("Under 1907 Act pension at 1910:", sum(dt$pension_1907act, na.rm=TRUE), "\n")
cat("  Pension amount (1907 Act recipients):",
    round(mean(dt[pension_1907act == TRUE]$gen_penamt_1910, na.rm=TRUE), 1), "\n")

# Check pension law 1890 (disability pension)
dt[, pension_1890 := grepl("^189006", gen_penlaw_1900)]
cat("Under 1890 disability pension at 1900:", sum(dt$pension_1890, na.rm=TRUE), "\n")

# Pension status cross-tab
cat("\nPension transition (among alive at 1910):\n")
dt_alive <- dt[alive_1910 == TRUE]
cat("  Had pension at 1900:", sum(!is.na(dt_alive$gen_penamt_1900)), "\n")
cat("  Had pension at 1910:", sum(!is.na(dt_alive$gen_penamt_1910)), "\n")
cat("  Gained pension (1907 Act, age 62+):", sum(dt_alive$pension_1907act, na.rm=TRUE), "\n\n")

## ---- 9. RDD feasibility ----
cat("--- 9. RDD FEASIBILITY (cross-section, 1910) ---\n")
rdd <- dt[alive_1910 == TRUE & !is.na(lfp_1910) & !is.na(age_1907)]
cat("RDD sample (alive, with lfp, with age):", nrow(rdd), "\n")
cat("  Below 62:", sum(rdd$age_1907 < 62), "\n")
cat("  At/above 62:", sum(rdd$age_1907 >= 62), "\n")
cat("  LFP below 62:", round(mean(rdd[age_1907 < 62]$lfp_1910), 3), "\n")
cat("  LFP at/above 62:", round(mean(rdd[age_1907 >= 62]$lfp_1910), 3), "\n")

# Quick raw jump
cat("\nRaw LFP by age near cutoff:\n")
for (a in 58:66) {
  sub <- rdd[age_1907 == a]
  if (nrow(sub) > 0) {
    cat(sprintf("  Age %d: N=%d, LFP=%.3f\n", a, nrow(sub), mean(sub$lfp_1910)))
  }
}

## ---- 10. Power calculation ----
cat("\n--- 10. POWER ESTIMATES ---\n")
# Within ±5yr bandwidth
rdd_bw5 <- rdd[age_1907 >= 57 & age_1907 <= 67]
n_left  <- sum(rdd_bw5$age_1907 < 62)
n_right <- sum(rdd_bw5$age_1907 >= 62)
sd_y    <- sd(rdd_bw5$lfp_1910)
mde <- 2.8 * sd_y * sqrt(1/n_left + 1/n_right)
cat("Cross-section RDD (±5yr):\n")
cat("  N_left:", n_left, " N_right:", n_right, "\n")
cat("  SD(LFP_1910):", round(sd_y, 3), "\n")
cat("  Approximate MDE (80% power):", round(mde, 3), "\n")

## Panel
panel_rdd <- panel[age_1907 >= 57 & age_1907 <= 67]
if (nrow(panel_rdd) > 0) {
  n_left_p  <- sum(panel_rdd$age_1907 < 62)
  n_right_p <- sum(panel_rdd$age_1907 >= 62)
  sd_dy     <- sd(panel_rdd$delta_lfp)
  mde_p <- 2.8 * sd_dy * sqrt(1/n_left_p + 1/n_right_p)
  cat("Panel RDD (±5yr, ΔY):\n")
  cat("  N_left:", n_left_p, " N_right:", n_right_p, "\n")
  cat("  SD(ΔY):", round(sd_dy, 3), "\n")
  cat("  Approximate MDE (80% power):", round(mde_p, 3), "\n")
}

cat("\n=== EXPLORATION COMPLETE ===\n")

## Save exploration results
saveRDS(dt, file.path(data_dir, "exploration_merged.rds"))
cat("Merged dataset saved to:", file.path(data_dir, "exploration_merged.rds"), "\n")
