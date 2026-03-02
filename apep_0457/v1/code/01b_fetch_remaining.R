##############################################################################
# 01b_fetch_remaining.R — Fetch municipality-level STATENT + second home data
# APEP-0457: The Lex Weber Shock
##############################################################################

source("00_packages.R")
library(BFS)

cat("\n========== FETCHING REMAINING DATA ==========\n\n")

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

# ══════════════════════════════════════════════════════════════════════════════
# 1. MUNICIPALITY-LEVEL STATENT (Gemeinde × Wirtschaftssektor)
# ══════════════════════════════════════════════════════════════════════════════
cat("--- Municipality-level STATENT ---\n")

# BFS catalog found: "Arbeitsstätten und Beschäftigte nach Gemeinde und Wirtschaftssektor"
# Find the exact table in PXWeb
cat("Searching BFS catalog for municipality employment table...\n")
catalog <- bfs_get_catalog_tables(language = "de")
muni_rows <- catalog[grep("Gemeinde.*Wirtschafts", catalog$title, ignore.case = TRUE), ]
cat("Found", nrow(muni_rows), "municipality employment tables\n")
if (nrow(muni_rows) > 0) {
  print(muni_rows[, c("title", "language", "number_observation")])
}

# Try to download using bfs_get_data
cat("\nAttempting download via BFS package...\n")
for (i in seq_len(nrow(muni_rows))) {
  cat("  Table", i, ":", muni_rows$title[i], "\n")
  tryCatch({
    df <- bfs_get_data(number_bfs = muni_rows$number_bfs[i], language = "de")
    cat("    SUCCESS:", nrow(df), "rows ×", ncol(df), "cols\n")
    cat("    Columns:", paste(names(df), collapse = ", "), "\n")
    write_csv(df, file.path(data_dir, "statent_municipality_sector.csv"))
    cat("    Saved to statent_municipality_sector.csv\n")
    break  # Got the data, stop trying
  }, error = function(e) {
    cat("    Error:", e$message, "\n")
  })
}

# Also try the PXWeb direct approach for municipality data
# The table ID pattern for municipality STATENT
pxweb_base <- "https://www.pxweb.bfs.admin.ch/api/v1/de/"

# List available tables to find municipality-level ones
cat("\nBrowsing PXWeb for municipality employment tables...\n")
resp <- http_get(pxweb_base)
if (status_code(resp) == 200) {
  all_tables <- fromJSON(content(resp, as = "text", encoding = "UTF-8"))
  # Find tables related to employment + municipality
  emp_tables <- all_tables[grep("06020", all_tables$id), ]
  if (nrow(emp_tables) > 0) {
    cat("Employment section tables:\n")
    for (i in seq_len(nrow(emp_tables))) {
      cat("  ", emp_tables$id[i], ":", emp_tables$text[i], "\n")
    }

    # Try each for municipality data
    for (i in seq_len(nrow(emp_tables))) {
      tbl_id <- emp_tables$id[i]
      tbl_url <- paste0(pxweb_base, tbl_id)
      cat("\n  Exploring", tbl_id, "...\n")

      # List subtables
      sub_resp <- tryCatch(http_get(tbl_url), error = function(e) NULL)
      if (!is.null(sub_resp) && status_code(sub_resp) == 200) {
        subtables <- fromJSON(content(sub_resp, as = "text", encoding = "UTF-8"))
        if (is.data.frame(subtables)) {
          for (j in seq_len(min(5, nrow(subtables)))) {
            cat("    ", subtables$id[j], ":", subtables$text[j], "\n")
          }

          # Check each subtable for Gemeinde dimension
          muni_sub <- subtables[grep("Gemeinde|gemeinde", subtables$text,
                                     ignore.case = TRUE), ]
          if (nrow(muni_sub) > 0) {
            cat("  *** MUNICIPALITY TABLE FOUND ***\n")
            for (k in seq_len(nrow(muni_sub))) {
              cat("    ", muni_sub$id[k], ":", muni_sub$text[k], "\n")

              # Get metadata for this table
              sub_url <- paste0(tbl_url, "/", muni_sub$id[k])
              meta_resp <- tryCatch(http_get(sub_url), error = function(e) NULL)
              if (!is.null(meta_resp) && status_code(meta_resp) == 200) {
                m <- fromJSON(content(meta_resp, as = "text", encoding = "UTF-8"))
                if (!is.null(m$variables)) {
                  for (v in seq_along(m$variables$code)) {
                    cat("      Dim:", m$variables$text[v],
                        "(", length(m$variables$values[[v]]), "values)\n")
                  }
                }
              }
            }
          }
        }
      }
      Sys.sleep(0.5)
    }
  }
}

