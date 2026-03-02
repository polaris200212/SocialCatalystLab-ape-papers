## 02_clean_data.R — Clean and merge all data sources
## apep_0486: Progressive Prosecutors, Incarceration, and Public Safety

source("00_packages.R")

cat("=== Loading raw data ===\n")

# --- Vera ---
vera <- fread(file.path(DATA_DIR, "vera_incarceration_trends.csv"))
vera[, fips := str_pad(as.character(fips), width = 5, pad = "0")]
cat("Vera raw:", nrow(vera), "rows\n")

# Aggregate quarterly to annual (take Q4 snapshot for stock measures,
# sum for flow measures)
# Keep only year-level (some rows are quarterly)
# The Vera data has quarterly observations; take Q4 for jail population stock
vera_annual <- vera[quarter == 4 | is.na(quarter), .(
  # Stock measures (point-in-time)
  total_jail_pop       = total_jail_pop[1],
  total_jail_pretrial  = total_jail_pretrial[1],
  total_jail_sentenced = total_jail_sentenced[1],
  black_jail_pop       = black_jail_pop[1],
  white_jail_pop       = white_jail_pop[1],
  latinx_jail_pop      = latinx_jail_pop[1],
  aapi_jail_pop        = aapi_jail_pop[1],
  native_jail_pop      = native_jail_pop[1],
  # Population
  total_pop            = total_pop[1],
  total_pop_15to64     = total_pop_15to64[1],
  black_pop_15to64     = black_pop_15to64[1],
  white_pop_15to64     = white_pop_15to64[1],
  # Rates
  total_jail_pop_rate  = total_jail_pop_rate[1],
  black_jail_pop_rate  = black_jail_pop_rate[1],
  white_jail_pop_rate  = white_jail_pop_rate[1],
  # Flow measures
  total_jail_adm       = total_jail_adm[1],
  # Metadata
  urbanicity           = urbanicity[1],
  region               = region[1],
  county_name          = county_name[1],
  state_abbr           = state_abbr[1]
), by = .(fips, year)]

# If no Q4, fall back to any available quarter
vera_fallback <- vera[, .(
  total_jail_pop       = last(na.omit(total_jail_pop)),
  total_jail_pretrial  = last(na.omit(total_jail_pretrial)),
  total_jail_sentenced = last(na.omit(total_jail_sentenced)),
  black_jail_pop       = last(na.omit(black_jail_pop)),
  white_jail_pop       = last(na.omit(white_jail_pop)),
  latinx_jail_pop      = last(na.omit(latinx_jail_pop)),
  aapi_jail_pop        = last(na.omit(aapi_jail_pop)),
  native_jail_pop      = last(na.omit(native_jail_pop)),
  total_pop            = last(na.omit(total_pop)),
  total_pop_15to64     = last(na.omit(total_pop_15to64)),
  black_pop_15to64     = last(na.omit(black_pop_15to64)),
  white_pop_15to64     = last(na.omit(white_pop_15to64)),
  total_jail_pop_rate  = last(na.omit(total_jail_pop_rate)),
  black_jail_pop_rate  = last(na.omit(black_jail_pop_rate)),
  white_jail_pop_rate  = last(na.omit(white_jail_pop_rate)),
  total_jail_adm       = last(na.omit(total_jail_adm)),
  urbanicity           = last(na.omit(urbanicity)),
  region               = last(na.omit(region)),
  county_name          = last(na.omit(county_name)),
  state_abbr           = last(na.omit(state_abbr))
), by = .(fips, year)]

# Use Q4 where available, fallback otherwise
vera_annual <- vera_annual[!is.na(total_jail_pop)]
vera_fb_needed <- vera_fallback[!paste(fips, year) %in% paste(vera_annual$fips, vera_annual$year)]
vera_fb_needed <- vera_fb_needed[!is.na(total_jail_pop)]
vera_annual <- rbind(vera_annual, vera_fb_needed)

# Restrict to analysis period
vera_annual <- vera_annual[year >= 2005 & year <= 2023]
cat("Vera annual panel:", nrow(vera_annual), "county-years\n")
cat("Unique counties:", length(unique(vera_annual$fips)), "\n")

# Compute rates where missing
vera_annual[, `:=`(
  jail_rate = fifelse(
    !is.na(total_jail_pop_rate), total_jail_pop_rate,
    fifelse(total_pop_15to64 > 0, total_jail_pop / total_pop_15to64 * 100000, NA_real_)
  ),
  black_jail_rate = fifelse(
    !is.na(black_jail_pop_rate), black_jail_pop_rate,
    fifelse(black_pop_15to64 > 0, black_jail_pop / black_pop_15to64 * 100000, NA_real_)
  ),
  white_jail_rate = fifelse(
    !is.na(white_jail_pop_rate), white_jail_pop_rate,
    fifelse(white_pop_15to64 > 0, white_jail_pop / white_pop_15to64 * 100000, NA_real_)
  ),
  pretrial_share = fifelse(total_jail_pop > 0, total_jail_pretrial / total_jail_pop, NA_real_),
  state_fips = substr(fips, 1, 2)
)]

