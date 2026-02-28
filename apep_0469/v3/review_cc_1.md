# Internal Claude Code Review — Round 1

**Paper:** apep_0469 v3 — Missing Men, Rising Women
**Reviewer:** Claude Code (internal)
**Date:** 2026-02-28

---

## Reviewer 2 Assessment (Harsh)

### Strengths
1. **Data innovation is genuine.** The 3-wave MLP panel (43.5M individuals, 1930-1940-1950) is a real advance over repeated cross-sections. The scale is impressive.
2. **Pre-trend test is clean.** Near-zero coefficients for both men and wives in 1930-1940 changes, supporting parallel trends.
3. **Exhaustive robustness.** 11 robustness specifications in Table 11, plus RI, LOO, binned scatter, Oster delta. The null result is genuinely robust.
4. **Honest about limitations.** The paper acknowledges positive selection, noisy mobilization measure, and couples-panel restrictions throughout.

### Weaknesses
1. **Decomposition residual lacks formal inference.** The -0.0011 residual is tiny and presented without standard errors. The text now correctly hedges ("not statistically distinguishable from zero"), but a state-level bootstrap would strengthen this.
2. **Mobilization measure not validated against established benchmarks.** The CenSoc Army enlistment rate is weakly correlated with interstate movers (R²=0.004). Without comparison to ACL's Selective Service inductions, readers cannot tell if the null is measurement attenuation or genuine.
3. **Couples panel conditions on marital survival.** Women who divorced, became widows, or remarried are excluded — precisely the women whose wartime experience was most disruptive. This selection is acknowledged but not quantified.
4. **State-level negative coefficient unexplored.** The micro-level null vs state-level negative (-0.005, p<0.10) tension deserves more investigation.

### Minor Issues
- Table 5 (OCCSCORE) has dramatically smaller N than other tables — adequately explained in notes but could be clearer in text.
- The 1930 LFP definition (CLASSWKR > 0) is standard but could benefit from an additional citation validating comparability.

## Editor Assessment (Constructive)

This is a strong empirical paper that uses modern data-linking techniques to bring individual-level evidence to a canonical question. The key contributions are:
1. The decomposition showing within-couple gains ≈ aggregate gains (compositional turnover neutral)
2. The pre-trend test validating the identification strategy
3. The household complementarity finding (negative husband-wife correlation)

The paper correctly positions mobilization gradients as secondary and descriptive rather than causal. The prose is clear and the conclusion frames the contribution well.

**Verdict:** MINOR REVISION — ready for external review.

The remaining weaknesses (decomposition inference, mobilization validation) are acknowledged limitations that would require substantial new data/computation to address. They do not invalidate the paper's core contribution.
