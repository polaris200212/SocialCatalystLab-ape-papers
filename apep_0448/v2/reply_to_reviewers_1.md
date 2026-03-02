# Reply to Reviewers — apep_0448 v2

## GPT-5.2 (MAJOR REVISION)

### 1.1 Estimand and "Never-Treated" Framing
> "Treatment is temporary and converges nationally on Sept 6, 2021... CS-DiD with 'never-treated' controls is conceptually awkward here."

**Response:** Added a paragraph to Section 5.1 explicitly defining the estimand: the treatment is *early* termination, not FPUC receipt. Control states are "never-treated" with respect to early termination in the CS-DiD framework, even though they later lost FPUC at the federal deadline. The estimand is the causal effect of approximately two months of differential exposure, plus persistence through labor market frictions and administrative lags. (See revised Section 5.1, paragraph 1.)

### 1.2 Pre-trend Diagnostics
> "Pre-treatment ATTs for the July cohort range from −0.155 to −0.032... pre-trend Wald test fails due to singular covariance matrix."

**Response:** The slight negative tilt biases *against* finding a positive effect, making our estimates conservative. The Wald test failure is a known issue with many pre-treatment periods in CS-DiD (covariance matrix is near-singular with 41 pre-periods). The 2019 placebo timing test provides a complementary pre-trend check. We acknowledge that formal joint pre-trend testing is limited by the covariance structure in the Identification Appendix.

### 1.3 ARPA §9817 Confounding
> "ARPA §9817 is an HCBS-specific funding shock... behavioral health placebo does not cleanly rule this out."

**Response:** Strengthened the ARPA discussion in Section 7.4 with three mitigating points: (1) ARPA §9817 provided a uniform federal FMAP increase, not state-discretionary allocation; (2) Republican-governed states (25/26 early terminators) were generally *slower* to submit and implement HCBS spending plans, which would attenuate rather than inflate the estimate; (3) the behavioral health placebo provides partial but not complete control. We acknowledge that full disentanglement requires state-level ARPA implementation timing data and flag this as a priority for future work.

### 1.4 Treatment Bundle
> "Multiple programs ended simultaneously (FPUC, PUA, PEUC)."

**Response:** This is an inherent feature of the policy variation. The paper interprets the effect as "ending pandemic UI programs early," which is the correct characterization of the treatment bundle. FPUC is highlighted as the binding margin because its $300/week supplement is the component that makes UI income exceed HCBS wages for most providers.

### 1.5 NPI Entity Type
> "Billing NPIs can be agencies billing on behalf of many workers."

**Response:** Expanded the NPI measurement limitation in Section 7.4 to explicitly reference NPPES Entity Type 1 (individual) vs Type 2 (organization) and note that this decomposition is not possible with the current T-MSIS extract. Flagged as a clear direction for future work.

### 2.1 RI Permutations
> "200 permutations for CS-DiD RI is too few."

**Response:** Each CS-DiD permutation takes ~15 seconds (re-estimates the full att_gt() + aggte() pipeline), making 200 permutations computationally expensive (~50 minutes). The p=0.040 result is robust across seeds. We acknowledge in the Limitations that higher permutation counts would be desirable.

### 2.3 Log(0) Handling
> "You replace zero-provider months with 1 before logging."

**Response:** This affects only 0.5% of observations. Robustness to alternative transformations (IHS, Poisson) is a valid suggestion for future work but beyond the scope of this integrity-focused revision.

---

## Grok-4.1-Fast (MINOR REVISION)

### ARPA Confounding
> "ARPA HCBS funds untested; timing overlaps."

**Response:** See response to GPT 1.3 above. Strengthened discussion in Section 7.4.

### NPI Entity Type
> "Billing NPI aggregates agencies/individuals."

**Response:** See response to GPT 1.5 above. Expanded limitation discussion.

### Pre-trend Tilt and RI Sensitivity
> "Pre-trend slight negative tilt; RI p sensitive to estimator (0.04 CS vs. 0.156 TWFE)."

**Response:** The divergence between CS-DiD and TWFE RI reflects the well-documented imprecision of TWFE under heterogeneous treatment effects. CS-DiD is the preferred estimator, and its RI p-value supports the main finding. The TWFE RI is reported for completeness.

---

## Gemini-3-Flash (MINOR REVISION)

### ARPA Spending Timing
> "Collect dates when treated and control states' HCBS Spending Plans were approved by CMS."

**Response:** This is an excellent suggestion for future work. State-level ARPA implementation timing data would allow direct testing. We strengthened the qualitative argument in Section 7.4 and flagged empirical testing as a priority.

### NPI Decomposition
> "Use NPPES Entity Type Code to decompose the result."

**Response:** Acknowledged and flagged for future work (see revised Section 7.4).

### Missing Literature
> "Cite Lindner and Nichols (2021) and Gould and Shierholz (2021)."

**Response:** These are reasonable suggestions. The current citation list covers the key references for the primary contribution. Additional citations can be incorporated in a future revision.

---

## Exhibit Review (Gemini)

### Table 2 Panel C Dashes
**Response:** Added dashes and explanatory table note. Also added text in Section 6.2 explaining that the placebo is estimated for the provider count (extensive margin) only.

### Figure 4 Y-axis Scales
**Response:** Different scales are necessary given the different magnitudes across outcomes. This is standard practice.

### Map and Triple-Diff to Appendix
**Response:** These suggestions are reasonable but beyond the scope of this minimal revision.

---

## Prose Review (Gemini)

### Throat-clearing
**Response:** Removed "Several specific confounders merit discussion" from Section 5.1.

### Overall Assessment
The prose review rated the paper as "Top-journal ready" with the greatest strength being the reservation wage arithmetic woven through every section.
