# Initial Research Plan: apep_0486

## Research Question

Do progressive district attorneys reduce incarceration, and if so, at what cost to public safety? We examine (1) whether progressive DA elections reduce county jail populations, (2) how the reduction decomposes into pretrial vs. sentenced and Black vs. White components, and (3) whether the resulting decarceration affects homicide mortality.

## Identification Strategy

**Design:** Staggered Difference-in-Differences (Callaway & Sant'Anna 2021)

**Treatment:** Election of a progressive district attorney, defined following Petersen, Mitchell & Yan (2024) as a DA endorsing 6+ of 29 reform policy sub-items. Treatment timing is the year the progressive DA takes office (typically January following election).

**Treated units:** ~30 US counties where progressive DAs were elected between 2014 and 2022 (see treatment coding below).

**Control units:** All other US counties (never-treated) with non-missing Vera jail data.

**Primary extension: DDD (Race × DA × Time)**
The racial decomposition uses the Black vs. White jail population rates and homicide mortality rates as a triple-difference. The third dimension (race) absorbs county-level time-varying confounds and tests whether progressive DAs specifically reduced racial disparities.

## Expected Effects and Mechanisms

**First stage (jail population):**
- Expected: Progressive DA → 10–25% reduction in county jail population
- Mechanism 1 (bail): Pretrial jail population falls as DAs reduce cash bail requests
- Mechanism 2 (charging): Sentenced jail population falls as DAs decline charges for low-level offenses
- Mechanism 3 (equity): Black jail population rate falls more than White, narrowing the racial gap

**Public safety (homicide):**
- Ambiguous sign: Decarceration may increase crime (reduced deterrence/incapacitation) or decrease it (reduced criminogenic effects of incarceration). We report honestly whatever we find.
- Expected to be small or null based on existing literature (Agan et al. 2025, Petersen et al. 2024)

## Treatment Coding

Progressive DA counties with election/inauguration years:

| County | State | DA | Year |
|--------|-------|-----|------|
| Baltimore City | MD | Marilyn Mosby | 2015 |
| Cook County | IL | Kim Foxx | 2016 |
| Orange/Osceola | FL | Aramis Ayala | 2016 |
| Harris County | TX | Kim Ogg | 2016 |
| St. Louis City | MO | Kimberly Gardner | 2017 |
| Hillsborough | FL | Andrew Warren | 2017 |
| Philadelphia | PA | Larry Krasner | 2018 |
| Wyandotte | KS | Mark Dupree | 2017 |
| Kings County | NY | Eric Gonzalez | 2018 |
| St. Louis County | MO | Wesley Bell | 2019 |
| Suffolk County | MA | Rachael Rollins | 2019 |
| Contra Costa | CA | Diana Becton | 2019 |
| Durham County | NC | Satana Deberry | 2019 |
| Arlington | VA | Parisa Dehghani-Tafti | 2020 |
| Fairfax | VA | Steve Descano | 2020 |
| Loudoun | VA | Buta Biberaj | 2020 |
| Dallas County | TX | John Creuzot | 2019 |
| San Francisco | CA | Chesa Boudin | 2020 |
| Los Angeles | CA | George Gascon | 2021 |
| Travis County | TX | Jose Garza | 2021 |
| Orange/Osceola | FL | Monique Worrell | 2021 |
| Oakland County | MI | Karen McDonald | 2021 |
| Multnomah | OR | Mike Schmidt | 2021 |
| Washtenaw | MI | Eli Savit | 2021 |
| New York County | NY | Alvin Bragg | 2022 |
| Alameda County | CA | Pamela Price | 2023 |

## Primary Specification

**Equation (DiD first stage):**

y_{ct} = α_c + α_t + Σ_g δ_g · 1[G_c = g] · 1[t ≥ g] + X'_{ct}β + ε_{ct}

where y is jail population rate (per 100K), c is county, t is year, g is treatment cohort, G_c is county c's treatment year, X contains time-varying controls, and α_c, α_t are county and year FE.

**Estimator:** Callaway & Sant'Anna (2021) group-time ATT with doubly robust estimation (outcome regression + inverse probability weighting). Aggregated via simple and dynamic (event-study) weights.

**Clustering:** At the state level. With ~15 states containing treated counties, use wild cluster bootstrap for inference (Roodman et al. 2019).

**DDD specification (racial decomposition):**

y_{rct} = α_rc + α_rt + α_ct + δ · Black_r × Treated_{ct} + X'_{ct}β + ε_{rct}

where r ∈ {Black, White}, and α_rc, α_rt, α_ct are race×county, race×year, and county×year FE respectively. δ captures the differential effect on Black vs. White outcomes.

## Data Sources

| Source | Variable | Geographic Level | Time Period | Access |
|--------|----------|-----------------|-------------|--------|
| Vera Institute (GitHub) | Jail population, pretrial, sentenced, by race | County (FIPS) | 1970–2024 | Direct CSV download |
| County Health Rankings (URL) | Homicide mortality rate, by race | County (FIPS) | 2010–2024 | Direct CSV download |
| Census ACS (API) | Population, demographics, poverty, income | County (FIPS) | 2009–2023 | API with key |
| FRED (API) | State unemployment rate | State | 2000–2024 | API with key |

## Planned Robustness Checks

1. **Pre-COVID subsample:** Restrict to 2010–2019 (excludes COVID-era confounding)
2. **Pre-COVID cohorts only:** Keep only DAs elected before 2020
3. **Leave-one-out influence:** Drop each of the 5 largest treated counties individually
4. **Statewide reform controls:** State × year FE to absorb bail/sentencing reforms
5. **HonestDiD sensitivity:** Rambachan-Roth bounds on pre-trend violations
6. **Wild cluster bootstrap:** Correct inference for small number of state clusters
7. **Race placebo:** AAPI jail/homicide effects (should be null)
8. **Alternative aggregation:** Sun & Abraham (2021) interaction-weighted estimator

## Exposure Alignment (DiD)

- **Who is actually treated?** Residents of counties where a progressive DA takes office
- **Primary estimand population:** All county residents (for homicide); jail population (for incarceration)
- **Placebo/control population:** (a) Counties that never elected a progressive DA; (b) Within DDD: White population vs. Black population
- **Design:** DiD (primary), DDD with race (secondary)

## Power Assessment

- **Pre-treatment periods:** 8–14 years (2005–2014 for earliest cohort)
- **Treated clusters:** ~27 counties across ~15 states
- **Post-treatment periods:** 1–9 years depending on cohort
- **MDE assessment:** With ~3,000 counties in panel and 27 treated, and annual jail population rate variation of ~200 per 100K, the MDE for a 10% effect (20 per 100K) should be detectable with standard power. Will verify with actual data.
