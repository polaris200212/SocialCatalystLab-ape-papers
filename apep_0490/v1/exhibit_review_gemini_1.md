# Exhibit Review — Gemini 3 Flash (Round 1)

**Role:** Visual exhibit advisor
**Model:** gemini-3-flash-preview (ai_studio)
**Paper:** paper.pdf
**Timestamp:** 2026-03-03T12:53:59.493941
**Route:** Direct Google API + PDF
**Tokens:** 18917 in / 2192 out
**Response SHA256:** 11c79aa81a6ac65f

---

This advisor review evaluates the visual exhibits of the paper "The Price of Position: Does Listing Order Shape the Diffusion of AI Research?" against the standards of top-tier economics journals (AER, QJE, etc.).

# Exhibit-by-Exhibit Review

## Main Text Exhibits

### Figure 1: "The arXiv Daily Submission and Announcement Cycle"
**Page:** 5
- **Formatting:** Non-standard for a top journal. It is a boxed text list rather than a schematic or flow diagram.
- **Clarity:** The text is clear, but it requires the reader to mentally map the timeline.
- **Storytelling:** Essential for understanding the "treatment," but visually underwhelming.
- **Labeling:** Good descriptive title.
- **Recommendation:** **REVISE**
  - Transform this into a visual horizontal timeline. Use arrows to show the submission window and points to show the announcement times. This will make the 24-hour delay (the "cost" of treatment) much more intuitive.

### Table 1: "Summary Statistics"
**Page:** 11
- **Formatting:** Clean, but missing decimal alignment in the "Mean" and "SD" columns. The horizontal lines (booktabs style) are appropriate.
- **Clarity:** Good. It clearly distinguishes between the full sample and the RDD slice.
- **Storytelling:** Effectively shows that the RDD sample is a subset with slightly different characteristics (e.g., higher citations), which is important for the LATE interpretation.
- **Labeling:** "Variable" labels are clear. Units (e.g., "count" or "0-1") should be implicitly or explicitly clearer in the notes.
- **Recommendation:** **KEEP AS-IS** (with minor decimal alignment tweak).

### Figure 2: "First Stage: Listing Position Discontinuity at the 14:00 ET Cutoff"
**Page:** 14
- **Formatting:** Professional. The use of binned means with confidence intervals and a local polynomial fit is standard.
- **Clarity:** The "jump" is unmistakable. The y-axis (Position percentile) is inverted in meaning (lower is better), which is correctly noted.
- **Storytelling:** This is a perfect "First Stage" plot. It proves the instrument works.
- **Labeling:** Excellent. The annotations "Before cutoff" and "After cutoff" inside the plot area would help further, but the notes are sufficient.
- **Recommendation:** **KEEP AS-IS**

### Figure 3: "Submission Density Around the 14:00 ET Cutoff"
**Page:** 15
- **Formatting:** Standard histogram.
- **Clarity:** Shows the spike after the cutoff clearly.
- **Storytelling:** Vital for the "strategic timing" discussion. It honestly shows that authors try to game the system.
- **Labeling:** Clear. 
- **Recommendation:** **KEEP AS-IS**

### Table 2: "Covariate Balance at the Cutoff"
**Page:** 16
- **Formatting:** Minimalist and clean.
- **Clarity:** Easy to scan for p-values.
- **Storytelling:** Confirms that despite the density spike in Figure 3, the *types* of papers are similar.
- **Labeling:** Standard errors in parentheses are correctly noted.
- **Recommendation:** **KEEP AS-IS**

### Table 3: "The Visibility Premium: RDD Estimates at the arXiv Daily Cutoff"
**Page:** 16
- **Formatting:** Journal-ready. Clear column headers.
- **Clarity:** The null results are immediately apparent from the small coefficients relative to SEs.
- **Storytelling:** This is the "Money Table." It directly tests the main hypothesis.
- **Labeling:** Significance stars are defined (though none are used, which is the point).
- **Recommendation:** **KEEP AS-IS**

### Figure 4: "RDD Plot: Three-Year Citations at the arXiv Daily Cutoff"
**Page:** 17
- **Formatting:** High quality.
- **Clarity:** Slightly "noisy" compared to the first stage, which correctly represents the data.
- **Storytelling:** Visually reinforces Table 3. The "jump" is visibly non-existent/flat.
- **Labeling:** Y-axis is clearly log-transformed.
- **Recommendation:** **KEEP AS-IS**

