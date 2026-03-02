# Initial Research Plan: Low Emission Zone Boundaries and Property Values

## Research Question

Do low emission zones (Zones à Faibles Émissions, ZFE) affect property values in French cities? Specifically, does a property price discontinuity emerge at ZFE boundaries after implementation, and does the effect vary by property type, neighborhood income, and transit access?

## Identification Strategy

**Spatial Regression Discontinuity Design (Spatial RDD)**

- **Running variable:** Signed geodesic distance from each DVF property transaction to the nearest ZFE boundary polygon. Positive values = inside ZFE; negative = outside.
- **Cutoff:** Distance = 0 (the ZFE boundary).
- **Treatment:** Being inside the ZFE, where polluting vehicles (below certain Crit'Air levels) are banned.
- **Bandwidth:** Data-driven optimal bandwidth selection (Calonico, Cattaneo, and Titiunik 2014; rdrobust package in R).
- **Polynomial:** Local linear regression, with local quadratic as robustness.

**Multi-city design:** Pool transactions near ZFE boundaries across Paris (Grand Paris Métropole, A86), Lyon, Grenoble, Strasbourg, and other available cities. City fixed effects absorb level differences; the RDD identifies the boundary discontinuity within each city.

**Temporal dimension:** Compare boundary effects before vs. after ZFE implementation (event study within RDD). Pre-ZFE smoothness validates the design.

## Expected Effects and Mechanisms

The sign is genuinely ambiguous ex ante:

**Positive price effect inside ZFE (appreciation):**
- Cleaner air and reduced noise → environmental amenity premium
- Status/green signaling → demand from environmentally conscious buyers
- Reduced traffic → improved pedestrian environment

**Negative price effect inside ZFE (depreciation):**
- Reduced accessibility for car-dependent households
- Enforcement uncertainty and political backlash
- Disproportionate burden on lower-income residents with older vehicles

**Heterogeneity predictions:**
- Effect should be stronger near public transit (complementary amenity)
- Effect may differ for apartments vs. houses (car dependency)
- Higher-income neighborhoods may show premium; lower-income may show discount

## Primary Specification

```
log(price_sqm)_it = α + τ · 1(inside_ZFE)_i + f(distance_i) + X_i'β + γ_city + δ_year + ε_it
```

Where:
- `price_sqm` = transaction price per square meter
- `1(inside_ZFE)` = indicator for property inside the ZFE polygon
- `f(distance)` = local polynomial in signed distance to boundary
- `X_i` = property controls (surface area, rooms, building type, lot count)
- `γ_city` = city fixed effects
- `δ_year` = year fixed effects

Estimated using rdrobust with MSE-optimal bandwidth and triangular kernel.

## Data Sources

1. **DVF (Demandes de Valeurs Foncières):** Bulk CSV from data.gouv.fr, 2018-2024 (covering pre- and post-ZFE periods). ~3.8M transactions/year, 98.6% geocoded.
2. **ZFE boundaries:** GeoJSON polygons from city open data portals (Paris, Lyon, Grenoble, Strasbourg, Marseille, others).
3. **ZFE implementation dates:** From official city decrees and Légifrance.
4. **Controls:** Property characteristics from DVF itself (type_local, surface_reelle_bati, nombre_pieces_principales, nombre_lots).

## Planned Robustness Checks

1. **McCrary density test:** Test for bunching of transactions at the boundary.
2. **Pre-ZFE placebo:** Run RDD on pre-implementation data — should find no discontinuity.
3. **Covariate balance:** Test for discontinuities in property characteristics at the boundary.
4. **Bandwidth sensitivity:** Half-bandwidth, double-bandwidth, CER-optimal bandwidth.
5. **Polynomial order:** Local linear vs. local quadratic.
6. **Donut hole:** Exclude transactions within 100m of boundary (avoid boundary measurement error).
7. **City-by-city:** Estimate separately for each city to check consistency.
8. **Placebo boundaries:** Artificial boundaries 500m inside and outside the real boundary.
9. **Temporal dynamics:** Year-by-year estimates before and after ZFE implementation.

## Power Assessment

- **Sample size near boundary:** With ~3.8M transactions/year across France and 6+ years of data, even within narrow bandwidths (e.g., 500m from boundary) across multiple cities, we expect tens of thousands of observations.
- **Effect size:** Comparable LEZ studies in Germany find ~2% rent effects (JEEM 2025). A 2% effect on property prices should be detectable given the sample size.
- **Multiple cities:** Pooling across Paris, Lyon, Grenoble, Strasbourg provides both statistical power and external validity.

## Paper Structure

1. Introduction: ZFE as climate policy with spatial inequality implications
2. Institutional Background: French ZFE policy, Crit'Air system, city-level implementation
3. Data: DVF transactions + ZFE boundary polygons
4. Empirical Strategy: Spatial RDD design, validity tests
5. Results: Main estimates, heterogeneity
6. Robustness: Pre-period placebos, bandwidth sensitivity, donut holes
7. Discussion: Welfare implications, distributional effects
8. Conclusion
