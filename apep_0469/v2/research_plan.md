# Initial Research Plan: Missing Men, Rising Women

## Research Question

How did WWII reshape the gender hierarchy in American economic life, and how much of the measured 1940-1950 gender convergence reflects genuine within-person female advancement versus compositional shifts from male absence and mortality?

## Title

**Missing Men, Rising Women: WWII Mobilization and the Individual Origins of Gender Convergence in American Labor Markets**

## Identification Strategy

### Primary Design: Individual Panel DiD

For woman $i$ in county $c$ observed in census waves $t \in \{1930, 1940, 1950\}$:

$$\Delta Y_{ic} = \alpha + \beta \cdot \text{Mobilization}_c + \gamma X_{i,1940} + \delta_s + \varepsilon_{ic}$$

where:
- $\Delta Y_{ic}$: change in outcome (e.g., occupation score, LFP) between 1940 and 1950
- $\text{Mobilization}_c$: county-level Army enlistment rate (CenSoc data / 1940 male population 18-44)
- $X_{i,1940}$: individual pre-war characteristics (age, education, race, marital status, pre-war occupation)
- $\delta_s$: state fixed effects

### Pre-Trend Validation (1930-1940)

Same specification applied to 1930-1940 changes. If $\beta_{pre} \approx 0$, parallel trends hold.

### Triple-Difference

Compare (women vs men) × (high vs low mobilization) × (pre vs post). Within-county gender differential controls for county-level shocks affecting both genders.

### Separation from War Production

Control for Jaworski (2017) county-level war plant investment. Subsample analysis: non-mover women (same county 1940-1950). Placebo on women 50+.

### Selection Correction

- Lee (2009) bounds for differential male attrition
- IPW reweighting linked sample to match full cross-section
- Oster (2019) test for selection on unobservables

## Expected Effects and Mechanisms

### Mechanism Chain: Mobilization → Vacancy → Entry → Upgrading → Convergence

1. **Male departure** (first stage): High-mobilization counties lose more working-age men
2. **Female entry** (extensive margin): Women enter labor force to fill vacancies
3. **Occupational upgrading** (intensive margin): Women move into higher-status occupations
4. **Marriage market restructuring**: Fewer available men → delayed marriage, different matching
5. **Measured convergence**: Combination of female advancement + male compositional change

### Expected Signs
- Female LFP: Positive (more women working in high-mobilization counties)
- Female occupation score: Positive (women moving into higher-SEI jobs)
- Female household headship: Positive (more women as household heads)
- Marriage rate: Ambiguous (fewer men available, but also economic independence)
- Gender occupation gap: Negative (convergence)

## Primary Specification

### Data Sources
1. **IPUMS MLP**: 1930-1940-1950 linked census data (HISTID linkage key)
   - Variables: HISTID, YEAR, SEX, AGE, RACE, BPL, MARST, NCHILD, LABFORCE, EMPSTAT, OCC1950, OCCSCORE, SEI, IND1950, EDUC, INCWAGE, STATEFIP, COUNTY, RELATE, URBAN, FARM
2. **CenSoc WWII Army Enlistment**: 9M records with county FIPS (Harvard Dataverse)
3. **Jaworski (2017)**: County-level war plant investment (OpenICPSR 140421)
4. **NHGIS**: County-level 1940 Census denominators

### Sample
- **Core sample**: Women aged 18-55 in 1940, linked 1940→1950 via HISTID
- **Extended sample**: Subset also linked to 1930 (for pre-trend tests)
- **Male comparison**: Men aged 18-55 in 1940, linked 1940→1950

### Outcomes
**Primary:**
1. Labor force participation (LABFORCE)
2. Occupation score (OCCSCORE/SEI)
3. Occupation × industry cell transitions

**Secondary:**
4. Household headship (RELATE == 1)
5. Marital status transitions (1940 single → 1950 married, etc.)
6. Geographic mobility (county change 1940→1950)

**Decomposition:**
7. Aggregate gender gap = within-person female change + within-person male change + composition

### Inference
- Cluster standard errors at county level (~3,000 counties)
- Wild cluster bootstrap for robustness
- Randomization inference: permute mobilization across counties

## Planned Robustness Checks

