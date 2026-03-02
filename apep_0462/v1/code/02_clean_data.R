## 02_clean_data.R — Build département-quarter panel from BAAC microdata
## apep_0462: Speed limit reversal and road safety in France

source(here::here("output", "apep_0462", "v1", "code", "00_packages.R"))

# ── 1. Read and Stack BAAC Data (2015-2024) ──────────────────────────

years <- 2015:2024

read_baac <- function(file_type, year) {
  path <- file.path(DATA_DIR, sprintf("%s_%d.csv", file_type, year))
  if (!file.exists(path)) {
    warning(sprintf("Missing: %s", path))
    return(NULL)
  }
  # BAAC delimiter varies: comma for older files, semicolon for newer
  # Let fread auto-detect
  dt <- fread(path, encoding = "UTF-8", colClasses = "character")
  # 2022 caract file uses "Accident_Id" instead of "Num_Acc"
  if ("Accident_Id" %in% names(dt) && !"Num_Acc" %in% names(dt)) {
    setnames(dt, "Accident_Id", "Num_Acc")
  }
  dt
}

cat("Reading BAAC microdata...\n")

# Read all years of Caracteristiques
caract_list <- lapply(years, function(y) {
  dt <- read_baac("caract", y)
  if (is.null(dt)) return(NULL)
  dt[, .(Num_Acc, jour, mois, an, dep, agg)]
})
caract <- rbindlist(caract_list, fill = TRUE)
cat(sprintf("  Caracteristiques: %d records\n", nrow(caract)))

# Read all years of Lieux
lieux_list <- lapply(years, function(y) {
  dt <- read_baac("lieux", y)
  if (is.null(dt)) return(NULL)
  dt[, .(Num_Acc, catr)]
})
lieux <- rbindlist(lieux_list, fill = TRUE)
cat(sprintf("  Lieux: %d records\n", nrow(lieux)))

# Read all years of Usagers
usagers_list <- lapply(years, function(y) {
  dt <- read_baac("usagers", y)
  if (is.null(dt)) return(NULL)
  dt[, .(Num_Acc, grav)]
})
usagers <- rbindlist(usagers_list, fill = TRUE)
cat(sprintf("  Usagers: %d records\n", nrow(usagers)))

# ── 2. Merge and Filter ─────────────────────────────────────────────

# Join caract with lieux on Num_Acc
acc <- merge(caract, lieux, by = "Num_Acc", all.x = FALSE)
cat(sprintf("  After caract-lieux merge: %d accidents\n", nrow(acc)))

# Standardize département codes across format changes
# Old format (2015-2018): 3-digit codes like "590" for dep 59, "010" for dep 01
# Corsica: "2A0"/"201" and "2B0"/"202"
# New format (2019+): 2-digit codes like "59", "01"
acc[, dep_raw := trimws(dep)]

# Handle Corsica variants first
acc[dep_raw %in% c("2A0", "2A", "201"), dep_code := "2A"]
acc[dep_raw %in% c("2B0", "2B", "202"), dep_code := "2B"]

# For numeric codes: extract département number
acc[is.na(dep_code), dep_num := suppressWarnings(as.integer(dep_raw))]

# 3-digit codes: divide by 10 to get 2-digit département (e.g., 590 → 59)
acc[is.na(dep_code) & !is.na(dep_num) & dep_num >= 100 & dep_num <= 959,
    dep_code := sprintf("%02d", dep_num %/% 10L)]

# 2-digit codes: already correct (e.g., 59)
acc[is.na(dep_code) & !is.na(dep_num) & dep_num >= 1 & dep_num <= 95,
    dep_code := sprintf("%02d", dep_num)]

# 3-digit overseas: 971-976 → exclude later
acc[is.na(dep_code) & !is.na(dep_num) & dep_num >= 970 & dep_num <= 976,
    dep_code := as.character(dep_num)]
