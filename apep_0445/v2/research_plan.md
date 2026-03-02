# Research Plan: APEP-0445 v2

## Revision of APEP-0445 v1

**Research Question:** Do Opportunity Zones attract data center investment to distressed communities?

**Identification Strategy:** Regression Discontinuity Design at the 20% poverty rate threshold for LIC eligibility, with fuzzy RDD using official CDFI OZ designation data.

## Key Improvements Over v1

1. **Official OZ Data:** Replaced poverty-rank approximation with CDFI Fund designated-qozs.12.14.18.xlsx
2. **Fuzzy RDD:** First-stage F-statistic = 31.7 (strong instrument)
3. **Systematic Placebo Grid:** 26 cutoffs (every 1pp, 5-35% excluding ±2pp of 20%), 0/26 significant
4. **Local Randomization:** Fisher exact p-values via rdlocrand, all > 0.28
5. **County-Clustered SEs:** Parametric specifications with county-level clustering
6. **Covariate-Adjusted RDD:** rdrobust with demographic covariates
7. **Infrastructure Heterogeneity:** Split-sample by ACS broadband availability (2017 vintage)
8. **Literature:** Added Cattaneo et al. (2015, 2020), Bartik (1991), Kassam et al. (2024)

## Primary Specification

- Running variable: Poverty rate (centered at 20%)
- Treatment: OZ designation (fuzzy, via LIC eligibility)
- Outcomes: Change in total, information sector, and construction employment (LODES WAC)
- Method: rdrobust with MSE-optimal bandwidth, triangular kernel, local linear

## Results Summary

- First stage is strong (F=31.7), confirming LIC eligibility predicts OZ designation
- All reduced-form RDD estimates are precisely estimated nulls
- Results robust to kernel choice, polynomial order, donut holes, bandwidth variation
- Null persists across infrastructure-ready and infrastructure-poor tracts
- Interpretation: OZ tax incentives insufficient to overcome fundamental site selection factors for data centers
