# Reviewer Response Plan — Round 1

**Date:** 2026-02-26
**Decisions:** GPT MAJOR, Grok MAJOR, Gemini MINOR

## Common Concerns (All Reviewers)

### 1. DDD Pre-Trend Test (GPT §1.3, Grok §6.1, Gemini §6.1)
All three want a formal event-study / pre-trend test for the DDD gap (state gov - private sector).
**Action:** Implement DDD event study in R; add pre-trend joint test; add figure.

### 2. Reframe Causal Claims (GPT §5.1-5.2, Grok §5)
Paper oversells "no effect" when pre-trends are violated and post-window is short.
**Action:** Soften language in abstract/conclusion to "no detectable short-run stock-composition change."

### 3. Local Government Placebo (GPT §3.1, Grok §6.1)
The +0.014 (p=0.03) local placebo is concerning and under-discussed.
**Action:** Add discussion of why local gov might show this pattern (possible spillovers, different occupational mix).

## High-Priority Improvements

### 4. Wild Cluster Bootstrap (GPT §2.1, Grok §2)
**Action:** Add wild cluster bootstrap p-values for TWFE and DDD main estimates using `fwildclusterboot`.

### 5. State-Specific Linear Trends (GPT §3.1)
**Action:** Add TWFE specification with state-specific linear trends as robustness.

### 6. Leave-One-Out (Internal review)
**Action:** Drop each treated state one at a time, report range of estimates.

### 7. Cohort-Specific ATTs (Gemini §6.1)
**Action:** Report CS ATTs separately for 2022 and 2023 cohorts.

## Prose/Exhibit Improvements (from A.5/A.6)

### 8. Fix prose per review: already done in previous revision pass.

## Implementation Order
1. R code: DDD event study, WCB, state trends, leave-one-out, cohort ATTs
2. Tables/figures: regenerate
3. Paper text: incorporate new results, reframe claims
4. Recompile and verify