# ══════════════════════════════════════════════════════════════════════════════
# 2. SECOND HOME SHARES (Zweitwohnungsanteil)
# ══════════════════════════════════════════════════════════════════════════════
cat("\n\n--- Second home share data ---\n")

# Search BFS catalog for Zweitwohnung/dwelling data
zw_rows <- catalog[grep("Wohnung|wohnung|Zweit|Gebäude.*Gemeinde",
                         catalog$title, ignore.case = TRUE), ]
cat("Dwelling/building tables in BFS catalog:", nrow(zw_rows), "\n")
if (nrow(zw_rows) > 0) {
  for (i in seq_len(min(10, nrow(zw_rows)))) {
    cat("  ", zw_rows$title[i], "\n")
  }

  # Try downloading housing tables that might contain occupancy data
  for (i in seq_len(nrow(zw_rows))) {
    if (grepl("Gemeinde", zw_rows$title[i], ignore.case = TRUE)) {
      cat("\n  Trying:", zw_rows$title[i], "\n")
      tryCatch({
        df <- bfs_get_data(number_bfs = zw_rows$number_bfs[i], language = "de")
        cat("    SUCCESS:", nrow(df), "rows ×", ncol(df), "cols\n")
        cat("    Columns:", paste(names(df), collapse = ", "), "\n")

        fname <- paste0("bfs_housing_", i, ".csv")
        write_csv(df, file.path(data_dir, fname))
        cat("    Saved:", fname, "\n")
      }, error = function(e) {
        cat("    Error:", e$message, "\n")
      })
    }
  }
}

# Search PXWeb housing section (09xx tables)
cat("\nBrowsing PXWeb housing tables...\n")
housing_section <- all_tables[grep("^px-x-09", all_tables$id), ]
if (nrow(housing_section) > 0) {
  cat("Housing section tables:\n")
  for (i in seq_len(nrow(housing_section))) {
    cat("  ", housing_section$id[i], ":", housing_section$text[i], "\n")
  }

  # Explore each for municipality-level dwelling data
  for (i in seq_len(nrow(housing_section))) {
    tbl_id <- housing_section$id[i]
    tbl_url <- paste0(pxweb_base, tbl_id)
    sub_resp <- tryCatch(http_get(tbl_url), error = function(e) NULL)
    if (!is.null(sub_resp) && status_code(sub_resp) == 200) {
      ct <- content(sub_resp, as = "text", encoding = "UTF-8")
      subtables <- tryCatch(fromJSON(ct), error = function(e) NULL)
      if (is.data.frame(subtables) && nrow(subtables) > 0) {
        gemeinde_sub <- subtables[grep("Gemeinde|Belegung|Zweit",
                                       subtables$text, ignore.case = TRUE), ]
        if (nrow(gemeinde_sub) > 0) {
          cat("  *** RELEVANT TABLE in", tbl_id, "***\n")
          for (j in seq_len(nrow(gemeinde_sub))) {
            cat("    ", gemeinde_sub$id[j], ":", gemeinde_sub$text[j], "\n")

            # Get metadata
            sub_url <- paste0(tbl_url, "/", gemeinde_sub$id[j])
            meta_resp <- tryCatch(http_get(sub_url), error = function(e) NULL)
            if (!is.null(meta_resp) && status_code(meta_resp) == 200) {
              m <- tryCatch(fromJSON(content(meta_resp, as = "text", encoding = "UTF-8")),
                           error = function(e) NULL)
              if (!is.null(m) && !is.null(m$variables)) {
                for (v in seq_along(m$variables$code)) {
                  cat("      Dim:", m$variables$text[v],
                      "(", length(m$variables$values[[v]]), "values)\n")
                }
              }
            }
          }
        }
      }
    }
    Sys.sleep(0.3)
  }
}

# ══════════════════════════════════════════════════════════════════════════════
# 3. BUILDING PERMITS / NEW CONSTRUCTION (from BFS catalog tables found above)
# ══════════════════════════════════════════════════════════════════════════════
cat("\n\n--- Building permits / new construction ---\n")

# The BFS catalog found these housing tables with municipality data:
# "Neu erstellte Gebäude mit Wohnungen nach Grossregion, Kanton, Gemeinde und Gebäudetyp, ab 2013"
# "Neu erstellte Wohnungen nach Grossregion, Kanton, Gemeinde und Anzahl Zimmer, ab 2013"
# "Neu erstellte Wohnungen nach Grossregion, Kanton, Gemeinde und Gebäudetyp, ab 2013"

