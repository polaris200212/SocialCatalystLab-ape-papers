# Exhibit Review — Gemini 3 Flash (Round 1)

**Role:** Visual exhibit advisor
**Model:** gemini-3-flash-preview (ai_studio)
**Paper:** paper.pdf
**Timestamp:** 2026-03-02T19:08:48.193716
**Route:** Direct Google API + PDF
**Tokens:** 17877 in / 1924 out
**Response SHA256:** 818060d05bd72779

---

# Exhibit-by-Exhibit Review

## Main Text Exhibits

### Table 1: "Summary Statistics: Pre-Treatment Means (2010–2014)"
**Page:** 8
- **Formatting:** Generally clean. Uses horizontal rules appropriately. Standard deviations are correctly placed in parentheses.
- **Clarity:** Logical comparison between Treated and Other counties. The use of "per 100K" and "thousands" is clear.
- **Storytelling:** Essential for showing the baseline differences (especially population size), which justifies the use of weights/controls later.
- **Labeling:** Good. Includes N (county-years) and clear units.
- **Recommendation:** **KEEP AS-IS**

### Table 2: "Effect of Progressive DA Election on County Jail Population Rate"
**Page:** 12
- **Formatting:** Professional. Standard errors in parentheses. Significance stars defined.
- **Clarity:** Column headers (1)-(5) are descriptive. However, the coefficient for "Log Pop" in Column (2) is massive (-974.7) compared to the outcome mean, which might distract readers.
- **Storytelling:** This is the "money table." It effectively shows robustness across TWFE, CS-DiD, and subsamples.
- **Labeling:** "State x Year FE" uses a dash instead of "No" for clarity; "Yes" is used where applicable.
- **Recommendation:** **REVISE**
  - Use decimal alignment for all columns to ensure numbers like (157.6) and (45.3) line up vertically.
  - In the notes, explicitly state the mean of the dependent variable for the treated group to help readers scale the coefficients.

### Figure 1: "Event Study: Effect of Progressive DA on Jail Population Rate"
**Page:** 13
- **Formatting:** Clean "ggplot" style. The grey shaded CI is standard but the "Pre-treatment" and "Post-treatment" text labels at the top are a bit cluttered.
- **Clarity:** The message is clear: no pre-trends, immediate effect.
- **Storytelling:** Crucial for validating the DiD design.
- **Labeling:** Y-axis label is descriptive. X-axis "Years Relative to DA" is standard.
- **Recommendation:** **REVISE**
  - Increase the font size of the axis labels and numbers; they will be hard to read in a printed journal.
  - Remove the redundant title at the very top of the plot area; the Figure caption is sufficient.

### Figure 2: "Raw Trends in Jail Population Rates: Progressive DA vs. Other Counties"
**Page:** 14
- **Formatting:** Good use of shaded confidence bands.
- **Clarity:** Visually distinct paths.
- **Storytelling:** Provides raw data evidence to support the regression results.
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS** (Consider moving to Appendix if space is tight, as the event study is more rigorous).

### Table 3: "Effect of Progressive DA Election on Homicide Mortality Rate"
**Page:** 15
- **Formatting:** Standard.
- **Clarity:** Very clean with only two columns.
- **Storytelling:** Directly addresses the "public safety" concern.
- **Labeling:** "Age-adjusted" is correctly noted in the text and notes.
- **Recommendation:** **REVISE**
  - Combine this with Table 2 as "Panel B" or add it as a column in a consolidated "Main Effects" table. Having a separate table for just two columns of one outcome is inefficient.

### Figure 3: "Event Study: Effect of Progressive DA on Homicide Rate"
**Page:** 16
- **Formatting:** Consistent with Figure 1.
- **Clarity:** Note the x-axis only goes from -2 to 2. This is much shorter than Figure 1.
- **Storytelling:** Supports the null effect on crime.
- **Labeling:** Good.
- **Recommendation:** **REVISE**
  - Add a note in the caption explaining why the window is shorter (-2 to +2) compared to the jail rate figure (this is due to the 2019-2024 data constraint mentioned in text).

