################################################################################
# 02_clean_data.R — Variable Construction & Record Linkage
# Paper: Voting Their Wallet? Medicaid Revenue Dependence and Provider Political Behavior
# APEP-0487
#
# This script:
#   1. Matches T-MSIS providers (via NPPES) to FEC donors
#   2. Constructs Medicaid dependence measure (T-MSIS / (T-MSIS + Medicare))
#   3. Defines expansion treatment and timing
#   4. Builds the provider × election-cycle analysis panel
################################################################################

source("00_packages.R")

cat("=== Loading intermediate data ===\n")
provider_raw <- read_parquet(file.path(LOCAL_DATA, "provider_panel_raw.parquet")) |> setDT()
fec <- read_parquet(file.path(LOCAL_DATA, "fec_healthcare_donations.parquet")) |> setDT()

medicare_file <- file.path(LOCAL_DATA, "medicare_puf_all.parquet")
if (file.exists(medicare_file)) {
  medicare <- read_parquet(medicare_file) |> setDT()
} else {
  medicare <- data.table(npi = character(), year = integer(), medicare_paid_total = numeric())
}

cat("Provider raw:", nrow(provider_raw), "| FEC:", nrow(fec), "| Medicare:", nrow(medicare), "\n\n")

# ============================================================================
cat("=== Step 1: Define Medicaid Expansion Treatment ===\n")

# Late-expanding states within T-MSIS window (2018-2024)
expansion_states <- data.table(
  state = c("VA", "ME", "ID", "NE", "MO", "OK", "SD"),
  expansion_date = as.Date(c("2019-01-01", "2019-01-01", "2020-01-01",
                              "2020-10-01", "2021-10-01", "2021-07-01",
                              "2023-07-01")),
  expansion_year = c(2019, 2019, 2020, 2020, 2021, 2021, 2023)
)

# Map expansion year to first affected election cycle
# Election cycle 20XX covers Jan (XX-1) through Dec XX
# E.g., 2020 cycle = Jan 2019 - Dec 2020
expansion_states[, first_post_cycle := ifelse(
  month(expansion_date) <= 6,
  year(expansion_date),   # If expand in H1, current cycle is post
  year(expansion_date) + ifelse(year(expansion_date) %% 2 == 0, 0, 1)  # If H2 odd year, next even year
)]
# Simplify: map to FEC 2-year cycles (even years)
expansion_states[, first_post_cycle := ceiling(expansion_year / 2) * 2]

# Never-expanded states (as of Dec 2024)
never_expanded <- c("TX", "FL", "GA", "WI", "WY", "MS", "AL", "SC", "TN", "KS")

# States that expanded BEFORE T-MSIS window (pre-2018) — always-treated, used cautiously
early_expanded <- setdiff(state.abb, c(expansion_states$state, never_expanded))

cat("Late-expansion states:", nrow(expansion_states), "\n")
cat("Never-expanded states:", length(never_expanded), "\n")
cat("Early-expanded states:", length(early_expanded), "\n\n")

# ============================================================================
cat("=== Step 2: Record Linkage — T-MSIS/NPPES to FEC ===\n")

# Strategy: Deterministic matching on (last_name, first_name, state, zip5)
# Then validate with occupation field

# Prepare NPPES side: individual providers only
providers_for_match <- provider_raw[entity_type == "1" & !is.na(last_name) & !is.na(first_name)]
providers_for_match[, `:=`(
  match_last = toupper(str_trim(last_name)),
  match_first = toupper(str_trim(first_name)),
  match_state = toupper(practice_state),
  match_zip5 = substr(practice_zip5, 1, 5)
)]

# Prepare FEC side
fec[, `:=`(
  match_last = toupper(str_trim(donor_last)),
  match_first = toupper(str_trim(donor_first)),
  match_state = toupper(donor_state),
  match_zip5 = donor_zip5
)]

# Unique provider keys
provider_keys <- unique(providers_for_match[, .(npi, match_last, match_first,
                                                  match_state, match_zip5)])

