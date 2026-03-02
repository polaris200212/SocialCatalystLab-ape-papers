## 01_fetch_data.R — Data acquisition from Swiss federal sources
## APEP-0458: Second Home Caps and Local Labor Markets

source("code/00_packages.R")
library(readxl)

cat("\n=== FETCHING DATA ===\n")

# ---------------------------------------------------------------------------
# 1. Second-home share data (running variable)
#    Source: geo.admin.ch identify API + STAC Excel downloads
# ---------------------------------------------------------------------------
cat("1. Fetching second-home share data...\n")

# 1a. Download earliest available Excel (2017) for baseline running variable
# The ZWA data starts in 2017 on STAC, but the ARE computed initial
# shares at the time of the initiative (2012). The 2017 data includes
# the status classification (above/below 20%) which was determined pre-2013.

stac_years <- c("2017", "2018", "2019-03", "2020-03", "2021-03",
                "2022-03", "2023-03", "2024-03")

zwa_all <- list()
for (yr in stac_years) {
  xlsx_url <- paste0(
    "https://data.geo.admin.ch/ch.are.wohnungsinventar-zweitwohnungsanteil/",
    "wohnungsinventar-zweitwohnungsanteil_", yr, "/",
    "wohnungsinventar-zweitwohnungsanteil_", yr, "_2056.xlsx.zip"
  )

  temp_zip <- tempfile(fileext = ".zip")
  result <- tryCatch({
    download.file(xlsx_url, temp_zip, mode = "wb", quiet = TRUE)
    TRUE
  }, error = function(e) FALSE)

  if (result && file.info(temp_zip)$size > 100) {
    temp_dir <- tempdir()
    unzip(temp_zip, exdir = temp_dir, overwrite = TRUE)
    xlsx_files <- list.files(temp_dir, pattern = "\\.xlsx$", full.names = TRUE,
                             recursive = TRUE)

    if (length(xlsx_files) > 0) {
      df <- tryCatch({
        read_excel(xlsx_files[1])
      }, error = function(e) {
        cat("  Failed to read xlsx for", yr, ":", e$message, "\n")
        NULL
      })

      if (!is.null(df)) {
        df$year_snapshot <- yr
        zwa_all[[yr]] <- as.data.table(df)
        cat("  ", yr, ":", nrow(df), "municipalities\n")
      }
    }
  } else {
    cat("  ", yr, ": download failed\n")
  }
}

if (length(zwa_all) > 0) {
  zwa_panel <- rbindlist(zwa_all, fill = TRUE)
  cat("  Total ZWA panel:", nrow(zwa_panel), "rows across", length(zwa_all), "years\n")
  fwrite(zwa_panel, "data/zwa_panel.csv")
  cat("  Saved: data/zwa_panel.csv\n")
} else {
  cat("  WARNING: Excel downloads failed. Using identify API fallback.\n")
}

# 1b. Also get current snapshot via identify API (complete coverage)
cat("  Fetching current ZWA via identify API...\n")

# Switzerland bounding box in LV95 (EPSG:2056)
all_features <- list()
# Split into quadrants to stay under the 200-feature limit
boxes <- list(
  c(2485000, 1075000, 2660000, 1200000),  # West
  c(2660000, 1075000, 2835000, 1200000),  # East
  c(2485000, 1200000, 2660000, 1295000),  # NW
  c(2660000, 1200000, 2835000, 1295000)   # NE
)

for (box in boxes) {
  geom <- paste(box, collapse = ",")
  resp <- GET("https://api3.geo.admin.ch/rest/services/api/MapServer/identify",
              query = list(
                geometryType = "esriGeometryEnvelope",
                geometry = geom,
                sr = 2056,
                layers = "all:ch.are.wohnungsinventar-zweitwohnungsanteil",
                returnGeometry = "false",
                limit = 3000,
                tolerance = 0
              ))

  if (status_code(resp) == 200) {
    d <- content(resp, "parsed")
    all_features <- c(all_features, d$results)
  }
  Sys.sleep(0.5)
}

