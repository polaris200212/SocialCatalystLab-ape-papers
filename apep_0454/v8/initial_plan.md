# Initial Research Plan — apep_0454

## Title
The Depleted Safety Net: Pre-COVID Provider Exits, Pandemic Service Disruption, and the Effectiveness of Federal HCBS Investment

## Research Question
Did areas with greater pre-pandemic Medicaid provider workforce depletion experience worse service disruption during COVID-19, and did the American Rescue Plan's HCBS investment (§9817) help restore provider supply in depleted markets?

## Identification Strategy

### Part 1: Pre-COVID Exits × Pandemic Disruption (Continuous-Treatment Event Study)

**Treatment:** Pre-COVID provider exit intensity — the share of active Medicaid providers (billing NPIs) in a state that permanently exit T-MSIS billing between January 2018 and February 2020. Measured from T-MSIS billing cessation + NPPES career proxies.

**Event:** COVID-19 pandemic onset (March 2020).

**Design:** Continuous-treatment event study. Partition states into quartiles of pre-COVID exit intensity. Estimate dynamic treatment effects comparing high-exit vs low-exit states before and after March 2020, controlling for state and month fixed effects.

**Key assumption:** Pre-COVID exit intensity is uncorrelated with pandemic-specific outcome trends (conditional on controls). Validated by parallel pre-trends tests.

**Shift-share instrument:** National specialty-specific exit rates (the "shift") × state-level baseline specialty composition in 2018 (the "share") → predicted exit intensity. Addresses endogeneity of local exits.

### Part 2: ARPA HCBS Recovery (Within-State DDD)

**Treatment:** ARPA §9817 enhanced FMAP (April 1, 2021), targeting HCBS services.

**Design:** Triple-difference:
- Time: Pre-ARPA (Jan 2018 – Mar 2021) vs Post-ARPA (Apr 2021 – Dec 2024)
- Provider type: HCBS providers (T/H/S-code billers, targeted by ARPA) vs Non-HCBS (CPT-code billers, not targeted)
- Exit intensity: High vs Low pre-COVID provider exit states

**Key coefficient (β₇):** The ARPA effect on HCBS supply specifically in depleted markets. Tests whether federal investment reached where it was needed most.

### Part 3: Long-Run Persistence (2022–2024)
Dynamic event study coefficients through 2024 test whether:
(a) pandemic disruption was temporary or persistent
(b) ARPA reversed pre-COVID depletion or merely stabilized existing capacity

## Expected Effects and Mechanisms

1. **Pandemic disruption (Part 1):** States with higher pre-COVID exit rates experience larger declines in active providers, beneficiaries served, and claims volume after March 2020. Mechanism: depleted networks have less slack to absorb pandemic demand surge and workforce stress.

2. **ARPA recovery (Part 2):** HCBS providers in high-exit states show larger post-April-2021 increases in entry and billing volume vs HCBS providers in low-exit states (and vs non-HCBS providers in the same states). Mechanism: ARPA rate increases and bonuses attract new entrants / retain existing providers where wages were previously too low.

3. **Deaths of despair (secondary):** States with higher pre-COVID behavioral health provider exits experience larger increases in drug overdose and suicide mortality post-March 2020. Channel: reduced access to substance use and mental health treatment. This is a secondary analysis with explicit caveats about the indirect causal chain.

## Primary Specification

### Part 1: Event Study
```
Y_{st} = α_s + δ_t + Σ_k β_k × (ExitIntensity_s × 1[t = k]) + X_{st}γ + ε_{st}
```
Where Y_{st} is a T-MSIS outcome (active providers, beneficiaries, claims) in state s, month t. ExitIntensity_s is the pre-COVID provider exit rate. Event time k is relative to March 2020. X_{st} includes state unemployment (FRED), COVID case rates (CDC), and ACS demographics.

### Part 2: DDD
```
Y_{sjt} = α_sj + δ_jt + β₁(Post-ARPA_t × HCBS_j) + β₂(Post-ARPA_t × HighExit_s)
         + β₃(HCBS_j × HighExit_s) + β₇(Post-ARPA_t × HCBS_j × HighExit_s) + ε_{sjt}
```
Where j indexes provider type (HCBS vs non-HCBS), s indexes state, t indexes month. β₇ is the coefficient of interest.

## Planned Robustness Checks
1. Alternative exit definitions (3-month, 6-month, 12-month billing cessation thresholds)
2. Rambachan-Roth HonestDiD sensitivity analysis for parallel trends violations
3. Randomization inference (permute exit intensity across states)
4. Placebo event dates (March 2019 for Part 1; April 2020 for Part 2)
5. Leave-one-state-out jackknife
6. Callaway-Sant'Anna estimator as alternative to OLS event study
7. Bartik instrument diagnostics (Goldsmith-Pinkham et al. Rotemberg weights)
8. Alternative exit intensity measures (count-based vs spending-share-based)

## Exposure Alignment (DiD Requirements)
- **Who is treated:** States with above-median pre-COVID Medicaid provider exit rates
- **Primary estimand population:** Medicaid HCBS and behavioral health providers
- **Placebo/control population:** Non-HCBS Medicaid providers (for Part 2 DDD); low-exit states (for Part 1)
- **Design:** Part 1: Continuous-treatment event study; Part 2: DDD

## Power Assessment
- **Pre-treatment periods:** 26 months (Jan 2018 – Feb 2020) for Part 1; 38 months (Jan 2018 – Mar 2021) for Part 2
- **Treatment clusters:** 50 states + DC (continuous treatment in Part 1; all states in Part 2 DDD)
- **Post-treatment periods:** 57 months (Mar 2020 – Dec 2024) for Part 1; 45 months (Apr 2021 – Dec 2024) for Part 2
- **Monthly provider panel:** ~400K+ active billing NPIs × 84 months aggregated to state × provider-type × month

## Data Sources
| Source | Variables | Access |
|--------|-----------|--------|
| T-MSIS Parquet | Provider billing, claims, beneficiaries, spending | Local download (2.74 GB) |
| NPPES Bulk | State, ZIP, specialty, enumeration/deactivation dates | CMS download |
| Census ACS | State demographics, poverty, insurance rates | CENSUS_API_KEY |
| FRED | State unemployment rates | FRED_API_KEY |
| CDC COVID Deaths | State-month COVID mortality | data.cdc.gov Socrata |
| CDC Drug Overdose | State-month provisional overdose deaths | data.cdc.gov Socrata |
| OxCGRT | State-level COVID policy stringency | GitHub CSV |
| Census ZCTA-County | ZIP-to-county crosswalk | Direct download |
