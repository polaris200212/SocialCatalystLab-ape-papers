## 01_fetch_data.R — Download BTVote V2 data from Harvard Dataverse
## apep_0481: Gender, Electoral Pathway, and Party Discipline in the German Bundestag

source("00_packages.R")

data_dir <- "../data"
dir.create(data_dir, showWarnings = FALSE, recursive = TRUE)

## Harvard Dataverse persistent IDs for BTVote V2
## See: https://dataverse.harvard.edu/dataverse/btvote
datasets <- list(
  voting = list(
    doi = "10.7910/DVN/24U1FR",
    desc = "BTVote Voting Behavior (individual vote records)"
  ),
  mps = list(
    doi = "10.7910/DVN/QSFXLQ",
    desc = "BTVote MP Characteristics (gender, mandate type, party)"
  ),
  votes = list(
    doi = "10.7910/DVN/AHBBXY",
    desc = "BTVote Vote Characteristics (policy area, date, type)"
  )
)

download_dataverse <- function(doi, data_dir, name) {
  out_dir <- file.path(data_dir, name)
  dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

  api_url <- paste0(
    "https://dataverse.harvard.edu/api/datasets/:persistentId?persistentId=doi:",
    doi
  )

  cat(sprintf("Fetching metadata for %s (doi:%s)...\n", name, doi))
  response <- tryCatch(
    jsonlite::fromJSON(api_url),
    error = function(e) {
      cat(sprintf("  Error fetching metadata: %s\n", e$message))
      return(NULL)
    }
  )

  if (is.null(response)) return(NULL)

  files <- response$data$latestVersion$files
  if (is.null(files) || nrow(files) == 0) {
    cat("  No files found in dataset.\n")
    return(NULL)
  }

  cat(sprintf("  Found %d files:\n", nrow(files)))
  downloaded <- character(0)

  for (i in seq_len(nrow(files))) {
    file_id <- files$dataFile$id[i]
    file_name <- files$dataFile$filename[i]
    file_size <- files$dataFile$filesize[i]
    out_path <- file.path(out_dir, file_name)

    if (file.exists(out_path)) {
      cat(sprintf("    [SKIP] %s (already exists)\n", file_name))
      downloaded <- c(downloaded, out_path)
      next
    }

    cat(sprintf("    Downloading %s (%.1f MB)...\n",
                file_name, file_size / 1e6))

    dl_url <- paste0(
      "https://dataverse.harvard.edu/api/access/datafile/", file_id
    )

    tryCatch({
      download.file(dl_url, out_path, mode = "wb", quiet = TRUE)
      cat(sprintf("    [OK] %s\n", file_name))
      downloaded <- c(downloaded, out_path)
    }, error = function(e) {
      cat(sprintf("    [FAIL] %s: %s\n", file_name, e$message))
    })
  }

  return(downloaded)
}

## Download all three datasets
for (name in names(datasets)) {
  cat(sprintf("\n=== %s ===\n", datasets[[name]]$desc))
  download_dataverse(datasets[[name]]$doi, data_dir, name)
}

## Verify downloads
cat("\n=== Verification ===\n")
for (name in names(datasets)) {
  files <- list.files(file.path(data_dir, name), full.names = TRUE)
  cat(sprintf("%s: %d files\n", name, length(files)))
  for (f in files) {
    cat(sprintf("  %s (%.1f MB)\n", basename(f),
                file.info(f)$size / 1e6))
  }
}

cat("\nData download complete.\n")
