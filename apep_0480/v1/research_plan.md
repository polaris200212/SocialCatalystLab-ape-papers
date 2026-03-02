# Initial Research Plan — apep_0480

## Research Question

What are the local effects of mass betting shop closures on crime, property values, and economic activity? Do closures improve neighborhoods by removing a source of antisocial behavior, or do they harm them by creating vacancies, destroying jobs, and displacing gambling online?

## Policy Context

On April 1, 2019, the UK government reduced the maximum stake on Fixed-Odds Betting Terminals (FOBTs) from £100 to £2. This regulatory shock caused the largest wave of high-street closures in England's recent history: over 1,000 betting shops closed within six months, concentrated in the most deprived local authorities. The reform was politically salient — the FOBT stake cut was debated in Parliament, delayed in the 2018 Budget, and ultimately accelerated by cross-party pressure.

Despite the reform's scale and policy importance, no causal economics study has estimated its local effects. The existing literature is entirely descriptive (Hall et al. 2021; Evans and Cross 2021).

## Identification Strategy

**Design:** Doubly Robust Difference-in-Differences (Sant'Anna and Zhao 2020)

**Temporal variation:** Pre/post April 2019 (national shock)

**Cross-sectional treatment intensity:** Pre-policy betting shop density per 10,000 population at the Local Authority level, using the 2015–2018 average from Gambling Commission Licensing Authority Statistics. This is predetermined — measured before the policy announcement (May 2018) and not a function of the closure decision.

**Why DR:** Betting shops are concentrated in deprived areas. Unconditional parallel trends may fail because deprived LAs have different crime/property/employment trajectories. The DR estimator conditions on rich LA-level covariates (IMD deprivation score, population density, age composition, baseline crime rate, urbanity classification) to restore conditional parallel trends. The doubly robust property means the estimator is consistent if either the propensity score model (probability of being high-exposure) or the outcome model (conditional mean function) is correctly specified.

**R implementation:** `did` package (Callaway and Sant'Anna) with DR option; `DRDID` package for the core estimator.

## Exposure Alignment

- **Who is actually treated?** Residents and businesses near betting shops in high-density LAs
- **Primary estimand population:** Local authorities with above-median pre-policy betting shop density (~165 LAs)
- **Control population:** LAs with zero or below-median pre-policy betting shop density
- **Design:** Continuous treatment DiD (density per 10k population) as primary; binary (above/below median) as robustness

## Expected Effects and Mechanisms

**Theory is ambiguous — this is the contribution.**

Channel 1: **Neighborhood improvement** (crime falls, prices rise)
- Betting shops attract antisocial behavior, disorder, and foot traffic associated with crime
- Closures remove this "attractor" → antisocial behavior and violence fall
- Neighborhood becomes more desirable → property values increase

Channel 2: **Vacancy/decay** (crime rises, prices fall)
- Closed betting shops become vacant storefronts → broken windows
- Reduced foot traffic → less informal surveillance → crime opportunity increases
- High-street decline signals → property values fall

Channel 3: **Online displacement** (crime composition shifts)
- Problem gambling moves online → domestic settings
- Domestic incidents may increase even as street crime falls
- Net crime effect depends on which channel dominates

Channel 4: **Employment** (welfare increases)
- Each shop employed 4-8 staff; ~12,000 jobs at risk
- Closures in deprived areas → unemployment → welfare claims increase
- But new businesses may fill vacated premises → partial offset

## Primary Specification

$$Y_{it} = \alpha + \beta \cdot Density_i \times Post_t + X_{it}\gamma + \delta_i + \lambda_t + \varepsilon_{it}$$

Where:
- $Y_{it}$ = total police-recorded crime per 10,000 population in LA $i$, quarter $t$
- $Density_i$ = pre-policy betting shop density per 10,000 population (2015-2018 avg)
- $Post_t$ = indicator for $t \geq$ Q2 2019
- $X_{it}$ = time-varying controls (population, NOMIS claimant count)
- $\delta_i, \lambda_t$ = LA and quarter fixed effects
- Clustered SEs at the LA level (329 clusters)

**Primary estimand:** The ATT on total crime per capita, estimated via DR-DiD.

**Secondary estimand:** Mean LA-level property transaction price (Land Registry, LA-quarter).

## Power Assessment

- **Pre-treatment periods:** 16 quarters (Q1 2015 – Q4 2018) in Gambling Commission data; 36+ quarters in Police/Land Registry data
- **Treated clusters (above-median density):** ~165 LAs
- **Control clusters:** ~165 LAs
- **Post-treatment periods per cohort:** 24+ quarters (Q2 2019 – Q4 2024)
- **MDE given sample size:** With 329 LAs, 40+ quarters, and rich within-LA variation, MDE should be well below 5% of the outcome mean. Will compute formally after data fetch.

## Planned Robustness Checks

1. **Event study plots** for crime and property values by exposure quintile
2. **Alternative exposure definitions:** density per km², binary above/below median, actual post-policy closure count (instrumented by pre-policy density)
3. **Rambachan-Roth (HonestDiD)** sensitivity to linear pre-trend violations
4. **Goodman-Bacon decomposition** if using staggered treatment timing
5. **Crime-category placebos:** Vehicle crime, bike theft, burglary (unrelated to gambling) as falsification
6. **Non-gambling retail closures** in same LAs as placebo treatment
7. **Leave-one-out LA stability:** Drop each LA and re-estimate
8. **Wild cluster bootstrap** for inference robustness
9. **Deprivation heterogeneity:** Effects by IMD quintile

## Data Sources

| Source | Variable | Geography | Frequency | Access |
|--------|----------|-----------|-----------|--------|
| Gambling Commission LA Statistics | Betting shop counts | 329 LAs | Annual (2015–2025) | Free Excel |
| Gambling Commission Business Register | Establishment-level closures | Postcode | Cross-section | Free CSV |
| data.police.uk bulk downloads | Crime counts by category | LSOA → LA | Monthly (Dec 2010–) | Free CSV |
| HM Land Registry PPD | Transaction prices | Postcode → LA | Each transaction | Free CSV |
| NOMIS (DWP claimant count) | Unemployment claims | LA | Monthly | Free API |
| NOMIS (ASHE) | Earnings | LA | Annual | Free API |
| ONS mid-year estimates | Population denominators | LA | Annual | Free |
| English IMD 2019 | Deprivation index | LSOA → LA | Cross-section | Free |

## Timeline

1. Data fetch: Gambling Commission + Police bulk + Land Registry + NOMIS
2. Clean: Merge datasets at LA-quarter level
3. First-stage: Document shop closures by pre-policy density
4. Main analysis: DR-DiD on crime and property values
5. Mechanism: Crime decomposition + vacancy tracking
6. Robustness: Full battery
7. Write paper (25+ pages)
8. Review cycle
