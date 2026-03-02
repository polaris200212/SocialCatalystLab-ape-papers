###############################################################################
# 02_clean_data.R — Clean and prepare all datasets
# Paper: Divine Forgiveness Beliefs (apep_0218)
###############################################################################

source("00_packages.R")

data_dir <- "../data"

###############################################################################
# 1. GSS — Extract religion and divine belief variables
###############################################################################
cat("\n=== Processing GSS Data ===\n")

gss_file <- list.files(file.path(data_dir, "gss"), pattern = "\\.dta$", full.names = TRUE)[1]
cat("Reading GSS file:", gss_file, "\n")

gss_vars <- c(
  "year", "id_",
  "god", "heaven", "hell", "afterlif", "angels", "miracles",
  "judge", "master", "lover", "friend", "creator", "healer",
  "father", "mother", "king", "spouse", "redeemer",
  "cope4", "forgive3",
  "relig", "denom", "fund", "attend", "pray", "reliten",
  "postlife", "bible",
  "age", "sex", "race", "educ", "degree", "income", "rincome",
  "region", "partyid", "polviews", "class_",
  "sei10", "realinc", "coninc",
  "happy", "health", "trust", "helpful"
)

gss_raw <- haven::read_dta(gss_file)
cat("GSS raw dimensions:", nrow(gss_raw), "x", ncol(gss_raw), "\n")

names(gss_raw) <- tolower(names(gss_raw))
gss <- gss_raw %>% select(any_of(tolower(gss_vars)))
cat("Selected GSS dimensions:", nrow(gss), "x", ncol(gss), "\n")

# Recode afterlife beliefs: 1=Yes definitely, 2=Yes probably, 3=No probably not, 4=No definitely not
binary_belief_vars <- c("heaven", "hell", "afterlif", "angels", "miracles")
for (v in intersect(binary_belief_vars, names(gss))) {
  gss[[v]] <- case_when(
    as.numeric(gss[[v]]) == 1 ~ 1L,
    as.numeric(gss[[v]]) == 2 ~ 1L,
    as.numeric(gss[[v]]) == 3 ~ 0L,
    as.numeric(gss[[v]]) == 4 ~ 0L,
    TRUE ~ NA_integer_
  )
}

# COPE4 and FORGIVE3
for (v in intersect(c("cope4", "forgive3"), names(gss))) {
  gss[[v]] <- ifelse(as.numeric(gss[[v]]) %in% 1:4, as.numeric(gss[[v]]), NA)
}

# God-image battery
god_image_vars <- c("judge", "master", "lover", "friend", "creator",
                     "healer", "father", "mother", "king", "spouse", "redeemer")
for (v in intersect(god_image_vars, names(gss))) {
  gss[[v]] <- ifelse(as.numeric(gss[[v]]) %in% 1:4, as.numeric(gss[[v]]), NA)
}

# Demographics
gss <- gss %>%
  mutate(
    female = ifelse(as.numeric(sex) == 2, 1L, ifelse(as.numeric(sex) == 1, 0L, NA_integer_)),
    age_num = ifelse(as.numeric(age) >= 18 & as.numeric(age) <= 89, as.numeric(age), NA_real_),
    educ_num = ifelse(as.numeric(educ) >= 0 & as.numeric(educ) <= 20, as.numeric(educ), NA_real_),
    college = ifelse(as.numeric(degree) >= 3, 1L, ifelse(as.numeric(degree) >= 0, 0L, NA_integer_)),
    attend_num = ifelse(as.numeric(attend) >= 0 & as.numeric(attend) <= 8, as.numeric(attend), NA_real_),
    realinc_num = as.numeric(realinc),
    year = as.integer(year)
  )

# Religious tradition categories
gss <- gss %>%
  mutate(
    relig_cat = case_when(
      as.numeric(relig) == 1 ~ "Protestant",
      as.numeric(relig) == 2 ~ "Catholic",
      as.numeric(relig) == 3 ~ "Jewish",
      as.numeric(relig) == 4 ~ "None",
      as.numeric(relig) %in% 5:13 ~ "Other",
      TRUE ~ NA_character_
    )
  )

cat("\nGSS variable availability:\n")
for (v in c("heaven", "hell", "afterlif", "cope4", "forgive3", "judge",
            "god", "attend_num", "female", "age_num", "educ_num")) {
  if (v %in% names(gss)) {
    n_valid <- sum(!is.na(gss[[v]]))
    cat(sprintf("  %-12s: %6d non-missing (%.1f%%)\n", v, n_valid,
                100 * n_valid / nrow(gss)))
  }
}

saveRDS(gss, file.path(data_dir, "gss_clean.rds"))
cat("Saved gss_clean.rds:", nrow(gss), "rows\n")

###############################################################################
# 2. D-PLACE Ethnographic Atlas — EA034 High Gods
###############################################################################
cat("\n=== Processing D-PLACE Ethnographic Atlas ===\n")

