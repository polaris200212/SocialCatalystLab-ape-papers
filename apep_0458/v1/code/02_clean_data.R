## 02_clean_data.R — Data cleaning and variable construction
## APEP-0458: Second Home Caps and Local Labor Markets

source("code/00_packages.R")

cat("\n=== CLEANING DATA ===\n")

# ---------------------------------------------------------------------------
# 1. Clean ZWA (Second Home Share) — Running Variable
# ---------------------------------------------------------------------------
cat("1. Cleaning ZWA data...\n")
zwa <- fread("data/zwa_current.csv")

# Key variables:
# gemeinde_nr = BFS municipality number
# zwa_pct = second home share (%)
# total_dwellings = total housing units
# primary_dwellings = primary residence count
# status: 0 = below 20%, 1 = above 20%

cat("  Municipalities:", nrow(zwa), "\n")
cat("  ZWA range:", round(min(zwa$zwa_pct, na.rm = TRUE), 1), "to",
    round(max(zwa$zwa_pct, na.rm = TRUE), 1), "%\n")
cat("  Above 20% (treated):", sum(zwa$zwa_pct >= 20, na.rm = TRUE), "\n")
cat("  Below 20% (control):", sum(zwa$zwa_pct < 20, na.rm = TRUE), "\n")

# Create RDD running variable (centered at 20%)
zwa[, running := zwa_pct - 20]
zwa[, treated := as.integer(zwa_pct >= 20)]

# ---------------------------------------------------------------------------
# 2. Clean STATENT (Employment) — Primary Outcome
# ---------------------------------------------------------------------------
cat("\n2. Cleaning STATENT data...\n")
statent <- fread("data/statent_municipal_raw.csv")

cat("  Raw rows:", nrow(statent), "\n")
cat("  Columns:", paste(names(statent), collapse = ", "), "\n")

# Reshape: one row per municipality-year with sector columns
# Sector codes: 999=Total, 1=Primary, 2=Secondary, 3=Tertiary
# Measure codes: 2=Beschäftigte (employees), 5=VZÄ (FTE)

statent[, gemeinde := as.integer(gemeinde)]
statent[, year := as.integer(year)]

# Filter to total employment (measure = 2 = Beschäftigte)
emp <- statent[measure == "2"]
emp_wide <- dcast(emp, year + gemeinde ~ sektor, value.var = "value")
# dcast sorts by sektor: 1=Primary, 2=Secondary, 3=Tertiary, 999=Total
setnames(emp_wide, c("year", "gemeinde_nr", "emp_primary",
                      "emp_secondary", "emp_tertiary", "emp_total"))

# Also get FTE (measure = 5)
fte <- statent[measure == "5"]
fte_wide <- dcast(fte, year + gemeinde ~ sektor, value.var = "value")
# dcast sorts by sektor: 1=Primary, 2=Secondary, 3=Tertiary, 999=Total
setnames(fte_wide, c("year", "gemeinde_nr", "fte_primary",
                      "fte_secondary", "fte_tertiary", "fte_total"))

# Merge employees and FTE
employment <- merge(emp_wide, fte_wide, by = c("year", "gemeinde_nr"), all = TRUE)

cat("  Employment panel: ", nrow(employment), "rows,",
    uniqueN(employment$gemeinde_nr), "municipalities,",
    uniqueN(employment$year), "years\n")

# Compute sector shares
employment[, share_primary := emp_primary / emp_total]
employment[, share_secondary := emp_secondary / emp_total]
employment[, share_tertiary := emp_tertiary / emp_total]

# Log employment
employment[, log_emp_total := log(emp_total + 1)]
employment[, log_emp_secondary := log(emp_secondary + 1)]
employment[, log_emp_tertiary := log(emp_tertiary + 1)]

# ---------------------------------------------------------------------------
# 3. Clean Tourism Data
# ---------------------------------------------------------------------------
cat("\n3. Cleaning tourism data...\n")

if (file.exists("data/hesta_municipal_raw.csv")) {
  tourism <- fread("data/hesta_municipal_raw.csv")

  # indicator: 1 = arrivals, 2 = overnight stays
  tourism[, gemeinde_nr := as.integer(gemeinde)]
  tourism[, year := as.integer(year)]

  tourism_wide <- dcast(tourism, year + gemeinde_nr ~ indicator,
                        value.var = "value")
  setnames(tourism_wide, c("year", "gemeinde_nr", "arrivals", "overnights"))

  tourism_wide[, log_overnights := log(overnights + 1)]
  tourism_wide[, log_arrivals := log(arrivals + 1)]

  cat("  Tourism panel:", nrow(tourism_wide), "rows,",
      uniqueN(tourism_wide$gemeinde_nr), "municipalities\n")
}

