###############################################################################
# 03_main_analysis.R — Main Analysis for "Divine Forgiveness Beliefs"
# Paper: apep_0218
#
# Produces descriptive and correlational analyses across five datasets:
#   GSS (individual US), EA (cross-cultural), SCCS, Pulotu, Seshat, FRED
#
# All key results saved as RDS files in ../data/ for tables/figures scripts.
###############################################################################

source("00_packages.R")

cat("\n========================================================================\n")
cat("  MAIN ANALYSIS: Divine Forgiveness Beliefs (apep_0218)\n")
cat("========================================================================\n\n")

# --------------------------------------------------------------------------
# Load cleaned data
# --------------------------------------------------------------------------
gss     <- readRDS("../data/gss_clean.rds")
ea      <- readRDS("../data/ea_clean.rds")
sccs    <- readRDS("../data/sccs_clean.rds")
sccs_hg <- readRDS("../data/sccs_highgods.rds")
pulotu  <- readRDS("../data/pulotu_clean.rds")
pq      <- readRDS("../data/pulotu_questions.rds")
seshat  <- readRDS("../data/seshat_clean.rds")
fred    <- readRDS("../data/fred_annual.rds")

cat("Data loaded successfully.\n")
cat("  GSS:      ", nrow(gss), "rows x", ncol(gss), "cols\n")
cat("  EA:       ", nrow(ea), "rows x", ncol(ea), "cols\n")
cat("  SCCS:     ", nrow(sccs), "rows x", ncol(sccs), "cols\n")
cat("  SCCS HG:  ", nrow(sccs_hg), "rows x", ncol(sccs_hg), "cols\n")
cat("  Pulotu:   ", nrow(pulotu), "rows x", ncol(pulotu), "cols\n")
cat("  Seshat:   ", nrow(seshat), "rows x", ncol(seshat), "cols\n")
cat("  FRED:     ", nrow(fred), "rows x", ncol(fred), "cols\n\n")


###############################################################################
#  PART 1: DESCRIPTIVE ANALYSIS
###############################################################################

cat("====================================================================\n")
cat("  PART 1: DESCRIPTIVE ANALYSIS\n")
cat("====================================================================\n\n")

# --------------------------------------------------------------------------
# 1. Summary statistics for all divine belief variables (GSS)
# --------------------------------------------------------------------------
cat("--- 1. GSS Summary Statistics: Divine Belief Variables ---\n\n")

# Define the key divine belief variables
belief_vars <- c("heaven", "hell", "afterlif", "god", "judge", "master",
                 "lover", "friend", "creator", "healer", "father", "mother",
                 "king", "spouse", "redeemer", "cope4", "forgive3")

# Compute summary statistics for each variable
belief_summary <- map_dfr(belief_vars, function(v) {
  x <- as.numeric(gss[[v]])
  tibble(
    variable = v,
    n_obs    = sum(!is.na(x)),
    n_miss   = sum(is.na(x)),
    pct_miss = round(100 * mean(is.na(x)), 1),
    mean     = round(mean(x, na.rm = TRUE), 3),
    sd       = round(sd(x, na.rm = TRUE), 3),
    min      = min(x, na.rm = TRUE),
    max      = max(x, na.rm = TRUE)
  )
})

print(belief_summary, n = Inf)
cat("\n")

# For binary belief variables, compute prevalence rates
binary_beliefs <- c("heaven", "hell", "afterlif")
binary_summary <- map_dfr(binary_beliefs, function(v) {
  x <- gss[[v]]
  x <- x[!is.na(x)]
  tibble(
    variable    = v,
    n           = length(x),
    pct_yes     = round(100 * mean(x == 1), 1),
    pct_no      = round(100 * mean(x == 0), 1)
  )
})
cat("Binary belief prevalence (% yes):\n")
print(binary_summary)
cat("\n")

# God confidence: recode to labeled categories
god_labels <- c(
  "1" = "Don't believe",
  "2" = "No way to find out",
  "3" = "Higher power",
  "4" = "Believe sometimes",
  "5" = "Believe with doubts",
  "6" = "No doubts"
)
god_dist <- gss %>%
  filter(!is.na(god)) %>%
  mutate(god_num = as.numeric(god)) %>%
  count(god_num) %>%
  mutate(
    label = god_labels[as.character(god_num)],
    pct   = round(100 * n / sum(n), 1)
  )
cat("God confidence distribution:\n")
print(god_dist)
cat("\n")

# Save
saveRDS(belief_summary, "../data/results_belief_summary.rds")
saveRDS(god_dist, "../data/results_god_dist.rds")


# --------------------------------------------------------------------------
# 2. Cross-tabulations by religious tradition
# --------------------------------------------------------------------------
cat("--- 2. Cross-tabulations by Religious Tradition ---\n\n")

# Ensure relig_cat is a factor with meaningful order
gss <- gss %>%
  mutate(relig_cat = factor(relig_cat,
    levels = c("Protestant", "Catholic", "Jewish", "None", "Other")))

