##############################################################################
# 01_fetch_data.R — Data acquisition (revised: multiple fallback approaches)
# APEP-0457: The Lex Weber Shock
##############################################################################

source("00_packages.R")

cat("\n========== PHASE 1: DATA ACQUISITION ==========\n\n")

# ── Helper: HTTP with browser-like headers ───────────────────────────────────
http_get <- function(url, ...) {
  GET(url, add_headers(
    `User-Agent` = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36",
    `Accept` = "application/json, text/csv, */*"
  ), timeout(120), config(followlocation = TRUE), ...)
}

http_post <- function(url, body_json) {
  POST(url,
       body = body_json,
       content_type("application/json"),
       add_headers(
         `User-Agent` = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36",
         `Accept` = "application/json"
       ),
       timeout(120))
}

# ══════════════════════════════════════════════════════════════════════════════
# APPROACH A: Try BFS R package
# ══════════════════════════════════════════════════════════════════════════════
cat("--- Approach A: BFS R package ---\n")

if (requireNamespace("BFS", quietly = TRUE)) {
  library(BFS)

  cat("Searching BFS catalog for STATENT...\n")
  tryCatch({
    # Search BFS catalog
    catalog <- bfs_get_catalog(language = "de")
    cat("BFS catalog loaded:", nrow(catalog), "datasets\n")

    # Find STATENT tables
    statent_rows <- catalog[grep("STATENT|Arbeitsstätten|Beschäftigte.*Kanton",
                                 catalog$title, ignore.case = TRUE), ]
    cat("STATENT-related tables:", nrow(statent_rows), "\n")
    if (nrow(statent_rows) > 0) {
      for (i in seq_len(min(5, nrow(statent_rows)))) {
        cat("  ", statent_rows$title[i], "\n")
        cat("    URL:", statent_rows$url[i], "\n")
      }
    }

    # Also search for dwelling/housing tables
    housing_rows <- catalog[grep("Wohnung|Belegung|Gebäude.*Gemeinde",
                                  catalog$title, ignore.case = TRUE), ]
    cat("\nHousing tables:", nrow(housing_rows), "\n")
    if (nrow(housing_rows) > 0) {
      for (i in seq_len(min(5, nrow(housing_rows)))) {
        cat("  ", housing_rows$title[i], "\n")
      }
    }
  }, error = function(e) {
    cat("BFS package error:", e$message, "\n")
  })
} else {
  cat("BFS package not available\n")
}

# ══════════════════════════════════════════════════════════════════════════════
# APPROACH B: BFS PXWeb API with JSON-stat2 (retry with proper headers)
# ══════════════════════════════════════════════════════════════════════════════
cat("\n--- Approach B: BFS PXWeb API with proper headers ---\n")

statent_url <- paste0(
  "https://www.pxweb.bfs.admin.ch/api/v1/de/",
  "px-x-0602010000_101/px-x-0602010000_101.px"
)

# Get metadata first
cat("Fetching STATENT metadata...\n")
meta_resp <- http_get(statent_url)
if (status_code(meta_resp) == 200) {
  meta <- fromJSON(content(meta_resp, as = "text", encoding = "UTF-8"))
  vars <- meta$variables
  cat("Table:", meta$title, "\n")
  cat("Dimensions:", paste(vars$text, collapse = " × "), "\n")

  # Build a SMALLER query: just total employment + FTE, all cantons, all years
  # Focus on 1-digit NOGA aggregates (fewer sectors)
  year_vals <- vars$values[[1]]  # All years
  canton_vals <- vars$values[[2]]  # All cantons
  sector_vals <- vars$values[[3]]  # All sectors (86)
  obs_vals <- vars$values[[4]]  # Observation units

  # Keep only: total employees and FTEs
  obs_keep <- obs_vals[c(1, 2, 5)]  # Arbeitsstätten, Beschäftigte, VZÄ
  cat("Obs units selected:", paste(vars$valueTexts[[4]][c(1,2,5)], collapse = ", "), "\n")

  # Download year by year with only key variables
  cat("\nDownloading STATENT data year by year...\n")
  all_statent <- list()

  for (yr in year_vals) {
    cat("  Year", yr, "... ")

    q <- list(
      query = list(
        list(code = vars$code[1],
             selection = list(filter = "item", values = list(yr))),
        list(code = vars$code[2],
             selection = list(filter = "item", values = as.list(canton_vals))),
        list(code = vars$code[3],
             selection = list(filter = "item", values = as.list(sector_vals))),
        list(code = vars$code[4],
             selection = list(filter = "item", values = as.list(obs_keep)))
      ),
      response = list(format = "json-stat2")
    )

    body_json <- toJSON(q, auto_unbox = TRUE)

    resp <- tryCatch(
      http_post(statent_url, body_json),
      error = function(e) { cat("error:", e$message, "\n"); NULL }
    )

    if (!is.null(resp) && status_code(resp) == 200) {
      json_data <- fromJSON(content(resp, as = "text", encoding = "UTF-8"))

      # Parse JSON-stat2
      dims <- json_data$dimension
      dim_names <- names(dims)
      dim_labels <- lapply(dim_names, function(d) {
        idx <- dims[[d]]$category$index
        lbl <- dims[[d]]$category$label
        ordered_labels <- lbl[names(sort(unlist(idx)))]
        unname(ordered_labels)
      })
      names(dim_labels) <- dim_names

      grid <- expand.grid(dim_labels, stringsAsFactors = FALSE, KEEP.OUT.ATTRS = FALSE)
      grid$value <- json_data$value
      all_statent[[yr]] <- grid
      cat("OK (", nrow(grid), "rows)\n")
    } else {
      status <- if (!is.null(resp)) status_code(resp) else "NULL"
      cat("FAILED (", status, ")\n")

      # If 403, try CSV format instead
      if (!is.null(resp) && status_code(resp) == 403) {
        cat("    Trying CSV format...\n")
        q$response$format <- "csv"
        body_csv <- toJSON(q, auto_unbox = TRUE)
        resp_csv <- tryCatch(http_post(statent_url, body_csv), error = function(e) NULL)
        if (!is.null(resp_csv)) {
          cat("    CSV status:", status_code(resp_csv), "\n")
          if (status_code(resp_csv) == 200) {
            csv_text <- content(resp_csv, as = "text", encoding = "UTF-8")
            df <- read_csv(csv_text, show_col_types = FALSE)
            all_statent[[yr]] <- df
            cat("    CSV OK (", nrow(df), "rows)\n")
          }
        }
      }
    }
    Sys.sleep(1)
  }

  if (length(all_statent) > 0) {
    statent_df <- bind_rows(all_statent) %>% as_tibble()
    write_csv(statent_df, file.path(data_dir, "statent_canton_sector_raw.csv"))
    cat("\nSaved STATENT data:", nrow(statent_df), "rows\n")
  } else {
    cat("\nWARNING: No STATENT data downloaded from PXWeb API\n")
  }
}

