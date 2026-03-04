# Exhibit Review — Gemini 3 Flash (Round 1)

**Role:** Visual exhibit advisor
**Model:** gemini-3-flash-preview (ai_studio)
**Paper:** paper.pdf
**Timestamp:** 2026-03-04T01:29:56.478020
**Route:** Direct Google API + PDF
**Tokens:** 28277 in / 1691 out
**Response SHA256:** 63abfaa9c880f12f

---

# Exhibit-by-Exhibit Review

This review evaluates the exhibits for "Friends in High Places: Minimum Wage Shocks and Social Network Propagation." The paper sets a high bar for visual clarity, particularly with its mapping and event study designs, which are central to the SCI literature.

## Main Text Exhibits

### Figure 1: "Population-Weighted Network Minimum Wage Exposure by County"
**Page:** 12
- **Formatting:** Professional. The color ramp (Magma-style) is standard for spatial economics and prints well in grayscale.
- **Clarity:** Excellent. The key message—within-state variation in exposure—is immediately apparent.
- **Storytelling:** Essential. It justifies the shift-share approach by showing that even within $7.25 states (like Texas), there is significant variation in network "shock" intensity.
- **Labeling:** Legend is clear; units are in dollars. 
- **Recommendation:** **KEEP AS-IS**

### Figure 2: "Population-Weighted Minus Probability-Weighted Exposure Gap"
**Page:** 13
- **Formatting:** High quality. Diverging color scheme (Blue-Red) is appropriate for a "gap" measure.
- **Clarity:** High. Clearly shows that the "California corridor" is where the author's new weighting scheme deviates most from the literature.
- **Storytelling:** Crucial for the paper's secondary contribution (methodological innovation on weighting).
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS**

### Figure 3: "Within-State Residual Variation in the Instrumental Variable"
**Page:** 14
- **Formatting:** Two-panel map structure is clean. 
- **Clarity:** Slightly cluttered due to the number of small county polygons. The contrast between Panel A and B is the "story," and it is visible.
- **Storytelling:** This is a "First Stage/Identification" exhibit. It effectively shows that the variation isn't just geographic noise but persists even when restricting to distant connections.
- **Labeling:** "Residual IV" is a technical term; ensures the reader knows these aren't raw dollars.
- **Recommendation:** **KEEP AS-IS**

### Table 1: "Network Minimum Wage Exposure and Local Labor Market Outcomes"
**Page:** 35
- **Formatting:** Standard AER/QJE style. No vertical lines, clear grouping. Numbers are decimal-aligned.
- **Clarity:** The table is dense (6 columns, 2 panels, multiple sub-rows). It takes more than 10 seconds to parse the "monotonicity" message without the notes.
- **Storytelling:** This is the "Everything Table." It groups the main OLS, 2SLS, and distance tests.
- **Labeling:** Standard errors in parentheses, stars defined. 
- **Recommendation:** **REVISE**
  - **Specific Changes:** The distance thresholds ($\ge$200km, etc.) are the most important part of the paper's credibility. Highlight columns (2) through (5) with a slight background tint or a spanning header labeled "Distance-Restricted Instruments" to help the reader see the coefficient climb.

### Table 2: "USD-Denominated Specifications: 2SLS Estimates"
**Page:** 36
- **Formatting:** Clean and professional.
- **Clarity:** Very high. This provides the "headline" numbers ($1 increase = 3.4% earnings increase).
- **Storytelling:** Essential for economic magnitude interpretation.
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS**

### Table 3: "Balance Tests: Pre-Period Characteristics by IV Quartile"
**Page:** 36
- **Formatting:** Journal-ready.
- **Clarity:** Good. It highlights the $p=0.004$ imbalance in employment levels, which the author addresses in the text.
- **Storytelling:** Necessary "hygiene" table for a shift-share paper.
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS**

### Figure 6: "Event Study: Employment Response to Network Exposure"
**Page:** 37
- **Formatting:** Modern ggplot2-style with shaded 95% CIs. 
- **Clarity:** High. The vertical dotted line for "Fight for $15 begins" is a helpful anchor.
- **Storytelling:** This is the primary evidence for the parallel trends assumption.
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS**

### Figure 4: "First Stage: Out-of-State vs. Full Network Exposure" (Binscatter)
**Page:** 18
- **Formatting:** Excellent. Shows the raw data underlying the IV.
- **Clarity:** Very high.
- **Storytelling:** Establishes the strength of the instrument visually.
- **Recommendation:** **KEEP AS-IS**

### Figure 5: "Distance-Credibility Tradeoff"
**Page:** 20
- **Formatting:** Dual-axis plot.
- **Clarity:** Dual axes are often discouraged by editors, but here it is necessary to show the crossing of "Strength" and "Exogeneity."
- **Storytelling:** Unique and powerful way to visualize the "sweet spot" of the instrument (100–250km).
- **Recommendation:** **KEEP AS-IS**

---

## Appendix Exhibits

### Table 5: "Job Flow Mechanism: Effects of Network Exposure on Labor Market Dynamics"
**Page:** 40
- **Storytelling:** This is currently in the appendix but contains the "Mechanism" evidence (Churn vs. Net Growth). 
- **Recommendation:** **PROMOTE TO MAIN TEXT**. This table is the "smoking gun" for the information channel over the migration/demand channel.

### Figure 10: "Heterogeneity by Census Division" (Forest Plot)
**Page:** 43
- **Clarity:** High.
- **Storytelling:** Essential for showing that the effect is driven by low-wage regions (South).
- **Recommendation:** **PROMOTE TO MAIN TEXT**. It provides the strongest intuition for *why* the effect exists.

### Table 8: "Distance-Credibility Analysis"
**Page:** 46
- **Recommendation:** **KEEP IN APPENDIX**. Redundant with Table 1 but provides the raw N.

---

## Overall Assessment

- **Exhibit count:** 3 main tables, 6 main figures, 10 appendix tables, 1 appendix figure.
- **General quality:** Extremely high. The paper follows the "Bailey/Stroebel" visual style (maps + binscatters), which is currently very successful in top-5 journals.
- **Strongest exhibits:** Figure 5 (Tradeoff plot) and Figure 1 (Exposure map).
- **Weakest exhibits:** Table 1 is slightly over-compressed. 
- **Missing exhibits:** A **Summary Statistics table** (Means, SDs, Min, Max) for all primary variables is missing. Table 3 (Balance) only shows means by quartile; a full descriptive table is standard.

### Top 3 Improvements:
1.  **Consolidate Mechanisms:** Move Table 5 (Job Flows) and Figure 10 (Geography Heterogeneity) to the main text. They are not "robustness"; they are the "story."
2.  **Add Summary Statistics:** Create a standard Table 1 that shows the mean and variance of Network MW, Earnings, Employment, and the SCI weights.
3.  **Table 1 Formatting:** In the main results table, use a grouped header to clearly distinguish between the "Baseline" result and the "Distance Sensitivity" results. This prevents the reader from getting lost in the 6-column layout.