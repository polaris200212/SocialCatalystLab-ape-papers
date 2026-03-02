##############################################################################
# 01c_fetch_muni.R — Targeted fetch: municipality STATENT + Zweitwohnungen
# APEP-0457: The Lex Weber Shock
##############################################################################

source("00_packages.R")
library(BFS)

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
# 1. Find and download municipality-level STATENT via BFS catalog
# ══════════════════════════════════════════════════════════════════════════════
cat("--- Searching BFS catalog for municipality STATENT ---\n")

# Use the newer catalog function
tryCatch({
  cat_tables <- bfs_get_catalog_tables(language = "de")
  cat("BFS catalog:", nrow(cat_tables), "tables\n")
  cat("Columns:", paste(names(cat_tables), collapse = ", "), "\n")

  # Search for STATENT / employment / municipality
  hits <- cat_tables[grep("Gemeinde.*Beschäftigte|Beschäftigte.*Gemeinde|Gemeinde.*Arbeits|STATENT.*Gemeinde",
                           cat_tables$title, ignore.case = TRUE), ]
  cat("\nMunicipality employment hits:", nrow(hits), "\n")

  if (nrow(hits) > 0) {
    for (i in seq_len(nrow(hits))) {
      cat("  [", i, "]", hits$title[i], "\n")
      cat("      number_bfs:", hits$number_bfs[i], "\n")
    }

    # Try downloading each hit
    for (i in seq_len(nrow(hits))) {
      cat("\n  Downloading:", hits$title[i], "...\n")
      tryCatch({
        df <- bfs_get_data(number_bfs = hits$number_bfs[i], language = "de")
        cat("    SUCCESS:", nrow(df), "rows ×", ncol(df), "cols\n")
        cat("    Columns:", paste(names(df), collapse = ", "), "\n")
        cat("    Sample:\n")
        print(head(df, 2))
        write_csv(df, file.path(data_dir, paste0("statent_muni_", i, ".csv")))
        cat("    Saved!\n")
      }, error = function(e) {
        cat("    Error:", e$message, "\n")
      })
    }
  }

  # Also search more broadly for Gemeinde employment
  hits2 <- cat_tables[grep("Gemeinde", cat_tables$title, ignore.case = TRUE), ]
  hits2 <- hits2[grep("Beschäftigte|Arbeit|Sektor|Wirtschaft",
                       hits2$title, ignore.case = TRUE), ]
  cat("\nBroader Gemeinde+employment hits:", nrow(hits2), "\n")
  if (nrow(hits2) > 0) {
    for (i in seq_len(min(10, nrow(hits2)))) {
      cat("  ", hits2$title[i], " | number:", hits2$number_bfs[i], "\n")
    }
  }
}, error = function(e) {
  cat("BFS catalog error:", e$message, "\n")
})

# ══════════════════════════════════════════════════════════════════════════════
# 2. Browse PXWeb directly for municipality STATENT tables
# ══════════════════════════════════════════════════════════════════════════════
cat("\n\n--- Browsing PXWeb directory for municipality tables ---\n")

