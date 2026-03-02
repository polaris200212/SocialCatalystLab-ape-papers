# Reply to Reviewers — apep_0417 v3

## Scope of This Revision

This revision (v2 → v3) focused on **layout and presentation improvements**: splitting paired desert maps into individual figures, fixing LaTeX float placement from `[H]` to `[tbp]`, and adding per-specialty discussion text. The analysis, data, and empirical results are unchanged from v2.

---

## Reviewer 1 (GPT-5.2): MAJOR REVISION

### Concern 1: Treatment Timing/Mismeasurement
> "Using a constant 'eventual net disenrollment rate' switched on at start is not aligned with realized enrollment shocks."

**Response:** We acknowledge this concern as a valid limitation of our continuous-intensity design. The current specification uses each state's cumulative net disenrollment rate as a time-invariant intensity measure activated at the unwinding start date. As the reviewer notes, a time-varying quarterly cumulative measure would better capture the dynamic dose-response relationship. We defer this to a future substantive revision.

### Concern 2: T-MSIS Reporting Confounding
> "States that processed redeterminations aggressively plausibly changed encounter submission processes."

**Response:** This is an important identification threat that we discuss in Section 5.3. We acknowledge that we do not have direct measures of T-MSIS encounter completeness by state-quarter. The extensive robustness checks (region × quarter FEs, total claims outcome, placebo tests) provide indirect evidence against reporting-driven results, but we agree that direct data quality controls would strengthen the paper. Deferred to future revision.

### Concern 3: Functional Form with Extreme Zeros
> "log(count+1) may not be the best primary model; add PPML/binary outcomes."

**Response:** We report a desert indicator specification in Table 5 and discuss the binary extensive margin. We agree that PPML would be a valuable complement given the mass at zero. Deferred to future revision.

### Concern 4: Missing Cross-References (Fixed)
We corrected broken LaTeX references in the appendix Specialty-Specific Event Studies section (`eq:es` → `eq:eventstudy`, `fig:event_study` → `fig:eventstudy`, `tab:main_results` → `tab:main_by_spec`).

### Concern 5: "By Construction" Claim (Fixed)
We softened the claim about Behavioral Health and Dental panels being identical "by construction" to note that no NP/PA taxonomy codes map to these categories in our classification, and we verified this in the data.

---

## Reviewer 2 (Grok-4.1-Fast): MINOR REVISION

### Concern 1: Short Post-Period
> "Null could reflect lags."

**Response:** Acknowledged in Section 8.5 (Limitations). We note that 5-6 post-treatment quarters may be insufficient for supply-side adjustment. Future T-MSIS releases will enable longer windows.

### Concern 2: Suppression Bias
> "Low-volume marginal providers missed—attenuation toward null plausible."

**Response:** Addressed in Section 8.5 and the full-time threshold robustness check (≥36 claims/quarter in Table 5). We agree this remains a limitation of T-MSIS data.

### Concern 3: Add Callaway-Sant'Anna
**Response:** Deferred to future revision. The Sun-Abraham estimator already addresses cohort heterogeneity concerns.

### Concern 4: Surgery Trajectory (Fixed)
We corrected the text description of surgery trends to accurately reflect the +4.5% growth shown in Table 2, distinguishing it from the declines in psychiatry, OB-GYN, and dental.

---

## Reviewer 3 (Gemini-3-Flash): MINOR REVISION

### Concern 1: Practice Size Heterogeneity
> "Can you test if stickiness varies by practice size?"

**Response:** An interesting suggestion. T-MSIS billing NPI data does not directly identify practice size, but organizational NPI linkages could approximate this. Deferred to future revision.

### Concern 2: Travel Distance Deserts
> "Calculate travel distance to nearest NPI for desert residents."

**Response:** This would be a valuable extension of the atlas. Using NPPES practice-location addresses with county centroids, we could compute approximate travel distances. Deferred to future revision.

### Concern 3: Log Total Payments Outcome
**Response:** We test log total claims in Table 5 (row "Total claims (log) as outcome"). Log payments would provide additional insight into revenue effects. Deferred to future revision.

---

## Exhibit Review (Gemini Vision)

### Suggestion: Consolidate 6 Maps into One Multi-Panel Figure
**Response:** We intentionally split maps into individual figures in this revision to improve readability at the user's request. Individual maps with standalone legends are easier to examine at full resolution and allow text to flow between figures, eliminating the large white spaces that characterized v2.

### Suggestion: Move Table 2 and Table 3 to Appendix
**Response:** We retain these in the main text as they support the descriptive atlas contribution and are referenced extensively in the text.

---

## Prose Review (Gemini)

### Implemented Changes
1. **Punchier results lead**: Replaced generic "precisely estimated null" with vivid description emphasizing the massive shock and non-response
2. **Active voice**: Changed passive clustering description to active voice

### Deferred
- Opening hook rewrite (would change the established narrative arc)
- Data section restructuring (cosmetic, low priority for layout revision)
