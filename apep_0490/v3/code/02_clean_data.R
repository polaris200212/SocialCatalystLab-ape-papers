###############################################################################
# 02_clean_data.R — Construct running variable, adoption outcomes, analysis sample
# Paper: Does Visibility Delay Frontier AI? (apep_0490 v3)
###############################################################################

source("00_packages.R")

cat("=== Loading raw data ===\n")

# Load arXiv metadata
if (file.exists(file.path(DATA_DIR, "arxiv_raw_bulk.csv"))) {
  arxiv <- fread(file.path(DATA_DIR, "arxiv_raw_bulk.csv"))
  if ("v1_timestamp_utc" %in% names(arxiv)) {
    arxiv[, timestamp_utc := as.POSIXct(v1_timestamp_utc, format = "%Y-%m-%dT%H:%M:%SZ", tz = "UTC")]
  } else {
    arxiv[, timestamp_utc := as.POSIXct(published, format = "%Y-%m-%dT%H:%M:%SZ", tz = "UTC")]
  }
} else {
  arxiv <- fread(file.path(DATA_DIR, "arxiv_raw_api.csv"))
  arxiv[, timestamp_utc := as.POSIXct(published, format = "%Y-%m-%dT%H:%M:%SZ", tz = "UTC")]
}

arxiv <- arxiv[!is.na(timestamp_utc)]
arxiv[, v1_year := year(timestamp_utc)]

# Load citation sources
s2_file <- file.path(DATA_DIR, "semantic_scholar_citations.csv")
oa_file <- file.path(DATA_DIR, "openalex_citations.csv")
ind_file <- file.path(DATA_DIR, "industry_citations.csv")

has_s2 <- file.exists(s2_file) && file.info(s2_file)$size > 100
has_oa <- file.exists(oa_file) && file.info(oa_file)$size > 100
has_ind <- file.exists(ind_file) && file.info(ind_file)$size > 100

if (has_s2) s2 <- fread(s2_file)
if (has_oa) oa <- fread(oa_file)
if (has_ind) industry <- fread(ind_file)

cat(sprintf("arXiv records: %d\n", nrow(arxiv)))
if (has_s2) cat(sprintf("Semantic Scholar records: %d\n", nrow(s2)))
if (has_oa) cat(sprintf("OpenAlex records: %d\n", nrow(oa)))
if (has_ind) cat(sprintf("Industry citation records: %d\n", nrow(industry)))

# ============================================================================
# Step 1: Convert UTC timestamps to US Eastern Time
# ============================================================================

cat("\n=== Converting to US Eastern Time ===\n")

arxiv[, timestamp_et := with_tz(timestamp_utc, tzone = "America/New_York")]
arxiv[, submission_date := as.Date(timestamp_et)]
arxiv[, submission_hour := hour(timestamp_et)]
arxiv[, submission_min := minute(timestamp_et)]
arxiv[, submission_sec := second(timestamp_et)]
arxiv[, day_of_week := lubridate::wday(timestamp_et, label = TRUE)]

arxiv[, minutes_since_midnight := submission_hour * 60 + submission_min + submission_sec / 60]

# ============================================================================
# Step 2: Compute running variable (minutes from 14:00 ET cutoff)
# ============================================================================

cat("=== Computing running variable ===\n")

cutoff_minutes <- 14 * 60  # 840

# Running variable: negative = before cutoff, positive = after
arxiv[, run_var := minutes_since_midnight - cutoff_minutes]

# Treatment: submitted after cutoff → first in next batch
arxiv[, after_cutoff := as.integer(run_var > 0)]

# ============================================================================
# Step 3: Determine announcement batch and position
# ============================================================================

cat("=== Determining announcement batches ===\n")

# Announcement batch assignment
arxiv[, announcement_date := fifelse(
  after_cutoff == 1,
  submission_date + 1L,
  submission_date
)]

# Handle weekends
arxiv[, ann_dow := wday(announcement_date)]
arxiv[ann_dow == 7, announcement_date := announcement_date + 2L]  # Sat → Mon
arxiv[ann_dow == 1, announcement_date := announcement_date + 1L]  # Sun → Mon

# Position within batch (rank by submission time)
arxiv[, position_in_batch := frank(as.numeric(timestamp_utc)), by = announcement_date]
arxiv[, batch_size := .N, by = announcement_date]
arxiv[, position_pctile := position_in_batch / batch_size]

cat(sprintf("Position percentile — before cutoff: %.3f, after cutoff: %.3f\n",
            mean(arxiv[after_cutoff == 0]$position_pctile, na.rm = TRUE),
            mean(arxiv[after_cutoff == 1]$position_pctile, na.rm = TRUE)))

# ============================================================================
# Step 4: Filter to weekday submissions
# ============================================================================

cat("=== Filtering to weekday submissions ===\n")

