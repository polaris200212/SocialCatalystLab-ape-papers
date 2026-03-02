# Exhibit Review — Gemini 3 Flash (Round 1)

**Role:** Visual exhibit advisor
**Model:** gemini-3-flash-preview (ai_studio)
**Paper:** paper.pdf
**Timestamp:** 2026-02-20T09:30:22.632921
**Route:** Direct Google API + PDF
**Tokens:** 23077 in / 2518 out
**Response SHA256:** 3ea64db571539dee

---

This review evaluates the exhibits in the paper "Does Piped Water Build Human Capital? Evidence from India’s Jal Jeevan Mission" against the standards of top-tier economics journals (AER, QJE, etc.).

# Exhibit-by-Exhibit Review

## Main Text Exhibits

### Table 1: "Summary Statistics"
**Page:** 10
- **Formatting:** Clean, uses standard booktabs. Professional spacing.
- **Clarity:** Excellent. Separating "Baseline" and "Changes" is logical.
- **Storytelling:** Provides the necessary scale for the JJM program and the baseline deficits.
- **Labeling:** Units (pp, %, thousands) are clearly marked.
- **Recommendation:** **KEEP AS-IS**

### Figure 1: "Baseline Water Infrastructure Deficit by District"
**Page:** 11
- **Formatting:** **Major Error.** The title says "Map shows..." and the notes discuss "Darker shading," but the image is a **Histogram**. 
- **Clarity:** The histogram itself is clear, but it does not match the description.
- **Storytelling:** A histogram is useful to show the distribution of the instrument, but the paper explicitly refers to geographic concentration (Northeast, Rajasthan) which requires a map.
- **Labeling:** The x-axis and y-axis are clear.
- **Recommendation:** **REVISE**
  - Replace the histogram with an actual choropleth map of India as described in the text and notes.
  - Move the histogram to the Appendix or combine it into a two-panel figure (Panel A: Map, Panel B: Histogram).

### Table 2: "First Stage: Baseline Water Deficit Predicts Water Improvement"
**Page:** 14
- **Formatting:** Standard journal format. 
- **Clarity:** The progression from unconditional to controlled models is clear.
- **Storytelling:** Establishes the strength of the instrument (F > 1000).
- **Labeling:** Notes are comprehensive; significance stars are defined.
- **Recommendation:** **KEEP AS-IS**

### Figure 2: "First Stage: Water Deficit vs. Water Improvement"
**Page:** 15
- **Formatting:** The binned scatter plot is professional. 
- **Clarity:** Legend/Title mismatch. The figure title says "vs. Water Improvement," but the y-axis label says "$\Delta$ Female School Attendance." This is actually the **Reduced Form** plot for education, not the First Stage.
- **Storytelling:** Crucial for showing linearity and lack of outliers.
- **Labeling:** Axis labels are inconsistent with the title.
- **Recommendation:** **REVISE**
  - Fix the y-axis label to match the title (should be $\Delta$ Improved Drinking Water) OR change the title to reflect that this is the Education Reduced Form.

### Table 3: "Reduced Form: Water Deficit and Education Outcomes"
**Page:** 16
- **Formatting:** Standard. Decimal alignment is good.
- **Clarity:** Logical grouping of education variables.
- **Storytelling:** Shows the "flow" (attendance) vs "stock" (literacy) impacts.
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS**

### Figure 3: "Reduced Form: Water Deficit vs. Change in Female School Attendance"
**Page:** 17
- **Formatting:** Professional binscatter.
- **Clarity:** **Redundancy/Labeling Error.** This figure is almost identical to Figure 2. The title says "First Stage" in the header but "Reduced Form" in the caption. 
- **Storytelling:** Redundant if Figure 2 is corrected.
- **Recommendation:** **REMOVE** (or consolidate). If Figure 2 is corrected to be the First Stage, this Figure 3 can stay as the Reduced Form, but the internal header "First Stage" must be deleted.

### Table 4: "IV Estimates: Effect of Water Improvement on Education"
**Page:** 18
- **Formatting:** AER-ready.
- **Clarity:** High. Shows the main causal estimates.
- **Storytelling:** The core result of the paper.
- **Labeling:** Correctly identifies 2SLS.
- **Recommendation:** **KEEP AS-IS**

### Table 5: "Health Mechanism: Water Deficit and Health Outcomes"
**Page:** 19
- **Formatting:** Excellent use of Panels (A: Reduced Form, B: IV).
- **Clarity:** High, despite many columns. 
- **Storytelling:** Effectively groups the "mechanism" outcomes.
- **Labeling:** Good.
- **Recommendation:** **KEEP AS-IS**

### Figure 4: "Health Mechanism: Water Deficit vs. Change in Child Stunting and Institutional Births"
**Page:** 20
- **Formatting:** Professional coefficient plot.
- **Clarity:** The "Domain" color-coding is excellent for quick parsing.
- **Storytelling:** Effectively summarizes Table 5.
- **Labeling:** The x-axis "Coefficient on Water Gap" is clear.
- **Recommendation:** **KEEP AS-IS**

### Table 6: "Placebo: Water Deficit and Nighttime Lights"
**Page:** 21
- **Formatting:** Standard.
- **Clarity:** Good.
- **Storytelling:** Essential for the exclusion restriction argument.
- **Recommendation:** **KEEP AS-IS** (or move to Appendix if space is tight, but AER usually likes placebos in main text).

