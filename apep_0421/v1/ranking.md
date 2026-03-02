# Research Idea Ranking

**Generated:** 2026-02-20T08:49:11.897931
**Model:** openai/gpt-5.2 (reasoning: high)
**Tokens:** 11186

---

### Rankings

**#1: Does Piped Water Build Human Capital? Evidence from India's Jal Jeevan Mission**
- **Score:** 72/100
- **Strengths:** Extremely policy-relevant, genuinely under-studied at scale, and the district-year panel (700+ districts) gives real scope for credible event-study diagnostics and heterogeneity. Education outcomes (girls’ enrollment/dropout) are a plausible first-order channel for household tap connections.
- **Concerns:** Rollout intensity is likely correlated with district/state capacity and broader development trends (endogeneity); COVID-era schooling shocks (2020–21) are a major concurrent confounder for enrollment/retention outcomes. Administrative JJM coverage data may be overstated or measured with error, creating attenuation or bias.
- **Novelty Assessment:** High. Surprisingly little rigorous causal work on JJM specifically; the water→human capital literature exists, but not on this flagship program at national scale.
- **DiD Assessment:**
  - **Pre-treatment periods:** **Strong** (UDISE+ 2015–2019 gives 5 pre years before Aug 2019)
  - **Selection into treatment:** **Marginal** (faster rollout plausibly tied to governance/capacity and baseline infrastructure; proposed IV may help but exclusion is debatable)
  - **Comparison group:** **Marginal** (not-yet-treated districts are usable, but “eventually-treated” comparisons can be systematically different; need strong diagnostics)
  - **Treatment clusters:** **Strong** (hundreds of districts)
  - **Concurrent policies:** **Marginal** (COVID is the big one; plus sanitation/health campaigns could co-move with water access)
  - **Outcome-Policy Alignment:** **Marginal–Strong** (tap water plausibly reduces girls’ time burden and illness → attendance/retention; alignment is conceptually sound, but education effects are indirect and could be small)
  - **Data-Outcome Timing:** **Marginal** (JJM starts Aug 2019; UDISE+ is typically as-of ~Sept 30 and/or academic-year reporting—“first treated year” can have near-zero exposure unless you lag treatment and define school-year exposure carefully)
  - **Outcome Dilution:** **Marginal** (district outcomes include urban schools/households; JJM is rural—must restrict to rural schools/blocks or weight by rural share)
- **Recommendation:** **PURSUE (conditional on: (i) define exposure on an academic-year basis with lags; (ii) pre-specify a COVID strategy—e.g., drop 2020–21 or focus on 2022–24; (iii) validate JJM dashboard coverage against NFHS/other surveys to assess mismeasurement)**

---

**#2: Did Guaranteed Employment Crowd Out or Crowd In Rural Enterprise? Evidence from MGNREGA's Phased Rollout**
- **Score:** 56/100
- **Strengths:** The question is substantively important and relatively less saturated than the wage/employment margin; the phased rollout is one of India’s best-known quasi-experiments. Economic Census outcomes are well-aligned with “enterprise creation/structure.”
- **Concerns:** The core outcome (Economic Census enterprise counts) is observed in only a couple rounds (2005, 2013; possibly 1998), making parallel-trends testing on the *same outcome* very limited. Phase assignment is “rule-based” but based on backwardness—treated and control districts are structurally different, raising serious trend-differential risk.
- **Novelty Assessment:** Medium. Many MGNREGA causal papers exist, but enterprise formation/structural change using Economic Census is much less common; still, “MGNREGA effects” broadly are heavily studied.
- **DiD Assessment:**
  - **Pre-treatment periods:** **Weak** (enterprise outcomes: effectively 1 pre-period at 2005; even with 1998 that’s still ≤2 pre points—hard to assess pre-trends for firm counts)
  - **Selection into treatment:** **Marginal** (index-based assignment is plausibly predetermined but directly related to poverty/development trajectories)
  - **Comparison group:** **Marginal** (Phase I vs Phase III districts differ fundamentally in backwardness; requires careful reweighting/matching and robustness)
  - **Treatment clusters:** **Strong** (hundreds of districts)
  - **Concurrent policies:** **Marginal** (mid-2000s had multiple rural initiatives; plus 2008 macro shock timing overlaps later phase)
  - **Outcome-Policy Alignment:** **Strong** (Economic Census establishments/employment directly measure enterprise activity)
  - **Data-Outcome Timing:** **Strong** (2005 clearly pre; 2013 clearly post with long exposure)
  - **Outcome Dilution:** **Strong** (MGNREGA is broad-based; district-level enterprise outcomes should reflect treated population meaningfully)
