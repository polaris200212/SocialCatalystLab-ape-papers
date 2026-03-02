# Exhibit Review — Gemini 3 Flash (Round 1)

**Role:** Visual exhibit advisor
**Model:** gemini-3-flash-preview (ai_studio)
**Paper:** paper.pdf
**Timestamp:** 2026-02-23T11:37:06.406596
**Route:** Direct Google API + PDF
**Tokens:** 18397 in / 2155 out
**Response SHA256:** 098b6d72033f1eec

---

As a visual exhibit advisor for top-tier economics journals, I have reviewed the exhibits in "Roads to Nowhere? Rural Infrastructure and the Persistence of Gender Gaps in Non-Farm Employment in India."

Overall, the exhibits are of high quality, following the clean, minimalist style of the *Quarterly Journal of Economics* or *American Economic Review*. However, there is significant redundancy between the main text and the appendix, and some figures require technical refinements to meet the "10-second parse" rule.

---

# Exhibit-by-Exhibit Review

## Main Text Exhibits

### Table 1: "Summary Statistics: Villages Near the PMGSY Population Threshold"
**Page:** 11
- **Formatting:** Professional and clean. Uses standard Booktabs-style horizontal lines.
- **Clarity:** Excellent. The grouping of pre-treatment vs. outcomes is logical.
- **Storytelling:** Essential. It establishes that the comparison groups are balanced on observables (other than population), which is the bedrock of the RDD.
- **Labeling:** Clear. Units (shares and rates) are understood to be 0-1 based on the means.
- **Recommendation:** **KEEP AS-IS**

### Figure 1: "McCrary Density Test at the PMGSY Population Threshold"
**Page:** 14
- **Formatting:** Good, but the background grid is slightly too prominent.
- **Clarity:** The bin colors (light green) are a bit faint. The overlap of the black/red lines at the threshold is the key area; the pink shaded confidence interval is visible but thin.
- **Storytelling:** Standard diagnostic. It proves no manipulation.
- **Labeling:** Axis labels are clear.
- **Recommendation:** **REVISE**
  - Increase the line weight for the density fit lines.
  - Darken the bin colors (use a more standard gray or muted blue) to improve contrast against the white background.
  - Remove the minor gridlines.

