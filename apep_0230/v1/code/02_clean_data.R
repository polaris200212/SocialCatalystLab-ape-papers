## 02_clean_data.R - Build analysis panel
## Neighbourhood Planning and House Prices (apep_0228)

source("00_packages.R")

data_dir <- "../data"

## ─────────────────────────────────────────────────────────────
## 1. Load processed data
## ─────────────────────────────────────────────────────────────

np <- readRDS(file.path(data_dir, "np_clean.rds"))
la_first_np <- readRDS(file.path(data_dir, "la_first_np.rds"))
np_yearly <- readRDS(file.path(data_dir, "np_yearly.rds"))
lr_panel <- fread(file.path(data_dir, "land_registry_la_year.csv"))

cat(sprintf("NP data: %d plans across %d LAs\n", nrow(np), n_distinct(np$la_name)))
cat(sprintf("LR panel: %d district-year observations\n", nrow(lr_panel)))

## ─────────────────────────────────────────────────────────────
## 2. Standardize LA names for matching
## ─────────────────────────────────────────────────────────────

## LR districts are uppercase; NP data has full council names
## Build a crosswalk

lr_districts <- sort(unique(lr_panel$district))
np_las <- la_first_np %>% select(la_name, la_upper)

## Direct matching on uppercase cleaned names
matched <- np_las %>%
  mutate(lr_district = case_when(
    la_upper %in% lr_districts ~ la_upper,
    TRUE ~ NA_character_
  ))

## Handle common mismatches
name_fixes <- tribble(
  ~la_name_pattern,                   ~lr_district,
  "Bristol",                          "CITY OF BRISTOL",
  "Kingston upon Hull",               "CITY OF KINGSTON UPON HULL",
  "City of London",                   "CITY OF LONDON",
  "City of Westminster",              "CITY OF WESTMINSTER",
  "City of York",                     "CITY OF YORK",
  "County Durham",                    "COUNTY DURHAM",
  "Herefordshire",                    "HEREFORDSHIRE",
  "Isle of Wight",                    "ISLE OF WIGHT",
  "East Riding of Yorkshire",         "EAST RIDING OF YORKSHIRE",
  "Cornwall",                         "CORNWALL",
  "Wiltshire",                        "WILTSHIRE",
  "Shropshire",                       "SHROPSHIRE",
  "Bath and North East Somerset",     "BATH AND NORTH EAST SOMERSET",
  "Buckinghamshire",                  "BUCKINGHAMSHIRE",
  "Dorset",                           "DORSET",
  "North Northamptonshire",           "NORTH NORTHAMPTONSHIRE",
  "West Northamptonshire",            "WEST NORTHAMPTONSHIRE",
  "North Somerset",                   "NORTH SOMERSET",
  "South Gloucestershire",            "SOUTH GLOUCESTERSHIRE",
  "Bournemouth, Christchurch and Poole", "BOURNEMOUTH, CHRISTCHURCH AND POOLE",
  "Cumberland",                       "CUMBERLAND",
  "Westmorland and Furness",          "WESTMORLAND AND FURNESS",
  "Somerset",                         "SOMERSET"
)

## Apply fixes
for (i in seq_len(nrow(name_fixes))) {
  idx <- grepl(name_fixes$la_name_pattern[i], matched$la_name, ignore.case = TRUE) &
         is.na(matched$lr_district)
  if (any(idx)) {
    matched$lr_district[idx] <- name_fixes$lr_district[i]
  }
}

## For remaining unmatched, try partial matching
unmatched <- matched %>% filter(is.na(lr_district))
if (nrow(unmatched) > 0) {
  for (i in seq_len(nrow(unmatched))) {
    candidate <- unmatched$la_upper[i]
    ## Try exact match first
    if (candidate %in% lr_districts) {
      matched$lr_district[matched$la_upper == candidate] <- candidate
      next
    }
    ## Try adding common prefixes/suffixes
    candidates <- c(
      candidate,
      paste0("CITY OF ", candidate),
      paste0("BOROUGH OF ", candidate)
    )
    hit <- candidates[candidates %in% lr_districts]
    if (length(hit) > 0) {
      matched$lr_district[matched$la_upper == candidate] <- hit[1]
    }
  }
}

## Report matching quality
n_matched <- sum(!is.na(matched$lr_district))
n_total <- nrow(matched)
cat(sprintf("\nLA matching: %d / %d matched (%.0f%%)\n",
            n_matched, n_total, 100 * n_matched / n_total))