# Old format overseas: 9710 → 971 etc
acc[is.na(dep_code) & !is.na(dep_num) & dep_num >= 9710 & dep_num <= 9769,
    dep_code := as.character(dep_num %/% 10L)]

# Drop records with unparseable dep codes
acc <- acc[!is.na(dep_code)]

# Keep metropolitan France only (01-95, 2A, 2B)
metro_codes <- c(sprintf("%02d", 1:95), "2A", "2B")
acc <- acc[dep_code %in% metro_codes]

cat(sprintf("  Unique metro départements: %d\n", uniqueN(acc$dep_code)))

# Clean numeric fields
# BAAC year field is 2-digit (15, 16...) for 2015-2018, 4-digit for 2019+
acc[, year_raw := as.integer(an)]
acc[, year := fifelse(year_raw < 100, year_raw + 2000L, year_raw)]
acc[, `:=`(
  month = as.integer(mois),
  agg_code = as.integer(agg),
  catr_code = as.integer(catr)
)]

cat("  Year distribution:\n")
print(acc[, .N, by = year][order(year)])

# Create quarter variable
acc[, quarter := ceiling(month / 3)]
acc[, yq := year + (quarter - 1) / 4]  # Continuous quarter

cat(sprintf("  Metropolitan accidents: %d\n", nrow(acc)))

# ── 3. Aggregate Severity by Accident ────────────────────────────────

# For each accident, count fatalities, hospitalized, light injuries
sev <- usagers[, .(
  n_killed = sum(grav == "2", na.rm = TRUE),
  n_hosp   = sum(grav == "3", na.rm = TRUE),
  n_light  = sum(grav == "4", na.rm = TRUE),
  n_victims = .N
), by = Num_Acc]

# Merge severity onto accidents
acc <- merge(acc, sev, by = "Num_Acc", all.x = TRUE)
acc[is.na(n_killed), `:=`(n_killed = 0, n_hosp = 0, n_light = 0, n_victims = 0)]

# ── 4. Create Road-Type Subsets ──────────────────────────────────────

# Primary sample: routes départementales (catr=3) outside agglomeration (agg=2)
# This is the exact population affected by the 80/90 speed limit
acc[, treated_road := (catr_code == 3 & agg_code == 2)]

# Placebo samples
acc[, autoroute := (catr_code == 1)]              # Autoroutes (speed unchanged)
acc[, dept_road_urban := (catr_code == 3 & agg_code == 1)]  # Dept roads IN agglomeration

cat(sprintf("  Routes départementales hors agglo: %d accidents\n",
            sum(acc$treated_road)))
cat(sprintf("  Autoroutes: %d accidents\n", sum(acc$autoroute)))
cat(sprintf("  Routes départementales in agglo: %d accidents\n",
            sum(acc$dept_road_urban)))

# ── 5. Build Département-Quarter Panel ───────────────────────────────

# For each département × quarter: count accidents and casualties
# on treated roads, autoroutes, and urban dept roads

build_panel <- function(road_filter, suffix = "") {
  sub <- acc[get(road_filter) == TRUE]

  panel <- sub[, .(
    accidents = .N,
    killed = sum(n_killed),
    hospitalized = sum(n_hosp),
    light_injury = sum(n_light),
    total_casualties = sum(n_killed + n_hosp + n_light),
    severity_rate = fifelse(.N > 0, sum(n_killed + n_hosp) / .N, NA_real_)
  ), by = .(dep_code, year, quarter)]

  setnames(panel, setdiff(names(panel), c("dep_code", "year", "quarter")),
           paste0(setdiff(names(panel), c("dep_code", "year", "quarter")), suffix))
  panel
}

panel_main <- build_panel("treated_road", "")
panel_auto <- build_panel("autoroute", "_auto")
panel_urban <- build_panel("dept_road_urban", "_urban")

