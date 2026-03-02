# Initial Research Plan: Cash Scarcity and Food Prices

## Research Question

How does a sudden, policy-induced cash scarcity affect food prices? Specifically, did the 2023 Nigerian naira redesign—which created an acute currency shortage lasting 6–8 weeks—differentially increase food prices in states with lower banking infrastructure density?

## Identification Strategy

**Continuous Difference-in-Differences.** The Central Bank of Nigeria (CBN) announced the naira redesign in October 2022 as a federal monetary policy decision, plausibly exogenous to state-level food price trends. Cross-state variation in treatment intensity arises from pre-existing differences in banking infrastructure: states with fewer bank branches per capita, lower ATM density, and higher cash dependence experienced more severe shortages of new-denomination notes.

Treatment intensity is measured using pre-reform (2022) state-level characteristics:
- Primary: Bank branches per 100,000 population (CBN Annual Statistical Bulletin, Table A.15)
- Alternative: Urbanization rate as proxy (NBS/World Bank)

The key identifying assumption is that, absent the naira redesign, food price trends would have evolved similarly across states with different banking infrastructure levels (parallel trends in treatment intensity). This is testable with 20+ years of pre-treatment weekly food price data.

## Expected Effects and Mechanisms

**Primary hypothesis:** States with lower banking density experienced larger food price increases during the cash crisis (Jan–Mar 2023), because:
1. **Transaction costs:** Cash-dependent markets faced higher costs when physical currency became scarce
2. **Supply disruption:** Traders and transporters who operated in cash could not purchase or move goods
3. **POS premium:** Alternative payment channels (POS terminals) charged surcharges of 400–1,000%, effectively raising transaction costs
4. **Market segmentation:** Cash-scarce areas became isolated from integrated national markets

**Secondary hypotheses:**
- Effects larger for commodities typically traded in cash (grains, tubers) vs modern retail (bread)
- Effects larger in markets further from state capitals (proxy for financial access within states)
- Recovery visible after Supreme Court ruling (March 3, 2023) restored old notes as legal tender

## Exposure Alignment

- **Who is treated:** All Nigerian consumers and market participants, but with differential intensity based on state-level financial infrastructure
- **Primary estimand:** ATT weighted by treatment intensity (interaction of banking scarcity × post-crisis indicator)
- **Control population:** States with high banking density (treatment intensity near zero, serving as comparisons)
- **Design:** Continuous DiD (not binary treatment)

## Power Assessment

- **Units:** 15 states in FEWS NET data
- **Time periods:** ~1,100 weeks (2003–2024), of which ~1,000+ are pre-treatment
- **Commodities:** 20 products per state-week (can pool or analyze separately)
- **Total market-week observations:** ~100,000+ (after restricting to balanced panel)
- **Clusters:** 15 states — will require wild cluster bootstrap (Webb 6-point weights)
- **Pre-treatment periods:** >900 weeks (far exceeds ≥5 requirement)
- **Post-treatment periods:** ~8 weeks of acute crisis, ~40 weeks to end of 2023

**Power concern:** 15 clusters is below ideal (>30 for asymptotic CRSE validity). Mitigation: wild cluster bootstrap, randomization inference, and permutation-based p-values.

## Primary Specification

```
log(Price_imt) = α_im + γ_t + β(BankScarcity_i × Post_t) + X'_it δ + ε_imt
```

Where:
- i = state, m = commodity, t = week
- α_im = state × commodity fixed effects
- γ_t = week fixed effects
- BankScarcity_i = inverse of bank branches per capita (continuous, time-invariant)
- Post_t = indicator for crisis period (Feb 1 – Mar 15, 2023)
- X_it = state-level controls (optional: population, urbanization)

## Planned Robustness Checks

1. **Parallel trends:** Event study plots showing week-by-week β coefficients for 52 weeks before and after crisis
2. **Placebo tests:** Run same specification for "fake" crises at every quarter in 2019–2021
3. **Alternative treatment measures:** Urbanization rate, distance from Lagos, ATM density
4. **Commodity heterogeneity:** Separate regressions for cash-intensive (grains) vs less cash-intensive (livestock) goods
5. **Wild cluster bootstrap:** Webb 6-point weights, 9,999 replications
6. **Randomization inference:** Permute treatment intensity across states
7. **Dose-response:** Non-parametric bin analysis (quintiles of banking density)
8. **Recovery dynamics:** Extended event study through June 2023 to capture price normalization after Supreme Court ruling
9. **Bacon decomposition:** Verify no contaminated comparisons in the continuous treatment setting

## Data Sources

| Data | Source | Access | Granularity |
|------|--------|--------|-------------|
| Food prices | FEWS NET | Direct CSV API | Market-commodity-week |
| Bank branches by state | CBN Statistical Bulletin | PDF/Excel download | State-year |
| Banking proxy (urbanization) | World Bank WDI | API | State (from census) |
| Population | NBS / World Bank | API | State |
| Conflict events | UCDP (HDX) | CSV download | State-month (control) |

## Timeline

1. Data acquisition: Fetch FEWS NET, construct treatment variable
2. Cleaning: Build balanced panel, log-transform prices, merge treatment
3. Main analysis: TWFE continuous DiD, event study
4. Robustness: Bootstrap, placebo, RI, heterogeneity
5. Figures and tables
6. Paper writing
