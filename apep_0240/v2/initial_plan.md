# Initial Research Plan: Flood Risk Disclosure Laws and Housing Market Capitalization

## Research Question

Do state-level flood risk disclosure laws cause housing prices in flood-prone areas to decline relative to non-flood-prone areas? In other words, does mandatory disclosure of flood risk to homebuyers lead to more complete capitalization of flood risk into housing prices?

## Identification Strategy

**Staggered Difference-in-Differences with Triple-Differencing**

Treatment: State adoption of mandatory seller disclosure laws that include flood risk/history content. Approximately 28 states adopted such laws between 1992 and 2024, while ~14 states (AL, AR, AZ, GA, ID, KS, MA, MO, MT, NM, UT, VA, WV, WY) never adopted mandatory flood disclosure requirements.

The triple-difference design exploits three sources of variation:
1. **Across states**: Treated (adopted disclosure law) vs. never-treated states
2. **Across time**: Before vs. after law adoption within treated states
3. **Across flood exposure**: High-flood-exposure counties vs. low-flood-exposure counties within each state

This design identifies the causal effect of disclosure under the assumption that within-state trends in the housing price gap between flood-exposed and non-flood-exposed counties would have been parallel absent the disclosure law.

## Exposure Alignment

- **Who is actually treated?** Homebuyers in states that adopt flood disclosure laws, particularly those purchasing properties in flood-prone areas.
- **Primary estimand population:** Counties with high flood exposure in treated states.
- **Placebo/control population:** Counties with low flood exposure in treated states (within-state control); all counties in never-treated states (across-state control).
- **Design:** Triple-diff (DDD): state × flood_exposure × post

## Expected Effects and Mechanisms

**Primary hypothesis:** Disclosure laws reduce housing prices in flood-prone areas by forcing sellers to reveal flood risk information that buyers would not otherwise observe. This capitalizes previously hidden risk into prices.

**Expected magnitude:** Based on the Fannie Mae Texas study (4.2% decline in 500-year flood zones after SB 339), we expect a 2-5% decline in flood-exposed county housing values relative to non-flood-exposed counties after disclosure adoption.

**Mechanisms to test:**
1. **Information channel:** Disclosure provides new information → prices adjust downward in risky areas
2. **Sorting channel:** Informed buyers avoid flood zones → demand shifts to non-flood areas → relative price decline in flood areas
3. **Insurance channel:** Disclosure increases awareness → higher flood insurance take-up → reduction in perceived uninsured risk

## Primary Specification

$$\log(ZHVI_{cst}) = \alpha + \beta_1 \cdot FloodExposure_c \times Post_{st} + \gamma_{cs} + \delta_{st} + \epsilon_{cst}$$

Where:
- $ZHVI_{cst}$ is Zillow Home Value Index for county $c$ in state $s$ at time $t$
- $FloodExposure_c$ is a county's flood exposure (measured by historical FEMA flood declarations, continuous or binary)
- $Post_{st}$ is an indicator for state $s$ having adopted disclosure law by time $t$
- $\gamma_{cs}$ are county-by-state fixed effects (absorb all time-invariant county characteristics)
- $\delta_{st}$ are state-by-time fixed effects (absorb all state-specific time trends)

The coefficient of interest $\beta_1$ captures the differential effect of disclosure on flood-exposed vs. non-flood-exposed counties within treated states. With CS-DiD, this is estimated heterogeneity-robustly.

## Power Assessment

- **Pre-treatment periods:** 10+ years (Zillow ZHVI available monthly from 2000; disclosure laws adopted 1992-2024)
- **Treated clusters:** ~28 states adopted flood disclosure laws
- **Post-treatment periods per cohort:** Varies; early adopters (1992-1998) have 25+ years post-treatment; recent adopters (2022-2024) have 1-3 years
- **MDE:** With ~3,100 counties across 50 states, even small effects (1-2%) should be detectable

## Planned Robustness Checks

1. **Event study plot:** Dynamic treatment effects for 5+ pre-treatment years and 5+ post-treatment years to verify parallel pre-trends
2. **Callaway-Sant'Anna estimator:** Heterogeneity-robust staggered DiD
3. **Bacon decomposition:** Examine relative contributions of clean vs. contaminated 2x2 comparisons
4. **Intensive margin:** Treatment intensity based on NRDC flood disclosure grades (A through F) rather than binary adoption
5. **Placebo tests:**
   - Counties with zero flood declarations should show no effect
   - States that adopted generic disclosure (without flood questions) should show weaker effects
6. **Alternative outcome:** Building permits in flood zones (does construction shift away from flood areas?)
7. **HonestDiD sensitivity analysis:** Test sensitivity to violations of parallel trends

## Data Sources

| Source | Variable | Granularity | API/Access |
|--------|----------|-------------|------------|
| Zillow Research | ZHVI (housing values) | County-month | Public CSV download |
| FEMA OpenFEMA | Disaster declarations | County-event | REST API (no key) |
| Census | Building permits | County-month/year | Census API |
| NRDC/Agent research | Disclosure law dates | State-year | Compiled from research |
| NOAA nClimDiv | PDSI (drought control) | State-month | Bulk CSV download |
