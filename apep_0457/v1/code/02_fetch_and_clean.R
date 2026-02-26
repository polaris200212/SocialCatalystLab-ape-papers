##############################################################################
# 02_fetch_and_clean.R — Re-fetch with proper JSON-stat2 parsing + clean
# APEP-0457: The Lex Weber Shock
##############################################################################

source("00_packages.R")
library(sf)

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

# Helper: parse JSON-stat2 into data.frame
parse_jsonstat2 <- function(json_text) {
  jd <- fromJSON(json_text, simplifyVector = FALSE)

  # Extract dimensions
  dim_ids <- jd$id  # ordered dimension names
  dim_sizes <- unlist(jd$size)

  # Build label vectors for each dimension
  dim_labels <- list()
  for (d in dim_ids) {
    cat_info <- jd$dimension[[d]]$category
    # index maps category codes to positions
    idx <- unlist(cat_info$index)
    # label maps category codes to human-readable labels
    lbl <- unlist(cat_info$label)
    # Sort by index position
    ordered_codes <- names(sort(idx))
    dim_labels[[d]] <- lbl[ordered_codes]
  }

  # JSON-stat2: LAST dimension varies fastest (row-major / C-order)
  # expand.grid: FIRST argument varies fastest (column-major / Fortran-order)
  # Fix: reverse dimensions for expand.grid, then reorder columns
  rev_labels <- rev(dim_labels)
  grid <- expand.grid(rev_labels, stringsAsFactors = FALSE)
  # Reorder columns back to original dimension order
  grid <- grid[, rev(names(grid)), drop = FALSE]
  names(grid) <- dim_ids

  # Flatten values (handle nulls)
  raw_vals <- jd$value
  vals <- sapply(raw_vals, function(v) if (is.null(v)) NA_real_ else as.numeric(v))
  grid$value <- vals
  grid
}

# ══════════════════════════════════════════════════════════════════════════════
# 1. STATENT MUNICIPALITY DATA (px-x-0602010000_102)
# ══════════════════════════════════════════════════════════════════════════════
cat("=== STATENT Municipality × Sector ===\n")

tbl_id <- "px-x-0602010000_102"
tbl_url <- paste0(pxweb_base, tbl_id, "/", tbl_id, ".px")

statent_file <- file.path(data_dir, "statent_municipality.csv")

if (!file.exists(statent_file) || file.info(statent_file)$size < 100000) {
  # Get metadata
  resp <- http_get(tbl_url)
  m <- fromJSON(content(resp, as = "text", encoding = "UTF-8"), simplifyVector = FALSE)
  cat("Table:", m$title, "\n")

  # Print dimensions
  for (i in seq_along(m$variables)) {
    v <- m$variables[[i]]
    cat("  ", v$text, "(", length(v$values), "values)\n")
  }

  # Find year variable
  year_idx <- which(sapply(m$variables, function(v) grepl("Jahr", v$text)))
  year_vals <- m$variables[[year_idx]]$values
  cat("Years:", paste(year_vals, collapse = ", "), "\n")

  all_data <- list()
  for (yr in year_vals) {
    q <- list(
      query = lapply(seq_along(m$variables), function(vi) {
        v <- m$variables[[vi]]
        if (grepl("Jahr", v$text)) {
          list(code = v$code,
               selection = list(filter = "item", values = list(yr)))
        } else {
          list(code = v$code,
               selection = list(filter = "all", values = list("*")))
        }
      }),
      response = list(format = "json-stat2")
    )

    body <- toJSON(q, auto_unbox = TRUE)
    dr <- tryCatch(http_post(tbl_url, body), error = function(e) NULL)
    if (!is.null(dr) && status_code(dr) == 200) {
      txt <- content(dr, as = "text", encoding = "UTF-8")
      df <- parse_jsonstat2(txt)
      all_data[[yr]] <- df
      cat("  Year", yr, ":", nrow(df), "rows,", ncol(df), "cols\n")
    } else {
      st <- if (!is.null(dr)) status_code(dr) else "ERR"
      cat("  Year", yr, ": FAILED (", st, ")\n")
    }
    Sys.sleep(1.5)
  }

  if (length(all_data) > 0) {
    statent_raw <- bind_rows(all_data)
    cat("STATENT total:", nrow(statent_raw), "rows\n")
    cat("Columns:", paste(names(statent_raw), collapse = ", "), "\n")
    cat("Sample:\n")
    print(head(statent_raw[statent_raw$value > 0 & !is.na(statent_raw$value), ], 5))
    write_csv(statent_raw, statent_file)
  }
} else {
  cat("Loading existing statent_municipality.csv\n")
  statent_raw <- read_csv(statent_file, show_col_types = FALSE)
}

