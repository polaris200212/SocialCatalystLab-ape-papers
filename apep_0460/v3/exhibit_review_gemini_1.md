# Exhibit Review — Gemini 3 Flash (Round 1)

**Role:** Visual exhibit advisor
**Model:** gemini-3-flash-preview (ai_studio)
**Paper:** paper.pdf
**Timestamp:** 2026-02-26T17:02:58.383843
**Route:** Direct Google API + PDF
**Tokens:** 16837 in / 2051 out
**Response SHA256:** a5e4505bc496c44c

---

# Exhibit-by-Exhibit Review

## Main Text Exhibits

### Table 1: "Summary Statistics"
**Page:** 10
- **Formatting:** Clean and professional. Follows standard journal style with minimal horizontal rules. Numbers are well-aligned.
- **Clarity:** Excellent. Variables are grouped logically. It provides a clear sense of the panel dimensions in the notes.
- **Storytelling:** Essential. It establishes the scale of the data (10 million transactions aggregated to 3,510 units) and the variation in the key exposure measures.
- **Labeling:** Good. It includes N, unit definitions, and descriptive statistics.
- **Recommendation:** **KEEP AS-IS**

---

### Table 2: "Main Results: UK Exposure and French Housing Prices"
**Page:** 11
- **Formatting:** Strong. Uses standard significance stars and parentheses for SEs. The use of checkmarks for fixed effects is standard for AER/QJE.
- **Clarity:** The column headers are a bit crowded (e.g., "Stock+Trend"). The Within $R^2$ for Column 6 is expressed in scientific notation ($2.13 \times 10^{-5}$), which is jarring compared to the other decimals.
- **Storytelling:** This is the "bad news" table of the paper. It effectively shows how the German placebo (Col 5) outperforms the UK effect, and how trends (Col 6) kill the significance.
- **Labeling:** Clear. Notes explain the abbreviations (SCI, DE, Resid).
- **Recommendation:** **REVISE**
  - Change scientific notation in Column 6 $R^2$ to standard decimal (0.00002) for consistency, or use "0.000" if the precision isn't necessary.
  - Expand "DE Plac." to "German Placebo" if space permits, as "DE" is not as universally recognized as "UK".

---

### Table 3: "Triple-Difference: UK Exposure × Post × Houses"
**Page:** 13
- **Formatting:** Consistent with Table 2.
- **Clarity:** High. The interaction terms are clearly labeled.
- **Storytelling:** This is the paper’s "centerpiece." It effectively compares the UK effect (Col 1-2) against the German placebo (Col 4). 
- **Labeling:** "UK+DE" in Column 5 needs a more descriptive header like "Horse Race."
- **Recommendation:** **REVISE**
  - Add the p-values in the notes or text for the triple-diff coefficients, as the text emphasizes them (e.g., $p \approx 0.10$), but the table shows them as insignificant (no stars). 
  - Change "DE Plac." to "German Placebo."

---

### Figure 1: "Event Studies: SCI and Census Stock Exposure"
**Page:** 16
- **Formatting:** Clean ggplot2-style aesthetic. The shaded 95% CIs are professional.
- **Clarity:** Good. The distinction between Panel A and B is clear. The horizontal dashed line at zero is essential and present.
- **Storytelling:** Vital for DiD. It shows the "marginal pre-trend violations" mentioned in the text.
- **Labeling:** Y-axis labels "Log SCI(UK) × Period" are a bit technical. 
- **Recommendation:** **REVISE**
  - Improve Y-axis labels to be more intuitive, e.g., "Effect on Log Housing Price."
  - The "10, 20, 30" on the X-axis should ideally be labeled with years (e.g., 2018, 2020) to help the reader map the event study to the real-world timeline (Brexit, COVID).

---

### Figure 2: "Triple-Difference Event Study: Houses vs. Apartments"
**Page:** 17
- **Formatting:** Professional.
- **Clarity:** The "Log SCI(UK) × House × Period" label on the Y-axis is quite long and technical.
- **Storytelling:** Crucial. This figure shows why the triple-diff is the "cleanest" evidence, as the pre-period is much flatter than in Figure 1.
- **Labeling:** Needs year labels on the X-axis for better context.
- **Recommendation:** **REVISE**
  - Add year labels to X-axis.
  - Clarify Y-axis label: "Triple-Diff Coefficient (House vs. Apt)."

