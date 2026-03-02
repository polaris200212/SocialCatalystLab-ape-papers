## 02_clean_data.R — Clean and construct analysis variables
## APEP-0420: The Visible and the Invisible

source("00_packages.R")

data_dir <- "../data"

## Load raw NBI panel
cat("Loading raw NBI panel...\n")
nbi <- fread(file.path(data_dir, "nbi_panel_raw.csv"))
cat(sprintf("Raw observations: %s\n", format(nrow(nbi), big.mark = ",")))

## Standardize column names (NBI naming varies across years)
## Map to clean names
old_names <- names(nbi)
name_map <- c(
  "STATE_CODE_001" = "state_fips",
  "COUNTY_CODE_003" = "county_fips",
  "STRUCTURE_NUMBER_008" = "bridge_id",
  "YEAR_BUILT_027" = "year_built",
  "ADT_029" = "adt",
  "YEAR_ADT_030" = "adt_year",
  "DESIGN_LOAD_031" = "design_load",
  "DECK_COND_058" = "deck_cond",
  "SUPERSTRUCTURE_COND_059" = "super_cond",
  "SUBSTRUCTURE_COND_060" = "sub_cond",
  "CHANNEL_COND_061" = "channel_cond",
  "FUNCTIONAL_CLASS_026" = "func_class",
  "STRUCTURE_KIND_043A" = "struct_kind",
  "STRUCTURE_TYPE_043B" = "struct_type",
  "DECK_AREA_SQ_METER_NBI_COMPUTED" = "deck_area",
  "LAT_016" = "lat",
  "LONG_017" = "lon",
  "MAIN_UNIT_SPANS_045" = "n_spans",
  "MAX_SPAN_LEN_MT_048" = "max_span_m",
  "STRUCTURE_LEN_MT_049" = "total_len_m",
  "DECK_WIDTH_MT_052" = "deck_width_m",
  "SERVICE_ON_042A" = "service_on",
  "SERVICE_UND_042B" = "service_under"
)

for (old_nm in names(name_map)) {
  if (old_nm %in% names(nbi)) {
    setnames(nbi, old_nm, name_map[old_nm])
  }
}

## Clean state/county FIPS
nbi[, state_fips := as.integer(state_fips)]
nbi[, county_fips := as.integer(county_fips)]
nbi[, year := as.integer(nbi_year)]

## Clean condition ratings (0-9 scale, N = not applicable)
for (col in c("deck_cond", "super_cond", "sub_cond", "channel_cond")) {
  if (col %in% names(nbi)) {
    nbi[, (col) := suppressWarnings(as.integer(get(col)))]
  }
}

## Clean numeric fields
for (col in c("adt", "year_built", "deck_area", "n_spans", "max_span_m",
              "total_len_m", "deck_width_m", "design_load")) {
  if (col %in% names(nbi)) {
    nbi[, (col) := suppressWarnings(as.numeric(get(col)))]
  }
}

## Filter to highway bridges on public roads
## Service on = 1 (highway) is the standard filter
if ("service_on" %in% names(nbi)) {
  nbi <- nbi[service_on == 1 | is.na(service_on)]
}

## Remove bridges with missing condition ratings
nbi <- nbi[!is.na(deck_cond) & !is.na(super_cond) & !is.na(sub_cond)]

## Remove condition rating = N (not applicable, coded as NA after conversion)
## and values outside 0-9
for (col in c("deck_cond", "super_cond", "sub_cond")) {
  nbi <- nbi[get(col) >= 0 & get(col) <= 9]
}

## Remove bridges with zero or missing ADT
nbi <- nbi[!is.na(adt) & adt > 0]

## Remove bridges in territories (state FIPS > 56)
nbi <- nbi[state_fips <= 56 & state_fips != 0]

## Remove DC (state FIPS = 11) — no governor elections
nbi <- nbi[state_fips != 11]

cat(sprintf("After cleaning: %s observations\n", format(nrow(nbi), big.mark = ",")))
cat(sprintf("Unique bridges: %s\n", format(length(unique(nbi$bridge_id)), big.mark = ",")))

## Construct key variables

## 1. Bridge age
## Validate year_built: must be in plausible range (1800 to current year)
nbi[year_built < 1800 | year_built > year, year_built := NA]
nbi[, bridge_age := year - year_built]
nbi[bridge_age < 0 | bridge_age > 250, bridge_age := NA]  # data errors

## Clean number of spans (must be positive integer)
nbi[n_spans < 1, n_spans := NA]

## Clean total length (must be positive for bridges with >20ft span)
nbi[total_len_m <= 0, total_len_m := NA]

## Clean max span length
nbi[max_span_m <= 0, max_span_m := NA]

## 2. Minimum condition rating (structurally deficient if < 5)
nbi[, min_cond := pmin(deck_cond, super_cond, sub_cond)]
nbi[, struct_deficient := as.integer(min_cond < 5)]

## 3. Average condition (composite)
nbi[, avg_cond := (deck_cond + super_cond + sub_cond) / 3]

## 4. Log ADT
nbi[, log_adt := log(adt + 1)]

## 5. ADT terciles (within state × year to account for state differences)
nbi[, adt_tercile := cut(adt,
                         breaks = quantile(adt, probs = c(0, 1/3, 2/3, 1), na.rm = TRUE),
                         labels = c("Low", "Medium", "High"),
                         include.lowest = TRUE),
    by = .(state_fips, year)]

nbi[, high_adt := as.integer(adt_tercile == "High")]
nbi[, low_adt := as.integer(adt_tercile == "Low")]

## 6. Initial ADT (first observation for each bridge — predetermined)
initial_adt <- nbi[, .(initial_adt = adt[which.min(year)],
                       initial_year = min(year)),
                   by = bridge_id]
