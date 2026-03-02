###############################################################################
# 04_robustness.R - Robustness checks, permutation inference, placebo tests
# Paper: Where Cultural Borders Cross (apep_0439)
###############################################################################

source("code/00_packages.R")

gender_panel <- readRDS(file.path(data_dir, "gender_panel_final.rds"))
gender_index <- readRDS(file.path(data_dir, "gender_index.rds"))
results <- readRDS(file.path(data_dir, "main_results.rds"))
full_panel <- readRDS(file.path(data_dir, "full_panel.rds"))

# ============================================================================
# 1. ROBUSTNESS: ALTERNATIVE CLUSTERING
# ============================================================================
cat("=== Robustness 1: Alternative clustering ===\n")

# Baseline: cluster at municipality
r1_mun <- feols(yes_share ~ is_french * is_catholic | vote_date,
                data = gender_panel, cluster = ~mun_id)

# Cluster at canton level (26 clusters)
r1_canton <- feols(yes_share ~ is_french * is_catholic | vote_date,
                   data = gender_panel, cluster = ~canton_id)

# Two-way clustering: municipality + vote_date
r1_twoway <- feols(yes_share ~ is_french * is_catholic | vote_date,
                   data = gender_panel, cluster = ~mun_id + vote_date)

etable(r1_mun, r1_canton, r1_twoway,
       headers = c("Cluster: Mun", "Cluster: Canton", "Two-way"),
       dict = c(is_frenchTRUE = "French", is_catholicTRUE = "Catholic",
                "is_frenchTRUE:is_catholicTRUE" = "French × Catholic"))

# ============================================================================
# 2. ROBUSTNESS: WITHIN-CANTON ESTIMATION
# ============================================================================
cat("\n=== Robustness 2: Within-canton estimation ===\n")

# Canton FE absorbs all between-canton variation
# Language effect identified only from bilingual cantons (FR, BE, VS)
r2_canton_fe <- feols(yes_share ~ is_french * is_catholic | vote_date + canton_id,
                      data = gender_panel, cluster = ~mun_id)

# For religion: canton × referendum FE
r2_canton_ref_fe <- feols(yes_share ~ is_french | vote_date^canton_id,
                          data = gender_panel, cluster = ~mun_id)

etable(r2_canton_fe, r2_canton_ref_fe,
       headers = c("Canton FE", "Canton × Referendum FE"),
       dict = c(is_frenchTRUE = "French", is_catholicTRUE = "Catholic",
                "is_frenchTRUE:is_catholicTRUE" = "French × Catholic"))

# ============================================================================
# 3. PERMUTATION INFERENCE (500 iterations)
# ============================================================================
cat("\n=== Robustness 3: Permutation inference ===\n")

# Observed interaction coefficient
obs_interaction <- coef(results$m1_interaction)["is_frenchTRUE:is_catholicTRUE"]

# Permutation: randomly reassign French/Catholic labels across municipalities
set.seed(42)
n_perm <- 500
perm_coefs <- numeric(n_perm)

# Get unique municipality-level data
mun_data <- gender_panel %>%
  distinct(mun_id, .keep_all = TRUE) %>%
  select(mun_id, is_french, is_catholic)

for (i in seq_len(n_perm)) {
  if (i %% 100 == 0) cat("  Permutation", i, "/", n_perm, "\n")

  # Randomly shuffle language and religion labels
  shuffled <- mun_data %>%
    mutate(
      is_french_perm = sample(is_french),
      is_catholic_perm = sample(is_catholic)
    )

  # Merge permuted labels
  perm_panel <- gender_panel %>%
    select(-is_french, -is_catholic) %>%
    left_join(shuffled %>% select(mun_id, is_french_perm, is_catholic_perm),
              by = "mun_id") %>%
    rename(is_french = is_french_perm, is_catholic = is_catholic_perm)

  # Estimate permuted interaction
  fit_perm <- tryCatch({
    feols(yes_share ~ is_french * is_catholic | vote_date,
          data = perm_panel, cluster = ~mun_id)
  }, error = function(e) NULL)

  if (!is.null(fit_perm)) {
    perm_coefs[i] <- coef(fit_perm)["is_frenchTRUE:is_catholicTRUE"]
  } else {
    perm_coefs[i] <- NA
  }
}

