# Initial Research Plan: The Elasticity of Medicaid's Safety Net

## Research Question

How elastic are local Medicaid HCBS markets? When a provider is suddenly removed from a local market through federal fraud exclusion, do remaining providers expand to absorb displaced patients, or does a care gap persist? What structural features of local markets (concentration, rurality, service type) predict resilience versus fragility?

## Identification Strategy

**Design:** Within-state event study DiD around OIG exclusion events

**Unit of analysis:** ZIP code × month (2018M01–2024M12, 84 months)

**Key equation:**

Y_{ct} = Σ_k β_k × 1[t - E_c = k] + δ_c + γ_{st} + X'_{ct}Γ + ε_{ct}

where:
- c = ZIP code, s = state, t = month, E_c = exclusion month
- δ_c = ZIP code fixed effects
- γ_{st} = state × month FE (absorbs ALL state-level time-varying confounders)
- X_{ct} = enforcement intensity controls (other exclusions in county × quarter)
- k ∈ [-18, +18] months relative to exclusion
- Outcomes Y_{ct} are computed EXCLUDING the excluded provider's own billing

**Treatment:** OIG LEIE exclusion of a Medicaid provider who was actively billing HCBS services in T-MSIS. Restricted to exclusions July 2020+ (≥30 months pre-period).

**Control:** ZIP codes within the same state that did not experience an exclusion in the event window.

**Estimator:** Callaway and Sant'Anna (2021) for heterogeneity-robust group-time ATT estimates, with never-treated and not-yet-treated as comparison groups.

## Expected Effects and Mechanisms

**Primary hypothesis:** β_k > 0 for k ≥ 0 — remaining providers absorb displaced patients, and total rest-of-market HCBS spending recovers within 6-12 months.

**Mechanisms:**
1. **Capacity absorption:** Existing providers near the excluded provider expand their caseloads
2. **New entry:** New providers enter the market to fill the gap (NPI entry rate increases)
3. **Geographic substitution:** Patients travel to adjacent ZIPs to find care (boundary spillovers)

**Alternative hypothesis:** β_k < 0 or β_k ≈ 0 — the market does NOT absorb, and HCBS spending falls permanently. This would indicate HCBS markets are fragile and provider exits create persistent care deserts.

**Expected heterogeneity:**
- More elastic markets: urban, low-concentration (competitive), personal care (T1019)
- Less elastic markets: rural, high-concentration, behavioral health (H-codes requiring specialized credentials)
- Organizational exclusions may create larger shocks than individual exclusions

## Primary Specification

**Outcome variables (from T-MSIS, excluding the excluded provider):**
1. ln(HCBS spending) — total rest-of-market HCBS spending in ZIP
2. ln(Active HCBS providers) — number of distinct NPIs billing HCBS in ZIP
3. ln(Beneficiaries served) — unique beneficiaries receiving HCBS in ZIP
4. HCBS provider entry rate — new NPI appearance in ZIP
5. HCBS provider exit rate — NPI disappearance from ZIP
6. Absorption rate — (change in rest-of-market spending) / (excluded provider's baseline spending)

**Treatment variable:** Binary indicator for post-exclusion months in treated ZIPs

**Sample restriction:** Exclusions July 2020 – December 2024 with valid NPI, matched to T-MSIS billing, and ≥5% market share in their service category within their ZIP

## Exposure Alignment (DiD Requirements)

- **Who is actually treated?** Medicaid beneficiaries who were receiving HCBS from the excluded provider
- **Primary estimand population:** HCBS providers and beneficiaries in the excluded provider's ZIP code
- **Placebo/control population:** (a) Non-HCBS Medicaid services in same ZIP; (b) HCBS in unrelated service categories
- **Design:** Staggered event study with multiple exclusion cohorts

## Power Assessment

- **Pre-treatment periods:** ≥30 months (2018M01 to event month)
- **Post-treatment periods:** Variable, average ~24 months
- **Treated markets:** ~1,000-2,500 ZIP codes (depending on NPI match rate and market share threshold)
- **Treatment variation:** Exclusions occur in different ZIPs across different months → staggered timing
- **MDE assessment:** With ~2,000 treated ZIP × 84 months ≈ 168,000 observations, state × month-clustered SEs, we expect to detect effects of 5-10% in HCBS spending with 80% power for the full sample. High-share subsample will have larger effects but smaller N.

## Planned Robustness Checks

1. **Pre-trend tests:** Event study with 18 monthly leads, CS-DiD group-time ATTs
2. **Anticipatory effects:** Plot excluded provider's own billing trajectory; define "effective exclusion" as billing drop date
3. **Enforcement-wave controls:** State × month FE, county-quarter exclusion count controls, isolated-exclusion subsample
4. **Exclusion type heterogeneity:** Mandatory (1128a — criminal) vs. permissive (1128b — audit-based)
5. **Market definition sensitivity:** ZIP vs. county vs. commuting zone
6. **Market share threshold sensitivity:** 5%, 10%, 20% cutoffs
7. **Placebo outcomes:** Non-HCBS Medicaid spending in same ZIP, HCBS in different service categories
8. **Spillover analysis:** Adjacent ZIP codes (do they gain providers/spending?)
9. **Randomization inference:** Randomly assign exclusion dates; compare true vs. placebo distribution
10. **HonestDiD:** Rambachan and Roth (2023) sensitivity to parallel trends violations

## Data Sources

| Source | Variables | Geographic Level | Temporal Coverage |
|--------|-----------|-----------------|-------------------|
| T-MSIS Parquet (local) | HCBS outcomes: claims, spending, providers, beneficiaries | NPI × HCPCS × month → ZIP → county | Monthly, 2018-01 to 2024-12 |
| OIG LEIE (direct CSV) | Exclusion dates, NPIs, specialties, exclusion types | Provider-level | Historical through current |
| NPPES Extract (local) | Provider geography, type, specialty | NPI → ZIP, county | Snapshot |
| Census ZCTA-County | ZIP-to-county crosswalk | ZIP-county mapping | 2020 |
| Census ACS 5-Year | Population, poverty, demographics, elderly share | County | 2018-2022 |
| USDA Rural-Urban Codes | Urban/rural classification | County | 2023 |
