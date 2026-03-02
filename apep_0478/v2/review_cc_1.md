# Internal Review (Claude Code Self-Review)

**Paper:** Going Up Alone: Automation, Trust, and the Disappearance of the Elevator Operator
**Version:** v2 (revision of apep_0478 v1)
**Reviewer:** Claude Code (internal)
**Date:** 2026-02-28

---

## 1. RESEARCH DESIGN

**Strengths:**
- Multi-method approach (descriptive panel + SCM + event study + triple-diff) provides converging evidence
- 38,562 linked elevator operators via MLP v2.0 crosswalk is a large sample for historical analysis
- IPW correction for linkage selection bias strengthens causal claims
- Comparison group (building service workers) is well-motivated and structurally similar

**Weaknesses:**
- Pre-trends in event study are significant, which the paper now honestly acknowledges. The SCM approach is presented as the more appropriate alternative.
- State-level analysis uses New York State as a proxy for NYC, which introduces measurement error

## 2. IDENTIFICATION STRATEGY

- DiD framework with elevator operators vs. building service workers is credible
- SCM for state-level analysis with 18 donor states is well-specified
- Triple difference (elevator × NY × post-1945) provides additional robustness
- Exclusion of janitors from comparison group tested as robustness check

## 3. STATISTICAL RIGOR

- Standard errors appropriately clustered by state in regressions
- Permutation inference for SCM (p = 0.056) provides distribution-free testing
- IPW addresses linkage selection; weights trimmed at 99th percentile
- Logit model for selection into persistence is well-specified with AMEs

## 4. DATA AND REPRODUCIBILITY

- All data from IPUMS Full-Count Census + MLP v2.0 (documented sources)
- R scripts numbered 00-06 with clear pipeline
- Azure data connection for large crosswalk files
- Tables and figures generated from code, not hand-constructed

## 5. RESULTS INTERPRETATION

- Abstract and text now accurately reflect coefficient signs and magnitudes
- Selection logit interpretation corrected (Black coefficient insignificant, Native-born significant)
- OCCSCORE interpretation correctly distinguishes unweighted (imprecise) from IPW (significant)
- "Paradox of the Epicenter" well-supported by NYC persistence evidence

## 6. ACTIONABLE REVISION REQUESTS

1. **Minor:** Gemini noted 483,773 vs 38,562+445,000=483,562 discrepancy (211 persons). Text says "approximately 445,000" which is adequate but could be exact.
2. **Minor:** Consider adding a brief note reconciling peak 1950 headcount with 84% exit rate (replacement by new entrants).

## 7. OVERALL ASSESSMENT

**Key strengths:** Novel historical setting, large linked panel, multi-method convergence, honest engagement with limitations (pre-trends, null results)

**Critical weaknesses:** None remaining after 8 rounds of advisor review fixes

**Publishability:** Ready for external review

DECISION: MINOR REVISION
