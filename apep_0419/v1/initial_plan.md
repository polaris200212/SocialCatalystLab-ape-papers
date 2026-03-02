# Initial Research Plan: Virtual Snow Days and the Weather-Absence Penalty for Working Parents

## Research Question

Do state laws authorizing virtual instruction during weather-related school closures reduce parental work absences during severe winter weather? In other words, does the availability of virtual learning eliminate the "snow day childcare scramble" that forces parents to miss work?

## Identification Strategy

**Staggered Difference-in-Differences** exploiting the differential timing of state virtual snow day law adoption. States authorized virtual instruction for weather closures at different times between 2011 and 2023, creating quasi-experimental variation.

**Triple-Difference (DDD):** The core design interacts three sources of variation:
1. **Policy adoption** (virtual snow day state vs. non-virtual state)
2. **Weather intensity** (heavy-snowfall months vs. mild months)
3. **Parental status** (parents of school-age children vs. non-parents)

The identifying assumption is that, absent virtual snow day laws, the relationship between snowfall intensity and parental work absences would have evolved similarly across adopting and non-adopting states.

## Expected Effects and Mechanisms

**Primary mechanism:** School closures for weather → parents need emergency childcare → parents miss work or reduce hours. Virtual instruction eliminates this channel by keeping children occupied at home during weather events.

**Expected direction:** Negative — virtual snow day authorization should REDUCE the hours gap (usual - actual hours worked) for parents during heavy-snowfall months relative to non-parents and non-heavy months.

**Effect heterogeneity:**
- Larger for single parents (no partner backup)
- Larger for parents of younger children (older children can self-supervise)
- Larger in high-snowfall states (more frequent school closures)
- Larger for hourly workers vs. salaried (less workplace flexibility)

## Exposure Alignment

**Who is actually treated?** Working parents of school-age children (ages 5-17) in states that authorize virtual instruction for weather closures.

**Primary estimand population:** Employed parents of school-age children, winter months.

**Placebo/control populations:**
1. Non-parents in the same state (should not be affected by school closure policies)
2. Parents in states without virtual snow day authorization
3. All workers during non-winter months (no school weather closures)

**Design:** Triple-difference (DDD) nested within staggered DiD.

## Primary Specification

### Data Sources

1. **CPS Monthly Microdata** (Census Bureau PUMD): Individual-level employment, hours worked (usual vs. actual), absence reasons, state FIPS, parental status. Years: 2005-2024.

2. **NOAA Storm Events Database**: State-month counts of winter weather events (Winter Storm, Heavy Snow, Blizzard, Ice Storm). Years: 2005-2024.

3. **State Virtual Snow Day Policy Database**: Compiled from EdWeek, NCSL, Governing.com, state legislation databases. Treatment year for each state.

### Main Model

State × winter-season panel (winters 2005/06 through 2023/24):

Y_{sw} = α_s + δ_w + β(VirtualSnowDay_{sw}) + γ(StormEvents_{sw}) + θ(VirtualSnowDay_{sw} × StormEvents_{sw}) + ε_{sw}

Where:
- Y_{sw} = mean hours gap for employed parents of school-age children in state s, winter w
- VirtualSnowDay_{sw} = 1 if state s has adopted virtual snow day law by winter w
- StormEvents_{sw} = count of significant winter weather events in state s during winter w
- θ is the parameter of interest: the attenuation of the hours gap during storms in virtual-snow-day states

### Estimator

**Primary:** Callaway-Sant'Anna (2021) with never-treated controls and uniform aggregation. Applied to the state × winter panel.

**Secondary:** TWFE as comparison (with Goodman-Bacon decomposition to diagnose bias).

**Inference:** State-level clustering with wild cluster bootstrap (MacKinnon and Webb 2018) given 8 pre-COVID treated clusters. Randomization inference as additional robustness.

## Power Assessment

- **Pre-treatment periods:** 6+ winters (2005/06 through 2010/11) before first adopters
- **Treated clusters (full sample):** 23+ states
- **Treated clusters (pre-COVID):** 8 states
- **Post-treatment periods per cohort:** 2-13 winters depending on adoption year
- **Individual observations per state-winter:** ~300 employed parents (from ~3,600 CPS respondents per state-quarter)
- **MDE given sample size:** To be computed after data construction

## Planned Robustness Checks

1. **Pre-COVID subsample (2005-2019):** Uses only pre-COVID adopters; avoids COVID contamination
2. **HonestDiD sensitivity analysis:** Rambachan-Roth bounds on parallel trends violations
3. **Placebo treatment group:** Same analysis for non-parents (should show null effect)
4. **Placebo outcome:** Summer months (no school closures, should show null)
5. **Alternative estimators:** Sun-Abraham, Gardner two-stage imputation
6. **Binary outcome:** Extensive margin (any absence) in addition to intensive margin (hours gap)
7. **Event study:** Dynamic treatment effects with CS-DiD
8. **Leave-one-out:** Drop each treated state to check sensitivity to any single state