ea_data <- read_csv(file.path(data_dir, "dplace_ea", "data.csv"), show_col_types = FALSE)
ea_soc <- read_csv(file.path(data_dir, "dplace_ea", "societies.csv"), show_col_types = FALSE)
ea_codes <- read_csv(file.path(data_dir, "dplace_ea", "codes.csv"), show_col_types = FALSE)
ea_vars <- read_csv(file.path(data_dir, "dplace_ea", "variables.csv"), show_col_types = FALSE)

cat("EA data rows:", nrow(ea_data), "\n")
cat("EA societies:", nrow(ea_soc), "\n")

# Find EA034 (high gods)
ea034_ids <- ea_vars %>% filter(grepl("034", ID) & grepl("high.god|High God|Religion", Name, ignore.case = TRUE))
cat("EA034 variable ID:", ea034_ids$ID, "\n")

# Get EA034 data — join using Code_ID
ea_highgods <- ea_data %>%
  filter(Var_ID == "EA034") %>%
  left_join(ea_codes %>% filter(Var_ID == "EA034") %>% select(ID, Description),
            by = c("Code_ID" = "ID")) %>%
  left_join(ea_soc %>% select(ID, Name, Latitude, Longitude, region),
            by = c("Soc_ID" = "ID"))

cat("EA034 observations:", nrow(ea_highgods), "\n")
cat("EA034 code distribution:\n")
print(table(ea_highgods$Description, useNA = "ifany"))

# Build wide dataset with high gods + covariates
# Also get: EA028 (dependence on agriculture), EA031 (class stratification),
# EA030 (settlement patterns), EA033 (jurisdictional levels)
covariate_vars <- c("EA028", "EA031", "EA030", "EA033", "EA066", "EA042", "EA043")

ea_wide <- ea_data %>%
  filter(Var_ID %in% c("EA034", covariate_vars)) %>%
  select(Soc_ID, Var_ID, Code_ID) %>%
  pivot_wider(names_from = Var_ID, values_from = Code_ID, values_fn = first) %>%
  left_join(ea_soc %>% select(ID, Name, Latitude, Longitude, region), by = c("Soc_ID" = "ID"))

# Decode EA034 into numeric (0=absent, 1=otiose, 2=active not moral, 3=active moral)
# D-PLACE codes are 1-indexed: EA034-1=Absent, EA034-2=Otiose, EA034-3=Active not moral, EA034-4=Active moral
ea_wide <- ea_wide %>%
  mutate(
    high_gods_num = case_when(
      EA034 == "EA034-1" ~ 0L,  # Absent
      EA034 == "EA034-2" ~ 1L,  # Otiose/not concerned with humans
      EA034 == "EA034-3" ~ 2L,  # Active, not supporting morality
      EA034 == "EA034-4" ~ 3L,  # Active, supporting morality
      TRUE ~ NA_integer_
    ),
    high_gods_label = case_when(
      high_gods_num == 0 ~ "Absent",
      high_gods_num == 1 ~ "Otiose",
      high_gods_num == 2 ~ "Active, not moralizing",
      high_gods_num == 3 ~ "Active, moralizing",
      TRUE ~ NA_character_
    )
  )

cat("EA wide dataset:", nrow(ea_wide), "societies x", ncol(ea_wide), "variables\n")
cat("High gods distribution:\n")
print(table(ea_wide$high_gods_label, useNA = "ifany"))

saveRDS(ea_wide, file.path(data_dir, "ea_clean.rds"))
saveRDS(ea_highgods, file.path(data_dir, "ea_highgods.rds"))

###############################################################################
# 3. D-PLACE SCCS — High Gods + extensive covariates
###############################################################################
cat("\n=== Processing D-PLACE SCCS ===\n")

sccs_data <- read_csv(file.path(data_dir, "dplace_sccs", "data.csv"), show_col_types = FALSE)
sccs_soc <- read_csv(file.path(data_dir, "dplace_sccs", "societies.csv"), show_col_types = FALSE)
sccs_codes <- read_csv(file.path(data_dir, "dplace_sccs", "codes.csv"), show_col_types = FALSE)
sccs_vars <- read_csv(file.path(data_dir, "dplace_sccs", "variables.csv"), show_col_types = FALSE)

cat("SCCS data rows:", nrow(sccs_data), "\n")
cat("SCCS societies:", nrow(sccs_soc), "\n")

# Find SCCS238 (high gods)
sccs238_var <- sccs_vars %>% filter(grepl("SCCS238|High God", ID))
if (nrow(sccs238_var) == 0) {
  sccs238_var <- sccs_vars %>% filter(grepl("high.god|High God", Name, ignore.case = TRUE))
}
cat("SCCS high gods variable:\n")
print(sccs238_var %>% select(ID, Name))

# Get the variable ID
hg_var_id <- sccs238_var$ID[1]

sccs_highgods <- sccs_data %>%
  filter(Var_ID == hg_var_id) %>%
  left_join(sccs_codes %>% filter(Var_ID == hg_var_id) %>% select(ID, Description),
            by = c("Code_ID" = "ID")) %>%
  left_join(sccs_soc %>% select(ID, Name, Latitude, Longitude, region),
            by = c("Soc_ID" = "ID"))

