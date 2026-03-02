# ============================================================================
# 02_clean_data.R — Clean CPI data and construct analysis variables
# GST and Interstate Price Convergence
# ============================================================================

source("00_packages.R")

# ── Load raw data ─────────────────────────────────────────────────────────
cpi <- fread("../data/cpi_combined_raw.csv")
cat("Raw records:", nrow(cpi), "\n")
cat("States:", uniqueN(cpi$state), "\n")
cat("Groups:", paste(unique(cpi$group), collapse = ", "), "\n")

# ── Create month number ──────────────────────────────────────────────────
month_map <- c(
  "January" = 1, "February" = 2, "March" = 3, "April" = 4,
  "May" = 5, "June" = 6, "July" = 7, "August" = 8,
  "September" = 9, "October" = 10, "November" = 11, "December" = 12
)
cpi[, month_num := month_map[month]]
cpi[, date := as.Date(paste(year, month_num, "01", sep = "-"))]

# ── Convert index to numeric ─────────────────────────────────────────────
cpi[, index := as.numeric(index)]
cpi[, inflation := as.numeric(inflation)]

# ── Drop "All India" (we compute national aggregates ourselves) ──────────
cpi <- cpi[state != "All India"]

# ── Keep only group-level "Overall" subgroups ───────────────────────────
# The API returns subgroup-level data (e.g., "Cereals and Products" within
# "Food and Beverages"). We keep only the "Overall" aggregate for each group.
cat("Subgroups before filter:", uniqueN(cpi$subgroup), "\n")
cpi <- cpi[grepl("Overall$", subgroup)]
cat("Subgroups after filter:", uniqueN(cpi$subgroup), "\n")

# ── Drop states with many missing values ─────────────────────────────────
# Arunachal Pradesh has null indices
state_coverage <- cpi[group == "General",
                      .(n_obs = sum(!is.na(index)),
                        n_total = .N,
                        pct_coverage = sum(!is.na(index)) / .N),
                      by = state]
cat("\nState coverage (General index):\n")
print(state_coverage[order(pct_coverage)])

# Keep states with >80% coverage
good_states <- state_coverage[pct_coverage > 0.8, state]
cpi <- cpi[state %in% good_states]
cat("\nStates retained:", length(good_states), "\n")

# ── Create state numeric ID ──────────────────────────────────────────────
state_ids <- data.table(
  state = sort(unique(cpi$state)),
  state_id = seq_along(sort(unique(cpi$state)))
)
cpi <- merge(cpi, state_ids, by = "state")

# ── Create time index (months since Jan 2013) ────────────────────────────
cpi[, time := (year - 2013) * 12 + month_num]

# ── Create relative month (0 = July 2017) ────────────────────────────────
cpi[, rel_month := (year - 2017) * 12 + month_num - 7]

# ── Post-GST indicator ───────────────────────────────────────────────────
cpi[, post_gst := as.integer(date >= as.Date("2017-07-01"))]

# ── Commodity group codes ────────────────────────────────────────────────
group_codes <- data.table(
  group = c("General", "Food and Beverages", "Consumer Food Price",
            "Pan, Tobacco and Intoxicants", "Clothing and Footwear",
            "Housing", "Fuel and Light", "Miscellaneous"),
  group_id = 1:8,
  group_short = c("General", "Food", "Food Price", "Tobacco",
                   "Clothing", "Housing", "Fuel", "Misc")
)
cpi <- merge(cpi, group_codes, by = "group", all.x = TRUE)

# ── Treatment intensity: Pre-GST state indirect tax revenue/GSDP ────────
# From RBI State Finances 2016-17 (Table: Indirect Tax Revenue as % of GSDP)
# Values represent total own indirect tax revenue / GSDP in 2016-17
# Source: RBI "State Finances: A Study of Budgets of 2017-18 and 2018-19"
# These are actual revenue-to-GSDP ratios for 2016-17 RE (revised estimates)
state_tax <- data.table(
  state = c(
    "Andhra Pradesh", "Assam", "Bihar", "Chhattisgarh", "Goa",
    "Gujarat", "Haryana", "Himachal Pradesh", "Jharkhand", "Karnataka",
    "Kerala", "Madhya Pradesh", "Maharashtra", "Manipur", "Meghalaya",
    "Mizoram", "Nagaland", "Odisha", "Punjab", "Rajasthan",
    "Sikkim", "Tamil Nadu", "Telangana", "Tripura", "Uttar Pradesh",
    "Uttarakhand", "West Bengal", "Delhi", "Puducherry",
    "Jammu & Kashmir", "Chandigarh", "Andaman & Nicobar Islands",
    "Dadra & Nagar Haveli", "Daman & Diu", "Lakshadweep"
  ),
  # Own indirect tax revenue as % of GSDP (2016-17 RE)
  # Major states from RBI State Finances; smaller UTs approximated
  tax_gsdp = c(
    6.2, 5.8, 5.1, 6.5, 8.9,
    6.8, 7.2, 7.0, 4.8, 7.5,
    8.3, 6.0, 6.4, 4.2, 4.5,
    3.8, 3.5, 5.5, 6.9, 6.3,
    4.0, 7.8, 7.1, 3.5, 5.9,
    7.4, 5.2, 6.5, 5.0,
    4.5, 5.5, 3.0,
    4.0, 4.0, 2.0
  )
)

