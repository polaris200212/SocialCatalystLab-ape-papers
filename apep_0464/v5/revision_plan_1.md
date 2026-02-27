# Reply to Reviewers — apep_0464 v5

## Stage C Revision Summary

This revision addresses feedback from three external referees (GPT-5.2: MAJOR, Grok-4.1-Fast: MAJOR, Gemini-3-Flash: MINOR), one internal review, four advisor reviews, one exhibit review, and one prose review.

---

## Response to Major Concerns

### 1. Pre-Trend Violation (All Reviewers)

**Concern:** Joint F-test rejects parallel trends at p=0.03. Pre-treatment coefficients are statistically significant.

**Response:** We now foreground this limitation throughout the paper:
- The introduction explicitly notes the F-test rejection and references Rambachan-Roth sensitivity analysis
- Section 7.14 (HonestDiD) now presents a bracketing approach: the pre-trend-adjusted estimate (0.87 pp) as a lower bound and the baseline (1.35 pp) as an upper bound
- The event study figure notes already reported the F-test; we now discuss it more prominently in the text
- We soften causal language throughout (e.g., "permanently activating" → "consistent with... activating")

### 2. Horse-Race Collinearity (All Reviewers)

**Concern:** Column (D) sign flip on immigration coefficient. No VIFs reported.

**Response:**
- Added VIF reporting: Network Fuel × Network Immigration correlation is -0.39 (VIF=1.2, moderate). Network Immigration × Own Immigration correlation is 0.86 (VIF=3.9, severe).
- The text now explicitly states Column (C) is the preferred specification and Column (D) documents the collinearity limit
- We acknowledge the sign flip and explain it as severe multicollinearity between network and local immigration channels

### 3. Post-Treatment SCI (GPT, Grok)

**Concern:** SCI measured in 2024, 10 years after treatment.

**Response:** This concern was already the focus of Workstream 3 in the revision plan. The paper addresses it through:
- Migration proxy (ρ=0.66) replicates results
- Pre-determination test (opposite-sign pre-treatment coefficients)
- Measurement error bounds (classical EIV → estimate is lower bound)
- We have strengthened the language to acknowledge this remains a limitation

### 4. Causal Claim Calibration (GPT, Grok)

**Concern:** Paper overclaims causal identification given pre-trend and SCI issues.

**Response:** Softened throughout:
- Introduction no longer says "sharp structural break" without qualification
- Event study section acknowledges F-test rejection
- Discussion section frames results as "consistent with" rather than "proves"

---

## Response to Advisor Review Issues (Stage A)

### Fixed (Round 1 → Round 2, 3/4 PASS):
1. **Empty robustness table cells:** Filled Donut (Own=2.21, Net=1.64) and Migration Proxy (Net=1.45) rows
2. **Sign interpretation:** Corrected immigration coefficient interpretation throughout (negative = connected to low-immigration areas → higher RN)
3. **Post-GJ row mismatch:** Renamed to "GJ interaction (× Post-GJ)" with explanatory table note distinguishing from timing decomposition
4. **Missing inference p-values:** Added urbanization-block RI (p=0.31) and shift-level RI (p=0.02) to Table 6
5. **Missing shift-level RI in RI comparison table:** Added row for Borusyak et al. shift-level RI (p=0.02)

---

## Response to Exhibit Review (Gemini Vision)

1. **Table 3 column cutoff:** Reformatted horse-race table with `\small`, `@{}` column spacing, and proper label formatting
2. **Table 8 redundancy:** Shift-level RI now included in the RI comparison table; redundancy addressed
3. **Figure 5 horizontal line:** Noted for future revision (minor)

---

## Response to Prose Review (Gemini)

1. **Opening sentence:** Noted suggestion to start with GJ in the streets; retained current structure for now but will consider for next revision
2. **Coefficient translation:** Added bracketing language (lower bound 0.87, upper bound 1.35) for more intuitive interpretation
3. **Section headers:** Retained current headers; considered but did not implement narrative headers

---

## Summary of Changes

| Change | Location | Rationale |
|--------|----------|-----------|
| Acknowledge F-test p=0.03 in intro | Line 128 | Pre-trend transparency |
| Add VIFs to horse-race discussion | Section 5.2 | Collinearity documentation |
| Fix immigration sign interpretation | Abstract, Intro, Section 5.2 | Correct direction of effect |
| Fill robustness table rows 4, 7, 8 | Table 6 | Complete reporting |
| Add shift-level RI to comparison table | Table RI | Complete reporting |
| Bracket effect size [0.87, 1.35] | Section 7.14 | Honest uncertainty |
| Soften causal language | Throughout | Calibrated claims |
| Reformat horse-race table | Table 3 | Professional presentation |
| Clarify Post-GJ naming | Table 6 + notes | Cross-table consistency |
