##############################################################################
# 00_data_access_test.R
# APEP 0421 - India Data Access Smoke Tests
# Tests accessibility of key data sources for India economics research
##############################################################################

library(httr)
library(jsonlite)
library(fredr)

# Define base directories (same as 00_packages.R)
script_dir <- dirname(sys.frame(1)$ofile %||% ".")
if (script_dir == ".") script_dir <- getwd()
if (basename(script_dir) == "code") {
  base_dir <- dirname(script_dir)
} else {
  base_dir <- script_dir
}
data_dir <- file.path(base_dir, "data")

# Output collector
results <- list()
cat("=" , rep("=", 70), "\n", sep = "")
cat("APEP 0421 - India Data Access Smoke Tests\n")
cat("Date:", as.character(Sys.time()), "\n")
cat("=" , rep("=", 70), "\n\n", sep = "")

###############################################################################
# TEST 1: FRED API — India-related macroeconomic series
###############################################################################
cat("TEST 1: FRED API for India\n")
cat(rep("-", 50), "\n", sep = "")

fred_key <- Sys.getenv("FRED_API_KEY")
if (nchar(fred_key) == 0) {
  cat("  FRED_API_KEY not found in environment. SKIPPING.\n")
  results$fred <- list(accessible = FALSE, reason = "No API key")
} else {
  fredr_set_key(fred_key)

  # Series to test
  fred_series <- list(
    list(id = "MKTGDPINA646NWDB", desc = "India GDP (current USD)"),
    list(id = "DDOE02INA086NWDB", desc = "India CPI"),
    list(id = "FPCPITOTLZGIND",   desc = "India Inflation (annual %)"),
    list(id = "NYGDPPCAPKDIND",   desc = "India GDP per capita (constant 2015 USD)"),
    list(id = "SLUEM1524ZSIND",   desc = "India Youth Unemployment Rate"),
    list(id = "INDPOPDPNDOLPCT",  desc = "India Age Dependency Ratio"),
    list(id = "INDCPALTT01IXOBM", desc = "India CPI All Items"),
    list(id = "INDGDPRQPSMEI",    desc = "India Real GDP Quarterly (OECD)"),
    list(id = "INDPOPSP",         desc = "India Population (UN)"),
    list(id = "MANPMNONA066NEST", desc = "India Manufacturing PMI"),
    list(id = "INDLPMINDM",       desc = "India Industrial Production"),
    list(id = "DEXINUS",          desc = "India/US Exchange Rate")
  )

  fred_results <- list()
  for (s in fred_series) {
    tryCatch({
      dat <- fredr_series_observations(
        series_id = s$id,
        observation_start = as.Date("2000-01-01"),
        observation_end   = as.Date("2025-12-31")
      )
      n_obs <- nrow(dat)
      date_range <- if (n_obs > 0) {
        paste(min(dat$date, na.rm = TRUE), "to", max(dat$date, na.rm = TRUE))
      } else {
        "no data"
      }
      non_na <- sum(!is.na(dat$value))
      cat(sprintf("  ✓ %s (%s): %d obs (%d non-NA), range: %s\n",
                  s$id, s$desc, n_obs, non_na, date_range))
      fred_results[[s$id]] <- list(
        accessible = TRUE, obs = n_obs, non_na = non_na,
        date_range = date_range, desc = s$desc
      )
    }, error = function(e) {
      cat(sprintf("  ✗ %s (%s): ERROR - %s\n", s$id, s$desc, e$message))
      fred_results[[s$id]] <<- list(accessible = FALSE, error = e$message, desc = s$desc)
    })
    Sys.sleep(0.5)  # Rate limit
  }

  # Also search for India-related series
  cat("\n  Searching FRED for 'India' series...\n")
  tryCatch({
    search_res <- fredr_series_search_text(
      search_text = "India",
      limit = 50
    )
    cat(sprintf("  Found %d series matching 'India'\n", nrow(search_res)))
    if (nrow(search_res) > 0) {
      cat("  Top 10 by popularity:\n")
      top10 <- head(search_res[order(-search_res$popularity), ], 10)
      for (i in seq_len(nrow(top10))) {
        cat(sprintf("    %s: %s (freq: %s, pop: %d)\n",
                    top10$id[i], top10$title[i],
                    top10$frequency_short[i], top10$popularity[i]))
      }
    }
    fred_results$search <- list(total_series = nrow(search_res))
  }, error = function(e) {
    cat(sprintf("  Search error: %s\n", e$message))
  })

  results$fred <- fred_results
}

