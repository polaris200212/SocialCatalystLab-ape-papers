# Exhibit Review — Gemini 3 Flash (Round 1)

**Role:** Visual exhibit advisor
**Model:** gemini-3-flash-preview (ai_studio)
**Paper:** paper.pdf
**Timestamp:** 2026-02-20T08:55:30.933659
**Route:** Direct Google API + PDF
**Tokens:** 24117 in / 2193 out
**Response SHA256:** d915185373ae5d11

---

This review evaluates the visual exhibits of the paper titled **"Where Medicaid Goes Dark: A Claims-Based Atlas of Provider Deserts and the Resilience of Supply to Enrollment Shocks"** against the standards of top-tier economics journals.

---

# Exhibit-by-Exhibit Review

## Main Text Exhibits

### Figure 1: "Medicaid Unwinding Intensity by State"
**Page:** 12
- **Formatting:** High quality. The chloropleth map is clean and uses a standard projection. 
- **Clarity:** The "darker is more intense" logic is intuitive. The bins are well-chosen.
- **Storytelling:** Essential. It establishes the "treatment" variation necessary for the DiD design.
- **Labeling:** Clear. Legend is appropriately placed.
- **Recommendation:** **KEEP AS-IS**

### Table 1: "Summary Statistics by Specialty"
**Page:** 13
- **Formatting:** Professional. Uses a clear "Booktabs" style with minimal horizontal lines. Numbers are clean, though decimal alignment could be tighter in the "% Zero" and "Per 10K Pop" columns.
- **Clarity:** Very high. The transition from raw counts to population-adjusted rates is logical.
- **Storytelling:** Critical baseline. It immediately highlights the "Desert" problem mentioned in the title.
- **Labeling:** Note is comprehensive.
- **Recommendation:** **KEEP AS-IS**

### Figure 2: "Active Medicaid Clinicians by Specialty, 2018–2024"
**Page:** 14
- **Formatting:** Good use of colors. The "Unwinding begins" red line is a standard and helpful marker.
- **Clarity:** Slightly cluttered due to the number of lines, but the legend helps. The y-axis "county-quarter sum" is a bit abstract compared to a per-capita measure.
- **Storytelling:** Provides the raw time-series context. It shows the "eye-ball" null result before the regression analysis.
- **Labeling:** Clear.
- **Recommendation:** **REVISE**
  - Change the y-axis label to "Total Active Clinicians (Thousands)" and scale values (e.g., 25.0 instead of 25000) to reduce visual noise.

### Table 2: "Active Medicaid Clinicians by Specialty and Year (Mean Quarterly Count)"
**Page:** 14
- **Formatting:** Standard.
- **Clarity:** Logical. The "Change (%)" column is the most important part of this table.
- **Storytelling:** Redundant with Figure 2 and Figure 3. Top journals generally prefer the visual trend over a year-by-year table of raw counts unless the exact numbers are vital for a calibration.
- **Labeling:** Clear.
- **Recommendation:** **MOVE TO APPENDIX**

### Figure 3: "Medicaid Clinician Supply by Specialty, Indexed to 2018Q1"
**Page:** 15
- **Formatting:** Excellent. The horizontal dashed line at 100 is crucial for interpretation.
- **Clarity:** Much clearer than Figure 2 for comparing relative growth/decline across specialties.
- **Storytelling:** Very strong. It tells the "structural decline" story perfectly.
- **Labeling:** Good.
- **Recommendation:** **KEEP AS-IS** (Consider merging with Figure 2 as Panel B to save space).

### Figures 4–9: "Medicaid Provider Deserts: [Specialty], 2023Q1"
**Pages:** 16–19
- **Formatting:** Consistent and professional.
- **Clarity:** The "Zero" bin (dark red) is visually striking and effectively communicates the "Desert" concept.
- **Storytelling:** This is the "Atlas" part of the title. However, 6 full-page maps take up too much real estate for a main-text section. 
- **Labeling:** Clear.
- **Recommendation:** **REVISE**
  - Consolidate Figures 4, 5, 6, and 8 (Primary Care, Dental, Psychiatry, OB-GYN) into a single 2x2 multi-panel figure. Move Behavioral Health (Fig 7) and Surgery (Fig 9) to the Appendix. This maintains the "Atlas" impact without overwhelming the reader.

### Figures 10–11: "Primary Care Deserts: [No NP/PA vs All Clinicians]"
**Page:** 21
- **Formatting:** Consistent with previous maps.
- **Clarity:** The visual difference is clear—NP inclusion "fills in" the map.
- **Storytelling:** This is one of the paper's "key methodological contributions." It deserves high visibility.
- **Labeling:** Clear.
- **Recommendation:** **REVISE**
  - Group these into a single figure with Panel A and Panel B for direct side-by-side comparison.

