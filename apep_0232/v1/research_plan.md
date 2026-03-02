# Initial Research Plan: The Geography of Monetary Transmission

## Research Question

Does monetary policy transmit more strongly to regions with higher shares of hand-to-mouth (liquidity-constrained) households? If so, this provides the first cross-regional causal evidence for the central mechanism in Heterogeneous Agent New Keynesian (HANK) models.

## Identification Strategy

**Primary approach: Local projections with cross-state heterogeneity**

We estimate Jordà (2005) local projections at the state-month level:

$$Y_{s,t+h} - Y_{s,t-1} = \alpha_s^h + \alpha_t^h + \gamma^h (\text{MP}_t \times \text{HtM}_s) + \beta^h (\text{MP}_t \times X_s) + \delta^h Z_{s,t} + \varepsilon_{s,t+h}$$

Where:
- $Y_{s,t+h}$: Log nonfarm employment (or income) in state $s$ at horizon $h$
- $\text{MP}_t$: Bu-Rogers-Wu (2021) monetary policy shock (monthly, 1994–2020)
- $\text{HtM}_s$: Pre-determined hand-to-mouth household share (state-level, lagged)
- $X_s$: Vector of competing state characteristics (industry composition, non-tradable share, housing leverage, bank exposure)
- $Z_{s,t}$: Time-varying state controls (lagged employment growth, lagged income)
- $\alpha_s^h, \alpha_t^h$: State and time fixed effects

**Key parameter:** $\gamma^h$ — the differential monetary policy impulse response by HtM share. HANK predicts $\gamma^h > 0$ for employment responses to expansionary shocks (high-HtM states respond more).

**Secondary approach: Bartik IV for fiscal transfer multipliers**

State-level annual panel (2000–2023):
$$\Delta Y_{s,t} = \alpha_s + \alpha_t + \beta \widehat{\text{Transfer}}_{s,t} + \gamma (\widehat{\text{Transfer}}_{s,t} \times \text{HtM}_s) + \varepsilon_{s,t}$$

Where $\widehat{\text{Transfer}}_{s,t} = \sum_c \text{share}_{s,c,t_0} \times \Delta \text{National}_c,t$ is the Bartik instrument.

## Expected Effects and Mechanisms

**HANK predicts:**
1. $\gamma^h > 0$: States with more HtM households show larger employment responses to monetary easing (amplification effect)
2. The mechanism operates through the INDIRECT channel: monetary easing → aggregate demand → labor income → consumption by HtM households → further demand
3. Asymmetry: tightening hurts high-HtM states MORE than easing helps them (HtM cannot smooth negative shocks)
4. The HtM channel is distinct from the non-tradable channel (both should independently amplify)

**Expected magnitudes (from HANK calibrations):**
- Kaplan-Moll-Violante (2018): A 10pp increase in HtM share increases the employment elasticity to monetary shocks by ~20-40%
- A 100bp monetary easing: baseline employment rise of ~0.3% nationally; high-HtM states (top quartile) ~0.4-0.5%, low-HtM (bottom quartile) ~0.15-0.25%

## Primary Specification

Monthly state panel, local projections, horizons h = 0, 1, ..., 48 months:
- Dependent variable: 100 × (log employment_{s,t+h} - log employment_{s,t-1})
- Key regressor: MP_t × HtM_s (standardized)
- FE: State, year-month
- SE: Driscoll-Kraay (robust to cross-sectional dependence)

## Planned Robustness Checks

1. **Alternative HtM measures:** Poverty rate, SNAP recipiency, zero-financial-income share
2. **Horse race controls:** Manufacturing share, construction share, non-tradable share, homeownership, bank exposure
3. **Alternative monetary shocks:** Romer-Romer narrative, high-frequency (Nakamura-Steinsson)
4. **Asymmetry test:** Separate estimates for tightening (MP < 0) vs easing (MP > 0) episodes
5. **Placebo:** HtM should NOT predict differential responses to oil price shocks or technology shocks
6. **Fiscal transfer channel:** Bartik IV using BEA SAINC35 transfer categories (annual panel)
7. **Permutation inference:** Randomly reassign HtM rankings across states
8. **Pre-GFC vs post-GFC subsamples:** Test stability across monetary regimes

## Data Sources

| Data | Source | Frequency | Period |
|------|--------|-----------|--------|
| Monetary shocks | BRW (Fed website) | Monthly | 1994–2020 |
| State employment | FRED (BLS LAUS) | Monthly | 1990–2025 |
| Poverty rate | FRED (Census) | Annual | 1989–2024 |
| SNAP recipients | FRED | Annual/Monthly | varies |
| State GDP | BEA SAGDP | Annual | 1997–2023 |
| Transfer receipts | BEA SAINC35 | Annual | 2000–2023 |
| State personal income | BEA SQINC | Quarterly | 2005–2023 |
| Industry composition | BEA/BLS | Annual | varies |
| Homeownership | FRED/Census | Annual | varies |

## Paper Structure (Target: 28-30 pages)

1. Introduction (3 pages)
2. Theoretical Framework: A Simple Regional HANK Model (3 pages)
3. Data and Measurement (3 pages)
4. Empirical Strategy (3 pages)
5. Main Results: Monetary Transmission (5 pages)
6. The Fiscal Transfer Channel (3 pages)
7. Robustness and Mechanisms (4 pages)
8. Structural Interpretation: From Cross-State to Aggregate (2 pages)
9. Conclusion (1 page)
