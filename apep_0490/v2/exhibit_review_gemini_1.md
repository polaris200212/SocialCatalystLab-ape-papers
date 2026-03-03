# Exhibit Review — Gemini 3 Flash (Round 1)

**Role:** Visual exhibit advisor
**Model:** gemini-3-flash-preview (ai_studio)
**Paper:** paper.pdf
**Timestamp:** 2026-03-03T14:28:48.065717
**Route:** Direct Google API + PDF
**Tokens:** 23077 in / 2406 out
**Response SHA256:** b51ef425a5367207

---

# Exhibit-by-Exhibit Review

## Main Text Exhibits

### Figure 1: "The arXiv Daily Submission and Announcement Cycle"
**Page:** 6
- **Formatting:** Clean but looks more like a text box than a formal figure. The font size is slightly large relative to the body text.
- **Clarity:** High. Effectively communicates the complex timing logic which is central to the RDD.
- **Storytelling:** Essential. It justifies the running variable and explains why 14:00 is the discontinuity point.
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS**

### Table 1: "Summary Statistics"
**Page:** 13
- **Formatting:** Professional. Uses standard booktabs-style horizontal lines. Decimal alignment is generally good, though "NaN" and "NA" in the industry row break the flow.
- **Clarity:** Good. The comparison between the full matched sample and the RDD subsample is logical.
- **Storytelling:** Vital for establishing that the 289 papers in the RDD window are representative of the broader sample.
- **Labeling:** Notes are comprehensive.
- **Recommendation:** **REVISE**
  - Replace "NaN/NA" in the industry row with "0.00" or em-dashes (—). "NaN" looks like a coding error rather than a statistical result.
  - The variable "Abstract length (chars)" is a bit raw; consider converting to "word count" for better intuition.

### Figure 2: "First Stage: Listing Position Discontinuity at the 14:00 ET Cutoff"
**Page:** 16
- **Formatting:** High quality. Professional ggplot-style theme with clear confidence intervals.
- **Clarity:** Excellent. The 10-second test is passed: the viewer immediately see the massive drop in percentile (improvement in position).
- **Storytelling:** This is the "First Stage" and is perhaps the strongest visual in the paper.
- **Labeling:** Y-axis clearly marked as percentiles. Title is descriptive.
- **Recommendation:** **KEEP AS-IS**

### Figure 3: "Submission Density Around the 14:00 ET Cutoff"
**Page:** 17
- **Formatting:** Good use of a histogram. 
- **Clarity:** The "Before/After" labels within the plot area are helpful.
- **Storytelling:** Crucial for the validity of the RDD. It honestly shows the spike just after the cutoff, which motivates the "Donut" robustness checks.
- **Labeling:** Axis labels are present and clear.
- **Recommendation:** **REVISE**
  - Consider adding the McCrary test p-value directly onto the figure space to immediately reassure the reader.

### Table 2: "Covariate Balance at the Cutoff"
**Page:** 18
- **Formatting:** Standard journal format.
- **Clarity:** Column logic (Estimate, SE, p, BW, N) is standard and easy to read.
- **Storytelling:** Critical for identification. Shows that quality-correlated variables don't jump.
- **Labeling:** Notes are sufficient.
- **Recommendation:** **REVISE**
  - Add a "Mean" column for the control group so readers can judge the magnitude of the "RDD Estimate." A -0.11 jump is meaningless without knowing the mean of that category.

### Table 3: "The Visibility Premium: RDD Estimates at the arXiv Daily Cutoff"
**Page:** 18
- **Formatting:** Excellent. Grouping columns by citation horizon (1y, 3y, 5y, Total) is logical.
- **Clarity:** Clear, though the "Min. detectable effect" row is a bit unusual for a main table (usually in notes).
- **Storytelling:** The core result. It shows the "null" clearly.
- **Labeling:** Standard errors in parentheses, significance stars defined.
- **Recommendation:** **REVISE**
  - Consolidate: This table has very few rows. Consider adding the "Industry Adoption" results (once available) as Panel B to this table to make it a one-stop-shop for main results.

### Figure 4: "RDD Plot: Three-Year Citations at the arXiv Daily Cutoff"
**Page:** 20
- **Formatting:** Consistent with Figure 2.
- **Clarity:** Good. Shows the lack of a jump.
- **Storytelling:** The primary visualization of the null result.
- **Labeling:** Clear y-axis label.
- **Recommendation:** **KEEP AS-IS**

### Figure 5: "Bandwidth Sensitivity: Estimates Stable Across Choices"
**Page:** 21
- **Formatting:** Standard "coefficient plot" style.
- **Clarity:** High. Shows the estimate is not a result of "p-hacking" the bandwidth.
- **Storytelling:** Strong robustness evidence.
- **Labeling:** Good.
- **Recommendation:** **MOVE TO APPENDIX**
  - This is a standard robustness check. In top journals, these often live in the appendix to keep the main text narrative focused on the findings.

