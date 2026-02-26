# Reviewer Response Plan - Round 1

## Common Concerns Across Reviewers

### 1. Pre-Trend (All 3 reviewers)
- **Issue**: Marginally significant pre-trend (p=0.08) threatens parallel trends assumption
- **Fix**:
  - Add HonestDiD (Rambachan-Roth) sensitivity analysis bounding the effect under plausible trend violations
  - Add state-specific linear trends specification
  - Report joint test of pre-period event-study coefficients

### 2. ARPA Narrative (GPT, Gemini)
- **Issue**: Pre-ARPA coefficient becomes insignificant; story shifts from "decline" to "differential recovery"
- **Fix**: Reframe ARPA result as descriptive heterogeneity, acknowledge the narrative tension explicitly

### 3. Monopsony Language (GPT)
- **Issue**: Wage ratio is a proxy, not direct Medicaid rate evidence
- **Fix**: Soften to "consistent with monopsony" language throughout; acknowledge proxy nature explicitly

### 4. Inference Strengthening (GPT)
- **Issue**: RI only 500 permutations; wild cluster bootstrap missing
- **Fix**: Increase RI to 5,000 permutations

### 5. Exhibit Improvements (Exhibit Review)
- Re-scale COVID cases to per 10,000 to eliminate scientific notation

### 6. Prose Improvements (Prose Review)
- Kill passive voice in robustness section
- Tighten roadmap paragraph
- Sharpen results narration

## Execution Order

1. Add robustness code (HonestDiD, state trends, expanded RI)
2. Re-run analysis pipeline
3. Update paper text (claims, ARPA framing, prose)
4. Regenerate tables
5. Recompile PDF
