## ============================================================
## 02_clean_data.R — Data cleaning and variable construction (v3)
## Merges RNE, commune characteristics, INSEE census,
## municipal finances, election candidacy, Sirene data,
## BPE equipment, expanded adjoint pipeline, expanded DGFIP
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
## PART A.5: NEW v3 — Adjoint (Deputy Mayor) Pipeline
## ----------------------------------------------------------

cat("\nProcessing RNE adjoint pipeline...\n")

adjoint_stats <- rne %>%
  mutate(
    is_adjoint = grepl("adjoint|Adjoint", fonction, ignore.case = TRUE),
    is_mayor = fonction == "Maire",
    adjoint_rank = as.numeric(str_extract(fonction, "\\d+"))
  ) %>%
  group_by(dep_code, commune_code) %>%
  summarise(
    n_adjoints = sum(is_adjoint, na.rm = TRUE),
    n_female_adjoints = sum(is_adjoint & female == 1, na.rm = TRUE),
    female_share_adjoints = ifelse(sum(is_adjoint) > 0,
      sum(is_adjoint & female == 1) / sum(is_adjoint), NA_real_),
    female_first_adjoint = {
      adj_fem <- female[is_adjoint]
      adj_ranks <- adjoint_rank[is_adjoint]
      if (length(adj_fem) == 0) {
        NA_real_
      } else if (any(!is.na(adj_ranks))) {
        idx <- which.min(adj_ranks)
        adj_fem[idx]
      } else {
        adj_fem[1]
      }
    },
    female_share_top3_adjoints = {
      adj_idx <- which(is_adjoint)
      if (length(adj_idx) >= 3) {
        ranks <- adjoint_rank[adj_idx]
        if (any(!is.na(ranks))) {
          ord <- order(ranks)
          top3 <- adj_idx[ord[1:min(3, length(ord))]]
        } else {
          top3 <- adj_idx[1:3]
        }
        mean(female[top3])
      } else if (length(adj_idx) > 0) {
        mean(female[adj_idx])
      } else NA_real_
    },
    highest_female_adjoint_rank = {
      fem_adj <- which(is_adjoint & female == 1 & !is.na(adjoint_rank))
      if (length(fem_adj) > 0) min(adjoint_rank[fem_adj]) else NA_real_
    },
    .groups = "drop"
  )

cat("  Adjoint stats:", nrow(adjoint_stats), "communes\n")
cat("  Mean female adjoint share:",
    round(mean(adjoint_stats$female_share_adjoints, na.rm = TRUE), 3), "\n")

council_stats <- council_stats %>%
  left_join(adjoint_stats, by = c("dep_code", "commune_code"))

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

df <- df %>%
  mutate(
    pop = population,
    pop_centered = population - 1000,
    above_threshold = as.integer(population >= 1000),
    parity_status = ifelse(above_threshold == 1,
                           "Parity (>=1000)", "No parity (<1000)")
  )

## ===========================================================
## PART B: Municipal Finance Data (v3: expanded accounts)
## ===========================================================