# Permutation p-value
perm_coefs_valid <- perm_coefs[!is.na(perm_coefs)]
n_exceed_interaction <- sum(abs(perm_coefs_valid) >= abs(obs_interaction))
perm_p <- n_exceed_interaction / length(perm_coefs_valid)
cat("  Observed interaction:", round(obs_interaction, 4), "\n")
if (n_exceed_interaction == 0) {
  cat("  Permutation p-value (two-sided): < ", round(1/length(perm_coefs_valid), 4),
      " (0 of", length(perm_coefs_valid), "permutations exceed observed)\n")
} else {
  cat("  Permutation p-value (two-sided):", round(perm_p, 4), "\n")
}
cat("  N valid permutations:", length(perm_coefs_valid), "\n")

# Also compute permutation p for language main effect
obs_lang <- coef(results$m1_lang)["is_frenchTRUE"]
perm_lang_coefs <- numeric(n_perm)

set.seed(43)
for (i in seq_len(n_perm)) {
  if (i %% 100 == 0) cat("  Lang permutation", i, "/", n_perm, "\n")

  shuffled_lang <- mun_data %>%
    mutate(is_french_perm = sample(is_french))

  perm_panel_lang <- gender_panel %>%
    select(-is_french) %>%
    left_join(shuffled_lang %>% select(mun_id, is_french_perm), by = "mun_id") %>%
    rename(is_french = is_french_perm)

  fit_perm_lang <- tryCatch({
    feols(yes_share ~ is_french | vote_date, data = perm_panel_lang, cluster = ~mun_id)
  }, error = function(e) NULL)

  if (!is.null(fit_perm_lang)) {
    perm_lang_coefs[i] <- coef(fit_perm_lang)["is_frenchTRUE"]
  } else {
    perm_lang_coefs[i] <- NA
  }
}

perm_lang_valid <- perm_lang_coefs[!is.na(perm_lang_coefs)]
n_exceed_lang <- sum(abs(perm_lang_valid) >= abs(obs_lang))
perm_p_lang <- n_exceed_lang / length(perm_lang_valid)
if (n_exceed_lang == 0) {
  cat("  Language main effect permutation p: <", round(1/length(perm_lang_valid), 4),
      " (0 of", length(perm_lang_valid), "permutations exceed observed)\n")
} else {
  cat("  Language main effect permutation p:", round(perm_p_lang, 4), "\n")
}

# ============================================================================
# 4. ROBUSTNESS: INDIVIDUAL REFERENDUM ESTIMATES
# ============================================================================
cat("\n=== Robustness 4: Individual referendum estimates ===\n")

ref_results <- gender_panel %>%
  filter(!is.na(culture_4)) %>%
  group_by(vote_date, year) %>%
  group_modify(function(df, keys) {
    fit <- tryCatch(
      lm(yes_share ~ is_french * is_catholic, data = df),
      error = function(e) NULL
    )
    if (is.null(fit)) return(tibble())

    coefs <- summary(fit)$coefficients
    tibble(
      n = nrow(df),
      french = coefs["is_frenchTRUE", "Estimate"],
      french_se = coefs["is_frenchTRUE", "Std. Error"],
      french_p = coefs["is_frenchTRUE", "Pr(>|t|)"],
      catholic = if ("is_catholicTRUE" %in% rownames(coefs))
        coefs["is_catholicTRUE", "Estimate"] else NA,
      interaction = if ("is_frenchTRUE:is_catholicTRUE" %in% rownames(coefs))
        coefs["is_frenchTRUE:is_catholicTRUE", "Estimate"] else NA,
      interaction_se = if ("is_frenchTRUE:is_catholicTRUE" %in% rownames(coefs))
        coefs["is_frenchTRUE:is_catholicTRUE", "Std. Error"] else NA
    )
  }) %>%
  ungroup()

cat("Individual referendum results:\n")
print(ref_results %>% select(vote_date, year, french, catholic, interaction, n))

# ============================================================================
# 5. ROBUSTNESS: EXCLUDE URBAN MUNICIPALITIES
# ============================================================================
cat("\n=== Robustness 5: Exclude large cities ===\n")

# Exclude municipalities with >50,000 eligible voters (major cities)
r5_no_cities <- feols(
  yes_share ~ is_french * is_catholic | vote_date,
  data = gender_panel %>% filter(eligible < 50000),
  cluster = ~mun_id
)

