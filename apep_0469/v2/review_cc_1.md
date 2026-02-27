# Internal Review - Claude Code (Round 1)

## PART 1: CRITICAL REVIEW

### 1. Identification and Empirical Design

The paper exploits cross-state variation in WWII mobilization intensity using CenSoc Army enlistment records, combined with within-person differencing via the Census Linking Project. The identification strategy is transparent and well-documented. The key assumption—that state-level mobilization is exogenous to wives' LFP conditional on region and demographics—is standard in this literature (Acemoglu et al. 2004).

**Strengths:**
- Within-person differencing absorbs time-invariant individual heterogeneity, a genuine advance over repeated cross-sections.
- The two-panel design (men linked directly, wives through husbands) is creative and appropriate given the ABE algorithm's surname constraints.
- Wife identity verification (age consistency check, 85.9% pass rate) addresses the remarriage concern transparently.

**Weaknesses:**
- The couples panel conditions on marital survival, excluding widows and divorcees. This is acknowledged but could be discussed more formally as sample selection bias.
- The mobilization measure (CenSoc Army enlistees only) differs from Acemoglu et al.'s Selective Service data, making direct comparison difficult. This is noted but the implications could be sharper.

### 2. Inference and Statistical Validity

Standard errors are clustered at the state level throughout (49 clusters). The paper provides HC2, HC3, and randomization inference as robustness. The RI p-value (0.033) is more informative than the cluster-robust p-value given the small number of clusters.

- Sample sizes are reported consistently across tables.
- The significance star footnote (p. 18) explicitly explains the fixest convention (* = p<0.1) and why t≈2.0 yields one star with 49 clusters.
- The R² footnote for the unconditional specification is appropriate.

### 3. Robustness and Alternative Explanations

The robustness battery is extensive: Oster bounds, RI, HC2/HC3, LOO, ANCOVA, trimmed sample, wife-verified subsample, placebo on older women, quintile treatment. This is commendable.

**Concern:** The placebo test on older wives (46+) shows a significant positive coefficient (+0.0049, p<0.05). The paper interprets this as general equilibrium effects, but it could also indicate a violation of the identification assumption (mobilization correlated with broader economic shocks). This deserves more discussion.

### 4. Contribution and Literature Positioning

The paper clearly positions itself relative to Acemoglu et al. (2004), Goldin (1991), and Rose (2018). The within-person design is a genuine contribution. The comparison of within-couple and aggregate changes is novel and informative.

### 5. Results Interpretation and Claim Calibration

The paper is appropriately cautious about the mobilization coefficient (0.68 pp, borderline significant). The within-vs-aggregate comparison is well-framed as informative rather than as a formal decomposition identity—the revision correctly notes that these cover different populations.

## PART 2: CONSTRUCTIVE SUGGESTIONS

1. The comparison between within-couple and aggregate changes would be strengthened by computing the aggregate change specifically for married women (from cross-sectional data), eliminating the population-mismatch concern entirely.
2. A formal bounding exercise on the selection bias from conditioning on marital survival would strengthen the paper.
3. The quintile treatment effects (Table 8) show a non-monotonic pattern—this deserves brief discussion.

## 6. ACTIONABLE REVISION REQUESTS

1. **Must-fix:** Ensure all abstract numbers match table values exactly (currently consistent after revision).
2. **High-value:** Discuss the significant placebo result (older wives) more carefully—could it indicate confounding?
3. **High-value:** Consider computing married-women-specific aggregate LFP to make the comparison cleaner.
4. **Optional:** The LOO range [-0.0031, +0.0000] shows one state causes a near-zero estimate; identify which state and discuss.

## 7. OVERALL ASSESSMENT

**Strengths:** Massive scale (14M men, 5.6M couples), genuine within-person design, extensive robustness, honest treatment of null results, beautiful exhibits.

**Weaknesses:** Mobilization effect is modest and borderline significant; placebo on older women shows unexpected positive result; within-vs-aggregate comparison spans different populations.

**Publishability:** Strong candidate for AEJ: Economic Policy after addressing the placebo result interpretation and the married-women aggregate comparison. The scale and methodological rigor are impressive.

DECISION: MINOR REVISION