cat("\n")

###############################################################################
# TEST 2: data.gov.in - ONORC and other datasets
###############################################################################
cat("TEST 2: data.gov.in API\n")
cat(rep("-", 50), "\n", sep = "")

# Try the data.gov.in API without an API key first (some endpoints are open)
# Then try with key if available
datagov_key <- Sys.getenv("DATA_GOV_IN_API_KEY")  # unlikely to be set

# Test the catalog endpoint
datagov_results <- list()

# Test 2a: ONORC catalog page
cat("  2a: ONORC catalog page...\n")
tryCatch({
  resp <- GET("https://data.gov.in/catalog/one-nation-one-ration-card-onorc-plan",
              timeout(30),
              user_agent("APEP-Research/1.0"))
  cat(sprintf("  Status: %d\n", status_code(resp)))
  if (status_code(resp) == 200) {
    body <- content(resp, as = "text", encoding = "UTF-8")
    cat(sprintf("  Response size: %d bytes\n", nchar(body)))
    # Check for download links
    has_csv <- grepl("csv", body, ignore.case = TRUE)
    has_xls <- grepl("xls", body, ignore.case = TRUE)
    has_api <- grepl("api\\.data\\.gov\\.in", body, ignore.case = TRUE)
    cat(sprintf("  Contains CSV links: %s\n", has_csv))
    cat(sprintf("  Contains XLS links: %s\n", has_xls))
    cat(sprintf("  Contains API links: %s\n", has_api))
    datagov_results$onorc_catalog <- list(
      accessible = TRUE, status = status_code(resp),
      has_csv = has_csv, has_xls = has_xls, has_api = has_api
    )
  } else {
    datagov_results$onorc_catalog <- list(accessible = FALSE, status = status_code(resp))
  }
}, error = function(e) {
  cat(sprintf("  ERROR: %s\n", e$message))
  datagov_results$onorc_catalog <<- list(accessible = FALSE, error = e$message)
})

# Test 2b: data.gov.in API search
cat("\n  2b: data.gov.in API search for 'ONORC'...\n")
tryCatch({
  resp <- GET("https://api.data.gov.in/resource/catalog",
              query = list(
                format = "json",
                "filters[title]" = "ONORC",
                limit = 10
              ),
              timeout(30),
              user_agent("APEP-Research/1.0"))
  cat(sprintf("  Status: %d\n", status_code(resp)))
  if (status_code(resp) == 200) {
    body <- content(resp, as = "text", encoding = "UTF-8")
    cat(sprintf("  Response: %s\n", substr(body, 1, 500)))
    datagov_results$onorc_api <- list(accessible = TRUE, status = 200)
  } else {
    body <- content(resp, as = "text", encoding = "UTF-8")
    cat(sprintf("  Response: %s\n", substr(body, 1, 500)))
    datagov_results$onorc_api <- list(accessible = FALSE, status = status_code(resp))
  }
}, error = function(e) {
  cat(sprintf("  ERROR: %s\n", e$message))
  datagov_results$onorc_api <<- list(accessible = FALSE, error = e$message)
})

# Test 2c: data.gov.in API general search for India welfare/development data
cat("\n  2c: data.gov.in API search for welfare/development datasets...\n")
search_terms <- c("ration card", "MGNREGA", "PM Awas", "rural development",
                   "Jal Jeevan", "drinking water", "education district")
