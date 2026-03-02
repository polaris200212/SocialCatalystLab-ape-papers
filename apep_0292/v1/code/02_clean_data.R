## 02_clean_data.R — Merge and construct analysis variables
## APEP-0281: Mandatory Energy Disclosure and Property Values (RDD)

source("00_packages.R")

# ============================================================
# 1. Load raw data
# ============================================================
pluto_raw <- readRDS(file.path(data_dir, "pluto_raw.rds"))
ll84_raw <- readRDS(file.path(data_dir, "ll84_raw.rds"))

sales_file <- file.path(data_dir, "sales_raw.rds")
has_sales <- file.exists(sales_file)
if (has_sales) sales_raw <- readRDS(sales_file)

permits_file <- file.path(data_dir, "permits_raw.rds")
has_permits <- file.exists(permits_file)
if (has_permits) permits_raw <- readRDS(permits_file)

# ============================================================
# 2. Clean PLUTO
# ============================================================
cat("Cleaning PLUTO...\n")

pluto <- pluto_raw %>%
  mutate(
    bldgarea = as.numeric(bldgarea),
    lotarea = as.numeric(lotarea),
    assesstot = as.numeric(assesstot),
    assessland = as.numeric(assessland),
    numfloors = as.numeric(numfloors),
    unitsres = as.numeric(unitsres),
    unitstotal = as.numeric(unitstotal),
    yearbuilt = as.numeric(yearbuilt),
    yearalter1 = as.numeric(yearalter1),
    numbldgs = as.numeric(numbldgs)
  ) %>%
  filter(
    !is.na(bldgarea),
    bldgarea > 0,
    !is.na(assesstot),
    assesstot > 0
  ) %>%
  mutate(
    # RDD running variable: distance from 25K threshold
    gfa = bldgarea,
    gfa_centered = gfa - 25000,
    above_threshold = as.integer(gfa >= 25000),

    # Outcome: log assessed value
    log_assesstot = log(assesstot),
    log_assess_per_sqft = log(assesstot / bldgarea),

    # Building age
    building_age = 2020 - yearbuilt,
    building_age = ifelse(building_age < 0 | building_age > 300, NA, building_age),

    # Borough indicator
    borough_name = case_when(
      borough == "1" | toupper(borough) == "MN" ~ "Manhattan",
      borough == "2" | toupper(borough) == "BX" ~ "Bronx",
      borough == "3" | toupper(borough) == "BK" ~ "Brooklyn",
      borough == "4" | toupper(borough) == "QN" ~ "Queens",
      borough == "5" | toupper(borough) == "SI" ~ "Staten Island",
      TRUE ~ borough
    ),

    # Land use categories
    landuse_cat = case_when(
      landuse %in% c("01", "02", "03") ~ "Residential",
      landuse %in% c("04") ~ "Commercial",
      landuse %in% c("05") ~ "Industrial",
      landuse %in% c("06", "07", "08") ~ "Mixed/Institutional",
      landuse %in% c("09") ~ "Open Space",
      landuse %in% c("10", "11") ~ "Parking/Vacant",
      TRUE ~ "Other"
    ),

    # Pre-policy construction (built before LL84 expansion)
    pre_policy_built = as.integer(yearbuilt < 2009)
  )

cat("PLUTO cleaned:", nrow(pluto), "rows with valid GFA and assessed values\n")
cat("Buildings near threshold (20K-30K):", sum(pluto$gfa >= 20000 & pluto$gfa <= 30000), "\n")
cat("Buildings above 25K:", sum(pluto$above_threshold), "\n")
cat("Buildings below 25K:", sum(!pluto$above_threshold), "\n")

# ============================================================
# 3. Clean LL84 — Energy disclosure data
# ============================================================
cat("\nCleaning LL84...\n")

ll84 <- ll84_raw %>%
  mutate(
    property_gfa = as.numeric(property_gfa_calculated),
    site_eui = as.numeric(site_eui_kbtu_ft),
    source_eui = as.numeric(source_eui_kbtu_ft),
    energy_star = as.numeric(energy_star_score),
    ghg_direct = as.numeric(direct_ghg_emissions_metric),
    ghg_indirect = if ("indirect_location_based_ghg" %in% names(.)) as.numeric(indirect_location_based_ghg) else NA_real_,
    report_year = as.numeric(report_year),
    bbl = as.character(nyc_borough_block_and_lot)
  ) %>%
  filter(
    !is.na(property_gfa),
    property_gfa > 0
  )

cat("LL84 cleaned:", nrow(ll84), "rows\n")

# Summarize energy metrics per BBL (most recent year)
ll84_summary <- ll84 %>%
  group_by(bbl) %>%
  arrange(desc(report_year)) %>%
  slice(1) %>%
  ungroup() %>%
  select(bbl, property_gfa, site_eui, source_eui, energy_star,
         ghg_direct, report_year)

cat("LL84 unique properties:", nrow(ll84_summary), "\n")

# ============================================================
# 4. Merge PLUTO with LL84
# ============================================================
cat("\nMerging PLUTO with LL84...\n")

# Normalize BBL: strip trailing decimals from PLUTO format
pluto <- pluto %>%
  mutate(bbl_clean = sub("\\..*", "", bbl))

ll84_summary <- ll84_summary %>%
  mutate(bbl_clean = sub("\\..*", "", bbl))

