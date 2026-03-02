# Exhibit Review — Gemini 3 Flash (Round 1)

**Role:** Visual exhibit advisor
**Model:** gemini-3-flash-preview (ai_studio)
**Paper:** paper.pdf
**Timestamp:** 2026-03-02T10:08:16.148972
**Route:** Direct Google API + PDF
**Tokens:** 19957 in / 1933 out
**Response SHA256:** 529290a67a90c4a3

---

# Exhibit-by-Exhibit Review

## Main Text Exhibits

### Table 1: "Summary Statistics"
**Page:** 11
- **Formatting:** Clean and professional. Use of panels (A, B, C) is excellent for grouping.
- **Clarity:** Very high. The transition from the full sample to gender and party breakdowns is logical.
- **Storytelling:** Essential. It establishes the low baseline rebellion rate (1.62%), which is crucial for interpreting the "precisely estimated null."
- **Labeling:** Clear. Note correctly defines the sample and variables.
- **Recommendation:** **KEEP AS-IS**

### Table 2: "Gender, Mandate Type, and Party-Line Deviation"
**Page:** 14
- **Formatting:** Standard journal format. No vertical lines, appropriate horizontal rules.
- **Clarity:** Logical progression across columns. Standard errors are correctly placed in parentheses.
- **Storytelling:** This is the "money table." It clearly shows the coefficient of interest (Female $\times$ District) remains null even as controls and fixed effects are added.
- **Labeling:** Significance stars are defined. However, the outcome variable "Party-Line Deviation" is a binary 0/1, but the coefficients are described in the text as "percentage points." 
- **Recommendation:** **REVISE**
  - **Specific Change:** Add a row or a note explicitly stating if coefficients are multiplied by 100 to represent percentage points. Currently, "0.0011" in the table corresponds to "0.11 percentage points" in the text. Standardizing this (e.g., scaling the dependent variable by 100 before regression) would make the table more readable.

### Figure 1: "Party-Line Deviation by Gender and Mandate Type over Time"
**Page:** 15
- **Formatting:** Modern and clean. The color palette (Red/Blue) is standard for gender. 
- **Clarity:** The overlap of four lines is a bit "busy." The shaded 95% CIs make it harder to distinguish the individual paths in the 1990s.
- **Storytelling:** Vital for showing the convergence over time mentioned in the text.
- **Labeling:** Excellent. Legend is clear and axis labels are descriptive.
- **Recommendation:** **REVISE**
  - **Specific Change:** Consider facets (two panels: one for District, one for List) to reduce line crossings, or use different line types (solid vs. dashed) more aggressively to distinguish the mandate types.

### Figure 2: "Raw Party-Line Deviation by Gender and Mandate Type"
**Page:** 16
- **Formatting:** Professional bar chart.
- **Clarity:** Very high. The message (List members rebel more than District members) is clear in 2 seconds.
- **Storytelling:** Slightly redundant with Table 1 Panel B and the text. This is a "visual DDD" but doesn't include the fixed effects that actually change the sign of the District coefficient.
- **Recommendation:** **MOVE TO APPENDIX**
  - **Reasoning:** It shows raw means which are misleading relative to the paper’s main results (where the District coefficient is positive after FE). Table 2 and Figure 1 do the heavy lifting better.

### Figure 3: "Female × District Interaction by Party"
**Page:** 17
- **Formatting:** Excellent "coefficient plot" style.
- **Clarity:** High. The Green Party outlier is immediately visible.
- **Storytelling:** Crucial. This explains the "one exception" to the null.
- **Labeling:** Clear. The dashed line at 0.00 is a good reference.
- **Recommendation:** **KEEP AS-IS**

### Table 3: "Gender × Mandate Type Interaction by Policy Domain"
**Page:** 18
- **Formatting:** Consistent with Table 2.
- **Clarity:** Good. Subsetting by "Feminine" vs "Masculine" is clear.
- **Storytelling:** Important for testing the "Conditional Expression" hypothesis.
- **Labeling:** Notes define CAP codes correctly.
- **Recommendation:** **KEEP AS-IS**