# Unique donor keys (aggregate FEC by donor identity × cycle)
fec_donors <- fec[, .(
  total_amount = sum(amount, na.rm = TRUE),
  n_donations = .N,
  dem_amount = sum(amount[party == "DEM"], na.rm = TRUE),
  rep_amount = sum(amount[party == "REP"], na.rm = TRUE),
  dem_donations = sum(party == "DEM", na.rm = TRUE),
  rep_donations = sum(party == "REP", na.rm = TRUE),
  any_dem = any(party == "DEM", na.rm = TRUE),
  any_rep = any(party == "REP", na.rm = TRUE)
), by = .(match_last, match_first, match_state, match_zip5, cycle, OCCUPATION)]

cat("Provider keys for matching:", nrow(provider_keys), "\n")
cat("FEC donor-cycle records:", nrow(fec_donors), "\n")

# Deterministic match: exact on (last, first, state, zip5)
matched <- merge(provider_keys, fec_donors,
                 by = c("match_last", "match_first", "match_state", "match_zip5"),
                 allow.cartesian = TRUE)

cat("\nDeterministic match results:\n")
cat("  Matched records:", nrow(matched), "\n")
cat("  Unique matched NPIs:", uniqueN(matched$npi), "\n")
cat("  Match rate (NPIs):", round(uniqueN(matched$npi) / nrow(provider_keys) * 100, 1), "%\n")

# Occupation validation: check consistency between NPPES taxonomy and FEC occupation
# This is a soft validation — we report concordance but don't drop mismatches
matched[, occupation_upper := toupper(OCCUPATION)]

# Simple concordance check
matched[, occ_concordant := FALSE]
matched[grepl("PHYSICIAN|DOCTOR|SURGEON|MD|DO", occupation_upper), occ_concordant := TRUE]
matched[grepl("NURSE|RN|NP|LPN", occupation_upper), occ_concordant := TRUE]
matched[grepl("THERAPIST|PT|OT|SPEECH", occupation_upper), occ_concordant := TRUE]
matched[grepl("SOCIAL WORKER|LCSW|MSW", occupation_upper), occ_concordant := TRUE]
matched[grepl("PSYCHOLOG|PSYCHIATR", occupation_upper), occ_concordant := TRUE]
matched[grepl("PHARMAC", occupation_upper), occ_concordant := TRUE]
matched[grepl("DENTIST|DDS|DMD", occupation_upper), occ_concordant := TRUE]
matched[grepl("HEALTH|MEDICAL|HOSPITAL|CLINIC|CARE", occupation_upper), occ_concordant := TRUE]

cat("  Occupation concordance:", round(mean(matched$occ_concordant) * 100, 1), "%\n")

# ============================================================================
cat("\n=== Step 3: Construct Medicaid Dependence ===\n")

# Compute pre-expansion Medicaid revenue by provider
# Use 2018 (the first T-MSIS year, before any late expansions)
pre_medicaid <- provider_raw[year == 2018, .(
  pre_medicaid_paid = sum(medicaid_paid, na.rm = TRUE),
  pre_medicaid_claims = sum(medicaid_claims, na.rm = TRUE),
  pre_hcbs_share = mean(hcbs_share, na.rm = TRUE)
), by = npi]

# Pre-expansion Medicare revenue
pre_medicare <- medicare[year == 2018, .(
  pre_medicare_paid = sum(medicare_paid_total, na.rm = TRUE)
), by = npi]

# Merge
pre_revenue <- merge(pre_medicaid, pre_medicare, by = "npi", all.x = TRUE)
pre_revenue[is.na(pre_medicare_paid), pre_medicare_paid := 0]

# Medicaid dependence = Medicaid / (Medicaid + Medicare)
# If Medicare data is available, use share. Otherwise use log Medicaid paid.
has_medicare <- sum(pre_revenue$pre_medicare_paid > 0) > 100

if (has_medicare) {
  cat("Medicare PUF data available — using Medicaid/(Medicaid+Medicare) share.\n")
  pre_revenue[, medicaid_share := pre_medicaid_paid /
                fifelse(pre_medicaid_paid + pre_medicare_paid > 0,
                       pre_medicaid_paid + pre_medicare_paid, 1)]
} else {
  cat("No Medicare PUF data — using normalized log Medicaid revenue as dependence measure.\n")
  # Use percentile rank of log Medicaid paid as continuous [0,1] measure
  pre_revenue[, medicaid_share := frank(log(pre_medicaid_paid + 1)) / .N]
}

