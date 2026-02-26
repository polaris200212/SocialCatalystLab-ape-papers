# Exhibit Review — Gemini 3 Flash (Round 1)

**Role:** Visual exhibit advisor
**Model:** gemini-3-flash-preview (ai_studio)
**Paper:** paper.pdf
**Timestamp:** 2026-02-26T10:22:49.243461
**Route:** Direct Google API + PDF
**Tokens:** 17357 in / 1881 out
**Response SHA256:** 438c760f3ba749b8

---

# Exhibit-by-Exhibit Review

## Main Text Exhibits

### Table 1: "Summary Statistics: Pre-Treatment Municipality Characteristics (2011–2012)"
**Page:** 9
- **Formatting:** Generally clean. However, it uses double horizontal lines which is slightly dated for top journals. Number alignment is good.
- **Clarity:** Clear comparison between treated and control groups.
- **Storytelling:** Essential. It establishes the baseline differences, which motivates the RDD (showing that simple OLS would be biased).
- **Labeling:** Good. "N" is clearly defined. Notes are comprehensive.
- **Recommendation:** **REVISE**
  - Change "Above 20%" and "Below 20%" to more descriptive headers like "Treated (Share $\ge$ 20%)" and "Control (Share < 20%)".
  - Use single horizontal lines only (Top, Bottom, and below headers).

### Figure 1: "Distribution of Second-Home Shares Across Swiss Municipalities"
**Page:** 10
- **Formatting:** Professional ggplot2-style aesthetic. The blue line for the threshold is clear.
- **Clarity:** High. Shows the skewness and the density near the threshold immediately.
- **Storytelling:** Critical for an RDD paper to show there is mass around the cutoff.
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS**

### Figure 2: "McCrary Density Test at the 20% Threshold"
**Page:** 13
- **Formatting:** Clean. Uses standard `rdrobust` output style.
- **Clarity:** The green bars (histogram) are a bit light; might not print well in grayscale.
- **Storytelling:** Vital for validity. 
- **Labeling:** The x-axis label is "Second-Home Share Minus 20% Threshold". While accurate, it's a bit wordy.
- **Recommendation:** **REVISE**
  - Shorten x-axis to "Distance to 20% Threshold (pp)".
  - Consider consolidating Figure 2 and Table 2 into a single Exhibit (Figure with the stats in a small box or the note) to save space.

### Table 2: "McCrary Density Test at the 20% Threshold"
**Page:** 13
- **Formatting:** Standard.
- **Clarity:** High.
- **Storytelling:** Redundant if Figure 2 is present. Top journals usually prefer the figure with the p-value in the note.
- **Recommendation:** **MOVE TO APPENDIX** or **REMOVE** if p-value is added to Figure 2 note.

### Table 3: "Main RDD Estimates: Effect of Second-Home Construction Ban on Local Employment"
**Page:** 14
- **Formatting:** Excellent. Professional layout.
- **Clarity:** Very high. All four primary outcomes are visible at once.
- **Storytelling:** This is the "Money Table" of the paper.
- **Labeling:** Well-labeled. Standard errors in parentheses are noted.
- **Recommendation:** **KEEP AS-IS**

### Figure 3 & Figure 4: "RDD Plot: Employment Growth..." & "Log Total Employment..."
**Page:** 15-16
- **Formatting:** Standard binned scatter plots.
- **Clarity:** The fit lines (red) are clear.
- **Storytelling:** These are the visual proof of the null. However, having them on separate pages is inefficient.
- **Labeling:** Clear.
- **Recommendation:** **REVISE**
  - **Consolidate** into one Figure with Panel A (Growth) and Panel B (Log Level). This allows the reader to compare the "flow" vs "stock" results on one page.

### Figure 5: "Event-Study RDD: Year-by-Year Treatment Effects on Log Employment"
**Page:** 17
- **Formatting:** Professional. The shaded CI is clear.
- **Clarity:** High. The "flatness" of the result is obvious.
- **Storytelling:** Crucial for ruling out pre-trends and showing the persistence of the null.
- **Labeling:** The "Initiative (March 2012)" annotation is very helpful.
- **Recommendation:** **KEEP AS-IS**

