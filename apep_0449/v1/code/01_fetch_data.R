## ============================================================================
## 01_fetch_data.R — Download election, affidavit, and outcome data
## Strategy: Try multiple sources, use whatever works
## ============================================================================
source("00_packages.R")

cat("\n========================================\n")
cat("DATA ACQUISITION — Criminal Politicians RDD\n")
cat("========================================\n\n")

## ============================================================================
## A. ELECTION DATA — Lok Dhaba / TCPD
## ============================================================================
cat("── A. Fetching election data from Lok Dhaba / TCPD ──\n")

## Try Lok Dhaba API for state assembly election data
## The portal uses a REST API: POST to /api/data with parameters
election_file <- file.path(DATA_DIR, "elections_state_assembly.csv")

if (!file.exists(election_file)) {
  ## Try the Lok Dhaba API endpoint
  tryCatch({
    ## Lok Dhaba uses a GraphQL/REST API. The data download URL pattern:
    res <- GET("https://lokdhaba.ashoka.edu.in/api/rawdata",
               query = list(
                 electionType = "AE",  # Assembly Elections
                 stateName = "all",
                 year = "all"
               ),
               timeout(120))
    if (status_code(res) == 200) {
      content_type <- headers(res)$`content-type`
      if (grepl("csv|text", content_type, ignore.case = TRUE)) {
        writeBin(content(res, "raw"), election_file)
        cat("  Downloaded election data from Lok Dhaba API\n")
      } else {
        cat("  Lok Dhaba API returned non-CSV response. Trying alternative.\n")
        stop("non-CSV")
      }
    } else {
      cat("  Lok Dhaba API returned status:", status_code(res), "\n")
      stop("API error")
    }
  }, error = function(e) {
    cat("  Lok Dhaba API not available. Trying TCPD GitHub...\n")

    ## Fallback: TCPD historical data on GitHub
    ## Note: This only has 1951-1962 data. Modern data requires the portal.
    ## Try ECI results scraping as next fallback
    tryCatch({
      ## Try the India Votes API as alternative
      res2 <- GET("https://www.indiavotes.com/api/elections",
                   timeout(30))
      if (status_code(res2) == 200) {
        cat("  IndiaVotes API accessible — would need custom scraping\n")
      }
    }, error = function(e2) {
      cat("  IndiaVotes not accessible either.\n")
    })
  })
}

## ============================================================================
## B. AFFIDAVIT DATA — DataMeet GitHub + MyNeta
## ============================================================================
cat("\n── B. Fetching affidavit data ──\n")

## DataMeet GitHub has pre-scraped Lok Sabha affidavits
affidavit_files <- c(
  "myneta.2004.csv" = "https://raw.githubusercontent.com/datameet/india-election-data/master/affidavits/myneta.2004.csv",
  "myneta.2009.csv" = "https://raw.githubusercontent.com/datameet/india-election-data/master/affidavits/myneta.2009.csv",
  "myneta.2014.csv" = "https://raw.githubusercontent.com/datameet/india-election-data/master/affidavits/myneta.2014.csv"
)

for (fname in names(affidavit_files)) {
  outpath <- file.path(DATA_DIR, fname)
  if (!file.exists(outpath)) {
    tryCatch({
      download.file(affidavit_files[[fname]], outpath, quiet = TRUE)
      cat("  Downloaded:", fname, "\n")
    }, error = function(e) {
      cat("  Failed to download:", fname, "\n")
    })
  } else {
    cat("  Already have:", fname, "\n")
  }
}

## Also try the main affidavits.csv (combined)
combined_aff <- file.path(DATA_DIR, "affidavits_combined.csv")
if (!file.exists(combined_aff)) {
  tryCatch({
    download.file(
      "https://raw.githubusercontent.com/datameet/india-election-data/master/affidavits/affidavits.csv",
      combined_aff, quiet = TRUE)
    cat("  Downloaded: affidavits_combined.csv\n")
  }, error = function(e) {
    cat("  Combined affidavits not available.\n")
  })
}