cat("  Without large cities - interaction:",
    round(coef(r5_no_cities)["is_frenchTRUE:is_catholicTRUE"], 4), "\n")

# Exclude municipalities with >10,000 eligible voters
r5_rural <- feols(
  yes_share ~ is_french * is_catholic | vote_date,
  data = gender_panel %>% filter(eligible < 10000),
  cluster = ~mun_id
)

cat("  Rural only (<10K eligible) - interaction:",
    round(coef(r5_rural)["is_frenchTRUE:is_catholicTRUE"], 4), "\n")

# ============================================================================
# 5B. ROBUSTNESS: VOTER-WEIGHTED REGRESSION
# ============================================================================
cat("\n=== Robustness 5B: Voter-weighted ===\n")

# Weight by eligible voters to estimate average voter effect (not average municipality)
r5b_weighted <- feols(
  yes_share ~ is_french * is_catholic | vote_date,
  data = gender_panel,
  weights = ~eligible,
  cluster = ~mun_id
)

voter_weighted_coefs <- list(
  french = coef(r5b_weighted)["is_frenchTRUE"],
  catholic = coef(r5b_weighted)["is_catholicTRUE"],
  interaction = coef(r5b_weighted)["is_frenchTRUE:is_catholicTRUE"],
  french_se = se(r5b_weighted)["is_frenchTRUE"],
  catholic_se = se(r5b_weighted)["is_catholicTRUE"],
  interaction_se = se(r5b_weighted)["is_frenchTRUE:is_catholicTRUE"]
)
cat("  Voter-weighted French:", round(voter_weighted_coefs$french, 4),
    "(SE:", round(voter_weighted_coefs$french_se, 4), ")\n")
cat("  Voter-weighted Catholic:", round(voter_weighted_coefs$catholic, 4),
    "(SE:", round(voter_weighted_coefs$catholic_se, 4), ")\n")
cat("  Voter-weighted interaction:", round(voter_weighted_coefs$interaction, 4),
    "(SE:", round(voter_weighted_coefs$interaction_se, 4), ")\n")

# ============================================================================
# 6. FALSIFICATION: NON-GENDER REFERENDUM CATEGORIES
# ============================================================================
cat("\n=== Robustness 6: Extended falsification ===\n")

# Sample non-gender referenda (random selection for broad falsification)
# Take 6 random non-gender referenda from each decade
set.seed(44)
non_gender_dates <- full_panel %>%
  filter(ref_type == "other") %>%
  distinct(vote_date, year) %>%
  mutate(decade = floor(year / 10) * 10) %>%
  group_by(decade) %>%
  slice_sample(prop = 1) %>%     # shuffle within decade
  slice_head(n = 6) %>%          # take up to 6 per decade
  ungroup() %>%
  pull(vote_date)

falsi_extended <- full_panel %>%
  filter(vote_date %in% non_gender_dates) %>%
  mutate(
    culture_4 = case_when(
      !is_french & !is_catholic ~ "German-Protestant",
      !is_french & is_catholic ~ "German-Catholic",
      is_french & !is_catholic ~ "French-Protestant",
      is_french & is_catholic ~ "French-Catholic"
    )
  ) %>%
  filter(!is.na(culture_4))

r6_falsi_ext <- feols(yes_share ~ is_french * is_catholic | vote_date,
                      data = falsi_extended, cluster = ~mun_id)

cat("Extended falsification (non-gender referenda):\n")
cat("  French:", round(coef(r6_falsi_ext)["is_frenchTRUE"], 4), "\n")
cat("  Catholic:", round(coef(r6_falsi_ext)["is_catholicTRUE"], 4), "\n")
cat("  Interaction:", round(coef(r6_falsi_ext)["is_frenchTRUE:is_catholicTRUE"], 4), "\n")

# ============================================================================
# 7. ROBUSTNESS: INCLUSIVE SAMPLE (mixed cantons classified by majority)
# ============================================================================
cat("\n=== Robustness 7: Including mixed cantons ===\n")

# Load full votes data and reclassify mixed cantons by pre-1800 majority
votes_full <- readRDS(file.path(data_dir, "votes_clean.rds"))

