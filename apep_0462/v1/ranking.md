# Research Idea Ranking

**Generated:** 2026-02-26T15:26:38.815682
**Model:** openai/gpt-5.2 (reasoning: high)
**Tokens:** 6716

---

### Rankings

**#1: The Speed of Death: Departmental Reversals of France's 80 km/h Speed Limit and Road Safety**
- **Score: 76/100**
- **Strengths:** Clean, policy-relevant variation with many treated units (≈52 départements) and high-quality administrative microdata (BAAC) that can be tightly restricted to the actually-affected road segment types. Strong built-in falsification tests (autoroutes; agglomeration roads) and the setting is well-suited to modern staggered DiD (CS; Sun-Abraham; dCDH).
- **Concerns:** Adoption is not randomized—départements may reverse because of local politics, road composition, or pre-existing safety trends; COVID-era mobility shocks overlap early reversals and could interact with treatment timing in non-parallel ways. Treatment is often *partial* (some routes returned to 90, others not), which risks attenuation without an intensity design.
- **Novelty Assessment:** **High.** The 2018 national reduction has been studied, but the **department-level reversal margin** with staggered adoption and microdata-based road-type targeting appears under-studied academically; existing discussion is largely descriptive (ONISR comparisons).
- **DiD Assessment (mandatory 8 criteria):**
  - **Pre-treatment periods:** **Strong** (quarterly: Q3 2018–Q4 2019 gives ≥6 pre-quarters before first 2020 reversals; annual panels can also be used, but should focus on post-2018 period to keep the “baseline policy” constant).
  - **Selection into treatment:** **Marginal** (voluntary departmental choice; plausible correlation with preferences/road risk; must lean heavily on pre-trend/event-study diagnostics and covariates; consider political composition as predictors/placebos).
  - **Comparison group:** **Marginal** (non-reversal départements are usable, but treated vs untreated likely differ in rurality/road mix; dept FE + road-type restrictions help).
  - **Treatment clusters:** **Strong** (≈52 treated départements; adequate for inference).
  - **Concurrent policies:** **Marginal** (COVID mobility changes are the big threat; helps that controls experience COVID too, but interaction with reversal timing is possible; mobility controls and later adopters are important).
  - **Outcome-Policy Alignment:** **Strong** (BAAC accidents/fatalities on **routes départementales (catr=3) outside agglomeration** directly map to where the 80↔90 rule applies).
  - **Data-Outcome Timing:** **Strong** (BAAC includes accident date; can code treatment by exact effective/signage date at month/day level; avoids “measured before exposure” problems).
  - **Outcome Dilution:** **Marginal → Strong** (if you restrict to eligible road categories, dilution is low; but because reversals are often partial within a département, a binary treated indicator dilutes—use “share of network reverted” intensity when possible).
- **Recommendation:** **PURSUE (conditional on: compiling exact effective dates + intensity by département; showing robust pre-trends and COVID-robustness using mobility controls / excluding 2020 / focusing on 2022–2024 variation; estimating effects on fatalities and serious injuries separately).**

---

**#2: Size Without Scale? The Fiscal Effects of France's Municipal Merger Wave**
- **Score: 63/100**
- **Strengths:** Large-N setting (≈780 treated) with rich, credible administrative finance outcomes (OFGL) and clear treatment timing (mergers typically effective Jan 1). Strong policy relevance for territorial organization and grant design, and France is a meaningful gap relative to the Germany/Japan/Denmark evidence.
- **Concerns:** The core threat is **endogenous selection**: mergers are voluntary and plausibly chosen in response to fiscal stress, demographic decline, or administrative capacity—exactly the outcomes you will study. Treated communes are structurally different (small/rural), so “never-treated” communes may be a weak counterfactual without careful design (stacked cohorts, reweighting/matching, or quasi-exogenous incentive variation).
- **Novelty Assessment:** **Moderate-High.** Municipal consolidation is heavily studied internationally, but **France’s post-2015 “communes nouvelles” wave** is comparatively less covered with modern causal methods; still, it is not a brand-new question globally.
- **DiD Assessment (mandatory 8 criteria):**
  - **Pre-treatment periods:** **Marginal** (2016 cohort has 2012–2015 = 4 pre-years; later cohorts have more—analysis should emphasize cohorts with ≥5 pre-years or use stacked designs).
  - **Selection into treatment:** **Marginal** (could be **Weak** if evidence shows mergers preceded by worsening fiscal trends; the proposal needs a stronger quasi-exogenous lever such as DGF-bonus deadline pressure, close-call votes, or eligibility thresholds).
  - **Comparison group:** **Marginal** (never-treated communes are numerous but not necessarily comparable; require reweighting/matching and/or restricting to “at-risk of merging” communes).
  - **Treatment clusters:** **Strong** (hundreds of treated communes; inference feasible).
  - **Concurrent policies:** **Marginal** (major nationwide local-finance reforms—e.g., taxe d’habitation phase-out—affect outcomes; year FE nets common shocks, but interactions with merger status may matter).
  - **Outcome-Policy Alignment:** **Strong** (spending, debt, investment, tax rates are direct fiscal mechanisms potentially affected by mergers).
  - **Data-Outcome Timing:** **Strong** (accounts are annual; mergers effective Jan 1 typically implies near-full-year exposure in first post year).
  - **Outcome Dilution:** **Strong** (the entire merged entity is affected; not a tiny subpopulation).
