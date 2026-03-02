# Exhibit Review — Gemini 3 Flash (Round 2)

**Role:** Visual exhibit advisor
**Model:** gemini-3-flash-preview (ai_studio)
**Paper:** paper.pdf
**Timestamp:** 2026-02-25T21:10:47.708372
**Route:** Direct Google API + PDF
**Tokens:** 18397 in / 1967 out
**Response SHA256:** e6aea24e3ed311aa

---

This review evaluates the exhibits of "Clean Air, Dirty Divide? Property Price Effects of Low Emission Zone Boundaries in France" against the standards of top-tier economics journals (AER, QJE, etc.).

# Exhibit-by-Exhibit Review

## Main Text Exhibits

### Table 1: "Summary Statistics"
**Page:** 7
- **Formatting:** Generally clean. However, decimal alignment is missing in the "Price/m²" row (standard deviations in parentheses are not centered under the means).
- **Clarity:** Excellent. The stratification by Enforcement and Location makes the "level difference" clear immediately.
- **Storytelling:** Vital. It preemptively explains why a simple "inside vs. outside" comparison is biased (showing higher prices inside) and justifies the RDD.
- **Labeling:** The euro symbol (€) is rendered as an "e" in the OCR/PDF—ensure this is a proper symbol in the final LaTeX. "Apartment (%)" is clear.
- **Recommendation:** **REVISE**
  - Use `dcolumn` or `siunitx` in LaTeX to decimal-align all numbers.
  - Ensure the Euro symbol renders correctly.

### Figure 1: "Property Prices at the ZFE Boundary"
**Page:** 10
- **Formatting:** Professional "ggplot2" style. Good use of confidence intervals. 
- **Clarity:** The key message (no jump at zero) is visible in under 5 seconds.
- **Storytelling:** This is the "money plot" of the paper. It clearly shows the price gradient and the lack of discontinuity.
- **Labeling:** Axis labels are excellent. The subtitle "RDD estimate: -0.0245 (-2.4%)" is helpful but redundant with the caption; typically, top journals prefer this information in the table or the notes rather than as a figure title.
- **Recommendation:** **KEEP AS-IS**

### Table 2: "Main Results: Effect of ZFE on Property Prices"
**Page:** 11
- **Formatting:** Standard three-line table. Good use of whitespace.
- **Clarity:** Logical progression from baseline to controls to placebo.
- **Storytelling:** Effectively communicates the null result. Adding "Implied % effect" is a very helpful "AER-style" touch for interpretation.
- **Labeling:** Significance stars are defined. Standard errors are in parentheses. 
- **Recommendation:** **KEEP AS-IS**

### Figure 2: "Density of Transactions at ZFE Boundary (McCrary Test)"
**Page:** 13
- **Formatting:** Clean histogram. The orange dashed line at the cutoff is clear.
- **Clarity:** The "McCrary p=0" annotation is a bit small but legible.
- **Storytelling:** This is a "bad news" exhibit (failing the density test). The author handles it well by explaining the A86 motorway's physical presence.
- **Labeling:** "Number of Transactions" is a clear y-axis. 
- **Recommendation:** **REVISE**
  - Increase the font size of the "McCrary p=0" text for better legibility in print.

### Table 3: "Covariate Balance at ZFE Boundary"
**Page:** 14
- **Formatting:** Clear columns.
- **Clarity:** The "Status" column (PASS/FAIL) is highly non-standard for top journals. It feels a bit "undergraduate."
- **Storytelling:** Shows where the RDD is valid (surface/rooms) and where it is structural (lots/apartment share).
- **Labeling:** Clear.
- **Recommendation:** **REVISE**
  - **Remove the "Status" column.** Journal readers are sophisticated enough to interpret p-values. A "PASS/FAIL" column is too evaluative for a formal table. 

### Table 4: "Heterogeneity by Property Type"
**Page:** 14
- **Formatting:** Clean.
- **Clarity:** Comparing "Appartement" vs "Maison" is straightforward.
- **Storytelling:** Explains the lack of power/imprecision for houses.
- **Recommendation:** **KEEP AS-IS** (Consider merging with Table 2 as Panel B to save space if needed).

