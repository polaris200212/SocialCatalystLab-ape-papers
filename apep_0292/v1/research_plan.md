# Initial Research Plan: Mandatory Energy Disclosure and the Information Premium in Commercial Real Estate

## Research Question

Does mandatory building energy benchmarking and disclosure affect property values and investment behavior? Specifically, does New York City's Local Law 84 (LL84) — which requires buildings above 25,000 square feet to publicly disclose energy and water performance — create an "information premium" in commercial real estate markets?

## Institutional Background

NYC Local Law 84 (2009) initially required buildings over 50,000 sq ft to annually benchmark energy and water consumption via EPA's Portfolio Manager. In 2016, the threshold was lowered to 25,000 sq ft, bringing approximately 12,000 additional buildings under the mandate. During 2016–2019, the 25,000 sq ft threshold was the ONLY energy regulation at that cutoff: LL87 (energy audits) applied at 50,000 sq ft, and LL97 (emission caps) was not enacted until 2019 with compliance starting in 2024.

This institutional setting creates a clean regression discontinuity: buildings just above 25,000 sq ft must publicly disclose energy performance; buildings just below face no such requirement.

## Identification Strategy

**Design:** Sharp regression discontinuity at 25,000 sq ft gross floor area.

**Running variable:** Building gross floor area (GFA) in square feet, from NYC PLUTO (Primary Land Use Tax Lot Output) database. PLUTO records are based on Department of Finance assessments and building construction records — they are administratively determined, not self-reported by building owners. This limits manipulation.

**Treatment:** Mandatory annual energy and water benchmarking disclosure under LL84.

**Key assumption:** Buildings just above and below 25,000 sq ft are comparable in all dimensions except disclosure status. We verify this with covariate balance tests.

**Why manipulation is unlikely:** Building GFA is determined by physical construction and recorded in city property records decades before LL84's expansion. Altering a building's GFA requires costly construction (adding or demolishing floors). For the vast majority of NYC's building stock — constructed well before 2016 — the 25,000 sq ft threshold was not a consideration during construction.

## Expected Effects and Mechanisms

### Information Channel
**Hypothesis H1:** If energy disclosure resolves information asymmetry (Akerlof 1970), buildings above the threshold experience a separation of "lemons" from "peaches." Average assessed values may increase if the market previously undervalued efficient buildings, or decrease if inefficient buildings were previously overvalued. The NET effect is ambiguous ex ante.

### Investment Channel
**Hypothesis H2:** Mandatory disclosure creates reputational incentives. Building owners above the threshold invest in energy efficiency improvements to improve their public Energy Star score. We test this with building permit data.

### Compliance Cost Channel
**Hypothesis H3:** Benchmarking compliance imposes costs (data collection, consultant fees, Portfolio Manager entry). If compliance costs dominate any information benefits, property values may decrease at the threshold. This predicts a NEGATIVE discontinuity.

### Null Hypothesis
**Hypothesis H0:** If the real estate market already internalized energy performance information (through utility bills during due diligence, broker knowledge, or tenant negotiations), disclosure adds nothing new. The RDD estimates zero — challenging the rationale for benchmarking mandates.

## Primary Specification

For building $i$ in neighborhood $n$:

$$Y_i = \alpha + \tau D_i + f(X_i - c) + D_i \cdot g(X_i - c) + \gamma Z_i + \varepsilon_i$$

where:
- $Y_i$: outcome (log assessed value, log sale price, building permit indicator)
- $D_i$: indicator for $X_i \geq 25{,}000$ (LL84 treatment)
- $X_i$: building gross floor area
- $c = 25{,}000$: threshold
- $f(\cdot), g(\cdot)$: local polynomial functions (MSE-optimal bandwidth, Cattaneo et al. 2020)
- $Z_i$: predetermined covariates (year built, land use class, borough)

## Data Sources

1. **NYC PLUTO** (Socrata API): All NYC tax lots. Provides GFA, assessed values, year built, land use, number of units, floors, building class, ZIP code, borough. Available for all buildings regardless of LL84 status. Annual releases.

2. **NYC LL84 Benchmarking** (Socrata API): Energy and water performance for buildings >25K sq ft. Provides Energy Star score, site EUI (kBtu/ft²), source EUI, GHG emissions, water usage. Annual data from 2016+.

3. **NYC DOF Rolling Sales** (Socrata API): Property sales with prices, dates, building class, neighborhood. Used for hedonic price analysis near the threshold.

4. **NYC DOB Permits** (Socrata API): Building permits for all buildings. Used to measure investment response (energy-related permits).

## Planned Robustness Checks

1. **McCrary density test** (rddensity): Test for bunching at 25,000 sq ft.
2. **Covariate balance**: Year built, building class, number of floors, borough should be smooth at cutoff.
3. **Bandwidth sensitivity**: MSE-optimal bandwidth ± 50%, 75%, 125%, 150%.
4. **Polynomial order**: Linear, quadratic, cubic local polynomials.
5. **Donut RDD**: Exclude buildings within ±500 and ±1,000 sq ft of cutoff.
6. **Placebo cutoffs**: Test at 20,000, 30,000, 35,000, 40,000, 45,000 sq ft.
7. **Pre-policy test**: Same RDD before LL84 expansion (pre-2016) — should find no effect.
8. **Building cohort split**: Pre-2000 construction (threshold irrelevant at construction) vs. post-2009 construction (potential anticipation).
9. **Heterogeneity by building type**: Residential vs. commercial vs. mixed-use.
10. **Heterogeneity by energy performance**: Among LL84-compliant buildings, does the value premium increase with Energy Star score?

## Analysis Pipeline

| Script | Purpose |
|--------|---------|
| 00_packages.R | Load libraries, set APEP theme |
| 01_fetch_data.R | Fetch PLUTO, LL84, DOF sales, DOB permits via Socrata API |
| 02_clean_data.R | Merge datasets, construct variables, restrict sample |
| 03_main_analysis.R | RDD estimation with rdrobust, main results |
| 04_robustness.R | All robustness checks, placebo tests, heterogeneity |
| 05_figures.R | RDD plots, density plots, covariate balance figures |
| 06_tables.R | Results tables in LaTeX format |

## Outcome Variables (Primary)

1. **Log assessed total value** (PLUTO: assesstot) — most comprehensive, available for all buildings
2. **Building permit count** (DOB: number of permits filed in post-2016 window) — investment response
3. **Log sale price per sq ft** (DOF: conditional on transaction) — market valuation

## Timeline and Risks

**Risk 1:** Building GFA might not be available for enough buildings near 25K sq ft. Mitigated by NYC's enormous building stock.

**Risk 2:** The LL84 Socrata dataset may not include buildings that were required but failed to comply. Non-compliance introduces measurement error in treatment.

**Risk 3:** The 25K threshold may not be perfectly enforced (some below-threshold buildings report voluntarily). This makes the RDD fuzzy rather than sharp.

**Risk 4:** Assessed values respond slowly to market conditions. We supplement with sales prices (faster response) where available.
