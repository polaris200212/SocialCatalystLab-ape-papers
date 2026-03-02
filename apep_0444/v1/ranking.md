# Research Idea Ranking

**Generated:** 2026-02-23T13:10:04.211636
**Model:** openai/gpt-5.2 (reasoning: high)
**Tokens:** 9352

---

### Rankings

**#1: Does Sanitation Drive Development? Satellite Evidence from India's Swachh Bharat Mission**
- **Score: 70/100**
- **Strengths:** Big policy with large, plausibly differential timing across states and a long satellite panel, making a modern staggered DiD/event-study feasible at scale. If you can validate “ODF” as real treatment (not just politics), the question is highly policy-relevant and the design could be credible.
- **Concerns:** ODF declarations are likely **endogenous** (better-governed/faster-growing states may declare earlier) and potentially **mis-measured** (paper ODF vs behavior change), both of which can break parallel trends or attenuate effects. Nightlights are an **indirect** proxy for sanitation’s economic channels and may be diluted by urban activity within districts.
- **Novelty Assessment:** **Moderately high.** SBM has many papers (mostly health/behavior), but “ODF timing × nightlights economic activity” is much less saturated than standard SBM outcomes; this is closer to a new angle than a rehash.
- **DiD Assessment:**
  - **Pre-treatment periods:** **Strong** (VIIRS 2012–2015 + DMSP extension gives ≥5 pre-years depending on calibration choices)
  - **Selection into treatment:** **Marginal** (ODF timing likely reflects state capacity, governance, and underlying development trends; not externally assigned)
  - **Comparison group:** **Marginal** (early-ODF vs late-ODF Indian states/districts differ structurally; “not-yet-treated” helps but doesn’t guarantee comparability)
  - **Treatment clusters:** **Strong** (≈35 state clusters; district outcomes but treatment varies at state level, so inference must respect state clustering)
  - **Concurrent policies:** **Marginal** (demonetization 2016, GST 2017 are nationwide; still risky if ODF timing correlates with differential exposure/sector mix across states)
  - **Outcome-Policy Alignment:** **Marginal** (nightlights capture broad economic activity; sanitation could affect productivity and local demand, but mapping is indirect—needs mechanism/validation)
  - **Data-Outcome Timing:** **Marginal** (VIIRS annual composites are calendar-year aggregates; ODF dates are often mid-year, so “first treated year” is partial exposure unless you switch to monthly VIIRS or re-code exposure)
  - **Outcome Dilution:** **Marginal** (SBM-G is rural; district nightlights include urban cores—treatment-relevant population could be well below 50% in urbanized districts; mitigate by rural-pixel/village-weighted lights)
- **Recommendation:** **PURSUE (conditional on: validating ODF timing with independent sanitation/use measures such as NFHS/other surveys; using monthly VIIRS or an exposure-weighted treatment definition; reporting rural-only/nightlights variants and excluding major urban pixels to reduce dilution).**

---

**#2: Piped Water and Rural Development: Early Evidence from India's Jal Jeevan Mission**
- **Score: 62/100**
- **Strengths:** Extremely policy-relevant and genuinely under-studied at causal scale; district-by-district administrative coverage data creates potentially rich treatment intensity variation. If you pivot from “100% completion” to **continuous coverage** and use careful event studies, this can become a serious evaluation.
- **Concerns:** Timing of “completion” is likely **highly endogenous** to district capacity, baseline infrastructure, and growth trajectories (parallel trends risk). Right now the design is also **premature**: few early completers and only ~1–2 post years (plus COVID-era noise) makes estimates fragile.
- **Novelty Assessment:** **High.** There is not yet a large mature causal literature on JJM comparable to older Indian flagship programs.
- **DiD Assessment:**
  - **Pre-treatment periods:** **Strong** (VIIRS 2012–2018 gives long pre-period)
  - **Selection into treatment:** **Marginal** (could easily be **weak** in practice; early completion almost surely correlates with unobserved growth/capacity—must be stress-tested with pre-trends and/or an alternative identification strategy)
  - **Comparison group:** **Marginal** (early vs late districts likely differ; comparability depends on rich controls, within-state designs, and pre-trend evidence)
  - **Treatment clusters:** **Marginal** (depends on how many districts truly hit 100% by 2023 and have usable post data; could be <20 effective treated clusters in the analysis window)
  - **Concurrent policies:** **Marginal** (COVID/recovery overlaps the early period; less of a “coincident reform” problem if completion is mostly 2022–2023, but still noisy)
  - **Outcome-Policy Alignment:** **Marginal** (nightlights are indirect; UDISE+ enrollment is plausible via health/time costs but still not the most direct water outcome—consider health clinic visits, diarrhea proxies, time use if available)
  - **Data-Outcome Timing:** **Marginal** (VIIRS annual = calendar year; “district hits 100%” date could be mid-year; UDISE+ enrollment is typically as-of early school year—often September—so alignment must be explicit)
  - **Outcome Dilution:** **Marginal** (JJM is rural; district outcomes include urban populations and non-household economic activity; dilution depends on rural share—should use rural-only measures if possible)