---

### Figure 3: "House-Apartment Price Gap Event Study"
**Page:** 18
- **Formatting:** Good. Standard two-panel layout.
- **Clarity:** High.
- **Storytelling:** This is essentially a robustness check for Figure 2, showing that the "gap" itself is what drives the result. It's a bit redundant with Figure 2 but serves a specific econometric purpose.
- **Labeling:** The titles "A: House-Apt Gap x SCI" are a bit shorthand.
- **Recommendation:** **KEEP AS-IS** (or move to Appendix if the paper is over the limit, as Figure 2 tells most of the story).

---

### Figure 4: "Randomization Inference: Census Stock"
**Page:** 19
- **Formatting:** Excellent. The red vertical line clearly indicates the "real" coefficient against the null distribution.
- **Clarity:** Very high.
- **Storytelling:** Standard for papers using geographic variation where spatial correlation is a concern.
- **Labeling:** "RI p = 0.004" is clearly displayed.
- **Recommendation:** **KEEP AS-IS**

---

### Figure 5: "Leave-One-Out Analysis: Census Stock"
**Page:** 20
- **Formatting:** Professional.
- **Clarity:** Good. The dots representing coefficients when dropping one department are clear.
- **Storytelling:** Necessary to prove that the Dordogne or Paris isn't driving the entire result.
- **Labeling:** Y-axis "Coefficient" is clear.
- **Recommendation:** **KEEP AS-IS**

---

### Table 4: "Robustness: Census Stock Specification"
**Page:** 21
- **Formatting:** Consistent.
- **Clarity:** Column headers like "No IdF" and "No Cors." are explained in the notes, which is good.
- **Storytelling:** Standard robustness. Shows the result is not driven by the capital or islands.
- **Recommendation:** **KEEP AS-IS**

---

### Table 5: "Exchange Rate Channel: Sterling Depreciation and Housing Prices"
**Page:** 22
- **Formatting:** Note that Column 3 header is cut off: "(Placeb" should be "(Placebo)".
- **Clarity:** Good.
- **Storytelling:** This addresses the "Mechanism." 
- **Labeling:** Fix the typo in Col 3 header.
- **Recommendation:** **REVISE**
  - Fix typo: "(Placeb" $\rightarrow$ "(Placebo)".

---

### Table 6: "Geographic Heterogeneity: Channel-Facing and UK Buyer Hotspots"
**Page:** 23
- **Formatting:** Standard.
- **Clarity:** The comparison between "Channel vs. Interior" and "Hotspot vs. Non-Hotspot" is logical.
- **Storytelling:** Adds color to the "rural houses" narrative.
- **Recommendation:** **KEEP AS-IS**

---

### Figure 6: "GBP/EUR Exchange Rate, 2014–2023"
**Page:** 24
- **Formatting:** Simple and effective.
- **Clarity:** High.
- **Storytelling:** Critical for the reader to visualize the "shock." The pound didn't just drop; it stayed low.
- **Labeling:** Clear.
- **Recommendation:** **KEEP AS-IS**

---

## Overall Assessment

- **Exhibit count:** 6 main tables, 6 main figures, 0 appendix tables, 0 appendix figures.
- **General quality:** Extremely high. This paper follows the "Stroebel style" of SCI papers (logical, diagnostic-heavy, very clean).
- **Strongest exhibits:** Table 3 (The centerpiece) and Figure 4 (Randomization inference).
- **Weakest exhibits:** Figure 1 (Pre-trend issues) and Table 5 (Typo in header).
- **Missing exhibits:** A **Map of France** showing the Social Connectedness Index (UK) or Census Stock by département. For a geography-based paper, a "heat map" is standard and helps the reader immediately see the Dordogne/Brittany clusters.
- **Top 3 improvements:**
  1. **Add a Map:** Include a figure showing the geographic distribution of the treatment variable (UK Census Stock) to provide spatial context.
  2. **Harmonize X-Axes:** Update all event study plots (Figs 1, 2, 3) to include Year labels (2014, 2016, etc.) on the X-axis rather than just "Quarters relative to 0."
  3. **Table Cleanup:** Fix the scientific notation in Table 2 and the header typo in Table 5.