arxiv[, sub_dow := wday(submission_date)]
arxiv_weekday <- arxiv[sub_dow >= 2 & sub_dow <= 6]

cat(sprintf("Weekday submissions: %d (%.1f%% of total)\n",
            nrow(arxiv_weekday), 100 * nrow(arxiv_weekday) / nrow(arxiv)))

# Thursday indicator (3-day front page)
arxiv_weekday[, thursday_sub := as.integer(sub_dow == 5)]

# Day-of-week indicators
arxiv_weekday[, dow_mon := as.integer(sub_dow == 2)]
arxiv_weekday[, dow_tue := as.integer(sub_dow == 3)]
arxiv_weekday[, dow_wed := as.integer(sub_dow == 4)]
arxiv_weekday[, dow_thu := as.integer(sub_dow == 5)]
arxiv_weekday[, dow_fri := as.integer(sub_dow == 6)]

# Mon-Wed vs Thu-Fri split
arxiv_weekday[, early_week := as.integer(sub_dow %in% 2:4)]

# ============================================================================
# Step 5: Construct covariates for balance tests
# ============================================================================

cat("=== Constructing covariates ===\n")

if ("n_authors" %in% names(arxiv_weekday)) {
  arxiv_weekday[is.na(n_authors), n_authors := 1L]
} else {
  arxiv_weekday[, n_authors := str_count(authors %||% "", ";") + 1L]
}

if (!"abstract_length" %in% names(arxiv_weekday)) {
  arxiv_weekday[, abstract_length := nchar(title)]
}

arxiv_weekday[, n_categories := str_count(categories, " ") + 1L]

if ("n_versions" %in% names(arxiv_weekday)) {
  arxiv_weekday[, multi_version := as.integer(n_versions > 1)]
}

# Primary category indicators
for (cat_name in c("cs.AI", "cs.CL", "cs.LG", "stat.ML", "cs.CV")) {
  col_name <- paste0("is_", gsub("\\.", "_", cat_name))
  arxiv_weekday[, (col_name) := as.integer(grepl(cat_name, categories))]
}

# ============================================================================
# Step 6: Merge citation data — best-available approach
# ============================================================================

cat("=== Merging citation data ===\n")

merged <- copy(arxiv_weekday)

# Merge Semantic Scholar data (primary citation source)
if (has_s2) {
  merged <- merge(merged, s2, by = "arxiv_id", all.x = TRUE)
  cat(sprintf("  S2 match rate: %.1f%%\n",
              100 * sum(!is.na(merged$s2_cite_total)) / nrow(merged)))
}

# Merge OpenAlex data (affiliations, venue, secondary citations)
if (has_oa) {
  merged <- merge(merged, oa, by = "arxiv_id", all.x = TRUE)
  cat(sprintf("  OA match rate: %.1f%%\n",
              100 * sum(!is.na(merged$openalex_id)) / nrow(merged)))
}

# Construct best-available citation measures
# Priority: Semantic Scholar > OpenAlex
if (has_s2 && has_oa) {
  merged[, cited_by_count := fifelse(!is.na(s2_cite_total), s2_cite_total, oa_cited_by_count)]
  merged[, cite_1y := fifelse(!is.na(s2_cite_1y), s2_cite_1y, oa_cite_1y)]
  merged[, cite_3y := fifelse(!is.na(s2_cite_3y), s2_cite_3y, oa_cite_3y)]
  merged[, cite_5y := fifelse(!is.na(s2_cite_5y), s2_cite_5y, oa_cite_5y)]
  merged[, cite_source := fifelse(!is.na(s2_cite_total), "s2", "oa")]
  merged[is.na(cited_by_count), cite_source := NA_character_]
} else if (has_s2) {
  merged[, cited_by_count := s2_cite_total]
  merged[, cite_1y := s2_cite_1y]
  merged[, cite_3y := s2_cite_3y]
  merged[, cite_5y := s2_cite_5y]
  merged[, cite_source := "s2"]
} else if (has_oa) {
  merged[, cited_by_count := oa_cited_by_count]
  merged[, cite_1y := oa_cite_1y]
  merged[, cite_3y := oa_cite_3y]
  merged[, cite_5y := oa_cite_5y]
  merged[, cite_source := "oa"]
}

# Overall match rate
n_matched <- sum(!is.na(merged$cited_by_count))
cat(sprintf("  Combined citation match rate: %d / %d (%.1f%%)\n",
            n_matched, nrow(merged), 100 * n_matched / nrow(merged)))

# ============================================================================
# Step 7: Merge industry adoption data
# ============================================================================

cat("=== Merging industry adoption data ===\n")