# Also build annual panel
build_annual <- function(road_filter, suffix = "") {
  sub <- acc[get(road_filter) == TRUE]

  panel <- sub[, .(
    accidents = .N,
    killed = sum(n_killed),
    hospitalized = sum(n_hosp),
    light_injury = sum(n_light),
    total_casualties = sum(n_killed + n_hosp + n_light)
  ), by = .(dep_code, year)]

  setnames(panel, setdiff(names(panel), c("dep_code", "year")),
           paste0(setdiff(names(panel), c("dep_code", "year")), suffix))
  panel
}

annual_main  <- build_annual("treated_road", "")
annual_auto  <- build_annual("autoroute", "_auto")
annual_urban <- build_annual("dept_road_urban", "_urban")

# ── 6. Load Treatment Panel ──────────────────────────────────────────

treat <- fread(file.path(DATA_DIR, "treatment_panel.csv"))

# Parse reversal date to year-quarter
treat[, reversal_year := as.integer(substr(reversal_date, 1, 4))]
treat[, reversal_month := as.integer(substr(reversal_date, 6, 7))]
treat[, reversal_quarter := ceiling(reversal_month / 3)]
treat[, reversal_yq := reversal_year + (reversal_quarter - 1) / 4]

# Standardize dep_code to 2-digit character
treat[, dep_code := sprintf("%02d", as.integer(dep_code))]

# For CS-DiD: first_treat = first quarter of treatment (as integer index)
# Create a time index: Q3 2015 = 1, Q4 2015 = 2, ...
# Quarter index: (year - 2015) * 4 + quarter
treat[, first_treat_q := (reversal_year - 2015) * 4 + reversal_quarter]

cat(sprintf("\nTreatment panel: %d départements reversed\n", nrow(treat)))
cat(sprintf("  Earliest: %s (%s)\n", treat[reversal_yq == min(reversal_yq), dep_name[1]],
            treat[reversal_yq == min(reversal_yq), reversal_date[1]]))
cat(sprintf("  Latest: %s (%s)\n", treat[reversal_yq == max(reversal_yq), dep_name[1]],
            treat[reversal_yq == max(reversal_yq), reversal_date[1]]))

# ── 7. Merge Treatment onto Panel ────────────────────────────────────

# All metropolitan départements (including non-treated)
all_deps <- sort(unique(acc$dep_code))

# Create balanced quarterly panel
quarters <- CJ(
  dep_code = all_deps,
  year = 2015:2024,
  quarter = 1:4
)
# Remove Q1-Q2 of 2015 if we only have data from 2015
# (Actually keep all — BAAC covers full year)
# Remove future quarters (Q1-Q4 2025 onwards)
quarters <- quarters[year <= 2024]

# Add time index
quarters[, t := (year - 2015) * 4 + quarter]

# Merge main outcome
panel <- merge(quarters, panel_main, by = c("dep_code", "year", "quarter"), all.x = TRUE)
panel[is.na(accidents), `:=`(accidents = 0, killed = 0, hospitalized = 0,
                              light_injury = 0, total_casualties = 0,
                              severity_rate = NA_real_)]

# Merge placebo outcomes
panel <- merge(panel, panel_auto, by = c("dep_code", "year", "quarter"), all.x = TRUE)
panel[is.na(accidents_auto), `:=`(accidents_auto = 0, killed_auto = 0,
                                   hospitalized_auto = 0, light_injury_auto = 0,
                                   total_casualties_auto = 0, severity_rate_auto = NA_real_)]

panel <- merge(panel, panel_urban, by = c("dep_code", "year", "quarter"), all.x = TRUE)
panel[is.na(accidents_urban), `:=`(accidents_urban = 0, killed_urban = 0,
                                    hospitalized_urban = 0, light_injury_urban = 0,
                                    total_casualties_urban = 0, severity_rate_urban = NA_real_)]

# Merge treatment information
panel <- merge(panel, treat[, .(dep_code, reversal_date, reversal_year,
                                 reversal_quarter, reversal_yq, first_treat_q,
                                 coverage, share_pct)],
               by = "dep_code", all.x = TRUE)