cat("SCCS high gods observations:", nrow(sccs_highgods), "\n")
cat("SCCS high gods distribution:\n")
print(table(sccs_highgods$Description, useNA = "ifany"))

# Get useful covariates
# Population, subsistence, stratification, political hierarchy, writing
useful_var_ids <- sccs_vars %>%
  filter(grepl("populat|subsist|agricult|stratif|jurisdict|class|writing|money|urban|complex",
               Name, ignore.case = TRUE)) %>%
  pull(ID)

sccs_wide <- sccs_data %>%
  filter(Var_ID %in% c(hg_var_id, useful_var_ids)) %>%
  select(Soc_ID, Var_ID, Value) %>%
  mutate(Value = as.numeric(Value)) %>%
  pivot_wider(names_from = Var_ID, values_from = Value, values_fn = first) %>%
  left_join(sccs_soc %>% select(ID, Name, Latitude, Longitude, region), by = c("Soc_ID" = "ID"))

cat("SCCS wide dataset:", nrow(sccs_wide), "societies x", ncol(sccs_wide), "variables\n")
saveRDS(sccs_wide, file.path(data_dir, "sccs_clean.rds"))
saveRDS(sccs_highgods, file.path(data_dir, "sccs_highgods.rds"))

###############################################################################
# 4. Pulotu — Supernatural punishment in Austronesian cultures
###############################################################################
cat("\n=== Processing Pulotu ===\n")

pulotu_resp <- read_csv(file.path(data_dir, "pulotu", "responses.csv"), show_col_types = FALSE)
pulotu_q <- read_csv(file.path(data_dir, "pulotu", "questions.csv"), show_col_types = FALSE)
pulotu_cult <- read_csv(file.path(data_dir, "pulotu", "cultures.csv"), show_col_types = FALSE)

cat("Pulotu responses:", nrow(pulotu_resp), "\n")
cat("Pulotu questions:", nrow(pulotu_q), "\n")
cat("Pulotu cultures:", nrow(pulotu_cult), "\n")

# Identify religion-relevant questions
religion_q <- pulotu_q %>%
  filter(grepl("god|punish|supernatural|moral|spirit|afterlife|reward|belief|ancestor|prayer|sacrifice|ritual",
               paste(Name, Description, sep = " "), ignore.case = TRUE))
cat("\nReligion-related Pulotu questions:\n")
print(religion_q %>% select(ID, Simplified_Name) %>% head(20))

# Build wide dataset
pulotu_wide <- pulotu_resp %>%
  select(Language_ID, Parameter_ID, Value) %>%
  mutate(Value = as.numeric(Value)) %>%
  pivot_wider(names_from = Parameter_ID, values_from = Value, values_fn = first) %>%
  left_join(pulotu_cult %>% select(ID, Name, Macroarea, Latitude, Longitude),
            by = c("Language_ID" = "ID"))

cat("Pulotu wide dataset:", nrow(pulotu_wide), "cultures x", ncol(pulotu_wide), "variables\n")
saveRDS(pulotu_wide, file.path(data_dir, "pulotu_clean.rds"))
saveRDS(pulotu_q, file.path(data_dir, "pulotu_questions.rds"))

###############################################################################
# 5. Seshat — Moralizing supernatural punishment
###############################################################################
cat("\n=== Processing Seshat ===\n")

seshat_file <- file.path(data_dir, "seshat", "mr_dataset.csv")
if (file.exists(seshat_file) && file.size(seshat_file) > 100) {
  seshat <- read_csv(seshat_file, show_col_types = FALSE)
  cat("Seshat dimensions:", nrow(seshat), "x", ncol(seshat), "\n")
  cat("Seshat columns:\n")
  for (col in names(seshat)) cat(sprintf("  %s\n", col))
  saveRDS(seshat, file.path(data_dir, "seshat_clean.rds"))
} else {
  cat("Seshat data not available.\n")
}

###############################################################################
# 6. FRED Economic Indicators — Annualize for GSS merge
###############################################################################
cat("\n=== Processing Economic Covariates ===\n")

fred_file <- file.path(data_dir, "economic", "fred_indicators.csv")
if (file.exists(fred_file)) {
  fred <- read_csv(fred_file, show_col_types = FALSE)

  fred_annual <- fred %>%
    filter(!is.na(value)) %>%
    group_by(series, label, year) %>%
    summarize(value = mean(value, na.rm = TRUE), .groups = "drop") %>%
    select(year, series, value) %>%
    pivot_wider(names_from = series, values_from = value)

  cat("FRED annual data:", nrow(fred_annual), "years\n")
  saveRDS(fred_annual, file.path(data_dir, "fred_annual.rds"))
}

cat("\n=== All data cleaning complete ===\n")
for (f in list.files(data_dir, pattern = "\\.rds$")) {
  sz <- file.size(file.path(data_dir, f))
  cat(sprintf("  %s: %.1f MB\n", f, sz / 1e6))
}
