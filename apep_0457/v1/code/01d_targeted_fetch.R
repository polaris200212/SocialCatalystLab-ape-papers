##############################################################################
# 01d_targeted_fetch.R — Direct targeted downloads
# APEP-0457: The Lex Weber Shock
##############################################################################

source("00_packages.R")

http_get <- function(url, ...) {
  GET(url, add_headers(
    `User-Agent` = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36"
  ), timeout(120), config(followlocation = TRUE), ...)
}
http_post <- function(url, body_json) {
  POST(url, body = body_json, content_type("application/json"),
       add_headers(`User-Agent` = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)"),
       timeout(120))
}

pxweb_base <- "https://www.pxweb.bfs.admin.ch/api/v1/de/"

# ══════════════════════════════════════════════════════════════════════════════
# 1. STATENT municipality table (px-x-0602010000_103)
# ══════════════════════════════════════════════════════════════════════════════
cat("--- STATENT municipality table (px-x-0602010000_103) ---\n")

# Try the direct PXWeb table that should be municipality × sector
for (tbl_num in c("103", "102", "105", "106", "107", "108", "109")) {
  tbl_id <- paste0("px-x-0602010000_", tbl_num)
  tbl_url <- paste0(pxweb_base, tbl_id, "/", tbl_id, ".px")

  cat("Checking", tbl_id, "... ")
  resp <- tryCatch(http_get(tbl_url), error = function(e) NULL)
  if (!is.null(resp) && status_code(resp) == 200) {
    m <- tryCatch(fromJSON(content(resp, as = "text", encoding = "UTF-8")),
                  error = function(e) NULL)
    if (!is.null(m) && !is.null(m$variables)) {
      cat("FOUND: ", m$title, "\n")
      for (v in seq_along(m$variables$code)) {
        nv <- length(m$variables$values[[v]])
        cat("  ", m$variables$text[v], "(", nv, "values)\n")
        if (nv <= 10) {
          cat("    Values:", paste(m$variables$valueTexts[[v]], collapse = ", "), "\n")
        } else {
          cat("    First:", paste(head(m$variables$valueTexts[[v]], 5), collapse = ", "), "\n")
        }
      }

      # Check if this has Gemeinde data (> 100 geographic values = municipalities)
      geo_idx <- which(sapply(m$variables$values, length) > 100)
      if (length(geo_idx) > 0) {
        cat("  ** HAS MUNICIPALITY DATA (dim", geo_idx, "has",
            length(m$variables$values[[geo_idx[1]]]), "values) **\n")

        # Download year by year
        year_vals <- m$variables$values[[1]]
        cat("  Downloading", length(year_vals), "years...\n")

        muni_data <- list()
        for (yr in year_vals) {
          q <- list(
            query = lapply(seq_along(m$variables$code), function(vi) {
              if (vi == 1) {
                list(code = m$variables$code[vi],
                     selection = list(filter = "item", values = list(yr)))
              } else {
                list(code = m$variables$code[vi],
                     selection = list(filter = "all", values = list("*")))
              }
            }),
            response = list(format = "json-stat2")
          )
          body <- toJSON(q, auto_unbox = TRUE)
          dr <- tryCatch(http_post(paste0(pxweb_base, tbl_id, "/", tbl_id, ".px"),
                                   body), error = function(e) NULL)
          if (!is.null(dr) && status_code(dr) == 200) {
            jd <- fromJSON(content(dr, as = "text", encoding = "UTF-8"))
            dims <- jd$dimension
            dn <- names(dims)
            dl <- lapply(dn, function(d) {
              idx <- dims[[d]]$category$index
              lbl <- dims[[d]]$category$label
              lbl[names(sort(unlist(idx)))]
            })
            names(dl) <- dn
            grid <- expand.grid(dl, stringsAsFactors = FALSE)
            grid$value <- jd$value
            muni_data[[yr]] <- grid
            cat("  Year", yr, ":", nrow(grid), "rows\n")
          } else {
            st <- if (!is.null(dr)) status_code(dr) else "ERR"
            cat("  Year", yr, ": FAILED (", st, ")\n")
          }
          Sys.sleep(1)
        }

        if (length(muni_data) > 0) {
          muni_df <- bind_rows(muni_data)
          fname <- paste0("statent_muni_", tbl_num, ".csv")
          write_csv(muni_df, file.path(data_dir, fname))
          cat("  Saved", fname, ":", nrow(muni_df), "rows\n")
          break  # Got data, stop trying other tables
        }
      }
    } else {
      cat("metadata parse error\n")
    }
  } else {
    cat("not found\n")
  }
}

# ══════════════════════════════════════════════════════════════════════════════
# 2. Zweitwohnungsanteil via GeoAdmin features API
# ══════════════════════════════════════════════════════════════════════════════
cat("\n--- Zweitwohnungsanteil from GeoAdmin ---\n")

layer_id <- "ch.are.wohnungsinventar-zweitwohnungsanteil"

# Use the identify endpoint with a bounding box covering all of Switzerland
# Switzerland extent in LV95: E 2485000-2834000, N 1075000-1296000
# Or WGS84: 5.9-10.5°E, 45.8-47.8°N
# The identify endpoint uses LV95 coordinates

# Try getting features by querying the layer directly with large bounding box
# Use MapServer identify
cat("Using identify endpoint...\n")
identify_url <- paste0(
  "https://api3.geo.admin.ch/rest/services/api/MapServer/identify?",
  "layers=all:", layer_id,
  "&geometry=2500000,1080000,2830000,1300000",
  "&geometryType=esriGeometryEnvelope",
  "&mapExtent=2485000,1075000,2834000,1296000",
  "&imageDisplay=1000,600,96",
  "&tolerance=0",
  "&returnGeometry=false",
  "&lang=de",
  "&limit=5000"
)

