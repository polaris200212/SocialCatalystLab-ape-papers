# Download CES cumulative RDS (37.8 MB)
ces_rds_url <- "https://dataverse.harvard.edu/api/access/datafile/12134963"
dest <- "../data/ces_cumulative.rds"
cat("Downloading CES cumulative data (37.8 MB)...\n")
download.file(ces_rds_url, dest, mode = "wb", quiet = FALSE)
cat("Download complete. File size:", file.size(dest) / 1024 / 1024, "MB\n")

# Load and explore
cat("\nLoading CES data...\n")
ces <- readRDS(dest)
cat("Rows:", nrow(ces), "\n")
cat("Cols:", ncol(ces), "\n")
cat("Years:", paste(sort(unique(ces$year)), collapse = ", "), "\n")
cat("Respondents per year:\n")
print(table(ces$year))

# Check key variables
cat("\n=== Key Variable Check ===\n")
# Economic perception variables
econ_vars <- grep("econ|economy|job|employ|income|finan", names(ces), value = TRUE, ignore.case = TRUE)
cat("Economic variables:", paste(head(econ_vars, 20), collapse = ", "), "\n")

# State identifier
if ("inputstate" %in% names(ces)) {
  cat("\nState identifier present: YES\n")
  cat("Number of states:", length(unique(ces$inputstate)), "\n")
}

# Key demographics
demo_check <- c("gender", "educ", "race", "faminc", "employ", "pid3", "pid7", "ideo5", "inputstate", "birthyr", "marstat")
for (v in demo_check) {
  if (v %in% names(ces)) {
    n_valid <- sum(!is.na(ces[[v]]))
    cat(sprintf("  %-15s: %7d valid (%4.1f%%)\n", v, n_valid, 100*n_valid/nrow(ces)))
  } else {
    cat(sprintf("  %-15s: NOT FOUND\n", v))
  }
}

# Policy attitude variables 
cat("\n=== Policy Attitude Variables ===\n")
policy_vars <- grep("CC\\d+_3|abort|gun|immig|envi|health|marry|milit|trade|min_wage|marijuana", 
                     names(ces), value = TRUE, ignore.case = TRUE)
cat("Found", length(policy_vars), "potential policy attitude variables\n")
cat("Sample:", paste(head(policy_vars, 30), collapse = ", "), "\n")

# Economic perception - look for approval/economy rating
approve_vars <- grep("approv|econ|economy", names(ces), value = TRUE, ignore.case = TRUE)
cat("\nEconomic/approval variables:", paste(approve_vars, collapse = ", "), "\n")
for (v in approve_vars) {
  n_valid <- sum(!is.na(ces[[v]]))
  cat(sprintf("  %s: %d valid obs\n", v, n_valid))
}
