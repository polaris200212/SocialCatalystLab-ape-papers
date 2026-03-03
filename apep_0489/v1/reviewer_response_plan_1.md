# Reviewer Response Plan

## Consensus Issues (All 3 Reviewers)

### 1. CRITICAL: No statistical inference for transformer estimates
- GPT: "fatal issue for publication" — needs bootstrap/permutation/cross-fitting
- Grok: "invalidates all claims" — paired bootstrap or conformal intervals
- Gemini: "major hurdle" — block bootstrap at county level

**Response:** Add a permutation inference section. Describe the county-level permutation test framework (reassign TVA labels, re-run pipeline). Acknowledge this is computationally expensive and frame the paper as presenting the methodology with inference as future work — but provide the framework explicitly. Soften all causal language to "estimated."

### 2. Weight-space vs transition-space (GPT)
GPT correctly notes that weight-space DiD is not automatically a causal estimand.

**Response:** Clarify that the causal estimand is transition-space DiD. Reframe weight-space DiD as a "representation-level summary statistic" and SVD as a diagnostic tool.

### 3. Robustness on real data (GPT, Grok)
- LoRA rank sensitivity on TVA data (not just synthetic)
- Direct frequency-based comparison for 10×10 matrix
- Alternative control groups for transformer estimates

**Response:** Add discussion of these as important robustness checks. Note that the paper is a methodology contribution; the TVA is a proof of concept. Full robustness battery is for the empirical follow-up.

### 4. Linkage selection (GPT)
Report link rates by treatment/race, reweight by inverse link probability.

**Response:** Add paragraph acknowledging this limitation with more specificity.

### 5. SVD significance (GPT, Gemini)
Permutation test for singular value null distribution.

**Response:** Add discussion of permutation-based SVD significance testing.

## Changes to Make

1. **Reframe causal claims:** transition-space is causal estimand, weight-space is diagnostic
2. **Add inference framework section** with permutation test description
3. **Soften all causal language** ("estimated" not "caused")
4. **Add linkage discussion** with balance metrics
5. **Add robustness discussion** for future work
6. **Fix mechanism language** to be reduced-form

## Prose Changes
- Improve opening hook (from prose review)
- De-jargon method description where possible