### Table 4: "Covariate Balance at the 20% Threshold"
**Page:** 18
- **Formatting:** Good.
- **Clarity:** High.
- **Storytelling:** Supporting evidence for the RDD assumption. 
- **Recommendation:** **MOVE TO APPENDIX**
  - In a 25-30 page AER/QJE paper, covariate balance is often a single sentence in the text pointing to an Appendix table, unless there is a specific controversy about a variable.

### Figure 6: "Covariate Balance at the 20% Threshold" (Coefficient Plot)
**Page:** 18
- **Formatting:** Clean.
- **Clarity:** High.
- **Storytelling:** Visual version of Table 4.
- **Recommendation:** **MOVE TO APPENDIX** (Keep either the table or the figure in the appendix; both are not needed).

### Table 5: "Bandwidth Sensitivity: Employment Growth"
**Page:** 19
- **Formatting:** Professional.
- **Clarity:** Easy to read.
- **Storytelling:** Standard robustness.
- **Recommendation:** **MOVE TO APPENDIX**

### Table 6: "Robustness: Polynomial Order and Kernel Sensitivity"
**Page:** 19
- **Formatting:** Good use of Panels A and B.
- **Clarity:** Very clear.
- **Storytelling:** Essential robustness.
- **Recommendation:** **MOVE TO APPENDIX**

### Figure 7: "Bandwidth Sensitivity: Employment Growth Estimates"
**Page:** 20
- **Formatting:** High quality.
- **Clarity:** Very high.
- **Storytelling:** Visual proof of Table 5.
- **Recommendation:** **MOVE TO APPENDIX**

### Table 7 & Figure 8: "Placebo Threshold Tests"
**Page:** 21-22
- **Formatting:** Consistent.
- **Clarity:** Figure 8 is very effective at showing the 35% outlier vs the 20% null.
- **Storytelling:** Strong robustness.
- **Recommendation:** **REVISE**
  - **Consolidate** Table 7 and Figure 8 into one exhibit in the **Appendix**. Figure 8 is much more impactful than the table.

### Table 8: "Donut-Hole RDD Estimates"
**Page:** 22
- **Formatting:** Clean.
- **Clarity:** High.
- **Storytelling:** Important for ruling out manipulation very close to the 20% mark.
- **Recommendation:** **MOVE TO APPENDIX**

---

## Overall Assessment

- **Exhibit count:** 4 Main Tables, 8 Main Figures, 0 Appendix Exhibits (Current layout has everything in main text).
- **General quality:** The exhibits are technically very high quality (clear coding, professional aesthetics). However, the paper suffers from "exhibit bloat" in the main text. Top journals want the main narrative to be tight.
- **Strongest exhibits:** Table 3 (Main Results), Figure 5 (Event Study).
- **Weakest exhibits:** Table 2 (Redundant with Fig 2), Figure 6 (Redundant with Table 4).

### Missing Exhibits:
- **Map of Switzerland:** For a spatial/regional paper in a top journal, a map showing the treated vs. control municipalities (perhaps shaded by second-home share) is almost mandatory. It helps the reader understand the "Alpine vs. Lowland" divide mentioned in the text.

### Top 3 Improvements:
1.  **Aggressive Relegation to Appendix:** Move Tables 4, 5, 6, 7, 8 and Figures 6, 7, 8 to a dedicated "Online Appendix." The main text should focus on the distribution (Fig 1), validity (Fig 2), main results (Table 3), and dynamics (Fig 5).
2.  **Panel Consolidation:** Merge Figures 3 and 4 into a single two-panel figure. This reduces the page count and makes the "Null across all definitions" argument more punchy.
3.  **Add a Geographic Map:** Include a figure showing the spatial distribution of the 20% threshold. This anchors the "Institutional Background" (Section 2) in reality for international readers.