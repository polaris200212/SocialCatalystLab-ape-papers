# Initial Research Plan: apep_0462

## Research Question

Did restoring the 90 km/h speed limit on French departmental roads reverse the safety gains achieved by the 2018 reduction to 80 km/h? We exploit the staggered adoption of speed limit reversals across départements following the December 2019 Loi d'Orientation des Mobilités (LOM) to estimate the causal effect on road accidents and casualties.

## Identification Strategy

**Design:** Staggered difference-in-differences

**Treatment:** Departmental council vote to restore 90 km/h on routes départementales, with effective dates varying across 52 départements from January 2020 through 2026.

**Control:** ~40 metropolitan départements that maintained 80 km/h plus 4 urban départements without eligible roads (Paris, Hauts-de-Seine, Seine-Saint-Denis, Val-de-Marne).

**Estimator:** Callaway and Sant'Anna (2021) — heterogeneity-robust, handles staggered adoption without "forbidden comparisons" between early and late treated units.

**Unit of analysis:** Département × quarter (primary), département × year (robustness).

**Sample period:** Q3 2018 – Q4 2024 (quarterly), 2015–2024 (annual).

## Exposure Alignment

**Who is actually treated?** Drivers on routes départementales outside agglomeration in départements that restored 90 km/h. These roads are two-lane, bidirectional, outside built-up areas.

**Primary estimand population:** Road users on treated roads (identified by BAAC fields: catr=3, agg=2, dep=treated département).

**Placebo/control population:** (a) Road users on autoroutes in the same treated départements (speed limit unchanged). (b) Road users on routes départementales within agglomeration (50 km/h, unchanged). (c) Road users in never-treated départements on the same road types.

**Design:** DiD. Triple-difference (DDD) as robustness: treated dept × departmental road × post-reversal, netting out département-wide trends via autoroute accidents.

## Expected Effects and Mechanisms

**Primary hypothesis:** Restoring 90 km/h increases road accidents and fatalities on affected roads. Kinetic energy scales as v², so a 12.5% speed increase (80→90) raises crash energy by ~27%, making accidents more severe.

**Expected magnitude:** ONISR estimated +13% in fatalities in reversal départements (2021). We expect a positive ATT of 8-15% for total corporal accidents and a larger effect (12-20%) on fatalities due to the severity channel.

**Mechanisms:**
1. Speed channel: Higher speeds → shorter reaction time → more accidents
2. Severity channel: Higher speeds → more kinetic energy → more severe outcomes conditional on accident
3. Behavioral channel: Speed limit signal may affect behavior beyond the treated roads (speed culture spillover)

**Possible null result:** If actual driving speeds changed little (speed limit compliance was already low), or if road engineering improvements offset speed effects, we may find a null.

## Primary Specification

```
Y_{dt} = α_d + γ_t + Σ_g Σ_e ATT(g,e) × 1{G_d = g, t-g = e} + ε_{dt}
```

Where:
- Y_{dt}: accidents (or fatalities, injuries) per 100,000 population in département d, quarter t
- α_d: département fixed effects
- γ_t: quarter fixed effects
- G_d: treatment cohort (quarter of 90 km/h restoration)
- ATT(g,e): group-time average treatment effect
- Cluster-robust standard errors at département level

**Implementation:** R package `did` (Callaway & Sant'Anna), with `anticipation = 0`, `control_group = "nevertreated"`.

## Power Assessment

| Criterion | Value |
|-----------|-------|
| Pre-treatment periods (quarterly, Q3 2018 – Q4 2019) | 6 quarters |
| Treated clusters | 52 départements |
| Control clusters | ~44 départements (never-treated + excluded) |
| Post-treatment periods per cohort | Varies: 4-20 quarters |
| Primary outcome mean | ~100 accidents/dept/year; ~25/quarter |
| Primary outcome SD | ~50/dept/year (substantial cross-sectional variation) |
| MDE (total accidents, annual, α=0.05, power=0.80) | ~12% (≈12 accidents/dept/year) |
| MDE (fatalities, annual, α=0.05, power=0.80) | ~35% (underpowered for small fatality effects) |

Fatalities are underpowered as a standalone outcome — report but rely on total accidents and serious injuries for primary inference.

## Planned Robustness Checks

1. **Sun and Abraham (2021)** interaction-weighted estimator
2. **De Chaisemartin and D'Haultfoeuille (2020)** estimator
3. **Placebo outcome:** Autoroute accidents in treated départements
4. **Placebo outcome:** Accidents within agglomeration (50 km/h roads)
5. **Triple-difference:** Treated dept × departmental road × post
6. **Intensity:** Continuous treatment (share of network restored) instead of binary
7. **COVID robustness:** (a) Exclude 2020 Q1-Q3, (b) Post-2021 adopters only, (c) Google Mobility controls
8. **Heterogeneity:** By département urbanization, by road network density, by political orientation of council
9. **HonestDiD:** Sensitivity to parallel trends violations (Rambachan & Roth 2023)
10. **Bacon decomposition:** Show absence of forbidden comparisons
11. **Randomization inference:** Permute treatment timing across départements

## Data Sources

| Data | Source | Period | Key Variables |
|------|--------|--------|---------------|
| Road accidents | BAAC (data.gouv.fr) | 2005-2024 | dep, catr, agg, grav, date, GPS |
| Treatment timing | Web compilation | 2020-2026 | dep, effective_date, km_restored |
| Population | INSEE | 2015-2024 | dep, population |
| Google Mobility | Google | 2020-2022 | dep, driving mobility index |
| Political control | Elections data | 2015-2021 | dep, council majority |

## Timeline

1. Compile treatment panel (département × reversal date × intensity)
2. Download and clean BAAC 2015-2024
3. Merge and construct département-quarter panel
4. Run CS-DiD main specification + event study
5. Robustness checks
6. Write paper (25-30 pages)
7. Review and publish
