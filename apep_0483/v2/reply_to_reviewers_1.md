# Reply to Reviewers — Stage C Revision

## Response to GPT-5.2 (Reject & Resubmit)

### 1. Short panel / single pre-period
**Concern:** 4 years with 1 pre-period is thin for event study. Cannot credibly assess pre-trends.
**Response:** We relabeled the event study as "baseline exposure × year interactions" and added explicit language acknowledging the single pre-period limitation (Section 4.2, 8). We cannot extend the panel without substantial new data collection. We note this as a key limitation.

### 2. Bartik IV exclusion
**Concern:** Trend × share violates exclusion; industry composition predicts local prosperity.
**Response:** We added an IV falsification test (instrument on Attainment 8). **The test failed** — the instrument significantly predicts raw scores (p < 0.001). We now honestly report this failure in the IV results section, the Discussion, the Limitations, and the abstract. The IV is now presented as a "sign check" rather than a credible causal estimate. The OLS-IV discussion section was rewritten to foreground the exclusion violation.

### 3. Region×year FE
**Concern:** Need to control for region-specific shocks.
**Response:** Added region×year FE specification to robustness table. Result: β = 0.026 (vs 0.025 in main spec) — virtually identical. The null is robust to absorbing all region-specific time-varying shocks.

### 4. Academy DDD is not a DDD
**Concern:** Cross-sectional, confounded, not informative.
**Response:** We now explicitly describe it as a "descriptive association" rather than a causal mechanism test. The text acknowledges the cross-sectional nature prevents causal interpretation.

### 5. Causal claim calibration
**Concern:** Paper leans too heavily on causal interpretation.
**Response:** Abstract, conclusion, and policy implications substantially toned down. The conclusion now states: "We cannot definitively establish whether this pattern reflects a causal effect." Policy implications section explicitly notes what the design can and cannot establish.

---

## Response to Grok-4.1-Fast (Major Revision)

### 1. Extend pre-period
**Concern:** Merge 2016/17-2017/18 Progress 8 into event study.
**Response:** Not feasible within current revision scope — would require new data acquisition and panel construction. Acknowledged as limitation.

### 2. Test IV exclusion
**Concern:** Regress instrument on falsification outcomes.
**Response:** Done. Added Attainment 8 falsification test. The instrument fails (p < 0.001), and we report this honestly.

### 3. Quantify event study power
**Concern:** p=0.033 drives dynamics claim.
**Response:** We note the marginal significance and discuss alternative explanations (differential post-COVID recovery by region). The relabeled section makes clear this is suggestive, not definitive.

### 4. School panel for DDD
**Concern:** Use multi-year school-level data with school FE.
**Response:** Not feasible within current revision — would require school-level multi-year panel. Noted as important direction for future research.

### 5. Bound OLS-IV gap
**Concern:** Formal sensitivity tests for exclusion restriction.
**Response:** The falsification test effectively resolves this: the exclusion restriction is likely violated. We now present the IV as informative about sign but not magnitude.

---

## Response to Gemini-3-Flash (Major Revision)

### 1. IV magnitude and validity
**Concern:** IV estimate enormous; control for time-varying indicators.
**Response:** Added IV falsification test confirming exclusion concern. IV section completely rewritten to present as a sign check with honest discussion of exclusion failure.

### 2. Strengthen slow-moving channel
**Concern:** Vacancy data weak; need teacher experience/retention.
**Response:** Cannot add new mechanism data in this revision. Acknowledged as limitation.

### 3. Clarify London Effect
**Concern:** Re-run excluding London.
**Response:** Done. Main spec excluding London: β = 0.079 (p = 0.287), still null. Event study excluding London: 2023 coefficient = -0.233 (p = 0.001). Results survive excluding London. Reported in robustness table and text.

---

## Response to Exhibit Review

- Figures 5 (LOOR) and 6 (RI) kept in main text for completeness in this revision
- Added region×year FE and exclude-London rows to robustness summary table
- DDD interpretation updated to emphasize descriptive nature

## Response to Prose Review

- Fixed table narration in Results section ("Column X shows" → story-driven prose)
- Simplified contribution paragraph
- Toned down abstract and conclusion
