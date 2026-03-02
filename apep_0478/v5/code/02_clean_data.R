# =============================================================================
# 02_clean_data.R — Going Up Alone v4 (apep_0478)
# Construct analysis variables and prepare datasets
# v4: All rates as per-10k employed (cleaned denominator), county/metro,
#     borough identification, entry analysis, full arc (1900-1980)
# =============================================================================

source("00_packages.R")

cat("\n========================================\n")
cat("CLEANING AND CONSTRUCTING VARIABLES (v4)\n")
cat("========================================\n\n")

# ─────────────────────────────────────────────────────────────────────────────
# Load raw data
# ─────────────────────────────────────────────────────────────────────────────

state_panel  <- fread(file.path(DATA_DIR, "state_panel.csv"))
national_raw <- fread(file.path(DATA_DIR, "national_aggregates.csv"))
nyc_detail   <- fread(file.path(DATA_DIR, "nyc_borough_detail.csv"))
linked_bldg  <- fread(file.path(DATA_DIR, "linked_bldg_service_1940_1950.csv"))

# Load post-1950 data if available
post1950_file <- file.path(DATA_DIR, "post1950_aggregates.csv")
has_post1950 <- file.exists(post1950_file)
if (has_post1950) {
  post1950 <- fread(post1950_file)
  cat("  Post-1950 data loaded.\n")
}

# Load county data if available
county_file <- file.path(DATA_DIR, "county_panel.csv")
has_county <- file.exists(county_file)
if (has_county) {
  county_panel <- fread(county_file)
  cat("  County panel loaded.\n")
}

# Load metro panel if available
metro_file <- file.path(DATA_DIR, "metro_panel.csv")
has_metro <- file.exists(metro_file)
if (has_metro) {
  metro_panel <- fread(metro_file)
  cat("  Metro panel loaded.\n")
}

# Load entrants data if available
entrants_file <- file.path(DATA_DIR, "entrants_1940_1950.csv")
has_entrants <- file.exists(entrants_file)
if (has_entrants) {
  entrants <- fread(entrants_file)
  cat("  Entrants data loaded.\n")
}

# ─────────────────────────────────────────────────────────────────────────────
# PART 1: National descriptive variables
# v4: All rates use cleaned employed denominator
# ─────────────────────────────────────────────────────────────────────────────

cat("Part 1: National descriptive variables...\n")

national_raw[, `:=`(
  elev_per_10k_pop     = n_elevator_ops / total_pop * 10000,
  elev_per_10k_emp     = n_elevator_ops / total_employed * 10000,
  pct_female           = n_elev_female / n_elevator_ops * 100,
  pct_black            = n_elev_black / n_elevator_ops * 100,
  pct_other_race       = n_elev_other_race / n_elevator_ops * 100,
  pct_under20          = n_elev_under20 / n_elevator_ops * 100,
  pct_20s              = n_elev_20s / n_elevator_ops * 100,
  pct_30s              = n_elev_30s / n_elevator_ops * 100,
  pct_40s              = n_elev_40s / n_elevator_ops * 100,
  pct_50s              = n_elev_50s / n_elevator_ops * 100,
  pct_60plus           = n_elev_60plus / n_elevator_ops * 100,
  janitor_per_10k_emp  = n_janitors / total_employed * 10000,
  porter_per_10k_emp   = n_porters / total_employed * 10000,
  guard_per_10k_emp    = n_guards / total_employed * 10000
)]

fwrite(national_raw, file.path(DATA_DIR, "national_clean.csv"))

# ─────────────────────────────────────────────────────────────────────────────
# PART 1b: Build full arc (1900-1980) by combining full-count + PUMS
# ─────────────────────────────────────────────────────────────────────────────

cat("Part 1b: Full arc (1900-1980)...\n")

full_arc <- national_raw[, .(
  year, n_elevator_ops, total_employed, elev_per_10k_emp,
  janitor_per_10k_emp, porter_per_10k_emp, guard_per_10k_emp,
  pct_female, pct_black, mean_age_elev, source = "full-count"
)]

if (has_post1950) {
  post_arc <- post1950[, .(
    year,
    n_elevator_ops = as.integer(n_elevator_ops),
    total_employed = as.integer(total_employed),
    elev_per_10k_emp,
    janitor_per_10k_emp, porter_per_10k_emp, guard_per_10k_emp,
    source = "Census published statistics"
  )]
  full_arc <- rbind(full_arc, post_arc, fill = TRUE)
}