1. **Pre-trend test**: 1930-1940 placebo (should be zero)
2. **Placebo group**: Women 50+ in 1940 (should be zero)
3. **Non-mover subsample**: Women in same county 1940-1950
4. **Control for war production**: Add Jaworski county investment
5. **Alternative mobilization measures**: State-level (Acemoglu et al. 2004 replication at state level)
6. **Lee bounds**: Selection-corrected estimates
7. **IPW-weighted analysis**: Correct for linkage selection
8. **Oster (2019) test**: Coefficient stability under proportional selection
9. **Triple-diff**: Women × high-mobilization × post
10. **Continuous vs quintile treatment**: Mobilization bins
11. **Dropping top/bottom 5% mobilization counties**: Trimmed sample
12. **Alternative outcome measures**: Binary occupation upgrade, top-quartile SEI

## Heterogeneity Analysis

1. **By race**: White women vs Black women (differential access to defense jobs; Great Migration)
2. **By pre-war SES**: Father's occupation score (from 1930 link)
3. **By age at war**: 18-25 (entry-age) vs 26-35 vs 36-45 vs 46-55
4. **By region**: Northeast, Midwest, South, West (defense industry distribution)
5. **By urban/rural**: Different opportunity structures and social norms
6. **By pre-war marital status**: Single vs married women
7. **By pre-war occupation**: Professionals vs clerical vs manufacturing vs domestic
8. **By husband's service** (if linkable): Women whose husbands served vs didn't

## Paper Architecture (40+ pages)

1. **Introduction** (4-5 pages): Hook, contribution, findings, literature
2. **Historical Background** (3-4 pages): WWII mobilization, women's wartime entry, post-war adjustment
3. **Data** (4-5 pages): MLP, CenSoc, construction of key variables, link quality
4. **Descriptive Facts** (3-4 pages): Individual trajectories, who moved up/down
5. **The Decomposition** (4-5 pages): Aggregate convergence = within-person + composition
6. **Causal Estimates** (5-6 pages): Mobilization → female outcomes (DiD + pre-trends)
7. **Mechanisms** (4-5 pages): Marriage, mobility, selection analysis
8. **Heterogeneity** (4-5 pages): Race, SES, region, age, urban/rural
9. **Counterfactual** (2-3 pages): How much convergence without the war?
10. **Conclusion** (2-3 pages): Implications for understanding gender convergence

**Appendix (10+ pages):**
- A: Variable definitions and construction
- B: Link quality analysis and IPW
- C: Full robustness battery
- D: Additional heterogeneity tables
- E: Maps and geographic analysis
- F: Replication instructions

## Figures and Maps

1. **County mobilization map** (choropleth): Geographic distribution of WWII Army enlistment rates
2. **Event study plot**: Female occupation scores by mobilization quintile, 1930-1940-1950
3. **Decomposition figure**: Stacked bar showing within-person female + within-person male + composition
4. **Scatter plot**: County mobilization rate vs female occupation change (binned)
5. **Transition matrix heatmaps**: Occupation-to-occupation flows for women, by mobilization
6. **Heterogeneity forest plot**: Effect by subgroup (race, age, region, etc.)
7. **Sex ratio change map**: County-level male-to-female ratio change 1940-1950
8. **Pre-trend validation figure**: 1930-1940 placebo estimates
9. **Lee bounds figure**: Upper and lower bounds with point estimates
10. **Historical timeline**: Key WWII dates, mobilization waves, demobilization

## Exposure Alignment (DiD Requirements)

- **Who is treated?** Women in high-mobilization counties (continuous treatment)
- **Treatment timing:** 1941-1945 (between 1940 and 1950 censuses)
- **Pre-periods:** 1930-1940 (one clean pre-period in individual data)
- **Post-periods:** 1950 (one post-period)
- **Treated clusters:** ~3,000 counties with continuous mobilization intensity
- **Note:** This is not a standard staggered DiD (no adoption timing variation) — it's a continuous treatment DiD with one pre-period and one post-period. The 1930 wave provides the pre-trend test.

## Power Assessment

- Expected N (women linked 1940-1950): ~5-10 million
- Expected N (women linked 1930-1940-1950): ~2-5 million
- Counties: ~3,000
- MDE with this sample size: extremely small (< 0.01 SD for main effects)
- Power is not a concern given MLP scale
