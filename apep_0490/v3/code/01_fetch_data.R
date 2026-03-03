###############################################################################
# 01_fetch_data.R — Fetch arXiv metadata + citation data (FULL POPULATION)
# Paper: Does Visibility Delay Frontier AI? (apep_0490 v3)
#
# Strategy:
# 1. arXiv API with month-by-month date windows — NO CAP per category
# 2. Semantic Scholar API (primary citation source, high arXiv coverage)
# 3. OpenAlex API (secondary, for affiliation data)
# 4. Industry citing-work analysis for adoption lag measurement
#
# Target: full population of AI/ML papers 2012-2024 (~200K+)
###############################################################################

source("00_packages.R")
library(xml2)

# ============================================================================
# Step 1: Fetch arXiv metadata — full population via date-windowed queries
# ============================================================================

cat("=== Step 1: Fetch arXiv metadata (full population) ===\n")

arxiv_file <- file.path(DATA_DIR, "arxiv_raw_bulk.csv")

if (!file.exists(arxiv_file) || file.info(arxiv_file)$size < 100) {

  fetch_arxiv_batch <- function(category, start_idx = 0, max_results = 200,
                                 date_from = NULL, date_to = NULL) {
    # Build query with date range
    query <- sprintf("cat:%s", category)
    if (!is.null(date_from) && !is.null(date_to)) {
      # arXiv API submittedDate filter: YYYYMMDDHHMM format
      query <- sprintf("cat:%s+AND+submittedDate:[%s+TO+%s]",
                        category, date_from, date_to)
    }

    url <- sprintf(
      "http://export.arxiv.org/api/query?search_query=%s&start=%d&max_results=%d&sortBy=submittedDate&sortOrder=ascending",
      query, start_idx, max_results
    )

    resp <- tryCatch({
      request(url) |>
        req_timeout(60) |>
        req_retry(max_tries = 5, backoff = ~ 5) |>
        req_perform()
    }, error = function(e) {
      cat(sprintf("    API error: %s\n", conditionMessage(e)))
      return(NULL)
    })

    if (is.null(resp)) return(NULL)

    xml_text_content <- resp_body_string(resp)
    doc <- tryCatch(read_xml(xml_text_content), error = function(e) NULL)
    if (is.null(doc)) return(NULL)

    ns <- xml_ns(doc)

    # Check total results from opensearch
    total_node <- xml_find_first(doc, ".//opensearch:totalResults",
                                  c(opensearch = "http://a9.com/-/spec/opensearch/1.1/"))
    total_results <- if (!is.null(total_node)) as.integer(xml_text(total_node)) else 0L

    entries <- xml_find_all(doc, ".//d1:entry", ns)
    if (length(entries) == 0) return(list(data = NULL, total = total_results))

    results <- lapply(entries, function(entry) {
      id_raw <- xml_text(xml_find_first(entry, ".//d1:id", ns))
      arxiv_id <- gsub("http://arxiv.org/abs/", "", id_raw)
      arxiv_id <- gsub("v[0-9]+$", "", arxiv_id)

      title <- xml_text(xml_find_first(entry, ".//d1:title", ns))
      title <- trimws(gsub("\\s+", " ", title))

      published <- xml_text(xml_find_first(entry, ".//d1:published", ns))
      updated <- xml_text(xml_find_first(entry, ".//d1:updated", ns))

      cat_nodes <- xml_find_all(entry, ".//arxiv:primary_category", xml_ns(doc))
      primary_cat <- if (length(cat_nodes) > 0) xml_attr(cat_nodes[1], "term") else NA

      all_cats <- xml_find_all(entry, ".//d1:category", ns)
      categories <- paste(xml_attr(all_cats, "term"), collapse = " ")

      authors <- xml_find_all(entry, ".//d1:author/d1:name", ns)
      n_authors <- length(authors)
      author_names <- paste(xml_text(authors), collapse = "; ")

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

    list(data = rbindlist(results, fill = TRUE), total = total_results)
  }

  # Generate month-by-month date windows from 2012 to 2024
  generate_windows <- function(year_start, year_end) {
    windows <- list()
    for (yr in year_start:year_end) {
      for (mo in 1:12) {
        from_str <- sprintf("%04d%02d01000000", yr, mo)
        # End of month
        if (mo == 12) {
          to_str <- sprintf("%04d%02d31235959", yr, mo)
        } else {
          # Last day of month
          last_day <- as.integer(format(as.Date(sprintf("%04d-%02d-01", yr, mo + 1)) - 1, "%d"))
          to_str <- sprintf("%04d%02d%02d235959", yr, mo, last_day)
        }
        windows <- c(windows, list(list(from = from_str, to = to_str,
                                         label = sprintf("%04d-%02d", yr, mo))))
      }
    }
    windows
  }

  windows <- generate_windows(YEAR_START, YEAR_END)

  all_papers <- list()
  seen_ids <- character(0)
  total_fetched <- 0L
  checkpoint_file <- file.path(DATA_DIR, "arxiv_checkpoint.csv")

  # Resume from checkpoint if available
  if (file.exists(checkpoint_file) && file.info(checkpoint_file)$size > 100) {
    checkpoint <- fread(checkpoint_file)
    all_papers <- list(checkpoint)
    seen_ids <- checkpoint$arxiv_id
    total_fetched <- nrow(checkpoint)
    cat(sprintf("Resumed from checkpoint: %d papers\n", total_fetched))
  }

  for (cat_name in AI_CATEGORIES) {
    cat(sprintf("\n=== Fetching %s ===\n", cat_name))
    cat_total <- 0L

    for (win in windows) {
      start_idx <- 0L
      batch_size <- 200L
      window_count <- 0L

      repeat {
        result <- fetch_arxiv_batch(cat_name, start_idx, batch_size,
                                     win$from, win$to)

        if (is.null(result) || is.null(result$data) || nrow(result$data) == 0) {
          break
        }

        batch <- result$data
        batch[, pub_year := as.integer(substr(published, 1, 4))]

        # Deduplicate against already-seen IDs
        new_rows <- batch[!(arxiv_id %in% seen_ids)]
        if (nrow(new_rows) > 0) {
          all_papers <- c(all_papers, list(new_rows))
          seen_ids <- c(seen_ids, new_rows$arxiv_id)
          window_count <- window_count + nrow(new_rows)
          cat_total <- cat_total + nrow(new_rows)
          total_fetched <- total_fetched + nrow(new_rows)
        }

        # If we got fewer results than batch_size, we've exhausted this window
        if (nrow(batch) < batch_size) break

        # If total_results indicates more, paginate
        if (!is.null(result$total) && start_idx + batch_size >= result$total) break

        start_idx <- start_idx + batch_size
        Sys.sleep(3)  # Respect rate limits
      }

      if (window_count > 0) {
        cat(sprintf("  %s %s: +%d papers (cumulative: %d)\n",
                    cat_name, win$label, window_count, cat_total))
      }

      Sys.sleep(3)
    }

    cat(sprintf("  %s total: %d papers\n", cat_name, cat_total))

    # Checkpoint after each category
    if (length(all_papers) > 0) {
      checkpoint_dt <- rbindlist(all_papers, fill = TRUE)
      checkpoint_dt <- unique(checkpoint_dt, by = "arxiv_id")
      fwrite(checkpoint_dt, checkpoint_file)
      cat(sprintf("  Checkpoint saved: %d total papers\n", nrow(checkpoint_dt)))
    }

    Sys.sleep(5)
  }

  arxiv_df <- rbindlist(all_papers, fill = TRUE)
  arxiv_df <- unique(arxiv_df, by = "arxiv_id")

  cat(sprintf("\nTotal unique papers: %d\n", nrow(arxiv_df)))
  if (nrow(arxiv_df) > 0) {
    cat("Year distribution:\n")
    print(table(arxiv_df$pub_year))
    cat("\nCategory distribution (primary):\n")
    print(table(arxiv_df$primary_category))
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

# Handle both timestamp formats
if ("v1_timestamp_utc" %in% names(arxiv_df)) {
  arxiv_df[, timestamp_utc := as.POSIXct(v1_timestamp_utc, format = "%Y-%m-%dT%H:%M:%SZ", tz = "UTC")]
} else {
  arxiv_df[, timestamp_utc := as.POSIXct(published, format = "%Y-%m-%dT%H:%M:%SZ", tz = "UTC")]
}

n_before <- nrow(arxiv_df)
arxiv_df <- arxiv_df[!is.na(timestamp_utc)]
cat(sprintf("Valid timestamps: %d / %d\n", nrow(arxiv_df), n_before))

arxiv_df[, v1_year := year(timestamp_utc)]

# ============================================================================
# Step 2: Query Semantic Scholar for citation data (primary source)
# ============================================================================

cat("\n=== Step 2: Query Semantic Scholar for citations ===\n")

s2_file <- file.path(DATA_DIR, "semantic_scholar_citations.csv")

if (!file.exists(s2_file) || file.info(s2_file)$size < 100) {

  query_s2 <- function(arxiv_id) {
    # Semantic Scholar has native arXiv ID lookup
    url <- sprintf("https://api.semanticscholar.org/graph/v1/paper/ARXIV:%s", arxiv_id)

    resp <- tryCatch({
      request(url) |>
        req_url_query(fields = "citationCount,citations.year,citations.authors,influentialCitationCount,year,venue,publicationDate") |>
        req_timeout(15) |>
        req_retry(max_tries = 3, backoff = ~ 3) |>
        req_perform()
    }, error = function(e) NULL)

    if (is.null(resp) || resp_status(resp) != 200) return(NULL)

    body <- tryCatch(resp_body_json(resp), error = function(e) NULL)
    if (is.null(body)) return(NULL)

    cite_total <- body$citationCount %||% 0L
    influential <- body$influentialCitationCount %||% 0L
    pub_year <- body$year %||% NA_integer_
    venue <- body$venue %||% NA_character_
    pub_date <- body$publicationDate %||% NA_character_

    # Process citations for industry affiliation detection
    n_frontier <- 0L
    n_bigtech <- 0L
    n_other_industry <- 0L
    frontier_companies <- character(0)
    bigtech_companies <- character(0)
    first_frontier_date <- NA_character_
    first_industry_date <- NA_character_
    cite_1y <- 0L; cite_3y <- 0L; cite_5y <- 0L

    if (!is.null(body$citations) && length(body$citations) > 0) {
      for (citing in body$citations) {
        cite_year <- citing$year %||% NA_integer_

        # Count by horizon
        if (!is.na(cite_year) && !is.na(pub_year)) {
          diff <- cite_year - pub_year
          if (diff >= 0 && diff <= 1) cite_1y <- cite_1y + 1L
          if (diff >= 0 && diff <= 3) cite_3y <- cite_3y + 1L
          if (diff >= 0 && diff <= 5) cite_5y <- cite_5y + 1L
        }

        # Check industry affiliations
        if (!is.null(citing$authors)) {
          for (auth in citing$authors) {
            # S2 author names sometimes include affiliations in the name field
            # But the graph API doesn't always return institution data
            # We'll supplement with OpenAlex for affiliations
          }
        }
      }
    }

    data.table(
      arxiv_id = arxiv_id,
      s2_cite_total = cite_total,
      s2_influential = influential,
      s2_cite_1y = cite_1y,
      s2_cite_3y = cite_3y,
      s2_cite_5y = cite_5y,
      s2_pub_year = pub_year,
      s2_venue = venue,
      s2_pub_date = pub_date
    )
  }

  n_total <- nrow(arxiv_df)
  cat(sprintf("Querying Semantic Scholar for %d papers...\n", n_total))

  s2_results <- list()
  success_count <- 0L
  s2_checkpoint <- file.path(DATA_DIR, "s2_checkpoint.csv")

  # Resume from checkpoint
  start_i <- 1L
  if (file.exists(s2_checkpoint) && file.info(s2_checkpoint)$size > 100) {
    prev <- fread(s2_checkpoint)
    s2_results <- list(prev)
    success_count <- nrow(prev)
    # Find where to resume
    done_ids <- prev$arxiv_id
    start_i <- which(!(arxiv_df$arxiv_id %in% done_ids))[1]
    if (is.na(start_i)) start_i <- n_total + 1L
    cat(sprintf("  Resuming from paper %d (have %d matches)\n", start_i, success_count))
  }

  for (i in seq(start_i, n_total)) {
    result <- query_s2(arxiv_df$arxiv_id[i])

    if (!is.null(result)) {
      s2_results <- c(s2_results, list(result))
      success_count <- success_count + 1L
    }

    if (i %% 100 == 0) {
      cat(sprintf("  Progress: %d/%d (%d matches, %.0f%%)\n",
                  i, n_total, success_count, 100 * success_count / i))
    }

    # S2 rate limit: 100 requests per 5 minutes without API key
    Sys.sleep(3)

    # Checkpoint every 1000
    if (i %% 1000 == 0 && length(s2_results) > 0) {
      s2_cp <- rbindlist(s2_results, fill = TRUE)
      fwrite(s2_cp, s2_checkpoint)
      cat(sprintf("  Checkpoint: %d records\n", nrow(s2_cp)))
    }
  }

  if (length(s2_results) > 0) {
    s2_df <- rbindlist(s2_results, fill = TRUE)
    s2_df <- unique(s2_df, by = "arxiv_id")
    fwrite(s2_df, s2_file)
    cat(sprintf("\nSemantic Scholar data saved: %d records (%.0f%% match rate)\n",
                nrow(s2_df), 100 * nrow(s2_df) / n_total))
  } else {
    cat("WARNING: No Semantic Scholar matches found.\n")
    s2_df <- data.table()
    fwrite(s2_df, s2_file)
  }

} else {
  s2_df <- fread(s2_file)
  cat(sprintf("Loaded existing Semantic Scholar data: %d records\n", nrow(s2_df)))
}

# ============================================================================
# Step 3: Query OpenAlex for affiliation + citing works data
# ============================================================================

cat("\n=== Step 3: Query OpenAlex for affiliations and citing works ===\n")

openalex_file <- file.path(DATA_DIR, "openalex_citations.csv")

if (!file.exists(openalex_file) || file.info(openalex_file)$size < 100) {

  query_openalex <- function(arxiv_id, title_backup = NULL) {
    # Try arXiv DOI first
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

    body <- NULL
    match_method <- "doi"

    if (is.null(resp) || resp_status(resp) != 200) {
      # Fallback: search by title
      if (!is.null(title_backup) && nchar(title_backup) > 15) {
        search_url <- "https://api.openalex.org/works"
        resp <- tryCatch({
          request(search_url) |>
            req_headers(`User-Agent` = "mailto:apep@research.org") |>
            req_url_query(
              filter = sprintf("title.search:%s", substr(title_backup, 1, 200)),
              per_page = 3,
              select = "id,title,cited_by_count,publication_date,counts_by_year,authorships,primary_location"
            ) |>
            req_timeout(10) |>
            req_perform()
        }, error = function(e) NULL)

        if (!is.null(resp) && resp_status(resp) == 200) {
          resp_body <- resp_body_json(resp)
          if (!is.null(resp_body$results) && length(resp_body$results) > 0) {
            # Match on title similarity
            for (candidate in resp_body$results) {
              if (!is.null(candidate$title)) {
                # Simple title matching: case-insensitive exact match
                if (tolower(trimws(candidate$title)) == tolower(trimws(title_backup))) {
                  body <- candidate
                  match_method <- "title_exact"
                  break
                }
              }
            }
            # If no exact match, take first result if title is very similar
            if (is.null(body) && length(resp_body$results) > 0) {
              first_title <- tolower(trimws(resp_body$results[[1]]$title %||% ""))
              query_title <- tolower(trimws(title_backup))
              # Jaccard-like similarity on words
              words_a <- unique(strsplit(first_title, "\\s+")[[1]])
              words_b <- unique(strsplit(query_title, "\\s+")[[1]])
              overlap <- length(intersect(words_a, words_b))
              union_size <- length(union(words_a, words_b))
              if (union_size > 0 && overlap / union_size > 0.7) {
                body <- resp_body$results[[1]]
                match_method <- "title_fuzzy"
              }
            }
          }
        }
      }
      if (is.null(body)) return(NULL)
    } else {
      body <- resp_body_json(resp)
    }

    if (is.null(body$id)) return(NULL)

    # Citation counts by year
    cby <- body$counts_by_year
    cite_1y <- 0L; cite_3y <- 0L; cite_5y <- 0L
    cite_total <- body$cited_by_count %||% 0L
    pub_year <- as.integer(substr(body$publication_date %||% "2000", 1, 4))

    if (!is.null(cby) && length(cby) > 0) {
      for (cy in cby) {
        diff <- cy$year - pub_year
        if (!is.null(diff) && !is.na(diff)) {
          if (diff >= 0 && diff <= 1) cite_1y <- cite_1y + (cy$cited_by_count %||% 0L)
          if (diff >= 0 && diff <= 3) cite_3y <- cite_3y + (cy$cited_by_count %||% 0L)
          if (diff >= 0 && diff <= 5) cite_5y <- cite_5y + (cy$cited_by_count %||% 0L)
        }
      }
    }

    # Extract author affiliations
    affiliations <- character(0)
    n_oa_authors <- 0L
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

    venue <- NA_character_
    if (!is.null(body$primary_location) && !is.null(body$primary_location$source)) {
      venue <- body$primary_location$source$display_name %||% NA_character_
    }

    data.table(
      arxiv_id = arxiv_id,
      openalex_id = body$id,
      oa_cited_by_count = cite_total,
      oa_cite_1y = cite_1y,
      oa_cite_3y = cite_3y,
      oa_cite_5y = cite_5y,
      pub_year_oa = pub_year,
      n_oa_authors = n_oa_authors,
      affiliations = paste(unique(affiliations), collapse = "; "),
      venue = venue,
      match_method = match_method
    )
  }

  n_total <- nrow(arxiv_df)
  cat(sprintf("Querying OpenAlex for %d papers...\n", n_total))

  oa_results <- list()
  success_count <- 0L
  oa_checkpoint <- file.path(DATA_DIR, "openalex_checkpoint.csv")

  start_i <- 1L
  if (file.exists(oa_checkpoint) && file.info(oa_checkpoint)$size > 100) {
    prev <- fread(oa_checkpoint)
    oa_results <- list(prev)
    success_count <- nrow(prev)
    done_ids <- prev$arxiv_id
    start_i <- which(!(arxiv_df$arxiv_id %in% done_ids))[1]
    if (is.na(start_i)) start_i <- n_total + 1L
    cat(sprintf("  Resuming from paper %d (have %d matches)\n", start_i, success_count))
  }

  for (i in seq(start_i, n_total)) {
    result <- query_openalex(arxiv_df$arxiv_id[i], arxiv_df$title[i])

    if (!is.null(result)) {
      oa_results <- c(oa_results, list(result))
      success_count <- success_count + 1L
    }

    if (i %% 100 == 0) {
      cat(sprintf("  Progress: %d/%d (%d matches, %.0f%%)\n",
                  i, n_total, success_count, 100 * success_count / i))
    }

    Sys.sleep(0.11)  # ~9 req/sec

    if (i %% 1000 == 0 && length(oa_results) > 0) {
      oa_cp <- rbindlist(oa_results, fill = TRUE)
      fwrite(oa_cp, oa_checkpoint)
    }
  }

  if (length(oa_results) > 0) {
    oa_df <- rbindlist(oa_results, fill = TRUE)
    oa_df <- unique(oa_df, by = "arxiv_id")
    fwrite(oa_df, openalex_file)
    cat(sprintf("\nOpenAlex data saved: %d records (%.0f%% match rate)\n",
                nrow(oa_df), 100 * nrow(oa_df) / n_total))
    cat("Match method breakdown:\n")
    print(table(oa_df$match_method))
  } else {
    cat("WARNING: No OpenAlex matches found.\n")
    oa_df <- data.table()
    fwrite(oa_df, openalex_file)
  }

} else {
  oa_df <- fread(openalex_file)
  cat(sprintf("Loaded existing OpenAlex data: %d records\n", nrow(oa_df)))
}

# ============================================================================
# Step 4: Query citing works for industry adoption data
# ============================================================================

cat("\n=== Step 4: Industry adoption from citing works ===\n")

industry_file <- file.path(DATA_DIR, "industry_citations.csv")

if (!file.exists(industry_file) || file.info(industry_file)$size < 100) {

  query_citing_works <- function(openalex_id, pub_date_str) {
    work_id <- gsub("https://openalex.org/", "", openalex_id)

    # Fetch all citing works with authorship data
    url <- sprintf(
      "https://api.openalex.org/works?filter=cites:%s&per_page=200&select=id,publication_date,authorships",
      work_id
    )

    resp <- tryCatch({
      request(url) |>
        req_headers(`User-Agent` = "mailto:apep@research.org") |>
        req_timeout(15) |>
        req_retry(max_tries = 3, backoff = ~ 2) |>
        req_perform()
    }, error = function(e) NULL)

    if (is.null(resp) || resp_status(resp) != 200) return(NULL)

    body <- resp_body_json(resp)
    if (is.null(body$results) || length(body$results) == 0) return(NULL)

    pub_date <- as.Date(pub_date_str)
    total_count <- body$meta$count %||% length(body$results)

    # Track all industry citations with dates
    industry_events <- list()  # list of data.tables with date + company + tier
    n_total_citing <- 0L

    process_citing_batch <- function(results_list) {
      for (citing in results_list) {
        n_total_citing <<- n_total_citing + 1L
        cite_date <- tryCatch(as.Date(citing$publication_date), error = function(e) NA)

        if (!is.null(citing$authorships)) {
          for (auth in citing$authorships) {
            if (!is.null(auth$institutions)) {
              for (inst in auth$institutions) {
                inst_name <- inst$display_name %||% ""
                for (lab in INDUSTRY_LABS) {
                  if (grepl(lab, inst_name, ignore.case = TRUE)) {
                    tier <- INDUSTRY_TIER_MAP[lab]
                    industry_events[[length(industry_events) + 1L]] <<- data.table(
                      cite_date = cite_date,
                      company = lab,
                      tier = tier
                    )
                    break  # One match per institution is enough
                  }
                }
              }
            }
          }
        }
      }
    }

    # Process first page
    process_citing_batch(body$results)

    # Paginate through remaining pages
    if (total_count > 200) {
      cursor <- body$meta$next_cursor %||% NULL
      pages <- 1L
      while (!is.null(cursor) && pages < 25) {
        next_url <- sprintf(
          "https://api.openalex.org/works?filter=cites:%s&per_page=200&cursor=%s&select=id,publication_date,authorships",
          work_id, cursor
        )
        resp2 <- tryCatch({
          request(next_url) |>
            req_headers(`User-Agent` = "mailto:apep@research.org") |>
            req_timeout(15) |>
            req_retry(max_tries = 2, backoff = ~ 2) |>
            req_perform()
        }, error = function(e) NULL)

        if (is.null(resp2) || resp_status(resp2) != 200) break
        body2 <- resp_body_json(resp2)
        if (is.null(body2$results) || length(body2$results) == 0) break

        process_citing_batch(body2$results)

        cursor <- body2$meta$next_cursor %||% NULL
        pages <- pages + 1L
        Sys.sleep(0.11)
      }
    }

    if (length(industry_events) == 0) {
      return(data.table(
        openalex_id = openalex_id,
        n_industry_cites = 0L,
        n_frontier_cites = 0L,
        n_bigtech_cites = 0L,
        n_other_industry_cites = 0L,
        n_distinct_companies = 0L,
        first_industry_date = NA_character_,
        first_frontier_date = NA_character_,
        adoption_lag_days = NA_real_,
        frontier_lag_days = NA_real_,
        adopted_12m = 0L,
        adopted_18m = 0L,
        frontier_adopted_12m = 0L,
        frontier_adopted_18m = 0L,
        n_frontier_labs_18m = 0L,
        companies_list = "",
        total_citing_works = n_total_citing
      ))
    }

    events_dt <- rbindlist(industry_events, fill = TRUE)

    # Compute adoption metrics
    n_frontier <- sum(events_dt$tier == "frontier")
    n_bigtech <- sum(events_dt$tier == "bigtech")
    n_other <- sum(events_dt$tier == "other")
    distinct_companies <- unique(events_dt$company)

    first_industry <- min(events_dt$cite_date, na.rm = TRUE)
    frontier_events <- events_dt[tier == "frontier"]
    first_frontier <- if (nrow(frontier_events) > 0) min(frontier_events$cite_date, na.rm = TRUE) else NA

    adoption_lag <- if (!is.na(first_industry) && !is.na(pub_date)) {
      as.numeric(difftime(first_industry, pub_date, units = "days"))
    } else NA_real_

    frontier_lag <- if (!is.na(first_frontier) && !is.na(pub_date)) {
      as.numeric(difftime(first_frontier, pub_date, units = "days"))
    } else NA_real_

    # Binary adoption within windows
    adopted_12m <- as.integer(!is.na(adoption_lag) && adoption_lag <= 365)
    adopted_18m <- as.integer(!is.na(adoption_lag) && adoption_lag <= 548)
    frontier_12m <- as.integer(!is.na(frontier_lag) && frontier_lag <= 365)
    frontier_18m <- as.integer(!is.na(frontier_lag) && frontier_lag <= 548)

    # Count distinct frontier labs citing within 18 months
    if (nrow(frontier_events) > 0 && !is.na(pub_date)) {
      frontier_18m_events <- frontier_events[
        !is.na(cite_date) & as.numeric(difftime(cite_date, pub_date, units = "days")) <= 548
      ]
      n_frontier_18m <- length(unique(frontier_18m_events$company))
    } else {
      n_frontier_18m <- 0L
    }

    data.table(
      openalex_id = openalex_id,
      n_industry_cites = nrow(events_dt),
      n_frontier_cites = n_frontier,
      n_bigtech_cites = n_bigtech,
      n_other_industry_cites = n_other,
      n_distinct_companies = length(distinct_companies),
      first_industry_date = as.character(first_industry),
      first_frontier_date = as.character(first_frontier),
      adoption_lag_days = adoption_lag,
      frontier_lag_days = frontier_lag,
      adopted_12m = adopted_12m,
      adopted_18m = adopted_18m,
      frontier_adopted_12m = frontier_12m,
      frontier_adopted_18m = frontier_18m,
      n_frontier_labs_18m = n_frontier_18m,
      companies_list = paste(distinct_companies, collapse = "; "),
      total_citing_works = n_total_citing
    )
  }

  # Query citing works for papers with OpenAlex IDs
  oa_with_id <- oa_df[!is.na(openalex_id) & nchar(openalex_id) > 5]
  n_to_query <- nrow(oa_with_id)
  cat(sprintf("Querying citing works for %d papers...\n", n_to_query))

  industry_results <- list()
  ind_checkpoint <- file.path(DATA_DIR, "industry_checkpoint.csv")

  start_i <- 1L
  if (file.exists(ind_checkpoint) && file.info(ind_checkpoint)$size > 100) {
    prev <- fread(ind_checkpoint)
    industry_results <- list(prev)
    done_ids <- prev$openalex_id
    start_i <- which(!(oa_with_id$openalex_id %in% done_ids))[1]
    if (is.na(start_i)) start_i <- n_to_query + 1L
    cat(sprintf("  Resuming from paper %d\n", start_i))
  }

  for (i in seq(start_i, n_to_query)) {
    # Use publication date from OpenAlex
    pub_date_str <- if ("pub_year_oa" %in% names(oa_with_id)) {
      sprintf("%d-01-01", oa_with_id$pub_year_oa[i])
    } else "2015-01-01"

    result <- query_citing_works(oa_with_id$openalex_id[i], pub_date_str)

    if (!is.null(result)) {
      result$arxiv_id <- oa_with_id$arxiv_id[i]
      industry_results <- c(industry_results, list(result))
    }

    if (i %% 50 == 0) {
      cat(sprintf("  Progress: %d/%d (%.0f%%)\n", i, n_to_query, 100 * i / n_to_query))
    }

    Sys.sleep(0.11)

    if (i %% 500 == 0 && length(industry_results) > 0) {
      ind_cp <- rbindlist(industry_results, fill = TRUE)
      fwrite(ind_cp, ind_checkpoint)
      cat(sprintf("  Checkpoint: %d records\n", nrow(ind_cp)))
    }
  }

  if (length(industry_results) > 0) {
    industry_df <- rbindlist(industry_results, fill = TRUE)
    industry_df <- unique(industry_df, by = "arxiv_id")
    fwrite(industry_df, industry_file)
    cat(sprintf("\nIndustry citation data saved: %d records\n", nrow(industry_df)))
    cat(sprintf("Papers with any industry citation: %d (%.1f%%)\n",
                sum(industry_df$n_industry_cites > 0),
                100 * mean(industry_df$n_industry_cites > 0)))
    cat(sprintf("Papers with frontier lab citation: %d (%.1f%%)\n",
                sum(industry_df$n_frontier_cites > 0),
                100 * mean(industry_df$n_frontier_cites > 0)))
    cat(sprintf("Papers adopted by frontier within 12m: %d (%.1f%%)\n",
                sum(industry_df$frontier_adopted_12m, na.rm = TRUE),
                100 * mean(industry_df$frontier_adopted_12m, na.rm = TRUE)))
  } else {
    cat("WARNING: No industry citation data collected.\n")
    industry_df <- data.table()
    fwrite(industry_df, industry_file)
  }

} else {
  industry_df <- fread(industry_file)
  cat(sprintf("Loaded existing industry citation data: %d records\n", nrow(industry_df)))
}

# ============================================================================
# Summary
# ============================================================================

cat("\n=== Data fetch complete ===\n")
cat(sprintf("arXiv papers: %d\n", nrow(arxiv_df)))
if (exists("s2_df")) cat(sprintf("Semantic Scholar matches: %d (%.0f%%)\n",
                                   nrow(s2_df), 100 * nrow(s2_df) / nrow(arxiv_df)))
if (exists("oa_df")) cat(sprintf("OpenAlex matches: %d (%.0f%%)\n",
                                   nrow(oa_df), 100 * nrow(oa_df) / nrow(arxiv_df)))
if (exists("industry_df")) {
  cat(sprintf("Industry citation records: %d\n", nrow(industry_df)))
  cat(sprintf("Frontier lab adoption rate: %.1f%%\n",
              100 * mean(industry_df$n_frontier_cites > 0)))
}
