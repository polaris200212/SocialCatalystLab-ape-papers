# Research Ideas — MGNREGA and Rural Employment (India)

## Idea 1: Safety Nets and Risk-Taking — How India's Employment Guarantee Transformed Crop Portfolios

**Policy:** MGNREGA (Mahatma Gandhi National Rural Employment Guarantee Act). Staggered rollout: Phase I (Feb 2006, 200 poorest districts), Phase II (Apr 2007, +130 districts), Phase III (Apr 2008, all ~640 rural districts). Assignment based on district backwardness index.

**Outcome:** Crop diversification measured using ICRISAT District-Level Database (DLD). Primary outcomes: (1) Crop diversification index (1 minus Herfindahl of crop area shares), (2) Share of non-cereal/commercial crops (vegetables, spices, cotton, sugarcane) in total cropped area, (3) Average crop yield per hectare. Annual district-level data, ~300+ districts, 1966–2017.

**Identification:** Callaway-Sant'Anna staggered DiD exploiting three MGNREGA phase cohorts. ~200 Phase I districts treated in 2006, ~130 Phase II in 2007, remaining ~310 in 2008. Pre-treatment: 2000–2005 (6+ years). Post-treatment: 2006–2017 (up to 12 years). District and year fixed effects. Clustering at state level.

**Why it's novel:** Existing MGNREGA literature focuses on wages, employment, and structural transformation. No published paper rigorously estimates the effect of employment guarantee on crop portfolio risk-taking. This parallels Cai, de Janvry, and Sadoulet (2016, AER), who showed formal crop insurance induced Chinese farmers to shift toward riskier, higher-return crops. MGNREGA functions as *implicit* crop insurance by guaranteeing off-farm income during agricultural downturns. If MGNREGA enables similar risk-taking, this reveals a previously undocumented welfare channel. No top-5 journal paper on MGNREGA × crop diversification exists.

**Feasibility check:**
- Variation: 3-phase staggered rollout → clean DiD (Phase I: 200 districts, well above 20 threshold)
- Data: ICRISAT DLD confirmed accessible (HTTP 200). SHRUG nightlights available locally.
- Novelty: Extensive APEP check (22 India papers) — none on crop diversification. Literature review: ~5–10 papers, none in top-5 journals. Under-studied.
- Sample size: ~300 districts × 17 years = ~5,100 district-year observations.
- Pre-periods: 6 years (2000–2005) for Phase I. Ample for parallel trends testing.

---

## Idea 2: MGNREGA as Climate Insurance — Does Employment Guarantee Buffer Drought Shocks?

**Policy:** Same MGNREGA staggered rollout as Idea 1.

**Outcome:** (1) Nightlights intensity at district level (SHRUG DMSP 2000–2013, VIIRS 2012–2021) as proxy for economic resilience to drought. (2) Crop yields from ICRISAT DLD. (3) MGNREGA take-up during drought years (MGNREGA MIS).

**Identification:** Triple-difference: District × Year × Drought Shock. Drought measured as standardized precipitation deviation (rainfall below 1 SD of long-run district mean, using ICRISAT rainfall data). Estimate whether MGNREGA dampened the negative effect of drought on economic activity. Pre-MGNREGA drought response vs. post-MGNREGA drought response, exploiting phase timing.

**Why it's novel:** The MGNREGA-as-insurance mechanism is known theoretically but rigorous evidence is thin. Johnson (2009, SSRN) is the foundational piece but remains a working paper. No top-5 journal publication on MGNREGA drought resilience exists. Climate adaptation is high-profile; demonstrating that employment guarantees serve as climate insurance would be policy-relevant globally. Existing work finds a "discouraged worker effect" during droughts (Basu 2013, World Development), making the question empirically live. Zimmermann (2020, JDE) studied MGNREGA as risk-coping but not the agricultural productivity channel.

**Feasibility check:**
- Variation: MGNREGA phases × drought incidence → triple-diff
- Data: ICRISAT has district-level rainfall (annual). SHRUG has nightlights. Both confirmed accessible.
- Novelty: ~15–25 papers, none in top-5 journals. Moderately studied.
- Sample size: ~300+ districts × 20 years = ~6,000+ observations.
- Pre-periods: 6+ years of pre-MGNREGA rainfall variation.
- Concern: Triple-diff adds complexity; need sufficient drought variation across districts.

---

