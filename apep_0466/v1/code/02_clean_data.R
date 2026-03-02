## ============================================================================
## 02_clean_data.R — Variable construction
## APEP-0466: Municipal Population Thresholds and Firm Creation in France
## ============================================================================

source("00_packages.R")

data_dir <- "../data"

# ===========================================================================
# 1. LOAD RAW DATA
# ===========================================================================
pop_panel <- fread(file.path(data_dir, "commune_population_panel.csv"))
sirene <- fread(file.path(data_dir, "sirene_creations.csv"))
stock <- fread(file.path(data_dir, "sirene_stock.csv"))

cat(sprintf("Population panel: %d rows\n", nrow(pop_panel)))
cat(sprintf("Sirene creations: %d rows\n", nrow(sirene)))
cat(sprintf("Stock data: %d communes\n", nrow(stock)))

# ===========================================================================
# 2. DEFINE GOVERNANCE THRESHOLDS
# ===========================================================================

# Council size brackets (Article L2121-2 CGCT)
council_brackets <- data.table(
  pop_min = c(0, 100, 500, 1500, 2500, 3500, 5000, 10000, 20000, 30000, 40000, 50000),
  pop_max = c(99, 499, 1499, 2499, 3499, 4999, 9999, 19999, 29999, 39999, 49999, 59999),
  council_size = c(9, 11, 15, 19, 23, 27, 29, 33, 35, 39, 43, 45)
)

# Mayor salary brackets (Article L2123-23 CGCT, 2024 values in EUR/month)
salary_brackets <- data.table(
  pop_min = c(0, 500, 1000, 3500, 10000, 20000, 50000, 100000),
  pop_max = c(499, 999, 3499, 9999, 19999, 49999, 99999, 999999),
  mayor_salary = c(1042, 1647, 2108, 2247, 2656, 3677, 4495, 5925)
)

# Electoral system (proportional list voting threshold)
# Pre-2013: 3500; Post-2013 (elections from 2014): 1000
electoral_threshold_pre2013 <- 3500
electoral_threshold_post2013 <- 1000

# Key thresholds for RDD analysis
rdd_thresholds <- c(500, 1000, 1500, 3500, 10000)

# ===========================================================================
# 3. ASSIGN GOVERNANCE VARIABLES
# ===========================================================================

assign_council <- function(pop) {
  sapply(pop, function(p) {
    idx <- which(council_brackets$pop_min <= p & council_brackets$pop_max >= p)
    if (length(idx) == 0) return(NA_integer_)
    council_brackets$council_size[idx[1]]
  })
}

assign_salary <- function(pop) {
  sapply(pop, function(p) {
    idx <- which(salary_brackets$pop_min <= p & salary_brackets$pop_max >= p)
    if (length(idx) == 0) return(NA_real_)
    salary_brackets$mayor_salary[idx[1]]
  })
}

assign_proportional <- function(pop, year) {
  threshold <- ifelse(year >= 2014, electoral_threshold_post2013, electoral_threshold_pre2013)
  as.integer(pop >= threshold)
}

# ===========================================================================
# 4. BUILD ANALYSIS PANEL
# ===========================================================================

# Use most recent population for cross-sectional RDD
pop_cross <- pop_panel[data_year == max(data_year)]
pop_cross <- pop_cross[!is.na(population) & population > 0]

# Remove overseas territories (dep_code >= 97)
pop_cross <- pop_cross[!grepl("^97", dep_code)]
# Remove Paris, Lyon, Marseille (special governance regimes)
pop_cross <- pop_cross[!code_insee %in% c("75056", "69123", "13055")]

# Merge with Sirene creation data
panel <- merge(
  pop_cross[, .(code_insee, commune_name, population, superficie_km2,
                densite, dep_code, reg_code)],
  sirene,
  by = "code_insee",
  all.x = FALSE  # Keep only communes with Sirene data
)

# Assign governance variables
panel[, council_size := assign_council(population)]
panel[, mayor_salary := assign_salary(population)]
panel[, proportional := assign_proportional(population, year)]

# Compute per-capita rates
panel[, creation_rate := n_creations / population * 1000]  # per 1,000 inhabitants

# Drop election years (partial exposure: 2008, 2014, 2020)
panel[, election_year := year %in% c(2008, 2014, 2020)]

# Compute distance to nearest threshold (normalized)
panel[, `:=`(
  dist_500 = population - 500,
  dist_1000 = population - 1000,
  dist_1500 = population - 1500,
  dist_3500 = population - 3500,
  dist_10000 = population - 10000
)]

# Nearest threshold and normalized distance
panel[, nearest_threshold := sapply(population, function(p) {
  rdd_thresholds[which.min(abs(p - rdd_thresholds))]
})]
panel[, dist_nearest := population - nearest_threshold]
panel[, above_nearest := as.integer(dist_nearest >= 0)]

# Log population (for some specifications)
panel[, log_pop := log(population)]
panel[, log_area := log(superficie_km2 + 1)]

# Merge stock data
panel <- merge(panel, stock, by = "code_insee", all.x = TRUE)
panel[, stock_rate := n_active / population * 1000]

# ===========================================================================
# 5. CONSTRUCT PERIOD VARIABLES
# ===========================================================================

# Electoral cycle periods
panel[, period := fcase(
  year >= 2009 & year <= 2013, "2008-2014",
  year >= 2015 & year <= 2019, "2014-2020",
  year >= 2021 & year <= 2024, "2020-2026",
  default = "election_year"
)]

# Pre/post 2013 reform (for DiDisc at 3500)
panel[, post_reform := as.integer(year >= 2014)]

# ===========================================================================
# 6. SUMMARY STATISTICS
# ===========================================================================

cat("\n=== Panel Summary ===\n")
cat(sprintf("Communes: %d\n", uniqueN(panel$code_insee)))
cat(sprintf("Years: %d to %d\n", min(panel$year), max(panel$year)))
cat(sprintf("Observations: %d\n", nrow(panel)))

# Summary by threshold proximity
for (thresh in rdd_thresholds) {
  bw <- thresh * 0.3
  near <- panel[abs(population - thresh) <= bw & election_year == FALSE]
  if (nrow(near) > 0) {
    cat(sprintf("\nThreshold %d (±%.0f): %d communes, avg creation rate = %.1f\n",
                thresh, bw, uniqueN(near$code_insee), mean(near$creation_rate, na.rm = TRUE)))
    cat(sprintf("  Below: avg pop = %.0f, avg creations = %.1f\n",
                mean(near[population < thresh]$population),
                mean(near[population < thresh]$creation_rate, na.rm = TRUE)))
    cat(sprintf("  Above: avg pop = %.0f, avg creations = %.1f\n",
                mean(near[population >= thresh]$population),
                mean(near[population >= thresh]$creation_rate, na.rm = TRUE)))
  }
}

# ===========================================================================
# 7. SAVE ANALYSIS PANEL
# ===========================================================================

fwrite(panel, file.path(data_dir, "analysis_panel.csv"))
cat(sprintf("\nAnalysis panel saved: %d rows\n", nrow(panel)))

# Also save cross-sectional means (for figures)
commune_means <- panel[election_year == FALSE, .(
  mean_creation_rate = mean(creation_rate, na.rm = TRUE),
  mean_creations = mean(n_creations, na.rm = TRUE),
  total_creations = sum(n_creations, na.rm = TRUE),
  n_years = .N
), by = .(code_insee, population, council_size, mayor_salary, dep_code,
          superficie_km2, densite)]

fwrite(commune_means, file.path(data_dir, "commune_means.csv"))
cat(sprintf("Commune means saved: %d communes\n", nrow(commune_means)))
