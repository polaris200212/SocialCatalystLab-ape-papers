# Research Idea Ranking

**Generated:** 2026-03-03T14:16:46.161042
**Models:** GPT-5.2, Gemini 3.1 Pro, Grok 4.1 Fast
**Reasoning:** high

## Comparison Table

| Idea | GPT-5.2 | Gemini 3.1 Pro | Grok 4.1 Fast |
|------|------|------|------|
| The Price of Subsidy Limits — Multi-Cuto... | PURSUE (74) | PURSUE (85) | PURSUE (78) |
| Flood Risk, Insurance Subsidies, and Pro... | CONSIDER (61) | CONSIDER (72) | CONSIDER (68) |
| Stamp Duty Holidays and Housing Market D... | SKIP (54) | SKIP (50) | SKIP (54) |

---

## GPT-5.2

**Tokens:** 5882

### Rankings

**#1: The Price of Subsidy Limits — Multi-Cutoff Evidence from Help to Buy's Regional Caps**
- **Score: 74/100**
- **Strengths:** The 2021 switch to 9 region-specific caps is a genuinely nice “new object,” and the multi-cutoff bunching design gives unusual internal replication (9 thresholds at once) with clear falsification/placebo options (resales; London cap unchanged). Spatial border comparisons add a second, conceptually distinct source of identifying variation.
- **Concerns:** The Land Registry data won’t tell you who actually used Help-to-Buy or whether the buyer was a first-time buyer post‑2021, so interpretation can drift from “policy effect” to “pricing around salient thresholds among eligible new-build stock.” The post‑reform window is relatively short and overlaps a volatile macro housing period, so you’ll need to be explicit that this is about *pricing frictions/incidence around caps* rather than broader market equilibrium effects.
- **Novelty Assessment:** **High.** Help-to-Buy has been studied, and bunching at the *single* £600k cap has a paper now, but exploiting the **9 simultaneous regional caps + border designs** is (to my knowledge) largely unexploited in the academic literature.
- **Top-Journal Potential: Medium-High.** Not automatically top‑5, but it has the ingredients top field journals like AEJ:EP/JUE like: clean policy kink/notch environment, replication across cutoffs, and an interpretable design lesson about how caps translate into price manipulation/incidence. To push toward top‑5, you’d need a tighter welfare/design message (e.g., how much subsidy is captured by developers vs buyers; distortions in quality/size; implications for optimal cap design).
- **Identification Concerns:** (i) Sorting/manipulation is the *outcome* in bunching, but you must show it’s tied to the cap rather than coincident pricing norms; (ii) border RDD requires very local comparisons and strong evidence that other discontinuities (planning regimes, local demand) don’t jump at region lines; (iii) compositional changes post‑2021 (FTB-only rule) could change the pool of transactors in ways that mimic cap effects.
- **Recommendation:** **PURSUE (conditional on: a convincing interpretation strategy without individual HTB take-up; a pre-analysis plan for border bandwidths/placebos; at least one mechanism margin beyond price—e.g., property type mix/quality proxies, time-on-market if obtainable, or developer-level clustering).**

---

**#2: Flood Risk, Insurance Subsidies, and Property Values — A Spatial Regression Discontinuity at England's Flood Zone Boundaries**
- **Score: 61/100**
- **Strengths:** The Flood Re timing creates a strong mechanism test (insurance-cost channel vs risk-perception channel), and a boundary-based design is, in principle, a step up from standard hedonic capitalization regressions. Policy stakes are real (insurance subsidies, land-use regulation, climate adaptation).
- **Concerns:** Feasibility/measurement is the main risk: Land Registry PPD lacks property attributes and (critically) construction year, yet your proposed triple-difference hinges on **pre‑2009 eligibility**—without linking to EPC/VOA/Valuation Office or another source for age/characteristics, the core design may not be implementable. Postcode-centroid geocoding can produce serious running-variable measurement error right where spatial RDD needs precision; plus flood boundaries often follow rivers/coasts where amenities and unobservables can change discontinuously.
- **Novelty Assessment:** **Medium.** Flood-risk capitalization is heavily studied internationally and in the UK, but **UK spatial RDD at EA boundaries + using Flood Re as a mechanism shifter** is meaningfully less common and could be a contribution if executed cleanly.
- **Top-Journal Potential: Medium.** Could be AEJ:EP/top field if you truly nail the design and mechanism decomposition (insurance vs beliefs) with persuasive diagnostics. Without high-quality micro covariates/structure age and precise geolocation, it is likely to be viewed as “clever but fragile.”
- **Identification Concerns:** (i) Smoothness/continuity at boundaries is not guaranteed (waterfront amenities; local planning/zoning correlated with floodplains); (ii) boundary definitions may change over time or embed endogenous protection investments; (iii) centroid location error biases RDD toward zero and can create spurious patterns if correlated with postcode geometry near rivers.
- **Recommendation:** **CONSIDER (conditional on: obtaining property age/attributes and better geocodes; demonstrating boundary balance on observables; showing results are robust across multiple boundary segments and excluding obvious amenity discontinuities like immediate waterfront strips).**

