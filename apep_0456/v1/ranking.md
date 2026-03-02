# Research Idea Ranking

**Generated:** 2026-02-25T17:24:20.178551
**Model:** openai/gpt-5.2 (reasoning: high)
**Tokens:** 6311

---

### Rankings

**#1: Low Emission Zone Boundaries and Property Values — Spatial RDD on French ZFE**
- Score: 77/100
- Strengths: Very strong data environment (DVF is enormous and precisely geocoded) and the spatial-RDD + event-study “difference-in-discontinuities” design is a genuinely compelling way to get closer to causal effects than the standard LEZ DiD. High policy salience (urban climate/transport policy) and credible scope for heterogeneous effects (transit access, income, baseline pollution).
- Concerns: ZFE boundaries often coincide with “real” neighborhood discontinuities (ring roads, major arterials, commune borders) that can generate price jumps unrelated to the ZFE (noise, access, school zones, neighborhood identity), so you’ll need very careful design (boundary-segment fixed effects, placebo boundaries, and strong pre-period smoothness). Treatment is also “exposure-mediated” (depends on car ownership/commuting and enforcement), so interpretation should be framed as the capitalization of the bundle of changes at the boundary, not pure air quality.
- Novelty Assessment: High. LEZ/ULEZ and housing prices have been studied, but mostly with DiD; spatial RDD at LEZ boundaries (especially with France’s DVF scale and staggered tightening) is much less explored and plausibly first-mover in this exact configuration.
- Recommendation: **PURSUE (conditional on: (i) convincing pre-trend/placebo discontinuity tests in multiple pre-ZFE years; (ii) boundary-segment FE / local border-pair comparisons to soak up road/administrative discontinuities; (iii) clear handling of phased tightening/anticipation and enforcement dates by city).**

---

**#2: Quartiers Prioritaires (QPV) Designation and Local Economic Activity — RDD on Income Concentration Threshold**
- Score: 71/100
- Strengths: The policy is large, multi-instrument, and politically important; an RDD around a transparent threshold is an attractive way to move beyond descriptive “QPV gap” reporting. Outcomes (firm creation/survival, property prices) are well-measured in Sirene/DVF and plausibly responsive to QPV-linked tax exemptions and investment.
- Concerns: This is not a pure “single-cutoff, sharp RDD” in practice: the designation algorithm includes contiguity and minimum population rules, and there was local input—so you may end up with a *fuzzy/algorithmic* threshold and must document the first stage carefully. The running variable (FILOSOFI carroyage) looks like the biggest operational risk; if access is delayed or the measure is too discrete/noisy at 200m, the design weakens quickly.
- Novelty Assessment: High-moderate. Surprisingly under-exploited with quasi-experimental methods given the policy scale; I do not recall a well-known published RDD on the 2014 QPV cutoff, though there is substantial descriptive and program-evaluation literature.
- Recommendation: **CONSIDER (upgrade to PURSUE if: (i) FILOSOFI carroyage microdata access is secured reliably; (ii) you can replicate the designation rule and show a strong discontinuity in treatment probability at 50%; (iii) you pre-register/commit to bandwidth and robustness given discreteness).**

---

**#3: Close Municipal Elections and Local Public Investment — RDD on Vote Margin**
- Score: 63/100
- Strengths: Data feasibility is excellent (election returns + DGCL fiscal accounts are standard, DVF/Sirene add rich downstream outcomes), and close-election RDD is a well-understood identification strategy with clear validity checks (density at zero margin, covariate balance, placebo outcomes). Strong policy relevance for intergovernmental transfers, investment cyclicality, and local economic development.
- Concerns: Novelty is only moderate because close-election RDD is a crowded design internationally, and France’s two-round list system makes “treatment” (party/coalition/ideology) messier than single-candidate races—classification of political alignment and constructing a clean forcing variable requires care. Effects on investment may have implementation lags and be mechanically tied to the municipal budget calendar, so timing of outcome windows matters for interpretation (even if not a DiD).
- Novelty Assessment: Moderate. The *France-specific* application with DVF-scale housing outcomes is less common, but the core design is well-trodden.
- Recommendation: **CONSIDER (conditional on: (i) a transparent, defensible mapping from list outcomes to political “treatment”; (ii) focusing on communes where the mapping is unambiguous; (iii) pre-specifying outcome windows consistent with French budget/investment timing).**

---

**#4: Education Priority Zone Designation and Housing Price Capitalization — RDD on School Social Composition Index**
- Score: 52/100
- Strengths: The IPS disclosure is recent and could enable genuinely new work in France; the question (school designation capitalization into housing) is policy-relevant and connects to a classic literature (Black 1999-style capitalization). If catchments can be measured credibly, a fuzzy RDD could be interesting.
- Concerns: Data feasibility/construct validity are the binding constraints: catchment boundaries are not centrally available and are essential for a clean capitalization design; without them, “distance to school” is not the assignment mechanism and will muddle interpretation. Identification is also intrinsically fuzzier (discretionary REP assignment, unclear published cutoff, limited mass near threshold especially for REP+), so you risk weak first stage and a design that is hard to explain/defend.
- Novelty Assessment: Moderate-high (France/IPS-specific), but the *research question* (school quality/designation and housing prices) is extremely studied elsewhere; the novelty is mainly institutional/data rather than conceptual.
- Recommendation: **SKIP (unless: (i) you can obtain nationwide catchment boundaries or a high-quality proxy for assignment; and (ii) you can document a strong, stable first stage from IPS to REP/REP+ near a clearly defined cutoff).**

---

**#5: Commercial Authorization Threshold and Retail Market Structure — RDD at 1,000 m²**
- Score: 34/100
- Strengths: If the running variable were observed, the regulatory threshold is conceptually clean and highly policy-relevant (entry barriers, market structure, local employment). The 300→1,000 m² change is also potentially valuable for complementary designs.
- Concerns: The proposal currently fails on the most important feasibility point: **no reliable, scalable dataset with store-level floor area / planned sales area** is in hand, and assembling CDAC applications/decisions nationwide is a major data-construction project with uncertain completeness. Even with data, strategic bunching at 999 m² is likely severe—potentially interesting, but it undermines a standard RDD and pushes the project toward a different design (bunching/manipulation + approval probability modeling).
- Novelty Assessment: Moderate. French retail regulation has a classic literature (e.g., Bertrand & Kramarz and successors), and an RDD here would be a methodological twist—but only if the data hurdle is cleared.
- Recommendation: **SKIP (unless you first secure a comprehensive administrative source for floor area/planned area with near-universal coverage).**

---

### Summary

This is a strong batch on *ideas*, but only two look immediately “research-ready” without major structural hurdles. **Idea 1** is the clear front-runner because it combines unusually rich data with a design that can be made quite credible if the boundary confounding is handled properly; **Idea 2** is next-best but hinges on obtaining/operationalizing the FILOSOFI carroyage running variable and showing a strong first stage given the algorithmic aspects of QPV designation. **Idea 4** should be deprioritized due to a critical data gap; **Idea 3** is promising in concept but likely to stall on catchment boundaries and weak/unclear cutoff structure.