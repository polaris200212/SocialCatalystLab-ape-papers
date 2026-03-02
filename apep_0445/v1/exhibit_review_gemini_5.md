# Exhibit Review — Gemini 3 Flash (Round 5)

**Role:** Visual exhibit advisor
**Model:** gemini-3-flash-preview (ai_studio)
**Paper:** paper.pdf
**Timestamp:** 2026-02-23T16:12:55.140027
**Route:** Direct Google API + PDF
**Tokens:** 19437 in / 2138 out
**Response SHA256:** 55a1bf0fcfb284dd

---

This review evaluates the visual exhibits of your paper for submission to top-tier economics journals. The paper presents a high-quality, professional suite of exhibits that follow standard RDD conventions. However, several figures require better "10-second" legibility, and certain tables can be consolidated to streamline the main text.

# Exhibit-by-Exhibit Review

## Main Text Exhibits

### Table 1: "Summary Statistics: Census Tracts Near the 20% Poverty Threshold"
**Page:** 10
- **Formatting:** Clean and professional. Proper use of panels (A, B, C).
- **Clarity:** High. Clearly compares treatment/control regions near the cutoff.
- **Storytelling:** Essential. It establishes that while tracts are similar in levels, there is a "selection" effect in Panel C (governor choice) that justifies the ITT approach.
- **Labeling:** Good. Standard errors are appropriately omitted from summary tables; units are clearly marked.
- **Recommendation:** **KEEP AS-IS**

### Figure 1: "Distribution of Census Tracts Around the 20% Poverty Threshold"
**Page:** 14
- **Formatting:** Modern and clean. The use of different colors for below/above threshold is helpful.
- **Clarity:** The subtitle "McCrary test" is a bit small. 
- **Storytelling:** Critical for RDD validity. It honestly shows the heaping/discontinuity which is common in poverty-rate data.
- **Labeling:** Clear. 
- **Recommendation:** **REVISE**
  - Increase the font size of the subtitle (McCrary stats).
  - Add a vertical line at 20% that is clearly labeled "Poverty Threshold (20%)" to match the text.

### Figure 2: "Approximated OZ Designation Pattern by Poverty Rate"
**Page:** 15
- **Formatting:** Professional. Good use of binned scatter with a linear fit.
- **Clarity:** High.
- **Storytelling:** Establishes the "first stage" of the ITT. It shows the probability is low at the cutoff but rises, which is a nuanced but important point.
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS**

### Table 2: "Covariate Balance at the 20% Poverty Threshold"
**Page:** 16
- **Formatting:** Standard. Numbers are decimal-aligned.
- **Clarity:** Good, though "RDD Estimate" needs to be clearly defined as the jump at the cutoff.
- **Storytelling:** Necessary for RDD.
- **Labeling:** "p-value" column is helpful for quick scanning.
- **Recommendation:** **MOVE TO APPENDIX**
  - Most AER/QJE papers move the full covariate balance table to the Appendix and summarize it in the text, or use a "Coefficient Plot" (like your Figure 8) in the main text instead. Figure 8 is more visually impactful.

### Table 3: "Main RDD Estimates: Effect of OZ Eligibility on Employment"
**Page:** 16
- **Formatting:** Journal-ready. Proper use of brackets for CI and parentheses for SE.
- **Clarity:** Excellent. The primary result is undeniable.
- **Storytelling:** This is the "Money Table." 
- **Labeling:** Clear. Note mentions `rdrobust`.
- **Recommendation:** **KEEP AS-IS**

### Figure 3: "Reduced-Form RDD: Change in Total Employment at the OZ Eligibility Threshold"
**Page:** 17
- **Formatting:** Good use of point-size to represent 'n'.
- **Clarity:** The y-axis "Change in Total Employment (2019-2023 vs 2015-2017)" is a bit wordy but accurate.
- **Storytelling:** Visually confirms the null from Table 3.
- **Labeling:** Legend is clear.
- **Recommendation:** **REVISE**
  - **Crucial:** The red dashed line should be labeled "Eligibility Threshold" directly on the plot. 
  - Consider a "Donut" version of this plot if the bunching at the threshold is a major reviewer concern.

### Figure 4: "Reduced-Form RDD: Change in Information-Sector Employment at the Threshold"
**Page:** 18
- **Formatting:** Consistent with Figure 3.
- **Clarity:** Good.
- **Storytelling:** This is the key sectoral result.
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS** (Or consider combining Figs 3 and 4 into a two-panel Figure 3 to save space).

