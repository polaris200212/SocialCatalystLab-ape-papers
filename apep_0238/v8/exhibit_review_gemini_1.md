# Exhibit Review — Gemini 3 Flash (Round 1)

**Role:** Visual exhibit advisor
**Model:** gemini-3-flash-preview (ai_studio)
**Paper:** paper.pdf
**Timestamp:** 2026-02-26T02:36:23.193868
**Route:** Direct Google API + PDF
**Tokens:** 39197 in / 2270 out
**Response SHA256:** 64cca660f2d129e6

---

This review evaluates the visual exhibits of "Demand Recessions Scar, Supply Recessions Don’t" based on the standards of top-tier economics journals (AER, QJE, JPE).

# Exhibit-by-Exhibit Review

## Main Text Exhibits

### Table 1: "Summary Statistics"
**Page:** 14
- **Formatting:** Professional. Clear panel structure. Standard booktabs lines used.
- **Clarity:** Excellent. Logic flows from general outcomes to specific exposure measures.
- **Storytelling:** Essential. Establishes the cross-state variation that identifies the paper.
- **Labeling:** Clear. Units (thousands, %, log) are all present.
- **Recommendation:** **KEEP AS-IS**

### Table 2: "Bartik Decomposition: Rotemberg Weights by Industry"
**Page:** 18
- **Formatting:** Clean. Includes a "Leave-one-out" sub-panel which is standard for Bartik papers in top journals.
- **Clarity:** Good. It quickly identifies Leisure & Hospitality as the primary driver.
- **Storytelling:** Strong. Addresses the "black box" of the Bartik instrument immediately.
- **Labeling:** Definitions of $h$ and $\hat{\pi}_h$ are clear in the notes.
- **Recommendation:** **KEEP AS-IS**

### Table 3: "Local Projection Estimates: Employment Response to Recession Exposure"
**Page:** 21
- **Formatting:** Journal-ready. Decimal-aligned coefficients. Multiple inference rows (SE, p-values, bootstrap) are handled with distinct brackets/braces.
- **Clarity:** Slightly cluttered due to four rows of inference statistics per coefficient.
- **Storytelling:** This is the "Money Table." It perfectly captures the asymmetry (persistence in Panel A, recovery in Panel B).
- **Labeling:** Notes are exhaustive. Significance stars are well-defined.
- **Recommendation:** **REVISE**
  - **Change:** Consider moving the Wild Cluster Bootstrap (curly braces) or Permutation p-values (brackets) to an appendix version to improve whitespace, keeping only the most robust one (Wild Cluster) in the main text.

### Figure 1: "First Stage: Saiz Housing Supply Elasticity vs. Housing Price Boom"
**Page:** 23
- **Formatting:** Standard scatter with fit.
- **Clarity:** High. State abbreviations help identify outliers (NV, AZ).
- **Storytelling:** Validates the instrument for the demand shock.
- **Labeling:** Axis labels are clear. Regression stats (Slope, r) are helpful inside the plot.
- **Recommendation:** **KEEP AS-IS**

### Table 4: "Instrumental Variable Estimates: Saiz Housing Supply Elasticity"
**Page:** 23
- **Formatting:** Clean. Logic follows Table 3.
- **Clarity:** High.
- **Storytelling:** Crucial robustness for the Great Recession results.
- **Labeling:** AR 95% CI is a professional touch for weak-instrument robustness.
- **Recommendation:** **KEEP AS-IS**

### Table 5: "Within–Great Recession Horse Race: Housing Demand vs. Industry Composition"
**Page:** 24
- **Formatting:** Consistent with prior tables.
- **Clarity:** Clear "Horse Race" layout.
- **Storytelling:** Directly addresses the most likely "confounder" (sectoral shocks in 2008).
- **Labeling:** VIF is a helpful addition.
- **Recommendation:** **KEEP AS-IS**

### Table 6: "Employment Persistence: Half-Lives and Recovery Measures"
**Page:** 25
- **Formatting:** Summary table style.
- **Clarity:** High. Excellent at distilling complex LP results into digestible "summary" numbers.
- **Storytelling:** Great "bridge" between reduced-form and structural sections.
- **Recommendation:** **KEEP AS-IS**

### Figure 2: "Local Projection Impulse Response Functions: Employment"
**Page:** 26
- **Formatting:** High quality. Shaded CIs are professional.
- **Clarity:** High. The 10-second test: The asymmetry is immediately obvious.
- **Storytelling:** This is the most important figure in the paper.
- **Labeling:** Legend and axis units are correct.
- **Recommendation:** **KEEP AS-IS**

### Figure 3: "Peak-to-Trough Employment Declines by State"
**Page:** 27
- **Formatting:** Tile maps (square bins) are used instead of geographical maps. This is modern and preferred as it gives equal visual weight to small NE states.
- **Clarity:** High. Color scale is intuitive (Red = Loss).
- **Storytelling:** Shows the different "geographies" of the two recessions.
- **Recommendation:** **KEEP AS-IS**

