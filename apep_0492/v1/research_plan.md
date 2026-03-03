# Research Plan: The Price of Subsidy Limits

## Research Question

How do regionally differentiated housing subsidy price caps distort new-build housing markets? Specifically: (1) How much do developers and buyers manipulate prices to stay below subsidy caps? (2) Does the incidence of subsidy limits vary with cap generosity? (3) Do caps alter the composition of new housing supply?

## Policy Background

The UK's Help to Buy Equity Loan scheme (2013–2023) provided 20% equity loans (40% in London) for new-build properties below a price cap. From April 2013 to March 2021, a uniform £600,000 national cap applied. On April 1, 2021, the scheme was reformed: 9 region-specific caps were introduced (ranging from £186,100 in the North East to £600,000 in London), and eligibility was restricted to first-time buyers.

### Regional Price Caps (April 2021)

| Region | Cap | Change from £600K |
|--------|-----|-------------------|
| North East | £186,100 | -69% |
| North West | £224,400 | -63% |
| Yorkshire & Humber | £228,100 | -62% |
| East Midlands | £261,900 | -56% |
| West Midlands | £255,600 | -57% |
| South West | £349,000 | -42% |
| East of England | £407,400 | -32% |
| South East | £437,600 | -27% |
| London | £600,000 | 0% |

## Identification Strategy

### Design 1: Multi-Cutoff Bunching Analysis (Primary)

Following Kleven (2016) and Best & Kleven (2018), we estimate the behavioral response to each regional price cap using bunching estimation. For each region r:

1. Estimate the counterfactual price distribution (absent the cap) using a polynomial fit to bins excluding the bunching region
2. Calculate excess mass below the cap (b_r) and missing mass above
3. Compute the implied demand/supply elasticity from the bunching ratio

**Nine simultaneous cutoffs** provide internal replication. Cross-regional variation in cap generosity (North East cap = 1.33× median new-build price vs. London cap = 0.87× median) tests whether distortions vary with cap bite.

### Design 2: Temporal Difference-in-Bunching

Compare the price distribution for new builds in each region before April 2021 (uniform £600K cap) vs. after (regional caps). This removes time-invariant features of regional price distributions and isolates the effect of cap changes.

- **Treatment intensity:** Regions where the cap fell most (NE, NW, Y&H: 60%+ reduction) vs. regions where it fell less (SE, EoE: 27-32%) vs. London (unchanged = placebo)
- **Pre-period:** 2018–2021 (uniform cap era, excluding COVID lockdown months)
- **Post-period:** April 2021 – March 2023 (regional cap era)

### Design 3: Spatial RDD at Regional Borders

New-build properties near regional boundaries face different caps. For properties within bandwidth h of the border:
- Running variable: signed distance to border (positive = higher-cap side)
- Treatment: eligibility differential at the same price point

**Best borders** (largest cap gap):
- NE / Yorkshire: £186K vs £228K (£42K gap)
- NE / NW: £186K vs £224K (£38K gap)
- EoE / London: £407K vs £600K (£193K gap)
- SE / London: £438K vs £600K (£162K gap)

Properties priced in the gap between adjacent caps are eligible on one side but not the other.

## Expected Effects and Mechanisms

1. **Bunching below caps:** Excess mass of new-build transactions just below each regional cap, with a "hole" above. Stronger bunching in regions with tighter caps (North) because the cap binds more.
2. **Property type composition shift:** In regions where the cap dropped sharply (NE: £186K), developers should shift toward cheaper property types (terraced houses, flats) to fit under the cap. Detached house share should decline.
3. **Quantity effects:** Total new-build transactions in the price range between the new regional cap and the old £600K cap should fall — these properties are no longer subsidy-eligible.
4. **Spatial price discontinuity:** At regional borders, new-build prices should bunch below the lower cap on the low-cap side, while similar properties on the high-cap side show no bunching at that price point.

## Primary Specification

**Bunching estimation:**
- Bin width: £1,000 (sensitivity: £500, £2,000)
- Polynomial order for counterfactual: 7th degree (sensitivity: 5th, 9th)
- Bunching window: [cap - £30K, cap + £30K] (sensitivity: ±£15K, ±£50K)
- Inference: bootstrapped standard errors (1000 iterations)

**Spatial RDD:**
- Bandwidth: CCT optimal (Calonico, Cattaneo & Titiunik 2014)
- Kernel: triangular (sensitivity: uniform, Epanechnikov)
- Polynomial: local linear (sensitivity: quadratic)
- Clustering: postcode level

## Planned Robustness Checks

1. **Placebo: second-hand properties** — no bunching expected at HTB caps for resales
2. **Placebo: London** — cap unchanged at £600K; no change in bunching expected
3. **Placebo: pre-2021 at same regional caps** — no bunching expected at future cap values before they were announced
4. **Donut specifications** — exclude properties within £1K of cap
5. **Alternative bin widths and polynomial orders** for bunching
6. **Multiple bandwidths** for spatial RDD (5km, 10km, 20km, CCT optimal)
7. **McCrary density test** at regional borders (no sorting of properties)
8. **Covariate balance** at borders (property type, freehold/leasehold, month)
9. **Leave-one-region-out** sensitivity
10. **Monthly event study** around April 2021 reform date

## Data Sources

1. **HM Land Registry Price Paid Data (PPD):** Universe of residential transactions in England and Wales. Annual CSV files from `https://price-paid-data.publicdata.landregistry.gov.uk/pp-YYYY.csv`. Key variables: price, date, postcode, property type (D/S/T/F), old/new (Y/N), freehold/leasehold.
2. **ONS Postcode Directory (ONSPD):** Maps postcodes to regions, LSOAs, coordinates. Free download from ONS Open Geography Portal.
3. **postcodes.io API:** Backup for postcode-to-region assignment.

## Exposure Alignment (Bunching Design)

- **Who is treated?** Buyers and developers of new-build properties priced near the regional cap. The cap determines subsidy eligibility.
- **Primary estimand:** The distortion in the new-build price distribution at each regional cap — measured as excess mass below and missing mass above.
- **Placebo population:** Second-hand properties (not eligible for HTB, should show no bunching at caps).

## Power Assessment

- **New-build transactions per year:** ~132,000 (2022 data, confirmed)
- **Post-reform period:** April 2021 – March 2023 = ~264,000 new-build transactions
- **Bin size at £1,000:** Each £1,000 bin near a typical cap contains ~50-200 transactions (region-dependent)
- **Bunching detection:** With ≥50 transactions per bin, even modest bunching (10% excess mass) is detectable at conventional significance levels
- **Spatial RDD:** The key constraint is new builds near regional borders. For the EoE/London border (high density), expect thousands of new builds within 20km. For NE/Yorkshire (lower density), expect hundreds. This is sufficient for local linear RDD with CCT bandwidths.
