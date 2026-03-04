# Exhibit Review — Gemini 3 Flash (Round 1)

**Role:** Visual exhibit advisor
**Model:** gemini-3-flash-preview (ai_studio)
**Paper:** paper.pdf
**Timestamp:** 2026-03-04T01:17:40.401319
**Route:** Direct Google API + PDF
**Tokens:** 17357 in / 2040 out
**Response SHA256:** d35f68b10dff3ee9

---

# Exhibit-by-Exhibit Review

## Main Text Exhibits

### Table 1: "Sample Characteristics by Treatment Status (1920 Baseline)"
**Page:** 7
- **Formatting:** Clean and professional. Use of horizontal rules follows standard academic style (booktabs). Number alignment is good.
- **Clarity:** Excellent. The breakdown between Occupation Shares and Demographics is logical.
- **Storytelling:** Essential. It establishes the baseline imbalance (TVA counties being more agricultural), which justifies the DiD approach and the need to control for composition.
- **Labeling:** Clear. The note explains the sample and the "Unclassified" category well.
- **Recommendation:** **KEEP AS-IS**

### Figure 1: "Pre-trends diagnostic: difference in pre-treatment transition probabilities..."
**Page:** 9
- **Formatting:** Heatmap style is modern. The color scale (blue-to-red) is standard for showing differences.
- **Clarity:** Moderate. The values in the cells are very small (0.00x), which is the point, but the visual "clutter" of 144 cells makes it hard to see a pattern other than "mostly white/neutral."
- **Storytelling:** Supports the parallel trends assumption visually. 
- **Labeling:** Good. Includes the MAE in the title which is a helpful summary statistic.
- **Recommendation:** **REVISE**
  - Increase the font size of the axis labels and the cell numbers. 
  - Consider a "white-out" threshold: if a value is below the MAE (0.006), leave the cell blank/white to visually emphasize where the *actual* pre-trend noise is located.

### Figure 2: "DiD transition effect matrix"
**Page:** 10
- **Formatting:** High quality. The color Diverging Palette (RdBu) is appropriate for treatment effects.
- **Clarity:** Good. It allows for quick identification of the "Farmer" column as a primary area of impact.
- **Storytelling:** This is the "money plot" of the paper. It shows the "distributional anatomy" mentioned in the abstract.
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS** (though ensuring the PDF export is high-resolution vector format for the final journal).

### Table 2: "Occupation-Level DiD Transition Matrix (percentage points)"
**Page:** 11
- **Formatting:** Decimal alignment is excellent. Use of abbreviations (FmLab, Oper., etc.) is necessary for fit.
- **Clarity:** High. It provides the precise numbers behind Figure 2.
- **Storytelling:** Crucial. It documents the transition-level details that aggregate regressions miss.
- **Labeling:** Good. The note explains the exclusion of "Professional" as a source row due to N, which is standard rigor.
- **Recommendation:** **REVISE**
  - Bold or star the cells that are statistically significant based on the bootstrap results from Table 5/11. Currently, it is hard to tell which of these 144 numbers represent real signal vs. noise.

### Figure 3: "Top 15 DiD transition effects by absolute magnitude"
**Page:** 12
- **Formatting:** Clean bar chart.
- **Clarity:** Very high. It immediately highlights that the biggest effects are "stay-rate" disruptions and "avoidance" of farming.
- **Storytelling:** Excellent. It distills the complex 144-cell matrix into a "greatest hits" list that the reader can remember.
- **Labeling:** Labels like "Clerical (stay)" and "Sales $\rightarrow$ Manager" are very intuitive.
- **Recommendation:** **KEEP AS-IS**

### Table 3: "Frequency-Based DiD Transition Matrix (percentage points)"
**Page:** 14
- **Formatting:** Consistent with Table 2.
- **Clarity:** Low. The table is very noisy (values like $\pm$ 29pp mentioned in the text).
- **Storytelling:** Serves as a "sanity check" to show that the model isn't hallucinating the effects.
- **Labeling:** Good.
- **Recommendation:** **MOVE TO APPENDIX**
  - This is a methodological validation. The main text results should focus on the preferred transformer estimates. Keeping both in the main text is repetitive for the reader.