# ══════════════════════════════════════════════════════════════════════════════
# 2. CANTON × DETAILED SECTOR (for tourism sector identification)
# ══════════════════════════════════════════════════════════════════════════════
cat("\n=== STATENT Canton × NOGA Sector ===\n")

canton_sector_file <- file.path(data_dir, "statent_canton_noga.csv")

if (!file.exists(canton_sector_file) || file.info(canton_sector_file)$size < 100000) {
  tbl_id2 <- "px-x-0602010000_101"
  tbl_url2 <- paste0(pxweb_base, tbl_id2, "/", tbl_id2, ".px")

  resp2 <- http_get(tbl_url2)
  if (status_code(resp2) == 200) {
    m2 <- fromJSON(content(resp2, as = "text", encoding = "UTF-8"), simplifyVector = FALSE)
    cat("Table:", m2$title, "\n")

    for (i in seq_along(m2$variables)) {
      v <- m2$variables[[i]]
      cat("  ", v$text, "(", length(v$values), ")\n")
    }

    year_idx2 <- which(sapply(m2$variables, function(v) grepl("Jahr", v$text)))
    year_vals2 <- m2$variables[[year_idx2]]$values

    all_canton <- list()
    for (yr in year_vals2) {
      q <- list(
        query = lapply(seq_along(m2$variables), function(vi) {
          v <- m2$variables[[vi]]
          if (grepl("Jahr", v$text)) {
            list(code = v$code,
                 selection = list(filter = "item", values = list(yr)))
          } else {
            list(code = v$code,
                 selection = list(filter = "all", values = list("*")))
          }
        }),
        response = list(format = "json-stat2")
      )

      body <- toJSON(q, auto_unbox = TRUE)
      dr <- tryCatch(http_post(tbl_url2, body), error = function(e) NULL)
      if (!is.null(dr) && status_code(dr) == 200) {
        txt <- content(dr, as = "text", encoding = "UTF-8")
        df <- parse_jsonstat2(txt)
        all_canton[[yr]] <- df
        cat("  Year", yr, ":", nrow(df), "rows\n")
      } else {
        st <- if (!is.null(dr)) status_code(dr) else "ERR"
        cat("  Year", yr, ": FAILED (", st, ")\n")
      }
      Sys.sleep(1.5)
    }

    if (length(all_canton) > 0) {
      canton_noga <- bind_rows(all_canton)
      write_csv(canton_noga, canton_sector_file)
      cat("Saved canton NOGA:", nrow(canton_noga), "rows\n")
    }
  }
} else {
  cat("Loading existing statent_canton_noga.csv\n")
  canton_noga <- read_csv(canton_sector_file, show_col_types = FALSE)
}

# ══════════════════════════════════════════════════════════════════════════════
# 3. NEW CONSTRUCTION (px-x-0904030000_101)
# ══════════════════════════════════════════════════════════════════════════════
cat("\n=== New Construction by Municipality ===\n")

construction_file <- file.path(data_dir, "new_construction_municipality.csv")

if (!file.exists(construction_file) || file.info(construction_file)$size < 100000) {
  # Two BFS tables: _101 covers 1995-2012, _105 covers 2013-2023
  all_constr_parts <- list()

  for (tbl_suffix in c("101", "105")) {
    tbl_id3 <- paste0("px-x-0904030000_", tbl_suffix)
    tbl_url3 <- paste0(pxweb_base, tbl_id3, "/", tbl_id3, ".px")

    cat("Fetching", tbl_id3, "...\n")
    resp3 <- http_get(tbl_url3)
    if (status_code(resp3) == 200) {
      m3 <- fromJSON(content(resp3, as = "text", encoding = "UTF-8"),
                     simplifyVector = FALSE)
      cat("  Table:", m3$title, "\n")

      year_idx3 <- which(sapply(m3$variables, function(v) grepl("Jahr", v$text)))
      year_vals3 <- m3$variables[[year_idx3]]$values
      cat("  Years:", paste(m3$variables[[year_idx3]]$valueTexts, collapse = ", "), "\n")

      for (yr in year_vals3) {
        q <- list(
          query = lapply(seq_along(m3$variables), function(vi) {
            v <- m3$variables[[vi]]
            if (grepl("Jahr", v$text)) {
              list(code = v$code,
                   selection = list(filter = "item", values = list(yr)))
            } else {
              list(code = v$code,
                   selection = list(filter = "all", values = list("*")))
            }
          }),
          response = list(format = "json-stat2")
        )

        body <- toJSON(q, auto_unbox = TRUE)
        dr <- tryCatch(http_post(tbl_url3, body), error = function(e) NULL)
        if (!is.null(dr) && status_code(dr) == 200) {
          txt <- content(dr, as = "text", encoding = "UTF-8")
          df <- parse_jsonstat2(txt)
          all_constr_parts[[paste0(tbl_suffix, "_", yr)]] <- df
          cat("  ", yr, ":", nrow(df), "rows\n")
        } else {
          st <- if (!is.null(dr)) status_code(dr) else "ERR"
          cat("  ", yr, ": FAILED (", st, ")\n")
        }
        Sys.sleep(1.5)
      }
    }
  }

  if (length(all_constr_parts) > 0) {
    constr_df <- bind_rows(all_constr_parts)
    write_csv(constr_df, construction_file)
    cat("Saved construction:", nrow(constr_df), "rows\n")
    cat("Columns:", paste(names(constr_df), collapse = ", "), "\n")
  }
} else {
  cat("Loading existing new_construction_municipality.csv\n")
  constr_df <- read_csv(construction_file, show_col_types = FALSE)
}

