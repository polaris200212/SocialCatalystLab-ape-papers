##############################################################################
# 01e_zweitwohnung_construction.R — Second home shares + construction data
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
       timeout(180))
}

pxweb_base <- "https://www.pxweb.bfs.admin.ch/api/v1/de/"

# ══════════════════════════════════════════════════════════════════════════════
# 1. ZWEITWOHNUNGSANTEIL via GeoAdmin (fixed feature query)
# ══════════════════════════════════════════════════════════════════════════════
cat("--- Zweitwohnungsanteil from GeoAdmin ---\n")

layer <- "ch.are.wohnungsinventar-zweitwohnungsanteil"

# Try using BFS Gemeindenummer as feature ID (Zurich = 261)
test_ids <- c(261, 351, 1061, 2701, 3203, 5586, 6621)
cat("Testing feature IDs with known BFS Gemeindenummern...\n")
for (fid in test_ids) {
  url <- paste0("https://api3.geo.admin.ch/rest/services/api/MapServer/",
                layer, "/", fid, "?returnGeometry=false&lang=de")
  r <- tryCatch(http_get(url), error = function(e) NULL)
  if (!is.null(r) && status_code(r) == 200) {
    d <- tryCatch(fromJSON(content(r, as = "text", encoding = "UTF-8")),
                  error = function(e) NULL)
    if (!is.null(d) && !is.null(d$feature)) {
      cat("  ID", fid, ": FOUND -", d$feature$attributes$gemeinde_name, "\n")
      cat("    zwg_3110:", d$feature$attributes$zwg_3110, "\n")
      cat("    status:", d$feature$attributes$status, "\n")
    } else {
      cat("  ID", fid, ": no feature\n")
    }
  } else {
    st <- if (!is.null(r)) status_code(r) else "NULL"
    cat("  ID", fid, ": HTTP", st, "\n")
  }
}

# If the Gemeindenummer-as-ID approach works, download all municipalities
# Swiss BFS Gemeindenummern go from 1 to about 7000
# But many numbers are retired (merged municipalities)
# Active municipalities: ~2,100 with numbers up to about 7000

cat("\nDownloading all municipality features (IDs 1-7000)...\n")
all_zw <- list()
success_count <- 0
fail_count <- 0

for (fid in 1:7000) {
  url <- paste0("https://api3.geo.admin.ch/rest/services/api/MapServer/",
                layer, "/", fid, "?returnGeometry=false&lang=de")
  r <- tryCatch(http_get(url), error = function(e) NULL)
  if (!is.null(r) && status_code(r) == 200) {
    d <- tryCatch(fromJSON(content(r, as = "text", encoding = "UTF-8")),
                  error = function(e) NULL)
    if (!is.null(d) && !is.null(d$feature) && !is.null(d$feature$attributes)) {
      all_zw[[length(all_zw) + 1]] <- as.data.frame(d$feature$attributes,
                                                       stringsAsFactors = FALSE)
      success_count <- success_count + 1
    }
  }

  if (fid %% 500 == 0) {
    cat("  Scanned", fid, "/7000:", success_count, "found,", fail_count, "failed\n")
  }
  # Rate limiting: ~10 requests/sec
  if (fid %% 10 == 0) Sys.sleep(0.5)
}

cat("Total municipalities found:", success_count, "\n")

if (length(all_zw) > 0) {
  zw_df <- bind_rows(all_zw)
  cat("Columns:", paste(names(zw_df), collapse = ", "), "\n")
  cat("Sample:\n")
  print(head(zw_df, 5))
  write_csv(zw_df, file.path(data_dir, "zweitwohnungsanteil.csv"))
  cat("Saved zweitwohnungsanteil.csv:", nrow(zw_df), "rows\n")
}

# ══════════════════════════════════════════════════════════════════════════════
# 2. NEW CONSTRUCTION DATA (Neu erstellte Wohnungen)
# ══════════════════════════════════════════════════════════════════════════════
cat("\n--- New construction data (municipality level) ---\n")

# Table: px-x-0904030000_101
# Neu erstellte Wohnungen nach Kanton/Gemeinde, Anzahl Zimmer und Jahr
# 3,085 municipalities × 7 room sizes × 18 years
tbl_id <- "px-x-0904030000_101"
tbl_url <- paste0(pxweb_base, tbl_id, "/", tbl_id, ".px")

