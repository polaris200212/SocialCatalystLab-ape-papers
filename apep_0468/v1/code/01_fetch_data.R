# ==============================================================================
# 01_fetch_data.R — Fetch crop data and load SHRUG baseline data
# APEP-0468: MGNREGA and Crop Portfolio Diversification
# ==============================================================================

source("00_packages.R")

data_dir <- "../data"
dir.create(data_dir, showWarnings = FALSE, recursive = TRUE)

# Path to shared SHRUG data (set SHRUG_DIR env var for replication)
shrug_dir <- Sys.getenv("SHRUG_DIR", file.path(normalizePath("../.."), "data", "india_shrug"))
stopifnot(dir.exists(shrug_dir))

# ==============================================================================
# 1. Fetch district-level crop area/production data
# ==============================================================================
cat("=== Fetching district-level crop data ===\n")

if (file.exists(file.path(data_dir, "crop_panel.rds"))) {
  cat("Crop panel already cached.\n")
  crop_panel <- readRDS(file.path(data_dir, "crop_panel.rds"))
} else {
  # Try data.gov.in API for district-wise crop production statistics
  # This provides area, production by district, crop, season, year
  cat("Downloading from data.gov.in...\n")

  tryCatch({
    # data.gov.in provides district-wise season-wise crop production
    # API endpoint for CKAN resource
    api_url <- "https://api.data.gov.in/resource/35be999b-0208-4354-b557-f6ca9a5355de"
    params <- list(
      `api-key` = "579b464db66ec23bdd000001cdd3946e44ce4aad7209ff7b23ac571b",
      format = "csv",
      limit = 100000,
      offset = 0
    )

    # Fetch in batches
    all_data <- list()
    batch <- 1
    total_rows <- 0

    repeat {
      cat(sprintf("  Fetching batch %d (offset %d)...\n", batch, params$offset))
      query_str <- paste0(api_url, "?",
                          paste(names(params), params, sep = "=", collapse = "&"))
      tmp <- tryCatch(fread(query_str, showProgress = FALSE),
                      error = function(e) NULL)

      if (is.null(tmp) || nrow(tmp) == 0) break

      all_data[[batch]] <- tmp
      total_rows <- total_rows + nrow(tmp)
      cat(sprintf("    Got %d rows (total: %d)\n", nrow(tmp), total_rows))

      if (nrow(tmp) < params$limit) break
      params$offset <- params$offset + params$limit
      batch <- batch + 1
      if (batch > 30) break  # Safety limit
    }

    if (length(all_data) > 0) {
      crop_raw <- rbindlist(all_data, fill = TRUE)
      cat("Total crop records:", nrow(crop_raw), "\n")
      saveRDS(crop_raw, file.path(data_dir, "crop_raw_datagovin.rds"))
    } else {
      crop_raw <- NULL
    }
  }, error = function(e) {
    cat("data.gov.in API failed:", e$message, "\n")
    crop_raw <<- NULL
  })

  # If API failed, try Ministry of Agriculture DES portal
  if (is.null(crop_raw) || nrow(crop_raw) == 0) {
    cat("\nTrying Ministry of Agriculture DES portal...\n")
    tryCatch({
      des_url <- "https://data.desagri.gov.in/api/crops/apy"
      tmp <- fread(des_url, showProgress = FALSE)
      if (nrow(tmp) > 0) {
        crop_raw <- tmp
        saveRDS(crop_raw, file.path(data_dir, "crop_raw_des.rds"))
      }
    }, error = function(e) {
      cat("DES portal also failed:", e$message, "\n")
      crop_raw <<- NULL
    })
  }

  # If both APIs failed, try ICRISAT Dataverse
  if (is.null(crop_raw) || nrow(crop_raw) == 0) {
    cat("\nTrying ICRISAT Dataverse...\n")
    tryCatch({
      icrisat_dv <- "https://dataverse.icrisat.org/api/access/datafile/:persistentId?persistentId=doi:10.21421/D2/XFB1BZ"
      dest <- file.path(data_dir, "icrisat_dataverse.tab")
      download.file(icrisat_dv, dest, mode = "wb", quiet = FALSE)
      crop_raw <- fread(dest)
      saveRDS(crop_raw, file.path(data_dir, "crop_raw_icrisat.rds"))
    }, error = function(e) {
      cat("ICRISAT Dataverse also failed:", e$message, "\n")
      crop_raw <<- NULL
    })
  }

  # If all API sources failed, construct from Kaggle/public data
  if (is.null(crop_raw) || nrow(crop_raw) == 0) {
    cat("\nAll API sources failed. Downloading from Kaggle mirror...\n")
    tryCatch({
      # This dataset contains district-wise crop production for India
      # Source: https://www.kaggle.com/datasets/abhinand05/crop-production-in-india
      kaggle_url <- "https://raw.githubusercontent.com/dsrscientist/dataset1/master/crop_production.csv"
      crop_raw <- fread(kaggle_url, showProgress = FALSE)
      cat("Downloaded crop data:", nrow(crop_raw), "rows\n")
      saveRDS(crop_raw, file.path(data_dir, "crop_raw_kaggle.rds"))
    }, error = function(e) {
      cat("Kaggle mirror also failed:", e$message, "\n")
      crop_raw <<- NULL
    })
  }

  if (!is.null(crop_raw) && nrow(crop_raw) > 0) {
    cat("\nCrop data columns:", paste(names(crop_raw), collapse = ", "), "\n")
    cat("Years available:", paste(sort(unique(crop_raw$Crop_Year %||% crop_raw$year %||%
                                               crop_raw$Year)), collapse = ", "), "\n")
    crop_panel <- crop_raw
    saveRDS(crop_panel, file.path(data_dir, "crop_panel.rds"))
  } else {
    cat("\n*** WARNING: Could not download crop data from any source. ***\n")
    cat("Will construct analysis using SHRUG Census worker categories as outcome.\n")
    crop_panel <- NULL
  }
}