# Get top-level categories
resp <- http_get(pxweb_base)
if (status_code(resp) == 200) {
  top <- fromJSON(content(resp, as = "text", encoding = "UTF-8"))
  cat("Top-level PXWeb sections:\n")
  for (i in seq_len(nrow(top))) {
    cat("  ", top$id[i], ":", substr(top$text[i], 1, 80), "\n")
  }

  # Drill into the employment section (06xxx)
  emp_ids <- top$id[grep("^px-x-06", top$id)]
  cat("\nEmployment sections:", paste(emp_ids, collapse = ", "), "\n")

  for (eid in emp_ids) {
    cat("\n  Section:", eid, "\n")
    sub_url <- paste0(pxweb_base, eid)
    sub_resp <- tryCatch(http_get(sub_url), error = function(e) NULL)
    if (!is.null(sub_resp) && status_code(sub_resp) == 200) {
      sub <- tryCatch(fromJSON(content(sub_resp, as = "text", encoding = "UTF-8")),
                      error = function(e) NULL)
      if (is.data.frame(sub)) {
        for (j in seq_len(nrow(sub))) {
          txt <- sub$text[j]
          if (grepl("Gemeinde|gemeinde", txt, ignore.case = TRUE)) {
            cat("    *** MUNICIPALITY: ", sub$id[j], ":", txt, "\n")

            # Get metadata
            tbl_url <- paste0(sub_url, "/", sub$id[j])
            meta_resp <- tryCatch(http_get(tbl_url), error = function(e) NULL)
            if (!is.null(meta_resp) && status_code(meta_resp) == 200) {
              m <- tryCatch(fromJSON(content(meta_resp, as = "text", encoding = "UTF-8")),
                           error = function(e) NULL)
              if (!is.null(m) && !is.null(m$variables)) {
                for (v in seq_along(m$variables$code)) {
                  nvals <- length(m$variables$values[[v]])
                  cat("        ", m$variables$text[v], "(", nvals, "values)\n")
                }

                # Download a sample year
                yr_vals <- m$variables$values[[1]]
                all_vals <- m$variables$values
                cat("        Years:", paste(yr_vals, collapse = ", "), "\n")

                # Download year by year
                cat("        Downloading...\n")
                muni_data <- list()
                for (yr in yr_vals) {
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
                  dr <- tryCatch(http_post(tbl_url, body), error = function(e) NULL)
                  if (!is.null(dr) && status_code(dr) == 200) {
                    jd <- fromJSON(content(dr, as = "text", encoding = "UTF-8"))
                    dims <- jd$dimension
                    dim_names <- names(dims)
                    dim_labels <- lapply(dim_names, function(d) {
                      idx <- dims[[d]]$category$index
                      lbl <- dims[[d]]$category$label
                      lbl[names(sort(unlist(idx)))]
                    })
                    names(dim_labels) <- dim_names
                    grid <- expand.grid(dim_labels, stringsAsFactors = FALSE)
                    grid$value <- jd$value
                    muni_data[[yr]] <- grid
                    cat("          Year", yr, ":", nrow(grid), "rows\n")
                  } else {
                    st <- if (!is.null(dr)) status_code(dr) else "ERR"
                    cat("          Year", yr, ": FAILED (", st, ")\n")
                  }
                  Sys.sleep(1)
                }

                if (length(muni_data) > 0) {
                  muni_df <- bind_rows(muni_data)
                  write_csv(muni_df, file.path(data_dir, "statent_municipality_raw.csv"))
                  cat("        Saved statent_municipality_raw.csv:", nrow(muni_df), "rows\n")
                }
              }
            }
          } else {
            cat("    ", sub$id[j], ":", substr(txt, 1, 60), "\n")
          }
        }
      }
    }
  }
}

# ══════════════════════════════════════════════════════════════════════════════
# 3. Zweitwohnungsanteil from GeoAdmin API (fixed parsing)
# ══════════════════════════════════════════════════════════════════════════════
cat("\n\n--- GeoAdmin Zweitwohnungsanteil (fixed) ---\n")

layer_id <- "ch.are.wohnungsinventar-zweitwohnungsanteil"

# Get layer metadata
geo_url <- paste0(
  "https://api3.geo.admin.ch/rest/services/api/MapServer/",
  layer_id, "?lang=de"
)
resp <- tryCatch(http_get(geo_url), error = function(e) NULL)
if (!is.null(resp) && status_code(resp) == 200) {
  layer_info <- fromJSON(content(resp, as = "text", encoding = "UTF-8"),
                         simplifyDataFrame = FALSE)
  cat("Layer:", layer_info$name, "\n")
  if (!is.null(layer_info$fields)) {
    cat("Fields:\n")
    for (f in layer_info$fields) {
      cat("  ", f$name, "(", f$type, ")\n")
    }
  }
}

# Use the identify endpoint to get data for a sample area
# Then use find to get all municipalities
# The find endpoint can search across all features
cat("\nUsing find endpoint to get all municipalities...\n")

# We need to iterate through municipalities
# Try getting features by canton using the identify endpoint with a bounding box
# Switzerland bounding box: 5.9, 45.8, 10.5, 47.8 (WGS84)