- **Recommendation:** **CONSIDER (conditional on: (i) pivot identification toward an explicit RDD/local randomization at phase cutoffs *if* the backwardness index and assignment rule can be reconstructed cleanly; and/or (ii) find additional pre-period enterprise measures—older Economic Censuses or alternative admin data—to support pre-trends; otherwise this is likely a “weak DiD”)**

---

**#3: MGNREGA and the Feminization of India's Rural Non-Farm Economy**
- **Score:** 52/100
- **Strengths:** Gendered structural transformation is a first-order policy concern, and the triple-difference (Female vs Male) is a sensible way to absorb many district-level confounders. Outcomes from Census worker categories are interpretable for “sectoral composition.”
- **Concerns:** The main outcomes are decennial (Census 2001 vs 2011), yielding essentially no credible pre-trends test around a 2006–08 intervention; composition changes between 2001–2011 will reflect many forces besides MGNREGA. Male outcomes are not a clean counterfactual because general equilibrium and sectoral shifts can affect men and women differently for reasons unrelated to MGNREGA.
- **Novelty Assessment:** Medium. MGNREGA-gender impacts are studied; this exact “composition shift into non-farm” angle is less common, but still adjacent to a large literature.
- **DiD Assessment:**
  - **Pre-treatment periods:** **Weak** (for Census-based composition: essentially one pre point; cannot test parallel trends in the same outcome)
  - **Selection into treatment:** **Marginal** (same backwardness-index concern as Idea 2)
  - **Comparison group:** **Marginal** (Phase I vs Phase III districts differ systematically)
  - **Treatment clusters:** **Strong**
  - **Concurrent policies:** **Marginal** (many gender/education/rural programs 2001–2011; plus broader structural transformation)
  - **Outcome-Policy Alignment:** **Marginal–Strong** (MGNREGA could shift women’s work choices; Census categories capture broad sectors, but may miss informal/seasonal work and are sensitive to reporting norms)
  - **Data-Outcome Timing:** **Strong** (2011 is post-treatment with several years’ exposure)
  - **Outcome Dilution:** **Strong** (women are directly targeted by program design; impacts need not be tiny)
- **Recommendation:** **CONSIDER (conditional on: adding higher-frequency gendered labor outcomes—e.g., NSS/PLFS-style series where possible, or administrative MGNREGA female person-days linked to local labor-market data—to create a real pre-trends test; without that, this is vulnerable to “one-pre-period DiD” skepticism)**

---

