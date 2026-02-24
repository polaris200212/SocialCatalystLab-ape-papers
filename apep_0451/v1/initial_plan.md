# Initial Research Plan — apep_0451

## Research Question

How did the 2000s global cocoa price boom affect human capital accumulation in Ghana's cocoa-producing regions? Specifically, did the tripling of world cocoa prices between 2000 and 2010 increase or decrease school enrollment, educational attainment, and child labor in regions with high cocoa production intensity?

## Identification Strategy

**Design:** Doubly-Robust Difference-in-Differences (Sant'Anna and Zhao, 2020) applied to repeated cross-sections from the Ghana Population and Housing Census (1984, 2000, 2010) via IPUMS International.

**Treatment intensity:** Continuous regional cocoa production share (CocoaShare_r) interacted with world cocoa price changes (Bartik/shift-share design). Treatment_rt = CocoaShare_r × log(CocoaPrice_t).

**Comparison group:** Main specification restricts to 6 forest-belt regions (Western, Central, Eastern, Ashanti, Brong-Ahafo, Volta) that share ecological and economic structure but vary in cocoa intensity. High-cocoa: Western (~55%), Ashanti (~20%), Brong-Ahafo (~15%), Eastern (~8%). Low-cocoa: Central (~2%), Volta (<1%).

**Pre-trends:** Test using the 1984→2000 period (cocoa prices were flat/declining) as a falsification exercise. If treatment intensity was not correlated with outcome changes in 1984-2000, the parallel trends assumption for 2000-2010 gains credibility.

**Inference:** Wild cluster bootstrap at the region level (Cameron, Gelbach, Miller 2008). Also report permutation-based inference.

## Expected Effects and Mechanisms

**Theoretical ambiguity:** Commodity booms have two opposing effects on schooling:

1. **Income effect (+):** Higher cocoa prices raise household income, reducing credit constraints for school fees and materials. Predicts INCREASED enrollment.

2. **Substitution effect (-):** Higher returns to cocoa farming raise the opportunity cost of schooling. Children may be pulled into cocoa harvesting. Predicts DECREASED enrollment, increased child labor.

**Prior:** Based on the literature (Kruger 2007 on Brazilian coffee; Edmonds et al. on Vietnam rice), the substitution effect tends to dominate for older children (secondary school age), while the income effect dominates for younger children (primary school age). Expect heterogeneity by age group.

**Mechanisms to test:**
- Age heterogeneity (primary vs. secondary school age)
- Gender heterogeneity (boys more likely pulled into farm labor)
- Agricultural sector employment growth in cocoa regions

## Primary Specification

Y_irt = α + β(CocoaShare_r × Post2010_t) + X_irt'γ + μ_r + δ_t + ε_irt

Where:
- Y_irt: outcome (enrolled in school, completed primary, works in agriculture) for individual i in region r in year t
- CocoaShare_r: baseline share of cocoa production in region r (fixed at pre-treatment levels)
- Post2010_t: indicator for 2010 census (vs. 2000)
- X_irt: individual covariates (age, sex, urban/rural, household size)
- μ_r: region fixed effects
- δ_t: year fixed effects

DR implementation: Sant'Anna & Zhao (2020) AIPW estimator via R `DRDID` package, with dichotomized treatment (above/below median cocoa share) and continuous treatment robustness.

## Planned Robustness Checks

1. **Pre-trends test:** Repeat main specification for 1984-2000 period (no cocoa boom). β should be statistically zero.
2. **Full 10-region sample:** Include Greater Accra and northern regions (broader comparison).
3. **Forest-belt only, excluding Volta:** Tighter ecological comparison.
4. **Rural subsample:** Restrict to rural areas where cocoa effects are concentrated.
5. **Agricultural subsample:** Estimate effect among agricultural workers specifically.
6. **Migration test:** Compare working-age population growth and inter-regional migration rates across cocoa vs. non-cocoa regions.
7. **Age-specific effects:** Separate estimates for ages 6-11 (primary), 12-17 (secondary), 18-24 (post-secondary).
8. **Gender heterogeneity:** Separate estimates for males and females.
9. **Alternative treatment measures:** Binary high/low cocoa classification; district-level variation using GEO2_GH if feasible.
10. **Permutation inference:** Randomly reassign cocoa shares across regions to construct null distribution.

## Exposure Alignment

**Who is treated:** Households in cocoa-producing regions who benefit from higher cocoa incomes. Treatment is mediated through COCOBOD's farmgate price (50-70% pass-through of world prices).

**Primary estimand population:** All residents of forest-belt regions, weighted by regional cocoa production share (Bartik exposure measure). The DR DiD compares high-cocoa regions (Western, Ashanti, Brong Ahafo, Eastern) vs. low-cocoa regions (Central, Volta).

**Placebo/control population:** Residents of low-cocoa forest-belt regions who share ecological conditions but lack substantial cocoa production.

**Design:** Two-period DiD (2000 vs 2010) with pre-trend validation (1984-2000). Not staggered — common shock (world price) with continuous regional exposure variation.

**Intent-to-treat dilution:** Estimates capture ITT effects on full regional population, not just cocoa farming households. This attenuates relative to effects on directly affected families.

## Power Assessment

- Individuals per region-year: ~200,000-250,000 (10% census sample)
- Total sample (2 main periods, 6 regions): ~2.5-3.0M individuals
- Treatment variation: continuous (CocoaShare ranges from <1% to ~55%)
- With 6 clusters in forest-belt specification, inference requires wild bootstrap
- MDE depends on outcome: school enrollment rates (~60-80%), so detecting a 2-3 pp change should be feasible with millions of observations, though cluster-level variation constrains effective degrees of freedom

## Data Sources

1. **IPUMS International:** Ghana Population and Housing Census 1984, 2000, 2010 (confirmed accessible via API; ~5.7M total person records)
2. **FRED:** World cocoa prices (PCOCOUSDM, monthly from 2003; supplemented with World Bank Pink Sheet for earlier years)
3. **Regional cocoa shares:** From COCOBOD annual reports and academic literature (Vigneri 2005, Kolavalli & Vigneri 2011). Will hard-code shares based on published data.
4. **DHS STATcompiler:** Supplementary health/fertility outcomes by region (7 rounds, 1988-2022) for extended pre-trends analysis.
