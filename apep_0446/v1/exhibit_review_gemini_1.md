# Exhibit Review — Gemini 3 Flash (Round 1)

**Role:** Visual exhibit advisor
**Model:** gemini-3-flash-preview (ai_studio)
**Paper:** paper.pdf
**Timestamp:** 2026-02-23T18:05:47.513188
**Route:** Direct Google API + PDF
**Tokens:** 18397 in / 1792 out
**Response SHA256:** 05161825cbbc3fa6

---

This review evaluates the visual exhibits of the paper "Digital Markets and Price Discovery: Evidence from India’s e-NAM Agricultural Platform" against the standards of top-tier economics journals (AER, QJE, etc.).

# Exhibit-by-Exhibit Review

## Main Text Exhibits

### Table 1: "Summary Statistics"
**Page:** 9
- **Formatting:** Clean and professional. Uses horizontal rules appropriately (top, mid, bottom). Numbers are mostly aligned, though "Mean Price" and "Total Obs" could be decimal-aligned for better scanning.
- **Clarity:** Excellent. Provides a clear overview of the four commodities and the sample composition (treated vs. control).
- **Storytelling:** Critical. It immediately reveals the "Never-Treated" sample size problem, justifying the use of the CS-DiD estimator later.
- **Labeling:** Clear. Notes define the sample and the units (Rs per quintal).
- **Recommendation:** **KEEP AS-IS**

### Table 2: "Effect of e-NAM Integration on Log Mandi Prices"
**Page:** 13
- **Formatting:** Standard regression format. $R^2$ and Within $R^2$ values are reported to 5 decimal places; 3 is sufficient for top journals.
- **Clarity:** Logic is clear (commodity-by-commodity TWFE). However, the "mandi_id" and "time_period" labels are a bit "code-heavy." 
- **Storytelling:** This is the "straw man" table. It shows the biased TWFE results. It is necessary to set up the contrast with Table 3.
- **Labeling:** Significance stars are standard.
- **Recommendation:** **REVISE**
  - Change "mandi_id fixed effects" to "Mandi FEs" and "time_period" to "Month-Year FEs."
  - Round $R^2$ values to 3 decimal places.

### Table 3: "e-NAM Price Effects by Commodity"
**Page:** 14
- **Formatting:** Very sparse. It looks more like a summary of coefficients than a standard regression table.
- **Clarity:** It’s easy to read, but it lacks the standard regression diagnostic info (Fixed Effects, Clustering) seen in Table 2.
- **Storytelling:** This is the "hero" table of the paper. It shows the corrected positive results for storable crops. 
- **Recommendation:** **REVISE**
  - Merge this with Table 2 or format it identically. It should show the "TWFE" vs "CS-DiD" side-by-side in columns for Wheat and Soybean to make the sign reversal the visual centerpiece.

### Figure 1 & 2: "Dynamic Treatment Effects: [Wheat/Soybean]"
**Page:** 15-16
- **Formatting:** High quality. Clean background, shaded 95% CIs, and a clear treatment line.
- **Clarity:** Very high. The distinction between pre-trend testing and post-treatment growth is immediate.
- **Storytelling:** These are the most important figures in the paper. They validate the identification strategy.
- **Labeling:** "Quarters Relative to e-NAM Integration" is a good x-axis choice.
- **Recommendation:** **REVISE**
  - **Consolidate:** Combine these into a single figure with Panel A (Wheat) and Panel B (Soybean). This saves space and allows for a direct visual comparison of the magnitudes.

### Figure 3: "e-NAM Price Effects by Commodity"
**Page:** 18
- **Formatting:** Simple coefficient plot.
- **Clarity:** High, but somewhat redundant if the reader has already seen Table 3 and Figures 1/2.
- **Storytelling:** It summarizes the "storability divide."
- **Recommendation:** **MOVE TO APPENDIX**
  - The main text already has the specific event studies and the point estimates in tables. This summary plot is "nice to have" but not "need to have" for the main narrative.

### Figure 4: "Placebo Test: Falsification of Pre-Trends"
**Page:** 19
- **Formatting:** Excellent use of color (Blue vs. Red) to denote significance.
- **Clarity:** The "Non-significant = parallel trends supported" annotation is a great "reader-friendly" touch.
- **Storytelling:** Essential. It kills the perishable crop results and saves the storable ones.
- **Recommendation:** **KEEP AS-IS**

### Table 4: "Robustness: e-NAM Price Effects Across Estimators"
**Page:** 20
- **Formatting:** Good use of em-dashes for non-estimable cells.
- **Clarity:** Logical layout comparing the three main estimators plus the placebo.
- **Storytelling:** Crucial for the "DiD revolution" literature context (comparing TWFE, CS, and Sun-Abraham).
- **Recommendation:** **KEEP AS-IS**

### Figure 5: "Sensitivity to Treatment Date Assignment"
**Page:** 21
- **Formatting:** A bit cluttered with the 5 different "shift" points for 4 commodities.
- **Clarity:** Harder to parse in 10 seconds than the previous figures.
- **Storytelling:** Robustness. It proves the results aren't sensitive to the specific month of rollout.
- **Recommendation:** **MOVE TO APPENDIX**
  - This is a standard robustness check that rarely needs to be in the main text of an AER/QJE paper unless the treatment timing is highly controversial.

---

## Appendix Exhibits

### Figure 6: "Staggered Rollout of e-NAM Platform"
**Page:** 32
- **Formatting:** High quality.
- **Clarity:** Great visualization of the "waves" of treatment.
- **Storytelling:** This provides the "institutional reality" of the staggered DiD.
- **Recommendation:** **PROMOTE TO MAIN TEXT**
  - Top journals love a "Figure 1" that shows the rollout of the policy being studied. This should be in Section 2 (Institutional Background).

### Figure 7: "Price Dispersion Over Time"
**Page:** 33
- **Formatting:** The "spaghetti" lines for the raw data are very thin and hard to distinguish.
- **Clarity:** Low. The message ("modest reduction") is lost in the noise of the plot.
- **Storytelling:** Redundant with the text in Section 6.4.
- **Recommendation:** **REVISE**
  - Use a "binned" version of the data or show the average CV for "Early Treated" vs "Never Treated" to make the trend lines clearer. If it remains this noisy, **REMOVE**.

---

## Overall Assessment

- **Exhibit count:** 4 main tables, 5 main figures, 0 appendix tables, 2 appendix figures.
- **General quality:** High. The figures are modern and the tables follow "Best Practice" for staggered DiD papers.
- **Strongest exhibits:** Figure 4 (Placebo) and Figure 1 (Wheat Event Study).
- **Weakest exhibits:** Figure 7 (Dispersion) and Figure 5 (Sensitivity).
- **Missing exhibits:** 
    1. **A Map:** A paper on India’s market integration almost *requires* a map showing the geographic distribution of mandis and which states integrated in which phase.
    2. **Balance Table:** A table comparing characteristics of early-adopters vs. late-adopters (e.g., size of mandi, distance to rail) would strengthen the selection argument.

- **Top 3 improvements:**
  1. **Consolidate Event Studies:** Put Figure 1 and 2 into a single two-panel figure. 
  2. **The "Comparison" Table:** Merge Table 3 into Table 2. Show the transition from biased TWFE to robust CS-DiD in one clear table so the reader can see the coefficients flip.
  3. **Institutional Visuals:** Promote the Rollout Figure (Fig 6) to the main text and add a Map of the mandis. This grounds the "Spatial Arbitrage" mechanism in physical reality.