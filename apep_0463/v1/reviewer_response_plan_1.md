# Reviewer Response Plan — Round 1

## Summary of Reviews
- GPT-5.2: REJECT AND RESUBMIT
- Grok-4.1-Fast: MAJOR REVISION
- Gemini-3-Flash: MAJOR REVISION

All three reviewers converge on the same core issues.

## Grouped Concerns

### 1. Parallel Trends Violation (All 3 reviewers — CRITICAL)
- Placebo tests show significant pre-crisis coefficients
- Event study pre-period is unstable
- Banking density gradient = North-South divide

**Action:**
- Add state-specific linear trends as alternative specification
- Soften all causal language throughout (abstract, intro, results, conclusion)
- Reframe as "descriptive evidence" + "cautionary tale for continuous DiD"
- Explicitly state early (abstract + intro) that design cannot speak to aggregate effects

### 2. Treatment Proxy Weakness (All 3 reviewers — CRITICAL)
- Banking density ≠ cash scarcity
- No first-stage validation
- Skewed: Lagos vs North

**Action:**
- Add "Northern state" dummy comparison (Gemini request)
- Acknowledge proxy limitations more prominently
- We lack data for POS/mobile money density or Google Trends validation

### 3. Fuel Result Needs WCB Inference (GPT — CRITICAL)
- p=0.02 from cluster-robust SE with 13 clusters may be spurious
- Multiple testing concern across commodity groups

**Action:**
- Run WCB for fuel commodity regression
- Label commodity analysis as exploratory
- Report adjusted p-values or clearly state multiple testing caveat

### 4. Prose Improvements (Exhibit + Prose reviews)
- Results section reads as "table narration" → already improved
- Strengthen opening hook → already improved
- Move RI distribution to appendix
- Move state-level treatment table to appendix

### 5. Additional Literature (GPT, Grok)
- Rambachan & Roth (2023) — cited but not applied
- Note: implementation for continuous treatment is non-standard
- Add acknowledgment that formal sensitivity analysis isn't feasible

## Execution Order
1. Code changes: add state trends spec, WCB for fuel, North dummy comparison
2. Paper revisions: soften causal claims, add new results, restructure exhibits
3. Recompile and verify
