# Reply to Reviewers — Round 1

**Paper:** The First Retirement Age: Civil War Pensions and Elderly Labor Supply at the Age-62 Threshold
**Workspace:** output/paper_197/
**Parent:** apep_0442

---

## Reviewer 1 (GPT-5.2): MAJOR REVISION

### 1.1 Estimand/First-Stage Ambiguity
**Concern:** The paper risks being interpreted as estimating a retirement effect of pension income when it is at best a reduced-form ITT effect. Without observing pension receipt, the paper cannot estimate a first stage.

**Response:** We have reframed the estimand throughout. Section 4 (Conceptual Framework) now explicitly positions the main estimate as an intent-to-treat (ITT) effect of crossing the automatic eligibility threshold, not "the effect of pensions" per dollar transferred. The new paragraph explains that many veterans below 62 already received disability-based pensions, attenuating the first stage. The ITT is the policy-relevant parameter (it measures the effect of moving the eligibility threshold), and the paper now states this clearly. The introduction also previews the null finding explicitly.

### 1.2 Confederate State Pension Rules
**Concern:** Need a state-by-state table of Confederate pension eligibility rules to strengthen the diff-in-disc assumption.

**Response:** Added a new appendix subsection (A.3) with a 13-state table of Confederate pension rules circa 1907–1910, citing Glasson (1918), Eli & Salisbury (2016), and Salisbury (2017). No Southern state used age 62 as a threshold. States with age-based eligibility (GA, LA, TX, FL) used age 60. The modal program was disability-based with no age trigger.

### 1.3 Literacy Discontinuity
**Concern:** The large literacy imbalance (RD estimate -0.218, SE 0.057) is first-order and needs stronger treatment than "control for literacy."

**Response:** We address this through multiple channels: (i) literacy-controlled specification in Table 7 (virtually identical to baseline), (ii) attempted Lee bounds (fails due to sparsity—now discussed with clearer prose), (iii) diff-in-disc, which absorbs any literacy-driven confound common to both groups. The Lee bounds failure is explicitly noted as informative about the sparsity of the below-62 sample. We acknowledge this is a limitation of the 1.4% sample that full-count data would resolve.

### 1.4 Multiple Testing for Heterogeneity
**Concern:** Extensive heterogeneity analysis requires addressing multiple comparisons.

**Response:** Added explicit caveat in Section 9 that subgroup results are exploratory, some estimates may achieve significance by chance, and readers should calibrate priors accordingly. We do not adjust for multiple comparisons because the primary goal is pattern identification, but we flag this transparently.

### 1.5 Missing References
**Concern:** Missing local randomization RDD references (Cattaneo, Titiunik & Vázquez-Bare 2017, 2020).

**Response:** Added both references to the bibliography and cited them in the RDD methodology section (Section 3.3), contextualizing the local randomization framework for discrete running variables.

### 1.6 Density Test at Placebo Cutoffs
**Concern:** Show density tests for both groups at 62, plus placebo cutoffs.

**Response:** The paper already includes placebo cutoff analysis (Figure 8, Table 7 Panel C). The density test discussion in Section 7.1 explicitly argues that the rejection reflects the steep demographic decline and would appear at any cutoff in this range—confirmed by the placebo cutoff analysis.

### 1.7 Results Prose ("Table-Speak")
**Concern:** Results section reads like a spreadsheet narration.

**Response:** Rewrote Section 7.2 to lead with the finding ("no statistically significant discontinuity") and interpret the MDE before discussing columns. The intro now previews the null result explicitly per the "Shleifer tells you the answer early" principle.

---

## Reviewer 2 (Grok-4.1-Fast): MINOR REVISION

### 2.1 Confederate State Pensions
**Concern:** Tabulate state-specific Confederate thresholds.

**Response:** Added appendix table (see 1.2 above). Confirms no age-62 trigger in any state.

### 2.2 Missing References
**Concern:** Add Barreca et al. (2018), Wright (2014), Bloemen et al. (2018).

**Response:** Barreca et al. (2016) already cited. The Confederate pension institutional detail is now covered through the appendix table with existing citations (Glasson, Eli & Salisbury). The paper's literature review is already comprehensive; we defer adding further references to avoid bloat.

### 2.3 Power Extensions
**Concern:** Link to full-count data or Union Army pension records.

**Response:** Acknowledged as future work. The 1.4% sample is the maximum achievable given that VETCIVWR is only available in the 1% and 1.4% oversampled extracts. Record linkage to Union Army pension records is an excellent suggestion for future research.

### 2.4 Elasticity Bounds
**Concern:** Quantify economic significance via elasticity bounds given MDE.

**Response:** The MDE discussion in Section 7.2 frames the power limitation in percentage-point terms. Without a credible first stage, converting to elasticities would require additional assumptions that could mislead. The ITT framing in Section 4 clarifies why elasticity bounds are not straightforward here.

---

## Reviewer 3 (Gemini-3-Flash): MAJOR REVISION

### 3.1 Power / Full-Count Census
**Concern:** Use the 1910 full-count census with record linkage.

**Response:** Acknowledged as the most valuable extension. VETCIVWR is unavailable in the full-count file, so this requires military record linkage—a substantial data effort beyond the current revision's scope. Noted in Section 10.4 as a limitation and opportunity for future work.

### 3.2 Literacy Imbalance
**Concern:** Show a "literacy-residualized" RDD plot.

**Response:** The literacy-controlled specification in Table 7 (Panel B) residualizes the outcome on literacy before RDD estimation. The controlled estimate is virtually identical to the baseline. The imbalance diagnosis is discussed in the Lee bounds subsection and throughout the validity section.

---

## Additional Changes (from Exhibit and Prose Reviews)

1. **Removed roadmap paragraph** from introduction (prose review).
2. **Sharpened Section 2.3** transition: "not a transition from zero to twelve dollars, but from uncertainty to a guarantee."
3. **Fixed Lee bounds prose**: broke up long parenthetical sentence for clarity.
4. **Added null result preview** to introduction.
5. **Strengthened conclusion** with a more memorable final sentence.
6. **Added multiple testing caveat** for heterogeneity section.
