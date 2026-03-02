# Initial Research Plan: apep_0277

## Research Question

Do comprehensive indoor smoking bans change social norms around smoking — leading to voluntary behavior change (quit attempts, reduced consumption) beyond their direct legal reach — or do they merely relocate smoking from regulated venues to unregulated settings?

## Identification Strategy

**Method:** Doubly-robust difference-in-differences (Callaway & Sant'Anna, 2021)

**Treatment:** Statewide comprehensive indoor smoking ban adoption (covering workplaces, restaurants, AND bars). 28 states + DC adopted between 2002 and 2016.

**Treatment timing (from CDC MMWR 2011, 2016):**

| State | Year | State | Year |
|-------|------|-------|------|
| Delaware | 2002 | Illinois | 2008 |
| New York | 2003 | Iowa | 2008 |
| Massachusetts | 2004 | Maryland | 2008 |
| Rhode Island | 2005 | Maine | 2009 |
| Washington | 2005 | Montana | 2009 |
| Colorado | 2006 | Nebraska | 2009 |
| Hawaii | 2006 | Oregon | 2009 |
| New Jersey | 2006 | Utah | 2009 |
| Ohio | 2006 | Vermont | 2009 |
| Arizona | 2007 | Kansas | 2010 |
| DC | 2007 | Michigan | 2010 |
| Minnesota | 2007 | South Dakota | 2010 |
| New Mexico | 2007 | Wisconsin | 2010 |
|  |  | North Dakota | 2012 |
|  |  | California | 2016 |

**Comparison group:** ~22 states that never adopted comprehensive statewide bans as of 2023.

## Expected Effects and Mechanisms

**Hypothesis 1 (Compliance only):** Smoking bans reduce workplace/restaurant secondhand smoke exposure but have no effect on smoking BEHAVIOR (prevalence, quit attempts, intensity). Smokers relocate to unregulated settings. Treatment effect on quit attempts = 0.

**Hypothesis 2 (Norm internalization):** Bans change social norms by:
- Making non-smoking the visible default in public spaces
- Reducing perceived prevalence of smoking (empirical expectations shift)
- Signaling social disapproval of smoking (normative expectations shift)
- Creating environments where quitting is socially reinforced

Under H2: quit attempts increase, daily cigarette consumption decreases, and effects grow over time as norms deepen.

**Expected magnitudes:** Based on Carpenter et al. (2011) and the existing literature, I expect 1–3 percentage point reductions in current smoking prevalence (from a ~20% baseline in early 2000s), and 3–5 percentage point increases in quit attempts. The key TEST is whether these effects are:
- Immediate and flat (compliance) OR
- Delayed and growing (norm internalization)

## Primary Specification

Individual-level DR-DiD using the `did` package in R:

```
ATT(g,t) = E[Y_t(1) - Y_t(0) | G=g]
```

Where:
- Y = current smoker (binary), quit attempts (binary), cigarettes per day (intensive)
- G = year of comprehensive ban adoption (group)
- t = year of observation
- Covariates for DR: age, sex, race, education, income, state cigarette tax, Medicaid expansion status

Group-time ATTs aggregated using:
1. Simple average ATT (overall effect)
2. Event-time aggregation (dynamic effects / event study)
3. Calendar-time aggregation (time-varying effects)

## Exposure Alignment (DiD Design)

**Who is treated:** All residents of states with comprehensive indoor smoking bans.

**Primary estimand population:** Adult current smokers (for quit attempts, intensity) and all adults (for prevalence).

**Placebo/control population:** Adults in non-adopting states.

**Design:** Staggered DiD with doubly-robust estimation. NOT triple-diff.

## Power Assessment

- **Pre-treatment periods:** 7+ years for all states (BRFSS from 1995; earliest ban in 2002)
- **Treated clusters:** 28 states + DC = 29 treated units
- **Post-treatment periods:** 7–21 years depending on cohort
- **Sample size:** BRFSS surveys ~400,000 adults per year × 28 years = ~11 million observations
- **Baseline smoking rate:** ~23% in 2000, declining to ~12% by 2020
- **Expected MDE:** With N ≈ 11M and 29 treated clusters, MDE is well below 1 pp for prevalence and ~2 pp for quit attempts

## Planned Robustness Checks

1. **Event study plots** — pre-treatment coefficients should be near zero
2. **HonestDiD** — Rambachan & Roth sensitivity analysis for violations of parallel trends
3. **Cigarette tax controls** — time-varying state excise tax rates
4. **Tobacco-control spending** — CDC STATE System per-capita expenditures
5. **Medicaid cessation coverage** — ACA expansion and state cessation benefit timing
6. **Leave-one-region-out** — drop each Census region and re-estimate
7. **Border-state comparison** — restrict controls to geographically contiguous states
8. **Drop partial-exposure year** — use only full calendar years of exposure
9. **Placebo test on non-smokers** — quit attempts should not change for never-smokers (mechanical check)
10. **Randomization inference** — permute treatment timing 1000 times for exact p-values

## Data Sources

| Data | Source | Years | Access |
|------|--------|-------|--------|
| Smoking outcomes | BRFSS (CDC) | 1995–2023 | Download XPT files |
| Cigarette taxes | Tax Foundation / CDC STATE System | 1995–2023 | Web/API |
| Tobacco spending | CDC STATE System | 2000–2023 | API |
| Demographics | BRFSS internal | 1995–2023 | Same as outcomes |
| Medicaid expansion | KFF | 2014+ | Published tables |
| Policy dates | CDC MMWR | 2002–2016 | Published (hardcoded) |
| State populations | Census ACS | 2000–2023 | tidycensus |
