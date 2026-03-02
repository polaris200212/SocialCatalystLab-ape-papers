# Exhibit Review — Gemini 3 Flash (Round 2)

**Role:** Visual exhibit advisor
**Model:** gemini-3-flash-preview (ai_studio)
**Paper:** paper.pdf
**Timestamp:** 2026-02-26T22:47:07.498669
**Route:** Direct Google API + PDF
**Tokens:** 19437 in / 1896 out
**Response SHA256:** 9ffe8c68ca4fd552

---

This review evaluates the exhibits of the provided paper against the standards of top-tier economics journals (AER, QJE, etc.).

# Exhibit-by-Exhibit Review

## Main Text Exhibits

### Table 1: "Summary Statistics by MGNREGA Phase"
**Page:** 9
- **Formatting:** Generally clean. However, the number of districts (top row) should be separated from the characteristics by a horizontal rule to distinguish sample size from variables.
- **Clarity:** Excellent. Comparison across phases and the "All" column is logical.
- **Storytelling:** Essential. It immediately validates the "backwardness" selection mechanism mentioned in the text.
- **Labeling:** Good. Table notes define the variables and the backwardness index clearly.
- **Recommendation:** **REVISE**
  - Add a horizontal rule below the "Districts" row.
  - Decimal-align all numeric values (e.g., population and rainfall have different digit counts).

### Table 2: "Effect of MGNREGA on District Nightlights"
**Page:** 13
- **Formatting:** Professional. Uses standard parenthetical SEs and significance stars.
- **Clarity:** Clear comparison of estimators (TWFE vs. CS-DiD vs. Sun-Abraham).
- **Storytelling:** This is the "hook" of the paper—showing how estimator choice flips the result.
- **Labeling:** Comprehensive. Explicitly states the dependent variable and clustering levels.
- **Recommendation:** **KEEP AS-IS**

### Figure 1: "Callaway-Sant’Anna Dynamic Event Study"
**Page:** 14
- **Formatting:** Clean "modern" look. Background gridlines are a bit heavy for QJE style; consider lightening or removing them.
- **Clarity:** The pre-trend violation is unmistakable. 
- **Storytelling:** Central to the paper’s argument regarding identification challenges.
- **Labeling:** Clear. 
- **Recommendation:** **REVISE**
  - Remove the background grey grid and use a white background.
  - The Y-axis label "ATT" is a bit cryptic; change to "Effect on Log Nightlights (ATT)".

### Figure 2: "Mean Log Nightlights by MGNREGA Cohort"
**Page:** 15
- **Formatting:** Colors are distinguishable, but the red/blue/green lines with markers look a bit like a standard Excel/ggplot output. 
- **Clarity:** Easy to see the levels difference between phases.
- **Storytelling:** Provides the "raw data" view that justifies the DiD approach.
- **Labeling:** The dashed vertical lines are excellent for indicating treatment timing.
- **Recommendation:** **REVISE**
  - Increase line weight for the cohort trajectories.
  - Move the legend inside the plot area (e.g., top left) to reduce whitespace.

### Figure 3: "Heterogeneous Effects by Baseline Characteristics"
**Page:** 16
- **Formatting:** Multi-panel plot is efficient.
- **Clarity:** The inverted-U in "Ag. Labor Share" is the key takeaway and is visible.
- **Storytelling:** This is the paper's primary contribution.
- **Labeling:** The X-axis labels (High, Low, Medium) are rotated 45 degrees; this is usually avoided in top journals if possible.
- **Recommendation:** **REVISE**
  - Reorder X-axis categories to a logical "Low, Medium, High" for all panels (currently "High, Low, Medium").
  - Un-rotate the labels by making the font smaller or the panels wider.

### Table 3: "Heterogeneous Effects by Baseline District Characteristics"
**Page:** 17
- **Formatting:** Good use of grouping by "Dimension."
- **Clarity:** Provides the precise coefficients for Figure 3.
- **Storytelling:** Redundant with Figure 3? In top journals, authors often choose one for the main text and move the other to the appendix.
- **Recommendation:** **MOVE TO APPENDIX** (Keep Figure 3 in main text as it is more visually striking).

