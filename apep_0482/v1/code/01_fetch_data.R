## ============================================================
## 01_fetch_data.R — Data acquisition
## Downloads: CONPREL budget data, election candidate data,
##            INE Padrón population data
## ============================================================

source("00_packages.R")

data_dir <- "../data"
dir.create(data_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(file.path(data_dir, "conprel"), showWarnings = FALSE)
dir.create(file.path(data_dir, "elections"), showWarnings = FALSE)

## ----------------------------------------------------------
## 1. CONPREL Municipal Budget Data (Liquidaciones)
##    Source: Ministerio de Hacienda
##    Format: .accdb (Access 2007+) in ZIP
##    Years: 2010-2023 (post-classification-reform)
## ----------------------------------------------------------

conprel_years <- 2010:2023

for (yr in conprel_years) {
  zip_file <- file.path(data_dir, "conprel", paste0("liq_", yr, ".zip"))
  csv_inv  <- file.path(data_dir, "conprel", paste0("inventario_", yr, ".csv"))
  csv_func <- file.path(data_dir, "conprel", paste0("funcional_", yr, ".csv"))

  if (file.exists(csv_func)) {
    cat("Year", yr, "already processed.\n")
    next
  }

  # Download ZIP
  if (!file.exists(zip_file)) {
    cat("Downloading CONPREL liquidaciones", yr, "...\n")
    url <- paste0(
      "https://serviciostelematicosext.hacienda.gob.es/SGFAL/CONPREL/",
      "Consulta/DescargaFichero?CCAA=&TipoDato=Liquidaciones&Ejercicio=",
      yr, "&TipoPublicacion=Access"
    )
    resp <- GET(url, write_disk(zip_file, overwrite = TRUE),
                config(ssl_verifypeer = FALSE), timeout(300))
    if (status_code(resp) != 200) {
      warning("Failed to download year ", yr, ": HTTP ", status_code(resp))
      file.remove(zip_file)
      next
    }
    cat("  Downloaded:", round(file.info(zip_file)$size / 1e6, 1), "MB\n")
  }

  # Unzip to temp dir
  tmp_dir <- tempdir()
  unzip(zip_file, exdir = tmp_dir)

  # Find the .accdb file
  accdb <- list.files(tmp_dir, pattern = "\\.accdb$", full.names = TRUE,
                      recursive = TRUE)
  if (length(accdb) == 0) {
    # Try .mdb as fallback
    accdb <- list.files(tmp_dir, pattern = "\\.mdb$", full.names = TRUE,
                        recursive = TRUE)
  }
  if (length(accdb) == 0) {
    warning("No Access file found for year ", yr)
    next
  }
  accdb <- accdb[1]
  cat("  Access file:", basename(accdb), "\n")

  # Export tables using mdb-export
  cat("  Exporting tb_inventario...\n")
  system2("mdb-export", args = c(shQuote(accdb), "tb_inventario"),
          stdout = csv_inv)

  cat("  Exporting tb_funcional...\n")
  system2("mdb-export", args = c(shQuote(accdb), "tb_funcional"),
          stdout = csv_func)

  # Verify
  if (file.exists(csv_func) && file.info(csv_func)$size > 0) {
    n_rows <- length(readLines(csv_func)) - 1
    cat("  Year", yr, ":", n_rows, "program-level spending records\n")
  } else {
    warning("Export failed for year ", yr)
  }

  # Clean up extracted files
  file.remove(accdb)
}

## ----------------------------------------------------------
## 2. INE Padrón Municipal (Population Data)
##    Running variable for RDD
##    Source: INE JSON API
## ----------------------------------------------------------

padron_file <- file.path(data_dir, "padron_municipal.csv")

if (!file.exists(padron_file)) {
  cat("Downloading INE Padrón Municipal data...\n")

  # The API returns population by municipality
  # Table 29005: Cifras oficiales de población por municipio
  padron_url <- "https://servicios.ine.es/wstempus/js/es/DATOS_TABLA/29005?tip=AM"

  resp <- GET(padron_url, timeout(300))
  if (status_code(resp) == 200) {
    padron_raw <- content(resp, as = "text", encoding = "UTF-8")
    padron_json <- fromJSON(padron_raw)

    # Parse the JSON structure — INE API returns nested data
    # Each entry has Nombre (municipality name), Data (time series)
    padron_list <- list()
    for (i in seq_along(padron_json$Nombre)) {
      if (length(padron_json$Data[[i]]) > 0) {
        df_i <- padron_json$Data[[i]]
        df_i$municipio <- padron_json$Nombre[i]
        df_i$cod_municipio <- padron_json$COD[i]
        padron_list[[i]] <- df_i
      }
    }
    padron_df <- bind_rows(padron_list)
    write_csv(padron_df, padron_file)
    cat("  Padrón data:", nrow(padron_df), "rows\n")
  } else {
    cat("  INE API returned HTTP", status_code(resp), "\n")
    cat("  Falling back to bulk download...\n")

    # Fallback: download CSV from INE
    bulk_url <- "https://www.ine.es/jaxi/files/_px/es/csv_bdsc/t20/e245/p04/provi/l0/0tamu001.csv_bdsc?nocab=1"
    resp2 <- GET(bulk_url, write_disk(padron_file, overwrite = TRUE),
                 timeout(300))
    cat("  Bulk download:", round(file.info(padron_file)$size / 1e6, 1), "MB\n")
  }
} else {
  cat("Padrón data already exists.\n")
}

## ----------------------------------------------------------
## 3. Election Candidate Data (Gender)
##    Source: Ministerio del Interior via direct download
##    Municipal elections: 2003, 2007, 2011, 2015, 2019, 2023
## ----------------------------------------------------------

# Download raw ZIP files from Ministerio del Interior
election_years <- list(
  c(2003, "05"), c(2007, "05"), c(2011, "05"),
  c(2015, "05"), c(2019, "05"), c(2023, "05")
)

for (ey in election_years) {
  yr <- ey[1]
  mo <- ey[2]
  yr_short <- substr(as.character(yr), 3, 4)

  zip_file <- file.path(data_dir, "elections", paste0("municipal_", yr, ".zip"))

  if (!file.exists(zip_file)) {
    cat("Downloading municipal election data", yr, "...\n")

    # URL pattern from Ministerio del Interior
    url <- paste0(
      "https://infoelectoral.interior.gob.es/estaticos/docxl/apliextr/04",
      yr_short, mo, "_MUNI.zip"
    )

    resp <- GET(url, write_disk(zip_file, overwrite = TRUE),
                config(ssl_verifypeer = FALSE), timeout(120))

    if (status_code(resp) != 200 || file.info(zip_file)$size < 1000) {
      cat("  Primary URL failed for", yr, ". Trying alternate...\n")
      # Try alternate URL pattern
      url2 <- paste0(
        "https://infoelectoral.interior.gob.es/estaticos/docxl/apliextr/04",
        yr_short, mo, "_MESA.zip"
      )
      resp <- GET(url2, write_disk(zip_file, overwrite = TRUE),
                  config(ssl_verifypeer = FALSE), timeout(120))
    }

    if (status_code(resp) == 200 && file.info(zip_file)$size > 1000) {
      cat("  Downloaded:", round(file.info(zip_file)$size / 1e6, 1), "MB\n")
    } else {
      cat("  WARNING: Failed to download election data for", yr, "\n")
      file.remove(zip_file)
    }
  } else {
    cat("Election data", yr, "already exists.\n")
  }
}

cat("\n=== Data acquisition complete ===\n")
cat("CONPREL budget files:", length(list.files(file.path(data_dir, "conprel"),
    pattern = "funcional.*\\.csv")), "years\n")
cat("Election ZIPs:", length(list.files(file.path(data_dir, "elections"),
    pattern = "\\.zip$")), "elections\n")
cat("Padrón:", file.exists(padron_file), "\n")
