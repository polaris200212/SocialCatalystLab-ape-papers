# Exhibit Review — Gemini 3 Flash (Round 1)

**Role:** Visual exhibit advisor
**Model:** gemini-3-flash-preview (ai_studio)
**Paper:** paper.pdf
**Timestamp:** 2026-02-26T22:04:30.893068
**Route:** Direct Google API + PDF
**Tokens:** 17877 in / 1821 out
**Response SHA256:** 744111b9099de6fd

---

# Exhibit-by-Exhibit Review

## Main Text Exhibits

### Table 1: "Summary Statistics by MGNREGA Phase"
**Page:** 8
- **Formatting:** Clean and professional. Use of horizontal rules follows standard journal style (Booktabs).
- **Clarity:** Excellent. It clearly shows the "backwardness" gradient across phases.
- **Storytelling:** Vital for establishing the identification challenge (selection on observables).
- **Labeling:** Clear. Units (mm) are included for rainfall. 
- **Recommendation:** **KEEP AS-IS**

### Table 2: "Effect of MGNREGA on District Nightlights"
**Page:** 12
- **Formatting:** Standard regression table format. Decimal alignment is good.
- **Clarity:** High. The comparison between TWFE and CS-DiD is the central methodological point of the paper.
- **Storytelling:** This is the "money" table. It shows that the choice of estimator determines whether the program is perceived as a success or a failure.
- **Labeling:** Significance stars and clustering levels are clearly defined in the notes.
- **Recommendation:** **KEEP AS-IS**

### Figure 1: "Callaway-Sant’Anna Dynamic Event Study"
**Page:** 14
- **Formatting:** Professional ggplot2-style aesthetic. The dashed vertical line for treatment onset is standard.
- **Clarity:** The message is clear but "troubling" for the author: the pre-trend is significant. The 10-second parse reveals a downward trend before $t=0$.
- **Storytelling:** Essential. It provides the honesty check required for top journals.
- **Labeling:** Y-axis "ATT" is a bit jargon-heavy; "Effect on Log Nightlights" would be more descriptive.
- **Recommendation:** **REVISE**
  - Change Y-axis label to "Effect on Log Nightlights (ATT)."
  - Add a horizontal dashed line at 0 to make the pre-treatment decline more visually obvious.

### Figure 2: "Mean Log Nightlights by MGNREGA Cohort"
**Page:** 15
- **Formatting:** High quality. Colors are distinct and markers help readability.
- **Clarity:** This "raw data" plot is helpful for understanding the levels behind the DiD estimates.
- **Storytelling:** It shows the "catch-up" or "divergence" visually.
- **Labeling:** The legend is clear.
- **Recommendation:** **KEEP AS-IS**

### Figure 3: "Heterogeneous Effects by Baseline Characteristics"
**Page:** 16
- **Formatting:** Good use of facet wrapping to show four dimensions.
- **Clarity:** A bit cluttered. The x-axis labels (High, Low, Medium) vary in order or position across panels.
- **Storytelling:** This is the core contribution of the paper. It visually confirms the "Goldilocks" result for Ag. Labor Share.
- **Labeling:** The title "ATT (Log Nightlights)" is consistent.
- **Recommendation:** **REVISE**
  - Standardize the X-axis order for all panels (e.g., always "Low, Medium, High" or "Dark, Medium, Bright") to reduce cognitive load.
  - The "Baseline Luminosity" labels "Dark, Dark, Medium" in the screenshot appear to have a typo (should be Dark, Medium, Bright).

### Table 3: "Heterogeneous Effects by Baseline District Characteristics"
**Page:** 17
- **Formatting:** Clean tabular version of Figure 3.
- **Clarity:** Logical grouping by dimension.
- **Storytelling:** Redundant with Figure 3, but necessary for the exact coefficients/SEs. In a top journal, this is often moved to the Appendix if the figure is in the main text.
- **Labeling:** Notes are comprehensive.
- **Recommendation:** **MOVE TO APPENDIX** (The figure tells the story better; the table provides the reference data).

