# Updated Research Plan: Does Piped Water Build Human Capital?

## Research Question

Does India's Jal Jeevan Mission (JJM) — the world's largest piped water infrastructure program — improve human capital accumulation in rural districts? Specifically, does district-level expansion of household tap connections increase female school enrollment and women's education?

## Identification Strategy (Adapted)

**Design:** Cross-district Bartik exposure design using NFHS-4 vs NFHS-5

**Treatment:** Baseline water infrastructure deficit = 100 - NFHS-4 improved drinking water (%). Districts with larger deficits had more "room" for JJM improvement → higher treatment exposure.

**Unit of analysis:** District (629 matched districts using 2011 Census boundaries)

**Time period:** NFHS-4 (2015-16, pre-JJM) vs NFHS-5 (2019-21, during JJM early implementation)

**Estimator:** OLS reduced form + 2SLS IV (instrument actual water improvement with baseline deficit)

**Clustering:** State level (35 clusters)

**Adaptation rationale:** UDISE+ and JJM dashboard data are not available in bulk downloadable format. The NFHS provides district-level water access AND education indicators for both pre-JJM and during-JJM periods, enabling a clean before/after Bartik design with 629 districts.

## Mechanism

JJM piped water → reduced time burden of water fetching (primarily on girls/women) → increased school attendance → higher enrollment/retention, especially for girls in secondary school.

Secondary channel: Piped water → reduced waterborne disease (diarrhea) → fewer school absences → better learning outcomes.

## Expected Effects

- **Primary:** Positive effect on female secondary enrollment (ages 14-17), where opportunity cost of water-fetching is highest
- **Secondary:** Reduction in female dropout rates
- **Heterogeneity:** Larger effects in districts with (a) higher baseline water-fetching time, (b) lower baseline tap water coverage, (c) higher female population share in rural areas
- **Null possibility:** Effects may be small or zero if (a) water-fetching was not a binding constraint on schooling, (b) JJM infrastructure is not functional, (c) other barriers dominate

## Primary Specification

$$Y_{dt} = \alpha_d + \gamma_t + \beta \cdot \text{JJM\_Coverage}_{d,t-1} + X_{d} \cdot \delta_t + \varepsilon_{dt}$$

Where:
- $Y_{dt}$ = female enrollment rate (or dropout rate) in district $d$, academic year $t$
- $\alpha_d$ = district fixed effects
- $\gamma_t$ = year fixed effects
- $\text{JJM\_Coverage}_{d,t-1}$ = lagged share of HH with tap connections
- $X_d$ = baseline district characteristics (Census 2011) interacted with year trends

## COVID Strategy

**Primary:** Drop academic years 2020-21 and 2021-22 from estimation sample
**Robustness 1:** Include COVID years with state × year FEs
**Robustness 2:** Include COVID years with school closure duration controls

## Planned Robustness Checks

1. **Parallel pre-trends:** Event study with 5 pre-treatment years (2015-2019)
2. **Placebo outcome:** Male enrollment (should be unaffected if mechanism is water-fetching burden)
3. **Alternative treatment:** NFHS-5 piped water indicator as cross-validation
4. **Urban placebo:** Urban school enrollment (JJM targets rural areas)
5. **Nightlights:** VIIRS district nightlights as economic activity outcome
6. **Bandwidth:** Vary treatment threshold (10%, 20%, 30% coverage onset)
7. **Bacon decomposition:** Check for negative-weight concerns in TWFE
8. **Permutation inference:** Randomization inference for p-values given clustered structure

## Data Sources

| Data | Source | Granularity | Coverage |
|------|--------|-------------|----------|
| JJM tap connections | ejalshakti.gov.in | District × year | 2019-2025 |
| UDISE+ enrollment | udiseplus.gov.in | District × year | 2015-2025 |
| VIIRS nightlights | SHRUG v2.1 | District × year | 2012-2021 |
| Census 2011 controls | SHRUG PCA11 | District | 2011 |
| Village Directory 2011 | SHRUG VD11 | District | 2011 (water infrastructure baseline) |
| NFHS-4/5 factsheets | data.gov.in / GitHub | District × wave | 2015-16, 2019-21 |

## Exposure Alignment

- **Who is treated:** Rural households in districts receiving JJM tap connections
- **Primary estimand:** Female students in rural schools within treated districts
- **Placebo population:** Male students (should not benefit from reduced water-fetching)
- **Control population:** Districts with low/no JJM coverage in a given academic year

## Power Assessment

- Pre-treatment periods: 5 (academic years 2015-16 through 2019-20)
- Treatment clusters: ~640 districts
- Post-treatment periods: 3 clean (2022-23 through 2024-25), or 5 including COVID years
- MDE: With 640 districts, 10 years, and clustering at state level, we should detect effects of ~0.5-1 percentage point on enrollment rates (given baseline ~70-80% enrollment in upper primary)