### Figure 4: "JOLTS Labor Market Flows: Great Recession vs. COVID"
**Page:** 29
- **Formatting:** 2x2 grid. Clean time-series lines.
- **Clarity:** Good. Shaded recession bars are standard.
- **Storytelling:** Provides the "macro" context for why the state-level results occur.
- **Recommendation:** **KEEP AS-IS**

### Table 7: "Mechanism Test: Unemployment Rate Persistence by Recession Type"
**Page:** 30
- **Formatting:** Consistent.
- **Clarity:** High.
- **Storytelling:** Tests the "Mechanism" (Unemployment persistence) directly.
- **Recommendation:** **KEEP AS-IS**

### Figure 5: "Mechanism Flow: Demand vs. Supply Recession Pathways"
**Page:** 31
- **Formatting:** Simple flowchart. 
- **Clarity:** High.
- **Storytelling:** While helpful for a presentation, top-tier journals often find these too "textbook-like."
- **Recommendation:** **MOVE TO APPENDIX** or integrate into a "Conceptual Framework" figure if one is added.

### Table 8: "Model Parameters"
**Page:** 33
- **Formatting:** Large, detailed table.
- **Clarity:** High. Separation of calibrated vs. estimated parameters is essential.
- **Storytelling:** Documenting the "Simulated Method of Moments" (SMM) logic.
- **Recommendation:** **KEEP AS-IS**

### Table 9: "Simulated Method of Moments: Target Moments and Model Fit"
**Page:** 35
- **Formatting:** Standard structural macro table.
- **Clarity:** High. The "Difference" column is helpful for judging fit.
- **Recommendation:** **KEEP AS-IS**

### Figure 6: "Model vs. Data: Employment Paths After Demand and Supply Shocks"
**Page:** 37
- **Formatting:** Overlay of data (markers) and model (lines).
- **Clarity:** High.
- **Storytelling:** This is the "Success" figure for the structural model.
- **Recommendation:** **KEEP AS-IS**

### Figure 7: "Counterfactual Employment Paths"
**Page:** 38
- **Formatting:** Multi-line plot. 
- **Clarity:** A bit cluttered. The difference between "dotted" and "dashed" blue lines is hard to see.
- **Storytelling:** Decomposes the "why."
- **Recommendation:** **REVISE**
  - **Change:** Increase line thickness. Use more distinct colors (e.g., Orange/Purple) for the two counterfactual channels rather than just shades/styles of Blue.

### Table 10: "Welfare Losses from Demand vs. Supply Shocks"
**Page:** 39
- **Formatting:** Clean summary.
- **Clarity:** High.
- **Storytelling:** The final "punchline" of the paper (71:1 ratio).
- **Recommendation:** **KEEP AS-IS**

### Figure 8: "Permutation Inference: p-Values Across Horizons"
**Page:** 40
- **Formatting:** Bar chart for p-values.
- **Clarity:** Very high.
- **Storytelling:** Robustness check for Table 3.
- **Recommendation:** **MOVE TO APPENDIX** (This is a diagnostic; Figure 2 already shows the main result with CIs).

---

## Appendix Exhibits (Selected High-Impact)

### Figure 10: "Aggregate Employment Paths..." (Page 59)
- **Recommendation:** **KEEP IN APPENDIX**. Good for reference but redundant with Figure 4.

### Table 13: "LP Estimates: Unemployment Rate Response (Appendix)" (Page 61)
- **Recommendation:** **REVISE**. The "raw Bartik" coefficients in Panel B (65.38) look "exploded" and may confuse readers.
- **Fix:** Report only the "Per 1-SD" row as the main coefficients.

### Figure 13: "Recovery Speed Maps" (Page 63)
- **Recommendation:** **PROMOTE TO MAIN TEXT**. This is a very strong visual showing that *all* COVID states recovered fast, while GR recovery was heterogeneous. This "uniformity of recovery" is a powerful argument.

---

## Overall Assessment

- **Exhibit count:** 7 Main Tables, 7 Main Figures, 5 Appendix Tables, 6 Appendix Figures.
- **General quality:** Extremely high. The use of modern "Tile Maps," local projection IRFs, and a clear bridge between reduced-form and structural tables makes it very "QJE/AER-ready."
- **Strongest exhibits:** Figure 2 (The IRF contrast) and Table 3 (The main LP result).
- **Weakest exhibits:** Figure 7 (Visual overlap of counterfactual lines) and Figure 5 (Too simplified for main text).

### Top 3 Improvements:
1.  **Declutter Table 3:** Move some of the inference rows (like permutation p-values) to an appendix version so the main table "breathes" more.
2.  **Visual Distinction in Figure 7:** Use color, not just line-style, to distinguish the "No Scarring" and "No OLF" channels.
3.  **Promote Figure 13:** Move the Recovery Speed Maps to the main results section (near Figure 3) to show the uniformity of the COVID recovery versus the "drag" of the Great Recession.