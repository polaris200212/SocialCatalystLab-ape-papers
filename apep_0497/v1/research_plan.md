# Initial Research Plan — apep_0497

## Research Question

Who captures a tax cut? When France abolished its €23.4 billion annual taxe d'habitation (TH) on primary residences (2018-2023), did the savings capitalize into higher property prices — transferring the benefit from future buyers to incumbent owners — or did prices remain stable, allowing new homeowners to enjoy permanently lower housing costs?

## Identification Strategy

**Design:** Staggered continuous difference-in-differences

**Treatment variation (two dimensions):**

1. **Cross-sectional dose (pre-reform TH rate):** France's ~35,000 communes had TH rates ranging from ~5% to >30% of valeur locative cadastrale in 2017. Higher-rate communes experienced larger per-property tax savings.

2. **Temporal stagger (income-based phase-in):** 80% of households (below ~€27,000 RFR) received progressive TH relief in 2018-2020 (30% → 65% → 100%); the remaining 20% were phased out in 2021-2023. Communes with different income compositions received effective tax relief at different times.

**Primary treatment measure:** Commune-level TH savings per m² = (2017 TH rate) × (2017 average valeur locative per m²) × (share of below-threshold households). This is pre-determined and exogenous to the reform.

**Estimator:** Callaway-Sant'Anna (2021) for group-time ATTs, with groups defined by income-share terciles/quartiles (early/medium/late treated).

**Parallel trends assumption:** Testable using 2014-2017 pre-period (4 years before first phase-in).

### Exposure Alignment (DiD)

- **Who is treated:** Owners of primary residences in communes with positive TH rates (essentially all communes)
- **Primary estimand population:** Property buyers in high-TH communes post-reform
- **Placebo/control population:** (1) Low-TH communes; (2) Communes with high secondary-residence shares (exempt from TH abolition)
- **Design:** Continuous DiD with staggered groups

### Power Assessment

- **Pre-treatment periods:** 4 (2014-2017)
- **Treated clusters:** ~35,000 communes (all treated, varying intensity)
- **Post-treatment periods:** 6 (2018-2023)
- **Observations:** ~2-3 million transactions per year × 10 years ≈ 20-25 million
- **Expected MDE:** Very small given N; can detect <1% price effect per €100 TH savings

## Expected Effects and Mechanisms

**Prediction under full capitalization (Oates 1969):** Property prices should rise by the present discounted value of future TH savings. For a commune with €1,000/year TH savings per property and a 3% discount rate, full capitalization implies ~€33,000 price increase.

**Prediction under zero capitalization:** Prices unchanged; buyers benefit from lower annual costs.

**Partial capitalization is most likely** (consistent with Palmon & Smith 1998, Lutz 2015), with heterogeneity:
- Supply-constrained markets (Paris, dense urban): higher capitalization (prices absorb more)
- Supply-elastic markets (rural, new construction): lower capitalization (quantity response)

**Mechanism chain:**
1. TH abolition → lower effective annual cost of homeownership (first stage, mechanical)
2. Lower cost → higher willingness to pay → higher transaction prices (main result)
3. Higher prices → increased transaction volume (liquidity channel)
4. Supply response: higher prices → more building permits (longer-run supply adjustment)

## Primary Specification

```
log(price_ict) = β × TH_dose_c × Post_t + α_c + γ_t + X_ict'δ + ε_ict
```

Where:
- `price_ict` = transaction price per m² for property i in commune c at time t
- `TH_dose_c` = pre-reform (2017) TH savings per m² (standardized)
- `Post_t` = indicator for 2018+
- `α_c` = commune fixed effects
- `γ_t` = year-quarter fixed effects
- `X_ict` = property characteristics (surface, rooms, type, new/existing)

**Staggered version:** Callaway-Sant'Anna with groups defined by terciles of commune-level below-threshold household share (early/medium/late exposure).

## Planned Robustness Checks

1. **Event study:** Dynamic treatment effects (leads and lags, 2014-2024)
2. **HonestDiD:** Rambachan-Roth sensitivity bounds for linear pre-trend violations
3. **Secondary residence placebo:** Estimate effect on high-secondary-residence communes (should be null)
4. **Alternative exposure measures:** TH rate alone, TH savings per dwelling, interaction with Filosofi income shares
5. **Leave-one-out:** Drop one département at a time
6. **Donut specification:** Drop 2018 (transition year with partial relief)
7. **Trimming:** Exclude extreme TH rates (<5th and >95th percentile)
8. **Supply elasticity heterogeneity:** Split by population density, geographic constraints
9. **Anticipation test:** Check for price effects in 2017 (reform announced September 2017)

## Data Sources

| Dataset | Source | Years | Level | Key Variables |
|---------|--------|-------|-------|---------------|
| DVF | data.gouv.fr | 2014-2024 | Transaction | Price, type, surface, rooms, commune code |
| REI | data.economie.gouv.fr | 2014-2023 | Commune | TH taux, bases, products |
| Filosofi | insee.fr | 2017 | Commune | Income deciles, poverty rate, Gini |
| RP Logement | insee.fr | 2017 | Commune | Primary/secondary residence shares |
| COG | insee.fr | 2014-2024 | Commune | Commune boundary changes, mergers |
