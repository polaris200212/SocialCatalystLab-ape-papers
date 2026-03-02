# Reply to Internal Review (Round 1)

## Major Concerns

### 1. CS-DiD vs Sun-Abraham disagreement
**Concern:** The two heterogeneity-robust estimators give qualitatively different answers.

**Response:** We have substantially rewritten the robustness discussion (Section 7) to present this disagreement transparently rather than privileging CS-DiD. The abstract and introduction now characterize results as "suggestive" evidence rather than definitive findings. We explicitly acknowledge that the tightly clustered treatment cohorts make estimates sensitive to comparison group composition. We do not implement BJS imputation due to scope constraints but acknowledge this as a natural extension.

### 2. Thin control group
**Concern:** Zero never-treated mandis for wheat/soybean; not-yet-treated controls evaporate by 2018Q2.

**Response:** We have added an explicit caveat in the event study section noting that long-horizon coefficients (beyond 8 quarters) are identified primarily from early-vs-late cohort contrasts, not treated-vs-untreated comparisons. The limitations section already flagged this, and we have strengthened the language.

### 3. District sampling strategy
**Concern:** Only 6 districts per state sampled from the API; never disclosed.

**Response:** We have added a footnote in the data section disclosing the sampling strategy, explaining the API rate constraint motivation, and noting the coverage limitation. We acknowledge this restricts external validity.

### 4. State-level treatment assignment
**Concern:** Effective identifying variation is between 4 cohorts and 2 control states.

**Response:** We have rewritten the treatment assignment paragraph to explicitly acknowledge that variation is entirely between-state, and that the effective number of independent treatment contrasts is modest. We commit to reporting state-clustered standard errors alongside mandi-clustered results.

### 5. Missing arrival quantity analysis
**Concern:** Arrival effects were predicted by the framework but never estimated.

**Response:** We have added a limitation paragraph explaining that arrival quantity data in our sample is substantially sparser and noisier than prices, precluding reliable estimation. This is flagged as a natural extension for future work.

### 6. Null price dispersion result
**Concern:** The primary prediction of the conceptual framework fails and is under-discussed.

**Response:** We have substantially expanded the price dispersion discussion, offering three alternative explanations: (1) within-state CV may be the wrong measure given state-level treatment, (2) pre-existing information infrastructure reduced e-NAM's marginal value, (3) price-level effects may reflect local competition rather than spatial convergence.

## Minor Concerns

### 1. Circular placebo logic
Acknowledged. The parallel trends tests for wheat/soybean are necessary but not sufficient conditions. We do not claim they "prove" the design is valid, only that they are consistent with it.

### 2-3. Citation formatting
These are cosmetic issues that do not affect content. Noted for cleanup.

### 4. Low within R-squared
Low within R² is expected with rich fixed effects. The treatment effect is economically meaningful (4-8% price increase) even if it explains a small fraction of overall within-mandi variation.

### 5. Title "price discovery"
We retain the title as price discovery encompasses both levels and dispersion effects. The null dispersion result is itself informative about the nature of e-NAM's effects.

### 6. Abstract length
Revised to ~140 words.

### 7-10. Sun-Abraham SEs, power analysis, HonestDiD, dispersion clustering
Noted as valid improvements beyond the scope of this revision round.
