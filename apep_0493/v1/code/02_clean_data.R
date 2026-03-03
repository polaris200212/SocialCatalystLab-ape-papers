# =============================================================================
# 02_clean_data.R — Construct analysis panel with treatment variable
# apep_0493: Council Tax Support Localisation and Low-Income Employment
# =============================================================================

source("00_packages.R")

# =============================================================================
# 1. Clean Claimant Count Data
# =============================================================================
cat("=== Cleaning claimant count data ===\n")

cc_raw <- fread(file.path(data_dir, "nomis_claimant_count_raw.csv"))

cc <- cc_raw |>
  as_tibble() |>
  select(la_code = GEOGRAPHY_CODE, la_name = GEOGRAPHY_NAME,
         date_name = DATE_NAME, value = OBS_VALUE) |>
  mutate(
    date = as.Date(paste0("01 ", date_name), format = "%d %B %Y"),
    year = year(date), month = month(date),
    claimant_count = as.numeric(value)
  ) |>
  filter(!is.na(date), !is.na(claimant_count), str_starts(la_code, "E")) |>
  select(la_code, la_name, date, year, month, claimant_count)

cat("  Claimant count:", nrow(cc), "rows,", n_distinct(cc$la_code), "English LAs\n")

# =============================================================================
# 2. Clean Population Data
# =============================================================================
cat("\n=== Cleaning population data ===\n")

pop_raw <- fread(file.path(data_dir, "nomis_population_raw.csv"))

pop <- pop_raw |>
  as_tibble() |>
  select(la_code = GEOGRAPHY_CODE, date_name = DATE_NAME, value = OBS_VALUE) |>
  mutate(year = as.numeric(date_name), working_age_pop = as.numeric(value)) |>
  filter(!is.na(year), !is.na(working_age_pop), str_starts(la_code, "E")) |>
  select(la_code, year, working_age_pop)

cat("  Population:", nrow(pop), "rows,", n_distinct(pop$la_code), "English LAs\n")

# =============================================================================
# 3. Construct Treatment Variable from LCTS Data
# =============================================================================
cat("\n=== Constructing treatment variable ===\n")

# Parse 2013 LCTS: CTS amounts foregone by LA, split by pension-age / working-age
lcts_raw <- readxl::read_excel(
  file.path(data_dir, "taxbase_2013.xls"), sheet = "Data", skip = 5, col_names = FALSE
)

names(lcts_raw) <- c("ecode", "class", "la_name",
  paste0("pension_band_", c("A0","A","B","C","D","E","F","G","H","total")),
  paste0("working_band_", c("A0","A","B","C","D","E","F","G","H","total")),
  paste0("all_band_", c("A0","A","B","C","D","E","F","G","H","total")))

lcts <- lcts_raw |>
  filter(str_starts(ecode, "E")) |>
  mutate(across(contains("band_"), as.numeric)) |>
  transmute(
    dluhc_code = ecode,
    la_name_lcts = la_name,
    cts_pension = pension_band_total,
    cts_working = working_band_total,
    cts_total   = all_band_total
  ) |>
  filter(!is.na(cts_total), cts_total > 0)

cat("  LCTS parsed:", nrow(lcts), "LAs\n")

# Create crosswalk: match LCTS names to NOMIS LA codes by name
# NOMIS uses ONS GSS codes (E07xxxxxx), LCTS uses DLUHC codes (Exxxx)
nomis_las <- cc |>
  distinct(la_code, la_name) |>
  mutate(la_name_clean = str_to_lower(str_trim(la_name)))

lcts <- lcts |>
  mutate(la_name_clean = str_to_lower(str_trim(la_name_lcts)))

# Join by cleaned name
lcts <- lcts |>
  left_join(nomis_las |> select(la_code, la_name_clean), by = "la_name_clean")

matched <- sum(!is.na(lcts$la_code))
cat("  Matched", matched, "of", nrow(lcts), "LAs by name\n")