cat("\n=== Processing Municipal Finance Data (v3 expanded) ===\n")

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
    tmp <- read_delim(fin_file, delim = ";", n_max = 5, show_col_types = FALSE)
    if (ncol(tmp) < 3) {
      tmp <- read_csv(fin_file, n_max = 5, show_col_types = FALSE)
    }
    if (ncol(tmp) >= 3) {
      delim_char <- if (ncol(read_delim(fin_file, delim = ";", n_max = 1,
                                         show_col_types = FALSE)) >= 3) ";" else ","
      read_delim(fin_file, delim = delim_char, show_col_types = FALSE,
                 col_types = cols(.default = "c"))
    } else NULL
  }, error = function(e) {
    cat("  Error reading", yr, ":", e$message, "\n")
    NULL
  })

  if (is.null(fin_raw) || nrow(fin_raw) == 0) next
  cat("  Read", nrow(fin_raw), "rows,", ncol(fin_raw), "columns\n")

  if ("categ" %in% names(fin_raw)) {
    fin_raw <- fin_raw %>% filter(categ == "Commune")
    cat("  After filtering to communes:", nrow(fin_raw), "rows\n")
  }

  if (all(c("ndept", "insee") %in% names(fin_raw))) {
    fin_raw <- fin_raw %>%
      mutate(
        commune_id = paste0(
          formatC(as.integer(ndept), width = 2, flag = "0"),
          formatC(as.integer(insee), width = 3, flag = "0")
        )
      )
  } else {
    cat("  Cannot construct commune code, skipping", yr, "\n")
    next
  }

  # v3: Expanded account classification
  fin_raw <- fin_raw %>%
    mutate(
      spend_debit = as.numeric(obnetdeb),
      account = as.character(compte),
      is_expense_account = substr(account, 1, 1) == "6",
      is_social_account = substr(account, 1, 3) %in% c("655", "656", "657"),
      is_education_account = substr(account, 1, 4) %in% c("6551", "6553"),
      is_culture_account = substr(account, 1, 4) %in% c("6574"),
      is_environment_account = substr(account, 1, 4) %in% c("6575", "6576"),
      is_personnel_account = substr(account, 1, 3) %in%
        c("641", "642", "643", "644", "645"),
      is_sports_account = substr(account, 1, 4) %in% c("6573")
    )

  fin_agg <- fin_raw %>%
    filter(!is.na(spend_debit)) %>%
    group_by(commune_id) %>%
    summarise(
      total_spending = sum(spend_debit[is_expense_account], na.rm = TRUE),
      social_spending = sum(spend_debit[is_social_account], na.rm = TRUE),
      education_spending = sum(spend_debit[is_education_account], na.rm = TRUE),
      culture_spending = sum(spend_debit[is_culture_account], na.rm = TRUE),
      environment_spending = sum(spend_debit[is_environment_account], na.rm = TRUE),
      personnel_spending = sum(spend_debit[is_personnel_account], na.rm = TRUE),
      sports_spending = sum(spend_debit[is_sports_account], na.rm = TRUE),
      n_expense_categories = n_distinct(substr(account[is_expense_account], 1, 3)),
      n_lines = n(),
      year = yr,
      .groups = "drop"
    )

  cat("  Aggregated to", nrow(fin_agg), "communes for", yr, "\n")
  finance_list[[as.character(yr)]] <- fin_agg
}

if (length(finance_list) > 0) {
  finance_all <- bind_rows(finance_list)

  finance_avg <- finance_all %>%
    group_by(commune_id) %>%
    summarise(
      avg_total_spending = mean(total_spending, na.rm = TRUE),
      avg_social_spending = mean(social_spending, na.rm = TRUE),
      avg_education_spending = mean(education_spending, na.rm = TRUE),
      avg_culture_spending = mean(culture_spending, na.rm = TRUE),
      avg_environment_spending = mean(environment_spending, na.rm = TRUE),
      avg_personnel_spending = mean(personnel_spending, na.rm = TRUE),
      avg_sports_spending = mean(sports_spending, na.rm = TRUE),
      avg_n_categories = mean(n_expense_categories, na.rm = TRUE),
      n_finance_years = n(),
      .groups = "drop"
    )

  cat("Finance data: averaged across years for", nrow(finance_avg), "communes\n")

  df_fin <- df %>%
    left_join(finance_avg, by = c("commune_code_geo" = "commune_id"))

  n_matched <- sum(!is.na(df_fin$avg_total_spending))
  cat("  Finance matched:", n_matched, "of", nrow(df), "communes\n")

  if (n_matched > 0) {
    df_fin <- df_fin %>%
      mutate(
        spend_total_pc = avg_total_spending / pop,
        spend_social_pc = avg_social_spending / pop,
        spend_education_pc = avg_education_spending / pop,
        spend_culture_pc = avg_culture_spending / pop,
        spend_environment_pc = avg_environment_spending / pop,
        spend_personnel_pc = avg_personnel_spending / pop,
        spend_sports_pc = avg_sports_spending / pop,
        # v3: Spending HHI (Herfindahl)
        spend_hhi = {
          cats <- cbind(avg_social_spending, avg_education_spending,
                        avg_culture_spending, avg_environment_spending,
                        avg_personnel_spending, avg_sports_spending)
          total <- rowSums(cats, na.rm = TRUE)
          shares <- cats / ifelse(total > 0, total, NA)
          rowSums(shares^2, na.rm = TRUE)
        },
        social_share = avg_social_spending / ifelse(avg_total_spending > 0,
          avg_total_spending, NA),
        family_spending = NA_real_,
        spend_family_pc = NA_real_
      )
    df <- df_fin
  }
} else {
  cat("  No finance data available\n")
  for (v in c("spend_total_pc", "spend_social_pc", "spend_education_pc",
              "spend_culture_pc", "spend_environment_pc", "spend_personnel_pc",
              "spend_sports_pc", "spend_hhi", "social_share",
              "spend_family_pc")) {
    df[[v]] <- NA_real_
  }
}

