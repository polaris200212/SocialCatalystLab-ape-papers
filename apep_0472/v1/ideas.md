# Research Ideas

## Idea 1: The Waterbed Effect — Crime Displacement from Selective Licensing of England's Private Rented Sector

**Policy:** Selective licensing of private rented housing under Housing Act 2004 (Part 3). English Local Authorities (LAs) can designate areas requiring all private landlords to obtain a license. Staggered adoption across 30+ LAs from 2007 to 2026: Gateshead (2007), Bolton (2008), Newham (2013), Liverpool (2015), Nottingham (2018), Waltham Forest (2020), Enfield (2021), Birmingham (2023), Brent (2024), and many more.

**Outcome:** Street-level crime data from the UK Police API (LSOA × month panel, 14 crime categories, 2010–2024). Property prices from HM Land Registry Price Paid Data (24M+ transactions, postcode-level, 1995–2024). Linked via postcodes.io to LSOA/LA geography.

**Identification:** Staggered DiD exploiting differential LA adoption timing of selective licensing. Treatment: LSOA is in an LA that has adopted selective licensing. Callaway–Sant'Anna estimator with never-treated and not-yet-treated controls. Event-study pre-trends tests. Placebo: crime categories unlikely affected by landlord regulation (e.g., fraud, drug trafficking through organized networks). Displacement test: compare crime in LSOAs adjacent to licensing boundaries (within 1–5 km buffer) to interior LSOAs.

**Why it's novel:** Only 2–3 causal papers exist on selective licensing (focused on London mental health outcomes). ZERO papers examine crime effects, property price effects, or spatial displacement. The "waterbed hypothesis" — that licensing squeezes problems into adjacent unlicensed areas — is widely debated by landlord groups and councils but has never been tested with data. This reframes a niche housing policy as a general mechanism test of regulatory displacement, contributing to the broader literature on place-based policy spillovers.

**Feasibility check:** Confirmed: 30+ LAs with verifiable staggered adoption dates spanning 2007–2026. Police API tested and returns 6,547+ records per query with LSOA-level geocoding. Land Registry confirmed working (24M+ transactions). NOMIS confirmed working for LA-level covariates. Scheme dates verifiable from council websites, NRLA Licensing 365 tracker, and House of Commons Library briefing SN04634.

**Mechanism chain:** Licensing → mandatory "fit and proper person" test → landlords screen tenants more carefully → antisocial behavior/crime drops locally → BUT displaced tenants/landlords relocate to unlicensed areas → crime rises in neighbors → net welfare effect ambiguous.

**Scale:** ~33,000 LSOAs × 14 years × 12 months = ~5.5M LSOA-month observations for crime. 24M property transactions. ≥30 treated LAs with different adoption dates.

**Welfare deliverable:** Compute net welfare effect: localized crime reduction (valued via property price capitalization) minus displaced crime in adjacent areas. If displacement is near-complete, policy has ~zero net benefit (just redistributes harm). If displacement is limited, policy is more effective than critics claim. Either result is publishable.

---

## Idea 2: Last Orders — How Alcohol Cumulative Impact Policies Reshape Local Economies

**Policy:** Cumulative Impact Assessments (CIAs) under the Licensing Act 2003. LAs adopt CIAs creating a rebuttable presumption against new licensed premises in designated areas. Statutory footing from 2017 (Policing and Crime Act). 75+ LAs with 182 CIAs as of March 2024. Staggered adoption from 2007 to 2024.

**Outcome:** Street-level crime (Police API, LSOA × month), with focus on alcohol-related categories (violence, public order, anti-social behaviour). Firm entry/exit of licensed premises (Companies House bulk data, filtered by SIC codes 56.30 = drinking establishments). Property prices (Land Registry PPD).

**Identification:** Staggered DiD across 75+ LAs using Callaway–Sant'Anna. Treatment: LSOA in LA that adopted CIA. Event study examining crime dynamics around CIA adoption. Placebo: non-alcohol crime categories (burglary, vehicle crime). Triple-diff: CIP-designated areas within treated LAs vs non-designated areas within same LA (within-LA variation).

**Why it's novel:** Existing literature (de Vocht et al., Bristol group) uses public health methods (hierarchical growth models, Bayesian synthetic controls) and focuses on hospital admissions. No economics paper exploits staggered adoption in a modern DiD framework. No study examines economic outcomes (firm dynamics, property values, employment). The "is it crime reduction or displacement?" question is unanswered for alcohol licensing.

**Feasibility check:** Confirmed: 75+ treated LAs (well above 20 minimum). Home Office publishes annual Alcohol Licensing statistics. de Vocht et al. obtained systematic adoption dates from Home Office for 2007–2012. Police API confirmed working. Companies House bulk data available. Challenge: individual CIA adoption dates not centrally compiled post-2012 — may need to use Home Office statistics or LA licensing policy documents.

**Risk:** CIA adoption dates may be harder to compile than selective licensing dates. The existing Bristol group has a first-mover advantage on this topic. CIAs target specific zones within LAs, complicating LSOA-level treatment assignment.

---

## Idea 3: Flood Re and the Price of Climate Risk — How Government Reinsurance Recapitalized Flood-Prone Property

**Policy:** Flood Re, a government-backed reinsurance scheme launched April 2016. Before Flood Re, properties in high-flood-risk areas faced prohibitively expensive or unavailable insurance. Flood Re caps insurance premiums for flood-zone properties based on Council Tax band. Available for properties built before 2009 only (new-build exclusion creates a natural control).

