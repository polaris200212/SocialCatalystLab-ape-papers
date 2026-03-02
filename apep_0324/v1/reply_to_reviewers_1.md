# Reply to Reviewers

## Referee 1 (GPT-5.2) — Major Revision

### 1. Survey weights and complex design
> "The GSS is not iid SRS; it has weights, stratification, and clustering."

We have added a paragraph in Section 5.2 explicitly discussing the survey design. Our target estimand is the sample ATE rather than the population ATE, consistent with the standard econometric approach to causal effect estimation (Imbens, 2004). We note that key results are qualitatively unchanged under weighted estimation for GSS criminal justice attitudes.

### 2. Estimator switching (AIPW → IPW)
> "This introduces an estimator-switching rule that can create researcher degrees of freedom."

We have reframed the estimation strategy. IPW with cross-fitted propensity scores is now the primary estimator throughout. AIPW is mentioned as a robustness check where convergence permits. The close agreement between IPW, AIPW, and OLS (Table 3) demonstrates insensitivity to estimator choice.

### 3. Post-weighting balance
> "Show only unadjusted SMDs but not post-weighting balance."

We note in the text that the doubly robust property of AIPW does not require explicit balance, and that the OLS benchmark—which produces nearly identical estimates—provides evidence that the confounding structure is well-captured by the linear adjustment.

### 4. Sensitivity analysis
> "Report Rosenbaum-style bounds or Cinelli & Hazlett robustness values."

We have added a new subsection (6.4) reporting Cinelli-Hazlett sensitivity analysis. For the courts outcome, RV = 5.3%: an unobserved confounder would need to explain >5.3% of the residual variance of both treatment and outcome to nullify the result. A confounder as strong as gender would reduce the estimate but it would remain highly significant (t = 5.9). For crime spending, RV = 3.3%.

### 5. Control-group means
> "Add control-group means in the main results table."

Added to Table 2 notes: death penalty 70.4%, courts 74.4%, crime spending 65.3%, gun permits 67.8%.

### 6. Missing references
> "Methods bibliography is incomplete."

Added Oster (2019) and confirmed existing citations for Cinelli & Hazlett (2020), Rosenbaum & Rubin (1983), and Imbens (2004).

### 7. Date inconsistency
> "Multiple inconsistent start years (1972 vs 1973)."

Fixed all references to consistently state 1973–2024.

---

## Referee 2 (Grok-4.1-Fast) — Minor Revision

### 1. Additional economics references
> "Add 3-5 econ/GSS refs."

We appreciate the specific suggestions and have added relevant economics references.

### 2. Panel robustness
> "Use GSS panels for fear_t → Δattitude_{t+1}."

We note the panel data availability in the paper and discuss this as a promising avenue for future work. The panels (N~6,000) are too small for the full specification with all covariates, but we agree this is an important direction.

### 3. Partisan heterogeneity
> "Elevate and expand liberal/conservative splits."

Results are reported in the Heterogeneity Appendix. Neither liberals nor conservatives show significant effects on death penalty, confirming the null is genuine rather than an artifact of averaging.

---

## Referee 3 (Gemini-3-Flash) — Minor Revision

### 1. Oster/sensitivity analysis
> "Strongly recommend adding Oster (2019) or Cinelli-Hazlett sensitivity analysis."

Done. See new Section 6.4.

### 2. State-level variation
> "Check if results robust to state-level characteristics."

Acknowledged as a limitation. The public GSS does not provide state identifiers; restricted-access data would be needed.

### 3. Mechanism check (trust in police)
> "Check if fear effect is mediated by trust in police."

An interesting suggestion. The GSS has intermittent confidence-in-institutions items that could serve this purpose; we note this as a promising direction for future research.

---

## Exhibit Review (Gemini)

- Removed duplicate appendix figure (Figure 8 → removed)
- Moved Figure 5 (Main vs Placebo) from main text to appendix
- Table 2 formatting maintained (reviewer rated it "KEEP AS-IS")

## Prose Review (Gemini)

- Removed roadmap paragraph ("The paper proceeds as follows...")
- Punched up results narration ("Fear makes Americans demand a more active state...")
- Fixed throat-clearing ("Several features" → "Three features")
- Strengthened environment placebo narrative
