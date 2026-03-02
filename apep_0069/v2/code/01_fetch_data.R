# =============================================================================
# 01_fetch_data.R - Data Acquisition
# v2: Fixed BL adoption year (2015, not 2016), added LexFind provenance,
#     added placebo referendum fetching.
#     Uses direct voteinfo JSON API (ogd-static.voteinfo-app.ch) since
#     opendata.swiss API is down as of 2026.
# =============================================================================

get_this_script_dir <- function() {
  for (i in seq_len(sys.nframe())) {
    if (!is.null(sys.frame(i)$ofile)) return(dirname(sys.frame(i)$ofile))
  }
  return(getwd())
}
script_dir <- get_this_script_dir()
source(file.path(script_dir, "00_packages.R"))

dir.create(data_dir, showWarnings = FALSE, recursive = TRUE)

# =============================================================================
# Helper: Fetch vote data from voteinfo JSON API
# =============================================================================
# The swissdd package's opendata.swiss endpoint is down. Use the static
# voteinfo JSON API directly. URL pattern:
#   https://ogd-static.voteinfo-app.ch/v1/ogd/sd-t-17-02-{YYYYMMDD}-eidgAbstimmung.json
# Each JSON contains all votes on that date, with municipality-level results.

fetch_voteinfo <- function(date_str, vorlage_idx = NULL, vorlage_pattern = NULL) {
  # date_str: "YYYYMMDD" format
  url <- paste0("https://ogd-static.voteinfo-app.ch/v1/ogd/sd-t-17-02-",
                date_str, "-eidgAbstimmung.json")
  message(paste("  Fetching:", url))

  resp <- tryCatch(httr::GET(url, httr::timeout(30)), error = function(e) {
    message(paste("  HTTP error:", e$message))
    NULL
  })

  if (is.null(resp) || httr::status_code(resp) != 200) {
    message(paste("  Failed with status:", if (!is.null(resp)) httr::status_code(resp) else "NULL"))
    return(NULL)
  }

  txt <- httr::content(resp, "text", encoding = "UTF-8")
  data <- jsonlite::fromJSON(txt)

  vorlagen <- data$schweiz$vorlagen
  n_vorlagen <- nrow(vorlagen)
  message(paste("  Found", n_vorlagen, "vote(s) on", date_str))

  # Select vorlage by index or pattern match on title
  if (!is.null(vorlage_pattern)) {
    # Search titles for pattern match
    titles <- sapply(seq_len(n_vorlagen), function(i) {
      tt <- vorlagen$vorlagenTitel[[i]]
      if (is.data.frame(tt)) paste(tt[,1], collapse = " | ") else paste(tt, collapse = " | ")
    })
    match_idx <- grep(vorlage_pattern, titles, ignore.case = TRUE)
    if (length(match_idx) == 0) {
      message(paste("  No title matched pattern:", vorlage_pattern))
      message(paste("  Available titles:", paste(titles, collapse = "; ")))
      return(NULL)
    }
    vorlage_idx <- match_idx[1]
    message(paste("  Selected vorlage", vorlage_idx, ":", titles[vorlage_idx]))
  } else if (is.null(vorlage_idx)) {
    vorlage_idx <- 1
  }

  # Extract municipality-level data from the selected vorlage
  kantone <- vorlagen$kantone[[vorlage_idx]]
  votedate <- data$abstimmtag

  rows <- list()
  for (k in seq_len(nrow(kantone))) {
    canton_id <- kantone$geoLevelnummer[k]
    canton_name <- kantone$geoLevelname[k]
    gem <- kantone$gemeinden[[k]]
    if (is.null(gem) || nrow(gem) == 0) next

    res <- gem$resultat
    rows[[k]] <- tibble(
      mun_id = as.integer(gem$geoLevelnummer),
      mun_name = gem$geoLevelname,
      canton_id = as.integer(canton_id),
      canton_name = canton_name,
      jaStimmenInProzent = res$jaStimmenInProzent,
      jaStimmenAbsolut = res$jaStimmenAbsolut,
      neinStimmenAbsolut = res$neinStimmenAbsolut,
      stimmbeteiligungInProzent = res$stimmbeteiligungInProzent,
      anzahlStimmberechtigte = res$anzahlStimmberechtigte,
      votedate = votedate
    )
  }

  result <- bind_rows(rows)
  message(paste("  Extracted", nrow(result), "municipality observations"))
  return(result)
}