# --- County Health Rankings (Homicide data) ---
cat("\n=== Processing CHR homicide data ===\n")

chr_files <- list.files(DATA_DIR, pattern = "chr_\\d{4}\\.csv", full.names = TRUE)
cat("CHR files found:", length(chr_files), "\n")

chr_list <- list()
for (f in chr_files) {
  yr <- as.integer(str_extract(basename(f), "\\d{4}"))

  tryCatch({
    # Read with flexible parsing (CHR has header row + variable name row)
    raw <- fread(f, header = TRUE, skip = 1, fill = TRUE)

    # Find the relevant columns by position (CHR format is stable)
    # FIPS is in column 3 (5-digit FIPS), homicide raw value varies
    if (ncol(raw) < 100) {
      cat(sprintf("  CHR %d: too few columns (%d), skipping\n", yr, ncol(raw)))
      next
    }

    # Use column names from header
    header <- fread(f, nrows = 1, header = FALSE)
    cnames <- as.character(header[1, ])

    # Find homicide columns
    hom_idx <- grep("Homicides raw value", cnames, ignore.case = TRUE)
    hom_num_idx <- grep("Homicides numerator", cnames, ignore.case = TRUE)
    hom_den_idx <- grep("Homicides denominator", cnames, ignore.case = TRUE)

    # Find FIPS column
    fips_idx <- grep("fipscode|5.digit FIPS", cnames, ignore.case = TRUE)
    if (length(fips_idx) == 0) fips_idx <- 3

    if (length(hom_idx) > 0 && length(fips_idx) > 0) {
      df <- data.frame(
        chr_year = yr,
        fips = as.character(raw[[fips_idx[1]]]),
        homicide_rate = suppressWarnings(as.numeric(raw[[hom_idx[1]]])),
        stringsAsFactors = FALSE
      )

      if (length(hom_num_idx) > 0) {
        df$homicide_numerator <- suppressWarnings(as.numeric(raw[[hom_num_idx[1]]]))
      }
      if (length(hom_den_idx) > 0) {
        df$homicide_denominator <- suppressWarnings(as.numeric(raw[[hom_den_idx[1]]]))
      }

      # Also look for race-specific homicide data
      hom_black_idx <- grep("Homicides.*Black", cnames)
      hom_white_idx <- grep("Homicides.*White", cnames)

      if (length(hom_black_idx) > 0) {
        df$homicide_rate_black <- suppressWarnings(as.numeric(raw[[hom_black_idx[1]]]))
      }
      if (length(hom_white_idx) > 0) {
        df$homicide_rate_white <- suppressWarnings(as.numeric(raw[[hom_white_idx[1]]]))
      }

      # Pad FIPS to 5 digits
      df$fips <- str_pad(df$fips, width = 5, pad = "0")

      # Remove state-level rows and invalid FIPS
      df <- df[nchar(df$fips) == 5 & !is.na(df$homicide_rate) & df$fips != "00000", ]

      chr_list[[as.character(yr)]] <- df
      cat(sprintf("  CHR %d: %d counties with homicide data\n", yr, nrow(df)))
    } else {
      cat(sprintf("  CHR %d: homicide columns not found\n", yr))
    }
  }, error = function(e) {
    cat(sprintf("  CHR %d: ERROR - %s\n", yr, e$message))
  })
}

chr_panel <- bind_rows(chr_list)
cat("CHR homicide panel:", nrow(chr_panel), "county-years\n")

# --- ACS Demographics ---
cat("\n=== Processing ACS demographics ===\n")
acs <- fread(file.path(DATA_DIR, "acs_county_demographics.csv"))
acs[, fips := str_pad(as.character(fips), width = 5, pad = "0")]
cat("ACS panel:", nrow(acs), "county-years\n")

# --- FRED Unemployment ---
cat("\n=== Processing FRED unemployment ===\n")
fred <- fread(file.path(DATA_DIR, "fred_state_unemployment.csv"))
fred[, state_fips := str_pad(as.character(state_fips), width = 2, pad = "0")]
cat("FRED panel:", nrow(fred), "state-years\n")

# --- Treatment indicator ---
cat("\n=== Merging treatment indicator ===\n")
treatment <- fread(file.path(DATA_DIR, "progressive_da_treatment.csv"))
treatment[, fips := str_pad(as.character(fips), width = 5, pad = "0")]
cat("Treatment counties:", nrow(treatment), "\n")

# --- MERGE ALL ---
cat("\n=== Building analysis panel ===\n")

# Start with Vera (most important)
panel <- vera_annual

# Merge treatment
panel <- merge(panel, treatment[, .(fips, treatment_year, da_name)],
               by = "fips", all.x = TRUE)