- **Recommendation:** **CONSIDER (upgrade to PURSUE if: you can credibly isolate quasi-exogenous variation—e.g., DGF bonus deadline bunching, institutional constraints, or “stacked DiD” with carefully constructed at-risk controls; and you show strong pre-trend balance within the restricted sample).**

---

**#3: Does Building Bike Lanes Save Lives? Evidence from France's Cycling Infrastructure Boom**
- **Score: 45/100**
- **Strengths:** Highly policy-relevant and potentially publishable if identified well; BAAC microdata with geocodes opens the door to stronger spatial designs than a city-year DiD. The COVID “coronapistes” period provides salient variation and public interest.
- **Concerns:** As currently framed, identification is fragile: infrastructure expansion is gradual and endogenous; COVID simultaneously changed driving volumes, cycling volumes, enforcement, and street allocation. Using *counts* of cycling accidents at the city-year level risks severe outcome-policy mismatch (exposure changes) and dilution (only some corridors treated).
- **Novelty Assessment:** **Moderate.** There is a sizable international literature on cycling infrastructure and safety; the France/COVID episode is newer, but not an untouched question.
- **DiD Assessment (mandatory 8 criteria):**
  - **Pre-treatment periods:** **Strong** (BAAC back to 2005).
  - **Selection into treatment:** **Weak** (cities building lanes faster are systematically different and may be responding to cycling demand/safety issues; strong endogeneity likely).
  - **Comparison group:** **Marginal** (late adopters/smaller cities differ; comparability questionable without strong design restrictions).
  - **Treatment clusters:** **Strong** (200+ cities).
  - **Concurrent policies:** **Weak** (COVID-era mobility shocks, low-traffic zones, speed reductions, enforcement changes often coincide with bike-lane rollout).
  - **Outcome-Policy Alignment:** **Weak** (accident *counts* mix risk and exposure; bike lanes can increase cycling volumes, raising counts even if risk falls—need rates per cyclist-km or severity conditional on exposure).
  - **Data-Outcome Timing:** **Weak** (many lanes installed mid-year; annual outcomes imply partial exposure and mechanical attenuation unless using monthly data and precise opening dates).
  - **Outcome Dilution:** **Weak** (citywide cycling accidents include roads untouched by new lanes; treated network share may be small, especially outside major corridors).
- **Recommendation:** **SKIP (unless redesigned).** To become viable, pivot to a **spatial/event study**: compare crashes **within X meters of new lanes vs similar corridors not treated yet**, use **monthly** timing, incorporate cycling counts for exposure, and treat COVID explicitly (e.g., corridor fixed effects + city-by-month shocks).

---

### Summary

This is a strong batch on policy salience, but only **Idea 1** currently combines high novelty with reasonably credible identification and well-aligned outcomes; it’s the clear first project to pursue. **Idea 2** is feasible and relevant but needs a more convincing strategy against voluntary-selection bias. **Idea 3** fails multiple DiD checklist items (alignment, timing, dilution, concurrent shocks) in its current city-year DiD form and should be skipped unless re-identified with a corridor-level spatial design and exposure-adjusted outcomes.