if (length(all_features) > 0) {
  zwa_current <- rbindlist(lapply(all_features, function(f) {
    a <- f$attributes
    data.table(
      gemeinde_nr = a$gemeinde_nummer,
      gemeinde_name = a$gemeinde_name,
      total_dwellings = a$zwg_3150,
      primary_dwellings = a$zwg_3010,
      primary_equivalent = a$zwg_3100,
      primary_share = a$zwg_3110,
      zwa_pct = a$zwg_3120,
      status = a$status,
      verfahren = a$verfahren
    )
  }), fill = TRUE)

  # Remove duplicates (overlap between quadrants)
  zwa_current <- unique(zwa_current, by = "gemeinde_nr")
  cat("  Current ZWA snapshot:", nrow(zwa_current), "municipalities\n")
  fwrite(zwa_current, "data/zwa_current.csv")
  cat("  Saved: data/zwa_current.csv\n")

  # Key statistics
  cat("  Above 20%:", sum(zwa_current$zwa_pct >= 20, na.rm = TRUE), "\n")
  cat("  Below 20%:", sum(zwa_current$zwa_pct < 20, na.rm = TRUE), "\n")
  cat("  Range:", round(min(zwa_current$zwa_pct, na.rm = TRUE), 1), "% to",
      round(max(zwa_current$zwa_pct, na.rm = TRUE), 1), "%\n")
}

# ---------------------------------------------------------------------------
# 2. BFS STATENT employment data (primary outcome)
#    Source: BFS PXWeb table px-x-0602010000_101
# ---------------------------------------------------------------------------
cat("\n2. Fetching STATENT employment data...\n")

statent_url <- "https://www.pxweb.bfs.admin.ch/api/v1/de/px-x-0602010000_101"
meta_resp <- GET(statent_url)
meta <- content(meta_resp, "parsed")

cat("  Table:", meta$title, "\n")
for (v in meta$variables) {
  cat("    ", v$code, ":", length(v$values), "values\n")
}

# Build query: all years × all municipalities × aggregate employment
# Identify which variable is which
year_var <- NULL
geo_var <- NULL
other_vars <- list()

for (v in meta$variables) {
  if (grepl("[Jj]ahr|[Yy]ear|[Zz]eit|[Pp]eriod", v$text, ignore.case = TRUE)) {
    year_var <- v
  } else if (grepl("[Gg]emeinde|[Mm]unicip|[Kk]anton|[Rr]aum|[Rr]egion", v$text, ignore.case = TRUE)) {
    geo_var <- v
  } else {
    other_vars <- c(other_vars, list(v))
  }
}

# Query with PXWeb POST format
# For large queries, select all years but limit other dimensions
query_items <- list()

if (!is.null(year_var)) {
  query_items <- c(query_items, list(list(
    code = year_var$code,
    selection = list(filter = "item", values = year_var$values)
  )))
}

if (!is.null(geo_var)) {
  # Select municipalities (BFS numbers, usually 4 digits starting with 1-9)
  # Filter to just municipality codes (exclude cantons, districts)
  all_geos <- geo_var$values
  # Municipal codes in BFS are typically between 1 and 6999
  mun_codes <- all_geos[as.numeric(all_geos) >= 1 & as.numeric(all_geos) <= 6999]
  if (length(mun_codes) == 0) mun_codes <- all_geos  # fallback

  cat("  Geographic units:", length(mun_codes), "\n")

  # PXWeb has a cell limit (~100k). Query in batches if needed.
  # For now, try the full query
  query_items <- c(query_items, list(list(
    code = geo_var$code,
    selection = list(filter = "item", values = mun_codes)
  )))
}

for (v in other_vars) {
  # Select first value (usually total/aggregate)
  query_items <- c(query_items, list(list(
    code = v$code,
    selection = list(filter = "item", values = head(v$values, 1))
  )))
}

query_body <- list(query = query_items, response = list(format = "csv"))

cat("  Posting STATENT query...\n")
statent_resp <- tryCatch({
  POST(statent_url, body = toJSON(query_body, auto_unbox = TRUE),
       content_type_json(), timeout(180))
}, error = function(e) {
  cat("  Query failed:", e$message, "\n")
  NULL
})

if (!is.null(statent_resp) && status_code(statent_resp) == 200) {
  statent_text <- content(statent_resp, "text", encoding = "UTF-8")
  statent_raw <- fread(text = statent_text)
  cat("  STATENT total employment:", nrow(statent_raw), "rows\n")
  fwrite(statent_raw, "data/statent_municipal_raw.csv")
}

# Also get the sectoral table (px-x-0602010000_102 — by NOGA division)
cat("\n  Fetching STATENT sectoral breakdown (NOGA)...\n")
statent2_url <- "https://www.pxweb.bfs.admin.ch/api/v1/de/px-x-0602010000_102"
meta2_resp <- GET(statent2_url)
meta2 <- content(meta2_resp, "parsed")