## ============================================================================
## C. SHRUG DATA — Harvard Dataverse
## ============================================================================
cat("\n── C. Trying SHRUG data from Harvard Dataverse ──\n")

## SHRUG DOI: doi:10.7910/DVN/DPESAK
## Try Dataverse API for file listing
shrug_dir <- file.path(DATA_DIR, "shrug")
dir.create(shrug_dir, showWarnings = FALSE)

shrug_available <- FALSE
tryCatch({
  dv_res <- GET("https://dataverse.harvard.edu/api/datasets/:persistentId",
                query = list(persistentId = "doi:10.7910/DVN/DPESAK"),
                timeout(30))
  if (status_code(dv_res) == 200) {
    dv_data <- content(dv_res, "text", encoding = "UTF-8")
    dv_json <- fromJSON(dv_data)

    if (!is.null(dv_json$data$latestVersion$files)) {
      files_df <- dv_json$data$latestVersion$files
      cat("  Found", nrow(files_df), "files on Harvard Dataverse\n")

      ## Look for election and nightlights files
      if ("label" %in% names(files_df)) {
        election_files <- files_df[grepl("triv|affid|elect", files_df$label,
                                         ignore.case = TRUE), ]
        nl_files <- files_df[grepl("night|light|nl|dmsp|viirs", files_df$label,
                                    ignore.case = TRUE), ]
        cat("  Election-related files:", nrow(election_files), "\n")
        cat("  Nightlight files:", nrow(nl_files), "\n")

        ## Download key files
        for (i in seq_len(min(nrow(files_df), 20))) {
          fid <- files_df$dataFile$id[i]
          flabel <- files_df$label[i]
          if (grepl("triv|affid|elect|night|light|nl|census|pca|vd",
                     flabel, ignore.case = TRUE)) {
            outf <- file.path(shrug_dir, flabel)
            if (!file.exists(outf)) {
              tryCatch({
                dl_url <- paste0("https://dataverse.harvard.edu/api/access/datafile/", fid)
                download.file(dl_url, outf, quiet = TRUE, mode = "wb")
                cat("    Downloaded:", flabel, "\n")
                shrug_available <- TRUE
              }, error = function(e) {
                cat("    Failed:", flabel, "\n")
              })
            }
          }
        }
      }
    }
  } else {
    cat("  Dataverse API returned status:", status_code(dv_res), "\n")
  }
}, error = function(e) {
  cat("  Harvard Dataverse not accessible:", conditionMessage(e), "\n")
})

## ============================================================================
## D. PRAKASH ET AL. REPLICATION DATA — Mendeley
## ============================================================================
cat("\n── D. Trying Prakash et al. (2019) replication data ──\n")

prakash_dir <- file.path(DATA_DIR, "prakash_replication")
dir.create(prakash_dir, showWarnings = FALSE)

prakash_zip <- file.path(prakash_dir, "prakash_2019.zip")
prakash_available <- FALSE

if (!file.exists(prakash_zip)) {
  ## Try common Mendeley zip download patterns
  mendeley_urls <- c(
    "https://prod-dcd-datasets-cache-zipfiles.s3.eu-west-1.amazonaws.com/wcdtwfmtkb-1.zip",
    "https://data.mendeley.com/public-files/datasets/wcdtwfmtkb/files/archive/download"
  )

  for (url in mendeley_urls) {
    tryCatch({
      cat("  Trying:", substr(url, 1, 80), "...\n")
      download.file(url, prakash_zip, quiet = TRUE, mode = "wb",
                    timeout = 120)
      fsize <- file.info(prakash_zip)$size
      if (!is.na(fsize) && fsize > 1000) {
        cat("  Success! Downloaded Prakash et al. replication data (",
            round(fsize / 1e6, 1), "MB)\n")
        prakash_available <- TRUE

        ## Unzip
        tryCatch({
          unzip(prakash_zip, exdir = prakash_dir)
          cat("  Unzipped to:", prakash_dir, "\n")
          cat("  Contents:", paste(list.files(prakash_dir, recursive = TRUE),
                                   collapse = ", "), "\n")
        }, error = function(e) {
          cat("  Unzip failed:", conditionMessage(e), "\n")
        })
        break
      } else {
        file.remove(prakash_zip)
      }
    }, error = function(e) {
      cat("  Failed:", conditionMessage(e), "\n")
      if (file.exists(prakash_zip)) file.remove(prakash_zip)
    })
  }
}

