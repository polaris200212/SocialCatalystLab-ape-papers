# =============================================================================
# 02_clean_data.R — Construct derived variables for descriptive analysis
# =============================================================================

source("00_packages.R")

# Load fetched data
panel_summary <- readRDS(file.path(DATA_DIR, "panel_summary.rds"))
census_pop <- readRDS(file.path(DATA_DIR, "census_pop.rds"))
link_diag <- readRDS(file.path(DATA_DIR, "link_diagnostics.rds"))
panel_desc <- readRDS(file.path(DATA_DIR, "panel_desc.rds"))
occ_transitions <- readRDS(file.path(DATA_DIR, "occ_transitions.rds"))
migration <- readRDS(file.path(DATA_DIR, "migration_flows.rds"))
state_link_rates <- readRDS(file.path(DATA_DIR, "state_link_rates.rds"))
abe_comparison <- readRDS(file.path(DATA_DIR, "abe_comparison.rds"))
tri_desc <- readRDS(file.path(DATA_DIR, "tri_panel_desc.rds"))
var_avail <- readRDS(file.path(DATA_DIR, "var_availability.rds"))

# =============================================================================
# 1. Compute overall link rates per decade pair
# =============================================================================
overall_link_rates <- panel_summary %>%
  filter(pair != "1920-1930-1940") %>%
  mutate(
    census_pop_y1 = census_pop$n_total[match(y1, census_pop$year)],
    link_rate = n_rows / census_pop_y1,
    link_rate_pct = link_rate * 100,
    pair_label = sprintf("%d\u2192%d", y1, y2)
  )

# =============================================================================
# 2. Aggregate link diagnostics by key dimensions
# =============================================================================

# By race (White, Black)
link_by_race <- link_diag %>%
  filter(race_cat %in% c("White", "Black")) %>%
  group_by(pair, race_cat) %>%
  summarize(
    n_linked = sum(n_linked),
    n_total = sum(n_total),
    link_rate = n_linked / n_total,
    .groups = "drop"
  ) %>%
  mutate(race_label = race_cat)

# By sex
link_by_sex <- link_diag %>%
  group_by(pair, sex_cat) %>%
  summarize(
    n_linked = sum(n_linked),
    n_total = sum(n_total),
    link_rate = n_linked / n_total,
    .groups = "drop"
  ) %>%
  mutate(sex_label = sex_cat)

# By age group
link_by_age <- link_diag %>%
  group_by(pair, age_group) %>%
  summarize(
    n_linked = sum(n_linked),
    n_total = sum(n_total),
    link_rate = n_linked / n_total,
    .groups = "drop"
  )

# =============================================================================
# 3. Occupation transition matrices (as proportions)
# =============================================================================
occ_categories <- c("Professional", "Manager", "Clerical", "Sales",
                     "Craftsman", "Operative", "Service",
                     "Farmer", "Farm laborer", "Laborer")

occ_matrices <- occ_transitions %>%
  filter(occ_y1 %in% occ_categories & occ_y2 %in% occ_categories) %>%
  group_by(pair) %>%
  mutate(
    total_y1 = sum(n),
    pct = n / total_y1 * 100
  ) %>%
  ungroup()

# Switching rates by pair
occ_switching <- occ_transitions %>%
  filter(occ_y1 %in% occ_categories & occ_y2 %in% occ_categories) %>%
  group_by(pair) %>%
  summarize(
    total = sum(n),
    same = sum(n[occ_y1 == occ_y2]),
    switch_rate = 1 - same / total,
    .groups = "drop"
  )

# =============================================================================
# 4. STATEFIP to state name mapping
# =============================================================================
state_names <- tibble(
  statefip = c(1,2,4,5,6,8,9,10,11,12,13,15,16,17,18,19,20,21,22,23,24,25,
               26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,44,45,46,
               47,48,49,50,51,53,54,55,56),
  state_name = c("Alabama","Alaska","Arizona","Arkansas","California",
                 "Colorado","Connecticut","Delaware","D.C.","Florida",
                 "Georgia","Hawaii","Idaho","Illinois","Indiana",
                 "Iowa","Kansas","Kentucky","Louisiana","Maine",
                 "Maryland","Massachusetts","Michigan","Minnesota",
                 "Mississippi","Missouri","Montana","Nebraska",
                 "Nevada","New Hampshire","New Jersey","New Mexico",
                 "New York","North Carolina","North Dakota","Ohio",
                 "Oklahoma","Oregon","Pennsylvania","Rhode Island",
                 "South Carolina","South Dakota","Tennessee","Texas",
                 "Utah","Vermont","Virginia","Washington",
                 "West Virginia","Wisconsin","Wyoming"),
  state_abbr = c("AL","AK","AZ","AR","CA","CO","CT","DE","DC","FL",
                 "GA","HI","ID","IL","IN","IA","KS","KY","LA","ME",
                 "MD","MA","MI","MN","MS","MO","MT","NE","NV","NH",
                 "NJ","NM","NY","NC","ND","OH","OK","OR","PA","RI",
                 "SC","SD","TN","TX","UT","VT","VA","WA","WV","WI","WY")
)

# =============================================================================
# 5. State link rates with names
# =============================================================================
state_link_rates <- state_link_rates %>%
  left_join(state_names, by = "statefip") %>%
  # Filter to continental US (exclude territories, Alaska, Hawaii for 1900-1950)
  filter(statefip <= 56, !statefip %in% c(2, 15))

# =============================================================================
# 6. Migration: top origin-destination pairs with state names
# =============================================================================
migration_named <- migration %>%
  left_join(state_names %>% select(statefip, origin_name = state_name),
            by = c("origin" = "statefip")) %>%
  left_join(state_names %>% select(statefip, dest_name = state_name),
            by = c("dest" = "statefip"))

# Top migration corridors across all decades
top_corridors <- migration_named %>%
  group_by(origin_name, dest_name) %>%
  summarize(total_movers = sum(n), .groups = "drop") %>%
  arrange(desc(total_movers)) %>%
  head(20)

# =============================================================================
# 7. Demographic transition rates
# =============================================================================
demo_transitions <- panel_desc %>%
  select(pair, y1, y2, n, mover_rate, pct_farm_y1, pct_farm_y2,
         farm_exit_rate, pct_married_y1, pct_married_y2) %>%
  mutate(
    urbanization_rate = pct_farm_y1 - pct_farm_y2,  # net farm exit
    marriage_entry = pct_married_y2 - pct_married_y1
  )

# =============================================================================
# Save all cleaned data
# =============================================================================
saveRDS(overall_link_rates, file.path(DATA_DIR, "overall_link_rates.rds"))
saveRDS(link_by_race, file.path(DATA_DIR, "link_by_race.rds"))
saveRDS(link_by_sex, file.path(DATA_DIR, "link_by_sex.rds"))
saveRDS(link_by_age, file.path(DATA_DIR, "link_by_age.rds"))
saveRDS(occ_matrices, file.path(DATA_DIR, "occ_matrices.rds"))
saveRDS(occ_switching, file.path(DATA_DIR, "occ_switching.rds"))
saveRDS(state_link_rates, file.path(DATA_DIR, "state_link_rates_named.rds"))
saveRDS(migration_named, file.path(DATA_DIR, "migration_named.rds"))
saveRDS(top_corridors, file.path(DATA_DIR, "top_corridors.rds"))
saveRDS(demo_transitions, file.path(DATA_DIR, "demo_transitions.rds"))
saveRDS(state_names, file.path(DATA_DIR, "state_names.rds"))

cat("Data cleaning complete.\n")