# Heaven, hell, afterlife rates by tradition
belief_by_relig <- gss %>%
  filter(!is.na(relig_cat)) %>%
  group_by(relig_cat) %>%
  summarise(
    n_total        = n(),
    n_heaven       = sum(!is.na(heaven)),
    pct_heaven     = round(100 * mean(heaven, na.rm = TRUE), 1),
    n_hell         = sum(!is.na(hell)),
    pct_hell       = round(100 * mean(hell, na.rm = TRUE), 1),
    n_afterlife    = sum(!is.na(afterlif)),
    pct_afterlife  = round(100 * mean(afterlif, na.rm = TRUE), 1),
    .groups = "drop"
  )
cat("Belief rates by religious tradition:\n")
print(belief_by_relig)
cat("\n")

# God-image means by tradition (1-4 scale, where 1 = extremely well)
god_image_vars <- c("judge", "master", "lover", "friend", "creator",
                    "healer", "father", "mother", "king", "spouse", "redeemer")

god_image_by_relig <- gss %>%
  filter(!is.na(relig_cat)) %>%
  group_by(relig_cat) %>%
  summarise(
    across(all_of(god_image_vars),
           list(mean = ~round(mean(.x, na.rm = TRUE), 2),
                n    = ~sum(!is.na(.x))),
           .names = "{.col}_{.fn}"),
    .groups = "drop"
  )
cat("God image means by tradition (1=extremely well, 4=not at all):\n")
print(god_image_by_relig, width = 200)
cat("\n")

# Cope4 and Forgive3 by tradition
cope_forgive_by_relig <- gss %>%
  filter(!is.na(relig_cat)) %>%
  group_by(relig_cat) %>%
  summarise(
    cope4_mean    = round(mean(cope4, na.rm = TRUE), 2),
    cope4_n       = sum(!is.na(cope4)),
    forgive3_mean = round(mean(forgive3, na.rm = TRUE), 2),
    forgive3_n    = sum(!is.na(forgive3)),
    .groups = "drop"
  )
cat("COPE4 (divine punishment) and FORGIVE3 (divine forgiveness) by tradition:\n")
print(cope_forgive_by_relig)
cat("\n")

saveRDS(belief_by_relig, "../data/results_belief_by_relig.rds")
saveRDS(god_image_by_relig, "../data/results_god_image_by_relig.rds")
saveRDS(cope_forgive_by_relig, "../data/results_cope_forgive_by_relig.rds")


# --------------------------------------------------------------------------
# 3. Time trends: heaven, hell, afterlife by year
# --------------------------------------------------------------------------
cat("--- 3. Time Trends: Heaven, Hell, Afterlife ---\n\n")

# Aggregate belief rates by year (only years that have data)
time_trends <- gss %>%
  group_by(year) %>%
  summarise(
    n_heaven   = sum(!is.na(heaven)),
    pct_heaven = ifelse(n_heaven > 0, round(100 * mean(heaven, na.rm = TRUE), 1), NA),
    n_hell     = sum(!is.na(hell)),
    pct_hell   = ifelse(n_hell > 0, round(100 * mean(hell, na.rm = TRUE), 1), NA),
    n_afterlif = sum(!is.na(afterlif)),
    pct_afterlif = ifelse(n_afterlif > 0, round(100 * mean(afterlif, na.rm = TRUE), 1), NA),
    .groups = "drop"
  ) %>%
  # Keep only years that have at least one belief measure
  filter(n_heaven > 0 | n_hell > 0 | n_afterlif > 0)

cat("Belief rates over time (years with data):\n")
print(time_trends, n = Inf)
cat("\n")

# Also track God-confidence over time (more years available)
god_trends <- gss %>%
  filter(!is.na(god)) %>%
  mutate(god_num = as.numeric(god)) %>%
  group_by(year) %>%
  summarise(
    n         = n(),
    mean_god  = round(mean(god_num, na.rm = TRUE), 2),
    pct_no_doubts = round(100 * mean(god_num == 6, na.rm = TRUE), 1),
    pct_dont_believe = round(100 * mean(god_num == 1, na.rm = TRUE), 1),
    .groups = "drop"
  )
cat("God confidence over time:\n")
print(god_trends, n = Inf)
cat("\n")

saveRDS(time_trends, "../data/results_time_trends.rds")
saveRDS(god_trends, "../data/results_god_trends.rds")


# --------------------------------------------------------------------------
# 4. God-image analysis: distribution of images
# --------------------------------------------------------------------------
cat("--- 4. God-Image Analysis ---\n\n")

# God image variables use 1-4 scale (1=extremely well, 4=not at all well)
# Recode to "high agreement" (1 or 2) vs "low agreement" (3 or 4)
god_image_dist <- map_dfr(god_image_vars, function(v) {
  x <- gss[[v]]
  x <- x[!is.na(x)]
  tibble(
    image        = v,
    n            = length(x),
    mean         = round(mean(x), 2),
    pct_agree    = round(100 * mean(x <= 2), 1),  # 1 or 2 = agrees image fits
    pct_disagree = round(100 * mean(x >= 3), 1)   # 3 or 4 = disagrees
  )
}) %>%
  arrange(mean)  # Sort by agreement level (lower mean = more agreement)

cat("God-image agreement (1=extremely well, 4=not at all):\n")
print(god_image_dist, n = Inf)
cat("\n")