### Figure 4: "Female × District Interaction by Policy Domain (CAP Classification)"
**Page:** 19
- **Formatting:** Clean coefficient plot. 
- **Clarity:** The "Health" estimate has a massive CI, which draws the eye away from the more precise nulls.
- **Storytelling:** Supports Table 3 with finer detail.
- **Labeling:** Good use of color-coding for policy types.
- **Recommendation:** **REVISE**
  - **Specific Change:** Sort the y-axis by the precision of the estimate (inverse of SE) or by the point estimate value rather than alphabetically/randomly. This helps the reader see the "clustering around zero" more effectively.

### Table 4: "Gender × Mandate Type Interaction by Time Period"
**Page:** 20
- **Formatting:** Good.
- **Clarity:** Clear temporal breakdown.
- **Storytelling:** Redundant with Figure 1. Figure 1 shows the continuous evolution; this table just picks three bins. 
- **Recommendation:** **MOVE TO APPENDIX**
  - **Reasoning:** Figure 1 is a more powerful way to show the convergence. The table provides the exact numbers, but they aren't surprising given the figure.

### Figure 5: "Rebellion Rate by District Race Closeness (Dual Candidates)"
**Page:** 21
- **Formatting:** Standard RDD plot.
- **Clarity:** The bin scatter is a bit noisy. The two lines (List Entrant vs District Winner) are the key.
- **Storytelling:** Extremely important. This is the causal evidence that mandates matter, and the text notes the effect is identical for both genders.
- **Labeling:** Clear.
- **Recommendation:** **REVISE**
  - **Specific Change:** The text mentions the effect is identical for men and women. The figure should likely be **split into two panels** (Male/Female) or use different colors for Gender within the RDD to visually prove the "identical effect" claim.

### Table 5: "Robustness Checks"
**Page:** 22
- **Formatting:** Summary table style.
- **Clarity:** Very high. It condenses many regressions into one view.
- **Storytelling:** Great for the final "clinch" of the argument.
- **Recommendation:** **KEEP AS-IS**

---

## Appendix Exhibits

### Figure 6: "Women in the German Bundestag, 1983–2021"
**Page:** 33
- **Formatting:** Clean line chart.
- **Clarity:** High.
- **Storytelling:** Good context for the "Time Evolution" section.
- **Labeling:** Quota adoption annotations are very helpful.
- **Recommendation:** **PROMOTE TO MAIN TEXT**
  - **Reasoning:** This provides essential institutional context for why the sample is split the way it is. It would fit well in Section 2.3.

---

## Overall Assessment

- **Exhibit count:** 4 Main Tables, 5 Main Figures, 1 Appendix Figure. (Plus several results reported in text for Appendix C/D).
- **General quality:** Extremely high. The exhibits look like they belong in a top-tier journal (AER/QJE style). The use of coefficient plots (Fig 3, 4) is much better than providing giant tables of interactions.
- **Strongest exhibits:** Table 1 (perfect summary stats), Figure 3 (powerful heterogeneity visual).
- **Weakest exhibits:** Figure 2 (potentially misleading raw means), Figure 5 (needs gender breakdown to match the text's claim).
- **Missing exhibits:** 
    - **A Balance Table for the RDD:** While the text mentions balance is "satisfactory," a table showing balance on gender, party, and age at the RDD threshold is standard for Econometrica/ReStud.
    - **A "First Stage" RDD Plot:** Showing that the probability of being a District Member jumps from 0 to 1 at the threshold.
- **Top 3 improvements:**
  1. **Scale Coefficients in Tables:** Multiply the dependent variable by 100 so that Table 2 shows "0.11" instead of "0.0011." This aligns the tables with the "percentage point" language in the text.
  2. **Gender-Split Figure 5:** To support the claim that the causal effect of mandates is "identical" for men and women, the RDD plot must show both groups.
  3. **Consolidate/Move Redundant Visuals:** Move Figure 2 and Table 4 to the appendix to tighten the main text's narrative flow.