### Figure 5: "Bandwidth Sensitivity: Estimates Stable Across Choices"
**Page:** 18
- **Formatting:** Standard coefficient plot.
- **Clarity:** Shows the point estimates crossing zero at different bandwidths.
- **Storytelling:** Essential for RDD robustness.
- **Labeling:** Y-axis label "RDD estimate (robust)" is clear.
- **Recommendation:** **REVISE**
  - **Change:** Add a horizontal dashed line at y=0 (it is there, but faint). Make it more prominent to highlight the null.

### Table 4: "Robustness: Bandwidth Sensitivity and Donut RDD"
**Page:** 19
- **Formatting:** Good use of panels (Panel A, Panel B).
- **Clarity:** Combines several robustness checks efficiently.
- **Storytelling:** Strong. Shows that even when "strategic" papers are removed (Donut), the result remains null.
- **Recommendation:** **KEEP AS-IS**

### Figure 6: "Placebo Cutoffs: Only the Real 14:00 ET Cutoff Matters"
**Page:** 20
- **Formatting:** Good use of color/shape (red triangle) to distinguish the true effect.
- **Clarity:** Very high.
- **Storytelling:** A "Turing Test" for the result. Since nothing is significant at any time, it reinforces that there's no hidden time-of-day effect.
- **Recommendation:** **KEEP AS-IS**

### Table 5: "Heterogeneity by arXiv Category"
**Page:** 22
- **Formatting:** Clean.
- **Clarity:** The extremely small N for `cs.CL` and others is alarming but transparent.
- **Storytelling:** Shows the result isn't just driven by one sub-field.
- **Recommendation:** **MOVE TO APPENDIX**
  - **Reason:** The sample sizes in the sub-categories are too small (N=5, N=14) to be meaningful in the main text. The main text should focus on the pooled results.

---

## Appendix Exhibits

### Figure 7: "McCrary Density Test at the 14:00 ET Cutoff"
**Page:** 31
- **Formatting:** Output from `rddensity`. 
- **Clarity:** Professional but a bit "busy" with the overlapping shaded areas.
- **Storytelling:** Technically superior to Figure 3 for formal testing.
- **Recommendation:** **KEEP AS-IS**

### Figure 8: "Donut RDD: Excluding Papers Near the Cutoff"
**Page:** 32
- **Formatting:** Similar to Figure 5.
- **Clarity:** Good.
- **Storytelling:** Redundant with Table 4 Panel B.
- **Recommendation:** **REMOVE**
  - **Reason:** Table 4 already presents these numbers clearly. This figure doesn't add a new dimension of understanding.

### Figure 9: "Formal RDD Plot: rdplot Visualization"
**Page:** 33
- **Formatting:** Default R output.
- **Clarity:** The 4th-order polynomial (red line) looks like "overfitting" (wavy lines).
- **Storytelling:** This actually makes the data look *less* convincing than Figure 4. 
- **Recommendation:** **REVISE** or **REMOVE**
  - **Change:** If kept, use a lower-order polynomial. Top journals prefer local linear fits (as in Figure 4) over high-order global polynomials which can be misleading.

### Figure 10: "Covariate Balance at the Cutoff"
**Page:** 34
- **Formatting:** Coefficient plot for balance.
- **Clarity:** The x-axis scale is dominated by "abstract_length" (which is in hundreds), making all other indicators look like zero.
- **Storytelling:** Poor due to scaling issues.
- **Recommendation:** **REVISE**
  - **Change:** Standardize the covariates (z-scores) before plotting, or split into two plots (one for continuous counts, one for binary indicators).

---

## Overall Assessment

- **Exhibit count:** 3 main tables, 5 main figures, 2 appendix tables (referenced but not all shown in OCR), 4 appendix figures.
- **General quality:** Extremely high. The paper follows the "Cattaneo et al." school of RDD visualization, which is the current gold standard for AER/QJE.
- **Strongest exhibits:** Figure 2 (First Stage) and Figure 6 (Placebos).
- **Weakest exhibits:** Figure 10 (Scaling issues) and Figure 1 (Needs to be a diagram).

- **Missing exhibits:** 
  1. **A Coefficient Plot for All Outcomes:** A single figure showing the RDD coefficient and 95% CI for 1y, 3y, 5y citations, and industry adoption would be a great "Summary of Results" figure for the introduction or results start.
  2. **Raw Data Scatter:** A plot of Citations vs. Submission Time for the *entire* day (not just the RDD window) to show the descriptive "Selection" effect the author claims exists.

- **Top 3 improvements:**
  1. **Diagrammatic Figure 1:** Turn the text box into a visual timeline of the arXiv submission/announcement cycle.
  2. **Standardize Figure 10:** Scale the covariate balance plot so the binary indicators are visible alongside abstract length.
  3. **Streamline Main Text:** Move Table 5 (Heterogeneity) to the appendix as the sub-sample sizes are too small for a main-text claim.