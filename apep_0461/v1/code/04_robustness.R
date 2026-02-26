## 04_robustness.R — Robustness checks
## apep_0461: Oil Dependence and Child Survival

source("00_packages.R")

cat("=== Loading panel data ===\n")
panel <- readRDS("../data/panel_dev.rds")
panel_full <- readRDS("../data/panel_full.rds")

# ============================================================
# 1. Including OECD countries
# ============================================================
cat("\n=== Robustness 1: Including OECD ===\n")

r1 <- feols(u5_mortality ~ treatment_continuous + log_gdppc + pop_growth + urban_pct |
              iso3c + year,
            data = panel_full, cluster = ~iso3c)
cat("  Including OECD: "); print(coeftable(r1)["treatment_continuous",])

# ============================================================
# 2. Dropping top 5 oil exporters
# ============================================================
cat("\n=== Robustness 2: Dropping top 5 oil exporters ===\n")

top5_oil <- panel %>%
  filter(year == 2013) %>%
  slice_max(oil_rents_pre, n = 5) %>%
  pull(iso3c)

cat(sprintf("  Dropped: %s\n", paste(top5_oil, collapse = ", ")))

r2 <- feols(u5_mortality ~ treatment_continuous + log_gdppc + pop_growth + urban_pct |
              iso3c + year,
            data = filter(panel, !iso3c %in% top5_oil), cluster = ~iso3c)
cat("  Without top 5: "); print(coeftable(r2)["treatment_continuous",])

# ============================================================
# 3. Alternative treatment: Total resource rents (not just oil)
# ============================================================
cat("\n=== Robustness 3: Total resource rents ===\n")

panel <- panel %>%
  mutate(treatment_total_rents = total_rents_pre * post2014)

r3 <- feols(u5_mortality ~ treatment_total_rents + log_gdppc + pop_growth + urban_pct |
              iso3c + year,
            data = panel, cluster = ~iso3c)
cat("  Total rents: "); print(coeftable(r3)["treatment_total_rents",])

# ============================================================
# 4. Placebo test: Use 2010 as fake treatment date
# ============================================================
cat("\n=== Robustness 4: Placebo test (2010 fake treatment) ===\n")

panel_placebo <- panel %>%
  filter(year >= 2005, year <= 2013) %>%
  mutate(
    post2010 = as.integer(year >= 2010),
    treatment_placebo = oil_rents_pre * post2010
  )

r4 <- feols(u5_mortality ~ treatment_placebo + log_gdppc + pop_growth + urban_pct |
              iso3c + year,
            data = panel_placebo, cluster = ~iso3c)
cat("  Placebo (2010): "); print(coeftable(r4)["treatment_placebo",])

# ============================================================
# 5. Placebo outcome: Adult literacy (slow-moving)
# ============================================================
cat("\n=== Robustness 5: Placebo outcome (urban %) ===\n")

# Urban % is slow-moving and shouldn't respond to short-run fiscal shocks
r5 <- feols(urban_pct ~ treatment_continuous |
              iso3c + year,
            data = panel, cluster = ~iso3c)
cat("  Placebo outcome (urban %): "); print(coeftable(r5)["treatment_continuous",])

# ============================================================
# 6. Region-specific estimates
# ============================================================
cat("\n=== Robustness 6: Region-specific estimates ===\n")

regions <- unique(panel$region[!is.na(panel$region)])
region_results <- map_dfr(regions, function(reg) {
  d <- filter(panel, region == reg)
  if (n_distinct(d$iso3c) < 10 || sum(d$oil_rents_pre > 5, na.rm = TRUE) < 5) {
    return(tibble(region = reg, estimate = NA, se = NA, n_countries = n_distinct(d$iso3c)))
  }
  m <- tryCatch(
    feols(u5_mortality ~ treatment_continuous + log_gdppc + pop_growth + urban_pct |
            iso3c + year, data = d, cluster = ~iso3c),
    error = function(e) NULL
  )
  if (is.null(m)) return(tibble(region = reg, estimate = NA, se = NA, n_countries = n_distinct(d$iso3c)))
  ct <- coeftable(m)["treatment_continuous",]
  tibble(region = reg, estimate = ct[1], se = ct[2], n_countries = n_distinct(d$iso3c))
})

cat("  Region-specific results:\n")
print(region_results)

# ============================================================
# 7. Sensitivity to time window
# ============================================================
cat("\n=== Robustness 7: Time window sensitivity ===\n")

windows <- list(
  "2005-2020" = c(2005, 2020),
  "2005-2018" = c(2005, 2018),
  "2008-2023" = c(2008, 2023),
  "2010-2023" = c(2010, 2023)
)

window_results <- map_dfr(names(windows), function(w) {
  yrs <- windows[[w]]
  d <- filter(panel, year >= yrs[1], year <= yrs[2])
  m <- feols(u5_mortality ~ treatment_continuous + log_gdppc + pop_growth + urban_pct |
               iso3c + year, data = d, cluster = ~iso3c)
  ct <- coeftable(m)["treatment_continuous",]
  tibble(window = w, estimate = ct[1], se = ct[2], p_value = ct[4])
})

cat("  Time window results:\n")
print(window_results)

# ============================================================
# 8. Interaction with sovereign wealth fund
# ============================================================
cat("\n=== Robustness 8: Sovereign wealth fund interaction ===\n")

# Countries with major SWFs (as of 2014)
swf_countries <- c("NOR", "ARE", "KWT", "SAU", "QAT", "SGP", "CHN", "RUS",
                    "KAZ", "LBY", "IRN", "DZA", "BRN", "BHR", "OMN", "TTO",
                    "TLS", "AGO", "NGA", "GHA", "BWA", "GAB")

panel <- panel %>%
  mutate(
    has_swf = as.integer(iso3c %in% swf_countries),
    treatment_swf = treatment_continuous * has_swf,
    treatment_no_swf = treatment_continuous * (1 - has_swf)
  )

r8 <- feols(u5_mortality ~ treatment_continuous + treatment_swf +
              log_gdppc + pop_growth + urban_pct |
              iso3c + year,
            data = panel, cluster = ~iso3c)
cat("  SWF interaction: "); print(coeftable(r8))

# ============================================================
# 9. Wild cluster bootstrap (few treated clusters concern)
# ============================================================
cat("\n=== Robustness 9: Cluster-robust inference check ===\n")

# Count effective clusters
n_clusters <- panel %>%
  filter(!is.na(treatment_continuous), !is.na(u5_mortality)) %>%
  summarise(
    total = n_distinct(iso3c),
    treated = n_distinct(iso3c[oil_rents_pre > 5])
  )
cat(sprintf("  Total clusters: %d, Treated clusters: %d\n",
            n_clusters$total, n_clusters$treated))

if (n_clusters$treated < 30) {
  cat("  WARNING: Fewer than 30 treated clusters. Consider wild bootstrap.\n")
}

# ============================================================
# Save robustness results
# ============================================================
robustness <- list(
  r1_oecd = r1, r2_notop5 = r2, r3_total_rents = r3,
  r4_placebo_time = r4, r5_placebo_outcome = r5,
  region_results = region_results,
  window_results = window_results,
  r8_swf = r8,
  cluster_info = n_clusters
)

saveRDS(robustness, "../data/robustness_results.rds")
saveRDS(panel, "../data/panel_dev.rds")  # Re-save with SWF variable

cat("\n=== Robustness checks complete ===\n")
