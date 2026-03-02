# Research Ideas

## Idea 1: Virtual Snow Days and the Weather-Absence Penalty for Working Parents

**Policy:** State laws authorizing public schools to use virtual/remote instruction instead of canceling classes during inclement weather ("virtual snow day" laws). Staggered adoption: Kentucky, New Hampshire, Kansas, Missouri, West Virginia (2011 — packet-based); Minnesota (2017 — 5 e-learning days); Illinois, Pennsylvania (2019); New York, Virginia, Maryland (2022); New Jersey (2023). Twenty-three states limit virtual weather days; 4 states prohibit them entirely (Arkansas, Massachusetts, DC, and others).

**Outcome:** Parental work absences during severe winter weather. Data: CPS Monthly public-use microdata (free from Census, includes state FIPS, absence reason codes for "bad weather" and "childcare problems"). Supplemented with NOAA Global Historical Climatology Network (GHCN) daily snowfall data at the county level.

**Identification:** Difference-in-differences comparing parental work absence rates in states that adopted virtual snow day policies vs. states that did not. Key interaction: policy × snowfall intensity × parent status (triple-difference). The treatment effect operates through the interaction: virtual snow day policies should attenuate the "snowfall → school closure → childcare scramble → missed work" channel. Pre-COVID adopters (2011-2019, ~8 states) provide cleanest variation; post-COVID adopters (2022-2023, ~15 additional states) supplement with Callaway-Sant'Anna estimators to handle heterogeneous timing.

**Why it's novel:** No causal study examines how school weather-closure policies affect parental labor supply. Existing literature studies snow days' effects on student learning (Marcotte 2007; Goodman 2014) but not the labor market spillover to parents. The COVID-era expansion of virtual instruction creates unprecedented policy variation.

**Feasibility check:** BLS CPS data confirmed accessible via API (series LNU02036012 returns monthly absence counts). CPS microdata freely downloadable from Census. NOAA GHCN daily data available via CDO API. 23+ treated states identified. Concern: COVID contamination of treatment timing requires careful design (focus on pre-COVID adopters for clean identification + post-COVID for DDD with weather shocks).

---

## Idea 2: FEMA Pre-Disaster Mitigation Grants and Subsequent Weather Damage Reduction

**Policy:** FEMA's Pre-Disaster Mitigation (PDM) grant program (1997-2019) and its successor, Building Resilient Infrastructure and Communities (BRIC, 2020-present). These competitive grants fund hazard mitigation projects (flood barriers, drainage upgrades, wind-resistant retrofits, safe rooms) BEFORE disasters strike. States and localities receive grants at different times and amounts. All 50 states participate.

**Outcome:** Property damage and casualties from subsequent severe weather events in recipient vs. non-recipient jurisdictions. Data: OpenFEMA Hazard Mitigation Grant Program (HMGP) awards, OpenFEMA Disaster Declarations, NOAA Storm Events Database (property damage, crop damage, injuries, deaths by county-event).

**Identification:** Staggered DiD comparing county-level weather damage outcomes before vs. after receiving PDM/BRIC grants, using similar non-recipient counties as controls. Key advantage: FEMA's competitive grant allocation creates quasi-experimental variation — counties that applied but didn't receive grants form a natural comparison group. Weather events (storms, floods, tornados) provide the "test" of mitigation investment effectiveness.

**Why it's novel:** Despite billions in federal mitigation spending, rigorous causal evaluation of PDM/BRIC effectiveness is remarkably scarce. FEMA's own benefit-cost analyses use engineering models, not empirical counterfactuals. A 2019 NIBS report estimated $6 saved per $1 of mitigation spending, but this was not based on causal identification.

**Feasibility check:** OpenFEMA API confirmed working (disaster declarations return clean JSON). NOAA Storm Events data publicly available. 50 states with county-level variation. 5+ years pre-treatment for early PDM grants (1997+). Concern: grant receipt may be endogenous to disaster risk (higher-risk areas apply more). Can address with matching on pre-treatment disaster exposure and using application-but-rejected as control.

---

## Idea 3: State Building Code Modernization and Severe Weather Property Damage

**Policy:** State adoption of International Building Code (IBC) / International Residential Code (IRC) editions. The ICC updates codes every 3 years (2003, 2006, 2009, 2012, 2015, 2018, 2021). States adopt different editions at different times — some are on 2021 codes, others still use 2009 or earlier. Key weather-relevant provisions include wind speed design requirements (updated after Hurricane Andrew), flood elevation standards, and snow load calculations.

