# Exhibit Review — Gemini 3 Flash (Round 1)

**Role:** Visual exhibit advisor
**Model:** gemini-3-flash-preview (ai_studio)
**Paper:** paper.pdf
**Timestamp:** 2026-03-03T19:31:49.156998
**Route:** Direct Google API + PDF
**Tokens:** 19437 in / 1963 out
**Response SHA256:** 4b3d958aeb01c26c

---

This review evaluates the exhibits in "Who Captures a Tax Cut? Property Price Capitalization and Fiscal Substitution from France’s Residence Tax Abolition" according to top-journal standards (AER, QJE).

# Exhibit-by-Exhibit Review

## Main Text Exhibits

### Figure 1: "Distribution of Pre-Reform Commune TH Rates (2017)"
**Page:** 12
- **Formatting:** Clean, professional. The red dashed line for the median is standard and helpful.
- **Clarity:** Excellent. It clearly shows the continuous nature of the treatment variation.
- **Storytelling:** Essential. It justifies using a continuous-treatment DiD rather than a binary comparison.
- **Labeling:** Clear. Axis labels and units (%) are present.
- **Recommendation:** **KEEP AS-IS**

### Table 1: "Summary Statistics"
**Page:** 13
- **Formatting:** Standard "Booktabs" style. Good use of panels (A and B). 
- **Clarity:** Logical layout. N is clearly defined for different levels of observation (transaction vs. commune).
- **Storytelling:** Provides the necessary scale of the data (5.4M transactions).
- **Labeling:** Good. "Price per m²" and "Tax rates (%)" are clearly labeled.
- **Recommendation:** **KEEP AS-IS**

### Table 2: "Effect of Taxe d’Habitation Abolition on Property Prices"
**Page:** 16
- **Formatting:** Journal-ready. Proper use of parentheses for SEs and stars for significance.
- **Clarity:** The coefficients are very small ($10^{-5}$), which is a common issue in capitalization papers.
- **Storytelling:** This is the "Main Result" table showing the null effect.
- **Labeling:** "TH Rate (2017)" is the key regressor. Note: the table uses scientific notation for the main coefficient.
- **Recommendation:** **REVISE**
  - **Specific Change:** Rescale the TH Rate variable (e.g., divide by 10 or 100) or report the coefficient for a 10-percentage-point change. Scientific notation ($5.17 \times 10^{-5}$) is often harder for a reader to mentally parse than "0.005".

### Figure 2: "Event Study: TH Rate × Year Interaction"
**Page:** 17
- **Formatting:** Clean background. Reference year (0/2020) is clear.
- **Clarity:** The y-axis uses scientific notation (0e+00, -4e-04). This is visually cluttered.
- **Storytelling:** Crucial for showing no post-reform divergence.
- **Labeling:** Axis labels are descriptive.
- **Recommendation:** **REVISE**
  - **Specific Change:** Fix the y-axis labels. Instead of "0e+00", use "0.000". Better yet, multiply the dependent variable by 100 so the y-axis represents percentage points, allowing for cleaner labels (e.g., -0.04, -0.02, 0).

### Figure 3: "Event Study: High TH (Q4) vs. Low TH (Q1) Communes"
**Page:** 18
- **Formatting:** Consistent with Figure 2.
- **Clarity:** Much easier to read than Figure 2 because the coefficients are larger (binned comparison).
- **Storytelling:** Good robustness/alternative visualization of Figure 2.
- **Recommendation:** **KEEP AS-IS**

### Figure 4: "Property Prices by Pre-Reform TH Rate Quartile"
**Page:** 19
- **Formatting:** High quality. Good use of color (Viridis-style palette).
- **Clarity:** Very high. The parallel trends are obvious to the naked eye.
- **Storytelling:** This is the most "honest" look at the raw data. It effectively anchors the regression results.
- **Recommendation:** **KEEP AS-IS**

### Table 3: "Fiscal Substitution: TFB Rate Change (2017–2024)"
**Page:** 20
- **Formatting:** Consistent with Table 2.
- **Clarity:** Simple 2-column structure is clear.
- **Storytelling:** This is the "Mechanism" table. It supports the core claim of the paper.
- **Recommendation:** **KEEP AS-IS**