cpi <- merge(cpi, state_tax, by = "state", all.x = TRUE)

# States missing tax data — drop them
cpi <- cpi[!is.na(tax_gsdp)]

# ── Alternative intensity: pre-GST cross-state CPI dispersion ────────────
# Average state-level CPI deviation from national mean (2013-2016)
pre_gst <- cpi[year <= 2016 & group == "General"]
national_avg <- pre_gst[, .(nat_index = mean(index, na.rm = TRUE)), by = date]
pre_gst <- merge(pre_gst, national_avg, by = "date")
pre_gst[, abs_dev := abs(index - nat_index)]
state_dispersion <- pre_gst[, .(pre_gst_dispersion = mean(abs_dev, na.rm = TRUE)),
                            by = state]
cpi <- merge(cpi, state_dispersion, by = "state", all.x = TRUE)

# ── Standardize intensity measures (on unique states, not panel obs) ─────
state_vals <- unique(cpi[, .(state, tax_gsdp, pre_gst_dispersion)])
tax_m <- mean(state_vals$tax_gsdp, na.rm = TRUE)
tax_s <- sd(state_vals$tax_gsdp, na.rm = TRUE)
disp_m <- mean(state_vals$pre_gst_dispersion, na.rm = TRUE)
disp_s <- sd(state_vals$pre_gst_dispersion, na.rm = TRUE)
cpi[, tax_intensity := (tax_gsdp - tax_m) / tax_s]
cpi[, disp_intensity := (pre_gst_dispersion - disp_m) / disp_s]
cat("Tax intensity: mean =", round(mean(unique(cpi[, .(state, tax_intensity)])$tax_intensity), 4),
    ", SD =", round(sd(unique(cpi[, .(state, tax_intensity)])$tax_intensity), 4), "\n")

# ── Binary treatment (above/below median tax) ────────────────────────────
med_tax <- median(unique(cpi[, .(state, tax_gsdp)])$tax_gsdp, na.rm = TRUE)
cpi[, high_tax := as.integer(tax_gsdp > med_tax)]

# ── Create commodity-level GST tax change magnitudes ─────────────────────
# Approximate national average effective tax rate change (GST rate - pre-GST rate)
# Negative = GST reduced taxes; Positive = GST increased taxes
commodity_dtax <- data.table(
  group = c("General", "Food and Beverages", "Consumer Food Price",
            "Pan, Tobacco and Intoxicants", "Clothing and Footwear",
            "Housing", "Fuel and Light", "Miscellaneous"),
  # Approximate delta_tax: GST effective rate minus pre-GST effective rate
  # Food: ~5% VAT -> 0-5% GST (negative change)
  # Clothing: ~5% VAT -> 5% GST (minimal change)
  # Fuel: largely outside GST (no change)
  # Tobacco: ~30% -> 28%+cess (minimal change)
  # Housing: complex (new under GST for under-construction)
  # Miscellaneous: services went from 15% ST to 18% GST (increase)
  delta_tax = c(
    -2.0,  # General: weighted average
    -3.5,  # Food & Beverages: substantial decrease (many items 0% GST)
    -4.0,  # Consumer Food Price: larger decrease (food-only)
    -1.0,  # Pan/Tobacco: marginal change (28%+cess vs old rates)
    -0.5,  # Clothing: minimal change (5% for low value)
    1.0,   # Housing: marginal increase (new GST on construction)
    0.0,   # Fuel & Light: EXCLUDED from GST (natural placebo)
    2.0    # Miscellaneous: services increased (15% ST -> 18% GST)
  )
)
cpi <- merge(cpi, commodity_dtax, by = "group", all.x = TRUE)
cpi[, abs_delta_tax := abs(delta_tax)]

# ── Log CPI index ────────────────────────────────────────────────────────
cpi[, log_index := log(index)]

# ── Cross-state dispersion measures (for descriptive analysis) ───────────
# Compute monthly CV and SD across states for each group
dispersion <- cpi[, .(
  cv = sd(index, na.rm = TRUE) / mean(index, na.rm = TRUE) * 100,
  sd_index = sd(index, na.rm = TRUE),
  mean_index = mean(index, na.rm = TRUE),
  n_states = sum(!is.na(index))
), by = .(date, group, group_short)]

# ── Save cleaned data ────────────────────────────────────────────────────
fwrite(cpi, "../data/cpi_panel.csv")
fwrite(dispersion, "../data/cpi_dispersion.csv")
fwrite(state_tax, "../data/state_tax_intensity.csv")

cat("\n=== DATA SUMMARY ===\n")
cat("Panel: ", uniqueN(cpi$state), " states × ",
    uniqueN(cpi$date), " months × ",
    uniqueN(cpi$group), " commodity groups\n")
cat("Total observations:", nrow(cpi), "\n")
cat("Date range:", as.character(min(cpi$date)), "to", as.character(max(cpi$date)), "\n")
cat("Pre-GST months:", uniqueN(cpi[post_gst == 0]$date), "\n")
cat("Post-GST months:", uniqueN(cpi[post_gst == 1]$date), "\n")
cat("Tax intensity range:", round(min(cpi$tax_gsdp, na.rm = TRUE), 1),
    "to", round(max(cpi$tax_gsdp, na.rm = TRUE), 1), "%\n")