# Punitive vs. forgiving image comparison
# "Judge" and "King" and "Master" = punitive/authoritarian images
# "Lover", "Friend", "Healer", "Mother" = benevolent/forgiving images
gss_images <- gss %>%
  filter(!is.na(judge) & !is.na(lover)) %>%
  mutate(
    punitive_index   = rowMeans(cbind(judge, master, king), na.rm = TRUE),
    benevolent_index = rowMeans(cbind(lover, friend, healer, mother), na.rm = TRUE),
    # Lower values = more agreement; so "gap" measures relative forgiving emphasis
    forgiveness_gap  = punitive_index - benevolent_index
  )

cat("Punitive vs. Benevolent God-Image Indices:\n")
cat("  Punitive (judge/master/king):     mean =", round(mean(gss_images$punitive_index, na.rm = TRUE), 3),
    " SD =", round(sd(gss_images$punitive_index, na.rm = TRUE), 3), "\n")
cat("  Benevolent (lover/friend/healer/mother): mean =", round(mean(gss_images$benevolent_index, na.rm = TRUE), 3),
    " SD =", round(sd(gss_images$benevolent_index, na.rm = TRUE), 3), "\n")
cat("  Forgiveness gap (punitive - benevolent): mean =", round(mean(gss_images$forgiveness_gap, na.rm = TRUE), 3),
    " SD =", round(sd(gss_images$forgiveness_gap, na.rm = TRUE), 3), "\n")
cat("  N =", nrow(gss_images), "\n\n")

# Correlation matrix among god images
god_image_mat <- gss %>%
  select(all_of(god_image_vars)) %>%
  drop_na() %>%
  as.data.frame()

if (nrow(god_image_mat) > 30) {
  god_image_cor <- round(cor(god_image_mat), 3)
  cat("God-image correlation matrix (N =", nrow(god_image_mat), "):\n")
  print(god_image_cor)
  cat("\n")
  saveRDS(god_image_cor, "../data/results_god_image_cor.rds")
}

saveRDS(god_image_dist, "../data/results_god_image_dist.rds")
saveRDS(gss_images %>% select(year, relig_cat, punitive_index, benevolent_index, forgiveness_gap),
        "../data/results_god_image_indices.rds")


# --------------------------------------------------------------------------
# 5. COPE4 vs FORGIVE3 distributions and correlations
# --------------------------------------------------------------------------
cat("--- 5. COPE4 (Divine Punishment) vs FORGIVE3 (Divine Forgiveness) ---\n\n")

# COPE4: "Felt punished by God for lack of devotion" (1-4 scale)
# FORGIVE3: "Sought God's love and care" or similar forgiveness item

cope4_dist <- gss %>%
  filter(!is.na(cope4)) %>%
  count(cope4) %>%
  mutate(pct = round(100 * n / sum(n), 1))
cat("COPE4 distribution (N =", sum(cope4_dist$n), "):\n")
print(cope4_dist)
cat("\n")

forgive3_dist <- gss %>%
  filter(!is.na(forgive3)) %>%
  count(forgive3) %>%
  mutate(pct = round(100 * n / sum(n), 1))
cat("FORGIVE3 distribution (N =", sum(forgive3_dist$n), "):\n")
print(forgive3_dist)
cat("\n")

# Correlation between cope4 and forgive3
cope_forgive_data <- gss %>%
  filter(!is.na(cope4) & !is.na(forgive3))

if (nrow(cope_forgive_data) > 30) {
  cf_cor <- cor.test(cope_forgive_data$cope4, cope_forgive_data$forgive3)
  cat("Correlation between COPE4 and FORGIVE3:\n")
  cat("  r =", round(cf_cor$estimate, 3), "\n")
  cat("  t =", round(cf_cor$statistic, 3), "\n")
  cat("  p =", format.pval(cf_cor$p.value, digits = 4), "\n")
  cat("  N =", nrow(cope_forgive_data), "\n\n")

  # Cross-tabulation
  cf_cross <- table(cope_forgive_data$cope4, cope_forgive_data$forgive3)
  cat("Cross-tabulation (COPE4 rows x FORGIVE3 cols):\n")
  print(cf_cross)
  cat("\n")

  saveRDS(cf_cor, "../data/results_cope_forgive_cor.rds")
  saveRDS(cf_cross, "../data/results_cope_forgive_cross.rds")
}

# Also correlate with god-image variables where available
cope_image_data <- gss %>%
  filter(!is.na(cope4)) %>%
  select(cope4, forgive3, all_of(god_image_vars), heaven, hell, afterlif) %>%
  select(where(~sum(!is.na(.x)) > 30))

if (ncol(cope_image_data) > 2) {
  cope_cors <- cor(cope_image_data, use = "pairwise.complete.obs")
  cat("Correlation matrix (cope4/forgive3 with other beliefs):\n")
  print(round(cope_cors, 3))
  cat("\n")
  saveRDS(round(cope_cors, 3), "../data/results_cope_image_cors.rds")
}

saveRDS(cope4_dist, "../data/results_cope4_dist.rds")
saveRDS(forgive3_dist, "../data/results_forgive3_dist.rds")


# --------------------------------------------------------------------------
# 6. EA034 High Gods distribution across world regions
# --------------------------------------------------------------------------
cat("--- 6. EA034 High Gods Distribution Across World Regions ---\n\n")

ea_region_dist <- ea %>%
  filter(!is.na(high_gods_label)) %>%
  count(region, high_gods_label) %>%
  group_by(region) %>%
  mutate(
    region_total = sum(n),
    pct = round(100 * n / sum(n), 1)
  ) %>%
  ungroup() %>%
  arrange(region, high_gods_label)