# For unmatched, try fuzzy matching
unmatched <- lcts |> filter(is.na(la_code))
if (nrow(unmatched) > 0) {
  cat("  Unmatched LAs:", paste(head(unmatched$la_name_lcts, 10), collapse = ", "), "\n")

  # Common name differences
  name_fixes <- c(
    "city of bristol" = "bristol, city of",
    "city of london" = "city of london",
    "herefordshire" = "herefordshire, county of",
    "kingston upon hull" = "kingston upon hull, city of",
    "durham" = "county durham",
    "st albans" = "st albans",
    "st edmundsbury" = "st edmundsbury",
    "st helens" = "st. helens",
    "king's lynn and west norfolk" = "king's lynn and west norfolk"
  )

  # Try broader fuzzy matching
  for (i in which(is.na(lcts$la_code))) {
    target <- lcts$la_name_clean[i]
    # Find closest match
    dists <- adist(target, nomis_las$la_name_clean)
    best <- which.min(dists)
    if (dists[best] <= 5) {  # Allow up to 5 character edits
      lcts$la_code[i] <- nomis_las$la_code[best]
    }
  }

  matched2 <- sum(!is.na(lcts$la_code))
  cat("  After fuzzy matching:", matched2, "of", nrow(lcts), "LAs matched\n")

  still_unmatched <- lcts |> filter(is.na(la_code))
  if (nrow(still_unmatched) > 0) {
    cat("  Still unmatched:", paste(still_unmatched$la_name_lcts, collapse = ", "), "\n")
  }
}

# Drop unmatched LAs
lcts <- lcts |> filter(!is.na(la_code))
cat("  Final LCTS dataset:", nrow(lcts), "LAs\n")

# Merge with 2012 population to get per-capita CTS
pop_2012 <- pop |> filter(year == 2012) |> select(la_code, pop_2012 = working_age_pop)

lcts <- lcts |>
  left_join(pop_2012, by = "la_code") |>
  mutate(
    # CTS per working-age person (£ per year)
    cts_working_pc = cts_working / pop_2012,
    cts_total_pc   = cts_total / pop_2012,
    # Working-age share of total CTS
    # Under national CTB, this share was determined by demographics
    # Under local CTS, cut LAs will have lower working-age share
    # (because pensioners are protected, only working-age CTS was cut)
    wa_cts_share = cts_working / cts_total
  )

cat("  Mean CTS/capita (working age): £", round(mean(lcts$cts_working_pc, na.rm = TRUE)),
    "\n  SD:", round(sd(lcts$cts_working_pc, na.rm = TRUE)), "\n")

# Treatment classification:
# Strategy: LAs that cut CTS will show LOWER working-age CTS per capita
# relative to their claimant base. We use the pre-reform claimant rate
# to control for "need" and extract the residual as treatment intensity.
#
# Approach 1 (Binary): Compare top vs bottom tercile of CTS per capita
# Approach 2 (Continuous): CTS working-age per capita (normalized)

# Get pre-reform mean claimant rate for each LA (2010-2012)
pre_claimant <- cc |>
  filter(year >= 2010, year <= 2012) |>
  left_join(pop, by = c("la_code", "year")) |>
  group_by(la_code) |>
  summarise(
    pre_claimant_rate = mean(claimant_count / working_age_pop * 100, na.rm = TRUE),
    pre_claimant_count = mean(claimant_count, na.rm = TRUE),
    .groups = "drop"
  )

lcts <- lcts |>
  left_join(pre_claimant, by = "la_code")

# Residualize CTS per capita on pre-reform claimant rate
# This controls for "need" — the residual captures generosity
if (sum(!is.na(lcts$cts_working_pc) & !is.na(lcts$pre_claimant_rate)) > 50) {
  resid_mod <- lm(cts_working_pc ~ pre_claimant_rate, data = lcts)
  lcts$cts_residual <- NA_real_
  lcts$cts_residual[!is.na(lcts$cts_working_pc) & !is.na(lcts$pre_claimant_rate)] <-
    residuals(resid_mod)

  cat("  R² of CTS~claimant_rate:", round(summary(resid_mod)$r.squared, 3), "\n")
  cat("  Residual CTS SD: £", round(sd(lcts$cts_residual, na.rm = TRUE)), "\n")
}

