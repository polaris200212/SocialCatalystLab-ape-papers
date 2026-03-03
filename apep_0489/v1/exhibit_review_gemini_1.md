# Exhibit Review — Gemini 3 Flash (Round 1)

**Role:** Visual exhibit advisor
**Model:** gemini-3-flash-preview (ai_studio)
**Paper:** paper.pdf
**Timestamp:** 2026-03-03T03:37:33.548137
**Route:** Direct Google API + PDF
**Tokens:** 29317 in / 2647 out
**Response SHA256:** f758db2596c20f44

---

# Exhibit-by-Exhibit Review

## Main Text Exhibits

### Table 1: "Synthetic DGP Overview"
**Page:** 15
- **Formatting:** Clean, professional LaTeX-style formatting. Good use of horizontal rules (booktabs style). 
- **Clarity:** Excellent. It provides a roadmap for the validation section.
- **Storytelling:** Essential. It establishes the "stress tests" the model must pass before real-world application.
- **Labeling:** Clear. The note explains $K$ and $T$, though "pp" is standard enough to potentially omit from notes if space is needed.
- **Recommendation:** **KEEP AS-IS**

### Table 2: "DGP 1: Cell-Level Recovery"
**Page:** 16
- **Formatting:** Consistent with Table 1. Number alignment is good.
- **Clarity:** Very high. The "Error" column makes the key message (low bias) immediate.
- **Storytelling:** Strong. It proves the model handles the "row-stochastic" constraint of probability matrices.
- **Labeling:** Suggest adding a note clarifying if "Estimated $\Delta P$" is the mean across seeds or a single run.
- **Recommendation:** **REVISE**
  - Add "Standard errors in parentheses" or "Mean of N simulations" to the note to clarify the point estimate's nature.

### Table 3: "Small Effect Detection (DGP 4)"
**Page:** 18
- **Formatting:** Professional.
- **Clarity:** The "Detected?" column is a great addition for a 10-second parse.
- **Storytelling:** Important for establishing the power of the method.
- **Labeling:** Units (pp) are clearly labeled in headers.
- **Recommendation:** **KEEP AS-IS**

### Table 4: "Heterogeneous Treatment Effects by Age (DGP 6)"
**Page:** 20
- **Formatting:** Standardized.
- **Clarity:** Good use of "Pooled" as a benchmark row.
- **Storytelling:** Validates the side-embedding architecture's ability to capture interactions.
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS**

### Table 5: "Non-Markov History Dependence (DGP 7)"
**Page:** 21
- **Formatting:** Standardized.
- **Clarity:** The "Improvement" column is the "hero" metric here.
- **Storytelling:** This is the most important validation table as it justifies using a Transformer over a simple Markov Chain. 
- **Recommendation:** **KEEP AS-IS** (Consider promoting the "Improvement" text to bold to highlight the 49-77% gains).

### Table 6: "Sample Size–Accuracy Frontier (DGP 8)"
**Page:** 22
- **Formatting:** Standardized.
- **Clarity:** Clear trade-off shown between $N$ and MAE.
- **Storytelling:** Useful for future researchers to determine if their dataset is large enough for this method.
- **Labeling:** "Training Time (s)" is helpful for practical implementation.
- **Recommendation:** **KEEP AS-IS**

### Table 7: "Synthetic Validation Summary"
**Page:** 24
- **Formatting:** Standardized.
- **Clarity:** Excellent summary table.
- **Storytelling:** While a bit redundant with previous tables, it serves as a "Final Grade" for the method.
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS**

### Table 8: "Summary Statistics: TVA vs. Control Counties (1920 Baseline)"
**Page:** 27
- **Formatting:** Good use of grouping for years.
- **Clarity:** Logical layout.
- **Storytelling:** Crucial for the "Parallel Trends" argument.
- **Labeling:** The $N$ values are clearly broken down.
- **Recommendation:** **KEEP AS-IS**

### Table 9: "Transition-Space DiD: Dominant Cells (TVA Application)"
**Page:** 28
- **Formatting:** Professional.
- **Clarity:** Easy to read the "from-to" flows.
- **Storytelling:** This is the core result of the paper's application.
- **Labeling:** Good explanation of the 1.0 pp threshold for inclusion.
- **Recommendation:** **KEEP AS-IS**

### Table 10: "Weight-Space SVD of DiD Adapter Differences"
**Page:** 29
- **Formatting:** Professional.
- **Clarity:** The L2 Norm and Top-1 Energy columns provide a nice "heat map" of where the model is learning.
- **Storytelling:** Novel. This shows the "anatomy" of the neural network's reaction to treatment.
- **Labeling:** Mathematical symbols are well-defined in the notes.
- **Recommendation:** **KEEP AS-IS**

### Table 11: "Heterogeneous Effects by Age Group"
**Page:** 30
- **Formatting:** Clean.
- **Clarity:** Column headers are intuitive.
- **Storytelling:** Shows the "who" of the structural transformation.
- **Recommendation:** **REVISE**
  - **Consolidation:** This table, Table 12, and Table 13 all show Heterogeneous Effects. To save space in a top journal (like AER), these should be merged into one large "Table 11: Heterogeneous Treatment Effects" with Panels A (Age), B (Initial Occupation), and C (Race).

