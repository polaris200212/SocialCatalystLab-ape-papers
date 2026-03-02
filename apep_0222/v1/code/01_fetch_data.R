##############################################################################
# 01_fetch_data.R — Fetch QWI data from Census API
# APEP-0221: Educational Content Restriction Laws and Teacher Labor Markets
##############################################################################

source("00_packages.R")

cat("=== Fetching QWI data from Census Bureau API ===\n")

# All 51 state FIPS (50 states + DC)
all_states <- paste0(
  "01,02,04,05,06,08,09,10,11,12,13,15,16,17,18,19,20,21,22,23,24,25,",
  "26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,44,45,46,47,48,",
  "49,50,51,53,54,55,56"
)

# Variables to fetch
qwi_vars <- "Emp,EarnS,HirA,Sep,FrmJbC,FrmJbLs,Payroll,TurnOvrS"

# Industries: Education (61), Healthcare (62), All (00), Retail (44-45), Manufacturing (31-33)
industries <- c("61", "62", "00", "44-45", "31-33")
industry_labels <- c("Education", "Healthcare", "All Industries", "Retail", "Manufacturing")

# Years and quarters
years <- 2015:2024
quarters <- 1:4

# Function to fetch one batch
fetch_qwi_batch <- function(year, quarter, industry) {
  url <- paste0(
    "https://api.census.gov/data/timeseries/qwi/sa",
    "?get=", qwi_vars,
    "&for=state:", all_states,
    "&year=", year,
    "&quarter=", quarter,
    "&sex=0",
    "&industry=", industry,
    "&ownercode=A05",
    "&agegrp=A00"
  )

  tryCatch({
    resp <- GET(url, timeout(60))
    if (status_code(resp) == 200) {
      content_text <- content(resp, "text", encoding = "UTF-8")
      data <- fromJSON(content_text, flatten = TRUE)
      if (length(data) > 1) {
        df <- as.data.frame(data[-1, , drop = FALSE], stringsAsFactors = FALSE)
        names(df) <- data[1, ]
        return(df)
      }
    }
    return(NULL)
  }, error = function(e) {
    return(NULL)
  })
}

# Fetch all combinations
all_data <- list()
total_calls <- length(years) * length(quarters) * length(industries)
call_num <- 0
success <- 0

for (ind in industries) {
  for (yr in years) {
    for (qtr in quarters) {
      call_num <- call_num + 1
      if (call_num %% 50 == 0) {
        cat(sprintf("  Progress: %d/%d calls (%.0f%%), %d successful\n",
                    call_num, total_calls, 100 * call_num / total_calls, success))
      }

      result <- fetch_qwi_batch(yr, qtr, ind)
      if (!is.null(result) && nrow(result) > 0) {
        all_data[[length(all_data) + 1]] <- result
        success <- success + 1
      }

      Sys.sleep(0.1)  # Rate limiting
    }
  }
}

cat(sprintf("\nFetch complete: %d/%d successful calls\n", success, total_calls))

# Combine all data
qwi_raw <- bind_rows(all_data)

# Convert numeric columns
numeric_cols <- c("Emp", "EarnS", "HirA", "Sep", "FrmJbC", "FrmJbLs", "Payroll", "TurnOvrS")
for (col in numeric_cols) {
  qwi_raw[[col]] <- as.numeric(qwi_raw[[col]])
}
qwi_raw$year <- as.integer(qwi_raw$year)
qwi_raw$quarter <- as.integer(qwi_raw$quarter)

# Create time variable (year-quarter as numeric)
qwi_raw <- qwi_raw %>%
  mutate(
    state_fips = state,
    time_q = year + (quarter - 1) / 4,
    yq = paste0(year, "Q", quarter)
  )

# Add industry labels
qwi_raw <- qwi_raw %>%
  mutate(industry_label = case_when(
    industry == "61" ~ "Education",
    industry == "62" ~ "Healthcare",
    industry == "00" ~ "All Industries",
    industry == "44-45" ~ "Retail",
    industry == "31-33" ~ "Manufacturing",
    TRUE ~ industry
  ))

cat(sprintf("Raw QWI data: %d rows, %d states, %d industries\n",
            nrow(qwi_raw), n_distinct(qwi_raw$state_fips), n_distinct(qwi_raw$industry)))
cat(sprintf("Year range: %d-%d\n", min(qwi_raw$year), max(qwi_raw$year)))

# Save raw data
saveRDS(qwi_raw, "../data/qwi_raw.rds")
cat("Saved: ../data/qwi_raw.rds\n")

# Also fetch QWI by sex for education sector (gender composition analysis)
cat("\n=== Fetching QWI by sex for education sector ===\n")

sex_data <- list()
sex_calls <- 0
for (yr in years) {
  for (qtr in quarters) {
    for (sx in c("1", "2")) {  # 1=Male, 2=Female
      sex_calls <- sex_calls + 1
      result <- fetch_qwi_batch(yr, qtr, "61")
      # Actually need sex-specific call
      url <- paste0(
        "https://api.census.gov/data/timeseries/qwi/sa",
        "?get=Emp,EarnS,HirA,Sep",
        "&for=state:", all_states,
        "&year=", yr,
        "&quarter=", qtr,
        "&sex=", sx,
        "&industry=61",
        "&ownercode=A05",
        "&agegrp=A00"
      )
      tryCatch({
        resp <- GET(url, timeout(60))
        if (status_code(resp) == 200) {
          content_text <- content(resp, "text", encoding = "UTF-8")
          data <- fromJSON(content_text, flatten = TRUE)
          if (length(data) > 1) {
            df <- as.data.frame(data[-1, , drop = FALSE], stringsAsFactors = FALSE)
            names(df) <- data[1, ]
            sex_data[[length(sex_data) + 1]] <- df
          }
        }
      }, error = function(e) { })
      Sys.sleep(0.1)
    }
  }
}

if (length(sex_data) > 0) {
  qwi_sex <- bind_rows(sex_data)
  for (col in c("Emp", "EarnS", "HirA", "Sep")) {
    qwi_sex[[col]] <- as.numeric(qwi_sex[[col]])
  }
  qwi_sex$year <- as.integer(qwi_sex$year)
  qwi_sex$quarter <- as.integer(qwi_sex$quarter)
  qwi_sex <- qwi_sex %>%
    mutate(
      state_fips = state,
      sex_label = ifelse(sex == "1", "Male", "Female"),
      time_q = year + (quarter - 1) / 4
    )
  saveRDS(qwi_sex, "../data/qwi_education_by_sex.rds")
  cat(sprintf("Saved sex-disaggregated education data: %d rows\n", nrow(qwi_sex)))
}

cat("\n=== Data fetch complete ===\n")