### Table 4: "TWFE Benchmark: County-Level Regressions"
**Page:** 16
- **Formatting:** Standard regression table. Professional.
- **Clarity:** High.
- **Storytelling:** Vital for the "Story." It shows that a standard AER-style table would find -1.49pp, while the paper's new method finds much more reallocation underneath.
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS**

### Figure 4: "TWFE event study"
**Page:** 16
- **Formatting:** Standard event study plots.
- **Clarity:** High.
- **Storytelling:** Essential for establishing the credibility of the TVA treatment effect using standard methods.
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS**

### Table 5: "Bootstrap Standard Errors for Key Transition Effects"
**Page:** 19
- **Formatting:** Clean.
- **Clarity:** High.
- **Storytelling:** This is the most important "results" table for inference. It proves that the findings aren't just noise.
- **Labeling:** Good. Significance stars are present.
- **Recommendation:** **KEEP AS-IS**

### Figure 5: "Real treatment (left) vs. placebo (right) DiD transition matrices"
**Page:** 20
- **Formatting:** Side-by-side comparison is effective.
- **Clarity:** Good. The visual contrast between the blue column on the left and the red column on the right is a very strong argument for identification.
- **Storytelling:** Strongest robustness check in the paper.
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS**

### Figure 6: "Weight-space DiD analysis"
**Page:** 21
- **Formatting:** Bar charts are standard.
- **Clarity:** Moderate. "Rank-1 Concentration" is a technical ML term that might alienate some labor economists.
- **Storytelling:** This is "black box opening." It shows *how* the transformer sees the treatment.
- **Labeling:** The x-axis labels (0.linear1, etc.) are internal model names.
- **Recommendation:** **REVISE**
  - Change x-axis labels to be more descriptive (e.g., "Layer 1 FFN", "Layer 1 Attention"). 
  - Add a note explaining what "L2 Norm of $\Delta W^{DiD}$" means in layman's terms (e.g., "Magnitude of parameter change").

---

## Appendix Exhibits

### Table 6: "Model Configuration"
**Page:** 27
- **Recommendation:** **KEEP AS-IS** (Standard for reproducibility).

### Table 7: "Four-Adapter Training Summary"
**Page:** 28
- **Recommendation:** **KEEP AS-IS**

### Table 8: "Synthetic Validation Results"
**Page:** 28
- **Recommendation:** **KEEP AS-IS** (Crucial for a paper introducing a new ML estimator).

### Table 9: "Weight-Space DiD SVD by Layer"
**Page:** 29
- **Recommendation:** **KEEP AS-IS** (Supports Figure 6).

### Table 10: "TVA Counties by State"
**Page:** 30
- **Recommendation:** **KEEP AS-IS**

### Table 11: "Full Bootstrap Standard Errors (percentage points)"
**Page:** 31
- **Recommendation:** **KEEP AS-IS** (Necessary for completeness, but correctly placed in the appendix).

---

## Overall Assessment

- **Exhibit count:** 5 main tables, 6 main figures, 6 appendix tables, 0 appendix figures.
- **General quality:** Extremely high. The paper uses a sophisticated mix of traditional econometrics (TWFE) and modern ML visualization (heatmaps, weight-space analysis). The tables are formatted to the highest journal standards.
- **Strongest exhibits:** Figure 2 (The heatmap of effects) and Figure 3 (The top 15 summary).
- **Weakest exhibits:** Figure 1 (Too cluttered) and Figure 6 (Technical labeling).
- **Missing exhibits:** 
    - **A Map:** A map of the 164 TVA counties vs. the control counties in the 16 states would be a standard and helpful addition for Section 3.1.
- **Top 3 improvements:**
  1. **Cross-reference Significance:** In Table 2 (Main Matrix), bold or star the coefficients that are statistically significant.
  2. **Add a Geography Map:** Include a figure showing the treated and control regions to help the reader visualize the spatial DiD.
  3. **Clarify Figure 6:** Use more "Economist-friendly" labels for the model layers and provide a more intuitive explanation of the weight-space metrics in the notes.