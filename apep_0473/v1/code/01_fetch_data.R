###############################################################################
# 01_fetch_data.R — Fetch UC rollout dates + NOMIS employment data
# APEP-0473: Universal Credit and Self-Employment in Britain
###############################################################################

source("00_packages.R")

###############################################################################
# Helper: Direct NOMIS API calls (targeted fetching)
###############################################################################

nomis_fetch <- function(dataset_id, params = list(), max_rows = 25000) {
  base_url <- paste0("https://www.nomisweb.co.uk/api/v01/dataset/", dataset_id, ".data.csv")

  api_key <- Sys.getenv("NOMIS_API_KEY")
  if (nchar(api_key) > 0) {
    params$uid <- api_key
    max_rows <- 100000
  }

  all_data <- list()
  offset <- 0
  repeat {
    params$recordoffset <- offset
    params$recordlimit <- max_rows

    req <- request(base_url) %>%
      req_url_query(!!!params) %>%
      req_timeout(180)

    resp <- tryCatch(req_perform(req), error = function(e) {
      cat("  API error:", conditionMessage(e), "\n")
      return(NULL)
    })

    if (is.null(resp)) break

    body <- resp_body_string(resp)
    if (nchar(body) < 10) {
      cat("  Empty response at offset", offset, "\n")
      break
    }

    chunk <- tryCatch(
      read_csv(body, show_col_types = FALSE),
      error = function(e) {
        cat("  CSV parse error:", conditionMessage(e), "\n")
        return(NULL)
      }
    )

    if (is.null(chunk) || nrow(chunk) == 0) break

    all_data <- c(all_data, list(chunk))
    cat(sprintf("  Fetched %d rows (offset %d)\n", nrow(chunk), offset))

    if (nrow(chunk) < max_rows) break
    offset <- offset + max_rows
    Sys.sleep(1)  # respect rate limits
  }

  if (length(all_data) == 0) return(tibble())
  bind_rows(all_data)
}

###############################################################################
# 1. UC Full Service Rollout Dates (from GOV.UK)
###############################################################################

cat("=== Constructing UC Full Service rollout dates ===\n")

# Scrape the 2018 rollout schedule
rollout_url <- "https://www.gov.uk/government/publications/universal-credit-transition-to-full-service/universal-credit-transition-rollout-schedule-march-2018-to-december-2018"

rollout_entries <- tryCatch({
  page <- read_html(rollout_url)
  tables <- page %>% html_elements("table") %>% html_table()
  cat("Found", length(tables), "tables from GOV.UK\n")
  if (length(tables) > 0) {
    bind_rows(tables, .id = "table_id")
  } else NULL
}, error = function(e) {
  cat("GOV.UK scrape failed:", conditionMessage(e), "\n")
  NULL
})

if (!is.null(rollout_entries) && nrow(rollout_entries) > 0) {
  write_csv(rollout_entries, file.path(DATA_DIR, "uc_rollout_2018_raw.csv"))
  cat("Saved 2018 rollout:", nrow(rollout_entries), "entries\n")
}

# Download rollout PDF for earlier phases
pdf_url <- "https://assets.publishing.service.gov.uk/media/5ab507c8e5274a1aa2d414d1/universal-credit-transition-rollout-schedule.pdf"
tryCatch({
  download.file(pdf_url, file.path(DATA_DIR, "uc_rollout_schedule.pdf"),
                mode = "wb", quiet = TRUE)
  cat("Downloaded rollout PDF\n")
}, error = function(e) cat("PDF download failed\n"))

###############################################################################
# 2. NOMIS APS: Targeted variable fetch
#    Need: self-employment rate, employment rate, by LA, quarterly
###############################################################################

cat("\n=== Fetching APS self-employment data ===\n")

# Key variables from NM_17_5:
# 249 = % aged 16-64 who are self employed
# 45  = Employment rate - aged 16-64
# 73  = % in employment who are self employed - aged 16+
# 18  = Economic activity rate - aged 16-64

# Fetch EACH variable separately to avoid API row limits

# --- Self-employment rate (% of working-age pop self-employed) ---
cat("Fetching self-employment rate (var 249)...\n")
aps_se <- nomis_fetch("NM_17_5", params = list(
  geography = "TYPE464",
  variable = "249",
  time = "latest",  # Need to specify time differently
  measures = "20599"
))