### Table 12: "Heterogeneous Effects by Initial Occupation"
**Page:** 31
- **Formatting:** Standard.
- **Clarity:** "N (1000s)" is a vital context column.
- **Storytelling:** Essential.
- **Recommendation:** **REVISE**
  - Merge into a multi-panel table as suggested above.

### Table 13: "Heterogeneous Effects by Race"
**Page:** 32
- **Formatting:** Standard.
- **Clarity:** "Ratio" column is a good addition.
- **Storytelling:** High impact for policy/equity discussion.
- **Recommendation:** **REVISE**
  - Merge into a multi-panel table as suggested above.

### Table 14: "Traditional TWFE DiD Results"
**Page:** 33
- **Formatting:** Classic "Table 1" style for econ papers. Decimal-aligned.
- **Clarity:** Very high. Standard error parentheses are correct.
- **Storytelling:** Provides the "Ground Truth" benchmark for the new method.
- **Labeling:** Significance stars and clustering are well-noted.
- **Recommendation:** **KEEP AS-IS**

### Table 15: "Ablation: Model Architecture Size"
**Page:** 35
- **Formatting:** Standard.
- **Clarity:** Clear monotonic relationship.
- **Storytelling:** Justifies the "Base" model choice.
- **Recommendation:** **MOVE TO APPENDIX** (This is a technical justification that slows the main narrative).

### Table 16: "Ablation: LoRA Rank"
**Page:** 36
- **Formatting:** Standard.
- **Clarity:** Good.
- **Storytelling:** Technical validation.
- **Recommendation:** **MOVE TO APPENDIX**

### Table 17: "Ablation: Prediction Head Type"
**Page:** 36
- **Formatting:** Standard.
- **Clarity:** Clear evidence for the Two-Stage head.
- **Storytelling:** High importance for the "Economic Inductive Bias" argument.
- **Recommendation:** **KEEP AS-IS** (This is a key architectural contribution).

### Table 18: "Ablation: Temporal Masking Strategy"
**Page:** 37
- **Formatting:** Standard.
- **Clarity:** Good.
- **Recommendation:** **MOVE TO APPENDIX**

### Table 19: "Ablation: Pre-Training Strategy"
**Page:** 38
- **Formatting:** Standard.
- **Recommendation:** **MOVE TO APPENDIX**

### Table 20: "Ablation Summary"
**Page:** 38
- **Formatting:** Clean summary.
- **Clarity:** "Best vs. Worst" is a very clear way to show impact.
- **Storytelling:** Excellent "at-a-glance" for the methodology section.
- **Recommendation:** **KEEP AS-IS** (Move the specific sub-tables 15, 16, 18, 19 to Appendix and keep this summary in the main text).

---

## Appendix Exhibits

### Table 21: "TVA Counties by State"
**Page:** 46
- **Recommendation:** **KEEP AS-IS** (Standard data appendix table).

### Table 22: "Complete Model Hyperparameters"
**Page:** 48
- **Recommendation:** **KEEP AS-IS** (Crucial for reproducibility).

### Table 23: "Architecture Ablation: Complete Results"
**Page:** 51
- **Recommendation:** **REVISE**
  - This is redundant with the moved Table 15. Consolidate them.

### Table 24: "Transition-Space DiD: Full 6x6 Matrix"
**Page:** 52
- **Formatting:** Excellent. A 6x6 matrix is much more readable than the 10x10.
- **Clarity:** Provides the "big picture" of the TVA's effect on the labor market.
- **Recommendation:** **PROMOTE TO MAIN TEXT**
  - This is a powerful visual of the paper's primary empirical contribution. It should replace the simpler Table 9.

### Table 25: "Robustness: Alternative Control Groups"
**Page:** 52
- **Recommendation:** **KEEP AS-IS**

### Table 26: "Runtime Benchmarks"
**Page:** 53
- **Recommendation:** **KEEP AS-IS**

---

## Overall Assessment

- **Exhibit count:** 20 main tables, 0 main figures, 6 appendix tables, 0 appendix figures.
- **General quality:** The tables are exceptionally professional and follow "Top 5" journal conventions (no vertical lines, clear notes, logical flow). However, the paper is **entirely missing figures**, which is a significant handicap for QJE/AER.
- **Strongest exhibits:** Table 5 (Non-Markov evidence) and Table 24 (The 6x6 Matrix).
- **Weakest exhibits:** The individual ablation tables (15, 16, 18, 19) are too granular for the main text and create a "wall of tables" that slows the reader.
- **Missing exhibits:** 
  1. **A Map:** A paper on the TVA *must* have a map of the treatment and control counties.
  2. **Event Study Plot:** While Table 14 shows the pre-trends, a standard Figure 1 in a DiD paper is a plot of coefficients over time with 95% CIs.
  3. **Heatmap/Sankey Diagram:** Since the paper is about "Transition Space," a visual representation of the flows (e.g., a heatmap of the 6x6 matrix) would be much more impactful than a table for the first 10 seconds of reading.

### Top 3 Improvements:
1. **Create Figures:** Add a map of the TVA study area and a visualization (heatmap or Sankey) of the transition matrix.
2. **Consolidate Heterogeneity:** Merge Tables 11, 12, and 13 into a single multi-panel "Heterogeneous Effects" table to improve the narrative flow of the application section.
3. **Streamline Ablations:** Move the technical ablation tables to the Appendix and rely on the "Ablation Summary" (Table 20) in the main text to communicate the design choices.