# Initial Research Plan: Does Local Governance Scale Matter?

## Research Question

Do discrete increases in municipal governance capacity — council size, mayor compensation, and electoral rules — at commune population thresholds causally affect local firm creation and survival in France?

## Identification Strategy

**Design:** Multi-cutoff sharp regression discontinuity design (RDD)

**Running variable:** Commune legal population (population légale from INSEE), which deterministically assigns governance mandates.

**Treatment:** At each population threshold, governance structure changes discretely:
- **500:** Mayor salary jumps from €1,042 to €1,647 (58% increase)
- **1,000:** Mayor salary from €1,647 to €2,108 (28%); since 2013, proportional list voting
- **1,500:** Council size from 15 to 19 members
- **3,500:** Mayor salary from €2,108 to €2,247 (7%); council from 23 to 27; pre-2013 also proportional voting + gender parity
- **10,000:** Mayor salary from €2,247 to €2,656 (18%); council from 29 to 33

**Primary cutoff:** 3,500 (largest governance bundle; DiDisc opportunity with 2013 reform)

**DiDisc at 3,500:** Before 2013, both governance mandates AND electoral system change at 3,500. After 2013, only governance mandates change (electoral system moved to 1,000). Comparing the 3,500 discontinuity before and after 2013 isolates the electoral system effect.

## Expected Effects and Mechanisms

**Hypothesized mechanisms:**
1. **Governance quality channel:** More councillors → better oversight → more business-friendly decisions (zoning, permits, infrastructure)
2. **Mayor capacity channel:** Higher-paid mayor → more time invested in governance → active business promotion
3. **Political competition channel:** Proportional voting → more party competition → responsive governance OR gridlock
4. **Administrative capacity channel:** Larger councils → more committee specialization → better local public goods

**Expected sign:** Ambiguous ex ante:
- **Positive:** Better governance → firm creation through improved local public goods, zoning flexibility, infrastructure investment
- **Negative:** Larger governance apparatus → more regulation, higher local taxes, bureaucratic friction
- **Null:** Municipal governance may be too weak to affect firm location decisions; firms respond to département/regional/national factors

A well-executed null result would be highly informative: it would demonstrate that sub-national governance variation doesn't matter for firm dynamics, challenging the decentralization literature.

## Primary Specification

Local polynomial RDD (Calonico, Cattaneo, Titiunik 2014):

Y_{c,t} = α + τ · 1[pop_c ≥ threshold] + f(pop_c - threshold) + X_c'β + δ_d + γ_t + ε_{c,t}

Where:
- Y_{c,t}: Firm creation rate per 1,000 inhabitants in commune c, year t
- pop_c: Legal population (running variable)
- f(): Local polynomial (linear or quadratic, MSE-optimal bandwidth)
- X_c: Covariates (commune area, density, département fixed effects)
- δ_d: Département fixed effects
- γ_t: Year fixed effects

**Bandwidth selection:** CCT optimal bandwidth with triangular kernel. Report sensitivity at 50%, 75%, 100%, 125%, 150%, 200% of optimal.

**Inference:** Cluster-robust standard errors at département level. Randomization inference as robustness.

## Planned Robustness Checks

1. **McCrary density test** at each threshold (manipulation check)
2. **Covariate balance** at thresholds: commune area, altitude, density, distance to nearest city
3. **Bandwidth sensitivity** (50%-200% of optimal)
4. **Polynomial order sensitivity** (linear, quadratic, cubic)
5. **Donut-hole RDD** (exclude communes within ±50 of threshold)
6. **Placebo thresholds** at non-policy population levels (e.g., 750, 2,000, 4,000)
7. **Multi-cutoff pooled estimation** (Cattaneo et al. 2016)
8. **DiDisc at 3,500** (pre vs. post-2013 electoral reform)
9. **Election-year timing** (drop 2008, 2014, 2020 election years)

## Exposure Alignment

- **Treated unit:** Communes whose legal population crosses a governance threshold
- **Treatment timing:** Takes effect at next municipal election (6-year cycle: 2008, 2014, 2020)
- **Outcome period:** Annual Sirene establishment counts, measured in inter-election years
- **Control:** Communes on the other side of the threshold (within optimal bandwidth)

## Power Assessment

- **Communes near 3,500 threshold (±20%):** 1,333
- **Communes near 1,000 threshold (±20%):** 3,296
- **Communes near 500 threshold (±20%):** 4,124
- **Total commune-years (5 cutoffs, ~15 years):** ~80,000+
- **Firm creation rate baseline:** ~10-15 creations per 1,000 inhabitants per year
- **Expected MDE:** Given large N, should detect effects of 5-10% of baseline rate

## Data Sources

1. **INSEE Commune Population Data** — data.gouv.fr CSV (34,935 communes, annual legal population)
2. **INSEE Sirene API** — establishment-level data with creation dates, closure dates, commune codes, NAF sector codes, employee brackets
3. **Governance rules** — Articles L2121-2, L2123-23, L2122-2 of the CGCT (deterministic from population)
4. **Elections data** — data.gouv.fr (for DiDisc analysis using pre/post-2013 electoral reform)
