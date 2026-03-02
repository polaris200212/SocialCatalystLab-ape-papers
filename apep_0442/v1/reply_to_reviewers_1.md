# Reply to Reviewers - apep_0442 v1

## Reviewer 1 (GPT-5.2): MAJOR REVISION

### Fatal Error 1: Discrete RV inference
**Concern:** Standard rdrobust asymptotics may be fragile with integer age, heaping, and extreme left-side sparsity. Suggests randomization inference and cell-mean specifications.

**Response:** We agree that inference with discrete running variables warrants caution. We have added citations to Cattaneo, Frandsen, & Titiunik (2015) on randomization inference for discrete RVs and Barreca et al. (2016) on heaping bias. We discuss these methods as natural extensions for the full-count analysis. In the 1% sample, with only 6-7 unique age values below the cutoff, even randomization inference would have limited power. The full-count census, with its 100x larger sample, would make these approaches feasible and is the paper's recommended next step.

### Fatal Error 2: Difference-in-discontinuities
**Concern:** Union-minus-Confederate diff-in-disc would be more convincing than separate RDDs.

**Response:** We agree this is an attractive specification and have added discussion of it as a priority for the full-count analysis. With the 1% sample, the Confederate veteran sample (N=1,149) has only ~50 observations below age 62, making the diff-in-disc even more imprecise than the already-underpowered main estimate.

### Fatal Error 3: Overclaiming
**Concern:** "Passes every validity test" is too strong given density test rejection and literacy imbalance.

**Response:** We have revised this language throughout to accurately characterize which tests pass and which face challenges.

### Suggestion: 95% CIs in tables
**Response:** Added to main results table.

### Suggestion: Missing references
**Response:** Added Imbens & Lemieux (2008), Barreca et al. (2016), and Cattaneo, Frandsen, & Titiunik (2015).

---

## Reviewer 2 (Grok-4.1-Fast): MAJOR REVISION

### Assessment: "Gold-standard ID; internal validity airtight despite power limits"
**Response:** We appreciate this characterization and have maintained the strong design while being more precise about limitations.

### Suggestion: Full-count census
**Response:** We agree this is the priority next step and have added a quantitative power analysis showing that the full-count census (est. 150,000 Union veterans) would yield an MDE of approximately 2-3 percentage points, well within the range of plausible pension effects.

### Suggestion: Missing references
**Response:** Added suggested references where verifiable.

---

## Reviewer 3 (Gemini-3-Flash): MAJOR REVISION

### Core concern: "Cannot publish proof-of-concept with insignificant results when full-count data exists"
**Response:** We acknowledge this fundamental tension. The paper's contribution is design validation and historical documentation, positioning it for the full-count analysis that would deliver the definitive estimate. We have added a quantitative power analysis to make the "roadmap" concrete.

### Suggestion: Lee Bounds for literacy imbalance
**Response:** The literacy-controlled RDD (Table 4, Panel B) shows the estimate is essentially unchanged (0.166 vs 0.164), providing direct evidence that the literacy imbalance does not drive results. We discuss this as a stronger test than bounds, since it directly removes the confound.

### Suggestion: Birth record matching
**Response:** Unfortunately, linked birth records for Civil War-era veterans are not systematically available. The full-count census with its 100x sample would resolve the discrete running variable concern through sheer statistical power.
