# Internal Review — Round 1

## Identification and Empirical Design

The DDD design is well-motivated: state expansion timing x provider Medicaid dependence x time. The third difference within state-time cells is a genuine strength, absorbing state-level confounders that would bias a simple DiD. The 7-state treatment group and 10-state control provide reasonable geographic variation, though the few-cluster problem is real.

**Key weakness:** The RI p-value of 0.342 and the smaller CS-DiD ATT (0.0014, insignificant) represent a serious challenge to the TWFE result. The paper handles this honestly, which is commendable, but the tension remains.

## Inference and Statistical Validity

- State-clustered SEs are standard but potentially unreliable with 17 clusters
- RI with 199 permutations is appropriate and correctly implemented
- The HonestDiD sensitivity analysis adds value
- Singleton removal footnotes are now clear

## Robustness

LOO analysis (0.0033-0.0045) shows stability. The placebo test on Q1 providers is appropriate. The RI and CS-DiD results are the most informative robustness checks and both fail to confirm the main result.

## Contribution

Novel data construction (T-MSIS x FEC linkage) is genuinely new. The supply-side policy feedback angle is underexplored. Literature positioning is good with 14 intro citations.

## Results Interpretation

The paper appropriately calibrates claims as "suggestive" given the RI result. The magnitude (0.30pp on a 1.5% base = 20%) is economically meaningful if true.

## Actionable Revision Requests

1. **Must-fix:** None remaining after 12 advisor rounds
2. **High-value:** Scale Table 3 coefficients to percentage points (exhibit review suggestion)
3. **Optional:** Add geographic map of treatment/control states

## Overall Assessment

- **Strengths:** Novel data linkage, honest reporting of conflicting inference, rigorous DDD design
- **Weaknesses:** Few-cluster inference limits power, suggestive rather than definitive results
- **Publishability:** Suitable for AEJ:EP or equivalent with the current level of honesty about limitations

DECISION: MINOR REVISION
