# Initial Research Plan: Does Sanitation Drive Development?

## Research Question

Does achieving Open Defecation Free (ODF) status under India's Swachh Bharat Mission (SBM-G) generate measurable economic returns, as captured by satellite nighttime lights?

## Identification Strategy

**Staggered Difference-in-Differences** exploiting state-level variation in ODF declaration timing (2016–2019).

- **Treatment:** Binary indicator for whether a state has been declared ODF, with fractional exposure weighting in the ODF declaration year.
- **Treatment timing:** Staggered across ~35 states/UTs over 3.5 years (May 2016 – October 2019).
- **Estimator:** Callaway and Sant'Anna (2021) heterogeneity-robust DiD, with not-yet-treated districts as the comparison group.
- **Clustering:** Standard errors clustered at the state level (treatment unit).
- **Unit of analysis:** District × year (~640 districts × 12 years VIIRS).

## Exposure Alignment

- **Who is treated:** Rural populations in districts within states that declare ODF.
- **Primary estimand:** Average treatment effect on the treated (ATT) — the change in district-level nighttime economic activity attributable to ODF declaration.
- **Placebo population:** Urban-only districts (SBM-G targets rural sanitation).
- **Design:** Standard two-way DiD (district and year fixed effects) with staggered treatment.

## Expected Effects and Mechanisms

**Positive effect channels:**
1. Health improvement → labor productivity gains → higher economic activity
2. Toilet construction spending → local fiscal multiplier
3. Women's time reallocation (reduced water-fetching/sanitation trips) → increased labor supply
4. Reduced disease burden → lower healthcare costs → higher consumption

**Null/negative channels:**
1. ODF declarations may be political window-dressing without genuine behavior change
2. Nightlights may be too coarse to capture sanitation-driven economic changes
3. Construction spending is one-time; no lasting economic boost

**Magnitude:** Given the indirect mapping from sanitation to nightlights, we expect modest effects if any. A 1–3% increase in district nightlights for treated states would be economically meaningful. We pre-commit to reporting null results if found.

## Primary Specification

```
Y_{d,t} = α_d + γ_t + β × ODF_{s(d),t} + ε_{d,t}
```

Where:
- Y = log(nightlights + 1) at district d in year t
- α_d = district fixed effects
- γ_t = year fixed effects
- ODF_{s(d),t} = treatment indicator (1 if state s containing district d has declared ODF by year t; fractional in declaration year)
- SE clustered at state level

## Planned Robustness Checks

1. **Callaway-Sant'Anna** group-time ATTs with event study decomposition
2. **Rural-only nightlights** (excluding Census towns from aggregation)
3. **Population-weighted nightlights** (per-capita economic activity)
4. **Exclude saturated urban pixels** (top decile of population)
5. **Alternative outcome measures:** mean luminosity, max luminosity, lit area
6. **Extended pre-treatment window** using calibrated DMSP (2010–2013) + VIIRS (2014–2023)
7. **Heterogeneity:** Baseline OD prevalence, rural share, political alignment (BJP vs non-BJP states)
8. **Placebo:** Effect on urban-only areas (SBM-G doesn't target urban)
9. **NFHS validation:** Show ODF correlates with actual sanitation improvement
10. **Randomization Inference** for p-values robust to few-cluster concerns (35 state clusters)

## Power Assessment

- **Pre-treatment periods:** 4 years VIIRS (2012–2015); 6 with DMSP calibration (2010–2015)
- **Treated clusters:** 35 states/UTs (all eventually treated; ~10 states in early cohorts)
- **Post-treatment periods per cohort:** 4–7 years (early declarers: 2016 → 2023)
- **MDE:** With 640 districts, 35 state clusters, and within-R² ~ 0.05 for nightlights, we expect to detect effects of ~2–3% changes in nightlights at α=0.05. This is feasible for large programs but may miss subtle effects.

## Data Sources

| Data | Source | Coverage | Role |
|------|--------|----------|------|
| VIIRS nightlights | SHRUG (local) | 2012–2023, village-level | Primary outcome |
| DMSP nightlights | SHRUG (local) | 1994–2013, village-level | Extended pre-treatment |
| Census PCA 2011 | SHRUG (local) | Village-level | Controls, population weights |
| Census PCA 2001 | SHRUG (local) | Village-level | Baseline controls |
| Geographic crosswalk | SHRUG (local) | Village → district → state | Aggregation |
| State ODF dates | PIB press releases | State-level | Treatment timing |
| NFHS-4/5 factsheets | rchiips.org | District-level | Validation |

## Analysis Script Structure

```
code/
├── 00_packages.R          — Load libraries, set themes
├── 01_fetch_data.R         — Construct state ODF treatment dates
├── 02_clean_data.R         — Build district × year nightlights panel
├── 03_main_analysis.R      — TWFE and CS-DiD primary regressions
├── 04_robustness.R         — Placebo, heterogeneity, RI, sensitivity
├── 05_figures.R            — Event study plots, maps, descriptive figures
├── 06_tables.R             — Summary stats, regression tables
```