if (has_ind) {
  ind_cols <- c("arxiv_id", "n_industry_cites", "n_frontier_cites", "n_bigtech_cites",
                "n_other_industry_cites", "n_distinct_companies",
                "adoption_lag_days", "frontier_lag_days",
                "adopted_12m", "adopted_18m",
                "frontier_adopted_12m", "frontier_adopted_18m",
                "n_frontier_labs_18m", "total_citing_works")
  ind_cols <- ind_cols[ind_cols %in% names(industry)]
  merged <- merge(merged, industry[, ..ind_cols], by = "arxiv_id", all.x = TRUE)

  # Fill NAs with 0 for count/binary variables
  count_vars <- c("n_industry_cites", "n_frontier_cites", "n_bigtech_cites",
                   "n_other_industry_cites", "n_distinct_companies",
                   "adopted_12m", "adopted_18m",
                   "frontier_adopted_12m", "frontier_adopted_18m",
                   "n_frontier_labs_18m")
  for (cv in count_vars) {
    if (cv %in% names(merged)) merged[is.na(get(cv)), (cv) := 0L]
  }

  # Construct derived adoption outcomes
  merged[, has_industry_cite := as.integer(n_industry_cites > 0)]
  merged[, has_frontier_cite := as.integer(n_frontier_cites > 0)]
  merged[, has_bigtech_cite := as.integer(n_bigtech_cites > 0)]
  merged[, ln_industry_cites := log(n_industry_cites + 1)]
  merged[, ln_frontier_cites := log(n_frontier_cites + 1)]

  # Industry citation share
  merged[, industry_cite_share := fifelse(
    !is.na(cited_by_count) & cited_by_count > 0,
    n_industry_cites / cited_by_count, 0
  )]
  merged[, frontier_cite_share := fifelse(
    !is.na(cited_by_count) & cited_by_count > 0,
    n_frontier_cites / cited_by_count, 0
  )]

  # Log adoption lag (for papers that were adopted)
  merged[, ln_adoption_lag := log(adoption_lag_days + 1)]
  merged[adoption_lag_days < 0, ln_adoption_lag := NA_real_]  # Shouldn't happen but safeguard
  merged[, ln_frontier_lag := log(frontier_lag_days + 1)]
  merged[frontier_lag_days < 0, ln_frontier_lag := NA_real_]

  # Adoption speed: inverse of lag (higher = faster adoption)
  # Capped at 1/30 (30 days minimum meaningful lag)
  merged[, adoption_speed := fifelse(
    !is.na(adoption_lag_days) & adoption_lag_days > 0,
    1 / pmax(adoption_lag_days, 30), 0
  )]

  cat(sprintf("Papers with any industry citation: %d (%.1f%%)\n",
              sum(merged$has_industry_cite, na.rm = TRUE),
              100 * mean(merged$has_industry_cite, na.rm = TRUE)))
  cat(sprintf("Papers with frontier lab citation: %d (%.1f%%)\n",
              sum(merged$has_frontier_cite, na.rm = TRUE),
              100 * mean(merged$has_frontier_cite, na.rm = TRUE)))
  cat(sprintf("Papers adopted by frontier within 12m: %d (%.1f%%)\n",
              sum(merged$frontier_adopted_12m, na.rm = TRUE),
              100 * mean(merged$frontier_adopted_12m, na.rm = TRUE)))
  cat(sprintf("Papers adopted by frontier within 18m: %d (%.1f%%)\n",
              sum(merged$frontier_adopted_18m, na.rm = TRUE),
              100 * mean(merged$frontier_adopted_18m, na.rm = TRUE)))
  cat(sprintf("Median adoption lag (adopted papers): %.0f days\n",
              median(merged[has_industry_cite == 1]$adoption_lag_days, na.rm = TRUE)))
  cat(sprintf("Median frontier lag (frontier-adopted papers): %.0f days\n",
              median(merged[has_frontier_cite == 1]$frontier_lag_days, na.rm = TRUE)))
} else {
  cat("WARNING: industry_citations.csv not found. Adoption outcomes will be NA.\n")
  merged[, has_industry_cite := NA_integer_]
  merged[, has_frontier_cite := NA_integer_]
}

# ============================================================================
# Step 8: Log-transform citation outcomes
# ============================================================================

for (col in c("cited_by_count", "cite_1y", "cite_3y", "cite_5y")) {
  if (col %in% names(merged)) {
    merged[, paste0("ln_", col) := log(get(col) + 1)]
  }
}

# Highly cited indicator (top 10% within year)
if ("cited_by_count" %in% names(merged)) {
  year_col <- if ("v1_year" %in% names(merged)) "v1_year" else NULL
  if (!is.null(year_col)) {
    merged[, highly_cited := as.integer(cited_by_count >= quantile(cited_by_count, 0.9, na.rm = TRUE)),
           by = get(year_col)]
  } else {
    merged[, highly_cited := as.integer(cited_by_count >= quantile(cited_by_count, 0.9, na.rm = TRUE))]
  }
}

