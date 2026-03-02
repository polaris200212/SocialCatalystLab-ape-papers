# Exhibit Review — Gemini 3 Flash (Round 1)

**Role:** Visual exhibit advisor
**Model:** gemini-3-flash-preview (ai_studio)
**Paper:** paper.pdf
**Timestamp:** 2026-02-11T13:51:34.254231
**Route:** Direct Google API + PDF
**Tokens:** 20477 in / 1980 out
**Response SHA256:** c17e170a7cd40a4b

---

# Exhibit-by-Exhibit Review

## Main Text Exhibits

### Table 1: "Summary Statistics: Education Sector (NAICS 61) by Treatment Status"
**Page:** 8
- **Formatting:** Generally professional. Standard errors are in parentheses below means. Column headers are clearly grouped.
- **Clarity:** Clear, but the high standard deviations relative to the means for "Employment" suggest that the data are not being logged here, which makes the raw means hard to compare across groups of different sizes.
- **Storytelling:** Essential. It establishes that treated and control states have similar churn rates (separation/hire) but differ in scale and earnings level.
- **Labeling:** Good. Includes N for states and N for state-quarters. Notes define the data source and variables.
- **Recommendation:** **REVISE**
  - Add a row for "Log Employment" or weight the raw employment means to make them more representative of a "typical" state in each group. 
  - Decimal-align the numbers in the columns to improve readability.

### Figure 1: "Treatment Rollout: Adoption of Educational Content Restriction Laws, 2021–2023"
**Page:** 13
- **Formatting:** Clean, modern "dot plot" style. Gridlines are subtle.
- **Clarity:** Very high. It is much easier to read than a standard map for understanding *timing*.
- **Storytelling:** Excellent. It visualizes the "staggered" nature of the treatment, which justifies the use of Callaway-Sant'Anna.
- **Labeling:** Clear legend for stringency. Axis labels are appropriate.
- **Recommendation:** **KEEP AS-IS**

### Figure 2: "Raw Trends in Log Education Employment: Treated vs. Never-Treated States"
**Page:** 15
- **Formatting:** Two-panel vertical layout. The use of an index ($2020Q4=100$) in Panel A is a standard and effective way to show parallel trends.
- **Clarity:** High. The seasonality in Panel B (Separation Rate) is very obvious, which helps the reader understand the data frequency.
- **Storytelling:** Vital for "selling" the DiD identification. It shows the COVID shock affected both groups identically.
- **Labeling:** Notes mention "Shaded bands show ±1 standard deviation," but those bands are virtually invisible or missing in the rendering. 
- **Recommendation:** **REVISE**
  - Increase the transparency/visibility of the shaded confidence bands.
  - In Panel B, the y-axis is "Separation Rate." Clarify if this is quarterly.

### Table 2: "Effect of Educational Content Restriction Laws on Education Sector Labor Markets"
**Page:** 17
- **Formatting:** Professional AER/QJE style. No vertical lines. Proper grouping by Panel (A, B, C).
- **Clarity:** Excellent. The contrast between the null in Panel A and the spurious significance in Panel B is the "hero" finding of the paper.
- **Storytelling:** This is the central exhibit of the paper. It groups all primary outcomes and estimators logically.
- **Labeling:** Significance stars are defined. Standard errors are noted as being in parentheses.
- **Recommendation:** **KEEP AS-IS**

### Figure 3: "Event Study: Callaway-Sant’Anna Dynamic ATT Estimates"
**Page:** 19
- **Formatting:** Standard 2x2 grid. The zero-lines (horizontal and vertical) are appropriately emphasized.
- **Clarity:** Good. The color-coding (Blue, Orange, Green, Pink) helps distinguish the four outcomes.
- **Storytelling:** Confirms the lack of pre-trends and the persistent null effect. 
- **Labeling:** Y-axis labeled "ATT" is a bit generic; better to label it with the units of the outcome (e.g., "$\Delta$ Log Employment").
- **Recommendation:** **REVISE**
  - Update y-axis labels to be more descriptive (e.g., "Effect on Log Emp").
  - Consider combining the legend or ensuring titles (A, B, C, D) are large enough.