### Table 4: "MGNREGA and Structural Transformation (Census 2001-2011)"
**Page:** 19
- **Formatting:** Standard cross-sectional regression format.
- **Clarity:** Good.
- **Storytelling:** Important for mechanism checking.
- **Labeling:** "Backward." in the controls row should be "Backwardness Index" for clarity.
- **Recommendation:** **KEEP AS-IS**

### Figure 4: "Census Mechanism: Structural Transformation by MGNREGA Phase"
**Page:** 20
- **Formatting:** Bar charts are generally discouraged in AER/QJE unless showing categorical distributions.
- **Clarity:** The message (no difference across phases) is clear.
- **Storytelling:** This is effectively a visual version of Table 4.
- **Labeling:** Y-axis "Change (2001-2011)" needs units (e.g., "Percentage Point Change").
- **Recommendation:** **REMOVE** (The results are already in Table 4; the bar charts don't add enough value to justify the space).

### Figure 5: "Sun-Abraham (2021) Interaction-Weighted Event Study"
**Page:** 21
- **Formatting:** Similar to Figure 1.
- **Clarity:** The contrast with Figure 1 (due to normalization) is explained well in the text.
- **Storytelling:** Essential for robustness.
- **Recommendation:** **KEEP AS-IS** (Or consolidate as Panel B of Figure 1).

### Table 5: "Robustness Checks"
**Page:** 22
- **Formatting:** Professional.
- **Clarity:** Logical progression of checks.
- **Storytelling:** Standard requirement.
- **Recommendation:** **KEEP AS-IS**

### Figure 6: "TWFE vs. Callaway-Sant’Anna Event Study Comparison"
**Page:** 23
- **Formatting:** Overlaid plots are high-impact.
- **Clarity:** Excellent visual evidence of why TWFE fails here.
- **Storytelling:** One of the most important methodological figures in the paper.
- **Recommendation:** **KEEP AS-IS** (Consider promoting this to Figure 2 to establish the methodological stakes early).

---

## Appendix Exhibits

### Figure 7: "Baseline Balance by MGNREGA Phase"
**Page:** 32
- **Formatting:** Boxplots are effective for balance.
- **Recommendation:** **KEEP AS-IS**

### Table 6: "CS-DiD Heterogeneity: Within-Tercile ATT Estimates"
**Page:** 34
- **Recommendation:** **KEEP AS-IS**

### Table 7: "Dose-Response: Effect of Years of MGNREGA Exposure"
**Page:** 34
- **Recommendation:** **KEEP AS-IS**

### Table 8: "Rambachan-Roth Sensitivity Bounds"
**Page:** 35
- **Recommendation:** **PROMOTE TO MAIN TEXT**
  - *Reasoning:* Given the severity of the pre-trend violation in Figure 1, the Rambachan-Roth bounds are a "front-line" defense for the paper's credibility, not just an appendix robustness check.

---

## Overall Assessment

- **Exhibit count:** 5 main tables, 6 main figures, 3 appendix tables, 1 appendix figure.
- **General quality:** High. The paper follows modern DiD diagnostic standards (CS, Sun-Abraham, Roth). Tables are cleaner than the figures.
- **Strongest exhibits:** Figure 6 (Comparison plot) and Table 2 (Main results).
- **Weakest exhibits:** Figure 4 (Redundant bar charts) and Figure 3 (Awkward X-axis ordering/rotation).
- **Missing exhibits:** A **Map of India** showing the Phase I, II, and III districts would be standard and very helpful for readers unfamiliar with Indian geography.

**Top 3 Improvements:**
1. **Consolidate and Promote:** Move the Rambachan-Roth table (Table 8) to the main text and consider making the comparison plot (Figure 6) a centerpiece of the results section.
2. **Fix Heterogeneity Visuals:** In Figure 3 and Table 3, reorder the terciles to "Low-Medium-High" to allow for easier intuitive parsing of trends.
3. **Clean Figure Aesthetics:** Transition all figures to a "clean" theme (white background, no gridlines, larger font sizes) to match the austere aesthetic of the AER/QJE.