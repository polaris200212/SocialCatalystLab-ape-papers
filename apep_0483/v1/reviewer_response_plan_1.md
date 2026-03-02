# Reviewer Response Plan - Round 1

## Common Concerns (all 3 reviewers)

### 1. Placebo Failure (CRITICAL)
All reviewers flag the 2005-2010 placebo (-1.12, p=0.101) as nearly identical to the main effect.
**Response:** Acknowledge more prominently. This is a genuine limitation. We will:
- Mention the placebo concern in the introduction
- Frame the result explicitly as an association, not a causal effect
- Add language that the DR cannot distinguish from persistent structural differences

### 2. No Pre-Treatment Outcomes (CRITICAL)
KS4 only available from 2018/19.
**Response:** Try to fetch historical KS4 data (% 5+ A*-C) from DfE archives. If available, add a trends analysis.

### 3. Regional Fragility
Excluding Unitary authorities flips sign.
**Response:** Already documented. Add more explicit discussion of what this means for interpretation.

### 4. Estimator-Dependent Significance
RF-AIPW p=0.037 but OLS p=0.233, RI p=0.236.
**Response:** Implement cross-fitted AIPW (DML-style) with K-fold. Report all inference strategies transparently.

### 5. Thin Covariates
Only baseline pay + urban proxy.
**Response:** Try to fetch additional baseline covariates (IMD deprivation scores, FSM share, academy share) from public APIs.

## Prose Workstream
- Soften all causal language throughout
- Reframe the paper as documenting an association with honest treatment of limitations
- Improve results narration per prose review feedback

## Exhibits Workstream
- Add significance stars (already done)
- No other exhibit changes flagged as critical

## Execution Order
1. Try to fetch historical KS4 + additional covariates
2. Implement cross-fitted AIPW
3. Cluster SEs at region level
4. Rewrite language throughout
5. Recompile and QA