resp <- tryCatch(http_get(identify_url), error = function(e) NULL)
if (!is.null(resp) && status_code(resp) == 200) {
  data <- fromJSON(content(resp, as = "text", encoding = "UTF-8"),
                   simplifyDataFrame = TRUE)
  if (!is.null(data$results) && is.data.frame(data$results) && nrow(data$results) > 0) {
    attrs <- data$results$attributes
    cat("Features found:", nrow(attrs), "\n")
    cat("Columns:", paste(names(attrs), collapse = ", "), "\n")
    cat("Sample:\n")
    print(head(attrs, 5))

    write_csv(attrs, file.path(data_dir, "zweitwohnungsanteil.csv"))
    cat("Saved zweitwohnungsanteil.csv:", nrow(attrs), "rows\n")
  } else {
    cat("No features returned from identify\n")
  }
} else {
  cat("Identify failed:", if (!is.null(resp)) status_code(resp) else "NULL", "\n")
}

# If identify didn't return enough, also try the features endpoint
# Paginate through all features
if (!exists("attrs") || is.null(attrs) || nrow(attrs) < 500) {
  cat("\nTrying paginated feature download...\n")

  all_features <- list()
  offset <- 0
  batch_size <- 200

  while (TRUE) {
    feat_url <- paste0(
      "https://api3.geo.admin.ch/rest/services/api/MapServer/",
      layer_id,
      "/find?searchField=gemeinde_nummer",
      "&searchText=*",
      "&returnGeometry=false",
      "&offset=", offset,
      "&limit=", batch_size,
      "&lang=de"
    )

    # Actually try a different approach: iterate through municipality numbers
    # Swiss BFS municipality numbers range from roughly 1-7000
    # But the find endpoint needs actual search values

    # Try getting a specific municipality to verify the API works
    test_url <- paste0(
      "https://api3.geo.admin.ch/rest/services/api/MapServer/",
      layer_id, "/1?returnGeometry=false&lang=de"
    )
    resp <- tryCatch(http_get(test_url), error = function(e) NULL)
    if (!is.null(resp) && status_code(resp) == 200) {
      cat("Single feature test:", status_code(resp), "\n")
      d <- fromJSON(content(resp, as = "text", encoding = "UTF-8"))
      cat("Feature:", str(d), "\n")
    }
    break
  }

  # Download features one by one (IDs typically 1-2500)
  cat("Downloading features by ID (1 to 2500)...\n")
  all_features <- list()
  for (fid in 1:2500) {
    feat_url <- paste0(
      "https://api3.geo.admin.ch/rest/services/api/MapServer/",
      layer_id, "/", fid, "?returnGeometry=false&lang=de"
    )
    r <- tryCatch(http_get(feat_url), error = function(e) NULL)
    if (!is.null(r) && status_code(r) == 200) {
      d <- tryCatch(fromJSON(content(r, as = "text", encoding = "UTF-8")),
                    error = function(e) NULL)
      if (!is.null(d) && !is.null(d$feature) && !is.null(d$feature$attributes)) {
        all_features[[length(all_features) + 1]] <- as.data.frame(
          d$feature$attributes, stringsAsFactors = FALSE
        )
      }
    }
    if (fid %% 100 == 0) {
      cat("  ID", fid, ":", length(all_features), "features so far\n")
      Sys.sleep(0.5)
    }
    if (fid %% 10 == 0) Sys.sleep(0.1)  # Rate limiting
  }

  if (length(all_features) > 0) {
    zw_df <- bind_rows(all_features)
    cat("Total features:", nrow(zw_df), "\n")
    write_csv(zw_df, file.path(data_dir, "zweitwohnungsanteil.csv"))
    cat("Saved zweitwohnungsanteil.csv\n")
  }
}

# ══════════════════════════════════════════════════════════════════════════════
# 3. New construction data from BFS PXWeb
# ══════════════════════════════════════════════════════════════════════════════
cat("\n--- New construction from PXWeb ---\n")

# Housing tables start with px-x-09
# Check tables 0903 and 0904 for Bautätigkeit (building activity)
for (tbl_num in c("0903020000_101", "0903020000_102", "0903020000_111",
                   "0904010000_111", "0904010000_112", "0904010000_113",
                   "0904030000_101", "0904030000_102")) {
  tbl_id <- paste0("px-x-", tbl_num)
  tbl_url <- paste0(pxweb_base, tbl_id, "/", tbl_id, ".px")

  cat("Checking", tbl_id, "... ")
  resp <- tryCatch(http_get(tbl_url), error = function(e) NULL)
  if (!is.null(resp) && status_code(resp) == 200) {
    m <- tryCatch(fromJSON(content(resp, as = "text", encoding = "UTF-8")),
                  error = function(e) NULL)
    if (!is.null(m) && !is.null(m$variables)) {
      cat(m$title, "\n")
      has_muni <- any(sapply(m$variables$values, length) > 100)
      if (has_muni) cat("  ** HAS MUNICIPALITY DATA **\n")
      for (v in seq_along(m$variables$code)) {
        cat("  ", m$variables$text[v], "(", length(m$variables$values[[v]]), ")\n")
      }
    }
  } else {
    cat("not found\n")
  }
  Sys.sleep(0.3)
}

# ══════════════════════════════════════════════════════════════════════════════
# SUMMARY
# ══════════════════════════════════════════════════════════════════════════════
cat("\n\n========== FINAL DATA FILES ==========\n")
for (f in list.files(data_dir)) {
  sz <- file.info(file.path(data_dir, f))$size
  cat("  ", f, ":", round(sz / 1024, 1), "KB\n")
}
