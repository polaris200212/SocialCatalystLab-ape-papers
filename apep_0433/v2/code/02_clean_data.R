## ============================================================
## 02_clean_data.R — Data cleaning and variable construction (v2)
## Merges RNE, commune characteristics, INSEE census,
## municipal finances, election candidacy, and Sirene data
## ============================================================

source("00_packages.R")

data_dir <- "../data"

## ===========================================================
## PART A: Core dataset (from v1)
## ===========================================================

## ----------------------------------------------------------
## 1. Process RNE — Compute female councillor share by commune
## ----------------------------------------------------------

cat("Processing RNE councillor data...\n")
rne <- read_delim(file.path(data_dir, "rne_conseillers_municipaux.csv"),
                  delim = ";", locale = locale(encoding = "UTF-8"),
                  show_col_types = FALSE)

rne <- rne %>%
  rename(
    dep_code = `Code du département`,
    commune_code = `Code de la commune`,
    commune_name = `Libellé de la commune`,
    sexe = `Code sexe`,
    date_mandat = `Date de début du mandat`,
    fonction = `Libellé de la fonction`,
    csp_code = `Code de la catégorie socio-professionnelle`,
    csp_label = `Libellé de la catégorie socio-professionnelle`
  )

rne <- rne %>%
  mutate(female = ifelse(sexe == "F", 1, 0))

council_stats <- rne %>%
  group_by(dep_code, commune_code, commune_name) %>%
  summarise(
    n_councillors = n(),
    n_female = sum(female),
    female_share = mean(female),
    has_female_mayor = any(fonction == "Maire" & female == 1, na.rm = TRUE),
    n_lists_approx = n_distinct(interaction(dep_code, commune_code)),
    .groups = "drop"
  )

cat("  Council stats:", nrow(council_stats), "communes\n")
cat("  Mean female share:", round(mean(council_stats$female_share), 3), "\n")

## ----------------------------------------------------------
## 2. Process commune characteristics
## ----------------------------------------------------------

cat("Processing commune population data...\n")
communes <- read_csv(file.path(data_dir, "communes_france.csv"),
                     show_col_types = FALSE)

communes <- communes %>%
  select(
    code_insee, nom_standard, population, superficie_km2,
    densite, dep_code, dep_nom, reg_code, reg_nom,
    grille_densite, grille_densite_texte,
    latitude_mairie, longitude_mairie,
    any_of(c("zone_emploi", "code_unite_urbaine",
             "nom_unite_urbaine", "type_commune_unite_urbain"))
  ) %>%
  rename(commune_code_geo = code_insee)

cat("  Communes with population:", nrow(communes), "\n")

## ----------------------------------------------------------
## 3. Process INSEE census employment data
## ----------------------------------------------------------

cat("Processing INSEE census employment data...\n")

insee_cols <- c(
  "CODGEO",
  "P22_POP1564", "P22_H1564", "P22_F1564",
  "P22_ACT1564", "P22_HACT1564", "P22_FACT1564",
  "P22_ACTOCC1564", "P22_HACTOCC1564", "P22_FACTOCC1564",
  "P22_CHOM1564",
  "P22_EMPLT_FSAL", "P22_EMPLT_FNSAL",
  "P16_POP1564", "P16_F1564", "P16_FACT1564", "P16_FACTOCC1564",
  "P16_ACT1564", "P16_ACTOCC1564",
  "P11_POP1564", "P11_F1564", "P11_FACT1564", "P11_FACTOCC1564",
  "P11_ACT1564", "P11_ACTOCC1564"
)

header <- read_delim(
  file.path(data_dir, "insee_emploi", "base-cc-emploi-pop-active-2022.CSV"),
  delim = ";", n_max = 0, show_col_types = FALSE
)
avail_cols <- names(header)
cols_to_read <- insee_cols[insee_cols %in% avail_cols]

