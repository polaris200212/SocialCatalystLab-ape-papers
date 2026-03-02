# =============================================================================
# 04_panel_analysis.R - Panel DiD and Callaway-Sant'Anna
# v2: CRITICAL FIXES:
#   1. Time-varying D_ct treatment (1 iff law in force at referendum t)
#   2. CS first_treat uses IN-FORCE years (2011,2012,2013,2016), not adoption
#   3. BS excluded from CS (treatment = final period)
#   4. Rambachan-Roth sensitivity analysis added
# =============================================================================

get_this_script_dir <- function() {
  for (i in seq_len(sys.nframe())) {
    if (!is.null(sys.frame(i)$ofile)) return(dirname(sys.frame(i)$ofile))
  }
  return(getwd())
}
script_dir <- get_this_script_dir()
source(file.path(script_dir, "00_packages.R"))

# Load data
voting_data <- readRDS(file.path(data_dir, "voting_data.rds"))
canton_treatment <- readRDS(file.path(data_dir, "canton_treatment.rds"))

gemeinde_data <- voting_data %>%
  rename(canton = canton_abbr, language = lang, voters = eligible_voters) %>%
  mutate(treated = as.numeric(treated))

# =============================================================================
# 1. Fetch/Load Historical Referendum Data
# =============================================================================
message("=== BUILDING PANEL FROM REAL REFERENDUM DATA ===")

canton_lookup <- tibble(
  canton_id = 1:26,
  canton = c("ZH", "BE", "LU", "UR", "SZ", "OW", "NW", "GL", "ZG", "FR",
             "SO", "BS", "BL", "SH", "AR", "AI", "SG", "GR", "AG", "TG",
             "TI", "VD", "VS", "NE", "GE", "JU")
)

fetch_or_load <- function(rds_name, from_date, to_date, name_pattern) {
  rds_path <- file.path(data_dir, rds_name)
  if (file.exists(rds_path)) {
    return(readRDS(rds_path))
  }
  tryCatch({
    votes <- get_nationalvotes(from_date = from_date, to_date = to_date,
                                geolevel = "municipality")
    if (!is.null(name_pattern)) {
      votes <- votes %>% filter(str_detect(tolower(name), name_pattern))
    }
    votes
  }, error = function(e) NULL)
}

votes_2000 <- fetch_or_load("votes_2000.rds", "2000-09-01", "2000-09-30", "solar|energie")
votes_2003 <- fetch_or_load("votes_2003.rds", "2003-05-01", "2003-05-31", "strom|nuclear|moratorium")
votes_2016 <- fetch_or_load("votes_2016.rds", "2016-11-01", "2016-11-30", "ausstieg|atom")

# Aggregate to canton level
agg_canton <- function(df) {
  if (is.null(df) || nrow(df) == 0) return(NULL)
  df %>%
    mutate(canton_id = as.integer(canton_id)) %>%
    group_by(canton_id) %>%
    summarize(
      yes_share = weighted.mean(jaStimmenInProzent, anzahlStimmberechtigte, na.rm = TRUE),
      n_gemeinden = n(),
      .groups = "drop"
    ) %>%
    left_join(canton_lookup, by = "canton_id")
}

votes_2000_ct <- agg_canton(votes_2000) %>% mutate(year = 2000)
votes_2003_ct <- agg_canton(votes_2003) %>% mutate(year = 2003)
votes_2016_ct <- agg_canton(votes_2016) %>% mutate(year = 2016)

# 2017 from main data
canton_2017 <- gemeinde_data %>%
  group_by(canton, treated, language) %>%
  summarize(
    yes_share = weighted.mean(yes_share, voters, na.rm = TRUE),
    n_gemeinden = n(),
    .groups = "drop"
  ) %>%
  mutate(year = 2017)

# =============================================================================
# 2. Build Panel with TIME-VARYING Treatment
# =============================================================================
message("\n=== CONSTRUCTING PANEL WITH TIME-VARYING D_ct ===")

# Get canton-level treatment info
canton_info <- canton_treatment %>%
  select(canton_abbr, treated, lang, in_force_year) %>%
  rename(canton = canton_abbr, language = lang)