# The NOMIS API time parameter for APS uses date ranges
# Let's try specific time format
if (nrow(aps_se) < 100) {
  cat("Retrying with explicit time range...\n")
  # Try yearly aggregates
  years <- 2004:2019
  aps_se_list <- list()
  for (yr in years) {
    cat("  Year", yr, "...")
    chunk <- tryCatch({
      nomis_fetch("NM_17_5", params = list(
        geography = "TYPE464",
        variable = "249",
        time = as.character(yr),
        measures = "20599"
      ))
    }, error = function(e) tibble())
    if (nrow(chunk) > 0) {
      aps_se_list <- c(aps_se_list, list(chunk))
      cat(nrow(chunk), "rows\n")
    } else {
      cat("no data\n")
    }
    Sys.sleep(0.5)
  }
  aps_se <- bind_rows(aps_se_list)
}

if (nrow(aps_se) > 0) {
  cat("Self-employment data:", nrow(aps_se), "rows\n")
  write_csv(aps_se, file.path(DATA_DIR, "aps_self_employment_raw.csv"))
}

# --- Employment rate (% of working-age pop in employment) ---
cat("\nFetching employment rate (var 45)...\n")
aps_emp_list <- list()
for (yr in 2004:2019) {
  cat("  Year", yr, "...")
  chunk <- tryCatch({
    nomis_fetch("NM_17_5", params = list(
      geography = "TYPE464",
      variable = "45",
      time = as.character(yr),
      measures = "20599"
    ))
  }, error = function(e) tibble())
  if (nrow(chunk) > 0) {
    aps_emp_list <- c(aps_emp_list, list(chunk))
    cat(nrow(chunk), "rows\n")
  } else {
    cat("no data\n")
  }
  Sys.sleep(0.5)
}
aps_emp <- bind_rows(aps_emp_list)

if (nrow(aps_emp) > 0) {
  cat("Employment rate data:", nrow(aps_emp), "rows\n")
  write_csv(aps_emp, file.path(DATA_DIR, "aps_employment_rate_raw.csv"))
}

# --- Self-employment share (% of employed who are self-employed) ---
cat("\nFetching self-employment share (var 73)...\n")
aps_share_list <- list()
for (yr in 2004:2019) {
  cat("  Year", yr, "...")
  chunk <- tryCatch({
    nomis_fetch("NM_17_5", params = list(
      geography = "TYPE464",
      variable = "73",
      time = as.character(yr),
      measures = "20599"
    ))
  }, error = function(e) tibble())
  if (nrow(chunk) > 0) {
    aps_share_list <- c(aps_share_list, list(chunk))
    cat(nrow(chunk), "rows\n")
  } else {
    cat("no data\n")
  }
  Sys.sleep(0.5)
}
aps_share <- bind_rows(aps_share_list)

if (nrow(aps_share) > 0) {
  cat("Self-emp share data:", nrow(aps_share), "rows\n")
  write_csv(aps_share, file.path(DATA_DIR, "aps_se_share_raw.csv"))
}

# --- Economic activity rate ---
cat("\nFetching economic activity rate (var 18)...\n")
aps_econ_active_list <- list()
for (yr in 2004:2019) {
  cat("  Year", yr, "...")
  chunk <- tryCatch({
    nomis_fetch("NM_17_5", params = list(
      geography = "TYPE464",
      variable = "18",
      time = as.character(yr),
      measures = "20599"
    ))
  }, error = function(e) tibble())
  if (nrow(chunk) > 0) {
    aps_econ_active_list <- c(aps_econ_active_list, list(chunk))
    cat(nrow(chunk), "rows\n")
  } else {
    cat("no data\n")
  }
  Sys.sleep(0.5)
}
aps_econ_active <- bind_rows(aps_econ_active_list)

if (nrow(aps_econ_active) > 0) {
  cat("Economic activity data:", nrow(aps_econ_active), "rows\n")
  write_csv(aps_econ_active, file.path(DATA_DIR, "aps_econ_activity_raw.csv"))
}

###############################################################################
# 3. Claimant Count (monthly, for first-stage verification)
###############################################################################

cat("\n=== Fetching Claimant Count data ===\n")

# NM_162_1 didn't work earlier. Try the older JSA dataset.
# NM_1_1: JSA Claimant Count (pre-UC baseline)