# Aggregate by broad region groupings
ea_broad <- ea %>%
  filter(!is.na(high_gods_label)) %>%
  mutate(
    broad_region = case_when(
      grepl("Africa", region)   ~ "Africa",
      grepl("Europe|Caucasus", region) ~ "Europe",
      grepl("Asia|China|Mongolia|Siberia|Indo-China|Malesia|Indian", region) ~ "Asia",
      grepl("Pacific|Australia|New Zealand|Papuasia", region) ~ "Oceania",
      grepl("America|U.S.A.|Canada|Mexico|Brazil|Caribbean", region) ~ "Americas",
      grepl("Arab", region) ~ "Middle East",
      TRUE ~ "Other"
    )
  ) %>%
  count(broad_region, high_gods_label) %>%
  group_by(broad_region) %>%
  mutate(
    total = sum(n),
    pct   = round(100 * n / sum(n), 1)
  ) %>%
  ungroup()

cat("High Gods by broad region:\n")
ea_broad_wide <- ea_broad %>%
  select(broad_region, high_gods_label, pct) %>%
  pivot_wider(names_from = high_gods_label, values_from = pct, values_fill = 0)
print(ea_broad_wide)
cat("\n")

# Overall distribution
ea_overall <- ea %>%
  filter(!is.na(high_gods_label)) %>%
  count(high_gods_label) %>%
  mutate(pct = round(100 * n / sum(n), 1))
cat("Overall EA High Gods distribution (N =", sum(ea_overall$n), "):\n")
print(ea_overall)
cat("\n")

saveRDS(ea_region_dist, "../data/results_ea_region_dist.rds")
saveRDS(ea_broad, "../data/results_ea_broad_region.rds")
saveRDS(ea_overall, "../data/results_ea_overall.rds")


# --------------------------------------------------------------------------
# 7. SCCS High Gods distribution
# --------------------------------------------------------------------------
cat("--- 7. SCCS High Gods Distribution ---\n\n")

# SCCS238 is all NA in the main file; use the separate highgods file
sccs_hg_dist <- sccs_hg %>%
  count(Value) %>%
  mutate(pct = round(100 * n / sum(n), 1)) %>%
  arrange(desc(n))

cat("SCCS High Gods distribution (N =", sum(sccs_hg_dist$n), " societies):\n")
print(sccs_hg_dist)
cat("\n")

# By region
sccs_hg_region <- sccs_hg %>%
  count(region, Value) %>%
  group_by(region) %>%
  mutate(
    total = sum(n),
    pct   = round(100 * n / sum(n), 1)
  ) %>%
  ungroup() %>%
  arrange(region, Value)

# Broad region grouping
sccs_hg_broad <- sccs_hg %>%
  mutate(
    broad_region = case_when(
      grepl("Africa", region)   ~ "Africa",
      grepl("Europe|Caucasus", region) ~ "Europe",
      grepl("Asia|China|Mongolia|Siberia|Indo-China|Malesia|Indian", region) ~ "Asia",
      grepl("Pacific|Australia|New Zealand|Papuasia", region) ~ "Oceania",
      grepl("America|U.S.A.|Canada|Mexico|Brazil|Caribbean", region) ~ "Americas",
      grepl("Arab", region) ~ "Middle East",
      TRUE ~ "Other"
    )
  ) %>%
  count(broad_region, Value) %>%
  group_by(broad_region) %>%
  mutate(pct = round(100 * n / sum(n), 1)) %>%
  ungroup()

cat("SCCS High Gods by broad region:\n")
sccs_broad_wide <- sccs_hg_broad %>%
  select(broad_region, Value, pct) %>%
  pivot_wider(names_from = Value, values_from = pct, values_fill = 0)
print(sccs_broad_wide)
cat("\n")

saveRDS(sccs_hg_dist, "../data/results_sccs_hg_dist.rds")
saveRDS(sccs_hg_broad, "../data/results_sccs_hg_broad.rds")


# --------------------------------------------------------------------------
# 8. Pulotu supernatural punishment prevalence
# --------------------------------------------------------------------------
cat("--- 8. Pulotu Supernatural Punishment Prevalence ---\n\n")

# Parameter 7 = "Supernatural punishment for impiety" (0/1)
pulotu_sp <- pulotu %>%
  filter(!is.na(`7`)) %>%
  rename(sp_impiety = `7`)

sp_dist <- pulotu_sp %>%
  count(sp_impiety) %>%
  mutate(
    label = ifelse(sp_impiety == 1, "Present", "Absent"),
    pct   = round(100 * n / sum(n), 1)
  )
cat("Supernatural punishment for impiety (N =", sum(sp_dist$n), " cultures):\n")
print(sp_dist)
cat("\n")

# Related Pulotu belief variables
# 2 = God(s), 10 = afterlife actions of others, 11 = afterlife own actions
pulotu_beliefs <- pulotu %>%
  select(Language_ID, Name, Macroarea, Latitude, Longitude,
         gods = `2`, sp_impiety = `7`,
         afterlife_others = `10`, afterlife_self = `11`) %>%
  drop_na(sp_impiety)

