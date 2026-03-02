# Stage C Revision Plan: Addressing Referee Feedback

## Reviewer Decisions
- GPT-5.2: MAJOR REVISION
- Grok-4.1-Fast: MAJOR REVISION
- Gemini-3-Flash: MINOR REVISION

## Key Issues and Responses

### 1. Multiple Testing / Inference (All reviewers)
**Issue:** Romano-Wolf shows no individual horizon survives FWER at 5%. Long-run scarring claim rests on imprecise coefficients.
**Response:** Restructured abstract and introduction to lead with pre-specified π_LR = -0.037 as primary test object. Honest reporting of RW results throughout. Individual horizons framed as exploratory.

### 2. Causal Claims Too Strong (GPT, Grok)
**Issue:** Title/abstract imply general causal claim about demand vs supply recessions.
**Response:** Already had episode-comparative caveat in introduction (line 104). Further softened abstract and results language. Maintained title (subtitle already qualifies).

### 3. Welfare Ratio Precision (GPT, Grok)
**Issue:** 12:1 ratio presented too precisely given J-test rejection and ρ_a sensitivity.
**Response:** Abstract now reports 7-18:1 range. Welfare section notes model rejection explicitly. Conclusion uses range framing. Bold formatting removed from point estimate.

### 4. IV Attenuation at Long Horizons (GPT, Gemini)
**Issue:** Text claimed IV "comparable to OLS through h=48" but IV is -0.022 vs OLS -0.053 at h=48.
**Response:** Fixed text to say "comparable through h=24" with explicit note of h=48 attenuation.

### 5. Fiscal Confounding (GPT, Grok)
**Issue:** Can't separate shock type from policy response.
**Response:** Section 7.5 already has extensive discussion. Introduction caveat strengthened. No new data analysis possible in text revision.

### 6. COVID Horizon Coverage (from advisor review)
**Issue:** Data extends to June 2024 (52 months post-peak) but analysis truncated at 48 months.
**Response:** Added explicit text explaining deliberate truncation for round horizons.

## Changes Not Made (Out of Scope for Text Revision)
- Additional recessions (2001, 1981-82) — would require new data/analysis
- State-level duration measures from CPS micro — would require new data
- Balance tests for Saiz elasticity — would require new analysis
- Restricted permutations — would require new code
- Fiscal controls (PPP/ARRA as controls) — would require new data