# ══════════════════════════════════════════════════════════════════════════════
# 4. ZWEITWOHNUNGSANTEIL from GeoPackages
# ══════════════════════════════════════════════════════════════════════════════
cat("\n=== Zweitwohnungsanteil from GeoPackages ===\n")

gpkg_files <- list.files(data_dir, pattern = "zweitwohnungsanteil.*\\.gpkg$",
                         full.names = TRUE)
cat("Found", length(gpkg_files), "GeoPackage files\n")

all_zw <- list()
for (gpkg in gpkg_files) {
  fname <- basename(gpkg)
  # Extract year from filename
  yr_match <- regmatches(fname, regexpr("\\d{4}(-\\d{2})?", fname))
  if (length(yr_match) == 0) next

  tryCatch({
    sf_data <- st_read(gpkg, quiet = TRUE)
    df <- st_drop_geometry(sf_data)

    # Standardize column names (some years have different cases)
    names(df) <- toupper(names(df))

    # Add year indicator
    df$file_year <- yr_match

    cat("  ", fname, ":", nrow(df), "rows,", ncol(df), "cols\n")
    cat("    Columns:", paste(names(df), collapse = ", "), "\n")

    all_zw[[fname]] <- df
  }, error = function(e) {
    cat("  Error reading", fname, ":", e$message, "\n")
  })
}

if (length(all_zw) > 0) {
  # Use the 2017 data as our primary treatment classification
  # (earliest available, closest to post-referendum implementation)
  zw_2017 <- all_zw[[grep("2017", names(all_zw))[1]]]
  cat("\n2017 Zweitwohnungsanteil:\n")
  cat("  Municipalities:", nrow(zw_2017), "\n")
  cat("  Columns:", paste(names(zw_2017), collapse = ", "), "\n")

  # ZWG_3120 = second home share (%)
  cat("  Second home share (ZWG_3120) summary:\n")
  print(summary(zw_2017$ZWG_3120))
  cat("  Municipalities > 20%:", sum(zw_2017$ZWG_3120 > 20, na.rm = TRUE), "\n")
  cat("  Municipalities <= 20%:", sum(zw_2017$ZWG_3120 <= 20, na.rm = TRUE), "\n")

  # Save clean version
  zw_clean <- zw_2017 %>%
    select(gem_no = GEM_NO, name = NAME,
           dwellings_permanent = ZWG_3010,
           dwellings_total = ZWG_3150,
           share_permanent = ZWG_3110,
           share_secondhome = ZWG_3120) %>%
    mutate(treated = as.integer(share_secondhome > 20))

  write_csv(zw_clean, file.path(data_dir, "zweitwohnungsanteil_clean.csv"))
  cat("Saved zweitwohnungsanteil_clean.csv:", nrow(zw_clean), "rows\n")
  cat("  Treated (>20%):", sum(zw_clean$treated, na.rm = TRUE), "\n")
  cat("  Control (<=20%):", sum(zw_clean$treated == 0, na.rm = TRUE), "\n")
}

# ══════════════════════════════════════════════════════════════════════════════
# 5. BUILD ANALYSIS PANEL
# ══════════════════════════════════════════════════════════════════════════════
cat("\n=== Building Analysis Panel ===\n")

