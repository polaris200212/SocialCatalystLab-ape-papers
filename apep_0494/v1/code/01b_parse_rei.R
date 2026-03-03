## ===========================================================================
## 01b_parse_rei.R — Parse REI tax rate files into standardized CSVs
## apep_0494: Property Tax Capitalization from France's TH Abolition
## ===========================================================================

source("00_packages.R")

# ============================================================================
# 1. Parse REI 2017 (XLSX with coded column names)
# ============================================================================

cat("=== Parsing REI 2017 ===\n")

rei_2017_xlsx <- file.path(DAT, "REI-2017-fichier-notice-trace/REI_COMPLET_2017.xlsx")

if (file.exists(rei_2017_xlsx)) {
  # Read first few rows to identify structure
  cat("  Reading REI 2017 XLSX (114 MB, ~35K rows)...\n")
  rei2017 <- as.data.table(read_excel(rei_2017_xlsx))
  cat(sprintf("  Rows: %d, Columns: %d\n", nrow(rei2017), ncol(rei2017)))

  # Key columns from REI codebook:
  # CODGEO = commune code (5-digit INSEE)
  # LIBGEO = commune name
  # B12 = TH commune rate (taux voté)
  # E12 = TFB commune rate (taux voté)
  # B33 = TH produit (revenue)
  # E33 = TFB produit (revenue)
  # B31 = TH base nette (tax base)
  # E31 = TFB base nette (tax base)

  # REI 2017 uses DEP (département) + COM (commune) to form the 5-digit INSEE code
  # Column names: DEP, DIR, COM, REC, ...
  cat("  Column names (first 20): ", paste(names(rei2017)[1:20], collapse=", "), "\n")

  if ("DEP" %in% names(rei2017) && "COM" %in% names(rei2017)) {
    # Construct 5-digit commune code from DEP + COM
    rei2017[, code_commune := paste0(
      str_pad(as.character(DEP), 2, pad = "0"),
      str_pad(as.character(COM), 3, pad = "0")
    )]
    cat(sprintf("  Built code_commune from DEP+COM. Sample: %s\n",
                paste(head(rei2017$code_commune, 5), collapse = ", ")))
    codgeo_col <- "code_commune"
  } else {
    codgeo_col <- grep("^CODGEO$|^codgeo$|^CODE.COMMUNE|^CODCOM", names(rei2017), value = TRUE)
    if (length(codgeo_col) == 0) stop("Cannot find commune code column in REI 2017")
  }
  cat(sprintf("  Commune code column: %s\n", codgeo_col[1]))

  # Check for B12 and E12
  stopifnot("B12 column not found in REI 2017" = "B12" %in% names(rei2017))
  stopifnot("E12 column not found in REI 2017" = "E12" %in% names(rei2017))

  # Also look for LIBGEO or name column
  lib_col <- grep("^LIBGEO$|^LIB|^NOM", names(rei2017), value = TRUE)
  lib_col <- if (length(lib_col) > 0) lib_col[1] else NA

  # Extract and standardize
  rei2017_clean <- data.table(
    code_commune = as.character(rei2017[[codgeo_col[1]]]),
    libcom = if (!is.na(lib_col)) as.character(rei2017[[lib_col]]) else NA_character_,
    taux_th = as.numeric(rei2017[["B12"]]),
    taux_tfb = as.numeric(rei2017[["E12"]]),
    produit_th = if ("B33" %in% names(rei2017)) as.numeric(rei2017[["B33"]]) else NA_real_,
    produit_tfb = if ("E33" %in% names(rei2017)) as.numeric(rei2017[["E33"]]) else NA_real_,
    base_th = if ("B31" %in% names(rei2017)) as.numeric(rei2017[["B31"]]) else NA_real_,
    base_tfb = if ("E31" %in% names(rei2017)) as.numeric(rei2017[["E31"]]) else NA_real_,
    annee = 2017L
  )

  # Add dept code
  rei2017_clean[, dept := substr(code_commune, 1, 2)]

  # Clean
  rei2017_clean <- rei2017_clean[!is.na(code_commune) & nchar(code_commune) == 5]
  rei2017_clean <- rei2017_clean[!is.na(taux_th)]

  cat(sprintf("  Parsed: %d communes\n", nrow(rei2017_clean)))
  cat(sprintf("  Mean TH rate: %.2f%%\n", mean(rei2017_clean$taux_th, na.rm = TRUE)))
  cat(sprintf("  Mean TFB rate: %.2f%%\n", mean(rei2017_clean$taux_tfb, na.rm = TRUE)))
  cat(sprintf("  TH rate range: %.2f%% to %.2f%%\n",
              min(rei2017_clean$taux_th, na.rm = TRUE),
              max(rei2017_clean$taux_th, na.rm = TRUE)))

  fwrite(rei2017_clean, file.path(DAT, "rei_2017_parsed.csv"))
  cat("  Saved rei_2017_parsed.csv\n")

  rm(rei2017)
  gc()
} else {
  stop("REI 2017 XLSX not found at: ", rei_2017_xlsx)
}