### Table 4: "Racial Decomposition: Differential Effects on Black vs. White Jail Rates"
**Page:** 17
- **Formatting:** Professional.
- **Clarity:** Column (1) and (2) show different specifications (DDD vs Ratio).
- **Storytelling:** This is the "Paradox" result. It is the most novel part of the paper.
- **Labeling:** "B/W Ratio" should be spelled out as "Black-to-White Jail Ratio" in the header if space permits.
- **Recommendation:** **KEEP AS-IS**

### Figure 4: "Black and White Jail Rates by DA Type"
**Page:** 18
- **Formatting:** The four lines are a bit difficult to distinguish.
- **Clarity:** High "ink-to-information" ratio. The widening gap is visible but the crossover of the "Other" lines is messy.
- **Storytelling:** Visualizes the "Equity Paradox."
- **Labeling:** Legend is clear.
- **Recommendation:** **REVISE**
  - Use different colors (e.g., Blue for Black, Red for White) and different line types (Solid for Treated, Dashed for Control) to make the four lines immediately distinguishable.

### Table 5: "Robustness: Effect on Jail Population Rate Across Specifications"
**Page:** 19
- **Formatting:** Standard.
- **Clarity:** Column (6) "AAPI" is a placebo test; this is a very strong addition.
- **Storytelling:** Strong robustness section.
- **Labeling:** Good.
- **Recommendation:** **KEEP AS-IS**

### Figure 5: "Leave-One-Out Influence Analysis"
**Page:** 20
- **Formatting:** Standard coefficient plot.
- **Clarity:** Clear that no single county drives the result.
- **Storytelling:** Necessary for DiD with only 25 treated units.
- **Recommendation:** **MOVE TO APPENDIX** (This is a standard diagnostic that doesn't need main text space).

---

## Appendix Exhibits

### Figure 6: "Progressive DA Election Timeline"
**Page:** 21
- **Formatting:** Clean.
- **Clarity:** Excellent visualization of staggered entry.
- **Storytelling:** Helps the reader understand the "treatment" variation.
- **Recommendation:** **PROMOTE TO MAIN TEXT** (Place this in the Data/Methods section; it's vital for understanding the identification strategy).

### Table 6: "Progressive District Attorney Counties: Treatment Details"
**Page:** 29
- **Formatting:** Comprehensive.
- **Clarity:** Very useful for transparency.
- **Storytelling:** Essential reference for the "25 counties" mentioned in the abstract.
- **Recommendation:** **KEEP AS-IS** (In Appendix).

---

## Overall Assessment

- **Exhibit count:** 5 Main Tables, 5 Main Figures, 1 Appendix Table, 1 Appendix Figure.
- **General quality:** High. The tables follow standard AER format. Figures are clean but font sizes are slightly small for publication.
- **Strongest exhibits:** Table 2 (Main Results) and Table 4 (Racial Paradox).
- **Weakest exhibits:** Figure 4 (Cluttered lines) and Table 3 (Too small/could be merged).
- **Missing exhibits:** 
    1. **A Map:** A U.S. map highlighting the 25 treated counties would be a high-impact "Figure 1."
    2. **Triple-Diff Event Study:** A figure showing the dynamic effect on the Black-to-White ratio would be more convincing than just Table 4.

### Top 3 Improvements:
1.  **Consolidate Main Tables:** Merge Table 2 (Incarceration) and Table 3 (Homicides) into a single "Main Results" table with Panel A and Panel B. This allows the reader to see the "Incarceration falls, Crime doesn't rise" story in one glance.
2.  **Improve Figure 4 (Racial Trends):** Use distinct colors. Currently, it's hard to tell which grey line is which. This figure is central to the paper's "Paradox" claim and needs to be "punchier."
3.  **Promote the Timeline (Figure 6):** Move the Treatment Timeline to the main text. In staggered DiD papers, showing the timing of treatment is now considered standard for the main body to assess the validity of the "staggered" design.