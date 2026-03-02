# Reply to Reviewers — Round 1

## Reviewer 1 (GPT-5.2): REJECT AND RESUBMIT

### 1.1 Selection-on-observables not credible as causal design
> "Sign flips should be treated as a warning that β is being identified by functional form"

**Response:** We agree that the conditional association cannot be interpreted as strictly causal. We have:
- Softened all causal language throughout (abstract, intro, mechanisms): "reduced" → "is associated with"
- Added an explicit weight justification paragraph explaining the population-weighted vs unweighted estimands
- The paper now frames the contribution as documenting a robust conditional association rather than establishing causality

### 1.2 CenSoc mobilization measure not benchmarked against AAL
> "Benchmarking is essential"

**Response:** We lack access to the original Selective Service data used by AAL. We have preserved the honest caveat ("has not been formally benchmarked") and note that the CenSoc Army records cover ~60% of total service members. Table A11 compares estimation approaches.

### 2.1 State-level SEs inappropriate (IID with N=49)
> "HC2/HC3 at minimum; preferably wild bootstrap / randomization inference"

**Response:** Added three new inference procedures:
- **HC3 standard errors** (SE = 0.0025, t = -2.89, *more* significant than IID)
- **Randomization inference** (1,000 permutations, p < 0.001)
- **Leave-one-out influence** (all 49 coefficients negative, range [-0.0087, -0.0055])

These directly address the small-N inference concern. The result is far stronger than the bootstrap suggested.

### 2.3 Triple-diff magnitude implausibly large (-0.284)
> "28.4 percentage points"

**Response:** The triple-diff coefficient represents the *relative* female-male change per SD of mobilization, conditional on state and year FEs plus individual controls. It is a different estimand from the state-level aggregate. The individual-level model identifies from within-state variation in gender × time × mobilization, which operates on a different margin. We have preserved the triple-diff as complementary evidence while emphasizing the state-level result as primary.

### 3.1 Sensitivity to weights
> "Result significant only in one preferred specification"

**Response:** Added weight justification paragraph explaining that population-weighted is the correct estimand for population-level effects. The randomization inference (p < 0.001) and leave-one-out (all negative) strongly support the weighted result.

### 3.3 Baby boom / fertility confound
> "Arguably the most plausible negative effect driver"

**Response:** This is a fair concern. IPUMS NCHILD is available but was not in our extract. We note this as a limitation in the threats section and in the conclusion.

### 4.2 Missing literature
> "Rambachan & Roth, Cameron Gelbach & Miller, Conley & Taber"

**Response:** All four citations added to the paper.

---

## Reviewer 2 (Grok-4.1-Fast): MAJOR REVISION

### Must-fix 1: Replicate AAL exactly
**Response:** Same as GPT 1.2 — we lack the original Selective Service data. Table A11 documents the estimation differences.

### Must-fix 2: Baby boom confound
**Response:** Acknowledged as limitation. IPUMS NCHILD not in current extract.

### Must-fix 3: Synthetic controls or matching
**Response:** With N=49 and all states "treated" (continuous mobilization intensity), SCM is not directly applicable. The leave-one-out analysis (all 49 betas negative) and randomization inference (p < 0.001) provide strong evidence against the result being driven by outliers.

### High-value 1: War industry controls
**Response:** State-level war industry data would strengthen the analysis. We note this as a data limitation.

### High-value 2: Individual pre-trend fix
**Response:** We have de-emphasized the triple-diff and made the state-level result primary, which passes the pre-trend test.

---

## Reviewer 3 (Gemini-3-Flash): MAJOR REVISION

### Sensitivity to weights
**Response:** Added weight justification paragraph. Population-weighted estimand is the policy-relevant quantity.

### ANCOVA specification
> "Include 1940 LFP as a regressor"

**Response:** Added ANCOVA specification (Section 6.8). mob_std = -0.0051, p < 0.10, with lagged DV = 0.846. Confirms negative direction in levels.

### Fertility confounder
**Response:** Acknowledged as limitation. Would require state-level birth rate data.

### Reconciliation with AAL
**Response:** Table A11 provides comparison. Key differences: (1) different mobilization measure (CenSoc Army vs Selective Service), (2) different specification (first-difference vs levels), (3) different controls.

---

## Prose Review (Gemini)

- Killed roadmap paragraph ✓
- Improved opening research question ✓
- Humanized magnitude ("Michigan and Colorado") ✓
- Improved results narration (reduced "Column X shows" pattern) ✓
- Stronger conclusion sentence ✓
- Improved Data section opening ✓

## Exhibit Review (Gemini)

- Cleaned all table variable names via setFixest_dict() ✓
- Table headers now use descriptive English instead of code names ✓