---

**#3: Stamp Duty Holidays and Housing Market Dynamics — Temporal RDD at the 2021 Cliff Edge**
- **Score: 54/100**
- **Strengths:** Data is abundant and the deadlines are sharp, giving high power for event-time patterns, bunching, and market-timing responses. Policymakers care a lot about transaction taxes and “holiday” design.
- **Concerns:** Novelty is limited—SDLT notch/bunching is a mature literature, and the COVID holiday period has been analyzed in multiple outlets (academic and policy), making it hard to claim a new object. Identification is also inherently tricky: the deadline is anticipated, so sorting/manipulation is massive, and what you identify cleanly is mostly *timing* (intertemporal shifting) rather than durable incidence on prices—often read as “competent but not field-changing.”
- **Novelty Assessment:** **Low-Medium.** The exact 2021 step-down structure is somewhat distinct, but the broader question (stamp duty holidays/deadlines and bunching) is very well-trodden.
- **Top-Journal Potential: Low-Medium.** Unlikely to clear top‑5/AEJ:EP unless you can deliver something beyond a better-measured bunching plot—e.g., a compelling welfare/accounting decomposition (deadweight loss vs liquidity relief), general equilibrium implications, or a surprising mechanism (credit constraints, chain effects, failures of market intermediation).
- **Identification Concerns:** (i) Temporal RD around known deadlines violates “no sorting” by construction; (ii) contemporaneous shocks (pandemic demand, mortgage market shifts) complicate interpretation even in narrow windows; (iii) outcomes like price may reflect compositional shifts in transacted properties rather than incidence.
- **Recommendation:** **SKIP (unless you can reframe around a sharper mechanism/welfare deliverable and bring in additional data—e.g., mortgage offers, listings, chain collapse, or conveyancing delays—to explain the timing distortion and its welfare costs).**

---

### Summary

This is a solid batch with one clearly high-upside idea. **Idea 1** is the best bet because it combines a genuinely new policy feature (9 simultaneous caps) with unusually strong internal replication and feasible administrative data. **Idea 2** could be very good but is currently bottlenecked by data/measurement requirements (property age, geocoding precision); **Idea 3** is likely to be crowded and to land as “incremental” absent a stronger mechanism-and-welfare angle.

---

## Gemini 3.1 Pro

**Tokens:** 8226

Here is my evaluation of the research proposals, ranked from most to least promising, applying the rigorous standards of top-tier economics journals and the provided editorial patterns.

### Rankings

**#1: The Price of Subsidy Limits — Multi-Cutoff Evidence from Help to Buy's Regional Caps**
- **Score**: 85/100
- **Strengths**: Leverages a rare, multi-dimensional policy shock (9 simultaneous caps, temporal changes, and spatial borders) to provide robust internal replication. The ability to estimate price incidence across different regional housing markets offers clear, quantifiable welfare implications for a first-order policy debate.
- **Concerns**: The spatial RDD at regional borders may suffer from small sample sizes, as new-build developments exactly on regional boundaries are relatively rare. Furthermore, the 2021–2023 period coincides with severe macroeconomic shocks (interest rate hikes) that could complicate the temporal difference-in-bunching.
- **Novelty Assessment**: High. While the pre-2021 Help to Buy scheme is well-documented (e.g., Carozzi et al. 2024), the 2021 regional cap reform remains largely unexploited. The combination of a multi-cutoff bunching design with a spatial boundary RDD is entirely novel for this literature.
- **Top-Journal Potential**: High. Top journals reward papers that build a compelling "causal chain" and quantify welfare rather than just estimating an ATE. By exploiting 9 simultaneous notches and spatial borders, this paper maps the heterogeneous incidence of housing subsidies, fitting the editorial preference for definitive, scale-driven statements.
- **Identification Concerns**: The main threat is whether regional borders perfectly coincide with other unobserved local discontinuities (e.g., local authority planning policies, council tax bands, or wage shocks) that independently affect new-build prices. 
- **Recommendation**: PURSUE

