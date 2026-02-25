# Initial Research Plan — apep_0453

## Research Question

Did pre-existing banking infrastructure buffer the economic disruption of India's November 2016 demonetization, and did it shape differential long-run recovery patterns? More broadly: does financial infrastructure determine resilience to large monetary shocks?

## Policy Context

On November 8, 2016, India's Prime Minister Narendra Modi announced the immediate demonetization of all Rs 500 and Rs 1,000 banknotes — 86.9% of currency in circulation (Rs 15.44 trillion, ~12.5% of GDP). Citizens had 50 days to deposit or exchange the old notes at bank branches. This created an overnight liquidity crisis, particularly acute in areas with limited banking access.

The key geographic variation: districts with more bank branches per capita could process note exchanges faster, maintaining economic activity. Districts with fewer branches experienced longer queues, higher exchange costs, and greater economic disruption.

## Identification Strategy

**Design:** Continuous-treatment Difference-in-Differences (intensity design)

**Treatment:** Pre-existing banking infrastructure from Census 2011 Town Directory
- Primary measure: Total bank branches per 100,000 population (government + private commercial + cooperative)
- Alternative measures: Government bank branches only; private bank density; bank-to-population ratio

**Event:** November 8, 2016 (demonetization announcement)

**Outcome:** Log VIIRS annual nightlights sum at district level (proxy for economic activity, following Henderson, Storeygard & Weil 2012; Chodorow-Reich et al. 2020)

**Unit:** District (640 districts, ~28 states)

**Time:** 2012–2023 (12 years: 4 pre-demonetization, 1 event year, 7 post)

**Specification:**
```
log(NL_{d,t}) = α_d + γ_t + Σ_k β_k × Bank_{d,2011} × 1(Year = k) + X'_{d,2011} × γ_t + ε_{d,t}
```

Where:
- `NL_{d,t}` = VIIRS nightlight sum in district d, year t
- `α_d` = district fixed effects
- `γ_t` = year fixed effects
- `Bank_{d,2011}` = bank branches per 100K population (Census 2011, pre-determined)
- `1(Year = k)` = year indicators (event study, omitting 2015)
- `X'_{d,2011}` = baseline controls (population, urbanization, literacy, SC/ST share, worker composition) interacted with year

**Clustering:** State-level (28+ clusters)

## Expected Effects and Mechanisms

**Hypothesis 1 (Buffering):** Districts with higher banking density experienced smaller nightlight declines in 2016–2017. β_2017 < 0 for low-banking districts relative to high-banking districts.

**Hypothesis 2 (Recovery):** High-banking districts recovered faster. The negative effect dissipates by 2018–2019 for high-banking districts but persists longer in low-banking areas.

**Hypothesis 3 (Structural change):** Demonetization may have accelerated formalization in areas with banking access, as the cash economy was disrupted. This would show positive β coefficients in later years (2019–2023) for high-banking districts.

**Mechanisms:**
1. Transaction cost channel: Bank branches reduce the cost of exchanging old notes → faster remonetization
2. Credit channel: Banks in affected areas could extend credit during the cash crunch
3. Digital adoption channel: Banking presence facilitates shift to digital payments post-demonetization

## Exposure Alignment (DiD Requirements)

**Who is actually treated?** All economic agents (households, firms) in every district. The shock is universal.

**Primary estimand population:** Districts with varying levels of pre-existing banking infrastructure. Treatment intensity is continuous.

**Placebo/control population:** There is no untreated group — instead, we compare high-intensity (many banks) to low-intensity (few banks) districts. The identifying variation is cross-sectional intensity × time.

**Design:** Continuous DiD (not binary). Not a traditional staggered design.

## Power Assessment

- **Pre-treatment periods:** 4 (2012–2015)
- **Treated clusters:** 640 districts (all treated, continuous intensity)
- **Post-treatment periods:** 7 (2017–2023), with 2016 as partial
- **State clusters for SE:** 28+ states
- **Panel:** 640 × 12 = 7,680 district-year observations
- **Banking intensity variation:** Mean 4.9, SD 4.8 branches per 100K (strong cross-sectional variation)
- **Expected MDE:** Very well-powered given N=640 districts and 12 years. Chodorow-Reich et al. (2020) found ~2 pp effects at district level with similar sample.

## Primary Specification

1. **Event study:** Estimate year-by-year coefficients on Bank_{d,2011} × Year_k (omit 2015 as reference). Plot pre-trends and dynamic effects.

2. **Pooled DiD:**
```
log(NL_{d,t}) = α_d + γ_t + β × Bank_{d,2011} × Post_t + X'_{d,2011} × γ_t + ε_{d,t}
```
Where Post_t = 1 for t ≥ 2017 (or t ≥ 2016 in alternative specification)

3. **Short-run vs Long-run:**
- Short-run (2017–2018): Immediate buffering effect
- Medium-run (2019–2020): Recovery dynamics
- Long-run (2021–2023): Structural transformation

## Planned Robustness Checks

1. **Pre-trends test:** Event study coefficients for 2012–2015 should be indistinguishable from zero
2. **Alternative intensity measures:** Government banks only; private banks only; log bank branches; binary above/below median
3. **Placebo event dates:** Run the same specification with fake demonetization in 2014 (should find no effects)
4. **Dropping extreme districts:** Exclude top/bottom 5% by banking density
5. **Alternative outcomes:** DMSP nightlights (1994–2013) for extended pre-period; nightlights per capita
6. **Urbanization controls:** Interact banking with urban share to ensure not just proxying for urban/rural divide
7. **Spatial clustering:** Conley standard errors as alternative to state clustering
8. **COVID robustness:** Separate 2020–2023 effects from pre-COVID 2017–2019 effects
9. **Sub-district analysis:** ~5,900 sub-districts for greater power (if TD data matches)
10. **Comparison with Chodorow-Reich measure:** Use their currency replacement ratio approach at district level alongside our banking infrastructure measure

## Data Sources

| Data | Source | Level | Years |
|------|--------|-------|-------|
| VIIRS nightlights | SHRUG (local) | District, sub-district | 2012–2023 |
| DMSP nightlights | SHRUG (local) | District | 1994–2013 |
| Bank branches | Census 2011 TD (SHRUG, local) | District, sub-district | 2011 (cross-section) |
| Population, literacy, workers | Census 2011 PCA (SHRUG, local) | District | 2011 |
| Historical Census | Census 2001, 1991 PCA (SHRUG, local) | District | 2001, 1991 |
| Economic Census | SHRUG EC | District | 2005, 2013 |
| RBI credit data | RBI DBIE | State | 2012–2023 |
| FRED India GDP | FRED API | National | 2012–2023 |

## Heterogeneity Analysis

1. **By economic structure:** Agricultural vs non-agricultural districts (from Census worker classification)
2. **By urbanization:** Urban vs rural districts
3. **By pre-existing development:** Above/below median literacy, nightlights in 2015
4. **By SC/ST share:** Marginalized communities may have less banking access
5. **By state:** State-level variation in remonetization speed
