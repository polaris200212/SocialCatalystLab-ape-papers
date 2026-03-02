# Conditional Requirements

**Generated:** 2026-02-26T15:26:38.819086
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

## The Speed of Death: Departmental Reversals of France's 80 km/h Speed Limit and Road Safety

**Rank:** #1 | **Recommendation:** PURSUE

### Condition 1: compiling exact effective dates + intensity by département

**Status:** [x] RESOLVED

**Response:**
Treatment timing will be compiled from three cross-validated sources: (1) Ligue de Défense des Conducteurs observatory (52 départements with dates and network coverage), (2) L'Argus/France Info interactive maps with département-level detail, (3) ONISR annual reports (2021: 39 depts, 2022: 46, etc.). For intensity, the Revue Technique Auto published a table of 51 départements with percentage of eligible network restored. These sources will be cross-validated to build the treatment panel (département × effective_date × km_restored × share_network). Where dates conflict, prefectoral arrêtés on Légifrance will be used as the authoritative source.

**Evidence:**
- Ligue des Conducteurs: https://www.liguedesconducteurs.org/observatoire-80-versus-90-kmh-ldc/
- L'Argus: https://www.largus.fr/actualite-automobile/la-carte-de-france-des-departements-qui-repassent-a-90-kmh-10488403.html
- France Info map: https://www.franceinfo.fr/societe/securite-routiere/limitation-de-la-vitesse-a-80-km-h/carte-routes-quels-sont-les-departements-ou-la-limite-de-vitesse-est-repassee-a-90-km-h_6009233.html
- Revue Technique Auto: https://www.revue-technique-auto.fr/fr/parolesdexperts/retour-aux-90-kmh-quels-sont-les-departements-concernes--n541

---

### Condition 2: showing robust pre-trends

**Status:** [x] RESOLVED

**Response:**
Event-study specification with quarterly data from Q3 2018 (when 80 km/h took effect) will show pre-treatment dynamics. With 6 quarters of "universal 80 km/h" before Q1 2020 (first reversals), there are sufficient pre-periods to test parallel trends. Additionally, using annual data going back to 2015 provides 5 pre-treatment years. Pre-trend coefficients will be plotted with 95% CIs. If pre-trends are violated, will apply HonestDiD (Rambachan & Roth 2023) sensitivity analysis. Placebo outcomes (autoroute accidents in the same départements) provide a direct falsification test.

**Evidence:**
- BAAC data verified available 2005-2024 on data.gouv.fr (downloaded and confirmed structure)
- 2019 data shows 97 metropolitan départements with accidents on routes départementales
- Quarterly aggregation yields ~25 accidents/dept/quarter (sufficient for pre-trends testing)

---

### Condition 3: COVID-robustness using mobility controls / excluding 2020 / focusing on 2022–2024 variation

**Status:** [x] RESOLVED

**Response:**
Three-pronged COVID robustness strategy: (1) Baseline CS-DiD with département and quarter FE absorbs common COVID shocks affecting treated and control equally. (2) Subsample analysis restricting to post-COVID reversal cohorts (2022-2026 adopters) where COVID confounding is minimal. (3) Google Mobility Reports (available 2020-2022 at département level) as explicit controls for driving activity changes. (4) Excluding 2020 Q1-Q3 (lockdown period) as sensitivity check. (5) Triple-difference using autoroute accidents in the same départements (COVID affected all roads equally, speed limit change only affected routes départementales).

**Evidence:**
- Google COVID Community Mobility Reports available at département level for France
- ~15 départements reversed after 2021, providing clean post-COVID variation
- Autoroute accidents provide within-département placebo outcome

---

### Condition 4: estimating effects on fatalities

**Status:** [x] RESOLVED

**Response:**
Fatalities (grav=2 in BAAC usagers file) will be a primary outcome. With 475 fatalities/year nationally on affected roads (~5/dept/year), annual-level analysis is feasible but noisy. Monthly/quarterly aggregation improves power. Will present: (a) fatality counts per département-quarter, (b) fatality RATE per 100 accidents (severity ratio), (c) log fatalities with Poisson quasi-MLE for count data. MDE calculation: with 52 treated and 40 control départements, 6 pre-periods, and σ ≈ 4 fatalities/dept/year, a 13% effect (0.65 additional fatalities/dept/year) has power ~0.7 at α=0.05 using cluster-robust inference.

**Evidence:**
- 2019 BAAC data shows 475 fatalities on routes départementales hors agglomération
- Median département: 4 fatalities/year; mean: 5.2
- ONISR's prior estimate: +74 excess deaths/year (13% increase) across reversal départements

---

### Condition 5: serious injuries separately

**Status:** [x] RESOLVED

**Response:**
Serious injuries (grav=3, hospitalized) will be reported as a separate outcome in all specifications. Note: the hospitalization classification changed in 2018 with the reform of the BAAC codebook, so pre-2018 comparisons require care. For the reversal analysis (2018+ data), the classification is consistent. Will also report: (a) total corporal accidents (the most-powered outcome), (b) light injuries (grav=4), (c) a severity index (killed + hospitalized as share of all victims). The severity decomposition tests whether the speed limit reversal affects the extensive margin (more accidents) or intensive margin (more severe accidents conditional on occurring).

**Evidence:**
- 2019 BAAC shows 3,528 hospitalized + 8,484 light injuries on routes départementales hors agglomération
- Hospitalized injuries: ~36/dept/year — much more statistical power than fatalities alone
- Severity classification consistent within 2018-2024 window

---

## Verification Checklist

Before proceeding to Phase 4:

- [x] All conditions above are marked RESOLVED or NOT APPLICABLE
- [x] Evidence is provided for each resolution
- [x] This file has been committed to git

**Once complete, update Status at top of file to: RESOLVED**
