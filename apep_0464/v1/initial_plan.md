# Initial Research Plan — apep_0464

## Title
Connected Backlash: Social Networks, Carbon Tax Incidence, and the Political Economy of Climate Policy in France

## Research Question
Do social network connections amplify political backlash to carbon pricing? Specifically, does network exposure to economically burdened areas — measured by the Facebook Social Connectedness Index — predict increases in populist (Rassemblement National) vote share beyond what direct economic incidence would predict?

## Identification Strategy

### Primary: Shift-Share Instrumental Variables
- **Shares:** Pre-existing SCI connections between départements (2020 vintage, predetermined relative to electoral outcomes)
- **Shifts:** Carbon tax exposure = département-level road fuel consumption per capita (SDES data, 2013 baseline) × carbon tax rate schedule (€7→€44.60/tCO2, 2014-2018)
- **Instrument:** NetworkCarbonExposure_dt = Σ_j SCI_dj × FuelPerCapita_j × CarbonRate_t
- **Outcome:** ΔRN_ct = change in RN first-round vote share at commune c in département d, election t
- **Exclusion restriction:** SCI connections to fuel-intensive areas affect local voting ONLY through information/grievance transmission, conditional on own département's economic conditions, geographic proximity, and demographic trends

### Supporting Strategies
1. **Event study around Gilets Jaunes (Nov 2018):** Interact network exposure with pre/post GJ indicators. Expect: flat pre-trends, sharp post-GJ divergence.
2. **Distance-restricted SCI:** Re-estimate using only SCI connections beyond 200km, 500km. If effects strengthen, this rules out pure geographic spillovers.
3. **Placebo outcomes:** Network exposure to fuel vulnerability should NOT predict: (a) left-bloc vote share, (b) centrist vote share, (c) local municipal election outcomes in non-political-economy dimensions.
4. **Leave-one-out:** Drop each département from the SCI computation to rule out dominant bilateral pairs.

## Expected Effects and Mechanisms

### Primary hypothesis
Départements with stronger SCI connections to fuel-vulnerable areas will see larger RN gains, even after controlling for their own fuel exposure. The network amplification coefficient γ > 0.

### Magnitude expectations (based on Flückiger & Ludwig 2025 and apep_0185)
- Flückiger & Ludwig find 1pp increase in network-weighted BLM protests → 1pp increase in own protest
- apep_0185 finds $1 network MW increase → 3.4% earnings effect
- For our setting: 1 SD increase in network carbon exposure → 1-3 pp additional RN vote share gain (beyond own exposure effect)

### Mechanisms
1. **Information transmission:** Voters learn about carbon tax costs from connected areas, updating beliefs about policy harm. Consistent with: effects concentrated among low-information voters, effects stronger for less-salient elections (European > presidential).
2. **Grievance amplification:** Hearing about others' suffering increases own resentment, even if own costs are moderate. Consistent with: network effects larger than direct effects for low-fuel départements.
3. **NOT migration:** Following apep_0185, verify that inter-département migration is not the mechanism (IRS/INSEE migration data).

## Primary Specification

### Reduced-form (commune-level)
```
RN_ct = α + β₁ × OwnFuelExposure_d(c) × Post_t
      + γ  × NetworkFuelExposure_d(c) × Post_t
      + δ  × X_ct + μ_c + τ_t + ε_ct
```
where:
- RN_ct: RN first-round vote share (%) in commune c, election t
- OwnFuelExposure_d(c): road fuel consumption per capita in commune c's département
- NetworkFuelExposure_d(c): SCI-weighted average of fuel consumption in connected départements
- Post_t: indicator for post-carbon-tax elections (2017+) or post-GJ (2019+)
- X_ct: time-varying controls (unemployment rate, median income, population growth)
- μ_c: commune fixed effects
- τ_t: election fixed effects
- Cluster SEs at département level (96 clusters)

**Key coefficient: γ** — the network amplification effect

### IV (first stage)
```
NetworkFuelExposure_d(c) × Post_t = π₁ × Σ_j SCI_dj × FuelPC_j × CarbonRate_t + controls + ε
```

### Structural model
A Bayesian learning model of political preference formation:
- Voters observe own carbon tax cost (noisy signal) and network signals
- Network signal = SCI-weighted average of connected areas' costs
- Vote RN if perceived total cost exceeds switching threshold
- Parameters: β (own cost weight), γ (network weight), δ (threshold), σ (noise)
- Estimation: MLE on département × election panel (N=576)
- Counterfactuals: (1) γ=0 world, (2) compensating transfers reducing c_dt

## Planned Robustness Checks

1. Alternative SCI specifications: probability-weighted vs. population-weighted (following apep_0185)
2. Distance-restricted SCI (200km, 500km, 1000km cutoffs)
3. Controlling for geographic proximity (distance × fuel exposure interaction)
4. Alternative fuel exposure measures: commuting CO2 (INSEE), fuel prices (prix-carburants), car modal share
5. Alternative political outcomes: turnout, blank votes, other party vote shares
6. Subsample analysis: urban vs. rural communes, high vs. low income départements
7. Permutation/randomization inference on SCI connections
8. Bacon decomposition for the DiD component
9. Sensitivity to SCI vintage (2021 vs. pre-2020 if available)
10. Honest DiD bounds (Rambachan & Roth 2023)

## Exposure Alignment (DiD Framework)

### Who is treated?
All French residents are "treated" by the carbon tax, but with vastly differential intensity. Treatment intensity = département-level fuel consumption per capita. Network treatment = SCI-weighted exposure to high-intensity départements.

### Primary estimand population
35,000+ French metropolitan communes across 96 départements, voters in first-round elections

### Comparison group
Within-commune over-time variation (commune FE), comparing high-network-exposure to low-network-exposure communes before and after carbon tax increases

### Design
Continuous treatment DiD with shift-share IV. Not binary staggered adoption — the carbon tax is national but incidence varies.

## Power Assessment

- **Elections:** 6 waves (presidential 2012, European 2014, presidential 2017, European 2019, presidential 2022, European 2024)
- **Pre-treatment periods:** 2 elections before significant carbon tax (2012, 2014); 3 before GJ (add 2017)
- **Post-treatment periods:** 3-4 elections after carbon tax/GJ
- **Treated clusters:** 96 départements with CONTINUOUS treatment variation (no binary cutoff)
- **Commune-level observations:** ~35,000 × 6 = 210,000
- **Expected effect size:** 1-3 pp RN vote share change per SD of network exposure
- **Within-commune SD of RN vote share:** ~5-8 pp across elections
- **Power:** With 210,000 obs and 96 clusters, detecting a 1 pp effect requires SE < 0.5 pp. With département-level clustering and rich within-commune variation, this should be achievable.

## Data Pipeline

| Script | Input | Output |
|--------|-------|--------|
| 00_packages.R | — | Library loading |
| 01_fetch_data.R | API endpoints, URLs | Raw data files |
| 02_clean_data.R | Raw data | Analysis panel |
| 03_main_analysis.R | Panel | Main regression tables |
| 04_robustness.R | Panel | Robustness tables |
| 05_figures.R | Panel + results | All figures |
| 06_tables.R | Results | All formatted tables |
| 07_structural.R | Panel | Structural model estimates |

## Timeline

1. Data acquisition and cleaning (01-02)
2. Descriptive analysis and maps (05)
3. Reduced-form estimation (03)
4. Robustness and placebo tests (04)
5. Structural model (07)
6. Paper writing
7. Review and revision
8. Publication