# ══════════════════════════════════════════════════════════════════════════════
# APPROACH C: BFS DAM-API for direct asset downloads
# ══════════════════════════════════════════════════════════════════════════════
cat("\n--- Approach C: BFS DAM-API direct downloads ---\n")

# The BFS provides data assets at dam-api.bfs.admin.ch
# STATENT data is available as Excel/CSV downloads

# Try known STATENT asset IDs
statent_assets <- c(
  "px-x-0602010000_101" = "https://www.bfs.admin.ch/bfsstatic/dam/assets/32189359/master",
  "statent_sectors" = "https://dam-api.bfs.admin.ch/hub/api/dam/assets/32189359/master"
)

for (name in names(statent_assets)) {
  url <- statent_assets[[name]]
  dest <- file.path(data_dir, paste0(name, ".px"))
  cat("Trying", name, "from DAM...\n")
  resp <- tryCatch(http_get(url, write_disk(dest, overwrite = TRUE)),
                   error = function(e) NULL)
  if (!is.null(resp)) {
    cat("  Status:", status_code(resp), " Size:", file.info(dest)$size, "bytes\n")
  }
}

# ══════════════════════════════════════════════════════════════════════════════
# APPROACH D: Construct core data from reliable known sources
# ══════════════════════════════════════════════════════════════════════════════
cat("\n--- Approach D: Constructing data from known reliable sources ---\n")

# If API approaches fail, we use known-good BFS asset download URLs
# BFS publishes STAT-TAB extracts that can be downloaded directly

# 1. Try the PXWeb interactive download as px file
px_download_url <- paste0(
  "https://www.pxweb.bfs.admin.ch/api/v1/de/",
  "px-x-0602010000_101/px-x-0602010000_101.px"
)

# Try downloading the .px file directly (GET, not POST)
cat("Downloading .px file directly...\n")
px_file <- file.path(data_dir, "statent_canton_sector.px")
resp <- tryCatch(
  http_get(px_download_url, write_disk(px_file, overwrite = TRUE)),
  error = function(e) NULL
)
if (!is.null(resp)) {
  cat("  Status:", status_code(resp), " Size:", file.info(px_file)$size, "bytes\n")
  if (status_code(resp) == 200 && file.info(px_file)$size > 1000) {
    # Parse PX file using pxR or manual parsing
    if (requireNamespace("pxR", quietly = TRUE)) {
      library(pxR)
      px_data <- read.px(px_file)
      statent_df <- as_tibble(px_data$DATA$value)
      cat("  Parsed PX file:", nrow(statent_df), "rows\n")
    } else {
      cat("  PX file downloaded but pxR package not available for parsing\n")
      cat("  Install with: install.packages('pxR')\n")
    }
  }
}

# ══════════════════════════════════════════════════════════════════════════════
# APPROACH E: Use BFS STAT-TAB web interface to get direct CSV download links
# ══════════════════════════════════════════════════════════════════════════════
cat("\n--- Approach E: Try known BFS STAT-TAB CSV asset URLs ---\n")

# BFS publishes downloadable files at bfs.admin.ch/asset/
# These are stable URLs for common datasets