## ===========================================================
## PART C: 2020 Election Candidacy Data
## ===========================================================

cat("\n=== Processing 2020 Election Candidacy Data ===\n")

read_candidacy <- function(filepath) {
  if (!file.exists(filepath)) return(NULL)
  ext <- tools::file_ext(filepath)
  if (ext == "txt") {
    tryCatch({
      tmp <- read_delim(filepath, delim = "\t", n_max = 5, show_col_types = FALSE)
      if (ncol(tmp) < 3) {
        tmp <- read_delim(filepath, delim = ";", n_max = 5, show_col_types = FALSE)
        if (ncol(tmp) >= 3) return(read_delim(filepath, delim = ";",
          show_col_types = FALSE, col_types = cols(.default = "c")))
      }
      return(read_delim(filepath, delim = "\t", show_col_types = FALSE,
                         col_types = cols(.default = "c")))
    }, error = function(e) NULL)
  } else if (ext == "xlsx") {
    tryCatch(read_excel(filepath), error = function(e) NULL)
  } else {
    tryCatch(read_csv(filepath, show_col_types = FALSE,
                      col_types = cols(.default = "c")),
             error = function(e) NULL)
  }
}

cand_above <- read_candidacy(file.path(data_dir, "candidatures_2020_above1000.txt"))
if (is.null(cand_above))
  cand_above <- read_candidacy(file.path(data_dir, "candidatures_2020_above1000.xlsx"))

cand_below <- read_candidacy(file.path(data_dir, "candidatures_2020_below1000.txt"))
if (is.null(cand_below))
  cand_below <- read_candidacy(file.path(data_dir, "candidatures_2020_below1000.xlsx"))

if (!is.null(cand_above) || !is.null(cand_below)) {
  process_candidacy <- function(cand_df) {
    if (is.null(cand_df)) return(NULL)
    col_lower <- tolower(names(cand_df))
    cat("  Candidacy columns:", paste(head(names(cand_df), 15), collapse = ", "), "\n")

    sex_col <- names(cand_df)[which(col_lower %in% c("sexe", "civilite", "civilité",
      "sexe du candidat", "code sexe"))[1]]
    code_col <- names(cand_df)[which(col_lower %in% c("code commune",
      "code de la commune", "code_commune", "codecommune", "insee"))[1]]
    dep_col <- names(cand_df)[which(col_lower %in% c("code département",
      "code du département", "code_departement", "dep"))[1]]

    if (is.na(sex_col) || is.na(code_col)) {
      cat("  Cannot find sex or code column\n")
      return(NULL)
    }

    cand_df$is_female <- grepl("^(F|Mme|MME|f|2)$", cand_df[[sex_col]])

    if (!is.na(dep_col)) {
      cand_df$commune_id <- paste0(
        sprintf("%02s", cand_df[[dep_col]]),
        sprintf("%03s", cand_df[[code_col]])
      )
    } else {
      cand_df$commune_id <- cand_df[[code_col]]
    }

    # v3: also compute number of lists (PR signature)
    list_col <- names(cand_df)[which(col_lower %in% c("nuance liste",
      "code nuance liste", "libellé de la liste", "nom de la liste",
      "n panneau"))[1]]

    result <- cand_df %>%
      group_by(commune_id) %>%
      summarise(
        n_candidates = n(),
        n_female_candidates = sum(is_female),
        female_candidate_share = mean(is_female),
        n_lists = if (!is.na(list_col)) n_distinct(.data[[list_col]]) else NA_integer_,
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
  cat("  No candidacy data available\n")
  df$n_candidates <- NA_real_
  df$n_female_candidates <- NA_real_
  df$female_candidate_share <- NA_real_
  df$n_lists <- NA_integer_
}

## ===========================================================
## PART D: Sirene Business Creation Data
## ===========================================================

cat("\n=== Processing Sirene Business Creation Data ===\n")

sirene_dir <- file.path(data_dir, "sirene_creations")
sirene_processed <- FALSE

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
      sirene_processed <- TRUE
    }
  }
}

