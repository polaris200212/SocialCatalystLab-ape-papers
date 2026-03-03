###############################################################################
# 02_clean_data.R — Construct running variable and analysis sample
# Paper: The Price of Position (apep_0490)
###############################################################################

source("00_packages.R")

cat("=== Loading raw data ===\n")

# Load arXiv metadata
if (file.exists(file.path(DATA_DIR, "arxiv_raw_bulk.csv"))) {
  arxiv <- fread(file.path(DATA_DIR, "arxiv_raw_bulk.csv"))
  arxiv[, timestamp_utc := as.POSIXct(v1_timestamp_utc, format = "%Y-%m-%dT%H:%M:%SZ", tz = "UTC")]
} else {
  arxiv <- fread(file.path(DATA_DIR, "arxiv_raw_api.csv"))
  arxiv[, timestamp_utc := as.POSIXct(published, format = "%Y-%m-%dT%H:%M:%SZ", tz = "UTC")]
}

# Load OpenAlex data
oa <- fread(file.path(DATA_DIR, "openalex_citations.csv"))

cat(sprintf("arXiv records: %d\n", nrow(arxiv)))
cat(sprintf("OpenAlex records: %d\n", nrow(oa)))

# ============================================================================
# Step 1: Convert UTC timestamps to US Eastern Time
# ============================================================================

cat("\n=== Converting to US Eastern Time ===\n")

# arXiv cutoff is 14:00 ET (Eastern Time)
# During EDT (second Sunday March - first Sunday November): UTC-4
# During EST (first Sunday November - second Sunday March): UTC-5
# The cutoff is ALWAYS 14:00 local Eastern time

arxiv[, timestamp_et := with_tz(timestamp_utc, tzone = "America/New_York")]
arxiv[, submission_date := as.Date(timestamp_et)]
arxiv[, submission_hour := hour(timestamp_et)]
arxiv[, submission_min := minute(timestamp_et)]
arxiv[, submission_sec := second(timestamp_et)]
arxiv[, day_of_week := lubridate::wday(timestamp_et, label = TRUE)]

# Minutes since midnight ET
arxiv[, minutes_since_midnight := submission_hour * 60 + submission_min + submission_sec / 60]

# ============================================================================
# Step 2: Compute running variable (minutes from 14:00 ET cutoff)
# ============================================================================

cat("=== Computing running variable ===\n")

# Cutoff is at 14:00 ET = 840 minutes since midnight
cutoff_minutes <- 14 * 60  # = 840

# Running variable: minutes from cutoff
# Negative = before cutoff (paper goes in TODAY's announcement)
# Positive = after cutoff (paper goes in TOMORROW's announcement)
arxiv[, run_var := minutes_since_midnight - cutoff_minutes]

# Treatment indicator: submitted after cutoff
# Papers after cutoff → first in NEXT DAY's announcement
# Papers before cutoff → last in TODAY's announcement
arxiv[, after_cutoff := as.integer(run_var > 0)]

# ============================================================================
# Step 3: Determine announcement batch and expected position
# ============================================================================

cat("=== Determining announcement batches ===\n")

# arXiv announcement schedule (all times ET):
# Mon 14:00 - Tue 14:00 → announced Tue 20:00
# Tue 14:00 - Wed 14:00 → announced Wed 20:00
# Wed 14:00 - Thu 14:00 → announced Thu 20:00
# Thu 14:00 - Fri 14:00 → announced Sun 20:00
# Fri 14:00 - Mon 14:00 → announced Mon 20:00

# Announcement batch = the date whose announcement this paper appears in
# If submitted before cutoff on day D: appears in day D's announcement
# If submitted after cutoff on day D: appears in day D+1's announcement
# Weekend submissions are batched with Monday's cutoff

arxiv[, announcement_date := fifelse(
  after_cutoff == 1,
  submission_date + 1L,  # After cutoff → next day's batch
  submission_date        # Before cutoff → same day's batch
)]

# Handle weekends: move announcement dates to next business day
# Saturday → Monday, Sunday → Monday
arxiv[, ann_dow := wday(announcement_date)]
arxiv[ann_dow == 7, announcement_date := announcement_date + 2L]  # Sat → Mon
arxiv[ann_dow == 1, announcement_date := announcement_date + 1L]  # Sun → Mon

# Within each announcement batch, papers are ordered by ACTUAL submission time
# Earlier submission = earlier position (lower number = more visible)
# Must use full timestamp, not just minutes_since_midnight, because batches
# span two calendar days (D-1 14:00 through D 14:00)
arxiv[, position_in_batch := frank(as.numeric(timestamp_utc)), by = announcement_date]

# Normalize position: 1 = first listed, higher = later
# Also compute relative position (percentile within batch)
arxiv[, batch_size := .N, by = announcement_date]
arxiv[, position_pctile := position_in_batch / batch_size]

# Verify first stage: after-cutoff papers should have LOW position_pctile
# (early in next batch) and before-cutoff should have HIGH position_pctile
# (late in current batch)
cat(sprintf("Position percentile — before cutoff: %.3f, after cutoff: %.3f\n",
            mean(arxiv[after_cutoff == 0]$position_pctile, na.rm = TRUE),
            mean(arxiv[after_cutoff == 1]$position_pctile, na.rm = TRUE)))

# ============================================================================
# Step 4: Exclude weekends and compute day-of-week features
# ============================================================================

cat("=== Filtering to weekday submissions ===\n")

# Keep only weekday submissions (Mon-Fri) — weekend behavior is different
arxiv[, sub_dow := wday(submission_date)]
arxiv_weekday <- arxiv[sub_dow >= 2 & sub_dow <= 6]

