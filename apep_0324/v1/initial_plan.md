# Initial Research Plan: Fear and Punitiveness in America

## Research Question

Does personal fear of crime cause individuals to support more punitive criminal justice policies? Specifically, does feeling unsafe in one's neighborhood — conditional on actual crime levels, demographics, and political ideology — predict stronger support for the death penalty, harsher courts, and more crime-related government spending?

## Identification Strategy

**Method:** Doubly Robust / Augmented Inverse Probability Weighting (AIPW)

**Treatment:** Binary indicator for fear of crime (GSS variable `fear`): "Is there any area right around here — that is, within a mile — where you would be afraid to walk alone at night?" (Yes = afraid, No = not afraid)

**Outcomes:**
1. Death penalty support (`cappun`): "Do you favor or oppose the death penalty for persons convicted of murder?"
2. Courts too lenient (`courts`): "In general, do you think the courts in this area deal too harshly or not harshly enough with criminals?"
3. Crime spending preferences (`natcrime`): "Are we spending too much money, too little money, or about the right amount on halting the rising crime rate?"

**Identifying assumption:** Conditional on a rich set of observables, fear of crime is as good as randomly assigned. Formally: (Y(1), Y(0)) ⊥ D | X, where D is fear status and X includes demographics, SES, political ideology, region, and year.

**Propensity score covariates (X):**
- Demographics: age (polynomial), sex, race (Black/White/Other), Hispanic ethnicity
- SES: education (years), parents' education (maeduc, paeduc), real family income (realinc)
- Family: marital status, number of children
- Political: political views (polviews, 7-point liberal-conservative), party ID (partyid)
- Geographic: region (4 categories), urban/rural (srcbelt, 6 categories)
- Temporal: year fixed effects
- Absorbers: region × year fixed effects (in robustness)

## Expected Effects and Mechanisms

**Hypothesized direction:** Fear of crime → increased punitive attitudes (death penalty support, demand for harsher courts, more crime spending).

**Mechanisms:**
1. **Availability heuristic:** Fearful individuals overweight crime risks in policy reasoning
2. **Protective motivation:** Fear triggers demand for deterrence and retribution
3. **Group threat theory:** Fear of crime maps onto racial/class anxieties that manifest as punitiveness

**Counterhypothesis:** If fear is entirely explained by demographics and ideology (after conditioning), the AIPW-adjusted effect will be null. This would suggest that punitiveness is a fixed ideological orientation, not responsive to personal safety experiences.

## Primary Specification

**AIPW estimator:**
$$\hat{\tau}_{AIPW} = \frac{1}{n}\sum_{i=1}^{n} \left[\frac{D_i Y_i}{\hat{e}(X_i)} - \frac{(D_i - \hat{e}(X_i))\hat{\mu}_1(X_i)}{\hat{e}(X_i)}\right] - \frac{1}{n}\sum_{i=1}^{n} \left[\frac{(1-D_i) Y_i}{1-\hat{e}(X_i)} + \frac{(D_i - \hat{e}(X_i))\hat{\mu}_0(X_i)}{1-\hat{e}(X_i)}\right]$$

Where:
- $\hat{e}(X_i)$ = estimated propensity score (logistic regression or random forest)
- $\hat{\mu}_d(X_i)$ = estimated conditional mean outcome (linear regression)

**Implementation in R:**
- `AIPW` package for standard AIPW estimation
- Cross-fitted propensity scores and outcome models (5-fold)
- Trimmed propensity scores (drop observations with ê < 0.05 or ê > 0.95)

## Planned Robustness Checks

1. **Propensity score overlap diagnostics:** Distribution plots, standardized mean differences (SMD < 0.1 threshold)
2. **Alternative propensity score models:** Logistic, probit, random forest, LASSO
3. **E-value sensitivity analysis:** Quantify minimum confounding strength needed to explain away results
4. **Subgroup analysis:** By decade (1970s/1980s/1990s/2000s/2010s/2020s), sex, race, education, political orientation
5. **Panel validation:** GSS panel waves (2006-2014) — measure fear in wave 1, punitive attitudes in wave 2/3
6. **Falsification/placebo tests:** Test effect of fear on unrelated attitudes (science spending, environmental spending, space spending)
7. **Alternative treatments:** Replace fear with trust, with actual victimization (if available), or with neighborhood crime proxy
8. **Region × year FE:** Saturated model absorbing all regional time trends
9. **Historical trends:** Show how the fear-punitiveness relationship has evolved over 50 years alongside the actual crime decline

## Data Sources

| Data | Source | Access | Variables |
|------|--------|--------|-----------|
| GSS cumulative | gssr R package | Confirmed | fear, cappun, courts, natcrime, demographics |
| GSS panel (2006-2014) | gssr R package | Confirmed | Panel waves for temporal ordering |
| FBI UCR crime rates | BLS/FBI API | Confirmed | Region-year actual crime rates (control variable) |

## Power Assessment

- Total observations: ~33,000 (fear × outcome overlap varies by outcome)
- Treatment prevalence: ~40% fear = 1 (varies by year, declining over time as actual crime fell)
- Expected effect size: 5-15 percentage points (modest, based on prior literature)
- With N=33,000, AIPW is well-powered for even small effects (MDE ~2 pp at 80% power)

## Timeline

1. Data preparation: Fetch GSS, construct variables, merge FBI crime data
2. Descriptive analysis: Trends in fear, punitiveness, actual crime over 50 years
3. Propensity score estimation: Model fear as function of X
4. AIPW estimation: Main results + heterogeneity
5. Robustness: E-values, panel validation, placebos
6. Paper writing: 25+ pages, submission-ready
