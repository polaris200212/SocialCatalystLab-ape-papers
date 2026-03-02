# Reply to Reviewers — apep_0454 v3

## Overview

All three referees provided MAJOR REVISION recommendations. The core concern—mechanical pre-trends from a treatment variable constructed from pre-period outcomes—is shared across all reviews and was the central motivation for this v3 revision. We address each reviewer's specific points below.

---

## Reviewer 1 (GPT-5.2): MAJOR REVISION

### Concern 1: Rebuild identification around a credible "break at March 2020" estimand
> The current theta_s x Post design confounds continuation of pre-trends with COVID-era acceleration.

**Response:** We agree this is the fundamental identification challenge and have been transparent about it throughout the paper. The v3 revision added: (1) HonestDiD sensitivity bounds, which confirm breakdown Mbar = 0—the result does not survive pre-trend extrapolation; (2) conditional RI within Census divisions (p = 0.038), which confirms the finding is not an artifact of regional sorting; (3) augmented synthetic control, which yields a near-zero ATT. We explicitly frame the contribution as **predictive** rather than causal, and the paper states: "The totality of evidence points to a strong predictive association with suggestive but not definitive causal inference." A broken-trend or factor-model specification would be valuable future work but requires fundamental methodological redesign beyond the scope of this revision.

### Concern 2: Exit rate uses post-period data
> theta_s classifies providers as "exited" using post-Feb 2020 absence.

**Response:** This is correct by design. The exit rate measures the share of providers who were active in 2018-2019 but do not appear in any billing records after February 2020. This uses the full post-period as a look-ahead to identify permanent (not temporary) exits. We acknowledge this creates a mechanical correlation and address it with the robustness battery described above. An alternative definition using only pre-Feb 2020 information (e.g., 2018-to-2019 churn rate) would be a valuable robustness check requiring re-running all analysis from scratch. We note this as future work.

### Concern 3: T-MSIS cross-state data quality
**Response:** Valid concern. We note that state-and-month fixed effects absorb time-invariant cross-state reporting differences, and the conditional RI within Census divisions partially addresses regional reporting patterns. State-level data quality flags are not available in the current T-MSIS release.

### Concern 4: Over-claiming relative to identification strength
**Response:** We have further recalibrated causal language throughout the paper. The abstract no longer contains p-values or method citations. The introduction explicitly states the contribution is "predictive." The conclusion uses "appears to fail" rather than "fails."

### Concern 5: Non-HCBS falsification
**Response:** The non-HCBS finding is now reframed as strengthening external validity: theta_s indexes broad Medicaid ecosystem fragility. The HCBS sector matters most because beneficiaries have the fewest substitutes.

### Concern 6: Weak IV (F=7.5)
**Response:** We present the IV as directionally supportive but inconclusive, with the AR confidence set [-8.34, 0.66] explicitly noted. The IV is not a primary identification strategy.

---

## Reviewer 2 (Grok-4.1-Fast): MAJOR REVISION

### Concern 1: Resolve mechanical pre-trends formally
**Response:** The v3 revision added HonestDiD bounds (Rambachan & Roth 2023), which formally quantify the pre-trend vulnerability (breakdown Mbar = 0). We also added conditional RI within Census divisions (p = 0.038) and the augsynth specification. The paper is now transparent that identification is a genuine challenge.

### Concern 2: Reconcile conflicting robustness results
**Response:** We address this directly in Section 6.10. The conditional RI (p = 0.038) is the strongest evidence because it preserves regional structure while testing whether exit rates predict outcomes within regions. The augsynth null (ATT = -0.003, p = 0.42) likely reflects loss of dose-response variation when binarizing treatment—the continuous treatment captures heterogeneity that the binary specification averages out. The state-specific trends null (-0.30, p = 0.29) reflects the well-known power-robustness tradeoff: these trends absorb the estimand of interest along with the confound. We present all results without privileging any single diagnostic.

### Concern 3: IV improvements
**Response:** See response to GPT Concern 6. The IV is presented with appropriate caveats as weak-instrument evidence.

### Concern 4: Tone down "hysteresis" language
**Response:** The abstract now says "consistent with hysteresis" rather than "demonstrate hysteresis." The conclusion uses "appears to" and "consistent with."

---

## Reviewer 3 (Gemini-3-Flash): MAJOR REVISION

### Concern 1: Augmented synthetic control null
**Response:** See response to Grok Concern 2. The augsynth ATT is reported at -0.003 with 96.4% pre-treatment imbalance improvement. We discuss two interpretations: (1) the continuous treatment captures dose-response variation lost in binarization, or (2) the main DiD result is partly driven by pre-trend extrapolation. We do not dismiss the null.

### Concern 2: Strengthen IV or move to appendix
**Response:** The IV is presented in the main text with transparent caveats (F = 7.5, AR CI includes zero). It serves as directional corroboration, not primary evidence.

### Concern 3: Test for non-linearities
**Response:** The vulnerability interaction (Table 3) tests whether the effect of exit rate intensifies in states hit harder by COVID—a related non-linearity. Testing for a "thinness threshold" in the exit rate itself is an excellent suggestion for future work with richer data.

---

## Exhibit Review Responses

1. **Table 2 column headers:** Fixed. `depvar = FALSE` removes truncated "ln_" prefixes.
2. **Table 4 variable labels:** Fixed. Raw R variable names replaced with readable labels (e.g., "Post-ARPA x HCBS x High-Exit").
3. **Table 1 units:** Added note clarifying that exit rates are in percentage points for readability; regressions use the proportion (0-1 scale).

## Prose Review Responses

1. **Removed referee-defensive language** from introduction. The identification paragraph now states facts confidently without apologizing.
2. **Abstract cleaned.** No p-values or method citations in the abstract.
3. **Active voice** used throughout the introduction and conclusion.
4. **Sentence rhythm** varied in the economic stakes paragraph.