pulotu_belief_summary <- tibble(
  variable = c("God(s) present", "Supernatural punishment",
               "Afterlife (others' actions)", "Afterlife (own actions)"),
  n_obs = c(sum(!is.na(pulotu_beliefs$gods)),
            sum(!is.na(pulotu_beliefs$sp_impiety)),
            sum(!is.na(pulotu_beliefs$afterlife_others)),
            sum(!is.na(pulotu_beliefs$afterlife_self))),
  pct_yes = c(
    round(100 * mean(pulotu_beliefs$gods == 1, na.rm = TRUE), 1),
    round(100 * mean(pulotu_beliefs$sp_impiety == 1, na.rm = TRUE), 1),
    round(100 * mean(pulotu_beliefs$afterlife_others == 1, na.rm = TRUE), 1),
    round(100 * mean(pulotu_beliefs$afterlife_self == 1, na.rm = TRUE), 1)
  )
)
cat("Pulotu belief prevalence summary:\n")
print(pulotu_belief_summary)
cat("\n")

# Cross-tab: supernatural punishment by geographic zone (latitude bands)
# Macroarea is unavailable (all NA), so use Latitude for geographic grouping
if ("Latitude" %in% names(pulotu_beliefs) && sum(!is.na(pulotu_beliefs$Latitude)) > 0) {
  sp_by_zone <- pulotu_beliefs %>%
    filter(!is.na(Latitude)) %>%
    mutate(
      geo_zone = case_when(
        abs(Latitude) <= 10 ~ "Equatorial (0-10)",
        abs(Latitude) <= 23.5 ~ "Tropical (10-23.5)",
        abs(Latitude) <= 35 ~ "Subtropical (23.5-35)",
        TRUE ~ "Temperate (35+)"
      )
    ) %>%
    group_by(geo_zone) %>%
    summarise(
      n = n(),
      pct_sp = round(100 * mean(sp_impiety == 1, na.rm = TRUE), 1),
      pct_gods = round(100 * mean(gods == 1, na.rm = TRUE), 1),
      .groups = "drop"
    ) %>%
    arrange(desc(pct_sp))
  cat("Supernatural punishment by geographic zone (Austronesian societies):\n")
  print(sp_by_zone)
  cat("\n")
  saveRDS(sp_by_zone, "../data/results_pulotu_sp_zone.rds")
} else {
  cat("  No geographic data available for Pulotu sub-group analysis.\n\n")
}

saveRDS(sp_dist, "../data/results_pulotu_sp_dist.rds")
saveRDS(pulotu_belief_summary, "../data/results_pulotu_belief_summary.rds")


# --------------------------------------------------------------------------
# 9. Seshat moralizing supernatural punishment over time
# --------------------------------------------------------------------------
cat("--- 9. Seshat MSP Over Time ---\n\n")

# Create century variable from midpoint of Start-End
seshat <- seshat %>%
  mutate(
    midpoint = (Start + End) / 2,
    century  = floor(midpoint / 100) * 100
  )

# MSP (moralizing supernatural punishment) by century
seshat_by_century <- seshat %>%
  group_by(century) %>%
  summarise(
    n_polities = n(),
    mean_MSP     = round(mean(MSP, na.rm = TRUE), 3),
    mean_MSP_sum = round(mean(MSP_sum, na.rm = TRUE), 2),
    mean_minMSP  = round(mean(minMSP, na.rm = TRUE), 3),
    pct_afterlife = round(100 * mean(afterlife, na.rm = TRUE), 1),
    pct_thislife  = round(100 * mean(thislife, na.rm = TRUE), 1),
    .groups = "drop"
  ) %>%
  arrange(century)

cat("Seshat MSP by century:\n")
print(seshat_by_century, n = Inf)
cat("\n")

# By NGA (Natural Geographic Area)
seshat_by_nga <- seshat %>%
  group_by(NGA) %>%
  summarise(
    n          = n(),
    year_range = paste(min(Start), "to", max(End)),
    mean_MSP   = round(mean(MSP, na.rm = TRUE), 3),
    max_MSP    = round(max(MSP, na.rm = TRUE), 3),
    .groups = "drop"
  ) %>%
  arrange(desc(mean_MSP))

cat("Seshat MSP by Natural Geographic Area:\n")
print(seshat_by_nga, n = Inf)
cat("\n")

# Track emergence of afterlife beliefs
seshat_afterlife_emergence <- seshat %>%
  filter(!is.na(afterlife)) %>%
  group_by(NGA) %>%
  summarise(
    first_afterlife_century = min(century[afterlife > 0], na.rm = TRUE),
    .groups = "drop"
  ) %>%
  filter(is.finite(first_afterlife_century))

cat("First century with afterlife beliefs by NGA:\n")
print(seshat_afterlife_emergence, n = Inf)
cat("\n")

saveRDS(seshat_by_century, "../data/results_seshat_century.rds")
saveRDS(seshat_by_nga, "../data/results_seshat_nga.rds")
saveRDS(seshat_afterlife_emergence, "../data/results_seshat_afterlife_emergence.rds")


###############################################################################
#  PART 2: CORRELATIONAL ANALYSIS
###############################################################################

cat("\n====================================================================\n")
cat("  PART 2: CORRELATIONAL ANALYSIS\n")
cat("====================================================================\n\n")

# --------------------------------------------------------------------------
# 10. OLS: Hell belief ~ demographics + religiosity
# --------------------------------------------------------------------------
cat("--- 10. OLS: Hell Belief ~ Controls ---\n\n")