bau_rows <- catalog[grep("Neu erstellte", catalog$title, ignore.case = TRUE), ]
if (nrow(bau_rows) > 0) {
  cat("New construction tables found:", nrow(bau_rows), "\n")
  for (i in seq_len(nrow(bau_rows))) {
    cat("  Downloading:", bau_rows$title[i], "\n")
    tryCatch({
      df <- bfs_get_data(number_bfs = bau_rows$number_bfs[i], language = "de")
      cat("    SUCCESS:", nrow(df), "rows ×", ncol(df), "cols\n")
      fname <- paste0("new_construction_", i, ".csv")
      write_csv(df, file.path(data_dir, fname))
      cat("    Saved:", fname, "\n")
    }, error = function(e) {
      cat("    Error:", e$message, "\n")
    })
  }
}

# ══════════════════════════════════════════════════════════════════════════════
# 4. SWISS GEOPORTAL: Zweitwohnungsanteil Layer
# ══════════════════════════════════════════════════════════════════════════════
cat("\n\n--- Swiss Geoportal Zweitwohnungsanteil ---\n")

# The federal Geoportal has a layer for Zweitwohnungsanteil
# Try the OGC WFS to get feature data
# Layer: ch.are.wohnungsinventar-zweitwohnungsanteil
layer_id <- "ch.are.wohnungsinventar-zweitwohnungsanteil"

# GeoAdmin API: get features
cat("Querying GeoAdmin feature API for", layer_id, "...\n")
geo_url <- paste0(
  "https://api3.geo.admin.ch/rest/services/api/MapServer/",
  layer_id, "?lang=de"
)
resp <- tryCatch(http_get(geo_url), error = function(e) NULL)
if (!is.null(resp) && status_code(resp) == 200) {
  layer_info <- fromJSON(content(resp, as = "text", encoding = "UTF-8"))
  cat("Layer info:", names(layer_info), "\n")
  if (!is.null(layer_info$fields)) {
    cat("Fields:\n")
    for (f in layer_info$fields) {
      cat("  ", f$name, "(", f$type, ")\n")
    }
  }
}

# Try to get all features via the find endpoint
cat("\nFetching Zweitwohnungsanteil features...\n")
# Use the identify endpoint to get municipality-level data
find_url <- paste0(
  "https://api3.geo.admin.ch/rest/services/api/MapServer/find?",
  "layer=", layer_id,
  "&searchField=gemname&searchText=*&returnGeometry=false&lang=de"
)
resp <- tryCatch(http_get(find_url), error = function(e) NULL)
if (!is.null(resp)) {
  cat("Status:", status_code(resp), "\n")
  if (status_code(resp) == 200) {
    data <- fromJSON(content(resp, as = "text", encoding = "UTF-8"))
    if (!is.null(data$results) && length(data$results) > 0) {
      cat("Features found:", length(data$results), "\n")
      if (is.data.frame(data$results)) {
        attrs <- data$results$attributes
        if (!is.null(attrs)) {
          cat("Sample:\n")
          print(head(attrs, 3))
          write_csv(attrs, file.path(data_dir, "zweitwohnungsanteil_geoadmin.csv"))
          cat("Saved zweitwohnungsanteil_geoadmin.csv\n")
        }
      }
    }
  }
}

# Alternative: WMS GetFeatureInfo / WFS GetFeature
cat("\nTrying WFS for Zweitwohnungsanteil...\n")
wfs_url <- paste0(
  "https://wms.geo.admin.ch/?SERVICE=WFS&VERSION=2.0.0&REQUEST=GetFeature",
  "&TYPENAMES=", layer_id,
  "&COUNT=10&OUTPUTFORMAT=application/json"
)
resp <- tryCatch(http_get(wfs_url), error = function(e) NULL)
if (!is.null(resp)) {
  cat("WFS Status:", status_code(resp), "\n")
  if (status_code(resp) == 200) {
    wfs_data <- fromJSON(content(resp, as = "text", encoding = "UTF-8"))
    if (!is.null(wfs_data$features)) {
      cat("WFS features:", length(wfs_data$features), "\n")
    }
  }
}

# ══════════════════════════════════════════════════════════════════════════════
# FINAL SUMMARY
# ══════════════════════════════════════════════════════════════════════════════
cat("\n\n========== DATA FILES ==========\n")
data_files <- list.files(data_dir, full.names = TRUE)
for (f in data_files) {
  cat("  ", basename(f), ":", round(file.info(f)$size / 1024, 1), "KB\n")
}