### Table 7: "Heterogeneity in Education Effects"
**Page:** 22
- **Formatting:** Standard.
- **Clarity:** Split-sample approach is clear.
- **Storytelling:** Crucial for the "marginalized groups" narrative.
- **Recommendation:** **KEEP AS-IS**

### Figure 5: "Heterogeneity: Education Effects by Baseline Characteristics"
**Page:** 22
- **Formatting:** Coefficient plot.
- **Clarity:** **Title/Label Mismatch.** The plot title says "Placebo Tests," but the Figure caption says "Heterogeneity." The actual outcomes listed (Tobacco, Pregnancy, etc.) are **Placebos**, not education heterogeneity.
- **Storytelling:** This is an exclusion restriction plot, not a heterogeneity plot.
- **Recommendation:** **REVISE**
  - Fix title/caption mismatch. Rename to "Figure 5: Placebo Outcomes."
  - Move to after Table 6 (Placebo section).

### Figure 6: "Leave-One-State-Out Estimates: Female School Attendance"
**Page:** 23
- **Formatting:** **Major Error.** The figure title and text describe "Leave-One-State-Out" (which should be a plot of 35 coefficients), but the image provided is a **Randomization Inference Permutation Distribution**.
- **Clarity:** The histogram is clear, but it's the wrong exhibit for this section.
- **Storytelling:** RI is important, but the LOSO plot is missing.
- **Recommendation:** **REVISE**
  - Insert the actual LOSO coefficient plot (usually a sorted dot-and-whisker plot).
  - Move this RI histogram to the Appendix or a dedicated RI section.

### Table 8: "Robustness Summary: Female School Attendance"
**Page:** 26
- **Formatting:** Good summary table.
- **Clarity:** Very high—allows a reader to see the "stability" of the 0.35 coefficient across all specs.
- **Storytelling:** Strong closer for the empirical section.
- **Recommendation:** **KEEP AS-IS**

### Figure 7: "Placebo Test: Distribution of Placebo Coefficients"
**Page:** 28
- **Formatting:** This is the **actual LOSO plot** that was supposed to be Figure 6.
- **Clarity:** The x-axis labels (State names) are vertical and hard to read.
- **Storytelling:** Confirms no single state drives results.
- **Recommendation:** **REVISE**
  - Correct the numbering and title (this is LOSO, not Placebo).
  - Use a horizontal layout for state names if possible, or rotate 45 degrees for better legibility.

### Figure 8: "Conley Bounds: Sensitivity of IV Estimate to Exclusion Restriction Violations"
**Page:** 29
- **Formatting:** **Major Error.** The image is an **Event Study plot** for Nighttime Lights, but the caption and text describe **Conley Bounds** (a sensitivity plot).
- **Clarity:** The event study plot is actually very good—it shows no pre-trends.
- **Storytelling:** This "Event Study" is highly valuable for identification but is mislabeled as a sensitivity analysis.
- **Recommendation:** **REVISE**
  - Relabel this as "Figure [X]: Event Study of Nighttime Lights."
  - **PROMOTE** this to the identification section (Section 5/6) to prove no pre-trends.
  - Add the actual Conley Bounds plot if it exists.

---

## Appendix Exhibits

### Table A1: "District Matching Between NFHS-4 and NFHS-5"
**Page:** 36
- **Recommendation:** **KEEP AS-IS**. Standard and necessary for transparency.

### Table A2: "Variable Definitions"
**Page:** 38
- **Recommendation:** **KEEP AS-IS**. Essential.

### Table A3: "Full OLS Coefficients: Reduced-Form Regression"
**Page:** 39
- **Recommendation:** **KEEP AS-IS**. Good for showing control coefficients.

### Table A4: "Correlation Matrix: Outcome Changes"
**Page:** 40
- **Recommendation:** **KEEP AS-IS**.

### Table A5 & A6: "Multiple Hypothesis Testing / Wild Cluster Bootstrap"
**Page:** 41-42
- **Recommendation:** **KEEP AS-IS**. These technical robustness checks are perfect for the appendix.

---

## Overall Assessment

- **Exhibit count:** 8 Main Tables, 8 Main Figures, 7 Appendix Tables, 0 Appendix Figures.
- **General quality:** The tables are extremely high quality and AER-ready. The figures have high-quality aesthetics but suffer from **severe labeling and placement errors** (titles, captions, and images are frequently mismatched).
- **Strongest exhibits:** Table 4 (IV Core Results), Table 8 (Robustness Summary), Figure 4 (Mechanism Coefficient Plot).
- **Weakest exhibits:** Figure 1 (described as a map, is a histogram), Figure 6 (described as LOSO, is RI), Figure 8 (described as Conley, is an Event Study).
- **Missing exhibits:** A **Map of India** showing treatment intensity (baseline deficit) is cited in the text but missing from the visuals.

### Top 3 Improvements:
1. **Fix Image-Caption Mismatches:** Ensure the First Stage plot, the LOSO plot, the RI plot, and the Event Study plot are correctly labeled and placed in their respective sections.
2. **Include the Map:** Figure 1 must be a map to support the claims about geographic concentration in the Northeast and tribal areas. 
3. **Consolidate/Clarify First Stage/Reduced Form Figures:** Figures 2 and 3 are redundant and confusingly labeled. Ensure one clearly shows the First Stage ($\Delta$ Water on Deficit) and the other clearly shows the Reduced Form ($\Delta$ Attendance on Deficit).