# Create LL84 compliance indicator
ll84_bbls <- unique(ll84_summary$bbl_clean)
pluto <- pluto %>%
  mutate(
    has_ll84 = as.integer(bbl_clean %in% ll84_bbls)
  )

# Merge energy data for buildings in LL84
pluto_merged <- pluto %>%
  left_join(
    ll84_summary %>% select(bbl_clean, site_eui, source_eui, energy_star, ghg_direct),
    by = "bbl_clean"
  )

cat("PLUTO with LL84 match:", sum(pluto_merged$has_ll84), "of", nrow(pluto_merged), "\n")

# ============================================================
# 5. Clean sales data (if available)
# ============================================================
if (has_sales) {
  cat("\nCleaning sales data...\n")
  # Standardize column names (NYC sales data varies by dataset)
  sales_cols <- tolower(names(sales_raw))
  names(sales_raw) <- sales_cols

  # Find price and BBL columns
  price_col <- names(sales_raw)[grepl("sale.*price|price", names(sales_raw))][1]
  bbl_col <- names(sales_raw)[grepl("^bbl", names(sales_raw))][1]
  date_col <- names(sales_raw)[grepl("sale.*date|date", names(sales_raw))][1]
  gfa_col <- names(sales_raw)[grepl("gross.*sq|square|bldg.*area|gfa", names(sales_raw))][1]

  if (!is.na(price_col)) {
    sales <- sales_raw %>%
      mutate(
        sale_price = as.numeric(.data[[price_col]]),
        bbl_sale = if (!is.na(bbl_col)) as.character(.data[[bbl_col]]) else NA_character_,
        sale_date = if (!is.na(date_col)) as.Date(.data[[date_col]]) else NA
      ) %>%
      filter(
        !is.na(sale_price),
        sale_price > 10000  # Exclude $0 and nominal transfers
      )

    cat("Sales cleaned:", nrow(sales), "valid transactions\n")
    saveRDS(sales, file.path(data_dir, "sales_clean.rds"))
  }
}

# ============================================================
# 6. Clean permits (if available)
# ============================================================
if (has_permits) {
  cat("\nCleaning permits data...\n")
  permits <- permits_raw %>%
    mutate(
      approved_date = as.Date(approved_date),
      bbl_permit = paste0(
        str_pad(borough, 1, "left", "0"),
        str_pad(block, 5, "left", "0"),
        str_pad(lot, 4, "left", "0")
      )
    ) %>%
    filter(!is.na(approved_date))

  # Count permits per BBL in post-policy period (2016+)
  permit_counts <- permits %>%
    filter(approved_date >= as.Date("2016-01-01")) %>%
    group_by(bbl_permit) %>%
    summarise(
      n_permits_post = n(),
      .groups = "drop"
    )

  cat("Permits: ", nrow(permits), " total, ", nrow(permit_counts), " unique BBLs\n")
  saveRDS(permit_counts, file.path(data_dir, "permit_counts.rds"))

  # Merge with PLUTO
  pluto_merged <- pluto_merged %>%
    left_join(permit_counts, by = c("bbl" = "bbl_permit")) %>%
    mutate(n_permits_post = replace_na(n_permits_post, 0),
           has_permit_post = as.integer(n_permits_post > 0))
}

# ============================================================
# 7. Create analysis sample (RDD bandwidth)
# ============================================================
cat("\nCreating RDD analysis sample...\n")

# Broad sample: 5K-50K sq ft (for visual inspection)
rdd_broad <- pluto_merged %>%
  filter(gfa >= 5000, gfa <= 50000)

# Narrow sample: 15K-35K sq ft (primary analysis)
rdd_narrow <- pluto_merged %>%
  filter(gfa >= 15000, gfa <= 35000)

# Very narrow: 20K-30K sq ft (tight bandwidth)
rdd_tight <- pluto_merged %>%
  filter(gfa >= 20000, gfa <= 30000)

cat("Broad sample (5K-50K):", nrow(rdd_broad), "\n")
cat("Narrow sample (15K-35K):", nrow(rdd_narrow), "\n")
cat("Tight sample (20K-30K):", nrow(rdd_tight), "\n")

# ============================================================
# 8. Save analysis datasets
# ============================================================
saveRDS(pluto_merged, file.path(data_dir, "pluto_analysis.rds"))
saveRDS(rdd_broad, file.path(data_dir, "rdd_broad.rds"))
saveRDS(rdd_narrow, file.path(data_dir, "rdd_narrow.rds"))
saveRDS(rdd_tight, file.path(data_dir, "rdd_tight.rds"))

# ============================================================
# 9. Summary statistics
# ============================================================
cat("\n=== Summary Statistics ===\n")
cat("Total buildings in PLUTO:", nrow(pluto_merged), "\n")
cat("Buildings with LL84 data:", sum(pluto_merged$has_ll84), "\n")
cat("\nBy threshold status (narrow sample 15K-35K):\n")
rdd_narrow %>%
  group_by(above_threshold) %>%
  summarise(
    n = n(),
    mean_gfa = mean(gfa),
    mean_assess = mean(assesstot, na.rm = TRUE),
    mean_log_assess = mean(log_assesstot, na.rm = TRUE),
    mean_year_built = mean(yearbuilt, na.rm = TRUE),
    mean_floors = mean(numfloors, na.rm = TRUE),
    pct_residential = mean(landuse_cat == "Residential", na.rm = TRUE),
    .groups = "drop"
  ) %>%
  print()

cat("\nData cleaning complete.\n")