# Binary treatment: below-median residual CTS = "cut" LAs
lcts <- lcts |>
  mutate(
    # Continuous treatment (standardized)
    treat_continuous = scale(cts_residual)[, 1],
    # Binary: below median = cut (less generous than expected given need)
    treat_binary = as.integer(cts_residual < median(cts_residual, na.rm = TRUE)),
    # Tercile groups
    treat_tercile = ntile(cts_residual, 3)
  )

cat("\n  Treatment summary (binary):\n")
cat("    Cut LAs (treat=1):", sum(lcts$treat_binary == 1, na.rm = TRUE), "\n")
cat("    Protected LAs (treat=0):", sum(lcts$treat_binary == 0, na.rm = TRUE), "\n")

cat("\n  Treatment summary (terciles):\n")
for (t in 1:3) {
  n_t <- sum(lcts$treat_tercile == t, na.rm = TRUE)
  m_t <- mean(lcts$cts_working_pc[lcts$treat_tercile == t], na.rm = TRUE)
  cat("    Tercile", t, ":", n_t, "LAs, mean CTS/capita = £", round(m_t), "\n")
}

# Save treatment data
treatment <- lcts |>
  select(la_code, cts_working_pc, cts_total_pc, wa_cts_share,
         pre_claimant_rate, cts_residual, treat_continuous, treat_binary, treat_tercile)

fwrite(treatment, file.path(data_dir, "treatment.csv"))
cat("\n  Treatment data saved\n")

# =============================================================================
# 4. Construct Analysis Panel
# =============================================================================
cat("\n=== Constructing analysis panel ===\n")

panel <- cc |>
  left_join(pop, by = c("la_code", "year")) |>
  left_join(treatment, by = "la_code") |>
  filter(!is.na(working_age_pop), working_age_pop > 0, !is.na(treat_binary)) |>
  distinct(la_code, date, .keep_all = TRUE) |>
  mutate(
    claimant_rate = claimant_count / working_age_pop * 100,
    post = as.integer(date >= as.Date("2013-04-01")),
    rel_month = interval(as.Date("2013-04-01"), date) %/% months(1),
    # Create year-quarter for aggregation
    yq = paste0(year, "Q", quarter(date)),
    # Log outcome
    log_claimant_rate = log(claimant_rate + 0.01)
  )

cat("  Final panel:", nrow(panel), "rows,",
    n_distinct(panel$la_code), "LAs,",
    n_distinct(panel$date), "months\n")

# Check balance
cat("\n  Balance check:\n")
balance <- panel |>
  filter(post == 0) |>
  group_by(treat_binary) |>
  summarise(
    n_las = n_distinct(la_code),
    mean_rate = mean(claimant_rate, na.rm = TRUE),
    sd_rate = sd(claimant_rate, na.rm = TRUE),
    mean_pop = mean(working_age_pop, na.rm = TRUE),
    .groups = "drop"
  )
print(balance)

# =============================================================================
# 5. Save Final Panel
# =============================================================================
fwrite(panel, file.path(data_dir, "analysis_panel.csv"))
cat("\n=== Panel saved to analysis_panel.csv ===\n")

# =============================================================================
# 6. Summary Statistics Table
# =============================================================================
cat("\n=== Summary Statistics ===\n")

sum_stats <- panel |>
  group_by(Period = ifelse(post == 0, "Pre-reform (2008-2013)", "Post-reform (2013-2023)"),
           Group = ifelse(treat_binary == 1, "Cut LAs", "Protected LAs")) |>
  summarise(
    `N (LA-months)` = n(),
    `N (LAs)` = n_distinct(la_code),
    `Mean claimant rate (%)` = round(mean(claimant_rate, na.rm = TRUE), 2),
    `SD claimant rate (%)` = round(sd(claimant_rate, na.rm = TRUE), 2),
    `Mean claimant count` = round(mean(claimant_count, na.rm = TRUE)),
    `Mean working-age pop` = round(mean(working_age_pop, na.rm = TRUE)),
    .groups = "drop"
  )

print(sum_stats)
