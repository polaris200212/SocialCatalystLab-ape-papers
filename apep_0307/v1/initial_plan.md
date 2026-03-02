# Initial Research Plan: Does Medicaid Disenrollment Destroy Provider Networks?

## Research Question

Does the staggered termination of Medicaid continuous enrollment (the "unwinding") cause HCBS provider exit and market concentration increases? We test whether enrollment shocks to a 100% Medicaid-dependent sector produce irreversible supply-side damage.

## Identification Strategy

**Staggered Difference-in-Differences.** States initiated Medicaid terminations between April 2023 and mid-2024, with most starting April-July 2023. We exploit this state-level timing variation using the Callaway and Sant'Anna (2021) heterogeneity-robust estimator.

**Treatment definition:** Binary indicator for whether state *s* has initiated Medicaid unwinding terminations by month *t*. Treatment groups defined by the month of first termination (April, May, June, July 2023, or later).

**Treatment intensity:** Continuous measure using state-level disenrollment rate (share of enrollees terminated) as treatment intensity. Ex parte renewal rate serves as an instrument for disenrollment intensity (administrative capacity → procedural disenrollment → provider exit).

**Key identifying assumption:** Conditional on state and time fixed effects, the timing of unwinding initiation is orthogonal to pre-existing trends in provider exit. The timing was determined by state administrative capacity and political will, not by provider market conditions.

## Expected Effects and Mechanisms

**Primary mechanism:** Medicaid unwinding reduces beneficiary enrollment → HCBS providers (100% Medicaid-dependent, no Medicare equivalent) lose patients → revenue declines below viability threshold → providers exit market.

**Expected findings:**
1. States with earlier/more aggressive unwinding see higher HCBS provider exit rates (extensive margin)
2. Surviving providers see billing volume declines (intensive margin)
3. Small providers (individual billers, sole proprietors) are more likely to exit than large organizations
4. HCBS market concentration (HHI) increases as small providers exit and large chains absorb market share
5. Effects are concentrated in HCBS/behavioral codes (T, H, S prefixes) — not CPT professional services where providers have Medicare as alternative revenue

**Null hypothesis that would be interesting:** If providers do NOT exit despite enrollment declines, it suggests (a) providers absorb temporary losses expecting re-enrollment, (b) states backfill revenue through rate increases, or (c) providers substitute toward private-pay or other payer sources.

## Primary Specification

$$Y_{st} = \alpha + \sum_{g} \sum_{t \neq g-1} \beta_{g,t} \cdot \mathbb{1}[G_s = g] \cdot \mathbb{1}[T = t] + \gamma_s + \delta_t + \epsilon_{st}$$

Where:
- $Y_{st}$: Outcome for state *s* in month *t* (provider exit rate, log billing volume, HHI)
- $G_s$: Treatment group (month state *s* initiates unwinding)
- $\gamma_s$: State fixed effects
- $\delta_t$: Time fixed effects
- $\beta_{g,t}$: Group-time average treatment effects

Aggregation: Simple weighted average ATT across all groups and post-treatment periods.

## Exposure Alignment (DiD-Specific)

**Who is actually treated?** All Medicaid providers in states that initiate unwinding terminations. The "treatment" is the state-level enrollment shock.

**Primary estimand population:** HCBS providers (billing T, H, S HCPCS codes) — these are 100% Medicaid-dependent with no alternative payer.

**Placebo/control population:** Providers billing CPT professional services (99xxx codes) who also bill Medicare — these have diversified revenue and should be less affected.

**Design:** Standard two-way DiD with staggered adoption. Later-unwinding states serve as not-yet-treated controls for early unwinders.

## Power Assessment

- **Pre-treatment periods:** 63 months (January 2018 - March 2023) — far exceeds minimum 5
- **Treated clusters:** 50 states + DC — far exceeds minimum 20
- **Post-treatment periods per cohort:** 12-21 months (depending on cohort timing)
- **Effective sample:** ~50 states × 84 months = ~4,200 state-month observations
- **Provider-level:** 617K providers × 84 months (though highly unbalanced panel)
- **MDE assessment:** With 50 clusters and 63 pre-periods, detectable effects should be very small. Formal MDE computed after constructing panel.

## Planned Robustness Checks

1. **Sun-Abraham (2021)** interaction-weighted estimator as alternative to CS-DiD
2. **SDID** (synthetic DiD) for small-sample robustness
3. **Treatment intensity:** Replace binary treatment with continuous disenrollment rate
4. **Event study:** Dynamic treatment effects with leads/lags to assess pre-trends
5. **Placebo test on Medicare-only providers:** Providers billing only CPT codes with Medicare alternative should show no effect
6. **Permutation inference:** Randomization-based p-values to address cluster-level inference
7. **Leave-one-out:** Sequential exclusion of each state to test sensitivity
8. **Alternative exit definitions:** 3-month, 6-month, 12-month non-billing thresholds
9. **Bacon decomposition:** Identify clean 2×2 DiD comparisons vs. problematic ones
10. **Wild cluster bootstrap:** Cluster-robust inference at state level

## Data Pipeline

1. **T-MSIS Provider Spending** (2.9GB Parquet, opendata.hhs.gov) — full dataset needed
2. **NPPES Bulk Extract** (~7GB, download.cms.gov) — for state/specialty/entity type assignment
3. **CMS Unwinding Reports** (public Excel/PDF) — state-level timing and disenrollment rates
4. **Census ACS 5-year** (Census API) — Medicaid enrollment per capita by state for denominators
5. **BLS QCEW** (bls.gov) — healthcare employment for triangulation

## Analysis Code Structure

- `00_packages.R` — Load libraries
- `01_fetch_data.R` — Download T-MSIS, NPPES, treatment timing
- `02_clean_data.R` — NPI linkage, state assignment, panel construction
- `03_main_analysis.R` — CS-DiD, event studies, treatment effects
- `04_robustness.R` — Sun-Abraham, SDID, permutation inference, placebos
- `05_figures.R` — Event study plots, maps, descriptive figures
- `06_tables.R` — Summary statistics, regression tables

## Paper Outline

1. **Introduction** — Hook with unwinding statistics; motivation (supply-side gap); preview of findings
2. **Background** — Medicaid unwinding timeline; HCBS provider landscape; why supply-side matters
3. **Data** — T-MSIS description; NPPES linkage; outcome construction; sample statistics
4. **Empirical Strategy** — Staggered DiD setup; identifying assumptions; threats
5. **Results** — Main treatment effects; event studies; heterogeneity
6. **Market Concentration** — HHI analysis; firm-level responses; small vs. large providers
7. **Robustness** — Alternative estimators, placebos, inference
8. **Discussion** — Policy implications (OBBBA work requirements); welfare implications
9. **Conclusion** — Summary; what this means for the future of HCBS
