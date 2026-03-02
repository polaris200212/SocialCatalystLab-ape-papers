# =============================================================================
# 02_clean_data.R - Data Cleaning and Border Segment Analysis
# v2: CRITICAL FIX - Proper same-language border filter using per-segment
#     distances. Each municipality's distance is computed to its nearest
#     border SEGMENT, and same-language status verified on BOTH sides.
# =============================================================================

get_this_script_dir <- function() {
  for (i in seq_len(sys.nframe())) {
    if (!is.null(sys.frame(i)$ofile)) return(dirname(sys.frame(i)$ofile))
  }
  return(getwd())
}
script_dir <- get_this_script_dir()
source(file.path(script_dir, "00_packages.R"))

# =============================================================================
# 1. Load Raw Data
# =============================================================================
voting_data <- readRDS(file.path(data_dir, "voting_data.rds"))
canton_treatment <- readRDS(file.path(data_dir, "canton_treatment.rds"))

has_spatial <- file.exists(file.path(data_dir, "gemeinde_boundaries.rds"))
if (has_spatial) {
  gemeinde_sf <- readRDS(file.path(data_dir, "gemeinde_boundaries.rds"))
}

# Canton boundaries
kanton_sf <- tryCatch({
  readRDS(file.path(data_dir, "canton_boundaries.rds"))
}, error = function(e) {
  if (has_spatial) {
    ktnr_col <- names(gemeinde_sf)[grepl("KTNR|kantonsnummer", names(gemeinde_sf), ignore.case = TRUE)]
    if (length(ktnr_col) > 0) {
      gemeinde_sf %>%
        group_by(!!sym(ktnr_col[1])) %>%
        summarise(.groups = "drop")
    }
  }
})

# =============================================================================
# 2. Standardize Column Names
# =============================================================================
if (has_spatial) {
  if ("kantonsnummer" %in% names(gemeinde_sf))
    gemeinde_sf <- gemeinde_sf %>% rename(KTNR = kantonsnummer)
  if ("bfs_nummer" %in% names(gemeinde_sf))
    gemeinde_sf <- gemeinde_sf %>% rename(mun_id = bfs_nummer)

  # Canton lookup
  canton_lookup <- tibble(
    KTNR = 1:26,
    canton_abbr = c("ZH", "BE", "LU", "UR", "SZ", "OW", "NW", "GL", "ZG", "FR",
                    "SO", "BS", "BL", "SH", "AR", "AI", "SG", "GR", "AG", "TG",
                    "TI", "VD", "VS", "NE", "GE", "JU")
  )

  if (!"canton_abbr" %in% names(gemeinde_sf)) {
    ktnr <- names(gemeinde_sf)[grepl("KTNR|KANTONSNUM", names(gemeinde_sf))]
    if (length(ktnr) > 0) {
      if (ktnr[1] != "KTNR") gemeinde_sf <- gemeinde_sf %>% rename(KTNR = all_of(ktnr[1]))
      gemeinde_sf <- gemeinde_sf %>% left_join(canton_lookup, by = "KTNR")
    }
  }

  # Compute centroids
  gemeinde_centroids <- gemeinde_sf %>%
    st_centroid() %>%
    st_coordinates() %>%
    as_tibble() %>%
    rename(centroid_x = X, centroid_y = Y)
  gemeinde_sf <- gemeinde_sf %>% bind_cols(gemeinde_centroids)
}

# =============================================================================
# 3. CRITICAL FIX: Per-Segment Border Distances
# =============================================================================
# The v1 code computed distance to the POOLED border (union of all treated-
# control boundaries), then naively filtered by canton language. This doesn't
# verify that the NEAREST border segment is actually a same-language crossing.
#
# v2 approach:
#   1. Compute individual border segments between each treated-control pair
#   2. For each municipality, find the NEAREST segment
#   3. Record which segment (and thus which canton pair) it belongs to
#   4. Mark segments as same-language or cross-language based on BOTH sides
# =============================================================================

