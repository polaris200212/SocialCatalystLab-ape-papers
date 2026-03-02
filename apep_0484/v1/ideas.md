# Research Ideas

## Idea 1: Flood Re and the Capitalization of Climate Risk Insurance — A Triple-Difference Design

**Policy:** The UK's Flood Re reinsurance scheme launched on 4 April 2016, capping flood insurance premiums for residential properties built before 1 January 2009 in flood-risk areas. Properties built after 2009 are explicitly excluded to avoid incentivizing new construction in flood zones. This creates a sharp eligibility cutoff by construction date within the same flood zone.

**Outcome:** HM Land Registry Price Paid Data (24M+ transactions, 1995–present, postcode-level). Secondary outcomes: transaction volumes (market liquidity), new construction in flood zones (moral hazard proxy via new-build flag).

**Identification:** Triple-difference (DDD):
- Dimension 1: Flood zone vs. non-flood zone (EA Open Flood Risk by Postcode, 4-band classification)
- Dimension 2: Pre- vs. post-April 2016 (Flood Re launch)
- Dimension 3: Pre-2009 construction (eligible) vs. post-2009 construction (ineligible) — identified via Land Registry New Build flag + transaction date

The DDD nets out: (a) nationwide housing trends (time FE), (b) flood-zone-specific trends unrelated to insurance (e.g., climate risk perception), (c) construction-vintage-specific trends. The post-2009 properties in flood zones face identical flood risk but receive NO insurance subsidy — a clean within-flood-zone control group.

**Why it's novel:** Garbarino, Guin & Lee (2024, J. Risk & Insurance) estimated the DiD effect of Flood Re on flood-zone prices but did NOT exploit the pre-2009/post-2009 eligibility cutoff. Their design cannot distinguish Flood Re effects from contemporaneous changes in climate risk perception or flood defense investment. Our DDD is strictly more credible. Additionally, we examine moral hazard in new construction and distributional effects across Council Tax bands — neither studied causally.

**Feasibility check:** Confirmed: (1) Land Registry PPD downloadable as bulk CSV with New Build flag + postcode, (2) EA Open Flood Risk by Postcode downloadable as CSV with postcode-level flood risk classification, (3) direct postcode merge between datasets, (4) 10-year post-period (2016–2026), (5) pre-period from 1995 gives 21 years of baseline data, (6) estimated 50,000–100,000 post-2009 properties in flood zones from continued development despite restrictions. Not previously studied in APEP.


## Idea 2: Welfare Federalism and the Race to the Bottom — Council Tax Support Localization

**Policy:** In April 2013, the UK government abolished the national Council Tax Benefit and devolved responsibility to ~300 Local Authorities in England to design their own Council Tax Support (CTS) schemes, with a ~10% funding cut. LAs made heterogeneous choices: some absorbed the cut, others passed it to working-age claimants (requiring 8%–30% minimum contributions). This created sharp cross-LA variation in effective benefit generosity overnight.

**Outcome:** Land Registry PPD (property prices at postcode level), NOMIS (employment, claimant counts by LA), Police API (crime by LSOA).

**Identification:** Continuous DiD using LA-level CTS generosity (minimum contribution rate) as treatment intensity × pre/post April 2013. The generosity choices were driven by LA fiscal position and political composition — instrument with prior grant dependence (exogenous central government formula). Callaway & Sant'Anna with continuous treatment or grouped by terciles of minimum contribution rate.

**Why it's novel:** IFS documented the policy variation (Adam & Browne 2014, Ogier & Phillips 2019) but no causal study exists using modern DiD methods with housing market or crime outcomes. The welfare federalism question (does localization create a race to the bottom?) is theoretically rich with deep roots in public economics.

**Feasibility check:** Confirmed: (1) New Policy Institute/Joseph Rowntree Foundation published LA-level CTS scheme parameters for 2013–2019, (2) NOMIS provides claimant count data at LA-month level, (3) 300+ LAs provide well-powered DiD, (4) pre-period from 2008 gives 5 years baseline, (5) 10+ years post-period. Concern: need to verify downloadable CTS scheme data — may require scraping from PDF reports.


## Idea 3: Planning Deregulation and the Quality-Quantity Tradeoff — Permitted Development Rights and Article 4 Directions

