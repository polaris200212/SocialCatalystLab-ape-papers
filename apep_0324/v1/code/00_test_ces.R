library(jsonlite)

# Get file listing for CES 2022 dataset
cat("=== CES 2022 Dataset Files ===\n")
doi <- "doi:10.7910/DVN/PR4L8P"
files_url <- paste0("https://dataverse.harvard.edu/api/datasets/:persistentId/versions/:latest/files?persistentId=", doi)
tryCatch({
  files <- fromJSON(files_url)
  for (i in 1:nrow(files$data)) {
    f <- files$data[i, ]
    cat(sprintf("  %s (%.1f MB) - id: %s\n", 
                f$dataFile$filename,
                f$dataFile$filesize / 1024 / 1024,
                f$dataFile$id))
  }
}, error = function(e) {
  cat("Error:", e$message, "\n")
})

# Also check CES cumulative (the Guide is at cces.gov.harvard.edu)
cat("\n=== CES Cumulative Common Content ===\n")
# The cumulative dataset: doi:10.7910/DVN/II2DB6
doi_cum <- "doi:10.7910/DVN/II2DB6"
files_url2 <- paste0("https://dataverse.harvard.edu/api/datasets/:persistentId/versions/:latest/files?persistentId=", doi_cum)
tryCatch({
  files2 <- fromJSON(files_url2)
  for (i in 1:nrow(files2$data)) {
    f <- files2$data[i, ]
    cat(sprintf("  %s (%.1f MB) - id: %s\n", 
                f$dataFile$filename,
                f$dataFile$filesize / 1024 / 1024,
                f$dataFile$id))
  }
}, error = function(e) {
  cat("Error:", e$message, "\n")
})
