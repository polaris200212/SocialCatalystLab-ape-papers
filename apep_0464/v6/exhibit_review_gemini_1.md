# Exhibit Review — Gemini 3 Flash (Round 1)

**Role:** Visual exhibit advisor
**Model:** gemini-3-flash-preview (ai_studio)
**Paper:** paper.pdf
**Timestamp:** 2026-02-27T17:31:42.564665
**Route:** Direct Google API + PDF
**Tokens:** 27757 in / 2383 out
**Response SHA256:** d9642c185e703b4b

---

# Exhibit-by-Exhibit Review

## Main Text Exhibits

### Figure 1: "Fuel Vulnerability by Département"
**Page:** 8
- **Formatting:** Clean map layout. The viridis-style color scale is appropriate for accessibility and grayscale printing.
- **Clarity:** The geographic message (high vulnerability in central France) is clear. However, the legend title "tCO2e / worker / year" is a bit small.
- **Storytelling:** Essential. It establishes the "shift" in the shift-share design.
- **Labeling:** Legend is clear, but the map would benefit from a small scale bar or a north arrow, though not strictly required for top journals.
- **Recommendation:** **KEEP AS-IS**

### Figure 2: "Network Fuel Exposure by Département"
**Page:** 9
- **Formatting:** Consistent with Figure 1.
- **Clarity:** Very high. The contrast between this and Figure 1 (showing how networks smooth out the exposure) is the core visual intuition of the paper.
- **Storytelling:** Crucial. This is the visual representation of the main regressor.
- **Labeling:** Good.
- **Recommendation:** **KEEP AS-IS**

### Table 1: "Summary Statistics"
**Page:** 11
- **Formatting:** Standard academic format. Decimal points are mostly aligned, though the SD column could be tighter.
- **Clarity:** Simple and readable. 
- **Storytelling:** Important for scale. It clarifies that "Network fuel exposure" has very low variance (SD 0.02) compared to the outcome.
- **Labeling:** Note is comprehensive.
- **Recommendation:** **REVISE**
  - Increase decimal precision for the "Network fuel exposure (raw)" SD and Min/Max columns. Currently, 0.02 SD with a range of 0.64–0.82 feels under-reported; three or four decimal places would help since the regression results depend on these small variations.

### Table 2: "Département-Level Results (Primary Specification)"
**Page:** 15
- **Formatting:** Professional. Good use of horizontal rules. Numbers are well-aligned.
- **Clarity:** The column headers (D1-D4) are helpful, but "Pop-weighted" should be more prominently marked as the preferred specification.
- **Storytelling:** This is the "Headline" table. 
- **Labeling:** Excellent notes. 
- **Recommendation:** **KEEP AS-IS**

### Table 3: "Horse-Race: Network Fuel Exposure vs. Network Immigration Exposure"
**Page:** 17
- **Formatting:** Journal-ready.
- **Clarity:** The transition from column (A) to (C) clearly shows the attenuation.
- **Storytelling:** This is the most "intellectually honest" part of the paper, addressing the bundling of shocks.
- **Labeling:** "RN Vote Share (pp)" clearly indicates the unit.
- **Recommendation:** **KEEP AS-IS**

### Table 4: "Timing Decomposition: Carbon Tax Era vs. Post-Gilets Jaunes"
**Page:** 18
- **Formatting:** Weakest in the main text. The variable names (e.g., `own_fuel_std × post_carbon_only`) are raw code output, not publication-quality labels.
- **Clarity:** Harder to read than Tables 2 and 3 due to the long, underscored variable names.
- **Storytelling:** Important for the "signal vs. magnitude" argument.
- **Labeling:** Needs "clean" variable names.
- **Recommendation:** **REVISE**
  - Rename variables to "Own Exposure $\times$ 2014–2017", "Network Exposure $\times$ 2014–2017", etc.
  - Remove underscores.
  - Align the "dept_code" and "id_election" fixed effects labels with the style in Table 2.

### Figure 3: "Event Study: Network Fuel Exposure and Rassemblement National Vote Share"
**Page:** 20
- **Formatting:** High quality. The use of a shaded background for the post-treatment period is a standard, effective "QJE-style" touch.
- **Clarity:** Excellent. The two panels allow for a side-by-side comparison of direct vs. network effects.
- **Storytelling:** This is the "money shot" of the paper, showing the sharp break in 2014.
- **Labeling:** "Coefficient (pp RN share)" is a bit wordy for a y-axis; "Effect on RN Vote Share (pp)" is more standard.
- **Recommendation:** **REVISE**
  - Increase the font size of the x-axis years (2002, 2004, etc.). They are currently quite small relative to the title.

### Figure 4: "RN Vote Share Trajectory by Fuel Vulnerability Quartile"
**Page:** 21
- **Formatting:** Clean. Colors are distinguishable.
- **Clarity:** Very high. This is the "raw data" version of the event study.
- **Storytelling:** Excellent. It grounds the complex shift-share in a simple descriptive divergence.
- **Labeling:** Good.
- **Recommendation:** **KEEP AS-IS**

