# Research Idea Ranking

**Generated:** 2026-02-23T14:46:10.311093
**Model:** openai/gpt-5.2 (reasoning: high)
**Tokens:** 5179

---

### Rankings

**#1: Opportunity Zone Designation and Data Center Investment — A Fuzzy RDD at the Poverty Threshold**
- **Score: 74/100**
- **Strengths:** The poverty-threshold-based assignment creates a plausibly clean quasi-experiment at national scale, and the “data center” channel is meaningfully novel within the now-large Opportunity Zone (OZ) evaluation literature. Policy relevance is high given the fiscal cost of OZs and the claim that data centers are a prime “but-for” failure case.
- **Concerns:** The key *institutional* risk is that “poverty ≥20% ⇒ eligible, poverty <20% ⇒ ineligible” is not strictly true for OZs (other eligibility routes like median family income criteria and contiguous-tract rules can generate below-20% eligibility/designations), which could seriously weaken the first stage if not handled carefully. Outcome measurement is also a risk: tract-level data center activity is hard to observe in public data (CBP is county-level and often suppressed; permits/property values are proxies and may not capture data center capex well).
- **Novelty Assessment:** **Moderately novel.** OZs have many papers (prices, housing, business formation), but “OZs → data center/tech infrastructure siting” is much less studied and could be a genuinely valuable addition if executed well.
- **Recommendation:** **PURSUE (conditional on: verifying the true eligibility/designation rule around 20% poverty including MFI/contiguity exceptions; confirming a strong first stage in designation probability at the chosen running-variable cutoff; securing a credible data-center location/outcome dataset beyond suppressed CBP, e.g., commercial/industry data on facilities, capacity (MW), or square footage).**

---

**#2: Qualified Opportunity Fund Investment in Data Center Tracts — RDD with Treasury Reporting Data**
- **Score: 66/100**
- **Strengths:** Using QOF investment dollars is attractive because it measures the *mechanism* directly (capital flows), which most OZ papers struggle to observe; if tract-level QOF dollars are available, the design can cleanly show whether the OZ cutoff moved capital and whether data-center-heavy tracts disproportionately captured it. Strong policy relevance given current proposals to extend/retarget OZ benefits.
- **Concerns:** Data feasibility is the dominant risk: tract-level QOF investment may be suppressed/aggregated, and if so the core contribution collapses. Even if available, attributing QOF dollars to “data center” vs other uses may be noisy unless you have a high-quality facility/capacity dataset and can defensibly map investments to that activity.
- **Novelty Assessment:** **Moderately high.** OZ evaluation is well-trodden, but pairing OZ cutoff designs with *direct* QOF-dollar data and explicitly testing the “data center capture” hypothesis is comparatively new.
- **Recommendation:** **CONSIDER (upgrade to PURSUE if: tract-level QOF dollars exist with usable coverage; you can validate investment categorization; and you pre-specify how you’ll handle OZ eligibility exceptions so the RDD is not mis-specified).**

---

**#3: State Data Center Tax Incentive Adoption — Spatial Border County RDD**
- **Score: 47/100**
- **Strengths:** Very high topical novelty—surprisingly little credible causal evidence exists on data center tax incentives despite enormous fiscal costs. Border-based designs can be persuasive if outcomes are observed well and if confounding border discontinuities are addressed.
- **Concerns:** This is likely underpowered and potentially mis-identified as written. Data centers are lumpy, rare, and often missing/suppressed in county-by-industry data; many border counties will have zeros forever, making detection extremely difficult. Identification is also fragile because “state border” bundles many discontinuities beyond the incentive (electricity prices and regulation, permitting, land-use, fiber backbone, other subsidies), violating the smoothness assumption unless you add strong structure (border-pair fixed effects + rich controls, or a design closer to a border-county DiD/event study).
- **Novelty Assessment:** **High.** But the empirical constraints here are severe.
- **Recommendation:** **SKIP (unless redesigned)** — This could become viable if you (i) obtain a near-census dataset of data center openings/capacity (MW, square footage) with geocodes, (ii) restrict to plausible corridors (e.g., within commuting zones/metros split by a border), and (iii) treat it as a border-pair panel/event study rather than a pure spatial RDD.

---

**#4: Georgia Data Center Tax Tiers — Multi-Cutoff RDD at Population Thresholds**
- **Score: 32/100**
- **Strengths:** Clean-looking “sharp” population cutoffs are appealing in principle, and multi-cutoff designs can be elegant if the treatment actually changes behavior near the threshold.
- **Concerns:** By your own feasibility check, the outcome-policy alignment is poor: Georgia data centers are in large metro counties far from the cutoffs, so there’s no realistic margin where the tier difference changes siting. Even if you find effects on broad outcomes (total employment, revenues), attribution to the data center incentive mechanism will be very hard and likely unconvincing.
- **Novelty Assessment:** **Moderate.** Population-threshold RDDs are common; “GA tiered data center exemption via population RDD” is a niche application but not compelling if the policy doesn’t bind where data centers are.
- **Recommendation:** **SKIP.** The design is likely to produce nulls that are not informative (because the relevant activity is nowhere near the thresholds).

---

### Summary

Overall, the best concepts are the OZ-based RDDs (Ideas 1 and 4) because they can plausibly deliver credible identification at scale and tackle a relatively under-studied *industrial* channel (data centers) within a heavily studied policy. The border-county spatial RDD (Idea 2) is highly novel but is likely to fail on power and smoothness/compound-discontinuity grounds without substantially better facility-level data and a redesign. The Georgia tier RDD (Idea 3) is least promising because the thresholds appear irrelevant to where data centers actually locate, making the causal question poorly aligned with observable outcomes.