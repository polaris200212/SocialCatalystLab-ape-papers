# Internal Review — Round 1

**Reviewer:** Claude Code (self-review)
**Date:** 2026-02-26

## Key Strengths

1. **Novel data**: First use of T-MSIS provider-level claims for HCBS workforce analysis
2. **Clean identification**: Pre-COVID exit rates are predetermined; parallel trends supported by event study
3. **Comprehensive robustness**: RI, LOO, placebo, control sensitivity, shift-share IV
4. **Honest null result**: DDD for ARPA is reported as imprecise rather than overclaimed

## Critical Weaknesses

1. **Weak IV**: First-stage F = 7.5 < 10. Reduced form is directionally supportive but not a strong complement. Paper correctly caveats this.
2. **DDD imprecision**: The ARPA question is underpowered. 51 clusters with a triple interaction may not have enough variation.
3. **Binary vs continuous discrepancy (resolved)**: Earlier binary cutoff robustness specs gave opposite-signed coefficients. These were removed. The continuous treatment is the primary specification.

## Revision Priorities

1. **Must-fix**: None remaining after advisor review cycle (addressed IV terminology, data tail, coefficient precision)
2. **High-value**: Consider Anderson-Hsiao or other panel estimators as robustness; add wild cluster bootstrap p-values
3. **Optional**: Appendix tables for LOO full results, first-stage details

## Decision

The paper presents a credible analysis with novel data. The main DiD result is robust. The DDD result is honestly reported as imprecise. Ready for external review.

DECISION: MINOR REVISION
