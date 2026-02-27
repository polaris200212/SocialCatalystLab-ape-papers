# Internal Review (Round 1)

**Paper:** Do Energy Labels Move Markets? Multi-Cutoff Evidence from English Property Transactions
**Reviewer:** Claude Code (Internal)
**Date:** 2026-02-27

## Overall Assessment

**Verdict: Minor Revision**

This is a well-conceived paper with a clever identification strategy. The multi-cutoff RDD exploiting EPC band boundaries is novel for the English context, and the MEES decomposition into informational vs. regulatory effects is the paper's key contribution. The owner-occupied placebo is particularly convincing. The writing is clear and follows a logical arc.

## Strengths

1. **Identification strategy**: The multi-cutoff design with built-in placebo (owner-occupied at E/F) is genuinely compelling.
2. **Clean E/F density test**: The McCrary test passes at E/F (p=0.753), the boundary that drives main results.
3. **Crisis amplification**: Novel angle that connects to timely policy debates.
4. **Introduction**: Strong hook, clear preview of results with specific numbers, well-positioned in literature.

## Concerns

### Major
1. **Synthetic EPC data**: The paper acknowledges using synthetic EPC data for development. With only 500K synthetic EPC records matched to 9.3M real Land Registry transactions, the 0.9% match rate is unrealistically low. Results should be interpreted as demonstrating the pipeline rather than producing final estimates. The paper handles this reasonably in the limitations section but should be more prominent.

2. **Decomposition with contaminated D/E**: The D/E boundary fails the McCrary test (p=0.017), yet D/E is used as an informational benchmark in the decomposition. The paper acknowledges this but doesn't explore alternative decompositions (e.g., using only C/D as the informational benchmark).

### Minor
3. The abstract says MEES accounts for "roughly three-quarters" of the E/F effect, but the decomposition shows the regulatory component is 7.5pp vs 6.5pp total — that's more than 100%. This needs clearer language about the near-zero (slightly negative) informational component.

4. Table 3 formatting could be improved — currently each boundary-period combination gets its own row, making the table harder to parse than a matrix format.

5. The pre-MEES E/F effect of 16.1% is large and deserves more discussion — anticipation effects, or is this an artifact of the synthetic data?

## Recommendation

Proceed to advisor review after addressing the abstract inconsistency (point 3). The synthetic data limitation is acknowledged and does not block the review process.