### Table 4: "Bandwidth Sensitivity: $\Delta$ Total Employment"
**Page:** 18
- **Formatting:** Clean.
- **Clarity:** High.
- **Storytelling:** Demonstrates the null isn't an artifact of the 100% bandwidth.
- **Labeling:** Units are clear.
- **Recommendation:** **MOVE TO APPENDIX** 
  - In a top journal, the main text should focus on the primary result. This is a robustness check better suited for the Appendix (Table 7 already does some of this work).

### Figure 5: "Placebo Cutoff Tests"
**Page:** 19
- **Formatting:** Clear. The use of red for the true cutoff is excellent.
- **Clarity:** High.
- **Storytelling:** Very persuasive. It shows the 20% estimate is unremarkable relative to random noise.
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS**

### Figure 6: "Dynamic RDD: Year-by-Year Estimates at the 20% Poverty Threshold"
**Page:** 20
- **Formatting:** Professional.
- **Clarity:** Very high.
- **Storytelling:** Essential. It proves the "Parallel Trends" logic of the RDD by showing flat pre-trends.
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS**

### Table 5: "Parametric RDD Specifications"
**Page:** 21
- **Formatting:** Standard OLS table style.
- **Clarity:** Slightly cluttered due to the interaction terms and many rows.
- **Storytelling:** Confirms that the non-parametric results hold under OLS with controls.
- **Labeling:** Column headers could be more descriptive (e.g., "Total Emp" vs "Info Emp").
- **Recommendation:** **REVISE**
  - Group the outcomes. Use "$\Delta$ Total Employment" as a super-header for cols 1-3 and "$\Delta$ Info Employment" for 4-5.
  - Simplify the "Above Threshold $\times$ Poverty Rate" label.

### Table 6: "Heterogeneity: Urban versus Rural Tracts"
**Page:** 22
- **Formatting:** Clean.
- **Clarity:** Good.
- **Storytelling:** Vital for the "Data Center" story, as they only go to urban areas.
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS**

---

## Appendix Exhibits

### Figure 7: "Bandwidth Sensitivity of the Main RDD Estimate"
**Page:** 32
- **Recommendation:** **KEEP AS-IS** (Redundant with Table 4, but good for Appendix).

### Table 7, 8, & 9: "Robustness Checks"
**Page:** 33-34
- **Recommendation:** **REVISE (CONSOLIDATE)**
  - Tables 7, 8, and 9 are all testing the same thing: robustness of the null. 
  - Suggest merging them into one "Robustness of the Main Null Result" table with multiple panels. Panel A: Donut sizes. Panel B: Polynomial orders. Panel C: Kernels. This makes the Appendix much easier to navigate.

### Figure 8: "Covariate Balance at the 20% Poverty Threshold"
**Page:** 35
- **Recommendation:** **PROMOTE TO MAIN TEXT**
  - This is much more effective than Table 2. It shows the reader at a glance which variables are balanced and which have "heaping" issues. Swap Table 2 for this.

---

## Overall Assessment

- **Exhibit count:** 6 Main Tables, 6 Main Figures, 3 Appendix Tables, 2 Appendix Figures.
- **General quality:** Extremely high. The paper follows the "Cattaneo/Titiunik" RDD style perfectly. The aesthetics are minimalist and professional.
- **Strongest exhibits:** Figure 6 (Dynamic RDD) and Figure 5 (Placebo Cutoffs).
- **Weakest exhibits:** Table 2 (too dry for main text) and Figure 1 (needs larger subtitle text).
- **Missing exhibits:** A **Map Figure** showing the spatial distribution of OZ-eligible vs. designated tracts in a specific high-density data center region (e.g., Northern Virginia/Loudoun County) would be a "Gold Star" addition for a journal like the AEJ: Policy. It would ground the abstract RDD in the real-world geography of the industry.

### Top 3 Improvements:
1.  **Swap Table 2 for Figure 8 (Coefficient Plot)** in the main text. It is more visually efficient for showing covariate imbalance.
2.  **Consolidate Appendix Tables 7, 8, and 9** into a single multi-panel "Master Robustness Table."
3.  **Label Figure 3 & 4 axes and thresholds more aggressively.** Ensure the vertical line is explicitly labeled "20% Poverty Threshold" on the graph itself to improve the "10-second parse."