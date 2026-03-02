# Test alternative data access methods

library(jsonlite)

# Test 1: CES data - try the correct Dataverse API URL
cat("=== TEST 1: CES Data via Dataverse API ===\n")

# Search for CES 2022 dataset
tryCatch({
  # The CCES/CES common content datasets
  # Try direct Dataverse search
  search_url <- "https://dataverse.harvard.edu/api/search?q=cooperative+election+study+2022&type=dataset"
  result <- fromJSON(search_url)
  if (length(result$data$items) > 0) {
    cat("Found", length(result$data$items), "datasets\n")
    for (i in 1:min(3, length(result$data$items))) {
      cat(sprintf("  %d. %s\n", i, result$data$items$name[i]))
      cat(sprintf("     URL: %s\n", result$data$items$url[i]))
    }
  }
}, error = function(e) {
  cat("Search failed:", e$message, "\n")
})

# Test 2: Try downloading GSS data directly from NORC
cat("\n=== TEST 2: GSS Data Direct Download ===\n")

# The GSS cumulative data in Stata format 
# From the GSS data explorer: https://gssdataexplorer.norc.org/
# CSV extract URL
tryCatch({
  # Check if haven is available for reading Stata files
  if (require(haven, quietly = TRUE)) {
    cat("haven package available for reading Stata files\n")
  } else {
    cat("Installing haven...\n")
    install.packages("haven", repos = "https://cloud.r-project.org", quiet = TRUE)
  }
  
  # Try GSS from NORC's data page
  # The cumulative data file is large (~200MB). Let's try a different approach.
  # Use the GSS data from the gssr GitHub repo
  gss_url <- "https://github.com/kjhealy/gssr/raw/master/data/gss_all.rda"
  cat("Attempting GSS download from gssr GitHub repo...\n")
  
  temp_file <- tempfile(fileext = ".rda")
  download.file(gss_url, temp_file, mode = "wb", quiet = TRUE)
  
  load(temp_file)
  if (exists("gss_all")) {
    cat("SUCCESS: GSS cumulative data loaded from GitHub\n")
    cat("Observations:", nrow(gss_all), "\n")
    cat("Variables:", ncol(gss_all), "\n")
    
    # Check key variables
    key_vars <- c("trust", "getahead", "eqwlth", "natcrime", "grass", "fefam", "cappun",
                   "courts", "fear", "gunlaw", "homosex", "abany", "natfare", "natheal",
                   "confinan", "conbus", "conlegis", "conjudge", "year", "region", "age",
                   "sex", "race", "educ", "rincome", "wrkstat", "realinc", "prestg80")
    available <- key_vars[key_vars %in% names(gss_all)]
    cat("\nKey variables available:", length(available), "of", length(key_vars), "\n")
    
    # Check attitude variables
    attitude_vars <- c("trust", "getahead", "eqwlth", "natcrime", "grass", "fefam", 
                       "cappun", "courts", "fear", "gunlaw", "homosex", "abany", 
                       "natfare", "natheal")
    attitude_avail <- attitude_vars[attitude_vars %in% names(gss_all)]
    cat("Attitude variables:", paste(attitude_avail, collapse = ", "), "\n")
    
    # Sample sizes
    cat("\nSample sizes for key variables:\n")
    for (v in attitude_avail) {
      n_valid <- sum(!is.na(gss_all[[v]]))
      years_with_data <- length(unique(gss_all$year[!is.na(gss_all[[v]])]))
      cat(sprintf("  %-12s: %6d obs across %2d years\n", v, n_valid, years_with_data))
    }
    
    # Geographic info
    cat("\nGeographic variables:\n")
    if ("region" %in% names(gss_all)) {
      cat("  region: ", length(unique(na.omit(gss_all$region))), "unique values\n")
      print(table(gss_all$region, useNA = "ifany"))
    }
    
    # Save a small subset for exploration
    saveRDS(gss_all[, intersect(available, names(gss_all))], 
            file = "../data/gss_subset.rds")
    cat("\nSaved GSS subset to data/gss_subset.rds\n")
    
  }
  unlink(temp_file)
}, error = function(e) {
  cat("FAILED:", e$message, "\n")
})

cat("\n=== TESTS COMPLETE ===\n")
