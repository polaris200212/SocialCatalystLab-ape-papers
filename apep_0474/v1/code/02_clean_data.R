## =============================================================================
## 02_clean_data.R — Build commune × quarter panel from Sirene API data
## apep_0474: Downtown for Sale? ACV Commercial Displacement
## =============================================================================

source(file.path(dirname(sys.frame(1)$ofile %||% "code/02_clean_data.R"), "00_packages.R"))

## ---- 1. Read Sirene establishment data ----
cat("=== Reading Sirene establishment data ===\n")

sirene_path <- file.path(DATA, "sirene_establishments.csv")
stopifnot(file.exists(sirene_path))

sirene <- fread(sirene_path)
cat(sprintf("Total establishments: %s\n", format(nrow(sirene), big.mark = ",")))

# Verify structure
cat(sprintf("  Unique communes: %d\n", uniqueN(sirene$code_commune)))
cat(sprintf("  ACV communes: %d\n", uniqueN(sirene[sample == "acv"]$code_commune)))
cat(sprintf("  Control communes: %d\n", uniqueN(sirene[sample == "control"]$code_commune)))
cat(sprintf("  Downtown-sector: %s\n", format(sum(sirene$downtown_sector), big.mark = ",")))
cat(sprintf("  Year range: %d-%d\n", min(sirene$year), max(sirene$year)))

## ---- 2. Load ACV treatment data ----
cat("\n=== Loading ACV treatment data ===\n")
acv <- fread(file.path(DATA, "acv_communes_clean.csv"))
acv_codes <- unique(acv$code_commune)
cat(sprintf("  ACV communes: %d\n", length(acv_codes)))

## ---- 3. Build commune × quarter panel ----
cat("\n=== Building commune × quarter panel ===\n")

# All commune codes in the sample
all_codes <- unique(sirene$code_commune)

# Creation counts by commune × quarter × sector type
creations_dt <- sirene[downtown_sector == 1,
                       .(n_creations = .N),
                       by = .(code_commune, year, quarter)]

creations_all <- sirene[, .(n_creations_all = .N),
                        by = .(code_commune, year, quarter)]

creations_placebo <- sirene[placebo_sector == 1,
                            .(n_creations_placebo = .N),
                            by = .(code_commune, year, quarter)]

# Create full grid
panel_grid <- CJ(code_commune = all_codes,
                 year = 2010:2024,
                 quarter = 1:4)

# Merge creation counts
panel <- merge(panel_grid, creations_dt,
               by = c("code_commune", "year", "quarter"), all.x = TRUE)
panel <- merge(panel, creations_all,
               by = c("code_commune", "year", "quarter"), all.x = TRUE)
panel <- merge(panel, creations_placebo,
               by = c("code_commune", "year", "quarter"), all.x = TRUE)

# Fill NA with 0
panel[is.na(n_creations), n_creations := 0]
panel[is.na(n_creations_all), n_creations_all := 0]
panel[is.na(n_creations_placebo), n_creations_placebo := 0]

# Treatment indicators
panel[, acv := fifelse(code_commune %in% acv_codes, 1L, 0L)]
panel[, post := fifelse(year > 2017 | (year == 2017 & quarter == 4), 1L, 0L)]
panel[, treat_post := acv * post]

# Event time relative to 2018Q1 (treatment onset)
panel[, event_time := (year - 2018) * 4 + (quarter - 1)]

# Bin endpoints
panel[, event_bin := fcase(
  event_time <= -20, -20L,
  event_time >= 20, 20L,
  default = as.integer(event_time)
)]

# Log transformation
panel[, log_creations := log1p(n_creations)]
panel[, log_creations_all := log1p(n_creations_all)]

# Département
panel[, dept := substr(code_commune, 1, 2)]
panel[dept %in% c("2A", "2B"), dept := "20"]
panel[, dept_year := paste0(dept, "_", year)]

# Numeric IDs
panel[, commune_id := as.integer(as.factor(code_commune))]
panel[, time_id := (year - 2010) * 4 + quarter]
panel[, yq_label := paste0(year, "Q", quarter)]
panel[, yq := year + (quarter - 1) / 4]

# Period indicators
panel[, post_precovid := fifelse(year %in% 2018:2019, 1L, 0L)]
panel[, post_covid := fifelse(year %in% 2020:2021, 1L, 0L)]
panel[, post_recovery := fifelse(year >= 2022, 1L, 0L)]

## ---- 4. Compute commune-level pre-treatment characteristics ----
cat("\n=== Computing pre-treatment characteristics ===\n")

pre_chars <- panel[year >= 2012 & year <= 2017,
                   .(pre_creations_annual = sum(n_creations) / 6,
                     pre_creations_all_annual = sum(n_creations_all) / 6),
                   by = code_commune]

# Current stock proxy: total creations over all years
stock <- sirene[downtown_sector == 1, .N, by = code_commune]
setnames(stock, "N", "n_active")

stock_all <- sirene[, .N, by = code_commune]
setnames(stock_all, "N", "n_active_all")

pre_chars <- merge(pre_chars, stock, by = "code_commune", all.x = TRUE)
pre_chars <- merge(pre_chars, stock_all, by = "code_commune", all.x = TRUE)
pre_chars[, acv := fifelse(code_commune %in% acv_codes, 1L, 0L)]
pre_chars[, dept := substr(code_commune, 1, 2)]

# Merge to panel for heterogeneity
panel <- merge(panel, pre_chars[, .(code_commune, n_active, n_active_all,
                                     pre_creations_annual)],
               by = "code_commune", all.x = TRUE)

# Size categories
panel[, size_cat := fcase(
  is.na(n_active) | n_active < 10, "Small",
  n_active < 30, "Medium",
  default = "Large"
)]

# CS-DiD variables (annual)
panel[, first_treat := fifelse(acv == 1, 33L, 0L)]  # time_id for 2018Q1

## ---- 5. Save ----
cat("\n=== Saving panel dataset ===\n")
fwrite(panel, file.path(DATA, "panel_commune_quarter.csv"))
fwrite(pre_chars, file.path(DATA, "commune_characteristics.csv"))

cat(sprintf("  Panel: %s observations\n", format(nrow(panel), big.mark = ",")))
cat(sprintf("  Communes: %d (ACV: %d, Control: %d)\n",
            uniqueN(panel$code_commune),
            uniqueN(panel[acv == 1]$code_commune),
            uniqueN(panel[acv == 0]$code_commune)))
cat(sprintf("  Quarters: %d (%s to %s)\n",
            uniqueN(panel$time_id),
            min(panel$yq_label), max(panel$yq_label)))
cat(sprintf("  Mean downtown creations (ACV): %.2f\n",
            mean(panel[acv == 1]$n_creations)))
cat(sprintf("  Mean downtown creations (Control): %.2f\n",
            mean(panel[acv == 0]$n_creations)))

cat("\nData cleaning complete.\n")
