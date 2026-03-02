# Research Ideas

## Idea 1: Decarceration Without Danger? Progressive Prosecutors, Jail Populations, and Homicide Mortality

**Policy:** Election of progressive/reform district attorneys across ~30 US counties (staggered 2014–2022). Progressive DAs are defined using the Petersen, Mitchell & Yan (2024) taxonomy: endorsement of 6+ of 29 reform policy sub-items spanning non-prosecution, bail reform, sentencing reform, diversion, and police accountability. Key treated counties include Cook (Foxx 2016), Philadelphia (Krasner 2018), Los Angeles (Gascon 2020), San Francisco (Boudin 2020), Dallas (Creuzot 2019), Harris (Ogg 2016), Suffolk/Boston (Rollins 2019), and ~20 others.

**Outcome:**
- Primary: County-level jail population and jail population rate (Vera Institute Incarceration Trends, 1970–2024, GitHub download confirmed)
- Secondary: County-level homicide mortality rate (County Health Rankings, 2010–2024, direct URL download confirmed)
- Mechanism: Pretrial vs. sentenced jail population; Black vs. White jail population rates (Vera racial breakdowns)
- Controls: Census ACS county demographics (API confirmed working)

**Identification:** Staggered DiD (Callaway–Sant'Anna) exploiting variation in timing of progressive DA elections across counties. The design makes three contributions no existing paper achieves:
1. **First-stage verification with administrative incarceration data**: Vera jail populations directly measure whether progressive DAs change incarceration — the existing literature (Agan et al. 2025, Petersen et al. 2024) skips this step entirely.
2. **Mechanism decomposition**: Pretrial jail population (bail reform channel) vs. sentenced jail population (charging/sentencing channel) vs. racial composition (equity channel).
3. **Mortality-based crime measure**: Homicides from vital statistics CANNOT be under-reported, addressing the critique that UCR crime data reflects reporting changes rather than actual crime changes.

**Why it's novel:**
- Agan et al. (2025 NBER) uses UCR crime data + some charging data but never examines administrative jail populations
- Petersen et al. (2024 C&PP) treats progressive DAs as binary treatment on UCR crime; no incarceration mechanism
- No existing paper combines Vera incarceration data with progressive DA identification
- The racial decomposition (Black/White jail rates × progressive DA × pre/post) directly tests the stated goal of progressive prosecution: reducing racial disparities

**Feasibility check:**
- ✅ Vera data: 1970–2024, county FIPS, direct GitHub CSV download confirmed
- ✅ CHR homicide data: 2010–2024, county FIPS, direct URL download confirmed
- ✅ Census ACS: All years, county FIPS, API working (tested with CENSUS_API_KEY)
- ✅ ~30 treated counties, staggered 2014–2022 (≥8 years of pre-treatment for latest cohort)
- ✅ Not in APEP list (no progressive prosecutor papers exist)
- ✅ Literature gap confirmed: existing papers use UCR, none use Vera jail data


## Idea 2: The Charge Channel — How Progressive Prosecutors Reshape Deterrence Signals

**Policy:** Same progressive DA elections as Idea 1, but focused on the SIGNALING mechanism. When progressive DAs publicly announce they won't prosecute certain offenses (marijuana possession, petty theft under thresholds), they change the expected cost of crime for offenders.

**Outcome:**
- Primary: Crime by type from city-level Socrata open data portals (Chicago, Philadelphia, San Francisco, Los Angeles, etc.)
- DDD design: DA-deprioritized crime types (drug offenses, misdemeanor theft, trespassing) vs. DA-maintained types (violent crimes, gun crimes) × progressive DA × before/after
- Controls: Census ACS demographics

**Identification:** Triple-difference (DDD). The third dimension — deprioritized vs. maintained crime types — provides a built-in placebo. If ALL crime increases equally, the mechanism isn't deterrence signaling; if only deprioritized crimes increase, it IS.

**Why it's novel:** No paper systematically classifies which crime types each DA deprioritized and uses within-DA crime-type variation for identification.

**Feasibility check:**
- ⚠️ Data: Requires assembling crime data from individual city Socrata portals (inconsistent schemas)
- ⚠️ Sample: Limited to cities with open data AND progressive DAs (~10-15)
- ⚠️ Crime type classification: Need to hand-code which crimes each DA explicitly deprioritized
- ✅ Novel DDD design with built-in placebo
- ❌ FBI CDE API confirmed non-functional; no county-level UCR data via API


## Idea 3: The Geography of Justice — Spatial Spillovers from Progressive Prosecution

**Policy:** Same progressive DA elections, but examining effects on NEIGHBORING counties (spatial displacement).

**Outcome:**
- Crime or incarceration changes in counties bordering progressive DA jurisdictions
- Border county pairs: one side has progressive DA, other doesn't
- Vera jail data for neighboring counties

**Identification:** Spatial DiD / Border discontinuity. Compare trends in border counties that share a jurisdictional boundary but differ in DA type.

**Why it's novel:** No paper examines whether progressive prosecution displaces crime or incarceration to neighboring jurisdictions.

**Feasibility check:**
- ✅ Vera jail data covers all counties
- ⚠️ Need county adjacency file (Census provides this)
- ⚠️ Power concern: Progressive DA counties are typically large urban counties; their "neighbors" may be very different (suburban/rural)
- ⚠️ Displacement in incarceration doesn't make economic sense (crimes are prosecuted where committed)
- ✅ Novel spatial dimension


## Idea 4: Racial Convergence or Divergence? Progressive Prosecutors and the Black-White Incarceration Gap

**Policy:** Same progressive DA elections, with explicit focus on racial equity outcomes.

**Outcome:**
- Black/White jail incarceration rate ratio (Vera data)
- Black/White homicide mortality rate ratio (CHR data)
- DDD: Black vs. White × Progressive DA × Before/After

**Identification:** DDD where the third dimension is race. Progressive DAs explicitly aim to reduce racial disparities. The test: does the Black-White incarceration gap narrow AND does the Black-White victimization gap narrow (or widen)?

**Why it's novel:** The racial tradeoff framing — can you reduce racially disparate incarceration without increasing racially disparate victimization — has not been empirically tested in the progressive prosecution context.

**Feasibility check:**
- ✅ Vera has jail population by race (Black, White, Latinx, Native, AAPI) at county level
- ✅ CHR has homicide rates by race at county level
- ⚠️ Small cell sizes for race-specific jail/mortality in smaller counties (suppression)
- ✅ Politically important, scientifically clear question
- ✅ DDD with built-in mechanism test


## Idea 5: Progressive Prosecutors and Local Economic Activity

**Policy:** Same progressive DA elections, but measuring economic spillovers.

**Outcome:**
- County-level employment in crime-sensitive industries (retail NAICS 44-45, food service 722, security 5616) from BLS QCEW
- County-level establishment counts from County Business Patterns

**Identification:** DiD × industry type (crime-sensitive vs. insensitive) = DDD.

**Why it's novel:** No paper examines the economic consequences of progressive prosecution. "Crime as a hidden tax" framing connects criminal justice to urban economics.

**Feasibility check:**
- ✅ BLS QCEW has county-level employment by industry (API accessible)
- ⚠️ Mechanism is indirect: DA → crime perceptions → business decisions → employment
- ⚠️ Many steps in the causal chain — hard to isolate
- ✅ Novel economic outcome no paper has examined
