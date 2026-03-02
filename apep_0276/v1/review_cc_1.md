# Internal Review (Claude Code) — Round 1

**Reviewer:** Claude Code (claude-opus-4-6)
**Date:** 2026-02-13
**Paper:** Registered but Not Voting: Felon Voting Rights Restoration and the Limits of Civic Re-Inclusion

## Summary

This paper tests whether restoring felon voting rights increases Black political participation beyond the directly affected population. Using staggered adoption across 22 US states (1996-2024) and CPS Voting Supplement data, the paper finds that restoration increases Black voter registration (+2.3 pp, p<0.001) but widens the Black-White turnout gap (-3.7 pp, p=0.015). A triple-difference using within-race felony risk variation finds no community-level spillovers.

## Strengths

1. **Important and novel question**: Shifting from direct effects to community spillovers is a genuine contribution
2. **Clean identification**: DD with state x year FE, CS estimator, DDD mechanism test, Hispanic placebo
3. **Surprising finding**: The registration-turnout divergence is the most interesting result and well-documented
4. **Methodological rigor**: Modern staggered DiD estimators (CS, Sun-Abraham), HonestDiD sensitivity
5. **Comprehensive robustness**: 10 robustness checks covering specification, sample, and estimator choices

## Weaknesses

1. **DD vs CS sign discrepancy**: The cell-level DD shows -3.7pp while CS shows +5.3pp — opposite signs require careful explanation
2. **Pre-trends noise**: The t=-2 event study coefficient is negative and moderately large
3. **Composition accounting**: The paper needs quantitative evidence that the composition channel can explain the observed patterns
4. **Table presentation**: Missing cluster counts, explicit confidence intervals

## Verdict

CONDITIONALLY ACCEPT — The paper presents an important finding with credible identification. The main concerns (DD/CS reconciliation, composition accounting, inference details) are addressable.
