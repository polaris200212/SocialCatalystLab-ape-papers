# Initial Research Plan: Opportunity Zone Designation and Data Center Investment

## Research Question

Do place-based capital gains tax incentives (Opportunity Zones) attract data center and technology infrastructure investment to low-income communities, or do they subsidize investment that would have occurred regardless?

## Exposure Alignment

**Who is treated?** Census tracts crossing the 20% poverty threshold become eligible for OZ designation. Governors select ~25% of eligible tracts. **Who is actually affected?** Investors channeling capital gains through QOFs into designated tracts, and data center operators choosing sites in OZ tracts. The treatment operates through investor-side capital gains deferral, not direct cost reduction for operators.

## Identification Strategy

**Design:** Fuzzy Regression Discontinuity Design at the 20% poverty rate threshold for OZ eligibility.

**Running Variable:** Census tract poverty rate from the 2011-2015 ACS (the vintage used for OZ designation).

**First Stage:** Tracts with poverty rate ≥ 20% are eligible for OZ designation; tracts below are ineligible (absent MFI pathway). Governors selected ~25% of eligible tracts, creating a ~25pp jump in designation probability at the cutoff.

**Sample Restriction:** Exclude tracts eligible only via the MFI pathway (poverty < 20% but MFI ≤ 80% of area median). This ensures the 20% poverty cutoff cleanly separates eligible from ineligible tracts in our sample.

**Exclusion Restriction:** The 20% poverty threshold affects outcomes only through OZ designation, not through other programs. Key threat: NMTC uses the same LIC definition. Will test by controlling for NMTC allocation amounts and checking for pre-period discontinuities.

## Expected Effects and Mechanisms

**Primary hypothesis:** OZ designation increases data center and tech investment in designated tracts, as capital gains deferral creates a strong financial incentive for large-scale, capital-intensive projects like data centers.

**Expected direction:** Positive effect on NAICS 51 employment, total employment, and construction activity in designated tracts relative to barely-ineligible tracts.

**Mechanisms:**
1. Capital gains tax deferral reduces effective cost of data center investment by 15-37% (depending on holding period)
2. Data centers are ideal OZ investments: large capital expenditure, long holding periods, predictable cash flows
3. OZ designation signals government support, reducing regulatory uncertainty

**Null result interpretation:** If effects are zero, this suggests data centers locate based on infrastructure factors (fiber, power, land) rather than tax incentives — consistent with the Georgia audit finding that 70% of investment would have occurred anyway.

## Primary Specification

**Reduced-form RDD:**
Y_{it} = α + τ · 1(poverty_i ≥ 20%) + f(poverty_i) + X_i'β + ε_{it}

Where:
- Y_{it}: outcome for tract i in post-period t (NAICS 51 employment, total employment, construction employment)
- 1(poverty_i ≥ 20%): indicator for crossing eligibility threshold
- f(poverty_i): flexible polynomial in poverty rate (local linear or quadratic)
- X_i: pre-treatment covariates (population, median income, urbanicity)

**Fuzzy RDD (2SLS):**
First stage: OZ_i = π · 1(poverty_i ≥ 20%) + g(poverty_i) + X_i'δ + v_i
Second stage: Y_{it} = α + τ_{IV} · OZ_i_hat + f(poverty_i) + X_i'β + ε_{it}

**Bandwidth selection:** Calonico, Cattaneo, and Titiunik (2014) optimal bandwidth selector (rdrobust package in R).

## Planned Robustness Checks

1. **Bandwidth sensitivity:** Test at 50%, 75%, 100%, 125%, 150% of optimal bandwidth
2. **Polynomial order:** Linear, quadratic, and cubic specifications
3. **Donut RDD:** Exclude tracts within 1pp and 2pp of the cutoff
4. **McCrary density test:** Verify no bunching at the 20% threshold
5. **Covariate balance:** Test for discontinuities in pre-determined characteristics
6. **Placebo cutoffs:** Test at 15% and 25% poverty (no policy discontinuity expected)
7. **Pre-treatment outcomes:** Test for discontinuities in 2015-2017 outcomes (should be zero)
8. **Dynamic effects:** Year-by-year RDD estimates (event study at the cutoff)
9. **Heterogeneity:** By urbanicity, state, baseline infrastructure quality
10. **NMTC control:** Add NMTC allocation amounts as controls; test NMTC-specific discontinuity

## Data Sources

| Data | Source | Coverage | Granularity |
|------|--------|----------|-------------|
| Poverty rate (running variable) | Census ACS 2011-2015 | All US tracts | Tract |
| OZ designation status | CDFI Fund / Treasury | All US tracts | Tract |
| Employment by NAICS sector | Census LEHD/LODES | 2002-2023 | Census block |
| Establishment counts | Census County Business Patterns | Annual | County |
| Building permits | Census Building Permits Survey | Monthly | County/place |
| Population & demographics | Census ACS | Annual | Tract |

## Power Assessment

- **Sample size:** ~73,000 census tracts nationally; ~30,000+ within reasonable bandwidth of 20% cutoff
- **First stage:** ~25pp jump in designation probability (F >> 10)
- **Pre-treatment periods:** 2002-2017 (15 years)
- **Post-treatment periods:** 2018-2023 (5 years)
- **Concern:** NAICS 51 employment is sparse in many tracts; total employment has more power
- **MDE estimate:** With ~30,000 tracts and ~25% first stage, MDE likely < 5% of mean employment — very well-powered
