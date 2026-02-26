# Initial Research Plan — apep_0468

## Research Question

Does India's employment guarantee (MGNREGA) function as implicit crop insurance, enabling rural farmers to shift from safe staple crops toward riskier, higher-return commercial crops? We estimate the causal effect of MGNREGA on crop portfolio diversification using the program's three-phase staggered district rollout (2006–2008) and ICRISAT district-level agricultural data spanning 2000–2016.

## Motivation

Risk-averse farmers in developing countries systematically under-diversify their crop portfolios, planting safe but low-return staples instead of higher-value commercial crops (Rosenzweig & Binswanger 1993; Dercon & Christiaensen 2011). Formal crop insurance can shift this calculus—Cai, de Janvry, and Sadoulet (2016, AER) showed that crop insurance adoption in China increased tobacco planting by 20%. But formal insurance programs have limited reach in most developing countries.

MGNREGA—the world's largest public works program—guarantees 100 days of employment per rural household at the statutory minimum wage. By providing a reliable income floor during agricultural downturns, MGNREGA may function as *implicit* crop insurance: reducing the downside risk of crop failure and enabling farmers to diversify toward higher-return crops. If this channel operates, it reveals a previously undocumented welfare benefit of employment guarantees—one that compounds over time as farmers learn and agricultural markets adjust.

## Identification Strategy

**Design:** Staggered Difference-in-Differences exploiting MGNREGA's three-phase rollout:
- Phase I: February 2006 → 200 poorest districts (backwardness index)
- Phase II: April 2007 → +130 districts
- Phase III: April 2008 → all remaining ~310 rural districts

**Estimator:** Callaway & Sant'Anna (2021) group-time ATT, aggregated to dynamic event-study estimates. This avoids the negative weighting / forbidden comparison problems of traditional TWFE.

**Agricultural year alignment:** ICRISAT DLD uses agricultural years (July–June). First fully treated agricultural year:
- Phase I: 2006–07 (DLD year = 2007)
- Phase II: 2007–08 (DLD year = 2008)
- Phase III: 2008–09 (DLD year = 2009)

**Unit of analysis:** District × agricultural year (~300–571 districts × 17 years)

**Fixed effects:** District FE + agricultural year FE (absorbed by CS-DiD). State × year FE in robustness.

**Clustering:** State level (28–36 clusters). Robustness with district-level clustering.

## Expected Effects and Mechanisms

**Primary hypothesis:** MGNREGA increases crop diversification by reducing downside income risk for farming households.

**Mechanism:** MGNREGA guarantees Rs. 100–300/day (varies by state/year) for unskilled manual labor. During drought or crop failure, household income is partially insured. This reduces the variance of total household income, lowering the effective risk of switching from safe cereals (rice, wheat) to higher-return but riskier commercial crops (cotton, sugarcane, vegetables, spices).

**Expected sign:** Positive effect on crop diversification index; positive effect on commercial crop share; ambiguous effect on average yield (diversification may raise or lower mean yield depending on the crops chosen).

**Heterogeneity predictions:**
- Stronger effect in drought-prone districts (higher baseline risk)
- Stronger for smaller landholders (more risk-constrained)
- Stronger where MGNREGA take-up is higher (dose-response)

## Primary Specification

$$Y_{dt} = \alpha_d + \lambda_t + \sum_{g \in \{2007, 2008, 2009\}} \sum_{e} \delta_{g,e} \cdot \mathbb{1}[G_d = g] \cdot \mathbb{1}[t = g + e] + X_{dt}'\beta + \varepsilon_{dt}$$

Where:
- $Y_{dt}$: Crop diversification index for district $d$ in year $t$
- $G_d$: Treatment cohort (first fully treated DLD year: 2007, 2008, or 2009)
- $e$: Event time relative to treatment
- $X_{dt}$: Time-varying controls (rainfall, NFSM/NHM/BRGF exposure)
- Standard errors clustered at state level

