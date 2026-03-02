# Initial Research Plan: Does Telehealth Payment Parity Expand Medicaid Behavioral Health Access?

## Research Question

Do state-level telehealth payment parity laws expand the supply of behavioral health providers serving Medicaid beneficiaries? We examine whether parity laws increase the number of unique providers billing for behavioral health services, total beneficiaries receiving care, and total claims volume and spending.

## Identification Strategy

**Design:** Staggered Difference-in-Differences (DiD) using Callaway-Sant'Anna (2021) doubly robust estimator.

**Treatment:** State adoption of permanent Medicaid telehealth payment parity law. Treatment timing varies from 2020 to 2023, with 26 states adopting during our observation window.

**Unit of analysis:** State x quarter (28 quarters: Q1 2018 -- Q4 2024).

**Control group:** Never-treated states (those without permanent Medicaid telehealth payment parity as of December 2024).

## Exposure Alignment

**Who is actually treated?** Behavioral health providers billing Medicaid in states that adopt telehealth payment parity.

**Placebo/control population:** Personal care providers (T-code billers) in the same states -- personal care services cannot be delivered via telehealth.

**Design:** Both standard DiD and Triple-diff (DDD): state x time x service-type.

## Power Assessment

- Pre-treatment periods: 5+ years for states adopting in 2023-2024
- Treated clusters: 26 states
- Post-treatment periods: Varies by cohort (1-5 years)
- Total state x quarter observations: ~1,400 (51 units x 28 quarters)

## Planned Robustness Checks

1. Goodman-Bacon decomposition of TWFE estimate
2. Sun-Abraham interaction-weighted estimator
3. Rambachan-Roth HonestDiD sensitivity analysis
4. Placebo test: fake treatment dates (2 years early)
5. Placebo outcome: personal care (T-codes)
6. Excluding COVID period
7. Wild cluster bootstrap inference
8. Leave-one-out sensitivity

## Data Sources

| Source | Variables | Access |
|--------|-----------|--------|
| T-MSIS (local Parquet) | Claims, spending, beneficiaries by NPI x HCPCS x month | Local file |
| NPPES (local Parquet) | Provider state, ZIP, specialty | Local file |
| CCHPCA + NCSL | Telehealth parity law adoption dates | Manual construction |
| Census ACS (API) | State population | CENSUS_API_KEY |
| FRED (API) | State unemployment rates | FRED_API_KEY |
