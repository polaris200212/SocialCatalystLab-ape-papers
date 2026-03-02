# Internal Review — Claude Code (Round 1)

**Role:** Reviewer 2 (harsh, skeptical) + Editor (constructive)
**Paper:** Across the Channel: Social Networks and the Cross-Border Housing Effects of Brexit
**Version:** v4 (revision of v3)

---

## PART 1: CRITICAL REVIEW

### 1. Identification and Empirical Design

**Strengths:**
- The triple-difference (house × exposure × post) is a clever design that absorbs département × quarter shocks
- Pre-determined census stock from INSEE provides genuinely independent variation from Facebook SCI
- The multi-country placebo battery is a welcome addition over v3's single German placebo

**Concerns:**
- The GADM1-level placebos (BE, NL, IT, ES) are measured at coarser resolution than the UK/DE GADM2 placebos. This asymmetry makes the multi-country comparison difficult to interpret: the GADM1 DiD placebos being null may reflect measurement attenuation rather than absence of cosmopolitan confounding.
- The horse-race specification (all countries simultaneously) is subject to severe multicollinearity among correlated European SCI measures. The fact that all become insignificant could reflect power loss rather than clean identification.
- The triple-difference assumes cosmopolitan appreciation affects houses and apartments symmetrically. If foreign investment disproportionately targets apartments (luxury Paris market), this assumption fails.

### 2. Inference and Statistical Validity

- The pairs cluster bootstrap is well-implemented and validates cluster-robust SEs for most specifications
- The SCI triple-difference bootstrap p-value (0.054) is notably more favorable than cluster-robust (0.106) — this suggests the cluster-robust may be conservative, which is worth noting but also raises questions about which inference to trust
- With only 96 clusters, the power of the triple-difference is inherently limited

### 3. Robustness and Alternative Explanations

- The pre-2020 triple-difference is null for both SCI and stock, which the authors interpret as evidence that the effect may be confounded with COVID. This is an important finding that deserves more prominent discussion.
- HonestDiD confidence intervals include zero at all M-bar values — this is a negative result that the paper should engage with more directly
- The commune-level estimation (612K obs) improves precision but SCI remains insignificant (p=0.129); only stock is borderline (p=0.05)

### 4. Contribution and Literature Positioning

- The methodological contribution (diagnosing cosmopolitan confounding in SCI designs) is genuinely novel and valuable
- The substantive finding (UK-specific housing demand effect) is weaker than the paper sometimes claims
- Literature coverage is adequate; the revision footnote properly links to v3

### 5. Results Interpretation and Claim Calibration

- The paper has improved considerably from v3 in honestly reporting mixed results
- The Discussion section now correctly notes that BE/IT/ES triple-diff placebos are significant
- The conclusion could still be tightened — "strongest evidence" language should be moderated given the HonestDiD nulls and mixed placebos

### 6. Actionable Revision Requests

**Must-fix:**
1. None remaining after v4 advisor fixes (text-table consistency resolved)

**High-value improvements:**
1. More prominent discussion of the HonestDiD null result (CIs include zero)
2. Clarify why bootstrap p (0.054) differs substantially from cluster-robust p (0.106) for the SCI triple-diff
3. Consider adding a sentence acknowledging the measurement asymmetry limitation (GADM1 vs GADM2)

**Optional polish:**
1. Move bootstrap table and RI figure to appendix per exhibit review suggestion
2. Add a map of UK exposure across départements (exhibit review suggestion)

### 7. Overall Assessment

**Key strengths:** Honest engagement with mixed results, comprehensive diagnostic battery, genuinely novel methodological contribution to SCI literature.

**Critical weaknesses:** The substantive finding (UK-specific housing effect) rests on specifications that are borderline significant and sensitive to inference method. The HonestDiD analysis does not provide strong reassurance. The GADM1 measurement asymmetry complicates multi-country comparisons.

**Publishability:** This is a solid applied microeconomics paper with a valuable methodological lesson. The identification is creative if imperfect. The honest reporting of mixed results is a strength. Publishable at AEJ: Economic Policy after minor revisions.

---

## PART 2: CONSTRUCTIVE SUGGESTIONS

1. The paper's clearest contribution is methodological — consider reframing to lead with "how to diagnose cosmopolitan confounding" rather than "Brexit affected French housing"
2. A binscatter of price changes vs. UK exposure would help readers visualize the raw relationship
3. Consider reporting wild cluster bootstrap (if fwildclusterboot becomes available for R 4.5.2) as a sensitivity check alongside pairs bootstrap

---

DECISION: MINOR REVISION