### Table 4: "MGNREGA and Structural Transformation (Census 2001-2011)"
**Page:** 18
- **Formatting:** Consistent with previous tables.
- **Clarity:** "Phase III" is the omitted category, which is standard but should be noted in the header if possible.
- **Storytelling:** Provides the "why" (mechanisms) behind the nightlight results.
- **Labeling:** Column (1) $\Delta$ Ag. Labor is clear.
- **Recommendation:** **REVISE**
  - Add the mean of the dependent variable for the omitted category (Phase III) at the bottom of the table to help the reader interpret the magnitude of the Phase 1 and 2 coefficients.

### Figure 4: "Census Mechanism: Structural Transformation by MGNREGA Phase"
**Page:** 19
- **Formatting:** Bar charts with error bars. Standard and clean.
- **Clarity:** Very high. The "inverted U" in Ag. Labor Share change is immediately visible.
- **Storytelling:** Complements Table 4. 
- **Labeling:** "Change (2001-2011)" is clear.
- **Recommendation:** **KEEP AS-IS**

### Figure 5: "Sun-Abraham (2021) Interaction-Weighted Event Study"
**Page:** 20
- **Formatting:** Similar to Figure 1 but with a different color/confidence interval style.
- **Clarity:** The pre-trend is even more aggressive here.
- **Storytelling:** This is a robustness check for Figure 1.
- **Labeling:** Clear.
- **Recommendation:** **MOVE TO APPENDIX** (Keep only one main event study figure to maintain flow; Figure 6 already does the comparison).

### Figure 6: "TWFE vs. Callaway-Sant’Anna Event Study Comparison"
**Page:** 22
- **Formatting:** Excellent. Overlaying the two estimators is the most effective way to show why the choice of estimator matters.
- **Clarity:** High impact. The divergence at $t=0$ is the key takeaway.
- **Storytelling:** This is a candidate for the most important figure in the paper.
- **Labeling:** Legend is clear.
- **Recommendation:** **KEEP AS-IS** (Consider promoting this to Figure 1 or 2 as it summarizes the paper's methodological tension).

---

## Appendix Exhibits

### Figure 7: "Baseline Balance by MGNREGA Phase"
**Page:** 31
- **Formatting:** Standard boxplots.
- **Clarity:** Effectively visualizes the "imbalance" discussed in the text.
- **Storytelling:** Supports Table 1.
- **Labeling:** Standardized values make comparison easy across different units.
- **Recommendation:** **KEEP AS-IS**

---

## Overall Assessment

- **Exhibit count:** 4 main tables, 6 main figures, 0 appendix tables, 1 appendix figure.
- **General quality:** Extremely high. The paper follows the "Modern DiD" playbook (Callaway-Sant'Anna, Sun-Abraham) and uses visualization effectively to show the failure of TWFE.
- **Strongest exhibits:** Table 2 (Main Results) and Figure 6 (The Comparison).
- **Weakest exhibits:** Figure 3 (X-axis ordering needs consistency) and Table 3 (Redundant with Fig 3).
- **Missing exhibits:** 
    - **Map of India:** A figure showing Phase I, II, and III districts geographically is standard for this literature and missing.
    - **Coefficient Plot for Appendix:** The paper mentions "Full CS-DiD Heterogeneity" in text (Section D.1) but doesn't show the figure.

**Top 3 improvements:**
1.  **Add a map:** Visualize the treatment rollout across India. Readers need to see the spatial clustering of the "Backwardness Index."
2.  **Consolidate and Move:** Move Table 3 and Figure 5 to the Appendix. They provide robustness/detail but the main narrative is already covered by Figure 3 and Figure 6.
3.  **Standardize Heterogeneity Plots:** In Figure 3, ensure the X-axis always goes from "Low to High" or "Least to Most" across all four panels to allow for easier scanning.