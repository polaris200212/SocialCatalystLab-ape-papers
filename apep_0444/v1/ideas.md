# Research Ideas

## Idea 1: Does Sanitation Drive Development? Satellite Evidence from India's Swachh Bharat Mission

**Policy:** Swachh Bharat Mission — Gramin (SBM-G), launched October 2, 2014. States declared Open Defecation Free (ODF) at staggered dates: Sikkim (May 2016), Himachal Pradesh (Oct 2016), Kerala (Nov 2016), Uttarakhand and Haryana (June 2017), Gujarat/Chhattisgarh/Arunachal Pradesh (by Jan 2018), ~15 more states by mid-2018, remaining by October 2, 2019. Roughly 4 cohorts over 3.5 years of stagger.

**Outcome:** VIIRS annual nightlights (2012–2023) at the village level from SHRUG, aggregated to district level (~640 districts). Nightlights proxy for economic activity (Henderson, Storeygard, Weil 2012). Supplemented by DMSP nightlights (1994–2013) for extended pre-treatment series. Census 2001/2011 PCA for baseline controls and heterogeneity.

**Identification:** Staggered Difference-in-Differences exploiting state-level ODF declaration dates as treatment timing. Districts within a state share a common treatment date. Callaway and Sant'Anna (2021) heterogeneity-robust estimator with never-yet-treated as comparison group. Event study plots to validate parallel pre-trends. ~640 districts in 35 states/UTs, with 4–6 pre-treatment years (VIIRS 2012–2015; extended with calibrated DMSP back to 2010) and up to 7 post-treatment years.

**Why it's novel:** The SBM literature focuses overwhelmingly on health outcomes (child mortality, stunting, diarrhea). Zero published papers examine the economic effects of ODF declarations using satellite nightlights. The question is policy-relevant: India invested ₹62,000+ crore (~$8B) in toilet construction. Did this investment generate measurable economic returns beyond health? The result is genuinely ambiguous — ODF declarations may reflect real behavior change (positive effect) or political window-dressing (null effect). Either finding is informative.

**Feasibility check:**
- Variation: Confirmed. State ODF dates staggered 2016–2019 across 35 states/UTs. Reconstructible from PIB press releases (confirmed: Sikkim May 2016, HP Oct 2016, Kerala Nov 2016, Uttarakhand/Haryana June 2017, 10 states by Jan 2018, all by Oct 2019).
- Data: Confirmed. VIIRS nightlights (2012–2023) and DMSP (1994–2013) at village level locally available in `data/india_shrug/`. Census PCA 1991/2001/2011 available. Geographic crosswalk (village → district → state) available. R data.table loads successfully tested.
- Novelty: Confirmed. No APEP papers on India. No published papers on SBM + nightlights/economic activity.
- Sample: 640 districts, ~596K villages, 35 states. Well-powered.
- DiD gate: ≥5 pre-periods (2010–2015 with DMSP+VIIRS) ✓, ≥20 treated states ✓.

**Mechanisms to test:**
1. Health → productivity (districts with higher baseline OD rates should show larger effects)
2. Construction spending multiplier (toilet investment as local fiscal stimulus)
3. Women's time use reallocation (reduced water-fetching/sanitation time → labor supply)
4. Heterogeneity: urban vs rural districts, baseline sanitation coverage, state political alignment

---

## Idea 2: MGNREGA and the Feminization of the Rural Workforce: Village-Level Evidence from India

**Policy:** Mahatma Gandhi National Rural Employment Guarantee Act (MGNREGA). Phase I: February 2006 (200 most backward districts). Phase II: April 2007 (+130 districts). Phase III: April 2008 (all remaining ~310 rural districts). Assignment based on Planning Commission backwardness index.

**Outcome:** Primary: Census 2001 → 2011 change in female worker composition (main workers, marginal workers, non-workers) at village level from SHRUG PCA data (~596K villages). Secondary: DMSP nightlights (2000–2013) for annual event study dynamics.

**Identification:** Staggered DiD exploiting Phase I/II/III rollout at district level. Compare Phase I districts (treated Feb 2006) vs Phase III districts (treated Apr 2008) — 2-year treatment stagger. Callaway-Sant'Anna estimator. Village-level analysis with district-level treatment. Pre-treatment: Census 1991/2001 + DMSP 2000–2005 (6 years). ~640 districts across 28+ states.

