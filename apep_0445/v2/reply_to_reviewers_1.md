# Reply to Reviewers — APEP-0445 v2

## GPT-5.2 (MAJOR REVISION)

### 1. Internal consistency: OZ designation rate text vs Table 1
**Fixed.** Text now correctly reports "11.1 percent designation rate within the optimal bandwidth, with 4.3 percent below the cutoff and 20.7 percent above."

### 2. Internal consistency: Sample size 11,046 vs Table 5 showing 8,331
**Fixed.** Text now reads "8,331 tracts" matching Table 5.

### 3. Internal consistency: Parenthetical N examples don't match Table 2
**Fixed.** Text now reads "16,372 for Δ Total employment versus 15,690 for Δ Info sector employment" matching Table 2 exactly.

### 4. Parametric coefficient values don't match tables
**Fixed.** Updated to match actual values: "6.5 for total employment, −0.5 for information" (parametric) vs "9.0 and −1.8" (nonparametric).

### 5. Outcome validity for "data center investment"
**Partially addressed.** We acknowledge this limitation more prominently and tighten claims. The paper now explicitly notes that the null on NAICS 51 is a proxy, and foregrounds the total employment null (which captures all industries) as the stronger result. Adding additional outcome families (CBP, permits, energy data) would require tract-level data that is generally suppressed or unavailable.

### 6. Implement fuzzy RD Wald table
**Done.** Added Table (tab2b_fuzzy_rdd) with nonparametric fuzzy RDD Wald estimates from rdrobust. As expected, estimates are noisier but confirm the null. Text discusses compliers and interprets alongside the ITT.

### 7. McCrary rejection / discrete running variable
**Addressed.** Added explicit discussion of the quasi-discrete running variable issue in Section 6.1, referencing Frandsen (2017) and Cattaneo et al. (2015). Local randomization inference is now better integrated as the primary response to density concerns.

### 8. Tighten external validity claims
**Partially addressed.** We note more carefully that effects are local to the ~20% poverty margin and that data center clusters may sit at different points in the poverty distribution.

---

## Grok-4.1-Fast (MINOR REVISION)

### 1. Fuzzy IV estimates underplayed
**Fixed.** Added prominent fuzzy RDD Wald table (see GPT #6 above).

### 2. Missing references
**Acknowledged.** The Agarwal & Ross (2024) and Perez-Truglia (2020) suggestions noted for future revision. Core RDD methodology references (Cattaneo, Calonico, Frandsen) already present.

### 3. Contiguous-tract provision quantification
**Already addressed in Section 5.3**, which notes the provision is "quantitatively minor" (approximately 5% of all designated OZ tracts).

---

## Gemini-3-Flash (MINOR REVISION)

### 1. Compound treatment (NMTC sharing 20% threshold)
**Already addressed** in Section 5.4 and throughout. The null strengthens under compound treatment.

### 2. Capital vs labor discussion
**Partially addressed.** We note in limitations that investment may show up in property values or capital rather than employment. The paper's contribution is the employment channel specifically.

---

## Exhibit Review (Gemini)

### 1. Consolidate Figures 3/4 and 5/6
**Deferred.** Multi-panel figures would require regenerating R code; current separate figures are clear and the paper is 39 pages, well above the minimum.

### 2. Balance table: add mean column
**Deferred.** The balance table is already informative; mean values are available in Table 1.

### 3. Table 6 (parametric) formatting
**Fixed.** Removed duplicate header row showing raw variable names. Fixed interaction term label.

---

## Prose Review (Gemini)

### 1. Kill roadmap paragraph
**Done.** Replaced verbose roadmap with one-sentence transition.

### 2. Active transitions in robustness section
**Done.** Changed "I subject the main results to an extensive battery of robustness checks" to "The null result is not an artifact of specification choices."

### 3. Prune fillers
**Done.** Changed "Several limitations warrant acknowledgment" to "Four caveats apply to these results." Tightened LODES data description.

---

## Code Review (Codex-Mini)

### 1. Missing set.seed() before rdrandinf
**Fixed.** Added `set.seed(12345)` before the local randomization inference loop. Re-ran with reproducible seed; results unchanged.

---

## Additional Fixes from Advisor Review (Round 1)

1. **McCrary t-statistic:** Fixed text from t=4.46 to t=5.03 (matching figure and actual computation)
2. **Figure 8b filename:** Fixed from `fig8b_placebo_hist.pdf` to `fig8b_placebo_histogram.pdf`
3. **Figure 9 filename:** Fixed from `fig9_infra_het.pdf` to `fig9_infrastructure.pdf`
4. **QOF investment date:** Fixed from "through 2025" to "through 2023, with continued growth projected"
5. **Broadband ACS vintage:** Fixed figure caption from "ACS 2011-2015" to "ACS 2017 5-year estimates"
