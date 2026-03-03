# Reply to Reviewers — Round 1

## Response to GPT-5.2 (Major Revision)

### 1. Linear trends identification unvalidated
**Concern:** The causal claim rests on parametric linear trends without validation against more flexible methods.

**Response:** We added a quadratic trends specification (Table 4, Column 5), which yields a coefficient of +0.056 (p=0.31). The estimate lies between the linear-trend and naive estimates but is statistically insignificant. We acknowledge this sensitivity to functional form in the text (Section 6.4). We agree that synthetic DiD or interactive fixed effects would be stronger; however, with a single treatment date and binary/continuous cross-sectional treatment, the canonical synthetic control methods require panel-level pre-treatment matching that is feasible but computationally intensive. We leave this to future work and present our results as suggestive rather than definitive.

### 2. Universal Credit rollout as first-order confound
**Concern:** UC rollout is geographically staggered and mechanically changes claimant definitions.

**Response:** We substantially expanded the UC discussion in the Limitations section (Section 7.5), acknowledging UC as a first-order threat to identification. We note that authority-month UC rollout data is not publicly available at the required granularity. The pre-2020 subsample analysis (new Table 4, Column 6) partially addresses this by showing results are insignificant in the pre-COVID period, though UC was rolling out during 2013-2018.

### 3. Treatment measurement is expenditure-based and time-invariant
**Concern:** A single 2013 spending snapshot applied through 2023 conflates generosity and caseload.

**Response:** We acknowledge this limitation. The ideal treatment would use policy parameters (minimum payment rates, taper rules) by authority-year, but this granular data is not systematically available. The 2013 snapshot captures the initial policy choice, which is the source of quasi-experimental variation. Post-2013 changes to CTS schemes would attenuate the treatment contrast, biasing our estimates toward zero.

---

## Response to Grok-4.1-Fast (Minor Revision)

### 1. Pre-2020 results untabulated
**Concern:** COVID robustness claim was asserted but not shown.

**Response:** Fixed. We added pre-2020 subsample results (Table 4, Column 6; Section 6.4). The results are honestly reported: naive TWFE = -0.041 (p=0.26), trend-adjusted = +0.032 (p=0.40). Both are insignificant. This is now prominently discussed in the paper.

### 2. Sample attrition under-audited
**Concern:** 15% drop via fuzzy matching could introduce selection bias.

**Response:** We expanded the sample construction description (Section 4.4) to note that unmatched authorities are predominantly small district councils with naming differences, and that pre-reform claimant rates are similar across matched and unmatched authorities.

### 3. Non-monotonic dose-response
**Concern:** Moderate-cut group shows larger effect than most-cut group in trends specification.

**Response:** We investigated pre-reform trend slopes by tercile and found they are nearly identical across all three groups (~0.01 per month). The non-monotonicity thus does not appear driven by differential pre-trends. We acknowledge in Section 6.3 that the pattern "is consistent with the pre-existing trends confounding the naive estimates differently across terciles, rather than reflecting a true causal gradient." We consider this evidence against a clean causal interpretation.

---

## Response to Gemini-3-Flash (Major Revision)

### 1. Universal Credit rollout
**Response:** See response to GPT-5.2, point 2 above. Expanded UC discussion in Section 7.5.

### 2. Dose-response non-monotonicity
**Response:** See response to Grok-4.1-Fast, point 3 above.

### 3. Mechanism untested
**Concern:** Financial distress narrative lacks direct evidence.

**Response:** We agree this is a limitation. Authority-level council tax arrears data (published by DLUHC) could provide direct mechanism evidence. We note this as an avenue for future research (Section 7.3) and have been careful to label the mechanism discussion as "proposed channels" rather than established facts. We softened the back-of-envelope calculation in Section 7.1 to be clearly labeled as illustrative.

---

## Summary of Changes Made

1. **Pre-2020 subsample analysis** — Added to robustness table (Column 6) and discussed in Sections 5.4, 6.4, 7.1, and Conclusion
2. **Quadratic trends specification** — Added to robustness table (Column 5) and discussed in Section 6.4
3. **UC rollout discussion expanded** — Section 7.5 substantially rewritten
4. **Sample attrition** — Section 4.4 expanded
5. **Abstract revised** — Now reflects the nuanced finding (pre-2020 insignificance)
6. **Conclusion revised** — Replaces "wrong" with "unreliable"; acknowledges COVID dependence
7. **Discussion section revised** — More cautious framing of the sign reversal
8. **Donut and placebo N values corrected** — Fixed sample sizes to match code output
