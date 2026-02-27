# Research Ideas

## Idea 1: Does Welfare Simplification Encourage Entrepreneurship? Universal Credit Rollout and Firm Formation in the UK

**Policy:** Universal Credit (UC) full service rollout across ~300+ Local Authorities in Great Britain, staggered monthly from November 2015 to December 2018. UC replaced six legacy benefits (JSA, ESA, Income Support, Housing Benefit, Working Tax Credit, Child Tax Credit) with a single payment and a unified 55% taper rate. For self-employed claimants, UC introduced the Minimum Income Floor (MIF) — assuming earnings of at least NMW × hours after a 12-month start-up period — and real-time HMRC earnings verification (RTI).

**Outcome:** (1) Companies House bulk data: monthly new company registrations by LA (via postcode → ONS NSPL → LA mapping), disaggregated by SIC code. (2) NOMIS Annual Population Survey: self-employment rates by LA (variable 73/74, 2004-2024).

**Identification:** Staggered difference-in-differences exploiting month-level variation in UC full service rollout across ~300+ LAs. Treatment dates sourced from DWP's official Transition Rollout Schedule (March 2018 PDF + Annex A). Estimator: Callaway & Sant'Anna (2021). Pre-treatment window: 2013-2015 (before any full service). Post-treatment: varies by cohort. Study window ends Q4 2019 to avoid COVID confounding.

**Why it's novel:** (1) UC's effect on self-employment/entrepreneurship is completely unstudied causally — existing literature is qualitative only (Griffiths & Wood 2024). (2) The mechanism is theoretically ambiguous: UC's simplified taper may encourage entry into self-employment by making income smoothing transparent, while the MIF may discourage it by penalizing low earners after 12 months. Net effect is an empirical question. (3) Companies House data as a real-time firm formation measure at the LA level is a new measurement object. (4) Policy-relevant: the UK government is currently reforming UC for the self-employed.

**Feasibility check:** Confirmed: UC rollout dates available in DWP PDF (300+ LA × month pairs). Companies House bulk data confirmed accessible (free CSV, 5M companies, exact IncorporationDate, 89% valid postcodes). NOMIS APS confirmed working (380 LAs, 2004-2024, variable 73). ONS NSPL freely available for postcode→LA linkage.

**Mechanism chain:** UC simplification → reduced complexity of benefit-work interaction → (a) lower barrier to self-employment entry, (b) MIF penalizes low-earning self-employed after 12 months → net effect on firm formation depends on which channel dominates → heterogeneity by sector (SIC code), local labour market conditions, and MIF bindingness.

**DiD feasibility:** ≥20 treated LAs per wave. 37 distinct monthly treatment cohorts. 2-3 years pre-treatment. Staggered design avoids forbidden comparisons with CS estimator.

---

## Idea 2: The Immigration Cliff: Brexit, EU Worker Loss, and Firm Dynamics in Exposed Local Labour Markets

**Policy:** End of EU free movement (January 2021) + points-based immigration system. Sharp reduction in EU worker inflows, differentially affecting sectors/LAs with high pre-Brexit EU worker concentration.

**Outcome:** Companies House firm formation/dissolution by SIC code × LA. NOMIS wages (ASHE) and vacancies.

**Identification:** Shift-share (Bartik) design: pre-2016 EU worker share by sector × LA (from APS/Labour Force Survey) × post-2021 immigration restriction. Following Goldsmith-Pinkham, Sorkin & Swift (2020) for validity of share instruments.

**Why it's novel:** Most Brexit labour market studies are descriptive. Firm-level creative destruction (not just wages) is understudied. Counter-intuitive: restrictions may increase firm formation in some sectors (recruitment agencies, automation) while destroying others.

**Feasibility check:** NOMIS APS has EU worker shares by LA. Companies House confirmed. BUT: severe COVID confound — end of free movement (Jan 2021) overlaps with COVID recovery. Separating Brexit from COVID effects is the central challenge. Using 2016 referendum as alternative shock helps but introduces anticipation issues.

---

## Idea 3: Punishing Poverty or Pushing Into Work? The Employment Effects of Council Tax Support Localisation

**Policy:** April 2013 abolition of national Council Tax Benefit, replaced by locally-designed Council Tax Support (CTS) schemes across 326 English LAs. ~150 LAs cut support to working-age claimants; ~150 maintained passthrough. Continuous variation in cut size.

**Outcome:** NOMIS claimant counts, employment rates, self-employment rates by LA.

**Identification:** Dose-response DiD exploiting cross-LA variation in CTS generosity changes, with LAs that maintained full passthrough as controls. Single treatment date (April 2013) but continuous intensity variation.

**Why it's novel:** Limited causal evidence exists. IFS (January 2026) studied this and found null employment effects, but used regression methods. A formal staggered/intensity DiD with Callaway-Sant'Anna and Companies House firm data could add value.

**Feasibility check:** CTS scheme variation is documented. NOMIS confirmed. BUT: IFS already published a comprehensive causal study in January 2026 finding no employment effects. Novelty is limited — would need a substantially different angle (e.g., firm formation, not just employment).

---

## Idea 4: The Living Wage Bite: How the National Living Wage Reshaped Local Firm Dynamics

**Policy:** National Living Wage introduction (April 2016, workers 25+). Bite varies dramatically across LAs depending on pre-existing wage distribution — low-wage areas (parts of East Midlands, Wales, North East) had much higher effective bite than London.

**Outcome:** Companies House firm birth/death rates by SIC code × LA. NOMIS employment and earnings.

**Identification:** Intensity DiD exploiting cross-LA variation in NLW bite (= fraction of workers earning below new NLW in 2015, from ASHE via NOMIS). Single treatment date (April 2016) with continuous dose.

**Why it's novel:** Extensive literature on NLW employment effects (Dube 2019, Harasztosi-Lindner 2019) but very little on firm dynamics (entry/exit). The creative destruction channel — does minimum wage increase kill low-productivity firms while creating space for higher-productivity entrants? — is theoretically important but empirically thin.

**Feasibility check:** NOMIS ASHE confirmed for bite calculation. Companies House confirmed. BUT: single treatment date limits DiD credibility without staggered adoption. Would need to rely on dose-response design. Also, some existing literature (Riley & Bondibene 2017, Dustmann et al. 2022) exists on UK minimum wage firm effects.

---

## Idea 5: From Welfare to Enterprise? Scotland's Devolved Employment Services and Self-Employment Outcomes

**Policy:** Scotland devolved employment services from April 2018 (Fair Start Scotland replaced the UK-wide Work Programme). Scotland adopted a voluntary-first, holistic approach versus England's mandatory, sanctions-driven model.

**Outcome:** NOMIS self-employment and employment rates. Companies House firm formation.

**Identification:** England-Scotland border DiD. LAs near the border provide tighter geographic comparison.

**Why it's novel:** Direct comparison of two welfare-to-work philosophies (voluntary vs mandatory) in adjacent jurisdictions.

**Feasibility check:** Clean policy variation. NOMIS and Companies House confirmed. BUT: only 2 "units" (England vs Scotland) — severely underpowered for inference. Even with LA-level analysis, clustering at the nation level gives effectively N=2. Would need spatial RDD at border, which limits sample size further.