## Idea 3: MGNREGA and Non-Farm Enterprise Dynamics — The Demand vs. Cost Channel

**Policy:** Same MGNREGA staggered rollout.

**Outcome:** Village-level non-farm enterprise counts and employment from SHRUG Economic Census. EC 2005 (pre-MGNREGA) vs EC 2013 (post-full-rollout). Secondary: Census 2001 vs 2011 changes in worker composition (agricultural labor → non-ag workers).

**Identification:** Cross-sectional DiD at village level within MGNREGA phase-assigned districts. Phase I districts: EC 2005 (pre) → EC 2013 (post), compared to Phase III districts (treated only 2 years later, serving as partial control). Village and district fixed effects.

**Why it's novel:** APEP has 4 papers on MGNREGA + structural transformation, but all use nightlights as primary outcome. None examine firm-level dynamics using Economic Census microdata. The demand vs. cost channel is theoretically ambiguous: MGNREGA raises unskilled wages (cost → fewer firms) but injects cash (demand → more firms). Decomposing these channels using firm-level data is genuinely new.

**Feasibility check:**
- Variation: Phase assignment creates treatment timing variation at district level.
- Data: SHRUG Economic Census (ec05, ec13) available locally — confirmed.
- Novelty: Not covered by existing APEP papers (which use nightlights, not EC data).
- Sample size: ~640K villages (massive cross-section).
- Pre-periods: Only 1 pre-period (EC 2005). This is a significant limitation for parallel trends.
- Concern: Only 2 time points (2005, 2013) — cannot do event study with multiple pre-periods at village level. Would need to supplement with district-level nightlights panel for dynamic effects.

---

## Idea 4: MGNREGA and School Enrollment — Income Effects vs. Child Labor Substitution

**Policy:** Same MGNREGA staggered rollout.

**Outcome:** District-level school enrollment, dropout rates, pupil-teacher ratios from UDISE+/DISE (annual, 2005–present). ~1.5M schools aggregated to district level.

**Identification:** Staggered DiD across MGNREGA phases. DISE data starts 2005, providing pre-treatment data for Phase I districts. Annual data enables proper event study.

**Why it's novel:** Adukia (UChicago, working paper) and Sekhri & Li (2020, WBER) have studied this — but with conflicting results (Adukia: null; Sekhri-Li: more child labor, lower enrollment). The question is empirically live. Modern staggered DiD methods (CS-DiD, Sun-Abraham) were not available when these papers were written. A paper using state-of-the-art methods to resolve this conflict would be valuable.

**Feasibility check:**
- Variation: MGNREGA phases, 200+ treated Phase I districts.
- Data: UDISE+ confirmed accessible (HTTP 200). But bulk download requires scraping — feasibility uncertain.
- Novelty: Well-studied (~15–20 papers), best publication is WBER. Active disagreement increases value of resolution.
- Sample size: Large (640+ districts × 10+ years).
- Concern: UDISE+ bulk data extraction may be difficult. Competing literature is more developed here.

---

## Idea 5: MGNREGA, Mandatory Bank Accounts, and Rural Financial Deepening

**Policy:** 2008 mandate requiring all MGNREGA wages to be paid through bank accounts (previously cash-in-hand). This created millions of first-time bank account holders in rural India, years before Jan Dhan Yojana (2014).

**Outcome:** District-level banking indicators from RBI BSR: bank branches, credit-deposit ratio, savings accounts. SHRUG bank branch data at village level.

**Identification:** Intensity design: districts with higher MGNREGA participation (person-days per capita) received a larger "dose" of forced financial inclusion. Use pre-2008 MGNREGA intensity × post-2008 interaction. Alternatively, exploit Phase I districts' earlier exposure to the bank payment mandate.

**Why it's novel:** The 2008 bank payment mandate is a clean policy change that forced financial inclusion 6 years before Jan Dhan. Existing literature (~10–15 papers) focuses on debt reduction, not broader financial deepening. No top-5 journal paper exists.

**Feasibility check:**
- Variation: MGNREGA phases × bank mandate timing (but mandate was national in 2008).
- Data: RBI BSR confirmed accessible but requires digitization of PDF tables.
- Novelty: Moderately studied, bank account sub-angle is thin.
- Sample size: ~600+ districts.
- Concern: Identification is weaker — the bank mandate was national (2008), not staggered. Must rely on intensity variation. RBI BSR data is in PDF format, requiring significant extraction effort.
