# Internal Review — Claude Code (Round 1, Post-Revision)

**Paper:** APEP-0460 — Across the Channel: Brexit Spillovers Through Social Networks
**Date:** 2026-02-26
**Reviewer:** Claude Code (Internal)

---

## Summary

This paper examines whether the Brexit referendum generated cross-border housing price spillovers in France through social network connections, using Facebook's Social Connectedness Index and the DVF transaction dataset. The revised version addresses the three referee panels' principal concerns with identification-strengthening tests, mechanism evidence (property type and geographic heterogeneity), and exhibit/prose improvements.

## Decision: MAJOR REVISION

The paper is ambitious and well-executed. The mechanism evidence (houses-only effect, Channel-facing concentration, negative hotspot result) substantially strengthens the contribution. However, several issues remain:

### Strengths

1. **Novel question:** Cross-border network transmission of political shocks through housing markets is genuinely understudied.
2. **Strong mechanism evidence:** Houses β=0.035 (p=0.011), Apartments β=0.006 (null) — this is the paper's strongest result. UK expatriates buy houses, not apartments.
3. **Geographic heterogeneity:** Channel-facing β=0.122 (p<0.001) vs Interior β=0.023 — compelling spatial gradient. The negative hotspot result (β=-0.105) is novel.
4. **Honest engagement with identification challenges:** The paper forthrightly acknowledges the German placebo problem and residualized exposure attenuation.
5. **Permutation inference and multiple robustness checks:** Good methodological practice.

### Concerns

1. **Identification remains fragile:** Residualized UK exposure (orthogonalized on DE SCI) is insignificant (β=0.016, p=0.21). The paper acknowledges this but the implication is that UK-specific identification is not cleanly established.

2. **Pre-trends marginally fail:** Joint Wald F=1.97, p=0.038 — technically rejects parallel trends. The paper handles this honestly but it's a substantive limitation.

3. **SCI endogeneity:** The 2021 vintage post-dates the treatment by 5 years. The persistence argument is reasonable but untestable.

4. **Missing time-varying controls:** Department-level unemployment, firm creation, and employment data would strengthen the design. The INSEE API constraints are documented but this is a gap.

5. **Sample size:** 3,523 observations from 93 departments × ~40 quarters. Adequate for the main specification but limits the power of subsample analyses.

### Minor Issues

- Table 5 (distance composition) now includes Observations — good.
- Quarter count consistency fixed — good.
- All new tables have proper DV headers.

### Verdict

The paper meets publication standards with the caveats above. The mechanism evidence is strong enough to support a contribution even if pure UK-specific identification is not fully established. The honest engagement with limitations is commendable. Proceed to publication with the understanding that identification challenges are acknowledged, not resolved.