cat("  Table:", meta2$title, "\n")
for (v in meta2$variables) {
  cat("    ", v$code, ":", length(v$values), "values - first few:", paste(head(v$values, 3), collapse = ", "), "\n")
}

# For sectoral data, select key sectors:
# F = Construction, I = Accommodation & food services, Total
query_items2 <- list()
for (v in meta2$variables) {
  if (grepl("[Jj]ahr|[Yy]ear|[Zz]eit|[Pp]eriod", v$text, ignore.case = TRUE)) {
    query_items2 <- c(query_items2, list(list(
      code = v$code,
      selection = list(filter = "item", values = v$values)
    )))
  } else if (grepl("[Gg]emeinde|[Mm]unicip|[Kk]anton|[Rr]aum|[Rr]egion", v$text, ignore.case = TRUE)) {
    # All municipalities
    vals <- v$values
    # Filter to actual municipalities if possible
    numeric_vals <- vals[!is.na(suppressWarnings(as.numeric(vals)))]
    mun_vals <- numeric_vals[as.numeric(numeric_vals) >= 1 & as.numeric(numeric_vals) <= 6999]
    if (length(mun_vals) == 0) mun_vals <- head(vals, 500)  # fallback
    query_items2 <- c(query_items2, list(list(
      code = v$code,
      selection = list(filter = "item", values = mun_vals)
    )))
  } else if (grepl("[Ww]irtschaft|NOGA|[Ss]ect|[Bb]ranch|[Aa]bteil", v$text, ignore.case = TRUE)) {
    # Key sectors: look for construction (F/41-43), accommodation (I/55-56), total
    # PXWeb codes vary; select a strategic subset
    noga_vals <- v$values
    cat("    NOGA values (first 20):", paste(head(noga_vals, 20), collapse = ", "), "\n")
    # Select all to start, we'll filter in R
    query_items2 <- c(query_items2, list(list(
      code = v$code,
      selection = list(filter = "item", values = noga_vals)
    )))
  } else {
    query_items2 <- c(query_items2, list(list(
      code = v$code,
      selection = list(filter = "item", values = head(v$values, 1))
    )))
  }
}

query_body2 <- list(query = query_items2, response = list(format = "csv"))

cat("  Posting sectoral query...\n")
statent2_resp <- tryCatch({
  POST(statent2_url, body = toJSON(query_body2, auto_unbox = TRUE),
       content_type_json(), timeout(180))
}, error = function(e) {
  cat("  Sectoral query failed:", e$message, "\n")
  NULL
})

if (!is.null(statent2_resp) && status_code(statent2_resp) == 200) {
  statent2_text <- content(statent2_resp, "text", encoding = "UTF-8")
  statent_sector <- fread(text = statent2_text)
  cat("  STATENT sectoral data:", nrow(statent_sector), "rows\n")
  fwrite(statent_sector, "data/statent_sector_raw.csv")
} else if (!is.null(statent2_resp)) {
  cat("  HTTP status:", status_code(statent2_resp), "\n")
  # If cell count exceeded, query in batches
  err_text <- content(statent2_resp, "text", encoding = "UTF-8")
  if (grepl("too many", err_text, ignore.case = TRUE) ||
      status_code(statent2_resp) == 400) {
    cat("  Cell limit exceeded. Querying in year batches...\n")

    # Get year variable
    yr_var <- NULL
    for (v in meta2$variables) {
      if (grepl("[Jj]ahr|[Yy]ear|[Zz]eit|[Pp]eriod", v$text, ignore.case = TRUE)) {
        yr_var <- v
        break
      }
    }

    if (!is.null(yr_var)) {
      batch_results <- list()
      for (yr_val in yr_var$values) {
        # Modify query for single year
        q_batch <- query_items2
        for (i in seq_along(q_batch)) {
          if (q_batch[[i]]$code == yr_var$code) {
            q_batch[[i]]$selection$values <- list(yr_val)
          }
        }

        batch_body <- list(query = q_batch, response = list(format = "csv"))
        batch_resp <- tryCatch({
          POST(statent2_url, body = toJSON(batch_body, auto_unbox = TRUE),
               content_type_json(), timeout(120))
        }, error = function(e) NULL)

        if (!is.null(batch_resp) && status_code(batch_resp) == 200) {
          batch_text <- content(batch_resp, "text", encoding = "UTF-8")
          batch_dt <- fread(text = batch_text)
          batch_results[[yr_val]] <- batch_dt
          cat("    Year", yr_val, ":", nrow(batch_dt), "rows\n")
        }
        Sys.sleep(0.3)
      }

      if (length(batch_results) > 0) {
        statent_sector <- rbindlist(batch_results, fill = TRUE)
        cat("  Total sectoral data:", nrow(statent_sector), "rows\n")
        fwrite(statent_sector, "data/statent_sector_raw.csv")
      }
    }
  }
}

