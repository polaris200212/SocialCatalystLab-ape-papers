# Internal Review — Round 1

**Paper:** Who Captures a Tax Cut? Property Price Capitalization from France's Taxe d'Habitation Abolition
**Reviewer:** Claude Code (internal)
**Date:** 2026-03-03

---

## PART 1: CRITICAL REVIEW

### 1. Identification and Empirical Design

**Strengths:** The paper exploits cross-commune variation in pre-reform TH rates as a continuous treatment dose in a standard DiD framework. The institutional setting is clean: a national reform with full central government compensation eliminates confounds from changes in local public goods.

**Concerns:**
- The continuous-dose specification (TH_dose_std × Post) assumes linearity in the dose-response relationship. The tercile-based robustness check addresses this partially, but the monotonicity is not always confirmed.
- The two-group DiD (Section 6.3) shows imperfect pre-trends (joint F-test p = 0.13, pre-reform coefficients positive at 0.013-0.017). The paper appropriately acknowledges this, but the cautionary language should be even stronger.
- The Column 3 specification with département × year FE yields a negative, marginally significant coefficient (-0.004, p = 0.08), which contradicts the positive overall effect in Columns 1-2. The paper explains this as house-market attenuation, but this specification absorbs variation that could be informative about the treatment effect within départements.

### 2. Inference and Statistical Validity

- Standard errors are clustered at the département level (93 clusters) — appropriate.
- The apartment result (0.023, SE = 0.006, p < 0.001) is precisely estimated.
- Sample sizes vary across specifications (227,826 for main; 51,745 for apartments; 275,101 for houses). The Table 1 note now explains this variation adequately.
- HonestDiD sensitivity analysis shows that the TWFE event-study results are not robust to violations of parallel trends — the confidence interval includes zero even at M-bar = 0.

### 3. Robustness and Alternative Explanations

- Leave-one-out by département: robust (range -0.001 to 0.004).
- Donut specification dropping 2018: consistent.
- Trimmed sample: consistent.
- Anticipation test: negative coefficient for 2017, ruling out positive anticipation.
- Supply heterogeneity: direction consistent with theory but imprecise.

**Missing:** No placebo test using an outcome that should NOT be affected (e.g., commercial property prices, rents). A placebo on a non-residential market would strengthen the paper.

### 4. Contribution and Literature Positioning

The paper clearly positions itself relative to Oates (1969), Hilber & Mayer (2017), Lutz (2015), and the French housing literature (Bach, Bonnet). The contribution — first causal estimate of TH abolition capitalization — is well-articulated.

### 5. Results Interpretation

- The apartment-versus-house contrast is well-interpreted and a genuine contribution.
- The welfare calculation (Appendix) appropriately uses the apartment coefficient rather than the overall estimate.
- The paper is honest about the null overall result and the house-market attenuation.

### 6. Actionable Revision Requests

1. **Must-fix:** Strengthen cautionary language around two-group DiD pre-trends (Section 6.3). The p = 0.13 pre-trend test and positive pre-reform coefficients warrant more explicit caveats.
2. **High-value:** Consider adding a brief discussion of why pre-trends differ between the continuous-dose event study (clean) and the two-group design (imperfect). This may reflect compositional differences in the comparison groups.
3. **Optional:** A placebo test on commercial property or rents would strengthen identification.

## PART 2: CONSTRUCTIVE SUGGESTIONS

1. The apartment-specific event study is the strongest evidence; consider leading with it more prominently in the abstract and introduction.
2. The discussion of delayed capitalization is thoughtful and could be expanded — the phasing schedule creates a natural test of how quickly markets incorporate partial vs. full information.
3. The welfare calculation is illustrative but could note that apartment-market capitalization is a lower bound on total capitalization if houses also capitalize with noise.

---

## Overall Assessment

**Key strengths:** Clean institutional setting, large-scale data (universe of transactions), honest treatment of null overall result, strong apartment-specific finding, thorough robustness.

**Critical weaknesses:** Two-group DiD pre-trends are imperfect; overall median price shows no effect; HonestDiD sensitivity shows non-robustness of aggregate TWFE.

**Publishability:** The apartment-specific result is novel, precisely estimated, and economically important. The paper would benefit from revision but is publishable.

DECISION: MINOR REVISION