# Top venue indicator
top_venues <- c(
  "Neural Information Processing Systems", "NeurIPS",
  "International Conference on Machine Learning", "ICML",
  "International Conference on Learning Representations", "ICLR",
  "Association for Computational Linguistics", "ACL",
  "AAAI Conference on Artificial Intelligence", "AAAI",
  "Computer Vision and Pattern Recognition", "CVPR"
)

# Check both S2 venue and OA venue
if ("s2_venue" %in% names(merged) || "venue" %in% names(merged)) {
  merged[, top_venue := 0L]
  if ("s2_venue" %in% names(merged)) {
    merged[grepl(paste(top_venues, collapse = "|"), s2_venue, ignore.case = TRUE),
           top_venue := 1L]
  }
  if ("venue" %in% names(merged)) {
    merged[grepl(paste(top_venues, collapse = "|"), venue, ignore.case = TRUE),
           top_venue := 1L]
  }
}

# ============================================================================
# Step 9: Batch size validation
# ============================================================================

cat("\n=== Batch size validation ===\n")

batch_stats <- merged[, .(
  n_papers = .N,
  n_categories = length(unique(primary_category))
), by = announcement_date]

cat(sprintf("Unique announcement dates: %d\n", nrow(batch_stats)))
cat(sprintf("Batch size — mean: %.0f, median: %.0f, min: %d, max: %d\n",
            mean(batch_stats$n_papers), median(batch_stats$n_papers),
            min(batch_stats$n_papers), max(batch_stats$n_papers)))

# Flag suspiciously small batches
small_batches <- batch_stats[n_papers < 5]
if (nrow(small_batches) > 0) {
  cat(sprintf("WARNING: %d batches with <5 papers (may be holidays/weekends)\n",
              nrow(small_batches)))
}

# ============================================================================
# Step 10: Create analysis samples
# ============================================================================

cat("\n=== Creating analysis samples ===\n")

# Full sample: all weekday papers with citation data
full_sample <- merged[!is.na(cited_by_count)]

# RDD sample: within ±120 minutes of cutoff
rdd_sample <- full_sample[abs(run_var) <= 120]

cat(sprintf("Full weekday sample (with citations): %d papers\n", nrow(full_sample)))
cat(sprintf("RDD sample (±120 min): %d papers\n", nrow(rdd_sample)))
cat(sprintf("  Before cutoff: %d\n", sum(rdd_sample$after_cutoff == 0)))
cat(sprintf("  After cutoff: %d\n", sum(rdd_sample$after_cutoff == 1)))

# Year distribution in RDD sample
cat("\nRDD sample year distribution:\n")
print(table(rdd_sample$v1_year))

# Citation summary
cat("\n=== Summary Statistics ===\n")
cat(sprintf("Median citations: %.0f\n", median(rdd_sample$cited_by_count, na.rm = TRUE)))
cat(sprintf("Mean citations: %.1f\n", mean(rdd_sample$cited_by_count, na.rm = TRUE)))
cat(sprintf("Mean 1y citations: %.1f\n", mean(rdd_sample$cite_1y, na.rm = TRUE)))
cat(sprintf("Mean 3y citations: %.1f\n", mean(rdd_sample$cite_3y, na.rm = TRUE)))
cat(sprintf("Mean n_authors: %.1f\n", mean(rdd_sample$n_authors, na.rm = TRUE)))
cat(sprintf("Mean batch_size: %.0f\n", mean(rdd_sample$batch_size, na.rm = TRUE)))

if ("has_frontier_cite" %in% names(rdd_sample)) {
  cat(sprintf("\nFrontier adoption rate: %.1f%%\n",
              100 * mean(rdd_sample$has_frontier_cite, na.rm = TRUE)))
  cat(sprintf("Industry adoption rate: %.1f%%\n",
              100 * mean(rdd_sample$has_industry_cite, na.rm = TRUE)))
  cat(sprintf("Adopted within 12m (frontier): %.1f%%\n",
              100 * mean(rdd_sample$frontier_adopted_12m, na.rm = TRUE)))
  cat(sprintf("Adopted within 18m (frontier): %.1f%%\n",
              100 * mean(rdd_sample$frontier_adopted_18m, na.rm = TRUE)))
}

# ============================================================================
# Save
# ============================================================================

fwrite(full_sample, file.path(DATA_DIR, "full_sample.csv"))
fwrite(rdd_sample, file.path(DATA_DIR, "rdd_sample.csv"))

# Also save the full merged dataset (including papers without citations)
fwrite(merged, file.path(DATA_DIR, "merged_all.csv"))

cat("\n=== Data cleaning complete ===\n")
cat(sprintf("Saved full_sample.csv: %d rows\n", nrow(full_sample)))
cat(sprintf("Saved rdd_sample.csv: %d rows\n", nrow(rdd_sample)))
