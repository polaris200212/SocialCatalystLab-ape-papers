# Revision Plan 2 — Post External Reviews

## Verdicts
- GPT-5.2: MAJOR REVISION
- Grok-4.1-Fast: MINOR REVISION
- Gemini-3-Flash: MINOR REVISION

## Priority Changes

### 1. DDD Event Study (All reviewers)
- Generate dynamic DDD coefficients using relative-time interactions
- Plot pre/post treatment effects to validate parallel trends in road-type gap
- Add as Figure 9

### 2. Treatment Intensity Clarification (GPT, Gemini)
- Clarify that the binary DDD is ITT on the département policy package
- Note median share is 9%, so effect per percentage point is ~0.34
- Adjust welfare calculation to reflect ITT nature

### 3. Welfare Scaling (GPT)
- Scale back quantitative welfare claims
- Frame as illustrative rather than definitive
- Acknowledge fatality uncertainty as dominant source of welfare uncertainty

### 4. Two-Way Clustering (GPT)
- Add two-way clustered SEs (département × time) for DDD
- Report alongside one-way as robustness

### 5. Estimator Transparency (GPT)
- Document CS-DiD parameters: control group, bootstrap reps, anticipation
- Note how DDD stacking preserves identification

### 6. Minor Fixes
- Currency standardization (already €, but verify PDF rendering)
- Clarify "corporal accidents" = injury accidents only
- Mention property-damage-only limitation more prominently