setorder(full_arc, year)
fwrite(full_arc, file.path(DATA_DIR, "full_arc_1900_1980.csv"))
cat("  Full arc:\n")
print(full_arc[, .(year, n_elevator_ops, elev_per_10k_emp, source)])

# ─────────────────────────────────────────────────────────────────────────────
# PART 2: State-level panel
# ─────────────────────────────────────────────────────────────────────────────

cat("\nPart 2: State-level panel...\n")

state_panel[, `:=`(
  elev_per_1k_bldg = ifelse(n_bldg_service_all > 0,
                            n_elevator_ops / n_bldg_service_all * 1000, NA),
  elev_per_10k_pop = n_elevator_ops / total_pop * 10000,
  elev_per_10k_emp = ifelse(total_employed > 0,
                            n_elevator_ops / total_employed * 10000, NA),
  pct_elev_young   = ifelse(n_elevator_ops > 0,
                            n_elev_young / n_elevator_ops * 100, NA),
  pct_elev_old     = ifelse(n_elevator_ops > 0,
                            n_elev_old / n_elevator_ops * 100, NA),
  pct_elev_female  = ifelse(n_elevator_ops > 0,
                            n_elev_female / n_elevator_ops * 100, NA),
  pct_elev_black   = ifelse(n_elevator_ops > 0,
                            n_elev_black / n_elevator_ops * 100, NA),
  mfg_share        = n_manufacturing / total_employed,
  foreign_share    = n_foreign_born / total_pop,
  log_pop          = log(total_pop)
)]

# State name labels
state_labels <- data.table(
  STATEFIP = c(1, 2, 4, 5, 6, 8, 9, 10, 11, 12, 13, 15, 16, 17, 18, 19, 20,
               21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36,
               37, 38, 39, 40, 41, 42, 44, 45, 46, 47, 48, 49, 50, 51, 53, 54, 55, 56),
  state_name = c("Alabama", "Alaska", "Arizona", "Arkansas", "California",
                 "Colorado", "Connecticut", "Delaware", "DC", "Florida",
                 "Georgia", "Hawaii", "Idaho", "Illinois", "Indiana", "Iowa",
                 "Kansas", "Kentucky", "Louisiana", "Maine", "Maryland",
                 "Massachusetts", "Michigan", "Minnesota", "Mississippi",
                 "Missouri", "Montana", "Nebraska", "Nevada", "New Hampshire",
                 "New Jersey", "New Mexico", "New York", "North Carolina",
                 "North Dakota", "Ohio", "Oklahoma", "Oregon", "Pennsylvania",
                 "Rhode Island", "South Carolina", "South Dakota", "Tennessee",
                 "Texas", "Utah", "Vermont", "Virginia", "Washington",
                 "West Virginia", "Wisconsin", "Wyoming")
)

state_panel <- merge(state_panel, state_labels, by = "STATEFIP", all.x = TRUE)
state_panel[, is_nyc := STATEFIP == 36]
state_panel[, treated := as.integer(is_nyc & year >= 1950)]
state_panel[, post := as.integer(year >= 1950)]

# Filter for states with sufficient data
state_coverage <- state_panel[, .(
  n_years = uniqueN(year),
  max_ops = max(n_elevator_ops)
), by = STATEFIP]
good_states <- state_coverage[n_years >= 5 & max_ops >= 50]$STATEFIP

scm_panel <- state_panel[STATEFIP %in% good_states]
cat(sprintf("  SCM panel: %d rows (%d states)\n",
    nrow(scm_panel), length(good_states)))

fwrite(scm_panel, file.path(DATA_DIR, "scm_panel.csv"))

# ─────────────────────────────────────────────────────────────────────────────
# PART 2b: NYC borough panel
# ─────────────────────────────────────────────────────────────────────────────

cat("Part 2b: NYC borough panel...\n")

nyc_detail[, elev_per_10k_emp := ifelse(total_employed > 0,
                                         n_elevator_ops / total_employed * 10000, NA)]
nyc_detail[, pct_female := ifelse(n_elevator_ops > 0,
                                   n_elev_female / n_elevator_ops * 100, NA)]
nyc_detail[, pct_black := ifelse(n_elevator_ops > 0,
                                  n_elev_black / n_elevator_ops * 100, NA)]

cat("  Borough summary (1940):\n")
print(nyc_detail[year == 1940, .(borough, n_elevator_ops, total_employed,
                                  elev_per_10k_emp)])

fwrite(nyc_detail, file.path(DATA_DIR, "nyc_borough_clean.csv"))

