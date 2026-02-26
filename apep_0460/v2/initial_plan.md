# Research Plan: Across the Channel

## Research Question

Do economic shocks transmit across national borders through social networks? We study this question using Brexit as a quasi-natural experiment and Facebook's Social Connectedness Index (SCI) to measure cross-border social ties between French and UK regions.

## Identification Strategy

**Design:** Shift-share instrumental variables (Borusyak, Hull, and Jaravel 2022).

**Shares:** Pre-Brexit SCI weights from each French NUTS-3 département to UK NUTS-3/ITL3 regions. These capture the density of Facebook friendship links and proxy for broader social and economic connections. The SCI is time-invariant (October 2021 vintage reflecting pre-existing social structure) and predetermined relative to the Brexit shock.

**Shocks:** Differential Brexit economic impact across UK regions, measured by:
- Primary: Change in regional GVA per capita from ONS ITL3 data (2015-2016 baseline vs post-Brexit)
- Alternative: UK regional EU trade exposure (share of regional output going to EU markets)
- Alternative: Bloom et al. (2025) firm-level Brexit exposure index aggregated to ITL3

**Estimating equation:**

Y_{f,t} = α + β · BrexitExposure_f × Post_t + γ_f + δ_t + X_{f,t}Γ + ε_{f,t}

Where:
- Y_{f,t} = outcome in French département f at time t
- BrexitExposure_f = Σ_k [SCI(f,k) × Population_k / Σ_j SCI(f,j) × Population_j] × BrexitShock_k
- Post_t = 1 after June 23, 2016 (referendum) or January 1, 2021 (trade frictions)
- γ_f = département fixed effects
- δ_t = quarter fixed effects
- X_{f,t} = time-varying controls (EU structural fund receipts, local demographic trends)

**Exclusion restriction:** Conditional on département and time fixed effects, the only channel through which SCI-weighted UK economic shocks affect French local outcomes is through the social network connection itself (information flows, confidence effects, trade facilitation, migration links). We test this by showing:
1. German exposure placebo has no effect (rules out generic connectivity)
2. Pre-trends are flat (rules out differential trends correlated with UK ties)
3. Effects are stronger for population-weighted SCI (consistent with information volume channel)
4. Effects are not driven by physical proximity (distance-restricted instruments)

## Expected Effects and Mechanisms

**Primary hypothesis:** French départements with stronger social ties to UK regions that were harder hit by Brexit experienced larger declines in local economic activity.

**Expected signs:**
- Housing prices: Negative (reduced demand from UK-connected investment/migration)
- Firm creation: Negative (reduced cross-border business opportunities, lower confidence)
- Unemployment: Positive (job losses in UK-exposed sectors, reduced cross-Channel labor demand)

**Mechanisms to test:**
1. **Information channel:** Social network connections transmit information about economic distress, affecting local expectations and behavior. Test: Effects should be stronger for population-weighted SCI (volume) than probability-weighted (share).
2. **Trade channel:** Social ties facilitate informal trade networks. Test: Effects should be larger in départements with higher UK export/import shares.
3. **Migration/mobility channel:** Reduced cross-border worker flows. Test: Effects on inward migration from UK (if data available) and on housing demand in expat-heavy areas.
4. **Investment/FDI channel:** UK firms reduce investment in France. Test: Effects on firm creation in sectors with high UK FDI.

## Primary Specification

**Unit of observation:** French département × quarter
**Sample:** 96 metropolitan départements × 36 quarters (2014Q1–2022Q4)
**N ≈ 3,456 département-quarter observations**

**Primary outcome:** Log median housing transaction price from DVF (département-quarter)
**Secondary outcomes:**
- Log firm creation count (département-quarter, INSEE BDM)
- Unemployment rate (département-quarter, INSEE BDM)
- Log salaried employment (département-annual, INSEE ESTEL)

**Fixed effects:** Département FE + Quarter FE (baseline); Région × Quarter FE (demanding)

**Clustering:** By département (96 clusters)

## Exposure Alignment

- **Who is treated?** All French départements are "treated" with differential intensity based on SCI-weighted UK exposure
- **Primary estimand:** Average marginal effect of a one-unit increase in SCI-weighted Brexit exposure on local economic outcomes
- **Control population:** Within-France variation — départements with low UK SCI serve as implicit controls
- **Design:** Continuous treatment intensity DiD (not binary)

## Power Assessment

- **Pre-treatment periods:** 8 quarters (2014Q1–2015Q4)
- **Post-treatment periods:** 24+ quarters (2016Q3–2022Q4)
- **Clusters:** 96 départements (well above the 42 threshold for reliable cluster-robust inference)
- **Cross-sectional variation:** SCI weights vary substantially across départements — Île-de-France, Hauts-de-France (Calais), PACA, and Normandy have strong UK connections; interior départements (Creuse, Cantal) have weak connections
- **MDE:** To be computed after data assembly, but with 96 clusters and strong first stage, we expect reasonable power for economically meaningful effects

## Planned Robustness Checks

1. **German exposure placebo:** Replace UK SCI weights with German SCI weights; estimate same specification. Expect null.
2. **Pre-trends / event study:** Quarter-by-quarter coefficients from 2014Q1 through 2022Q4. Flat pre-2016Q2.
3. **Permutation inference:** Randomly reassign UK regional Brexit shocks across UK regions (2,000 draws). Compute share of permuted coefficients exceeding actual.
4. **Swiss franc positive placebo (Jan 2015):** SCI-weighted Swiss exposure should predict effects on border départements. Validates the SCI channel.
5. **Population-weighted vs probability-weighted SCI:** Following apep_0185 methodology. Expect population-weighted to dominate.
6. **Distance-restricted instruments:** Exclude nearby UK regions (London); use only distant UK connections. Tests whether effects are driven by local confounders or genuine network transmission.
7. **Leave-one-region-out:** Drop each UK region in turn to ensure no single region drives results.
8. **Alternative shock measures:** Use Bloom et al. (2025) firm-level exposure aggregated to ITL3 instead of GVA changes.
9. **COVID control:** Include COVID-period interactions to separate pandemic from trade-friction effects.
10. **Sector-irrelevant outcome placebo:** Estimate effects on purely domestic outcomes (public sector employment, agricultural employment in non-UK-connected sectors). Expect null.

## Data Sources

| Source | Level | Frequency | Years | Access |
|--------|-------|-----------|-------|--------|
| Facebook SCI (HDX gadm1.zip) | NUTS-3 pairs | Static | Oct 2021 | Free download |
| DVF (CEREMA DVF+) | Commune → dept. | Transaction | 2014-2023 | Free bulk download |
| INSEE Unemployment | Département | Quarterly | 1982-2025 | SDMX API (open) |
| INSEE Firm Creations | Département | Monthly | 2000-present | SDMX API (open) |
| INSEE Employment (ESTEL) | Département | Annual | 2007-present | SDMX API (open) |
| ONS Regional GVA | ITL3 (UK) | Annual | 1998-2023 | Excel download |
| Eurostat Regional | NUTS-3 (UK) | Annual | 1998-2019 | API (open) |
