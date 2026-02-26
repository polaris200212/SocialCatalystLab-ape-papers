# Initial Plan: Second Home Caps and Local Labor Markets

## Research Question

Does restricting second-home construction affect local labor markets in Swiss tourist municipalities? Using a regression discontinuity design at the binding 20% second-home share threshold created by Switzerland's 2012 Zweitwohnungsinitiative (Second Home Initiative), this paper estimates the causal effect of construction restrictions on sectoral employment, tourism activity, and local economic structure.

## Policy Background

Switzerland's Second Home Initiative (Art. 75b BV), approved by popular vote on March 11, 2012, prohibits new second-home construction in municipalities where second homes exceed 20% of total housing stock. An implementing ordinance took effect January 1, 2013. Approximately 360 of Switzerland's ~2,100 municipalities exceeded the threshold and face binding construction restrictions. The 20% threshold was set federally and applies uniformly nationwide.

## Identification Strategy

**Design:** Sharp Regression Discontinuity Design (RDD)

**Running Variable:** Pre-initiative municipal second-home share (Zweitwohnungsanteil), measured from the Federal Building and Housing Register (GWR) as of 2012, before the policy took effect.

**Threshold:** 20% — municipalities above this threshold cannot issue new building permits for second homes.

**Treatment:** Binding prohibition on new second-home construction.

**Key Assumptions:**
1. No precise manipulation of the running variable at 20% (testable via McCrary density test)
2. Potential outcomes are continuous at the threshold
3. Pre-treatment covariates are balanced at the threshold

## Expected Effects and Mechanisms

**Primary channel — Construction and employment:**
- Municipalities above 20% lose second-home construction demand → reduced construction employment
- Expected: negative effect on construction sector employment (NOGA F)

**Secondary channel — Tourism substitution:**
- Fewer second homes may shift demand toward hotel/rental tourism → increased hospitality employment
- OR: overall reduced tourism demand if second homes are complements to local spending
- Expected sign: ambiguous (the empirical question)

**Tertiary channel — Resident welfare:**
- Less competition for housing → lower housing costs for locals
- But also less economic activity → potentially lower wages/employment in services
- Expected: heterogeneous effects across income groups

## Primary Specification

Y_{it} = α + τ · 1(ZWA_i > 20%) + f(ZWA_i - 20%) + X_i'β + ε_{it}

Where:
- Y_{it} = outcome for municipality i in post-period t (employment by sector, overnight stays, etc.)
- ZWA_i = pre-initiative (2012) second-home share for municipality i
- f(·) = local polynomial in the running variable (linear or quadratic, both sides)
- X_i = pre-determined covariates (population, altitude, language region, canton FE)
- Bandwidth: Calonico-Cattaneo-Titiunik (2014) optimal bandwidth with triangular kernel

## Data Sources

| Variable | Source | Granularity | Period |
|----------|--------|-------------|--------|
| Second-home share (running var.) | ARE/opendata.swiss "Wohnungsinventar" | Municipal | 2012 (pre-determined) |
| Employment by sector | BFS STATENT | Municipal × sector | 2011-2023 |
| Tourism overnight stays | BFS HESTA (Beherbergungsstatistik) | Municipal | 2005-2023 |
| Construction permits | BFS Bau- und Wohnbaustatistik | Municipal | 2005-2023 |
| Population & demographics | BFS STATPOP | Municipal | 2010-2023 |
| Municipal finance | BFS Finanzstatistik | Municipal | 2010-2022 |

## Power Assessment

- ~360 municipalities above 20% threshold
- ~1,700 municipalities below 20%
- With CCT optimal bandwidth (likely ±5-8 pp around 20%), expect 100-300 municipalities in estimation window
- STATENT covers all registered businesses → full enumeration (not a survey)
- Pre-treatment periods: 2011 (STATENT start) to 2012 = 1-2 years pre + 2013-2023 = 11 years post
- Power is primarily determined by cross-sectional density near the threshold, which needs empirical verification

## Planned Robustness Checks

1. **McCrary density test** — test for bunching at 20%
2. **Covariate balance** — pre-treatment characteristics smooth at threshold (population, altitude, language, income, sector composition)
3. **Bandwidth sensitivity** — vary bandwidth (50%, 75%, 100%, 150%, 200% of CCT optimal)
4. **Polynomial order** — linear vs quadratic local polynomial
5. **Donut-hole RDD** — exclude municipalities within ±1 pp of threshold
6. **Placebo thresholds** — test at 10%, 15%, 25%, 30% (should be zero)
7. **Event-study by year** — RDD estimates separately for each post-treatment year (2013-2023)
8. **Kernel sensitivity** — triangular vs uniform kernel
9. **Pre-treatment outcome balance** — verify no discontinuity in 2011 outcomes at 20%
