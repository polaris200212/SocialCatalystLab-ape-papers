# Internal Review — Claude Code (Round 1)

**Role:** Internal referee
**Timestamp:** 2026-03-01
**Paper:** Automating Elevators (apep_0478 v4)

---

## 1. IDENTIFICATION AND RESEARCH DESIGN

This paper is primarily descriptive — it assembles the lifecycle of elevator operators from 1900–1980, tracks individual-level transitions in a 1940–1950 linked panel, and examines newspaper discourse. There is no causal identification in the strict sense (no policy shock, no RDD, no canonical DiD), and the paper is honest about this framing.

**Strengths:**
- The linked panel (N = 38,562) is a genuine contribution — tracking individual displacement outcomes is rare in historical labor economics
- The comparison group (janitors, porters, guards) is well-motivated
- The newspaper corpus adds a qualitative evidence layer that complements the quantitative analysis

**Concerns:**
- The displacement regressions (Table 4) are cross-sectional comparisons, not causal estimates. The paper mostly avoids causal language, but the phrase "displacement regressions" could imply more than is warranted.
- The SCM in the appendix uses states as units with only 4 pre-treatment periods (1900, 1910, 1920, 1930) and a vague treatment definition ("institutional protections" after 1940). This is methodologically weak — 4 pre-periods for SCM is insufficient for reliable inference. The paper appropriately relegates this to the appendix.

## 2. DATA-DESIGN ALIGNMENT

- Census microdata (1900–1950): Full-count, well-documented, appropriate for the descriptive analysis
- Published aggregates (1960–1980): Necessary for the full arc, clearly sourced
- Linked panel (1940–1950): MLP v2.0 with 47% linkage rate — standard for the field
- Newspaper corpus: American Stories, appropriate source with documented methodology

No fatal data-design misalignment detected.

## 3. ROBUSTNESS AND ALTERNATIVE EXPLANATIONS

**Present:**
- IPW for linkage selection (Table 8)
- OCC1950 cleaning sensitivity
- Comparison group robustness
- SCM as alternative approach

**Missing or weak:**
- No formal balance table comparing linked vs. unlinked operators (mentioned in text but not shown — the exhibit review flagged this)
- The 84% exit rate is presented as evidence of displacement, but no benchmark is provided for what "normal" occupational turnover looked like in 1940–1950. If 70% of janitors also changed occupations, the 84% figure is less striking.
- The racial channeling finding (Black operators → janitorial work) could partly reflect geographic sorting: Black operators were concentrated in cities with different labor market structures. State fixed effects may not fully capture this.

## 4. CONTRIBUTION AND LITERATURE POSITIONING

- Literature positioning is adequate. Key citations present: Acemoglu & Restrepo, Autor, Frey & Osborne, Goldin & Katz, David
- The "first comprehensive lifecycle" claim is appropriate — no prior paper has assembled this specific dataset
- Missing: Could cite Autor, Levy & Murnane (2003) on routine-task replacement more specifically, as elevator operation is a canonical routine manual task

## 5. RESULTS INTERPRETATION AND CLAIM CALIBRATION

- The "forty-year gap" framing is effective and well-supported
- The racial channeling finding is the paper's strongest result and is presented proportionally
- The newspaper section makes qualitative claims that are well-calibrated to the evidence (discourse "shifted," not "caused")
- The entry analysis (Section 6.4) is interesting but could be interpreted differently: women entering in 1950 might reflect postwar labor force participation generally, not occupation-specific decline

## 6. ACTIONABLE REVISION REQUESTS

### Must-fix:
1. **Add comparison group exit rate.** The 84% exit rate is meaningless without knowing what janitors/porters/guards experienced. Add one sentence with the comparison: "By comparison, X% of janitors and Y% of porters also changed occupations between 1940 and 1950."
2. **Summary statistics table.** The paper has no summary statistics for the linked panel. Add a table showing means/SDs for operators vs. comparison workers in 1940 (age, race, sex, OCCSCORE, NYC share).

### High-value improvements:
3. **Kill the roadmap paragraph** (page 3, "The paper proceeds as follows..."). The prose review also flagged this. The section headers are self-explanatory.
4. **Tighten Section 4 (Data).** The prose review correctly notes that the data section reads like an inventory. Lead with the people, not the datasets.
5. **Figure 5 (metro trajectories):** Too many overlapping lines. Highlight Manhattan in bold, grey out others, or show Manhattan vs. average-of-others.
6. **Move Table 1 to appendix** or integrate its key numbers into the text. It's redundant with Figure 1.

### Optional polish:
7. Rename "Empirical Strategy" sections with more evocative titles (per prose review suggestion)
8. The abstract is 149 words — just under the 150-word limit. Could tighten slightly.

## 7. OVERALL ASSESSMENT

**Key strengths:**
- Compelling narrative that sustains reader interest throughout
- Novel data combination (full-count census + linked panel + newspaper corpus)
- Honest about what the data can and cannot show
- The racial channeling finding is genuinely important and well-documented
- Writing quality is high — the opening hook is excellent

**Critical weaknesses:**
- Missing summary statistics table
- No comparison group benchmark for the exit rate
- The newspaper section is rich qualitatively but lacks quantitative analysis (no figures showing article counts by category over time, despite the classification pipeline)

**Publishability:** Strong descriptive paper with genuine contributions to the automation and economic history literatures. The combination of data sources and the quality of the writing elevate it above typical descriptive work. With the must-fix items addressed, this is competitive for AEJ: Economic Policy or Explorations in Economic History, and possibly AER Papers & Proceedings.

DECISION: MINOR REVISION
