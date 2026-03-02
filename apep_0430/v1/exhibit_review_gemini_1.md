# Exhibit Review — Gemini 3 Flash (Round 1)

**Role:** Visual exhibit advisor
**Model:** gemini-3-flash-preview (ai_studio)
**Paper:** paper.pdf
**Timestamp:** 2026-02-20T21:15:18.347260
**Route:** Direct Google API + PDF
**Tokens:** 18397 in / 1912 out
**Response SHA256:** d0d3f2ac3391b0b9

---

This review evaluates the visual exhibits of the paper "Does Workfare Catalyze Long-Run Development? Fifteen-Year Evidence from India’s Employment Guarantee" against the standards of top-tier economics journals (AER, QJE, etc.).

# Exhibit-by-Exhibit Review

## Main Text Exhibits

### Table 1: "Summary Statistics by MGNREGA Phase"
**Page:** 11
- **Formatting:** Professional and clean. Use of Panel A and B is appropriate.
- **Clarity:** Excellent. It clearly shows the "backwardness" gradient across phases.
- **Storytelling:** Vital for establishing the identification challenge (non-random assignment).
- **Labeling:** Clear. Units (thousands, log points) are well-noted.
- **Recommendation:** **KEEP AS-IS**

### Table 2: "Effect of MGNREGA on Nighttime Luminosity"
**Page:** 14
- **Formatting:** Good use of checkmarks for fixed effects. Numbers are reasonably aligned.
- **Clarity:** "Within $R^2$" is a nice touch for panel data.
- **Storytelling:** This is the "money table." It successfully shows how the result changes from null (TWFE) to positive (State-Year FE).
- **Labeling:** The note is a bit long; some of that info (Phase dates) belongs in the text.
- **Recommendation:** **REVISE**
  - **Change:** Decimal-align all coefficients and standard errors. Currently, the parentheses and stars cause ragged alignment.
  - **Change:** Define the Callaway-Sant’Anna (CS) result more prominently. Perhaps add a "Column 5" for the CS point estimate to allow direct comparison with TWFE in the same table, rather than just putting it in the note.

### Figure 1: "Dynamic Treatment Effects: Callaway-Sant’Anna Estimator"
**Page:** 15
- **Formatting:** Clean, modern "ggplot2" style.
- **Clarity:** The pre-trend coefficients clearly show the identification problem mentioned in the text.
- **Storytelling:** High impact. It visualizes the transition from pre-treatment to treatment.
- **Labeling:** Y-axis label is good. The note clarifies the confidence intervals.
- **Recommendation:** **REVISE**
  - **Change:** The vertical dashed line is at period -0.5. It should be at -1 (the omitted period) to be standard.
  - **Change:** Add a horizontal line at $y=0$ (it exists but is faint) to make the pre-trend violations more obvious.

### Figure 2: "Cohort-Specific Average Treatment Effects"
**Page:** 16
- **Formatting:** Good use of color to distinguish Phase I and II.
- **Clarity:** Sparse but effective.
- **Storytelling:** This is a "diagnostic" figure. It explains *why* the aggregated effect might be weird.
- **Recommendation:** **KEEP AS-IS** (Though it could be a panel in Figure 1).

### Figure 3: "Nighttime Luminosity by MGNREGA Phase, 1994–2023"
**Page:** 17
- **Formatting:** The DMSP...VIIRS transition is clearly marked.
- **Clarity:** A bit cluttered with three lines and three confidence ribbons.
- **Storytelling:** Essential "raw data" plot. It shows the massive upward trend in India and the catch-up of Phase I.
- **Labeling:** Legend is clear.
- **Recommendation:** **REVISE**
  - **Change:** The confidence ribbons overlap too much, creating a muddy gray/brown color. Use lighter transparency (alpha) or use dashed/dotted lines for the phases instead of solid colors for all.

### Figure 4: "Heterogeneous Treatment Effects by Baseline Characteristics"
**Page:** 18
- **Formatting:** Good two-panel structure.
- **Clarity:** The contrast between the Agricultural Labor panel and the SC/ST panel is immediately obvious.
- **Storytelling:** Strong. It supports the "structural transformation" narrative.
- **Recommendation:** **KEEP AS-IS**

