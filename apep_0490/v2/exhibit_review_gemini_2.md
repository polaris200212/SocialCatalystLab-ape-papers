# Exhibit Review — Gemini 3 Flash (Round 2)

**Role:** Visual exhibit advisor
**Model:** gemini-3-flash-preview (ai_studio)
**Paper:** paper.pdf
**Timestamp:** 2026-03-03T16:21:03.688005
**Route:** Direct Google API + PDF
**Tokens:** 19437 in / 1924 out
**Response SHA256:** f4be30bf11c97982

---

# Exhibit-by-Exhibit Review

## Main Text Exhibits

### Figure 1: "The arXiv Daily Submission and Announcement Cycle"
**Page:** 5
- **Formatting:** Clean and professional. The boxed format works for a timeline/institutional detail.
- **Clarity:** High. Clearly explains a complex schedule that is central to the identification strategy.
- **Storytelling:** Essential. It visualizes the "treatment" (the delay vs. position tradeoff) mentioned in the text.
- **Labeling:** Clear. Time zones and days are explicitly noted.
- **Recommendation:** **KEEP AS-IS**

### Table 1: "Summary Statistics"
**Page:** 11
- **Formatting:** Excellent. Uses standard booktabs style (no vertical lines). Numbers are clearly legible.
- **Clarity:** Good. Comparing the "Matched Sample" to the "RDD Sample" is logical for external validity.
- **Storytelling:** Important for showing that the RDD sample is a representative (if smaller) subset of the broader matched data.
- **Labeling:** Professional. Notes explain the sample restrictions and data sources.
- **Recommendation:** **REVISE**
  - Change "n Authors" to "Number of Authors" for a more formal look. 
  - Ensure all decimal points are aligned vertically (currently "968.25" and "1,845" disrupt the column flow).
  - Add a comma for thousands in "Abstract length" (e.g., 1,000) for consistency.

### Figure 2: "First Stage: Listing Position Discontinuity at the 14:00 ET Cutoff"
**Page:** 14
- **Formatting:** High quality. Good use of binned means and confidence intervals.
- **Clarity:** Immediate. The "10-second rule" is met; the jump is undeniable.
- **Storytelling:** The strongest piece of evidence for the first stage.
- **Labeling:** Y-axis is clearly labeled with percentiles. The red dashed line for the cutoff is standard.
- **Recommendation:** **KEEP AS-IS**

### Figure 3: "Submission Density Around the 14:00 ET Cutoff"
**Page:** 15
- **Formatting:** Standard histogram.
- **Clarity:** Slightly cluttered due to the 2-minute bins.
- **Storytelling:** Necessary to address manipulation/strategic timing.
- **Labeling:** Good. Descriptive subtitle helps.
- **Recommendation:** **MOVE TO APPENDIX**
  - While important for validity, the McCrary test result is more formal. The main text flow would be improved by moving this raw density plot to the appendix and keeping only the formal result in the text.

### Table 2: "Covariate Balance at the Cutoff"
**Page:** 16
- **Formatting:** Consistent with Table 1.
- **Clarity:** High. 
- **Storytelling:** Proves the "as-good-as-random" assignment.
- **Labeling:** Note on Bonferroni correction is excellent.
- **Recommendation:** **REVISE**
  - Standardize covariate names (e.g., change "n Authors" to "Number of Authors", "Cs AI" to "cs.AI indicator"). 
  - The "Eff. N" column should be right-aligned or decimal-aligned.

### Table 3: "The Visibility Premium: RDD Estimates at the arXiv Daily Cutoff"
**Page:** 16
- **Formatting:** Professional. Standard error parentheses are correct.
- **Clarity:** Very high.
- **Storytelling:** This is the "money table" of the paper. It shows the null result across different horizons.
- **Labeling:** "Log(1y cites+1)" is clear. 
- **Recommendation:** **REVISE**
  - Add a row for "Mean of Dependent Variable" at the bottom of the table. In a paper about null results, knowing the baseline citation count is critical for the reader to interpret the "Min. detectable effect."

