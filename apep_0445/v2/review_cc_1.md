# Internal Claude Code Review — Round 1

**Paper:** APEP-0445 v2
**Date:** 2026-02-23

## Summary

This is a revision of APEP-0445 v1 addressing reviewer concerns about OZ data approximation, missing first-stage analysis, placebo testing, and inference robustness.

## Key Findings

### Strengths
1. **Official CDFI data integration:** Replaced the poverty-rank approximation with actual CDFI designated OZ list (8,764 tracts). First-stage F=31.7 is strong.
2. **Comprehensive robustness:** Systematic placebo grid (26 cutoffs, 0/26 significant), local randomization inference (all p > 0.28), county-clustered SEs, covariate-adjusted rdrobust.
3. **Infrastructure heterogeneity:** Direct test using ACS broadband data. Null persists across all quartiles — empirical evidence for infrastructure-dominance mechanism.
4. **Fuzzy RDD Wald estimates:** Now reported explicitly, complementing the reduced-form ITT.

### Issues Identified and Fixed
1. **Internal consistency errors:** Multiple text-table mismatches (OZ rate 0.5% vs 11.1%, N=11,046 vs 8,331, incorrect parenthetical N values). All corrected.
2. **McCrary t-statistic mismatch:** Text said 4.46, figure showed 5.03. Fixed to 5.03.
3. **Missing figure files:** fig8b and fig9 had wrong filenames in LaTeX. Fixed.
4. **Table 5 formatting:** Duplicate header row with raw variable names removed.
5. **Missing set.seed():** Added for rdrandinf reproducibility.
6. **Citation date error:** "QOF investment through 2025" from 2023 report. Fixed.

### Remaining Limitations (Not Fixable)
- NAICS 51 is a noisy proxy for data center employment (2-digit includes telecom, publishing, etc.)
- Compound treatment at 20% threshold (OZ + NMTC + other LIC programs)
- Local estimand at poverty margin may not generalize to all tract poverty levels

## Verdict

Paper is ready for external review and publication. All fixable issues addressed. Remaining limitations are transparently discussed and inherent to the research design.