# ---------------------------------------------------------------------------
# 3. BFS tourism overnight stays (HESTA)
#    Source: BFS PXWeb table px-x-1003020000_101
# ---------------------------------------------------------------------------
cat("\n3. Fetching HESTA tourism data...\n")

hesta_url <- "https://www.pxweb.bfs.admin.ch/api/v1/de/px-x-1003020000_101"
hesta_meta_resp <- GET(hesta_url)
hesta_meta <- content(hesta_meta_resp, "parsed")

cat("  Table:", hesta_meta$title, "\n")
for (v in hesta_meta$variables) {
  cat("    ", v$code, ":", length(v$values), "values\n")
}

# Build tourism query
hesta_query <- list()
for (v in hesta_meta$variables) {
  if (grepl("[Jj]ahr|[Yy]ear|[Zz]eit|[Pp]eriod|[Mm]onat", v$text, ignore.case = TRUE)) {
    hesta_query <- c(hesta_query, list(list(
      code = v$code,
      selection = list(filter = "item", values = v$values)
    )))
  } else if (grepl("[Gg]emeinde|[Mm]unicip|[Kk]anton|[Rr]aum|[Rr]egion|[Zz]one", v$text, ignore.case = TRUE)) {
    hesta_query <- c(hesta_query, list(list(
      code = v$code,
      selection = list(filter = "all", values = list("*"))
    )))
  } else if (grepl("[Hh]erkunft|[Oo]rigin|[Nn]ational", v$text, ignore.case = TRUE)) {
    # Total (not by nationality)
    hesta_query <- c(hesta_query, list(list(
      code = v$code,
      selection = list(filter = "item", values = head(v$values, 1))
    )))
  } else {
    hesta_query <- c(hesta_query, list(list(
      code = v$code,
      selection = list(filter = "item", values = head(v$values, 2))
    )))
  }
}

hesta_body <- list(query = hesta_query, response = list(format = "csv"))

cat("  Posting HESTA query...\n")
hesta_data_resp <- tryCatch({
  POST(hesta_url, body = toJSON(hesta_body, auto_unbox = TRUE),
       content_type_json(), timeout(180))
}, error = function(e) {
  cat("  Query failed:", e$message, "\n")
  NULL
})

if (!is.null(hesta_data_resp) && status_code(hesta_data_resp) == 200) {
  hesta_text <- content(hesta_data_resp, "text", encoding = "UTF-8")
  hesta_raw <- fread(text = hesta_text)
  cat("  HESTA data:", nrow(hesta_raw), "rows\n")
  fwrite(hesta_raw, "data/hesta_municipal_raw.csv")
} else if (!is.null(hesta_data_resp)) {
  cat("  HTTP", status_code(hesta_data_resp), "\n")
  err <- content(hesta_data_resp, "text", encoding = "UTF-8")
  cat("  Error:", substr(err, 1, 300), "\n")
}

# ---------------------------------------------------------------------------
# 4. BFS population data (STATPOP)
#    Source: BFS PXWeb table px-x-0102020000_101
# ---------------------------------------------------------------------------
cat("\n4. Fetching STATPOP population data...\n")

statpop_url <- "https://www.pxweb.bfs.admin.ch/api/v1/de/px-x-0102020000_101"
statpop_meta_resp <- GET(statpop_url)
statpop_meta <- content(statpop_meta_resp, "parsed")

cat("  Table:", statpop_meta$title, "\n")
for (v in statpop_meta$variables) {
  cat("    ", v$code, ":", length(v$values), "values\n")
}

