# Reply to Reviewers — Round 1

## Reviewer 1 (GPT-5-mini) — MAJOR REVISION

### Concern 1: Implementation details for CS-DiD
**Response:** Added explicit details: R `did` package v2.1.2, `est_method = "dr"`, analytic (not bootstrap) SEs, cohort-size weighting for ATT aggregation, district-level clustering.

### Concern 2: Goodman-Bacon decomposition
**Response:** Deferred to future revision. The CS-DiD is the primary estimator and TWFE is reported only as benchmark. The near-zero TWFE vs positive CS suggests negative weighting bias, consistent with heterogeneous treatment effects across cohorts.

### Concern 3: Power/MDE calculation
**Response:** Added back-of-envelope MDE discussion in Limitations: ~2.5% MDE at 80% power, which is right at the point estimate. Acknowledges analysis is borderline-powered at district level.

### Concern 4: Placebo outcomes
**Response:** Deferred to future revision. The transaction volume test partially serves this role (tests mechanism rather than placebo). Commercial property data not available at this geographic granularity.

### Concern 5: RI details
**Response:** Clarified procedure: cohort assignments permuted across districts, preserving overall timing distribution. Two-sided p-value reported.

### Concern 6: Parish-level analysis
**Response:** Acknowledged as most important extension. Requires geocoding Land Registry postcodes to parish boundaries — a major data effort beyond current scope.

## Reviewer 2 (Grok-4.1-Fast) — MINOR REVISION

### Assessment: "Top-journal caliber DiD execution"
**Response:** Thank you. No fatal issues identified.

### Suggestion: Missing references
**Response:** Noted for future revision. Key references (Goodman-Bacon, Sun & Abraham, Callaway & Sant'Anna) are already cited.

## Reviewer 3 (Gemini-3-Flash) — MINOR REVISION

### Concern 1: Missing reference (Been 2018)
**Response:** Noted for future revision.

### Concern 2: Geographic aggregation attenuation
**Response:** Extensively discussed in Limitations. Added MDE calculation showing district-level analysis is borderline-powered.

## Exhibit Review
- Table 3 "Mean of Dep. Var." row: Deferred to future revision
- Prose improvements: Applied where feasible

## Prose Review
- Strengthened results opening ("Neighbourhood plans do not make houses more expensive")
- Other prose suggestions noted for future revision