# =============================================================================
# 1. Fetch Main Referendum Data (Energy Strategy 2050, May 21, 2017)
# =============================================================================
message("=== FETCHING GEMEINDE-LEVEL VOTING DATA ===")

message("\n1. Energy Strategy 2050 (May 2017)...")
energy_vote <- fetch_voteinfo("20170521")  # Only one vote on this date

if (!is.null(energy_vote) && nrow(energy_vote) > 0) {
  message(paste("   Got", nrow(energy_vote), "gemeinde observations"))
} else {
  stop("FATAL: Could not fetch Energy Strategy 2050 referendum data")
}

energy_df <- energy_vote %>%
  select(
    mun_id, mun_name, canton_id, canton_name,
    yes_share = jaStimmenInProzent,
    yes_votes = jaStimmenAbsolut,
    no_votes = neinStimmenAbsolut,
    turnout = stimmbeteiligungInProzent,
    eligible_voters = anzahlStimmberechtigte,
    votedate
  ) %>%
  mutate(vote_type = "energy_2017")

# =============================================================================
# 2. Fetch Placebo Referendums (non-energy, same period)
# =============================================================================
message("\n=== FETCHING PLACEBO REFERENDUMS ===")

# Immigration initiative (Feb 9, 2014) - Masseneinwanderungsinitiative
message("2a. Immigration initiative (Feb 2014)...")
immigration_2014 <- fetch_voteinfo("20140209", vorlage_pattern = "wanderung|immigration|Masseneinwander")
if (is.null(immigration_2014) || nrow(immigration_2014) == 0) {
  # Fallback: just take the first vorlage
  immigration_2014 <- fetch_voteinfo("20140209", vorlage_idx = 1)
}

# Healthcare initiative (Sep 28, 2014) - Einheitskasse
message("\n2b. Healthcare initiative (Sep 2014)...")
healthcare_2014 <- fetch_voteinfo("20140928", vorlage_pattern = "gesundheit|kasse|pr.mien|caisse")
if (is.null(healthcare_2014) || nrow(healthcare_2014) == 0) {
  healthcare_2014 <- fetch_voteinfo("20140928", vorlage_idx = 1)
}

# Service public initiative (Jun 5, 2016) - Pro Service public
message("\n2c. Service public initiative (Jun 2016)...")
service_2016 <- fetch_voteinfo("20160605", vorlage_pattern = "service|public|grundversorgung")
if (is.null(service_2016) || nrow(service_2016) == 0) {
  service_2016 <- fetch_voteinfo("20160605", vorlage_idx = 1)
}

# =============================================================================
# 3. Fetch Historical Energy Referendums (for panel)
# =============================================================================
message("\n=== FETCHING HISTORICAL ENERGY REFERENDUMS ===")

# 2000 Solar Initiative (Sep 24, 2000) - 3 energy votes on this date
message("3a. 2000 Solar/Energy Initiative...")
votes_2000 <- fetch_voteinfo("20000924", vorlage_pattern = "solar|energie|energy|f.rder")
if (is.null(votes_2000) || nrow(votes_2000) == 0) {
  votes_2000 <- fetch_voteinfo("20000924", vorlage_idx = 1)
}

# 2003 Electricity Without Nuclear (May 18, 2003)
message("\n3b. 2003 Nuclear Moratorium...")
votes_2003 <- fetch_voteinfo("20030518", vorlage_pattern = "strom|nuclear|moratorium|atom|kern")
if (is.null(votes_2003) || nrow(votes_2003) == 0) {
  votes_2003 <- fetch_voteinfo("20030518", vorlage_idx = 1)
}

# 2016 Nuclear Phase-Out (Nov 27, 2016)
message("\n3c. 2016 Nuclear Phase-Out...")
votes_2016 <- fetch_voteinfo("20161127", vorlage_pattern = "ausstieg|atom|kern|nuclear")
if (is.null(votes_2016) || nrow(votes_2016) == 0) {
  votes_2016 <- fetch_voteinfo("20161127", vorlage_idx = 1)
}

