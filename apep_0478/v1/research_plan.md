# Initial Research Plan: Going Up Alone

## Research Question

Why did elevator automation — technically feasible from ~1900 — take over 40 years to achieve widespread adoption, and what role did the 1945 NYC elevator operator strike play as a coordination shock that broke behavioral resistance to operatorless elevators?

## Conceptual Framework

**The Adoption Puzzle:** Automatic elevators (push-button, self-service) were patented and demonstrated by the early 1900s. By the 1920s-1930s, the technology was mature and cost-effective. Yet building owners continued employing human operators because riders refused to enter an elevator alone. This is not a standard technology diffusion story (Griliches 1957) or a vintage capital story (Manuelli & Seshadri 2014) — it's a behavioral equilibrium sustained by coordination failure. No single building owner wanted to be first to remove operators and risk tenant flight.

**The Shock:** The September 1945 NYC elevator operator strike (15,000 workers, 6 days) forced 1.5 million office workers to walk stairs or experience minimal-service elevators. This mass forced exposure broke the behavioral equilibrium. Within a decade, automated share of new installations went from 12.6% (1950) to 90%+ (1959). The strike serves as an exogenous coordination shock — it didn't change the technology, the costs, or the building stock; it changed beliefs.

**Connection to Today:** The elevator case directly parallels AI adoption debates. Technologies exist (autonomous vehicles, AI diagnostics, automated customer service) that are technically superior on many dimensions but face behavioral resistance. Understanding what breaks the trust barrier has first-order policy implications.

## Identification Strategy

### Part I: Descriptive Atlas (No Causal Claims)

Document the complete lifecycle of the only occupation in the Census ever fully eliminated by automation:

1. **National time series (1900-1950):** Operator counts, shares, growth rates
2. **Geographic distribution:** City-level operator employment, concentration (34% in NYC)
3. **Demographic composition:** Sex (feminization from 1.5% to 31%), race (~25% Black), age distribution (aging workforce)
4. **Industry distribution:** Which sectors employed operators (by IND1950)
5. **Comparison to other building service workers:** Janitors, porters, guards — did they follow similar patterns?

### Part II: The Adoption Puzzle & Strike Shock (Primary Causal Section)

**Design:** Synthetic Control Method (SCM)

**Treatment:** NYC (STATEFIP=36, metropolitan area). Strike occurred September 24-30, 1945.

**Outcome Variables:**
1. Elevator operators per 1,000 building-service workers (primary)
2. Elevator operators per 10,000 population (secondary)
3. New entrants into elevator operation (age < 25, proxy for hiring cessation)
4. Share of operators who are young (< 30) vs old (> 50)

**Donor Pool:** 50+ US cities with population > 100,000 in 1940, excluding NYC.

**Pre-treatment Matching Variables (for SCM):**
- Elevator operator share (1900-1940, 5 periods)
- Total building-service employment share
- Population
- Manufacturing employment share
- Foreign-born share (proxy for building stock age/density)

**Pre-treatment Periods:** 1900, 1910, 1920, 1930, 1940 (5 pre-treatment observations)

**Post-treatment Period:** 1950 (one post-treatment observation in Census data)

**Inference:** Permutation (placebo-in-space) tests. Construct placebo SCM for every donor city; compute p-value as share of placebos with effect as large as NYC.

**Robustness:**
1. Augmented SCM (Ben-Michael et al. 2021) for bias correction
2. Alternative donor pools (top-10 cities only; cities with > 1,000 operators)
3. DiD with hand-selected comparable cities (Chicago, Philadelphia, Detroit, Boston) as secondary specification
4. Falsification: same SCM on janitors (OCC1950=770) — should show NO effect

### Part III: Worker Outcomes (Complementary Section)

**Design:** Descriptive + matched comparison using MLP 1940→1950 linked panel

**Sample:** All individuals with OCC1950=761 (elevator operators) in 1940 census, linked to 1950 census via MLP v2.0 crosswalk.

**Comparison Group:** Building-service workers (janitors=770, porters=780, guards/doorkeepers=763) in 1940, linked to 1950.

**Outcomes:**
1. Transition matrix: 1950 occupation for 1940 elevator operators
2. Labor force participation in 1950
3. SEI (socioeconomic index) change: 1950 vs 1940
4. Geographic mobility (state change between 1940 and 1950)
5. Heterogeneity by race, sex, age, city

**NOT the headline:** This section shows what happened to workers, complementing the adoption puzzle. It is explicitly subordinated to Part II.

## Expected Effects and Mechanisms