# Combine panel
panel_list <- list()
if (!is.null(votes_2000_ct)) panel_list <- c(panel_list, list(votes_2000_ct %>% select(canton, yes_share, year)))
if (!is.null(votes_2003_ct)) panel_list <- c(panel_list, list(votes_2003_ct %>% select(canton, yes_share, year)))
if (!is.null(votes_2016_ct)) panel_list <- c(panel_list, list(votes_2016_ct %>% select(canton, yes_share, year)))
panel_list <- c(panel_list, list(canton_2017 %>% select(canton, yes_share, year)))

canton_panel <- bind_rows(panel_list) %>%
  left_join(canton_info, by = "canton")

# CRITICAL FIX: Time-varying treatment D_ct
# D_ct = 1 iff canton c's energy law was IN FORCE at referendum t
# In-force years: GR=2011, BE=2012, AG=2013, BL=2016, BS=2017
canton_panel <- canton_panel %>%
  mutate(
    D_ct = case_when(
      !treated ~ 0,  # Never-treated cantons
      canton == "GR" & year >= 2011 ~ 1,  # GR in force Jan 2011
      canton == "BE" & year >= 2012 ~ 1,  # BE in force Jan 2012
      canton == "AG" & year >= 2013 ~ 1,  # AG in force Jan 2013
      canton == "BL" & year >= 2016 ~ 1,  # BL in force Jul 2016
      canton == "BS" & year >= 2017 ~ 1,  # BS in force Jan 2017
      TRUE ~ 0  # Pre-treatment periods for treated cantons
    )
  )

# Print treatment status verification
message("\nD_ct verification (should show time-varying pattern):")
canton_panel %>%
  filter(treated == 1) %>%
  select(canton, year, D_ct) %>%
  pivot_wider(names_from = year, values_from = D_ct) %>%
  print()

message(paste("\nPanel observations:", nrow(canton_panel)))
message(paste("Cantons:", n_distinct(canton_panel$canton)))
message(paste("Years:", paste(sort(unique(canton_panel$year)), collapse = ", ")))

# =============================================================================
# 3. Panel DiD with Time-Varying Treatment
# =============================================================================
message("\n=== PANEL DiD (TIME-VARYING D_ct) ===")

canton_panel <- canton_panel %>%
  mutate(canton_id = as.numeric(factor(canton)))

did_model <- feols(
  yes_share ~ D_ct | canton + year,
  data = canton_panel,
  cluster = ~canton
)

message("DiD Results:")
print(summary(did_model))

did_results <- tibble(
  term = "D_ct (time-varying)",
  estimate = coef(did_model)["D_ct"],
  se = sqrt(vcov(did_model)["D_ct","D_ct"]),
  ci_lower = coef(did_model)["D_ct"] - 1.96 * sqrt(vcov(did_model)["D_ct","D_ct"]),
  ci_upper = coef(did_model)["D_ct"] + 1.96 * sqrt(vcov(did_model)["D_ct","D_ct"]),
  n_obs = nobs(did_model)
)
write_csv(did_results, file.path(tab_dir, "did_results.csv"))

# Event study summary (descriptive)
event_study <- canton_panel %>%
  group_by(year, treated) %>%
  summarize(
    mean_yes = mean(yes_share, na.rm = TRUE),
    se = sd(yes_share, na.rm = TRUE) / sqrt(n()),
    .groups = "drop"
  ) %>%
  mutate(group = ifelse(treated == 1, "Treated Cantons", "Control Cantons"))

write_csv(event_study, file.path(tab_dir, "event_study_summary.csv"))
write_csv(canton_panel, file.path(tab_dir, "panel_data_summary.csv"))

# =============================================================================
# 4. Callaway-Sant'Anna (FIXED timing)
# =============================================================================
message("\n=== CALLAWAY-SANT'ANNA (CORRECTED) ===")

has_did <- requireNamespace("did", quietly = TRUE)

