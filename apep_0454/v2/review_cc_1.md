# Internal Review: apep_0454 v2
**Date:** 2026-02-26
**Reviewer:** Claude Code (internal)

## Verdict: MINOR REVISION

## Summary

This is a substantial revision of apep_0454 v1 ("The Depleted Safety Net") that addresses the two primary weaknesses of the original: (1) the "so what?" problem — v1 documented provider exits but never showed consequences for beneficiaries, and (2) the bad control problem — COVID deaths are partly a mediator, not just a confounder.

## Strengths

1. **Beneficiary outcomes are the key addition.** The finding that a 1-SD increase in exit intensity is associated with a 7% decline in beneficiaries served (coefficient -1.005, p=0.038) directly answers the "so what?" question. This is the most important contribution of the revision.

2. **Mediation analysis is well-executed.** Showing that adding COVID deaths barely attenuates the main coefficient (-0.879 → -0.876) is very informative. The DAG discussion in Section 5.4 is a genuine contribution to the methodology.

3. **Vulnerability interaction (Table 3) is novel.** The significant interaction for claims/beneficiary (-0.0021, p=0.035) provides a mechanism story: depleted networks amplified COVID's damage on the intensive margin.

4. **Robustness expanded.** 2,000 RI permutations (up from 500), RI for beneficiary outcomes, non-HCBS falsification, truncated sample test.

## Concerns

1. **Pre-trend F-test (F=6.67, p<0.001).** The joint test rejects, driven by far pre-period coefficients. The paper handles this honestly (Section 6.7) by noting that near-treatment coefficients are close to zero. But reviewers may flag this as problematic.

2. **RI p-value for beneficiaries (0.108).** The parametric test gives p=0.038 but RI gives 0.108. This discrepancy should be acknowledged — the beneficiary result is significant at conventional levels but fragile under permutation-based inference.

3. **Claims/bene and spending/bene are null.** The intensive margin results are driven entirely by the vulnerability interaction, not the main specification. This limits the "compounding harm" interpretation.

4. **Non-HCBS coefficient (-1.376) larger than HCBS (-0.879).** The paper reframes this but doesn't fully resolve why the supposedly HCBS-specific mechanism has a larger effect on non-HCBS providers.

## Recommendations

- Minor prose improvements needed (transitions between new sections)
- Consider acknowledging the RI/parametric discrepancy for beneficiary results more explicitly
- The paper is ready for external review
