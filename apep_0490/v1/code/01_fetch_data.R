###############################################################################
# 01_fetch_data.R — Fetch arXiv metadata and OpenAlex citation data
# Paper: The Price of Position (apep_0490)
#
# Strategy:
# 1. Use arXiv API (Atom feed) to fetch papers by category with timestamps
# 2. Query OpenAlex for citation counts and author affiliations
###############################################################################

source("00_packages.R")
library(xml2)

cat("=== Step 1: Fetch arXiv metadata via API ===\n")

arxiv_file <- file.path(DATA_DIR, "arxiv_raw_api.csv")

if (!file.exists(arxiv_file) || file.info(arxiv_file)$size < 100) {

  # arXiv API: query by category with date ranges
  # Returns Atom XML with exact timestamps in <published> field
  # Rate limit: ~3 sec between requests

  fetch_arxiv <- function(category, start_idx = 0, max_results = 200) {
    url <- sprintf(
      "http://export.arxiv.org/api/query?search_query=cat:%s&start=%d&max_results=%d&sortBy=submittedDate&sortOrder=ascending",
      category, start_idx, max_results
    )

    resp <- tryCatch({
      request(url) |>
        req_timeout(30) |>
        req_retry(max_tries = 3, backoff = ~ 5) |>
        req_perform()
    }, error = function(e) {
      cat(sprintf("    API error: %s\n", conditionMessage(e)))
      return(NULL)
    })

    if (is.null(resp)) return(NULL)

    xml_text <- resp_body_string(resp)
    doc <- tryCatch(read_xml(xml_text), error = function(e) NULL)
    if (is.null(doc)) return(NULL)

    ns <- xml_ns(doc)
    entries <- xml_find_all(doc, ".//d1:entry", ns)

    if (length(entries) == 0) return(NULL)

    results <- lapply(entries, function(entry) {
      id_raw <- xml_text(xml_find_first(entry, ".//d1:id", ns))
      # Extract arXiv ID from URL: http://arxiv.org/abs/XXXX.XXXXX[vN]
      arxiv_id <- gsub("http://arxiv.org/abs/", "", id_raw)
      arxiv_id <- gsub("v[0-9]+$", "", arxiv_id)

      title <- xml_text(xml_find_first(entry, ".//d1:title", ns))
      title <- trimws(gsub("\\s+", " ", title))

      published <- xml_text(xml_find_first(entry, ".//d1:published", ns))
      updated <- xml_text(xml_find_first(entry, ".//d1:updated", ns))

      # Get all categories
      cat_nodes <- xml_find_all(entry, ".//arxiv:primary_category", xml_ns(doc))
      primary_cat <- if (length(cat_nodes) > 0) xml_attr(cat_nodes[1], "term") else NA

      all_cats <- xml_find_all(entry, ".//d1:category", ns)
      categories <- paste(xml_attr(all_cats, "term"), collapse = " ")

      # Count authors
      authors <- xml_find_all(entry, ".//d1:author/d1:name", ns)
      n_authors <- length(authors)
      author_names <- paste(xml_text(authors), collapse = "; ")

      # Abstract
      summary_node <- xml_find_first(entry, ".//d1:summary", ns)
      abstract <- if (!is.null(summary_node)) xml_text(summary_node) else ""
      abstract <- trimws(gsub("\\s+", " ", abstract))

      data.table(
        arxiv_id = arxiv_id,
        title = title,
        published = published,
        updated = updated,
        primary_category = primary_cat,
        categories = categories,
        n_authors = n_authors,
        authors = author_names,
        abstract_length = nchar(abstract)
      )
    })

    rbindlist(results, fill = TRUE)
  }

  # Fetch papers for each AI/ML category
  # We need papers from 2012-2020 with exact timestamps
  # arXiv API returns max 2000 per query, we paginate

  all_papers <- list()
  seen_ids <- character(0)

  for (cat in c("cs.AI", "cs.CL", "cs.LG", "stat.ML")) {
    cat(sprintf("\nFetching %s papers...\n", cat))
    start <- 0
    batch_size <- 200  # arXiv API can be slow with large batches
    cat_count <- 0
    consecutive_empty <- 0

    for (batch_num in 1:500) {  # Up to 100K papers per category
      cat(sprintf("  Batch %d (start=%d)...", batch_num, start))

      batch <- fetch_arxiv(cat, start, batch_size)

      if (is.null(batch) || nrow(batch) == 0) {
        consecutive_empty <- consecutive_empty + 1
        cat(" empty\n")
        if (consecutive_empty >= 3) break
        start <- start + batch_size
        Sys.sleep(3)
        next
      }
      consecutive_empty <- 0

      # Parse years and filter
      batch[, pub_year := as.integer(substr(published, 1, 4))]

      # Filter to 2012-2020 and deduplicate
      batch_new <- batch[pub_year >= 2012 & pub_year <= 2020 & !(arxiv_id %in% seen_ids)]
      seen_ids <- c(seen_ids, batch_new$arxiv_id)
      cat_count <- cat_count + nrow(batch_new)

      cat(sprintf(" got %d new (total: %d)\n", nrow(batch_new), cat_count))

      if (nrow(batch_new) > 0) {
        all_papers <- c(all_papers, list(batch_new))
      }

      # Check if we've gone past 2020
      max_year <- max(batch$pub_year, na.rm = TRUE)
      if (max_year > 2020) {
        cat(sprintf("  Reached %d, stopping %s\n", max_year, cat))
        break
      }

      start <- start + batch_size
      Sys.sleep(3)  # Respect rate limits

      # Target: ~2000 papers per category for a solid sample
      if (cat_count >= 2000) {
        cat(sprintf("  Reached target of %d papers for %s\n", cat_count, cat))
        break
      }
    }

    cat(sprintf("  Final count for %s: %d papers\n", cat, cat_count))
    Sys.sleep(5)
  }

  arxiv_df <- rbindlist(all_papers, fill = TRUE)
  arxiv_df <- unique(arxiv_df, by = "arxiv_id")

  cat(sprintf("\nTotal unique papers: %d\n", nrow(arxiv_df)))
  if (nrow(arxiv_df) > 0) {
    cat("Year distribution:\n")
    print(table(arxiv_df$pub_year))
  }

  fwrite(arxiv_df, arxiv_file)
  cat(sprintf("Saved to %s\n", arxiv_file))

} else {
  arxiv_df <- fread(arxiv_file)
  cat(sprintf("Loaded %d papers from cache\n", nrow(arxiv_df)))
}