# =============================================================================
# 4. Define Treatment (CORRECTED adoption years and provenance)
# =============================================================================
message("\n=== DEFINING TREATMENT ===")

# CRITICAL FIX: BL adoption year is 2015, not 2016
# All sources verified via LexFind.ch (see 00_packages.R for URLs)
canton_treatment <- tribble(
  ~canton_id, ~canton_abbr, ~adoption_year, ~in_force_year, ~entry_force_date, ~treated,
  # Treated (energy law in force before May 2017)
  18, "GR", 2010, 2011, "2011-01-01", TRUE,   # Graubünden
  2,  "BE", 2011, 2012, "2012-01-01", TRUE,   # Bern
  19, "AG", 2012, 2013, "2013-01-01", TRUE,   # Aargau
  13, "BL", 2015, 2016, "2016-07-01", TRUE,   # Basel-Landschaft (FIXED: was 2016)
  12, "BS", 2016, 2017, "2017-01-01", TRUE,   # Basel-Stadt
  # Control cantons
  1,  "ZH", NA, NA, NA, FALSE,
  3,  "LU", 2017, 2018, "2018-01-01", FALSE,
  4,  "UR", NA, NA, NA, FALSE,
  5,  "SZ", NA, NA, NA, FALSE,
  6,  "OW", NA, NA, NA, FALSE,
  7,  "NW", NA, NA, NA, FALSE,
  8,  "GL", NA, NA, NA, FALSE,
  9,  "ZG", NA, NA, NA, FALSE,
  10, "FR", 2019, 2020, "2020-01-01", FALSE,
  11, "SO", NA, NA, NA, FALSE,
  14, "SH", NA, NA, NA, FALSE,
  15, "AR", NA, NA, NA, FALSE,
  16, "AI", 2020, 2021, "2021-01-01", FALSE,
  17, "SG", NA, NA, NA, FALSE,
  20, "TG", NA, NA, NA, FALSE,
  21, "TI", NA, NA, NA, FALSE,
  22, "VD", NA, NA, NA, FALSE,
  23, "VS", NA, NA, NA, FALSE,
  24, "NE", NA, NA, NA, FALSE,
  25, "GE", NA, NA, NA, FALSE,
  26, "JU", NA, NA, NA, FALSE
)

# Language region (canton level, BFS classification)
canton_treatment <- canton_treatment %>%
  mutate(
    lang = case_when(
      canton_abbr %in% c("GE", "VD", "NE", "JU") ~ "French",
      canton_abbr %in% c("FR", "VS") ~ "French",
      canton_abbr == "TI" ~ "Italian",
      TRUE ~ "German"
    )
  )

message("Treated cantons:")
print(canton_treatment %>% filter(treated) %>% select(canton_abbr, adoption_year, in_force_year))

# =============================================================================
# 5. Fetch Spatial Data
# =============================================================================
message("\n=== FETCHING SPATIAL DATA ===")

message("1. Downloading gemeinde boundaries from BFS...")
gemeinde_sf <- tryCatch({
  bfs_get_base_maps(geom = "polg", category = "gf", date = "2017-01-01")
}, error = function(e) {
  message("   BFS failed, trying swisstopo...")
  NULL
})

if (is.null(gemeinde_sf)) {
  tryCatch({
    api_url <- "https://data.geo.admin.ch/ch.swisstopo.swissboundaries3d/swissboundaries3d_2025-01/swissboundaries3d_2025-01_2056_5728.gpkg.zip"
    temp_zip <- tempfile(fileext = ".zip")
    download.file(api_url, temp_zip, mode = "wb", quiet = TRUE, timeout = 120)
    temp_dir <- tempdir()
    unzip(temp_zip, exdir = temp_dir)
    gpkg_files <- list.files(temp_dir, pattern = "\\.gpkg$", full.names = TRUE, recursive = TRUE)
    if (length(gpkg_files) > 0) {
      layers <- st_layers(gpkg_files[1])
      gem_layer <- layers$name[grepl("gemeinde|municipality|hoheitsgebiet", layers$name, ignore.case = TRUE)]
      if (length(gem_layer) > 0) {
        gemeinde_sf <- st_read(gpkg_files[1], layer = gem_layer[1], quiet = TRUE)
        message(paste("   Loaded", nrow(gemeinde_sf), "gemeinde boundaries"))
      }
    }
  }, error = function(e) {
    message(paste("   Alternative source failed:", e$message))
  })
}

