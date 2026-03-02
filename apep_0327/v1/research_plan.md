# Initial Research Plan: State Minimum Wage Increases and the HCBS Provider Supply Crisis

## Research Question

Do state minimum wage increases reduce the supply of Home and Community-Based Services (HCBS) providers in Medicaid? When minimum wages rise, does the shrinking wage premium for emotionally demanding direct care work relative to retail and food service jobs cause providers to exit the HCBS market, reducing access for elderly and disabled beneficiaries?

## Identification Strategy

**Design:** Staggered difference-in-differences (DiD) using Callaway and Sant'Anna (2021) heterogeneity-robust estimator.

**Treatment:** State-level minimum wage increases during 2018–2024. Approximately 32 states + DC raised their minimum wages above the federal floor ($7.25) during this period, with different effective dates and magnitudes. Nineteen states remained at the federal minimum throughout (clean never-treated control group).

**Key identification assumption:** Parallel trends — absent minimum wage increases, HCBS provider supply would have evolved similarly across treated and control states. Testable via pre-treatment event-study coefficients.

**Why this is credible:**
1. State MW laws are motivated by general labor market concerns, not Medicaid provider supply — exogenous to HCBS outcomes.
2. Staggered adoption across 32+ states provides variation in both timing and magnitude.
3. Never-treated states (19 at $7.25) provide a clean comparison group.
4. The mechanism is economically intuitive: HCBS direct care workers earn a median of $16.12/hr (BLS OES 2023), placing them squarely in the range where MW increases bind. Retail/food service becomes relatively more attractive when MW rises.

## Exposure Alignment (DiD)

**Who is actually treated?** Low-wage HCBS direct care workers (personal care attendants, home health aides) whose wages are near the minimum wage. Organizational providers employing such workers are also affected through labor costs.

**Primary estimand population:** HCBS providers billing T-codes (personal care), H-codes (behavioral health), and S-codes (attendant care) in T-MSIS, linked to states via NPPES.

**Placebo/control population:** Non-HCBS Medicaid providers billing CPT codes (physicians, specialists) whose wages are far above MW. These should show no response to MW increases.

**Design:** DiD (primary) with triple-difference DDD robustness (HCBS vs. non-HCBS within same state).

## Expected Effects and Mechanisms

**Primary hypothesis:** MW increases reduce HCBS provider supply.
- **Mechanism 1 (Outside option):** Higher MW raises the reservation wage for HCBS workers. If Medicaid reimbursement rates don't keep pace, workers exit to retail/food service.
- **Mechanism 2 (Cost pressure):** For organizational providers employing HCBS workers, MW increases raise labor costs. Providers may reduce staff, serve fewer beneficiaries, or exit the market.
- **Mechanism 3 (Offsetting):** States may raise Medicaid HCBS reimbursement rates in response to MW increases, partially or fully offsetting the supply reduction.

**Expected sign:** Negative effect on provider counts and beneficiaries served, with heterogeneity:
- Larger effects in states where MW approaches HCBS wages (high "bite")
- Larger effects for individual providers (sole proprietors) vs. organizations
- Larger effects for personal care (T-codes) vs. behavioral health (H-codes)

**Null result interpretation:** If no effect, it suggests either (a) HCBS wages were already above MW in most affected states, (b) Medicaid rates adjusted to compensate, or (c) HCBS workers have limited labor market mobility. All are informative.

## Primary Specification

```
Y_{st} = α + β·MW_{st} + X_{st}γ + δ_s + τ_t + ε_{st}

Y: log(HCBS_providers), log(beneficiaries), entry_rate, exit_rate
MW: log(minimum_wage) or binary(above_federal)
X: state-level controls (unemployment, population, Medicaid enrollment proxy)
δ_s: state fixed effects
τ_t: year-month fixed effects
```

**Primary estimator:** Callaway-Sant'Anna (2021) with never-treated as comparison group, clustered at state level.

**Event study:** Dynamic ATT by periods relative to first MW increase, visualized with event-study plot.

## Power Assessment

- **Pre-treatment periods:** 2018–[first MW increase], minimum 5+ years for most treated states
- **Treated clusters:** 32 states (well above 20 threshold)
- **Post-treatment periods:** Varies by cohort (2018 early adopters to 2024 late adopters)
- **Total observations:** ~54 states × 84 months ≈ 4,500 state-months
- **MDE:** With 32 treated states, 19 controls, and 84 months, we have substantial power to detect effects of ~5% on provider counts. Exact MDE depends on residual variance (will compute after data construction).

## Planned Robustness Checks

1. **Triple-difference (DDD):** HCBS (T/H/S-code) vs. non-HCBS (CPT-code) providers × MW increase × state
2. **Continuous treatment:** Use log(MW) instead of binary treatment
3. **Dose-response:** Interact treatment with "MW bite" (MW/median HCBS wage ratio)
4. **Alternative estimators:** Sun-Abraham (2021), de Chaisemartin-D'Haultfœuille (2020) for comparison
5. **Randomization inference:** Fisher permutation tests on treatment timing
6. **Placebo tests:**
   a. Non-HCBS Medicaid providers (physician offices) should show null effect
   b. Pre-trends test from event study
7. **Provider heterogeneity:** Individual (entity_type=1) vs. organizational (entity_type=2) providers
8. **Code-specific analysis:** T-codes (personal care) vs. H-codes (behavioral health) vs. S-codes (attendant care)
9. **Spatial controls:** State-level BLS QCEW healthcare employment as control
10. **Exclude ARPA states:** Drop states with major HCBS rate increases to isolate MW effect

## Data Sources

| Source | Role | Access |
|--------|------|--------|
| T-MSIS Parquet (local) | HCBS provider outcomes | Confirmed (2.74 GB) |
| NPPES bulk extract | NPI → state, entity type, specialty | Downloading (~800 MB) |
| DOL/NCSL MW data | State minimum wage panel | Public, manually compiled |
| Census ACS 5-Year | State population denominators | API (CENSUS_API_KEY) |
| BLS QCEW | Local healthcare employment | Direct CSV download |
| FRED | State unemployment rate | API (FRED_API_KEY) |

## Code Pipeline

- `00_packages.R` — Load libraries, set themes
- `01_fetch_data.R` — Load T-MSIS, build NPPES extract, fetch Census/BLS/FRED
- `02_clean_data.R` — Build state × month panel, construct MW treatment variable, provider entry/exit
- `03_main_analysis.R` — CS-DiD estimation, event study, ATT
- `04_robustness.R` — DDD, placebo tests, alternative estimators, RI
- `05_figures.R` — Event study plots, descriptive trends, maps
- `06_tables.R` — Summary statistics, main results, robustness tables
