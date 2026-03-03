# Research Ideas — apep_0493

## Idea 1: The Price of Austerity: Council Tax Support Localisation and Low-Income Employment

**Policy:** In April 2013, the UK government devolved Council Tax Benefit (a national scheme providing 100% council tax relief to ~5.8 million low-income households) to 326 English Local Authorities, with a 10% budget cut. Each LA designed its own Council Tax Support (CTS) scheme: ~62 LAs maintained full protection (no minimum payment), while ~264 LAs imposed minimum payments ranging from 5% to 40%+ of council tax liability on previously-exempt working-age claimants. This created sharp, quasi-random variation in the effective tax on non-employment across otherwise-similar areas.

**Outcome:** Employment and benefit claiming. Primary: NOMIS claimant count (JSA/UC) by LA, monthly, 1986-2026. Secondary: Council tax collection rates and arrears from DLUHC annual statistics. Tertiary: ASHE earnings by LA from NOMIS.

**Identification:** Continuous-treatment DiD. Pre-period (2008-2012): all LAs under identical national CTB. Post-period (2013-2023): LAs vary in CTS cut intensity. Treatment intensity measured from DLUHC Council Taxbase data (change in CTS reduction per dwelling between 2012/13 and 2013/14, normalized by pre-reform CTS claims). Estimator: Callaway & Sant'Anna with continuous treatment or two-group (protected vs. cut) binary DiD. Pre-trends testable because both groups operated under identical national policy pre-2013.

**Why it's novel:** Virtually no peer-reviewed academic literature exists. One IFS policy report (Adam, Joyce, Pope 2019) found null employment effects using cross-sectional regression, but did not exploit the panel structure, used no event-study framework, and did not apply modern staggered DiD methods. No AER/QJE/EJ publication. The question — whether imposing financial penalties on non-working benefit claimants increases employment or merely creates financial distress — is at the heart of global welfare reform debates.

**Feasibility check:**
- Confirmed: NOMIS API returns claimant count by LA-month back to 1986 (tested via REST API, 1,624 rows for 4 dates × 406 LAs)
- Confirmed: DLUHC Council Taxbase statistics downloadable as ODS files from GOV.UK (Table 1.29 gives CTS reduction by LA)
- Confirmed: Band D council tax levels by LA available 1993-2026
- Treatment variable: Binary split (protected vs. cut) is documented in NPI/Entitledto annual reports. Continuous treatment (minimum payment %) available from Entitledto blog posts (2013-2026) — may require extraction from PDFs. Alternative: construct treatment from council taxbase data changes.
- Pre-treatment periods: 5+ years (2008-2012) under national CTB
- Treated clusters: ~264 LAs imposed cuts (well above 20)
- Control clusters: ~62 LAs maintained full protection

**Key risks:** (1) Treatment variable construction requires effort — entitledto data is in blog posts/PDFs, not downloadable CSV. Fallback: use council taxbase changes as proxy. (2) IFS found null — our contribution must explain why modern DiD may yield different conclusions (panel structure, event study, treatment heterogeneity, longer post-period).


## Idea 2: Conditioned to Work? Universal Credit's In-Work Regime and Labour Supply at the Intensive Margin

**Policy:** Universal Credit's "Full Service" rollout (2016-2018) introduced in-work conditionality — requiring employed claimants earning below a threshold to attend work coach meetings and demonstrate job search/hours progression. This was unprecedented: no prior UK benefit imposed mandatory requirements on employed people. The rollout was staggered across ~300 Jobcentre Plus offices, with precise dates published by DWP.

**Outcome:** Hours worked and earnings progression. ASHE (Annual Survey of Hours and Earnings) by LA from NOMIS; NOMIS Annual Population Survey (hours worked); claimant count transitions (off-benefit rate).

**Identification:** Staggered DiD exploiting variation in Full Service rollout dates across Jobcentres/LAs. Treatment timing driven by DWP administrative capacity and IT readiness, not local labour market conditions. Estimator: Callaway & Sant'Anna.

**Why it's novel:** Existing APEP papers on UC focus on entrepreneurship (apep_0471) and employment composition (apep_0473). Academic papers focus on mental health (Wickham et al. 2024) and housing insecurity (Reeve 2022). No published study isolates the in-work conditionality mechanism using the staggered rollout. This is the most contentious feature of UC.

**Feasibility check:**
- Confirmed: DWP rollout schedule published on GOV.UK with exact Jobcentre dates
- Confirmed: NOMIS provides ASHE earnings and APS hours by LA
- Concern: ASHE is annual, not monthly — limits event-study precision
- Concern: Need to verify that APS data covers sufficient LAs at adequate sample size
- Pre-treatment: 5+ years (2010-2015) before Full Service rollout
- Treated clusters: ~300 Jobcentres (maps to LAs)


## Idea 3: The Training Tax: Britain's Apprenticeship Levy and the Restructuring of Youth Employment

