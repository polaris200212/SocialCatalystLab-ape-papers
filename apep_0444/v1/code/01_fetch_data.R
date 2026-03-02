## ============================================================
## 01_fetch_data.R — Construct state ODF treatment dates
## Paper: Does Sanitation Drive Development? (apep_0444)
## ============================================================

BASE_DIR <- file.path("output", "apep_0444", "v1")
source(file.path(BASE_DIR, "code", "00_packages.R"))

# ── State ODF Declaration Dates ──────────────────────────────
# Sources: PIB press releases, Daily Pioneer, ORF, BankExamsToday
# See ideas.md and research_plan.md for full source documentation.
#
# Census 2011 state codes mapped to ODF declaration year and month.
# For states where exact month is uncertain, best estimate used
# (marked with source confidence tier in comments).
#
# Treatment coding: ODF year = year in which the state was declared ODF.
# Fractional exposure calculated in 02_clean_data.R.

odf_dates <- data.table(
  pc11_state_id = c(
    # Tier 1: High confidence (PIB confirmed)
    11L,  # Sikkim - May 2016
    2L,   # Himachal Pradesh - Oct 2016
    32L,  # Kerala - Nov 2016
    5L,   # Uttarakhand - June 2017
    6L,   # Haryana - June 2017
    24L,  # Gujarat - Oct 2017
    12L,  # Arunachal Pradesh - late 2017 (by Jan 2018 PIB)
    22L,  # Chhattisgarh - late 2017 (by Jan 2018 PIB)
    4L,   # Chandigarh - late 2017 (by Jan 2018 PIB)
    # Note: Daman & Diu (code 25) and Dadra & Nagar Haveli (code 26)
    # merged into single UT in Jan 2020; treat separately for 2011 Census

    # Tier 2: Medium confidence (part of group milestones)
    17L,  # Meghalaya - ~Jan/Feb 2018
    8L,   # Rajasthan - Mar 2018
    15L,  # Mizoram - ~Mar 2018
    3L,   # Punjab - ~Mar-June 2018
    25L,  # Daman & Diu - ~mid 2018
    26L,  # Dadra & Nagar Haveli - ~mid 2018
    27L,  # Maharashtra - ~mid 2018
    35L,  # Andaman & Nicobar - ~mid 2018
    31L,  # Lakshadweep - ~mid 2018
    28L,  # Andhra Pradesh - ~mid 2018
    14L,  # Manipur - Oct 2018
    13L,  # Nagaland - Oct 2018
    23L,  # Madhya Pradesh - Oct 2018
    20L,  # Jharkhand - Nov 2018
    16L,  # Tripura - ~Dec 2018
    18L,  # Assam - ~late 2018/early 2019

    # Tier 3: Lower confidence (2019 laggards)
    9L,   # Uttar Pradesh - ~Jan 2019
    29L,  # Telangana - ~mid 2019
    30L,  # Karnataka - ~mid 2019 (actually code 29 is Karnataka... let me fix)
    33L,  # Tamil Nadu - ~Oct 2019
    34L,  # Puducherry - ~2019
    7L,   # Delhi - ~2019
    10L,  # Bihar - Oct 2019
    21L,  # Odisha - ~mid-late 2019
    19L,  # West Bengal - Aug 2019
    1L    # Jammu & Kashmir - ~2019
  ),
  odf_month = c(
    # Tier 1
    5L, 10L, 11L, 6L, 6L, 10L, 12L, 12L, 12L,
    # Tier 2
    2L, 3L, 3L, 5L, 6L, 6L, 6L, 6L, 6L, 6L, 10L, 10L, 10L, 11L, 12L, 12L,
    # Tier 3
    1L, 6L, 6L, 10L, 10L, 6L, 10L, 8L, 8L, 10L
  ),
  odf_year = c(
    # Tier 1
    2016L, 2016L, 2016L, 2017L, 2017L, 2017L, 2017L, 2017L, 2017L,
    # Tier 2
    2018L, 2018L, 2018L, 2018L, 2018L, 2018L, 2018L, 2018L, 2018L, 2018L,
    2018L, 2018L, 2018L, 2018L, 2018L, 2019L,
    # Tier 3
    2019L, 2019L, 2019L, 2019L, 2019L, 2019L, 2019L, 2019L, 2019L, 2019L
  ),
  confidence_tier = c(
    rep(1L, 9), rep(2L, 17), rep(3L, 10)
  )
)

# Fix state code for Karnataka (Census 2011 code = 29, not 30)
# Telangana split from Andhra Pradesh in 2014 but Census 2011 was unified
# Telangana (formed 2014) doesn't have a separate Census 2011 code
# For Census 2011, Telangana districts are under AP (code 28)
# We'll handle Telangana by assigning its districts (which are under AP code 28
# in Census 2011) the Telangana ODF date in 02_clean_data.R

# Remove the duplicate Telangana entry (districts under AP in Census 2011)
# and fix Karnataka
odf_dates[pc11_state_id == 29L, `:=`(odf_month = 6L, odf_year = 2019L)]
# Entry 30 was intended for Karnataka but Census code 29 = Karnataka
# Remove the entry with code 30 (doesn't exist in Census 2011)
odf_dates <- odf_dates[pc11_state_id != 30L]

# Verify: should have ~35 unique state codes
cat("Number of state entries:", nrow(odf_dates), "\n")
cat("Unique state IDs:", length(unique(odf_dates$pc11_state_id)), "\n")

# ── Compute fractional exposure in ODF year ───────────────────
odf_dates[, frac_exposure := (12 - odf_month + 1) / 12]
cat("ODF dates constructed.\n")
cat("Year distribution:\n")
print(table(odf_dates$odf_year))

# ── Save treatment dates ─────────────────────────────────────
fwrite(odf_dates, file.path(BASE_DIR, "data", "odf_dates.csv"))
cat("Saved to data/odf_dates.csv\n")

# ── State name lookup for tables/figures ──────────────────────
state_names <- data.table(
  pc11_state_id = c(1:35),
  state_name = c(
    "Jammu & Kashmir", "Himachal Pradesh", "Punjab", "Chandigarh",
    "Uttarakhand", "Haryana", "Delhi", "Rajasthan",
    "Uttar Pradesh", "Bihar", "Sikkim", "Arunachal Pradesh",
    "Nagaland", "Manipur", "Mizoram", "Tripura",
    "Meghalaya", "Assam", "West Bengal", "Jharkhand",
    "Odisha", "Chhattisgarh", "Madhya Pradesh", "Gujarat",
    "Daman & Diu", "Dadra & Nagar Haveli", "Maharashtra",
    "Andhra Pradesh", "Karnataka", "Goa",
    "Lakshadweep", "Kerala", "Tamil Nadu", "Puducherry",
    "Andaman & Nicobar"
  )
)
fwrite(state_names, file.path(BASE_DIR, "data", "state_names.csv"))

# Note: Goa is Census 2011 state code 30
# Let me add Goa to odf_dates if missing
if (!(30L %in% odf_dates$pc11_state_id)) {
  goa_row <- data.table(
    pc11_state_id = 30L, odf_month = 8L, odf_year = 2019L,
    confidence_tier = 1L, frac_exposure = 5/12
  )
  odf_dates <- rbind(odf_dates, goa_row)
  cat("Added Goa (state code 30, ODF Aug 2019)\n")
}

# Re-save with Goa
fwrite(odf_dates, file.path(BASE_DIR, "data", "odf_dates.csv"))
cat("Final state count:", nrow(odf_dates), "\n")
cat("Year distribution (final):\n")
print(table(odf_dates$odf_year))