still_unmatched <- matched %>% filter(is.na(lr_district))
if (nrow(still_unmatched) > 0) {
  cat("Unmatched LAs:\n")
  print(still_unmatched$la_name)
}

## ─────────────────────────────────────────────────────────────
## 3. Build analysis panel
## ─────────────────────────────────────────────────────────────

## Get all districts from LR data
all_districts <- lr_panel %>%
  distinct(district) %>%
  pull(district)

## Create treatment crosswalk: district -> first_treat_year
treatment_xwalk <- matched %>%
  filter(!is.na(lr_district)) %>%
  left_join(la_first_np %>% select(la_name, first_np_year, cumulative_nps),
            by = "la_name") %>%
  select(lr_district, first_np_year, cumulative_nps) %>%
  distinct(lr_district, .keep_all = TRUE)

## Merge treatment info into LR panel
panel <- lr_panel %>%
  as_tibble() %>%
  left_join(treatment_xwalk, by = c("district" = "lr_district")) %>%
  mutate(
    ## For CS-DiD: first_treat must be 0 for never-treated
    first_treat = ifelse(is.na(first_np_year), 0, first_np_year),
    ## Treatment indicator (post-treatment)
    treated = ifelse(first_treat > 0 & year >= first_treat, 1, 0),
    ## Log outcome
    log_median_price = log(median_price),
    log_mean_price = log(mean_price),
    ## Numeric district ID for CS-DiD
    district_id = as.numeric(factor(district))
  )

## Add cumulative NP count per LA-year
np_cumulative <- np_yearly %>%
  group_by(la_upper) %>%
  arrange(referendum_year) %>%
  mutate(cum_nps = cumsum(new_nps)) %>%
  ungroup() %>%
  select(la_upper, referendum_year, cum_nps)

## For intensity analysis: merge cumulative NPs
panel <- panel %>%
  left_join(
    treatment_xwalk %>% select(lr_district),
    by = c("district" = "lr_district")
  )

## ─────────────────────────────────────────────────────────────
## 4. Sample restrictions
## ─────────────────────────────────────────────────────────────

## Keep years 2008-2023 for the main analysis
panel <- panel %>%
  filter(year >= 2008, year <= 2023)

## Drop districts with very few transactions (< 50 per year on average)
panel <- panel %>%
  group_by(district) %>%
  mutate(avg_transactions = mean(n_transactions)) %>%
  ungroup() %>%
  filter(avg_transactions >= 50)

## ─────────────────────────────────────────────────────────────
## 5. Summary statistics
## ─────────────────────────────────────────────────────────────

cat("\n=== Panel Summary ===\n")
cat(sprintf("Districts: %d\n", n_distinct(panel$district)))
cat(sprintf("Years: %d - %d\n", min(panel$year), max(panel$year)))
cat(sprintf("District-year obs: %d\n", nrow(panel)))
cat(sprintf("Treated districts (ever NP): %d\n", sum(panel$first_treat > 0) / n_distinct(panel$year)))
cat(sprintf("Never-treated districts: %d\n",
            n_distinct(panel$district[panel$first_treat == 0])))
cat(sprintf("\nMedian price stats:\n"))
cat(sprintf("  Mean: GBP %s\n", format(round(mean(panel$median_price)), big.mark = ",")))
cat(sprintf("  SD:   GBP %s\n", format(round(sd(panel$median_price)), big.mark = ",")))
cat(sprintf("  Min:  GBP %s\n", format(round(min(panel$median_price)), big.mark = ",")))
cat(sprintf("  Max:  GBP %s\n", format(round(max(panel$median_price)), big.mark = ",")))

## Cohort distribution
cohort_dist <- panel %>%
  filter(first_treat > 0) %>%
  distinct(district, first_treat) %>%
  count(first_treat, name = "n_districts")

cat("\nCohort distribution (first NP year):\n")
print(as.data.frame(cohort_dist), row.names = FALSE)

## ─────────────────────────────────────────────────────────────
## 6. Save analysis panel
## ─────────────────────────────────────────────────────────────

saveRDS(panel, file.path(data_dir, "analysis_panel.rds"))
fwrite(panel, file.path(data_dir, "analysis_panel.csv"))
saveRDS(treatment_xwalk, file.path(data_dir, "treatment_xwalk.rds"))

cat("\nAnalysis panel saved.\n")
