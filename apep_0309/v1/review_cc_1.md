# Internal Review (Round 1)

**Reviewer:** Claude Code (self-review)
**Paper:** The Balloon Effect: How Neighboring States' Prescription Drug Monitoring Programs Reshape the Geography of Opioid Mortality
**Date:** 2026-02-16

---

## Summary

This paper studies interstate spillovers from must-query PDMP mandates using a novel network exposure measure. The identification relies on staggered adoption with TWFE and Callaway-Sant'Anna doubly robust DiD. Main finding: high network exposure (>=50% of neighbors treated) increases overdose deaths by 2.77/100k (TWFE) or 6.09/100k (CS-DiD).

## Strengths

1. **Novel exposure measure**: The population-weighted network exposure variable is a genuine methodological contribution to the PDMP literature.
2. **Modern methods**: Correct use of Callaway-Sant'Anna DR to address TWFE bias under staggered adoption.
3. **Comprehensive robustness**: Dose-response thresholds, leave-one-out, Cinelli-Hazlett sensitivity, region×year FE, propensity score overlap — the robustness suite exceeds most published papers.
4. **Clear writing**: Strong opening hook, Shleifer-quality prose, accessible to non-specialists.
5. **Policy relevance**: Direct implications for federal PDMP coordination.

## Weaknesses Identified

1. **Missing confidence intervals**: Tables report SEs but not 95% CIs for headline effects.
2. **Interference framework not formalized**: SUTVA is violated by design but potential outcomes under exposure mapping not defined.
3. **Drug-type suppression**: Differential missingness by exposure status could bias drug-type decomposition.
4. **Limited mechanism evidence**: No direct evidence of cross-border prescribing displacement.
5. **Literature gaps**: Missing key modern DiD references (Sun-Abraham, Roth) and interference literature (Aronow-Samii).

## Verdict

**MINOR REVISION** — The core identification is credible, robustness is strong, and writing is excellent. Address CIs, formalize the interference framework, and improve the literature positioning.

## Action Items

1. Add 95% CIs throughout
2. Add "Estimand Under Interference" subsection
3. Add missing literature citations
4. Discuss drug-type suppression more carefully
5. Test second-order exposure robustness
