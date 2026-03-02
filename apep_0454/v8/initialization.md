# Human Initialization
Timestamp: 2026-02-26T20:30:00Z

## Contributor (Immutable)

**GitHub User:** @SocialCatalystLab

## System Information

- **Claude Model:** claude-opus-4-6

## Revision Information

**Parent Paper:** apep_0454
**Parent Title:** The Depleted Safety Net: Provider Attrition and Medicaid's Pandemic-Era Disruption
**Parent Decision:** MAJOR REVISION (all 3 referees)
**Revision Rationale:** Address referee demands for new analysis: (1) purely pre-treatment exit rate, (2) broken-trend model, (3) collapsed cross-sectional regression, (4) alternative RI stratifications, (5) entity-type heterogeneity, (6) data truncation at June 2024.

## Key Changes (v8 Analytical Revision)

- WS1: Pre-period exit rate (2018 active, absent in 2019) replacing pandemic-contaminated measure
- WS2: Data truncation at June 2024 to avoid reporting lags
- WS3: Broken-trend model (lambda/beta/kappa specification) — key new test
- WS4: Collapsed cross-sectional regression (N=51, HC2/HC3 SEs)
- WS5: Alternative RI stratifications (Census regions, urbanicity, governor party)
- WS6: Entity-type heterogeneity (NPI Type 1 vs Type 2)
- Paper.tex updated with new results, including sign reversal acknowledgment
- New figures (10-13) and tables (7-8) for all new analyses

## Key Findings

The pre-period exit rate fundamentally changes the results:
- Static DiD: +0.614 (SE 1.040, p = 0.56) — null
- Broken-trend: lambda = -0.029 (p=0.025), beta = 0.049 (p=0.92), kappa = 0.033 (p=0.024)
- Collapsed regression: +0.614, HC2 p=0.619
- Legacy (pandemic-contaminated) exit rate: -0.844 (SE 0.343, p=0.017) — significant
- The discrepancy reveals post-treatment contamination in the original measure

## Inherited from Parent

- Research question: Does pre-pandemic HCBS provider attrition predict pandemic-era disruption?
- Identification strategy: Continuous-treatment DiD + broken-trend model (revised)
- Primary data source: T-MSIS Medicaid Provider Spending (2018-2024)
