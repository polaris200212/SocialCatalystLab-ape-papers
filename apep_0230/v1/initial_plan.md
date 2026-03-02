# Initial Research Plan: Neighbourhood Planning and House Prices

## Research Question

Does the adoption of Neighbourhood Development Plans under England's Localism Act 2011 affect local house prices? Do communities that gain formal control over local land use see property values rise, fall, or remain unchanged?

## Identification Strategy

**Design:** Staggered difference-in-differences (Callaway & Sant'Anna 2021)

**Treatment:** A local authority is "treated" when its first neighbourhood plan is formally adopted ("made") following a successful referendum. Treatment intensity is measured as the cumulative number of made neighbourhood plans within the LA.

**Treatment variation:** 1,197 neighbourhood plans were made across 177 local authorities between 2013 and 2024, with peak adoption during 2016-2019 (~200 plans/year). Treatment is heavily staggered — ideal for modern heterogeneity-robust DiD estimators.

**Control group:** Not-yet-treated local authorities (LAs that eventually adopt NPs but haven't yet) and never-treated LAs (LAs with no made NPs by 2024). Both serve as valid counterfactuals under parallel trends.

**Outcome data:** Median house prices by local authority from HM Land Registry Price Paid Data, aggregated to LA × year panels from 2008 to 2023.

**Key assumption:** Parallel trends — the timing of when an LA's first NP is adopted is uncorrelated with differential trends in house prices, conditional on LA and year fixed effects. Validated through event study pre-trends tests.

## Expected Effects and Mechanisms

**Mechanism 1 — Supply restriction:** NPs may constrain housing supply by limiting where and how much development occurs, reducing planning permission rates. This would RAISE house prices.

**Mechanism 2 — Amenity preservation:** NPs can protect green spaces, historic character, and local amenities. This preservation effect would RAISE prices for existing properties.

**Mechanism 3 — Development certainty:** NPs provide clear guidance for developers, potentially ENCOURAGING appropriate development. This could LOWER or stabilize prices.

**Mechanism 4 — Signalling:** NP adoption signals community engagement and desirability, possibly RAISING prices through a sorting/selection channel.

**Net prediction:** Ambiguous. The supply restriction and amenity channels predict price increases. The development certainty channel predicts decreases or null effects. This ambiguity makes the paper valuable regardless of the sign.

## Primary Specification

**Estimator:** Callaway & Sant'Anna (2021) group-time ATT with not-yet-treated as control

**Unit:** Local authority (district/unitary) × year

**Outcome:** Log median house price (from Land Registry aggregation)

**Treatment timing:** Year in which LA's first NP passes referendum

**Fixed effects:** LA and year (absorbed by the estimator)

**Standard errors:** Clustered at the local authority level

## Planned Robustness Checks

1. **Alternative treatment definitions:**
   - Binary (first NP made) vs continuous (cumulative NP count / total parishes)
   - Using referendum date vs formal "made" date
   - Using NP designation date as a placebo (designation is years before "made")

2. **Alternative estimators:**
   - Sun & Abraham (2021) interaction-weighted estimator
   - de Chaisemartin & D'Haultfœuille (2020)
   - Standard TWFE (to show bias)

3. **Sensitivity analysis:**
   - HonestDiD (Rambachan & Roth 2023) — sensitivity to parallel trends violations
   - Randomization inference — permutation of treatment dates across LAs

4. **Heterogeneity:**
   - By urban/rural classification
   - By region (London/South East vs rest)
   - By housing market conditions (high vs low demand areas)

5. **Mechanism tests:**
   - Effect on planning permission approval rates (MHCLG planning statistics)
   - Effect on housing completions (MHCLG live tables)
   - Effect on number of transactions (extensive margin)

6. **Event study:**
   - Dynamic treatment effects from t-8 to t+6 (or available window)
   - Flat pre-trends required for identification credibility

## Power Assessment

- **Treated clusters:** 177 local authorities with at least one NP
- **Total LAs in England:** ~312 districts/unitaries
- **Pre-treatment periods:** 5+ years (2008-2012 before first NP in 2013)
- **Post-treatment periods:** Varies by cohort (up to 11 years for early adopters)
- **Expected effect size:** Moderate — Hilber & Vermeulen (2016) found planning constraints doubled house price growth in England. NPs are one specific channel. We expect a smaller effect (2-5% price increase).
- **MDE given sample size:** With 312 LAs × 16 years = ~5,000 LA-year observations, and 177 treated LAs, we should detect effects of ~2-3% in house prices with 80% power.

## Data Sources

| Source | Geography | Frequency | Access |
|--------|-----------|-----------|--------|
| MHCLG/Locality NP Excel | Parish/LA | Snapshot (Mar 2024) | Free download (CONFIRMED) |
| Land Registry Price Paid | Transaction | Continuous | Free S3 download (CONFIRMED) |
| ONS Nomis | LA | Monthly/Quarterly | Free API (CONFIRMED) |
| MHCLG Planning Statistics | LA | Quarterly | Free download |
