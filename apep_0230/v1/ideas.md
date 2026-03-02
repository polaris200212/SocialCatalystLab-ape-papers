# Research Ideas

## Idea 1: Neighbourhood Planning and House Prices — Does Community Control Over Land Use Raise Property Values?

**Policy:** England's Localism Act 2011 empowered parish councils and neighbourhood forums to create legally binding Neighbourhood Development Plans (NDPs). These plans give communities direct democratic control over local land use — allocating housing sites, setting design standards, and restricting development types. Once approved by referendum, plans become part of the statutory development plan, carrying legal weight in planning decisions. Between 2013 and 2024, 1,197 neighbourhood plans were formally adopted ("made") in a heavily staggered fashion across 177 local authorities.

**Outcome:** HM Land Registry Price Paid Data — every residential property transaction in England and Wales since 1995, with price, date, postcode, property type, new-build flag. Transaction-level data mapped to parish-level annual panels via ONS National Statistics Postcode Lookup.

**Identification:** Staggered difference-in-differences (Callaway & Sant'Anna 2021) exploiting the variation in when neighbourhood plans were adopted. Treatment units are parishes that adopted plans; control units are not-yet-treated and never-treated parishes. Event study validates parallel pre-trends across 8+ pre-treatment years (Land Registry data from 2008; treatment starts 2013). Robustness via HonestDiD sensitivity analysis and randomization inference.

**Why it's novel:** Despite a large literature on UK planning constraints and house prices (Hilber & Vermeulen 2016), there is NO rigorous causal study exploiting the staggered adoption of neighbourhood plans as a natural experiment. The existing literature uses cross-sectional variation in regulatory restrictiveness. The government-commissioned University of Reading study (2020) was descriptive. This paper would be the first to use modern staggered DiD methods on the NP rollout.

**Feasibility check:**
- Variation: 1,197 treated parishes across 2013-2024, with peak adoption 2016-2019 (200+ plans/year). Easily exceeds 20 treated clusters. ✓
- Data access: MHCLG/Locality publishes Excel file with all 3,067 designated areas, referendum dates, turnout %, yes %. CONFIRMED DOWNLOADED AND VERIFIED. Land Registry Price Paid Data freely downloadable from GOV.UK S3 bucket (~900K transactions/year). CONFIRMED ACCESSIBLE. ✓
- Novelty: No DiD study on NP adoption and house prices exists. Government commissioned only descriptive research. Google Scholar reveals no causal study. ✓
- Sample size: ~1,200 treated parishes × 15 years × ~90 transactions/parish/year = millions of transactions. ✓
- Pre-periods: Land Registry data from 1995 (18+ years before first NP). At least 8 years from 2008 baseline. ✓
- Mechanism: NPs could raise prices through supply restriction (fewer permissions), amenity preservation, or development certainty. Direction ambiguous ex ante, making null results publishable. ✓


## Idea 2: Universal Credit Rollout and the Self-Employment Trap — Does the Minimum Income Floor Reduce Entrepreneurship?

**Policy:** Universal Credit (UC) replaced six legacy benefits and was rolled out across ~643 Jobcentre Plus offices in a staggered fashion from 2013 to 2018. UC introduced the Minimum Income Floor (MIF), which assumes self-employed claimants earn at least minimum wage × 35 hours — reducing UC payments for those earning less. This discourages marginal/survival self-employment.

**Outcome:** ONS Nomis API — self-employment rates, claimant counts, employment, and economic inactivity by local authority (monthly, from 1983). CONFIRMED WORKING: API returns data by LA with 96+ rows per query.

**Identification:** Staggered DiD exploiting the variation in when each JC+ office area transitioned to UC full service. DWP published exact rollout dates (2015-2018) in an official schedule. CS-DiD estimator with not-yet-treated controls.

**Why it's novel:** While UC's effects on employment and housing have been studied (Wickham et al. on mental health; Reeves & Loopstra on food insecurity), the specific effect of the MIF on self-employment rates has received limited rigorous causal attention. The MIF was also suspended during COVID (March 2020-July 2021), providing a second shock for robustness.

**Feasibility check:**
- Variation: ~643 JC+ offices rolled out over 5+ years. Easily exceeds 20 clusters. ✓
- Data access: DWP rollout schedule published as PDF. Nomis API confirmed working. ✓
- Novelty: MIF-specific self-employment effect is understudied. ✓
- Sample size: 300+ LAs × 60+ months = 18,000+ observations. ✓
- Pre-periods: Nomis data from 1983. 30+ years pre-treatment. ✓
- CONCERN: Isolating MIF effect from UC's other changes (conditionality, digital-by-default, payment frequency) is challenging. ✗ (partially)


## Idea 3: Business Improvement Districts and Local Economic Vitality — Does Collective Action Save the High Street?

**Policy:** Over 300 Business Improvement Districts (BIDs) have been established across the UK since 2004, each through a local ballot of businesses. BIDs levy additional taxes on businesses within a defined area to fund improvements (cleanliness, safety, marketing, events). Staggered adoption with clear ballot dates.

**Outcome:** Land Registry Price Paid Data (commercial property values via LSOA matching), UK Police Crime Data API (anti-social behaviour, theft), ONS Business Demography (business births/deaths by LA).

**Identification:** Staggered DiD comparing BID areas to comparable non-BID areas before and after establishment. Event study with pre-trends test.

**Why it's novel:** Most BID research is descriptive or case-study based. There is no rigorous causal study using modern staggered DiD methods on UK BIDs. The question — can collective private action substitute for declining public services? — is of first-order policy importance.

**Feasibility check:**
- Variation: 300+ BIDs over 20 years. Exceeds 20 clusters. ✓
- Data access: Police Crime API confirmed working. Land Registry confirmed. ✓
- Novelty: No causal DiD study on UK BIDs. ✓
- CONCERN: Assembling BID establishment dates and boundaries may require web scraping of individual council websites. ✗ (data assembly risk)
- CONCERN: BID adoption is highly endogenous to local economic conditions. ✗ (selection concern)


## Idea 4: Academy School Conversions and Teacher Labour Markets

**Policy:** Since 2010, over 7,000 English schools have converted from local authority control to academy status, gaining autonomy over curriculum, pay, and staffing. Conversions were heavily staggered, with exact dates in DfE's GIAS database.

**Outcome:** DfE school performance tables (KS2/GCSE results), School Workforce Census (teacher retention, pay).

**Identification:** Staggered DiD comparing converting schools to not-yet-converted schools.

**Why it's novel:** While academy effects on student attainment have been studied (Eyles, Machin & Silva 2018), teacher labour market effects are understudied. Academy pay flexibility could attract better teachers but also increase turnover.

**Feasibility check:**
- Variation: 7,000+ conversions over 14 years. Excellent. ✓
- Data access: GIAS has all conversion dates. School performance data is public. ✓
- Novelty: Teacher labour market angle is relatively novel. Moderate. ✓
- CONCERN: Academy conversion is endogenous (schools self-select or are forced). ✗
- CONCERN: School Workforce Census detailed data requires DfE data access agreement. ✗ (access risk)
- CONCERN: Existing literature is substantial, reducing novelty. ✗
