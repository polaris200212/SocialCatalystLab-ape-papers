# Research Ideas

## Idea 1: Does Place-Based Climate Policy Work? A Regression Discontinuity Analysis of IRA Energy Community Bonus Credits

**Policy:** The Inflation Reduction Act (2022) created "energy community" bonus tax credits — a 10 percentage point bonus on clean energy Investment Tax Credits (ITC) and Production Tax Credits (PTC) for projects sited in areas with significant fossil fuel employment. Qualification requires: (a) fossil fuel employment ≥ 0.17% of total employment in the MSA/non-MSA (statutory threshold), AND (b) local unemployment rate ≥ national average. The 0.17% fossil fuel employment threshold is set by statute (IRC §45(b)(11)(B)(ii)) and creates a sharp discontinuity in investment incentives.

**Outcome:** Clean energy project siting and capacity, measured from EIA Form 860/860M (universe of planned, under construction, and operational electricity generators with ≥1MW capacity, geocoded to county). Secondary outcomes: local employment (QCEW), property values (FHFA HPI), and business formation (Census Business Formation Statistics).

**Identification:** Sharp RDD at the 0.17% fossil fuel employment threshold. Running variable: fossil fuel employment share in the MSA/non-MSA, constructed from Census County Business Patterns (NAICS 211, 2121, 213111/2, 486, 4247) using pre-IRA (2021) data. Main specification conditions on MSAs/non-MSAs where unemployment ≥ national average (so the second criterion is satisfied), then estimates the discontinuity at 0.17%. Robustness: (1) bivariate RDD using both thresholds simultaneously, (2) RDD on unemployment margin among areas with FF employment ≥ 0.17%, (3) donut RDD excluding observations closest to cutoff, (4) bandwidth sensitivity (Calonico-Cattaneo-Titiunik optimal bandwidth with bias correction), (5) McCrary density test for manipulation (implausible since threshold set after data collected), (6) covariate balance tests at cutoff.

**Why it's novel:** No existing RDD paper on IRA energy communities. The few existing IRA papers (Bistline et al. 2023, NBER w31267; Holland et al. 2025, NBER w33092) are simulation/modeling studies, not causal identification. This would be the first paper to estimate the *actual* causal effect of energy community designation on clean energy investment using quasi-experimental methods.

**Why it matters for a JMP:** This paper sits at the intersection of three hot literatures — place-based policy (Kline & Moretti 2014; Busso, Gregory & Kline 2013), environmental economics (the "green transition"), and industrial policy (Juhász, Lane & Rodrik 2023). The IRA is the largest climate investment in US history ($369B). Whether its place-based component successfully redirects investment to fossil fuel communities — or whether solar/wind resources dominate location decisions — is a first-order policy question worth hundreds of billions of dollars.

**Feasibility check:** ✅ Treasury publishes energy community designation lists with underlying data (home.treasury.gov). ✅ CBP available via Census API for running variable construction. ✅ EIA 860/860M downloadable as Excel from eia.gov. ✅ ~384 MSAs + ~590 non-MSAs = ~974 observations for RDD. ✅ 3+ years of post-treatment data (IRA signed Aug 2022, energy community guidance April 2023). ✅ 8GB RAM sufficient for MSA-level analysis.

---

## Idea 2: Wildfire Smoke, Air Quality Thresholds, and Consumer Spending: Evidence from EPA AQI Discontinuities

**Policy:** EPA's Air Quality Index (AQI) uses sharp thresholds to classify air quality and trigger public health advisories. At AQI = 101, classification changes from "Moderate" (yellow) to "Unhealthy for Sensitive Groups" (orange), triggering school outdoor activity cancellations, health advisories, and behavioral changes. At AQI = 151, classification becomes "Unhealthy" (red), triggering more severe warnings.

**Outcome:** Consumer spending from Opportunity Insights Economic Tracker (daily spending by county), emergency department visits (CDC WONDER), and school attendance (where available). The spending outcome is novel — most AQI papers focus on health.

**Identification:** Sharp RDD at the AQI = 100/150 thresholds. Running variable: daily county-level AQI from EPA Air Quality System monitors. Treatment: days when AQI crosses the threshold trigger behavioral responses. Panel structure: county × day observations, exploiting within-county variation in AQI.

**Why it's novel:** Existing AQI papers focus almost exclusively on health outcomes (Deryugina et al. 2019; Schlenker & Walker 2016). The economic activity channel — how air quality warnings change consumer behavior and local commerce — is understudied. Wildfire smoke episodes have increased dramatically, making this increasingly policy-relevant.

