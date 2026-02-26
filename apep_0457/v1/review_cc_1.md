# Internal Review — Claude Code (Round 1)

**Role:** Reviewer 2 (harsh, skeptical)
**Paper:** The Lex Weber Shock: Second Home Construction Caps and Local Labor Markets in Switzerland
**Paper ID:** APEP-0457
**Date:** 2026-02-26

---

## PART 1: CRITICAL REVIEW

### 1. Identification and Empirical Design

**Strengths:**
- The Lex Weber provides a genuinely sharp, well-defined treatment with a clean 20% threshold, creating both DiD and RDD designs simultaneously.
- The paper uses administrative census data (STATENT) covering the universe of Swiss employers — no sampling concerns.
- The combination of multiple identification strategies (TWFE DiD, CS-DiD, RDD, dose-response, RI) is methodologically exemplary.

**Weaknesses:**
- **Treatment measurement timing (major):** Treatment is measured using the 2017 ARE inventory, which postdates the 2012 vote and 2016 ZWG implementation. The paper adds a discussion of why the 2017 measure is likely stable, but cannot prove it. The ideal would be a pre-2012 housing inventory, which the paper acknowledges is unavailable in comparable geospatial form. This is the paper's fundamental design limitation.
- **Pre-trends (major):** The event study shows significant positive pre-treatment coefficients (k=-5 through k=-2), and the CS pre-test formally rejects parallel trends (p=0.004). The paper honestly reports this but the parallel trends assumption — the key identifying assumption for DiD — appears violated.
- **Treatment timing ambiguity:** The policy has multiple potential onset dates (March 2012 vote, September 2012 ordinance, January 2016 ZWG). The main specification uses 2016, but alternative timing specifications (2013, 2015) yield similar results, which could mean: (a) the effect is robust to timing, or (b) the pattern is not driven by any specific policy date.

### 2. Inference and Statistical Validity

- Standard errors properly clustered at the municipality level throughout.
- Sample sizes reported and consistent across specifications (27,392 for total employment, lower for sectoral outcomes due to zeros).
- RI with 1,000 permutations provides exact inference under the sharp null — p=0.000 is compelling.
- CS estimator properly implemented with doubly-robust estimation.
- RDD uses bias-corrected robust inference from Calonico et al. (2014) — correct procedure.
- **Minor concern:** The paper does not report effective sample sizes for the CS estimator in the main text (though now reported in Table 4).

### 3. Robustness and Alternative Explanations

**Strong robustness battery:**
- Bacon decomposition (single-cohort, so clean)
- Randomization inference (1,000 perms, p=0.000)
- Alternative timing (2013, 2015)
- Placebo sector (primary/agriculture)
- Dose-response across SH share bins
- Narrow-bandwidth DiD (±5pp)
- Placebo cutoffs (10%, 15%, 25%)
- FTE as alternative outcome
- Establishments as extensive margin
- CS event study
- RDD at threshold

**Key concern:** The placebo cutoffs at 10%, 15%, and 25% all yield significant negative effects. This is a serious challenge to the Lex Weber causal interpretation — it suggests the employment decline is associated with the level of second home shares generally, not the specific 20% policy threshold. Combined with the near-threshold null (±5pp DiD), this raises questions about whether the policy threshold matters at all. The paper discusses this honestly.

### 4. Contribution and Literature

- First paper to estimate employment effects of the Lex Weber using administrative employment data — clear novelty.
- Hilber and Schöni (2020) examined housing price effects using synthetic control — complementary rather than overlapping.
- Literature coverage is adequate but could be strengthened with:
  - Ahlfeldt and Pietrostefani (2019) on the economics of density and construction regulation
  - Müller and Painter (2015) or other European second-home regulation literature
  - Saiz (2010) is cited but Gyourko and Molloy (2015) review of housing supply would contextualize better

### 5. Results Interpretation and Claim Calibration

The paper does an excellent job calibrating claims to evidence. The abstract, introduction, and conclusion all honestly acknowledge the pre-trend problem, CS attenuation, and near-threshold null. The "two interpretations" framing (causal vs. structural) is intellectually honest.

**One concern:** The RI result (p=0.000) could be misleading in isolation. The RI tests whether the *correlation* between treatment and employment change could arise by chance — but if treatment is correlated with structural factors (tourism dependence), the RI will reject even without a causal effect. The paper should note this caveat.

### 6. Actionable Revision Requests

**Must-fix:**
1. Add a sentence in the RI discussion noting that RI tests the sharp null of no treatment effect but does not address confounding from omitted variables correlated with treatment.
2. Discuss the official Swiss government list of "second home municipalities" from 2012/2013 (the Bundesamt für Raumentwicklung published a preliminary list) as a potential validation of the 2017 treatment definition.

**High-value improvements:**
3. Add a specification with canton × year fixed effects to absorb cantonal shocks (tourism trends may be canton-specific).
4. Consider a synthetic control approach for a subset of large treated municipalities (Zermatt, Davos, St. Moritz) to complement the aggregate DiD.
5. Show the distribution of pre-trend coefficients from the RI to demonstrate whether the pre-trend pattern also appears in placebo assignments.

**Optional polish:**
6. The dose-response figure shows that only the >50% bin has a significant negative effect — discuss whether the "effect" is entirely driven by the most extreme tourism municipalities.
7. Consider reporting wild cluster bootstrap p-values as an alternative to standard clustered SEs.

---

## PART 2: CONSTRUCTIVE SUGGESTIONS

The paper's greatest strength is its intellectual honesty. In a field where authors routinely cherry-pick the most favorable specification, this paper presents its complications front and center. The "two interpretations" framework is genuinely useful for readers.

The paper would be strengthened by:
1. **Canton × year FE** to absorb regional tourism trends
2. **Heterogeneity analysis** by canton or by urban/rural classification
3. **Longer pre-period** if earlier employment data is available (pre-2011 STATENT)
4. **Property price outcomes** from Wüest Partner or similar to connect to Hilber & Schöni
5. **Population/migration outcomes** to test whether people (not just jobs) leave treated municipalities

The paper makes a genuine contribution to understanding place-based regulation in Alpine communities. The honest reporting of identification challenges is itself a methodological contribution.

## 7. Overall Assessment

**Key strengths:** Sharp policy setting, administrative data, comprehensive robustness battery, intellectual honesty about identification challenges.

**Critical weaknesses:** Post-policy treatment measurement, pre-trend violations, near-threshold null, placebo cutoffs suggesting the pattern is not threshold-specific.

**Publishability:** The paper is publishable as an AEJ:Policy-level contribution with revisions. The identification challenges are significant but the honest reporting and comprehensive diagnostics partially compensate. The setting and data quality are first-rate.

DECISION: MAJOR REVISION
