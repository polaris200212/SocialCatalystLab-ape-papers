# Exhibit Review — Gemini 3 Flash (Round 1)

**Role:** Visual exhibit advisor
**Model:** gemini-3-flash-preview (ai_studio)
**Paper:** paper.pdf
**Timestamp:** 2026-02-25T12:54:03.739863
**Route:** Direct Google API + PDF
**Tokens:** 18397 in / 1692 out
**Response SHA256:** 3c748b88fb892cd0

---

This review evaluates the exhibits of the paper "Choking the Supply, Signing the Treaty" for submission to top-tier economics journals.

# Exhibit-by-Exhibit Review

## Main Text Exhibits

### Table 1: "Summary Statistics"
**Page:** 9
- **Formatting:** Generally professional. Use of panels (A, B, C) is excellent for grouping.
- **Clarity:** High. Clear distinction between outcomes and country characteristics.
- **Storytelling:** Essential. Sets the stage for the enormous variance in mercury trade ($103k mean vs $443k SD), justifying the log transformations used later.
- **Labeling:** Good. "Mercury share (pre-ban)" clearly defined in notes.
- **Recommendation:** **KEEP AS-IS**

### Table 2: "Effect of EU Mercury Export Ban on African Mercury Imports"
**Page:** 13
- **Formatting:** Standard AER style. Numbers are clearly presented.
- **Clarity:** The "Outcome" and "Controls" rows at the bottom help navigate the specifications quickly.
- **Storytelling:** This is the primary result table for Design 1. Including the placebo (Log Fert) in column 5 is a strong rhetorical move to include in the main results.
- **Labeling:** Clear. Significance stars are defined.
- **Recommendation:** **REVISE**
  - **Change:** Decimal-align the coefficients and standard errors. Currently, they are center-aligned, which makes comparing magnitudes across columns slightly harder for the eye.

### Figure 1: "Event Study: EU Mercury Export Ban"
**Page:** 14
- **Formatting:** Clean. Use of a shaded band for 95% CI is standard and preferred over error bars for time series.
- **Clarity:** The message is clear: no pre-trend and a significant post-ban drop.
- **Storytelling:** Critical for establishing the parallel trends assumption for the continuous DiD.
- **Labeling:** Good. Descriptive subtitle clarifies the reference period ($t=-1$).
- **Recommendation:** **KEEP AS-IS**

### Figure 2: "Mercury Import Sources for Africa"
**Page:** 15
- **Formatting:** Professional "stacked area" plot. Colors are distinct but professional.
- **Clarity:** Highly effective. The visual "collapse" of the blue EU area after 2011 tells the story instantly.
- **Storytelling:** This is the strongest "mechanism" exhibit. It immediately visualizes the "waterbed effect" (rerouting).
- **Labeling:** Source notes and axis units are present.
- **Recommendation:** **KEEP AS-IS**

### Table 3: "Effect of Minamata Convention on Mercury Imports"
**Page:** 16
- **Formatting:** Professional.
- **Clarity:** Column (5) is very important as it combines both policies.
- **Storytelling:** This table presents the "counter-intuitive" finding.
- **Labeling:** "Treatment" row (Ratification vs NAP) is a helpful addition.
- **Recommendation:** **REVISE**
  - **Change:** Relabel "Minamata ratified" to "Ratification" and "NAP submitted" to "NAP Implementation" to match the text's terminology more closely and reduce jargon in the stub.

### Figure 3: "Event Study: Minamata Convention Ratification"
**Page:** 17
- **Formatting:** Consistent with Figure 1.
- **Clarity:** Shows the "positive" trend post-ratification well.
- **Storytelling:** Necessary to show that the positive coefficient in Table 3 isn't just a one-year spike but a sustained trend.
- **Recommendation:** **KEEP AS-IS**

### Table 4: "Robustness: Alternative Specifications for EU Mercury Export Ban"
**Page:** 18
- **Formatting:** Standard.
- **Clarity:** High.
- **Storytelling:** Very comprehensive. Column (6) "Balanced" is particularly important given the data quality issues mentioned.
- **Labeling:** Footnotes (4)-(6) are helpful for explaining the column variations.
- **Recommendation:** **MOVE TO APPENDIX**
  - **Reasoning:** Table 2 already establishes the main result and a placebo. This table is "standard" robustness. Moving it to the Appendix would tighten the main narrative of the paper.

### Figure 4: "Leave-One-Out Sensitivity"
**Page:** 19
- **Formatting:** Clean, but very long (54 countries).
- **Clarity:** Hard to read individual country codes on the y-axis.
- **Storytelling:** Important for showing the result isn't driven by a single outlier (like Ghana or Mali).
- **Labeling:** Labels are legible but tiny.
- **Recommendation:** **REVISE**
  - **Change:** Highlight/Bold the "Very High ASGM" countries (Ghana, Tanzania, etc.) in the y-axis list so the reader can immediately see that the biggest players aren't driving the result.

---

## Appendix Exhibits

### Figure 5: "Total Mercury Imports to Africa, 2000–2023"
**Page:** 27
- **Recommendation:** **KEEP AS-IS** (A good "big picture" aggregate plot).

### Figure 6: "Mercury Imports by ASGM Prevalence"
**Page:** 28
- **Recommendation:** **PROMOTE TO MAIN TEXT**
  - **Reasoning:** This figure shows that the trends are entirely driven by "High" and "Very High" ASGM countries. It provides essential "common sense" validity to the trade data being used as a proxy for mining.

### Figure 7: "Minamata Convention Ratification in Africa"
**Page:** 29
- **Recommendation:** **KEEP AS-IS**

### Table 5: "Callaway-Sant’Anna Doubly Robust DiD: Overall ATT"
**Page:** 29
- **Recommendation:** **REMOVE**
  - **Reasoning:** This is redundant with Table 3 and Figure 3. The "Overall ATT" can simply be mentioned in the text or as a footnote in Table 3.

### Table 6: "Minamata Convention Ratification: African Countries"
**Page:** 30
- **Recommendation:** **KEEP AS-IS** (Essential for transparency on the staggered timing).

---

## Overall Assessment

- **Exhibit count:** 3 Main Tables, 4 Main Figures, 2 Appendix Tables, 3 Appendix Figures (Post-recommendations)
- **General quality:** Extremely high. The figures are "Econometrica-ready" in terms of clean aesthetics. The use of a consistent color palette (reds for EU Ban, teals/greens for Minamata) is excellent.
- **Strongest exhibits:** Figure 2 (Trade Reallocation) and Figure 1 (Event Study).
- **Weakest exhibits:** Table 5 (Redundant) and Figure 4 (Y-axis clutter).
- **Missing exhibits:** A **Map of Africa** showing "EU Dependence Share" (intensity of treatment) and "ASGM Prevalence" would be a standard and highly effective "Figure 1" for an AER/QJE paper to show the geographic distribution of the identifying variation.

### Top 3 Improvements:
1.  **Add a map:** Create a dual-panel map showing ASGM intensity and pre-2011 EU trade dependence.
2.  **Consolidate Robustness:** Move the bulk of Table 4 to the appendix to keep the main text focused on the "Supply-side works, Demand-side doesn't" narrative.
3.  **Promote Figure 6:** Move the "Imports by ASGM Prevalence" figure to the main text to validate the data source early on.