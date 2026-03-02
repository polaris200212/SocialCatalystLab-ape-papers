library(jsonlite)

# Try to find correct CES dataset on Dataverse
cat("=== Finding CES datasets ===\n")
search_url <- "https://dataverse.harvard.edu/api/search?q=%22cooperative+congressional+election+study%22&type=dataset&per_page=10"
result <- fromJSON(search_url)
for (i in 1:min(10, length(result$data$items$name))) {
  cat(sprintf("%d. %s\n   DOI: %s\n", i, result$data$items$name[i], result$data$items$global_id[i]))
}

# Also try "cooperative election study" (the name changed)
cat("\n=== Also searching 'cooperative election study' ===\n")
search_url2 <- "https://dataverse.harvard.edu/api/search?q=%22cooperative+election+study%22+2022&type=dataset&per_page=5"
result2 <- fromJSON(search_url2)
for (i in 1:min(5, length(result2$data$items$name))) {
  cat(sprintf("%d. %s\n   DOI: %s\n", i, result2$data$items$name[i], result2$data$items$global_id[i]))
}

# Try to get GSS via direct NORC download
cat("\n=== Testing GSS via NORC ===\n")
# The GSS is also available through IPUMS
# Let's try the NORC website download link
# Actually, let's try a different approach: use the foreign package to read SPSS
# Or just test if we can fetch from gss.norc.org

# Check R version for package compatibility
cat("R version:", R.version.string, "\n")

# Try installing gssr from GitHub
tryCatch({
  if (!require(remotes, quietly = TRUE)) {
    install.packages("remotes", repos = "https://cloud.r-project.org", quiet = TRUE)
  }
  cat("Attempting to install gssr from GitHub...\n")
  remotes::install_github("kjhealy/gssr", quiet = TRUE, upgrade = "never")
  library(gssr)
  data(gss_all)
  cat("SUCCESS: GSS data loaded\n")
  cat("Rows:", nrow(gss_all), "Cols:", ncol(gss_all), "\n")
}, error = function(e) {
  cat("GitHub install failed:", e$message, "\n")
  cat("Will try alternative GSS access...\n")
})
