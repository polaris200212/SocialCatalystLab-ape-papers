# Initial Research Plan — apep_0483

## Research Question

Did the UK's decade of teacher pay austerity (2010-2019) reduce student achievement in areas where teacher pay became least competitive relative to the private sector?

## Policy Context

Between 2010 and 2019, UK teacher salaries fell approximately 8% in real terms under the public-sector 1% pay cap. Teacher pay is set nationally via the School Teachers' Pay and Conditions Document (STPCD), but private-sector wages vary substantially across England's ~150 Local Authorities. In areas where private wages grew rapidly (tech corridors, financial centers), teacher pay became far less competitive — potentially driving talented teachers out of the profession or deterring high-quality candidates. In areas where private wages stagnated, the competitiveness shock was minimal.

## Identification Strategy

**Primary estimator: Doubly Robust Difference-in-Differences (DRDID)**

Following Sant'Anna & Zhao (2020, Journal of Econometrics):

1. **Panel structure:** LA × year, 2010/11-2022/23 (with pre-period from 2010/11)
2. **Treatment definition:** Binary — LAs in the top quartile of teacher-pay-competitiveness decline (measured as the change in teacher-to-private-wage ratio from 2010 to 2019)
3. **Treatment timing:** 2010-2019 austerity period; gradual treatment onset means we use a continuous competitiveness measure in robustness
4. **DR components:**
   - Propensity score model: P(high-shock LA | X) using 2010 baseline characteristics
   - Outcome regression model: E[GCSE | treatment, X] conditional on covariates
   - DRDID is consistent if either model is correctly specified

**Robustness estimators:**
- Two-way FE (LA + year) with cluster-robust SEs
- Bartik shift-share IV: predicted local wage growth from baseline (2005) industry employment shares × national industry-level wage growth
- Pure AIPW cross-sectional estimate (long differences, 2010 vs. 2019)

## Expected Effects and Mechanisms

**Hypothesis:** LAs experiencing the largest decline in teacher pay competitiveness will show:
1. Higher teacher vacancy rates (intermediate outcome, verifiable)
2. Lower teacher retention rates (intermediate outcome, verifiable)
3. Lower GCSE attainment (main outcome)
4. Larger achievement gaps for disadvantaged (FSM) students (heterogeneity)

**Mechanism chain:** Pay competitiveness decline → teacher exits/unfilled vacancies → lower replacement quality OR class coverage gaps → student achievement falls

**Expected direction:** Negative effect of competitiveness shock on student outcomes
**Expected magnitude:** Informed by Britton & Propper (2016) and Burgess et al. (2022), expect 0.5-2 Attainment 8 points reduction in high-shock LAs.

## Primary Specification

$$Y_{lt} = \alpha + \tau \cdot D_{lt} + X_{lt}'\beta + \mu_l + \lambda_t + \varepsilon_{lt}$$

Where:
- $Y_{lt}$: Average GCSE Attainment 8 score in LA $l$, year $t$
- $D_{lt}$: Treatment indicator (or continuous competitiveness ratio)
- $X_{lt}$: Time-varying covariates (pupil demographics, FSM share)
- $\mu_l$: LA fixed effects
- $\lambda_t$: Year fixed effects
- Clustered SEs at LA level

DRDID version replaces TWFE with the doubly robust estimator from Sant'Anna & Zhao (2020).

## Planned Robustness Checks

1. **Pre-trend tests:** Event-study coefficients for pre-austerity years (2010-2011)
2. **HonestDiD bounds:** Rambachan & Roth (2023) sensitivity to non-parallel trends
3. **Private school placebo:** Private schools set own pay; should not be affected by STPCD competitiveness
4. **Subject heterogeneity:** STEM (strong outside options) vs. humanities (weak outside options)
5. **Leave-one-out by region:** Ensure results not driven by London
6. **Bartik IV:** Predicted wage growth from baseline industry shares
7. **Rosenbaum Γ bounds:** Sensitivity to hidden bias magnitude
8. **Oster (2019) δ:** Coefficient stability under selection on unobservables
9. **Continuous treatment dose-response:** Generalized propensity score approach
10. **Alternative treatment definitions:** Median split, terciles, top/bottom quintile

## Exposure Alignment (DR-DiD)

- **Who is treated?** LAs where teacher pay competitiveness declined most during 2010-2019 austerity
- **Primary estimand population:** Students in state-funded schools in high-shock LAs
- **Placebo/control population:** (a) Students in low-shock LAs; (b) Private school students in all LAs
- **Design:** DRDID (doubly robust diff-in-diff) with binary treatment; TWFE with continuous treatment

## Power Assessment

- **Number of LAs:** ~150 LA districts in England with complete data
- **Pre-treatment periods:** 1-2 years (2009/10-2010/11) in KS4 data
- **Treated units:** ~38 LAs (top quartile)
- **Post-treatment periods:** ~12 (2011/12-2022/23)
- **Total observations:** ~150 × 14 = ~2,100 LA-year observations
- **MDE:** With 38 treated LAs, 112 control LAs, 14 years, and LA-clustered SEs, estimated MDE is approximately 1.5-2.0 Attainment 8 points (reasonable given mean ~46 and SD ~5 across LAs)

## Data Sources

| Source | Variable | Granularity | Period |
|--------|----------|-------------|--------|
| NOMIS ASHE (NM_99_1) | Median annual gross pay | LA district | 2005-2023 |
| DfE KS4 performance | Attainment 8, Progress 8, 5+ A*-C | LA | 2009/10-2024/25 |
| DfE SWC vacancies | Teacher vacancy rate | LA | 2010/11-2023/24 |
| DfE SWC retention | Teacher leaving rate | LA | 2010/11-2023/24 |
| ONS/NOMIS | Population, deprivation, demographics | LA | 2005-2023 |
| STPCD pay scales | National teacher pay by band | National | 2005-2023 |