# --- Parse STATENT municipality data ---
if (exists("statent_raw") && nrow(statent_raw) > 0) {
  cat("Parsing STATENT...\n")
  cat("  Columns:", paste(names(statent_raw), collapse = ", "), "\n")

  # Identify column names from the JSON-stat2 output
  # Expected: year, municipality, sector, observation_unit, value
  col_names <- names(statent_raw)
  cat("  First non-empty rows:\n")
  print(head(statent_raw[!is.na(statent_raw$value) & statent_raw$value > 0, ], 3))

  # The municipality column should contain BFS Gemeindenummer
  # Extract numeric municipality ID from the label
  muni_col <- col_names[grepl("Gemeinde|Kanton|Region", col_names, ignore.case = TRUE)]
  sector_col <- col_names[grepl("Sektor|Wirtschaft", col_names, ignore.case = TRUE)]
  year_col <- col_names[grepl("Jahr", col_names, ignore.case = TRUE)]
  obs_col <- col_names[grepl("Beobachtung", col_names, ignore.case = TRUE)]

  cat("  Municipality col:", muni_col, "\n")
  cat("  Sector col:", sector_col, "\n")
  cat("  Year col:", year_col, "\n")
  cat("  Obs unit col:", obs_col, "\n")

  # Filter to Beschäftigte (employees) and total employment
  # Parse municipality number from label like "......1234 Gemeindename"
  statent_panel <- statent_raw %>%
    rename(municipality = all_of(muni_col[1]),
           sector = all_of(sector_col[1]),
           year = all_of(year_col[1]),
           obs_unit = all_of(obs_col[1])) %>%
    filter(!is.na(value)) %>%
    # Extract BFS number from municipality label
    mutate(
      gem_no = as.integer(str_extract(municipality, "\\d+")),
      year_num = as.integer(str_extract(year, "\\d{4}"))
    ) %>%
    filter(!is.na(gem_no), !is.na(year_num))

  cat("  Parsed rows:", nrow(statent_panel), "\n")
  cat("  Unique municipalities:", n_distinct(statent_panel$gem_no), "\n")
  cat("  Years:", paste(sort(unique(statent_panel$year_num)), collapse = ", "), "\n")
  cat("  Sectors:", paste(unique(statent_panel$sector), collapse = " | "), "\n")
  cat("  Obs units:", paste(unique(statent_panel$obs_unit), collapse = " | "), "\n")

  # Keep only total Beschäftigte (not gender-disaggregated)
  # Pivot to wide format: one row per municipality-year
  emp_panel <- statent_panel %>%
    filter(obs_unit == "Beschäftigte") %>%
    select(gem_no, year = year_num, sector, value) %>%
    # Create sector labels
    mutate(sector_short = case_when(
      grepl("Total|Insgesamt", sector) ~ "total",
      grepl("Primär|1\\.", sector) ~ "primary",
      grepl("Sekundär|2\\.", sector) ~ "secondary",
      grepl("Tertiär|3\\.", sector) ~ "tertiary",
      TRUE ~ "other"
    )) %>%
    # Pivot wider: employment by sector
    select(gem_no, year, sector_short, value) %>%
    pivot_wider(names_from = sector_short, values_from = value,
                names_prefix = "emp_", values_fn = sum)

  cat("  Employment panel:", nrow(emp_panel), "rows\n")
  cat("  Columns:", paste(names(emp_panel), collapse = ", "), "\n")

  # Also extract FTE (Vollzeitäquivalente) for robustness
  fte_panel <- statent_panel %>%
    filter(obs_unit == "Vollzeitäquivalente") %>%
    select(gem_no, year = year_num, sector, value) %>%
    mutate(sector_short = case_when(
      grepl("Total|Insgesamt", sector) ~ "total",
      grepl("Primär|1\\.", sector) ~ "primary",
      grepl("Sekundär|2\\.", sector) ~ "secondary",
      grepl("Tertiär|3\\.", sector) ~ "tertiary",
      TRUE ~ "other"
    )) %>%
    select(gem_no, year, sector_short, value) %>%
    pivot_wider(names_from = sector_short, values_from = value,
                names_prefix = "fte_", values_fn = sum)

  # Also extract establishments (Arbeitsstätten) for extensive margin
  estab_panel <- statent_panel %>%
    filter(obs_unit == "Arbeitsstätten") %>%
    select(gem_no, year = year_num, sector, value) %>%
    mutate(sector_short = case_when(
      grepl("Total|Insgesamt", sector) ~ "total",
      grepl("Primär|1\\.", sector) ~ "primary",
      grepl("Sekundär|2\\.", sector) ~ "secondary",
      grepl("Tertiär|3\\.", sector) ~ "tertiary",
      TRUE ~ "other"
    )) %>%
    select(gem_no, year, sector_short, value) %>%
    pivot_wider(names_from = sector_short, values_from = value,
                names_prefix = "estab_", values_fn = sum)

  emp_panel <- emp_panel %>%
    left_join(fte_panel, by = c("gem_no", "year")) %>%
    left_join(estab_panel, by = c("gem_no", "year"))

  cat("  Panel with FTE + establishments:", nrow(emp_panel), "rows,",
      ncol(emp_panel), "cols\n")
}

