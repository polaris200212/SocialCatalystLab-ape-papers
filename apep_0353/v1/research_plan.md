# Initial Research Plan: Tight Labor Markets and the Crisis in Home Care

## Research Question

Does local labor market tightness reduce the supply of Medicaid Home and Community-Based Services (HCBS) providers? When outside options improve for low-wage workers, do HCBS providers exit, reduce services, or fail to enter — and what are the consequences for Medicaid beneficiaries?

## Identification Strategy

**Design:** Two-way fixed effects panel with Bartik shift-share instrumental variable

**Unit of analysis:** County × quarter (2018Q1–2024Q4, 28 quarters)

**Key equation:**

HCBS_Supply_{ct} = β × LaborTightness_{ct} + δ_c + γ_{st} + X'_{ct}Γ + ε_{ct}

where:
- c = county, s = state, t = quarter
- δ_c = county fixed effects (absorb time-invariant county characteristics)
- γ_{st} = state × quarter FEs (absorb ALL state-level time-varying confounders)
- X_{ct} = county-level time-varying controls (poverty, demographics)
- LaborTightness_{ct} = county-level employment-to-population ratio or inverse unemployment (from BLS QCEW)

**Bartik IV:** Z_{ct} = Σ_k (share_{ck,2018} × ΔlnEmp_{-c,k,t})
- share_{ck,2018}: Pre-period county c's employment share in industry k (from 2018 QCEW)
- ΔlnEmp_{-c,k,t}: National (leave-county-out) employment growth in industry k
- Excludes NAICS 62 (healthcare) from instrument to satisfy exclusion restriction

## Expected Effects and Mechanisms

**Primary hypothesis:** β < 0 — tighter labor markets reduce HCBS provider supply

**Mechanism:** HCBS workers earn $14-17/hour (median), competing directly with retail ($15-18), food service ($14-17), and warehouse/logistics ($17-22). When local labor markets tighten, these outside options become more attractive, pulling workers away from caregiving.

**Expected heterogeneity:**
- Larger effects in counties with more low-wage service employment (retail, food service)
- Larger effects for individual (sole proprietor) providers vs organizational providers
- Larger effects for personal care (T1019) than institutional services (T2016)
- Possible null for H-codes (behavioral health) if workers have specialized credentials

**Counter-hypothesis:** β could be zero or positive if Medicaid reimbursement rates adjust to compete, or if provider organizations absorb turnover without reducing services.

## Primary Specification

**Outcome variables (from T-MSIS):**
1. ln(Active HCBS providers) — extensive margin of supply
2. ln(HCBS claims per beneficiary) — intensive margin of access
3. ln(HCBS spending) — total spending
4. HCBS provider entry rate — new NPI appearance
5. HCBS provider exit rate — NPI disappearance

**Treatment variable:** County-quarter employment-to-population ratio (QCEW total private employment / ACS population)

**IV first stage:** Bartik shift-share predicting county employment growth

## Exposure Alignment (DiD Requirements)

- **Who is actually treated?** Low-wage HCBS workers who face improved outside options when local labor markets tighten
- **Primary estimand population:** Medicaid beneficiaries receiving HCBS in counties experiencing labor market tightening
- **Placebo/control population:** (a) High-wage medical providers (physicians, specialists); (b) Non-HCBS Medicaid services
- **Design:** Continuous-treatment DiD with Bartik IV (not binary treatment)

## Power Assessment

- **Pre-treatment periods:** 8 quarters (2018Q1–2019Q4)
- **Post-treatment periods:** 20 quarters (2020Q1–2024Q4), with COVID recovery providing primary variation
- **Treated clusters:** ~3,100 counties across 50 states + DC
- **Treatment variation:** COVID recovery created massive within-state employment variation (some counties recovered to <3% unemployment while neighboring counties stayed >6%)
- **MDE assessment:** With ~3,100 counties × 28 quarters ≈ 86,800 county-quarter observations, state×quarter-clustered SEs, and realistic ICCs, we expect to detect effects of 2-3% in HCBS supply with 80% power

## Planned Robustness Checks

1. **Pre-trend tests:** Event study plots with 8 quarterly leads, randomization inference
2. **Bartik diagnostics:** Goldsmith-Pinkham et al. (2020) Rotemberg weights; exclude NAICS 62; leave-one-out largest industry; 3-digit NAICS
3. **Placebo outcomes:** High-wage medical providers; non-HCBS Medicaid spending
4. **Alternative treatment measures:** Unemployment rate; wage growth in competing industries
5. **Sample restrictions:** Drop small counties (<10 HCBS providers); drop states with T-MSIS quality concerns
6. **Heterogeneity:** By rural/urban status; by pre-period service-sector employment share; by provider type (individual vs organizational)
7. **Callaway and Sant'Anna (2021):** Cohort-based DiD for counties that experienced discrete tightening events
8. **Demand controls:** Include total Medicaid beneficiaries and non-HCBS spending as controls

## Data Sources

| Source | Variables | Geographic Level | Temporal Coverage |
|--------|-----------|-----------------|-------------------|
| T-MSIS Parquet | HCBS outcomes (claims, spending, providers, beneficiaries) | NPI → ZIP → county | Monthly, 2018-01 to 2024-12 |
| NPPES Extract | Provider geography, type, specialty | NPI-level | Snapshot |
| BLS QCEW | Employment by industry, wages, establishments | County-quarter | 2017Q1-2024Q4 |
| Census ACS 5-Year | Population, poverty, demographics | County | 2018-2022 |
| Census ZCTA-County | ZIP-to-county crosswalk | ZIP-county mapping | 2020 |