gss_reg <- gss %>%
  filter(!is.na(hell) & !is.na(age_num) & !is.na(female) &
         !is.na(educ_num) & !is.na(realinc_num) & !is.na(attend_num) &
         !is.na(relig_cat)) %>%
  mutate(
    realinc_10k = realinc_num / 10000,
    age_10 = age_num / 10
  )

cat("Regression sample (hell model): N =", nrow(gss_reg), "\n\n")

ols_hell <- feols(hell ~ age_10 + female + educ_num + realinc_10k +
                    attend_num + i(relig_cat, ref = "Protestant"),
                  data = gss_reg, vcov = "hetero")

cat("OLS: Belief in Hell\n")
summary(ols_hell)
cat("\n")


# --------------------------------------------------------------------------
# 11. OLS: Heaven belief ~ same controls
# --------------------------------------------------------------------------
cat("--- 11. OLS: Heaven Belief ~ Controls ---\n\n")

gss_reg_heaven <- gss %>%
  filter(!is.na(heaven) & !is.na(age_num) & !is.na(female) &
         !is.na(educ_num) & !is.na(realinc_num) & !is.na(attend_num) &
         !is.na(relig_cat)) %>%
  mutate(
    realinc_10k = realinc_num / 10000,
    age_10 = age_num / 10
  )

cat("Regression sample (heaven model): N =", nrow(gss_reg_heaven), "\n\n")

ols_heaven <- feols(heaven ~ age_10 + female + educ_num + realinc_10k +
                      attend_num + i(relig_cat, ref = "Protestant"),
                    data = gss_reg_heaven, vcov = "hetero")

cat("OLS: Belief in Heaven\n")
summary(ols_heaven)
cat("\n")


# --------------------------------------------------------------------------
# 12. OLS: Forgive3 ~ same controls (subset with data)
# --------------------------------------------------------------------------
cat("--- 12. OLS: FORGIVE3 (Divine Forgiveness) ~ Controls ---\n\n")

gss_reg_forgive <- gss %>%
  filter(!is.na(forgive3) & !is.na(age_num) & !is.na(female) &
         !is.na(educ_num) & !is.na(realinc_num) & !is.na(attend_num) &
         !is.na(relig_cat)) %>%
  mutate(
    realinc_10k = realinc_num / 10000,
    age_10 = age_num / 10
  )

cat("Regression sample (forgive3 model): N =", nrow(gss_reg_forgive), "\n")

if (nrow(gss_reg_forgive) >= 30) {
  ols_forgive <- feols(forgive3 ~ age_10 + female + educ_num + realinc_10k +
                         attend_num + i(relig_cat, ref = "Protestant"),
                       data = gss_reg_forgive, vcov = "hetero")
  cat("\nOLS: FORGIVE3 (Divine Forgiveness)\n")
  summary(ols_forgive)
} else {
  cat("  Insufficient observations for regression.\n")
  ols_forgive <- NULL
}
cat("\n")


# --------------------------------------------------------------------------
# 13. OLS: Cope4 ~ same controls (subset with data)
# --------------------------------------------------------------------------
cat("--- 13. OLS: COPE4 (Divine Punishment) ~ Controls ---\n\n")

gss_reg_cope <- gss %>%
  filter(!is.na(cope4) & !is.na(age_num) & !is.na(female) &
         !is.na(educ_num) & !is.na(realinc_num) & !is.na(attend_num) &
         !is.na(relig_cat)) %>%
  mutate(
    realinc_10k = realinc_num / 10000,
    age_10 = age_num / 10
  )

cat("Regression sample (cope4 model): N =", nrow(gss_reg_cope), "\n")

if (nrow(gss_reg_cope) >= 30) {
  ols_cope <- feols(cope4 ~ age_10 + female + educ_num + realinc_10k +
                      attend_num + i(relig_cat, ref = "Protestant"),
                    data = gss_reg_cope, vcov = "hetero")
  cat("\nOLS: COPE4 (Divine Punishment)\n")
  summary(ols_cope)
} else {
  cat("  Insufficient observations for regression.\n")
  ols_cope <- NULL
}
cat("\n")


# --------------------------------------------------------------------------
# 14. OLS: Judge (God as judge image) ~ same controls
# --------------------------------------------------------------------------
cat("--- 14. OLS: Judge (God-as-Judge Image) ~ Controls ---\n\n")

gss_reg_judge <- gss %>%
  filter(!is.na(judge) & !is.na(age_num) & !is.na(female) &
         !is.na(educ_num) & !is.na(realinc_num) & !is.na(attend_num) &
         !is.na(relig_cat)) %>%
  mutate(
    realinc_10k = realinc_num / 10000,
    age_10 = age_num / 10
  )

cat("Regression sample (judge model): N =", nrow(gss_reg_judge), "\n")

if (nrow(gss_reg_judge) >= 30) {
  ols_judge <- feols(judge ~ age_10 + female + educ_num + realinc_10k +
                       attend_num + i(relig_cat, ref = "Protestant"),
                     data = gss_reg_judge, vcov = "hetero")
  cat("\nOLS: God as Judge Image (1=extremely well, 4=not at all)\n")
  summary(ols_judge)
} else {
  cat("  Insufficient observations for regression.\n")
  ols_judge <- NULL
}
cat("\n")