# Actually, use the search endpoint more carefully
# The find endpoint with searchText=* should return all features
find_url <- paste0(
  "https://api3.geo.admin.ch/rest/services/api/MapServer/find?",
  "layer=", layer_id,
  "&searchField=gemname",
  "&searchText=a",  # Search for any name containing 'a'
  "&returnGeometry=false",
  "&contains=true",
  "&lang=de"
)
resp <- tryCatch(http_get(find_url), error = function(e) NULL)
if (!is.null(resp) && status_code(resp) == 200) {
  data <- fromJSON(content(resp, as = "text", encoding = "UTF-8"),
                   simplifyDataFrame = TRUE)
  if (!is.null(data$results) && is.data.frame(data$results)) {
    cat("Results:", nrow(data$results), "\n")
    if (nrow(data$results) > 0 && !is.null(data$results$attributes)) {
      attrs <- data$results$attributes
      cat("Attribute columns:", paste(names(attrs), collapse = ", "), "\n")
      cat("Sample:\n")
      print(head(attrs, 3))

      # Now get ALL municipalities by searching with different letters
      cat("\nFetching all municipalities...\n")
      all_features <- list()
      seen_ids <- c()

      for (letter in c(letters, "ä", "ö", "ü")) {
        url <- paste0(
          "https://api3.geo.admin.ch/rest/services/api/MapServer/find?",
          "layer=", layer_id,
          "&searchField=gemname",
          "&searchText=", URLencode(letter),
          "&returnGeometry=false",
          "&contains=true",
          "&lang=de"
        )
        r <- tryCatch(http_get(url), error = function(e) NULL)
        if (!is.null(r) && status_code(r) == 200) {
          d <- fromJSON(content(r, as = "text", encoding = "UTF-8"),
                       simplifyDataFrame = TRUE)
          if (!is.null(d$results) && is.data.frame(d$results) && nrow(d$results) > 0) {
            a <- d$results$attributes
            a$feature_id <- d$results$id
            # Deduplicate
            new_ids <- setdiff(a$feature_id, seen_ids)
            if (length(new_ids) > 0) {
              all_features[[length(all_features) + 1]] <- a[a$feature_id %in% new_ids, ]
              seen_ids <- c(seen_ids, new_ids)
            }
          }
        }
        Sys.sleep(0.3)
      }

      if (length(all_features) > 0) {
        zw_df <- bind_rows(all_features) %>% distinct()
        cat("Total unique municipalities:", nrow(zw_df), "\n")
        cat("Columns:", paste(names(zw_df), collapse = ", "), "\n")
        write_csv(zw_df, file.path(data_dir, "zweitwohnungsanteil.csv"))
        cat("Saved zweitwohnungsanteil.csv\n")
      }
    }
  } else {
    cat("No results found\n")
  }
} else {
  cat("Find endpoint failed:", if (!is.null(resp)) status_code(resp) else "NULL", "\n")
}

# ══════════════════════════════════════════════════════════════════════════════
# 4. New construction by municipality (from BFS catalog)
# ══════════════════════════════════════════════════════════════════════════════
cat("\n\n--- New construction data ---\n")

tryCatch({
  cat_tables <- bfs_get_catalog_tables(language = "de")

  bau_rows <- cat_tables[grep("Neu erstellte", cat_tables$title, ignore.case = TRUE), ]
  cat("New construction tables:", nrow(bau_rows), "\n")

  if (nrow(bau_rows) > 0) {
    for (i in seq_len(nrow(bau_rows))) {
      cat("  [", i, "]", bau_rows$title[i], "\n")
      tryCatch({
        df <- bfs_get_data(number_bfs = bau_rows$number_bfs[i], language = "de")
        cat("    ", nrow(df), "rows ×", ncol(df), "cols\n")
        write_csv(df, file.path(data_dir, paste0("new_construction_", i, ".csv")))
      }, error = function(e) cat("    Error:", e$message, "\n"))
    }
  }
}, error = function(e) cat("Catalog error:", e$message, "\n"))

# ══════════════════════════════════════════════════════════════════════════════
# SUMMARY
# ══════════════════════════════════════════════════════════════════════════════
cat("\n\n========== DATA FILES ==========\n")
for (f in list.files(data_dir)) {
  sz <- file.info(file.path(data_dir, f))$size
  cat("  ", f, ":", round(sz / 1024, 1), "KB\n")
}
