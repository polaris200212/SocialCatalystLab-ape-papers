# Initial Research Plan: Lockdowns and the Collapse of In-Person Medicaid Care

## Research Question

Did state COVID-19 lockdown policies cause a differential collapse in Medicaid's in-person home-based care services (HCBS) relative to telehealth-eligible behavioral health services, and did this disruption persist after lockdowns ended?

## Identification Strategy

**Triple-Difference (DDD) Design:**
1. **Service type:** HCBS (T-codes, in-person required) vs. Behavioral Health (H-codes, telehealth-eligible)
2. **Time:** Pre-lockdown (Jan 2018 – Feb 2020) vs. Post-lockdown (April 2020 – Dec 2024)
3. **Lockdown intensity:** State-level stringency from Oxford COVID-19 Government Response Tracker (continuous)

**Key equation:**
Y_{s,k,t} = β₁(Stringency_s × HCBS_k × Post_t) + β₂(Stringency_s × Post_t) + β₃(HCBS_k × Post_t) + γ_{s,k} + δ_{k,t} + θ_{s,t} + ε_{s,k,t}

where s=state, k=service type, t=month, and we include state×service, service×month, and state×month fixed effects.

**Identifying assumption:** Absent lockdowns, the ratio of HCBS to behavioral health billing would have evolved similarly across high- and low-stringency states. The state×month FE absorb all state-level COVID severity, economic conditions, and common policy shocks. The service×month FE absorb national trends in each service type. Only the differential impact on in-person vs. telehealth-eligible services within the same state is attributed to lockdown stringency.

## Expected Effects and Mechanisms

1. **Acute disruption (March–June 2020):** HCBS billing drops sharply in high-stringency states relative to BH, as personal care aides cannot enter homes while BH providers pivot to telehealth.
2. **Partial recovery (July 2020 – Dec 2020):** HCBS billing recovers as lockdowns ease, but potentially incompletely if providers exited.
3. **Long-run scarring (2021–2024):** If lockdowns caused permanent provider exit, HCBS may show persistent deficits even as lockdowns ended.

**Mechanisms to explore:**
- Provider exit (extensive margin: number of billing NPIs)
- Service intensity (intensive margin: claims per provider)
- Beneficiary access (beneficiaries served per provider)

## Primary Specification

State × service-type × month panel (50 states × 2 service types × 84 months = 8,400 obs).
Outcomes: log(total_paid), log(total_claims), log(n_providers), log(total_beneficiaries).
Treatment: continuous stringency × HCBS × post.
Standard errors: Clustered at state level (50 clusters).

**March 2020 handling:** Drop March 2020 from the sample (partial exposure month, orders issued mid-month). Define post = April 2020+.

## Planned Robustness Checks

1. **Differential pre-trends:** Event-study plot of HCBS-BH gap by stringency quartile, showing parallel trends pre-March 2020
2. **Binary treatment:** Dichotomize stringency at median as alternative to continuous measure
3. **Alternative stringency windows:** Peak stringency (April 2020) vs. cumulative stringency (March–June 2020)
4. **COVID severity controls:** Add state-level COVID death rates as controls (though absorbed by state×month FE)
5. **Exclude never-lockdown states:** Test sensitivity to the 7 states without statewide orders
6. **Placebo treatment date:** Run the same specification with placebo lockdown dates in 2019
7. **Alternative service comparison:** Use CPT professional services (codes 99xxx) instead of H-codes as the telehealth-eligible comparison
8. **Callaway-Sant'Anna:** Heterogeneity-robust estimator using dichotomized treatment timing
9. **Randomization inference:** Permute stringency across states to test sharp null

## Exposure Alignment (DiD)

- **Who is treated:** Medicaid HCBS providers in states with high lockdown stringency
- **Primary estimand:** Differential effect on in-person HCBS billing relative to telehealth-eligible BH billing
- **Control population:** Same providers/states, behavioral health services that could pivot to telehealth
- **Design:** Triple-difference (state × service-type × time)

## Power Assessment

- **Pre-treatment periods:** 26 months (Jan 2018 – Feb 2020)
- **Treatment clusters:** 50 states (continuous treatment intensity)
- **Post-treatment periods:** 57 months (April 2020 – Dec 2024, excluding March 2020)
- **Service types:** 2 (HCBS vs. BH)
- **Total observations:** ~8,300 state-service-month cells
- **Expected power:** Strong. With 50 clusters and 26 pre-periods, we can detect moderate effects. The within-state comparison (HCBS vs. BH) further increases precision by absorbing state-level shocks.

## Data Sources

1. **T-MSIS Medicaid Provider Spending** (local Parquet, 227M rows) — primary outcomes
2. **NPPES** (local extract or bulk CSV) — state assignment via practice address
3. **Oxford COVID-19 Government Response Tracker** (GitHub CSV) — state-level stringency index
4. **CDC Stay-at-Home Orders** (Socrata API) — binary stay-at-home indicator by state × day
5. **Census ACS** (API) — state-level population, demographics, Medicaid enrollment denominators
6. **FRED** (API) — state unemployment rates as economic controls
