# Internal Review - Round 1

**Reviewer:** Claude Code (Internal)
**Date:** 2026-03-03
**Paper:** DiD-Transformer Framework

## PART 1: CRITICAL REVIEW

### 1. Identification and Empirical Design

**Strengths:**
- The four-adapter LoRA design with temporal loss masking is a genuinely creative approach to embedding DiD logic in neural network fine-tuning.
- Parallel trends are testable in the transition-space via the pre-trends MAE diagnostic.
- Treatment assignment is intent-to-treat (1920 county of residence), avoiding endogenous migration concerns.

**Concerns:**
- The weight-space DiD lacks formal asymptotic theory. The paper acknowledges this but relies on synthetic validation and comparison with traditional DiD as substitutes. This is the paper's most significant limitation.
- The 1933 TVA establishment straddling the 1930-1940 decade is now acknowledged in the text, but the attenuation argument could be more precise about what "conservative lower bound" means quantitatively.

### 2. Inference and Statistical Validity

- No formal inference (p-values, confidence intervals) is available for the transition-space DiD estimates. The paper uses three alternatives: pre-trends, synthetic validation, and comparison with traditional TWFE (which does have inference).
- The traditional TWFE section provides proper clustered standard errors at the state level.
- For a methodology paper, this is acceptable—the contribution is the framework, not a single empirical result.

### 3. Robustness and Alternative Explanations

- Eight synthetic DGPs provide thorough stress-testing of the method.
- Five ablation studies isolate each design choice.
- Comparison with traditional DiD serves as an external benchmark.
- Missing: placebo in the transformer framework (e.g., fake treatment on random counties).

### 4. Contribution and Literature Positioning

- Well-positioned at the intersection of causal inference (DiD), representation learning (transformers), and labor economics (career transitions).
- Clear differentiation from CAREER (Vafa et al.), Kline & Moretti, Ilharco et al.
- Literature coverage is solid for all three strands.

### 5. Results Interpretation

- Claims are generally well-calibrated. The paper does not claim the method replaces traditional DiD but rather complements it for distributional outcomes.
- The 576-token vocabulary and its construction are now clearly explained (1,440 theoretical, 576 with sufficient frequency).

## PART 2: CONSTRUCTIVE SUGGESTIONS

1. **Add a permutation-based placebo test:** Randomly assign TVA treatment to non-TVA counties and run the four-adapter pipeline. This would provide a null distribution for the transition-space DiD.
2. **Formal inference is the open frontier:** Discuss more concretely what a formal inferential theory might look like (e.g., bootstrap over the full pipeline, asymptotic normality of the LoRA parameters).
3. **Figures:** The paper would benefit from at least one visual — a heatmap of the 6x6 transition DiD matrix would be more impactful than the table.

## 6. Actionable Revision Requests

### Must-fix:
1. None remaining after the advisor review fixes (county count, placeholders, treatment timing).

### High-value:
1. Add a permutation placebo test in the transformer framework.
2. Improve the opening paragraph per prose review suggestions.

### Optional:
1. Move detailed ablation tables to appendix, keep summary in main text.
2. Add a map of the TVA study area.

## 7. Overall Assessment

**Key strengths:** Genuine methodological innovation; thorough synthetic validation; strong empirical application with 10.85M individuals; clear comparison with traditional methods.

**Critical weaknesses:** Lack of formal inference for the core estimand; no permutation-based placebo.

**Publishability:** This is a methods paper with a strong empirical application. The lack of formal inference is a limitation but is honestly acknowledged and partially addressed through synthetic validation. Publishable in a top methods-focused journal after minor revisions.

DECISION: MINOR REVISION
