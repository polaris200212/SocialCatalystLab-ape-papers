# Initial Research Plan: Does Place-Based Climate Policy Work?
## A Regression Discontinuity Analysis of IRA Energy Community Bonus Credits

**Paper ID:** apep_0418
**Date:** 2026-02-19
**Method:** Sharp RDD

---

## Research Question

Does the Inflation Reduction Act's energy community bonus credit — a 10 percentage point increase in clean energy tax credits for areas with significant fossil fuel employment — successfully redirect clean energy investment to fossil fuel communities? Or do natural resource endowments (solar irradiance, wind speed) dominate location decisions regardless of the subsidy?

## Identification Strategy

**Design:** Sharp Regression Discontinuity at the 0.17% fossil fuel employment threshold.

The IRA (IRC §45(b)(11)(B)(ii)) designates MSAs and non-MSAs as "energy communities" (eligible for 10pp bonus ITC/PTC) if they meet two conditions:
1. Fossil fuel employment ≥ 0.17% of total employment (using County Business Patterns)
2. Local unemployment rate ≥ national average

**Key insight:** Among areas where unemployment exceeds the national average, the 0.17% fossil fuel employment threshold MECHANICALLY determines energy community status. This creates a sharp discontinuity.

**Running variable:** Fossil fuel employment share (% of total employment in fossil fuel NAICS codes: 211, 2121, 213111/2, 486, 4247), constructed from pre-IRA (2021) County Business Patterns data.

**Sample restriction:** MSAs/non-MSAs with unemployment ≥ national average AND not qualifying through brownfield or coal closure pathways (to isolate the fossil fuel employment margin).

## Expected Effects and Mechanisms

**Central hypothesis:** Energy community designation increases clean energy project siting in qualifying areas, but the magnitude depends on the relative importance of tax incentives vs. natural resource endowments.

**Expected effect:** Positive but potentially modest. The 10pp bonus increases the ITC from 30% to 40% (a 33% increase in the subsidy rate). This is economically significant but may not overcome the fundamental physics of renewable energy (solar panels need sun, wind turbines need wind).

**Mechanisms:**
1. **Direct investment channel:** The bonus makes marginal projects in qualifying areas profitable
2. **Spatial displacement:** Investment may shift FROM non-qualifying areas TO qualifying areas (zero-sum)
3. **Resource constraint channel:** If natural endowments dominate, the bonus may fail to redirect investment
4. **Political economy:** The "just transition" framing may attract investment beyond pure economics

## Primary Specification

```r
# Sharp RDD using rdrobust
rd_main <- rdrobust(
  y = clean_energy_capacity,        # MW of new clean energy capacity (post-IRA)
  x = ff_employment_share,          # Running variable: FF employment %
  c = 0.17,                         # Statutory threshold
  covs = cbind(solar_irradiance, wind_speed, population, median_income),
  cluster = state_fips,             # Cluster SEs by state
  all = TRUE                        # Report all estimates
)
```

## Planned Outcomes (Pipeline Cascade)

1. **Interconnection queue entries** (LBNL Queued Up) — Developer intent, earliest signal
2. **Proposed generators** (EIA 860M) — Mid-pipeline
3. **New operational capacity** (EIA 860) — Realized outcome, by technology (solar, wind, storage)
4. **Local employment** (QCEW) — Labor market effects
5. **Property values** (FHFA HPI) — Capitalization

## Planned Robustness Checks

1. **McCrary density test** (rddensity) — Test for manipulation at 0.17%
2. **Covariate balance** — Pre-determined characteristics smooth through cutoff
3. **Bandwidth sensitivity** — CCT optimal + 0.5×, 0.75×, 1.25×, 1.5×, 2× optimal
4. **Polynomial order** — Linear, quadratic (no higher per Gelman & Imbens 2019)
5. **Placebo cutoffs** — Test at 0.10%, 0.12%, 0.14%, 0.20%, 0.25%, 0.30%
6. **Donut RDD** — Exclude observations closest to cutoff
7. **Bivariate RDD** — Joint threshold on both FF employment and unemployment
8. **Alternative running variable** — Using 2020 vs 2021 CBP data
9. **Heterogeneity** — By solar irradiance (high vs low resource areas), by region

## Data Sources

| Data | Source | Variables | Unit |
|------|--------|-----------|------|
| Fossil fuel employment | Census CBP API | Employment by NAICS, total emp | County/MSA |
| Energy community lists | Treasury (home.treasury.gov) | Designation status, pathway | MSA/non-MSA |
| Generator data | EIA 860/860M | Capacity, technology, location, status | Generator/county |
| Interconnection queue | LBNL Queued Up | Queue date, capacity, technology | Project |
| Solar irradiance | NREL NSRDB | GHI, DNI | County |
| Wind speed | NREL Wind Toolkit | Hub-height wind speed | County |
| Employment | BLS QCEW | County employment/wages | County/quarter |
| Property values | FHFA HPI | House price index | MSA/quarter |
| Demographics | ACS 5-year | Population, income, education | MSA |

## Power Assessment

- ~974 MSAs/non-MSAs total
- Restricting to unemployment ≥ national average: ~400-500
- Observations within CCT optimal bandwidth of 0.17%: ~100-200 (estimate)
- Given the discrete nature of the running variable, local randomization methods (rdlocrand) may complement continuity-based inference

## Paper Structure

1. Introduction (hook: $369B IRA, will it reach coal country?)
2. Background (IRA energy communities, place-based policy literature)
3. Data and Institutional Setting
4. Identification Strategy (RDD design, validity tests)
5. Results (pipeline cascade: queue → proposed → operational)
6. Mechanisms (resource endowments, spatial displacement)
7. Welfare Implications
8. Conclusion