insee <- read_delim(
  file.path(data_dir, "insee_emploi", "base-cc-emploi-pop-active-2022.CSV"),
  delim = ";", show_col_types = FALSE,
  col_select = all_of(cols_to_read)
)

cat("  INSEE employment:", nrow(insee), "communes\n")

insee <- insee %>%
  mutate(
    female_emp_rate = P22_FACTOCC1564 / P22_F1564,
    female_lfpr = P22_FACT1564 / P22_F1564,
    male_emp_rate = P22_HACTOCC1564 / (P22_POP1564 - P22_F1564),
    male_lfpr = P22_HACT1564 / (P22_POP1564 - P22_F1564),
    total_emp_rate = P22_ACTOCC1564 / P22_POP1564,
    total_lfpr = P22_ACT1564 / P22_POP1564,
    gender_emp_gap = male_emp_rate - female_emp_rate,
    gender_lfpr_gap = male_lfpr - female_lfpr,
    female_share_employed = P22_FACTOCC1564 / P22_ACTOCC1564,
    female_self_emp_share = P22_EMPLT_FNSAL / (P22_EMPLT_FSAL + P22_EMPLT_FNSAL),
    unemployment_rate = P22_CHOM1564 / P22_ACT1564
  )

if ("P11_F1564" %in% names(insee)) {
  insee <- insee %>%
    mutate(
      female_emp_rate_2011 = P11_FACTOCC1564 / P11_F1564,
      female_lfpr_2011 = P11_FACT1564 / P11_F1564,
      total_emp_rate_2011 = P11_ACTOCC1564 / P11_POP1564
    )
}

if ("P16_F1564" %in% names(insee)) {
  insee <- insee %>%
    mutate(
      female_emp_rate_2016 = P16_FACTOCC1564 / P16_F1564,
      female_lfpr_2016 = P16_FACT1564 / P16_F1564,
      total_emp_rate_2016 = P16_ACTOCC1564 / P16_POP1564
    )
}

## ----------------------------------------------------------
## 4. Merge core datasets
## ----------------------------------------------------------

cat("Merging core datasets...\n")

df <- communes %>%
  inner_join(council_stats, by = c("commune_code_geo" = "commune_code")) %>%
  inner_join(insee, by = c("commune_code_geo" = "CODGEO"))

cat("  After core merge:", nrow(df), "communes\n")

## Construct RDD variables
df <- df %>%
  mutate(
    pop = population,
    pop_centered = population - 1000,
    above_threshold = as.integer(population >= 1000),
    parity_status = ifelse(above_threshold == 1,
                           "Parity (>=1000)", "No parity (<1000)")
  )

## ===========================================================
## PART B: NEW — Municipal Finance Data
## ===========================================================

cat("\n=== Processing Municipal Finance Data ===\n")

finance_list <- list()

