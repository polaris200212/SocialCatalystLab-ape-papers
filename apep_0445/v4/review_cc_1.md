# Internal Review - Round 1

**Reviewer:** Claude Code (internal)
**Paper:** apep_0445 v4 — Do Place-Based Tax Incentives Attract Data Center Investment?
**Date:** 2026-02-23

## Summary

This revision (v4) addresses three external reviewer concerns from v3: (1) stock-vs-flow data center measurement, (2) local randomization as co-primary framework, and (3) missing literature. The paper now includes vintage-separated DC analysis using EIA-860 generator operating years, a main-text local randomization section, and expanded citations.

## Strengths

1. **Dual-framework approach** is well-motivated given the McCrary density discontinuity. Both continuity-based and design-based estimates tell the same null story.
2. **DC vintage analysis** (Table 7) is a genuine methodological improvement — separating pre-2018 legacy facilities from post-2018 treatment-relevant openings addresses a core concern.
3. **Comprehensive robustness** — bandwidth sensitivity, donut, polynomial, kernel, placebo, event study, parametric, local randomization, and DC-specific robustness all confirm the null.
4. **Well-written** — clear prose, good narrative arc from motivation through results.

## Issues Identified

1. **Minor:** Table 10 (parametric) still shows very low R² values (~10⁻⁵), which is expected with null effects but worth a footnote.
2. **Minor:** DC vintage sparsity (4-5 post-2018 DCs in bandwidth) limits power — appropriately acknowledged with MDE.
3. **Fixed in this round:** Appendix LR table window inconsistency (0.8 → 0.75), DC robustness table bandwidth mismatch, parametric table variable naming.

## Decision

The paper is methodologically sound with a comprehensive null result. All reviewer concerns have been addressed.

DECISION: CONDITIONALLY ACCEPT