if (!sirene_processed) {
  cat("  Sirene data not available — using INSEE self-employment shares\n")
}

## ===========================================================
## PART F: NEW v3 — BPE Public Equipment Data
## ===========================================================

cat("\n=== Processing BPE Equipment Data (v3) ===\n")

process_bpe <- function(bpe_dir_path, vintage_label) {
  if (!dir.exists(bpe_dir_path)) {
    cat("  BPE", vintage_label, "directory not found\n")
    return(NULL)
  }

  bpe_files <- list.files(bpe_dir_path, pattern = "\\.csv$|\\.CSV$",
                          recursive = TRUE, full.names = TRUE)
  if (length(bpe_files) == 0) {
    cat("  No CSV files in BPE", vintage_label, "\n")
    return(NULL)
  }

  cat("  Reading BPE", vintage_label, "from:", bpe_files[1], "\n")
  bpe_raw <- tryCatch({
    tmp <- read_delim(bpe_files[1], delim = ";", n_max = 5, show_col_types = FALSE)
    if (ncol(tmp) >= 3) {
      read_delim(bpe_files[1], delim = ";", show_col_types = FALSE,
                 col_types = cols(.default = "c"))
    } else {
      read_csv(bpe_files[1], show_col_types = FALSE,
               col_types = cols(.default = "c"))
    }
  }, error = function(e) {
    cat("  Error reading BPE:", e$message, "\n")
    NULL
  })

  if (is.null(bpe_raw) || nrow(bpe_raw) == 0) return(NULL)

  cat("  BPE", vintage_label, ":", nrow(bpe_raw), "rows,", ncol(bpe_raw), "cols\n")
  cat("  Columns:", paste(head(names(bpe_raw), 10), collapse = ", "), "\n")

  col_lower <- tolower(names(bpe_raw))
  depcom_col <- names(bpe_raw)[which(col_lower %in% c("depcom", "dep_com",
    "codgeo", "code_commune", "depcom_2024", "depcom_2023"))[1]]
  type_col <- names(bpe_raw)[which(col_lower %in% c("typequ", "type_equip",
    "type_equipement", "typequ_21", "typequ_23"))[1]]
  nb_col <- names(bpe_raw)[which(col_lower %in% c("nb_equip", "nb", "nombre",
    "nb_equipements"))[1]]

  if (is.na(depcom_col) || is.na(type_col)) {
    cat("  Cannot find DEPCOM or TYPEQU columns\n")
    cat("  Available:", paste(names(bpe_raw), collapse = ", "), "\n")
    return(NULL)
  }

  cat("  Using columns: commune=", depcom_col, " type=", type_col, "\n")

  bpe_raw$commune_id <- bpe_raw[[depcom_col]]
  bpe_raw$equip_type <- bpe_raw[[type_col]]
  if (!is.na(nb_col)) {
    bpe_raw$n_equip <- as.numeric(bpe_raw[[nb_col]])
  } else {
    bpe_raw$n_equip <- 1
  }

  # Equipment type classification (INSEE BPE 2024 codes)
  # Uses DOM (domain) and SDOM (sub-domain) columns when available
  # DOM: A=services, B=education, C=health, D=social, E=transport, F=sports, G=tourism
  # SDOM: D1=childcare, D2-D7=other social, A5=culture/leisure

  # Use DOM/SDOM if available, else classify by TYPEQU prefix
  has_dom <- "DOM" %in% names(bpe_raw) || "dom" %in% tolower(names(bpe_raw))
  has_sdom <- "SDOM" %in% names(bpe_raw) || "sdom" %in% tolower(names(bpe_raw))

  if (has_sdom) {
    sdom_col <- names(bpe_raw)[which(tolower(names(bpe_raw)) == "sdom")[1]]
    bpe_raw$sdom_val <- bpe_raw[[sdom_col]]
  } else if (has_dom) {
    dom_col <- names(bpe_raw)[which(tolower(names(bpe_raw)) == "dom")[1]]
    bpe_raw$sdom_val <- bpe_raw[[dom_col]]  # use DOM as fallback
  } else {
    bpe_raw$sdom_val <- substr(bpe_raw$equip_type, 1, 1)
  }

  bpe_agg <- bpe_raw %>%
    mutate(
      domain = case_when(
        sdom_val == "D1" ~ "childcare",        # crèches, halte-garderie
        grepl("^D", sdom_val) ~ "social",       # D2-D7 other social services
        grepl("^B", sdom_val) ~ "education",    # B1-B3
        grepl("^F", sdom_val) ~ "sports",       # F1-F3
        grepl("^C", sdom_val) ~ "health",       # C1-C6
        sdom_val == "A5" ~ "culture",           # cultural/leisure (biblio, cinema, etc.)
        TRUE ~ "other"
      )
    ) %>%
    group_by(commune_id, domain) %>%
    summarise(n_facilities = sum(n_equip, na.rm = TRUE), .groups = "drop") %>%
    pivot_wider(names_from = domain, values_from = n_facilities,
                values_fill = 0, names_prefix = "bpe_")

  bpe_agg <- bpe_agg %>%
    mutate(bpe_total = rowSums(select(., starts_with("bpe_")), na.rm = TRUE))

  cat("  Aggregated BPE for", nrow(bpe_agg), "communes\n")
  return(bpe_agg)
}

