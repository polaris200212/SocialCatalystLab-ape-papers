# Reply to Reviewers — apep_0469 v3

## Stage C Revision Summary

This revision addresses feedback from three external referees (GPT-5.2: Major Revision, Grok-4.1-Fast: Minor Revision, Gemini-3-Flash: Major Revision), plus exhibit and prose reviews.

---

## GPT-5.2 (Major Revision)

### 1. Decomposition lacks uncertainty (Must-fix)
**Response:** Added explicit statement that the -0.0011 residual "is not statistically distinguishable from zero at conventional levels" and that "the strongest interpretation is that compositional turnover was approximately neutral." Section 8.1 now presents the residual with appropriate hedging.

### 2. Scale back causal language around mobilization (Must-fix)
**Response:** Comprehensive revision throughout. Changed "effect" to "gradient" or "association" in multiple locations. Defined the estimand explicitly as intent-to-treat by 1940 state of residence. Added language acknowledging that equilibrium spillovers, measurement attenuation, and a genuinely diffuse shock cannot be distinguished with the data at hand. Mechanisms section now lists four non-exclusive explanations rather than a single interpretation.

### 3. Validate mobilization measure against ACL (Must-fix)
**Response:** Acknowledged as a limitation. The paper now explicitly notes the difference between CenSoc Army enlistment data and ACL's Selective Service induction data, and includes an appendix comparison table. A full replication using Selective Service data is beyond the scope of this revision but noted as important future work.

### 4. Spouse identity/linkage error analysis (Must-fix)
**Response:** Age-verified subsample robustness (97.3%) already reported in Table 11. The 86% figure is now contextualized in both the introduction and the appendix. Results are robust to restricting to confirmed matches.

### 5. Label husband-wife dynamics as reduced-form (High-value)
**Response:** Done. Section 5.4 now explicitly states: "Because ΔLF^husband is endogenous to shared household shocks, this coefficient does not identify a causal mechanism; it describes the net within-couple correlation conditional on controls." Introduction also updated to use "reduced-form within-couple correlation."

### 6. Migration/exposure (High-value)
**Response:** Non-mover subsample already reported. Treatment defined as ITT by 1940 state in the framework section.

### 7. Reconcile micro vs state-level (High-value)
**Response:** Section 8.3 discusses the difference between the state-level negative coefficient and micro-level null, attributing it to population differences and measurement issues.

---

## Grok-4.1-Fast (Minor Revision)

### 1. Report % age-verified in main text (Must-fix)
**Response:** The 86% figure is reported in the introduction and Section 2.3. Robustness to 97.3% verified subsample in Table 11.

### 2. Validate 1930 LFP definition (Must-fix)
**Response:** Section 4 (Pre-Trend Test) includes a paragraph explaining why the definitional shift does not bias the pre-trend test. The test concerns *changes*, not levels, and the shift would need to correlate with future mobilization to invalidate the test.

### 3. ACL reconciliation (High-value)
**Response:** Appendix A2 includes a comparison table. Section 8.3 discusses measure differences.

---

## Gemini-3-Flash (Major Revision)

### 1. Mobilization measure discrepancy vs ACL (Must-fix)
**Response:** Addressed in Section 8.3 and Appendix A2. The difference is attributed to the mobilization measure (CenSoc vs Selective Service), sample restrictions (stable married couples vs all women), and measurement period.

### 2. Define compositional residual more clearly (Must-fix)
**Response:** Section 5.6 now provides a clearer explanation of what enters the residual and notes it is not statistically distinguishable from zero.

### 3. Mobilization validation (High-value)
**Response:** Acknowledged as a limitation. The weak correlation with mover rates is presented transparently.

### 4. Occupational upgrading in manufacturing (High-value)
**Response:** Table 5 examines OCCSCORE changes. More granular industry analysis would require additional data construction beyond the current revision scope.

---

## Prose Review (Gemini)

### Applied improvements:
1. **Killed the list in Section 2.3** — converted enumerated steps to narrative paragraphs ("follow the husband, find the wife")
2. **Made the opening more vivid** — "We know the aggregate numbers changed, but we do not know if the women changed"
3. **Reduced "table narration"** in results sections — led with economic interpretation, not column references
4. **Added transitions** between Data and Framework sections
5. **Rewrote conclusion** as reframing, not summary — opens with the Rosie the Riveter narrative, ends with methodological implications

---

## Exhibit Review (Gemini)

Most exhibits rated KEEP AS-IS. No structural changes required.