for (term in search_terms) {
  tryCatch({
    resp <- GET("https://api.data.gov.in/lists",
                query = list(
                  format = "json",
                  search = term,
                  limit = 5
                ),
                timeout(15),
                user_agent("APEP-Research/1.0"))
    if (status_code(resp) == 200) {
      body <- content(resp, as = "text", encoding = "UTF-8")
      parsed <- tryCatch(fromJSON(body), error = function(e) NULL)
      n_results <- if (!is.null(parsed) && "total" %in% names(parsed)) parsed$total else "?"
      cat(sprintf("  '%s': %s results (HTTP %d)\n", term, n_results, status_code(resp)))
    } else {
      cat(sprintf("  '%s': HTTP %d\n", term, status_code(resp)))
    }
  }, error = function(e) {
    cat(sprintf("  '%s': ERROR - %s\n", term, e$message))
  })
  Sys.sleep(0.3)
}

results$datagov <- datagov_results
cat("\n")

###############################################################################
# TEST 3: RBI DBIE — State-level credit/deposit data
###############################################################################
cat("TEST 3: RBI DBIE\n")
cat(rep("-", 50), "\n", sep = "")

rbi_results <- list()

# Test 3a: Main DBIE portal accessibility
cat("  3a: DBIE portal accessibility...\n")
tryCatch({
  resp <- GET("https://dbie.rbi.org.in",
              timeout(30),
              user_agent("APEP-Research/1.0"))
  cat(sprintf("  Main portal status: %d\n", status_code(resp)))
  rbi_results$portal <- list(accessible = status_code(resp) == 200, status = status_code(resp))
}, error = function(e) {
  cat(sprintf("  Portal ERROR: %s\n", e$message))
  rbi_results$portal <<- list(accessible = FALSE, error = e$message)
})

# Test 3b: DBIE API endpoints
cat("  3b: DBIE API exploration...\n")
dbie_endpoints <- c(
  "https://dbie.rbi.org.in/DBIE/dbie.rbi?site=publications",
  "https://dbie.rbi.org.in/DBIE/dbie.rbi?site=statistics",
  "https://dbie.rbi.org.in/api/data",
  "https://data.rbi.org.in/DBIE/dbie.rbi?site=statistics&page=SectorsandSubSectorsoftheEconomy"
)
for (ep in dbie_endpoints) {
  tryCatch({
    resp <- GET(ep, timeout(15), user_agent("APEP-Research/1.0"))
    body_size <- nchar(content(resp, as = "text", encoding = "UTF-8"))
    cat(sprintf("  %s -> HTTP %d (%d bytes)\n",
                substr(ep, nchar("https://dbie.rbi.org.in") + 1, nchar(ep)),
                status_code(resp), body_size))
  }, error = function(e) {
    cat(sprintf("  %s -> ERROR: %s\n", substr(ep, 30, nchar(ep)), e$message))
  })
  Sys.sleep(0.3)
}

# Test 3c: RBI Handbook of Statistics (known downloadable CSV/XLS)
cat("  3c: RBI Handbook of Statistics...\n")
tryCatch({
  resp <- GET("https://rbi.org.in/scripts/AnnualPublications.aspx?head=Handbook%20of%20Statistics%20on%20Indian%20Economy",
              timeout(30),
              user_agent("APEP-Research/1.0"))
  cat(sprintf("  Handbook page status: %d\n", status_code(resp)))
  if (status_code(resp) == 200) {
    body <- content(resp, as = "text", encoding = "UTF-8")
    has_xls <- grepl("\\.xls", body, ignore.case = TRUE)
    has_csv <- grepl("\\.csv", body, ignore.case = TRUE)
    has_pdf <- grepl("\\.pdf", body, ignore.case = TRUE)
    cat(sprintf("  XLS links: %s, CSV links: %s, PDF links: %s\n", has_xls, has_csv, has_pdf))
    rbi_results$handbook <- list(accessible = TRUE, has_xls = has_xls, has_csv = has_csv)
  }
}, error = function(e) {
  cat(sprintf("  Handbook ERROR: %s\n", e$message))
  rbi_results$handbook <<- list(accessible = FALSE, error = e$message)
})

