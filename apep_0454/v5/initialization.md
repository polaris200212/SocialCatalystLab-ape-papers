# Human Initialization
Timestamp: 2026-02-26T14:00:00Z

## Contributor (Immutable)

**GitHub User:** @SocialCatalystLab

This field is captured at initialization and MUST match at publish time.

## System Information

- **Claude Model:** claude-opus-4-6

## Revision Information

**Parent Paper:** apep_0454 (v2)
**Parent Title:** The Depleted Safety Net: Pre-COVID Provider Exits, Pandemic Service Disruption, and the Effectiveness of Federal HCBS Investment
**Parent Decision:** MAJOR REVISION (all three v2 referees)
**Revision Rationale:** Address the unified concern about mechanical pre-trends from the treatment definition (theta_s constructed from 2018-2019 exits). Add HonestDiD sensitivity bounds, conditional RI, augsynth robustness, exit timing validation, and Anderson-Rubin CI. Rewrite abstract and introduction to Shleifer-level quality with hysteresis framing.

## Key Changes Planned

1. HonestDiD sensitivity bounds (Rambachan & Roth 2023) for pre-trend violations
2. Conditional randomization inference within Census divisions (5,000 perms)
3. Augmented synthetic control with binarized treatment (Ben-Michael et al. 2021)
4. Exit timing validation (McCrary-style bunching test at Feb 2020)
5. Anderson-Rubin weak-IV confidence set
6. Complete rewrite of abstract and introduction (Shleifer-level)
7. Hysteresis framing (Blanchard & Summers 1986, Yagan 2019, Hirschman 1970)
8. Recalibrated causal claims throughout (predictive, not causal)
9. Wild cluster bootstrap for providers and beneficiaries

## Original Reviewer Concerns Being Addressed

1. **All three v2 referees:** Mechanical pre-trends from treatment definition → HonestDiD, conditional RI, augsynth
2. **All three v2 referees:** Broken-trend spec nullifies main effect → Honest acknowledgment, sensitivity bounds
3. **User directive:** Introduction and abstract lack Shleifer-level quality → Complete rewrite with conceptual hook

## Inherited from Parent

- Research question: Same (pre-COVID exits predict pandemic-era HCBS disruption)
- Identification strategy: Same base DiD, enhanced with robustness battery
- Primary data source: T-MSIS Medicaid Provider Spending (2018-2024)
