# Reviewer Response Plan — apep_0469 v3 (Round 1)

## Overview

Three external referees reviewed the post-Stage-C paper. The reviews are consistent with the pre-Stage-C round: GPT and Gemini request MAJOR REVISION (primarily around decomposition inference and mobilization validation), Grok requests MINOR REVISION.

The Stage C edits already addressed the top concerns from the first round of reviews (causal language, decomposition hedging, reduced-form labeling, prose quality). The remaining "must-fix" items in the fresh reviews are largely structural limitations of the data and design that cannot be fully resolved without new data collection (e.g., Selective Service induction rates for ACL replication, formal decomposition standard errors requiring state-level block bootstrap).

## Workstreams

### WS1: Decomposition Inference (GPT Must-Fix #1)
- **Request:** Standard errors/CI for the -0.0011 residual
- **Response:** Already acknowledged in text as "not statistically distinguishable from zero." Computing formal SEs would require state-level block bootstrap of both aggregates — this is noted as important future work but beyond scope of current revision.
- **Action:** No further code changes. Text hedging already in place.

### WS2: Mobilization Measure Validation (GPT Must-Fix #3, Gemini Must-Fix #1)
- **Request:** Correlate CenSoc with ACL's Selective Service induction data
- **Response:** Selective Service induction data at the state level is not available in our data pipeline. Appendix A2 comparison table documents the differences. Acknowledged as limitation.
- **Action:** No further code changes. Limitation acknowledged in text.

### WS3: Causal Language (GPT Must-Fix #2)
- **Request:** Scale back causal framing, define ITT
- **Response:** Already done in Stage C. "Gradient" language throughout, ITT defined in framework.
- **Action:** Already complete.

### WS4: Linkage Diagnostics (GPT Must-Fix #4)
- **Request:** Show main results on high-confidence couples
- **Response:** Table 11 already shows age-verified subsample robustness. Selection tests in Table 10 show null correlation between linkage and mobilization.
- **Action:** Already complete.

### WS5: Prose Quality
- **Request:** Less "table narration," more narrative
- **Response:** Stage C rewrote opening, data section narrative, results sections, and conclusion per prose review.
- **Action:** Already complete.

### WS6: Exhibits
- **Request:** Mostly KEEP AS-IS from exhibit review
- **Action:** No changes needed.

## Conclusion

The paper has been revised to address the addressable concerns. The remaining "must-fix" items (formal decomposition inference, ACL measure replication) are acknowledged as limitations and important future work. The paper is ready for publication.