**Feasibility check:** ✅ EPA AQS data downloadable (aqs.epa.gov). ✅ Opportunity Insights daily spending tracker is public. ⚠️ Need to verify sufficient county × day observations near thresholds. ⚠️ AQI is somewhat continuous — behavioral response may not be sharp at exact threshold.

---

## Idea 3: The $55,000 Cliff: IRA Clean Vehicle Credit Price Caps and Manufacturer Strategic Pricing

**Policy:** The IRA created a $7,500 consumer tax credit for clean vehicles with a sharp MSRP cap: $55,000 for sedans and $80,000 for SUVs/trucks. Vehicles priced above the cap receive zero credit. This creates a massive incentive for manufacturers to price vehicles just below the threshold.

**Outcome:** Vehicle pricing distribution (bunching analysis), sales volumes by model, and consumer welfare. Data from manufacturer price lists, EPA fuel economy data (with MSRP), and potentially state vehicle registration databases.

**Identification:** Bunching estimator (Kleven & Waseem 2013) at the $55,000/$80,000 MSRP thresholds. The excess mass of vehicles priced just below the cap reveals manufacturer strategic response. Consumer-side: RDD comparing buyer demographics and purchase patterns for vehicles priced just below vs above the cap using household survey data.

**Why it's novel:** The EV tax credit literature (Muehlegger & Rapson 2022; Xing, Leard & Li 2021) focuses on demand responses, not manufacturer strategic pricing. The IRA's hard MSRP caps are new and create textbook bunching opportunities.

**Feasibility check:** ✅ EPA fuel economy data with MSRP is public. ⚠️ Vehicle-level sales data may require proprietary sources. ⚠️ Bunching requires sufficient model-year observations. ⚠️ MSRP caps only apply to new EVs — limited model count.

---

## Idea 4: Does Federal Broadband Funding Close the Digital Divide? Evidence from FCC Speed Thresholds

**Policy:** The Infrastructure Investment and Jobs Act (IIJA, 2021) allocated $42.5B for the Broadband Equity, Access, and Deployment (BEAD) program. Locations with download speeds < 25 Mbps are classified as "unserved" and receive funding priority. Locations with 25-100 Mbps are "underserved." The 25 Mbps threshold creates a sharp discontinuity in federal funding eligibility.

**Outcome:** Internet adoption rates (ACS), remote work (CPS), housing values (Zillow/FHFA), and small business formation (Census BFS). The remote work channel is particularly timely post-COVID.

**Identification:** Sharp RDD at the 25 Mbps speed threshold, using FCC broadband map speed data as the running variable. Census blocks just below 25 Mbps (unserved, eligible for BEAD) vs just above (underserved, lower priority).

**Why it's novel:** The broadband RDD literature (Faber, Sanchis-Guarner & Weinhardt 2015; Hjort & Poulsen 2019) uses European data. The BEAD program is the largest US broadband investment ever and hasn't been studied.

**Feasibility check:** ⚠️ FCC broadband maps available but speed data is provider-reported (measurement error concern). ⚠️ BEAD grants only recently awarded (2024-2025) — outcomes may be too early to measure. ⚠️ Speed threshold may not be sharp in practice.

---

## Idea 5: Aging into Medicare at 65 and the Decision to Start a Business: Health Insurance Lock and Entrepreneurship

**Policy:** At age 65, Americans become eligible for Medicare, eliminating dependence on employer-sponsored health insurance. This creates a sharp age discontinuity in the implicit cost of self-employment (losing employer health insurance becomes costless at 65).

**Outcome:** Self-employment rates, business formation, and business survival from CPS monthly microdata (age × employment status) and Census Longitudinal Business Database.

**Identification:** Sharp RDD at age 65 using monthly CPS microdata. Running variable: age in months relative to 65th birthday. Compare self-employment rates just before vs just after Medicare eligibility.

**Why it's novel:** The "entrepreneurship lock" hypothesis (Fairlie, Kapur & Gates 2011) has been studied with ACA and spousal coverage, but the age-65 Medicare RDD has received surprisingly little rigorous treatment with modern RDD methods (CCT bandwidth, randomization inference). Most existing work uses DiD around ACA or pre/post comparisons.

**Feasibility check:** ✅ CPS microdata available via IPUMS (have API key). ✅ Large samples near age 65. ✅ Running variable (age) is precise. ⚠️ Other things change at 65 (Social Security claiming, retirement norms) — need to distinguish Medicare channel from general retirement. ⚠️ Age heaping/rounding in survey data.
