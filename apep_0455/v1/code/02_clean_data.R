## ============================================================
## 02_clean_data.R — Clean and merge DVF + TLV + controls
## Paper: TLV Expansion and Housing Markets (apep_0455)
## ============================================================

source("00_packages.R")

data_dir <- "../data"

## -------------------------------------------------------
## 1. Load Definitive TLV Treatment Assignment
## -------------------------------------------------------

cat("=== Loading TLV zonage data ===\n")

## The definitive file has three zonage columns:
## - Zonage TLV 2013: "TLV" or "Non TLV"
## - Zonage TLV 2023: "1. Zone tendue", "2. Zone touristique et tendue", "3. Non tendue"
## - Zonage TLV post décret 22/12/2025: same categories

tlv_file <- file.path(data_dir, "zonage_tlv_2025.csv")
stopifnot(file.exists(tlv_file))

tlv_raw <- fread(tlv_file, sep = ";", encoding = "UTF-8")
cat(sprintf("  TLV zonage: %d communes\n", nrow(tlv_raw)))

## Rename columns
setnames(tlv_raw, c("code_commune", "dep", "nom", "code_epci",
                      "lib_epci", "zonage_2013", "zonage_2023", "zonage_2025"))

## Construct treatment groups
## Pre-2023 TLV: communes that had TLV before the 2023 expansion
## 2023 Expansion: communes that moved from "Non TLV" to zone tendue/touristique
## Never TLV: communes that remain "Non tendue" after 2023

tlv <- tlv_raw %>%
  as_tibble() %>%
  mutate(
    code_commune = as.character(code_commune),
    ## Pad code_commune to 5 digits for joining
    code_commune = ifelse(nchar(code_commune) < 5,
                           sprintf("%05s", code_commune),
                           code_commune),
    pre2023_tlv = (zonage_2013 == "TLV"),
    zone_2023 = case_when(
      grepl("^1\\.", zonage_2023) ~ "tendue",
      grepl("^2\\.", zonage_2023) ~ "touristique_tendue",
      grepl("^3\\.", zonage_2023) ~ "non_tendue",
      TRUE ~ NA_character_
    ),
    ## Treatment: communes newly designated in 2023
    ## = was "Non TLV" in 2013, became zone 1 or 2 in 2023
    treatment_group = case_when(
      pre2023_tlv ~ "always_treated",
      zone_2023 %in% c("tendue", "touristique_tendue") ~ "expansion_2023",
      zone_2023 == "non_tendue" ~ "never_treated",
      TRUE ~ NA_character_
    ),
    ## Binary treatment for DiD (excluding always_treated)
    treated = case_when(
      treatment_group == "expansion_2023" ~ 1L,
      treatment_group == "never_treated" ~ 0L,
      TRUE ~ NA_integer_
    )
  )

## Summary
cat("\n=== Treatment Assignment ===\n")
cat(sprintf("  Always treated (pre-2023, excluded): %d\n",
            sum(tlv$treatment_group == "always_treated", na.rm = TRUE)))
cat(sprintf("  Expansion 2023 (TREATED): %d\n",
            sum(tlv$treatment_group == "expansion_2023", na.rm = TRUE)))
cat(sprintf("    - Zone tendue: %d\n",
            sum(tlv$treatment_group == "expansion_2023" &
                  tlv$zone_2023 == "tendue", na.rm = TRUE)))
cat(sprintf("    - Zone touristique et tendue: %d\n",
            sum(tlv$treatment_group == "expansion_2023" &
                  tlv$zone_2023 == "touristique_tendue", na.rm = TRUE)))
cat(sprintf("  Never treated (CONTROL): %d\n",
            sum(tlv$treatment_group == "never_treated", na.rm = TRUE)))

## Save treatment assignment
saveRDS(tlv, file.path(data_dir, "treatment.rds"))

## -------------------------------------------------------
## 2. Read and Clean DVF
## -------------------------------------------------------

cat("\n=== Reading DVF data ===\n")

dvf_files <- list.files(data_dir, pattern = "^dvf_\\d{4}\\.csv\\.gz$",
                         full.names = TRUE)

if (length(dvf_files) == 0) {
  stop("No DVF files found. Run 01_fetch_data.R first.")
}

cat(sprintf("  Found %d DVF files\n", length(dvf_files)))

dvf_list <- list()

for (f in dvf_files) {
  yr <- as.integer(gsub(".*dvf_(\\d{4})\\.csv\\.gz", "\\1", f))
  cat(sprintf("  Reading DVF %d...\n", yr))

  raw <- tryCatch({
    fread(f, encoding = "UTF-8", fill = TRUE, showProgress = FALSE)
  }, error = function(e) {
    cat(sprintf("    Error: %s\n", e$message))
    NULL
  })

  if (is.null(raw) || nrow(raw) == 0) next

  ## Standardize column names
  names(raw) <- tolower(names(raw))
  cols <- names(raw)
  cat(sprintf("    %d rows, cols: %s\n", nrow(raw),
              paste(head(cols, 8), collapse = ", ")))

  ## The geo-DVF format has standardized column names:
  ## code_commune (int), type_local, surface_reelle_bati, valeur_fonciere,
  ## nature_mutation, date_mutation, code_departement, nombre_pieces_principales

  ## Filter: keep only sales of houses and apartments
  clean <- raw %>%
    as_tibble() %>%
    filter(nature_mutation == "Vente",
           type_local %in% c("Maison", "Appartement"),
           !is.na(valeur_fonciere), valeur_fonciere > 0,
           !is.na(surface_reelle_bati), surface_reelle_bati > 0)

  ## Parse fields
  clean <- clean %>%
    mutate(
      price = as.numeric(valeur_fonciere),
      date = as.Date(date_mutation),
      year = year(date),
      quarter = quarter(date),
      code_commune = sprintf("%05d", as.integer(code_commune)),
      surface = as.numeric(surface_reelle_bati),
      property_type = type_local,
      pieces = as.integer(nombre_pieces_principales),
      dep = sprintf("%02d", as.integer(code_departement))
    )

  ## Select and filter
  clean <- clean %>%
    select(code_commune, dep, date, year, quarter,
           price, surface, property_type, pieces) %>%
    filter(!is.na(price), price > 0,
           !is.na(surface), surface > 0,
           !is.na(code_commune)) %>%
    mutate(
      price_sqm = price / surface,
      log_price_sqm = log(price_sqm)
    ) %>%
    ## Remove extreme outliers
    filter(price_sqm >= 100, price_sqm <= 50000,
           surface >= 9, surface <= 500)

  dvf_list[[as.character(yr)]] <- clean
  cat(sprintf("    Cleaned: %d transactions\n", nrow(clean)))
}

