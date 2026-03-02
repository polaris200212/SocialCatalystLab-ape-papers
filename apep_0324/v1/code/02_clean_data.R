###############################################################################
# 02_clean_data.R — Construct analysis variables
# Paper: Fear and Punitiveness in America
# APEP Working Paper apep_0313
###############################################################################

source("00_packages.R")

gss <- readRDS("../data/gss_raw.rds")
crime <- readRDS("../data/crime_rates.rds")

cat("=== Constructing Analysis Variables ===\n")

# --- Treatment: Fear of crime ---
# fear: 1 = "yes, afraid", 2 = "not afraid"
# Recode to binary: 1 = afraid, 0 = not afraid
gss <- gss %>%
  mutate(
    afraid = case_when(
      fear == 1 ~ 1L,
      fear == 2 ~ 0L,
      TRUE ~ NA_integer_
    )
  )
cat("Fear variable: ", sum(!is.na(gss$afraid)), "valid obs\n")
cat("  Afraid:", sum(gss$afraid == 1, na.rm = TRUE),
    "(", round(100 * mean(gss$afraid == 1, na.rm = TRUE), 1), "%)\n")
cat("  Not afraid:", sum(gss$afraid == 0, na.rm = TRUE),
    "(", round(100 * mean(gss$afraid == 0, na.rm = TRUE), 1), "%)\n")

# --- Outcomes ---
# cappun: 1 = favor death penalty, 2 = oppose
gss <- gss %>%
  mutate(
    favor_deathpen = case_when(
      cappun == 1 ~ 1L,
      cappun == 2 ~ 0L,
      TRUE ~ NA_integer_
    )
  )

# courts: 1 = too harsh, 2 = not harsh enough, 3 = about right
gss <- gss %>%
  mutate(
    courts_too_lenient = case_when(
      courts == 2 ~ 1L,
      courts %in% c(1, 3) ~ 0L,
      TRUE ~ NA_integer_
    )
  )

# natcrime: 1 = too little spending, 2 = about right, 3 = too much
gss <- gss %>%
  mutate(
    want_more_crime_spending = case_when(
      natcrime == 1 ~ 1L,
      natcrime %in% c(2, 3) ~ 0L,
      TRUE ~ NA_integer_
    )
  )

# gunlaw: 1 = favor gun permits, 2 = oppose
gss <- gss %>%
  mutate(
    favor_gun_permits = case_when(
      gunlaw == 1 ~ 1L,
      gunlaw == 2 ~ 0L,
      TRUE ~ NA_integer_
    )
  )

# Placebo outcomes (should NOT be affected by fear)
# natspac: spending on space exploration
gss <- gss %>%
  mutate(
    want_more_space_spending = case_when(
      natspac == 1 ~ 1L,
      natspac %in% c(2, 3) ~ 0L,
      TRUE ~ NA_integer_
    )
  )
# natsci: spending on science
gss <- gss %>%
  mutate(
    want_more_sci_spending = case_when(
      natsci == 1 ~ 1L,
      natsci %in% c(2, 3) ~ 0L,
      TRUE ~ NA_integer_
    )
  )
# natenvir: spending on environment
gss <- gss %>%
  mutate(
    want_more_envir_spending = case_when(
      natenvir == 1 ~ 1L,
      natenvir %in% c(2, 3) ~ 0L,
      TRUE ~ NA_integer_
    )
  )

# --- Covariates ---
gss <- gss %>%
  mutate(
    # Demographics
    female = as.integer(sex == 2),
    age_c = age - 45,  # centered
    age_sq = age_c^2,
    black = as.integer(race == 2),
    other_race = as.integer(race == 3),

    # Education
    educ_years = as.numeric(educ),
    college = as.integer(degree >= 3),  # bachelor's or higher
    hs_or_less = as.integer(degree <= 1),

    # Parents' education (impute median if missing)
    maeduc_imp = ifelse(is.na(maeduc), median(maeduc, na.rm = TRUE), maeduc),
    paeduc_imp = ifelse(is.na(paeduc), median(paeduc, na.rm = TRUE), paeduc),
    parent_educ_avg = (maeduc_imp + paeduc_imp) / 2,

    # Family
    married = as.integer(marital == 1),
    has_children = as.integer(childs > 0),
    n_children = pmin(childs, 6),  # top-code at 6

    # Income (log real income, handle zeros/NAs)
    log_realinc = log(pmax(realinc, 1)),

    # Political (polviews: 1-7, 1=extremely liberal, 7=extremely conservative)
    conservative = case_when(
      polviews >= 5 ~ 1L,
      polviews <= 3 ~ 0L,
      polviews == 4 ~ 0L,  # moderate
      TRUE ~ NA_integer_
    ),
    polviews_c = polviews - 4,  # centered at moderate

    # Party ID (partyid: 0-7, 0=strong Dem, 6=strong Rep, 7=other)
    republican = case_when(
      partyid %in% c(5, 6) ~ 1L,
      partyid %in% c(0, 1, 2, 3, 4) ~ 0L,
      TRUE ~ NA_integer_
    ),

    # Geography
    region_f = factor(region, levels = 1:4,
                      labels = c("Northeast", "Midwest", "South", "West")),
    urban = as.integer(srcbelt %in% c(1, 2, 3)),  # central city or suburbs

    # Decade (for heterogeneity)
    decade = floor(year / 10) * 10,
    period = case_when(
      year <= 1985 ~ "1973-1985",
      year <= 1995 ~ "1986-1995",
      year <= 2005 ~ "1996-2005",
      year <= 2015 ~ "2006-2015",
      TRUE ~ "2016-2024"
    ),
    period_f = factor(period, levels = c("1973-1985", "1986-1995",
                                          "1996-2005", "2006-2015",
                                          "2016-2024"))
  )

# Merge national crime rates
gss <- left_join(gss, crime, by = "year")

# --- Analysis Sample ---
# Main sample: non-missing fear + at least one outcome + key covariates
gss_analysis <- gss %>%
  filter(
    !is.na(afraid),
    !is.na(age),
    !is.na(female),
    !is.na(race),
    !is.na(educ_years),
    !is.na(region),
    age >= 18 & age <= 89
  )

cat("\n=== Analysis Sample ===\n")
cat("Total obs:", nrow(gss_analysis), "\n")
cat("Years:", min(gss_analysis$year), "-", max(gss_analysis$year), "\n")
cat("Unique years:", length(unique(gss_analysis$year)), "\n")

# Outcome coverage
outcomes <- c("favor_deathpen", "courts_too_lenient",
              "want_more_crime_spending", "favor_gun_permits")
for (v in outcomes) {
  cat(sprintf("  %s: %d valid obs\n", v, sum(!is.na(gss_analysis[[v]]))))
}

# Treatment distribution by decade
cat("\nFear of crime by decade:\n")
gss_analysis %>%
  group_by(decade) %>%
  summarise(
    n = n(),
    pct_afraid = round(100 * mean(afraid, na.rm = TRUE), 1),
    .groups = "drop"
  ) %>%
  print()

saveRDS(gss_analysis, file = "../data/gss_analysis.rds")
cat("\nSaved: ../data/gss_analysis.rds\n")

cat("=== Data Cleaning Complete ===\n")
