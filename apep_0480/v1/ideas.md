# Research Ideas

## Idea 1: Maximum Stakes — The Local Effects of England's Fixed-Odds Betting Terminal Reform on Crime, Property Values, and Welfare

**Policy:** On April 1, 2019, the UK government reduced the maximum stake on Fixed-Odds Betting Terminals (FOBTs) from £100 to £2. This caused mass closures of betting shops — over 1,000 within six months — concentrated in England's most deprived local authorities. The policy is one of the largest regulatory shocks to the UK high street in recent years.

**Outcome:** Three outcome margins, all measured at the Local Authority level:
1. **Crime:** Police-recorded crime from data.police.uk (street-level, monthly, 2013–2024). Categories: antisocial behavior, violence and sexual offences, shoplifting, criminal damage, drugs, public order.
2. **Property values:** HM Land Registry Price Paid Data (postcode-level, 1995–2024). Aggregated to LA-quarter level.
3. **Welfare/employment:** NOMIS DWP claimant count and ASHE earnings data by LA, monthly/annual.

**Identification:** Doubly robust difference-in-differences (Sant'Anna and Zhao 2020). The national policy shock provides temporal variation (pre/post April 2019). Cross-sectional treatment intensity is measured by pre-policy betting shop density per capita (from Gambling Commission Licensing Authority Statistics, 2015–2018 average). The DR estimator conditions on rich LA-level covariates (deprivation indices, demographics, baseline crime rates, urbanity) to restore parallel trends that may not hold unconditionally given betting shops' concentration in deprived areas. The R `did` package implements this natively.

**Why it's novel:** No causal economics paper exists on the 2019 FOBT reform. The entire published literature consists of descriptive spatial analyses (Hall et al. 2021) and policy reports (Bristol PFRC 2021). The causal effects on local crime, property values, and employment have never been estimated.

**Mechanism story (belief-changing):** Conventional wisdom says betting shop closures improve neighborhoods. But the effects are theoretically ambiguous:
- Street crime may FALL (reduced footfall, fewer disorder incidents around shops)
- But domestic/online crime may RISE (gambling displaced to online channels, confined to homes)
- Vacant storefronts → broken windows → offsetting crime increase
- Job losses in deprived areas → economic decline → crime increase
Resolving this ambiguity is the scientific contribution.

**Built-in placebos:**
- Non-gambling retail closures in the same LAs (same economic conditions, no gambling mechanism)
- Crime categories unrelated to gambling/night-time economy (e.g., bike theft, vehicle crime)
- LAs with no pre-policy betting shops (zero-exposure control group)

**Feasibility check:** CONFIRMED
- Gambling Commission LA statistics: 329 LAs, 2015–2025, free Excel download
- Gambling Commission business register: establishment-level CSV with postcodes, free
- Police API: Monthly crime by LSOA/LA from December 2010, free
- Land Registry PPD: 24M+ transactions, free bulk CSV download
- NOMIS: DWP claimant count by LA, monthly, free API
- DiD feasibility: 329 LAs × continuous treatment; 4+ pre-periods (2015–2018) × 6 post-periods (2019–2024)

---

## Idea 2: Last Orders — Pub Closures and the Unraveling of Local Social Capital in England

**Policy:** England has lost over 7,000 pubs since 2010, with closures accelerating to ~1,000/year by 2024. Closures are driven by a combination of rising business rates, changing drinking habits, and property development pressures. There is no single policy shock — closures are staggered across local authorities over time.

**Outcome:** Crime (Police API), property values (Land Registry), and political behavior (constituency-level voting data for UKIP/Reform UK support as social cohesion proxy).

**Identification:** DR: Match LAs that experienced above-median pub closures to similar LAs with below-median closures, using AIPW estimator with rich controls from NOMIS (deprivation, demographics, employment). Alternatively, exploit business rates revaluation shocks (2017) that differentially affected marginal pubs as an instrument.

**Why it's novel:** Existing literature is correlational FE/OLS only. Bolet (2021, Comparative Political Studies) found pub closures predict UKIP support but used OLS with controls, not credible causal identification. No DR or DiD paper exists.

**Feasibility check:** CONFIRMED — NOMIS Business Counts (SIC 56302) by LA, 2010–present; Police API crime; Land Registry PPD. But identification is WEAKER than Idea 1 because there is no clean exogenous shock.

---

## Idea 3: The Border Effect — Scotland's Minimum Unit Pricing and Cross-Border Alcohol-Related Crime

**Policy:** On May 1, 2018, Scotland introduced a minimum unit price of 50p for alcohol. England did not. This created a sharp policy discontinuity at the Scotland-England border.

**Outcome:** Alcohol-related crime (Police API covers both nations), emergency admissions (NHS Scotland/England border health boards), and cross-border alcohol purchases (descriptive evidence from retailers).

**Identification:** Border DiD comparing crime in Scottish LAs near the border vs English LAs near the border, before and after May 2018. DR augments this with LA-level covariates to handle differential trends.

**Why it's novel:** Health effects have been studied (Public Health Scotland reports). Crime spillover effects have NOT been causally estimated. The cross-border design is clean.

**Feasibility check:** PARTIAL — Police API covers England, Wales, and Northern Ireland. Scottish crime data requires separate source (Scottish Government recorded crime statistics by LA). Border LAs may number <20 on each side, raising power concerns. The border region is sparsely populated.

---

## Idea 4: Flooding the Market — Extreme Weather Events and Small Business Survival in England

**Policy:** England experiences increasingly frequent and severe flooding. Flood events are plausibly exogenous (conditional on geography) and create sharp local economic shocks.

**Outcome:** Firm dissolution rates (Companies House, SIC-level), property prices (Land Registry), and insurance costs (if available).

**Identification:** DR event study. Match flood-affected LSOAs to similar non-flooded LSOAs using pre-event characteristics. AIPW for the ATT of experiencing a major flood event.

**Why it's novel:** Some hedonic literature on flood risk capitalization exists, but firm survival effects are understudied. Climate adaptation angle is timely.

**Feasibility check:** PARTIAL — EA Flood Monitoring API provides real-time and historical data, but identifying "major flood events" at the LSOA level requires careful construction. Companies House tracks firms by postcode. Main concern: enough LSOA-level flood events for inference?