# Treatment indicator
panel[, treated := !is.na(first_treat_q)]
panel[, post := fifelse(treated & t >= first_treat_q, 1L, 0L)]

# For CS-DiD: never-treated units get first_treat = 0
panel[is.na(first_treat_q), first_treat_q := 0L]

# Dep numeric ID for fixest
panel[, dep_id := as.integer(factor(dep_code))]

# Create continuous intensity treatment
panel[is.na(share_pct), share_pct := 0]
panel[, intensity := fifelse(post == 1, share_pct / 100, 0)]

cat(sprintf("\nFinal quarterly panel: %d dep × quarter observations\n", nrow(panel)))
cat(sprintf("  Départements: %d (treated: %d, never-treated: %d)\n",
            uniqueN(panel$dep_code),
            uniqueN(panel[treated == TRUE, dep_code]),
            uniqueN(panel[treated == FALSE, dep_code])))

# ── 8. Build Annual Panel ────────────────────────────────────────────

annual_quarters <- CJ(dep_code = all_deps, year = 2015:2024)
annual <- merge(annual_quarters, annual_main, by = c("dep_code", "year"), all.x = TRUE)
annual[is.na(accidents), `:=`(accidents = 0, killed = 0, hospitalized = 0,
                               light_injury = 0, total_casualties = 0)]
annual <- merge(annual, annual_auto, by = c("dep_code", "year"), all.x = TRUE)
annual[is.na(accidents_auto), `:=`(accidents_auto = 0, killed_auto = 0,
                                    hospitalized_auto = 0, light_injury_auto = 0,
                                    total_casualties_auto = 0)]
annual <- merge(annual, annual_urban, by = c("dep_code", "year"), all.x = TRUE)
annual[is.na(accidents_urban), `:=`(accidents_urban = 0, killed_urban = 0,
                                     hospitalized_urban = 0, light_injury_urban = 0,
                                     total_casualties_urban = 0)]

# Treatment
annual <- merge(annual, treat[, .(dep_code, reversal_year, share_pct, coverage)],
                by = "dep_code", all.x = TRUE)
annual[, treated := !is.na(reversal_year)]
annual[, post := fifelse(treated & year >= reversal_year, 1L, 0L)]
annual[is.na(reversal_year), reversal_year := 0L]
annual[is.na(share_pct), share_pct := 0]
annual[, dep_id := as.integer(factor(dep_code))]

cat(sprintf("Final annual panel: %d dep-year observations\n", nrow(annual)))

# ── 9. Save ──────────────────────────────────────────────────────────

fwrite(panel, file.path(DATA_DIR, "panel_quarterly.csv"))
fwrite(annual, file.path(DATA_DIR, "panel_annual.csv"))
fwrite(treat, file.path(DATA_DIR, "treatment_clean.csv"))

cat("\nAll panels saved.\n")

# ── 10. Summary Statistics ───────────────────────────────────────────

cat("\n=== Summary Statistics ===\n")
cat("\nQuarterly panel (routes départementales hors agglomération):\n")
panel[, .(
  mean_accidents = mean(accidents),
  sd_accidents = sd(accidents),
  mean_killed = mean(killed),
  mean_hosp = mean(hospitalized),
  mean_total = mean(total_casualties)
)] |> print()

cat("\nBy treatment status (pre-period 2015-2019):\n")
panel[year <= 2019, .(
  mean_accidents = mean(accidents),
  sd_accidents = sd(accidents),
  n_deps = uniqueN(dep_code)
), by = treated] |> print()

cat("\nTreatment rollout by year:\n")
treat[, .N, by = reversal_year][order(reversal_year)] |> print()

cat("\nCoverage distribution:\n")
treat[, .(
  n = .N,
  mean_share = mean(share_pct),
  median_share = median(share_pct),
  min_share = min(share_pct),
  max_share = max(share_pct)
), by = coverage] |> print()