# Build population query
statpop_query <- list()
for (v in statpop_meta$variables) {
  if (grepl("[Jj]ahr|[Yy]ear|[Zz]eit", v$text, ignore.case = TRUE)) {
    statpop_query <- c(statpop_query, list(list(
      code = v$code,
      selection = list(filter = "item", values = v$values)
    )))
  } else if (grepl("[Gg]emeinde|[Mm]unicip|[Rr]aum|[Rr]egion", v$text, ignore.case = TRUE)) {
    statpop_query <- c(statpop_query, list(list(
      code = v$code,
      selection = list(filter = "all", values = list("*"))
    )))
  } else {
    statpop_query <- c(statpop_query, list(list(
      code = v$code,
      selection = list(filter = "item", values = head(v$values, 1))
    )))
  }
}

statpop_body <- list(query = statpop_query, response = list(format = "csv"))

cat("  Posting STATPOP query...\n")
statpop_data_resp <- tryCatch({
  POST(statpop_url, body = toJSON(statpop_body, auto_unbox = TRUE),
       content_type_json(), timeout(180))
}, error = function(e) {
  cat("  Query failed:", e$message, "\n")
  NULL
})

if (!is.null(statpop_data_resp) && status_code(statpop_data_resp) == 200) {
  statpop_text <- content(statpop_data_resp, "text", encoding = "UTF-8")
  statpop_raw <- fread(text = statpop_text)
  cat("  STATPOP data:", nrow(statpop_raw), "rows\n")
  fwrite(statpop_raw, "data/statpop_raw.csv")
}

# ---------------------------------------------------------------------------
# 5. Canton-level NOGA employment (STATENT by canton and NOGA division)
#    Source: BFS PXWeb table px-x-0602010000_103
# ---------------------------------------------------------------------------
cat("\n5. Fetching canton NOGA employment data...\n")

canton_noga_url <- "https://www.pxweb.bfs.admin.ch/api/v1/de/px-x-0602010000_103/px-x-0602010000_103.px"
canton_noga_meta_resp <- tryCatch(GET(canton_noga_url), error = function(e) NULL)

if (!is.null(canton_noga_meta_resp) && status_code(canton_noga_meta_resp) == 200) {
  canton_noga_meta <- content(canton_noga_meta_resp, "parsed")
  cat("  Table:", canton_noga_meta$title, "\n")

  # Build query: all years, all cantons, key NOGA codes, headcount measure
  canton_noga_query <- list()
  for (v in canton_noga_meta$variables) {
    if (grepl("[Jj]ahr|[Yy]ear", v$text, ignore.case = TRUE)) {
      canton_noga_query <- c(canton_noga_query, list(list(
        code = v$code, selection = list(filter = "item", values = v$values)
      )))
    } else if (grepl("[Kk]anton|[Rr]egion|[Rr]aum", v$text, ignore.case = TRUE)) {
      canton_noga_query <- c(canton_noga_query, list(list(
        code = v$code, selection = list(filter = "all", values = list("*"))
      )))
    } else {
      canton_noga_query <- c(canton_noga_query, list(list(
        code = v$code, selection = list(filter = "item", values = v$values)
      )))
    }
  }

  canton_noga_body <- list(query = canton_noga_query, response = list(format = "csv"))

  canton_noga_data_resp <- tryCatch({
    POST(canton_noga_url, body = toJSON(canton_noga_body, auto_unbox = TRUE),
         content_type_json(), timeout(180))
  }, error = function(e) { cat("  Query failed:", e$message, "\n"); NULL })

  if (!is.null(canton_noga_data_resp) && status_code(canton_noga_data_resp) == 200) {
    canton_noga_text <- content(canton_noga_data_resp, "text", encoding = "UTF-8")
    canton_noga_raw <- fread(text = canton_noga_text)
    cat("  Canton NOGA data:", nrow(canton_noga_raw), "rows\n")
    fwrite(canton_noga_raw, "data/statent_canton_noga_raw.csv")
  }
} else {
  cat("  Canton NOGA table not available (non-critical)\n")
}

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
cat("\n=== DATA FETCH SUMMARY ===\n")
data_files <- list.files("data", pattern = "\\.(csv|rds)$")
for (f in data_files) {
  fsize <- file.info(file.path("data", f))$size
  nlines <- length(readLines(file.path("data", f), n = -1L, warn = FALSE))
  cat(sprintf("  %-40s %8s bytes  %6d lines\n", f,
              format(fsize, big.mark = ","), nlines))
}
cat("Total files:", length(data_files), "\n")
cat("=== DONE ===\n")