# ==============================================================================
# 2. Load SHRUG district-level data (local)
# ==============================================================================
cat("\n=== Loading SHRUG data ===\n")

# Census 2001 at district level (pre-treatment baseline)
cat("Loading Census 2001 (district level)...\n")
pc01_dist <- fread(file.path(shrug_dir, "pc01_pca_clean_pc01dist.csv"))
cat("  Census 2001 districts:", nrow(pc01_dist), "\n")
cat("  Columns:", paste(head(names(pc01_dist), 10), collapse = ", "), "...\n")

# Census 2011 at district level (post-treatment)
cat("Loading Census 2011 (district level)...\n")
pc11_dist <- fread(file.path(shrug_dir, "pc11_pca_clean_pc11dist.csv"))
cat("  Census 2011 districts:", nrow(pc11_dist), "\n")

# Geographic crosswalk (district level)
cat("Loading geographic crosswalk (district level)...\n")
td_dist <- fread(file.path(shrug_dir, "pc11_td_clean_pc11dist.csv"))
cat("  Crosswalk entries:", nrow(td_dist), "\n")
cat("  Columns:", paste(names(td_dist), collapse = ", "), "\n")

# DMSP nightlights at district level (1992–2013, annual)
cat("Loading DMSP nightlights (district level)...\n")
nl_dist <- fread(file.path(shrug_dir, "dmsp_pc11dist.csv"))
cat("  DMSP obs:", nrow(nl_dist), "\n")
cat("  Years:", paste(sort(unique(nl_dist$year)), collapse = ", "), "\n")

# VIIRS nightlights at district level (2012+, annual)
cat("Loading VIIRS nightlights (district level)...\n")
viirs_dist <- fread(file.path(shrug_dir, "viirs_annual_pc11dist.csv"))
cat("  VIIRS obs:", nrow(viirs_dist), "\n")

# Check VIIRS columns
viirs_cols <- names(viirs_dist)
cat("  VIIRS columns:", paste(head(viirs_cols, 10), collapse = ", "), "\n")

# ==============================================================================
# 3. Construct MGNREGA phase assignment
# ==============================================================================
cat("\n=== Constructing MGNREGA phase treatment ===\n")

# Build backwardness index from Census 2001 district data
# Components: SC/ST share, agricultural labor share, literacy rate (inverse)

dist01 <- copy(pc01_dist)

# Compute backwardness index components
dist01[, `:=`(
  sc_st_share = (pc01_pca_p_sc + pc01_pca_p_st) / pc01_pca_tot_p,
  lit_rate = pc01_pca_p_lit / pc01_pca_tot_p,
  ag_labor_share = pc01_pca_main_al_p / pmax(pc01_pca_tot_work_p, 1)
)]

