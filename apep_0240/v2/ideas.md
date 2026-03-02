# Research Ideas

## Idea 1: Flood Risk Disclosure Laws and Housing Market Capitalization of Flood Risk

**Policy:** State adoption of mandatory seller disclosure laws requiring flood risk/history information in real estate transactions. ~28 states adopted laws with flood-specific disclosure content between 1992-2024, with a particularly active recent wave (2019-2024) including Texas SB 339 (2019), Florida (2024), New York (2023), New Jersey (2023), North Carolina (2024), and others. ~14 states remain without mandatory flood disclosure (AL, AR, AZ, GA, ID, KS, MA, MO, MT, NM, UT, VA, WV, WY).

**Outcome:** County-level housing values from Zillow Home Value Index (ZHVI), monthly frequency, free public data. Also Census Annual Survey building permits for new residential construction activity.

**Identification:** Staggered DiD with Callaway-Sant'Anna heterogeneity-robust estimator. Treatment: state adoption of flood disclosure law. Triple-diff available: (flood-exposed counties vs. non-flood-exposed counties) × (treated states vs. controls) × (before vs. after). Flood exposure measured by historical FEMA disaster declarations for flood events. The key prediction: disclosure laws should cause housing prices in flood-prone areas to decline relative to non-flood areas within the same state (as hidden flood risk is capitalized), while non-flood areas should see no effect or mild positive spillovers.

**Why it's novel:** Existing work (Fannie Mae 2024 on Texas SB 339) studies single states. A multi-state DiD exploiting the 2019-2024 legislative wave is genuinely new. The triple-diff design (flood vs. non-flood areas) within a staggered adoption framework provides very clean identification. The mechanism test—whether disclosure simply capitalizes already-known risk or provides genuinely new information—has not been systematically tested across states.

**Feasibility check:** Confirmed: 28+ treated states with staggered adoption (1992-2024), 14 never-treated controls. Zillow ZHVI is accessible (HTTP 200, 13MB CSV). FEMA OpenFEMA disaster declarations API confirmed working. Building permits data available from Census. NRDC State Flood Disclosure Scorecard provides systematic grading of all 50 states.

---

## Idea 2: State Climate Action Plans and Clean Energy Employment

**Policy:** State adoption of formal climate action plans (CAPs). C2ES reports 33 states have released or are developing climate action plans, with staggered adoption from 2001 (Rhode Island) through 2020+ (recent state updates). Plans include GHG reduction targets, renewable energy mandates, and adaptation strategies.

**Outcome:** Clean energy employment (BLS QCEW, Green Goods and Services data), renewable energy capacity (EIA State Energy Data System), or electricity generation by source (EIA-923 data).

**Identification:** Staggered DiD. Treatment: state adoption of first climate action plan. 30+ treated states with adoption spanning 2001-2020, providing excellent staggering. ~17 never-treated states serve as controls.

**Why it's novel:** While individual CAP components (RPS, cap-and-trade) have been studied, the comprehensive effect of the umbrella CAP itself—which bundles multiple policies, creates bureaucratic infrastructure, and signals political commitment—has not been studied as a unified treatment.

**Feasibility check:** Likely sufficient states (30+), but treatment definition is diffuse (plans vary enormously in content and ambition). Outcome data available from EIA and BLS. Key concern: plans are bundled with other policies, making it hard to isolate the plan's independent effect. Georgetown Climate Center provides systematic tracking.

---

## Idea 3: FEMA Flood Map Revisions and Local Fiscal Impacts

**Policy:** FEMA periodically updates its Flood Insurance Rate Maps (FIRMs), reclassifying areas as Special Flood Hazard Areas (SFHAs) or removing that designation. Map revisions happen at different times across communities, creating staggered treatment.

**Outcome:** Local government property tax revenue (Census Annual Survey of State and Local Government Finances), new residential building permits (Census Building Permits Survey), housing values (Zillow ZHVI).

**Identification:** County-level event study / staggered DiD. Treatment: county receives FEMA FIRM revision that expands SFHA designation. Staggering comes from the administrative timeline of FEMA's mapping schedule, which is driven by budget and bureaucratic priorities rather than local economic conditions.

**Why it's novel:** The fiscal externality of flood zone reclassification has not been studied. If FIRM revisions reduce property values (as existing work suggests), this reduces the property tax base and affects local government revenues. This creates a perverse incentive: local governments may resist map updates that would improve risk communication because they would reduce tax revenue. This is a genuinely new mechanism.

**Feasibility check:** FEMA FIRM effective dates are available through the National Flood Hazard Layer. Census government finance data is publicly available. However, assembling the treatment variable requires mapping FIRM revision dates to counties, which involves GIS processing of FEMA map data. More complex data assembly than Idea 1.

---

## Idea 4: State Building Code Stringency and Weather-Related Disaster Losses

**Policy:** States adopt updated versions of the International Building Code (IBC) and International Residential Code (IRC) at different times. Over 50% of states still use 2018 or older code versions, while others have adopted 2021 or 2024 editions. Each code cycle brings stricter structural requirements for wind, flood, and seismic resistance.

**Outcome:** Property damage from weather events (NOAA Storm Events Database), FEMA disaster assistance per capita (OpenFEMA), insurance claims (NFIP).

**Identification:** DiD interacted with weather intensity. Treatment: state adopts newer IBC/IRC version. Compare damage from comparable weather events in states with newer vs. older codes. Weather event intensity (from NOAA Storm Events) serves as the "dose" variable.

**Why it's novel:** While specific provisions (Florida's post-Andrew code) have been studied, a systematic cross-state analysis of code stringency and weather resilience has not been done. The interaction design (code × weather intensity) is clean because weather events are quasi-random conditional on geography.

**Feasibility check:** CONCERN: Building code effect operates through NEW construction only, creating a very slow treatment effect. States that adopted newer codes in 2021 will have barely any new-code housing stock by 2025. Also, assembling the treatment variable (exact adoption dates for each state × code version) requires compiling from ICC records. This idea is conceptually strong but execution is challenging.

---

## Idea 5: FEMA Disaster Declarations and Local Employment Recovery

**Policy:** FEMA issues major disaster declarations that unlock federal assistance programs (Individual Assistance, Public Assistance, Hazard Mitigation Grant Program). Declarations happen at different times across states and counties, creating massive staggered variation (thousands of declarations since 1953).

**Outcome:** County-level quarterly employment and wages from BLS QCEW or Census QWI.

**Identification:** Staggered event study design. Treatment: county-level FEMA major disaster declaration for weather event. Compare employment trajectories in declared counties to similar counties without declarations. Event-time coefficients trace out the recovery path.

**Why it's novel:** While disaster effects on employment have been studied, the specific causal effect of the FEDERAL DECLARATION (vs. disasters that don't receive declarations) has not been cleanly identified. Some disasters that meet the threshold get declared and others don't, creating variation in federal aid that could be exploited.

**Feasibility check:** FEMA OpenFEMA API confirmed working (69,615 records, 1953-present). BLS QCEW is publicly available at county-quarterly level. However, the identification concern is that declarations are endogenous to damage severity—worse disasters get declared. Without a clean RDD or IV at the declaration threshold, this is correlational. Might work better as RDD than DiD.