### Table 4: "Robustness: Bandwidth Sensitivity and Donut RDD"
**Page:** 22
- **Formatting:** Good use of Panels A and B.
- **Clarity:** Clear comparison.
- **Storytelling:** Redundant with Figure 5 but provides the exact numbers.
- **Labeling:** Clear.
- **Recommendation:** **REVISE**
  - Since Figure 5 shows Bandwidth sensitivity, this table could be shortened or moved entirely to the appendix. If kept, combine with Table 3 as a "Robustness" panel.

### Figure 6: "Placebo Cutoffs: No Systematic Pattern at Alternative Times"
**Page:** 23
- **Formatting:** Clean. The red triangle effectively highlights the "real" estimate.
- **Clarity:** Excellent.
- **Storytelling:** Reassuring evidence that the result isn't a fluke of the time of day.
- **Labeling:** Clear.
- **Recommendation:** **MOVE TO APPENDIX**
  - Similar to Figure 5, this is a "validity check" that is best suited for an Online Appendix in a QJE/AER submission.

### Table 5: "Industry Adoption: RDD Estimates at the arXiv Daily Cutoff"
**Page:** 24
- **Formatting:** Placeholder.
- **Clarity:** N/A (Data pending).
- **Storytelling:** Potential for a very strong second half of the paper.
- **Labeling:** N/A.
- **Recommendation:** **REVISE**
  - **CRITICAL:** Fill with data. If results are null, consider merging with Table 3 as "Panel B: Industry Outcomes" to emphasize the uniformity of the null across sectors.

### Figures 7, 8, & 9: (Industry and Multi-Outcome Plots)
**Pages:** 25-28
- **Recommendation:** **REVISE**
  - Figure 9 (The Multi-Outcome coefficient plot) should be the **Main Text** centerpiece for the industry section, while Figures 7 and 8 can be moved to the appendix. Figure 9 tells the "whole story" in one glance.

---

## Appendix Exhibits

### Figure 10: "McCrary Density Test at the 14:00 ET Cutoff"
**Page:** 39
- **Formatting:** Standard `rddensity` output.
- **Clarity:** A bit cluttered with the grey shading and bin bars.
- **Storytelling:** Validates Figure 3.
- **Recommendation:** **KEEP AS-IS** (Standard for appendix).

### Figure 11: "Donut RDD: Excluding Papers Near the Cutoff"
**Page:** 40
- **Formatting:** Consistent.
- **Clarity:** Clear.
- **Storytelling:** Robustness.
- **Recommendation:** **REMOVE**
  - This information is already contained in Table 4, Panel B. Having both a table and a figure for a 3-point donut test is overkill.

### Figure 12: "Formal RDD Plot: rdplot Visualization"
**Page:** 41
- **Formatting:** Raw `rdplot` output from R.
- **Clarity:** The 4th-order polynomial (red line) is wiggly and potentially misleading/distracting compared to the loess in Figure 4.
- **Storytelling:** Technical validation.
- **Recommendation:** **KEEP AS-IS** (Suited for appendix).

### Table 6: "Heterogeneity by arXiv Category"
**Page:** 41
- **Formatting:** Professional.
- **Clarity:** Good.
- **Storytelling:** Important to show the effect isn't driven by one specific sub-field.
- **Labeling:** Small sample sizes (Eff. N = 17) are correctly noted.
- **Recommendation:** **KEEP AS-IS**

### Figure 13: "Covariate Balance at the Cutoff"
**Page:** 42
- **Formatting:** Horizontal coefficient plot.
- **Clarity:** Very high.
- **Storytelling:** Visual version of Table 2.
- **Recommendation:** **PROMOTE TO MAIN TEXT**
  - Top journals love "balancing plots." It is much easier to see that all dots are on the zero line than to read Table 2. Replace Table 2 with this figure in the main text.

---

## Overall Assessment

- **Exhibit count:** 5 Main Tables, 9 Main Figures (including placeholders), 1 Appendix Table, 4 Appendix Figures.
- **General quality:** High. The RDD visualizations are standard and professional. The paper suffers from "placeholder syndrome" in the second half.
- **Strongest exhibits:** Figure 2 (First Stage) and Figure 13 (Covariate Plot).
- **Weakest exhibits:** Table 5 and Figures 7-9 (due to missing data). Figure 11 is redundant.
- **Missing exhibits:** 
    1. **A binned scatter plot of the "descriptive" relationship.** The paper argues the correlation is selection, not causal. Showing the OLS slope (Position vs Citations) in a figure would provide the "stylized fact" that the RDD then debunks.
- **Top 3 improvements:**
  1. **Consolidate Results:** Merge the academic citation results (Table 3) and industry results (Table 5) into a single, high-impact "Main Results" table with Panels A and B.
  2. **Prioritize Visuals for Identification:** Replace the text-heavy Table 2 (Covariate Balance) with Figure 13 in the main text.
  3. **Streamline Robustness:** Move the Bandwidth Sensitivity (Fig 5) and Placebo Cutoffs (Fig 6) to the Appendix to improve the narrative flow of the main text.