# ─────────────────────────────────────────────────────────────────────────────
# PART 3: Linked panel — individual displacement variables
# ─────────────────────────────────────────────────────────────────────────────

cat("\nPart 3: Individual displacement variables...\n")

linked_bldg <- as.data.table(linked_bldg)

# Create derived variables
linked_bldg[, `:=`(
  is_elevator_1940 = as.integer(occ1950_1940 == OCC_ELEVATOR),
  is_janitor_1940  = as.integer(occ1950_1940 == OCC_JANITOR),
  is_porter_1940   = as.integer(occ1950_1940 == OCC_PORTER),
  is_guard_1940    = as.integer(occ1950_1940 == OCC_GUARD),

  still_elevator_1950 = as.integer(occ1950_1950 == OCC_ELEVATOR),
  still_bldg_service  = as.integer(occ1950_1950 %in% BLDG_SERVICE_OCCS),
  stayed_same_occ     = as.integer(occ1950_1950 == occ1950_1940),

  is_female = as.integer(sex_1940 == 2),
  is_black  = as.integer(race_1940 == 2),
  is_white  = as.integer(race_1940 == 1),
  is_native = as.integer(bpl_1940 < 100),

  age_group_1940 = cut(age_1940,
                       breaks = c(0, 20, 30, 40, 50, 60, 100),
                       labels = c("<20", "20-29", "30-39", "40-49", "50-59", "60+"),
                       right = FALSE),

  is_nyc_1940 = as.integer(statefip_1940 == 36 & countyicp_1940 %in% NYC_COUNTYICP),

  # v4: Borough identification
  borough_1940 = fcase(
    statefip_1940 == 36 & countyicp_1940 == 610, "Manhattan",
    statefip_1940 == 36 & countyicp_1940 == 470, "Brooklyn",
    statefip_1940 == 36 & countyicp_1940 == 810, "Queens",
    statefip_1940 == 36 & countyicp_1940 == 50,  "Bronx",
    statefip_1940 == 36 & countyicp_1940 == 850, "Staten Island",
    default = NA_character_
  )
)]

# Occupational transition: broad categories
linked_bldg[, occ_broad_1950 := fcase(
  occ1950_1950 == 761, "Elevator operator",
  occ1950_1950 %in% c(770, 780, 763, 753, 764), "Other building service",
  occ1950_1950 >= 700 & occ1950_1950 < 800 & !(occ1950_1950 %in% c(761, 770, 780, 763, 753, 764)), "Other service worker",
  occ1950_1950 >= 500 & occ1950_1950 < 600, "Craftsman",
  occ1950_1950 >= 300 & occ1950_1950 < 500, "Operative/manufacturing",
  occ1950_1950 >= 200 & occ1950_1950 < 300, "Clerical/sales",
  occ1950_1950 >= 100 & occ1950_1950 < 200, "Manager/proprietor",
  occ1950_1950 >= 0   & occ1950_1950 < 100, "Professional/technical",
  occ1950_1950 >= 800 & occ1950_1950 < 900, "Laborer",
  occ1950_1950 >= 900 & occ1950_1950 < 980, "Farm worker",
  occ1950_1950 == 0 | occ1950_1950 >= 980, "Not in labor force",
  default = "Other"
)]

linked_bldg[, occscore_change := occscore_1950 - occscore_1940]

cat(sprintf("  Linked panel: %s individuals\n", format(nrow(linked_bldg), big.mark = ",")))
cat(sprintf("  Elevator operators (1940): %s\n",
    format(sum(linked_bldg$is_elevator_1940), big.mark = ",")))

fwrite(linked_bldg, file.path(DATA_DIR, "linked_panel_clean.csv"))

# ─────────────────────────────────────────────────────────────────────────────
# PART 4: Transition matrices (all dimensions)
# ─────────────────────────────────────────────────────────────────────────────

cat("Part 4: Transition matrices...\n")

elev_1940 <- linked_bldg[is_elevator_1940 == 1]

trans_matrix <- elev_1940[, .N, by = occ_broad_1950]
trans_matrix[, pct := N / sum(N) * 100]
setorder(trans_matrix, -N)
cat("  Elevator operator transition (1940 → 1950):\n")
print(trans_matrix)
fwrite(trans_matrix, file.path(DATA_DIR, "transition_matrix.csv"))

# By race
trans_by_race <- elev_1940[, .N, by = .(is_black, occ_broad_1950)]
trans_by_race[, pct := N / sum(N) * 100, by = is_black]
fwrite(trans_by_race, file.path(DATA_DIR, "transition_by_race.csv"))

