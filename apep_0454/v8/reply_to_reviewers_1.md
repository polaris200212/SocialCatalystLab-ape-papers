# Reply to Reviewers — apep_0454 v8

## Context

This revision was a text-only honest reframe: all causal/hysteresis claims were softened to predictive/descriptive framing. No new analysis was conducted. The reviews below address the v8 text.

---

## Referee 1 (GPT-5.2): MAJOR REVISION

### Must-fix 1: Commit to predictive vs. causal framing
**Response:** Addressed. This was the primary goal of the v8 revision. The title dropped "Hysteresis," abstract uses "I find" not "I show," the non-HCBS paragraph was reframed to acknowledge the exit rate indexes ecosystem fragility rather than an HCBS-specific mechanism, and a new robustness synthesis paragraph explicitly states the evidence supports "a strong predictive association... with suggestive but not definitive evidence of causal amplification."

### Must-fix 2: Redesign empirical strategy (broken-trend model)
**Response:** Acknowledged as important future work. A formal broken-trend model estimating the change in slope at March 2020 would strengthen the causal claim. This requires new analysis outside the scope of this text-only revision. The limitations section now explicitly states: "The strongest interpretation of this paper is predictive rather than causal."

### Must-fix 3: Fix HCBS classification to pre-period only
**Response:** Valid concern. Defining HCBS status from 2018-2019 billing only (locking classification before treatment) would address post-treatment endogeneity in the DDD. Deferred to a future analytical revision.

### Must-fix 4: Validate against reporting artifacts
**Response:** Partially addressed. The truncation robustness check (dropping last 6 months, coefficient virtually identical) provides some evidence against reporting-lag confounds. More thorough validation (alternative "active" thresholds, servicing NPI analysis, completeness measures) requires new code.

### High-value 5-9: Collapsed analysis, non-HCBS reframe, ARPA intensity, beneficiary precision, IV
**Response:** The non-HCBS reframe (item 6) was the centerpiece of this revision. Other items are deferred to future analytical revisions. The IV is appropriately caveated as "directionally supportive but inconclusive."

---

## Referee 2 (Grok-4.1-Fast): MAJOR REVISION

### Must-fix 1: Reframe core claim as predictive
**Response:** Done. See detailed changes above.

### Must-fix 2: Normalized effects consistently
**Response:** The 1SD interpretation appears in the abstract, results section, and magnitude interpretation paragraph. Minor inconsistencies across sections can be addressed in a polish pass.

### Must-fix 3: AR CI in main text
**Response:** The AR CI is reported in the formal sensitivity section (Section 6.8), which is in the main text. Its placement seems appropriate given the weak-instrument caveat.

### High-value: Deeper pre-trend decomposition, literature, provider heterogeneity
**Response:** Literature suggestions (McGinn, Ladd, Yamamoto) are noted for future revision. Pre-trend decomposition and provider heterogeneity require new analysis.

---

## Referee 3 (Gemini-3-Flash): MAJOR REVISION

### Must-fix: Broken-trend model
**Response:** Acknowledged. See response to GPT must-fix 2 above.

### High-value: Stronger IV, ARPA mechanism
**Response:** Both require new analysis. ARPA implementation heterogeneity data (CMS spending plans, Advancing States reports) would enable intensity variation — noted as a promising direction.

---

## Summary of Changes Made in This Revision

| Change | Status |
|--------|--------|
| Title: drop "Hysteresis" | Done |
| Abstract: "I find" not "I show" | Done |
| Non-HCBS paragraph: honest reframe | Done |
| Contribution paragraph: "I document" | Done |
| Robustness synthesis paragraph | Done |
| Discussion 7.1: "consistent with" not "signature of" | Done |
| Discussion 7.1: conditional hedging | Done |
| Discussion 7.2: "suggesting" not "implying" | Done |
| Limitations: predictive interpretation sentence | Done |
| Global "I show" → "I find"/"I document" | Done |

## Changes Deferred to Future Revision

| Change | Reason |
|--------|--------|
| Broken-trend model | Requires new R analysis |
| HCBS pre-period classification fix | Requires code change |
| Collapsed state-level analysis | Requires new R analysis |
| Reporting artifact validation | Requires new code |
| ARPA implementation heterogeneity | Requires external data collection |
| Additional literature citations | Can be added in next revision |