# ============================================================================
# 2. Parse REI 2020 (for intermediate year)
# ============================================================================

cat("\n=== Parsing REI 2020 ===\n")

rei_2020_zip <- file.path(DAT, "rei_2020.zip")

if (file.exists(rei_2020_zip)) {
  zip_contents <- unzip(rei_2020_zip, list = TRUE)$Name
  cat(sprintf("  ZIP contents: %s\n", paste(zip_contents, collapse = ", ")))

  # Find the main data file
  xlsx_file <- grep("\\.xlsx$", zip_contents, value = TRUE, ignore.case = TRUE)
  if (length(xlsx_file) == 0) xlsx_file <- zip_contents[1]

  tmpdir <- tempdir()
  unzip(rei_2020_zip, exdir = tmpdir)
  fpath <- file.path(tmpdir, xlsx_file[1])

  cat(sprintf("  Reading %s...\n", xlsx_file[1]))
  rei2020 <- as.data.table(read_excel(fpath))
  cat(sprintf("  Rows: %d, Columns: %d\n", nrow(rei2020), ncol(rei2020)))

  # Build commune code from DEP+COM or find CODGEO
  cat("  Column names (first 20): ", paste(names(rei2020)[1:20], collapse=", "), "\n")
  if ("DEP" %in% names(rei2020) && "COM" %in% names(rei2020)) {
    rei2020[, code_commune := paste0(str_pad(as.character(DEP), 2, pad="0"),
                                     str_pad(as.character(COM), 3, pad="0"))]
    codgeo_col <- "code_commune"
  } else {
    codgeo_col <- grep("^CODGEO$|^codgeo$|^CODE", names(rei2020), value = TRUE)
    if (length(codgeo_col) == 0) codgeo_col <- names(rei2020)[1]
  }

  # REI 2020+ uses descriptive column names instead of codes
  # Find columns by matching patterns
  nms <- names(rei2020)
  th_col <- grep("^TH - COMMUNE / TAUX", nms, value = TRUE)
  # Prefer TAUX VOTE over TAUX NET
  th_vote <- grep("TAUX VOTE", th_col, value = TRUE)
  th_col <- if (length(th_vote) > 0) th_vote[1] else if (length(th_col) > 0) th_col[1] else NA

  tfb_col <- grep("^FB - COMMUNE / TAUX", nms, value = TRUE)
  tfb_vote <- grep("TAUX VOTE", tfb_col, value = TRUE)
  tfb_col <- if (length(tfb_vote) > 0) tfb_vote[1] else if (length(tfb_col) > 0) tfb_col[1] else NA

  cat(sprintf("  TH rate column: %s\n", th_col))
  cat(sprintf("  TFB rate column: %s\n", tfb_col))

  # Also check for coded columns as fallback
  if (is.na(th_col) && "B12" %in% nms) th_col <- "B12"
  if (is.na(tfb_col) && "E12" %in% nms) tfb_col <- "E12"

  lib_col <- grep("^Libell.*commune$|^LIBCOM$|^LIB", nms, value = TRUE)
  lib_col <- if (length(lib_col) > 0) lib_col[1] else NA

  # Product and base columns
  prod_th <- grep("^TH - COMMUNE / MONTANT REEL", nms, value = TRUE)
  prod_th_col <- if (length(prod_th) > 0) prod_th[1] else NA
  prod_tfb <- grep("^FB - COMMUNE / MONTANT REEL", nms, value = TRUE)
  prod_tfb_col <- if (length(prod_tfb) > 0) prod_tfb[1] else NA
  base_th <- grep("^TH - COMMUNE / BASE NETTE$", nms, value = TRUE)
  base_th_col <- if (length(base_th) > 0) base_th[1] else NA
  base_tfb <- grep("^FB - COMMUNE / BASE NETTE$", nms, value = TRUE)
  base_tfb_col <- if (length(base_tfb) > 0) base_tfb[1] else NA

  # Build commune code from DEPARTEMENT + COMMUNE
  dep_col <- grep("^DEPARTEMENT$|^DEP$", nms, value = TRUE)
  com_col <- grep("^COMMUNE$|^COM$", nms, value = TRUE)
  if (length(dep_col) > 0 && length(com_col) > 0) {
    rei2020[, code_commune := paste0(str_pad(as.character(get(dep_col[1])), 2, pad="0"),
                                     str_pad(as.character(get(com_col[1])), 3, pad="0"))]
    codgeo_col <- "code_commune"
  }

  if (!is.na(tfb_col) || !is.na(th_col)) {
    rei2020_clean <- data.table(
      code_commune = as.character(rei2020[[codgeo_col[1]]]),
      libcom = if (!is.na(lib_col)) as.character(rei2020[[lib_col]]) else NA_character_,
      taux_th = if (!is.na(th_col)) as.numeric(rei2020[[th_col]]) else NA_real_,
      taux_tfb = if (!is.na(tfb_col)) as.numeric(rei2020[[tfb_col]]) else NA_real_,
      produit_th = if (!is.na(prod_th_col)) as.numeric(rei2020[[prod_th_col]]) else NA_real_,
      produit_tfb = if (!is.na(prod_tfb_col)) as.numeric(rei2020[[prod_tfb_col]]) else NA_real_,
      base_th = if (!is.na(base_th_col)) as.numeric(rei2020[[base_th_col]]) else NA_real_,
      base_tfb = if (!is.na(base_tfb_col)) as.numeric(rei2020[[base_tfb_col]]) else NA_real_,
      annee = 2020L
    )

    rei2020_clean[, dept := substr(code_commune, 1, 2)]
    rei2020_clean <- rei2020_clean[!is.na(code_commune) & nchar(code_commune) == 5]
    rei2020_clean <- rei2020_clean[!is.na(taux_th) | !is.na(taux_tfb)]

    cat(sprintf("  Parsed: %d communes\n", nrow(rei2020_clean)))
    if (!is.na(th_col)) cat(sprintf("  Mean TH rate: %.2f%%\n", mean(rei2020_clean$taux_th, na.rm = TRUE)))
    cat(sprintf("  Mean TFB rate: %.2f%%\n", mean(rei2020_clean$taux_tfb, na.rm = TRUE)))

    fwrite(rei2020_clean, file.path(DAT, "rei_2020_parsed.csv"))
    cat("  Saved rei_2020_parsed.csv\n")
  } else {
    cat("  WARNING: Could not find TH or TFB rate column in REI 2020\n")
  }

  rm(rei2020)
  gc()
  unlink(tmpdir, recursive = TRUE)
}


