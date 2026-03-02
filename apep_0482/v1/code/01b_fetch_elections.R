## ============================================================
## 01b_fetch_elections.R — Download and parse election data
## Uses R's download.file (works with this server) and
## manually parses fixed-width candidate files
## ============================================================

source("00_packages.R")

data_dir <- "../data"

parse_election_zip <- function(url, election_year) {
  tmp <- tempdir()
  zip_file <- file.path(tmp, paste0("elec_", election_year, ".zip"))

  resp <- GET(url, write_disk(zip_file, overwrite = TRUE),
              config(ssl_verifypeer = FALSE), timeout(300))
  if (status_code(resp) != 200) {
    cat("  HTTP error:", status_code(resp), "\n")
    return(NULL)
  }

  files <- unzip(zip_file, exdir = tmp)

  # Find type-04 file (candidates)
  cand_file <- files[grepl("^04", basename(files)) &
                      grepl("[.]DAT$", basename(files), ignore.case = TRUE)]

  if (length(cand_file) == 0) {
    cat("  No candidate file for", election_year, "\n")
    return(NULL)
  }

  lines <- readLines(cand_file[1], encoding = "latin1", warn = FALSE)
  cat("  Year", election_year, ":", length(lines), "lines\n")

  # Parse fixed-width per Ministry spec (Tipo 04):
  # 1-2: tipo_eleccion, 3-6: anno, 7-8: mes, 9: vuelta
  # 10-11: provincia, 12-14: municipio, 15: distrito
  # 16-21: candidatura, 22-24: orden
  # 25: tipo_candidato (T/S), 26-50: nombre
  # 51-75: apellido1, 76-100: apellido2
  # 101: sexo (M/F), 102-109: nacimiento
  # 110-119: DNI, 120: elegido (S/N)

  dt <- data.table(
    election_year = election_year,
    provincia = substr(lines, 10, 11),
    municipio = substr(lines, 12, 14),
    tipo_cand = trimws(substr(lines, 25, 25)),
    sexo = trimws(substr(lines, 101, 101)),
    elegido = trimws(substr(lines, 120, 120))
  )

  # Construct 5-digit INE code
  dt[, ine_code := paste0(provincia, municipio)]
  dt[, is_female := (sexo == "F")]
  dt[, is_elected := (elegido == "S")]

  cat("  Unique municipalities:", uniqueN(dt$ine_code), "\n")
  cat("  Elected:", sum(dt$is_elected), "\n")
  if (sum(dt$is_elected) > 0 && sum(dt$is_female, na.rm = TRUE) > 0) {
    cat("  Female elected share:",
        round(mean(dt$is_female[dt$is_elected], na.rm = TRUE) * 100, 1), "%\n")
  } else {
    cat("  No gender data or no elected\n")
  }

  return(dt)
}

# URLs (full year format)
urls <- list(
  "2007" = "https://infoelectoral.interior.gob.es/estaticos/docxl/apliextr/04200705_MUNI.zip",
  "2011" = "https://infoelectoral.interior.gob.es/estaticos/docxl/apliextr/04201105_MUNI.zip",
  "2015" = "https://infoelectoral.interior.gob.es/estaticos/docxl/apliextr/04201505_MUNI.zip",
  "2019" = "https://infoelectoral.interior.gob.es/estaticos/docxl/apliextr/04201905_MUNI.zip",
  "2023" = "https://infoelectoral.interior.gob.es/estaticos/docxl/apliextr/04202305_MUNI.zip"
)

all_dt <- list()
for (yr in names(urls)) {
  cat("\nDownloading", yr, "...\n")
  result <- tryCatch(parse_election_zip(urls[[yr]], as.integer(yr)),
                     error = function(e) { cat("  ERROR:", e$message, "\n"); NULL })
  if (!is.null(result)) all_dt[[yr]] <- result
  Sys.sleep(2)
}

elections <- rbindlist(all_dt, fill = TRUE)
cat("\nTotal:", nrow(elections), "candidates\n")
cat("Sample ine_codes:", paste(head(sort(unique(elections$ine_code)), 10), collapse = ", "), "\n")

# Aggregate to municipality-election level
council_gender <- elections[is_elected == TRUE & sexo %in% c("F", "M"),
  .(female_share = mean(is_female, na.rm = TRUE),
    n_female = sum(is_female, na.rm = TRUE),
    n_total = .N),
  by = .(ine_code, election_year)
]

cat("\nCouncil gender:", nrow(council_gender), "municipality-elections\n")
cat("Mean female share:", round(mean(council_gender$female_share) * 100, 1), "%\n")
for (yr in sort(unique(council_gender$election_year))) {
  sub <- council_gender[election_year == yr]
  cat("  ", yr, ": N=", nrow(sub),
      " mean=", round(mean(sub$female_share) * 100, 1), "%\n")
}

fwrite(council_gender, file.path(data_dir, "council_gender.csv"))
cat("\nSaved council_gender.csv\n")