# Quartiles for heterogeneity analysis
pre_revenue[, medicaid_share_q := cut(medicaid_share,
                                       breaks = quantile(medicaid_share, c(0, .25, .5, .75, 1),
                                                         na.rm = TRUE),
                                       labels = c("Q1_low", "Q2", "Q3", "Q4_high"),
                                       include.lowest = TRUE)]

cat("Medicaid dependence distribution:\n")
print(summary(pre_revenue$medicaid_share))
cat("\nBy quartile:\n")
print(pre_revenue[, .(N = .N, mean_share = mean(medicaid_share),
                       mean_paid = mean(pre_medicaid_paid)), by = medicaid_share_q])

# ============================================================================
cat("\n=== Step 4: Build Analysis Panel ===\n")

# Unit: provider × election cycle
# Election cycles: 2018, 2020, 2022, 2024
analysis_cycles <- c(2018, 2020, 2022, 2024)

# Provider-level annual totals (already in provider_raw)
# Aggregate to election cycles (2-year sums)
provider_cycle <- provider_raw[, .(
  cycle = ceiling(year / 2) * 2  # Map year to even cycle year
), by = .(npi, year, medicaid_paid, medicaid_claims, medicaid_beneficiaries,
          hcbs_paid, hcbs_share, entity_type, practice_state, practice_zip5,
          taxonomy_code, credential, gender, last_name, first_name)]

provider_cycle <- provider_cycle[cycle %in% analysis_cycles]

# Aggregate to NPI × cycle
provider_cycle_agg <- provider_cycle[, .(
  medicaid_paid = sum(medicaid_paid, na.rm = TRUE),
  medicaid_claims = sum(medicaid_claims, na.rm = TRUE),
  medicaid_beneficiaries = sum(medicaid_beneficiaries, na.rm = TRUE),
  hcbs_paid = sum(hcbs_paid, na.rm = TRUE)
), by = .(npi, cycle)]

# Merge provider characteristics (use most recent year in cycle)
provider_chars <- provider_raw[, .SD[which.max(year)],
                                by = npi,
                                .SDcols = c("entity_type", "practice_state",
                                            "practice_zip5", "taxonomy_code",
                                            "credential", "gender")]

provider_cycle_agg <- merge(provider_cycle_agg, provider_chars, by = "npi", all.x = TRUE)

# Expand to balanced panel (all NPIs × all cycles) for provider FE
all_combos <- CJ(npi = unique(provider_cycle_agg$npi), cycle = analysis_cycles)
panel <- merge(all_combos, provider_cycle_agg, by = c("npi", "cycle"), all.x = TRUE)

# Fill missing with zeros (provider didn't bill in that cycle)
panel[is.na(medicaid_paid), medicaid_paid := 0]
panel[is.na(medicaid_claims), medicaid_claims := 0]

# Forward-fill provider characteristics
panel[, practice_state := practice_state[!is.na(practice_state)][1], by = npi]

# Add pre-expansion Medicaid dependence (time-invariant)
panel <- merge(panel, pre_revenue[, .(npi, medicaid_share, medicaid_share_q, pre_hcbs_share)],
               by = "npi", all.x = TRUE)

# Add expansion treatment
panel <- merge(panel, expansion_states[, .(state, expansion_year, first_post_cycle)],
               by.x = "practice_state", by.y = "state", all.x = TRUE)

# Treatment indicators
panel[, `:=`(
  expansion_state = practice_state %in% expansion_states$state,
  is_never_expanded = practice_state %in% never_expanded,
  post_expansion = !is.na(first_post_cycle) & cycle >= first_post_cycle,
  # Group for CS-DiD: first post-treatment cycle (or 0 for never-treated)
  cohort = fifelse(!is.na(first_post_cycle), first_post_cycle, 0L)
)]

# DDD interaction
panel[, `:=`(
  treat_ddd = post_expansion * medicaid_share
)]

# Add FEC donation outcomes
donation_outcomes <- matched[, .(
  any_donation = TRUE,
  total_donations = sum(total_amount, na.rm = TRUE),
  n_donations = sum(n_donations, na.rm = TRUE),
  dem_amount = sum(dem_amount, na.rm = TRUE),
  rep_amount = sum(rep_amount, na.rm = TRUE),
  dem_share = sum(dem_amount, na.rm = TRUE) /
    fifelse(sum(total_amount, na.rm = TRUE) > 0, sum(total_amount, na.rm = TRUE), 1),
  any_dem = any(any_dem),
  any_rep = any(any_rep)
), by = .(npi, cycle)]