# Remove districts with very small or zero population
dist01 <- dist01[pc01_pca_tot_p > 1000]

# Standardize and combine into composite index
dist01[, backwardness_index := scale(sc_st_share)[,1] +
         scale(ag_labor_share)[,1] +
         scale(-lit_rate)[,1]]

# Rank districts (most backward = highest index = rank 1)
dist01[, backward_rank := frank(-backwardness_index)]

# Assign MGNREGA phases
n_dist <- nrow(dist01)
cat("Districts after filtering:", n_dist, "\n")

# Phase I: top 200 most backward districts
# Phase II: next 130
# Phase III: remaining
dist01[, mgnrega_phase := fifelse(backward_rank <= 200, 1L,
                            fifelse(backward_rank <= 330, 2L, 3L))]

# First treated agricultural year (ICRISAT/DLD convention)
# Phase I (Feb 2006): first full ag year = 2006-07, coded as year 2007
# Phase II (Apr 2007): first full ag year = 2007-08, coded as year 2008
# Phase III (Apr 2008): first full ag year = 2008-09, coded as year 2009
dist01[, first_treat := fifelse(mgnrega_phase == 1, 2007L,
                          fifelse(mgnrega_phase == 2, 2008L, 2009L))]

cat("\nMGNREGA Phase Distribution:\n")
print(dist01[, .N, by = mgnrega_phase][order(mgnrega_phase)])

# Create district ID for panel (state_id * 1000 + district_id)
dist01[, dist_id := pc01_state_id * 1000 + pc01_district_id]

# Save baseline characteristics and treatment assignment
dist01[, cultivator_share := pc01_pca_main_cl_p / pmax(pc01_pca_tot_work_p, 1)]

baseline <- dist01[, .(pc01_state_id, pc01_district_id, dist_id,
                        pop_2001 = pc01_pca_tot_p,
                        sc_st_share, lit_rate, ag_labor_share,
                        cultivator_share,
                        cultivators = pc01_pca_main_cl_p,
                        ag_laborers = pc01_pca_main_al_p,
                        total_workers = pc01_pca_tot_work_p,
                        backwardness_index, backward_rank,
                        mgnrega_phase, first_treat)]

saveRDS(baseline, file.path(data_dir, "baseline_district.rds"))
cat("Saved baseline_district.rds\n")

# ==============================================================================
# 4. Construct nightlights panel
# ==============================================================================
cat("\n=== Constructing nightlights district-year panel ===\n")

# DMSP: 1992-2013
nl_panel <- nl_dist[, .(pc11_state_id, pc11_district_id, year,
                         total_light = dmsp_total_light_cal,
                         mean_light = dmsp_mean_light_cal,
                         max_light = dmsp_max_light,
                         num_cells = dmsp_num_cells)]

# Create district ID matching Census 2001 codes
# Note: pc11 codes may differ from pc01 codes due to district splits
# For now use pc11 codes — will harmonize in cleaning step
nl_panel[, dist_id := pc11_state_id * 1000 + pc11_district_id]

# Restrict to 2000-2013 (our analysis period for DMSP)
nl_panel <- nl_panel[year >= 2000 & year <= 2013]
cat("DMSP panel: ", nrow(nl_panel), "obs,",
    length(unique(nl_panel$dist_id)), "districts,",
    paste(range(nl_panel$year), collapse = "-"), "\n")

saveRDS(nl_panel, file.path(data_dir, "nightlights_panel.rds"))
cat("Saved nightlights_panel.rds\n")

# ==============================================================================
# 5. Summary
# ==============================================================================
cat("\n=== Data Fetch Summary ===\n")
cat("Baseline districts:", nrow(baseline), "\n")
cat("  Phase I:", sum(baseline$mgnrega_phase == 1), "\n")
cat("  Phase II:", sum(baseline$mgnrega_phase == 2), "\n")
cat("  Phase III:", sum(baseline$mgnrega_phase == 3), "\n")
cat("Nightlights panel:", nrow(nl_panel), "obs\n")
if (!is.null(crop_panel)) {
  cat("Crop data:", nrow(crop_panel), "obs\n")
} else {
  cat("Crop data: NOT AVAILABLE — will use Census worker composition\n")
}
cat("\nAll data saved to:", data_dir, "\n")
