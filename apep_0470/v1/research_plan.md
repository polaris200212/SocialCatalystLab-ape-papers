# Initial Research Plan: The Unequal Legacies of the Tennessee Valley Authority

## Research Question

Did the Tennessee Valley Authority — the largest place-based development program in American history — benefit all residents equally, or did its effects fracture along the fault lines of race and gender in the Jim Crow South?

## Identification Strategy

**Spatial Gradient Difference-in-Differences with Individual Fixed Effects**

1. **Unit of analysis:** Individual person, linked across 1920, 1930, and 1940 decennial censuses via IPUMS MLP crosswalks.

2. **Treatment definition:**
   - **Binary:** Residing in a TVA service-area county in 1930 (before TVA operations began in 1933).
   - **Continuous:** Log distance from 1930 county centroid to nearest TVA dam site (treatment intensity).
   - **Border subsample:** Restrict to counties within 100km of the TVA boundary.

3. **Pre-period validation:** The 1920→1930 individual-level transition is entirely pre-TVA. Parallel trends in occupational outcomes, literacy, and home ownership between future-TVA and non-TVA individuals during this period validate the identification assumption.

4. **Main estimating equation:**

   Y_{ict} = α_i + γ_t + β₁(TVA_c × Post_t) + β₂(TVA_c × Post_t × Distance_c) + X_{ct}δ + ε_{ict}

   Where i indexes individuals, c counties, t census years. α_i absorbs all time-invariant individual characteristics; γ_t absorbs common time trends; X_{ct} controls for county-level New Deal spending (excluding TVA) and pre-treatment characteristics interacted with time.

5. **Heterogeneity:** Triple interactions with race (Black/White), gender, and age cohort to decompose treatment effects along demographic lines.

6. **Migration decomposition:** Classify individuals as stayers, in-migrants, out-migrants, and never-TVA using observed county changes across censuses.

## Expected Effects and Mechanisms

### Mechanism Chain: TVA → Electrification → Manufacturing → Occupational Upgrading

- TVA dams provided cheap electricity and flood control
- Electricity enabled manufacturing in previously agricultural areas
- Manufacturing offered higher-wage occupations than farming

### Expected Heterogeneity

1. **Race:** Jim Crow institutions likely channeled TVA benefits toward white workers. Black workers faced employment discrimination in TVA construction (only 1.9% of qualified test-takers near Norris Dam were Black, vs. 7.1% of population). Hypothesis: TVA widened racial occupational gaps.

2. **Gender:** Electrification reduced domestic labor burden and enabled light manufacturing (textiles). MLP v2.0 enables women's linking for the first time. Hypothesis: TVA increased women's labor force participation, but more for white women than Black women.

3. **Age:** Younger workers (15-30 in 1930) had more occupational flexibility; older workers (40+) were locked into existing careers. TVA may have primarily benefited the young.

4. **Distance:** Effects should decay with distance from TVA infrastructure. Sharp decay implies local employment/electrification channels; flat decay implies agglomeration spillovers.

## Primary Specification

**Outcome hierarchy (pre-registered):**

Family 1 (Primary — Holm correction):
1. Occupational income score (SEI based on OCC1950)
2. Manufacturing employment indicator
3. Log wage income (1940 only, individual FE controls for pre-treatment occupation)

Family 2 (Secondary — Holm correction):
1. Labor force participation
2. Home ownership
3. Farm employment indicator

Family 3 (Exploratory — no correction required):
- Literacy, weeks worked, migration indicator, education (children subsample)

## Planned Robustness Checks

1. **Pre-trend test:** 1920→1930 placebo DiD (both periods pre-TVA)
2. **Border-county restriction:** Compare adjacent counties on either side of TVA boundary
3. **Distance donut:** Exclude counties within 25km of boundary (spillover zone)
4. **Lee (2009) bounds:** Bound treatment effects under worst-case attrition assumptions
5. **IPW for link quality:** Reweight by inverse probability of successful census linkage
6. **Conservative vs. standard links:** Run analysis on multiple link-quality thresholds
7. **Proposed authority placebo:** Test whether "proposed but never approved" authority counties show effects
8. **Other New Deal controls:** Include per-capita WPA, CCC, FERA, AAA spending as controls
9. **Wild cluster bootstrap:** Account for county-level clustering with few state clusters
10. **Randomization inference:** Permute TVA assignment across counties

## Exposure Alignment (DiD)

- **Who is treated?** Individuals residing in TVA service-area counties in the 1930 census
- **Primary estimand:** ATT on 1930→1940 occupational/income outcomes for TVA residents
- **Control population:** Individuals in non-TVA counties, with preference for adjacent counties and proposed-authority counties
- **Design:** Individual-level DiD with two pre-periods (1920, 1930) and one post-period (1940)

## Power Assessment

- **Pre-treatment periods:** 2 (1920, 1930)
- **Treated clusters:** ~125-201 TVA counties (depending on boundary definition)
- **Control clusters:** 500+ adjacent/proposed-authority counties
- **Individual panel:** Expected 500K-2M linked individuals in TVA + adjacent counties
- **Post-treatment periods per cohort:** 1 (1940)
- **MDE given sample size:** With N > 500K and county-level clustering, MDE < 0.05 SD for main effects; < 0.10 SD for race × TVA interactions

## Data Sources

1. **IPUMS MLP v2.0:** Full-count census data for 1920, 1930, 1940 with cross-census individual linkages
2. **MLP Crosswalks:** Parquet files providing HISTID pairs for 1920-1930 and 1930-1940
3. **TVA County List:** From Kline & Moretti (2014) QJE replication files
4. **TVA Dam Locations:** Geocoded from historical records (16 dams, 1933-1944)
5. **New Deal Spending:** Fishback, Kantor, and Wallis (2003) county-level data
6. **County Shapefiles:** NHGIS or tigris R package for 1930 county boundaries
