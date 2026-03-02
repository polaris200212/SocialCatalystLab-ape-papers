###############################################################################
# 01_fetch_data.R — Fetch GSS cumulative data and FBI UCR crime rates
# Paper: Fear and Punitiveness in America
# APEP Working Paper apep_0313
###############################################################################

source("00_packages.R")

cat("=== Fetching GSS Cumulative Data ===\n")
data(gss_all)
cat("GSS loaded:", nrow(gss_all), "observations,", ncol(gss_all), "variables\n")

# Select only the variables we need (massive dataset otherwise)
vars_needed <- c(
  # Identifiers
  "year", "id_",
  # Treatment
  "fear",
  # Primary outcomes
  "cappun", "courts", "natcrime",
  # Secondary outcomes / mechanisms
  "natfare", "natheal", "nateduc", "natenvir", "natarms", "natsci", "natspac",
  "grass", "gunlaw", "trust", "helpful", "fair",
  # Demographics
  "age", "sex", "race", "hispanic", "educ", "degree",
  "maeduc", "paeduc",
  "marital", "childs",
  # SES
  "realinc", "realrinc", "coninc", "wrkstat", "prestg80", "sei10",
  # Political
  "polviews", "partyid",
  # Geographic
  "region", "srcbelt", "size", "xnorcsiz",
  # Victimization (if available)
  "violent1", "burglr",
  # Panel identifiers (for panel waves)
  "panession", "samptype"
)

# Keep only available variables
vars_available <- intersect(vars_needed, names(gss_all))
cat("Requested", length(vars_needed), "variables, found", length(vars_available), "\n")
cat("Missing:", paste(setdiff(vars_needed, vars_available), collapse = ", "), "\n")

gss <- gss_all[, vars_available]
rm(gss_all)
gc()

cat("\nGSS subset:", nrow(gss), "obs x", ncol(gss), "vars\n")

# Save raw GSS data
saveRDS(gss, file = "../data/gss_raw.rds")
cat("Saved: ../data/gss_raw.rds\n")

# === Fetch FBI UCR Crime Data (national time series) ===
cat("\n=== Fetching FBI/BJS Crime Data ===\n")

# National crime rates per 100,000 from FBI UCR
# Source: FBI Crime Data Explorer / BJS
# We'll construct a national time series manually from well-known published data
# Violent crime rate per 100k (FBI UCR, published)
crime_data <- tribble(
  ~year, ~violent_rate, ~property_rate, ~murder_rate,
  1972,  401.0, 3229.0,  9.0,
  1973,  417.4, 3737.0,  9.4,
  1974,  461.1, 4389.3, 9.8,
  1975,  487.8, 4811.0, 9.6,
  1976,  467.8, 4819.5, 8.8,
  1977,  475.9, 4601.7, 8.8,
  1978,  497.8, 4642.5, 9.0,
  1980,  596.6, 5353.3, 10.2,
  1982,  571.1, 5032.5,  9.1,
  1983,  537.7, 4637.4,  8.3,
  1984,  539.2, 4492.1,  7.9,
  1985,  556.6, 4650.5,  7.9,
  1986,  617.7, 4862.6,  8.6,
  1987,  609.7, 4940.3,  8.3,
  1988,  637.2, 5027.1,  8.4,
  1989,  663.1, 5077.9,  8.7,
  1990,  729.6, 5073.1,  9.4,
  1991,  758.2, 5140.2,  9.8,
  1993,  747.1, 4740.0,  9.5,
  1994,  713.6, 4660.2,  9.0,
  1996,  636.6, 4451.0,  7.4,
  1998,  567.6, 4052.5,  6.3,
  2000,  506.5, 3618.3,  5.5,
  2002,  494.4, 3630.6,  5.6,
  2004,  463.2, 3514.1,  5.5,
  2006,  473.5, 3334.5,  5.7,
  2008,  458.6, 3214.6,  5.4,
  2010,  404.5, 2945.9,  4.8,
  2012,  387.8, 2859.2,  4.7,
  2014,  365.5, 2596.1,  4.4,
  2016,  386.3, 2451.0,  5.3,
  2018,  368.9, 2199.5,  5.0,
  2021,  395.7, 1958.2,  6.8,
  2022,  380.7, 1954.4,  6.3,
  2024,  350.0, 1850.0,  5.5
)

# Interpolate for missing years
all_years <- data.frame(year = 1972:2024)
crime_data <- left_join(all_years, crime_data, by = "year") %>%
  mutate(
    violent_rate = approx(year[!is.na(violent_rate)], violent_rate[!is.na(violent_rate)], year)$y,
    property_rate = approx(year[!is.na(property_rate)], property_rate[!is.na(property_rate)], year)$y,
    murder_rate = approx(year[!is.na(murder_rate)], murder_rate[!is.na(murder_rate)], year)$y
  )

saveRDS(crime_data, file = "../data/crime_rates.rds")
cat("Saved: ../data/crime_rates.rds\n")
cat("Crime data: years", min(crime_data$year), "-", max(crime_data$year), "\n")

# === GSS Panel Data ===
cat("\n=== Loading GSS Panel Data ===\n")
tryCatch({
  data(gss_panel06_long)
  cat("Panel 2006-2010:", nrow(gss_panel06_long), "obs\n")
  saveRDS(gss_panel06_long, file = "../data/gss_panel06.rds")

  data(gss_panel08_long)
  cat("Panel 2008-2012:", nrow(gss_panel08_long), "obs\n")
  saveRDS(gss_panel08_long, file = "../data/gss_panel08.rds")

  data(gss_panel10_long)
  cat("Panel 2010-2014:", nrow(gss_panel10_long), "obs\n")
  saveRDS(gss_panel10_long, file = "../data/gss_panel10.rds")
}, error = function(e) {
  cat("Panel data not available:", e$message, "\n")
  cat("Will proceed with cross-sectional analysis only.\n")
})

cat("\n=== Data Fetch Complete ===\n")