for (yr in 2019:2022) {
  fin_file <- file.path(data_dir, paste0("balances_comptables_communes_", yr, ".csv"))
  if (!file.exists(fin_file)) {
    cat("  Finance file for", yr, "not found, skipping\n")
    next
  }

  fsize <- file.info(fin_file)$size
  if (fsize < 5000) {
    cat("  Finance file for", yr, "too small (", fsize, "bytes), skipping\n")
    next
  }

  cat("  Reading finance data for", yr, "...\n")

  fin_raw <- tryCatch({
    # Try semicolon delimiter first (DGFIP standard)
    tmp <- read_delim(fin_file, delim = ";", n_max = 5, show_col_types = FALSE)
    if (ncol(tmp) < 3) {
      tmp <- read_csv(fin_file, n_max = 5, show_col_types = FALSE)
    }
    if (ncol(tmp) >= 3) {
      delim_char <- if (ncol(read_delim(fin_file, delim = ";", n_max = 1, show_col_types = FALSE)) >= 3) ";" else ","
      read_delim(fin_file, delim = delim_char, show_col_types = FALSE,
                 col_types = cols(.default = "c"))
    } else NULL
  }, error = function(e) {
    cat("  Error reading", yr, ":", e$message, "\n")
    NULL
  })

  if (is.null(fin_raw) || nrow(fin_raw) == 0) next

  cat("  Read", nrow(fin_raw), "rows,", ncol(fin_raw), "columns\n")

  # Filter to commune budgets only (ctype 101 = communes, categ = "Commune")
  if ("categ" %in% names(fin_raw)) {
    fin_raw <- fin_raw %>% filter(categ == "Commune")
    cat("  After filtering to communes:", nrow(fin_raw), "rows\n")
  }

  # Construct proper 5-digit INSEE code from ndept + insee
  # ndept = department number (2-3 digits), insee = commune code within dept (3 digits)
  if (all(c("ndept", "insee") %in% names(fin_raw))) {
    fin_raw <- fin_raw %>%
      mutate(
        commune_id = paste0(
          formatC(as.integer(ndept), width = 2, flag = "0"),
          formatC(as.integer(insee), width = 3, flag = "0")
        )
      )
    cat("  Constructed commune_id from ndept+insee\n")
    cat("  Example IDs:", paste(head(unique(fin_raw$commune_id), 5), collapse = ", "), "\n")
  } else {
    cat("  Cannot construct commune code, skipping", yr, "\n")
    next
  }

  # Use operational spending columns
  # obnetdeb = mandated operational debits (spending)
  # obnetcre = mandated operational credits (revenue)
  # sd = total debit balance, sc = total credit balance
  # For spending: sum obnetdeb (operational expenditure) across accounts
  fin_raw <- fin_raw %>%
    mutate(
      spend_debit = as.numeric(obnetdeb),
      # Account codes: 6xx = operating expenses
      # 65x = other management expenses (includes social transfers)
      # 657 = specific grants/welfare
      # 011 = employees (compte starts with 6)
      account = as.character(compte),
      is_expense_account = substr(account, 1, 1) == "6",
      # Social-related accounts: 6x with specific subaccounts
      # 655/656/657 = grants and social contributions
      is_social_account = account %in% c("6551", "6552", "6553", "6554",
        "6556", "6558", "657", "6571", "6572", "6573", "6574") |
        substr(account, 1, 3) %in% c("655", "656", "657"),
      # Education-related: 6551 (school contributions)
      is_education_account = substr(account, 1, 4) %in% c("6551", "6553")
    )

  # Aggregate to commune level
  fin_agg <- fin_raw %>%
    filter(!is.na(spend_debit)) %>%
    group_by(commune_id) %>%
    summarise(
      total_spending = sum(spend_debit[is_expense_account], na.rm = TRUE),
      social_spending = sum(spend_debit[is_social_account], na.rm = TRUE),
      education_spending = sum(spend_debit[is_education_account], na.rm = TRUE),
      family_spending = NA_real_,
      n_lines = n(),
      year = yr,
      .groups = "drop"
    )

  cat("  Aggregated to", nrow(fin_agg), "communes for", yr, "\n")
  finance_list[[as.character(yr)]] <- fin_agg
}

# Combine years and average
if (length(finance_list) > 0) {
  finance_all <- bind_rows(finance_list)

  finance_avg <- finance_all %>%
    group_by(commune_id) %>%
    summarise(
      avg_total_spending = mean(total_spending, na.rm = TRUE),
      avg_social_spending = mean(social_spending, na.rm = TRUE),
      avg_education_spending = mean(education_spending, na.rm = TRUE),
      avg_family_spending = mean(family_spending, na.rm = TRUE),
      n_finance_years = n(),
      .groups = "drop"
    )

  cat("Finance data: averaged across years for", nrow(finance_avg), "communes\n")

  # Merge with main df
  # commune_id might be SIREN or INSEE code — try matching
  df_fin <- df %>%
    left_join(finance_avg, by = c("commune_code_geo" = "commune_id"))

  n_matched <- sum(!is.na(df_fin$avg_total_spending))
  cat("  Finance matched:", n_matched, "of", nrow(df), "communes\n")

  if (n_matched > 0) {
    # Per capita spending
    df_fin <- df_fin %>%
      mutate(
        spend_total_pc = avg_total_spending / pop,
        spend_social_pc = avg_social_spending / pop,
        spend_education_pc = avg_education_spending / pop,
        spend_family_pc = avg_family_spending / pop
      )
    df <- df_fin
  }
} else {
  cat("  No finance data available — spending outcomes will be NA\n")
  df$spend_total_pc <- NA_real_
  df$spend_social_pc <- NA_real_
  df$spend_education_pc <- NA_real_
  df$spend_family_pc <- NA_real_
}