**#4: Piped Water and Child Survival: Jal Jeevan Mission's Health Dividend**
- **Score:** 46/100
- **Strengths:** Very high policy relevance; outcomes (diarrhea, anthropometrics) are tightly connected to water access in principle. The question “did JJM actually deliver health gains?” is hugely important.
- **Concerns:** Using NFHS-4 vs NFHS-5 district factsheets produces (i) only one pre and one post observation, and (ii) severe timing contamination because NFHS-5 fieldwork spans 2019–2021—overlapping both early JJM rollout and COVID. District-level aggregation discards interview-month timing that is crucial here.
- **Novelty Assessment:** High for JJM-specific causal health evaluation; lower for “piped water and child health” generally (large global literature).
- **DiD Assessment:**
  - **Pre-treatment periods:** **Weak** (two-wave DiD; cannot evaluate pre-trends)
  - **Selection into treatment:** **Marginal** (JJM rollout speed likely correlated with capacity and health investments)
  - **Comparison group:** **Marginal** (all districts treated to varying degrees; identification relies on functional-form/conditional assumptions)
  - **Treatment clusters:** **Strong** (hundreds of districts)
  - **Concurrent policies:** **Weak** (COVID disrupted healthcare access, nutrition, disease environment; also contemporaneous sanitation/health initiatives may co-move)
  - **Outcome-Policy Alignment:** **Marginal–Strong** (diarrhea is aligned; stunting/wasting reflect longer-run nutrition and infection environment—plausibly affected but less tightly mapped to short-run water rollout)
  - **Data-Outcome Timing:** **Weak** (NFHS-5 interview months vary; many “post” observations may have little/no JJM exposure; COVID period fundamentally shifts outcomes)
  - **Outcome Dilution:** **Marginal** (JJM is rural; NFHS district indicators mix rural/urban—dilutes unless you use rural-only microdata)
- **Recommendation:** **SKIP (unless redesigned)** — viable redesign would use **NFHS microdata** with **exact interview month** + rural samples, match to **district-month JJM progress**, and possibly drop COVID months; as written (factsheet two-wave), identification is not credible.

---

**#5: Portable Rations, Mobile Workers: One Nation One Ration Card and Interstate Migration in India**
- **Score:** 40/100
- **Strengths:** Policy relevance is high; staggered adoption across 36 states/UTs is, in principle, a good setting. Having take-up/transactions is a major plus for first-stage validation.
- **Concerns:** The proposed outcomes are poorly aligned with the mechanism: GST, credit/deposits, and even PLFS published aggregates are at best indirect proxies for migration and are likely dominated by non-migrant dynamics. Migrants are a small share of state populations, so dilution is severe; and the adoption window (2020–21) overlaps massively with COVID shocks and lockdown-driven reverse migration.
- **Novelty Assessment:** Medium–High. ONORC itself has limited causal evaluation, but “migration responses to social protection portability” is a known question in other contexts; the binding constraint here is identification/outcome measurement.
- **DiD Assessment:**
  - **Pre-treatment periods:** **Weak** (earliest adopters in 2019 have ~2 years pre; below the ≥3–5 year comfort zone)
  - **Selection into treatment:** **Marginal** (adoption likely correlated with state administrative capacity/digitization and welfare governance)
  - **Comparison group:** **Weak** (states differ enormously; “never-treated” doesn’t exist; not-yet-treated are not comparable without heavy adjustments)
  - **Treatment clusters:** **Strong** (36 states/UTs)
  - **Concurrent policies:** **Weak** (COVID lockdowns and relief policies swamp labor mobility patterns during core adoption period)
  - **Outcome-Policy Alignment:** **Weak** (GST/credit are not migration; PLFS published tables are unlikely to deliver state-quarter migration flows that map to interstate portability)
  - **Data-Outcome Timing:** **Marginal** (quarterly outcomes vs mid-quarter adoption is manageable, but only if outcomes truly measure migration)
  - **Outcome Dilution:** **Weak** (interstate migrants are typically <10% of population; macro aggregates will barely move even if migrant welfare improves)
- **Recommendation:** **SKIP (unless redesigned)** — a credible redesign would require **migration-specific high-frequency measures** (railway ticketing flows, telecom mobility, eShram/EPFO portability, Aadhaar-auth cross-state movement proxies) and a plan to separate ONORC from COVID-period shocks.

---

### Summary

This is a strong batch on **policy importance and novelty**, but only **Idea 1 (JJM + education with long district panels)** has a DiD structure that plausibly clears the pre-trends/timing bar with reasonable design discipline. The MGNREGA ideas (2 and 4) ask good questions but are hamstrung by **low-frequency outcome measurement**, making parallel-trends validation difficult unless you pivot to an RDD-style design or bring in additional pre-period outcome data. Ideas 3 and 5 fail mainly on **outcome-policy alignment, COVID-era confounding, and dilution**, and should not proceed without major redesign.