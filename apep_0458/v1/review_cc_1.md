# Internal Review — Claude Code (Round 1)

**Role:** Reviewer 2 (harsh, skeptical)
**Paper:** Second-Home Caps and Local Labor Markets: Evidence from Switzerland's Lex Weber
**Timestamp:** 2026-02-26

---

## PART 1: CRITICAL REVIEW

### 1. Identification and Empirical Design

The paper exploits the sharp 20% second-home share threshold created by Switzerland's 2012 Zweitwohnungsinitiative. This is a textbook RDD setting: a constitutional threshold set by popular referendum, not legislative bargaining. The design is credible for estimating local effects near the cutoff.

**Key concern:** The running variable uses current (not pre-policy) second-home shares. The paper acknowledges this limitation and provides several mitigating arguments: (1) the ban affects new construction, not existing classifications; (2) 99.2% of municipalities have definitive status; (3) the null result is conservative since any running variable drift would bias toward finding effects. While this is an honest and reasonable discussion, it remains the primary weakness. Pre-2012 municipality-level ZWA data would strengthen the design substantially.

**Treatment timing:** The paper uses 2011-2012 as the pre-period, arguing that annual STATENT data captures employment structures before the December 2012 ordinance's permitting effects materialized. This is defensible but imperfect — the March 2012 vote itself could have triggered anticipatory responses.

### 2. Inference and Statistical Validity

Standard errors are computed using the robust bias-corrected procedure of Calonico, Cattaneo, and Titiunik (2014). Bandwidth selection is CCT-optimal. The paper correctly notes that bias-corrected p-values may not correspond to simple t-ratios, which is important for reader interpretation.

The log employment specification has low statistical power (N=104, SE=1.139). The paper is honest about this limitation, but it means the log-level results are essentially uninformative — the confidence interval spans from a 600% increase to an 80% decrease.

Tourism analysis is appropriately moved to the appendix given N_right=3.

### 3. Robustness

The battery of robustness checks is comprehensive:
- Bandwidth sensitivity (0.5x to 2x)
- Polynomial order (1-3)
- Kernel function (triangular, uniform, Epanechnikov)
- Placebo thresholds (10%, 12%, 15%, 25%, 30%, 35%)
- Donut-hole specifications (±0.5, ±1, ±2 pp)
- Event study (year-by-year 2011-2023)
- Covariate balance (4 covariates, common bandwidth)
- McCrary density test

All produce null results, supporting the main finding.

### 4. Contribution and Literature

The paper contributes to the housing regulation and local labor market literatures. The Lex Weber setting is novel and well-suited for RDD analysis. The null result is a meaningful contribution — it challenges the narrative that construction restrictions necessarily harm local economies.

**Missing literature:** Could cite Saiz (2010) on housing supply elasticity, Glaeser and Gyourko (2005) on housing regulation costs, and Brunetti and Weder (2003) on Swiss direct democracy effects.

### 5. Results Interpretation

The null result is appropriately calibrated. The paper correctly distinguishes between the tight confidence interval for employment growth (ruling out >20pp changes) and the imprecise log-level estimates. The conceptual framework provides reasonable mechanisms for why the null might arise (substitution toward tourism-linked construction, labor mobility).

**Minor overclaiming:** The event study section previously used "confirms" language for a pattern with wide confidence intervals. This has been softened appropriately.

### 6. Actionable Revision Requests

**Must-fix:**
1. None remaining — the paper addresses its limitations honestly.

**High-value improvements:**
1. Obtain pre-2012 ZWA data if possible (archival research, ARE data requests)
2. Add power calculations — what minimum detectable effect does the design support?
3. Extend tourism analysis with establishment-level data

**Optional polish:**
1. Improve figure aesthetics per exhibit review
2. Strengthen opening hook per prose review
3. Add difference-in-means column to Table 1

## PART 2: CONSTRUCTIVE SUGGESTIONS

The paper's contribution would increase substantially with:
- A power analysis showing the MDE given the sample size and design
- A formal fuzzy RDD specification instrumenting actual policy exposure with current ZWA
- Establishment-level analysis using STATENT microdata (new firm entry/exit near threshold)

## 7. Overall Assessment

**Strengths:** Clean RDD setting, comprehensive robustness, honest engagement with limitations, well-structured null result paper.

**Weaknesses:** Running variable uses post-policy measurement; low power for log-level outcomes; limited tourism data.

**Publishability:** Suitable for a field journal after minor revisions. The AEJ: Economic Policy or Journal of Urban Economics would be appropriate targets.

DECISION: MINOR REVISION
