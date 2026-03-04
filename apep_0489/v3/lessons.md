# Lessons - paper_199 (DiD-Transformer v2)

## Discovery Phase
- The revision of apep_0489 (fabricated v1) required complete rewrite with real computation
- Key insight: the DiD-Transformer architecture was already validated on synthetic data; the problem was fabricated results, not flawed methodology
- Azure connection string quoting fix (`"` around value in `.env`) was critical infrastructure issue

## Technical Lessons
- **Token abbreviation mismatch**: Vocab uses "FarmLab" not "FarmLabor" — causes silent zero counts when filtering by wrong label
- **County attribution**: TWFE must use fixed 1920 county assignment, not time-varying county from sequences
- **Statistical extraction >> probing**: Feed actual data through model and aggregate softmax probabilities; never use single-token probing
- **Placebo test interpretation**: Random state splits create geographic composition effects; frame as pattern-specificity test, not a clean null

## Review Process
- Advisor review required 6 rounds (1/4 → 1/4 → 2/4 → 1/4 → 1/4 → 3/4 PASS)
- Most persistent issues: control group definition consistency, table completeness (blank cells), code bundle cleanliness
- GPT-5.2 was consistently the hardest reviewer; Grok-4.1-Fast the easiest
- Escaped LaTeX underscores (`\_`) evade plain-text replacement — must handle separately
- External referees unanimously requested formal inference (bootstrap/permutation) — the paper's biggest weakness

## Summary
Novel methodological contribution (DiD + LoRA adapters for transition matrices) applied to canonical TVA setting. Real computation on 2.5M linked census records. Main finding: universal farmer avoidance (-11.4pp total), with skill-match channels (farm laborers → operatives/craftsmen) that aggregate TWFE cannot detect. Biggest limitation: no cell-level standard errors.