**Policy:** In April 2017, the UK introduced a 0.5% payroll tax on employers with annual pay bills exceeding £3 million. Revenue funds employer "digital accounts" for apprenticeship training. The levy simultaneously increased large-employer training costs (substituting free government grants for mandatory contributions) and reduced small-employer access to subsidized training (the old system's flexibility was curtailed).

**Outcome:** Apprenticeship starts by LA and level from DfE Explore Education Statistics (2009/10-2024/25). Youth employment (16-24) from NOMIS claimant count and APS. Business counts by size band from NOMIS (IDBR).

**Identification:** Continuous-treatment DiD exploiting LA-level variation in pre-levy share of employment in levy-paying firms (250+ employees, from NOMIS IDBR data). LAs with higher concentrations of large employers are more exposed to the levy shock. Event: April 2017.

**Why it's novel:** No top-journal publication on the UK Apprenticeship Levy's causal effects. The CVER discussion paper (Conlon et al. 2021) used firm-level matching, not geographic exposure. The shift-share geographic approach would be new. The composition story (fewer Level 2 starts, more Level 4+; fewer young apprentices, more adult; small firms squeezed out) has policy implications for skills strategy.

**Feasibility check:**
- Confirmed: DfE publishes apprenticeship starts by LA from 2009/10 (CSV download)
- Confirmed: NOMIS IDBR data provides business counts by size band by LA from 2010
- Pre-treatment: 7+ years (2009/10-2016/17)
- Concern: Shift-share/Bartik design — lessons warn about "mechanically endogenous exposure measures"
- Concern: Simultaneous apprenticeship standards reform complicates identification
- Treated clusters: All 300+ LAs (continuous treatment), but effectively comparing high-vs-low exposure


## Idea 4: Zones of Employment? Staggered Designation and Local Labour Market Effects of England's Enterprise Zones

**Policy:** England designated Enterprise Zones (EZs) in two rounds: 24 zones in April 2012 and 24 additional zones in 2016-2017. EZs offer business rate discounts (up to £275K over 5 years), simplified planning, and enhanced capital allowances. Each zone has defined geographic boundaries.

**Outcome:** BRES workplace employment by LSOA/LA from NOMIS. Business demography (entries/exits) from ONS. Potentially Land Registry property prices near zone boundaries.

**Identification:** Staggered DiD exploiting the two distinct designation rounds. Units: EZ vs. matched non-EZ areas (propensity score or nearest-neighbour matching on pre-period characteristics). LSOA-level analysis using EZ boundary shapefiles from data.gov.uk. Can test for displacement (employment gains inside zones offset by losses nearby).

**Why it's novel:** Existing evaluations (What Works Centre, Chaudhary & Potter 2019) did not use modern staggered DiD or LSOA-level microdata. No CS-DiD analysis exploiting the two rounds. Displacement analysis using geographic proximity is genuinely new.

**Feasibility check:**
- Confirmed: EZ boundary shapefiles on data.gov.uk
- Confirmed: BRES employment data available from NOMIS at LSOA level
- Pre-treatment: 3 years for Round 1 (2009-2012), 7+ years for Round 2 (2009-2016)
- Concern: Only 48 zones — borderline for cluster count (but each zone contains multiple LSOAs)
- Concern: Selection into EZ designation is endogenous (deprived areas chosen)


## Idea 5: The Benefit Cap and the Geography of Work Incentives

**Policy:** The UK Benefit Cap limits total household welfare payments. Introduced April 2013 (piloted in 4 London boroughs), rolled out nationally in July-September 2013 at £26,000/year (£500/week). Lowered to £20,000 (£23,000 in London) in November 2016. The cap's bite varies enormously across LAs because Housing Benefit (the largest component for affected families) reflects local rent levels.

**Outcome:** Employment entry (claimant count-to-employment transitions) from NOMIS. Housing moves (benefit cap households forced to relocate) from DWP Stat-Xplore. Children in poverty from DWP.

**Identification:** Exposure-based DiD. Treatment intensity = pre-reform share of benefit claimants expected to exceed the cap (based on LA-level rent distributions and household composition). The 2016 cap reduction provides a second shock for event-study verification. Estimator: two-way FE or CS-DiD with continuous treatment.

**Why it's novel:** DWP published descriptive evaluations showing ~5pp employment increase among capped households. But no rigorous DiD exploiting the geographic variation in cap bite with modern estimators. The key contribution: decomposing employment effects from residential mobility effects (do capped households move to cheaper areas or find work?).

**Feasibility check:**
- Confirmed: NOMIS claimant count by LA (monthly)
- DWP Stat-Xplore provides benefit cap caseloads by LA (need to verify API access)
- VOA (Valuation Office Agency) provides local rent data for treatment intensity construction
- Pre-treatment: Limited (cap introduced July 2013, same year as CTS reform)
- Concern: Two treatments coincide (CTS localisation + benefit cap, both April-September 2013) — identification requires careful separation
- Treated clusters: All 300+ LAs (continuous treatment based on cap exposure)
