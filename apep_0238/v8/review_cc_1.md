# Internal Review (Round 1)

**Reviewer:** Claude Code (internal)
**Paper:** Demand Recessions Scar, Supply Recessions Don't
**Date:** 2026-02-26

## PART 1: CRITICAL REVIEW

### 1. Identification and Empirical Design
The paper uses a compelling natural experiment: comparing state-level employment responses to two recessions with fundamentally different etiologies. The identification strategy relies on Bartik shift-share instruments for industry composition shocks and Saiz housing supply elasticity for the Great Recession demand channel.

**Strengths:**
- Bartik decomposition with Rotemberg weights addresses Goldsmith-Pinkham et al. (2020) concerns
- IV estimates using Saiz elasticity provide causal variation for the demand channel
- Within-GR horse race (Table 5) distinguishes housing demand from industry composition
- 50-state × 84-month panel provides adequate power

**Concerns:**
- The COVID "supply shock" interpretation assumes industry composition captures the exogenous shutdown channel, but industries that reopened quickly (e.g., construction) may confound the demand/supply distinction
- Leave-one-out robustness (excluding Leisure & Hospitality) weakens but doesn't eliminate significance — appropriate to note

### 2. Inference and Statistical Validity
- Standard errors clustered by state (50 clusters) — adequate
- Permutation inference (Figure 8) provides exact p-values for finite-sample validity
- Conley spatial HAC in appendix addresses geographic correlation
- Sample sizes consistent across specifications

### 3. Robustness and Alternative Explanations
- Placebo tests, event study pre-trends, migration decomposition all present
- Subsample analysis (pre/post, industry subsets) thorough
- Missing: formal test of parallel trends assumption beyond visual inspection

### 4. Contribution and Literature Positioning
Strong positioning against Yagan (2019), Kroft et al. (2016), Barrero et al. (2023). The DMP model with SMM estimation is a genuine contribution over ad-hoc calibration.

### 5. Results Interpretation
- The 71:1 welfare ratio under risk neutrality is the headline finding and is well-supported by the model
- CRRA results (up to 330:1 at ρ=5) appropriately caveat sensitivity to risk aversion
- SMM fit is honest about unemployment rate gap (2.3 pp vs target)

## PART 2: CONSTRUCTIVE SUGGESTIONS

### Must-Fix
1. None remaining after 7 rounds of theory review and advisor review pass

### High-Value Improvements
1. Add formal pre-trend test (e.g., Roth 2022 pre-test) beyond visual event study
2. Consider discussing heterogeneity by worker demographics (age, education)
3. Welfare comparison could acknowledge that different discount rates might narrow the ratio

### Optional Polish
1. Figure 7 counterfactuals are busy — consider splitting into panels (exhibit review also flagged)
2. The mechanism flowchart (Figure 5) could move to appendix

## OVERALL ASSESSMENT

**Key Strengths:** Novel demand-vs-supply recession comparison, rigorous structural model with formal estimation, comprehensive robustness battery.

**Critical Weaknesses:** None that would block acceptance. Minor concerns about the supply/demand classification being perfectly clean.

**Publishability:** High. Suitable for AEJ: Economic Policy or similar.

DECISION: MINOR REVISION