if (!exists("gemeinde_sf") || is.null(gemeinde_sf)) {
  message("   Spatial boundaries not available - will use non-spatial analysis")
  gemeinde_sf <- NULL
}

message("2. Downloading canton boundaries...")
canton_sf <- tryCatch({
  bfs_get_base_maps(geom = "polg", category = "kf", date = "2017-01-01")
}, error = function(e) NULL)

if (is.null(canton_sf) && !is.null(gemeinde_sf)) {
  ktnr_col <- names(gemeinde_sf)[grepl("KTNR|kantonsnummer", names(gemeinde_sf), ignore.case = TRUE)]
  if (length(ktnr_col) > 0) {
    canton_sf <- gemeinde_sf %>%
      group_by(!!sym(ktnr_col[1])) %>%
      summarise(.groups = "drop")
  }
}

# =============================================================================
# 6. Merge and Save
# =============================================================================
message("\n=== MERGING DATA ===")

voting_data <- energy_df %>%
  left_join(canton_treatment %>% select(canton_id, canton_abbr, treated, lang, adoption_year, in_force_year),
            by = "canton_id")

message(paste("   Treated gemeinden:", sum(voting_data$treated)))
message(paste("   Control gemeinden:", sum(!voting_data$treated)))

# Merge with spatial data
voting_sf <- NULL
if (!is.null(gemeinde_sf)) {
  id_col <- names(gemeinde_sf)[str_detect(names(gemeinde_sf), "GMDNR|BFS_NR|mun_id|GDENR|bfs_nummer")]
  if (length(id_col) > 0) {
    voting_sf <- gemeinde_sf %>%
      rename(mun_id = all_of(id_col[1])) %>%
      mutate(mun_id = as.integer(mun_id)) %>%
      left_join(voting_data, by = "mun_id")
    message(paste("   Spatial merge:", nrow(voting_sf), "gemeinden"))
  }
}

# =============================================================================
# 7. Save All Data
# =============================================================================
message("\n=== SAVING DATA ===")

saveRDS(voting_data, file.path(data_dir, "voting_data.rds"))
saveRDS(canton_treatment, file.path(data_dir, "canton_treatment.rds"))

if (!is.null(voting_sf)) saveRDS(voting_sf, file.path(data_dir, "voting_sf.rds"))
if (!is.null(gemeinde_sf)) saveRDS(gemeinde_sf, file.path(data_dir, "gemeinde_boundaries.rds"))
if (!is.null(canton_sf)) saveRDS(canton_sf, file.path(data_dir, "canton_boundaries.rds"))

# Save historical votes for panel
if (!is.null(votes_2000)) saveRDS(votes_2000, file.path(data_dir, "votes_2000.rds"))
if (!is.null(votes_2003)) saveRDS(votes_2003, file.path(data_dir, "votes_2003.rds"))
if (!is.null(votes_2016)) saveRDS(votes_2016, file.path(data_dir, "votes_2016.rds"))

# Save placebo referendums
if (!is.null(immigration_2014)) saveRDS(immigration_2014, file.path(data_dir, "placebo_immigration_2014.rds"))
if (!is.null(healthcare_2014)) saveRDS(healthcare_2014, file.path(data_dir, "placebo_healthcare_2014.rds"))
if (!is.null(service_2016)) saveRDS(service_2016, file.path(data_dir, "placebo_service_2016.rds"))

message("\n=== DATA ACQUISITION COMPLETE ===")
message(paste("Total gemeinden:", nrow(voting_data)))
message(paste("  Treated:", sum(voting_data$treated)))
message(paste("  Control:", sum(!voting_data$treated)))
