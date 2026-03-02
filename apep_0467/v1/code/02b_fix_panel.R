## Quick fix: forward-fill population for 2024 and recompute per-capita vars
source("00_packages.R")

panel <- readRDS(file.path(DATA, "panel_analysis.rds"))
pop_dt <- fread(file.path(DATA, "state_population.csv"))

# Forward-fill: use 2023 population for 2024
state_name_map <- data.table(
  name = c(state.name, "District of Columbia"),
  abbr = c(state.abb, "DC")
)
pop_dt2 <- merge(pop_dt, state_name_map, by.x = "state_name", by.y = "name", all.x = TRUE)
pop_dt2[, state := abbr]
pop_dt2 <- pop_dt2[!is.na(state), .(state, year, population)]

# Add 2024 using 2023 values
pop_2023 <- pop_dt2[year == 2023]
pop_2024 <- copy(pop_2023)
pop_2024[, year := 2024]
pop_all <- rbind(pop_dt2, pop_2024)

# Remove old population and re-merge
panel[, population := NULL]
panel[, c("covid_cases_pc", "covid_deaths_pc", "providers_pc", "beneficiaries_pc") := NULL]

panel <- merge(panel, pop_all, by = c("state", "year"), all.x = TRUE)

# Fill any remaining NAs with forward-fill by state
setorder(panel, state, month_date)
panel[, population := nafill(population, type = "locf"), by = state]

# Recompute per-capita measures
panel[population > 0, `:=`(
  covid_cases_pc = fifelse(is.na(new_cases), 0, new_cases) / population * 100000,
  covid_deaths_pc = fifelse(is.na(new_deaths), 0, new_deaths) / population * 100000,
  providers_pc = n_providers / population * 100000,
  beneficiaries_pc = total_beneficiaries / population * 100000
)]

# For pre-COVID months where COVID data doesn't exist, set cases to 0
panel[is.na(covid_cases_pc), covid_cases_pc := 0]
panel[is.na(covid_deaths_pc), covid_deaths_pc := 0]

cat(sprintf("Panel after fix: %d rows, %d complete cases for controlled spec\n",
            nrow(panel),
            sum(!is.na(panel$covid_cases_pc) & !is.na(panel$state_ur))))

# Check how many rows have state_ur
cat(sprintf("Rows with state_ur: %d\n", sum(!is.na(panel$state_ur))))
cat(sprintf("Rows without state_ur: %d\n", sum(is.na(panel$state_ur))))

saveRDS(panel, file.path(DATA, "panel_analysis.rds"))
cat("Saved fixed panel_analysis.rds\n")
