# Internal Review - Round 1

**Reviewer:** Claude Code (Internal)
**Paper:** Parity Without Payoff? Gender Quotas in French Local Government
**Date:** 2026-02-21

---

## PART 1: CRITICAL REVIEW

### 1. Format Check

- **Length:** ~25 pages main text + appendix. Meets requirement.
- **References:** Adequate coverage of the gender quota literature (Chattopadhyay & Duflo, Beaman et al., Bertrand et al., Ferreira & Gyourko) and RDD methodology (Calonico et al., Cattaneo et al.). Missing some key references (noted below).
- **Prose:** All sections in paragraph form. No bullet-point sections in main text.
- **Section depth:** Each section has adequate depth.
- **Figures:** 11 figures with visible data, proper axes, and clear labels.
- **Tables:** 10 tables with real numbers. No placeholders detected.

### 2. Statistical Methodology

- **Standard errors:** All coefficients have SEs in parentheses. PASS.
- **Significance testing:** Stars, p-values, and Holm-corrected p-values reported. PASS.
- **Confidence intervals:** 95% CIs in main results table. PASS.
- **Sample sizes:** N reported for all regressions. PASS.
- **RDD requirements:** McCrary test (T=0.18, p=0.86), bandwidth sensitivity (Fig 4, Table 10), placebo cutoffs (Fig 6), covariate balance (Table 3). PASS.
- **Multiple hypothesis correction:** Holm adjustment across 13 outcomes. PASS.
- **Equivalence testing:** TOST with SESOI = 1 pp. Correctly notes TOST p = 1.000 means equivalence cannot be established. PASS.

### 3. Identification Strategy

**Strengths:**
- Sharp RDD at 1,000 threshold is clean — running variable (legal population) determined by INSEE, not manipulable by communes.
- McCrary test confirms no manipulation.
- Covariate balance tests all pass.
- 3,500 validation exercise is creative (now correctly described as exposure duration test).

**Concerns:**
- The compound treatment (parity + PR) remains the central limitation. The paper now honestly addresses this but the 3,500 validation is not as clean as an ideal test would be.
- The fuzzy RD-IV is acknowledged as weak but still reported — consider demoting to appendix.
- Cross-sectional design limits causal claims about dynamics.

### 4. Literature

**Missing references that should be added:**
- Cattaneo, Idrobo & Titiunik (2019/2020) — the RDD textbook, essential methodological reference
- Lee & Lemieux (2010) — canonical RDD survey
- Imbens & Lemieux (2008) — foundational RDD reference
- Eggers et al. (2021) on regression discontinuity designs in political science

### 5. Writing Quality

The prose is generally strong — clear, well-structured, with good transitions. The introduction hooks effectively with the India-France contrast. The mechanisms section is well-organized. Minor issues:
- The "Reporting Conventions" subsection (Section 4) is useful but could be a footnote to reduce clutter.
- Some results paragraphs read like table narration rather than storytelling.

### 6. Constructive Suggestions

1. **Move fuzzy RD-IV to appendix.** The weak instrument problem is substantial and the reduced-form results are more informative. Reporting the IV in the main text invites questions about the scaling/interpretation.
2. **Add a heterogeneity analysis.** Does the null hold for communes just above 1,000 vs. those farther above? For communes in different regions?
3. **Discuss the 2014 vs. 2020 council timing more carefully.** The paper uses the 2020-elected council but the parity rule applied starting 2014. Are we testing the effect of 6 years of parity exposure?

## PART 2: OVERALL ASSESSMENT

**Strengths:**
- Clean RDD design with strong institutional setting
- Comprehensive outcome families (labor, political, spending, entrepreneurship)
- Honest null interpretation with appropriate caveats
- Good methodological transparency (equivalence tests, MDE, MHT)

**Weaknesses:**
- Compound treatment cannot be fully resolved
- Cross-sectional data limits dynamic analysis
- Fuzzy IV is underpowered — should probably be demoted to appendix
- Missing some foundational RDD references

**DECISION: MINOR REVISION**