cat("Fetching metadata for", tbl_id, "...\n")
resp <- http_get(tbl_url)
if (status_code(resp) == 200) {
  m <- fromJSON(content(resp, as = "text", encoding = "UTF-8"))
  cat("Table:", m$title, "\n")
  for (v in seq_along(m$variables$code)) {
    cat("  ", m$variables$text[v], "(", length(m$variables$values[[v]]), ")\n")
  }

  # Download year by year
  year_vals <- m$variables$values[[which(grepl("Jahr", m$variables$text))]]
  cat("Years:", paste(year_vals, collapse = ", "), "\n")

  all_bau <- list()
  for (yr in year_vals) {
    q <- list(
      query = lapply(seq_along(m$variables$code), function(vi) {
        if (grepl("Jahr", m$variables$text[vi])) {
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
      dn <- names(dims)
      dl <- lapply(dn, function(d) {
        idx <- dims[[d]]$category$index
        lbl <- dims[[d]]$category$label
        lbl[names(sort(unlist(idx)))]
      })
      names(dl) <- dn
      grid <- expand.grid(dl, stringsAsFactors = FALSE)
      grid$value <- jd$value
      all_bau[[yr]] <- grid
      cat("  Year", yr, ":", nrow(grid), "rows\n")
    } else {
      st <- if (!is.null(dr)) status_code(dr) else "ERR"
      cat("  Year", yr, ": FAILED (", st, ")\n")
    }
    Sys.sleep(1)
  }

  if (length(all_bau) > 0) {
    bau_df <- bind_rows(all_bau)
    write_csv(bau_df, file.path(data_dir, "new_dwellings_municipality.csv"))
    cat("Saved new_dwellings_municipality.csv:", nrow(bau_df), "rows\n")
  }
}

# Also get building projects (Bauvorhaben) — px-x-0904010000_113
# Bauvorhaben nach Kanton/Gemeinde, Art der Auftraggeber, Kategorie der Bauwerke und Jahr
cat("\n--- Building projects by category ---\n")
tbl_id2 <- "px-x-0904010000_113"
tbl_url2 <- paste0(pxweb_base, tbl_id2, "/", tbl_id2, ".px")

resp2 <- http_get(tbl_url2)
if (status_code(resp2) == 200) {
  m2 <- fromJSON(content(resp2, as = "text", encoding = "UTF-8"))
  cat("Table:", m2$title, "\n")
  for (v in seq_along(m2$variables$code)) {
    cat("  ", m2$variables$text[v], "(", length(m2$variables$values[[v]]), ")\n")
  }

  year_vals2 <- m2$variables$values[[which(grepl("Jahr", m2$variables$text))]]
  cat("Years:", paste(year_vals2, collapse = ", "), "\n")

  all_bv <- list()
  for (yr in year_vals2) {
    q <- list(
      query = lapply(seq_along(m2$variables$code), function(vi) {
        if (grepl("Jahr", m2$variables$text[vi])) {
          list(code = m2$variables$code[vi],
               selection = list(filter = "item", values = list(yr)))
        } else {
          list(code = m2$variables$code[vi],
               selection = list(filter = "all", values = list("*")))
        }
      }),
      response = list(format = "json-stat2")
    )

    body <- toJSON(q, auto_unbox = TRUE)
    dr <- tryCatch(http_post(tbl_url2, body), error = function(e) NULL)
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
      all_bv[[yr]] <- grid
      cat("  Year", yr, ":", nrow(grid), "rows\n")
    } else {
      st <- if (!is.null(dr)) status_code(dr) else "ERR"
      cat("  Year", yr, ": FAILED (", st, ")\n")
    }
    Sys.sleep(1)
  }

  if (length(all_bv) > 0) {
    bv_df <- bind_rows(all_bv)
    write_csv(bv_df, file.path(data_dir, "building_projects_municipality.csv"))
    cat("Saved building_projects_municipality.csv:", nrow(bv_df), "rows\n")
  }
}

# ══════════════════════════════════════════════════════════════════════════════
# SUMMARY
# ══════════════════════════════════════════════════════════════════════════════
cat("\n\n========== FINAL DATA FILES ==========\n")
for (f in list.files(data_dir)) {
  sz <- file.info(file.path(data_dir, f))$size
  cat("  ", f, ":", round(sz / 1024, 1), "KB\n")
}
