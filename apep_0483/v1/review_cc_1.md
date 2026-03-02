# Internal Review - Round 1

**Date:** 2026-03-02

## 1. Identification and Empirical Design

**Strengths:**
- The interaction between nationally uniform teacher pay and spatially heterogeneous private wages creates a plausible source of cross-sectional variation.
- The DR-AIPW framework is appropriate for an observational cross-sectional design under unconfoundedness.
- Treatment definition (bottom quartile of competitiveness change) is transparent and replicable.

**Weaknesses:**
- No pre-treatment outcome data (KS4 only available from 2018/19), so parallel trends cannot be tested.
- The placebo test (2005-2010 competitiveness change) yields a coefficient of -1.12 (p=0.101), which is concerning — it suggests pre-existing differences.
- Cross-sectional identification relies entirely on selection-on-observables, with only two covariates (baseline pay and urban proxy).

## 2. Inference and Statistical Validity

- Standard errors correctly use heteroskedasticity-robust estimates.
- Sample sizes are now clearly reconciled (146 raw, 141 analysis, 133 trimmed logistic, 141 RF).
- RI p-value of 0.236 for OLS specification raises concerns about significance depending on estimator choice.
- The RF-AIPW's improved precision over the parametric version warrants further investigation — could be an artifact of the RF smoothing.

## 3. Robustness

- Oster delta of 2.13 is encouraging.
- Leave-one-region-out analysis revealing sign flip when excluding Unitary authorities is a significant fragility.
- Alternative treatment definitions (median, tercile) yield null results, suggesting effects concentrated in the extreme tail.

## 4. Contribution

- Paper fills a gap: causal evidence on teacher pay and achievement within a single country using real pay variation.
- Literature positioning is adequate, citing Hanushek, Chetty, Rivkin, Dolton, Britton & Propper, Hendricks, Sims.
- Could benefit from citing Nagler, Piopiunik, and West (2020) on teacher pay and quality in Germany.

## 5. Results Interpretation

- The paper honestly presents the evidence as "suggestive rather than definitive" — this is appropriate given the limitations.
- Policy implications are proportionate to evidence.

## 6. Actionable Revision Requests

1. **Must-fix:** Acknowledge the placebo test concern more prominently in the introduction.
2. **High-value:** Add a discussion of why the RF-AIPW is more precise than the parametric version, beyond "flexible functional form."
3. **Optional:** Consider adding school-level variation data from DfE school workforce statistics to support the supply mechanism.

## 7. Overall Assessment

- **Strengths:** Novel policy variation, appropriate methodology, honest treatment of limitations, well-written.
- **Weaknesses:** Limited covariates, concerning placebo, fragility to region composition, no pre-treatment outcomes.
- **Publishability:** Solid working paper. With stronger placebo and additional covariates, could target a field journal.

DECISION: MINOR REVISION