# Test 3d: RBI Statistical Tables — credit/deposit at state level
cat("  3d: RBI Statistical Tables Relating to Banks in India...\n")
tryCatch({
  resp <- GET("https://rbi.org.in/scripts/AnnualPublications.aspx?head=Statistical%20Tables%20Relating%20to%20Banks%20in%20India",
              timeout(30),
              user_agent("APEP-Research/1.0"))
  cat(sprintf("  Stats Tables page status: %d\n", status_code(resp)))
  if (status_code(resp) == 200) {
    body <- content(resp, as = "text", encoding = "UTF-8")
    has_download <- grepl("download|xls|csv", body, ignore.case = TRUE)
    cat(sprintf("  Has download links: %s\n", has_download))
    rbi_results$stat_tables <- list(accessible = TRUE, has_downloads = has_download)
  }
}, error = function(e) {
  cat(sprintf("  ERROR: %s\n", e$message))
})

results$rbi <- rbi_results
cat("\n")

###############################################################################
# TEST 4: SHRUG (Socioeconomic High-resolution Rural-Urban Geographic dataset)
###############################################################################
cat("TEST 4: SHRUG GitHub Releases\n")
cat(rep("-", 50), "\n", sep = "")

shrug_results <- list()

# Test 4a: GitHub releases page
cat("  4a: SHRUG GitHub releases...\n")
tryCatch({
  resp <- GET("https://api.github.com/repos/devdatalab/shrug-public/releases",
              timeout(30),
              add_headers(Accept = "application/vnd.github.v3+json"),
              user_agent("APEP-Research/1.0"))
  cat(sprintf("  GitHub API status: %d\n", status_code(resp)))
  if (status_code(resp) == 200) {
    releases <- fromJSON(content(resp, as = "text", encoding = "UTF-8"))
    cat(sprintf("  Number of releases: %d\n", nrow(releases)))
    if (nrow(releases) > 0) {
      for (i in seq_len(min(nrow(releases), 5))) {
        cat(sprintf("  Release: %s (tag: %s, date: %s)\n",
                    releases$name[i], releases$tag_name[i],
                    substr(releases$published_at[i], 1, 10)))
        # Check assets
        assets <- releases$assets[[i]]
        if (!is.null(assets) && nrow(assets) > 0) {
          for (j in seq_len(nrow(assets))) {
            size_mb <- round(assets$size[j] / 1e6, 1)
            cat(sprintf("    Asset: %s (%.1f MB, downloads: %d)\n",
                        assets$name[j], size_mb, assets$download_count[j]))
          }
        } else {
          cat("    No downloadable assets\n")
        }
      }
    }
    shrug_results$releases <- list(accessible = TRUE, n_releases = nrow(releases))
  } else {
    shrug_results$releases <- list(accessible = FALSE, status = status_code(resp))
  }
}, error = function(e) {
  cat(sprintf("  ERROR: %s\n", e$message))
  shrug_results$releases <<- list(accessible = FALSE, error = e$message)
})

# Test 4b: SHRUG main repo contents
cat("\n  4b: SHRUG repo contents...\n")
tryCatch({
  resp <- GET("https://api.github.com/repos/devdatalab/shrug-public/contents",
              timeout(30),
              add_headers(Accept = "application/vnd.github.v3+json"),
              user_agent("APEP-Research/1.0"))
  if (status_code(resp) == 200) {
    contents <- fromJSON(content(resp, as = "text", encoding = "UTF-8"))
    cat(sprintf("  Files/dirs in repo root: %d\n", nrow(contents)))
    for (i in seq_len(nrow(contents))) {
      cat(sprintf("    %s (%s)\n", contents$name[i], contents$type[i]))
    }
    shrug_results$repo <- list(accessible = TRUE, n_items = nrow(contents))
  }
}, error = function(e) {
  cat(sprintf("  ERROR: %s\n", e$message))
})

# Test 4c: Check local SHRUG data if exists
local_shrug <- file.path(dirname(dirname(getwd())), "data", "india_shrug")
if (dir.exists(local_shrug)) {
  cat(sprintf("\n  4c: Local SHRUG data found at %s\n", local_shrug))
  files <- list.files(local_shrug, recursive = TRUE)
  cat(sprintf("  Files: %d\n", length(files)))
  for (f in head(files, 20)) {
    fpath <- file.path(local_shrug, f)
    size_mb <- round(file.size(fpath) / 1e6, 2)
    cat(sprintf("    %s (%.2f MB)\n", f, size_mb))
  }
  shrug_results$local <- list(exists = TRUE, n_files = length(files))
} else {
  cat("\n  4c: No local SHRUG data at data/india_shrug/\n")
  shrug_results$local <- list(exists = FALSE)
}