dvf <- bind_rows(dvf_list)
cat(sprintf("\n  Total DVF: %d transactions, %d communes, years %s\n",
            nrow(dvf), n_distinct(dvf$code_commune),
            paste(sort(unique(dvf$year)), collapse = "-")))

## -------------------------------------------------------
## 3. Merge DVF with Treatment
## -------------------------------------------------------

cat("\n=== Merging DVF with treatment ===\n")

## Ensure commune codes match (pad to 5 digits)
dvf <- dvf %>%
  mutate(code_commune = ifelse(nchar(code_commune) < 5,
                                sprintf("%05s", code_commune),
                                code_commune))

## Join treatment
panel <- dvf %>%
  inner_join(
    tlv %>%
      filter(!is.na(treated)) %>%
      select(code_commune, treated, treatment_group, zone_2023,
             dep_tlv = dep, nom),
    by = "code_commune"
  ) %>%
  mutate(
    post = as.integer(year >= 2024),
    treat_post = treated * post
  )

cat(sprintf("  Panel: %d transactions\n", nrow(panel)))
cat(sprintf("  Treated communes: %d (%d transactions)\n",
            n_distinct(panel$code_commune[panel$treated == 1]),
            sum(panel$treated == 1)))
cat(sprintf("  Control communes: %d (%d transactions)\n",
            n_distinct(panel$code_commune[panel$treated == 0]),
            sum(panel$treated == 0)))

## Year × treatment summary
year_summary <- panel %>%
  group_by(year, treated) %>%
  summarise(
    n = n(),
    communes = n_distinct(code_commune),
    mean_price_sqm = mean(price_sqm, na.rm = TRUE),
    median_price_sqm = median(price_sqm, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  arrange(year, treated)

cat("\n  Year × Treatment:\n")
print(as.data.frame(year_summary))

## -------------------------------------------------------
## 4. Commune-Year Panel
## -------------------------------------------------------

cat("\n=== Building commune-year panel ===\n")

commune_year <- panel %>%
  group_by(code_commune, dep, year, treated, treatment_group, zone_2023) %>%
  summarise(
    n_transactions = n(),
    mean_price_sqm = mean(price_sqm, na.rm = TRUE),
    median_price_sqm = median(price_sqm, na.rm = TRUE),
    mean_log_price_sqm = mean(log_price_sqm, na.rm = TRUE),
    sd_price_sqm = sd(price_sqm, na.rm = TRUE),
    total_volume = sum(price, na.rm = TRUE),
    mean_surface = mean(surface, na.rm = TRUE),
    share_apartments = mean(property_type == "Appartement", na.rm = TRUE),
    mean_pieces = mean(pieces, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(
    post = as.integer(year >= 2024),
    treat_post = treated * post,
    log_transactions = log(n_transactions + 1),
    log_volume = log(total_volume + 1)
  )

cat(sprintf("  Commune-year panel: %d obs (%d communes × %d years)\n",
            nrow(commune_year),
            n_distinct(commune_year$code_commune),
            n_distinct(commune_year$year)))

## -------------------------------------------------------
## 5. Balance check: compare treated and control pre-treatment
## -------------------------------------------------------

cat("\n=== Pre-treatment balance ===\n")

pre_balance <- commune_year %>%
  filter(year < 2024) %>%
  group_by(treated) %>%
  summarise(
    communes = n_distinct(code_commune),
    mean_price_sqm = mean(mean_price_sqm, na.rm = TRUE),
    mean_transactions = mean(n_transactions, na.rm = TRUE),
    mean_surface = mean(mean_surface, na.rm = TRUE),
    mean_share_apt = mean(share_apartments, na.rm = TRUE),
    .groups = "drop"
  )

print(as.data.frame(pre_balance))

## -------------------------------------------------------
## 6. Save datasets
## -------------------------------------------------------

cat("\n=== Saving ===\n")

saveRDS(panel, file.path(data_dir, "panel_transactions.rds"))
saveRDS(commune_year, file.path(data_dir, "panel_commune_year.rds"))
write_parquet(as.data.frame(panel), file.path(data_dir, "panel_transactions.parquet"))
write_parquet(as.data.frame(commune_year), file.path(data_dir, "panel_commune_year.parquet"))

cat("  Saved panel_transactions.rds and panel_commune_year.rds\n")
cat("  Saved parquet versions\n")

cat("\n=== Summary ===\n")
cat(sprintf("  Total transactions: %s\n", format(nrow(panel), big.mark = ",")))
cat(sprintf("  Treated: %s | Control: %s\n",
            format(sum(panel$treated == 1), big.mark = ","),
            format(sum(panel$treated == 0), big.mark = ",")))
cat(sprintf("  Treatment rate: %.1f%%\n",
            100 * mean(panel$treated == 1)))

cat("\nData cleaning complete.\n")