# ---------------------------------------------------------------------------
# 4. Clean Canton NOGA (for construction/accommodation detail)
# ---------------------------------------------------------------------------
cat("\n4. Cleaning canton NOGA data...\n")

if (file.exists("data/statent_canton_noga_raw.csv")) {
  canton_noga <- fread("data/statent_canton_noga_raw.csv")

  # NOGA: 999=Total, 41=Building construction, 42=Civil engineering,
  # 43=Specialized construction, 55=Accommodation, 56=Food/beverage
  canton_noga[, year := as.integer(year)]
  canton_noga[, kanton := as.integer(kanton)]

  # Create construction aggregate (41+42+43) and accommodation (55+56)
  canton_emp <- canton_noga[measure == "2"]  # Beschäftigte

  construction <- canton_emp[noga %in% c("41", "42", "43"),
                             .(emp_construction = sum(value, na.rm = TRUE)),
                             by = .(year, kanton)]
  accommodation <- canton_emp[noga %in% c("55", "56"),
                              .(emp_accommodation = sum(value, na.rm = TRUE)),
                              by = .(year, kanton)]
  total_canton <- canton_emp[noga == "999",
                             .(emp_total_canton = value),
                             by = .(year, kanton)]

  canton_sectors <- Reduce(function(x, y) merge(x, y, by = c("year", "kanton"), all = TRUE),
                           list(total_canton, construction, accommodation))

  canton_sectors[, share_construction := emp_construction / emp_total_canton]
  canton_sectors[, share_accommodation := emp_accommodation / emp_total_canton]

  cat("  Canton sectors:", nrow(canton_sectors), "rows\n")
}

# ---------------------------------------------------------------------------
# 5. Map municipalities to cantons
# ---------------------------------------------------------------------------
cat("\n5. Creating municipality-canton mapping...\n")

# BFS municipality numbers encode canton:
# 1-99 → ZH, 301-399 → BE, etc.
# Standard mapping:
canton_ranges <- data.table(
  kanton_nr = c(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26),
  kanton_name = c("Zürich","Bern","Luzern","Uri","Schwyz","Obwalden","Nidwalden",
                  "Glarus","Zug","Freiburg","Solothurn","Basel-Stadt","Basel-Landschaft",
                  "Schaffhausen","Appenzell A.Rh.","Appenzell I.Rh.","St. Gallen",
                  "Graubünden","Aargau","Thurgau","Ticino","Vaud","Valais",
                  "Neuchâtel","Genève","Jura"),
  language = c("de","de","de","de","de","de","de","de","de","fr","de","de","de",
               "de","de","de","de","de","de","de","it","fr","de","fr","fr","fr"),
  gem_start = c(1, 301, 1001, 1201, 1301, 1401, 1501, 1601, 1701, 2001,
                2401, 2701, 2761, 2901, 3001, 3101, 3201, 3501, 4001,
                4501, 5001, 5401, 6001, 6401, 6601, 6701),
  gem_end = c(300, 1000, 1200, 1300, 1400, 1500, 1600, 1700, 2000, 2400,
              2700, 2760, 2900, 3000, 3100, 3200, 3500, 4000, 4500,
              5000, 5400, 6000, 6400, 6600, 6700, 7000)
)

# Map function
assign_canton <- function(gem_nr) {
  for (i in seq_len(nrow(canton_ranges))) {
    if (gem_nr >= canton_ranges$gem_start[i] & gem_nr <= canton_ranges$gem_end[i]) {
      return(canton_ranges$kanton_nr[i])
    }
  }
  return(NA_integer_)
}

# ---------------------------------------------------------------------------
# 6. Merge into analysis dataset
# ---------------------------------------------------------------------------
cat("\n6. Building analysis dataset...\n")

# Start with ZWA (running variable) — this determines the RDD sample
# Merge with employment panel
analysis <- merge(employment, zwa[, .(gemeinde_nr, zwa_pct, running, treated,
                                       total_dwellings, primary_dwellings)],
                  by = "gemeinde_nr", all.x = FALSE, all.y = FALSE)

cat("  After ZWA merge:", nrow(analysis), "rows,",
    uniqueN(analysis$gemeinde_nr), "municipalities\n")

# Add canton
analysis[, kanton := sapply(gemeinde_nr, assign_canton)]

# Add language region from canton mapping
analysis <- merge(analysis, canton_ranges[, .(kanton_nr, kanton_name, language)],
                  by.x = "kanton", by.y = "kanton_nr", all.x = TRUE)

