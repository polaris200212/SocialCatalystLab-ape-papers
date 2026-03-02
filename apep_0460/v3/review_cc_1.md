# Internal Review — Claude Code (Round 1)

**Role:** Internal reviewer (Reviewer 2 mode)
**Paper:** Across the Channel: Social Networks and the Cross-Border Housing Effects of Brexit
**Timestamp:** 2026-02-26T16:50:00

---

## PART 1: CRITICAL REVIEW

### 1. Identification and Empirical Design

**Strengths:**
- The three-pronged identification strategy (census stock, residualized exposure, triple-difference) is well-motivated and addresses specific concerns raised about the v2 design.
- The census stock from INSEE Première No. 1809 (2016 reference date) is genuinely pre-determined relative to the June 2016 referendum.
- The triple-difference design is theoretically compelling: British buyers concentrate in rural houses, while cosmopolitan appreciation should affect houses and apartments symmetrically.

**Concerns:**
- The census stock is measured at bassin de vie level and aggregated to département. The aggregation introduces noise and may lose meaningful within-département variation. The paper should acknowledge this limitation.
- The residualized exposure result (β≈0.010, p=0.431) is presented as evidence that "the raw SCI result is substantially confounded." But the first-stage R² is only 0.20, meaning 80% of SCI variation is NOT explained by confounders. The insignificance could reflect attenuation from projecting onto a small set of controls rather than genuine confounding.
- The census stock attenuates to insignificance with département-specific linear trends (Column 6, p=0.897). This is a serious threat — it suggests the post-2016 divergence may be a continuation of pre-existing trends rather than a Brexit-induced break.

### 2. Inference and Statistical Validity

- Standard errors are properly clustered at the département level throughout.
- Randomization inference (2,000 permutations, p=0.003) provides strong evidence for the census stock baseline specification.
- The triple-difference coefficients are not statistically significant (p=0.106 to 0.182). The paper honestly acknowledges this. However, framing a "null German placebo" (p=0.667) as the key finding, while the UK coefficient is also insignificant, stretches the interpretation.
- Sample sizes are now internally consistent across text and tables (3,510 main panel, 7,014 property-type panel, 7,010 after singletons).

### 3. Robustness and Alternative Explanations

- Leave-one-out analysis shows no single département drives the result — good.
- Excluding Île-de-France and Corsica barely affects estimates — good.
- The binary treatment (top quintile) yields β=0.015, p=0.171 — insignificant, which weakens the continuous-treatment result.
- The short window (2014-2018) result (β=0.007, p=0.007) is interesting — it suggests the effect may be concentrated in the immediate post-Brexit period.
- Department-specific trends kill the result. This needs more discussion.

### 4. Contribution and Literature Positioning

- The paper positions itself clearly in the SCI literature (Bailey et al. 2018, 2020).
- The methodological contribution (diagnosing cosmopolitan confounding) is genuine and valuable.
- Missing: Hilber and Vermeulen (2016) on UK housing supply constraints; Sá (2015) on foreign demand and UK house prices.

### 5. Results Interpretation and Claim Calibration

- The abstract and introduction appropriately hedge ("genuine but modest").
- The "Honest Assessment" section (8.4) is exemplary — it frankly states that the German placebo is "the single most inconvenient fact."
- The exchange rate interaction (Sterling × Stock, β=-0.060, p=0.006) is compelling evidence for the mechanisms channel.

### 6. Actionable Revision Requests

**Must-fix:**
1. Discuss the trend sensitivity more explicitly. The census stock result vanishing with département trends is the most important diagnostic. Consider showing pre-trend tests or event-study-based pre-trend diagnostics.

**High-value improvements:**
2. Add a brief discussion of why the residualized exposure might be insignificant due to attenuation (not just confounding).
3. The triple-difference p-values should be presented in the abstract or introduction to calibrate expectations early.

**Optional polish:**
4. Consider adding a binscatter of census stock vs. SCI to validate the correlation visually (exhibit review also flagged this).

## PART 2: CONSTRUCTIVE SUGGESTIONS

- The paper would benefit from Conley spatial HAC standard errors as a robustness check, given the geographic nature of treatment.
- A dose-response specification (e.g., quintile dummies × Post) would complement the continuous treatment.
- The exchange rate mechanism is the strongest identification channel — consider giving it more prominence.

## 7. OVERALL ASSESSMENT

**Key strengths:** Novel identification strategy; honest reporting of results; comprehensive robustness battery; genuinely pre-determined exposure measure.

**Critical weaknesses:** Census stock result does not survive département trends; triple-difference is imprecisely estimated; German placebo remains dominant in standard DiD.

**Publishability:** The paper makes a genuine methodological contribution to the SCI literature by demonstrating how to diagnose and address cosmopolitan confounding. The empirical results are mixed but honestly reported. Suitable for AEJ: Economic Policy or similar with revisions.

DECISION: MINOR REVISION
