# Initial Research Plan: Priced Out of Care

## Research Question

Does Medicaid's structural wage uncompetitiveness predict home care workforce fragility? Specifically: did states where personal care aide wages were lowest relative to competing low-wage occupations in 2019 experience the largest disruptions to Medicaid HCBS provider supply, beneficiary access, and spending during and after the COVID-19 pandemic?

## Theoretical Framework

Medicaid operates as a monopsonist in HCBS labor markets. State Medicaid agencies set reimbursement rates unilaterally, and these rates flow through home care agencies to determine worker compensation. When Medicaid wages are near or below outside options (retail, food service, warehousing), the workforce is in fragile equilibrium — any shock that disrupts supply or improves outside options triggers disproportionate exit. COVID-19 provides a natural stress test: it simultaneously disrupted in-person care work, created new outside options (enhanced UI, Amazon hiring), and raised competing-sector wages. The monopsony framework (Manning 2003; Azar, Marinescu, and Steinbaum 2022) predicts that states with larger monopsony markdowns (lower wage ratios) should experience sharper workforce contractions.

## Identification Strategy

**Design:** Continuous-treatment difference-in-differences.

**Treatment variable:** Pre-COVID (2019) Medicaid wage competitiveness ratio by state:
- Numerator: BLS OES median hourly wage for SOC 39-9021 (Personal Care Aides), state-level, May 2019
- Denominator: BLS OES weighted-average median hourly wage for competing occupations (SOC 41-2011 Cashiers, 35-3021 Combined Food Prep/Serving, 53-7062 Laborers/Freight/Stock), state-level, May 2019
- Ratio = PCA wage / composite competing wage

**Estimating equation:**

Y_st = Σ_t β_t × (WageRatio_s × 1[Month=t]) + γ_s + δ_t + X_st'λ + ε_st

where:
- Y_st = outcome for state s in month t
- WageRatio_s = pre-COVID (2019) personal care aide wage / competing-sector wage
- γ_s = state fixed effects
- δ_t = month fixed effects
- X_st = time-varying controls (COVID cases per capita, unemployment rate, lockdown stringency)
- Reference period: January 2020 (normalized to 0)

**Identifying assumption:** Conditional on state and month FE, the 2019 wage ratio is uncorrelated with the timing and severity of COVID-related disruptions. This is testable: pre-trends should be flat (β_t ≈ 0 for t < March 2020).

**Inference:** State-clustered standard errors (50 clusters). Wild cluster bootstrap as robustness.

## Exposure Alignment (DiD Requirements)

- **Who is treated:** All states, with continuous treatment intensity based on 2019 wage ratio
- **Primary estimand population:** HCBS providers (billing NPIs with T/S-code activity) in each state
- **Placebo/control population:** Medicare home health providers (same states, federally-set rates)
- **Design:** Continuous-treatment DiD (NOT staggered adoption — no treatment timing variation)

## Expected Effects and Mechanisms

1. **Provider supply decline (primary):** States with lower wage ratios should experience larger declines in active HCBS providers after March 2020, as workers exit to better-paying alternatives
2. **Beneficiary access loss:** Fewer providers → fewer beneficiaries served → access crisis
3. **Spending disruption:** Spending should decline in low-ratio states (fewer providers billing) even as per-unit rates may increase (remaining providers charge more)
4. **Entry margin:** New provider entries should be lower in low-ratio states (less attractive labor market)
5. **Concentration effect:** Small providers (sole proprietors) exit disproportionately → market concentration increases in low-ratio states

## Primary Specifications

### Specification 1: Event Study (Main)
- Y = log(active HCBS providers_st)
- Treatment × month dummies, state FE, month FE
- Report: event study coefficient plot with 95% CI

### Specification 2: Pre/Post DiD
- Y = log(active HCBS providers_st)
- WageRatio × Post (March 2020+), state FE, month FE
- Single aggregate treatment effect

### Specification 3: Triple-Difference (Medicare Placebo)
- Y = log(active providers_spt), p ∈ {Medicaid HCBS, Medicare Home Health}
- WageRatio × Post × Medicaid, with state×payer and month×payer FE
- Tests: Does the wage ratio predict ONLY Medicaid disruption?

### Specification 4: Beneficiary Access
- Y = log(total beneficiaries_st)
- Same event study structure as Spec 1

### Specification 5: ARPA Repair
- Extend analysis through 2024
- Interact WageRatio × Post-ARPA (mid-2021+)
- Test whether ARPA rate increases reversed disruption differentially by initial ratio

## Planned Robustness Checks

1. **COVID controls:** Add state×month COVID cases/deaths, lockdown stringency (Oxford index), state unemployment rate
2. **Region × month FE:** Replace month FE with Census-region × month to absorb regional pandemic trajectories
3. **Binned treatment:** Terciles of wage ratio instead of continuous (robust to functional form)
4. **Alternative wage measures:** (a) 25th percentile instead of median, (b) different competing occupations, (c) wage level instead of ratio
5. **Placebo outcomes:** (a) High-skill Medicaid providers (physicians), (b) Medicare providers, (c) Behavioral health providers (telehealth-eligible)
6. **Randomization inference:** Permute wage ratio across states (500-1000 permutations)
7. **Bacon decomposition analog:** Demonstrate no "forbidden comparison" issues in continuous treatment
8. **Wild cluster bootstrap:** For inference with 50 clusters
9. **Bartik IV:** Instrument for outside-option wages using national industry growth × state baseline industry shares
10. **Dropping outlier states:** Iteratively drop each state; verify no single state drives results

## Power Assessment

- Pre-treatment periods: 26 months (Jan 2018 – Feb 2020)
- Post-treatment periods: 58 months (Mar 2020 – Dec 2024)
- Treated clusters: 50 states (continuous treatment)
- Outcome variation: Based on T-MSIS data, states have 1–1,016 HCBS providers; using log transformation normalizes scale
- MDE calculation: With 50 states, 84 months, ICC ≈ 0.5, and wage ratio SD ≈ 0.15, MDE ≈ 3-5% change in provider count per 0.1 unit change in wage ratio (back-of-envelope; formal power calculation in analysis)

## Data Sources

| Source | What | Access | Tested? |
|--------|------|--------|---------|
| T-MSIS Parquet | HCBS outcomes (providers, beneficiaries, spending) | Local file (4.1 GB) | ✅ Verified |
| NPPES Extract | State assignment via NPI join | Local Parquet | ✅ Verified |
| BLS OES (May 2019) | Personal care aide + competing-sector wages by state | Direct download (Excel) | ✅ Public |
| Medicare Physician/Supplier PUF | Medicare home health spending by NPI | data.cms.gov Socrata | ✅ Confirmed working |
| Census ACS | State demographics, poverty, insurance | CENSUS_API_KEY | ✅ Verified |
| FRED | State unemployment rates | FRED_API_KEY | ✅ Verified |
| COVID Tracking / NYT | State-level COVID cases/deaths | Public download | ✅ Public |
| Oxford COVID-19 Government Response | Lockdown stringency index by state | Public GitHub | ✅ Public |

## Code Pipeline

```
00_packages.R     — Load libraries, set themes
01_fetch_data.R   — Download BLS OES, COVID data, Medicare PUF; load T-MSIS/NPPES from shared path
02_clean_data.R   — Construct wage ratio, build state×month panel, define HCBS provider outcomes
03_main_analysis.R — Event study, pre/post DiD, triple-diff
04_robustness.R   — All robustness checks (controls, binned, placebos, RI, bootstrap)
05_figures.R      — Event study plots, maps, distribution figures
06_tables.R       — Summary statistics, regression tables
```
