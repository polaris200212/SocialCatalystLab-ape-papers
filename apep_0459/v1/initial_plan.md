# Initial Research Plan: apep_0459

## Research Question

Do state skills-based hiring laws — which remove bachelor's degree requirements for government jobs — actually change the educational composition of the public sector workforce? Or are they performative policies that alter job postings without changing who gets hired?

## Motivation and Epistemic Framing

For decades, the bachelor's degree has functioned as the primary credential gatekeeping access to knowledge-economy employment — a modern analog to the priestly ordination that once controlled access to written texts. Between 2022 and 2025, over 20 US states ran the largest experiment in "de-credentialization" in American history, removing degree requirements for state government positions. Yet the only existing evidence (Blair et al. 2024, NBER WP 33220) examines job postings, not actual employment. A Harvard/Burning Glass report (Fuller et al. 2024) found that private sector firms who removed degree requirements from postings still rarely hired non-degree workers. This paper tests whether the public sector behaves differently — whether the credential gatekeeping function can actually be dismantled by policy.

## Identification Strategy

**Staggered Difference-in-Differences** using Callaway and Sant'Anna (2021).

- **Treatment:** State adoption of skills-based hiring law or executive order (binary, by effective date)
- **Treatment group:** 20+ states with documented adoption dates (March 2022 – January 2025)
- **Control group:** Never-treated and not-yet-treated states
- **Unit of analysis:** State × year (ACS annual data)
- **Pre-treatment periods:** 2012–2021 (10 years minimum)
- **Post-treatment periods:** 2022–2023 (ACS), potentially 2024

### Exposure Alignment

- **Who is actually treated?** State government employees and applicants in treated states
- **Primary estimand population:** State government workers identified via ACS class-of-worker variable (COW = "state government employee")
- **Placebo/control population:** (1) Private sector workers in same states; (2) Federal government workers in same states; (3) Local government workers in same states (policies target state government specifically)
- **Design:** DiD with triple-diff placebo (state gov vs. other sectors within treated states)

### Power Assessment

- **Pre-treatment periods:** 10 (ACS 2012-2021)
- **Treated clusters:** 20+ states
- **Post-treatment periods per cohort:** 1-2 years for most cohorts; 2 years for early adopters (Maryland, Tennessee, 2022)
- **Sample size:** ACS provides ~3.5M observations/year. Approximately 5-7% are state government employees (~175K-245K/year). State-level cells have hundreds to thousands of observations.
- **MDE:** With 50 states and 12+ years, standard power calculations for cluster-level DiD suggest we can detect effects of ~2-3 percentage points on the share of non-degree workers.

## Expected Effects and Mechanisms

**Primary hypothesis:** Skills-based hiring laws increase the share of state government employees without bachelor's degrees.

**Competing hypotheses:**
1. **Null effect (credential inertia):** Hiring managers continue to prefer degreed candidates regardless of policy. The degree requirement was a screen, not a mandate — removing the formal requirement doesn't change informal preferences. Fuller et al. (2024) suggests this is the likely outcome.
2. **Positive effect (barrier removal):** Non-degree workers who were previously screened out now apply and get hired. Workforce composition shifts toward more diverse educational backgrounds.
3. **Heterogeneous effects:** Strong effects in states with robust implementation (Utah: 98% of jobs affected) vs. weak effects in states with symbolic executive orders.

**Mechanisms to test:**
- Labor market tightness as moderator (tight markets → stronger incentive to remove barriers)
- Occupational heterogeneity (effects stronger in administrative/clerical roles vs. professional/technical)
- Demographic composition (do non-white workers disproportionately benefit?)

## Primary Specification

$$Y_{st} = \alpha_s + \gamma_t + \beta \cdot \text{Treated}_{st} + X_{st}'\delta + \epsilon_{st}$$

Where:
- $Y_{st}$ = share of state government employees without BA in state $s$, year $t$
- $\text{Treated}_{st}$ = 1 if state $s$ adopted SBH policy by year $t$
- $X_{st}$ = state-year controls (unemployment rate, state GDP per capita, total government employment)
- $\alpha_s, \gamma_t$ = state and year fixed effects

Estimated using Callaway-Sant'Anna (2021) ATT(g,t) with never-treated as comparison group.

## Planned Robustness Checks

1. **Triple-difference (DDD):** Compare state government workers to private sector workers within treated states. If the effect is driven by the policy (not state-level trends), it should show up only in the state government sector.
2. **Event study:** Plot ATT(g,t) for each cohort to verify no pre-trends and assess dynamic effects
3. **Heterogeneity by policy strength:** Classify states as "strong" (legislative mandate or executive order affecting 90%+ of positions) vs. "weak" (review/consideration orders). Test dose-response.
4. **Heterogeneity by labor market tightness:** Interact treatment with state unemployment rate
5. **Heterogeneity by occupation type:** Split by broad occupation categories (administrative, professional, protective services)
6. **Demographic decomposition:** Test whether non-white workers, rural workers, or younger workers disproportionately enter state government post-policy
7. **Bacon decomposition:** Verify that results are not driven by problematic comparisons in TWFE
8. **Sun and Abraham (2021) estimator:** Alternative heterogeneity-robust estimator as sensitivity check
9. **HonestDiD sensitivity analysis:** Assess robustness to violations of parallel trends

## Data Sources

| Source | Variables | Years | Granularity |
|--------|-----------|-------|-------------|
| ACS (IPUMS) | Class of worker, education, occupation, earnings, race, age, state | 2012-2023 | Individual (state identifiable) |
| CPS Monthly (IPUMS) | Same as ACS, monthly frequency | 2019-2025 | Individual (state identifiable) |
| FRED | State unemployment rate | 2012-2024 | State × month |
| BEA | State GDP per capita | 2012-2023 | State × year |
| NCSL/NGA/Executive orders | Policy adoption dates | 2022-2025 | State |

## Timeline

1. Construct treatment variable (state × year policy adoption dates) from executive orders and legislation
2. Fetch ACS microdata from IPUMS API (2012-2023)
3. Construct outcomes: education composition, demographics, earnings by education
4. Fetch controls from FRED and BEA
5. Run primary specification (CS-DiD) and event study
6. Run robustness checks (DDD, heterogeneity, Bacon decomposition)
7. Generate figures and tables
8. Write paper (25+ pages)