panel[is.na(treatment_year), treatment_year := 0]  # Never-treated = 0 for CS-DiD

# Create post-treatment indicator
panel[, treated := fifelse(treatment_year > 0 & year >= treatment_year, 1L, 0L)]
panel[, ever_treated := fifelse(treatment_year > 0, 1L, 0L)]

# Merge ACS
panel <- merge(panel, acs, by = c("fips", "year"), all.x = TRUE)

# Merge FRED unemployment
panel <- merge(panel, fred[, .(state_fips, year, unemp_rate)],
               by = c("state_fips", "year"), all.x = TRUE)

# Merge CHR homicide data
chr_dt <- as.data.table(chr_panel)
panel <- merge(panel, chr_dt, by.x = c("fips", "year"),
               by.y = c("fips", "chr_year"), all.x = TRUE)

# Compute derived variables
panel[, `:=`(
  poverty_rate = fifelse(total_pop_acs > 0, poverty_pop / total_pop_acs * 100, NA_real_),
  black_share = fifelse(total_pop_acs > 0, black_pop / total_pop_acs * 100, NA_real_),
  log_pop = log(total_pop + 1),
  log_jail_pop = log(total_jail_pop + 1),
  log_income = log(pmax(median_hh_income, 1)),
  bw_jail_ratio = fifelse(white_jail_rate > 0, black_jail_rate / white_jail_rate, NA_real_)
)]

# Summary stats
cat("\n=== Panel summary ===\n")
cat("Total county-years:", nrow(panel), "\n")
cat("Unique counties:", length(unique(panel$fips)), "\n")
cat("Year range:", range(panel$year), "\n")
cat("Treated county-years:", sum(panel$treated), "\n")
cat("Ever-treated counties:", sum(panel$ever_treated & !duplicated(panel$fips)), "\n")
cat("Never-treated counties:", sum(!panel$ever_treated & !duplicated(panel$fips)), "\n")
cat("Counties with jail data:", sum(!is.na(panel$total_jail_pop) & !duplicated(panel$fips)), "\n")
cat("Counties with homicide data:", sum(!is.na(panel$homicide_rate) & !duplicated(paste(panel$fips, panel$year))), "\n")

# Treated county summary
treated_counties <- panel[ever_treated == 1 & !duplicated(fips)]
cat("\nTreated counties:\n")
for (i in seq_len(nrow(treated_counties))) {
  r <- treated_counties[i]
  jail_obs <- sum(!is.na(panel[fips == r$fips]$total_jail_pop))
  cat(sprintf("  %s (%s, %s): DA=%s, treatment=%d, jail_obs=%d\n",
              r$county_name, r$state_abbr, r$fips, r$da_name, r$treatment_year, jail_obs))
}

# Save
fwrite(panel, file.path(DATA_DIR, "analysis_panel.csv"))
cat("\nAnalysis panel saved:", file.path(DATA_DIR, "analysis_panel.csv"), "\n")

# Also create a "long" panel by race for the DDD analysis
cat("\n=== Creating race-stratified panel for DDD ===\n")

race_panel <- panel[, .(
  fips, year, treatment_year, treated, ever_treated, state_fips,
  county_name, state_abbr, urbanicity, region,
  total_pop, total_pop_15to64,
  black_jail_pop, white_jail_pop,
  black_pop_15to64, white_pop_15to64,
  black_jail_rate, white_jail_rate,
  homicide_rate_black, homicide_rate_white,
  total_jail_pop, jail_rate,
  poverty_rate, black_share, log_pop, unemp_rate
)]

# Reshape to long by race
black_rows <- race_panel[, .(
  fips, year, treatment_year, treated, ever_treated, state_fips,
  county_name, state_abbr, urbanicity, region,
  race = "Black",
  jail_pop = black_jail_pop,
  pop_15to64 = black_pop_15to64,
  jail_rate_race = black_jail_rate,
  homicide_rate_race = homicide_rate_black,
  total_jail_pop, jail_rate,
  poverty_rate, black_share, log_pop, unemp_rate
)]

white_rows <- race_panel[, .(
  fips, year, treatment_year, treated, ever_treated, state_fips,
  county_name, state_abbr, urbanicity, region,
  race = "White",
  jail_pop = white_jail_pop,
  pop_15to64 = white_pop_15to64,
  jail_rate_race = white_jail_rate,
  homicide_rate_race = homicide_rate_white,
  total_jail_pop, jail_rate,
  poverty_rate, black_share, log_pop, unemp_rate
)]

race_long <- rbind(black_rows, white_rows)
race_long[, is_black := fifelse(race == "Black", 1L, 0L)]

cat("Race-stratified panel:", nrow(race_long), "county-year-race observations\n")
fwrite(race_long, file.path(DATA_DIR, "race_panel.csv"))

cat("\n=== DATA CLEANING COMPLETE ===\n")