**Policy:** In May 2013, England introduced Permitted Development Rights (PDR) allowing office-to-residential conversion without full planning permission (Class J/O, later Class MA from August 2021). Between 2014–2022, approximately 30–50 Local Authorities adopted Article 4 Directions to re-impose planning controls in their areas, at staggered dates.

**Outcome:** MHCLG PDR Live Tables (prior approval applications by LA-quarter from 2013), Land Registry PPD (property prices), EPC register (dwelling quality: floor area, energy rating).

**Identification:** Staggered DiD comparing LAs that adopted Article 4 Directions (blocking PDR) vs. those that did not. Article 4 adoption is staggered but concentrated (many in 2021–2022). Alternative design: the 2013 PDR introduction itself, comparing initially exempted LAs (control) vs. non-exempted LAs (treated).

**Why it's novel:** No causal study exists on PDR or Article 4 effects. The entire literature is descriptive (Ferm et al. 2021, Urban Studies; Clifford et al. 2020, MHCLG report). This would be the first DiD estimate of planning deregulation's effect on housing supply and quality.

**Feasibility check:** Partially confirmed: (1) MHCLG PDR Live Tables downloadable, (2) planning.data.gov.uk has 2,449 Article 4 records from 71 LAs, (3) need to compile Article 4 adoption dates from LA websites for remaining LAs — moderate manual effort. Risk: Wave 3 timing bunches in August 2022, limiting staggered variation.


## Idea 4: The Austerity Elasticity of Crime — Police Funding Cuts and Public Safety

**Policy:** UK police forces experienced ~20% real cuts in central government grants between 2010–2018. The cut intensity varied by force: forces more dependent on Home Office grants (vs. council tax precept) faced proportionally larger budget reductions. This gives continuous variation across 43 police forces in England and Wales.

**Outcome:** Police API bulk downloads (LSOA-month crime from December 2010), aggregated to force-month panels.

**Identification:** Continuous DiD using pre-reform (2009) grant dependency share as treatment intensity × post-2010 austerity period. Forces with high grant dependence are more deprived, but the DiD identifies the effect of the differential *change* in funding, not the level. Pre-trend test: 2010–2012 pre-period before major cuts bite. Alternative: event study around annual grant allocation announcements.

**Why it's novel:** Mello (2019, AER) estimated the police-crime elasticity for the US using COPS grants. No equivalent UK study exists with modern causal methods. UK police funding is set centrally, making the variation more plausibly exogenous than US settings where local politics drive funding.

**Feasibility check:** Confirmed: (1) Home Office publishes annual police grant allocations by force, (2) Police API provides crime from Dec 2010, (3) 43 forces provide adequate clusters for wild cluster bootstrap. Concern: only 43 clusters is thinner than ideal for Callaway-Sant'Anna; may need aggregated force-level analysis with WCB inference.


## Idea 5: Clean Air, Rich Air? ULEZ Expansions and Residential Sorting in London

**Policy:** London's Ultra Low Emission Zone (ULEZ) expanded in three stages: original central London (April 2019), inner London expansion (October 2021), and outer London expansion (August 2023). The £12.50/day charge on non-compliant vehicles creates sharp geographic boundaries that shift with each expansion.

**Outcome:** Land Registry PPD (property prices), NOMIS (neighbourhood demographics), Police API (crime as neighbourhood quality proxy).

**Identification:** Spatial DiD around ULEZ boundary: compare properties just inside vs. just outside the zone boundary, before and after each expansion. Three staggered expansions provide internal replication. Placebo boundaries using earlier, non-active zones.

**Why it's novel:** Existing ULEZ literature focuses on air quality and vehicle compliance. The residential sorting question (does ULEZ gentrify neighbourhoods by pricing out older-car, lower-income residents?) is unstudied and has major equity implications for environmental policy design globally.

**Feasibility check:** Partially confirmed: (1) ULEZ boundary shapefiles from TfL, (2) Land Registry PPD for prices, (3) need to geocode postcodes and calculate distance to boundary. Concern: outer London expansion (Aug 2023) gives only 2.5 years of post-period — may be underpowered. Original zone (April 2019) gives 7 years but is small geography.