### Table 3: "Robustness: Alternative Specifications for Log Employment"
**Page:** 20
- **Formatting:** Clean list of specifications.
- **Clarity:** High. Including the 95% CI and p-value alongside the estimate makes the null result "honest" and transparent.
- **Storytelling:** Supports the main finding by showing the result isn't sensitive to control group choice or estimator choice (except for the biased TWFE).
- **Labeling:** Good. Notes explain the abbreviations (CS, TWFE).
- **Recommendation:** **KEEP AS-IS**

### Figure 4: "Heterogeneity by Law Stringency: Event Study Estimates for Log Employment"
**Page:** 21
- **Formatting:** Overlapping event studies.
- **Clarity:** A bit cluttered. The confidence intervals for the two groups overlap significantly, making it "busy."
- **Storytelling:** Important for the "regulatory chill" argument—shows that even "Strong" laws had no effect.
- **Labeling:** Legend is clear.
- **Recommendation:** **REVISE**
  - Use "hollow" points for one group or slightly offset the x-axis points (jitter) so the error bars don't land exactly on top of each other.

### Table 4: "Placebo Tests: Effect of Education Content Laws on Non-Education Sectors"
**Page:** 22
- **Formatting:** Standard table.
- **Clarity:** Clear.
- **Storytelling:** Crucial for internal validity.
- **Labeling:** Notes are comprehensive.
- **Recommendation:** **KEEP AS-IS**

### Figure 5: "Placebo Event Study: Education vs. Non-Education Sectors"
**Page:** 23
- **Formatting:** Multiple lines on one plot.
- **Clarity:** Low. With four sectors plus confidence intervals, this is very "spaghetti-like."
- **Storytelling:** Redundant with Table 4.
- **Recommendation:** **MOVE TO APPENDIX**
  - The table carries the message more cleanly for the main text.

### Figure 6: "Randomization Inference: Permutation Distribution of TWFE Coefficient"
**Page:** 24
- **Formatting:** Standard histogram with a vertical line for the observed value.
- **Clarity:** Very high.
- **Storytelling:** Directly addresses the "significance" of the TWFE result, showing it's a systematic bias, not a fluke.
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS**

### Table 5: "Educational Content Restriction Laws: Treatment Coding"
**Page:** 25
- **Formatting:** Long reference table.
- **Clarity:** High.
- **Storytelling:** Provides the transparency needed for others to replicate the work.
- **Labeling:** Well-documented.
- **Recommendation:** **MOVE TO APPENDIX**
  - It takes up a full page in the "Results" section but is actually a data description. Moving it would improve the flow from "Robustness" to "Discussion."

---

## Appendix Exhibits
*(Note: The PDF provided contains text descriptions of Appendix sections but no separate Appendix tables/figures beyond those listed above. If the author intended the above to be the full set, the assessment follows.)*

---

## Overall Assessment

- **Exhibit count:** 5 main tables, 6 main figures, 0 appendix tables, 0 appendix figures.
- **General quality:** Extremely high. The paper follows the "modern DiD" template perfectly. Figures are created with a consistent aesthetic (likely `ggplot2`).
- **Strongest exhibits:** Table 2 (The comparison of estimators) and Figure 1 (The dot-plot rollout).
- **Weakest exhibits:** Figure 5 (Spaghetti plot of placebos) and Table 1 (Raw employment means).
- **Missing exhibits:** 
  1. **A summary of the "Compositional Finding" (Female Share):** The abstract and text highlight a 0.7pp increase in female share, but this is never shown in a table or figure. It deserves its own small table or a row in Table 2.
  2. **A map:** While Figure 1 is better for timing, a simple US map shaded by "Treated vs. Control" is a standard "sanity check" for geographic clustering.

**Top 3 Improvements:**
1. **Create an exhibit for the Female Share result.** This is the only "positive" finding in the paper; leaving it as text-only undersells it.
2. **Declutter the "spaghetti" plots.** Specifically, move Figure 5 to the appendix and use "jittering" or facets for Figure 4 to make the confidence intervals readable.
3. **Shift Table 5 to the Appendix.** The main text should flow from the Placebo/Randomization results directly into the Discussion. A full-page list of bills disrupts the narrative momentum.