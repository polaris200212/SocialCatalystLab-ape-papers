## Discovery
- **Policy chosen:** UK Flood Re reinsurance scheme (April 2016) — sharp construction-date eligibility cutoff (pre-2009) creates natural DDD within flood zones; 10-year post-period, massive sample
- **Ideas rejected:** UC→crime (d'Este & Harvey 2024 JLEO already published), Police funding cuts (only 43 clusters), ULEZ sorting (short post-period for outer London), PDR/Article 4 (data construction challenge for adoption dates)
- **Data source:** Land Registry PPD (24M+ transactions, bulk CSV) + EA Open Flood Risk by Postcode (postcode-level flood classification)
- **Key risk:** Post-2009 properties in flood zones may be compositionally different from pre-2009 stock (newer construction standards, different developers/buyers). Must show balance on observables and argue remaining differences are time-invariant (differenced out in DDD).

## Review
- **Advisor verdict:** 3 of 4 PASS (6 rounds — GPT persistently failed on eligibility proxy concern)
- **Referee verdict:** GPT: R&R, Grok: Major Revision, Gemini: Major Revision
- **Top criticism:** All three reviewers flagged the failing Very Low risk placebo (-0.134***) and pre-trends (p=0.011) as evidence that the DDD captures vintage depreciation, not Flood Re
- **Surprise feedback:** GPT argued the New Build flag measurement error is non-classical (correlated with market segment), meaning attenuation toward zero is not guaranteed — a more sophisticated point than expected
- **What changed:** Comprehensively recalibrated all claims from "precise null" to "evidence against large positive capitalization"; added placebo-adjusted bounds; expanded misclassification discussion with quantitative estimates; softened all policy conclusions; added missing literature

## Summary
- **Key lesson:** When placebo tests fail dramatically, the right response is transparent reframing, not defensive argumentation. The paper's value shifted from "null result" to "methodological demonstration + evidence against large effects"
- **What worked:** Massive dataset, novel DDD design, comprehensive robustness checks including HonestDiD
- **What didn't work:** New Build flag proxy is fundamentally limited; vintage depreciation in flood-classified areas dominates the insurance signal
- **Future direction:** True construction year data (EPC/VOA), micro premium data, repeat-sales design