# Merge tourism where available
if (exists("tourism_wide")) {
  analysis <- merge(analysis, tourism_wide,
                    by = c("year", "gemeinde_nr"), all.x = TRUE)
}

# Canton-level sector detail
if (exists("canton_sectors")) {
  analysis <- merge(analysis, canton_sectors[, .(year, kanton, share_construction,
                                                  share_accommodation)],
                    by = c("year", "kanton"), all.x = TRUE)
}

# ---------------------------------------------------------------------------
# 7. Construct pre-treatment variables (baseline characteristics)
# ---------------------------------------------------------------------------
cat("\n7. Computing pre-treatment characteristics...\n")

# Pre-treatment period: 2011-2012 (before 2013 ordinance)
pre <- analysis[year %in% c(2011, 2012)]
baseline <- pre[, .(
  emp_total_pre = mean(emp_total, na.rm = TRUE),
  emp_secondary_pre = mean(emp_secondary, na.rm = TRUE),
  emp_tertiary_pre = mean(emp_tertiary, na.rm = TRUE),
  share_tertiary_pre = mean(share_tertiary, na.rm = TRUE),
  share_secondary_pre = mean(share_secondary, na.rm = TRUE),
  fte_total_pre = mean(fte_total, na.rm = TRUE)
), by = gemeinde_nr]

analysis <- merge(analysis, baseline, by = "gemeinde_nr", all.x = TRUE)

# Define post-treatment periods
analysis[, post := as.integer(year >= 2013)]
analysis[, period := ifelse(year <= 2012, "pre", ifelse(year <= 2015, "transition", "post"))]

# Employment growth (relative to 2011 baseline)
analysis[, emp_growth := (emp_total - emp_total_pre) / emp_total_pre]

# Altitude proxy: tourism municipalities tend to be at higher altitude
# Use tertiary share as proxy for economic structure
# (Will use as covariate in RDD balance tests)

cat("  Final analysis dataset:", nrow(analysis), "rows\n")
cat("  Municipalities:", uniqueN(analysis$gemeinde_nr), "\n")
cat("  Years:", paste(range(analysis$year), collapse = "-"), "\n")
cat("  Treated municipalities:", uniqueN(analysis[treated == 1]$gemeinde_nr), "\n")
cat("  Control municipalities:", uniqueN(analysis[treated == 0]$gemeinde_nr), "\n")

# ---------------------------------------------------------------------------
# 8. Summary statistics
# ---------------------------------------------------------------------------
cat("\n8. Summary statistics:\n")
cat("\nBy treatment status (2011 baseline):\n")
summary_stats <- pre[, .(
  n_municipalities = uniqueN(gemeinde_nr),
  mean_zwa = mean(zwa_pct, na.rm = TRUE),
  mean_emp = mean(emp_total, na.rm = TRUE),
  mean_fte = mean(fte_total, na.rm = TRUE),
  mean_share_secondary = mean(share_secondary, na.rm = TRUE),
  mean_share_tertiary = mean(share_tertiary, na.rm = TRUE)
), by = treated]

print(summary_stats)

# ---------------------------------------------------------------------------
# 9. Save
# ---------------------------------------------------------------------------
fwrite(analysis, "data/analysis_panel.csv")
cat("\nSaved: data/analysis_panel.csv\n")

# Also save cross-sectional RDD dataset (post-treatment averages)
post_avg <- analysis[year >= 2014 & year <= 2023, .(
  emp_total_post = mean(emp_total, na.rm = TRUE),
  emp_secondary_post = mean(emp_secondary, na.rm = TRUE),
  emp_tertiary_post = mean(emp_tertiary, na.rm = TRUE),
  fte_total_post = mean(fte_total, na.rm = TRUE),
  share_tertiary_post = mean(share_tertiary, na.rm = TRUE),
  log_emp_total_post = mean(log_emp_total, na.rm = TRUE),
  log_overnights_post = mean(log_overnights, na.rm = TRUE),
  overnights_post = mean(overnights, na.rm = TRUE),
  emp_growth_post = mean(emp_growth, na.rm = TRUE)
), by = .(gemeinde_nr, zwa_pct, running, treated, kanton, kanton_name, language,
          total_dwellings, emp_total_pre, share_tertiary_pre, share_secondary_pre)]

fwrite(post_avg, "data/rdd_cross_section.csv")
cat("Saved: data/rdd_cross_section.csv (", nrow(post_avg), "rows)\n")

cat("\n=== CLEANING DONE ===\n")