# --------------------------------------------------------------------------
# Combined regression table: all five OLS models
# --------------------------------------------------------------------------
cat("--- Combined OLS Regression Summary ---\n\n")

ols_models <- list(
  "Hell"      = ols_hell,
  "Heaven"    = ols_heaven,
  "Forgive3"  = ols_forgive,
  "Cope4"     = ols_cope,
  "Judge"     = ols_judge
)

# Remove NULL models
ols_models <- ols_models[!sapply(ols_models, is.null)]

# Extract key coefficients for comparison
ols_comparison <- map_dfr(names(ols_models), function(nm) {
  m <- ols_models[[nm]]
  ct <- coeftable(m)
  tibble(
    model    = nm,
    variable = rownames(ct),
    estimate = round(ct[, 1], 4),
    se       = round(ct[, 2], 4),
    tstat    = round(ct[, 3], 3),
    pvalue   = fixest::pvalue(m)
  )
})

cat("Key coefficient comparison across models:\n")
# Focus on main variables of interest
key_vars <- c("age_10", "female", "educ_num", "realinc_10k", "attend_num")
ols_key <- ols_comparison %>%
  filter(variable %in% key_vars) %>%
  select(model, variable, estimate, se, pvalue) %>%
  mutate(sig = case_when(
    pvalue < 0.001 ~ "***",
    pvalue < 0.01  ~ "**",
    pvalue < 0.05  ~ "*",
    pvalue < 0.10  ~ "+",
    TRUE           ~ ""
  ))
print(ols_key, n = Inf)
cat("\n")

saveRDS(ols_models, "../data/results_ols_models.rds")
saveRDS(ols_comparison, "../data/results_ols_comparison.rds")


# --------------------------------------------------------------------------
# 15. Cross-cultural correlations: SCCS high gods and covariates
# --------------------------------------------------------------------------
cat("--- 15. Cross-Cultural Correlations: SCCS ---\n\n")

# Merge high gods data into SCCS main data
sccs_hg_merged <- sccs_hg %>%
  select(Soc_ID, Value, Code_ID) %>%
  mutate(
    high_gods_num = case_when(
      Code_ID == "SCCS238-1" ~ 0,  # Absent
      Code_ID == "SCCS238-2" ~ 1,  # Otiose
      Code_ID == "SCCS238-3" ~ 2,  # Active, not moralizing
      Code_ID == "SCCS238-4" ~ 3,  # Active, moralizing
      TRUE ~ NA_real_
    )
  ) %>%
  left_join(sccs, by = "Soc_ID")

cat("Merged SCCS+highgods: N =", nrow(sccs_hg_merged), "\n\n")

# Available numeric SCCS covariates with data
sccs_num_vars <- c("SCCS814", "SCCS821", "SCCS826", "SCCS834",
                   "SCCS885", "SCCS886", "SCCS887", "SCCS888", "SCCS889")

# These are environmental/cultural variables. Compute correlations with high gods.
sccs_cors <- map_dfr(sccs_num_vars, function(v) {
  d <- sccs_hg_merged %>%
    filter(!is.na(high_gods_num) & !is.na(.data[[v]]))
  if (nrow(d) < 10) {
    return(tibble(variable = v, n = nrow(d), r = NA, p = NA))
  }
  ct <- cor.test(d$high_gods_num, d[[v]])
  tibble(
    variable = v,
    n        = nrow(d),
    r        = round(ct$estimate, 3),
    p        = round(ct$p.value, 4)
  )
})

cat("Correlations: SCCS high gods (0-3) with available covariates:\n")
sccs_cors <- sccs_cors %>%
  mutate(sig = case_when(
    p < 0.001 ~ "***",
    p < 0.01  ~ "**",
    p < 0.05  ~ "*",
    p < 0.10  ~ "+",
    TRUE       ~ ""
  ))
print(sccs_cors, n = Inf)
cat("\n")

# Also: high gods distribution by Latitude bands (proxy for ecology)
sccs_lat_bands <- sccs_hg_merged %>%
  filter(!is.na(high_gods_num) & !is.na(Latitude)) %>%
  mutate(lat_band = cut(abs(Latitude),
                        breaks = c(0, 10, 23.5, 40, 90),
                        labels = c("Tropical (0-10)", "Subtropical (10-23.5)",
                                   "Temperate (23.5-40)", "High latitude (40+)"))) %>%
  group_by(lat_band) %>%
  summarise(
    n = n(),
    mean_high_gods = round(mean(high_gods_num), 2),
    pct_moralizing = round(100 * mean(high_gods_num == 3), 1),
    .groups = "drop"
  )

cat("SCCS high gods by latitude band:\n")
print(sccs_lat_bands)
cat("\n")

saveRDS(sccs_cors, "../data/results_sccs_cors.rds")
saveRDS(sccs_lat_bands, "../data/results_sccs_lat_bands.rds")


# --------------------------------------------------------------------------
# 16. Macro analysis: GSS beliefs by year merged with FRED
# --------------------------------------------------------------------------
cat("--- 16. Macro Analysis: GSS Beliefs x FRED Economic Indicators ---\n\n")

