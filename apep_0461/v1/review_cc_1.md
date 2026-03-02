# Internal Review - Round 1

**Reviewer:** Claude Code (Internal)
**Paper:** Does Oil Kill Children? Testing the Resource Curse-Child Mortality Nexus After the 2014 Price Crash
**Date:** 2026-02-26

---

## PART 1: CRITICAL REVIEW

### 1. Identification and Empirical Design

**Strengths:**
- The 2014 oil price crash is a genuinely large, plausibly exogenous shock to oil-dependent countries' fiscal capacity
- The continuous treatment design (pre-crash oil rents x Post2014) is a reasonable Bartik-style approach
- Country and year FE absorb level differences and global trends
- Event study shows flat pre-trends supporting parallel trends assumption
- 135 countries with 30 treated provide adequate statistical power

**Concerns:**
- The design is a standard cross-country DiD with continuous treatment intensity. While the oil price crash was exogenous, oil *dependence* is not randomly assigned. Countries with high oil rents differ systematically from non-oil countries in governance, conflict exposure, and institutional quality. The fixed effects help but cannot fully address time-varying unobservable confounders.
- The post-treatment window (2014-2023) includes COVID-19, which differentially affected health systems. While time windows excluding COVID produce similar null results, this concurrent shock complicates interpretation.
- Under-5 mortality data for many developing countries are modeled estimates (UN IGME), not vital registration. Measurement error in the outcome would attenuate effects toward zero, potentially contributing to the null finding.

### 2. Inference and Statistical Validity

- Standard errors clustered at country level are appropriate
- 135 clusters (30 treated) exceeds conventional thresholds for reliable inference
- CIs are reported alongside point estimates
- The MDE calculation (0.27 per pp of oil rents) is clearly presented
- Power analysis adequately bounds the informativeness of the null

### 3. Robustness and Alternative Explanations

- Six robustness specifications in Table 5, plus region-specific, time window, and SWF interaction analyses
- Placebo tests (fake timing, placebo outcome) both produce null results as expected
- The total resource rents specification showing a marginally significant *negative* effect is intriguing and deserves more discussion
- The mechanism analysis (health spending increases rather than decreases) is the paper's most novel contribution

### 4. Contribution and Literature Positioning

- Well-positioned against Sachs & Warner, Ross, Dube & Vargas, Bazzi & Blattman
- The null result contributes to the growing revisionist literature on the resource curse
- Missing some key references: Haber & Menaldo (2011) on the political resource curse, Caselli & Michaels (2013) on oil windfalls in Brazil, Arezki & Bruckner (2011) on commodity prices and democratization

### 5. Results Interpretation

- The paper does a good job framing the null honestly
- The mechanism finding (health spending maintained/increased) is appropriately caveated with the GDP denominator effect
- Policy implications are proportional to evidence strength
- The conclusion about energy transition implications is speculative but appropriately flagged

## PART 2: CONSTRUCTIVE SUGGESTIONS

### Must-fix:
1. Add missing literature references (Haber & Menaldo, Caselli & Michaels)
2. Discuss the GDP denominator effect more carefully - the increase in health expenditure as % of GDP may be entirely mechanical
3. Address the WDI mortality measurement concern more prominently

### High-value improvements:
1. Add a specification using absolute health spending (not % of GDP) to test whether the denominator effect drives the mechanism result
2. Consider a heterogeneity analysis by institutional quality (Polity score)
3. Discuss the role of international health aid more systematically

### Optional:
1. A formal F-test for joint significance of pre-period event study coefficients
2. Wild cluster bootstrap p-values given moderate cluster count

## OVERALL ASSESSMENT

This is a well-executed null result paper with a credible identification strategy, honest reporting, and a genuinely interesting mechanism finding. The research question is important and the answer (no effect) is informative. The paper's main limitation is that the null could partly reflect measurement error in modeled mortality data rather than a true absence of effect. The mechanism analysis (health spending maintained) is the most novel contribution and could be developed further.

DECISION: MINOR REVISION
