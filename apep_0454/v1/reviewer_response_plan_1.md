# Reviewer Response Plan — Round 1

**Date:** 2026-02-26
**Reviews:** GPT-5.2 (Major Rev), Grok-4.1-Fast (Minor Rev), Gemini-3-Flash (Minor Rev)

## Priority 1: Must-Fix

### 1.1 Exit Definition Clarity
- Add explicit definition of "active provider" (≥1 claim in month)
- Note ln(x+1) transformation for zeros
- Add sentence about intermittent billing patterns

### 1.2 Inference Strengthening
- Add wild cluster bootstrap p-values for main specification
- Increase RI permutations from 500 to 1,000 (hardware constrained)

### 1.3 Non-HCBS Placebo
- Run main specification on non-HCBS providers as falsification test
- If insignificant, strengthens HCBS-specific channel claim

### 1.4 DDD Reframing
- Reframe Part 2 as descriptive/suggestive rather than causal
- Acknowledge lack of cross-state ARPA implementation variation

## Priority 2: High-Value

### 2.1 Time-Window Effects
- Report separate effects for pandemic first year, second year, post-ARPA
- Better match claims to time periods

### 2.2 Literature Updates
- Add Callaway & Sant'Anna 2021 citation
- Add Goodman-Bacon 2021 reference

## Priority 3: Prose Improvements (from prose review)
- Opening hook (already fixed — $14.15/hr lead)
- Tighten ARPA results narration

## Execution Order
1. Run non-HCBS placebo + wild bootstrap in R
2. Update paper.tex with all fixes
3. Recompile and verify