# Reclassify mixed cantons
votes_inclusive <- votes_full %>%
  mutate(
    hist_religion_inclusive = case_when(
      hist_religion == "Mixed" & canton_abbr == "SG" ~ "Catholic",
      hist_religion == "Mixed" & canton_abbr %in% c("AG", "GR", "SO", "TG") ~ "Protestant",
      TRUE ~ hist_religion
    ),
    is_catholic_incl = hist_religion_inclusive == "Catholic"
  )

inclusive_panel <- votes_inclusive %>%
  filter(is_gender) %>%
  filter(mun_language %in% c("French", "German"),
         hist_religion_inclusive %in% c("Protestant", "Catholic"))

r7_inclusive <- feols(yes_share ~ is_french * is_catholic_incl | vote_date,
                      data = inclusive_panel, cluster = ~mun_id)

cat("  Inclusive sample N:", nrow(inclusive_panel), "\n")
cat("  Inclusive municipalities:", n_distinct(inclusive_panel$mun_id), "\n")
cat("  French:", round(coef(r7_inclusive)["is_frenchTRUE"], 4), "\n")
cat("  Catholic:", round(coef(r7_inclusive)["is_catholic_inclTRUE"], 4), "\n")
cat("  Interaction:", round(coef(r7_inclusive)["is_frenchTRUE:is_catholic_inclTRUE"], 4), "\n")

# ============================================================================
# 8. CANTON-LEVEL PERMUTATION INFERENCE
# ============================================================================
cat("\n=== Robustness 8: Canton-level permutation inference ===\n")

# GPT reviewer flagged that i.i.d. municipality-level permutation doesn't respect
# the canton-level assignment mechanism for religion. Here we permute confessional
# status at the CANTON level (relabel cantons, not municipalities), keeping
# language labels fixed (they're municipality-level).

# Get canton-level religion mapping
canton_data <- gender_panel %>%
  distinct(canton_id, is_catholic)

set.seed(45)
n_perm_canton <- 500
perm_canton_coefs <- numeric(n_perm_canton)

for (i in seq_len(n_perm_canton)) {
  if (i %% 100 == 0) cat("  Canton permutation", i, "/", n_perm_canton, "\n")

  # Permute religion labels at the canton level
  shuffled_canton <- canton_data %>%
    mutate(is_catholic_perm = sample(is_catholic))

  # Merge permuted canton-level religion back to municipality panel
  perm_panel_canton <- gender_panel %>%
    select(-is_catholic) %>%
    left_join(shuffled_canton %>% select(canton_id, is_catholic_perm),
              by = "canton_id") %>%
    rename(is_catholic = is_catholic_perm)

  fit_perm_canton <- tryCatch({
    feols(yes_share ~ is_french * is_catholic | vote_date,
          data = perm_panel_canton, cluster = ~mun_id)
  }, error = function(e) NULL)

  if (!is.null(fit_perm_canton)) {
    perm_canton_coefs[i] <- coef(fit_perm_canton)["is_frenchTRUE:is_catholicTRUE"]
  } else {
    perm_canton_coefs[i] <- NA
  }
}

perm_canton_valid <- perm_canton_coefs[!is.na(perm_canton_coefs)]
n_exceed_canton <- sum(abs(perm_canton_valid) >= abs(obs_interaction))
perm_p_canton <- n_exceed_canton / length(perm_canton_valid)
cat("  Canton-level permutation p-value:", round(perm_p_canton, 4), "\n")
cat("  N valid canton permutations:", length(perm_canton_valid), "\n")

# ============================================================================
# 9. FRACTIONAL LOGIT ROBUSTNESS
# ============================================================================
cat("\n=== Robustness 9: Fractional logit ===\n")

# Dependent variable is a share in [0,1]. GLM with quasibinomial addresses
# functional form concern (GPT reviewer).
r9_flogit <- glm(yes_share ~ is_french * is_catholic + factor(vote_date),
                 data = gender_panel,
                 family = quasibinomial(link = "logit"))

# Extract marginal effects at the mean for comparison
flogit_coefs <- summary(r9_flogit)$coefficients
cat("  Fractional logit coefficients (log-odds):\n")
cat("    French:", round(flogit_coefs["is_frenchTRUE", "Estimate"], 4),
    "(SE:", round(flogit_coefs["is_frenchTRUE", "Std. Error"], 4), ")\n")
cat("    Catholic:", round(flogit_coefs["is_catholicTRUE", "Estimate"], 4),
    "(SE:", round(flogit_coefs["is_catholicTRUE", "Std. Error"], 4), ")\n")
