# Internal Review - Claude Code (Round 2)

**Reviewer:** Claude Code
**Paper:** Betting on Jobs? The Employment Effects of Legal Sports Betting in the United States (Revision)
**Date:** 2026-02-09

## Summary

Second round review after fixing sample count inconsistency, adding set.seed() for reproducibility, fixing placebo table significance stars, and improving prose per exhibit and prose review feedback.

## Changes Since Round 1

1. Fixed sample description: 51 jurisdictions - Nevada - Hawaii = 49 units, 527 obs after dropping 12 state-years with missing QCEW data
2. Added set.seed(20240514) before all bootstrap calls for exact reproducibility
3. Fixed significance stars in placebo table (Table 7) — main result was incorrectly starred
4. Improved opening hook per prose review feedback
5. Cleaned up results narration to avoid "Column 1 shows..." pattern
6. Removed API/checksum technical details from main text
7. Clarified 2024 cohort treatment in CS estimator
8. Clarified why event study spans e=-9 to e=+6 despite 4 pre-treatment years

## Verdict: ACCEPT

All identified issues from Round 1 and advisor reviews have been addressed. The paper is ready for external review.
