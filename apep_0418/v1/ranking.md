# Research Idea Ranking

**Generated:** 2026-02-19T16:25:54.644696
**Model:** openai/gpt-5.2 (reasoning: high)
**Tokens:** 6823

---

### Rankings

**#1: Does Place-Based Climate Policy Work? A Regression Discontinuity Analysis of IRA Energy Community Bonus Credits**
- Score: 82/100
- Strengths: Very high novelty on a flagship, high-stakes policy (IRA) with a legislated cutoff that plausibly supports credible quasi-experimental estimation. Data sources for both treatment and energy investment outcomes are largely public and reasonably well-matched to the mechanism.
- Concerns: “Energy community” status is not determined *only* by the 0.17% threshold (multiple qualification pathways + the unemployment condition), so the design can easily become **fuzzy** unless the sample is restricted to the statutory-area channel with clean determinism. Investment/siting responses may have long lags (interconnection queues, permitting), so early post-IRA years risk underestimating effects.
- Novelty Assessment: **High**. There is plenty on place-based policy and clean-energy subsidies, but essentially no credible causal work yet on the *realized* effects of the IRA energy community bonus using discontinuities.
- DiD Assessment (if applicable): Not DiD (RDD).
- Recommendation: **PURSUE (conditional on: cleanly isolating areas where qualification is mechanically determined by the 0.17% rule; validating timing by using “early pipeline” outcomes like interconnection queue entries/permitting in addition to EIA 860 build outcomes)**

---

**#2: Wildfire Smoke, Air Quality Thresholds, and Consumer Spending: Evidence from EPA AQI Discontinuities**
- Score: 69/100
- Strengths: Excellent high-frequency panel variation with large samples (county × day) and a clear, policy-salient “information treatment” (AQI color categories/advisories) that plausibly shifts behavior beyond the biological pollution channel. Opportunity Insights spending data is a strong, policy-relevant economic outcome that is less studied than health endpoints.
- Concerns: The key threat is **behavior not being discontinuous** at 101/151—people and institutions may respond smoothly to perceived smoke, not to the AQI label—making the “RDD” effectively a test for salience/communication effects, not pollution impacts. Monitor placement/missingness and county-level assignment of AQI (often not truly county-universe) can create nonclassical measurement error near cutoffs.
- Novelty Assessment: **Medium**. AQI-threshold designs and pollution RDDs exist, but consumer spending responses to AQI advisories are less saturated than health and labor supply; still, this is adjacent to an established literature.
- DiD Assessment (if applicable): Not DiD (RDD).
- Recommendation: **CONSIDER (strongly preferred if framed explicitly as an “information/advisory threshold” effect; and conditional on showing no discontinuities in weather/smoke correlates and robust handling of monitor coverage/assignment)**

---

**#3: The $55,000 Cliff: IRA Clean Vehicle Credit Price Caps and Manufacturer Strategic Pricing**
- Score: 63/100
- Strengths: The MSRP cap is a textbook environment for bunching/threshold responses, and the manufacturer strategic pricing angle is genuinely interesting relative to a demand-heavy EV-credit literature. High policy relevance given ongoing debate about EV subsidy design and incidence (consumers vs firms).
- Concerns: Data feasibility is the core risk: EPA MSRP is not transaction price, trim-level pricing is complex, and credible sales/registration microdata is often proprietary—without it, welfare/incidence claims will be thin. Identification is also complicated by *other* IRA eligibility rules changing around the same time (assembly/battery rules; evolving guidance; SUV classification), which can confound a clean “MSRP-cap-only” interpretation.
- Novelty Assessment: **Medium-High**. There is lots on EV credits and adoption, much less on manufacturer pricing/bunching around subsidy cliffs—this is plausibly novel if executed with the right data.
- DiD Assessment (if applicable): Not DiD (bunching/RD-style).
- Recommendation: **CONSIDER (conditional on: obtaining trim-level MSRP + transaction/registration data; and cleanly separating MSRP-cap incentives from other contemporaneous IRA eligibility shocks)**

---

**#4: Aging into Medicare at 65 and the Decision to Start a Business: Health Insurance Lock and Entrepreneurship**
- Score: 54/100
- Strengths: The age-65 threshold is conceptually clean, policy-relevant, and widely understood; if you can measure entrepreneurship cleanly at high frequency, this can speak directly to “job/entrepreneurship lock.” Large national surveys and administrative business data make this potentially scalable.
- Concerns: Novelty is limited (age-65 RDD is extremely well-trodden in health/labor), and entrepreneurship specifically may already have partial coverage in prior work even if not as the main outcome. More importantly, the proposed CPS “age in months” running variable is likely **not feasible/precise** in standard monthly CPS, and confounding discontinuities at 65 (retirement norms, Social Security claiming, pensions) make a single-threshold design hard to attribute to Medicare without stronger structure (e.g., heterogeneous effects by pre-65 insurance type).
- Novelty Assessment: **Low-Medium**. The Medicare-at-65 discontinuity is one of the most studied thresholds in applied micro; the incremental novelty hinges on (i) entrepreneurship as the main outcome and (ii) unusually strong data/measurement.
- DiD Assessment (if applicable): Not DiD (RDD).
- Recommendation: **SKIP unless redesigned (e.g., using data with exact DOB/age-in-months and pre-65 insurance status; and a strategy to separate Medicare from retirement/Social Security channels)**

---

**#5: Does Federal Broadband Funding Close the Digital Divide? Evidence from FCC Speed Thresholds**
- Score: 41/100
- Strengths: Big-ticket policy question (BEAD) with enormous relevance; in principle, a threshold-based design could be compelling if treatment were mechanically assigned and outcomes were observed after buildout.
- Concerns: The “25 Mbps” running variable is **provider-reported and strategically manipulable**, and BEAD funding is not a mechanical function of being just below/above 25 Mbps (state plans, challenge processes, engineering constraints), so the design is unlikely to be a sharp RDD and may not even be a credible fuzzy RDD. Timing is also problematic: awards/buildouts are recent and staggered, so meaningful adoption/remote-work outcomes likely won’t be measurable soon.
- Novelty Assessment: **Medium**. BEAD itself is new, but “broadband thresholds with messy maps” is a known identification minefield; novelty doesn’t compensate for weak identification feasibility here.
- DiD Assessment (if applicable): Not DiD (RDD proposed).
- Recommendation: **SKIP**

---

### Summary

This is a strong batch on policy salience, but only one idea (IRA energy communities RDD) combines **high novelty + plausibly clean identification + feasible data** right now. The AQI–spending threshold design is a solid second-best if framed correctly as an *information/advisory* discontinuity rather than a pure pollution effect. The BEAD broadband threshold idea is the clearest “do not fund yet” case because the threshold is not mechanically tied to treatment and the running variable is especially vulnerable to reporting/manipulation and timing limitations.