results$shrug <- shrug_results
cat("\n")

###############################################################################
# TEST 5: UDISE+ (Unified District Information System for Education Plus)
###############################################################################
cat("TEST 5: UDISE+ Portal\n")
cat(rep("-", 50), "\n", sep = "")

udise_results <- list()

cat("  5a: UDISE+ main portal...\n")
tryCatch({
  resp <- GET("https://udiseplus.gov.in",
              timeout(30),
              user_agent("APEP-Research/1.0"))
  cat(sprintf("  Portal status: %d\n", status_code(resp)))
  if (status_code(resp) == 200) {
    body <- content(resp, as = "text", encoding = "UTF-8")
    has_download <- grepl("download|bulk|data", body, ignore.case = TRUE)
    has_api <- grepl("api", body, ignore.case = TRUE)
    cat(sprintf("  Has download references: %s\n", has_download))
    cat(sprintf("  Has API references: %s\n", has_api))
    udise_results$portal <- list(accessible = TRUE, has_download = has_download)
  }
}, error = function(e) {
  cat(sprintf("  ERROR: %s\n", e$message))
  udise_results$portal <<- list(accessible = FALSE, error = e$message)
})

# Test 5b: UDISE+ dashboard / report card
cat("  5b: UDISE+ dashboard data endpoints...\n")
udise_endpoints <- c(
  "https://dashboard.udiseplus.gov.in",
  "https://src.udiseplus.gov.in/searchSchool",
  "https://udiseplus.gov.in/dashboard/stateWise",
  "https://dashboard.udiseplus.gov.in/#!/home"
)
for (ep in udise_endpoints) {
  tryCatch({
    resp <- GET(ep, timeout(15), user_agent("APEP-Research/1.0"),
                config(followlocation = TRUE))
    cat(sprintf("  %s -> HTTP %d\n", ep, status_code(resp)))
  }, error = function(e) {
    cat(sprintf("  %s -> ERROR: %s\n", ep, substr(e$message, 1, 80)))
  })
  Sys.sleep(0.3)
}

results$udise <- udise_results
cat("\n")

###############################################################################
# TEST 6: Jal Jeevan Mission (JJM) Dashboard
###############################################################################
cat("TEST 6: Jal Jeevan Mission Dashboard\n")
cat(rep("-", 50), "\n", sep = "")

jjm_results <- list()

cat("  6a: JJM main dashboard...\n")
tryCatch({
  resp <- GET("https://ejalshakti.gov.in/jjmreport/JJMIndia.aspx",
              timeout(30),
              user_agent("APEP-Research/1.0"))
  cat(sprintf("  JJM dashboard status: %d\n", status_code(resp)))
  if (status_code(resp) == 200) {
    body <- content(resp, as = "text", encoding = "UTF-8")
    body_size <- nchar(body)
    has_api <- grepl("api|json|ajax|webservice|ashx|asmx", body, ignore.case = TRUE)
    has_download <- grepl("download|export|csv|excel", body, ignore.case = TRUE)
    has_state <- grepl("state|statewise|StateWise", body)
    cat(sprintf("  Response size: %d bytes\n", body_size))
    cat(sprintf("  Has API/AJAX references: %s\n", has_api))
    cat(sprintf("  Has download/export references: %s\n", has_download))
    cat(sprintf("  Has state-level references: %s\n", has_state))
    jjm_results$dashboard <- list(
      accessible = TRUE, size = body_size,
      has_api = has_api, has_download = has_download
    )
  }
}, error = function(e) {
  cat(sprintf("  ERROR: %s\n", e$message))
  jjm_results$dashboard <<- list(accessible = FALSE, error = e$message)
})