### Figure 2: "Distribution of Village Population Near the PMGSY Threshold"
**Page:** 15
- **Formatting:** Professional.
- **Clarity:** High. The use of two colors to distinguish the sides of the cutoff is helpful.
- **Storytelling:** Redundant with Figure 1. While Figure 1 is a statistical test, Figure 2 is a raw histogram. In top journals, these are usually combined or one is relegated to the appendix.
- **Labeling:** Excellent.
- **Recommendation:** **MOVE TO APPENDIX** (This supports Figure 1 but doesn't add a new "discovery.")

### Table 2: "Covariate Balance at the PMGSY Eligibility Threshold"
**Page:** 15
- **Formatting:** Clean, but the columns could be better spaced.
- **Clarity:** Good. It quickly shows high p-values.
- **Storytelling:** This is the regression version of the balance test in Table 1.
- **Labeling:** "nonag share f" should be renamed to "Female Non-Ag Share" for consistency with the text.
- **Recommendation:** **REVISE**
  - Add a note defining $N$ (sample size) for these regressions, as it varies by bandwidth.
  - Consolidate: This table is small. Consider moving it to the Appendix and keeping only the "Joint F-test" or a summary statement in the main text to save space.

### Table 3: "PMGSY Road Eligibility and Employment Outcomes: RDD Estimates"
**Page:** 16
- **Formatting:** Journal-ready.
- **Clarity:** Very high. The $N_{eff}$ column is a nice touch for RDD papers.
- **Storytelling:** The "Money Table." It shows the null result across all primary and secondary outcomes.
- **Labeling:** Abbreviations (SE, $N_{eff}$) are defined.
- **Recommendation:** **KEEP AS-IS**

### Figure 3: "RDD Plot: Female Non-Agricultural Worker Share"
**Page:** 17
- **Formatting:** Excellent.
- **Clarity:** The binned scatters are clear. The fit line shows the trend well.
- **Storytelling:** The most important visual proof of the null.
- **Labeling:** Includes the point estimate and SE in the plot area—this is a "Gold Standard" practice for AER.
- **Recommendation:** **KEEP AS-IS**

### Figure 4: "RDD Plot: Male Non-Agricultural Worker Share"
**Page:** 17
- **Formatting:** Consistent with Figure 3.
- **Clarity:** High.
- **Storytelling:** Vital for the argument that "it's not just women; roads don't even move the needle for men."
- **Labeling:** Good.
- **Recommendation:** **KEEP AS-IS** (Consider combining Figures 3 and 4 into a single Figure with Panel A and Panel B to save vertical space).

### Table 4: "Robustness: Bandwidth Sensitivity for Female Non-Agricultural Worker Share"
**Page:** 18
- **Formatting:** Standard.
- **Clarity:** Clear, but would be more impactful as a coefficient plot.
- **Storytelling:** Proves the result isn't a fluke of the CCT bandwidth.
- **Labeling:** Good.
- **Recommendation:** **MOVE TO APPENDIX** (Figure 5 already tells this story visually and more effectively).

### Figure 5: "Bandwidth Sensitivity of the RDD Estimate"
**Page:** 19
- **Formatting:** High quality.
- **Clarity:** The shaded 95% CI clearly crossing zero across the whole range is a "10-second parse."
- **Storytelling:** Essential robustness.
- **Labeling:** "RD Estimate" on Y-axis is clear.
- **Recommendation:** **KEEP AS-IS**

### Figure 6: "Placebo Cutoff Tests"
**Page:** 20
- **Formatting:** Consistent.
- **Clarity:** Good.
- **Storytelling:** Standard RDD robustness.
- **Labeling:** The legend (Blue vs. Grey) is clear.
- **Recommendation:** **KEEP AS-IS**

### Figure 7: "Covariate Balance at the PMGSY Threshold"
**Page:** 20
- **Formatting:** Clean coefficient plot.
- **Clarity:** High.
- **Storytelling:** This is the visual version of Table 2.
- **Labeling:** Variable names are a bit "code-heavy" (e.g., "nonag share f").
- **Recommendation:** **REVISE**
  - Change Y-axis labels to "Formal" English (e.g., "Female LFPR" instead of "lfpr f").
  - Since this visualizes Table 2, keep this in the main text and move Table 2 to the Appendix.

### Figure 8: "Donut Hole Sensitivity"
**Page:** 21
- **Formatting:** Consistent.
- **Clarity:** Very high.
- **Storytelling:** Addresses potential sorting/manipulation right at the 500 mark.
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS**

---

## Appendix Exhibits

### Table 5: "Variable Definitions"
**Page:** 31
- **Recommendation:** **KEEP AS-IS** (Essential for replication).

### Table 6 & 7: "Polynomial Order" and "Kernel Sensitivity"
**Page:** 32
- **Recommendation:** **REVISE**
  - Consolidate Tables 6 and 7 into a single "Robustness to Specification" table with Panel A (Polynomials) and Panel B (Kernels). This is standard for *Econometrica* or *ReStud* appendices.

### Table 8: "Male Employment Outcomes"
**Page:** 32
- **Recommendation:** **REMOVE**
  - These results are already present in the main text's Table 3. There is no need to repeat them in the appendix unless you are showing additional specifications (like different bandwidths specifically for males).

---

## Overall Assessment

- **Exhibit count:** 4 main tables, 8 main figures, 4 appendix tables, 0 appendix figures.
- **General quality:** The visual style is very cohesive. The "Coefficient Plot" style (Figures 5-8) is modern and highly effective for communicating null results.
- **Strongest exhibits:** Figure 3 (RDD Plot) and Figure 5 (Bandwidth Sensitivity).
- **Weakest exhibits:** Figure 1 (Density) due to low contrast and Figure 2 (Redundancy).
- **Missing exhibits:** 
    1. **Map of India/Sample:** A figure showing the geographic distribution of "treated" vs. "control" villages or just the "Plains" vs "Hills" states would be very helpful for context.
    2. **First Stage:** While the paper cites Asher and Novosad for the first stage (roads actually being built), a paper targeting AER should ideally show the first-stage discontinuity in road construction within this specific sample to prove the ITT isn't zero just because no roads were built.

**Top 3 Improvements:**
1.  **Consolidate for Flow:** Combine Figure 3 and 4 into one figure (Panel A/B). Move Table 2 (Balance) to the Appendix and rely on Figure 7 (Balance Plot) in the main text.
2.  **Clean up Labels:** Ensure all Y-axis labels in figures use "Publication English" (e.g., "Labor Force Participation Rate") rather than "Stata Code" (e.g., "lfpr_f").
3.  **Add Contextual Visuals:** Add a map showing the PMGSY program coverage or the "Plains" sample. This grounds the high-level econometrics in the physical reality of India.