# Internal Review — Round 1

**Reviewer:** Claude Code (internal)
**Paper:** Connected Backlash: Social Networks and the Political Economy of Carbon Taxation in France
**Date:** 2026-02-26

---

## 1. Identification and Empirical Design

**Strengths:** The shift-share design using SCI × fuel vulnerability is well-motivated. The identification argument is clear: SCI measures social connections formed for many reasons (family, education, work) that are plausibly exogenous to the carbon tax. The 200km distance restriction is a clever way to separate social from geographic proximity.

**Concerns:**
- The parallel trends test is reasonable with 4 pre-treatment coefficients near zero, but the 2007 coefficient is marginally significant (t = -2.24). The paper discusses this honestly.
- The SCI is measured post-treatment (2024 vintage). While Facebook friendships are persistent, there's a minor concern about reverse causality (political sorting into networks). The paper should note the vintage explicitly.

## 2. Inference and Statistical Validity

The paper commendably reports four inference methods. The WCB p=0.377 for the network coefficient is honestly discussed. The explanation (low between-cluster variation in network exposure, SD=0.02) is plausible. Block RI (p=0.002) and standard RI (p=0.001) both support significance.

**Issue:** The WCB result means the paper's strongest causal claim rests partly on the choice of inference method. The paper handles this well but should not overstate the network finding in the abstract.

## 3. Robustness

Robustness is extensive: 8 specifications, placebo parties (Green, center-right), distance restriction, leave-one-out, urban/rural heterogeneity, continuous treatment. The placebo results (both insignificant) are particularly compelling.

## 4. Contribution

Well-positioned relative to Fetzer (2019), Douenne & Fabre (2022), Flückiger & Ludwig (2025). The contribution is clear: networks transmit political backlash beyond directly affected areas.

## 5. Results Interpretation

The 2.4 multiplier from the SAR model is now well-explained (distinguishing scalar vs. nationally-weighted). The honest admission that SEM ≈ SAR means the structural interpretation is uncertain adds credibility.

## 6. Actionable Revision Requests

1. **Must-fix:** None remaining (advisor review issues addressed)
2. **High-value:** Consider mentioning SCI vintage year explicitly
3. **Optional:** Binscatter plot of ΔVoteShare vs NetworkExposure (from exhibit review)

## 7. Overall Assessment

**Strengths:** Novel question, rich data, extensive robustness, honest reporting of the WCB weakness and SAR/SEM ambiguity.
**Weaknesses:** WCB inference for network coefficient, inability to separate contagion from correlated errors structurally.
**Publishability:** Strong candidate for AEJ: Economic Policy after the current revision cycle.

DECISION: MINOR REVISION