# Test 6b: JJM API endpoints
cat("  6b: JJM API endpoints...\n")
jjm_endpoints <- c(
  "https://ejalshakti.gov.in/jjmreport/JJMReportAPI/JJMReport.asmx",
  "https://ejalshakti.gov.in/jjmreport/JJMReport_Dashboard.aspx",
  "https://ejalshakti.gov.in/IMISReports/Reports/BasicInformation/rpt_JJM_StatusofScheme.aspx",
  "https://ejalshakti.gov.in/jjmreport/GetStateData",
  "https://ejalshakti.gov.in/JalJeevanMission/Loging/DashboardData"
)
for (ep in jjm_endpoints) {
  tryCatch({
    resp <- GET(ep, timeout(15), user_agent("APEP-Research/1.0"),
                config(followlocation = TRUE))
    cat(sprintf("  %s\n    -> HTTP %d (%d bytes)\n", ep, status_code(resp),
                nchar(content(resp, as = "text", encoding = "UTF-8"))))
  }, error = function(e) {
    cat(sprintf("  %s\n    -> ERROR: %s\n", ep, substr(e$message, 1, 80)))
  })
  Sys.sleep(0.3)
}

results$jjm <- jjm_results
cat("\n")

###############################################################################
# TEST 7: World Bank API — India indicators (bonus, reliable fallback)
###############################################################################
cat("TEST 7: World Bank API (India indicators)\n")
cat(rep("-", 50), "\n", sep = "")

wb_results <- list()
wb_indicators <- list(
  list(id = "NY.GDP.PCAP.PP.KD",   desc = "GDP per capita PPP (constant 2017 USD)"),
  list(id = "SI.POV.DDAY",         desc = "Poverty headcount ($2.15/day)"),
  list(id = "SE.ADT.LITR.ZS",      desc = "Adult literacy rate"),
  list(id = "SH.STA.WASH.P5",      desc = "Basic drinking water (rural)"),
  list(id = "SH.STA.BASS.RU.ZS",   desc = "Basic sanitation (rural)"),
  list(id = "EG.ELC.ACCS.ZS",      desc = "Access to electricity"),
  list(id = "SE.PRM.ENRR",         desc = "Gross enrollment, primary"),
  list(id = "SL.UEM.TOTL.ZS",      desc = "Unemployment total"),
  list(id = "FP.CPI.TOTL.ZG",      desc = "Inflation, consumer prices"),
  list(id = "NE.EXP.GNFS.ZS",      desc = "Exports of goods/services (% GDP)")
)

for (ind in wb_indicators) {
  tryCatch({
    url <- sprintf("https://api.worldbank.org/v2/country/IND/indicator/%s?format=json&per_page=100&date=2000:2024",
                   ind$id)
    resp <- GET(url, timeout(15))
    if (status_code(resp) == 200) {
      parsed <- fromJSON(content(resp, as = "text", encoding = "UTF-8"))
      if (length(parsed) >= 2 && !is.null(parsed[[2]])) {
        dat <- parsed[[2]]
        n_obs <- nrow(dat)
        non_null <- sum(!is.na(dat$value) & dat$value != "null")
        years <- dat$date[!is.na(dat$value) & dat$value != "null"]
        yr_range <- if (length(years) > 0) paste(min(years), "-", max(years)) else "no data"
        cat(sprintf("  ✓ %s (%s): %d obs (%d non-null), years: %s\n",
                    ind$id, ind$desc, n_obs, non_null, yr_range))
        wb_results[[ind$id]] <- list(accessible = TRUE, obs = n_obs,
                                     non_null = non_null, years = yr_range)
      } else {
        cat(sprintf("  ~ %s (%s): response parsed but no data array\n", ind$id, ind$desc))
        wb_results[[ind$id]] <- list(accessible = TRUE, obs = 0)
      }
    }
  }, error = function(e) {
    cat(sprintf("  ✗ %s: ERROR - %s\n", ind$id, e$message))
    wb_results[[ind$id]] <<- list(accessible = FALSE, error = e$message)
  })
  Sys.sleep(0.3)
}

results$worldbank <- wb_results
cat("\n")

###############################################################################
# TEST 8: PLFS (Periodic Labour Force Survey) — MoSPI
###############################################################################
cat("TEST 8: PLFS / MoSPI Data\n")
cat(rep("-", 50), "\n", sep = "")

plfs_results <- list()