cat("    Interaction:", round(flogit_coefs["is_frenchTRUE:is_catholicTRUE", "Estimate"], 4),
    "(SE:", round(flogit_coefs["is_frenchTRUE:is_catholicTRUE", "Std. Error"], 4), ")\n")

# Compute average marginal effects for interpretability
# Use numerical differentiation at each observation
pred_base <- predict(r9_flogit, type = "response")
eps <- 1e-6

# AME for French
newdata_french <- gender_panel
newdata_french$is_french <- TRUE
pred_french1 <- predict(r9_flogit, newdata = newdata_french, type = "response")
newdata_french$is_french <- FALSE
pred_french0 <- predict(r9_flogit, newdata = newdata_french, type = "response")
ame_french <- mean(pred_french1 - pred_french0)

# AME for interaction: marginal effect of French in Catholic vs Protestant areas
newdata_fc <- gender_panel
newdata_fc$is_french <- TRUE; newdata_fc$is_catholic <- TRUE
pred_fc <- predict(r9_flogit, newdata = newdata_fc, type = "response")
newdata_fp <- gender_panel
newdata_fp$is_french <- TRUE; newdata_fp$is_catholic <- FALSE
pred_fp <- predict(r9_flogit, newdata = newdata_fp, type = "response")
newdata_gc <- gender_panel
newdata_gc$is_french <- FALSE; newdata_gc$is_catholic <- TRUE
pred_gc <- predict(r9_flogit, newdata = newdata_gc, type = "response")
newdata_gp <- gender_panel
newdata_gp$is_french <- FALSE; newdata_gp$is_catholic <- FALSE
pred_gp <- predict(r9_flogit, newdata = newdata_gp, type = "response")
ame_interaction <- mean((pred_fc - pred_gc) - (pred_fp - pred_gp))

cat("  Average marginal effects (pp):\n")
cat("    French AME:", round(ame_french * 100, 2), "pp\n")
cat("    Interaction AME:", round(ame_interaction * 100, 2), "pp\n")

# ============================================================================
# 10. BENJAMINI-HOCHBERG ADJUSTMENT FOR REFERENDUM-SPECIFIC INTERACTIONS
# ============================================================================
cat("\n=== Robustness 10: BH-adjusted q-values for referendum interactions ===\n")

# Compute p-values for each referendum's interaction
ref_pvals <- ref_results %>%
  filter(!is.na(interaction), !is.na(interaction_se)) %>%
  mutate(
    interaction_p = 2 * pnorm(-abs(interaction / interaction_se)),
    bh_qval = p.adjust(interaction_p, method = "BH")
  )

cat("Referendum interaction p-values and BH q-values:\n")
print(ref_pvals %>% select(vote_date, year, interaction, interaction_se, interaction_p, bh_qval))

# ============================================================================
# 11. SAVE ROBUSTNESS RESULTS
# ============================================================================

robustness <- list(
  alt_clustering = list(r1_mun = r1_mun, r1_canton = r1_canton, r1_twoway = r1_twoway),
  within_canton = list(r2_canton_fe = r2_canton_fe),
  permutation = list(
    obs_interaction = obs_interaction,
    perm_coefs = perm_coefs_valid,
    perm_p_interaction = perm_p,
    n_exceed_interaction = n_exceed_interaction,
    obs_lang = obs_lang,
    perm_lang_coefs = perm_lang_valid,
    perm_p_lang = perm_p_lang,
    n_exceed_lang = n_exceed_lang
  ),
  canton_permutation = list(
    perm_canton_coefs = perm_canton_valid,
    perm_p_canton = perm_p_canton,
    n_exceed_canton = n_exceed_canton
  ),
  individual_ref = ref_results,
  ref_bh_adjusted = ref_pvals,
  no_cities = r5_no_cities,
  rural_only = r5_rural,
  voter_weighted = r5b_weighted,
  voter_weighted_coefs = voter_weighted_coefs,
  falsi_extended = r6_falsi_ext,
  inclusive = r7_inclusive,
  fractional_logit = list(
    model = r9_flogit,
    ame_french = ame_french,
    ame_interaction = ame_interaction,
    coefs = flogit_coefs
  )
)

saveRDS(robustness, file.path(data_dir, "robustness_results.rds"))

cat("\n=== ROBUSTNESS ANALYSIS COMPLETE ===\n")
