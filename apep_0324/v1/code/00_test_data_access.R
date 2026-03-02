# Test CES/CCES data access and BLS state unemployment
# CES cumulative file from Harvard Dataverse

# Test 1: Can we download CES data?
cat("=== TEST 1: CES Data Access ===\n")

# The CES cumulative common content is at Harvard Dataverse
# Individual year files are smaller and more manageable
# Try to download the 2022 CES common content (Stata format, ~50MB)
ces_url <- "https://dataverse.harvard.edu/api/access/datafile/7859383"  # 2022 CES
cat("Attempting CES 2022 download from Harvard Dataverse...\n")

tryCatch({
  # Just download headers to check accessibility
  con <- url(ces_url, "rb")
  test_bytes <- readBin(con, what = "raw", n = 1000)
  close(con)
  cat("SUCCESS: CES data accessible from Harvard Dataverse\n")
  cat("Downloaded", length(test_bytes), "bytes as test\n")
}, error = function(e) {
  cat("FAILED:", e$message, "\n")
})

# Test 2: BLS state unemployment data
cat("\n=== TEST 2: BLS State Unemployment ===\n")
library(jsonlite)

# BLS API v2 - state unemployment rates
# Series LASST010000000000003 = Alabama unemployment rate
bls_url <- "https://api.bls.gov/publicAPI/v2/timeseries/data/LASST010000000000003?startyear=2020&endyear=2024"
tryCatch({
  result <- fromJSON(bls_url)
  if (result$status == "REQUEST_SUCCEEDED") {
    data <- result$Results$series$data[[1]]
    cat("SUCCESS: BLS data accessible\n")
    cat("Sample rows:", nrow(data), "\n")
    print(head(data[, c("year", "period", "value")], 5))
  }
}, error = function(e) {
  cat("FAILED:", e$message, "\n")
})

# Test 3: GSS data via gssr package
cat("\n=== TEST 3: GSS Data via gssr ===\n")
if (!require(gssr, quietly = TRUE)) {
  cat("gssr package not installed. Attempting install...\n")
  install.packages("gssr", repos = "https://cloud.r-project.org", quiet = TRUE)
}
if (require(gssr, quietly = TRUE)) {
  data(gss_all)
  cat("SUCCESS: GSS cumulative data loaded\n")
  cat("Observations:", nrow(gss_all), "\n")
  cat("Variables:", ncol(gss_all), "\n")
  # Check key attitude variables
  key_vars <- c("trust", "getahead", "eqwlth", "natcrime", "grass", "fefam", "cappun", 
                 "courts", "fear", "gunlaw", "homosex", "abany", "natfare", "natheal",
                 "confinan", "conbus", "conlegis", "conjudge")
  available <- key_vars[key_vars %in% names(gss_all)]
  cat("Key attitude variables available:", length(available), "of", length(key_vars), "\n")
  cat("Available:", paste(available, collapse = ", "), "\n")
  
  # Check sample sizes for key variables
  for (v in available[1:min(8, length(available))]) {
    n_valid <- sum(!is.na(gss_all[[v]]))
    cat(sprintf("  %s: %d valid obs\n", v, n_valid))
  }
} else {
  cat("FAILED: Could not install gssr package\n")
}

cat("\n=== TESTS COMPLETE ===\n")