- **Recommendation:** **CONSIDER (conditional on: using treatment intensity—%FHTC—rather than a 100% threshold; ensuring ≥2–3 post years for a meaningful treated set; prioritizing within-state comparisons and rigorous pre-trend diagnostics; pre-registering robustness to alternative timing/exposure definitions).**

---

**#3: MGNREGA and the Feminization of the Rural Workforce: Village-Level Evidence from India**
- **Score: 48/100**
- **Strengths:** The female labor composition question is important, and the Census village universe is a major data asset with excellent statistical power. The rollout was policy-driven and based on a pre-period backwardness index, which is better than “opt-in” adoption.
- **Concerns:** The primary outcome (Census 2001→2011 change) provides **no credible pre-trend test** for female workforce composition (at best 1991/2001 gives only two pre points and still fails the DiD pre-trends standard). Phase I districts were intentionally more “backward,” so differential underlying trends are a first-order threat, and nightlights pre-trends do **not** validate labor-composition pre-trends.
- **Novelty Assessment:** **Low-to-moderate.** MGNREGA is one of the most studied Indian policies; the *village-level Census angle* is new, but the core policy question sits in a crowded literature.
- **DiD Assessment:**
  - **Pre-treatment periods:** **Weak** (for the *actual* female workforce composition outcome: essentially one pre-period in 2001; even adding 1991 yields only two pre points—still weak)
  - **Selection into treatment:** **Strong** (rollout tied to pre-determined backwardness criteria, not chosen by districts)
  - **Comparison group:** **Weak** (Phase I vs Phase III districts are structurally different by design; comparability is a major issue)
  - **Treatment clusters:** **Strong** (hundreds of districts; inference feasible)
  - **Concurrent policies:** **Marginal** (other targeted rural/health programs in the mid-2000s could differentially affect “backward” districts)
  - **Outcome-Policy Alignment:** **Strong** (female worker composition is directly tied to the hypothesized mechanism)
  - **Data-Outcome Timing:** **Strong** (2011 Census reflects multiple years of exposure post-2006/08)
  - **Outcome Dilution:** **Strong** (village-level rural outcome; treatment relevant to a large share of residents)
- **Recommendation:** **SKIP (unless redesigned).** To salvage: bring in **annual/repeated** labor outcomes at district level (NSS/PLFS/administrative work participation measures) to create ≥5 true pre-periods for the *same* outcome, or switch to a different design (e.g., IV/RDD around the backwardness cutoff if a true threshold exists and is non-manipulable).

---

**#4: Does Ration Card Portability Unlock Labor Mobility? Evidence from India's One Nation One Ration Card**
- **Score: 38/100**
- **Strengths:** Policy is hugely important, nationally scaled, and genuinely under-evaluated; the theoretical mechanism (portability reduces migration frictions) is clear and policy-relevant.
- **Concerns:** The rollout is almost perfectly confounded by **COVID-19 and the 2020 migration shock**, which is a major concurrent event directly affecting the outcomes of interest (mobility, urban activity, nightlights). Nightlights are also a **weak proxy** for labor mobility (alignment problem), making nulls or positives hard to interpret.
- **Novelty Assessment:** **High.** There are few rigorous causal evaluations so far.
- **DiD Assessment:**
  - **Pre-treatment periods:** **Strong** (VIIRS 2012–2018 pre-period)
  - **Selection into treatment:** **Marginal** (adoption likely correlated with state admin capacity/digitization readiness)
  - **Comparison group:** **Marginal** (late adopters differ; and the pandemic created heterogeneous shocks)
  - **Treatment clusters:** **Strong** (many states/UTs adopt over time)
  - **Concurrent policies:** **Weak** (COVID lockdowns and recovery coincide with adoption timing and directly move migration/economic activity—dealbreaker for clean DiD here)
  - **Outcome-Policy Alignment:** **Weak** (nightlights are not a direct measure of migration; portability could change welfare without moving lights much, and lights moved massively for COVID reasons)
  - **Data-Outcome Timing:** **Weak** (adoption begins Aug 2019; pandemic hits Mar 2020; annual nightlights blur exposure and are dominated by pandemic-era dynamics)
  - **Outcome Dilution:** **Marginal** (policy targets PDS beneficiaries—large, but still a subset of total economic activity; nightlights reflect everyone)
- **Recommendation:** **SKIP (in current form).** A viable redesign would require outcomes directly tied to portability/mobility (administrative ONORC transaction flows, ePoS data, mobility data, PLFS migration modules) and a strategy that cleanly handles COVID (e.g., focus only on Aug 2019–Feb 2020 pilot window—but that likely becomes underpowered and short).

---

### Summary

Only **Idea 1 (SBM × nightlights)** clears the bar as a plausible, policy-relevant DiD with enough time-series depth—though it still hinges on convincing readers that **ODF timing is not just endogenous politics** and that nightlights are not too diluted. **Idea 4 (JJM)** is novel and important but looks **too early** and potentially endogenous unless you shift to intensity and accumulate more post-treatment years. **Ideas 2 and 3** fail key DiD criteria (female labor pre-trends for Idea 2; COVID/confounding and outcome mismatch for Idea 3) and should be skipped unless substantially redesigned.