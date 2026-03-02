###############################################################################
# 01b_refetch_htm.R — Re-fetch poverty and SNAP with CORRECT series IDs
# Bug fix: State abbreviation was hardcoded as "CA" — now uses each state's abbr
###############################################################################

source("00_packages.R")

state_info <- readRDS("../data/state_info.rds")

# ===========================================================================
# POVERTY RATES
# Format: PPAA{STATE_ABBR}{FIPS5}A156NCEN
# Example: PPAAAL01000A156NCEN (Alabama), PPAACA06000A156NCEN (California)
# ===========================================================================
cat("Fetching state poverty rates (corrected IDs)...\n")

pov_list <- list()
for (i in 1:nrow(state_info)) {
  fips <- state_info$fips[i]
  abbr <- state_info$abbr[i]
  fips5 <- paste0(fips, "000")
  series_id <- paste0("PPAA", abbr, fips5, "A156NCEN")

  tryCatch({
    obs <- fredr(
      series_id = series_id,
      observation_start = as.Date("1989-01-01"),
      observation_end = as.Date("2024-01-01")
    )
    if (nrow(obs) > 0) {
      pov_list[[fips]] <- obs %>%
        select(date, value) %>%
        mutate(state_fips = fips, poverty_rate = value / 100) %>%
        select(date, state_fips, poverty_rate)
      cat(sprintf("  %s: %d obs\n", state_info$name[i], nrow(obs)))
    }
  }, error = function(e) {
    cat(sprintf("  FAILED %s (%s): %s\n", state_info$name[i], series_id, e$message))
  })

  Sys.sleep(0.6)
}

state_poverty <- bind_rows(pov_list) %>%
  mutate(year = year(date))

cat(sprintf("\nPoverty: %d obs, %d states\n",
            nrow(state_poverty), n_distinct(state_poverty$state_fips)))

saveRDS(state_poverty, "../data/state_poverty.rds")

# ===========================================================================
# SNAP RECIPIENCY
# Format: BR{FIPS5}{STATE_ABBR}A647NCEN
# Example: BR01000ALA647NCEN (Alabama), BR06000CAA647NCEN (California)
# ===========================================================================
cat("\nFetching SNAP recipiency (corrected IDs)...\n")

snap_list <- list()
for (i in 1:nrow(state_info)) {
  fips <- state_info$fips[i]
  abbr <- state_info$abbr[i]
  fips5 <- paste0(fips, "000")
  series_id <- paste0("BR", fips5, abbr, "A647NCEN")

  tryCatch({
    obs <- fredr(
      series_id = series_id,
      observation_start = as.Date("1989-01-01"),
      observation_end = as.Date("2024-01-01")
    )
    if (nrow(obs) > 0) {
      snap_list[[fips]] <- obs %>%
        select(date, value) %>%
        mutate(state_fips = fips, snap_recipients = value) %>%
        select(date, state_fips, snap_recipients)
      cat(sprintf("  %s: %d obs\n", state_info$name[i], nrow(obs)))
    }
  }, error = function(e) {
    cat(sprintf("  FAILED %s (%s): %s\n", state_info$name[i], series_id, e$message))
  })

  Sys.sleep(0.6)
}

state_snap <- bind_rows(snap_list) %>%
  mutate(year = year(date))

cat(sprintf("\nSNAP: %d obs, %d states\n",
            nrow(state_snap), n_distinct(state_snap$state_fips)))

saveRDS(state_snap, "../data/state_snap.rds")

cat("\n=== RE-FETCH COMPLETE ===\n")