### Figure 4: "RDD Plot: Three-Year Citations at the arXiv Daily Cutoff"
**Page:** 18
- **Formatting:** Consistent with Figure 2.
- **Clarity:** High. Shows a flat relationship through the cutoff.
- **Storytelling:** Essential visual counterpart to the main regression result.
- **Labeling:** Clearly labeled.
- **Recommendation:** **KEEP AS-IS**

### Figure 5: "Bandwidth Sensitivity: Estimates Stable Across Choices"
**Page:** 19
- **Formatting:** Clean.
- **Clarity:** Good. The horizontal dashed line at zero is helpful.
- **Storytelling:** Robustness check.
- **Labeling:** X-axis units (minutes) are clear.
- **Recommendation:** **MOVE TO APPENDIX**
  - This is a standard robustness check. Table 4 already contains these numbers. Having both in the main text is redundant.

### Table 4: "Robustness: Bandwidth Sensitivity and Donut RDD"
**Page:** 20
- **Formatting:** Good use of Panels A and B.
- **Clarity:** Logic is sound.
- **Storytelling:** Addresses the most likely critiques (bandwidth choice and strategic timing).
- **Labeling:** Significant stars and notes are well-handled.
- **Recommendation:** **KEEP AS-IS**

### Figure 6: "Placebo Cutoffs: No Systematic Pattern at Alternative Times"
**Page:** 21
- **Formatting:** High professional standard. The use of a different color (red triangle) for the true cutoff is a great visual cue.
- **Clarity:** High.
- **Storytelling:** Powerfully rules out "time-of-day" effects.
- **Labeling:** Good.
- **Recommendation:** **KEEP AS-IS**

---

## Appendix Exhibits

### Figure 7: "McCrary Density Test at the 14:00 ET Cutoff"
**Page:** 32
- **Recommendation:** **KEEP AS-IS** (Stronger than the raw histogram in Fig 3).

### Figure 8: "Donut RDD: Excluding Papers Near the Cutoff"
**Page:** 33
- **Recommendation:** **REMOVE**
  - Redundant. These estimates are already reported in Table 4, Panel B. A figure doesn't add new information here.

### Figure 9: "Formal RDD Plot: rdplot Visualization"
**Page:** 34
- **Recommendation:** **REVISE**
  - The y-axis scaling and fourth-order polynomial make the data look "wigglier" than it is. Figure 4 in the main text is actually a better visualization. Either remove this or use a lower-order polynomial to match the main text's local linear approach.

### Table 5: "Heterogeneity by arXiv Category"
**Page:** 34
- **Recommendation:** **KEEP AS-IS**

### Figure 10: "Covariate Balance at the Cutoff"
**Page:** 35
- **Recommendation:** **PROMOTE TO MAIN TEXT**
  - This coefficient plot is a much more modern and "at-a-glance" way to show balance than Table 2. I recommend replacing Table 2 with this figure in the main text to save space and improve visual flow.

---

## Overall Assessment

- **Exhibit count:** 5 main tables, 5 main figures, 1 appendix table, 4 appendix figures.
- **General quality:** Extremely high. These exhibits follow the "AER style" closely: clean white backgrounds, no gridlines, serif fonts, and detailed notes.
- **Strongest exhibits:** Figure 2 (First Stage) and Figure 6 (Placebo tests).
- **Weakest exhibits:** Figure 3 (Raw density) and Figure 8 (Redundant donut plot).
- **Missing exhibits:** A **"Coefficient Plot" for the main results** (Table 3) would be a great addition to the main text to visualize the point estimates and CIs across the 1, 3, 5, and Total citation horizons simultaneously.

### Top 3 Improvements:
1. **Consolidate Robustness:** Move Figure 5 (Bandwidth) and Figure 3 (Density) to the appendix to tighten the main text.
2. **Visualize Balance:** Replace Table 2 with Figure 10 in the main text. Top journals increasingly prefer "eye-balling" balance via coefficient plots over large tables of p-values.
3. **Contextualize the Null:** Add the "Dependent Variable Mean" to Table 3. Without it, the reader cannot easily judge if the "Min. detectable effect" of 1.48 log points is large or small relative to the typical paper's citations.