# Aggregate GSS beliefs by year
gss_yearly <- gss %>%
  group_by(year) %>%
  summarise(
    n_respondents  = n(),
    # Binary beliefs (available in select years)
    pct_heaven     = ifelse(sum(!is.na(heaven)) > 10,
                           mean(heaven, na.rm = TRUE), NA),
    pct_hell       = ifelse(sum(!is.na(hell)) > 10,
                           mean(hell, na.rm = TRUE), NA),
    pct_afterlife  = ifelse(sum(!is.na(afterlif)) > 10,
                           mean(afterlif, na.rm = TRUE), NA),
    # God confidence (more years)
    mean_god       = ifelse(sum(!is.na(god)) > 10,
                           mean(as.numeric(god), na.rm = TRUE), NA),
    pct_no_doubts  = ifelse(sum(!is.na(god)) > 10,
                           mean(as.numeric(god) == 6, na.rm = TRUE), NA),
    # Church attendance
    mean_attend    = ifelse(sum(!is.na(attend_num)) > 10,
                           mean(attend_num, na.rm = TRUE), NA),
    .groups = "drop"
  )

# Merge with FRED
gss_fred <- gss_yearly %>%
  inner_join(fred, by = "year")

cat("GSS-FRED merged data: N =", nrow(gss_fred), " years\n\n")

# Rename FRED variables for clarity
gss_fred <- gss_fred %>%
  rename(
    gdp_growth  = A191RL1Q225SBEA,
    population  = B230RC0A052NBEA,
    gini        = GINIALLRF,
    med_income  = MEHOINUSA672N,
    unemp       = UNRATE
  )

# Correlations: economic indicators with religious beliefs
econ_vars <- c("gdp_growth", "gini", "unemp", "med_income")
belief_year_vars <- c("pct_heaven", "pct_hell", "pct_afterlife",
                      "mean_god", "pct_no_doubts", "mean_attend")

# Build correlation matrix
macro_cors <- map_dfr(econ_vars, function(ev) {
  map_dfr(belief_year_vars, function(bv) {
    d <- gss_fred %>% filter(!is.na(.data[[ev]]) & !is.na(.data[[bv]]))
    if (nrow(d) < 5) {
      return(tibble(econ_var = ev, belief_var = bv, n = nrow(d),
                    r = NA, p = NA))
    }
    ct <- cor.test(d[[ev]], d[[bv]])
    tibble(
      econ_var  = ev,
      belief_var = bv,
      n         = nrow(d),
      r         = round(ct$estimate, 3),
      p         = round(ct$p.value, 4)
    )
  })
})

macro_cors <- macro_cors %>%
  mutate(sig = case_when(
    is.na(p) ~ "",
    p < 0.001 ~ "***",
    p < 0.01  ~ "**",
    p < 0.05  ~ "*",
    p < 0.10  ~ "+",
    TRUE       ~ ""
  ))

cat("Macro correlations: Economic indicators x Religious beliefs (year-level):\n")
print(macro_cors, n = Inf)
cat("\n")

# Focus on the strongest relationships
strong_cors <- macro_cors %>%
  filter(!is.na(r)) %>%
  arrange(p)
cat("Strongest macro correlations:\n")
print(head(strong_cors, 10))
cat("\n")

# Time series: attendance and inequality
if (sum(!is.na(gss_fred$mean_attend) & !is.na(gss_fred$gini)) >= 5) {
  attend_gini <- cor.test(
    gss_fred$mean_attend[!is.na(gss_fred$mean_attend) & !is.na(gss_fred$gini)],
    gss_fred$gini[!is.na(gss_fred$mean_attend) & !is.na(gss_fred$gini)]
  )
  cat("Attendance-Inequality correlation:\n")
  cat("  r =", round(attend_gini$estimate, 3),
      " p =", round(attend_gini$p.value, 4),
      " N =", sum(!is.na(gss_fred$mean_attend) & !is.na(gss_fred$gini)), "\n\n")
}

# God confidence and unemployment
if (sum(!is.na(gss_fred$mean_god) & !is.na(gss_fred$unemp)) >= 5) {
  god_unemp <- cor.test(
    gss_fred$mean_god[!is.na(gss_fred$mean_god) & !is.na(gss_fred$unemp)],
    gss_fred$unemp[!is.na(gss_fred$mean_god) & !is.na(gss_fred$unemp)]
  )
  cat("God confidence-Unemployment correlation:\n")
  cat("  r =", round(god_unemp$estimate, 3),
      " p =", round(god_unemp$p.value, 4),
      " N =", sum(!is.na(gss_fred$mean_god) & !is.na(gss_fred$unemp)), "\n\n")
}

saveRDS(gss_fred, "../data/results_gss_fred.rds")
saveRDS(macro_cors, "../data/results_macro_cors.rds")


###############################################################################
#  SUMMARY OF ALL SAVED RESULTS
###############################################################################

cat("\n====================================================================\n")
cat("  RESULTS FILES SAVED\n")
cat("====================================================================\n\n")

result_files <- list.files("../data/", pattern = "^results_", full.names = TRUE)
for (f in sort(result_files)) {
  obj <- readRDS(f)
  dims <- if (is.data.frame(obj)) paste(nrow(obj), "x", ncol(obj)) else class(obj)[1]
  cat("  ", basename(f), " [", dims, "]\n")
}

cat("\n========================================================================\n")
cat("  ANALYSIS COMPLETE\n")
cat("========================================================================\n")
