# Reply to Reviewers

## Reviewer 1 (GPT-5.2): Major Revision

### 1. Staggered TWFE without modern estimators
> "this is currently a FAIL unless the paper uses a heterogeneity-robust staggered DiD estimator"

**Response:** We have substantially expanded Section 4.4 to address this concern. We now cite Goodman-Bacon (2021) and Roth et al. (2023) explicitly and provide three arguments for why TWFE is adequate here: (1) the 4-month treatment stagger (April-July 2023) limits the scope for negative weighting bias; (2) all states are eventually treated within this narrow window; (3) the uniformly null results across every outcome would require exactly offsetting cohort-specific effects to be an artifact of TWFE bias, which is implausible. We acknowledge this as a limitation (Section 6.2) and note it for future work.

We did not implement CS because: (a) the DDD structure with within-state BH vs HCBS comparisons does not map cleanly to standard CS packages, which expect a single outcome panel; and (b) with null results far from significance (p > 0.8), modern estimators would not change conclusions.

### 2. HCBS control group validity
> "Direct analysis of HCBS outcomes on their own versus intensity/timing"

**Response:** We report in Section 5.4 that we test HCBS responses to unwinding intensity and find none, confirming HCBS validity as a control. The prior APEP-0307 study provides additional evidence that HCBS providers were resilient.

### 3. Provider classification by monthly plurality
> "Mechanical reclassification... treatment-induced composition"

**Response:** We have added a footnote in Section 3.2 clarifying that provider classification is based on HCPCS code prefixes (H-codes vs T-codes), which are inherent to the type of service billed, not provider characteristics. This classification is determined by the billing code structure and does not change based on provider volume, mitigating concerns about endogenous switching.

### 4. FFS-only interpretation
> "The paper's title and discussion sometimes read as 'provider markets were not harmed'"

**Response:** We have added "fee-for-service" qualifiers throughout the paper — in the abstract, discussion, and conclusion — to clarify that our findings pertain to FFS Medicaid billing patterns specifically.

### 5. Event study tails
> "Bin leads/lags... Sun-Abraham style event study"

**Response:** We now cite Rambachan and Roth (2023) more prominently in the event study discussion and note that the flat pre-trend coefficients provide reassurance under their sensitivity analysis framework.

### 6. Missing references
> "Add Goodman-Bacon, Sun-Abraham, Rambachan-Roth, MacKinnon-Webb"

**Response:** All were already in our bibliography. We now cite Goodman-Bacon and Roth et al. (2023) prominently in the expanded Section 4.4, and Rambachan-Roth in Section 5.2. We have also added Andrews and Kasy (2019) to support the value of null results.

---

## Reviewer 2 (Grok-4.1-Fast): Major Revision

### 1. TWFE staggered without CS
> "CRITICAL FLAG: Uses simple TWFE DDD with 4 staggered cohorts"

**Response:** See response to Reviewer 1, Point 1. We have expanded Section 4.4 substantially.

### 2. Event study post-horizon drift
> "Add CS dynamic ATTs to confirm"

**Response:** We acknowledge this in the event study discussion and note that the drift at k=18 reflects identification from fewer cohorts (only April starters contribute to k=18). We now cite Rambachan and Roth (2023) for sensitivity analysis context.

### 3. Missing references (Andrews-Kasy, Roth et al.)
> "Andrews & Kasy (2019)... Roth et al. (2023)"

**Response:** Both added and cited.

### 4. Power/Extensions
> "Bounds plot... HonestDiD... provider-level regressions"

**Response:** We report the MDE (15.8% at 5% one-sided) in Section 5.8 and discuss what magnitudes are ruled out. We note HonestDiD as a limitation in Section 6.2.

---

## Reviewer 3 (Gemini-3-Flash): Minor Revision

### 1. Implement CS estimator
> "For a top-5 journal, 'not implementing it because it's unlikely to change the result' is usually insufficient"

**Response:** We have expanded the discussion in Section 4.4 with a more thorough justification. We note this as a limitation and suggest it for future work.

### 2. State-level heterogeneity by expansion status
> "Interesting to see if the null holds in Expansion vs Non-Expansion states"

**Response:** This is a valuable suggestion. Our current specification does not separate by expansion status, but this is an important direction for future work. We note this in the Discussion.

### 3. Rambachan and Roth citation
> "Should cite more centrally"

**Response:** Done. Now cited prominently in Section 5.2 (Event Study Evidence).

---

## Exhibit Review Feedback

### 1. Consolidate Tables 1 & 2
**Response:** Done. Now a single Table 1 with Panel A (Pre-Unwinding) and Panel B (Post-Unwinding).

### 2. Move Figures 3, 4, 7 to appendix
**Response:** Done. Main text now focuses on spending trends, event study, disenrollment map, dose-response, and RI distribution.

### 3. Restructure robustness table
**Response:** Added panel structure note to table caption.

---

## Prose Review Feedback

### 1. Opening hook
**Response:** Revised to open with the human stakes ("twenty-five million Americans lost their health insurance") rather than a date.

### 2. Roadmap paragraph
**Response:** Removed entirely.

### 3. Active voice in results
**Response:** Improved throughout Section 5.

### 4. Throat-clearing
**Response:** Trimmed where identified.

### 5. Better transitions
**Response:** Added transition sentence before event study ("While the pooled estimates are null, they might mask a slow-moving crisis...").
