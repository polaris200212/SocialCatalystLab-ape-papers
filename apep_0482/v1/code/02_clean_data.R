## ============================================================
## 02_clean_data.R — Parse and merge datasets
## Constructs: municipality-year panel with budget shares,
##             female councillor shares, population
## ============================================================

source("00_packages.R")

data_dir <- "../data"

## ----------------------------------------------------------
## 1. Parse CONPREL Budget Data
##    Program-level spending from tb_funcional + tb_inventario
## ----------------------------------------------------------

cat("=== Parsing CONPREL budget data ===\n")

budget_list <- list()

for (yr in 2010:2023) {
  inv_file  <- file.path(data_dir, "conprel", paste0("inventario_", yr, ".csv"))
  func_file <- file.path(data_dir, "conprel", paste0("funcional_", yr, ".csv"))

  if (!file.exists(func_file)) {
    cat("  Skipping year", yr, "(not downloaded)\n")
    next
  }

  # Read inventory (municipality master)
  inv <- fread(inv_file, encoding = "Latin-1")
  # Standardize column names (may vary across years)
  names(inv) <- tolower(trimws(names(inv)))

  # Extract 5-digit INE code from codente
  # Format: "PPMMM..." where PP=province, MMM=municipality
  if ("codente" %in% names(inv)) {
    inv[, ine_code := substr(trimws(codente), 1, 5)]
  } else if ("cdente" %in% names(inv)) {
    inv[, ine_code := substr(trimws(cdente), 1, 5)]
  }

  # Map entity ID to INE code
  id_col <- intersect(c("idente", "id", "codbdgel"), names(inv))[1]
  if (is.na(id_col)) {
    cat("  WARNING: Cannot find entity ID column in year", yr, "\n")
    next
  }

  inv_map <- inv[, .(idente = get(id_col), ine_code,
                      nombre = if ("nombreente" %in% names(inv)) nombreente
                               else if ("nombre" %in% names(inv)) nombre
                               else NA_character_,
                      poblacion = if ("poblacion" %in% names(inv)) poblacion
                                  else NA_real_)]

  # Read functional/program spending
  func <- fread(func_file, encoding = "Latin-1")
  names(func) <- tolower(trimws(names(func)))

  # Clean program code (remove trailing spaces)
  func[, program := trimws(as.character(cdfgr))]
  func[, program_3digit := substr(program, 1, 3)]
  func[, program_2digit := substr(program, 1, 2)]
  func[, program_1digit := substr(program, 1, 1)]

  # Clean economic chapter code
  func[, chapter := trimws(as.character(cdcta))]
  func[, chapter_1digit := substr(chapter, 1, 1)]

  # Merge with inventory to get INE codes
  func_id_col <- intersect(c("idente", "id"), names(func))[1]
  if (!is.na(func_id_col)) {
    func <- merge(func, inv_map[, .(idente, ine_code, poblacion)],
                  by.x = func_id_col, by.y = "idente", all.x = TRUE)
  }

  # Keep only municipal entities (filter out diputaciones, etc.)
  # Municipal codes are 5 digits; other entities have longer codes or different formats
  func <- func[!is.na(ine_code) & nchar(ine_code) == 5]

  func[, year := yr]
  budget_list[[as.character(yr)]] <- func

  cat("  Year", yr, ":", nrow(func), "records,",
      uniqueN(func$ine_code), "municipalities\n")
}

budget_raw <- rbindlist(budget_list, fill = TRUE)
cat("\nTotal budget records:", nrow(budget_raw), "\n")
cat("Unique municipalities:", uniqueN(budget_raw$ine_code), "\n")
cat("Years:", paste(sort(unique(budget_raw$year)), collapse = ", "), "\n")

## ----------------------------------------------------------
## 2. Construct Budget Shares
##    Primary outcomes: within-education composition
## ----------------------------------------------------------

cat("\n=== Constructing budget shares ===\n")