cat("  8a: MoSPI PLFS page...\n")
tryCatch({
  resp <- GET("https://mospi.gov.in/publication/periodic-labour-force-survey-plfs-1",
              timeout(30),
              user_agent("APEP-Research/1.0"))
  cat(sprintf("  MoSPI PLFS status: %d\n", status_code(resp)))
  if (status_code(resp) == 200) {
    body <- content(resp, as = "text", encoding = "UTF-8")
    has_download <- grepl("download|pdf|xls|csv|zip", body, ignore.case = TRUE)
    cat(sprintf("  Has download links: %s\n", has_download))
    plfs_results$mospi <- list(accessible = TRUE, has_download = has_download)
  }
}, error = function(e) {
  cat(sprintf("  ERROR: %s\n", e$message))
  plfs_results$mospi <<- list(accessible = FALSE, error = e$message)
})

# 8b: PLFS unit-level data from microdata portal
cat("  8b: MoSPI microdata portal...\n")
tryCatch({
  resp <- GET("https://microdata.gov.in/nada43/index.php/catalog",
              timeout(30),
              user_agent("APEP-Research/1.0"))
  cat(sprintf("  Microdata portal status: %d\n", status_code(resp)))
  plfs_results$microdata <- list(accessible = status_code(resp) == 200,
                                  status = status_code(resp))
}, error = function(e) {
  cat(sprintf("  ERROR: %s\n", e$message))
  plfs_results$microdata <<- list(accessible = FALSE, error = e$message)
})

results$plfs <- plfs_results
cat("\n")

###############################################################################
# SUMMARY
###############################################################################
cat("=" , rep("=", 70), "\n", sep = "")
cat("SUMMARY OF DATA ACCESS TESTS\n")
cat("=" , rep("=", 70), "\n\n", sep = "")

summary_lines <- c()

# FRED
fred_ok <- sum(sapply(results$fred, function(x) isTRUE(x$accessible)))
fred_total <- length(results$fred) - 1  # minus search
summary_lines <- c(summary_lines,
  sprintf("FRED API:        %d/%d India series accessible", fred_ok, fred_total))

# World Bank
wb_ok <- sum(sapply(results$worldbank, function(x) isTRUE(x$accessible) && x$obs > 0))
wb_total <- length(results$worldbank)
summary_lines <- c(summary_lines,
  sprintf("World Bank API:  %d/%d indicators accessible", wb_ok, wb_total))

# data.gov.in
summary_lines <- c(summary_lines,
  sprintf("data.gov.in:     ONORC catalog %s",
          ifelse(isTRUE(results$datagov$onorc_catalog$accessible), "ACCESSIBLE", "NOT ACCESSIBLE")))

# RBI
summary_lines <- c(summary_lines,
  sprintf("RBI DBIE:        Portal %s",
          ifelse(isTRUE(results$rbi$portal$accessible), "ACCESSIBLE", "NOT ACCESSIBLE")))

# SHRUG
summary_lines <- c(summary_lines,
  sprintf("SHRUG GitHub:    %s",
          ifelse(isTRUE(results$shrug$releases$accessible),
                 sprintf("ACCESSIBLE (%d releases)", results$shrug$releases$n_releases),
                 "NOT ACCESSIBLE")))

# UDISE+
summary_lines <- c(summary_lines,
  sprintf("UDISE+:          Portal %s",
          ifelse(isTRUE(results$udise$portal$accessible), "ACCESSIBLE", "NOT ACCESSIBLE")))

# JJM
summary_lines <- c(summary_lines,
  sprintf("JJM Dashboard:   %s",
          ifelse(isTRUE(results$jjm$dashboard$accessible), "ACCESSIBLE", "NOT ACCESSIBLE")))

# PLFS
summary_lines <- c(summary_lines,
  sprintf("PLFS/MoSPI:      %s",
          ifelse(isTRUE(results$plfs$mospi$accessible), "ACCESSIBLE", "NOT ACCESSIBLE")))

for (line in summary_lines) {
  cat(line, "\n")
}

# Save results as JSON for report generation
results_json <- toJSON(results, auto_unbox = TRUE, pretty = TRUE)
writeLines(results_json, file.path(data_dir, "access_results.json"))
cat("\nResults saved to", file.path(data_dir, "access_results.json"), "\n")

cat("\nDone.\n")