**Outcome:** Property damage from severe weather events (hurricanes, tornadoes, severe storms). Data: NOAA Storm Events Database (property damage by county-event), FEMA Individual Assistance claims (county-level).

**Identification:** Staggered DiD exploiting differential timing of IBC/IRC adoption across states. Newer code editions include stronger wind-resistance and flood-elevation requirements. Compare weather damage per dollar of property value in early-adopting vs. late-adopting states, conditional on storm intensity (using NOAA wind speed, precipitation data).

**Why it's novel:** The Florida building code literature (Simmons et al. 2019) studies a single state. No comprehensive multi-state DiD examines how staggered building code modernization affects weather damage nationally. The 3-year code cycle creates clean "dose-response" variation.

**Feasibility check:** ICC maintains a public code adoption tracker by state. NOAA Storm Events data is publicly available. 35+ states have adopted some IBC/IRC edition. 5+ pre-treatment years available. Concern: newer codes only apply to new construction — need sufficient post-adoption building stock turnover. Can proxy with Census new construction permits data.

---

## Idea 4: State Winter Utility Disconnection Moratoriums and Cold-Weather Mortality

**Policy:** State laws prohibiting utility companies from disconnecting residential heating service during cold weather. Thirty-two states have some form of winter disconnection protection. Key variation: temperature-based moratoriums (disconnection banned when temp < 32°F: Alabama, Arizona, Iowa at 20°F, Kansas at 35°F) vs. date-based moratoriums (November 1 to April 15: Wisconsin; December 1 to March 31: Illinois) vs. no protection.

**Outcome:** Cold-weather mortality: hypothermia deaths (ICD-10 X31: exposure to excessive natural cold; T68: hypothermia), and all-cause excess winter mortality. Data: CDC WONDER Underlying Cause of Death (county-year-month, publicly accessible), NOAA temperature data.

**Identification:** DiD exploiting state-level variation in disconnection protections interacted with cold weather shocks. The treatment effect should manifest during extreme cold events: states with moratoriums should see fewer hypothermia deaths during cold snaps. Supplemented with within-state variation from moratorium expansions/reforms over time.

**Why it's novel:** The COVID-era research (NBER WP 28394, Jowers et al. 2021) studied COVID moratoriums' effect on COVID mortality, not cold-weather-specific moratoriums on cold-weather mortality. The direct thermal protection channel — keeping heat on during freezing weather saves lives — has never been causally estimated in the economics literature.

**Feasibility check:** CDC WONDER publicly accessible. NOAA temperature data available. 32+ states with protections vs. 18 without. Concern: adoption timing is old (most moratoriums enacted 1970s-1990s), making pre-treatment period identification challenging. Can use moratorium REFORMS (expansions, temperature threshold changes) as treatment variation.

---

## Idea 5: State Drought Emergency Declarations and Agricultural Employment Adjustment

**Policy:** State drought emergency declarations and associated mandatory water use restrictions. Western states have formal drought contingency triggers that automatically restrict agricultural water allocation when drought monitors reach specified thresholds. States adopted these frameworks at different times (California 2014-2015, Texas 2013, Colorado 2013, others later).

**Outcome:** Agricultural employment and wages in drought-affected counties. Data: QCEW (Quarterly Census of Employment and Wages, BLS — county-level ag employment), USDA NASS crop production data, US Drought Monitor (weekly drought intensity by county).

**Identification:** DiD comparing agricultural labor market outcomes during drought periods in states with vs. without formal drought emergency frameworks. The treatment is the policy framework that triggers mandatory restrictions — not the drought itself (which is exogenous to the policy). States with formal triggers reduce water allocation more sharply during droughts, potentially displacing agricultural workers.

**Why it's novel:** Drought economics literature focuses on crop losses and water pricing (Deschênes and Greenstone 2007; Fisher et al. 2012) but not on the labor market adjustment channel. How agricultural workers are displaced by policy-mandated water restrictions — and whether they find alternative employment — is understudied.

**Feasibility check:** BLS QCEW accessible via API. US Drought Monitor data publicly available (weekly GIS shapefiles). Concern: only ~15 western states have formal drought frameworks. May need to expand to include drought declarations (which all states can make) as treatment. Pre-treatment periods available from 2000+.