if (has_spatial && !is.null(kanton_sf)) {
  message("\n=== COMPUTING PER-SEGMENT BORDER DISTANCES ===")

  # Prepare canton data
  ktnr_col_k <- names(kanton_sf)[grepl("KTNR|kantonsnummer|KANTONSNUM", names(kanton_sf), ignore.case = TRUE)]
  if (length(ktnr_col_k) > 0 && ktnr_col_k[1] != "canton_id") {
    kanton_sf <- kanton_sf %>% rename(canton_id = all_of(ktnr_col_k[1]))
  }

  kanton_with_treatment <- kanton_sf %>%
    left_join(canton_lookup %>% rename(canton_id = KTNR), by = "canton_id") %>%
    filter(!is.na(canton_abbr)) %>%  # Exclude lake/border territory (canton_id=27)
    left_join(canton_treatment %>% select(-canton_id), by = "canton_abbr") %>%
    mutate(treated = coalesce(treated, FALSE))

  treated_ids <- kanton_with_treatment %>%
    filter(treated == TRUE) %>%
    pull(canton_id)

  # Get individual border segments
  segments <- get_border_segments(kanton_with_treatment, treated_ids, canton_id_col = "canton_id")
  message(paste("Found", length(segments), "border segments"))

  # Classify each segment as same-language or cross-language
  lang_lookup <- canton_treatment %>% select(canton_id, lang)

  for (k in seq_along(segments)) {
    t_lang <- lang_lookup$lang[lang_lookup$canton_id == segments[[k]]$treated_id]
    c_lang <- lang_lookup$lang[lang_lookup$canton_id == segments[[k]]$control_id]
    segments[[k]]$same_language <- (t_lang == c_lang)
    t_abbr <- canton_treatment$canton_abbr[canton_treatment$canton_id == segments[[k]]$treated_id]
    c_abbr <- canton_treatment$canton_abbr[canton_treatment$canton_id == segments[[k]]$control_id]
    segments[[k]]$pair_label <- paste0(t_abbr, "-", c_abbr)
    segments[[k]]$treated_lang <- t_lang
    segments[[k]]$control_lang <- c_lang
    message(paste("  Segment", k, ":", segments[[k]]$pair_label,
                  "(", t_lang, "-", c_lang, ",",
                  ifelse(segments[[k]]$same_language, "SAME", "CROSS"), "language)"))
  }

  # Compute distance from each municipality to each segment
  message("\nComputing per-segment distances for each municipality...")

  gemeinde_points <- st_as_sf(gemeinde_sf, coords = c("centroid_x", "centroid_y"),
                               crs = st_crs(gemeinde_sf))

  # Distance matrix: rows = municipalities, cols = segments
  dist_matrix <- matrix(NA_real_, nrow = nrow(gemeinde_points), ncol = length(segments))
  for (k in seq_along(segments)) {
    dist_matrix[, k] <- as.numeric(st_distance(gemeinde_points, segments[[k]]$geom))
  }

  # For each municipality, find nearest segment
  nearest_segment <- apply(dist_matrix, 1, which.min)
  nearest_distance <- apply(dist_matrix, 1, min)

  # Build the analysis dataset
  gemeinde_sf <- gemeinde_sf %>%
    mutate(
      nearest_segment_idx = nearest_segment,
      dist_to_nearest_border = nearest_distance / 1000,  # Convert to km
      nearest_pair = sapply(nearest_segment, function(k) segments[[k]]$pair_label),
      nearest_same_language = sapply(nearest_segment, function(k) segments[[k]]$same_language),
      nearest_treated_id = sapply(nearest_segment, function(k) segments[[k]]$treated_id),
      nearest_control_id = sapply(nearest_segment, function(k) segments[[k]]$control_id)
    )

  # Add treatment status and sign the distance
  gemeinde_sf <- gemeinde_sf %>%
    left_join(canton_treatment %>% select(canton_abbr, treated, lang), by = "canton_abbr") %>%
    mutate(
      signed_distance_km = ifelse(treated, dist_to_nearest_border, -dist_to_nearest_border)
    )

  # Print summary of municipality-border pair assignments
  message("\n=== MUNICIPALITY-BORDER PAIR SUMMARY ===")
  pair_counts <- gemeinde_sf %>%
    st_drop_geometry() %>%
    count(nearest_pair, nearest_same_language) %>%
    arrange(nearest_pair)
  print(pair_counts)

  same_lang_count <- sum(gemeinde_sf$nearest_same_language, na.rm = TRUE)
  cross_lang_count <- sum(!gemeinde_sf$nearest_same_language, na.rm = TRUE)
  message(paste("\nSame-language nearest border:", same_lang_count, "municipalities"))
  message(paste("Cross-language nearest border:", cross_lang_count, "municipalities"))

  # Also compute distance to pooled border (for comparison)
  pooled_border <- get_policy_border(kanton_with_treatment, treated_ids, canton_id_col = "canton_id")
  if (!st_is_empty(pooled_border)) {
    pooled_dist <- as.numeric(st_distance(gemeinde_points, pooled_border))
    gemeinde_sf$dist_to_pooled_border_km <- pooled_dist / 1000
    gemeinde_sf$pooled_signed_distance_km <- ifelse(gemeinde_sf$treated,
                                                     gemeinde_sf$dist_to_pooled_border_km,
                                                     -gemeinde_sf$dist_to_pooled_border_km)
  }
} else {
  message("No spatial data available - skipping border distance computation")
}

# =============================================================================
# 4. Create Final Analysis Dataset
# =============================================================================
message("\n=== CREATING ANALYSIS DATASET ===")

if (has_spatial) {
  analysis_df <- gemeinde_sf %>%
    st_drop_geometry() %>%
    left_join(
      voting_data %>% select(mun_id, yes_share, turnout, eligible_voters, yes_votes, no_votes, vote_type),
      by = "mun_id"
    ) %>%
    filter(!is.na(yes_share)) %>%
    mutate(
      near_border = abs(signed_distance_km) < 30,
      log_pop = log(eligible_voters + 1),
      urban = as.numeric(eligible_voters >= 5000)
    )

  message(paste("Analysis sample:", nrow(analysis_df), "municipalities"))
  message(paste("Near border (30km):", sum(analysis_df$near_border, na.rm = TRUE)))

  # Create the same-language subsample (CORRECTLY filtered)
  same_lang_df <- analysis_df %>%
    filter(nearest_same_language == TRUE)

  message(paste("Same-language border subsample:", nrow(same_lang_df)))

  saveRDS(analysis_df, file.path(data_dir, "analysis_data.rds"))
  saveRDS(gemeinde_sf, file.path(data_dir, "gemeinde_spatial.rds"))
} else {
  # Non-spatial fallback
  analysis_df <- voting_data %>%
    filter(!is.na(yes_share)) %>%
    mutate(
      log_pop = log(eligible_voters + 1),
      urban = as.numeric(eligible_voters >= 5000)
    )
  saveRDS(analysis_df, file.path(data_dir, "analysis_data.rds"))
}

message("\n=== DATA CLEANING COMPLETE ===")