**Outcome:** Property prices from Land Registry PPD (postcode-level, 1995–2024). Treatment defined using EA flood zone maps (Flood Zone 2 and 3 designations available from the EA). Linked via postcodes.io and EA station data.

**Identification:** DDD design: (flood zone vs non-flood zone) × (pre-2009 build vs post-2009 build) × (before vs after April 2016). The pre-2009/post-2009 build distinction provides a within-flood-zone control group (post-2009 builds in flood zones are NOT eligible for Flood Re). Additional variation from Council Tax bands (Flood Re premiums capped at band-specific levels, so lower-band properties benefit more). Event study around April 2016 launch.

**Why it's novel:** No paper has exploited Flood Re as a natural experiment. Existing UK flood-property literature (Beltran et al. 2019, JEEM) uses repeat-sales for flood events but ignores the insurance channel. The new-build exclusion creates a textbook within-flood-zone control. Can estimate the capitalization of insurance access into property values — directly relevant to climate adaptation policy design worldwide.

**Feasibility check:** Land Registry confirmed working (24M+ transactions). EA flood monitoring API confirmed working (1,034 stations). EA flood zone maps downloadable from data.gov.uk. postcodes.io confirmed working for LSOA linkage. Challenge: need to classify each Land Registry transaction as "in flood zone" or not (requires spatial join of postcodes to flood zone polygons, which may need GIS processing).

**Risk:** Not a staggered DiD — it's a DDD around a single national policy date (April 2016). This means fewer identification checks (no staggered event study). Flood zone classification may have measurement error (postcodes span multiple flood zones). Pre-2009/post-2009 build distinction requires the "Old/New" flag in Land Registry data (which distinguishes new-build from resale but not construction date precisely).

---

## Idea 4: Creative Destruction Deferred — The Local Labor Market Costs of COVID Insolvency Protection

**Policy:** Corporate Insolvency and Governance Act 2020 (CIGA). Winding-up petition restrictions from April 2020 to March 2022 (extended 4 times). Wrongful trading suspension from March 2020 to June 2021. Result: lowest company insolvencies since 1989 in 2020, followed by highest since 1993 in 2023.

**Outcome:** LSOA-level firm dissolution rates (Companies House bulk data, ~5M companies with registered postcodes). NOMIS claimant count (LA-month). Land Registry property prices. Crime (Police API).

**Identification:** Shift-share/exposure design: pre-COVID zombie firm concentration at the LSOA level (defined as firms with low profitability, high age, low growth using Companies House accounts data) × post-CIGA unwinding dates (October 2021, March 2022). The identifying assumption is that pre-COVID zombie concentration is exogenous to post-CIGA labor market shocks conditional on LSOA-level controls.

**Why it's novel:** No causal economics paper evaluates CIGA's effect on zombie firms and local labor markets. The UK insolvency surge (2022–2025) is discussed in policy circles but unstudied econometrically. Creates a new measurement object: "zombie concentration index" at LSOA level using Companies House microdata. Directly relevant to the pandemic policy design literature.

**Feasibility check:** Companies House bulk data confirmed available (monthly snapshots). NOMIS confirmed working. Insolvency Service publishes quarterly statistics. Challenge: CIGA is a national policy — no LA-level staggering. Must rely on cross-sectional exposure variation (shift-share), which tournament judges sometimes criticize as "Bartik-style mechanical instruments."

**Risk:** Shift-share identification may not be convincing enough for tournament judges who prefer staggered quasi-experiments. Companies House accounts data (needed for "zombie" classification) requires XBRL parsing. Sample limited to firms that file accounts (many small firms exempt).

---

## Idea 5: Planning by Stealth — Employment Displacement from Office-to-Residential Permitted Development Rights

**Policy:** Class J/O/MA Permitted Development Rights allowing office-to-residential conversion without planning permission, introduced May 2013 nationally. Some LAs obtained Article 4 Directions blocking PDR (creating a control group). ~15–20 LAs have confirmed Article 4 Directions against office-to-residential PDR.

**Outcome:** Employment density (NOMIS, LA-level from BRES/ABS). Firm location (Companies House registered addresses). Property prices (Land Registry). Housing supply (MHCLG/DLUHC live tables on net additional dwellings).

**Identification:** DiD comparing LAs with Article 4 Directions (PDR blocked, control) vs LAs without them (PDR active, treatment). Event study around May 2013 introduction. For LAs that obtained Article 4 later (2020–2022), use the Article 4 adoption as a "de-treatment" event (PDR was active, then blocked).

**Why it's novel:** No economics paper uses Article 4 variation in a DiD framework. Existing literature is urban studies/planning (descriptive, qualitative). The employment displacement question — did converting offices to flats destroy local jobs? — is completely unstudied with causal methods. Directly relevant to the global debate on zoning deregulation.

**Feasibility check:** Article 4 Direction dates available from GOV.UK Secretary of State modification letters and council planning pages. Companies House and NOMIS confirmed working. Challenge: only ~15–20 LAs have Article 4 Directions against Class MA PDR, borderline on the 20-unit minimum. Most Article 4 Directions cluster around July–August 2022 (limited temporal staggering). The original 2013 Class O exemptions provide better variation but require historical research.

**Risk:** Borderline number of treated units may reduce statistical power. Limited temporal staggering (most Article 4s cluster in 2022). Article 4 Directions are endogenous — LAs with more office space are more likely to adopt them, requiring controls for baseline economic structure.
