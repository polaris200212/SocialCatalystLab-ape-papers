# Exhibit Review — Gemini 3 Flash (Round 1)

**Role:** Visual exhibit advisor
**Model:** gemini-3-flash-preview (ai_studio)
**Paper:** paper.pdf
**Timestamp:** 2026-02-22T18:12:24.649678
**Route:** Direct Google API + PDF
**Tokens:** 18397 in / 2167 out
**Response SHA256:** f096a3a070aad4c6

---

# Exhibit-by-Exhibit Review

## Main Text Exhibits

### Figure 1: "India’s 2000 State Bifurcations: Treatment and Control Regions"
**Page:** 8
- **Formatting:** Clean map, but the gridlines (long/lat) are somewhat distracting and non-standard for top-tier economics journals. 
- **Clarity:** Good. The color contrast between blue and orange is distinct.
- **Storytelling:** Essential. It establishes the geography of the "natural experiment."
- **Labeling:** The legend is clear. Title is descriptive.
- **Recommendation:** **REVISE**
  - Remove the background latitude/longitude gridlines for a cleaner, more professional look. 
  - Ensure the map projection is standard (e.g., Lambert Conformal Conic for India).

### Table 1: "Summary Statistics: New State vs Parent State Districts"
**Page:** 9
- **Formatting:** Professional "booktabs" style. Number alignment is good.
- **Clarity:** Excellent. The $p$-value column immediately highlights the identification challenge (pre-treatment imbalances).
- **Storytelling:** Crucial. It justifies the move away from simple DiD toward RDD and sensitivity analysis.
- **Labeling:** Clear. Standard errors are missing, though means and $p$-values are present.
- **Recommendation:** **KEEP AS-IS**

### Table 2: "Effect of State Creation on Nightlight Intensity"
**Page:** 11
- **Formatting:** Journal-ready. Proper use of stars and parentheses for SEs.
- **Clarity:** Good. Logical progression from baseline to robust estimators.
- **Storytelling:** This is the "headline" results table. The inclusion of CS-DiD ATT and Wild Bootstrap $p$-values in the main table is excellent practice.
- **Labeling:** Detailed notes. 
- **Recommendation:** **KEEP AS-IS**

### Figure 2: "Event Studies: TWFE (Panel A) and Callaway-Sant’Anna (Panel B)"
**Page:** 12
- **Formatting:** Standard ggplot2 style. The shaded CIs are acceptable but many top journals prefer capped whisker lines for coefficients.
- **Clarity:** High. The 10-second takeaway (significant pre-trends) is unavoidable.
- **Storytelling:** Central to the paper’s honesty regarding parallel trends.
- **Labeling:** "Coefficient" vs "ATT" on y-axes is appropriate.
- **Recommendation:** **REVISE**
  - Switch from shaded ribbons to error bars (whiskers). Shaded regions can obscure the point estimates when overlapping.
  - Add a horizontal dashed line at 0 (already present, but make it darker).

### Figure 3: "Average Nightlight Intensity: New vs. Parent State Districts"
**Page:** 13
- **Formatting:** Raw data plots are very common in QJE/AER to show the "raw" variation.
- **Clarity:** The "State creation" vertical line and text are well-placed.
- **Storytelling:** Good for showing the level shift vs. the trend.
- **Labeling:** Axis labels are clear.
- **Recommendation:** **KEEP AS-IS**

### Table 3: "Border Discontinuity Design: Full Sample vs. Border Subsample"
**Page:** 14
- **Formatting:** A bit cluttered. Mixing OLS/DiD columns with a "Spatial RDD" row in the middle is unconventional.
- **Clarity:** The Spatial RDD result feels "tucked in."
- **Storytelling:** Combines two different designs (Subsample DiD and Cross-sectional RDD).
- **Recommendation:** **REVISE**
  - **Split** this exhibit. Keep Columns (1)–(5) as a table showing the sensitivity to the distance buffer. Move the "Spatial RDD" result to a dedicated table or keep it exclusively in the text/Figure 5. Mixing a cross-sectional RDD estimate into a panel DiD table is confusing for the reader.

### Figure 4: "Border DiD Event Study (Districts Within 150km of Boundary)"
**Page:** 15
- **Formatting:** Consistent with Figure 2.
- **Clarity:** Good, but the subtitle "Pre-trends should flatten..." belongs in the text or a note, not the figure title.
- **Storytelling:** Important for showing that the border restriction *partially* works.
- **Recommendation:** **REVISE**
  - Remove the subtitle from the image. 
  - Match formatting (whiskers) with Figure 2.