cat("Fetching JSA Claimant Count by year...\n")
jsa_list <- list()
for (yr in 2010:2019) {
  cat("  Year", yr, "...")
  chunk <- tryCatch({
    nomis_fetch("NM_1_1", params = list(
      geography = "TYPE464",
      time = paste0(yr, "-01,", yr, "-04,", yr, "-07,", yr, "-10"),
      sex = "0",
      age = "0",
      duration = "0",
      measures = "20100"
    ))
  }, error = function(e) tibble())
  if (nrow(chunk) > 0) {
    jsa_list <- c(jsa_list, list(chunk))
    cat(nrow(chunk), "rows\n")
  } else {
    cat("no data\n")
  }
  Sys.sleep(0.5)
}
jsa_data <- bind_rows(jsa_list)

if (nrow(jsa_data) > 0) {
  cat("JSA data:", nrow(jsa_data), "rows\n")
  write_csv(jsa_data, file.path(DATA_DIR, "jsa_claimants_raw.csv"))
}

###############################################################################
# 4. BRES for sector employment
###############################################################################

cat("\n=== Fetching BRES sector employment ===\n")

# Already fetched earlier, check if it's adequate
if (file.exists(file.path(DATA_DIR, "bres_raw.csv"))) {
  bres <- read_csv(file.path(DATA_DIR, "bres_raw.csv"), show_col_types = FALSE)
  cat("BRES data already exists:", nrow(bres), "rows\n")
} else {
  bres_data <- nomis_fetch("NM_189_1", params = list(
    geography = "TYPE464",
    time = "2010-2019",
    industry = "37748736",
    employment_status = "1,2",
    measures = "20100"
  ))
  if (nrow(bres_data) > 0) {
    write_csv(bres_data, file.path(DATA_DIR, "bres_raw.csv"))
    cat("BRES data:", nrow(bres_data), "rows\n")
  }
}

###############################################################################
# 5. Business counts (enterprises by LA) — filter from existing data
###############################################################################

cat("\n=== Processing business counts ===\n")

if (file.exists(file.path(DATA_DIR, "business_counts_raw.csv"))) {
  # The full file is huge (568K rows). Read and filter for what we need.
  biz <- read_csv(file.path(DATA_DIR, "business_counts_raw.csv"),
                  show_col_types = FALSE)

  # Keep just total by LA by year
  if ("LEGAL_STATUS_NAME" %in% names(biz)) {
    biz_summary <- biz %>%
      filter(grepl("total|all", LEGAL_STATUS_NAME, ignore.case = TRUE) |
             grepl("sole", LEGAL_STATUS_NAME, ignore.case = TRUE))
    write_csv(biz_summary, file.path(DATA_DIR, "business_counts_filtered.csv"))
    cat("Filtered business counts:", nrow(biz_summary), "rows\n")
  } else {
    cat("Business counts columns:", paste(names(biz)[1:15], collapse = ", "), "\n")
  }
}

###############################################################################
# 6. Population estimates from ONS
###############################################################################

cat("\n=== Fetching population estimates ===\n")

# Try NOMIS mid-year population estimates
# NM_2002_1: Population estimates - small area based

pop_list <- list()
for (yr in 2010:2019) {
  cat("  Year", yr, "...")
  chunk <- tryCatch({
    nomis_fetch("NM_2002_1", params = list(
      geography = "TYPE464",
      time = as.character(yr),
      sex = "0",
      age = "0",
      measures = "20100"
    ))
  }, error = function(e) tibble())
  if (nrow(chunk) > 0) {
    pop_list <- c(pop_list, list(chunk))
    cat(nrow(chunk), "rows\n")
  } else {
    cat("no data\n")
  }
  Sys.sleep(0.5)
}
pop_data <- bind_rows(pop_list)

if (nrow(pop_data) > 0) {
  cat("Population data:", nrow(pop_data), "rows\n")
  write_csv(pop_data, file.path(DATA_DIR, "population_raw.csv"))
}

###############################################################################
# Summary
###############################################################################

cat("\n=== Final Data Summary ===\n")
files <- list.files(DATA_DIR, pattern = "\\.csv$")
for (f in files) {
  sz <- file.size(file.path(DATA_DIR, f))
  cat(sprintf("  %-45s  %8s bytes\n", f, format(sz, big.mark = ",")))
}
cat("\nTotal CSV files:", length(files), "\n")