### Figure 5: "Goodman-Bacon Decomposition of TWFE Estimate"
**Page:** 19
- **Formatting:** Standard for modern DiD papers.
- **Clarity:** Clearly shows the "Later vs Earlier" (blue dots) pulling the estimate down.
- **Storytelling:** Purely methodological, but necessary given the TWFE null result.
- **Recommendation:** **MOVE TO APPENDIX**
  - **Reason:** While interesting, Table 2 and Figure 1 already tell the story that TWFE is biased. This is a "mechanics" figure that takes up a lot of main text real estate.

### Table 3: "Robustness Checks"
**Page:** 20
- **Formatting:** The "event_time" labels are very "raw code" (underscores).
- **Clarity:** Extremely long list of coefficients for a robustness table. 
- **Storytelling:** It tries to do too much (DMSP-only event study vs. VIIRS-only vs. Placebo).
- **Recommendation:** **REVISE / SPLIT**
  - **Change:** Rename "event_time = -12" to "t - 12" for a journal look.
  - **Change:** The DMSP event study (Col 1) is so long it pushes the key Placebo and Phase I/III results to the bottom. **Split Column 1 into its own Figure** (it's an event study, it should be a plot) and keep Columns 2-4 as a shorter table.

### Figure 6: "Randomization Inference: Distribution of Permuted Coefficients"
**Page:** 21
- **Formatting:** Professional.
- **Clarity:** The "Actual" line vs. the distribution is very clear.
- **Storytelling:** Confirms the TWFE result is noise.
- **Recommendation:** **MOVE TO APPENDIX**
  - **Reason:** The paper's primary contribution is the 15-year CS result. Proving the "bad" estimator is "bad" via RI is a secondary robustness step.

---

## Appendix Exhibits

### Figure 7: "Sensor Comparison in the 2012–2013 Overlap Period"
**Page:** 30
- **Formatting:** Excellent.
- **Clarity:** Shows the level-shift between DMSP and VIIRS.
- **Recommendation:** **KEEP AS-IS**

### Figure 8: "Sun-Abraham Event Study"
**Page:** 31
- **Formatting:** Looks like base R graphics. Not consistent with the "ggplot" style of Figures 1-6.
- **Clarity:** The y-axis and x-axis labels are standard.
- **Storytelling:** Confirms the CS result with a different estimator.
- **Recommendation:** **REVISE**
  - **Change:** Re-plot using the same aesthetic style (fonts/colors) as Figure 1 to ensure a "unified" paper feel.

### Table 4: "Heterogeneous Treatment Effects by Baseline Characteristics"
**Page:** 33
- **Formatting:** The column headers (SC/ST Q1, etc.) are a bit cramped. 
- **Clarity:** Logical layout.
- **Recommendation:** **KEEP AS-IS**

---

## Overall Assessment

- **Exhibit count:** 3 main tables, 6 main figures, 1 appendix table, 2 appendix figures.
- **General quality:** High. The paper adopts modern "staggered DiD" visualization standards (Bacon plots, event studies).
- **Strongest exhibits:** Table 1 (Summary Stats) and Figure 4 (Heterogeneity).
- **Weakest exhibits:** Table 3 (Too long/messy) and Figure 8 (Inconsistent style).
- **Missing exhibits:** A **Map of India** showing the Phase I, II, and III districts would be standard for a development paper and help readers visualize the "backwardness" geography.

### Top 3 Improvements:
1.  **Consolidate the "Bias" Story:** Move Figure 5 (Bacon) and Figure 6 (RI) to the appendix. They are "diagnostics" that confirm why the old method failed; keep the main text focused on the new results.
2.  **Professionalize Table 3:** Remove the underscores from variable names (e.g., `event_time`) and turn the DMSP event study into a figure. 
3.  **Aesthetic Consistency:** Ensure Figure 8 (Appendix) matches the visual theme of Figure 1. Top journals look for a "branded" feel across all visuals.