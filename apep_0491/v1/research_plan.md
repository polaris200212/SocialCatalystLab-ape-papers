# Initial Research Plan — apep_0491

## Research Question

Do Extreme Risk Protection Orders (ERPOs / "red flag" laws) reduce violent crime? Specifically, does staggered state adoption of ERPOs lead to reductions in firearm homicide, aggravated assault, and robbery, and through what mechanisms?

## Identification Strategy

**Design:** Callaway & Sant'Anna (2021) staggered difference-in-differences exploiting cross-state variation in ERPO adoption timing across 22 states (1999–2024).

**Treatment:** Binary indicator for ERPO law effective date in state *s* at time *t*. Treatment groups defined by adoption cohort (CT 1999, IN 2005, CA 2016, WA 2016, 2018 wave [8 states], 2019 wave [4 states], 2020 wave [4 states], 2024 wave [2 states]).

**Control:** 28 never-adopting states. Secondary: not-yet-treated states per CS-DiD. Anti-ERPO states (OK, TN, WV, WY, MT, TX) as explicit placebo group.

**Estimand:** Group-time average treatment effects on the treated (ATT), aggregated to overall ATT, dynamic ATT (event-time), and cohort-specific ATT.

## Expected Effects and Mechanisms

**Primary hypothesis:** ERPO laws reduce firearm-involved violent crime by temporarily removing firearms from individuals at risk of perpetrating violence. Expected mechanism chain:

1. ERPO law adoption → ERPO petitions filed (first stage / demonstrated bite)
2. Firearm removal → Reduced firearm homicide and aggravated assault
3. Effect concentrated in intimate-partner violence contexts (where risk is most observable)
4. No effect on non-firearm homicide (placebo — mechanism operates through firearms)
5. No effect on property crime (placebo — ERPOs target interpersonal violence risk)

**Expected sign:** Negative (crime reduction). **Plausible magnitude:** 5–15% reduction in firearm homicide, based on prior single-state estimates (Florida ~11% per JAMA 2024; Heflin 2023 ~10%).

**Null result scenario:** If effects are precisely estimated near zero with demonstrated policy bite (petitions filed), this is a valuable contribution — it would suggest ERPOs are insufficient for violent crime reduction despite reducing suicide (the established channel).

## Exposure Alignment (DiD Requirements)

- **Who is actually treated?** Individuals in ERPO-adopting states who would have committed firearm violence absent the law. Broad population-level intent-to-treat.
- **Primary estimand population:** State-level crime rates (per 100,000) in ERPO states.
- **Placebo/control population:** Never-adopting states; non-firearm crime within treated states.
- **Design:** Staggered DiD (not triple-diff in baseline; DDD as robustness with firearm vs. non-firearm).

## Power Assessment

- **Pre-treatment periods:** 5+ years for all cohorts (2018 wave: 2000–2017 = 18 years). CT: 1960–1998 = 39 years.
- **Treated clusters:** 22 states (exceeds 20-state minimum).
- **Post-treatment periods per cohort:** CT: 24 years, IN: 18 years, 2016 wave: 7 years, 2018 wave: 5 years, 2019 wave: 4 years, 2020 wave: 3 years.
- **MDE:** With 50 state-year clusters, σ ≈ 2–3 per 100K for murder rate, we can detect ~10–15% changes in murder rates at 80% power (will compute precisely after data).

## Primary Specification

$$Y_{st} = \text{CS-DiD ATT}(g,t) \text{ aggregated over groups and time}$$

Where $Y_{st}$ is crime rate per 100,000 in state $s$, year $t$. Group $g$ defined by ERPO adoption year. Estimated using `did` R package (Callaway & Sant'Anna 2021).

**Covariates:** State and year fixed effects (implicit in CS-DiD). Time-varying controls in robustness: unemployment rate, poverty rate, population, concurrent gun legislation indicators (from RAND Firearm Law Database).

## Planned Robustness Checks

1. **Event study:** Dynamic treatment effects from t-10 to t+8 for visual pre-trend verification
2. **HonestDiD sensitivity:** Rambachan & Roth (2023) bounds under partial violations of parallel trends
3. **Never-treated vs. not-yet-treated:** Compare results using different control groups
4. **Leave-one-state-out:** Jackknife dropping each treated state to check sensitivity
5. **Leave-one-cohort-out:** Drop the 2018 cluster (8 states) to verify results aren't driven by a single wave
6. **Concurrent policy controls:** Add RAND firearm law indicators for universal background checks, permit-to-purchase, waiting periods
7. **DDD: Firearm vs. non-firearm:** ERPO × post × firearm-crime (from SHR weapon type)
8. **Placebo outcomes:** Property crime rates (burglary, larceny, MVT) — should show no effect
9. **Anti-ERPO states:** Explicit test of whether anti-ERPO laws are associated with crime changes
10. **Wild cluster bootstrap:** For inference robustness with state-level clustering
11. **Randomization inference:** Permutation test shuffling treatment assignment across states
12. **Sample restrictions:** Drop 2021 (UCR transition year); restrict to continuously-reporting agencies

## Data Sources

| Source | Variables | Coverage |
|--------|-----------|----------|
| Kaplan UCR Offenses Known (Harvard Dataverse) | Murder, assault, robbery, burglary, larceny, MVT, clearance rates | 1960–2023, agency-level |
| Kaplan SHR (Supplementary Homicide Reports) | Weapon type, victim-offender relationship, circumstances | 1976–2023, incident-level |
| RAND State Firearm Law Database | 50+ gun law provisions | 1991–2023, state-level |
| National ERPO Resource Center | ERPO adoption dates | All 22 states |
| Census/ACS | Population, demographics | Annual, state-level |
| BLS/FRED | Unemployment rate | Monthly, state-level |

## Code Pipeline

```
00_packages.R         — Libraries (data.table, fixest, did, HonestDiD, arrow, ggplot2)
01_fetch_data.R       — Download UCR + SHR + RAND firearm laws + covariates
02_clean_data.R       — Build state × year panel; code ERPO treatment; merge controls
03_main_analysis.R    — CS-DiD main specification + event study
04_robustness.R       — All 12 robustness checks above
05_figures.R          — Event study plots, coefficient plots, mechanism decomposition
06_tables.R           — Summary stats, main results, robustness, heterogeneity
```

## Timeline

1. **Data construction:** Build state × year panel from UCR + SHR + RAND
2. **Descriptive analysis:** Crime trends by ERPO adoption status; balance tables
3. **Main specification:** CS-DiD with event study
4. **Mechanism analysis:** Firearm vs. non-firearm decomposition; IPV decomposition
5. **Robustness:** Full battery of 12 checks
6. **Paper writing:** 25+ pages with full results