# Education programs (Area 3, Policy 32 in the program classification)
# 321: Infant and primary education centers
# 322: Secondary education
# 323: Infant/primary/special education operations
# 324: Non-regulated education
# 325: University education
# 326: Complementary education services (meals, transport, extracurricular)
# 327: Special education
# 328/329: Other education

# Check available columns in budget_raw
cat("Budget raw columns:", paste(names(budget_raw), collapse = ", "), "\n")

# Extract population lookup (one per municipality-year)
pop_lookup <- budget_raw[!is.na(poblacion),
  .(poblacion = as.numeric(poblacion[1])),
  by = .(ine_code, year)
]
cat("Population lookup:", nrow(pop_lookup), "municipality-years\n")

# Aggregate spending by municipality-year-program
muni_program <- budget_raw[,
  .(spending = sum(as.numeric(importe), na.rm = TRUE)),
  by = .(ine_code, year, program_3digit, program_2digit, program_1digit)
]

# Total education spending (policy group 32)
edu_spending <- muni_program[program_2digit == "32",
  .(total_edu = sum(spending, na.rm = TRUE)),
  by = .(ine_code, year)
]

# Education subcategories
edu_sub <- muni_program[program_2digit == "32",
  .(spending = sum(spending, na.rm = TRUE)),
  by = .(ine_code, year, program_3digit)
]

# Pivot wider
edu_wide <- dcast(edu_sub, ine_code + year ~ program_3digit,
                  value.var = "spending", fill = 0)

# Name the key programs
edu_cols <- names(edu_wide)[-(1:2)]
cat("Education program codes found:", paste(edu_cols, collapse = ", "), "\n")

# Merge with totals
edu_panel <- merge(edu_wide, edu_spending, by = c("ine_code", "year"))

# Compute shares (handle zero totals)
for (col in edu_cols) {
  share_col <- paste0("share_", col)
  edu_panel[, (share_col) := fifelse(total_edu > 0,
                                      get(col) / total_edu, NA_real_)]
}

# Total spending by municipality-year (all categories)
total_spending <- muni_program[,
  .(total_spending = sum(spending, na.rm = TRUE)),
  by = .(ine_code, year)
]

# Social spending (policy group 23)
social_spending <- muni_program[program_2digit == "23",
  .(total_social = sum(spending, na.rm = TRUE)),
  by = .(ine_code, year)
]

# Security spending (policy group 13)
security_spending <- muni_program[program_2digit == "13",
  .(total_security = sum(spending, na.rm = TRUE)),
  by = .(ine_code, year)
]

# Infrastructure spending (policy group 15)
infra_spending <- muni_program[program_2digit == "15",
  .(total_infra = sum(spending, na.rm = TRUE)),
  by = .(ine_code, year)
]

# Merge all spending categories
panel <- merge(total_spending, edu_spending, by = c("ine_code", "year"),
               all.x = TRUE)
# Add population from lookup
panel <- merge(panel, pop_lookup, by = c("ine_code", "year"), all.x = TRUE)
panel <- merge(panel, edu_panel[, c("ine_code", "year",
               grep("^share_", names(edu_panel), value = TRUE)),
               with = FALSE],
               by = c("ine_code", "year"), all.x = TRUE)
panel <- merge(panel, social_spending, by = c("ine_code", "year"), all.x = TRUE)
panel <- merge(panel, security_spending, by = c("ine_code", "year"), all.x = TRUE)
panel <- merge(panel, infra_spending, by = c("ine_code", "year"), all.x = TRUE)

# Fill NAs with 0 for spending
for (col in c("total_edu", "total_social", "total_security", "total_infra")) {
  panel[is.na(get(col)), (col) := 0]
}

# Per capita measures
panel[, edu_pc := total_edu / as.numeric(poblacion)]
panel[, social_pc := total_social / as.numeric(poblacion)]
panel[, security_pc := total_security / as.numeric(poblacion)]
panel[, spending_pc := total_spending / as.numeric(poblacion)]