**Primary outcomes:**
1. Crop diversification index: $1 - \text{HHI}$ where HHI = $\sum_c (area_c / total\_area)^2$ across 20 ICRISAT crops
2. Commercial crop share: (area of cotton + sugarcane + oilseeds + fruits + vegetables) / total cropped area
3. Cereal share: (area of rice + wheat + maize + sorghum + millet) / total cropped area (expected negative)

## Planned Robustness Checks

### Identification
1. **Event study with pre-trends:** Dynamic coefficients t-6 to t+10; joint F-test that pre-treatment coefficients = 0
2. **HonestDiD sensitivity:** Rambachan & Roth (2023) bounds under parallel trends violations
3. **Sun-Abraham (2021):** Interaction-weighted estimator as alternative to CS-DiD
4. **Bacon decomposition:** Show absence of forbidden comparisons in TWFE
5. **Synthetic DiD:** Arkhangelsky et al. (2021) as additional estimator

### Confound Controls
6. **Concurrent policy controls:** NFSM × post, NHM × post, BRGF × post indicators
7. **State × year FE:** Absorb all state-level agricultural policy changes
8. **Exclude NFSM districts:** Check if results survive dropping 312 NFSM districts
9. **Exclude BRGF-only districts:** Isolate MGNREGA from BRGF

### Mechanism
10. **Drought heterogeneity:** Interact treatment with baseline drought frequency (pre-2006 rainfall coefficient of variation)
11. **MGNREGA intensity:** Use person-days per capita as treatment intensity (dose-response)
12. **Landholding heterogeneity:** If data available, test by farm size (small vs. large)

### Inference
13. **Wild cluster bootstrap:** Webb (2023) wild bootstrap for small number of state clusters
14. **Randomization inference:** Permute treatment assignment across districts within states

## Exposure Alignment (DiD Checklist)

- **Who is actually treated?** Rural farming households in MGNREGA-eligible districts. MGNREGA provides an alternative income source that insures against crop failure.
- **Primary estimand population:** Cultivator households in treated districts
- **Placebo population:** Urban populations (unaffected by MGNREGA rural employment guarantee)
- **Design:** DiD (staggered, 3 cohorts)

## Power Assessment

- **Pre-treatment periods:** 6+ years (DLD 2001–2006 for Phase I)
- **Treated clusters (Phase I):** 200 districts (>> 20 threshold)
- **Total clusters:** ~300–571 districts depending on ICRISAT coverage
- **Post-treatment periods per cohort:** Phase I: up to 10 years (2007–2016); Phase III: up to 8 years
- **State-level clusters for inference:** 19–20 states in ICRISAT
- **MDE assessment:** With ~5,000 district-year observations, 200+ treated districts, and 6 pre-periods, the design should detect effects of 0.1–0.2 SD in crop diversification. Formal power calculation will be conducted after data assembly.

## Data Sources

| Source | Variables | Coverage | Access |
|--------|-----------|----------|--------|
| ICRISAT DLD | Crop area, production, yield (20 crops) | ~571 districts, 1966–2016 | Free download (confirmed) |
| ICRISAT DLD | Rainfall, irrigation | ~571 districts, 1966–2016 | Same |
| SHRUG Census PCA | Population, literacy, SC/ST, workers | Village → district aggregation | Local (available) |
| SHRUG Nightlights | DMSP/VIIRS luminosity | District-level, 1992–2021 | Local (available) |
| MGNREGA Phase Lists | Phase I/II/III district assignment | All districts | Government notifications |
| NFSM District Lists | NFSM districts | 312 districts | nfsm.gov.in |
| BRGF District Lists | BRGF districts | 250 districts | Planning Commission |

## Timeline

1. Fetch ICRISAT DLD data and MGNREGA phase assignment lists
2. Construct district × year panel with crop diversification outcomes
3. Merge treatment timing, baseline characteristics, concurrent policy exposure
4. Run primary CS-DiD specification and event study
5. Full robustness battery
6. Write paper (25+ pages)
7. Internal + external review
8. Publish