bpe23 <- process_bpe(file.path(data_dir, "bpe24"), "2024")
bpe18 <- process_bpe(file.path(data_dir, "bpe18"), "2018")

if (!is.null(bpe23)) {
  df <- df %>%
    left_join(bpe23, by = c("commune_code_geo" = "commune_id"))

  n_bpe <- sum(!is.na(df$bpe_total))
  cat("  BPE 2023 matched:", n_bpe, "of", nrow(df), "communes\n")

  # Per-1000 rates + binary indicators
  df <- df %>%
    mutate(
      across(starts_with("bpe_") & !ends_with("_pc"),
             ~ . / (pop / 1000), .names = "{.col}_pc"),
      has_creche = as.integer(!is.na(bpe_childcare) & bpe_childcare > 0),
      has_social_centre = as.integer(!is.na(bpe_social) & bpe_social > 0)
    )
} else {
  cat("  BPE 2023 not available — facility outcomes will be NA\n")
  for (v in c("bpe_childcare", "bpe_social", "bpe_education", "bpe_sports",
              "bpe_health", "bpe_culture", "bpe_total",
              "bpe_childcare_pc", "bpe_social_pc", "bpe_education_pc",
              "bpe_sports_pc", "bpe_health_pc", "bpe_culture_pc", "bpe_total_pc",
              "has_creche", "has_social_centre")) {
    df[[v]] <- NA_real_
  }
}

if (!is.null(bpe18)) {
  bpe18 <- bpe18 %>%
    rename_with(~ paste0(.x, "_2018"), -commune_id)

  df <- df %>%
    left_join(bpe18, by = c("commune_code_geo" = "commune_id"))

  n_bpe18 <- sum(!is.na(df$bpe_total_2018))
  cat("  BPE 2018 matched:", n_bpe18, "communes\n")
} else {
  cat("  BPE 2018 not available\n")
}

## ===========================================================
## PART E: Final cleaning
## ===========================================================

cat("\n=== Final Cleaning ===\n")

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

cat("\nOutcome availability:\n")
cat("  Spending data:", sum(!is.na(df$spend_total_pc)), "communes\n")
cat("  Candidacy data:", sum(!is.na(df$n_candidates)), "communes\n")
cat("  Female mayor:", sum(!is.na(df$has_female_mayor)), "communes\n")
cat("  Self-emp share:", sum(!is.na(df$female_self_emp_share) &
    is.finite(df$female_self_emp_share)), "communes\n")
cat("  BPE facilities:", sum(!is.na(df$bpe_total)), "communes\n")
cat("  Adjoint data:", sum(!is.na(df$female_share_adjoints)), "communes\n")
cat("  Spending HHI:", sum(!is.na(df$spend_hhi) &
    is.finite(df$spend_hhi)), "communes\n")

df <- df %>%
  mutate(
    pop_centered_3500 = population - 3500,
    above_3500 = as.integer(population >= 3500)
  )

saveRDS(df, file.path(data_dir, "analysis_data.rds"))
cat("\nSaved analysis dataset:", file.path(data_dir, "analysis_data.rds"), "\n")