# --- Parse construction data ---
if (exists("constr_df") && nrow(constr_df) > 0) {
  cat("\nParsing construction data...\n")
  cat("  Columns:", paste(names(constr_df), collapse = ", "), "\n")

  constr_col <- names(constr_df)
  muni_col_c <- constr_col[grepl("Gemeinde|Kanton|Region", constr_col, ignore.case = TRUE)]
  year_col_c <- constr_col[grepl("Jahr", constr_col, ignore.case = TRUE)]

  # The two construction tables have different municipality column names
  # _101: "Kanton (-) / Gemeinde (......)"
  # _105: "Grossregion (<<) / Kanton (-) / Gemeinde (......)"
  # Coalesce both columns to get municipality info

  # Coalesce both municipality columns to handle both table formats
  constr_panel <- constr_df %>%
    mutate(
      municipality = coalesce(!!!syms(muni_col_c)),
      year_label = .[[year_col_c[1]]]
    ) %>%
    # Extract BFS number from "......NNNN Name" format
    filter(grepl("\\.{6}", municipality)) %>%
    mutate(
      gem_no = as.integer(str_extract(municipality, "(?<=\\.{6})\\d+")),
      year = as.integer(year_label)
    ) %>%
    filter(!is.na(gem_no), !is.na(year))

  cat("  Construction years:", paste(sort(unique(constr_panel$year)), collapse = ", "), "\n")

  # Aggregate new dwellings: total across room sizes
  # Sum all dwelling types for each municipality-year
  new_dwellings <- constr_panel %>%
    group_by(gem_no, year) %>%
    summarise(new_dwellings = sum(value, na.rm = TRUE), .groups = "drop")

  cat("  New dwellings panel:", nrow(new_dwellings), "rows\n")
}

# --- Merge all into analysis panel ---
if (exists("emp_panel") && exists("zw_clean")) {
  cat("\nMerging panels...\n")

  panel <- emp_panel %>%
    left_join(zw_clean %>% select(gem_no, share_secondhome, treated, name),
              by = "gem_no")

  if (exists("new_dwellings")) {
    panel <- panel %>%
      left_join(new_dwellings, by = c("gem_no", "year"))
  }

  # Drop municipalities with no treatment classification
  panel <- panel %>%
    filter(!is.na(treated))

  # Create key variables
  panel <- panel %>%
    mutate(
      post = as.integer(year >= 2016),
      treat_post = treated * post,
      log_emp_total = log(pmax(emp_total, 1)),
      log_emp_tertiary = log(pmax(emp_tertiary, 1)),
      log_emp_secondary = log(pmax(emp_secondary, 1)),
      log_emp_primary = log(pmax(emp_primary, 1)),
      log_fte_total = log(pmax(fte_total, 1)),
      log_fte_tertiary = log(pmax(fte_tertiary, 1)),
      log_estab_total = log(pmax(estab_total, 1)),
      log_new_dwellings = log(pmax(new_dwellings, 1))
    )

  cat("\n=== FINAL PANEL ===\n")
  cat("Rows:", nrow(panel), "\n")
  cat("Municipalities:", n_distinct(panel$gem_no), "\n")
  cat("Years:", paste(sort(unique(panel$year)), collapse = ", "), "\n")
  cat("Treated:", sum(panel$treated == 1 & panel$year == min(panel$year)), "\n")
  cat("Control:", sum(panel$treated == 0 & panel$year == min(panel$year)), "\n")

  # Summary by treatment group
  cat("\nMeans by treatment group (all years):\n")
  panel %>%
    group_by(treated) %>%
    summarise(
      n_muni = n_distinct(gem_no),
      mean_emp_total = mean(emp_total, na.rm = TRUE),
      mean_emp_tertiary = mean(emp_tertiary, na.rm = TRUE),
      mean_new_dwellings = mean(new_dwellings, na.rm = TRUE),
      mean_sh_share = mean(share_secondhome, na.rm = TRUE)
    ) %>%
    print()

  write_csv(panel, file.path(data_dir, "analysis_panel.csv"))
  cat("\nSaved analysis_panel.csv\n")
}

cat("\n========== DATA FILES ==========\n")
for (f in list.files(data_dir, pattern = "\\.csv$")) {
  sz <- file.info(file.path(data_dir, f))$size
  cat("  ", f, ":", round(sz / 1024, 1), "KB\n")
}
