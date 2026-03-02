# Research Ideas — India Economic Development

## Idea 1: Does Piped Water Build Human Capital? Evidence from India's Jal Jeevan Mission

**Policy:** Jal Jeevan Mission (JJM), launched August 2019. The world's largest piped water program — Rs. 3.6 lakh crore ($43B) to provide functional household tap connections (FHTC) to all ~19 crore rural households by 2024. District-level rollout varied dramatically: Goa and D&NH achieved "Har Ghar Jal" (100% coverage) by August 2022, while large states like UP and Bihar remain below 80% in 2025. The staggered completion across 700+ districts over 5 years creates clean quasi-experimental variation.

**Outcome:** (1) UDISE+ school enrollment and retention data (annual, district-level, 2015–2024), focusing on female enrollment in primary/upper-primary/secondary schools and dropout rates; (2) SHRUG VIIRS nightlights (annual, district-level, 2012–2021) as proxy for economic activity; (3) NFHS-4 (2015–16) vs NFHS-5 (2019–21) district factsheets for child health outcomes (diarrhea prevalence, stunting, women's time spent fetching water).

**Identification:** District-level staggered DiD. Treatment: cumulative share of households with tap connections (continuous intensity) from JJM dashboard (ejalshakti.gov.in), available at district × year. Pre-treatment: 2015–2019 (5 years of UDISE+ data before JJM launch). Post-treatment: 2020–2024. Instrument for endogeneity of rollout speed: baseline (2011 Census) water infrastructure deficit interacted with state-level JJM budget allocation. Callaway & Sant'Anna (2021) heterogeneity-robust estimator for staggered adoption. Event study to test for parallel pre-trends and dynamic treatment effects.

**Why it's novel:** Despite being one of the world's largest infrastructure programs ($43B+), JJM has NO rigorous causal evaluation using quasi-experimental methods. Existing studies are descriptive (PLOS One 2024 — before/after cross-sections), WHO projections (simulation-based), and state case studies. No published paper uses the staggered district-level rollout for DiD identification. The education channel (piped water → reduced water-fetching burden on girls → higher school attendance) connects to a large water-education nexus literature (Devoto et al. 2012, AER) but has never been tested at this scale.

**Feasibility check:**
- Variation: 700+ districts, rollout spans 2019–2024, massive cross-district heterogeneity. ✓
- Data: JJM dashboard has district × year coverage data (confirmed accessible). UDISE+ downloadable. NFHS-4/5 factsheets available as CSV from data.gov.in and GitHub. SHRUG VIIRS at district level (1.6MB, downloaded). ✓
- Novelty: Zero DiD papers on JJM. Massive literature gap for a $43B program. ✓
- Sample size: ~640 districts × 10 years = ~6,400 district-year observations. ✓
- COVID confounder: School closures 2020–21 must be addressed (focus on 2022–2024 for clean post-treatment, or include COVID controls). ⚠️

---

## Idea 2: Did Guaranteed Employment Crowd Out or Crowd In Rural Enterprise? Evidence from MGNREGA's Phased Rollout

**Policy:** Mahatma Gandhi National Rural Employment Guarantee Act (MGNREGA), rolled out in three phases: Phase I (February 2006, 200 most backward districts), Phase II (April 2007, +130 districts), Phase III (April 2008, all remaining ~310 districts). District assignment was based on a composite "backwardness index" using poverty, human development, and Naxalite insurgency indicators.

**Outcome:** SHRUG Economic Census 2005 (pre-MGNREGA) and 2013 (7 years post for Phase I) at district level: number of non-agricultural establishments, employment by sector (manufacturing, services, construction, trade), female employment share in non-farm enterprises. Supplemented by SHRUG VIIRS/DMSP nightlights (annual, 2000–2013) at district level for continuous outcome.

**Identification:** Staggered DiD exploiting phase assignment timing. Phase I districts (treated Feb 2006) vs Phase III districts (treated Apr 2008), with Phase II as intermediate. Key: District assignment was rule-based (backwardness index), enabling regression-kink/discontinuity at phase boundaries. Callaway & Sant'Anna for staggered treatment. Pre-treatment outcomes (EC 1998, EC 2005, Census 2001, nightlights 2000–2005) for parallel trends testing and covariate balance. Cluster at state level.

**Why it's novel:** MGNREGA's labor market effects (wages, agricultural employment) are well-studied (Imbert & Papp 2015 AER; Muralidharan et al. 2023 Econometrica). But the ENTERPRISE CREATION channel is largely unexamined. Two competing mechanisms: (a) Crowding out — higher rural wages make enterprises less profitable, reducing firm entry; (b) Crowding in — higher incomes create demand for services and goods, pulling enterprises into treated districts. The Economic Census (available in SHRUG) provides direct measurement of firm counts, employment composition, and sector structure that has not been exploited for this question. This paper tests whether a guaranteed employment program accelerated or retarded India's structural transformation.

**Feasibility check:**
- Variation: 640+ districts across 3 phases over 2 years. ✓
- Data: SHRUG EC 2005 and EC 2013 downloaded (zip verified). SHRUG nightlights downloaded. Census 2001/2011 downloaded. All at district level. ✓
- Novelty: Enterprise creation channel is unstudied with Economic Census data. ✓
- Sample size: ~640 districts × 2 EC rounds + annual nightlights. ✓
- Phase assignment data: Need district-level phase lists (available from government gazette/data.gov.in). ⚠️

---

## Idea 3: Portable Rations, Mobile Workers: One Nation One Ration Card and Interstate Migration in India

**Policy:** One Nation One Ration Card (ONORC), enabling interstate portability of PDS (Public Distribution System) ration entitlements. Staggered state adoption: 4 pilot states (August 2019) → 12 more (January 2020) → most remaining states during 2020–2021 → Assam as 36th state/UT (June 2022). Before ONORC, migrant workers lost access to subsidized food when they moved across state borders — a major friction for 140+ million internal migrants.

**Outcome:** State × quarter panel combining: (1) PLFS aggregate state-level employment and migration statistics from published annual reports (2017–2024); (2) GST revenue by state (monthly, from GST Council press releases, as proxy for formal economic activity); (3) RBI DBIE state-level credit and deposits (quarterly); (4) ONORC portability transaction counts from government dashboard (direct take-up measure).

**Identification:** State-level staggered DiD. Treatment = state adoption of ONORC system. 36 states/UTs adopting over a 3-year window (2019–2022). Pre-treatment: PLFS 2017–2019 (2–3 years). Callaway & Sant'Anna estimator. Event study for dynamic effects. Key test: states with higher baseline migrant populations (from Census 2011) should show larger effects (heterogeneous treatment effects by migration intensity).

**Why it's novel:** Only one published paper studies ONORC's effects: Tumbe & Jha (2024, Indian Journal of Labour Economics) found "limited interstate traction" — fewer than 0.5 million monthly interstate transactions. But their analysis is descriptive. No paper uses the staggered state adoption for causal DiD. The question of whether PDS portability actually facilitates migration — or whether institutional barriers (documentation, biometric errors, awareness) limit take-up — is unresolved. This paper provides the first causal estimate.

**Feasibility check:**
- Variation: 36 states/UTs staggered over 3 years. Meets 20+ treated units threshold. ✓
- Data: PLFS published reports downloadable. GST Council press releases public. RBI DBIE confirmed accessible (smoke test PASS). ✓
- Novelty: No causal evaluation of ONORC exists. ✓
- Sample size: 36 states × 28 quarters (2017Q3–2024Q2) = ~1,008 state-quarter observations. ✓
- State adoption dates: Need to compile from PIB/government press releases. ⚠️

---

## Idea 4: MGNREGA and the Feminization of India's Rural Non-Farm Economy

**Policy:** Same MGNREGA phased rollout as Idea 2 (Phase I: 2006, Phase II: 2007, Phase III: 2008). But focused specifically on the gender dimension: MGNREGA mandated that at least one-third of person-days be allocated to women, and in practice, female participation rates exceed 50% in most states. This made MGNREGA the single largest employer of women in rural India.

**Outcome:** SHRUG Census 2001 and 2011 at district level: female main workers by type (cultivator, agricultural laborer, household industry, other workers), female literacy, female non-worker share. SHRUG Economic Census 2005 and 2013: female employment in non-farm establishments by sector. SHRUG nightlights for annual dynamics.

**Identification:** Same staggered DiD as Idea 2 but with female-specific outcomes. Triple-difference design: Phase I vs Phase III × Female vs Male × Pre vs Post. The male outcomes serve as within-district control for common shocks. Tests whether MGNREGA differentially shifted women OUT of agricultural labor and INTO non-farm employment.

**Why it's novel:** Prior MGNREGA-gender studies (Azam 2012, IZA; Desai et al. 2018) show MGNREGA increased female LFPR and wages. But NO study examines the STRUCTURAL COMPOSITION shift: Did MGNREGA move women from agricultural labor to non-farm employment? The Census worker classification (main cultivator / agricultural laborer / household industry / other worker) enables direct measurement of sectoral transitions. India's female LFPR puzzle (declining despite growth) may partly reflect MGNREGA-induced sectoral shifts that appear as LFPR changes in one survey but composition changes in another.

**Feasibility check:**
- Variation: Same as Idea 2 (640+ districts, 3 phases). ✓
- Data: SHRUG Census (gender-disaggregated worker data) downloaded. EC with female employment. ✓
- Novelty: Sectoral composition of female employment post-MGNREGA is unstudied. ✓
- Sample size: Same as Idea 2. ✓
- Connection to U-shaped FLFPR literature adds theoretical weight. ✓

---

## Idea 5: Piped Water and Child Survival: Jal Jeevan Mission's Health Dividend

**Policy:** Same JJM as Idea 1, but focused exclusively on child health outcomes. The WHO estimated JJM could avert ~400,000 diarrheal deaths if safely managed water reaches all households. India accounts for 25% of global under-5 diarrheal deaths.

**Outcome:** NFHS-4 (2015–16) and NFHS-5 (2019–21) district-level factsheet indicators: (1) prevalence of diarrhea in children under 5 in the two weeks preceding the survey; (2) children under 5 who are stunted (height-for-age); (3) children under 5 who are wasted (weight-for-height); (4) proportion of households using piped water into dwelling. Cross-sectional intensity design using district-level JJM coverage between survey rounds.

**Identification:** Cross-district intensity DiD using two NFHS waves. Treatment intensity: change in household tap water coverage between NFHS-4 and NFHS-5 at district level (directly measured by both surveys). Instrument: pre-JJM (2011 Census Village Directory) tap water infrastructure deficit × state-level JJM budget allocation as IV for JJM-induced water access. Controls: baseline district characteristics from Census 2011 (population density, literacy, SC/ST share, urbanization). The key assumption: districts where JJM expanded piped water faster should show larger health improvements conditional on baseline.

**Why it's novel:** The WHO study was a simulation. The PLOS One study used before/after without causal identification. No paper uses the NFHS-4 → NFHS-5 transition combined with district-level JJM rollout as treatment variation to estimate causal health effects. The district-representative sampling of NFHS-4 and NFHS-5 (~640 districts each) provides sufficient power for district-level DiD. The diarrhea-water connection is well-established biologically; the question is whether JJM's infrastructure actually delivers the expected health gains at population scale.

**Feasibility check:**
- Variation: ~640 districts, massive cross-district variation in JJM coverage. ✓
- Data: NFHS-4 and NFHS-5 district factsheets available as CSV (GitHub: SaiSiddhardhaKalla/NFHS, data.gov.in). JJM dashboard for coverage data. ✓
- Novelty: No causal health evaluation of JJM exists. ✓
- Sample size: ~640 districts × 2 survey waves = ~1,280 observations. ✓
- Timing: NFHS-5 fieldwork (2019–21) overlaps with early JJM. Districts surveyed later in Phase 2 (2020–21) had more JJM exposure but also COVID contamination. ⚠️