### Figure 5: "Spatial RDD: Nightlight Growth vs. Distance to State Boundary"
**Page:** 16
- **Formatting:** Excellent. Shows the binned means and the underlying scatter.
- **Clarity:** The jump at the boundary is visually striking.
- **Storytelling:** This is arguably the most "causal" evidence in the paper.
- **Labeling:** Title and axis labels are very strong.
- **Recommendation:** **KEEP AS-IS** (This is a "Top 5" journal quality figure).

### Table 4: "Robustness Checks"
**Page:** 17
- **Formatting:** Very condensed.
- **Clarity:** It's essentially a list of coefficients. 
- **Storytelling:** Useful, but purely supporting.
- **Recommendation:** **MOVE TO APPENDIX**
  - The main text already discusses these. A summary table like this is better suited for the appendix to save main-text "real estate" for the heterogeneity results.

### Figure 6: "Rambachan-Roth Sensitivity: Robust Confidence Intervals"
**Page:** 18
- **Formatting:** Clean.
- **Clarity:** The "breakdown" logic is clear.
- **Storytelling:** Critical for modern DiD papers where pre-trends fail.
- **Recommendation:** **KEEP AS-IS**

### Figure 7: "Placebo Permutation: Distribution of Estimates Under Random Assignment"
**Page:** 19
- **Formatting:** Simple histogram.
- **Clarity:** The blue "Actual" line is very clear.
- **Storytelling:** Good for addressing the "small number of clusters" concern.
- **Recommendation:** **KEEP AS-IS**

### Table 5: "Heterogeneous Effects by State Pair"
**Page:** 20
- **Formatting:** Clean.
- **Clarity:** High. 
- **Storytelling:** Essential. It reveals that the "average" effect is driven by 2 out of 3 states.
- **Recommendation:** **KEEP AS-IS**

### Figure 8: "Nightlight Trends by State Pair"
**Page:** 21
- **Formatting:** Multi-panel.
- **Clarity:** Small multiples are very effective here. 
- **Storytelling:** Visually confirms Table 5.
- **Recommendation:** **KEEP AS-IS**

### Figure 9: "Capital City Effect: New State Capitals vs. Other Districts"
**Page:** 22
- **Formatting:** Clear.
- **Clarity:** The divergent green line (Capitals) is the "Aha!" moment for the mechanism.
- **Storytelling:** Supports the "Administrative Agglomeration" story.
- **Recommendation:** **KEEP AS-IS**

---

## Appendix Exhibits

### Figure 10: "Long-Run Trajectories: Two Decades After State Creation"
**Page:** 32
- **Formatting:** Good use of different shapes (Circle/Triangle) for different sensors (DMSP/VIIRS).
- **Clarity:** The "DMSP->VIIRS" label is helpful.
- **Storytelling:** Shows the effect isn't just a short-term blip.
- **Recommendation:** **PROMOTE TO MAIN TEXT**
  - Given that the paper emphasizes "Two Decades" in the title, showing the full 20-year trajectory in the main text is more impactful than the 1994-2013 cut-off in Figure 3. Replace Figure 3 with Figure 10.

---

## Overall Assessment

- **Exhibit count:** 5 Tables (Main), 9 Figures (Main), 0 Tables (App), 1 Figure (App)
- **General quality:** High. The paper adopts modern DiD standards (CS-DiD, Rambachan-Roth, RDD). The figures are clean, though some (Fig 2, 4) use "out-of-the-box" ggplot2 aesthetics that could be slightly more polished.
- **Strongest exhibits:** Figure 5 (Spatial RDD), Figure 9 (Capital effects), and Table 2 (Main estimates).
- **Weakest exhibits:** Table 3 (trying to do too much by mixing RDD and DiD) and Figure 1 (unnecessary gridlines).
- **Missing exhibits:** 
    1. **A Coefficient Plot for Robustness:** Instead of the list in Table 4, a figure showing the point estimates and 95% CIs for various specifications (Dropping states, alternative weights) would be more "AER-style."
    2. **Balance Plot:** A visual version of Table 1 (Standardized Mean Differences) is often requested by reviewers to see the scale of imbalance.
- **Top 3 improvements:**
  1. **Consolidate/Split Table 3:** Move the Spatial RDD estimate out of the DiD subsample table to avoid confusing the reader on the identification strategy.
  2. **Professionalize Aesthetics:** Remove shaded CI ribbons in Figures 2 and 4 in favor of capped error bars; remove the map gridlines in Figure 1.
  3. **Re-order for Storytelling:** Swap Figure 3 for Figure 10 in the main text to emphasize the "Two Decades" contribution promised in the title.