# ============================================================================
# 3. Parse REI 2022
# ============================================================================

cat("\n=== Parsing REI 2022 ===\n")

rei_2022_zip <- file.path(DAT, "rei_2022.zip")

if (file.exists(rei_2022_zip)) {
  zip_contents <- unzip(rei_2022_zip, list = TRUE)$Name
  cat(sprintf("  ZIP contents: %s\n", paste(zip_contents, collapse = ", ")))

  xlsx_file <- grep("\\.xlsx$", zip_contents, value = TRUE, ignore.case = TRUE)
  if (length(xlsx_file) == 0) xlsx_file <- zip_contents[1]

  tmpdir <- tempdir()
  unzip(rei_2022_zip, exdir = tmpdir)
  fpath <- file.path(tmpdir, xlsx_file[1])

  cat(sprintf("  Reading %s...\n", xlsx_file[1]))
  rei2022 <- as.data.table(read_excel(fpath))
  cat(sprintf("  Rows: %d, Columns: %d\n", nrow(rei2022), ncol(rei2022)))

  cat("  Column names (first 20): ", paste(names(rei2022)[1:20], collapse=", "), "\n")
  if ("DEP" %in% names(rei2022) && "COM" %in% names(rei2022)) {
    rei2022[, code_commune := paste0(str_pad(as.character(DEP), 2, pad="0"),
                                     str_pad(as.character(COM), 3, pad="0"))]
    codgeo_col <- "code_commune"
  } else {
    codgeo_col <- grep("^CODGEO$|^codgeo$|^CODE", names(rei2022), value = TRUE)
    if (length(codgeo_col) == 0) codgeo_col <- names(rei2022)[1]
  }

  # REI 2022 uses same descriptive column names as 2020
  nms <- names(rei2022)

  th_col <- grep("^TH - COMMUNE / TAUX", nms, value = TRUE)
  th_vote <- grep("TAUX VOTE", th_col, value = TRUE)
  th_col <- if (length(th_vote) > 0) th_vote[1] else if (length(th_col) > 0) th_col[1] else NA

  tfb_col <- grep("^FB - COMMUNE / TAUX", nms, value = TRUE)
  tfb_vote <- grep("TAUX VOTE", tfb_col, value = TRUE)
  tfb_col <- if (length(tfb_vote) > 0) tfb_vote[1] else if (length(tfb_col) > 0) tfb_col[1] else NA

  if (is.na(th_col) && "B12" %in% nms) th_col <- "B12"
  if (is.na(tfb_col) && "E12" %in% nms) tfb_col <- "E12"

  cat(sprintf("  TH rate column: %s\n", th_col))
  cat(sprintf("  TFB rate column: %s\n", tfb_col))

  dep_col <- grep("^DEPARTEMENT$|^DEP$", nms, value = TRUE)
  com_col <- grep("^COMMUNE$|^COM$", nms, value = TRUE)
  if (length(dep_col) > 0 && length(com_col) > 0) {
    rei2022[, code_commune := paste0(str_pad(as.character(get(dep_col[1])), 2, pad="0"),
                                     str_pad(as.character(get(com_col[1])), 3, pad="0"))]
    codgeo_col <- "code_commune"
  }

  lib_col <- grep("^Libell.*commune$|^LIBCOM$|^LIB", nms, value = TRUE)
  lib_col <- if (length(lib_col) > 0) lib_col[1] else NA

  prod_tfb <- grep("^FB - COMMUNE / MONTANT REEL", nms, value = TRUE)
  prod_tfb_col <- if (length(prod_tfb) > 0) prod_tfb[1] else NA
  base_tfb <- grep("^FB - COMMUNE / BASE NETTE$", nms, value = TRUE)
  base_tfb_col <- if (length(base_tfb) > 0) base_tfb[1] else NA

  if (!is.na(tfb_col) || !is.na(th_col)) {
    rei2022_clean <- data.table(
      code_commune = as.character(rei2022[[codgeo_col[1]]]),
      libcom = if (!is.na(lib_col)) as.character(rei2022[[lib_col]]) else NA_character_,
      taux_th = if (!is.na(th_col)) as.numeric(rei2022[[th_col]]) else NA_real_,
      taux_tfb = if (!is.na(tfb_col)) as.numeric(rei2022[[tfb_col]]) else NA_real_,
      produit_th = NA_real_,
      produit_tfb = if (!is.na(prod_tfb_col)) as.numeric(rei2022[[prod_tfb_col]]) else NA_real_,
      base_th = NA_real_,
      base_tfb = if (!is.na(base_tfb_col)) as.numeric(rei2022[[base_tfb_col]]) else NA_real_,
      annee = 2022L
    )

    rei2022_clean[, dept := substr(code_commune, 1, 2)]
    rei2022_clean <- rei2022_clean[!is.na(code_commune) & nchar(code_commune) == 5]
    rei2022_clean <- rei2022_clean[!is.na(taux_tfb) | !is.na(taux_th)]

    cat(sprintf("  Parsed: %d communes\n", nrow(rei2022_clean)))
    cat(sprintf("  Mean TFB rate: %.2f%%\n", mean(rei2022_clean$taux_tfb, na.rm = TRUE)))

    fwrite(rei2022_clean, file.path(DAT, "rei_2022_parsed.csv"))
    cat("  Saved rei_2022_parsed.csv\n")
  }

  rm(rei2022)
  gc()
  unlink(tmpdir, recursive = TRUE)
}


# ============================================================================
# 4. Combine All Parsed REI Files
# ============================================================================

cat("\n=== Combining all parsed REI files ===\n")

rei_files <- list.files(DAT, pattern = "rei_\\d{4}_parsed\\.csv$", full.names = TRUE)
cat(sprintf("  Found %d parsed REI files: %s\n", length(rei_files),
            paste(basename(rei_files), collapse = ", ")))

rei_all <- rbindlist(lapply(rei_files, fread), fill = TRUE)
setnames(rei_all, "annee", "year")

cat(sprintf("  Combined REI: %d rows, years %s\n",
            nrow(rei_all), paste(sort(unique(rei_all$year)), collapse = ", ")))

# Validate
stopifnot("Expected communes in REI" = nrow(rei_all) > 30000)
stopifnot("Expected 2017 in REI" = 2017 %in% rei_all$year)

cat("\n=== REI parsing complete ===\n")