### Table 5: "Spatial Model Comparison"
**Page:** 23
- **Formatting:** Professional.
- **Clarity:** The juxtaposition of SAR, SEM, and SDM is a standard way to present spatial diagnostics.
- **Storytelling:** Technical but necessary for the "multiplier" argument.
- **Labeling:** Good.
- **Recommendation:** **KEEP AS-IS**

### Table 6: "Robustness Checks (Département-Level)"
**Page:** 26
- **Formatting:** Efficient use of a "one row per regression" layout.
- **Clarity:** Allows the reader to scan many specifications quickly.
- **Storytelling:** Demonstrates the results aren't driven by specific samples or outliers.
- **Labeling:** Notes describe each check well.
- **Recommendation:** **KEEP AS-IS**

### Table 7: "Inference Comparison: Network × Post Coefficient (Département-Level)"
**Page:** 28
- **Formatting:** Clean.
- **Clarity:** Very high. It’s rare to see 9 different inference methods presented so clearly.
- **Storytelling:** Essential for modern shift-share papers (Adão et al. 2019 compliance).
- **Labeling:** Good.
- **Recommendation:** **KEEP AS-IS**

### Table 8: "Randomization Inference: Network Fuel Exposure Coefficient"
**Page:** 29
- **Formatting:** Redundant.
- **Clarity:** Clear, but repeats data already in Table 7.
- **Storytelling:** Does not add new information; Table 7 already covers RI.
- **Recommendation:** **REMOVE** (Redundant with Table 7).

### Figure 5: "Network Effect by Distance Bin"
**Page:** 32
- **Formatting:** Bar chart is appropriate here.
- **Clarity:** The non-monotonicity is immediately apparent.
- **Storytelling:** Vital for the "social vs. geographic" mechanism.
- **Labeling:** Good.
- **Recommendation:** **KEEP AS-IS**

### Figure 6: "Rotemberg Weights vs. Fuel Vulnerability Shifts"
**Page:** 34
- **Formatting:** Standard diagnostic plot for Bartik/Shift-share papers.
- **Clarity:** Clear identification of the influential observations (2A, 2B).
- **Storytelling:** Reassures the reader that the results aren't driven by a single department.
- **Labeling:** Good.
- **Recommendation:** **KEEP AS-IS**

### Table 9: "Pre-Trend-Adjusted Specification"
**Page:** 35
- **Formatting:** Standard.
- **Clarity:** Clearly labels the new "Trend" variables.
- **Storytelling:** Conservative "lower bound" estimate.
- **Recommendation:** **KEEP AS-IS**

### Figure 7: "HonestDiD Sensitivity: Robust Confidence Intervals Under Pre-Trend Violations"
**Page:** 38
- **Formatting:** Modern. 
- **Clarity:** The $x$-axis ($\bar{M}$) is a bit abstract for a non-technical reader, but standard for this methodology.
- **Storytelling:** Shows how much pre-trend the result can "swallow."
- **Labeling:** Good.
- **Recommendation:** **KEEP AS-IS**

---

## Appendix Exhibits

### Table A1: "Elections in the Panel"
**Page:** 45
- **Recommendation:** **KEEP AS-IS** (Useful reference).

### Figure A1: "SCI-Based vs. Migration-Based Network Exposure"
**Page:** 48
- **Recommendation:** **KEEP AS-IS** (Validation of the main regressor).

### Table A2: "Commune-Level Results (Ancillary)"
**Page:** 49
- **Recommendation:** **KEEP AS-IS** (Shows consistency at the 37k observation level).

### Table A3: "Controls Sensitivity: Network Coefficient Across Specifications"
**Page:** 50
- **Recommendation:** **KEEP AS-IS** (Standard "peeling the onion" table).

---

## Overall Assessment

- **Exhibit count:** 8 main tables (post-removal of T8), 7 main figures, 2 appendix tables, 1 appendix figure.
- **General quality:** Extremely high. This paper follows the "Stroebel/Bailey" visual style (clean maps, event studies with shaded post-periods, and comprehensive inference tables) which is very successful in top journals.
- **Strongest exhibits:** Figure 3 (Event Study) and Table 3 (Horse-Race). They perfectly capture the "What" and the "Why."
- **Weakest exhibits:** Table 4 (Raw code variable names) and Table 8 (Redundancy).
- **Missing exhibits:** A **"Figure 0" or Figure A0 schematic** illustrating the network logic (e.g., a toy diagram of three departments: one vulnerable, one connected, one not) would help readers conceptualize the shift-share mechanism before diving into the maps.

### Top 3 improvements:
1.  **Clean Table 4:** Replace raw variable names (`network_fuel_std`) with publication-quality labels.
2.  **Prune Redundancy:** Remove Table 8; its information is already integrated into the excellent Table 7.
3.  **Precision in Summary Stats:** Increase decimal places for the Network Exposure variable in Table 1 to show the underlying variation more clearly.