### Figure 5: "Fiscal Substitution: TFB Rate Change vs. Pre-Reform TH Rate"
**Page:** 21
- **Formatting:** Scatter plot with OLS fit. The density of points makes it look like a "cloud."
- **Clarity:** The red line is clear, but the individual dots (33,000 communes) are a bit overwhelming.
- **Storytelling:** Visualizes the mechanism from Table 3.
- **Recommendation:** **REVISE**
  - **Specific Change:** Consider a **Binscatter** version of this plot (similar to Figure 6) to show the relationship more cleanly, or use a hex-bin plot to show the density of communes more effectively.

### Figure 6: "Binscatter: TH Rate and Residualized Property Prices"
**Page:** 22
- **Formatting:** Excellent. Professional use of confidence intervals.
- **Clarity:** High. Summarizes 5 million rows of data in one clear picture.
- **Storytelling:** This is the "Money Shot" of the paper. It shows the null result after controls.
- **Recommendation:** **KEEP AS-IS** (Consider moving this earlier in the results section).

### Table 4: "Heterogeneity by Property Type"
**Page:** 23
- **Formatting:** Consistent. 
- **Clarity:** Shows the "Apartment" vs "House" split clearly.
- **Storytelling:** Adds nuance; the negative coefficient for apartments is an important finding.
- **Recommendation:** **KEEP AS-IS**

### Table 5: "Robustness: Alternative Specifications"
**Page:** 24
- **Formatting:** Tight but readable. 
- **Clarity:** Covers many bases (Binary, Std, No IDF, etc.).
- **Storytelling:** Standard "kitchen sink" robustness table.
- **Recommendation:** **KEEP AS-IS**

### Figure 7: "Leave-One-Out: Stability Across Départements"
**Page:** 25
- **Formatting:** Good visualization of a standard robustness check.
- **Clarity:** The ordering by coefficient size makes the stability obvious.
- **Recommendation:** **KEEP AS-IS**

---

## Appendix Exhibits

### Figure 8: "Fiscal Substitution Event Study: TFB Rate Response to Baseline TH Rate"
**Page:** 34
- **Formatting:** Consistent with main text event studies.
- **Clarity:** Shows the "pre-trend" (years -3 to 0) which is vital.
- **Storytelling:** This provides the causal "bridge" for the mechanism.
- **Labeling:** Clear.
- **Recommendation:** **PROMOTE TO MAIN TEXT**
  - **Reason:** In a top-tier journal, the "Parallel Trends" for the mechanism are just as important as the parallel trends for the main result. This should be a panel in a "Mechanism" figure alongside the scatter plot.

---

## Overall Assessment

- **Exhibit count:** 5 main tables, 7 main figures, 0 appendix tables, 1 appendix figure.
- **General quality:** Extremely high. The paper follows the "Modern Empirical Micro" aesthetic perfectly (clean plots, binscatters, event studies).
- **Strongest exhibits:** Figure 4 (Raw trends) and Figure 6 (Binscatter).
- **Weakest exhibits:** Figure 2 and Table 2 (due to the scientific notation/scaling issues).
- **Missing exhibits:** 
    1. **A Map:** A paper about France with 33,000 communes *needs* a map of the treatment intensity (TH rates in 2017).
    2. **A Decomposition Table:** Since the paper claims the "Net Benefit" is what matters, a table showing the calculation of the "Net Fiscal Impact" for a median home would be a powerful storytelling device.
- **Top 3 improvements:**
  1. **Rescale variables:** Fix the $10^{-5}$ coefficients in Table 2 and the scientific notation on the y-axis of Figure 2. It makes the results look "too small to matter" rather than "precisely estimated zeros."
  2. **Add a Map:** Create a choropleth map of France showing pre-reform TH rates to visualize the "Natural Experiment" and geographic variation.
  3. **Consolidate Mechanism Figures:** Merge Figure 5 (Scatter), Figure 8 (Appendix Event Study), and Table 3 into a single multi-panel "Mechanism" exhibit. This makes the substitution story undeniable.