# By sex
trans_by_sex <- elev_1940[, .N, by = .(is_female, occ_broad_1950)]
trans_by_sex[, pct := N / sum(N) * 100, by = is_female]
fwrite(trans_by_sex, file.path(DATA_DIR, "transition_by_sex.csv"))

# By age
trans_by_age <- elev_1940[, .N, by = .(age_group_1940, occ_broad_1950)]
trans_by_age[, pct := N / sum(N) * 100, by = age_group_1940]
fwrite(trans_by_age, file.path(DATA_DIR, "transition_by_age.csv"))

# By NYC status
trans_by_city <- elev_1940[, .N, by = .(is_nyc_1940, occ_broad_1950)]
trans_by_city[, pct := N / sum(N) * 100, by = is_nyc_1940]
fwrite(trans_by_city, file.path(DATA_DIR, "transition_by_city.csv"))

# v4: By borough (NYC only)
if (any(!is.na(elev_1940$borough_1940))) {
  trans_by_borough <- elev_1940[!is.na(borough_1940), .N, by = .(borough_1940, occ_broad_1950)]
  trans_by_borough[, pct := N / sum(N) * 100, by = borough_1940]
  fwrite(trans_by_borough, file.path(DATA_DIR, "transition_by_borough.csv"))
  cat("  Borough transitions saved.\n")

  # Borough persistence summary
  borough_persist <- elev_1940[!is.na(borough_1940), .(
    n = .N,
    exit_rate = mean(still_elevator_1950 == 0),
    mean_occscore_change = mean(occscore_change, na.rm = TRUE),
    pct_black = mean(is_black) * 100
  ), by = borough_1940]
  setorder(borough_persist, -exit_rate)
  cat("  Borough persistence:\n")
  print(borough_persist)
  fwrite(borough_persist, file.path(DATA_DIR, "borough_persistence.csv"))
}

# ─────────────────────────────────────────────────────────────────────────────
# PART 5: Entry analysis — who became elevator operators?
# ─────────────────────────────────────────────────────────────────────────────

if (has_entrants) {
  cat("\nPart 5: Entry analysis...\n")

  entrants <- as.data.table(entrants)
  entrants[, `:=`(
    is_female = as.integer(sex_1940 == 2),
    is_black = as.integer(race_1940 == 2),
    is_nyc = as.integer(statefip_1940 == 36 & countyicp_1940 %in% NYC_COUNTYICP),
    occscore_change = occscore_1950 - occscore_1940
  )]

  # Broad occupation in 1940 (before entering)
  entrants[, occ_broad_1940 := fcase(
    occ1950_1940 %in% c(770, 780, 763, 753, 764), "Other building service",
    occ1950_1940 >= 700 & occ1950_1940 < 800, "Other service worker",
    occ1950_1940 >= 500 & occ1950_1940 < 600, "Craftsman",
    occ1950_1940 >= 300 & occ1950_1940 < 500, "Operative/manufacturing",
    occ1950_1940 >= 200 & occ1950_1940 < 300, "Clerical/sales",
    occ1950_1940 >= 100 & occ1950_1940 < 200, "Manager/proprietor",
    occ1950_1940 >= 0   & occ1950_1940 < 100, "Professional/technical",
    occ1950_1940 >= 800 & occ1950_1940 < 900, "Laborer",
    occ1950_1940 >= 900 & occ1950_1940 < 980, "Farm worker",
    occ1950_1940 == 0 | occ1950_1940 >= 980, "Not in labor force",
    default = "Other"
  )]

  # Summary: where did entrants come from?
  entry_origins <- entrants[, .N, by = occ_broad_1940]
  entry_origins[, pct := N / sum(N) * 100]
  setorder(entry_origins, -N)
  cat("  Entry origins:\n")
  print(entry_origins)
  fwrite(entry_origins, file.path(DATA_DIR, "entry_origins.csv"))

  # Demographics of entrants
  entry_demo <- entrants[, .(
    n = .N,
    mean_age = mean(age_1940),
    pct_black = mean(is_black) * 100,
    pct_female = mean(is_female) * 100,
    pct_nyc = mean(is_nyc) * 100,
    mean_occscore_change = mean(occscore_change)
  )]
  cat("  Entrant demographics:\n")
  print(entry_demo)
  fwrite(entry_demo, file.path(DATA_DIR, "entry_demographics.csv"))
}

cat("\n========================================\n")
cat("DATA CLEANING COMPLETE\n")
cat("========================================\n")
