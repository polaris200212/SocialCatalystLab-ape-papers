# Revision Plan 1 — Stage C Response to Referee Feedback

## Referee Decisions
- GPT-5.2: MAJOR REVISION
- Grok-4.1-Fast: MAJOR REVISION
- Gemini-3-Flash: MAJOR REVISION

## Common Concerns (All 3 Referees)
1. **WCB p=0.377** — inference validity for network coefficient
2. **SCI 2024 vintage** — post-treatment network measurement
3. **Structural overclaim** — SAR/SEM observational equivalence

## Changes Made

### 1. SCI Vintage Limitation (GPT, Gemini)
- Added explicit limitation discussion in Appendix (Identification section)
- Three mitigating arguments: SCI stability, pre-treatment event study, Facebook maturity by 2012
- Updated data appendix to flag the vintage concern

### 2. Event Study Equation (GPT)
- Updated Equation 9 to include both Own × event-time and Net × event-time interactions
- Matches actual estimation shown in Figure 3

### 3. Effective N / Moulton Problem (GPT)
- Added "Effective sample size" paragraph in Section 5.1
- Points to dept-level regressions (N=960) as complementary analysis

### 4. Structural Counterfactuals (GPT, Gemini)
- Completely reframed Section 7.3 as "upper bounds under SAR interpretation"
- Added explicit caveat: under SEM, network contribution would be smaller
- Presented 11pp counterfactual as range (0 to 11)

### 5. Joint Pre-Trend Test (GPT, Grok)
- Added formal statement: joint F-test fails to reject (p > 0.10)

### 6. WCB Code Verification (All)
- Added explicit statement that same code produces p=0.015 for own-exposure
- Strengthened explanation of low between-cluster variation mechanism

## Not Addressed (Future Work)
- AKM (2019) shift-share robust standard errors
- Distance-bin decomposition beyond 200km cutoff
- Survey/attitudinal mechanism data
- Facebook penetration heterogeneity test
- Spatial bootstrap for N=96 structural models