**Why it's novel:** MGNREGA is well-studied for wages and employment, but village-level analysis of female workforce composition using Census complete enumeration (~600K villages) is unprecedented. Women constitute ~55% of MGNREGA workers nationally. The question: did guaranteed employment catalyze a permanent shift in female labor force participation, or was the effect temporary/confined to MGNREGA work itself?

**Feasibility check:**
- Variation: Confirmed. Phase I/II/III dates well-documented in legislation and academic papers (Imbert & Papp 2015).
- Data: Confirmed. Census PCA with female worker variables (pc11_pca_main_work_f, pc11_pca_marg_work_f, pc11_pca_non_work_f) locally available. DMSP nightlights locally available.
- Novelty: Partial. MGNREGA is well-studied, but existing APEP paper on MGNREGA had fragile pre-trends and lost tournament matches. Village-level Census analysis with female focus is genuinely new.
- Sample: 596K villages, 640 districts. Massive statistical power.
- DiD gate: ≥5 pre-periods (DMSP 2000–2005) ✓, ≥20 treated states ✓.
- **Risk:** Only 2 Census periods (2001, 2011) for primary outcome — no pre-trend test possible with Census alone. Must rely on nightlights for event study validation.

---

## Idea 3: Does Ration Card Portability Unlock Labor Mobility? Evidence from India's One Nation One Ration Card

**Policy:** One Nation One Ration Card (ONORC), enabling inter-state portability of PDS ration entitlements. Launched August 9, 2019 (4 pilot states). Staggered expansion: 12 more states by January 2020, 4 more by June 2020, gradual expansion to 35 states/UTs by February 2022, Assam (36th) by June 2022. ~3 years of state-level stagger.

**Outcome:** VIIRS nightlights (2012–2023) at district level. Nightlights in migrant-receiving urban districts vs migrant-sending rural districts. Heterogeneity by baseline migration intensity (Census 2011 migration data).

**Identification:** Staggered DiD using state ONORC adoption dates. Treatment: state joins the ONORC system. CS-DiD with not-yet-treated comparison. 36 states/UTs, staggered over 3 years.

**Why it's novel:** ONORC is one of the world's largest portability reforms (800M+ PDS beneficiaries) and has almost no rigorous causal evaluation. Tumbe & Jha (2024) is descriptive only. The theoretical prediction is clear: removing food-security barriers to migration should increase inter-state labor mobility and economic integration.

**Feasibility check:**
- Variation: Confirmed. State adoption dates documented in press releases (Aug 2019: 4 states → June 2022: 36 states).
- Data: Confirmed for nightlights. Uncertain for migration outcomes — PLFS microdata requires MoSPI registration.
- Novelty: Confirmed. No rigorous DiD evaluation exists.
- Sample: 36 states, 640 districts.
- DiD gate: ≥5 pre-periods (VIIRS 2012–2018) ✓, ≥20 treated states ✓.
- **Risk:** COVID-19 confound. ONORC launched Aug 2019, national lockdown Mar 2020. Massive reverse migration during COVID makes it nearly impossible to separate ONORC effects from COVID effects on mobility. This is the primary feasibility concern.

---

## Idea 4: Piped Water and Rural Development: Early Evidence from India's Jal Jeevan Mission

**Policy:** Jal Jeevan Mission (JJM), launched August 2019, targeting 100% functional household tap connections (FHTC) in all rural households. District-level completion staggered: Goa first (2022), several districts in 2023, ongoing through 2028 (deadline extended). Dashboard tracks district-by-district coverage.

**Outcome:** VIIRS nightlights (2012–2023) at village/district level. UDISE+ school enrollment as secondary outcome.

**Identification:** Staggered DiD using district-level "Har Ghar Jal" (100% coverage) achievement dates. CS-DiD estimator. Districts achieving coverage earlier vs later.

**Why it's novel:** JJM is the world's largest piped water program and has no rigorous causal evaluation. Access to piped water should reduce women's time burden (water collection), improve child health, and potentially boost economic activity.

**Feasibility check:**
- Variation: Confirmed. District completion dates available from JJM dashboard (ejalshakti.gov.in).
- Data: Confirmed. Nightlights + UDISE+ available.
- Novelty: Confirmed. No rigorous DiD exists.
- Sample: 640+ districts.
- DiD gate: ≥5 pre-periods (VIIRS 2012–2018) ✓, ≥20 treated states ✓ (if enough districts have completed).
- **Risk:** Very short post-treatment periods. Few districts achieved 100% before 2023. Only 1–2 years of post-treatment VIIRS data for early completers. COVID confound (2020–2021). May be premature.
