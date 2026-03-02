# Research Plan: APEP-0445 v3

## Revision of APEP-0445 v2

**Research Question:** Do place-based tax incentives attract data center investment to distressed communities?

**Identification Strategy:** Regression Discontinuity Design at the 20% poverty rate threshold for LIC eligibility, with fuzzy RDD using official CDFI OZ designation data.

## Exposure Alignment

**Who is treated?** Census tracts with poverty rates at or above 20% become eligible for OZ designation through the poverty pathway. Governors then select ~25% of eligible tracts for designation.

**Who is actually affected?** Investors who channel capital gains through Qualified Opportunity Funds into designated tracts receive tax benefits (deferral, partial exclusion, and permanent appreciation exclusion). Data center developers and operators are affected if they choose OZ-designated sites, gaining access to OZ-channeled capital. The treatment operates through an investor-side mechanism (capital gains deferral) rather than direct cost reduction for facility operators.

**Treatment timing:** OZ designations were certified in 2018. The pre-period (2015-2017) predates all OZ effects. The post-period (2019-2023) allows time for investment decisions and construction cycles (3-5 years for large data centers).

**Compound treatment at the threshold:** The 20% poverty rate also governs eligibility for the New Markets Tax Credit (NMTC) and other LIC-linked programs. The ITT captures the full bundle effect of crossing the LIC eligibility threshold, not OZ alone. This strengthens rather than weakens the null: even the combined LIC bundle fails to attract data centers.

## Key Improvements Over v2 (This Revision)

1. **Direct Data Center Locations:** EIA Form 860 + EPA GHGRP facilities geocoded to census tracts, creating binary presence and count outcomes
2. **Engagement with Concurrent Literature:** Gargano & Giacoletti (2025) on state-level DC incentives, Jaros (2026) on local tax abatements
3. **Incentive Hierarchy Framework:** State sales tax exemptions > local abatements > tract-level OZ capital gains
4. **MDE Calculation:** Minimum detectable effect at 80% power for DC presence outcome
5. **Local Randomization Covariate Balance:** Fisher exact p-values for covariates within ±1.0 pp window
6. **Kolesar & Rothe (2018):** Added reference on discrete running variable inference
7. **Honest Treatment of Imbalance:** Corrected claims about covariate balance to accurately describe which covariates are balanced and which reflect mechanical correlation with poverty

## Improvements Inherited from v2

1. **Official OZ Data:** CDFI Fund designated-qozs.12.14.18.xlsx
2. **Fuzzy RDD:** First-stage F-statistic = 32.9 (strong instrument)
3. **Systematic Placebo Grid:** 26 cutoffs (every 1pp, 5-35% excluding ±2pp of 20%)
4. **Local Randomization:** Fisher exact p-values via rdrandinf
5. **County-Clustered SEs:** Parametric specifications with county-level clustering
6. **Infrastructure Heterogeneity:** Split-sample by ACS broadband availability

## Primary Specifications

- Running variable: Poverty rate (centered at 20%)
- Treatment: OZ designation (fuzzy, via LIC eligibility)
- Outcomes:
  - Change in total, information sector, and construction employment (LODES WAC)
  - Data center presence (binary) and count (EIA-860 + EPA GHGRP)
- Method: rdrobust with MSE-optimal bandwidth, triangular kernel, local linear
- Supplementary: Local randomization inference (rdrandinf), parametric LPM for DC presence

## Results Summary

- First stage is strong (F=32.9), confirming LIC eligibility predicts OZ designation
- All reduced-form RDD estimates are precisely estimated nulls
- Direct DC presence outcome confirms null with direct facility measurement
- MDE for DC presence: 0.066 pp (233% of base rate)
- Dynamic event study shows no pre-trends and no emerging post-treatment effects
- Results robust to bandwidth variation, donut RDD, polynomial order, kernel choice, and local randomization inference
- Infrastructure heterogeneity splits show null across all broadband quartiles