panel <- merge(panel, donation_outcomes, by = c("npi", "cycle"), all.x = TRUE)

# Fill NAs for non-donors
panel[is.na(any_donation), any_donation := FALSE]
panel[is.na(total_donations), total_donations := 0]
panel[is.na(n_donations), n_donations := 0]
panel[is.na(dem_amount), dem_amount := 0]
panel[is.na(rep_amount), rep_amount := 0]
panel[is.na(dem_share), dem_share := NA_real_]  # Only defined for donors

# Add county FIPS from ZIP5 (using Census ZCTA crosswalk)
# Simplified: first 3 digits of ZIP → approximate state mapping already from NPPES

# Add state unemployment
state_unemp_file <- file.path(LOCAL_DATA, "fred_state_unemp.parquet")
if (file.exists(state_unemp_file)) {
  state_unemp <- read_parquet(state_unemp_file) |> setDT()
  # Average unemployment over 2-year cycle
  state_unemp[, cycle := ceiling(year / 2) * 2]
  state_unemp_cycle <- state_unemp[, .(unemp_rate = mean(unemp_rate, na.rm = TRUE)),
                                    by = .(state, cycle)]
  panel <- merge(panel, state_unemp_cycle,
                 by.x = c("practice_state", "cycle"),
                 by.y = c("state", "cycle"),
                 all.x = TRUE)
}

# ============================================================================
cat("\n=== Step 5: Sample Restrictions ===\n")

# Restrict to individual providers (Entity Type 1)
panel_indiv <- panel[entity_type == "1" | is.na(entity_type)]

# Restrict to states in our design (expansion + never-expanded)
panel_analysis <- panel_indiv[practice_state %in% c(expansion_states$state, never_expanded)]

# Require pre-expansion Medicaid billing (must appear in 2018)
npis_with_pre <- provider_raw[year == 2018 & entity_type == "1", unique(npi)]
panel_analysis <- panel_analysis[npi %in% npis_with_pre]

cat("Sample sizes:\n")
cat("  Full panel:", nrow(panel), "provider-cycles\n")
cat("  Individual providers:", nrow(panel_indiv), "\n")
cat("  In design states:", nrow(panel_analysis), "\n")
cat("  With pre-period billing:", nrow(panel_analysis), "\n")
cat("  Unique providers:", uniqueN(panel_analysis$npi), "\n")
cat("  Unique states:", uniqueN(panel_analysis$practice_state), "\n")
cat("  Donation rate:", round(mean(panel_analysis$any_donation) * 100, 1), "%\n")

# ============================================================================
cat("\n=== Saving analysis panel ===\n")

write_parquet(panel_analysis, file.path(LOCAL_DATA, "analysis_panel.parquet"))
write_parquet(panel, file.path(LOCAL_DATA, "full_panel.parquet"))

# Save linkage quality statistics
linkage_stats <- data.table(
  metric = c("Total individual NPIs in T-MSIS",
             "NPIs matched to FEC (any cycle)",
             "Match rate",
             "Occupation concordance",
             "Total FEC healthcare donations",
             "Unique donors (name × state × zip)",
             "Analysis sample provider-cycles",
             "Analysis sample unique providers",
             "Donation rate in analysis sample"),
  value = c(nrow(provider_keys),
            uniqueN(matched$npi),
            paste0(round(uniqueN(matched$npi) / nrow(provider_keys) * 100, 1), "%"),
            paste0(round(mean(matched$occ_concordant) * 100, 1), "%"),
            nrow(fec),
            uniqueN(fec, by = c("match_last", "match_first", "match_state", "match_zip5")),
            nrow(panel_analysis),
            uniqueN(panel_analysis$npi),
            paste0(round(mean(panel_analysis$any_donation) * 100, 1), "%"))
)

fwrite(linkage_stats, file.path(LOCAL_DATA, "linkage_quality.csv"))
cat("\nLinkage quality:\n")
print(linkage_stats)

cat("\n=== Data cleaning complete ===\n")