## ===========================================================
## PART C: NEW — 2020 Election Candidacy Data
## ===========================================================

cat("\n=== Processing 2020 Election Candidacy Data ===\n")

read_candidacy <- function(filepath) {
  if (!file.exists(filepath)) return(NULL)

  ext <- tools::file_ext(filepath)
  if (ext == "txt") {
    # Try tab-delimited first, then semicolon
    tryCatch({
      tmp <- read_delim(filepath, delim = "\t", n_max = 5, show_col_types = FALSE)
      if (ncol(tmp) < 3) {
        tmp <- read_delim(filepath, delim = ";", n_max = 5, show_col_types = FALSE)
        if (ncol(tmp) >= 3) return(read_delim(filepath, delim = ";", show_col_types = FALSE,
                                               col_types = cols(.default = "c")))
      }
      return(read_delim(filepath, delim = "\t", show_col_types = FALSE,
                         col_types = cols(.default = "c")))
    }, error = function(e) NULL)
  } else if (ext == "xlsx") {
    tryCatch(read_excel(filepath), error = function(e) NULL)
  } else {
    tryCatch(read_csv(filepath, show_col_types = FALSE, col_types = cols(.default = "c")),
             error = function(e) NULL)
  }
}

cand_above <- read_candidacy(file.path(data_dir, "candidatures_2020_above1000.txt"))
if (is.null(cand_above)) {
  cand_above <- read_candidacy(file.path(data_dir, "candidatures_2020_above1000.xlsx"))
}

cand_below <- read_candidacy(file.path(data_dir, "candidatures_2020_below1000.txt"))
if (is.null(cand_below)) {
  cand_below <- read_candidacy(file.path(data_dir, "candidatures_2020_below1000.xlsx"))
}

if (!is.null(cand_above) || !is.null(cand_below)) {
  process_candidacy <- function(cand_df) {
    if (is.null(cand_df)) return(NULL)

    col_lower <- tolower(names(cand_df))
    cat("  Candidacy columns:", paste(head(names(cand_df), 15), collapse = ", "), "\n")

    # Find gender and commune columns
    sex_col <- names(cand_df)[which(col_lower %in% c("sexe", "civilite", "civilité",
      "sexe du candidat", "code sexe"))[1]]
    code_col <- names(cand_df)[which(col_lower %in% c("code commune", "code de la commune",
      "code_commune", "codecommune", "insee"))[1]]
    dep_col <- names(cand_df)[which(col_lower %in% c("code département", "code du département",
      "code_departement", "dep"))[1]]

    if (is.na(sex_col) || is.na(code_col)) {
      cat("  Cannot find sex or code column\n")
      return(NULL)
    }

    cand_df$is_female <- grepl("^(F|Mme|MME|f|2)$", cand_df[[sex_col]])

    # Construct commune identifier
    if (!is.na(dep_col)) {
      cand_df$commune_id <- paste0(
        sprintf("%02s", cand_df[[dep_col]]),
        sprintf("%03s", cand_df[[code_col]])
      )
    } else {
      cand_df$commune_id <- cand_df[[code_col]]
    }

    # Aggregate to commune level
    result <- cand_df %>%
      group_by(commune_id) %>%
      summarise(
        n_candidates = n(),
        n_female_candidates = sum(is_female),
        female_candidate_share = mean(is_female),
        .groups = "drop"
      )
    return(result)
  }

  cand_above_agg <- process_candidacy(cand_above)
  cand_below_agg <- process_candidacy(cand_below)

  cand_all <- bind_rows(cand_above_agg, cand_below_agg)

  if (!is.null(cand_all) && nrow(cand_all) > 0) {
    cat("  Candidacy data:", nrow(cand_all), "communes\n")

    df <- df %>%
      left_join(cand_all, by = c("commune_code_geo" = "commune_id"))

    n_cand <- sum(!is.na(df$n_candidates))
    cat("  Candidacy matched:", n_cand, "communes\n")
  }
} else {
  cat("  No candidacy data available — pipeline outcomes will use RNE data only\n")
  df$n_candidates <- NA_real_
  df$n_female_candidates <- NA_real_
  df$female_candidate_share <- NA_real_
}