### Figure 3: "ZFE Boundary Effect Over Time"
**Page:** 16
- **Formatting:** Professional coefficient plot with 95% CI ribbon.
- **Clarity:** Clearly shows the 2021 "bump" and subsequent return to null.
- **Storytelling:** Vital for the "anticipation" and "enforcement" arguments.
- **Recommendation:** **REVISE**
  - Add a horizontal dashed line at 0 (it's there, but very faint).
  - Add "N=" or "Point Estimate" labels above each year to help the reader.

### Table 5: "Robustness Checks"
**Page:** 17
- **Formatting:** Excellent use of Panels (A and B).
- **Clarity:** Easy to scan different specifications.
- **Storytelling:** Demonstrates the fragility of the 200m donut-hole result, which the text discusses honestly.
- **Recommendation:** **KEEP AS-IS**

### Figure 4: "Bandwidth Sensitivity"
**Page:** 19
- **Formatting:** High-quality sensitivity plot.
- **Clarity:** The vertical dotted line for "Optimal BW" is standard and helpful.
- **Storytelling:** Defends against "p-hacking" via bandwidth choice.
- **Recommendation:** **KEEP AS-IS**

### Figure 5: "Placebo Cutoff Tests"
**Page:** 20
- **Formatting:** Good use of color (blue for real, gray for placebo).
- **Clarity:** Shows the real estimate is "in the pack" of placebos.
- **Recommendation:** **KEEP AS-IS**

---

## Appendix Exhibits

### Figure 6: "Weak vs. Strong Enforcement: Property Prices at the Boundary"
**Page:** 30
- **Storytelling:** This is essentially a "Difference-in-Discontinuities" visual.
- **Recommendation:** **PROMOTE TO MAIN TEXT.** This is a very powerful way to show that the "inside-outside" price level gap is constant across time periods, strengthening the identification. It is more informative than the McCrary histogram.

### Figure 7: "Map of Property Transactions Near the Paris ZFE Boundary"
**Page:** 32
- **Clarity:** Very clear. It allows the reader to visualize the A86 ring.
- **Storytelling:** Essential "Figure 1" material for any spatial paper.
- **Recommendation:** **PROMOTE TO MAIN TEXT.** This should be the first figure the reader sees to understand the geography of the study.

### Figure 8: "Covariate Balance at ZFE Boundary"
**Page:** 33
- **Clarity:** A visual version of Table 3.
- **Storytelling:** Redundant with Table 3.
- **Recommendation:** **REMOVE.** In a top journal, you don't need both Table 3 and Figure 8. Table 3 contains the actual numbers (coeffs, SEs, N) which are more useful for the Appendix. If the author prefers a visual, move Figure 8 to the main text and move Table 3 to the appendix.

---

## Overall Assessment

- **Exhibit count:** 5 main tables, 5 main figures, 0 appendix tables, 3 appendix figures
- **General quality:** High. The visuals follow modern "RD-plot" conventions perfectly. Tables are clean but occasionally "talk down" to the reader (e.g., the "Status" column).
- **Strongest exhibits:** Figure 1 (Main RD plot), Figure 5 (Placebo cutoffs), Table 2 (Main results).
- **Weakest exhibits:** Table 3 (due to "PASS/FAIL" labeling), Figure 8 (redundant).
- **Missing exhibits:** 
    1. **A specific "Difference-in-Discontinuities" Table:** While the text reports the +0.015 coefficient, it deserves its own row or small table to be the definitive "causal" estimate.
    2. **Map of Air Quality:** If data exists, a map showing that NO2 or PM2.5 actually *does* drop at the boundary would turn this from a "null result" paper into a "limited capitalization" paper.

### Top 3 Improvements:
1.  **Geography first:** Move Figure 7 (Map) to the main text as Figure 1. Spatial papers must ground the reader in the physical map immediately.
2.  **Formalize Table 3:** Remove "PASS/FAIL" and "Status" from the balance table. Let the p-values speak for themselves.
3.  **Merge for Flow:** Consider merging Table 4 (Heterogeneity) into Table 2 as "Panel B" to keep all primary price estimates in one place.