if (has_did) {
  library(did)

  # CRITICAL FIX: Use IN-FORCE years, not adoption years
  # CRITICAL FIX: Exclude BS (first post-treatment period is final period)
  canton_cs <- canton_panel %>%
    filter(canton != "BS") %>%  # EXCLUDE BS
    mutate(
      # IN-FORCE years (not adoption years as in v1)
      first_treat = case_when(
        canton == "GR" ~ 2011,   # v1 had 2010 (adoption year) - WRONG
        canton == "BE" ~ 2012,   # v1 had 2011 - WRONG
        canton == "AG" ~ 2013,   # v1 had 2012 - WRONG
        canton == "BL" ~ 2016,   # Correct
        TRUE ~ 0                 # Never treated
      )
    )

  message("CS data verification:")
  canton_cs %>%
    filter(first_treat > 0) %>%
    select(canton, year, first_treat, D_ct) %>%
    distinct() %>%
    arrange(canton, year) %>%
    print()

  cs_result <- tryCatch({
    att_gt(
      yname = "yes_share",
      tname = "year",
      idname = "canton_id",
      gname = "first_treat",
      data = canton_cs,
      control_group = "nevertreated",
      base_period = "universal"
    )
  }, error = function(e) {
    message(paste("CS error:", e$message))
    NULL
  })

  if (!is.null(cs_result)) {
    cs_agg <- aggte(cs_result, type = "simple")
    message(paste("CS ATT:", round(cs_agg$overall.att, 2),
                  "(SE =", round(cs_agg$overall.se, 2), ")"))

    cs_summary <- tibble(
      estimator = "Callaway-Sant'Anna (corrected)",
      att = cs_agg$overall.att,
      se = cs_agg$overall.se,
      ci_lower = cs_agg$overall.att - 1.96 * cs_agg$overall.se,
      ci_upper = cs_agg$overall.att + 1.96 * cs_agg$overall.se,
      note = "BS excluded; in-force years used"
    )
    write_csv(cs_summary, file.path(tab_dir, "callaway_santanna.csv"))

    # Dynamic event study
    cs_event <- tryCatch({
      aggte(cs_result, type = "dynamic")
    }, error = function(e) NULL)

    if (!is.null(cs_event)) {
      cs_event_df <- tibble(
        event_time = cs_event$egt,
        att = cs_event$att.egt,
        se = cs_event$se.egt
      ) %>%
        mutate(ci_lower = att - 1.96 * se, ci_upper = att + 1.96 * se)
      write_csv(cs_event_df, file.path(tab_dir, "cs_event_study.csv"))

      # Save for plotting
      saveRDS(cs_event_df, file.path(data_dir, "cs_event_data.rds"))
    }

    # Group-time ATTs for appendix table
    gt_results <- tibble(
      group = cs_result$group,
      time = cs_result$t,
      att = cs_result$att,
      se = cs_result$se
    ) %>%
      mutate(ci_lower = att - 1.96 * se, ci_upper = att + 1.96 * se)
    write_csv(gt_results, file.path(tab_dir, "cs_group_time.csv"))
  }
} else {
  message("did package not available - using TWFE only")
  cs_summary <- tibble(
    estimator = "TWFE (time-varying D_ct)",
    att = coef(did_model)["D_ct"],
    se = sqrt(vcov(did_model)["D_ct","D_ct"]),
    ci_lower = coef(did_model)["D_ct"] - 1.96 * sqrt(vcov(did_model)["D_ct","D_ct"]),
    ci_upper = coef(did_model)["D_ct"] + 1.96 * sqrt(vcov(did_model)["D_ct","D_ct"])
  )
  write_csv(cs_summary, file.path(tab_dir, "callaway_santanna.csv"))
}

# =============================================================================
# 5. Rambachan-Roth Sensitivity (if HonestDiD available)
# =============================================================================
message("\n=== RAMBACHAN-ROTH SENSITIVITY ===")

has_honestdid <- requireNamespace("HonestDiD", quietly = TRUE)

if (has_honestdid && has_did && exists("cs_result") && !is.null(cs_result)) {
  library(HonestDiD)

  rr_result <- tryCatch({
    # Get the event study for sensitivity
    cs_es <- aggte(cs_result, type = "dynamic")

    # Rambachan-Roth breakdown analysis
    honest_result <- HonestDiD::createSensitivityResults_relativeMagnitudes(
      betahat = cs_es$att.egt,
      sigma = diag(cs_es$se.egt^2),
      numPrePeriods = sum(cs_es$egt < 0),
      numPostPeriods = sum(cs_es$egt >= 0),
      Mbarvec = seq(0, 2, by = 0.5)
    )

    message("Rambachan-Roth breakdown values:")
    print(honest_result)

    write_csv(as_tibble(honest_result), file.path(tab_dir, "rambachan_roth.csv"))
    honest_result
  }, error = function(e) {
    message(paste("HonestDiD error:", e$message))
    NULL
  })
} else {
  message("HonestDiD not available or CS not estimated - skipping")
}

message("\n=== PANEL ANALYSIS COMPLETE ===")