nbi <- merge(nbi, initial_adt, by = "bridge_id", all.x = TRUE)

## Initial ADT terciles (within state)
nbi[, initial_adt_tercile := cut(initial_adt,
                                  breaks = quantile(initial_adt, probs = c(0, 1/3, 2/3, 1), na.rm = TRUE),
                                  labels = c("Low", "Medium", "High"),
                                  include.lowest = TRUE),
    by = state_fips]

nbi[, high_initial_adt := as.integer(initial_adt_tercile == "High")]

## 7. Annual condition change (key outcome)
setorder(nbi, bridge_id, year)
nbi[, deck_change := deck_cond - shift(deck_cond), by = bridge_id]
nbi[, super_change := super_cond - shift(super_cond), by = bridge_id]
nbi[, sub_change := sub_cond - shift(sub_cond), by = bridge_id]
nbi[, avg_cond_change := avg_cond - shift(avg_cond), by = bridge_id]

## 8. Repair event (condition jump of 2+ points in any component)
nbi[, repair_event := as.integer(
  deck_change >= 2 | super_change >= 2 | sub_change >= 2
)]
nbi[is.na(repair_event), repair_event := 0L]

## 9. Deterioration event (condition drop of 1+ in any component)
nbi[, deterioration := as.integer(
  deck_change <= -1 | super_change <= -1 | sub_change <= -1
)]
nbi[is.na(deterioration), deterioration := 0L]

## 10. Functional classification (urban vs rural indicator)
if ("func_class" %in% names(nbi)) {
  nbi[, func_class_num := suppressWarnings(as.integer(func_class))]
  ## NBI functional class: 1-9 rural, 11-19 urban (or 01-09 rural, 11-19 urban)
  nbi[, urban := as.integer(func_class_num >= 11)]
  nbi[is.na(urban), urban := 0L]
}

## 11. Material type (simplified categories)
if ("struct_kind" %in% names(nbi)) {
  nbi[, material := fcase(
    struct_kind %in% c("1", "2"), "Concrete",
    struct_kind %in% c("3", "4"), "Steel",
    struct_kind %in% c("5", "6"), "Prestressed",
    struct_kind %in% c("7"), "Wood",
    default = "Other"
  )]
}

## Merge governor election data
gov_elec <- fread(file.path(data_dir, "governor_elections.csv"))
nbi <- merge(nbi, gov_elec, by.x = c("state_fips", "year"),
             by.y = c("state_fips", "year"), all.x = TRUE)
nbi[is.na(gov_election), gov_election := 0L]

## Pre-election year indicator (year before election)
nbi[, pre_election := as.integer(gov_election == 0 &
                                   shift(gov_election, type = "lead") == 1),
    by = state_fips]
nbi[is.na(pre_election), pre_election := 0L]

## Election window (election year or year before)
nbi[, election_window := as.integer(gov_election == 1 | pre_election == 1)]

## Create state-year cluster ID
nbi[, state_year := paste0(state_fips, "_", year)]

## Summary
cat(sprintf("\nFinal analysis dataset:\n"))
cat(sprintf("  Observations: %s\n", format(nrow(nbi), big.mark = ",")))
cat(sprintf("  Unique bridges: %s\n", format(uniqueN(nbi$bridge_id), big.mark = ",")))
cat(sprintf("  States: %d\n", uniqueN(nbi$state_fips)))
cat(sprintf("  Years: %d-%d\n", min(nbi$year), max(nbi$year)))
cat(sprintf("  High-ADT bridges (initial): %s (%.1f%%)\n",
            format(sum(nbi$high_initial_adt == 1, na.rm = TRUE), big.mark = ","),
            100 * mean(nbi$high_initial_adt == 1, na.rm = TRUE)))
cat(sprintf("  Structurally deficient: %.1f%%\n",
            100 * mean(nbi$struct_deficient == 1, na.rm = TRUE)))
cat(sprintf("  Mean deck condition: %.2f\n", mean(nbi$deck_cond, na.rm = TRUE)))
cat(sprintf("  Mean ADT: %s\n", format(round(mean(nbi$adt)), big.mark = ",")))

## Save cleaned panel
fwrite(nbi, file.path(data_dir, "nbi_panel_clean.csv"))
cat("\nSaved: nbi_panel_clean.csv\n")

## Save summary statistics for the paper
sumstats <- nbi[year >= 2001, .(  # year >= 2001 because condition changes need lag
  N = .N,
  n_bridges = uniqueN(bridge_id),
  mean_deck = mean(deck_cond, na.rm = TRUE),
  sd_deck = sd(deck_cond, na.rm = TRUE),
  mean_super = mean(super_cond, na.rm = TRUE),
  sd_super = sd(super_cond, na.rm = TRUE),
  mean_sub = mean(sub_cond, na.rm = TRUE),
  sd_sub = sd(sub_cond, na.rm = TRUE),
  mean_adt = mean(adt, na.rm = TRUE),
  sd_adt = sd(adt, na.rm = TRUE),
  mean_age = mean(bridge_age, na.rm = TRUE),
  sd_age = sd(bridge_age, na.rm = TRUE),
  pct_deficient = mean(struct_deficient, na.rm = TRUE),
  pct_urban = mean(urban, na.rm = TRUE),
  mean_deck_change = mean(deck_change, na.rm = TRUE),
  sd_deck_change = sd(deck_change, na.rm = TRUE),
  pct_repair = mean(repair_event, na.rm = TRUE),
  pct_deterioration = mean(deterioration, na.rm = TRUE)
)]

fwrite(sumstats, file.path(data_dir, "summary_statistics.csv"))
cat("Saved: summary_statistics.csv\n")
