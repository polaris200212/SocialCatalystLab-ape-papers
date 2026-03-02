# Initial Research Plan: Flood Re and the Capitalization of Climate Risk Insurance

## Research Question

Does subsidized flood insurance capitalize into property values, and does it create moral hazard by encouraging continued development in flood-risk areas? We exploit the UK's Flood Re reinsurance scheme — which caps flood insurance premiums for pre-2009 properties but explicitly excludes newer construction — to estimate a triple-difference effect on property values, transaction volumes, and new construction patterns.

## Identification Strategy

**Triple-Difference (DDD) Design:**

Y_{ipzt} = α + β₁(FloodZone_p × Post2016_t × Pre2009_i) + β₂(FloodZone_p × Post2016_t)
           + β₃(FloodZone_p × Pre2009_i) + β₄(Post2016_t × Pre2009_i)
           + γ_p + δ_t + ε_{ipzt}

Where:
- i indexes construction vintage (pre-2009 = eligible, post-2009 = ineligible)
- p indexes postcode-level flood risk classification
- z indexes Local Authority
- t indexes year-quarter

**Three dimensions of variation:**
1. **Flood zone exposure:** EA Risk of Flooding from Rivers and Sea (High/Medium vs. Low/Very Low)
2. **Policy timing:** Pre- vs. post-April 2016 (Flood Re launch)
3. **Eligibility:** Pre-2009 construction (Flood Re eligible) vs. post-2009 (ineligible)

The DDD coefficient β₁ identifies the effect of Flood Re eligibility on property prices within flood zones, netting out: (a) national property trends, (b) flood-zone-specific trends unrelated to insurance, (c) construction-vintage-specific trends.

## Exposure Alignment

- **Who is actually treated?** Owners/buyers of residential properties built before 1 January 2009 located in EA-classified flood risk areas. Flood Re caps their insurance premiums via Council Tax band.
- **Primary estimand population:** Pre-2009 residential properties in Medium/High flood risk postcodes, transacting after April 2016.
- **Placebo/control population:** Post-2009 residential properties in the SAME flood risk postcodes (identical flood exposure, no insurance subsidy).
- **Design:** DDD (three-way interaction)

## Expected Effects and Mechanisms

1. **Price capitalization (primary):** Flood Re reduces insurance costs for eligible properties → reduces the implicit "flood risk discount" → property prices rise. Garbarino et al. (2024) found a ~£4,000 average effect using DiD. Our DDD should isolate the insurance channel more cleanly.

2. **Transaction volume (liquidity):** Pre-Flood Re, flood-zone properties were often unmortgageable due to unavailable or prohibitively expensive insurance. Flood Re restored insurability → increased transaction volumes for eligible properties.

3. **Moral hazard (new construction):** Despite the post-2009 exclusion, developers may build in flood zones expecting the cutoff to be extended (or that buyers will accept the risk). Test: share of new-build transactions in flood zones before vs. after 2016.

4. **Distributional effects:** Flood Re premiums are capped by Council Tax band (Band A = £210, Band H = £1,260 as of 2023). Higher-value properties in higher bands receive larger absolute subsidies. Test: DDD heterogeneity by Council Tax band or property value quintile.

## Primary Specification

**Sample:** All residential transactions in England and Wales from Land Registry PPD, 2009–2025. Restrict to postcodes with flood risk classification from EA RoFRS.

**Dependent variable:** Log transaction price (main), transaction count per postcode-quarter (volume), new-build share (moral hazard).

**Treatment variables:**
- FloodZone_p: Binary indicator for Medium or High flood risk (from EA postcode-level data)
- Post2016_t: Binary indicator for transactions on or after 1 April 2016
- Pre2009_i: Binary indicator for established properties (New Build flag = N, or first sold before 2009)

**Fixed effects:** Postcode FE (absorbs time-invariant location characteristics), year-quarter FE (absorbs national trends). Alternative: LA × year-quarter FE (absorbs local trends).

**Clustering:** Two-way at postcode and year-quarter level. Robustness: LA-level clustering.

## Power Assessment

- **Pre-treatment periods:** 2009Q1–2016Q1 = 29 quarters (for the DDD with post-2009 properties)
- **Post-treatment periods:** 2016Q2–2025Q4 = 38 quarters
- **Treated clusters (flood-risk postcodes with both pre-2009 and post-2009 properties):** Estimated 20,000–50,000 postcodes (England has ~1.7M postcodes; ~10% have some flood risk; a subset will have both vintage types)
- **Total transactions:** ~24M in full PPD; estimated 2–3M in flood-risk postcodes
- **MDE:** With this sample size, we can detect effects well below 1% of property value. Garbarino et al. found ~1.5% — easily detectable.

## Planned Robustness Checks

1. **Event-study coefficients:** Annual DDD coefficients 2009–2025 relative to 2015
2. **Pre-trend F-test:** Joint insignificance of pre-2016 DDD coefficients
3. **HonestDiD / Rambachan-Roth sensitivity bounds**
4. **Placebo: Very Low flood risk areas** (Flood Re irrelevant — standard insurance affordable)
5. **Placebo: non-residential transactions** (Flood Re doesn't cover commercial property)
6. **Bandwidth variation for flood risk classification** (Medium+High vs. High only)
7. **Donut estimation:** Exclude properties transacting near the April 2016 cutoff
8. **EPC-based construction date:** Independent verification using EPC CONSTRUCTION_AGE_BAND
9. **Leave-one-out by region:** Ensure results not driven by London or any single region
10. **Repeat-sales subsample:** Within-property price changes for properties sold both before and after 2016

## Data Sources

| Source | Content | Format | Access |
|--------|---------|--------|--------|
| Land Registry PPD | 24M+ transactions, 1995–present | Bulk CSV | Free download, OGL v3.0 |
| EA Open Flood Risk by Postcode | Postcode-level flood risk (4 bands) | CSV | Free download, OGL v3.0 |
| ONS NSPL | Postcode → LSOA/LA lookup | Bulk CSV | Free download |
| EPC Register | Construction age band, floor area, energy rating | Bulk CSV by month | Free download |
| Flood Re Annual Reports | Aggregate premium data, ceded policies | PDF | Published annually |
