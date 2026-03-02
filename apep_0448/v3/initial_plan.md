# Initial Plan (Revision of apep_0448 v2)

## Research Question (Inherited)
Does early termination of pandemic unemployment insurance benefits increase Medicaid HCBS provider supply?

## Identification Strategy (Inherited)
Callaway-Sant'Anna (2021) staggered DiD with never-treated comparison group. 26 treatment states, 25 control jurisdictions (including DC). Monthly state-level panel from T-MSIS Medicaid claims.

## Exposure Alignment

- **Who is actually treated:** Medicaid HCBS providers (billing T-codes and S-codes) in the 26 states that voluntarily terminated FPUC/PUA/PEUC benefits before the federal September 6, 2021 expiration date. Treatment occurs at the state-month level when the state's first full month of exposure begins (July 2021 for June terminators, August 2021 for July terminators).
- **Primary estimand population:** Low-wage direct care workers and home health aides whose market wages (~$12-14/hr) were below or near the effective UI benefit threshold (~$15/hr with the $300 FPUC supplement). These workers had the strongest labor supply incentive to remain on UI rather than return to Medicaid-reimbursed care work.
- **Placebo/control population:** Behavioral health (BH) providers billing H-codes in the same treated and control states. BH providers earn higher wages ($18-25/hr), well above the UI benefit threshold, so early UI termination should not differentially affect their labor supply. A null effect on BH providers supports the wage-competition mechanism.
- **Design:** Staggered DiD (Callaway-Sant'Anna 2021) as the primary estimator, with 25 never-treated jurisdictions (maintained benefits through September 6) as the comparison group. Triple-difference (HCBS vs BH × Early Terminator × Post) as robustness check exploiting within-state, across-service variation.

## Revision Objectives (v3)
1. Decompose provider effect by NPPES Entity Type 1 (individual) vs Type 2 (organization)
2. Increase CS-DiD RI permutations from 200 to 1,000
3. Fix factual error in Limitations claiming entity type data is unavailable
4. New results subsection, table, and figure for entity type decomposition

## What Does NOT Change
- Research question, identification strategy, data
- Main CS-DiD ATT estimates
- Behavioral health placebo
- Triple-difference
- Event study figures
- All other robustness checks