# Education share of total
panel[, edu_share_total := fifelse(total_spending > 0,
                                    total_edu / total_spending, NA_real_)]

# Education HHI (concentration within education)
# Join back the subcategory shares
share_cols <- grep("^share_", names(panel), value = TRUE)
panel[, edu_hhi := rowSums(panel[, ..share_cols]^2, na.rm = TRUE)]
panel[edu_hhi == 0, edu_hhi := NA]

cat("\nPanel dimensions:", nrow(panel), "municipality-years\n")

## ----------------------------------------------------------
## 3. Load Election Data (Council Gender Composition)
##    Pre-downloaded via infoelectoral R package
## ----------------------------------------------------------

cat("\n=== Loading election candidate data ===\n")

# Council gender data was pre-processed from Ministerio del Interior
# via the rOpenSpain/infoelectoral package (candidatos() function)
# Elections: 2007, 2011, 2015, 2019, 2023
# (2003 excluded: no gender field in that year's data)

council_gender_file <- file.path(data_dir, "council_gender.csv")
if (file.exists(council_gender_file)) {
  council_gender <- fread(council_gender_file)
  cat("Council gender data:", nrow(council_gender), "municipality-elections\n")
  cat("Mean female share:", round(mean(council_gender$female_share) * 100, 1), "%\n")
  cat("Years:", paste(sort(unique(council_gender$election_year)), collapse = ", "), "\n")
} else {
  cat("WARNING: council_gender.csv not found. Run election download first.\n")
  council_gender <- data.table(ine_code = character(), election_year = integer(),
                                female_share = numeric(), n_female = integer(),
                                n_total = integer())
}

## ----------------------------------------------------------
## 4. Merge Panel
##    Match budget years to the most recent election
## ----------------------------------------------------------

cat("\n=== Merging panel ===\n")

# Map each budget year to the governing council (most recent election)
# Elections: 2003, 2007, 2011, 2015, 2019, 2023
# Term: from election year to next election year - 1
panel[, election_year := fcase(
  year >= 2003 & year < 2007, 2003L,
  year >= 2007 & year < 2011, 2007L,
  year >= 2011 & year < 2015, 2011L,
  year >= 2015 & year < 2019, 2015L,
  year >= 2019 & year < 2023, 2019L,
  year >= 2023, 2023L,
  default = NA_integer_
)]

# Ensure consistent ine_code type (character)
panel[, ine_code := as.character(ine_code)]
council_gender[, ine_code := as.character(ine_code)]

# Merge council gender composition
if (nrow(council_gender) > 0) {
  panel <- merge(panel, council_gender,
                 by = c("ine_code", "election_year"), all.x = TRUE)
}

# Treatment indicator: above quota threshold
panel[, pop := as.numeric(poblacion)]
panel[, above_5000 := (pop >= 5000)]
panel[, above_3000 := (pop >= 3000)]

# Treatment depends on year (3000 threshold only from 2011)
panel[, treated := fcase(
  election_year >= 2007 & pop >= 5000, TRUE,
  election_year >= 2011 & pop >= 3000, TRUE,
  default = FALSE
)]

# Running variable centered at cutoffs
panel[, pop_centered_5000 := pop - 5000]
panel[, pop_centered_3000 := pop - 3000]

cat("Final panel:", nrow(panel), "municipality-years\n")
cat("Unique municipalities:", uniqueN(panel$ine_code), "\n")
cat("With council gender data:", sum(!is.na(panel$female_share)), "\n")

## ----------------------------------------------------------
## 5. Save cleaned panel
## ----------------------------------------------------------

fwrite(panel, file.path(data_dir, "analysis_panel.csv"))
if (nrow(council_gender) > 0) {
  fwrite(council_gender, file.path(data_dir, "council_gender.csv"))
}

cat("\nSaved: analysis_panel.csv\n")
cat("Columns:", paste(names(panel), collapse = ", "), "\n")