# STATENT: Employment by canton and economic activity
# Try fetching the landing page to find download links
bfs_landing <- "https://www.bfs.admin.ch/bfs/en/home/statistics/industry-services/businesses-employment/jobs-statistics/employed-persons-noga.assetdetail.32189359.html"
cat("Checking BFS asset landing page...\n")
resp <- tryCatch(http_get(bfs_landing), error = function(e) NULL)
if (!is.null(resp)) cat("  Status:", status_code(resp), "\n")

# Try common BFS asset download pattern
# The px-x-0602010000_101 might have a direct download ID
for (asset_id in c("32189359", "32189370", "32189380")) {
  url <- paste0("https://dam-api.bfs.admin.ch/hub/api/dam/assets/", asset_id, "/master")
  cat("  Trying asset", asset_id, "... ")
  resp <- tryCatch(http_get(url), error = function(e) NULL)
  if (!is.null(resp)) {
    ct <- resp$headers$`content-type`
    sz <- resp$headers$`content-length`
    cat("Status:", status_code(resp), "Type:", ct, "Size:", sz, "\n")
    if (status_code(resp) == 200 && !is.null(sz) && as.numeric(sz) > 1000) {
      dest <- file.path(data_dir, paste0("bfs_asset_", asset_id, ".xlsx"))
      writeBin(content(resp, as = "raw"), dest)
      cat("    Saved to:", dest, "\n")
    }
  } else {
    cat("failed\n")
  }
}

# ══════════════════════════════════════════════════════════════════════════════
# APPROACH F: Swiss Geoportal for second home data
# ══════════════════════════════════════════════════════════════════════════════
cat("\n--- Approach F: ARE Zweitwohnungen data ---\n")

# The ARE publishes Zweitwohnungsanteil through the Swiss Geoportal
# Try the GeoAdmin API
cat("Searching Swiss Geoportal (api3.geo.admin.ch)...\n")
geo_search_url <- paste0(
  "https://api3.geo.admin.ch/rest/services/api/SearchServer?",
  "searchText=Zweitwohnung&type=layers&lang=de"
)
resp <- tryCatch(http_get(geo_search_url), error = function(e) NULL)
if (!is.null(resp) && status_code(resp) == 200) {
  geo_results <- fromJSON(content(resp, as = "text", encoding = "UTF-8"))
  if (!is.null(geo_results$results) && length(geo_results$results) > 0) {
    cat("Geoportal layers found:\n")
    for (r in geo_results$results) {
      cat("  ", r$attrs$label, "\n")
      cat("    Layer:", r$attrs$layer, "\n")
    }
  } else {
    cat("No Zweitwohnung layers found on Geoportal\n")
  }
}

# Try direct ARE website for the Zweitwohnungsinventar
are_url <- "https://www.are.admin.ch/are/de/home/raumentwicklung-und-raumplanung/raumplanungsrecht/zweitwohnungen/zweitwohnungsinventar.html"
cat("\nChecking ARE Zweitwohnungsinventar page...\n")
resp <- tryCatch(http_get(are_url), error = function(e) NULL)
if (!is.null(resp)) {
  cat("  Status:", status_code(resp), "\n")
  if (status_code(resp) == 200) {
    page_text <- content(resp, as = "text", encoding = "UTF-8")
    # Look for download links (.xlsx, .csv, .zip)
    links <- regmatches(page_text, gregexpr('href="[^"]*\\.(xlsx|csv|zip|xls)"', page_text))[[1]]
    if (length(links) > 0) {
      cat("  Download links found:\n")
      for (l in links) cat("   ", l, "\n")
    } else {
      cat("  No direct download links found in HTML\n")
    }

    # Check for dam-api links
    dam_links <- regmatches(page_text, gregexpr('dam/assets/[0-9]+', page_text))[[1]]
    if (length(dam_links) > 0) {
      cat("  DAM asset links found:\n")
      for (l in unique(dam_links)) {
        cat("   ", l, "\n")
        # Try downloading
        asset_url <- paste0("https://dam-api.bfs.admin.ch/hub/api/", l, "/master")
        resp2 <- tryCatch(http_get(asset_url), error = function(e) NULL)
        if (!is.null(resp2) && status_code(resp2) == 200) {
          sz <- length(content(resp2, as = "raw"))
          if (sz > 1000) {
            dest <- file.path(data_dir, paste0(gsub("/", "_", l), ".bin"))
            writeBin(content(resp2, as = "raw"), dest)
            cat("      Downloaded:", sz, "bytes →", dest, "\n")
          }
        }
      }
    }
  }
}

# ══════════════════════════════════════════════════════════════════════════════
# SUMMARY
# ══════════════════════════════════════════════════════════════════════════════
cat("\n\n========== DATA ACQUISITION SUMMARY ==========\n")
cat("Files in data directory:\n")
data_files <- list.files(data_dir, full.names = TRUE)
if (length(data_files) > 0) {
  for (f in data_files) {
    cat("  ", basename(f), ":", round(file.info(f)$size / 1024, 1), "KB\n")
  }
} else {
  cat("  (no files downloaded)\n")
  cat("\n  FALLBACK NEEDED: APIs returned 403.\n")
  cat("  Will construct synthetic-free dataset from reliable sources in 01b_fetch_data.R\n")
}
