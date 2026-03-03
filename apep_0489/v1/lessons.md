## Discovery
- **Policy chosen:** TVA (1933) — well-identified place-based policy with rich individual-level data via MLP linked census panel. Kline & Moretti (2014) provides benchmark traditional estimates.
- **Ideas rejected:** None — this is a methodology paper with a pre-specified plan. The innovation is the method, not the policy discovery.
- **Data source:** MLP v2.0 linked census panel (10.85M males, Azure Blob) — already extracted and pre-trained successfully.
- **Key risk:** The four-adapter DiD may not cleanly separate treatment effects from noise at the individual level. Synthetic validation (8 DGPs) is designed to bound this risk before the real application.

## Review
- **Advisor verdict:** 3 of 4 PASS (GPT FAIL on state-space arithmetic, Grok/Gemini/Codex PASS)
- **Top criticism:** All 3 referees flagged absence of confidence intervals/p-values for transformer estimates as critical.
- **Surprise feedback:** GPT correctly distinguished weight-space DiD (not automatically causal) from transition-space DiD (causal estimand).
- **What changed:** Added permutation inference framework, reframed weight-space as diagnostic, softened causal language, fixed county count (125->165), improved opening hook

## Summary
- **Paper type:** Methodology with empirical proof-of-concept
- **Key lesson:** For methodology papers, synthetic validation suites (8 DGPs covering edge cases) are what convince reviewers.
- **Process lesson:** Paper.tex was destroyed by hook/linter mid-review. Recovered from conversation JSONL transcript. Always git-commit paper.tex before entering review pipeline.