**#2: Flood Risk, Insurance Subsidies, and Property Values — A Spatial Regression Discontinuity at England's Flood Zone Boundaries**
- **Score**: 72/100
- **Strengths**: The triple-interaction design brilliantly isolates the mechanism—separating the pure risk perception of flood zones from the financial burden of insurance costs by exploiting the Flood Re pre-2009 eligibility rule. It pre-builds the skeptic's counterargument into the design.
- **Concerns**: Relying on postcode centroids (~15 households per postcode) for a spatial RDD running variable introduces severe measurement error right at the boundary. GIS computation for millions of properties against complex polygons is also highly non-trivial.
- **Novelty Assessment**: Medium-High. While flood capitalization is heavily studied using hedonic models, applying a spatial RDD combined with the Flood Re policy shock to decompose mechanisms is a fresh, valuable approach that moves beyond standard literature.
- **Top-Journal Potential**: Medium. The mechanism decomposition (insurance vs. risk) perfectly aligns with editorial preferences for separating competing stories and isolating intermediate outcomes. However, if the spatial measurement error cannot be resolved, top journals will reject it on data/identification grounds.
- **Identification Concerns**: Postcode centroids will misclassify properties near the complex, non-linear flood zone boundaries, severely attenuating the discontinuity. The design strictly requires exact property coordinates (e.g., UPRN data) to avoid fatal measurement error in the running variable.
- **Recommendation**: CONSIDER (conditional on: securing exact property coordinates (UPRN) rather than relying on postcode centroids; verifying sufficient transaction density exactly at the boundaries).

**#3: Stamp Duty Holidays and Housing Market Dynamics — Temporal RDD at the 2021 Cliff Edge**
- **Score**: 50/100
- **Strengths**: The policy provides massive, salient shocks with a universe of high-quality administrative data, ensuring immense statistical power. The phased step-down creates an interesting "dosage" variation.
- **Concerns**: The literature on UK Stamp Duty holidays is entirely saturated, and the proposed temporal RDD is fundamentally flawed because buyers actively manipulate the running variable (transaction date) to beat the deadline.
- **Novelty Assessment**: Low. SDLT notches and holidays are among the most heavily studied topics in public and urban economics (Best & Kleven, Besley et al., plus numerous recent COVID-era working papers). 
- **Top-Journal Potential**: Low. This is the quintessential "competent but not exciting" proposal that estimates an ATE on a highly familiar policy without revealing a counter-intuitive mechanism. It lacks the belief-changing pivot required to excite top-5 economics journals.
- **Identification Concerns**: Temporal RDD assumes no precise manipulation of the running variable, but retiming transactions to beat the tax deadline is the exact behavioral response occurring. This violates the core RDD assumption, necessitating a bunching design which is already heavily saturated in the literature.
- **Recommendation**: SKIP

### Summary

This batch presents a clear hierarchy of scientific potential. Idea 1 is a standout proposal that leverages a complex, multi-dimensional policy shock to deliver top-tier causal inference on a first-order policy issue, making it highly competitive for top journals. Idea 2 has excellent theoretical framing and mechanism decomposition but faces a near-fatal data limitation regarding spatial precision that must be solved before proceeding. Idea 3 is a classic example of a technically feasible but scientifically redundant project that would read as "competent but unexciting"; I strongly recommend skipping it and focusing institute resources on Idea 1.

---

## Grok 4.1 Fast

**Tokens:** 5318

### Rankings