### Figure 12: "Medicaid Desert Counties by Specialty: Urban vs. Rural"
**Page:** 22
- **Formatting:** Clean 2x2 grid.
- **Clarity:** High. Shows the massive gap in psychiatry/OB-GYN versus primary care.
- **Storytelling:** Important for the "Structural Factors" argument.
- **Labeling:** Legend is clear.
- **Recommendation:** **KEEP AS-IS**

### Table 3: "Percentage of County-Quarters in Desert Status, Pre vs. Post Unwinding"
**Page:** 23
- **Formatting:** Clean.
- **Clarity:** Simple 2x2-style comparison.
- **Storytelling:** Effectively previews the null result in a simple "Means" format.
- **Labeling:** Note is sufficient.
- **Recommendation:** **KEEP AS-IS**

### Table 4: "Effect of Medicaid Unwinding on Provider Supply by Specialty"
**Page:** 26
- **Formatting:** Excellent. Inclusion of "Mean Y" and "95% CI" is very helpful for interpreting nulls.
- **Clarity:** Very high.
- **Storytelling:** The core causal result of the paper.
- **Labeling:** Significance stars and clustering noted.
- **Recommendation:** **KEEP AS-IS**

### Figure 13: "Event Study: Medicaid Unwinding and Provider Supply"
**Page:** 27
- **Formatting:** Standard DiD event study plot.
- **Clarity:** Clear pre-trends and post-treatment null.
- **Storytelling:** Essential for identification verification.
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS**

### Table 5: "Robustness Checks"
**Page:** 28
- **Formatting:** Efficiently packs many specifications into one table.
- **Clarity:** High.
- **Storytelling:** Confirms the main result isn't a "fluke" of the definition or model.
- **Labeling:** Excellent note explaining the randomization inference.
- **Recommendation:** **KEEP AS-IS**

### Figure 14: "Permutation Inference: Distribution of Placebo Coefficients"
**Page:** 31
- **Formatting:** Clean histogram.
- **Clarity:** The red line for "Observed" is standard and effective.
- **Storytelling:** Strong "Gold Standard" for papers reporting null results to prove it isn't just lack of power.
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS**

---

## Appendix Exhibits

### Table 6: "Specialty Classification from NUCC Taxonomy Codes"
**Page:** 41
- **Formatting:** Dense but necessary.
- **Recommendation:** **KEEP AS-IS**

### Table 7: "State-Level Unwinding Characteristics"
**Page:** 42
- **Recommendation:** **KEEP AS-IS**

### Table 8: "Effect of Medicaid Unwinding on Provider Supply: No-NP/PA Panel"
**Page:** 43
- **Storytelling:** Important robustness check for the NP-inclusion decision.
- **Recommendation:** **KEEP AS-IS**

### Table 9: "Desert Rates: All Clinicians vs. No-NP/PA Panel"
**Page:** 43
- **Recommendation:** **KEEP AS-IS**

---

## Overall Assessment

- **Exhibit count:** 5 Main Tables (suggest 4), 14 Main Figures (suggest 6 via consolidation), 4 Appendix Tables.
- **General quality:** Extremely high. The paper follows "AER-style" aesthetics: clean white space, no gridlines, high-contrast colors, and comprehensive table notes.
- **Strongest exhibits:** Table 4 (Main Result), Figure 13 (Event Study), and Figure 14 (Permutation). These three together provide a very "tight" causal story.
- **Weakest exhibits:** Figure 2 (redundant with Fig 3) and the individual specialty maps (too much space for the information conveyed).
- **Missing exhibits:** A **Summary Statistics table of County Characteristics** (Urban vs Rural, baseline Medicaid share, etc.) would help the reader understand the "Two Americas" story being told.

### Top 3 Improvements:
1. **Consolidate Geography:** Merge the individual specialty maps (Figs 4-9) into a single 4-panel "Overview of Deserts" figure. This prevents "map fatigue" and forces the reader to see the cross-specialty disparity.
2. **Side-by-Side NP Impact:** Place the "No-NP" and "All Clinicians" maps (Figs 10-11) as Panels A and B of a single figure. This makes the "NP-fill-in" effect much more visually obvious.
3. **Streamline Descriptive Trends:** Merge Figure 2 and Figure 3. Use raw counts (Fig 2) as Panel A and the Index (Fig 3) as Panel B. This allows the reader to see both the scale and the relative trend simultaneously.