# Internal Review — Round 1

**Paper:** Connected Backlash: Social Networks, Carbon Tax Incidence, and the Political Economy of Climate Policy in France
**Reviewer:** Claude Code (self-review)
**Date:** 2026-02-26

## Verdict: MINOR REVISION

## Summary

This paper examines how social networks amplify political backlash against France's carbon tax by combining commune-level election data (~35,000 communes, 6 elections) with Facebook's Social Connectedness Index. The core finding is that network exposure to fuel-vulnerable départements raises RN vote share by 0.48 pp/SD (p<0.01), nearly 3x the direct own-exposure effect (which is itself insignificant). A SAR structural model yields ρ=0.97, implying massive network amplification.

## Strengths

1. **Novel and important question.** The social network channel for carbon tax backlash is genuinely understudied. The connection to Gilets Jaunes makes it timely.

2. **Credible identification.** Shift-share design using pre-existing SCI connections is well-motivated. Bartik diagnostics show low concentration (HHI=0.025) and reasonable exogeneity.

3. **Comprehensive robustness.** Distance restrictions (>200km), placebo (turnout), LOO (100% significant, range 0.42-0.56), income controls, post-GJ subsample all support the main finding.

4. **Structural estimation.** SAR model provides a disciplined framework for quantifying the network multiplier, not just showing it exists.

5. **Beautiful maps and figures.** The geographic visualizations effectively convey the spatial variation.

## Weaknesses and Suggestions

### Methodology

1. **ρ=0.97 interpretation.** The network contagion parameter is implausibly close to 1, implying a spatial multiplier of ~33. This could reflect model misspecification (omitted common shocks, correlated effects) rather than true contagion. The paper should discuss this limitation more explicitly and consider what Manski's reflection problem means here.

2. **Randomization inference p-value for network coefficient is NaN.** This is reported in the robustness summary but not adequately explained. The RI test for the network coefficient failed—this should be diagnosed and fixed (likely a computational issue with the permutation test).

3. **Pre-treatment period.** Only 1 pre-treatment election (2012). The 2014 European election is already post-carbon-tax (CCE introduced in 2014 Finance Law). With just one pre-treatment observation, parallel trends is hard to credibly test.

4. **TWFE with staggered timing concerns.** The paper uses a simple post indicator rather than cohort-specific treatment timing. Since the carbon tax applies nationally and simultaneously, this is actually appropriate—but the paper should explicitly note that the treatment is a continuous dose (fuel vulnerability), not binary adoption.

### Content

5. **Main text length.** At 25 pages, the paper meets the minimum threshold but is thin given the ambition of the project. The institutional background and data sections could be expanded with more detail on the SCI construction, commune-election matching, and fuel vulnerability measurement.

6. **Missing discussion of alternative mechanisms.** Could the results reflect media contagion (TV/newspaper coverage) rather than social network contagion? The paper should discuss how to disentangle SCI-based social ties from media market overlap.

7. **Counterfactual simulation.** The claim that eliminating network contagion would reduce RN vote share by 4.4pp relies heavily on the SAR model's assumptions. This should be presented more cautiously.

### Presentation

8. **Table labels.** kableExtra tables lack \label commands, making cross-referencing difficult. The paper uses descriptive text instead of \ref{} which works but is inelegant.

9. **Abstract.** Strong and specific. No changes needed.

10. **Introduction.** Well-structured with clear hook, method, results, and contributions. Could be slightly tightened.

## Required Changes

1. Diagnose and fix the NaN RI p-value for the network coefficient
2. Add discussion of Manski reflection problem and ρ interpretation
3. Expand main text to at least 28-30 pages (add detail to Data and Background sections)
4. Discuss media contagion as alternative mechanism

## Minor Issues

- LeSage reference type fixed (article→book) ✓
- All figures render correctly ✓
- All tables compile ✓
- Bibliography resolves correctly ✓