## ===========================================================
## PART D: NEW — Sirene Business Creation Data
## ===========================================================

cat("\n=== Processing Sirene Business Creation Data ===\n")

sirene_dir <- file.path(data_dir, "sirene_creations")
sirene_geoloc <- file.path(data_dir, "sirene_geoloc.zip")

sirene_processed <- FALSE

# Try pre-aggregated creation data first
if (dir.exists(sirene_dir)) {
  sirene_files <- list.files(sirene_dir, pattern = "\\.csv$|\\.CSV$",
                              recursive = TRUE, full.names = TRUE)
  if (length(sirene_files) > 0) {
    cat("  Reading Sirene creation files...\n")
    sirene_raw <- tryCatch(
      read_delim(sirene_files[1], delim = ";", show_col_types = FALSE,
                 col_types = cols(.default = "c")),
      error = function(e) {
        tryCatch(read_csv(sirene_files[1], show_col_types = FALSE,
                          col_types = cols(.default = "c")),
                 error = function(e2) NULL)
      }
    )

    if (!is.null(sirene_raw)) {
      cat("  Sirene:", nrow(sirene_raw), "rows\n")
      cat("  Columns:", paste(head(names(sirene_raw), 10), collapse = ", "), "\n")
      sirene_processed <- TRUE
    }
  }
}

if (!sirene_processed) {
  cat("  Sirene data not available or not processable\n")
  cat("  Will use INSEE self-employment shares from census as proxy\n")
  # Already have female_self_emp_share from census
}

## ===========================================================
## PART E: Final cleaning
## ===========================================================

cat("\n=== Final Cleaning ===\n")

# Drop communes with missing key variables
df <- df %>%
  filter(
    !is.na(pop),
    !is.na(female_share),
    !is.na(female_emp_rate),
    is.finite(female_emp_rate),
    pop > 0,
    P22_F1564 > 10
  )

cat("Final analysis dataset:", nrow(df), "communes\n")
cat("  Above 1000:", sum(df$above_threshold), "\n")
cat("  Below 1000:", sum(1 - df$above_threshold), "\n")
cat("  Within [500, 1500]:",
    sum(df$pop >= 500 & df$pop <= 1500), "\n")

cat("\nNew outcome availability:\n")
cat("  Spending data:", sum(!is.na(df$spend_total_pc)), "communes\n")
cat("  Candidacy data:", sum(!is.na(df$n_candidates)), "communes\n")
cat("  Female mayor:", sum(!is.na(df$has_female_mayor)), "communes\n")
cat("  Self-emp share:", sum(!is.na(df$female_self_emp_share) &
    is.finite(df$female_self_emp_share)), "communes\n")

## ----------------------------------------------------------
## Also construct the 3,500 threshold variables for validation
## ----------------------------------------------------------
df <- df %>%
  mutate(
    pop_centered_3500 = population - 3500,
    above_3500 = as.integer(population >= 3500)
  )

saveRDS(df, file.path(data_dir, "analysis_data.rds"))
cat("\nSaved analysis dataset:", file.path(data_dir, "analysis_data.rds"), "\n")
