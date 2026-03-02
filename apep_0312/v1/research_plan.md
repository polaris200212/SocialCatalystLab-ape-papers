# Initial Research Plan: APEP-0310

## Research Question

Did workers' compensation laws — the first major workplace safety regulation in American history — actually reduce industrial accidents? And did these laws reshape occupational sorting by altering the risk-return tradeoff of dangerous work?

## Policy Background

Between 1911 and 1920, 42 US states replaced the common-law negligence system with workers' compensation insurance, one of the most consequential labor market reforms of the Progressive Era. Under the old system, injured workers had to prove employer negligence in court (subject to fellow-servant, contributory negligence, and assumption-of-risk defenses). Workers' comp introduced no-fault insurance: employers automatically compensated injured workers regardless of fault, but workers gave up the right to sue.

**Key adoption dates (Fishback & Kantor 1998):**
- 1911: WI, CA, IL, KS, MA, NH, NJ, OH, WA (9 states)
- 1912: MD, MI, RI (3 states)
- 1913: AZ, CT, IA, MN, NE, NV, NY, OR, TX, WV (10 states)
- 1914: LA, KY (2 states)
- 1915: CO, IN, ME, MT, OK, PA, VT, WY (8 states)
- 1917: DE, ID, NM, SD, UT (5 states)
- 1918: VA (1 state)
- 1919: AL, MO, ND, TN (4 states)
- 1920: GA (1 state)
- 1929-1948: NC, FL, SC, AR, MS (5 states — "never treated" in our window)

## Identification Strategy

**Method: Doubly Robust (AIPW) within Callaway & Sant'Anna (2021) Framework**

Workers' comp adoption was systematically correlated with state characteristics: more industrial, urban, and politically progressive states adopted earlier (Fishback & Kantor 1998). Simple DiD is insufficient because:
1. Decennial census data (1910, 1920) is too coarse for event-study pre-trends
2. Selection into early adoption creates confounding

The DR/AIPW estimator addresses this by combining:
- **Propensity score model:** P(early adoption | state manufacturing share, urbanization, population, foreign-born share, literacy rate)
- **Outcome regression:** E[Y | treatment, covariates]
- **Double robustness:** Consistent if either model is correctly specified

**Implementation:**
- For newspaper data (annual panel 1900-1920): Callaway & Sant'Anna with `est_method = "dr"` using the R `did` package
- For IPUMS cross-sections (1910 vs 1920): AIPW estimator from the R `DRDID` package, treating this as repeated cross-sections

## Expected Effects and Mechanisms

**Mechanism 1: Safety improvement (workplace accident reduction)**
- Workers' comp shifted injury costs to employers → incentive to improve safety
- Expected: Decline in newspaper accident reports after adoption
- But: Moral hazard could offset — workers take more risks when insured (Fishback 1987)

**Mechanism 2: Occupational sorting**
- Workers' comp reduced compensating differentials for dangerous work (risk premium)
- If risk premium falls, dangerous occupations become relatively less attractive → workers sort OUT
- But: If workers value insurance, dangerous occupations become MORE attractive → workers sort IN
- The net effect is theoretically ambiguous

**Mechanism 3: Industry composition**
- Workers' comp increased labor costs for dangerous industries → some firms exit
- Expected: Decline in employment share of high-risk industries

## Primary Specification

### Newspaper Analysis (Annual Panel)

$$\text{AccidentIndex}_{st} = \alpha + \delta_{st}^{DR} + X_{st}\beta + \gamma_s + \lambda_t + \epsilon_{st}$$

Where:
- $\text{AccidentIndex}_{st}$ = workplace accident newspaper mentions per total newspaper pages in state $s$, year $t$
- $\delta_{st}^{DR}$ = group-time ATT from AIPW estimator
- $X_{st}$ = time-varying state controls
- $\gamma_s, \lambda_t$ = state and year fixed effects

### IPUMS Analysis (Repeated Cross-Sections)

$$\text{DangerousOcc}_{ist} = \alpha + \tau \cdot \text{WorkComp}_{st} + X_{ist}\beta + \gamma_s + \lambda_t + \epsilon_{ist}$$

Where:
- $\text{DangerousOcc}_{ist}$ = indicator for working in a high-risk occupation
- $\text{WorkComp}_{st}$ = indicator for workers' comp law in effect
- $X_{ist}$ = individual covariates (age, sex, race, nativity, literacy, marital status)
- AIPW estimation via `DRDID` package for the repeated cross-section case

## Planned Robustness Checks

1. **Placebo test:** Test for pre-trend in accident coverage (1900-1910, before any adoptions)
2. **Alternative treatment definitions:** Early (1911-1913) vs. late (1914+) vs. never
3. **Alternative search terms:** Vary newspaper search queries (mine explosion, factory fire, workplace death)
4. **Newspaper coverage normalization:** Accident mentions per capita vs. per newspaper page
5. **Heterogeneity:** Effects by state industrialization level, adoption cohort
6. **Dangerous occupation classification:** Alternative definitions using historical occupation injury rates
7. **Sample restrictions:** Males aged 18-65 in non-farm occupations
8. **Inference:** Cluster-robust standard errors at state level; wild bootstrap for small cluster count

## Data Sources

1. **Chronicling America API** (Library of Congress): State-year newspaper accident coverage, 1900-1920
2. **IPUMS USA** (1% samples): Individual-level census data, 1910 and 1920
3. **Workers' comp adoption dates:** Fishback & Kantor (1998, 2000)
4. **Historical state characteristics:** Published census summary statistics

## Exposure Alignment (DR-specific)

- **Who is treated:** Workers in states that adopted workers' compensation
- **Primary estimand population:** Workers in dangerous occupations (mining, manufacturing, construction) in states adopting workers' comp
- **Control population:** Workers in states that adopted later or never (within the observation window)
- **Design:** Doubly Robust repeated cross-sections (1910 vs 1920) + DR staggered treatment panel (newspapers)

## Power Assessment

- **Newspaper panel:** ~48 states × 21 years (1900-1920) = ~1,008 state-year observations
- **IPUMS samples:** ~90,000+ individuals per census year (1% samples)
- **Treated states by 1920:** 42 states (with 6 never-treated controls + timing variation)
- **Potential concern:** Only 6 never-treated states limits some DR specifications → use timing variation (early vs. late adopters) as primary comparison