**Part II Expected Effects:**
- NYC should show a disproportionate decline in elevator operator share between 1940 and 1950 relative to synthetic NYC
- The mechanism is NOT that the strike directly destroyed jobs (it lasted 6 days) but that it broke the behavioral equilibrium, leading to accelerated automation investment in the following years
- New entrants (young workers) should decline more sharply than incumbents — consistent with buildings stopping hiring rather than mass layoffs

**Part III Expected Patterns:**
- Elevator operators transition primarily to adjacent building-service occupations (janitors, porters, guards)
- Older operators exit the labor force; younger operators switch occupations
- Black operators may face worse transition outcomes due to racial barriers in alternative occupations
- NYC operators may show different transition patterns than operators in other cities

## Specification Details

### Primary SCM Specification

```r
# Using Synth package
synth_out <- synth(
  dataprep.out = dataprep(
    foo = city_panel,
    predictors = c("operator_share", "bldg_service_share", "pop_log", "mfg_share", "foreign_share"),
    predictors.op = "mean",
    time.predictors.prior = 1900:1940,
    dependent = "operator_per_bldg_service",
    unit.variable = "city_id",
    time.variable = "year",
    treatment.identifier = "NYC",
    controls.identifier = donor_cities,
    time.optimize.ssr = 1900:1940,
    time.plot = 1900:1950
  )
)
```

### Robustness: Augmented SCM

```r
# Using augsynth package
ascm <- augsynth(
  operator_per_bldg_service ~ treated,
  unit = city_id,
  time = year,
  data = city_panel,
  progfunc = "Ridge",
  scm = TRUE
)
```

### Individual Displacement Analysis

```r
# Using fixest for matched comparison
feols(sei_1950 - sei_1940 ~ elevator_operator_1940 | statefip_1940 + race_1940 + age_group_1940,
      data = linked_panel)
```

## Planned Robustness Checks

1. **Placebo outcome:** Janitors (OCC1950=770) in same SCM framework — expect null
2. **Placebo time:** Pretend strike was in 1935 → run SCM on 1900-1940 with "treatment" at 1930-1940
3. **Alternative outcomes:** Operators per capita, operator share of all workers, new entrant rate
4. **Alternative donor pools:** Top-10 only, population > 250K, same census division excluded
5. **Augmented SCM:** Ridge augmentation for finite-sample bias
6. **Leave-one-out:** Drop each major donor city from pool to assess sensitivity
7. **Individual-level matching:** CEM or propensity score matching for Part III comparison group

## Data Sources

All data on Azure Blob Storage:

| Dataset | Azure Path | Rows |
|---------|-----------|------|
| MLP Crosswalk v2.0 | `raw/ipums_mlp/v2/mlp_crosswalk_v2.parquet` | 175.6M |
| 1900 Census | `raw/ipums_fullcount/us1900m.parquet` | ~76M |
| 1910 Census | `raw/ipums_fullcount/us1910m.parquet` | ~92M |
| 1920 Census | `raw/ipums_fullcount/us1920c.parquet` | ~106M |
| 1930 Census | `raw/ipums_fullcount/us1930d.parquet` | ~123M |
| 1940 Census | `raw/ipums_fullcount/us1940b.parquet` | ~132M |
| 1950 Census | `raw/ipums_fullcount/us1950b.parquet` | ~151M |

**Key variables:** HISTID, STATEFIP, COUNTYICP, CITY, AGE, SEX, RACE, BPL, NATIVITY, MARST, OCC1950, IND1950, SEI, OCCSCORE, CLASSWKR, LABFORCE, LIT, FARM

## Paper Structure (Target: 45+ pages main text, 15+ pages appendix)

1. **Introduction** (5-6 pages): Hook with the "only eliminated occupation" fact. Frame the adoption puzzle. Preview findings.
2. **Historical Background** (6-8 pages): The elevator, the operator, the technology gap, the 1945 strike. Rich narrative drawing on primary sources.
3. **Data** (4-5 pages): Census microdata, MLP linked panels, variable construction.
4. **Part I: The Rise and Fall of the Elevator Operator** (8-10 pages): Descriptive atlas with 6-8 figures. National trends, geographic distribution, demographics.
5. **Part II: Breaking the Equilibrium** (8-10 pages): The adoption puzzle framed theoretically. SCM identification. Results. Robustness.
6. **Part III: Where Did They Go?** (6-8 pages): Individual displacement tracking. Transition matrices. Heterogeneity.
7. **Discussion: Lessons for AI Adoption** (3-4 pages): Connect findings to contemporary technology adoption.
8. **Conclusion** (2-3 pages)

**Appendix** (15+ pages):
- A: Variable definitions and Census harmonization
- B: SCM donor pool and weights
- C: All placebo tests (space and time)
- D: Full transition matrices by demographic group
- E: Additional figures and tables
