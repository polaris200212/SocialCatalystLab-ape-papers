# Initial Research Plan: The Visible and the Invisible

## Research Question

Does political visibility — proxied by traffic exposure — cause differential maintenance quality for public infrastructure? When more voters observe a bridge daily, does it deteriorate more slowly and get repaired faster?

## Identification Strategy

**Primary approach: Doubly Robust (AIPW) estimation** using bridge-level panel data from the National Bridge Inventory (NBI), 2000-2023.

**Treatment:** High-visibility bridges (top tercile of Average Daily Traffic within state) vs. low-visibility bridges (bottom tercile).

**Covariates for unconfoundedness:** Bridge age, material type, design load, span length, number of spans, functional classification, climate zone (from NOAA), deck area, and state fixed effects. These are the engineering determinants of bridge condition — conditional on these, ADT variation reflects visibility (who sees the bridge), not inherent quality differences.

**Key identification tests:**

1. **Electoral Maintenance Cycle:** Interact ADT tercile × gubernatorial election year. If maintenance is politically motivated, high-ADT bridges should receive disproportionate investment in election years. This separates "political visibility" from "economic importance."

2. **Lagged ADT to prevent reverse causality:** Use INITIAL (year-2000) ADT as the exposure measure, predetermined relative to subsequent maintenance decisions.

3. **Negative control outcome:** Substructure condition (underwater, invisible to voters) should show NO visibility premium if the mechanism is political monitoring. Deck condition (visible from the road) should.

4. **E-value sensitivity analysis:** Report how strong unmeasured confounding would need to be to explain the results.

## Expected Effects and Mechanisms

**Primary prediction:** High-ADT bridges deteriorate more slowly (conditional on engineering characteristics) because:
- More voter complaints when conditions deteriorate
- Greater media coverage of poor conditions on busy roads
- Higher political cost of bridge failure/closure on busy routes
- State DOTs face pressure to prioritize visible infrastructure

**Heterogeneity predictions:**
- Effect larger in competitive election states (close gubernatorial races)
- Effect larger for DECK condition (visible) than SUBSTRUCTURE (invisible)
- Effect attenuates for term-limited governors (reduced political incentive)
- Effect larger in states with more media capacity (newspapers per capita)

**Magnitude:** Based on engineering deterioration models, a typical bridge loses ~0.1 condition rating points per year. We predict high-ADT bridges deteriorate 20-40% more slowly (0.06-0.08 per year), conditional on engineering characteristics.

## Primary Specification

$$\Delta C_{ijt} = \alpha + \beta \cdot HighADT_i + X_i'\gamma + \delta_j + \mu_t + \varepsilon_{ijt}$$

Where:
- $\Delta C_{ijt}$ = annual change in condition rating for bridge $i$ in state $j$ at time $t$
- $HighADT_i$ = indicator for top-tercile ADT (measured at initial observation)
- $X_i$ = engineering covariates (age, material, design, span, deck area)
- $\delta_j$ = state fixed effects
- $\mu_t$ = year fixed effects

**DR version:** AIPW with SuperLearner for both propensity score (P(HighADT | X)) and outcome regression (E[ΔC | X, ADT]).

## Planned Robustness Checks

1. Continuous ADT (log) instead of tercile indicator
2. Different ADT cutoffs (median, quartiles)
3. Alternative ML methods for nuisance estimation (XGBoost, random forest, LASSO)
4. Trimming extreme propensity scores (0.01, 0.05, 0.10)
5. Bridge-level fixed effects (within-bridge variation over time)
6. Exclude bridges that underwent major reconstruction
7. Placebo test: effect on bridges < 5 years old (too new to differ)
8. State-by-year fixed effects (absorb all state-level policy variation)

## Data Sources

1. **National Bridge Inventory (NBI):** ~621,000 bridges × 24 years = ~15M bridge-years. Condition ratings (0-9), ADT, engineering characteristics, GPS coordinates. FHWA download.
2. **Governor election data:** State election years and margins from public records.
3. **Climate data:** NOAA climate zones or HDD/CDD from FRED by state.
4. **Census demographics:** County population, income from Census API.

## Power Assessment

- ~620,000 bridges per year, 24 years of data
- Top/bottom tercile: ~207,000 bridges per group
- With state + year FE and engineering covariates, residual SD of ΔC ≈ 0.3
- MDE at 80% power, α=0.05: ~0.001 rating points per year
- Expected effect: 0.02-0.04 rating points per year
- **Extremely well-powered.** Power is not a concern with 15M observations.
