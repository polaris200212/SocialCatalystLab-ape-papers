# Conditional Requirements

**Generated:** 2026-02-27T15:36:32.276118
**Status:** RESOLVED

---

## THESE CONDITIONS MUST BE ADDRESSED BEFORE PHASE 4 (EXECUTION)

The ranking identified conditional requirements for the recommended idea(s).
Before proceeding to data work, you MUST address each condition below.

For each condition:
1. **Validate** - Confirm the condition is satisfied (with evidence)
2. **Mitigate** - Explain how you'll handle it if not fully satisfied
3. **Document** - Update this file with your response

**DO NOT proceed to Phase 4 until all conditions are marked RESOLVED.**

---

## Downtown for Sale? Commercial Displacement Effects of France's Action Cœur de Ville Program

**Rank:** #1 | **Recommendation:** PURSUE

### Condition 1: downtown geolocation/definition rather than commune-only

**Status:** [x] RESOLVED

**Response:**

Three complementary strategies address this concern:

1. **Commune-as-center design (primary):** ACV specifically targets "villes moyennes" — the selected commune IS the city center of its agglomération. The displacement test compares the ACV commune (center) to neighboring non-ACV communes within the same département or EPCI (periphery). This commune-level center/periphery distinction is the cleanest and most replicable approach.

2. **Sectoral proxy for downtown activity:** Retail (NAF 47.xx), restaurants/cafés (NAF 56.xx), and personal services (NAF 96.xx) are heavily concentrated in city centers. By focusing on these "downtown-facing" sectors rather than all establishments, we isolate the portion of economic activity most likely to be affected by ACV, reducing dilution.

3. **Robustness with geocoded Sirene:** The Sirene establishment file includes the complete address (street name + number) for each establishment. While precise coordinates are not available in the open bulk download, I can use the BAN (Base Adresse Nationale) geocoder to convert addresses to lat/lon coordinates and define a "downtown" buffer (e.g., 500m radius from the city's main square / mairie). This is computationally intensive but provides a direct test.

**Evidence:** ACV targets 222 communes that function as "pôles de centralité" for surrounding territory (Legifrance instruction, March 2018). The ACV commune list (data.gouv.fr) contains INSEE codes that can be matched to the EPCI geography.

---

### Condition 2: transparent event-study pre-trend tests

**Status:** [x] RESOLVED

**Response:**

The design will include:
1. **Event-study specification** using Callaway-Sant'Anna (2021) with group-time ATT estimates. Pre-treatment coefficients (2012Q1–2017Q4 = 24 quarterly coefficients before the March 2018 announcement) will be plotted to assess parallel pre-trends.
2. **Joint test** for pre-treatment coefficients = 0 (F-test / Wald test).
3. **HonestDiD** sensitivity analysis (Rambachan and Roth, 2023) to bound ATT estimates under violations of parallel trends. This is the gold standard for addressing the concern that ACV cities were selected because they were declining.
4. **Pre-trend heterogeneity:** Test whether results differ for ACV cities with converging vs. diverging pre-treatment trends relative to controls.

**Evidence:** Sirene data goes back to at least 2010, providing 8+ years of pre-treatment data for quarterly establishment counts. This exceeds the typical 5-period minimum and supports granular event-study diagnostics.

---

### Condition 3: sensitivity

**Status:** [x] RESOLVED

**Response:**

Sensitivity analyses will include:
1. **Alternative matching specifications:** Propensity score matching, coarsened exact matching (CEM), and entropy balancing on pre-treatment commune characteristics (population, commercial density, unemployment, housing vacancy, département).
2. **Alternative estimators:** Sun and Abraham (2021), de Chaisemartin and d'Haultfœuille (2020), and Borusyak et al. (2024) imputation estimator, in addition to Callaway-Sant'Anna.
3. **Alternative outcome definitions:** Net establishment creation (births – deaths), gross births only, retail-only index, hospitality-only index, all-sector index.
4. **Wild cluster bootstrap** for inference with ~222 treated clusters (Cameron et al., 2008).
5. **Randomization inference (RI):** Permute treatment assignment 1,000 times across eligible communes to generate sharp null distribution.
6. **Leave-one-out:** Check that results are not driven by any single ACV city or département.
7. **Donut specification:** Drop 2018 (transition year) from the analysis.

**Evidence:** Standard sensitivity toolkit for DiD papers at top journals. CS-DiD, HonestDiD, and wild bootstrap are the methodological state of the art.

---

### Condition 4: explicit handling of ACV as a bundled package incl. ORT/Denormandie

**Status:** [x] RESOLVED

**Response:**

ACV, ORT (Opérations de Revitalisation de Territoire, Loi ELAN Nov 2018), and the Denormandie tax incentive (Jan 2019) are deliberately designed as a complementary package targeting the same cities. This is a feature, not a bug — the policy-relevant estimand is the **total ACV package effect**, which is what policymakers want to know.

Explicit handling:
1. **Frame the estimand clearly:** We estimate the effect of the "ACV treatment package" (ACV + ORT + Denormandie) on commercial vitality, not the effect of any single instrument in isolation.
2. **Timing decomposition:** ACV conventions were signed October 2018 onward. ORT was enabled by Loi ELAN (Nov 2018). Denormandie started Jan 2019. The sequence allows testing: (a) Do effects appear before ORT/Denormandie? (b) Do effects accelerate after ORT/Denormandie? This timing decomposition provides partial separation.
3. **Heterogeneity by ORT adoption:** Not all 222 ACV cities signed an ORT convention. Cities with ACV + ORT vs ACV only can be compared to assess bundling effects.
4. **Explicitly discuss in the paper** that ACV is a policy bundle and that the estimand is the total package effect.

**Evidence:** Cour des Comptes (2022) discusses the intertwining of ACV, ORT, and fiscal incentives. The convention dates in the data.gouv.fr CSV allow timing-based partial separation.

---

### Condition 5: COVID heterogeneity

**Status:** [x] RESOLVED

**Response:**

COVID (March 2020 – mid-2021) is a major confound in the post-treatment period. Handling:

1. **Région × year fixed effects** absorb regional COVID shocks.
2. **Urban structure × year interactions:** Control for city population size × year, because COVID differentially affected large vs. medium cities (flight from large cities benefited medium cities).
3. **Split sample analysis:** Report results for (a) pre-COVID post-treatment (2018–2019, 2 years), (b) COVID period (2020–2021), and (c) post-COVID (2022–2025). The pre-COVID window (2018–2019) is the cleanest test of ACV effects, uncontaminated by COVID.
4. **ACV × COVID interaction term:** Explicitly test whether ACV cities experienced different COVID impacts on commercial vitality.
5. **"Flight from Paris" control:** The pandemic triggered a well-documented migration to medium-sized cities. I can control for distance to Paris or inclusion in the Paris commuter zone.
6. **Exclusion of 2020 as robustness:** Drop the March 2020 – December 2020 period entirely and check if results hold.

**Evidence:** The ANCT Real Estate Barometer (2024) documented that ACV cities "resisted the crisis better" than the national average, suggesting differential COVID effects that must be explicitly modeled.

---

## Verification Checklist

Before proceeding to Phase 4:

- [x] All conditions above are marked RESOLVED
- [x] Evidence is provided for each resolution
- [x] This file has been committed to git

**Once complete, update Status at top of file to: RESOLVED**