# ============================================================================
# Parse timestamps
# ============================================================================

cat("\n=== Parsing timestamps ===\n")

arxiv_df[, timestamp_utc := as.POSIXct(published, format = "%Y-%m-%dT%H:%M:%SZ", tz = "UTC")]

# Remove any rows with failed timestamp parsing
n_before <- nrow(arxiv_df)
arxiv_df <- arxiv_df[!is.na(timestamp_utc)]
cat(sprintf("Valid timestamps: %d / %d\n", nrow(arxiv_df), n_before))

# Add year column
arxiv_df[, v1_year := year(timestamp_utc)]

# ============================================================================
# Step 2: Query OpenAlex for citation data
# ============================================================================

cat("\n=== Step 2: Query OpenAlex for citations ===\n")

openalex_file <- file.path(DATA_DIR, "openalex_citations.csv")

if (!file.exists(openalex_file) || file.info(openalex_file)$size < 100) {

  query_openalex <- function(arxiv_id, title_backup = NULL) {
    # Try by DOI first (arXiv DOI format)
    url <- sprintf(
      "https://api.openalex.org/works/https://doi.org/10.48550/arXiv.%s",
      arxiv_id
    )

    resp <- tryCatch({
      request(url) |>
        req_headers(`User-Agent` = "mailto:apep@research.org") |>
        req_url_query(select = "id,title,cited_by_count,publication_date,counts_by_year,authorships,primary_location,type") |>
        req_timeout(10) |>
        req_retry(max_tries = 2, backoff = ~ 1) |>
        req_perform()
    }, error = function(e) NULL)

    if (is.null(resp) || resp_status(resp) != 200) {
      # Fallback: search by title
      if (!is.null(title_backup) && nchar(title_backup) > 10) {
        search_url <- sprintf(
          "https://api.openalex.org/works?filter=title.search:%s&per_page=1",
          URLencode(substr(title_backup, 1, 150))
        )
        resp <- tryCatch({
          request(search_url) |>
            req_headers(`User-Agent` = "mailto:apep@research.org") |>
            req_url_query(select = "id,title,cited_by_count,publication_date,counts_by_year,authorships,primary_location") |>
            req_timeout(10) |>
            req_perform()
        }, error = function(e) NULL)

        if (!is.null(resp) && resp_status(resp) == 200) {
          body <- resp_body_json(resp)
          if (!is.null(body$results) && length(body$results) > 0) {
            body <- body$results[[1]]
          } else {
            return(NULL)
          }
        } else {
          return(NULL)
        }
      } else {
        return(NULL)
      }
    } else {
      body <- resp_body_json(resp)
    }

    if (is.null(body$id)) return(NULL)

    # Extract citation counts by year
    cby <- body$counts_by_year
    cite_1y <- 0; cite_3y <- 0; cite_5y <- 0
    cite_total <- body$cited_by_count %||% 0

    pub_year <- as.integer(substr(body$publication_date %||% "2000", 1, 4))
    if (!is.null(cby) && length(cby) > 0) {
      for (cy in cby) {
        diff <- cy$year - pub_year
        if (!is.null(diff) && !is.na(diff)) {
          if (diff >= 0 && diff <= 1) cite_1y <- cite_1y + (cy$cited_by_count %||% 0)
          if (diff >= 0 && diff <= 3) cite_3y <- cite_3y + (cy$cited_by_count %||% 0)
          if (diff >= 0 && diff <= 5) cite_5y <- cite_5y + (cy$cited_by_count %||% 0)
        }
      }
    }

    # Extract author affiliations
    affiliations <- character(0)
    n_oa_authors <- 0
    if (!is.null(body$authorships)) {
      n_oa_authors <- length(body$authorships)
      for (auth in body$authorships) {
        if (!is.null(auth$institutions)) {
          for (inst in auth$institutions) {
            if (!is.null(inst$display_name)) {
              affiliations <- c(affiliations, inst$display_name)
            }
          }
        }
      }
    }

    # Check venue
    venue <- NA_character_
    if (!is.null(body$primary_location) && !is.null(body$primary_location$source)) {
      venue <- body$primary_location$source$display_name %||% NA_character_
    }

    data.table(
      arxiv_id = arxiv_id,
      openalex_id = body$id,
      cited_by_count = cite_total,
      cite_1y = cite_1y,
      cite_3y = cite_3y,
      cite_5y = cite_5y,
      pub_year_oa = pub_year,
      n_oa_authors = n_oa_authors,
      affiliations = paste(unique(affiliations), collapse = "; "),
      venue = venue
    )
  }

  # Query OpenAlex for all papers
  n_total <- nrow(arxiv_df)
  cat(sprintf("Querying OpenAlex for %d papers...\n", n_total))

  oa_results <- list()
  success_count <- 0

  for (i in seq_len(n_total)) {
    result <- query_openalex(arxiv_df$arxiv_id[i], arxiv_df$title[i])

    if (!is.null(result)) {
      oa_results <- c(oa_results, list(result))
      success_count <- success_count + 1
    }

    if (i %% 50 == 0) {
      cat(sprintf("  Progress: %d/%d (%d matches, %.0f%%)\n",
                  i, n_total, success_count, 100 * success_count / i))
    }

    Sys.sleep(0.11)  # ~9 req/sec (below 10 limit)

    # Checkpoint every 500 papers
    if (i %% 500 == 0 && length(oa_results) > 0) {
      checkpoint <- rbindlist(oa_results, fill = TRUE)
      fwrite(checkpoint, file.path(DATA_DIR, "openalex_checkpoint.csv"))
    }
  }

  if (length(oa_results) > 0) {
    oa_df <- rbindlist(oa_results, fill = TRUE)
    fwrite(oa_df, openalex_file)
    cat(sprintf("\nOpenAlex data saved: %d records (%.0f%% match rate)\n",
                nrow(oa_df), 100 * nrow(oa_df) / n_total))
  } else {
    cat("WARNING: No OpenAlex matches found.\n")
    oa_df <- data.table()
    fwrite(oa_df, openalex_file)
  }

} else {
  oa_df <- fread(openalex_file)
  cat(sprintf("Loaded existing OpenAlex data: %d records\n", nrow(oa_df)))
}

cat("\n=== Data fetch complete ===\n")
cat(sprintf("arXiv papers: %d\n", nrow(arxiv_df)))
if (exists("oa_df")) cat(sprintf("OpenAlex matches: %d\n", nrow(oa_df)))
