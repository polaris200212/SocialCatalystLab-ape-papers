# Initial Research Plan — apep_0471

## Research Question

Does welfare simplification encourage entrepreneurship? Specifically, did the staggered rollout of Universal Credit's full service across UK Local Authorities (2015-2018) affect firm formation and self-employment rates?

## Policy Background

Universal Credit (UC) replaced six legacy benefits (JSA, ESA, Income Support, Housing Benefit, Working Tax Credit, Child Tax Credit) with a single monthly payment. Key features for self-employment:

1. **Unified 55% taper rate** — under legacy benefits, self-employed claimants faced complex interactions across multiple benefits with different taper rates, creating uncertainty about marginal returns to effort
2. **Minimum Income Floor (MIF)** — after a 12-month "start-up period," UC assumes self-employed claimants earn at least NMW × expected hours, reducing entitlement for low earners
3. **Real-time earnings verification (RTI)** — HMRC integration automatically tracks earnings, reducing the informal economy incentive

The net effect on self-employment is theoretically ambiguous: simplification lowers entry barriers, but the MIF penalizes the low-earning self-employed.

## Identification Strategy

**Staggered Difference-in-Differences** exploiting month-level variation in UC full service rollout across ~300+ Local Authorities from November 2015 to December 2018.

- **Treatment:** UC full service go-live date for each LA (from DWP Transition Rollout Schedule PDF)
- **Estimator:** Callaway & Sant'Anna (2021) — robust to heterogeneous treatment effects and staggered adoption
- **Pre-treatment:** 2013-2015 (before any full service began)
- **Post-treatment:** Up to Q4 2019 (avoiding COVID)
- **Unit of analysis:** Local Authority × month (for Companies House) or LA × year (for NOMIS APS)

## Exposure Alignment (DiD)

- **Who is treated?** Benefit claimants in LAs where UC full service has been rolled out. The full service covers all claimant types (singles, couples, families).
- **Primary estimand population:** All potential entrepreneurs/self-employed in treated LAs. Treatment affects the entire local labour market via general equilibrium (benefit claimants' behaviour affects vacancy filling, wage setting, and informal competition).
- **Placebo/control population:** (a) LAs not yet treated (not-yet-treated comparison); (b) High-wage sectors where benefit interactions are minimal (within-LA placebo).
- **Design:** Standard DiD with staggered treatment timing.

## Expected Effects and Mechanisms

1. **Net effect on firm formation:** Ambiguous sign. Simplification channel predicts positive; MIF channel predicts negative (especially after 12 months post-treatment).
2. **Composition:** UC may shift the type of firms formed — more personal service companies (reflecting formalization) but potentially fewer sole traders (MIF discouragement).
3. **Dynamic effects:** Expect initial increase (start-up period shield), then potential decline after 12 months as MIF binds.
4. **Heterogeneity:** Effects should be larger in LAs with (a) higher baseline benefit claimant shares, (b) lower pre-existing self-employment rates, (c) sectors with high self-employment propensity (construction, professional services, transport).

## Primary Specification

$$Y_{it} = \alpha_i + \lambda_t + \tau_{CS-DiD} \cdot D_{it} + \epsilon_{it}$$

Where:
- $Y_{it}$: Monthly new company registrations per 1,000 working-age population in LA $i$, month $t$
- $D_{it}$: Treatment indicator (= 1 after UC full service goes live in LA $i$)
- $\alpha_i, \lambda_t$: LA and time fixed effects
- $\tau_{CS-DiD}$: Group-time ATT estimated via Callaway & Sant'Anna

## Planned Robustness Checks

1. **Event study:** Dynamic treatment effects plot to assess pre-trends (joint F-test) and dynamic response
2. **Alternative outcomes:** NOMIS self-employment rates (annual), firm dissolution rates
3. **Placebo tests:**
   - High-income areas (low benefit dependency) as within-sample control
   - Firm formation in sectors with no self-employment propensity (e.g., public administration, utilities)
4. **Alternative estimators:** Sun & Abraham (2021), de Chaisemartin & d'Haultfoeuille (2020) for robustness
5. **Heterogeneity:** By baseline benefit claimant rate, sector (SIC 1-digit), LA deprivation quintile
6. **Inference:** Cluster at LA level. Wild cluster bootstrap as sensitivity. Randomization inference if concerns about few effective clusters per wave.
7. **MIF timing test:** Compare effects 0-12 months post-treatment (start-up period) vs 12+ months (MIF binding)

## Power Assessment

- **Pre-treatment periods:** ~24-36 months (Jan 2013 - Oct 2015)
- **Treated clusters:** 300+ LAs (staggered across 37 monthly waves)
- **Post-treatment periods per cohort:** 12-48 months depending on wave
- **MDE:** With ~300 LAs and monthly data, power should be sufficient to detect 2-3% changes in firm formation rates. Exact power calculation will be conducted after assembling the panel.

## Data Sources

1. **Treatment dates:** DWP Transition Rollout Schedule (PDF, already downloaded)
2. **Firm formation:** Companies House BasicCompanyData bulk CSV (~5GB, free download). IncorporationDate × RegAddress.PostCode → ONS NSPL → LA mapping.
3. **Self-employment rates:** NOMIS API, dataset NM_17_5 (Annual Population Survey), variable 73 (self-employment rate 16+), geography TYPE464, 2004-2024.
4. **Population denominators:** ONS mid-year population estimates via ONS API or NOMIS.
5. **Covariates:** NOMIS (unemployment rate, earnings), ONS (deprivation indices).
6. **Postcode → LA mapping:** ONS National Statistics Postcode Lookup (NSPL).

## Code Structure

- `00_packages.R` — Load libraries, set themes
- `01_fetch_data.R` — Download Companies House, NOMIS, NSPL, construct treatment dates
- `02_clean_data.R` — Build LA × month panel, merge treatment dates, construct variables
- `03_main_analysis.R` — Callaway & Sant'Anna estimation, event study
- `04_robustness.R` — Alternative estimators, placebos, heterogeneity
- `05_figures.R` — Event study plots, maps, descriptive figures
- `06_tables.R` — Summary statistics, regression tables