**#1: The Price of Subsidy Limits — Multi-Cutoff Evidence from Help to Buy's Regional Caps**
- **Score**: 78/100
- **Strengths**: Exceptional novelty from exploiting the unstudied 2021 regional cap reform with a multi-pronged design (multi-cutoff bunching, temporal DiD, spatial RDD) providing internal replication across 9 thresholds and borders; universe-scale PPD data ensures high power and precise elasticities on subsidy limits, directly informing housing policy design.
- **Concerns**: Short post-reform window (2021–2023) risks underpowered long-run dynamics; spatial RDD at borders may suffer from sorting or spillovers if buyers cross regions strategically.
- **Novelty Assessment**: High—uniform cap well-studied (Carozzi et al. 2024), but no existing work on the 9 regional caps or their multi-cutoff/spatial designs.
- **Top-Journal Potential**: High—creates a new "object" (regional cap bunching with replication) and causal chain (cap → bunching → missing mass/prices), challenging subsidy design wisdom in a first-order housing market with clear welfare implications (e.g., deadweight loss bounds); mirrors Best & Kleven (2018) successes but extends to multi-threshold replication on universe data.
- **Identification Concerns**: Strong pre-trends testable via uniform cap era; placebos (second-hand, unchanged London) mitigate, but border RDD needs density tests for manipulation and spillovers.
- **Recommendation**: PURSUE (conditional on: robust border bandwidth selection and mechanism tests like developer pricing responses)

**#2: Flood Risk, Insurance Subsidies, and Property Values — A Spatial Regression Discontinuity at England's Flood Zone Boundaries**
- **Score**: 68/100
- **Strengths**: Novel spatial RDD at flood boundaries with Flood Re shock enables mechanism decomposition (insurance costs vs. risk perception), leveraging geocoded universe PPD for climate-relevant capitalization estimates.
- **Concerns**: Postcode-level measurement error (~15 households) biases boundary estimates; GIS intensity risks implementation hurdles, and complex polygons may violate RDD continuity assumptions.
- **Novelty Assessment**: Medium-high—no UK spatial RDD papers, though hedonic capitalization exists (Beltran et al. 2018/19); Flood Re eligibility adds fresh angle absent in US FEMA work.
- **Top-Journal Potential**: Medium—compelling chain (zone → insurance/risk → prices) with policy stakes (Flood Re welfare), but niche unless framed as broader climate adaptation test; spatial RDDs often critiqued for confounders (Keele & Titiunik), lacking the "belief-changing pivot" of top winners.
- **Identification Concerns**: Spatial sorting or endogenous development near boundaries threatens exogeneity; Flood Re DiD needs strong pre-2016 trends, and Zone 1/2 placebo may not fully validate.
- **Recommendation**: CONSIDER (conditional on: simulation-based measurement error correction; high-powered pre/post balance tests)

**#3: Stamp Duty Holidays and Housing Market Dynamics — Temporal RDD at the 2021 Cliff Edge**
- **Score**: 54/100
- **Strengths**: Massive sample (~850K txns) and multiple deadlines enable precise bunching/ATE on tax response; phased "dosage" adds some design value.
- **Concerns**: Heavy COVID confounds (market boom) invalidate parallel trends; extensive prior SDLT literature diminishes marginal value.
- **Novelty Assessment**: Low—SDLT notches/bunching heavily studied (Best & Kleven 2018; Besley et al. 2014); COVID phase-down gets some press but no rigorous advance.
- **Top-Journal Potential**: Low—standard temporal RDD/bunching on familiar tax holiday yields "competent but unsurprising ATE" without mechanism chain or welfare pivot; appendix patterns flag this as modal loss (narrow outcome, no new object amid confounds).
- **Identification Concerns**: No pre-treatment for COVID-era trends (pandemic distortions); anticipation/pull-forward biases temporal RDD without strong event-study validation.
- **Recommendation**: SKIP

### Summary
This is a strong batch overall, with Idea 1 standing out as genuinely top-journal caliber due to its novel multi-design on a recent reform and universe data enabling definitive subsidy estimates—pursue it first. Idea 2 has solid mechanism potential but spatial pitfalls drop it; Idea 3 is competently identified but crowded and confounded, fitting "technically sound but unexciting." Prioritize housing subsidies over flood or tax notches for policy impact.