cat(sprintf("Weekday submissions: %d (%.1f%% of total)\n",
            nrow(arxiv_weekday), 100 * nrow(arxiv_weekday) / nrow(arxiv)))

# Thursday submissions get 3-day front page (announced Sunday, stays until Monday)
arxiv_weekday[, thursday_sub := as.integer(sub_dow == 5)]

# ============================================================================
# Step 5: Construct pre-determined covariates for balance tests
# ============================================================================

cat("=== Constructing covariates ===\n")

# From arXiv metadata:
# 1. Number of authors (proxy for team size / resources)
if ("n_authors" %in% names(arxiv_weekday)) {
  arxiv_weekday[is.na(n_authors), n_authors := 1L]
} else {
  # Count from authors string if available
  arxiv_weekday[, n_authors := str_count(authors %||% "", ";") + 1L]
}

# 2. Abstract length (proxy for paper complexity/completeness)
if (!"abstract_length" %in% names(arxiv_weekday)) {
  arxiv_weekday[, abstract_length := nchar(title)]  # Fallback
}

# 3. Number of categories (cross-listing indicator)
arxiv_weekday[, n_categories := str_count(categories, " ") + 1L]

# 4. Has multiple versions (indicator of revision)
if ("n_versions" %in% names(arxiv_weekday)) {
  arxiv_weekday[, multi_version := as.integer(n_versions > 1)]
}

# 5. Primary category indicators
for (cat in c("cs.AI", "cs.CL", "cs.LG", "stat.ML", "cs.CV")) {
  col_name <- paste0("is_", gsub("\\.", "_", cat))
  arxiv_weekday[, (col_name) := as.integer(grepl(cat, categories))]
}

# ============================================================================
# Step 6: Merge with OpenAlex citation data
# ============================================================================

cat("=== Merging with OpenAlex ===\n")

merged <- merge(arxiv_weekday, oa, by = "arxiv_id", all.x = TRUE)

# Flag industry-affiliated papers (for industry adoption outcome)
merged[, has_industry_affil := as.integer(
  grepl(paste(INDUSTRY_LABS, collapse = "|"), affiliations, ignore.case = TRUE)
)]

# Log citations (adding 1 to handle zeros)
for (col in c("cited_by_count", "cite_1y", "cite_3y", "cite_5y")) {
  if (col %in% names(merged)) {
    merged[, paste0("ln_", col) := log(get(col) + 1)]
  }
}

# Indicator for highly cited (top 10% within year)
if ("cited_by_count" %in% names(merged)) {
  year_col <- if ("v1_year" %in% names(merged)) "v1_year" else if ("pub_year" %in% names(merged)) "pub_year" else NULL
  if (!is.null(year_col)) {
    merged[, highly_cited := as.integer(cited_by_count >= quantile(cited_by_count, 0.9, na.rm = TRUE)),
           by = get(year_col)]
  } else {
    merged[, highly_cited := as.integer(cited_by_count >= quantile(cited_by_count, 0.9, na.rm = TRUE))]
  }
}

# Indicator for published in top venue
top_venues <- c(
  "Neural Information Processing Systems",
  "NeurIPS",
  "International Conference on Machine Learning",
  "ICML",
  "International Conference on Learning Representations",
  "ICLR",
  "Association for Computational Linguistics",
  "ACL",
  "AAAI Conference on Artificial Intelligence",
  "AAAI",
  "Computer Vision and Pattern Recognition",
  "CVPR"
)

if ("venue" %in% names(merged)) {
  merged[, top_venue := as.integer(
    grepl(paste(top_venues, collapse = "|"), venue, ignore.case = TRUE)
  )]
}

# ============================================================================
# Step 7: Create analysis sample
# ============================================================================

cat("=== Creating analysis sample ===\n")

# RDD sample: papers within ±120 minutes of cutoff (wide bandwidth)
analysis <- merged[abs(run_var) <= 120]

cat(sprintf("Full weekday sample: %d papers\n", nrow(merged)))
cat(sprintf("RDD sample (±120 min): %d papers\n", nrow(analysis)))
cat(sprintf("  Before cutoff: %d\n", sum(analysis$after_cutoff == 0)))
cat(sprintf("  After cutoff: %d\n", sum(analysis$after_cutoff == 1)))

# Summary statistics
cat("\n=== Summary Statistics ===\n")
if ("cited_by_count" %in% names(analysis)) {
  cat(sprintf("Median citations: %.0f\n", median(analysis$cited_by_count, na.rm = TRUE)))
  cat(sprintf("Mean citations: %.1f\n", mean(analysis$cited_by_count, na.rm = TRUE)))
  cat(sprintf("Mean 1y citations: %.1f\n", mean(analysis$cite_1y, na.rm = TRUE)))
  cat(sprintf("Mean 3y citations: %.1f\n", mean(analysis$cite_3y, na.rm = TRUE)))
}
cat(sprintf("Mean n_authors: %.1f\n", mean(analysis$n_authors, na.rm = TRUE)))
cat(sprintf("Mean n_categories: %.1f\n", mean(analysis$n_categories, na.rm = TRUE)))

# ============================================================================
# Save analysis datasets
# ============================================================================

fwrite(merged, file.path(DATA_DIR, "full_sample.csv"))
fwrite(analysis, file.path(DATA_DIR, "rdd_sample.csv"))

cat("\n=== Data cleaning complete ===\n")
cat(sprintf("Saved full_sample.csv: %d rows\n", nrow(merged)))
cat(sprintf("Saved rdd_sample.csv: %d rows\n", nrow(analysis)))