## ============================================================================
## E. ECI ELECTION RESULTS — Direct scraping
## ============================================================================
cat("\n── E. Scraping ECI election results ──\n")

## If we don't have election data yet, try scraping key elections from ECI
## Focus on large states with many constituencies: UP, Bihar, MP, Rajasthan, Maharashtra
## These states held elections in 2003-2017 window

## For now, check what data we actually have
cat("\n========================================\n")
cat("DATA AVAILABILITY SUMMARY\n")
cat("========================================\n")

data_files <- list.files(DATA_DIR, recursive = TRUE)
cat("Files downloaded:\n")
for (f in data_files) {
  fpath <- file.path(DATA_DIR, f)
  fsize <- file.info(fpath)$size
  cat(sprintf("  %-50s  %s\n", f,
              ifelse(fsize > 1e6,
                     paste0(round(fsize/1e6, 1), " MB"),
                     paste0(round(fsize/1e3, 1), " KB"))))
}

## ============================================================================
## F. CONSTRUCT ANALYSIS DATASET FROM WHATEVER WE HAVE
## ============================================================================
cat("\n── F. Loading and examining available data ──\n")

## Load affidavit data (DataMeet)
aff_list <- list()
for (yr in c(2004, 2009, 2014)) {
  fname <- file.path(DATA_DIR, paste0("myneta.", yr, ".csv"))
  if (file.exists(fname)) {
    tryCatch({
      df <- fread(fname, fill = TRUE, encoding = "UTF-8")
      df$election_year <- yr
      aff_list[[as.character(yr)]] <- df
      cat("  Loaded", yr, "affidavits:", nrow(df), "candidates\n")
    }, error = function(e) {
      cat("  Error loading", yr, "affidavits:", conditionMessage(e), "\n")
    })
  }
}

if (length(aff_list) > 0) {
  ## Examine column names
  cat("\n  Column names in affidavit data:\n")
  for (nm in names(aff_list)) {
    cat("    ", nm, ":", paste(names(aff_list[[nm]]), collapse = ", "), "\n")
  }
}

## Load combined affidavits if available
if (file.exists(combined_aff)) {
  tryCatch({
    aff_combined <- fread(combined_aff, fill = TRUE, encoding = "UTF-8")
    cat("  Combined affidavits:", nrow(aff_combined), "rows\n")
    cat("  Columns:", paste(names(aff_combined), collapse = ", "), "\n")
  }, error = function(e) {
    cat("  Error loading combined affidavits:", conditionMessage(e), "\n")
  })
}

## Check SHRUG files
shrug_files <- list.files(shrug_dir, recursive = TRUE)
if (length(shrug_files) > 0) {
  cat("\n  SHRUG files available:\n")
  for (f in shrug_files) cat("    ", f, "\n")
}

## Check Prakash replication files
prakash_files <- list.files(prakash_dir, recursive = TRUE)
if (length(prakash_files) > 0) {
  cat("\n  Prakash et al. replication files:\n")
  for (f in prakash_files) cat("    ", f, "\n")
}

cat("\n========================================\n")
cat("DATA FETCH COMPLETE\n")
cat("========================================\n")

## Save data availability status
data_status <- list(
  affidavit_lok_sabha = length(aff_list) > 0,
  shrug_available = shrug_available,
  prakash_available = prakash_available,
  election_data = file.exists(election_file),
  timestamp = Sys.time()
)
saveRDS(data_status, file.path(DATA_DIR, "data_status.rds"))
cat("Data status saved to data_status.rds\n")
